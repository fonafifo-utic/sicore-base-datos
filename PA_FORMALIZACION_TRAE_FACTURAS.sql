use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Febrero 2025
-- Description:	Trae todos los números de factura y comprobantes formalizados.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_FORMALIZACION_TRAE_FACTURAS]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_FORMALIZACION_TRAE_FACTURAS]
GO

CREATE PROCEDURE [dbo].[PA_FORMALIZACION_TRAE_FACTURAS]
AS
BEGIN TRY
	BEGIN TRAN

		select
			numeroFacturaFonafifo
		from
			SICORE_FORMALIZACION
		where 
			numeroFacturaFonafifo != ''
		and
			year(fechaHora) = year(getdate())

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK

	select ERROR_MESSAGE() as resultado
END CATCH