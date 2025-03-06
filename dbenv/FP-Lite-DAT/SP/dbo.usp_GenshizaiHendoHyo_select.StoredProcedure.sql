IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_GenshizaiHendoHyo_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_GenshizaiHendoHyo_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ========================================================================
-- 原資材変動表の検索処理
--  指定された品名コードの原資材、開始日付～終了日付の期間について、
--  日付毎に納入予実、使用予実、調整数、在庫数を抽出する。
-- Author:		kaneko.m
-- Create date: 2013.08.07
-- Last Update: 2020.11.18 wang.w 納入実績＆製造実績の表示仕様変更（小数点3桁まで表示）
--            : 2021.05.19 BRC.takaki 繰越在庫と計算在庫の表示差異を修正
--            : 2021.06.03 BRC.saito 当日の繰越在庫と計算在庫の表示差異を修正
--            : 2021.12.22 BRC.t.sato 確定チェックを外した場合、製造実績に表示しないよう修正
-- ========================================================================
CREATE PROCEDURE [dbo].[usp_GenshizaiHendoHyo_select]
	 @cd_hinmei			as varchar(14)	-- 品名コード
	,@dt_hizuke			as datetime		-- 検索日付：開始日
	,@flg_jisseki		as smallint		-- 定数：予実フラグ：実績
	,@flg_yotei			as smallint		-- 定数：予実フラグ：予定
	,@flg_shiyo			as smallint		-- 定数：未使用フラグ：使用
	,@cd_kg				as varchar(2)	-- 定数：単位コード：Kg
	,@cd_li				as varchar(2)	-- 定数：単位コード：L
	,@dt_hizuke_to		as datetime		-- 検索日付：終了日
	,@today				as datetime		-- 当日日付
	,@kbn_zaiko_ryohin	as SMALLINT		-- 定数：在庫区分：良品
	,@count			int output
WITH RECOMPILE
AS
BEGIN

DECLARE @su_iri DECIMAL(5, 0)
DECLARE @wt_nonyu DECIMAL(12, 6)
DECLARE @cd_tani VARCHAR(10)
DECLARE @kbn_hin SMALLINT

SELECT 
	@su_iri = COALESCE(mk.su_iri,mh.su_iri, 1),
	@wt_nonyu = COALESCE(mk.wt_nonyu,mh.wt_ko, 1),
	@cd_tani = COALESCE(mk.cd_tani_nonyu,mh.cd_tani_shiyo),
	@kbn_hin = mh.kbn_hin
FROM ma_hinmei mh
LEFT JOIN (
	SELECT
		su_iri
		,wt_nonyu
		,cd_tani_nonyu
		,cd_hinmei
	FROM ma_konyu
	WHERE cd_hinmei = @cd_hinmei
		AND no_juni_yusen = (SELECT MIN(ko.no_juni_yusen) AS no_juni_yusen
							FROM ma_konyu ko WITH(NOLOCK)
							WHERE ko.flg_mishiyo = @flg_shiyo
								AND ko.cd_hinmei = @cd_hinmei 
							)
) mk
ON mh.cd_hinmei = mk.cd_hinmei
WHERE mh.cd_hinmei = @cd_hinmei

