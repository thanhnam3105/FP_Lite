SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ma_kbn_baurate](
	[kbn_baurate] [smallint] NOT NULL,
	[nm_kbn_baurate] [nvarchar](50) NOT NULL,
	[dt_update] [datetime] NOT NULL,
	[ts] [timestamp] NOT NULL,
 CONSTRAINT [PK_ma_kbn_baurate] PRIMARY KEY CLUSTERED 
(
	[kbn_baurate] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
