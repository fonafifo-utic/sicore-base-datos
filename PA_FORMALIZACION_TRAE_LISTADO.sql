use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Octubre 2024
-- Description:	Trae todos los registros de Formalización.
-- Modificación: Marzo 2025
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_FORMALIZACION_TRAE_LISTADO]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_FORMALIZACION_TRAE_LISTADO]
GO

CREATE PROCEDURE [dbo].[PA_FORMALIZACION_TRAE_LISTADO]
AS
BEGIN TRY
	BEGIN TRAN

		declare @tipoCambio decimal(18,2) = (select top 1 cambio.tipoCompra from SIFIN..TIPO_CAMBIO_MONEDA cambio order by cambio.fechaTipoVenta desc);
		
		select
			formalizaciones.idFormalizacion,
			formalizaciones.idCotizacion,
			formalizaciones.idCliente,
			formalizaciones.cedulaCliente,
			formalizaciones.nombreCliente,
			formalizaciones.nombreComercial,
			formalizaciones.fechaHora,
			formalizaciones.montoDolares,
			formalizaciones.montoColones,
			formalizaciones.consecutivo,
			formalizaciones.numeroFacturaFonafifo,
			formalizaciones.numeroTransferencia,
			formalizaciones.numeroComprobante,
			formalizaciones.indicadorEstado,
			formalizaciones.creditoDebito,
			formalizaciones.idUsuario,
			formalizaciones.usuario,
			formalizaciones.tieneFacturas,
			formalizaciones.tipoCambio,
			formalizaciones.justificacionActivacion
		from
			(
				select
					cast(formalizacion.idFormalizacion as varchar(10)) idFormalizacion,
					cast(cotizacion.idCotizacion as varchar(10)) idCotizacion,
					cast(cliente.idCliente as varchar(10)) idCliente,
					cliente.cedulaCliente,
					dbo.FN_GET_CAMEL_CASE(cliente.nombreCliente) nombreCliente,
					dbo.FN_GET_CAMEL_CASE(cliente.nombreComercial) nombreComercial,
					formalizacion.fechaHora,
					formalizacion.montoDolares,
					@tipoCambio * formalizacion.montoDolares montoColones,
					formalizacion.consecutivo,
					formalizacion.numeroFacturaFonafifo,
					formalizacion.numeroTransferencia,
					formalizacion.numeroComprobante,
					case
						when formalizacion.indicadorEstado = 'P' then 'Pendiente'
						when formalizacion.indicadorEstado = 'F' then 'Formalizado'
						when formalizacion.indicadorEstado = 'C' then 'Pendiente Crédito'
						when formalizacion.indicadorEstado = 'K' then 'Pendiente Cierre'
						when formalizacion.indicadorEstado = 'V' then 'Pendiente Aprobación'
						when formalizacion.indicadorEstado = 'R' then 'Rechazada'
						when formalizacion.indicadorEstado = 'U' then 'Uso Interno'
					end indicadorEstado,
					case
						when formalizacion.creditoDebito = 'D' then 'Contado'
						when formalizacion.creditoDebito = 'C' then 'Crédito'
					end creditoDebito,
					cast(usuario.idUsuario as varchar(10)) idUsuario,
					persona.nombre + ' ' + persona.primerApellido + ' ' + persona.segundoApellido usuario,
					formalizacion.tieneFacturas,
					@tipoCambio tipoCambio,
					justificacionActivacion
				from
					SICORE_FORMALIZACION formalizacion
				inner join
					SICORE_COTIZACION cotizacion on formalizacion.idCotizacion = cotizacion.idCotizacion
				inner join
					SICORE_CLIENTE cliente on cotizacion.idCliente = cliente.idCliente
				left outer join
					SICORE_USUARIO usuario on cotizacion.idFuncionario = usuario.idUsuario
				left outer join
					SCGI..SIST_FUNCIONARIOS funcionario on usuario.idUsuario = funcionario.idUsuario
				left outer join
					SCGI..SIST_PERSONA persona on funcionario.idPersona = persona.idPersona
				where
					formalizacion.indicadorEstado != 'U'
				and
					cotizacion.idCotizacion not in (select idCotizacion from SICORE_COTIZACION_AGRUPACION)
				union
				select
					string_agg(formalizacion.idFormalizacion, ', ') idFormalizacion,
					string_agg(formalizacion.idCotizacion, ', ') idCotizacion,
					string_agg(cliente.idCliente, ', ') idCliente,
					string_agg(cliente.cedulaCliente, ', ') cedulaCliente,
					string_agg(dbo.FN_GET_CAMEL_CASE(cliente.nombreCliente), ', ') nombreCliente,
					string_agg(dbo.FN_GET_CAMEL_CASE(cliente.nombreComercial), ', ') nombreComercial,
					max(formalizacion.fechaHora) fechaHora,
					sum(formalizacion.montoDolares) montoDolares,
					@tipoCambio * sum(formalizacion.montoDolares) montoColones,
					agrupada.consecutivo,
					formalizacion.numeroFacturaFonafifo,
					formalizacion.numeroTransferencia,
					formalizacion.numeroComprobante,
					case
						when formalizacion.indicadorEstado = 'P' then 'Pendiente'
						when formalizacion.indicadorEstado = 'F' then 'Formalizado'
						when formalizacion.indicadorEstado = 'C' then 'Pendiente Crédito'
						when formalizacion.indicadorEstado = 'K' then 'Pendiente Cierre'
						when formalizacion.indicadorEstado = 'V' then 'Pendiente Aprobación'
						when formalizacion.indicadorEstado = 'R' then 'Rechazada'
						when formalizacion.indicadorEstado = 'U' then 'Uso Interno'
					end indicadorEstado,
					case
						when formalizacion.creditoDebito = 'D' then 'Contado'
						when formalizacion.creditoDebito = 'C' then 'Crédito'
					end creditoDebito,
					string_agg(usuario.idUsuario, ', ') idUsuario,
					string_agg(persona.nombre + ' ' + persona.primerApellido + ' ' + persona.segundoApellido, ', ') usuario,
					formalizacion.tieneFacturas,
					@tipoCambio tipoCambio,
					formalizacion.justificacionActivacion
				from
					SICORE_FORMALIZACION formalizacion
				inner join
					SICORE_COTIZACION_AGRUPACION agrupada on formalizacion.idCotizacion = agrupada.idCotizacion
				inner join
					SICORE_COTIZACION cotizacion on formalizacion.idCotizacion = cotizacion.idCotizacion
				inner join
					SICORE_CLIENTE cliente on cotizacion.idCliente = cliente.idCliente
				left outer join
					SICORE_USUARIO usuario on cotizacion.idFuncionario = usuario.idUsuario
				left outer join
					SCGI..SIST_FUNCIONARIOS funcionario on usuario.idUsuario = funcionario.idUsuario
				left outer join
					SCGI..SIST_PERSONA persona on funcionario.idPersona = persona.idPersona
				where
					formalizacion.indicadorEstado != 'U'
				and
					agrupada.indicadorEstado in ('P', 'F')
				group by
					agrupada.consecutivo,
					formalizacion.numeroFacturaFonafifo,
					formalizacion.numeroTransferencia,
					formalizacion.numeroComprobante,
					formalizacion.indicadorEstado,
					formalizacion.creditoDebito,
					formalizacion.tieneFacturas,
					formalizacion.justificacionActivacion
			) as formalizaciones
		order by
			formalizaciones.fechaHora desc

	COMMIT
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE();
	ROLLBACK;
END CATCH