IF OBJECT_ID ('dbo.vw_ma_kojo_01', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_ma_kojo_01]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_ma_kojo_01]
AS
SELECT
	ma_kojo.cd_kaisha as cd_kaisha
	,ma_kojo.cd_kojo as cd_kojo
	,ma_kojo.nm_kojo as nm_kojo
	,ma_kojo.nm_kojo as nm_kaisha
	,ma_kojo.dt_nendo_start as dt_nendo_start
	,ma_kojo.no_yubin1 as no_yubin1
	,ma_kojo.no_yubin2 as no_yubin2
	,ma_kojo.nm_jusho_1 as nm_jusho_1
	,ma_kojo.nm_jusho_2 as nm_jusho_2
	,ma_kojo.nm_jusho_3 as nm_jusho_3
	,ma_kojo.no_tel_1 as no_tel_1
	,ma_kojo.no_tel_2 as no_tel_2
	,ma_kojo.no_fax_1 as no_fax_1
	,ma_kojo.no_fax_2 as no_fax_2
	,ma_kojo.kbn_haigo_keisan_hoho as kbn_haigo_keisan_hoho
	,ma_kbn_haigo_keisan_hoho.nm_kbn_haigo_keisan_hoho as nm_kbn_haigo_keisan_hoho
	,ma_kojo.dt_kigen_chokuzen as dt_kigen_chokuzen
	,ma_kojo.dt_kigen_chikai as dt_kigen_chikai
	,ma_kojo.dt_create as dt_create
	,ma_kojo.cd_create as cd_create
	,ma_kojo.dt_update as dt_update
	,ma_kojo.cd_update as cd_update
	,ma_kojo.ts as ts
	,ma_kojo.no_com_reader_niuke as no_com_reader_niuke
FROM ma_kojo
LEFT OUTER JOIN ma_kbn_haigo_keisan_hoho
ON ma_kojo.kbn_haigo_keisan_hoho = ma_kbn_haigo_keisan_hoho.kbn_haigo_keisan_hoho
GO
