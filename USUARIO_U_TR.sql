USE [SICORE]
GO

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: 10 julio, 2024
-- Description:	Trigger por la actualización de un registro en Usuario.
-- =============================================

IF EXISTS (SELECT * FROM sys.objects WHERE [name] = N'USUARIO_U_TR' AND [type] = 'TR')
	DROP TRIGGER [dbo].[USUARIO_U_TR];
GO

CREATE TRIGGER [dbo].[USUARIO_U_TR]
   ON  [dbo].[SICORE_USUARIO]
   FOR UPDATE
AS 
BEGIN
	INSERT INTO [SCGI_TRAZA].[dbo].[SICORE_USUARIO]
		SELECT
			idUsuarioInterno,
			idUsuario,
			idPerfil
		FROM
			deleted
END