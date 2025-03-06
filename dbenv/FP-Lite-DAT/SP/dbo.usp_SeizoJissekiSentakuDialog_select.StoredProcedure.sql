DROP PROCEDURE [dbo].[usp_SeizoJissekiSentakuDialog_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/**********************************************************************
�@�\�F�������ёI���_�C�A���O��ʁ@��������
�t�@�C�����Fusp_SeizoJissekiSentakuDialog_select
�쐬���F2015.07.01 tsujita.s
�X�V���F2016.01.16 yokota
		2020.01.23 wang     --�����\�萔�܂��������ѐ���0�̂Ƃ��A�擾���Ȃ��B
**********************************************************************/
CREATE PROCEDURE [dbo].[usp_SeizoJissekiSentakuDialog_select]
    @dt_from datetime			-- ���������F�J�n��
    ,@dt_to datetime			-- ���������F�I����
	,@cd_haigo varchar(14)		-- ���������F�d�|�i�R�[�h
    ,@flg_kakutei smallint		-- �Œ�l�F�m��t���O�F�m��
    ,@flg_shiyo smallint		-- �Œ�l�F���g�p�t���O�F�g�p
AS
BEGIN

	SELECT
		seihin.cd_hinmei
		,hin.kbn_hin
		,kbn.nm_kbn_hin
		,hin.nm_hinmei_ja
		,hin.nm_hinmei_en
		,hin.nm_hinmei_zh
		,hin.nm_hinmei_vi
		,seihin.dt_seizo
		,seihin.su_seizo
		,seihin.no_lot_seihin
		,hin.flg_testitem
	FROM (
		SELECT
			cd_hinmei
			,dt_seizo
			,COALESCE(su_seizo_jisseki, 0) AS su_seizo
			,no_lot_seihin
			,flg_jisseki
		FROM
			tr_keikaku_seihin
		WHERE
			flg_jisseki = @flg_kakutei
		AND dt_seizo BETWEEN @dt_from AND @dt_to
		AND su_seizo_jisseki <> 0

		UNION ALL

		SELECT
			cd_hinmei
			,dt_seizo
			,COALESCE(su_seizo_yotei, 0) AS su_seizo
			,no_lot_seihin
			,flg_jisseki
		FROM
			tr_keikaku_seihin
		WHERE
			flg_jisseki <> @flg_kakutei
		AND dt_seizo BETWEEN @dt_from AND @dt_to
		AND su_seizo_yotei <> 0
	) seihin
	
	INNER JOIN ma_hinmei hin
	ON seihin.cd_hinmei = hin.cd_hinmei
	AND hin.cd_haigo = @cd_haigo

	LEFT JOIN ma_kbn_hin kbn
	ON hin.kbn_hin = kbn.kbn_hin

	ORDER BY
		seihin.dt_seizo, hin.kbn_hin, seihin.cd_hinmei

END



GO
