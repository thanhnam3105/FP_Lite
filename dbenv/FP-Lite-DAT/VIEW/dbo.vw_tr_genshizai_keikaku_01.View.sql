IF OBJECT_ID ('dbo.vw_tr_genshizai_keikaku_01', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_tr_genshizai_keikaku_01]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_tr_genshizai_keikaku_01] as

SELECT TOP 1
	tr.cd_hinmei AS cd_hinmei
	,tr.dt_keikaku_nonyu AS dt_keikaku_nonyu
FROM
	tr_genshizai_keikaku tr

INNER JOIN (
	SELECT MIN(dt_keikaku_nonyu) AS dt_keikaku_nonyu
	FROM tr_genshizai_keikaku
) MIN_DATE
ON MIN_DATE.dt_keikaku_nonyu = tr.dt_keikaku_nonyu
GO
