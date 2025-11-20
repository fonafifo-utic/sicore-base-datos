use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Septiembre 2025
-- Description:	Trae usuarios de SICORE del DDC.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_CLIENTE_TRAE_FUNCIONARIOS]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_CLIENTE_TRAE_FUNCIONARIOS]
GO

CREATE PROCEDURE [dbo].[PA_CLIENTE_TRAE_FUNCIONARIOS]
AS
BEGIN TRY
	BEGIN TRAN

		SELECT
			sicore.idUsuario											AS idUsuario,
			[dbo].[FN_GET_CAMEL_CASE](persona.nombre) +' '+
			[dbo].[FN_GET_CAMEL_CASE](persona.primerApellido) +' '+
			[dbo].[FN_GET_CAMEL_CASE](persona.segundoApellido)			AS nombre,
			usuarios.usuario											AS email,
			ISNULL(persona.telefonoFijoTrabajo, '')						AS telefono
		FROM
			SICORE_USUARIO sicore
		INNER JOIN
			SCGI..SIST_USUARIO usuarios ON sicore.idUsuario = usuarios.idUsuario
		INNER JOIN
			SCGI..SIST_PERSONA persona ON usuarios.idPersona = persona.idPersona
		WHERE
			sicore.idPerfil = 2
		AND
			sicore.idUsuario != 77629
		UNION
		SELECT
			0, '- Todos -', '', ''
		ORDER BY
			sicore.idUsuario DESC

	COMMIT
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE()
	ROLLBACK
END CATCH