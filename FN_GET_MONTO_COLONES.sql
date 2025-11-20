USE [SICORE]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FN_GET_MONTO_COLONES]') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
  DROP FUNCTION [dbo].[FN_GET_MONTO_COLONES]
GO

-- =============================================
-- Author:		Álvaro Zamora Solís.
-- Create date: Junio 2025
-- Description:	Convierte monto en dólares a colones.
-- =============================================

create function [dbo].[FN_GET_MONTO_COLONES]
(
	@pMontoDolares decimal (18,2),
	@pFechaFormalizacion datetime
)
returns decimal (18,2)

begin

	declare @salida decimal (18,2) =	(select
											isnull(tipoCompra * @pMontoDolares, 0)
										from
											SIFIN..TIPO_CAMBIO_MONEDA
										where
											fechaTipoVenta = cast(@pFechaFormalizacion as date)
										)

	return @salida;

end;