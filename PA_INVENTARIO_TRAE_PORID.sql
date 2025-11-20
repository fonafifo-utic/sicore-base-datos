use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Julio 2024
-- Description:	Trae los registros de Inventario filtrados por ID.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_INVENTARIO_TRAE_PORID]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_INVENTARIO_TRAE_PORID]
GO

CREATE PROCEDURE [dbo].[PA_INVENTARIO_TRAE_PORID] (@pIdInventario as int)
AS
BEGIN TRY
	BEGIN TRANSACTION
		
		select
			inventario.idInventario,
			inventario.remanente,
			inventario.comprometido,
			proyecto.idProyecto,
			proyecto.proyecto
		from
			SICORE_INVENTARIO inventario
		inner join
			SICORE_PROYECTO proyecto on inventario.idProyecto = proyecto.idProyecto
		where
			inventario.idInventario = @pIdInventario

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK
END CATCH