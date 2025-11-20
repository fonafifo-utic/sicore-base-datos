use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Abril 2025
-- Description:	Trae un listado de encuestas pendientes de contestar.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_ENCUESTA_LISTADO_PENDIENTES_CONTESTAR]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_ENCUESTA_LISTADO_PENDIENTES_CONTESTAR]
GO

CREATE PROCEDURE [dbo].[PA_ENCUESTA_LISTADO_PENDIENTES_CONTESTAR]
AS
BEGIN TRY
	BEGIN TRAN

		select
			traza.idTrazaEncuesta,
			cliente.nombreCliente,
			certificado.numeroCertificado,
			cast(traza.fechaHoraEnvio as date) fecha,
			convert(varchar(5), traza.fechaHoraEnvio, 108) hora
		from
			SICORE_ENCUESTA_TRAZA traza
		inner join
			SICORE_CLIENTE cliente on traza.idCliente = cliente.idCliente
		inner join
			SICORE_CERTIFICADO certificado on traza.idCertificado = certificado.idCertificado
		where
			traza.idCliente not in (select distinct idCliente from SICORE_ENCUESTA_REPORTE)
		and
			fechaHoraRespuesta is null
		order by
			fecha desc
		
	COMMIT
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE();

	ROLLBACK TRAN
END CATCH