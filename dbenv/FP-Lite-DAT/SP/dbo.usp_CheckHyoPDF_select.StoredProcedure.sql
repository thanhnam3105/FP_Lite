IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_CheckHyoPDF_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_CheckHyoPDF_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      <Author,,kobayashi.y>
-- Create date: <Create Date,,2013.11.18>
-- Last Update: <2017.01.19 kanehira.d>
-- Description: <Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_CheckHyoPDF_select]
	@no_lot_shikakari varchar(MAX)
	,@flg_mishiyo smallint
	,@kbn_hin_shikakari smallint	-- �萔�F�i�敪�F�d�|�i
	,@count int output
	,@cd_tani_shikakari VARCHAR(10) -- �萔�F�P�ʃR�[�h�FKg
	,@not_cd_hinmei VARCHAR(14)		-- �d�ʃ}�X�^�̏�ԋ敪�����̑��̏ꍇ�A�i���R�[�h�̓n�C�t�����Z�b�g����Ă���
	,@kbn_jotai_shikakari SMALLINT	-- �萔�F��ԋ敪�F�d�|�i
	,@kbn_jotai_sonota smallint		-- �萔�F��ԋ敪�F���̑�
	--,@comment VARCHAR(50)
	,@comment NVARCHAR(50)
	--,@mishiyo_comment VARCHAR(50)
	,@mishiyo_comment NVARCHAR(50)
AS
BEGIN

--	DECLARE @nm_tani_shikakari VARCHAR(12)
	DECLARE @nm_tani_shikakari NVARCHAR(12)
	SELECT
		@nm_tani_shikakari = tani_shikakari.nm_tani
	FROM ma_tani tani_shikakari
	WHERE
		tani_shikakari.cd_tani = @cd_tani_shikakari
		AND tani_shikakari.flg_mishiyo = @flg_mishiyo
	;

	SELECT
		DISTINCT shikakari.no_lot_shikakari
		,shokuba.nm_shokuba
		--shokuba.nm_shokuba
		,line.nm_line
		--,shikakari.no_lot_shikakari
		,shikakari.dt_seizo
		,haigo.cd_haigo
		,haigo.nm_haigo_ja
		,haigo.nm_haigo_en
		,haigo.nm_haigo_zh
		,haigo.nm_haigo_vi
		,haigo.wt_shikomi
		,haigo.no_kotei
		,haigo.no_tonyu
		,haigo.kbn_kanzan AS kbn_kanzan_haigo
		,yuko.no_han
		--,hinkbn.nm_kbn_hin
		,bunruikbn.nm_bunrui AS nm_kbn_hin
		,shikakari.wt_haigo_keikaku
		,shikakari.wt_haigo_keikaku_hasu
		,shikakari.ritsu_keikaku
		,shikakari.ritsu_keikaku_hasu
		,shikakari.su_batch_keikaku
		,shikakari.su_batch_keikaku_hasu
		,haigo.cd_hinmei
		,haigo.nm_hinmei
		,haigo.ritsu_budomari_recipe
		,haigo.wt_haigo_gokei
		,shikakari.wt_haigo_keikaku / haigo.wt_haigo_gokei AS haigo_bairitsu
		,shikakari.wt_haigo_keikaku_hasu / haigo.wt_haigo_gokei AS haigo_bairitsu_hasu
		--,tani.nm_tani
		,CASE haigo.kbn_hin
			WHEN @kbn_hin_shikakari THEN @nm_tani_shikakari
			ELSE tani.nm_tani
		END AS nm_tani
		,hinmei.kbn_kanzan AS kbn_kanzan_hinmei
		,haigo.wt_nisugata
		,haigo.wt_kowake
		,haigo.cd_mark
		,mark.mark
		,juryo_hin.wt_kowake AS wt_kowake_juryo_hin
		,juryo_kbn.wt_kowake AS wt_kowake_juryo_jyotai
		-- �D�揇�ʁF�@�@���i�v��Ȃ��A�@�@�@�@�@���g�p�R�����g
		--           �A�@���i�v�悠��(�P����)�A���i�R�[�h
		--           �B�@���i�v�悠��(����)�A�@�@�����g�p�R�����g
		,CASE 
			WHEN seihin.no_lot_seihin IS NULL THEN @mishiyo_comment
			WHEN count_shikakari.shikakari_lot_count = 1 THEN seihin_hinmei.cd_hinmei
			ELSE @comment
		 END AS cd_seihin
		-- �D�揇�ʁF�@�@���i�v��Ȃ��A�@�@�@�@�@���g�p�R�����g
		--           �A�@���i�v�悠��(�P����)�A���i��
		--           �B�@���i�v�悠��(����)�A�@�@�����g�p�R�����g 
		,CASE  
			WHEN seihin.no_lot_seihin IS NULL THEN @mishiyo_comment
			WHEN count_shikakari.shikakari_lot_count = 1 THEN  seihin_hinmei.nm_hinmei_ja
			ELSE @comment
		 END AS nm_seihin_hinmei_ja 
		-- �D�揇�ʁF�@�@���i�v��Ȃ��A�@�@�@�@�@���g�p�R�����g
		--           �A�@���i�v�悠��(�P����)�A���i��
		--           �B�@���i�v�悠��(����)�A�@�@�����g�p�R�����g 
		,CASE  
			WHEN seihin.no_lot_seihin IS NULL THEN @mishiyo_comment
			WHEN count_shikakari.shikakari_lot_count = 1 THEN  seihin_hinmei.nm_hinmei_en
			ELSE @comment
		 END AS nm_seihin_hinmei_en 
		-- �D�揇�ʁF�@�@���i�v��Ȃ��A�@�@�@�@�@���g�p�R�����g
		--           �A�@���i�v�悠��(�P����)�A���i��
		--           �B�@���i�v�悠��(����)�A�@�@�����g�p�R�����g  
		,CASE 
			WHEN seihin.no_lot_seihin IS NULL THEN @mishiyo_comment
			WHEN count_shikakari.shikakari_lot_count = 1 THEN  seihin_hinmei.nm_hinmei_zh
			ELSE @comment
		 END AS nm_seihin_hinmei_zh 
		 -- �D�揇�ʁF�@�@���i�v��Ȃ��A�@�@�@�@�@���g�p�R�����g
		--           �A�@���i�v�悠��(�P����)�A���i��
		--           �B�@���i�v�悠��(����)�A�@�@�����g�p�R�����g  
		,CASE 
			WHEN seihin.no_lot_seihin IS NULL THEN @mishiyo_comment
			WHEN count_shikakari.shikakari_lot_count = 1 THEN  seihin_hinmei.nm_hinmei_vi
			ELSE @comment
		 END AS nm_seihin_hinmei_vi
	FROM 
		su_keikaku_shikakari shikakari
		LEFT OUTER JOIN 
		(
			SELECT
				shikakarisum_join.dt_seizo
				,shikakarisum_join.cd_shikakari_hin
				,shikakarisum_join.cd_shokuba
				,shikakarisum_join.cd_line
				,MAX(yukoHan.no_han) AS no_han
				,MAX(yukoHan.dt_from) AS dt_from
			FROM
			(
				SELECT
					udf.no_han
					,udf.dt_from
					,udf.cd_haigo
				FROM udf_HaigoRecipeYukoHan(null, @flg_mishiyo, null) udf
			) yukoHan
			LEFT OUTER JOIN su_keikaku_shikakari shikakarisum_join
			ON yukoHan.cd_haigo = shikakarisum_join.cd_shikakari_hin
			AND yukoHan.dt_from <= shikakarisum_join.dt_seizo
			GROUP BY  
				shikakarisum_join.dt_seizo
				,shikakarisum_join.cd_shikakari_hin
				,shikakarisum_join.cd_shokuba
				,shikakarisum_join.cd_line
		) yuko
		ON shikakari.dt_seizo = yuko.dt_seizo
		AND shikakari.cd_shikakari_hin = yuko.cd_shikakari_hin
		AND shikakari.cd_shokuba = yuko.cd_shokuba
		AND shikakari.cd_line = yuko.cd_line
		LEFT OUTER JOIN 
		(
			SELECT
				udf.cd_haigo 
				,udf.no_han
				,udf.no_tonyu
				,udf.no_kotei
				,udf.dt_from
				,udf.nm_haigo_ja
				,udf.nm_haigo_en
				,udf.nm_haigo_zh
				,udf.nm_haigo_vi
				,udf.ritsu_budomari_recipe 
				,udf.cd_hinmei
				,udf.nm_hinmei
				,udf.wt_nisugata
				,udf.wt_kowake 
				,udf.flg_gassan_shikomi
				,udf.kbn_hin
				,udf.wt_shikomi
				,udf.kbn_kanzan
				,udf.wt_haigo_gokei
				,udf.cd_mark
				,udf.cd_bunrui
			FROM udf_HaigoRecipeYukoHan(null, @flg_mishiyo, null) udf
		) haigo
		ON shikakari.cd_shikakari_hin = haigo.cd_haigo
		AND yuko.dt_from = haigo.dt_from
		AND yuko.no_han = yuko.no_han
		-- �i�敪��
		LEFT OUTER JOIN ma_kbn_hin hinkbn
		ON haigo.kbn_hin = hinkbn.kbn_hin
		-- �i��
		LEFT OUTER JOIN ma_hinmei hinmei
		ON haigo.cd_hinmei = hinmei.cd_hinmei
		-- �E�ꖼ
		LEFT OUTER JOIN ma_shokuba shokuba
		ON shikakari.cd_shokuba = shokuba.cd_shokuba
		-- ���C����
		LEFT OUTER JOIN ma_line line
		ON shikakari.cd_shokuba = line.cd_shokuba
		AND shikakari.cd_line = line.cd_line
		-- �P��
		LEFT OUTER JOIN ma_tani tani
		ON hinmei.cd_tani_shiyo = tani.cd_tani
		AND tani.flg_mishiyo = @flg_mishiyo
		-- �d�|�i����
		LEFT OUTER JOIN ma_bunrui bunruikbn
		ON haigo.cd_bunrui = bunruikbn.cd_bunrui
		AND bunruikbn.kbn_hin = @kbn_hin_shikakari
		-- �������d�ʁi�i�R�[�h���Ɓj
		LEFT OUTER JOIN ma_juryo juryo_hin
		ON haigo.kbn_hin = juryo_hin.kbn_hin
		AND haigo.cd_hinmei = juryo_hin.cd_hinmei
		AND juryo_hin.kbn_jotai = @kbn_jotai_sonota
		-- �������d�ʁi�i�敪���Ɓj
		LEFT OUTER JOIN 
		(
			SELECT 
				juryo.cd_hinmei
				,juryo.kbn_hin
				,juryo.kbn_jotai
				,juryo.wt_kowake
			FROM ma_juryo juryo
			WHERE
				juryo.cd_hinmei = @not_cd_hinmei
				AND juryo.kbn_jotai <> @kbn_jotai_sonota
		) juryo_kbn
		ON
		(
			(
				hinmei.kbn_hin = juryo_kbn.kbn_hin
				AND hinmei.kbn_jotai = juryo_kbn.kbn_jotai
			)
			 OR 
			(
				juryo_kbn.kbn_hin = haigo.kbn_hin
				AND juryo_kbn.kbn_jotai = @kbn_jotai_shikakari
			)
		)

		-- �}�[�N
		LEFT OUTER JOIN ma_mark mark
		ON haigo.cd_mark = mark.cd_mark
		
		-- �����d�|�i���b�gNo.���������邩�J�E���g����
		LEFT OUTER JOIN
		(
			SELECT 
				COUNT(keikaku_shikakari.no_lot_shikakari) AS shikakari_lot_count
				,keikaku_shikakari.no_lot_shikakari
				, MAX(no_lot_seihin) AS no_lot_seihin
			FROM tr_keikaku_shikakari keikaku_shikakari
			GROUP BY keikaku_shikakari.no_lot_shikakari
		) count_shikakari
		ON shikakari.no_lot_shikakari = count_shikakari.no_lot_shikakari
	
	    -- ���i�g����
		LEFT OUTER JOIN tr_keikaku_seihin seihin
		ON seihin.no_lot_seihin = count_shikakari.no_lot_seihin
		
		-- �i���}�X�^�i���i�j
		LEFT OUTER JOIN ma_hinmei seihin_hinmei
		ON seihin.cd_hinmei = seihin_hinmei.cd_hinmei
	
	WHERE 
		shikakari.no_lot_shikakari IN (SELECT Id FROM udf_SplitCommaValue(@no_lot_shikakari))
	ORDER BY
		shikakari.no_lot_shikakari
		,haigo.no_kotei
		,haigo.no_tonyu
		
END
GO