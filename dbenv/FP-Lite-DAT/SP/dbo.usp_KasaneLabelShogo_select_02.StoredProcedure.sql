IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_KasaneLabelShogo_select_02') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_KasaneLabelShogo_select_02]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：重ねラベル照合 検索02
ファイル名	：usp_KasaneLabelShogo_select02
入力引数	：@mark, @cd_haigo, @no_kotei
              , @no_han, @flg_mishiyo
出力引数	：
戻り値		：成功時[0] 失敗時[0以外のエラーコード]
作成日		：2013.11.06  ADMAX okuda.k
更新日		：2015.01.18  ADMAX shibao.s
*****************************************************/
CREATE PROCEDURE [dbo].[usp_KasaneLabelShogo_select_02]
(
	@mark			VARCHAR(2)    --マーク
	,@cd_haigo		VARCHAR(14)   --配合コード
	,@no_kotei		DECIMAL(4,0)  --投入番号
	,@no_han		DECIMAL(4,0)  --版番号
	,@flg_mishiyo	SMALLINT      --未使用フラグ
)
AS
BEGIN
	SELECT 
		mhr.no_tonyu
		,mhr.cd_hinmei
		,mhr.nm_hinmei
		,mhr.wt_haigo
		,mhr.wt_shikomi
		,mhr.wt_kowake
	FROM ma_haigo_mei mhm
	INNER JOIN ma_haigo_recipe mhr
	ON mhm.cd_haigo = mhr.cd_haigo
	AND mhm.no_han = mhr.no_han
	AND mhm.flg_mishiyo = @flg_mishiyo
	INNER JOIN ma_mark mm
	ON mhr.cd_mark = mm.cd_mark
	WHERE
		mm.mark = @mark
		AND mhr.cd_haigo = @cd_haigo
		AND mhr.no_kotei = @no_kotei
		AND mhm.no_han = @no_han
END
GO
