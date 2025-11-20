USE [SICORE]
GO

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: 10 julio, 2024
-- Description:	Trigger por la actualización de un registro en Cliente.
-- =============================================

IF EXISTS (SELECT * FROM sys.objects WHERE [name] = N'CLIENTE_U_TR' AND [type] = 'TR')
	DROP TRIGGER [dbo].[CLIENTE_U_TR];
GO

CREATE TRIGGER [dbo].[CLIENTE_U_TR]
   ON  [dbo].[SICORE_CLIENTE]
   FOR UPDATE
AS 
BEGIN
	INSERT INTO [SCGI_TRAZA].[dbo].[SICORE_CLIENTE]
		SELECT
			idCliente,
			idSector,
			nombreCliente,
			nombreComercial,
			cedulaCliente,
			contactoCliente,
			telefonoCliente,
			emailCliente,
			direccionFisica,
			clasificacion,
			indicadorEstado,
			fechaInsertoAuditoria,
			idUsuarioInsertoAuditoria,
			fechaModificoAuditoria,
			idUsuarioModificoAuditoria,
			contactoContador,
			emailContador,
			esGestor,
			idAgenteCuenta,
			ucii
		FROM
			deleted
END