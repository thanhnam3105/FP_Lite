SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tr_login_saishu](
	[cd_tanto] [varchar](10) NOT NULL,
	[cd_shokuba] [varchar](10) NOT NULL,
	[cd_panel] [varchar](3) NOT NULL,
	[dt_create] [datetime] NULL,
	[dt_update] [datetime] NULL,
 CONSTRAINT [PK_tr_login_saishu] PRIMARY KEY CLUSTERED 
(
	[cd_tanto] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
