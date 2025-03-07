(function () {
    var lang = App.ui.pagedata.lang("vi", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Đăng ký chi tiết công thức" },
        cd_haigo: { text: "Mã công thức" },
        nm_haigo: { text: "Tên công thức" },
        haigoName: { text: "Công thức" },
        haigoRecipe: { text: "Chi tiết công thức" },
        cd_bunrui: { text: "Mã nhóm bán thành phẩm" },
        nm_bunrui: { text: "Phân loại nhóm" },
        wt_kihon: { text: "Trọng lượng cơ bản" },
        nm_han: { text: "Phiên bản" },
        no_kotei: { text: "Công đoạn" },
        nm_kotei: { text: "Công đoạn" },
        nm_shinki_han: { text: "Phiên bản mới" },
        nm_shinki_kotei: { text: "Công đoạn mới" },
        notUse: { text: "TH không sử dụng", tooltip: "Trường hợp không sử dụng"},
        flg_mishiyo: { text: "Không sử dụng" },
        no_seiho: { text: "Mã phương thức SX", tooltip: "Mã phương thức sản xuất"},
        biko: { text: "Ghi chú" },
        dt_yuko: { text: "Ngày bắt đầu hiệu lực" },
        //no_tonyu: { text: "Putting order" },
        //no_tonyu: { text: "Order" },
        no_tonyu: { text: "Thứ tự" },
        kbn_hin: { text: "Loại" },
        nm_kbn_hin: { text: "Loại" },
        cd_hinmei: { text: "Mã" },
        nm_hinmei: { text: "Tên" },
        cd_mark: { text: "Mã mác" },
        mark: { text: "Mác" },
        wt_shikomi: { text: "Trọng lượng công thức" },
        cd_tani_shiyo: { text: "Mã đơn vị sử dụng" },
        nm_tani_shiyo: { text: "Đơn vị sử dụng" },
        wt_nisugata: { text: "Trọng lượng đóng gói" },
        su_nisugata: { text: "Số lượng đóng gói" },
        wt_kowake: { text: "Trọng lượng chia nhỏ" },
        su_kowake: { text: "Số lượng chia nhỏ" },
        flg_kowake_systemgai: { text: "Chia nhỏ ngoài hệ thống" },
        ritsu_budomari: { text: "Tỉ lệ sử dụng" },
        ritsu_hiju: { text: "Tỉ trọng" },
        su_settei: { text: "Giá trị thiết lập" },
        su_settei_max: { text: "Tối đa" },
        su_settei_min: { text: "Tối thiểu" },
        cd_futai: { text: "Mã kiểu đóng gói" },
        nm_futai: { text: "Kiểu đóng gói" },
        nm_haigo_total: { text: "Trọng lượng công thức" },
        qty_shiage: { text: "Trọng lượng công thức 1 mẻ" },
        wt_chomieki: { text: "Trọng lượng" },
        maisu: { text: "Số tờ" },
        cd_tanto_koshin: { text: "Người phụ trách/ Ngày cập nhật" },
        kbn_hinkan: { text: "Quản lý chất lượng (QC)" },
        //kbn_seizo: { text: "Manufacture" },
        kbn_seizo: { text: "Quản lý sản xuất" },
        nenn: { text: "Năm" },
        tsuki: { text: "Tháng" },
        hi: { text: "Ngày" },
        deleteHaigo: { text: "Xóa công thức" },
        up: { text: "↑" },
        down: { text: "↓" },
        ts: { text: "Timestamp" },
        cd_create: { text: "Người đăng ký" },
        dt_create: { text: "Ngày đăng ký" },
        cd_update: { text: "Người cập nhật" },
        dt_update: { text: "Ngày cập nhật" },
        no_seq: { text: "id" },

        // PLC項目
        no_plc_komoku: { text: "PLC" },
        nm_plc_komoku: { text: "PLC" },

        // 固定値
        tani_kg: { text: "Kg" },
        tani_LB: { text: "LB" },
        tani_mai: { text: "Tờ" },
        haigo_total: { text: "Tổng trọng lượng công thức" },
        max_juryo: { number: 999999.999999 },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        con_recipe: { text: "Trạng thái công thức"},
        changeRecipe: { text: "Đang cập nhật" },
        createRecipe: { text: "Đang tạo mới" },
        totalQtyHaigo: { text: "Bằng tổng trọng lượng công thức" },
        labelChomieki: { text: "Nhãn BTP" },
        mishiyoError: { text: MS0678 },
        navigateErrorDetail: { text: MS0614 },
        navigateErrorPrint: { text: MS0705 },
        kowakejuryoError: { text: MS0771 },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の列幅を変更してください。
        no_kotei_width: { number: 70 },
        kbn_hin_width: { number: 95 },
        cd_hinmei_width: { number: 120 },
        nm_hinmei_width: { number: 200 },
        mark_width: { number: 40 },
        wt_shikomi_width: { number: 145 },
        nm_tani_shiyo_width: { number: 100 },
        wt_nisugata_width: { number: 130 },
        su_nisugata_width: { number: 120 },
        wt_kowake_width: { number: 130 },
        su_kowake_width: { number: 110 },
        flg_kowake_systemgai_width: { number: 160 },
        ritsu_budomari_width: { number: 85 },
        ritsu_hiju_width: { number: 60 },
        su_settei_width: { number: 90 },
        su_settei_max_width: { number: 70 },
        su_settei_min_width: { number: 70 },
        nm_futai_width: { number: 200 },
        each_lang_width: { number: 200 },
        // フッター項目の列幅
        qty_shiage_width: { number: 220 },
        totalQtyHaigo_width: { number: 210 },
        labelChomieki_width: { number: 150 },
        wt_chomieki_width: { number: 70 },
        maisu_width: { number: 70 },
        cd_tanto_koshin_width: { number: 200 },
        kbn_hinkan_width: { number: 110 },
        kbn_seizo_width: { number: 110 },
        replanConfirm: { text: MS0746 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("vi", {
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
            rules: { required: "Loại" },
            messages: { required: MS0042 }
        },
        cd_hinmei: {
            rules: {
                required: "Mã",
                maxbytelength: 14
            },
            params: { custom: "Mã" },
            messages: {
                required: MS0042,
                maxbytelength: MS0012,
                //custom: MS0049
                custom: MS0745
            }
        },
        nm_hinmei: {
            rules: {
                required: "Tên",
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
            params: { custom: "Dữ liệu nhập ứng với mác" },
            messages: { custom: MS0049 }
        },
        wt_shikomi: {
            rules: {
                //required: "Formula weight",
                number: true,
                range: [0.000000, 999999.999999]
            },
            params: {
                custom: "Trọng lượng công thức"
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
                required: "Tỉ lệ sử dụng",
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
                required: "Tỉ trọng",
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
                required: "Ngày bắt đầu hiệu lực",
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
                custom: "Trọng lượng công thức 1 mẻ"
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
    App.ui.pagedata.operation("vi", {
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