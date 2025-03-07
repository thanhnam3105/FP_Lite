SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ma_kbn_chui_kanki](
	[kbn_chui_kanki] [smallint] NOT NULL,
	[nm_kbn_chui_kanki] [nvarchar](50) NOT NULL,
	[dt_update] [datetime] NOT NULL,
	[ts] [timestamp] NOT NULL,
 CONSTRAINT [PK_ma_kbn_chui_kanki] PRIMARY KEY CLUSTERED 
(
	[kbn_chui_kanki] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
