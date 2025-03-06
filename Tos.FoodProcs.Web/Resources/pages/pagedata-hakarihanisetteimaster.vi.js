(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("vi", {
        // 画面項目
        _pageTitle: { text: "Master thiết lập phạm vi cân" },
        wt_hani_shiyo_kagen: { text: "Trọng lượng cân <br>(Giới hạn dưới)" },
        wt_hani_shiyo_jogen: { text: "Trọng lượng cân <br>(Giới hạn trên)" },
        wt_hani_tekio_kagen: { text: "Giới hạn dưới (g)" },
        wt_hani_tekio_jogen: { text: "Giới hạn trên (g)" },
        flg_mishiyo: { text: "Không <br>sử dụng" },
        // 検索条件
        katashiki: { text: "Định dạng" },
        // 注記
        notes: { text: "Input a minimum and maximum weighing value with gram." },
        // 隠し項目
        kbn_kasan_jyuryo: { text: "Loại phép cộng trọng lượng" },
        no_seq: { text: "Số thứ tự" },
        ts: { text: "Timestamp" },
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
        wt_hani_shiyo_kagen_width: { number: 180 },
        wt_hani_shiyo_jogen_width: { number: 180 },
        wt_hani_tekio_kagen_width: { number: 130 },
        wt_hani_tekio_jogen_width: { number: 130 },
        flg_mishiyo_width: { number: 80 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("vi", {
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
                custom: ["Giới hạn dưới (g)", "giới hạn trên (g)"]
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
                custom: ["Giới hạn dưới (g)", "giới hạn trên (g)"]
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