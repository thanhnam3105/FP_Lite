(function () {
    var lang = App.ui.pagedata.lang("zh", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "配料名主表详细" },
        cd_bunrui: { text: "半成品分类编号" },
        nm_bunrui: { text: "半成品分类" },
        cd_haigo: { text: "配料编号*" },
        nm_haigo_ja: { text: "配料名(日语)*" },
        nm_haigo_en: { text: "配料名(英语)*" },
        nm_haigo_zh: { text: "配料名(汉语)*" },
        nm_haigo_vi: { text: "配料名(vi)*"},
        nm_haigo_ryaku: { text: "配料名简称" },
        ritsu_budomari: { text: "原料利用率*" },
        wt_kihon: { text: "基本重量*" },
        kbn_kanzan: { text: "换算区分" },
        ritsu_hiju: { text: "比重*" },
        flg_gassan_shikomi: { text: "投放合计" },
        ritsu_kihon: { text: "基本倍率*" },
        shikomi_gassan: { text: "有投放合计" },
        wt_saidai_shikomi: { text: "投放最大重量*" },
        flg_shorihin: { text: "调味液" },  // (2014.09.03)処理品 → 調味液
        flg_mishiyo: { text: "未使用" },
        mishiyo: { text: "未使用显示" },
        ts: { text: "时间标记" },
        lineSave: { text: "生产线登录" },
        no_han: { text: "版本" },
        dt_from: { text: "有效期间" },
        notUse: { text: "不使用时" },
        dt_create: { text: "登录日" },
        dt_update: { text: "更新日" },
        lineSave: { text: "生产线登录" },
        ma_haigo_mei: { text: "在配料注表中" },
        ma_haigo_recipe: { text: "在配料明细中" },
        ma_seizo_line: { text: "在生产线主表中" },
        flg_tenkai: { text: "进行自动设计" },
        dd_shomi: { text: "保质期" },
        kbn_hokan: { text: "保管区分" },
        labelDay: { text: "天" },
        lineOK: { text: "有" },
        lineNG: { text: "无" },
        labelKg: { text: "Kg" },
        labelLB: { text: "LB" },
        labelL: { text: "L" },
        labelGAL: { text: "GAL" },
        msg_nm_haigo_ja: { text: "配料名(日语)" },
        msg_nm_haigo_en: { text: "配料名(英语)" },
        msg_nm_haigo_zh: { text: "配料名(汉语)" },
        msg_nm_haigo_vi: { text: "配料名 (vi)" },
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

    App.ui.pagedata.validation("zh", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        cd_haigo: {
            rules: {
                required: "配料编号",
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
                required: "原料利用率",
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
                required: "投放最大重量",
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
    App.ui.pagedata.operation("zh", {
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
