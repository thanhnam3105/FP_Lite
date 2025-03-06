IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_NonyuJissekiDensoIchiran_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_NonyuJissekiDensoIchiran_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：納入実績伝送一覧の検索処理
ファイル名	：[usp_NonyuJissekiDensoIchiran_select]
作成日		：2015.03.16 tsujita.s
最終更新日  ：
*****************************************************/
CREATE PROCEDURE [dbo].[usp_NonyuJissekiDensoIchiran_select] 
	@dt_denso_from DATETIME		-- 検索条件：伝送日_開始日
	,@dt_denso_to DATETIME		-- 検索条件：伝送日_終了日
	,@dt_nonyu_from DATETIME	-- 検索条件：納入日_開始日
	,@dt_nonyu_to DATETIME		-- 検索条件：納入日_終了日
	,@cd_hinmei VARCHAR(14)		-- 検索条件：品名コード
	,@no_nonyu VARCHAR(14)		-- 検索条件：納入番号
	,@chk_denso SMALLINT		-- 検索条件：伝送日チェックボックス
	,@chk_nonyu SMALLINT		-- 検索条件：納入日チェックボックス
	,@lot_put_char VARCHAR(3)	-- 定数：納入番号の頭に付与するPrefix
	,@chk_off SMALLINT			-- 定数：チェックボックスがOFFのときの値
AS
BEGIN

    WITH cte_pool AS
    (
		SELECT 
			pl.dt_denso
			,CONVERT(DATETIME, CONVERT(VARCHAR, pl.dt_nonyu) + ' 10:00:00', 112) AS 'dt_nonyu'
			,pl.kbn_denso_SAP
			,@lot_put_char + pl.no_nonyu AS no_nonyu
			,pl.cd_hinmei
			,mh.nm_hinmei_ja
			,mh.nm_hinmei_en
			,mh.nm_hinmei_zh
			,mh.nm_hinmei_vi
			,pl.cd_torihiki
			,tori.nm_torihiki
			,pl.su_nonyu_jitsu AS su_nonyu
			,mt.cd_tani
			,mt.nm_tani
			,pl.kbn_nyuko
		FROM
			tr_sap_jisseki_nonyu_denso_pool pl
		-- 品名マスタ
		LEFT JOIN ma_hinmei mh
		ON mh.cd_hinmei = pl.cd_hinmei
		-- 取引先マスタ
		LEFT JOIN ma_torihiki tori
		ON pl.cd_torihiki = tori.cd_torihiki
		-- 単位変換マスタ
		LEFT JOIN ma_sap_tani_henkan msth
		ON pl.cd_tani_nonyu = msth.cd_tani_henkan
		-- 単位マスタ
		LEFT JOIN ma_tani mt
		ON msth.cd_tani = mt.cd_tani
	)
	
	SELECT
		dt_denso
		,dt_nonyu
		,kbn_denso_SAP
		,no_nonyu
		,cd_hinmei
		,nm_hinmei_ja
		,nm_hinmei_en
		,nm_hinmei_zh
		,nm_hinmei_vi
		,cd_torihiki
		,nm_torihiki
		,su_nonyu
		,cd_tani
		,nm_tani
		,kbn_nyuko
	FROM
		cte_pool
	WHERE
		(@chk_denso = @chk_off OR dt_denso BETWEEN @dt_denso_from AND @dt_denso_to)
	AND (@chk_nonyu = @chk_off OR dt_nonyu BETWEEN @dt_nonyu_from AND @dt_nonyu_to)
	AND (LEN(@cd_hinmei) = 0 OR cd_hinmei = @cd_hinmei)
	AND (LEN(@no_nonyu) = 0 OR no_nonyu like '%' + @no_nonyu + '%')

	ORDER BY
		dt_denso DESC, cd_hinmei, dt_nonyu, no_nonyu, kbn_denso_SAP DESC
END
GO
