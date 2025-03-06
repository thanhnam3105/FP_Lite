SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tr_sap_jisseki_nonyu_denso](
	[kbn_denso_SAP] [smallint] NOT NULL,
	[no_nonyu] [varchar](10) NOT NULL,
	[no_niuke] [varchar](12) NOT NULL,
	[cd_kojo] [varchar](13) NULL,
	[cd_niuke_basho] [varchar](10) NULL,
	[dt_nonyu] [decimal](8, 0) NULL,
	[cd_hinmei] [varchar](14) NULL,
	[su_nonyu_jitsu] [decimal](10, 3) NOT NULL,
	[cd_torihiki] [varchar](13) NULL,
	[cd_tani_nonyu] [varchar](10) NULL,
	[kbn_nyuko] [smallint] NULL,
	[flg_kakutei] [smallint] NOT NULL,
	[no_nohinsho] [nvarchar](16) NULL,
	[no_zeikan_shorui] [nvarchar](16) NULL,
 CONSTRAINT [PK_tr_sap_jisseki_nonyu_denso] PRIMARY KEY CLUSTERED 
(
	[kbn_denso_SAP] ASC,
	[no_nonyu] ASC,
	[no_niuke] ASC,
	[su_nonyu_jitsu] ASC,
	[flg_kakutei] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
