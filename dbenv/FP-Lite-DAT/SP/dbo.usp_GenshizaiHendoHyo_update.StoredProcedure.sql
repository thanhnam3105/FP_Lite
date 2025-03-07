IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_GenshizaiHendoHyo_update') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_GenshizaiHendoHyo_update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能  ：原資材変動表 保存処理を行う
出力引数 ：なし
戻り値  ：成功時[0] 失敗時[0以外のエラーコード]
作成日  ：2013.08.27 kaneko.m
更新日  ：2016.05.20 motojima.m
 *****************************************************/
CREATE PROCEDURE [dbo].[usp_GenshizaiHendoHyo_update]
	@kbn_saiban_chosei varchar(2)			-- 調整トラン_採番区分
	,@kbn_prefix_chosei varchar(1)			-- 調整トラン_採番区分prefix
	,@kbn_saiban_nonyu varchar(2)			-- 納入トラン_採番区分
	,@kbn_prefix_nonyu varchar(1)			-- 納入トラン_採番区分prefix
	,@cd_hinmei VARCHAR(14)					-- 検索条件/品名コード
	,@dt_hizuke datetime					-- 明細/日付
	,@su_nonyu decimal(9,2)					-- 明細/納入数
	,@su_chosei decimal(12,6)				-- 明細/調整数
	,@su_keisanzaiko decimal(14,6)			-- 明細/計算在庫
	,@su_jitsuzaiko decimal(14,6)			-- 明細/実在庫
	,@cd_update VARCHAR(10)					-- 更新者(ログインユーザコード)
	,@flg_yojitsu smallint					-- 定数：予実フラグ：予定
	,@flg_chosei smallint					-- 定数：理由区分：調整理由
	,@flg_update_tr_chosei smallint			-- 調整トラン更新フラグ
	,@flg_delete_tr_chosei smallint			-- 調整トラン削除フラグ
	,@flg_update_tr_nonyu smallint			-- 納入トラン更新フラグ
	,@flg_delete_tr_nonyu smallint			-- 納入トラン削除フラグ
	,@flg_update_tr_zaiko_keisan smallint	-- 計算在庫トラン更新フラグ
	,@flg_delete_tr_zaiko_keisan smallint	-- 計算在庫トラン削除フラグ
	,@flg_update_tr_zaiko smallint			-- 在庫トラン更新フラグ
	,@flg_delete_tr_zaiko smallint			-- 在庫トラン削除フラグ
	,@cd_kg VARCHAR(10)						-- 定数：単位コード：Kg
	,@cd_li VARCHAR(10)						-- 定数：単位コード：L
	,@cs decimal(9,2)						-- 納入数
	,@hasu decimal(9,2)						-- 納入端数
	,@kbn_ryohin smallint					-- 定数：在庫区分：良品
	,@cd_soko VARCHAR(10)					-- 在庫トランの倉庫コード
	,@kbn_nyuko_yusho smallint				-- 定数：入庫区分：有償
	,@cd_genka VARCHAR(10)					-- 定数：原価センターコード
	,@cd_riyu VARCHAR(10)					-- 定数：理由コード
	
AS
BEGIN
	DECLARE @msg varchar(50)
    DECLARE @no_chosei_new varchar(14)
            ,@no_nonyu_new varchar(14)
	DECLARE @tan_ko decimal(12, 4)
	DECLARE @utc_sysdate datetime = GETUTCDATE()

    /****************************************
    　納入予実トランの削除および更新
    ****************************************/
   -- --既存データより変更があれば
   -- IF (SELECT su_nonyu FROM tr_nonyu
   --     WHERE flg_yojitsu = @flg_yojitsu
   --         AND cd_hinmei = @cd_hinmei
   --         AND dt_nonyu = @dt_hizuke
   --         AND su_nonyu = @cs
			--AND su_nonyu_hasu = @hasu ) IS NULL

	IF(SELECT
			tr.su_nonyu
		FROM
			(
				SELECT
					ROUND(SUM(su_nonyu), 2, 1) AS su_nonyu
					,ROUND(SUM(su_nonyu_hasu), 2, 1) AS su_nonyu_hasu
				FROM tr_nonyu
				WHERE
					dt_nonyu = @dt_hizuke
					AND cd_hinmei = @cd_hinmei
					AND flg_yojitsu = @flg_yojitsu
				GROUP BY dt_nonyu, cd_hinmei
			) tr
		WHERE
			tr.su_nonyu = @cs
			AND tr.su_nonyu_hasu = @hasu) IS NULL

    BEGIN
        IF @flg_delete_tr_nonyu = 1
        BEGIN
            DELETE tr_nonyu
            WHERE flg_yojitsu = @flg_yojitsu
                AND cd_hinmei = @cd_hinmei
                AND dt_nonyu = @dt_hizuke
        END
        IF @flg_update_tr_nonyu = 1
        BEGIN
            --採番処理
            EXEC dbo.usp_cm_Saiban @kbn_saiban_nonyu, @kbn_prefix_nonyu, @no_saiban = @no_nonyu_new output
            -- 新規登録処理
            INSERT INTO tr_nonyu (
                flg_yojitsu,
                no_nonyu,
                dt_nonyu,
                cd_hinmei,
                su_nonyu,
                su_nonyu_hasu, 
                cd_torihiki,
                cd_torihiki2,
                tan_nonyu,
                kin_kingaku,
                no_nonyusho,
                kbn_zei, 
                kbn_denso,
                flg_kakutei,
                dt_seizo,
                kbn_nyuko
            )
            SELECT 
                @flg_yojitsu,
                @no_nonyu_new,
                @dt_hizuke,
                @cd_hinmei,
				@cs,
				@hasu,
