use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Agosto 2025
-- Description:	Trae todos los registros de la tabla Cliente por idUsuario de ventas.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_CLIENTE_TRAE_LISTADO_POR_AGENTE]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_CLIENTE_TRAE_LISTADO_POR_AGENTE]
GO

CREATE PROCEDURE [dbo].[PA_CLIENTE_TRAE_LISTADO_POR_AGENTE] (@pIdUsuario bigint)
AS
BEGIN TRY

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
		cliente.esGestor
	from
		SICORE_CLIENTE cliente
	inner join
		SICORE_SECTOR_COMERCIAL sector on cliente.idSector = sector.idSectorComercial
	where
		idUsuarioInsertoAuditoria = @pIdUsuario
	order by
		cliente.idCliente desc

END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE();
END CATCH