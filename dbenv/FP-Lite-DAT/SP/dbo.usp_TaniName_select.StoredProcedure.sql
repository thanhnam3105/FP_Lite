IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_TaniName_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_TaniName_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\		�F�P�ʖ��擾
�t�@�C����	�Fusp_TaniName_select
���͈���	�F@cd_panel, @cd_shokuba, @flg_hakari, @flg_kinshi, @flg_mishiyo, @kbn_kino, @tani_LB, @tani_KG
�o�͈���	�F
�߂�l		�F
�쐬��		�F2016.07.21  BRC motojima.m
�X�V��		�F
*****************************************************/
CREATE PROCEDURE [dbo].[usp_TaniName_select]
(
	@cd_panel			AS VARCHAR(3)		-- �p�l���R�[�h
	,@cd_shokuba		AS VARCHAR(10)		-- �E��R�[�h
	,@flg_hakari		AS SMALLINT			-- �萔�F�g�p�ۃt���O�F�g�p��
	,@flg_kinshi		AS SMALLINT			-- �萔�F�֎~�t���O�F����
	,@flg_mishiyo		AS SMALLINT			-- �萔�F���g�p�t���O�F�g�p
	,@kbn_kino			AS SMALLINT			-- �@�\�敪�F�P�ʋ敪
	,@tani_LB			AS VARCHAR(2)		-- �Œ�F�P�ʖ��FLB
	,@tani_KG			AS VARCHAR(2)		-- �Œ�F�P�ʖ��FKg
)
AS 
BEGIN
	SELECT
		tani.nm_tani AS hakariTaniName
		,CASE WHEN kino.kbn_kino_naiyo = 1 THEN @tani_LB ELSE @tani_KG END AS taniName
	FROM
		ma_panel panel
		LEFT JOIN ma_hakari hakari ON
			panel.cd_hakari_1 = hakari.cd_hakari
			AND hakari.flg_mishiyo = @flg_mishiyo
		LEFT JOIN ma_shokuba shokuba ON
			panel.cd_shokuba = shokuba.cd_shokuba
			AND shokuba.flg_mishiyo = @flg_mishiyo
		LEFT JOIN ma_tani tani ON
			hakari.cd_tani = tani.cd_tani
			AND tani.flg_kinshi = @flg_kinshi
			AND tani.flg_mishiyo = @flg_mishiyo
		LEFT JOIN cn_kino_sentaku kino ON
			kino.kbn_kino = @kbn_kino
	WHERE
		panel.cd_panel = @cd_panel
		AND panel.cd_shokuba = @cd_shokuba
		AND panel.flg_hakari_1 = @flg_hakari
		AND panel.flg_mishiyo = @flg_mishiyo
END
GO
