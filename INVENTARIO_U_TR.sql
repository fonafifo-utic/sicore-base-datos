USE [SICORE]
GO

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: 10 julio, 2024
-- Description:	Trigger por el ingreso de un registro en Inventario.
-- =============================================

IF EXISTS (SELECT * FROM sys.objects WHERE [name] = N'INVENTARIO_U_TR' AND [type] = 'TR')
	DROP TRIGGER [dbo].[INVENTARIO_U_TR];
GO

CREATE TRIGGER [dbo].[INVENTARIO_U_TR]
   ON  [dbo].[SICORE_INVENTARIO]
   FOR UPDATE
AS 
BEGIN
	INSERT INTO [SCGI_TRAZA].[dbo].[SICORE_INVENTARIO]
		SELECT
			idInventario,
			idProyecto,
			remanente,
			vendido,
 			comprometido,
			periodo,
			fechaInsertoAuditoria,
			idUsuarioInsertoAuditoria,
			fechaModificoAuditoria,
			idUsuarioModificoAuditoria
		FROM
			deleted
END