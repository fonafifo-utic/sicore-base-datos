USE [SICORE]
GO

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_DOBLEFACTOR_ENVIAR_CODIGOSEGURIDAD]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_DOBLEFACTOR_ENVIAR_CODIGOSEGURIDAD]
GO

-- =============================================
-- Author:		Rogelio Solano A
-- Create date: 01 Oct 2023
-- Description:	Este PA envía el código de seguridad para el doble factor al medio seleccionado por el cliente, ya sea al correo o al telefono
-- Comentario: Adaptación para SICORE, por parte de Álvaro Zamora S.
-- Fecha Adaptación: 27 junio 2024
-- =============================================

CREATE PROCEDURE [dbo].[PA_DOBLEFACTOR_ENVIAR_CODIGOSEGURIDAD]
	@pIdPersona bigint,
	@pCodigo varchar(50),
	@pOpcionEnvio char(1),
	@pNombreSistema varchar(150),
	@pCorreoUsuario varchar(150)=null,
	@pTelefonoUsuario varchar(50)=null
AS
BEGIN
	
	Declare @asunto varchar(250)
	Declare @mensaje varchar(600)
	Declare @cuerpoCorreo varchar(max)
	declare @correo varchar(350)
	declare @telefono varchar(200)
	declare @idUsuario bigint
	
	Begin Try
		set @idUsuario = @pIdPersona;
		
		if(@pOpcionEnvio='E')
		Begin
			set @correo=@pCorreoUsuario

			Set @asunto='Envío de Código de Seguridad';
			Set @mensaje='Estimado(a) usuario(a):</strong> Se ha generado el siguiente código de seguridad requerido para ingresar al sistema: <b>'	+@pCodigo;
			Set @cuerpoCorreo='<div style="font-family: Arial, sans-serif; margin: 0; padding: 0; background-color: #f4f4f4;">    <div style="max-width: 600px; margin: 0 auto; padding: 0px 20px 20px; background-color: #ffffff; box-shadow: 0px 4px 6px #ccc;">    <div style="display: flex; align-items: center;">    <img src="http://sipsa.fonafifo.com/PPSA/Imagenes/Banners/Logo-Banco-Color.jpg" width="20%" height="auto" style="margin-right: 20px;">    <h2 style="color: #333; margin:38px 0 20px 0;font-size:18px">Sistema para Comercialización de Reducción de Emisiones - SICORE -</h2>    </div><p style="color: #666;">Se ha generado el siguiente código de seguridad requerido para ingresar al sistema: ' + @pCodigo + ' </p>    <hr></div></div>';

			Insert Into SCGI..SIST_COLA_ENVIO_CORREO
			Values
			(
				CURRENT_TIMESTAMP,
				CURRENT_TIMESTAMP,
				@correo,
				'P',
				'0',
				@asunto,
				@cuerpoCorreo,
				'1',
				CURRENT_TIMESTAMP,
				@idUsuario,
				CURRENT_TIMESTAMP,
				@idUsuario
			);

		End
		Else --Si es por teléfono
		Begin
				set @telefono = @pTelefonoUsuario;
				Set @mensaje='Su código de verificación de acceso al sistema '+@pNombreSistema+' de FONAFIFO es: '+ @pCodigo
				
				Insert into SCGI..SIST_COLA_ENVIO_SMS
				Values
					(
						CURRENT_TIMESTAMP,
						CURRENT_TIMESTAMP,
						@telefono,@mensaje,
						'P',
						'0',
						1,
						CURRENT_TIMESTAMP,
						@idUsuario,
						CURRENT_TIMESTAMP,
						@idUsuario
					)
		End

		Select 1 as result
	End Try
	Begin Catch
		Select ERROR_MESSAGE() as result
	End Catch
END
