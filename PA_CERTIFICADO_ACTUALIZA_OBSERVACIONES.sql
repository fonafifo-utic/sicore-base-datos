use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Abril 2025
-- Description:	Toma un valor JSON y actualiza las observaciones en Certificado.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_CERTIFICADO_ACTUALIZA_OBSERVACIONES]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_CERTIFICADO_ACTUALIZA_OBSERVACIONES]
GO

CREATE PROCEDURE [dbo].[PA_CERTIFICADO_ACTUALIZA_OBSERVACIONES] (@pCertificado as nvarchar(max))
AS
BEGIN TRY
	BEGIN TRAN

		declare @idCertificado varchar(10) = (select idCertificado from openjson(@pCertificado) with (idCertificado varchar(10) '$.idCertificado'));
		declare @observaciones nvarchar(max) = (select anotaciones from openjson(@pCertificado) with (anotaciones nvarchar(max) '$.observacion'));
		declare @idFuncionario int = (select idFuncionario from openjson(@pCertificado) with (idFuncionario int '$.idFuncionario'));
		declare @nombreCertificado varchar(100) = (select nombreCertificado from openjson(@pCertificado) with (nombreCertificado varchar(100) '$.nombreCertificado'));
		declare @cedulaJuridica varchar(100) = (select cedulaJuridica from openjson(@pCertificado) with (cedulaJuridica varchar(100) '$.cedulaJuridica'));
		declare @numeroTransferencia varchar(100) = (select numeroTransferencia from openjson(@pCertificado) with (numeroTransferencia varchar(100) '$.numeroTransferencia'));
		declare @justificacionEdicion nvarchar(max) = (select justificacionEdicion from openjson(@pCertificado) with (justificacionEdicion nvarchar(max) '$.justificacionEdicion'));
		declare @indicadorEstado char(1) = (select indicadorEstado from openjson(@pCertificado) with (indicadorEstado char(1) '$.indicadorEstado'));
		declare @cssCertificado nvarchar(max) = (select cssCertificado from openjson(@pCertificado) with (cssCertificado nvarchar(max) '$.cssCertificado'));
		declare @enIngles char(1) = (select enIngles from openjson(@pCertificado) with (enIngles char(1) '$.enIngles'));
		
		update SICORE_CERTIFICADO
			set
				nombreCertificado = upper(@nombreCertificado),
				cedulaJuridicaComprador = @cedulaJuridica,
				numeroTransferencia = @numeroTransferencia,
				observaciones  =upper(@observaciones),
				fechaModificoAuditoria = getdate(),
				idUsuarioModificoAuditoria = @idFuncionario,
				justificacionEdicion = upper(@justificacionEdicion),
				cssCertificado = @cssCertificado,
				enIngles = @enIngles
			where
				idCertificado in (select value from string_split(@idCertificado, ',') where value != '');

		select 1 as resultado

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK

	select ERROR_MESSAGE() as resultado
END CATCH