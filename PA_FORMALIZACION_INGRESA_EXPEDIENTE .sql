use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Noviembre 2024
-- Description:	Toma un objeto JSON para ingresar registros en la tabla Expediente de Formalización.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_FORMALIZACION_INGRESA_EXPEDIENTE]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_FORMALIZACION_INGRESA_EXPEDIENTE]
GO

CREATE PROCEDURE [dbo].[PA_FORMALIZACION_INGRESA_EXPEDIENTE] (@pExpediente as nvarchar(max))
AS
BEGIN TRY
	BEGIN TRAN

		set @pExpediente = replace(@pExpediente, '{ pExpediente = "{', '{');
		set @pExpediente = replace(@pExpediente, '" }', '');
		
		declare @idFormalizacion varchar(10) = (select idFormalizacion from openjson (@pExpediente) with (idFormalizacion varchar(10) '$.idFormalizacion'));
		declare @formalizacion bigint = 0;
		declare @formalizacionesTemporal as table (
			indice int null,
			formalizacion int null
		);

		IF CHARINDEX(',', @idFormalizacion) > 0
		BEGIN

			insert into @formalizacionesTemporal
			select
				row_number() over (order by value),
				value
			from
				string_split(@idFormalizacion, ',')
			where
				value != ''

			declare @min int = (select min(indice) from @formalizacionesTemporal);
			declare @max int = (select max(indice) from @formalizacionesTemporal);
			while (@min <= @max)
			begin
	
				set @formalizacion = (select formalizacion from @formalizacionesTemporal where indice = @min);

				insert into SICORE_EXPEDIENTE
					select
						idProyecto,
						idCotizacion,
						@formalizacion,
						idCertificado,
						nombreArchivo,
						rutaFisicaArchivo,
						getdate(),
						getdate(),
						idFuncionario,
						null,
						null
					from
						openjson(@pExpediente)
					with
						(
							idProyecto int '$.idProyecto',
							idCotizacion int '$.idCotizacion',
							idCertificado int '$.idCertificado',
							nombreArchivo varchar(150) '$.nombreArchivo',
							rutaFisicaArchivo varchar(250) '$.rutaFisicaPDF',
							idFuncionario int '$.idFuncionario'
						)

				set @min = (select min(indice) from @formalizacionesTemporal where indice > @min);
			end;
    
		END
		ELSE
		BEGIN

			set @formalizacion = cast(@idFormalizacion as bigint);

			insert into SICORE_EXPEDIENTE
			select
				idProyecto,
				idCotizacion,
				@formalizacion,
				idCertificado,
				nombreArchivo,
				rutaFisicaArchivo,
				getdate(),
				getdate(),
				idFuncionario,
				null,
				null
			from
				openjson(@pExpediente)
			with
				(
					idProyecto int '$.idProyecto',
					idCotizacion int '$.idCotizacion',
					idCertificado int '$.idCertificado',
					nombreArchivo varchar(150) '$.nombreArchivo',
					rutaFisicaArchivo varchar(250) '$.rutaFisicaPDF',
					idFuncionario int '$.idFuncionario'
				)

		END
				
		select 1 as resultado;

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK

	select ERROR_MESSAGE() as resultado
END CATCH