IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_CheckKasaneKowakeExist_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_CheckKasaneKowakeExist_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能        ：小分け実績存在チェック  重ね小分ラベルの小分実績・賞味期限チェック
ファイル名  ：usp_KowakeCheckKasaneKowake_select
作成日      ：2016.02.01 ADMAX shibao.s 
更新日      ：2017.04.26 BRC   kanehira.d Q&Bサポート対応No.56
*****************************************************/
CREATE PROCEDURE [dbo].[usp_CheckKasaneKowakeExist_select]

	@dt_seizo		        DATETIME		-- 検索条件：製造日
	,@cd_seihin             VARCHAR(14)		-- 検索条件：製品コード
	,@su_kai				DECIMAL(4)		-- 検索条件：回数
	,@su_ko		            DECIMAL(4)		-- 検索条件：個数
	,@no_tonyu_start		DECIMAL(4)		-- 検索条件：重ね開始投入番号
	,@no_tonyu_end			DECIMAL(4)		-- 検索条件：重ね終了投入番号
	,@no_kotei 				DECIMAL(4)		-- 検索条件：工程番号
	,@cd_line				VARCHAR(10)		-- 検索条件：ラインコード
	,@no_lot_seihin 		VARCHAR(14)		-- 検索条件：製品ロット番号
	,@kbn_seikihasu			SMALLINT		-- 検索条件：正規、端数区分	
	,@kbn_kowakehasu		SMALLINT		-- 検索条件：正規、端数小分区分
	,@ritsu_kihon           DECIMAL(5,2)    -- 検索条件：基本倍率
AS
BEGIN

SELECT DISTINCT
	k.wt_haigo
	,k.cd_seihin
	,k.no_kotei
	,k.dt_seizo
	,k.su_ko
	,k.su_kai
	,k.kbn_hin
	,k.cd_line
	,k.kbn_seikihasu
	,k.kbn_kowakehasu
	,k.no_lot_seihin
	,k.no_lot_oya
	,k.cd_hinmei
	,k.no_tonyu
	,dt_shomi_kaifu
FROM 
	tr_kowake k
WHERE
	k.dt_seizo = @dt_seizo
	AND k.cd_seihin = @cd_seihin 
	AND k.su_kai = @su_kai
	AND k.su_ko = @su_ko
	AND k.no_tonyu BETWEEN @no_tonyu_start AND @no_tonyu_end
	AND k.no_kotei = @no_kotei
	AND k.cd_line = @cd_line
	AND k.no_lot_seihin = @no_lot_seihin
	AND k.kbn_seikihasu = @kbn_seikihasu
	AND k.kbn_kowakehasu = @kbn_kowakehasu
	AND (k.ritsu_kihon IS NULL
			OR k.ritsu_kihon = @ritsu_kihon)
Order by no_tonyu

END
GO
