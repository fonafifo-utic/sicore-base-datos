use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Febrero 2025
-- Description:	Trae todos los registros de un Proyecto activo.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_PROYECTO_TRAE_LISTADO_SIN_INVENTARIO]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_PROYECTO_TRAE_LISTADO_SIN_INVENTARIO]
GO

CREATE PROCEDURE [dbo].[PA_PROYECTO_TRAE_LISTADO_SIN_INVENTARIO]
AS
BEGIN TRY
	BEGIN TRAN

		select
			proyecto.idProyecto,
			dbo.FN_GET_CAMEL_CASE(proyecto) proyecto,
			'' descripcionProyecto,
			dbo.FN_GET_CAMEL_CASE(ubicacionGeografica) ubicacionGeografica,
			periodoInicio,
			periodoFinalizacion,
			especieArboles,
			contratoPSA,
			case
				when proyecto.indicadorEstado = 'A' then
					'Activo'
				when proyecto.indicadorEstado = 'I' then
					'Inactivo'
			end indicadorEstado,
			0 cotizacionesAsociadas
		from
			SICORE_PROYECTO proyecto
		where
			proyecto.indicadorEstado = 'A'
		and
			proyecto.idProyecto not in (select idProyecto from SICORE_INVENTARIO)

	COMMIT
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE()
	ROLLBACK TRANSACTION TPROCESO
END CATCH