IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_GenryozanIchiran_KowakeKanri_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_GenryozanIchiran_KowakeKanri_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\		�F�����c�ꗗ��� ����
�t�@�C����	�Fusp_GenryozanIchiran_KowakeKanri_select
���͈���	�F@cd_shokuba, @dt_hyoryo_zan, @chk_zenzan, @chk_shukei
			  , @chk_ari, @chk_nashi, @haki_flg, @taishogaiHakiFlg
			  , @taishoHakiFlg, @shiyoMishiyoFlg, @kigengireKigenFlg
			  , @chokuzenKigenFlg, @chikaiKigenFlg, @yoyuKigenFlg
			  , @kigen_chikai, @kigen_chokuzen, @skip, @top, @isExcel
			  , @dt_utc
�o�͈���	�F
�߂�l		�F������[0] ���s��[0�ȊO�̃G���[�R�[�h]
�쐬��		�F2013.10.02 ADMAX onodera.s
�X�V��      �F2015.10.05 ADMAX taira.s		�ܖ������������������O�Ƃ���悤�ɏC��
�X�V��      �F2016.08.24 BRC	ieki.h		LB�Ή�
�X�V��      �F2017.02.15 BRC	kanehira.d	�T�|�[�gNo.30
�X�V��      �F2017.06.12 BRC	matsumura.y	�E�ꂪ�I������Ă��Ȃ��ꍇ�ɑS�E�ꌟ�������悤���ԋp�l�ɐE�ꖼ���܂߂�悤�ɏC��
�X�V��      �F2018.02.26 BRC	yokota.t	�𓀃��x���Ή�
*****************************************************/
CREATE PROCEDURE [dbo].[usp_GenryozanIchiran_KowakeKanri_select] 
	@cd_shokuba			VARCHAR(10)    --�E��R�[�h
	,@dt_hyoryo_zan		DATETIME      --�c���ʓ�
	,@chk_zenzan		SMALLINT      --�S�����c�`�F�b�N
	,@chk_shukei		SMALLINT      --�W�v�`�F�b�N
	,@chk_ari			SMALLINT      --�`�F�b�N�L
	,@chk_nashi			SMALLINT      --�`�F�b�N��
	,@haki_flg			SMALLINT      --�j���t���O�i���W�I�{�^���j
	,@taishogaiHakiFlg	SMALLINT      --�j���t���O�i�j���ΏۊO�j
	,@taishoHakiFlg		SMALLINT      --�j���t���O�i�j���Ώہj
	,@shiyoMishiyoFlg	SMALLINT      --���g�p�t���O�i�g�p�j
	,@kigengireKigenFlg	SMALLINT      --�����t���O�i�����؂�j
	,@chokuzenKigenFlg	SMALLINT      --�����t���O�i�����؂꒼�O�j
	,@chikaiKigenFlg	SMALLINT      --�����t���O�i�����؂�߂��j
	,@yoyuKigenFlg		SMALLINT      --�����t���O�i�����؂�]�T����j
	,@kigen_chikai		DECIMAL       --�����؂�߂������i�H��}�X�^���擾�j
	,@kigen_chokuzen	DECIMAL       --�����؂꒼�O�����i�H��}�X�^���擾�j
	,@skip				DECIMAL(10)   --�Ǎ��J�n�ʒu
	,@top				DECIMAL(10)   --��ʕ\������
	,@isExcel			BIT           --Excel�o�͗p
	,@dt_utc			DATETIME	  -- �V�X�e���u�N�����v��UTC���� EX)���{�Fyyyy/MM/dd 15:00:00.000
	,@kbnKaito			SMALLINT      --�𓀃��x���敪
	,@kbnKaitoZan       SMALLINT      --�𓀎c���x���敪
AS
    DECLARE @start	DECIMAL(10)
    DECLARE @end	DECIMAL(10)
	DECLARE @true	BIT
	DECLARE @false	BIT
	DECLARE @day	SMALLINT
    SET		@start	= @skip + 1
    SET		@end	= @skip + @top
    SET		@true	= 1
    SET		@false	= 0
    SET		@day	= 1

	-- �u�W�v�v�`�F�b�N�{�b�N�X�Ƀ`�F�b�N������ꍇ�A��𖄂߂邽�߂̕ϐ��ƒl
	DECLARE @datetime	DATETIME
	DECLARE	@wt_zero	DECIMAL
	DECLARE	@zeroFlg	SMALLINT
	SET		@datetime	= ''
	SET		@wt_zero	= 0.00
	SET		@zeroFlg	= 0

BEGIN
	-- �W�v�Ȃ�
	IF	@chk_shukei = @chk_nashi
	BEGIN
		WITH cte AS
			(
				SELECT	-- �\������
					 ISNULL(TZ.cd_hinmei,'') AS cd_hinmei
					,ISNULL(TZ.nm_hinmei,'') AS nm_hinmei_ja
					,ISNULL(TZ.nm_hinmei,'') AS nm_hinmei_en
					,ISNULL(TZ.nm_hinmei,'') AS nm_hinmei_zh
					,ISNULL(TZ.nm_hinmei,'') AS nm_hinmei_vi
					--,ISNULL(TZ.no_lot,0) AS no_lot
					,CASE 
						WHEN TZ.no_lot = TZ.tkn_no_lot THEN ISNULL(TZ.tkn_old_no_lot,0)
						ELSE ISNULL(TZ.no_lot,0)
					 END AS no_lot
					,ISNULL(TZ.wt_jisseki,0) AS wt_jisseki
					,ISNULL(TZ.wt_jisseki_futai,0) AS wt_jisseki_futai
					,ISNULL(TZ.nm_tani,'') AS nm_tani
					,ISNULL(TZ.cd_panel,'') AS cd_panel
					,ISNULL(TZ.nm_tanto,'') AS nm_tanto
					,ISNULL(TZ.dt_hyoryo_zan,'') AS dt_hyoryo_zan		-- �c���ʓ�
					,ISNULL(TZ.dt_hyoryo_zan,'') AS tm_hyoryo_zan		-- ��������
					,ISNULL(TZ.dt_shiyo,'') AS dt_shiyo					-- �J����ܖ�����
					,ISNULL(TZ.dt_kigen,'') AS dt_kigen					-- �ܖ�����
					,ISNULL(TZ.dt_shomi_kaito,'') AS dt_shomi_kaito		-- �𓀌�ܖ�����
					,ISNULL(TZ.nm_torihiki,'') AS nm_torihiki
					,ISNULL(TZ.flg_mikaifu,0) AS flg_mikaifu
					,ISNULL(TZ.flg_haki,0) AS flg_haki
					,ISNULL(TZ.nm_shokuba, '') AS nm_shokuba
					-- ��\������
					,TZ.no_lot_zan
					,CASE
						-- �g�p�����؂�
						WHEN TZ.dt_shiyo < @dt_utc THEN @kigengireKigenFlg						
						-- �g�p�������O
						WHEN TZ.dt_shiyo >=  @dt_utc
						AND TZ.dt_shiyo < DATEADD(DAY,@kigen_chokuzen + 1, @dt_utc) THEN @chokuzenKigenFlg						
						-- �g�p�����߂�
						WHEN TZ.dt_shiyo >=  DATEADD(DAY,@kigen_chokuzen + 1, @dt_utc)
						AND TZ.dt_shiyo < DATEADD(DAY,@kigen_chikai + 1, @dt_utc) THEN @chikaiKigenFlg
						-- �g�p�����܂ŗ]�T����
						ELSE @yoyuKigenFlg
					END AS kigen
					,TZ.kbn_label
					 -- ���ёւ�����
					,ROW_NUMBER() OVER (ORDER BY TZ.cd_hinmei,TZ.cd_shokuba,TZ.dt_shiyo) AS RN
				FROM
					(
						SELECT
							tzj.cd_hinmei
							,tzj.nm_hinmei
							,tl.no_lot
							,tzj.wt_jisseki
							,tzj.wt_jisseki_futai
							,tani.nm_tani
							,tzj.cd_panel
							,mta.nm_tanto
							,tzj.dt_hyoryo_zan
							--,tzj.dt_kigen
							,tl.dt_shomi AS dt_kigen
							,mt.nm_torihiki
							,tzj.flg_mikaifu
							,tzj.flg_haki
							,tzj.no_lot_zan
							,mp.cd_shokuba
							,msh.nm_shokuba
							,CASE
								-- �𓀃��x���܂��͉𓀎c���x���̏ꍇ
								WHEN tzj.kbn_label = @kbnKaito OR tzj.kbn_label = @kbnKaitoZan THEN tl.dt_shomi_kaito
								--WHEN tzj.dt_kigen < tl.dt_shomi_kaifu THEN tzj.dt_kigen
								--WHEN tzj.dt_kigen >= tl.dt_shomi_kaifu THEN tl.dt_shomi_kaifu
								WHEN tl.dt_shomi < tl.dt_shomi_kaifu THEN tl.dt_shomi
								WHEN tl.dt_shomi >= tl.dt_shomi_kaifu THEN tl.dt_shomi_kaifu
							END AS dt_shiyo
							,tl.dt_shomi_kaito
							,tkn.no_lot AS tkn_no_lot
							,tkn.old_no_lot AS tkn_old_no_lot
							,tzj.kbn_label AS kbn_label
						FROM tr_zan_jiseki tzj
						LEFT OUTER JOIN ma_torihiki mt
						ON tzj.cd_maker = mt.cd_torihiki
						AND mt.flg_mishiyo = @shiyoMishiyoFlg
						LEFT OUTER JOIN ma_tanto mta
						ON tzj.cd_tanto = mta.cd_tanto
						AND mta.flg_mishiyo = @shiyoMishiyoFlg
						LEFT OUTER JOIN tr_lot tl
						ON tzj.no_lot_zan = tl.no_lot_jisseki
						LEFT OUTER JOIN tr_kongo_nisugata tkn
						ON tzj.no_lot_zan = tkn.no_lot_jisseki
						AND tl.no_lot = tkn.no_lot
						LEFT JOIN ma_panel mp
						ON tzj.cd_panel = mp.cd_panel
						AND mp.flg_mishiyo = @shiyoMishiyoFlg
						LEFT OUTER JOIN  ma_hakari hakari
						ON tzj.cd_hakari = hakari.cd_hakari
						LEFT OUTER JOIN ma_tani tani
						ON hakari.cd_tani = tani.cd_tani
						LEFT JOIN ma_shokuba msh
						ON mp.cd_shokuba = msh.cd_shokuba
					) TZ
				WHERE
					--TZ.cd_shokuba = @cd_shokuba
					(@cd_shokuba IS NULL OR TZ.cd_shokuba = @cd_shokuba)
					AND ((@chk_zenzan = @chk_ari) -- �S�����c�`�F�b�N
					OR (@dt_hyoryo_zan <= TZ.dt_hyoryo_zan
					AND TZ.dt_hyoryo_zan < (SELECT DATEADD(DD,@day,@dt_hyoryo_zan))))
					AND ((@haki_flg = @chk_ari)	-- �j���t���O�`�F�b�N
					OR (TZ.flg_haki = @taishogaiHakiFlg))
			)
		SELECT
			cnt
			-- �\������
			,cte_row.cd_hinmei
			,cte_row.nm_hinmei_ja
			,cte_row.nm_hinmei_en
			,cte_row.nm_hinmei_zh
			,cte_row.nm_hinmei_vi
			,cte_row.no_lot
			,cte_row.wt_jisseki
			,cte_row.wt_jisseki_futai
			,cte_row.nm_tani
			,cte_row.cd_panel
			,cte_row.nm_tanto
			,cte_row.dt_hyoryo_zan
			,cte_row.tm_hyoryo_zan
			,cte_row.dt_shiyo
			,cte_row.dt_kigen
			,cte_row.dt_shomi_kaito
			,cte_row.nm_torihiki
			,cte_row.flg_mikaifu
			,cte_row.flg_haki
			,cte_row.nm_shokuba
			-- ��\������
			,cte_row.no_lot_zan
			,cte_row.kigen
			,cte_row.kbn_label
		FROM
			(
				SELECT
					MAX(RN) OVER() AS cnt
					,*
				FROM cte
			) cte_row
		WHERE
			(
				(
					@isExcel = @false
					AND RN BETWEEN @start AND @end
				)
				OR @isExcel = @true
			)
	END -- �W�v����
	ELSE IF @chk_shukei = @chk_ari
	BEGIN
		WITH cte AS
			(
				SELECT	-- �\������
					 ISNULL(TZ_shukei.cd_hinmei,'') AS cd_hinmei
					,ISNULL(TZ_shukei.nm_hinmei_ja,'') AS nm_hinmei_ja
					,ISNULL(TZ_shukei.nm_hinmei_en,'') AS nm_hinmei_en
					,ISNULL(TZ_shukei.nm_hinmei_zh,'') AS nm_hinmei_zh
					,ISNULL(TZ_shukei.nm_hinmei_vi,'') AS nm_hinmei_vi
					,SUM(TZ_shukei.wt_jisseki) AS wt_jisseki
					,ISNULL(TZ_shukei.nm_tani,'') AS nm_tani
					,ISNULL(TZ_shukei.flg_haki,0) AS flg_haki
					,ISNULL(TZ_shukei.nm_shokuba, '') AS nm_shokuba
					-- ��\������
					,ISNULL(TZ_shukei.kigen,'') AS kigen
					-- �u''�v�͕����^�ƍ��킹�邽�߂̋�ӏ�
					,'' AS no_lot
					,@wt_zero AS wt_jisseki_futai
					,'' AS cd_panel
					,'' AS nm_tanto
					,@datetime AS dt_hyoryo_zan
					,@datetime AS tm_hyoryo_zan
					,@datetime AS dt_shiyo
					,@datetime AS dt_kigen
					,@datetime AS dt_shomi_kaito
					,'' AS nm_torihiki
					,@zeroFlg AS flg_mikaifu
					,'' AS no_lot_zan
					,@zeroFlg AS kbn_label
					-- ���ёւ�����
					,ROW_NUMBER() OVER (ORDER BY TZ_shukei.cd_hinmei, TZ_shukei.cd_shokuba) AS RN
				FROM
					(
						SELECT
							TZ.cd_hinmei
							,CASE
								-- �d�|�c�̏ꍇ
								WHEN TZ.kbn_label = 5 THEN 
									-- �z���}�X�^�ɓo�^���Ȃ��ꍇ�͎c���уg�����̔z�������擾
									(CASE 
										WHEN TZ.haigoCode IS NOT NULL THEN TZ.nm_haigo_ja ELSE TZ.nm_hinmei
									END)
								-- �����c�̏ꍇ
								ELSE
									-- �i���}�X�^�ɓo�^���Ȃ��ꍇ�͎c���уg�����̕i�����擾 
									(CASE 
										WHEN TZ.hinCode IS NOT NULL THEN TZ.nm_hinmei_ja ELSE TZ.nm_hinmei
									END) 
							END AS nm_hinmei_ja
							,CASE
								 -- �d�|�c�̏ꍇ
								WHEN TZ.kbn_label = 5 THEN 
									(CASE 
										WHEN TZ.haigoCode IS NOT NULL THEN TZ.nm_haigo_en ELSE TZ.nm_hinmei
									END)
								-- �����c�̏ꍇ
								ELSE 
									(CASE 
										WHEN TZ.hinCode IS NOT NULL THEN TZ.nm_hinmei_en ELSE TZ.nm_hinmei
									END) 
							END AS nm_hinmei_en
							,CASE
								-- �d�|�c�̏ꍇ
								WHEN TZ.kbn_label = 5 THEN 
									(CASE 
										WHEN TZ.haigoCode IS NOT NULL THEN TZ.nm_haigo_zh ELSE TZ.nm_hinmei
									END) 
								-- �����c�̏ꍇ
								ELSE
									(CASE 
										WHEN TZ.hinCode IS NOT NULL THEN TZ.nm_hinmei_zh ELSE TZ.nm_hinmei
									END)  
							END AS nm_hinmei_zh
							,CASE
								 -- �d�|�c�̏ꍇ
								WHEN TZ.kbn_label = 5 THEN 
									(CASE 
										WHEN TZ.haigoCode IS NOT NULL THEN TZ.nm_haigo_vi ELSE TZ.nm_hinmei
									END)
								-- �����c�̏ꍇ
								ELSE 
									(CASE 
										WHEN TZ.hinCode IS NOT NULL THEN TZ.nm_hinmei_vi ELSE TZ.nm_hinmei
									END) 
							END AS nm_hinmei_vi
							,TZ.wt_jisseki
							,TZ.nm_tani
							,TZ.cd_shokuba
							,TZ.nm_shokuba
							,TZ.flg_haki
							,CASE
								-- �g�p�����؂�
								WHEN TZ.dt_shiyo < @dt_utc THEN @kigengireKigenFlg
								-- �g�p�������O
								WHEN TZ.dt_shiyo >=  @dt_utc
								AND TZ.dt_shiyo < DATEADD(DAY,@kigen_chokuzen + 1, @dt_utc) THEN @chokuzenKigenFlg
								-- �g�p�����߂�
								WHEN TZ.dt_shiyo >=  DATEADD(DAY,@kigen_chokuzen + 1, @dt_utc)
								AND TZ.dt_shiyo < DATEADD(DAY,@kigen_chikai + 1, @dt_utc) THEN @chikaiKigenFlg
								-- �g�p�����܂ŗ]�T����
								ELSE @yoyuKigenFlg
							END AS kigen
						FROM
							(
								SELECT
									tzj.cd_hinmei
									,mh.cd_hinmei as hinCode
									,mhm.cd_haigo as haigoCode
									,mh.nm_hinmei_ja
									,mh.nm_hinmei_en
									,mh.nm_hinmei_zh
									,mh.nm_hinmei_vi
									,mhm.nm_haigo_ja
									,mhm.nm_haigo_en
									,mhm.nm_haigo_zh
									,mhm.nm_haigo_vi
									,tzj.nm_hinmei
									,tzj.wt_jisseki
									,tani.nm_tani
									,tzj.flg_haki
									,mp.cd_shokuba
									,msh.nm_shokuba 
									,tzj.dt_hyoryo_zan
									,tzj.kbn_label
									,CASE
										-- �𓀎c���x���̏ꍇ
										WHEN tzj.kbn_label = @kbnKaitoZan THEN tl.dt_shomi_kaito
										--WHEN tzj.dt_kigen < tl.dt_shomi_kaifu THEN tzj.dt_kigen
										--WHEN tzj.dt_kigen >= tl.dt_shomi_kaifu THEN tl.dt_shomi_kaifu
										WHEN tl.dt_shomi < tl.dt_shomi_kaifu THEN tl.dt_shomi
										WHEN tl.dt_shomi >= tl.dt_shomi_kaifu THEN tl.dt_shomi_kaifu
									 END AS dt_shiyo
								FROM tr_zan_jiseki tzj
								LEFT OUTER JOIN tr_lot tl
								ON tzj.no_lot_zan = tl.no_lot_jisseki
								LEFT OUTER JOIN ma_panel mp
								ON tzj.cd_panel = mp.cd_panel
								AND mp.flg_mishiyo = @shiyoMishiyoFlg
								LEFT OUTER JOIN ma_hinmei mh
								ON tzj.cd_hinmei = mh.cd_hinmei
								LEFT OUTER JOIN ma_haigo_mei mhm
								ON tzj.cd_hinmei = mhm.cd_haigo
								AND mhm.no_han = 1
								LEFT OUTER JOIN  ma_hakari hakari
								ON tzj.cd_hakari = hakari.cd_hakari
								LEFT OUTER JOIN ma_tani tani
								ON hakari.cd_tani = tani.cd_tani
								LEFT JOIN ma_shokuba msh
								ON mp.cd_shokuba = msh.cd_shokuba
							) TZ
						WHERE
							--TZ.cd_shokuba = @cd_shokuba
							(@cd_shokuba IS NULL OR TZ.cd_shokuba = @cd_shokuba)
							AND (	-- �S�����c�`�F�b�N
									(@chk_zenzan = @chk_ari)
									OR (
										@dt_hyoryo_zan <= TZ.dt_hyoryo_zan
										AND TZ.dt_hyoryo_zan <
											(
												SELECT DATEADD(DD,@day,@dt_hyoryo_zan)
											)
										)
							)
							AND (	-- �j���t���O�`�F�b�N
									(@haki_flg = @chk_ari)
									OR (TZ.flg_haki = @taishogaiHakiFlg)
								)
							AND kbn_label != @kbnKaito	-- �𓀃��x���敪�͏��O 
					) TZ_shukei
				GROUP BY
					TZ_shukei.cd_hinmei
					,TZ_shukei.nm_hinmei_ja
					,TZ_shukei.nm_hinmei_en
					,TZ_shukei.nm_hinmei_zh
					,TZ_shukei.nm_hinmei_vi
					,TZ_shukei.kigen
					,TZ_shukei.nm_tani
					,TZ_shukei.flg_haki
					,TZ_shukei.cd_shokuba
					,TZ_shukei.nm_shokuba
			)
		SELECT
			cnt
			-- �\������
			,cte_row.cd_hinmei
			,cte_row.nm_hinmei_ja
			,cte_row.nm_hinmei_en
			,cte_row.nm_hinmei_zh
			,cte_row.nm_hinmei_vi
			,cte_row.flg_haki
			,cte_row.nm_shokuba
			-- ��\������
			,cte_row.kigen
			-- �u''�v�u0�v�͕����^�ƍ��킹�邽�߂̋�ӏ�
			,cte_row.no_lot
			,cte_row.wt_jisseki
			,cte_row.wt_jisseki_futai
			,cte_row.nm_tani
			,cte_row.cd_panel
			,cte_row.nm_tanto
			,cte_row.dt_hyoryo_zan
			,cte_row.tm_hyoryo_zan
			,cte_row.dt_shiyo
			,cte_row.dt_kigen
			,cte_row.dt_shomi_kaito
			,cte_row.nm_torihiki
			,cte_row.flg_mikaifu
			,cte_row.no_lot_zan
			,cte_row.kbn_label
		FROM
			(
				SELECT
					MAX(RN) OVER() AS cnt
					,*
				FROM cte
			) cte_row
		WHERE
			(
				(
					@isExcel = @false
					AND RN BETWEEN @start AND @end
				)
				OR @isExcel = @true
			)
	END
END


GO