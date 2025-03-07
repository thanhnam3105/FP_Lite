IF OBJECT_ID ('dbo.vw_tr_niuke_02', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_tr_niuke_02]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/************************************************************
機能		：在庫一覧画面・検索用ビュー
ビュー名	：vw_tr_niuke_02
入力引数	：
備考		：
作成日		：2013.07.17 admax
更新日		：
************************************************************/
CREATE VIEW [dbo].[vw_tr_niuke_02]
AS

SELECT 
	t_niu_first.dt_niuke								AS dt_niuke
	,t_niu_first.tm_nonyu_jitsu							AS tm_nonyu_jitsu
	,Convert(varchar,(Convert(bigint,t_niu.no_niuke)))	AS no_niuke
	,ISNull(t_niu.no_lot, '') 							AS no_lot
	,ISNull(t_niu.dt_seizo, '') 						AS dt_seizo
	,ISNull(t_niu.dt_kigen, '') 						AS dt_kigen
	,ISNull(m_zaiko.nm_kbn_zaiko, '')					AS nm_kbn_zaiko
	,ISNull(t_niu.su_zaiko, 0) 							AS su_zaiko
	,ISNull(t_niu.su_zaiko_hasu, 0)						AS su_zaiko_hasu
	,t_niu.cd_hinmei									AS cd_hinmei
	,Convert(varchar,t_niu.kbn_zaiko)					AS cd_kbn_zaiko
	,IsNull(m_hin.nm_hinmei_ja, '') 					AS nm_hinmei_ja
	,ISNULL(m_hin.nm_hinmei_en, '')						AS nm_hinmei_en
	,ISNULL(m_hin.nm_hinmei_zh, '')						AS nm_hinmei_zh
	,ISNULL(m_hin.nm_hinmei_vi, '')						AS nm_hinmei_vi
,case 
when t_niu.dt_kigen IS NULL or t_niu.dt_seizo IS NULL then '0'
when t_niu.dt_kigen - GetDate() < 0 then '1'
when convert(int,(t_niu.dt_kigen - t_niu.dt_seizo))/3 > (t_niu.dt_kigen - GetDate()) then '1'
else '0'
end as flg_kakutei



FROM tr_niuke t_niu

JOIN
	(
		SELECT 
			MAX(no_seq) no_seq
			,no_niuke no_niuke
			,kbn_zaiko kbn_zaiko
		FROM tr_niuke
		GROUP BY no_niuke,kbn_zaiko
	)  t_niu_new
ON t_niu.no_niuke = t_niu_new.no_niuke
AND t_niu.no_seq = t_niu_new.no_seq
AND t_niu.kbn_zaiko = t_niu_new.kbn_zaiko		
JOIN
	(
		SELECT 
			dt_niuke dt_niuke
			,tm_nonyu_jitsu tm_nonyu_jitsu
			,no_niuke no_niuke
			,kbn_zaiko kbn_zaiko
		FROM	tr_niuke
		WHERE	no_seq = (select MIN(no_seq) from tr_niuke)
	) t_niu_first
ON t_niu.no_niuke = t_niu_first.no_niuke
LEFT JOIN ma_kbn_zaiko m_zaiko
ON t_niu.kbn_zaiko = m_zaiko.kbn_zaiko
LEFT JOIN ma_hinmei m_hin
ON t_niu.cd_hinmei = m_hin.cd_hinmei
AND m_hin.flg_mishiyo = 0		
LEFT JOIN ma_kbn_hokan m_hokan
ON  m_hin.kbn_hokan = m_hokan.cd_hokan_kbn
AND m_hokan.flg_mishiyo = 0
GO
