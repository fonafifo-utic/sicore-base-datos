USE [SICORE]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FN_GET_FORMATO_CONSECUTIVO]') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
  DROP FUNCTION [dbo].[FN_GET_FORMATO_CONSECUTIVO]
GO

-- =============================================
-- Author:		Álvaro Zamora Solís.
-- Create date: Junio 2025
-- Description:	Pone ceros de acuerdo al .
-- =============================================

create function [dbo].[FN_GET_FORMATO_CONSECUTIVO] 
(
	@pEntrada bigint
)
returns nvarchar(max)

begin

	declare @salida nvarchar(max) = '';

	if(len(@pEntrada) = 1) set @salida = '00' + cast(@pEntrada as varchar(10));
	if(len(@pEntrada) = 2) set @salida = '0' + cast(@pEntrada as varchar(10));
	if(len(@pEntrada) = 3) set @salida = cast(@pEntrada as varchar(10));
	
	return @salida;

end;