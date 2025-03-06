(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("ja", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "原資材調整入力" },
        // 検索条件
        dt_chosei_hassei: { text: "調整発生日" },
        // 明細
        cd_hinmei: { text: "コード" },
        nm_hinmei: { text: "原資材名" },
        nm_kbn_hin: { text: "品区分" },
        nm_nisugata: { text: "荷姿" },
        tani_shiyo: { text: "使用単位" },
        su_chosei: { text: "調整数" },
        nm_riyu: { text: "調整理由" },
        biko: { text: "備考" },
        cd_seihin: { text: "製品コード" },
        nm_seihin: { text: "製品名" },
        cd_update: { text: "更新者コード" },
        nm_update: { text: "更新者" },
        dt_update: { text: "更新日付" },
        genka_busho: { text: "原価発生部署" },
        cd_soko: { text: "倉庫" },
        no_lot_seihin: { text: '製品ロット' },
        excelIkatsu: { text: "EXCEL(期間選択)" },
        // 隠し項目
        no_seq: { text: "シーケンス番号" },
        kbn_hin: { text: "品区分" },
        cd_riyu: { text: "理由コード" },
        flg_mishiyo: { text: "未使用フラグ(製品)" },
        anbun_no_seq:{ text:"使用予実按分シーケンス"},
        // 品名セレクタ呼び出し用
        //hinmeiDlgParam_seihin: { text: "4" },
        //hinmeiDlgParam_genshizai: { text: "6" },
        //hinmeiDlgParam_genryo: { text: "7" },
        //hinmeiDlgParam_shizai: { text: "8" },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        saveConfirm: { text: MS0064 },
        searchConfirm: { text: MS0065 },
        excelChangeMeisai: { text: MS0560 },
        notFound: { text: MS0037 },
        noRecords: { text: MS0442 },
        noSelect: { text: MS0443 },
        noChange: { text: MS0444 },
        unloadWithoutSave: { text: MS0066 },
        changeCondition: { text: MS0299 },
        limitOver: { text: MS0011 },
        notExistsData: { text: MS0037 },
        rangeOver: { text: MS0778 },
        noInputHinmeiCode: { text: MS0042 },
        noDisplayDialog: { text: MS0831 },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の列幅を変更してください。
        cd_hinmei_width: { number: 100 },
        nm_hinmei_width: { number: 150 },
        nm_kbn_hin_width: { number: 60 },
        nm_nisugata_width: { number: 80 },
        tani_shiyo_width: { number: 80 },
        su_chosei_width: { number: 100 },
        nm_riyu_width: { number: 130 },
        biko_width: { number: 150 },
        nm_genka_width: { number: 130 },
        nm_soko_width: { number: 130 },
        cd_seihin_width: { number: 100 },
        nm_seihin_width: { number: 150 },
        nm_update_width: { number: 100 },
        dt_update_width: { number: 80 }
        // TODO: ここまで
    });
    App.ui.pagedata.validation("ja", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        cd_hinmei: {
            rules: {
                required: "コード",
                maxbytelength: 14,
                alphanum: true
            },
            messages: {
                required: MS0042,
                maxbytelength: MS0012,
                alphanum: MS0439,
                custom: MS0160
            }
        },
        su_chosei: {
            rules: {
                required: "調整数",
                //      number: true,
                range: [-999999.999999, 999999.999999]
            },
            messages: {
                required: MS0042,
                //      number: MS0441,
                range: MS0009
            }
        },
        nm_riyu: {
            rules: {
                required: "調整理由"
            },
            messages: {
                required: MS0042
            }
        },
        biko: {
            rules: {
                maxbytelength: 50
            },
            messages: {
                maxbytelength: MS0012
            }
        },
        cd_seihin: {
            rules: {
                maxbytelength: 14,
                alphanum: true
            },
            messages: {
                maxbytelength: MS0012,
                alphanum: MS0439,
                custom: MS0160
            }
        },
        // 検索条件
        dt_chosei_hassei: {
            rules: {
                required: "調整発生日",
                datestring: true,
                lessdate: new Date(1970, 1 - 1, 1 - 1),
                greaterdate: new Date(new Date().getFullYear() + 1, new Date().getMonth(), new Date().getDate() + 1)
            },
            messages: {
                required: MS0004,
                datestring: MS0247,
                lessdate: MS0247,
                greaterdate: MS0247
            }
        },
        no_lot_seihin: {
            rules: {
            },
            messages: {
                custom: MS0037
            }
        }
        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("ja", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
        search: {
            Manufacture: { visible: true },
            Quality: { visible: true },
            Purchase: { visible: true },
            Warehouse: { visible: true }
        },
        colchange: {
            Manufacture: { visible: true },
            Quality: { visible: true },
            Purchase: { visible: true },
            Warehouse: { visible: true }
        },
        excel: {
            Manufacture: { visible: true },
            Quality: { visible: true },
            Purchase: { visible: true },
            Warehouse: { visible: true }
        },
        save: {
            Manufacture: { visible: true },
            Quality: { visible: false },
            Purchase: { visible: true },
            Warehouse: { visible: true }
        },
        add: {
            Manufacture: { visible: true },
            Quality: { visible: false },
            Purchase: { visible: true },
            Warehouse: { visible: true }
        },
        del: {
            Manufacture: { visible: true },
            Quality: { visible: false },
            Purchase: { visible: true },
            Warehouse: { visible: true }
        },
        hinmeiIchiran: {
            Manufacture: { visible: true },
            Quality: { visible: false },
            Purchase: { visible: true },
            Warehouse: { visible: true }
        },
        seihinIchiran: {
            Manufacture: { visible: true },
            Quality: { visible: false },
            Purchase: { visible: true },
            Warehouse: { visible: true }
        },
        shikakariZanIchiran: {
            Manufacture: { visible: true },
            Quality: { visible: false },
            Purchase: { visible: true },
            Warehouse: { visible: true }
        }
        // TODO: ここまで
    });

    //// ページデータ -- End
})();
