use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Febrero 2025
-- Description:	Trae todos los registros de un Proyecto activo.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_PROYECTO_TRAE_LISTADO_ACTIVOS]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_PROYECTO_TRAE_LISTADO_ACTIVOS]
GO

CREATE PROCEDURE [dbo].[PA_PROYECTO_TRAE_LISTADO_ACTIVOS]
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
			count(cotizacion.idCotizacion) cotizacionesAsociadas
		from
			SICORE_PROYECTO proyecto
		left outer join
			SICORE_COTIZACION cotizacion on proyecto.idProyecto = cotizacion.idProyecto
		where
			proyecto.indicadorEstado = 'A'
		group by
			proyecto.idProyecto,
			proyecto,
			ubicacionGeografica,
			periodoInicio,
			periodoFinalizacion,
			especieArboles,
			contratoPSA,
			proyecto.indicadorEstado

	COMMIT
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE()
	ROLLBACK TRANSACTION TPROCESO
END CATCH
			