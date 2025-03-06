SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tr_sap_torihiki_jushin_pool](
	[kbn_denso_SAP] [smallint] NOT NULL,
	[kbn_torihiki] [smallint] NOT NULL,
	[nm_torihiki] [nvarchar](50) NOT NULL,
	[cd_torihiki] [varchar](13) NOT NULL,
	[nm_torihiki_ryaku] [nvarchar](50) NULL,
	[no_yubin] [varchar](10) NULL,
	[nm_jusho] [nvarchar](100) NULL,
	[no_tel] [varchar](20) NULL,
	[no_fax] [varchar](20) NULL,
	[e_mail] [varchar](50) NULL,
	[flg_mishiyo] [smallint] NOT NULL,
	[dt_jushin] [datetime] NOT NULL,
	[dt_create] [datetime] NOT NULL,
 CONSTRAINT [PK_tr_sap_torihiki_jushin_pool] PRIMARY KEY CLUSTERED 
(
	[kbn_denso_SAP] ASC,
	[cd_torihiki] ASC,
	[dt_jushin] ASC,
	[dt_create] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
