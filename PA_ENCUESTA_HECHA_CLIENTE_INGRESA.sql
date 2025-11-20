USE [SICORE]
GO

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Noviembre 2024
-- Description:	Toma un objeto JSON para ingresar una encuesta.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_ENCUESTA_HECHA_CLIENTE_INGRESA]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_ENCUESTA_HECHA_CLIENTE_INGRESA]
GO

CREATE PROCEDURE [dbo].[PA_ENCUESTA_HECHA_CLIENTE_INGRESA] (@pEncuesta as nvarchar(max))
AS
BEGIN TRY
	BEGIN TRAN
	
		set @pEncuesta = replace(@pEncuesta, '{ pEncuesta = "[{', '[{');
		set @pEncuesta = replace(@pEncuesta, '" }', '');

		declare @min int = (select min([key]) from openjson(@pEncuesta))
		declare @max int = (select max([key]) from openjson(@pEncuesta))

		while(@min <= @max)
		begin
			declare @valor nvarchar(max) = (select [value] from openjson(@pEncuesta) where [key] = @min);

			declare @idCliente int = (select idCliente from openjson(@valor) with (idCliente int '$.idCliente'));
			declare @pregunta varchar(255) = (select pregunta from openjson(@valor) with (pregunta varchar(255) '$.pregunta'));
			declare @respuesta varchar(255) = (select respuesta from openjson(@valor) with (respuesta varchar(255) '$.respuesta'));
			declare @pesoRespuesta int = (select valor from openjson(@valor) with (valor int '$.valor'));
			declare @fechaHora datetime = getdate();
			declare @tipoPregunta char(1) = (select tipoPregunta from openjson(@valor) with (tipoPregunta char(1) '$.tipoPregunta'));
			declare @nombreCliente varchar(250) = (select nombreCliente from SICORE_CLIENTE where idCliente = @idCliente);
			
			insert into SICORE_ENCUESTA_REPORTE
				select
					@idCliente,
					@pregunta,
					@respuesta,
					@pesoRespuesta,
					@fechaHora,
					@tipoPregunta
	
			set @min = (select min([key]) from openjson(@pEncuesta) where [key] > @min);
		end

		declare @idCertificado int = (select top 1 idCertificado from SICORE_ENCUESTA_TRAZA where idCliente = @idCliente order by fechaHoraEnvio desc);

		update SICORE_ENCUESTA_TRAZA
		set
			fechaHoraRespuesta = @fechaHora
		where
			idCliente = @idCliente
		and
			idCertificado = @idCertificado;

		declare @cuerpoCorreo nvarchar(max) = '<div style="font-family: Arial, sans-serif; margin: 0; padding: 0; background-color: #f4f4f4;"><div style="max-width: 600px; margin: 0 auto; padding: 0px 20px 20px; background-color: #ffffff; box-shadow: 0px 4px 6px #ccc;"><div style="display: flex; align-items: center;"><img src="http://sipsa.fonafifo.com/PPSA/Imagenes/Banners/Logo-Banco-Color.jpg" width="20%" height="auto" style="margin-right: 20px;"><h2 style="color: #333; margin:38px 0 20px 0;font-size:18px">Notificación de SICORE</h2></div><p style="color: #666;">Una encuesta ha sido contestada por parte de: '+ @nombreCliente +'</p><hr></div></div>';

		set @cuerpoCorreo = trim(@cuerpoCorreo);

		insert into SCGI..SIST_COLA_ENVIO_CORREO
		values
		(
			CURRENT_TIMESTAMP,
			CURRENT_TIMESTAMP,
			'silvia.zuniga@fonafifo.go.cr',
			'P',
			'0',
			'Notificación de SICORE',
			@cuerpoCorreo,
			'1',
			CURRENT_TIMESTAMP,
			78834,
			CURRENT_TIMESTAMP,
			78834
		);
		
		select 1 as resultado

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK

	select ERROR_MESSAGE() as resultado
END CATCH