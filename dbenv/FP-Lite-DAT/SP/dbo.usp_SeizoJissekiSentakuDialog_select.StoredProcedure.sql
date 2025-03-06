DROP PROCEDURE [dbo].[usp_SeizoJissekiSentakuDialog_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/**********************************************************************
機能：製造実績選択ダイアログ画面　検索処理
ファイル名：usp_SeizoJissekiSentakuDialog_select
作成日：2015.07.01 tsujita.s
更新日：2016.01.16 yokota
		2020.01.23 wang     --製造予定数また製造実績数が0のとき、取得しない。
**********************************************************************/
CREATE PROCEDURE [dbo].[usp_SeizoJissekiSentakuDialog_select]
    @dt_from datetime			-- 検索条件：開始日
    ,@dt_to datetime			-- 検索条件：終了日
	,@cd_haigo varchar(14)		-- 検索条件：仕掛品コード
    ,@flg_kakutei smallint		-- 固定値：確定フラグ：確定
    ,@flg_shiyo smallint		-- 固定値：未使用フラグ：使用
AS
BEGIN

	SELECT
		seihin.cd_hinmei
		,hin.kbn_hin
		,kbn.nm_kbn_hin
		,hin.nm_hinmei_ja
		,hin.nm_hinmei_en
		,hin.nm_hinmei_zh
		,hin.nm_hinmei_vi
		,seihin.dt_seizo
		,seihin.su_seizo
		,seihin.no_lot_seihin
		,hin.flg_testitem
	FROM (
		SELECT
			cd_hinmei
			,dt_seizo
			,COALESCE(su_seizo_jisseki, 0) AS su_seizo
			,no_lot_seihin
			,flg_jisseki
		FROM
			tr_keikaku_seihin
		WHERE
			flg_jisseki = @flg_kakutei
		AND dt_seizo BETWEEN @dt_from AND @dt_to
		AND su_seizo_jisseki <> 0

		UNION ALL

		SELECT
			cd_hinmei
			,dt_seizo
			,COALESCE(su_seizo_yotei, 0) AS su_seizo
			,no_lot_seihin
			,flg_jisseki
		FROM
			tr_keikaku_seihin
		WHERE
			flg_jisseki <> @flg_kakutei
		AND dt_seizo BETWEEN @dt_from AND @dt_to
		AND su_seizo_yotei <> 0
	) seihin
	
	INNER JOIN ma_hinmei hin
	ON seihin.cd_hinmei = hin.cd_hinmei
	AND hin.cd_haigo = @cd_haigo

	LEFT JOIN ma_kbn_hin kbn
	ON hin.kbn_hin = kbn.kbn_hin

	ORDER BY
		seihin.dt_seizo, hin.kbn_hin, seihin.cd_hinmei

END



GO
