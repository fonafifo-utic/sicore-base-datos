use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Noviembre 2025
-- Description:	Toma un objeto JSON para ingresar registros en la tabla Parámetros.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_PARAMETROS_ACTUALIZA]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_PARAMETROS_ACTUALIZA]
GO

CREATE PROCEDURE [dbo].[PA_PARAMETROS_ACTUALIZA] (@pParametros as nvarchar(max))
AS
BEGIN TRY
	BEGIN TRAN
		
		set @pParametros = replace(@pParametros, '{ pParametros = "{', '{');
		set @pParametros = replace(@pParametros, '" }', '');

		DECLARE @consecutivo INT = (SELECT CAST(valor AS INT) FROM SICORE_PARAMETROS WHERE descripcion = 'Contador de descargas reporte de encuestas.');
		DECLARE @textoAlternativoReporte VARCHAR(250) = (SELECT descripcion FROM SICORE_PARAMETROS WHERE valor = 'Texto alternativo del reporte de encuestas');

		DECLARE @consecutivoDesdeFE INT = (SELECT consecutivo FROM OPENJSON(@pParametros) WITH (consecutivo INT '$.consecutivo')); 
		DECLARE @textoAlternativoReporteFE VARCHAR(250) = (SELECT textoAlternativo FROM OPENJSON(@pParametros) WITH (textoAlternativo VARCHAR(250) '$.textoAlternativoReporte'));

		IF(@consecutivo < @consecutivoDesdeFE)
		BEGIN
	
			UPDATE SICORE_PARAMETROS
			SET
				valor = CAST(@consecutivoDesdeFE AS VARCHAR(10))
			WHERE
				descripcion = 'Contador de descargas reporte de encuestas.';
		END

		IF(@textoAlternativoReporte != @textoAlternativoReporteFE)
		BEGIN
	
			UPDATE SICORE_PARAMETROS
			SET
				descripcion = @textoAlternativoReporteFE
			WHERE
				valor = 'Texto alternativo del reporte de encuestas'
		END

		SELECT 1 resultado;

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK

	SELECT ERROR_MESSAGE() as resultado
END CATCH