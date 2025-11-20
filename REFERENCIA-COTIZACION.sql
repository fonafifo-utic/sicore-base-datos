USE [xxxx]
GO

/****** Object:  Table [dbo].[PPSA_SOLICITUD_PAGO]    Script Date: 18/6/2024 08:52:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PPSA_SOLICITUD_PAGO](
	[idSolicitudPago] [bigint] IDENTITY(1,1) NOT NULL,
	[idPagoProgramado] [bigint] NOT NULL,
	[idContrato] [bigint] NOT NULL,
	[numeroContrato] [varchar](19) NOT NULL,
	[numeroCuota] [tinyint] NOT NULL,
	[numeroSolicitudPago] [varchar](12) NOT NULL,
	[fechaSolicitudPago] [datetime] NOT NULL,
	[haSolicitud] [decimal](17, 6) NOT NULL,
	[arbolesSolicitud] [int] NOT NULL,
	[montoSolicitud] [decimal](18, 2) NOT NULL,
	[deduccionAfectacion] [decimal](18, 2) NOT NULL,
	[deduccionImpuesto] [decimal](18, 2) NOT NULL,
	[deduccionIncumplimiento] [decimal](18, 2) NOT NULL,
	[deduccionAbonoCredito] [decimal](18, 2) NOT NULL,
	[deduccionOtraInstitucion] [decimal](18, 2) NOT NULL,
	[deduccionOtras] [decimal](18, 2) NOT NULL,
	[totalDeduccion] [decimal](18, 2) NOT NULL,
	[montoNetoSolicitud] [decimal](18, 2) NOT NULL,
	[inconsistenciaER] [char](1) NOT NULL,
	[morosoPersonJuri] [char](1) NOT NULL,
	[idEstado] [smallint] NOT NULL,
	[observacion] [varchar](250) NULL,
	[hechoPor] [varchar](30) NULL,
	[revisadoPor] [varchar](30) NULL,
	[autorizadoPor] [varchar](30) NULL,
	[idCuentaBancaria] [bigint] NULL,
	[tipoMoneda] [char](1) NULL,
	[colonesXMoneda] [decimal](18, 2) NOT NULL,
	[pdfEstudioMorosidad] [varchar](250) NULL,
	[numeroVersionAuditoria] [bigint] NOT NULL,
	[fechaInsertoAuditoria] [datetime] NOT NULL,
	[idUsuarioInsertoAuditoria] [bigint] NOT NULL,
	[fechaModificoAuditoria] [datetime] NOT NULL,
	[idUsuarioModificoAuditoria] [bigint] NOT NULL,
	[obsDevolucionDeFinanciero] [varchar](250) NULL,
	[fechaDevolucion] [datetime] NULL,
	[idPersonaDev] [bigint] NULL,
	[fechaPlantacion] [datetime] NULL,
	[idUsuarioAnulaSP] [bigint] NULL,
	[observacionAnulaSP] [varchar](200) NULL,
	[fechaAnulaSP] [datetime] NULL,
	[idListaPSAnti] [bigint] NULL,
	[obsCambioEMenFinanciero] [varchar](50) NULL,
	[montoBase] [decimal](18, 2) NOT NULL,
	[montoHidrico] [decimal](18, 2) NOT NULL,
	[montoBiodiversidad] [decimal](18, 2) NOT NULL,
 CONSTRAINT [PK_PPSA_PPSA_SOLICITUD_PAGO] PRIMARY KEY CLUSTERED 
(
	[idSolicitudPago] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[PPSA_SOLICITUD_PAGO] ADD  CONSTRAINT [DF__PPSA_SOLI__haSol__013FDF81]  DEFAULT ((0)) FOR [haSolicitud]
GO

ALTER TABLE [dbo].[PPSA_SOLICITUD_PAGO] ADD  CONSTRAINT [DF__PPSA_SOLI__arbol__023403BA]  DEFAULT ((0)) FOR [arbolesSolicitud]
GO

ALTER TABLE [dbo].[PPSA_SOLICITUD_PAGO] ADD  CONSTRAINT [DF__PPSA_SOLI__monto__032827F3]  DEFAULT ((0)) FOR [montoSolicitud]
GO

ALTER TABLE [dbo].[PPSA_SOLICITUD_PAGO] ADD  CONSTRAINT [DF__PPSA_SOLI__deduc__041C4C2C]  DEFAULT ((0)) FOR [deduccionAfectacion]
GO

ALTER TABLE [dbo].[PPSA_SOLICITUD_PAGO] ADD  CONSTRAINT [DF__PPSA_SOLI__deduc__05107065]  DEFAULT ((0)) FOR [deduccionImpuesto]
GO

ALTER TABLE [dbo].[PPSA_SOLICITUD_PAGO] ADD  CONSTRAINT [DF__PPSA_SOLI__deduc__0604949E]  DEFAULT ((0)) FOR [deduccionIncumplimiento]
GO

ALTER TABLE [dbo].[PPSA_SOLICITUD_PAGO] ADD  CONSTRAINT [DF__PPSA_SOLI__deduc__06F8B8D7]  DEFAULT ((0)) FOR [deduccionAbonoCredito]
GO

ALTER TABLE [dbo].[PPSA_SOLICITUD_PAGO] ADD  CONSTRAINT [DF__PPSA_SOLI__deduc__07ECDD10]  DEFAULT ((0)) FOR [deduccionOtraInstitucion]
GO

ALTER TABLE [dbo].[PPSA_SOLICITUD_PAGO] ADD  CONSTRAINT [DF__PPSA_SOLI__deduc__08E10149]  DEFAULT ((0)) FOR [deduccionOtras]
GO

ALTER TABLE [dbo].[PPSA_SOLICITUD_PAGO] ADD  CONSTRAINT [DF__PPSA_SOLI__total__09D52582]  DEFAULT ((0)) FOR [totalDeduccion]
GO

ALTER TABLE [dbo].[PPSA_SOLICITUD_PAGO] ADD  CONSTRAINT [DF__PPSA_SOLI__monto__0AC949BB]  DEFAULT ((0)) FOR [montoNetoSolicitud]
GO

ALTER TABLE [dbo].[PPSA_SOLICITUD_PAGO] ADD  CONSTRAINT [DF__PPSA_SOLI__incon__0BBD6DF4]  DEFAULT ('N') FOR [inconsistenciaER]
GO

ALTER TABLE [dbo].[PPSA_SOLICITUD_PAGO] ADD  CONSTRAINT [DF__PPSA_SOLI__moros__0CB1922D]  DEFAULT ('N') FOR [morosoPersonJuri]
GO

ALTER TABLE [dbo].[PPSA_SOLICITUD_PAGO] ADD  CONSTRAINT [DF__PPSA_SOLI__idEst__0DA5B666]  DEFAULT ((0)) FOR [idEstado]
GO

ALTER TABLE [dbo].[PPSA_SOLICITUD_PAGO] ADD  CONSTRAINT [DF__PPSA_SOLI__obser__0E99DA9F]  DEFAULT ('') FOR [observacion]
GO

ALTER TABLE [dbo].[PPSA_SOLICITUD_PAGO] ADD  CONSTRAINT [DF_PPSA_SOLICITUD_PAGO_idCuentaBancaria]  DEFAULT ((1)) FOR [idCuentaBancaria]
GO

ALTER TABLE [dbo].[PPSA_SOLICITUD_PAGO] ADD  CONSTRAINT [DF_PPSA_SOLICITUD_PAGO_tipoMoneda]  DEFAULT ((1)) FOR [tipoMoneda]
GO

ALTER TABLE [dbo].[PPSA_SOLICITUD_PAGO] ADD  CONSTRAINT [DF_PPSA_SOLICITUD_PAGO_colonesXMoneda]  DEFAULT ((1)) FOR [colonesXMoneda]
GO

ALTER TABLE [dbo].[PPSA_SOLICITUD_PAGO] ADD  CONSTRAINT [DF__PPSA_SOLI__numer__0F8DFED8]  DEFAULT ((0)) FOR [numeroVersionAuditoria]
GO

ALTER TABLE [dbo].[PPSA_SOLICITUD_PAGO] ADD  CONSTRAINT [DF_PPSA_SOLICITUD_PAGO_montoBase]  DEFAULT ((0)) FOR [montoBase]
GO

ALTER TABLE [dbo].[PPSA_SOLICITUD_PAGO] ADD  CONSTRAINT [DF_PPSA_SOLICITUD_PAGO_montoHidrico]  DEFAULT ((0)) FOR [montoHidrico]
GO

ALTER TABLE [dbo].[PPSA_SOLICITUD_PAGO] ADD  CONSTRAINT [DF_PPSA_SOLICITUD_PAGO_montoBiodiversidad]  DEFAULT ((0)) FOR [montoBiodiversidad]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Usuario que Inicio Session..' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PPSA_SOLICITUD_PAGO', @level2type=N'COLUMN',@level2name=N'hechoPor'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'CajaUnica, FID-544-11,..' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PPSA_SOLICITUD_PAGO', @level2type=N'COLUMN',@level2name=N'idCuentaBancaria'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 Colones, 2 Dolares' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PPSA_SOLICITUD_PAGO', @level2type=N'COLUMN',@level2name=N'tipoMoneda'
GO


