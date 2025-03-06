IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_Hyoryo_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_Hyoryo_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：秤量画面 秤量検索
ファイル名	：usp_Hyoryo_select
入力引数	：no_tonyu, dt_hiduke, no_kotei ,cd_haigo
              ,cd_mark_from ,cd_mark_to, flg_mishiyo
出力引数	：
戻り値		：失敗時[0以外のエラーコード]
作成日		：2013.10.23  ADMAX okuda.k
更新日		：2015.10.27  ADMAX taira.s	有効版を考慮するように修正
*****************************************************/
CREATE PROCEDURE [dbo].[usp_Hyoryo_select]
(
	@no_tonyu		INT          --投入番号
	,@dt_hiduke		DATETIME     --日付
	,@no_kotei		INT          --工程番号
	,@cd_haigo		VARCHAR(14)  --配合コード
	,@cd_mark_from	VARCHAR(3)   --重ねマークコードmin
	,@cd_mark_to	VARCHAR(3)   --重ねマークコードmax
	,@flg_mishiyo	INT          --未使用フラグ
)
AS 
BEGIN
	SELECT
		mm.cd_mark
	FROM ma_mark mm
	INNER JOIN ma_haigo_recipe mhr
	ON mhr.cd_mark = mm.cd_mark
	INNER JOIN ma_haigo_mei mhm
	ON mhr.cd_haigo = mhm.cd_haigo
	AND mhr.no_han = (SELECT TOP 1 no_han FROM udf_HaigoRecipeYukoHan(@cd_haigo, @flg_mishiyo, @dt_hiduke))
	AND mhr.wt_haigo = mhm.wt_haigo
	WHERE mhr.no_tonyu = @no_tonyu
	  AND mhr.cd_haigo = @cd_haigo
	  AND mhr.no_kotei = @no_kotei
	  AND mm.cd_mark BETWEEN @cd_mark_from AND @cd_mark_to
END
GO
