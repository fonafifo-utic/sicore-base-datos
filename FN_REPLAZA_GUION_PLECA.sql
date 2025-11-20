USE [SICORE]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FN_REPLAZA_GUION_PLECA]') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
  DROP FUNCTION [dbo].[FN_REPLAZA_GUION_PLECA]
GO

-- =============================================
-- Author:		Álvaro Zamora Solís.
-- Create date: Marzo 2025
-- Description:	Limpia una celda de plecas y guiones.
-- =============================================

create function [dbo].[FN_REPLAZA_GUION_PLECA] 
(
	@pEntrada nvarchar(max)
)
returns nvarchar(max)

begin

	declare @espacioBlanco char(1) = ' ';
	declare @guion char(1) = '-';
	declare @pleca char(1) = '/';

	declare @celdaLimpia varchar(150) = (replace(@pEntrada, @espacioBlanco, ''));

	set @celdaLimpia = (replace(@celdaLimpia, @guion, ''));

	set @celdaLimpia = (replace(@celdaLimpia, @pleca, ';'));

	return @celdaLimpia;

end;