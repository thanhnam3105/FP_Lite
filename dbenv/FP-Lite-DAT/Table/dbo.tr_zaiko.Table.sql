SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tr_zaiko](
	[cd_hinmei] [varchar](14) NOT NULL,
	[dt_hizuke] [datetime] NOT NULL,
	[su_zaiko] [decimal](14, 6) NULL,
	[dt_jisseki_zaiko] [datetime] NULL,
	[dt_update] [datetime] NULL,
	[cd_update] [varchar](10) NULL,
	[tan_tana] [decimal](12, 4) NULL,
	[kbn_zaiko] [smallint] NOT NULL,
	[cd_soko] [varchar](10) NOT NULL,
 CONSTRAINT [PK_tr_zaiko] PRIMARY KEY CLUSTERED 
(
	[cd_hinmei] ASC,
	[dt_hizuke] ASC,
	[kbn_zaiko] ASC,
	[cd_soko] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
