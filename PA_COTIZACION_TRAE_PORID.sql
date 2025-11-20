use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Julio 2024
-- Description:	Trae los registros de la tabla Cotización filtrados por ID.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_COTIZACION_TRAE_PORID]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_COTIZACION_TRAE_PORID]
GO

CREATE PROCEDURE [dbo].[PA_COTIZACION_TRAE_PORID] (@pIdCotizacion as int)
AS
BEGIN TRY
	BEGIN TRANSACTION

		declare @tipoCambio decimal(18,2) = (select top 1 tipoVenta from SIFIN..TIPO_CAMBIO_MONEDA order by fechaTipoVenta desc)
		--declare @tipoCambio decimal(18,2) = 503.04;
		
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
			persona.nombreCorto,
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
			end indicadorEstado,
			cotizacion.cuentaConvenio,
			cotizacion.cotizacionEnIngles,
			cotizacion.cotizacionEnviada,
			@tipoCambio tipoCambio,
			tipoCompra,
			justificacionCompra,
			observacionDeAprobacion
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
			SCGI..SIST_PERSONA persona on funcionario.idPersona = persona.idPersona
		where
			cotizacion.idCotizacion = @pIdCotizacion

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK
END CATCH