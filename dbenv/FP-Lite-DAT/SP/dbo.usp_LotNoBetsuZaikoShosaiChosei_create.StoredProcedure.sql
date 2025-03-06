IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_LotNoBetsuZaikoShosaiChosei_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_LotNoBetsuZaikoShosaiChosei_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能        ：調整トラン 追加
ファイル名  ：usp_LotNoBetsuZaikoShosaiChosei_create
入力引数    ：@no_niuke, @dt_niuke, @dt_nitizi,@cd_riyu
            ：@cd_riyu2, @su_chosei, @su_moto_chosei,@biko
            ：@cd_update,@cd_location,@cd_genka_center,@cd_soko
            ：@no_nohinsho,@no_niuke,@kbn_zaiko,@cd_tirihiki
出力引数    ：
戻り値      ：
作成日      ：2013.11.21  ADMAX endo.y
更新日      ：2015.12.21  ADMAX s.shibao
更新日      ：2016.12.19  BRC   motojima.m 中文対応
*****************************************************/
CREATE PROCEDURE [dbo].[usp_LotNoBetsuZaikoShosaiChosei_create]
	 @no_seq_chosei		 VARCHAR(14)		--調整トラン用シーケンス番号 
	, @no_seq_chosei2	 VARCHAR(14)		--調整トラン用シーケンス番号 
	, @cd_hinmei		 VARCHAR(14)		--画面.品名コード
	, @dt_nitizi         DATETIME		    --(ロットNo.別在庫詳細から渡された値)
	, @cd_riyu			 VARCHAR(10)		--理由コード（相殺用）
	, @cd_riyu2			 VARCHAR(10)		--理由コード（新規用）
	, @su_chosei		 DECIMAL(12,6)	    --調整数
	, @su_moto_chosei	 DECIMAL(12,6)	    --調整数	 
	--, @biko            VARCHAR(50)		--画面.備考
	, @biko              NVARCHAR(50)		--画面.備考
	, @cd_update         VARCHAR(10)		--セッション情報ログインユーザーコード
	, @cd_location       VARCHAR(10)		--ロケーションコード
	, @cd_genka_center	 VARCHAR(10)	    --原価センターコード
	, @cd_soko			 VARCHAR(10)	    --倉庫コード
	--, @no_nohinsho	 VARCHAR(14)	    --納品書番号
	, @no_nohinsho		 NVARCHAR(14)	    --納品書番号
	, @no_niuke          VARCHAR(14)        --荷受番号
	, @kbn_zaiko         SMALLINT           --在庫区分
	, @cd_tirihiki       VARCHAR(13)        --取引先コード
AS	
BEGIN

	--調整トラン追加処理(変更前調整数登録)
		INSERT INTO tr_chosei
		(
			[no_seq]
			, [cd_hinmei]
			, [dt_hizuke]
			, [cd_riyu]
			, [su_chosei]
			, [biko]
			, [cd_seihin]
			, [dt_update]
			, [cd_update]
			--, [cd_kura]
			, [cd_genka_center] 
            , [cd_soko] 
            , [no_nohinsho] 
            , [no_niuke] 
            , [kbn_zaiko] 
            , [cd_torihiki] 
		)
		VALUES
		(
			@no_seq_chosei
			, @cd_hinmei
			, @dt_nitizi
			, @cd_riyu
			, @su_moto_chosei
			, @biko
			, ''
			, GETUTCDATE()
			, @cd_update
			--, @cd_location
			, @cd_genka_center
			, @cd_soko
			, @no_nohinsho
			, @no_niuke 
			, @kbn_zaiko
			, @cd_tirihiki

		)
	--調整トラン追加処理(変更後調整数登録)	
		INSERT INTO tr_chosei
		(
			[no_seq]
			, [cd_hinmei]
			, [dt_hizuke]
			, [cd_riyu]
			, [su_chosei]
			, [biko]
			, [cd_seihin]
			, [dt_update]
			, [cd_update]
			--, [cd_kura]
			, [cd_genka_center] 
            , [cd_soko] 
            , [no_nohinsho] 
            , [no_niuke] 
            , [kbn_zaiko] 
            , [cd_torihiki] 

		)
		VALUES
		(
			@no_seq_chosei2
			, @cd_hinmei
			, @dt_nitizi
			, @cd_riyu2
			, @su_chosei
			, @biko
			, ''
			, GETUTCDATE()
			, @cd_update
			--, @cd_location
			, @cd_genka_center
			, @cd_soko
			, @no_nohinsho
			, @no_niuke 
			, @kbn_zaiko
			, @cd_tirihiki
		)

END
GO
