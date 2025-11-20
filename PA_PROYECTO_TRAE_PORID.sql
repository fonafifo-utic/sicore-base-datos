use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Agosto 2024
-- Description:	Trae los registros de un Proyecto filtrados por ID.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_PROYECTO_TRAE_PORID]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_PROYECTO_TRAE_PORID]
GO

CREATE PROCEDURE [dbo].[PA_PROYECTO_TRAE_PORID] (@pIdProyecto as int)
AS
BEGIN TRY
	BEGIN TRANSACTION
		
		select
			idProyecto,
			dbo.FN_GET_CAMEL_CASE(proyecto) proyecto,
			'' descripcionProyecto,
			dbo.FN_GET_CAMEL_CASE(ubicacionGeografica) ubicacionGeografica,
			periodoInicio,
			periodoFinalizacion,
			especieArboles,
			contratoPSA,
			case
				when indicadorEstado = 'A' then
					'Activo'
				when indicadorEstado = 'I' then
					'Inactivo'
			end indicadorEstado,
			0 cotizacionesAsociadas
		from
			SICORE_PROYECTO
		where
			idProyecto = @pIdProyecto
	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK
END CATCH