IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_KasaneLabelOkikae_select_04') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_KasaneLabelOkikae_select_04]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：重ねラベル貼替 検索04
ファイル名	：usp_KasaneLabelOkikae_select_04
入力引数	：@cd_haigo ,@no_tonyu, @no_kotei
			  , @dt_hizuke ,@flg_mishiyo
出力引数	：
戻り値		：成功時[0] 失敗時[0以外のエラーコード]
作成日		：2014.01.29  ADMAX kakuta.y -- 03と違い、品区分と品名コードをみない
更新日		：
*****************************************************/
CREATE PROCEDURE [dbo].[usp_KasaneLabelOkikae_select_04]
(
	 @cd_haigo		VARCHAR(14) --配合コード
	 ,@no_tonyu		NUMERIC(4)  --投入番号
	 ,@no_kotei		NUMERIC(4)  --工程番号
	 ,@dt_hizuke	DATETIME    --日付
	 ,@flg_mishiyo	VARCHAR(1)  --未使用フラグ
)
AS
BEGIN
	SELECT
		mm.cd_mark mark
		,MAX(mhr.no_han) AS no_han
	FROM ma_haigo_recipe mhr
	INNER JOIN
		(
			SELECT
				cd_haigo
				,no_han
			FROM udf_HaigoRecipeYukoHan(@cd_haigo, @flg_mishiyo, @dt_hizuke)
		) ma_haigo_mei
	ON mhr.cd_haigo = ma_haigo_mei.cd_haigo
	AND mhr.no_han = ma_haigo_mei.no_han
	INNER JOIN ma_mark mm
	ON mhr.cd_mark = mm.cd_mark
	WHERE
		mhr.cd_haigo = @cd_haigo
		AND mhr.no_tonyu = @no_tonyu
		AND mhr.no_kotei = @no_kotei
	GROUP BY
		mm.cd_mark
END
GO
