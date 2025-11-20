use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Julio 2024
-- Description:	Trae todos los registros de Revisión Financiera.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_REVISION_FINANCIERA_TRAE_LISTADO]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_REVISION_FINANCIERA_TRAE_LISTADO]
GO

CREATE PROCEDURE [dbo].[PA_REVISION_FINANCIERA_TRAE_LISTADO]
AS
BEGIN TRY
	BEGIN TRANSACTION TPROCESO

		select
			idRevisionFinanciera,
			idCotizacion,
			idPago,
			fechaPago,
			idRecibo,
			fechaRecibo,
			estado,
			fechaInsertoAuditoria,
			idUsuarioInsertoAuditoria,
			fechaModificoAuditoria,
			idUsuarioModificoAuditoria
		from
			SICORE_REVISION_FINANCIERA

	COMMIT TRANSACTION TPROCESO
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE()
	ROLLBACK TRANSACTION TPROCESO
END CATCH