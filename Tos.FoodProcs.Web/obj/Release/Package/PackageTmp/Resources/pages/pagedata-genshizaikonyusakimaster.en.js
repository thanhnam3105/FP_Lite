(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("en", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Source List" },
        // 検索条件
        cd_hinmei: { text: "Material code" },
        nm_hinmei: { text: "Material name ：" },
        // 明細
        no_juni_yusen: { text: "Order of<br>priority" },
        cd_torihiki: { text: "Code" },
        nm_torihiki: { text: "Name" },
        nm_nisugata_hyoji: { text: "Packing style" },
        tani_nonyu: { text: "Delivery unit" },
        cd_tani_nonyu: { text: "Delivery unit code" },
        tani_nonyu_hasu: { text: "Delivery unit(Partial)" },
        cd_tani_nonyu_hasu: { text: "Delivery unit code(Partial)" },
        tan_nonyu: { text: "Unit price" },
        tan_nonyu_new: { text: "New unit price" },
        dt_tanka_new: { text: "Change date for<br>new unit price" },
        su_hachu_lot_size: { text: "Order lot size" },
        wt_nonyu: { text: "Quantity of one<br>product(kg)" },
        su_iri: { text: "Contained number" },
        su_leadtime: { text: "Lead time" },
        cd_torihiki2: { text: "Vendor code2" },
        nm_torihiki2: { text: "Vendor name2" },
        flg_mishiyo: { text: "Unused" },
        // 隠し項目
        ts: { text: "Time stamp" },
        // ボタン名
        gramNyuryoku: { text: "Gram input" },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        saveConfirm: { text: MS0064 },
        searchConfirm: { text: MS0065 },
        excelChangeMeisai: { text: MS0560 },
        notFound: { text: MS0037 },
        noRecords: { text: MS0442 },
        noSelect: { text: MS0443 },
        noChange: { text: MS0444 },
        addRecordMax: { text: MS0052 },
        unloadWithoutSave: { text: MS0066 },
        changeCondition: { text: MS0299 },
        limitOver: { text: MS0624 },
        searchBefore: { text: MS0621 },
        compNewTanka: { text: MS0305 },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の列幅を変更してください。
        no_juni_yusen_width: { number: 70 },
        cd_torihiki_width: { number: 120 },
        nm_torihiki_width: { number: 200 },
        nm_nisugata_hyoji_width: { number: 100 },
        tani_nonyu_width: { number: 120 },
        tan_nonyu_width: { number: 120 },
        tan_nonyu_new_width: { number: 120 },
        dt_tanka_new_width: { number: 110 },
        su_hachu_lot_size_width: { number: 130 },
        wt_nonyu_width: { number: 130 },
        su_iri_width: { number: 80 },
        su_leadtime_width: { number: 100 },
        cd_torihiki2_width: { number: 120 },
        nm_torihiki2_width: { number: 200 },
        flg_mishiyo_width: { number: 70 },
        each_lang_width: { number: 160 }
        // TODO: ここまで
    });
    App.ui.pagedata.validation("en", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        no_juni_yusen: {
            rules: {
                required: "Order of priority",
                number: true,
                range: [1, 100],
                digits: [3]
            },
            messages: {
                required: MS0042,
                number: MS0441,
                range: MS0450,
                digits: MS0576
            }
        },
        cd_torihiki: {
            rules: {
                required: "Vendor code",
                maxbytelength: 13,
                alphanum: true,
                custom: true
            },
            params: {
                custom: "Vendor code"
            },
            messages: {
                required: MS0042,
                maxbytelength: MS0012,
                alphanum: MS0439,
                custom: MS0049
            }
        },
        nm_nisugata_hyoji: {
            rules: {
                maxbytelength: 50
            },
            messages: {
                maxbytelength: MS0012
            }
        },
        tani_nonyu: {
            rules: {
                required: "Delivery unit"
            },
            messages: {
                required: MS0042
            }
        },
        tan_nonyu: {
            rules: {
                required: "Unit price",
                number: true,
                range: [0, 99999999.9999],
                pointlength: [8, 4, false]
            },
            messages: {
                required: MS0042,
                number: MS0441,
                range: MS0450,
                pointlength: MS0440
            }
        },
        tan_nonyu_new: {
            rules: {
                number: true,
                range: [0, 99999999.9999],
                pointlength: [8, 4, false]
            },
            messages: {
                number: MS0441,
                range: MS0450,
                pointlength: MS0440
            }
        },
        dt_tanka_new: {
            rules: {
                datestring: "Change date for new unit price",
                lessdate: new Date(new Date().getFullYear(), new Date().getMonth(), new Date().getDate() - 1)
            },
            messages: {
                datestring: MS0247,
                lessdate: MS0306
            }
        },
        su_hachu_lot_size: {
            rules: {
                number: true,
                range: [0, 99999.99],
                pointlength: [5, 2, false]
            },
            messages: {
                number: MS0441,
                range: MS0450,
                pointlength: MS0440
            }
        },
        wt_nonyu: {
            rules: {
                required: "Quantity of one product(kg)",
                number: true,
                range: [0, 999999.999999],
                pointlength: [6, 6, false]
            },
            messages: {
                required: MS0042,
                number: MS0441,
                range: MS0450,
                pointlength: MS0440
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
        su_leadtime: {
            rules: {
                required: "Lead time",
                number: true,
                range: [0, 999],
                digits: [3]
            },
            messages: {
                required: MS0042,
                number: MS0441,
                range: MS0450,
                digits: MS0576
            }
        },
        cd_torihiki2: {
            rules: {
                maxbytelength: 13,
                alphanum: true
            },
            params: {
                custom: "Vendor code2"
            },
            messages: {
                maxbytelength: MS0012,
                alphanum: MS0439,
                custom: MS0049
            }
        },
        // 検索条件
        cd_hinmei: {
            rules: {
                required: "Raw materials & packing materials code",
                maxbytelength: 14,
                alphanum: true
            },
            params: {
                custom: "Raw materials & packing materials code"
            },
            messages: {
                required: MS0042,
                maxbytelength: MS0012,
                alphanum: MS0439,
                custom: MS0049
            }
        }
        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("en", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
        search: {
            NotRole: { visible: false }
        },
        colchange: {
            NotRole: { visible: false }
        },
        add: {
            NotRole: { visible: false },
            isRoleFisrt: { visible: false }
        },
        del: {
            NotRole: { visible: false },
            isRoleFisrt: { visible: false }
        },
        torihikiIchiran: {
            NotRole: { visible: false },
            isRoleFisrt: { visible: false }
        },
        gram: {
            NotRole: { visible: false },
            isRoleFisrt: { visible: false }
        },
        save: {
            NotRole: { visible: false },
            isRoleFisrt: { visible: false }
        },
        excel: {
            NotRole: { visible: false }
        }
        // TODO: ここまで
    });

    //// ページデータ -- End
})();
