SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tr_sap_chosei_zaiko_denso_taisho](
	[no_seq] [varchar](14) NOT NULL,
	[cd_hinmei] [varchar](14) NOT NULL,
	[dt_hizuke] [datetime] NULL,
	[cd_riyu] [varchar](10) NOT NULL,
	[su_chosei] [decimal](10, 3) NOT NULL,
	[dt_update] [datetime] NOT NULL,
	[cd_update] [varchar](10) NOT NULL,
	[cd_genka_center] [varchar](10) NULL,
	[cd_soko] [varchar](10) NULL,
	[cd_torihiki] [varchar](13) NULL,
	[biko] [nvarchar](100) NULL,
	[no_nohinsho] [nvarchar](16) NULL,
 CONSTRAINT [PK_tr_sap_chosei_zaiko_denso_taisho] PRIMARY KEY CLUSTERED 
(
	[no_seq] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
