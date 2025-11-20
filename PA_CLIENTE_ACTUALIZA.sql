use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Setiembre 2024
-- Description:	Toma un objeto JSON para actualizar registros en la tabla Cliente.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_CLIENTE_ACTUALIZA]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_CLIENTE_ACTUALIZA]
GO

CREATE PROCEDURE [dbo].[PA_CLIENTE_ACTUALIZA] (@pCliente as nvarchar(max))
AS
BEGIN TRY
	BEGIN TRAN
		
		set @pCliente = replace(@pCliente, '{ pCliente = "{', '{');
		set @pCliente = replace(@pCliente, '" }', '');

		declare @idCliente bigint					= (select idCliente from openjson (@pCliente) with (idCliente bigint '$.idCliente'));
		declare @idSector bigint					= (select idSector from openjson (@pCliente) with (idSector bigint '$.idSector'));
		declare @idTipoEmpresa bigint				= (select idTipoEmpresa from openjson (@pCliente) with (idTipoEmpresa bigint '$.idTipoEmpresa'));
		declare @nombreCliente varchar(255)			= (select upper(nombreCliente) nombreCliente from openjson (@pCliente) with (nombreCliente varchar(255) '$.nombreCliente'));
		declare @nombreComercial varchar(255)		= (select upper(nombreComercial) nombreComercial from openjson (@pCliente) with (nombreComercial varchar(255) '$.nombreComercial'));	
		declare @cedulaCliente varchar(150)			= (select upper(cedulaCliente) cedulaCliente from openjson (@pCliente) with (cedulaCliente varchar(150) '$.cedulaCliente'));
		declare @contactoCliente varchar(150)		= (select upper(contactoCliente) contactoCliente from openjson (@pCliente) with (contactoCliente varchar(150) '$.contactoCliente'));
		declare @telefonoCliente varchar(150)		= (select telefonoCliente from openjson (@pCliente) with (telefonoCliente varchar(150) '$.telefonoCliente'));
		declare @emailCliente varchar(150)			= (select upper(emailCliente) emailCliente from openjson (@pCliente) with (emailCliente varchar(150) '$.emailCliente'));
		declare @direccionFisica varchar(255)		= (select upper(direccionFisica) direccionFisica from openjson (@pCliente) with (direccionFisica varchar(255) '$.direccionFisica'));
		declare @clasificacion char(2)				= (select upper(clasificacion) clasificacion from openjson (@pCliente) with (clasificacion char(2) '$.clasificacion'));
		declare @idFuncionario bigint				= (select idFuncionario from openjson (@pCliente) with (idFuncionario bigint '$.idFuncionario'));
		declare @contactoContador varchar(150)		= (select upper(contactoContador) contactoContador from openjson (@pCliente) with (contactoContador varchar(150) '$.contactoContador'));
		declare @emailContador varchar(150)			= (select upper(emailContador) emailContador from openjson (@pCliente) with (emailContador varchar(150) '$.emailContador'));
		declare @esGestor char(1)					= (select esGestor from openjson (@pCliente) with (esGestor char(1) '$.esGestor'));
		declare @idAgente bigint					= (select idAgente from openjson (@pCliente) with (idAgente bigint '$.idAgente'));
		declare @ucii varchar(50)					= (select ucii from openjson (@pCliente) with (ucii varchar(50) '$.ucii'));

		update SICORE_CLIENTE
		set
			idSector = @idSector,
			nombreCliente = @nombreCliente,
			nombreComercial = @nombreComercial,
			cedulaCliente = @cedulaCliente,
			contactoCliente = @contactoCliente,
			telefonoCliente = @telefonoCliente,
			emailCliente = @emailCliente,
			direccionFisica = @direccionFisica,
			clasificacion = @clasificacion,
			idUsuarioModificoAuditoria = @idFuncionario,
			fechaModificoAuditoria = getdate(),
			contactoContador = @contactoContador,
			emailContador = @emailContador,
			esGestor = @esGestor,
			idAgenteCuenta = @idAgente,
			ucii = @ucii
		where
			idCliente = @idCliente

		select 1 as resultado

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK

	select ERROR_MESSAGE() as resultado
END CATCH