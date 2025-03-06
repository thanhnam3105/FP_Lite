IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_GenshizaiShikakarihinShiyoIchiran_shizai_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_GenshizaiShikakarihinShiyoIchiran_shizai_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ============================================================================
-- Author:		<Author,,tsujita.s>
-- Create date: <Create Date,,2014.06.23>
-- Last Update: <2016.12.13 motojima.m>
-- Description:	<Description,,原資材・仕掛品使用一覧> 
-- 検索条件/品区分で「資材」が選択されたときの検索処理
--
-- ※※ 戻り値に修正がある場合 ※※
-- usp_GenshizaiShikakarihinShiyoIchiran_select_Resultは手で修正してください！
-- 共通で上記Resultを使用している原料・自家原料と仕掛品の検索SPは
-- 一時テーブルで返却している為、関数インポートの「列情報の取得」では取得されません
-- ＃Resultがあれば実行できます。
-- ============================================================================
CREATE PROCEDURE [dbo].[usp_GenshizaiShikakarihinShiyoIchiran_shizai_select]
	@con_kbn_hin		SMALLINT		-- 検索条件：品区分
	,@con_bunrui		VARCHAR(10)		-- 検索条件：分類
	--,@con_name		VARCHAR(50)		-- 検索条件：名称(品名コードor品名)
	,@con_name			NVARCHAR(50)	-- 検索条件：名称(品名コードor品名)
	,@dt_from			DATETIME		-- 検索条件：有効日付
	,@lang				VARCHAR(2)		-- 検索条件：ブラウザ言語
	,@kbn_hin_seihin	SMALLINT		-- 定数：品区分：製品
	,@kbn_hin_jikagen	SMALLINT		-- 定数：品区分：自家原料
	,@shiyoMishiyoFlg	BIT				-- 定数：未使用フラグ：使用
AS
BEGIN

	-- 有効版保持テーブル
	CREATE TABLE #yukoHanTable (
		cd_hinmei					VARCHAR(14)
		,no_han						DECIMAL(4,0)
	)

	-- ===========================
	--  ワークテーブルへのINSERT
	-- ===========================
	INSERT INTO #yukoHanTable (
		cd_hinmei
		,no_han
	)
	--SELECT
	--	yuko.cd_hinmei
	--	,yuko.no_han
	--FROM
	--	(
	--		SELECT
	--			shiyo.cd_hinmei
	--			,shiyo.no_han
	--			,yukoS.no_han_max
	--		FROM ma_shiyo_h shiyo
	--		LEFT OUTER JOIN
	--			(
	--				SELECT
	--					maxS.cd_hinmei
	--					,MAX(maxS.no_han) AS 'no_han_max'
	--				FROM ma_shiyo_h maxS
	--				WHERE
	--					maxS.flg_mishiyo = @shiyoMishiyoFlg
	--					AND maxS.dt_from <= @dt_from
	--				GROUP BY maxS.cd_hinmei
	--			) yukoS
	--		ON shiyo.cd_hinmei = yukoS.cd_hinmei
	--		AND shiyo.no_han = yukoS.no_han_max
	--	) yuko
	--WHERE
	--	@dt_from IS NULL
	--	OR (@dt_from IS NOT NULL AND yuko.no_han_max IS NOT NULL)

	-- 有効日付をもとに有効版の最大のものを取得して一時テーブルにINSERTします
	SELECT
		han.cd_hinmei
		,MAX(han.no_han) AS 'no_han'
	FROM ma_shiyo_h han
	INNER JOIN (
		-- 有効な有効日付を品名コードごとに取得
		SELECT
			shiyo.cd_hinmei
			,MAX(shiyo.dt_from) AS 'dt_from'
		FROM ma_shiyo_h shiyo
		WHERE
			(@dt_from IS NULL OR (@dt_from IS NOT NULL AND shiyo.dt_from <= @dt_from))
			AND shiyo.flg_mishiyo = @shiyoMishiyoFlg
		GROUP BY shiyo.cd_hinmei
	) yukoDate
	ON han.cd_hinmei = yukoDate.cd_hinmei
	AND han.dt_from = yukoDate.dt_from
	WHERE
		han.flg_mishiyo = @shiyoMishiyoFlg
	GROUP BY han.cd_hinmei


	-- 取得本処理
	SELECT
		kbn.nm_kbn_hin AS 'nm_kbn_hin'
		,genryo.cd_hinmei AS 'cd_hinmei'
		,genryo.nm_hinmei_ja AS 'nm_hinmei_ja'
		,genryo.nm_hinmei_en AS 'nm_hinmei_en'
		,genryo.nm_hinmei_zh AS 'nm_hinmei_zh'
		,genryo.nm_hinmei_vi AS 'nm_hinmei_vi'
		,genryo.flg_mishiyo AS 'mishiyo_hin'
		,'' AS 'cd_shikakari'
