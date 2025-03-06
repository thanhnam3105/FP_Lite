IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_TantoshaMaster_update') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_TantoshaMaster_update]
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
CREATE PROCEDURE [dbo].[usp_TantoshaMaster_update]
	@cd_tanto			VARCHAR(10)
	--,@nm_tanto		VARCHAR(50)
	,@nm_tanto			NVARCHAR(50)
	,@cd_update			VARCHAR(10)
	,@flg_mishiyo		SMALLINT
	,@flg_kyosei_hoshin	SMALLINT
	,@kbn_ma_hinmei		SMALLINT
	,@kbn_ma_haigo		SMALLINT
	,@kbn_ma_konyusaki	SMALLINT
	,@kbn_shikomi_chohyo SMALLINT

AS
BEGIN

/*******************************
	担当者マスタ　更新
*******************************/
UPDATE ma_tanto
SET nm_tanto = @nm_tanto
	,flg_mishiyo = @flg_mishiyo
	,flg_kyosei_hoshin = @flg_kyosei_hoshin
	,kbn_ma_hinmei = @kbn_ma_hinmei		 
	,kbn_ma_haigo = @kbn_ma_haigo		
	,kbn_ma_konyusaki = @kbn_ma_konyusaki	
	,kbn_shikomi_chohyo = @kbn_shikomi_chohyo
	,cd_update = @cd_update
	,dt_update = GETUTCDATE()
WHERE cd_tanto = @cd_tanto

END
GO
