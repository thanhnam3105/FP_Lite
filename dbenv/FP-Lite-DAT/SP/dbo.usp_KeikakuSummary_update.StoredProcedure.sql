IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_KeikakuSummary_update') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_KeikakuSummary_update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,tsujita.s>
-- Create date: <Create Date,,2015.01.15>
-- ���Ԑ��i�E�d�|�i�v��F�폜���̃T�}���X�V����
-- =============================================
CREATE PROCEDURE [dbo].[usp_KeikakuSummary_update]
	@dt_seizo				DATETIME
    ,@cd_shikakari			VARCHAR(14)
	,@cd_shokuba			VARCHAR(10)
	,@cd_line				VARCHAR(10)
	,@no_lot_shikakari		VARCHAR(14)
	-- �X�V���e
	,@wt_shikomi_keikaku	DECIMAL(12,6)
	,@wt_hitsuyo			DECIMAL(12,6)
	,@su_batch_keikaku		DECIMAL(12,6)
	,@su_batch_keikaku_hasu DECIMAL(12,6)
AS
BEGIN

	/************************************
	  �d���ʁA�K�v�ʁA�o�b�`���̍X�V
	*************************************/
	UPDATE su_keikaku_shikakari
	SET wt_shikomi_keikaku = @wt_shikomi_keikaku
		,wt_hitsuyo = @wt_hitsuyo
		,su_batch_keikaku = @su_batch_keikaku
		,su_batch_keikaku_hasu = @su_batch_keikaku_hasu
	WHERE 
		dt_seizo = @dt_seizo
		AND no_lot_shikakari = @no_lot_shikakari
		AND cd_shikakari_hin = @cd_shikakari
		AND cd_shokuba = @cd_shokuba
		AND cd_line = @cd_line
	
END
GO
