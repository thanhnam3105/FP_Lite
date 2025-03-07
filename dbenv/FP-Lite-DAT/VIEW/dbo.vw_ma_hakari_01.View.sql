IF OBJECT_ID ('dbo.vw_ma_hakari_01', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_ma_hakari_01]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_ma_hakari_01]
AS
SELECT 
	 mh.cd_hakari AS cd_hakari
	,mh.nm_hakari AS nm_hakari
	,mh.cd_tani AS cd_tani
	,mt.nm_tani AS nm_tani
	,(mh.kbn_baurate + ',' + mh.kbn_parity + ',' + mh.kbn_databit + ',' + mh.kbn_stopbit) AS joken_tushin
	,mh.kbn_baurate AS kbn_baurate
	,mk_bau.nm_kbn_baurate AS nm_kbn_baurate
	,mh.kbn_parity AS kbn_parity
	,mk_par.nm_kbn_parity AS nm_kbn_parity
	,mh.kbn_databit AS kbn_databit
	,mk_dat.nm_kbn_databit AS nm_kbn_databit
	,mh.kbn_stopbit AS kbn_stopbit
	,mk_st.nm_kbn_stopbit AS nm_kbn_stopbit
	,mh.kbn_handshake AS kbn_handshake
	,mk_hand.nm_kbn_handshake AS nm_kbn_handshake
	,mh.nm_antei AS nm_antei
	,mh.nm_fuantei AS nm_fuantei
	,mh.su_keta AS su_keta
	,mh.su_ichi_dot AS su_ichi_dot
	,mh.su_ichi_fugo AS su_ichi_fugo
	,mh.cd_fundo AS cd_fundo
	,mf.wt_fundo AS wt_fundo
	,mf.cd_tani AS cd_tani_fundo
	,mt2.nm_tani AS nm_tani_fundo
	,mh.flg_fugo AS flg_fugo
	,mh.no_ichi_juryo AS no_ichi_juryo
	,mh.dt_create AS dt_create
	,mh.cd_create AS cd_create
	,mh.dt_update AS dt_update
	,mh.cd_update AS cd_update
	,mh.flg_mishiyo AS flg_mishiyo
	,mh.no_com AS no_com
	,mh.ts AS ts
	,mt.flg_mishiyo AS mt_flg_mishiyo
	,mf.flg_mishiyo AS mf_flg_mishiyo
	,mh.flg_hakari_check AS flg_hakari_check
	,mh.tm_interval
FROM
	ma_hakari mh

LEFT JOIN ma_tani mt
ON mh.cd_tani = mt.cd_tani

LEFT JOIN ma_fundo mf
ON mh.cd_fundo = mf.cd_fundo

LEFT JOIN ma_kbn_baurate mk_bau
ON mk_bau.kbn_baurate = mh.kbn_baurate

LEFT JOIN ma_kbn_parity mk_par
ON mk_par.kbn_parity = mh.kbn_parity

LEFT JOIN ma_kbn_databit mk_dat
ON mk_dat.kbn_databit = mh.kbn_databit

LEFT JOIN ma_kbn_stopbit mk_st
ON mk_st.kbn_stopbit = mh.kbn_stopbit

LEFT JOIN ma_kbn_handshake mk_hand
ON mk_hand.kbn_handshake = mh.kbn_handshake

LEFT JOIN ma_tani mt2
ON mf.cd_tani = mt2.cd_tani
GO
