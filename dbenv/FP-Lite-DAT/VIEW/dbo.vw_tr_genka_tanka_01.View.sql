IF OBJECT_ID ('dbo.vw_tr_genka_tanka_01', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_tr_genka_tanka_01]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_tr_genka_tanka_01] as

	SELECT
		gen.dt_genka_keisan
		,hin.cd_hinmei
		,hin.kbn_hin
		,hin.cd_bunrui
	FROM
		tr_genka_tanka gen

	INNER JOIN ma_hinmei hin
	ON gen.cd_hinmei = hin.cd_hinmei
GO
