use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Febrero 2025
-- Description:	Toma un objeto JSON para actualizar los registros en la tabla Expediente de Formalización.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_FORMALIZACION_ACTUALIZA_EXPEDIENTE]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_FORMALIZACION_ACTUALIZA_EXPEDIENTE]
GO

CREATE PROCEDURE [dbo].[PA_FORMALIZACION_ACTUALIZA_EXPEDIENTE] (@pExpediente as nvarchar(max))
AS
BEGIN TRY
	BEGIN TRAN

		set @pExpediente = replace(@pExpediente, '{ pExpediente = "{', '{');
		set @pExpediente = replace(@pExpediente, '" }', '');

		declare @idFormalizacion int = (select idFormalizacion from openjson(@pExpediente) with (idFormalizacion int '$.idFormalizacion'));

		if(exists(select 1 from SICORE_EXPEDIENTE where idFormalizacion = @idFormalizacion and idCertificado = 0 and idCotizacion = 0 and idProyecto = 0))
		begin

			declare @nombreArchivo varchar(150) = (select nombreArchivo from openjson(@pExpediente) with (nombreArchivo varchar(150) '$.nombreArchivo'));

			delete from SICORE_EXPEDIENTE
			where idFormalizacion = @idFormalizacion
			and nombreArchivo = @nombreArchivo
			and idCertificado = 0
			and idCotizacion = 0
			and idProyecto = 0

		end

		insert into SICORE_EXPEDIENTE
			select
				idProyecto,
				idCotizacion,
				idFormalizacion,
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
					idFormalizacion int '$.idFormalizacion',
					idCertificado int '$.idCertificado',
					nombreArchivo varchar(150) '$.nombreArchivo',
					rutaFisicaArchivo varchar(250) '$.rutaFisicaPDF',
					idFuncionario int '$.idFuncionario'
				)

		select 1 as resultado;

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK

	select ERROR_MESSAGE() as resultado
END CATCH