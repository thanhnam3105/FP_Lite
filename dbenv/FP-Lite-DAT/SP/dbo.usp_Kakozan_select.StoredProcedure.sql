IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_Kakozan_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_Kakozan_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\        �F���H�c ����
�t�@�C����  �Fusp_Kakozan_select
���͈���    �F@dt_hizuke, @isKeikoku, @cd_niuke
			  , @kbn_hin, @cd_bunrui, @zaikoZeroFlg
			  , @lang, @con_hinmei, @dt_niuke_from
			  , @dt_niuke_to,  @isNiukeDateFrom
			  , @isNiukeDateTo, @shiyoMishiyoFlg
			  , @jikagenryoHinKbn, @ryohinZaikoKbn, @horyuZaikoKbn
			  , @kakozanNyushuko, @mikakuteiKakuteiFlg, @skip	
			  , @top, @isExcel
�o�͈���    �F
�߂�l      �F
�쐬��      �F2013.09.20  ADMAX onodera.s
�X�V��      �F2015.08.20  ADMAX taira.s
�X�V��      �F2015.10.05  MJ    ueno.k
�X�V��      �F2015.10.16  MJ    ueno.k  ���o����������׎󂯎��ѓ��݂̂ɏC��
�X�V��      �F2015.10.19  MJ    ueno.k  �\�����ڂ͒��������_�ł̕\���ɏC��
�X�V��      �F2016.12.13  BRC   motojima.m �����Ή�
�X�V��      �F2017.11.14  BRC   sato.s �����Ή�
*****************************************************/
CREATE PROCEDURE [dbo].[usp_Kakozan_select] 
	@dt_hizuke				DATETIME	  -- �݌ɒ�����
	, @isKeikoku			BIT			  -- �x���`�F�b�N�{�b�N�X
	, @cd_niuke				VARCHAR(14)	  -- �׎�ꏊ�R�[�h
	, @kbn_hin				SMALLINT	  -- �i�敪
	, @cd_bunrui			VARCHAR(10)	  -- ���ރR�[�h
	, @isZaikoZero			BIT			  -- �݌�0�\���`�F�b�N�{�b�N�X
	, @lang					varchar(2)	  -- �u���E�U����
	--, @con_hinmei			varchar(50)	  -- �i��
	, @con_hinmei			nvarchar(50)  -- �i��
	, @dt_niuke_from		DATETIME	  -- �׎��(FROM)
	, @dt_niuke_to			DATETIME	  -- �׎��(TO)
	, @isNiukeDateFrom		BIT			  -- �׎��(FROM)����/�Ȃ�����
	, @isNiukeDateTo		BIT			  -- �׎��(TO)����/�Ȃ�����
	, @shiyoMishiyoFlg		SMALLINT	  -- ���g�p�t���O.�g�p
	, @jikagenryoHinKbn		SMALLINT	  -- �i�敪.���ƌ���
	, @ryohinZaikoKbn		SMALLINT	  -- �݌ɋ敪.�Ǖi
	, @horyuZaikoKbn		SMALLINT	  -- �݌ɋ敪.�ۗ�
	, @kakozanNyushuko		SMALLINT	  -- ���o�ɋ敪.���H�c
	, @mikakuteiKakuteiFlg	SMALLINT	  -- �m��t���O.���m��
	, @kigengireKigenFlg	SMALLINT	  -- �����t���O.�����؂�
	, @chokuzenKigenFlg		SMALLINT	  -- �����t���O.���O
	, @chikaiKigenFlg		SMALLINT	  -- �����t���O.�߂�
	, @yoyuKigenFlg			SMALLINT	  -- �����t���O.�]�T
	, @dt_kigen_chikai		DECIMAL		  -- �H��}�X�^.kigen_chikai
	, @dt_kigen_chokuzen	DECIMAL		  -- �H��}�X�^.kigen_chokuzen
	, @dt_utc				DATETIME	  -- �V�X�e���u�N�����v��UTC���� EX)���{�Fyyyy/MM/dd 15:00:00.000
	, @skip					DECIMAL(10)	  -- �X�L�b�v(�㑱�f�[�^�����p)
	, @top					DECIMAL(10)	  -- �����f�[�^���(�㑱�f�[�^�����p)
	, @isExcel				BIT			  -- �G�N�Z���t���O
AS
BEGIN
	
	DECLARE @start			DECIMAL(10)
    DECLARE @end			DECIMAL(10)
	DECLARE @true			BIT
	DECLARE @false			BIT
	DECLARE @keikoku		SMALLINT
	DECLARE @misetteiKigen	VARCHAR
	DECLARE @kireKigen		VARCHAR
	DECLARE @majikaKigen	VARCHAR
	DECLARE @yoyuKigen		VARCHAR
	DECLARE @one			SMALLINT
	DECLARE @minSeqNo DECIMAL(8, 0)
	DECLARE @taniKg SMALLINT
	DECLARE @taniL SMALLINT
	
	SET		@mikakuteiKakuteiFlg = '0'
	SET		@kireKigen			 = '1'
	SET		@majikaKigen		 = '2'
	SET		@yoyuKigen			 = '3'
    SET		@start	             =	@skip + 1
    SET		@end	             =	@skip + @top
    SET		@true	             =	1
    SET		@false	             =	0
    SET		@one	             =	1
    SET		@taniKg	             =	4
    SET		@taniL	             =	11
    
	SELECT @minSeqNo = MIN(minS.no_seq) FROM tr_niuke minS;	

	WITH cte AS	(
				SELECT	*
						, ROW_NUMBER() OVER (ORDER BY no_niuke) AS RN
				
				FROM	(
						SELECT		-- �\������
								CASE t_niu.kbn_nyushukko
									WHEN @kakozanNyushuko THEN t_niu.flg_kakutei
									ELSE @mikakuteiKakuteiFlg
								END flg_kakutei													-- �m��
								, ISNULL(ma_niuke.nm_niuke, '')	nm_niuke						-- �׎�ꏊ
								, t_niu.cd_hinmei												-- �i���R�[�h
								, ISNULL(ma_hinmei.nm_hinmei_en, '')	nm_hinmei_en			-- �i��(�p��)
								, ISNULL(ma_hinmei.nm_hinmei_ja, '')	nm_hinmei_ja			-- �i��(���{��)
								, ISNULL(ma_hinmei.nm_hinmei_zh, '')	nm_hinmei_zh			-- �i��(������)
								, ISNULL(ma_hinmei.nm_hinmei_vi, '')	nm_hinmei_vi
								, ISNULL(ma_hinmei.nm_nisugata_hyoji, '')	nm_nisugata_hyoji	-- �׎p
								, tn_min.dt_niuke		AS	min_dt_niuke						-- �׎��
								, tn_min.tm_nonyu_jitsu	AS	min_tm_nonyu_jitsu					-- ����
								, t_niu.no_lot													-- ���b�gNo.
								, t_niu.dt_seizo												-- ������
								, t_niu.dt_kigen												-- �ܖ�����
								, ma_kbn_zaiko.nm_kbn_zaiko										-- �݌ɋ敪(����)
								, ISNULL(t_niu.su_zaiko, 0) su_zaiko							-- �݌�C/S��
								, ISNULL(t_niu.su_zaiko_hasu, 0) su_zaiko_hasu					-- �݌ɒ[��
								, CASE 
									WHEN ISNULL ( ma_konyu.cd_tani_nonyu, ma_hinmei.cd_tani_nonyu ) IN (@taniKg,@taniL)
										THEN
											CASE t_niu.kbn_hin
												WHEN  @jikagenryoHinKbn  THEN ISNUll(ma_hinmei.su_iri,1) * ISNULL(FLOOR(ma_hinmei.wt_ko * 1000) / 1000,1) * ISNULL(t_niu.su_zaiko, 0) + ISNULL(t_niu.su_zaiko_hasu, 0) / 1000
												ELSE ISNUll(ma_konyu.su_iri,1) * ISNUll(FLOOR(ma_konyu.wt_nonyu * 1000) / 1000,1) * ISNULL(t_niu.su_zaiko, 0) + ISNULL(t_niu.su_zaiko_hasu, 0) / 1000
										 	END
									ELSE
											CASE t_niu.kbn_hin
												WHEN  @jikagenryoHinKbn  THEN ISNUll(ma_hinmei.su_iri,1) * ISNULL(FLOOR(ma_hinmei.wt_ko * 1000) / 1000,1) * ISNULL(t_niu.su_zaiko, 0) + ISNULL(t_niu.su_zaiko_hasu, 0)
												ELSE ISNUll(ma_konyu.su_iri,1) * ISNUll(FLOOR(ma_konyu.wt_nonyu * 1000) / 1000,1) * ISNULL(t_niu.su_zaiko, 0) + ISNULL(t_niu.su_zaiko_hasu, 0)
										 	END
								  END AS su_shiyo												-- �݌ɐ��i�g�p�P�ʁj
								, t_niu.cd_update												-- �X�V��ID
								--��\������
								, t_niu.no_niuke												-- �׎�ԍ�
								, t_niu.kbn_zaiko												-- �݌ɋ敪(�R�[�h)
								, t_niu.kbn_nyushukko											-- ���o�ɋ敪
								, t_niu.dt_niuke		AS	niuke_dt_niuke
								, tn_max.dt_niuke		AS	max_dt_niuke						-- �׎��(�ŐV)
								, tn_max.no_seq			AS	max_no_seq							-- �V�[�P���X�ԍ�(�ŐV)
								, ISNULL ( ma_konyu.cd_tani_nonyu, ma_hinmei.cd_tani_nonyu ) AS cd_tani_nonyu
								, CASE t_niu.kbn_hin
										WHEN  @jikagenryoHinKbn  THEN ma_hinmei.su_iri
										ELSE ma_konyu.su_iri
								END AS su_iri													-- ����
								, CASE t_niu.kbn_hin
										WHEN  @jikagenryoHinKbn  THEN FLOOR(ma_hinmei.wt_ko * 1000) / 1000
										ELSE  FLOOR(ma_konyu.wt_nonyu * 1000) / 1000
								END AS wt_ko													-- �d��
								, CASE
										/*WHEN t_niu.dt_kigen IS NULL
												OR t_niu.dt_seizo IS NULL THEN @mikakuteiKakuteiFlg
										WHEN t_niu.dt_kigen - GETUTCDATE ( ) < 0 THEN @kireKigen
										WHEN  CEILING((CONVERT (DECIMAL,(DATEDIFF(DAY , t_niu.dt_kigen , t_niu.dt_seizo)))* -1) / 3) > CONVERT (INT, (DATEDIFF(DAY, GETUTCDATE() , t_niu.dt_kigen))) THEN @majikaKigen
										ELSE @yoyuKigen*/
										-- �g�p�����؂�
										WHEN t_niu.dt_kigen < @dt_utc THEN @kigengireKigenFlg
										-- �g�p�������O
										WHEN t_niu.dt_kigen >= @dt_utc
										AND t_niu.dt_kigen < DATEADD(DAY,@dt_kigen_chokuzen,@dt_utc) THEN @chokuzenKigenFlg
										-- �g�p�����߂�
										WHEN t_niu.dt_kigen >=  DATEADD(DAY,@dt_kigen_chokuzen,@dt_utc)
										AND t_niu.dt_kigen < DATEADD(DAY,@dt_kigen_chikai,@dt_utc) THEN @chikaiKigenFlg
										-- �g�p�����܂ŗ]�T����
										ELSE @yoyuKigenFlg
								END AS flg_keikoku
								,maxzaiko.su_shukko AS saishinZaiko
								,maxzaiko.su_shukko_hasu AS saishinZaikoHasu
								,maxzaiko.flgSaishin AS flgSaishin
								,tn_min.dt_nonyu		AS	min_dt_nonyu	-- ����[����
								
						FROM	tr_niuke t_niu
							LEFT JOIN	ma_niuke
									ON	t_niu.cd_niuke_basho	= ma_niuke.cd_niuke_basho
									AND	ma_niuke.flg_mishiyo	= @shiyoMishiyoFlg
							INNER JOIN	ma_kbn_zaiko
									ON	t_niu.kbn_zaiko			= ma_kbn_zaiko.kbn_zaiko
							INNER JOIN	ma_konyu
									ON t_niu.cd_torihiki		= ma_konyu.cd_torihiki
									AND t_niu.cd_hinmei			= ma_konyu.cd_hinmei
									--AND ma_konyu.flg_mishiyo	= @shiyoMishiyoFlg
									--ON CASE
									--		WHEN	@kbn_hin				<> @jikagenryoHinKbn
									--			AND t_niu.cd_torihiki		= ma_konyu.cd_torihiki
									--			AND	t_niu.cd_hinmei			= ma_konyu.cd_hinmei
									--			AND	ma_konyu.flg_mishiyo	= @shiyoMishiyoFlg		THEN 1
									--		WHEN	@kbn_hin				= @jikagenryoHinKbn		THEN 1
									--		ELSE 0
									--	END = 1
							INNER JOIN	( 
										SELECT	
												t_min.dt_niuke
												, t_min.tm_nonyu_jitsu
												, t_min.no_niuke
												, t_min.dt_nonyu 
										FROM	tr_niuke t_min
										WHERE	
											t_min.no_seq = (
																SELECT
																	MIN(no_seq)
																FROM tr_niuke
															)
										) tn_min
									ON	t_niu.no_niuke	=	tn_min.no_niuke
--
							INNER JOIN	(	
											SELECT
												t_max.no_niuke
												, t_max.kbn_zaiko
												, MAX(t_max.no_seq) no_seq
												, MAX(t_max.dt_niuke) dt_niuke
												, MAX(t_max.dt_nonyu) dt_nonyu
											FROM tr_niuke t_max
											WHERE
												(
													(
														(t_max.kbn_zaiko = @ryohinZaikoKbn OR t_max.kbn_zaiko = @horyuZaikoKbn)
														and t_max.dt_niuke < (SELECT DATEADD(DD,1,@dt_hizuke))
														and t_max.no_seq <> @minSeqNo
													)
												OR
													(
														(t_max.kbn_zaiko = @ryohinZaikoKbn OR t_max.kbn_zaiko = @horyuZaikoKbn)
														and t_max.dt_nonyu < (SELECT DATEADD(DD,1,@dt_hizuke))
														and t_max.no_seq = @minSeqNo
													)
												)

--												(t_max.kbn_zaiko = @ryohinZaikoKbn OR t_max.kbn_zaiko = @horyuZaikoKbn)
--												and t_max.dt_niuke < (SELECT DATEADD(DD,1,@dt_hizuke))
											GROUP BY
												t_max.no_niuke
												, t_max.kbn_zaiko
										) tn_max
									ON	t_niu.no_niuke			= tn_max.no_niuke
									AND	t_niu.kbn_zaiko			= tn_max.kbn_zaiko
--
							LEFT JOIN	ma_hinmei
									ON	t_niu.cd_hinmei			= ma_hinmei.cd_hinmei
							LEFT JOIN	ma_bunrui
									ON	ma_bunrui.cd_bunrui		= ma_hinmei.cd_bunrui
									AND	t_niu.kbn_hin			= ma_bunrui.kbn_hin
							LEFT JOIN	ma_kbn_hin
									ON	ma_kbn_hin.kbn_hin		= ma_hinmei.kbn_hin
							left join (
								select su_shukko
										,su_shukko_hasu
										,maxtn.no_niuke
										,kbn_zaiko
										,1 AS flgSaishin
								from tr_niuke maxtn
								inner join (
									select max(no_seq) maxseq
											,no_niuke 
									from tr_niuke
									group by no_niuke
								)max_niu
								on maxtn.no_niuke = max_niu.no_niuke
									and maxtn.no_seq = max_niu.maxseq

									and (
											(maxtn.dt_niuke > (SELECT DATEADD(DD,0,@dt_hizuke)) 
											AND 
											maxtn.no_seq <> @minSeqNo)
										OR 
										(
											(maxtn.dt_nonyu > (SELECT DATEADD(DD,0,@dt_hizuke)) 
											AND 
											maxtn.no_seq = @minSeqNo)
										)
									)
--									and maxtn.dt_niuke > (SELECT DATEADD(DD,0,@dt_hizuke))
							)maxzaiko
							on t_niu.no_niuke = maxzaiko.no_niuke
							and t_niu.kbn_zaiko = maxzaiko.kbn_zaiko
--									
							--�׎���ѓ�(from,to)
							INNER JOIN tr_niuke t_niuke_jisseki
							ON (
									(@isNiukeDateFrom = @false OR t_niuke_jisseki.dt_nonyu >= @dt_niuke_from)
									AND (@isNiukeDateTo = @false OR t_niuke_jisseki.dt_nonyu <= @dt_niuke_to)	
									AND t_niuke_jisseki.no_seq = @minSeqNo
									AND t_niuke_jisseki.no_niuke = t_niu.no_niuke
							)
						WHERE
							(
								(
									t_niu.dt_niuke < (SELECT DATEADD(DD,1,@dt_hizuke))
									AND 
									t_niu.no_seq <> @minSeqNo
								)
								OR 
								(
									t_niu.dt_nonyu < (SELECT DATEADD(DD,1,@dt_hizuke))
									AND 
									t_niu.no_seq = @minSeqNo
								)
							)
--						WHERE		t_niu.dt_niuke < (SELECT DATEADD(DD,1,@dt_hizuke))
							AND		t_niu.kbn_hin			=	@kbn_hin
							--�݌�0�\���`�F�b�N�Œ��o������ύX							
							AND 
							(
								CASE 
									WHEN @isZaikoZero = @false THEN t_niu.su_zaiko 
									ELSE 1 
								END > 0
								OR 
								CASE 
									WHEN @isZaikoZero = @false THEN t_niu.su_zaiko_hasu 
									ELSE 1 
								END > 0 								
							)														
							AND		(t_niu.kbn_zaiko = @ryohinZaikoKbn OR t_niu.kbn_zaiko = @horyuZaikoKbn)
							AND		(LEN(@cd_niuke) = 0 OR t_niu.cd_niuke_basho = @cd_niuke)
							AND		(LEN(@cd_bunrui) = 0 OR ma_hinmei.cd_bunrui = @cd_bunrui)
							-- ������Ή��F����ɂ���Č����Ώۂ̕i���J������ύX����
							AND (LEN(ISNULL(@con_hinmei, '')) = 0 OR
									(@lang = 'en' OR @lang = 'zh') OR
										t_niu.cd_hinmei like '%' + @con_hinmei + '%' OR ma_hinmei.nm_hinmei_ja like '%' + @con_hinmei + '%'
								)
							AND (LEN(ISNULL(@con_hinmei, '')) = 0 OR
									(@lang = 'ja' OR @lang = 'zh') OR
										t_niu.cd_hinmei like '%' + @con_hinmei + '%' OR ma_hinmei.nm_hinmei_en like '%' + @con_hinmei + '%'
								)
							AND (LEN(ISNULL(@con_hinmei, '')) = 0 OR
									(@lang = 'ja' OR @lang = 'en') OR
										t_niu.cd_hinmei like '%' + @con_hinmei + '%' OR ma_hinmei.nm_hinmei_zh like '%' + @con_hinmei + '%'
								)
							AND (LEN(ISNULL(@con_hinmei, '')) = 0 OR
									(@lang = 'ja' OR @lang = 'zh') OR
										t_niu.cd_hinmei like '%' + @con_hinmei + '%' OR ma_hinmei.nm_hinmei_vi like '%' + @con_hinmei + '%'
								)
							--�׎��(From,To) �׎���ѓ������ݒ�͏�ֈړ��B�����ł̓V�[�P���XNo�̂ݏ����ɁB
--

							AND (
									(
----									(@isNiukeDateFrom = @false OR t_niu.dt_niuke >= @dt_niuke_from)
----									AND (@isNiukeDateTo = @false OR t_niu.dt_niuke <= @dt_niuke_to)											
									 t_niu.no_seq <> @minSeqNo
									AND t_niu.no_seq = tn_max.no_seq
									)
								OR 
									(
----									(@isNiukeDateFrom = @false OR t_niu.dt_nonyu >= @dt_niuke_from)
----									AND (@isNiukeDateTo = @false OR t_niu.dt_nonyu <= @dt_niuke_to)	
										tn_max.no_seq = @minSeqNo
									AND t_niu.no_seq = @minSeqNo
									)
							)
--							AND (@isNiukeDateFrom = @false OR t_niu.dt_niuke >= @dt_niuke_from)
--							AND (@isNiukeDateTo = @false OR t_niu.dt_niuke <= @dt_niuke_to)											
--							AND		t_niu.no_seq			=	tn_max.no_seq

						) rowNum

				WHERE	(@isKeikoku = @false )
						OR 
						(
						@isKeikoku = @true 
							AND (
									rowNum.flg_keikoku		= @kireKigen 
									OR rowNum.flg_keikoku	= @majikaKigen
								)
						)
			GROUP BY rowNum.flg_kakutei
					, rowNum.nm_niuke
					, rowNum.cd_hinmei
					, rowNum.nm_hinmei_en
					, rowNum.nm_hinmei_ja
					, rowNum.nm_hinmei_zh
					, rowNum.nm_hinmei_vi
					, rowNum.nm_nisugata_hyoji
					, rowNum.min_dt_niuke
					, rowNum.no_lot
					, rowNum.min_tm_nonyu_jitsu
					, rowNum.dt_seizo
					, rowNum.dt_kigen
					, rowNum.nm_kbn_zaiko
					, rowNum.su_zaiko
					, rowNum.su_zaiko_hasu
					, rowNum.su_shiyo
					, rowNum.cd_update
					, rowNum.min_dt_nonyu
					--��\������
					, rowNum.no_niuke
					, rowNum.kbn_zaiko
					, rowNum.kbn_nyushukko
					, rowNum.niuke_dt_niuke
					, rowNum.max_dt_niuke
					, rowNum.max_no_seq
					, rowNum.cd_tani_nonyu
					, rowNum.su_iri
					, rowNum.wt_ko
					, rowNum.flg_keikoku
					, rowNum.saishinZaiko
					, rowNum.saishinZaikoHasu
					, rowNum.flgSaishin
		)
		-- ��ʂɕԋp����l���擾
		SELECT
			cnt
			, cte_row.flg_kakutei
			, cte_row.nm_niuke
			, cte_row.cd_hinmei
			, cte_row.nm_hinmei_en
			, cte_row.nm_hinmei_ja
			, cte_row.nm_hinmei_zh
			, cte_row.nm_hinmei_vi
			, cte_row.nm_nisugata_hyoji
			, cte_row.min_dt_niuke
			, cte_row.no_lot
			, cte_row.min_tm_nonyu_jitsu
			, cte_row.dt_seizo
			, cte_row.dt_kigen
			, cte_row.nm_kbn_zaiko
			, cte_row.su_zaiko
			, cte_row.su_zaiko_hasu
			, cte_row.su_shiyo
			, cte_row.cd_update
			--��\������
			, cte_row.no_niuke
			, cte_row.kbn_zaiko
			, cte_row.kbn_nyushukko
			, cte_row.niuke_dt_niuke
			, cte_row.max_dt_niuke
			, cte_row.max_no_seq
			, cte_row.cd_tani_nonyu
			, cte_row.su_iri
			, cte_row.wt_ko
			, cte_row.flg_keikoku
			, cte_row.saishinZaiko
			, cte_row.saishinZaikoHasu
			, cte_row.flgSaishin
			, cte_row.min_dt_nonyu
		FROM(
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
GO
