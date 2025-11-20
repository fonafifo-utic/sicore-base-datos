use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Octubre 2024
-- Description:	Trae los registros de la tabla Certificado filtrados por ID.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_CERTIFICADO_TRAE_PORID]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_CERTIFICADO_TRAE_PORID]
GO

CREATE PROCEDURE [dbo].[PA_CERTIFICADO_TRAE_PORID] (@pIdCertificado varchar(150))
AS
BEGIN TRY
	
	declare @directorEjecutivo varchar(250) = (select directorEjecutivo from SICORE_PERSONALIZACION);

	select
		persona.nombre + ' ' + persona.primerApellido + ' ' + persona.segundoApellido usuario,
		usuarios.usuario emailUsuario,
		numeroCertificado,
		dbo.FN_GET_CAMEL_CASE(nombreCertificado) nombreCertificado,
		fechaEmisionCertificado,
		cedulaJuridicaComprador,
		montoTransferencia,
		numeroTransferencia,
		fechaTransferencia,
		annoInventarioGEI,
		cotizacion.cantidad,
		cotizacion.cuentaConvenio,
		dbo.FN_GET_CAMEL_CASE(proyecto.proyecto) proyecto,
		inventario.periodo,
		isnull(expediente.nombreArchivo, '') nombreArchivo,
		cotizacion.anotaciones,
		dbo.FN_GET_CAMEL_CASE(certificado.observaciones) observaciones,
		@directorEjecutivo directorEjecutivo,
		certificado.numeroIdentificacionInterno numeroIdentificacionUnico,
		certificado.cssCertificado,
		certificado.enIngles,
		certificado.indicadorEstado,
		certificado.justificacionEdicion,
		certificado.numeroCertificadoUnico
	from
		SICORE_CERTIFICADO certificado
	inner join
		SICORE_COTIZACION cotizacion on certificado.idCotizacion = cotizacion.idCotizacion
	inner join
		SICORE_PROYECTO proyecto on cotizacion.idProyecto = proyecto.idProyecto
	inner join
		SICORE_INVENTARIO inventario on cotizacion.idProyecto = inventario.idProyecto
	left outer join
		SICORE_USUARIO usuario on cotizacion.idFuncionario = usuario.idUsuario
	left outer join
		SCGI..SIST_FUNCIONARIOS funcionario on usuario.idUsuario = funcionario.idUsuario
	left outer join
		SCGI..SIST_PERSONA persona on funcionario.idPersona = persona.idPersona
	left outer join
		SCGI..SIST_USUARIO usuarios on usuario.idUsuario = usuarios.idUsuario
	left outer join
		SICORE_EXPEDIENTE expediente on certificado.idCertificado = expediente.idCertificado
	where
		certificado.idCertificado in (select value from string_split(@pIdCertificado, ',') where value != '');

END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE()
	ROLLBACK
END CATCH