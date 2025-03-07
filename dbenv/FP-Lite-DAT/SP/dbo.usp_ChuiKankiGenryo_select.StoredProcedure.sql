IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_ChuiKankiGenryo_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_ChuiKankiGenryo_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：原料残秤量 注意喚起原料検索
ファイル名	：usp_ChuiKankiGenryo_select
入力引数	：@cd_hinmei,@kbn_hin,@kbnGenryo,@kbnShikakari
出力引数	：
戻り値		：
作成日		：2014.07.22  ADMAX endo.y
更新日		：
*****************************************************/
CREATE PROCEDURE [dbo].[usp_ChuiKankiGenryo_select]
(
	@cd_hinmei		VARCHAR(14)	--品名コード
	,@kbn_hin		SMALLINT	--品区分
	,@kbnGenryo		SMALLINT	--品区分(原料or自家原料)
	,@kbnShikakari	SMALLINT	--品区分(仕掛品)
)
AS 
BEGIN
DECLARE @kbnHin	SMALLINT

	IF @kbn_hin = @kbnGenryo
	BEGIN
		set @kbnHin = (select kbn_hin
						from ma_hinmei
						where cd_hinmei = @cd_hinmei)
	END
	ELSE
	BEGIN
		set @kbnHin = @kbnShikakari
	END
	
	SELECT 
		(select nm_kbn from udf_ChuiKankiShiyo(@cd_hinmei,1,1,0,@kbnHin))as kbnAllergy
		,(select nm_chui_kanki from udf_ChuiKankiShiyo(@cd_hinmei,1,1,0,@kbnHin))as nm_Allergy
		,(select nm_kbn from udf_ChuiKankiShiyo(@cd_hinmei,9,1,0,@kbnHin))as kbnOther
		,(select nm_chui_kanki from udf_ChuiKankiShiyo(@cd_hinmei,9,1,0,@kbnHin))as nm_Other
END
GO
