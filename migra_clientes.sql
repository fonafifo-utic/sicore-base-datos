use SICORE
go

--begin tran
--rollback
--commit

/*
insert into SICORE_CLIENTE
select
	idSectorComercial,
	dbo.FN_GET_CAMEL_CASE(nombre_cliente) nombre_cliente,
	dbo.FN_GET_CAMEL_CASE(nombre_comercial) nombre_comercial,
	cedula,
	dbo.FN_GET_CAMEL_CASE(contacto) contacto,
	telefono,
	lower(email) email,
	'N/A',
	'D',
	getdate(),
	72103,
	null,
	null
from (
		select
			row_number() over (partition by cedula order by nombre_comercial asc) fila,
			sector.idSectorComercial,
			nombre_cliente,
			nombre_comercial,
			cedula,
			contacto,
			telefono,
			email
		from
			[dbo].[clientes$] clientes
		inner join
			SICORE_SECTOR_COMERCIAL sector on UPPER(clientes.sector) = upper(sector.sectorComercial)
		where
			cedula is not null
		and
			contacto is not null
		and
			telefono is not null
		and
			email is not null
	) as tabla_original
where
	tabla_original.fila = 1
*/

--===========================================================================================================--
/*
--insert into SICORE_CLIENTE
select
	idSectorComercial,
	dbo.FN_GET_CAMEL_CASE(nombre_cliente) nombre_cliente,
	dbo.FN_GET_CAMEL_CASE(nombre_comercial) nombre_comercial,
	cedula,
	dbo.FN_GET_CAMEL_CASE(contacto) contacto,
	telefono,
	lower(email) email,
	'N/A',
	'D',
	getdate(),
	72103,
	null,
	null
from (
		select
			row_number() over (partition by cedula order by nombre_comercial asc) fila,
			sector.idSectorComercial,
			nombre_cliente,
			nombre_comercial,
			cedula,
			contacto,
			isnull(telefono,0) telefono,
			email
		from
			[dbo].[clientes$] clientes
		inner join
			SICORE_SECTOR_COMERCIAL sector on UPPER(clientes.sector) = upper(sector.sectorComercial)
		where
			cedula is not null
		and
			contacto is not null
		and
			telefono is null
		and
			email is not null
	) as tabla_original
where
	tabla_original.fila = 1

--===========================================================================================================--
*/

--delete from [dbo].[clientes$]
--where [DIRECCIÓN DE DESARROLLO Y COMERCIALIZACIÓN DE SERVICIOS AMBIENTA] = 'Sector'

-- cuenta total 257 --
-- ================ --
--select * from SICORE_SECTOR_COMERCIAL

--update [dbo].[clientes$]
--set [DIRECCIÓN DE DESARROLLO Y COMERCIALIZACIÓN DE SERVICIOS AMBIENTA] = 'Sector'
--where [DIRECCIÓN DE DESARROLLO Y COMERCIALIZACIÓN DE SERVICIOS AMBIENTA] is null

/*
-- Para revisar --
------------------

select
	F4
from
	[dbo].[clientes$] tabla_grande
where
	substring(F4, 1, 2) not in ('2-', '3-', '4-')

select
	*
from
	[dbo].[clientes$] tabla_grande
where
	substring(F4, 1, 2) in ('2-', '3-', '4-')
and
	F6 is null

select
	*
from
	[dbo].[clientes$] tabla_grande
where
	substring(F4, 1, 2) in ('2-', '3-', '4-')
and
	F5 is not null
and
	F6 is not null
and
	F7 is not null
and
	F6 in ('Sin información disponible')
and
	F6 like ('%ext%')
replace(replace(replace(replace(F6, '-', ''), '; ', ';'), '/', ''), ' ', '') != ('255479709')
and
	replace(replace(replace(replace(lower(F7), '/ ', ';'), ' / ', ';'), '; ', ''), ':', ';') != 'lsoto@spradling.grouplrodriguez@spradling.group'

*/

--select * from SICORE_CLIENTE

/*

declare @tabla as table
(
	indice int,
	telefono varchar(150)
)

insert into @tabla
select
	row_number() over (order by F6) indice,
	F6  telefonoCliente
from
	[dbo].[clientes$] tabla_grande
inner join
	SICORE_SECTOR_COMERCIAL sector on tabla_grande.[DIRECCIÓN DE DESARROLLO Y COMERCIALIZACIÓN DE SERVICIOS AMBIENTA] = sector.sectorComercial
where
	substring(F4, 1, 2) in ('2-', '3-', '4-')
and
	F5 is not null
and
	F6 is not null
and
	F7 is not null
and
	F6 not in ('Sin información disponible')
and
	F6 not like ('%ext%')

declare @min int = (select min(indice) from @tabla);
declare @max int = (select MAX(indice) from @tabla);

while (@min <= @max)
begin

	declare @espacioBlanco char(1) = ' ';
	declare @guion char(1) = '-';
	declare @pleca char(1) = '/';

	declare @datoLimpio varchar(150) = (
											select
												replace(telefono, @espacioBlanco, '')
											from
												@tabla
											where
												indice = @min
										);

	update @tabla
	set
		telefono = @datoLimpio
	where
		indice = @min;

	set @datoLimpio = (
							select
								replace(telefono, @guion, '')
							from
								@tabla
							where
								indice = @min
						);

	update @tabla
	set
		telefono = @datoLimpio
	where
		indice = @min;

	set @datoLimpio = (
							select
								replace(telefono, @pleca, ';')
							from
								@tabla
							where
								indice = @min
						);

	update @tabla
	set
		telefono = @datoLimpio
	where
		indice = @min;

	set @min = (select min(indice) from @tabla where @min < indice);
end

select * from @tabla

*/

begin tran
--commit

insert into SICORE_CLIENTE
select
	sector.idSectorComercial,
	upper(F2) nombreCliente,
	upper(F3) nombreComercial,
	replace(replace(F4, '-', ''), ' ', '') cedulaCliente,
	upper(F5) contactoCliente,
	dbo.FN_REPLAZA_GUION_PLECA(F6)  telefonoCliente,
	dbo.FN_REPLAZA_GUION_PLECA(upper(F7)) emailCliente,
	'' direccionFisica,
	'D' clasificacion,
	'A' indicadorEstado,
	getdate() fechaInsertoAuditoria,
	72103 idUsuarioInsertoAuditoria,
	getdate() fechaModificoAuditoria,
	72103 idUsuarioModificoAuditoria
from
	[dbo].[clientes$] tabla_grande
inner join
	SICORE_SECTOR_COMERCIAL sector on tabla_grande.[DIRECCIÓN DE DESARROLLO Y COMERCIALIZACIÓN DE SERVICIOS AMBIENTA] = sector.sectorComercial
where
	substring(F4, 1, 2) in ('2-', '3-', '4-')
and
	F5 is not null
and
	F6 is not null
and
	F7 is not null
and
	F6 not in ('Sin información disponible')
and
	F6 not like ('%ext%')

select * from SICORE_CLIENTE