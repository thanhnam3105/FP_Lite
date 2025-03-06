(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("zh", {
        // 画面項目のテキスト
        //_pageTitle: { text: "原料使用量計算" },
        // 2014.11.10 名称変更：原料使用量計算→庫出依頼
        _pageTitle: { text: "出库委托" },
        // 明細
        //dt_shukko: { text: "出库日期" },
        dt_shukko: { text: "出库日" },
        cd_hinmei: { text: "原材料编号" },
        nm_hinmei: { text: "原材料名" },
        nm_nisugata_hyoji: { text: "包装形式" },
        nm_tani: { text: "使用单位" },
        su_shiyo_sum: { text: "使用预定数" },
        wt_shiyo_zan: { text: "前一天余量" },
        qty_hitsuyo: { text: "必要量" },
        su_kuradashi: { text: "出库委托数" },
        su_kuradashi_sum: { text: "出库委托" },
        su_kuradashi_su: { text: "数" },
        //su_kuradashi_hasu: { text: "零数" },
        su_kuradashi_hasu: { text: "零头数" },
        flg_kakutei: { text: "确定" },
        kbn_status: { text: "状态" },
        nm_bunrui: { text: "分类" },
        dt_hiduke: { text: "日期" },
        shukkobi: { text: "出库日期变更" },
        // allCheck: { text: "全部检查" },
        allCheck: { text: "全部确认" },
        cd_tani_kuradashi: { text: "单位编号" },
        nm_tani_kuradashi: { text: "出库单位" },

        // 旧項目
        qty_hitsuyoNonyu: { text: "必要量<br>（入库单位）" },
        //qty_hitsuyoNonyuHasu: { text: "必要量零数<br>（入库单位）" },
        qty_hitsuyoNonyuHasu: { text: "必要量零头数<br>（入库单位）" },
        nm_torihiki_ryaku: { text: "采购商" },
        //zan_hiduke: { text: "剩余日期" },
        zan_hiduke: { text: "余量日期" },

        // 検索条件
        dt_hiduke_search: { text: "日期" },
        //kbn_hin_search: { text: "品区分" },
        kbn_hin_search: { text: "商品区分" },
        nm_jikagenryo: { text: "自制原料" },

        // 項目の幅
        flg_kakutei_width: { number: 50 },
        each_lang_width: { number: 80 },

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
        unprintableCheck: {text: MS0560},
        limitOver: { text: MS0011 }
    });

    App.ui.pagedata.validation("zh", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        wt_shiyo_zan: {
            rules: {
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
                required: "出库日",
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
                required: "日期",
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
