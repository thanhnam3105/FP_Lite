IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_LotNoBetsuZaikoShosaiChoseiHenpin_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_LotNoBetsuZaikoShosaiChoseiHenpin_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能        ：調整トラン 追加(返品時)
ファイル名  ：[usp_LotNoBetsuZaikoShosaiChoseiHenpin_create]
入力引数    ：@no_niuke, @dt_nitizi, @su_chosei, @cd_update, @kbn_zaiko, @cd_genka_center, @cd_soko, @biko, @kbn_Zaiko_Chosei_Henpin
出力引数    ：
戻り値      ：
作成日      ：2015.09.25 MJ ueno.k 
更新日      ：2016.12.13 BRC motojima.m 中文対応
*****************************************************/
CREATE PROCEDURE [dbo].[usp_LotNoBetsuZaikoShosaiChoseiHenpin_create]
	@no_niuke					VARCHAR(14)		--荷受番号
	, @cd_hinmei				VARCHAR(14)		--画面.品名コード
	, @dt_nitizi				DATETIME		--(ロットNo.別在庫詳細から渡された値)
	, @su_chosei				DECIMAL(12,6)	--調整数
	, @cd_update				VARCHAR(10)		--セッション情報ログインユーザーコード
    , @kbn_zaiko				SMALLINT		--明細/在庫区分
	, @cd_genka_center			VARCHAR(10)		--工場マスタ/原価センターコード
	, @cd_soko					VARCHAR(10)		--工場マスタ/倉庫コード
	--, @biko					VARCHAR(100)	--明細/備考
	, @biko						NVARCHAR(100)	--明細/備考
	, @kbn_Zaiko_Chosei_Henpin	VARCHAR(10)		--自動調整理由区分.返品

AS 

BEGIN

	--調整トラン追加処理(更新)
		--調整トラン追加
		UPDATE tr_chosei 
		SET 
			--TOsVN 17035 nt.toan 2023/03/16(Request #480) Start -->
			--su_chosei = @su_chosei
			biko = @biko
			--TOsVN 17035 nt.toan 2023/03/16(Request #480) End -->
			,nm_henpin = @biko
			,dt_update = GETUTCDATE()
			,cd_update = @cd_update
			,cd_genka_center = @cd_genka_center
			,cd_soko = @cd_soko
		WHERE 
			cd_hinmei = @cd_hinmei 
			AND dt_hizuke = @dt_nitizi
			AND no_niuke = @no_niuke
			AND kbn_zaiko = @kbn_zaiko
			AND cd_riyu = @kbn_Zaiko_Chosei_Henpin

END
GO
