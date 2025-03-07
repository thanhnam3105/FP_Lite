SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ma_torihiki](
	[kbn_torihiki] [smallint] NOT NULL,
	[nm_torihiki] [nvarchar](50) NOT NULL,
	[cd_torihiki] [varchar](13) NOT NULL,
	[nm_torihiki_ryaku] [nvarchar](50) NULL,
	[nm_busho] [nvarchar](50) NULL,
	[no_yubin] [varchar](10) NULL,
	[nm_jusho] [nvarchar](100) NULL,
	[no_tel] [varchar](20) NULL,
	[no_fax] [varchar](20) NULL,
	[e_mail] [varchar](256) NULL,
	[nm_tanto_1] [nvarchar](50) NULL,
	[nm_tanto_2] [nvarchar](50) NULL,
	[nm_tanto_3] [nvarchar](50) NULL,
	[kbn_keishiki_nonyusho] [smallint] NULL,
	[kbn_keisho_nonyusho] [smallint] NULL,
	[kbn_hin] [smallint] NULL,
	[biko] [nvarchar](256) NULL,
	[cd_maker] [varchar](20) NULL,
	[flg_pikking] [smallint] NOT NULL,
	[flg_mishiyo] [smallint] NOT NULL,
	[dt_create] [datetime] NOT NULL,
	[cd_create] [varchar](10) NOT NULL,
	[dt_update] [datetime] NOT NULL,
	[cd_update] [varchar](10) NOT NULL,
	[ts] [timestamp] NOT NULL,
 CONSTRAINT [PK_ma_torihiki] PRIMARY KEY CLUSTERED 
(
	[cd_torihiki] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
