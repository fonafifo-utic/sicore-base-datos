use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Agosto 2024
-- Description:	Toma un objeto JSON para actualizar la tabla Proyectos.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_PROYECTO_ACTUALIZA]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_PROYECTO_ACTUALIZA]
GO

CREATE PROCEDURE [dbo].[PA_PROYECTO_ACTUALIZA] (@pProyecto as nvarchar(max))
AS
BEGIN TRY
	BEGIN TRANSACTION
		
		SET NOCOUNT ON;

		set @pProyecto = replace(@pProyecto, '{ pProyecto = "{', '{');
		set @pProyecto = replace(@pProyecto, '" }', '');

		declare @idProyecto int = (select idProyecto from openjson (@pProyecto) with (idProyecto int '$.idProyecto'));
		declare @idFuncionario int = (select idFuncionario from openjson (@pProyecto) with (idFuncionario int '$.idFuncionario'));

		declare @proyecto varchar(150) = (select proyecto from openjson (@pProyecto) with (proyecto varchar(150) '$.proyecto'));
		declare @descripcionProyecto varchar(150) = (select descripcionProyecto from openjson (@pProyecto) with (descripcionProyecto varchar(150) '$.descripcionProyecto'));
		declare @ubicacionGeografica varchar(150) = (select ubicacionGeografica from openjson (@pProyecto) with (ubicacionGeografica varchar(150) '$.ubicacionGeografica'));
		declare @periodoInicio date = (select periodoInicio from openjson (@pProyecto) with (periodoInicio date '$.periodoInicio'));
		declare @periodoFinalizacion date = (select periodoFinalizacion from openjson (@pProyecto) with (periodoFinalizacion date '$.periodoFinalizacion'));
		declare @especieArboles varchar(255) = (select especieArboles from openjson (@pProyecto) with (especieArboles varchar(255) '$.especieArboles'));
		declare @contratoPSA varchar(100) = (select contratoPSA from openjson (@pProyecto) with (contratoPSA varchar(100) '$.contratoPSA'));

		if(@idProyecto != 0)
		begin
			update SICORE_PROYECTO
				set
					proyecto = upper(@proyecto),
					descripcionProyecto = @descripcionProyecto,
					ubicacionGeografica = upper(@ubicacionGeografica),
					fechaModificoAuditoria = getdate(),
					idUsuarioModificoAuditoria = @idFuncionario,
					periodoInicio = @periodoInicio,
					periodoFinalizacion = @periodoFinalizacion,
					especieArboles = @especieArboles,
					contratoPSA = @contratoPSA
				where
					idProyecto = @idProyecto;
		end
		else
		begin
			update SICORE_PROYECTO
				set
					descripcionProyecto = @descripcionProyecto,
					ubicacionGeografica = upper(@ubicacionGeografica),
					fechaModificoAuditoria = getdate(),
					idUsuarioModificoAuditoria = @idFuncionario,
					periodoInicio = @periodoInicio,
					periodoFinalizacion = @periodoFinalizacion,
					especieArboles = @especieArboles,
					contratoPSA = @contratoPSA
				where
					proyecto = @proyecto;
		end

		select 1 as resultado

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK

	select ERROR_MESSAGE() as resultado
END CATCH