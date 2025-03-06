IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_HaigoCheckKasaneKowake_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_HaigoCheckKasaneKowake_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\        �F�z���`�F�b�N  �d�ˏ������x���̏������сE�ܖ������`�F�b�N
�t�@�C����  �Fusp_HaigoCheckKasaneKowake_select
�쐬��      �F2015.10.23 MJ ueno.k
�X�V��      �F2016.01.18 ADMAX kakuta.y ���o���kbn_kowakehasu�ǉ�
�X�V��      �F2018.02.23 BRC kanehira.d ������������i���R�[�h���폜�@��֕i�����Ή�
*****************************************************/
CREATE PROCEDURE [dbo].[usp_HaigoCheckKasaneKowake_select]

	 @no_lot_seihin 		VARCHAR(14)		-- ���������F���i���b�g�ԍ�
	,@no_kotei 				DECIMAL(4)		-- ���������F�H���ԍ�
	,@no_tonyu				DECIMAL(4)		-- ���������F�����ԍ�
	,@dt_seizo				DATETIME		-- ���������F������
	,@su_ko		            DECIMAL(4)		-- ���������F��
	,@su_kai				DECIMAL(4)		-- ���������F��
	--,@cd_hinmei				VARCHAR(14)		-- ���������F�i���R�[�h
	,@kbn_hin				SMALLINT		-- ���������F�i�敪
	,@cd_line				VARCHAR(10)		-- ���������F���C���R�[�h
	,@kbn_seikihasu			SMALLINT		-- ���������F���K�A�[���敪	
	,@wt_haigo				DECIMAL(12,6)	-- ���������F�z���d��
	,@no_tonyu_start		DECIMAL(4)		-- ���������F�d�ˊJ�n�����ԍ�
	,@no_tonyu_end			DECIMAL(4)		-- ���������F�d�ˏI�������ԍ�
	,@kbn_kowakehasu		SMALLINT		-- ���������F���K�A�[�������敪
AS
BEGIN

SELECT
      kowake.dt_kowake
      ,kowake.cd_panel
      ,kowake.cd_hakari
      ,kowake.cd_seihin
      ,kowake.nm_seihin
      ,kowake.cd_hinmei
      ,kowake.nm_hinmei
      ,kowake.no_kotei
      ,kowake.su_ko
      ,kowake.su_kai
      ,kowake.no_tonyu
      ,kowake_wt.wt_total AS wt_haigo	--�d�˃��x��QR�R�[�h�͍��v�d�ʂɂȂ�̂ŁA�d�˓��̍��v�d�ʂ��o��
      ,kowake.wt_jisseki
      ,kowake.cd_line
      ,kowake.ritsu_kihon
      ,kowake.cd_maker
      ,kowake.cd_tanto_kowake
      ,kowake.dt_chikan
      ,kowake.cd_tanto_chikan
      ,kowake.dt_shomi
      ,kowake.dt_shomi_kaifu
      ,kowake.dt_seizo
      ,kowake.flg_kanryo_tonyu
      ,kowake.dt_tonyu
      ,kowake.no_lot_oya
      ,kowake.no_lot_seihin
      ,kowake.kbn_seikihasu
	  ,kowake.kbn_kowakehasu
      ,kowake.kbn_hin
FROM tr_kowake kowake

INNER JOIN 
(
	SELECT
		SUM(kk.wt_haigo) AS wt_total
		,kk.no_kotei
		,kk.dt_seizo
		,kk.su_ko
		,kk.su_kai
		,kk.kbn_hin
		,kk.cd_line
		,kk.kbn_seikihasu
		,kk.no_lot_seihin
	FROM
		(
			SELECT DISTINCT
				--SUM(k.wt_haigo) AS wt_total
				k.wt_haigo
				,k.no_kotei
				,k.dt_seizo
				,k.su_ko
				,k.su_kai
				,k.kbn_hin
				,k.cd_line
				,k.kbn_seikihasu
				,k.kbn_kowakehasu
				,k.no_lot_seihin
				,k.no_lot_oya
				,k.cd_hinmei
				,k.no_tonyu
			FROM tr_kowake k
			WHERE
				k.no_lot_seihin = @no_lot_seihin
				AND k.no_kotei = @no_kotei
				AND k.dt_seizo = @dt_seizo
				AND k.su_ko = @su_ko
				AND k.su_kai = @su_kai
				AND k.cd_line = @cd_line
				AND k.kbn_seikihasu = @kbn_seikihasu
				AND k.kbn_kowakehasu = @kbn_kowakehasu
				AND k.no_tonyu BETWEEN @no_tonyu_start AND @no_tonyu_end
		) kk
	GROUP BY
		kk.no_kotei
		,kk.dt_seizo
		,kk.su_ko
		,kk.su_kai
		,kk.kbn_hin
		,kk.cd_line
		,kk.kbn_seikihasu
		,kk.no_lot_seihin
) kowake_wt
ON kowake_wt.no_kotei = kowake.no_kotei
AND	kowake_wt.no_lot_seihin = kowake.no_lot_seihin
AND kowake_wt.dt_seizo = kowake.dt_seizo
AND kowake_wt.su_ko = kowake.su_ko
AND kowake_wt.su_kai = kowake.su_kai
AND kowake_wt.kbn_hin = kowake.kbn_hin
AND kowake_wt.cd_line = kowake.cd_line
AND kowake_wt.kbn_seikihasu = kowake.kbn_seikihasu
WHERE
	kowake.no_lot_seihin = @no_lot_seihin
	AND kowake.no_kotei = @no_kotei
	AND kowake.no_tonyu = @no_tonyu
	AND kowake.dt_seizo = @dt_seizo
	AND kowake.su_ko = @su_ko
	AND kowake.su_kai = @su_kai
	AND kowake.kbn_hin = @kbn_hin
	AND kowake.cd_line = @cd_line
	AND kowake.kbn_seikihasu = @kbn_seikihasu
	AND kowake.kbn_kowakehasu = @kbn_kowakehasu
	--AND kowake.cd_hinmei = @cd_hinmei
	AND kowake_wt.wt_total = @wt_haigo
ORDER BY
	kowake.dt_shomi_kaifu
	,kowake.dt_shomi ASC
END
GO
