IF OBJECT_ID ('dbo.vw_ma_hinmei_08', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_ma_hinmei_08]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_ma_hinmei_08]
AS
SELECT
	ISNULL(m_niu.nm_niuke, '') AS nm_niuke
	,ISNULL(m_hin.nm_nisugata_hyoji, '') AS nisugata_hyoji
	,ISNULL(m_ko_join.su_iri, 1) AS su_iri
	,ISNULL(m_hin.cd_hinmei, '') AS cd_hinmei
	,ISNULL(m_hin.flg_mishiyo, 0) AS flg_mishiyo
FROM dbo.ma_hinmei m_hin
LEFT OUTER JOIN dbo.ma_niuke m_niu
ON m_hin.cd_niuke_basho = m_niu.cd_niuke_basho
AND m_niu.flg_mishiyo = 0
LEFT OUTER JOIN
	(
		SELECT
			m_ko.cd_hinmei
			,m_ko.su_iri
		FROM dbo.ma_konyu m_ko
		INNER JOIN
			(
				SELECT
					cd_hinmei
					,MIN(no_juni_yusen) AS no_yusen
				FROM dbo.ma_konyu
				WHERE
					flg_mishiyo = 0
				GROUP BY
					cd_hinmei
			) m_ko_hinmei
		ON m_ko.cd_hinmei = m_ko_hinmei.cd_hinmei
		AND m_ko.no_juni_yusen = m_ko_hinmei.no_yusen
		AND m_ko.flg_mishiyo = 0
	) m_ko_join
ON m_hin.cd_hinmei = m_ko_join.cd_hinmei
GO
