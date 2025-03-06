IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_ShikomiNippo_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_ShikomiNippo_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**********************************************************************
�@�\�F�d�������ʁ@��������
�t�@�C�����Fusp_ShikomiNippo_select
�쐬���F2013.05.27 kasahara.a
�X�V���F2015.07.01 tsujita.s
�X�V���F2016.10.24 okuyama
�X�V���F2017.01.05 cho.k Q&B�T�|�[�gNo17�Ή�
**********************************************************************/
CREATE PROCEDURE [dbo].[usp_ShikomiNippo_select]
    @dt_seizo_st				DATETIME		-- ���������F�������i�J�n�j
	,@dt_seizo_en				DATETIME		-- ���������F�������i�I���j
    ,@cd_shokuba				VARCHAR(14)		-- ���������F�E��R�[�h
    ,@cd_line					VARCHAR(14)		-- ���������F���C���R�[�h
	,@chk_mi_sakusei			SMALLINT		-- ��������/�`���󋵁y���쐬�z
	,@chk_mi_denso				SMALLINT		-- ��������/�`���󋵁y���`���z
	,@chk_denso_machi			SMALLINT		-- ��������/�`���󋵁y�`���ҁz
	,@chk_denso_zumi			SMALLINT		-- ��������/�`���󋵁y�`���ρz
	,@chk_mi_toroku				SMALLINT		-- ��������/�o�^�󋵁y���o�^�z
	,@chk_ichibu_mi_mitoroku	SMALLINT		-- ��������/�o�^�󋵁y�ꕔ���o�^�z
	,@chk_toroku_sumi			SMALLINT		-- ��������/�o�^�󋵁y�o�^�ρz
    ,@FlagFalse					SMALLINT		-- �Œ�l�F���g�p�t���O�F�g�p
    ,@HaigoMasterKbn			SMALLINT		-- �Œ�l�F�}�X�^�敪�F�z��
	,@kbn_hin_genryo			SMALLINT		--�i�敪(�����j
	,@kbn_hin_jika				SMALLINT		--�i�敪(���ƌ����j
	,@skip decimal(10)							-- SKIP����
	,@top decimal(10)							-- ���������
	,@isExcel smallint							-- EXCEL�t���O
AS
BEGIN

	DECLARE @start				DECIMAL(10)
	DECLARE	@end				DECIMAL(10)
	DECLARE @true				BIT
	DECLARE @false				BIT
	DECLARE @day				SMALLINT
	-- �`����
	DECLARE @mi_sakusei			SMALLINT
	DECLARE @mi_denso			SMALLINT
	DECLARE @denso_machi		SMALLINT
	DECLARE @denso_zumi			SMALLINT
	-- �o�^��
	DECLARE @mi_toroku			SMALLINT
	DECLARE @ichibu_mi_toroku	SMALLINT
	DECLARE @toroku_sumi		SMALLINT

	SET @start = @skip
	SET @end = @skip + @top
    SET @true  = 1
    SET @false = 0
	SET	@day = 1
	-- �`����
	SET @mi_sakusei = 0
	SET @mi_denso = 1
	SET @denso_machi = 2
	SET @denso_zumi = 4
	-- �o�^��
	SET @mi_toroku = 0
	SET @ichibu_mi_toroku = 1
	SET @toroku_sumi = 2

	;WITH cte AS
		(
			SELECT           
                shika.flg_jisseki
                ,shika.cd_shikakari_hin
                ,hai.nm_haigo_ja
                ,hai.nm_haigo_en
                ,hai.nm_haigo_zh
				,hai.nm_haigo_vi
                ,tani.nm_tani
                --,shika.wt_shikomi_keikaku
                ,CEILING(shika.wt_shikomi_keikaku * 1000) / 1000 AS wt_shikomi_keikaku
                -- �d����
                --,CAST(ROUND((ISNULL(hai.wt_haigo_gokei, 0) * ISNULL(shika.ritsu_jisseki, 0) * ISNULL(shika.su_batch_jisseki, 0))
                    --+ (ISNULL(hai.wt_haigo_gokei, 0) * ISNULL(shika.ritsu_jisseki_hasu, 0) * ISNULL(shika.su_batch_jisseki_hasu, 0)), 6, 1) AS DECIMAL(38, 6))
                    --+ (ISNULL(hai.wt_haigo_gokei, 0) * ISNULL(shika.ritsu_jisseki_hasu, 0) * ISNULL(shika.su_batch_jisseki_hasu, 0)), 3, 1) AS DECIMAL(38, 6))
                ,CAST((CEILING(((ISNULL(hai.wt_haigo_gokei, 0) * ISNULL(shika.ritsu_jisseki, 0) * ISNULL(shika.su_batch_jisseki, 0))
                    + (ISNULL(hai.wt_haigo_gokei, 0) * ISNULL(shika.ritsu_jisseki_hasu, 0) * ISNULL(shika.su_batch_jisseki_hasu, 0)))* 1000) / 1000 ) AS DECIMAL(35, 3))
                AS wt_shikomi_jisseki
                --,CASE WHEN shika.ritsu_jisseki IS NULL THEN shika.ritsu_keikaku ELSE shika.ritsu_jisseki END AS ritsu_jisseki
                ,CASE WHEN shika.ritsu_jisseki IS NULL THEN shika.ritsu_keikaku ELSE CEILING(shika.ritsu_jisseki * 100) / 100 END AS ritsu_jisseki
                --,CASE WHEN shika.ritsu_jisseki IS NULL THEN shika.ritsu_keikaku_hasu ELSE shika.ritsu_jisseki_hasu END AS ritsu_jisseki_hasu
                ,CASE WHEN shika.ritsu_jisseki IS NULL THEN shika.ritsu_keikaku_hasu ELSE CEILING(shika.ritsu_jisseki_hasu * 100) / 100 END AS ritsu_jisseki_hasu
                --,CASE WHEN shika.su_batch_jisseki IS NULL THEN shika.su_batch_keikaku ELSE shika.su_batch_jisseki END AS su_batch_jisseki
                ,CASE WHEN shika.su_batch_jisseki IS NULL THEN shika.su_batch_keikaku ELSE CEILING(shika.su_batch_jisseki) END AS su_batch_jisseki
                --,CASE WHEN shika.su_batch_jisseki IS NULL THEN shika.su_batch_keikaku_hasu ELSE shika.su_batch_jisseki_hasu END AS su_batch_jisseki_hasu
                ,CASE WHEN shika.su_batch_jisseki IS NULL THEN shika.su_batch_keikaku_hasu ELSE CEILING(shika.su_batch_jisseki_hasu) END AS su_batch_jisseki_hasu
                --,shika.wt_zaiko_jisseki
                ,CEILING(shika.wt_zaiko_jisseki * 1000) / 1000 AS wt_zaiko_jisseki
                ,shika.no_lot_shikakari
                ,shika.dt_seizo
                ,shika.cd_shokuba
                ,shika.cd_line
                ,line.nm_line
                ,shoku.nm_shokuba
                ,hai.no_han
                ,hai.flg_mishiyo AS flg_haigo_mishiyo
                ,tani.flg_mishiyo AS flg_tani_mishiyo
                ,line.flg_mishiyo AS flg_line_mishiyo
                ,seizoLine.flg_mishiyo AS flg_seizo_line_mishiyo
                ,hai.wt_haigo_gokei
                --,shika.wt_hitsuyo
                ,CEILING(shika.wt_hitsuyo* 1000) / 1000 AS wt_hitsuyo
                -- �����c
                ,0 AS wt_shikomi_zan
                ,anbun.kbn_jotai_denso
				,shika.kbn_toroku_jotai
                ,ROW_NUMBER() OVER (ORDER BY shika.dt_seizo, shika.cd_shikakari_hin, shika.cd_line) AS RN
            FROM
			(
				SELECT
					keikaku_shikakari.flg_jisseki
					,keikaku_shikakari.cd_shikakari_hin
					,keikaku_shikakari.wt_shikomi_keikaku
					,keikaku_shikakari.ritsu_jisseki
					,keikaku_shikakari.ritsu_jisseki_hasu
					,keikaku_shikakari.ritsu_keikaku
					,keikaku_shikakari.ritsu_keikaku_hasu
					,keikaku_shikakari.su_batch_jisseki
					,keikaku_shikakari.su_batch_jisseki_hasu
					,keikaku_shikakari.su_batch_keikaku
					,keikaku_shikakari.su_batch_keikaku_hasu
					,keikaku_shikakari.wt_zaiko_jisseki
					,keikaku_shikakari.no_lot_shikakari
					,keikaku_shikakari.dt_seizo
					,keikaku_shikakari.cd_shokuba
					,keikaku_shikakari.cd_line
					,keikaku_shikakari.wt_hitsuyo
					,keikaku_shikakari.kbn_toroku_jotai
					,yuko.cd_haigo
					,MAX(yuko.dt_from) AS dt_from
				FROM
				(
					SELECT
						flg_jisseki
						,cd_shikakari_hin
						,wt_shikomi_keikaku
						,ritsu_jisseki
						,ritsu_jisseki_hasu
						,ritsu_keikaku
						,ritsu_keikaku_hasu
						,su_batch_jisseki
						,su_batch_jisseki_hasu
						,su_batch_keikaku
						,su_batch_keikaku_hasu
						,wt_zaiko_jisseki
						,no_lot_shikakari
						,dt_seizo
						,cd_shokuba
						,cd_line
						,wt_hitsuyo			
						,(
							SELECT 
								CASE
									WHEN COUNT(lotTrace.no_seq) = 0 THEN @mi_toroku
									WHEN COUNT(lotTrace.no_seq) = COUNT(CASE WHEN lotTrace.no_niuke IS NULL THEN 1 ELSE NULL END) THEN @mi_toroku
									WHEN COUNT(lotTrace.no_seq) = COUNT(CASE WHEN lotTrace.no_niuke IS NOT NULL THEN 1 ELSE NULL END) THEN @toroku_sumi
									ELSE @ichibu_mi_toroku
								END
							FROM tr_lot_trace lotTrace

							LEFT JOIN ma_hinmei hinmei
							ON lotTrace.cd_hinmei = hinmei.cd_hinmei
							AND hinmei.flg_mishiyo = @false

							WHERE lotTrace.no_lot_shikakari = su_keikaku_shikakari.no_lot_shikakari
							AND (lotTrace.kbn_hin = @kbn_hin_genryo OR lotTrace.kbn_hin = @kbn_hin_jika)
							AND (hinmei.flg_trace_taishogai IS NULL OR hinmei.flg_trace_taishogai = @false)
						) AS kbn_toroku_jotai			
					FROM su_keikaku_shikakari
					WHERE ( @dt_seizo_st <= dt_seizo AND dt_seizo < DATEADD(DD, @day, @dt_seizo_en) )
					AND cd_shokuba = @cd_shokuba
					AND cd_line = CASE WHEN @cd_line IS NULL THEN cd_line ELSE @cd_line END
				) AS keikaku_shikakari
				LEFT OUTER JOIN 
				(
					SELECT 
						cd_haigo
						,dt_from
					FROM dbo.ma_haigo_mei 
					WHERE flg_mishiyo = @FlagFalse				
				) yuko
				ON keikaku_shikakari.cd_shikakari_hin = yuko.cd_haigo
				AND yuko.dt_from <= keikaku_shikakari.dt_seizo
				GROUP BY 
					keikaku_shikakari.flg_jisseki
					,keikaku_shikakari.cd_shikakari_hin
					,keikaku_shikakari.wt_shikomi_keikaku
					,keikaku_shikakari.ritsu_jisseki
					,keikaku_shikakari.ritsu_jisseki_hasu
					,keikaku_shikakari.ritsu_keikaku
					,keikaku_shikakari.ritsu_keikaku_hasu
					,keikaku_shikakari.su_batch_jisseki
					,keikaku_shikakari.su_batch_jisseki_hasu
					,keikaku_shikakari.su_batch_keikaku
					,keikaku_shikakari.su_batch_keikaku_hasu
					,keikaku_shikakari.wt_zaiko_jisseki
					,keikaku_shikakari.no_lot_shikakari
					,keikaku_shikakari.dt_seizo
					,keikaku_shikakari.cd_shokuba
					,keikaku_shikakari.cd_line
					,keikaku_shikakari.wt_hitsuyo
					,keikaku_shikakari.kbn_toroku_jotai
					,yuko.cd_haigo
			) shika
            LEFT OUTER JOIN dbo.ma_haigo_mei AS hai
			ON shika.cd_haigo = hai.cd_haigo 
			AND shika.dt_from = hai.dt_from
            LEFT OUTER JOIN dbo.ma_tani AS tani
            ON hai.kbn_kanzan = tani.cd_tani
            LEFT OUTER JOIN ma_line line
            ON shika.cd_line = line.cd_line
            LEFT OUTER JOIN ma_seizo_line seizoLine
            ON shika.cd_shikakari_hin = seizoLine.cd_haigo
            AND line.cd_line = seizoLine.cd_line
            AND seizoLine.kbn_master = @HaigoMasterKbn
            LEFT OUTER JOIN ma_shokuba shoku
            ON shika.cd_shokuba = shoku.cd_shokuba
            LEFT JOIN (
				SELECT no_lot_shikakari
					,MIN(kbn_jotai_denso) AS kbn_jotai_denso
				FROM tr_sap_shiyo_yojitsu_anbun
				GROUP BY no_lot_shikakari
			) anbun
			ON shika.no_lot_shikakari = anbun.no_lot_shikakari

			WHERE
			(
				(@chk_mi_sakusei = @true AND (anbun.kbn_jotai_denso IS NULL OR anbun.kbn_jotai_denso = @mi_sakusei))
				OR (@chk_mi_denso = @true AND anbun.kbn_jotai_denso = @mi_denso)
				OR (@chk_denso_machi = @true AND anbun.kbn_jotai_denso = @denso_machi)
				OR (@chk_denso_zumi = @true AND anbun.kbn_jotai_denso = @denso_zumi)
			)
			AND
			(
				(@chk_mi_toroku = @true AND kbn_toroku_jotai = @mi_toroku)
				OR (@chk_ichibu_mi_mitoroku = @true AND kbn_toroku_jotai = @ichibu_mi_toroku)
				OR (@chk_toroku_sumi = @true AND kbn_toroku_jotai = @toroku_sumi)
			)
		)

		SELECT
            cnt
            ,flg_jisseki
            ,cd_shikakari_hin
            ,nm_haigo_ja
            ,nm_haigo_en
            ,nm_haigo_zh
			,nm_haigo_vi
            ,nm_tani
            ,wt_shikomi_keikaku
            ,wt_shikomi_jisseki
            ,ritsu_jisseki
            ,ritsu_jisseki_hasu
            ,su_batch_jisseki
            ,su_batch_jisseki_hasu
            ,wt_zaiko_jisseki
            ,no_lot_shikakari
            ,dt_seizo
            ,cd_shokuba
            ,cd_line
            ,nm_line
            ,nm_shokuba
            ,no_han
            ,flg_haigo_mishiyo
            ,flg_tani_mishiyo
            ,flg_line_mishiyo
            -- �����c
            ,CASE WHEN (ISNULL(wt_shikomi_jisseki, 0) + ISNULL(wt_zaiko_jisseki, 0) - ISNULL(wt_hitsuyo, 0)) > 0
                THEN ISNULL(wt_shikomi_jisseki, 0) + ISNULL(wt_zaiko_jisseki, 0) - ISNULL(wt_hitsuyo, 0)
                ELSE 0
            END AS wt_shikomi_zan
            ,wt_haigo_gokei
            ,wt_hitsuyo
            ,kbn_jotai_denso
			--,CASE
			--	WHEN flg_jisseki = @true AND kbn_toroku_jotai = @mi_toroku THEN @true
			--	ELSE @false
			--END AS flg_toroku
			,@false AS flg_toroku
			,kbn_toroku_jotai
		FROM (
				SELECT 
					MAX(RN) OVER() cnt
					,*
				FROM
					cte 				
			) 
            cte_row
		WHERE 
		( 
			(
				@isExcel = @false
				AND RN BETWEEN @start AND @end
			)
			OR (
				@isExcel = @true
			)
		)
		
END
GO
