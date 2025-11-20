use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Julio 2024
-- Description:	Recupera un listado de usuarios del sistema SICORE.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_USUARIO_TRAE_LISTADO]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_USUARIO_TRAE_LISTADO]
GO

CREATE PROCEDURE [dbo].[PA_USUARIO_TRAE_LISTADO] (@pIdPerfil bigint)
AS
BEGIN TRY
	BEGIN TRANSACTION

		declare @cantidadUsuario int = (select count(idUsuarioInterno) from [SICORE_USUARIO]);

		select
			usuario.idUsuario,
			usuario.idPerfil,
			perfil.nombre perfil,
			perfil.descripcion descripcionPerfil,
			personas.idPersona,
			usuarios.usuario,
			usuarios.indicadorEstado,
			usuarios.fechaVenceClave,
			personas.documentoID,
			personas.nombre,
			personas.primerApellido,
			personas.segundoApellido,
			personas.indicadorGenero,
			@cantidadUsuario cantidadUsuarios,
			personas.telefonoFijoTrabajo
		from
			[SICORE_USUARIO] usuario
		inner join
			[SICORE_PERFIL] perfil on perfil.idPerfil = usuario.idPerfil
		inner join
			[SCGI].[dbo].[SIST_USUARIO] usuarios on usuario.idUsuario = usuarios.idUsuario
		inner join
			[SCGI].[dbo].[SIST_PERSONA] personas on usuarios.idPersona = personas.idPersona

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK
END CATCH
