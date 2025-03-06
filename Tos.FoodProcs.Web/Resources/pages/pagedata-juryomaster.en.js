(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("en", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Basic Weighing Weight Master" },
        cd_hinmei: { text: "Code" },
        nm_hinmei: { text: "Name" },
        wt_kowake: { text: "Weight" },
        kbn_jotai: { text: "Condition" },
        kbn_hin: { text: "Item type" },
        cd_hinmei_kensaku: { text: "Code" },
        nm_hinmei_kensaku: { text: "Name" },
        dt_create: { text: "Creation date" },
        cd_create: { text: "Creater" },
        ts: { text: "Time stamp" },
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        // TODO: 画面の仕様に応じて以下の列幅を変更してください。
        cd_hinmei_width: { number: 130 },
        nm_hinmei_width: { number: 500 },
        wt_kowake_width: { number: 130 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("en", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。

        cd_hinmei: {
            rules: {
            	alphanumForCode: true,
                maxlength: 14,
                custom: false
            },
            params: {
                custom: "Code"
            },
            messages: {
                alphanumForCode: MS0439,
                maxlength: MS0012,
                custom: MS0049
            }
        },
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
        cd_hinmei_kensaku: {
            rules: {
                alphanum: true,
                maxlength: 14,
                custom: false
            },
            params: {
                custom: "Item name code"
            },
            messages: {
                alphanum: MS0439,
                maxlength: MS0012,
                custom: MS0049
            }
        },
        kbn_hin: {
            rules: {
                custom: false
            },
            params: {
                custom: "Item name code"
            },
            messages: {
            	custom: MS0049
            }

        }
        //  TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("en", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
        search: {
            Warehouse: { visible: false }
        },
        colchange: {
            Warehouse: { visible: false }
        },
        add: {
            Purchase: { visible: false },
            Warehouse: { visible: false }
        },
        del: {
            Purchase: { visible: false },
            Warehouse: { visible: false }
        },
        hinmei: {
            Purchase: { visible: false },
            Warehouse: { visible: false }
        },
        save: {
            Purchase: { visible: false },
            Warehouse: { visible: false }
        }
        // TODO: ここまで
    });

    //// ページデータ -- End
})();
