SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[wk_kuradashi](
	[cd_hinmei] [varchar](14) NOT NULL,
	[su_kuradashi_all] [decimal](18, 3) NULL,
	[su_kuradashi_zan] [decimal](18, 3) NULL,
	[su_iri] [decimal](5, 0) NULL,
	[dt_shukko] [datetime] NOT NULL,
	[dt_hizuke] [datetime] NOT NULL,
	[cd_tani_nonyu] [varchar](10) NULL,
 CONSTRAINT [PK_wk_kuradashi_1] PRIMARY KEY CLUSTERED 
(
	[cd_hinmei] ASC,
	[dt_hizuke] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
