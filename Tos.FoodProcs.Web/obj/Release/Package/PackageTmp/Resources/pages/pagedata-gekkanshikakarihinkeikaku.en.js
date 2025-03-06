(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("en", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Monthly Mixer Plan" },
        // 明細
        dt_hitsuyo: { text: "Required date" },
        dt_hitusyo_yobi: { text: "Day of the week" },
        //dt_shikomi: { text: "Produce date" },
        dt_shikomi: { text: "Production<br>date" },
        nm_hinmei: { text: "Parents semi-finished<br>product name" },
        cd_shikakari: { text: "Code" },
        nm_shikakarihin: { text: "Name" },
        kbn_gassan: { text: "Total<br>type" },
        tan_shiyo: { text: "Usage<br>unit" },
        wt_hituyo: { text: "Required<br>amount" },
        wt_shikomi: { text: "Produce<br>amount" },
        cd_line: { text: "Line code" },
        nm_line: { text: "Line name" },
        no_lot_seihin: { text: "Product lot" },
        no_lot_oya: { text: "Parents semi-finished<br>product lot" },
        no_lot_shikakari: { text: "Semi-finished<br>product lot" },
        // 検索条件
        dt_hiduke_search: { text: "Date" },
        dt_hiduke_start: { text: " Date (start)" },
        dt_hiduke_end: { text: " Date (end)" },
        nm_shokuba_search: { text: "Workplace" },
        cd_hinmei_search: { text: "Code" },
        nm_hinmei_search: { text: "Name" },
        rd_lotNashi: { text: "None" },
        rd_lotSeihin: { text: "Product" },
        rd_lotOya: { text: "Parents work in progress" },
        rd_lotShikakari: { text: "Work in progress" },
        no_lot_search: { text: "Lot" },
        // 画面で利用するテキスト
        seihinIchiran: { text: "Semi-finished product list" },
        lineIchiran: { text: "Line list" },
        namisen: { text: "-" },
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
        dt_hitsuyo_tukihi_width: { number: 100 },
        dt_hitsuyo_yobi_width: { number: 140 },
        dt_seizo_width: { number: 100 },
        nm_haigo_width: { number: 140 },
        cd_hinmei_width: { number: 140 },
        nm_shikakari_width: { number: 140 },
        nm_gassan_kbn_width: { number: 50 },
        nm_tani_width: { number: 50 },
        wt_hitsuyo_width: { number: 90 },
        wt_shikomi_keikaku_width: { number: 110 },
        cd_line_width: { number: 100 },
        nm_line_width: { number: 120 },
        no_lot_shikakari_width: { number: 120 },
        no_lot_shikakari_oya_width: { number: 140 },
        no_lot_seihin_width: { number: 120 },
        each_lang_width: { number: 90 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("en", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        // 明細/コード
        dt_seizo: {
            rules: {
                //required: "Manufacture date",
                required: "Production date",
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
                required: "Progressing product code",
                maxbytelength: 14,
                alphanum: true
            },
            //params: {
            //    custom: "Progressing product code"
            //},
            messages: {
                required: MS0042,
                maxbytelength: MS0012,
                alphanum: MS0439
                //custom: MS0049,
                //custom_no_entry: "There is an imperfection in the master."
            }
        },
        wt_shikomi_keikaku: {
            rules: {
                required: "Produce amount",
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
                required: "Line code",
                alphanum: true,
                maxbytelength: 14
            },
            params: {
                custom: "Line code"
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
                custom: "Valid formula code"
            },
            messages: {
                custom: MS0049
            }
        },
        // 検索条件
        dt_hiduke_search_from: {
            rules: {
                required: "Start date",
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
                required: "Finish date",
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
                custom: "Progressing product code"
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
    App.ui.pagedata.operation("en", {
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
