USE [SICORE]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FN_GET_NOMBRE_CORTO_FUNCIONARIO]') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
  DROP FUNCTION [dbo].[FN_GET_NOMBRE_CORTO_FUNCIONARIO]
GO

-- =============================================
-- Author:		Álvaro Zamora Solís.
-- Create date: Junio 2025
-- Description:	Hace un Camel Case para Nombre de Funcionario.
-- =============================================

create function [dbo].[FN_GET_NOMBRE_CORTO_FUNCIONARIO]
(
	@pIdFuncionario bigint
)
returns nvarchar(max)

begin

	declare @idPersona int = (select idPersona from SCGI..SIST_USUARIO where idUsuario = @pIdFuncionario);

	declare @salida nvarchar(max) = (
										select
											dbo.FN_GET_CAMEL_CASE(nombre) + ' ' + 
											dbo.FN_GET_CAMEL_CASE(primerApellido) + ' ' + 
											dbo.FN_GET_CAMEL_CASE(segundoApellido)
										from
											SCGI..SIST_PERSONA
										where
											idPersona = @idPersona
									);

	return @salida;

end;