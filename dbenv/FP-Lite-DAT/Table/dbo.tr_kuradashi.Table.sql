SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tr_kuradashi](
	[dt_hizuke] [datetime] NOT NULL,
	[cd_hinmei] [varchar](14) NOT NULL,
	[wt_shiyo_zan] [decimal](12, 6) NOT NULL,
	[dt_shukko] [datetime] NOT NULL,
	[su_kuradashi] [decimal](7, 0) NULL,
	[flg_kakutei] [smallint] NOT NULL,
	[kbn_status] [smallint] NOT NULL,
	[dt_create] [datetime] NOT NULL,
	[cd_create] [varchar](10) NOT NULL,
	[dt_update] [datetime] NOT NULL,
	[cd_update] [varchar](10) NOT NULL,
	[su_kuradashi_hasu] [decimal](7, 0) NOT NULL,
 CONSTRAINT [PK_tr_kuradashi] PRIMARY KEY CLUSTERED 
(
	[dt_hizuke] ASC,
	[cd_hinmei] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
