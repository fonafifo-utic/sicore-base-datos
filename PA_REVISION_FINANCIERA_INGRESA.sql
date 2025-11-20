use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Julio 2024
-- Description:	Toma un objeto JSON para ingresar registros en Revisión Financiera.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_REVISION_FINANCIERA_INGRESA]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_REVISION_FINANCIERA_INGRESA]
GO

CREATE PROCEDURE [dbo].[PA_REVISION_FINANCIERA_INGRESA] (@pRevisionFinanciera as nvarchar(max))
AS
BEGIN TRY
	BEGIN TRAN

		insert into SICORE_REVISION_FINANCIERA
			select	
				idCotizacion,
				idPago,
				fechaPago,
				idRecibo,
				fechaRecibo,
				estado,
				null,
				null,
				null,
				null
			from
				openjson(@pRevisionFinanciera)
			with
				(
					idCotizacion int '$.IdCotizacion',
					idPago int '$.IdPago',
					fechaPago date '$.FechaPago',
					idRecibo int '$.IdRecibo',
					fechaRecibo date '$.FechaRecibo',
					estado char(1) '$.Estado'
				)

		select 1 as resultado;

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK

	select ERROR_MESSAGE() as resultado
END CATCH