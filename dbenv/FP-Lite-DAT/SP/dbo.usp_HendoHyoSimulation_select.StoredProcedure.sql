IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_HendoHyoSimulation_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_HendoHyoSimulation_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===================================================
-- Author:		higashiya.s
-- Create date: 2013.09.13
-- Last Update: 2016.10.14 matsumura.y
-- Description:	�ϓ��\�V�~�����[�V�����F�f�[�^���o����
-- ===================================================
CREATE PROCEDURE [dbo].[usp_HendoHyoSimulation_select]
	 @con_cd_hinmei     varchar(14)
	,@con_dt_hizuke     datetime
	,@flg_one_day       varchar(1)
	,@flg_yojitsu_yo    smallint	-- �萔�F�\���t���O�F�\��
	,@flg_yojitsu_ji    smallint	-- �萔�F�\���t���O�F����
	,@cd_kg		        varchar(2)	-- �萔�F�P�ʃR�[�h�FKg
	,@cd_li		        varchar(2)	-- �萔�F�P�ʃR�[�h�FL
	,@flg_shiyo         smallint	-- �萔�F���g�p�t���O�F�g�p
	,@kbn_zaiko_ryohin	smallint	-- �萔�F�݌ɋ敪�F�Ǖi
	,@sysdate			datetime	-- �V�X�e�����t
AS
BEGIN

-- ============
-- �ϐ��̏�����
-- ============
SET @flg_one_day =
		(SELECT
			CASE WHEN @flg_one_day IS NULL
				 THEN ''
				 ELSE @flg_one_day
				 END)

-- ==============
-- �[���P�ʂ̎擾
-- ==============
DECLARE @cd_tani varchar(10)
DECLARE @su_ko decimal(12, 6)
DECLARE @su_iri decimal(5, 0)

SELECT 
	@su_iri = COALESCE(mk.su_iri,mh.su_iri, 1),
	@su_ko = COALESCE(mk.wt_nonyu,mh.wt_ko, 1),
	@cd_tani = COALESCE(mk.cd_tani_nonyu, mh.cd_tani_shiyo)
FROM ma_hinmei mh
LEFT JOIN (
	SELECT
		su_iri
		,wt_nonyu
		,cd_tani_nonyu
		,cd_hinmei
	FROM ma_konyu
	WHERE cd_hinmei = @con_cd_hinmei
		AND no_juni_yusen = (SELECT MIN(ko.no_juni_yusen) AS no_juni_yusen
							FROM ma_konyu ko WITH(NOLOCK)
							WHERE ko.flg_mishiyo = @flg_shiyo
								AND ko.cd_hinmei = @con_cd_hinmei 
							)
) mk
ON mh.cd_hinmei = mk.cd_hinmei
WHERE mh.cd_hinmei = @con_cd_hinmei

-- ==============
-- �f�[�^���o����
-- ==============
SELECT
	 MEISAI_INFO.dt_hizuke                       AS dt_hizuke
	,MEISAI_INFO.dt_hizuke                       AS dt_ymd
	,MEISAI_INFO.flg_kyujitsu                    AS flg_kyujitsu
	--,ROUND(MEISAI_INFO.su_nonyu, 2, 1)           AS save_before_su_nonyu
	,ROUND(MEISAI_INFO.su_nonyu, 3, 1)           AS save_before_su_nonyu --��ʉB�����ڂ����g���Ă��Ȃ�
	--,ROUND(MEISAI_INFO.su_nonyu, 2, 1)           AS before_su_nonyu
	,ROUND(MEISAI_INFO.su_nonyu, 3, 1)           AS before_su_nonyu -- ������l�ʂ�؂�̂�
	--,ROUND(MEISAI_INFO.su_nonyu, 2, 1)           AS after_su_nonyu
	,ROUND(MEISAI_INFO.su_nonyu, 3, 1)           AS after_su_nonyu -- ������l�ʂ�؂�̂�
	--,ROUND(MEISAI_INFO.su_shiyo, 2, 1)           AS before_wt_shiyo
	--,MEISAI_INFO.su_shiyo                        AS before_wt_shiyo
	,CEILING(MEISAI_INFO.su_shiyo * 1000) / 1000   AS before_wt_shiyo -- ������l�ʂ�؂�グ
	--,MEISAI_INFO.su_shiyo                          AS after_wt_shiyo
	,CEILING(MEISAI_INFO.su_shiyo * 1000) / 1000   AS after_wt_shiyo -- ������l�ʂ�؂�グ
	/*,COALESCE(
		MEISAI_INFO.su_zaiko,
		COALESCE(NEAREST_ZAIKO.su_zaiko, CALC_BEFORE_DAY_ZAIKO_INFO.su_zaiko, 0.00)
	--	- ROUND(SUM_INFO.sum_su_shiyo, 2, 1)
		- (CEILING(SUM_INFO.sum_su_shiyo * 100) / 100)
		+ CASE WHEN @cd_tani = @cd_kg or @cd_tani = @cd_li
			THEN ROUND(SUM_INFO.sum_su_nonyu, 2, 1) * @su_ko * @su_iri
				+ (ROUND(SUM_INFO.sum_su_nonyu_hasu, 2, 1) / 1000 )
			ELSE ROUND(SUM_INFO.sum_su_nonyu, 2, 1) * @su_ko * @su_iri
				+ (ROUND(SUM_INFO.sum_su_nonyu_hasu, 2, 1) * @su_ko)
			END
		- ROUND(SUM_INFO.sum_su_chosei, 2, 1))   AS before_wt_zaiko*/
	,ROUND(COALESCE(
		MEISAI_INFO.su_zaiko,
		COALESCE(NEAREST_ZAIKO.su_zaiko, CALC_BEFORE_DAY_ZAIKO_INFO.su_zaiko, 0.000)
		- (CEILING(SUM_INFO.sum_su_shiyo * 1000) / 1000)
		+ CASE WHEN @cd_tani = @cd_kg or @cd_tani = @cd_li
			THEN ROUND(SUM_INFO.sum_su_nonyu, 2, 1) * @su_ko * @su_iri
				+ (ROUND(SUM_INFO.sum_su_nonyu_hasu, 2, 1) / 1000 ) --�P�ʕϊ��ׂ̈̊���1000
			ELSE ROUND(SUM_INFO.sum_su_nonyu, 2, 1) * @su_ko * @su_iri
				+ (ROUND(SUM_INFO.sum_su_nonyu_hasu, 2, 1) * @su_ko)
			END
		- (CEILING(SUM_INFO.sum_su_chosei * 1000) / 1000)) -- �������͑���ʂɍ��킹������l�ʂ�؂�グ
		, 3, 1) AS before_wt_zaiko --�v�Z���ʂ͏�����l�ʂ�؂�グ
	,@su_iri									 AS su_iri
	,@su_ko										 AS su_ko
	,@cd_tani									 AS cd_tani
	--,MEISAI_INFO.su_zaiko                        AS su_zaiko
	,ROUND(MEISAI_INFO.su_zaiko, 3, 1)           AS su_zaiko --������l�ʂ�؂�̂�
FROM
	-- �y���׏��z
	-- ���t���̖��׏��𒊏o����
   (SELECT
		 @con_cd_hinmei             AS cd_hinmei
		,CALENDAR_INFO.dt_hizuke    AS dt_hizuke
		,CALENDAR_INFO.flg_kyujitsu AS flg_kyujitsu
		--,NONYU_INFO.su_nonyu        AS su_nonyu
		,CASE WHEN @cd_tani = @cd_kg 
				OR @cd_tani = @cd_li
			THEN NONYU_INFO.su_nonyu * @su_ko * @su_iri
				+ (NONYU_INFO.su_nonyu_hasu * @su_ko / 1000 )
			ELSE NONYU_INFO.su_nonyu * @su_ko * @su_iri
				+ (NONYU_INFO.su_nonyu_hasu * @su_ko)
		END							AS su_nonyu 
		,SHIYO_INFO.su_shiyo        AS su_shiyo
		,CHOSEI_INFO.su_chosei      AS su_chosei
		,ZAIKO_INFO.su_zaiko        AS su_zaiko
	FROM
		-- �y���חp�J�����_�[���z
		-- �J�����_�[�}�X�^(ma_calendar)���A�w����t��10���O�`�w����t��15����̓��t�𒊏o����
	   (SELECT
			dt_hizuke,
			flg_kyujitsu
		FROM
			ma_calendar
		WHERE
			dt_hizuke BETWEEN DATEADD(day, -10, @con_dt_hizuke)
				AND DATEADD(day, 15, @con_dt_hizuke)
		) CALENDAR_INFO
		LEFT OUTER JOIN
			-- �y���חp�[���\���z
			-- �[���\���g����(tr_nonyu)���A�w����t��10���O�`�w����t��15����̓��t�P�ʂ̔[�����𒊏o����
			-- �V�X�e�����t�O���ȑO�͎��т���A�V�X�e�����t�����ȍ~�͗\�肩��[�����𒊏o����
		   (SELECT
				 dt_nonyu
				,SUM(COALESCE(su_nonyu, 0.00)) AS su_nonyu
				,SUM(COALESCE(su_nonyu_hasu, 0.00)) AS su_nonyu_hasu
			FROM
				tr_nonyu
			WHERE
				flg_yojitsu = @flg_yojitsu_ji
			AND dt_nonyu >= DATEADD(day, -10, @con_dt_hizuke)
			AND dt_nonyu < @sysdate --DATEADD(day, -1, GETUTCDATE())
			AND cd_hinmei = @con_cd_hinmei
			GROUP BY
				dt_nonyu
			UNION ALL
			SELECT
				 dt_nonyu
				,SUM(COALESCE(su_nonyu, 0.00)) AS su_nonyu
				,SUM(COALESCE(su_nonyu_hasu, 0.00)) AS su_nonyu_hasu
			FROM
				tr_nonyu
			WHERE
				flg_yojitsu = @flg_yojitsu_yo
			--AND dt_nonyu > DATEADD(day, -1, GETUTCDATE())
			AND dt_nonyu BETWEEN @sysdate AND DATEADD(day, 15, @con_dt_hizuke)
			AND cd_hinmei = @con_cd_hinmei
			GROUP BY
				dt_nonyu
			UNION ALL
			SELECT
				[dt_seizo] AS 'dt_hizuke' --���t
				,SUM(COALESCE([su_seizo_yotei], 0.00))      AS 'su_nonyu_yotei' --�����\�萔
				,0
			FROM [tr_keikaku_seihin]
			WHERE
				[dt_seizo] BETWEEN @sysdate AND DATEADD(day, 15, @con_dt_hizuke)
				AND [cd_hinmei] = @con_cd_hinmei
			GROUP BY
				[dt_seizo]
			UNION ALL
			SELECT
				[dt_seizo] AS 'dt_hizuke' --���t
				,SUM(COALESCE(su_seizo_jisseki, 0.00))      AS 'su_nonyu_yotei' --�������ѐ�
				,0
			FROM [tr_keikaku_seihin]
			WHERE
				[dt_seizo] >= DATEADD(day, -10, @con_dt_hizuke)
				AND [dt_seizo] < @sysdate
				AND [cd_hinmei] = @con_cd_hinmei
			GROUP BY
				[dt_seizo]
			) NONYU_INFO
		ON
			CALENDAR_INFO.dt_hizuke = NONYU_INFO.dt_nonyu
		LEFT OUTER JOIN
			-- �y���חp�g�p�\���z
			-- �g�p�\���g����(tr_shiyo_yojitsu)���A�w����t��10���O�`�w����t��15����̓��t�P�ʂ̎g�p���𒊏o����
			-- �V�X�e�����t�O���ȑO�͎��т���A�V�X�e�����t�����ȍ~�͗\�肩��g�p���𒊏o����
		   (SELECT
				 dt_shiyo
				,SUM(COALESCE(su_shiyo, 0.00)) AS su_shiyo
			FROM
				tr_shiyo_yojitsu
			WHERE
				flg_yojitsu = @flg_yojitsu_ji
			AND dt_shiyo >= DATEADD(day, -10, @con_dt_hizuke)
			AND dt_shiyo < @sysdate --DATEADD(day, -1, GETUTCDATE())
			AND cd_hinmei = @con_cd_hinmei
			GROUP BY
				dt_shiyo
			UNION
			SELECT
				 dt_shiyo
				,SUM(COALESCE(su_shiyo, 0.00)) AS su_shiyo
			FROM
				tr_shiyo_yojitsu
			WHERE
				flg_yojitsu = @flg_yojitsu_yo
			--AND dt_shiyo > DATEADD(day, -1, GETUTCDATE())
			AND dt_shiyo BETWEEN @sysdate AND DATEADD(day, 15, @con_dt_hizuke)
			AND cd_hinmei = @con_cd_hinmei
			GROUP BY
				dt_shiyo
			) SHIYO_INFO
		ON
			CALENDAR_INFO.dt_hizuke = SHIYO_INFO.dt_shiyo
		LEFT OUTER JOIN
			-- �y���חp�����z
			-- �����g����(tr_chosei)���A�w����t��10���O�`�V�X�e�����t�O���̓��t�P�ʂ̒������𒊏o����
		   (SELECT
				 dt_hizuke
				,SUM(COALESCE(su_chosei, 0.00)) AS su_chosei
			FROM
				tr_chosei
			WHERE
				dt_hizuke BETWEEN DATEADD(day, -10, @con_dt_hizuke)
					AND DATEADD(day, 15, @con_dt_hizuke)
			--AND dt_hizuke <= DATEADD(day, -1, GETUTCDATE())
			AND cd_hinmei = @con_cd_hinmei
			GROUP BY
				dt_hizuke
			) CHOSEI_INFO
		ON
			CALENDAR_INFO.dt_hizuke = CHOSEI_INFO.dt_hizuke
		LEFT OUTER JOIN
			-- �y���חp�݌Ɂz
			-- �݌Ƀg����(tr_zaiko)���A�w����t��10���O�`�V�X�e�����t�O���̓��t�P�ʂ̍݌ɐ��𒊏o����
		   (SELECT
				 dt_hizuke
				,SUM(COALESCE(su_zaiko, 0.00)) AS su_zaiko
			FROM
				tr_zaiko
			WHERE
				dt_hizuke BETWEEN DATEADD(day, -10, @con_dt_hizuke) AND @sysdate
			AND cd_hinmei = @con_cd_hinmei
			AND kbn_zaiko = @kbn_zaiko_ryohin
			GROUP BY
				dt_hizuke
			) ZAIKO_INFO
		ON
			CALENDAR_INFO.dt_hizuke = ZAIKO_INFO.dt_hizuke
	) MEISAI_INFO
	INNER JOIN
		-- �y�݌v���z
		-- ���t���ɁA���̓��t�܂ł̗݌v���𒊏o����
	   (SELECT
			 SUM_CALENDAR_INFO.dt_hizuke    AS dt_hizuke
		    ,SUM(COALESCE(SUM_MEISAI_INFO.su_nonyu, 0))  AS sum_su_nonyu
			,SUM(COALESCE(SUM_MEISAI_INFO.su_nonyu_hasu, 0))  AS sum_su_nonyu_hasu
		    ,SUM(COALESCE(SUM_MEISAI_INFO.su_shiyo, 0))  AS sum_su_shiyo
		    ,SUM(COALESCE(SUM_MEISAI_INFO.su_chosei, 0)) AS sum_su_chosei
		FROM
			-- �y�݌v�p�J�����_�[���z
			-- �J�����_�[�}�X�^(ma_calendar)���A�w����t��10���O�`�w����t��15����̓��t�𒊏o����
		   (SELECT
				dt_hizuke
			FROM
				ma_calendar
			WHERE
				dt_hizuke BETWEEN DATEADD(day, -10, @con_dt_hizuke)
					AND DATEADD(day, 15, @con_dt_hizuke)
			) SUM_CALENDAR_INFO
			INNER JOIN
				-- �y�݌v�p���׏��z
				-- ���t���ɁA���̓��t�܂ł̗݌v�����Z�o���邽�߂̖��׏��𒊏o����
			   (SELECT
					 SUM_MEISAI_CALENDAR_INFO.dt_hizuke     AS dt_hizuke
				    ,COALESCE(SUM_NONYU_INFO.su_nonyu, 0.00)   AS su_nonyu
					,COALESCE(SUM_NONYU_INFO.su_nonyu_hasu, 0.00)   AS su_nonyu_hasu
				    ,COALESCE(SUM_SHIYO_INFO.su_shiyo, 0.00)   AS su_shiyo
				    ,COALESCE(SUM_CHOSEI_INFO.su_chosei, 0.00) AS su_chosei
				FROM
					-- �y�݌v���חp�J�����_�[���z
					-- �J�����_�[�}�X�^(ma_calendar)���A�w����t��10���O�`�w����t��15����̓��t�𒊏o����
				   (SELECT
						dt_hizuke
					FROM
						ma_calendar
					WHERE
						dt_hizuke BETWEEN DATEADD(day, -10, @con_dt_hizuke)
							AND DATEADD(day, 15, @con_dt_hizuke)
					) SUM_MEISAI_CALENDAR_INFO
					LEFT OUTER JOIN
						-- �y�݌v���חp�[���\���z
						-- �[���\���g����(tr_nonyu)���A�w����t��10���O�`�w����t��15����̓��t�P�ʂ̔[�����𒊏o����
						-- �V�X�e�����t�O���ȑO�͎��т���A�V�X�e�����t�����ȍ~�͗\�肩��[�����𒊏o����
					   (SELECT
							 dt_nonyu
						    ,SUM(COALESCE(su_nonyu, 0.00)) AS su_nonyu
							,SUM(COALESCE(su_nonyu_hasu, 0.00)) AS su_nonyu_hasu
						FROM
							tr_nonyu
						WHERE
							flg_yojitsu = @flg_yojitsu_ji
						AND dt_nonyu >= DATEADD(day, -10, @con_dt_hizuke)
						AND dt_nonyu < @sysdate --DATEADD(day, -1, GETUTCDATE())
						AND cd_hinmei = @con_cd_hinmei
						GROUP BY
							dt_nonyu
						UNION ALL
						SELECT
							 dt_nonyu
						    ,SUM(COALESCE(su_nonyu, 0.00)) AS su_nonyu
							,SUM(COALESCE(su_nonyu_hasu, 0.00)) AS su_nonyu_hasu
						FROM
							tr_nonyu
						WHERE
							flg_yojitsu = @flg_yojitsu_yo
						--AND dt_nonyu > DATEADD(day, -1, GETUTCDATE())
						AND dt_nonyu BETWEEN @sysdate AND DATEADD(day, 15, @con_dt_hizuke)
						AND cd_hinmei = @con_cd_hinmei
						GROUP BY
							dt_nonyu
						UNION ALL
						SELECT
							[dt_seizo] AS 'dt_hizuke' --���t
							,SUM(COALESCE([su_seizo_yotei], 0.00))      AS 'su_nonyu_yotei' --�����\�萔
							,0
						FROM [tr_keikaku_seihin]
						WHERE
							[dt_seizo] BETWEEN @sysdate AND DATEADD(day, 15, @con_dt_hizuke)
							AND [cd_hinmei] = @con_cd_hinmei
						GROUP BY
							[dt_seizo]
						UNION ALL
						SELECT
							[dt_seizo] AS 'dt_hizuke' --���t
							,SUM(COALESCE(su_seizo_jisseki, 0.00))      AS 'su_nonyu_yotei' --�������ѐ�
							,0
						FROM [tr_keikaku_seihin]
						WHERE
							[dt_seizo] >= DATEADD(day, -10, @con_dt_hizuke)
							AND [dt_seizo] < @sysdate
							AND [cd_hinmei] = @con_cd_hinmei
						GROUP BY
							[dt_seizo]
						) SUM_NONYU_INFO
					ON
						SUM_MEISAI_CALENDAR_INFO.dt_hizuke = SUM_NONYU_INFO.dt_nonyu
					LEFT OUTER JOIN
						-- �y�݌v���חp�g�p�\���z
						-- �g�p�\���g����(tr_shiyo_yojitsu)���A�w����t��10���O�`�w����t��15����̓��t�P�ʂ̎g�p���𒊏o����
						-- �V�X�e�����t�O���ȑO�͎��т���A�V�X�e�����t�����ȍ~�͗\�肩��g�p���𒊏o����
					   (SELECT
							 dt_shiyo
							--,CEILING(SUM(COALESCE(su_shiyo, 0.00)) * 100) / 100 AS su_shiyo
							,CEILING(SUM(COALESCE(su_shiyo, 0.00)) * 1000) / 1000 AS su_shiyo  --�����_��l�ʂŐ؂�
						FROM
							tr_shiyo_yojitsu
						WHERE
							flg_yojitsu = @flg_yojitsu_ji
						AND dt_shiyo >= DATEADD(day, -10, @con_dt_hizuke)
						AND dt_shiyo < @sysdate --DATEADD(day, -1, GETUTCDATE())
						AND cd_hinmei = @con_cd_hinmei
						GROUP BY
							dt_shiyo
						UNION ALL
						SELECT
							 dt_shiyo
							--,CEILING(SUM(COALESCE(su_shiyo, 0.00)) * 100) / 100 AS su_shiyo
							,CEILING(SUM(COALESCE(su_shiyo, 0.00)) * 1000) / 1000 AS su_shiyo --�����_��l�ʂŐ؏グ
						FROM
							tr_shiyo_yojitsu
						WHERE
							flg_yojitsu = @flg_yojitsu_yo
						--AND dt_shiyo > DATEADD(day, -1, GETUTCDATE())
						AND dt_shiyo BETWEEN @sysdate AND DATEADD(day, 15, @con_dt_hizuke)
						AND cd_hinmei = @con_cd_hinmei
						GROUP BY
							dt_shiyo
						) SUM_SHIYO_INFO
					ON
						SUM_MEISAI_CALENDAR_INFO.dt_hizuke = SUM_SHIYO_INFO.dt_shiyo
					LEFT OUTER JOIN
						-- �y�݌v���חp�����z
						-- �����g����(tr_chosei)���A�w����t��10���O�`�V�X�e�����t�O���̓��t�P�ʂ̒������𒊏o����
					   (SELECT
							 dt_hizuke
						    ,SUM(COALESCE(su_chosei, 0.00)) AS su_chosei
						FROM
							tr_chosei
						WHERE
							dt_hizuke BETWEEN DATEADD(day, -10, @con_dt_hizuke)
								AND DATEADD(day, 15, @con_dt_hizuke)
						AND cd_hinmei = @con_cd_hinmei
						GROUP BY
							dt_hizuke
						) SUM_CHOSEI_INFO
					ON
						SUM_MEISAI_CALENDAR_INFO.dt_hizuke = SUM_CHOSEI_INFO.dt_hizuke
				) SUM_MEISAI_INFO
			-- �݌v�̑Ώۂ́A�V�X�e�����t�O���ȑO�Œ��߂̎��݌ɂ����݂�����t�̗������炻�̓��t�܂łƂ���
			ON
				SUM_CALENDAR_INFO.dt_hizuke >= SUM_MEISAI_INFO.dt_hizuke
			AND SUM_MEISAI_INFO.dt_hizuke > COALESCE((SELECT
														  MAX(dt_hizuke)
													  FROM
														  tr_zaiko
													  WHERE
														  dt_hizuke >= DATEADD(day, -10, @con_dt_hizuke)
													  AND dt_hizuke < SUM_CALENDAR_INFO.dt_hizuke
													  AND dt_hizuke < @sysdate --DATEADD(day, -1, GETUTCDATE())
													  AND cd_hinmei = @con_cd_hinmei
													  AND kbn_zaiko = @kbn_zaiko_ryohin)
													 , 0)
		GROUP BY SUM_CALENDAR_INFO.dt_hizuke
		) SUM_INFO
	ON
		MEISAI_INFO.dt_hizuke = SUM_INFO.dt_hizuke
	LEFT OUTER JOIN
		-- �y���ߎ��݌ɏ��z
		-- ���t���ɁA�V�X�e�����t�O���ȑO�Œ��߂̎��݌ɏ��𒊏o����
	   (SELECT
			 dt_hizuke
			,SUM(su_zaiko) AS su_zaiko
		FROM
			 tr_zaiko
		WHERE
			dt_hizuke >= DATEADD(day, -10, @con_dt_hizuke)
		AND dt_hizuke < @sysdate --GETUTCDATE() --DATEADD(day, -1, GETUTCDATE())
		AND cd_hinmei = @con_cd_hinmei
		AND kbn_zaiko = @kbn_zaiko_ryohin
		GROUP BY dt_hizuke
	) NEAREST_ZAIKO
	ON
		NEAREST_ZAIKO.dt_hizuke = (SELECT
									   MAX(dt_hizuke)
								   FROM
									   tr_zaiko
								   WHERE
									   dt_hizuke >= DATEADD(day, -10, @con_dt_hizuke)
								   AND dt_hizuke < MEISAI_INFO.dt_hizuke
								   AND dt_hizuke < @sysdate --GETUTCDATE() --DATEADD(day, -1, GETUTCDATE())
								   AND cd_hinmei = @con_cd_hinmei
								   AND kbn_zaiko = @kbn_zaiko_ryohin)
	LEFT OUTER JOIN
		-- �y�Z�o�J�n���O���v�Z�݌ɏ��z
	 	-- �w����t��11���O(�Z�o�J�n���O��)�̌v�Z�݌ɏ��𒊏o����
	   (SELECT
			 cd_hinmei
			,su_zaiko
		FROM
			tr_zaiko_keisan
		WHERE
			dt_hizuke = DATEADD(day, -11, @con_dt_hizuke)
		AND cd_hinmei = @con_cd_hinmei
		) CALC_BEFORE_DAY_ZAIKO_INFO
	ON
		MEISAI_INFO.cd_hinmei = CALC_BEFORE_DAY_ZAIKO_INFO.cd_hinmei
WHERE
-- ����w��t���O���w�肳�ꂽ�ꍇ�́A�w����̂݃f�[�^���o����
-- (�w�肳��Ă��Ȃ��ꍇ(NULL�̏ꍇ)�́A�S���擾�����)
	LEN(@flg_one_day) = 0
OR  MEISAI_INFO.dt_hizuke = @con_dt_hizuke
ORDER BY
	MEISAI_INFO.dt_hizuke

END

