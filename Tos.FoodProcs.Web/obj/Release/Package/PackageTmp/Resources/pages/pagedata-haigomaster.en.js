(function () {
    var lang = App.ui.pagedata.lang("en", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Formula Detail Master" },
        cd_bunrui: { text: "Group code" },
        nm_bunrui: { text: "Group name" },
        cd_haigo: { text: "Formula code*" },
        nm_haigo_ja: { text: "Formula name (ja)*" },
        nm_haigo_en: { text: "Formula name (en)*" },
        nm_haigo_zh: { text: "Formula name (zh)*" },
        nm_haigo_vi: { text: "Formula name (vi)*" },
        nm_haigo_ryaku: { text: "Short formula name" },
        ritsu_budomari: { text: "Yield*" },
        wt_kihon: { text: "Basic weight*" },
        kbn_kanzan: { text: "Convert unit" },
        ritsu_hiju: { text: "Gravity" },
        flg_gassan_shikomi: { text: "Total produce" },
        ritsu_kihon: { text: "Basic magnification*" },
        shikomi_gassan: { text: "Add up" },
        wt_saidai_shikomi: { text: "Max weight*" },
        flg_shorihin: { text: "Label for WIP" },
        flg_mishiyo: { text: "Unused" },
        mishiyo: { text: "Display unused" },
        ts: { text: "Time stamp" },
        lineSave: { text: "Register line" },
        no_han: { text: "Version" },
        dt_from: { text: "Term of validity" },
        notUse: { text: "When not usage" },
        dt_create: { text: "Registration date" },
        dt_update: { text: "Update date" },
        lineSave: { text: "Register line" },
        ma_haigo_mei: { text: "Formula name master" },
        ma_haigo_recipe: { text: "Formula recipe" },
        ma_seizo_line: { text: "Manufacture line master" },
        flg_tenkai: { text: "Auto Plan" },
        //dd_shomi: { text: "Expiry date" },
        //dd_shomi: { text: "Shelf life before opened" },
        dd_shomi: { text: "Expiration date" },
        kbn_hokan: { text: "Storage type" },
        labelDay: { text: "date" },
        lineOK: { text: "Exist" },
        //lineNG: { text: "None" },
        lineNG: { text: "Not Exist" },
        labelKg: { text: "Kg" },
        labelLB: { text: "LB" },
        labelL: { text: "L" },
        labelGAL: { text: "GAL" },
        msg_nm_haigo_ja: { text: "Formula name (ja)" },
        msg_nm_haigo_en: { text: "Formula name (en)" },
        msg_nm_haigo_zh: { text: "Formula name (zh)" },
        msg_nm_haigo_vi: { text: "Formula name (vi)" },
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

    App.ui.pagedata.validation("en", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        cd_haigo: {
            rules: {
                required: "Formula code",
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
                required: "Yield",
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
                required: "Basic weight",
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
                required: " Basic magnification",
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
                required: "Gravity",
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
                required: "Maximum weight of produce",
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
    App.ui.pagedata.operation("en", {
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
