(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("vi", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Master nhà cung cấp nguyên vật liệu" },
        // 検索条件
        cd_hinmei: { text: "Mã nguyên vật liệu" },
        nm_hinmei: { text: "Tên nguyên vật liệu：" },
        // 明細
        no_juni_yusen: { text: "Thứ tự ưu tiên" },
        cd_torihiki: { text: "Mã nhà cung cấp" },
        nm_torihiki: { text: "Tên nhà cung cấp" },
        nm_nisugata_hyoji: { text: "Quy cách đóng gói" },
        tani_nonyu: { text: "Đơn vị nhập" },
        cd_tani_nonyu: { text: "Mã đơn vị nhập" },
        tani_nonyu_hasu: { text: "Đơn vị nhập (lẻ)" },
        cd_tani_nonyu_hasu: { text: "Mã đơn vị nhập (lẻ)" },
        tan_nonyu: { text: "Đơn giá hiện tại" },
        tan_nonyu_new: { text: "Đơn giá mới" },
        dt_tanka_new: { text: "Ngày đổi đơn giá mới" },
        su_hachu_lot_size: { text: "Kích cỡ lô hàng đặt" },
        wt_nonyu: { text: "Trọng lượng 1 cái" },
        su_iri: { text: "Số lượng bên trong" },
        su_leadtime: { text: "Thời gian cung ứng" },
        cd_torihiki2: { text: "Mã nhà cung cấp 2" },
        nm_torihiki2: { text: "Tên nhà cung cấp 2" },
        flg_mishiyo: { text: "Không<br>sử dụng" },
        // 隠し項目
        ts: { text: "Timestamp" },
        // ボタン名
        gramNyuryoku: { text: "Nhập gram" },
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
        no_juni_yusen_width: { number: 100 },
        cd_torihiki_width: { number: 120 },
        nm_torihiki_width: { number: 200 },
        nm_nisugata_hyoji_width: { number: 120 },
        tani_nonyu_width: { number: 120 },
        tan_nonyu_width: { number: 120 },
        tan_nonyu_new_width: { number: 120 },
        dt_tanka_new_width: { number: 130 },
        su_hachu_lot_size_width: { number: 130 },
        wt_nonyu_width: { number: 130 },
        su_iri_width: { number: 125 },
        su_leadtime_width: { number: 130 },
        cd_torihiki2_width: { number: 120 },
        nm_torihiki2_width: { number: 200 },
        flg_mishiyo_width: { number: 70 },
        each_lang_width: { number: 160 }
        // TODO: ここまで
    });
    App.ui.pagedata.validation("vi", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        no_juni_yusen: {
            rules: {
                required: "Thứ tự ưu tiên",
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
                required: "Mã nhà cung cấp",
                maxbytelength: 13,
                alphanum: true,
                custom: true
            },
            params: {
                custom: "Mã nhà cung cấp"
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
                required: "Đơn vị nhập"
            },
            messages: {
                required: MS0042
            }
        },
        tan_nonyu: {
            rules: {
                required: "Đơn giá hiện tại",
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
                datestring: "Ngày đổi đơn giá mới",
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
                required: "Trọng lượng 1 cái",
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
                required: "Số lượng bên trong",
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
                required: "Thời gian cung ứng",
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
                custom: "Mã nhà cung cấp 2"
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
                required: "Mã nguyên vật liệu",
                maxbytelength: 14,
                alphanum: true
            },
            params: {
                custom: "Mã nguyên vật liệu"
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
    App.ui.pagedata.operation("vi", {
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