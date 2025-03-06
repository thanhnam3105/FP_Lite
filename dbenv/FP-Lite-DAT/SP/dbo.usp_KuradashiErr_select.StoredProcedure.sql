IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_KuradashiErr_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_KuradashiErr_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\		�F�ړ��o�ɉ�ʁ@�ɏo��M
�t�@�C����	�Fusp_KuradashiErr_select
���͈���	�F@dt_search,@hinKbn,@miJusin
�o�͈���	�F
�߂�l		�F
�쐬��		�F2014.11.05  ADMAX endo.y
�X�V��		�F
*****************************************************/
CREATE  PROCEDURE [dbo].[usp_KuradashiErr_select](
	@dt_search		DATETIME	--��������/�o�ɓ�
	,@hinKbn		SMALLINT	--��������/�i�敪
	,@miJusin		SMALLINT	--��M�敪.����M
	,@flg_kakutei	SMALLINT	--�m��t���O.�m��
	,@cd_niuke_basho VARCHAR(10)--��������/�׎�ꏊ
	,@cd_bunrui		VARCHAR(10)	--��������/����	
)
AS
BEGIN
	--�J���}��؂菈��		
	SELECT 
		REPLACE((
			SELECT tr_kuradashi.cd_hinmei AS [data()]
			FROM tr_kuradashi
			INNER JOIN ma_hinmei mh
				ON tr_kuradashi.cd_hinmei = mh.cd_hinmei
					AND mh.kbn_hin = @hinKbn
			WHERE kbn_status = @miJusin
				AND dt_shukko = @dt_search
				AND flg_kakutei = @flg_kakutei
				AND (( @cd_bunrui = '') OR (mh.cd_bunrui = @cd_bunrui))
				AND (( @cd_niuke_basho = '') OR (mh.cd_niuke_basho = @cd_niuke_basho))
			ORDER BY tr_kuradashi.cd_hinmei
	FOR XML PATH('')),' ',',') as cd_hinmei
END
GO
