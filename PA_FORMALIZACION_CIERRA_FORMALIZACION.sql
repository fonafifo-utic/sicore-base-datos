use SICORE
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Octubre 2024
-- Description:	Toma un objeto JSON para actualizar los registros de la tabla Formalización.
-- Modificación: Marzo 2025.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_FORMALIZACION_CIERRA_FORMALIZACION]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_FORMALIZACION_CIERRA_FORMALIZACION]
GO

CREATE PROCEDURE [dbo].[PA_FORMALIZACION_CIERRA_FORMALIZACION] (@pFormalizacion as nvarchar(max))
AS
BEGIN TRY
	BEGIN TRANSACTION

		set @pFormalizacion = replace(@pFormalizacion, '{ pFormalizacion = "{', '{');
		set @pFormalizacion = replace(@pFormalizacion, '" }', '');

		declare @idFormalizacion varchar(10) = (select idFormalizacion from openjson(@pFormalizacion) with (idFormalizacion varchar(10) '$.idFormalizacion'));

		declare @idFuncionario bigint = (select idUsuario from openjson(@pFormalizacion) with (idUsuario bigint '$.idUsuario'));
		declare @tieneFaturas char(1) = (select tieneFaturas from openjson(@pFormalizacion) with (tieneFaturas char(1) '$.tieneFacturas'));
		declare @indicadorEstado char(1) = (select indicadorEstado from openjson(@pFormalizacion) with (indicadorEstado char(1) '$.indicadorEstado'));
		declare @numeroTransaccion varchar(100) = (select numeroTransferencia from openjson(@pFormalizacion) with (numeroTransferencia varchar(100) '$.numeroTransferencia'))
		declare @numeroComprobante varchar(100) = (select numeroComprobante from openjson(@pFormalizacion) with (numeroComprobante varchar(100) '$.numeroComprobante'));
		declare @numeroFactura varchar(100) = (select numeroFactura from openjson(@pFormalizacion) with (numeroFactura varchar(100) '$.numeroFactura'));

		declare @periodo varchar(4) = cast(year(getdate()) as varchar(4));
		declare @annoInventarioGEI int = year(getdate());
		declare @numeroConsecutivo varchar(10) = '';
		declare @tabla as table (indice int identity(1,1), cotizacion int null);
		declare @min int = 0;
		declare @max int = 0;

		declare @creditoDebito char(1) = (select top 1 creditoDebito from SICORE_FORMALIZACION where idFormalizacion in (select value
																															from string_split(@idFormalizacion, ',')
																															where value != ''));
-- Actualiza la Formalización si la factura es a crédito o al contado ('D').
		if(@creditoDebito = 'C')
		begin

			update SICORE_FORMALIZACION
			set
				indicadorEstado = @indicadorEstado,
				fechaHoraFormalizacion = getdate(),
				fechaModificoAuditoria = getdate(),
				idUsuarioModificoAuditoria = @idFuncionario
			where
				idFormalizacion in	(
										select value
										from string_split(@idFormalizacion, ',')
										where value != ''
									);
		end
		else
		begin
			update SICORE_FORMALIZACION
				set
					indicadorEstado = @indicadorEstado,
					tieneFacturas = @tieneFaturas,
					fechaHoraFormalizacion = getdate(),
					fechaModificoAuditoria = getdate(),
					idUsuarioModificoAuditoria = @idFuncionario
				where
					idFormalizacion in	(
											select value
											from string_split(@idFormalizacion, ',')
											where value != ''
										);
		end;

		declare @idCotizacion varchar(10) = '';
		declare @consecutivo int = 0;
		declare @cantidad decimal(18,2) = 0;
		declare @idProyecto bigint = 0;
		declare @remanente decimal(18,2) = 0;
		declare @remanenteVirtual decimal(18,2) = 0;

		if(len(@consecutivo) = 1) set @numeroConsecutivo = '00' + cast(@consecutivo as varchar(3));
		if(len(@consecutivo) = 2) set @numeroConsecutivo = '0' + cast(@consecutivo as varchar(3));
		if(len(@consecutivo) = 3) set @numeroConsecutivo = cast(@consecutivo as varchar(3));

-- Pregunta si tiene hay más de un código de Formalización para traerse los dos códigos de las Cotizaciones y el consecutivo de la Cotización Agrupada.
		if(charindex(',', @idFormalizacion) > 0)
		begin
			set @idCotizacion = (select string_agg(idCotizacion, ',') from SICORE_FORMALIZACION where idFormalizacion in (select value
																														from string_split(@idFormalizacion, ',')
																														where value != ''));

			set @consecutivo = (select top 1 consecutivo from SICORE_COTIZACION_AGRUPACION where indicadorEstado = 'P' and idCotizacion in (select value
																											from string_split(@idCotizacion, ',')
																											where value != ''));
		end
		else
		begin

