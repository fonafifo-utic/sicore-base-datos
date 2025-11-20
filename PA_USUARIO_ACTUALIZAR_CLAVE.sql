USE [SICORE]
GO

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_USUARIO_ACTUALIZAR_CLAVE]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_USUARIO_ACTUALIZAR_CLAVE]
GO

-- =============================================
-- Author:		Rogelio Solano A
-- Create date: 01 Oct 2023
-- Descripción: Este PA se encarga de actualizar la clave de un usuario cuando esta esté vencida, o se haya asignado una temporal.
-- Solamente se pasa el idPersona dado que este PA se llama posterior al Login, entonces ya se puede obtener este parámetro si el login fue exitoso.
-- Como manejamos dos escenarios de usuario, el cliente que se registra en la base de credifor y los funcionarios que estan en SCGI, hay que validar q tipo de cliente es para así saber
-- actualizar la info.
-- Comentario: Adaptación para SICORE, por parte de Álvaro Zamora S.
-- Fecha Adaptación: 25 jun 2024
-- =============================================


CREATE PROCEDURE [dbo].[PA_USUARIO_ACTUALIZAR_CLAVE] 
	-- Add the parameters for the stored procedure here
	@pIdUsuario bigint,
	@pClave varchar(20),
	@pIdPerfil bigint,
	@pIdPersona bigint
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @r int
	declare @istemporal varchar(2)
	declare @claveanterior varchar(50)
	set @pIdUsuario = (select idUsuario from SICORE_USUARIO where idPersona = @pIdPersona);

	Begin Try
		Begin Transaction tProcess

			if(not exists(Select 1 from (Select top 6 clave from SICORE_HISTO_CLAVES where idUsuario=@pIdUsuario order by fechaRegistro desc)as h Where h.clave=@pClave))
				set @r=0;			
			else
				set @r=1;

			if(@r=0)
			begin
				Select @istemporal = esClaveTemporal from SICORE_USUARIO Where idUsuario=@pIdUsuario
				Set @claveanterior = dbo.FN_GET_CLAVE_USUARIO(@pIdUsuario,@pIdPerfil)

				set @istemporal = 'S'
				select @istemporal , @claveanterior

				if(@istemporal='N')
				begin
			
					Update
						SICORE_USUARIO
					Set
						claveTemporal=Cast
						(
							(
								Right(NEWID(),5) + '~' + 
								Reverse(@pClave) + '~' + 
								Cast(Cast( Replace(Reverse(Convert(varchar(20), CURRENT_TIMESTAMP, 114)),':','') as bigInt) + 
								idUsuario as varchar(50))
							)
							as Binary(50)
						),
						fechaVenceClave=DATEADD(DD,30,GetDate()),
						indicadorEstado='A',
						ultimoAcceso=GETDATE(),
						fechaModificoAuditoria=GETDATE(),
						idUsuarioModificoAuditoria=@pIdUsuario
					Where
						idUsuario=@pIdUsuario

					Insert Into SICORE_HISTO_CLAVES
					Values
						(@pIdUsuario,CONVERT(date, getdate()),@claveanterior,GetDate())
				end
				else
				begin
					if(@pClave!=@claveanterior)--Esto es para evitar que se ponga la misma clave temporal
					begin

						Update
							SICORE_USUARIO
						Set
							claveTemporal=Cast
							(
								(
									Right(NEWID(),5) + '~' + 
									Reverse(@pClave) + '~' + 
									Cast(Cast( Replace(Reverse(Convert(varchar(20), CURRENT_TIMESTAMP, 114)),':','') as bigInt) + 
									idUsuario as varchar(50))
								)
								as Binary(50)
							),
							fechaVenceClave=DATEADD(DD,30,GetDate()),
							indicadorEstado='A',
							ultimoAcceso=GETDATE(),
							fechaModificoAuditoria=GETDATE(),
							idUsuarioModificoAuditoria=@pIdUsuario
						Where
							idUsuario=@pIdUsuario

						Insert Into SICORE_HISTO_CLAVES
						Values
							(@pIdUsuario,CONVERT(date, getdate()),@claveanterior,GetDate())

					end
					else
					begin
						Select 2 as result --No se puede poner la misma clave temporal
					end
				end
			end
			else
				Select -1 as result
		
		Commit Transaction tProcess
		
		Select 1 as result

	End Try
	Begin Catch
		RollBack Transaction tProcess
		Select ERROR_MESSAGE() as result
	End Catch
END