SELECT
	ROW_NUMBER() OVER (ORDER BY meisai.dt_hizuke)              AS 'no_row'
	,meisai.cd_hinmei                                          AS 'cd_hinmei' --品名コード
	,meisai.dt_hizuke                                          AS 'dt_ymd' --隠し項目日付
	,meisai.dt_hizuke                                          AS 'dt_hizuke' --日付
	,CONVERT(varchar, datepart(weekday, meisai.dt_hizuke) - 1) AS 'dt_yobi' --曜日（画面のIDと合わせるため1減算）
	,meisai.flg_kyujitsu                                       AS 'flg_kyujitsu' 
	,meisai.flg_shukujitsu                                     AS 'flg_shukujitsu'
	,CASE WHEN @cd_tani = @cd_kg OR @cd_tani = @cd_li
		-- KgまたはL
		THEN ROUND(meisai.su_nonyu_yotei * @wt_nonyu * @su_iri
			+ (meisai.su_nonyu_yotei_hasu / 1000 ),3,1)
		-- 上記以外
		ELSE ROUND(meisai.su_nonyu_yotei * @wt_nonyu * @su_iri 
			+ (meisai.su_nonyu_yotei_hasu * @wt_nonyu),3,1)
	 END														   AS 'su_nonyu_yotei'   --納入予定数
	,CASE WHEN @cd_tani = @cd_kg OR @cd_tani = @cd_li
		-- KgまたはL
		THEN ROUND(meisai.su_nonyu_jisseki * @wt_nonyu * @su_iri
			+ (meisai.su_nonyu_jisseki_hasu / 1000 ),3,1)
		-- 上記以外
		ELSE ROUND(meisai.su_nonyu_jisseki * @wt_nonyu * @su_iri 
			+ (meisai.su_nonyu_jisseki_hasu * @wt_nonyu),3,1)
	END														   AS 'su_nonyu_jisseki' --納入実績数
	,CEILING(meisai.su_shiyo_yotei*1000)/1000                  AS 'su_shiyo_yotei' --使用予定数
	,CEILING(meisai.su_shiyo_jisseki*1000)/1000                AS 'su_shiyo_jisseki' --使用実績数
	,CEILING(meisai.su_chosei*1000)/1000                       AS 'su_chosei' --調整数
	,0.00 AS 'su_keisanzaiko' --計算在庫数
	,ROUND(meisai.su_jitsuzaiko,3,1)      AS 'su_jitsuzaiko' --実在庫数
    ,ROUND(kurikoshi_zaiko.su_kurikoshi_zan,3,1)   AS 'su_kurikoshi_zan' --繰越在庫
	,@wt_nonyu		AS 'su_ko' --個重量
	,@su_iri		AS 'su_iri' --入数
	,@cd_tani	    AS 'cd_tani' --納入単位
