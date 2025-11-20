use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Octubre 2025
-- Description:	Trae las cotizaciones que están agrupadas para ser aprobadas.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_COTIZACION_TRAE_PORCONSECUTIVO]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_COTIZACION_TRAE_PORCONSECUTIVO]
GO

CREATE PROCEDURE [dbo].[PA_COTIZACION_TRAE_PORCONSECUTIVO] (@pConsecutivos AS NVARCHAR(255))
AS
BEGIN TRY

		SELECT
			cotizacion.consecutivo,
			dbo.FN_GET_NOMBRE_CORTO_FUNCIONARIO(cotizacion.idFuncionario) AS nombreCorto,
			cotizacion.fechaHora,
			cotizacion.montoTotalDolares,
			cotizacion.cantidad
		FROM
			SICORE_COTIZACION cotizacion
		WHERE
			cotizacion.consecutivo IN	(
											SELECT
												value 
											FROM
												STRING_SPLIT(@pConsecutivos, ',')
										)

END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE() AS Error
END CATCH