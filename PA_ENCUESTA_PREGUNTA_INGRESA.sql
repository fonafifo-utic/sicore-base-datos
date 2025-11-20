use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Noviembre 2024
-- Description:	Toma un objeto JSON para ingresar una pregunta y su respectiva respuestas.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_ENCUESTA_PREGUNTA_INGRESA]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_ENCUESTA_PREGUNTA_INGRESA]
GO

CREATE PROCEDURE [dbo].[PA_ENCUESTA_PREGUNTA_INGRESA] (@pPregunta as nvarchar(max))
AS
BEGIN TRY
	BEGIN TRAN
	
		set @pPregunta = replace(@pPregunta, '{ pPregunta = "{', '{');
		set @pPregunta = replace(@pPregunta, '" }', '');
		
		insert into SICORE_ENCUESTA_PREGUNTA
			select
				idFuncionario,
				pregunta,
				tipo,
				'A',
				getdate(),
				idFuncionario,
				null,
				null
			from
				openjson(@pPregunta)
			with
				(
					idFuncionario bigint '$.idFuncionario',
					pregunta varchar(255) '$.pregunta',
					tipo char(1) '$.tipo'
				)

		declare @tipo as char(1) = (select tipo from openjson (@pPregunta) with (tipo char(1) '$.tipo'));

		if(@tipo != 'A')
		begin

			declare @idPregunta as int = (select top 1 idPregunta from SICORE_ENCUESTA_PREGUNTA order by idPregunta desc);
			declare @idFuncionario as int = (select idFuncionario from openjson (@pPregunta) with (idFuncionario int '$.idFuncionario'));
			declare @respuestas as nvarchar(max) = (select respuestas from openjson(@pPregunta) with (respuestas nvarchar(max) '$.respuestas' as json));

			insert into SICORE_ENCUESTA_RESPUESTA
				select
					@idPregunta,
					respuesta,
					valorPeso,
					getdate(),
					@idFuncionario,
					null,
					null
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