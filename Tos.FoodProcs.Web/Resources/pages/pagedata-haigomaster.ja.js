(function () {
    var lang = App.ui.pagedata.lang("ja", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "配合名マスタ詳細" },
        cd_bunrui: { text: "仕掛品分類コード" },
        nm_bunrui: { text: "仕掛品分類" },
        cd_haigo: { text: "配合コード*" },
        nm_haigo_ja: { text: "配合名(日本語)*" },
        nm_haigo_en: { text: "配合名(英語)*" },
        nm_haigo_zh: { text: "配合名(中国語)*" },
        nm_haigo_vi: { text: "配合名(vi)*"},
        nm_haigo_ryaku: { text: "配合名略" },
        ritsu_budomari: { text: "歩留*" },
        wt_kihon: { text: "基本重量*" },
        kbn_kanzan: { text: "換算区分" },
        ritsu_hiju: { text: "比重*" },
        flg_gassan_shikomi: { text: "仕込合算" },
        ritsu_kihon: { text: "基本倍率*" },
        shikomi_gassan: { text: "仕込合算あり" },
        wt_saidai_shikomi: { text: "仕込最大重量*" },
        flg_shorihin: { text: "調味液" },  // (2014.09.03)処理品 → 調味液
        flg_mishiyo: { text: "未使用" },
        mishiyo: { text: "未使用表示" },
        ts: { text: "タイムスタンプ" },
        lineSave: { text: "ライン登録" },
        no_han: { text: "版" },
        dt_from: { text: "有効期間" },
        notUse: { text: "使用しない場合" },
        dt_create: { text: "登録日" },
        dt_update: { text: "更新日" },
        lineSave: { text: "ライン登録" },
        ma_haigo_mei: { text: "配合名マスタに" },
        ma_haigo_recipe: { text: "配合レシピに" },
        ma_seizo_line: { text: "製造ラインマスタに" },
        flg_tenkai: { text: "自動立案する" },
        dd_shomi: { text: "賞味期間" },
        kbn_hokan: { text: "保管区分" },
        labelDay: { text: "日" },
        lineOK: { text: "あり" },
        lineNG: { text: "なし" },
        labelKg: { text: "Kg" },
        labelLB: { text: "LB" },
        labelL: { text: "L" },
        labelGAL: { text: "GAL" },
        msg_nm_haigo_ja: { text: "配合名(日本語)" },
        msg_nm_haigo_en: { text: "配合名(英語)" },
        msg_nm_haigo_zh: { text: "配合名(中国語)" },
        msg_nm_haigo_vi: { text: "配合名 (vi)" },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        notFound: { text: MS0037 },
        requiredInput: { text: MS0042 },
        noRecords: { text: MS0442 },
        noSelect: { text: MS0443 },
        unloadWithoutSave: { text: MS0066 },
        clearConfirm: { text: MS0070 },
        navigateConfirm: { text: MS0076 },
        navigateError: { text: MS0623 },
        chomiCheck: { text: MS0732 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("ja", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        cd_haigo: {
            rules: {
                required: "配合コード",
                maxbytelength: 14,
                alphanum: true
            },
            messages: {
                required: MS0042,
                maxbytelength: MS0012,
                alphanum: MS0439
            }
        },
        nm_haigo_ja: {
            rules: {
                illegalchara: true,
                maxbytelength: 50
            },
            messages: {
                illegalchara: MS0005,
                maxbytelength: MS0012,
                custom: MS0451
            }
        },
        nm_haigo_en: {
            rules: {
                illegalchara: true,
                maxbytelength: 50
            },
            messages: {
                illegalchara: MS0005,
                maxbytelength: MS0012,
                custom: MS0451
            }
        },
        nm_haigo_zh: {
            rules: {
                illegalchara: true,
                maxbytelength: 50
            },
            messages: {
                illegalchara: MS0005,
                maxbytelength: MS0012,
                custom: MS0451
            }
        },
        nm_haigo_vi: {
            rules: {
                illegalchara: true,
                maxbytelength: 50
            },
            messages: {
                illegalchara: MS0005,
                maxbytelength: MS0012,
                custom: MS0451
            }
        },
        nm_haigo_ryaku: {
            rules: {
                illegalchara: true,
                maxbytelength: 50
            },
            messages: {
                illegalchara: MS0005,
                maxbytelength: MS0012
            }
        },
        ritsu_budomari: {
            rules: {
                required: "歩留",
                number: true,
                range: [0.01, 999.99],
                pointlength: [3, 2, false]
            },
            messages: {
                required: MS0042,
                number: MS0441,
                range: MS0450,
                pointlength: MS0440
            }
        },
        wt_kihon: {
            rules: {
                required: "基本重量",
                number: true,
                range: [1, 9999],
                digits: [4]
            },
            messages: {
                required: MS0042,
                number: MS0441,
                range: MS0450,
                digits: MS0576
            }
        },
        ritsu_kihon: {
            rules: {
                required: "基本倍率",
                number: true,
                range: [0.01, 999.99],
                pointlength: [3, 2, false]
            },
            messages: {
                required: MS0042,
                number: MS0441,
                range: MS0450,
                pointlength: MS0440
            }
        },
        ritsu_hiju: {
            rules: {
                required: "比重",
                number: true,
                range: [0.0001, 99.9999],
                pointlength: [2, 4, false]
            },
            messages: {
                required: MS0042,
                number: MS0441,
                range: MS0450,
                pointlength: MS0440
            }
        },
        wt_saidai_shikomi: {
            rules: {
                required: "仕込最大重量",
                number: true,
                range: [0.000001, 999999.999999],
                pointlength: [6, 6, false]
            },
            messages: {
                required: MS0042,
                number: MS0441,
                range: MS0450,
                pointlength: MS0440
            }
        },
        dd_shomi: {
            rules: {
                number: true,
                digits: [4],
                range: [0, 9999]
            },
            messages: {
                number: MS0441,
                digits: MS0576,
                range: MS0450
            }
        }
        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("ja", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
        save: {
            NotRole: { visible: false },
            isRoleFisrt: { visible: false }
        },
        lineSave: {
            NotRole: { visible: false }
        },
        recipe: {
            NotRole: { visible: false }
        },
        clear: {
            NotRole: { visible: false }
        }
        // TODO: ここまで
    });
})();
