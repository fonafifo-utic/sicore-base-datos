use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Setiembre 2024
-- Description:	Trae todos los registros de la tabla Cliente por ID.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_CLIENTE_TRAE_PORID]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_CLIENTE_TRAE_PORID]
GO

CREATE PROCEDURE [dbo].[PA_CLIENTE_TRAE_PORID] (@pIdCliente as int)
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
			dbo.FN_GET_CAMEL_CASE(cliente.direccionFisica) direccionFisica,
			cliente.clasificacion,
			case
				when cliente.indicadorEstado = 'A' then
					'Activo'
				when cliente.indicadorEstado = 'I' then
					'Inactivo'
			end indicadorEstado,
			dbo.FN_GET_CAMEL_CASE(contactoContador) contactoContador,
			dbo.FN_GET_CAMEL_CASE(emailContador) emailContador,
			esGestor,
			idAgenteCuenta idAgente,
			ucii
		from
			SICORE_CLIENTE cliente
		inner join
			SICORE_SECTOR_COMERCIAL sector on cliente.idSector = sector.idSectorComercial
		where
			cliente.idCliente = @pIdCliente


	COMMIT
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE()
	ROLLBACK
END CATCH