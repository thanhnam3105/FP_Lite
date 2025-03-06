IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_KasaneLabelOkikae_select_01') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_KasaneLabelOkikae_select_01]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：重ねラベル置換画面 重ねラベル貼替用SQL
				指定された配合コード、投入番号、工程番号、指定日付以降について、
				マークコードを抽出する。
ファイル名	：usp_KasaneLabelOkikae_select
入力引数	：@cd_haigo, @no_tonyu ,@no_kotei
              , @dt_hizuke, @flg_mishiyo
出力引数	：
戻り値		：
作成日		：2013.09.26  ADMAX okuda.k
更新日		：2015.10.27  ADMAX taira.s	有効版を考慮するように修正
*****************************************************/
CREATE PROCEDURE [dbo].[usp_KasaneLabelOkikae_select_01]
(
	@cd_haigo		VARCHAR(14) --配合コード
	,@no_tonyu		NUMERIC(4)  --投入番号
	,@no_kotei		NUMERIC(4)  --工程番号
	,@dt_hizuke		DATETIME    --日付
	,@flg_mishiyo	VARCHAR(1)  --未使用フラグ
)
AS
BEGIN
	SELECT
		ISNULL(mhr.cd_mark, '00') AS cd_mark
	FROM ma_haigo_recipe mhr
    WHERE
    	mhr.cd_haigo = @cd_haigo
		AND mhr.no_tonyu = @no_tonyu
		AND mhr.no_kotei = @no_kotei
		AND mhr.no_han = (SELECT TOP 1 no_han FROM udf_HaigoRecipeYukoHan(@cd_haigo, @flg_mishiyo, @dt_hizuke))		
END
GO
