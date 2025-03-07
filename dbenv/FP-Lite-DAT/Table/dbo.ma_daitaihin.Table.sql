SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ma_daitaihin](
	[kbn_hin_daihyo] [smallint] NOT NULL,
	[cd_hinmei_daihyo] [varchar](14) NOT NULL,
	[kbn_hin] [smallint] NOT NULL,
	[cd_hinmei] [varchar](14) NOT NULL,
	[dt_create] [datetime] NOT NULL,
	[cd_create] [varchar](10) NOT NULL,
	[dt_update] [datetime] NOT NULL,
	[cd_update] [varchar](10) NOT NULL,
	[flg_mishiyo] [smallint] NOT NULL,
	[ts] [timestamp] NOT NULL,
 CONSTRAINT [PK_ma_daitaihin] PRIMARY KEY CLUSTERED 
(
	[kbn_hin_daihyo] ASC,
	[cd_hinmei_daihyo] ASC,
	[kbn_hin] ASC,
	[cd_hinmei] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
