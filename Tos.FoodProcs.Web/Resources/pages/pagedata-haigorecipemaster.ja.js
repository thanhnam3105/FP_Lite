(function () {
    var lang = App.ui.pagedata.lang("ja", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "配合レシピ登録" },
        cd_haigo: { text: "配合コード" },
        nm_haigo: { text: "配合名" },
        haigoName: { text: "配合" },
        haigoRecipe: { text: "配合レシピ" },
        cd_bunrui: { text: "仕掛品分類コード" },
        nm_bunrui: { text: "仕掛品分類" },
        wt_kihon: { text: "基本重量" },
        nm_han: { text: "版" },
        no_kotei: { text: "工程" },
        nm_kotei: { text: "工程" },
        nm_shinki_han: { text: "新規版" },
        nm_shinki_kotei: { text: "新規工程" },
        notUse: { text: "使用しない場合" },
        flg_mishiyo: { text: "未使用" },
        no_seiho: { text: "製法番号" },
        biko: { text: "備考" },
        dt_yuko: { text: "有効開始日付" },
        no_tonyu: { text: "投入順" },
        kbn_hin: { text: "品区分" },
        nm_kbn_hin: { text: "品区分" },
        cd_hinmei: { text: "コード" },
        nm_hinmei: { text: "原料名" },
        cd_mark: { text: "マークコード" },
        mark: { text: "マーク" },
        wt_shikomi: { text: "配合重量" },
        cd_tani_shiyo: { text: "使用単位コード" },
        nm_tani_shiyo: { text: "使用単位" },
        wt_nisugata: { text: "荷姿重量" },
        su_nisugata: { text: "荷姿数" },
        wt_kowake: { text: "小分重量" },
        su_kowake: { text: "小分数" },
        flg_kowake_systemgai: { text: "システム外小分" },
        ritsu_budomari: { text: "歩留" },
        ritsu_hiju: { text: "比重" },
        su_settei: { text: "設定値" },
        su_settei_max: { text: "最大値" },
        su_settei_min: { text: "最小値" },
        cd_futai: { text: "風袋コード" },
        nm_futai: { text: "風袋名" },
        nm_haigo_total: { text: "配合重量" },
        qty_shiage: { text: "仕上重量の決定" },
        wt_chomieki: { text: "重量" },
        maisu: { text: "枚数" },
        cd_tanto_koshin: { text: "担当者/更新日" },
        kbn_hinkan: { text: "品管" },
        kbn_seizo: { text: "製造" },
        nenn: { text: "年" },
        tsuki: { text: "月" },
        hi: { text: "日" },
        deleteHaigo: { text: "配合削除" },
        up: { text: "↑" },
        down: { text: "↓" },
        ts: { text: "タイムスタンプ" },
        cd_create: { text: "登録者" },
        dt_create: { text: "登録日" },
        cd_update: { text: "更新者" },
        dt_update: { text: "更新日" },
        no_seq: { text: "id" },

        // PLC項目
        no_plc_komoku: { text: "運転登録" },
        nm_plc_komoku: { text: "運転登録" },

        // 固定値
        tani_kg: { text: "Kg" },
        tani_LB: { text: "LB" },
        tani_mai: { text: "枚" },
        haigo_total: { text: "配合重量の合計" },
        max_juryo: { number: 999999.999999 },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        con_recipe: { text: "レシピ状態" },
        changeRecipe: { text: "レシピ変更" },
        createRecipe: { text: "新規レシピ" },
        totalQtyHaigo: { text: "配合重量の合計とする。" },
        labelChomieki: { text: "調味液ラベル" },
        mishiyoError: { text: MS0678 },
        navigateErrorDetail: { text: MS0614 },
        navigateErrorPrint: { text: MS0705 },
        kowakejuryoError: { text: MS0771 },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の列幅を変更してください。
        no_kotei_width: { number: 35 },
        kbn_hin_width: { number: 75 },
        cd_hinmei_width: { number: 120 },
        nm_hinmei_width: { number: 200 },
        mark_width: { number: 40 },
        wt_shikomi_width: { number: 105 },
        nm_tani_shiyo_width: { number: 60 },
        wt_nisugata_width: { number: 105 },
        su_nisugata_width: { number: 40 },
        wt_kowake_width: { number: 105 },
        su_kowake_width: { number: 40 },
        flg_kowake_systemgai_width: { number: 95 },
        ritsu_budomari_width: { number: 45 },
        ritsu_hiju_width: { number: 60 },
        su_settei_width: { number: 70 },
        su_settei_max_width: { number: 70 },
        su_settei_min_width: { number: 70 },
        nm_futai_width: { number: 200 },
        each_lang_width: { number: 120 },
        // フッター項目の列幅
        qty_shiage_width: { number: 100 },
        totalQtyHaigo_width: { number: 150 },
        labelChomieki_width: { number: 80 },
        wt_chomieki_width: { number: 30 },
        maisu_width: { number: 30 },
        cd_tanto_koshin_width: { number: 90 },
        kbn_hinkan_width: { number: 30 },
        kbn_seizo_width: { number: 30 },
        replanConfirm: { text: MS0746 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("ja", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        no_seiho: {
            rules: { maxbytelength: 20 },
            messages: { maxbytelength: MS0012 }
        },
        biko: {
            rules: { maxbytelength: 200 },
            messages: { maxbytelength: MS0012 }
        },
        kbn_hin: {
            rules: { required: "品区分" },
            messages: { required: MS0042 }
        },
        cd_hinmei: {
            rules: {
                required: "品コード",
                maxbytelength: 14
            },
            params: { custom: "コード" },
            messages: {
                required: MS0042,
                maxbytelength: MS0012,
                //custom: MS0049
                custom: MS0745
            }
        },
        nm_hinmei: {
            rules: {
                required: "原料名",
                maxbytelength: 50,
                illegalchara: true
            },
            messages: {
                required: MS0042,
                maxbytelength: MS0012,
                illegalchara: MS0005
            }
        },
        mark: {
            rules: {},
            params: { custom: "組み合わせでのマーク" },
            messages: { custom: MS0049 }
        },
        wt_shikomi: {
            rules: {
                //required: "配合重量",
                number: true,
                range: [0.000000, 999999.999999]
            },
            params: {
                custom: "配合重量"
            },
            messages: {
                //required: MS0042,
                number: MS0441,
                range: MS0450,
                custom: MS0042
            }
        },
        wt_nisugata: {
            rules: {
                number: true,
                range: [0.000000, 999999.999999]
            },
            messages: {
                number: MS0441,
                range: MS0450
            }
        },
        su_nisugata: {
            rules: {
                number: true,
                range: [0, 9999],
                pointlength: [4, 0, false]
            },
            messages: {
                number: MS0441,
                range: MS0450,
                pointlength: MS0440
            }
        },
        wt_kowake: {
            rules: {
                number: true,
                range: [0.000000, 999999.999999],
                pointlength: [6, 6, false]
            },
            messages: {
                number: MS0441,
                range: MS0450,
                pointlength: MS0440
            }
        },
        su_kowake: {
            rules: {
                number: true,
                range: [0, 9999],
                pointlength: [4, 0, false]
            },
            messages: {
                number: MS0441,
                range: MS0450,
                pointlength: MS0440
            }
        },
        ritsu_budomari: {
            rules: {
                required: "歩留",
                number: true,
                range: [0.00, 999.99]
            },
            messages: {
                required: MS0042,
                number: MS0441,
                range: MS0450
            }
        },
        ritsu_hiju: {
            rules: {
                required: "比重",
                number: true,
                range: [0.000, 99.999]
            },
            messages: {
                required: MS0042,
                number: MS0441,
                range: MS0450
            }
        },
        su_settei: {
            rules: {
                number: true,
                range: [0.000, 99999.999]
            },
            messages: {
                number: MS0441,
                range: MS0450
            }
        },
        su_settei_max: {
            rules: {
                number: true,
                range: [0.000, 99999.999]
            },
            messages: {
                number: MS0441,
                range: MS0450
            }
        },
        su_settei_min: {
            rules: {
                number: true,
                range: [0.000, 99999.999]
            },
            messages: {
                number: MS0441,
                range: MS0450
            }
        },
        dt_from: {
            rules: {
                required: "有効開始日付",
                datestring: true
            },
            messages: {
                required: MS0042,
                datestring: MS0247
            }
        },
        wt_haigo_gokei: {
            rules: {
                number: true,
                range: [0.000000, 999999.999999],
                pointlength: [6, 6, false]
            },
            params: {
                custom: "仕上重量"
            },
            messages: {
                number: MS0441,
                range: MS0450,
                custom: MS0042,
                pointlength: MS0440
            }
        }
        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("ja", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
        nm_shinki_han: {
            NotRole: { visible: false },
            isRoleFisrt: { visible: false }
        },
        nm_shinki_kotei: {
            NotRole: { visible: false },
            isRoleFisrt: { visible: false }
        },
        search: {
            NotRole: { visible: false }
        },
        colchange: {
            NotRole: { visible: false },
            isRoleFisrt: { visible: false }
        },
        add: {
            NotRole: { visible: false },
            isRoleFisrt: { visible: false }
        },
        del: {
            NotRole: { visible: false },
            isRoleFisrt: { visible: false }
        },
        hinmeiIchiran: {
            NotRole: { visible: false },
            isRoleFisrt: { visible: false }
        },
        markIchiran: {
            NotRole: { visible: false },
            isRoleFisrt: { visible: false }
        },
        futaiIchiran: {
            NotRole: { visible: false },
            isRoleFisrt: { visible: false }
        },
        tanto_hinkan: {
            NotRole: { visible: false },
            isRoleFisrt: { visible: false }
        },
        tanto_seizo: {
            NotRole: { visible: false },
            isRoleFisrt: { visible: false }
        },
        save: {
            NotRole: { visible: false },
            isRoleFisrt: { visible: false }
        },
        print: {
            NotRole: { visible: false }
        },
        clear: {
            NotRole: { visible: false },
            isRoleFisrt: { visible: false }
        },
        deleteHaigo: {
            NotRole: { visible: false },
            isRoleFisrt: { visible: false }
        },
        up: {
            NotRole: { visible: false },
            isRoleFisrt: { visible: false }
        },
        down: {
            NotRole: { visible: false },
            isRoleFisrt: { visible: false }
        },
        detail: {
            NotRole: { visible: false }
        }
        // TODO: ここまで
    });
})();
