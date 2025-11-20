USE [SICORE]
GO

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_ENVIAR_NOTIFICACION_COTIZACION]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_ENVIAR_NOTIFICACION_COTIZACION]
GO

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Mayo 2025
-- Description:	Pone en cola una nueva cotización para ser aprobada.
-- Modificación: Junio 2025
-- =============================================

CREATE PROCEDURE [dbo].[PA_ENVIAR_NOTIFICACION_COTIZACION] (@numeroCotizacion as varchar(255), @idFuncionario bigint)
AS
BEGIN TRY
	BEGIN TRAN

		declare @idUsuarioJefeDP int = (select idUsuario from SICORE_USUARIO where idPerfil = 6);
		declare @jefaturaDP varchar(255) = (select usuario from SCGI..SIST_USUARIO where idUsuario = @idUsuarioJefeDP);

		declare @idUsuarioJefeDM int = (select idUsuario from SICORE_USUARIO where idPerfil = 7);
		declare @jefaturaDM varchar(255) = (select usuario from SCGI..SIST_USUARIO where idUsuario = @idUsuarioJefeDM);

		declare @destinatario varchar(150) = @jefaturaDM + ';' + @jefaturaDP;
		declare @asunto varchar(150) = 'Solicitud de Aprobación';
		declare @idPersona int = (select idPersona from SCGI..SIST_USUARIO where idUsuario = @idFuncionario);
		declare @nombreFuncionario varchar(250) = (select
														dbo.FN_GET_CAMEL_CASE(nombre) + ' ' +
														dbo.FN_GET_CAMEL_CASE(primerApellido) + ' ' +
														dbo.FN_GET_CAMEL_CASE(segundoApellido) funcionario
													from
														SCGI..SIST_PERSONA
													where
														idPersona = @idPersona);

		declare @cuerpoCorreo nvarchar(max) = '<div style="font-family: Arial, sans-serif; margin: 0; padding: 0; background-color: #f4f4f4;"><div style="max-width: 600px; margin: 0 auto; padding: 0px 20px 20px; background-color: #ffffff; box-shadow: 0px 4px 6px #ccc;"><div style="display: flex; align-items: center;"><h2 style="color: #333; margin:38px 0 20px 0;font-size:18px">APROBACIÓN DE COTIZACIÓN</h2></div><br><p style="color: #666; font-weight:bold">La cotización N° ' + @numeroCotizacion + ' elaborada por el funcionario ' + @nombreFuncionario + ', está lista para su revisión.</p></div></div>';

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