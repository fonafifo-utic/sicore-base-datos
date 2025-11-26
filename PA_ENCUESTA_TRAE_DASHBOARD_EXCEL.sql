USE [SICORE]
GO

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Noviembre 2025
-- Description:	Trae las respuestas contestadas para exponerlas en un Excel.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_ENCUESTA_TRAE_DASHBOARD_EXCEL]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_ENCUESTA_TRAE_DASHBOARD_EXCEL]
GO

CREATE PROCEDURE [dbo].[PA_ENCUESTA_TRAE_DASHBOARD_EXCEL]
AS
BEGIN TRY
	
	DECLARE @primerDiaAnno DATE = (DATEFROMPARTS(YEAR(GETDATE()), 1, 1));
	DECLARE @hoy DATE = (CAST(GETDATE() AS DATE));

	DECLARE @tablaTemporalRating AS TABLE (
		pregunta	VARCHAR(255),
		valor		INT,
		conteo		INT
	);

	DECLARE @reporte AS TABLE (
		pregunta	VARCHAR(255),
		contestaron	INT,
		respuesta	VARCHAR(255)
	);

	INSERT INTO @tablaTemporalRating
	SELECT
		pregunta,
		valor,
		COUNT(idReporte)
	FROM
		SICORE_ENCUESTA_REPORTE
	WHERE
		tipoPregunta = 'E'
	AND
		CAST(fechaHoraRespuesta AS DATE) BETWEEN @primerDiaAnno AND @hoy
	GROUP BY
		pregunta,
		valor;

	INSERT INTO @reporte
	SELECT DISTINCT
		rating.pregunta				AS [pregunta],
		rating.conteo				AS [contestaron],
		respuesta.respuestaOpcion	AS [respuesta]
	FROM
		@tablaTemporalRating rating
	INNER JOIN
		SICORE_ENCUESTA_RESPUESTA respuesta ON rating.valor = respuesta.valorRespuesta
	UNION
	SELECT
		pregunta			AS [pregunta],
		COUNT(idReporte)	AS [contestaron],
		respuesta			AS [respuesta]
	FROM
		SICORE_ENCUESTA_REPORTE
	WHERE
		tipoPregunta = 'S'
	AND
		CAST(fechaHoraRespuesta AS DATE) BETWEEN @primerDiaAnno AND @hoy
	GROUP BY
		pregunta,
		respuesta;

	SELECT
		pregunta,
		contestaron,
		respuesta
	FROM
		@reporte
	ORDER BY
		contestaron ASC
	
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE();
END CATCH

