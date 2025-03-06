IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_ShikakariZanIchiranDialog_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_ShikakariZanIchiranDialog_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,shibao.s>
-- Create date: <Create Date,,2015.12.08>
-- Description:	仕掛残選択セレクタの検索処理
-- =============================================
CREATE PROCEDURE [dbo].[usp_ShikakariZanIchiranDialog_select]
	@cd_hinmei	   varchar(14)	-- ダイアログ呼び出し元の選択値
	,@start_date   datetime	-- ダイアログ入力値
	,@end_date	   datetime	-- ダイアログ入力値
	,@lang         varchar(10) --言語 
AS
BEGIN

SELECT 
	 seihin.dt_seizo
	 ,ISNULL(seihin.su_seizo_jisseki,0) as su_seizo_jisseki
	 ,seihin.no_lot_seihin
	 ,hinmei.cd_hinmei
	 ,CASE @lang WHEN 'ja' THEN hinmei.nm_hinmei_ja 
				 WHEN 'en' THEN hinmei.nm_hinmei_en
				 WHEN 'zh' THEN hinmei.nm_hinmei_zh
				 WHEN 'vi' THEN hinmei.nm_hinmei_vi
	 END AS nm_hinmei

FROM tr_keikaku_seihin seihin
LEFT OUTER JOIN ma_hinmei hinmei
ON seihin.cd_hinmei = hinmei.cd_hinmei

LEFT OUTER JOIN tr_sap_shiyo_yojitsu_anbun anbun
ON seihin.no_lot_seihin = anbun.no_lot_seihin

LEFT OUTER JOIN(
		SELECT 
			no_seq_shiyo_yojitsu_anbun
			,SUM(su_shiyo) as sum_shiyo
		FROM tr_shiyo_shikakari_zan
		GROUP BY no_seq_shiyo_yojitsu_anbun
		HAVING    
			SUM(su_shiyo)> 0
	)sum_shikakari
ON anbun.no_seq = sum_shikakari.no_seq_shiyo_yojitsu_anbun
AND anbun.kbn_shiyo_jisseki_anbun = 3

WHERE
	seihin.cd_hinmei = @cd_hinmei
	AND seihin.dt_seizo BETWEEN @start_date AND @end_date
	AND (seihin.su_seizo_jisseki * hinmei.su_iri * hinmei.wt_ko) > ISNULL(sum_shikakari.sum_shiyo,0)
ORDER BY seihin.dt_seizo

END
GO
