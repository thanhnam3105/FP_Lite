(function () {
    var lang = App.ui.pagedata.lang("vi", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Thông tin chung công thức" },
        cd_bunrui: { text: "Mã nhóm bán thành phẩm" },
        nm_bunrui: { text: "Nhóm bán thành phẩm" },
        cd_haigo: { text: "Mã công thức*" },
        nm_haigo_ja: { text: "Tên công thức (jp)*", tooltip: "Tên công thức (Tiếng Nhật)*"},
        nm_haigo_en: { text: "Tên công thức (en)*", tooltip: "Tên công thức (Tiếng Anh)*"},
        nm_haigo_zh: { text: "Tên công thức (zh)*", tooltip: "Tên công thức (Tiếng Trung)*" },
        nm_haigo_vi: { text: "Tên công thức (vi)*", tooltip: "Tên công thức (Tiếng Việt)*" },
        nm_haigo_ryaku: { text: "Tên công thức (viết tắt)" },
        ritsu_budomari: { text: "Tỉ lệ sử dụng*" },
        wt_kihon: { text: "Trọng lượng cơ bản*" },
        kbn_kanzan: { text: "Đơn vị quy đổi" },
        ritsu_hiju: { text: "Tỉ trọng*" },
        flg_gassan_shikomi: { text: "Tính gộp lượng sản xuất" },
        ritsu_kihon: { text: "Bội suất cơ bản" },
        shikomi_gassan: { text: "Tính gộp lượng SX", tooltip: "Tính gộp lượng sản xuất"},
        wt_saidai_shikomi: { text: "Lượng sản xuất tối đa*"},
        flg_shorihin: { text: "Nhãn BTP" },
        flg_mishiyo: { text: "Không sử dụng" },
        mishiyo: { text: "Hiển thị không sử dụng" },
        ts: { text: "Timestamp" },
        lineSave: { text: "Đăng ký dây chuyền" },
        no_han: { text: "Phiên bản" },
        dt_from: { text: "Thời hạn hiệu lực" },
        notUse: { text: "TH không sử dụng", tooltip: "Trường hợp không sử dụng"},
        dt_create: { text: "Ngày đăng ký" },
        dt_update: { text: "Ngày cập nhật" },
        lineSave: { text: "Đăng ký dây chuyền" },
        ma_haigo_mei: { text: "Vào master công thức" },
        ma_haigo_recipe: { text: "Vào master công thức" },
        ma_seizo_line: { text: "Vào master dây chuyền sản xuất" },
        flg_tenkai: { text: "Tự động lên kế hoạch" },
        //dd_shomi: { text: "Expiry date" },
        //dd_shomi: { text: "Shelf life before opened" },
        dd_shomi: { text: "Hạn sử dụng" },
        kbn_hokan: { text: "Cách bảo quản" },
        labelDay: { text: "Ngày" },
        lineOK: { text: "Có" },
        //lineNG: { text: "None" },
        lineNG: { text: "Không có" },
        labelKg: { text: "Kg" },
        labelLB: { text: "LB" },
        labelL: { text: "L" },
        labelGAL: { text: "GAL" },
        msg_nm_haigo_ja: { text: "Tên công thức (ja)" },
        msg_nm_haigo_en: { text: "Tên công thức (en)" },
        msg_nm_haigo_zh: { text: "Tên công thức (zh)" },
        msg_nm_haigo_vi: { text: "Tên công thức (vi)" },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        notFound: { text: MS0037 },
        requiredInput: { text: MS0042 },
        noRecords: { text: MS0442 },
        noSelect: { text: MS0443 },
        unloadWithoutSave: { text: MS0066 },
        clearConfirm: { text: MS0070 },
        navigateConfirm: { text: MS0076 },
        navigateError: { text: MS0623 },
        chomiCheck: { text: MS0732 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("vi", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
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
        nm_haigo_ja: {
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
        nm_haigo_en: {
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
        nm_haigo_zh: {
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
        nm_haigo_vi: {
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
        nm_haigo_ryaku: {
            rules: {
                illegalchara: true,
                maxbytelength: 50
            },
            messages: {
                illegalchara: MS0005,
                maxbytelength: MS0012
            }
        },
        ritsu_budomari: {
            rules: {
                required: "Tỉ lệ sử dụng",
                number: true,
                range: [0.01, 999.99],
                pointlength: [3, 2, false]
            },
            messages: {
                required: MS0042,
                number: MS0441,
                range: MS0450,
                pointlength: MS0440
            }
        },
        wt_kihon: {
            rules: {
                required: "Trọng lượng cơ bản",
                number: true,
                range: [1, 9999],
                digits: [4]
            },
            messages: {
                required: MS0042,
                number: MS0441,
                range: MS0450,
                digits: MS0576
            }
        },
        ritsu_kihon: {
            rules: {
                required: "Bội suất cơ bản",
                number: true,
                range: [0.01, 999.99],
                pointlength: [3, 2, false]
            },
            messages: {
                required: MS0042,
                number: MS0441,
                range: MS0450,
                pointlength: MS0440
            }
        },
        ritsu_hiju: {
            rules: {
                required: "Tỉ trọng",
                number: true,
                range: [0.0001, 99.9999],
                pointlength: [2, 4, false]
            },
            messages: {
                required: MS0042,
                number: MS0441,
                range: MS0450,
                pointlength: MS0440
            }
        },
        wt_saidai_shikomi: {
            rules: {
                required: "Lượng sản xuất tối đa",
                number: true,
                range: [0.000001, 999999.999999],
                pointlength: [6, 6, false]
            },
            messages: {
                required: MS0042,
                number: MS0441,
                range: MS0450,
                pointlength: MS0440
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
        }
        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("vi", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
        save: {
            NotRole: { visible: false },
            isRoleFisrt: { visible: false }
        },
        lineSave: {
            NotRole: { visible: false }
        },
        recipe: {
            NotRole: { visible: false }
        },
        clear: {
            NotRole: { visible: false }
        }
        // TODO: ここまで
    });
})();