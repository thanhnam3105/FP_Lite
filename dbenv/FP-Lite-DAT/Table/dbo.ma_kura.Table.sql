SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ma_kura](
	[cd_kura] [varchar](10) NOT NULL,
	[nm_kura] [nvarchar](50) NOT NULL,
	[flg_mishiyo] [smallint] NOT NULL,
	[dt_create] [datetime] NOT NULL,
	[cd_create] [varchar](10) NOT NULL,
	[dt_update] [datetime] NOT NULL,
	[cd_update] [varchar](10) NOT NULL,
	[ts] [timestamp] NOT NULL,
 CONSTRAINT [PK_ma_kura] PRIMARY KEY CLUSTERED 
(
	[cd_kura] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
