use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Julio 2024
-- Description:	Trae registros de la tabla Personalización filtrados por ID.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_PERSONALIZACION_TRAE_PORID]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_PERSONALIZACION_TRAE_PORID]
GO

CREATE PROCEDURE [dbo].[PA_PERSONALIZACION_TRAE_PORID] (@pIdPersonalizacion as int)
AS
BEGIN TRY
	BEGIN TRANSACTION
		
		SET NOCOUNT ON;
		
		select
			idPersonalizacion,
			direccion,
			telefono,
			logoPrincipal,
			logoSecundario,
			tercerLogo,
			logoSistema,
			leyendaPiePagina,
			leyendaCentroCertificado,
			fechaInsertoAuditoria,
			idUsuarioInsertoAuditoria,
			fechaModificoAuditoria,
			idUsuarioModificoAuditoria
		from
			SICORE_PERSONALIZACION
		where
			idPersonalizacion = @pIdPersonalizacion

		SET NOCOUNT OFF;

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK

	select ERROR_MESSAGE() as resultado
END CATCH