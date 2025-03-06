(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("ja", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "ラインマスタ"},
        shokuba: { text: "職場" },
        lineCode: { text: "ラインコード" },
        lineName: { text: "ライン名" },
        mishiyoFlag: { text: "未使用" },
        createCode: { text: "登録者" },
        createDate: { text: "登録日時" },
        updateDate: { text: "更新日時" },
        ts: { text: "タイムスタンプ" },
        saveConfirm: { text: MS0064 },
        searchConfirm: { text: MS0065 },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        noRecords: { text: MS0442 },
        notFound: { text: MS0037 },
        noSelect: { text: MS0443 },
        noChange: { text: MS0444 },
        unloadWithoutSave: { text: MS0066 },
        searchBefore: { text: MS0621 },
        changeCondition: { text: MS0299 },
        // TODO: 画面の仕様に応じて以下の列幅を変更してください。
        cd_line_width: { number: 120 },
        nm_line_width: { number: 450 },
        flg_mishiyo_width: { number: 75 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("ja", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        shokuba: {
            rules: {
                required: "職場"
            },
            messages: {
                required: MS0004
            }
        },
        cd_line: {
            rules: {
                required: "ラインコード",
                alphanum: true,
                maxbytelength: 10
            },
            messages: {
                required: MS0042,
                alphanum: MS0439,
                maxbytelength: MS0012
            }
        },
        nm_line: {
            rules: {
                required: "ライン名",
                illegalchara: true,
                maxbytelength: 50
            },
            messages: {
                required: MS0042,
                illegalchara: MS0005,
                maxbytelength: MS0012
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
            Manufacture: { visible: false },
            Quality: { visible: false },
            Purchase: { visible: false },
            Warehouse: { visible: false }
        },
        colchange: {
            Warehouse: { visible: false }
        },
        add: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Purchase: { visible: false },
            Warehouse: { visible: false }
        },
        del: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Purchase: { visible: false },
            Warehouse: { visible: false }
        }
        // TODO: ここまで
    });

    //// ページデータ -- End
})();
