(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("ja", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "設備マスタ"},
        shokuba: { text: "職場" },
        cd_setsubi: { text: "コード" },
        nm_setsubi: { text: "設備名" },
        flg_mishiyo: { text: "未使用" },
        cd_create: { text: "登録者" },
        dt_create: { text: "登録日時" },
        ts: { text: "タイムスタンプ" },
        saveConfirm: { text: MS0064 },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        noRecords: { text: MS0442 },
        notFound: { text: MS0037 },
        noSelect: { text: MS0443 },
        noChange: { text: MS0444 },
        unloadWithoutSave: { text: MS0066 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("ja", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        cd_shokuba: {
            rules: {
                required: "職場"
            },
            messages: {
                required: MS0004
            }
        },
        cd_setsubi: {
            rules: {
                required: "設備コード",
                alphanum: true,
                maxbytelength: 10
            },
            messages: {
                required: MS0042,
                alphanum: MS0439,
                maxbytelength: MS0012
            }
        },
        nm_setsubi: {
            rules: {
                required: "設備名",
                maxbytelength: 50
            },
            messages: {
                required: MS0042,
                maxbytelength: MS0012
            }
        }
        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("ja", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
        // TODO: ここまで
    });

    //// ページデータ -- End
})();
