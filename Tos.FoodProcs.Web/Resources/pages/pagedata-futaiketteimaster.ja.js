(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("ja", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "風袋決定マスタ" },
        wt_kowake: { text: "重量" },
        cd_tani: { text: "単位" },
        cd_futai: { text: "風袋コード" },
        nm_futai: { text: "風袋名" },
        flg_mishiyo: { text: "未使用" },
        kbn_jotai: { text: "状態区分" },
        cd_hinmei: { text: "品名コード" },
        //kbn_hin: { text: "品名区分" },
        kbn_hin: { text: "品区分" },
        nm_hinmei: { text: "品名" },
        dt_create: { text: "作成日時" },
        cd_create: { text: "作成者" },
        ts: { text: "タイムスタンプ" },

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

    App.ui.pagedata.validation("ja", {
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
                required: "単位"
            },
            messages: {
                required: MS0042
            }
        },
        cd_futai: {
            rules: {
                required: "風袋コード",
                alphanum: true,
                maxlength: 10
            },
            params: {
                custom: "風袋コード"
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
                custom: "品名コード"
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
    App.ui.pagedata.operation("ja", {
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
