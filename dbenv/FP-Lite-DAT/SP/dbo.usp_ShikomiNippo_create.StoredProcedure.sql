IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_ShikomiNippo_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_ShikomiNippo_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,kasahara.a>
-- Create date: <Create Date,,2013.05.27>
-- Last Update: <2016.09.16 inoue.k>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_ShikomiNippo_create]
	@ShikakarihinKeikakuSaibanKbn varchar(2)
	,@ShikakarihinKeikakuPrefixSaibanKbn varchar(1)
	,@ShikakariLotSaibanKbn varchar(2)
	,@ShikakariLotPrefixSaibanKbn varchar(1)
    ,@dt_seizo datetime
    ,@cd_shikakari_hin varchar(14)
    ,@cd_shokuba varchar(10)
    ,@cd_line varchar(10)
    ,@wt_shikomi_jisseki decimal(12, 6)
    ,@wt_zaiko_jisseki decimal(12, 6)
    ,@wt_shikomi_zan decimal(12, 6)
    ,@su_batch_jisseki decimal(12, 6)
    ,@su_batch_jisseki_hasu decimal(12, 6)
    ,@ritsu_jisseki decimal(12, 6)
    ,@ritsu_jisseki_hasu decimal(12, 6)
    ,@flg_jisseki smallint
    ,@GenryoHinKbn smallint
    ,@JikaGenryoHinKbn smallint
    ,@JissekiYojitsuFlag smallint
    ,@HaigoMasterKbn smallint
    ,@FlagFalse smallint
    ,@ShiyoYojitsuSeqNoSaibanKbn varchar(2)
    ,@ShiyoYojitsuSeqNoPrefixSaibanKbn varchar(1)
AS
BEGIN
 
DECLARE @no_lot_shikakari_new varchar(14)
DECLARE @no_shikakari_keikaku_new varchar(14)

/********************************
	仕掛品ロット　採番処理
********************************/
EXEC dbo.usp_cm_Saiban @ShikakariLotSaibanKbn, @ShikakariLotPrefixSaibanKbn,
@no_saiban = @no_lot_shikakari_new output

/********************************
	仕掛品計画　採番処理
********************************/
EXEC dbo.usp_cm_Saiban @ShikakarihinKeikakuSaibanKbn, @ShikakarihinKeikakuPrefixSaibanKbn,
@no_saiban = @no_shikakari_keikaku_new output

/********************************
	仕掛品計画サマリー　新規登録		
********************************/
-- ラインコードがNULLの場合、ラインコードを取得する
IF (@cd_line IS NULL OR @cd_line = '')
BEGIN
    SELECT
        @cd_line = cd_line
    FROM
    (SELECT 
        se.cd_haigo
        ,se.cd_line
        ,MIN(se.no_juni_yusen) AS yusen
    FROM ma_seizo_line se
    INNER JOIN ma_line li
    ON se.cd_line = li.cd_line
    WHERE
        se.kbn_master = @HaigoMasterKbn
        AND cd_shokuba = @cd_shokuba
        AND cd_haigo = @cd_shikakari_hin
        AND se.flg_mishiyo = @FlagFalse
    GROUP BY se.cd_haigo, se.cd_line
    ) tb
END

INSERT INTO su_keikaku_shikakari
    (
        [dt_seizo]
        ,[cd_shikakari_hin]
        ,[cd_shokuba]
        ,[cd_line]
        ,[wt_hitsuyo]
        ,[wt_shikomi_keikaku]
        ,[wt_shikomi_jisseki]
        ,[wt_zaiko_keikaku]
        ,[wt_zaiko_jisseki]
        ,[wt_shikomi_zan]
        ,[wt_haigo_keikaku]
        ,[wt_haigo_keikaku_hasu]
        ,[su_batch_keikaku]
        ,[su_batch_keikaku_hasu]
        ,[ritsu_keikaku]
        ,[ritsu_keikaku_hasu]
        ,[wt_haigo_jisseki]
        ,[wt_haigo_jisseki_hasu]
        ,[su_batch_jisseki]
        ,[su_batch_jisseki_hasu]
        ,[ritsu_jisseki]
        ,[ritsu_jisseki_hasu]
        ,[su_label_sumi]
        ,[flg_label]
        ,[su_label_sumi_hasu]
        ,[flg_label_hasu]
        ,[flg_keikaku]
        ,[flg_jisseki]
        ,[flg_shusei]
        ,[no_lot_shikakari]
        ,[flg_shikomi]
    )
    VALUES (
        @dt_seizo
        ,@cd_shikakari_hin
        ,@cd_shokuba
        ,@cd_line
        --,null
        ,0
        --,null
        ,0
        ,@wt_shikomi_jisseki
        --,null
        ,0
        ,@wt_zaiko_jisseki
        ,@wt_shikomi_zan
        --,null
        ,0
        --,null
        ,0
        --,null
        ,0
        --,null
        ,0
        --,null
        ,0
        --,null
        ,0
        --,null
        ,0
        --,null
        ,0
        ,@su_batch_jisseki
        ,@su_batch_jisseki_hasu
        ,@ritsu_jisseki
        ,@ritsu_jisseki_hasu
        --,null
        ,0
        ,@FlagFalse
        --,null
        ,0
        ,@FlagFalse
        ,@FlagFalse
        ,@flg_jisseki
        ,@FlagFalse
        ,@no_lot_shikakari_new
        ,@FlagFalse
    )

