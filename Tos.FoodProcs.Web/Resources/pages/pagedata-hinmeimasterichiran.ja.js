(function () {
    var lang = App.ui.pagedata.lang("ja", {
        _pageTitle: { text: "品名マスタ" },
        mishiyo: { text: "未使用表示" },
        // ★共通の項目
        cd_hinmei: { text: "コード" },
        nm_hinmei: { text: "品名" },
        nm_hinmei_ja: { text: "品名(日本語)" },
        nm_hinmei_en: { text: "品名(英語)" },
        nm_hinmei_zh: { text: "品名(中国語)" },
        nm_hinmei_vi: { text: "品名 (vi)"},
        nm_hinmei_ryaku: { text: "品名略" },
        kbn_hin: { text: "品区分" },
        nm_kbn_hin: { text: "品区分" },
        nm_nisugata_hyoji: { text: "荷姿表示用" },
        wt_nisugata_naiyo: { text: "荷姿内容量" },
        su_iri: { text: "入数" },
        wt_ko: { text: "一個の量" },
        kbn_kanzan: { text: "一個の量の単位" },
        nm_kbn_kanzan: { text: "一個の量の単位" },
        tani_nonyu: { text: "納入単位" },
        cd_tani_nonyu: { text: "納入単位" },
        tani_shiyo: { text: "使用単位" },
        cd_tani_shiyo: { text: "使用単位" },
        ritsu_hiju: { text: "比重" },
        tan_ko: { text: "単価" },
        nm_bunrui: { text: "分類" },
        cd_bunrui: { text: "分類" },
        dd_shomi: { text: "賞味期間" },
        kikan_kaifumae_shomi_tani: { text: "賞味期間(日)" },
        dd_kaifugo_shomi: { text: "開封後賞味期間" },
        kikan_kaifugo_shomi_tani: { text: "開封後賞味期間(日)" },
        kbn_hokan: { text: "保管区分" },
        nm_hokan: { text: "保管区分" },
        kbn_kaifugo_hokan: { text: "開封後保管区分" },
        nm_kaifugo_hokan: { text: "開封後保管区分" },
        kbn_kaitogo_hokan: { text: "解凍後保管区分" },
        nm_kaitogo_hokan: { text: "解凍後保管区分" },
        kbn_jotai: { text: "状態区分" },
        nm_kbn_jotai: { text: "状態区分" },
        kbn_zei: { text: "税区分" },
        nm_zei: { text: "税区分" },
        ritsu_budomari: { text: "歩留" },
        su_zaiko_min: { text: "最低在庫" },
        su_zaiko_max: { text: "最大在庫" },
        nm_niuke: { text: "荷受場所" },
        dd_leadtime: { text: "納入リードタイム" },
        biko: { text: "備考" },
        flg_mishiyo: { text: "未使用" },
        cd_niuke_basho: { text: "荷受場所" },
        cd_location: { text: "ロケーション" },
        dd_kotei: { text: "固定日" },
        flg_testitem: { text: "テスト品" },
        flg_trace_taishogai: { text: "トレース対象外" },
        cd_tani_nonyu_hasu: { text: "納入単位(端数)" },
        dd_kaitogo_shomi: { text: "解凍後賞味期間" },
        kikan_kaitogo_shomi_tani: { text: "解凍後賞味期間(日)" },

        // ★製品・自家原の項目
        cd_hanbai_1: { text: "販売先コード１" },
        nm_torihiki1: { text: "販売先１" },
        cd_hanbai_2: { text: "販売先コード２" },
        nm_torihiki2: { text: "販売先２" },
        cd_haigo: { text: "配合コード" },
        nm_haigo: { text: "配合名" },
        cd_jan: { text: "JANコード" },
        su_batch_dekidaka: { text: "バッチ出来高" },
        su_palette: { text: "パレット乗数" },
        kin_romu: { text: "標準労務費" },
        kin_keihi_cs: { text: "１Ｃ／Ｓ経費" },
        kbn_kuraire: { text: "庫入区分" },
        nm_kbn_kuraire: { text: "庫入区分" },
        tan_nonyu: { text: "納入単価" },
        flg_tenkai: { text: "展開区分" },
        line: { text: "ライン登録" },

        // ★原料・資材の項目
        cd_seizo: { text: "製造元コード" },
        nm_seizo: { text: "製造元名" },
        nm_torihiki: { text: "製造元名" },
        cd_maker_hin: { text: "メーカー品コード" },
        su_hachu_lot_size: { text: "発注ロットサイズ" },
        nm_kura: { text: "庫場所名" },
        cd_kura: { text: "庫場所" },
        dt_create: { text: "登録日" },
        dt_update: { text: "更新日" },
        notUse: { text: "使用しない場合" },

        // その他、定数定義、固定文言、隠し項目など
        lineSearch: { text: "ライン登録" },
        lineButton: { text: "ライン登録" },
        shizaiButton: { text: "資材使用" },
        konyuButton: { text: "原資材購入先" },
        ts: { text: "タイムスタンプ" },
        lineOK: { text: "あり" },
        lineNG: { text: "なし" },
        labelTanka: { text: "円" },
        labelDay: { text: "日" },
        labelEn: { text: "円" },
        labelCase: { text: "C/S" },
        labelPercent: { text: "％" },
        labelKg: { text: "Kg" },
        labelLB: { text: "LB" },
        labelL: { text: "L" },
        labelGAL: { text: "GAL" },
        labelTenkai: { text: "展開する" },
        shomiTaniMae: { text: "日" },
        shomiTaniAto: { text: "日" },
        cd_create: { text: "登録者"},
        cd_update: { text: "更新者" },
        each_lang_width: { text: "8em" },
        //不使用チェックボックス時
        each_fushiyo_width: { text: "7em" },
        unit_width: { text: "30px" },
        header_width: { text: "60%" },
        item_label_right_width: { text: "8em" },
        msg_nm_hinmei_ja: { text: "品名(日本語)" },
        msg_nm_hinmei_en: { text: "品名(英語)" },
        msg_nm_hinmei_zh: { text: "品名(中国語)" },
        msg_nm_hinmei_vi: { text: "品名(vi)" },
        errorHinKbnParamLine: { text: "ライン登録エラー：登録されている" },
        errorHinKbnParamShiza: { text: "資材使用エラー：登録されている" },
        errorHinKbnParamKonyu: { text: "原資材購入先エラー：登録されている" },
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
        nm_hinmei_ryaku_width: { number: 120 },
        nm_kbn_hin_width: { number: 80 },
        nm_nisugata_hyoji_width: { number: 120 },
        wt_nisugata_naiyo_width: { number: 110 },
        su_iri_width: { number: 60 },
        wt_ko_width: { number: 110 },
        nm_kbn_kanzan_width: { number: 115 },
        tani_nonyu_width: { number: 90 },
        tani_shiyo_width: { number: 90 },
        ritsu_hiju_width: { number: 80 },
        tan_ko_width: { number: 110 },
        nm_bunrui_width: { number: 200 },
        dd_shomi_width: { number: 105 },
        dd_kaifugo_shomi_width: { number: 145 },
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

    App.ui.pagedata.validation("ja", {
        //TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        cd_hinmei: {
            rules: {
                required: "品コード",
                maxbytelength: 14,
                alphanum: true
            },
            params: {
                custom: "品コード"
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
            rules: { required: "品区分" },
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
                required: "入数",
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
                required: "一個の量",
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
                required: "比重",
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
            rules: { required: "税区分" },
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
                custom: ["最大在庫", "最低在庫"]
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
                custom: ["最大在庫", "最低在庫"]
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
        rules: { required: "荷受場所" },
        messages: { required: MS0042 }
        },
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
                required: "庫入区分"
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
                alphanum: MS0439,
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

    App.ui.pagedata.validation2("ja", {
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
    App.ui.pagedata.operation("ja", {
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
