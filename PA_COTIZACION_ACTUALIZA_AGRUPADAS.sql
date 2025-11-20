use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Octubre 2025
-- Description:	Toma un objeto JSON para actualizar el estado de las cotizaciones agrupadas.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_COTIZACION_ACTUALIZA_AGRUPADAS]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_COTIZACION_ACTUALIZA_AGRUPADAS]
GO

CREATE PROCEDURE [dbo].[PA_COTIZACION_ACTUALIZA_AGRUPADAS] (@pCotizacion as nvarchar(max))
AS
BEGIN TRY
	BEGIN TRANSACTION

		SET @pCotizacion = REPLACE(@pCotizacion, '{ pCotizacion = "{', '{');
		SET @pCotizacion = REPLACE(@pCotizacion, '" }', '');

		DECLARE @indicadorEstado CHAR(1) = (SELECT indicadorEstado FROM OPENJSON (@pCotizacion) WITH (indicadorEstado CHAR(1) '$.indicadorEstado'));
		DECLARE @justificacion VARCHAR(MAX) = (SELECT justificacion FROM OPENJSON (@pCotizacion) WITH (justificacion VARCHAR(MAX) '$.justificacion'));
		DECLARE @idFuncionario INT = (SELECT idFuncionario FROM OPENJSON (@pCotizacion) WITH (idFuncionario INT '$.idFuncionario'));
		DECLARE @consecutivo INT = (SELECT consecutivo FROM OPENJSON (@pCotizacion) WITH (consecutivo INT '$.consecutivo'));

		DECLARE @consecutivoConFormato VARCHAR(10) = '';
		DECLARE @periodo VARCHAR(4) = CAST(YEAR(GETDATE()) AS VARCHAR(4));

		DECLARE @numeroCotizacion VARCHAR(255) = 'DDC-AG-' + @consecutivoConFormato +'-'+ @periodo;
		
		DECLARE @idUsuarioJefeDP BIGINT = 0;
		DECLARE @jefaturaDP VARCHAR(255) = 0;

		DECLARE @idUsuarioJefeDM BIGINT = 0;
		DECLARE @jefaturaDM VARCHAR(255) = 0;

		DECLARE @asunto VARCHAR(150) = '';
		DECLARE @destinatario VARCHAR(150) = '';
		DECLARE @idPersona BIGINT = 0;
		DECLARE @nombreFuncionario VARCHAR(250) = '';

		DECLARE @cuerpoCorreo NVARCHAR(MAX) = '';

		IF(@indicadorEstado = 'R')
		BEGIN

			UPDATE SICORE_COTIZACION_AGRUPACION
			SET
				indicadorEstado = @indicadorEstado,
				justificacionAprobacion = @justificacion,
				fechaModificoAuditoria = GETDATE(),
				idUsuarioModificoAuditoria = @idFuncionario
			WHERE
				consecutivo = @consecutivo;

			UPDATE SICORE_COTIZACION
			SET
				indicadorEstado = 'A',
				fechaModificoAuditoria = GETDATE(),
				idUsuarioModificoAuditoria = @idFuncionario
			WHERE
				idCotizacion IN (SELECT idCotizacion FROM SICORE_COTIZACION_AGRUPACION WHERE consecutivo = @consecutivo);

			IF(LEN(@consecutivo) = 1) SET @consecutivoConFormato = '00' + CAST(@consecutivo AS VARCHAR(3));
			IF(LEN(@consecutivo) = 2) SET @consecutivoConFormato = '0' + CAST(@consecutivo AS VARCHAR(3));
			IF(LEN(@consecutivo) = 3) SET @consecutivoConFormato = CAST(@consecutivo AS VARCHAR(3));

			SET @numeroCotizacion = 'DDC-AG-' + @consecutivoConFormato +'-'+ @periodo;

			SET @asunto = 'Agrupación Rechazada';
			SET @idFuncionario = (SELECT TOP 1 idUsuarioInsertoAuditoria FROM SICORE_COTIZACION_AGRUPACION WHERE consecutivo = @consecutivo);
			SET @destinatario = (SELECT usuario FROM SCGI..SIST_USUARIO WHERE idUsuario = @idFuncionario);
			SET @idPersona = (SELECT idPersona FROM SCGI..SIST_USUARIO WHERE idUsuario = @idFuncionario);

			SET @cuerpoCorreo = '<div style="font-family: Arial, sans-serif; margin: 0; padding: 0; background-color: #f4f4f4;"><div style="max-width: 600px; margin: 0 auto; padding: 0px 20px 20px; background-color: #ffffff; box-shadow: 0px 4px 6px #ccc;"><div style="display: flex; align-items: center;"><h2 style="color: #333; margin:38px 0 20px 0;font-size:18px">AGRUPACIÓN RECHAZADA</h2></div><br><p style="color: #666; font-weight:bold">La cotización agrupada N° ' + @numeroCotizacion + ' ha sido rechazada para su valoración.</p></div></div>';
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
				@idFuncionario,
				CURRENT_TIMESTAMP,
				@idFuncionario
			);

			SELECT 1 AS resultado;

		END
		ELSE
		BEGIN

			UPDATE SICORE_COTIZACION_AGRUPACION
			SET
				indicadorEstado = @indicadorEstado,
				fechaModificoAuditoria = GETDATE(),
				idUsuarioModificoAuditoria = @idFuncionario
			WHERE
				consecutivo = @consecutivo;

			SET @consecutivoConFormato = '';
			SET @periodo = CAST(YEAR(GETDATE()) AS VARCHAR(4));
		
			IF(LEN(@consecutivo) = 1) SET @consecutivoConFormato = '00' + CAST(@consecutivo AS VARCHAR(3));
			IF(LEN(@consecutivo) = 2) SET @consecutivoConFormato = '0' + CAST(@consecutivo AS VARCHAR(3));
			IF(LEN(@consecutivo) = 3) SET @consecutivoConFormato = CAST(@consecutivo AS VARCHAR(3));

			SET @numeroCotizacion = 'DDC-AG-' + @consecutivoConFormato +'-'+ @periodo;
		
			SET @asunto = 'Agrupación Aprobada';
			SET @idFuncionario = (SELECT TOP 1 idUsuarioInsertoAuditoria FROM SICORE_COTIZACION_AGRUPACION WHERE consecutivo = @consecutivo);
			SET @destinatario = (SELECT usuario FROM SCGI..SIST_USUARIO WHERE idUsuario = @idFuncionario);
			SET @idPersona = (SELECT idPersona FROM SCGI..SIST_USUARIO WHERE idUsuario = @idFuncionario);

			SET @cuerpoCorreo = '<div style="font-family: Arial, sans-serif; margin: 0; padding: 0; background-color: #f4f4f4;"><div style="max-width: 600px; margin: 0 auto; padding: 0px 20px 20px; background-color: #ffffff; box-shadow: 0px 4px 6px #ccc;"><div style="display: flex; align-items: center;"><h2 style="color: #333; margin:38px 0 20px 0;font-size:18px">APROBACIÓN DE COTIZACIÓN AGRUPADA</h2></div><br><p style="color: #666; font-weight:bold">La agrupación N° ' + @numeroCotizacion + ' fue aprobada.</p></div></div>';

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
				@idFuncionario,
				CURRENT_TIMESTAMP,
				@idFuncionario
			);

			SELECT 1 AS resultado;

		END

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK

	select ERROR_MESSAGE() as resultado
END CATCH