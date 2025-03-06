SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tr_chosei](
	[no_seq] [varchar](14) NOT NULL,
	[cd_hinmei] [varchar](14) NOT NULL,
	[dt_hizuke] [datetime] NULL,
	[cd_riyu] [varchar](10) NOT NULL,
	[su_chosei] [decimal](12, 6) NOT NULL,
	[biko] [nvarchar](50) NULL,
	[cd_seihin] [varchar](14) NULL,
	[dt_update] [datetime] NOT NULL,
	[cd_update] [varchar](10) NOT NULL,
	[cd_genka_center] [varchar](10) NULL,
	[cd_soko] [varchar](10) NULL,
	[cd_torihiki] [varchar](13) NULL,
	[nm_henpin] [nvarchar](100) NULL,
	[no_nohinsho] [nvarchar](16) NULL,
	[no_niuke] [varchar](14) NULL,
	[kbn_zaiko] [smallint] NULL,
	[no_lot_seihin] [varchar](14) NULL,
 CONSTRAINT [PK_tr_chosei_01] PRIMARY KEY CLUSTERED 
(
	[no_seq] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
