IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_HenpinNyuryoku_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_HenpinNyuryoku_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===============================================
-- Author:		        MJ Ueno.K
-- Create date: 2015.09.14
-- Last Update: 2015.09.14 
-- Description:	返品入力
--    返品入力対象データ抽出処理
-- ===============================================
CREATE PROCEDURE [dbo].[usp_HenpinNyuryoku_select]
	 @con_no_niuke			varchar(14)		-- 検索条件：荷受番号
	,@con_kbn_zaiko			smallint		-- 検索条件：在庫区分
	,@con_no_seq			decimal			-- 検索条件：シーケンスNO.
	,@con_niuke_basho		varchar(10)
	,@lang					varchar(10)		-- 検索条件：表示国フラグ
	,@mishiyoflg            smallint		-- 検索条件：未使用フラグ
	,@henpinflg				smallint		-- 検索条件：返品フラグ
AS
BEGIN

	-- ==============
	-- データ抽出処理
	-- ==============
	SELECT TOP 1 
		niuke.cd_hinmei
		,CASE @lang WHEN 'ja' THEN hinmei.nm_hinmei_ja
					WHEN 'en' THEN hinmei.nm_hinmei_en
					WHEN 'zh' THEN hinmei.nm_hinmei_zh
					WHEN 'vi' THEN hinmei.nm_hinmei_vi
		END AS nm_hinmei
		,niuke.dt_niuke
		,niuke_master.nm_niuke
		,niuke.tm_nonyu_jitsu
		,niuke.nm_hyoji_nisugata
		,niuke.no_lot
		,niuke.kbn_zaiko
		,konyu.su_iri
		,niuke.no_nohinsho
		,niuke.su_zaiko
		,niuke.su_zaiko_hasu
		,hinmei.cd_tani_nonyu
		,hinmei.wt_ko
		,konyu.cd_torihiki
		,niuke.dt_nonyu
		,niuke.cd_niuke_basho
	FROM tr_niuke niuke 

	INNER JOIN ma_konyu konyu 
	ON
		(
			konyu.cd_hinmei = niuke.cd_hinmei 
			AND konyu.cd_torihiki = niuke.cd_torihiki
		)

	INNER JOIN ma_hinmei hinmei 
	ON
		(
			hinmei.cd_hinmei = niuke.cd_hinmei
			AND hinmei.flg_mishiyo = @mishiyoflg 
		)

    INNER JOIN ma_niuke niuke_master 
    ON
		(
			niuke_master.cd_niuke_basho = niuke.cd_niuke_basho 
			AND niuke_master.flg_mishiyo = @mishiyoflg 
		)     
		   
	INNER JOIN ma_kbn_niuke	 kbn_niuke
	ON 
		(	
			niuke_master.kbn_niuke_basho = kbn_niuke.kbn_niuke_basho
			AND kbn_niuke.flg_mishiyo = @mishiyoflg
			AND kbn_niuke.flg_henpin = @henpinflg 
		)

	WHERE
		niuke.no_niuke = @con_no_niuke
		AND niuke.kbn_zaiko = @con_kbn_zaiko
		AND niuke.no_seq = @con_no_seq
		AND niuke.cd_niuke_basho = @con_niuke_basho

	ORDER BY konyu.no_juni_yusen;

END


GO
