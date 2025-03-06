IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_LabelHarikaeSentaku_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_LabelHarikaeSentaku_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\		�F���x���\��ւ�
�t�@�C����	�Fusp_LabelHarikaeSentaku_select
���͈���	�F@cd_seihin, @cd_hinmei, @su_ko, @su_kai
              , @no_tonyu_min, @no_tonyu_max, @cd_line
              , @no_kotei, @no_lot_seihin, @dt_seizo ,@flg_mishiyo
              , @kbn_kowakehasu, @ritsu_kihon
�o�͈���	�F
�߂�l		�F
�쐬��		�F2013.10.04  ADMAX okuda.k
�X�V��		�F2016.01.14  ADMAX shibao.s
�X�V��		�F2016.08.18  BRC   motojima.m LB�Ή�
�X�V��		�F2017.04.26  BRC   kanehira.d Q&B�T�|�[�g�Ή�No.56
�X�V��		�F2018.03.15  BRC   kanehira.d Q&B�����V�X�e������ �𓀌�ܖ������̎擾
�X�V��		�F2018.07.23  BRC   takagi.r ��ƈ˗�No.151 �J����ܖ�����,�����ޏܖ������Ń��R�[�h���\�[�g
*****************************************************/
CREATE PROCEDURE [dbo].[usp_LabelHarikaeSentaku_select]
(
	@cd_seihin		VARCHAR(14)
	,@cd_hinmei		VARCHAR(14)
	,@su_ko			NUMERIC(4, 0)  --��
	,@su_kai		NUMERIC(4, 0)  --��
	,@no_tonyu_min	NUMERIC(4)     --�����ԍ�
	,@no_tonyu_max	NUMERIC(4)     --�����ԍ�
	,@cd_line		VARCHAR(10)
	,@no_kotei		NUMERIC(4)     --�H���ԍ�
	,@no_lot_seihin	VARCHAR(14)
	,@dt_seizo		DATETIME       --���t
	,@flg_mishiyo	NUMERIC(1)
	,@wt_haigo		DECIMAL(12,6)  --�z���d��
	,@kbn_seikihasu	SMALLINT       --���K�A�[���敪
	,@kbn_kowakehasu SMALLINT      --�[���t���O
	,@kbn_hin		SMALLINT	   --�i�敪
	,@ritsu_kihon   DECIMAL(5,2)   --��{�{��
)
AS
BEGIN
	SELECT 
		tk.dt_kowake
		,tk.cd_hinmei
		,tk.nm_hinmei
		,tk.nm_seihin
		,tk.wt_haigo
		,tk.wt_jisseki
		,tani.nm_tani
		,tl.no_lot
		,tk.dt_shomi
		,tk.dt_shomi_kaifu
		,tk.dt_shomi_kaito
		,tk.su_kai
		,tk.su_ko
		,tk.no_tonyu
		,tk.cd_line
		,ISNULL(mt.nm_tanto, '') AS nm_tanto
		,tk.dt_seizo
		,tk.no_kotei
	FROM tr_kowake tk
		LEFT OUTER JOIN tr_lot tl
		ON tk.no_lot_kowake = tl.no_lot_jisseki
		LEFT OUTER JOIN ma_tanto mt
		ON tk.cd_tanto_kowake = mt.cd_tanto
		AND mt.flg_mishiyo = @flg_mishiyo
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
		AND tk.cd_seihin = @cd_seihin
		AND tk.cd_hinmei = @cd_hinmei
		AND tk.su_ko = @su_ko
		AND tk.su_kai = @su_kai
		AND tk.no_tonyu BETWEEN @no_tonyu_min AND @no_tonyu_max
		AND tk.cd_line = @cd_line
		AND tk.no_kotei = @no_kotei
		AND (tk.no_lot_seihin = @no_lot_seihin
		OR tk.no_lot_seihin IS NULL)
		AND tk.wt_haigo = @wt_haigo
		AND tk.kbn_seikihasu = @kbn_seikihasu
		AND tk.kbn_kowakehasu = @kbn_kowakehasu
		AND tk.kbn_hin = @kbn_hin
		AND (tk.ritsu_kihon IS NULL 
				OR tk.ritsu_kihon = @ritsu_kihon)
	ORDER BY tk.dt_shomi_kaifu,tk.dt_shomi
END
GO
