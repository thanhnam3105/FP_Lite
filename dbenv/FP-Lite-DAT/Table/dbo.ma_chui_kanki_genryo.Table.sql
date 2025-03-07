SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ma_chui_kanki_genryo](
	[kbn_hin] [smallint] NOT NULL,
	[cd_hinmei] [varchar](14) NOT NULL,
	[kbn_chui_kanki] [smallint] NOT NULL,
	[cd_chui_kanki] [varchar](10) NOT NULL,
	[no_juni_yusen] [smallint] NULL,
	[flg_chui_kanki_hyoji] [smallint] NULL,
	[flg_mishiyo] [smallint] NULL,
	[dt_create] [datetime] NULL,
	[cd_create] [varchar](10) NULL,
	[dt_update] [datetime] NULL,
	[cd_update] [varchar](10) NOT NULL,
	[ts] [timestamp] NOT NULL,
 CONSTRAINT [PK_ma_chui_kanki_genryo] PRIMARY KEY CLUSTERED 
(
	[kbn_hin] ASC,
	[cd_hinmei] ASC,
	[kbn_chui_kanki] ASC,
	[cd_chui_kanki] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
