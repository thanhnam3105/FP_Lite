IF OBJECT_ID ('dbo.vw_tr_keikaku_seihin_exists', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_tr_keikaku_seihin_exists]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_tr_keikaku_seihin_exists] AS
SELECT
	sei.cd_hinmei
   ,sei.no_lot_seihin	
   ,hin.nm_hinmei_ja
   ,hin.nm_hinmei_en
   ,hin.nm_hinmei_zh
   ,hin.nm_hinmei_vi
   ,hin.flg_mishiyo
FROM  tr_keikaku_seihin sei 
LEFT OUTER JOIN ma_hinmei hin 
ON sei.cd_hinmei = hin.cd_hinmei
GO
