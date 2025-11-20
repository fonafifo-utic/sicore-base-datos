use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Agosto 2024
-- Description:	Trae todos los registros del Sector Comercial.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_CLIENTE_SECTOR_TRAE_LISTADO_COMPLETO]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_CLIENTE_SECTOR_TRAE_LISTADO_COMPLETO]
GO

CREATE PROCEDURE [dbo].[PA_CLIENTE_SECTOR_TRAE_LISTADO_COMPLETO]
AS
BEGIN TRY
	BEGIN TRAN

		select
			idSectorComercial,
			sectorComercial
		from
			SICORE_SECTOR_COMERCIAL sector

	COMMIT
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE()
	ROLLBACK TRANSACTION TPROCESO
END CATCH