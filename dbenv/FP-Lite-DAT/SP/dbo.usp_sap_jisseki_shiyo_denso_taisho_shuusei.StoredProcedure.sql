IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_sap_jisseki_shiyo_denso_taisho_shuusei') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_sap_jisseki_shiyo_denso_taisho_shuusei]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\		�F�g�p���ё��M�Ώۃe�[�u���덷�C������
�t�@�C����	�Fusp_sap_jisseki_shiyo_denso_taisho_shuusei
���͈���	�F
�o�͈���	�F
�߂�l		�F������[0] ���s��[0�ȊO�̃G���[�R�[�h]
�쐬��		�F2015.07.13 kaneko.m
�X�V��		�F2018.12.12 BRC.kanehira �덷��t�^����f�[�^�擾�̏����i���я��j���C��
*****************************************************/
CREATE PROCEDURE [dbo].[usp_sap_jisseki_shiyo_denso_taisho_shuusei] 
AS
BEGIN

	-- �ꎞ�e�[�u���쐬
	CREATE TABLE #tmp_anbun
	(
		[no_seq] [varchar](14) NOT NULL
		,[no_lot_shikakari] [varchar](14) NOT NULL
		,[kbn_shiyo_jisseki_anbun] [varchar](10) NOT NULL
		,[no_lot_seihin] [varchar](14) NULL
		,[dt_shiyo_shikakari] [datetime] NULL
		,[su_shiyo_shikakari] [decimal](12, 6) NOT NULL
		,[kbn_jotai_denso] [smallint] NOT NULL
		,[wt_shikomi_jisseki] [decimal](12, 6) NOT NULL
		,[cd_hinmei] [varchar](14) NOT NULL
		,[dt_shiyo] [datetime] NOT NULL
		,[su_shiyo] [decimal](12, 6) NOT NULL
	)
	
	CREATE NONCLUSTERED INDEX idx_anbun1 ON #tmp_anbun (no_seq)

	CREATE TABLE #tmp_diff
	(
		[no_lot_shikakari] [varchar](14) NOT NULL
		,[cd_hinmei] [varchar](14) NOT NULL
		,[su_shiyo_sum] [decimal](12, 6) NOT NULL
		,[su_shiyo] [decimal](12, 6) NOT NULL
		,[diff] [decimal](12, 6) NULL
	)
	
	CREATE TABLE #tmp_taisho
	(
		[no_lot_seihin] [varchar](14) NULL
		,[no_lot_shikakari] [varchar](14) NULL
		,[dt_shiyo] [datetime] NULL
		,[cd_hinmei] [varchar](14) NULL
		,[su_shiyo] [decimal](12, 6) NULL
	)
	
	DECLARE @msg VARCHAR(500)		-- �������ʃ��b�Z�[�W�i�[�p
	DECLARE @dt_taisho DATETIME

	--SET @dt_taisho = DATEADD(DD, -60, GETDATE())
	SET @dt_taisho = DATEADD(DD, -60, GETUTCDATE())

	-- �ĕ����擾
	INSERT INTO #tmp_anbun
	SELECT
		anbun.no_seq
		, anbun.no_lot_shikakari
		, anbun.kbn_shiyo_jisseki_anbun
		, anbun.no_lot_seihin
		, anbun.dt_shiyo_shikakari
		, anbun.su_shiyo_shikakari
		, anbun.kbn_jotai_denso
		, shikakari.wt_shikomi_jisseki
		, shiyo.cd_hinmei
		, shiyo.dt_shiyo
		, CEILING(shiyo.su_shiyo * (anbun.su_shiyo_shikakari / shikakari.wt_shikomi_jisseki) * 1000) / 1000 AS su_shiyo
	FROM tr_sap_shiyo_yojitsu_anbun anbun
	INNER JOIN (
		SELECT DISTINCT no_lot_shikakari 
		FROM tr_sap_shiyo_yojitsu_anbun
		WHERE dt_shiyo_shikakari >= @dt_taisho
	) taisho
	  ON taisho.no_lot_shikakari = anbun.no_lot_shikakari
	INNER JOIN su_keikaku_shikakari shikakari
	  ON shikakari.no_lot_shikakari = anbun.no_lot_shikakari
	INNER JOIN (
		SELECT
			no_lot_shikakari
			, dt_shiyo
			, cd_hinmei
			, SUM(su_shiyo) AS su_shiyo
		FROM tr_shiyo_yojitsu
		WHERE flg_yojitsu = 1
		GROUP BY no_lot_shikakari,dt_shiyo, cd_hinmei
	  ) shiyo
	  ON shiyo.no_lot_shikakari = anbun.no_lot_shikakari

	-- �ꎞ�ĕ��g�����Ǝg�p���тƂ̍����i�d�|�i���b�g�E�i���R�[�h�P�ʁj
	INSERT INTO #tmp_diff
	SELECT
		*
	FROM (
		SELECT
			summary.no_lot_shikakari
			, summary.cd_hinmei
			, summary.su_shiyo AS su_shiyo_sum
			, shiyo.su_shiyo
			, summary.su_shiyo - shiyo.su_shiyo AS diff
		FROM (
			SELECT
				no_lot_shikakari
				, cd_hinmei
				, SUM(su_shiyo) AS su_shiyo
			FROM #tmp_anbun
			GROUP BY no_lot_shikakari, cd_hinmei
		) summary
		INNER JOIN (
			SELECT
				no_lot_shikakari
				, cd_hinmei
				, CEILING(SUM(su_shiyo) * 1000) / 1000 AS su_shiyo
			FROM tr_shiyo_yojitsu
			WHERE flg_yojitsu = 1
			  AND no_lot_shikakari IS NOT NULL
			GROUP BY no_lot_shikakari,cd_hinmei
			) shiyo
		ON shiyo.no_lot_shikakari = summary.no_lot_shikakari
		AND shiyo.cd_hinmei = summary.cd_hinmei
	) foo
	WHERE su_shiyo <> su_shiyo_sum

	-- �d�|�i���b�g�A�i���R�[�h���Ƃɒ����Ώۂ̂P����I��
	-- �ĕ�����o�����f�[�^-�ĕ��Ǝg�p���т̍���
	-- �덷�C����̈ĕ��f�[�^
	INSERT INTO #tmp_taisho
	SELECT
		foo.no_lot_seihin
		, foo.no_lot_shikakari
		, foo.dt_shiyo
		, foo.cd_hinmei
		, foo.su_shiyo - ISNULL(diff.diff, 0) AS su_shiyo
	FROM (
		SELECT
			*
			--, ROW_NUMBER() OVER(PARTITION BY no_lot_shikakari, cd_hinmei ORDER BY su_shiyo_shikakari DESC) AS RN
			, ROW_NUMBER() OVER(PARTITION BY no_lot_shikakari, cd_hinmei ORDER BY su_shiyo_shikakari DESC, no_lot_seihin DESC) AS RN
		FROM #tmp_anbun
		WHERE no_lot_seihin IS NOT NULL
		) foo
	LEFT OUTER JOIN #tmp_diff diff
	  ON foo.RN = 1
	  AND diff.no_lot_shikakari = foo.no_lot_shikakari
	  AND diff.cd_hinmei = foo.cd_hinmei
	  
	  
	-- �Ώۃg�������X�V
	UPDATE tr_sap_jisseki_shiyo_denso_taisho
	SET su_shiyo = tmp.su_shiyo
	FROM tr_sap_jisseki_shiyo_denso_taisho taisho
	INNER JOIN (
		SELECT
			no_lot_seihin
			, dt_shiyo
			, cd_hinmei
			, CEILING(SUM(su_shiyo) * 1000) / 1000 AS su_shiyo 
		FROM #tmp_taisho
		GROUP BY no_lot_seihin, dt_shiyo, cd_hinmei
	) tmp
	  ON tmp.no_lot_seihin = taisho.no_lot_seihin
	  AND tmp.dt_shiyo = taisho.dt_shiyo
	  AND tmp.cd_hinmei = taisho.cd_hinmei
	WHERE taisho.su_shiyo <> tmp.su_shiyo
	
	-- �ꎞ�e�[�u���̍폜
	DROP TABLE #tmp_anbun
	DROP TABLE #tmp_diff
	DROP TABLE #tmp_taisho

	RETURN

	-- //////////// --
	--  �G���[����
	-- //////////// --
	Error_Handling:
		CLOSE cursor_denso
		DEALLOCATE cursor_denso
		PRINT @msg

		RETURN

END