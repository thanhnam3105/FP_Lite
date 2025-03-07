IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_GenshizaiZaikoNyuryoku_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_GenshizaiZaikoNyuryoku_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===============================================
-- Author:		tsujita.s
-- Create date: 2013.08.06
-- Last Update: 2018.10.09 motojima.m
--              2022.04.20 quang.l
-- Description:	原資材在庫入力
--    データ抽出処理と在庫数・金額の計算処理
-- ===============================================
CREATE PROCEDURE [dbo].[usp_GenshizaiZaikoNyuryoku_select]
	 @con_dt_zaiko			datetime		-- 検索条件：在庫日付
	,@con_kbn_hin			varchar(2)		-- 検索条件：品区分
	,@con_hin_bunrui		varchar(10)		-- 検索条件：品分類
	,@con_kurabasho			varchar(10)		-- 検索条件：倉場所
	--,@con_hinmei			varchar(50)		-- 検索条件：品名
	,@con_hinmei			nvarchar(50)	-- 検索条件：品名
	,@flg_shiyobun			smallint		-- 検索条件：0…使用分、1…未使用分、2…使用分と未使用分
	,@flg_zaiko				smallint		-- 検索条件：0…在庫なし含む、0以外…計算在庫/実在庫ありのみ
	,@hasu_floor_decimal	int				-- 実在庫端数(納入単位)：切捨て用小数
	,@hasu_ceil_decimal		int				-- 実在庫端数(納入単位)：切上げ用小数
	,@lang					varchar(2)		-- ブラウザ言語
	,@shiyo_flag			smallint		-- 定数：未使用フラグ：使用
	,@mishiyo_flag			smallint		-- 定数：未使用フラグ：未使用
	,@tani_kg				varchar(2)		-- 定数：納入単位：Kg
	,@tani_L				varchar(2)		-- 定数：納入単位：L
	,@genryo				varchar(2)		-- 定数：品区分：原料
	,@shizai				varchar(2)		-- 定数：品区分：資材
	,@jikagenryo			varchar(2)		-- 定数：品区分：自家原料
	,@kbn_zaiko				smallint		-- 検索条件：在庫区分
	,@cd_soko				varchar(10)		-- 検索条件：倉庫コード
	,@kbn_zaiko_horyu		smallint		-- 在庫区分.保留品

