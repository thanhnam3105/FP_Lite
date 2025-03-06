(function () {
    var lang = App.ui.pagedata.lang("zh", {
        _pageTitle: { text: "品名主表" },
        mishiyo: { text: "未使用显示" },
        // ★共通の項目
        cd_hinmei: { text: "编号" },
        nm_hinmei: { text: "品名" },
        nm_hinmei_ja: { text: "品名(日语)" },
        nm_hinmei_en: { text: "品名(英语)" },
        nm_hinmei_zh: { text: "品名(汉语)" },
        nm_hinmei_vi: { text: "品名(vi)" },
        nm_hinmei_ryaku: { text: "品名简称" },
        kbn_hin: { text: "商品区分" },
        nm_kbn_hin: { text: "商品区分" },
        nm_nisugata_hyoji: { text: "显示包装形式用" },
        wt_nisugata_naiyo: { text: "包装容量" },
        su_iri: { text: "装箱数" },
        wt_ko: { text: "单个数量" },
        kbn_kanzan: { text: "单个数量单位" },
        nm_kbn_kanzan: { text: "单个数量单位" },
        tani_nonyu: { text: "入库单位" },
        cd_tani_nonyu: { text: "入库单位" },
        tani_shiyo: { text: "使用单位" },
        cd_tani_shiyo: { text: "使用单位" },
        ritsu_hiju: { text: "比重" },
        tan_ko: { text: "单价" },
        nm_bunrui: { text: "分类" },
        cd_bunrui: { text: "分类" },
        dd_shomi: { text: "保质期" },
        kikan_kaifumae_shomi_tani: { text: "保质期(天)" },
        dd_kaifugo_shomi: { text: "开封后保质期" },
        kikan_kaifugo_shomi_tani: { text: "开放后保质期(天)" },
        dd_kaitogo_shomi: { text: "解冻后保质期" },
        kikan_kaitogo_shomi_tani: { text: "解冻后保质期(天)" },
        kbn_hokan: { text: "保管区分" },
        nm_hokan: { text: "保管区分" },
        kbn_kaifugo_hokan: { text: "开封后保管区分" },
        nm_kaifugo_hokan: { text: "开封后保管区分" },
        kbn_kaitogo_hokan: { text: "解冻后保管区分" },
        nm_kaitogo_hokan: { text: "解冻后保管区分" },
        kbn_jotai: { text: "状态区分" },
        nm_kbn_jotai: { text: "状态区分" },
        kbn_zei: { text: "税区分" },
        nm_zei: { text: "税区分" },
        ritsu_budomari: { text: "原料利用率" },
        su_zaiko_min: { text: "最小库存" },
        su_zaiko_max: { text: "最大库存" },
        //nm_niuke: { text: "荷受場所" },
        //nm_niuke: { text: "领货地点" },
        nm_niuke: { text: "入库地点" },
        dd_leadtime: { text: "入库期" },
        biko: { text: "备注" },
        flg_mishiyo: { text: "未使用" },
        //cd_niuke_basho: { text: "领货地点" },
        cd_niuke_basho: { text: "入库地点" },
        cd_location: { text: "地点" },
        dd_kotei: { text: "固定日" },
        // flg_testitem: { text: "考试品名" },
        flg_testitem: { text: "测试品" },
        flg_trace_taishogai: { text: "追溯对象外" },
        //cd_tani_nonyu_hasu: { text: "入库单位(零数)" },
        cd_tani_nonyu_hasu: { text: "入库单位(零头数)" },

        // ★製品・自家原の項目
        cd_hanbai_1: { text: "销售商编号１" },
        nm_torihiki1: { text: "销售商１" },
        cd_hanbai_2: { text: "销售商编号２" },
        nm_torihiki2: { text: "销售商２" },
        cd_haigo: { text: "配料编号" },
        nm_haigo: { text: "配料名" },
        cd_jan: { text: "JAN编码" },
        su_batch_dekidaka: { text: "批次总产" },
        su_palette: { text: "栈板倍数" },
        kin_romu: { text: "标准劳务费" },
        kin_keihi_cs: { text: "１Ｃ／Ｓ经费" },
        kbn_kuraire: { text: "入库区分" },
        nm_kbn_kuraire: { text: "入库区分" },
        tan_nonyu: { text: "入库单价" },
        flg_tenkai: { text: "展开区分" },
        line: { text: "生产线登录" },

        // ★原料・資材の項目
        cd_seizo: { text: "制造商编号" },
        nm_seizo: { text: "制造商名" },
        nm_torihiki: { text: "制造商名" },
        cd_maker_hin: { text: "制造产品编号" },
        //su_hachu_lot_size: { text: "订货批量大小" },
        su_hachu_lot_size: { text: "订货批号大小" },
        nm_kura: { text: "仓库地点名" },
        cd_kura: { text: "仓库地点" },
        dt_create: { text: "登录日" },
        dt_update: { text: "更新日" },
        notUse: { text: "不使用时" },

        // その他、定数定義、固定文言、隠し項目など
        lineSearch: { text: "生产线登录" },
        lineButton: { text: "生产线登录" },
        shizaiButton: { text: "材料使用" },
        konyuButton: { text: "原材料购买商" },
        ts: { text: "时间标记" },
        lineOK: { text: "有" },
        lineNG: { text: "无" },
        labelTanka: { text: "日円" },
        labelDay: { text: "天" },
        labelEn: { text: "天" },
        labelCase: { text: "C/S" },
        labelPercent: { text: "％" },
        labelKg: { text: "Kg" },
        labelLB: { text: "LB" },
        labelL: { text: "L" },
        labelGAL: { text: "GAL" },
        labelTenkai: { text: "展开" },
        shomiTaniMae: { text: "天" },
        shomiTaniAto: { text: "天" },
        cd_create: { text: "登录者" },
        cd_update: { text: "更新者" },
        each_lang_width: { text: "8em" },
        //不使用チェックボックス時
        each_fushiyo_width: { text: "4em" },
        unit_width: { text: "30px" },
        header_width: { text: "60%" },
        item_label_right_width: { text: "8em" },
        msg_nm_hinmei_ja: { text: "品名(日语)" },
        msg_nm_hinmei_en: { text: "品名(英语)" },
        msg_nm_hinmei_zh: { text: "品名(汉语)" },
        msg_nm_hinmei_vi: { text: "品名(vi)" },
        errorHinKbnParamLine: { text: "生产线登录错误：已登录" },
        errorHinKbnParamShiza: { text: "材料使用错误：已登录" },
        errorHinKbnParamKonyu: { text: "原材料购买商错误：已登录" },
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

    App.ui.pagedata.validation("zh", {
        //TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        cd_hinmei: {
            rules: {
                required: "品编号",
                maxbytelength: 14,
                alphanum: true
            },
            params: {
                custom: "品编号"
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
                required: "装箱数",
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
                required: "单个数量",
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
        kbn_kaitogo_hokan_detail: {
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
                custom: ["最大库存", "最小库存"]
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
                custom: ["最大库存", "最小库存"]
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
            rules: { required: "入库地点" },
            messages: { required: MS0042 }
        },
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
        required: "入库区分"
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

    App.ui.pagedata.validation2("zh", {
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
    App.ui.pagedata.operation("zh", {
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
