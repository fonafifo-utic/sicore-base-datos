USE [SICORE]
GO

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_RECHAZA_COTIZACION]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_RECHAZA_COTIZACION]
GO

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Mayo 2025
-- Description:	Activa una Formalización para que sea editada por motivo de error.
-- =============================================

CREATE PROCEDURE [dbo].[PA_RECHAZA_COTIZACION] (@pCotizacion nvarchar(max))
AS
BEGIN TRY
	BEGIN TRAN

		declare @idUsuario int = (select idUsuario from openjson (@pCotizacion) with (idUsuario int '$.idUsuario'));
		declare @idCotizacion int = (select idCotizacion from openjson (@pCotizacion) with (idCotizacion int '$.idCotizacion'));
		declare @observacion nvarchar(max) = (select observacion from openjson (@pCotizacion) with (observacion nvarchar(max) '$.observacion'));
		
		declare @consecutivo varchar(100) = (select consecutivo from SICORE_COTIZACION where idCotizacion = @idCotizacion);
		declare @idFuncionarioDF int = (select idUsuarioInsertoAuditoria from SICORE_COTIZACION where idCotizacion = @idCotizacion);
		declare @emailFuncionarioDF varchar(150) = (select usuario from SCGI..SIST_USUARIO where idUsuario = @idFuncionarioDF);
		declare @numeroConsecutivo varchar(10) = '';
		declare @annoActual varchar(4) = cast(year(getdate()) as varchar(4));

		if(len(@consecutivo) = 1) set @numeroConsecutivo = '00' + cast(@consecutivo as varchar(1));
		if(len(@consecutivo) = 2) set @numeroConsecutivo = '0' + cast(@consecutivo as varchar(2));
		if(len(@consecutivo) = 3) set @numeroConsecutivo =  cast(@consecutivo as varchar(10));

		declare @cotizacion varchar(100) = 'DDC-CO-' + @numeroConsecutivo + '-' + @annoActual;

		update SICORE_COTIZACION
		set
			idUsuarioModificoAuditoria = @idUsuario,
			fechaModificoAuditoria = getdate(),
			observacionDeAprobacion = @observacion,
			indicadorEstado = 'R'
		where
			idCotizacion = @idCotizacion

		declare @cuerpoCorreo nvarchar(max) ='<div style="font-family: Arial, sans-serif; margin: 0; padding: 0; background-color: #f4f4f4;"><div style="max-width: 600px; margin: 0 auto; padding: 0px 20px 20px; background-color: #ffffff; box-shadow: 0px 4px 6px #ccc;"><div style="display: flex; align-items: center;"><h2 style="color: #333; margin:38px 0 20px 0;font-size:18px">SOLICITUD DE APROBACIÓN</h2></div><br><p style="color: #666; font-weight:bold">La Cotización número: ' + @cotizacion + ' ha sido rechazada.</p><p style="color: #666; font-weight:bold">Se ha encontrado: ' + @observacion + '</p></div></div>';

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
			@idUsuario,
			CURRENT_TIMESTAMP,
			@idUsuario
		);

		select 1 as resultado
	
	COMMIT
END TRY
BEGIN CATCH
		Select ERROR_MESSAGE() as resultado
END CATCH