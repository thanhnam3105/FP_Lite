SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tr_zan_jiseki](
	[no_lot_zan] [varchar](14) NOT NULL,
	[dt_hyoryo_zan] [datetime] NOT NULL,
	[cd_panel] [varchar](3) NOT NULL,
	[cd_hakari] [varchar](10) NOT NULL,
	[cd_hinmei] [varchar](14) NOT NULL,
	[nm_hinmei] [nvarchar](50) NOT NULL,
	[wt_jisseki] [decimal](12, 6) NOT NULL,
	[wt_jisseki_futai] [decimal](12, 6) NOT NULL,
	[cd_tanto] [varchar](10) NOT NULL,
	[dt_read] [datetime] NULL,
	[flg_mikaifu] [smallint] NOT NULL,
	[dt_kaifu] [datetime] NULL,
	[dt_kigen] [datetime] NOT NULL,
	[flg_ido] [smallint] NULL,
	[flg_haki] [smallint] NOT NULL,
	[cd_maker] [varchar](20) NULL,
	[cd_label] [text] NULL,
	[kbn_label] [smallint] NULL,
	[dt_shomi_kaito] [datetime] NULL,
 CONSTRAINT [PK_tr_zan_jiseki] PRIMARY KEY CLUSTERED 
(
	[no_lot_zan] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
