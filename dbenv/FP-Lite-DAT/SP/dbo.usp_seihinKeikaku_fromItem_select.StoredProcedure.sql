IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_SeihinKeikaku_FromItem_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_SeihinKeikaku_FromItem_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =======================================================
-- Author:		sueyoshi.y
-- Create date: 2013.09.05
-- Last update: 2017.07.03 cho.k
-- Description:	品名コードからレシピ展開（第一階層目の検索）
-- args:	@hinmeiCode,@suryo,@shokubaCode,@seizoDate 画面の項目
--          @firstKaiso　第一階層
-- =======================================================
CREATE PROCEDURE [dbo].[usp_SeihinKeikaku_FromItem_select]
    @hinmeiCode varchar(14)
    ,@suryo decimal
    ,@shokubaCode varchar(10)
    ,@lineCode varchar(10)
    ,@seizoDate datetime
    ,@firstKaiso smallint
	,@hinmeiFalseFlag smallint
	,@haigoFalseFlag smallint -- udfから取得するため０をセット
	,@haigoMasterKbn smallint -- マスタ区分：配合マスタ
	,@shiyoFlg smallint -- 未使用フラグ：使用
AS

	DECLARE @haigoCode varchar(14)
	SELECT @haigoCode = cd_haigo FROM ma_hinmei WHERE cd_hinmei = @hinmeiCode

	-- 配合コードを元に、製造可能ラインマスタからラインコードを取得
	DECLARE @tmp_line varchar(10) = NULL
	
	-- 最初に製品の製造ラインと同一のラインコードを取得する。
	SELECT @tmp_line = cd_line FROM ma_seizo_line
	WHERE cd_haigo = @haigoCode
	AND kbn_master = @haigoMasterKbn
	AND cd_line = @lineCode
	AND flg_mishiyo = @shiyoFlg
	
	-- 取得できなかった場合は、次に優先度の高いラインコードを取得する。
	IF @tmp_line IS NULL
	BEGIN
		SELECT @tmp_line = cd_line FROM ma_seizo_line
		WHERE cd_haigo = @haigoCode
		AND kbn_master = @haigoMasterKbn
		AND flg_mishiyo = @shiyoFlg
		AND no_juni_yusen = (
				SELECT MIN(no_juni_yusen) AS no_juni_yusen
				FROM ma_seizo_line
				WHERE cd_haigo = @haigoCode
				AND kbn_master = @haigoMasterKbn
				AND flg_mishiyo = @shiyoFlg )
	END
	
	-- 取得できなかった場合はラインコードと職場コードにNULLを設定する(エラー処理はサービス側で行う)
	IF @tmp_line IS NULL
	BEGIN
		SET @lineCode = NULL
		SET @shokubaCode = NULL
	END
	ELSE BEGIN
		SET @lineCode = @tmp_line
		-- 製造可能ラインマスタから取得したラインコードを元に、ラインマスタから職場コードを取得
		SELECT @shokubaCode = cd_shokuba FROM ma_line
		WHERE cd_line = @lineCode
	END

    SELECT  
		DISTINCT 
        @hinmeiCode cd_hinmei
        ,@shokubaCode cd_shokuba
        ,@lineCode cd_line
        ,@seizoDate dt_seizo
        ,@suryo su_suryo
        ,ma_hinmei.ritsu_budomari hinmei_budomari 
        ,ma_hinmei.flg_tenkai hinmei_flg_tenkai 
        ,ma_hinmei.ritsu_hiju 
        ,ma_hinmei.su_iri 
        ,ma_hinmei.wt_ko 
        ,ma_hinmei.kbn_kanzan hinmei_kbn_kanzan
        ,ma_haigo_mei_yuko.cd_haigo 
        ,ma_haigo_mei_yuko.nm_haigo_ja 
        ,ma_haigo_mei_yuko.ritsu_budomari_mei haigo_budomari 
        ,ma_haigo_mei_yuko.wt_kihon haigo_wt_kihon 
        ,ma_haigo_mei_yuko.flg_gassan_shikomi 
        ,ma_haigo_mei_yuko.wt_haigo haigo_wt_haigo 
        ,ma_haigo_mei_yuko.flg_tenkai haigo_flg_tenkai 
        ,ma_haigo_mei_yuko.kbn_kanzan haigo_kbn_kanzan 
        ,ma_haigo_mei_yuko.wt_haigo_gokei
        ,ma_haigo_mei_yuko.ritsu_kihon
        ,CAST(0.0 AS DECIMAL) no_han 
        ,CAST(0.0 AS DECIMAL) recipe_wt_haigo 
        ,CAST(0.0 AS DECIMAL) no_kotei 
        ,CAST(0.0 AS DECIMAL) no_tonyu 
        ,CAST(0 AS SMALLINT) recipe_kbn_hin      -- 配合レシピマスタの品区分
        ,ma_haigo_mei_yuko.cd_haigo recipe_cd_hinmei  --本来はレシピの項目を取得するが一階層目は配合名の項目を取得する
        ,ma_haigo_mei_yuko.nm_haigo_ja recipe_nm_hinmei 
        ,CAST(0.0 AS DECIMAL) wt_shikomi 
        ,CAST(0.0 AS DECIMAL) recipe_budomari 
        ,'' cd_shizai 
        ,CAST(0.0 AS DECIMAL) su_shiyo
        ,@firstKaiso su_kaiso
        ,'' no_lot_shikakari_oya
    FROM ma_hinmei 
	LEFT OUTER JOIN udf_HaigoRecipeYukoHan(@haigoCode, @haigoFalseFlag, @seizoDate) ma_haigo_mei_yuko
    ON ma_hinmei.cd_haigo = ma_haigo_mei_yuko.cd_haigo 
    WHERE 
    ma_hinmei.flg_mishiyo = @hinmeiFalseFlag 
    AND ma_hinmei.cd_hinmei = '' + @hinmeiCode + ''
GO
