SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tr_line_kyujitsu](
	[cd_line] [varchar](10) NOT NULL,
	[dt_seizo] [datetime] NOT NULL,
	[cd_riyu] [varchar](10) NOT NULL,
	[cd_update] [varchar](10) NULL,
	[dt_update] [datetime] NULL,
 CONSTRAINT [PK_tr_line_kyujitsu] PRIMARY KEY CLUSTERED 
(
	[cd_line] ASC,
	[dt_seizo] ASC,
	[cd_riyu] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
