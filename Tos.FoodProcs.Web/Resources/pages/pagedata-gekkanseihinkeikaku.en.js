(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("en", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Production Plan" },
        // 明細
        dt_seizo: { text: "Day" },
        dt_seizo_yobi: { text: "Day of<br>the week" },
        cd_riyu: { text: "Code" },
        nm_riyu: { text: "Reason of holiday" },
        cd_hinmei: { text: "Code" },
        nm_hinmei: { text: "Product name" },
        nm_nisugata: { text: "Packing style" },
        su_seizo_yotei: { text: "Planned quantities" },
        su_seizo_jisseki: { text: "Actual quantities" },
        no_lot_seihin: { text: "Product lot No." },
        batch: { text: "Quantity of<br>batches" },
        bairitsu: { text: "Magnification" },
        check_reflect: { text: "Reflect<br>target" },
        // 検索条件
        dt_hiduke_search: { text: "Date" },
        nm_shokuba_search: { text: "Workplace" },
        nm_line_search: { text: "Line" },
        // 画面で利用するテキスト
        zenLine: { text: "Check all lines" },
        gokei: { text: "Display total" },
        //seihinIchiran: { text: "Product list" },
        yasumiIchiran: { text: "Holiday list" },
        csReflect: { text: "C/S Reflect" },
        blank: { text: "" },
        msg_param: { text: "production number of" },
        searchConfirm: { text: MS0065 },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        saveConfirm: { text: MS0064 },
        clearConfirm: { text: MS0070 },
        oldDateInputConfirm: { text: MS0151 },
        jissekiDataConfirm: { text: MS0682 },
        noRecords: { text: MS0442 },
        notFound: { text: MS0037 },
        noSelect: { text: MS0443 },
        noChange: { text: MS0038 },
        criteriaChange: { text: MS0048 },
        unloadWithoutSave: { text: MS0066 },
        unprintableCheck: { text: MS0560 },
        shikomiDeleteCheck: { text: MS0800 },
        jissekiCheck: { text: MS0801 },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の列幅を変更してください。
        nm_riyu_width: { number: 120 },
        dt_seizo_width: { number: 50 },
        dt_seizo_yobi_width: { number: 80 },
        cd_hinmei_width: { number: 100 },
        nm_hinmei_width: { number: 180 },
        nm_nisugata_hyoji_width: { number: 120 },
        su_seizo_yotei_width: { number: 140 },
        su_seizo_jisseki_width: { number: 120 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("en", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        su_seizo_yotei: {
            rules: {
                required: "Planned quantities", //"Number of productions",
                number: true
            },
            params: {
                custom: ["Planned quantities", 1, 9999999999]
            },
            messages: {
                required: MS0042,
                number: MS0441,
                custom: MS0666
            }
        },
        cd_hinmei: {
            rules: {
                required: "Code"
            },
            messages: {
                required: MS0042
            }
        },
        //nm_hinmei_en: { //製品名en版用
        //    rules: {
        //        required: "Product name"
        //    },
        //    messages: {
        //        required: MS0122
        //    }
        //},
        wt_ko: { // マスタ整合性チェック用
            rules: {
                required: "Unit quantity"
            },
            messages: {
                required: MS0122
            }
        },
        su_batch_keikaku: {
            rules: {
                number: true,
                range: [0, 9999]
            },
            messages: {
                number: MS0441,
                range: MS0450
            }
        },
        // 検索条件
        dt_hiduke_search: {
            rules: {
                required: "Date",
                monthstring: true,
                lessmonth: new Date(1974, 12 - 1),
                greatermonth: new Date(new Date().getFullYear() + 3, new Date().getMonth() + 1)
            },
            messages: {
                required: MS0004,
                monthstring: MS0247,
                lessmonth: MS0247,
                greatermonth: MS0247
            }
        },
        lineCode: {
            rules: {
                required: "Line name"
            },
            messages: {
                required: MS0004
            }
        }
        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("en", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
        save: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Quality: { visible: false },
            Purchase: { visible: false },
            Warehouse: { visible: false }
        },
        addButton: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Quality: { visible: false },
            Purchase: { visible: false },
            Warehouse: { visible: false }
        },
        colchange: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Warehouse: { visible: false }
        },
        deleteButton: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Quality: { visible: false },
            Purchase: { visible: false },
            Warehouse: { visible: false }
        },
        seihinIchiran: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Warehouse: { visible: false }
        },
        yasumiIchiran: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Warehouse: { visible: false }
        },
        zenLine: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Warehouse: { visible: false }
        },
        "grid:itemGrid.cd_hinmei": {
            Editor: { enable: false },
            Viewer: { enable: false },
            Warehouse: { visible: false }
        },
        search: {
            Editor: { enable: false },
            Viewer: { enable: false },
            Warehouse: { visible: false }
        },
        excel: {
            Editor: { enable: false },
            Viewer: { enable: false },
            Warehouse: { visible: false }
        },
        total: {
            Editor: { enable: false },
            Viewer: { enable: false },
            Warehouse: { visible: false }
        },
        csReflect: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Quality: { visible: false },
            Purchase: { visible: false },
            Warehouse: { visible: false }
        }
        // TODO: ここまで
    });

    //// ページデータ -- End
})();