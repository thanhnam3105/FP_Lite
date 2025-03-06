IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_GenshizaiChoseiNyuryoku_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_GenshizaiChoseiNyuryoku_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =================================================================================
-- Author:		<Author,,shibao.s>
-- Create date: <Create Date,,2015.11.27>
-- Description:	<Description,,原資材調整入力> 
-- 仕掛残在庫数チェック:入力した調整数が[使用予\uc1\u23455 ?u192 ?按分トラン]．[仕掛品使用量]
-- を超えていないかチェックするための処理
--
-- =================================================================================
CREATE PROCEDURE [dbo].[usp_GenshizaiChoseiNyuryoku_select]
	@before_su_chosei	DECIMAL(12,6)   -- 明細：変更前調整数
	,@after_su_chosei	DECIMAL(12,6)	-- 明細：変更後調整数
	,@no_lot_seihin		VARCHAR(14)	    -- 明細：製品ロット№
	,@count int output 
AS
BEGIN

CREATE TABLE #tmp_anbun_no_seq
(
	no_seq VARCHAR(14)
)
INSERT INTO #tmp_anbun_no_seq 
exec usp_GenshizaiChoseiNyuryokuAnbunNoSeq_select @no_lot_seihin


SELECT 
	anbun.no_lot_seihin 
FROM tr_sap_shiyo_yojitsu_anbun anbun
LEFT OUTER JOIN tr_shiyo_shikakari_zan shikakari
ON anbun.no_lot_seihin = @no_lot_seihin
AND shikakari.no_seq_shiyo_yojitsu_anbun = anbun.no_seq 
WHERE 
	anbun.no_lot_seihin = @no_lot_seihin 
	AND (
			anbun.su_shiyo_shikakari - (
						SELECT 	
							ISNULL(SUM(su_shiyo),0)   
						FROM 
							tr_shiyo_shikakari_zan 
						WHERE 
							no_seq_shiyo_yojitsu_anbun = (SELECT Distinct no_seq FROM #tmp_anbun_no_seq)
						)
			+ @before_su_chosei - @after_su_chosei
		)
     >= 0
END

SELECT @count = @@ROWCOUNT
GO
