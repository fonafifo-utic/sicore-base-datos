use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Diciembre 2024
-- Description:	Trae respuestas de Selección.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_ENCUESTA_TRAE_SELECCION]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_ENCUESTA_TRAE_SELECCION]
GO

CREATE PROCEDURE [dbo].[PA_ENCUESTA_TRAE_SELECCION]
AS
BEGIN TRY
	BEGIN TRAN

		select
			pregunta,
			respuesta,
			count(idReporte) conteo
		from
			SICORE_ENCUESTA_REPORTE
		where
			tipoPregunta = 'S'
		group by
			pregunta,
			respuesta
		
	COMMIT
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE();

	ROLLBACK TRAN
END CATCH