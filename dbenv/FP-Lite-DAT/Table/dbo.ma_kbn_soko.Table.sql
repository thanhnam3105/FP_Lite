SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ma_kbn_soko](
	[kbn_hin] [smallint] NOT NULL,
	[cd_soko_kbn] [varchar](10) NOT NULL,
	[dt_create] [datetime] NOT NULL,
	[cd_create] [varchar](10) NOT NULL,
	[dt_update] [datetime] NOT NULL,
	[cd_update] [varchar](10) NOT NULL,
 CONSTRAINT [PK_ma_kbn_soko] PRIMARY KEY CLUSTERED 
(
	[kbn_hin] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
