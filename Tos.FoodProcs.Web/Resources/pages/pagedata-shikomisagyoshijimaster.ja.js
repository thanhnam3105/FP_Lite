
(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("ja", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "仕込作業指示マスタ" },
        cd_sagyo: { text: "仕込作業指示コード" },
        nm_sagyo: { text: "仕込作業指示名" },
        detail: { text: "詳細"},
        cd_mark: { text: "マーク" },
        flg_mishiyo: { text: "未使用" },
        ts: { text: "タイムスタンプ" },
        cd_create: { text: "登録者" },
        dt_create: { text: "登録日時" },
        saveConfirm: { text: MS0064 },

        // 検索条件
        con_sagyo: { text: "仕込作業指示" },

        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        noRecords: { text: MS0442 },
        noSelect: { text: MS0443 },
        noChange: { text: MS0444 },
        notFound: { text: MS0037 },
        unloadWithoutSave: { text: MS0066 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("ja", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。

        cd_sagyo: {
            rules: {
                required: "コード",
                alphanum: true,
                maxlength: 10
            },
            messages: {
                required: MS0042,
                alphanum: MS0439,
                maxlength: MS0012
            }
        },
        nm_sagyo: {
            rules: {
                illegalchara: true,
                required: "仕込作業指示名",
                maxbytelength: 50
            },
            messages: {
                illegalchara: MS0005,
                required: MS0042,
                maxbytelength: MS0012
            }
        },
        detail: {
            rules: {
                illegalchara: true,
                maxbytelength: 4000
            },
            messages: {
                illegalchara: MS0005,
                maxbytelength: MS0012
            }
        },
        cd_mark: {
            rules: {
                required: "マーク"
            },
            messages: {
                required: MS0042
            }
        }
        // TODO: ここまで
    });
    App.ui.pagedata.validation2("ja", {
        // 検索条件のバリデーション
        con_sagyo: {
            rules: {
                illegalchara: true,
                maxbytelength: 50
            },
            messages: {
                illegalchara: MS0005,
                maxbytelength: MS0012
            }
        }
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("ja", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
        save: {
            Manufacture: { visible: false },
            Purchase: { visible: false },
            Warehouse: { visible: false }
        },
        colchange: {
            Warehouse: { visible: false }
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
        search: {
            Warehouse: { visible: false }
        },
        "grid:itemGrid.cd_sagyo": {
            Manufacture: { visible: false },
            Purchase: { visible: false },
            Warehouse: { visible: false }
        }
        // TODO: ここまで
    });

    //// ページデータ -- End
})();
