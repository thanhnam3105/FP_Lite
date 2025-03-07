SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tr_genshizai_keikaku](
	[cd_hinmei] [varchar](14) NOT NULL,
	[dt_zaiko_keisan] [datetime] NULL,
	[dt_keikaku_nonyu] [datetime] NULL,
 CONSTRAINT [PK_tr_genshizai_keikaku] PRIMARY KEY CLUSTERED 
(
	[cd_hinmei] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
