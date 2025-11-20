use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Octubre 2025
-- Description:	Trae las cotizaciones que están activas.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_COTIZACION_TRAE_LISTADO_ACTIVAS]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_COTIZACION_TRAE_LISTADO_ACTIVAS]
GO

CREATE PROCEDURE [dbo].[PA_COTIZACION_TRAE_LISTADO_ACTIVAS]
AS
BEGIN TRY
	
	declare @tipoCambio decimal(18,2) = (select top 1 tipoCompra from SIFIN..TIPO_CAMBIO_MONEDA order by fechaTipoVenta desc);

	select
		cotizacion.idCotizacion,
		cliente.idCliente,
		dbo.FN_GET_CAMEL_CASE(cliente.nombreCliente) nombreCliente,
		cliente.cedulaCliente,
		dbo.FN_GET_CAMEL_CASE(cliente.contactoCliente) contactoCliente,
		cliente.telefonoCliente,
		lower(cliente.emailCliente) emailCliente,
		cliente.direccionFisica,
		sector.sectorComercial,
		usuario.idUsuario,
		dbo.FN_GET_NOMBRE_CORTO_FUNCIONARIO(usuario.idUsuario) nombreCorto,
		proyecto.idProyecto,
		dbo.FN_GET_CAMEL_CASE(proyecto.proyecto) proyecto,
		cotizacion.fechaHora,
		cotizacion.fechaExpiracion,
		cotizacion.cantidad,
		cotizacion.precioUnitario,
		cotizacion.subTotal,
		cotizacion.montoTotalColones,
		cotizacion.montoTotalDolares,
		cotizacion.consecutivo,
		cotizacion.anotaciones,
		case
			when cotizacion.indicadorEstado = 'A' then
				'Activa'
		end indicadorEstado,
		cotizacion.cuentaConvenio,
		cotizacion.cotizacionEnIngles,
		cotizacion.cotizacionEnviada,
		@tipoCambio tipoCambio,
		(select
			sum(datediff(day, fechaHora, getdate()))
		from
			SICORE_COTIZACION_TRAZABILIDAD
		where
			idCotizacion = cotizacion.idCotizacion) cantidadDiasEnviado,
		tipoCompra,
		justificacionCompra,
		dbo.FN_GET_NOMBRE_CORTO_FUNCIONARIO(cliente.idAgenteCuenta) agenteCuenta
	from
		SICORE_COTIZACION cotizacion
	inner join
		SICORE_CLIENTE cliente on cotizacion.idCliente = cliente.idCliente
	inner join
		SICORE_SECTOR_COMERCIAL sector on cliente.idSector = sector.idSectorComercial
	inner join
		SICORE_PROYECTO proyecto on cotizacion.idProyecto = proyecto.idProyecto
	left outer join
		SICORE_USUARIO usuario on cotizacion.idFuncionario = usuario.idUsuario
	left outer join
		SCGI..SIST_FUNCIONARIOS funcionario on usuario.idUsuario = funcionario.idUsuario
	where
		cotizacion.indicadorEstado IN ('A')
	and
		cotizacion.idCotizacion not in (select idCotizacion from SICORE_COTIZACION_AGRUPACION where indicadorEstado in ('V'))
	order by
		cotizacion.idCotizacion desc

END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE()
END CATCH