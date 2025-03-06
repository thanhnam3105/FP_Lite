IF OBJECT_ID ('dbo.vw_tr_kuradashi_01', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_tr_kuradashi_01]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_tr_kuradashi_01]
AS
	SELECT 
		tk.cd_hinmei
		,tk.dt_shukko
		,tk.flg_kakutei
		,tk.kbn_status
		,mh.kbn_hin
		,mh.flg_mishiyo
		,mh.cd_niuke_basho
		,mh.cd_bunrui
	FROM tr_kuradashi tk
	INNER JOIN ma_hinmei mh
		ON tk.cd_hinmei = mh.cd_hinmei
GO
