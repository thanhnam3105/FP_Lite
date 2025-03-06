IF OBJECT_ID ('dbo.vw_tr_sap_shiyo_yojitsu_anbun_02', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_tr_sap_shiyo_yojitsu_anbun_02]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/************************************************************
�@�\		�F�������� �폜���̈��g�����폜�Ώی����r���[
�r���[��	�Fvw_tr_sap_shiyo_yojitsu_anbun_02
���l		�F
�쐬��		�F2015.07.09 ADMAX tsujita.s
�X�V��		�F2015.07.09 ADMAX tsujita.s
************************************************************/
CREATE VIEW [dbo].[vw_tr_sap_shiyo_yojitsu_anbun_02]
AS

	SELECT
		shikakari.no_seq
		,shikakari.kbn_shiyo_jisseki_anbun
		,shikakari.no_lot_shikakari
		,seihin.no_lot_seihin
		,shikakari.dt_shiyo_shikakari
		,shikakari.su_shiyo_shikakari
		,shikakari.kbn_jotai_denso
		,shikakari.ts
	FROM
		tr_sap_shiyo_yojitsu_anbun seihin
	INNER JOIN tr_sap_shiyo_yojitsu_anbun shikakari
	ON seihin.no_lot_shikakari = shikakari.no_lot_shikakari
GO