FROM
-- ■明細情報(meisai) >> 日付毎の明細情報を抽出する■
(
    SELECT
        @cd_hinmei                                          AS 'cd_hinmei' --品名コード
        ,meisai_calendar.dt_hizuke                          AS 'dt_hizuke' --日付
        ,meisai_calendar.flg_kyujitsu                       AS 'flg_kyujitsu' 
        ,meisai_calendar.flg_shukujitsu                     AS 'flg_shukujitsu'
        ,COALESCE(meisai_nonyu_yotei.su_nonyu_yotei, 0.00)     AS 'su_nonyu_yotei' --納入予定数
		,COALESCE(meisai_nonyu_yotei.su_nonyu_yotei_hasu, 0.00) AS 'su_nonyu_yotei_hasu' --納入予定端数
        ,COALESCE(meisai_nonyu_jisseki.su_nonyu_jisseki, 0.00) AS 'su_nonyu_jisseki' --納入実績数
		,COALESCE(meisai_nonyu_jisseki.su_nonyu_jisseki_hasu, 0.00) AS 'su_nonyu_jisseki_hasu' --納入実績数
        ,COALESCE(meisai_shiyo_yotei.su_shiyo_yotei, 0)     AS 'su_shiyo_yotei' --使用予定数
        ,COALESCE(meisai_shiyo_jisseki.su_shiyo_jisseki, 0) AS 'su_shiyo_jisseki' --使用実績数
        ,COALESCE(meisai_chosei.su_chosei, 0)               AS 'su_chosei' --調整数
        ,meisai_zaiko.su_jitsuzaiko                         AS 'su_jitsuzaiko' --実在庫数
    FROM
    -- ■明細用カレンダー情報(meisai_calendar) >> カレンダーマスタ(ma_calendar)より、開始日～終了日の日付を抽出する■
    (
        SELECT
            [dt_hizuke] AS 'dt_hizuke' --日付
            ,[flg_kyujitsu] AS 'flg_kyujitsu'
            ,[flg_shukujitsu] AS 'flg_shukujitsu'
        FROM [ma_calendar]
        WHERE
            [dt_hizuke] BETWEEN @dt_hizuke AND @dt_hizuke_to --DATEADD(day, 31, @dt_hizuke)
    ) meisai_calendar
    LEFT OUTER JOIN
    -- ■明細用在庫(meisai_zaiko) >> 在庫トラン(tr_zaiko)より、開始日～終了日かつ当日以前の日付単位の在庫数を抽出する■
    (
        SELECT
            [dt_hizuke] AS 'dt_hizuke' --日付
            ,SUM(COALESCE([su_zaiko], 0))       AS 'su_jitsuzaiko' --実在庫数
        FROM [tr_zaiko]
        WHERE
            [dt_hizuke] BETWEEN @dt_hizuke AND @dt_hizuke_to --DATEADD(day, 31, @dt_hizuke)
			AND [dt_hizuke] <= @today
            AND [cd_hinmei] = @cd_hinmei
            AND kbn_zaiko = @kbn_zaiko_ryohin
        GROUP BY
            [dt_hizuke]
    ) meisai_zaiko
    ON meisai_calendar.dt_hizuke = meisai_zaiko.dt_hizuke
    LEFT OUTER JOIN
    -- ■明細用 納入予定or製造予定(meisai_nonyu_yotei) >> 納入予実トラン(tr_nonyu) or 製造計画トランより、開始日～終了日の日付単位の予定数を抽出する■
    (
        SELECT
            [dt_nonyu] AS 'dt_hizuke' --日付
            ,SUM(COALESCE([su_nonyu], 0.00))      AS 'su_nonyu_yotei' --納入予定数
			,SUM(COALESCE([su_nonyu_hasu], 0.00)) AS 'su_nonyu_yotei_hasu' --納入予定端数
        FROM [tr_nonyu]
        WHERE
            [flg_yojitsu] = @flg_yotei
            AND [dt_nonyu] BETWEEN @dt_hizuke AND @dt_hizuke_to --DATEADD(day, 31, @dt_hizuke)
            AND [cd_hinmei] = @cd_hinmei
        GROUP BY
            [dt_nonyu]
        UNION ALL
        SELECT
            [dt_seizo] AS 'dt_hizuke' --日付
            ,SUM(COALESCE([su_seizo_yotei], 0.00))      AS 'su_nonyu_yotei' --製造予定数
			,0
        FROM [tr_keikaku_seihin]
        WHERE
            [dt_seizo] BETWEEN @dt_hizuke AND @dt_hizuke_to --DATEADD(day, 31, @dt_hizuke)
            AND [cd_hinmei] = @cd_hinmei
        GROUP BY
            [dt_seizo]
    ) meisai_nonyu_yotei 
    ON meisai_calendar.dt_hizuke = meisai_nonyu_yotei.dt_hizuke
    LEFT OUTER JOIN
    -- ■明細用納入実績or製造実績(meisai_nonyu_jisseki) >> 納入予実トラン(tr_nonyu)より、開始日～終了日の日付単位の納入実績数を抽出する■
    (
        SELECT
            [dt_nonyu] AS 'dt_hizuke' --日付
            ,SUM(COALESCE([su_nonyu], 0.000))      AS 'su_nonyu_jisseki' --納入実績数
			,SUM(COALESCE([su_nonyu_hasu], 0.000)) AS 'su_nonyu_jisseki_hasu' --納入実績端数
        FROM [tr_nonyu]
        WHERE
            [flg_yojitsu] = @flg_jisseki
            AND [dt_nonyu] BETWEEN @dt_hizuke AND @dt_hizuke_to --DATEADD(day, 31, @dt_hizuke)
            AND [cd_hinmei] = @cd_hinmei
        GROUP BY
            [dt_nonyu]
        UNION ALL
        SELECT
            [dt_seizo] AS 'dt_hizuke' --日付
            ,SUM(COALESCE([su_seizo_jisseki], 0.00))      AS 'su_nonyu_yotei' --製造実績数
			,0
        FROM [tr_keikaku_seihin]
        WHERE
            [dt_seizo] BETWEEN @dt_hizuke AND @dt_hizuke_to --DATEADD(day, 31, @dt_hizuke)
            AND [cd_hinmei] = @cd_hinmei
            AND [flg_jisseki] = CASE WHEN @kbn_hin = 7
                                    -- kbn_hin=7(自家原料)の場合、flg_jissekiが1(製造日報チェック済み)のみ製造実績数に加算する
                                    THEN 1
                                    -- kbn_hinが7以外の場合、flg_jissekiに関わらずすべて製造実績数に加算する
                                    ELSE [flg_jisseki]
                                END
        GROUP BY
            [dt_seizo]
    ) meisai_nonyu_jisseki
    ON meisai_calendar.dt_hizuke = meisai_nonyu_jisseki.dt_hizuke
    LEFT OUTER JOIN
    -- ■明細用使用予定(meisai_shiyo_yotei) >> 使用予実トラン(tr_shiyo_yojitsu)より、開始日～終了日の日付単位の使用予定数を抽出する■
    (
        SELECT
            [dt_shiyo] AS 'dt_hizuke' --日付
            ,SUM(COALESCE(CEILING([su_shiyo]*1000)/1000 , 0))      AS 'su_shiyo_yotei' --使用予定数
        FROM [tr_shiyo_yojitsu]
        WHERE
            [flg_yojitsu] = @flg_yotei
            AND [dt_shiyo] BETWEEN @dt_hizuke AND @dt_hizuke_to --DATEADD(day, 31, @dt_hizuke)
            AND [cd_hinmei] = @cd_hinmei
        GROUP BY
            [dt_shiyo]
    ) meisai_shiyo_yotei
    ON meisai_calendar.dt_hizuke = meisai_shiyo_yotei.dt_hizuke
    LEFT OUTER JOIN
    -- ■明細用使用実績(meisai_shiyo_jisseki) >> 使用予実トラン(tr_shiyo_yojitsu)より、開始日～終了日の日付単位の使用実績数を抽出する■
    (
        SELECT
            [dt_shiyo] AS 'dt_hizuke' --日付
            ,SUM(COALESCE(CEILING([su_shiyo]*1000)/1000, 0))      AS 'su_shiyo_jisseki' --使用実績数
        FROM [tr_shiyo_yojitsu]
        WHERE
            [flg_yojitsu] = @flg_jisseki
            AND [dt_shiyo] BETWEEN @dt_hizuke AND @dt_hizuke_to --DATEADD(day, 31, @dt_hizuke)
            AND [cd_hinmei] = @cd_hinmei
        GROUP BY
            [dt_shiyo]
    ) meisai_shiyo_jisseki
    ON meisai_calendar.dt_hizuke = meisai_shiyo_jisseki.dt_hizuke
    LEFT OUTER JOIN
    -- ■明細用調整(meisai_chosei) >> 調整トラン(tr_chosei)より、開始日～終了日の日付単位の調整数を抽出する■
    (
        SELECT
            [dt_hizuke] AS 'dt_hizuke' --日付
            ,SUM(COALESCE([su_chosei], 0))      AS 'su_chosei' --調整数
        FROM [tr_chosei]
        WHERE
            [dt_hizuke] BETWEEN @dt_hizuke AND @dt_hizuke_to --DATEADD(day, 31, @dt_hizuke)
            AND [cd_hinmei] = @cd_hinmei
        GROUP BY
            [dt_hizuke]
    ) meisai_chosei
    ON meisai_calendar.dt_hizuke = meisai_chosei.dt_hizuke
) meisai

