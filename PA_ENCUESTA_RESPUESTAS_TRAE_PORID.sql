use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Noviembre 2024
-- Description:	Trae las respuestas de una pregunta filtrado por ID de la pregunta.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_ENCUESTA_RESPUESTAS_TRAE_PORID]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_ENCUESTA_RESPUESTAS_TRAE_PORID]
GO

CREATE PROCEDURE [dbo].[PA_ENCUESTA_RESPUESTAS_TRAE_PORID] (@pIdPregunta as int)
AS
BEGIN TRY
	BEGIN TRAN
		
		select
			respuestas.idRespuesta,
			respuestas.idPregunta,
			pregunta.pregunta,
			pregunta.tipoPregunta,
			respuestas.respuestaOpcion respuesta,
			respuestas.valorRespuesta
		from
			SICORE_ENCUESTA_RESPUESTA respuestas
		inner join
			SICORE_ENCUESTA_PREGUNTA pregunta on respuestas.idPregunta = pregunta.idPregunta
		where
			respuestas.idPregunta = @pIdPregunta

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK
END CATCH