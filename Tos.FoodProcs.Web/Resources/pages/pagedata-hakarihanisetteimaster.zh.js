(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("zh", {
        // 画面項目
        _pageTitle: { text: "秤范围设定主表" },
        wt_hani_shiyo_kagen: { text: "秤量值（下）" },
        wt_hani_shiyo_jogen: { text: "秤量值（上）" },
        wt_hani_tekio_kagen: { text: "下限（ｇ）" },
        wt_hani_tekio_jogen: { text: "上限（ｇ）" },
        flg_mishiyo: { text: "未使用" },
        // 検索条件
        katashiki: { text: "形式" },
        // 注記
        notes: { text: "秤量上下限值的单位以（ｇ）输入" },
        // 隠し項目
        kbn_kasan_jyuryo: { text: "重量加法区分" },
        no_seq: { text: "序列号" },
        ts: { text: "时间标记" },
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
        // TODO: 画面の仕様に応じて以下の列幅を変更してください。
        wt_hani_shiyo_kagen_width: { number: 150 },
        wt_hani_shiyo_jogen_width: { number: 150 },
        wt_hani_tekio_kagen_width: { number: 130 },
        wt_hani_tekio_jogen_width: { number: 130 },
        flg_mishiyo_width: { number: 80 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("zh", {
        // バリデーションルールとバリデーションメッセージ
        wt_hani_shiyo_kagen: {
            rules: {
                //required: "秤量値(下)",
                number: true,
                pointlength: [6, 3, false],
                range: [0, 999999.999]
            },
            messages: {
                //required: MS0042,
                number: MS0441,
                pointlength: MS0440,
                range: MS0450,
                custom: MS0502
            }
        },
        wt_hani_shiyo_jogen: {
            rules: {
                //required: "秤量値(上)",
                number: true,
                pointlength: [6, 3, false],
                range: [0, 999999.999]
            },
            messages: {
                //required: MS0042,
                number: MS0441,
                pointlength: MS0440,
                range: MS0450,
                custom: MS0502
            }
        },
        wt_hani_tekio_kagen: {
            rules: {
                //required: "下限(ｇ)",
                number: true,
                pointlength: [6, 3, false],
                range: [0, 999999.999]
            },
            params: {
                custom: ["下限（ｇ）", "上限（ｇ）"]
            },
            messages: {
                //required: MS0042,
                number: MS0441,
                pointlength: MS0440,
                range: MS0450,
                custom: MS0500
            }
        },
        wt_hani_tekio_jogen: {
            rules: {
                //required: "上限(ｇ)",
                number: true,
                pointlength: [6, 3, false],
                range: [0, 999999.999]
            },
            params: {
                custom: ["下限（ｇ）", "上限（ｇ）"]
            },
            messages: {
                //required: MS0042,
                number: MS0441,
                pointlength: MS0440,
                range: MS0450,
                custom: MS0500
            }
        }
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("zh", {
        // 画面制御ルール(権限)
        add: {
            Viewer: { visible: false }
        },
        del: {
            Viewer: { visible: false }
        }
    });

    //// ページデータ -- End
})();
