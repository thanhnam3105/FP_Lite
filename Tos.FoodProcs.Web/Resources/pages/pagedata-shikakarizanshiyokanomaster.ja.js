(function () {
    var lang = App.ui.pagedata.lang("ja", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "仕掛残使用可能マスタ" },
        cd_shikakari_zan: { text: "仕掛残コード" },
        nm_shikakari_zan: { text: "名称" },
        no_juni_hyoji: { text: "表示順" },
        cd_seihin: { text: "コード" },
        nm_seihin: { text: "品名" },
        nm_nisugata_hyoji: { text: "荷姿" },
        flg_mishiyo: { text: "未使用" }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("ja", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        cd_shikakari_zan: {
            rules: {
                required: "仕掛残コード",
                alphanum: true,
                maxbytelength: 14
            },
            messages: {
                required: MS0042,
                alphanum: MS0005,
                maxbytelength: MS0012
            }
        },
        cd_seihin: {
            rules: {
                required: "製品コード",
                alphanum: true,
                maxbytelength: 14,
                custom: true
            },
            messages: {
                required: MS0042,
                alphanum: MS0005,
                maxbytelength: MS0012
            }
        },
        no_juni_hyoji: {
            rules: {
                required: "表示順",
                number: true,
                maxbytelength: 3,
                range: [1, 100]
            },
            messages: {
                required: MS0042,
                number: MS0441,
                maxbytelength: MS0012,
                range: MS0450
            }
        }

        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("ja", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
        search: {
            Manufacture: { visible: false },
            Purchase: { visible: false },
            Warehouse: { visible: false }
        },
        colchange: {
            Manufacture: { visible: false },
            Purchase: { visible: false },
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
        hinmei: {
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
})();
