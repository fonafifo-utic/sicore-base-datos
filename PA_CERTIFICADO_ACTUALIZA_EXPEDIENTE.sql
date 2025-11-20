use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Febrero 2025
-- Description:	Toma un objeto JSON para actualizar los registros en la tabla Expediente de SICORE.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_CERTIFICADO_ACTUALIZA_EXPEDIENTE]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_CERTIFICADO_ACTUALIZA_EXPEDIENTE]
GO

CREATE PROCEDURE [dbo].[PA_CERTIFICADO_ACTUALIZA_EXPEDIENTE] (@pExpediente as nvarchar(max))
AS
BEGIN TRY
	BEGIN TRAN

		set @pExpediente = replace(@pExpediente, '{ pExpediente = "{', '{');
		set @pExpediente = replace(@pExpediente, '" }', '');

		declare @nombreArchivo varchar(150) = (select nombreArchivo from openjson(@pExpediente) with (nombreArchivo varchar(150) '$.nombreArchivo'));

		if(exists(select 1 from SICORE_EXPEDIENTE where idProyecto = 1 and idCotizacion = 1 and idFormalizacion = 1 and idCertificado = 1 and nombreArchivo = @nombreArchivo))
		begin

			declare @idFormalizacion int = (select idFormalizacion from openjson(@pExpediente) with (idFormalizacion int '$.idFormalizacion'));
			declare @rutaFisicaArchivo varchar(250) = (select rutaFisicaArchivo from openjson(@pExpediente) with (rutaFisicaArchivo varchar(250) '$.rutaFisicaPDF'));
			declare @idFuncionario int = (select idFuncionario from openjson(@pExpediente) with (idFuncionario int '$.idFuncionario'));

			update SICORE_EXPEDIENTE
			set
				fechaModificoAuditoria = getdate(),
				idUsuarioModificoAuditoria = @idFuncionario
			where
				idProyecto = 1
			and
				idCotizacion = 1
			and
				idFormalizacion = 1
			and
				idCertificado = 1
			and
				nombreArchivo = @nombreArchivo;

		end
		else
		begin

			insert into SICORE_EXPEDIENTE
			select
				1,
				1,
				1,
				1,
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
					nombreArchivo varchar(150) '$.nombreArchivo',
					rutaFisicaArchivo varchar(250) '$.rutaFisicaPDF',
					idFuncionario int '$.idFuncionario'
				)

		end

		select 1 as resultado;

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK

	select ERROR_MESSAGE() as resultado
END CATCH