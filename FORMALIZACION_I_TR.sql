USE [SICORE]
GO

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: 10 julio, 2024
-- Description:	Trigger por el ingreso de una Formalización Financiera.
-- =============================================

IF EXISTS (SELECT * FROM sys.objects WHERE [name] = N'FORMALIZACION_I_TR' AND [type] = 'TR')
	DROP TRIGGER [dbo].[FORMALIZACION_I_TR];
GO

CREATE TRIGGER [dbo].[FORMALIZACION_I_TR]
   ON  [dbo].[SICORE_FORMALIZACION]
   FOR INSERT
AS 
BEGIN
	INSERT INTO [SCGI_TRAZA].[dbo].[SICORE_FORMALIZACION]
		SELECT
			idFormalizacion,
			idCotizacion,
			idFuncionario,
			fechaHora,
			montoDolares,
			montoColones,
			consecutivo,
			numeroFacturaFonafifo,
			numeroTransferencia,
			justificacionCompra,
			creditoDebito,
			indicadorEstado,
			tieneFacturas,
			fechaHoraFormalizacion,
			fechaInsertoAuditoria,
			idUsuarioInsertoAuditoria,
			fechaModificoAuditoria,
			idUsuarioModificoAuditoria,
			numeroComprobante,
			vistoBuenoJefatura,
			justificacionActivacion,
			numeroCIIU
		FROM
			inserted
END