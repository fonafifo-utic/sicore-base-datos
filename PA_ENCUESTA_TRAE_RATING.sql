use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Noviembre 2024
-- Description:	Trae respuestas de Rating.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_ENCUESTA_TRAE_RATING]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_ENCUESTA_TRAE_RATING]
GO

CREATE PROCEDURE [dbo].[PA_ENCUESTA_TRAE_RATING]
AS
BEGIN TRY
	BEGIN TRAN

		declare @tablaTemporalRating as table (
			pregunta varchar(255),
			valor int,
			conteo int
		)

		insert into @tablaTemporalRating
		select
			pregunta,
			valor,
			count(idReporte)
		from
			SICORE_ENCUESTA_REPORTE
		where
			tipoPregunta = 'E'
		group by
			pregunta,
			valor

		select distinct
			rating.conteo,
			rating.pregunta,
			respuesta.respuestaOpcion respuesta
		from
			@tablaTemporalRating rating
		inner join
			SICORE_ENCUESTA_RESPUESTA respuesta on rating.valor = respuesta.valorRespuesta
		
	COMMIT
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE();

	ROLLBACK TRAN
END CATCH