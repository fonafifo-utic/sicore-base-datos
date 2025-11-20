use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Julio 2024
-- Description:	Trae todos los registros de Perfil.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_PERFIL_TRAE_LISTADO]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_PERFIL_TRAE_LISTADO]
GO

CREATE PROCEDURE [dbo].[PA_PERFIL_TRAE_LISTADO]
AS
BEGIN TRY
	BEGIN TRAN

		select
			idPerfil,
			nombre,
			descripcion
		from
			SICORE_PERFIL

	COMMIT
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE()
	ROLLBACK TRAN
END CATCH