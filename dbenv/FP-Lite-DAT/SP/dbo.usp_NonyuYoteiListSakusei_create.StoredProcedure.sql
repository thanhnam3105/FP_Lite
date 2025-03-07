IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_NonyuYoteiListSakusei_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_NonyuYoteiListSakusei_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =======================================================
-- Author:		higashiya.s
-- Create date: 2013.07.23
-- Description:	納入予定リスト作成：納入予実トラン登録処理
-- =======================================================
CREATE PROCEDURE [dbo].[usp_NonyuYoteiListSakusei_create]
	 @kbn_saiban varchar(2)
	,@kbn_prefix varchar(1)
	,@flg_yojitsu_yotei smallint
	,@flg_yojitsu_jisseki smallint
	,@no_nonyu varchar(13)
	,@dt_nonyu datetime
	,@cd_hinmei varchar(14)
	,@su_nonyu decimal(9,2)
	,@su_nonyu_hasu decimal(9,2)
	,@cd_torihiki varchar(13)
	,@cd_torihiki2 varchar(13)
	,@tan_nonyu decimal(12,4)
	,@kin_kingaku decimal(12,4)
	,@no_nonyusho varchar(20)
	,@kbn_zei smallint
	,@kbn_denso smallint
	,@flg_kakutei smallint
	,@dt_seizo datetime
	,@dt_nonyu_yotei datetime
	,@su_nonyu_yotei decimal(9,2)
	,@kbn_nyuko smallint
	,@su_nonyu_yotei_hasu	DECIMAL(9,2)

AS
BEGIN

-- 採番納入番号
DECLARE @no_nonyu_new varchar(14)
-- 実績用納入番号
DECLARE @no_nonyu_yotei varchar(14)

-- ================
-- 納入番号採番処理
-- ================
-- 納入番号が引き渡されていない場合、納入番号を採番する
IF @no_nonyu IS NULL
	EXEC dbo.usp_cm_Saiban
		@kbn_saiban,
		@kbn_prefix,
		@no_saiban = @no_nonyu_new output
ELSE
	SET @no_nonyu_new = @no_nonyu

IF @su_nonyu_yotei + @su_nonyu_yotei_hasu <> 0 and @dt_nonyu_yotei is not null
begin
	-- ======================
	-- 納入予実トラン登録処理(予定)
	-- ======================
	INSERT INTO
		tr_nonyu(
			 flg_yojitsu
			,no_nonyu
			,dt_nonyu
			,cd_hinmei
			,su_nonyu
			,su_nonyu_hasu
			,cd_torihiki
			,cd_torihiki2
			,tan_nonyu
			,kin_kingaku
			,no_nonyusho
			,kbn_zei
			,kbn_denso
			,flg_kakutei
			,dt_seizo
			,kbn_nyuko
		)
	VALUES
		(
			 @flg_yojitsu_yotei
			,@no_nonyu_new
			,@dt_nonyu_yotei
			,@cd_hinmei
			,@su_nonyu_yotei
			,@su_nonyu_yotei_hasu
			,@cd_torihiki
			,@cd_torihiki2
			,@tan_nonyu
			,@kin_kingaku
			,@no_nonyusho
			,@kbn_zei
			,@kbn_denso
			,@flg_kakutei
			,@dt_seizo
			,@kbn_nyuko
		)
end
IF @su_nonyu + @su_nonyu_hasu <> 0 and @dt_nonyu is not null and @kin_kingaku > 0
begin 

	-- 納入予定番号取得
	SET @no_nonyu_yotei = (
							SELECT
								yotei.no_nonyu
							FROM tr_nonyu yotei
							WHERE
								yotei.no_nonyu = @no_nonyu_new
								AND yotei.flg_yojitsu = 0
						  )




	-- ======================
	-- 納入予実トラン登録処理(実績)
	-- ======================
	INSERT INTO
		tr_nonyu(
			 flg_yojitsu
			,no_nonyu
			,dt_nonyu
			,cd_hinmei
			,su_nonyu
			,su_nonyu_hasu
			,cd_torihiki
			,cd_torihiki2
			,tan_nonyu
			,kin_kingaku
			,no_nonyusho
			,kbn_zei
			,kbn_denso
			,flg_kakutei
			,dt_seizo
			,no_nonyu_yotei
		)
	VALUES
		(
			 @flg_yojitsu_jisseki
			,@no_nonyu_new
			,@dt_nonyu
			,@cd_hinmei
			,@su_nonyu
			,@su_nonyu_hasu
			,@cd_torihiki
			,@cd_torihiki2
			,@tan_nonyu
			,@kin_kingaku
			,@no_nonyusho
			,@kbn_zei
			,@kbn_denso
			,@flg_kakutei
			,@dt_seizo
			,@no_nonyu_yotei
		)
end
END
GO
