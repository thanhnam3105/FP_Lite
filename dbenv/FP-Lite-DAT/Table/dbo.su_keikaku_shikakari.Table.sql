SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[su_keikaku_shikakari](
	[dt_seizo] [datetime] NOT NULL,
	[cd_shikakari_hin] [varchar](14) NOT NULL,
	[cd_shokuba] [varchar](10) NOT NULL,
	[cd_line] [varchar](10) NOT NULL,
	[wt_hitsuyo] [decimal](12, 6) NULL,
	[wt_shikomi_keikaku] [decimal](12, 6) NULL,
	[wt_shikomi_jisseki] [decimal](12, 6) NULL,
	[wt_zaiko_keikaku] [decimal](12, 6) NULL,
	[wt_zaiko_jisseki] [decimal](12, 6) NULL,
	[wt_shikomi_zan] [decimal](12, 6) NULL,
	[wt_haigo_keikaku] [decimal](12, 6) NULL,
	[wt_haigo_keikaku_hasu] [decimal](12, 6) NULL,
	[su_batch_keikaku] [decimal](12, 6) NULL,
	[su_batch_keikaku_hasu] [decimal](12, 6) NULL,
	[ritsu_keikaku] [decimal](12, 6) NULL,
	[ritsu_keikaku_hasu] [decimal](12, 6) NULL,
	[wt_haigo_jisseki] [decimal](12, 6) NULL,
	[wt_haigo_jisseki_hasu] [decimal](12, 6) NULL,
	[su_batch_jisseki] [decimal](12, 6) NULL,
	[su_batch_jisseki_hasu] [decimal](12, 6) NULL,
	[ritsu_jisseki] [decimal](12, 6) NULL,
	[ritsu_jisseki_hasu] [decimal](12, 6) NULL,
	[su_label_sumi] [decimal](4, 0) NULL,
	[flg_label] [smallint] NOT NULL,
	[su_label_sumi_hasu] [decimal](4, 0) NULL,
	[flg_label_hasu] [smallint] NOT NULL,
	[flg_keikaku] [smallint] NOT NULL,
	[flg_jisseki] [smallint] NOT NULL,
	[flg_shusei] [smallint] NOT NULL,
	[no_lot_shikakari] [varchar](14) NOT NULL,
	[flg_shikomi] [smallint] NOT NULL,
 CONSTRAINT [PK_su_keikaku_shikakari] PRIMARY KEY CLUSTERED 
(
	[no_lot_shikakari] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
