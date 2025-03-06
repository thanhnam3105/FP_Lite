(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("zh", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "材料使用量计算" },
        // 明細
        nm_bunrui: { text: "分类" },
        cd_hinmei: { text: "材料编号" },
        nm_hinmei: { text: "材料名" },
        nm_tani: { text: "使用单位" },
        nm_nisugata_hyoji: { text: "包装形式" },
        su_shiyo_sum: { text: "使用预定" },
        //wt_shiyo_zan: { text: "前一天剩余" },
        wt_shiyo_zan: { text: "前一天余量" },
        qty_hitsuyo: { text: "必要量<br>（使用单位）" },
        qty_hitsuyoNonyu: { text: "必要量<br>（入库单位）" },
       // qty_hitsuyoNonyuHasu: { text: "必要量零数<br>（入库单位）" },
        qty_hitsuyoNonyuHasu: { text: "必要量零头数<br>（入库单位）" },
        nm_torihiki_ryaku: { text: "购买商" },
        //zan_hiduke: { text: "剩余日期" },
        zan_hiduke: { text: "余量日期" },
        dt_hiduke: { text: "登录日期" },
        // 検索条件
        dt_hiduke_search: { text: "日期" },
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
        unprintableCheck: { text: MS0560 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("zh", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        wt_shiyo_zan: {
            rules: {
                //required: "前一天剩余",
                required: "前一天余量",
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
                required: "日期",
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
    App.ui.pagedata.operation("zh", {
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
