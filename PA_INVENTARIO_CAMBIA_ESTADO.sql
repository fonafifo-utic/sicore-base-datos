use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Julio 2024
-- Description:	Toma un objeto JSON para cambiarle el estado a un ítem del inventario.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_INVENTARIO_CAMBIA_ESTADO]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_INVENTARIO_CAMBIA_ESTADO]
GO

CREATE PROCEDURE [dbo].[PA_INVENTARIO_CAMBIA_ESTADO] (@pInventario as nvarchar(max))
AS
BEGIN TRY
	BEGIN TRANSACTION
		
		SET NOCOUNT ON;

		set @pInventario = replace(@pInventario, '{ pInventario = "{', '{');
		set @pInventario = replace(@pInventario, '" }', '');

		declare @idInventario int = (select idInventario from openjson (@pInventario) with (idInventario int '$.IdInventario'));
		declare @estado char(1) = (select indicadorEstado from openjson (@pInventario) with (indicadorEstado char(1) '$.IndicadorEstado'));

		if(@estado = 'A') set @estado = 'I'
		else if(@estado = 'I') set @estado = 'A'

		update SICORE_INVENTARIO
			set
				indicadorEstado = @estado
			where
				idInventario = @idInventario;

		select 1 as resultado

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK

	select ERROR_MESSAGE() as resultado
END CATCH