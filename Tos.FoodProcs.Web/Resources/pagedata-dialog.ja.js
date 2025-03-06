(function () {

    App.ui.pagedata.lang("ja", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        // ダイアログ名称
        torihikisakiDialog: { text: "取引先マスタ検索" },
        categoryDialog: { text: "分類コード検索" },
        haigoDialog: { text: "配合コード検索" },
        hinmeiDialog: { text: "品名マスタ検索" },
        finmeiDialog: { text: "_品名マスタ検索" },
        lineDialog: { text: "ラインマスタ検索" },
        seizoLineDialog: { text: "製造ラインマスタ検索" },
        kojoDialog: { text: "工場マスタ検索" },
        futaiDialog: { text: "風袋マスタ検索" },
        futaiKetteiDialog: { text: "風袋決定マスタ登録一覧検索" },
        niukebashoDialog: { text: "荷受場所マスタ一覧" },
        commentDialog: { text: "コメントマスタ一覧" },
        markDialog: { text: "マークマスタ一覧" },
        gokeiHyojiDialog: { text: "製品別合計表示" },
        yasumiItiranDialog: { text: "休み一覧" },
        labelinsatsuDialog: { text: "ラベル印刷" },
        gramTaniDialog: { text: "グラム単位入力" },
        insatsuSentakuDialog: { text: "印刷選択" },
        shiyoIchiranDialog: { text: "原資材使用一覧" },
        genshizaiLotDialog: { text: "原資材ロット入力" },
        ShikakariZanIchiranDialog: { text: "仕掛残選択" },
        genryoLotSentakuDialog: { text: "原料ロット選択" },
        genryoLotTorikeshiDialog: { text: "原料ロット取消" },
        JikaGenryoLotSentakuDialog: { text: "自家原料ロット選択" },
        jikaGenryoLotTorikeshiDialog: { text: "自家原料ロット取消" },
        shokubaSentakuDialog: { text: "職場選択" },
        excelikatsuDialog: { text: "EXCEL(期間選択)" },
        between: { text: "　～　" },

        // 各ダイアログ内項目
        csvTitle: { text: "CSVアップロード" },
        file1: { text: "ファイル1" },
        file2: { text: "ファイル2" },
        categoryCode: { text: "分類コード" },    
        categoryName: { text: "分類名" },
        torihikisakiCode: { text: "取引先コード" },
        torihikisakiName: { text: "取引先名" },
        haigoCode: { text: "配合コード" },
        haigoName: { text: "配合名" },
        cd_hinmei_dlg: { text: "コード" },
        kbn_hin_dlg: { text: "品区分" },
        nm_hinmei_dlg: { text: "名称" },
        nm_naiyo_dlg: { text: "内容" },
        nm_haigo: { text: "配合名" },
        cd_line_dlg: { text: "コード" },
        nm_line_dlg: { text: "名称" },
        cd_seihin_dlg: { text: "コード" },
        nm_seihin_dlg: { text: "製品名" },
        nm_gokei_dlg: { text: "合計量(C/S)" },
        cd_setsubi: { text: "コード" },
        nm_setsubi: { text: "名称" },
        cd_kojo: { text: "コード" },
        nm_kojo: { text: "名称" },
        cd_futai_dlg: { text: "コード" },
        nm_futai_dlg: { text: "名称" },
        cd_mark_dlg: { text: "コード" },
        nm_mark_dlg: { text: "名称" },
        cd_riyu_dlg: { text: "理由コード" },
        nm_riyu_dlg: { text: "理由" },
        mark_dlg: { text: "マーク" },
        startDate: { text: "開始日" },
        endDate: { text: "終了日" },
        cd_niukebasho_dlg: { text: "コード" },
        nm_niukebasho_dlg: { text: "荷受場所名" },
        cd_comment: { text: "コード" },
        comment: { text: "コメント" },
        seq_comment_dlg: { text: "シーケンス番号" },
        genshizaikonyuDialog: { text: "原資材購入先マスタ検索" },
        con_cd_hinmei: { text: "品名コード" },
        juni_yusen: { text: "優先順位" },
        cd_torihiki_butsu: { text: "コード(物流)" },
        nm_torihiki_butsu: { text: "取引先名(物流)" },
        cd_torihiki_sho: { text: "コード(商流)" },
        nm_torihiki_sho: { text: "取引先名(商流)" },
        masterKubun: { text: "マスタ区分" },
        ts: { text: "タイムスタンプ" },
        seizoLineCode: { text: "ラインコード*" },
        seizoLineName: { text: "ライン名" },
        yusenNumber: { text: "順位*" },
        gramWtNonyu: { text: "一個の量" },
        gramMsg: { text: "入力された値はKgに換算されます" },
        mishiyoFlag: { text: "未使用" },
        mishiyoFukumuFlag: { text: "未使用含" },
        torokuCode: { text: "登録者" },
        torokuDate: { text: "登録日時" },
        cd_shikakari_hin_dlg: { text: "仕掛品コード" },
        nm_shikakari_hin_dlg: { text: "仕掛品名" },
        wt_hitsuyo_dlg: { text: "必要量" },
        cd_seihin_shiyodlg: { text: "製品コード" },
        dt_seizo_dlg: { text: "製造日" },
        cd_genshizai_dlg: { text: "原資材コード" },
        nm_genshizai_dlg: { text: "原資材名" },
        no_lot_dlg: { text: "原資材ロットNo" },
        dt_niuke_dlg: { text: "荷受日" },
        tm_niuke_dlg: { text: "時刻" },
        dt_kigen_dlg: { text: "賞味期限" },
        biko_dlg: { text: "備考" },
        maxPeriod: { text: "62" },
        // 個別ラベル画面
        jyuryoSoShikomi: { text: "総仕込重量" },
        ritsuBai: { text: "倍率" },
        ritsuBaiShort: { text: "倍" },
        suBatch: { text: "バッチ数" },
        suSeiki: { text: "正規" },
        suHasu: { text: "端数" },
        suSeikiKakko: { text: "正規）" },
        suHasuKakko: { text: "端数）" },
        allView: { text: "全て" },
        seikiView: { text: "正規" },
        hasuView: { text: "端数" },
        labelInsatsuZen: { text: "全ラベル印刷" },
        labelInsatsuKo: { text: "個別ラベル印刷" },
        suKaishiBatch: { text: "開始バッチ数" },
        suShuryoBatch: { text: "終了バッチ数" },
        no_kotei_dlg: { text: "工程" },
        nm_mark_label_dlg: { text: "マーク" },
        nm_genryo_dlg: { text: "原料" },
        wt_kihon_dlg: { text: "基本重量" },
        wt_haigo_dlg: { text: "配合重量" },
        nm_tani_shiyo_dlg: { text: "使用単位" },
        wt_nisugata_dlg: { text: "荷姿重量" },
        nm_nisugata_dlg: { text: "荷姿" },
        su_nisugata_kowake_dlg: { text: "数" },
        wt_kowake1_dlg: { text: "小分重量１" },
        su_kowake1_kowake_dlg: { text: "小分個数１" },
        nm_futai1_dlg: { text: "風袋１" },
        wt_kowake2_dlg: { text: "小分重量２" },
        su_kowake2_kowake_dlg: { text: "小分個数２" },
        nm_futai2_dlg: { text: "風袋２" },
        shokuba_dlg: { text: "職場" },

        // 印刷選択画面
        insatsuButton: { text: "印刷" },
        shikomiKeikauHyo: { text: "仕込計画表" },
        lotKirokuHyo: { text: "秤量記録表" },
        checkHyo: { text: "配合チェック表" },
        // ラベルに印字する文字
        txt_kotei_label: { text: "工程" },
        txt_kotei_sagyojyun_label: { text: "作業順" },
        txt_genryo_label: { text: "原料名" },
        txt_juryo_label: { text: "重量" },
        txt_kaisu_label: { text: "回数" },
        txt_kosu_label: { text: "個数" },
        txt_shikomi_label: { text: "仕込日" },
        txt_kai_label: { text: "回" },
        txt_ko_label: { text: "個" },
        //txt_kigen_label: { text: "使用期限" },
        //txt_kigen_label: { text: "開封後期限" },
        txt_kigen_label: { text: "賞味期限" },
        txt_haigo_label: { text: "配合名" },
        txt_futai_label: { text: "風袋名" },
        txt_code_label: { text: "原料コード" },
        // ラベルに印字する文字(ver2用)
        txt_titleKowake_label: { text: "小分ラベル" },
        txt_titleKasane_label: { text: "重ねラベル" },
        txt_titleChomi_label: { text: "調味液ラベル" },
        txt_codeHaigo_label2: { text: "配合コード" },
        txt_code_label2: { text: "原料コード" },
        txt_genryo_label2: { text: "原料名" },
        txt_juryo_label2: { text: "重量" },
        txt_haigo_label2: { text: "配合名" },
        txt_shikomi_label2: { text: "仕込日" },
        txt_seizo_label2: { text: "製造日" },
        txt_kotei_label2: { text: "工程" },
        txt_kotei_sagyojyun_label2: { text: "作業順" },
        txt_kaisu_label2: { text: "回数" },
        txt_kosu_label2: { text: "個数" },
        txt_maisu_label2: { text: "枚数" },
        txt_ritsuBai_label2: { text: "倍率" },

        kbn_tani_LB_GAL: { text: "1" },
        kbn_tani_Kg_L: { text: "0" },
        lbl_mark_g: { text: "g" },
        lbl_mark_LB: { text: "LB" },
        lbl_mark_Kg: { text: "Kg" },
        cd_mark: { text: "10" },
        
        // 品名DLG、取引先DLGの複数選択上限数
        limitMultiSelect: { text: "50" },
        // 実績データ確認ダイアログで使用
        txt_dlg_title: { text: "変更された製品" },
        txt_radio_case: { text: "Ｃ/Ｓ数のみ反映" },
        txt_radio_all: { text: "全ての計画に反映" },
        // 休日ダイアログ
        txt_kyujitsu_kaijyo: { text: "休日解除" },

        // トレース画面.品名マスタ検索ダイアログ
        nm_content_dlg: { text: "内容" },
        // 注意喚起ダイアログ
        chuiKankiDialog: { text: "注意喚起一覧" },
        txt_kbn_chui_dlg: { text: "注意喚起区分" },
        txt_nm_chui_dlg: { text: "注意喚起名" },
        cd_chui_dlg: { text: "コード" },
        nm_chui_dlg: { text: "名称" },

        // 製造実績選択ダイアログ
        seizoJissekiDialog: { text: "製造実績選択" },
        date_between: { text: "　～　" },
        seizoJissekiDlg_date: { text: "日付" },
        seizoJissekiDlg_shikakari: { text: "仕掛品" },
        seizoJissekiDlg_code: { text: "コード" },
        seizoJissekiDlg_hinmei: { text: "品名" },
        seizoJissekiDlg_seizoSu: { text: "製造数" },
        seizoJissekiDlg_lotNo: { text: "製品ロット番号" },
        seizoJissekiDlgn_itemLabel_width: { number: 80 },

        // 仕掛残選択セレクタ
        shikakariZanDlg_date: { text: "日付" },
        shikakariZanDlg_nm_shikakari: { text: "仕掛残" },
        seizoJissekiDlg_seizoSu: { text: "製造数" },
        seizoJissekiDlg_lotNo: { text: "製品ロット番号" },

        // 原料ロット選択ダイアログ
        genryo_sentaku_item_nm_code: { text: "原資材コード" },
        genryo_sentaku_checkbox_dlg: { text: "確定", number: 55 },
        genryo_sentaku_datedelivery_dlg: { text: "荷受実績日", number: 120 },
        genryo_sentaku_datereceive_dlg: { text: "荷受予定日", number: 120 },
        genryo_sentaku_datedeadline_dlg: { text: "賞味期限", number: 120 },
        genryo_sentaku_lotNo_dlg: { text: "ロット番号" },
        genryo_sentaku_lotNo: { text: "原資材ロット番号", number: 120 },
        genryo_sentaku_height_table: { number: 190 },

        // 原料ロット取消ダイアログ        
        genryo_item_nm_code: { text: "原資材コード" },
        genryo_dlg_delete: { text: "取消", number: 45 },
        genryo_dlg_recei_date: { text: "荷受予定日", number: 120 },
        genryo_dlg_time: { text: "荷受実績日", number: 100 },
        genryo_dlg_expiry_date: { text: "賞味期限", number: 100 },
        genryo_dlg_lot_no: { text: "ロット番号", number: 110 },
        genryo_dlg_height_table: { number: 185 },

        // 原料ロット選択ダイアログ        
        jika_genryo_sentaku_item_name_code: { text: "自家原料コード" },
        jika_genryo_sentaku_date: { text: "製造日", number: 135 },
        jika_genryo_sentaku_delete: { text: "確定", number: 52 },
        jika_genryo_sentaku_nofpro: { text: "製造数", number: 135 },
        jika_genryo_sentaku_lotno: { text: "ロット番号", number: 118 },
        jika_genryo_sentaku_exdate: { text: "賞味期限", number: 100 },

        // 自家原料ロット取消ダイアログ        
        jika_genryo_item_nm_code: { text: "自家原料コード" },
        jika_genryo_dlg_delete: { text: "取消", number: 45 },
        jika_genryo_dlg_manufature_date: { text: "製造日", number: 130 },
        jika_genryo_dlg_no_of_product: { text: "製造数", number: 135 },
        jika_genryo_dlg_lot_no: { text: "ロット番号", number: 110 },
        jika_genryo_dlg_expiry_date: { text: "賞味期限", number: 100 },

        // 職場選択ダイアログ
        excel:{text: "EXCEL"},
        nm_shokuba_dlg: { text: "職場" },
        cd_shokuba_dlg: { text: "職場コード" },
        nm_shokubamei_dlg: { text: "職場名" },

        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        noChange: { text: MS0444 },
        notFound: { text: MS0037 },
        changedNotDo: { text: MS0048 },
        flgMishiyo: { text: MS0050 },
        noSelect: { text: MS0443 },
        saveConfirm: { text: MS0064 },
        closeConfirm: { text: MS0066 },
        maxLength: { text: MS0440 },
        noPrintSelect: { text: MS0117 },
        chomiekiLabelPrintConfirm: { text: MS0381 },
        multiSelect: { text: MS0699 },
        noRowSelect: { text: MS0056 },
        noKowakeLabel: { text: MS0706 },
        uploading: { text: "アップロード中・・・" },
        unMatchKasane: { text: MS0717 },
        startDateOverEndDate: { text: MS0019 },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の列幅を変更してください。
        wt_kihon_width: { number: 100 },
        no_kotei_width: { number: 30 },
        wt_nisugata_width: { number: 100 },
        wt_haigo_width: { number: 100 },
        su_nisugata_kowake_seiki_width: { number: 30 },
        su_nisugata_kowake_hasu_width: { number: 30 },
        wt_kowake1_width: { number: 100 },
        su_kowake1_kowake_width: { number: 30 },
        wt_kowake2_width: { number: 100 },
        su_kowake2_kowake_width: { number: 70 },
        // TODO: ここまで
    });

    App.ui.pagedata.validation("ja", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        masterKubun: {
            rules: {
                required: "マスタ区分"
            },
            messages: {
                required: MS0004
            }
        },
        haigoCode: {
            rules: {
                required: "配合コード",
                alphanum: true,
                maxbytelength: 14
            },
            messages: {
                required: MS0004,
                alphanum: MS0439,
                maxbytelength: MS0012
            }
        },
        cd_line_dlg: {
            rules: {
                required: "ラインコード",
                alphanum: true,
                maxbytelength: 10
            },
            messages: {
                required: MS0042,
                alphanum: MS0439,
                maxbytelength: MS0012,
                custom: MS0058
            }
        },
        no_juni_yusen: {
            rules: {
                required: "順位",
                digits: true,
                range: [1, 99],
                maxbytelength: 2
            },
            messages: {
                required: MS0042,
                digits: MS0005,
                range: MS0009,
                maxbytelength: MS0012
            }
        },
        cd_comment: {
            rules: {
                required: "コード",
                maxbytelength: 2
            },
            messages: {
                required: MS0042,
                maxbytelength: MS0012
            }
        },
        comment: {
            rules: {
                required: "コメント",
                maxbytelength: 100
            },
            messages: {
                required: MS0042,
                maxbytelength: MS0012
            }
        },
        gramWtNonyu: {
            rules: {
                number: true,
                range: [0, 999999999.999],
                pointlength: [9, 3, false]
            },
            messages: {
                number: MS0441,
                range: MS0450,
                pointlength: MS0440
            }
        },
        suKaishiBatch: {
            rules: {
                required: "開始バッチ数",
                number: true,
                range: [1, 99]
            },
            messages: {
                required: MS0042,
                number: MS0441,
                range: MS0450
            }
        },
        suShuryoBatch: {
            rules: {
                required: "終了バッチ数",
                number: true,
                range: [1, 99]
            },
            messages: {
                required: MS0042,
                number: MS0441,
                range: MS0450,
                custom: MS0553
            }
        },
        hizuke_from: {
            rules: {
                required: "開始日",
                datestring: true,
                lessdate: new Date(1975, 1 - 1, 1 - 1)
            },
            messages: {
                required: MS0042,
                datestring: MS0247,
                lessdate: MS0247
            }
        },
        hizuke_to: {
            rules: {
                required: "終了日",
                datestring: true,
                lessdate: new Date(1975, 1 - 1, 1 - 1)
            },
            messages: {
                required: MS0042,
                datestring: MS0247,
                lessdate: MS0247
            }
        },
        hizuke: {
            rules: {
                required: "開始日",
                datestring: true,
                lessdate: new Date(1975, 1 - 1, 1 - 1),
                //greaterdate: new Date(new Date().getFullYear() + 10, new Date().getMonth(), new Date().getDate() + 1)
            },
            messages: {
                required: MS0042,
                datestring: MS0247,
                lessdate: MS0247,
                //greaterdate: MS0247
            }
        },
        ///begin genryo lot sentaku dialog
        dt_niuke_start: {
            rules:{
                datestring: true,
                greaterdate: new Date("3001/01/01"),
                lessdate: new Date("1969/12/31"),
                greaterdate_niuke_from: ["荷受予定日（開始）", "荷受予定日（終了）"]
            },
            messages:{
                datestring: MS0247,
                greaterdate: MS0247,
                lessdate: MS0247,
                greaterdate_niuke_from: MS0019
            }
        },
        dt_niuke_end: {
            rules:{
                datestring: true,
                greaterdate: new Date("3001/01/01"),
                lessdate: new Date("1969/12/31")
            },
            messages:{
                datestring: MS0247,
                greaterdate: MS0247,
                lessdate: MS0247
            }
        },
        dt_yotei_niuke_start: {
            rules:{
                datestring: true,
                greaterdate: new Date("3001/01/01"),
                lessdate: new Date("1969/12/31"),
                greaterdate_yoteiniuke_from: ["荷受実績日（開始）", "荷受実績日（終了）"]
            },
            messages:{
                datestring: MS0247,
                greaterdate: MS0247,
                lessdate: MS0247,
                greaterdate_yoteiniuke_from: MS0019
            }
        },
        dt_yotei_niuke_end: {
            rules:{
                datestring: true,
                greaterdate: new Date("3001/01/01"),
                lessdate: new Date("1969/12/31")
            },
            messages:{
                datestring: MS0247,
                greaterdate: MS0247,
                lessdate: MS0247
            }
        },
        ///end genryo lot sentaku dialog
        ///begin jika genryo lot sentaku dialog
        dt_seizo_start: {
            rules:{
                datestring: true,
                greaterdate: new Date("3001/01/01"),
                lessdate: new Date("1969/12/31"),
                greaterdate_from: ["製造日（開始）", "製造日（終了）"]
            },
            messages:{
                datestring: MS0247,
                greaterdate: MS0247,
                lessdate: MS0247,
                greaterdate_from: MS0019
            }
        },
        dt_seizo_end: {
            rules:{
                datestring: true,
                greaterdate: new Date("3001/01/01"),
                lessdate: new Date("1969/12/31")
            },
            messages:{
                datestring: MS0247,
                greaterdate: MS0247,
                lessdate: MS0247
            }
        },
        ///end jika genryo lot sentaku dialog
        no_lot_search:{
            rules: {
                maxbytelength: 14
            },
            messages: {
                maxbytelength: MS0012
            }
        }
        // TODO: ここまで
    });

})();