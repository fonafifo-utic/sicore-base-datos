use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Julio 2024
-- Description:	Toma un objeto JSON para actualizar los registros de la tabla Personalización.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_PERSONALIZACION_ACTUALIZA]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_PERSONALIZACION_ACTUALIZA]
GO

CREATE PROCEDURE [dbo].[PA_PERSONALIZACION_ACTUALIZA] (@pPersonalizacion as nvarchar(max))
AS
BEGIN TRY
	BEGIN TRAN

		set @pPersonalizacion = replace(@pPersonalizacion, '{ pPersonalizacion = "{', '{');
		set @pPersonalizacion = replace(@pPersonalizacion, '" }', '');

		if (not exists (select top 1 idPersonalizacion from SICORE_PERSONALIZACION))
		begin
		
			insert into SICORE_PERSONALIZACION
				select
					logoPrincipal,
					logoSecundario,
					tercerLogo,
					logoSistema,
					leyendaDescriptivaCotizacionEspannol,
					leyendaDescriptivaCotizacionIngles,
					leyendaFinalidadCotizacionEspannol,
					leyendaFinalidadCotizacionIngles,
					leyendaDescripcionCertificadoEspannol,
					leyendaDescripcionCertificadoIngles,
					getdate(),
					idFuncionario,
					null,
					null,
					correoGerenciaEjecutiva,
					directorEjecutivo
				from
					openjson(@pPersonalizacion)
				with
					(
						idFuncionario int '$.idFuncionario',
						logoPrincipal varbinary (max) '$.logoPrincipal',
						logoSecundario varbinary (max) '$.logoSecundario',
						tercerLogo varbinary (max) '$.tercerLogo',
						logoSistema varbinary (max) '$.logoSistema',
						leyendaDescriptivaCotizacionEspannol varchar(max) '$.leyendaDescriptivaCotizacionEspannol',
						leyendaDescriptivaCotizacionIngles varchar(max) '$.leyendaDescriptivaCotizacionIngles',
						leyendaFinalidadCotizacionEspannol varchar(max) '$.leyendaFinalidadCotizacionEspannol',
						leyendaFinalidadCotizacionIngles varchar(max) '$.leyendaFinalidadCotizacionIngles',
						leyendaDescripcionCertificadoEspannol varchar(max) '$.leyendaDescripcionCertificadoEspannol',
						leyendaDescripcionCertificadoIngles varchar(max) '$.leyendaDescripcionCertificadoIngles',
						correoGerenciaEjecutiva varchar(100) '$.correoGerenciaEjecutiva',
						directorEjecutivo varchar(100) '$.directorEjecutivo'
					)

			select 1 as resultado;

		end
		else
		begin

			declare @idPersonalizacion int = (select idPersonalizacion from openjson (@pPersonalizacion) with (idPersonalizacion int '$.idPersonalizacion'));
			declare @idFuncionario int = (select idFuncionario from openjson (@pPersonalizacion) with (idFuncionario int '$.idFuncionario'));
			declare @logoPrincipal varbinary (max) = (select logoPrincipal from openjson (@pPersonalizacion) with (logoPrincipal varbinary (max) '$.logoPrincipal'));
			declare @logoSecundario varbinary (max) = (select logoSecundario from openjson (@pPersonalizacion) with (logoSecundario varbinary (max) '$.logoSecundario'));
			declare @tercerLogo varbinary (max) = (select tercerLogo from openjson (@pPersonalizacion) with (tercerLogo varbinary (max) '$.tercerLogo'));
			declare @logoSistema varbinary (max) = (select logoSistema from openjson (@pPersonalizacion) with (logoSistema varbinary (max) '$.logoSistema'));
			declare @leyendaDescriptivaCotizacionEspannol varchar(max) = (select leyendaDescriptivaCotizacionEspannol from openjson (@pPersonalizacion) with (leyendaDescriptivaCotizacionEspannol varchar(max) '$.leyendaDescriptivaCotizacionEspannol'));
			declare @leyendaDescriptivaCotizacionIngles varchar(max) = (select leyendaDescriptivaCotizacionIngles from openjson (@pPersonalizacion) with (leyendaDescriptivaCotizacionIngles varchar(max) '$.leyendaDescriptivaCotizacionIngles'));
			declare @leyendaFinalidadCotizacionEspannol varchar(max) = (select leyendaFinalidadCotizacionEspannol from openjson (@pPersonalizacion) with (leyendaFinalidadCotizacionEspannol varchar(max) '$.leyendaFinalidadCotizacionEspannol'));
			declare @leyendaFinalidadCotizacionIngles varchar(max) = (select leyendaFinalidadCotizacionIngles from openjson (@pPersonalizacion) with (leyendaFinalidadCotizacionIngles varchar(max) '$.leyendaFinalidadCotizacionIngles'));
			declare @leyendaDescripcionCertificadoEspannol varchar(max) = (select leyendaDescripcionCertificadoEspannol from openjson (@pPersonalizacion) with (leyendaDescripcionCertificadoEspannol varchar(max) '$.leyendaDescripcionCertificadoEspannol'));
			declare @leyendaDescripcionCertificadoIngles varchar(max) = (select leyendaDescripcionCertificadoIngles from openjson (@pPersonalizacion) with (leyendaDescripcionCertificadoIngles varchar(max) '$.leyendaDescripcionCertificadoIngles'));
			declare @correoGerenciaEjecutiva varchar(100) = (select correoGerenciaEjecutiva from openjson (@pPersonalizacion) with (correoGerenciaEjecutiva varchar(100) '$.correoGerenciaEjecutiva'));
			declare @directorEjecutivo varchar(250) = (select directorEjecutivo from openjson (@pPersonalizacion) with (directorEjecutivo varchar(250) '$.directorEjecutivo'));

			update SICORE_PERSONALIZACION
				set
					logoPrincipal = @logoPrincipal,
					logoSecundario = @logoSecundario,
					tercerLogo = @tercerLogo,
					logoSistema = @logoSistema,
					leyendaDescriptivaCotizacionEspannol = @leyendaDescriptivaCotizacionEspannol,
					leyendaDescriptivaCotizacionIngles = @leyendaDescriptivaCotizacionIngles,
					leyendaFinalidadCotizacionEspannol = @leyendaFinalidadCotizacionEspannol,
					leyendaFinalidadCotizacionIngles = @leyendaFinalidadCotizacionIngles,
					leyendaDescripcionCertificadoEspannol = @leyendaDescripcionCertificadoEspannol,
					leyendaDescripcionCertificadoIngles = @leyendaDescripcionCertificadoIngles,
					idUsuarioModificoAuditoria = @idFuncionario,
					fechaModificoAuditoria = getdate(),
					correoGerenciaEjecutiva = @correoGerenciaEjecutiva,
					directorEjecutivo = @directorEjecutivo
				where
					idPersonalizacion = @idPersonalizacion;

			select 1 as resultado;

		end

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK

	select ERROR_MESSAGE() as resultado
END CATCH