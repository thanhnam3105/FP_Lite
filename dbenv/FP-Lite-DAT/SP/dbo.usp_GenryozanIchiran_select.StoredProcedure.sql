IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_GenryozanIchiran_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_GenryozanIchiran_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\		�F�����c�ꗗ��� ����
�t�@�C����	�Fusp_GenryozanIchiran_select
���͈���	�F@dt_hyoryo, @kaifuzumiMikaifuFlg, @mikaifuMikaifuFlg
			  , @dt_kigen_chokuzen, @dt_kigen_chikai, @cd_shokuba
			  , @mikaifu, @searchCriteriaFlg, @taishoHakiFlg
			  , @hakiTaisho, @hakiTaishogai, @kigengireKigenFlg
			  , @chokuzenKigenFlg, @chikaiKigenFlg, @yoyuKigenFlg
			  , @shiyoMishiyoFlg, @skip, @top, dt_utc
�o�͈���	�F
�߂�l		�F������[0] ���s��[0�ȊO�̃G���[�R�[�h]
�쐬��		�F2013.11.19 ADMAX onodera.s
�X�V��      �F2014.02.17 ADMAX kunii.h
�X�V��      �F2016.07.25 BRC   motojima.m -- LB�Ή�
�X�V��      �F2017.02.15 BRC   kanehira.d -- �T�|�[�gNo.30
�X�V��      �F2018.02.26 BRC   yokota.t   -- �𓀃��x���Ή�
�X�V��      �F2018.05.08 BRC   tokumoto.k -- �𓀎c���x���Ή�
�X�V��      �F2022.05.31 BRC   yashiro.k -- �^�C���A�E�g�������Ή�
*****************************************************/
CREATE PROCEDURE [dbo].[usp_GenryozanIchiran_select] 
	@dt_hyoryo				DATETIME     --���ʓ�
	,@dt_kigen_chokuzen		SMALLINT	 --�������O
	,@dt_kigen_chikai		SMALLINT	 --�����߂�
	,@cd_shokuba			VARCHAR(10)	 --�E��R�[�h
	,@kaifuzumiMikaifuFlg	SMALLINT     --���J���t���O�i�J���ς݁j
	,@mikaifuMikaifuFlg		SMALLINT     --���J���t���O�i���J���j
	--,@mikaifu				VARCHAR(10)  --�J�����\���p/���J��
	,@mikaifu				NVARCHAR(10) --�J�����\���p/���J��
	,@searchCriteriaFlg		SMALLINT     --���������t���O
	,@taishoHakiFlg			SMALLINT     --�j���t���O�i�j���Ώہj
	--,@hakiTaisho			VARCHAR(10)  --��ԕ\���p�i�j���j
	,@hakiTaisho			NVARCHAR(10) --��ԕ\���p�i�j���j
	--,@hakiTaishogai		VARCHAR(10)  --��ԕ\���p�i�c�j
	,@hakiTaishogai			NVARCHAR(10) --��ԕ\���p�i�c�j
	,@kigengireKigenFlg		SMALLINT     --�����t���O�i�����؂�j
	,@chokuzenKigenFlg		SMALLINT     --�����t���O�i�����؂꒼�O�j
	,@chikaiKigenFlg		SMALLINT     --�����t���O�i�����؂�߂��j
	,@yoyuKigenFlg			SMALLINT     --�����t���O�i�����؂�]�T����j
	,@shiyoMishiyoFlg		SMALLINT     --���g�p�t���O�i�g�p�j
	,@skip					DECIMAL(10)  --�Ǎ��J�n�ʒu
	,@top					DECIMAL(10)  --��ʕ\������
	,@dt_utc				DATETIME	 --�V�X�e���u�N�����v��UTC���� EX)���{�Fyyyy/MM/dd 15:00:00.000
	,@kbnShikakari			SMALLINT     --�d�|�c���x���敪
	,@kbnKaito				SMALLINT     --�𓀃��x���敪
	,@kbnKaitozan			SMALLINT	 --�𓀎c���x���敪

WITH RECOMPILE

AS
    DECLARE @day	SMALLINT
    DECLARE @start	DECIMAL(10)
    DECLARE @end	DECIMAL(10)
    DECLARE @kbn_kino_tani SMALLINT
	SET		@day	= 1
    SET		@start	= @skip + 1
    SET		@end	= @skip + @top
    
    -- �P�ʋ@�\�敪���擾
    SELECT
		@kbn_kino_tani = ISNULL(kbn_kino_naiyo, 0)
	FROM cn_kino_sentaku
	WHERE kbn_kino = 2 

BEGIN
	WITH cte AS
		(
			SELECT
			 	*
				,ROW_NUMBER() OVER (ORDER BY cd_hinmei,kigen) AS RN-- ���ёւ�����
			FROM
			(
				SELECT DISTINCT-- �\������
					ISNULL(tzj.cd_hinmei,'') AS cd_hinmei
					,ISNULL(tzj.nm_hinmei,'') AS nm_hinmei
					--,ISNULL(tl.no_lot,'') AS no_lot
					,CASE 
						WHEN tl.no_lot = tkn.no_lot THEN ISNULL(tkn.old_no_lot,'')
						ELSE ISNULL(tl.no_lot,'')
					 END AS no_lot
					,ISNULL(tl.no_lot,'') AS old_no_lot
					,CASE
						-- �𓀃��x���̏ꍇ
						WHEN tzj.kbn_label = @kbnKaito THEN NULL
						-- �P�ʂ�g�A���@�\�P�ʋ敪��1(LB)�̏ꍇ
						-- ���яd��(kg�P��)�~455.55
						WHEN ISNULL(tani.cd_tani, 4) = 3 AND @kbn_kino_tani = 1 THEN ISNULL(tzj.wt_jisseki,0.000) * 454.55
						-- �P�ʂ�g�A���@�\�P�ʋ敪��1(Kg)�̏ꍇ
						-- ���яd��(kg�P��)�~1000.000
						WHEN ISNULL(tani.cd_tani, 4) = 3 AND @kbn_kino_tani = 0 THEN ISNULL(tzj.wt_jisseki,0.000) * 1000.000
						-- �P�ʂ�Kg�ELB�̏ꍇ
						ELSE ISNULL(tzj.wt_jisseki,0.000)
					 END AS wt_jisseki
					,ISNULL(tani.nm_tani,'') AS wt_jisseki_tani
					,ISNULL(mt.nm_tanto,'') AS nm_tanto
					,ISNULL(tzj.dt_hyoryo_zan,'') AS dt_hyoryo_zan
					,tl.dt_shomi AS dt_shomi
					,CASE 
						-- �𓀃��x���܂��͉𓀎c���x���̏ꍇ
						WHEN tzj.kbn_label = @kbnKaito OR tzj.kbn_label = @kbnKaitozan THEN NULL 
						-- ���J���̏ꍇ
	 					WHEN tzj.flg_mikaifu = @mikaifuMikaifuFlg THEN tl.dt_shomi
						-- �J���ς݂̏ꍇ
						WHEN tzj.flg_mikaifu = @kaifuzumiMikaifuFlg THEN tl.dt_shomi_kaifu
					END AS kigen
					,tl.dt_shomi_kaito AS dt_shomi_kaito	-- �𓀌�ܖ�����
					,CASE
						-- �𓀃��x���̏ꍇ
						WHEN tzj.kbn_label = @kbnKaito THEN ISNULL(mkh3.nm_hokan_kbn, '')

						-- ���z�����}�X�^�ɕۊǋ敪������ꍇ
						-- �����t�E�d�|�c�̏ꍇ
						WHEN tzj.kbn_label = @kbnShikakari THEN ISNULL(mkh1.nm_hokan_kbn, '')
						
						-- ���i���}�X�^�ɕۊǋ敪������ꍇ
						-- ���J���̏ꍇ
	 					WHEN tzj.flg_mikaifu = @mikaifuMikaifuFlg THEN ISNULL(mkh.nm_hokan_kbn,'')
						-- �J���ς݂̏ꍇ
						WHEN tzj.flg_mikaifu = @kaifuzumiMikaifuFlg THEN ISNULL(mkh2.nm_hokan_kbn,'')
						
						-- ����O
						ELSE ''
					 END AS nm_hokan_kbn
					--,ISNULL(tzj.wt_jisseki_futai,'') AS wt_jisseki_futai
					,CASE 
						-- �𓀃��x���̏ꍇ
						WHEN tzj.kbn_label = @kbnKaito THEN NULL
						ELSE ISNULL(tzj.wt_jisseki_futai,'')
					 END AS wt_jisseki_futai
					,ISNULL(tani.nm_tani,'') AS wt_jisseki_futai_tani
					,CASE
						-- ���J���̏ꍇ
						WHEN tzj.flg_mikaifu = @mikaifuMikaifuFlg THEN @mikaifu
						-- �J���ς݂̏ꍇ
						WHEN tzj.flg_mikaifu = @kaifuzumiMikaifuFlg THEN CONVERT(VARCHAR,tzj.dt_kaifu,120)
					END AS kaifu
					,CASE
						WHEN tzj.flg_haki = @taishoHakiFlg THEN @hakiTaisho
						ELSE @hakiTaishogai
					END AS flg_haki
					-- ��\������
					,CASE
						-- �𓀃��x���܂��͉𓀎c���x���̏ꍇ
						WHEN tzj.kbn_label = @kbnKaito OR tzj.kbn_label = @kbnKaitozan THEN
							CASE
								-- �g�p�����؂�F�����̓Z�[�t
								WHEN tl.dt_shomi_kaito < @dt_utc THEN @kigengireKigenFlg
								-- �g�p�������O
								WHEN tl.dt_shomi_kaito >= @dt_utc
								AND tl.dt_shomi_kaito < DATEADD(DAY, @dt_kigen_chokuzen + 1, @dt_utc) THEN @chokuzenKigenFlg
								-- �g�p�����߂�
								WHEN tl.dt_shomi_kaito >= DATEADD(DAY, @dt_kigen_chokuzen + 1, @dt_utc)
								AND tl.dt_shomi_kaito < DATEADD(DAY, @dt_kigen_chikai + 1, @dt_utc) THEN @chikaiKigenFlg
								-- �g�p�����܂ŗ]�T����
		 						ELSE @yoyuKigenFlg						
							END		
						-- ���J���̏ꍇ
						WHEN tzj.flg_mikaifu = @mikaifuMikaifuFlg THEN
							CASE
								-- �g�p�����؂�F�����̓Z�[�t
								WHEN tl.dt_shomi < @dt_utc THEN @kigengireKigenFlg
								-- �g�p�������O
								WHEN tl.dt_shomi >= @dt_utc
								AND tl.dt_shomi < DATEADD(DAY, @dt_kigen_chokuzen + 1, @dt_utc) THEN @chokuzenKigenFlg
								-- �g�p�����߂�
								WHEN tl.dt_shomi >= DATEADD(DAY, @dt_kigen_chokuzen + 1, @dt_utc)
								AND tl.dt_shomi < DATEADD(DAY, @dt_kigen_chikai + 1, @dt_utc) THEN @chikaiKigenFlg
								-- �g�p�����܂ŗ]�T����
		 						ELSE @yoyuKigenFlg
							END
						-- �J���ς݂̏ꍇ
						WHEN tzj.flg_mikaifu = @kaifuzumiMikaifuFlg THEN
							CASE
								-- �g�p�����؂�F�����̓Z�[�t
								WHEN tl.dt_shomi_kaifu < @dt_utc THEN @kigengireKigenFlg
								-- �g�p�������O
								WHEN tl.dt_shomi_kaifu >= @dt_utc
									AND tl.dt_shomi_kaifu < DATEADD(DAY, @dt_kigen_chokuzen + 1, @dt_utc) THEN @chokuzenKigenFlg
								-- �g�p�����߂�
								WHEN tl.dt_shomi_kaifu >= DATEADD(DAY, @dt_kigen_chokuzen + 1, @dt_utc)
									AND tl.dt_shomi_kaifu < DATEADD(DAY, @dt_kigen_chikai + 1, @dt_utc) THEN @chikaiKigenFlg
								-- �g�p�����܂ŗ]�T����
								ELSE @yoyuKigenFlg
							END
						 END AS  kigenFlg
						 ,ISNULL(tzj.no_lot_zan,'') AS no_lot_zan
						 --,ISNULL(CONVERT(DATETIME,tzj.dt_hyoryo_zan, 121), '') AS date_hyoryozan
						 ,ISNULL(tzj.dt_hyoryo_zan, '') AS date_hyoryozan
						 ,ISNULL(tzj.flg_mikaifu,'') AS mikaifuFlg
						 ,ISNULL(tn.nm_maker_kojo,'') AS nm_maker_kojo
						 ,CASE 
							WHEN tzj.kbn_label = @kbnShikakari THEN mfk1.cd_tani
							ELSE mfk.cd_tani
						  END AS cd_tani_futai
						 ,mp.flg_shiyo_tani_mg AS flg_shiyo_tani_mg
						 ,mhr.cd_tani AS cd_tani_hakari
						 ,CASE 
							WHEN tzj.kbn_label = @kbnShikakari THEN (select nm_kbn from udf_ChuiKankiShiyo(tzj.cd_hinmei,1,1,0,@kbnShikakari))
							ELSE (select nm_kbn from udf_ChuiKankiShiyo(tzj.cd_hinmei,1,1,0,mh.kbn_hin))
						 END AS kbnAllergy
						 ,CASE 
							WHEN tzj.kbn_label = @kbnShikakari THEN (select nm_chui_kanki from udf_ChuiKankiShiyo(tzj.cd_hinmei,1,1,0,@kbnShikakari))
							ELSE (select nm_chui_kanki from udf_ChuiKankiShiyo(tzj.cd_hinmei,1,1,0,mh.kbn_hin))
						 END AS nm_Allergy
						 ,CASE 
							WHEN tzj.kbn_label = @kbnShikakari THEN (select nm_kbn from udf_ChuiKankiShiyo(tzj.cd_hinmei,9,1,0,@kbnShikakari))
							ELSE (select nm_kbn from udf_ChuiKankiShiyo(tzj.cd_hinmei,9,1,0,mh.kbn_hin))
						 END AS kbnOther
						 ,CASE 
							WHEN tzj.kbn_label = @kbnShikakari THEN (select nm_chui_kanki from udf_ChuiKankiShiyo(tzj.cd_hinmei,9,1,0,@kbnShikakari))
							ELSE (select nm_chui_kanki from udf_ChuiKankiShiyo(tzj.cd_hinmei,9,1,0,mh.kbn_hin))
						 END AS nm_Other
						 ,tzj.kbn_label AS kbn_label
					FROM tr_zan_jiseki tzj
					LEFT OUTER JOIN tr_lot tl
					ON tzj.no_lot_zan = tl.no_lot_jisseki
					LEFT OUTER JOIN tr_kongo_nisugata tkn
					ON tzj.no_lot_zan = tkn.no_lot_jisseki
					AND tl.no_lot = tkn.no_lot
					LEFT OUTER JOIN ma_tanto mt
					ON tzj.cd_tanto = mt.cd_tanto
					LEFT OUTER JOIN ma_hinmei mh
					ON tzj.cd_hinmei = mh.cd_hinmei
					LEFT OUTER JOIN ma_kbn_hokan mkh
					ON mh.kbn_hokan = mkh.cd_hokan_kbn
					LEFT OUTER JOIN ma_kbn_hokan mkh2
					ON mh.kbn_kaifugo_hokan = mkh2.cd_hokan_kbn
					LEFT OUTER JOIN tr_niuke tn
					ON tzj.cd_maker = tn.cd_maker
					LEFT OUTER JOIN ma_panel mp
					ON tzj.cd_panel = mp.cd_panel
					AND mp.flg_mishiyo = @shiyoMishiyoFlg
					LEFT OUTER JOIN ma_futai_kettei mfk
					ON  mh.cd_hinmei = mfk.cd_hinmei
					AND mh.kbn_hin = mfk.kbn_hin
					AND mfk.flg_mishiyo = @shiyoMishiyoFlg
					LEFT OUTER JOIN ma_hakari mhr
					ON mhr.cd_hakari = mp.cd_hakari_1
					AND mhr.flg_mishiyo = @shiyoMishiyoFlg
					LEFT OUTER JOIN ma_tani tani
					ON mhr.cd_tani = tani.cd_tani
					LEFT OUTER JOIN ma_haigo_mei mhm
					ON mhm.cd_haigo = tzj.cd_hinmei
					AND mhm.no_han = (SELECT TOP 1 no_han FROM udf_HaigoRecipeYukoHan(mhm.cd_haigo, @shiyoMishiyoFlg, tzj.dt_hyoryo_zan))
					AND tzj.kbn_label = @kbnShikakari
					LEFT OUTER JOIN ma_kbn_hokan mkh1
					ON mhm.kbn_hokan = mkh1.cd_hokan_kbn
					LEFT OUTER JOIN ma_futai_kettei mfk1
					ON  mhm.cd_haigo = mfk1.cd_hinmei
					AND mfk1.kbn_hin = 5
					AND mfk1.flg_mishiyo = @shiyoMishiyoFlg
					-- �𓀌�ۊǋ敪���擾
					LEFT OUTER JOIN ma_kbn_hokan mkh3
					ON mh.kbn_kaitogo_hokan = mkh3.cd_hokan_kbn
					AND mkh3.flg_mishiyo = @shiyoMishiyoFlg
					WHERE
						tzj.dt_read IS NULL
						AND (( @searchCriteriaFlg = 0 )
						OR @dt_hyoryo <= dt_hyoryo_zan
  						AND dt_hyoryo_zan < (SELECT DATEADD(DD,@day,@dt_hyoryo)))
						AND mp.cd_shokuba = @cd_shokuba
						AND ((tzj.kbn_label = @kbnShikakari AND mhm.cd_haigo IS NOT NULL) OR tzj.kbn_label != @kbnShikakari)
			) genryozan
		)
	SELECT
		cnt
		-- �\������
		,cte_row.cd_hinmei
		,cte_row.nm_hinmei
		,cte_row.no_lot
		,cte_row.old_no_lot
		,cte_row.wt_jisseki
		,cte_row.wt_jisseki_tani
		,cte_row.nm_tanto
		,cte_row.dt_hyoryo_zan
		,cte_row.dt_shomi
		,cte_row.kigen
		,cte_row.dt_shomi_kaito
		,cte_row.nm_hokan_kbn
		,cte_row.wt_jisseki_futai
		,cte_row.wt_jisseki_futai_tani
		,cte_row.kaifu
		,cte_row.flg_haki
		-- ��\������
		,cte_row.kigenFlg
		,cte_row.no_lot_zan
		,cte_row.date_hyoryozan
		,cte_row.mikaifuFlg
		,cte_row.nm_maker_kojo
		,cte_row.cd_tani_futai
		,cte_row.flg_shiyo_tani_mg
		,cte_row.cd_tani_hakari
		,cte_row.kbnAllergy
		,cte_row.nm_Allergy
		,cte_row.kbnOther
		,cte_row.nm_Other
		,cte_row.kbn_label
		
	FROM
		(
			SELECT
				MAX(RN) OVER() cnt
				,*
			FROM cte
		) cte_row
	WHERE
		RN BETWEEN @start AND @end
END
GO
