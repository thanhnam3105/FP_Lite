SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tr_sap_chosei_zaiko_denso_pool](
	[kbn_denso_SAP] [smallint] NOT NULL,
	[no_seq] [varchar](14) NOT NULL,
	[cd_hinmei] [varchar](14) NOT NULL,
	[cd_kojo] [varchar](13) NOT NULL,
	[cd_soko] [varchar](10) NULL,
	[cd_riyu] [varchar](10) NULL,
	[su_chosei] [decimal](10, 3) NOT NULL,
	[cd_tani_SAP] [varchar](10) NULL,
	[cd_genka_center] [varchar](10) NULL,
	[dt_denpyo] [decimal](8, 0) NOT NULL,
	[dt_hizuke] [decimal](8, 0) NOT NULL,
	[dt_denso] [datetime] NOT NULL,
	[kbn_ido] [varchar](2) NULL,
	[cd_torihiki] [varchar](13) NULL,
	[biko] [nvarchar](100) NULL,
	[no_nohinsho] [nvarchar](16) NULL,
 CONSTRAINT [PK_tr_sap_chosei_zaiko_denso_pool] PRIMARY KEY CLUSTERED 
(
	[kbn_denso_SAP] ASC,
	[no_seq] ASC,
	[dt_denso] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
