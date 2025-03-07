SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cn_saiban](
	[kbn_saiban] [varchar](2) NOT NULL,
	[kbn_prefix] [varchar](1) NULL,
	[no] [decimal](18, 0) NULL,
	[ts] [timestamp] NULL,
 CONSTRAINT [PK_cn_saiban] PRIMARY KEY CLUSTERED 
(
	[kbn_saiban] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
