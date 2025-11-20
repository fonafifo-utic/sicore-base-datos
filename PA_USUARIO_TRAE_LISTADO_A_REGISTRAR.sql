use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Agosto 2024
-- Description:	Recupera un listado de usuarios desde SCGI para poder registrar usuarios a SICORE.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_USUARIO_TRAE_LISTADO_A_REGISTRAR]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_USUARIO_TRAE_LISTADO_A_REGISTRAR]
GO

CREATE PROCEDURE [dbo].[PA_USUARIO_TRAE_LISTADO_A_REGISTRAR]
AS
BEGIN TRY
	BEGIN TRANSACTION

		select
			usuarios.idUsuario,
			usuarios.usuario,
			personas.documentoID,
			personas.nombre,
			personas.primerApellido,
			personas.segundoApellido
		from
			[SCGI].[dbo].[SIST_USUARIO] usuarios
		inner join
			[SCGI].[dbo].[SIST_PERSONA] personas on usuarios.idPersona = personas.idPersona
		where
			idUsuario in (select idUsuario from [SCGI].[dbo].[SIST_FUNCIONARIOS] where idEstado = 'A')
		and
			usuarios.indicadorEstado = 'A'
		order by
			personas.documentoID asc

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK
END CATCH
