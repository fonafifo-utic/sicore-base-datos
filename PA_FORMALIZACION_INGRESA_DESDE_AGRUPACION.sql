use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Octubre 2025
-- Description:	Toma un objeto JSON para ingresar registros en la tabla Formalización .
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_FORMALIZACION_INGRESA_DESDE_AGRUPACION]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_FORMALIZACION_INGRESA_DESDE_AGRUPACION]
GO

CREATE PROCEDURE [dbo].[PA_FORMALIZACION_INGRESA_DESDE_AGRUPACION] (@pFormalizacion as nvarchar(max))
AS
BEGIN TRY
	BEGIN TRAN

		set @pFormalizacion = replace(@pFormalizacion, '{ pFormalizacion = "{', '{');
		set @pFormalizacion = replace(@pFormalizacion, '" }', '');

		declare @idCotizacion bigint =				(select idCotizacion from openjson(@pFormalizacion) with (idCotizacion bigint '$.idCotizacion'));

		DECLARE @consecutivoAgrupacion INT				= (SELECT consecutivo FROM OPENJSON (@pFormalizacion) WITH (consecutivo INT));
		DECLARE @fecha DATE								= (SELECT fechaHora FROM OPENJSON(@pFormalizacion) WITH (fechaHora DATE '$.fechaHora'));
		DECLARE @hora CHAR(8)							= CAST(DATEPART(HOUR, GETDATE()) AS CHAR(2)) +':'+ CAST(DATEPART(MINUTE, GETDATE()) AS CHAR(2)) +':'+ CAST(DATEPART(SECOND, GETDATE()) AS CHAR(2));
		DECLARE @fechaHora DATETIME						= CAST(CAST(@fecha AS CHAR(10)) + ' ' + @hora AS DATETIME);
		DECLARE @numeroFacturaFonafifo VARCHAR(100)		= (SELECT numeroFacturaFonafifo FROM OPENJSON(@pFormalizacion) WITH (numeroFacturaFonafifo VARCHAR(100) '$.numeroFacturaFonafifo'));
		DECLARE @numeroTransferencia VARCHAR(100)		= (SELECT numeroTransferencia FROM OPENJSON(@pFormalizacion) WITH (numeroTransferencia VARCHAR(100) '$.numeroTransferencia'));
		DECLARE @justificacionCompra VARCHAR(100)		= (SELECT justificacionCompra FROM OPENJSON(@pFormalizacion) WITH (justificacionCompra VARCHAR(150) '$.justificacionCompra'));
		DECLARE @creditoDebito CHAR(1)					= (SELECT creditoDebito FROM OPENJSON(@pFormalizacion) WITH (creditoDebito CHAR(1) '$.creditoDebito'));
		DECLARE @indicadorEstado CHAR(1)				= (SELECT indicadorEstado FROM OPENJSON(@pFormalizacion) WITH (indicadorEstado CHAR(1) '$.indicadorEstado'));
		DECLARE @idFuncionario BIGINT					= (SELECT idFuncionario FROM OPENJSON(@pFormalizacion) WITH (idFuncionario BIGINT '$.idFuncionario'));
		DECLARE @numeroComprobante VARCHAR(100)			= (SELECT numeroComprobante FROM OPENJSON(@pFormalizacion) WITH (numeroComprobante VARCHAR(100) '$.numeroComprobante'));
		DECLARE @numeroCIIU VARCHAR(50)					= (SELECT numeroCIIU FROM OPENJSON(@pFormalizacion) WITH (numeroCIIU VARCHAR(50) '$.numeroCIIU'));

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
			WHERE
				idCotizacion IN (
									SELECT
										idCotizacion
									FROM
										SICORE_COTIZACION_AGRUPACION WHERE consecutivo = @consecutivoAgrupacion
								)
		end
		else
		begin

			if(@indicadorEstado = 'P')
			begin
		
				insert into SICORE_FORMALIZACION
				SELECT
					idCotizacion,
					@idFuncionario,
					@fechaHora,
					montoTotalDolares,
					montoTotalColones,
					consecutivo,
					@numeroFacturaFonafifo,
					@numeroTransferencia,
					@justificacionCompra,
					@creditoDebito,
					@indicadorEstado,
					'N',
					GETDATE(),
					GETDATE(),
					@idFuncionario,
					NULL,
					NULL,
					@numeroComprobante,
					'N',
					'',
					@numeroCIIU
				FROM
					SICORE_COTIZACION cotizacion
				WHERE
					cotizacion.idCotizacion IN (
										SELECT
											idCotizacion
										FROM
											SICORE_COTIZACION_AGRUPACION WHERE consecutivo = @consecutivoAgrupacion
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
					WHERE
						idCotizacion IN (
														SELECT
															idCotizacion
														FROM
															SICORE_COTIZACION_AGRUPACION WHERE consecutivo = @consecutivoAgrupacion
													)

				end
				else
				begin

					insert into SICORE_FORMALIZACION
					SELECT
						idCotizacion,
						@idFuncionario,
						@fechaHora,
						montoTotalDolares,
						montoTotalColones,
						consecutivo,
						@numeroFacturaFonafifo,
						@numeroTransferencia,
						@justificacionCompra,
						@creditoDebito,
						@indicadorEstado,
						'N',
						GETDATE(),
						GETDATE(),
						@idFuncionario,
						NULL,
						NULL,
						@numeroComprobante,
						'N',
						'',
						@numeroCIIU
					FROM
						SICORE_COTIZACION cotizacion
					WHERE
						cotizacion.idCotizacion IN (
											SELECT
												idCotizacion
											FROM
												SICORE_COTIZACION_AGRUPACION WHERE consecutivo = @consecutivoAgrupacion
										)

				end
			end

			update SICORE_COTIZACION
				set
					indicadorEstado = 'P',
					fechaModificoAuditoria = getdate(),
					idUsuarioModificoAuditoria = @idFuncionario
				where
					idCotizacion IN (
										SELECT
											idCotizacion
										FROM
											SICORE_COTIZACION_AGRUPACION WHERE consecutivo = @consecutivoAgrupacion
									);

			UPDATE SICORE_COTIZACION_AGRUPACION
				SET
					indicadorEstado = 'P',
					fechaModificoAuditoria = getdate(),
					idUsuarioModificoAuditoria = @idFuncionario
			WHERE
				consecutivo = @consecutivoAgrupacion


		end

		select 1 as resultado;

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK

	select ERROR_MESSAGE() as resultado;
END CATCH