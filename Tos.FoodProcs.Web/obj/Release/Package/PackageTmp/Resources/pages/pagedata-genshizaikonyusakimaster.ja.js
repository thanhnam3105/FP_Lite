(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("ja", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "原資材購入先マスタ" },
        // 検索条件
        cd_hinmei: { text: "原資材コード" },
        nm_hinmei: { text: "原資材名　：" },
        // 明細
        no_juni_yusen: { text: "優先順位" },
        cd_torihiki: { text: "取引先コード" },
        nm_torihiki: { text: "取引先名" },
        nm_nisugata_hyoji: { text: "荷姿" },
        tani_nonyu: { text: "納入単位" },
        cd_tani_nonyu: { text: "納入単位コード" },
        tani_nonyu_hasu: { text: "納入単位(端数)" },
        cd_tani_nonyu_hasu: { text: "納入単位(端数)コード" },
        tan_nonyu: { text: "現単価" },
        tan_nonyu_new: { text: "新単価" },
        dt_tanka_new: { text: "新単価切替日" },
        su_hachu_lot_size: { text: "発注ロットサイズ" },
        wt_nonyu: { text: "一個の量（kg）" },
        su_iri: { text: "入数" },
        su_leadtime: { text: "リードタイム" },
        cd_torihiki2: { text: "取引先コード2" },
        nm_torihiki2: { text: "取引先名2" },
        flg_mishiyo: { text: "未使用" },
        // 隠し項目
        ts: { text: "タイムスタンプ" },
        // ボタン名
        gramNyuryoku: { text: "グラム入力" },
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
    App.ui.pagedata.validation("ja", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        no_juni_yusen: {
            rules: {
                required: "優先順位",
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
                required: "取引先コード",
                maxbytelength: 13,
                alphanum: true,
                custom: true
            },
            params: {
                custom: "取引先コード"
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
                required: "納入単位"
            },
            messages: {
                required: MS0042
            }
        },
        tan_nonyu: {
            rules: {
                required: "現単価",
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
                datestring: "新単価切替日",
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
                required: "一個の量（Kg）",
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
        su_leadtime: {
            rules: {
                required: "リードタイム",
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
                custom: "取引先コード2"
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
                required: "原資材コード",
                maxbytelength: 14,
                alphanum: true
            },
            params: {
                custom: "原資材コード"
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
    App.ui.pagedata.operation("ja", {
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
