use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Agosto 2024
-- Description:	Trae información de proyección de los proyectos para ponerlos en el dashboard.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_DASHBOARD_TRAE_INFO_PROYECTOS]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_DASHBOARD_TRAE_INFO_PROYECTOS]
GO

CREATE PROCEDURE [dbo].[PA_DASHBOARD_TRAE_INFO_PROYECTOS]
AS
BEGIN TRY
	BEGIN TRAN

		select
			resultados.proyecto,
			resultados.vendido,
			resultados.comprometido
		from
			(select
				proyecto.proyecto,
				inventario.vendido,
				(((entrada.remanente - isnull(devolucion.remanente, 0) - inventario.comprometido) - inventario.vendido)) comprometido
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
					idProyecto) as entrada on proyecto.idProyecto = entrada.idProyecto
			left outer join
				(select
					sum(cantidad) remanente,
					idProyecto
				from
					SICORE_MOVIMIENTO_INVENTARIO
				where
					tipoMovimiento in ('D')
				group by
					idProyecto) as devolucion on devolucion.idProyecto = proyecto.idProyecto) as resultados
		--where
			--resultados.comprometido != 0

	COMMIT
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE()
	ROLLBACK
END CATCH