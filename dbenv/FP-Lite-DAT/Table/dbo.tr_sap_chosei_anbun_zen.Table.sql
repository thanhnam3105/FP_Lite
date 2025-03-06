SET ANSI_NULLS ON	
GO	
SET QUOTED_IDENTIFIER ON	
GO	
SET ANSI_PADDING ON	
GO	
CREATE TABLE [dbo].[tr_sap_chosei_anbun_zen](	
	[no_seq] [varchar](14)NOT NULL,
	[no_seq_anbun] [varchar](14)NOT NULL,
	[no_lot_shikakari] [varchar](14)NOT NULL,
	[cd_hinmei] [varchar](14)NOT NULL,
	[dt_hizuke] [datetime]NULL,
	[cd_riyu] [varchar](10)NOT NULL,
	[su_chosei] [decimal](12,6)NOT NULL,
	[cd_genka_center] [varchar](10)NULL,
	[cd_soko] [varchar](10)NULL,
	 CONSTRAINT [PK_tr_sap_chosei_anbun_zen] PRIMARY KEY CLUSTERED 
	(
	
	  no_seq ASC
	
	
	)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
	) ON [PRIMARY]
	GO
	SET ANSI_PADDING OFF
	GO
