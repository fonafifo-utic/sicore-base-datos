use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Noviembre 2025
-- Description:	Trae las encuestas contestadas en un rango de fechas.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_REPORTES_TRAE_LISTADO_ENCUENTAS]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_REPORTES_TRAE_LISTADO_ENCUENTAS]
GO

CREATE PROCEDURE [dbo].[PA_REPORTES_TRAE_LISTADO_ENCUENTAS] (@pParametros nvarchar(max))
AS
BEGIN TRY

		declare @pfechaInicio date = (select cast(fechaInicio as date) from openjson (@pParametros) with (fechaInicio date '$.fechaInicio'));
		declare @pfechaFinal date = (select cast(fechaFin as date) from openjson (@pParametros) with (fechaFin date '$.fechaFin'));
		
		declare @idFuncionario int = (select funcionario from openjson (@pParametros) with (funcionario int '$.funcionario'));
				
		declare @fechaDesde varchar(100) = (convert(varchar, @pfechaInicio, 105));
		declare @fechaHasta varchar(100) = (convert(varchar, @pfechaFinal, 105));
		declare @rangoDefechas varchar(max) = 'Desde el: ' + @fechaDesde + ' hasta: ' + @fechaHasta;
		
		declare @temp as table (idCliente int);

		insert into @temp
			select distinct idCliente from SICORE_ENCUESTA_TRAZA where fechaHoraRespuesta is not null;

		declare @conteoTotalClientes int = (select count(idCliente) from @temp);

		select
			pregunta,
			case when valor = 0 then
				respuesta
			else
				valor
			end respuesta,
			count(respuesta) personasQueContestaron,
			@conteoTotalClientes totalEncuestados,
			cast(
				(cast
					(count(respuesta) as decimal(18,4)) /
					cast(@conteoTotalClientes as decimal(18,2))) as decimal(18,4)
			) as porcentaje
		from
			SICORE_ENCUESTA_REPORTE
		where
			respuesta != ''
		and
			pregunta not in
			(
				'Disponga de este espacio para indicar el impacto para su empresa, asociado a la compra de este producto.',
				'Disponga de este espacio para algún comentario o recomendación de mejora al servicio, o al producto.'
			)
		and
			cast(fechaHoraRespuesta as date) between @fechaDesde and @fechaHasta
		group by
			pregunta, valor, respuesta
		order by
			pregunta

END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE();
END CATCH