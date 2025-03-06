IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_TonyuMainMenu_TonyuJokyo_update') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_TonyuMainMenu_TonyuJokyo_update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**********************************************************************
機能：投入メインメニュー　投入状況取得処理
ファイル名：usp_TonyuMainMenu_TonyuJokyo_update
入力引数：@cd_panel, @cd_shokuba, @cd_tanto, @FlagFalse,
    @KbnseikiHasuSeiki, @nm_naiyo_jisseki, @kbn_kyosei
出力引数：-
戻り値：-
作成日：2013.12.19 kasahara.a
更新日：2016.12.13 motojima.m 中文対応
**********************************************************************/
CREATE PROCEDURE [dbo].[usp_TonyuMainMenu_TonyuJokyo_update]
    @cd_panel						VARCHAR(14)		-- パネルコード
    ,@cd_shokuba					VARCHAR(10)		-- 職場コード
    ,@cd_tanto						VARCHAR(10)		-- ログインユーザーコード
    ,@FlagFalse						VARCHAR(1)		-- フラグ（false）
    ,@KbnSeikiHasuSeiki				VARCHAR(1)		-- 正規端数区分
    --,@JissekiNaiyoKyoseiShuryo	VARCHAR(20)		-- 実績内容（強制終了） 
    ,@JissekiNaiyoKyoseiShuryo		NVARCHAR(20)	-- 実績内容（強制終了） 
    ,@KbnKyoseiKyoseiShuryo			VARCHAR(1)		-- 強制歩進区分（強制終了）
	,@sagyoFlag						BIT				-- 仕込作業指示マークの場合はtrue
	,@shoriDate						DATETIME		-- 処理日(強制終了日付(システム日付))
AS

BEGIN

DECLARE @cd_line varchar(10)
DECLARE @nm_line nvarchar(50)
DECLARE @cd_haigo varchar(14)
DECLARE @nm_haigo nvarchar(50)
DECLARE @no_kotei decimal(4, 0)
DECLARE @su_yotei_disp decimal(4, 0)
DECLARE @su_kai_disp decimal(4, 0)
DECLARE @su_yotei decimal(4, 0)
DECLARE @su_kai decimal(4, 0)
DECLARE @su_yotei_hasu decimal(4, 0)
DECLARE @su_kai_hasu decimal(4, 0)
DECLARE @no_tonyu decimal(4, 0)
DECLARE @mark varchar(2)
DECLARE @cd_hinmei varchar(14)
DECLARE @nm_hinmei nvarchar(50)
DECLARE @wt_kihon decimal(4, 0)
DECLARE @no_lot_seihin varchar(14)
DECLARE @kbn_seikihasu smallint
DECLARE @kbn_jokyo smallint
DECLARE @dt_seizo datetime
DECLARE @dt_yotei_seizo datetime
DECLARE @true BIT = 1;

SELECT DISTINCT
    @cd_haigo = tj.cd_haigo
    ,@nm_haigo = tj.nm_haigo
    ,@dt_seizo = tj.dt_seizo
    ,@dt_yotei_seizo = tj.dt_yotei_seizo
    ,@no_kotei = tj.no_kotei
    ,@su_kai_disp = tj.su_kai_disp
    ,@su_yotei = tj.su_yotei
    ,@su_yotei_hasu = tj.su_yotei_hasu
    ,@cd_line = tj.cd_line
    ,@no_lot_seihin = tj.no_lot_seihin
    ,@kbn_seikihasu = tj.kbn_seikihasu
FROM udf_TonyuJokyo(@cd_panel, @cd_Shokuba, @FlagFalse, @KbnSeikiHasuSeiki) tj

/*-----------------------------------
    投入開始トラン更新
-----------------------------------*/
UPDATE tr_tonyu_start
SET
    dt_start = GETUTCDATE()
    ,dt_end = NULL
    ,nm_haigo = @nm_haigo
    ,dt_seizo = @dt_seizo
    ,dt_yotei_seizo = @dt_yotei_seizo
    ,su_yotei_seizo = @su_yotei
    ,su_yotei_seizo_hasu = @su_yotei_hasu
    ,cd_shokuba = @cd_shokuba
    ,cd_line = @cd_line
    ,cd_tanto = @cd_tanto
