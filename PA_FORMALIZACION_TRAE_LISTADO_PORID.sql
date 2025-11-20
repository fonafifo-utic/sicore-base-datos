use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Julio 2024
-- Description:	Trae todos los registros de la tabla Formalización filtrados por ID de formalización.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_FORMALIZACION_TRAE_LISTADO_PORID]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_FORMALIZACION_TRAE_LISTADO_PORID]
GO

CREATE PROCEDURE [dbo].[PA_FORMALIZACION_TRAE_LISTADO_PORID] (@pIdFormalizacion int)
AS
BEGIN TRY
	BEGIN TRAN

		declare @tipoCambio decimal(18,2) = (select top 1 cambio.tipoCompra from SIFIN..TIPO_CAMBIO_MONEDA cambio order by cambio.fechaTipoVenta desc);

		select
			formalizacion.idFormalizacion,
			cotizacion.idCotizacion,
			cliente.idCliente,
			cliente.cedulaCliente,
			cliente.nombreCliente,
			cliente.nombreComercial,
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
			usuario.idUsuario,
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
			idFormalizacion = @pIdFormalizacion
		and
			formalizacion.indicadorEstado != 'U'

	COMMIT
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE()
	ROLLBACK
END CATCH