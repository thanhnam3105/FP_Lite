IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_GenryoLotToroku_select_03') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_GenryoLotToroku_select_03]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      <SangVM>
-- Create date: <Create Date: 2016/03>
-- Last Update: <2016/01/11 BRC.kanehira>
-- Last Update: <2019/11/15 BRC.saito>
-- Description: <Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_GenryoLotToroku_select_03]
	@dt_hiduke 		DATETIME
  , @cd_hinmei		VARCHAR(14)
  , @no_lot     	VARCHAR(14)
  , @no_tonyu       DECIMAL(4,0)
AS
BEGIN
	DECLARE @dt_hizuke_max	  DATETIME
	DECLARE @zero			  SMALLINT
	DECLARE @kbn_nyushukko	  SMALLINT
	DECLARE @kowake_count   SMALLINT
	DECLARE @tonyu_count    SMALLINT

	SET @zero = 0
	SET @kbn_nyushukko = 3
	
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

	--SELECT DISTINCT
		--no_niuke
		--, no_lot
	--FROM tr_niuke
	--WHERE cd_hinmei = @cd_hinmei
	--AND kbn_nyushukko = @kbn_nyushukko
	--AND CAST(dt_niuke AS DATE) = CAST(@dt_hizuke_max AS DATE)
	
		SELECT DISTINCT
			-- 優先順位：①　投入あり、小分けありの荷受No
			--           ②　投入あり、小分けなしの荷受No
			--           ③　投入なし、小分けありの荷受No
			--           ④　投入なし、小分けなしの荷受No（前日庫出し）
			CASE WHEN TR_KOWA1.no_lot_kowake IS NOT NULL THEN TR_NIU2.no_niuke
				 WHEN TR_TONYU.no_lot IS NOT NULL THEN TR_NIU1.no_niuke
				 WHEN TR_KOWA2.no_lot_kowake IS NOT NULL THEN TR_NIU3.no_niuke
				 --ELSE ISNULL(CAST(TR_NIU4.no_niuke AS VARCHAR(14)), NULL)
			END  AS no_niuke
			-- 投入、小分に紐づく荷受がない場合はNULLを設定する。
			-- 荷受に紐づく場合は下記条件でロットNoを取得する。
			-- 優先順位：①　投入あり、小分けありのロットNo
			--           ②　投入あり、小分けなしのロットNo
			--           ③　投入なし、小分けありのロットNo
			--           ④　投入なし、小分けなしのロットNo（前日庫出し）
			, CASE WHEN TR_KOWA1.no_lot_kowake IS NOT NULL THEN TR_NIU2.no_lot
				   WHEN TR_TONYU.no_lot IS NOT NULL THEN TR_NIU1.no_lot
				   WHEN TR_KOWA2.no_lot_kowake IS NOT NULL THEN TR_NIU3.no_lot
				   --ELSE TR_NIU4.no_lot
			  END  AS no_lot  
		FROM (
			SELECT*
			FROM su_keikaku_shikakari
			WHERE CAST(dt_seizo AS DATE) = CAST(@dt_hiduke AS DATE)
				AND no_lot_shikakari = @no_lot
		) SHI

		-- 投入の情報取得：開始
		LEFT JOIN tr_tonyu TR_TONYU
			ON SHI.cd_shokuba = TR_TONYU.cd_shokuba
			AND SHI.cd_line = TR_TONYU.cd_line
			AND SHI.cd_shikakari_hin = TR_TONYU.cd_haigo
			AND TR_TONYU.cd_hinmei = @cd_hinmei
			AND TR_TONYU.no_tonyu = @no_tonyu
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

		LEFT JOIN tr_lot TR_LOT1
			ON TR_KOWA1.no_lot_kowake = TR_LOT1.no_lot_jisseki
			
		--荷姿ラベルを読み込んだ場合は投入と荷受を紐づける
		LEFT JOIN  (
					SELECT 
						MAX(niuke.no_niuke) AS no_niuke
						,niuke.cd_hinmei
						,niuke.dt_seizo
						,niuke.dt_kigen
						,niuke.no_lot
					FROM tr_niuke niuke
					GROUP BY niuke.cd_hinmei,niuke.dt_seizo, niuke.dt_kigen, niuke.no_lot
				  )TR_NIU1
			ON  TR_NIU1.cd_hinmei = @cd_hinmei
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
					GROUP BY niuke.cd_hinmei,niuke.dt_seizo, niuke.dt_kigen, niuke.no_lot
				  )TR_NIU2
			ON  TR_NIU2.cd_hinmei = @cd_hinmei
			--AND TR_LOT1.dt_seizo_genryo = TR_NIU2.dt_seizo
			AND ISNULL(TR_LOT1.dt_seizo_genryo,'') = TR_NIU2.dt_seizo
			AND TR_LOT1.dt_shomi = TR_NIU2.dt_kigen
			AND TR_LOT1.no_lot = TR_NIU2.no_lot
		-- 投入の情報取得：終了

		-- 小分けの情報取得：開始
		LEFT JOIN tr_kowake TR_KOWA2
			ON TR_KOWA2.cd_hinmei = @cd_hinmei
			AND SHI.cd_line = TR_KOWA2.cd_line
			AND SHI.no_lot_shikakari = TR_KOWA2.no_lot_seihin
			AND TR_KOWA2.no_tonyu = @no_tonyu

		LEFT JOIN tr_lot TR_LOT2
			ON TR_KOWA2.no_lot_kowake = TR_LOT2.no_lot_jisseki

		LEFT JOIN (
					SELECT 
						MAX(niuke.no_niuke) AS no_niuke
						,niuke.cd_hinmei
						--,niuke.dt_seizo
						,ISNULL(niuke.dt_seizo,'') AS dt_seizo
						,niuke.dt_kigen
						,niuke.no_lot
						FROM tr_niuke niuke
					GROUP BY niuke.cd_hinmei,niuke.dt_seizo, niuke.dt_kigen, niuke.no_lot
				  )TR_NIU3
			ON  TR_NIU3.cd_hinmei = @cd_hinmei
			--AND TR_LOT2.dt_seizo_genryo = TR_NIU3.dt_seizo
			AND ISNULL(TR_LOT2.dt_seizo_genryo,'') = TR_NIU3.dt_seizo
			AND TR_LOT2.dt_shomi = TR_NIU3.dt_kigen
			AND TR_LOT2.no_lot = TR_NIU3.no_lot 
		-- 小分けの情報取得：終了

		-- 前日庫出しした情報取得：開始
		--LEFT JOIN tr_niuke TR_NIU4
			--ON TR_NIU4.cd_hinmei = @cd_hinmei
			--AND TR_NIU4.kbn_nyushukko = @kbn_nyushukko
			--AND CAST(TR_NIU4.dt_niuke AS DATE) = CAST(@dt_hizuke_max AS DATE)
		-- 前日庫出しした情報取得：終了
		
	ELSE
	
		SELECT DISTINCT
		no_niuke
		, no_lot
		FROM tr_niuke

		WHERE cd_hinmei = @cd_hinmei
		AND kbn_nyushukko = @kbn_nyushukko
		AND CAST(dt_niuke AS DATE) = CAST(@dt_hizuke_max AS DATE)
	
END