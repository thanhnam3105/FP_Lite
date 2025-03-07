SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cn_kino_sentaku](
	[kbn_kino] [smallint] NOT NULL,
	[kbn_kino_naiyo] [smallint] NOT NULL,
 CONSTRAINT [PK_cn_kino_sentaku] PRIMARY KEY CLUSTERED 
(
	[kbn_kino] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
