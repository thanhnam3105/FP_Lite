SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ma_batch_old_data_del](
	[no_shori] [int] NOT NULL,
	[table_name] [varchar](50) NULL,
	[column_name] [varchar](20) NULL,
	[column_style] [varchar](30) NULL,
	[date_part] [varchar](5) NULL,
	[date_number] [int] NULL,
	[max_rec] [int] NULL,
	[flg_shori] [int] NULL,
 CONSTRAINT [PK_ma_batch_old_data_del] PRIMARY KEY CLUSTERED 
(
	[no_shori] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

