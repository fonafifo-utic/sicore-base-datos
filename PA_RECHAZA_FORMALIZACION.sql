USE [SICORE]
GO

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_RECHAZA_FORMALIZACION]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_RECHAZA_FORMALIZACION]
GO

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Mayo 2025
-- Description:	Rechaza una Formalización para que sea editada por motivo de error.
-- =============================================

CREATE PROCEDURE [dbo].[PA_RECHAZA_FORMALIZACION] (@pFormalizacion as nvarchar(max))
AS
BEGIN TRY
	BEGIN TRAN

		declare @consecutivo varchar(100) = (select consecutivo from openjson (@pFormalizacion) with (consecutivo int '$.consecutivo'));
		declare @justificacionActivacion nvarchar(max) = (select justificacionActivacion from openjson (@pFormalizacion) with (justificacionActivacion nvarchar(max) '$.justificacionActivacion'));
		
		declare @idCotizacion int = (select idCotizacion from SICORE_COTIZACION where consecutivo = @consecutivo);
		declare @idFormalizacion int = (select idFormalizacion from SICORE_FORMALIZACION where idCotizacion = @idCotizacion);
		declare @idFuncionarioDF int = (select idUsuarioInsertoAuditoria from SICORE_FORMALIZACION where idCotizacion = @idCotizacion);
		declare @emailFuncionarioDF varchar(150) = (select usuario from SCGI..SIST_USUARIO where idUsuario = @idFuncionarioDF);
		declare @numeroConsecutivo varchar(10) = '';
		declare @annoActual varchar(4) = cast(year(getdate()) as varchar(4));

		if(len(@consecutivo) = 1) set @numeroConsecutivo = '00' + cast(@consecutivo as varchar(1));
		if(len(@consecutivo) = 2) set @numeroConsecutivo = '0' + cast(@consecutivo as varchar(2));
		if(len(@consecutivo) = 3) set @numeroConsecutivo =  cast(@consecutivo as varchar(10));

		declare @cotizacion varchar(100) = 'DDC-CO-' + @numeroConsecutivo + '-' + @annoActual;

		update SICORE_FORMALIZACION
		set
			vistoBuenoJefatura = 'R',
			indicadorEstado = 'R',
			idUsuarioModificoAuditoria = 17086,
			fechaModificoAuditoria = getdate(),
			justificacionActivacion = @justificacionActivacion
		where
			idFormalizacion = @idFormalizacion

		declare @cuerpoCorreo nvarchar(max) ='<div style="font-family: Arial, sans-serif; margin: 0; padding: 0; background-color: #f4f4f4;"><div style="max-width: 600px; margin: 0 auto; padding: 0px 20px 20px; background-color: #ffffff; box-shadow: 0px 4px 6px #ccc;"><div style="display: flex; align-items: center;"><h2 style="color: #333; margin:38px 0 20px 0;font-size:18px">Solicitud de Aprobación</h2></div><p style="color: #666;">Se ha rechazado la Formalización de la Cotización: ' + @cotizacion + '</p><p style="color: #666;">Se ha encontrado las siguientes observaciones: ' + @justificacionActivacion + '</p></div></div>';

		set @cuerpoCorreo = trim(@cuerpoCorreo);

		insert into SCGI..SIST_COLA_ENVIO_CORREO
		values
		(
			CURRENT_TIMESTAMP,
			CURRENT_TIMESTAMP,
			@emailFuncionarioDF,
			'P',
			'0',
			'Solicitud de Aprobación',
			@cuerpoCorreo,
			'1',
			CURRENT_TIMESTAMP,
			17086,
			CURRENT_TIMESTAMP,
			17086
		);

		select 1 as resultado
	
	COMMIT
END TRY
BEGIN CATCH
		Select ERROR_MESSAGE() as resultado
END CATCH