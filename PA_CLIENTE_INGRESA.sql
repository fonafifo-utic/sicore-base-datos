use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Agosto 2024
-- Description:	Toma un objeto JSON para ingresar registros en la tabla Cliente.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_CLIENTE_INGRESA]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_CLIENTE_INGRESA]
GO

CREATE PROCEDURE [dbo].[PA_CLIENTE_INGRESA] (@pCliente as nvarchar(max))
AS
BEGIN TRY
	BEGIN TRAN
		
		set @pCliente = replace(@pCliente, '{ pCliente = "{', '{');
		set @pCliente = replace(@pCliente, '" }', '');

		declare @cedulaCliente varchar(150) = (select cedulaCliente from openjson (@pCliente) with (cedulaCliente varchar(150) '$.cedulaCliente'));
		declare @emailCliente varchar(150) = (select emailCliente from openjson (@pCliente) with (emailCliente varchar(150) '$.emailCliente'));

		if(exists(select 1 from SICORE_CLIENTE where cedulaCliente = @cedulaCliente or emailCliente = @emailCliente))
		begin
			select 2 as resultado
		end
		else
		begin
			insert into SICORE_CLIENTE
				select
					idSector,
					upper(nombreCliente) nombreCliente,
					upper(nombreComercial) nombreComercial,
					cedulaCliente,
					upper(contactoCliente) contactoCliente,
					telefonoCliente,
					upper(emailCliente) emailCliente,
					upper(direccionFisica) direccionFisica,
					upper(clasificacion) clasificacion,
					indicadorEstado,
					getdate(),
					idFuncionario,
					null,
					null,
					upper(contactoContador) contactoContador,
					upper(emailContador) emailContador,
					'N',
					idAgente,
					ucii
				from
					openjson(@pCliente)
				with
					(
						idSector bigint '$.idSector',
						nombreCliente varchar(255) '$.nombreCliente',
						nombreComercial varchar(255) '$.nombreComercial',
						cedulaCliente varchar(150) '$.cedulaCliente',
						contactoCliente varchar(150) '$.contactoCliente',
						telefonoCliente varchar(150) '$.telefonoCliente',
						emailCliente varchar(150) '$.emailCliente',
						direccionFisica varchar(255) '$.direccionFisica',
						clasificacion char(2) '$.clasificacion',
						idFuncionario bigint '$.idFuncionario',
						indicadorEstado char(1) '$.indicadorEstado',
						contactoContador varchar(150) '$.contactoContador',
						emailContador varchar(150) '$.emailContador',
						idAgente bigint '$.idAgente',
						ucii varchar(10) '$.ucii'
					)

			select 1 as resultado
		end

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK

	select ERROR_MESSAGE() as resultado
END CATCH