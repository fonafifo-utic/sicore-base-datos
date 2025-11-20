USE [SICORE]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FN_GET_CLAVE_USUARIO]') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
  DROP FUNCTION [dbo].[FN_GET_CLAVE_USUARIO]
GO

-- =============================================
-- Author:		Rogelio Solano A
-- Create date: OCt 2023
-- Description:	Esta funcion descifra la contraseña de un usuario.
-- Comentario: Modificado para el proyecto SICORE.
-- Modificador: Álvaro Zamora Solís.
-- Fecha modificación: 26-06-2024
-- =============================================


Create Function [dbo].[FN_GET_CLAVE_USUARIO] 
(
	@pIdUsuario varchar(20),
	@pIdPerfil bigint
)
Returns varchar(20)

Begin
	Declare @resultado varchar(50);
	declare @idPersona bigint
	
	if(@pIdPerfil=1 or @pIdPerfil=7)--Si es un cliente o un funcionario de fideicomiso
	Begin
		Set @resultado =
			isNull
			(
				(
					Select 
						Reverse
						(
							Replace(
								Left
								(
									subString(Cast(claveTemporal as varchar(50)), charIndex('~',Cast(claveTemporal as varchar(50)))+1,100),
									charIndex
									(
										'~',
										subString(Cast(claveTemporal as varchar(50)), charIndex('~',Cast(claveTemporal as varchar(50)))+1,100)
									)
								), '~',''
							)
						)
					From SICORE_USUARIO
					Where 
					(				
						(@pIdUsuario <> '' And @pIdUsuario = idUsuario)
					)
				),''
			);
	End
	Else--Si es un funcionario de fonafifo
		Begin
			Select @idPersona=idPersona from SICORE_USUARIO Where idUsuario=@pIdUsuario
			Set @resultado =
				isNull
				(
					(
						Select 
							Reverse
							(
								Replace(
									Left
									(
										subString(Cast(claveTemporal as varchar(50)), charIndex('~',Cast(claveTemporal as varchar(50)))+1,100),
										charIndex
										(
											'~',
											subString(Cast(claveTemporal as varchar(50)), charIndex('~',Cast(claveTemporal as varchar(50)))+1,100)
										)
									), '~',''
								)
							)
						From SCGI..SIST_USUARIO
						Where 
						(				
							(@idPersona <> '' And @idPersona = idPersona)
						)
					),''
				);
		End

	Return(@resultado);
END;