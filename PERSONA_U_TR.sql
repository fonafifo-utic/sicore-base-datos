USE [SICORE]
GO

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: 10 julio, 2024
-- Description:	Trigger por la actualización de un registro en Persona.
-- =============================================

IF EXISTS (SELECT * FROM sys.objects WHERE [name] = N'PERSONA_U_TR' AND [type] = 'TR')
	DROP TRIGGER [dbo].PERSONA_U_TR;
GO

CREATE TRIGGER [dbo].PERSONA_U_TR
   ON  [dbo].SICORE_PERSONA
   FOR UPDATE
AS 
BEGIN
	INSERT INTO [SCGI_TRAZA].[dbo].SICORE_PERSONA
		SELECT
			[idPersona]
			,[idTipoDocumentoID]
			,[documentoID]
			,[nombre]
			,[primerApellido]
			,[segundoApellido]
			,[fechaNacimiento]
			,[fechaCaducidadDocID]
			,[idDistrito]
			,[direccionExacta]
			,[caserio]
			,[idEstadoCivil]
			,[apartadoPostal]
			,[idGradoAcademico]
			,[idProfesion]
			,[indicadorGenero]
			,[indicadorEstado]
			,[aceptaSMS]
			,[telefonoMovil]
			,[telefonoFijoCasa]
			,[telefonoFijoTrabajo]
			,[fechaDefuncion]
			,[indicadorFallecido]
			,[correo]
			,[idBanco]
			,[cuentaIBAN]
			,[certificadoIBAN]
			,[numeroVersionAuditoria]
			,[fechaInsertoAuditoria]
			,[idUsuarioInsertoAuditoria]
			,[fechaModificoAuditoria]
			,[idUsuarioModificoAuditoria]
			,CURRENT_TIMESTAMP
		FROM
			deleted
END