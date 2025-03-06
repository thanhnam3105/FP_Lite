IF OBJECT_ID ('dbo.vw_tr_tonyu_keikaku_01', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_tr_tonyu_keikaku_01]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[vw_tr_tonyu_keikaku_01]
AS
SELECT
	ISNULL(ttk.dt_seizo, '') AS dt_seizo
	,ISNULL(ttk.mark, '') AS mark
	,ISNULL(ttk.cd_hinmei, '') AS cd_hinmei
	,ISNULL(ttk.nm_hinmei, '') AS nm_hinmei
	,ISNULL(ttk.wt_haigo, '') AS wt_haigo
	,ISNULL(ttk.nm_tani, '') AS nm_tani
	,ISNULL(ttk.wt_nisugata, 0) AS wt_nisugata
	,ISNULL(ttk.su_nisugata, 0) AS su_nisugata
	,ISNULL(ttk.wt_kowake, 0) AS wt_kowake
	,ISNULL(ttk.su_kowake, 0) AS su_kowake
	,ISNULL(ttk.wt_kowake_hasu, 0) AS wt_kowake_hasu
	,ISNULL(ttk.su_kowake_hasu, 0) AS su_kowake_hasu
	,ISNULL(ttk.hijyu, 0) AS hijyu
	,ISNULL(ttk.su_settei, 0) AS su_settei
	,ISNULL(ttk.su_settei_max, 0) AS su_settei_max
	,ISNULL(ttk.su_settei_min, 0) AS su_settei_min
	,ISNULL(ttk.cd_shokuba, '') AS cd_shokuba
	,ISNULL(ttk.cd_panel, '') AS cd_panel
	,ISNULL(ttk.cd_line, '') AS cd_line
	,ISNULL(ttk.kbn_seikihasu, 0) AS kbn_seikihasu
	,ISNULL(ttk.no_kotei, 0) AS no_kotei
	,ISNULL(ttk.no_tonyu, '') AS no_tonyu
	,ISNULL(ttk.flg_kowake_systemgai, 0) AS flg_kowake_systemgai
FROM dbo.tr_tonyu_keikaku ttk
LEFT OUTER JOIN dbo.ma_hinmei mh
ON ttk.cd_hinmei = mh.cd_hinmei



GO
