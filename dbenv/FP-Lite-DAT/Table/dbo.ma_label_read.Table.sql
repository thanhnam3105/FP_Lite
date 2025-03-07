SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ma_label_read](
	[cd_format] [varchar](4) NOT NULL,
	[no_jun] [decimal](4, 0) NOT NULL,
	[su_byte] [decimal](4, 0) NOT NULL,
	[biko] [nvarchar](50) NULL,
	[ts] [timestamp] NOT NULL,
 CONSTRAINT [PK_ma_label_read] PRIMARY KEY CLUSTERED 
(
	[cd_format] ASC,
	[no_jun] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
