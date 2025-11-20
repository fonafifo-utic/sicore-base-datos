use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Octubre 2025
-- Description:	Trae las cotizaciones que están agrupadas.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_COTIZACION_TRAE_LISTADO_AGRUPADAS]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_COTIZACION_TRAE_LISTADO_AGRUPADAS]
GO

CREATE PROCEDURE [dbo].[PA_COTIZACION_TRAE_LISTADO_AGRUPADAS]
AS
BEGIN TRY
	
	SELECT
		cotizaciones.consecutivo,
		dbo.FN_GET_NOMBRE_CORTO_FUNCIONARIO(cotizaciones.idFuncionario) AS nombreCorto,
		cotizaciones.fechaHora,
		SUM(cotizacion.montoTotalDolares) AS montoDolares,
		SUM(cotizacion.cantidad) AS cantidad,
		STRING_AGG(cotizacion.consecutivo, ', ') AS cotizaciones,
		case
			when cotizaciones.indicadorEstado = 'A' then
				'Activa'
			when cotizaciones.indicadorEstado = 'I' then
				'Inactiva'
			when cotizaciones.indicadorEstado = 'P' then
				'Pendiente'
			when cotizaciones.indicadorEstado = 'F' then
				'Formalizada'
			when cotizaciones.indicadorEstado = 'E' then
				'Enviada'
			when cotizaciones.indicadorEstado = 'K' then
				'Pendiente Cierre'
			when cotizaciones.indicadorEstado = 'V' then
				'Pendiente Validación'
			when cotizaciones.indicadorEstado = 'R' then
				'Rechazada'
			when cotizaciones.indicadorEstado = 'U' then
				'Uso Interno'
			when cotizaciones.indicadorEstado = 'G' then
				'Agrupada'
		end indicadorEstado
	FROM
		SICORE_COTIZACION_AGRUPACION cotizaciones
	INNER JOIN
		SICORE_COTIZACION cotizacion ON cotizaciones.idCotizacion = cotizacion.idCotizacion
	WHERE
		cotizaciones.indicadorEstado != 'N'
	GROUP BY
		cotizaciones.consecutivo,
		cotizaciones.idFuncionario,
		cotizaciones.fechaHora,
		cotizaciones.indicadorEstado
	ORDER BY
		cotizaciones.fechaHora DESC

END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE()
END CATCH