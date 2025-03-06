SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ma_riyu](
	[kbn_bunrui_riyu] [smallint] NOT NULL,
	[cd_riyu] [varchar](10) NOT NULL,
	[nm_riyu] [nvarchar](50) NOT NULL,
	[dt_create] [datetime] NOT NULL,
	[cd_create] [varchar](10) NOT NULL,
	[dt_update] [datetime] NOT NULL,
	[cd_update] [varchar](10) NOT NULL,
	[ts] [timestamp] NOT NULL,
	[flg_kinshi] [smallint] NOT NULL,
	[flg_denso] [smallint] NOT NULL,
 CONSTRAINT [PK_ma_riyu] PRIMARY KEY CLUSTERED 
(
	[kbn_bunrui_riyu] ASC,
	[cd_riyu] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
