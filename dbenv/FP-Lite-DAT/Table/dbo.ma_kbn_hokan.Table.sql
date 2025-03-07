SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ma_kbn_hokan](
	[cd_hokan_kbn] [varchar](10) NOT NULL,
	[nm_hokan_kbn] [nvarchar](50) NOT NULL,
	[flg_mishiyo] [smallint] NOT NULL,
	[dt_create] [datetime] NOT NULL,
	[cd_create] [varchar](10) NOT NULL,
	[dt_update] [datetime] NOT NULL,
	[cd_update] [varchar](10) NOT NULL,
	[ts] [timestamp] NULL,
 CONSTRAINT [PK_ma_kbn_hokan] PRIMARY KEY CLUSTERED 
(
	[cd_hokan_kbn] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
