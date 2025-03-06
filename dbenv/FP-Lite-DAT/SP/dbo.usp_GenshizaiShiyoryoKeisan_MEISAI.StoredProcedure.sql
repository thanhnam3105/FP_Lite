IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_GenshizaiShiyoryoKeisan_MEISAI') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_GenshizaiShiyoryoKeisan_MEISAI]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===============================================
-- Author:		brc.nam
-- Create date: 2017.11.17
-- Last Update: 2017.11.17 brc.nam
-- Description:	庫出依頼画面 職場別EXCEL：明細取得
--    データ抽出処理
-- ===============================================
CREATE PROCEDURE [dbo].[usp_GenshizaiShiyoryoKeisan_MEISAI]
	  @con_hizuke			DATETIME		-- 検索条件：日付
	, @con_shokuba			VARCHAR(10)		-- 検索条件：職場
	, @flg_yojitsu			SMALLINT		-- 検索条件：予実フラグ：予定…0、実績…1

AS
BEGIN

	SET NOCOUNT ON

-- 使用予実トラン：（仕掛品計画紐付け）
SELECT 
	  SHIYO_SUM.cd_hinmei						-- 品名コード
	, SHIYO_SUM.dt_shiyo						-- 使用予定日
	, SHIYO_SUM.su_shiyo_sum AS SUM_su_shiyo	-- 使用予定量
	, SHIYO_SUM.cd_shikakari_hin AS code		-- 仕掛品コード
	, haigo.nm_haigo_en AS nm_hinmei_en			-- 配合名
	, haigo.nm_haigo_ja AS nm_hinmei_ja
	, haigo.nm_haigo_zh AS nm_hinmei_zh
	, haigo.nm_haigo_vi AS nm_hinmei_vi
	, shokuba.nm_shokuba						-- 職場名
FROM 
	(
		-- 使用予実トラン:サブクエリ
		SELECT 
			  tsy.cd_hinmei
			, tsy.dt_shiyo
			, SUM(su_shiyo) AS su_shiyo_sum
			, keikaku.cd_shokuba
			, keikaku.cd_shikakari_hin
			, keikaku.no_han
		FROM (
			SELECT *
			FROM tr_shiyo_yojitsu
			WHERE 
			  flg_yojitsu = @flg_yojitsu
			AND dt_shiyo = @con_hizuke
		    AND su_shiyo <> 0
			) tsy

		-- 仕掛品計画
		INNER JOIN (
				SELECT
					  keikaku.cd_shikakari_hin
					, keikaku.cd_shokuba
					, no_lot_shikakari
					, MAX(haigo.no_han) AS no_han
				FROM su_keikaku_shikakari keikaku
				INNER JOIN ma_haigo_mei haigo
					ON keikaku.cd_shikakari_hin = haigo.cd_haigo
					AND haigo.flg_mishiyo = 0
					AND haigo.dt_from <= keikaku.dt_seizo
				WHERE (LEN(@con_shokuba) = 0 OR keikaku.cd_shokuba = @con_shokuba)
				GROUP BY
					  keikaku.cd_shokuba
					, keikaku.cd_shikakari_hin
					, keikaku.no_lot_shikakari	
		    ) keikaku
			ON tsy.no_lot_shikakari = keikaku.no_lot_shikakari
		GROUP BY 
			  tsy.cd_hinmei
			, tsy.dt_shiyo
			, keikaku.cd_shokuba
			, keikaku.cd_shikakari_hin
			, keikaku.no_han
	) SHIYO_SUM

	-- 配合マスタ
	LEFT OUTER JOIN ma_haigo_mei haigo
		ON SHIYO_SUM.cd_shikakari_hin = haigo.cd_haigo
		AND SHIYO_SUM.no_han = haigo.no_han

	-- 職場マスタ
	LEFT OUTER JOIN ma_shokuba shokuba
		ON SHIYO_SUM.cd_shokuba = shokuba.cd_shokuba
		AND shokuba.flg_mishiyo = 0

UNION

-- 使用予実トラン：（製品計画紐付け）
SELECT 
	  SHIYO_SUM.cd_hinmei AS cd_hinmei			-- 品名コード
	, SHIYO_SUM.dt_shiyo AS dt_shiyo			-- 使用予定日
	, SHIYO_SUM.su_shiyo_sum AS SUM_su_shiyo	-- 使用予定量
	, SHIYO_SUM.code AS code					-- 品名コード（製品）
	, hinmei.nm_hinmei_en AS nm_hinmei_en		-- 品名
	, hinmei.nm_hinmei_ja AS nm_hinmei_ja
	, hinmei.nm_hinmei_zh AS nm_hinmei_zh
	, hinmei.nm_hinmei_vi AS nm_hinmei_vi
	, shokuba.nm_shokuba						-- 職場名
FROM
	(
		-- 使用予実トラン:サブクエリ
		SELECT 
			  tsy.cd_hinmei
			, tsy.dt_shiyo
			, SUM(su_shiyo) AS su_shiyo_sum
			, keikaku.cd_shokuba
			, keikaku.cd_hinmei AS code
		FROM (
			SELECT *
			FROM tr_shiyo_yojitsu
			WHERE
				flg_yojitsu = @flg_yojitsu
				AND dt_shiyo = @con_hizuke
				AND su_shiyo <> 0
			) tsy

		-- 製品計画
		INNER JOIN tr_keikaku_seihin keikaku
			ON tsy.no_lot_seihin = keikaku.no_lot_seihin
			AND (LEN(@con_shokuba) = 0 OR keikaku.cd_shokuba = @con_shokuba)
		GROUP BY 
			  tsy.cd_hinmei
			, tsy.dt_shiyo
			, keikaku.cd_shokuba
			, keikaku.cd_hinmei	
	) SHIYO_SUM

	-- 品名マスタ
	LEFT OUTER JOIN ma_hinmei hinmei
	ON SHIYO_SUM.code = hinmei.cd_hinmei
		AND hinmei.flg_mishiyo = 0

	-- 職場マスタ
	LEFT OUTER JOIN ma_shokuba shokuba
	ON SHIYO_SUM.cd_shokuba = shokuba.cd_shokuba
		AND shokuba.flg_mishiyo = 0

ORDER BY 
	  code
	, cd_hinmei

END