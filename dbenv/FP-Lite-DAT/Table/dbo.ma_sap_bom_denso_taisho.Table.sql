SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ma_sap_bom_denso_taisho](
	[cd_seihin] [varchar](14) NOT NULL,
	[no_han] [decimal](4, 0) NOT NULL,
	[cd_kojo] [varchar](10) NOT NULL,
	[dt_from] [datetime] NOT NULL,
	[su_kihon] [decimal](4, 0) NOT NULL,
	[cd_hinmei] [varchar](14) NOT NULL,
	[su_hinmoku] [decimal](12, 6) NULL,
	[cd_tani] [varchar](10) NOT NULL,
	[su_kaiso] [smallint] NOT NULL,
	[cd_haigo] [varchar](14) NOT NULL,
	[no_kotei] [decimal](4, 0) NOT NULL,
	[no_tonyu] [varchar](30) NOT NULL,
	[flg_mishiyo] [smallint] NOT NULL,
 CONSTRAINT [PK_ma_sap_bom_denso_taisho] PRIMARY KEY CLUSTERED 
(
	[cd_seihin] ASC,
	[no_han] ASC,
	[cd_hinmei] ASC,
	[su_kaiso] ASC,
	[cd_haigo] ASC,
	[no_kotei] ASC,
	[no_tonyu] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
