use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Abril 2025
-- Description:	Trae todos los posibles directores ejecutivos.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_PERSONALIZACION_TRAE_DIRECTORES]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_PERSONALIZACION_TRAE_DIRECTORES]
GO

CREATE PROCEDURE [dbo].[PA_PERSONALIZACION_TRAE_DIRECTORES]
AS
BEGIN TRY
	BEGIN TRAN

		select
			dbo.FN_GET_CAMEL_CASE(nombre) + ' ' +
			dbo.FN_GET_CAMEL_CASE(primerApellido) + ' ' +
			dbo.FN_GET_CAMEL_CASE(segundoApellido) director
		from
			SCGI..SIST_PERSONA
		where
			idPersona in (519284, 2300980, 565998, 555239, 675850)

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK

	select ERROR_MESSAGE() as resultado
END CATCH