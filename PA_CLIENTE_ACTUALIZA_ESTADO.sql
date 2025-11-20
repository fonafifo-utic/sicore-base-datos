use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Enero 2025
-- Description:	Toma un objeto JSON para actualizar el estado del Cliente.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_CLIENTE_ACTUALIZA_ESTADO]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_CLIENTE_ACTUALIZA_ESTADO]
GO

CREATE PROCEDURE [dbo].[PA_CLIENTE_ACTUALIZA_ESTADO] (@pCliente as nvarchar(max))
AS
BEGIN TRY
	BEGIN TRAN
		
		set @pCliente = replace(@pCliente, '{ pCliente = "{', '{');
		set @pCliente = replace(@pCliente, '" }', '');

		declare @idCliente bigint					= (select idCliente from openjson (@pCliente) with (idCliente bigint '$.idCliente'));
		declare @idFuncionario bigint				= (select idFuncionario from openjson (@pCliente) with (idFuncionario bigint '$.idFuncionario'));
		declare @estado char(1)						= (select indicadorEstado from openjson (@pCliente) with (indicadorEstado char(1) '$.indicadorEstado'));

		update SICORE_CLIENTE
		set
			indicadorEstado = @estado,
			idUsuarioModificoAuditoria = @idFuncionario,
			fechaModificoAuditoria = getdate()
		where
			idCliente = @idCliente

		select 1 as resultado

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK

	select ERROR_MESSAGE() as resultado
END CATCH