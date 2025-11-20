use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Julio 2025
-- Description:	Trae información de ventas para crear un gráfico de barra en el Dashboard.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_DASHBOARD_TRAE_MONTO_VENTAS_MES]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_DASHBOARD_TRAE_MONTO_VENTAS_MES]
GO

CREATE PROCEDURE [dbo].[PA_DASHBOARD_TRAE_MONTO_VENTAS_MES]
AS
BEGIN TRY
	BEGIN TRAN

		select
			month(fechaTransferencia) mes,
			sum(montoTransferencia) montoTransferencia
		from
			SICORE_CERTIFICADO certificado
		group by
			month(fechaTransferencia)

	COMMIT
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE()
	ROLLBACK
END CATCH