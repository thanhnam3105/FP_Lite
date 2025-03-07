IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_HendoHyoSimulation_delete') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_HendoHyoSimulation_delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===========================================================
-- Author:		higashiya.s
-- Create date: 2013.09.24
-- Description:	変動表シミュレーション：納入予実トラン削除処理
-- ===========================================================
CREATE PROCEDURE [dbo].[usp_HendoHyoSimulation_delete]
	 @flg_yojitsu smallint,
	 @dt_nonyu datetime,
	 @cd_hinmei varchar(14)

AS
BEGIN

-- ======================
-- 納入予実トラン削除処理
-- ======================
DELETE
	tr_nonyu
WHERE
	flg_yojitsu = @flg_yojitsu
AND dt_nonyu = @dt_nonyu
AND cd_hinmei = @cd_hinmei

END
GO
