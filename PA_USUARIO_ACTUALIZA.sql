USE [SICORE]
GO

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Julio 2024
-- Description:	Toma un JSON como parámetro y actualiza un registro dentro de la tabla Usuarios.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_USUARIO_ACTUALIZA]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_USUARIO_ACTUALIZA]
GO

CREATE PROCEDURE [dbo].[PA_USUARIO_ACTUALIZA] (@pUsuario nvarchar(max))
AS
BEGIN TRY
	BEGIN TRANSACTION
	
	SET NOCOUNT ON;

		set @pUsuario = replace(@pUsuario, '{ pUsuario = "{', '{');
		set @pUsuario = replace(@pUsuario, '" }', '');

		declare @correo varchar(150) = (select correo from openjson (@pUsuario) with (correo varchar(150) '$.correo'));
		declare @telefonoMovil varchar(8) = (select telefonoMovil from openjson (@pUsuario) with (telefonoMovil varchar(8) '$.telefonoMovil'));
		declare @idPersona bigint = (select idUsuario from openjson (@pUsuario) with (idUsuario bigint '$.idUsuario'));

		Update
			SICORE_PERSONA
		Set
			correo = @correo,
			telefonoMovil = @telefonoMovil
		Where
			idPersona = @idPersona

		Select 1 as result
	   
	SET NOCOUNT OFF;

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK

	select ERROR_MESSAGE() as resultado
END CATCH