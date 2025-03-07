SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tr_keikaku_shikakari](
	[data_key] [varchar](14) NOT NULL,
	[dt_seizo] [datetime] NOT NULL,
	[dt_hitsuyo] [datetime] NULL,
	[no_lot_seihin] [varchar](14) NULL,
	[no_lot_shikakari] [varchar](14) NOT NULL,
	[no_lot_shikakari_oya] [varchar](14) NULL,
	[cd_shokuba] [varchar](10) NOT NULL,
	[cd_line] [varchar](10) NOT NULL,
	[cd_shikakari_hin] [varchar](14) NOT NULL,
	[wt_shikomi_keikaku] [decimal](12, 6) NULL,
	[wt_shikomi_jisseki] [decimal](12, 6) NULL,
	[su_kaiso_shikomi] [decimal](4, 0) NULL,
	[dt_update] [datetime] NOT NULL,
	[wt_haigo_keikaku] [decimal](12, 6) NULL,
	[wt_haigo_jisseki] [decimal](12, 6) NULL,
	[su_batch_yotei] [decimal](12, 6) NULL,
	[su_batch_jisseki] [decimal](12, 6) NULL,
	[ritsu_bai] [decimal](12, 6) NULL,
	[cd_hinmei] [varchar](14) NULL,
	[wt_hitsuyo] [decimal](12, 6) NULL,
	[data_key_oya] [varchar](14) NULL,
 CONSTRAINT [PK_tr_keikaku_shikakari] PRIMARY KEY CLUSTERED 
(
	[data_key] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
