USE SICORE
GO

-- =============== tablas administrativas ================================ --
drop table if exists SICORE_PERFIL;
create table [dbo].[SICORE_PERFIL](
	[idPerfil] [bigint] IDENTITY(1,1) NOT NULL,
	[nombre] [varchar](150) NOT NULL,
	[descripcion] [varchar](250) NULL
)
go

exec sp_addextendedproperty
	N'MS_Description',
	'Tabla que almacena un listado de perfiles.',
	N'user', N'dbo', N'table',
	N'SICORE_PERFIL', NULL, NULL
go

insert into SICORE_PERFIL
values
	('Administrador', 'Administrador de SICORE.'),
	('Usuario DM', 'Usuario de SICORE.'),
	('Financiero', 'Usuario del departamento Financiero.'),
	('Asistente DDC', 'Asistente del Departamento.'),
	('Asistente Dirección Ejecutiva', 'Usuario de la dirección ejecutiva.'),
	('Jefatura DP', 'Permisos de jefatura. Aprueba Cotizaciones. Ajusta inventario.'),
	('Jefatura DM', 'Permisos de jefatura. Aprueba Cotizaciones. Ajusta inventario.'),
	('Jefatura DF', 'Aprueba Formalizaciones.'),
	('Director', 'Gerenciar'),
	('Jefatura DPC', 'Aprueba Formalizaciones.')
go

drop table if exists SICORE_USUARIO;
create table [dbo].[SICORE_USUARIO](
	idUsuarioInterno bigint identity(1,1) not null
		constraint PK_USUARIO_idUsuario primary key,
	idUsuario  bigint not null,
	idPerfil bigint not null
)
go

exec sp_addextendedproperty
	N'MS_Description',
	'Tabla que almacena un listado de funcionarios que participan directamente con el SICORE.',
	N'user', N'dbo', N'table',
	N'SICORE_USUARIO', NULL, NULL
go

insert into SICORE_USUARIO
values (72103, 1), (79028, 1)
go

drop table if exists SICORE_PARAMETROS;
create table [dbo].[SICORE_PARAMETROS] (
	idParametro bigint identity(1,1) not null,
	[valor] [varchar](50) NULL,
	[descripcion] [varchar](150) NULL
)
go

exec sp_addextendedproperty
	N'MS_Description',
	'Tabla miselanea para control administrativo de usuarios.',
	N'user', N'dbo', N'table',
	N'SICORE_PARAMETROS', NULL, NULL
go

insert into SICORE_PARAMETROS
values
	('30', 'Total de días naturales para resolución de una solicitud'),
	('10', 'Días hábiles para corregir inconsistencias del formulario de solicitud de crédito'),
	('1', 'Consecutivo para el número de solicitud y número de expediente'),
	('tipos de propietarios', 'Dueño, Arrendatario, Albacea'),
	('S', 'Activar Doble Factor (N-No | S-Sí)'),
	('local', 'servidor donde está instalado el sistema (desa ó scgi)')
go

drop table if exists SICORE_PANTALLA;
create table [dbo].[SICORE_PANTALLA](
	idPantalla bigint identity(1,1) not null,
	titulo varchar(150) not null,
	icono varchar(100) not null,
	rutaEnlace varchar(150) not null
)
go

exec sp_addextendedproperty
	N'MS_Description',
	'Tabla que guarda los nombres y enlaces del sistema.',
	N'user', N'dbo', N'table',
	N'SICORE_PANTALLA', NULL, NULL
go

insert into SICORE_PANTALLA
values
(
	'Dashboard',
    'pi pi-home',
    'dashboard'
),
(
	'Usuarios',
	'pi pi-users',
	'usuarios/listar'
),
(            
    'Proyectos',
    'pi pi-briefcase',
    'proyecto/listar'  
),
(
	'Inventario',
	'pi pi-box',
	'inventario/listar'     
),
( 
    'Clientes',
    'pi pi-address-book',
    'clientes/listar'
),
( 
    'Cotización',
    'pi pi-file',
    'cotizacion/listar'
),
(
    'Formalización',
    'pi pi-chart-line',
    'formalizacion/listar'
),
(   
	'Certificados',
	'pi pi-id-card',
	'certificados/listar'
),
(     
    'Personalización',
    'pi pi-sliders-h',
    'personalizacion/listar'
),
(
    'Encuesta',
    'pi pi-star',
    'encuesta/dashboard'
),
(
	'Reportes',
	'pi pi-list',
	'reportes/listar'
)
go

