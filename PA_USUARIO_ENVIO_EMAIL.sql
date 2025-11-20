USE [SICORE]
GO

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_USUARIO_ENVIO_EMAIL]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_USUARIO_ENVIO_EMAIL]
GO

-- =============================================
-- Author:		Rogelio Solano A
-- Create date: Oct 2023
-- Description:	Este PA envía el correo informativo al usuario logueado, en las acciones de recordar contraeña o actualización de contraseña. 
-- Comentario: Adaptación para SICORE, por parte de Álvaro Zamora S.
-- Fecha Adaptación: 25 jun 2024
-- =============================================
		
Create Procedure [dbo].[PA_USUARIO_ENVIO_EMAIL]
	@pAsunto varchar(150),
	@pCuerpoCorreo varchar(5000),
	@pCorreo varchar(200),
	@pIdPersonaEnvia varchar(20)
As	
Begin Try		
	Begin Tran
			declare @idPersona bigint = 0;
			declare @idUsuario bigint = 0;
			declare @escorreo as int = charindex('@', @pCorreo);

			if(@escorreo = 0)
			begin
				set @idPersona = (select idPersona from SCGI.[dbo].[SIST_PERSONA] where documentoID = @pCorreo);
				set @pCorreo = (select usuario from SCGI.[dbo].[SIST_USUARIO] where idPersona = @idPersona);
			end
			
			set @idUsuario = (select idUsuario from SCGI.[dbo].[SIST_USUARIO] where usuario = @pCorreo);

			if(exists(select 1 from SICORE_USUARIO where idUsuario = @idUsuario))
			begin
				Insert Into SCGI..SIST_COLA_ENVIO_CORREO
					Values	(
								CURRENT_TIMESTAMP,
								CURRENT_TIMESTAMP, 
								@pCorreo,
								'P',
								'0', 
								@pAsunto,
								@pCuerpoCorreo,
								'1',
								CURRENT_TIMESTAMP, 
								@idUsuario,
								CURRENT_TIMESTAMP, 
								@idUsuario
							);
				select 1;
			end
			else select -1;

	Commit
End Try
Begin Catch
	Rollback Transaction pTransacion;
	Select ERROR_MESSAGE() as result;
End Catch

