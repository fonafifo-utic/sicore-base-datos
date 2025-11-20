USE [SICORE]
GO

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_ENVIAR_CERTIFICADO_YAFUE_FIRMADO]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_ENVIAR_CERTIFICADO_YAFUE_FIRMADO]
GO

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Febrero 2025
-- Description:	Pone en cola la notificación de que un certificado fue firmado.
-- =============================================

CREATE PROCEDURE [dbo].[PA_ENVIAR_CERTIFICADO_YAFUE_FIRMADO] (@pFormalizacion as nvarchar(max))
AS
BEGIN TRY
	BEGIN TRAN

		set @pFormalizacion = replace(@pFormalizacion, '{ pFormalizacion = "{', '{');
		set @pFormalizacion = replace(@pFormalizacion, '" }', '');

		declare @nuevoCertificado varchar(100) = (select numeroFormalizacion from openjson(@pFormalizacion) with (numeroFormalizacion varchar(150)));
		declare @asunto varchar(150) = (select asunto from openjson(@pFormalizacion) with (asunto varchar(150)));
		declare @idCertificado bigint = (select idCertificado from openjson(@pFormalizacion) with (idCertificado bigint '$.destinatario'));
		declare @idCotizacion bigint = (select idCotizacion from SICORE_CERTIFICADO where idCertificado = @idCertificado);
		declare @idFuncionarioCreoCotizacion bigint = (select idFuncionario from SICORE_COTIZACION where idCotizacion = @idCotizacion);
		declare @emailFuncionario varchar(150) = (select usuario from SCGI.[dbo].[SIST_USUARIO] where idUsuario = @idFuncionarioCreoCotizacion);
		declare @destinatario varchar(255) = 'silvia.zuniga@fonafifo.go.cr;' + @emailFuncionario;
		declare @idFuncionario bigint = (select idFuncionario from openjson(@pFormalizacion) with (idFuncionario bigint));

		declare @cuerpoCorreo nvarchar(max) = '<div style="font-family: Arial, sans-serif; margin: 0; padding: 0; background-color: #f4f4f4;">
<div style="max-width: 600px; margin: 0 auto; padding: 0px 20px 20px; background-color: #ffffff; box-shadow: 0px 4px 6px #ccc;">
<div style="display: flex; align-items: center;">
<h2 style="color: #333; margin:38px 0 20px 0;font-size:18px">CERTIFICADO FIRMADO</h2>
</div><br><p style="color: #666; font-weight:bold">El certificado de la cotización ' + @nuevoCertificado + ', ya fue firmado digitalmente y está listo ser enviado.</p>
<br><hr><p style="color: #666;">Nota: Este es un mensaje generado automáticamente por el sistema SICORE. No responda ni escriba a esta dirección de correo</p></div></div>';

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