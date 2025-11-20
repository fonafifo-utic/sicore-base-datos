USE [SICORE]
GO

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: 10 julio, 2024
-- Description:	Trigger por la actualización de un registro en Personalización.
-- =============================================

IF EXISTS (SELECT * FROM sys.objects WHERE [name] = N'PERSONALIZACION_U_TR' AND [type] = 'TR')
	DROP TRIGGER [dbo].[PERSONALIZACION_U_TR];
GO

CREATE TRIGGER [dbo].[PERSONALIZACION_U_TR]
   ON  [dbo].[SICORE_PERSONALIZACION]
   FOR UPDATE
AS 
BEGIN
	INSERT INTO [SCGI_TRAZA].[dbo].[SICORE_PERSONALIZACION]
		SELECT
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
			fechaInsertoAuditoria,
			idUsuarioInsertoAuditoria,
			fechaModificoAuditoria,
			idUsuarioModificoAuditoria,
			correoGerenciaEjecutiva,
			directorEjecutivo
		FROM
			deleted
END