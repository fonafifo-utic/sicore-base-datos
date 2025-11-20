USE [SICORE]
GO

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: 10 julio, 2024
-- Description:	Trigger por el ingreso de un registro en Inventario.
-- =============================================

IF EXISTS (SELECT * FROM sys.objects WHERE [name] = N'MOVIMIENTO_INVENTARIO_I_TR' AND [type] = 'TR')
	DROP TRIGGER [dbo].[MOVIMIENTO_INVENTARIO_I_TR];
GO

CREATE TRIGGER [dbo].[MOVIMIENTO_INVENTARIO_I_TR]
   ON  [dbo].[SICORE_MOVIMIENTO_INVENTARIO]
   FOR INSERT
AS 
BEGIN
	INSERT INTO [SCGI_TRAZA].[dbo].[SICORE_MOVIMIENTO_INVENTARIO]
		SELECT
			idMovimiento,
			idProyecto,
			idUsuario,
			fechaMovimiento,
			cantidad,
			descripcionMovimiento,
			tipoMovimiento,
 			remanenteVirtual,
			remanenteReal,
			fechaInsertoAuditoria,
			idUsuarioInsertoAuditoria,
			fechaModificoAuditoria,
			idUsuarioModificoAuditoria
		FROM
			inserted
END