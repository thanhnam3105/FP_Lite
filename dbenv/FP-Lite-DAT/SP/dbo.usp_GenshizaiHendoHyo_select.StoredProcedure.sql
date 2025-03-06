IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_GenshizaiHendoHyo_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_GenshizaiHendoHyo_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ========================================================================
-- �����ޕϓ��\�̌�������
--  �w�肳�ꂽ�i���R�[�h�̌����ށA�J�n���t�`�I�����t�̊��Ԃɂ��āA
--  ���t���ɔ[���\���A�g�p�\���A�������A�݌ɐ��𒊏o����B
-- Author:		kaneko.m
-- Create date: 2013.08.07
-- Last Update: 2020.11.18 wang.w �[�����с��������т̕\���d�l�ύX�i�����_3���܂ŕ\���j
--            : 2021.05.19 BRC.takaki �J�z�݌ɂƌv�Z�݌ɂ̕\�����ق��C��
--            : 2021.06.03 BRC.saito �����̌J�z�݌ɂƌv�Z�݌ɂ̕\�����ق��C��
--            : 2021.12.22 BRC.t.sato �m��`�F�b�N���O�����ꍇ�A�������тɕ\�����Ȃ��悤�C��
-- ========================================================================
CREATE PROCEDURE [dbo].[usp_GenshizaiHendoHyo_select]
	 @cd_hinmei			as varchar(14)	-- �i���R�[�h
	,@dt_hizuke			as datetime		-- �������t�F�J�n��
	,@flg_jisseki		as smallint		-- �萔�F�\���t���O�F����
	,@flg_yotei			as smallint		-- �萔�F�\���t���O�F�\��
	,@flg_shiyo			as smallint		-- �萔�F���g�p�t���O�F�g�p
	,@cd_kg				as varchar(2)	-- �萔�F�P�ʃR�[�h�FKg
	,@cd_li				as varchar(2)	-- �萔�F�P�ʃR�[�h�FL
	,@dt_hizuke_to		as datetime		-- �������t�F�I����
	,@today				as datetime		-- �������t
	,@kbn_zaiko_ryohin	as SMALLINT		-- �萔�F�݌ɋ敪�F�Ǖi
	,@count			int output
WITH RECOMPILE
AS
BEGIN

DECLARE @su_iri DECIMAL(5, 0)
DECLARE @wt_nonyu DECIMAL(12, 6)
DECLARE @cd_tani VARCHAR(10)
DECLARE @kbn_hin SMALLINT

SELECT 
	@su_iri = COALESCE(mk.su_iri,mh.su_iri, 1),
	@wt_nonyu = COALESCE(mk.wt_nonyu,mh.wt_ko, 1),
	@cd_tani = COALESCE(mk.cd_tani_nonyu,mh.cd_tani_shiyo),
	@kbn_hin = mh.kbn_hin
FROM ma_hinmei mh
LEFT JOIN (
	SELECT
		su_iri
		,wt_nonyu
		,cd_tani_nonyu
		,cd_hinmei
	FROM ma_konyu
	WHERE cd_hinmei = @cd_hinmei
		AND no_juni_yusen = (SELECT MIN(ko.no_juni_yusen) AS no_juni_yusen
							FROM ma_konyu ko WITH(NOLOCK)
							WHERE ko.flg_mishiyo = @flg_shiyo
								AND ko.cd_hinmei = @cd_hinmei 
							)
) mk
ON mh.cd_hinmei = mk.cd_hinmei
WHERE mh.cd_hinmei = @cd_hinmei

SELECT
	ROW_NUMBER() OVER (ORDER BY meisai.dt_hizuke)              AS 'no_row'
	,meisai.cd_hinmei                                          AS 'cd_hinmei' --�i���R�[�h
	,meisai.dt_hizuke                                          AS 'dt_ymd' --�B�����ړ��t
	,meisai.dt_hizuke                                          AS 'dt_hizuke' --���t
	,CONVERT(varchar, datepart(weekday, meisai.dt_hizuke) - 1) AS 'dt_yobi' --�j���i��ʂ�ID�ƍ��킹�邽��1���Z�j
	,meisai.flg_kyujitsu                                       AS 'flg_kyujitsu' 
	,meisai.flg_shukujitsu                                     AS 'flg_shukujitsu'
	,CASE WHEN @cd_tani = @cd_kg OR @cd_tani = @cd_li
		-- Kg�܂���L
		THEN ROUND(meisai.su_nonyu_yotei * @wt_nonyu * @su_iri
			+ (meisai.su_nonyu_yotei_hasu / 1000 ),3,1)
		-- ��L�ȊO
		ELSE ROUND(meisai.su_nonyu_yotei * @wt_nonyu * @su_iri 
			+ (meisai.su_nonyu_yotei_hasu * @wt_nonyu),3,1)
	 END														   AS 'su_nonyu_yotei'   --�[���\�萔
	,CASE WHEN @cd_tani = @cd_kg OR @cd_tani = @cd_li
		-- Kg�܂���L
		THEN ROUND(meisai.su_nonyu_jisseki * @wt_nonyu * @su_iri
			+ (meisai.su_nonyu_jisseki_hasu / 1000 ),3,1)
		-- ��L�ȊO
		ELSE ROUND(meisai.su_nonyu_jisseki * @wt_nonyu * @su_iri 
			+ (meisai.su_nonyu_jisseki_hasu * @wt_nonyu),3,1)
	END														   AS 'su_nonyu_jisseki' --�[�����ѐ�
	,CEILING(meisai.su_shiyo_yotei*1000)/1000                  AS 'su_shiyo_yotei' --�g�p�\�萔
	,CEILING(meisai.su_shiyo_jisseki*1000)/1000                AS 'su_shiyo_jisseki' --�g�p���ѐ�
	,CEILING(meisai.su_chosei*1000)/1000                       AS 'su_chosei' --������
	,0.00 AS 'su_keisanzaiko' --�v�Z�݌ɐ�
	,ROUND(meisai.su_jitsuzaiko,3,1)      AS 'su_jitsuzaiko' --���݌ɐ�
    ,ROUND(kurikoshi_zaiko.su_kurikoshi_zan,3,1)   AS 'su_kurikoshi_zan' --�J�z�݌�
	,@wt_nonyu		AS 'su_ko' --�d��
	,@su_iri		AS 'su_iri' --����
	,@cd_tani	    AS 'cd_tani' --�[���P��
FROM
-- �����׏��(meisai) >> ���t���̖��׏��𒊏o���遡
(
    SELECT
        @cd_hinmei                                          AS 'cd_hinmei' --�i���R�[�h
        ,meisai_calendar.dt_hizuke                          AS 'dt_hizuke' --���t
        ,meisai_calendar.flg_kyujitsu                       AS 'flg_kyujitsu' 
        ,meisai_calendar.flg_shukujitsu                     AS 'flg_shukujitsu'
        ,COALESCE(meisai_nonyu_yotei.su_nonyu_yotei, 0.00)     AS 'su_nonyu_yotei' --�[���\�萔
		,COALESCE(meisai_nonyu_yotei.su_nonyu_yotei_hasu, 0.00) AS 'su_nonyu_yotei_hasu' --�[���\��[��
        ,COALESCE(meisai_nonyu_jisseki.su_nonyu_jisseki, 0.00) AS 'su_nonyu_jisseki' --�[�����ѐ�
		,COALESCE(meisai_nonyu_jisseki.su_nonyu_jisseki_hasu, 0.00) AS 'su_nonyu_jisseki_hasu' --�[�����ѐ�
        ,COALESCE(meisai_shiyo_yotei.su_shiyo_yotei, 0)     AS 'su_shiyo_yotei' --�g�p�\�萔
        ,COALESCE(meisai_shiyo_jisseki.su_shiyo_jisseki, 0) AS 'su_shiyo_jisseki' --�g�p���ѐ�
        ,COALESCE(meisai_chosei.su_chosei, 0)               AS 'su_chosei' --������
        ,meisai_zaiko.su_jitsuzaiko                         AS 'su_jitsuzaiko' --���݌ɐ�
    FROM
    -- �����חp�J�����_�[���(meisai_calendar) >> �J�����_�[�}�X�^(ma_calendar)���A�J�n���`�I�����̓��t�𒊏o���遡
    (
        SELECT
            [dt_hizuke] AS 'dt_hizuke' --���t
            ,[flg_kyujitsu] AS 'flg_kyujitsu'
            ,[flg_shukujitsu] AS 'flg_shukujitsu'
        FROM [ma_calendar]
        WHERE
            [dt_hizuke] BETWEEN @dt_hizuke AND @dt_hizuke_to --DATEADD(day, 31, @dt_hizuke)
    ) meisai_calendar
    LEFT OUTER JOIN
    -- �����חp�݌�(meisai_zaiko) >> �݌Ƀg����(tr_zaiko)���A�J�n���`�I�����������ȑO�̓��t�P�ʂ̍݌ɐ��𒊏o���遡
    (
        SELECT
            [dt_hizuke] AS 'dt_hizuke' --���t
            ,SUM(COALESCE([su_zaiko], 0))       AS 'su_jitsuzaiko' --���݌ɐ�
        FROM [tr_zaiko]
        WHERE
            [dt_hizuke] BETWEEN @dt_hizuke AND @dt_hizuke_to --DATEADD(day, 31, @dt_hizuke)
			AND [dt_hizuke] <= @today
            AND [cd_hinmei] = @cd_hinmei
            AND kbn_zaiko = @kbn_zaiko_ryohin
        GROUP BY
            [dt_hizuke]
    ) meisai_zaiko
    ON meisai_calendar.dt_hizuke = meisai_zaiko.dt_hizuke
    LEFT OUTER JOIN
    -- �����חp �[���\��or�����\��(meisai_nonyu_yotei) >> �[���\���g����(tr_nonyu) or �����v��g�������A�J�n���`�I�����̓��t�P�ʂ̗\�萔�𒊏o���遡
    (
        SELECT
            [dt_nonyu] AS 'dt_hizuke' --���t
            ,SUM(COALESCE([su_nonyu], 0.00))      AS 'su_nonyu_yotei' --�[���\�萔
			,SUM(COALESCE([su_nonyu_hasu], 0.00)) AS 'su_nonyu_yotei_hasu' --�[���\��[��
        FROM [tr_nonyu]
        WHERE
            [flg_yojitsu] = @flg_yotei
            AND [dt_nonyu] BETWEEN @dt_hizuke AND @dt_hizuke_to --DATEADD(day, 31, @dt_hizuke)
            AND [cd_hinmei] = @cd_hinmei
        GROUP BY
            [dt_nonyu]
        UNION ALL
        SELECT
            [dt_seizo] AS 'dt_hizuke' --���t
            ,SUM(COALESCE([su_seizo_yotei], 0.00))      AS 'su_nonyu_yotei' --�����\�萔
			,0
        FROM [tr_keikaku_seihin]
        WHERE
            [dt_seizo] BETWEEN @dt_hizuke AND @dt_hizuke_to --DATEADD(day, 31, @dt_hizuke)
            AND [cd_hinmei] = @cd_hinmei
        GROUP BY
            [dt_seizo]
    ) meisai_nonyu_yotei 
    ON meisai_calendar.dt_hizuke = meisai_nonyu_yotei.dt_hizuke
    LEFT OUTER JOIN
    -- �����חp�[������or��������(meisai_nonyu_jisseki) >> �[���\���g����(tr_nonyu)���A�J�n���`�I�����̓��t�P�ʂ̔[�����ѐ��𒊏o���遡
    (
        SELECT
            [dt_nonyu] AS 'dt_hizuke' --���t
            ,SUM(COALESCE([su_nonyu], 0.000))      AS 'su_nonyu_jisseki' --�[�����ѐ�
			,SUM(COALESCE([su_nonyu_hasu], 0.000)) AS 'su_nonyu_jisseki_hasu' --�[�����ђ[��
        FROM [tr_nonyu]
        WHERE
            [flg_yojitsu] = @flg_jisseki
            AND [dt_nonyu] BETWEEN @dt_hizuke AND @dt_hizuke_to --DATEADD(day, 31, @dt_hizuke)
            AND [cd_hinmei] = @cd_hinmei
        GROUP BY
            [dt_nonyu]
        UNION ALL
        SELECT
            [dt_seizo] AS 'dt_hizuke' --���t
            ,SUM(COALESCE([su_seizo_jisseki], 0.00))      AS 'su_nonyu_yotei' --�������ѐ�
			,0
        FROM [tr_keikaku_seihin]
        WHERE
            [dt_seizo] BETWEEN @dt_hizuke AND @dt_hizuke_to --DATEADD(day, 31, @dt_hizuke)
            AND [cd_hinmei] = @cd_hinmei
            AND [flg_jisseki] = CASE WHEN @kbn_hin = 7
                                    -- kbn_hin=7(���ƌ���)�̏ꍇ�Aflg_jisseki��1(��������`�F�b�N�ς�)�̂ݐ������ѐ��ɉ��Z����
                                    THEN 1
                                    -- kbn_hin��7�ȊO�̏ꍇ�Aflg_jisseki�Ɋւ�炸���ׂĐ������ѐ��ɉ��Z����
                                    ELSE [flg_jisseki]
                                END
        GROUP BY
            [dt_seizo]
    ) meisai_nonyu_jisseki
    ON meisai_calendar.dt_hizuke = meisai_nonyu_jisseki.dt_hizuke
    LEFT OUTER JOIN
    -- �����חp�g�p�\��(meisai_shiyo_yotei) >> �g�p�\���g����(tr_shiyo_yojitsu)���A�J�n���`�I�����̓��t�P�ʂ̎g�p�\�萔�𒊏o���遡
    (
        SELECT
            [dt_shiyo] AS 'dt_hizuke' --���t
            ,SUM(COALESCE(CEILING([su_shiyo]*1000)/1000 , 0))      AS 'su_shiyo_yotei' --�g�p�\�萔
        FROM [tr_shiyo_yojitsu]
        WHERE
            [flg_yojitsu] = @flg_yotei
            AND [dt_shiyo] BETWEEN @dt_hizuke AND @dt_hizuke_to --DATEADD(day, 31, @dt_hizuke)
            AND [cd_hinmei] = @cd_hinmei
        GROUP BY
            [dt_shiyo]
    ) meisai_shiyo_yotei
    ON meisai_calendar.dt_hizuke = meisai_shiyo_yotei.dt_hizuke
    LEFT OUTER JOIN
    -- �����חp�g�p����(meisai_shiyo_jisseki) >> �g�p�\���g����(tr_shiyo_yojitsu)���A�J�n���`�I�����̓��t�P�ʂ̎g�p���ѐ��𒊏o���遡
    (
        SELECT
            [dt_shiyo] AS 'dt_hizuke' --���t
            ,SUM(COALESCE(CEILING([su_shiyo]*1000)/1000, 0))      AS 'su_shiyo_jisseki' --�g�p���ѐ�
        FROM [tr_shiyo_yojitsu]
        WHERE
            [flg_yojitsu] = @flg_jisseki
            AND [dt_shiyo] BETWEEN @dt_hizuke AND @dt_hizuke_to --DATEADD(day, 31, @dt_hizuke)
            AND [cd_hinmei] = @cd_hinmei
        GROUP BY
            [dt_shiyo]
    ) meisai_shiyo_jisseki
    ON meisai_calendar.dt_hizuke = meisai_shiyo_jisseki.dt_hizuke
    LEFT OUTER JOIN
    -- �����חp����(meisai_chosei) >> �����g����(tr_chosei)���A�J�n���`�I�����̓��t�P�ʂ̒������𒊏o���遡
    (
        SELECT
            [dt_hizuke] AS 'dt_hizuke' --���t
            ,SUM(COALESCE([su_chosei], 0))      AS 'su_chosei' --������
        FROM [tr_chosei]
        WHERE
            [dt_hizuke] BETWEEN @dt_hizuke AND @dt_hizuke_to --DATEADD(day, 31, @dt_hizuke)
            AND [cd_hinmei] = @cd_hinmei
        GROUP BY
            [dt_hizuke]
    ) meisai_chosei
    ON meisai_calendar.dt_hizuke = meisai_chosei.dt_hizuke
) meisai

-- ���J�z�݌ɂ��Z�o����(kurikoshi_zaiko)��
-- �J�z�݌ɂ̐��x���グ�邽�߁A�J�n����45���O����v�Z����B
LEFT OUTER JOIN
(
	SELECT
		@cd_hinmei AS cd_hinmei
		,ruikei.dt_hizuke AS dt_hizuke
		 -- ���݌ɂ������ꍇ�A�O���̌v�Z�݌ɐ�
		,COALESCE(ruikei_jitsuzaiko.su_jitsuzaiko, zenjitsu_keisanzaiko.su_zaiko, 0.00)
			-- �v�Z�݌ɐ� + �[���� - �g�p�� - ������
				+ COALESCE(ruikei.su_nonyu_ruikei, 0.00)
				- COALESCE(ruikei.su_shiyo_ruikei, 0.000000)
				- COALESCE(ruikei.su_chosei_ruikei, 0.000000)
		 AS 'su_kurikoshi_zan' --�J�z�݌�
	FROM
	-- ���݌v���(ruikei)��
	-- �����t���ɁA���̓��t�܂ł̗݌v���𒊏o���遡
	(
		SELECT
			ruikei_calendar.dt_hizuke    AS 'dt_hizuke' --���t
			,SUM(
				CASE WHEN @cd_tani = @cd_kg OR @cd_tani = @cd_li
					-- Kg�܂���L
					THEN ROUND(ruikei_meisai.su_nonyu * @wt_nonyu * @su_iri 
						+ (ruikei_meisai.su_nonyu_hasu / 1000 ),3,1)
					-- ��L�ȊO
					ELSE ROUND(ruikei_meisai.su_nonyu * @wt_nonyu * @su_iri 
						+ (ruikei_meisai.su_nonyu_hasu * @wt_nonyu),3,1)
				END
			 ) AS 'su_nonyu_ruikei' --�[�����݌v
			,SUM(ruikei_meisai.su_shiyo)  AS 'su_shiyo_ruikei' --�g�p���݌v
			,SUM(ruikei_meisai.su_chosei) AS 'su_chosei_ruikei' --�������݌v
		FROM
		-- ���݌v�p�J�����_�[���(ruikei_calendar)��
		-- ���J�����_�[�}�X�^(ma_calendar)���A�J�n����45���O�`�J�n���̓��t�𒊏o���遡
		(
			SELECT
				[dt_hizuke] AS 'dt_hizuke' --���t
			FROM [ma_calendar]
			WHERE
				[dt_hizuke] BETWEEN DATEADD(day, -45, @dt_hizuke) AND DATEADD(day, -1, @dt_hizuke)
		) ruikei_calendar
		LEFT JOIN
		-- ���݌v�p���׏��(ruikei_meisai)��
		-- �����t���ɁA���̓��t�܂ł̗݌v�����Z�o���邽�߂̖��׏��𒊏o���遡
		(
			SELECT
				ruikei_meisai_calendar.dt_hizuke      AS 'dt_hizuke' --���t
				,COALESCE(ruikei_nonyu.su_nonyu, 0)   AS 'su_nonyu'  --�[����
				,COALESCE(ruikei_nonyu.su_nonyu_hasu, 0)   AS 'su_nonyu_hasu'  --�[����
				,COALESCE(ruikei_shiyo.su_shiyo, 0)   AS 'su_shiyo'  --�g�p��
				,COALESCE(ruikei_chosei.su_chosei, 0) AS 'su_chosei' --������
			FROM
			-- ���݌v���חp�J�����_�[���(ruikei_meisai_calendar)��
			-- ���J�����_�[�}�X�^(ma_calendar)���A�J�n����45���O�`�J�n���̑O���̓��t�𒊏o���遡
			(
				SELECT
					[dt_hizuke] AS 'dt_hizuke' --���t
				FROM [ma_calendar]
				WHERE
					[dt_hizuke] BETWEEN DATEADD(day, -45, @dt_hizuke) AND DATEADD(day, -1, @dt_hizuke)
			) ruikei_meisai_calendar
			LEFT OUTER JOIN
			-- ���݌v���חp�[���\��(ruikei_nonyu)��
			-- ���[���\���g����(tr_nonyu) or �����v��g�������A�J�n����45���O�`�J�n���̑O���𒊏o���遡
			-- ���O���ȑO�͎��т���A�����ȍ~�͗\�肩��[�����𒊏o���遡
			(
				------- ///�[������
				SELECT
					[dt_nonyu] AS 'dt_hizuke' --���t
					,SUM(COALESCE([su_nonyu], 0.000))      AS 'su_nonyu' --�[����
					,SUM(COALESCE([su_nonyu_hasu], 0.000)) AS 'su_nonyu_hasu' --�[���[��
				FROM [tr_nonyu]
				WHERE
					[flg_yojitsu] = @flg_jisseki
					AND [dt_nonyu] BETWEEN DATEADD(day, -45, @dt_hizuke) AND DATEADD(day, -1, @dt_hizuke)
					AND [dt_nonyu] < @today
					AND [cd_hinmei] = @cd_hinmei
				GROUP BY
					[dt_nonyu]
				UNION ALL
				------- ///�[���\��
				SELECT
					nonyu_yotei.[dt_nonyu] AS 'dt_hizuke' --���t
					-- �����ɔ[�����т�����ꍇ�͎��їD��
					,CASE WHEN (SUM(COALESCE(nonyu_jitsu.[su_nonyu], 0.000)) <> 0.000
								OR SUM(COALESCE(nonyu_jitsu.[su_nonyu_hasu], 0.000)) <> 0.000)
						THEN SUM(COALESCE(nonyu_jitsu.[su_nonyu], 0.000))
						ELSE SUM(COALESCE(nonyu_yotei.[su_nonyu], 0.000))
					 END AS 'su_nonyu' --�[����
					 -- �����ɔ[�����т�����ꍇ�͎��їD��
					,CASE WHEN (SUM(COALESCE(nonyu_jitsu.[su_nonyu], 0.000)) <> 0.000
								OR SUM(COALESCE(nonyu_jitsu.[su_nonyu_hasu], 0.000)) <> 0.000)
						THEN SUM(COALESCE(nonyu_jitsu.[su_nonyu_hasu], 0.000))
						ELSE SUM(COALESCE(nonyu_yotei.[su_nonyu_hasu], 0.000))
					 END AS 'su_nonyu_hasu' --�[���[��
				FROM [tr_nonyu] nonyu_yotei
				LEFT JOIN [tr_nonyu] nonyu_jitsu
				ON nonyu_yotei.[no_nonyu] = nonyu_jitsu.[no_nonyu]
				AND nonyu_yotei.[dt_nonyu] = nonyu_jitsu.[dt_nonyu]
				AND nonyu_jitsu.[flg_yojitsu] = @flg_jisseki
				AND nonyu_jitsu.[dt_nonyu] = @today
				WHERE
					nonyu_yotei.[flg_yojitsu] = @flg_yotei
					AND nonyu_yotei.[dt_nonyu] BETWEEN DATEADD(day, -45, @dt_hizuke) AND DATEADD(day, -1, @dt_hizuke)
					AND nonyu_yotei.[dt_nonyu] >= @today
					AND nonyu_yotei.[cd_hinmei] = @cd_hinmei
				GROUP BY
					nonyu_yotei.[dt_nonyu]
				UNION ALL
				------- ///��������
				SELECT
					[dt_seizo] AS 'dt_hizuke' --���t
					,SUM(COALESCE([su_seizo_jisseki], 0.000)) AS 'su_nonyu_yotei' --�����\�萔
					,0.000 AS 'su_nonyu_hasu'
				FROM [tr_keikaku_seihin]
				WHERE
					[dt_seizo] BETWEEN DATEADD(day, -45, @dt_hizuke) AND DATEADD(day, -1, @dt_hizuke)
					AND [dt_seizo] < @today
					AND [cd_hinmei] = @cd_hinmei
				GROUP BY
					[dt_seizo]
				UNION ALL
				------- ///�����\��
				SELECT
					[dt_seizo] AS 'dt_hizuke' --���t
					-- �����ɐ������т�����ꍇ�͎��їD��
					,CASE WHEN (SUM(COALESCE([su_seizo_jisseki], 0.000)) <> 0.000 AND [dt_seizo] = @today)
						THEN SUM(COALESCE([su_seizo_jisseki], 0.000))
						ELSE SUM(COALESCE([su_seizo_yotei], 0.000))
					 END AS 'su_nonyu_yotei' --�����\�萔
					,0.000 AS 'su_nonyu_hasu'
				FROM [tr_keikaku_seihin]
				WHERE
					[dt_seizo] BETWEEN DATEADD(day, -45, @dt_hizuke) AND DATEADD(day, -1, @dt_hizuke)
					AND [dt_seizo] >= @today
					AND [cd_hinmei] = @cd_hinmei
				GROUP BY
					[dt_seizo]
			) ruikei_nonyu
			ON ruikei_meisai_calendar.dt_hizuke = ruikei_nonyu.dt_hizuke
			LEFT OUTER JOIN
			-- ���݌v���חp�g�p�\��(ruikei_shiyo)��
			-- ���g�p�\���g����(tr_shiyo_yojitsu)���A�J�n����45���O�`�J�n���̑O���𒊏o���遡
			-- ���O���ȑO�͎��т���A�����ȍ~�͗\�肩��g�p���𒊏o���遡
			(
				SELECT
					[dt_shiyo] AS 'dt_hizuke' --���t
					,SUM(COALESCE(CEILING([su_shiyo]*1000)/1000, 0))      AS 'su_shiyo' --�g�p��
				FROM [tr_shiyo_yojitsu]
				WHERE
					[flg_yojitsu] = @flg_jisseki
					AND [dt_shiyo] BETWEEN DATEADD(day, -45, @dt_hizuke) AND DATEADD(day, -1, @dt_hizuke)
					AND [dt_shiyo] < @today
					AND [cd_hinmei] = @cd_hinmei
				GROUP BY
					[dt_shiyo]
				UNION
				SELECT
					[dt_shiyo] AS 'dt_hizuke' --���t
					,SUM(COALESCE(CEILING([su_shiyo]*1000)/1000, 0))      AS 'su_shiyo' --�g�p��
				FROM [tr_shiyo_yojitsu]
				WHERE
					[flg_yojitsu] = @flg_yotei
					AND [dt_shiyo] BETWEEN DATEADD(day, -45, @dt_hizuke) AND DATEADD(day, -1, @dt_hizuke)
					AND [dt_shiyo] >= @today
					AND [cd_hinmei] = @cd_hinmei
				GROUP BY
					[dt_shiyo]
			) ruikei_shiyo
			ON ruikei_meisai_calendar.dt_hizuke = ruikei_shiyo.dt_hizuke
			LEFT OUTER JOIN
			-- ���݌v���חp����(ruikei_chosei)��
			-- �������g����(tr_chosei)���A�J�n����45���O�`�J�n���̑O���𒊏o���遡
			(
				SELECT
					[dt_hizuke] AS 'dt_hizuke' --���t
					,SUM(COALESCE([su_chosei], 0))      AS 'su_chosei' --������
				FROM [tr_chosei]
				WHERE
					[dt_hizuke] BETWEEN DATEADD(day, -45, @dt_hizuke) AND DATEADD(day, -1, @dt_hizuke)
					AND [cd_hinmei] = @cd_hinmei
				GROUP BY
					[dt_hizuke]
			) ruikei_chosei
			ON ruikei_meisai_calendar.dt_hizuke = ruikei_chosei.dt_hizuke
		) ruikei_meisai
		-- ���݌v�̑Ώۂ́A�O���ȑO�Œ��߂̎��݌ɂ����݂�����t�̗������炻�̓��t�܂łƂ��遡
		ON ruikei_calendar.dt_hizuke >= ruikei_meisai.dt_hizuke
		AND ruikei_meisai.dt_hizuke > COALESCE((SELECT MAX([dt_hizuke]) AS dt_hizuke
											   FROM [tr_zaiko]
											   WHERE [dt_hizuke] >= DATEADD(day, -45, @dt_hizuke)
													AND [dt_hizuke] <= ruikei_calendar.dt_hizuke
													AND [dt_hizuke] <= @today
													AND [cd_hinmei] = @cd_hinmei
													AND kbn_zaiko = @kbn_zaiko_ryohin), 0)
		GROUP BY
			ruikei_calendar.dt_hizuke
	) ruikei

	LEFT OUTER JOIN
	-- ���݌v�p���ߎ��݌ɏ��
	-- �����t���Ɏ��݌ɏ��𒊏o���遡
	(
		SELECT
			[dt_hizuke] AS 'dt_hizuke' --���t
			,SUM(COALESCE([su_zaiko], 0)) AS 'su_jitsuzaiko' --���݌ɐ�
		FROM [tr_zaiko]
		WHERE
			[dt_hizuke] BETWEEN DATEADD(day, -45, @dt_hizuke) AND DATEADD(day, -1, @dt_hizuke)
			AND [dt_hizuke] <= @today
			AND [cd_hinmei] = @cd_hinmei
			AND kbn_zaiko = @kbn_zaiko_ryohin
		GROUP BY
			[dt_hizuke]
	) ruikei_jitsuzaiko
	ON ruikei_jitsuzaiko.dt_hizuke = (SELECT MAX([dt_hizuke])
									  FROM [tr_zaiko]
                                      WHERE [dt_hizuke] BETWEEN DATEADD(day, -45, @dt_hizuke) AND ruikei.dt_hizuke
                                      AND [dt_hizuke] <= @today
                                      AND [cd_hinmei] = @cd_hinmei
                                      AND kbn_zaiko = @kbn_zaiko_ryohin)
	LEFT OUTER JOIN
	-- ���O���v�Z�݌ɏ��(zenjitsu_keisanzaiko) >> �J�n����46���O�̌v�Z�݌ɏ��𒊏o���遡
	(
		SELECT
			[cd_hinmei] AS 'cd_hinmei'
			,[dt_hizuke]
			,[su_zaiko] 
		FROM [tr_zaiko_keisan]
		WHERE
			[dt_hizuke] = DATEADD(day, -46, @dt_hizuke)
			AND [cd_hinmei] = @cd_hinmei
	) zenjitsu_keisanzaiko
	ON 1 = 1

	WHERE ruikei.dt_hizuke = DATEADD(day, -1, @dt_hizuke)
) kurikoshi_zaiko
ON meisai.cd_hinmei = kurikoshi_zaiko.cd_hinmei

ORDER BY
	 meisai.dt_hizuke
SET @count = @@ROWCOUNT
END

GO
