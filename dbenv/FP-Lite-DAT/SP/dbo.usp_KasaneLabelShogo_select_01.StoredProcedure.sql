IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_KasaneLabelShogo_select_01') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_KasaneLabelShogo_select_01]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：重ねラベル照合 検索
ファイル名	：usp_KasaneLabelShogo_select
入力引数	：@markfrom, @markto, @cd_haigo, @no_tonyu
              , @no_kotei, @dt_seizo, @flg_mishiyo
出力引数	：
戻り値		：成功時[0] 失敗時[0以外のエラーコード]
作成日		：2013.11.06  ADMAX okuda.k
更新日		：
*****************************************************/
CREATE PROCEDURE [dbo].[usp_KasaneLabelShogo_select_01]
(
	@markfrom		VARCHAR(2)    --マークコードfrom
	,@markto		VARCHAR(2)    --マークコードto
	,@cd_haigo		VARCHAR(14)   --配合コード
	,@no_tonyu		DECIMAL(4,0)  --投入番号
	,@no_kotei		DECIMAL(4,0)  --工程番号
	,@dt_seizo		DATETIME      --製造日
	,@flg_mishiyo	SMALLINT      --未使用フラグ
)
AS
BEGIN
    SELECT
		mm.mark
		,mhm.nm_haigo_ja
		,mhm.nm_haigo_en
		,mhm.nm_haigo_zh
		,mhm.nm_haigo_vi
		,MAX(mhm.no_han) AS no_han
    FROM ma_haigo_mei mhm
	INNER JOIN ma_haigo_recipe mhr
	ON mhm.cd_haigo = mhr.cd_haigo
	AND mhm.no_han = mhr.no_han
	AND mhm.flg_mishiyo = @flg_mishiyo
	INNER JOIN ma_mark mm
	ON mhr.cd_mark = mm.cd_mark
    WHERE
        mm.cd_mark BETWEEN @markfrom AND @markto
		AND mhr.cd_haigo = @cd_haigo
		AND mhr.no_tonyu = @no_tonyu
		AND mhr.no_kotei = @no_kotei
		AND CONVERT(VARCHAR(10), mhm.dt_from, 111) <= CONVERT(VARCHAR(10), @dt_seizo, 111)
		AND mhr.no_han = (
			SELECT TOP 1
				udf.no_han
			FROM 
				udf_HaigoRecipeYukoHan(@cd_haigo, @flg_mishiyo, @dt_seizo) udf
		) 
	GROUP BY
	    mm.mark
	    ,mhm.nm_haigo_ja
	    ,mhm.nm_haigo_en
	    ,mhm.nm_haigo_zh
		,mhm.nm_haigo_vi
END
GO