-- Realiza la actualización del inventario e ingresa el movimiento correspondiente:
			set @idCotizacion = (select idCotizacion from SICORE_FORMALIZACION where idFormalizacion = @idFormalizacion);
			set @consecutivo = (select consecutivo from SICORE_FORMALIZACION where idFormalizacion = @idFormalizacion);

			set @cantidad = (select cantidad from SICORE_COTIZACION where idCotizacion = @idCotizacion);
			set @idProyecto = (select idProyecto from SICORE_COTIZACION where idCotizacion = @idCotizacion);
			set @remanente = (select remanente from SICORE_INVENTARIO where idProyecto = @idProyecto);
			set @remanenteVirtual = (select comprometido from SICORE_INVENTARIO where idProyecto = @idProyecto);

			set @remanente = @remanente - @cantidad;
			update SICORE_INVENTARIO
			set
				remanente = @remanente,
				vendido = vendido + @cantidad,
				fechaModificoAuditoria = getdate(),
				idUsuarioModificoAuditoria = @idFuncionario
			where
				idProyecto = @idProyecto;
		
			insert into SICORE_MOVIMIENTO_INVENTARIO
			values(
				@idProyecto,
				@idFuncionario,
				getdate(),
				@cantidad,
				'Venta por cotización número: DDC-CO-' + @numeroConsecutivo +'-'+ @periodo,
				'V',
				@remanenteVirtual,
				@remanente,
				getdate(),
				@idFuncionario,
				null,
				null
			);
		end

-- Actualiza los estados de las Cotizaciones:
		update SICORE_COTIZACION
		set
			indicadorEstado = @indicadorEstado,
			fechaModificoAuditoria = getdate(),
			idUsuarioModificoAuditoria = @idFuncionario
		where
			idCotizacion in (select value
								from string_split(@idCotizacion, ',')
								where value != '');

		update SICORE_COTIZACION_AGRUPACION
		set
			indicadorEstado = @indicadorEstado,
			fechaModificoAuditoria = getdate(),
			idUsuarioModificoAuditoria = @idFuncionario
		where
			idCotizacion in (select value
								from string_split(@idCotizacion, ',')
								where value != '');
		
-- Si hay más de una Formalización, entrará en un ciclo para actualizar el invenario y registrar los movimientos:
		if(charindex(',', @idFormalizacion) > 0)
		begin

			insert into @tabla
			select value from string_split(@idCotizacion, ',') where value != ''

			set @min = (select min(indice) from @tabla);
			set @max = (select max(indice) from @tabla);
			while (@min <= @max)
			begin
				declare @cotizacion int = (select cotizacion from @tabla where indice = @min);
				
				set @idProyecto = (select idProyecto from SICORE_COTIZACION where idCotizacion = @cotizacion);
				set @cantidad = (select cantidad from SICORE_COTIZACION where idCotizacion = @cotizacion);

				set @remanente = (select remanente from SICORE_INVENTARIO where idProyecto = @idProyecto);
				set @remanenteVirtual = (select comprometido from SICORE_INVENTARIO where idProyecto = @idProyecto);

				set @remanente = @remanente - @cantidad;

				update SICORE_INVENTARIO
				set
					remanente = @remanente,
					vendido = vendido + @cantidad,
					fechaModificoAuditoria = getdate(),
					idUsuarioModificoAuditoria = @idFuncionario
				where
					idProyecto = @idProyecto;
		
				insert into SICORE_MOVIMIENTO_INVENTARIO
				values(
					@idProyecto,
					@idFuncionario,
					getdate(),
					@cantidad,
					'Venta por cotización número: DDC-AG-' + @numeroConsecutivo +'-'+ @periodo,
					'V',
					@remanenteVirtual,
					@remanente,
					getdate(),
					@idFuncionario,
					null,
					null
				);
				
				set @min = (select min(indice) from @tabla where indice > @min);
			end
		end;

-- Contruye el Certificado:
		declare @idCliente int = 0;
		declare @idVendedor bigint = 0;
		declare @numeroCertificado int = 0;
		declare @cedulaCliente varchar(50) = '';
		declare @nombreCertificado varchar(150) = '';
		declare @montoTransferencia decimal(18,2) = 0;
		declare @numeroTransferencia varchar(10) = '';
		declare @fechaTransferencia datetime = '';
		declare @numeroUnico varchar(150) = '';