drop table if exists SICORE_PANTALLA_POR_ROL;
create table [dbo].[SICORE_PANTALLA_POR_ROL](
	idPantallaPorRol bigint identity(1,1) not null,
	idPantalla bigint not null,
	idPerfil bigint not null
)
go

exec sp_addextendedproperty
	N'MS_Description',
	'Tabla que asocia el nombre de las pantallas con los roles o perfiles del sistema.',
	N'user', N'dbo', N'table',
	N'SICORE_PANTALLA_POR_ROL', NULL, NULL
go

insert into SICORE_PANTALLA_POR_ROL
values
(1,	1),
(2, 1),
(3, 1),
(4, 1),
(5, 1),
(6, 1),
(7, 1),
(8, 1),
(9, 1),
(10, 1),
(11, 1),
(1, 2),
(4, 2),
(5, 2),
(6, 2),
(7, 2),
(8, 2),
(10, 2),
(11, 2),
(7, 3),
(10, 4),
(1, 4),
(4, 4),
(5, 4),
(6, 4),
(7, 4),
(8, 4),
(11, 4),
(1, 6),
(4, 6),
(5, 6),
(6, 6),
(7, 6),
(8, 6),
(10, 6),
(11, 6),
(1, 7),
(4, 7),
(5, 7),
(6, 7),
(7, 7),
(8, 7),
(10, 7),
(11, 7),
(7, 8),
(11, 8),
(7,	10),
(11, 10)
go

-- ============================================================================================================================= --
-- =============== tablas sistema ================================ --

drop table if exists SICORE_PROYECTO;
create table SICORE_PROYECTO (
	idProyecto bigint identity(1,1) not null
		constraint PK_PROYECTO_idProyecto primary key,
	proyecto varchar(150) not null,
	descripcionProyecto nvarchar(255) not null,
	ubicacionGeografica varchar(150) not null,
	fechaInsertoAuditoria datetime null,
	idUsuarioInsertoAuditoria bigint null,
	fechaModificoAuditoria datetime null,
	idUsuarioModificoAuditoria bigint null,
	periodoInicio date not null,
	periodoFinalizacion date not null,
	especieArboles varchar(255) not null,
	contratoPSA  varchar(100) not null,
	indicadorEstado char(1) not null
)
go

exec sp_addextendedproperty
	N'MS_Description',
	'Tabla que almacena un listado de proyectos.',
	N'user', N'dbo', N'table',
	N'SICORE_PROYECTO', NULL, NULL
go

drop table if exists SICORE_INVENTARIO;
create table SICORE_INVENTARIO (
	idInventario bigint identity(1,1) not null
		constraint PK_INVENTARIO_idInventario primary key, 
	idProyecto bigint not null
		constraint FK_PROYECTO_idProyecto foreign key
			references SICORE_PROYECTO (idProyecto),
	remanente decimal(18,2) not null,
	vendido decimal(18,2) not null,
 	comprometido decimal(18,2) not null,
	periodo int not null,
	fechaInsertoAuditoria datetime null, --fecha_actual.
	idUsuarioInsertoAuditoria bigint null, --el que está logueado.
	fechaModificoAuditoria datetime null, --fecha de la actualización.
	idUsuarioModificoAuditoria bigint null --usuario que modifica.
)
go

exec sp_addextendedproperty
	N'MS_Description',
	'Tabla que almacena un listado de invetario de UCC.',
	N'user', N'dbo', N'table',
	N'SICORE_INVENTARIO', NULL, NULL
go

drop table if exists SICORE_MOVIMIENTO_INVENTARIO;
create table SICORE_MOVIMIENTO_INVENTARIO (
	idMovimiento bigint identity(1,1) not null
		constraint PK_MOVIMIENTO_INVENTARIO_idMovimiento primary key,
	idProyecto bigint not null
		constraint FK_MOVIMIENTO_PROYECTO_idProyecto foreign key
			references SICORE_PROYECTO (idProyecto),
	idUsuario bigint not null,
	fechaMovimiento datetime not null,
	cantidad decimal(18,2) not null,
	descripcionMovimiento nvarchar(max) not null,
	tipoMovimiento char(1) not null,
 	remanenteVirtual decimal(18,2) not null,
	remanenteReal decimal(18,2) not null,
	fechaInsertoAuditoria datetime null, --fecha_actual.
	idUsuarioInsertoAuditoria bigint null, --el que está logueado.
	fechaModificoAuditoria datetime null, --fecha de la actualización.
	idUsuarioModificoAuditoria bigint null --usuario que modifica.
)
go

