use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Julio 2024
-- Description:	Toma un objeto JSON para actualizar la tabla Inventario.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_INVENTARIO_ACTUALIZA]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_INVENTARIO_ACTUALIZA]
GO

CREATE PROCEDURE [dbo].[PA_INVENTARIO_ACTUALIZA] (@pInventario as nvarchar(max))
AS
BEGIN TRY
	BEGIN TRANSACTION

		set @pInventario = replace(@pInventario, '{ pInventario = "{', '{');
		set @pInventario = replace(@pInventario, '" }', '');

		declare @idInventario bigint = (select idInventario from openjson (@pInventario) with (idInventario bigint '$.idInventario'));
		declare @idProyecto bigint = (select idProyecto from openjson (@pInventario) with (idProyecto bigint '$.idProyecto'));
		declare @cantidad decimal(18,2) = (select cantidad from openjson (@pInventario) with (cantidad decimal(18,2) '$.cantidad'));	
		declare @idUsuario bigint = (select idUsuario from openjson(@pInventario) with (idUsuario bigint '$.idUsuario'));
		declare @descripcionMovimiento varchar(250) = (select descripcionMovimiento from openjson(@pInventario) with (descripcionMovimiento varchar(250) '$.descripcionMovimiento'));

		declare @remanente decimal(18,2) = (select remanente from SICORE_INVENTARIO where idInventario = @idInventario);
		declare @comprometido decimal(18,2) = (select comprometido from SICORE_INVENTARIO where idInventario = @idInventario);

		set @comprometido = @comprometido - @cantidad;
		set @remanente = @remanente - @cantidad;

		insert into SICORE_MOVIMIENTO_INVENTARIO
		select
			@idProyecto,
			@idUsuario,
			getdate(),
			@cantidad,
			@descripcionMovimiento,
			'D',
			@comprometido,
			@remanente,
			getdate(),
			@idUsuario,
			null,
			null
			
		update SICORE_INVENTARIO
			set
				remanente = @remanente,
				comprometido = @comprometido,
				fechaModificoAuditoria = getdate(),
				idUsuarioModificoAuditoria = @idUsuario
			where
				idInventario = @idInventario;

		select 1 as resultado

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK

	select ERROR_MESSAGE() as resultado
END CATCH