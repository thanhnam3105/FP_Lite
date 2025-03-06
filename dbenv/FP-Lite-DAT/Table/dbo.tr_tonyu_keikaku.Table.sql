SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tr_tonyu_keikaku](
	[dt_seizo] [datetime] NOT NULL,
	[cd_panel] [varchar](3) NOT NULL,
	[cd_shokuba] [varchar](10) NOT NULL,
	[cd_line] [varchar](10) NOT NULL,
	[no_kotei] [decimal](4, 0) NOT NULL,
	[no_tonyu] [decimal](4, 0) NOT NULL,
	[mark] [varchar](2) NOT NULL,
	[cd_hinmei] [varchar](14) NOT NULL,
	[nm_hinmei] [nvarchar](50) NOT NULL,
	[wt_haigo] [decimal](12, 6) NOT NULL,
	[nm_tani] [nvarchar](12) NOT NULL,
	[wt_nisugata] [decimal](12, 6) NOT NULL,
	[su_nisugata] [decimal](4, 0) NOT NULL,
	[wt_kowake] [decimal](12, 6) NOT NULL,
	[su_kowake] [decimal](4, 0) NOT NULL,
	[wt_kowake_hasu] [decimal](12, 6) NOT NULL,
	[su_kowake_hasu] [decimal](4, 0) NOT NULL,
	[hijyu] [decimal](6, 4) NOT NULL,
	[kbn_seikihasu] [smallint] NOT NULL,
	[su_settei] [decimal](8, 3) NULL,
	[su_settei_max] [decimal](8, 3) NULL,
	[su_settei_min] [decimal](8, 3) NULL,
	[cd_tani_nisugata] [varchar](10) NULL,
	[cd_tani_kowake] [varchar](10) NULL,
	[cd_tani_kowake_hasu] [varchar](10) NULL,
	[flg_kowake_systemgai] [smallint] NULL,
 CONSTRAINT [PK_tr_tonyu_keikaku] PRIMARY KEY CLUSTERED 
(
	[dt_seizo] ASC,
	[cd_panel] ASC,
	[cd_shokuba] ASC,
	[cd_line] ASC,
	[no_kotei] ASC,
	[no_tonyu] ASC,
	[kbn_seikihasu] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
