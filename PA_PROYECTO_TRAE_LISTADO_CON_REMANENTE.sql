use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Septiembre 2024
-- Description:	Trae todos los registros de un Proyecto cuando este tiene remanente de inventario.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_PROYECTO_TRAE_LISTADO_CON_REMANENTE]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_PROYECTO_TRAE_LISTADO_CON_REMANENTE]
GO

CREATE PROCEDURE [dbo].[PA_PROYECTO_TRAE_LISTADO_CON_REMANENTE]
AS
BEGIN TRY
	BEGIN TRAN

		select
			proyecto.idProyecto,
			dbo.FN_GET_CAMEL_CASE(proyecto.proyecto) proyecto,
			proyecto.descripcionProyecto,
			dbo.FN_GET_CAMEL_CASE(proyecto.ubicacionGeografica) ubicacionGeografica
		from
			SICORE_PROYECTO proyecto
		inner join
			SICORE_INVENTARIO inventario on proyecto.idProyecto = inventario.idProyecto
		where
			inventario.remanente > 0

	COMMIT
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE()
	ROLLBACK TRANSACTION TPROCESO
END CATCH