exec sp_addextendedproperty
	N'MS_Description',
	'Tabla que almacena todos los movimientos de entradas y salidas en inventario.',
	N'user', N'dbo', N'table',
	N'SICORE_MOVIMIENTO_INVENTARIO', NULL, NULL
go

EXEC sys.sp_addextendedproperty
	@name=N'MS_Description',
	@value=N'Usa un tipo de movimiento: Entrada (I) y Salida (S)',
	@level0type=N'SCHEMA',
	@level0name=N'dbo',
	@level1type=N'TABLE',
	@level1name=N'SICORE_MOVIMIENTO_INVENTARIO',
	@level2type=N'COLUMN',
	@level2name=N'tipoMovimiento'
GO

-- ============================================================================================================================= --
-- =============== segunda etapa ================================ --
drop table if exists SICORE_SECTOR_COMERCIAL;
create table SICORE_SECTOR_COMERCIAL (
	idSectorComercial bigint identity(1,1) not null
		constraint PK_SECTOR_idSector primary key,
	sectorComercial varchar(255) not null
)
go

exec sp_addextendedproperty
	N'MS_Description',
	'Tabla que almacena todos los sectores comerciales para crear una cotización.',
	N'user', N'dbo', N'table',
	N'SICORE_SECTOR_COMERCIAL', NULL, NULL
go

insert into SICORE_SECTOR_COMERCIAL
values
('Agropecuario'),
('Banca y Finanzas'),
('Comercial'),
('Diplomacia'),
('Educación'),
('Inmobiliaria'),
('Manufactura e Industria'),
('Persona Física'),
('Salud General'),
('Servicios'),
('Tecnología, Comunicación y Energía'),
('Transporte'),
('Turismo'),
('Zona Franca'),
('Exportación (Sin ZF)'),
('Sin Datos')
go

drop table if exists SICORE_TIPO_EMPRESA;
create table SICORE_TIPO_EMPRESA (
	idTipoEmpresa bigint identity(1,1) not null
		constraint PK_TIPO_EMPRESA_idTipoEmpresa primary key,
	idSector bigint not null
		constraint FK_TIPO_EMPRESA_idSector foreign key
			references SICORE_SECTOR_COMERCIAL (idSectorComercial),
	tipoEmpresa varchar(255) not null
)
go

exec sp_addextendedproperty
	N'MS_Description',
	'Tabla que almacena todos los tipos de empresa para crear una cotización.',
	N'user', N'dbo', N'table',
	N'SICORE_TIPO_EMPRESA', NULL, NULL
go

