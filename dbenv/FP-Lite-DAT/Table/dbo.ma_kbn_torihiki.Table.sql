SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ma_kbn_torihiki](
	[kbn_torihiki] [smallint] NOT NULL,
	[nm_kbn_torihiki] [nvarchar](50) NOT NULL,
	[dt_update] [datetime] NOT NULL,
	[ts] [timestamp] NOT NULL,
 CONSTRAINT [PK_ma_kbn_torihiki] PRIMARY KEY CLUSTERED 
(
	[kbn_torihiki] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
