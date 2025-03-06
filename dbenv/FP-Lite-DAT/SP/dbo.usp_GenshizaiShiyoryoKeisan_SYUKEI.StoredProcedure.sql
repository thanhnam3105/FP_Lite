IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_GenshizaiShiyoryoKeisan_SYUKEI') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_GenshizaiShiyoryoKeisan_SYUKEI]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===============================================
-- Author:		brc.nam
-- Create date: 2017.11.17
-- Last Update: 2017.11.17 brc.nam
-- Description:	庫出依頼画面 職場別EXCEL：集計取得
--    データ抽出処理
-- ===============================================
CREATE PROCEDURE [dbo].[usp_GenshizaiShiyoryoKeisan_SYUKEI]
	  @con_hizuke			DATETIME		-- 検索条件：日付
	, @con_bunrui			VARCHAR(10)		-- 検索条件：分類
	, @con_hinKubun			SMALLINT		-- 検索条件：品区分
	, @con_shokuba			VARCHAR(10)		-- 検索条件：職場
	, @flg_yojitsu			SMALLINT		-- 検索条件：予実フラグ：予定…0、実績…1
	, @flg_shiyo			SMALLINT		-- 定数：未使用フラグ：使用
	, @kbn_genryo			SMALLINT		-- 定数：品区分：原料
	, @kbn_shizai			SMALLINT		-- 定数：品区分：資材
	, @kbn_jikagen			SMALLINT		-- 定数：品区分：自家原料
	, @tani_li				VARCHAR(2)		-- 定数：単位：L
	, @utc					INT				-- 現地とUTC時間の時差
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
	
	-- 定数：0
	DECLARE @zero DECIMAL
		SET @zero = 0
	
	-- 使用予実トラン(仕掛品計画紐付け)
	SELECT
		  hinmei.kbn_hin AS kbn_hin													-- 品区分
		, hinmei.cd_bunrui AS cd_bunrui												-- 分類コード
		, bunrui.nm_bunrui AS nm_bunrui												-- 分類名
		, hinmei.cd_hinmei AS cd_hinmei												-- 品名コード
		, COALESCE(hinmei.nm_hinmei_ryaku,hinmei.nm_hinmei_ja, '') AS nm_hinmei_ja	-- 品名(原資材名)
		, COALESCE(hinmei.nm_hinmei_ryaku,hinmei.nm_hinmei_en, '') AS nm_hinmei_en
		, COALESCE(hinmei.nm_hinmei_ryaku,hinmei.nm_hinmei_zh, '') AS nm_hinmei_zh
		, COALESCE(hinmei.nm_hinmei_ryaku,hinmei.nm_hinmei_vi, '') AS nm_hinmei_vi
		, hinmei.cd_tani_shiyo AS cd_tani_shiyo										-- 単位コード
		, tani.nm_tani AS nm_tani													-- 単位名
		, ISNULL(hinmei.nm_nisugata_hyoji, '') AS nm_nisugata_hyoji					-- 荷姿表示
		, SHIYO_SUM.dt_shiyo AS dt_hiduke											-- 使用予定日
		, SHIYO_SUM.su_shiyo_sum AS su_shiyo_sum									-- 使用予定量		
		, @zero AS wt_shiyo_zan														-- 前日残(0固定)
		, @dtShukko AS dt_shukko													-- 出庫日
		, ISNULL(hinmei.su_iri, 0) AS su_iri										-- 入数
		, ISNULL(hinmei.wt_ko, 0) AS wt_ko											-- 個重量
		, hinmei.ritsu_hiju AS ritsu_hiju											-- 率比重
		, m_konyu.cd_tani_nonyu AS cd_tani_nonyu									-- 庫出単位コード
		, tani2.nm_tani AS nm_tani_kuradashi										-- 庫出単位名
		, shokuba.cd_shokuba AS cd_shokuba											-- 職場コード
		, shokuba.nm_shokuba AS nm_shokuba											-- 職場名
	FROM
	(
		-- 使用予実トラン：サブクエリ
		SELECT 
			  tsy.cd_hinmei
			, tsy.dt_shiyo
			, SUM(su_shiyo) AS su_shiyo_sum
			, keikaku_sikakari.cd_shokuba
		FROM (
			SELECT *
			FROM tr_shiyo_yojitsu
			WHERE
				flg_yojitsu = @flg_yojitsu
				AND dt_shiyo = @con_hizuke
				AND su_shiyo <> 0
		) tsy

		-- 仕掛品計画
		INNER JOIN su_keikaku_shikakari keikaku_sikakari
			ON tsy.no_lot_shikakari = keikaku_sikakari.no_lot_shikakari
			AND (LEN(@con_shokuba) = 0 OR keikaku_sikakari.cd_shokuba = @con_shokuba)
		GROUP BY 	
			  tsy.cd_hinmei
			, tsy.dt_shiyo
			, keikaku_sikakari.cd_shokuba
	) SHIYO_SUM
		
	-- 品名マスタ
	INNER JOIN
		(
			SELECT
				  cd_hinmei
				, kbn_hin
				, nm_hinmei_ja
				, nm_hinmei_en
				, nm_hinmei_zh
				, nm_hinmei_vi
				, nm_hinmei_ryaku
				, nm_nisugata_hyoji
				, cd_tani_shiyo
				, cd_bunrui
				, ritsu_hiju
				, su_iri
				, wt_ko
			FROM ma_hinmei
			WHERE
				flg_mishiyo = @flg_shiyo
				AND (kbn_hin = @kbn_genryo OR kbn_hin = @kbn_shizai OR kbn_hin = @kbn_jikagen)
				AND (@con_hinKubun = 0 OR kbn_hin = @con_hinKubun)
				AND (LEN(@con_bunrui) = 0 OR cd_bunrui = @con_bunrui)
		) hinmei
	ON SHIYO_SUM.cd_hinmei = hinmei.cd_hinmei
	
	-- 原資材購入先マスタ
	LEFT OUTER JOIN
		(
			SELECT 
				  ma_konyu.cd_hinmei
				, cd_tani_nonyu
			FROM ma_konyu
			INNER JOIN
				(
					SELECT cd_hinmei, MIN(no_juni_yusen) juni
					FROM ma_konyu
					WHERE
						flg_mishiyo = @flg_shiyo
					GROUP BY cd_hinmei
				)mk
			ON mk.cd_hinmei = ma_konyu.cd_hinmei
			AND mk.juni = ma_konyu.no_juni_yusen
		) m_konyu
	ON hinmei.cd_hinmei = m_konyu.cd_hinmei
	
	-- 単位マスタ
	LEFT OUTER JOIN ma_tani tani
	ON hinmei.cd_tani_shiyo = tani.cd_tani
	AND tani.flg_mishiyo = @flg_shiyo

	-- 単位マスタ(納入単位用)
	LEFT OUTER JOIN ma_tani tani2
	ON m_konyu.cd_tani_nonyu = tani2.cd_tani
	AND tani2.flg_mishiyo = @flg_shiyo

	-- 職場マスタ
	LEFT OUTER JOIN ma_shokuba shokuba
	ON SHIYO_SUM.cd_shokuba = shokuba.cd_shokuba
	AND shokuba.flg_mishiyo = @flg_shiyo

	-- 分類マスタ
	LEFT OUTER JOIN ma_bunrui bunrui
	ON hinmei.cd_bunrui = bunrui.cd_bunrui
	AND bunrui.kbn_hin = hinmei.kbn_hin
	AND bunrui.flg_mishiyo = @flg_shiyo

