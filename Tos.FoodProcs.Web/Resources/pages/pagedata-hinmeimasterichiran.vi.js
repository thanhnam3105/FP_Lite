(function () {
    var lang = App.ui.pagedata.lang("vi", {
        _pageTitle: { text: "Master nguyên vật liệu" },
        mishiyo: { text: "Phạm vi hiển thị"},
        // ★共通の項目
        cd_hinmei: { text: "Mã" },
        nm_hinmei: { text: "Tên" },
        nm_hinmei_ja: { text: "Tên (ja)", tooltip: "Tên (Tiếng Nhật) "},
        nm_hinmei_en: { text: "Tên (en)", tooltip: "Tên (Tiếng Anh) " },
        nm_hinmei_vi: { text: "Tên (vi)", tooltip: "Tên (Tiếng Việt) " },
        nm_hinmei_zh: { text: "Tên (zh)", tooltip: "Tên (Tiếng Trung) "},
        nm_hinmei_ryaku: { text: "Tên (viết tắt)", tooltip: "Tên (viết tắt) "},
        kbn_hin: { text: "Loại" },
        nm_kbn_hin: { text: "Loại" },
        // nm_nisugata_hyoji: { text: "For display of<br>packing style" },
        nm_nisugata_hyoji: { text: "Quy cách đóng gói" },
        wt_nisugata_naiyo: { text: "Tổng trọng lượng", tooltip: "Tổng trọng lượng theo quy cách đóng gói"},
        su_iri: { text: "Số lượng bên trong"},
        wt_ko: { text: "Trọng lượng 1 cái"},
        kbn_kanzan: { text: "Đơn vị trọng lượng"},
        nm_kbn_kanzan: { text: "Đơn vị trọng lượng" },
        tani_nonyu: { text: "Đơn vị nhập" },
        cd_tani_nonyu: { text: "Đơn vị nhập" },
        tani_shiyo: { text: "Đơn vị<br>sử dụng" },
        cd_tani_shiyo: { text: "Đơn vị sử dụng" },
        ritsu_hiju: { text: "Tỉ trọng" },
        tan_ko: { text: "Đơn giá" },
        nm_bunrui: { text: "Phân loại nhóm" },
        cd_bunrui: { text: "Phân loại nhóm" },
        //dd_shomi: { text: "Number of <br>expiry date" },
        //dd_shomi: { text: "Shelf life <br>before opened" },
        dd_shomi: { text: "Hạn sử dụng" },
        //kikan_kaifumae_shomi_tani: { text: "Expiry date<br>(day)" },
        //kikan_kaifumae_shomi_tani: { text: "Shelf life <br>before opened(day)" },
        kikan_kaifumae_shomi_tani: { text: "Hạn sử dụng (ngày)" },
        //dd_kaifugo_shomi: { text: "Shelf life<br>after opened" },
        //dd_kaifugo_shomi: { text: "Expiry date<br>after opening" },
        dd_kaifugo_shomi: { text: "Hạn sử dụng sau khi mở",},
        //kikan_kaifugo_shomi_tani: { text: "Expiry date<br>after opened(day)" },
        //kikan_kaifugo_shomi_tani: { text: "Shelf life <br>after opened(day)" },
        kikan_kaifugo_shomi_tani: { text: "Hạn sử dụng sau khi mở<br>(ngày)" },
        dd_kaitogo_shomi: { text: "Hạn sử dụng sau khi<br>rã đông" },
        kikan_kaitogo_shomi_tani: { text: "Hạn sử dụng sau khi<br>rã đông(ngày)" },
        kbn_hokan: { text: "ĐK bảo quản", tooltip: "Điều kiện bảo quản" },
        nm_hokan: { text: "ĐK bảo quản" },
        //kbn_kaifugo_hokan: { text: "Storage type of<br>after breaking seal" },
        kbn_kaifugo_hokan: { text: "ĐK bảo quản sau khi mở", tooltip: "Điều kiện bảo quản sau khi mở" },
        //nm_kaifugo_hokan: { text: "Storage type of<br>after breaking seal" },
        nm_kaifugo_hokan: { text: "ĐK bảo quản sau khi mở" },
        kbn_kaitogo_hokan: { text: "ĐK bảo quản sau khi rã đông", tooltip: "Điều kiện bảo quản sau khi rã đông" },
        nm_kaitogo_hokan: { text: "ĐK bảo quản sau khi rã đông", tooltip: "Điều kiện bảo quản sau khi rã đông" },
        kbn_jotai: { text: "Trạng thái" },
        nm_kbn_jotai: { text: "Trạng thái" },
        kbn_zei: { text: "Loại thuế" },
        nm_zei: { text: "Loại thuế" },
        ritsu_budomari: { text: "Tỉ lệ<br>sử dụng" },
        su_zaiko_min: { text: "Tồn kho tối thiểu" },
        su_zaiko_max: { text: "Tồn kho tối đa" },
        nm_niuke: { text: "Nơi nhận hàng" },
        dd_leadtime: { text: "Thời gian cung ứng", tooltip: "Thời gian cung ứng" },
        biko: { text: "Ghi chú" },
        flg_mishiyo: { text: "Không<br>sử dụng" },
        cd_niuke_basho: { text: "Nơi nhận hàng" },
        cd_location: { text: "Vị trí" },
        dd_kotei: { text: "Fixed day" },
        flg_testitem: { text: "SP thử nghiệm" },
        flg_trace_taishogai: { text: "Không truy vết" },
        cd_tani_nonyu_hasu: { text: "Đơn vị nhập(lẻ)" },

        // ★製品・自家原の項目
        cd_hanbai_1: { text: "Mã bên bán 1" },
        nm_torihiki1: { text: "Bên bán 1" },
        cd_hanbai_2: { text: "Mã bên bán 2" },
        nm_torihiki2: { text: "Bên bán 2" },
        cd_haigo: { text: "Mã công thức" },
        nm_haigo: { text: "Tên công thức" },
        cd_jan: { text: "Mã JAN" },
        su_batch_dekidaka: { text: "Sản lượng của 1 mẻ SX" },
        su_palette: { text: "Thừa số pallet" },
        kin_romu: { text: "Chi phí lao động tiêu chuẩn" },
        kin_keihi_cs: { text: "Chi phí cho 1 C/S" },
        kbn_kuraire: { text: "Loại nhập kho" },
        nm_kbn_kuraire: { text: "Loại nhập kho" },
        tan_nonyu: { text: "Đơn giá nhập" },
        flg_tenkai: { text: "Loại triển khai" },
        line: { text: "Dây chuyền sản xuất" },

        // ★原料・資材の項目
        cd_seizo: { text: "Mã nhà SX" },
        nm_seizo: { text: "Tên nhà SX" },
        nm_torihiki: { text: "Tên nhà SX" },
        cd_maker_hin: { text: "Mã NVL tại nơi SX" },
        su_hachu_lot_size: { text: "Cỡ lô đặt hàng" },
        nm_kura: { text: "Tên kho" },
        cd_kura: { text: "Kho xuất" },
        dt_create: { text: "Ngày đăng ký" },
        dt_update: { text: "Ngày cập nhật" },
        notUse: { text: "TH không sử dụng", tooltip: "Trường hợp không sử dụng" },

        // その他、定数定義、固定文言、隠し項目など
        lineSearch: { text: "Đăng ký dây chuyền" },
        lineButton: { text: "Đăng ký dây chuyền" },
        //shizaiButton: { text: "Usage of packing material" },
        shizaiButton: { text: "Đăng ký sử dụng vật tư" },
        konyuButton: { text: "Đăng ký nhà cung cấp" },
        ts: { text: "Timestamp" },
        lineOK: { text: "Đã đăng ký" },
        lineNG: { text: "Chưa đăng ký" },
        labelTanka: { text: "Yên" },
        labelDay: { text: "Ngày" },
        labelEn: { text: "Yên" },
        labelCase: { text: "C/S" },
        labelPercent: { text: "％" },
        labelKg: { text: "Kg" },
        labelLB: { text: "LB" },
        labelL: { text: "L" },
        labelGAL: { text: "GAL" },
        labelTenkai: { text: "Triển khai" },
        shomiTaniMae: { text: "Ngày" },
        shomiTaniAto: { text: "Ngày" },
        cd_create: { text: "Người đăng ký" },
        cd_update: { text: "Người cập nhật" },
        each_lang_width: { text: "12em" },
        //不使用チェックボックス時
        each_fushiyo_width: { text: "11em" },
        unit_width: { text: "4em" },
        header_width: { text: "16em" },
        item_label_right_width: { text: "15em" },
        msg_nm_hinmei_ja: { text: "Tên (ja)" },
        msg_nm_hinmei_en: { text: "Tên (en)" },
        msg_nm_hinmei_zh: { text: "Tên (zh)" },
        msg_nm_hinmei_vi: { text: "Tên (vi)" },
        errorHinKbnParamLine: { text: "Lỗi đăng ký dây chuyền: " },
        errorHinKbnParamShiza: { text: "Lỗi đăng ký vật tư sử dụng: " },
        errorHinKbnParamKonyu: { text: "Lỗi đăng ký nhà cung cấp: " },
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
        su_iri_width: { number: 80 },
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
        dd_kaifugo_shomi_width: { number: 155 },
        //kikan_kaifugo_shomi_tani_width: { number: 140 },
        dd_kaitogo_shomi_width: { number: 145 },
        nm_hokan_width: { number: 150 },
        nm_kaifugo_hokan_width: { number: 170 },
        nm_kaitogo_hokan_width: { number: 200 },
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

    App.ui.pagedata.validation("vi", {
        //TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        cd_hinmei: {
            rules: {
                required: "Mã NVL",
                maxbytelength: 14,
                alphanum: true
            },
            params: {
                custom: "Mã NVL"
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
            rules: { required: "Loại" },
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
        wt_ko: {
            rules: {
                required: "Trọng lượng 1 cái",
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
                required: "Tỉ trọng",
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
            rules: { required: "Loại thuế" },
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
                custom: ["Tồn kho tối đa", "Tồn kho tối thiểu"]
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
                custom: ["Tồn kho tối đa", "Tồn kho tối thiểu"]
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
            rules: { required: "Nơi nhận hàng" },
            messages: { required: MS0042 }
        },
        cd_haigo: {
            rules: {
                required: "Mã công thức",
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
                required: "Loại nhập kho"
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

    App.ui.pagedata.validation2("vi", {
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
    App.ui.pagedata.operation("vi", {
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