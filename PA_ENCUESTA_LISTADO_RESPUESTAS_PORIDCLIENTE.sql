use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Abril 2025
-- Description:	Trae un listado de respuestas de un encuesta enviada.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_ENCUESTA_LISTADO_RESPUESTAS_PORIDCLIENTE]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_ENCUESTA_LISTADO_RESPUESTAS_PORIDCLIENTE]
GO

CREATE PROCEDURE [dbo].[PA_ENCUESTA_LISTADO_RESPUESTAS_PORIDCLIENTE] (@pIdCliente int)
AS
BEGIN TRY
	BEGIN TRAN

		select
			reporte.idReporte,
			reporte.pregunta,
			case
				when reporte.tipoPregunta = 'E' then
					reporte.valor
				when reporte.tipoPregunta = 'S' then
					reporte.respuesta
				when reporte.tipoPregunta = 'A' then
					reporte.respuesta
			end respuesta,
			cast(reporte.fechaHoraRespuesta as date) fecha,
			convert(varchar(5), reporte.fechaHoraRespuesta, 108) hora
		from
			SICORE_ENCUESTA_REPORTE reporte
		where
			reporte.idCliente = @pIdCliente
		and
			reporte.fechaHoraRespuesta in (select traza.fechaHoraRespuesta from SICORE_ENCUESTA_TRAZA traza where idCliente = @pIdCliente)

	COMMIT
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE();

	ROLLBACK TRAN
END CATCH