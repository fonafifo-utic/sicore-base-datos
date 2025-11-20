USE [SICORE]
GO

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Julio 2024
-- Description:	Toma un JSON como parámetro y lo desarma para agregar un registro dentro del sistema SICORE.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_USUARIO_INGRESA]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_USUARIO_INGRESA]
GO

CREATE PROCEDURE [dbo].[PA_USUARIO_INGRESA] (@pUsuario nvarchar(max))
AS
BEGIN TRY
	BEGIN TRAN
	
		set @pUsuario = replace(@pUsuario, '{ pUsuario = "{', '{');
		set @pUsuario = replace(@pUsuario, '" }', '');

		declare @idUsuario int = (select idUsuario from openjson(@pUsuario) with (idUsuario int '$.idUsuario'));

		if(exists(select 1 from SICORE_USUARIO where idUsuario = @idUsuario))
		begin
			select 1 as resultado
		end
		else
		begin
			insert into SICORE_USUARIO
			select
				idUsuario,
				idPerfil
			from
				openjson(@pUsuario)
			with
				(
					idUsuario int '$.idUsuario',
					idPerfil int '$.idPerfil'
				)
			
			select 1 as resultado
		end

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK

	select ERROR_MESSAGE() as resultado
END CATCH