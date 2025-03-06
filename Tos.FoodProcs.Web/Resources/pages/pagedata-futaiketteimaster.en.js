(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("en", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Tare Of Each Weight Master" },
        wt_kowake: { text: "Weight" },
        cd_tani: { text: "Unit" },
        cd_futai: { text: "Code" },
        nm_futai: { text: "Name" },
        flg_mishiyo: { text: "Unused" },
        kbn_jotai: { text: "Condition" },
        cd_hinmei: { text: "Item code" },
        kbn_hin: { text: "Item type" },
        nm_hinmei: { text: "Name" },
        dt_create: { text: "Creation date" },
        cd_create: { text: "Creater" },
        ts: { text: "Time stamp" },

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

    App.ui.pagedata.validation("en", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。

        wt_kowake: {
            rules: {
                required: "Weight",
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
                required: "Unit"
            },
            messages: {
                required: MS0042
            }
        },
        cd_futai: {
            rules: {
                required: "Packing code",
                alphanum: true,
                maxlength: 10
            },
            params: {
                custom: "Packing code"
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
                custom: "Item name code"
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
    App.ui.pagedata.operation("en", {
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
