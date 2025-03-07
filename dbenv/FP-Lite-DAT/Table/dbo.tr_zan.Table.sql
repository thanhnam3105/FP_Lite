SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tr_zan](
	[dt_hizuke] [datetime] NOT NULL,
	[cd_hinmei] [varchar](14) NOT NULL,
	[wt_shiyo_zan] [decimal](12, 6) NOT NULL,
 CONSTRAINT [PK_tr_zan] PRIMARY KEY CLUSTERED 
(
	[dt_hizuke] ASC,
	[cd_hinmei] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
