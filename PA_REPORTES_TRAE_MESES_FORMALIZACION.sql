use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Abril 2025
-- Description:	Trae todos los meses que corresponde a las formalización hechas.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_REPORTES_TRAE_MESES_FORMALIZACION]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_REPORTES_TRAE_MESES_FORMALIZACION]
GO

CREATE PROCEDURE [dbo].[PA_REPORTES_TRAE_MESES_FORMALIZACION]
AS
BEGIN TRY
	BEGIN TRAN

		select distinct
			month(fechaHora) valor,
			case
				when month(fechaHora) = 1 then
					'Enero'
				when month(fechaHora) = 2 then
					'Febrero'
				when month(fechaHora) = 3 then
					'Marzo'
				when month(fechaHora) = 4 then
					'Abril'
				when month(fechaHora) = 5 then
					'Mayo'
				when month(fechaHora) = 6 then
					'Junio'
				when month(fechaHora) = 7 then
					'Julio'
				when month(fechaHora) = 8 then
					'Agosto'
				when month(fechaHora) = 9 then
					'Septiembre'
				when month(fechaHora) = 10 then
					'Octubre'
				when month(fechaHora) = 11 then
					'Noviembre'
				when month(fechaHora) = 12 then
					'Diciembre'
			end mes
		from	
			SICORE_FORMALIZACION
		where
			year(fechaHora) = year(getdate());
	
	COMMIT
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE()
	ROLLBACK
END CATCH