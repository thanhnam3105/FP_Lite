SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ma_sap_tani_henkan](
	[cd_tani] [varchar](10) NOT NULL,
	[cd_tani_henkan] [nvarchar](10) NOT NULL,
 CONSTRAINT [PK_ma_sap_tani_henkan] PRIMARY KEY CLUSTERED 
(
	[cd_tani] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
