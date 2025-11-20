use [SICORE]
go

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_REVISA_FECHA_EXP_COTIZACIONES]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_REVISA_FECHA_EXP_COTIZACIONES]
GO

CREATE PROCEDURE [dbo].[PA_REVISA_FECHA_EXP_COTIZACIONES]
AS
BEGIN TRY
	BEGIN TRAN

		declare @min int = (select min(idCotizacion) from SICORE_COTIZACION where fechaExpiracion in ('2025-01-23'));
		declare @max int = (select max(idCotizacion) from SICORE_COTIZACION where fechaExpiracion in ('2025-01-23'));

		while (@min <= @max)
		begin
	
			declare @idCotizacion int = (select idCotizacion from SICORE_COTIZACION where idCotizacion = @min);
			declare @idFuncionario int = 72103;
			declare @comentario varchar(255) = 'Devolución de remanente por medio automático de SICORE';

			exec PA_COTIZACION_INACTIVA @idCotizacion, @idFuncionario, @comentario;

			waitfor delay '00:00:05';

			set @min = (select min(idCotizacion) from SICORE_COTIZACION where fechaExpiracion in ('2025-01-23') and idCotizacion > @min);
		end

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK
END CATCH