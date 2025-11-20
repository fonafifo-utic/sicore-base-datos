use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Setiembre 2024
-- Description:	Trae todos los registros de la tabla Cliente filtrados por ID del sector comercial.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_CLIENTE_TRAE_CLIENTE_POR_IDSECTOR]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_CLIENTE_TRAE_CLIENTE_POR_IDSECTOR]
GO

CREATE PROCEDURE [dbo].[PA_CLIENTE_TRAE_CLIENTE_POR_IDSECTOR] (@pIdSector bigint)
AS
BEGIN TRY
	BEGIN TRAN

		select
			cliente.idCliente,
			cliente.idSector,
			sector.sectorComercial,
			dbo.FN_GET_CAMEL_CASE(cliente.nombreCliente) nombreCliente,
			cliente.cedulaCliente,
			dbo.FN_GET_CAMEL_CASE(cliente.contactoCliente) contactoCliente,
			cliente.telefonoCliente,
			lower(cliente.emailCliente) emailCliente,
			cliente.direccionFisica,
			cliente.esGestor
		from
			SICORE_CLIENTE cliente
		inner join
			SICORE_SECTOR_COMERCIAL sector on cliente.idSector = sector.idSectorComercial
		where
			sector.idSectorComercial = @pIdSector
		and
			cliente.indicadorEstado = 'A';

	COMMIT
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE()
	ROLLBACK
END CATCH