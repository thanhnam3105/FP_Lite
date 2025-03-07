IF OBJECT_ID ('dbo.vw_ma_konyu_01', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_ma_konyu_01]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_ma_konyu_01]
AS
SELECT
	m_ko.su_iri
	,m_ko.cd_hinmei
	,m_ko.flg_mishiyo
FROM dbo.ma_konyu m_ko
INNER JOIN
	(
		SELECT
			cd_torihiki
			,cd_hinmei
			,MAX(dt_update) AS dt_henko
		FROM dbo.ma_konyu
		GROUP BY
			cd_torihiki
			,cd_hinmei
			,dt_update
	) m_ko_new
ON m_ko.dt_update = m_ko_new.dt_henko
AND m_ko.cd_torihiki = m_ko_new.cd_torihiki
AND m_ko.cd_hinmei = m_ko_new.cd_hinmei
GO
