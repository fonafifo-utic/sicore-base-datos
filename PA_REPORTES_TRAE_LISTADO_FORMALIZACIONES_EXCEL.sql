use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Junio 2025
-- Description:	Trae un listado de Formalizaciones filtradas por fecha desde el principio de año a hoy.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_REPORTES_TRAE_LISTADO_FORMALIZACIONES_EXCEL]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_REPORTES_TRAE_LISTADO_FORMALIZACIONES_EXCEL]
GO

CREATE PROCEDURE [dbo].[PA_REPORTES_TRAE_LISTADO_FORMALIZACIONES_EXCEL]
AS
BEGIN TRY
	BEGIN TRAN

		declare @annoVigente as varchar(10) = year(getdate());
		declare @fechaInicio as date = @annoVigente + '-01-01';
		declare @pfechaFinal as date = cast(getdate() as date);

		select
			cotizacion.consecutivo												as consecutivo,
			dbo.FN_GET_CAMEL_CASE(sector.sectorComercial)						as [sector_comercial],
			dbo.FN_GET_CAMEL_CASE(cliente.nombreCliente)						as [nombre_cliente],
			convert(varchar, formalizacion.fechaHora, 105) + ' ' +
			convert(varchar(5), formalizacion.fechaHora, 108)					as [fecha_hora],
			convert(decimal(10,2), formalizacion.montoDolares)					as [monto_dolares],
			formalizacion.numeroTransferencia									as [numero_transferencia],
			formalizacion.numeroFacturaFonafifo									as [numero_facturaFonafifo],
			cotizacion.tipoCompra												as [tipo_compra],
			case
				when formalizacion.creditoDebito = 'D' then
					'Contado'
				when formalizacion.creditoDebito = 'C' then
					'Crédito'
			end																	as [credito_debito],
			case
					when cotizacion.cuentaConvenio = 'F' then
						'FID-544-17'
					when cotizacion.cuentaConvenio = 'N' then
						'Banco Nacional de Costa Rica'
					when cotizacion.cuentaConvenio = 'M' then
						'FID-544-13'
				end																as cuentaPago,
			dbo.FN_GET_CAMEL_CASE(persona.nombre) + ' ' +
			dbo.FN_GET_CAMEL_CASE(persona.primerApellido) + ' ' +
			dbo.FN_GET_CAMEL_CASE(persona.segundoApellido)						as usuario
		from
			SICORE_FORMALIZACION formalizacion
		inner join
			SICORE_COTIZACION cotizacion on formalizacion.idCotizacion = cotizacion.idCotizacion
		inner join
			SICORE_CLIENTE cliente on cotizacion.idCliente = cliente.idCliente
		inner join
			SICORE_SECTOR_COMERCIAL sector on cliente.idSector = sector.idSectorComercial
		left outer join
			SICORE_USUARIO usuario on formalizacion.idFuncionario = usuario.idUsuario
		left outer join
			SCGI..SIST_FUNCIONARIOS funcionario on usuario.idUsuario = funcionario.idUsuario
		left outer join
			SCGI..SIST_PERSONA persona on funcionario.idPersona = persona.idPersona
		where
			cast(formalizacion.fechaHora as date) between @fechaInicio and @pfechaFinal
		order by
			formalizacion.idFormalizacion asc;
	
	COMMIT
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE()
	ROLLBACK
END CATCH