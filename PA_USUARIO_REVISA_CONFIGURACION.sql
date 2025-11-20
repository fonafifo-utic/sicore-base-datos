use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Agosto 2025
-- Description:	Pregunta si está configurado el usuario para usar el doble factor de Microsoft.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_USUARIO_REVISA_CONFIGURACION]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_USUARIO_REVISA_CONFIGURACION]
GO

CREATE PROCEDURE [dbo].[PA_USUARIO_REVISA_CONFIGURACION] (@pIdUsuario BIGINT)
AS
BEGIN TRY
	
	SELECT 
		claveSecretaMFA
	FROM
		SCGI..SIST_USUARIO
	WHERE
		idUsuario = @pIdUsuario

END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE()
	ROLLBACK
END CATCH