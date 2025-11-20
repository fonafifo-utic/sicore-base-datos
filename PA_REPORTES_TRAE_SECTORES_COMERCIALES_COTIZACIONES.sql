use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Junio 2025
-- Description:	Trae todos los sectores comerciales por un rango de fechas.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_REPORTES_TRAE_SECTORES_COMERCIALES_COTIZACIONES]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_REPORTES_TRAE_SECTORES_COMERCIALES_COTIZACIONES]
GO

CREATE PROCEDURE [dbo].[PA_REPORTES_TRAE_SECTORES_COMERCIALES_COTIZACIONES] (@pParametros nvarchar(max))
AS
BEGIN TRY
	BEGIN TRAN

		declare @pfechaInicio date = (select cast(fechaInicio as date) from openjson (@pParametros) with (fechaInicio date '$.fechaInicio'));
		declare @pfechaFinal date = (select cast(fechaFin as date) from openjson (@pParametros) with (fechaFin date '$.fechaFin'));

		select distinct
			sector.idSectorComercial idSector,
			sector.sectorComercial sector
		from
			SICORE_SECTOR_COMERCIAL sector
		inner join
			SICORE_CLIENTE cliente on sector.idSectorComercial = cliente.idCliente
		inner join
			SICORE_COTIZACION cotizacion on cliente.idCliente = cotizacion.idCliente
		where
			cast(cotizacion.fechaHora as date) between @pfechaInicio and @pfechaFinal
	
	COMMIT
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE()
	ROLLBACK
END CATCH