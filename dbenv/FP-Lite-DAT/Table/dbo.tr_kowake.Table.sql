SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tr_kowake](
	[no_lot_kowake] [varchar](14) NOT NULL,
	[dt_kowake] [datetime] NOT NULL,
	[cd_panel] [varchar](3) NOT NULL,
	[cd_hakari] [varchar](10) NOT NULL,
	[cd_seihin] [varchar](14) NOT NULL,
	[nm_seihin] [nvarchar](50) NOT NULL,
	[cd_hinmei] [varchar](14) NOT NULL,
	[nm_hinmei] [nvarchar](50) NOT NULL,
	[no_kotei] [decimal](4, 0) NOT NULL,
	[su_ko] [decimal](4, 0) NOT NULL,
	[su_kai] [decimal](4, 0) NOT NULL,
	[no_tonyu] [decimal](4, 0) NOT NULL,
	[wt_haigo] [decimal](12, 6) NOT NULL,
	[wt_jisseki] [decimal](12, 6) NOT NULL,
	[cd_line] [varchar](10) NOT NULL,
	[ritsu_kihon] [decimal](5, 2) NULL,
	[cd_maker] [varchar](20) NOT NULL,
	[cd_tanto_kowake] [varchar](10) NOT NULL,
	[dt_chikan] [datetime] NULL,
	[cd_tanto_chikan] [varchar](10) NULL,
	[dt_shomi] [datetime] NOT NULL,
	[dt_shomi_kaifu] [datetime] NOT NULL,
	[dt_seizo] [datetime] NOT NULL,
	[flg_kanryo_tonyu] [smallint] NULL,
	[dt_tonyu] [datetime] NULL,
	[no_lot_oya] [varchar](14) NULL,
	[no_lot_seihin] [varchar](14) NULL,
	[kbn_seikihasu] [smallint] NULL,
	[kbn_hin] [smallint] NULL,
	[kbn_kowakehasu] [smallint] NULL,
	[dt_shomi_kaito] [datetime] NULL,
 CONSTRAINT [PK_tr_kowake] PRIMARY KEY CLUSTERED 
(
	[no_lot_kowake] ASC,
	[dt_kowake] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
