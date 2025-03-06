(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("zh", {
        // 画面項目
        _pageTitle: { text: "标准砝码上下限值主表" },
        cd_fundo: { text: "编号" },
        wt_fundo: { text: "标准砝码重量（ｇ）" },
        wt_fundo_jogen: { text: "下限（ｇ）" },
        wt_fundo_kagen: { text: "上限（ｇ）" },
        flg_mishiyo: { text: "未使用" },
        // 隠し項目
        ts: { text: "时间标记" },
        // 画面メッセージ
        saveConfirm: { text: MS0064 },
        errorSize: { text: MS0500 },
        noRecords: { text: MS0442 },
        notFound: { text: MS0037 },
        noSelect: { text: MS0443 },
        noChange: { text: MS0444 },
        unloadWithoutSave: { text: MS0066 },
        // TODO: 画面の仕様に応じて以下の列幅を変更してください。
        cd_fundo_width: { number: 100 },
        wt_fundo_width: { number: 150 },
        wt_fundo_kagen_width: { number: 130 },
        wt_fundo_jogen_width: { number: 130 },
        flg_mishiyo_width: { number: 70 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("zh", {
        // バリデーションルールとバリデーションメッセージ
        cd_fundo: {
            rules: {
                required: "编号",
                maxbytelength: 10,
                alphanum: true
            },
            messages: {
                required: MS0042,
                maxbytelength: MS0012,
                alphanum: MS0439
            }
        },
        wt_fundo: {
            rules: {
                //required: "標準分銅重量",
                number: true,
                pointlength: [6, 3, false],
                range: [0, 999999.999]
            },
            params: {
                custom: ["下限", "标准砝码重量"]
            },
            messages: {
                //required: MS0042,
                number: MS0441,
                pointlength: MS0440,
                range: MS0450,
                custom: MS0500
            }
        },
        wt_fundo_jogen: {
            rules: {
                //required: "上限",
                number: true,
                pointlength: [6, 3, false],
                range: [0, 999999.999]
            },
            //params: {
            //    custom: ["下限", "上限"]
            //},
            messages: {
                //required: MS0042,
                number: MS0441,
                pointlength: MS0440,
                range: MS0450
                //custom: MS0500
            }
        },
        wt_fundo_kagen: {
            rules: {
                //required: "下限",
                number: true,
                pointlength: [6, 3, false],
                range: [0, 999999.999]
            },
            params: {
                custom: ["下限", "标准砝码重量"]
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
