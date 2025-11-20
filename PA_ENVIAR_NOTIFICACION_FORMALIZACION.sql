USE [SICORE]
GO

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_ENVIAR_NOTIFICACION_FORMALIZACION]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_ENVIAR_NOTIFICACION_FORMALIZACION]
GO

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Mayo 2025
-- Description:	Pone en cola una nueva cotización para ser aprobada.
-- =============================================

CREATE PROCEDURE [dbo].[PA_ENVIAR_NOTIFICACION_FORMALIZACION] (@numeroFormalizacion as varchar(255), @idFuncionario bigint)
AS
BEGIN TRY
	BEGIN TRAN

		declare @idJefeFinanciero int = (select idUsuario from SICORE_USUARIO where idPerfil = 8);
		declare @idJefePresupuesto int = (select idUsuario from SICORE_USUARIO where idPerfil = 10);

		declare @emailJefeFinanciero varchar(150) = (select usuario from SCGI.dbo.SIST_USUARIO where idUsuario = @idJefeFinanciero);
		declare @emailJefePresupuesto varchar(150) = (select usuario from SCGI.dbo.SIST_USUARIO where idUsuario = @idJefePresupuesto);
		
		declare @destinatario varchar(max) = @emailJefeFinanciero + ';' + @emailJefePresupuesto;
		
		declare @asunto varchar(150) = 'Solicitud de Aprobación';
		declare @cuerpoCorreo nvarchar(max) = '<div style="font-family: Arial, sans-serif; margin: 0; padding: 0; background-color: #f4f4f4;"><div style="max-width: 600px; margin: 0 auto; padding: 0px 20px 20px; background-color: #ffffff; box-shadow: 0px 4px 6px #ccc;"><div style="display: flex; align-items: center;"><h2 style="color: #333; margin:38px 0 20px 0;font-size:18px">Solicitud de Aprobación</h2></div><br><p style="color: #666; font-weight:bold">La formalización de la cotización N° ' + @numeroFormalizacion + ' está lista para su revisión.</p></div></div>';

		set @cuerpoCorreo = trim(@cuerpoCorreo);

		insert into SCGI..SIST_COLA_ENVIO_CORREO
		values
		(
			CURRENT_TIMESTAMP,
			CURRENT_TIMESTAMP,
			@destinatario,
			'P',
			'0',
			@asunto,
			@cuerpoCorreo,
			'1',
			CURRENT_TIMESTAMP,
			@idFuncionario,
			CURRENT_TIMESTAMP,
			@idFuncionario
		);

		select 1 as resultado

	COMMIT
END TRY
BEGIN CATCH
		Select ERROR_MESSAGE() as resultado
END CATCH