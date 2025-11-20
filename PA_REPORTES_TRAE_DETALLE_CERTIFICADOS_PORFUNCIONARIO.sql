use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Setiembre 2025
-- Description:	Trae un listado de Ventas o Certificados filtrado por Funcionario o agente.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_REPORTES_TRAE_DETALLE_CERTIFICADOS_PORFUNCIONARIO]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_REPORTES_TRAE_DETALLE_CERTIFICADOS_PORFUNCIONARIO]
GO

CREATE PROCEDURE [dbo].[PA_REPORTES_TRAE_DETALLE_CERTIFICADOS_PORFUNCIONARIO] (@pIdFuncionario BIGINT)
AS
BEGIN TRY
	
	SELECT
		numeroIdentificacionInterno								AS certificado,
		[dbo].[FN_GET_CAMEL_CASE](nombreCertificado)			AS cliente,
		CONVERT(VARCHAR, fechaEmisionCertificado, 105) + ' ' +	
		CONVERT(VARCHAR(5), fechaEmisionCertificado, 108)		AS fecha,
		cotizacion.cantidad										AS cantidad,
		CONVERT(DECIMAL(10,2), montoTransferencia)				AS monto
	FROM
		SICORE_CERTIFICADO certificado
	INNER JOIN
		SICORE_COTIZACION cotizacion ON certificado.idCotizacion = cotizacion.idCotizacion
	WHERE
		certificado.idFuncionario = @pIdFuncionario

END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE();
END CATCH