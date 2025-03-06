IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_NonyuIraishoListPdf_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_NonyuIraishoListPdf_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===============================================
-- Author:		tsujita.s
-- Create date: 2013.09.11
-- Last Update: 2015.02.19 tsujita.s
-- Description:	�[���˗������X�g
--    PDF�p�f�[�^���o����
-- ===============================================
CREATE PROCEDURE [dbo].[usp_NonyuIraishoListPdf_select]
	@hizuke_from			datetime		-- ���t�F�n�_
	,@hizuke_to				datetime		-- ���t�F�I�_
	,@today					datetime		-- UTC���Ԃŕϊ��ς݃V�X�e�����t
	,@yotei_nashi			smallint		-- �\��Ȃ����o�́F1
	,@flg_yotei				smallint		-- �萔�F�\���t���O�F�\��
	,@flg_jisseki			smallint		-- �萔�F�\���t���O�F����
	,@flg_mishiyo			smallint		-- �萔�F���g�p�t���O�F�g�p
	,@param_torihiki		varchar(1000)	-- ���������F�I�����ꂽ�����R�[�h
	,@param_hin				varchar(1000)	-- ���������F�I�����ꂽ�i���R�[�h
	,@tani_kg				varchar(2)		-- �萔�F�P�ʃR�[�h�FKg
	,@tani_li				varchar(2)		-- �萔�F�P�ʃR�[�h�FL
AS
BEGIN

	SET NOCOUNT ON

	-- ========================================================
	-- ========================================================
	--   �S�������
	-- ========================================================
	-- ========================================================
	IF @param_torihiki = ''
	BEGIN
		-- �� �[���g�������{�[�����[�N�̏����擾
		SELECT
		 CALENDAR.dt_hizuke AS dt_hizuke
		 ,NONYU.cd_hinmei AS cd_hinmei

		 --,floor(NONYU.su_nonyu) AS su_nonyu
		 -- �[���P�ʂ�Kg�܂���L�̏ꍇ�́A�[���𐳋K���ɉ��Z����
		 ,dbo.udf_NonyuHasuKanzan(
			ma_ko.cd_tani_nonyu, ma_hin.cd_tani_nonyu,
			NONYU.su_nonyu, NONYU.su_nonyu_hasu, @tani_kg, @tani_li) AS su_nonyu

		 ,COALESCE(WORK.su_nonyu, 0) AS su_nonyu_wo
		 ,COALESCE(NONYU.cd_torihiki, '') AS cd_torihiki
		 ,COALESCE(ma_hin.cd_niuke_basho, '') AS cd_niuke_basho
		 ,COALESCE(ma_hin.nm_hinmei_ja, '') AS nm_hinmei_ja
		 ,COALESCE(ma_hin.nm_hinmei_en, '') AS nm_hinmei_en
		 ,COALESCE(ma_hin.nm_hinmei_zh, '') AS nm_hinmei_zh
		 ,COALESCE(ma_hin.nm_hinmei_vi, '') AS nm_hinmei_vi
		 ,ma_hin.cd_bunrui AS cd_bunrui
		 ,ma_bun.nm_bunrui AS nm_bunrui
		 ,ma_tan_nonyu.nm_tani AS nonyu_tani
		 ,ma_tan_shiyo.nm_tani AS shiyo_tani
		 ,ma_ko.nm_nisugata_hyoji AS nm_nisugata_hyoji
		 -- �d��
		 --,COALESCE(ma_ko.wt_nonyu, 0) * COALESCE(ma_ko.su_iri, 0)
		 --	* floor(NONYU.su_nonyu) AS juryo
		 ,COALESCE(ma_ko.wt_nonyu, 0) * COALESCE(ma_ko.su_iri, 0)
			* dbo.udf_NonyuHasuKanzan(
				ma_ko.cd_tani_nonyu, ma_hin.cd_tani_nonyu,
				NONYU.su_nonyu, NONYU.su_nonyu_hasu, @tani_kg, @tani_li) AS juryo
		FROM
		-- �J�����_�[�}�X�^
		(SELECT dt_hizuke
				,flg_kyujitsu
		 FROM ma_calendar
		 WHERE dt_hizuke >= @hizuke_from
		 AND dt_hizuke < @hizuke_to
		) CALENDAR

		-- �[���g����
		LEFT JOIN (SELECT cd_hinmei AS cd_hinmei
				,dt_nonyu AS dt_nonyu
				,SUM(su_nonyu) AS su_nonyu
				,cd_torihiki AS cd_torihiki
				,SUM(su_nonyu_hasu) AS su_nonyu_hasu
			FROM tr_nonyu
			WHERE dt_nonyu >= @hizuke_from
			AND dt_nonyu < @hizuke_to
			AND (
				(dt_nonyu < @today AND flg_yojitsu = @flg_jisseki)
				OR
				(dt_nonyu >= @today AND flg_yojitsu = @flg_yotei)
			)
			GROUP BY cd_hinmei, dt_nonyu, cd_torihiki
		) NONYU
		ON NONYU.dt_nonyu = CALENDAR.dt_hizuke

		-- �[�����[�N�g����
		LEFT JOIN (SELECT cd_hinmei AS cd_hinmei
				,dt_nonyu AS dt_nonyu
				,su_nonyu AS su_nonyu
				,cd_torihiki AS cd_torihiki
			FROM wk_nonyu
			WHERE dt_nonyu >= @hizuke_from
			AND dt_nonyu < @hizuke_to
		) WORK
		ON WORK.dt_nonyu = CALENDAR.dt_hizuke
		AND WORK.cd_hinmei = NONYU.cd_hinmei

		-- �i���}�X�^
		LEFT JOIN ma_hinmei ma_hin
		ON ma_hin.cd_hinmei = NONYU.cd_hinmei

		-- �����ލw����}�X�^
		LEFT JOIN ma_konyu ma_ko
		ON ma_ko.cd_hinmei = NONYU.cd_hinmei
		AND ma_ko.cd_torihiki = NONYU.cd_torihiki

		-- �P�ʃ}�X�^�F�[���P��
		LEFT JOIN ma_tani ma_tan_nonyu
		ON ma_tan_nonyu.cd_tani = ma_ko.cd_tani_nonyu

		-- �P�ʃ}�X�^�F�g�p�P��
		LEFT JOIN ma_tani ma_tan_shiyo
		ON ma_tan_shiyo.cd_tani = ma_hin.cd_tani_shiyo

		-- ���ރ}�X�^
		LEFT JOIN ma_bunrui ma_bun
		ON ma_bun.cd_bunrui = ma_hin.cd_bunrui
		AND ma_bun.kbn_hin = ma_hin.kbn_hin

		WHERE
			NONYU.su_nonyu > 0 OR NONYU.su_nonyu_hasu > 0 OR WORK.su_nonyu > 0
			
	UNION
			
		-- �� �[�����[�N�ɂ������݂��Ȃ������擾
		SELECT
		 CALENDAR.dt_hizuke AS dt_hizuke
		 ,WORK.cd_hinmei AS cd_hinmei

		 --,COALESCE(NONYU.su_nonyu, 0) AS su_nonyu
		 -- �[���P�ʂ�Kg�܂���L�̏ꍇ�́A�[���𐳋K���ɉ��Z����
		 ,dbo.udf_NonyuHasuKanzan(
			wo_ko.cd_tani_nonyu, wo_hin.cd_tani_nonyu,
			NONYU.su_nonyu, NONYU.su_nonyu_hasu, @tani_kg, @tani_li) AS su_nonyu

		 ,COALESCE(WORK.su_nonyu, 0) AS su_nonyu_wo
		 ,COALESCE(WORK.cd_torihiki, '') AS cd_torihiki
		 ,COALESCE(wo_hin.cd_niuke_basho, '') AS cd_niuke_basho
		 ,COALESCE(wo_hin.nm_hinmei_ja, '') AS nm_hinmei_ja
		 ,COALESCE(wo_hin.nm_hinmei_en, '') AS nm_hinmei_en
		 ,COALESCE(wo_hin.nm_hinmei_zh, '') AS nm_hinmei_zh
		 ,COALESCE(wo_hin.nm_hinmei_vi, '') AS nm_hinmei_vi
		 ,wo_bun.cd_bunrui AS cd_bunrui
		 ,wo_bun.nm_bunrui AS nm_bunrui
		 ,wo_tan_nonyu.nm_tani AS nonyu_tani
		 ,wo_tan_shiyo.nm_tani AS shiyo_tani
		 ,wo_ko.nm_nisugata_hyoji AS nm_nisugata_hyoji
		 ,0 AS juryo
		FROM
		-- �J�����_�[�}�X�^
		(SELECT dt_hizuke
				,flg_kyujitsu
		 FROM ma_calendar
		 WHERE dt_hizuke >= @hizuke_from
		 AND dt_hizuke < @hizuke_to
		) CALENDAR

		-- �[�����[�N�g����
		LEFT JOIN (SELECT cd_hinmei AS cd_hinmei
				,dt_nonyu AS dt_nonyu
				,su_nonyu AS su_nonyu
				,cd_torihiki AS cd_torihiki
			FROM wk_nonyu
			WHERE dt_nonyu >= @hizuke_from
			AND dt_nonyu < @hizuke_to
		) WORK
		ON WORK.dt_nonyu = CALENDAR.dt_hizuke

		-- �[���g����
		LEFT JOIN (SELECT cd_hinmei AS cd_hinmei
				,dt_nonyu AS dt_nonyu
				,SUM(su_nonyu) AS su_nonyu
				--,SUM(su_nonyu) + SUM(su_nonyu_hasu) AS su_nonyu
				,SUM(su_nonyu_hasu) AS su_nonyu_hasu
				,cd_torihiki AS cd_torihiki
			FROM tr_nonyu
			WHERE dt_nonyu >= @hizuke_from
			AND dt_nonyu < @hizuke_to
			AND (
				(dt_nonyu < @today AND flg_yojitsu = @flg_jisseki)
				OR
				(dt_nonyu >= @today AND flg_yojitsu = @flg_yotei)
			)
			GROUP BY cd_hinmei, dt_nonyu, cd_torihiki
		) NONYU
		ON NONYU.dt_nonyu = CALENDAR.dt_hizuke
		AND NONYU.cd_hinmei = WORK.cd_hinmei

		-- �i���}�X�^
		LEFT JOIN ma_hinmei wo_hin
		ON wo_hin.cd_hinmei = WORK.cd_hinmei

		-- �����ލw����}�X�^
		LEFT JOIN ma_konyu wo_ko
		ON wo_ko.cd_hinmei = WORK.cd_hinmei
		AND wo_ko.cd_torihiki = WORK.cd_torihiki

		-- �P�ʃ}�X�^�F�[���P��
		LEFT JOIN ma_tani wo_tan_nonyu
		ON wo_tan_nonyu.cd_tani = wo_ko.cd_tani_nonyu

		-- �P�ʃ}�X�^�F�g�p�P��
		LEFT JOIN ma_tani wo_tan_shiyo
		ON wo_tan_shiyo.cd_tani = wo_hin.cd_tani_shiyo

		-- ���ރ}�X�^
		LEFT JOIN ma_bunrui wo_bun
		ON wo_bun.cd_bunrui = wo_hin.cd_bunrui
		AND wo_bun.kbn_hin = wo_hin.kbn_hin
			
		WHERE (NONYU.su_nonyu > 0 OR NONYU.su_nonyu_hasu > 0 OR WORK.su_nonyu > 0)
		AND NONYU.cd_hinmei IS NULL
	END

	-- ========================================================
	-- ========================================================
	--  �u�\��Ȃ��̕i�ڂ��o�͂���v�Ƀ`�F�b�N�������Ă����ꍇ
	-- ========================================================
	-- ========================================================
	ELSE IF @yotei_nashi = 1
	BEGIN
		-- �� �[���g�������{�[�����[�N�̏����擾
		SELECT
		 CALENDAR.dt_hizuke AS dt_hizuke
		 ,NONYU.cd_hinmei AS cd_hinmei

		 --,floor(NONYU.su_nonyu) AS su_nonyu
		 -- �[���P�ʂ�Kg�܂���L�̏ꍇ�́A�[���𐳋K���ɉ��Z����
		 ,dbo.udf_NonyuHasuKanzan(
			ma_ko.cd_tani_nonyu, ma_hin.cd_tani_nonyu,
			NONYU.su_nonyu, NONYU.su_nonyu_hasu, @tani_kg, @tani_li) AS su_nonyu

		 ,COALESCE(WORK.su_nonyu, 0) AS su_nonyu_wo
		 ,COALESCE(NONYU.cd_torihiki, '') AS cd_torihiki
		 ,COALESCE(ma_hin.cd_niuke_basho, '') AS cd_niuke_basho
		 ,COALESCE(ma_hin.nm_hinmei_ja, '') AS nm_hinmei_ja
		 ,COALESCE(ma_hin.nm_hinmei_en, '') AS nm_hinmei_en
		 ,COALESCE(ma_hin.nm_hinmei_zh, '') AS nm_hinmei_zh
		 ,COALESCE(ma_hin.nm_hinmei_vi, '') AS nm_hinmei_vi
		 ,ma_hin.cd_bunrui AS cd_bunrui
		 ,ma_bun.nm_bunrui AS nm_bunrui
		 ,ma_tan_nonyu.nm_tani AS nonyu_tani
		 ,ma_tan_shiyo.nm_tani AS shiyo_tani
		 ,ma_ko.nm_nisugata_hyoji AS nm_nisugata_hyoji
		 -- �d��
		 --,COALESCE(ma_ko.wt_nonyu, 0) * COALESCE(ma_ko.su_iri, 0)
		 --	* floor(NONYU.su_nonyu) AS juryo
		 ,COALESCE(ma_ko.wt_nonyu, 0) * COALESCE(ma_ko.su_iri, 0)
			* dbo.udf_NonyuHasuKanzan(
				ma_ko.cd_tani_nonyu, ma_hin.cd_tani_nonyu,
				NONYU.su_nonyu, NONYU.su_nonyu_hasu, @tani_kg, @tani_li) AS juryo
		FROM (
			-- �J�����_�[�}�X�^
			SELECT dt_hizuke
				,flg_kyujitsu
			FROM ma_calendar
			WHERE dt_hizuke >= @hizuke_from
			AND dt_hizuke < @hizuke_to
		) CALENDAR

		-- �[���g����
		LEFT JOIN (SELECT cd_hinmei AS cd_hinmei
				,dt_nonyu AS dt_nonyu
				,SUM(su_nonyu) AS su_nonyu
				,cd_torihiki AS cd_torihiki
				,SUM(su_nonyu_hasu) AS su_nonyu_hasu
			FROM tr_nonyu
			WHERE dt_nonyu >= @hizuke_from
			AND dt_nonyu < @hizuke_to
			AND (
				(dt_nonyu < @today AND flg_yojitsu = @flg_jisseki)
				OR
				(dt_nonyu >= @today AND flg_yojitsu = @flg_yotei)
			)
			AND cd_hinmei
				IN (SELECT id FROM udf_SplitCommaValue(@param_hin))
			AND cd_torihiki
				IN (SELECT id FROM udf_SplitCommaValue(@param_torihiki))
			GROUP BY cd_hinmei, dt_nonyu, cd_torihiki
		) NONYU
		ON NONYU.dt_nonyu = CALENDAR.dt_hizuke

		-- �[�����[�N�g����
		LEFT JOIN (SELECT cd_hinmei AS cd_hinmei
				,dt_nonyu AS dt_nonyu
				,su_nonyu AS su_nonyu
				,cd_torihiki AS cd_torihiki
			FROM wk_nonyu
			WHERE dt_nonyu >= @hizuke_from
			AND dt_nonyu < @hizuke_to
			AND cd_hinmei
				IN (SELECT id FROM udf_SplitCommaValue(@param_hin))
			AND cd_torihiki
				IN (SELECT id FROM udf_SplitCommaValue(@param_torihiki))
		) WORK
		ON WORK.dt_nonyu = CALENDAR.dt_hizuke
		AND WORK.cd_hinmei = NONYU.cd_hinmei

		-- �i���}�X�^
		LEFT JOIN ma_hinmei ma_hin
		ON ma_hin.cd_hinmei = NONYU.cd_hinmei

		-- �����ލw����}�X�^
		LEFT JOIN ma_konyu ma_ko
		ON ma_ko.cd_hinmei = NONYU.cd_hinmei
		AND ma_ko.cd_torihiki = NONYU.cd_torihiki

		-- �P�ʃ}�X�^�F�[���P��
		LEFT JOIN ma_tani ma_tan_nonyu
		ON ma_tan_nonyu.cd_tani = ma_ko.cd_tani_nonyu

		-- �P�ʃ}�X�^�F�g�p�P��
		LEFT JOIN ma_tani ma_tan_shiyo
		ON ma_tan_shiyo.cd_tani = ma_hin.cd_tani_shiyo

		-- ���ރ}�X�^
		LEFT JOIN ma_bunrui ma_bun
		ON ma_bun.cd_bunrui = ma_hin.cd_bunrui
		AND ma_bun.kbn_hin = ma_hin.kbn_hin

		WHERE
			NONYU.su_nonyu > 0 OR NONYU.su_nonyu_hasu > 0 OR WORK.su_nonyu > 0
		
	UNION
		
		-- �� �[�����[�N�ɂ������݂��Ȃ������擾
		SELECT
		 CALENDAR.dt_hizuke AS dt_hizuke
		 ,WORK.cd_hinmei AS cd_hinmei

		 --,COALESCE(NONYU.su_nonyu, 0) AS su_nonyu
		 -- �[���P�ʂ�Kg�܂���L�̏ꍇ�́A�[���𐳋K���ɉ��Z����
		 ,dbo.udf_NonyuHasuKanzan(
			wo_ko.cd_tani_nonyu, wo_hin.cd_tani_nonyu,
			NONYU.su_nonyu, NONYU.su_nonyu_hasu, @tani_kg, @tani_li) AS su_nonyu

		 ,COALESCE(WORK.su_nonyu, 0) AS su_nonyu_wo
		 ,COALESCE(WORK.cd_torihiki, '') AS cd_torihiki
		 ,COALESCE(wo_hin.cd_niuke_basho, '') AS cd_niuke_basho
		 ,COALESCE(wo_hin.nm_hinmei_ja, '') AS nm_hinmei_ja
		 ,COALESCE(wo_hin.nm_hinmei_en, '') AS nm_hinmei_en
		 ,COALESCE(wo_hin.nm_hinmei_zh, '') AS nm_hinmei_zh
		 ,COALESCE(wo_hin.nm_hinmei_vi, '') AS nm_hinmei_vi
		 ,wo_bun.cd_bunrui AS cd_bunrui
		 ,wo_bun.nm_bunrui AS nm_bunrui
		 ,wo_tan_nonyu.nm_tani AS nonyu_tani
		 ,wo_tan_shiyo.nm_tani AS shiyo_tani
		 ,wo_ko.nm_nisugata_hyoji AS nm_nisugata_hyoji
		 ,0 AS juryo
		FROM
		-- �J�����_�[�}�X�^
		(SELECT dt_hizuke
				,flg_kyujitsu
		 FROM ma_calendar
		 WHERE dt_hizuke >= @hizuke_from
		 AND dt_hizuke < @hizuke_to
		) CALENDAR

		-- �[�����[�N�g����
		LEFT JOIN (SELECT cd_hinmei AS cd_hinmei
				,dt_nonyu AS dt_nonyu
				,su_nonyu AS su_nonyu
				,cd_torihiki AS cd_torihiki
			FROM wk_nonyu
			WHERE dt_nonyu >= @hizuke_from
			AND dt_nonyu < @hizuke_to
			AND cd_hinmei
				IN (SELECT id FROM udf_SplitCommaValue(@param_hin))
			AND cd_torihiki
				IN (SELECT id FROM udf_SplitCommaValue(@param_torihiki))
		) WORK
		ON WORK.dt_nonyu = CALENDAR.dt_hizuke

		-- �[���g����
		LEFT JOIN (SELECT cd_hinmei AS cd_hinmei
				,dt_nonyu AS dt_nonyu
				,SUM(su_nonyu) AS su_nonyu
				--,SUM(su_nonyu) + SUM(su_nonyu_hasu) AS su_nonyu
				,SUM(su_nonyu_hasu) AS su_nonyu_hasu
				,cd_torihiki AS cd_torihiki
			FROM tr_nonyu
			WHERE dt_nonyu >= @hizuke_from
			AND dt_nonyu < @hizuke_to
			AND (
				(dt_nonyu < @today AND flg_yojitsu = @flg_jisseki)
				OR
				(dt_nonyu >= @today AND flg_yojitsu = @flg_yotei)
			)
			AND cd_hinmei
				IN (SELECT id FROM udf_SplitCommaValue(@param_hin))
			AND cd_torihiki
				IN (SELECT id FROM udf_SplitCommaValue(@param_torihiki))
			GROUP BY cd_hinmei, dt_nonyu, cd_torihiki
		) NONYU
		ON NONYU.dt_nonyu = CALENDAR.dt_hizuke
		AND NONYU.cd_hinmei = WORK.cd_hinmei

		-- �i���}�X�^
		LEFT JOIN ma_hinmei wo_hin
		ON wo_hin.cd_hinmei = WORK.cd_hinmei

		-- �����ލw����}�X�^
		LEFT JOIN ma_konyu wo_ko
		ON wo_ko.cd_hinmei = WORK.cd_hinmei
		AND wo_ko.cd_torihiki = WORK.cd_torihiki

		-- �P�ʃ}�X�^�F�[���P��
		LEFT JOIN ma_tani wo_tan_nonyu
		ON wo_tan_nonyu.cd_tani = wo_ko.cd_tani_nonyu

		-- �P�ʃ}�X�^�F�g�p�P��
		LEFT JOIN ma_tani wo_tan_shiyo
		ON wo_tan_shiyo.cd_tani = wo_hin.cd_tani_shiyo

		-- ���ރ}�X�^
		LEFT JOIN ma_bunrui wo_bun
		ON wo_bun.cd_bunrui = wo_hin.cd_bunrui
		AND wo_bun.kbn_hin = wo_hin.kbn_hin
		
		WHERE (NONYU.su_nonyu > 0 OR NONYU.su_nonyu_hasu > 0 OR WORK.su_nonyu > 0)
		AND NONYU.cd_hinmei IS NULL

	UNION

		-- �� �g�����ƃ��[�N�ɖ���(�[���\��̖���)�i�������擾����
		SELECT
		 @today AS dt_hizuke
		 ,yotei_ko.cd_hinmei AS cd_hinmei

		 --,COALESCE(TR.su_nonyu, 0.0) AS su_nonyu
		 -- �[���P�ʂ�Kg�܂���L�̏ꍇ�́A�[���𐳋K���ɉ��Z����
		 ,dbo.udf_NonyuHasuKanzan(
			yotei_ko.cd_tani_nonyu, ma_hin.cd_tani_nonyu,
			TR.su_nonyu, TR.su_nonyu_hasu, @tani_kg, @tani_li) AS su_nonyu

		 ,COALESCE(WORK.su_nonyu, 0.0) AS su_nonyu_wo
		 ,COALESCE(yotei_ko.cd_torihiki, '') AS cd_torihiki
		 ,COALESCE(ma_hin.cd_niuke_basho, '') AS cd_niuke_basho
		 ,COALESCE(ma_hin.nm_hinmei_ja, '') AS nm_hinmei_ja
		 ,COALESCE(ma_hin.nm_hinmei_en, '') AS nm_hinmei_en
		 ,COALESCE(ma_hin.nm_hinmei_zh, '') AS nm_hinmei_zh
		 ,COALESCE(ma_hin.nm_hinmei_vi, '') AS nm_hinmei_vi
		 ,ma_hin.cd_bunrui AS cd_bunrui
		 ,ma_bun.nm_bunrui AS nm_bunrui
		 ,ma_tan_nonyu.nm_tani AS nonyu_tani
		 ,ma_tan_shiyo.nm_tani AS shiyo_tani
		 ,yotei_ko.nm_nisugata_hyoji AS nm_nisugata_hyoji
		 ,0.0 AS juryo
		FROM (
			SELECT cd_hinmei
			,MIN(no_juni_yusen) AS no_juni_yusen
			FROM ma_konyu
			WHERE cd_hinmei
				IN (SELECT id FROM udf_SplitCommaValue(@param_hin))
			AND flg_mishiyo = @flg_mishiyo
			GROUP BY cd_hinmei
		) YUSEN

		-- �����ލw����}�X�^
		LEFT JOIN ma_konyu yotei_ko
		ON yotei_ko.cd_hinmei = YUSEN.cd_hinmei
		AND yotei_ko.no_juni_yusen = YUSEN.no_juni_yusen
		--AND yotei_ko.flg_mishiyo = @flg_mishiyo

		-- �[���g����
		LEFT JOIN (
				SELECT cd_hinmei AS cd_hinmei
					,su_nonyu AS su_nonyu
					,su_nonyu_hasu AS su_nonyu_hasu
				FROM tr_nonyu
				WHERE dt_nonyu >= @hizuke_from
				AND dt_nonyu < @hizuke_to
				AND (
					(dt_nonyu < @today AND flg_yojitsu = @flg_jisseki)
					OR
					(dt_nonyu >= @today AND flg_yojitsu = @flg_yotei)
				)
				AND cd_hinmei
					IN (SELECT id FROM udf_SplitCommaValue(@param_hin))
				AND cd_torihiki
					IN (SELECT id FROM udf_SplitCommaValue(@param_torihiki))
				AND (su_nonyu > 0 OR su_nonyu_hasu > 0)
		) TR
		ON TR.cd_hinmei = yotei_ko.cd_hinmei

		-- �[�����[�N�g����
		LEFT JOIN (
				SELECT cd_hinmei AS cd_hinmei
					,su_nonyu AS su_nonyu
				FROM wk_nonyu
				WHERE dt_nonyu >= @hizuke_from
				AND dt_nonyu < @hizuke_to
				AND cd_hinmei
					IN (SELECT id FROM udf_SplitCommaValue(@param_hin))
				AND cd_torihiki
					IN (SELECT id FROM udf_SplitCommaValue(@param_torihiki))
				AND su_nonyu > 0
		) WORK
		ON WORK.cd_hinmei = yotei_ko.cd_hinmei

		-- �i���}�X�^
		LEFT JOIN ma_hinmei ma_hin
		ON ma_hin.cd_hinmei = yotei_ko.cd_hinmei

		-- �P�ʃ}�X�^�F�[���P��
		LEFT JOIN ma_tani ma_tan_nonyu
		ON ma_tan_nonyu.cd_tani = yotei_ko.cd_tani_nonyu

		-- �P�ʃ}�X�^�F�g�p�P��
		LEFT JOIN ma_tani ma_tan_shiyo
		ON ma_tan_shiyo.cd_tani = ma_hin.cd_tani_shiyo

		-- ���ރ}�X�^
		LEFT JOIN ma_bunrui ma_bun
		ON ma_bun.cd_bunrui = ma_hin.cd_bunrui
		AND ma_bun.kbn_hin = ma_hin.kbn_hin

		--WHERE TR.su_nonyu IS NULL
		WHERE (TR.su_nonyu IS NULL OR TR.su_nonyu_hasu IS NULL)
		AND WORK.su_nonyu IS NULL
		AND yotei_ko.cd_torihiki IN (SELECT id FROM udf_SplitCommaValue(@param_torihiki))
	END

	-- =========================================================
	-- =========================================================
	--  �u�\��Ȃ��̕i�ڂ��o�͂���v�Ƀ`�F�b�N���Ȃ��ꍇ
	-- =========================================================
	-- =========================================================
	ELSE BEGIN
		-- =================================
		--  �I�����ꂽ�i���R�[�h������ꍇ
		-- =================================
		IF @param_hin <> ''
		BEGIN
			-- �� �[���g�������{�[�����[�N�̏����擾
			SELECT
			 CALENDAR.dt_hizuke AS dt_hizuke
			 ,NONYU.cd_hinmei AS cd_hinmei

			 --,floor(NONYU.su_nonyu) AS su_nonyu
			 -- �[���P�ʂ�Kg�܂���L�̏ꍇ�́A�[���𐳋K���ɉ��Z����
			 ,dbo.udf_NonyuHasuKanzan(
				ma_ko.cd_tani_nonyu, ma_hin.cd_tani_nonyu,
				NONYU.su_nonyu, NONYU.su_nonyu_hasu, @tani_kg, @tani_li) AS su_nonyu

			 ,COALESCE(WORK.su_nonyu, 0) AS su_nonyu_wo
			 ,COALESCE(NONYU.cd_torihiki, '') AS cd_torihiki
			 ,COALESCE(ma_hin.cd_niuke_basho, '') AS cd_niuke_basho
			 ,COALESCE(ma_hin.nm_hinmei_ja, '') AS nm_hinmei_ja
			 ,COALESCE(ma_hin.nm_hinmei_en, '') AS nm_hinmei_en
			 ,COALESCE(ma_hin.nm_hinmei_zh, '') AS nm_hinmei_zh
			 ,COALESCE(ma_hin.nm_hinmei_vi, '') AS nm_hinmei_vi
			 ,ma_hin.cd_bunrui AS cd_bunrui
			 ,ma_bun.nm_bunrui AS nm_bunrui
			 ,ma_tan_nonyu.nm_tani AS nonyu_tani
			 ,ma_tan_shiyo.nm_tani AS shiyo_tani
			 ,ma_ko.nm_nisugata_hyoji AS nm_nisugata_hyoji
			 -- �d��
			 --,COALESCE(ma_ko.wt_nonyu, 0) * COALESCE(ma_ko.su_iri, 0)
			 --	* floor(NONYU.su_nonyu) AS juryo
			 ,COALESCE(ma_ko.wt_nonyu, 0) * COALESCE(ma_ko.su_iri, 0)
				* dbo.udf_NonyuHasuKanzan(
					ma_ko.cd_tani_nonyu, ma_hin.cd_tani_nonyu,
					NONYU.su_nonyu, NONYU.su_nonyu_hasu, @tani_kg, @tani_li) AS juryo
			FROM
			-- �J�����_�[�}�X�^
			(SELECT dt_hizuke
					,flg_kyujitsu
			 FROM ma_calendar
			 WHERE dt_hizuke >= @hizuke_from
			 AND dt_hizuke < @hizuke_to
			) CALENDAR

			-- �[���g����
			LEFT JOIN (SELECT cd_hinmei AS cd_hinmei
					,dt_nonyu AS dt_nonyu
					,SUM(su_nonyu) AS su_nonyu
					,cd_torihiki AS cd_torihiki
					,SUM(su_nonyu_hasu) AS su_nonyu_hasu
				FROM tr_nonyu
				WHERE dt_nonyu >= @hizuke_from
				AND dt_nonyu < @hizuke_to
				AND (
					(dt_nonyu < @today AND flg_yojitsu = @flg_jisseki)
					OR
					(dt_nonyu >= @today AND flg_yojitsu = @flg_yotei)
				)
				AND cd_hinmei
					IN (SELECT id FROM udf_SplitCommaValue(@param_hin))
				AND cd_torihiki
					IN (SELECT id FROM udf_SplitCommaValue(@param_torihiki))
				GROUP BY cd_hinmei, dt_nonyu, cd_torihiki
			) NONYU
			ON NONYU.dt_nonyu = CALENDAR.dt_hizuke

			-- �[�����[�N�g����
			LEFT JOIN (SELECT cd_hinmei AS cd_hinmei
					,dt_nonyu AS dt_nonyu
					,su_nonyu AS su_nonyu
					,cd_torihiki AS cd_torihiki
				FROM wk_nonyu
				WHERE dt_nonyu >= @hizuke_from
				AND dt_nonyu < @hizuke_to
				AND cd_hinmei
					IN (SELECT id FROM udf_SplitCommaValue(@param_hin))
				AND cd_torihiki
					IN (SELECT id FROM udf_SplitCommaValue(@param_torihiki))
			) WORK
			ON WORK.dt_nonyu = CALENDAR.dt_hizuke
			AND WORK.cd_hinmei = NONYU.cd_hinmei

			-- �i���}�X�^
			LEFT JOIN ma_hinmei ma_hin
			ON ma_hin.cd_hinmei = NONYU.cd_hinmei

			-- �����ލw����}�X�^
			LEFT JOIN ma_konyu ma_ko
			ON ma_ko.cd_hinmei = NONYU.cd_hinmei
			AND ma_ko.cd_torihiki = NONYU.cd_torihiki

			-- �P�ʃ}�X�^�F�[���P��
			LEFT JOIN ma_tani ma_tan_nonyu
			ON ma_tan_nonyu.cd_tani = ma_ko.cd_tani_nonyu

			-- �P�ʃ}�X�^�F�g�p�P��
			LEFT JOIN ma_tani ma_tan_shiyo
			ON ma_tan_shiyo.cd_tani = ma_hin.cd_tani_shiyo

			-- ���ރ}�X�^
			LEFT JOIN ma_bunrui ma_bun
			ON ma_bun.cd_bunrui = ma_hin.cd_bunrui
			AND ma_bun.kbn_hin = ma_hin.kbn_hin

			WHERE
				NONYU.su_nonyu > 0 OR WORK.su_nonyu > 0
			
		UNION
			
			-- �� �[�����[�N�ɂ������݂��Ȃ������擾
			SELECT
			 CALENDAR.dt_hizuke AS dt_hizuke
			 ,WORK.cd_hinmei AS cd_hinmei

			 --,COALESCE(NONYU.su_nonyu, 0) AS su_nonyu
			 -- �[���P�ʂ�Kg�܂���L�̏ꍇ�́A�[���𐳋K���ɉ��Z����
			 ,dbo.udf_NonyuHasuKanzan(
				wo_ko.cd_tani_nonyu, wo_hin.cd_tani_nonyu,
				NONYU.su_nonyu, NONYU.su_nonyu_hasu, @tani_kg, @tani_li) AS su_nonyu

			 ,COALESCE(WORK.su_nonyu, 0) AS su_nonyu_wo
			 ,COALESCE(WORK.cd_torihiki, '') AS cd_torihiki
			 ,COALESCE(wo_hin.cd_niuke_basho, '') AS cd_niuke_basho
			 ,COALESCE(wo_hin.nm_hinmei_ja, '') AS nm_hinmei_ja
			 ,COALESCE(wo_hin.nm_hinmei_en, '') AS nm_hinmei_en
			 ,COALESCE(wo_hin.nm_hinmei_zh, '') AS nm_hinmei_zh
			 ,COALESCE(wo_hin.nm_hinmei_vi, '') AS nm_hinmei_vi
			 ,wo_bun.cd_bunrui AS cd_bunrui
			 ,wo_bun.nm_bunrui AS nm_bunrui
			 ,wo_tan_nonyu.nm_tani AS nonyu_tani
			 ,wo_tan_shiyo.nm_tani AS shiyo_tani
			 ,wo_ko.nm_nisugata_hyoji AS nm_nisugata_hyoji
			 ,0 AS juryo
			FROM
			-- �J�����_�[�}�X�^
			(SELECT dt_hizuke
					,flg_kyujitsu
			 FROM ma_calendar
			 WHERE dt_hizuke >= @hizuke_from
			 AND dt_hizuke < @hizuke_to
			) CALENDAR

			-- �[�����[�N�g����
			LEFT JOIN (SELECT cd_hinmei AS cd_hinmei
					,dt_nonyu AS dt_nonyu
					,su_nonyu AS su_nonyu
					,cd_torihiki AS cd_torihiki
				FROM wk_nonyu
				WHERE dt_nonyu >= @hizuke_from
				AND dt_nonyu < @hizuke_to
				AND cd_hinmei
					IN (SELECT id FROM udf_SplitCommaValue(@param_hin))
				AND cd_torihiki
					IN (SELECT id FROM udf_SplitCommaValue(@param_torihiki))
			) WORK
			ON WORK.dt_nonyu = CALENDAR.dt_hizuke

			-- �[���g����
			LEFT JOIN (SELECT cd_hinmei AS cd_hinmei
					,dt_nonyu AS dt_nonyu
					,SUM(su_nonyu) AS su_nonyu
					--,SUM(su_nonyu) + SUM(su_nonyu_hasu) AS su_nonyu
					,SUM(su_nonyu_hasu) AS su_nonyu_hasu
					,cd_torihiki AS cd_torihiki
				FROM tr_nonyu
				WHERE dt_nonyu >= @hizuke_from
				AND dt_nonyu < @hizuke_to
				AND (
					(dt_nonyu < @today AND flg_yojitsu = @flg_jisseki)
					OR
					(dt_nonyu >= @today AND flg_yojitsu = @flg_yotei)
				)
				AND cd_hinmei
					IN (SELECT id FROM udf_SplitCommaValue(@param_hin))
				AND cd_torihiki
					IN (SELECT id FROM udf_SplitCommaValue(@param_torihiki))
				GROUP BY cd_hinmei, dt_nonyu, cd_torihiki
			) NONYU
			ON NONYU.dt_nonyu = CALENDAR.dt_hizuke
			AND NONYU.cd_hinmei = WORK.cd_hinmei

			-- �i���}�X�^
			LEFT JOIN ma_hinmei wo_hin
			ON wo_hin.cd_hinmei = WORK.cd_hinmei

			-- �����ލw����}�X�^
			LEFT JOIN ma_konyu wo_ko
			ON wo_ko.cd_hinmei = WORK.cd_hinmei
			AND wo_ko.cd_torihiki = WORK.cd_torihiki

			-- �P�ʃ}�X�^�F�[���P��
			LEFT JOIN ma_tani wo_tan_nonyu
			ON wo_tan_nonyu.cd_tani = wo_ko.cd_tani_nonyu

			-- �P�ʃ}�X�^�F�g�p�P��
			LEFT JOIN ma_tani wo_tan_shiyo
			ON wo_tan_shiyo.cd_tani = wo_hin.cd_tani_shiyo

			-- ���ރ}�X�^
			LEFT JOIN ma_bunrui wo_bun
			ON wo_bun.cd_bunrui = wo_hin.cd_bunrui
			AND wo_bun.kbn_hin = wo_hin.kbn_hin
			
			WHERE (NONYU.su_nonyu > 0 OR NONYU.su_nonyu_hasu > 0 OR WORK.su_nonyu > 0)
			AND NONYU.cd_hinmei IS NULL
		END

		-- =================================
		--  �I�����ꂽ�i���R�[�h���Ȃ�
		-- =================================
		ELSE BEGIN
			-- �� �[���g�������{�[�����[�N�̏����擾
			SELECT
			 CALENDAR.dt_hizuke AS dt_hizuke
			 ,NONYU.cd_hinmei AS cd_hinmei

			 --,floor(NONYU.su_nonyu) AS su_nonyu
			 -- �[���P�ʂ�Kg�܂���L�̏ꍇ�́A�[���𐳋K���ɉ��Z����
			 ,dbo.udf_NonyuHasuKanzan(
				ma_ko.cd_tani_nonyu, ma_hin.cd_tani_nonyu,
				NONYU.su_nonyu, NONYU.su_nonyu_hasu, @tani_kg, @tani_li) AS su_nonyu

			 ,COALESCE(WORK.su_nonyu, 0) AS su_nonyu_wo
			 ,COALESCE(NONYU.cd_torihiki, '') AS cd_torihiki
			 ,COALESCE(ma_hin.cd_niuke_basho, '') AS cd_niuke_basho
			 ,COALESCE(ma_hin.nm_hinmei_ja, '') AS nm_hinmei_ja
			 ,COALESCE(ma_hin.nm_hinmei_en, '') AS nm_hinmei_en
			 ,COALESCE(ma_hin.nm_hinmei_zh, '') AS nm_hinmei_zh
			 ,COALESCE(ma_hin.nm_hinmei_vi, '') AS nm_hinmei_vi
			 ,ma_hin.cd_bunrui AS cd_bunrui
			 ,ma_bun.nm_bunrui AS nm_bunrui
			 ,ma_tan_nonyu.nm_tani AS nonyu_tani
			 ,ma_tan_shiyo.nm_tani AS shiyo_tani
			 ,ma_ko.nm_nisugata_hyoji AS nm_nisugata_hyoji
			 -- �d��
			 --,COALESCE(ma_ko.wt_nonyu, 0) * COALESCE(ma_ko.su_iri, 0)
			 --	* floor(NONYU.su_nonyu) AS juryo
			 ,COALESCE(ma_ko.wt_nonyu, 0) * COALESCE(ma_ko.su_iri, 0)
				* dbo.udf_NonyuHasuKanzan(
					ma_ko.cd_tani_nonyu, ma_hin.cd_tani_nonyu,
					NONYU.su_nonyu, NONYU.su_nonyu_hasu, @tani_kg, @tani_li) AS juryo
			FROM
			-- �J�����_�[�}�X�^
			(SELECT dt_hizuke
					,flg_kyujitsu
			 FROM ma_calendar
			 WHERE dt_hizuke >= @hizuke_from
			 AND dt_hizuke < @hizuke_to
			) CALENDAR

			-- �[���g����
			LEFT JOIN (SELECT cd_hinmei AS cd_hinmei
					,dt_nonyu AS dt_nonyu
					,SUM(su_nonyu) AS su_nonyu
					,cd_torihiki AS cd_torihiki
					,SUM(su_nonyu_hasu) AS su_nonyu_hasu
				FROM tr_nonyu
				WHERE dt_nonyu >= @hizuke_from
				AND dt_nonyu < @hizuke_to
				AND (
					(dt_nonyu < @today AND flg_yojitsu = @flg_jisseki)
					OR
					(dt_nonyu >= @today AND flg_yojitsu = @flg_yotei)
				)
				AND cd_torihiki
					IN (SELECT id FROM udf_SplitCommaValue(@param_torihiki))
				GROUP BY cd_hinmei, dt_nonyu, cd_torihiki
			) NONYU
			ON NONYU.dt_nonyu = CALENDAR.dt_hizuke

			-- �[�����[�N�g����
			LEFT JOIN (SELECT cd_hinmei AS cd_hinmei
					,dt_nonyu AS dt_nonyu
					,su_nonyu AS su_nonyu
					,cd_torihiki AS cd_torihiki
				FROM wk_nonyu
				WHERE dt_nonyu >= @hizuke_from
				AND dt_nonyu < @hizuke_to
				AND cd_torihiki
					IN (SELECT id FROM udf_SplitCommaValue(@param_torihiki))
			) WORK
			ON WORK.dt_nonyu = CALENDAR.dt_hizuke
			AND WORK.cd_hinmei = NONYU.cd_hinmei

			-- �i���}�X�^
			LEFT JOIN ma_hinmei ma_hin
			ON ma_hin.cd_hinmei = NONYU.cd_hinmei

			-- �����ލw����}�X�^
			LEFT JOIN ma_konyu ma_ko
			ON ma_ko.cd_hinmei = NONYU.cd_hinmei
			AND ma_ko.cd_torihiki = NONYU.cd_torihiki

			-- �P�ʃ}�X�^�F�[���P��
			LEFT JOIN ma_tani ma_tan_nonyu
			ON ma_tan_nonyu.cd_tani = ma_ko.cd_tani_nonyu

			-- �P�ʃ}�X�^�F�g�p�P��
			LEFT JOIN ma_tani ma_tan_shiyo
			ON ma_tan_shiyo.cd_tani = ma_hin.cd_tani_shiyo

			-- ���ރ}�X�^
			LEFT JOIN ma_bunrui ma_bun
			ON ma_bun.cd_bunrui = ma_hin.cd_bunrui
			AND ma_bun.kbn_hin = ma_hin.kbn_hin

			WHERE
				NONYU.su_nonyu > 0 OR WORK.su_nonyu > 0
			
		UNION
			
			-- �� �[�����[�N�ɂ������݂��Ȃ������擾
			SELECT
			 CALENDAR.dt_hizuke AS dt_hizuke
			 ,WORK.cd_hinmei AS cd_hinmei

			 --,COALESCE(NONYU.su_nonyu, 0) AS su_nonyu
			 -- �[���P�ʂ�Kg�܂���L�̏ꍇ�́A�[���𐳋K���ɉ��Z����
			 ,dbo.udf_NonyuHasuKanzan(
				wo_ko.cd_tani_nonyu, wo_hin.cd_tani_nonyu,
				NONYU.su_nonyu, NONYU.su_nonyu_hasu, @tani_kg, @tani_li) AS su_nonyu

			 ,COALESCE(WORK.su_nonyu, 0) AS su_nonyu_wo
			 ,COALESCE(WORK.cd_torihiki, '') AS cd_torihiki
			 ,COALESCE(wo_hin.cd_niuke_basho, '') AS cd_niuke_basho
			 ,COALESCE(wo_hin.nm_hinmei_ja, '') AS nm_hinmei_ja
			 ,COALESCE(wo_hin.nm_hinmei_en, '') AS nm_hinmei_en
			 ,COALESCE(wo_hin.nm_hinmei_zh, '') AS nm_hinmei_zh
			 ,COALESCE(wo_hin.nm_hinmei_vi, '') AS nm_hinmei_vi
			 ,wo_bun.cd_bunrui AS cd_bunrui
			 ,wo_bun.nm_bunrui AS nm_bunrui
			 ,wo_tan_nonyu.nm_tani AS nonyu_tani
			 ,wo_tan_shiyo.nm_tani AS shiyo_tani
			 ,wo_ko.nm_nisugata_hyoji AS nm_nisugata_hyoji
			 ,0 AS juryo
			FROM
			-- �J�����_�[�}�X�^
			(SELECT dt_hizuke
					,flg_kyujitsu
			 FROM ma_calendar
			 WHERE dt_hizuke >= @hizuke_from
			 AND dt_hizuke < @hizuke_to
			) CALENDAR

			-- �[�����[�N�g����
			LEFT JOIN (SELECT cd_hinmei AS cd_hinmei
					,dt_nonyu AS dt_nonyu
					,su_nonyu AS su_nonyu
					,cd_torihiki AS cd_torihiki
				FROM wk_nonyu
				WHERE dt_nonyu >= @hizuke_from
				AND dt_nonyu < @hizuke_to
				AND cd_torihiki
					IN (SELECT id FROM udf_SplitCommaValue(@param_torihiki))
			) WORK
			ON WORK.dt_nonyu = CALENDAR.dt_hizuke

			-- �[���g����
			LEFT JOIN (SELECT cd_hinmei AS cd_hinmei
					,dt_nonyu AS dt_nonyu
					,SUM(su_nonyu) AS su_nonyu
					--,SUM(su_nonyu) + SUM(su_nonyu_hasu) AS su_nonyu
					,SUM(su_nonyu_hasu) AS su_nonyu_hasu
					,cd_torihiki AS cd_torihiki
				FROM tr_nonyu
				WHERE dt_nonyu >= @hizuke_from
				AND dt_nonyu < @hizuke_to
				AND (
					(dt_nonyu < @today AND flg_yojitsu = @flg_jisseki)
					OR
					(dt_nonyu >= @today AND flg_yojitsu = @flg_yotei)
				)
				AND cd_torihiki
					IN (SELECT id FROM udf_SplitCommaValue(@param_torihiki))
				GROUP BY cd_hinmei, dt_nonyu, cd_torihiki
			) NONYU
			ON NONYU.dt_nonyu = CALENDAR.dt_hizuke
			AND NONYU.cd_hinmei = WORK.cd_hinmei

			-- �i���}�X�^
			LEFT JOIN ma_hinmei wo_hin
			ON wo_hin.cd_hinmei = WORK.cd_hinmei

			-- �����ލw����}�X�^
			LEFT JOIN ma_konyu wo_ko
			ON wo_ko.cd_hinmei = WORK.cd_hinmei
			AND wo_ko.cd_torihiki = WORK.cd_torihiki

			-- �P�ʃ}�X�^�F�[���P��
			LEFT JOIN ma_tani wo_tan_nonyu
			ON wo_tan_nonyu.cd_tani = wo_ko.cd_tani_nonyu

			-- �P�ʃ}�X�^�F�g�p�P��
			LEFT JOIN ma_tani wo_tan_shiyo
			ON wo_tan_shiyo.cd_tani = wo_hin.cd_tani_shiyo

			-- ���ރ}�X�^
			LEFT JOIN ma_bunrui wo_bun
			ON wo_bun.cd_bunrui = wo_hin.cd_bunrui
			AND wo_bun.kbn_hin = wo_hin.kbn_hin
			
			WHERE (NONYU.su_nonyu > 0 OR NONYU.su_nonyu_hasu > 0 OR WORK.su_nonyu > 0)
			AND NONYU.cd_hinmei IS NULL
		END
	END


END
GO
