IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_KasaneLabelOkikae_Mark_By_Recipe_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_KasaneLabelOkikae_Mark_By_Recipe_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		ADMAX shibao.s
-- Create date: 2016.01.26
-- Description:	�d�˃��x���u��������ʂŃ��x���ɕR�Â���������
--              �������Ă��邩�m�F���邽�߂̃X�g�A�h
-- =============================================
CREATE PROCEDURE [dbo].[usp_KasaneLabelOkikae_Mark_By_Recipe_select]
	@haigoCode			  VARCHAR(14)	-- ���x���@�z���R�[�h
	,@seizoDay			  DATETIME	    -- ���x���@�����\���(������10:00�Œ�)
	,@shiyoMishiyoFlag	  SMALLINT	    -- �敪�^�R�[�h�ꗗ.���g�p�t���O.�g�p
	,@no_kotei            DECIMAL       -- �H���ԍ�
	,@no_tonyu            DECIMAL       -- �����ԍ�
	--,@count               SMALLINT  OUT -- �߂�l
AS
BEGIN
	DECLARE @cd_mark varchar(2)
	DECLARE @no_han decimal

--�}�[�N�ƗL���ł��擾����
SELECT 
	@cd_mark = ma_haigo_recipe.cd_mark
	,@no_han = ma_haigo_recipe.no_han
FROM ma_haigo_recipe
WHERE 
	cd_haigo = @haigoCode
	AND no_han = (SELECT TOP 1 udf.no_han	FROM udf_HaigoRecipeYukoHan(@haigoCode, @shiyoMishiyoFlag, @seizoDay) udf	)
	AND no_kotei = @no_kotei
	AND no_tonyu = @no_tonyu

--�}�[�N�ɕR�Â������ԍ����擾����
SELECT 
	no_tonyu
FROM ma_haigo_recipe
WHERE 
	cd_haigo = @haigoCode
	AND no_han = @no_han
	AND no_kotei = @no_kotei
	AND cd_mark = @cd_mark

END
GO
