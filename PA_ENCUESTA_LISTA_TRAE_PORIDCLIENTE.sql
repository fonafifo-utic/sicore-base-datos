use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Noviembre 2024
-- Description:	Trae encuesta dispuesta para ese cliente.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_ENCUESTA_LISTA_TRAE_PORIDCLIENTE]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_ENCUESTA_LISTA_TRAE_PORIDCLIENTE]
GO

CREATE PROCEDURE [dbo].[PA_ENCUESTA_LISTA_TRAE_PORIDCLIENTE] (@pIdCliente bigint)
AS
BEGIN TRY

	declare @fechaEnviado date = (select cast(fechaHoraRespuesta as date) from SICORE_ENCUESTA_REPORTE where idCliente = @pIdCliente);
	declare @hoyEnDia date = cast(getdate() as date);
	declare @cantidadDiasPasados int = datediff(day, @fechaEnviado, @hoyEnDia);

	if(@cantidadDiasPasados > 40 OR @fechaEnviado is null)
	begin
		select
			pregunta.idPregunta,
			respuesta.idRespuesta,
			pregunta.tipoPregunta,
			pregunta.pregunta,
			respuesta.respuestaOpcion,
			respuesta.valorRespuesta
		from
			SICORE_ENCUESTA encuesta
		inner join
			SICORE_ENCUESTA_PREGUNTA pregunta on encuesta.idPregunta = pregunta.idPregunta
		left outer join
			SICORE_ENCUESTA_RESPUESTA respuesta on pregunta.idPregunta = respuesta.idPregunta
		order by
			encuesta.idEncuesta
	end
	else begin
		select
			0 idPregunta,
			0 idRespuesta,
			'' tipoPregunta,
			'' pregunta,
			'' respuestaOpcion,
			'' valorRespuesta
	end

END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE()
	ROLLBACK
END CATCH