IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_HaigoCheck_update') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_HaigoCheck_update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：小分実績トラン 更新
ファイル名	：usp_Kakozan_update
入力引数	：@cd_seihin,@cd_hinmei,@no_lot_seihin
			  ,@su_kai,@su_ko,@wt_haigo
出力引数	：
戻り値		：
作成日		：2013.10.21  ADMAX endo.y
更新日		：2015.08.10  ADMAX kakuta.y WHERE句に品区分を追加
*****************************************************/
CREATE PROCEDURE [dbo].[usp_HaigoCheck_update] 
	@cd_seihin				VARCHAR(14)		-- 配合コード
	,@cd_hinmei				VARCHAR(14)		-- 原料コード
	,@no_lot_seihin			VARCHAR(14)		-- 製品ロット番号
	,@su_kai				DECIMAL(4,0)	-- 回数
	,@su_ko					DECIMAL(4,0)	-- 個数
	,@wt_haigo				DECIMAL(12,6)	-- 配合重量
	,@dt_shori				DATETIME		-- 投入日時
	,@flg_kanryo_tonyu		SMALLINT		-- 投入完了フラグ
	,@kbn_seikihasu			SMALLINT		-- 正規、端数区分
	,@kbn_kowakehasu		SMALLINT		-- 小分正規、端数区分
	,@no_tonyu				DECIMAL(4,0)	-- 投入順
	,@no_kotei				DECIMAL(4,0)	-- 工程
	,@kbn_hin				SMALLINT		-- 品区分
AS
BEGIN
	UPDATE tr_kowake
	SET dt_tonyu = @dt_shori
		,flg_kanryo_tonyu = @flg_kanryo_tonyu
	WHERE cd_seihin = @cd_seihin
	AND cd_hinmei = @cd_hinmei
	AND no_lot_seihin = @no_lot_seihin
	AND su_kai = @su_kai
	AND su_ko = @su_ko
	AND no_kotei = @no_kotei
	AND wt_haigo = @wt_haigo
	AND kbn_seikihasu = @kbn_seikihasu
	AND kbn_kowakehasu = @kbn_kowakehasu
	AND no_tonyu = @no_tonyu
	AND kbn_hin = @kbn_hin
END
GO
