use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Enero 2025
-- Description:	Trae la ruta de descarga del Expediente de Proyecto.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_PROYECTO_TRAE_RUTA_EXPEDIENTE_PDF_PORID]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_PROYECTO_TRAE_RUTA_EXPEDIENTE_PDF_PORID]
GO

CREATE PROCEDURE [dbo].[PA_PROYECTO_TRAE_RUTA_EXPEDIENTE_PDF_PORID] (@pIdProyecto int)
AS
BEGIN TRY
	BEGIN TRAN

		select
			nombreArchivo ruta
		from
			SICORE_EXPEDIENTE
		where
			idProyecto = @pIdProyecto
		and
			idCotizacion = 0
		and
			idFormalizacion = 0
		and
			idCertificado = 0
		
	COMMIT
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE()
	ROLLBACK
END CATCH