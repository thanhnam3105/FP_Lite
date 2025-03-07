IF OBJECT_ID ('dbo.vw_ma_hinmei_13', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_ma_hinmei_13]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_ma_hinmei_13]
AS
SELECT cd_hinmei
	, nm_hinmei_ja
	, nm_hinmei_en
	, nm_hinmei_zh
	, nm_hinmei_vi
	, flg_mishiyo
	, kbn_hin
FROM
	(
		-- 原料、自家原料の場合
		SELECT
			hin.cd_hinmei
			, hin.nm_hinmei_ja
			, hin.nm_hinmei_en
			, hin.nm_hinmei_zh
			, hin.nm_hinmei_vi
			, flg_mishiyo
			, kbn_hin
		FROM 
			ma_hinmei hin 
		WHERE hin.kbn_hin IN (2,7)

		UNION

		-- 仕掛品の場合
		SELECT
			hin2.cd_hinmei
			, hin2.nm_hinmei_ja
			, hin2.nm_hinmei_en
			, hin2.nm_hinmei_zh
			, hin2.nm_hinmei_vi
			, hin2.flg_mishiyo
			, CONVERT(Smallint, '5')  kbn_hin
		FROM 
			(SELECT
				ma.no_han AS no_han
				,ma.cd_haigo AS cd_hinmei
				,ma.nm_haigo_ja AS nm_hinmei_ja
				,ma.nm_haigo_en AS nm_hinmei_en
				,ma.nm_haigo_zh AS nm_hinmei_zh
				,ma.nm_haigo_vi AS nm_hinmei_vi
				,ma.flg_mishiyo
			FROM
				ma_haigo_mei ma
			INNER JOIN (
				SELECT MAX(no_han) AS no_han, cd_haigo
				FROM ma_haigo_mei
				WHERE flg_mishiyo = 0
				GROUP BY cd_haigo) maxHan
			ON ma.cd_haigo = maxHan.cd_haigo
			AND ma.no_han = maxHan.no_han
			)  hin2
	) temp

GO
