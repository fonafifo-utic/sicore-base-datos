USE [SICORE]
GO

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Octubre 2025
-- Description:	Toma un objeto JSON para ingresar registros en la tabla de agrupación de cotizaciones.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_COTIZACION_INGRESA_AGRUPADA]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_COTIZACION_INGRESA_AGRUPADA]
GO

CREATE PROCEDURE [dbo].[PA_COTIZACION_INGRESA_AGRUPADA] (@pCotizacion as nvarchar(max))
AS
BEGIN TRY
	BEGIN TRAN

		SET @pCotizacion = REPLACE(@pCotizacion, '{ pCotizacion = "{', '{');
		SET @pCotizacion = REPLACE(@pCotizacion, '" }', '');

		DECLARE @consecutivo INT = (SELECT TOP 1 consecutivo FROM SICORE_COTIZACION_AGRUPACION ORDER BY idAgrupacion DESC);

		IF(@consecutivo IS NULL) SET @consecutivo = 1;
		ELSE SET @consecutivo = @consecutivo + 1;

		INSERT INTO SICORE_COTIZACION_AGRUPACION
		SELECT
			idCotizacion,
			idCliente,
			@consecutivo,
			idFuncionario,
			GETDATE(),
			indicadorEstado,
			'',
			GETDATE(),
			idFuncionario,
			NULL,
			NULL
		FROM
			OPENJSON (@pCotizacion)
		WITH
			(
				idCotizacion BIGINT '$.idCotizacion',
				idCliente BIGINT '$.idCliente', 
				idFuncionario BIGINT '$.idFuncionario',
				indicadorEstado CHAR(1) '$.indicadorEstado'
			);

		DECLARE @idUsuario BIGINT = (SELECT TOP 1 idFuncionario FROM OPENJSON(@pCotizacion) WITH (idFuncionario BIGINT '$.idFuncionario'));

		UPDATE cotizacion
		SET
			cotizacion.indicadorEstado = 'G',
			cotizacion.idUsuarioModificoAuditoria = @idUsuario,
			cotizacion.fechaModificoAuditoria = GETDATE()
		FROM
			SICORE_COTIZACION cotizacion
		INNER JOIN (
			SELECT
				idCotizacion
			FROM OPENJSON (@pCotizacion)
			WITH (
				idCotizacion BIGINT '$.idCotizacion'
			)
		) AS cotizaciones ON cotizacion.idCotizacion = cotizaciones.idCotizacion;

		DECLARE @consecutivoConFormato VARCHAR(10) = '';
		DECLARE @periodo VARCHAR(4) = CAST(YEAR(GETDATE()) AS VARCHAR(4));
		
		IF(LEN(@consecutivo) = 1) SET @consecutivoConFormato = '00' + CAST(@consecutivo AS VARCHAR(3));
		IF(LEN(@consecutivo) = 2) SET @consecutivoConFormato = '0' + CAST(@consecutivo AS VARCHAR(3));
		IF(LEN(@consecutivo) = 3) SET @consecutivoConFormato = CAST(@consecutivo AS VARCHAR(3));

		DECLARE @numeroCotizacion VARCHAR(255) = 'DDC-AG-' + @consecutivoConFormato +'-'+ @periodo;
		
		DECLARE @idUsuarioJefeDP BIGINT = (SELECT idUsuario FROM SICORE_USUARIO WHERE idPerfil = 6);
		DECLARE @jefaturaDP VARCHAR(255) = (SELECT usuario FROM SCGI..SIST_USUARIO WHERE idUsuario = @idUsuarioJefeDP);

		DECLARE @idUsuarioJefeDM BIGINT = (SELECT idUsuario FROM SICORE_USUARIO WHERE idPerfil = 7);
		DECLARE @jefaturaDM VARCHAR(255) = (SELECT usuario FROM SCGI..SIST_USUARIO WHERE idUsuario = @idUsuarioJefeDM);

		DECLARE @destinatario VARCHAR(150) = @jefaturaDM + ';' + @jefaturaDP;
		DECLARE @asunto VARCHAR(150) = 'Solicitud de Aprobación';
		DECLARE @idPersona BIGINT = (SELECT idPersona FROM SCGI..SIST_USUARIO WHERE idUsuario = @idUsuario);
		DECLARE @nombreFuncionario VARCHAR(250) = (SELECT
														dbo.FN_GET_CAMEL_CASE(nombre) + ' ' +
														dbo.FN_GET_CAMEL_CASE(primerApellido) + ' ' +
														dbo.FN_GET_CAMEL_CASE(segundoApellido) funcionario
													FROM
														SCGI..SIST_PERSONA
													WHERE
														idPersona = @idPersona);

		declare @cuerpoCorreo NVARCHAR(MAX) = '<div style="font-family: Arial, sans-serif; margin: 0; padding: 0; background-color: #f4f4f4;"><div style="max-width: 600px; margin: 0 auto; padding: 0px 20px 20px; background-color: #ffffff; box-shadow: 0px 4px 6px #ccc;"><div style="display: flex; align-items: center;"><h2 style="color: #333; margin:38px 0 20px 0;font-size:18px">APROBACIÓN DE COTIZACIÓN</h2></div><br><p style="color: #666; font-weight:bold">La cotización agrupada N° ' + @numeroCotizacion + ' elaborada por el funcionario ' + @nombreFuncionario + ', está lista para su revisión.</p></div></div>';

		SET @cuerpoCorreo = TRIM(@cuerpoCorreo);

		INSERT INTO SCGI..SIST_COLA_ENVIO_CORREO
		VALUES
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
			@idUsuario,
			CURRENT_TIMESTAMP,
			@idUsuario
		);

		SELECT 1 AS resultado;

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK

	SELECT ERROR_MESSAGE() AS resultado;
END CATCH