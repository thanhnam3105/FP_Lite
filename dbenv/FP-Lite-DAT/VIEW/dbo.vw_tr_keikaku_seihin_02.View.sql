IF OBJECT_ID ('dbo.vw_tr_keikaku_seihin_02', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_tr_keikaku_seihin_02]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_tr_keikaku_seihin_02] AS
SELECT
	dt_seizo
   ,cd_hinmei
   ,SUM(COALESCE(su_seizo_yotei, 0)) AS sum_su_seizo_yotei
FROM
	tr_keikaku_seihin
GROUP BY
	dt_seizo
   ,cd_hinmei
GO
