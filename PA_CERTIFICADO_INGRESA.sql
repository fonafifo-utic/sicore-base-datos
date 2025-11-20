use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Julio 2024
-- Description:	Toma un valor JSON para ingresar un registro
-- en la tabla Certificado.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_CERTIFICADO_INGRESA]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_CERTIFICADO_INGRESA]
GO

CREATE PROCEDURE [dbo].[PA_CERTIFICADO_INGRESA] (@pCertificado as nvarchar(max))
AS
BEGIN TRY
	BEGIN TRANSACTION
		
		SET NOCOUNT ON;

		insert into SICORE_CERTIFICADO
			select	
				numeroCertificado,
				fechaEmisionCertificado,
				nombreComprador,
				montoCompraTotal,
				cantidadTotalToneladaAdquirida,
				cedulaJuridicaComprador,
				annoInventarioGEICliente,
				razonCompra,
				montoEconomicoTotal,
				numeroConvenio,
				montoEconomicoIngresadoColones,
				montoEquivalenteColones,
				numeroTransferencia,
				nombreBanco,
				fechaTransferencia,
				numeroFacturaFonafifo,
				funcionario,
				siglaProyecto,
				producto,
				tipoEnvio,
				direccion,
				anotaciones,
				otrosDetalles,
				null,
				null,
				null,
				null
			from
				openjson(@pCertificado)
			with
				(
					numeroCertificado int '$.numeroCertificado',
					fechaEmisionCertificado date '$.fechaEmisionCertificado',
					nombreComprador varchar(80) '$.nombreComprador',
					montoCompraTotal decimal(18,2) '$.montoCompraTotal',
					cantidadTotalToneladaAdquirida decimal(18,2) '$.cantidadTotalToneladaAdquirida',
					cedulaJuridicaComprador varchar(100) '$.cedulaJuridicaComprador',
					annoInventarioGEICliente int '$.annoInventarioGEICliente',
					razonCompra nvarchar(255) '$.razonCompra',
					montoEconomicoTotal decimal(18,2) '$.montoEconomicoTotal',
					numeroConvenio int '$.numeroConvenio',
					montoEconomicoIngresadoColones decimal (18,2) '$.montoEconomicoIngresadoColones',
					montoEquivalenteColones decimal(18,2) '$.montoEquivalenteColones',
					numeroTransferencia int '$.numeroTransferencia',
					nombreBanco varchar(100) '$.nombreBanco',
					fechaTransferencia date '$.fechaTransferencia',
					numeroFacturaFonafifo int '$.numeroFacturaFonafifo',
					funcionario varchar(100) '$.funcionario',
					siglaProyecto char(3) '$.siglaProyecto',
					producto char(5) '$.producto',
					tipoEnvio varchar(10) '$.tipoEnvio',
					direccion nvarchar(100) '$.direccion',
					anotaciones nvarchar(100) '$.anotaciones',
					otrosDetalles varbinary(max) '$.otrosDetalles'
				)

		select 1 as resultado

		SET NOCOUNT OFF;

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK

	select ERROR_MESSAGE() as resultado
END CATCH