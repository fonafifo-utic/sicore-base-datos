use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Abril 2025
-- Description:	Trae todos los meses que corresponde a las certificaciones hechas.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_REPORTES_TRAE_MESES_CERTIFICADO]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_REPORTES_TRAE_MESES_CERTIFICADO]
GO

CREATE PROCEDURE [dbo].[PA_REPORTES_TRAE_MESES_CERTIFICADO]
AS
BEGIN TRY
	BEGIN TRAN

		select distinct
			month(fechaEmisionCertificado) valor,
			case
				when month(fechaEmisionCertificado) = 1 then
					'Enero'
				when month(fechaEmisionCertificado) = 2 then
					'Febrero'
				when month(fechaEmisionCertificado) = 3 then
					'Marzo'
				when month(fechaEmisionCertificado) = 4 then
					'Abril'
				when month(fechaEmisionCertificado) = 5 then
					'Mayo'
				when month(fechaEmisionCertificado) = 6 then
					'Junio'
				when month(fechaEmisionCertificado) = 7 then
					'Julio'
				when month(fechaEmisionCertificado) = 8 then
					'Agosto'
				when month(fechaEmisionCertificado) = 9 then
					'Septiembre'
				when month(fechaEmisionCertificado) = 10 then
					'Octubre'
				when month(fechaEmisionCertificado) = 11 then
					'Noviembre'
				when month(fechaEmisionCertificado) = 12 then
					'Diciembre'
			end mes
		from	
			SICORE_CERTIFICADO
		where
			year(fechaEmisionCertificado) = year(getdate());
	
	COMMIT
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE()
	ROLLBACK
END CATCH