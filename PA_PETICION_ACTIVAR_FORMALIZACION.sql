USE [SICORE]
GO

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_PETICION_ACTIVAR_FORMALIZACION]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_PETICION_ACTIVAR_FORMALIZACION]
GO

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Mayo 2025
-- Description:	Petición para activar de nuevo una Formalización cerrada.
-- =============================================

CREATE PROCEDURE [dbo].[PA_PETICION_ACTIVAR_FORMALIZACION] (@pFormalizacion as nvarchar(max))
AS
BEGIN TRY
	BEGIN TRAN

		declare @idFormalizacion int = (select idFormalizacion from openjson (@pFormalizacion) with (idFormalizacion int '$.idFormalizacion'));
		declare @justificacion varchar(255) = (select justificacion from openjson (@pFormalizacion) with (justificacion varchar(255) '$.justificacion'));
		declare @idFuncionario int = (select idFuncionario from openjson (@pFormalizacion) with (idFuncionario int '$.idFuncionario'));

		declare @idCotizacion int = (select idCotizacion from SICORE_FORMALIZACION where idFormalizacion = @idFormalizacion);
		declare @consecutivo int = (select consecutivo from SICORE_COTIZACION where idCotizacion = @idCotizacion);
		declare @emailFuncionarioDF varchar(150) = (select usuario from SCGI..SIST_USUARIO where idUsuario = @idFuncionario);

		declare @numeroConsecutivo varchar(10) = '';
		declare @annoActual varchar(4) = cast(year(getdate()) as varchar(4));

		if(len(@consecutivo) = 1) set @numeroConsecutivo = '00' + cast(@consecutivo as varchar(1));
		if(len(@consecutivo) = 2) set @numeroConsecutivo = '0' + cast(@consecutivo as varchar(2));
		if(len(@consecutivo) = 3) set @numeroConsecutivo =  cast(@consecutivo as varchar(10));

		declare @cotizacion varchar(100) = 'DDC-CO-' + @numeroConsecutivo + '-' + @annoActual;

		update SICORE_FORMALIZACION
		set
			justificacionActivacion = @justificacion,
			idUsuarioModificoAuditoria = @idFuncionario,
			fechaModificoAuditoria = getdate()
		where
			idFormalizacion = @idFormalizacion

		declare @cuerpoCorreo nvarchar(max) ='<div style="font-family: Arial, sans-serif; margin: 0; padding: 0; background-color: #f4f4f4;"><div style="max-width: 600px; margin: 0 auto; padding: 0px 20px 20px; background-color: #ffffff; box-shadow: 0px 4px 6px #ccc;"><div style="display: flex; align-items: center;"><img src="http://sipsa.fonafifo.com/PPSA/Imagenes/Banners/Logo-Banco-Color.jpg" width="20%" height="auto" style="margin-right: 20px;"><h2 style="color: #333; margin:38px 0 20px 0;font-size:18px">Notificación de SICORE</h2></div><p style="color: #666;">Se ha solicitado la activación de la Formalización de la Cotización: ' + @cotizacion + '</p><p style="color: #666;">La solicitud se da aduciendo que: ' + @justificacion + '. Por parte del usuario: ' + @emailFuncionarioDF + '</p></div></div>';

		set @cuerpoCorreo = trim(@cuerpoCorreo);

		insert into SCGI..SIST_COLA_ENVIO_CORREO
		values
		(
			CURRENT_TIMESTAMP,
			CURRENT_TIMESTAMP,
			'zrodriguez@fonafifo.go.cr',
			'P',
			'0',
			'Notificación de SICORE',
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