insert into SICORE_TIPO_EMPRESA
values
(1, 'Agrocomercio'),
(1, 'Apoyo Técnico e Investigación'),
(1, 'Asistencia Técnica'),
(1, 'Producción Agrícola'),
(1, 'Servicios Profesionales'),
(1, 'Venta mayorista/minorista'),
(2, 'Inversión Planes de Pensión'),
(2, 'Servicios Bancarios'),
(2, 'Servicios Bolsa Valores'),
(2, 'Sin Fines de Lucro'),
(3, 'Asesoría y Promoción sectorial'),
(3, 'Logística'),
(3, 'Minorista y asesoría'),
(3, 'Restaurante y Eventos'),
(3, 'Servicios especiales'),
(3, 'Venta mayorista/minorista'),
(4, 'ONG/Gubernamental'),
(4, 'Política Pública'),
(5, 'Educativa y Formación'),
(5, 'Universitaria privada'),
(5, 'Universitaria Pública'),
(5, 'Universitaria Internacional'),
(6, 'Alquiler comercial'),
(6, 'Apoyo Técnico e Investigación'),
(6, 'Asesoría y Proyectos Constructivos'),
(6, 'Política Pública'),
(6, 'Servicios Profesionales'),
(7, 'Alimentos y bebidas'),
(7, 'Apoyo Técnico e Investigación'),
(7, 'Mobiliario y Línea Blanca'),
(7, 'Productos de Concreto'),
(7, 'Productos de Contrucción'),
(7, 'Productos de uso personal'),
(7, 'Productos Especializados'),
(7, 'Productos químicos'),
(7, 'Tecnología y diseño'),
(7, 'Venta mayorista/minorista'),
(8, 'Persona Física'),
(9, 'Comercial'),
(9, 'Farmaceútica'),
(9, 'Servicios Médicos'),
(9, 'Venta mayorista/minorista'),
(10, 'Alquiler y Eventos'),
(10, 'Asesoría y Promoción sectorial'),
(10, 'Comercial'),
(10, 'Educativa y Formación'),
(10, 'Institución Pública'),
(10, 'Mecánica'),
(10, 'Publicidad y Medios'),
(10, 'Recreación'),
(10, 'Seguros'),
(10, 'Servicio Ambiental'),
(10, 'Servicios funerarios'),
(10, 'Servicios Legales'),
(10, 'Servicios Profesionales'),
(10, 'Sin Fines de Lucro'),
(10, 'Alquileres y otros'),
(10, 'Apoyo Técnico e Investigación'),
(10, 'Política Pública'),
(11, 'Comercializ. Componentes Tecnología'),
(11, 'Electrificación y Servicios Públicos'),
(11, 'Institución Pública'),
(11, 'Servicios especiales'),
(11, 'Servicios Profesionales'),
(11, 'Venta mayorista/ minorista'),
(12, 'Aeroportuario'),
(12, 'Hidrocarburos'),
(12, 'Renta Car'),
(12, 'Transpote Público/ Privado'),
(12, 'Venta mayorista/ minorista'),
(13, 'Agencia turismo'),
(13, 'Asesoría y Promoción sectorial'),
(13, 'Hotelería'),
(13, 'Institución Pública'),
(13, 'Servicio Turístico'),
(13, 'Sin Fines de Lucro'),
(14, 'Alquiler comercial'),
(14, 'Equipo Médico'),
(14, 'Servicios Profesionales'),
(14, 'Tecnología')
go

drop table if exists SICORE_CLIENTE;
create table SICORE_CLIENTE (
	idCliente bigint identity(1,1) not null
		constraint PK_CLIENTE_idCliente primary key,
	idSector bigint not null
		constraint FK_SECTOR_COMERCIAL_idSector foreign key
			references SICORE_SECTOR_COMERCIAL(idSectorComercial),
	nombreCliente varchar(255) not null,
	nombreComercial varchar(255) not null,
	cedulaCliente varchar(150) not null,
	contactoCliente varchar(150) not null,
	telefonoCliente varchar(255) not null,
	emailCliente varchar(150) not null,
	direccionFisica varchar(255) not null,
	clasificacion char(2) not null,
	indicadorEstado char(1) not null,
	fechaInsertoAuditoria datetime null,
	idUsuarioInsertoAuditoria bigint null,
	fechaModificoAuditoria datetime null,
	idUsuarioModificoAuditoria bigint null,
	contactoContador varchar(150) null,
    emailContador varchar(150) null,
	esGestor char(1) not null,
	idAgenteCuenta bigint null,
	ucii varchar(10)
)
go

exec sp_addextendedproperty
	N'MS_Description',
	'Tabla que almacena todos los clientes.',
	N'user', N'dbo', N'table',
	N'SICORE_CLIENTE', NULL, NULL
go

drop table if exists SICORE_COTIZACION;
create table SICORE_COTIZACION (
	idCotizacion bigint identity (1,1) not null
		constraint PK_COTIZACION_idCotizacion primary key,
	idCliente bigint not null
		constraint FK_CLIENTE_idCliente foreign key
			references SICORE_CLIENTE(idCliente),
	idFuncionario bigint not null,
	idProyecto bigint not null
		constraint FK_COTIZACION_PROYECTO_idProyecto foreign key
			references SICORE_PROYECTO(idProyecto),
	fechaHora datetime not null,
	fechaExpiracion date not null,
	cantidad decimal(18,2) not null,
	precioUnitario decimal(18,2) not null,
	subTotal decimal(18,2) not null,
	montoTotalColones decimal(18,2) not null,
	montoTotalDolares decimal(18,2) not null,
	consecutivo int not null,
	anotaciones nvarchar(max) not null,
	indicadorEstado char(1) not null,
	fechaInsertoAuditoria datetime null, --fecha_actual.
	idUsuarioInsertoAuditoria bigint null, --el que está logueado.
	fechaModificoAuditoria datetime null, --fecha de la actualización.
	idUsuarioModificoAuditoria bigint null, --usuario que modifica.
	cuentaConvenio char(1) not null,
	cotizacionEnIngles bit not null,
	cotizacionEnviada bit not null,
	tipoCompra varchar(100) not null,
	justificacionCompra varchar(100) not null,
	observacionDeAprobacion nvarchar(max) not null
)
go

