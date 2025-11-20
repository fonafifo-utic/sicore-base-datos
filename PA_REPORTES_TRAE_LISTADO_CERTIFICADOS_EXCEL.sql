use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Julio 2025
-- Description:	Trae un listado de Certificados filtrados por fecha desde el principio de año a hoy.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_REPORTES_TRAE_LISTADO_CERTIFICADOS_EXCEL]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_REPORTES_TRAE_LISTADO_CERTIFICADOS_EXCEL]
GO

CREATE PROCEDURE [dbo].[PA_REPORTES_TRAE_LISTADO_CERTIFICADOS_EXCEL]
AS
BEGIN TRY
	BEGIN TRAN

		declare @annoVigente as varchar(10) = year(getdate());
		declare @pfechaInicio as date = @annoVigente + '-01-01';
		declare @pfechaFinal as date = cast(getdate() as date);
		declare @tipoCambio decimal(18,2) = (select top 1 tipoCompra from SIFIN..TIPO_CAMBIO_MONEDA order by fechaTipoVenta desc);

		select
			cast(annoInventarioGEI as varchar(10)) + '-' + 
			dbo.FN_GET_FORMATO_CONSECUTIVO(numeroCertificado)										as [numero_certificado],
			cotizacion.consecutivo																	as [consecutivo],
			dbo.FN_GET_CAMEL_CASE(sector.sectorComercial)											as [sector_comercial],
			dbo.FN_GET_CAMEL_CASE(cliente.nombreCliente)											as [nombre_certificado],
			convert(varchar, fechaEmisionCertificado, 105) + ' ' +		   
			convert(varchar(5), fechaEmisionCertificado, 108)										as [fecha_emision_certificado],
			cedulaJuridicaComprador																	as [cedula_juridica_comprador],
			'$ ' + cast(convert(decimal(10,2), montoTransferencia) as varchar(50))					as [monto_transferencia],
			'? ' + cast(convert(decimal(10,2), montoTransferencia * @tipoCambio) as varchar(50))	as [monto_transferencia_colones],
			numeroTransferencia																		as [numero_transferencia],
			convert(varchar, fechaTransferencia, 105)												as [fecha_transferencia],
			annoInventarioGEI																		as [anno_inventario_GEI],
			cotizacion.anotaciones																	as [anotaciones],
			dbo.FN_GET_CAMEL_CASE(persona.nombre) + ' ' +				   
			dbo.FN_GET_CAMEL_CASE(persona.primerApellido) + ' ' +		   
			dbo.FN_GET_CAMEL_CASE(persona.segundoApellido)											as [usuario]
		from
			SICORE_CERTIFICADO certificado
		inner join
			SICORE_COTIZACION cotizacion on certificado.idCotizacion = cotizacion.idCotizacion
		inner join
			SICORE_CLIENTE cliente on cotizacion.idCliente = cliente.idCliente
		inner join
			SICORE_SECTOR_COMERCIAL sector on cliente.idSector = sector.idSectorComercial
		left outer join
			SICORE_USUARIO usuario on certificado.idFuncionario = usuario.idUsuario
		left outer join
			SCGI..SIST_FUNCIONARIOS funcionario on usuario.idUsuario = funcionario.idUsuario
		left outer join
			SCGI..SIST_PERSONA persona on funcionario.idPersona = persona.idPersona
		where
			cast(cotizacion.fechaHora as date) between @pfechaInicio and @pfechaFinal
		order by
			certificado.idCertificado asc;
	
	COMMIT
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE()
	ROLLBACK
END CATCH