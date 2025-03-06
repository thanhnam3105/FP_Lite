IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_KasaneLabelShogo_select_03') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_KasaneLabelShogo_select_03]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\		�F�d�˃��x���ƍ� ����03
�t�@�C����	�Fusp_KasaneLabelShogo_select03
���͈���	�F@dt_seizo, @cd_haigo, @no_tonyu
              , @no_kotei ,@cd_line ,@cd_hinmei 
              , @su_kai ,@no_lot_seihin ,@flg_mishiyo
              , @ritsu_kihon
�o�͈���	�F
�߂�l		�F������[0] ���s��[0�ȊO�̃G���[�R�[�h]
�쐬��		�F2013.11.06  ADMAX okuda.k
�X�V��		�F2014.02.20  ADMAX kunii.h
�X�V��		�F2016.08.05  BRC   motojima.m  LB�Ή�
�X�V��		�F2017.04.26  BRC   kanehira.d  Q&B�T�|�[�g�Ή�No.56�@		�@
*****************************************************/
CREATE PROCEDURE [dbo].[usp_KasaneLabelShogo_select_03]
(
	@dt_seizo		DATETIME      --������
	,@cd_haigo		VARCHAR(14)   --�z���R�[�h
	,@no_tonyu		DECIMAL(4,0)  --�����ԍ�
	,@no_kotei		DECIMAL(4,0)  --�H���ԍ�
	,@cd_line		VARCHAR(10)   --���C���R�[�h
	,@cd_hinmei		VARCHAR(14)   --�i���R�[�h
	,@su_kai		DECIMAL(4,0)  --��
	,@no_lot_seihin	VARCHAR(14)   --���i���b�g�ԍ�
	,@flg_mishiyo	SMALLINT      --���g�p�t���O
	,@su_ko			DECIMAL(4,0)  --��
	,@kbn_seikihasu	SMALLINT      --���K�A�[���敪
	,@kbn_kowakehasu SMALLINT     --�[���t���O
	,@ritsu_kihon   DECIMAL(5,3)  --��{�{��
)
AS
BEGIN
	SELECT
		tk.dt_kowake
	    ,tk.cd_hinmei
	    ,tk.nm_hinmei
	    ,tk.nm_seihin
	    ,tk.wt_haigo
	    ,SUM(tk.wt_jisseki) AS wt_jisseki
	    ,tani.nm_tani
	    ,tk.su_kai
	    ,tk.su_ko
	    ,tk.no_tonyu
	    ,ISNULL(tanto_hyoryo.nm_tanto, '') AS hyoryoSya
	    ,tk.dt_chikan
	    ,tanto_chikan.nm_tanto chikanSya
	    ,tk.kbn_seikihasu
		,hinKbnMa.kbn_hin
		,hinKbnMa.nm_kbn_hin
	FROM tr_kowake tk
	LEFT OUTER JOIN ma_tanto tanto_hyoryo
	ON tk.cd_tanto_kowake  = tanto_hyoryo.cd_tanto
	AND tanto_hyoryo.flg_mishiyo = @flg_mishiyo
	LEFT OUTER JOIN ma_tanto tanto_chikan
	ON tk.cd_tanto_chikan = tanto_chikan.cd_tanto
	AND tanto_chikan.flg_mishiyo = @flg_mishiyo
	LEFT OUTER JOIN ma_kbn_hin hinKbnMa
	ON tk.kbn_hin = hinKbnMa.kbn_hin
	LEFT OUTER JOIN  ma_hakari hakari
	ON tk.cd_hakari = hakari.cd_hakari
	LEFT OUTER JOIN ma_tani tani
	ON hakari.cd_tani = tani.cd_tani
	WHERE
		@dt_seizo <= tk.dt_seizo
		AND tk.dt_seizo <
			(
				SELECT DATEADD(DD,1,@dt_seizo)
			)
		AND tk.cd_seihin = @cd_haigo
		AND tk.su_kai = @su_kai
		AND tk.no_tonyu = @no_tonyu
		AND tk.cd_line = @cd_line
		AND tk.no_kotei = @no_kotei
		AND tk.cd_hinmei = @cd_hinmei
		AND (tk.no_lot_seihin = @no_lot_seihin 
		OR tk.no_lot_seihin is NULL)
		AND tk.su_ko = @su_ko
		AND tk.kbn_seikihasu = @kbn_seikihasu
		AND tk.kbn_kowakehasu = @kbn_kowakehasu
		AND (tk.ritsu_kihon IS NULL
				OR tk.ritsu_kihon = @ritsu_kihon)
	GROUP BY
	    tk.dt_kowake
	    , tk.cd_hinmei
	    , tk.nm_hinmei
	    , tk.nm_seihin
	    , tk.wt_haigo
	    ,tani.nm_tani
	    , tk.su_kai
	    , tk.su_ko
	    , tk.no_tonyu
	    , tanto_hyoryo.nm_tanto
	    , tk.dt_chikan
	    , tanto_chikan.nm_tanto
	    , tk.kbn_seikihasu
		, hinKbnMa.kbn_hin
		, hinKbnMa.nm_kbn_hin
	ORDER BY 
	    tk.dt_kowake 
END
GO
