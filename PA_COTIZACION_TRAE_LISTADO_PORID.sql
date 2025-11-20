use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Julio 2024
-- Description:	Trae todos los registros de la tabla Formalización filtrados por ID de formalización.
-- Modificación: Junio 2025
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_COTIZACION_TRAE_LISTADO_PORID]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_COTIZACION_TRAE_LISTADO_PORID]
GO

CREATE PROCEDURE [dbo].[PA_COTIZACION_TRAE_LISTADO_PORID] (@pIdCotizacion int)
AS
BEGIN TRY
	BEGIN TRAN

		declare @tipoCambio decimal(18,2) = (select top 1 tipoCompra from SIFIN..TIPO_CAMBIO_MONEDA order by fechaTipoVenta desc);

		select
			cotizacion.idCotizacion,
			cliente.idCliente,	
			cliente.nombreCliente,
			cliente.cedulaCliente,
			cliente.contactoCliente,
			cliente.telefonoCliente,
			cliente.emailCliente,
			cliente.direccionFisica,
			sector.sectorComercial,
			usuario.idUsuario,
			dbo.FN_GET_NOMBRE_CORTO_FUNCIONARIO(usuario.idUsuario) nombreCorto,
			proyecto.idProyecto,
			proyecto.proyecto,
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
				when cotizacion.indicadorEstado = 'I' then
					'Inactiva'
				when cotizacion.indicadorEstado = 'P' then
					'Pendiente'
				when cotizacion.indicadorEstado = 'F' then
					'Formalizada'
				when cotizacion.indicadorEstado = 'E' then
					'Enviada'
				when cotizacion.indicadorEstado = 'K' then
					'Pendiente Cierre'
				when cotizacion.indicadorEstado = 'V' then
					'Pendiente Validación'
				when cotizacion.indicadorEstado = 'R' then
					'Rechazada'
				when cotizacion.indicadorEstado = 'U' then
					'Uso Interno'
				when cotizacion.indicadorEstado = 'G' then
					'Agrupada'
			end indicadorEstado,
			cotizacion.cuentaConvenio,
			cotizacion.cotizacionEnIngles,
			cotizacion.cotizacionEnviada,
			@tipoCambio tipoCambio,
			datediff(day, traza.fechaHora, getdate()) cantidadDiasEnviado,
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
		left outer join
			SICORE_COTIZACION_TRAZABILIDAD traza on cotizacion.idCotizacion = traza.idCotizacion
		where
			cotizacion.idCotizacion = @pIdCotizacion;

	COMMIT
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE()
	ROLLBACK
END CATCH