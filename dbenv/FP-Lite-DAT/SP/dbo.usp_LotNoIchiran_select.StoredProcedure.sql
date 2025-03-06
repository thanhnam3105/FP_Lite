IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_LotNoIchiran_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_LotNoIchiran_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\		�F���b�gNo.�ꗗ ����
�t�@�C����	�Fusp_LotNoIchiran_select
���͈���	�F@cd_hinmei, @dt_niuke, @kbn_zaiko
              , @page, @skip, @top
�o�͈���	�F	
�߂�l		�F
�쐬��		�F2013.10.03  ADMAX kakuta.y
�X�V��		�F2014.02.21  ADMAX kakuta.y -- �\��f�[�^���擾���Ȃ��悤�ɕύX
�X�V��		�F2015.10.05  MJ    ueno.k   -- �����������׎������׎���ѓ�(�[����)�ɕύX 
*****************************************************/
CREATE PROCEDURE [dbo].[usp_LotNoIchiran_select] 
	@cd_hinmei	VARCHAR(14)
	,@dt_niuke	DATETIME
	,@kbn_zaiko	SMALLINT
	,@page		SMALLINT		-- ��ʂ𔻒f�������( �u���b�gNo.�ʍ݌ɏڍׁv�F�u�g�p�ύ݌ɒ����v= 0�F1 )
	,@skip		DECIMAL(10)		-- �X�L�b�v
	,@top		DECIMAL(10)		-- �����f�[�^���
AS
BEGIN
	DECLARE @start	DECIMAL(10)
    DECLARE @end	DECIMAL(10)
    SET		@start	= @skip + 1
    SET		@end	= @skip + @top;
    

	IF @page = 0				-- ���b�gNo.�ʍ݌ɏڍ׉�ʂ���J���ꂽ�ꍇ 
	BEGIN

		WITH cte AS
			(
				SELECT 	
					ISNULL(max_no.no_lot, '') no_lot
					,min_no.tm_nonyu_jitsu tm_nonyu_jitsu
					,max_no.no_niuke
					,ROW_NUMBER() OVER (ORDER BY max_no.no_lot ,min_no.tm_nonyu_jitsu ,max_no.no_niuke) AS RN
					,no_nohinsho 
				FROM 
					(	-- �ŐV�̃V�[�P���X�ԍ����擾���܂��B
						SELECT 
							t_niu.no_niuke
							,MAX(t_niu.no_seq) AS max_seq
							,t_niu.cd_hinmei 
							,t_niu.no_lot
						FROM tr_niuke t_niu
						GROUP BY 
							t_niu.no_niuke
							,t_niu.cd_hinmei
							,t_niu.no_lot
					) max_no
					INNER JOIN 
						(			-- �d���ꎞ�̉׎���Ǝ��[���������擾���܂��B
							SELECT
								t_niu.no_niuke
								,t_niu.dt_niuke
								,t_niu.tm_nonyu_jitsu
								,t_niu.no_nohinsho
								,t_niu.dt_nonyu 
							FROM tr_niuke t_niu
							WHERE 
								t_niu.no_seq = 
								(
									SELECT
										MIN(no_seq)
									FROM tr_niuke
								)
						) min_no
					ON max_no.no_niuke = min_no.no_niuke
				WHERE
					max_no.cd_hinmei = @cd_hinmei
				--	AND @dt_niuke <= min_no.dt_niuke AND min_no.dt_niuke < (SELECT DATEADD(DD,1,@dt_niuke))
					AND @dt_niuke <= min_no.dt_nonyu AND min_no.dt_nonyu < (SELECT DATEADD(DD,1,@dt_niuke))
					AND ((max_no.no_lot IS NOT NULL OR max_no.no_lot <> '') AND (min_no.tm_nonyu_jitsu IS NOT NULL OR min_no.tm_nonyu_jitsu <> ''))
			)
		SELECT
			cnt
			,cte_row.no_lot
			,cte_row.tm_nonyu_jitsu
			,cte_row.no_niuke
			,cte_row.no_nohinsho 
		FROM
			(
				SELECT 
					MAX(RN) OVER() cnt
					,*
				FROM
					cte 
			) cte_row
		WHERE
			 RN BETWEEN @start AND @end
	END
	ELSE IF @page = 1					-- �g�p�ύ݌ɒ�����ʂ���J���ꂽ�ꍇ
	BEGIN

		WITH cte AS
			(
				SELECT 	
					ISNULL(max_no.no_lot, '') AS no_lot
					,min_no.tm_nonyu_jitsu tm_nonyu_jitsu
					,max_no.no_niuke
					,ROW_NUMBER() OVER (ORDER BY max_no.no_lot ,min_no.tm_nonyu_jitsu ,max_no.no_niuke) AS RN
					,no_nohinsho 
				FROM 
					(				-- �ŐV�̃V�[�P���X�ԍ����擾���܂��B
						SELECT
							t_niu.no_niuke
							,MAX(t_niu.no_seq) max_seq
							,t_niu.cd_hinmei
							,t_niu.no_lot
						FROM tr_niuke t_niu
						WHERE 
							t_niu.kbn_zaiko = @kbn_zaiko
						GROUP BY 
							t_niu.no_niuke
							,t_niu.cd_hinmei
							,t_niu.no_lot
					) max_no
				INNER JOIN
					(			-- �d���ꎞ�̉׎���Ǝ��[���������擾���܂��B
						SELECT
							t_niu.no_niuke
							,t_niu.dt_niuke
							,t_niu.tm_nonyu_jitsu
							,t_niu.no_nohinsho
							,t_niu.dt_nonyu 
						FROM tr_niuke t_niu
						WHERE 
							t_niu.no_seq = 
							(
								SELECT MIN(no_seq)
								FROM tr_niuke
							)
					) min_no
				ON max_no.no_niuke = min_no.no_niuke
				INNER JOIN
					(			-- �ŐV�̍݌ɐ��ƍ݌ɒ[�����擾���邽��
						SELECT 
							t_niu.no_niuke
							,t_niu.no_seq
							,t_niu.su_zaiko
							,t_niu.su_zaiko_hasu
						FROM tr_niuke t_niu
						WHERE 
							t_niu.kbn_zaiko = @kbn_zaiko
					) gt_zai
				ON max_no.no_niuke = gt_zai.no_niuke
				AND max_no.max_seq = gt_zai.no_seq
				WHERE max_no.cd_hinmei = @cd_hinmei
					AND @dt_niuke <= min_no.dt_niuke 
--					AND min_no.dt_niuke < (SELECT DATEADD(DD,1,@dt_niuke))
					AND min_no.dt_nonyu < (SELECT DATEADD(DD,1,@dt_niuke))
					AND gt_zai.su_zaiko = 0
					AND gt_zai.su_zaiko_hasu = 0
					AND ((max_no.no_lot IS NOT NULL OR max_no.no_lot <> '') AND (min_no.tm_nonyu_jitsu IS NOT NULL OR min_no.tm_nonyu_jitsu <> ''))
		)
		SELECT
			cnt
			,cte_row.no_lot
			,cte_row.tm_nonyu_jitsu
			,cte_row.no_niuke
			,cte_row.no_nohinsho 
		FROM(
				SELECT 
					MAX(RN) OVER() cnt
					,*
				FROM
					cte 
			) cte_row
		WHERE
			 RN BETWEEN @start AND @end
		END
END
GO
