use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Julio 2025
-- Description:	Trae un listado de Ventas filtrados por fecha desde el principio de año a hoy.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_REPORTES_TRAE_LISTADO_VENTAS_EXCEL]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_REPORTES_TRAE_LISTADO_VENTAS_EXCEL]
GO

CREATE PROCEDURE [dbo].[PA_REPORTES_TRAE_LISTADO_VENTAS_EXCEL]
AS
BEGIN TRY
	BEGIN TRAN

		declare @annoVigente as varchar(10) = year(getdate());
		declare @pfechaInicio as date = @annoVigente + '-01-01';
		declare @pfechaFinal as date = cast(getdate() as date);

		select
			dbo.FN_GET_CAMEL_CASE(cliente.nombreCliente)												as [nombre_cliente],
			sector.sectorComercial																		as [sector_comercial],
			convert(varchar, formalizacion.fechaHora, 105) + ' ' +
			convert(varchar(5), formalizacion.fechaHora, 108)											as fecha,
			cotizacion.cantidad																			as cantidad,
			isnull(dbo.FN_GET_MONTO_COLONES(formalizacion.montoDolares, formalizacion.fechaHora), 0)	as [monto_colones],
			formalizacion.montoDolares																	as [monto_dolares],
			case
				when cotizacion.cuentaConvenio = 'N' then
					'Fideicomiso 544-17'
				when cotizacion.cuentaConvenio = 'M' then
					'Fideicomiso 544-13'
				when cotizacion.cuentaConvenio = 'F' then
					'Cuenta de Fonafifo'
			end																							as cuenta,
			case
				when cotizacion.precioUnitario < 7.5 then
					'Monto: ' +
					cast(cotizacion.precioUnitario as varchar(10)) + 
					', por: ' + 
					cotizacion.justificacionCompra
				else
					'N/A'
			end																							as descuento,
			dbo.FN_GET_CAMEL_CASE(persona.nombre) + ' ' +
			dbo.FN_GET_CAMEL_CASE(persona.primerApellido) + ' ' +
			dbo.FN_GET_CAMEL_CASE(persona.segundoApellido)												as usuario
		from
			SICORE_FORMALIZACION formalizacion
		inner join
			SICORE_COTIZACION cotizacion on formalizacion.idCotizacion = cotizacion.idCotizacion
		inner join
			SICORE_CLIENTE cliente on cotizacion.idCliente = cliente.idCliente
		inner join
			SICORE_SECTOR_COMERCIAL sector on cliente.idSector = sector.idSectorComercial
		left outer join
			SICORE_USUARIO usuario on cotizacion.idFuncionario = usuario.idUsuario
		left outer join
			SCGI..SIST_FUNCIONARIOS funcionario on usuario.idUsuario = funcionario.idUsuario
		left outer join
			SCGI..SIST_PERSONA persona on funcionario.idPersona = persona.idPersona
		where
			cast(formalizacion.fechaHora as date) between @pfechaInicio and @pfechaFinal
		order by
			formalizacion.idFormalizacion desc;
	
	COMMIT
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE()
	ROLLBACK
END CATCH