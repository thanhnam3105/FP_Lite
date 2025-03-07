IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_HaigoMaster_update') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_HaigoMaster_update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,okada.k>
-- Create date: <Create Date,,2013.06.18>
-- Last Update: <2018.01.30 motojima.m>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_HaigoMaster_update]
	@cd_haigo				AS VARCHAR(14)		-- 配合コード
	,@nm_haigo_ja			AS NVARCHAR(50)		-- 配合名(日本語)
	--,@nm_haigo_en			AS VARCHAR(50)		-- 配合名(英語)
	,@nm_haigo_en			AS NVARCHAR(50)		-- 配合名(英語)
	,@nm_haigo_zh			AS NVARCHAR(50)		-- 配合名(中国語)
	,@nm_haigo_vi			AS NVARCHAR(50)
	--,@nm_haigo_ryaku		AS VARCHAR(50)		-- 配合名略
	,@nm_haigo_ryaku		AS NVARCHAR(50)		-- 配合名略
	,@ritsu_budomari		AS DECIMAL(5,2)		-- 歩留
	,@wt_kihon				AS DECIMAL(4,0)		-- 基本重量
	,@ritsu_kihon			AS DECIMAL(5,2)		-- 基本倍率
	,@flg_gassan_shikomi	AS SMALLINT			-- 仕込合算
	,@wt_saidai_shikomi		AS DECIMAL(12,6)	-- 仕込最大重量
	,@no_han				AS DECIMAL(4,0)		-- 版
	,@wt_haigo				AS DECIMAL(12,6)	-- 配合重量
	,@wt_haigo_gokei		AS DECIMAL(12,6)	-- 配合重量合計
	--,@biko				AS VARCHAR(50)		-- 備考
	,@biko					AS NVARCHAR(50)		-- 備考
	,@no_seiho				AS VARCHAR(20)		-- 製法番号
	,@cd_tanto_seizo		AS VARCHAR(10)		-- 製造担当者コード
	,@dt_seizo_koshin		AS DATETIME			-- 製造更新日付
	,@cd_tanto_hinkan		AS VARCHAR(10)		-- 品管担当者コード
	,@dt_hinkan_koshin		AS DATETIME			-- 品管更新日付
	,@dt_from				AS DATETIME			-- 有効日付(開始)
	,@kbn_kanzan			AS VARCHAR(10)		-- 換算区分
	,@ritsu_hiju			AS DECIMAL(6,4)		-- 比重
	,@flg_shorihin			AS SMALLINT			-- 処理品フラグ
	,@flg_tanto_hinkan		AS SMALLINT			-- 品管担当フラグ
	,@flg_tanto_seizo		AS SMALLINT			-- 製造担当フラグ
	,@kbn_shiagari			AS SMALLINT			-- 仕上がり区分
	,@cd_bunrui				AS VARCHAR(10)		-- 仕掛品分類
	,@flg_mishiyo			AS SMALLINT			-- 未使用フラグ
	,@dt_create				AS DATETIME			-- 作成日時
	,@cd_create				AS VARCHAR(10)		-- 作成者
	,@dt_update				AS DATETIME			-- 更新日時
	,@cd_update				AS VARCHAR(10)		-- 更新者
	,@wt_kowake				AS DECIMAL(12,6)	-- 小分け重量(調味液ラベル用)
	,@su_kowake				AS DECIMAL(4,0)		-- 小分け数(調味液ラベル用)
	,@flg_tenkai			AS SMALLINT			-- 展開フラグ
	,@dd_shomi				AS DECIMAL(4,0)		-- 賞味期間
	,@kbn_hokan				AS VARCHAR(10)		-- 保管区分
