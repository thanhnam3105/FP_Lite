(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("ja", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "仕掛品仕込計画" },
        // 明細
        flg_print: { text: "印刷" },
        flg_kakutei: { text: "確定" },
        nm_line: { text: "ライン" },
        cd_hinmei: { text: "仕掛品<br>コード" },
        nm_hinmei: { text: "仕掛品名" },
        nm_uchiwake: { text: "内訳" },
        nm_tani: { text: "使用<br>単位" },
        wt_hitsuyo: { text: "必要量" },
        wt_shikomi: { text: "仕込量" },
        nm_ritsu_bai: { text: "倍率" },
        nm_su_batch: { text: "バッチ数" },
        nm_seiki: { text: "正規" },
        nm_hasu: { text: "端数" },
        nm_zan_shikakari: { text: "当仕掛残" },
        nm_gokei_label: { text: "ラベル合計" },
        nm_label: { text: "ラベル" },
        no_lot_shikakarihin: { text: "仕掛品<br>ロット番号" },
        nm_haigo: { text: "配合名" },
        blank: { text: "" },
        nm_shikakari_oya_sub: { text: "親仕掛品ロット番号" },
        nm_seihin_sub: { text: "製品ロット番号" },

        // 検索条件
        dt_hiduke_search: { text: "日付" },
        nm_shokuba_search: { text: "職場" },
        nm_line_search: { text: "ライン" },
        flg_kakutei_search: { text: "確定" },
        flg_mikakutei_search: { text: "未確定" },
        rd_shikomi_search: { text: "仕込職場" },
        rd_shiyo_search: { text: "使用職場" },

        // ボタン
        btn_print_select: { text: "印刷選択" },
        btn_label_kobetsu: { text: "ラベル印刷" },
        btn_label_chomieki: { text: "調味液ラベル印刷" },
        btn_itiran_line: { text: "ライン一覧" },
        btn_insatsu_sentaku: { text: "印刷選択" },
        // その他
        btn_label_message: { text: "ラベル印刷画面" },

        searchConfirm: { text: MS0065 },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        saveConfirm: { text: MS0064 },
        clearConfirm: { text: MS0070 },
        noRecords: { text: MS0442 },
        notFound: { text: MS0037 },
        noSelect: { text: MS0443 },
        noChange: { text: MS0038 },
        noRowChecked: { text: MS0056 },
        someRowChecked: { text: MS0059 },
        criteriaChange: { text: MS0048 },
        unloadWithoutSave: { text: MS0066 },
        unprintableCheck: { text: MS0560 },
        labelprintCheck: { text: MS0048 },
        noChomiData: { text: MS0122 },
        checkShikomi: { text: MS0150 },
        zeroShikomi: { text: MS0124 },
        zeroHaigo: { text: MS0704 },
        shikomiUpdateCheck: { text: MS0799 },
        jissekiCheck: { text: MS0801 },
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        // TODO: 画面の仕様に応じて以下の列幅を変更してください。
        flg_shikomi_width: { number: 40 },
        uchiwake_width: { number: 35 },
        wt_zan_shikakari_width: { number: 100 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("ja", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        wt_shikomi_keikaku: {
            rules: {
                required: "計画仕込量",
                number: true,
                //range: [0, 999999.999999]
                range: [0, 999999.999]
            },
            messages: {
                required: MS0042,
                number: MS0441,
                range: MS0450
            }
        },
        ritsu_keikaku: {
            rules: {
                required: "計画倍率",
                number: true,
                range: [0, 99.99]
            },
            messages: {
                required: MS0042,
                number: MS0441,
                range: MS0450
            }
        },
        ritsu_keikaku_hasu: {
            rules: {
                required: "計画倍率端数",
                number: true,
                range: [0, 99.99]
            },
            messages: {
                required: MS0042,
                number: MS0441,
                range: MS0450
            }
        },
        su_batch_keikaku: {
            rules: {
                required: "計画バッチ数",
                number: true,
                range: [0, 9999]
            },
            messages: {
                required: MS0042,
                number: MS0441,
                range: MS0450
            }
        },
        su_batch_keikaku_hasu: {
            rules: {
                required: "計画バッチ数端数",
                number: true,
                range: [0, 1]
            },
            messages: {
                required: MS0042,
                number: MS0441,
                range: MS0450
            }
        },

        // 検索条件
        dt_hiduke_search: {
            rules: {
                required: "日付",
                datestring: true
            },
            messages: {
                required: MS0042,
                datestring: MS0247
            }
        },
        //lineCode: {
        //    rules: {
        //        required: true
        //    },
        //    messages: {
        //        required: MS0004
        //    }
        //}
        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("ja", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
        search: {
            Warehouse: { visible: false }
        },
        colchange: {
            Warehouse: { visible: false }
        },
        check: {
            Warehouse: { visible: false }
        },
        save: {
            Quality: { visible: false },
            Purchase: { visible: false },
            Warehouse: { visible: false }
        },
        //---------------------------------------------------------
        //2019/07/24 trinh.bd Task #14029
        //------------------------START----------------------------
        //insatsu_sentaku: {
        //    Warehouse: { visible: false }
        //},
        //label_kobetsu: {
        //    Warehouse: { visible: false }
        //},
        //------------------------END------------------------------
        label_chomieki: {
            Quality: { visible: false },
            Purchase: { visible: false },
            Warehouse: { visible: false }
        },
        zenlabel: {
            Quality: { visible: false },
            Purchase: { visible: false },
            Warehouse: { visible: false }
        },
        kobetsulabel: {
            Quality: { visible: false },
            Purchase: { visible: false },
            Warehouse: { visible: false }
        }
        // TODO: ここまで
    });

    //// ページデータ -- End
})();
