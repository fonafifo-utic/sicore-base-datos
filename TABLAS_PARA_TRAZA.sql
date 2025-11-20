USE SCGI_TRAZA
GO

drop table if exists SICORE_USUARIO
create table SICORE_USUARIO (
	idUsuarioInterno bigint not null,
	idUsuario  bigint not null,
	idPerfil bigint not null
)
go


drop table if exists SICORE_PERFIL
create table SICORE_PERFIL (
	idPerfil bigint NOT NULL,
	nombre varchar(150) NOT NULL,
	descripcion varchar(250) NULL
)
go

drop table if exists SICORE_PROYECTO
create table SICORE_PROYECTO (
	idProyecto bigint not null,
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

drop table if exists SICORE_INVENTARIO;
create table SICORE_INVENTARIO (
	idInventario bigint not null, 
	idProyecto bigint not null,
	remanente decimal(18,2) not null,
	vendido decimal(18,2) not null,
 	comprometido decimal(18,2) not null,
	periodo int not null,
	fechaInsertoAuditoria datetime null,
	idUsuarioInsertoAuditoria bigint null,
	fechaModificoAuditoria datetime null,
	idUsuarioModificoAuditoria bigint null
)
go

drop table if exists SICORE_MOVIMIENTO_INVENTARIO;
create table SICORE_MOVIMIENTO_INVENTARIO (
	idMovimiento bigint not null,
	idProyecto bigint not null,
	idUsuario bigint not null,
	fechaMovimiento datetime not null,
	cantidad decimal(18,2) not null,
	descripcionMovimiento nvarchar(max) not null,
	tipoMovimiento char(1) not null,
 	remanenteVirtual decimal(18,2) not null,
	remanenteReal decimal(18,2) not null,
	fechaInsertoAuditoria datetime null,
	idUsuarioInsertoAuditoria bigint null,
	fechaModificoAuditoria datetime null,
	idUsuarioModificoAuditoria bigint null
)
go

drop table if exists SICORE_CLIENTE;
create table SICORE_CLIENTE (
	idCliente bigint not null,
	idSector bigint not null,
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
	idAgenteCuenta bigint null.
	ucii VARCHAR(10) NULL
)
go

drop table if exists SICORE_COTIZACION;
create table SICORE_COTIZACION (
	idCotizacion bigint not null,
	idCliente bigint not null,
	idFuncionario bigint not null,
	idProyecto bigint not null,
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
	fechaInsertoAuditoria datetime null,
	idUsuarioInsertoAuditoria bigint null,
	fechaModificoAuditoria datetime null,
	idUsuarioModificoAuditoria bigint null,
	cuentaConvenio char(1) not null,
	cotizacionEnIngles bit not null,
	cotizacionEnviada bit not null,
	tipoCompra varchar(100) not null,
	justificacionCompra varchar(100) not null,
	observacionDeAprobacion nvarchar(max) not null
)
go

drop table if exists SICORE_FORMALIZACION;
create table SICORE_FORMALIZACION (
	idFormalizacion bigint not null,
	idCotizacion bigint not null,
	idFuncionario bigint not null,
	fechaHora datetime not null,
	montoDolares decimal (18,2) not null,
	montoColones decimal (18,2) not null,
	consecutivo int not null,
	numeroFacturaFonafifo varchar(100) not null,
	numeroTransferencia varchar(100) not null,
	justificacionCompra varchar(255) not null,
	creditoDebito char(1) not null,
	indicadorEstado char(1) not null,
	tieneFacturas char(1) not null,
	fechaHoraFormalizacion datetime not null,
	fechaInsertoAuditoria datetime null,
	idUsuarioInsertoAuditoria bigint null,
	fechaModificoAuditoria datetime null,
	idUsuarioModificoAuditoria bigint null,
	numeroComprobante varchar(100) not null,
	vistoBuenoJefatura char(1) null,
	justificacionActivacion nvarchar(max) null,
	numeroCIIU VARCHAR(50) NOT NULL
)
go

drop table if exists SICORE_CERTIFICADO;
create table SICORE_CERTIFICADO (
	idCertificado bigint not null,
	idFormalizacion bigint not null,
	idCotizacion bigint not null,
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
	observaciones nvarchar(max) not null,
	numeroIdentificacionInterno varchar(150) null,
	indicadorEstado char(1) null,
	cssCertificado nvarchar(max) null.
	enIngles char(1) null
)
go

drop table if exists SICORE_PERSONALIZACION;
create table SICORE_PERSONALIZACION (
	idPersonalizacion bigint not null,
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
