USE [SICORE]
GO

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_ENVIAR_FORMALIZACION]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_ENVIAR_FORMALIZACION]
GO

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Diciembre 2024
-- Description:	Pone en cola una nueva formalización para ser enviada.
-- Modificación: Junio 2025
-- =============================================

CREATE PROCEDURE [dbo].[PA_ENVIAR_FORMALIZACION] (@pFormalizacion as nvarchar(max))
AS
BEGIN TRY
	BEGIN TRAN

		declare @numeroFormalizacion varchar(100) = (select numeroFormalizacion from openjson(@pFormalizacion) with (numeroFormalizacion varchar(150)));
		declare @asunto varchar(150) = (select asunto from openjson(@pFormalizacion) with (asunto varchar(150)));
		declare @idFuncionario bigint = (select idFuncionario from openjson(@pFormalizacion) with (idFuncionario bigint));
		declare @destinatario nvarchar(max) = dbo.FN_GET_EMAILS_FINANCIERO();

		declare @cuerpoCorreo nvarchar(max) = '<div style="font-family: Arial, sans-serif; margin: 0; padding: 0; background-color: #f4f4f4;"><div style="max-width: 600px; margin: 0 auto; padding: 0px 20px 20px; background-color: #ffffff; box-shadow: 0px 4px 6px #ccc;"><div style="display: flex; align-items: center;"><h2 style="color: #333; margin:38px 0 20px 0;font-size:18px">FORMALIZACIÓN</h2></div><br><p style="color: #666; font-weight:bold">La formalización N° ' + @numeroFormalizacion + ' está lista para su revisión financiera.</p></div></div>';

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

		declare @idUsuarioAsistente int = (select idUsuario from SICORE_USUARIO where idPerfil = 4);
		declare @asistenteDDC varchar(150) = (select usuario from SCGI.dbo.SIST_USUARIO where idUsuario = @idUsuarioAsistente);
		declare @destinatarioDDC varchar(150) = (select usuario from SCGI.dbo.SIST_USUARIO where idUsuario = @idFuncionario);

		set @destinatarioDDC = @destinatarioDDC + ';' + @asistenteDDC;
		set @asunto = @asunto + ' - copia -'

		insert into SCGI..SIST_COLA_ENVIO_CORREO
		values
		(
			CURRENT_TIMESTAMP,
			CURRENT_TIMESTAMP,
			@destinatarioDDC,
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