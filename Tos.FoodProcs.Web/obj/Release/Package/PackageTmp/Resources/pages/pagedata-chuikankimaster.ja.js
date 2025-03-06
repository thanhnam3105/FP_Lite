(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("ja", {
        // 画面項目
        _pageTitle: { text: "注意喚起マスタ" },
        //検索条件
        kbn_chui_kanki: { text: "注意喚起区分" },
        //明細
        cd_chui_kanki: { text: "コード" },
        nm_chui_kanki: { text: "名称" },
        flg_mishiyo: { text: "未使用" },
        ts: { text: "タイムスタンプ" },
        // 画面メッセージ
        addRecordMax: { text: MS0052 },
        saveConfirm: { text: MS0064 },
        searchConfirm: { text: MS0065 },
        searchBefore: { text: MS0621 },
        rangeDuplicat: { text: MS0501 },
        noRecords: { text: MS0442 },
        notFound: { text: MS0037 },
        noSelect: { text: MS0443 },
        noChange: { text: MS0444 },
        changeCondition: { text: MS0299 },
        unloadWithoutSave: { text: MS0066 },
        overSearchCount: { text: MS0624 },
        // TODO: 画面の仕様に応じて以下の列幅を変更してください。
        cd_chui_kanki_width: { number: 100 },
        nm_chui_kanki_width: { number: 350 },
        flg_mishiyo_width: { number: 80 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("ja", {
        // バリデーションルールとバリデーションメッセージ
        cd_chui_kanki: {
            rules: {
                required: "コード",
                maxbytelength: 10,
                alphanum: true
            },
            messages: {
                required: MS0042,
                maxbytelength: MS0012,
                alphanum: MS0439,
            }
        },
        nm_chui_kanki: {
            rules: {
                required: "名称",
                illegalchara: true,
                maxbytelength: 50
            },
            messages: {
                required: MS0042,
                illegalchara: MS0005,
                maxbytelength: MS0012
            }
        }
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("ja", {
        // 画面制御ルール(権限)
        search: {
            Purchase: { visible: false }
        },
        colchange: {
            Purchase: { visible: false }
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
        save: {
            Manufacture: { visible: false },
            Purchase: { visible: false },
            Warehouse: { visible: false }
        }
    });

    //// ページデータ -- End
})();
