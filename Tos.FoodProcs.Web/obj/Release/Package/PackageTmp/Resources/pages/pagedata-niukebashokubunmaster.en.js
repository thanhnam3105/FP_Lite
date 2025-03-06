
(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("en", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Receipt Location Type Master" },
        kbn_niuke_basho: { text: "Code" },
        nm_kbn_niuke: { text: "Name" },
        flg_niuke: { text: "Receipt Location Allowed" },
        flg_henpin: { text: "Return Inventory Allowed" },
        flg_shukko: { text: "Materials Issue Allowed" },
        flg_mishiyo: { text: "Unused" },

        cd_create: { text: "Registered by" },
        dt_create: { text: "Registration date" },
        dt_update: { text: "Update Date" },
        cd_update: { text: "Updated by" },
        ts: { text: "Time stamp" },

        saveConfirm: { text: MS0064 },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        noRecords: { text: MS0442 },
        notFound: { text: MS0037 },
        noSelect: { text: MS0443 },
        noChange: { text: MS0444 },
        unloadWithoutSave: { text: MS0066 },
        // TODO: 画面の仕様に応じて以下の列幅を変更してください。
        kbn_niuke_basho_width: { number: 100 },
        nm_kbn_niuke_width: { number: 300 },
        flg_niuke_width: { number: 120 },
        flg_henpin_width: { number: 70 },
        flg_shukko_width: { number: 70 },
        flg_mishiyo_width: { number: 70 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("en", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。

        kbn_niuke_basho: {
            rules: {
                required: "Receipt Location Type",
                alphanum: true,
                maxlength: 10
            },
            messages: {
                required: MS0042,
                alphanum: MS0439,
                maxlength: MS0012
            }
        },
        nm_kbn_niuke: {
            rules: {
                required: "Receipt Location Type Name",
                maxbytelength: 50,
                illegalchara: true
            },
            messages: {
                required: MS0042,
                maxbytelength: MS0012,
                illegalchara: MS0005
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
        },
        "grid:itemGrid.kbn_niuke_basho": {
            Admin: { enable: true },
            guest: { enable: false },
            manager: { visible: false },
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        }
        // TODO: ここまで
    });

    //// ページデータ -- End
})();
