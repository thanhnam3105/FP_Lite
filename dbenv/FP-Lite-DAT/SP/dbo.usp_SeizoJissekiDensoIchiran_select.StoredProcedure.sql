IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_SeizoJissekiDensoIchiran_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_SeizoJissekiDensoIchiran_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：製造実績伝送一覧の検索処理
ファイル名	：[usp_SeizoJissekiDensoIchiran_select]
作成日		：2015.03.10 tsujita.s
最終更新日  ：2015.03.19 tsujita.s
*****************************************************/
CREATE PROCEDURE [dbo].[usp_SeizoJissekiDensoIchiran_select] 
	@dt_denso_from DATETIME		-- 検索条件：伝送日_開始日
	,@dt_denso_to DATETIME		-- 検索条件：伝送日_終了日
	,@dt_seizo_from DATETIME	-- 検索条件：製造日_開始日
	,@dt_seizo_to DATETIME		-- 検索条件：製造日_終了日
	,@cd_hinmei VARCHAR(14)		-- 検索条件：製品コード
	,@no_lot_seihin VARCHAR(14)	-- 検索条件：製品ロット番号
	,@chk_denso SMALLINT		-- 検索条件：伝送日チェックボックス
	,@chk_seizo SMALLINT		-- 検索条件：製造日チェックボックス
	,@lot_put_char VARCHAR(3)	-- 定数：製品ロット番号の頭に付与するPrefix
	,@chk_off SMALLINT			-- 定数：チェックボックスがOFFのときの値
AS
BEGIN

    WITH cte_pool AS
    (
		SELECT 
			tsjsdp.dt_denso
			,tsjsdp.kbn_denso_SAP
			,CONVERT(DATETIME, CONVERT(VARCHAR, tsjsdp.dt_seizo) + ' 10:00:00', 112) dt_seizo
			,tsjsdp.cd_hinmei
			,mh.nm_hinmei_ja
			,mh.nm_hinmei_en
			,mh.nm_hinmei_zh
			,mh.nm_hinmei_vi
			,(@lot_put_char + SUBSTRING(tsjsdp.no_lot_seihin, 3, 10)) AS no_lot_seihin
			,tsjsdp.su_seizo_jisseki AS su_seizo
			,mt.cd_tani
			,mt.nm_tani
			,tsjsdp.no_lot_hyoji
		FROM tr_sap_jisseki_seihin_denso_pool tsjsdp
		LEFT JOIN ma_hinmei mh
			ON mh.cd_hinmei = tsjsdp.cd_hinmei
		LEFT JOIN ma_sap_tani_henkan msth
			ON tsjsdp.cd_tani_SAP = msth.cd_tani_henkan
		LEFT JOIN ma_tani mt
			ON msth.cd_tani = mt.cd_tani
	)
	
	SELECT
		dt_denso
		,kbn_denso_SAP
		,dt_seizo
		,cd_hinmei
		,nm_hinmei_ja
		,nm_hinmei_en
		,nm_hinmei_zh
		,nm_hinmei_vi
		,no_lot_seihin
		,su_seizo
		,cd_tani
		,nm_tani
		,no_lot_hyoji
	FROM
		cte_pool
	WHERE
		(@chk_denso = @chk_off OR dt_denso BETWEEN @dt_denso_from AND @dt_denso_to)
	AND (@chk_seizo = @chk_off OR dt_seizo BETWEEN @dt_seizo_from AND @dt_seizo_to)
	AND (LEN(@cd_hinmei) = 0 OR cd_hinmei = @cd_hinmei)
	AND (LEN(@no_lot_seihin) = 0 OR no_lot_seihin like '%' + @no_lot_seihin + '%')

	ORDER BY
		dt_denso DESC, cd_hinmei, kbn_denso_SAP DESC
END
GO
