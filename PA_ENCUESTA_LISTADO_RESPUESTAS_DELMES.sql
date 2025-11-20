use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Abril 2025
-- Description:	Trae un listado de respuestas de la encuesta enviada.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_ENCUESTA_LISTADO_RESPUESTAS_DELMES]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_ENCUESTA_LISTADO_RESPUESTAS_DELMES]
GO

CREATE PROCEDURE [dbo].[PA_ENCUESTA_LISTADO_RESPUESTAS_DELMES]
AS
BEGIN TRY
	BEGIN TRAN

		declare @fechaActual date = cast(getdate() as date);
		declare @inicioMes date = (select dateadd(month, datediff(month, 0, @fechaActual), 0));
		declare @finMes date = (select dateadd(d, -1, dateadd(m, datediff(m, 0, @fechaActual) + 1, 0)));

		select
			reporte.idReporte,
			dbo.FN_GET_CAMEL_CASE(cliente.nombreCliente) nombreCliente,
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
			convert(varchar(5), reporte.fechaHoraRespuesta, 108) hora,
			certificado.numeroCertificado
		from
			SICORE_ENCUESTA_REPORTE reporte
		inner join
			SICORE_CLIENTE cliente on reporte.idCliente = cliente.idCliente
		inner join
			SICORE_COTIZACION cotizacion on reporte.idCliente = cotizacion.idCliente
		inner join
			SICORE_CERTIFICADO certificado on cotizacion.idCotizacion = certificado.idCotizacion
		where
			cast(reporte.fechaHoraRespuesta as date) between @inicioMes and @finMes
		order by
			fecha desc
		
	COMMIT
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE();

	ROLLBACK TRAN
END CATCH