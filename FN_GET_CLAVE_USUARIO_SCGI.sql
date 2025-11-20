USE [SICORE]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FN_GET_CLAVE_USUARIO_SCGI]') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
  DROP FUNCTION [dbo].[FN_GET_CLAVE_USUARIO_SCGI]
GO

-- =============================================
-- Author:		Rogelio Solano A
-- Create date: OCt 2023
-- Description:	Esta funcion descifra la contraseña de un usuario funcionario desde la tabla de SCGI..SIST_USUARIO
-- Comentario: Modificado para el proyecto SICORE.
-- Modificador: Álvaro Zamora Solís.
-- Fecha modificación: 26-06-2024
-- =============================================

Create Function [dbo].[FN_GET_CLAVE_USUARIO_SCGI] 
(
	@pIdPersona bigint,
	@pIdUsuario bigint
)
Returns varchar(20)

Begin
	Declare @resultado varchar(50);

		Set @resultado =
		isNull
		(
			(
				Select top 1
					Reverse
					(
						Replace(
							Left
							(
								subString(Cast(claveB as varchar(50)), charIndex('~',Cast(claveB as varchar(50)))+1,100),
								charIndex
								(
									'~',
									subString(Cast(claveB as varchar(50)), charIndex('~',Cast(claveB as varchar(50)))+1,100)
								)
							), '~',''
						)
					)
				From SCGI..SIST_USUARIO
				Where 
				(
					 @pIdPersona = idPersona
				)
			),''
		);
	
	
	Return(@resultado);
END;
