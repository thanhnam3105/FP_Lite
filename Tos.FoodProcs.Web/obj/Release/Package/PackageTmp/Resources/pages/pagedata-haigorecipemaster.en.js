(function () {
    var lang = App.ui.pagedata.lang("en", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Register Recipe Master" },
        cd_haigo: { text: "Code" },
        nm_haigo: { text: "Name" },
        haigoName: { text: "Formula" },
        haigoRecipe: { text: "formula recipe" },
        cd_bunrui: { text: "Group code" },
        nm_bunrui: { text: "Group name" },
        wt_kihon: { text: "Basic weight" },
        nm_han: { text: "Version" },
        no_kotei: { text: "Process" },
        nm_kotei: { text: "process" },
        nm_shinki_han: { text: "New version" },
        nm_shinki_kotei: { text: "New process" },
        notUse: { text: "When not usage" },
        flg_mishiyo: { text: "Unused" },
        no_seiho: { text: "Formula number" },
        biko: { text: "Notes" },
        dt_yuko: { text: "Valid start date" },
        //no_tonyu: { text: "Putting order" },
        //no_tonyu: { text: "Order" },
        no_tonyu: { text: "Recipe order" },
        kbn_hin: { text: "Item<br>type" },
        nm_kbn_hin: { text: "Item type" },
        cd_hinmei: { text: "Code" },
        nm_hinmei: { text: "Name" },
        cd_mark: { text: "Mark code" },
        mark: { text: "Mark" },
        wt_shikomi: { text: "Formula<br>weight" },
        cd_tani_shiyo: { text: "Usage unit<br>code" },
        nm_tani_shiyo: { text: "Usage<br>unit" },
        wt_nisugata: { text: "Packing style<br>weight" },
        su_nisugata: { text: "Number of<br>packing styles" },
        wt_kowake: { text: "Weighing<br>weight" },
        su_kowake: { text: "Number of<br>weighing" },
        flg_kowake_systemgai: { text: "Except<br>Weighing" },
        ritsu_budomari: { text: "Yield" },
        ritsu_hiju: { text: "Gravity" },
        su_settei: { text: "Setting<br>value" },
        su_settei_max: { text: "Maximum<br>value" },
        su_settei_min: { text: "Minimum<br>value" },
        cd_futai: { text: "Packing code" },
        nm_futai: { text: "Packing name" },
        nm_haigo_total: { text: "Formula weight" },
        qty_shiage: { text: "Total formula weight" },
        wt_chomieki: { text: "Weight" },
        maisu: { text: "Sheets No." },
        cd_tanto_koshin: { text: "PIC/update" },
        kbn_hinkan: { text: "Quality control" },
        //kbn_seizo: { text: "Manufacture" },
        kbn_seizo: { text: "Administrator" },
        nenn: { text: "Year" },
        tsuki: { text: "Month" },
        hi: { text: "date" },
        deleteHaigo: { text: "Delete formula" },
        up: { text: "Up" },
        down: { text: "Down" },
        ts: { text: "Time stamp" },
        cd_create: { text: "Registrant" },
        dt_create: { text: "Registration date" },
        cd_update: { text: "Updater" },
        dt_update: { text: "Update date" },
        no_seq: { text: "id" },

        // PLC項目
        no_plc_komoku: { text: "PLC" },
        nm_plc_komoku: { text: "PLC" },

        // 固定値
        tani_kg: { text: "Kg" },
        tani_LB: { text: "LB" },
        tani_mai: { text: "sheets" },
        haigo_total: { text: "The sum total of formula weight" },
        max_juryo: { number: 999999.999999 },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        con_recipe: { text: "Conditions of recipe" },
        changeRecipe: { text: "Change recipe" },
        createRecipe: { text: "New recipe" },
        totalQtyHaigo: { text: "Use total weight." },
        labelChomieki: { text: "Liquid seasoning label" },
        mishiyoError: { text: MS0678 },
        navigateErrorDetail: { text: MS0614 },
        navigateErrorPrint: { text: MS0705 },
        kowakejuryoError: { text: MS0771 },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の列幅を変更してください。
        no_kotei_width: { number: 70 },
        kbn_hin_width: { number: 75 },
        cd_hinmei_width: { number: 120 },
        nm_hinmei_width: { number: 200 },
        mark_width: { number: 40 },
        wt_shikomi_width: { number: 105 },
        nm_tani_shiyo_width: { number: 60 },
        wt_nisugata_width: { number: 105 },
        su_nisugata_width: { number: 120 },
        wt_kowake_width: { number: 100 },
        su_kowake_width: { number: 100 },
        flg_kowake_systemgai_width: { number: 110 },
        ritsu_budomari_width: { number: 45 },
        ritsu_hiju_width: { number: 60 },
        su_settei_width: { number: 70 },
        su_settei_max_width: { number: 70 },
        su_settei_min_width: { number: 70 },
        nm_futai_width: { number: 200 },
        each_lang_width: { number: 200 },
        // フッター項目の列幅
        qty_shiage_width: { number: 180 },
        totalQtyHaigo_width: { number: 210 },
        labelChomieki_width: { number: 150 },
        wt_chomieki_width: { number: 70 },
        maisu_width: { number: 70 },
        cd_tanto_koshin_width: { number: 90 },
        kbn_hinkan_width: { number: 110 },
        kbn_seizo_width: { number: 110 },
        replanConfirm: { text: MS0746 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("en", {
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
            rules: { required: "Item type" },
            messages: { required: MS0042 }
        },
        cd_hinmei: {
            rules: {
                required: "Item code",
                maxbytelength: 14
            },
            params: { custom: "Code" },
            messages: {
                required: MS0042,
                maxbytelength: MS0012,
                //custom: MS0049
                custom: MS0745
            }
        },
        nm_hinmei: {
            rules: {
                required: "Name",
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
            params: { custom: "Mark with formula" },
            messages: { custom: MS0049 }
        },
        wt_shikomi: {
            rules: {
                //required: "Formula weight",
                number: true,
                range: [0.000000, 999999.999999]
            },
            params: {
                custom: "Formula weight"
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
                required: "Yield",
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
                required: "Gravity",
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
                required: "Valid start date",
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
                custom: "Finishing weight"
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
    App.ui.pagedata.operation("en", {
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
