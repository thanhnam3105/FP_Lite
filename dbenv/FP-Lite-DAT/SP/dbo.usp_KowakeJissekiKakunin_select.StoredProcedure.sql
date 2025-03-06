IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_KowakeJissekiKakunin_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_KowakeJissekiKakunin_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\		�F�������ъm�F����
�t�@�C����	�Fusp_KowakeJissekiKakunin_select
���͈���	�F@cd_shokuba, @dt_kowake, @chk_shukei, @flg_haki
              , @mikanryoTonyuKanryoFlg, @kigengireKigenFlg
              , @chokuzenKigenFlg, @chikaiKigenFlg, @yoyuKigenFlg
              , @dt_kigen_chikai, @dt_kigen_chokuzen, @dt_utc
              , @skip, @top, @isExcel
�o�͈���	�F
�߂�l		�F
�쐬��		�F2013.10.03  ADMAX onodera.s
�X�V��		�F2016.08.22  BRC   ieki.h    LB�Ή�
�X�V��		�F2017.02.13  BRC   matsumura.y    QB�T�|�[�gNo.33�Ή�
�X�V��		�F2017.02.23  BRC   cho.k		�T�|�[�gNo.6�Ή��i���\���P�j
�X�V��		�F2018.02.26  BRC   yokota.t	�𓀃��x���Ή�
*****************************************************/
CREATE PROCEDURE [dbo].[usp_KowakeJissekiKakunin_select] 
	@cd_shokuba				    VARCHAR(10)		-- �E��R�[�h
	,@dt_kowake					DATETIME		-- ������(�����N�_����)
	,@chk_shukei				SMALLINT		-- ��������.�W�v�`�F�b�N�{�b�N�X
	,@flg_haki					SMALLINT		-- ��������.�j���\������/�Ȃ����W�I�{�^��
	,@mikanryoTonyuKanryoFlg	SMALLINT		-- ���������t���O.������
	,@kigengireKigenFlg			SMALLINT		-- �����t���O.�����؂�
	,@chokuzenKigenFlg			SMALLINT		-- �����t���O.���O
	,@chikaiKigenFlg			SMALLINT		-- �����t���O.�߂�
	,@yoyuKigenFlg				SMALLINT		-- �����t���O.�]�T
	,@dt_kigen_chikai			DECIMAL			-- �H��}�X�^.kigen_chikai
	,@dt_kigen_chokuzen			DECIMAL			-- �H��}�X�^.kigen_chokuzen
	,@dt_utc					DATETIME		-- �V�X�e���u�N�����v��UTC���� EX)���{�Fyyyy/MM/dd 15:00:00.000
	,@skip						DECIMAL(10)		-- �X�L�b�v
	,@top						DECIMAL(10)		-- �����f�[�^���
	,@isExcel					BIT				-- �G�N�Z���t���O
AS
BEGIN

	DECLARE @start	DECIMAL(10)
    DECLARE @end	DECIMAL(10)
    DECLARE @day	SMALLINT
	DECLARE @true	BIT
	DECLARE @false	BIT
    SET		@start	= @skip + 1
    SET		@end	= @skip + @top
    SET		@day	= 1
    SET		@true	= 1
    SET		@false	= 0

    DECLARE @su_keta_shosuten SMALLINT -- �z���d�ʂ̏����_�ȉ��̌���
    SET @su_keta_shosuten = (SELECT TOP 1 su_keta_shosuten FROM ma_kojo)

	DECLARE @datetime DATETIME				-- �u�W�v�v�`�F�b�N�{�b�N�X�Ƀ`�F�b�N������ꍇ�A��𖄂߂邽�߂̕ϐ��ƒl
	SET	    @datetime = '1979/01/01 00:00:00.000'

		-- �ꎞ�����g����
	DECLARE @tr_kowake_tmp TABLE
	(
		  no_lot_kowake			VARCHAR(14)			-- �������b�g�ԍ�
		, dt_kowake				DATETIME			-- ������
		, wt_jisseki			DECIMAL(18,6)		-- �����d��
		, dt_shomi				DATETIME			-- �ܖ�����
		, dt_shomi_kaifu		DATETIME			-- �J����ܖ�����
		, dt_shomi_kaito		DATETIME			-- �𓀌�ܖ����� 
		, dt_tonyu				DATETIME			-- ������
		, no_lot				VARCHAR(14)			-- ���b�g�ԍ�
		, no_lot_oya			VARCHAR(14)			-- �e���b�g�ԍ�
	)
	
	-- �ꎞ���b�g�g����
	DECLARE @tr_lot_tmp TABLE
	(
		  no_lot_kowake			VARCHAR(14)			-- �������b�g�ԍ�
		, no_lot				VARCHAR(4000)		-- �������b�g�ԍ�
	)
	
	-- �ꎞ�����g�����o�^
	INSERT INTO @tr_kowake_tmp
	SELECT
		  ISNULL(kowake.no_lot_oya, kowake.no_lot_kowake) AS no_lot_kowake
		, kowake.dt_kowake
		, kowake.wt_jisseki
		, kowake.dt_shomi
		, kowake.dt_shomi_kaifu
		, kowake.dt_shomi_kaito
		, kowake.dt_tonyu
		, lot.no_lot
		, kowake.no_lot_oya
	FROM tr_kowake kowake
	INNER JOIN tr_lot lot
		ON lot.no_lot_jisseki = kowake.no_lot_kowake
	WHERE kowake.dt_kowake >= @dt_kowake
	  AND kowake.dt_kowake < DATEADD(DAY,@day,@dt_kowake)
	  AND (
			@flg_haki = 0
			OR kowake.flg_kanryo_tonyu = @mikanryoTonyuKanryoFlg
		  )
	
	-- �ꎞ���b�g�g�����o�^
	INSERT INTO @tr_lot_tmp
	SELECT
		 kowake.no_lot_kowake
		,STUFF ((
				SELECT
					',' + lot.no_lot
				FROM
					(
						SELECT DISTINCT
						      tmp.no_lot_kowake
							, tmp.no_lot
						FROM @tr_kowake_tmp tmp
					) lot
				WHERE
					lot.no_lot_kowake = kowake.no_lot_kowake
				ORDER BY
					lot.no_lot_kowake
				FOR XML PATH('')),1,1,''
			) AS no_lot
	FROM @tr_kowake_tmp kowake
	GROUP BY
		kowake.no_lot_kowake
	
	-- �`�F�b�N�Ȃ�
	IF @chk_shukei = 0
	BEGIN
		WITH cte AS
			(
				SELECT
					  tk.dt_kowake
					, kowake.cd_hinmei
					, ISNULL(kowake.nm_hinmei,'') AS nm_hinmei
					, lot.no_lot
					, CASE
						WHEN hakari.cd_tani = 3 THEN ROUND(kowake.wt_haigo * 1000, @su_keta_shosuten, 1)
						ELSE ROUND(kowake.wt_haigo, @su_keta_shosuten, 1) 
					  END AS wt_haigo
					, CASE
						WHEN hakari.cd_tani = 3 THEN ROUND(tk.wt_jisseki * 1000, @su_keta_shosuten, 1)
						ELSE ROUND(tk.wt_jisseki, @su_keta_shosuten, 1) 
					  END AS wt_jisseki
					, tani.nm_tani
					, kowake.su_kai
					, kowake.su_ko
					, kowake.no_tonyu
					, kowake.no_kotei
					, ISNULL(kowake.nm_seihin, '') AS nm_seihin
					, line.nm_line
					, kowake.cd_panel
					, ISNULL(hakari.nm_hakari, '') AS nm_hakari
					, torihiki.nm_torihiki
					, ISNULL(tanto_kowake.nm_tanto, '') AS nm_tanto_kowake
					, kowake.dt_chikan
					, ISNULL(tanto_chikan.nm_tanto, '') AS nm_tanto_chikan
					, tk.dt_shomi
					, tk.dt_shomi_kaifu
					, tk.dt_shomi_kaito 
					, ISNULL(kowake.ritsu_kihon, 0.00) AS ritsu_kihon
					, kowake.dt_seizo
					, tk.dt_tonyu
					, kowake.flg_kanryo_tonyu
					, ISNULL(tk.no_lot_oya,'') AS no_lot_oya
					, tk.no_lot_kowake
					, CASE
						WHEN tk.dt_shomi_kaifu < @dt_utc THEN @kigengireKigenFlg
						WHEN tk.dt_shomi_kaifu >= @dt_utc AND tk.dt_shomi_kaifu < DATEADD(DAY,@dt_kigen_chokuzen,@dt_utc)
														 THEN @chokuzenKigenFlg
						WHEN tk.dt_shomi_kaifu >=  DATEADD(DAY,@dt_kigen_chokuzen,@dt_utc) AND tk.dt_shomi_kaifu < DATEADD(DAY,@dt_kigen_chikai,@dt_utc)
														 THEN @chikaiKigenFlg
						ELSE @yoyuKigenFlg
					  END AS kigen
					, kowake.kbn_hin
					, kbn_hin.nm_kbn_hin
					, ROW_NUMBER() OVER (ORDER BY kowake.kbn_hin, kowake.cd_hinmei, tk.dt_kowake) AS RN
				FROM (
					SELECT
						  tmp.no_lot_kowake
						, MAX(tmp.dt_kowake) AS dt_kowake
						, MIN(tmp.dt_kowake) AS dt_kowake_oya
						, SUM(tmp.wt_jisseki) AS wt_jisseki
						, MIN(tmp.dt_shomi) AS dt_shomi
						, MIN(tmp.dt_shomi_kaifu) AS dt_shomi_kaifu
						, MIN(tmp.dt_shomi_kaito) AS dt_shomi_kaito
						, MAX(tmp.dt_tonyu) AS dt_tonyu
						, MAX(tmp.no_lot_oya) AS no_lot_oya
					FROM @tr_kowake_tmp tmp
					GROUP BY tmp.no_lot_kowake
				) tk
				INNER JOIN tr_kowake kowake
					ON kowake.no_lot_kowake = tk.no_lot_kowake
					AND kowake.dt_kowake = tk.dt_kowake_oya
				INNER JOIN @tr_lot_tmp lot
					ON lot.no_lot_kowake = tk.no_lot_kowake
				-- ���}�X�^
				LEFT OUTER JOIN ma_hakari hakari
					ON hakari.cd_hakari = kowake.cd_hakari
				-- ���C���}�X�^
				LEFT OUTER JOIN ma_line line
					ON line.cd_line = kowake.cd_line
				-- �����}�X�^
				LEFT OUTER JOIN ma_torihiki torihiki
					ON torihiki.cd_torihiki = kowake.cd_maker
				-- �S���҃}�X�^�i�����S���ҁj
				LEFT OUTER JOIN ma_tanto tanto_kowake
					ON tanto_kowake.cd_tanto = kowake.cd_tanto_kowake
				-- �S���҃}�X�^�i�u���S���ҁj
				LEFT OUTER JOIN ma_tanto tanto_chikan
					ON tanto_chikan.cd_tanto = kowake.cd_tanto_chikan
				-- �p�l���}�X�^
				INNER JOIN ma_panel panel
					ON panel.cd_panel = kowake.cd_panel
					AND panel.cd_shokuba = @cd_shokuba
				-- �i�敪�}�X�^
				LEFT OUTER JOIN ma_kbn_hin kbn_hin
					ON kbn_hin.kbn_hin = kowake.kbn_hin
				-- �P�ʃ}�X�^
				LEFT OUTER JOIN ma_tani tani
					ON tani.cd_tani = hakari.cd_tani
