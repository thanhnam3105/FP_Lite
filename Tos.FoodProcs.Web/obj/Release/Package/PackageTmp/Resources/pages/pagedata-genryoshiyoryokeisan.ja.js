(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("ja", {
        // 画面項目のテキスト
        //_pageTitle: { text: "原料使用量計算" },
        // 2014.11.10 名称変更：原料使用量計算→庫出依頼
        _pageTitle: { text: "庫出依頼" },
        // 明細
        dt_shukko: { text: "出庫日" },
        cd_hinmei: { text: "原資材コード" },
        nm_hinmei: { text: "原資材名" },
        nm_nisugata_hyoji: { text: "荷姿" },
        nm_tani: { text: "使用単位" },
        su_shiyo_sum: { text: "使用予定量" },
        wt_shiyo_zan: { text: "前日残" },
        qty_hitsuyo: { text: "必要量" },
        su_kuradashi: { text: "庫出依頼数" },
        su_kuradashi_sum: { text: "庫出依頼" },
        su_kuradashi_su: { text: "数" },
        su_kuradashi_hasu: { text: "端数" },
        flg_kakutei: { text: "確定" },
        kbn_status: { text: "ステータス" },
        nm_bunrui: { text: "分類" },
        dt_hiduke: { text: "日付" },
        shukkobi: { text: "出庫日変更" },
        allCheck: { text: "全チェック" },
        cd_tani_kuradashi: { text: "単位コード" },
        nm_tani_kuradashi: { text: "庫出単位" },

        // 旧項目
        qty_hitsuyoNonyu: { text: "必要量<br>（納入単位）" },
        qty_hitsuyoNonyuHasu: { text: "必要量端数<br>（納入単位）" },
        nm_torihiki_ryaku: { text: "購入先" },
        zan_hiduke: { text: "残日付" },

        // 検索条件
        dt_hiduke_search: { text: "日付" },
        kbn_hin_search: { text: "品区分" },
        nm_jikagenryo: { text: "自家原料" },

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
                required: "出庫日",
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
                required: "日付",
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
