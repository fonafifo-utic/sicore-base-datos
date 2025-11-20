--=================================================--

drop table if exists SICORE_PERFIL_POR_USUARIO;
create table dbo.SICORE_PERFIL_POR_USUARIO (
	idPerfilUsuario bigint identity(1,1) not null,
	idPerfil bigint not null,
	idUsuario bigint not null
)
go

exec sp_addextendedproperty
	N'MS_Description',
	'Tabla que almacena los perfiles por usuario.',
	N'user', N'dbo', N'table',
	N'SICORE_PERFIL_POR_USUARIO', NULL, NULL
go

drop table if exists SICORE_LOG_REGISTRO_INGRESO;
create table [dbo].[SICORE_LOG_REGISTRO_INGRESO](
	[idLog] [bigint] IDENTITY(1,1) NOT NULL,
	[idUsuario] [bigint] NOT NULL,
	[fechayHora] [datetime] NOT NULL
)
GO

exec sp_addextendedproperty
	N'MS_Description',
	'Tabla que almacena un registro cada vez que un usuario ingresa al sistema.',
	N'user', N'dbo', N'table',
	N'SICORE_LOG_REGISTRO_INGRESO', NULL, NULL
go

drop table if exists SICORE_HISTO_CLAVES;
create table [dbo].[SICORE_HISTO_CLAVES](
	[idUsuario] [bigint] NULL,
	[fechaClave] [date] NULL,
	[clave] [varchar](20) NULL,
	[fechaRegistro] [datetime] NULL
)
GO

exec sp_addextendedproperty
	N'MS_Description',
	'Tabla que almacena las claves del sistema para control histórico.',
	N'user', N'dbo', N'table',
	N'SICORE_HISTO_CLAVES', NULL, NULL
go

drop table if exists SICORE_TRAZABILIDAD;
create table [dbo].[SICORE_TRAZABILIDAD](
	idTraza bigint identity(1,1) not null
		constraint PK_TRAZABILIDAD_idTraza primary key,
	idUsuario bigint not null,
	modulo varchar(255) not null,
	operacion varchar(255) not null,
	fechaTraza datetime not null
)
go

exec sp_addextendedproperty
	N'MS_Description',
	'Tabla que lleva la traza de lo que hace el usuario en sistema.',
	N'user', N'dbo', N'table',
	N'SICORE_TRAZABILIDAD', NULL, NULL
go


drop table if exists SICORE_LINEAS_FORMALIZACION;
create table SICORE_LINEAS_FORMALIZACION (
	idLineaFactura bigint identity(1,1) not null
		constraint PK_LINEAS_FORMALIZACION_idLineaFormalizacion primary key,
	idFactura bigint not null
		constraint FK_LINEA_FORMALIZACION_idFormalizacion foreign key
			references SICORE_FORMALIZACION (idFormalizacion),
	cantidad decimal(18,2) not null,
	descripcion varchar(150) not null,
	precioUnitario decimal(18,2) not null,
	subTotal decimal(18,2) not null,
	fechaInsertoAuditoria datetime null,
	idUsuarioInsertoAuditoria bigint null,
	fechaModificoAuditoria datetime null,
	idUsuarioModificoAuditoria bigint null
)
go

exec sp_addextendedproperty
	N'MS_Description',
	'Tabla que almacena las líneas de las facturas emitidas.',
	N'user', N'dbo', N'table',
	N'SICORE_LINEAS_FORMALIZACION', NULL, NULL
go

--=================================================--