-- ■繰越在庫を算出する(kurikoshi_zaiko)■
-- 繰越在庫の精度を上げるため、開始日の45日前から計算する。
LEFT OUTER JOIN
(
	SELECT
		@cd_hinmei AS cd_hinmei
		,ruikei.dt_hizuke AS dt_hizuke
		 -- 実在庫が無い場合、前日の計算在庫数
		,COALESCE(ruikei_jitsuzaiko.su_jitsuzaiko, zenjitsu_keisanzaiko.su_zaiko, 0.00)
			-- 計算在庫数 + 納入数 - 使用数 - 調整数
				+ COALESCE(ruikei.su_nonyu_ruikei, 0.00)
				- COALESCE(ruikei.su_shiyo_ruikei, 0.000000)
				- COALESCE(ruikei.su_chosei_ruikei, 0.000000)
		 AS 'su_kurikoshi_zan' --繰越在庫
	FROM
	-- ■累計情報(ruikei)■
	-- ■日付毎に、その日付までの累計情報を抽出する■
	(
		SELECT
			ruikei_calendar.dt_hizuke    AS 'dt_hizuke' --日付
			,SUM(
				CASE WHEN @cd_tani = @cd_kg OR @cd_tani = @cd_li
					-- KgまたはL
					THEN ROUND(ruikei_meisai.su_nonyu * @wt_nonyu * @su_iri 
						+ (ruikei_meisai.su_nonyu_hasu / 1000 ),3,1)
					-- 上記以外
					ELSE ROUND(ruikei_meisai.su_nonyu * @wt_nonyu * @su_iri 
						+ (ruikei_meisai.su_nonyu_hasu * @wt_nonyu),3,1)
				END
			 ) AS 'su_nonyu_ruikei' --納入数累計
			,SUM(ruikei_meisai.su_shiyo)  AS 'su_shiyo_ruikei' --使用数累計
			,SUM(ruikei_meisai.su_chosei) AS 'su_chosei_ruikei' --調整数累計
		FROM
		-- ■累計用カレンダー情報(ruikei_calendar)■
		-- ■カレンダーマスタ(ma_calendar)より、開始日の45日前～開始日の日付を抽出する■
		(
			SELECT
				[dt_hizuke] AS 'dt_hizuke' --日付
			FROM [ma_calendar]
			WHERE
				[dt_hizuke] BETWEEN DATEADD(day, -45, @dt_hizuke) AND DATEADD(day, -1, @dt_hizuke)
		) ruikei_calendar
		LEFT JOIN
		-- ■累計用明細情報(ruikei_meisai)■
		-- ■日付毎に、その日付までの累計情報を算出するための明細情報を抽出する■
		(
			SELECT
				ruikei_meisai_calendar.dt_hizuke      AS 'dt_hizuke' --日付
				,COALESCE(ruikei_nonyu.su_nonyu, 0)   AS 'su_nonyu'  --納入数
				,COALESCE(ruikei_nonyu.su_nonyu_hasu, 0)   AS 'su_nonyu_hasu'  --納入数
				,COALESCE(ruikei_shiyo.su_shiyo, 0)   AS 'su_shiyo'  --使用数
				,COALESCE(ruikei_chosei.su_chosei, 0) AS 'su_chosei' --調整数
			FROM
			-- ■累計明細用カレンダー情報(ruikei_meisai_calendar)■
			-- ■カレンダーマスタ(ma_calendar)より、開始日の45日前～開始日の前日の日付を抽出する■
			(
				SELECT
					[dt_hizuke] AS 'dt_hizuke' --日付
				FROM [ma_calendar]
				WHERE
					[dt_hizuke] BETWEEN DATEADD(day, -45, @dt_hizuke) AND DATEADD(day, -1, @dt_hizuke)
			) ruikei_meisai_calendar
			LEFT OUTER JOIN
			-- ■累計明細用納入予実(ruikei_nonyu)■
			-- ■納入予実トラン(tr_nonyu) or 製造計画トランより、開始日の45日前～開始日の前日を抽出する■
			-- ■前日以前は実績から、当日以降は予定から納入数を抽出する■
			(
				------- ///納入実績
				SELECT
					[dt_nonyu] AS 'dt_hizuke' --日付
					,SUM(COALESCE([su_nonyu], 0.000))      AS 'su_nonyu' --納入数
					,SUM(COALESCE([su_nonyu_hasu], 0.000)) AS 'su_nonyu_hasu' --納入端数
				FROM [tr_nonyu]
				WHERE
					[flg_yojitsu] = @flg_jisseki
					AND [dt_nonyu] BETWEEN DATEADD(day, -45, @dt_hizuke) AND DATEADD(day, -1, @dt_hizuke)
					AND [dt_nonyu] < @today
					AND [cd_hinmei] = @cd_hinmei
				GROUP BY
					[dt_nonyu]
				UNION ALL
				------- ///納入予定
				SELECT
					nonyu_yotei.[dt_nonyu] AS 'dt_hizuke' --日付
					-- 当日に納入実績がある場合は実績優先
					,CASE WHEN (SUM(COALESCE(nonyu_jitsu.[su_nonyu], 0.000)) <> 0.000
								OR SUM(COALESCE(nonyu_jitsu.[su_nonyu_hasu], 0.000)) <> 0.000)
						THEN SUM(COALESCE(nonyu_jitsu.[su_nonyu], 0.000))
						ELSE SUM(COALESCE(nonyu_yotei.[su_nonyu], 0.000))
					 END AS 'su_nonyu' --納入数
					 -- 当日に納入実績がある場合は実績優先
					,CASE WHEN (SUM(COALESCE(nonyu_jitsu.[su_nonyu], 0.000)) <> 0.000
								OR SUM(COALESCE(nonyu_jitsu.[su_nonyu_hasu], 0.000)) <> 0.000)
						THEN SUM(COALESCE(nonyu_jitsu.[su_nonyu_hasu], 0.000))
						ELSE SUM(COALESCE(nonyu_yotei.[su_nonyu_hasu], 0.000))
					 END AS 'su_nonyu_hasu' --納入端数
				FROM [tr_nonyu] nonyu_yotei
				LEFT JOIN [tr_nonyu] nonyu_jitsu
				ON nonyu_yotei.[no_nonyu] = nonyu_jitsu.[no_nonyu]
				AND nonyu_yotei.[dt_nonyu] = nonyu_jitsu.[dt_nonyu]
				AND nonyu_jitsu.[flg_yojitsu] = @flg_jisseki
				AND nonyu_jitsu.[dt_nonyu] = @today
				WHERE
					nonyu_yotei.[flg_yojitsu] = @flg_yotei
					AND nonyu_yotei.[dt_nonyu] BETWEEN DATEADD(day, -45, @dt_hizuke) AND DATEADD(day, -1, @dt_hizuke)
					AND nonyu_yotei.[dt_nonyu] >= @today
					AND nonyu_yotei.[cd_hinmei] = @cd_hinmei
				GROUP BY
					nonyu_yotei.[dt_nonyu]
				UNION ALL
				------- ///製造実績
				SELECT
					[dt_seizo] AS 'dt_hizuke' --日付
					,SUM(COALESCE([su_seizo_jisseki], 0.000)) AS 'su_nonyu_yotei' --製造予定数
					,0.000 AS 'su_nonyu_hasu'
				FROM [tr_keikaku_seihin]
				WHERE
					[dt_seizo] BETWEEN DATEADD(day, -45, @dt_hizuke) AND DATEADD(day, -1, @dt_hizuke)
					AND [dt_seizo] < @today
					AND [cd_hinmei] = @cd_hinmei
				GROUP BY
					[dt_seizo]
				UNION ALL
				------- ///製造予定
				SELECT
					[dt_seizo] AS 'dt_hizuke' --日付
					-- 当日に製造実績がある場合は実績優先
					,CASE WHEN (SUM(COALESCE([su_seizo_jisseki], 0.000)) <> 0.000 AND [dt_seizo] = @today)
						THEN SUM(COALESCE([su_seizo_jisseki], 0.000))
						ELSE SUM(COALESCE([su_seizo_yotei], 0.000))
					 END AS 'su_nonyu_yotei' --製造予定数
					,0.000 AS 'su_nonyu_hasu'
				FROM [tr_keikaku_seihin]
				WHERE
					[dt_seizo] BETWEEN DATEADD(day, -45, @dt_hizuke) AND DATEADD(day, -1, @dt_hizuke)
					AND [dt_seizo] >= @today
					AND [cd_hinmei] = @cd_hinmei
				GROUP BY
					[dt_seizo]
			) ruikei_nonyu
			ON ruikei_meisai_calendar.dt_hizuke = ruikei_nonyu.dt_hizuke
			LEFT OUTER JOIN
			-- ■累計明細用使用予実(ruikei_shiyo)■
			-- ■使用予実トラン(tr_shiyo_yojitsu)より、開始日の45日前～開始日の前日を抽出する■
			-- ■前日以前は実績から、当日以降は予定から使用数を抽出する■
			(
				SELECT
					[dt_shiyo] AS 'dt_hizuke' --日付
					,SUM(COALESCE(CEILING([su_shiyo]*1000)/1000, 0))      AS 'su_shiyo' --使用数
				FROM [tr_shiyo_yojitsu]
				WHERE
					[flg_yojitsu] = @flg_jisseki
					AND [dt_shiyo] BETWEEN DATEADD(day, -45, @dt_hizuke) AND DATEADD(day, -1, @dt_hizuke)
					AND [dt_shiyo] < @today
					AND [cd_hinmei] = @cd_hinmei
				GROUP BY
					[dt_shiyo]
				UNION
				SELECT
					[dt_shiyo] AS 'dt_hizuke' --日付
					,SUM(COALESCE(CEILING([su_shiyo]*1000)/1000, 0))      AS 'su_shiyo' --使用数
				FROM [tr_shiyo_yojitsu]
				WHERE
					[flg_yojitsu] = @flg_yotei
					AND [dt_shiyo] BETWEEN DATEADD(day, -45, @dt_hizuke) AND DATEADD(day, -1, @dt_hizuke)
					AND [dt_shiyo] >= @today
					AND [cd_hinmei] = @cd_hinmei
				GROUP BY
					[dt_shiyo]
			) ruikei_shiyo
			ON ruikei_meisai_calendar.dt_hizuke = ruikei_shiyo.dt_hizuke
			LEFT OUTER JOIN
			-- ■累計明細用調整(ruikei_chosei)■
			-- ■調整トラン(tr_chosei)より、開始日の45日前～開始日の前日を抽出する■
			(
				SELECT
					[dt_hizuke] AS 'dt_hizuke' --日付
					,SUM(COALESCE([su_chosei], 0))      AS 'su_chosei' --調整数
				FROM [tr_chosei]
				WHERE
					[dt_hizuke] BETWEEN DATEADD(day, -45, @dt_hizuke) AND DATEADD(day, -1, @dt_hizuke)
					AND [cd_hinmei] = @cd_hinmei
				GROUP BY
					[dt_hizuke]
			) ruikei_chosei
			ON ruikei_meisai_calendar.dt_hizuke = ruikei_chosei.dt_hizuke
		) ruikei_meisai
		-- ■累計の対象は、前日以前で直近の実在庫が存在する日付の翌日からその日付までとする■
		ON ruikei_calendar.dt_hizuke >= ruikei_meisai.dt_hizuke
		AND ruikei_meisai.dt_hizuke > COALESCE((SELECT MAX([dt_hizuke]) AS dt_hizuke
											   FROM [tr_zaiko]
											   WHERE [dt_hizuke] >= DATEADD(day, -45, @dt_hizuke)
													AND [dt_hizuke] <= ruikei_calendar.dt_hizuke
													AND [dt_hizuke] <= @today
													AND [cd_hinmei] = @cd_hinmei
													AND kbn_zaiko = @kbn_zaiko_ryohin), 0)
		GROUP BY
			ruikei_calendar.dt_hizuke
	) ruikei

	LEFT OUTER JOIN
	-- ■累計用直近実在庫情報■
	-- ■日付毎に実在庫情報を抽出する■
	(
		SELECT
			[dt_hizuke] AS 'dt_hizuke' --日付
			,SUM(COALESCE([su_zaiko], 0)) AS 'su_jitsuzaiko' --実在庫数
		FROM [tr_zaiko]
		WHERE
			[dt_hizuke] BETWEEN DATEADD(day, -45, @dt_hizuke) AND DATEADD(day, -1, @dt_hizuke)
			AND [dt_hizuke] <= @today
			AND [cd_hinmei] = @cd_hinmei
			AND kbn_zaiko = @kbn_zaiko_ryohin
		GROUP BY
			[dt_hizuke]
	) ruikei_jitsuzaiko
	ON ruikei_jitsuzaiko.dt_hizuke = (SELECT MAX([dt_hizuke])
									  FROM [tr_zaiko]
                                      WHERE [dt_hizuke] BETWEEN DATEADD(day, -45, @dt_hizuke) AND ruikei.dt_hizuke
                                      AND [dt_hizuke] <= @today
                                      AND [cd_hinmei] = @cd_hinmei
                                      AND kbn_zaiko = @kbn_zaiko_ryohin)
	LEFT OUTER JOIN
	-- ■前日計算在庫情報(zenjitsu_keisanzaiko) >> 開始日の46日前の計算在庫情報を抽出する■
	(
		SELECT
			[cd_hinmei] AS 'cd_hinmei'
			,[dt_hizuke]
			,[su_zaiko] 
		FROM [tr_zaiko_keisan]
		WHERE
			[dt_hizuke] = DATEADD(day, -46, @dt_hizuke)
			AND [cd_hinmei] = @cd_hinmei
	) zenjitsu_keisanzaiko
	ON 1 = 1

	WHERE ruikei.dt_hizuke = DATEADD(day, -1, @dt_hizuke)
) kurikoshi_zaiko
ON meisai.cd_hinmei = kurikoshi_zaiko.cd_hinmei

ORDER BY
	 meisai.dt_hizuke
SET @count = @@ROWCOUNT
END

GO
