use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Julio 2024
-- Description:	Toma un objeto JSON para ingresar un registro a la tabla Inventario.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_INVENTARIO_INGRESA]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_INVENTARIO_INGRESA]
GO

CREATE PROCEDURE [dbo].[PA_INVENTARIO_INGRESA] (@pInventario as nvarchar(max))
AS
BEGIN TRY
	BEGIN TRAN
		
		declare @idProyecto bigint = (select idProyecto from openjson(@pInventario) with (idProyecto bigint '$.idProyecto'));
		declare @idUsuario bigint = (select idUsuario from openjson(@pInventario) with (idUsuario bigint '$.idUsuario'));
		declare @cantidad decimal(18,2) = (select cantidad from openjson(@pInventario) with (cantidad decimal(18,2) '$.cantidad'));
		declare @descripcion varchar(255) = (select descripcion from openjson(@pInventario) with (descripcion varchar(255) '$.descripcionMovimiento'));
		
		declare @periodo int = year(getdate());
		declare @remanenteVirtual decimal (18,2) = 0;
		declare @remanente decimal (18,2) = 0;

		set @remanenteVirtual = (select comprometido from SICORE_INVENTARIO where idProyecto = @idProyecto and periodo = @periodo);
		set @remanenteVirtual = isnull(@remanenteVirtual,0) + @cantidad;

		set @remanente = (select remanente from SICORE_INVENTARIO where idProyecto = @idProyecto and periodo = @periodo);
		set @remanente = isnull(@remanente,0) + @cantidad;

		insert into SICORE_MOVIMIENTO_INVENTARIO
		select
			idProyecto,
			idUsuario,
			getdate(),
			cantidad,
			descripcionMovimiento,
			'E',
			@remanenteVirtual,
			@remanente,
			getdate(),
			@idUsuario,
			null,
			null
		from
			openjson(@pInventario)
		with
		(
			idProyecto bigint '$.idProyecto',
			idUsuario bigint '$.idUsuario',
			cantidad decimal(18,2) '$.cantidad',
			descripcionMovimiento varchar(255) '$.descripcionMovimiento'
		)

		if(exists(select 1 from SICORE_INVENTARIO where idProyecto = @idProyecto and periodo = @periodo))
		begin

			update SICORE_INVENTARIO
			set
				remanente = remanente + @cantidad,
				comprometido = comprometido + @cantidad,
				fechaModificoAuditoria = getdate(),
				idUsuarioModificoAuditoria = @idUsuario
			where
				idProyecto = @idProyecto
			and
				periodo = @periodo

		end
		else
		begin

			insert into SICORE_INVENTARIO
			values (
				@idProyecto,
				@cantidad,
				0,
				@cantidad,
				@periodo,
				getdate(),
				@idUsuario,
				null,
				null
					)
		
		end

		select 1 as resultado

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK

	select ERROR_MESSAGE() as resultado
END CATCH