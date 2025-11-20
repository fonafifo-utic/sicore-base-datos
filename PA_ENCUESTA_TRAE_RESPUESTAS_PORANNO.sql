use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Noviembre 2025
-- Description:	Trae la cantidad de respuestas por año.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_ENCUESTA_TRAE_RESPUESTAS_PORANNO]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_ENCUESTA_TRAE_RESPUESTAS_PORANNO]
GO

CREATE PROCEDURE [dbo].[PA_ENCUESTA_TRAE_RESPUESTAS_PORANNO]
AS
BEGIN TRY

	DECLARE @primerDiaDelAnno DATE = (SELECT DATEFROMPARTS(YEAR(GETDATE()), 1, 1));
	DECLARE @hoyDia DATE = (SELECT CAST(GETDATE() AS DATE));
	DECLARE @formularioRespondido DECIMAL(18,2) = (SELECT COUNT(DISTINCT idCliente) FROM SICORE_ENCUESTA_REPORTE WHERE CAST(fechaHoraRespuesta AS DATE) BETWEEN @primerDiaDelAnno AND @hoyDia);
	DECLARE @formularioEnviado DECIMAL(18,2) = (SELECT COUNT(DISTINCT idCertificado) FROM SICORE_ENCUESTA_TRAZA WHERE CAST(fechaHoraEnvio AS DATE) BETWEEN @primerDiaDelAnno AND @hoyDia);

	SELECT
		@formularioRespondido AS formulariosRespondidos,
		@formularioEnviado AS formulariosEnviados
		
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE();
END CATCH