IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_SeizoJissekiSentaku_nodata_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_SeizoJissekiSentaku_nodata_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ================================================
-- Author:      tsujita.s
-- Create date: 2015.06.25
-- Last Update: 2017.01.16 yokota
-- Description: 製造実績選択・データなし時の初期表示検索SP
-- ================================================
CREATE PROCEDURE [dbo].[usp_SeizoJissekiSentaku_nodata_select]
    @dt_shikomi			datetime		-- 検索条件：前画面．仕込日
    ,@cd_haigo			varchar(14)		-- 検索条件：前画面．コード
    ,@su_shikomi		decimal(12, 6)	-- 検索条件：前画面．仕込量
    ,@flg_mikakutei		smallint		-- 定数：確定フラグ：未確定
    ,@flg_kakutei		smallint		-- 定数：確定フラグ：確定
    ,@flg_shiyo			smallint		-- 定数：未使用フラグ：使用
    ,@denso_jotai		smallint		-- 定数：伝送状態区分の初期値：未伝送
    ,@kbn_anbun_seizo	varchar(10)		-- 定数：按分区分の初期値：製造
    ,@no_lot			varchar(14)		-- 明細：ロット番号
AS
BEGIN

	-- ///// 製造予実合計数の作成 /////
	DECLARE @total_su_seizo decimal(12, 6) = 0

	SELECT
		@total_su_seizo = SUM(COALESCE(seizoYojitsu.su_seizo, 0))
	FROM (
		SELECT
			tr.dt_seizo
			,tr.cd_hinmei
			,CASE WHEN tr.flg_jisseki = @flg_kakutei
			 THEN COALESCE(tr.su_seizo_jisseki, 0) * ma.wt_ko * ma.su_iri
			 ELSE COALESCE(tr.su_seizo_yotei, 0) * ma.wt_ko * ma.su_iri
			 END AS 'su_seizo'
			,ma.cd_haigo
		FROM tr_keikaku_seihin tr
		LEFT JOIN tr_keikaku_shikakari shikakari
		ON tr.no_lot_seihin = shikakari.no_lot_seihin
		AND tr.dt_seizo = shikakari.dt_seizo
		AND shikakari.cd_shikakari_hin = @cd_haigo
		INNER JOIN ma_hinmei ma
		ON tr.cd_hinmei = ma.cd_hinmei
		AND ma.cd_haigo = @cd_haigo
		WHERE tr.dt_seizo = @dt_shikomi
		AND shikakari.no_lot_shikakari = @no_lot
	) seizoYojitsu
	GROUP BY
		seizoYojitsu.dt_seizo, seizoYojitsu.cd_haigo


	-- ///// 明細情報の取得 /////
	SELECT
		@kbn_anbun_seizo AS 'kbn_shiyo_jisseki_anbun'
		,@dt_shikomi AS 'dt_shiyo_shikakari'
		,hin.kbn_hin
		,hkbn.nm_kbn_hin
		,seihin.cd_hinmei
		,hin.nm_hinmei_ja
		,hin.nm_hinmei_en
		,hin.nm_hinmei_zh
		,hin.nm_hinmei_vi
		,hin.nm_hinmei_ryaku
		,seihin.no_lot_seihin
		---- 仕込量を掛ける前に小数点第七位を四捨五入
		-- 仕込量を掛ける前に小数点第四位を四捨五入
		,CASE WHEN seihin.flg_jisseki = @flg_kakutei
		 --THEN ROUND(((COALESCE(seihin.su_seizo_jisseki, 0) * hin.wt_ko * hin.su_iri) / @total_su_seizo), 6, 0) * @su_shikomi
		 THEN ROUND(((COALESCE(seihin.su_seizo_jisseki, 0) * hin.wt_ko * hin.su_iri) / @total_su_seizo), 3, 0) * @su_shikomi
		 --ELSE ROUND(((COALESCE(seihin.su_seizo_yotei, 0) * hin.wt_ko * hin.su_iri) / @total_su_seizo), 6, 0) * @su_shikomi
		 ELSE ROUND(((COALESCE(seihin.su_seizo_yotei, 0) * hin.wt_ko * hin.su_iri) / @total_su_seizo), 3, 0) * @su_shikomi
		 END AS 'su_shiyo_shikakari'
		,'' AS 'cd_riyu'
		,'' AS 'cd_genka_center'
		,'' AS 'cd_soko'
		,@denso_jotai AS 'kbn_jotai_denso'
		,@denso_jotai AS 'kbn_denso'
		,hin.flg_testitem
	FROM (
		SELECT
			cd_hinmei
			,dt_seizo
			,no_lot_seihin
			,su_seizo_jisseki
			,su_seizo_yotei
			,flg_jisseki
		FROM
			tr_keikaku_seihin
		WHERE
			dt_seizo = @dt_shikomi
	) seihin

	LEFT JOIN tr_keikaku_shikakari shikakari
	ON seihin.no_lot_seihin = shikakari.no_lot_seihin
	AND seihin.dt_seizo = shikakari.dt_seizo
	AND shikakari.cd_shikakari_hin = @cd_haigo

	INNER JOIN ma_hinmei hin
	ON hin.cd_haigo = @cd_haigo
	AND seihin.cd_hinmei = hin.cd_hinmei

	LEFT JOIN ma_kbn_hin hkbn
	ON hin.kbn_hin = hkbn.kbn_hin

	WHERE
		shikakari.no_lot_shikakari = @no_lot

	ORDER BY hin.kbn_hin, seihin.cd_hinmei

END
GO
