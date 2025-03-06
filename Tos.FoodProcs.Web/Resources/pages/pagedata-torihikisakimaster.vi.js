(function () {
    var lang = App.ui.pagedata.lang("vi", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Master khách hàng" },

        kbn_torihiki: { text: "Loại khách hàng" },
        nm_kbn_torihiki: { text: "Loại khách hàng" },
        nm_torihiki: { text: "Tên khách hàng" },
        cd_torihiki: { text: "Mã khách hàng" },
        nm_torihiki_ryaku: { text: "Tên khách hàng (Gọi tắt)" },
        nm_busho: { text: "Tên bộ phận sản xuất"},
        no_yubin: { text: "Mã số bưu điện" },
        nm_jusho: { text: "Địa chỉ" },
        no_tel: { text: "TEL" },
        no_fax: { text: "FAX" },
        e_mail: { text: "E-Mail" },
        nm_tanto_1: { text: "Người phụ trách (1)" },
        nm_tanto_2: { text: "Người phụ trách (2)" },
        nm_tanto_3: { text: "Người phụ trách (3)" },
        kbn_keishiki_nonyusho: { text: "Định dạng phiếu nhập" },
        nm_kbn_keishiki_nonyusho: { text: "Định dạng phiếu nhập" },
        kbn_keisho_nonyusho: { text: "Loại kính ngữ" },
        nm_kbn_keisho_nonyusho: { text: "Loại kính ngữ" },
        kbn_hin: { text: "Loại sản phẩm" },
        biko: { text: "Ghi chú" },
        cd_maker: { text: "Mã nhà sản xuất" },
        flg_pikking: { text: "Cờ báo picking" },
        flg_mishiyo: { text: "Không<br>sử dụng" },
        display_unused: { text: "Hiển thị DLKH KSD", tooltip: "Hiển thị cả dữ liệu khách hàng không sử dụng" },
        dt_create: { text: "Ngày đăng ký" },
        cd_create: { text: "Mã người đăng ký" },
        dt_update: { text: "Ngày cập nhật" },
        cd_update: { text: "Mã người cập nhật" },
        ts: { text: "Time stamp" },
        nonyusho: { text: "Định dạng phiếu nhập" },
        notUse: { text: "Trường hợp không sử dụng" },
        nm_keishiki_nonyu: { text: "Số lượng nhập" },
        nm_keishiki_shiyou: { text: "Số lượng sử dụng" },
        nm_keisho_sama: { text: "Ông/Bà" },
        nm_keisho_onchu: { text: "Kính gửi" },
        nm_keisho_nashi: { text: "Không có" },
        nm_flg_mishiyo_ari: { text: "Có" },
        nm_flg_mishiyo_nashi: { text: "Không có" },
        deleteConfirm: { text: MS0068 },
        noRecords: { text: MS0442 },
        noSelect: { text: MS0443 },
        noChange: { text: MS0444 },
        clearConfirm: { text: MS0070 },
        unloadWithoutSave: { text: MS0066 },
        saveConfirm: { text: MS0064 },
        saveComplete: { text: MS0036 },
        deleteComplete: { text: MS0039 },
        changeCriteria: { text: MS0299 },
        // TODO: ここまで

        //要らないものをカットしていく
        combDetail: { text: "Chi tiết công thức" },
        categoryCode: { text: "Mã loại" },
        categoryName: { text: "Tên loại" },
        articleDivisionCD: { text: "Mã loại bán thành phẩm" },
        articleDivisionName: { text: "Tên loại bán thành phẩm" },
        combinationCD: { text: "Mã công thức" },
        combinationName: { text: "Tên công thức" },
        combinationShortName: { text: "Tên công thức (gọi tắt)" },
        combinationRomaName: { text: "Tên công thức (Romaji)" },
        yield: { text: "Bảo lưu" },
        baseWeight: { text: "Trọng lượng cơ bản" },
        vwDivision: { text: "Phân loại V/W" },
        specificGravity: { text: "Tỉ trọng" },
        facilitiesCD: { text: "Mã thiết bị" },
        facilitiesName: { text: "Tên thiết bị" },
        maxWeight: { text: "Lượng tối đa cần sản xuất" },
        lineCode: { text: "Mã dây chuyền" },
        lineName: { text: "Tên dây chuyền" },
        priority: { text: "Thứ tự ưu tiên" },
        combinationID: { text: "Số thứ tự" },
        other: { text: "Xưởng SX khác" },
        recipe: { text: "Định mức nguyên liêu" },
        UpateTimestamp: { text: "Ngày cập nhật" },
        // ここまで

    });

    App.ui.pagedata.validation("vi", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        cd_torihiki: {
            rules: {
                required: "Mã khách hàng",
                alphanum: true,
                maxbytelength: 13
            },
            params: {
                custom: "Mã khách hàng"
            },
            messages: {
                required: MS0042,
                alphanum: MS0439,
                maxbytelength: MS0012,
                custom: MS0045
            }
        },
        
        nm_torihiki: {
            rules: {
                required: "Tên khách hàng",
                maxbytelength: 50
            },
            messages: {
                required: MS0042,
                maxbytelength: MS0012
            }
        },
        nm_busho: {
            rules: {
                maxbytelength: 50
            },
            messages: {
                maxbytelength: MS0012
            }
        },
        nm_torihiki_ryaku: {
            rules: {
                maxbytelength: 50
            },
            messages: {
                maxbytelength: MS0012
            }
        },
        nm_tanto_1: {
            rules: {
                maxbytelength: 50
            },
            messages: {
                maxbytelength: MS0012
            }
        },
        nm_tanto_2: {
            rules: {
                maxbytelength: 50
            },
            messages: {
                maxbytelength: MS0012
            }
        },
        nm_tanto_3: {
            rules: {
                maxbytelength: 50
            },
            messages: {
                maxbytelength: MS0012
            }
        },
        no_yubin: {
            rules: {
                haneisukigo: true,
                maxbytelength: 10
            },
            messages: {
                haneisukigo: MS0439,
                maxbytelength: MS0012
            }
        },
        nm_jusho: {
            rules: {
                maxbytelength: 100
            },
            messages: {
                maxbytelength: MS0012
            }
        },
        no_tel: {
            rules: {
                haneisukigo: true,
                maxbytelength: 20
            },
            messages: {
                haneisukigo: MS0439,
                maxbytelength: MS0012
            }
        },
        no_fax: {
            rules: {
                haneisukigo: true,
                maxbytelength: 20
            },
            messages: {
                haneisukigo: MS0439,
                maxbytelength: MS0012
            }
        },
        cd_maker: {
            rules: {
                alphanum: true,
                maxbytelength: 13
            },
            messages: {
                alphanum: MS0439,
                maxbytelength: MS0012
            }
        },
        e_mail: {
            rules: {
                passwordilligalchar: true,
                maxbytelength: 256
            },
            messages: {
                passwordilligalchar: MS0005,
                maxbytelength: MS0012
            }
        },
        biko: {
            rules: {
                maxbytelength: 256
            },
            messages: {
                maxbytelength: MS0012
            }
        }
        // TODO: ここまで
    });
    App.ui.pagedata.validation2("vi", {
        //TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        con_nm_torihiki: {
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

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("vi", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
        // TODO: ここまで
    });

    // 権限設定
    App.ui.pagedata.operation("vi", {
        search: {
            Manufacture: { visible: false }
        },
        colchange: {
            Manufacture: { visible: false }
        },
        add: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        del: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        detail: {
            Manufacture: { visible: false }
        },
        copy: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        excel: {
            Manufacture: { visible: false }
        },
        save: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        clear: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        }

    });

})();