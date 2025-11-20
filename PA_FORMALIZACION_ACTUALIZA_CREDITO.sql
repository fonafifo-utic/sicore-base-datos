use SICORE
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Marzo 2025
-- Description:	Toma un objeto JSON para actualizar los registros de la tabla Formalización de una Cotización en Crédito.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_FORMALIZACION_ACTUALIZA_CREDITO]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_FORMALIZACION_ACTUALIZA_CREDITO]
GO

CREATE PROCEDURE [dbo].[PA_FORMALIZACION_ACTUALIZA_CREDITO] (@pFormalizacion as nvarchar(max))
AS
BEGIN TRY
	BEGIN TRANSACTION

		set @pFormalizacion = replace(@pFormalizacion, '{ pFormalizacion = "{', '{');
		set @pFormalizacion = replace(@pFormalizacion, '" }', '');

		declare @idFormalizacion bigint = (select idFormalizacion from openjson(@pFormalizacion) with (idFormalizacion bigint '$.idFormalizacion'));
		declare @idFuncionario bigint = (select idUsuario from openjson(@pFormalizacion) with (idUsuario bigint '$.idUsuario'));
		declare @numeroComprobante varchar(100) = (select numeroComprobante from openjson(@pFormalizacion) with (numeroComprobante varchar(100) '$.numeroComprobante'));
		declare @numeroFactura varchar(100) = (select UPPER(numeroFactura) numeroFactura from openjson(@pFormalizacion) with (numeroFactura varchar(100) '$.numeroFactura'));
		declare @tieneFaturas char(1) = (select tieneFaturas from openjson(@pFormalizacion) with (tieneFaturas char(1) '$.tieneFacturas'));
		declare @indicadorEstado char(1) = (select indicadorEstado from openjson(@pFormalizacion) with (indicadorEstado char(1) '$.indicadorEstado'));
		declare @creditoDebito char(1) = (select creditoDebito from SICORE_FORMALIZACION where idFormalizacion = @idFormalizacion);

		update SICORE_FORMALIZACION
		set 
			numeroFacturaFonafifo = @numeroFactura,
			tieneFacturas = @tieneFaturas,
			fechaHoraFormalizacion = getdate(),
			fechaModificoAuditoria = getdate(),
			idUsuarioModificoAuditoria = @idFuncionario,
			indicadorEstado = @indicadorEstado
		where
			idFormalizacion = @idFormalizacion;

		select 1 as resultado;

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK

	select ERROR_MESSAGE() as resultado
END CATCH