--				case when COALESCE(konyu.cd_tani_nonyu,hinmei.cd_tani_shiyo) = @cd_kg 
--							OR COALESCE(konyu.cd_tani_nonyu,hinmei.cd_tani_shiyo) = @cd_li
--						THEN floor(@su_nonyu / (COALESCE(konyu.wt_nonyu,hinmei.wt_ko) * COALESCE(konyu.su_iri,hinmei.su_iri)))
--						ELSE floor(@su_nonyu / (COALESCE(konyu.wt_nonyu,hinmei.wt_ko) * COALESCE(konyu.su_iri,hinmei.su_iri)))
--				END,
--
--				case when COALESCE(konyu.cd_tani_nonyu,hinmei.cd_tani_shiyo) = @cd_kg 
--							OR COALESCE(konyu.cd_tani_nonyu,hinmei.cd_tani_shiyo) = @cd_li
--						THEN (round(@su_nonyu/(COALESCE(konyu.wt_nonyu,hinmei.wt_ko) * COALESCE(konyu.su_iri,hinmei.su_iri)),3) - floor(@su_nonyu / (COALESCE(konyu.wt_nonyu,hinmei.wt_ko) * COALESCE(konyu.su_iri,hinmei.su_iri))))*1000
--				ELSE ceiling((round(@su_nonyu/(COALESCE(konyu.wt_nonyu,hinmei.wt_ko) * COALESCE(konyu.su_iri,hinmei.su_iri)),3)*1000-
--						floor(@su_nonyu / (COALESCE(konyu.wt_nonyu,hinmei.wt_ko) * COALESCE(konyu.su_iri,hinmei.su_iri)))*1000)/1000 * COALESCE(konyu.su_iri,hinmei.su_iri) *100)/100
--
--				END,
                konyu.cd_torihiki,
                null,
                COALESCE(konyu.tan_nonyu, hinmei.tan_nonyu),
                0,
                '',
                COALESCE(hinmei.kbn_zei, 0),
                null,
                null,
                null,
                @kbn_nyuko_yusho
            FROM ma_hinmei hinmei
            LEFT OUTER JOIN
            (
                SELECT
                    ma_konyu.cd_hinmei,
                    ma_konyu.cd_torihiki,
					ma_konyu.cd_tani_nonyu,
					ma_konyu.wt_nonyu,
					ma_konyu.su_iri,
                    ma_konyu.tan_nonyu
                FROM ma_konyu
                INNER JOIN
                (
                    SELECT
                        cd_hinmei,
                        MIN(no_juni_yusen) AS no_juni_yusen
                    FROM ma_konyu
                    WHERE cd_hinmei = @cd_hinmei
                    GROUP BY cd_hinmei
                ) pre_konyu
                ON ma_konyu.cd_hinmei = pre_konyu.cd_hinmei
                AND ma_konyu.no_juni_yusen = pre_konyu.no_juni_yusen
            )konyu
            ON hinmei.cd_hinmei = konyu.cd_hinmei
            WHERE hinmei.cd_hinmei = @cd_hinmei
        END
    END

    IF @@ERROR <> 0
    BEGIN
        SET @msg= 'error クエリ１'
    END

    /****************************************
    　調整予実トランの削除および更新
    ****************************************/
    --既存データより変更があれば
    -- 変動表の調整数は小数点以下2ケタの切り上げなので、DBと画面の値を合わせてから比較
    IF (SELECT tr.su_chosei
		FROM (
			SELECT CEILING(SUM(su_chosei) * 100) / 100 AS su_chosei
			FROM tr_chosei
	        WHERE cd_hinmei = @cd_hinmei
            AND dt_hizuke = @dt_hizuke
            GROUP BY cd_hinmei, dt_hizuke
        ) tr
        WHERE tr.su_chosei = @su_chosei) IS NULL
    BEGIN
        --削除処理
        IF @flg_delete_tr_chosei = 1
        BEGIN
            DELETE tr_chosei
            WHERE cd_hinmei = @cd_hinmei
                AND dt_hizuke = @dt_hizuke
        END
        IF @flg_update_tr_chosei = 1
        BEGIN
            --採番処理
            EXEC dbo.usp_cm_Saiban @kbn_saiban_chosei, @kbn_prefix_chosei, @no_saiban = @no_chosei_new output
            --新規登録処理
            INSERT INTO tr_chosei (
                no_seq,
                cd_hinmei,
                dt_hizuke,
                cd_riyu,
                su_chosei,
                biko,
                cd_seihin,
                dt_update, 
                cd_update,
                cd_genka_center,
                cd_soko
            )
            VALUES (
                @no_chosei_new,
                @cd_hinmei,
                @dt_hizuke,
                --(
                --    SELECT MIN(cd_riyu)
                --    FROM ma_riyu
                --    WHERE kbn_bunrui_riyu = @flg_chosei
                --),
                @cd_riyu,
                @su_chosei,
                null,
                null,
                @utc_sysdate,
                @cd_update,
                @cd_genka,
                @cd_soko
            )
        END
    END

    IF @@ERROR <> 0
    BEGIN
        SET @msg = 'error クエリ２'
    END

    /****************************************
    　計算在庫トランの削除および更新
    ****************************************/
    --既存データより変更があれば
    IF (SELECT su_zaiko FROM tr_zaiko_keisan
        WHERE cd_hinmei = @cd_hinmei
            AND dt_hizuke = @dt_hizuke
            AND su_zaiko = @su_keisanzaiko) IS NULL
    BEGIN
        IF @flg_delete_tr_zaiko_keisan = 1
        BEGIN
            --削除処理
            DELETE tr_zaiko_keisan
            WHERE cd_hinmei = @cd_hinmei
                AND dt_hizuke = @dt_hizuke
        END
        IF @flg_update_tr_zaiko_keisan = 1
        BEGIN
            --新規登録処理
            INSERT INTO tr_zaiko_keisan (
                cd_hinmei,
                dt_hizuke,
                su_zaiko,
                dt_update,
                cd_update
            )
            VALUES (
                @cd_hinmei,
                @dt_hizuke,
                @su_keisanzaiko,
                @utc_sysdate,
                @cd_update
            )
        END
        
        IF @@ERROR <> 0
        BEGIN
            SET @msg = 'error クエリ２'
        END
    END

    /****************************************
    　在庫トランの削除および更新
    ****************************************/
    --既存データより変更があれば
    --IF (SELECT su_zaiko FROM tr_zaiko
    --    WHERE cd_hinmei = @cd_hinmei
    --        AND dt_hizuke = @dt_hizuke
    --        AND su_zaiko = @su_jitsuzaiko
    --        AND kbn_zaiko = @kbn_ryohin) IS NULL
    IF (		
		SELECT tr.su_zaiko
		FROM (
			SELECT ROUND(SUM(su_zaiko),2,1) AS su_zaiko
			FROM tr_zaiko
	        WHERE cd_hinmei = @cd_hinmei
            AND dt_hizuke = @dt_hizuke
            AND kbn_zaiko = @kbn_ryohin
            GROUP BY cd_hinmei, dt_hizuke
        ) tr
        WHERE tr.su_zaiko = @su_jitsuzaiko) IS NULL 
    BEGIN
        --削除処理
        IF @flg_delete_tr_zaiko = 1
        BEGIN
            DELETE tr_zaiko
            WHERE cd_hinmei = @cd_hinmei
                AND dt_hizuke = @dt_hizuke
                AND kbn_zaiko = @kbn_ryohin
        END
        --新規登録処理
        IF @flg_update_tr_zaiko = 1
        BEGIN
			-- 個単価の取得
			SET @tan_ko = (SELECT COALESCE(tan_ko, 0) FROM ma_hinmei
							WHERE cd_hinmei = @cd_hinmei)
        
            INSERT INTO tr_zaiko (
                cd_hinmei,
                dt_hizuke,
                su_zaiko,
                dt_jisseki_zaiko,
                dt_update,
                cd_update,
                tan_tana,
                kbn_zaiko,
                cd_soko
            )
            VALUES (
                @cd_hinmei,
                @dt_hizuke,
                @su_jitsuzaiko,
                null,
                @utc_sysdate,
                @cd_update,
                @tan_ko,
                @kbn_ryohin,
                @cd_soko
            )
        END
    END
			
END
GO
