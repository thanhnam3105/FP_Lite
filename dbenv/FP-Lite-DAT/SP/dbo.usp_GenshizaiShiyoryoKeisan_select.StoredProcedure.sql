IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_GenshizaiShiyoryoKeisan_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_GenshizaiShiyoryoKeisan_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===============================================
-- Author:		tsujita.s
-- Create date: 2013.11.01
-- Last Update: 2015.06.03 kakuta.y
-- Description:	原料/資材使用量計算
--    データ抽出処理
-- ===============================================
CREATE PROCEDURE [dbo].[usp_GenshizaiShiyoryoKeisan_select]
	 @con_hizuke			DATETIME		-- 検索条件：日付
	,@con_bunrui			VARCHAR(10)		-- 検索条件：分類
	,@con_hinKubun			SMALLINT		-- 検索条件：品区分
	,@flg_yojitsu			SMALLINT		-- 検索条件：予実フラグ：予定…0、実績…1
	,@flg_shiyo				SMALLINT		-- 定数：未使用フラグ：使用
	,@kbn_genryo			SMALLINT		-- 定数：品区分：原料
	,@kbn_shizai			SMALLINT		-- 定数：品区分：資材
	,@kbn_jikagen			SMALLINT		-- 定数：品区分：自家原料
	,@tani_li				VARCHAR(2)		-- 定数：単位：L
	,@utc					INT				-- 現地とUTC時間の時差
