USE [SICORE]
GO

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_CERTIFICADO_FORMALIZADO_PARA_FIRMAR]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_CERTIFICADO_FORMALIZADO_PARA_FIRMAR]
GO

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Junio 2025
-- Description:	Pone en cola un nuevo certificado de CO2 para revisarlo antes de que pase a Dirección Ejecutiva.
-- =============================================

CREATE PROCEDURE [dbo].[PA_CERTIFICADO_FORMALIZADO_PARA_FIRMAR] (@pFormalizacion as nvarchar(max))
AS
BEGIN TRY
	BEGIN TRAN

		declare @nuevoCertificado varchar(100) = (select numeroFormalizacion from openjson(@pFormalizacion) with (numeroFormalizacion varchar(150)));
		declare @asunto varchar(150) = (select asunto from openjson(@pFormalizacion) with (asunto varchar(150)));
		declare @destinatario varchar(100) = (select correoGerenciaEjecutiva from SICORE_PERSONALIZACION);
		declare @idFuncionario bigint = (select idFuncionario from openjson(@pFormalizacion) with (idFuncionario bigint));

		declare @consecutivo int = (select cast(substring(@nuevoCertificado, 8, 3) as int));
		declare @idFuncionarioComercial bigint = (select idFuncionario from SICORE_COTIZACION where consecutivo = @consecutivo);
		declare @destinatarioComercial varchar(100) = (select usuario from [SCGI].[dbo].[SIST_USUARIO] where idUsuario = @idFuncionarioComercial);

		declare @cuerpoCorreo nvarchar(max) = '<div style="font-family: Arial, sans-serif; margin: 0; padding: 0; background-color: #f4f4f4;"><div style="max-width: 600px; margin: 0 auto; padding: 0px 20px 20px; background-color: #ffffff; box-shadow: 0px 4px 6px #ccc;"><div style="display: flex; align-items: center;"><h2 style="color: #333; margin:38px 0 20px 0;font-size:18px">NUEVO CERTIFICADO DE COMPENSACIÓN DE CO2</h2></div><p style="color: #666; font-weight:bold">La cotización N° ' + @nuevoCertificado + ' está lista para ser revisada antes de ser firmada por el Director Ejecutivo.</p></div></div>';

		set @cuerpoCorreo = trim(@cuerpoCorreo);
		set @destinatarioComercial = @destinatarioComercial + ';silvia.zuniga@fonafifo.go.cr';

		set @asunto = @asunto + ' - revisión -';

		insert into SCGI..SIST_COLA_ENVIO_CORREO
		values
		(
			CURRENT_TIMESTAMP,
			CURRENT_TIMESTAMP,
			@destinatarioComercial,
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