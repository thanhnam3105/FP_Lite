SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ma_sagyo](
	[cd_sagyo] [varchar](10) NOT NULL,
	[nm_sagyo] [nvarchar](50) NOT NULL,
	[cd_mark] [varchar](2) NOT NULL,
	[flg_mishiyo] [smallint] NOT NULL,
	[dt_create] [datetime] NOT NULL,
	[cd_create] [varchar](10) NOT NULL,
	[dt_update] [datetime] NOT NULL,
	[cd_update] [varchar](10) NOT NULL,
	[ts] [timestamp] NOT NULL,
	[detail] [nvarchar](4000) NULL,
 CONSTRAINT [PK_ma_sagyo] PRIMARY KEY CLUSTERED 
(
	[cd_sagyo] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
