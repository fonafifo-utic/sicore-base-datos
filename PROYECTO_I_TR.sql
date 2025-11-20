USE [SICORE]
GO

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: 10 julio, 2024
-- Description:	Trigger por el ingreso de un registro en Usuario.
-- =============================================

IF EXISTS (SELECT * FROM sys.objects WHERE [name] = N'PROYECTO_I_TR' AND [type] = 'TR') 
	DROP TRIGGER [dbo].[PROYECTO_I_TR];
GO

CREATE TRIGGER [dbo].[PROYECTO_I_TR]
   ON  [dbo].[SICORE_PROYECTO]
   FOR INSERT
AS 
BEGIN
	INSERT INTO [SCGI_TRAZA].[dbo].[SICORE_PROYECTO]
		SELECT
			idProyecto,
			proyecto,
			descripcionProyecto,
			ubicacionGeografica,
			fechaInsertoAuditoria,
			idUsuarioInsertoAuditoria,
			fechaModificoAuditoria,
			idUsuarioModificoAuditoria,
			periodoInicio,
			periodoFinalizacion,
			especieArboles,
			contratoPSA,
			indicadorEstado
		FROM
			inserted
END