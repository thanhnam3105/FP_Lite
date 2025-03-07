SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ma_zei](
	[kbn_zei] [smallint] NOT NULL,
	[nm_zei] [nvarchar](50) NOT NULL,
	[ritsu_zei] [decimal](5, 2) NOT NULL,
	[dt_update] [datetime] NOT NULL,
	[ts] [timestamp] NOT NULL,
 CONSTRAINT [PK_ma_zei] PRIMARY KEY CLUSTERED 
(
	[kbn_zei] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
