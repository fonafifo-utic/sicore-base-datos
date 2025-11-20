USE [SICORE]
GO

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_ENVIAR_CERTIFICADO_PARA_SERFIRMADO]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_ENVIAR_CERTIFICADO_PARA_SERFIRMADO]
GO

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Junio 2025
-- Description:	Pone en cola un nuevo certificado de CO2 para ser firmado por dirección ejecutiva.
-- =============================================

CREATE PROCEDURE [dbo].[PA_ENVIAR_CERTIFICADO_PARA_SERFIRMADO] (@idFuncionario bigint, @idCertificado varchar(10))
AS
BEGIN TRY
	BEGIN TRAN

		declare @consecutivo int = (select max(numeroCertificado) from SICORE_CERTIFICADO where idCertificado in (select value from string_split(@idCertificado, ',') where value != ''));
		declare @destinatario varchar(100) = (select correoGerenciaEjecutiva from SICORE_PERSONALIZACION);
		declare @annoEnCurso varchar(10) = cast(year(getdate()) as varchar(10));
		declare @nuevoCertificado varchar(100) = '';

		if(len(@consecutivo) = 1) set @nuevoCertificado = @annoEnCurso + '-00' + cast(@consecutivo as varchar(10));
		if(len(@consecutivo) = 2) set @nuevoCertificado = @annoEnCurso + '-0' + cast(@consecutivo as varchar(10));
		if(len(@consecutivo) = 3) set @nuevoCertificado = @annoEnCurso + '-' + cast(@consecutivo as varchar(10));

		declare @cuerpoCorreo nvarchar(max) = '<div style="font-family: Arial, sans-serif; margin: 0; padding: 0; background-color: #f4f4f4;"><div style="max-width: 600px; margin: 0 auto; padding: 0px 20px 20px; background-color: #ffffff; box-shadow: 0px 4px 6px #ccc;"><div style="display: flex; align-items: center;"><h2 style="color: #333; margin:38px 0 20px 0;font-size:18px">NUEVO CERTIFICADO DE COMPENSACIÓN DE CO2</h2></div><p style="color: #666; font-weight:bold">El certificado N° ' + @nuevoCertificado + ' está listo para ser firmado por el Director Ejecutivo.</p></div></div>';

		set @cuerpoCorreo = trim(@cuerpoCorreo);
		
		insert into SCGI..SIST_COLA_ENVIO_CORREO
		values
		(
			CURRENT_TIMESTAMP,
			CURRENT_TIMESTAMP,
			@destinatario,
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