use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Septiembre 2024
-- Description:	Toma un objeto JSON para ingresar registros en la tabla de la Traza de Cotización.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_COTIZACION_INGRESA_TRAZA_COTIZACION_ENVIADA]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_COTIZACION_INGRESA_TRAZA_COTIZACION_ENVIADA]
GO

CREATE PROCEDURE [dbo].[PA_COTIZACION_INGRESA_TRAZA_COTIZACION_ENVIADA] (@pCotizacion as nvarchar(max))
AS
BEGIN TRY
	BEGIN TRAN

		set @pCotizacion = replace(@pCotizacion, '{ pCotizacion = "{', '{');
		set @pCotizacion = replace(@pCotizacion, '" }', '');

		declare @idCotizacion bigint = (select idCotizacion from openjson (@pCotizacion) with (idCotizacion bigint '$.idCotizacion'));
		declare @idFuncionario bigint = (select idFuncionario from openjson (@pCotizacion) with (idFuncionario bigint '$.idFuncionario'));

		insert into SICORE_COTIZACION_TRAZABILIDAD
		select
			idFuncionario,
			idCliente,
			idCotizacion,
			getdate()
		from
			openjson(@pCotizacion)
		with
			(
				idFuncionario bigint '$.idFuncionario',
				idCliente bigint '$.idCliente',
				idCotizacion bigint '$.idCotizacion'
			)

		update SICORE_COTIZACION
		set
			indicadorEstado = 'E',
			cotizacionEnviada = 1,
			fechaModificoAuditoria = getdate(),
			idUsuarioModificoAuditoria = @idFuncionario
		where
			idCotizacion = @idCotizacion;

		select 1 as resultado;

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK

	select ERROR_MESSAGE() as resultado
END CATCH