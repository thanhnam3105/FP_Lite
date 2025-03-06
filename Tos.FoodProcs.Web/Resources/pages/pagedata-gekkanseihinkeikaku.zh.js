(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("zh", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "月产品计划" },
        // 明細
        dt_seizo: { text: "日" },
        dt_seizo_yobi: { text: "星期" },
        cd_riyu: { text: "编号" },
        nm_riyu: { text: "假日理由" },
        cd_hinmei: { text: "编号" },
        nm_hinmei: { text: "产品名" },
        //nm_nisugata: { text: "包装" },
        nm_nisugata: { text: "包装形式" }, 
        su_seizo_yotei: { text: "生产数" },
        su_seizo_jisseki: { text: "实际数" },
        no_lot_seihin: { text: "产品批号" },
        //batch: { text: "批次数" },
        batch: { text: "锅数" },
        bairitsu: { text: "倍率" },
        check_reflect: { text: "反映対象" },
        // 検索条件
        dt_hiduke_search: { text: "日期" },
        nm_shokuba_search: { text: "车间" },
        nm_line_search: { text: "生产线" },
        // 画面で利用するテキスト
        zenLine: { text: "确认全部线" },
        gokei: { text: "合计显示" },
        //seihinIchiran: { text: "製品一覧" },
        yasumiIchiran: { text: "休假一览" },
        csReflect: { text: "C/S数反映" },
        blank: { text: "" },
        msg_param: { text: "的生产数" },
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

    App.ui.pagedata.validation("zh", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        su_seizo_yotei: {
            rules: {
                required: "生产数",
                number: true
            },
            params: {
                custom: ["生产数", 1, 9999999999]
            },
            messages: {
                required: MS0042,
                number: MS0441,
                custom: MS0666
            }
        },
        cd_hinmei: {
            rules: {
                required: "编号"
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
                required: "一个数量"
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
                required: "日期",
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
                required: "生产线名"
            },
            messages: {
                required: MS0004
            }
        }
        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("zh", {
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