/********************************
	仕掛品計画トラン　新規登録		
********************************/
INSERT INTO [tr_keikaku_shikakari]
    (
        [data_key]
        ,[dt_seizo]
        ,[dt_hitsuyo]
        ,[no_lot_seihin]
        ,[no_lot_shikakari]
        ,[no_lot_shikakari_oya]
        ,[cd_shokuba]
        ,[cd_line]
        ,[cd_shikakari_hin]
        ,[wt_shikomi_keikaku]
        ,[wt_shikomi_jisseki]
        ,[su_kaiso_shikomi]
        ,[dt_update]
        ,[wt_haigo_keikaku]
        ,[wt_haigo_jisseki]
        ,[su_batch_yotei]
        ,[su_batch_jisseki]
        ,[ritsu_bai]
        ,[cd_hinmei]
        ,[wt_hitsuyo]
        ,[data_key_oya])
    VALUES (
        @no_shikakari_keikaku_new
        ,@dt_seizo
        ,null
        ,null
        ,@no_lot_shikakari_new
        ,null
        ,@cd_shokuba
        ,@cd_line
        ,@cd_shikakari_hin
        --,null
        ,0
        ,@wt_shikomi_jisseki
        --,null
        ,0
        ,GETUTCDATE()
        --,null
        ,0
        --,null
        ,0
        --,null
        ,0
        ,@su_batch_jisseki
        --,null
        ,0
        ,null
        --,null
        ,0
        ,null
    )

-- 以下処理は確定行のみ行う
IF @flg_jisseki = 1
BEGIN
	/*******************************
		使用予実トラン　新規登録
	*******************************/
	-- 配合レシピマスタ　検索
	DECLARE @cd_hinmei VARCHAR(14)
	DECLARE @wt_shikomi DECIMAL(12, 6) -- 配合重量
	DECLARE @ritsu_hiju DECIMAL(6, 4)
	DECLARE @ritsu_budomari DECIMAL(5, 2)
	DECLARE @ritsu_budomari_mei DECIMAL(5, 2)
	DECLARE @no_seq VARCHAR(14)
	DECLARE ichiran_cd_hinmei CURSOR FAST_FORWARD FOR
    SELECT 
        cd_hinmei
        ,wt_shikomi
        ,ISNULL(ritsu_hiju_recipe, 1) AS ritsu_hiju
        ,ISNULL(ritsu_budomari_recipe, 100) AS ritsu_budomari
        ,ISNULL(ritsu_budomari_mei, 100) AS ritsu_budomari_mei
    FROM udf_HaigoRecipeYukoHan(@cd_shikakari_hin, @FlagFalse, @dt_seizo)
    WHERE 
		kbn_hin IN (@GenryoHinKbn, @JikaGenryoHinKbn)
		AND cd_hinmei IS NOT NULL

	OPEN ichiran_cd_hinmei
		IF (@@error <> 0)
		BEGIN
		    DEALLOCATE ichiran_cd_hinmei
		END
		FETCH NEXT FROM ichiran_cd_hinmei INTO @cd_hinmei, @wt_shikomi, @ritsu_hiju, @ritsu_budomari, @ritsu_budomari_mei
        WHILE (@@FETCH_STATUS = 0)
        BEGIN
            -- 使用予実　採番処理
            EXEC dbo.usp_cm_Saiban @ShiyoYojitsuSeqNoSaibanKbn, @ShiyoYojitsuSeqNoPrefixSaibanKbn,
            @no_saiban = @no_seq output

            -- 使用予実トラン　新規登録
            INSERT INTO tr_shiyo_yojitsu (
				no_seq
				,flg_yojitsu
				,cd_hinmei
				,dt_shiyo
				,no_lot_seihin
				,no_lot_shikakari
				,su_shiyo
				,data_key_tr_shikakari
            )
            VALUES (
                @no_seq
                ,@JissekiYojitsuFlag
                ,@cd_hinmei
                ,@dt_seizo
                ,NULL
                ,@no_lot_shikakari_new
                ,dbo.udf_ShiyoYojitsuShiyoSu(
                    @wt_shikomi
                    ,@ritsu_hiju
                    ,@ritsu_budomari
					,@ritsu_budomari_mei
                    ,@su_batch_jisseki
                    ,@su_batch_jisseki_hasu
                    ,@ritsu_jisseki
                    ,@ritsu_jisseki_hasu
                )
                ,NULL
            )
            FETCH NEXT FROM ichiran_cd_hinmei INTO @cd_hinmei, @wt_shikomi, @ritsu_hiju, @ritsu_budomari, @ritsu_budomari_mei
        END
    CLOSE ichiran_cd_hinmei
    BEGIN
        DEALLOCATE ichiran_cd_hinmei
    END
END

END
GO
