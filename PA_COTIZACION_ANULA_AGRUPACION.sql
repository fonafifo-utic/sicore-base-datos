use SICORE
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Octubre 2025
-- Description:	Anula una agrupación de cotizaciones.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_COTIZACION_ANULA_AGRUPACION]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_COTIZACION_ANULA_AGRUPACION]
GO

CREATE PROCEDURE [dbo].[PA_COTIZACION_ANULA_AGRUPACION] (@pCotizacion AS NVARCHAR(MAX))
AS
BEGIN TRY
	BEGIN TRAN

		SET @pCotizacion = replace(@pCotizacion, '{ pCotizacion = "{', '{');
		SET @pCotizacion = replace(@pCotizacion, '" }', '');

		DECLARE @idCotizacion INT = (SELECT idCotizacion FROM OPENJSON (@pCotizacion) WITH (idCotizacion INT '$.idCotizacion'));
		DECLARE @idUsuario INT = (SELECT idUsuario FROM OPENJSON (@pCotizacion) WITH (idUsuario INT '$.idUsuario'));
		DECLARE @descripcion VARCHAR(255) = (SELECT descripcion FROM OPENJSON (@pCotizacion) WITH (descripcion VARCHAR(255) '$.descripcion'));
		
		UPDATE SICORE_COTIZACION_AGRUPACION
		SET
			indicadorEstado = 'N',
			justificacionAprobacion = @descripcion,
			fechaModificoAuditoria = GETDATE(),
			idUsuarioModificoAuditoria = @idUsuario
		WHERE
			consecutivo = @idCotizacion;

		UPDATE SICORE_COTIZACION
		SET
			indicadorEstado = 'A',
			fechaModificoAuditoria = GETDATE(),
			idUsuarioModificoAuditoria = @idUsuario
		WHERE
			idCotizacion IN (SELECT idCotizacion FROM SICORE_COTIZACION_AGRUPACION WHERE consecutivo = @idCotizacion);

		SELECT 1 AS resultado;

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK

	select ERROR_MESSAGE() as resultado
END CATCH