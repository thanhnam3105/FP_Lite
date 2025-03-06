(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("ja", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "月間製品計画" },
        // 明細
        dt_seizo: { text: "日" },
        dt_seizo_yobi: { text: "曜" },
        cd_riyu: { text: "コード" },
        nm_riyu: { text: "休日理由" },
        cd_hinmei: { text: "コード" },
        nm_hinmei: { text: "製品名" },
        nm_nisugata: { text: "荷姿" },
        su_seizo_yotei: { text: "製造数" },
        su_seizo_jisseki: { text: "実績数" },
        no_lot_seihin: { text: "製品ロットNo" },
        batch: { text: "バッチ数" },
        bairitsu: { text: "倍率" },
        check_reflect: { text: "反映対象" },
        // 検索条件
        dt_hiduke_search: { text: "日付" },
        nm_shokuba_search: { text: "職場" },
        nm_line_search: { text: "ライン" },
        // 画面で利用するテキスト
        zenLine: { text: "全ライン確認" },
        gokei: { text: "合計表示" },
        //seihinIchiran: { text: "製品一覧" },
        yasumiIchiran: { text: "休み一覧" },
        csReflect: { text: "C/S数反映" },
        blank: { text: "" },
        msg_param: { text: "の製造数"},
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
        dt_seizo_yobi_width: { number: 50 },
        cd_hinmei_width: { number: 100 },
        nm_hinmei_width: { number: 180 },
        nm_nisugata_hyoji_width: { number: 120 },
        su_seizo_yotei_width: { number: 120 },
        su_seizo_jisseki_width: { number: 120 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("ja", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        su_seizo_yotei: {
            rules: {
                required: "製造数",
                number: true
            },
            params: {
                custom: ["製造数", 1, 9999999999]
            },
            messages: {
                required: MS0042,
                number: MS0441,
                custom: MS0666
            }
        },
        cd_hinmei: {
            rules: {
                required: "コード"
            },
            messages: {
                required: MS0042
            }
        },
        //nm_hinmei_ja: { //製品名日本語用
        //    rules: {
        //        required: "製品名"
        //    },
        //    messages: {
        //        required: MS0122
        //    }
        //},
        wt_ko: { // マスタ整合性チェック用
            rules: {
                required: "一個の量"
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
                required: "日付",
                monthstring: true,
                lessmonth: new Date(1974, 12 - 1),
                greatermonth: new Date(new Date().getFullYear()+3, new Date().getMonth()+1)
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
                required: "ライン名"
            },
            messages: {
                required: MS0004
            }
        }
        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("ja", {
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
