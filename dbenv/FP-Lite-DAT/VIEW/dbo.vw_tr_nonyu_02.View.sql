IF OBJECT_ID ('dbo.vw_tr_nonyu_02', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_tr_nonyu_02]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_tr_nonyu_02] as

SELECT
 tr.cd_torihiki AS cd_torihiki
 ,ma.nm_torihiki AS nm_torihiki
 ,ma.nm_torihiki_ryaku AS nm_torihiki_ryaku
 ,ma.kbn_torihiki AS kbn_torihiki
 ,tr.flg_yojitsu AS flg_yojitsu
 ,tr.dt_nonyu AS dt_nonyu
 ,tr.cd_hinmei AS cd_hinmei
FROM tr_nonyu tr
LEFT JOIN ma_torihiki ma
ON ma.cd_torihiki = tr.cd_torihiki
GO
