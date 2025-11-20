use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Noviembre 2024
-- Description:	Trae encuesta conformada.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_ENCUESTA_LISTA_TRAE]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_ENCUESTA_LISTA_TRAE]
GO

CREATE PROCEDURE [dbo].[PA_ENCUESTA_LISTA_TRAE]
AS
BEGIN TRY
	BEGIN TRAN

		select
			encuesta.idEncuesta,
			encuesta.idPregunta,
			pregunta.pregunta,
			pregunta.tipoPregunta
		from
			SICORE_ENCUESTA encuesta
		inner join
			SICORE_ENCUESTA_PREGUNTA pregunta on encuesta.idPregunta = pregunta.idPregunta
		
	COMMIT
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE();

	ROLLBACK TRAN
END CATCH