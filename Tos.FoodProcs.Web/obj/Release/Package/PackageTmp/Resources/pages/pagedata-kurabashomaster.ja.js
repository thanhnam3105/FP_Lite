(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("ja", {
        // 画面項目
        _pageTitle: { text: "庫場所マスタ"},
        cd_kura: { text: "庫場所コード" },
        nm_kura: { text: "庫場所名" },
        flg_mishiyo: { text: "未使用" },
        // 隠し項目
        ts: { text: "タイムスタンプ" },
        // 画面メッセージ
        saveConfirm: { text: MS0064 },
        errorSize: { text: MS0500 },
        noRecords: { text: MS0442 },
        notFound: { text: MS0037 },
        noSelect: { text: MS0443 },
        noChange: { text: MS0444 },
        unloadWithoutSave: { text: MS0066 },
        // TODO: 画面の仕様に応じて以下の列幅を変更してください。
        cd_kura_width: { number: 120 },
        nm_kura_width: { number: 350 },
        flg_mishiyo_width: { number: 65 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("ja", {
        // バリデーションルールとバリデーションメッセージ
        cd_kura: {
            rules: {
                required: "庫場所コード",
                maxbytelength: 10,
                alphanum: true
            },
            messages: {
                required: MS0042,
                maxbytelength: MS0012,
                alphanum: MS0439
            }
        },
        nm_kura: {
            rules: {
                required: "庫場所名",
                maxbytelength: 50
            },
            messages: {
                required: MS0042,
                maxbytelength: MS0012
            }
        }
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("ja", {
        // 画面制御ルール(権限)
        colchange: {
            Manufacture: { visible: false },
            Quality: { visible: false }
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
        save: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        }
    });

    //// ページデータ -- End
})();
