IF OBJECT_ID ('dbo.vw_tr_shiyo_yojitsu_02', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_tr_shiyo_yojitsu_02]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/************************************************************
機能		：使用予実トランの仕掛品トラン単位でのビュー
ビュー名	：vw_tr_shiyo_yojitsu_02
備考		
作成日		：2016.11.15 k.cho
更新日		：2016.12.07 k.cho
************************************************************/
CREATE VIEW [dbo].[vw_tr_shiyo_yojitsu_02]
AS
	-- 原料・自家原料
	SELECT
		shiyo_yojitsu.flg_yojitsu
		, shiyo_yojitsu.dt_shiyo
		, tr_shikakari.no_lot_seihin
		, tr_shikakari.no_lot_shikakari
		, shiyo_yojitsu.cd_hinmei
		, CASE
			WHEN shiyo_yojitsu.flg_yojitsu = 0 AND su_shikakari.wt_shikomi_keikaku <> 0
				THEN shiyo_yojitsu.su_shiyo * (tr_shikakari.wt_shikomi_keikaku / su_shikakari.wt_shikomi_keikaku)
			WHEN shiyo_yojitsu.flg_yojitsu = 1 AND su_shikakari.wt_shikomi_jisseki <> 0
				THEN shiyo_yojitsu.su_shiyo * (tr_shikakari.wt_shikomi_jisseki / su_shikakari.wt_shikomi_jisseki)
			ELSE 0
		  END AS su_shiyo
	FROM tr_keikaku_shikakari tr_shikakari
	INNER JOIN
		(
			SELECT
				no_lot_shikakari
				, SUM(wt_shikomi_keikaku) AS wt_shikomi_keikaku
				, SUM(wt_shikomi_jisseki) AS wt_shikomi_jisseki
			FROM tr_keikaku_shikakari
			GROUP BY no_lot_shikakari
		) su_shikakari
		ON su_shikakari.no_lot_shikakari = tr_shikakari.no_lot_shikakari
	LEFT JOIN
		(
			SELECT
				flg_yojitsu
				, cd_hinmei
				, dt_shiyo
				, no_lot_shikakari
				, SUM(su_shiyo) AS su_shiyo
			FROM tr_shiyo_yojitsu
			WHERE no_lot_shikakari IS NOT NULL
			GROUP BY flg_yojitsu, cd_hinmei, dt_shiyo, no_lot_shikakari
		) shiyo_yojitsu
		ON shiyo_yojitsu.no_lot_shikakari = tr_shikakari.no_lot_shikakari
	WHERE shiyo_yojitsu.cd_hinmei IS NOT NULL
		AND shiyo_yojitsu.su_shiyo <> 0
	
	UNION ALL
	
	-- 資材
	SELECT 
		shiyo_yojitsu.flg_yojitsu
		, shiyo_yojitsu.dt_shiyo
		, shiyo_yojitsu.no_lot_seihin
		, shiyo_yojitsu.no_lot_shikakari
		, shiyo_yojitsu.cd_hinmei
		, shiyo_yojitsu.su_shiyo
	FROM tr_shiyo_yojitsu shiyo_yojitsu
	WHERE shiyo_yojitsu.no_lot_shikakari IS NULL
		AND shiyo_yojitsu.su_shiyo <> 0
GO