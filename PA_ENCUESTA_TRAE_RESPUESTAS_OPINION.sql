USE [SICORE]
GO

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Noviembre 2025
-- Description:	Trae respuestas de opinión de la encuesta.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_ENCUESTA_TRAE_RESPUESTAS_OPINION]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_ENCUESTA_TRAE_RESPUESTAS_OPINION]
GO

CREATE PROCEDURE [dbo].[PA_ENCUESTA_TRAE_RESPUESTAS_OPINION] (@fechaInicio AS DATE, @fechaFin AS DATE)
AS
BEGIN TRY
	
	SELECT
		reporte.pregunta										AS pregunta,
		reporte.respuesta										AS respuesta,
		reporte.fechaHoraRespuesta								AS fecha,
		dbo.FN_GET_CAMEL_CASE(cliente.nombreCliente)			AS cliente,
		dbo.FN_GET_CAMEL_CASE(persona.nombre) + ' ' +
		dbo.FN_GET_CAMEL_CASE(persona.primerApellido) + ' ' +	
		dbo.FN_GET_CAMEL_CASE(persona.segundoApellido)			AS agente
	FROM
		SICORE_ENCUESTA_REPORTE reporte
	INNER JOIN
		SICORE_CLIENTE cliente ON reporte.idCliente = cliente.idCliente
	INNER JOIN
		SCGI..SIST_USUARIO usuarios ON cliente.idAgenteCuenta = usuarios.idUsuario
	INNER JOIN
		SCGI..SIST_PERSONA persona ON usuarios.idPersona = persona.idPersona
	WHERE
		tipoPregunta = 'A'
	AND
		respuesta != ''
	AND
		CAST(fechaHoraRespuesta AS DATE) BETWEEN @fechaInicio AND @fechaFin
	ORDER BY
		fechaHoraRespuesta DESC;

END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE();
END CATCH