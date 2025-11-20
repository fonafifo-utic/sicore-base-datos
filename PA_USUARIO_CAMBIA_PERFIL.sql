use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Agosto 2024
-- Description:	Toma un objeto JSON, extrae el id de usuario y el id del perfil y edita el usuario.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_USUARIO_CAMBIA_PERFIL]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_USUARIO_CAMBIA_PERFIL]
GO

CREATE PROCEDURE [dbo].[PA_USUARIO_CAMBIA_PERFIL] (@pUsuario as nvarchar(max))
AS
BEGIN TRY
	BEGIN TRANSACTION

		set @pUsuario = replace(@pUsuario, '{ pUsuario = "{', '{');
		set @pUsuario = replace(@pUsuario, '" }', '');

		declare @idUsuario bigint = (select idUsuario from openjson(@pUsuario) with (idUsuario bigint '$.idUsuario'));
		declare @idPerfil bigint = (select idPerfil from openjson(@pUsuario) with (idPerfil bigint '$.idPerfil'));

		update SICORE_USUARIO
		set
			idPerfil = @idPerfil
		where
			idUsuario = @idUsuario;

		select 1 as resultado

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK

	select ERROR_MESSAGE() as resultado
END CATCH