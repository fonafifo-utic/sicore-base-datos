use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Septiembre 2024
-- Description:	Trae todos los registros de los tipos de empresa.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_CLIENTE_TIPO_TRAE_LISTADO]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_CLIENTE_TIPO_TRAE_LISTADO]
GO

CREATE PROCEDURE [dbo].[PA_CLIENTE_TIPO_TRAE_LISTADO]
AS
BEGIN TRY
	BEGIN TRAN

		select
			idTipoEmpresa,
			idSector,
			tipoEmpresa
		from
			SICORE_TIPO_EMPRESA

	COMMIT
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE()
	ROLLBACK TRANSACTION TPROCESO
END CATCH