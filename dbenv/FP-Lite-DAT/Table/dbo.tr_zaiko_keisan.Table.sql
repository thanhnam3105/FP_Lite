SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tr_zaiko_keisan](
	[cd_hinmei] [varchar](14) NOT NULL,
	[dt_hizuke] [datetime] NOT NULL,
	[su_zaiko] [decimal](14, 6) NULL,
	[dt_update] [datetime] NULL,
	[cd_update] [varchar](10) NULL,
 CONSTRAINT [PK_tr_zaiko_keisan] PRIMARY KEY CLUSTERED 
(
	[dt_hizuke] ASC,
	[cd_hinmei] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
