IF OBJECT_ID ('dbo.vw_tr_shiyo_yojitsu_01', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_tr_shiyo_yojitsu_01]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/************************************************************
機能		：配合の使用予実テーブルを作成するビュー
ビュー名	：vw_tr_shiyo_yojitsu_01
備考		：
作成日		：
更新日		：2016.12.07 k.cho
************************************************************/
CREATE VIEW [dbo].[vw_tr_shiyo_yojitsu_01]
AS
SELECT
   hin.nm_hinmei_ja
   ,hin.nm_hinmei_en
   ,hin.nm_hinmei_zh
   ,hin.nm_hinmei_vi
   --,sk.cd_shikakari_hin
   ,shikakari.cd_shikakari_hin
   --,sk.nm_haigo_ja
   --,shikakari.nm_haigo_ja
   ,ma_haigo.nm_haigo_ja
   --,sk.nm_haigo_en
   --,shikakari.nm_haigo_en
   ,ma_haigo.nm_haigo_en
   --,sk.nm_haigo_zh
   --,shikakari.nm_haigo_zh
   ,ma_haigo.nm_haigo_zh
   ,ma_haigo.nm_haigo_vi
   --,sy.su_shiyo
   ,CEILING(sy.su_shiyo*1000)/1000 AS su_shiyo
   --,se.cd_hinmei AS cd_seihin
   --,shikakari.cd_hinmei AS cd_seihin
   , tr_seihin.cd_hinmei AS cd_seihin
   --,se.nm_hinmei_ja AS nm_seihin_ja
   --,shikakari.nm_hinmei_ja AS nm_seihin_ja
   , ma_seihin.nm_hinmei_ja AS nm_seihin_ja
   --,se.nm_hinmei_en AS nm_seihin_en
   --,shikakari.nm_hinmei_en AS nm_seihin_en
   , ma_seihin.nm_hinmei_en AS nm_seihin_en
   --,se.nm_hinmei_zh AS nm_seihin_zh
   --,shikakari.nm_hinmei_zh AS nm_seihin_zh
   , ma_seihin.nm_hinmei_zh AS nm_seihin_zh
   , ma_seihin.nm_hinmei_vi AS nm_seihin_vi
   ,sy.cd_hinmei -- 基本的に抽出条件
   ,sy.dt_shiyo -- 基本的に抽出条件
   ,sy.flg_yojitsu -- 基本的に抽出条件
   --,ISNULL(sk.flg_mishiyo, 0) AS flg_mishiyo_shikakari -- 基本的に抽出条件
   --,ISNULL(shikakari.flg_mishiyo_shikakari, 0) AS flg_mishiyo_shikakari -- 基本的に抽出条件
   ,ISNULL(ma_haigo.flg_mishiyo, 0) AS flg_mishiyo_shikakari -- 基本的に抽出条件
   --,ISNULL(se.flg_mishiyo, 0) AS flg_mishiyo_seihin -- 基本的に抽出条件
   --,ISNULL(shikakari.flg_mishiyo_seihin, 0) AS flg_mishiyo_seihin -- 基本的に抽出条件
   ,ISNULL(ma_seihin.flg_mishiyo, 0) AS flg_mishiyo_seihin -- 基本的に抽出条件
   ,hin.flg_mishiyo AS flg_mishiyo_hinmei -- 基本的に抽出条件
--FROM tr_shiyo_yojitsu sy
FROM vw_tr_shiyo_yojitsu_02 sy

-- 原資材情報を取得する。
INNER JOIN ma_hinmei hin
	ON sy.cd_hinmei = hin.cd_hinmei

-- 製品情報を取得する。
LEFT OUTER JOIN tr_keikaku_seihin tr_seihin
	ON tr_seihin.no_lot_seihin = sy.no_lot_seihin
LEFT OUTER JOIN ma_hinmei ma_seihin
	ON ma_seihin.cd_hinmei = tr_seihin.cd_hinmei

-- 仕掛品情報を取得する。
LEFT OUTER JOIN (
	SELECT no_lot_shikakari
		 , cd_shikakari_hin
		 , MAX(no_han) AS no_han
	FROM ma_haigo_mei haigo_mei
	INNER JOIN 
		(SELECT su_shikakari.no_lot_shikakari
				, su_shikakari.cd_shikakari_hin
				, MAX(haigo.dt_from) AS dt_from
		FROM su_keikaku_shikakari su_shikakari
		INNER JOIN ma_haigo_mei haigo
			ON haigo.cd_haigo = su_shikakari.cd_shikakari_hin
			AND haigo.dt_from <= su_shikakari.dt_seizo
			AND haigo.flg_mishiyo = 0
		GROUP BY su_shikakari.no_lot_shikakari
				, su_shikakari.cd_shikakari_hin) shikakari_sub
	ON haigo_mei.cd_haigo = shikakari_sub.cd_shikakari_hin
	AND haigo_mei.dt_from = shikakari_sub.dt_from
	GROUP BY no_lot_shikakari
				, cd_shikakari_hin
	) shikakari
	ON shikakari.no_lot_shikakari = sy.no_lot_shikakari
