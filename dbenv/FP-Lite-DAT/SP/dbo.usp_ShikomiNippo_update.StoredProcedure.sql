IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_ShikomiNippo_update') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_ShikomiNippo_update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,kasahara.a>
-- Create date: <Create Date,,2013.05.27>
-- Description:	<Description,,>
-- Update date: <Update Date,,2018.07.30>
-- =============================================
CREATE PROCEDURE [dbo].[usp_ShikomiNippo_update]
    @dt_seizo datetime
    ,@cd_shikakari_hin varchar(14)
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
    ,@no_lot_shikakari varchar(14)
    ,@ShiyoYojitsuSeqNoSaibanKbn varchar(2)
    ,@ShiyoYojitsuSeqNoPrefixSaibanKbn varchar(1)
    ,@FlagFalse smallint
AS
BEGIN
 
DECLARE @flg_jisseki_old SMALLINT
DECLARE @wt_shikomi_jisseki_old DECIMAL(10,0)
DECLARE @ritsu_jisseki_old DECIMAL(12, 6)
DECLARE @ritsu_jisseki_hasu_old DECIMAL(12, 6)
DECLARE @su_batch_jisseki_old DECIMAL(12, 6)
DECLARE @su_batch_jisseki_hasu_old DECIMAL(12, 6)

-- 更新前の確定有無を取得
SELECT @flg_jisseki_old = flg_jisseki
    ,@wt_shikomi_jisseki_old = wt_shikomi_jisseki
    ,@ritsu_jisseki_old = ritsu_jisseki
    ,@ritsu_jisseki_hasu_old = ritsu_jisseki_hasu
    ,@su_batch_jisseki_old = su_batch_jisseki
    ,@su_batch_jisseki_hasu_old = su_batch_jisseki_hasu
FROM su_keikaku_shikakari WHERE no_lot_shikakari = @no_lot_shikakari

/********************************
	仕掛品計画サマリー　更新		
********************************/
UPDATE su_keikaku_shikakari
SET
    [wt_shikomi_jisseki] = @wt_shikomi_jisseki
    ,[wt_zaiko_jisseki] = @wt_zaiko_jisseki
    ,[wt_shikomi_zan] = @wt_shikomi_zan
    ,[su_batch_jisseki] = @su_batch_jisseki
    ,[su_batch_jisseki_hasu] = @su_batch_jisseki_hasu
    ,[ritsu_jisseki] = @ritsu_jisseki
    ,[ritsu_jisseki_hasu] = @ritsu_jisseki_hasu
    ,[flg_jisseki] = @flg_jisseki
WHERE no_lot_shikakari = @no_lot_shikakari

/*******************************************
	使用予実トラン　新規登録・更新・削除
*******************************************/
-- 配合レシピマスタ　検索
DECLARE @cd_hinmei VARCHAR(14)
DECLARE @wt_shikomi DECIMAL(12, 6)
DECLARE @ritsu_hiju DECIMAL(6, 4)
DECLARE @ritsu_budomari DECIMAL(5, 2)
DECLARE @ritsu_budomari_mei DECIMAL(5, 2)
DECLARE @su_shiyo DECIMAL(30, 6)
DECLARE @no_seq varchar(14)
DECLARE @cnt smallint
SET @cnt = 0

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
    FETCH NEXT FROM ichiran_cd_hinmei INTO @cd_hinmei, @wt_shikomi, @ritsu_hiju, @ritsu_budomari,@ritsu_budomari_mei
    WHILE @@FETCH_STATUS = 0
    BEGIN

        /*******************************
            使用予実トラン　新規登録
        *******************************/
        -- 以下処理は新しい確定行のみ行う
        IF (@flg_jisseki_old = 0 AND @flg_jisseki = 1)
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
                ,@no_lot_shikakari
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
        END

        /*******************************
            使用予実トラン　削除
        *******************************/
        IF (@flg_jisseki_old = 1 AND @flg_jisseki = 0)
        BEGIN
            DELETE tr_shiyo_yojitsu
            WHERE
                flg_yojitsu = @JissekiYojitsuFlag
                AND no_lot_shikakari = @no_lot_shikakari
        END

        /*******************************
            使用予実トラン　更新
        *******************************/
        -- 以下処理は確定かつ仕込量
        IF (@flg_jisseki_old = 1 AND @flg_jisseki = 1)
        BEGIN
            -- 削除
            IF (@cnt = 0)
            BEGIN
                DELETE tr_shiyo_yojitsu
                WHERE
					flg_yojitsu = @JissekiYojitsuFlag
                    AND dt_shiyo = @dt_seizo
                    AND no_lot_shikakari = @no_lot_shikakari
            END

            -- 使用予実　採番処理
            EXEC dbo.usp_cm_Saiban @ShiyoYojitsuSeqNoSaibanKbn, @ShiyoYojitsuSeqNoPrefixSaibanKbn,
            @no_saiban = @no_seq output

            -- 新規登録
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
                ,@no_lot_shikakari
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
        END
        SET @cnt = @cnt + 1
        FETCH NEXT FROM ichiran_cd_hinmei INTO @cd_hinmei, @wt_shikomi, @ritsu_hiju, @ritsu_budomari,@ritsu_budomari_mei
    END
CLOSE ichiran_cd_hinmei
BEGIN
    DEALLOCATE ichiran_cd_hinmei
END
END
GO