exec sp_addextendedproperty
	N'MS_Description',
	'Tabla que almacena un listado de cotizaciones.',
	N'user', N'dbo', N'table',
	N'SICORE_COTIZACION', NULL, NULL
go

EXEC sys.sp_addextendedproperty
	@name=N'MS_Description',
	@value=N'Usa cuentaConvenio para determinar si la cuenta bancaria pertenece a: Banco Nacional (N), Fideicomiso (F) y PSA Mujer (M)',
	@level0type=N'SCHEMA',
	@level0name=N'dbo',
	@level1type=N'TABLE',
	@level1name=N'SICORE_COTIZACION',
	@level2type=N'COLUMN',
	@level2name=N'cuentaConvenio'
GO

-- ============================================================================================================================= --
-- =============== tercera etapa ================================ --

drop table if exists SICORE_FORMALIZACION;
create table SICORE_FORMALIZACION (
	idFormalizacion bigint identity(1,1) not null
		constraint PK_FORMALIZACION_idFormalizacion primary key,
	idCotizacion bigint not null
		constraint FK_FACTURA_idCotizacion foreign key
			references SICORE_COTIZACION (idCotizacion),
	idFuncionario bigint not null,
	fechaHora datetime not null,
	montoDolares decimal (18,2) not null,
	montoColones decimal (18,2) not null,
	consecutivo int not null,
	numeroFacturaFonafifo varchar(100) not null,
	numeroTransferencia varchar(100) not null,
	justificacionCompra varchar(255) not null,
	creditoDebito char(1) not null,
	indicadorEstado char(1),
	tieneFacturas char(1) not null,
	fechaHoraFormalizacion datetime not null,
	fechaInsertoAuditoria datetime null,
	idUsuarioInsertoAuditoria bigint null,
	fechaModificoAuditoria datetime null,
	idUsuarioModificoAuditoria bigint null,
	numeroComprobante varchar(100) not null,
	vistoBuenoJefatura char(1) not null,
	justificacionActivacion nvarchar(max) not null,
	numeroCIIU varchar(50) not null
)
go


	[idFormalizacion] [bigint] IDENTITY(1,1) NOT NULL,
	[idCotizacion] [bigint] NOT NULL,
	[idFuncionario] [bigint] NOT NULL,
	[fechaHora] [datetime] NOT NULL,
	[montoDolares] [decimal](18, 2) NOT NULL,
	[montoColones] [decimal](18, 2) NOT NULL,
	[consecutivo] [int] NOT NULL,
	[numeroFacturaFonafifo] [varchar](100) NOT NULL,
	[numeroTransferencia] [varchar](100) NOT NULL,
	[justificacionCompra] [varchar](255) NOT NULL,
	[creditoDebito] [char](1) NOT NULL,
	[indicadorEstado] [char](1) NULL,
	[tieneFacturas] [char](1) NOT NULL,
	[fechaHoraFormalizacion] [datetime] NOT NULL,
	[fechaInsertoAuditoria] [datetime] NULL,
	[idUsuarioInsertoAuditoria] [bigint] NULL,
	[fechaModificoAuditoria] [datetime] NULL,
	[idUsuarioModificoAuditoria] [bigint] NULL,
	[numeroComprobante] [varchar](100) NOT NULL,
	[vistoBuenoJefatura] [char](1) NULL,
	[justificacionActivacion] [nvarchar](max) NULL,
	[numeroCIIU] [varchar](50) NOT NULL,
 



exec sp_addextendedproperty
	N'MS_Description',
	'Tabla que almacena un listado de facturas emitidas.',
	N'user', N'dbo', N'table',
	N'SICORE_FORMALIZACION', NULL, NULL
