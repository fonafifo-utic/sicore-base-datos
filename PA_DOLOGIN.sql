USE [SICORE]
GO

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_DOLOGIN]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_DOLOGIN]
GO

-- =============================================
-- Author:		Rogelio Solano A
-- Create date: 01 Oct 2023
-- Description:	Este PA valida las credenciales de ingreso del usuario de Credifor, retornando los datos requeridos para el manejo de la sesion dentro del sistema.
-- Comentario: Adaptación para SICORE, por parte de Álvaro Zamora S.
-- Fecha Adaptación: 25 jun 2024
-- =============================================

CREATE PROCEDURE [dbo].[PA_DOLOGIN] (@pCorreoCedula varchar(150), @pClave varchar(150))
AS
BEGIN TRY
	BEGIN TRANSACTION
	
		declare @nombreCompleto as varchar(150);
		declare @idPersona as int;
		declare @idUsuario as int;
		declare @correoUsuario as varchar(150);
		declare @correoNotificaciones as varchar(150);
		declare @requiereActualizar as varchar(150);
		declare @telefonoMovil as varchar(150);
		declare @telefonoFijoTrabajo as varchar(150);
		declare @idPerfil as int;
		declare @perfil as varchar(150);
		declare @token as varchar(150);
		declare @menu as nvarchar(max);

		set @pCorreoCedula = upper(replace(@pCorreoCedula, '-', ''));

		declare @escorreo as int = charindex('@', @pCorreoCedula);
		declare @usarDobleFactor char(1) = (select valor from SICORE_PARAMETROS Where idParametro = 5);

		if(@escorreo = 0)
		begin
			set @idPersona = (select idPersona from SCGI.[dbo].[SIST_PERSONA] where documentoID = @pCorreoCedula)
			set @pCorreoCedula = (select usuario from SCGI.[dbo].[SIST_USUARIO] where idPersona = @idPersona)
		end

		select
			@nombreCompleto			= (trim(personas.nombre) + ' '+trim(personas.primerApellido) + ' '+trim(isnull(personas.segundoApellido, ''))),
			@idPersona				= personas.idPersona,
 			@idUsuario				= usuarios.idUsuario,
			@correoUsuario			= usuarios.usuario,
			@correoNotificaciones	= isnull(personas.correoNotificaciones, ''),
			@requiereActualizar		= dbo.FN_VALIDA_REQUIERE_ACTUALIZAR_CLAVE
										(	
											usuarios.fechaVenceClave,
											usuarios.ultimoAcceso_SCGI,
											usuarios.claveTemporal
										),
			@telefonoMovil			= personas.telefonoMovil,
			@telefonoFijoTrabajo	= personas.telefonoFijoTrabajo,
			@idPerfil				= perfil.idPerfil,
			@perfil					= perfil.nombre,
			@token					= ''
		from
			SCGI.[dbo].[SIST_USUARIO] usuarios
		inner join
			SCGI.[dbo].[SIST_PERSONA] personas on usuarios.idPersona = personas.idPersona
		inner join
			dbo.SICORE_USUARIO usuario on usuarios.idUsuario = usuario.idUsuario
		inner join
			SICORE_PERFIL perfil on usuario.idPerfil = perfil.idPerfil
		where
			upper(usuarios.usuario) = upper(@pCorreoCedula)
		and
			dbo.FN_GET_CLAVE_USUARIO_SCGI(personas.idPersona, usuarios.idUsuario) = @pClave
		and
			usuarios.idUsuario in (select idUsuario from SCGI.[dbo].[SIST_FUNCIONARIOS] where idEstado = 'A')

		set @menu = (select dbo.FN_GET_MENU_INICIO(@idPerfil));

		select
			@nombreCompleto			as nombreCompleto,
			@idPersona				as idPersona,
 			@idUsuario				as idUsuario,
			@correoUsuario			as correoUsuario,
			@correoNotificaciones	as correoNotificaciones,
			@requiereActualizar		as requiereActualizar,
			@telefonoMovil			as telefonoMovil,
			@telefonoFijoTrabajo	as telefonoFijoTrabajo,
			@idPerfil				as idPerfil,
			@perfil					as perfil,
			@token					as token,
			@menu					as menu

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK


END CATCH