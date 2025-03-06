(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("zh", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "月半成品计划" },
        // 明細
        dt_hitsuyo: { text: "必要日" },
        dt_hitusyo_yobi: { text: "星期" },
        dt_shikomi: { text: "投放日" },
        nm_hinmei: { text: "主要半成品名" },
        cd_shikakari: { text: "半成品编号" },
        nm_shikakarihin: { text: "半成品名" },
        //kbn_gassan: { text: "合计<br>区分" },
        kbn_gassan: { text: "合算<br>区分" },
        tan_shiyo: { text: "使用<br>单位" },
        wt_hituyo: { text: "必要量" },
        wt_shikomi: { text: "投放量" },
        cd_line: { text: "生产线编号" },
        nm_line: { text: "生产线名" },
        //no_lot_seihin: { text: "产品批量" },
        no_lot_seihin: { text: "产品批号" },
        //no_lot_oya: { text: "主要半成品批量" },
        no_lot_oya: { text: "主要半成品批号" },
        //no_lot_shikakari: { text: "半成品批量" },
        no_lot_shikakari: { text: "半成品批号" },
        // 検索条件
        dt_hiduke_search: { text: "日期" },
        dt_hiduke_start: { text: "日期（开始）" },
        dt_hiduke_end: { text: "日期（结束）" },
        nm_shokuba_search: { text: "车间" },
        cd_hinmei_search: { text: "半产品编号" },
        nm_hinmei_search: { text: "半产品名" },
        rd_lotNashi: { text: "无" },
        rd_lotSeihin: { text: "产品" },
        rd_lotOya: { text: "主要半成品" },
        rd_lotShikakari: { text: "半产品" },
        //no_lot_search: { text: "批量" },
        no_lot_search: { text: "批号" },
        // 画面で利用するテキスト
        seihinIchiran: { text: "半产品一览" },
        lineIchiran: { text: "生产线一览" },
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

    App.ui.pagedata.validation("zh", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        // 明細/コード
        dt_seizo: {
            rules: {
                required: "投放日",
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
                required: "半产品编号",
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
                required: "投放日",
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
                required: "生产线编号",
                alphanum: true,
                maxbytelength: 14
            },
            params: {
                custom: "生产线编号"
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
                custom: "有效的配料编号"
            },
            messages: {
                custom: MS0049
            }
        },
    // 検索条件
        dt_hiduke_search_from: {
            rules: {
                required: "开始日期",
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
                required: "结束日期",
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
                custom: "半产品编号"
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
    App.ui.pagedata.operation("zh", {
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