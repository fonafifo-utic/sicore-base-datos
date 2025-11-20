use SICORE
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Marzo 2025
-- Description:	Toma un objeto JSON para actualizar los registros de la tabla Formalización.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_FORMALIZACION_ACTUALIZA_FORMALIZACION]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_FORMALIZACION_ACTUALIZA_FORMALIZACION]
GO

CREATE PROCEDURE [dbo].[PA_FORMALIZACION_ACTUALIZA_FORMALIZACION] (@pFormalizacion as nvarchar(max))
AS
BEGIN TRY
	BEGIN TRANSACTION

		set @pFormalizacion = replace(@pFormalizacion, '{ pFormalizacion = "{', '{');
		set @pFormalizacion = replace(@pFormalizacion, '" }', '');

		declare @idFormalizacion bigint = (select idFormalizacion from openjson(@pFormalizacion) with (idFormalizacion bigint '$.idFormalizacion'));
		declare @idFuncionario bigint = (select idUsuario from openjson(@pFormalizacion) with (idUsuario bigint '$.idUsuario'));

		declare @numeroComprobante varchar(100) = (select numeroComprobante from openjson(@pFormalizacion) with (numeroComprobante varchar(100) '$.numeroComprobante'));
		declare @numeroFactura varchar(100) = (select numeroFactura from openjson(@pFormalizacion) with (numeroFactura varchar(100) '$.numeroFactura'));
		declare @numeroTransaccion varchar(100) = (select numeroTransferencia from openjson(@pFormalizacion) with (numeroTransferencia varchar(100) '$.numeroTransferencia'));
		declare @tieneFacturas char(1) = (select tieneFacturas from openjson(@pFormalizacion) with (tieneFacturas char(1) '$.tieneFacturas'));
		declare @indicadorEstado char(1) = (select indicadorEstado from openjson(@pFormalizacion) with (indicadorEstado char(1) '$.indicadorEstado'));

		update SICORE_FORMALIZACION
			set
				numeroFacturaFonafifo = @numeroFactura,
				numeroTransferencia = @numeroTransaccion,
				numeroComprobante = @numeroComprobante,
				tieneFacturas = @tieneFacturas,
				fechaModificoAuditoria = getdate(),
				idUsuarioModificoAuditoria = @idFuncionario,
				indicadorEstado = @indicadorEstado
			where
				idFormalizacion = @idFormalizacion;

		declare @consecutivo int = (select consecutivo from SICORE_FORMALIZACION where idFormalizacion = @idFormalizacion);
		declare @anno varchar(10) = cast(year(getdate()) as varchar(5));
		declare @numeroFormalizacion varchar(100) = '';

		if(len(@consecutivo) = 1) set @numeroFormalizacion = '00' + cast(@consecutivo as varchar(5));
		if(len(@consecutivo) = 2) set @numeroFormalizacion = '0' + cast(@consecutivo as varchar(5));
		if(len(@consecutivo) = 3) set @numeroFormalizacion = cast(@consecutivo as varchar(5));
		
		set @numeroFormalizacion = 'DDC-CO-' + @numeroFormalizacion + '-' + @anno;
		
		exec PA_ENVIAR_NOTIFICACION_FORMALIZACION @numeroFormalizacion, @idFuncionario

		select 1 as resultado;

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK

	select ERROR_MESSAGE() as resultado
END CATCH
