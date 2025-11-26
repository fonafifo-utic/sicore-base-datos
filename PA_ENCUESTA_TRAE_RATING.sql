USE [SICORE]
GO

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Noviembre 2024
-- Description:	Trae respuestas de Rating.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_ENCUESTA_TRAE_RATING]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_ENCUESTA_TRAE_RATING]
GO

CREATE PROCEDURE [dbo].[PA_ENCUESTA_TRAE_RATING]
AS
BEGIN TRY

	DECLARE @primerDiaAnno AS DATE = DATEFROMPARTS(YEAR(GETDATE()), 1, 1);
	DECLARE @hoyEnDia AS DATE = CAST(GETDATE() AS DATE);

	DECLARE @tablaTemporalRating AS TABLE (
		pregunta VARCHAR(255),
		valor INT,
		conteo INT
	);

	INSERT INTO @tablaTemporalRating
	SELECT
		pregunta,
		valor,
		count(idReporte)
	FROM
		SICORE_ENCUESTA_REPORTE
	WHERE
		tipoPregunta = 'E'
	AND
		CAST(fechaHoraRespuesta AS DATE) BETWEEN @primerDiaAnno AND @hoyEnDia
	GROUP BY
		pregunta,
		valor

	SELECT DISTINCT
		rating.conteo,
		rating.pregunta,
		respuesta.respuestaOpcion respuesta
	FROM
		@tablaTemporalRating rating
	INNER JOIN
		SICORE_ENCUESTA_RESPUESTA respuesta on rating.valor = respuesta.valorRespuesta
		
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE();
END CATCH