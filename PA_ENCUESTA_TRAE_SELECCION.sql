USE [SICORE]
GO

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

		DECLARE @primerDiaAnno AS DATE = DATEFROMPARTS(YEAR(GETDATE()), 1, 1);
		DECLARE @hoyEnDia AS DATE = CAST(GETDATE() AS DATE);
			
		SELECT
			pregunta pregunta,
			respuesta,
			count(idReporte) conteo
		FROM
			SICORE_ENCUESTA_REPORTE
		WHERE
			tipoPregunta = 'S'
		AND
			CAST(fechaHoraRespuesta AS DATE) BETWEEN @primerDiaAnno AND @hoyEnDia
		GROUP BY
			pregunta,
			respuesta
		
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE();
END CATCH