go

drop table if exists SICORE_CERTIFICADO;
create table SICORE_CERTIFICADO (
	idCertificado bigint identity(1,1) not null
		constraint PK_CERTIFICADO_idCertificado primary key,
	idFormalizacion bigint not null
		constraint FK_CERTIFICADO_idFormalizacion foreign key
			references SICORE_FORMALIZACION (idFormalizacion),
	idCotizacion bigint not null
		constraint FK_CERTIFICADO_idCotizacion foreign key
			references SICORE_COTIZACION (idCotizacion),
	idFuncionario bigint not null,
	numeroCertificado varchar (10) not null,
	nombreCertificado varchar(100) not null,
	fechaEmisionCertificado datetime not null,
	cedulaJuridicaComprador varchar(100) not null,
	montoTransferencia decimal(18,5) not null,
	numeroTransferencia varchar(100) not null,
	fechaTransferencia date not null,
	annoInventarioGEI int null,
	fechaInsertoAuditoria datetime null,
	idUsuarioInsertoAuditoria bigint null,
	fechaModificoAuditoria datetime null,
	idUsuarioModificoAuditoria bigint null,
	observaciones nvarchar(max) null,
	numeroIdentificacionInterno varchar(150) null,
	justificacionEdicion nvarchar(max) null,
	indicadorEstado char(1) null,
	cssCertificado nvarchar(max) null,
	enIngles char(1) null
)
go

exec sp_addextendedproperty
	N'MS_Description',
	'Tabla que almacena un listado de certificados emitidos.',
	N'user', N'dbo', N'table',
	N'SICORE_CERTIFICADO', NULL, NULL
go

-- ============================================================================================================================= --
-- =============== cuarta etapa ================================ --

drop table if exists SICORE_PERSONALIZACION;
create table SICORE_PERSONALIZACION (
	idPersonalizacion bigint identity(1,1) not null
		constraint PK_PERSONALIZACION_idPersonalizacion primary key,
	logoPrincipal varbinary (max) null,
	logoSecundario varbinary (max) null,
	tercerLogo varbinary (max) null,
	logoSistema varbinary (max) null,
	leyendaDescriptivaCotizacionEspannol varchar(max) null,
	leyendaDescriptivaCotizacionIngles varchar(max) null,
	leyendaFinalidadCotizacionEspannol varchar(max) null,
	leyendaFinalidadCotizacionIngles varchar(max) null,
	leyendaDescripcionCertificadoEspannol varchar(max) null,
	leyendaDescripcionCertificadoIngles varchar(max) null,
	fechaInsertoAuditoria datetime null,
	idUsuarioInsertoAuditoria bigint null,
	fechaModificoAuditoria datetime null,
	idUsuarioModificoAuditoria bigint null,
	correoGerenciaEjecutiva varchar(100) not null,
	directorEjecutivo varchar(250) not null
)
go

exec sp_addextendedproperty
	N'MS_Description',
	'Tabla que almacena las leyendas de las cotizaciones y de los certificados.',
	N'user', N'dbo', N'table',
	N'SICORE_PERSONALIZACION', NULL, NULL
go

