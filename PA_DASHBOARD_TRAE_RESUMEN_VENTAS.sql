use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Enero 2025
-- Description:	Trae información un cuadro resumen de ventas para poner en el Dashboard.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_DASHBOARD_TRAE_RESUMEN_VENTAS]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_DASHBOARD_TRAE_RESUMEN_VENTAS]
GO

CREATE PROCEDURE [dbo].[PA_DASHBOARD_TRAE_RESUMEN_VENTAS]
AS
BEGIN TRY
	BEGIN TRAN

		select
			resultados.idProyecto,
			resultados.proyecto,
			resultados.vendido,
			resultados.remanente
		from (
			select
				proyecto.idProyecto,
				proyecto.proyecto,
				inventario.vendido vendido,
				movimiento.remanente - (isnull(salida.remanente, 0)) remanente
			from
				SICORE_PROYECTO proyecto
			inner join
				SICORE_INVENTARIO inventario on proyecto.idProyecto = inventario.idProyecto
			inner join
				(select
					sum(cantidad) remanente,
					idProyecto
				from
					SICORE_MOVIMIENTO_INVENTARIO
				where
					tipoMovimiento in ('E', 'I')
				group by
					idProyecto) as movimiento on proyecto.idProyecto = movimiento.idProyecto
			left outer join
				(select
					sum(cantidad) remanente,
					idProyecto
				from
					SICORE_MOVIMIENTO_INVENTARIO
				where
					tipoMovimiento = 'D'
				group by
					idProyecto) as salida on salida.idProyecto = inventario.idProyecto) as resultados
		where
			resultados.remanente != 0

	COMMIT
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE()
	ROLLBACK
END CATCH