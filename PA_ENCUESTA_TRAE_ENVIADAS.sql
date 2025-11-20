use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Abril 2025
-- Description:	Trae todas las encuestas enviadas.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_ENCUESTA_TRAE_ENVIADAS]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_ENCUESTA_TRAE_ENVIADAS]
GO

CREATE PROCEDURE [dbo].[PA_ENCUESTA_TRAE_ENVIADAS]
AS
BEGIN TRY

	select
		traza.idTrazaEncuesta,
		cliente.idCliente,
		cliente.emailCliente,
		dbo.FN_GET_CAMEL_CASE(cliente.nombreCliente) nombreCliente,
		certificado.numeroCertificado,
		dbo.FN_GET_CAMEL_CASE(persona.nombre) + ' ' + dbo.FN_GET_CAMEL_CASE(persona.primerApellido) + ' ' + dbo.FN_GET_CAMEL_CASE(persona.segundoApellido) usuario,
		traza.fechaHoraEnvio,
		case
			when (select fechaHoraRespuesta from SICORE_ENCUESTA_TRAZA where idTrazaEncuesta = traza.idTrazaEncuesta) is null then
				'Pendiente'
			else
				'Respondida'
		end 
			estado,
		certificado.idCotizacion,
		traza.conteoEnvios
	from
		SICORE_ENCUESTA_TRAZA traza
	inner join
		SICORE_CLIENTE cliente on traza.idCliente = cliente.idCliente
	inner join
		SICORE_CERTIFICADO certificado on traza.idCertificado = certificado.idCertificado
	left outer join
		SICORE_USUARIO usuario on certificado.idFuncionario = usuario.idUsuario
	left outer join
		SCGI..SIST_FUNCIONARIOS funcionario on usuario.idUsuario = funcionario.idUsuario
	left outer join
		SCGI..SIST_PERSONA persona on funcionario.idPersona = persona.idPersona
	order by
		traza.idTrazaEncuesta desc;
		
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE();

	ROLLBACK TRAN
END CATCH