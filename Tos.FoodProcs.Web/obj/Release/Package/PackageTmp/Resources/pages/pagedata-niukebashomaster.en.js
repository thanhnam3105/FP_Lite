
(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("en", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Receipt Location Master" },
        cd_niuke: { text: "Code" },
        nm_niuke: { text: "Name" },
        jusho_1: { text: "Address1" },
        jusho_2: { text: "Address2" },
        jusho_3: { text: "Address3" },
        flg_mishiyo: { text: "Unused" },
        ts: { text: "Time stamp" },
        cd_toroku: { text: "Registrant" },
        dt_toroku: { text: "Registration date" },
        saveConfirm: { text: MS0064 },
        kbn_niuke_basho: { text: "Type" },
        
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        noRecords: { text: MS0442 },
        noSelect: { text: MS0443 },
        noChange: { text: MS0444 },
        unloadWithoutSave: { text: MS0066 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("en", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。

        cd_niuke_basho: {
            rules: {
                required: "Code",
                alphanum: true,
                maxlength: 10
            },
            messages: {
                required: MS0042,
                alphanum: MS0439,
                maxlength: MS0012
            }
        },
        nm_niuke: {
            rules: {
                required: "Receiving location name",
                maxbytelength: 50
            },
            messages: {
                required: MS0042,
                maxbytelength: MS0012
            }
        },
        kbn_niuke_basho: {
            rules: {
                required: "Type",
                custom: true
            },
            params: {
                custom: "Type"
            },
            messages: {
                required: MS0042,
                custom: MS0042
            }
        },
        nm_jusho_1: {
            rules: {
                maxbytelength: 30
            },
            messages: {
                maxbytelength: MS0012
            }
        },
        nm_jusho_2: {
            rules: {
                maxbytelength: 30
            },
            messages: {
                maxbytelength: MS0012
            }
        },
        nm_jusho_3: {
            rules: {
                maxbytelength: 30
            },
            messages: {
                maxbytelength: MS0012
            }
        }

        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("en", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
        save: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        colchange: {
            Manufacture: { visible: false }
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
        }
        // TODO: ここまで
    });

    //// ページデータ -- End
})();
