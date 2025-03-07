IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_HinmeiDialogShikakari_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_HinmeiDialogShikakari_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,tsujita.s>
-- Create date: <Create Date,,2014.04.22>
-- Last Update: <2016.12.13 motojima.m>
-- Description:	品名セレクタ「区分：仕掛品」のときの検索処理
-- =============================================
CREATE PROCEDURE [dbo].[usp_HinmeiDialogShikakari_select]
	@flg_shiyo			smallint		-- 定数：未使用フラグ：使用
	,@kbn_hin			smallint		-- 定数：品区分：仕掛品
	--,@shikakarihin	varchar(50)		-- 文言：仕掛品
	,@shikakarihin		nvarchar(50)	-- 文言：仕掛品
	,@con_flg			smallint		-- 検索条件：未使用含かどうか
	--,@con_name		varchar(50)		-- 検索条件：品名
	,@con_name			nvarchar(50)	-- 検索条件：品名
	,@con_bunrui		varchar(10)		-- 検索条件：分類
AS
BEGIN

	IF @con_flg = 1
	BEGIN
		-- ///////////////////////////////////
		--  未使用を含む場合
		-- ///////////////////////////////////
		SELECT
			ma.no_han AS no_han
			,ma.cd_haigo AS cd_hinmei
			,ma.nm_haigo_ja AS nm_hinmei_ja
			,ma.nm_haigo_en AS nm_hinmei_en
			,ma.nm_haigo_zh AS nm_hinmei_zh
			,ma.nm_haigo_vi AS nm_hinmei_vi
			,@shikakarihin AS nm_kbn_hin
			,@kbn_hin AS kbn_hin
			,ma.wt_kihon AS nm_naiyo
		FROM
			ma_haigo_mei ma
		INNER JOIN (
			SELECT MAX(no_han) AS no_han
				,cd_haigo
			FROM ma_haigo_mei
			WHERE (LEN(@con_bunrui) = 0 OR cd_bunrui = @con_bunrui)
			AND (LEN(@con_name) = 0
				OR nm_haigo_ja LIKE '%' + @con_name + '%'
				OR nm_haigo_en LIKE '%' + @con_name + '%'
				OR nm_haigo_zh LIKE '%' + @con_name + '%'
				OR nm_haigo_vi LIKE '%' + @con_name + '%'
				OR cd_haigo LIKE '%' + @con_name + '%')
			GROUP BY cd_haigo
		) maxHan
		ON ma.cd_haigo = maxHan.cd_haigo
		AND ma.no_han = maxHan.no_han
		
		ORDER BY ma.cd_haigo
	END
	ELSE BEGIN
		-- ///////////////////////////////////
		--  未使用を含まない場合
		-- ///////////////////////////////////
		SELECT
			ma.no_han AS no_han
			,ma.cd_haigo AS cd_hinmei
			,ma.nm_haigo_ja AS nm_hinmei_ja
			,ma.nm_haigo_en AS nm_hinmei_en
			,ma.nm_haigo_zh AS nm_hinmei_zh
			,ma.nm_haigo_vi AS nm_hinmei_vi
			,@shikakarihin AS nm_kbn_hin
			,@kbn_hin AS kbn_hin
			,ma.wt_kihon AS nm_naiyo
		FROM
			ma_haigo_mei ma
		INNER JOIN (
			SELECT MAX(no_han) AS no_han
				,cd_haigo
			FROM ma_haigo_mei
			WHERE flg_mishiyo = @flg_shiyo
			AND (LEN(@con_bunrui) = 0 OR cd_bunrui = @con_bunrui)
			AND (LEN(@con_name) = 0
				OR nm_haigo_ja LIKE '%' + @con_name + '%'
				OR nm_haigo_en LIKE '%' + @con_name + '%'
				OR nm_haigo_zh LIKE '%' + @con_name + '%'
				OR nm_haigo_vi LIKE '%' + @con_name + '%'
				OR cd_haigo LIKE '%' + @con_name + '%')
			GROUP BY cd_haigo
		) maxHan
		ON ma.cd_haigo = maxHan.cd_haigo
		AND ma.no_han = maxHan.no_han
		
		ORDER BY ma.cd_haigo
	END

END
GO
