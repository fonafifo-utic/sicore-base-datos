USE [SICORE]
GO

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_ENVIAR_COTIZACION]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_ENVIAR_COTIZACION]
GO

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Septiembre 2024
-- Description:	Pone en cola la cotización para ser enviada.
-- =============================================

CREATE PROCEDURE [dbo].[PA_ENVIAR_COTIZACION] (@pOpcionesEnvio as nvarchar(max))
AS
BEGIN TRY
	BEGIN TRAN

		declare @asunto varchar(150) = (select asunto from openjson(@pOpcionesEnvio) with (asunto varchar(150)));
		declare @destinatario varchar(150) = (select destinatario from openjson(@pOpcionesEnvio) with (destinatario varchar(150)));
		declare @enlace varchar(150) = (select enlace from openjson(@pOpcionesEnvio) with (enlace varchar(150)));
		declare @numeroCotizacion varchar(150) = (select numeroCotizacion from openjson(@pOpcionesEnvio) with (numeroCotizacion varchar(150)));
		declare @idFuncionario bigint = (select idFuncionario from openjson(@pOpcionesEnvio) with (idFuncionario bigint));
		declare @idCotizacion bigint = (select idCotizacion from openjson(@pOpcionesEnvio) with (idCotizacion bigint));

		declare @cuerpoCorreo nvarchar(max) = '<div style="font-family: Arial, sans-serif; margin: 0; padding: 0; background-color: #f4f4f4;"><div style="max-width: 600px; margin: 0 auto; padding: 0px 20px 20px; background-color: #ffffff; box-shadow: 0px 4px 6px #ccc;">
		<div style="display: flex; align-items: center;"><img src="http://sipsa.fonafifo.com/PPSA/Imagenes/Banners/Logo-Banco-Color.jpg" width="20%" height="auto" style="margin-right: 20px;">
		<h2 style="color: #333; margin:38px 0 20px 0;font-size:18px">SOLICITUD DE COTIZACIÓN</h2></div><br><p style="color: #666; font-weight:bold">Cotización N°' + @numeroCotizacion + '</p><br>
		<p style="color: #666;">Adentro de este enlace encontrará la cotización solicitada: <a href="' + @enlace + '">'+ @numeroCotizacion +'</a></p><hr><p style="color: #666;">Nota: Este es un mensaje generado automáticamente por el sistema SICORE. No responda ni escriba a esta dirección de correo</p></div></div>';

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
