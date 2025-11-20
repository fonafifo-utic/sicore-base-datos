use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Enero 2025
-- Description:	Toma un objeto JSON para ingresar registros en la tabla Expediente de Proyecto.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_PROYECTO_INGRESA_EXPEDIENTE]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_PROYECTO_INGRESA_EXPEDIENTE]
GO

CREATE PROCEDURE [dbo].[PA_PROYECTO_INGRESA_EXPEDIENTE] (@pExpediente as nvarchar(max))
AS
BEGIN TRY
	BEGIN TRAN

		set @pExpediente = replace(@pExpediente, '{ pExpediente = "{', '{');
		set @pExpediente = replace(@pExpediente, '" }', '');

		declare @idProyecto bigint = (select idProyecto from openjson(@pExpediente) with (idProyecto bigint '$.idProyecto'));

		if(exists((select 1 from SICORE_EXPEDIENTE where idProyecto = @idProyecto)))
		begin
			delete from
				SICORE_EXPEDIENTE
			where
				idProyecto = @idProyecto
			and
				idCotizacion = 0
			and
				idFormalizacion = 0
			and
				idCertificado = 0;
		end

		insert into SICORE_EXPEDIENTE
		select
			idProyecto,
			0,
			0,
			0,
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