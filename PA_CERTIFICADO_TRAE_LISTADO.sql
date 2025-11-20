use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Octubre 2024
-- Description:	Trae todos los registros de la tabla Certificaciones.
-- Modificación: Marzo 2025
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_CERTIFICADO_TRAE_LISTADO]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_CERTIFICADO_TRAE_LISTADO]
GO

CREATE PROCEDURE [dbo].[PA_CERTIFICADO_TRAE_LISTADO]
AS
BEGIN TRY

	declare @tipoCambio decimal(18,2) = (select top 1 cambio.tipoCompra from SIFIN..TIPO_CAMBIO_MONEDA cambio order by cambio.fechaTipoVenta desc);

	select
		certificado.idCertificado,
		certificado.idFormalizacion,
		certificado.idCotizacion,
		certificado.idFuncionario,
		certificado.idCliente,
		certificado.usuario,
		certificado.numeroCertificado,
		certificado.nombreCertificado,
		certificado.fechaEmisionCertificado,
		certificado.cedulaJuridicaComprador,
		certificado.montoTransferencia,
		certificado.numeroTransferencia,
		certificado.fechaTransferencia,
		certificado.annoInventarioGEI,
		certificado.consecutivo,
		certificado.nombreArchivo,
		certificado.anotaciones,
		certificado.indicadorEstado,
		certificado.numeroCertificadoUnico
	from
		(select
			cast(certificado.idCertificado as varchar(10)) idCertificado,
			cast(certificado.idFormalizacion as varchar(10)) idFormalizacion,
			cast(certificado.idCotizacion as varchar(10)) idCotizacion,
			cast(certificado.idFuncionario as varchar(10)) idFuncionario,
			cast(cotizacion.idCliente as varchar(10)) idCliente,
			dbo.FN_GET_CAMEL_CASE(persona.nombre) + ' ' + dbo.FN_GET_CAMEL_CASE(persona.primerApellido) + ' ' + dbo.FN_GET_CAMEL_CASE(persona.segundoApellido) usuario,
			numeroCertificado,
			dbo.FN_GET_CAMEL_CASE(nombreCertificado) nombreCertificado,
			fechaEmisionCertificado,
			cedulaJuridicaComprador,
			montoTransferencia,
			numeroTransferencia,
			fechaTransferencia,
			annoInventarioGEI,
			cotizacion.consecutivo,
			isnull(expediente.nombreArchivo, '') nombreArchivo,
			cotizacion.anotaciones,
			case
				when certificado.indicadorEstado = 'A' then
					'Activo'
				when certificado.indicadorEstado = 'E' then
					'Enviado'
				when certificado.indicadorEstado = 'V' then
					'Pendiente Validación'
				when certificado.indicadorEstado = 'U' then
					'Uso Interno'
			end indicadorEstado,
			certificado.numeroCertificadoUnico
		from
			SICORE_CERTIFICADO certificado
		inner join
			SICORE_COTIZACION cotizacion on certificado.idCotizacion = cotizacion.idCotizacion
		left outer join
			SICORE_USUARIO usuario on certificado.idFuncionario = usuario.idUsuario
		left outer join
			SCGI..SIST_FUNCIONARIOS funcionario on usuario.idUsuario = funcionario.idUsuario
		left outer join
			SCGI..SIST_PERSONA persona on funcionario.idPersona = persona.idPersona
		left outer join
			SICORE_EXPEDIENTE expediente on certificado.idCertificado = expediente.idCertificado
										and expediente.idProyecto = 0
										and expediente.idCotizacion = 0
										and expediente.idFormalizacion = 0
		where
			cotizacion.idCotizacion not in (select idCotizacion from SICORE_COTIZACION_AGRUPACION)
		union
		select
			string_agg(certificado.idCertificado, ', ') idCertificado,
			string_agg(certificado.idFormalizacion, ', ') idFormalizacion,
			string_agg(certificado.idCotizacion, ', ') idCotizacion,
			string_agg(certificado.idFuncionario, ', ') idFuncionario,
			string_agg(cotizacion.idCliente, ', ') idCliente,
			string_agg(dbo.FN_GET_CAMEL_CASE(persona.nombre) + ' ' + 
			dbo.FN_GET_CAMEL_CASE(persona.primerApellido) + ' ' +
			dbo.FN_GET_CAMEL_CASE(persona.segundoApellido), ', ') usuario,
			max(certificado.numeroCertificado) numeroCertificado,
			string_agg(dbo.FN_GET_CAMEL_CASE(certificado.nombreCertificado), ', ') nombreCertificado,
			max(certificado.fechaEmisionCertificado) fechaEmisionCertificado,
			string_agg(certificado.cedulaJuridicaComprador, ', ') cedulaJuridicaComprador,
			sum(certificado.montoTransferencia) montoTransferencia,
			certificado.numeroTransferencia,
			certificado.fechaTransferencia,
			certificado.annoInventarioGEI,
			max(agrupada.consecutivo) consecutivo,
			isnull(expediente.nombreArchivo, '') nombreArchivo,
			string_agg(cotizacion.anotaciones, ', ') anotaciones,
			case
				when certificado.indicadorEstado = 'A' then
					'Activo'
				when certificado.indicadorEstado = 'E' then
					'Enviado'
				when certificado.indicadorEstado = 'V' then
					'Pendiente Validación'
			end indicadorEstado,
			max(certificado.numeroCertificadoUnico) numeroIdentificacionUnico
		from
			SICORE_CERTIFICADO certificado
		inner join
			SICORE_COTIZACION_AGRUPACION agrupada on certificado.idCotizacion = agrupada.idCotizacion
		inner join
			SICORE_COTIZACION cotizacion on certificado.idCotizacion = cotizacion.idCotizacion
		left outer join
			SICORE_USUARIO usuario on certificado.idFuncionario = usuario.idUsuario
		left outer join
			SCGI..SIST_FUNCIONARIOS funcionario on usuario.idUsuario = funcionario.idUsuario
		left outer join
			SCGI..SIST_PERSONA persona on funcionario.idPersona = persona.idPersona
		left outer join
			SICORE_EXPEDIENTE expediente on certificado.idCertificado = expediente.idCertificado
										and expediente.idProyecto = 0
										and expediente.idCotizacion = 0
										and expediente.idFormalizacion = 0
		where
			agrupada.indicadorEstado = 'F'
		and
			cotizacion.indicadorEstado = 'F'
		group by
			certificado.numeroTransferencia,
			certificado.fechaTransferencia,
			certificado.annoInventarioGEI,
			certificado.indicadorEstado,
			expediente.nombreArchivo
		) as certificado
	order by
		certificado.fechaEmisionCertificado desc;

END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE()
END CATCH