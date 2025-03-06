(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("zh", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "原料注意唤起主表" },
        //検索条件
        //kbn_hin: { text: "品区分" },
        kbn_hin: { text: "商品区分" },
        cd_hinmei: { text: "编号" },
        nm_hinmei: { text: "名称" },
        kbn_chui_kanki: { text: "注意唤起区分" },
        chuiIchiran: { text: "注意唤起名" },

        //明細
        cd_chui_kanki: { text: "注意唤起编号" },
        nm_chui_kanki: { text: "注意唤起名" },
        no_juni_yusen: { text: "顺序" },
        flg_chui_kanki_hyoji: { text: "注意唤起" },
        flg_mishiyo: { text: "未使用" },
        ts: { text: "时间标记" },
        dt_create: { text: "作成日期" },
        cd_create: { text: "作成者" },

        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        addRecordMax: { text: MS0052 },
        noRecords: { text: MS0442 },
        noSelect: { text: MS0443 },
        noChange: { text: MS0444 },
        unloadWithoutSave: { text: MS0066 },
        saveConfirm: { text: MS0064 },
        clearConfirm: { text: MS0070 },
        searchBefore: { text: MS0621 },
        changeCondition: { text: MS0299 },
        overSearchCount: { text: MS0624 },
        addSelectChui: { text: MS0721 },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の列幅を変更してください。
        cd_chui_kanki_width: { number: 120 },
        nm_chui_kanki_width: { number: 380 },
        no_juni_yusen_width: { number: 70 },
        flg_chui_kanki_hyoji_width: { number: 70 },
        flg_mishiyo_width: { number: 70 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("zh", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。

        cd_chui_kanki: {
            rules: {
                required: "注意唤起编号",
                alphanum: true,
                maxlength: 10
            },

            params: {
                custom: "注意唤起编号"
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
                required: "编号",
                alphanum: true,
                maxlength: 14
            },
            params: {
                custom: "编号"
            },
            messages: {
                required: MS0042,
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
            Purchase: { visible: false }
        },
        colchange: {
            Purchase: { visible: false }
        },
        add: {
            Manufacture: { visible: false },
            Purchase: { visible: false },
            Warehouse: { visible: false }
        },
        del: {
            Manufacture: { visible: false },
            Purchase: { visible: false },
            Warehouse: { visible: false }
        },
        chui: {
            Manufacture: { visible: false },
            Purchase: { visible: false },
            Warehouse: { visible: false }
        },
        save: {
            Manufacture: { visible: false },
            Purchase: { visible: false },
            Warehouse: { visible: false }
        }
        // TODO: ここまで
    });

    //// ページデータ -- End
})();
