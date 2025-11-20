use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Julio 2024
-- Description:	Toma un objeto JSON para ingresar registros en la tabla Cotización.
-- Modificación: Mayo 2025
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_COTIZACION_INGRESA]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_COTIZACION_INGRESA]
GO

CREATE PROCEDURE [dbo].[PA_COTIZACION_INGRESA] (@pCotizacion as nvarchar(max))
AS
BEGIN TRY
	BEGIN TRAN

		set @pCotizacion = replace(@pCotizacion, '{ pCotizacion = "{', '{');
		set @pCotizacion = replace(@pCotizacion, '" }', '');

		declare @consecutivo int = 0;
		declare @consecutivoDesdeApp int = (select consecutivo from openjson(@pCotizacion) with (consecutivo int '$.consecutivo'));
		declare @ultimoConsecutivoDisponible int = (select top 1 (consecutivo + 1) from SICORE_COTIZACION order by consecutivo desc);
		declare @tipoCompra varchar(150) = (select tipoCompra from openjson(@pCotizacion) with (tipoCompra varchar(150) '$.tipoCompra'));

		if(@ultimoConsecutivoDisponible != @consecutivoDesdeApp) set @consecutivo = @ultimoConsecutivoDisponible;
		else set @consecutivo = @consecutivoDesdeApp;
		
		if(@tipoCompra = 'Uso interno') exec SICORE.dbo.PA_COTIZACION_INGRESA_USO_INTERNO @pCotizacion
		else begin

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
				'V',
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

			declare @remanenteVirtual decimal(18,2) = 0;
			declare @remanenteReal decimal(18,2) = 0;
			declare @totalComprometido decimal(18,2) = 0;

			set @remanenteVirtual = (select comprometido from SICORE_INVENTARIO where idProyecto = @idProyecto);
			set @remanenteVirtual = @remanenteVirtual - @cantidad;
			set @remanenteReal = (select remanente from SICORE_INVENTARIO where idProyecto = @idProyecto);

			insert into SICORE_MOVIMIENTO_INVENTARIO
			values
			(
				@idProyecto,
				@idUsuario,
				getdate(),
				@cantidad,
				@descripcion,
				'C',
				@remanenteVirtual,
				@remanenteReal,
				getdate(),
				@idUsuario,	
				null,
				null
			)

			update SICORE_INVENTARIO
				set
					comprometido = @remanenteVirtual,
					fechaModificoAuditoria = getdate(),
					idUsuarioModificoAuditoria = @idUsuario
				where
					idProyecto = @idProyecto;

			declare @numeroCotizacion varchar(255) = 'DDC-CO-' + @consecutivoConFormato +'-'+ @periodo;
			exec SICORE.dbo.PA_ENVIAR_NOTIFICACION_COTIZACION @numeroCotizacion, @idUsuario

			select 1 as resultado;
		end;

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK

	select ERROR_MESSAGE() as resultado
END CATCH