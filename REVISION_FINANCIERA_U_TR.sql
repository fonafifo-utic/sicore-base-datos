USE [SICORE]
GO

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: 10 julio, 2024
-- Description:	Trigger por la actualización de un registro en Revisión Financiera.
-- =============================================

IF EXISTS (SELECT * FROM sys.objects WHERE [name] = N'REVISION_FINANCIERA_U_TR' AND [type] = 'TR')
	DROP TRIGGER [dbo].[REVISION_FINANCIERA_U_TR];
GO

CREATE TRIGGER [dbo].[REVISION_FINANCIERA_U_TR]
   ON  [dbo].[SICORE_REVISION_FINANCIERA]
   FOR INSERT
AS 
BEGIN
	INSERT INTO [SCGI_TRAZA].[dbo].[SICORE_REVISION_FINANCIERA]
		SELECT
			idRevisionFinanciera
			,idCotizacion
			,idPago
			,fechaPago
			,idRecibo
			,fechaRecibo
			,estado
			,fechaInsertoAuditoria
			,idUsuarioInsertoAuditoria
			,fechaModificoAuditoria
			,idUsuarioModificoAuditoria
			,CURRENT_TIMESTAMP
		FROM
			deleted
END