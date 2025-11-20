use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Julio 2024
-- Description:	Trae todos los registros de la tabla Personalización.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_PERSONALIZACION_TRAE_LISTADO]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_PERSONALIZACION_TRAE_LISTADO]
GO

CREATE PROCEDURE [dbo].[PA_PERSONALIZACION_TRAE_LISTADO]
AS
BEGIN TRY
	BEGIN TRAN

		select
			idPersonalizacion,
			logoPrincipal,
			logoSecundario,
			tercerLogo,
			logoSistema,
			leyendaDescriptivaCotizacionEspannol,
			leyendaDescriptivaCotizacionIngles,
			leyendaFinalidadCotizacionEspannol,
			leyendaFinalidadCotizacionIngles,
			leyendaDescripcionCertificadoEspannol,
			leyendaDescripcionCertificadoIngles,
			correoGerenciaEjecutiva,
			directorEjecutivo
		from
			SICORE_PERSONALIZACION

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK

	select ERROR_MESSAGE() as resultado
END CATCH