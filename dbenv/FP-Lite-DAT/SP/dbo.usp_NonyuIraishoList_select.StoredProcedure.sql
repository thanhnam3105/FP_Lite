IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_NonyuIraishoList_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_NonyuIraishoList_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===============================================
-- Author:		tsujita.s
-- Create date: 2013.09.11
-- Last Update: 2015.02.19
-- Description:	納入依頼書リスト
--    データ抽出処理
-- ===============================================
CREATE PROCEDURE [dbo].[usp_NonyuIraishoList_select]
	@hizuke_from			datetime		-- 日付：始点
	,@hizuke_to				datetime		-- 日付：終点
	,@today					datetime		-- UTC時間で変換済みシステム日付
	,@flg_yotei				smallint		-- 定数：予実フラグ：予定
	,@flg_jisseki			smallint		-- 定数：予実フラグ：実績
	,@flg_mishiyo			smallint		-- 定数：未使用フラグ：使用
	,@con_torihiki			varchar(13)		-- 検索条件：取引先コード
	,@param_hin				varchar(1000)	-- 検索条件：選択された品名コード
	,@tani_kg				varchar(2)		-- 定数：単位：Kg
	,@tani_li				varchar(2)		-- 定数：単位：L
AS
BEGIN

	SET NOCOUNT ON

	-- =================================
	--  選択された品名コードがある場合
	-- =================================
	IF @param_hin <> ''
	BEGIN
		SELECT
		 tr.flg_yojitsu AS flg_yojitsu
		 ,tr.no_nonyu AS no_nonyu
		 ,tr.cd_hinmei AS cd_hinmei
		 ,ma_hin.nm_hinmei_ja AS nm_hinmei_ja
		 ,ma_hin.nm_hinmei_en AS nm_hinmei_en
		 ,ma_hin.nm_hinmei_zh AS nm_hinmei_zh
		 ,ma_hin.nm_hinmei_vi AS nm_hinmei_vi
		 ,ma_ko.nm_nisugata_hyoji AS nm_nisugata_hyoji
		 ,ma_tan.nm_tani AS nm_tani
		 ,ma_bun.nm_bunrui AS nm_bunrui
		 ,tr.dt_nonyu AS dt_nonyu

		 --,COALESCE(floor(tr.su_nonyu), 0) AS su_nonyu
		 -- 納入単位がKgまたはLの場合は、端数を正規数に加算する
		 ,dbo.udf_NonyuHasuKanzan(ma_ko.cd_tani_nonyu, ma_hin.cd_tani_nonyu,
			tr.su_nonyu, tr.su_nonyu_hasu, @tani_kg, @tani_li) AS su_nonyu

		 ,tr.su_nonyu AS su_nonyu_db
		 ,tr.su_nonyu_hasu AS su_nonyu_hasu
		 ,tr.cd_torihiki AS cd_torihiki
		 ,tr.cd_torihiki2 AS cd_torihiki2
		 ,tr.tan_nonyu AS tan_nonyu
		 ,tr.kin_kingaku AS kin_kingaku
		 ,tr.no_nonyusho AS no_nonyusho
		 ,tr.kbn_zei AS kbn_zei
		 ,tr.kbn_denso AS kbn_denso
		 ,tr.flg_kakutei AS flg_kakutei
		 ,tr.dt_seizo AS dt_seizo
		 -- 重量
		 --,COALESCE(ma_ko.wt_nonyu, 0) * COALESCE(ma_ko.su_iri, 0) * COALESCE(floor(tr.su_nonyu), 0) AS juryo
		 ,COALESCE(ma_ko.wt_nonyu, 0) * COALESCE(ma_ko.su_iri, 0)
			* dbo.udf_NonyuHasuKanzan(ma_ko.cd_tani_nonyu, ma_hin.cd_tani_nonyu,
					tr.su_nonyu, tr.su_nonyu_hasu, @tani_kg, @tani_li) AS juryo
		FROM
			tr_nonyu tr

		-- 品名マスタ
		LEFT JOIN ma_hinmei ma_hin
		ON ma_hin.cd_hinmei = tr.cd_hinmei

		-- 原資材購入先マスタ
		LEFT JOIN ma_konyu ma_ko
		ON ma_ko.cd_hinmei = tr.cd_hinmei
		AND ma_ko.cd_torihiki = tr.cd_torihiki
		--AND ma_ko.flg_mishiyo = @flg_mishiyo

		-- 単位マスタ
		LEFT JOIN ma_tani ma_tan
		ON ma_tan.cd_tani = ma_ko.cd_tani_nonyu

		-- 分類マスタ
		LEFT JOIN ma_bunrui ma_bun
		ON ma_bun.cd_bunrui = ma_hin.cd_bunrui
		AND ma_bun.kbn_hin = ma_hin.kbn_hin

		WHERE
			tr.dt_nonyu BETWEEN @hizuke_from AND @hizuke_to
		AND (
			(tr.dt_nonyu < @today AND tr.flg_yojitsu = @flg_jisseki)
			OR
			(tr.dt_nonyu >= @today AND tr.flg_yojitsu = @flg_yotei)
		)
		AND tr.cd_torihiki = @con_torihiki
		AND tr.cd_hinmei
			IN (SELECT id FROM udf_SplitCommaValue(@param_hin))
		--AND tr.su_nonyu > 0
		ORDER BY
			tr.cd_hinmei, tr.dt_nonyu
	END

	-- =================================
	--  選択された品名コードがない場合
	-- =================================
	ELSE BEGIN
		SELECT
		 tr.flg_yojitsu AS flg_yojitsu
		 ,tr.no_nonyu AS no_nonyu
		 ,tr.cd_hinmei AS cd_hinmei
		 ,ma_hin.nm_hinmei_ja AS nm_hinmei_ja
		 ,ma_hin.nm_hinmei_en AS nm_hinmei_en
		 ,ma_hin.nm_hinmei_zh AS nm_hinmei_zh
		 ,ma_hin.nm_hinmei_vi AS nm_hinmei_vi
		 ,ma_ko.nm_nisugata_hyoji AS nm_nisugata_hyoji
		 ,ma_tan.nm_tani AS nm_tani
		 ,ma_bun.nm_bunrui AS nm_bunrui
		 ,tr.dt_nonyu AS dt_nonyu

		 --,COALESCE(floor(tr.su_nonyu), 0) AS su_nonyu
		 -- 納入単位がKgまたはLの場合は、端数を正規数に加算する
		 ,dbo.udf_NonyuHasuKanzan(ma_ko.cd_tani_nonyu, ma_hin.cd_tani_nonyu,
			tr.su_nonyu, tr.su_nonyu_hasu, @tani_kg, @tani_li) AS su_nonyu

		 ,tr.su_nonyu AS su_nonyu_db
		 ,tr.su_nonyu_hasu AS su_nonyu_hasu
		 ,tr.cd_torihiki AS cd_torihiki
		 ,tr.cd_torihiki2 AS cd_torihiki2
		 ,tr.tan_nonyu AS tan_nonyu
		 ,tr.kin_kingaku AS kin_kingaku
		 ,tr.no_nonyusho AS no_nonyusho
		 ,tr.kbn_zei AS kbn_zei
		 ,tr.kbn_denso AS kbn_denso
		 ,tr.flg_kakutei AS flg_kakutei
		 ,tr.dt_seizo AS dt_seizo
		 -- 重量
		 --,COALESCE(ma_ko.wt_nonyu, 0) * COALESCE(ma_ko.su_iri, 0) * COALESCE(floor(tr.su_nonyu), 0) AS juryo
		 ,COALESCE(ma_ko.wt_nonyu, 0) * COALESCE(ma_ko.su_iri, 0)
			* dbo.udf_NonyuHasuKanzan(ma_ko.cd_tani_nonyu, ma_hin.cd_tani_nonyu,
					tr.su_nonyu, tr.su_nonyu_hasu, @tani_kg, @tani_li) AS juryo
		FROM
			tr_nonyu tr

		-- 品名マスタ
		LEFT JOIN ma_hinmei ma_hin
		ON ma_hin.cd_hinmei = tr.cd_hinmei

		-- 原資材購入先マスタ
		LEFT JOIN ma_konyu ma_ko
		ON ma_ko.cd_hinmei = tr.cd_hinmei
		AND ma_ko.cd_torihiki = tr.cd_torihiki
		--AND ma_ko.flg_mishiyo = @flg_mishiyo

		-- 単位マスタ
		LEFT JOIN ma_tani ma_tan
		ON ma_tan.cd_tani = ma_ko.cd_tani_nonyu

		-- 分類マスタ
		LEFT JOIN ma_bunrui ma_bun
		ON ma_bun.cd_bunrui = ma_hin.cd_bunrui
		AND ma_bun.kbn_hin = ma_hin.kbn_hin

		WHERE
			tr.dt_nonyu BETWEEN @hizuke_from AND @hizuke_to
		AND (
			(tr.dt_nonyu < @today AND tr.flg_yojitsu = @flg_jisseki)
			OR
			(tr.dt_nonyu >= @today AND tr.flg_yojitsu = @flg_yotei)
		)
		AND tr.cd_torihiki = @con_torihiki
		--AND tr.su_nonyu > 0
		ORDER BY
			tr.cd_hinmei, tr.dt_nonyu
	END


END
GO
