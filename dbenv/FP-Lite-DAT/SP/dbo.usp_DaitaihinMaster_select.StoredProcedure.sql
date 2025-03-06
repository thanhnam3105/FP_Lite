IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_DaitaihinMaster_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_DaitaihinMaster_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\		�F��֕i�}�X�^��� ����
�t�@�C����	�Fusp_DaitaihinMaster_select
���͈���	�F@cd_hinmei_daihyo, @shiyo, @skip, @top, @lang, @isExcel
			  @shiyoMishiyoFlg, @mishiyoMishiyoFlg, @genryoHinKbn, @jikaGenryoHinKbn
�o�͈���	�F
�߂�l		�F������[0] ���s��[0�ȊO�̃G���[�R�[�h]
�쐬��		�F2016.08.29 BRC m.motojima		��֕i�Ή�
�X�V��      �F2018.02.21 BRC d.kanehira		��֕i�����Ή�
*****************************************************/
CREATE PROCEDURE [dbo].[usp_DaitaihinMaster_select]
	@cd_hinmei_daihyo 	VARCHAR(14)		-- ����/��\�i�R�[�h
	,@shiyo 			SMALLINT		-- ����/���g�p
	,@skip				DECIMAL(10)		-- �Ǎ��J�n�ʒu
	,@top				DECIMAL(10)		-- ��ʕ\������
	,@lang				VARCHAR(2)		-- �u���E�U����
	,@isExcel			BIT				-- Excel�o�͗p
	,@shiyoMishiyoFlg	SMALLINT	    -- �y���g�p�t���O�z �g�p
	,@mishiyoMishiyoFlg SMALLINT		-- �y���g�p�t���O�z ���g�p
	,@genryoHinKbn		SMALLINT		-- �y�i�敪�z����
	--,@shikakariHinKbn	SMALLINT		-- �y�i�敪�z�d�|�i
	--,@jikaGenryoHinKbn	SMALLINT		-- �y�i�敪�z���ƌ���
AS
BEGIN
	DECLARE @start decimal(10)
	DECLARE	@end decimal(10)
	DECLARE @true	BIT
	DECLARE @false	BIT

	SET @start = @skip
	SET @end = @skip + @top
	SET		@true	= 1
    SET		@false	= 0;


	WITH cte AS
		(
			SELECT cd_hinmei_daihyo
			, nm_hinmei_daihyo
			, cd_hinmei
			, nm_hinmei
			, flg_mishiyo						-- ����/���g�p
			, kbn_hin_daihyo
			, kbn_hin
			, dt_create
			, cd_create
			, dt_update
			, cd_update
			, ts
			, ROW_NUMBER() OVER (ORDER BY cd_hinmei_daihyo,cd_hinmei) AS RN
			FROM
					(
						-- �����A���ƌ����̏ꍇ
						SELECT
						daitai.cd_hinmei_daihyo						-- ����/��\�i�R�[�h
						,CASE @lang 
						WHEN 'ja' THEN 
							CASE 
								WHEN hin1.nm_hinmei_ja IS NULL OR LEN(hin1.nm_hinmei_ja) = 0 THEN hin1.nm_hinmei_ryaku
								ELSE hin1.nm_hinmei_ja
							END
						WHEN 'en' THEN
							CASE 
								WHEN hin1.nm_hinmei_en IS NULL OR LEN(hin1.nm_hinmei_en) = 0 THEN hin1.nm_hinmei_ryaku
								ELSE hin1.nm_hinmei_en
							END
						WHEN 'zh' THEN
							CASE 
								WHEN hin1.nm_hinmei_zh IS NULL OR LEN(hin1.nm_hinmei_zh) = 0 THEN hin1.nm_hinmei_ryaku
								ELSE hin1.nm_hinmei_zh
							END
						WHEN 'vi' THEN
							CASE 
								WHEN hin1.nm_hinmei_vi IS NULL OR LEN(hin1.nm_hinmei_vi) = 0 THEN hin1.nm_hinmei_ryaku
								ELSE hin1.nm_hinmei_vi
							END
						END AS nm_hinmei_daihyo	
						, daitai.cd_hinmei							-- ����/�i�R�[�h
						,CASE @lang 
						WHEN 'ja' THEN 
							CASE 
								WHEN hin2.nm_hinmei_ja IS NULL OR LEN(hin2.nm_hinmei_ja) = 0 THEN hin2.nm_hinmei_ryaku
								ELSE hin2.nm_hinmei_ja
							END
						WHEN 'en' THEN
							CASE 
								WHEN hin2.nm_hinmei_en IS NULL OR LEN(hin2.nm_hinmei_en) = 0 THEN hin2.nm_hinmei_ryaku
								ELSE hin2.nm_hinmei_en
							END
						WHEN 'zh' THEN
							CASE 
								WHEN hin2.nm_hinmei_zh IS NULL OR LEN(hin2.nm_hinmei_zh) = 0 THEN hin2.nm_hinmei_ryaku
								ELSE hin2.nm_hinmei_zh
							END
						WHEN 'vi' THEN
							CASE 
								WHEN hin2.nm_hinmei_vi IS NULL OR LEN(hin2.nm_hinmei_vi) = 0 THEN hin2.nm_hinmei_ryaku
								ELSE hin2.nm_hinmei_vi
							END
						END AS nm_hinmei							-- ����/�i��
						, daitai.kbn_hin_daihyo
						, daitai.kbn_hin
						, daitai.flg_mishiyo						-- ����/���g�p
						, daitai.dt_create
						, daitai.cd_create
						, daitai.dt_update
						, daitai.cd_update
						, daitai.ts
						FROM ma_daitaihin daitai
						INNER JOIN ma_hinmei hin1 
						ON daitai.cd_hinmei_daihyo = hin1.cd_hinmei
						--AND hin1.kbn_hin IN (@genryoHinKbn,@jikaGenryoHinKbn)
						AND hin1.kbn_hin = @genryoHinKbn
						INNER JOIN ma_hinmei hin2 
						ON daitai.cd_hinmei = hin2.cd_hinmei
						--AND hin2.kbn_hin IN (@genryoHinKbn,@jikaGenryoHinKbn)
						AND hin2.kbn_hin = @genryoHinKbn
						WHERE
						((@isExcel = @false AND daitai.cd_hinmei_daihyo = @cd_hinmei_daihyo) OR (@isExcel = @true))   -- ��������/��\�i�R�[�h
						--AND daitai.kbn_hin_daihyo IN (@genryoHinKbn,@jikaGenryoHinKbn)
						AND daitai.kbn_hin_daihyo = @genryoHinKbn
						--AND daitai.kbn_hin IN (@genryoHinKbn,@jikaGenryoHinKbn)
						AND daitai.kbn_hin = @genryoHinKbn
						--���g�p�\���Ȃ�/���g�p�\��
						AND ((@shiyo = @false AND daitai.flg_mishiyo = @shiyoMishiyoFlg) OR (@shiyo = @true AND daitai.flg_mishiyo in (@shiyoMishiyoFlg,@mishiyoMishiyoFlg)))

						--UNION

						-- �d�|�i�̏ꍇ
						--SELECT
						--daitai.cd_hinmei_daihyo						-- ����/��\�i�R�[�h
						--,CASE @lang 
						--WHEN 'ja' THEN 
							--CASE 
								--WHEN hin1.nm_hinmei_ja IS NULL OR LEN(hin1.nm_hinmei_ja) = 0 THEN hin1.nm_haigo_ryaku
								--ELSE hin1.nm_hinmei_ja
							--END
						--WHEN 'en' THEN
							--CASE 
								--WHEN hin1.nm_hinmei_en IS NULL OR LEN(hin1.nm_hinmei_en) = 0 THEN hin1.nm_haigo_ryaku
								--ELSE hin1.nm_hinmei_en
							--END
						--WHEN 'zh' THEN
							--CASE 
								--WHEN hin1.nm_hinmei_zh IS NULL OR LEN(hin1.nm_hinmei_zh) = 0 THEN hin1.nm_haigo_ryaku
								--ELSE hin1.nm_hinmei_zh
							--END
						--END AS nm_hinmei_daihyo	
						--, daitai.cd_hinmei							-- ����/�i�R�[�h
						--,CASE @lang 
						--WHEN 'ja' THEN 
							--CASE 
								--WHEN hin2.nm_hinmei_ja IS NULL OR LEN(hin2.nm_hinmei_ja) = 0 THEN hin2.nm_haigo_ryaku
								--ELSE hin2.nm_hinmei_ja
							--END
						--WHEN 'en' THEN
							--CASE 
								--WHEN hin2.nm_hinmei_en IS NULL OR LEN(hin2.nm_hinmei_en) = 0 THEN hin2.nm_haigo_ryaku
								--ELSE hin2.nm_hinmei_en
							--END
						--WHEN 'zh' THEN
							--CASE 
								--WHEN hin2.nm_hinmei_zh IS NULL OR LEN(hin2.nm_hinmei_zh) = 0 THEN hin2.nm_haigo_ryaku
								--ELSE hin2.nm_hinmei_zh
							--END
						--END AS nm_hinmei							-- ����/�i��
						--, daitai.kbn_hin_daihyo
						--, daitai.kbn_hin
						--, daitai.flg_mishiyo						-- ����/���g�p
						--, daitai.dt_create
						--, daitai.cd_create
						--, daitai.dt_update
						--, daitai.cd_update
						--, daitai.ts
						--FROM ma_daitaihin daitai
						--INNER JOIN 
							--(SELECT
								--ma.no_han AS no_han
								--,ma.cd_haigo AS cd_hinmei
								--,ma.nm_haigo_ja AS nm_hinmei_ja
								--,ma.nm_haigo_en AS nm_hinmei_en
								--,ma.nm_haigo_zh AS nm_hinmei_zh
								--,ma.nm_haigo_ryaku
							--FROM ma_haigo_mei ma
							--INNER JOIN 
								--( SELECT MAX(no_han) AS no_han, cd_haigo
								  --FROM ma_haigo_mei
								  --WHERE flg_mishiyo = @shiyoMishiyoFlg
								  --GROUP BY cd_haigo) maxHan
							--ON ma.cd_haigo = maxHan.cd_haigo
							--AND ma.no_han = maxHan.no_han
							--)  hin1 
						--ON daitai.cd_hinmei_daihyo = hin1.cd_hinmei
						--INNER JOIN 
							--( SELECT
								--ma.no_han AS no_han
								--,ma.cd_haigo AS cd_hinmei
								--,ma.nm_haigo_ja AS nm_hinmei_ja
								--,ma.nm_haigo_en AS nm_hinmei_en
								--,ma.nm_haigo_zh AS nm_hinmei_zh
								--,ma.nm_haigo_ryaku
							--FROM ma_haigo_mei ma
							--INNER JOIN 
								--( SELECT MAX(no_han) AS no_han,cd_haigo
								  --FROM ma_haigo_mei
								  --WHERE flg_mishiyo = @shiyoMishiyoFlg
								  --GROUP BY cd_haigo) maxHan
							--ON ma.cd_haigo = maxHan.cd_haigo
							--AND ma.no_han = maxHan.no_han
							--)   hin2 
							--ON daitai.cd_hinmei = hin2.cd_hinmei
						--WHERE
						--((@isExcel = @false AND daitai.cd_hinmei_daihyo = @cd_hinmei_daihyo) OR (@isExcel = @true))
						--AND daitai.kbn_hin_daihyo = @shikakariHinKbn
						--AND daitai.kbn_hin = @shikakariHinKbn
						--���g�p�\���Ȃ�/���g�p�\��
						--AND ((@shiyo = @false AND daitai.flg_mishiyo = @shiyoMishiyoFlg) OR (@shiyo = @true AND daitai.flg_mishiyo in (@shiyoMishiyoFlg,@mishiyoMishiyoFlg)))
					) temp

	)
		SELECT
            cnt
			, cd_hinmei_daihyo
			, nm_hinmei_daihyo
			, cd_hinmei
			, nm_hinmei
			, kbn_hin_daihyo
			, kbn_hin
			, flg_mishiyo
			, dt_create
			, cd_create
			, dt_update
			, cd_update
			, ts
		FROM (
				SELECT 
					MAX(RN) OVER() cnt
					,*
				FROM
					cte 
			) 
            cte_row
		WHERE RN BETWEEN @start AND @end
END
GO