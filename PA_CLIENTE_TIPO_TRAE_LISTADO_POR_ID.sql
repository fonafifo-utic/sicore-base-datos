use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Septiembre 2024
-- Description:	Trae todos los registros de los tipos de empresa filtrados por el ID del sector.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_CLIENTE_TIPO_TRAE_LISTADO_POR_ID]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_CLIENTE_TIPO_TRAE_LISTADO_POR_ID]
GO

CREATE PROCEDURE [dbo].[PA_CLIENTE_TIPO_TRAE_LISTADO_POR_ID] (@pIdSector bigint)
AS
BEGIN TRY
	BEGIN TRAN

		select
			idTipoEmpresa,
			idSector,
			tipoEmpresa
		from
			SICORE_TIPO_EMPRESA
		where
			idSector = @pIdSector;

	COMMIT
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE()
	ROLLBACK TRANSACTION TPROCESO
END CATCH