-- ��2017/02/23 �T�|�[�gNo.6�Ή��i���\���P�j�ŃR�����g�A�E�g��
--				SELECT DISTINCT
--					--�\������
--					TK.dt_kowake
--					,TK.cd_hinmei
--					,ISNULL(TK.nm_hinmei, '') AS nm_hinmei
--					,TK.no_lot
--					--,TK.wt_haigo
--					,CASE --�z���d��(������@su_keta_shosuten�ʂ܂ŕ\���B�؎̂�
--					WHEN TK.cd_tani = '3' 
--					THEN ROUND(tk.wt_haigo * 1000, @su_keta_shosuten, 1) --g�ϊ�
--					ELSE ROUND(tk.wt_haigo, @su_keta_shosuten, 1) 
--					END AS wt_haigo
--					--,SUM(TK.wt_jisseki) AS wt_jisseki
--					,CASE --���ђl(������3�ʂ܂ŕ\���B�؎̂�
--					WHEN TK.cd_tani = '3' 
--					THEN ROUND(SUM(TK.wt_jisseki) * 1000, 3, 1) --g�ϊ�
--					ELSE ROUND(SUM(TK.wt_jisseki), 3, 1) 
--					END AS wt_jisseki
--					,TK.nm_tani
--					,TK.su_kai
--					,TK.su_ko
--					,TK.no_tonyu
--					,TK.no_kotei
--					,ISNULL(TK.nm_seihin, '') AS nm_seihin
--					,TK.nm_line
--					,TK.cd_panel
--					,ISNULL(TK.nm_hakari, '') AS nm_hakari
--					,TK.nm_torihiki
--					,ISNULL(TK.nm_tanto_kowake, '') AS nm_tanto_kowake
--					,TK.dt_chikan
--					,ISNULL(TK.nm_tanto_chikan, '') AS nm_tanto_chikan
--					,TK.dt_shomi
--					,TK.dt_shomi_kaifu
--					,TK.ritsu_kihon
--					,TK.dt_seizo
--					,TK.dt_tonyu
--					,TK.flg_kanryo_tonyu
--					--��\������
--					,ISNULL(TK.no_lot_oya, '') AS no_lot_oya
--					,ISNULL(TK.no_lot_oya,TK.no_lot_kowake) AS no_lot_kowake
--					,CASE
--						-- �g�p�����؂�
--						WHEN TK.dt_shomi_kaifu < @dt_utc THEN @kigengireKigenFlg
--						-- �g�p�������O
--						WHEN TK.dt_shomi_kaifu >= @dt_utc
--						AND TK.dt_shomi_kaifu < DATEADD(DAY,@dt_kigen_chokuzen,@dt_utc) THEN @chokuzenKigenFlg
--						-- �g�p�����߂�
--						WHEN TK.dt_shomi_kaifu >=  DATEADD(DAY,@dt_kigen_chokuzen,@dt_utc)
--						AND TK.dt_shomi_kaifu < DATEADD(DAY,@dt_kigen_chikai,@dt_utc) THEN @chikaiKigenFlg
--						-- �g�p�����܂ŗ]�T����
--						ELSE @yoyuKigenFlg
--					END AS kigen
--					,TK.kbn_hin
--					,TK.nm_kbn_hin
--					,ROW_NUMBER() OVER (ORDER BY TK.kbn_hin, TK.cd_hinmei, TK.dt_kowake) AS RN
--				FROM
--					(
--						SELECT
--							CASE
--								WHEN tk.no_lot_oya IS NOT NULL THEN tk_max.dt_kowake
--								ELSE tk.dt_kowake
--							END AS dt_kowake
--							,CASE
--								WHEN tk.no_lot_oya IS NOT NULL THEN tk_min_shomi.dt_shomi
--								ELSE tk.dt_shomi
--							END AS dt_shomi
--							,CASE
--								WHEN tk.no_lot_oya IS NOT NULL THEN tk_min_kaifu.dt_shomi_kaifu
--								ELSE tk.dt_shomi_kaifu
--							END AS dt_shomi_kaifu
--							,CASE
--								WHEN tk_comma.no_lot IS NOT NULL THEN tk_comma.no_lot
--								ELSE tl.no_lot	
--							 END AS no_lot
--							,tk.cd_hinmei
--							,tk.nm_hinmei
--							,tk.wt_haigo
--							,tk.wt_jisseki
--							,tani.cd_tani
--							,tani.nm_tani
--							,tk.su_kai
--							,tk.su_ko
--							,tk.no_tonyu
--							,tk.no_kotei
--							,tk.nm_seihin
--							,ml.nm_line
--							,mp.cd_panel
--							,mh.nm_hakari
--							,mt.nm_torihiki
--							,mtk.nm_tanto AS nm_tanto_kowake	-- �����S���Җ�
--							,tk.dt_chikan
--							,ISNULL(mtt.nm_tanto, '') AS nm_tanto_chikan	-- �u���S���Җ�
--							,ISNULL(tk.ritsu_kihon, 0.00) AS ritsu_kihon
--							,tk.dt_seizo
--							,ISNULL(tk.flg_kanryo_tonyu, 0) AS flg_kanryo_tonyu
--						    ,CASE
--							 WHEN tk.no_lot_oya IS NOT NULL THEN tk_max.dt_tonyu
--							 ELSE tk.dt_tonyu
--						     END AS dt_tonyu
--							,tk.no_lot_oya
--							,tk.no_lot_kowake
--							,hinKbnMas.kbn_hin
--							,hinKbnMas.nm_kbn_hin
--						FROM tr_kowake tk
--						INNER JOIN tr_lot tl
--						ON tk.no_lot_kowake = tl.no_lot_jisseki
--						LEFT OUTER JOIN ma_hakari mh
--						ON tk.cd_hakari = mh.cd_hakari
--						LEFT OUTER JOIN ma_line ml
--						ON tk.cd_line = ml.cd_line
--						LEFT OUTER JOIN ma_torihiki mt
--						ON tk.cd_maker = mt.cd_torihiki
--						LEFT OUTER JOIN ma_tanto mtk	-- �����S����
--						ON tk.cd_tanto_kowake = mtk.cd_tanto
--						LEFT OUTER JOIN ma_tanto mtt	-- �u���S����
--						ON tk.cd_tanto_chikan = mtt.cd_tanto
--						INNER JOIN ma_panel mp
--						ON tk.cd_panel = mp.cd_panel
--						AND mp.cd_shokuba = @cd_shokuba
--						LEFT OUTER JOIN
--							(
--								SELECT
--									MAX(tk.dt_kowake) AS dt_kowake
--									,tk.no_lot_oya
--									,tk.cd_hinmei
--									,MAX(tk.dt_tonyu) AS dt_tonyu
--									,tk.kbn_hin
--								FROM tr_kowake tk
--								GROUP BY
--									tk.no_lot_oya
--									,tk.cd_hinmei
--									,tk.kbn_hin
--							) tk_max
--						ON tk.no_lot_oya = tk_max.no_lot_oya
--						AND tk.cd_hinmei = tk_max.cd_hinmei
--						AND tk.kbn_hin = tk_max.kbn_hin
--						LEFT OUTER JOIN
--							(
--								SELECT
--									MIN(tk.dt_shomi) AS dt_shomi
--									,tk.no_lot_oya
--									,tk.cd_hinmei
--									,tk.kbn_hin
--								FROM tr_kowake tk
--								GROUP BY
--									tk.no_lot_oya
--									,tk.cd_hinmei
--									,tk.kbn_hin
--							) tk_min_shomi
--						ON tk.no_lot_oya = tk_min_shomi.no_lot_oya
--						AND tk.cd_hinmei = tk_min_shomi.cd_hinmei
--						AND tk.kbn_hin = tk_min_shomi.kbn_hin
--						LEFT OUTER JOIN
--							(
--								SELECT
--									MIN(tk_min_kaifu.dt_shomi_kaifu) AS dt_shomi_kaifu
--									,tk_min_kaifu.no_lot_oya
--									,tk_min_kaifu.cd_hinmei
--									,tk_min_kaifu.kbn_hin
--								FROM tr_kowake tk_min_kaifu
--								GROUP BY
--									tk_min_kaifu.no_lot_oya
--									,tk_min_kaifu.cd_hinmei
--									,tk_min_kaifu.kbn_hin
--							) tk_min_kaifu
--						ON tk.no_lot_oya = tk_min_kaifu.no_lot_oya
--						AND tk.cd_hinmei = tk_min_kaifu.cd_hinmei
--						AND tk.kbn_hin = tk_min_kaifu.kbn_hin
--						LEFT OUTER JOIN
--							(
--								SELECT
--									lot_kirikae.no_lot_oya
--									,lot_kirikae.no_lot_kowake
--									,
--										STUFF ((
--											SELECT
--												',' + lot.no_lot
--											FROM
--												(
--													SELECT
--														tl.no_lot
--														,tl.no_lot_jisseki
--														,tk.no_lot_oya
--														,tk.cd_panel
--														,tk.dt_kowake
--													FROM
--														tr_lot tl
--													INNER JOIN tr_kowake tk
--													ON tl.no_lot_jisseki = tk.no_lot_kowake
--												) lot
--											WHERE
--												lot.no_lot_oya = lot_kirikae.no_lot_oya
--											ORDER BY
--												lot.no_lot_oya
--											FOR XML PATH('')),1,1,''
--										) AS no_lot
--								FROM tr_kowake lot_kirikae
--								GROUP BY
--									lot_kirikae.no_lot_oya
--									,lot_kirikae.no_lot_kowake
--							) tk_comma
--						ON tk.no_lot_kowake = tk_comma.no_lot_kowake
--						LEFT OUTER JOIN ma_kbn_hin hinKbnMas
--						ON tk.kbn_hin = hinKbnMas.kbn_hin
--						LEFT OUTER JOIN  ma_hakari hakari
--						ON tk.cd_hakari = hakari.cd_hakari
--						LEFT OUTER JOIN ma_tani tani
--						ON hakari.cd_tani = tani.cd_tani
--					) TK
--				WHERE
--					@dt_kowake <= TK.dt_kowake
--					AND TK.dt_kowake <
--						(
--							SELECT DATEADD(DD,@day,@dt_kowake)
--						)
--					AND (
--							@flg_haki = 0
--							OR TK.flg_kanryo_tonyu = @mikanryoTonyuKanryoFlg
--						)
--				GROUP BY
--					TK.dt_kowake
--					,TK.cd_hinmei
--					,TK.nm_hinmei
--					,TK.no_lot
--					,TK.wt_haigo
--					,TK.cd_tani
--					,TK.nm_tani
--					,TK.su_kai
--					,TK.su_ko
--					,TK.no_tonyu
--					,TK.no_kotei
--					,TK.nm_seihin
--					,TK.nm_line
--					,TK.cd_panel
--					,TK.nm_hakari
--					,TK.nm_torihiki
--					,TK.nm_tanto_kowake
--					,TK.dt_chikan
--					,TK.nm_tanto_chikan
--					,TK.dt_shomi
--					,TK.dt_shomi_kaifu
--					,TK.ritsu_kihon
--					,TK.dt_seizo
--					,TK.dt_tonyu
--					,TK.flg_kanryo_tonyu
--					,TK.no_lot_oya
--					,ISNULL(TK.no_lot_oya,TK.no_lot_kowake)
--					,TK.kbn_hin
--					,TK.nm_kbn_hin
-- ��2017/02/23 �T�|�[�gNo.6�Ή��i���\���P�j�ŃR�����g�A�E�g��
			)
		-- ��ʂɕԋp����l���擾
		SELECT
			cnt
			,cte_row.dt_kowake
			,cte_row.cd_hinmei
			,cte_row.nm_hinmei
			,cte_row.no_lot
			,cte_row.wt_haigo
			,cte_row.wt_jisseki
			,cte_row.nm_tani
			,cte_row.su_kai
			,cte_row.su_ko
			,cte_row.no_tonyu
			,cte_row.no_kotei
			,cte_row.nm_seihin
			,cte_row.nm_line
			,cte_row.cd_panel
			,cte_row.nm_hakari
			,cte_row.nm_torihiki
			,cte_row.nm_tanto_kowake
			,cte_row.dt_chikan
			,cte_row.nm_tanto_chikan
			,cte_row.dt_shomi
			,cte_row.dt_shomi_kaifu
			,cte_row.dt_shomi_kaito
			,cte_row.ritsu_kihon
			,cte_row.dt_seizo
			,cte_row.dt_tonyu
			,cte_row.flg_kanryo_tonyu
			,cte_row.kbn_hin
			,cte_row.nm_kbn_hin
			--��\������
			,cte_row.no_lot_oya
			,cte_row.no_lot_kowake
			,cte_row.kigen
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
				@isExcel = @false
				AND RN BETWEEN @start AND @end
			)
			OR @isExcel = @true
		ORDER BY cte_row.RN
	END
	-- �W�v����
	ELSE IF	@chk_shukei = 1
	BEGIN
		WITH cte AS
			(
				SELECT
					-- �\������
					  @datetime AS dt_kowake
					, summary.cd_hinmei
					, summary.nm_hinmei
					, '' AS no_lot
					, 0.00 AS wt_haigo
					, CASE
						WHEN hakari.cd_tani = 3 THEN ROUND(summary.wt_jisseki * 1000, @su_keta_shosuten, 1)
						ELSE ROUND(summary.wt_jisseki, @su_keta_shosuten, 1) 
					  END AS wt_jisseki
					, tani.nm_tani
					, 0.00 AS su_kai
					, 0.00 AS su_ko
					, 0.00 AS no_tonyu
					, 0.00 AS no_kotei
					, '' AS nm_seihin
					, '' AS nm_line
					, '' AS cd_panel
					, '' AS nm_hakari
					, '' AS nm_torihiki
					, '' AS nm_tanto_kowake
					, @datetime AS dt_chikan
					, '' AS nm_tanto_chikan
					, @datetime AS dt_shomi
					, @datetime AS dt_shomi_kaifu
					, @datetime As dt_shomi_kaito
					, 0.00 AS ritsu_kihon
					, @datetime AS dt_seizo
					, @datetime AS dt_tonyu
					, summary.flg_kanryo_tonyu
					-- ��\������
					, '' AS no_lot_oya
					, '' AS no_lot_kowake
					, summary.kigen
					, summary.kbn_hin
					, kbn_hin.nm_kbn_hin
					, ROW_NUMBER() OVER (ORDER BY summary.kbn_hin, summary.cd_hinmei, summary.nm_hinmei, summary.flg_kanryo_tonyu ,summary.wt_jisseki) AS RN
				FROM (
					SELECT
						kowake.cd_hinmei
						, kowake.nm_hinmei
						, SUM(taisho.wt_jisseki) AS wt_jisseki
						, taisho.kigen
						, kowake.cd_line
						, kowake.cd_panel
						, kowake.cd_hakari
						, kowake.kbn_hin
						, kowake.flg_kanryo_tonyu
					FROM (
						SELECT
							  tk.no_lot_kowake
							, tk.wt_jisseki
							, CASE
								WHEN tk.dt_shomi_kaifu < @dt_utc THEN @kigengireKigenFlg
								WHEN tk.dt_shomi_kaifu >= @dt_utc AND tk.dt_shomi_kaifu < DATEADD(DAY,@dt_kigen_chokuzen,@dt_utc)
																 THEN @chokuzenKigenFlg
								WHEN tk.dt_shomi_kaifu >=  DATEADD(DAY,@dt_kigen_chokuzen,@dt_utc) AND tk.dt_shomi_kaifu < DATEADD(DAY,@dt_kigen_chikai,@dt_utc)
																 THEN @chikaiKigenFlg
								ELSE @yoyuKigenFlg
							  END AS kigen
							, tk.dt_kowake_oya
						FROM (
							SELECT
								  tmp.no_lot_kowake
								, MAX(tmp.dt_kowake) AS dt_kowake
								, MIN(tmp.dt_kowake) AS dt_kowake_oya
								, SUM(tmp.wt_jisseki) AS wt_jisseki
								, MIN(tmp.dt_shomi) AS dt_shomi
								, MIN(tmp.dt_shomi_kaifu) AS dt_shomi_kaifu
								, MIN(tmp.dt_shomi_kaito) AS dt_shomi_kaito
								, MAX(tmp.dt_tonyu) AS dt_tonyu
								, MAX(tmp.no_lot_oya) AS no_lot_oya
							FROM @tr_kowake_tmp tmp
							GROUP BY tmp.no_lot_kowake
						) tk
					) taisho
					INNER JOIN tr_kowake kowake
						ON kowake.no_lot_kowake = taisho.no_lot_kowake
						AND kowake.dt_kowake = taisho.dt_kowake_oya
					GROUP BY 
						kowake.cd_hinmei
						, kowake.nm_hinmei
						, taisho.kigen
						, kowake.cd_line
						, kowake.cd_panel
						, kowake.cd_hakari
						, kowake.kbn_hin
						, kowake.flg_kanryo_tonyu
				) summary
				-- ���}�X�^
				LEFT OUTER JOIN ma_hakari hakari
					ON hakari.cd_hakari = summary.cd_hakari
				-- ���C���}�X�^
				LEFT OUTER JOIN ma_line line
					ON line.cd_line = summary.cd_line
				-- �p�l���}�X�^
				INNER JOIN ma_panel panel
					ON panel.cd_panel = summary.cd_panel
					AND panel.cd_shokuba = @cd_shokuba
				-- �i�敪�}�X�^
				LEFT OUTER JOIN ma_kbn_hin kbn_hin
					ON kbn_hin.kbn_hin = summary.kbn_hin
				-- �P�ʃ}�X�^
				LEFT OUTER JOIN ma_tani tani
					ON tani.cd_tani = hakari.cd_tani
			
