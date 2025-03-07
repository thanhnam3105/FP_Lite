SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ma_haigo_mei](
	[cd_haigo] [varchar](14) NOT NULL,
	[nm_haigo_ja] [nvarchar](50) NULL,
	[nm_haigo_en] [nvarchar](50) NULL,
	[nm_haigo_zh] [nvarchar](50) NULL,
	[nm_haigo_vi] [nvarchar](50) NULL,
	[nm_haigo_ryaku] [nvarchar](50) NULL,
	[ritsu_budomari] [decimal](5, 2) NULL,
	[wt_kihon] [decimal](4, 0) NOT NULL,
	[ritsu_kihon] [decimal](5, 2) NULL,
	[flg_gassan_shikomi] [smallint] NOT NULL,
	[wt_saidai_shikomi] [decimal](12, 6) NULL,
	[no_han] [decimal](4, 0) NOT NULL,
	[wt_haigo] [decimal](12, 6) NOT NULL,
	[wt_haigo_gokei] [decimal](12, 6) NULL,
	[biko] [nvarchar](200) NULL,
	[no_seiho] [varchar](20) NULL,
	[cd_tanto_seizo] [varchar](10) NULL,
	[dt_seizo_koshin] [datetime] NULL,
	[cd_tanto_hinkan] [varchar](10) NULL,
	[dt_hinkan_koshin] [datetime] NULL,
	[dt_from] [datetime] NOT NULL,
	[kbn_kanzan] [varchar](10) NOT NULL,
	[ritsu_hiju] [decimal](6, 4) NULL,
	[flg_shorihin] [smallint] NOT NULL,
	[flg_tanto_hinkan] [smallint] NOT NULL,
	[flg_tanto_seizo] [smallint] NOT NULL,
	[kbn_shiagari] [smallint] NOT NULL,
	[cd_bunrui] [varchar](10) NULL,
	[flg_mishiyo] [smallint] NOT NULL,
	[dt_create] [datetime] NOT NULL,
	[cd_create] [varchar](10) NOT NULL,
	[dt_update] [datetime] NOT NULL,
	[cd_update] [varchar](10) NOT NULL,
	[wt_kowake] [decimal](12, 6) NULL,
	[su_kowake] [decimal](4, 0) NULL,
	[ts] [timestamp] NOT NULL,
	[flg_tenkai] [smallint] NULL,
	[dd_shomi] [decimal](4, 0) NULL,
	[kbn_hokan] [varchar](10) NULL,
 CONSTRAINT [PK_ma_haigo_mei] PRIMARY KEY CLUSTERED 
(
	[cd_haigo] ASC,
	[no_han] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
