(function () {
    var lang = App.ui.pagedata.lang("zh", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "半成品余量使用可能主表" },
        cd_shikakari_zan: { text: "半成品余量编号" },
        nm_shikakari_zan: { text: "名称" },
        no_juni_hyoji: { text: "显示顺序" },
        cd_seihin: { text: "编号" },
        nm_seihin: { text: "品名" },
        nm_nisugata_hyoji: { text: "包装形式" },
        flg_mishiyo: { text: "未使用" }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("zh", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        cd_shikakari_zan: {
            rules: {
                required: "半成品余量编号",
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
                required: "产品编号",
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
                required: "显示顺序",
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
    App.ui.pagedata.operation("zh", {
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
