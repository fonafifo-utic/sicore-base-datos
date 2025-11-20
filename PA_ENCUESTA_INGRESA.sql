use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Noviembre 2024
-- Description:	Toma un objeto JSON para ingresar una encuesta.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_ENCUESTA_INGRESA]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_ENCUESTA_INGRESA]
GO

CREATE PROCEDURE [dbo].[PA_ENCUESTA_INGRESA] (@pEncuesta as nvarchar(max))
AS
BEGIN TRY
	BEGIN TRAN
	
		set @pEncuesta = replace(@pEncuesta, '{ pEncuesta = "{', '{');
		set @pEncuesta = replace(@pEncuesta, '" }', '');
		
		truncate table SICORE_ENCUESTA;
		
		insert into SICORE_ENCUESTA
			select
				idPregunta,
				getdate(),
				idFuncionario,
				null,
				null
			from
				openjson(@pEncuesta)
			with
				(
					idPregunta bigint '$.idPregunta',
					idFuncionario bigint '$.idFuncionario'
				)

		select 1 as resultado

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK

	select ERROR_MESSAGE() as resultado
END CATCH