IF OBJECT_ID ('dbo.vw_tr_keikaku_check', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_tr_keikaku_check]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/*****************************************************
機能  ：実績、計画確定チェックVIEW
ファイル名 ：vw_tr_keikaku_check
作成日  ：2016.10.12 cho.k
更新日  ：
*****************************************************/
CREATE VIEW [dbo].[vw_tr_keikaku_check]
AS
	

	SELECT DISTINCT
			no_lot_seihin						-- 製品ロット番号
		,	no_lot_shikakari					-- 仕掛品ロット番号
		,	flg_seihin_jisseki					-- 製造実績フラグ
		,	CASE flg_jisseki0 + flg_jisseki1 + flg_jisseki2 + flg_jisseki3 + flg_jisseki4
				+ flg_jisseki5 + flg_jisseki6 + flg_jisseki7 + flg_jisseki8 + flg_jisseki9
				WHEN 0 THEN 0
				ELSE 1
			END AS flg_shikakari_jisseki		-- 仕込実績フラグ：配下の仕掛品いずれかのflg_jissekiが1ならば1、それ以外なら0
		,	CASE flg_shikomi0 + flg_shikomi1 + flg_shikomi2 + flg_shikomi3 + flg_shikomi4
				+ flg_shikomi5 + flg_shikomi6 + flg_shikomi7 + flg_shikomi8 + flg_shikomi9
				WHEN 0 THEN 0
				ELSE 1
			END AS flg_shikomi					-- 仕込計画確定フラグ：配下の仕掛品いずれかのflg_shikomiが1ならば1、それ以外なら0
		,	CASE flg_label0 + flg_label1 + flg_label2 + flg_label3 + flg_label4
				+ flg_label5 + flg_label6 + flg_label7 + flg_label8 + flg_label9
				WHEN 0 THEN 0
				ELSE 1
			END AS flg_label					-- 仕込計画確定フラグ：配下の仕掛品いずれかのflg_labelが1ならば1、それ以外なら0
		,	CASE flg_label_hasu0 + flg_label_hasu1 + flg_label_hasu2 + flg_label_hasu3 + flg_label_hasu4
				+ flg_label_hasu5 + flg_label_hasu6 + flg_label_hasu7 + flg_label_hasu8 + flg_label_hasu9
				WHEN 0 THEN 0
				ELSE 1
			END AS flg_label_hasu				-- 仕込計画確定フラグ：配下の仕掛品いずれかのflg_label_hasuが1ならば1、それ以外なら0

	FROM (
		SELECT
				shikakari.no_lot_seihin
			,	shikakari.no_lot_shikakari
			,	ISNULL(seihin.flg_jisseki, 0)		AS flg_seihin_jisseki
			,	ISNULL(shikomi.flg_jisseki, 0)		AS flg_jisseki0
			,	ISNULL(shikomi.flg_shikomi, 0)		AS flg_shikomi0
			,	ISNULL(shikomi.flg_label, 0)		AS flg_label0
			,	ISNULL(shikomi.flg_label_hasu, 0)	AS flg_label_hasu0
			,	ISNULL(shikomi1.flg_jisseki, 0)		AS flg_jisseki1
			,	ISNULL(shikomi1.flg_shikomi, 0)		AS flg_shikomi1
			,	ISNULL(shikomi1.flg_label, 0)		AS flg_label1
			,	ISNULL(shikomi1.flg_label_hasu, 0)	AS flg_label_hasu1
			,	ISNULL(shikomi2.flg_jisseki, 0)		AS flg_jisseki2
			,	ISNULL(shikomi2.flg_shikomi, 0)		AS flg_shikomi2
			,	ISNULL(shikomi2.flg_label, 0)		AS flg_label2
			,	ISNULL(shikomi2.flg_label_hasu, 0)	AS flg_label_hasu2
			,	ISNULL(shikomi3.flg_jisseki, 0)		AS flg_jisseki3
			,	ISNULL(shikomi3.flg_shikomi, 0)		AS flg_shikomi3
			,	ISNULL(shikomi3.flg_label, 0)		AS flg_label3
			,	ISNULL(shikomi3.flg_label_hasu, 0)	AS flg_label_hasu3
			,	ISNULL(shikomi4.flg_jisseki, 0)		AS flg_jisseki4
			,	ISNULL(shikomi4.flg_shikomi, 0)		AS flg_shikomi4
			,	ISNULL(shikomi4.flg_label, 0)		AS flg_label4
			,	ISNULL(shikomi4.flg_label_hasu, 0)	AS flg_label_hasu4
			,	ISNULL(shikomi5.flg_jisseki, 0)		AS flg_jisseki5
			,	ISNULL(shikomi5.flg_shikomi, 0)		AS flg_shikomi5
			,	ISNULL(shikomi5.flg_label, 0)		AS flg_label5
			,	ISNULL(shikomi5.flg_label_hasu, 0)	AS flg_label_hasu5
			,	ISNULL(shikomi6.flg_jisseki, 0)		AS flg_jisseki6
			,	ISNULL(shikomi6.flg_shikomi, 0)		AS flg_shikomi6
			,	ISNULL(shikomi6.flg_label, 0)		AS flg_label6
			,	ISNULL(shikomi6.flg_label_hasu, 0)	AS flg_label_hasu6
			,	ISNULL(shikomi7.flg_jisseki, 0)		AS flg_jisseki7
			,	ISNULL(shikomi7.flg_shikomi, 0)		AS flg_shikomi7
			,	ISNULL(shikomi7.flg_label, 0)		AS flg_label7
			,	ISNULL(shikomi7.flg_label_hasu, 0)	AS flg_label_hasu7
			,	ISNULL(shikomi8.flg_jisseki, 0)		AS flg_jisseki8
			,	ISNULL(shikomi8.flg_shikomi, 0)		AS flg_shikomi8
			,	ISNULL(shikomi8.flg_label, 0)		AS flg_label8
			,	ISNULL(shikomi8.flg_label_hasu, 0)	AS flg_label_hasu8
			,	ISNULL(shikomi9.flg_jisseki, 0)		AS flg_jisseki9
			,	ISNULL(shikomi9.flg_shikomi, 0)		AS flg_shikomi9
			,	ISNULL(shikomi9.flg_label, 0)		AS flg_label9
			,	ISNULL(shikomi9.flg_label_hasu, 0)	AS flg_label_hasu9
			 
		-- 自分自身
		FROM tr_keikaku_shikakari shikakari
		INNER JOIN su_keikaku_shikakari shikomi
			ON shikomi.no_lot_shikakari = shikakari.no_lot_shikakari
		LEFT JOIN tr_keikaku_seihin seihin
			ON seihin.no_lot_seihin = shikakari.no_lot_seihin
		-- 1階層下
		LEFT JOIN tr_keikaku_shikakari shikakari1
			ON shikakari1.data_key_oya = shikakari.data_key
		LEFT JOIN su_keikaku_shikakari shikomi1
			ON shikomi1.no_lot_shikakari = shikakari1.no_lot_shikakari
		-- 2階層下
		LEFT JOIN tr_keikaku_shikakari shikakari2
			ON shikakari2.data_key_oya = shikakari1.data_key
		LEFT JOIN su_keikaku_shikakari shikomi2
			ON shikomi2.no_lot_shikakari = shikakari2.no_lot_shikakari
		-- 3階層下
		LEFT JOIN tr_keikaku_shikakari shikakari3
			ON shikakari3.data_key_oya = shikakari2.data_key
		LEFT JOIN su_keikaku_shikakari shikomi3
			ON shikomi3.no_lot_shikakari = shikakari3.no_lot_shikakari
		-- 4階層下
		LEFT JOIN tr_keikaku_shikakari shikakari4
			ON shikakari4.data_key_oya = shikakari3.data_key
		LEFT JOIN su_keikaku_shikakari shikomi4
			ON shikomi4.no_lot_shikakari = shikakari4.no_lot_shikakari
		-- 5階層下
		LEFT JOIN tr_keikaku_shikakari shikakari5
			ON shikakari5.data_key_oya = shikakari4.data_key
		LEFT JOIN su_keikaku_shikakari shikomi5
			ON shikomi5.no_lot_shikakari = shikakari5.no_lot_shikakari
		-- 6階層下
		LEFT JOIN tr_keikaku_shikakari shikakari6
			ON shikakari6.data_key_oya = shikakari5.data_key
		LEFT JOIN su_keikaku_shikakari shikomi6
			ON shikomi6.no_lot_shikakari = shikakari6.no_lot_shikakari
		-- 7階層下
		LEFT JOIN tr_keikaku_shikakari shikakari7
			ON shikakari7.data_key_oya = shikakari6.data_key
		LEFT JOIN su_keikaku_shikakari shikomi7
			ON shikomi7.no_lot_shikakari = shikakari7.no_lot_shikakari
		-- 8階層下
		LEFT JOIN tr_keikaku_shikakari shikakari8
			ON shikakari8.data_key_oya = shikakari7.data_key
		LEFT JOIN su_keikaku_shikakari shikomi8
			ON shikomi8.no_lot_shikakari = shikakari8.no_lot_shikakari
		-- 9階層下
		LEFT JOIN tr_keikaku_shikakari shikakari9
			ON shikakari9.data_key_oya = shikakari8.data_key
		LEFT JOIN su_keikaku_shikakari shikomi9
			ON shikomi9.no_lot_shikakari = shikakari9.no_lot_shikakari
	) jisseki

GO