(function () {
    var lang = App.ui.pagedata.lang("en", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Usable Inventory Master" },
        cd_shikakari_zan: { text: "Inventory code" },
        nm_shikakari_zan: { text: "Name" },
        no_juni_hyoji: { text: "Display No." },
        cd_seihin: { text: "Product code" },
        nm_seihin: { text: "Product name" },
        nm_nisugata_hyoji: { text: "Usage unit" },
        flg_mishiyo: { text: "Unused" }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("en", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        cd_shikakari_zan: {
            rules: {
                required: "Inventory code",
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
                required: "Product code",
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
                required: "Display No.",
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
    App.ui.pagedata.operation("en", {
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
