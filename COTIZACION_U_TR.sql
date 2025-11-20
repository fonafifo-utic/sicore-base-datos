USE [SICORE]
GO

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: 10 julio, 2024
-- Description:	Trigger por la actualización de una Cotización.
-- =============================================

IF EXISTS (SELECT * FROM sys.objects WHERE [name] = N'COTIZACION_U_TR' AND [type] = 'TR')
	DROP TRIGGER [dbo].[COTIZACION_U_TR];
GO

CREATE TRIGGER [dbo].[COTIZACION_U_TR]
   ON  [dbo].[SICORE_COTIZACION]
   FOR INSERT
AS 
BEGIN
	INSERT INTO [SCGI_TRAZA].[dbo].SICORE_COTIZACION
		SELECT
			idCotizacion,
			idCliente,
			idFuncionario,
			idProyecto,
			fechaHora,
			fechaExpiracion,
			cantidad,
			precioUnitario,
			subTotal,
			montoTotalColones,
			montoTotalDolares,
			consecutivo,
			anotaciones,
			indicadorEstado,
			fechaInsertoAuditoria,
			idUsuarioInsertoAuditoria,
			fechaModificoAuditoria,
			idUsuarioModificoAuditoria,
			cuentaConvenio,
			cotizacionEnIngles,
			cotizacionEnviada,
			tipoCompra,
			justificacionCompra,
			observacionDeAprobacion
		FROM
			deleted
END