SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tr_sap_hinmei_jushin](
	[kbn_denso_SAP] [smallint] NOT NULL,
	[cd_hinmei] [varchar](14) NOT NULL,
	[kbn_hin] [smallint] NULL,
	[flg_mishiyo] [smallint] NULL,
	[nm_hinmei_ja] [nvarchar](50) NULL,
	[nm_hinmei_en] [nvarchar](50) NULL,
	[nm_hinmei_zh] [nvarchar](50) NULL,
	[nm_hinmei_vi] [nvarchar](50) NULL,
	[dt_jushin] [datetime] NOT NULL,
 CONSTRAINT [PK_wk_sap_hinmei_jushin_1] PRIMARY KEY CLUSTERED 
(
	[kbn_denso_SAP] ASC,
	[cd_hinmei] ASC,
	[dt_jushin] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
