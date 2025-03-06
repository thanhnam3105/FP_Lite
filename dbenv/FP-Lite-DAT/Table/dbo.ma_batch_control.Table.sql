SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[ma_batch_control](
	[id_jobnet] [varchar](20) NOT NULL,
	[flg_shori] [int] NOT NULL,
	[dt_start] [datetime] NULL,
	[dt_end] [datetime] NULL,
	[biko] [varchar](100) NULL,
 CONSTRAINT [PK_ma_batch_control] PRIMARY KEY CLUSTERED 
(
	[id_jobnet] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO