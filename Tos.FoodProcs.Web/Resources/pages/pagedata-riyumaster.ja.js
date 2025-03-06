(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("ja", {
        // 画面項目
        _pageTitle: { text: "理由マスタ"},
        cd_riyu: { text: "理由コード" },
        nm_riyu: { text: "理由名" },
        flg_kinshi: { text: "禁止" },
        flg_denso: { text: "伝送" },
        // 検索条件
        kbn_bunrui_riyu: { text: "理由分類" },
        // 隠し項目
        ts: { text: "タイムスタンプ" },
        // 画面メッセージ
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
        notDel: { text: MS0238 }
    });

    App.ui.pagedata.validation("ja", {
        // バリデーションルールとバリデーションメッセージ
        cd_riyu: {
            rules: {
                required: "理由コード",
                alphanum: true,
                maxlength: 10
            },
            messages: {
                required: MS0042,
                alphanum: MS0439,
                maxlength: MS0021
            }
        },
        nm_riyu: {
            rules: {
                required: "理由名",
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
        search: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        colchange: {
            Manufacture: { visible: false },
            Quality: { visible: false },
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
        save: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        }
    });

    //// ページデータ -- End
})();
