SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ma_juryo](
	[kbn_jotai] [smallint] NOT NULL,
	[kbn_hin] [smallint] NOT NULL,
	[cd_hinmei] [varchar](14) NOT NULL,
	[wt_kowake] [decimal](12, 6) NOT NULL,
	[dt_create] [datetime] NOT NULL,
	[cd_create] [varchar](10) NOT NULL,
	[dt_update] [datetime] NOT NULL,
	[cd_update] [varchar](10) NOT NULL,
	[ts] [timestamp] NULL,
 CONSTRAINT [PK_ma_juryo] PRIMARY KEY CLUSTERED 
(
	[kbn_jotai] ASC,
	[kbn_hin] ASC,
	[cd_hinmei] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
