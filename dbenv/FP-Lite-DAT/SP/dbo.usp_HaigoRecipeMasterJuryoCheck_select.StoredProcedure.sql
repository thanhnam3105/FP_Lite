IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_HaigoRecipeMasterJuryoCheck_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_HaigoRecipeMasterJuryoCheck_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,okada.k>
-- Create date: <Create Date,,2013.05.30>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_HaigoRecipeMasterJuryoCheck_select]
	@cd_hinmei		AS VARCHAR(14)	-- �i���R�[�h
	,@kbn_hin		AS SMALLINT		-- �i�敪	
	,@kbn_jotai_sonota	AS SMALLINT		-- ��ԋ敪(���̑�)
	,@kbn_jotai_shikakari	AS SMALLINT	-- ��ԋ敪(�d�|�i)
	,@kbn_hin_genryo	AS SMALLINT		-- �i�敪(����)
	,@kbn_hin_shikakari	AS SMALLINT		-- �i�敪(�d�|�i)
AS
BEGIN
	
DECLARE @result_juryo AS DECIMAL(12,6)
	
	--�ʂ̏������d�ʐݒ���擾
		SET @result_juryo = 
		(
			SELECT 
				juryo.wt_kowake
			FROM 
				ma_juryo AS juryo
			WHERE 
				juryo.cd_hinmei = @cd_hinmei
				AND juryo.kbn_hin = @kbn_hin
				AND juryo.kbn_jotai = @kbn_jotai_sonota
		)
	
	--�ʂ̏����d�ʐݒ肪���������ꍇ�A���ʐݒ肩��擾
	IF @result_juryo IS NULL
	BEGIN
		IF @kbn_hin = @kbn_hin_shikakari BEGIN
			SET @result_juryo = 
			(
				SELECT 
					juryo.wt_kowake
				FROM 
					ma_juryo AS juryo
				WHERE
					juryo.cd_hinmei = '-'
					AND juryo.kbn_hin = @kbn_hin
					AND juryo.kbn_jotai = @kbn_jotai_shikakari
			)
		END
		ELSE IF @kbn_hin = @kbn_hin_genryo BEGIN
			SET @result_juryo = 
			(
				SELECT 
					juryo.wt_kowake
				FROM 
					ma_juryo AS juryo
				INNER JOIN 
					ma_hinmei AS hin 
				ON (
					hin.cd_hinmei = @cd_hinmei
					AND hin.kbn_hin = juryo.kbn_hin				
					AND hin.kbn_hin = juryo.kbn_hin
					AND hin.kbn_jotai = juryo.kbn_jotai
				)
				WHERE
					juryo.cd_hinmei = '-'
					AND juryo.kbn_hin = @kbn_hin
			)
		END
	END

	--�ݒ肪�Ȃ������ꍇ�A�����d�ʂ̃f�t�H���g�l1kg��ݒ�
	IF @result_juryo IS NULL
	BEGIN
		SET @result_juryo = 1
	END
	
	select @result_juryo AS wt_kowake

END
GO
