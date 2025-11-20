USE [SICORE]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FN_GET_CAMEL_CASE]') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
  DROP FUNCTION [dbo].[FN_GET_CAMEL_CASE]
GO

-- =============================================
-- Author:		Álvaro Zamora Solís.
-- Create date: Diciembre 2024
-- Description:	Convierte una cadena de ingreso en Camel Case.
-- =============================================

create function [dbo].[FN_GET_CAMEL_CASE] 
(
	@pEntrada nvarchar(max)
)
returns nvarchar(max)

begin

	declare @indice int = 1;
	declare @char char(1) = '';
	declare @charPrevio char(1) = '';
	declare @salida nvarchar(max) = lower(@pEntrada);

	while @indice <= len(@pEntrada)
	begin
		set @char = substring(@pEntrada, @indice, 1);
		set @charPrevio = case when @indice = 1 then ' ' else substring(@pEntrada, @indice - 1, 1) end;

		if(@charPrevio in (' ', ';', ':', '!', '?', ',', '.', '_', '-', '/', '&', '''', '('))
			set @salida = stuff(@salida, @indice, 1, upper(@char));

		set @indice += 1;
	end

	return @salida;

end;