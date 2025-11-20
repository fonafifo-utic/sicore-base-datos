use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Noviembre 2024
-- Description:	Toma un objeto JSON para ingresar registros en la tabla Expediente de Formalización.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_CERTIFICADO_INGRESA_EXPEDIENTE]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_CERTIFICADO_INGRESA_EXPEDIENTE]
GO

CREATE PROCEDURE [dbo].[PA_CERTIFICADO_INGRESA_EXPEDIENTE] (@pExpediente as nvarchar(max))
AS
BEGIN TRY
	BEGIN TRAN

		set @pExpediente = replace(@pExpediente, '{ pExpediente = "{', '{');
		set @pExpediente = replace(@pExpediente, '" }', '');
				
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