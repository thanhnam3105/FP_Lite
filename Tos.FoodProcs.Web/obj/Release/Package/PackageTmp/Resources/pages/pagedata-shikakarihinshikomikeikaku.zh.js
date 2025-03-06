(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("zh", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        // _pageTitle: { text: "半成品采购计划" },
        _pageTitle: { text: "半成品投入计划" },
        // 明細
        flg_print: { text: "打印" },
        flg_kakutei: { text: "确定" },
        nm_line: { text: "生产线" },
        cd_hinmei: { text: "半成品<br>编号" },
        nm_hinmei: { text: "半成品名" },
        nm_uchiwake: { text: "明细" },
        nm_tani: { text: "使用<br>单位" },
        wt_hitsuyo: { text: "必要量" },
        wt_shikomi: { text: "投放量" },
        nm_ritsu_bai: { text: "倍率" },
        //nm_su_batch: { text: "批次数量" },
        //nm_su_batch: { text: "批次数" },
        nm_su_batch: { text: "锅数" },
        nm_seiki: { text: "正式" },
        //nm_hasu: { text: "零数" },
        nm_hasu: { text: "零头数" },
        //nm_zan_shikakari: { text: "半成品余量" },
        nm_zan_shikakari: { text: "当天半成品余量" },
        nm_gokei_label: { text: "标签合计" },
        nm_label: { text: "标签" },
        //no_lot_shikakarihin: { text: "半成品<br>批量号码" },
        no_lot_shikakarihin: { text: "半成品<br>批号" },
        nm_haigo: { text: "配料名" },
        blank: { text: "" },
        //nm_shikakari_oya_sub: { text: "主半成品批量号码" },
        nm_shikakari_oya_sub: { text: "主半成品批号" },
        //nm_seihin_sub: { text: "生产批量号码" },
        nm_seihin_sub: { text: "生产批号" },

        // 検索条件
        dt_hiduke_search: { text: "日期" },
        nm_shokuba_search: { text: "车间" },
        nm_line_search: { text: "生产线" },
        flg_kakutei_search: { text: "确定" },
        flg_mikakutei_search: { text: "未确定" },
        rd_shikomi_search: { text: "投放车间" },
        rd_shiyo_search: { text: "使用车间" },

        // ボタン
        btn_print_select: { text: "打印选择" },
        btn_label_kobetsu: { text: "标签发行" },
        btn_label_chomieki: { text: "调味液标签发行" },
        btn_itiran_line: { text: "生产线一览" },
        btn_insatsu_sentaku: { text: "打印选择" },
        // その他
        btn_label_message: { text: "标签打印对话框" },

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

    App.ui.pagedata.validation("zh", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        wt_shikomi_keikaku: {
            rules: {
                required: "计划投放量",
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
                required: "计划倍率",
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
                //required: "计划倍率零数",
                required: "计划倍率零头数",
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
                //required: "计划批次数量",
                required: "计划锅数量",
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
                //required: "计划批次数量零头数",
                //required: "计划锅数量零数",
                required: "计划锅数量零头数",
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
                required: "日期",
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
    App.ui.pagedata.operation("zh", {
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