AS
BEGIN

	-- 未使用フラグにチェックなしの場合
	IF @flg_mishiyo = 0
	BEGIN
		-- 1版以外で1版が未使用の場合は、1版の未使用フラグを使用に更新
		IF @no_han <> 1
		BEGIN
			DECLARE @flg_mishiyo_1 AS SMALLINT -- 1版の未使用フラグ
			SELECT
				@flg_mishiyo_1 = flg_mishiyo
			FROM ma_haigo_mei
			WHERE
				cd_haigo = @cd_haigo
				AND no_han = 1
			
			IF @flg_mishiyo_1 = 1
			BEGIN
				UPDATE ma_haigo_mei
				SET 
					flg_mishiyo = 0
					,dt_update = @dt_update
					,cd_update = @cd_update
				WHERE
					cd_haigo = @cd_haigo
					AND no_han = 1
			END
		END
		-- 該当版の配合名マスタを更新
		UPDATE ma_haigo_mei
		SET 
			nm_haigo_ja = @nm_haigo_ja
			,nm_haigo_en = @nm_haigo_en
			,nm_haigo_zh = @nm_haigo_zh 
			,nm_haigo_vi = @nm_haigo_vi
			,nm_haigo_ryaku = @nm_haigo_ryaku
			,ritsu_budomari = @ritsu_budomari
			,wt_kihon = @wt_kihon
			,ritsu_kihon = @ritsu_kihon
			,flg_gassan_shikomi = @flg_gassan_shikomi
			,wt_saidai_shikomi = @wt_saidai_shikomi
			,wt_haigo = @wt_haigo
			,wt_haigo_gokei = @wt_haigo_gokei
			,biko = @biko
			,no_seiho = @no_seiho
			,cd_tanto_seizo = @cd_tanto_seizo
			,dt_seizo_koshin = @dt_seizo_koshin
			,cd_tanto_hinkan = @cd_tanto_hinkan
			,dt_hinkan_koshin = @dt_hinkan_koshin
			,dt_from = @dt_from
			,kbn_kanzan = @kbn_kanzan
			,ritsu_hiju = @ritsu_hiju
			,flg_shorihin = @flg_shorihin
			,flg_tanto_hinkan = @flg_tanto_hinkan
			,flg_tanto_seizo = @flg_tanto_seizo
			,kbn_shiagari = @kbn_shiagari
			,cd_bunrui = @cd_bunrui
			,flg_mishiyo = @flg_mishiyo
			,dt_create = @dt_create
			,cd_create = @cd_create
			,dt_update = @dt_update
			,cd_update = @cd_update
			,wt_kowake = @wt_kowake
			,su_kowake = @su_kowake
			,flg_tenkai = @flg_tenkai
			,dd_shomi = @dd_shomi
			,kbn_hokan = @kbn_hokan
		WHERE 
			cd_haigo = @cd_haigo
			AND no_han = @no_han
	END
	-- 未使用フラグにチェックありの場合
	ELSE
	BEGIN
	-- 該当版以外の未使用フラグを1に更新
		UPDATE ma_haigo_mei
		SET 
			flg_mishiyo = 1
			,dt_update = @dt_update
			,cd_update = @cd_update
		WHERE 
			cd_haigo = @cd_haigo
			AND no_han <> @no_han

	-- 該当版の配合名マスタを更新
		UPDATE ma_haigo_mei
		SET 
			nm_haigo_ja = @nm_haigo_ja
			,nm_haigo_en = @nm_haigo_en
			,nm_haigo_zh = @nm_haigo_zh
			,nm_haigo_vi = @nm_haigo_vi
			,nm_haigo_ryaku = @nm_haigo_ryaku
			,ritsu_budomari = @ritsu_budomari
			,wt_kihon = @wt_kihon
			,ritsu_kihon = @ritsu_kihon
			,flg_gassan_shikomi = @flg_gassan_shikomi
			,wt_saidai_shikomi = @wt_saidai_shikomi
			,wt_haigo = @wt_haigo
			,wt_haigo_gokei = @wt_haigo_gokei
			,biko = @biko
			,no_seiho = @no_seiho
			,cd_tanto_seizo = @cd_tanto_seizo
			,dt_seizo_koshin = @dt_seizo_koshin
			,cd_tanto_hinkan = @cd_tanto_hinkan
			,dt_hinkan_koshin = @dt_hinkan_koshin
			,dt_from = @dt_from
			,kbn_kanzan = @kbn_kanzan
			,ritsu_hiju = @ritsu_hiju
			,flg_shorihin = @flg_shorihin
			,flg_tanto_hinkan = @flg_tanto_hinkan
			,flg_tanto_seizo = @flg_tanto_seizo
			,kbn_shiagari = @kbn_shiagari
			,cd_bunrui = @cd_bunrui
			,flg_mishiyo = @flg_mishiyo
			,dt_create = @dt_create
			,cd_create = @cd_create
			,dt_update = @dt_update
			,cd_update = @cd_update
			,wt_kowake = @wt_kowake
			,su_kowake = @su_kowake
			,flg_tenkai = @flg_tenkai
			,dd_shomi = @dd_shomi
			,kbn_hokan = @kbn_hokan
		WHERE 
			cd_haigo = @cd_haigo
			AND no_han = @no_han
	END

END
GO
