use SICORE
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Setiembre 2024
-- Description:	Recibe el ID de una cotización para inactivarla y devolver el dinero al inventario, registrando ese movimiento.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_COTIZACION_INACTIVA]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_COTIZACION_INACTIVA]
GO

CREATE PROCEDURE [dbo].[PA_COTIZACION_INACTIVA] (@pIdCotizacion as bigint, @pIdUsuario as bigint, @pDescripcion as varchar(255))
AS
BEGIN TRY
	BEGIN TRAN

		declare @idProyecto int = (select idProyecto from SICORE_COTIZACION where idCotizacion = @pIdCotizacion);
		declare @cantidad decimal(18,2) = (select cantidad from SICORE_COTIZACION where idCotizacion = @pIdCotizacion);
		declare @remanenteVirtual decimal(18,2) = (select top 1 remanenteVirtual from SICORE_MOVIMIENTO_INVENTARIO where idProyecto = @idProyecto order by idMovimiento desc);
		declare @remanenteReal decimal(18,2) = (select top 1 remanenteReal from SICORE_MOVIMIENTO_INVENTARIO where idProyecto = @idProyecto order by idMovimiento desc);
		declare @comprometido decimal(18,2) = (select comprometido from SICORE_INVENTARIO where idProyecto = @idProyecto);

		set @remanenteVirtual = @remanenteVirtual + @cantidad;
		set @comprometido = @comprometido + @cantidad;

		insert into SICORE_MOVIMIENTO_INVENTARIO
		values
		(
			@idProyecto,
			@pIdUsuario,
			getdate(),
			@cantidad,
			@pDescripcion,
			'A',
			@remanenteVirtual,
			@remanenteReal,
			getdate(),	
			@pIdUsuario,
			null,
			null
		)

		update SICORE_INVENTARIO
		set
			comprometido = @comprometido,
			idUsuarioModificoAuditoria = @pIdUsuario,
			fechaModificoAuditoria = getdate()
		where
			idProyecto = @idProyecto;

		update SICORE_COTIZACION
		set
			indicadorEstado = 'I',
			idUsuarioModificoAuditoria = @pIdUsuario,
			fechaModificoAuditoria = getdate()
		where
			idCotizacion = @pIdCotizacion;

		select 1 as resultado;

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK

	select ERROR_MESSAGE() as resultado
END CATCH