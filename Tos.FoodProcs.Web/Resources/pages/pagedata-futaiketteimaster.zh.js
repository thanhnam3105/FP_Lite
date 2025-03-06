(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("zh", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "包装决定主表" },
        wt_kowake: { text: "重量" },
        cd_tani: { text: "单位" },
        cd_futai: { text: "包装编号" },
        nm_futai: { text: "包装名" },
        flg_mishiyo: { text: "未使用" },
        kbn_jotai: { text: "状态区分" },
        cd_hinmei: { text: "品名编号" },
        //kbn_hin: { text: "品名区分" },
        kbn_hin: { text: "商品区分" },
        nm_hinmei: { text: "品名" },
        dt_create: { text: "作成日期" },
        cd_create: { text: "作成者" },
        ts: { text: "时间标记" },

        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        noRecords: { text: MS0442 },
        noSelect: { text: MS0443 },
        noChange: { text: MS0444 },
        unloadWithoutSave: { text: MS0066 },
        saveConfirm: { text: MS0064 },
        clearConfirm: { text: MS0070 },
        searchBefore: { text: MS0621 },
        changeCondition: { text: MS0299 },
        overSearchCount: { text: MS0624 },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の列幅を変更してください。
        wt_kowake_width: { number: 130 },
        cd_tani_width: { number: 120 },
        cd_futai_width: { number: 100 },
        nm_futai_width: { number: 500 },
        flg_mishiyo_width: { number: 80 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("zh", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。

        wt_kowake: {
            rules: {
                required: "重量",
                number: true,
                pointlength: [6, 6, false]
            },
            messages: {
                required: MS0042,
                number: MS0441,
                pointlength: MS0440
            }
        },
        cd_tani: {
            rules: {
                required: "单位"
            },
            messages: {
                required: MS0042
            }
        },
        cd_futai: {
            rules: {
                required: "包装编号",
                alphanum: true,
                maxlength: 10
            },
            params: {
                custom: "包装编号"
            },
            messages: {
                required: MS0042,
                alphanum: MS0439,
                maxlength: MS0012,
                custom: MS0049
            }
        },
        cd_hinmei: {
            rules: {
                alphanum: true,
                maxlength: 14
            },
            params: {
                custom: "品名编号"
            },
            messages: {
                alphanum: MS0439,
                maxlength: MS0012,
                custom: MS0049
            }
        }
        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("zh", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
        search: {
            Warehouse: { visible: false }
        },
        save: {
            Purchase: { visible: false },
            Warehouse: { visible: false }
        },
        clear: {
            Purchase: { visible: false },
            Warehouse: { visible: false }
        },
        toroku: {
            Warehouse: { visible: false }
        },
        colchange: {
            Warehouse: { visible: false }
        },
        futai: {
            Purchase: { visible: false },
            Warehouse: { visible: false }
        },
        add: {
            Purchase: { visible: false },
            Warehouse: { visible: false }
        },
        del: {
            Purchase: { visible: false },
            Warehouse: { visible: false }
        }
        // TODO: ここまで
    });

    //// ページデータ -- End
})();
