IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_ShiyoJiossekiIkkatsuDenso_update') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_ShiyoJiossekiIkkatsuDenso_update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
@\		FgpÀÑê` XV
t@C¼	Fusp_ShiyoJiossekiIkkatsuDenso_update
ì¬ú		F2015.07.02  ADMAX tsujita.s
XVú		F
*****************************************************/
CREATE PROCEDURE [dbo].[usp_ShiyoJiossekiIkkatsuDenso_update]
	@dt_from			DATETIME	-- õðF`Jnú
	,@dt_to				DATETIME	-- õðF`I¹ú
	,@kbn_denso_machi	SMALLINT	-- ÅèlF`óÔæªF`Ò¿
	,@kbn_denso_midenso	SMALLINT	-- ÅèlF`óÔæªF¢`
AS
BEGIN
	SET NOCOUNT ON

	UPDATE
		tr_sap_shiyo_yojitsu_anbun
	SET
		kbn_jotai_denso = @kbn_denso_machi
	WHERE
		dt_shiyo_shikakari BETWEEN @dt_from AND @dt_to
	AND kbn_jotai_denso = @kbn_denso_midenso

END

GO
