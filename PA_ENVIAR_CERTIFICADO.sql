USE [SICORE]
GO

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_ENVIAR_CERTIFICADO]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_ENVIAR_CERTIFICADO]
GO

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Diciembre 2024
-- Description:	Pone en cola una certificación para ser enviada.
-- =============================================

CREATE PROCEDURE [dbo].[PA_ENVIAR_CERTIFICADO] (@pOpcionesEnvio as nvarchar(max))
AS
BEGIN TRY
	BEGIN TRAN

		set @pOpcionesEnvio = replace(@pOpcionesEnvio, '{ pOpcionesEnvio = "{', '{');
		set @pOpcionesEnvio = replace(@pOpcionesEnvio, '" }', '');

		declare @idFuncionario bigint = (select idFuncionario from openjson(@pOpcionesEnvio) with (idFuncionario bigint '$.idFuncionario'));
		declare @idCotizacion bigint = (select idCotizacion from openjson(@pOpcionesEnvio) with (idCotizacion bigint '$.idCotizacion'));
		declare @enviaEncuesta bit = (select enviaEncuesta from openjson(@pOpcionesEnvio) with (enviaEncuesta bit '$.enviaEncuesta'));

		declare @idCertificado int = (select idCertificado from SICORE_CERTIFICADO where idCotizacion = @idCotizacion);
		declare @idProyecto int = (select idProyecto from SICORE_COTIZACION where idCotizacion = @idCotizacion);
		declare @nombreProyecto varchar(100) = (select 'Proyecto: ' + dbo.FN_GET_CAMEL_CASE(proyecto) proyecto from SICORE_PROYECTO where idProyecto = @idProyecto);

		declare @asunto varchar(150) = (select asunto from openjson(@pOpcionesEnvio) with (asunto varchar(150)));
		declare @destinatario varchar(150) = (select destinatario from openjson(@pOpcionesEnvio) with (destinatario varchar(max)));
		
		declare @enlace varchar(150) = 'http://scgi.fonafifo.com/descargaExpediente/sicore/certificados/';
		declare @enlaceProyecto varchar(150) = 'http://scgi.fonafifo.com/descargaExpediente/sicore/proyecto/';
		declare @enlaceExpediente varchar(150) = 'http://scgi.fonafifo.com/descargaExpediente/sicore/';
		
		declare @enlaceEncuesta varchar(150) = (select enlace from openjson(@pOpcionesEnvio) with (enlace varchar(150)));
		
		declare @numeroCertificado varchar(150) = (select numeroCertificado from openjson(@pOpcionesEnvio) with (numeroCertificado varchar(150)));
		
		declare @nombreCertificado varchar(150) = (select nombreArchivo from SICORE_EXPEDIENTE where idCertificado = @idCertificado and idProyecto = 0 and idCotizacion = 0 and idFormalizacion = 0);

		set @enlace = @enlace + @nombreCertificado;

		declare @proyecto varchar(150) = (select nombreArchivo from SICORE_EXPEDIENTE where idProyecto = @idProyecto and idCotizacion = 0 and idFormalizacion = 0 and idCertificado = 0);

		set @enlaceProyecto = @enlaceProyecto + @proyecto;

		declare @elementoUno varchar(150) = 'DDC-EX-PER-2025.pdf';
		declare @nombreElementoUno varchar(150) = 'Permanencia';
		declare @elementoDos varchar(150) = 'DDC-EX-DCC-2025.pdf';
		declare @nombreElementoDos varchar(150) = 'Dirección de Cambio Climático';
		
		declare @cuerpoCorreo nvarchar(max) = '<div style="font-family: Arial, sans-serif; margin: 0; padding: 0; background-color: #f4f4f4;">
	<div style="max-width: 600px; margin: 0 auto; padding: 0px 20px 20px; background-color: #ffffff; box-shadow: 0px 4px 6px #ccc;">
	<div style="display: flex; align-items: center;">
	<img src="http://sipsa.fonafifo.com/PPSA/Imagenes/Banners/Logo-Banco-Color.jpg" width="20%" height="auto" style="margin-right: 20px;">
	<h2 style="color: #333; margin:38px 0 20px 0;font-size:18px">Departamento de Desarrollo y Comercialización</h2>
	</div>
	<br>
	<p style="color: #666; font-weight:bold">Certificado N°' + @numeroCertificado + '</p>
	<br>
	<p style="color: #666;">Adentro encontrará un enlace para descargar el certificado número: <a href="' + @enlace + '">'+ @numeroCertificado +'</a></p>
	<p style="color: #666;">También en este enlace se puede descargar la información del proyecto: <a href="' + @enlaceProyecto + '">' + @nombreProyecto +'</a></p>
	<p style="color: #666;">Información adicional:</p>
	<ul>
	<li><p style="color: #666;">Elemento Uno: <a href="' + @enlaceExpediente + @elementoUno +'">'+ @nombreElementoUno +'</a></p></li>
	<li><p style="color: #666;">Elemento Dos: <a href="' + @enlaceExpediente + @elementoDos +'">'+ @nombreElementoDos +'</a></p></li>
	</ul>
	<hr>
	<p style="color: #666;">Nota: Este es un mensaje generado automáticamente por el sistema SICORE. No responda ni escriba a esta dirección de correo.</p>
	</div>
	</div>';

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
		declare @funcionarioAsistenteDC varchar(150) = (select usuario from SCGI..SIST_USUARIO where idUsuario = @idUsuarioAsistente);

		insert into SCGI..SIST_COLA_ENVIO_CORREO
		values
		(
			CURRENT_TIMESTAMP,
			CURRENT_TIMESTAMP,
			@funcionarioAsistenteDC,
			'P',
			'0',
			@asunto + ' - copia -',
			@cuerpoCorreo,
			'1',
			CURRENT_TIMESTAMP,
			@idFuncionario,
			CURRENT_TIMESTAMP,
			@idFuncionario
		);

		if(@enviaEncuesta = 1)
		begin
			set @cuerpoCorreo = '<div style="font-family: Arial, sans-serif; margin: 0; padding: 0; background-color: #f4f4f4;">
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
				'Encuesta de Satisfacción',
				@cuerpoCorreo,
				'1',
				CURRENT_TIMESTAMP,
				@idFuncionario,
				CURRENT_TIMESTAMP,
				@idFuncionario
			);

			insert into SICORE_ENCUESTA_TRAZA
			select
				cotizacion.idCliente,
				certificado.idCertificado,
				@idFuncionario,
				getdate(),
				null,
				1
			from
				SICORE_COTIZACION cotizacion
			inner join
				SICORE_CERTIFICADO certificado on cotizacion.idCotizacion = certificado.idCotizacion
			where
				cotizacion.idCotizacion = @idCotizacion;
		end;

		select 1 as resultado
	
	COMMIT
END TRY
BEGIN CATCH
		Select ERROR_MESSAGE() as resultado

		rollback
END CATCH