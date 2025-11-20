use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Setiembre 2025
-- Description:	Trae un listado que muestra el esfuerzo del colaborador a un año.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_REPORTES_TRAE_LISTADO_ESFUERZO_ANUAL]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_REPORTES_TRAE_LISTADO_ESFUERZO_ANUAL]
GO

CREATE PROCEDURE [dbo].[PA_REPORTES_TRAE_LISTADO_ESFUERZO_ANUAL]
AS
BEGIN TRY

	DECLARE @primerDiaDelAnno AS DATE = DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0);

	SELECT
		certificado.idFuncionario											AS idFuncionario,
		dbo.FN_GET_CAMEL_CASE(persona.nombre) + ' ' +
		dbo.FN_GET_CAMEL_CASE(persona.primerApellido) + ' ' +
		dbo.FN_GET_CAMEL_CASE(persona.segundoApellido)						AS agente,
		SUM(cotizacion.cantidad)											AS cantidad,
		SUM(montoTransferencia)												AS monto,
		dbo.FN_GET_ULTIMA_VENTA_PORAGENTE(certificado.idFuncionario)		AS ultimaVenta
	FROM
		SICORE_CERTIFICADO certificado
	INNER JOIN
		SICORE_COTIZACION cotizacion ON certificado.idCotizacion = cotizacion.idCotizacion
	INNER JOIN
		SICORE_USUARIO usuario ON certificado.idFuncionario = usuario.idUsuario
	LEFT OUTER JOIN
		SCGI..SIST_USUARIO funcionario ON usuario.idUsuario = funcionario.idUsuario
	LEFT OUTER JOIN
		SCGI..SIST_PERSONA persona ON funcionario.idPersona = persona.idPersona
	WHERE
		CAST(fechaTransferencia AS DATE) BETWEEN @primerDiaDelAnno AND CAST(GETDATE() AS DATE) 
	GROUP BY
		certificado.idFuncionario,
		persona.nombre,
		persona.primerApellido,
		persona.segundoApellido
	ORDER BY
		certificado.idFuncionario ASC
 
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE()
END CATCH