-- ��2017/02/23 �T�|�[�gNo.6�Ή��i���\���P�j�ŃR�����g�A�E�g��
--				SELECT	-- �\������
--					@datetime AS dt_kowake -- �u''�v�u@datetime�v�u0.00�v�͕����^�ƍ��킹�邽�߂̋�ӏ� (kakuta.y,2013.10.10)
--					,tk_shukei.cd_hinmei
--					,tk_shukei.nm_hinmei
--					,'' AS no_lot
--					,0.00 AS wt_haigo
--					--,SUM(tk_shukei.wt_jisseki) AS wt_jisseki
--					,CASE --���ђl(������3�ʂ܂ŕ\���B�؎̂�
--					WHEN tk_shukei.cd_tani = '3' 
--					THEN ROUND(SUM(tk_shukei.wt_jisseki) * 1000, 3, 1) --g�ϊ�
--					ELSE ROUND(SUM(tk_shukei.wt_jisseki), 3, 1) 
--					END AS wt_jisseki
--					,tk_shukei.nm_tani
--					,0.00 AS su_kai
--					,0.00 AS su_ko
--					,0.00 AS no_tonyu
--					,0.00 AS no_kotei
--					,'' AS nm_seihin
--					,'' AS nm_line
--					,'' AS cd_panel
--					,'' AS nm_hakari
--					,'' AS nm_torihiki
--					,'' AS nm_tanto_kowake
--					,@datetime AS dt_chikan
--					,'' AS nm_tanto_chikan
--					,@datetime AS dt_shomi
--					,@datetime AS dt_shomi_kaifu
--					,0.00 AS ritsu_kihon
--					,@datetime AS dt_seizo
--					,@datetime AS dt_tonyu
--					,tk_shukei.flg_kanryo_tonyu
--					-- ��\������
--					--,ISNULL(tk_shukei.no_lot_oya,'') AS no_lot_oya
--					,'' AS no_lot_oya
--					,'' AS no_lot_kowake
--					,tk_shukei.kigen
--					,hinKbnMas.kbn_hin
--					,hinKbnMas.nm_kbn_hin
--					,ROW_NUMBER() OVER (ORDER BY hinKbnMas.kbn_hin, tk_shukei.cd_hinmei, tk_shukei.nm_hinmei, tk_shukei.flg_kanryo_tonyu ,SUM(tk_shukei.wt_jisseki)) AS RN
--				FROM
--					(
--						SELECT
--							TK.cd_hinmei
--							,TK.nm_hinmei
--							,TK.wt_jisseki
--							,TK.cd_tani
--							,TK.nm_tani
--							,TK.flg_kanryo_tonyu
--							,TK.no_lot_oya
--							,CASE
--								-- �g�p�����؂�
--								WHEN TK.dt_shomi_kaifu < DATEADD(DAY,1,@dt_utc) THEN @kigengireKigenFlg
--								-- �g�p�������O
--								WHEN TK.dt_shomi_kaifu >=  DATEADD(DAY,1,@dt_utc)
--								AND TK.dt_shomi_kaifu < DATEADD(DAY,@dt_kigen_chokuzen + 1,@dt_utc) THEN @chokuzenKigenFlg
--								-- �g�p�����߂�
--								WHEN TK.dt_shomi_kaifu >=  DATEADD(DAY,@dt_kigen_chokuzen + 1,@dt_utc)
--								AND TK.dt_shomi_kaifu < DATEADD(DAY,@dt_kigen_chikai + 1,@dt_utc) THEN @chikaiKigenFlg
--								-- �g�p�����܂ŗ]�T����
--								ELSE @yoyuKigenFlg
--							END AS kigen
--							,TK.kbn_hin
--						FROM
--							(
--								SELECT
--									tk.cd_hinmei
--									,tk.nm_hinmei
--									,tk.wt_jisseki
--									,tani.cd_tani
--									,tani.nm_tani
--									,tk.flg_kanryo_tonyu
--									,tk.no_lot_oya
--									,mp.cd_shokuba
--									,CASE 
--										WHEN tk.no_lot_oya IS NOT NULL THEN tk_max.dt_kowake
--										ELSE tk.dt_kowake
--									END AS dt_kowake
--									,CASE
--										WHEN tk.no_lot_oya IS NOT NULL THEN tk_min_kaifu.dt_shomi_kaifu
--										ELSE tk.dt_shomi_kaifu
--									END AS dt_shomi_kaifu
--									,tk.kbn_hin
--								FROM tr_kowake tk
--								INNER JOIN	tr_lot tl
--								ON	tk.no_lot_kowake = tl.no_lot_jisseki
--								LEFT OUTER JOIN ma_panel mp
--								ON	tk.cd_panel = mp.cd_panel
--								LEFT OUTER JOIN
--									(
--										SELECT
--											MAX(tk.dt_kowake) AS dt_kowake
--											,tk.no_lot_oya
--											,tk.cd_hinmei
--											,tk.kbn_hin
--										FROM tr_kowake tk
--										GROUP BY
--											tk.no_lot_oya
--											,tk.cd_hinmei
--											,tk.kbn_hin
--									) tk_max
--								ON tk.no_lot_oya = tk_max.no_lot_oya
--								AND	tk.cd_hinmei = tk_max.cd_hinmei
--								AND tk.kbn_hin = tk_max.kbn_hin
--								LEFT OUTER JOIN
--									(
--										SELECT
--											MIN(tk_min_kaifu.dt_shomi_kaifu) AS dt_shomi_kaifu
--											, tk_min_kaifu.no_lot_oya
--											, tk_min_kaifu.cd_hinmei
--											,tk_min_kaifu.kbn_hin
--										FROM tr_kowake tk_min_kaifu
--										GROUP BY
--											tk_min_kaifu.no_lot_oya
--											,tk_min_kaifu.cd_hinmei
--											,tk_min_kaifu.kbn_hin
--									) tk_min_kaifu
--								ON tk.no_lot_oya = tk_min_kaifu.no_lot_oya
--								AND tk.cd_hinmei = tk_min_kaifu.cd_hinmei
--								AND tk.kbn_hin = tk_min_kaifu.kbn_hin
--								LEFT OUTER JOIN  ma_hakari hakari
--								ON tk.cd_hakari = hakari.cd_hakari
--								LEFT OUTER JOIN ma_tani tani
--								ON hakari.cd_tani = tani.cd_tani
--							) TK
--						WHERE
--							@dt_kowake <= TK.dt_kowake
--								AND TK.dt_kowake <
--									(
--										SELECT DATEADD(DD,@day,@dt_kowake)
--									)
--								AND TK.cd_shokuba = @cd_shokuba
--								AND (
--										@flg_haki = 0
--										OR TK.flg_kanryo_tonyu = @mikanryoTonyuKanryoFlg
--									)
--					) tk_shukei
--				LEFT OUTER JOIN ma_kbn_hin hinKbnMas
--				ON tk_shukei.kbn_hin = hinKbnMas.kbn_hin
--				GROUP BY
--					tk_shukei.cd_hinmei
--					,tk_shukei.nm_hinmei
--					,tk_shukei.cd_tani
--					,tk_shukei.nm_tani
--					,tk_shukei.kigen
--					,tk_shukei.flg_kanryo_tonyu
--					--,tk_shukei.no_lot_oya
--					,hinKbnMas.kbn_hin
--					,hinKbnMas.nm_kbn_hin
-- ��2017/02/23 �T�|�[�gNo.6�Ή��i���\���P�j�ŃR�����g�A�E�g��
			)
		-- ��ʂɕԋp����l���擾
		SELECT
			cnt
			,cte_row.dt_kowake
			,cte_row.cd_hinmei
			,cte_row.nm_hinmei
			,cte_row.no_lot
			,cte_row.wt_haigo
			,cte_row.wt_jisseki
			,cte_row.nm_tani
			,cte_row.su_kai
			,cte_row.su_ko
			,cte_row.no_tonyu
			,cte_row.no_kotei
			,cte_row.nm_seihin
			,cte_row.nm_line
			,cte_row.cd_panel
			,cte_row.nm_hakari
			,cte_row.nm_torihiki
			,cte_row.nm_tanto_kowake
			,cte_row.dt_chikan
			,cte_row.nm_tanto_chikan
			,cte_row.dt_shomi
			,cte_row.dt_shomi_kaifu
			,cte_row.dt_shomi_kaito
			,cte_row.ritsu_kihon
			,cte_row.dt_seizo
			,cte_row.dt_tonyu
			,cte_row.flg_kanryo_tonyu
			,cte_row.kbn_hin
			,cte_row.nm_kbn_hin
			--��\������
			,cte_row.no_lot_oya
			,cte_row.no_lot_kowake
			,cte_row.kigen
		FROM
			(
				SELECT
					MAX(RN) OVER() cnt
					,*
				FROM cte 
			) cte_row
		WHERE
			(
				@isExcel = @false
				AND RN BETWEEN @start AND @end
			)
			OR @isExcel = @true
		ORDER BY cte_row.RN
	END
	-- �ꎞ�e�[�u�����폜���܂�
	DELETE FROM @tr_kowake_tmp
	DELETE FROM @tr_lot_tmp
	
	END
GO
