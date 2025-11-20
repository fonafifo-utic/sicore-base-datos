use [SICORE]
go

-- =============================================
-- Author:		Álvaro Zamora Solís
-- Create date: Agosto 2024
-- Description:	Toma un objeto JSON para ingresar un registro a la tabla Proyecto.
-- =============================================

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PA_PROYECTO_INGRESA]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[PA_PROYECTO_INGRESA]
GO

CREATE PROCEDURE [dbo].[PA_PROYECTO_INGRESA] (@pProyecto as nvarchar(max))
AS
BEGIN TRY
	BEGIN TRANSACTION
		
		SET NOCOUNT ON;

		set @pProyecto = replace(@pProyecto, '{ pProyecto = "{', '{');
		set @pProyecto = replace(@pProyecto, '" }', '');

		declare @proyecto varchar(150) = (select proyecto from openjson(@pProyecto) with (proyecto varchar(150) '$.proyecto'));

		if(not exists(select 1 from SICORE_PROYECTO where upper(proyecto) = upper(@proyecto)))
		begin
		
			insert into SICORE_PROYECTO
			select
				upper(proyecto) proyecto,
				descripcionProyecto,
				upper(ubicacionGeografica) ubicacionGeografica,
				getdate(),
				idFuncionario,
				null,
				null,
				periodoInicio,
				periodoFinalizacion,
				especieArboles,
				contratoPSA,
				'A'
			from
				openjson(@pProyecto)
			with
				(
					proyecto varchar(150) '$.proyecto',
					descripcionProyecto varchar(150) '$.descripcionProyecto',
					ubicacionGeografica varchar(150) '$.ubicacionGeografica',
					idFuncionario bigint '$.idFuncionario',
					periodoProyecto int '$.periodoProyecto',
					periodoInicio date '$.periodoInicio',
					periodoFinalizacion date '$.periodoFinalizacion',
					especieArboles varchar(255) '$.especieArboles',
					contratoPSA varchar(100) '$.contratoPSA'
				)

			select 1 as resultado
		end
		else 
			select 2 as resultado

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK

	select ERROR_MESSAGE() as resultado
END CATCH