IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_HaigoCheck_update') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_HaigoCheck_update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\		�F�������уg���� �X�V
�t�@�C����	�Fusp_Kakozan_update
���͈���	�F@cd_seihin,@cd_hinmei,@no_lot_seihin
			  ,@su_kai,@su_ko,@wt_haigo
�o�͈���	�F
�߂�l		�F
�쐬��		�F2013.10.21  ADMAX endo.y
�X�V��		�F2015.08.10  ADMAX kakuta.y WHERE��ɕi�敪��ǉ�
*****************************************************/
CREATE PROCEDURE [dbo].[usp_HaigoCheck_update] 
	@cd_seihin				VARCHAR(14)		-- �z���R�[�h
	,@cd_hinmei				VARCHAR(14)		-- �����R�[�h
	,@no_lot_seihin			VARCHAR(14)		-- ���i���b�g�ԍ�
	,@su_kai				DECIMAL(4,0)	-- ��
	,@su_ko					DECIMAL(4,0)	-- ��
	,@wt_haigo				DECIMAL(12,6)	-- �z���d��
	,@dt_shori				DATETIME		-- ��������
	,@flg_kanryo_tonyu		SMALLINT		-- ���������t���O
	,@kbn_seikihasu			SMALLINT		-- ���K�A�[���敪
	,@kbn_kowakehasu		SMALLINT		-- �������K�A�[���敪
	,@no_tonyu				DECIMAL(4,0)	-- ������
	,@no_kotei				DECIMAL(4,0)	-- �H��
	,@kbn_hin				SMALLINT		-- �i�敪
AS
BEGIN
	UPDATE tr_kowake
	SET dt_tonyu = @dt_shori
		,flg_kanryo_tonyu = @flg_kanryo_tonyu
	WHERE cd_seihin = @cd_seihin
	AND cd_hinmei = @cd_hinmei
	AND no_lot_seihin = @no_lot_seihin
	AND su_kai = @su_kai
	AND su_ko = @su_ko
	AND no_kotei = @no_kotei
	AND wt_haigo = @wt_haigo
	AND kbn_seikihasu = @kbn_seikihasu
	AND kbn_kowakehasu = @kbn_kowakehasu
	AND no_tonyu = @no_tonyu
	AND kbn_hin = @kbn_hin
END
GO
