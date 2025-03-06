IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_NiukeNyuryoku_select_05') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_NiukeNyuryoku_select_05]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\        �F�׎���� ���ь����@�׎�g����(���тȂ�)�̏ꍇ
�t�@�C����	�Fusp_NiukeNyuryoku_select_05
���͈���	�F@skip, @top, @no_nonyu
�o�͈���	�F
�߂�l		�F
�쐬��		�F2016.09.01  BRC   motojima.m �׎���͍s�ǉ��Ή�
�X�V��		�F2016.11.15  BRC   cho.k �[���m��t���O�̏����l��0�Ŏ擾
*****************************************************/
CREATE PROCEDURE [dbo].[usp_NiukeNyuryoku_select_05]
	@skip					DECIMAL(10)		-- �X�L�b�v
	,@top					DECIMAL(10)		-- �����f�[�^���
	,@no_nonyu				VARCHAR(13)		-- �[���ԍ�
AS
BEGIN

	DECLARE @start	DECIMAL(10)
    DECLARE @end	DECIMAL(10)
	-- �t���O�l
	DECLARE @zeroToFlg	SMALLINT
	DECLARE @oneToFlg	SMALLINT

    SET		@start	= @skip + 1
    SET		@end	= @skip + @top
	SET		@zeroToFlg	= 0
	SET		@oneToFlg	= 1


	DECLARE @initStr	VARCHAR
	SET @initStr = '';

	DECLARE @noSeqMin DECIMAL(8,0)
	SET @noSeqMin = (
						SELECT
							MIN(no_seq)
						FROM tr_niuke
					);

	WITH cte AS
		(

			SELECT	
				t_niu.tm_nonyu_jitsu tm_nonyu_jitsu					-- ����
				,t_niu.su_nonyu_jitsu								-- C/S��
				,t_niu.su_nonyu_jitsu_hasu							-- �[��
				,t_niu.kin_kuraire									-- ���z
				,ISNULL(t_niu.no_lot, @initStr ) AS no_lot			-- ���b�gNo.
				,t_niu.dt_seizo										-- ������
				,t_niu.dt_kigen										-- �ܖ�����
				,t_niu.no_nohinsho									-- �[�i���ԍ�
				,t_niu.no_zeikan_shorui								-- �Ŋ֏���No.
				,ISNULL(t_niu.no_denpyo, @initStr ) AS no_denpyo	-- �`�[No.
				,ISNULL(t_niu.biko, @initStr ) AS biko				-- ���l
				,t_niu.no_niuke										-- �׎�ԍ�(��\������)
				,CASE t_niu.tm_nonyu_jitsu
					WHEN NULL THEN 0
					ELSE 1
				END flg_tm_jitsu									-- ���ю����t���O(��\������)
				,t_niu.dt_nonyu										-- �[����
				,t_niu.kbn_nyuko AS kbn_nyuko						-- ���ɋ敪(��\������)
				,t_niu.no_nonyu AS no_nonyu							-- �[���ԍ�(��\������)
				,t_niu.no_nonyu AS no_nonyu_yotei					-- �[���\��ԍ�(��\������)
				--,t_niu.flg_kakutei AS flg_kakutei_nonyu				-- �m��t���O(��\������)
				,@zeroToFlg	AS flg_kakutei_nonyu				-- �m��t���O(��\������)
				,ROW_NUMBER() OVER (ORDER BY t_niu.tm_nonyu_jitsu, t_niu.no_niuke) AS RN
			FROM tr_niuke t_niu
			WHERE 
				t_niu.no_nonyu = @no_nonyu
				AND t_niu.no_seq = @noSeqMin
		)
		
		-- ��ʂɕԋp����l���擾
		SELECT
			cnt
			,cte_row.tm_nonyu_jitsu
			,cte_row.su_nonyu_jitsu
			,cte_row.su_nonyu_jitsu_hasu
			,cte_row.kin_kuraire
			,cte_row.no_lot
			,cte_row.dt_seizo
			,cte_row.dt_kigen
			,cte_row.no_nohinsho
			,cte_row.no_zeikan_shorui
			,cte_row.no_denpyo
			,cte_row.biko
			--��\������
			,cte_row.no_niuke
			,cte_row.flg_tm_jitsu
			,cte_row.dt_nonyu
			,cte_row.kbn_nyuko
			,cte_row.no_nonyu
			,cte_row.no_nonyu_yotei
			,cte_row.flg_kakutei_nonyu
		FROM
			(
				SELECT 
					MAX(RN) OVER() AS cnt
					,*
				FROM cte 
			) cte_row
		WHERE RN BETWEEN @start AND @end
		ORDER BY RN
END
GO
