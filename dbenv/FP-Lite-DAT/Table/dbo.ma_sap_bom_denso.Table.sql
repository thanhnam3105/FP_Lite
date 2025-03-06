SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ma_sap_bom_denso](
	[kbn_denso_SAP] [smallint] NOT NULL,
	[cd_seihin] [varchar](14) NOT NULL,
	[cd_kojo] [varchar](13) NOT NULL,
	[dt_from] [decimal](8, 0) NULL,
	[su_kihon] [decimal](6, 0) NULL,
	[cd_hinmei] [varchar](14) NOT NULL,
	[su_hinmoku] [decimal](12, 6) NULL,
	[cd_tani] [varchar](10) NULL,
	[su_kaiso] [varchar](2) NOT NULL,
	[cd_haigo] [varchar](14) NOT NULL,
	[no_kotei] [varchar](4) NOT NULL,
	[no_tonyu] [varchar](30) NOT NULL,
 CONSTRAINT [PK_ma_sap_bom_denso] PRIMARY KEY CLUSTERED 
(
	[kbn_denso_SAP] ASC,
	[cd_seihin] ASC,
	[cd_hinmei] ASC,
	[su_kaiso] ASC,
	[cd_haigo] ASC,
	[no_kotei] ASC,
	[no_tonyu] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
