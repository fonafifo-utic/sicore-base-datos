use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Enero 2025
-- Description:	Trae información un cuadro resumen de totales de inventario.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_DASHBOARD_TRAE_RESUMEN_REMANENTE]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_DASHBOARD_TRAE_RESUMEN_REMANENTE]
GO

CREATE PROCEDURE [dbo].[PA_DASHBOARD_TRAE_RESUMEN_REMANENTE]
AS
BEGIN TRY
	BEGIN TRAN

		select
			resultados.proyecto,
			resultados.remanente,
			resultados.utilizado,
			resultados.montoDolares
		from
			(select
				proyecto.proyecto,
				entrada.remanente - (isnull(salida.remanente, 0)) remanente,
				inventario.remanente - comprometido utilizado,
				isnull(plata.montoDolares, 0) montoDolares
			from
				SICORE_INVENTARIO inventario
			inner join
				SICORE_PROYECTO proyecto on inventario.idProyecto = proyecto.idProyecto
			inner join
				(select
					sum(cantidad) remanente,
					idProyecto
				from
					SICORE_MOVIMIENTO_INVENTARIO
				where
					tipoMovimiento in ('E', 'I')
				group by
					idProyecto) as entrada on entrada.idProyecto = inventario.idProyecto
			left outer join
				(select
					sum(cantidad) remanente,
					idProyecto
				from
					SICORE_MOVIMIENTO_INVENTARIO
				where
					tipoMovimiento = 'D'
				group by
					idProyecto) as salida on salida.idProyecto = inventario.idProyecto
			left outer join
				(select
					sum(montoTotalDolares) montoDolares,
					idProyecto
				from
					SICORE_COTIZACION
				where
					(indicadorEstado = 'F' or indicadorEstado = 'A')
				group by
					idProyecto) as plata on plata.idProyecto = inventario.idProyecto) as resultados
		where
			resultados.remanente != 0

	COMMIT
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE()
	ROLLBACK
END CATCH