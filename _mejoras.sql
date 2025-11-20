use SICORE
go

insert into SICORE_PANTALLA
values (
	'Encuesta',
	'pi pi-star',
	'encuesta/encuesta-enviada'
),
(
	'Reportes',
	'pi pi-list',
	'reportes/listar'
)
go

insert into SICORE_PANTALLA_POR_ROL
values
(
	11,
	1
),
(
	11,
	2
),
(
	1,
	4
),
(
	4,
	4
),
(
	5,
	4
),
(
	6,
	4
),
(
	7,
	4
),
(
	8,
	4
),
(
	11,
	4
),
(
	11,
	3
)
go

alter table SICORE_ENCUESTA_TRAZA
add conteoEnvios int not null
go

alter table SICORE_CERTIFICADO
add observaciones nvarchar(max) null
go

update SICORE_CERTIFICADO
set observaciones = ''
go

alter table SICORE_CERTIFICADO
alter column observaciones nvarchar(max) not null
go

alter table SICORE_PERSONALIZACION
add directorEjecutivo varchar(250) null
go

update SICORE_PERSONALIZACION
set directorEjecutivo = ''
go

alter table SICORE_PERSONALIZACION
alter column directorEjecutivo varchar(250) not null
go

use SCGI_TRAZA
go

alter table SICORE_CERTIFICADO
add observaciones nvarchar(max) null
go

update SICORE_CERTIFICADO
set observaciones = ''
go

alter table SICORE_CERTIFICADO
alter column observaciones nvarchar(max) not null
go

alter table SICORE_PERSONALIZACION
add directorEjecutivo varchar(250) null
go

update SICORE_PERSONALIZACION
set directorEjecutivo = ''
go

alter table SICORE_PERSONALIZACION
alter column directorEjecutivo varchar(250) not null
go

/*

PA_ENVIAR_CERTIFICADO
PA_ENCUESTA_HECHA_CLIENTE_INGRESA
PA_ENCUESTA_LISTADO_RESPUESTAS_DELMES
PA_ENCUESTA_TRAE_ENVIADAS
PA_REENVIAR_ENCUESTA
PA_REPORTES_TRAE_MESES_CERTIFICADO
PA_REPORTES_TRAE_ANNOS_CERTIFICADO
PA_REPORTES_TRAE_LISTADO_CERTIFICADO_PORMES
PA_REPORTES_TRAE_LISTADO_COTIZACIONES_PORMES
PA_REPORTES_TRAE_MESES_COTIZACION
PA_REPORTES_TRAE_ANNOS_COTIZACION
PA_ENVIAR_CERTIFICADO_PARA_FIRMAR
PA_DOBLEFACTOR_ENVIAR_CODIGOSEGURIDAD
PA_REPORTES_TRAE_LISTADO_FORMALIZACION_PORMES
PA_REPORTES_TRAE_ANNOS_FORMALIZACION
PA_REPORTES_TRAE_MESES_FORMALIZACION
CERTIFICADO_I_TR
CERTIFICADO_U_TR
PA_CERTIFICADO_TRAE_PORID
PA_FORMALIZACION_CIERRA_FORMALIZACION
PERSONALIZACION_I_TR
PERSONALIZACION_U_TR
PA_PERSONALIZACION_ACTUALIZA
PA_PERSONALIZACION_TRAE_LISTADO
PA_CERTIFICADO_ACTUALIZA_OBSERVACIONES
PA_PERSONALIZACION_TRAE_DIRECTORES

Copiar manual en la ruta: E:/ExpedienteSICORE/DG-UTIC-M-04-2024v1.4.pdf

*/