USE [SICORE]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FN_GET_ULTIMA_VENTA_PORAGENTE]') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
  DROP FUNCTION [dbo].[FN_GET_ULTIMA_VENTA_PORAGENTE]
GO

-- =============================================
-- Author:		Álvaro Zamora Solís.
-- Create date: Septiembre 2025
-- Description:	Trae la última venta que hizo un agente de ventas.
-- =============================================

CREATE FUNCTION [dbo].[FN_GET_ULTIMA_VENTA_PORAGENTE]
(
	@pIdUsuario BIGINT
)
RETURNS DATETIME

BEGIN

	DECLARE @fechaUltimaVenta DATETIME = (
											SELECT TOP 1
												fechaEmisionCertificado
											FROM
												SICORE..SICORE_CERTIFICADO
											WHERE
												idFuncionario = @pIdUsuario
											ORDER BY
												fechaEmisionCertificado DESC
										);

	RETURN @fechaUltimaVenta;

END;