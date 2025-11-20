USE [SICORE]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FN_GET_EMAILS_FINANCIERO]') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
  DROP FUNCTION [dbo].[FN_GET_EMAILS_FINANCIERO]
GO

-- =============================================
-- Author:		Álvaro Zamora Solís.
-- Create date: Junio 2025
-- Description:	Trae todos los correos electrónicos del perfil de Financiero.
-- =============================================

create function [dbo].[FN_GET_EMAILS_FINANCIERO] ()
returns nvarchar(max)

begin
	declare @min int = (select min(idUsuario) from SICORE_USUARIO where idPerfil = 3)
	declare @max int = (select max(idUsuario) from SICORE_USUARIO where idPerfil = 3)
	declare @salida nvarchar(max) = '';

	while (@min <= @max)
	begin

		declare @idFuncionario int = (select idUsuario from SICORE_USUARIO where idUsuario = @min);
		set @salida = @salida + (select usuario from SCGI..SIST_USUARIO where idUsuario = @idFuncionario) + ';';

		set @min = (select min(idUsuario) from SICORE_USUARIO where idUsuario > @min and idPerfil = 3);
	end

	set @salida = substring(@salida, 1, len(@salida)-1);

	return @salida;

end;