IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_TantoshaMaster_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_TantoshaMaster_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,kobayashi.y>
-- Create date: <Create Date,,2013.07.29>
-- Last Update: <2016.12.13 motojima.m>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_TantoshaMaster_create]
	@cd_tanto			VARCHAR(10)
	--,@nm_tanto		VARCHAR(50)
	,@nm_tanto			NVARCHAR(50)
	--,@nm_shozoku		VARCHAR(20)
	,@nm_shozoku		NVARCHAR(20)
	--,@nm_renrakusaki	VARCHAR(14)
	,@nm_renrakusaki	NVARCHAR(14)
	,@e_mail			VARCHAR(14)
	,@flg_mrp			SMALLINT
	,@flg_kyosei_hoshin	SMALLINT
	,@flg_mishiyo		SMALLINT
	,@cd_create			VARCHAR(10)
	,@cd_update			VARCHAR(10)
	,@cd_shokuba		VARCHAR(10)
	,@kbn_ma_hinmei		SMALLINT
	,@kbn_ma_haigo		SMALLINT
	,@kbn_ma_konyusaki	SMALLINT
	,@kbn_shikomi_chohyo SMALLINT
AS
BEGIN

/*******************************
	担当者マスタ　新規
*******************************/
INSERT INTO ma_tanto
(
	cd_tanto	
	,nm_tanto	
	,nm_shozoku	
	,nm_renrakusaki	
	,e_mail	
	,flg_mrp	
	,flg_kyosei_hoshin
	,flg_mishiyo
	,kbn_ma_hinmei		
	,kbn_ma_haigo		
	,kbn_ma_konyusaki	
	,kbn_shikomi_chohyo
	,dt_create	
	,cd_create	
	,dt_update	
	,cd_update	
	,cd_shokuba
)
values
(
	@cd_tanto	
	,@nm_tanto
	,@nm_shozoku
	,@nm_renrakusaki
	,@e_mail	
	,@flg_mrp
	,@flg_kyosei_hoshin
	,@flg_mishiyo	
	,@kbn_ma_hinmei		
	,@kbn_ma_haigo		
	,@kbn_ma_konyusaki	
	,@kbn_shikomi_chohyo
	,GETUTCDATE()
	,@cd_create
	,GETUTCDATE()
	,@cd_update
	,@cd_shokuba
)

END
GO
