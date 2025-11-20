USE [SICORE]
GO

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_ENVIAR_NOTIFICACION_PARA_DDC]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_ENVIAR_NOTIFICACION_PARA_DDC]
GO

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Marzo 2025
-- Description:	Pone en cola una notificación para ser revisada por DDC.
-- =============================================

CREATE PROCEDURE [dbo].[PA_ENVIAR_NOTIFICACION_PARA_DDC] (@pFormalizacion as nvarchar(max))
AS
BEGIN TRY
	BEGIN TRAN

		declare @asunto varchar(150) = (select asunto from openjson(@pFormalizacion) with (asunto varchar(150)));
		declare @numeroCotizacion varchar(100) = (select numeroFormalizacion from openjson(@pFormalizacion) with (numeroFormalizacion varchar(150) '$.numeroFormalizacion'));
		declare @consecutivo int = (select destinatario from openjson(@pFormalizacion) with (destinatario int '$.destinatario'));
		declare @idFuncionario bigint = (select idFuncionario from openjson(@pFormalizacion) with (idFuncionario bigint));
		declare @idFuncionarioCreoCotizacion bigint = (select idFuncionario from SICORE_COTIZACION where consecutivo = @consecutivo);
		declare @emailFuncionario varchar(max) = (select 'silvia.zuniga@fonafifo.go.cr;' + usuario from SCGI.[dbo].[SIST_USUARIO] where idUsuario = @idFuncionarioCreoCotizacion);

		declare @cuerpoCorreo nvarchar(max) = '<div style="font-family: Arial, sans-serif; margin: 0; padding: 0; background-color: #f4f4f4;">
		<div style="max-width: 600px; margin: 0 auto; padding: 0px 20px 20px; background-color: #ffffff; box-shadow: 0px 4px 6px #ccc;">
		<div style="display: flex; align-items: center;">
		<h2 style="color: #333; margin:38px 0 20px 0;font-size:18px">FORMALIZACIÓN</h2>
		</div><br><p style="color: #666; font-weight:bold">La cotizacion N° ' + @numeroCotizacion + ' está pendiente de pago por crédito.</p>
		<br><hr><p style="color: #666;">Nota: Este es un mensaje generado automáticamente por el sistema SICORE. No responda ni escriba a esta dirección de correo</p></div></div>'

		set @cuerpoCorreo = trim(@cuerpoCorreo);

		insert into SCGI..SIST_COLA_ENVIO_CORREO
		values
		(
			CURRENT_TIMESTAMP,
			CURRENT_TIMESTAMP,
			@emailFuncionario,
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