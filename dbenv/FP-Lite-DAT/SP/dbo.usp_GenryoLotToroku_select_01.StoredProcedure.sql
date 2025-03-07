IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_GenryoLotToroku_select_01') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_GenryoLotToroku_select_01]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      <SangVM>
-- Create date: <Create Date: 2016/03>
-- Last Update: <2018/02/07 BRC.tokumoto>
-- Last Update: <2019/01/07 BRC.kanehira>
-- Last Update: <2019/11/05 BRC.kanehira>
-- Last Update: <2019/11/15 BRC.saito>
-- Description: <Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_GenryoLotToroku_select_01]
	@dt_hiduke 			DATETIME
	, @cd_hinmei		VARCHAR(14)
	, @no_lot 			VARCHAR(14)
	, @GenryoHinKbn		SMALLINT
	, @ShikakariHinKbn	SMALLINT
	, @JikaGenryoHinKbn	SMALLINT
AS
BEGIN
	DECLARE @dt_hizuke_max	DATETIME
	DECLARE @zero			SMALLINT
	DECLARE @kbn_nyushukko	SMALLINT
	DECLARE @flg_mishiyo	SMALLINT
	DECLARE @kowake_count   SMALLINT
	DECLARE @tonyu_count    SMALLINT

	SET		@zero = 0
	SET		@kbn_nyushukko = 3
	SET		@flg_mishiyo = 0

	SELECT @dt_hizuke_max = MAX(CALENDAR.dt_hizuke)
	FROM ma_calendar CALENDAR
	WHERE CALENDAR.dt_hizuke < @dt_hiduke
	AND CALENDAR.flg_kyujitsu = @zero
	AND CALENDAR.flg_shukujitsu = @zero
	
	SELECT @kowake_count = COUNT( * ) 
	FROM tr_kowake
	WHERE no_lot_seihin = @no_lot
	
	SELECT @tonyu_count = COUNT( * ) 
	FROM tr_tonyu
	WHERE no_lot_seihin = @no_lot
	
	IF @kowake_count <> 0 OR @tonyu_count <> 0
	
			SELECT DISTINCT
				CAST (NULL AS SMALLINT) AS flg_henko
				, SHI.no_lot_shikakari
				, SHI.dt_seizo
				, SHI.cd_shikakari_hin
				, HAIGO_RECIPE.cd_hinmei
				, HAIGO_RECIPE.cd_hinmei AS cd_hinmei_old
				, Hin.nm_hinmei_ja
				, Hin.nm_hinmei_en
				, Hin.nm_hinmei_zh
				, Hin.nm_hinmei_vi
				, Hin.nm_hinmei_ryaku
				, Hin.cd_tani_shiyo
				, Tani.nm_tani AS nm_tani_shiyo
				, Hin.nm_nisugata_hyoji
				, Hin.flg_trace_taishogai
				, HAIGO_RECIPE.no_kotei
				, HAIGO_RECIPE.no_tonyu
				, HAIGO_RECIPE.kbn_hin
				--, ISNULL(CAST(TR_NIU3.no_niuke AS VARCHAR(14)), NULL) AS no_niuke
				-- 優先順位：①　代替品、投入あり、小分けありの荷受No
				--           ②　投入あり、小分けありの荷受No
				--           ③　代替品、投入あり、小分けなしの荷受No
				--           ④　投入あり、小分けなしの荷受No
				--           ⑤　代替品、投入なし、小分けありの荷受No
				--           ⑥　投入なし、小分けありの荷受No
				, CASE WHEN TR_KOWA1_DTH.no_lot_kowake IS NOT NULL THEN TR_NIU2_DTH.no_niuke
					   WHEN TR_KOWA1.no_lot_kowake IS NOT NULL THEN TR_NIU2.no_niuke
					   WHEN TR_TONYU_DTH.no_lot IS NOT NULL THEN TR_NIU1_DTH.no_niuke
					   WHEN TR_TONYU.no_lot IS NOT NULL THEN TR_NIU1.no_niuke
					   WHEN TR_KOWA2_DTH.no_lot_kowake IS NOT NULL THEN TR_NIU3_DTH.no_niuke
					   WHEN TR_KOWA2.no_lot_kowake IS NOT NULL THEN TR_NIU3.no_niuke
					   --ELSE ISNULL(CAST(TR_NIU4.no_niuke AS VARCHAR(14)), NULL)
				END  AS no_niuke
				--, TR_NIU.no_lot
				-- 投入、小分に紐づく荷受がない場合はNULLを設定する。
				-- 荷受に紐づく場合は下記条件でロットNoを取得する。
				-- 優先順位：①　代替品、投入あり、小分けありのロットNo
				--           ②　投入あり、小分けありのロットNo
				--           ③　代替品、投入あり、小分けなしのロットNo
				--           ④　投入あり、小分けなしのロットNo
				--           ⑤　代替品、投入なし、小分けありのロットNo
				--           ⑥　投入なし、小分けありのロットNo
				, CASE WHEN TR_KOWA1_DTH.no_lot_kowake IS NOT NULL THEN TR_NIU2_DTH.no_lot
					   WHEN TR_KOWA1.no_lot_kowake IS NOT NULL THEN TR_NIU2.no_lot
					   WHEN TR_TONYU_DTH.no_lot IS NOT NULL THEN TR_NIU1_DTH.no_lot
					   WHEN TR_TONYU.no_lot IS NOT NULL THEN TR_NIU1.no_lot
					   WHEN TR_KOWA2_DTH.no_lot_kowake IS NOT NULL THEN TR_NIU3_DTH.no_lot
					   WHEN TR_KOWA2.no_lot_kowake IS NOT NULL THEN TR_NIU3.no_lot
					   --ELSE TR_NIU4.no_lot
				  END  AS no_lot
				, NULL AS biko
			FROM (
				SELECT*
				FROM su_keikaku_shikakari
				WHERE CAST(dt_seizo AS DATE) = CAST(@dt_hiduke AS DATE)
				AND cd_shikakari_hin = @cd_hinmei
				AND no_lot_shikakari = @no_lot
				AND (su_batch_jisseki > @zero
				OR su_batch_jisseki_hasu > @zero)
			) SHI
			
			INNER JOIN (
				SELECT TOP 1
					cd_haigo
					,no_han
					,dt_from
				FROM dbo.ma_haigo_mei
				WHERE
					cd_haigo = @cd_hinmei
					AND flg_mishiyo = @flg_mishiyo
		--            AND dt_from <= @dt_hiduke
					AND CAST(dt_from AS DATE) <= CAST(@dt_hiduke AS DATE)
				ORDER BY dt_from DESC,no_han DESC
			) HAIGO_MEI
			ON SHI.cd_shikakari_hin = HAIGO_MEI.cd_haigo
			
			INNER JOIN ma_haigo_recipe HAIGO_RECIPE
			ON HAIGO_MEI.cd_haigo = HAIGO_RECIPE.cd_haigo
			AND HAIGO_MEI.no_han = HAIGO_RECIPE.no_han
			AND HAIGO_RECIPE.kbn_hin IN (@GenryoHinKbn, @ShikakariHinKbn, @JikaGenryoHinKbn)
			
			-- 投入の情報取得：開始
			LEFT JOIN tr_tonyu TR_TONYU
			ON SHI.cd_shokuba = TR_TONYU.cd_shokuba
			AND SHI.cd_line = TR_TONYU.cd_line
			--AND SHI.cd_shikakari_hin = TR_TONYU.cd_haigo
			AND HAIGO_RECIPE.cd_haigo = TR_TONYU.cd_haigo
			AND HAIGO_RECIPE.cd_hinmei = TR_TONYU.cd_hinmei
			AND HAIGO_RECIPE.no_tonyu = TR_TONYU.no_tonyu
			AND SHI.no_lot_shikakari = TR_TONYU.no_lot_seihin
			AND TR_TONYU.kbn_kyosei = 0
			
			LEFT JOIN tr_kowake TR_KOWA1
			ON TR_TONYU.cd_hinmei = TR_KOWA1.cd_hinmei
			AND TR_TONYU.no_kotei = TR_KOWA1.no_kotei
			AND TR_TONYU.su_ko_label = TR_KOWA1.su_ko
			AND TR_TONYU.su_kai = TR_KOWA1.su_kai
			AND TR_TONYU.no_tonyu = TR_KOWA1.no_tonyu
			AND TR_TONYU.cd_line = TR_KOWA1.cd_line
			AND TR_TONYU.dt_shori = TR_KOWA1.dt_tonyu
			AND TR_TONYU.no_lot_seihin = TR_KOWA1.no_lot_seihin
			AND TR_TONYU.kbn_seikihasu = TR_KOWA1.kbn_seikihasu
			AND TR_KOWA1.flg_kanryo_tonyu = 1
			
			LEFT JOIN tr_lot TR_LOT1
			ON TR_KOWA1.no_lot_kowake = TR_LOT1.no_lot_jisseki
			
			--LEFT JOIN tr_niuke TR_NIU1
			--ON TR_LOT1.dt_seizo_genryo = TR_NIU1.dt_seizo
			--AND TR_LOT1.dt_shomi = TR_NIU1.dt_kigen
			--AND TR_LOT1.no_lot = TR_NIU1.no_lot
			
			--荷姿ラベルを読み込んだ場合は投入と荷受を紐づける
			LEFT JOIN (
						SELECT 
						MAX(niuke.no_niuke) AS no_niuke
						,niuke.cd_hinmei
						,niuke.dt_seizo
						,niuke.dt_kigen
						,niuke.no_lot
						FROM tr_niuke niuke
						GROUP BY niuke.cd_hinmei, niuke.dt_seizo, niuke.dt_kigen, niuke.no_lot
					  )TR_NIU1
			ON	HAIGO_RECIPE.cd_hinmei = TR_NIU1.cd_hinmei
			AND TR_TONYU.no_lot = TR_NIU1.no_lot
			
			--投入に紐づく小分がある場合は小分と荷受を紐づける
			LEFT JOIN  (
						SELECT 
						MAX(niuke.no_niuke) AS no_niuke
						,niuke.cd_hinmei
						--,niuke.dt_seizo
						,ISNULL(niuke.dt_seizo,'') AS dt_seizo
						,niuke.dt_kigen
						,niuke.no_lot
						FROM tr_niuke niuke
						GROUP BY niuke.cd_hinmei, niuke.dt_seizo, niuke.dt_kigen, niuke.no_lot
					  )TR_NIU2
			ON	HAIGO_RECIPE.cd_hinmei = TR_NIU2.cd_hinmei
			--AND TR_LOT1.dt_seizo_genryo = TR_NIU2.dt_seizo
			--AND ISNULL(TR_LOT1.dt_seizo_genryo,'') = TR_NIU2.dt_seizo
			AND TR_LOT1.dt_shomi = TR_NIU2.dt_kigen
			AND TR_LOT1.no_lot = TR_NIU2.no_lot
			-- 投入の情報取得：終了

			-- 小分けの情報取得：開始
			LEFT JOIN tr_kowake TR_KOWA2
			ON HAIGO_RECIPE.cd_hinmei = TR_KOWA2.cd_hinmei
			AND SHI.cd_line = TR_KOWA2.cd_line
			AND SHI.no_lot_shikakari = TR_KOWA2.no_lot_seihin
			AND HAIGO_RECIPE.no_tonyu = TR_KOWA2.no_tonyu
			AND TR_KOWA2.flg_kanryo_tonyu = 0

			LEFT JOIN tr_lot TR_LOT2
			ON TR_KOWA2.no_lot_kowake = TR_LOT2.no_lot_jisseki
			
			--LEFT JOIN tr_niuke TR_NIU2
			--ON TR_LOT2.dt_seizo_genryo = TR_NIU2.dt_seizo
			--AND TR_LOT2.dt_shomi = TR_NIU2.dt_kigen
			--AND TR_LOT2.no_lot = TR_NIU2.no_lot 
			
			LEFT JOIN (
						SELECT 
						MAX(niuke.no_niuke) AS no_niuke
						,niuke.cd_hinmei
						--,niuke.dt_seizo
						,ISNULL(niuke.dt_seizo,'') AS dt_seizo
						,niuke.dt_kigen
						,niuke.no_lot
						FROM tr_niuke niuke
						GROUP BY niuke.cd_hinmei, niuke.dt_seizo, niuke.dt_kigen, niuke.no_lot
					  )TR_NIU3
			ON  HAIGO_RECIPE.cd_hinmei = TR_NIU3.cd_hinmei
			--AND TR_LOT2.dt_seizo_genryo = TR_NIU3.dt_seizo
			--AND ISNULL(TR_LOT2.dt_seizo_genryo,'') = TR_NIU3.dt_seizo
			AND TR_LOT2.dt_shomi = TR_NIU3.dt_kigen
			AND TR_LOT2.no_lot = TR_NIU3.no_lot 
			-- 小分けの情報取得：終了

			-- 前日庫出しした情報取得：開始
			--LEFT JOIN tr_niuke TR_NIU4
			--ON HAIGO_RECIPE.cd_hinmei = TR_NIU4.cd_hinmei
			--AND TR_NIU4.kbn_nyushukko = @kbn_nyushukko
			--AND CAST(TR_NIU4.dt_niuke AS DATE) = CAST(@dt_hizuke_max AS DATE)
			-- 前日庫出しした情報取得：終了
			
			
			-- 代替品マスタ情報取得：開始
			LEFT JOIN ma_daitaihin DAITAIHIN
			ON HAIGO_RECIPE.cd_hinmei = DAITAIHIN.cd_hinmei_daihyo
			
			-- 代替品-投入の情報取得：開始
			LEFT JOIN tr_tonyu TR_TONYU_DTH
			ON SHI.cd_shokuba = TR_TONYU_DTH.cd_shokuba
			AND SHI.cd_line = TR_TONYU_DTH.cd_line
			AND HAIGO_RECIPE.cd_haigo = TR_TONYU_DTH.cd_haigo
			AND DAITAIHIN.cd_hinmei = TR_TONYU_DTH.cd_hinmei
			AND HAIGO_RECIPE.no_tonyu = TR_TONYU_DTH.no_tonyu
			AND SHI.no_lot_shikakari = TR_TONYU_DTH.no_lot_seihin
			AND TR_TONYU_DTH.kbn_kyosei = 0
			
			LEFT JOIN tr_kowake TR_KOWA1_DTH
			ON TR_TONYU_DTH.cd_hinmei = TR_KOWA1_DTH.cd_hinmei
			AND TR_TONYU_DTH.no_kotei = TR_KOWA1_DTH.no_kotei
			AND TR_TONYU_DTH.su_ko_label = TR_KOWA1_DTH.su_ko
			AND TR_TONYU_DTH.su_kai = TR_KOWA1_DTH.su_kai
			AND TR_TONYU_DTH.no_tonyu = TR_KOWA1_DTH.no_tonyu
			AND TR_TONYU_DTH.cd_line = TR_KOWA1_DTH.cd_line
			AND TR_TONYU_DTH.dt_shori = TR_KOWA1_DTH.dt_tonyu
			AND TR_TONYU_DTH.no_lot_seihin = TR_KOWA1_DTH.no_lot_seihin
			AND TR_TONYU_DTH.kbn_seikihasu = TR_KOWA1_DTH.kbn_seikihasu
			AND TR_KOWA1_DTH.flg_kanryo_tonyu = 1
			
			LEFT JOIN tr_lot TR_LOT1_DTH
			ON TR_KOWA1_DTH.no_lot_kowake = TR_LOT1_DTH.no_lot_jisseki
			
			--荷姿ラベルを読み込んだ場合は投入と荷受を紐づける
			LEFT JOIN (
						SELECT 
						MAX(niuke.no_niuke) AS no_niuke
						,niuke.cd_hinmei
						,niuke.dt_seizo
						,niuke.dt_kigen
						,niuke.no_lot
						FROM tr_niuke niuke
						GROUP BY niuke.cd_hinmei, niuke.dt_seizo, niuke.dt_kigen, niuke.no_lot
					  )TR_NIU1_DTH
			ON	DAITAIHIN.cd_hinmei = TR_NIU1_DTH.cd_hinmei
			AND TR_TONYU_DTH.no_lot = TR_NIU1_DTH.no_lot
			
			--投入に紐づく小分がある場合は小分と荷受を紐づける
			LEFT JOIN  (
						SELECT 
						MAX(niuke.no_niuke) AS no_niuke
						,niuke.cd_hinmei
						,ISNULL(niuke.dt_seizo,'') AS dt_seizo
						,niuke.dt_kigen
						,niuke.no_lot
						FROM tr_niuke niuke
						GROUP BY niuke.cd_hinmei, niuke.dt_seizo, niuke.dt_kigen, niuke.no_lot
					  )TR_NIU2_DTH
			ON	DAITAIHIN.cd_hinmei = TR_NIU2_DTH.cd_hinmei
			--AND ISNULL(TR_LOT1_DTH.dt_seizo_genryo,'') = TR_NIU2_DTH.dt_seizo
			AND TR_LOT1_DTH.dt_shomi = TR_NIU2_DTH.dt_kigen
			AND TR_LOT1_DTH.no_lot = TR_NIU2_DTH.no_lot
			-- 代替品-投入の情報取得：終了
			
			-- 代替品-小分けの情報取得：開始
			LEFT JOIN tr_kowake TR_KOWA2_DTH
			ON DAITAIHIN.cd_hinmei = TR_KOWA2_DTH.cd_hinmei
			AND SHI.cd_line = TR_KOWA2_DTH.cd_line
			AND SHI.no_lot_shikakari = TR_KOWA2_DTH.no_lot_seihin
			AND HAIGO_RECIPE.no_tonyu = TR_KOWA2_DTH.no_tonyu
			AND TR_KOWA2_DTH.flg_kanryo_tonyu = 0

			LEFT JOIN tr_lot TR_LOT2_DTH
			ON TR_KOWA2_DTH.no_lot_kowake = TR_LOT2_DTH.no_lot_jisseki
			
			LEFT JOIN (
						SELECT 
						MAX(niuke.no_niuke) AS no_niuke
						,niuke.cd_hinmei
						,ISNULL(niuke.dt_seizo,'') AS dt_seizo
						,niuke.dt_kigen
						,niuke.no_lot
						FROM tr_niuke niuke
						GROUP BY niuke.cd_hinmei, niuke.dt_seizo, niuke.dt_kigen, niuke.no_lot
					  )TR_NIU3_DTH
			ON  DAITAIHIN.cd_hinmei = TR_NIU3_DTH.cd_hinmei
			--AND ISNULL(TR_LOT2_DTH.dt_seizo_genryo,'') = TR_NIU3_DTH.dt_seizo
			AND TR_LOT2_DTH.dt_shomi = TR_NIU3_DTH.dt_kigen
			AND TR_LOT2_DTH.no_lot = TR_NIU3_DTH.no_lot 
			-- 代替品-小分けの情報取得：終了
			
			-- 代替品マスタ情報取得：終了

			LEFT JOIN ma_hinmei Hin
			ON HAIGO_RECIPE.cd_hinmei = Hin.cd_hinmei

			LEFT JOIN ma_tani Tani
			ON Hin.cd_tani_shiyo = Tani.cd_tani
			
			WHERE Hin.flg_mishiyo = @flg_mishiyo
			OR Hin.flg_mishiyo IS NULL
			
	-- 投入なし、小分けなしの荷受No（前日庫出し）の取得
	ELSE
	
			SELECT DISTINCT
				CAST (NULL AS SMALLINT) AS flg_henko
				, SHI.no_lot_shikakari
				, SHI.dt_seizo
				, SHI.cd_shikakari_hin
				, HAIGO_RECIPE.cd_hinmei
				, HAIGO_RECIPE.cd_hinmei AS cd_hinmei_old
				, Hin.nm_hinmei_ja
				, Hin.nm_hinmei_en
				, Hin.nm_hinmei_zh
				, Hin.nm_hinmei_ryaku
				, Hin.cd_tani_shiyo
				, Tani.nm_tani AS nm_tani_shiyo
				, Hin.nm_nisugata_hyoji
				, Hin.flg_trace_taishogai
				, HAIGO_RECIPE.no_kotei
				, HAIGO_RECIPE.no_tonyu
				, HAIGO_RECIPE.kbn_hin
				, ISNULL(CAST(TR_NIU.no_niuke AS VARCHAR(14)), NULL) AS no_niuke
				, TR_NIU.no_lot
				, NULL AS biko
			FROM (
				SELECT*
				FROM su_keikaku_shikakari
				WHERE CAST(dt_seizo AS DATE) = CAST(@dt_hiduke AS DATE)
				AND cd_shikakari_hin = @cd_hinmei
				AND no_lot_shikakari = @no_lot
				AND (su_batch_jisseki > @zero
				OR su_batch_jisseki_hasu > @zero)
			) SHI
			
			INNER JOIN (
				SELECT TOP 1
					cd_haigo
					,no_han
					,dt_from
				FROM dbo.ma_haigo_mei
				WHERE
					cd_haigo = @cd_hinmei
					AND flg_mishiyo = @flg_mishiyo
					AND CAST(dt_from AS DATE) <= CAST(@dt_hiduke AS DATE)
				ORDER BY no_han DESC
			) HAIGO_MEI
			ON SHI.cd_shikakari_hin = HAIGO_MEI.cd_haigo

			
			INNER JOIN ma_haigo_recipe HAIGO_RECIPE
			ON HAIGO_MEI.cd_haigo = HAIGO_RECIPE.cd_haigo
			AND HAIGO_MEI.no_han = HAIGO_RECIPE.no_han
			AND HAIGO_RECIPE.kbn_hin IN (@GenryoHinKbn, @ShikakariHinKbn, @JikaGenryoHinKbn)

			LEFT JOIN tr_niuke TR_NIU
			ON HAIGO_RECIPE.cd_hinmei = TR_NIU.cd_hinmei
			AND TR_NIU.kbn_nyushukko = @kbn_nyushukko
			AND CAST(TR_NIU.dt_niuke AS DATE) = CAST(@dt_hizuke_max AS DATE)

			LEFT JOIN ma_hinmei Hin
			ON HAIGO_RECIPE.cd_hinmei = Hin.cd_hinmei

			LEFT JOIN ma_tani Tani
			ON Hin.cd_tani_shiyo = Tani.cd_tani
			
			WHERE Hin.flg_mishiyo = @flg_mishiyo
			OR Hin.flg_mishiyo IS NULL
END