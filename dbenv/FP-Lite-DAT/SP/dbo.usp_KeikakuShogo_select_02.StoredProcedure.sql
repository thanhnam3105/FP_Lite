IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_KeikakuShogo_select_02') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_KeikakuShogo_select_02]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      <Author,,kobayashi.y>
-- Create date: <Create Date,,2013.10.04>
-- Last Update: <2023.03.12 BRC 橋本 #2307>
-- Description: <Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_KeikakuShogo_select_02]
	@no_lot_shikakari	VARCHAR(MAX)
	,@kbn_jotai_sonota	SMALLINT
	,@flg_mishiyo		SMALLINT
	,@not_cd_hinmei		VARCHAR(14)
	,@init_cd_tani		VARCHAR(10)
	,@count				INT OUTPUT
AS
BEGIN
	DECLARE @kbn_jotai_shikakari SMALLINT = 3; --状態区分（仕掛品）

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
			,udf.cd_futai
			,udf.wt_kihon
			,udf.wt_haigo_gokei
			,udf.su_settei
			,udf.su_settei_max
			,udf.su_settei_min
			,udf.flg_kowake_systemgai
		FROM udf_HaigoRecipeYukoHan(null, @flg_mishiyo, '') udf
		INNER JOIN su_keikaku_shikakari su
		ON su.no_lot_shikakari = @no_lot_shikakari
		AND su.cd_shikakari_hin = udf.cD_haigo
		AND su.dt_seizo >= udf.dt_from
		WHERE
			udf.no_han = (SELECT TOP 1 no_han
						  FROM udf_HaigoRecipeYukoHan(su.cd_shikakari_hin, @flg_mishiyo, su.dt_seizo)
						 )
    )

	SELECT DISTINCT
		shikakari.cd_shikakari_hin
		,shikakari.cd_shokuba
		,shikakari.cd_line
		,haigo.no_kotei
		,haigo.no_tonyu
		,haigo.cd_mark
		,shikakari.dt_seizo
		,shikakari.ritsu_keikaku
		,shikakari.ritsu_keikaku_hasu
		,haigo.cd_hinmei
		,haigo.kbn_hin
		,haigo.no_han
		,shikakari.no_lot_shikakari
		,shikakari.su_batch_keikaku
		,shikakari.su_batch_keikaku_hasu

		,haigo.ritsu_hiju_recipe
		,haigo.ritsu_budomari_recipe
		,haigo.wt_shikomi
		,haigo.kbn_kanzan AS kbn_kanzan_haigo
		,hinmei.kbn_kanzan AS kbn_kanzan_hinmei
		,haigo.wt_nisugata
		,haigo.wt_kowake AS wt_kowake_recipe
		,juryo_hin.wt_kowake AS wt_kowake_juryo_hin
		,juryo_kbn.wt_kowake AS wt_kowake_juryo_jyotai
		,shikakari.wt_haigo_keikaku
		,shikakari.wt_haigo_keikaku_hasu
		,haigo.nm_hinmei
		,haigo.wt_kihon
		,haigo.nm_haigo_ja
		,haigo.nm_haigo_en
		,haigo.nm_haigo_zh
		,haigo.nm_haigo_vi
		,CASE WHEN hinmei.kbn_kanzan IS NOT NULL THEN hinmei.kbn_kanzan ELSE @init_cd_tani END AS cd_tani_shiyo
		,tani.nm_tani
		,mark.nm_mark
		,haigo.cd_futai
		,futai.nm_futai
		-- for C#
		,mark.mark
		,mark.kbn_shubetsu
		,haigo.wt_haigo_gokei
		,CASE WHEN haigo.wt_haigo_gokei > 0 THEN shikakari.wt_haigo_keikaku / haigo.wt_haigo_gokei
			  ELSE haigo.wt_haigo_gokei
	     END AS haigo_bairitsu
		,CASE WHEN haigo.wt_haigo_gokei > 0 THEN shikakari.wt_haigo_keikaku_hasu / haigo.wt_haigo_gokei 
		      ELSE haigo.wt_haigo_gokei
		 END AS haigo_bairitsu_hasu
		,(
			SELECT 
				COUNT(cd_futai) AS cd_futai
			FROM ma_futai_kettei futai_kettei 
			WHERE 
				futai_kettei.cd_hinmei = haigo.cd_hinmei
				AND futai_kettei.cd_tani =
					(CASE WHEN hinmei.kbn_kanzan IS NOT NULL THEN hinmei.kbn_kanzan ELSE @init_cd_tani END)
				AND futai_kettei.flg_mishiyo = @flg_mishiyo
		) AS futaiCnt
		,haigo.su_settei
		,haigo.su_settei_max
		,haigo.su_settei_min
		,mark.flg_label
		,(select nm_kbn from udf_ChuiKankiShiyo(haigo.cd_hinmei,1,1,0,haigo.kbn_hin))as kbnAllergy
		,(select nm_chui_kanki from udf_ChuiKankiShiyo(haigo.cd_hinmei,1,1,0,haigo.kbn_hin))as nm_Allergy
		,(select nm_kbn from udf_ChuiKankiShiyo(haigo.cd_hinmei,9,1,0,haigo.kbn_hin))as kbnOther
		,(select nm_chui_kanki from udf_ChuiKankiShiyo(haigo.cd_hinmei,9,1,0,haigo.kbn_hin))as nm_Other
		,hinmei.nm_hinmei_ryaku
		,haigo.flg_kowake_systemgai
	FROM (
		SELECT cd_shikakari_hin
			,cd_shokuba
			,cd_line
			,dt_seizo
			,ritsu_keikaku
			,ritsu_keikaku_hasu
			,no_lot_shikakari
			,su_batch_keikaku
			,su_batch_keikaku_hasu
			,wt_haigo_keikaku
			,wt_haigo_keikaku_hasu
		FROM su_keikaku_shikakari
		WHERE no_lot_shikakari = @no_lot_shikakari 
	) shikakari

	-- 有効配合情報
	LEFT OUTER JOIN udf_haigo haigo
	ON shikakari.cd_shikakari_hin = haigo.cd_haigo

	-- 品区分名
	LEFT OUTER JOIN ma_kbn_hin hinkbn
	ON haigo.kbn_hin = hinkbn.kbn_hin

	-- 品名
	LEFT OUTER JOIN ma_hinmei hinmei
	ON haigo.cd_hinmei = hinmei.cd_hinmei

	-- 小分け重量（品コードごと）
	LEFT OUTER JOIN ma_juryo juryo_hin
	ON haigo.kbn_hin = juryo_hin.kbn_hin
	AND haigo.cd_hinmei = juryo_hin.cd_hinmei
	AND juryo_hin.kbn_jotai = @kbn_jotai_sonota

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
		AND
			juryo.kbn_jotai <> @kbn_jotai_sonota
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

	-- 単位
	LEFT OUTER JOIN ma_tani tani
	ON (CASE WHEN hinmei.kbn_kanzan IS NOT NULL THEN hinmei.kbn_kanzan ELSE @init_cd_tani END) = tani.cd_tani
	AND tani.flg_mishiyo = @flg_mishiyo

	-- 風袋
	LEFT OUTER JOIN ma_futai futai
	ON haigo.cd_futai = futai.cd_futai
	AND futai.flg_mishiyo = @flg_mishiyo

	ORDER BY
		shikakari.no_lot_shikakari
		,haigo.no_kotei
		,haigo.no_tonyu;

END

























GO
