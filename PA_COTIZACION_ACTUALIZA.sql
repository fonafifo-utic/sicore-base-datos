use SICORE
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Julio 2024
-- Description:	Toma un objeto JSON para actualizar los registros de la tabla Cotización.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_COTIZACION_ACTUALIZA]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_COTIZACION_ACTUALIZA]
GO

CREATE PROCEDURE [dbo].[PA_COTIZACION_ACTUALIZA] (@pCotizacion as nvarchar(max))
AS
BEGIN TRY
	BEGIN TRANSACTION

		set @pCotizacion = replace(@pCotizacion, '{ pCotizacion = "{', '{');
		set @pCotizacion = replace(@pCotizacion, '" }', '');

		declare @idCotizacion bigint = (select idCotizacion from openjson (@pCotizacion) with (idCotizacion bigint '$.idCotizacion'));
		declare @idCliente bigint = (select idCliente from openjson(@pCotizacion) with (idCliente bigint '$.idCliente'));
		declare @idFuncionario bigint = (select idFuncionario from openjson(@pCotizacion) with (idFuncionario bigint '$.idFuncionario'));	
		declare @idProyecto	bigint = (select idProyecto from openjson(@pCotizacion) with (idProyecto bigint '$.idProyecto'));
		declare @cantidad decimal(18,2)	= (select cantidad from openjson(@pCotizacion) with (cantidad decimal(18,2) '$.cantidad'));
		declare @cantidadAnterior decimal(18,2)	= (select cantidad from SICORE_COTIZACION where idCotizacion = @idCotizacion);
		declare @precioUnitario decimal(18,2) = (select precioUnitario from openjson(@pCotizacion) with (precioUnitario decimal(18,2) '$.precioUnitario'));
		declare @subTotal decimal(18,2) = (select subTotal from openjson(@pCotizacion) with (subTotal decimal(18,2) '$.subTotal'));
		declare @montoTotalColones decimal(18,2) = (select montoTotalColones from openjson(@pCotizacion) with (montoTotalColones decimal(18,2) '$.montoTotalColones'));
		declare @montoTotalDolares decimal(18,2) = (select montoTotalDolares from openjson(@pCotizacion) with (montoTotalDolares decimal(18,2) '$.montoTotalDolares'));
		declare @consecutivo int = (select consecutivo from openjson(@pCotizacion) with (consecutivo int '$.consecutivo'));	
		declare @anotaciones nvarchar(max) = (select anotaciones from openjson(@pCotizacion) with (anotaciones nvarchar(max) '$.anotaciones'));
		declare @cuentaConvenio char(1) = (select cuentaConvenio from openjson(@pCotizacion) with (cuentaConvenio char(1) '$.cuentaConvenio'));
		declare @fechaExpiracion date = (select fechaExpiracion from openjson(@pCotizacion) with (fechaExpiracion date '$.fechaExpiracion'));
		declare @cotizacionEnIngles bit = (select cotizacionEnIngles from openjson(@pCotizacion) with (cotizacionEnIngles bit '$.cotizacionEnIngles'));
		declare @tipoCompra varchar(100) = (select tipoCompra from openjson(@pCotizacion) with (tipoCompra varchar(100) '$.tipoCompra'));
		declare @justificacionCompra varchar(100) = (select justificacionCompra from openjson(@pCotizacion) with (justificacionCompra varchar(100) '$.justificacionCompra'));
		
		declare @nombreCliente varchar(150) = (select nombreCliente from SICORE_CLIENTE where idCliente = @idCliente);
		declare @periodo varchar(4) = cast(year(getdate()) as varchar(4));
		declare @consecutivoConFormato varchar(10) = '';

		if(len(@consecutivo) = 1) set @consecutivoConFormato = '00' + cast(@consecutivo as varchar(3));
		if(len(@consecutivo) = 2) set @consecutivoConFormato = '0' + cast(@consecutivo as varchar(3));
		if(len(@consecutivo) = 3) set @consecutivoConFormato = cast(@consecutivo as varchar(3));

		declare @descripcion nvarchar(max) = 'Modificación de cotización número DDC-CO-' + @consecutivoConFormato + '-' + @periodo + ' para ' + @nombreCliente + ' con la siguiente anotación ' + @anotaciones;

		update SICORE_INVENTARIO
			set
				comprometido = comprometido + @cantidadAnterior
			where
				idProyecto = @idProyecto;

		update SICORE_INVENTARIO
			set
				comprometido = comprometido - @cantidad,
				idUsuarioModificoAuditoria = @idFuncionario,
				fechaModificoAuditoria = getdate()
			where
				idProyecto = @idProyecto;

		declare @remanenteVirtual decimal(18,2) = 0;
		declare @remanenteReal decimal(18,2) = 0;
		declare @totalComprometido decimal(18,2) = 0;
		
		set @remanenteVirtual = (select comprometido from SICORE_INVENTARIO where idProyecto = @idProyecto);
		set @remanenteReal = (select remanente from SICORE_INVENTARIO where idProyecto = @idProyecto);

		insert into SICORE_MOVIMIENTO_INVENTARIO
		values
		(
			@idProyecto,
			@idFuncionario,
			getdate(),
			@cantidad,
			@descripcion,
			'M',
			@remanenteVirtual,
			@remanenteReal,
			getdate(),
			@idFuncionario,	
			null,
			null
		)

		declare @indicadorEstado char(1) = (select indicadorEstado from SICORE_COTIZACION where idCotizacion = @idCotizacion);
		if(@indicadorEstado = 'R')
		begin
			update SICORE_COTIZACION
				set
					idCliente = @idCliente,
					idFuncionario = @idFuncionario,
					idProyecto = @idProyecto,
					cantidad = @cantidad,
					precioUnitario = @precioUnitario,
					subTotal = @subTotal,
					fechaExpiracion = @fechaExpiracion,
					montoTotalDolares = @montoTotalDolares,
					consecutivo = @consecutivo,
					anotaciones = @anotaciones,
					cuentaConvenio = @cuentaConvenio,
					cotizacionEnIngles = @cotizacionEnIngles,
					tipoCompra = @tipoCompra,
					justificacionCompra = @justificacionCompra,
					fechaModificoAuditoria = getdate(),
					idUsuarioModificoAuditoria = @idFuncionario,
					indicadorEstado = 'V'
			where
				idCotizacion = @idCotizacion;

			declare @numeroCotizacion varchar(255) = 'DDC-CO-' + @consecutivoConFormato +'-'+ @periodo;
			exec SICORE.dbo.PA_ENVIAR_NOTIFICACION_COTIZACION @numeroCotizacion, @idFuncionario
		end
		else
		begin
			update SICORE_COTIZACION
				set
					idCliente = @idCliente,
					idFuncionario = @idFuncionario,
					idProyecto = @idProyecto,
					cantidad = @cantidad,
					precioUnitario = @precioUnitario,
					subTotal = @subTotal,
					fechaExpiracion = @fechaExpiracion,
					montoTotalDolares = @montoTotalDolares,
					consecutivo = @consecutivo,
					anotaciones = @anotaciones,
					cuentaConvenio = @cuentaConvenio,
					cotizacionEnIngles = @cotizacionEnIngles,
					tipoCompra = @tipoCompra,
					justificacionCompra = @justificacionCompra,
					fechaModificoAuditoria = getdate(),
					idUsuarioModificoAuditoria = @idFuncionario
			where
				idCotizacion = @idCotizacion;
		end
	
		select 1 as resultado;

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK

	select ERROR_MESSAGE() as resultado
END CATCH