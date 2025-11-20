use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Noviembre 2024
-- Description:	Trae encuesta conformada.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_ENCUESTA_TRAE]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_ENCUESTA_TRAE]
GO

CREATE PROCEDURE [dbo].[PA_ENCUESTA_TRAE]
AS
BEGIN TRY
	BEGIN TRAN

		select
			pregunta.idPregunta,
			respuesta.idRespuesta,
			pregunta.tipoPregunta,
			pregunta.pregunta,
			respuesta.respuestaOpcion,
			respuesta.valorRespuesta
		from
			SICORE_ENCUESTA encuesta
		inner join
			SICORE_ENCUESTA_PREGUNTA pregunta on encuesta.idPregunta = pregunta.idPregunta
		left outer join
			SICORE_ENCUESTA_RESPUESTA respuesta on pregunta.idPregunta = respuesta.idPregunta
		order by
			encuesta.idEncuesta
		
	COMMIT
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE();

	ROLLBACK TRAN
END CATCH