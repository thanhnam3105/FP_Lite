IF OBJECT_ID ('dbo.vw_tr_niuke_lot_sentaku', 'V') IS NOT NULL
DROP VIEW [dbo].vw_tr_niuke_lot_sentaku
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_tr_niuke_lot_sentaku]
AS

SELECT DISTINCT
	niuke.no_niuke
	,niuke.cd_niuke_basho
	,niuke.kbn_zaiko                  
	,niuke.no_seq
	,niuke.cd_hinmei
	,niuke.dt_niuke
	,niuke.dt_nonyu
	,niuke.no_lot
	,niuke.dt_kigen
FROM
(
	SELECT
		t_niu.no_niuke
		,t_niu.cd_niuke_basho
		,t_niu.kbn_zaiko                  
		,t_niu.no_seq
		,t_niu.cd_hinmei
		,ISNULL(t_nyu_yotei.dt_nonyu,t_niu.tm_nonyu_yotei) AS dt_niuke
		,t_niu.dt_nonyu
		,t_niu.no_lot
		,t_niu.dt_kigen
	FROM
		tr_niuke t_niu
	LEFT OUTER JOIN
		tr_nonyu t_nyu_jitsu
	ON
		t_niu.no_nonyu = t_nyu_jitsu.no_nonyu
		AND t_nyu_jitsu.flg_yojitsu = 1
	LEFT OUTER JOIN
		tr_nonyu t_nyu_yotei
	ON
		t_nyu_jitsu.no_nonyu = t_nyu_yotei.no_nonyu
		AND t_nyu_yotei.flg_yojitsu = 0
	
	UNION
	
	SELECT
		t_niu.no_niuke
		,t_niu.cd_niuke_basho
		,t_niu.kbn_zaiko                  
		,t_niu.no_seq
		,t_niu.cd_hinmei
		,ISNULL(t_nyu_yotei.dt_nonyu,t_niu.tm_nonyu_yotei) AS dt_niuke
		,t_niu.dt_nonyu
		,t_niu.no_lot
		,t_niu.dt_kigen
	FROM
		tr_niuke t_niu
	LEFT OUTER JOIN
		tr_nonyu t_nyu_jitsu
	ON
		t_niu.no_nonyu = t_nyu_jitsu.no_nonyu
		AND t_nyu_jitsu.flg_yojitsu = 1
	LEFT OUTER JOIN
		tr_nonyu t_nyu_yotei
	ON
		t_nyu_jitsu.no_nonyu_yotei = t_nyu_yotei.no_nonyu
		AND t_nyu_yotei.flg_yojitsu = 0
) niuke

/*
SELECT
	t_niu.no_niuke
	,t_niu.cd_niuke_basho
	,t_niu.kbn_zaiko                  
	,t_niu.no_seq
	,t_niu.cd_hinmei
	--,ISNULL(t_nyu.dt_nonyu,t_niu.dt_niuke) AS dt_niuke
	,t_niu.dt_nonyu
	,t_niu.no_lot
	,t_niu.dt_kigen
FROM tr_niuke t_niu
LEFT OUTER JOIN tr_nonyu t_nyu
ON t_niu.no_nonyu = t_nyu.no_nonyu
AND t_nyu.flg_yojitsu = 0
*/

GO
