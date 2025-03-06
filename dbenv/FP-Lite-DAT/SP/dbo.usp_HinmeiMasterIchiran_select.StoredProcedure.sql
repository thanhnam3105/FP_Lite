IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_HinmeiMasterIchiran_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_HinmeiMasterIchiran_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===============================================
-- Author:      tsujita.s
-- Create date: 2013.11.07
-- Update data: 2016.12.13 motojima.m 中文対応
-- Update Update: 2018.02.06 brc.tokumoto Q&B投入事故防対応
-- Last Update: 2019.12.09 nakamura.r エクセルにロケーションを追加
-- Description: 品名マスタ一覧
--    データ抽出処理
-- ===============================================
CREATE PROCEDURE [dbo].[usp_HinmeiMasterIchiran_select]
	@con_kbn_hin			smallint		-- 検索条件：品区分
	,@con_bunrui			varchar(10)		-- 検索条件：分類
	,@con_kbn_hokan			varchar(10)		-- 検索条件：保管区分
	--,@con_hinmei			varchar(50)		-- 検索条件：品名
	,@con_hinmei			nvarchar(50)	-- 検索条件：品名
	,@mishiyo_hyoji			smallint		-- 検索条件：未使用表示：あり(1)/なし(0)
	,@lang					varchar(2)		-- ブラウザ言語
	,@kbn_tori_uriagesaki	smallint		-- 取引先区分：売上先
	,@kbn_tori_seizomoto	smallint		-- 取引先区分：製造元
	,@flg_shiyo				smallint		-- 未使用フラグ：使用
	,@no_han				decimal(4,0)	-- 版番号
