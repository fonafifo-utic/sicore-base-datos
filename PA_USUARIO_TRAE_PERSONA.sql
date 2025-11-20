use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Julio 2024
-- Description:	Recupera un listado de personas desde el padrón electoral.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_USUARIO_TRAE_PERSONA]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_USUARIO_TRAE_PERSONA]
GO

CREATE PROCEDURE [dbo].[PA_USUARIO_TRAE_PERSONA] (@pDocumentoId varchar(10))
AS
BEGIN TRY
	BEGIN TRANSACTION

		select
			persona.nombre + ' ' + persona.primerApellido + ' ' + persona.segundoApellido as nombre,
			usuario.usuario correo,
			persona.telefonoMovil telefonoMovil
		from
			[SCGI].[dbo].[SIST_PERSONA] persona
		inner join
			[SCGI].[dbo].[SIST_USUARIO] usuario on persona.idPersona = usuario.idPersona
		where
			documentoID = @pDocumentoId

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK
END CATCH
