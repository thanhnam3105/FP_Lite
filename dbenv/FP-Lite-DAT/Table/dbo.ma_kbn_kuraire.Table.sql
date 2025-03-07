SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ma_kbn_kuraire](
	[kbn_kuraire] [smallint] NOT NULL,
	[nm_kbn_kuraire] [nvarchar](50) NOT NULL,
	[dt_update] [datetime] NOT NULL,
	[ts] [timestamp] NOT NULL,
 CONSTRAINT [PK_ma_kuraire] PRIMARY KEY CLUSTERED 
(
	[kbn_kuraire] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
