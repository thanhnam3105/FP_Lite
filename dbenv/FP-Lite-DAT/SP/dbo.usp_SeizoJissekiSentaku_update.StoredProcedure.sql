IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_SeizoJissekiSentaku_update') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_SeizoJissekiSentaku_update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,tsujita.s>
-- Create date: <Create Date,,2015.06.29>
-- Last Update: 2015.07.13 tsujita.s
-- Description:	製造実績選択の一括更新処理
-- =============================================
CREATE PROCEDURE [dbo].[usp_SeizoJissekiSentaku_update]
	@no_lot_shikakari		AS VARCHAR(14)	-- 仕掛品ロット番号
	,@kbn_jotai_denso		AS SMALLINT		-- 固定値：伝送状態区分：未伝送
	,@misakuseiDensoKubun	AS SMALLINT		-- 固定値：伝送状態区分：未作成
AS
BEGIN

	-- 関連データの伝送状態区分を未伝送に一括更新
	UPDATE tr_sap_shiyo_yojitsu_anbun
	SET kbn_jotai_denso = @kbn_jotai_denso
	WHERE
		no_lot_shikakari = @no_lot_shikakari
		AND kbn_jotai_denso = @misakuseiDensoKubun
END
GO
