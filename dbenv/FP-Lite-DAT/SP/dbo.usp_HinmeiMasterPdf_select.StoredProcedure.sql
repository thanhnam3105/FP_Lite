IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_HinmeiMasterPdf_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_HinmeiMasterPdf_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===============================================
-- Author:      tsujita.s
-- Create date: 2013.11.07
-- Update date: 2016.03.08 khang
-- Update Update: 2018.02.08 brc.tokumoto Q&B�������̖h�Ή�
-- Last Update: 2018.02.20 brc.kanehira Q&B�������̖h�Ή� �𓀌�ۊǋ敪�̒ǉ�
-- Description: �i���}�X�^PDF �f�[�^���o����
-- ===============================================
CREATE PROCEDURE [dbo].[usp_HinmeiMasterPdf_select]
	 @cd_hinmei				varchar(14)		-- ���������F�i���R�[�h
	,@kbn_tori_uriagesaki	smallint		-- �����敪�F�����
	,@kbn_tori_seizomoto	smallint		-- �����敪�F������
	,@flg_shiyo				smallint		-- ���g�p�t���O�F�g�p
	,@no_han				decimal(4,0)	-- �Ŕԍ�
AS
BEGIN

	SET NOCOUNT ON

	SELECT
		hin.cd_hinmei AS cd_hinmei
		, hin.nm_hinmei_ja AS nm_hinmei_ja
		, hin.nm_hinmei_en AS nm_hinmei_en
		, hin.nm_hinmei_zh AS nm_hinmei_zh
		, hin.nm_hinmei_vi AS nm_hinmei_vi
		, hin.nm_hinmei_ryaku AS nm_hinmei_ryaku
		, hin.kbn_hin
		, khin.nm_kbn_hin AS nm_kbn_hin
		, hin.nm_nisugata_hyoji AS nm_nisugata_hyoji
		, hin.wt_nisugata_naiyo AS wt_nisugata_naiyo
		, hin.su_iri AS su_iri
		, hin.wt_ko AS wt_ko
		, kanzan.nm_tani AS nm_kbn_kanzan
		, hin.kbn_kanzan AS kbn_kanzan
		, nonyu.nm_tani AS tani_nonyu
		, shiyo.nm_tani AS tani_shiyo
		, hin.ritsu_hiju AS ritsu_hiju
		, hin.tan_ko AS tan_ko
		, bunrui.nm_bunrui AS nm_bunrui
		, hin.dd_shomi AS dd_shomi
		, hin.dd_kaifugo_shomi AS dd_kaifugo_shomi
		, hin.dd_kaitogo_shomi AS dd_kaitogo_shomi
		, hokan.nm_hokan_kbn AS nm_hokan
		, hokan2.nm_hokan_kbn AS nm_kaifugo_hokan
		, hokan3.nm_hokan_kbn AS nm_kaitogo_hokan
	    , COALESCE(jotai.nm_kbn_jotai, '') AS nm_kbn_jotai
		, zei.nm_zei AS nm_zei
		, hin.ritsu_budomari AS ritsu_budomari
		, hin.su_zaiko_min AS su_zaiko_min
		, hin.su_zaiko_max AS su_zaiko_max
		, niuke.nm_niuke AS nm_niuke
		, hin.dd_leadtime AS dd_leadtime
		, hin.biko AS biko
		, hin.flg_mishiyo AS flg_mishiyo
		, hin.dt_create AS dt_create
		, hin.dt_update AS dt_update
		, hin.cd_create AS cd_create
		, hin.cd_update AS cd_update
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
		, COALESCE(kuraire.nm_kbn_kuraire, '') AS nm_kbn_kuraire
		, hin.tan_nonyu AS tan_nonyu
		, hin.flg_tenkai AS flg_tenkai
		, hin.cd_seizo AS cd_seizo
		, seizo.nm_torihiki AS nm_seizo
		, hin.cd_maker_hin AS cd_maker_hin
		, hin.su_hachu_lot_size AS su_hachu_lot_size
		, kura.nm_kura AS nm_kura
		, hin.dd_kotei AS dd_kotei
		, hasu.nm_tani AS nm_tani_nonyu_hasu
		, loc.nm_location AS location
		, hin.flg_trace_taishogai
	FROM
		ma_hinmei hin

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
	LEFT JOIN ma_haigo_mei haigo
		ON hin.cd_haigo = haigo.cd_haigo
		AND haigo.no_han = @no_han
		AND haigo.flg_mishiyo = @flg_shiyo
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
	LEFT JOIN ma_tani hasu
		ON hin.cd_tani_nonyu_hasu = hasu.cd_tani
		AND hasu.flg_mishiyo = @flg_shiyo
	LEFT JOIN ma_location loc
		ON hin.cd_location = loc.cd_location
		AND loc.flg_mishiyo = @flg_shiyo

	WHERE
		hin.cd_hinmei = @cd_hinmei


END

GO