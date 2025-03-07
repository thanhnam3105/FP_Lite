SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ma_haigo_recipe](
	[no_seq] [bigint] IDENTITY(1,1) NOT NULL,
	[cd_haigo] [varchar](14) NOT NULL,
	[no_han] [decimal](4, 0) NOT NULL,
	[wt_haigo] [decimal](12, 6) NOT NULL,
	[no_kotei] [decimal](4, 0) NOT NULL,
	[no_tonyu] [decimal](4, 0) NOT NULL,
	[kbn_hin] [smallint] NOT NULL,
	[cd_hinmei] [varchar](14) NOT NULL,
	[nm_hinmei] [nvarchar](50) NOT NULL,
	[cd_mark] [varchar](2) NULL,
	[wt_kihon] [decimal](4, 0) NULL,
	[wt_shikomi] [decimal](12, 6) NULL,
	[wt_nisugata] [decimal](12, 6) NULL,
	[su_nisugata] [decimal](4, 0) NULL,
	[wt_kowake] [decimal](12, 6) NULL,
	[su_kowake] [decimal](4, 0) NULL,
	[cd_futai] [varchar](10) NULL,
	[ritsu_hiju] [decimal](6, 4) NULL,
	[ritsu_budomari] [decimal](5, 2) NULL,
	[dt_create] [datetime] NOT NULL,
	[cd_create] [varchar](10) NOT NULL,
	[dt_update] [datetime] NOT NULL,
	[cd_update] [varchar](10) NOT NULL,
	[su_settei] [decimal](8, 3) NULL,
	[su_settei_max] [decimal](8, 3) NULL,
	[su_settei_min] [decimal](8, 3) NULL,
	[ts] [timestamp] NOT NULL,
	[flg_kowake_systemgai] [smallint] NULL,
	[no_plc_komoku] [smallint] NULL,
 CONSTRAINT [PK_ma_haigo_recipe_1] PRIMARY KEY CLUSTERED 
(
	[no_seq] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
