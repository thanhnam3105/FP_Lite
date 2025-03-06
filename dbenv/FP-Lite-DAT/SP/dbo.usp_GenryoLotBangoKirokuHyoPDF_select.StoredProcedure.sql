IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_GenryoLotBangoKirokuHyoPDF_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_GenryoLotBangoKirokuHyoPDF_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      <Author,,kobayashi.y>
-- Create date: <Create Date,,2013.09.25>
-- Last Update: <2017.01.19 kanehira.d>
-- Last Update: <2017.10.11 kanehira.d> 均等小分対応　配合レシピから比重を取得するように修正
-- Description: <Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_GenryoLotBangoKirokuHyoPDF_select]
	@no_lot_shikakari varchar(MAX)	-- 明細/仕掛品ロット番号
	,@kbn_jotai_sonota smallint		-- 定数：状態区分：その他
	,@flg_mishiyo smallint			-- 定数：未使用フラグ：使用
	,@kbn_hin_shikakari smallint	-- 定数：品区分：仕掛品
--	,@count int output
	,@cd_tani_shikakari VARCHAR(10) -- 定数：単位コード：Kg
	,@not_cd_hinmei VARCHAR(14)		-- 重量マスタの状態区分がその他の場合、品名コードはハイフンがセットされている
	,@kbn_jotai_shikakari SMALLINT	-- 定数：状態区分：仕掛品
	--,@comment VARCHAR(50)
	,@comment NVARCHAR(50)
	--,@mishiyo_comment VARCHAR(50)
	,@mishiyo_comment NVARCHAR(50)
