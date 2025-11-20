use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Julio 2024
-- Description:	Toma un objeto JSON, extrae el id de usuario y lo elimina de la tabla.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_USUARIO_CAMBIA_ESTADO]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_USUARIO_CAMBIA_ESTADO]
GO

CREATE PROCEDURE [dbo].[PA_USUARIO_CAMBIA_ESTADO] (@pUsuario as nvarchar(max))
AS
BEGIN TRY
	BEGIN TRANSACTION

		set @pUsuario = replace(@pUsuario, '{ pUsuario = "{', '{');
		set @pUsuario = replace(@pUsuario, '" }', '');

		declare @idUsuario bigint = (select idUsuario from openjson(@pUsuario) with (idUsuario bigint '$.idUsuario'));

		delete from SICORE_USUARIO
		where idUsuario = @idUsuario

		select 1 as resultado

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK

	select ERROR_MESSAGE() as resultado
END CATCH