IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_ShiyoYojitsuAnbunTran_delete_02') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_ShiyoYojitsuAnbunTran_delete_02]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =======================================================================
-- Author     :	ADMAX kakuta.y
-- Create date: 2015.08.20
-- Last Update: 
-- Description: 使用予実按分トランの削除処理：製造は削除し、調整は未作成にする
-- =======================================================================
CREATE PROCEDURE [dbo].[usp_ShiyoYojitsuAnbunTran_delete_02]
	@no_lot_seihin			VARCHAR(14)	-- 製品ロット番号
	,@misakuseiDensoKubun	SMALLINT	-- 区分／コード一覧．伝送区分．未作成
	,@seizoAnbunKubun		SMALLINT	-- 区分／コード一覧．使用実績按分区分．製造
	,@choseiAnbunKubun		SMALLINT	-- 区分／コード一覧．使用実績按分区分．調整
AS
BEGIN

	-- 製品が紐付く仕掛品を未作成に更新
	UPDATE tr_sap_shiyo_yojitsu_anbun
	SET kbn_jotai_denso = @misakuseiDensoKubun
	WHERE
		no_lot_shikakari IN (
									SELECT
										con.no_lot_shikakari
									FROM tr_sap_shiyo_yojitsu_anbun con
									WHERE
										con.no_lot_seihin = @no_lot_seihin
									GROUP BY con.no_lot_shikakari
								)
	;

	-- 製品が紐付く仕掛品の製造を削除
	DELETE FROM tr_sap_shiyo_yojitsu_anbun
	WHERE
		kbn_shiyo_jisseki_anbun = @seizoAnbunKubun
		AND no_lot_seihin = @no_lot_seihin
	;

END

GO
