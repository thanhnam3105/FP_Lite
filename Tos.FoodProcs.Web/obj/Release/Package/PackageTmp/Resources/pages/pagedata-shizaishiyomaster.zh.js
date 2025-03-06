(function () {
    var lang = App.ui.pagedata.lang("zh", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "材料使用主表" },
        cd_hinmei: { text: "产品编号" },
        nm_hinmei: { text: "产品名" },
        nm_nisugata_hyoji: { text: "包装" },
        nm_han: { text: "版本" },
        nm_shinki_han: { text: "新版" },
        _meisaiTitle: { text: "材料使用变更" },
        notUse: { text: "不使用时" },
        flg_mishiyo: { text: "未使用" },
        dt_from: { text: "有効日期" },
        cd_shizai: { text: "材料编号" },
        nm_shizai: { text: "材料名" },
        nm_tani_shiyo: { text: "使用单位" },
        su_shiyo: { text: "使用数" },
        delete_shizai: { text: "材料使用删除" }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("zh", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        cd_hinmei: {
            rules: {
                required: "产品编号",
                alphanum: true,
                custom: true
            },
            params: {
                custom: "产品编号"
            },
            messages: {
                required: MS0042,
                alphanum: MS0005,
                custom: MS0049
            }
        },
        cd_shizai: {
            rules: {
                required: "材料编号",
                alphanum: true,
                maxbytelength: 14,
                custom: true
            },
            params: {
                custom: "材料编号"
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
                required: "使用数",
                pointlength: [6, 6, false],
                range: [0, 999999.999999]
            },
            messages: {
                required: MS0042,
                pointlength: MS0440,
                range: MS0450
            }
        }
        // TODO: ここまで
    });
    App.ui.pagedata.validation2("zh", {
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
    App.ui.pagedata.operation("zh", {
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
