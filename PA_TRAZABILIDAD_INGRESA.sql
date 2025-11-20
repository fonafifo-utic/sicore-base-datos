use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Agosto 2024
-- Description:	Toma un objeto JSON para ingresar un registro a la tabla SICORE_TRAZABILIDAD.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_TRAZABILIDAD_INGRESA]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_TRAZABILIDAD_INGRESA]
GO

CREATE PROCEDURE [dbo].[PA_TRAZABILIDAD_INGRESA] (@pEvento as nvarchar(max))
AS
BEGIN TRY
	BEGIN TRANSACTION
		
		SET NOCOUNT ON;

			declare @fechaTraza datetime = getdate();
			
			insert into SICORE_TRAZABILIDAD
			select
				idUsuario,
				modulo,
				operacion,
				@fechaTraza
			from
				openjson(@pEvento)
			with (
				idUsuario bigint '$.idUsuario',
				modulo varchar(255) '$.modulo',
				operacion varchar(255) '$.operacion'
				);

		select 1 as resultado

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK

	select ERROR_MESSAGE() as resultado
END CATCH