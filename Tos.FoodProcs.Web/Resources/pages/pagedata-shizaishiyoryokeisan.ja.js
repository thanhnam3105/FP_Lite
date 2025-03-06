(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("ja", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "資材使用量計算" },
        // 明細
        nm_bunrui: { text: "分類" },
        cd_hinmei: { text: "資材コード" },
        nm_hinmei: { text: "資材名" },
        nm_tani: { text: "使用単位" },
        nm_nisugata_hyoji: { text: "荷姿" },
        su_shiyo_sum: { text: "使用予定量" },
        wt_shiyo_zan: { text: "前日残" },
        qty_hitsuyo: { text: "必要量<br>（使用単位）" },
        qty_hitsuyoNonyu: { text: "必要量<br>（納入単位）" },
        qty_hitsuyoNonyuHasu: { text: "必要量端数<br>（納入単位）" },
        nm_torihiki_ryaku: { text: "購入先" },
        zan_hiduke: { text: "残日付" },
        dt_hiduke: { text: "登録日付" },
        // 検索条件
        dt_hiduke_search: { text: "日付" },
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

    App.ui.pagedata.validation("ja", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        wt_shiyo_zan: {
            rules: {
                required: "前日残",
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
                required: "日付",
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
    App.ui.pagedata.operation("ja", {
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
