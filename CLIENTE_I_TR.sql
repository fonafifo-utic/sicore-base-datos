USE [SICORE]
GO

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: 10 julio, 2024
-- Description:	Trigger por el ingreso de un registro en Cliente.
-- =============================================

IF EXISTS (SELECT * FROM sys.objects WHERE [name] = N'CLIENTE_I_TR' AND [type] = 'TR') 
	DROP TRIGGER [dbo].[CLIENTE_I_TR];
GO

CREATE TRIGGER [dbo].[CLIENTE_I_TR]
   ON  [dbo].[SICORE_CLIENTE]
   FOR INSERT
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
			inserted
END