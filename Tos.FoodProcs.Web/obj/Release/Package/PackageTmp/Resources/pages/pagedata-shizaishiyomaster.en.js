(function () {
    var lang = App.ui.pagedata.lang("en", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Packing Bom Master" },
        cd_hinmei: { text: "Code" },
        nm_hinmei: { text: "Name" },
        nm_nisugata_hyoji: { text: "Packing style" },
        nm_han: { text: "Version" },
        nm_shinki_han: { text: "New version" },
        _meisaiTitle: { text: "Change packing materials usage" },
        notUse: { text: "When not usage" },
        flg_mishiyo: { text: "Unused" },
        dt_from: { text: "Valid date" },
        cd_shizai: { text: "Code" },
        nm_shizai: { text: "Name" },
        nm_tani_shiyo: { text: "Usage unit" },
        su_shiyo: { text: "Usage quantity" },
        delete_shizai: { text: "Delete" }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("en", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        cd_hinmei: {
            rules: {
                required: "Product code",
                alphanum: true,
                custom: true
            },
            params: {
                custom: "Product code"
            },
            messages: {
                required: MS0042,
                alphanum: MS0005,
                custom: MS0049
            }
        },
        cd_shizai: {
            rules: {
                required: "Packing materials code",
                alphanum: true,
                maxbytelength: 14,
                custom: true
            },
            params: {
                custom: "Packing materials code"
            },
            messages: {
                required: MS0042,
                alphanum: MS0005,
                maxbytelength: MS0012,
                custom: MS0049
            }
        },
        su_shiyo: {
            rules: {
                required: "Usage amount",
                pointlength: [6, 6, false],
                range: [0, 999999.999999]
            },
            messages: {
                required: MS0042,
                pointlength: MS0440,
                range: MS0450
            }
        },
        dt_from: {
            rules: {
                custom: true
            },
            messages: {
                custom: MS0666
            }
        }
        // TODO: ここまで
    });
    App.ui.pagedata.validation2("en", {
        // 有効日付専用バリデーション
        dt_from: {
            rules: {
                datestring: true,
                lessdate: new Date(1975, 1 - 1, 1 - 1),
                greaterdate: new Date(new Date().getFullYear() + 50, new Date().getMonth(), new Date().getDate() + 1)
            },
            messages: {
                datestring: MS0247,
                lessdate: MS0247,
                greaterdate: MS0247
            }
        }
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("en", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
        shinkiHan: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        search: {
            Warehouse: { visible: false }
        },
        colchange: {
            Warehouse: { visible: false }
        },
        add: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        del: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        shizai: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        save: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        delete_shizai: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        }
        // TODO: ここまで
    });
})();
