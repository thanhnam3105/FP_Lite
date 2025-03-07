SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tr_tonyu_jokyo](
	[dt_seizo] [datetime] NOT NULL,
	[cd_panel] [varchar](3) NOT NULL,
	[cd_shokuba] [varchar](10) NOT NULL,
	[cd_line] [varchar](10) NOT NULL,
	[kbn_jokyo] [smallint] NOT NULL,
	[dt_yotei_seizo] [datetime] NOT NULL,
	[no_kotei] [decimal](4, 0) NOT NULL,
	[cd_haigo] [varchar](14) NOT NULL,
	[nm_haigo] [nvarchar](50) NOT NULL,
	[su_kai] [decimal](4, 0) NOT NULL,
	[su_kai_hasu] [decimal](4, 0) NOT NULL,
	[su_yotei] [decimal](4, 0) NOT NULL,
	[su_yotei_hasu] [decimal](4, 0) NOT NULL,
	[su_ko_niuke] [decimal](4, 0) NOT NULL,
	[su_ko] [decimal](4, 0) NOT NULL,
	[su_ko_hasu] [decimal](4, 0) NOT NULL,
	[no_tonyu] [decimal](4, 0) NOT NULL,
	[no_lot] [varchar](14) NULL,
	[flg_fukusu] [smallint] NULL,
	[wt_haigo] [decimal](12, 6) NULL,
	[no_lot_seihin] [varchar](14) NULL,
	[kbn_seikihasu] [smallint] NULL,
	[flg_saikido] [smallint] NULL,
	[flg_kanryo_tonyu] [varchar](1) NULL,
 CONSTRAINT [PK_tr_tonyu_jokyo] PRIMARY KEY CLUSTERED 
(
	[cd_panel] ASC,
	[cd_shokuba] ASC,
	[cd_line] ASC,
	[no_kotei] ASC,
	[su_kai] ASC,
	[su_ko_niuke] ASC,
	[su_ko] ASC,
	[su_ko_hasu] ASC,
	[no_tonyu] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
