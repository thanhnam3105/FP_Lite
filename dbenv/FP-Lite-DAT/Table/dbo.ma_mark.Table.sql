SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ma_mark](
	[cd_mark] [varchar](2) NOT NULL,
	[nm_mark] [nvarchar](10) NOT NULL,
	[mark] [varchar](2) NOT NULL,
	[kbn_shubetsu] [varchar](2) NOT NULL,
	[cd_tani_shiyo] [varchar](10) NOT NULL,
	[flg_label] [smallint] NOT NULL,
	[flg_lot] [smallint] NOT NULL,
	[kbn_nyuryoku_haigojyuryo] [smallint] NULL,
	[kbn_nyuryoku_nisugatajyuryo] [smallint] NULL,
	[kbn_nyuryoku_nisugatasu] [smallint] NULL,
	[kbn_nyuryoku_kowakejyuryo] [smallint] NULL,
	[kbn_nyuryoku_kowakesu] [smallint] NULL,
	[kbn_nyuryoku_hiju] [smallint] NULL,
	[kbn_nyuryoku_budomari] [smallint] NULL,
	[kbn_nyuryoku_futai] [smallint] NULL,
	[dt_update] [datetime] NULL,
	[ts] [timestamp] NOT NULL,
 CONSTRAINT [PK_ma_mark] PRIMARY KEY CLUSTERED 
(
	[cd_mark] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
