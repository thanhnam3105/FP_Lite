
(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("ja", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "保管区分マスタ" },
        cd_hokan_kbn: { text: "保管区分コード" },
        nm_hokan_kbn: { text: "保管区分名" },
        flg_mishiyo: { text: "未使用" },
        cd_create: { text: "登録者" },
        dt_create: { text: "登録日時" },
        dt_update: { text: "更新日時" },
        cd_update: { text: "更新者" },
        ts: { text: "タイムスタンプ" },
        saveConfirm: { text: MS0064 },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        noRecords: { text: MS0442 },
        notFound: { text: MS0037 },
        noSelect: { text: MS0443 },
        noChange: { text: MS0444 },
        unloadWithoutSave: { text: MS0066 },
        // TODO: 画面の仕様に応じて以下の列幅を変更してください。
        cd_hokan_kbn_width: { number: 125 },
        nm_hokan_kbn_width: { number: 400 },
        flg_mishiyo_width: { number: 70 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("ja", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。

        cd_hokan_kbn: {
            rules: {
                required: "保管区分コード",
                alphanum: true,
                maxlength: 10
            },
            messages: {
                required: MS0042,
                alphanum: MS0439,
                maxlength: MS0012
            }
        },
        nm_hokan_kbn: {
            rules: {
                required: "保管区分名",
                maxbytelength: 50,
                illegalchara: true
            },
            messages: {
                required: MS0042,
                maxbytelength: MS0012,
                illegalchara: MS0005,
            }
        }
        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("ja", {
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
        "grid:itemGrid.cd_hokan_kbn": {
            admin: { enable: true },
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