--**--
		,null AS 'wt_haigo'
		,shizai.su_shiyo AS 'su_shiyo'
--**--
		,shizai.no_han AS 'no_han'
		,'' AS 'nm_haigo_ja'
		,'' AS 'nm_haigo_en'
		,'' AS 'nm_haigo_zh'
		,'' AS 'nm_haigo_vi'
		,head.flg_mishiyo AS 'mishiyo_shikakari'
		,seihin.cd_hinmei AS 'cd_seihin'
		,seihin.nm_hinmei_ja AS 'nm_seihin_ja'
		,seihin.nm_hinmei_en AS 'nm_seihin_en'
		,seihin.nm_hinmei_zh AS 'nm_seihin_zh'
		,seihin.nm_hinmei_vi AS 'nm_seihin_vi'
		,seihin.flg_mishiyo AS 'mishiyo_seihin'
		,NULL AS 'dt_saishu_shikomi_yotei'
		,NULL AS 'dt_saishu_shikomi'
		,shizai_seizo_yotei.dt_seizo AS 'dt_saishu_seizo_yotei'
		,shizai_seizo_jisseki.dt_seizo AS 'dt_saishu_seizo'
	FROM (
		SELECT cd_hinmei
			,nm_hinmei_ja
			,nm_hinmei_en
			,nm_hinmei_zh
			,nm_hinmei_vi
			,flg_mishiyo
			,kbn_hin
		FROM ma_hinmei
		WHERE kbn_hin = @con_kbn_hin
		AND (LEN(@con_bunrui) = 0 OR cd_bunrui = @con_bunrui)
		AND (LEN(@con_name) = 0 OR
			(cd_hinmei like '%' + @con_name + '%'
				OR (@lang = 'ja' AND nm_hinmei_ja like '%' + @con_name + '%')
				OR (@lang = 'en' AND nm_hinmei_en like '%' + @con_name + '%')
				OR (@lang = 'zh' AND nm_hinmei_zh like '%' + @con_name + '%')
				OR (@lang = 'vi' AND nm_hinmei_vi like '%' + @con_name + '%')
			)
		)
	) genryo

	-- 品区分マスタ：品区分名を取得
	LEFT JOIN ma_kbn_hin kbn
	ON kbn.kbn_hin = genryo.kbn_hin

	-- 資材使用マスタボディ：検索条件の資材が紐付く資材使用マスタを取得
	LEFT JOIN (
		SELECT
			b.cd_hinmei
			,b.cd_shizai
			,b.su_shiyo 
			,b.no_han
		FROM ma_shiyo_b b
		INNER JOIN #yukoHanTable yuko
		ON b.cd_hinmei = yuko.cd_hinmei
		AND b.no_han = yuko.no_han
		GROUP BY b.cd_hinmei, b.cd_shizai,b.su_shiyo, b.no_han
	) shizai
	ON genryo.cd_hinmei = shizai.cd_shizai

	-- 資材使用マスタヘッダー：ボディに対するヘッダーを取得
	LEFT JOIN (
		SELECT
			h.cd_hinmei
			,h.no_han
			,h.flg_mishiyo
		FROM ma_shiyo_h h
		INNER JOIN #yukoHanTable yuko
		ON h.cd_hinmei = yuko.cd_hinmei
		AND h.no_han = yuko.no_han
	) head
	ON head.cd_hinmei = shizai.cd_hinmei
	AND head.no_han = shizai.no_han

	-- 品名マスタ：製品用の品名マスタ
	LEFT JOIN (
		SELECT
			cd_hinmei
			,cd_haigo
			,nm_hinmei_ja
			,nm_hinmei_en
			,nm_hinmei_zh
			,nm_hinmei_vi
			,flg_mishiyo
			,kbn_hin
		FROM ma_hinmei
		WHERE kbn_hin = @kbn_hin_seihin
		OR kbn_hin = @kbn_hin_jikagen
	) seihin
	ON seihin.cd_hinmei = shizai.cd_hinmei

	-- =================================================
	-- ■ shizai_seizo_yotei：製品_予定の資材情報
	-- =================================================
	LEFT JOIN (
		SELECT
			body.cd_hinmei
			,body.cd_shizai
			,MAX(seizo_yotei.dt_seizo) AS dt_seizo
			,body.no_han
			,seihin.cd_hinmei AS cd_seihin
		FROM (
			SELECT cd_hinmei
			FROM ma_hinmei
			WHERE kbn_hin = @con_kbn_hin
			AND (LEN(@con_bunrui) = 0 OR cd_bunrui = @con_bunrui)
			AND (LEN(@con_name) = 0 OR
				(cd_hinmei like '%' + @con_name + '%'
					OR (@lang = 'ja' AND nm_hinmei_ja like '%' + @con_name + '%')
					OR (@lang = 'en' AND nm_hinmei_en like '%' + @con_name + '%')
					OR (@lang = 'zh' AND nm_hinmei_zh like '%' + @con_name + '%')
					OR (@lang = 'vi' AND nm_hinmei_vi like '%' + @con_name + '%')
				)
			)
		) info_genryo

		-- 資材使用マスタボディ：検索条件の資材が紐付く資材使用マスタを取得
		LEFT JOIN (
			SELECT
				b.cd_hinmei
				,b.cd_shizai
				,b.no_han
			FROM ma_shiyo_b b
			INNER JOIN #yukoHanTable yuko
			ON b.cd_hinmei = yuko.cd_hinmei
			AND b.no_han = yuko.no_han
			GROUP BY b.cd_hinmei, b.cd_shizai, b.no_han
		) body
		ON info_genryo.cd_hinmei = body.cd_shizai

		-- 資材使用マスタヘッダー：有効日付（開始）を取得
		LEFT JOIN (
			SELECT
				h.cd_hinmei
				,h.no_han
				,h.dt_from
			FROM ma_shiyo_h h
			INNER JOIN #yukoHanTable yuko
			ON h.cd_hinmei = yuko.cd_hinmei
			AND h.no_han = yuko.no_han
		) head
		ON head.cd_hinmei = body.cd_hinmei
		AND head.no_han = body.no_han

		-- 資材使用マスタヘッダー：有効日付の終了日を取得
		LEFT JOIN (
			SELECT
				ma.cd_hinmei
				,ma.no_han
				,DATEADD(day, -1, MIN(sub.dt_from)) AS 'dt_to'
			FROM ma_shiyo_h ma
			INNER JOIN #yukoHanTable yuko
			ON ma.cd_hinmei = yuko.cd_hinmei
			AND ma.no_han = yuko.no_han

			LEFT JOIN ma_shiyo_h sub
			ON ma.cd_hinmei = sub.cd_hinmei
			AND ma.dt_from < sub.dt_from

			GROUP BY ma.cd_hinmei, ma.no_han
		) head_to
		ON head.cd_hinmei = head_to.cd_hinmei
		AND head.no_han = head_to.no_han

		-- 品名マスタ：製品用の品名マスタ
		LEFT JOIN (
			SELECT
				cd_hinmei
				--,cd_haigo
			FROM ma_hinmei
			WHERE kbn_hin = @kbn_hin_seihin
			OR kbn_hin = @kbn_hin_jikagen
		) seihin
		ON seihin.cd_hinmei = body.cd_hinmei

		-- 製造計画トラン(予定)：製造予定日用
		LEFT JOIN (
			SELECT
				cd_hinmei
				,dt_seizo
			FROM tr_keikaku_seihin
		) seizo_yotei
		ON seizo_yotei.cd_hinmei = seihin.cd_hinmei
		AND seizo_yotei.dt_seizo >= head.dt_from
		AND (head_to.dt_to IS NULL OR
				seizo_yotei.dt_seizo <= head_to.dt_to)

		GROUP BY body.cd_hinmei, body.cd_shizai, body.no_han, seihin.cd_hinmei

	) shizai_seizo_yotei
	ON shizai.cd_hinmei = shizai_seizo_yotei.cd_hinmei
	AND shizai.cd_shizai = shizai_seizo_yotei.cd_shizai
	AND shizai.no_han = shizai_seizo_yotei.no_han
	AND seihin.cd_hinmei = shizai_seizo_yotei.cd_seihin
	-- /////■ shizai_seizo_yotei：ここまで ■ /////

	-- =================================================
	-- ■ shizai_seizo_jisseki：製品_実績の資材情報
	-- =================================================
	LEFT JOIN (
		SELECT
			body.cd_hinmei
			,body.cd_shizai
			,MAX(seizo_jisseki.dt_seizo) AS dt_seizo
			,body.no_han
			,seihin.cd_hinmei AS cd_seihin
		FROM (
			SELECT cd_hinmei
			FROM ma_hinmei
			WHERE kbn_hin = @con_kbn_hin
			AND (LEN(@con_bunrui) = 0 OR cd_bunrui = @con_bunrui)
			AND (LEN(@con_name) = 0 OR
				(cd_hinmei like '%' + @con_name + '%'
					OR (@lang = 'ja' AND nm_hinmei_ja like '%' + @con_name + '%')
					OR (@lang = 'en' AND nm_hinmei_en like '%' + @con_name + '%')
					OR (@lang = 'zh' AND nm_hinmei_zh like '%' + @con_name + '%')
					OR (@lang = 'vi' AND nm_hinmei_vi like '%' + @con_name + '%')
				)
			)
		) info_genryo

		-- 資材使用マスタボディ：検索条件の資材が紐付く資材使用マスタを取得
		LEFT JOIN (
			SELECT
				b.cd_hinmei
				,b.cd_shizai
				,b.no_han
			FROM ma_shiyo_b b
			INNER JOIN #yukoHanTable yuko
			ON b.cd_hinmei = yuko.cd_hinmei
			AND b.no_han = yuko.no_han
			GROUP BY b.cd_hinmei, b.cd_shizai, b.no_han
		) body
		ON info_genryo.cd_hinmei = body.cd_shizai

		-- 資材使用マスタヘッダー：有効日付（開始）を取得
		LEFT JOIN (
			SELECT
				h.cd_hinmei
				,h.no_han
				,h.dt_from
			FROM ma_shiyo_h h
			INNER JOIN #yukoHanTable yuko
			ON h.cd_hinmei = yuko.cd_hinmei
			AND h.no_han = yuko.no_han
		) head
		ON head.cd_hinmei = body.cd_hinmei
		AND head.no_han = body.no_han

		-- 資材使用マスタヘッダー：有効日付の終了日を取得
		LEFT JOIN (
			SELECT
				ma.cd_hinmei
				,ma.no_han
				,DATEADD(day, -1, MIN(sub.dt_from)) AS 'dt_to'
			FROM ma_shiyo_h ma
			INNER JOIN #yukoHanTable yuko
			ON ma.cd_hinmei = yuko.cd_hinmei
			AND ma.no_han = yuko.no_han

			LEFT JOIN ma_shiyo_h sub
			ON ma.cd_hinmei = sub.cd_hinmei
			AND ma.dt_from < sub.dt_from

			GROUP BY ma.cd_hinmei, ma.no_han
		) head_to
		ON head.cd_hinmei = head_to.cd_hinmei
		AND head.no_han = head_to.no_han

		-- 品名マスタ：製品用の品名マスタ
		LEFT JOIN (
			SELECT
				cd_hinmei
				--,cd_haigo
			FROM ma_hinmei
			WHERE kbn_hin = @kbn_hin_seihin
			OR kbn_hin = @kbn_hin_jikagen
		) seihin
		ON seihin.cd_hinmei = body.cd_hinmei

		-- 製造計画トラン(実績)：製造日用
		LEFT JOIN (
			SELECT
				cd_hinmei
				,dt_seizo
			FROM tr_keikaku_seihin
			WHERE su_seizo_jisseki IS NOT NULL
		) seizo_jisseki
		ON seizo_jisseki.cd_hinmei = seihin.cd_hinmei
		AND seizo_jisseki.dt_seizo >= head.dt_from
		AND (head_to.dt_to IS NULL OR
				seizo_jisseki.dt_seizo <= head_to.dt_to)

		GROUP BY body.cd_hinmei, body.cd_shizai, body.no_han, seihin.cd_hinmei

	) shizai_seizo_jisseki
	ON shizai.cd_hinmei = shizai_seizo_jisseki.cd_hinmei
	AND shizai.cd_shizai = shizai_seizo_jisseki.cd_shizai
	AND shizai.no_han = shizai_seizo_jisseki.no_han
	AND seihin.cd_hinmei = shizai_seizo_jisseki.cd_seihin
	-- /////■ shizai_seizo_jisseki：ここまで ■ /////

	ORDER BY genryo.cd_hinmei, shizai.cd_hinmei, shizai.no_han , seihin.cd_hinmei

END
GO
