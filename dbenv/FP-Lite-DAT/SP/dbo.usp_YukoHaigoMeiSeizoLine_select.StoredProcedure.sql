IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_YukoHaigoMeiSeizoLine_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_YukoHaigoMeiSeizoLine_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,kobayashi.y>
-- Create date: <Create Date,,2013.12.16>
-- Last Update: <2014.09.30,tsujita.s>
-- Last Update: <2018.03.13,kanehira.d>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_YukoHaigoMeiSeizoLine_select]
    @hinCode		VARCHAR(14)  -- 製品コード
    ,@seizoDate		DATETIME    -- 製造日（有効版取得のため）
    ,@falseFlag		SMALLINT
    ,@masterKbn		SMALLINT
    ,@lineCode		VARCHAR(10)
    ,@hinKbnSeihin	SMALLINT	-- 定数：品区分：製品
    ,@hinKbnJikagen	SMALLINT	-- 定数：品区分：自家原料
AS

	SELECT
		hin.cd_hinmei AS seihinCode
		,hin.nm_hinmei_en
		,hin.nm_hinmei_ja
		,hin.nm_hinmei_zh
		,hin.nm_hinmei_vi
		,hin.nm_nisugata_hyoji
		,hin.wt_ko
		,hin.su_iri
		,seizo_line.cd_line
		,yukoHaigo.cd_haigo
		,yukoHaigo.ritsu_kihon
		,yukoHaigo.wt_haigo_gokei
		,yukoHaigo.ritsu_budomari_mei AS haigo_budomari
	FROM (
		SELECT cd_hinmei
			,nm_hinmei_en
			,nm_hinmei_ja
			,nm_hinmei_zh
			,nm_hinmei_vi
			,nm_nisugata_hyoji
			,cd_haigo
			,wt_ko
			,su_iri
		FROM ma_hinmei
		--WHERE cd_hinmei = @hinCode
		WHERE CONVERT(BINARY,cd_hinmei) = CONVERT(BINARY,@hinCode)
		AND (kbn_hin = @hinKbnSeihin OR kbn_hin = @hinKbnJikagen)
	) AS hin

	INNER JOIN ma_seizo_line seizo_line
	ON hin.cd_hinmei = seizo_line.cd_haigo
	AND seizo_line.flg_mishiyo = @falseFlag
	AND seizo_line.kbn_master = @masterKbn
	AND seizo_line.cd_line = @lineCode

	INNER JOIN (
		SELECT TOP 1
			udf.cd_haigo
			,udf.ritsu_kihon
			,udf.wt_haigo_gokei
			,udf.ritsu_budomari_mei
		FROM udf_HaigoRecipeYukoHan
		(
			(
				-- 製品コードをもとに、配合コードを取得
				SELECT
					hin.cd_haigo
				FROM (
					SELECT cd_haigo
					FROM ma_hinmei
					--WHERE cd_hinmei = @hinCode
					WHERE CONVERT(BINARY,cd_hinmei) = CONVERT(BINARY,@hinCode)
					AND (kbn_hin = @hinKbnSeihin OR kbn_hin = @hinKbnJikagen)
					AND flg_mishiyo = @falseFlag
				) hin
			)
			, @falseFlag, @seizoDate
		) udf
		WHERE
			udf.cd_hinmei IS NOT NULL
	) yukoHaigo
	ON hin.cd_haigo = yukoHaigo.cd_haigo

	ORDER BY
		seizo_line.no_juni_yusen DESC
GO
