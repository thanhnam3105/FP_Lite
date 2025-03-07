SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tr_hakari_check](
	[cd_panel] [varchar](3) NOT NULL,
	[dt_check] [datetime] NOT NULL,
	[cd_shokuba] [varchar](10) NOT NULL,
	[cd_hakari] [varchar](10) NOT NULL,
	[wt_jisseki] [decimal](12, 6) NOT NULL,
	[cd_fundo] [varchar](10) NOT NULL,
	[flg_suihei] [smallint] NULL,
	[cd_tanto] [varchar](10) NOT NULL,
 CONSTRAINT [PK_tr_hakari_check] PRIMARY KEY CLUSTERED 
(
	[cd_panel] ASC,
	[dt_check] ASC,
	[cd_shokuba] ASC,
	[cd_hakari] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
