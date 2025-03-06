IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_ShiyoYojitsu_insert') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_ShiyoYojitsu_insert]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==========================================================================
-- Author:		<Author,,cho.k>
-- Create date: <Create Date,,2016.11.22>
-- Description:	�g�p�\���g�����̓o�^����
-- ==========================================================================
CREATE PROCEDURE [dbo].[usp_ShiyoYojitsu_insert]
    @flg_yojitsu			SMALLINT      -- �\���t���O
    ,@cd_hinmei				VARCHAR(14)   -- �i���R�[�h
    ,@dt_shiyo				DATETIME      -- �g�p��
    ,@no_lot_seihin			VARCHAR(14)   -- ���i���b�g�ԍ�
    ,@no_lot_shikakari		VARCHAR(14)   -- �d�|�i���b�g�ԍ�
    ,@su_shiyo				DECIMAL(12,6) -- �g�p��
    ,@kbn_saiban			VARCHAR(2)    -- �̔ԋ敪(�g�p�\��)
    ,@kbn_prefix			VARCHAR(1)    -- �v���t�B�b�N�X(�g�p�\��)

AS

BEGIN

	-- �ǂ����NULL�̏ꍇ�́A�X�V�������s��Ȃ�
	IF (@no_lot_shikakari IS NULL)
		RETURN

	-- ==============================
    --  �g�p�\���V�[�P���X�ԍ����擾
	-- ==============================
    DECLARE @no VARCHAR(14)
    EXEC dbo.usp_cm_Saiban @kbn_saiban, @kbn_prefix, @no_saiban = @no OUTPUT


	-- ========================
    --  �g�p�\���g����INSERT
	-- ========================
    INSERT INTO tr_shiyo_yojitsu (
		no_seq
		,flg_yojitsu
		,cd_hinmei
		,dt_shiyo
		,no_lot_seihin
		,no_lot_shikakari
		,su_shiyo
	)
    VALUES (
		@no
		,@flg_yojitsu
		,@cd_hinmei
		,@dt_shiyo
		,@no_lot_seihin
		,@no_lot_shikakari
		,@su_shiyo
	)

END
GO