UNION

	-- 使用予実トラン(製品計画紐付け)
	SELECT
		  hinmei.kbn_hin AS kbn_hin													-- 品区分
		, hinmei.cd_bunrui AS cd_bunrui												-- 分類コード
		, bunrui.nm_bunrui AS nm_bunrui												-- 分類名
		, hinmei.cd_hinmei AS cd_hinmei												-- 品名コード
		, COALESCE(hinmei.nm_hinmei_ryaku,hinmei.nm_hinmei_ja, '') AS nm_hinmei_ja	-- 品名(原資材名)
		, COALESCE(hinmei.nm_hinmei_ryaku,hinmei.nm_hinmei_en, '') AS nm_hinmei_en
		, COALESCE(hinmei.nm_hinmei_ryaku,hinmei.nm_hinmei_zh, '') AS nm_hinmei_zh
		, COALESCE(hinmei.nm_hinmei_ryaku,hinmei.nm_hinmei_vi, '') AS nm_hinmei_vi
		, hinmei.cd_tani_shiyo AS cd_tani_shiyo										-- 単位コード
		, tani.nm_tani AS nm_tani													-- 単位名
		, ISNULL(hinmei.nm_nisugata_hyoji, '') AS nm_nisugata_hyoji					-- 荷姿表示
		, SHIYO_SUM.dt_shiyo AS dt_hiduke											-- 使用予定日
		, SHIYO_SUM.su_shiyo_sum AS su_shiyo_sum									-- 使用予定量		
		, @zero AS wt_shiyo_zan														-- 前日残(0固定)
		, @dtShukko AS dt_shukko													-- 出庫日
		, ISNULL(hinmei.su_iri, 0) AS su_iri										-- 入数
		, ISNULL(hinmei.wt_ko, 0) AS wt_ko											-- 個重量
		, hinmei.ritsu_hiju AS ritsu_hiju											-- 率比重
		, m_konyu.cd_tani_nonyu AS cd_tani_nonyu									-- 庫出単位コード
		, tani2.nm_tani AS nm_tani_kuradashi										-- 庫出単位名
		, shokuba.cd_shokuba AS cd_shokuba											-- 職場コード
		, shokuba.nm_shokuba AS nm_shokuba											-- 職場名
	FROM 
		(
			-- 使用予実トラン：サブクエリ
			SELECT 
				  tsy.cd_hinmei
				, tsy.dt_shiyo
				, SUM(tsy.su_shiyo) AS su_shiyo_sum
				, keikaku.cd_shokuba AS cd_shokuba
			FROM (
				SELECT *
				FROM tr_shiyo_yojitsu
				WHERE
					flg_yojitsu = @flg_yojitsu
					AND dt_shiyo = @con_hizuke
					AND su_shiyo <> 0
			) tsy
			
			-- 製品計画
			INNER JOIN
				(
					SELECT 
						  no_lot_seihin
						, cd_shokuba
					FROM tr_keikaku_seihin
				) keikaku
				ON tsy.no_lot_seihin = keikaku.no_lot_seihin
				AND (LEN(@con_shokuba) = 0 OR keikaku.cd_shokuba = @con_shokuba)
			GROUP BY 
			  tsy.cd_hinmei
			, tsy.dt_shiyo
			, keikaku.cd_shokuba
		) SHIYO_SUM

	-- 品名マスタ
	INNER JOIN
		(
			SELECT
				  cd_hinmei
				, kbn_hin
				, nm_hinmei_ja
				, nm_hinmei_en
				, nm_hinmei_zh
				, nm_hinmei_vi
				, nm_hinmei_ryaku
				, nm_nisugata_hyoji
				, cd_tani_shiyo
				, cd_bunrui
				, ritsu_hiju
				, su_iri
				, wt_ko
			FROM ma_hinmei
			WHERE
				flg_mishiyo = @flg_shiyo
				AND (kbn_hin = @kbn_genryo OR kbn_hin = @kbn_shizai OR kbn_hin = @kbn_jikagen)
				AND (@con_hinKubun = 0 OR kbn_hin = @con_hinKubun)
				AND (LEN(@con_bunrui) = 0 OR cd_bunrui = @con_bunrui)
		) hinmei
	ON SHIYO_SUM.cd_hinmei = hinmei.cd_hinmei
	
	-- 原資材購入先マスタ
	LEFT OUTER JOIN
		(
			SELECT 
				  ma_konyu.cd_hinmei
				, cd_tani_nonyu
			FROM ma_konyu
			INNER JOIN
				(
					SELECT cd_hinmei, MIN(no_juni_yusen) juni
					FROM ma_konyu
					WHERE
						flg_mishiyo = @flg_shiyo
					GROUP BY cd_hinmei
				)mk
			ON mk.cd_hinmei = ma_konyu.cd_hinmei
			AND mk.juni = ma_konyu.no_juni_yusen
		) m_konyu
	ON hinmei.cd_hinmei = m_konyu.cd_hinmei

	-- 単位マスタ
	LEFT OUTER JOIN ma_tani tani
	ON hinmei.cd_tani_shiyo = tani.cd_tani
	AND tani.flg_mishiyo = @flg_shiyo
	
	-- 単位マスタ(納入単位用)
	LEFT OUTER JOIN ma_tani tani2
	ON m_konyu.cd_tani_nonyu = tani2.cd_tani
	AND tani2.flg_mishiyo = @flg_shiyo

	-- 職場マスタ
	LEFT OUTER JOIN ma_shokuba shokuba
	ON SHIYO_SUM.cd_shokuba = shokuba.cd_shokuba
	AND shokuba.flg_mishiyo = @flg_shiyo

	-- 分類マスタ
	LEFT OUTER JOIN ma_bunrui bunrui
	ON hinmei.cd_bunrui = bunrui.cd_bunrui
	AND bunrui.kbn_hin = hinmei.kbn_hin
	AND bunrui.flg_mishiyo = @flg_shiyo

ORDER BY 
	  hinmei.kbn_hin
	, hinmei.cd_bunrui
	, hinmei.cd_hinmei

END