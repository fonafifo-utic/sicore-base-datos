USE [PRESONLINE]
GO
-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Octubre 2024
-- Description:	Crea un login generico
-- =============================================
ALTER PROCEDURE [dbo].[PA_SIS_DOLOGIN] 
	@pCorreoCedula varchar(200),
	@pClave varchar(100)
AS
BEGIN
	Begin Try
	
		declare @nombreCompleto as varchar(150);
		declare @idPersona as int;
		declare @idUsuario as int;
		declare @correoUsuario as varchar(150);
		declare @correoNotificaciones as varchar(150);
		declare @requiereActualizar as varchar(150);
		declare @telefonoMovil as varchar(150);
		declare @indicadorTipoUsuarioSICGI as varchar(10);

		declare @zip as varchar(max);
		declare @temporal as table (zip varchar(max))

		set @pCorreoCedula = upper(replace(@pCorreoCedula, '-', ''));

		declare @escorreo as int = charindex('@', @pCorreoCedula);
		declare @usarDobleFactor char(1) = (Select texto from SISUS..REPROFOR_PARAMETROS Where id=1);
		
		if(@escorreo = 0)
		begin
			set @idPersona = (select idPersona from SCGI.[dbo].[SIST_PERSONA] where documentoID = @pCorreoCedula)
			set @pCorreoCedula = (select usuario from SCGI.[dbo].[SIST_USUARIO] where idPersona = @idPersona)
		end

		select
			@nombreCompleto				= (trim(personas.nombre) + ' '+trim(personas.primerApellido) + ' '+trim(personas.segundoApellido)),
			@idPersona					= personas.idPersona,
 			@idUsuario					= usuarios.idUsuario,
			@correoUsuario				= usuarios.usuario,
			@correoNotificaciones		= isnull(personas.correoNotificaciones, ''),
			@requiereActualizar			= SICORE.dbo.FN_VALIDA_REQUIERE_ACTUALIZAR_CLAVE
											(	
												usuarios.fechaVenceClave,
												usuarios.ultimoAcceso_SCGI,
												usuarios.claveTemporal
											),
			@telefonoMovil				= personas.telefonoMovil,
			@indicadorTipoUsuarioSICGI	= usuarios.indicadorTipoUsuarioSICGI
		from
			SCGI.[dbo].[SIST_USUARIO] usuarios
		inner join
			SCGI.[dbo].[SIST_PERSONA] personas on usuarios.idPersona = personas.idPersona	
		where
			upper(usuarios.usuario) = upper(@pCorreoCedula)
		and
			PRESONLINE.dbo.FN_GET_CLAVE_PERSONA(usuarios.idPersona,'') = @pClave;

		
		insert into @temporal
		exec PRESONLINE.dbo.PA_PRESONLINE_ENCRYPTADECRYPTA_IDPERSONA 1, @idPersona,'N'

		set @zip = (select zip from @temporal);

		select
			isnull(@nombreCompleto,'')				as nombreCompleto,
			isnull(@idPersona,0)					as idPersona,
 			isnull(@idUsuario,0)					as idUsuario,
			isnull(@correoUsuario,'')				as correoUsuario,
			isnull(@correoNotificaciones,'')		as correoNotificaciones,
			isnull(@requiereActualizar,'')			as requiereActualizar,
			isnull(@telefonoMovil,'')				as telefonoMovil,
			isnull(@indicadorTipoUsuarioSICGI,'')	as indicadorTipoUsuarioSICGI,
			isnull(@zip,'')							as zip,
			isnull(@usarDobleFactor,'')				as usarDobleFactor

	End Try
	Begin Catch
		
	End Catch
END