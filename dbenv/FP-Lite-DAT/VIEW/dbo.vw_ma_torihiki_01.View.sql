IF OBJECT_ID ('dbo.vw_ma_torihiki_01', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_ma_torihiki_01]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_ma_torihiki_01]
AS
SELECT
	torihiki.cd_torihiki
	,torihiki.nm_torihiki
	,torihiki.nm_torihiki_ryaku
	,torihiki.nm_busho
	,torihiki.kbn_torihiki
	,kbn_torihiki.nm_kbn_torihiki
	,torihiki.no_yubin
	,torihiki.nm_jusho
	,torihiki.no_tel
	,torihiki.no_fax
	,torihiki.e_mail
	,torihiki.nm_tanto_1
	,torihiki.nm_tanto_2
	,torihiki.nm_tanto_3
	,torihiki.kbn_keishiki_nonyusho
	,torihiki.kbn_keisho_nonyusho
	,torihiki.kbn_hin
	,torihiki.biko
	,torihiki.cd_maker
	,torihiki.flg_pikking
	,torihiki.flg_mishiyo
	,torihiki.dt_create
	,torihiki.cd_create
	,torihiki.dt_update
	,torihiki.cd_update
	,torihiki.ts
FROM ma_torihiki torihiki
INNER JOIN ma_kbn_torihiki kbn_torihiki
ON torihiki.kbn_torihiki = kbn_torihiki.kbn_torihiki
GO
