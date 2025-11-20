use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Noviembre 2024
-- Description:	Trae la ruta de descarga de la Formalización.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_FORMALIZACION_TRAE_RUTA_PDF_PORID]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_FORMALIZACION_TRAE_RUTA_PDF_PORID]
GO

CREATE PROCEDURE [dbo].[PA_FORMALIZACION_TRAE_RUTA_PDF_PORID] (@pIdFormalizacion nvarchar(max))
AS
BEGIN TRY
	BEGIN TRAN

		select top 1
			nombreArchivo ruta
		from
			SICORE_EXPEDIENTE
		where
			idFormalizacion in (select value from string_split(@pIdFormalizacion, ',') where value != '')
		and
			nombreArchivo like '%.pdf'
		
	COMMIT
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE()
	ROLLBACK
END CATCH