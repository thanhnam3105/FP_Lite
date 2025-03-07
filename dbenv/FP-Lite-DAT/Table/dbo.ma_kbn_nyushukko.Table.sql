SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ma_kbn_nyushukko](
	[kbn_nyushukko] [smallint] NOT NULL,
	[nm_kbn_nyushukko] [nvarchar](50) NOT NULL,
	[dt_update] [datetime] NOT NULL,
	[ts] [timestamp] NOT NULL,
 CONSTRAINT [PK_ma_kbn_nyushukko] PRIMARY KEY CLUSTERED 
(
	[kbn_nyushukko] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
