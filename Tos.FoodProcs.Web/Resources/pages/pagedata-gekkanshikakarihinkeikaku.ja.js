(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("ja", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "月間仕掛品計画" },
        // 明細
        dt_hitsuyo: { text: "必要日" },
        dt_hitusyo_yobi: { text: "曜" },
        dt_shikomi: { text: "仕込日" },
        nm_hinmei: { text: "親仕掛品名" },
        cd_shikakari: { text: "仕掛品コード" },
        nm_shikakarihin: { text: "仕掛品名" },
        kbn_gassan: { text: "合算<br>区分" },
        tan_shiyo: { text: "使用<br>単位" },
        wt_hituyo: { text: "必要量" },
        wt_shikomi: { text: "仕込量" },
        cd_line: { text: "ラインコード" },
        nm_line: { text: "ライン名" },
        no_lot_seihin: { text: "製品ロット" },
        no_lot_oya: { text: "親仕掛品ロット" },
        no_lot_shikakari: { text: "仕掛品ロット" },
        // 検索条件
        dt_hiduke_search: { text: "日付" },
        dt_hiduke_start: { text: "日付（開始）" },
        dt_hiduke_end: { text: "日付（終了）" },
        nm_shokuba_search: { text: "職場" },
        cd_hinmei_search: { text: "仕掛品コード" },
        nm_hinmei_search: { text: "仕掛品名" },
        rd_lotNashi: { text: "なし" },
        rd_lotSeihin: { text: "製品" },
        rd_lotOya: { text: "親仕掛品" },
        rd_lotShikakari: { text: "仕掛品" },
        no_lot_search: { text: "ロット" },
        // 画面で利用するテキスト
        seihinIchiran: { text: "仕掛品一覧" },
        lineIchiran: { text: "ライン一覧" },
        namisen: { text: "～" },
        blank: { text: "" },
        searchConfirm: { text: MS0065 },
        // TODO: ここまで

        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        saveConfirm: { text: MS0064 },
        clearConfirm: { text: MS0070 },
        dateInputConfirm: { text: MS0151 },
        lotDeleteConfirm: { text: MS0565 },
        noRecords: { text: MS0442 },
        notFound: { text: MS0037 },
        noSelect: { text: MS0443 },
        noChange: { text: MS0038 },
        criteriaChange: { text: MS0048 },
        unloadWithoutSave: { text: MS0066 },
        unprintableCheck: { text: MS0560 },
        notSeihinLotDelCheck: { text: MS0569 },
        inputDateError: { text: MS0019 },
        shikomiUpdateCheck: { text: MS0799 },
        shikomiDeleteCheck: { text: MS0800 },
        jissekiCheck: { text: MS0801 },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の列幅を変更してください。
        dt_hitsuyo_tukihi_width: { number: 50 },
        dt_hitsuyo_yobi_width: { number: 30 },
        dt_seizo_width: { number: 100 },
        nm_haigo_width: { number: 120 },
        cd_hinmei_width: { number: 110 },
        nm_shikakari_width: { number: 120 },
        nm_gassan_kbn_width: { number: 50 },
        nm_tani_width: { number: 50 },
        wt_hitsuyo_width: { number: 90 },
        wt_shikomi_keikaku_width: { number: 110 },
        cd_line_width: { number: 100 },
        nm_line_width: { number: 120 },
        no_lot_shikakari_width: { number: 120 },
        no_lot_shikakari_oya_width: { number: 120 },
        no_lot_seihin_width: { number: 120 },
        each_lang_width: { number: 100 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("ja", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        // 明細/コード
        dt_seizo: {
            rules: {
                required: "仕込日",
                datestring: true,
                lessdate: new Date(1975, 1 - 1, 1 - 1),
                greaterdate: new Date(new Date().getFullYear() + 1, new Date().getMonth(), new Date().getDate() + 1)
            },
            messages: {
                required: MS0042,
                datestring: MS0247,
                lessdate: MS0247,
                greaterdate: MS0247
            }
        },
        cd_hinmei: {
            rules: {
                required: "仕掛品コード",
                maxbytelength: 14,
                alphanum: true
            },
            //params: {
            //    custom: "仕掛品コード"
            //},
            messages: {
                required: MS0042,
                maxbytelength: MS0012,
                alphanum: MS0439
            //    custom: MS0049,
            //    custom_no_entry: "マスタに不備があります"
            }
        },
        wt_shikomi_keikaku: {
            rules: {
                required: "仕込量",
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
        cd_line: {
            rules: {
                required: "ラインコード",
                alphanum: true,
                maxbytelength: 14
            },
            params: {
                custom: "ラインコード"
            },
            messages: {
                required: MS0042,
                alphanum: MS0439,
                maxbytelength: MS0012,
                custom: MS0042
            }
        },
        isYukoHaigoCode: {
            rules: {
            },
            params: {
                custom: "有効な配合コード"
            },
            messages: {
                custom: MS0049
            }
        },
        // 検索条件
        dt_hiduke_search_from: {
            rules: {
                required: "開始日付",
                datestring: true,
                lessdate: new Date(1975, 1 - 1, 1 - 1),
                greaterdate: new Date(new Date().getFullYear() + 1, new Date().getMonth(), new Date().getDate() + 1)
            },
            messages: {
                required: MS0004,
                datestring: MS0247,
                lessdate: MS0247,
                greaterdate: MS0247
            }
        },
        dt_hiduke_search_to: {
            rules: {
                required: "終了日付",
                datestring: true,
                lessdate: new Date(1975, 1 - 1, 1 - 1),
                greaterdate: new Date(new Date().getFullYear() + 1, new Date().getMonth(), new Date().getDate() + 1)
            },
            messages: {
                required: MS0004,
                datestring: MS0247,
                lessdate: MS0247,
                greaterdate: MS0247
            }
        },
        no_lot_search: {
            rules: {
                maxbytelength: 14,
                alphanum: true
            },
            messages: {
                maxbytelength: MS0012,
                alphanum: MS0439
            }
        },
        cd_hinmei_search: {
            rules: {
                maxbytelength: 14,
                alphanum: true,
                custom: false
            },
            params: {
                custom: "仕掛品コード"
            },
            messages: {
                maxbytelength: MS0012,
                alphanum: MS0439,
                custom: MS0049
            }
        }
        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("ja", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
        search: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Warehouse: { visible: false }
        },
        excel: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Warehouse: { visible: false }
        },
        colchange: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Warehouse: { visible: false }
        },
        save: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Purchase: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        addButton: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Purchase: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        deleteButton: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Purchase: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }

        },
        seihinIchiran: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Purchase: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        lineIchiran: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Purchase: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        "grid:itemGrid.cd_hinmei": {
            Editor: { enable: false },
            Viewer: { enable: false },
            Purchase: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        "grid:itemGrid.cd_line": {
            Editor: { enable: false },
            Viewer: { enable: false },
            Purchase: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        "grid:itemGrid.dt_seizo": {
            Editor: { enable: false },
            Viewer: { enable: false },
            Quality: { visible: false },
            Purchase: { visible: false },
            Warehouse: { visible: false }
        }
        // TODO: ここまで
    });

    //// ページデータ -- End
})();
