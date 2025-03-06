IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_NiukeNyuryoku_select_04') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_NiukeNyuryoku_select_04]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\        �F�׎���� �폜�Ώۂ̉׎�ԍ����g���[�X�p���b�g�g�����̑��݂��`�F�b�N���܂��B
�t�@�C����  �Fusp_NiukeNyuryoku_select_04
���͈���    �F@no_niuke
�o�͈���    �F
�߂�l      �F
�쐬��      �F2016.03.23  Khang
�X�V��      �F
*****************************************************/
CREATE PROCEDURE [dbo].[usp_NiukeNyuryoku_select_04] 
	@no_niuke				VARCHAR(14)
AS

BEGIN
	SELECT
		NIUKE.dt_niuke					--�׎��
		,NIUKE.tm_nonyu_jitsu			--�[����
		,NIUKE.no_lot					--���b�g�ԍ�
		,KEIKAKU.no_lot_shikakari		--�d�|�i���b�g�ԍ�
		,KEIKAKU.dt_seizo				--�d����
		,KEIKAKU.cd_shikakari_hin		--�d�|�i�R�[�h
	FROM 
	(
		SELECT
			no_lot_shikakari
			,no_niuke
		FROM tr_lot_trace 
		WHERE no_niuke = @no_niuke
	) TRACE

	LEFT OUTER JOIN su_keikaku_shikakari KEIKAKU
	ON TRACE.no_lot_shikakari = KEIKAKU.no_lot_shikakari

	LEFT OUTER JOIN tr_niuke NIUKE
	ON TRACE.no_niuke = NIUKE.no_niuke
END

GO