use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Junio 2025
-- Description:	Trae un listado de Cotizaciones filtradas por fecha desde el principio de año a hoy.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_REPORTES_TRAE_LISTADO_COTIZACIONES_EXCEL]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_REPORTES_TRAE_LISTADO_COTIZACIONES_EXCEL]
GO

CREATE PROCEDURE [dbo].[PA_REPORTES_TRAE_LISTADO_COTIZACIONES_EXCEL]
AS
BEGIN TRY
	BEGIN TRAN

		declare @annoVigente as varchar(10) = year(getdate());
		declare @fechaInicio as date = @annoVigente + '-01-01';
		declare @pfechaFinal as date = cast(getdate() as date);

		select
			dbo.FN_GET_CAMEL_CASE(sector.sectorComercial)				as [sector_Comercial],
			dbo.FN_GET_CAMEL_CASE(cliente.nombreCliente)				as [Nombre_Cliente],
			dbo.FN_GET_CAMEL_CASE(proyecto.proyecto)					as Proyecto,
			dbo.FN_GET_CAMEL_CASE(persona.nombre) + ' ' +
			dbo.FN_GET_CAMEL_CASE(persona.primerApellido) + ' ' +
			dbo.FN_GET_CAMEL_CASE(persona.segundoApellido)				as Funcionario,
			convert(varchar, cotizacion.fechaHora, 105) + ' ' +
			convert(varchar(5), cotizacion.fechaHora, 108)				as [Fecha_Hora],
			cotizacion.cantidad											as Cantidad,
			cotizacion.precioUnitario									as [Precio_Unitario],
			convert(decimal(10,2), cotizacion.montoTotalDolares)		as [Monto_Dólares],
			cotizacion.consecutivo										as Consecutivo,
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
			end															as Estado
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
			cast(cotizacion.fechaHora as date) between @fechaInicio and @pfechaFinal
		order by
			cotizacion.idCotizacion asc;
	
	COMMIT
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE()
	ROLLBACK
END CATCH