IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_CheckKasaneKowakeExist_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_CheckKasaneKowakeExist_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
@\        F¬ª¯ÀÑ¶Ý`FbN  dË¬ªxÌ¬ªÀÑEÜ¡úÀ`FbN
t@C¼  Fusp_KowakeCheckKasaneKowake_select
ì¬ú      F2016.02.01 ADMAX shibao.s 
XVú      F2017.04.26 BRC   kanehira.d Q&BT|[gÎNo.56
*****************************************************/
CREATE PROCEDURE [dbo].[usp_CheckKasaneKowakeExist_select]

	@dt_seizo		        DATETIME		-- õðF»¢ú
	,@cd_seihin             VARCHAR(14)		-- õðF»iR[h
	,@su_kai				DECIMAL(4)		-- õðFñ
	,@su_ko		            DECIMAL(4)		-- õðFÂ
	,@no_tonyu_start		DECIMAL(4)		-- õðFdËJnüÔ
	,@no_tonyu_end			DECIMAL(4)		-- õðFdËI¹üÔ
	,@no_kotei 				DECIMAL(4)		-- õðFHöÔ
	,@cd_line				VARCHAR(10)		-- õðFCR[h
	,@no_lot_seihin 		VARCHAR(14)		-- õðF»ibgÔ
	,@kbn_seikihasu			SMALLINT		-- õðF³KA[æª	
	,@kbn_kowakehasu		SMALLINT		-- õðF³KA[¬ªæª
	,@ritsu_kihon           DECIMAL(5,2)    -- õðFî{{¦
AS
BEGIN

SELECT DISTINCT
	k.wt_haigo
	,k.cd_seihin
	,k.no_kotei
	,k.dt_seizo
	,k.su_ko
	,k.su_kai
	,k.kbn_hin
	,k.cd_line
	,k.kbn_seikihasu
	,k.kbn_kowakehasu
	,k.no_lot_seihin
	,k.no_lot_oya
	,k.cd_hinmei
	,k.no_tonyu
	,dt_shomi_kaifu
FROM 
	tr_kowake k
WHERE
	k.dt_seizo = @dt_seizo
	AND k.cd_seihin = @cd_seihin 
	AND k.su_kai = @su_kai
	AND k.su_ko = @su_ko
	AND k.no_tonyu BETWEEN @no_tonyu_start AND @no_tonyu_end
	AND k.no_kotei = @no_kotei
	AND k.cd_line = @cd_line
	AND k.no_lot_seihin = @no_lot_seihin
	AND k.kbn_seikihasu = @kbn_seikihasu
	AND k.kbn_kowakehasu = @kbn_kowakehasu
	AND (k.ritsu_kihon IS NULL
			OR k.ritsu_kihon = @ritsu_kihon)
Order by no_tonyu

END
GO
