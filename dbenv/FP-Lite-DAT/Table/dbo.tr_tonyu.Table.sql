SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tr_tonyu](
	[dt_seizo] [datetime] NOT NULL,
	[cd_shokuba] [varchar](10) NOT NULL,
	[cd_line] [varchar](10) NOT NULL,
	[cd_haigo] [varchar](14) NOT NULL,
	[cd_hinmei] [varchar](14) NOT NULL,
	[nm_hinmei] [nvarchar](50) NULL,
	[su_kai] [decimal](4, 0) NOT NULL,
	[no_tonyu] [decimal](4, 0) NOT NULL,
	[wt_haigo] [decimal](12, 6) NOT NULL,
	[wt_nisugata] [decimal](12, 6) NOT NULL,
	[su_nisugata] [decimal](4, 0) NOT NULL,
	[wt_kowake] [decimal](12, 6) NOT NULL,
	[su_kowake] [decimal](4, 0) NOT NULL,
	[wt_kowake_hasu] [decimal](12, 6) NULL,
	[su_kowake_hasu] [decimal](4, 0) NOT NULL,
	[nm_tani] [nvarchar](12) NOT NULL,
	[ritsu_hiju] [decimal](6, 4) NOT NULL,
	[nm_naiyo_jisseki] [nvarchar](53) NOT NULL,
	[dt_shori] [datetime] NULL,
	[nm_mark] [nvarchar](10) NOT NULL,
	[cd_tanto] [varchar](10) NOT NULL,
	[dt_yotei_seizo] [datetime] NOT NULL,
	[no_kotei] [decimal](4, 0) NOT NULL,
	[su_ko_label] [decimal](4, 0) NULL,
	[su_kai_label] [decimal](4, 0) NULL,
	[dt_label_hakko] [datetime] NULL,
	[no_lot] [varchar](14) NULL,
	[dt_shomi] [datetime] NULL,
	[nm_naiyo_qr] [nvarchar](300) NULL,
	[biko] [nvarchar](50) NULL,
	[kbn_kyosei] [smallint] NULL,
	[no_lot_seihin] [varchar](14) NOT NULL,
	[kbn_seikihasu] [smallint] NOT NULL,
 CONSTRAINT [PK_tr_tonyu] PRIMARY KEY CLUSTERED 
(
	[dt_seizo] ASC,
	[cd_shokuba] ASC,
	[cd_line] ASC,
	[cd_haigo] ASC,
	[cd_hinmei] ASC,
	[su_kai] ASC,
	[no_tonyu] ASC,
	[su_nisugata] ASC,
	[su_kowake] ASC,
	[su_kowake_hasu] ASC,
	[no_kotei] ASC,
	[no_lot_seihin] ASC,
	[kbn_seikihasu] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
