IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_SeizoNippo_select_02') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_SeizoNippo_select_02]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\        	�F�������� �폜�Ώۂ̉׎�ԍ����g���[�X�p���b�g�g�����̑��݂��`�F�b�N���܂��B
�t�@�C����  	�Fusp_SeizoNippo_select_02
���͈���    	�F@no_niuke
�o�͈���    	�F
�߂�l      	�F
�쐬��      	�F2016.04.14  Khang
�X�V��      	�F
*****************************************************/
CREATE PROCEDURE [dbo].[usp_SeizoNippo_select_02] 
	@no_niuke		VARCHAR(14)
	,@flg_jisseki	SMALLINT
AS

BEGIN
	DECLARE @flg_jisseki_old SMALLINT

	SET @flg_jisseki_old = ( SELECT flg_jisseki FROM tr_keikaku_seihin WHERE no_lot_seihin = @no_niuke )

	-- �m��`�F�b�N���O����Ă����ꍇ���������܂�
	IF (@flg_jisseki_old = 1 AND @flg_jisseki = 0)
	BEGIN
		SELECT		
			TRACE.no_niuke AS no_lot_seihin	--���i���b�g�ԍ�
			,KEIKAKU.no_lot_shikakari		--�d�|�i���b�g�ԍ�
			,KEIKAKU.dt_seizo				--�d����
		FROM 
		(
			SELECT DISTINCT
				no_lot_shikakari
				,no_niuke
			FROM tr_lot_trace 
			WHERE no_niuke = @no_niuke
		) TRACE

		INNER JOIN su_keikaku_shikakari KEIKAKU
		ON TRACE.no_lot_shikakari = KEIKAKU.no_lot_shikakari
	END
	ELSE
	BEGIN
		SELECT		
			NULL AS no_lot_seihin			--���i���b�g�ԍ�
			,NULL AS no_lot_shikakari		--�d�|�i���b�g�ԍ�
			,NULL AS dt_seizo				--�d����
	END

END

GO