SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tr_shukko_rireki](
	[no_seq] [decimal](8, 0) NOT NULL,
	[dt_shukko] [datetime] NOT NULL,
	[no_niuke] [varchar](14) NOT NULL,
	[kbn_zaiko] [smallint] NOT NULL,
	[su_shukko] [decimal](9, 2) NOT NULL,
	[su_shukko_hasu] [decimal](9, 2) NOT NULL,
	[cd_shokuba] [varchar](10) NULL,
	[biko] [nvarchar](50) NULL,
	[dt_create] [varchar](10) NOT NULL,
	[cd_create] [varchar](10) NOT NULL,
	[cd_niuke_basho] [varchar](10) NULL,
 CONSTRAINT [PK_tr_shukko_rireki] PRIMARY KEY CLUSTERED 
(
	[no_seq] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO