SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ma_sap_riyu_torikeshi](
	[cd_riyu] [varchar](10) NOT NULL,
	[cd_riyu_torikeshi] [varchar](10) NOT NULL,
	[kbn_ido] [varchar](2) NULL,
	[kbn_ido_torikeshi] [varchar](2) NULL,
	[nm_riyu] [varchar](50) NULL,
 CONSTRAINT [PK_ma_sap_riyu_torikeshi] PRIMARY KEY CLUSTERED 
(
	[cd_riyu] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
