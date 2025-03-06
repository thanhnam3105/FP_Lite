SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ma_literal](
	[kbn_literal] [nvarchar](100) NOT NULL,
	[cd_key] [nvarchar](100)  NOT NULL,
	[cd_literal] [nvarchar](100) NULL,
	[flg_mishiyo] [bit] NULL,
	[dt_create] [datetime] NULL,
	[cd_create] [varchar](10) NULL,
	[dt_update] [datetime] NOT NULL,
	[cd_update] [varchar](10) NULL,
	[nm_literal] [nvarchar](100) NULL
 CONSTRAINT [PK_ma_literal] PRIMARY KEY CLUSTERED 
(
	[kbn_literal]ASC,
	[cd_key] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)

GO
