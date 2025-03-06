IF OBJECT_ID ('dbo.vw_kojoAndKaisha_info', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_kojoAndKaisha_info]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/************************************************************
�@�\		�F��ЂƍH��}�X�^���擾�p�r���[
�r���[��	�Fvw_kojoAndKaisha_info
���͈���	�F
���l		�F
�쐬��		�F2018.02.05 BRC kanehira
�X�V��		�F
************************************************************/
CREATE VIEW [dbo].[vw_kojoAndKaisha_info] AS
--TODO ����ł̓��O�C�����[�U�[�Ɖ�Ѓ}�X�^�A�H��}�X�^���R�Â��Ȃ����߉�Ѓ}�X�^�ƍH��}�X�^�̂ݕR�Â���
--�H����Ђ̓o�^��������������C����K�v����
SELECT
kaisha.cd_kaisha
,kojo.cd_kojo
,kojo.su_keta_shosuten
FROM ma_kojo kojo
INNER JOIN ma_kaisha kaisha
ON kaisha.cd_kaisha = kojo.cd_kaisha
--TODO END
GO