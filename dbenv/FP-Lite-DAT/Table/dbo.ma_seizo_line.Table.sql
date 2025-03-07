SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ma_seizo_line](
	[kbn_master] [smallint] NOT NULL,
	[cd_haigo] [varchar](14) NOT NULL,
	[no_juni_yusen] [smallint] NOT NULL,
	[cd_line] [varchar](10) NOT NULL,
	[flg_mishiyo] [smallint] NOT NULL,
	[dt_create] [datetime] NOT NULL,
	[cd_create] [varchar](10) NOT NULL,
	[dt_update] [datetime] NOT NULL,
	[cd_update] [varchar](10) NOT NULL,
	[ts] [timestamp] NOT NULL,
 CONSTRAINT [PK_ma_seizo_line_1] PRIMARY KEY CLUSTERED 
(
	[kbn_master] ASC,
	[cd_haigo] ASC,
	[no_juni_yusen] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
