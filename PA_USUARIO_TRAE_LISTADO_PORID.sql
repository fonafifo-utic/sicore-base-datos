use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Julio 2024
-- Description:	Recupera un usuario por id de usuario del sistema SICORE.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_USUARIO_TRAE_LISTADO_PORID]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_USUARIO_TRAE_LISTADO_PORID]
GO

CREATE PROCEDURE [dbo].[PA_USUARIO_TRAE_LISTADO_PORID] (@pIdUsuario bigint)
AS
BEGIN TRY
	BEGIN TRANSACTION
		
		select
			sp.nombre + ' ' + sp.primerApellido + ' ' + sp.segundoApellido nombre,
			sp.correo,
			sp.telefonoMovil,
			su.idPerfil
		from
			SICORE_PERSONA sp
		inner join
			SICORE_USUARIO su on sp.idPersona = su.idPersona
		where
			sp.idPersona = @pIdUsuario

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK
END CATCH
