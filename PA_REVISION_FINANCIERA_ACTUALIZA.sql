use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Julio 2024
-- Description:	Toma un JSON para actualizar los registros de la tabla Revisión Financiera.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_REVISION_FINANCIERA_ACTUALIZA]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_REVISION_FINANCIERA_ACTUALIZA]
GO

CREATE PROCEDURE [dbo].[PA_REVISION_FINANCIERA_ACTUALIZA] (@pRevisionFinanciera as nvarchar(max))
AS
BEGIN TRY
	BEGIN TRANSACTION
		
		SET NOCOUNT ON;

		declare @idRevisionFinanciera int = (select idRevisionFinanciera from openjson (@pRevisionFinanciera) with (idRevisionFinanciera int '$.IdRevisionFinanciera'));
		declare @idCotizacion int = (select idCotizacion from openjson (@pRevisionFinanciera) with (idCotizacion int '$.IdCotizacion'));
		declare @idPago int = (select idPago from openjson (@pRevisionFinanciera) with (idPago int '$.IdPago'));
		declare @fechaPago date = (select fechaPago from openjson (@pRevisionFinanciera) with (fechaPago date '$.FechaPago'));
		declare @idRecibo int = (select idRecibo from openjson (@pRevisionFinanciera) with (idRecibo int '$.IdRecibo'));
		declare @fechaRecibo date = (select fechaRecibo from openjson (@pRevisionFinanciera) with (fechaRecibo date '$.FechaRecibo'));
		declare @estado int = (select estado from openjson (@pRevisionFinanciera) with (estado int '$.Estado'));

		update SICORE_REVISION_FINANCIERA
			set
				idCotizacion = @idCotizacion,
				idPago = @idPago,
				fechaPago = @fechaPago,
				idRecibo = @idRecibo,
				fechaRecibo = @fechaRecibo,
				estado = @estado
			where
				idRevisionFinanciera = @idRevisionFinanciera;

		SET NOCOUNT OFF;

		select 1 as resultado

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK

	select ERROR_MESSAGE() as resultado
END CATCH