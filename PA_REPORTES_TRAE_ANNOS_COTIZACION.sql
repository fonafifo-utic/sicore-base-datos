use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Abril 2025
-- Description:	Trae todos los años que corresponde a las cotizaciones hechas.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_REPORTES_TRAE_ANNOS_COTIZACION]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_REPORTES_TRAE_ANNOS_COTIZACION]
GO

CREATE PROCEDURE [dbo].[PA_REPORTES_TRAE_ANNOS_COTIZACION]
AS
BEGIN TRY
	BEGIN TRAN

		select distinct
			year(fechaHora) anno
		from	
			SICORE_COTIZACION
	
	COMMIT
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE()
	ROLLBACK
END CATCH