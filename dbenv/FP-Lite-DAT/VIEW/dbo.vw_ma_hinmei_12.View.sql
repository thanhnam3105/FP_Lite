IF OBJECT_ID ('dbo.vw_ma_hinmei_12', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_ma_hinmei_12]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_ma_hinmei_12]
AS
SELECT
	Hin.cd_hinmei
	, Hin.nm_hinmei_en
	, Hin.nm_hinmei_ja
	, Hin.nm_hinmei_zh
	, Hin.nm_hinmei_vi
	, Hin.nm_hinmei_ryaku
	, Hin.nm_nisugata_hyoji
	, Hin.kbn_hin
	, Hin.flg_trace_taishogai
	, Hin.cd_tani_shiyo
	, Tani.nm_tani AS nm_tani_shiyo
FROM ma_hinmei Hin

LEFT JOIN ma_tani Tani
ON Hin.cd_tani_shiyo = Tani.cd_tani
GO
