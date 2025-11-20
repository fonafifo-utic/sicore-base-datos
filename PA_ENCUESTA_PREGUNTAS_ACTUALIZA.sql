use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Agosto 2024
-- Description:	Toma un objeto JSON para actualizar la tabla Preguntas y Respuestas.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_ENCUESTA_PREGUNTAS_ACTUALIZA]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_ENCUESTA_PREGUNTAS_ACTUALIZA]
GO

CREATE PROCEDURE [dbo].[PA_ENCUESTA_PREGUNTAS_ACTUALIZA] (@pPregunta as nvarchar(max))
AS
BEGIN TRY
	BEGIN TRAN

		set @pPregunta = replace(@pPregunta, '{ pPregunta = "{', '{');
		set @pPregunta = replace(@pPregunta, '" }', '');

		declare @idPregunta as int = (select idPregunta from openjson (@pPregunta) with (idPregunta int '$.idPregunta'));
		declare @idFuncionario int = (select idFuncionario from openjson (@pPregunta) with (idFuncionario int '$.idFuncionario'));
		declare @pregunta varchar(255) = (select pregunta from openjson (@pPregunta) with (pregunta varchar(255) '$.pregunta'));
		declare @tipo char(1) = (select tipo from openjson (@pPregunta) with (tipo char(1) '$.tipo'));
		declare @respuestas as nvarchar(max) = (select respuestas from openjson(@pPregunta) with (respuestas nvarchar(max) '$.respuestas' as json));

		update SICORE_ENCUESTA_PREGUNTA
		set
			pregunta = @pregunta,
			tipoPregunta = @tipo,
			fechaModificoAuditoria = getdate(),
			idUsuarioModificoAuditoria = @idFuncionario
		where
			idPregunta = @idPregunta

		if(@tipo != 'A')
		begin

			delete from SICORE_ENCUESTA_RESPUESTA
			where idPregunta = @idPregunta;

			insert into SICORE_ENCUESTA_RESPUESTA
				select
					@idPregunta,
					respuesta,
					valorPeso,
					getdate(),
					@idFuncionario,
					getdate(),
					@idFuncionario
				from
					openjson (@respuestas) with
					(
						respuesta varchar(250) '$.respuesta',
						valorPeso int '$.valorPeso'
					)

		end

		select 1 as resultado

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK

	select ERROR_MESSAGE() as resultado
END CATCH