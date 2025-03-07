IF OBJECT_ID ('dbo.vw_ma_shiyo_01', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_ma_shiyo_01]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_ma_shiyo_01]
AS
select
    h.cd_hinmei
    ,h.no_han
    ,h.dt_from
    ,b.cd_shizai
    ,hin.nm_hinmei_ja
    ,hin.nm_hinmei_en
    ,hin.nm_hinmei_zh
	,hin.nm_hinmei_vi
    ,hin.nm_nisugata_hyoji
    ,hin.cd_tani_shiyo
    ,t.nm_tani
    ,b.su_shiyo
    ,hin.kbn_hin
    ,h.flg_mishiyo
    ,hin.flg_mishiyo as hinmei_flg_mishiyo
    ,t.flg_mishiyo as tani_flg_mishiyo
    ,h.ts AS header_ts
    ,b.ts AS body_ts
from ma_shiyo_h h
left outer join ma_shiyo_b b
on h.cd_hinmei = b.cd_hinmei
and h.no_han = b.no_han
left outer join ma_hinmei hin
on b.cd_shizai = hin.cd_hinmei
left outer join ma_tani t
on hin.cd_tani_shiyo = t.cd_tani
GO
