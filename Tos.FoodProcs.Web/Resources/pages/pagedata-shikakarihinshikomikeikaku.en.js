(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("en", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Mixer Plan" },
        // 明細
        flg_print: { text: "Print" },
        flg_kakutei: { text: "Confirm" },
        nm_line: { text: "Line" },
        cd_hinmei: { text: "WIP code" },
        nm_hinmei: { text: "WIP name" },
        nm_uchiwake: { text: "Items" },
        nm_tani: { text: "Usage<br>unit" },
        wt_hitsuyo: { text: "Required<br>quantity" },
        wt_shikomi: { text: "Produce<br>quantity" },
        nm_ritsu_bai: { text: "Magnification" },
        nm_su_batch: { text: "Quantity of<br>batches" },
        nm_seiki: { text: "R" },
        nm_hasu: { text: "F" },
        nm_zan_shikakari: { text: "Today's inventory" },
        nm_gokei_label: { text: "Total of<br>label" },
        nm_label: { text: "Label" },
        no_lot_shikakarihin: { text: "Semi-finished product<br>lot No." },
        nm_haigo: { text: "Formula name" },
        blank: { text: "" },
        nm_shikakari_oya_sub: { text: "Parents semi-finished product lot No." },
        nm_seihin_sub: { text: "Product lot No." },

        // 検索条件
        dt_hiduke_search: { text: "Date" },
        nm_shokuba_search: { text: "Workplace" },
        nm_line_search: { text: "Line" },
        flg_kakutei_search: { text: "Confirm" },
        flg_mikakutei_search: { text: "Unconfirm" },
        rd_shikomi_search: { text: "Produce location" },
        rd_shiyo_search: { text: "Usage location" },

        // ボタン
        btn_print_select: { text: "Select print" },
        btn_label_kobetsu: { text: "Label print" },
        btn_label_chomieki: { text: "Print liquid seasoning label" },
        btn_itiran_line: { text: "Line catalogue" },
        btn_insatsu_sentaku: { text: "Select print" },
        // その他
        btn_label_message: { text: "Label print screen" },

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
        flg_shikomi_width: { number: 120 },
        uchiwake_width: { number: 70 },
        wt_zan_shikakari_width: { number: 130 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("en", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        wt_shikomi_keikaku: {
            rules: {
                required: "produce amount plan",
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
                required: "Plan of magnification",
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
                required: "Partial of magnification plan",
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
                required: "Number of batches plan",
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
                required: "Partial of batches plan",
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
                required: "Date",
                datestring: true
            },
            messages: {
                required: MS0004,
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
    App.ui.pagedata.operation("en", {
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
