(function () {
    var lang = App.ui.pagedata.lang("en", {
        _pageTitle: { text: "Material Master" },
        mishiyo: { text: "Display unused" },
        // ★共通の項目
        cd_hinmei: { text: "Item code" },
        nm_hinmei: { text: "Item name" },
        nm_hinmei_ja: { text: "Item name (ja)" },
        nm_hinmei_en: { text: "Item name (en)" },
        nm_hinmei_zh: { text: "Item name (zh)" },
        nm_hinmei_vi: { text: "Item name (vi)" },
        nm_hinmei_ryaku: { text: "Short name" },
        kbn_hin: { text: "Item type" },
        nm_kbn_hin: { text: "Item type" },
        // nm_nisugata_hyoji: { text: "For display of<br>packing style" },
        nm_nisugata_hyoji: { text: "Packing style" },
        wt_nisugata_naiyo: { text: "Contained quantities of packing style" },
        su_iri: { text: "Contained number" },
        wt_ko: { text: "Unit quantity" },
        kbn_kanzan: { text: "Conversion unit" },
        nm_kbn_kanzan: { text: "Conversion unit" },
        tani_nonyu: { text: "Delivery unit" },
        cd_tani_nonyu: { text: "Delivery unit" },
        tani_shiyo: { text: "Usage unit" },
        cd_tani_shiyo: { text: "Usage unit" },
        ritsu_hiju: { text: "Gravity" },
        tan_ko: { text: "Unit price" },
        nm_bunrui: { text: "Group" },
        cd_bunrui: { text: "Group" },
        //dd_shomi: { text: "Number of <br>expiry date" },
        //dd_shomi: { text: "Shelf life <br>before opened" },
        dd_shomi: { text: "Expiration date" },
        //kikan_kaifumae_shomi_tani: { text: "Expiry date<br>(day)" },
        //kikan_kaifumae_shomi_tani: { text: "Shelf life <br>before opened(day)" },
        kikan_kaifumae_shomi_tani: { text: "Expiration date<br>(day)" },
        //dd_kaifugo_shomi: { text: "Shelf life<br>after opened" },
        //dd_kaifugo_shomi: { text: "Expiry date<br>after opening" },
        dd_kaifugo_shomi: { text: "Expiration date<br>after opening" },
        //kikan_kaifugo_shomi_tani: { text: "Expiry date<br>after opened(day)" },
        //kikan_kaifugo_shomi_tani: { text: "Shelf life <br>after opened(day)" },
        kikan_kaifugo_shomi_tani: { text: "Expiration date<br>after opening(day)" },
        dd_kaitogo_shomi: { text: "Expiration date<br>after thawing" },
        kikan_kaitogo_shomi_tani: { text: "Expiration date<br>after thawing(day)" },
        kbn_hokan: { text: "Storage type" },
        nm_hokan: { text: "Storage type" },
        //kbn_kaifugo_hokan: { text: "Storage type of<br>after breaking seal" },
        kbn_kaifugo_hokan: { text: "Storage type<br>after opening" },
        //nm_kaifugo_hokan: { text: "Storage type of<br>after breaking seal" },
        nm_kaifugo_hokan: { text: "Storage type<br>after opening" },
        kbn_kaitogo_hokan: { text: "Storage type<br>after thawing" },
        nm_kaitogo_hokan: { text: "Storage type<br>after thawing" },
        kbn_jotai: { text: "Condition<br>type" },
        nm_kbn_jotai: { text: "Condition<br>type" },
        kbn_zei: { text: "Tax type" },
        nm_zei: { text: "Tax<br>type" },
        ritsu_budomari: { text: "Yield" },
        su_zaiko_min: { text: "Minimum<br>inventory" },
        su_zaiko_max: { text: "Maximum<br>inventory" },
        nm_niuke: { text: "Receipt location" },
        dd_leadtime: { text: "Delivery lead time" },
        biko: { text: "Notes" },
        flg_mishiyo: { text: "Unused" },
        cd_niuke_basho: { text: "Receipt location" },
        cd_location: { text: "Location" },
        dd_kotei: { text: "Fixed day" },
        flg_testitem: { text: "Test item" },
        flg_trace_taishogai: { text: "No lot tracking" },
        cd_tani_nonyu_hasu: { text: "Delivery unit(Partial)" },

        // ★製品・自家原の項目
        cd_hanbai_1: { text: "Sales contact code1" },
        nm_torihiki1: { text: "Sales contact1" },
        cd_hanbai_2: { text: "Sales contact code2" },
        nm_torihiki2: { text: "Sales contact2" },
        cd_haigo: { text: "Formula<br>code" },
        nm_haigo: { text: "Formula name" },
        cd_jan: { text: "JAN-code" },
        su_batch_dekidaka: { text: "Output number<br>of one batch" },
        su_palette: { text: "Palette<br>multiplier" },
        kin_romu: { text: "Basic labor<br>cost" },
        kin_keihi_cs: { text: "Cost of 1 C/S" },
        kbn_kuraire: { text: "Warehouse<br>type" },
        nm_kbn_kuraire: { text: "Warehousing<br>type" },
        tan_nonyu: { text: "Delivery unit<br>price" },
        flg_tenkai: { text: "Develop<br>type" },
        line: { text: "Register line" },

        // ★原料・資材の項目
        cd_seizo: { text: "Maker code" },
        nm_seizo: { text: "Maker name" },
        nm_torihiki: { text: "Maker name" },
        cd_maker_hin: { text: "Item code of maker" },
        su_hachu_lot_size: { text: "Purchase lot size" },
        nm_kura: { text: "Issued location name" },
        cd_kura: { text: "Issued location" },
        dt_create: { text: "Registration date" },
        dt_update: { text: "Update date" },
        notUse: { text: "When not usage" },

        // その他、定数定義、固定文言、隠し項目など
        lineSearch: { text: "Register line" },
        lineButton: { text: "Register line" },
        //shizaiButton: { text: "Usage of packing material" },
        shizaiButton: { text: "Packaging BOM Master" },
        konyuButton: { text: "Source List" },
        ts: { text: "Time stamp" },
        lineOK: { text: "Exist" },
        lineNG: { text: "None" },
        labelTanka: { text: "Dollar" },
        labelDay: { text: "Date" },
        labelEn: { text: "Dollar" },
        labelCase: { text: "C/S" },
        labelPercent: { text: "%" },
        labelKg: { text: "Kg" },
        labelLB: { text: "LB" },
        labelL: { text: "L" },
        labelGAL: { text: "GAL" },
        labelTenkai: { text: "Develop" },
        shomiTaniMae: { text: "Date" },
        shomiTaniAto: { text: "Date" },
        cd_create: { text: "Registrant" },
        cd_update: { text: "Updater" },
        each_lang_width: { text: "12em" },
        //不使用チェックボックス時
        each_fushiyo_width: { text: "8em" },
        unit_width: { text: "4em" },
        header_width: { text: "16em" },
        item_label_right_width: { text: "10em" },
        msg_nm_hinmei_ja: { text: "Item name (ja)" },
        msg_nm_hinmei_en: { text: "Item name (en)" },
        msg_nm_hinmei_zh: { text: "Item name (zh)" },
        msg_nm_hinmei_vi: { text: "Item name (vi)" },
        errorHinKbnParamLine: { text: "Register line error: Already registered" },
        errorHinKbnParamShiza: { text: "Packing materials usage error: Already registered" },
        errorHinKbnParamKonyu: { text: "Raw & packing materials vendor error：Already registered" },
        pdfChangeMeisai: { text: MS0048 },
        lineTorokuHinCdError: { text: MS0573 },
        lineTorokuHinKbnError: { text: MS0022 },
        requiredMsg: { text: MS0042 },
        inputValueError: { text: MS0009 },
        navigateError: { text: MS0623 },
        inputGreater: { text: MS0618 },
        OverlapHaigoCode: { text: MS0777 },
        // TODO: 画面の仕様に応じて以下の列幅を変更してください。
        cd_hinmei_width: { number: 110 },
        nm_hinmei_width: { number: 200 },
        nm_hinmei_ryaku_width: { number: 180 },
        nm_kbn_hin_width: { number: 100 },
        nm_nisugata_hyoji_width: { number: 120 },
        wt_nisugata_naiyo_width: { number: 130 },
        su_iri_width: { number: 60 },
        wt_ko_width: { number: 110 },
        nm_kbn_kanzan_width: { number: 115 },
        tani_nonyu_width: { number: 90 },
        tani_shiyo_width: { number: 90 },
        ritsu_hiju_width: { number: 80 },
        tan_ko_width: { number: 110 },
        nm_bunrui_width: { number: 200 },
        //dd_shomi_width: { number: 100 },
        dd_shomi_width: { number: 135 },
        //kikan_kaifumae_shomi_tani_width: { number: 100 },
        dd_kaifugo_shomi_width: { number: 145 },
        //kikan_kaifugo_shomi_tani_width: { number: 140 },
        dd_kaitogo_shomi_width: { number: 145 },
        nm_hokan_width: { number: 150 },
        nm_kaifugo_hokan_width: { number: 150 },
        nm_kaitogo_hokan_width: { number: 150 },
        nm_kbn_jotai_width: { number: 80 },
        nm_zei_width: { number: 70 },
        ritsu_budomari_width: { number: 70 },
        su_zaiko_min_width: { number: 130 },
        su_zaiko_max_width: { number: 130 },
        nm_niuke_width: { number: 200 },
        dd_leadtime_width: { number: 130 },
        flg_mishiyo_width: { number: 70 },
        nm_torihiki1_width: { number: 200 },
        nm_torihiki2_width: { number: 200 },
        cd_haigo_width: { number: 120 },
        nm_haigo_width: { number: 200 },
        cd_jan_width: { number: 105 },
        su_batch_dekidaka_width: { number: 100 },
        su_palette_width: { number: 100 },
        kin_romu_width: { number: 115 },
        kin_keihi_cs_width: { number: 115 },
        nm_kbn_kuraire_width: { number: 100 },
        tan_nonyu_width: { number: 120 },
        flg_tenkai_width: { number: 80 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("en", {
        //TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        cd_hinmei: {
            rules: {
                required: "Item code",
                maxbytelength: 14,
                alphanum: true
            },
            params: {
                custom: "Item code"
            },
            messages: {
                required: MS0042,
                maxbytelength: MS0012,
                alphanum: MS0439,
                custom: MS0045
            }
        },
        nm_hinmei_ja: {
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
        nm_hinmei_en: {
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
        nm_hinmei_zh: {
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
        nm_hinmei_vi: {
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
        nm_hinmei_ryaku: {
            rules: {
                illegalchara: true,
                maxbytelength: 50
            },
            messages: {
                illegalchara: MS0005,
                maxbytelength: MS0012
            }
        },
        kbn_hin: {
            rules: { required: "Item type" },
            messages: { required: MS0042 }
        },
        nm_nisugata_hyoji: {
            rules: {
                illegalchara: true,
                maxbytelength: 50
            },
            messages: {
                illegalchara: MS0005,
                maxbytelength: MS0012
            }
        },
        wt_nisugata_naiyo: {
            rules: {
                number: true,
                pointlength: [6, 6, false],
                range: [0, 999999.999999]
            },
            messages: {
                number: MS0441,
                pointlength: MS0440,
                range: MS0450
            }
        },
        su_iri: {
            rules: {
                required: "Number contained",
                number: true,
                range: [0, 99999],
                digits: [5]
            },
            messages: {
                required: MS0042,
                number: MS0441,
                range: MS0450,
                digits: MS0576
            }
        },
        wt_ko: {
            rules: {
                required: "Quantity of one product",
                number: true,
                pointlength: [6, 6, false],
                range: [0, 999999.999999]
            },
            messages: {
                required: MS0042,
                number: MS0441,
                pointlength: MS0440,
                range: MS0450
            }
        },
        ritsu_hiju: {
            rules: {
                required: "Gravity",
                number: true,
                pointlength: [2, 4, false],
                range: [0, 99.9999]
            },
            messages: {
                required: MS0042,
                number: MS0441,
                pointlength: MS0440,
                range: MS0450
            }
        },
        tan_ko: {
            rules: {
                number: true,
                pointlength: [8, 4, false],
                range: [0, 99999999.9999]
            },
            messages: {
                number: MS0441,
                pointlength: MS0440,
                range: MS0450
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
        },
        dd_kaifugo_shomi: {
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
        },
        dd_kaitogo_shomi: {
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
        },
        kbn_hokan_detail: {
            rules: {
            },
            messages: {
            }
        },
        kbn_kaifugo_hokan_detail: {
            rules: {
            },
            messages: {
            }
        },
        /*
        kbn_zei: {
            rules: { required: "Tax type" },
            messages: { required: MS0042 }
        },
        */
        ritsu_budomari: {
            rules: {
                number: true,
                pointlength: [3, 2, false],
                range: [0, 999.99]
            },
            messages: {
                number: MS0441,
                pointlength: MS0440,
                range: MS0450
            }
        },
        su_zaiko_min: {
            rules: {
                number: true,
                pointlength: [8, 6, false],
                range: [0, 99999999.999999]
            },
            params: {
                custom: ["Maximum inventory", "Minimum inventory"]
            },
            messages: {
                number: MS0441,
                pointlength: MS0440,
                range: MS0450,
                custom: MS0618
            }
        },
        su_zaiko_max: {
            rules: {
                number: true,
                pointlength: [8, 6, false],
                range: [0, 99999999.999999]
            },
            params: {
                custom: ["Maximum inventory", "Minimum inventory"]
            },
            messages: {
                number: MS0441,
                pointlength: MS0440,
                range: MS0450,
                custom: MS0618
            }
        },
        dd_leadtime: {
            rules: {
                number: true,
                digits: [3],
                range: [0, 999]
            },
            messages: {
                number: MS0441,
                digits: MS0576,
                range: MS0450
            }
        },
        biko: {
            rules: {
                illegalchara: true,
                maxbytelength: 200
            },
            messages: {
                illegalchara: MS0005,
                maxbytelength: MS0012
            }
        },
        /*
        cd_hanbai_1: {
            rules: {
                maxbytelength: 13,
                alphanum: true
            },
            messages: {
                maxbytelength: MS0012,
                alphanum: MS0439
            }
        },
        */
        /*
        cd_hanbai_2: {
            rules: {
                maxbytelength: 13,
                alphanum: true
            },
            messages: {
                maxbytelength: MS0012,
                alphanum: MS0439
            }
        },
        */
        cd_niuke_basho: {
            rules: { required: "Receipt location" },
            messages: { required: MS0042 }
        },
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
        /*
        cd_jan: {
            rules: {
                number: true,
                digits: [13],
                range: [0, 9999999999999]
            },
            messages: {
                number: MS0441,
                digits: MS0576,
                range: MS0450
            }
        },
        */
        su_batch_dekidaka: {
            rules: {
                number: true,
                pointlength: [7, 2, false],
                range: [0, 9999999.99]
            },
            messages: {
                number: MS0441,
                pointlength: MS0440,
                range: MS0450
            }
        },
        /*
        su_palette: {
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
        },
        */
        kin_romu: {
            rules: {
                number: true,
                pointlength: [8, 4, false],
                range: [0, 99999999.9999]
            },
            messages: {
                number: MS0441,
                pointlength: MS0440,
                range: MS0450
            }
        },
        kin_keihi_cs: {
            rules: {
                number: true,
                pointlength: [8, 4, false],
                range: [0, 99999999.9999]
            },
            messages: {
                number: MS0441,
                pointlength: MS0440,
                range: MS0450
            }
        },
        /*
        kbn_kuraire: {
            rules: {
                required: "Warehousing type"
            },
            messages: {
                required: MS0042
            }
        },
        */
        tan_nonyu: {
            rules: {
                number: true,
                pointlength: [8, 4, false],
                range: [0, 99999999.9999]
            },
            messages: {
                number: MS0441,
                pointlength: MS0440,
                range: MS0450
            }
        },
        /*
        cd_seizo: {
            rules: {
                alphanum: true,
                maxbytelength: 13
            },
            messages: {
                alphanum: MS0439,
                maxbytelength: MS0012
            }
        },
        */
        /*
        cd_maker_hin: {
            rules: {
                alphanum: true,
                maxbytelength: 13
            },
            messages: {
                maxbytelength: MS0012
            }
        },
        */
        su_hachu_lot_size: {
            rules: {
                number: true,
                pointlength: [5, 2, false],
                range: [0, 99999.99]
            },
            messages: {
                number: MS0441,
                pointlength: MS0440,
                range: MS0450
            }
        },
        dd_kotei: {
            rules: {
                number: true,
                digits: [3],
                range: [0, 999]
            },
            messages: {
                number: MS0441,
                digits: MS0576,
                range: MS0450
            }
        }
        // TODO: ここまで
    });

    App.ui.pagedata.validation2("en", {
        //TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        nm_hinmei: {
            rules: {
                illegalchara: true,
                maxbytelength: 50
            },
            messages: {
                illegalchara: MS0005,
                maxbytelength: MS0012
            }
        }
        // TODO: ここまで
    });

    // 権限設定
    App.ui.pagedata.operation("en", {
        search: {
            NotRole: { visible: false }
        },
        colchange: {
            NotRole: { visible: false }
        },
        detail: {
            NotRole: { visible: false }
        },
        // 一覧
        add: {
            NotRole: { visible: false },
            isRoleFisrt: { visible: false }
        },
        copy: {
            NotRole: { visible: false },
            isRoleFisrt: { visible: false }
        },
        // 詳細
        save: {
            NotRole: { visible: false },
            isRoleFisrt: { visible: false }
        },
        del: {
            NotRole: { visible: false },
            isRoleFisrt: { visible: false }
        },
        clear: {
            NotRole: { visible: false }
        },
        print: {
            NotRole: { visible: false }
        },
        line: {
            NotRole: { visible: false }
        },
        torihiki1Button: {
            NotRole: { visible: false }
        },
        torihiki2Button: {
            NotRole: { visible: false }
        },
        seizoButton: {
            NotRole: { visible: false }
        },
        haigoButton: {
            NotRole: { visible: false }
        },
        lineButton: {
            NotRole: { visible: false }
        },
        konyuButton: {
            NotRole: { visible: false }
        },
        excel: {
            NotRole: { visible: false }
        }
    });

})();
