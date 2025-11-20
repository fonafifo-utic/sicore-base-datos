USE [SICORE]
GO

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: 10 julio, 2024
-- Description:	Trigger por el ingreso de un Certificado.
-- =============================================

IF EXISTS (SELECT * FROM sys.objects WHERE [name] = N'CERTIFICADO_I_TR' AND [type] = 'TR')
	DROP TRIGGER [dbo].[CERTIFICADO_I_TR];
GO

CREATE TRIGGER [dbo].[CERTIFICADO_I_TR]
   ON  [dbo].[SICORE_CERTIFICADO]
   FOR INSERT
AS 
BEGIN
	INSERT INTO [SCGI_TRAZA].[dbo].[SICORE_CERTIFICADO]
		SELECT
			idCertificado,
			idFormalizacion,
			idCotizacion,
			idFuncionario,
			numeroCertificado,
			nombreCertificado,
			fechaEmisionCertificado,
			cedulaJuridicaComprador,
			montoTransferencia,
			numeroTransferencia,
			fechaTransferencia,
			annoInventarioGEI,
			fechaInsertoAuditoria,
			idUsuarioInsertoAuditoria,
			fechaModificoAuditoria,
			idUsuarioModificoAuditoria,
			observaciones,
			numeroIdentificacionInterno,
			justificacionEdicion,
			indicadorEstado,
			cssCertificado,
			enIngles
		FROM
			inserted
END