AS
BEGIN

	SET NOCOUNT ON

	-- ==============
	-- データ抽出処理
	-- ==============
		SELECT
		 zaiko.dt_hizuke AS zaiko_hizuke
		,k_zaiko.dt_hizuke AS keisan_hizuke
		,hin.cd_hinmei
		,hin.nm_hinmei_ja
		,hin.nm_hinmei_en
		,hin.nm_hinmei_zh
		,hin.nm_hinmei_vi
		,hin.nm_nisugata_hyoji
		,hin.kbn_hin
		,ma_kbn_hin.nm_kbn_hin AS nm_hinkbn
		,hin.cd_tani_nonyu
		,hin.cd_kura
		,kura.nm_kura
		,hin.cd_bunrui
		,mb.nm_bunrui
		,tani_nonyu.nm_tani AS tani_nonyu
		,tani_shiyo.nm_tani AS tani_shiyo
		,CASE WHEN @kbn_zaiko = @kbn_zaiko_horyu
				THEN
					0
				ELSE
					--COALESCE(CAST(k_zaiko.su_zaiko AS decimal(14,6)), 0)
					COALESCE(ROUND(k_zaiko.su_zaiko, 3, 1), 0.000) 
				END AS su_keisan_zaiko
		
		--,COALESCE(CAST(k_zaiko.su_zaiko AS decimal(14,6)), 0) AS su_keisan_zaiko
		--,COALESCE(CAST(zaiko.su_zaiko AS decimal(14,6)), 0) AS su_zaiko
		,COALESCE(ROUND(zaiko.su_zaiko, 3, 1), 0.000) AS su_zaiko

		-- 実在庫数(納入単位)
		,CASE WHEN hin.wt_ko > 0 AND zaiko.su_zaiko > 0 AND hin.su_iri > 0
		THEN
			ROUND( CAST((zaiko.su_zaiko / (hin.wt_ko * hin.su_iri)) AS DECIMAL(14,6)), 0, 1 )
		--ELSE 0 END
		ELSE 0.0 END
		AS jitsuzaiko_nonyu

		-- 実在庫端数(納入単位)
		,CASE WHEN hin.wt_ko > 0 AND zaiko.su_zaiko > 0 AND hin.su_iri > 0
		THEN
			CASE WHEN hin.cd_tani_nonyu = @tani_kg OR hin.cd_tani_nonyu = @tani_L
			THEN 
				CEILING(
					(ROUND(
						CAST(( (zaiko.su_zaiko % (hin.wt_ko * hin.su_iri)) * 1000 ) AS DECIMAL(14,6))
						* @hasu_floor_decimal, 0, 1) / @hasu_floor_decimal
					) * @hasu_ceil_decimal
				) / @hasu_ceil_decimal
			ELSE
				CEILING(
					(ROUND(
						CAST(( (zaiko.su_zaiko % (hin.wt_ko * hin.su_iri)) / hin.wt_ko ) AS DECIMAL(14,6))
						* @hasu_floor_decimal, 0, 1) / @hasu_floor_decimal
					) * @hasu_ceil_decimal
				) / @hasu_ceil_decimal
			END
		--ELSE 0 END
		ELSE 0.0 END
		AS jitsuzaiko_hasu

		,zaiko.dt_jisseki_zaiko
		,hin.flg_mishiyo
		,COALESCE(zaiko.tan_tana, hin.tan_ko, 0) AS tan_tana
		,COALESCE(hin.su_iri, 0) AS su_iri
		,COALESCE(hin.wt_ko, 0) AS wt_ko
		--,COALESCE(zaiko.cd_soko, @cd_soko) AS cd_soko
		,kbn_soko.cd_soko_kbn AS cd_soko
		--,COALESCE(soko.nm_soko, (select nm_soko from ma_soko where cd_soko = @cd_soko)) AS nm_soko
		,soko.nm_soko AS nm_soko
		-- 金額
		,CASE WHEN hin.wt_ko <> 0 AND zaiko.su_zaiko <> 0
		THEN CAST(floor( (CAST(zaiko.su_zaiko AS decimal) / hin.wt_ko) * COALESCE(zaiko.tan_tana, hin.tan_ko, 0) ) AS decimal)
			ELSE 0 END
		AS kingaku
        ,zaiko.su_zaiko AS jitsu_zaiko_su 
		,zaiko.dt_update
		,COALESCE(zaiko.tan_tana, hin.tan_ko, 0) AS tan_tana_bef
		FROM
			ma_hinmei hin

		LEFT JOIN ma_bunrui mb
		ON hin.cd_bunrui = mb.cd_bunrui
		AND hin.kbn_hin = mb.kbn_hin

		LEFT JOIN ma_tani tani_nonyu
		ON hin.cd_tani_nonyu = tani_nonyu.cd_tani

		LEFT JOIN ma_tani tani_shiyo
		ON hin.cd_tani_shiyo = tani_shiyo.cd_tani

		LEFT JOIN ma_kura kura
		ON hin.cd_kura = kura.cd_kura

		LEFT JOIN ma_kbn_hin
		ON hin.kbn_hin = ma_kbn_hin.kbn_hin

		LEFT JOIN tr_zaiko zaiko
		ON hin.cd_hinmei = zaiko.cd_hinmei
		AND zaiko.dt_hizuke = @con_dt_zaiko
		AND zaiko.kbn_zaiko = @kbn_zaiko
		--AND zaiko.cd_soko = @cd_soko

		LEFT JOIN tr_zaiko_keisan k_zaiko
		ON hin.cd_hinmei = k_zaiko.cd_hinmei
		AND k_zaiko.dt_hizuke = @con_dt_zaiko

		LEFT OUTER JOIN ma_kbn_soko kbn_soko
		ON hin.kbn_hin = kbn_soko.kbn_hin

		LEFT JOIN ma_soko soko
		--ON zaiko.cd_soko = soko.cd_soko
		ON kbn_soko.cd_soko_kbn = soko.cd_soko
		AND soko.flg_mishiyo = @shiyo_flag

		WHERE
		-- 使用分のみにチェックがある場合：使用分フラグが1でも2でもない
		((@flg_shiyobun = 1 OR @flg_shiyobun = 2) OR
			 hin.flg_mishiyo = @shiyo_flag)
		-- 未使用分のみにチェックがある場合：使用分フラグが0でも2でもない
		AND ((@flg_shiyobun = 0 OR @flg_shiyobun = 2) OR
			 hin.flg_mishiyo = @mishiyo_flag)
		-- 使用分と未使用分にチェックがある場合：使用分フラグが0でも1でもない
		AND ((@flg_shiyobun = 0 OR @flg_shiyobun = 1) OR
			 (hin.flg_mishiyo = @shiyo_flag OR hin.flg_mishiyo = @mishiyo_flag))

		-- 倉庫
		--AND (zaiko.cd_soko = @cd_soko or zaiko.cd_soko is null)
		AND kbn_soko.cd_soko_kbn IN (
			CASE WHEN @cd_soko <> '' THEN @cd_soko
			ELSE kbn_soko.cd_soko_kbn
			END
		)

		-- 以下の条件については、指定された場合のみ検索条件に含める
		-- (指定されていない場合は、全件取得される)
		AND (LEN(COALESCE(@con_kbn_hin, '')) = 0 OR hin.kbn_hin = @con_kbn_hin)
		AND (LEN(COALESCE(@con_hin_bunrui, '')) = 0 OR hin.cd_bunrui = @con_hin_bunrui)
		AND (LEN(COALESCE(@con_kurabasho, '')) = 0 OR hin.cd_kura = @con_kurabasho)
		AND (@flg_zaiko = 0 OR
			 (zaiko.su_zaiko > 0 OR k_zaiko.su_zaiko > 0))

		-- 品区分：原料、資材、自家原料のみ取得する
		AND ( hin.kbn_hin = CONVERT(smallint, @genryo)
				OR hin.kbn_hin = CONVERT(smallint, @shizai) OR hin.kbn_hin = CONVERT(smallint, @jikagenryo) )

		-- 多言語対応：言語によって検索対象の品名カラムを変更する
		AND (LEN(COALESCE(@con_hinmei, '')) = 0 OR
				(@lang = 'en' OR @lang = 'zh') OR
					hin.cd_hinmei like '%' + @con_hinmei + '%' OR hin.nm_hinmei_ja like '%' + @con_hinmei + '%'
			)
		AND (LEN(COALESCE(@con_hinmei, '')) = 0 OR
				(@lang = 'ja' OR @lang = 'zh') OR
					hin.cd_hinmei like '%' + @con_hinmei + '%' OR hin.nm_hinmei_en like '%' + @con_hinmei + '%'
			)
		AND (LEN(COALESCE(@con_hinmei, '')) = 0 OR
				(@lang = 'ja' OR @lang = 'en') OR
					hin.cd_hinmei like '%' + @con_hinmei + '%' OR hin.nm_hinmei_zh like '%' + @con_hinmei + '%'
			)
		AND (LEN(COALESCE(@con_hinmei, '')) = 0 OR
				(@lang = 'ja' OR @lang = 'zh') OR
					hin.cd_hinmei like '%' + @con_hinmei + '%' OR hin.nm_hinmei_vi like '%' + @con_hinmei + '%'
			)

		ORDER BY
			hin.cd_hinmei

END
GO