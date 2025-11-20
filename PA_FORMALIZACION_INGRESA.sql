use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Octubre 2024
-- Description:	Toma un objeto JSON para ingresar registros en la tabla Formalización.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_FORMALIZACION_INGRESA]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_FORMALIZACION_INGRESA]
GO

CREATE PROCEDURE [dbo].[PA_FORMALIZACION_INGRESA] (@pFormalizacion as nvarchar(max))
AS
BEGIN TRY
	BEGIN TRAN

		set @pFormalizacion = replace(@pFormalizacion, '{ pFormalizacion = "{', '{');
		set @pFormalizacion = replace(@pFormalizacion, '" }', '');

		declare @fecha date =						(select fechaHora from openjson (@pFormalizacion) with (fechaHora date '$.fechaHora'));
		declare @hora char(8) =						cast(datepart(hour, getdate()) as char(2)) +':'+ cast(datepart(minute, getdate()) as char(2)) +':'+ cast(datepart(second, getdate()) as char(2));
		declare @fechaHora datetime =				cast(cast(@fecha as char(10)) + ' ' + @hora as datetime);
		declare @idCotizacion bigint =				(select idCotizacion from openjson(@pFormalizacion) with (idCotizacion bigint '$.idCotizacion'));
		declare @idFuncionario bigint =				(select idFuncionario from openjson(@pFormalizacion) with (idFuncionario bigint '$.idFuncionario'));
		declare @indicadorEstado char(1) =			(select indicadorEstado from openjson(@pFormalizacion) with (indicadorEstado char(1) '$.indicadorEstado'));
		declare @numeroTransferencia varchar(100) =	(select numeroTransferencia from openjson(@pFormalizacion) with (numeroTransferencia varchar(100) '$.numeroTransferencia'));
		declare @consecutivo bigint =				(select consecutivo from openjson(@pFormalizacion) with (consecutivo int '$.consecutivo'));

		if(exists(select 1 from SICORE_FORMALIZACION where idCotizacion = @idCotizacion and numeroFacturaFonafifo != '' and creditoDebito = 'C' and tieneFacturas = 'S'))
		begin
			update SICORE_FORMALIZACION
			set
				indicadorEstado = @indicadorEstado,
				fechaModificoAuditoria = getdate(),
				idUsuarioModificoAuditoria = @idFuncionario
			where
				idCotizacion = @idCotizacion;

			update SICORE_COTIZACION
			set
				indicadorEstado = @indicadorEstado,
				fechaModificoAuditoria = getdate(),
				idUsuarioModificoAuditoria = @idFuncionario
			where
				idCotizacion = @idCotizacion
		end
		else
		begin

			if(@indicadorEstado = 'P')
			begin
		
				insert into SICORE_FORMALIZACION
				select
					idCotizacion,
					idFuncionario,
					@fechaHora,
					montoDolares,
					montoColones,
					consecutivo,
					numeroFacturaFonafifo,
					numeroTransferencia,
					justificacionCompra,
					creditoDebito,
					indicadorEstado,
					'N',
					getdate(),
					getdate(),
					idFuncionario,
					null,
					null,
					numeroComprobante,
					'N',
					'',
					numeroCIIU
				from 
					openjson (@pFormalizacion)
				with
					(
						idCotizacion bigint '$.idCotizacion',
						idFuncionario bigint '$.idFuncionario',
						montoDolares decimal(18,2) '$.montoDolares',
						montoColones decimal(18,2) '$.montoColones',
						consecutivo int '$.consecutivo',
						numeroFacturaFonafifo varchar(100) '$.numeroFacturaFonafifo',
						numeroTransferencia varchar(100) '$.numeroTransferencia',
						justificacionCompra varchar(150) '$.justificacionCompra',
						indicadorEstado	char(1) '$.indicadorEstado',
						creditoDebito char(1) '$.creditoDebito',
						numeroComprobante varchar(100) '$.numeroComprobante',
						numeroCIIU varchar(50) '$.numeroCIIU'
					)
		
			end
			else
			begin
			
				if(exists(select 1 from SICORE_FORMALIZACION where idCotizacion = @idCotizacion))
				begin

					update SICORE_FORMALIZACION
					set
						indicadorEstado = 'P',
						numeroTransferencia = @numeroTransferencia
					where
						idCotizacion = @idCotizacion

				end
				else
				begin

					insert into SICORE_FORMALIZACION
					select
						idCotizacion,
						idFuncionario,
						@fechaHora,
						montoDolares,
						montoColones,
						consecutivo,
						numeroFacturaFonafifo,
						numeroTransferencia,
						justificacionCompra,
						creditoDebito,
						indicadorEstado,
						'N',
						getdate(),
						getdate(),
						idFuncionario,
						null,
						null,
						numeroComprobante,
						'N',
						'',
						numeroCIIU
					from 
						openjson (@pFormalizacion)
					with
						(
							idCotizacion bigint '$.idCotizacion',
							idFuncionario bigint '$.idFuncionario',
							montoDolares decimal(18,2) '$.montoDolares',
							montoColones decimal(18,2) '$.montoColones',
							consecutivo int '$.consecutivo',
							numeroFacturaFonafifo varchar(100) '$.numeroFacturaFonafifo',
							numeroTransferencia varchar(100) '$.numeroTransferencia',
							justificacionCompra varchar(150) '$.justificacionCompra',
							indicadorEstado	char(1) '$.indicadorEstado',
							creditoDebito char(1) '$.creditoDebito',
							numeroComprobante varchar(100) '$.numeroComprobante',
							numeroCIIU varchar(50) '$.numeroCIIU'
						)

				end
			end

			update SICORE_COTIZACION
				set
					indicadorEstado = 'P',
					fechaModificoAuditoria = getdate(),
					idUsuarioModificoAuditoria = @idFuncionario
				where
					idCotizacion = @idCotizacion;

		end

		select 1 as resultado;

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK

	select ERROR_MESSAGE() as resultado
END CATCH