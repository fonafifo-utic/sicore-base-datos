use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Febrero 2025
-- Description:	Trae los registros de un Expediente en Proyecto filtrados por ID.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_PROYECTO_TRAE_EXPEDIENTE_PORID]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_PROYECTO_TRAE_EXPEDIENTE_PORID]
GO

CREATE PROCEDURE [dbo].[PA_PROYECTO_TRAE_EXPEDIENTE_PORID] (@pIdProyecto as int)
AS
BEGIN TRY
	BEGIN TRANSACTION
		
		select
			idProyecto,
			nombreArchivo,
			rutaFisicaArchivo
		from
			SICORE_EXPEDIENTE
		where
			idProyecto = @pIdProyecto
		and
			idCertificado = 0
		and
			idCotizacion = 0
		and
			idFormalizacion = 0
	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK
END CATCH