(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("vi", {
        // 画面項目
        _pageTitle: { text: "Master giá trị giới hạn của quả cân tiêu chuẩn" },
        cd_fundo: { text: "Mã" },
        wt_fundo: { text: "Trọng lượng quả cân tiêu chuẩn (g)" },
        wt_fundo_jogen: { text: "Giới hạn dưới (g)" },
        wt_fundo_kagen: { text: "Giới hạn trên (g)" },
        flg_mishiyo: { text: "Không <br>sử dụng" },
        // 隠し項目
        ts: { text: "Time_stamp" },
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

    App.ui.pagedata.validation("vi", {
        // バリデーションルールとバリデーションメッセージ
        cd_fundo: {
            rules: {
                required: "Mã",
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
                //required: "standard weight",
                number: true,
                pointlength: [6, 3, false],
                range: [0, 999999.999]
            },
            params: {
                custom: ["Giới hạn dưới", "Trọng lượng quả cân tiêu chuẩn"]
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
            //    custom: ["Minimum", "Maximum"]
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
                //required: "minimum",
                number: true,
                pointlength: [6, 3, false],
                range: [0, 999999.999]
            },
            params: {
                custom: ["Giới hạn dưới", "Trọng lượng quả cân tiêu chuẩn"]
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
    App.ui.pagedata.operation("vi", {
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