insert into SICORE_PERSONALIZACION
select
	null,
	null,
	null,
	null,
	N'Cada unidad corresponde a una tonelada de carbono equivalente fijado en proyectos conformados por contratos de Pago por Servicios Ambientales, actividad reforestación.',
	N'Greenhouse Gas Emissions Compensation Units. Each unit corresponds to one ton of carbon equivalent fixed in projects made up of Payment for Environmental Services contracts, reforestation activity.',
	N'El dinero captado por concepto de compra voluntaria de créditos de carbono, se dirige al Programa Nacional de Pago por Servicios Ambientales (Ley 7575), mediante el cual Costa Rica enfrenta el cambio climático, protege biodiversidad y recurso hídrico, en favor de la Sociedad, el desarrollo sostenible, de propietarios/as y poseedores/as de fincas que protegen y recuperan cobertura forestal. La compensación voluntaria de las emisiones de gases de efecto invernadero de viajes, permite a las personas asumir la responsabilidad de sus emisiones restantes al apoyar resultados de mitigación adicionales que ocurren fuera de sus límites.',
	N'The money collected from the voluntary purchase of carbon credits is directed to the National Program of Payment for Environmental Services (Law 7575), through which Costa Rica faces climate change, protects biodiversity and the water resource, in favor of society, sustainable development, and owners of farms that protect and recover forest cover. Voluntary offsetting of greenhouse gas emissions from travel allows people to take responsibility for their remaining emissions by supporting additional mitigation and adaptation outcomes that occur in tropical ecosystems. Costa Rica is a megadiverse country, and the only one in Latin America that has reversed the deforestation process.',
	N'Fonafifo está autorizado por Ley Forestal 7575, su Reglamento y modificaciones, a desarrollar proyectos de créditos de carbono, para el mercado nacional e internacional. El dinero captado es aplicado en el Programa de Pago por Servicios Ambientales (PSA), en actividades de mantenimiento y de restauración de bosques. Fonafifo ganó en 2020 el premio UN Global Climate Action Awards - Financing for Climate Friendly Investment. En 2021, en reconocimiento del Sistema de Áreas Protegidas y del Programa de PSA, Costa Rica recibió el premio Earthshot en la categoría de "Protect and Restore Nature“. Costa Rica es el único país de América Latina que ha revertido el proceso de deforestación.',
	N'Fonafifo is authorized by Forest Law 7575, its Regulations and modifications, to develop carbon credit projects for the national and international market. The money raised is applied to the Payment for Environmental Services Program (PES), in forest maintenance and restoration activities. Fonafifo won the UN Global Climate Action Awards - Financing for Climate Friendly Investment in 2020. In 2021, in recognition of the Protected Areas System and the PES Program, Costa Rica received the Earthshot award in the category of "Protect and Restore Nature. In 2024, the Global Excellence award presented to the country in Dubai, highlighted the Program of PES. Costa Rica is the only country in Latin America that has reversed the deforestation process. www.fonafifo.go.cr.',
	getdate(),
	72103,
	null,
	null,
	N'wesly.sanchez@fonafifo.go.cr'
go

drop table if exists SICORE_ENCUESTA_PREGUNTA;
create table SICORE_ENCUESTA_PREGUNTA (
	idPregunta bigint identity(1,1) not null
		constraint PK_ENCUESTA_PREGUNTA_idPregunta primary key,
	idFuncionario bigint not null,
	pregunta nvarchar(max) not null,
	tipoPregunta char(1) not null,
	indicadorEstado char(1) not null,
	fechaInsertoAuditoria datetime null,
	idUsuarioInsertoAuditoria bigint null,
	fechaModificoAuditoria datetime null,
	idUsuarioModificoAuditoria bigint null
)
go

exec sp_addextendedproperty
	N'MS_Description',
	'Tabla que almacena las preguntas para la encuesta de satisfacción.',
	N'user', N'dbo', N'table',
	N'SICORE_ENCUESTA_PREGUNTA', NULL, NULL
go

drop table if exists SICORE_ENCUESTA_RESPUESTA;
create table SICORE_ENCUESTA_RESPUESTA (
	idRespuesta bigint identity(1,1) not null
		constraint PK_ENCUESTA_RESPUESTA_idRespuesta primary key,
	idPregunta bigint not null,
	respuestaOpcion nvarchar(max) null,
	valorRespuesta int null,
	fechaInsertoAuditoria datetime null,
	idUsuarioInsertoAuditoria bigint null,
	fechaModificoAuditoria datetime null,
	idUsuarioModificoAuditoria bigint null
)
go

exec sp_addextendedproperty
	N'MS_Description',
	'Tabla que almacena las respuestas para la encuesta de satisfacción.',
	N'user', N'dbo', N'table',
	N'SICORE_ENCUESTA_RESPUESTA', NULL, NULL
go

drop table if exists SICORE_ENCUESTA_REPORTE;
create table SICORE_ENCUESTA_REPORTE (
	idReporte bigint identity(1,1) not null
		constraint PK_ENCUESTA_REPORTE_idReporte primary key,
	idCliente bigint not null,
	pregunta nvarchar(max) not null,
	respuesta nvarchar(max) not null,
	valor nvarchar(max) null,
	fechaHoraRespuesta datetime not null,
	tipoPregunta char(1) not null
)
go

