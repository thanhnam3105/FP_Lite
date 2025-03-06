(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("zh", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "原材料购买商主表" },
        // 検索条件
        cd_hinmei: { text: "原材料编号" },
        nm_hinmei: { text: "原材料名　：" },
        // 明細
        no_juni_yusen: { text: "优先顺序" },
        cd_torihiki: { text: "厂商编号" },
        nm_torihiki: { text: "厂商名" },
        //nm_nisugata_hyoji: { text: "包装" },
        nm_nisugata_hyoji: { text: "包装形式" },
        tani_nonyu: { text: "入库单位" },
        cd_tani_nonyu: { text: "入库单位编号" },
        //tani_nonyu_hasu: { text: "入库单位(零数)" },
        tani_nonyu_hasu: { text: "入库单位(零头数)" },
        //cd_tani_nonyu_hasu: { text: "入库单位(零数)编号" },
        cd_tani_nonyu_hasu: { text: "入库单位(零头数)编号" },
        tan_nonyu: { text: "单价" },
        tan_nonyu_new: { text: "新单价" },
        dt_tanka_new: { text: "新单价切换日" },
        //su_hachu_lot_size: { text: "订货批量大小" },
        su_hachu_lot_size: { text: "订货批号大小" },
        wt_nonyu: { text: "一个数量（kg）" },
        su_iri: { text: "装箱数" },
        // su_leadtime: { text: "读取时间" },
        su_leadtime: { text: "周期" },
        cd_torihiki2: { text: "厂商编号2" },
        nm_torihiki2: { text: "厂商名2" },
        flg_mishiyo: { text: "未使用" },
        // 隠し項目
        ts: { text: "时间标记" },
        // ボタン名
        gramNyuryoku: { text: "克输入" },
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
        each_lang_width: { number: 100 }
        // TODO: ここまで
    });
    App.ui.pagedata.validation("zh", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        no_juni_yusen: {
            rules: {
                required: "优先顺序",
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
                required: "厂商编号",
                maxbytelength: 13,
                alphanum: true,
                custom: true
            },
            params: {
                custom: "厂商编号"
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
                required: "入库单位"
            },
            messages: {
                required: MS0042
            }
        },
        tan_nonyu: {
            rules: {
                required: "单价",
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
                datestring: "新单价切换日",
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
                required: "一个数量（Kg）",
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
        su_leadtime: {
            rules: {
               // required: "读取时间",
                required: "周期",
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
                custom: "厂商编号2"
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
                required: "原材料编号",
                maxbytelength: 14,
                alphanum: true
            },
            params: {
                custom: "原材料编号"
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
    App.ui.pagedata.operation("zh", {
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