-- Si hay más de una Formalizacion, entrará en un ciclo para registrar los Certificados con un único número de Certificado.
		if(charindex(',', @idFormalizacion) > 0)
		begin
			delete from @tabla;
			set @min = 0;
			set @max = 0;
			set @cotizacion = 0;
			
			insert into @tabla
			select value from string_split(@idCotizacion, ',') where value != ''

			set @min = (select min(indice) from @tabla);
			set @max = (select max(indice) from @tabla);

			set @numeroCertificado = (select top 1 numeroCertificado from SICORE_CERTIFICADO order by idCertificado desc);
			if @numeroCertificado is null set @numeroCertificado = 62;
			else set @numeroCertificado = @numeroCertificado + 1;

			while (@min <= @max)
			begin

				set @cotizacion = (select cotizacion from @tabla where indice = @min);
				declare @formalizacion int = (select idFormalizacion from SICORE_FORMALIZACION where idCotizacion = @cotizacion);

				set @idCliente = (select idCliente from SICORE_COTIZACION where idCotizacion = @cotizacion);
				set @idVendedor = (select idFuncionario from SICORE_COTIZACION where idCotizacion = @cotizacion);
				
				set @cedulaCliente = (select cedulaCliente from SICORE_CLIENTE where idCliente = @idCliente);
				set @nombreCertificado = (select nombreCliente from SICORE_CLIENTE where idCliente = @idCliente);
				set @montoTransferencia = (select montoDolares from SICORE_FORMALIZACION where idFormalizacion = @formalizacion);
				set @numeroTransferencia = (select numeroTransferencia from SICORE_FORMALIZACION where idFormalizacion = @formalizacion);
				set @fechaTransferencia = (select fechaHora from SICORE_FORMALIZACION where idFormalizacion = @formalizacion);

				set @numeroUnico = '';

				if(len(@numeroCertificado) = 1) set @numeroUnico = '00' + cast(@numeroCertificado as varchar(10));
				if(len(@numeroCertificado) = 2) set @numeroUnico = '0' + cast(@numeroCertificado as varchar(10));
				if(len(@numeroCertificado) = 3) set @numeroUnico = cast(@numeroCertificado as varchar(10));
	
				set @numeroUnico = cast(@annoInventarioGEI as varchar(10)) + '-' + @numeroUnico;
				declare @numeroCertificadoUnico varchar(100) = CONVERT(varchar(100), NEWID());
	
				insert into SICORE_CERTIFICADO
				values(
					@formalizacion,
					@cotizacion,
					@idVendedor,
					@numeroCertificado,
					upper(@nombreCertificado),
					getdate(),
					@cedulaCliente,
					@montoTransferencia,
					@numeroTransferencia,
					@fechaTransferencia,
					@annoInventarioGEI,
					getdate(),
					@idFuncionario,
					getdate(),
					@idFuncionario,
					'',
					@numeroUnico,
					'',
					'V',
					'',
					'',
					@numeroCertificadoUnico
				);

				set @min = (select min(indice) from @tabla where indice > @min);

			end
		end
		else
		begin
			set @idCliente = (select idCliente from SICORE_COTIZACION where idCotizacion = @idCotizacion);
			set @idVendedor = (select idFuncionario from SICORE_COTIZACION where idCotizacion = @idCotizacion);

			set @numeroCertificado = (select top 1 numeroCertificado from SICORE_CERTIFICADO order by idCertificado desc);
			set @cedulaCliente = (select cedulaCliente from SICORE_CLIENTE where idCliente = @idCliente);
			set @nombreCertificado = (select nombreCliente from SICORE_CLIENTE where idCliente = @idCliente);
			set @montoTransferencia = (select montoDolares from SICORE_FORMALIZACION where idFormalizacion = @idFormalizacion);
			set @numeroTransferencia = (select numeroTransferencia from SICORE_FORMALIZACION where idFormalizacion = @idFormalizacion);
			set @fechaTransferencia = (select fechaHora from SICORE_FORMALIZACION where idFormalizacion = @idFormalizacion);

			if @numeroCertificado is null set @numeroCertificado = 62;
			else set @numeroCertificado = @numeroCertificado + 1;

			if(len(@numeroCertificado) = 1) set @numeroUnico = '00' + cast(@numeroCertificado as varchar(10));
			if(len(@numeroCertificado) = 2) set @numeroUnico = '0' + cast(@numeroCertificado as varchar(10));
			if(len(@numeroCertificado) = 3) set @numeroUnico = cast(@numeroCertificado as varchar(10));
	
			set @numeroUnico = cast(@annoInventarioGEI as varchar(10)) + '-' + @numeroUnico;
			set @numeroCertificadoUnico = CONVERT(varchar(100), NEWID());

			insert into SICORE_CERTIFICADO
			values(
				@idFormalizacion,
				@idCotizacion,
				@idVendedor,
				@numeroCertificado,
				upper(@nombreCertificado),
				getdate(),
				@cedulaCliente,
				@montoTransferencia,
				@numeroTransferencia,
				@fechaTransferencia,
				@annoInventarioGEI,
				getdate(),
				@idFuncionario,
				getdate(),
				@idFuncionario,
				'',
				@numeroUnico,
				'',
				'V',
				'',
				'',
				@numeroCertificadoUnico
			);
		end

		select 1 as resultado;

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK

	select ERROR_MESSAGE() as resultado
END CATCH
