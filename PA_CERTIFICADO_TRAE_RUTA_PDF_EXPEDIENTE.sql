use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Marzo 2025
-- Description:	Trae la ruta de descarga de los archivos que acompañan el expediente.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_CERTIFICADO_TRAE_RUTA_PDF_EXPEDIENTE]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_CERTIFICADO_TRAE_RUTA_PDF_EXPEDIENTE]
GO

CREATE PROCEDURE [dbo].[PA_CERTIFICADO_TRAE_RUTA_PDF_EXPEDIENTE]
AS
BEGIN TRY
	BEGIN TRAN

		select
			nombreArchivo ruta
		from
			SICORE_EXPEDIENTE
		where
			idProyecto = 1
		and
			idCotizacion = 1
		and
			idFormalizacion = 1
		and 
			idCertificado = 1
		
	COMMIT
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE()
	ROLLBACK
END CATCH