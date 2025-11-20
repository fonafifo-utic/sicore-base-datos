use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Agosto 2024
-- Description:	Trae todos los registros del Sector Comercial.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_CLIENTE_SECTOR_TRAE_LISTADO]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_CLIENTE_SECTOR_TRAE_LISTADO]
GO

CREATE PROCEDURE [dbo].[PA_CLIENTE_SECTOR_TRAE_LISTADO]
AS
BEGIN TRY
	BEGIN TRAN

		select distinct
			sector.idSectorComercial idSectorComercial,
			sector.sectorComercial sectorComercial
		from
			SICORE_SECTOR_COMERCIAL sector
		inner join
			SICORE_CLIENTE cliente on sector.idSectorComercial = cliente.idSector
		where
			cliente.indicadorEstado = 'A';

	COMMIT
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE()
	ROLLBACK TRANSACTION TPROCESO
END CATCH