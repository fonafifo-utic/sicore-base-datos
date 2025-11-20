use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Agosto 2024
-- Description:	Trae todos los registros de la tabla Cliente.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_CLIENTE_TRAE_LISTADO_SECTOR_TURISMO]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_CLIENTE_TRAE_LISTADO_SECTOR_TURISMO]
GO

CREATE PROCEDURE [dbo].[PA_CLIENTE_TRAE_LISTADO_SECTOR_TURISMO]
AS
BEGIN TRY
	BEGIN TRAN

		select
			cliente.idCliente,
			cliente.idSector,
			sector.sectorComercial,
			cliente.nombreCliente,
			cliente.cedulaCliente,
			cliente.contactoCliente,
			cliente.telefonoCliente,
			cliente.emailCliente,
			cliente.direccionFisica
		from
			SICORE_CLIENTE cliente
		inner join
			SICORE_SECTOR_COMERCIAL sector on cliente.idSector = sector.idSectorComercial
		where
			sector.idSectorComercial = 1

	COMMIT
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE()
	ROLLBACK
END CATCH