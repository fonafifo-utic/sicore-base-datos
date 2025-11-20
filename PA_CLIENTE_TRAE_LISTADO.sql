use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Agosto 2024
-- Description:	Trae todos los registros de la tabla Cliente.
-- Modificación: Marzo 2025.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_CLIENTE_TRAE_LISTADO]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_CLIENTE_TRAE_LISTADO]
GO

CREATE PROCEDURE [dbo].[PA_CLIENTE_TRAE_LISTADO]
AS
BEGIN TRY
	BEGIN TRAN

		select
			cliente.idCliente,
			cliente.idSector,
			sector.sectorComercial,
			dbo.FN_GET_CAMEL_CASE(cliente.nombreCliente) nombreCliente,
			dbo.FN_GET_CAMEL_CASE(cliente.nombreComercial) nombreComercial,
			cliente.cedulaCliente,
			dbo.FN_GET_CAMEL_CASE(cliente.contactoCliente) contactoCliente,
			cliente.telefonoCliente,
			lower(cliente.emailCliente) emailCliente,
			cliente.direccionFisica,
			cliente.clasificacion,
			case
				when cliente.indicadorEstado = 'A' then
					'Activo'
				when cliente.indicadorEstado = 'I' then
					'Inactivo'
			end indicadorEstado,
			(select count(idCotizacion) from SICORE_COTIZACION cotizacion where cotizacion.idCliente = cliente.idCliente) cotizacionesAsociadas,
			cliente.contactoContador,
			cliente.emailContador,
			cliente.esGestor,
			idAgenteCuenta idAgente,
			ucii
		from
			SICORE_CLIENTE cliente
		inner join
			SICORE_SECTOR_COMERCIAL sector on cliente.idSector = sector.idSectorComercial
		order by
			cliente.idCliente desc

	COMMIT
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE()
	ROLLBACK
END CATCH