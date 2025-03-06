(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("ja", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "製造可能ラインマスタ"},
        masterKubun: { text: "マスタ区分" },
        haigoCode: { text: "コード" },
        haigoName: { text: "名称" },
        seizoLineCode: { text: "ラインコード" },
        seizoLineName: { text: "ライン名" },
        yusenNumber: { text: "順位" },
        mishiyoFlag: { text: "未使用" },
        torokuCode: { text: "登録者" },
        torokuDate: { text: "登録日時" },
        ts: { text: "タイムスタンプ" },
        saveConfirm: { text: MS0064 },
        clearConfirm: { text: MS0070 },
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
        masterKubun: {
            rules: {
                required: "マスタ区分"
            },
            messages: {
                required: MS0004
            }
        },
        haigoCode: {
            rules: {
                required: "配合コード",
                alphanum: true,
                maxbytelength: 14,
				custom: true
            },
            params: {
                custom: "配合コード"
            },
            messages: {
                required: MS0004,
                alphanum: MS0439,
                maxbytelength: MS0012,
                custom: MS0049
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
                alphanum: MS0005,
                maxbytelength: MS0012,
                custom: MS0049
            }
        },
        no_juni_yusen: {
            rules: {
                required: "順位",
                digits: true,
                range: [1, 99],
                maxbytelength: 2
            },
            messages: {
                required: MS0042,
                digits: MS0005,
                range: MS0009,
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
        line: {
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
