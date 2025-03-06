IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_NonyuIraishoListPdf_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_NonyuIraishoListPdf_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===============================================
-- Author:		tsujita.s
-- Create date: 2013.09.11
-- Last Update: 2015.02.19 tsujita.s
-- Description:	納入依頼書リスト
--    PDF用データ抽出処理
-- ===============================================
CREATE PROCEDURE [dbo].[usp_NonyuIraishoListPdf_select]
	@hizuke_from			datetime		-- 日付：始点
	,@hizuke_to				datetime		-- 日付：終点
	,@today					datetime		-- UTC時間で変換済みシステム日付
	,@yotei_nashi			smallint		-- 予定なしも出力：1
	,@flg_yotei				smallint		-- 定数：予実フラグ：予定
	,@flg_jisseki			smallint		-- 定数：予実フラグ：実績
	,@flg_mishiyo			smallint		-- 定数：未使用フラグ：使用
	,@param_torihiki		varchar(1000)	-- 検索条件：選択された取引先コード
	,@param_hin				varchar(1000)	-- 検索条件：選択された品名コード
	,@tani_kg				varchar(2)		-- 定数：単位コード：Kg
	,@tani_li				varchar(2)		-- 定数：単位コード：L
AS
BEGIN

	SET NOCOUNT ON

	-- ========================================================
	-- ========================================================
	--   全件印刷時
	-- ========================================================
	-- ========================================================
	IF @param_torihiki = ''
	BEGIN
		-- ■ 納入トラン情報＋納入ワークの情報を取得
		SELECT
		 CALENDAR.dt_hizuke AS dt_hizuke
		 ,NONYU.cd_hinmei AS cd_hinmei

		 --,floor(NONYU.su_nonyu) AS su_nonyu
		 -- 納入単位がKgまたはLの場合は、端数を正規数に加算する
		 ,dbo.udf_NonyuHasuKanzan(
			ma_ko.cd_tani_nonyu, ma_hin.cd_tani_nonyu,
			NONYU.su_nonyu, NONYU.su_nonyu_hasu, @tani_kg, @tani_li) AS su_nonyu

		 ,COALESCE(WORK.su_nonyu, 0) AS su_nonyu_wo
		 ,COALESCE(NONYU.cd_torihiki, '') AS cd_torihiki
		 ,COALESCE(ma_hin.cd_niuke_basho, '') AS cd_niuke_basho
		 ,COALESCE(ma_hin.nm_hinmei_ja, '') AS nm_hinmei_ja
		 ,COALESCE(ma_hin.nm_hinmei_en, '') AS nm_hinmei_en
		 ,COALESCE(ma_hin.nm_hinmei_zh, '') AS nm_hinmei_zh
		 ,COALESCE(ma_hin.nm_hinmei_vi, '') AS nm_hinmei_vi
		 ,ma_hin.cd_bunrui AS cd_bunrui
		 ,ma_bun.nm_bunrui AS nm_bunrui
		 ,ma_tan_nonyu.nm_tani AS nonyu_tani
		 ,ma_tan_shiyo.nm_tani AS shiyo_tani
		 ,ma_ko.nm_nisugata_hyoji AS nm_nisugata_hyoji
		 -- 重量
		 --,COALESCE(ma_ko.wt_nonyu, 0) * COALESCE(ma_ko.su_iri, 0)
		 --	* floor(NONYU.su_nonyu) AS juryo
		 ,COALESCE(ma_ko.wt_nonyu, 0) * COALESCE(ma_ko.su_iri, 0)
			* dbo.udf_NonyuHasuKanzan(
				ma_ko.cd_tani_nonyu, ma_hin.cd_tani_nonyu,
				NONYU.su_nonyu, NONYU.su_nonyu_hasu, @tani_kg, @tani_li) AS juryo
		FROM
		-- カレンダーマスタ
		(SELECT dt_hizuke
				,flg_kyujitsu
		 FROM ma_calendar
		 WHERE dt_hizuke >= @hizuke_from
		 AND dt_hizuke < @hizuke_to
		) CALENDAR

		-- 納入トラン
		LEFT JOIN (SELECT cd_hinmei AS cd_hinmei
				,dt_nonyu AS dt_nonyu
				,SUM(su_nonyu) AS su_nonyu
				,cd_torihiki AS cd_torihiki
				,SUM(su_nonyu_hasu) AS su_nonyu_hasu
			FROM tr_nonyu
			WHERE dt_nonyu >= @hizuke_from
			AND dt_nonyu < @hizuke_to
			AND (
				(dt_nonyu < @today AND flg_yojitsu = @flg_jisseki)
				OR
				(dt_nonyu >= @today AND flg_yojitsu = @flg_yotei)
			)
			GROUP BY cd_hinmei, dt_nonyu, cd_torihiki
		) NONYU
		ON NONYU.dt_nonyu = CALENDAR.dt_hizuke

		-- 納入ワークトラン
		LEFT JOIN (SELECT cd_hinmei AS cd_hinmei
				,dt_nonyu AS dt_nonyu
				,su_nonyu AS su_nonyu
				,cd_torihiki AS cd_torihiki
			FROM wk_nonyu
			WHERE dt_nonyu >= @hizuke_from
			AND dt_nonyu < @hizuke_to
		) WORK
		ON WORK.dt_nonyu = CALENDAR.dt_hizuke
		AND WORK.cd_hinmei = NONYU.cd_hinmei

		-- 品名マスタ
		LEFT JOIN ma_hinmei ma_hin
		ON ma_hin.cd_hinmei = NONYU.cd_hinmei

		-- 原資材購入先マスタ
		LEFT JOIN ma_konyu ma_ko
		ON ma_ko.cd_hinmei = NONYU.cd_hinmei
		AND ma_ko.cd_torihiki = NONYU.cd_torihiki

		-- 単位マスタ：納入単位
		LEFT JOIN ma_tani ma_tan_nonyu
		ON ma_tan_nonyu.cd_tani = ma_ko.cd_tani_nonyu

		-- 単位マスタ：使用単位
		LEFT JOIN ma_tani ma_tan_shiyo
		ON ma_tan_shiyo.cd_tani = ma_hin.cd_tani_shiyo

		-- 分類マスタ
		LEFT JOIN ma_bunrui ma_bun
		ON ma_bun.cd_bunrui = ma_hin.cd_bunrui
		AND ma_bun.kbn_hin = ma_hin.kbn_hin

		WHERE
			NONYU.su_nonyu > 0 OR NONYU.su_nonyu_hasu > 0 OR WORK.su_nonyu > 0
			
	UNION
			
		-- ■ 納入ワークにしか存在しない情報を取得
		SELECT
		 CALENDAR.dt_hizuke AS dt_hizuke
		 ,WORK.cd_hinmei AS cd_hinmei

		 --,COALESCE(NONYU.su_nonyu, 0) AS su_nonyu
		 -- 納入単位がKgまたはLの場合は、端数を正規数に加算する
		 ,dbo.udf_NonyuHasuKanzan(
			wo_ko.cd_tani_nonyu, wo_hin.cd_tani_nonyu,
			NONYU.su_nonyu, NONYU.su_nonyu_hasu, @tani_kg, @tani_li) AS su_nonyu

		 ,COALESCE(WORK.su_nonyu, 0) AS su_nonyu_wo
		 ,COALESCE(WORK.cd_torihiki, '') AS cd_torihiki
		 ,COALESCE(wo_hin.cd_niuke_basho, '') AS cd_niuke_basho
		 ,COALESCE(wo_hin.nm_hinmei_ja, '') AS nm_hinmei_ja
		 ,COALESCE(wo_hin.nm_hinmei_en, '') AS nm_hinmei_en
		 ,COALESCE(wo_hin.nm_hinmei_zh, '') AS nm_hinmei_zh
		 ,COALESCE(wo_hin.nm_hinmei_vi, '') AS nm_hinmei_vi
		 ,wo_bun.cd_bunrui AS cd_bunrui
		 ,wo_bun.nm_bunrui AS nm_bunrui
		 ,wo_tan_nonyu.nm_tani AS nonyu_tani
		 ,wo_tan_shiyo.nm_tani AS shiyo_tani
		 ,wo_ko.nm_nisugata_hyoji AS nm_nisugata_hyoji
		 ,0 AS juryo
		FROM
		-- カレンダーマスタ
		(SELECT dt_hizuke
				,flg_kyujitsu
		 FROM ma_calendar
		 WHERE dt_hizuke >= @hizuke_from
		 AND dt_hizuke < @hizuke_to
		) CALENDAR

		-- 納入ワークトラン
		LEFT JOIN (SELECT cd_hinmei AS cd_hinmei
				,dt_nonyu AS dt_nonyu
				,su_nonyu AS su_nonyu
				,cd_torihiki AS cd_torihiki
			FROM wk_nonyu
			WHERE dt_nonyu >= @hizuke_from
			AND dt_nonyu < @hizuke_to
		) WORK
		ON WORK.dt_nonyu = CALENDAR.dt_hizuke

		-- 納入トラン
		LEFT JOIN (SELECT cd_hinmei AS cd_hinmei
				,dt_nonyu AS dt_nonyu
				,SUM(su_nonyu) AS su_nonyu
				--,SUM(su_nonyu) + SUM(su_nonyu_hasu) AS su_nonyu
				,SUM(su_nonyu_hasu) AS su_nonyu_hasu
				,cd_torihiki AS cd_torihiki
			FROM tr_nonyu
			WHERE dt_nonyu >= @hizuke_from
			AND dt_nonyu < @hizuke_to
			AND (
				(dt_nonyu < @today AND flg_yojitsu = @flg_jisseki)
				OR
				(dt_nonyu >= @today AND flg_yojitsu = @flg_yotei)
			)
			GROUP BY cd_hinmei, dt_nonyu, cd_torihiki
		) NONYU
		ON NONYU.dt_nonyu = CALENDAR.dt_hizuke
		AND NONYU.cd_hinmei = WORK.cd_hinmei

		-- 品名マスタ
		LEFT JOIN ma_hinmei wo_hin
		ON wo_hin.cd_hinmei = WORK.cd_hinmei

		-- 原資材購入先マスタ
		LEFT JOIN ma_konyu wo_ko
		ON wo_ko.cd_hinmei = WORK.cd_hinmei
		AND wo_ko.cd_torihiki = WORK.cd_torihiki

		-- 単位マスタ：納入単位
		LEFT JOIN ma_tani wo_tan_nonyu
		ON wo_tan_nonyu.cd_tani = wo_ko.cd_tani_nonyu

		-- 単位マスタ：使用単位
		LEFT JOIN ma_tani wo_tan_shiyo
		ON wo_tan_shiyo.cd_tani = wo_hin.cd_tani_shiyo

		-- 分類マスタ
		LEFT JOIN ma_bunrui wo_bun
		ON wo_bun.cd_bunrui = wo_hin.cd_bunrui
		AND wo_bun.kbn_hin = wo_hin.kbn_hin
			
		WHERE (NONYU.su_nonyu > 0 OR NONYU.su_nonyu_hasu > 0 OR WORK.su_nonyu > 0)
		AND NONYU.cd_hinmei IS NULL
	END

	-- ========================================================
	-- ========================================================
	--  「予定なしの品目も出力する」にチェックが入っていた場合
	-- ========================================================
	-- ========================================================
	ELSE IF @yotei_nashi = 1
	BEGIN
		-- ■ 納入トラン情報＋納入ワークの情報を取得
		SELECT
		 CALENDAR.dt_hizuke AS dt_hizuke
		 ,NONYU.cd_hinmei AS cd_hinmei

		 --,floor(NONYU.su_nonyu) AS su_nonyu
		 -- 納入単位がKgまたはLの場合は、端数を正規数に加算する
		 ,dbo.udf_NonyuHasuKanzan(
			ma_ko.cd_tani_nonyu, ma_hin.cd_tani_nonyu,
			NONYU.su_nonyu, NONYU.su_nonyu_hasu, @tani_kg, @tani_li) AS su_nonyu

		 ,COALESCE(WORK.su_nonyu, 0) AS su_nonyu_wo
		 ,COALESCE(NONYU.cd_torihiki, '') AS cd_torihiki
		 ,COALESCE(ma_hin.cd_niuke_basho, '') AS cd_niuke_basho
		 ,COALESCE(ma_hin.nm_hinmei_ja, '') AS nm_hinmei_ja
		 ,COALESCE(ma_hin.nm_hinmei_en, '') AS nm_hinmei_en
		 ,COALESCE(ma_hin.nm_hinmei_zh, '') AS nm_hinmei_zh
		 ,COALESCE(ma_hin.nm_hinmei_vi, '') AS nm_hinmei_vi
		 ,ma_hin.cd_bunrui AS cd_bunrui
		 ,ma_bun.nm_bunrui AS nm_bunrui
		 ,ma_tan_nonyu.nm_tani AS nonyu_tani
		 ,ma_tan_shiyo.nm_tani AS shiyo_tani
		 ,ma_ko.nm_nisugata_hyoji AS nm_nisugata_hyoji
		 -- 重量
		 --,COALESCE(ma_ko.wt_nonyu, 0) * COALESCE(ma_ko.su_iri, 0)
		 --	* floor(NONYU.su_nonyu) AS juryo
		 ,COALESCE(ma_ko.wt_nonyu, 0) * COALESCE(ma_ko.su_iri, 0)
			* dbo.udf_NonyuHasuKanzan(
				ma_ko.cd_tani_nonyu, ma_hin.cd_tani_nonyu,
				NONYU.su_nonyu, NONYU.su_nonyu_hasu, @tani_kg, @tani_li) AS juryo
		FROM (
			-- カレンダーマスタ
			SELECT dt_hizuke
				,flg_kyujitsu
			FROM ma_calendar
			WHERE dt_hizuke >= @hizuke_from
			AND dt_hizuke < @hizuke_to
		) CALENDAR

		-- 納入トラン
		LEFT JOIN (SELECT cd_hinmei AS cd_hinmei
				,dt_nonyu AS dt_nonyu
				,SUM(su_nonyu) AS su_nonyu
				,cd_torihiki AS cd_torihiki
				,SUM(su_nonyu_hasu) AS su_nonyu_hasu
			FROM tr_nonyu
			WHERE dt_nonyu >= @hizuke_from
			AND dt_nonyu < @hizuke_to
			AND (
				(dt_nonyu < @today AND flg_yojitsu = @flg_jisseki)
				OR
				(dt_nonyu >= @today AND flg_yojitsu = @flg_yotei)
			)
			AND cd_hinmei
				IN (SELECT id FROM udf_SplitCommaValue(@param_hin))
			AND cd_torihiki
				IN (SELECT id FROM udf_SplitCommaValue(@param_torihiki))
			GROUP BY cd_hinmei, dt_nonyu, cd_torihiki
		) NONYU
		ON NONYU.dt_nonyu = CALENDAR.dt_hizuke

		-- 納入ワークトラン
		LEFT JOIN (SELECT cd_hinmei AS cd_hinmei
				,dt_nonyu AS dt_nonyu
				,su_nonyu AS su_nonyu
				,cd_torihiki AS cd_torihiki
			FROM wk_nonyu
			WHERE dt_nonyu >= @hizuke_from
			AND dt_nonyu < @hizuke_to
			AND cd_hinmei
				IN (SELECT id FROM udf_SplitCommaValue(@param_hin))
			AND cd_torihiki
				IN (SELECT id FROM udf_SplitCommaValue(@param_torihiki))
		) WORK
		ON WORK.dt_nonyu = CALENDAR.dt_hizuke
		AND WORK.cd_hinmei = NONYU.cd_hinmei

		-- 品名マスタ
		LEFT JOIN ma_hinmei ma_hin
		ON ma_hin.cd_hinmei = NONYU.cd_hinmei

		-- 原資材購入先マスタ
		LEFT JOIN ma_konyu ma_ko
		ON ma_ko.cd_hinmei = NONYU.cd_hinmei
		AND ma_ko.cd_torihiki = NONYU.cd_torihiki

		-- 単位マスタ：納入単位
		LEFT JOIN ma_tani ma_tan_nonyu
		ON ma_tan_nonyu.cd_tani = ma_ko.cd_tani_nonyu

		-- 単位マスタ：使用単位
		LEFT JOIN ma_tani ma_tan_shiyo
		ON ma_tan_shiyo.cd_tani = ma_hin.cd_tani_shiyo

		-- 分類マスタ
		LEFT JOIN ma_bunrui ma_bun
		ON ma_bun.cd_bunrui = ma_hin.cd_bunrui
		AND ma_bun.kbn_hin = ma_hin.kbn_hin

		WHERE
			NONYU.su_nonyu > 0 OR NONYU.su_nonyu_hasu > 0 OR WORK.su_nonyu > 0
		
	UNION
		
		-- ■ 納入ワークにしか存在しない情報を取得
		SELECT
		 CALENDAR.dt_hizuke AS dt_hizuke
		 ,WORK.cd_hinmei AS cd_hinmei

		 --,COALESCE(NONYU.su_nonyu, 0) AS su_nonyu
		 -- 納入単位がKgまたはLの場合は、端数を正規数に加算する
		 ,dbo.udf_NonyuHasuKanzan(
			wo_ko.cd_tani_nonyu, wo_hin.cd_tani_nonyu,
			NONYU.su_nonyu, NONYU.su_nonyu_hasu, @tani_kg, @tani_li) AS su_nonyu

		 ,COALESCE(WORK.su_nonyu, 0) AS su_nonyu_wo
		 ,COALESCE(WORK.cd_torihiki, '') AS cd_torihiki
		 ,COALESCE(wo_hin.cd_niuke_basho, '') AS cd_niuke_basho
		 ,COALESCE(wo_hin.nm_hinmei_ja, '') AS nm_hinmei_ja
		 ,COALESCE(wo_hin.nm_hinmei_en, '') AS nm_hinmei_en
		 ,COALESCE(wo_hin.nm_hinmei_zh, '') AS nm_hinmei_zh
		 ,COALESCE(wo_hin.nm_hinmei_vi, '') AS nm_hinmei_vi
		 ,wo_bun.cd_bunrui AS cd_bunrui
		 ,wo_bun.nm_bunrui AS nm_bunrui
		 ,wo_tan_nonyu.nm_tani AS nonyu_tani
		 ,wo_tan_shiyo.nm_tani AS shiyo_tani
		 ,wo_ko.nm_nisugata_hyoji AS nm_nisugata_hyoji
		 ,0 AS juryo
		FROM
		-- カレンダーマスタ
		(SELECT dt_hizuke
				,flg_kyujitsu
		 FROM ma_calendar
		 WHERE dt_hizuke >= @hizuke_from
		 AND dt_hizuke < @hizuke_to
		) CALENDAR

		-- 納入ワークトラン
		LEFT JOIN (SELECT cd_hinmei AS cd_hinmei
				,dt_nonyu AS dt_nonyu
				,su_nonyu AS su_nonyu
				,cd_torihiki AS cd_torihiki
			FROM wk_nonyu
			WHERE dt_nonyu >= @hizuke_from
			AND dt_nonyu < @hizuke_to
			AND cd_hinmei
				IN (SELECT id FROM udf_SplitCommaValue(@param_hin))
			AND cd_torihiki
				IN (SELECT id FROM udf_SplitCommaValue(@param_torihiki))
		) WORK
		ON WORK.dt_nonyu = CALENDAR.dt_hizuke

		-- 納入トラン
		LEFT JOIN (SELECT cd_hinmei AS cd_hinmei
				,dt_nonyu AS dt_nonyu
				,SUM(su_nonyu) AS su_nonyu
				--,SUM(su_nonyu) + SUM(su_nonyu_hasu) AS su_nonyu
				,SUM(su_nonyu_hasu) AS su_nonyu_hasu
				,cd_torihiki AS cd_torihiki
			FROM tr_nonyu
			WHERE dt_nonyu >= @hizuke_from
			AND dt_nonyu < @hizuke_to
			AND (
				(dt_nonyu < @today AND flg_yojitsu = @flg_jisseki)
				OR
				(dt_nonyu >= @today AND flg_yojitsu = @flg_yotei)
			)
			AND cd_hinmei
				IN (SELECT id FROM udf_SplitCommaValue(@param_hin))
			AND cd_torihiki
				IN (SELECT id FROM udf_SplitCommaValue(@param_torihiki))
			GROUP BY cd_hinmei, dt_nonyu, cd_torihiki
		) NONYU
		ON NONYU.dt_nonyu = CALENDAR.dt_hizuke
		AND NONYU.cd_hinmei = WORK.cd_hinmei

		-- 品名マスタ
		LEFT JOIN ma_hinmei wo_hin
		ON wo_hin.cd_hinmei = WORK.cd_hinmei

		-- 原資材購入先マスタ
		LEFT JOIN ma_konyu wo_ko
		ON wo_ko.cd_hinmei = WORK.cd_hinmei
		AND wo_ko.cd_torihiki = WORK.cd_torihiki

		-- 単位マスタ：納入単位
		LEFT JOIN ma_tani wo_tan_nonyu
		ON wo_tan_nonyu.cd_tani = wo_ko.cd_tani_nonyu

		-- 単位マスタ：使用単位
		LEFT JOIN ma_tani wo_tan_shiyo
		ON wo_tan_shiyo.cd_tani = wo_hin.cd_tani_shiyo

		-- 分類マスタ
		LEFT JOIN ma_bunrui wo_bun
		ON wo_bun.cd_bunrui = wo_hin.cd_bunrui
		AND wo_bun.kbn_hin = wo_hin.kbn_hin
		
		WHERE (NONYU.su_nonyu > 0 OR NONYU.su_nonyu_hasu > 0 OR WORK.su_nonyu > 0)
		AND NONYU.cd_hinmei IS NULL

	UNION

		-- ■ トランとワークに無い(納入予定の無い)品名情報を取得する
		SELECT
		 @today AS dt_hizuke
		 ,yotei_ko.cd_hinmei AS cd_hinmei

		 --,COALESCE(TR.su_nonyu, 0.0) AS su_nonyu
		 -- 納入単位がKgまたはLの場合は、端数を正規数に加算する
		 ,dbo.udf_NonyuHasuKanzan(
			yotei_ko.cd_tani_nonyu, ma_hin.cd_tani_nonyu,
			TR.su_nonyu, TR.su_nonyu_hasu, @tani_kg, @tani_li) AS su_nonyu

		 ,COALESCE(WORK.su_nonyu, 0.0) AS su_nonyu_wo
		 ,COALESCE(yotei_ko.cd_torihiki, '') AS cd_torihiki
		 ,COALESCE(ma_hin.cd_niuke_basho, '') AS cd_niuke_basho
		 ,COALESCE(ma_hin.nm_hinmei_ja, '') AS nm_hinmei_ja
		 ,COALESCE(ma_hin.nm_hinmei_en, '') AS nm_hinmei_en
		 ,COALESCE(ma_hin.nm_hinmei_zh, '') AS nm_hinmei_zh
		 ,COALESCE(ma_hin.nm_hinmei_vi, '') AS nm_hinmei_vi
		 ,ma_hin.cd_bunrui AS cd_bunrui
		 ,ma_bun.nm_bunrui AS nm_bunrui
		 ,ma_tan_nonyu.nm_tani AS nonyu_tani
		 ,ma_tan_shiyo.nm_tani AS shiyo_tani
		 ,yotei_ko.nm_nisugata_hyoji AS nm_nisugata_hyoji
		 ,0.0 AS juryo
		FROM (
			SELECT cd_hinmei
			,MIN(no_juni_yusen) AS no_juni_yusen
			FROM ma_konyu
			WHERE cd_hinmei
				IN (SELECT id FROM udf_SplitCommaValue(@param_hin))
			AND flg_mishiyo = @flg_mishiyo
			GROUP BY cd_hinmei
		) YUSEN

		-- 原資材購入先マスタ
		LEFT JOIN ma_konyu yotei_ko
		ON yotei_ko.cd_hinmei = YUSEN.cd_hinmei
		AND yotei_ko.no_juni_yusen = YUSEN.no_juni_yusen
		--AND yotei_ko.flg_mishiyo = @flg_mishiyo

		-- 納入トラン
		LEFT JOIN (
				SELECT cd_hinmei AS cd_hinmei
					,su_nonyu AS su_nonyu
					,su_nonyu_hasu AS su_nonyu_hasu
				FROM tr_nonyu
				WHERE dt_nonyu >= @hizuke_from
				AND dt_nonyu < @hizuke_to
				AND (
					(dt_nonyu < @today AND flg_yojitsu = @flg_jisseki)
					OR
					(dt_nonyu >= @today AND flg_yojitsu = @flg_yotei)
				)
				AND cd_hinmei
					IN (SELECT id FROM udf_SplitCommaValue(@param_hin))
				AND cd_torihiki
					IN (SELECT id FROM udf_SplitCommaValue(@param_torihiki))
				AND (su_nonyu > 0 OR su_nonyu_hasu > 0)
		) TR
		ON TR.cd_hinmei = yotei_ko.cd_hinmei

		-- 納入ワークトラン
		LEFT JOIN (
				SELECT cd_hinmei AS cd_hinmei
					,su_nonyu AS su_nonyu
				FROM wk_nonyu
				WHERE dt_nonyu >= @hizuke_from
				AND dt_nonyu < @hizuke_to
				AND cd_hinmei
					IN (SELECT id FROM udf_SplitCommaValue(@param_hin))
				AND cd_torihiki
					IN (SELECT id FROM udf_SplitCommaValue(@param_torihiki))
				AND su_nonyu > 0
		) WORK
		ON WORK.cd_hinmei = yotei_ko.cd_hinmei

		-- 品名マスタ
		LEFT JOIN ma_hinmei ma_hin
		ON ma_hin.cd_hinmei = yotei_ko.cd_hinmei

		-- 単位マスタ：納入単位
		LEFT JOIN ma_tani ma_tan_nonyu
		ON ma_tan_nonyu.cd_tani = yotei_ko.cd_tani_nonyu

		-- 単位マスタ：使用単位
		LEFT JOIN ma_tani ma_tan_shiyo
		ON ma_tan_shiyo.cd_tani = ma_hin.cd_tani_shiyo

		-- 分類マスタ
		LEFT JOIN ma_bunrui ma_bun
		ON ma_bun.cd_bunrui = ma_hin.cd_bunrui
		AND ma_bun.kbn_hin = ma_hin.kbn_hin

		--WHERE TR.su_nonyu IS NULL
		WHERE (TR.su_nonyu IS NULL OR TR.su_nonyu_hasu IS NULL)
		AND WORK.su_nonyu IS NULL
		AND yotei_ko.cd_torihiki IN (SELECT id FROM udf_SplitCommaValue(@param_torihiki))
	END

	-- =========================================================
	-- =========================================================
	--  「予定なしの品目も出力する」にチェックがない場合
	-- =========================================================
	-- =========================================================
	ELSE BEGIN
		-- =================================
		--  選択された品名コードがある場合
		-- =================================
		IF @param_hin <> ''
		BEGIN
			-- ■ 納入トラン情報＋納入ワークの情報を取得
			SELECT
			 CALENDAR.dt_hizuke AS dt_hizuke
			 ,NONYU.cd_hinmei AS cd_hinmei

			 --,floor(NONYU.su_nonyu) AS su_nonyu
			 -- 納入単位がKgまたはLの場合は、端数を正規数に加算する
			 ,dbo.udf_NonyuHasuKanzan(
				ma_ko.cd_tani_nonyu, ma_hin.cd_tani_nonyu,
				NONYU.su_nonyu, NONYU.su_nonyu_hasu, @tani_kg, @tani_li) AS su_nonyu

			 ,COALESCE(WORK.su_nonyu, 0) AS su_nonyu_wo
			 ,COALESCE(NONYU.cd_torihiki, '') AS cd_torihiki
			 ,COALESCE(ma_hin.cd_niuke_basho, '') AS cd_niuke_basho
			 ,COALESCE(ma_hin.nm_hinmei_ja, '') AS nm_hinmei_ja
			 ,COALESCE(ma_hin.nm_hinmei_en, '') AS nm_hinmei_en
			 ,COALESCE(ma_hin.nm_hinmei_zh, '') AS nm_hinmei_zh
			 ,COALESCE(ma_hin.nm_hinmei_vi, '') AS nm_hinmei_vi
			 ,ma_hin.cd_bunrui AS cd_bunrui
			 ,ma_bun.nm_bunrui AS nm_bunrui
			 ,ma_tan_nonyu.nm_tani AS nonyu_tani
			 ,ma_tan_shiyo.nm_tani AS shiyo_tani
			 ,ma_ko.nm_nisugata_hyoji AS nm_nisugata_hyoji
			 -- 重量
			 --,COALESCE(ma_ko.wt_nonyu, 0) * COALESCE(ma_ko.su_iri, 0)
			 --	* floor(NONYU.su_nonyu) AS juryo
			 ,COALESCE(ma_ko.wt_nonyu, 0) * COALESCE(ma_ko.su_iri, 0)
				* dbo.udf_NonyuHasuKanzan(
					ma_ko.cd_tani_nonyu, ma_hin.cd_tani_nonyu,
					NONYU.su_nonyu, NONYU.su_nonyu_hasu, @tani_kg, @tani_li) AS juryo
			FROM
			-- カレンダーマスタ
			(SELECT dt_hizuke
					,flg_kyujitsu
			 FROM ma_calendar
			 WHERE dt_hizuke >= @hizuke_from
			 AND dt_hizuke < @hizuke_to
			) CALENDAR

			-- 納入トラン
			LEFT JOIN (SELECT cd_hinmei AS cd_hinmei
					,dt_nonyu AS dt_nonyu
					,SUM(su_nonyu) AS su_nonyu
					,cd_torihiki AS cd_torihiki
					,SUM(su_nonyu_hasu) AS su_nonyu_hasu
				FROM tr_nonyu
				WHERE dt_nonyu >= @hizuke_from
				AND dt_nonyu < @hizuke_to
				AND (
					(dt_nonyu < @today AND flg_yojitsu = @flg_jisseki)
					OR
					(dt_nonyu >= @today AND flg_yojitsu = @flg_yotei)
				)
				AND cd_hinmei
					IN (SELECT id FROM udf_SplitCommaValue(@param_hin))
				AND cd_torihiki
					IN (SELECT id FROM udf_SplitCommaValue(@param_torihiki))
				GROUP BY cd_hinmei, dt_nonyu, cd_torihiki
			) NONYU
			ON NONYU.dt_nonyu = CALENDAR.dt_hizuke

			-- 納入ワークトラン
			LEFT JOIN (SELECT cd_hinmei AS cd_hinmei
					,dt_nonyu AS dt_nonyu
					,su_nonyu AS su_nonyu
					,cd_torihiki AS cd_torihiki
				FROM wk_nonyu
				WHERE dt_nonyu >= @hizuke_from
				AND dt_nonyu < @hizuke_to
				AND cd_hinmei
					IN (SELECT id FROM udf_SplitCommaValue(@param_hin))
				AND cd_torihiki
					IN (SELECT id FROM udf_SplitCommaValue(@param_torihiki))
			) WORK
			ON WORK.dt_nonyu = CALENDAR.dt_hizuke
			AND WORK.cd_hinmei = NONYU.cd_hinmei

			-- 品名マスタ
			LEFT JOIN ma_hinmei ma_hin
			ON ma_hin.cd_hinmei = NONYU.cd_hinmei

			-- 原資材購入先マスタ
			LEFT JOIN ma_konyu ma_ko
			ON ma_ko.cd_hinmei = NONYU.cd_hinmei
			AND ma_ko.cd_torihiki = NONYU.cd_torihiki

			-- 単位マスタ：納入単位
			LEFT JOIN ma_tani ma_tan_nonyu
			ON ma_tan_nonyu.cd_tani = ma_ko.cd_tani_nonyu

			-- 単位マスタ：使用単位
			LEFT JOIN ma_tani ma_tan_shiyo
			ON ma_tan_shiyo.cd_tani = ma_hin.cd_tani_shiyo

			-- 分類マスタ
			LEFT JOIN ma_bunrui ma_bun
			ON ma_bun.cd_bunrui = ma_hin.cd_bunrui
			AND ma_bun.kbn_hin = ma_hin.kbn_hin

			WHERE
				NONYU.su_nonyu > 0 OR WORK.su_nonyu > 0
			
		UNION
			
			-- ■ 納入ワークにしか存在しない情報を取得
			SELECT
			 CALENDAR.dt_hizuke AS dt_hizuke
			 ,WORK.cd_hinmei AS cd_hinmei

			 --,COALESCE(NONYU.su_nonyu, 0) AS su_nonyu
			 -- 納入単位がKgまたはLの場合は、端数を正規数に加算する
			 ,dbo.udf_NonyuHasuKanzan(
				wo_ko.cd_tani_nonyu, wo_hin.cd_tani_nonyu,
				NONYU.su_nonyu, NONYU.su_nonyu_hasu, @tani_kg, @tani_li) AS su_nonyu

			 ,COALESCE(WORK.su_nonyu, 0) AS su_nonyu_wo
			 ,COALESCE(WORK.cd_torihiki, '') AS cd_torihiki
			 ,COALESCE(wo_hin.cd_niuke_basho, '') AS cd_niuke_basho
			 ,COALESCE(wo_hin.nm_hinmei_ja, '') AS nm_hinmei_ja
			 ,COALESCE(wo_hin.nm_hinmei_en, '') AS nm_hinmei_en
			 ,COALESCE(wo_hin.nm_hinmei_zh, '') AS nm_hinmei_zh
			 ,COALESCE(wo_hin.nm_hinmei_vi, '') AS nm_hinmei_vi
			 ,wo_bun.cd_bunrui AS cd_bunrui
			 ,wo_bun.nm_bunrui AS nm_bunrui
			 ,wo_tan_nonyu.nm_tani AS nonyu_tani
			 ,wo_tan_shiyo.nm_tani AS shiyo_tani
			 ,wo_ko.nm_nisugata_hyoji AS nm_nisugata_hyoji
			 ,0 AS juryo
			FROM
			-- カレンダーマスタ
			(SELECT dt_hizuke
					,flg_kyujitsu
			 FROM ma_calendar
			 WHERE dt_hizuke >= @hizuke_from
			 AND dt_hizuke < @hizuke_to
			) CALENDAR

			-- 納入ワークトラン
			LEFT JOIN (SELECT cd_hinmei AS cd_hinmei
					,dt_nonyu AS dt_nonyu
					,su_nonyu AS su_nonyu
					,cd_torihiki AS cd_torihiki
				FROM wk_nonyu
				WHERE dt_nonyu >= @hizuke_from
				AND dt_nonyu < @hizuke_to
				AND cd_hinmei
					IN (SELECT id FROM udf_SplitCommaValue(@param_hin))
				AND cd_torihiki
					IN (SELECT id FROM udf_SplitCommaValue(@param_torihiki))
			) WORK
			ON WORK.dt_nonyu = CALENDAR.dt_hizuke

			-- 納入トラン
			LEFT JOIN (SELECT cd_hinmei AS cd_hinmei
					,dt_nonyu AS dt_nonyu
					,SUM(su_nonyu) AS su_nonyu
					--,SUM(su_nonyu) + SUM(su_nonyu_hasu) AS su_nonyu
					,SUM(su_nonyu_hasu) AS su_nonyu_hasu
					,cd_torihiki AS cd_torihiki
				FROM tr_nonyu
				WHERE dt_nonyu >= @hizuke_from
				AND dt_nonyu < @hizuke_to
				AND (
					(dt_nonyu < @today AND flg_yojitsu = @flg_jisseki)
					OR
					(dt_nonyu >= @today AND flg_yojitsu = @flg_yotei)
				)
				AND cd_hinmei
					IN (SELECT id FROM udf_SplitCommaValue(@param_hin))
				AND cd_torihiki
					IN (SELECT id FROM udf_SplitCommaValue(@param_torihiki))
				GROUP BY cd_hinmei, dt_nonyu, cd_torihiki
			) NONYU
			ON NONYU.dt_nonyu = CALENDAR.dt_hizuke
			AND NONYU.cd_hinmei = WORK.cd_hinmei

			-- 品名マスタ
			LEFT JOIN ma_hinmei wo_hin
			ON wo_hin.cd_hinmei = WORK.cd_hinmei

			-- 原資材購入先マスタ
			LEFT JOIN ma_konyu wo_ko
			ON wo_ko.cd_hinmei = WORK.cd_hinmei
			AND wo_ko.cd_torihiki = WORK.cd_torihiki

			-- 単位マスタ：納入単位
			LEFT JOIN ma_tani wo_tan_nonyu
			ON wo_tan_nonyu.cd_tani = wo_ko.cd_tani_nonyu

			-- 単位マスタ：使用単位
			LEFT JOIN ma_tani wo_tan_shiyo
			ON wo_tan_shiyo.cd_tani = wo_hin.cd_tani_shiyo

			-- 分類マスタ
			LEFT JOIN ma_bunrui wo_bun
			ON wo_bun.cd_bunrui = wo_hin.cd_bunrui
			AND wo_bun.kbn_hin = wo_hin.kbn_hin
			
			WHERE (NONYU.su_nonyu > 0 OR NONYU.su_nonyu_hasu > 0 OR WORK.su_nonyu > 0)
			AND NONYU.cd_hinmei IS NULL
		END

		-- =================================
		--  選択された品名コードがない
		-- =================================
		ELSE BEGIN
			-- ■ 納入トラン情報＋納入ワークの情報を取得
			SELECT
			 CALENDAR.dt_hizuke AS dt_hizuke
			 ,NONYU.cd_hinmei AS cd_hinmei

			 --,floor(NONYU.su_nonyu) AS su_nonyu
			 -- 納入単位がKgまたはLの場合は、端数を正規数に加算する
			 ,dbo.udf_NonyuHasuKanzan(
				ma_ko.cd_tani_nonyu, ma_hin.cd_tani_nonyu,
				NONYU.su_nonyu, NONYU.su_nonyu_hasu, @tani_kg, @tani_li) AS su_nonyu

			 ,COALESCE(WORK.su_nonyu, 0) AS su_nonyu_wo
			 ,COALESCE(NONYU.cd_torihiki, '') AS cd_torihiki
			 ,COALESCE(ma_hin.cd_niuke_basho, '') AS cd_niuke_basho
			 ,COALESCE(ma_hin.nm_hinmei_ja, '') AS nm_hinmei_ja
			 ,COALESCE(ma_hin.nm_hinmei_en, '') AS nm_hinmei_en
			 ,COALESCE(ma_hin.nm_hinmei_zh, '') AS nm_hinmei_zh
			 ,COALESCE(ma_hin.nm_hinmei_vi, '') AS nm_hinmei_vi
			 ,ma_hin.cd_bunrui AS cd_bunrui
			 ,ma_bun.nm_bunrui AS nm_bunrui
			 ,ma_tan_nonyu.nm_tani AS nonyu_tani
			 ,ma_tan_shiyo.nm_tani AS shiyo_tani
			 ,ma_ko.nm_nisugata_hyoji AS nm_nisugata_hyoji
			 -- 重量
			 --,COALESCE(ma_ko.wt_nonyu, 0) * COALESCE(ma_ko.su_iri, 0)
			 --	* floor(NONYU.su_nonyu) AS juryo
			 ,COALESCE(ma_ko.wt_nonyu, 0) * COALESCE(ma_ko.su_iri, 0)
				* dbo.udf_NonyuHasuKanzan(
					ma_ko.cd_tani_nonyu, ma_hin.cd_tani_nonyu,
					NONYU.su_nonyu, NONYU.su_nonyu_hasu, @tani_kg, @tani_li) AS juryo
			FROM
			-- カレンダーマスタ
			(SELECT dt_hizuke
					,flg_kyujitsu
			 FROM ma_calendar
			 WHERE dt_hizuke >= @hizuke_from
			 AND dt_hizuke < @hizuke_to
			) CALENDAR

			-- 納入トラン
			LEFT JOIN (SELECT cd_hinmei AS cd_hinmei
					,dt_nonyu AS dt_nonyu
					,SUM(su_nonyu) AS su_nonyu
					,cd_torihiki AS cd_torihiki
					,SUM(su_nonyu_hasu) AS su_nonyu_hasu
				FROM tr_nonyu
				WHERE dt_nonyu >= @hizuke_from
				AND dt_nonyu < @hizuke_to
				AND (
					(dt_nonyu < @today AND flg_yojitsu = @flg_jisseki)
					OR
					(dt_nonyu >= @today AND flg_yojitsu = @flg_yotei)
				)
				AND cd_torihiki
					IN (SELECT id FROM udf_SplitCommaValue(@param_torihiki))
				GROUP BY cd_hinmei, dt_nonyu, cd_torihiki
			) NONYU
			ON NONYU.dt_nonyu = CALENDAR.dt_hizuke

			-- 納入ワークトラン
			LEFT JOIN (SELECT cd_hinmei AS cd_hinmei
					,dt_nonyu AS dt_nonyu
					,su_nonyu AS su_nonyu
					,cd_torihiki AS cd_torihiki
				FROM wk_nonyu
				WHERE dt_nonyu >= @hizuke_from
				AND dt_nonyu < @hizuke_to
				AND cd_torihiki
					IN (SELECT id FROM udf_SplitCommaValue(@param_torihiki))
			) WORK
			ON WORK.dt_nonyu = CALENDAR.dt_hizuke
			AND WORK.cd_hinmei = NONYU.cd_hinmei

			-- 品名マスタ
			LEFT JOIN ma_hinmei ma_hin
			ON ma_hin.cd_hinmei = NONYU.cd_hinmei

			-- 原資材購入先マスタ
			LEFT JOIN ma_konyu ma_ko
			ON ma_ko.cd_hinmei = NONYU.cd_hinmei
			AND ma_ko.cd_torihiki = NONYU.cd_torihiki

			-- 単位マスタ：納入単位
			LEFT JOIN ma_tani ma_tan_nonyu
			ON ma_tan_nonyu.cd_tani = ma_ko.cd_tani_nonyu

			-- 単位マスタ：使用単位
			LEFT JOIN ma_tani ma_tan_shiyo
			ON ma_tan_shiyo.cd_tani = ma_hin.cd_tani_shiyo

			-- 分類マスタ
			LEFT JOIN ma_bunrui ma_bun
			ON ma_bun.cd_bunrui = ma_hin.cd_bunrui
			AND ma_bun.kbn_hin = ma_hin.kbn_hin

			WHERE
				NONYU.su_nonyu > 0 OR WORK.su_nonyu > 0
			
		UNION
			
			-- ■ 納入ワークにしか存在しない情報を取得
			SELECT
			 CALENDAR.dt_hizuke AS dt_hizuke
			 ,WORK.cd_hinmei AS cd_hinmei

			 --,COALESCE(NONYU.su_nonyu, 0) AS su_nonyu
			 -- 納入単位がKgまたはLの場合は、端数を正規数に加算する
			 ,dbo.udf_NonyuHasuKanzan(
				wo_ko.cd_tani_nonyu, wo_hin.cd_tani_nonyu,
				NONYU.su_nonyu, NONYU.su_nonyu_hasu, @tani_kg, @tani_li) AS su_nonyu

			 ,COALESCE(WORK.su_nonyu, 0) AS su_nonyu_wo
			 ,COALESCE(WORK.cd_torihiki, '') AS cd_torihiki
			 ,COALESCE(wo_hin.cd_niuke_basho, '') AS cd_niuke_basho
			 ,COALESCE(wo_hin.nm_hinmei_ja, '') AS nm_hinmei_ja
			 ,COALESCE(wo_hin.nm_hinmei_en, '') AS nm_hinmei_en
			 ,COALESCE(wo_hin.nm_hinmei_zh, '') AS nm_hinmei_zh
			 ,COALESCE(wo_hin.nm_hinmei_vi, '') AS nm_hinmei_vi
			 ,wo_bun.cd_bunrui AS cd_bunrui
			 ,wo_bun.nm_bunrui AS nm_bunrui
			 ,wo_tan_nonyu.nm_tani AS nonyu_tani
			 ,wo_tan_shiyo.nm_tani AS shiyo_tani
			 ,wo_ko.nm_nisugata_hyoji AS nm_nisugata_hyoji
			 ,0 AS juryo
			FROM
			-- カレンダーマスタ
			(SELECT dt_hizuke
					,flg_kyujitsu
			 FROM ma_calendar
			 WHERE dt_hizuke >= @hizuke_from
			 AND dt_hizuke < @hizuke_to
			) CALENDAR

			-- 納入ワークトラン
			LEFT JOIN (SELECT cd_hinmei AS cd_hinmei
					,dt_nonyu AS dt_nonyu
					,su_nonyu AS su_nonyu
					,cd_torihiki AS cd_torihiki
				FROM wk_nonyu
				WHERE dt_nonyu >= @hizuke_from
				AND dt_nonyu < @hizuke_to
				AND cd_torihiki
					IN (SELECT id FROM udf_SplitCommaValue(@param_torihiki))
			) WORK
			ON WORK.dt_nonyu = CALENDAR.dt_hizuke

			-- 納入トラン
			LEFT JOIN (SELECT cd_hinmei AS cd_hinmei
					,dt_nonyu AS dt_nonyu
					,SUM(su_nonyu) AS su_nonyu
					--,SUM(su_nonyu) + SUM(su_nonyu_hasu) AS su_nonyu
					,SUM(su_nonyu_hasu) AS su_nonyu_hasu
					,cd_torihiki AS cd_torihiki
				FROM tr_nonyu
				WHERE dt_nonyu >= @hizuke_from
				AND dt_nonyu < @hizuke_to
				AND (
					(dt_nonyu < @today AND flg_yojitsu = @flg_jisseki)
					OR
					(dt_nonyu >= @today AND flg_yojitsu = @flg_yotei)
				)
				AND cd_torihiki
					IN (SELECT id FROM udf_SplitCommaValue(@param_torihiki))
				GROUP BY cd_hinmei, dt_nonyu, cd_torihiki
			) NONYU
			ON NONYU.dt_nonyu = CALENDAR.dt_hizuke
			AND NONYU.cd_hinmei = WORK.cd_hinmei

			-- 品名マスタ
			LEFT JOIN ma_hinmei wo_hin
			ON wo_hin.cd_hinmei = WORK.cd_hinmei

			-- 原資材購入先マスタ
			LEFT JOIN ma_konyu wo_ko
			ON wo_ko.cd_hinmei = WORK.cd_hinmei
			AND wo_ko.cd_torihiki = WORK.cd_torihiki

			-- 単位マスタ：納入単位
			LEFT JOIN ma_tani wo_tan_nonyu
			ON wo_tan_nonyu.cd_tani = wo_ko.cd_tani_nonyu

			-- 単位マスタ：使用単位
			LEFT JOIN ma_tani wo_tan_shiyo
			ON wo_tan_shiyo.cd_tani = wo_hin.cd_tani_shiyo

			-- 分類マスタ
			LEFT JOIN ma_bunrui wo_bun
			ON wo_bun.cd_bunrui = wo_hin.cd_bunrui
			AND wo_bun.kbn_hin = wo_hin.kbn_hin
			
			WHERE (NONYU.su_nonyu > 0 OR NONYU.su_nonyu_hasu > 0 OR WORK.su_nonyu > 0)
			AND NONYU.cd_hinmei IS NULL
		END
	END


END
GO
