(function () {
    var lang = App.ui.pagedata.lang("vi", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Danh sách master cân" },
        flg_mishiyo_kensaku: { text: "Hiển thị KSD", tooltip: "Hiển thị không sử dụng"},
        cd_hakari: { text: "Mã cân" },
        nm_hakari: { text: "Định dạng" },
        nm_tani: { text: "Đơn vị" },
        cd_tani: { text: "Mã đơn vị" },
        joken_tushin: { text: "Điều kiện truyền gửi" },
        kbn_baurate: { text: "Baud rate" },
        kbn_parity: { text: "Parity" },
        kbn_databit: { text: "Độ dài dữ liệu" },
        kbn_stopbit: { text: "Stop bit" },
        kbn_handshake: { text: "Hand shake" },
        nm_antei: { text: "Ổn định" },
        nm_fuantei: { text: "Không ổn định" },
        su_keta: { text: "Ký tự" },
        no_ichi_juryo: { text: "Trọng lượng" },
        su_ichi_fugo: { text: "Ký hiệu" },
        cd_fundo: { text: "Mã quả cân" },
        wt_fundo: { text: "Quả cân tiêu chuẩn" },
        disp_fugo: { text: "Xuất ký hiệu" },
        flg_fugo: { text: "Chưa xuất ký hiệu" },
        flg_mishiyo: { text: "Không <br>sử dụng" },
        flg_hakari_check: { text: "Kiểm tra cân" },
        flg_mishiyo_shosai: { text: "Trường hợp không sử dụng" },
        dt_create: { text: "Ngày đăng ký" },
        cd_create: { text: "Người đăng ký" },
        dt_update: { text: "Ngày cập nhật" },
        cd_update: { text: "Người cập nhật" },
        no_com: { text: "Số port COM" },
        ts: { text: "Timestamp" },

        dispFugoMsg: { text: "Không làm" },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        noRecords: { text: MS0442 },
        noSelect: { text: MS0443 },
        noChange: { text: MS0444 },
        saveConfirm: { text: MS0064 },
        saveComplete: { text: MS0036 },
        deleteConfirm: { text: MS0068 },
        deleteComplete: { text: MS0039 },
        unloadWithoutSave: { text: MS0066 },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の列幅を変更してください。
        cd_hakari_width: { number: 80 },
        nm_hakari_width: { number: 200 },
        nm_tani_width: { number: 80 },
        nm_kbn_baurate_width: { number: 100 },
        nm_kbn_parity_width: { number: 100 },
        nm_kbn_databit_width: { number: 100 },
        nm_kbn_stopbit_width: { number: 120 },
        nm_kbn_handshake_width: { number: 120 },
        nm_antei_width: { number: 60 },
        nm_fuantei_width: { number: 70 },
        no_ichi_juryo_width: { number: 50 },
        su_keta_width: { number: 50 },
        su_ichi_fugo_width: { number: 50 },
        wt_fundo_width: { number: 120 },
        flg_fugo_width: { number: 110 },
        flg_mishiyo_width: { number: 60 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("vi", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        cd_hakari: {
            rules: {
                required: "Mã cân",
                alphanum: true,
                maxlength: 10
            },
            messages: {
                required: MS0042,
                alphanum: MS0439,
                maxlength: MS0021
            }
        },
        nm_antei: {
            rules: {
                required: "Tên ổn định",
                alphanum: true,
                maxlength: 6
            },
            messages: {
                required: MS0042,
                alphanum: MS0439,
                maxlength: MS0021
            }
        },
        nm_hakari: {
            rules: {
                required: "Định dạng",
                maxbytelength: 50
            },
            messages: {
                required: MS0042,
                maxbytelength: MS0012
            }
        },
        nm_fuantei: {
            rules: {
                required: "Tên không ổn định",
                alphanum: true,
                maxlength: 6
            },
            messages: {
                required: MS0042,
                alphanum: MS0439,
                maxlength: MS0021
            }
        },
        cd_tani: {
            rules: {
                required: "Đơn vị"
            },
            messages: {
                required: MS0042
            }
        },
        no_ichi_juryo: {
            rules: {
                required: "Trọng lượng",
                number: true,
                pointlength: [4, 0, true]
            },
            messages: {
                required: MS0042,
                number: MS0441,
                pointlength: MS0440
            }
        },
        kbn_baurate: {
            rules: {
                required: "Baud rate"
            },
            messages: {
                required: MS0042
            }
        },
        su_keta: {
            rules: {
                required: "Ký tự",
                number: true,
                pointlength: [4, 0, true]
            },
            messages: {
                required: MS0042,
                number: MS0441,
                pointlength: MS0440
            }
        },
        kbn_parity: {
            rules: {
                required: "Parity"
            },
            messages: {
                required: MS0042
            }
        },
        su_ichi_fugo: {
            rules: {
                required: "Ký hiệu",
                number: true,
                pointlength: [4, 0, true]
            },
            messages: {
                required: MS0042,
                number: MS0441,
                pointlength: MS0440
            }
        },
        kbn_databit: {
            rules: {
                required: "Độ dài dữ liệu"
            },
            messages: {
                required: MS0042
            }
        },
        cd_fundo: {
            rules: {
                required: "Quả cân tiêu chuẩn"
            },
            messages: {
                required: MS0042
            }
        },
        kbn_stopbit: {
            rules: {
                required: "Stop bit"
            },
            messages: {
                required: MS0042
            }
        },
        flg_fugo: {
            rules: {
                required: "Xuất ký hiệu"
            },
            messages: {
                required: MS0042
            }
        },
        kbn_handshake: {
            rules: {
                required: "Hand shake"
            },
            messages: {
                required: MS0042
            }
        }
        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("vi", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
        add: {
            Viewer: { visible: false }
        },
        save: {
            Viewer: { visible: false }
        },
        del: {
            Viewer: { visible: false }
        }
        // TODO: ここまで
    });
})();