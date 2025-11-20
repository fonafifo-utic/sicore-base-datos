use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Julio 2024
-- Description:	Trae una Formalización para ser visualizada por ID de formalización.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_FORMALIZACION_TRAE_FORMALIZACION_PORID]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_FORMALIZACION_TRAE_FORMALIZACION_PORID]
GO

CREATE PROCEDURE [dbo].[PA_FORMALIZACION_TRAE_FORMALIZACION_PORID] (@pIdFormalizacion nvarchar(max))
AS
BEGIN TRY
	BEGIN TRAN

		select
			formalizacion.idFormalizacion,
			cotizacion.idCotizacion,
			proyecto.idProyecto,
			cliente.idCliente,
			proyecto.proyecto,
			formalizacion.consecutivo,
			case
				when formalizacion.creditoDebito = 'D' then
					'Contado'
				when formalizacion.creditoDebito = 'C' then
					'Crédito'
			end creditoDebito,
			formalizacion.fechaHora,
			formalizacion.fechaHoraFormalizacion,
			formalizacion.numeroFacturaFonafifo,
			formalizacion.numeroTransferencia,
			case
				when formalizacion.indicadorEstado = 'P' then 'Pendiente'
				when formalizacion.indicadorEstado = 'F' then 'Formalizado'
				when formalizacion.indicadorEstado = 'C' then 'Pendiente Crédito'
				when formalizacion.indicadorEstado = 'K' then 'Pendiente Cierre'
				when formalizacion.indicadorEstado = 'V' then 'Pendiente Aprobación'
				when formalizacion.indicadorEstado = 'R' then 'Rechazada'
			end indicadorEstado,
			formalizacion.idFuncionario,
			cotizacion.cantidad,
			cotizacion.montoTotalDolares,
			cotizacion.precioUnitario,
			cotizacion.subTotal,
			cotizacion.anotaciones,
			dbo.FN_GET_CAMEL_CASE(cliente.cedulaCliente) cedulaCliente,
			dbo.FN_GET_CAMEL_CASE(cliente.contactoCliente) contactoCliente,
			dbo.FN_GET_CAMEL_CASE(cliente.direccionFisica) direccionFisica,
			lower(cliente.emailCliente) emailCliente,
			dbo.FN_GET_CAMEL_CASE(cliente.nombreCliente) nombreCliente,
			dbo.FN_GET_CAMEL_CASE(cliente.nombreComercial) nombreComercial,
			cliente.telefonoCliente,
			dbo.FN_GET_CAMEL_CASE(isnull(cliente.contactoContador,'')) contactoContador,
			lower(isnull(cliente.emailContador, '')) emailContador,
			justificacionActivacion,
			cliente.ucii numeroCIIU
		from
			SICORE_FORMALIZACION formalizacion
		inner join
			SICORE_COTIZACION cotizacion on formalizacion.idCotizacion = cotizacion.idCotizacion
		inner join
			SICORE_PROYECTO proyecto on cotizacion.idProyecto = proyecto.idProyecto
		inner join
			SICORE_CLIENTE cliente on cotizacion.idCliente = cliente.idCliente
		where
			formalizacion.idFormalizacion in (select value from string_split(@pIdFormalizacion, ',') where value != '')

	COMMIT
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE()
	ROLLBACK
END CATCH