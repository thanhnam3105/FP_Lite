IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_KeikakuCheckJissekiFlag_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_KeikakuCheckJissekiFlag_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =======================================================
-- Author:		tsujita.s
-- Create date: 2015.03.23
-- Last update: 2015.06.24 tsujita.s
-- Description:	�v���ʂ̎��у`�F�b�N�p
-- =======================================================
CREATE PROCEDURE [dbo].[usp_KeikakuCheckJissekiFlag_select]
    @seihinLot		varchar(14)	-- ���i���b�g�ԍ�
    ,@shikakariLot	varchar(14)	-- �d�|�i���b�g�ԍ�
    ,@seizoDate		datetime	-- ������
	,@falseFlg		smallint	-- FALSE�t���O
	,@dataKey		varchar(14)	-- �d�|�i�f�[�^�L�[
AS

	-- ////////// ���i���b�g�ԍ�������ꍇ
	IF LEN(@seihinLot) > 0
	BEGIN
		SELECT
			su.dt_seizo AS 'dt_seizo'
			,@seihinLot AS 'no_lot_seihin'
			,su.no_lot_shikakari AS 'no_lot_shikakari'
			,COALESCE(seihin.flg_jisseki, @falseFlg) AS 'flg_jisseki_seizo'
			,su.flg_jisseki AS 'flg_jisseki_shikomi'
		FROM (
			SELECT
				dt_seizo
				,no_lot_seihin
				,flg_jisseki
			FROM tr_keikaku_seihin
			WHERE no_lot_seihin = @seihinLot
		) seihin
		LEFT JOIN (
			SELECT
				no_lot_shikakari
				,dt_seizo
				,no_lot_seihin
			FROM tr_keikaku_shikakari
		) shikakari
		ON seihin.no_lot_seihin = shikakari.no_lot_seihin
		LEFT JOIN (
			SELECT
				no_lot_shikakari
				,dt_seizo
				,flg_jisseki
			FROM
				su_keikaku_shikakari
		) su
		ON shikakari.no_lot_shikakari = su.no_lot_shikakari
	END
	-- ////////// ���i���b�g�ԍ����Ȃ��A�d�|�i���b�g�ԍ�������ꍇ
	ELSE IF LEN(@shikakariLot) > 0
	BEGIN
		SELECT
			su.dt_seizo AS 'dt_seizo'
			,seihin.no_lot_seihin AS 'no_lot_seihin'
			,su.no_lot_shikakari AS 'no_lot_shikakari'
			,COALESCE(seihin.flg_jisseki, @falseFlg) AS 'flg_jisseki_seizo'
			,su.flg_jisseki AS 'flg_jisseki_shikomi'
		FROM (
			SELECT
				no_lot_shikakari
				,dt_seizo
				,flg_jisseki			
			FROM su_keikaku_shikakari
			WHERE no_lot_shikakari = @shikakariLot
		) su
		LEFT JOIN (
			SELECT
				no_lot_shikakari
				,dt_seizo
				,no_lot_seihin
			FROM tr_keikaku_shikakari
			WHERE no_lot_shikakari = @shikakariLot
			-- �d�|�i�d����ʂ���̂Ƃ���@dataKey�͖���
			AND (LEN(@dataKey) = 0 OR data_key = @dataKey)
		) shikakari
		ON shikakari.no_lot_shikakari = su.no_lot_shikakari
		LEFT JOIN (
			SELECT
				dt_seizo
				,no_lot_seihin
				,flg_jisseki
			FROM tr_keikaku_seihin
		) seihin			
		ON shikakari.no_lot_seihin = seihin.no_lot_seihin
	END
	-- ////////// �ǂ���̃��b�g�ԍ����Ȃ��ꍇ��0(���тȂ�)��ԋp����
	ELSE BEGIN
		SELECT
			@seizoDate AS 'dt_seizo'
			,@seihinLot AS 'no_lot_seihin'
			,@shikakariLot AS 'no_lot_shikakari'
			,@falseFlg AS 'flg_jisseki_seizo'
			,@falseFlg AS 'flg_jisseki_shikomi'
	END
GO