exec sp_addextendedproperty
	N'MS_Description',
	'Tabla que almacena el reporte de la encuenta enviada.',
	N'user', N'dbo', N'table',
	N'SICORE_ENCUESTA_REPORTE', NULL, NULL
go

drop table if exists SICORE_ENCUESTA;
create table SICORE_ENCUESTA (
	idEncuesta bigint identity(1,1) not null
		constraint PK_SICORE_ENCUESTA_idEncuesta primary key,
	idPregunta bigint not null,
	fechaInsertoAuditoria datetime null,
	idUsuarioInsertoAuditoria bigint null,
	fechaModificoAuditoria datetime null,
	idUsuarioModificoAuditoria bigint null
)
go

exec sp_addextendedproperty
	N'MS_Description',
	'Tabla que almacena	las encuestas para que sean enviadas.',
	N'user', N'dbo', N'table',
	N'SICORE_ENCUESTA', NULL, NULL
go

drop table if exists SICORE_ENCUESTA_TRAZA;
create table SICORE_ENCUESTA_TRAZA (
	idTrazaEncuesta bigint identity(1,1) not null
		constraint PK_SICORE_ENCUESTA_TRAZA_idTrazaEncuesta primary key,
	idCliente bigint not null,
	idCertificado bigint not null,
	idFuncionario bigint not null,
	fechaHoraEnvio datetime not null,
	fechaHoraRespuesta datetime null,
	conteoEnvios int not null
)
go

exec sp_addextendedproperty
	N'MS_Description',
	'Tabla que almacena	a quien se le envío una encuesta.',
	N'user', N'dbo', N'table',
	N'SICORE_ENCUESTA_TRAZA', NULL, NULL
go

-- =========================================================================================== --
-- =============== última etapa ================================ --

drop table if exists SICORE_EXPEDIENTE;
create table SICORE_EXPEDIENTE (
	idExpediente bigint identity (1,1) not null
		constraint PK_EXPEDIENTE_idExpediente primary key,
	idProyecto bigint null,
	idCotizacion bigint null,
	idFormalizacion bigint null,
	idCertificado bigint null,
	nombreArchivo varchar(250) not null,
	rutaFisicaArchivo nvarchar(max) not null,
	fechaGeneracion datetime not null,
	fechaInsertoAuditoria datetime null,
	idUsuarioInsertoAuditoria bigint null,
	fechaModificoAuditoria datetime null,
	idUsuarioModificoAuditoria bigint null
)
go

exec sp_addextendedproperty
	N'MS_Description',
	'Tabla que almacena la información referente al expediente de sicore en general.',
	N'user', N'dbo', N'table',
	N'SICORE_EXPEDIENTE', NULL, NULL
go

drop table if exists SICORE_COTIZACION_TRAZABILIDAD;
create table SICORE_COTIZACION_TRAZABILIDAD (
	idTrazabilidadCotizacion bigint identity(1,1) not null,
	idFuncionario bigint not null,
	idCliente bigint not null,
	idCotizacion bigint not null,
	fechaHora datetime not null
)
go

exec sp_addextendedproperty
	N'MS_Description',
	'Tabla que almacena una traza de las cotizaciones enviadas.',
	N'user', N'dbo', N'table',
	N'SICORE_COTIZACION_TRAZABILIDAD', NULL, NULL
go

drop table if exists SICORE_COTIZACION_AGRUPACION;
create table SICORE_COTIZACION_AGRUPACION (
	idAgrupacion bigint identity (1,1) not null,
	idCotizacion bigint not null,
	idCliente bigint not null,
	consecutivo int not null,
	idFuncionario bigint not null,
	fechaHora datetime not null,
	indicadorEstado char(1) not null,
	justificacionAprobacion nvarchar(max) not null,
	fechaInsertoAuditoria datetime null, --fecha_actual.
	idUsuarioInsertoAuditoria bigint null, --el que está logueado.
	fechaModificoAuditoria datetime null, --fecha de la actualización.
	idUsuarioModificoAuditoria bigint null --usuario que modifica.
)
go

exec sp_addextendedproperty
	N'MS_Description',
	'Tabla que almacena una agrupación de cotizaciones para generar una única formalización y un certificado.',
	N'user', N'dbo', N'table',
	N'SICORE_COTIZACION_AGRUPACION', NULL, NULL
go

-- =========================================================================================== --
-- =========================================================================================== --