AS
BEGIN

	SET NOCOUNT ON

	SELECT
		---★共通項目
		hin.cd_hinmei AS cd_hinmei
		, hin.nm_hinmei_ja AS nm_hinmei_ja
		, hin.nm_hinmei_en AS nm_hinmei_en
		, hin.nm_hinmei_zh AS nm_hinmei_zh
		, hin.nm_hinmei_vi AS nm_hinmei_vi
		, hin.nm_hinmei_ryaku AS nm_hinmei_ryaku
		, hin.kbn_hin AS kbn_hin
		, khin.nm_kbn_hin AS nm_kbn_hin
		, hin.nm_nisugata_hyoji AS nm_nisugata_hyoji
		, hin.wt_nisugata_naiyo AS wt_nisugata_naiyo
		, hin.su_iri AS su_iri
		, hin.wt_ko AS wt_ko
		, hin.kbn_kanzan AS kbn_kanzan
		, kanzan.nm_tani AS nm_kbn_kanzan
		, hin.cd_tani_nonyu AS cd_tani_nonyu
		, nonyu.nm_tani AS tani_nonyu
		, hin.cd_tani_shiyo AS cd_tani_shiyo
		, shiyo.nm_tani AS tani_shiyo
		, hin.ritsu_hiju AS ritsu_hiju
		, hin.tan_ko AS tan_ko
		, hin.cd_bunrui AS cd_bunrui
		, bunrui.nm_bunrui AS nm_bunrui
		, hin.dd_shomi AS dd_shomi
		, hin.dd_kaifugo_shomi AS dd_kaifugo_shomi
		, hin.kbn_hokan AS kbn_hokan
		, hokan.nm_hokan_kbn AS nm_hokan
		, hin.kbn_kaifugo_hokan AS kbn_kaifugo_hokan
		, hokan2.nm_hokan_kbn AS nm_kaifugo_hokan
		, hin.kbn_jotai AS kbn_jotai
	    , ISNULL(jotai.nm_kbn_jotai, '') AS nm_kbn_jotai
		, hin.kbn_zei AS kbn_zei
		, zei.nm_zei AS nm_zei
		, hin.ritsu_budomari AS ritsu_budomari
		, hin.su_zaiko_min AS su_zaiko_min
		, hin.su_zaiko_max AS su_zaiko_max
		, hin.cd_niuke_basho AS cd_niuke_basho
		, niuke.nm_niuke AS nm_niuke
		, hin.dd_leadtime AS dd_leadtime
		, hin.biko AS biko
		, hin.flg_mishiyo AS flg_mishiyo
		, hin.dt_create AS dt_create
		, hin.dt_update AS dt_update
		, hin.cd_create AS cd_create
		, hin.cd_update AS cd_update
		, hin.dd_kaitogo_shomi AS dd_kaitogo_shomi
		, hin.kbn_kaitogo_hokan AS kbn_kaitogo_hokan
		, hokan3.nm_hokan_kbn AS nm_kaitogo_hokan
		
		---★製品・自家原の項目
		, hin.cd_hanbai_1 AS cd_hanbai_1
		, hanbai1.nm_torihiki AS nm_torihiki1
		, hin.cd_hanbai_2 AS cd_hanbai_2
		, hanbai2.nm_torihiki AS nm_torihiki2
		, hin.cd_haigo AS cd_haigo
		, haigo.nm_haigo_ja AS nm_haigo_ja
		, haigo.nm_haigo_en AS nm_haigo_en
		, haigo.nm_haigo_zh AS nm_haigo_zh
		, haigo.nm_haigo_vi AS nm_haigo_vi
		, hin.cd_jan AS cd_jan
		, hin.su_batch_dekidaka AS su_batch_dekidaka
		, hin.su_palette AS su_palette
		, hin.kin_romu AS kin_romu
		, hin.kin_keihi_cs AS kin_keihi_cs
		, hin.kbn_kuraire AS kbn_kuraire
		, ISNULL(kuraire.nm_kbn_kuraire, '') AS nm_kbn_kuraire
		, hin.tan_nonyu AS tan_nonyu
		, hin.flg_tenkai AS flg_tenkai

		---★原料・資材の項目
		, hin.cd_seizo AS cd_seizo
		, seizo.nm_torihiki AS nm_seizo
		, hin.cd_maker_hin AS cd_maker_hin
		, hin.su_hachu_lot_size AS su_hachu_lot_size
		, hin.cd_kura AS cd_kura
		, kura.nm_kura AS nm_kura
		, hin.ts AS ts
		, hin.cd_location AS cd_location
		, hin.dd_kotei AS dd_kotei
		, hin.cd_tani_nonyu_hasu AS cd_tani_nonyu_hasu
		, hin.flg_testitem
		, hin.flg_trace_taishogai
		, location.nm_location

	FROM ma_hinmei hin
	LEFT JOIN ma_kbn_hin khin
		ON hin.kbn_hin = khin.kbn_hin
	LEFT JOIN ma_tani nonyu
		ON hin.cd_tani_nonyu = nonyu.cd_tani
		AND nonyu.flg_mishiyo = @flg_shiyo
	LEFT JOIN ma_tani shiyo
		ON hin.cd_tani_shiyo = shiyo.cd_tani
		AND shiyo.flg_mishiyo = @flg_shiyo
	LEFT JOIN ma_bunrui bunrui
		ON hin.cd_bunrui = bunrui.cd_bunrui
		AND hin.kbn_hin = bunrui.kbn_hin
		AND bunrui.flg_mishiyo = @flg_shiyo
	LEFT JOIN ma_zei zei
		ON hin.kbn_zei = zei.kbn_zei
	LEFT JOIN ma_niuke niuke
		ON hin.cd_niuke_basho = niuke.cd_niuke_basho
		AND niuke.flg_mishiyo = @flg_shiyo
	LEFT JOIN ma_torihiki hanbai1
		ON hin.cd_hanbai_1 = hanbai1.cd_torihiki
		AND hanbai1.kbn_torihiki = @kbn_tori_uriagesaki
		AND hanbai1.flg_mishiyo = @flg_shiyo
	LEFT JOIN ma_torihiki hanbai2
		ON hin.cd_hanbai_2 = hanbai2.cd_torihiki
		AND hanbai2.kbn_torihiki = @kbn_tori_uriagesaki
		AND hanbai2.flg_mishiyo = @flg_shiyo	
	LEFT JOIN (
			SELECT
			ma.no_han AS no_han
			,ma.cd_haigo AS cd_haigo
			,ma.nm_haigo_ja AS nm_haigo_ja
			,ma.nm_haigo_en AS nm_haigo_en
			,ma.nm_haigo_zh AS nm_haigo_zh
			,ma.nm_haigo_vi AS nm_haigo_vi
			,ma.flg_mishiyo AS flg_mishiyo
		FROM
			ma_haigo_mei ma
		INNER JOIN (
			SELECT MAX(no_han) AS no_han
				,cd_haigo
			FROM ma_haigo_mei
			Where flg_mishiyo = @flg_shiyo
			GROUP BY cd_haigo
		) maxHan
		ON ma.cd_haigo = maxHan.cd_haigo
		AND ma.no_han = maxHan.no_han
		AND ma.flg_mishiyo = @flg_shiyo
		) haigo
		ON hin.cd_haigo = haigo.cd_haigo
	LEFT JOIN ma_torihiki seizo
		ON hin.cd_seizo = seizo.cd_torihiki
		AND seizo.kbn_torihiki = @kbn_tori_seizomoto
		AND seizo.flg_mishiyo = @flg_shiyo
	LEFT JOIN ma_kura kura
		ON hin.cd_kura = kura.cd_kura
		AND kura.flg_mishiyo = @flg_shiyo
	LEFT JOIN ma_kbn_hokan hokan
		ON hin.kbn_hokan = hokan.cd_hokan_kbn
		AND hokan.flg_mishiyo = @flg_shiyo
	LEFT JOIN ma_kbn_hokan hokan2
		ON hin.kbn_kaifugo_hokan = hokan2.cd_hokan_kbn
		AND hokan2.flg_mishiyo = @flg_shiyo
	LEFT JOIN ma_kbn_hokan hokan3
		ON hin.kbn_kaitogo_hokan = hokan3.cd_hokan_kbn
		AND hokan3.flg_mishiyo = @flg_shiyo
	LEFT JOIN ma_tani kanzan
		ON hin.kbn_kanzan = kanzan.cd_tani
		AND kanzan.flg_mishiyo = @flg_shiyo
	LEFT JOIN ma_kbn_jotai jotai
		ON hin.kbn_jotai = jotai.kbn_jotai
	LEFT JOIN ma_kbn_kuraire kuraire
		ON hin.kbn_kuraire = kuraire.kbn_kuraire
	LEFT JOIN ma_location location
	    ON hin.cd_location = location.cd_location

	WHERE
		-- 以下の条件については、指定された場合のみ検索条件に含める
		-- (指定されていない場合は、全件取得される)
		(LEN(ISNULL(@con_kbn_hin, '')) = 0 OR hin.kbn_hin = @con_kbn_hin)
		AND (LEN(ISNULL(@con_bunrui, '')) = 0 OR hin.cd_bunrui = @con_bunrui)
		AND (LEN(ISNULL(@con_kbn_hokan, '')) = 0 OR hin.kbn_hokan = @con_kbn_hokan)

		-- 多言語対応：言語によって検索対象の品名カラムを変更する
		AND (LEN(ISNULL(@con_hinmei, '')) = 0 OR
				(@lang = 'en' OR @lang = 'zh') OR
					hin.cd_hinmei like '%' + @con_hinmei + '%' OR hin.nm_hinmei_ja like '%' + @con_hinmei + '%'
			)
		AND (LEN(ISNULL(@con_hinmei, '')) = 0 OR
				(@lang = 'ja' OR @lang = 'zh') OR
					hin.cd_hinmei like '%' + @con_hinmei + '%' OR hin.nm_hinmei_en like '%' + @con_hinmei + '%'
			)
		AND (LEN(ISNULL(@con_hinmei, '')) = 0 OR
				(@lang = 'ja' OR @lang = 'en') OR
					hin.cd_hinmei like '%' + @con_hinmei + '%' OR hin.nm_hinmei_zh like '%' + @con_hinmei + '%'
			)
		AND (LEN(ISNULL(@con_hinmei, '')) = 0 OR
				(@lang = 'ja' OR @lang = 'zh') OR
					hin.cd_hinmei like '%' + @con_hinmei + '%' OR hin.nm_hinmei_vi like '%' + @con_hinmei + '%'
			)

		-- 未使用表示：なし(0)の場合、未使用フラグ=使用で絞り込む
		AND ((@mishiyo_hyoji = 1) OR hin.flg_mishiyo = @flg_shiyo)

	ORDER BY hin.cd_hinmei, hin.kbn_hin, hin.cd_bunrui


END


GO