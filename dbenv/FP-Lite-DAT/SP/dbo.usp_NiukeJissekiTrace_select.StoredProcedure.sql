IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_NiukeJissekiTrace_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_NiukeJissekiTrace_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\			�F�׎���уg���[�X��ʁ@����
�t�@�C����	�Fusp_NiukeJissekiTrace_select
���͈���		�F@chk_dt_yotei,@dt_yotei_st,@dt_yotei_en,
			  @chk_dt_jisseki,@dt_jisseki_st,@dt_jisseki_en,
			  @chk_cd_shokuba,@cd_shokuba,@chk_cd_line,
			  @cd_line,@chk_genryo,@genryoLot,
			  @chk_cd_genryo,@cd_genryo,@chk_cd_haigo,
			  @cd_haigo,@no_tonyu,@skip,@top,@isExcel
�o�͈���	�F	
�߂�l		�F
�쐬��		�F2014.01.16  ADMAX endo.y
�X�V��		�F2015.09.08  ADMAX taira.s
�X�V��		�F2015.10.06  MJ    ueno.k
�X�V��		�F2015.10.09  ADMAX taira.s
�X�V��		�F2016.03.31  Khang
�X�V��		�F2016.08.19  BRC motojima.m LB�Ή�
�X�V��		�F2017.01.26  BRC cho.k �T�|�[�gNo.1�Ή�
�X�V��		�F2020.02.28  wang�׎󂯎��уg���[�X��ʂɃo�b�`���Ɠ�������ǉ�
*****************************************************/
CREATE  PROCEDURE [dbo].[usp_NiukeJissekiTrace_select](
	@cd_hinmei			VARCHAR(14)	--��������/�i���R�[�h
	,@chk_dt_niuke		SMALLINT	--��������/�׎���`�F�b�N
	,@dt_niuke_st		DATETIME	--��������/�׎��(�J�n)
	,@dt_niuke_en		DATETIME	--��������/�׎��(�I��)
	,@chk_dt_seizo		SMALLINT	--��������/�����������`�F�b�N
	,@dt_seizo_st		DATETIME    --��������/����������(�J�n)
	,@dt_seizo_en		DATETIME	--��������/����������(�I��)
	,@chk_dt_kigen		SMALLINT	--��������/�ܖ��������`�F�b�N
	,@dt_kigen_st		DATETIME    --��������/�ܖ�������(�J�n)
	,@dt_kigen_en		DATETIME	--��������/�ܖ�������(�I��)
	,@chk_no_denpyo		SMALLINT	--��������/�`�[No�`�F�b�N
	,@no_denpyo			VARCHAR(30)	--��������/�`�[No
	,@chk_no_lot		SMALLINT	--��������/���b�gNo�`�F�b�N
	,@genryoLot			VARCHAR(14)	--��������/���b�gNo
	,@chk_cd_torihiki	SMALLINT	--��������/�����R�[�h�`�F�b�N
	,@cd_torihiki		VARCHAR(13)	--��������/�����R�[�h
	,@skip				DECIMAL(10)
	,@top				DECIMAL(10)
	,@isExcel			BIT
)
AS
BEGIN
    DECLARE  @start				DECIMAL(10)
    DECLARE  @end				DECIMAL(10)
	DECLARE  @true				BIT
	DECLARE  @false				BIT
	DECLARE  @day				SMALLINT
    SET      @start = @skip + 1
    SET      @end   = @skip + @top
    SET      @true  = 1
    SET      @false = 0
    SET		 @day   = 1

    BEGIN
		WITH cte AS
		(
			SELECT
				*
				,ROW_NUMBER() OVER (ORDER BY 
					uni.dt_niuke,
					uni.dt_kigen,
					uni.no_lot,
					uni.dt_hyoryo_zan,
					uni.dt_kowake,
					uni.dt_shori
				) AS RN
			FROM
			(
				SELECT DISTINCT
					-- �׎���
					  tr.dt_niuke					AS dt_niuke				-- �׎��
					, tr.dt_seizo_genryo			AS dt_seizo_genryo		-- ����������
					, tr.dt_kigen					AS dt_kigen				-- �ܖ�������
					, tr.no_lot						AS no_lot				-- ���b�g�ԍ�
					, tr.no_denpyo					AS no_denpyo			-- �`�[�ԍ�
					, tr.cd_torihiki				AS cd_torihiki			-- �����R�[�h
					, mt.nm_torihiki				AS nm_torihiki			-- ����於
					-- ���i�v��
					, NULL							AS cd_seihin_keikaku	-- ���i�R�[�h
					, NULL							AS nm_seihin_keikaku	-- ���i��
					, NULL							AS dt_seizo_keikaku		-- ������
					, NULL							AS dt_shomi_keikaku		-- �ܖ�����
					, NULL							AS no_lot_hyoji_keikaku	-- �\�����b�gNo
					-- �������
					, tr.dt_kowake					AS dt_kowake			-- ������
					, tr.cd_seihin					AS cd_seihin			-- ���i�R�[�h
					, tr.nm_seihin					AS nm_seihin			-- ���i��
					, tr.cd_line_kowake				AS cd_line_kowake		-- �������C���R�[�h
					, mlk.nm_line					AS nm_line_kowake		-- �������C����
					,tr.su_kai						AS su_kai				-- �o�b�`��
					,tr.su_ko						AS su_ko				-- ������
					, tr.dt_seizo_kowake			AS dt_seizo_kowake		-- ������
					-- �������
					, tr.dt_shori					AS dt_shori				-- ������
					, tr.cd_line_tonyu				AS cd_line_tonyu		-- �������C���R�[�h
					, mlt.nm_line					AS nm_line_tonyu		-- �������C����
					-- �c���
					, tr.dt_hyoryo_zan				AS dt_hyoryo_zan		-- �c���ʓ�
					, tr.wt_jisseki					AS wt_jisseki			-- �c�d��
					, tani.nm_tani					AS nm_tani				-- �P�ʖ�
					, tr.flg_haki					AS flg_haki				-- �j��
				FROM 
				(
					SELECT
						-- �׎���
						  tn.dt_nonyu		AS dt_niuke					--�׎��
						, tn.dt_seizo		AS dt_seizo_genryo			--����������
						, tn.dt_kigen		AS dt_kigen					--�ܖ�������
						, tn.no_lot			AS no_lot					--���b�g�ԍ�
						, tn.no_denpyo		AS no_denpyo				--�`�[�ԍ�
						, tn.cd_torihiki	AS cd_torihiki				--�����R�[�h
						-- �������
						, tk.dt_kowake		AS dt_kowake				--������
						, tk.cd_seihin		AS cd_seihin				--���i�R�[�h
						, tk.nm_seihin		AS nm_seihin				--���i��
						, tk.cd_line		AS cd_line_kowake			--�������C���R�[�h
					    ,tk.su_kai			AS su_kai					-- �o�b�`��
					    ,tk.su_ko			AS su_ko					-- ������
						, tk.dt_seizo		AS dt_seizo_kowake			--������
						-- �������
						, ISNULL(tt1.dt_shori, tt2.dt_shori) AS dt_shori			--������
						, ISNULL(tt1.cd_line, tt2.cd_line) AS cd_line_tonyu			--�������C���R�[�h
						-- �c���
						, tzj.cd_hakari		AS cd_hakari				--���R�[�h
						, tzj.dt_hyoryo_zan AS dt_hyoryo_zan			--�c���ʓ�
						, tzj.wt_jisseki	AS wt_jisseki				--�c�d��
						, tzj.flg_haki		AS flg_haki					--�j��
					FROM 
					(
						SELECT * 
						FROM tr_niuke niuke
						WHERE 
							    niuke.no_seq = 1
							--�y���������z
							-- [�i���R�[�h]
						    AND niuke.cd_hinmei = @cd_hinmei
							-- [�׎��]
							AND 
							(
								(@chk_dt_niuke = @false) 
								OR (niuke.dt_nonyu >= @dt_niuke_st and niuke.dt_nonyu < DATEADD(DD,@day,@dt_niuke_en))
							)
							-- [����������]
							AND 
							(
								(@chk_dt_seizo = @false) 
								OR (niuke.dt_seizo >= @dt_seizo_st and niuke.dt_seizo < DATEADD(DD,@day,@dt_seizo_en))
							)
							-- [�ܖ�������]
							AND (
								(@chk_dt_kigen = @false) 
								OR (niuke.dt_kigen >= @dt_kigen_st and niuke.dt_kigen < DATEADD(DD,@day,@dt_kigen_en))
							)
							-- [���b�gNo]
							AND ((@chk_no_lot = @false) OR niuke.no_lot = @genryoLot)
							-- [�`�[No]
							AND ((@chk_no_denpyo = @false) OR niuke.no_denpyo = @no_denpyo)
							-- [�����R�[�h]
							AND ((@chk_cd_torihiki = @false) OR niuke.cd_torihiki = @cd_torihiki)
					) tn	

					-- �������b�g���уg����
					LEFT OUTER JOIN 
					(
						SELECT 
							tl1.no_lot
							,tl1.no_lot_jisseki
							,tkn.old_no_lot
							,tk1.cd_hinmei AS cd_hinmei_kowake
							,tzj1.cd_hinmei AS cd_hinmei_zan
							,tl1.dt_shomi
							,tl1.dt_seizo_genryo
						FROM tr_lot tl1

						LEFT OUTER JOIN  tr_kongo_nisugata tkn
							ON tl1.no_lot = tkn.no_lot
						LEFT OUTER JOIN  tr_kowake tk1
							ON tl1.no_lot_jisseki = tk1.no_lot_kowake
						LEFT OUTER JOIN  tr_zan_jiseki tzj1
							ON  tl1.no_lot_jisseki = tzj1.no_lot_zan 
					) tl
					ON (tl.no_lot = tn.no_lot OR tl.old_no_lot = tn.no_lot)
					AND (tl.cd_hinmei_kowake = tn.cd_hinmei OR tl.cd_hinmei_zan = tn.cd_hinmei)
					AND tl.dt_shomi = tn.dt_kigen

					-- �������уg����
					LEFT OUTER JOIN tr_kowake tk
						ON tk.no_lot_kowake = tl.no_lot_jisseki

					-- �c���уg����
					LEFT OUTER JOIN tr_zan_jiseki tzj
						ON tl.no_lot_jisseki = tzj.no_lot_zan
					
					-- �����g�����i���������x���ǂݍ��݁j
					LEFT OUTER JOIN tr_tonyu tt1
						--ON tt1.dt_seizo = tk.dt_seizo
						ON tt1.cd_hinmei = tk.cd_hinmei
						AND tt1.su_kai = tk.su_kai
						AND tt1.no_tonyu = tk.no_tonyu
						AND tt1.no_kotei = tk.no_kotei
						AND tt1.no_lot_seihin = tk.no_lot_seihin
						AND tt1.su_ko_label = tk.su_ko
						AND tt1.cd_line = tk.cd_line
						AND tt1.dt_shori = tk.dt_tonyu
						AND tt1.kbn_seikihasu = tk.kbn_seikihasu
					
					-- �����g�����i�׎p���x���ǂݍ��݁j
					LEFT OUTER JOIN tr_tonyu tt2
						ON tt2.no_lot = tn.no_lot
						AND tt2.cd_hinmei = tn.cd_hinmei
						--AND tt2.dt_shomi = tn.dt_kigen
			) tr
			
			---- �����}�X�^
			LEFT OUTER JOIN ma_torihiki mt
				ON mt.cd_torihiki = tr.cd_torihiki
			
			---- ���}�X�^
			LEFT OUTER JOIN  ma_hakari hakari
				ON hakari.cd_hakari = tr.cd_hakari

			---- �P�ʃ}�X�^
			LEFT OUTER JOIN ma_tani tani
				ON tani.cd_tani = hakari.cd_tani
			
			
			---- ���C���}�X�^�i�����j
			LEFT OUTER JOIN ma_line mlk
				ON mlk.cd_line = tr.cd_line_kowake

			---- ���C���}�X�^�i�����j
			LEFT OUTER JOIN ma_line mlt
				ON mlt.cd_line = tr.cd_line_tonyu
			
		/* -- �� 2017.01.12 �T�|�[�g�Ή��ɂ��폜 �� --
				SELECT
					--�׎���
					tn.dt_nonyu AS dt_niuke					--�׎��
					--tn.dt_niuke AS dt_niuke
					,tn.dt_seizo AS dt_seizo_genryo			--����������
					,tn.dt_kigen AS dt_kigen				--�ܖ�������
					,tn.no_lot AS no_lot					--���b�g�ԍ�
					,tn.no_denpyo AS no_denpyo				--�`�[�ԍ�
					,tn.cd_torihiki AS cd_torihiki			--�����R�[�h
					,mt.nm_torihiki AS nm_torihiki			--����於
					--���i�v��
					,NULL AS cd_seihin_keikaku				--���i�R�[�h
					,NULL AS nm_seihin_keikaku				--���i��
					,NULL AS dt_seizo_keikaku				--������
					,NULL AS dt_shomi_keikaku				--�ܖ�����
					,NULL AS no_lot_hyoji_keikaku			--�\�����b�gNo
					--�������
					,tk.dt_kowake AS dt_kowake				--������
					,tk.cd_seihin AS cd_seihin				--���i�R�[�h
					,tk.nm_seihin AS nm_seihin				--���i��
					,tk.cd_line AS cd_line_kowake			--�������C���R�[�h
					,mlk.nm_line AS nm_line_kowake			--�������C����
					,tk.dt_seizo AS dt_seizo_kowake			--������
					--�������
					--,tt.dt_shori AS dt_shori
					--,tt.cd_line AS cd_line_tonyu
					--,mlt.nm_line AS nm_line_tonyu
					,tt.dt_shori AS dt_shori				--������
					,tt.cd_line AS cd_line_tonyu			--�������C���R�[�h
					,mlt.nm_line AS nm_line_tonyu			--�������C����
					--�c���
					,tzj.dt_hyoryo_zan AS dt_hyoryo_zan		--�c���ʓ�
					,tzj.wt_jisseki AS wt_jisseki			--�c�d��
					,tani.nm_tani							--�P�ʖ�
					,tzj.flg_haki AS flg_haki				--�j��
					--,tt.no_lot_seihin AS '���i���b�g'
				FROM tr_niuke tn
					--�����}�X�^
					LEFT OUTER JOIN ma_torihiki mt
					ON mt.cd_torihiki = tn.cd_torihiki

					--�������b�g���уg����
					LEFT OUTER JOIN 
					(
						SELECT 
							tl1.no_lot
							,tl1.no_lot_jisseki
							,tkn.old_no_lot
							,tk1.cd_hinmei AS cd_hinmei_kowake
							,tzj1.cd_hinmei AS cd_hinmei_zan
							,tl1.dt_shomi
							,tl1.dt_seizo_genryo
						FROM tr_lot tl1

						--LEFT OUTER JOIN  tr_zan_jiseki tzj
						--ON tzj.no_lot_zan = tl1.no_lot_jisseki

						LEFT OUTER JOIN  tr_kongo_nisugata tkn
						--on tl1.no_lot_jisseki = tkn.no_lot_jisseki
						ON tl1.no_lot = tkn.no_lot
						LEFT OUTER JOIN  tr_kowake tk1
						ON tl1.no_lot_jisseki = tk1.no_lot_kowake
						LEFT OUTER JOIN  tr_zan_jiseki tzj1
						ON  tl1.no_lot_jisseki = tzj1.no_lot_zan 
					) tl
					ON (tl.no_lot = tn.no_lot OR tl.old_no_lot = tn.no_lot)
					AND (tl.cd_hinmei_kowake = tn.cd_hinmei OR tl.cd_hinmei_zan = tn.cd_hinmei)
					AND tl.dt_shomi = tn.dt_kigen
					AND tl.dt_seizo_genryo = tn.dt_seizo

					--�������уg����
					LEFT OUTER JOIN tr_kowake tk
					ON tk.no_lot_kowake = tl.no_lot_jisseki

					--�c���уg����
					LEFT OUTER JOIN tr_zan_jiseki tzj
					ON tl.no_lot_jisseki = tzj.no_lot_zan
					
					----���}�X�^
					LEFT OUTER JOIN  ma_hakari hakari
					ON tzj.cd_hakari = hakari.cd_hakari

					----�P�ʃ}�X�^
					LEFT OUTER JOIN ma_tani tani
					ON hakari.cd_tani = tani.cd_tani
					
					--�����g����
					LEFT OUTER JOIN tr_tonyu tt
					ON tt.no_lot_seihin = tk.no_lot_seihin
					AND tt.no_kotei = tk.no_kotei
					AND tt.su_kai = tk.su_kai
					AND tt.dt_shori = tk.dt_tonyu
					
					--���C���}�X�^�i�����j
					LEFT OUTER JOIN ma_line mlk
					ON mlk.cd_line = tk.cd_line

					----���C���}�X�^�i�����j
					LEFT OUTER JOIN ma_line mlt
					ON mlt.cd_line = tt.cd_line

				WHERE tn.cd_hinmei = @cd_hinmei
				--�׎���ѓ�������������
				AND 
				(
					(@chk_dt_niuke = @false) 
					OR (tn.dt_nonyu >= @dt_niuke_st and tn.dt_nonyu < DATEADD(DD,@day,@dt_niuke_en))
				)
				--AND 
				--(
				--	(@chk_dt_niuke = @false) 
				--	OR (tn.dt_niuke >= @dt_niuke_st and tn.dt_niuke < DATEADD(DD,@day,@dt_niuke_en))
				--)
				AND 
				(
					(@chk_dt_seizo = @false) 
					OR (tn.dt_seizo >= @dt_seizo_st and tn.dt_seizo < DATEADD(DD,@day,@dt_seizo_en))
				)
				AND (
					(@chk_dt_kigen = @false) 
					OR (tn.dt_kigen >= @dt_kigen_st and tn.dt_kigen < DATEADD(DD,@day,@dt_kigen_en))
				)
				AND ((@chk_no_denpyo = @false) OR tn.no_denpyo = @no_denpyo)
				AND ((@chk_no_lot = @false) OR tn.no_lot = @genryoLot)
				AND ((@chk_cd_torihiki = @false) OR tn.cd_torihiki = @cd_torihiki)
				AND tn.no_seq = 1
					
				UNION ALL

				SELECT
					--�׎���
					tn2.dt_nonyu AS dt_niuke				--�׎��
					,tn2.dt_seizo AS dt_seizo_genryo		--����������
					,tn2.dt_kigen AS dt_kigen				--�ܖ�������
					,tn2.no_lot AS no_lot					--���b�g�ԍ�
					,tn2.no_denpyo AS no_denpyo				--�`�[�ԍ�
					,tn2.cd_torihiki AS cd_torihiki			--�����R�[�h
					,mt2.nm_torihiki AS nm_torihiki			--����於
					--���i�v��
					,NULL AS cd_seihin_keikaku				--���i�R�[�h
					,NULL AS nm_seihin_keikaku				--���i��
					,NULL AS dt_seizo_keikaku				--������
					,NULL AS dt_shomi_keikaku				--�ܖ�����
					,NULL AS no_lot_hyoji_keikaku			--�\�����b�gNo
					--�������
					,NULL AS dt_kowake						--������
					,NULL AS cd_seihin						--���i�R�[�h
					,NULL AS nm_seihin						--���i��
					,NULL AS cd_line_kowake					--�������C���R�[�h
					,NULL AS nm_line_kowake					--�������C����
					,NULL AS dt_seizo_kowake				--������
					--�������
					,tt2.dt_shori AS dt_shori				--������
					,tt2.cd_line AS cd_line_tonyu			--�������C���R�[�h
					,mlt2.nm_line AS nm_line_tonyu			--�������C����
					--�c���
					,NULL AS dt_hyoryo_zan					--�c���ʓ�
					,NULL AS wt_jisseki						--�c�d��
					,NULL AS nm_tani						--�P�ʖ�
					,NULL AS flg_haki						--�j��
				FROM tr_niuke tn2
					--�����}�X�^
					LEFT OUTER JOIN ma_torihiki mt2
					ON mt2.cd_torihiki = tn2.cd_torihiki
					--�����}�X�^�i�������Ȃ��j
					LEFT OUTER JOIN tr_tonyu tt2
					ON tn2.no_lot = tt2.no_lot
					AND tn2.cd_hinmei = tt2.cd_hinmei
					AND tn2.dt_kigen = tt2.dt_shomi
					--���C���}�X�^�i�������Ȃ��j
					LEFT OUTER JOIN ma_line mlt2
					ON mlt2.cd_line = tt2.cd_line
				WHERE tn2.cd_hinmei = @cd_hinmei
				--�׎���ѓ�������������
				AND 
				(
					(@chk_dt_niuke = @false) 
					OR (tn2.dt_nonyu >= @dt_niuke_st and tn2.dt_nonyu < DATEADD(DD,@day,@dt_niuke_en))
				)
				AND 
				(
					(@chk_dt_seizo = @false) 
					OR (tn2.dt_seizo >= @dt_seizo_st and tn2.dt_seizo < DATEADD(DD,@day,@dt_seizo_en))
				)
				AND 
				(
					(@chk_dt_kigen = @false) 
					OR (tn2.dt_kigen >= @dt_kigen_st and tn2.dt_kigen < DATEADD(DD,@day,@dt_kigen_en))
				)
				AND ((@chk_no_denpyo = @false) OR tn2.no_denpyo = @no_denpyo)
				AND ((@chk_no_lot = @false) OR tn2.no_lot = @genryoLot)
				AND ((@chk_cd_torihiki = @false) OR tn2.cd_torihiki = @cd_torihiki)
				AND tn2.no_seq = 1
				AND tt2.dt_shori IS NOT NULL
				-- �� 2017.01.12 �T�|�[�g�Ή��ɂ��폜 �� -- */
			) uni
		)

		-- ��ʂɕԋp����l���擾
		SELECT
			cnt
			,cte_row.dt_niuke
			,cte_row.dt_seizo_genryo
			,cte_row.dt_kigen
			,cte_row.no_lot
			,cte_row.no_denpyo
			,cte_row.cd_torihiki
			,cte_row.nm_torihiki
			,cte_row.cd_seihin_keikaku
			,cte_row.nm_seihin_keikaku
			,cte_row.dt_seizo_keikaku
			,cte_row.dt_shomi_keikaku
			,cte_row.no_lot_hyoji_keikaku
			,cte_row.dt_kowake
			,cte_row.cd_seihin
			,cte_row.nm_seihin
			,cte_row.cd_line_kowake
			,cte_row.nm_line_kowake
			,cte_row.su_kai
			,cte_row.su_ko
			,cte_row.dt_seizo_kowake
			,cte_row.dt_shori
			,cte_row.cd_line_tonyu
			,cte_row.nm_line_tonyu
			,cte_row.dt_hyoryo_zan
			,cte_row.wt_jisseki
			,cte_row.nm_tani
			,cte_row.flg_haki
		FROM
		(
			SELECT 
				MAX(RN) OVER() cnt
				,*
			FROM
				cte 
		) cte_row
		WHERE
		( 
			(
				@isExcel = @false
				AND RN BETWEEN @start AND @end
			)
			OR 
			(
				@isExcel = @true
			)
		)
	END
END

GO