SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ma_chui_kanki](
	[kbn_chui_kanki] [smallint] NOT NULL,
	[cd_chui_kanki] [varchar](10) NOT NULL,
	[nm_chui_kanki] [nvarchar](50) NOT NULL,
	[flg_mishiyo] [smallint] NOT NULL,
	[dt_create] [datetime] NOT NULL,
	[cd_create] [varchar](10) NOT NULL,
	[dt_update] [datetime] NOT NULL,
	[cd_update] [varchar](10) NOT NULL,
	[ts] [timestamp] NOT NULL,
 CONSTRAINT [PK_ma_chui_kanki] PRIMARY KEY CLUSTERED 
(
	[kbn_chui_kanki] ASC,
	[cd_chui_kanki] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
