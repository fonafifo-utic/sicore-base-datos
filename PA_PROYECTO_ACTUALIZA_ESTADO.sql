use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Enero 2025
-- Description:	Toma un objeto JSON para actualizar el estado del Proyecto.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_PROYECTO_ACTUALIZA_ESTADO]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_PROYECTO_ACTUALIZA_ESTADO]
GO

CREATE PROCEDURE [dbo].[PA_PROYECTO_ACTUALIZA_ESTADO] (@pProyecto as nvarchar(max))
AS
BEGIN TRY
	BEGIN TRANSACTION
		
		SET NOCOUNT ON;

		set @pProyecto = replace(@pProyecto, '{ pProyecto = "{', '{');
		set @pProyecto = replace(@pProyecto, '" }', '');

		declare @idProyecto int = (select idProyecto from openjson (@pProyecto) with (idProyecto int '$.idProyecto'));
		declare @idFuncionario int = (select idFuncionario from openjson (@pProyecto) with (idFuncionario int '$.idFuncionario'));
		declare @indicadorEstado char(1) = (select indicadorEstado from openjson (@pProyecto) with (indicadorEstado char(1) '$.indicadorEstado'));

		if(exists(select 1 from SICORE_INVENTARIO where idProyecto = @idProyecto))
		begin

			select 2 as resultado;

		end
		else
		begin

			update SICORE_PROYECTO
					set
						indicadorEstado = @indicadorEstado,
						fechaModificoAuditoria = getdate(),
						idUsuarioModificoAuditoria = @idFuncionario
					where
						idProyecto = @idProyecto;

			select 1 as resultado;

		end


	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK

	select ERROR_MESSAGE() as resultado
END CATCH