AS
BEGIN

	--DECLARE @nm_tani_shikakari VARCHAR(12)
	DECLARE @nm_tani_shikakari NVARCHAR(12)
	SELECT
		@nm_tani_shikakari = tani_shikakari.nm_tani
	FROM ma_tani tani_shikakari
	WHERE
		tani_shikakari.cd_tani = @cd_tani_shikakari
		AND tani_shikakari.flg_mishiyo = @flg_mishiyo
	;

	-- 有効配合情報を取得
    WITH udf_haigo AS
    (
		SELECT
			su.dt_seizo
			,udf.cd_haigo 
			,udf.no_han
			,udf.dt_from
			,udf.nm_haigo_ja
			,udf.nm_haigo_en
			,udf.nm_haigo_zh
			,udf.nm_haigo_vi
			,udf.ritsu_hiju_recipe
			,udf.ritsu_budomari_recipe 
			,udf.cd_hinmei
			,udf.nm_hinmei
			,udf.wt_nisugata
			,udf.wt_kowake 
			,udf.flg_gassan_shikomi
			,udf.kbn_hin
			,udf.wt_shikomi
			,udf.kbn_kanzan
			,udf.no_kotei
			,udf.no_tonyu
			,udf.cd_mark
			,udf.wt_haigo_gokei
			,udf.nm_hinmei_ja
			,udf.nm_hinmei_en
			,udf.nm_hinmei_zh
			,udf.nm_hinmei_vi
			,udf.nm_hinmei_ryaku
			,udf.cd_bunrui
			,su.no_lot_shikakari
		FROM udf_HaigoRecipeYukoHan(null, @flg_mishiyo, '') udf
		INNER JOIN su_keikaku_shikakari su
		ON su.no_lot_shikakari IN (SELECT Id FROM udf_SplitCommaValue(@no_lot_shikakari))
		AND su.cd_shikakari_hin = udf.cD_haigo
		AND su.dt_seizo >= udf.dt_from
		AND su.wt_haigo_keikaku + su.wt_haigo_keikaku_hasu > 0
		WHERE
			udf.no_han = (SELECT TOP 1 no_han
						  FROM udf_HaigoRecipeYukoHan(su.cd_shikakari_hin, @flg_mishiyo, su.dt_seizo)
						 )
    )

	SELECT
		DISTINCT shikakari.no_lot_shikakari
		,shokuba.nm_shokuba
		--shokuba.nm_shokuba
		,line.nm_line
		--,shikakari.no_lot_shikakari
		,shikakari.dt_seizo
		,haigo.cd_haigo
		,haigo.cd_mark
		,haigo.nm_haigo_ja
		,haigo.nm_haigo_en
		,haigo.nm_haigo_zh
		,haigo.nm_haigo_vi
		,haigo.wt_shikomi
		,haigo.no_kotei
		,haigo.no_tonyu
		,haigo.kbn_kanzan AS kbn_kanzan_haigo
		--,yuko.no_han
		,haigo.no_han
		,hinkbn.nm_bunrui AS nm_kbn_hin
		,shikakari.wt_haigo_keikaku
		,shikakari.wt_haigo_keikaku_hasu
		,shikakari.ritsu_keikaku
		,shikakari.ritsu_keikaku_hasu
		,shikakari.su_batch_keikaku
		,shikakari.su_batch_keikaku_hasu
		,haigo.kbn_hin
		,haigo.cd_hinmei
		,haigo.nm_hinmei
		,haigo.ritsu_hiju_recipe
		,haigo.ritsu_budomari_recipe
		,haigo.wt_haigo_gokei
		,shikakari.wt_haigo_keikaku / haigo.wt_haigo_gokei AS haigo_bairitsu
		--,shikakari.ritsu_keikaku AS haigo_bairitsu
		,shikakari.wt_haigo_keikaku_hasu / haigo.wt_haigo_gokei AS haigo_bairitsu_hasu
		--,shikakari.ritsu_keikaku_hasu AS haigo_bairitsu_hasu
		-- 付属情報
		,mark.mark
		,mark.kbn_shubetsu
		,torihiki.nm_torihiki
		,hinmei.kbn_kanzan AS kbn_kanzan_hinmei
		,haigo.wt_nisugata
		,haigo.wt_kowake AS wt_kowake_recipe
		,juryo_hin.wt_kowake AS wt_kowake_juryo_hin
		,juryo_kbn.wt_kowake AS wt_kowake_juryo_jyotai
		--,tani.nm_tani AS nm_tani
		,CASE haigo.kbn_hin
			WHEN @kbn_hin_shikakari THEN @nm_tani_shikakari
			ELSE tani.nm_tani
		END AS nm_tani

		-- 略称がなければ品名(仕掛品の場合は配合名)を取得する
		-- ja版
		,CASE WHEN haigo.kbn_hin = @kbn_hin_shikakari
		 THEN (CASE WHEN maHaigo.nm_haigo_ryaku IS NULL THEN maHaigo.nm_haigo_ja
				ELSE maHaigo.nm_haigo_ryaku END)
		 ELSE (CASE WHEN haigo.nm_hinmei_ryaku IS NULL THEN haigo.nm_hinmei_ja
				ELSE haigo.nm_hinmei_ryaku END) END AS nm_hinmei_ja
		-- en版
		,CASE WHEN haigo.kbn_hin = @kbn_hin_shikakari
		 THEN (CASE WHEN maHaigo.nm_haigo_ryaku IS NULL THEN maHaigo.nm_haigo_en
				ELSE maHaigo.nm_haigo_ryaku END)
		 ELSE (CASE WHEN haigo.nm_hinmei_ryaku IS NULL THEN haigo.nm_hinmei_en
				ELSE haigo.nm_hinmei_ryaku END) END AS nm_hinmei_en
		-- zh版
		,CASE WHEN haigo.kbn_hin = @kbn_hin_shikakari
		 THEN (CASE WHEN maHaigo.nm_haigo_ryaku IS NULL THEN maHaigo.nm_haigo_zh
				ELSE maHaigo.nm_haigo_ryaku END)
		 ELSE (CASE WHEN haigo.nm_hinmei_ryaku IS NULL THEN haigo.nm_hinmei_zh
				ELSE haigo.nm_hinmei_ryaku END) END AS nm_hinmei_zh
		-- vi
		,CASE WHEN haigo.kbn_hin = @kbn_hin_shikakari
		 THEN (CASE WHEN maHaigo.nm_haigo_ryaku IS NULL THEN maHaigo.nm_haigo_vi
				ELSE maHaigo.nm_haigo_ryaku END)
		 ELSE (CASE WHEN haigo.nm_hinmei_ryaku IS NULL THEN haigo.nm_hinmei_vi
				ELSE haigo.nm_hinmei_ryaku END) END AS nm_hinmei_vi
		-- 優先順位：①　製品計画なし、　　　　　未使用コメント
		--           ②　製品計画あり(１つだけ)、製品コード
		--           ③　製品計画あり(複数)、　　複数使用コメント
		,CASE 
			WHEN seihin.no_lot_seihin IS NULL THEN @mishiyo_comment
			--WHEN count_shikakari.shikakari_lot_count = 1 THEN seihin.no_lot_seihin
			WHEN count_shikakari.shikakari_lot_count = 1 THEN seihin_hinmei.cd_hinmei
			ELSE @comment
		 END AS cd_seihin
		-- 優先順位：①　製品計画なし、　　　　　未使用コメント
		--           ②　製品計画あり(１つだけ)、製品名
		--           ③　製品計画あり(複数)、　　複数使用コメント   
		,CASE  
			WHEN seihin.no_lot_seihin IS NULL THEN @mishiyo_comment
			WHEN count_shikakari.shikakari_lot_count = 1 THEN  seihin_hinmei.nm_hinmei_ja
			ELSE @comment
		 END AS nm_seihin_hinmei_ja 
		-- 優先順位：①　製品計画なし、　　　　　未使用コメント
		--           ②　製品計画あり(１つだけ)、製品名
		--           ③　製品計画あり(複数)、　　複数使用コメント 
		,CASE  
			WHEN seihin.no_lot_seihin IS NULL THEN @mishiyo_comment
			WHEN count_shikakari.shikakari_lot_count = 1 THEN  seihin_hinmei.nm_hinmei_en
			ELSE @comment
		 END AS nm_seihin_hinmei_en 
		-- 優先順位：①　製品計画なし、　　　　　未使用コメント
		--           ②　製品計画あり(１つだけ)、製品名
		--           ③　製品計画あり(複数)、　　複数使用コメント   
		,CASE 
			WHEN seihin.no_lot_seihin IS NULL THEN @mishiyo_comment
			WHEN count_shikakari.shikakari_lot_count = 1 THEN  seihin_hinmei.nm_hinmei_zh
			ELSE @comment
		 END AS nm_seihin_hinmei_zh 
		 -- 優先順位：①　製品計画なし、　　　　　未使用コメント
		--           ②　製品計画あり(１つだけ)、製品名
		--           ③　製品計画あり(複数)、　　複数使用コメント 
		,CASE  
			WHEN seihin.no_lot_seihin IS NULL THEN @mishiyo_comment
			WHEN count_shikakari.shikakari_lot_count = 1 THEN  seihin_hinmei.nm_hinmei_vi
			ELSE @comment
		 END AS nm_seihin_hinmei_vi

	FROM (
		SELECT no_lot_shikakari
			,dt_seizo
			,cd_shikakari_hin
			,cd_shokuba
			,cd_line
			,wt_haigo_keikaku
			,wt_haigo_keikaku_hasu
			,ritsu_keikaku
			,ritsu_keikaku_hasu
			,su_batch_keikaku
			,su_batch_keikaku_hasu
		FROM su_keikaku_shikakari
		WHERE
			no_lot_shikakari IN (SELECT Id FROM udf_SplitCommaValue(@no_lot_shikakari))
			AND wt_haigo_keikaku + wt_haigo_keikaku_hasu > 0
	) shikakari

	-- 有効配合情報
	LEFT OUTER JOIN udf_haigo haigo
	ON shikakari.cd_shikakari_hin = haigo.cd_haigo
	AND shikakari.no_lot_shikakari = haigo.no_lot_shikakari
	--LEFT OUTER JOIN 
	--(
	--	SELECT
	--		shikakarisum_join.dt_seizo
	--		,shikakarisum_join.cd_shikakari_hin
	--		,shikakarisum_join.cd_shokuba
	--		,shikakarisum_join.cd_line
	--		,MAX(yukoHan.no_han) AS no_han
	--		,MAX(yukoHan.dt_from) AS dt_from
	--	FROM
	--	(
	--		SELECT
	--			udf.no_han
	--			,udf.dt_from
	--			,udf.cd_haigo
	--		FROM udf_HaigoRecipeYukoHan(null, @flg_mishiyo, null) udf
	--	) yukoHan
	--	LEFT OUTER JOIN su_keikaku_shikakari shikakarisum_join
	--	ON yukoHan.cd_haigo = shikakarisum_join.cd_shikakari_hin
	--	AND yukoHan.dt_from <= shikakarisum_join.dt_seizo
	--	GROUP BY  
	--		shikakarisum_join.dt_seizo
	--		,shikakarisum_join.cd_shikakari_hin
	--		,shikakarisum_join.cd_shokuba
	--		,shikakarisum_join.cd_line
	--) yuko
	--ON shikakari.dt_seizo = yuko.dt_seizo
	--AND shikakari.cd_shikakari_hin = yuko.cd_shikakari_hin
	--AND shikakari.cd_shokuba = yuko.cd_shokuba
	--AND shikakari.cd_line = yuko.cd_line
	--LEFT OUTER JOIN 
	--(
	--	SELECT
	--		udf.cd_haigo 
	--		,udf.no_han
	--		,udf.no_tonyu
	--		,udf.no_kotei
	--		,udf.dt_from
	--		,udf.nm_haigo_ja
	--		,udf.nm_haigo_en
	--		,udf.nm_haigo_zh
	--		,udf.nm_haigo_ryaku
	--		,udf.ritsu_budomari_recipe 
	--		,udf.cd_hinmei
	--		,udf.nm_hinmei
	--		,udf.wt_nisugata
	--		,udf.wt_kowake 
	--		,udf.flg_gassan_shikomi
	--		,udf.kbn_hin
	--		,udf.wt_shikomi
	--		,udf.kbn_kanzan
	--		,udf.wt_haigo_gokei
	--		,udf.cd_mark
	--		,udf.nm_hinmei_ja
	--		,udf.nm_hinmei_en
	--		,udf.nm_hinmei_zh
	--		,udf.nm_hinmei_ryaku
	--		,udf.cd_bunrui
	--	FROM udf_HaigoRecipeYukoHan(null, @flg_mishiyo, null) udf
	--) haigo
	--ON shikakari.cd_shikakari_hin = haigo.cd_haigo
	--AND yuko.dt_from = haigo.dt_from
	--AND yuko.no_han = yuko.no_han

	-- 仕掛品分類
	LEFT OUTER JOIN ma_bunrui hinkbn
	ON haigo.cd_bunrui = hinkbn.cd_bunrui
	AND hinkbn.kbn_hin = @kbn_hin_shikakari

	-- レシピ情報の品名マスタ
	LEFT OUTER JOIN ma_hinmei hinmei
	ON haigo.cd_hinmei = hinmei.cd_hinmei
	
	-- 単位マスタ
	LEFT OUTER JOIN ma_tani tani
	ON hinmei.cd_tani_shiyo = tani.cd_tani
	and tani.flg_mishiyo = @flg_mishiyo

	-- レシピ情報の配合名マスタ
	LEFT OUTER JOIN (
		SELECT cd_haigo
			,MAX(no_han) AS no_han
		FROM ma_haigo_mei
		WHERE flg_mishiyo = @flg_mishiyo
		GROUP BY cd_haigo
	) maHaigo_yuko
	ON haigo.cd_hinmei = maHaigo_yuko.cd_haigo
	LEFT OUTER JOIN	(
		SELECT cd_haigo
			,no_han
			,nm_haigo_ja
			,nm_haigo_en
			,nm_haigo_zh
			,nm_haigo_vi
			,nm_haigo_ryaku
		FROM ma_haigo_mei
		WHERE flg_mishiyo = @flg_mishiyo
	) maHaigo
	ON haigo.cd_hinmei = maHaigo.cd_haigo
	AND maHaigo.no_han = maHaigo_yuko.no_han
	
	-- 小分け重量（品コードごと）
	LEFT OUTER JOIN ma_juryo juryo_hin
	ON haigo.kbn_hin = juryo_hin.kbn_hin
	AND haigo.cd_hinmei = juryo_hin.cd_hinmei
	AND juryo_hin.kbn_jotai = @kbn_jotai_sonota

	-- 小分け重量（品区分ごと）
	--LEFT OUTER JOIN 
	--(
	--	SELECT 
	--		juryo.cd_hinmei
	--		,juryo.kbn_hin
	--		,juryo.kbn_jotai
	--		,juryo.wt_kowake
	--	FROM ma_juryo juryo
	--	WHERE
	--		juryo.kbn_jotai <> @kbn_jotai_sonota
	--) juryo_kbn
	--ON hinmei.kbn_hin = juryo_kbn.kbn_hin
	--AND hinmei.kbn_jotai = juryo_kbn.kbn_jotai
	-- 小分け重量（品区分ごと）
	LEFT OUTER JOIN 
	(
		SELECT 
			juryo.cd_hinmei
			,juryo.kbn_hin
			,juryo.kbn_jotai
			,juryo.wt_kowake
		FROM ma_juryo juryo
		WHERE
			juryo.cd_hinmei = @not_cd_hinmei
			AND juryo.kbn_jotai <> @kbn_jotai_sonota
	) juryo_kbn
	ON
	(
		(
			hinmei.kbn_hin = juryo_kbn.kbn_hin
			AND hinmei.kbn_jotai = juryo_kbn.kbn_jotai
		)
		 OR 
		(
			juryo_kbn.kbn_hin = haigo.kbn_hin
			AND juryo_kbn.kbn_jotai = @kbn_jotai_shikakari
		)
	)

	-- メーカー名
	LEFT OUTER JOIN ma_torihiki torihiki
	ON hinmei.cd_seizo = torihiki.cd_torihiki

	-- 職場名
	LEFT OUTER JOIN ma_shokuba shokuba
	ON shikakari.cd_shokuba = shokuba.cd_shokuba

	-- ライン名
	LEFT OUTER JOIN ma_line line
	ON shikakari.cd_shokuba = line.cd_shokuba
	AND shikakari.cd_line = line.cd_line

	-- マーク
	LEFT OUTER JOIN ma_mark mark
	ON haigo.cd_mark = mark.cd_mark
	
	-- 同じ仕掛品ロットNo.がいくつあるかカウントする
	LEFT OUTER JOIN (
						SELECT COUNT(keikaku_shikakari.no_lot_shikakari) AS shikakari_lot_count
						,keikaku_shikakari.no_lot_shikakari
						, MAX(no_lot_seihin) AS no_lot_seihin
						FROM tr_keikaku_shikakari keikaku_shikakari
						GROUP BY keikaku_shikakari.no_lot_shikakari
					)	count_shikakari
	ON shikakari.no_lot_shikakari = count_shikakari.no_lot_shikakari
	
	-- 製品トラン
	LEFT OUTER JOIN tr_keikaku_seihin seihin
	ON seihin.no_lot_seihin = count_shikakari.no_lot_seihin
	
	-- 品名マスタ（製品）
	LEFT OUTER JOIN ma_hinmei seihin_hinmei
	ON seihin.cd_hinmei = seihin_hinmei.cd_hinmei
					
	ORDER BY
		shikakari.no_lot_shikakari
		,haigo.no_kotei
		,haigo.no_tonyu
END

GO
