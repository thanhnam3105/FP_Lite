IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_LotBetsuJissekiJuryo_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_LotBetsuJissekiJuryo_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\		�F���b�g�ʎ��яd��
�t�@�C����	�Fusp_LotBetsuJissekiJuryo_select
���͈���	�F@no_lot_oya, @skip, @top
�o�͈���	�F
�߂�l		�F
�쐬��		�F2013.10.09  ADMAX kakuta.y
�X�V��		�F2016.08.24  BRC   ieki.h		LB�Ή�
�X�V��		�F2017.02.13  BRC   matsumura.y		QB�T�|�[�gNo.33�Ή�
*****************************************************/
CREATE PROCEDURE [dbo].[usp_LotBetsuJissekiJuryo_select] 
	@no_lot_oya	VARCHAR(14)		-- �������ъm�F���.�e���b�g�ԍ�
	,@skip		DECIMAL(10)		-- �X�L�b�v
	,@top		DECIMAL(10)		-- �����f�[�^���
AS
BEGIN							-- ���b�g�ؑւ��s�����f�[�^�̃��b�g�ʏd�ʂ��擾���܂��B

	DECLARE @start	DECIMAL(10)
    DECLARE @end	DECIMAL(10)
    SET		@start	= @skip + 1
    SET		@end	= @skip + @top;

    WITH cte AS
		(
			SELECT
				t_lot.no_lot
				--,t_kowa.wt_jisseki
				,CASE --���ђl(������3�ʂ܂ŕ\���B�؎̂�
				WHEN tani.cd_tani = '3' 
				THEN ROUND(t_kowa.wt_jisseki * 1000, 3, 1) --g�ϊ�
				ELSE ROUND(t_kowa.wt_jisseki, 3, 1) 
				END AS wt_jisseki
				,tani.nm_tani
				,ROW_NUMBER() OVER (ORDER BY t_lot.no_lot) AS RN
			FROM tr_kowake t_kowa
			INNER JOIN tr_lot t_lot
			ON t_kowa.no_lot_kowake = t_lot.no_lot_jisseki
			LEFT OUTER JOIN  ma_hakari hakari
			ON t_kowa.cd_hakari = hakari.cd_hakari
			LEFT OUTER JOIN ma_tani tani
			ON hakari.cd_tani = tani.cd_tani
			WHERE
				t_kowa.no_lot_oya = @no_lot_oya
		)
	SELECT
		cnt
		,cte_row.no_lot
		,cte_row.wt_jisseki
		,cte_row.nm_tani
	FROM
		(
			SELECT
				MAX(RN) OVER() AS cnt
				,*
			FROM cte
		) cte_row
	WHERE
		RN BETWEEN @start AND @end
END
GO
