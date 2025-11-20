use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Octubre 2025
-- Description:	Toma un objeto JSON para ingresar registros en la tabla Cotización pero, bajo las condiciones de uso interno.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_COTIZACION_INGRESA_USO_INTERNO]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_COTIZACION_INGRESA_USO_INTERNO]
GO

CREATE PROCEDURE [dbo].[PA_COTIZACION_INGRESA_USO_INTERNO] (@pCotizacion as nvarchar(max))
AS
BEGIN TRY
	BEGIN TRAN

		set @pCotizacion = replace(@pCotizacion, '{ pCotizacion = "{', '{');
		set @pCotizacion = replace(@pCotizacion, '" }', '');

		declare @consecutivo int = 0;
		declare @consecutivoDesdeApp int = (select consecutivo from openjson(@pCotizacion) with (consecutivo int '$.consecutivo'));
		declare @tipoCompra varchar(150) = (select tipoCompra from openjson(@pCotizacion) with (tipoCompra varchar(150) '$.tipoCompra'));
		declare @ultimoConsecutivoDisponible int = (select top 1 (consecutivo + 1) from SICORE_COTIZACION order by consecutivo desc);

		if(@ultimoConsecutivoDisponible != @consecutivoDesdeApp) set @consecutivo = @ultimoConsecutivoDisponible;
		else set @consecutivo = @consecutivoDesdeApp;

		insert into SICORE_COTIZACION
		select	
			idCliente,
			idFuncionario,
			idProyecto,
			getdate(),
			fechaExpiracion,
			cantidad,
			precioUnitario,
			subTotal,
			montoTotalColones,
			montoTotalDolares,
			@consecutivo,
			anotaciones,
			'U',
			getdate(),
			idFuncionario,
			null,
			null,
			cuentaConvenio,
			cotizacionEnIngles,
			0,
			tipoCompra,
			justificacionCompra,
			''
		from
			openjson(@pCotizacion)
		with
			(
				idCliente bigint '$.idCliente',
				idFuncionario bigint '$.idFuncionario',
				idProyecto bigint '$.idProyecto',
				cantidad decimal(18,2) '$.cantidad',
				precioUnitario decimal(18,2) '$.precioUnitario',
				subTotal decimal(18,2) '$.subTotal',
				montoTotalDolares decimal(18,2) '$.montoTotalDolares',
				montoTotalColones decimal(18,2) '$.montoTotalColones',
				anotaciones nvarchar(max) '$.anotaciones',
				fechaExpiracion date '$.fechaExpiracion',
				cuentaConvenio char(1) '$.cuentaConvenio',
				cotizacionEnIngles bit '$.cotizacionEnIngles',
				tipoCompra varchar(100) '$.tipoCompra',
				justificacionCompra varchar(100) '$.justificacionCompra'
			)

		declare @idCliente bigint = (select idCliente from openjson (@pCotizacion) with (idCliente bigint '$.idCliente'));
		declare @anotaciones varchar(150) = (select anotaciones from openjson (@pCotizacion) with (anotaciones varchar(150) '$.anotaciones'));
		declare @nombreCliente varchar(150) = (select nombreCliente from SICORE_CLIENTE where idCliente = @idCliente);
		declare @periodo varchar(4) = cast(year(getdate()) as varchar(4));
		declare @consecutivoConFormato varchar(10) = '';
		
		if(len(@consecutivo) = 1) set @consecutivoConFormato = '00' + cast(@consecutivo as varchar(3));
		if(len(@consecutivo) = 2) set @consecutivoConFormato = '0' + cast(@consecutivo as varchar(3));
		if(len(@consecutivo) = 3) set @consecutivoConFormato = cast(@consecutivo as varchar(3));

		declare @idProyecto	bigint = (select idProyecto from openjson(@pCotizacion) with (idProyecto bigint '$.idProyecto'));
		declare @idUsuario	bigint = (select idFuncionario from openjson(@pCotizacion) with (idFuncionario bigint '$.idFuncionario'));
		declare @cantidad	decimal(18,2) = (select cantidad from openjson(@pCotizacion) with (cantidad decimal(18,2) '$.cantidad'));;
		declare @descripcion nvarchar(max) = 'Cotización número: DDC-CO-' + @consecutivoConFormato +'-'+ @periodo + ' para: ' + @nombreCliente + ' con la anotación de: ' + @anotaciones;

		declare @remanenteVirtual decimal(18,2) = (select comprometido from SICORE_INVENTARIO where idProyecto = @idProyecto);
		declare @remanenteReal decimal(18,2) = (select remanente from SICORE_INVENTARIO where idProyecto = @idProyecto);
		declare @totalComprometido decimal(18,2) = 0;

		set @remanenteVirtual = @remanenteVirtual - @cantidad;
		set @remanenteReal = @remanenteReal - @cantidad;

		update SICORE_INVENTARIO
		set
			remanente = @remanenteReal,
			vendido = vendido + @cantidad,
			fechaModificoAuditoria = getdate(),
			idUsuarioModificoAuditoria = @idUsuario
		where
			idProyecto = @idProyecto;
				
		insert into SICORE_MOVIMIENTO_INVENTARIO
		values(
			@idProyecto,
			@idUsuario,
			getdate(),
			@cantidad,
			'Venta por constitución de uso interno.',
			'V',
			@remanenteVirtual,
			@remanenteReal,
			getdate(),
			@idUsuario,
			null,
			null
		);

		declare @numeroCertificado int = (select top 1 numeroCertificado from SICORE_CERTIFICADO order by idCertificado desc);
		declare @cedulaCliente varchar(50) = (select cedulaCliente from SICORE_CLIENTE where idCliente = @idCliente);
		declare @nombreCertificado varchar(150) = (select nombreCliente from SICORE_CLIENTE where idCliente = @idCliente);

		declare @montoTransferencia decimal(18,2) = 0;
		declare @numeroTransferencia varchar(10) = 0;
		declare @fechaTransferencia datetime = getdate();
		
		declare @annoInventarioGEI int = year(getdate());

		if @numeroCertificado is null
		begin
			set @numeroCertificado = 62;
		end
		else
		begin
			set @numeroCertificado = @numeroCertificado + 1;
		end

		declare @numeroUnico varchar(150) = '';

		if(len(@numeroCertificado) = 1) set @numeroUnico = '00' + cast(@numeroCertificado as varchar(10));
		if(len(@numeroCertificado) = 2) set @numeroUnico = '0' + cast(@numeroCertificado as varchar(10));
		if(len(@numeroCertificado) = 3) set @numeroUnico = cast(@numeroCertificado as varchar(10));
	
		set @numeroUnico = cast(@annoInventarioGEI as varchar(10)) + '-' + @numeroUnico;
		declare @numeroCertificadoUnico varchar(100) = CONVERT(varchar(100), NEWID());

		declare @idCotizacion bigint = (select top 1 idCotizacion from SICORE_COTIZACION where indicadorEstado = 'U' order by idCotizacion desc);

		insert into SICORE_FORMALIZACION
		values (
			@idCotizacion,
			@idUsuario,
			getdate(),
			0,
			0,
			@consecutivo,
			0,
			0,
			'Uso interno',
			'D',
			'U',
			'N',
			getdate(),
			getdate(),
			@idUsuario,
			getdate(),
			@idUsuario,
			0,
			'S',
			'Uso interno'
		);

		declare @idFormalizacion bigint = (select top 1 idFormalizacion from SICORE_FORMALIZACION where indicadorEstado = 'U' order by idFormalizacion desc);
		
		insert into SICORE_CERTIFICADO
		values(
			@idFormalizacion,
			@idCotizacion,
			@idUsuario,
			@numeroCertificado,
			upper(@nombreCertificado),
			getdate(),
			@cedulaCliente,
			@montoTransferencia,
			@numeroTransferencia,
			@fechaTransferencia,
			@annoInventarioGEI,
			getdate(),
			@idUsuario,
			getdate(),
			@idUsuario,
			'',
			@numeroUnico,
			'',
			'U',
			'',
			'',
			@numeroCertificadoUnico
		);

		select 1 as resultado;

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK

	select ERROR_MESSAGE() as resultado
END CATCH