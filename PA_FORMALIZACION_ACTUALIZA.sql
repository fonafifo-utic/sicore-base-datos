use SICORE
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Marzo 2025
-- Description:	Toma un objeto JSON para actualizar los registros de la tabla Formalización.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_FORMALIZACION_ACTUALIZA]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_FORMALIZACION_ACTUALIZA]
GO

CREATE PROCEDURE [dbo].[PA_FORMALIZACION_ACTUALIZA] (@pFormalizacion as nvarchar(max))
AS
BEGIN TRY
	BEGIN TRANSACTION

		set @pFormalizacion = replace(@pFormalizacion, '{ pFormalizacion = "{', '{');
		set @pFormalizacion = replace(@pFormalizacion, '" }', '');

		declare @idFormalizacion varchar(50) = (select idFormalizacion from openjson(@pFormalizacion) with (idFormalizacion varchar(50) '$.idFormalizacion'));
		declare @idFuncionario bigint = (select idUsuario from openjson(@pFormalizacion) with (idUsuario bigint '$.idUsuario'));
		declare @indicadorEstado char(1) = (select indicadorEstado from openjson(@pFormalizacion) with (indicadorEstado char(1) '$.indicadorEstado'));
		declare @idCotizacion varchar(50) = (select string_agg(idCotizacion, ', ') as idCotizaciones from SICORE_FORMALIZACION where idFormalizacion in (select value from string_split(@idFormalizacion, ',') where value != ''));
		declare @tieneFaturas char(1) = (select tieneFaturas from openjson(@pFormalizacion) with (tieneFaturas char(1) '$.tieneFacturas'));
		declare @numeroComprobante varchar(100) = (select numeroComprobante from openjson(@pFormalizacion) with (numeroComprobante varchar(100) '$.numeroComprobante'));
		declare @numeroFactura varchar(100) = (select numeroFactura from openjson(@pFormalizacion) with (numeroFactura varchar(100) '$.numeroFactura'));
		declare @numeroTransaccion varchar(100) = (select numeroTransferencia from openjson(@pFormalizacion) with (numeroTransferencia varchar(100) '$.numeroTransferencia'));

		update SICORE_COTIZACION
		set
			indicadorEstado = 'P',
			fechaModificoAuditoria = getdate(),
			idUsuarioModificoAuditoria = @idFuncionario
		where
			idCotizacion in (select value from string_split(@idCotizacion, ',') where value != '');
		
		update SICORE_FORMALIZACION
		set
			numeroFacturaFonafifo = @numeroFactura,
			numeroTransferencia = @numeroTransaccion,
			numeroComprobante = @numeroComprobante,
			indicadorEstado = @indicadorEstado,
			tieneFacturas = @tieneFaturas,
			fechaHoraFormalizacion = getdate(),
			fechaModificoAuditoria = getdate(),
			idUsuarioModificoAuditoria = @idFuncionario	
		where
			idFormalizacion in (select value from string_split(@idFormalizacion, ',') where value != '');

		declare @consecutivo varchar(10) = (select string_agg(consecutivo, ',') from SICORE_COTIZACION where idCotizacion in (select value from string_split(@idCotizacion, ',') where value != ''));
		declare @anno varchar(10) = cast(year(getdate()) as varchar(5));
		declare @numeroFormalizacion varchar(100) = '';

		if (len(@consecutivo) <= 3)
		begin
			if(len(@consecutivo) = 1) set @numeroFormalizacion = '00' + cast(@consecutivo as varchar(5));
			if(len(@consecutivo) = 2) set @numeroFormalizacion = '0' + cast(@consecutivo as varchar(5));
			if(len(@consecutivo) = 3) set @numeroFormalizacion = cast(@consecutivo as varchar(5));

			set @numeroFormalizacion = 'DDC-CO-' + @numeroFormalizacion + '-' + @anno;
			exec PA_ENVIAR_NOTIFICACION_FORMALIZACION @numeroFormalizacion, @idFuncionario
		end
		else
		begin

			set @consecutivo = (select
								top 1 consecutivo
								from SICORE_COTIZACION_AGRUPACION
								where idCotizacion in (select value from string_split(@idCotizacion, ',') where value != '') 
								and indicadorEstado = 'P');

			if(len(@consecutivo) = 1) set @numeroFormalizacion = '00' + cast(@consecutivo as varchar(5));
			if(len(@consecutivo) = 2) set @numeroFormalizacion = '0' + cast(@consecutivo as varchar(5));
			if(len(@consecutivo) = 3) set @numeroFormalizacion = cast(@consecutivo as varchar(5));

			set @numeroFormalizacion = 'DDC-AG-' + @numeroFormalizacion + '-' + @anno;
			exec PA_ENVIAR_NOTIFICACION_FORMALIZACION @numeroFormalizacion, @idFuncionario
		end

		select 1 as resultado;

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK

	select ERROR_MESSAGE() as resultado
END CATCH
