SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ma_kaisha](
	[cd_kaisha] [varchar](13) NOT NULL,
	[nm_kaisha] [nvarchar](50) NULL,
	[no_yubin] [varchar](10) NULL,
	[nm_jusho_1] [nvarchar](30) NULL,
	[nm_jusho_2] [nvarchar](30) NULL,
	[nm_jusho_3] [nvarchar](30) NULL,
	[no_tel_1] [varchar](20) NULL,
	[no_tel_2] [varchar](20) NULL,
	[no_fax_1] [varchar](20) NULL,
	[no_fax_2] [varchar](20) NULL,
	[dt_create] [datetime] NOT NULL,
	[cd_create] [varchar](10) NOT NULL,
	[dt_update] [datetime] NOT NULL,
	[cd_update] [varchar](10) NOT NULL,
	[ts] [timestamp] NOT NULL,
 CONSTRAINT [PK_ma_kaisha] PRIMARY KEY CLUSTERED 
(
	[cd_kaisha] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
