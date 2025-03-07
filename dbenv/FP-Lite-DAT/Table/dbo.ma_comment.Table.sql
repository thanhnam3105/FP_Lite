SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ma_comment](
	[no_seq] [varchar](14) NOT NULL,
	[cd_comment] [varchar](2) NOT NULL,
	[comment] [nvarchar](100) NOT NULL,
	[flg_mishiyo] [smallint] NOT NULL,
	[dt_create] [datetime] NOT NULL,
	[cd_create] [varchar](10) NOT NULL,
	[dt_update] [datetime] NOT NULL,
	[cd_update] [varchar](10) NOT NULL,
 CONSTRAINT [PK_ma_comment] PRIMARY KEY CLUSTERED 
(
	[no_seq] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
