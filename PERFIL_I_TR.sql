USE [SICORE]
GO

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: 10 julio, 2024
-- Description:	Trigger por el ingreso de un registro en Perfil.
-- =============================================

IF EXISTS (SELECT * FROM sys.objects WHERE [name] = N'PERFIL_I_TR' AND [type] = 'TR')
	DROP TRIGGER [dbo].PERFIL_I_TR;
GO

CREATE TRIGGER [dbo].PERFIL_I_TR
   ON  [dbo].SICORE_PERFIL
   FOR INSERT
AS 
BEGIN
	INSERT INTO [SCGI_TRAZA].[dbo].SICORE_PERFIL
		SELECT
			idPerfil,
			nombre,
			descripcion
		FROM
			inserted
END