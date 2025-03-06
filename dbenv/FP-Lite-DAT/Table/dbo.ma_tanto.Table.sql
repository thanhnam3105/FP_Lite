SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ma_tanto](
	[cd_tanto] [varchar](10) NOT NULL,
	[nm_tanto] [nvarchar](50) NOT NULL,
	[nm_shozoku] [nvarchar](20) NOT NULL,
	[nm_renrakusaki] [varchar](14) NOT NULL,
	[e_mail] [varchar](50) NOT NULL,
	[flg_mrp] [smallint] NOT NULL,
	[flg_mishiyo] [smallint] NOT NULL,
	[dt_create] [datetime] NOT NULL,
	[cd_create] [varchar](10) NOT NULL,
	[dt_update] [datetime] NOT NULL,
	[cd_update] [varchar](10) NOT NULL,
	[cd_shokuba] [varchar](10) NULL,
	[ts] [timestamp] NOT NULL,
	[flg_kyosei_hoshin] [smallint] NULL,
	[kbn_ma_hinmei] [smallint] NULL,
	[kbn_ma_haigo] [smallint] NULL,
	[kbn_ma_konyusaki] [smallint] NULL,
	[kbn_shikomi_chohyo] [smallint] NULL
 CONSTRAINT [PK_ma_tanto] PRIMARY KEY CLUSTERED 
(
	[cd_tanto] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
