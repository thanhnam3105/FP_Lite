IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_NonyuYoteiListSakusei_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_NonyuYoteiListSakusei_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===============================================
-- Author:		higashiya.s
-- Create date: 2013.07.23
-- Last Update: 2015.02.25 tsujita.s
--              2018.08.09 nakamura.r(納入書No不具合修正
--              2019.10.17 brc.kanehira 分納した実績データが正常に取得できるように修正
-- Description:	納入予定リスト作成：データ抽出処理
-- ===============================================
CREATE PROCEDURE [dbo].[usp_NonyuYoteiListSakusei_select]
	 @con_dt_nonyu datetime
	,@con_kbn_hin varchar(6)
	,@con_cd_bunrui varchar(10)
	,@con_kbn_hokan varchar(10)
	,@con_cd_torihiki varchar(13)
	,@flg_yojitsu_yo smallint
	,@flg_yojitsu_ji smallint
	,@flg_mishiyo smallint
	,@cdTani_kg varchar(2)
	,@cdTani_li varchar(2)
	,@ryohinZaikoKubun	SMALLINT

AS
BEGIN

	DECLARE @minSeqNo DECIMAL(8,0)

	-- ============
	-- 変数の初期化
	-- ============
	SET @con_kbn_hin =
			(SELECT
				CASE WHEN @con_kbn_hin IS NULL
					 THEN ''
					 ELSE @con_kbn_hin
					 END)
	SET @con_cd_bunrui =
			(SELECT
				CASE WHEN @con_cd_bunrui IS NULL
					 THEN ''
					 ELSE @con_cd_bunrui
					 END)
	SET @con_kbn_hokan =
			(SELECT
				CASE WHEN @con_kbn_hokan IS NULL
					 THEN ''
					 ELSE @con_kbn_hokan
					 END)
	SET @con_cd_torihiki =
			(SELECT
				CASE WHEN @con_cd_torihiki IS NULL
					 THEN ''
					 ELSE @con_cd_torihiki
					 END)
	SET @minSeqNo =
		(SELECT
			MIN(niu.no_seq)
		 FROM tr_niuke niu)

	-- ==============
	-- データ抽出処理
	-- ==============
	SELECT
		 NONYU.no_nonyu          AS no_nonyu
		,NONYU.flg_kakutei       AS flg_kakutei
		,NONYU.no_nonyusho       AS no_nonyusho
		,ma_bunrui.nm_bunrui     AS nm_bunrui
		,NONYU.cd_hinmei         AS cd_hinmei
		,HIN.nm_hinmei_ja        AS nm_hinmei_ja
		,HIN.nm_hinmei_en        AS nm_hinmei_en
		,HIN.nm_hinmei_zh        AS nm_hinmei_zh
		,HIN.nm_hinmei_vi        AS nm_hinmei_vi
		,KONYU.nm_nisugata_hyoji AS nm_nisugata_hyoji
		,KONYU.cd_tani_nonyu     AS cd_tani_nonyu
		,ma_tani.nm_tani         AS nm_tani
		,KONYU.cd_tani_nonyu_hasu AS cd_tani_nonyu_hasu
		,ma_tani_hasu.nm_tani    AS nm_tani_hasu

		---- 納入単位がKgまたはLの場合は、端数を正規数に加算する
		----,NONYU.su_nonyu_yo       AS su_nonyu_yo
		----,dbo.udf_NonyuHasuKanzan(
		----	KONYU.cd_tani_nonyu, HIN.cd_tani_nonyu,
		----	NONYU.su_nonyu_yo, NONYU.su_nonyu_yo_hasu, @cdTani_kg, @cdTani_li) AS su_nonyu_yo
		,NONYU.su_nonyu_yo       AS su_nonyu_yo
		,NONYU.su_nonyu_yo_hasu  AS su_nonyu_yo_hasu

		,NONYU.su_nonyu_ji       AS su_nonyu_ji
		,NONYU.save_su_nonyu_ji  AS save_su_nonyu_ji
		,NONYU.su_nonyu_hasu     AS su_nonyu_hasu
		,NONYU.tan_nonyu         AS tan_nonyu
		,KONYU.tan_nonyu         AS ma_tan_nonyu
		,KONYU.tan_nonyu_new     AS ma_tan_nonyu_new
		,KONYU.dt_tanka_new      AS ma_dt_tanka_new
		,KONYU.su_iri            AS su_iri
		,NONYU.kin_kingaku       AS kin_kingaku
		,NONYU.kbn_zei           AS kbn_zei
		,ma_zei.nm_zei           AS nm_zei
		,NONYU.cd_torihiki       AS cd_torihiki
		,TORIHIKI_1.nm_torihiki  AS nm_torihiki
		,NONYU.cd_torihiki2      AS cd_torihiki2
		,TORIHIKI_2.nm_torihiki  AS nm_torihiki2
		,NONYU.dt_nonyu_hyoji    AS dt_nonyu
		,NONYU.kbn_nyuko         AS kbn_nyuko
		,NONYU.dt_nonyu_yotei    AS dt_nonyu_yotei
		,NONYU.dt_nonyu_yotei    AS save_dt_nonyu_yotei
		,NONYU.cd_torihiki_yotei AS cd_torihiki_yotei
		,NONYU.no_nonyu_yotei	 AS no_nonyu_yotei
		,niuke.isExistsNiukeJisseki AS isExistsNiukeJisseki	-- 荷受に納入番号と紐づく実績データがある場合は１
	FROM (
	   SELECT
			-- 品名コード、確定フラグ、納入書番号、納入単位、金額、税区分、取引先1、取引先2
			-- 上記の項目に関して、実績の納入番号が取得できなかった場合は予定の値を設定する
			 COALESCE(JI.no_nonyu, YO.no_nonyu)         AS no_nonyu
			,CASE WHEN JI.no_nonyu IS NULL
			THEN YO.cd_hinmei ELSE JI.cd_hinmei END AS cd_hinmei
			,CASE WHEN JI.no_nonyu IS NULL
			THEN YO.flg_kakutei ELSE JI.flg_kakutei END AS flg_kakutei
			,CASE WHEN JI.no_nonyusho IS NULL
			THEN YO.no_nonyusho ELSE JI.no_nonyusho END AS no_nonyusho
			,YO.su_nonyu                                AS su_nonyu_yo
			,YO.su_nonyu_hasu                           AS su_nonyu_yo_hasu
			,JI.su_nonyu                                AS su_nonyu_ji
			,JI.su_nonyu                                AS save_su_nonyu_ji
			,JI.su_nonyu_hasu                           AS su_nonyu_hasu
			,CASE WHEN JI.no_nonyu IS NULL
			THEN YO.tan_nonyu ELSE JI.tan_nonyu END AS tan_nonyu
			,CASE WHEN JI.no_nonyu IS NULL
			THEN YO.kin_kingaku ELSE JI.kin_kingaku END AS kin_kingaku
			,CASE WHEN JI.no_nonyu IS NULL
			THEN YO.kbn_zei ELSE JI.kbn_zei END AS kbn_zei
			,CASE WHEN JI.no_nonyu IS NULL
			THEN YO.cd_torihiki ELSE JI.cd_torihiki END AS cd_torihiki
			,CASE WHEN JI.no_nonyu IS NULL
			THEN YO.cd_torihiki2 ELSE JI.cd_torihiki2 END AS cd_torihiki2
			--,COALESCE(YO.dt_nonyu, JI.dt_nonyu)         AS dt_nonyu
			,YO.dt_nonyu								AS dt_nonyu
			--,COALESCE(JI.dt_nonyu, YO.dt_nonyu)         AS dt_nonyu_hyoji
			,JI.dt_nonyu						        AS dt_nonyu_hyoji
			,YO.kbn_nyuko						       AS kbn_nyuko
			,YO.dt_nonyu                                AS dt_nonyu_yotei
			,YO.cd_torihiki                             AS cd_torihiki_yotei
			,JI.no_nonyu_yotei							AS no_nonyu_yotei
		FROM (
		    SELECT
				 tr.no_nonyu
				,tr.cd_hinmei
				,tr.flg_kakutei
				,tr.no_nonyusho
				,tr.su_nonyu
				,tr.su_nonyu_hasu
				,tr.tan_nonyu
				,tr.kin_kingaku
				,tr.kbn_zei
				,tr.cd_torihiki
				,tr.cd_torihiki2
				,tr.dt_nonyu
				,tr.kbn_nyuko
			FROM
				tr_nonyu tr
			WHERE
				tr.flg_yojitsu = @flg_yojitsu_yo
			--AND dt_nonyu = @con_dt_nonyu
		) YO
		--FULL OUTER JOIN (
		LEFT OUTER JOIN (
		    SELECT
				 no_nonyu
				,cd_hinmei
				,flg_kakutei
				,no_nonyusho
				,su_nonyu
				,su_nonyu_hasu
				,tan_nonyu
				,kin_kingaku
				,kbn_zei
				,cd_torihiki
				,cd_torihiki2
				,dt_nonyu
				,kbn_nyuko
				,no_nonyu_yotei
			FROM
				tr_nonyu
			WHERE
				flg_yojitsu = @flg_yojitsu_ji
			--AND dt_nonyu = @con_dt_nonyu
		) JI
		ON YO.no_nonyu = JI.no_nonyu
		--ON YO.no_nonyu = JI.no_nonyu_yotei
		WHERE
			JI.dt_nonyu = @con_dt_nonyu
		OR YO.dt_nonyu = @con_dt_nonyu
		
		UNION
		
		SELECT
			-- 品名コード、確定フラグ、納入書番号、納入単位、金額、税区分、取引先1、取引先2
			-- 上記の項目に関して、実績の納入番号が取得できなかった場合は予定の値を設定する
			 COALESCE(JI.no_nonyu, YO.no_nonyu)         AS no_nonyu
			,CASE WHEN JI.no_nonyu IS NULL
			THEN YO.cd_hinmei ELSE JI.cd_hinmei END AS cd_hinmei
			,CASE WHEN JI.no_nonyu IS NULL
			THEN YO.flg_kakutei ELSE JI.flg_kakutei END AS flg_kakutei
			,CASE WHEN JI.no_nonyusho IS NULL
			THEN YO.no_nonyusho ELSE JI.no_nonyusho END AS no_nonyusho
			,YO.su_nonyu                                AS su_nonyu_yo
			,YO.su_nonyu_hasu                           AS su_nonyu_yo_hasu
			,JI.su_nonyu                                AS su_nonyu_ji
			,JI.su_nonyu                                AS save_su_nonyu_ji
			,JI.su_nonyu_hasu                           AS su_nonyu_hasu
			,CASE WHEN JI.no_nonyu IS NULL
			THEN YO.tan_nonyu ELSE JI.tan_nonyu END AS tan_nonyu
			,CASE WHEN JI.no_nonyu IS NULL
			THEN YO.kin_kingaku ELSE JI.kin_kingaku END AS kin_kingaku
			,CASE WHEN JI.no_nonyu IS NULL
			THEN YO.kbn_zei ELSE JI.kbn_zei END AS kbn_zei
			,CASE WHEN JI.no_nonyu IS NULL
			THEN YO.cd_torihiki ELSE JI.cd_torihiki END AS cd_torihiki
			,CASE WHEN JI.no_nonyu IS NULL
			THEN YO.cd_torihiki2 ELSE JI.cd_torihiki2 END AS cd_torihiki2
			,YO.dt_nonyu								AS dt_nonyu
			,JI.dt_nonyu						        AS dt_nonyu_hyoji
			,YO.kbn_nyuko						       AS kbn_nyuko
			,YO.dt_nonyu                                AS dt_nonyu_yotei
			,YO.cd_torihiki                             AS cd_torihiki_yotei
			,JI.no_nonyu_yotei							AS no_nonyu_yotei
		FROM
		(
			SELECT
				 tr.no_nonyu
				,tr.cd_hinmei
				,tr.flg_kakutei
				,tr.no_nonyusho
				,tr.su_nonyu
				,tr.su_nonyu_hasu
				,tr.tan_nonyu
				,tr.kin_kingaku
				,tr.kbn_zei
				,tr.cd_torihiki
				,tr.cd_torihiki2
				,tr.dt_nonyu
				,tr.kbn_nyuko
			FROM
				tr_nonyu tr
			WHERE
				tr.flg_yojitsu = @flg_yojitsu_yo
		) YO
		LEFT OUTER JOIN (
		    SELECT
				 no_nonyu
				,cd_hinmei
				,flg_kakutei
				,no_nonyusho
				,su_nonyu
				,su_nonyu_hasu
				,tan_nonyu
				,kin_kingaku
				,kbn_zei
				,cd_torihiki
				,cd_torihiki2
				,dt_nonyu
				,kbn_nyuko
				,no_nonyu_yotei
			FROM
				tr_nonyu
			WHERE
				flg_yojitsu = @flg_yojitsu_ji
		) JI
		ON
			YO.no_nonyu = JI.no_nonyu_yotei
		WHERE
			JI.dt_nonyu = @con_dt_nonyu
			OR YO.dt_nonyu = @con_dt_nonyu
	) NONYU

	LEFT OUTER JOIN
		ma_hinmei HIN
	ON NONYU.cd_hinmei = HIN.cd_hinmei
	AND HIN.flg_mishiyo = @flg_mishiyo

	LEFT OUTER JOIN
	   (SELECT
			 ma_konyu.cd_hinmei
			,ma_konyu.cd_torihiki
			,ma_konyu.nm_nisugata_hyoji
			,ma_konyu.cd_tani_nonyu
			,ma_konyu.cd_tani_nonyu_hasu
			,ma_konyu.tan_nonyu
			,ma_konyu.su_iri
			,ma_konyu.tan_nonyu_new
			,ma_konyu.dt_tanka_new
		FROM
			ma_konyu
		WHERE
			flg_mishiyo = @flg_mishiyo
	) KONYU
	ON NONYU.cd_hinmei = KONYU.cd_hinmei
	AND NONYU.cd_torihiki = KONYU.cd_torihiki

	LEFT OUTER JOIN
		ma_bunrui
	ON HIN.kbn_hin = ma_bunrui.kbn_hin
	AND HIN.cd_bunrui = ma_bunrui.cd_bunrui
	AND ma_bunrui.flg_mishiyo = @flg_mishiyo

	LEFT OUTER JOIN
		ma_zei
	ON NONYU.kbn_zei = ma_zei.kbn_zei

	LEFT OUTER JOIN
		ma_tani
	ON KONYU.cd_tani_nonyu = ma_tani.cd_tani
	AND ma_tani.flg_mishiyo = @flg_mishiyo

	LEFT OUTER JOIN ma_tani ma_tani_hasu
	ON KONYU.cd_tani_nonyu_hasu = ma_tani_hasu.cd_tani
	AND ma_tani_hasu.flg_mishiyo = @flg_mishiyo
	LEFT OUTER JOIN
		ma_torihiki TORIHIKI_1
	ON NONYU.cd_torihiki = TORIHIKI_1.cd_torihiki
	AND TORIHIKI_1.flg_mishiyo = @flg_mishiyo

	LEFT OUTER JOIN
		ma_torihiki TORIHIKI_2
	ON NONYU.cd_torihiki2 = TORIHIKI_2.cd_torihiki
	AND TORIHIKI_2.flg_mishiyo = @flg_mishiyo

	LEFT OUTER JOIN
		(
			SELECT DISTINCT
				niu.no_nonyu
				,CASE
					WHEN (ISNULL(niu.su_nonyu_jitsu, 0) + ISNULL(niu.su_nonyu_jitsu_hasu, 0)) > 0 THEN '1'
					ELSE ''
				END						 AS isExistsNiukeJisseki	-- 荷受に納入番号と紐づく実績データがある場合は１
			FROM tr_niuke niu
			WHERE
				niu.kbn_zaiko = @ryohinZaikoKubun
				AND niu.no_seq = @minSeqNo
		) niuke
	ON NONYU.no_nonyu = niuke.no_nonyu

	WHERE
		--NONYU.dt_nonyu = @con_dt_nonyu
	-- 以下の条件については、指定された場合のみ検索条件に含める
	-- (指定されていない場合(NULLの場合)は、全件取得される)
--	AND (LEN(@con_kbn_hin) = 0 OR
--		 HIN.kbn_hin = CONVERT(smallint, @con_kbn_hin))
	(LEN(@con_kbn_hin) = 0 OR
		 HIN.kbn_hin = CONVERT(smallint, @con_kbn_hin))
	AND (LEN(@con_cd_bunrui) = 0 OR
		 HIN.cd_bunrui = @con_cd_bunrui)
	AND (LEN(@con_kbn_hokan) = 0 OR
		 HIN.kbn_hokan = @con_kbn_hokan)
	AND (LEN(@con_cd_torihiki) = 0 OR
		 NONYU.cd_torihiki = @con_cd_torihiki)
	ORDER BY
		NONYU.cd_hinmei,
		NONYU.cd_torihiki,
		NONYU.no_nonyu_yotei,
		NONYU.no_nonyu

END
GO
