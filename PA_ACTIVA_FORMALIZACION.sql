USE [SICORE]
GO

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_ACTIVA_FORMALIZACION]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_ACTIVA_FORMALIZACION]
GO

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Mayo 2025
-- Description:	Activa una Formalización para que sea editada por motivo de error.
-- =============================================

CREATE PROCEDURE [dbo].[PA_ACTIVA_FORMALIZACION] (@pFormalizacion as nvarchar(max))
AS
BEGIN TRY
	BEGIN TRAN

		declare @idFormalizacion varchar(10) = (select idFormalizacion from openjson (@pFormalizacion) with (idFormalizacion varchar(10) '$.idFormalizacion'));
		
		declare @idFuncionarioDF int = 0;
		declare @creditoDebito char(1) = '';
		declare @emailFuncionarioDF varchar(150) = '';
		declare @consecutivo int = 0;
		
		if charindex(',', @idFormalizacion) > 0
		begin
			declare @idsCotizacion varchar(10) = (
													select STRING_AGG(idCotizacion, ', ')
													from SICORE_FORMALIZACION
													where idFormalizacion in (select value
																			from string_split(@idFormalizacion, ',')
																			where value != '')
												);

			set @idFuncionarioDF = (
										select top 1 idUsuarioModificoAuditoria
										from SICORE_FORMALIZACION
										where idFormalizacion in (select value
																from string_split(@idFormalizacion, ',')
																where value != '')
									);

			set @creditoDebito = (
										select top 1 creditoDebito
										from SICORE_FORMALIZACION
										where idFormalizacion in (select value
																from string_split(@idFormalizacion, ',')
																where value != '')
								);

			set @emailFuncionarioDF = (select usuario from SCGI..SIST_USUARIO where idUsuario = @idFuncionarioDF);

			set @consecutivo = (
								select top 1 consecutivo
								from SICORE_COTIZACION_AGRUPACION
								where idCotizacion in (select value
														from string_split(@idsCotizacion, ',')
														where value != '')
								and indicadorEstado = 'P'
								);
		end
		else
		begin
			declare @idCotizacion varchar(10) = (select idCotizacion from SICORE_FORMALIZACION where idFormalizacion = @idFormalizacion);

			set @idFuncionarioDF = (select idUsuarioModificoAuditoria from SICORE_FORMALIZACION where idFormalizacion = @idFormalizacion);
			set @creditoDebito = (select creditoDebito from SICORE_FORMALIZACION where idFormalizacion = @idFormalizacion);
			set @emailFuncionarioDF = (select usuario from SCGI..SIST_USUARIO where idUsuario = @idFuncionarioDF);
			set @consecutivo = (select consecutivo from SICORE_COTIZACION_AGRUPACION where idCotizacion = @idCotizacion and indicadorEstado = 'P');
		end
		
		declare @numeroConsecutivo varchar(10) = '';
		declare @annoActual varchar(4) = cast(year(getdate()) as varchar(4));

		if(len(@consecutivo) = 1) set @numeroConsecutivo = '00' + cast(@consecutivo as varchar(1));
		if(len(@consecutivo) = 2) set @numeroConsecutivo = '0' + cast(@consecutivo as varchar(2));
		if(len(@consecutivo) = 3) set @numeroConsecutivo =  cast(@consecutivo as varchar(10));

		declare @cotizacion varchar(100) = 'DDC-CO-' + @numeroConsecutivo + '-' + @annoActual;
		declare @indicadorEstado char(1) = 'K';
		
		if charindex(',', @idFormalizacion) > 0
		begin
			update SICORE_FORMALIZACION
			set
				vistoBuenoJefatura = 'A',
				indicadorEstado = @indicadorEstado,
				idUsuarioModificoAuditoria = 17086,
				fechaModificoAuditoria = getdate()
			where
				idFormalizacion in (select value
								from string_split(@idFormalizacion, ',')
								where value != '');
		end
		else
		begin
			update SICORE_FORMALIZACION
			set
				vistoBuenoJefatura = 'A',
				indicadorEstado = @indicadorEstado,
				idUsuarioModificoAuditoria = 17086,
				fechaModificoAuditoria = getdate()
			where
				idFormalizacion = @idFormalizacion
		end

		declare @cuerpoCorreo nvarchar(max) ='<div style="font-family: Arial, sans-serif; margin: 0; padding: 0; background-color: #f4f4f4;"><div style="max-width: 600px; margin: 0 auto; padding: 0px 20px 20px; background-color: #ffffff; box-shadow: 0px 4px 6px #ccc;"><div style="display: flex; align-items: center;"><h2 style="color: #333; margin:38px 0 20px 0;font-size:18px">Solicitud de Aprobación</h2></div><p style="color: #666;">Se ha aprobado la Formalización de la Cotización: ' + @cotizacion + '</p><hr></div></div>';

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

		select 1 as resultado;
	
	COMMIT
END TRY
BEGIN CATCH
		Select ERROR_MESSAGE() as resultado
END CATCH