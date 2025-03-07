SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tr_niuke_err](
	[bhtid] [varchar](2) NOT NULL,
	[dt_niuke] [datetime] NOT NULL,
	[tm_niuke] [varchar](5) NOT NULL,
	[no_format] [varchar](4) NOT NULL,
	[cd_hinmei_maker] [varchar](14) NOT NULL,
	[cd_hinmei] [varchar](14) NULL,
	[nm_hinmei] [nvarchar](80) NOT NULL,
	[cd_maker] [varchar](20) NOT NULL,
	[nm_maker] [nvarchar](60) NOT NULL,
	[cd_kojo] [varchar](13) NOT NULL,
	[nm_kojo] [nvarchar](60) NOT NULL,
	[nm_nisugata] [nvarchar](30) NULL,
	[nm_tani_nonyu] [nvarchar](12) NULL,
	[no_denpyo] [varchar](30) NULL,
	[no_lot] [varchar](14) NOT NULL,
	[no_location] [varchar](10) NULL,
	[su_nonyu] [varchar](7) NULL,
	[su_nonyu_hasu] [varchar](7) NULL,
	[dt_seizo] [datetime] NOT NULL,
	[dt_shomi] [datetime] NULL,
	[dt_nonyu_yotei] [datetime] NULL,
	[dt_label_hakko] [datetime] NOT NULL,
	[nm_sanchi] [nvarchar](30) NULL,
	[biko] [nvarchar](30) NULL
)
GO
