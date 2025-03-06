(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("en", {
        // 画面項目
        _pageTitle: { text: "Reason Master"},
        cd_riyu: { text: "Code" },
        nm_riyu: { text: "Name" },
        flg_kinshi: { text: "Prohibited" },
        flg_denso: { text: "Transmission" },
        // 検索条件
        kbn_bunrui_riyu: { text: "Group" },
        // 隠し項目
        ts: { text: "Time stamp" },
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

    App.ui.pagedata.validation("en", {
        // バリデーションルールとバリデーションメッセージ
        cd_riyu: {
            rules: {
                required: "Reason code",
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
                required: "Reason name",
                maxbytelength: 50
            },
            messages: {
                required: MS0042,
                maxbytelength: MS0012
            }
        }
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("en", {
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
