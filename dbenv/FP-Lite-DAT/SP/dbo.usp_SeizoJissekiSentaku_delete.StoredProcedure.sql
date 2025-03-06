IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_SeizoJissekiSentaku_delete') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_SeizoJissekiSentaku_delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,inamori.h>
-- Create date: <Create Date,,2015.12.24>
-- Description:	<Description,,製品ロット番号で製品計画トランと仕掛残使用予実トラン、シーケンス番号で調整トラン、使用予実按分シーケンスで仕掛残使用量トランを削除>
-- =============================================
CREATE PROCEDURE [dbo].[usp_SeizoJissekiSentaku_delete]
	@lotNo VARCHAR(14)
	,@seqNo VARCHAR(14)
AS

-- 製品計画トランの削除
DELETE FROM tr_keikaku_seihin
WHERE 
    no_lot_seihin = @lotNo
    
--調整トランの削除
DELETE FROM tr_chosei
WHERE
	no_lot_seihin = @lotNo

--仕掛残使用予実トランの削除
DELETE tr_shiyo_yojitsu
WHERE
	no_seq IN 
	(SELECT
		no_seq_shiyo_yojitsu
	FROM tr_shiyo_shikakari_zan
	WHERE 
		no_seq_shiyo_yojitsu_anbun = @seqNo
	)


--仕掛残使用量トランの削除
DELETE tr_shiyo_shikakari_zan
WHERE
	no_seq_shiyo_yojitsu_anbun = @seqNo



--
GO
