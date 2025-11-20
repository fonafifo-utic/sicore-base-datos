use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Noviembre 2025
-- Description:	Trae parámetros del reporte de encuestas.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_PARAMETROS_TRAE]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_PARAMETROS_TRAE]
GO

CREATE PROCEDURE [dbo].[PA_PARAMETROS_TRAE]
AS
BEGIN TRY
	
	DECLARE @consecutivo INT = (SELECT CAST(valor AS INT) FROM SICORE_PARAMETROS WHERE descripcion = 'Contador de descargas reporte de encuestas.');
	DECLARE @textoAlternativoReporte VARCHAR(250) = (SELECT descripcion FROM SICORE_PARAMETROS WHERE valor = 'Texto alternativo del reporte de encuestas');

	SELECT
		@consecutivo AS consecutivo,
		@textoAlternativoReporte AS textoAlternativoReporte;
	
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE() AS error
END CATCH