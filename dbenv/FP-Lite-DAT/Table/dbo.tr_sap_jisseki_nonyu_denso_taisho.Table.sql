SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tr_sap_jisseki_nonyu_denso_taisho](
	[no_nonyu] [varchar](10) NOT NULL,
	[no_niuke] [varchar](12) NOT NULL,
	[cd_kojo] [varchar](13) NOT NULL,
	[cd_niuke_basho] [varchar](10) NOT NULL,
	[dt_nonyu] [datetime] NULL,
	[cd_hinmei] [varchar](14) NOT NULL,
	[su_nonyu_jitsu] [decimal](10, 3) NULL,
	[cd_torihiki] [varchar](13) NOT NULL,
	[cd_tani_nonyu] [varchar](10) NOT NULL,
	[kbn_nyuko] [smallint] NULL,
	[flg_kakutei] [smallint] NULL,
	[no_nohinsho] [nvarchar](16) NULL,
	[no_zeikan_shorui] [nvarchar](16) NULL,
 CONSTRAINT [PK_tr_sap_jisseki_nonyu_denso_taisho] PRIMARY KEY CLUSTERED 
(
	[no_nonyu] ASC,
	[no_niuke] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
