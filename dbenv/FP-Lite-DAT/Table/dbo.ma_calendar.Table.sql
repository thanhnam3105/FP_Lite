SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ma_calendar](
	[yy_nendo] [decimal](4, 0) NOT NULL,
	[dt_hizuke] [datetime] NOT NULL,
	[flg_kyujitsu] [smallint] NOT NULL,
	[flg_shukujitsu] [smallint] NOT NULL,
	[dt_create] [datetime] NOT NULL,
	[cd_create] [varchar](10) NOT NULL,
	[dt_update] [datetime] NOT NULL,
	[cd_update] [varchar](10) NOT NULL,
	[ts] [timestamp] NOT NULL,
 CONSTRAINT [PK_ma_calendar] PRIMARY KEY CLUSTERED 
(
	[dt_hizuke] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
