IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_PrintLabel_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_PrintLabel_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：ラベル印刷画面（荷受）　検索
ファイル名	：usp_PrintLabel_select
入力引数	：@no_niuke, @flg_mishiyo
出力引数	：
戻り値		：成功時[0] 失敗時[0以外のエラーコード]
作成日		：2013.11.09  ADMAX okuda.k
更新日		：2013.11.28  ADMAX onodera.s
更新日		：2017.04.04  BRC kurimoto.m
更新日		：2017.08.03  BRC cho.k
*****************************************************/
CREATE PROCEDURE [dbo].[usp_PrintLabel_select]
(
	@no_niuke		VARCHAR(14)  --荷受番号
	,@flg_mishiyo	SMALLINT     --未使用フラグ
)
AS
BEGIN
	SELECT
		label.nm_niuke
		,label.nm_hokan_kbn
		,label.cd_hinmei
		,label.nm_hinmei_en
		,label.nm_hinmei_ja
		,label.nm_hinmei_zh
		,label.nm_hinmei_vi
		,label.nm_nisugata_hyoji
		,label.nm_tani
		,label.cd_torihiki
		,label.nm_torihiki
		,label.dt_niuke
		,label.no_lot
		,label.dt_seizo
		,label.dt_kigen
		,label.su_nonyu_jitsu
		,label.su_nonyu_jitsu_hasu
		,label.no_denpyo
		,label.biko
		,label.cd_hinmei_maker
		,label.nm_kuni
		,label.cd_maker
		,label.nm_maker
		,label.cd_maker_kojo
		,label.nm_maker_kojo
		-- 非表示項目
		,label.su_nonyu
		,label.su_nonyu_hasu
		,label.dt_nonyu
		,MIN(label.no_seq) AS no_seq
		,(select nm_kbn from udf_ChuiKankiShiyo(label.cd_hinmei,1,1,0,label.kbn_hin))as kbnAllergy
		,(select nm_chui_kanki from udf_ChuiKankiShiyo(label.cd_hinmei,1,1,0,label.kbn_hin))as nm_Allergy
		,(select nm_kbn from udf_ChuiKankiShiyo(label.cd_hinmei,9,1,0,label.kbn_hin))as kbnOther
		,(select nm_chui_kanki from udf_ChuiKankiShiyo(label.cd_hinmei,9,1,0,label.kbn_hin))as nm_Other
		,label.cd_tani
		,label.nm_location
		,label.cd_tani_nonyu
	FROM (
	SELECT
		-- 表示項目
		ISNULL(ma_niuke.nm_niuke,'') AS nm_niuke
		,ISNULL(ma_kbn_hokan.nm_hokan_kbn,'') AS nm_hokan_kbn
		,ISNULL(tr_niuke.cd_hinmei,'') AS cd_hinmei
		,ISNULL(ma_hinmei.nm_hinmei_ja,'') AS nm_hinmei_ja
		,ISNULL(ma_hinmei.nm_hinmei_en,'') AS nm_hinmei_en
		,ISNULL(ma_hinmei.nm_hinmei_zh,'') AS nm_hinmei_zh
		,ISNULL(ma_hinmei.nm_hinmei_vi,'') AS nm_hinmei_vi
		--,ISNULL(ma_konyu.nm_nisugata_hyoji,'') AS nm_nisugata_hyoji
		,CASE
			WHEN ISNULL(ma_konyu.nm_nisugata_hyoji, '') <> '' THEN ma_konyu.nm_nisugata_hyoji
			WHEN ISNULL(ma_hinmei.nm_nisugata_hyoji, '') <> '' THEN ma_hinmei.nm_nisugata_hyoji
		    ELSE ''
		 END AS nm_nisugata_hyoji
		,ISNULL(ma_tani.nm_tani,'') AS nm_tani
		,ISNULL(tr_niuke.cd_torihiki,'') AS cd_torihiki
		,ISNULL(ma_torihiki.nm_torihiki,'') AS nm_torihiki
		,tr_niuke.dt_niuke
		,ISNULL(tr_niuke.no_lot,'') AS no_lot
		,tr_niuke.dt_seizo
		,tr_niuke.dt_kigen
		,ISNULL(tr_niuke.su_nonyu_jitsu,0) AS su_nonyu_jitsu
		,ISNULL(tr_niuke.su_nonyu_jitsu_hasu,0) AS su_nonyu_jitsu_hasu
		,ISNULL(tr_niuke.no_denpyo,'') AS no_denpyo
		,ISNULL(tr_niuke.biko,'') AS biko
		,ISNULL(tr_niuke.cd_hinmei_maker,'') AS cd_hinmei_maker
		,ISNULL(tr_niuke.nm_kuni,'') AS nm_kuni
		,ISNULL(tr_niuke.cd_maker,'') AS cd_maker
		,ISNULL(tr_niuke.nm_maker,'') AS nm_maker
		,ISNULL(tr_niuke.cd_maker_kojo,'') AS cd_maker_kojo
		,ISNULL(tr_niuke.nm_maker_kojo,'') AS nm_maker_kojo
		-- 非表示項目
		,ISNULL(tr_nonyu.su_nonyu,0) AS su_nonyu
		,ISNULL(tr_nonyu.su_nonyu_hasu,0) AS su_nonyu_hasu
		,tr_niuke.dt_nonyu AS dt_nonyu
		--,MIN(no_seq) AS no_seq
		, tr_niuke.no_seq
		--,(select nm_kbn from udf_ChuiKankiShiyo(tr_niuke.cd_hinmei,1,1,0,tr_niuke.kbn_hin))as kbnAllergy
		--,(select nm_chui_kanki from udf_ChuiKankiShiyo(tr_niuke.cd_hinmei,1,1,0,tr_niuke.kbn_hin))as nm_Allergy
		--,(select nm_kbn from udf_ChuiKankiShiyo(tr_niuke.cd_hinmei,9,1,0,tr_niuke.kbn_hin))as kbnOther
		--,(select nm_chui_kanki from udf_ChuiKankiShiyo(tr_niuke.cd_hinmei,9,1,0,tr_niuke.kbn_hin))as nm_Other
		,ma_tani.cd_tani AS cd_tani
		,ISNULL(ma_location.nm_location,'') AS nm_location
		,ISNULL ( ma_konyu.cd_tani_nonyu, ma_hinmei.cd_tani_nonyu ) AS cd_tani_nonyu
		, ma_hinmei.kbn_hin
		, tr_niuke.no_niuke
	FROM tr_niuke 
	LEFT OUTER JOIN ma_niuke
	ON tr_niuke.cd_niuke_basho = ma_niuke.cd_niuke_basho
	AND ma_niuke.flg_mishiyo = @flg_mishiyo
	LEFT OUTER JOIN ma_hinmei
	ON tr_niuke.cd_hinmei = ma_hinmei.cd_hinmei
	AND ma_hinmei.flg_mishiyo = @flg_mishiyo
	LEFT OUTER JOIN ma_kbn_hokan
	ON ma_hinmei.kbn_hokan = ma_kbn_hokan.cd_hokan_kbn
	AND ma_kbn_hokan.flg_mishiyo = @flg_mishiyo
	LEFT OUTER JOIN ma_torihiki
	ON tr_niuke.cd_torihiki = ma_torihiki.cd_torihiki
	AND ma_torihiki.flg_mishiyo = @flg_mishiyo
	LEFT OUTER JOIN ma_konyu
	ON ma_konyu.cd_hinmei = tr_niuke.cd_hinmei
	AND ma_konyu.cd_torihiki = tr_niuke.cd_torihiki
	AND ma_konyu.flg_mishiyo = @flg_mishiyo
	LEFT OUTER JOIN ma_tani
	ON ma_tani.cd_tani = ma_konyu.cd_tani_nonyu
	LEFT OUTER JOIN tr_nonyu
	--ON tr_niuke.cd_hinmei = tr_nonyu.cd_hinmei
	--AND tr_niuke.dt_niuke = tr_nonyu.dt_nonyu
	--AND tr_niuke.cd_torihiki = tr_nonyu.cd_torihiki
	ON tr_niuke.no_nonyu = tr_nonyu.no_nonyu
	LEFT OUTER JOIN ma_location
	ON ma_location.cd_location = ma_hinmei.cd_location
	AND ma_location.flg_mishiyo = @flg_mishiyo
	--WHERE
	--	tr_niuke.no_seq =
	--	(
	--		SELECT
	--			MIN(no_seq) AS no_seq
	--		FROM tr_niuke
	--	)
	--	AND tr_niuke.no_niuke = @no_niuke
	--GROUP BY
	--	nm_niuke
	--	,nm_hokan_kbn
	--	,tr_niuke.cd_hinmei
	--	,ma_hinmei.nm_hinmei_en
	--	,ma_hinmei.nm_hinmei_ja
	--	,ma_hinmei.nm_hinmei_zh
	--	,ma_kyonu.nm_nisugata_hyoji
	--	,ma_tani.nm_tani
	--	,tr_niuke.cd_torihiki
	--	,ma_torihiki.nm_torihiki
	--	,tr_niuke.dt_niuke
	--	,tr_niuke.no_lot
	--	,tr_niuke.dt_seizo
	--	,tr_niuke.dt_kigen
	--	,tr_niuke.su_nonyu_jitsu
	--	,tr_niuke.su_nonyu_jitsu_hasu
	--	,tr_niuke.no_denpyo
	--	,tr_niuke.biko
	--	,tr_niuke.cd_hinmei_maker
	--	,tr_niuke.nm_kuni
	--	,tr_niuke.cd_maker
	--	,tr_niuke.nm_maker
	--	,tr_niuke.cd_maker_kojo
	--	,tr_niuke.nm_maker_kojo
	--	,tr_nonyu.su_nonyu
	--	,tr_nonyu.su_nonyu_hasu
	--	,tr_niuke.dt_nonyu
	--	,tr_niuke.kbn_hin
	--	,ma_tani.cd_tani
	--	,ma_location.nm_location
	--	,ISNULL ( ma_konyu.cd_tani_nonyu, ma_hinmei.cd_tani_nonyu )
	) label
	WHERE
		label.no_seq =
		(
			SELECT
				MIN(no_seq) AS no_seq
			FROM tr_niuke
		)
		AND label.no_niuke = @no_niuke
	GROUP BY
		label.nm_niuke
		,label.nm_hokan_kbn
		,label.cd_hinmei
		,label.nm_hinmei_en
		,label.nm_hinmei_ja
		,label.nm_hinmei_zh
		,label.nm_hinmei_vi
		,label.nm_nisugata_hyoji
		,label.nm_tani
		,label.cd_torihiki
		,label.nm_torihiki
		,label.dt_niuke
		,label.no_lot
		,label.dt_seizo
		,label.dt_kigen
		,label.su_nonyu_jitsu
		,label.su_nonyu_jitsu_hasu
		,label.no_denpyo
		,label.biko
		,label.cd_hinmei_maker
		,label.nm_kuni
		,label.cd_maker
		,label.nm_maker
		,label.cd_maker_kojo
		,label.nm_maker_kojo
		,label.su_nonyu
		,label.su_nonyu_hasu
		,label.dt_nonyu
		,label.kbn_hin
		,label.cd_tani
		,label.nm_location
		,label.cd_tani_nonyu
END

GO
