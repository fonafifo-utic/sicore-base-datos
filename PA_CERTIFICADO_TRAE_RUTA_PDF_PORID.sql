use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Noviembre 2024
-- Description:	Trae la ruta de descarga del Certificado.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_CERTIFICADO_TRAE_RUTA_PDF_PORID]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_CERTIFICADO_TRAE_RUTA_PDF_PORID]
GO

CREATE PROCEDURE [dbo].[PA_CERTIFICADO_TRAE_RUTA_PDF_PORID] (@pIdCertificado int)
AS
BEGIN TRY
	BEGIN TRAN

		select
			nombreArchivo ruta
		from
			SICORE_EXPEDIENTE
		where
			idCertificado = @pIdCertificado
		and
			idProyecto = 0
		and
			idCotizacion = 0
		and
			idFormalizacion = 0
		
	COMMIT
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE()
	ROLLBACK
END CATCH