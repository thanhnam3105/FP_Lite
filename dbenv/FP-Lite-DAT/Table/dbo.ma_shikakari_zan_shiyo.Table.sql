SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ma_shikakari_zan_shiyo](
	[cd_hinmei] [varchar](14) NOT NULL,
	[no_juni_hyoji] [smallint] NOT NULL,
	[cd_seihin] [varchar](14) NOT NULL,
	[flg_mishiyo] [smallint] NOT NULL,
	[dt_create] [datetime] NOT NULL,
	[cd_create] [varchar](10) NOT NULL,
	[dt_update] [datetime] NOT NULL,
	[cd_update] [varchar](10) NOT NULL,
	[ts] [timestamp] NOT NULL,
 CONSTRAINT [PK_ma_shikakari_zan_shiyo] PRIMARY KEY CLUSTERED 
(
	[cd_hinmei] ASC,
	[no_juni_hyoji] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
