use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Julio 2024
-- Description:	Trae todos los registros de Inventario.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_INVENTARIO_TRAE_LISTADO]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_INVENTARIO_TRAE_LISTADO]
GO

CREATE PROCEDURE [dbo].[PA_INVENTARIO_TRAE_LISTADO]
AS
BEGIN TRY
	BEGIN TRAN

	declare @periodo int = year(getdate());

	select
		inventario.idInventario,
		proyecto.idProyecto,
		dbo.FN_GET_CAMEL_CASE(proyecto.proyecto) proyecto,
		dbo.FN_GET_CAMEL_CASE(proyecto.ubicacionGeografica) ubicacionGeografica,
		inventario.remanente,
		inventario.vendido,
		inventario.comprometido
	from
		SICORE_PROYECTO proyecto
	inner join
		SICORE_INVENTARIO inventario on proyecto.idProyecto = inventario.idProyecto
	where
		inventario.periodo = @periodo

	COMMIT
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE()
	ROLLBACK TRANSACTION TPROCESO
END CATCH