use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Julio 2024
-- Description:	Toma un valor JSON para actualizar las columnas
-- de la tabla Certificado.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_CERTIFICADO_ACTUALIZA]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_CERTIFICADO_ACTUALIZA]
GO

CREATE PROCEDURE [dbo].[PA_CERTIFICADO_ACTUALIZA] (@pCertificado as nvarchar(max))
AS
BEGIN TRY
	BEGIN TRANSACTION
		
		SET NOCOUNT ON;

		declare @idCertificado int = (select idCertificado from openjson(@pCertificado) with (idCertificado int '$.idCertificado'));
		declare @numeroCertificado int = (select numeroCertificado from openjson(@pCertificado) with (numeroCertificado int '$.numeroCertificado'));
		declare @fechaEmisionCertificado date = (select fechaEmisionCertificado from openjson(@pCertificado) with (fechaEmisionCertificado date '$.fechaEmisionCertificado'));
		declare @nombreComprador varchar(80)= (select nombreComprador from openjson(@pCertificado) with (nombreComprador varchar(80) '$.nombreComprador'));
		declare @montoCompraTotal decimal(18,5) = (select montoCompraTotal from openjson(@pCertificado) with (montoCompraTotal decimal(18,5) '$.montoCompraTotal'));
		declare @cantidadTotalToneladaAdquirida decimal(18,2) = (select cantidadTotalToneladaAdquirida from openjson(@pCertificado) with (cantidadTotalToneladaAdquirida decimal(18,2) '$.cantidadTotalToneladaAdquirida'));
		declare @cedulaJuridicaComprador varchar(100) = (select cedulaJuridicaComprador from openjson(@pCertificado) with (cedulaJuridicaComprador varchar(100) '$.cedulaJuridicaComprador'));
		declare @annoInventarioGEICliente int = (select annoInventarioGEICliente from openjson(@pCertificado) with (annoInventarioGEICliente int '$.annoInventarioGEICliente'));
		declare @razonCompra nvarchar(255) = (select razonCompra from openjson(@pCertificado) with (razonCompra nvarchar(255) '$.razonCompra'));
		declare @montoEconomicoTotal decimal(18,2) = (select montoEconomicoTotal from openjson(@pCertificado) with (montoEconomicoTotal decimal(18,2) '$.montoEconomicoTotal'));
		declare @numeroConvenio int = (select numeroConvenio from openjson(@pCertificado) with (numeroConvenio int '$.numeroConvenio'));
		declare @numeroTransferencia int = (select numeroTransferencia from openjson(@pCertificado) with (numeroTransferencia int '$.numeroTransferencia'));
		declare @montoEconomicoIngresadoColones decimal(18,2) = (select montoEconomicoIngresadoColones from openjson(@pCertificado) with (montoEconomicoIngresadoColones decimal(18,2) '$.montoEconomicoIngresadoColones'));
		declare @montoEquivalenteColones decimal(18,2) = (select montoEquivalenteColones from openjson(@pCertificado) with (montoEquivalenteColones decimal(18,2) '$.montoEquivalenteColones'));
		declare @nombreBanco varchar(100) = (select nombreBanco from openjson(@pCertificado) with (nombreBanco varchar(100) '$.nombreBanco'));
		declare @fechaTransferencia date = (select fechaTransferencia from openjson(@pCertificado) with (fechaTransferencia date '$.fechaTransferencia'));
		declare @numeroFacturaFonafifo int = (select numeroFacturaFonafifo from openjson(@pCertificado) with (numeroFacturaFonafifo int '$.numeroFacturaFonafifo'));
		declare @funcionario varchar(100) = (select funcionario from openjson(@pCertificado) with (funcionario varchar(100) '$.funcionario'));
		declare @siglaProyecto char(3) = (select siglaProyecto from openjson(@pCertificado) with (siglaProyecto char(3) '$.siglaProyecto'));
		declare @producto char(5) = (select producto from openjson(@pCertificado) with (producto char(5) '$.producto'));
		declare @tipoEnvio varchar(10) = (select tipoEnvio from openjson(@pCertificado) with (tipoEnvio varchar(10) '$.tipoEnvio'));
		declare @direccion nvarchar(100) = (select direccion from openjson(@pCertificado) with (direccion nvarchar(100) '$.direccion'));
		declare @anotaciones nvarchar(100) = (select anotaciones from openjson(@pCertificado) with (anotaciones nvarchar(100) '$.anotaciones'));
		declare @otrosDetalles varbinary(max) = (select otrosDetalles from openjson(@pCertificado) with (otrosDetalles varbinary(max) '$.otrosDetalles'));

		update SICORE_CERTIFICADO
			set
				numeroCertificado = @numeroCertificado,
				fechaEmisionCertificado = @fechaEmisionCertificado,
				nombreComprador = @nombreComprador,
				montoCompraTotal = @montoCompraTotal,
				cantidadTotalToneladaAdquirida = @cantidadTotalToneladaAdquirida,
				annoInventarioGEICliente = @annoInventarioGEICliente,
				razonCompra = @razonCompra,
				montoEconomicoTotal = @montoEconomicoTotal,
				numeroConvenio = @numeroConvenio,
				montoEconomicoIngresadoColones = @montoEconomicoIngresadoColones,
				montoEquivalenteColones = @montoEquivalenteColones,
				numeroTransferencia = @numeroTransferencia,
				nombreBanco = @nombreBanco,
				fechaTransferencia = @fechaTransferencia,
				numeroFacturaFonafifo = @numeroFacturaFonafifo,
				funcionario = @funcionario,
				siglaProyecto = @siglaProyecto,
				producto = @producto,
				tipoEnvio = @tipoEnvio,
				direccion = @direccion,
				anotaciones = @anotaciones,
				otrosDetalles = @otrosDetalles
			where
				idCertificado = @idCertificado;

		SET NOCOUNT OFF;

		select 1 as resultado

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK

	select ERROR_MESSAGE() as resultado
END CATCH