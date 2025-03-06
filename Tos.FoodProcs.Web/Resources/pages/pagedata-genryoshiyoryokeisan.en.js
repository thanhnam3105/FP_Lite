(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("en", {
        // 画面項目のテキスト
        //_pageTitle: { text: "Usage quantities of raw material calculation" },
        // 2014.11.10 名称変更：原料使用量計算→庫出依頼
        _pageTitle: { text: "Material Issue Order" },
        // 明細
        dt_shukko: { text: "Issue date" },
        cd_hinmei: { text: "Material code" },
        nm_hinmei: { text: "Material name" },
        nm_nisugata_hyoji: { text: "Packing style" },
        nm_tani: { text: "Usage unit" },
        su_shiyo_sum: { text: "Quantity of<br>usage plan" },
        wt_shiyo_zan: { text: "Inventory of<br>yesterday" },
        qty_hitsuyo: { text: "Necessary<br>quantity" },
        su_kuradashi: { text: "Inventory out<br>request number" },
        su_kuradashi_sum: { text: "Issue Order" },
        su_kuradashi_su: { text: "Quantity" },
        su_kuradashi_hasu: { text: "Partial" },
        flg_kakutei: { text: "Confirm" },
        kbn_status: { text: "Status" },
        nm_bunrui: { text: "Group" },
        dt_hiduke: { text: "Date" },
        shukkobi: { text: "Change issue date" },
        allCheck: { text: "All Check" },
        cd_tani_kuradashi: { text: "単位コード" },
        nm_tani_kuradashi: { text: "Issue unit" },

        // 旧項目
        qty_hitsuyoNonyu: { text: "Required quantities<br>（delivery unit）" },
        qty_hitsuyoNonyuHasu: { text: "Partial of Required quantities<br>（delivery unit）" },
        nm_torihiki_ryaku: { text: "Maker name" },
        zan_hiduke: { text: "Inventory date" },

        // 検索条件
        dt_hiduke_search: { text: "Date" },
        kbn_hin_search: { text: "Item type" },
        nm_jikagenryo: { text: "Original of finished goods" },

        // 項目の幅
        flg_kakutei_width: { number: 100 },
        each_lang_width: { number: 100 },

        // 画面メッセージ
        searchConfirm: { text: MS0065 },
        saveConfirm: { text: MS0064 },
        clearConfirm: { text: MS0070 },
        noRecords: { text: MS0442 },
        notFound: { text: MS0037 },
        noSelect: { text: MS0443 },
        noChange: { text: MS0444 },
        criteriaChange: { text: MS0048 },
        unloadWithoutSave: { text: MS0066 },
        unprintableCheck: { text: MS0560 },
        limitOver: { text: MS0011 }
    });

    App.ui.pagedata.validation("en", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        wt_shiyo_zan: {
            rules: {
                required: "Rest of yesterday",
                range: [0, 999999.999],
                number: true
            },
            messages: {
                required: MS0042,
                range: MS0450,
                number: MS0441
            }
        },
        su_kuradashi: {
            rules: {
                range: [0, 9999999],
                number: true
            },
            messages: {
                range: MS0450,
                number: MS0441
            }
        },
        su_kuradashi_hasu: {
            rules: {
                range: [0, 9999999],
                number: true
            },
            messages: {
                range: MS0450,
                number: MS0441
            }
        },
        dt_shukko: {
            rules: {
                required: "Issue date",
                datestring: true
            },
            messages: {
                required: MS0042,
                datestring: MS0247
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
        },
        // 検索条件
        dt_shukko_henko: {
            rules: {
                datestring: true
            },
            messages: {
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
