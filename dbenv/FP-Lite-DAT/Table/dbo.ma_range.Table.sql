SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ma_range](
	[no_seq] [varchar](14) NOT NULL,
	[cd_hakari] [varchar](10) NOT NULL,
	[wt_hani_shiyo_kagen] [decimal](12, 6) NOT NULL,
	[wt_hani_shiyo_jogen] [decimal](12, 6) NOT NULL,
	[wt_hani_tekio_kagen] [decimal](12, 6) NOT NULL,
	[wt_hani_tekio_jogen] [decimal](12, 6) NOT NULL,
	[kbn_kasan_jyuryo] [smallint] NOT NULL,
	[dt_create] [datetime] NOT NULL,
	[cd_create] [varchar](10) NOT NULL,
	[dt_update] [datetime] NOT NULL,
	[cd_update] [varchar](10) NOT NULL,
	[flg_mishiyo] [smallint] NOT NULL,
	[ts] [timestamp] NOT NULL,
 CONSTRAINT [PK_ma_range] PRIMARY KEY CLUSTERED 
(
	[no_seq] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
