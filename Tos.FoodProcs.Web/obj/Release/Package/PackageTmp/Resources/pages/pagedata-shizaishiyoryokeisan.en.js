(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("en", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Calculate Usage Amount Of Packing Materials" },
        // 明細
        nm_bunrui: { text: "Group" },
        cd_hinmei: { text: "Code" },
        nm_hinmei: { text: "Name" },
        nm_tani: { text: "Usage unit" },
        nm_nisugata_hyoji: { text: "Packing style" },
        su_shiyo_sum: { text: "Quantity of usage plan" },
        wt_shiyo_zan: { text: "Inventory of yesterday" },
        qty_hitsuyo: { text: "Required quantity<br>（usage unit）" },
        qty_hitsuyoNonyu: { text: "Required quantity<br>（delivery unit）" },
        qty_hitsuyoNonyuHasu: { text: "Partial of Required quantity<br>（delivery unit）" },
        nm_torihiki_ryaku: { text: "Maker name" },
        zan_hiduke: { text: "Inventory of yesterday" },
        dt_hiduke: { text: "Registration date" },
        // 検索条件
        dt_hiduke_search: { text: "Date" },
        searchConfirm: { text: MS0065 },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        saveConfirm: { text: MS0064 },
        clearConfirm: { text: MS0070 },
        noRecords: { text: MS0442 },
        notFound: { text: MS0037 },
        noSelect: { text: MS0443 },
        noChange: { text: MS0038 },
        criteriaChange: { text: MS0048 },
        unloadWithoutSave: { text: MS0066 },
        unprintableCheck: {text: MS0560}
        // TODO: ここまで
    });

    App.ui.pagedata.validation("en", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        wt_shiyo_zan: {
            rules: {
                required: "rest of yesterday",
                range: [0, 999999.999],
                number: true
            },
            messages: {
                required: MS0042,
                range: MS0450,
                number: MS0441
            }
        },
        // 検索条件
        dt_hiduke_search: {
            rules: {
                required: "Date",
                datestring: true
            },
            messages: {
                required: MS0004,
                datestring: MS0247
            }
        }
        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("en", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
        search: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        colchange: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        excel: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        save: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        }
        // TODO: ここまで
    });

    //// ページデータ -- End
})();
