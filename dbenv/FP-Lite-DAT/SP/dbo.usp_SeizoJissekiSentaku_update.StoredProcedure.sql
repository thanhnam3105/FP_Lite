IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_SeizoJissekiSentaku_update') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_SeizoJissekiSentaku_update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,tsujita.s>
-- Create date: <Create Date,,2015.06.29>
-- Last Update: 2015.07.13 tsujita.s
-- Description:	�������ёI���̈ꊇ�X�V����
-- =============================================
CREATE PROCEDURE [dbo].[usp_SeizoJissekiSentaku_update]
	@no_lot_shikakari		AS VARCHAR(14)	-- �d�|�i���b�g�ԍ�
	,@kbn_jotai_denso		AS SMALLINT		-- �Œ�l�F�`����ԋ敪�F���`��
	,@misakuseiDensoKubun	AS SMALLINT		-- �Œ�l�F�`����ԋ敪�F���쐬
AS
BEGIN

	-- �֘A�f�[�^�̓`����ԋ敪�𖢓`���Ɉꊇ�X�V
	UPDATE tr_sap_shiyo_yojitsu_anbun
	SET kbn_jotai_denso = @kbn_jotai_denso
	WHERE
		no_lot_shikakari = @no_lot_shikakari
		AND kbn_jotai_denso = @misakuseiDensoKubun
END
GO
