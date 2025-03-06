IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_HendoHyoSimulation_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_HendoHyoSimulation_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===========================================================
-- Author:		higashiya.s
-- Create date: 2013.09.24
-- Description:	•Ï“®•\ƒVƒ~ƒ…ƒŒ[ƒVƒ‡ƒ“F”[“ü—\Àƒgƒ‰ƒ““o˜^ˆ—
-- ===========================================================
CREATE PROCEDURE [dbo].[usp_HendoHyoSimulation_create]
	 @kbn_saiban varchar(2)
	,@kbn_prefix varchar(1)
	,@flg_yojitsu smallint
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
	,@kbn_nyuko smallint

AS
BEGIN

-- Ì”Ô”[“ü”Ô†
DECLARE @no_nonyu_new varchar(14)

-- ================
-- ”[“ü”Ô†Ì”Ôˆ—
-- ================
EXEC dbo.usp_cm_Saiban
	@kbn_saiban,
	@kbn_prefix,
	@no_saiban = @no_nonyu_new output

-- ======================
-- ”[“ü—\Àƒgƒ‰ƒ““o˜^ˆ—
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
		 @flg_yojitsu
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
		,@kbn_nyuko
	)

END
GO
