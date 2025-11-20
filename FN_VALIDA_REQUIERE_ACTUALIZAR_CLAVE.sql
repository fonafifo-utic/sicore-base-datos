USE [SICORE]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FN_VALIDA_REQUIERE_ACTUALIZAR_CLAVE]') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
  DROP FUNCTION [dbo].[FN_VALIDA_REQUIERE_ACTUALIZAR_CLAVE]
GO 

-- =============================================
-- Author:		Rogelio Solano A
-- Create date: OCt 2023
-- Description:	Esta funcion valida si es requerido la actualización de la contraseña de un usuario.
-- Comentario: Modificado para el proyecto SICORE.
-- Modificador: Álvaro Zamora Solís.
-- Fecha modificación: 26-06-2024
-- =============================================

CREATE FUNCTION [dbo].[FN_VALIDA_REQUIERE_ACTUALIZAR_CLAVE]
(
	-- Add the parameters for the function here
	@pFechaVencimiento datetime,
	@pUltimoAcceso datetime,
	@pClaveTemporal varchar(2)
	
)
RETURNS varchar(1)
AS
BEGIN
	-- Declare the return variable here
	-- Add the T-SQL statements to compute the return value here

	DECLARE @r varchar(1) = 'N';
	
	if(@pFechaVencimiento<GetDate() or DATEDIFF(day,@pUltimoAcceso,getdate())>=30 or @pClaveTemporal='Si' or @pClaveTemporal='S')
	begin
		SET @r='S';
	end	

	-- Return the result of the function
	RETURN  @r

END