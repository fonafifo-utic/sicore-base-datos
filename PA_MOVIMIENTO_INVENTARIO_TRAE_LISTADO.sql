use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Agosto 2024
-- Description:	Trae todos los registros de movimientos de inventario.
-- Modificación: Marzo 2025
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_MOVIMIENTO_INVENTARIO_TRAE_LISTADO]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_MOVIMIENTO_INVENTARIO_TRAE_LISTADO]
GO

CREATE PROCEDURE [dbo].[PA_MOVIMIENTO_INVENTARIO_TRAE_LISTADO] (@pIdProyecto bigint)
AS
BEGIN TRY
	BEGIN TRAN

		--declare @saldoInicial decimal(18,2) = (
		--								select cantidad
		--								from SICORE_MOVIMIENTO_INVENTARIO
		--								where year(fechaMovimiento) = year(getdate())
		--								and tipoMovimiento = 'E'
		--								and idProyecto = @pIdProyecto
		--								);

		select
			movimiento.idMovimiento,
			movimiento.idProyecto,
			proyecto.proyecto,
			proyecto.ubicacionGeografica,
			movimiento.idUsuario,
			persona.nombre + ' ' + persona.primerApellido + ' ' + persona.segundoApellido usuario,
			movimiento.remanenteReal saldoInicial,
			movimiento.fechaMovimiento,
			movimiento.cantidad,
			case
				when movimiento.tipoMovimiento = 'E' then 'Entrada'
				when movimiento.tipoMovimiento = 'C' then 'Cotización'
				when movimiento.tipoMovimiento = 'V' then 'Venta'
				when movimiento.tipoMovimiento = 'D' then 'Devolución'
				when movimiento.tipoMovimiento = 'A' then 'Anulación'
				when movimiento.tipoMovimiento = 'M' then 'Modificación'
				when movimiento.tipoMovimiento = 'I' then 'Aumento'
			end tipoMovimiento,
			movimiento.descripcionMovimiento,
			inventario.comprometido,
			movimiento.remanenteVirtual remanente,
			movimiento.remanenteReal
		from
			SICORE_PROYECTO proyecto
		inner join
			SICORE_INVENTARIO inventario on proyecto.idProyecto = inventario.idProyecto
		inner join
			SICORE_MOVIMIENTO_INVENTARIO movimiento on inventario.idProyecto = movimiento.idProyecto
		inner join
			[SCGI].[dbo].[SIST_USUARIO] usuarios on movimiento.idUsuario = usuarios.idUsuario
		inner join
			[SCGI].[dbo].[SIST_PERSONA] persona on usuarios.idPersona = persona.idPersona
		where
			--year(movimiento.fechaMovimiento) = year(getdate())
		--and
			--inventario.periodo = year(getdate())
		--and
			proyecto.idProyecto = @pIdProyecto
		order by
			movimiento.idMovimiento desc

	COMMIT
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE()
	ROLLBACK
END CATCH