LEFT OUTER JOIN ma_haigo_mei ma_haigo
	ON ma_haigo.cd_haigo = shikakari.cd_shikakari_hin
	AND ma_haigo.no_han = shikakari.no_han


--LEFT OUTER JOIN 
--(-- 仕掛品情報を取得する
    --SELECT
        --ks.no_lot_shikakari
        --,ks.cd_shikakari_hin
        --,hai.nm_haigo_ja
        --,hai.nm_haigo_en
        --,hai.nm_haigo_zh
        --,hai.flg_mishiyo
        --,MAX(hai.dt_from) AS dt_from
    --FROM su_keikaku_shikakari ks
    --LEFT OUTER JOIN ma_haigo_mei hai
    --ON ks.cd_shikakari_hin = hai.cd_haigo 
    --AND hai.dt_from <= ks.dt_seizo
    --GROUP BY 
        --ks.no_lot_shikakari
        --,ks.cd_shikakari_hin
        --,hai.nm_haigo_ja
        --,hai.nm_haigo_en
        --,hai.nm_haigo_zh
        --,hai.flg_mishiyo
--) sk
--ON sy.no_lot_shikakari = sk.no_lot_shikakari
--LEFT OUTER JOIN 
--(-- 製品情報を取得する
    --SELECT
        --ks.no_lot_seihin
        --,ks.cd_hinmei
        --,hin.nm_hinmei_ja
        --,hin.nm_hinmei_en
        --,hin.nm_hinmei_zh
        --,hin.flg_mishiyo
    --FROM tr_keikaku_seihin ks
    --LEFT OUTER JOIN ma_hinmei hin
    --ON ks.cd_hinmei = hin.cd_hinmei
    --UNION
    --SELECT
        --ks.no_lot_seihin
        --,ks.cd_hinmei
        --,hin.nm_hinmei_ja
        --,hin.nm_hinmei_en
        --,hin.nm_hinmei_zh
        --,hin.flg_mishiyo
    --FROM tr_keikaku_shikakari ks
    --LEFT OUTER JOIN ma_hinmei hin
    --ON ks.cd_hinmei = hin.cd_hinmei
--) se
--LEFT OUTER JOIN 
--(-- 製品・仕掛品情報を取得する
--	SELECT 
--        shikakari.no_lot_seihin
--        ,shikakari.cd_hinmei
--        ,hin.nm_hinmei_ja
--        ,hin.nm_hinmei_en
--        ,hin.nm_hinmei_zh
--        ,hin.flg_mishiyo AS flg_mishiyo_seihin
--        , shikakari.no_lot_shikakari
--        ,shikakari.cd_shikakari_hin
--        ,hai.nm_haigo_ja
--        ,hai.nm_haigo_en
--        ,hai.nm_haigo_zh
--        ,hai.flg_mishiyo AS flg_mishiyo_shikakari
--        ,MAX(hai.dt_from) AS dt_from
--    FROM tr_keikaku_shikakari shikakari
--	LEFT JOIN tr_keikaku_seihin seihin
--		ON seihin.no_lot_seihin = shikakari.no_lot_seihin
--	LEFT JOIN ma_hinmei hin
--		ON shikakari.cd_hinmei = hin.cd_hinmei
--    LEFT OUTER JOIN ma_haigo_mei hai
--    ON shikakari.cd_shikakari_hin = hai.cd_haigo 
--    AND hai.dt_from <= shikakari.dt_seizo
--    GROUP BY 
--        shikakari.no_lot_seihin
--        ,shikakari.cd_hinmei
--        ,hin.nm_hinmei_ja
--        ,hin.nm_hinmei_en
--        ,hin.nm_hinmei_zh
--        ,hin.flg_mishiyo 
--        , shikakari.no_lot_shikakari
--        ,shikakari.cd_shikakari_hin
--        ,hai.nm_haigo_ja
--        ,hai.nm_haigo_en
--        ,hai.nm_haigo_zh
--        ,hai.flg_mishiyo 
--) shikakari
--ON ISNULL(sy.no_lot_seihin,'') = ISNULL(shikakari.no_lot_seihin,'')
--AND ISNULL(sy.no_lot_shikakari,'') = ISNULL(shikakari.no_lot_shikakari,'')
--ON sy.no_lot_seihin = se.no_lot_seihin
---- 品名を取得する
--LEFT OUTER JOIN ma_hinmei hin
--ON sy.cd_hinmei = hin.cd_hinmei


GO
