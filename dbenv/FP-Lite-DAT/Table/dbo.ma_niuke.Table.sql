SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ma_niuke](
	[cd_niuke_basho] [varchar](10) NOT NULL,
	[nm_niuke] [nvarchar](50) NOT NULL,
	[nm_jusho_1] [nvarchar](30) NULL,
	[nm_jusho_2] [nvarchar](30) NULL,
	[nm_jusho_3] [nvarchar](30) NULL,
	[flg_mishiyo] [smallint] NOT NULL,
	[dt_create] [datetime] NOT NULL,
	[cd_create] [varchar](10) NOT NULL,
	[dt_update] [datetime] NOT NULL,
	[cd_update] [varchar](10) NOT NULL,
	[ts] [timestamp] NOT NULL,
	[kbn_niuke_basho] [varchar](10) NOT NULL,
 CONSTRAINT [PK_ma_niuke] PRIMARY KEY CLUSTERED 
(
	[cd_niuke_basho] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
