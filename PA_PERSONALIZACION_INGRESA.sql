use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Julio 2024
-- Description:	Toma un objeto JSON para ingresar registros en la tabla Personalización.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_PERSONALIZACION_INGRESA]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_PERSONALIZACION_INGRESA]
GO

CREATE PROCEDURE [dbo].[PA_PERSONALIZACION_INGRESA] (@pPersonalizacion as nvarchar(max))
AS
BEGIN TRY
	BEGIN TRAN

		insert into SICORE_PERSONALIZACION
			select	
				direccion,
				telefono,
				logoPrincipal,
				logoSecundario,
				tercerLogo,
				logoSistema,
				leyendaPiePagina,
				leyendaCentroCertificado,
				null,
				null,
				null,
				null,
				correoGerenciaEjecutiva
			from
				openjson(@pPersonalizacion)
			with
				(
					direccion varchar(120) '$.Direccion',
					telefono varchar(80) '$.Telefono',
					logoPrincipal varbinary (max) '$.LogoPrincipal',
					logoSecundario varbinary (max) '$.LogoSecundario',
					tercerLogo varbinary (max) '$.TercerLogo',
					logoSistema varbinary (max) '$.LogoSistema',
					leyendaPiePagina varchar(160) '$.LeyendaPiePagina',
					leyendaCentroCertificado varchar(160) '$.LeyendaCentroCertificado',
					correoGerenciaEjecutiva varchar(100) '$.correoGerenciaEjecutiva'
				)

		select 1 as resultado

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK

	select ERROR_MESSAGE() as resultado
END CATCH