IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_SeizoNippo_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_SeizoNippo_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,kasahara.a>
-- Create date: <Create Date,,2013.05.27>
-- Last Update: <2015.03.19 tsujita.s>
-- Description:	��������̒ǉ�����
-- =============================================
CREATE PROCEDURE [dbo].[usp_SeizoNippo_create]
	@no_lot_seihin_new varchar(14)
--	@kbn_saiban varchar(2)
--	,@kbn_prefix varchar(1)
	,@dt_seizo datetime
	,@cd_shokuba varchar(10)
	,@cd_line varchar(10)
	,@cd_hinmei varchar(14)
	,@su_seizo_yotei decimal(10, 0)
	,@su_seizo_jisseki decimal(13, 3)
	,@flg_jisseki smallint
    ,@JissekiYojitsuFlag smallint
    ,@ShiyoYojitsuSeqNoSaibanKbn varchar(2)
    ,@ShiyoYojitsuSeqNoPrefixSaibanKbn varchar(1)
    ,@FlagFalse varchar(1)
    ,@persentKanzan DECIMAL(5, 2)
    ,@su_batch_jisseki DECIMAL(12, 6)
    ,@dt_shomi datetime
	,@no_lot_hyoji varchar(30)
AS
BEGIN
 
--DECLARE @no_lot_seihin_new varchar(14)

/********************************
	�̔ԏ���
********************************/
--EXEC dbo.usp_cm_Saiban @kbn_saiban, @kbn_prefix,
--@no_saiban = @no_lot_seihin_new output

/********************************
	���i�v��g�����@�V�K�o�^		
********************************/
INSERT INTO tr_keikaku_seihin
(
	no_lot_seihin
	,dt_seizo
	,cd_shokuba
	,cd_line
	,cd_hinmei
	,su_seizo_yotei
	,su_seizo_jisseki
	,flg_jisseki
	,kbn_denso
	,flg_denso
	,dt_update
	,su_batch_jisseki
	,dt_shomi
	,no_lot_hyoji
)
values
(
	@no_lot_seihin_new
	,@dt_seizo
	,@cd_shokuba
	,@cd_line
	,@cd_hinmei
	,@su_seizo_yotei
	,@su_seizo_jisseki
	,@flg_jisseki
	,0
	,0
	,GETUTCDATE()
	,@su_batch_jisseki
	,@dt_shomi
	,@no_lot_hyoji
)

IF @flg_jisseki = 1
BEGIN
	/*******************************
		�g�p�\���g�����@�V�K�o�^
	*******************************/
	-- ���ގg�p�}�X�^�@����
	DECLARE @cd_shizai VARCHAR(14)
	DECLARE @su_shiyo_shizai DECIMAL(12,6)
	DECLARE @su_shiyo DECIMAL(12,6)
    DECLARE @no_seq varchar(14)
    DECLARE @budomari DECIMAL(5,2)
	DECLARE ichiran_cd_shizai CURSOR FAST_FORWARD FOR
    SELECT cd_shizai, su_shiyo FROM udf_ShizaiShiyoYukoHan(@cd_hinmei, @FlagFalse, @dt_seizo)

	OPEN ichiran_cd_shizai
		IF (@@error <> 0)
		BEGIN
		    DEALLOCATE ichiran_cd_shizai
		END
		FETCH NEXT FROM ichiran_cd_shizai INTO @cd_shizai, @su_shiyo_shizai
        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- �g�p�\���@�̔ԏ���
            EXEC dbo.usp_cm_Saiban @ShiyoYojitsuSeqNoSaibanKbn, @ShiyoYojitsuSeqNoPrefixSaibanKbn,
            @no_saiban = @no_seq output
            
            -- �i���}�X�^����������擾
            SET @budomari = NULL -- ��x�N���A
            SET @budomari = (SELECT ma.ritsu_budomari FROM ma_hinmei ma
							 WHERE ma.cd_hinmei = @cd_shizai)
            IF @budomari IS NULL
            BEGIN
				SET @budomari = @persentKanzan	-- NULL�̏ꍇ�A�����l��ݒ�
			END
			
			-- �g�p�����v�Z
			SET @su_shiyo = 0.00 -- ��x�N���A
			SET @su_shiyo = @su_seizo_jisseki * @su_shiyo_shizai / @budomari * @persentKanzan

            -- �g�p�\���g�����@�V�K�o�^
            INSERT INTO tr_shiyo_yojitsu (
				no_seq
				,flg_yojitsu
				,cd_hinmei
				,dt_shiyo
				,no_lot_seihin
				,no_lot_shikakari
				,su_shiyo
            ) VALUES (
                @no_seq
                ,@JissekiYojitsuFlag
                ,@cd_shizai
                ,@dt_seizo
                ,@no_lot_seihin_new
                ,NULL
                --,(@su_seizo_jisseki * @su_shiyo_shizai) -- �g�p��
                ,@su_shiyo
            )

            FETCH NEXT FROM ichiran_cd_shizai INTO @cd_shizai, @su_shiyo_shizai
        END
    CLOSE ichiran_cd_shizai
    DEALLOCATE ichiran_cd_shizai
END

END
GO
