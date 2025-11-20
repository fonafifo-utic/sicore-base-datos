use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Julio 2024
-- Description:	Trae registros de Revisión Financiera filtrados por ID.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_REVISION_FINANCIERA_TRAE_PORID]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_REVISION_FINANCIERA_TRAE_PORID]
GO

CREATE PROCEDURE [dbo].[PA_REVISION_FINANCIERA_TRAE_PORID] (@pIdRevisionFinanciera as int)
AS
BEGIN TRY
	BEGIN TRANSACTION
		
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
		where
			idRevisionFinanciera = @pIdRevisionFinanciera

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK
END CATCH