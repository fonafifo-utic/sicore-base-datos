use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Abril 2025
-- Description:	Trae un listado de Formalización filtrados por mes y año.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_REPORTES_TRAE_LISTADO_FORMALIZACION_PORMES]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_REPORTES_TRAE_LISTADO_FORMALIZACION_PORMES]
GO

CREATE PROCEDURE [dbo].[PA_REPORTES_TRAE_LISTADO_FORMALIZACION_PORMES] (@pParametros nvarchar(max))
AS
BEGIN TRY
	BEGIN TRAN
		
		declare @pfechaInicio date = (select cast(fechaInicio as date) from openjson (@pParametros) with (fechaInicio date '$.fechaInicio'));
		declare @pfechaFinal date = (select cast(fechaFin as date) from openjson (@pParametros) with (fechaFin date '$.fechaFin'));
		
		declare @idFuncionario int = (select funcionario from openjson (@pParametros) with (funcionario int '$.funcionario'));
		declare @sectores varchar(255) = (select cast(sector as varchar(255)) from openjson (@pParametros) with (sector nvarchar(max) '$.sector' as json));
						
		declare @fechaDesde varchar(100) = (convert(varchar, @pfechaInicio, 105));
		declare @fechaHasta varchar(100) = (convert(varchar, @pfechaFinal, 105));
		declare @rangoDefechas varchar(max) = 'Desde el: ' + @fechaDesde + ' hasta: ' + @fechaHasta;
		
		declare @todosLosSectoresInvolucrados varchar(max) = 'Todos.';
		declare @sectoresFiltrados varchar(250) = 'Todos.';

		if(len(@sectores) <= 2)
		begin

			select	
				formalizacion.idFormalizacion										as idFormalizacion,
				cotizacion.consecutivo												as consecutivo,
				dbo.FN_GET_CAMEL_CASE(sector.sectorComercial)						as sectorComercial,
				dbo.FN_GET_CAMEL_CASE(cliente.nombreCliente)						as nombreCliente,
				formalizacion.fechaHora												as fechaHora,
				convert(varchar, formalizacion.fechaHora, 105) + ' ' +
				convert(varchar(5), formalizacion.fechaHora, 108)					as fechaYHora,
				convert(decimal(10,2), formalizacion.montoDolares)					as montoDolares,
				formalizacion.numeroTransferencia									as numeroTransferencia,
				formalizacion.numeroFacturaFonafifo									as numeroFacturaFonafifo,
				cotizacion.tipoCompra												as tipoCompra,
				case
					when formalizacion.creditoDebito = 'D' then
						'Contado'
					when formalizacion.creditoDebito = 'C' then
						'Crédito'
				end																	as creditoDebito,
				formalizacion.justificacionCompra									as justificacionCompra,
				case
					when cotizacion.cuentaConvenio = 'F' then
						'FID-544-17'
					when cotizacion.cuentaConvenio = 'N' then
						'Banco Nacional de Costa Rica'
					when cotizacion.cuentaConvenio = 'M' then
						'FID-544-13'
				end																	as cuentaPago,
				dbo.FN_GET_CAMEL_CASE(persona.nombre) + ' ' +
				dbo.FN_GET_CAMEL_CASE(persona.primerApellido) + ' ' +
				dbo.FN_GET_CAMEL_CASE(persona.segundoApellido)						as usuario,
				dbo.FN_GET_NOMBRE_CORTO_FUNCIONARIO(formalizacion.idFuncionario)	as funcionario,
				@rangoDefechas														as rangoDeFechas,
				@sectoresFiltrados													as sectoresFiltrados
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
				cast(formalizacion.fechaHora as date) between @pfechaInicio and @pfechaFinal
			order by
				formalizacion.idFormalizacion desc;
			
		end
		else
		begin
			
			set @todosLosSectoresInvolucrados =	(
													select distinct
														stuff (
																(
																	select	
																		', ' + sector.sectorComercial
																	from
																		SICORE_SECTOR_COMERCIAL sector
																	where
																		sector.idSectorComercial in (
																										select
																											replace(replace(value, '[', ''), ']', '')
																										from
																											string_split(@sectores, ',')
																									)
																	order by
																		sector.idSectorComercial asc
																	for xml path ('')
																), 1, 1, '') as filtroPorSectores
													from
														SICORE_SECTOR_COMERCIAL
													group by
														sectorComercial
												);

			declare @sumaCantidadSectores int = (sum(len(@todosLosSectoresInvolucrados) - len(replace(@todosLosSectoresInvolucrados, ',', '')) + 1));

			if(@sumaCantidadSectores >= 13)
			 begin
				set @sectoresFiltrados = 'Todos.';
			 end
			 else
			 begin
				 if(@sumaCantidadSectores >= 7)
				 begin
					declare @sectoresQueVanToMostrarse char(79) = @todosLosSectoresInvolucrados;
					set @sectoresFiltrados = @sectoresQueVanToMostrarse + '...';
				 end
				 else
				 begin
					 if(@sumaCantidadSectores < 7)
					 begin
						set @sectoresFiltrados = @todosLosSectoresInvolucrados;
					 end
				 end
			 end

			 select
				formalizacion.idFormalizacion										as idFormalizacion,
				cotizacion.consecutivo												as consecutivo,
				dbo.FN_GET_CAMEL_CASE(sector.sectorComercial)						as sectorComercial,
				dbo.FN_GET_CAMEL_CASE(cliente.nombreCliente)						as nombreCliente,
				formalizacion.fechaHora												as fechaHora,
				convert(varchar, formalizacion.fechaHora, 105) + ' ' +
				convert(varchar(5), formalizacion.fechaHora, 108)					as fechaYHora,
				convert(decimal(10,2), formalizacion.montoDolares)					as montoDolares,
				formalizacion.numeroTransferencia									as numeroTransferencia,
				formalizacion.numeroFacturaFonafifo									as numeroFacturaFonafifo,
				cotizacion.tipoCompra												as tipoCompra,
				case
					when formalizacion.creditoDebito = 'D' then
						'Contado'
					when formalizacion.creditoDebito = 'C' then
						'Crédito'
				end																	as creditoDebito,
				formalizacion.justificacionCompra									as justificacionCompra,
				case
					when cotizacion.cuentaConvenio = 'F' then
						'FID-544-17'
					when cotizacion.cuentaConvenio = 'N' then
						'Banco Nacional de Costa Rica'
					when cotizacion.cuentaConvenio = 'M' then
						'FID-544-13'
				end																	as cuentaPago,
				dbo.FN_GET_CAMEL_CASE(persona.nombre) + ' ' +
				dbo.FN_GET_CAMEL_CASE(persona.primerApellido) + ' ' +
				dbo.FN_GET_CAMEL_CASE(persona.segundoApellido)						as usuario,
				dbo.FN_GET_NOMBRE_CORTO_FUNCIONARIO(@idFuncionario)					as funcionario,
				@rangoDefechas														as rangoDeFechas,
				trim(@sectoresFiltrados)											as sectoresFiltrados
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
				cast(formalizacion.fechaHora as date) between @pfechaInicio and @pfechaFinal
			and
				sector.idSectorComercial in (select cast(replace(replace(value, '[', ''), ']', '') as int) from string_split(@sectores, ','))
			order by
				formalizacion.idFormalizacion desc;

		end


	COMMIT
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE()
	ROLLBACK
END CATCH