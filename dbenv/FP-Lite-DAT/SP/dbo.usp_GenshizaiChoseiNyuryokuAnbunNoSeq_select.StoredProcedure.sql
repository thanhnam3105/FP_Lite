IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_GenshizaiChoseiNyuryokuAnbunNoSeq_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_GenshizaiChoseiNyuryokuAnbunNoSeq_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能        ：原資材調整入力　新規行における使用予実按分シーケンスの取得方法
ファイル名  ：usp_GenshizaiChoseiNyuryokuAnbunNoSeq_select
作成日      ：2015.11.30 shibao.s
更新日      ：
*****************************************************/
CREATE PROCEDURE [dbo].[usp_GenshizaiChoseiNyuryokuAnbunNoSeq_select]
	@no_lot_seihin	VARCHAR(14)		-- 製品ロット№
AS
BEGIN
	SELECT 
		anbun.no_seq 
	FROM tr_keikaku_seihin keikaku
	LEFT OUTER JOIN tr_sap_shiyo_yojitsu_anbun anbun
	ON keikaku.no_lot_seihin = anbun.no_lot_seihin
	WHERE
		keikaku.no_lot_seihin = @no_lot_seihin
END
GO
