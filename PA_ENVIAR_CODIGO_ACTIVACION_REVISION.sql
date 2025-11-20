USE [SICORE]
GO

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_ENVIAR_CODIGO_ACTIVACION_REVISION]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_ENVIAR_CODIGO_ACTIVACION_REVISION]
GO

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Mayo 2025
-- Description:	Pone en cola un número de verificación para activar la revisión financiera.
-- =============================================

CREATE PROCEDURE [dbo].[PA_ENVIAR_CODIGO_ACTIVACION_REVISION] (@pOpcionesEnvio as nvarchar(max))
AS
BEGIN TRY
	BEGIN TRAN

		declare @numeroFormalizacion varchar(150) = (select numeroFormalizacion from openjson(@pOpcionesEnvio) with (numeroFormalizacion varchar(150) '$.numeroFormalizacion'));
		declare @asunto varchar(150) = (select asunto from openjson(@pOpcionesEnvio) with (asunto varchar(150) '$.asunto'));
		declare @destinatario varchar(150) = (select destinatario from openjson(@pOpcionesEnvio) with (destinatario varchar(150) '$.destinatario'));
		declare @idFuncionario int = (select idFuncionario from openjson(@pOpcionesEnvio) with (idFuncionario int '$.idFuncionario'));
		declare @codigoValidacion varchar(150) = (select codigoValidacion from openjson(@pOpcionesEnvio) with (codigoValidacion varchar(150) '$.codigoValidacion'));
		declare @enlace varchar(150) = 'http://localhost:4200/#/activar-formalizacion/' + @numeroFormalizacion;
		
		declare @cuerpoCorreo nvarchar(max) ='<div style="font-family: Arial, sans-serif; margin: 0; padding: 0; background-color: #f4f4f4;"><div style="max-width: 600px; margin: 0 auto; padding: 0px 20px 20px; background-color: #ffffff; box-shadow: 0px 4px 6px #ccc;"><div style="display: flex; align-items: center;"><img src="http://sipsa.fonafifo.com/PPSA/Imagenes/Banners/Logo-Banco-Color.jpg" width="20%" height="auto" style="margin-right: 20px;"><h2 style="color: #333; margin:38px 0 20px 0;font-size:18px">Notificación de SICORE</h2></div><p style="color: #666;">Se ha solicitado la activación de la Formalización de la Cotización: '+ @numeroFormalizacion +'</p><p style="color: #666;">Para aprobar esta activación por favor dar clic en: <a href="' + @enlace + '">Activar</a></p><hr></div></div>';

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
