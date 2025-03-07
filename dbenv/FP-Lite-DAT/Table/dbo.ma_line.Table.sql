SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ma_line](
	[cd_line] [varchar](10) NOT NULL,
	[nm_line] [nvarchar](50) NOT NULL,
	[cd_shokuba] [varchar](10) NOT NULL,
	[flg_mishiyo] [smallint] NOT NULL,
	[dt_create] [datetime] NOT NULL,
	[cd_create] [varchar](10) NOT NULL,
	[dt_update] [datetime] NOT NULL,
	[cd_update] [varchar](10) NOT NULL,
	[ts] [timestamp] NOT NULL,
 CONSTRAINT [PK_ma_line] PRIMARY KEY CLUSTERED 
(
	[cd_line] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
