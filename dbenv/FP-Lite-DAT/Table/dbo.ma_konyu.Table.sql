SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ma_konyu](
	[cd_hinmei] [varchar](14) NOT NULL,
	[no_juni_yusen] [smallint] NOT NULL,
	[cd_torihiki] [varchar](13) NOT NULL,
	[cd_torihiki2] [varchar](13) NULL,
	[nm_nisugata_hyoji] [nvarchar](50) NULL,
	[cd_tani_nonyu] [varchar](10) NOT NULL,
	[tan_nonyu] [decimal](12, 4) NOT NULL,
	[wt_nonyu] [decimal](12, 6) NOT NULL,
	[su_iri] [decimal](5, 0) NOT NULL,
	[su_leadtime] [decimal](3, 0) NOT NULL,
	[su_hachu_lot_size] [decimal](7, 2) NULL,
	[tan_nonyu_new] [decimal](12, 4) NULL,
	[dt_tanka_new] [datetime] NULL,
	[flg_mishiyo] [smallint] NOT NULL,
	[dt_create] [datetime] NOT NULL,
	[cd_create] [varchar](10) NOT NULL,
	[dt_update] [datetime] NOT NULL,
	[cd_update] [varchar](10) NOT NULL,
	[ts] [timestamp] NOT NULL,
	[cd_tani_nonyu_hasu] [varchar](10) NULL,
 CONSTRAINT [PK_ma_konyu] PRIMARY KEY CLUSTERED 
(
	[cd_hinmei] ASC,
	[no_juni_yusen] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
