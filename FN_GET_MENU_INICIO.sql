USE [SICORE]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FN_GET_MENU_INICIO]') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
  DROP FUNCTION [dbo].[FN_GET_MENU_INICIO]
GO

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Agosto 2024
-- Description:	Función que convierte una tupla en JSON para crear el menú de inicio en SICORE.
-- =============================================

Create Function [dbo].[FN_GET_MENU_INICIO] (@pIdPerfil bigint)
Returns nvarchar(max)
BEGIN
	declare @resultado nvarchar(max) = (
											select
												titulo,
												icono,
												rutaEnlace
											from
												SICORE_PANTALLA_POR_ROL pantallasRol
											inner join
												SICORE_PANTALLA pantalla on pantallasRol.idPantalla = pantalla.idPantalla
											inner join
												SICORE_PERFIL perfil on perfil.idPerfil = pantallasRol.idPerfil
											where
												perfil.idPerfil = @pIdPerfil
											order by 
												pantalla.idPantalla asc
											for json auto
										);

	Return(@resultado);
END;