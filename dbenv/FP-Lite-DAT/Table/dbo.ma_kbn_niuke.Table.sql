SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ma_kbn_niuke](
	[kbn_niuke_basho] [varchar](10) NOT NULL,
	[nm_kbn_niuke] [nvarchar](100) NOT NULL,
	[flg_niuke] [smallint] NOT NULL,
	[flg_henpin] [smallint] NOT NULL,
	[flg_shukko] [smallint] NOT NULL,
	[flg_mishiyo] [smallint] NOT NULL,
	[dt_create] [datetime] NOT NULL,
	[cd_create] [varchar](10) NOT NULL,
	[dt_update] [datetime] NOT NULL,
	[cd_update] [varchar](10) NOT NULL,
	[ts] [timestamp] NOT NULL,
 CONSTRAINT [PK_ma_kbn_niuke] PRIMARY KEY CLUSTERED 
(
	[kbn_niuke_basho] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