WHERE
    cd_haigo = @cd_haigo
    AND no_kotei = @no_kotei
    AND su_kai = @su_kai_disp
    AND no_lot_seihin = @no_lot_seihin
    AND kbn_seikihasu = @kbn_seikihasu

SELECT
    @cd_line = tj.cd_line
    ,@nm_line = tj.nm_line
    ,@cd_haigo = tj.cd_haigo
    ,@nm_haigo = tj.nm_haigo
    ,@no_kotei = tj.no_kotei
    ,@su_yotei = tj.su_yotei
    ,@su_yotei_hasu = tj.su_yotei_hasu
    ,@su_kai_disp = tj.su_kai_disp
    ,@no_tonyu = tj.no_tonyu
    ,@mark = tj.mark
    ,@cd_hinmei = tj.cd_hinmei
    ,@nm_hinmei = tj.nm_hinmei
    ,@wt_kihon = tj.wt_kihon
    ,@no_lot_seihin = tj.no_lot_seihin
    ,@kbn_seikihasu = tj.kbn_seikihasu
    ,@kbn_jokyo = tj.kbn_jokyo
    ,@dt_seizo = tj.dt_seizo
    ,@dt_yotei_seizo = tj.dt_yotei_seizo
FROM udf_TonyuJokyo(@cd_panel, @cd_Shokuba, @FlagFalse, @KbnSeikiHasuSeiki) tj

/*-----------------------------------
    投入状況トラン削除
-----------------------------------*/
DELETE tr_tonyu_jokyo
WHERE
    cd_panel = @cd_panel
    AND cd_shokuba = @cd_shokuba
    AND cd_line = @cd_line
    AND kbn_jokyo = @kbn_jokyo

/*-----------------------------------
    投入トラン追加
-----------------------------------*/
INSERT INTO [tr_tonyu]
           ([dt_seizo]
           ,[cd_shokuba]
           ,[cd_line]
           ,[cd_haigo]
           ,[cd_hinmei]
           ,[nm_hinmei]
           ,[su_kai]
           ,[no_tonyu]
           ,[wt_haigo]
           ,[wt_nisugata]
           ,[su_nisugata]
           ,[wt_kowake]
           ,[su_kowake]
           ,[wt_kowake_hasu]
           ,[su_kowake_hasu]
           ,[nm_tani]
           ,[ritsu_hiju]
           ,[nm_naiyo_jisseki]
           ,[dt_shori]
           ,[nm_mark]
           ,[cd_tanto]
           ,[dt_yotei_seizo]
           ,[no_kotei]
           ,[su_ko_label]
           ,[su_kai_label]
           ,[dt_label_hakko]
           ,[no_lot]
           ,[dt_shomi]
           ,[nm_naiyo_qr]
           ,[biko]
           ,[kbn_kyosei]
           ,[no_lot_seihin]
           ,[kbn_seikihasu])
     VALUES
        (
           @dt_seizo
           ,@cd_shokuba
           ,@cd_line
           ,@cd_haigo
           ,@cd_hinmei
           ,@nm_hinmei
           ,@su_kai_disp
           ,@no_tonyu
           ,CASE @sagyoFlag
				WHEN @true THEN 0
				ELSE @wt_kihon
			END
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,@JissekiNaiyoKyoseiShuryo
           --,GETUTCDATE()
		   ,@shoriDate
           ,@mark
           ,@cd_tanto
           ,@dt_yotei_seizo
           ,@no_kotei
           ,0
           ,0
           ,null
           ,null
           ,null
           ,null
           ,@JissekiNaiyoKyoseiShuryo
           ,@KbnKyoseiKyoseiShuryo
           ,@no_lot_seihin
           ,@kbn_seikihasu
        )
END
GO