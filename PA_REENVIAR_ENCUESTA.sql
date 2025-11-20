USE [SICORE]
GO

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_REENVIAR_ENCUESTA]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_REENVIAR_ENCUESTA]
GO

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Abril 2025
-- Description:	Pone en cola de nuevo una encuesta para ser enviada.
-- =============================================

CREATE PROCEDURE [dbo].[PA_REENVIAR_ENCUESTA] (@pOpcionesEnvio as nvarchar(max))
AS
BEGIN TRY
	BEGIN TRAN

		set @pOpcionesEnvio = replace(@pOpcionesEnvio, '{ pOpcionesEnvio = "{', '{');
		set @pOpcionesEnvio = replace(@pOpcionesEnvio, '" }', '');

		declare @idFuncionario bigint = (select idFuncionario from openjson(@pOpcionesEnvio) with (idFuncionario bigint));
		declare @idCotizacion bigint = (select idCotizacion from openjson(@pOpcionesEnvio) with (idCotizacion bigint));
		declare @asunto varchar(150) = (select asunto from openjson(@pOpcionesEnvio) with (asunto varchar(150)));
		declare @destinatario varchar(150) = (select destinatario from openjson(@pOpcionesEnvio) with (destinatario varchar(max)));
		declare @enlaceEncuesta varchar(150) = (select enlace from openjson(@pOpcionesEnvio) with (enlace varchar(150)));
		declare @numeroCertificado int = (select numeroCertificado from openjson(@pOpcionesEnvio) with (numeroCertificado int));

		declare @cuerpoCorreo nvarchar(max) = '<div style="font-family: Arial, sans-serif; margin: 0; padding: 0; background-color: #f4f4f4;">
		<div style="max-width: 600px; margin: 0 auto; padding: 0px 20px 20px; background-color: #ffffff; box-shadow: 0px 4px 6px #ccc;">
		<div style="display: flex; align-items: center;">
		<img src="http://sipsa.fonafifo.com/PPSA/Imagenes/Banners/Logo-Banco-Color.jpg" width="20%" height="auto" style="margin-right: 20px;">
		<h2 style="color: #333; margin:38px 0 20px 0;font-size:18px">Departamento de Desarrollo y Comercialización</h2>
		</div><p style="color: #666;">Adentro encontrará un enlace con una encuesta que nos ayuda a mejorar gracias a su colaboración: <a href="' + @enlaceEncuesta + '">Encuesta Satisfacción</a></p>
		<hr><p style="color: #666;">Nota: Este es un mensaje generado automáticamente por el sistema SICORE. No responda ni escriba a esta dirección de correo.</p></div></div>';

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

		declare @idCliente int = (select idCliente from SICORE_COTIZACION where idCotizacion = @idCotizacion);
		declare @idCertificado int = (select certificado.idCertificado from SICORE_COTIZACION cotizacion inner join SICORE_CERTIFICADO certificado on cotizacion.idCotizacion = certificado.idCotizacion where cotizacion.idCotizacion = @idCotizacion);
		declare @conteoEnvio int = (select conteoEnvios from SICORE_ENCUESTA_TRAZA where idCliente = @idCliente and idCertificado = @idCertificado);

		set @conteoEnvio += 1;

		insert into SICORE_ENCUESTA_TRAZA
		select
			cotizacion.idCliente,
			certificado.idCertificado,
			@idFuncionario,
			getdate(),
			null,
			@conteoEnvio
		from
			SICORE_COTIZACION cotizacion
		inner join
			SICORE_CERTIFICADO certificado on cotizacion.idCotizacion = certificado.idCotizacion
		where
			cotizacion.idCotizacion = @idCotizacion

		select 1 as resultado
	
	COMMIT
END TRY
BEGIN CATCH
		Select ERROR_MESSAGE() as resultado
END CATCH