SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ma_shiyo_b](
	[cd_hinmei] [varchar](14) NOT NULL,
	[no_han] [decimal](4, 0) NOT NULL,
	[cd_shizai] [varchar](14) NOT NULL,
	[su_shiyo] [decimal](12, 6) NOT NULL,
	[dt_create] [datetime] NOT NULL,
	[cd_create] [varchar](10) NOT NULL,
	[dt_update] [datetime] NOT NULL,
	[cd_update] [varchar](10) NOT NULL,
	[ts] [timestamp] NOT NULL,
 CONSTRAINT [PK_ma_shiyo_b] PRIMARY KEY CLUSTERED 
(
	[cd_hinmei] ASC,
	[no_han] ASC,
	[cd_shizai] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
