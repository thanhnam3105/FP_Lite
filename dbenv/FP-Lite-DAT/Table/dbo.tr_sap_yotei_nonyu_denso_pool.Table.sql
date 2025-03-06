SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tr_sap_yotei_nonyu_denso_pool](
	[kbn_denso_SAP] [smallint] NOT NULL,
	[no_nonyu] [varchar](10) NOT NULL,
	[cd_kojo] [varchar](13) NULL,
	[dt_nonyu] [decimal](8, 0) NULL,
	[cd_hinmei] [varchar](14) NOT NULL,
	[su_nonyu] [decimal](10, 3) NULL,
	[cd_torihiki] [varchar](13) NOT NULL,
	[cd_tani_SAP] [varchar](10) NULL,
	[kbn_nyuko] [smallint] NULL,
	[dt_denso] [datetime] NOT NULL,
 CONSTRAINT [PK_tr_sap_yotei_nonyu_denso_pool] PRIMARY KEY CLUSTERED 
(
	[kbn_denso_SAP] ASC,
	[no_nonyu] ASC,
	[dt_denso] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