AS
BEGIN

	SET NOCOUNT ON
	
	--出庫日に休日が設定されないよう営業日を取得
	DECLARE @dtShukko DATETIME
	SELECT
		@dtShukko = MAX(dt_hizuke)
	FROM ma_calendar
	WHERE
		flg_kyujitsu = 0
		AND dt_hizuke < @con_hizuke

	-- 庫出トランを優先するクエリ（庫出トランにしか存在しないレコードも抽出）
	SELECT
		hinmei.kbn_hin AS kbn_hin
		,hinmei.cd_bunrui AS cd_bunrui
		,bunrui.nm_bunrui AS nm_bunrui
		,kuradashi.cd_hinmei AS cd_hinmei
		--,IsNull(hinmei.nm_hinmei_ja, '') AS nm_hinmei_ja
		,COALESCE(hinmei.nm_hinmei_ryaku,hinmei.nm_hinmei_ja, '') AS nm_hinmei_ja
		--,IsNull(hinmei.nm_hinmei_en, '') AS nm_hinmei_en
		,COALESCE(hinmei.nm_hinmei_ryaku,hinmei.nm_hinmei_en, '') AS nm_hinmei_en
		--,IsNull(hinmei.nm_hinmei_zh, '') AS nm_hinmei_zh
		,COALESCE(hinmei.nm_hinmei_ryaku,hinmei.nm_hinmei_zh, '') AS nm_hinmei_zh
		,COALESCE(hinmei.nm_hinmei_ryaku,hinmei.nm_hinmei_vi, '') AS nm_hinmei_vi
		,hinmei.cd_tani_shiyo AS cd_tani_shiyo
		,tani.nm_tani AS nm_tani
		,ISNULL(hinmei.nm_nisugata_hyoji, '') AS nm_nisugata_hyoji
		,kuradashi.dt_hizuke AS dt_hiduke
		,ISNULL(SHIYO_SUM.su_shiyo_sum, 0) AS su_shiyo_sum
		,kuradashi.wt_shiyo_zan AS wt_shiyo_zan
		,kuradashi.dt_shukko AS dt_shukko
		,ISNULL(kuradashi.flg_kakutei, 0) AS flg_kakutei
		,ISNULL(kuradashi.kbn_status, 0) AS kbn_status
		,ISNULL(hinmei.su_iri, 0) AS su_iri
		,ISNULL(hinmei.wt_ko, 0) AS wt_ko
		,hinmei.ritsu_hiju AS ritsu_hiju
		,kuradashi.dt_create AS dt_create
		,ISNULL(kuradashi.su_kuradashi, 0) AS su_kuradashi
		,ISNULL(kuradashi.su_kuradashi_hasu, 0) AS su_kuradashi_hasu
		,m_konyu.cd_tani_nonyu AS cd_tani_nonyu
		,tani2.nm_tani AS nm_tani_kuradashi
	FROM tr_kuradashi kuradashi

	-- 使用予実トラン：サブクエリ１
	LEFT OUTER JOIN
		(
			SELECT 
				cd_hinmei
				,dt_shiyo
				,SUM(su_shiyo) AS su_shiyo_sum
			FROM tr_shiyo_yojitsu
			WHERE
				dt_shiyo = @con_hizuke
				AND su_shiyo <> 0
				AND flg_yojitsu = @flg_yojitsu
			GROUP BY cd_hinmei, dt_shiyo
		) SHIYO_SUM
	ON kuradashi.cd_hinmei = SHIYO_SUM.cd_hinmei
	AND kuradashi.dt_hizuke = SHIYO_SUM.dt_shiyo

	-- 品名マスタ
	INNER JOIN
		(
			SELECT
				cd_hinmei
				,kbn_hin
				,nm_hinmei_ja
				,nm_hinmei_en
				,nm_hinmei_zh
				,nm_hinmei_vi
				,nm_hinmei_ryaku
				,nm_nisugata_hyoji
				,cd_tani_shiyo
				,cd_bunrui
				,ritsu_hiju
				,su_iri
				,wt_ko
			FROM ma_hinmei
			WHERE
				flg_mishiyo = @flg_shiyo
				AND (kbn_hin = @kbn_genryo OR kbn_hin = @kbn_shizai OR kbn_hin = @kbn_jikagen)
				AND (@con_hinKubun = 0 OR kbn_hin = @con_hinKubun)
		) hinmei
	ON kuradashi.cd_hinmei = hinmei.cd_hinmei

	-- 単位マスタ
	LEFT OUTER JOIN ma_tani tani
	ON hinmei.cd_tani_shiyo = tani.cd_tani
	AND tani.flg_mishiyo = @flg_shiyo

	-- 分類マスタ
	LEFT OUTER JOIN ma_bunrui bunrui
	ON hinmei.cd_bunrui = bunrui.cd_bunrui
	AND bunrui.kbn_hin = hinmei.kbn_hin
	AND bunrui.flg_mishiyo = @flg_shiyo
	
	-- 原資材購入先マスタ
	LEFT OUTER JOIN
		(
			SELECT 
				ma_konyu.cd_hinmei
				,cd_tani_nonyu
			FROM ma_konyu
			INNER JOIN
				(
					SELECT
						cd_hinmei
						,MIN(no_juni_yusen) juni
					FROM ma_konyu
					WHERE
						flg_mishiyo = @flg_shiyo
					GROUP BY cd_hinmei
				)mk
			ON mk.cd_hinmei = ma_konyu.cd_hinmei
			AND mk.juni = ma_konyu.no_juni_yusen
		) m_konyu
	ON hinmei.cd_hinmei = m_konyu.cd_hinmei
	
	-- 単位マスタ(納入単位用)
	LEFT OUTER JOIN ma_tani tani2
	ON m_konyu.cd_tani_nonyu = tani2.cd_tani
	AND tani2.flg_mishiyo = @flg_shiyo

	WHERE
		(LEN(@con_bunrui) = 0 OR bunrui.cd_bunrui = @con_bunrui)
		AND kuradashi.dt_hizuke = @con_hizuke

	UNION

	-- 使用予実トランを優先するクエリ
	SELECT
		hinmei.kbn_hin AS kbn_hin
		,hinmei.cd_bunrui AS cd_bunrui
		,bunrui.nm_bunrui AS nm_bunrui
		,SHIYO_SUM.cd_hinmei AS cd_hinmei
		--,IsNull(hinmei.nm_hinmei_ja, '') AS nm_hinmei_ja
		,COALESCE(hinmei.nm_hinmei_ryaku,hinmei.nm_hinmei_ja, '') AS nm_hinmei_ja
		--,IsNull(hinmei.nm_hinmei_en, '') AS nm_hinmei_en
		,COALESCE(hinmei.nm_hinmei_ryaku,hinmei.nm_hinmei_en, '') AS nm_hinmei_en
		--,IsNull(hinmei.nm_hinmei_zh, '') AS nm_hinmei_zh
		,COALESCE(hinmei.nm_hinmei_ryaku,hinmei.nm_hinmei_zh, '') AS nm_hinmei_zh
		,COALESCE(hinmei.nm_hinmei_ryaku,hinmei.nm_hinmei_vi, '') AS nm_hinmei_vi
		,hinmei.cd_tani_shiyo AS cd_tani_shiyo
		,tani.nm_tani AS nm_tani
		,ISNULL(hinmei.nm_nisugata_hyoji, '') AS nm_nisugata_hyoji
		,SHIYO_SUM.dt_shiyo AS dt_hiduke
		,SHIYO_SUM.su_shiyo_sum AS su_shiyo_sum

		-- 庫出トランが存在しない場合は残実績トランを前日残とする
		--,COALESCE(kuradashi.wt_shiyo_zan, zan.wt_jisseki, 0) AS wt_shiyo_zan
		,CASE WHEN kuradashi.wt_shiyo_zan IS NOT NULL
			THEN kuradashi.wt_shiyo_zan
			ELSE
				-- //// 使用単位が「L」の場合、換算処理を行う ////
				-- 残実績トランは全てKgで数値を保持しているため
				CASE WHEN hinmei.cd_tani_shiyo = @tani_li
				THEN
					-- [前日残] = [前日残] / [品名マスタ].[比重]
					ISNULL((zan.wt_jisseki / hinmei.ritsu_hiju), 0)
				ELSE
					ISNULL(zan.wt_jisseki, 0)
				END
			END AS wt_shiyo_zan

		--,SHIYO_SUM.su_shiyo_sum - IsNull(zan.wt_shiyo_zan, 0) AS qty_hitsuyo
		
		-- 庫出トランにデータがなければ、検索条件/日付の前日を表示
		,ISNULL(kuradashi.dt_shukko, @dtShukko) AS dt_shukko
		,ISNULL(kuradashi.flg_kakutei, 0) AS flg_kakutei
		,ISNULL(kuradashi.kbn_status, 0) AS kbn_status
		,ISNULL(hinmei.su_iri, 0) AS su_iri
		,ISNULL(hinmei.wt_ko, 0) AS wt_ko
		,hinmei.ritsu_hiju AS ritsu_hiju
		,kuradashi.dt_create AS dt_create
		,ISNULL(kuradashi.su_kuradashi, 0) AS su_kuradashi
		,ISNULL(kuradashi.su_kuradashi_hasu, 0) AS su_kuradashi_hasu
		,m_konyu.cd_tani_nonyu AS cd_tani_nonyu
		,tani2.nm_tani AS nm_tani_kuradashi
	FROM
		(
		-- 使用予実トラン：サブクエリ１
			SELECT 
				cd_hinmei
				,dt_shiyo
				,SUM(su_shiyo) AS su_shiyo_sum
			FROM tr_shiyo_yojitsu
			WHERE
				dt_shiyo = @con_hizuke
				AND su_shiyo <> 0
				AND flg_yojitsu = @flg_yojitsu
			GROUP BY cd_hinmei, dt_shiyo
		) SHIYO_SUM

	-- 庫出トラン
	LEFT OUTER JOIN tr_kuradashi kuradashi
	ON SHIYO_SUM.cd_hinmei = kuradashi.cd_hinmei
	AND SHIYO_SUM.dt_shiyo = kuradashi.dt_hizuke
	--AND kuradashi.dt_hizuke = @con_hizuke

	-- 残実績トラン：サブクエリ２
	LEFT OUTER JOIN
		(
			SELECT
				cd_hinmei
				,SUM(wt_jisseki) AS wt_jisseki
			FROM tr_zan_jiseki
			WHERE
				DATEADD(hh, @utc, dt_hyoryo_zan) < @con_hizuke
				and dt_kigen > @con_hizuke
			GROUP BY cd_hinmei
		) zan
	ON SHIYO_SUM.cd_hinmei = zan.cd_hinmei
	--AND SHIYO_SUM.dt_shiyo = zan.dt_hyoryo_zan

	-- 品名マスタ
	INNER JOIN
		(
			SELECT
				cd_hinmei
				,kbn_hin
				,nm_hinmei_ja
				,nm_hinmei_en
				,nm_hinmei_zh
				,nm_hinmei_vi
				,nm_hinmei_ryaku
				,nm_nisugata_hyoji
				,cd_tani_shiyo
				,cd_bunrui
				,ritsu_hiju
				,su_iri
				,wt_ko
			FROM ma_hinmei
			WHERE
				flg_mishiyo = @flg_shiyo
				AND (kbn_hin = @kbn_genryo OR kbn_hin = @kbn_shizai OR kbn_hin = @kbn_jikagen)
				AND (@con_hinKubun = 0 OR kbn_hin = @con_hinKubun)
		) hinmei
	ON SHIYO_SUM.cd_hinmei = hinmei.cd_hinmei

	-- 単位マスタ
	LEFT OUTER JOIN ma_tani tani
	ON hinmei.cd_tani_shiyo = tani.cd_tani
	AND tani.flg_mishiyo = @flg_shiyo

	-- 分類マスタ
	LEFT OUTER JOIN ma_bunrui bunrui
	ON hinmei.cd_bunrui = bunrui.cd_bunrui
	AND bunrui.kbn_hin = hinmei.kbn_hin
	AND bunrui.flg_mishiyo = @flg_shiyo
	
	-- 原資材購入先マスタ
	LEFT OUTER JOIN
		(
			SELECT 
				ma_konyu.cd_hinmei
				,cd_tani_nonyu
			FROM ma_konyu
			INNER JOIN
				(
					SELECT cd_hinmei,MIN(no_juni_yusen) juni
					FROM ma_konyu
					WHERE
						flg_mishiyo = @flg_shiyo
					GROUP BY cd_hinmei
				)mk
			ON mk.cd_hinmei = ma_konyu.cd_hinmei
			AND mk.juni = ma_konyu.no_juni_yusen
		) m_konyu
	ON hinmei.cd_hinmei = m_konyu.cd_hinmei
	
	-- 単位マスタ(納入単位用)
	LEFT OUTER JOIN ma_tani tani2
	ON m_konyu.cd_tani_nonyu = tani2.cd_tani
	AND tani2.flg_mishiyo = @flg_shiyo

	WHERE
		(LEN(@con_bunrui) = 0 OR bunrui.cd_bunrui = @con_bunrui)

	ORDER BY kbn_hin, cd_bunrui, cd_hinmei

END
GO
