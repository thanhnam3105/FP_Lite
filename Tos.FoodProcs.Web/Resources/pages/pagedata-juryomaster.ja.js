(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("ja", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "重量マスタ" },
        cd_hinmei: { text: "コード" },
        nm_hinmei: { text: "名称" },
        wt_kowake: { text: "重量" },
        kbn_jotai: { text: "状態区分" },
        kbn_hin: { text: "品区分" },
        cd_hinmei_kensaku: { text: "品名コード" },
        nm_hinmei_kensaku: { text: "品名" },
        dt_create: { text: "作成日時" },
        cd_create: { text: "作成者" },
        ts: { text: "タイムスタンプ" },
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        // TODO: 画面の仕様に応じて以下の列幅を変更してください。
        cd_hinmei_width: { number: 130 },
        nm_hinmei_width: { number: 500 },
        wt_kowake_width: { number: 130 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("ja", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。

        cd_hinmei: {
            rules: {
            	alphanumForCode: true,
                maxlength: 14,
                custom: false
            },
            params: {
                custom: "コード"
            },
            messages: {
                alphanumForCode: MS0439,
                maxlength: MS0012,
                custom: MS0049
            }
        },
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
        cd_hinmei_kensaku: {
            rules: {
                alphanum: true,
                maxlength: 14,
                custom: false
            },
            params: {
                custom: "品名コード"
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
                custom: "品名コード"
            },
            messages: {
            	custom: MS0049
            }

        }
        //  TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("ja", {
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
