
(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("en", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "UOM Master" },
        cd_tani: { text: "Unit code" },
        nm_tani: { text: "Unit name" },
        flg_kinshi: { text: "Prohibition" },
        flg_mishiyo: { text: "Unused" },
        dt_create: { text: "Registration date" },
        cd_create: { text: "Registrant" },
        dt_update: { text: "Update date" },
        cd_update: { text: "Updater" },
        ts: { text: "Time stamp" },
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

    App.ui.pagedata.validation("en", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        
        cd_tani: {
            rules: {
                required: "Unit code",
                alphanum: true,
                maxlength: 10
            },
            messages: {
                required: MS0042,
                alphanum: MS0439,
                maxlength: MS0012
            }
        },
        nm_tani: {
            rules: {
                required: "Unit",
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
    // 権限設定
    App.ui.pagedata.operation("en", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
        colchange: {
            Manufacture: { visible: false }
        },
        save: {
            Manufacture: { visible: false },
            Warehouse: { visible: false }
        }
        // TODO: ここまで
    });
    //// ページデータ -- End
})();
