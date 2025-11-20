use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Noviembre 2024
-- Description:	Trae los registros de la tabla Preguntas filtrados por ID de pregunta.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_ENCUESTA_PREGUNTAS_TRAE_PORID]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_ENCUESTA_PREGUNTAS_TRAE_PORID]
GO

CREATE PROCEDURE [dbo].[PA_ENCUESTA_PREGUNTAS_TRAE_PORID] (@pIdPregunta as bigint)
AS
BEGIN TRY
	BEGIN TRAN

		select
			idPregunta,
			pregunta,
			case
				when tipoPregunta = 'S' then
					'Selección'
				when tipoPregunta = 'E' then
					'Escala'
				when tipoPregunta = 'A' then
					'Abierta'
			end tipo,
			case
				when indicadorEstado = 'A' then
					'Activo'
				when indicadorEstado = 'I' then
					'Inactivo'
			end estado
		from
			SICORE_ENCUESTA_PREGUNTA
		where
			idPregunta = @pIdPregunta

	COMMIT
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE()
	ROLLBACK TRANSACTION TPROCESO
END CATCH