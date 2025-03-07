SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ma_bunrui](
	[kbn_hin] [smallint] NOT NULL,
	[cd_bunrui] [varchar](10) NOT NULL,
	[nm_bunrui] [nvarchar](50) NOT NULL,
	[flg_mishiyo] [smallint] NOT NULL,
	[dt_create] [datetime] NOT NULL,
	[cd_create] [varchar](10) NOT NULL,
	[dt_update] [datetime] NOT NULL,
	[cd_update] [varchar](10) NOT NULL,
	[ts] [timestamp] NOT NULL,
 CONSTRAINT [PK_ma_bunrui] PRIMARY KEY CLUSTERED 
(
	[kbn_hin] ASC,
	[cd_bunrui] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
