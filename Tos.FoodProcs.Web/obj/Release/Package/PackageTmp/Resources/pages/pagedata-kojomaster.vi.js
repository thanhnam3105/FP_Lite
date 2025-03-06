
(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("vi", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Master xưởng sản xuất" },
        cd_kojo: { text: "Mã xưởng SX" },
        nm_kojo: { text: "Tên xưởng SX" },
        dt_nendo_start: { text: "Tháng bắt đầu năm tài chính" },
        no_yubin1: { text: "Số bưu điện 1" },
        no_yubin2: { text: "Số bưu điện 2" },
        jusho_1: { text: "Địa chỉ 1" },
        jusho_2: { text: "Địa chỉ 2" },
        jusho_3: { text: "Địa chỉ 3" },
        tel_1: { text: "TEL1" },
        tel_2: { text: "TEL2" },
        fax_1: { text: "FAX1" },
        fax_2: { text: "FAX2" },
        kbn_haigo_keisan_hoho: { text: "Loại cách tính thành phần" },
        nm_kbn_haigo_keisan_hoho: { text: "Tên cách tính thành phần" },
        dt_kigen_chokuzen: { text: "Số ngày ngay trước khi hết hạn" },
        dt_kigen_chikai: { text: "Số ngày gần hết hạn" },
        dt_toroku: { text: "Ngày đăng ký" },
        dt_henko: { text: "Ngày cập nhật" },
        ts: { text: "Timestamp" },
        cd_toroku: { text: "Người đăng ký" },
        cd_kaisha: { text: "Mã công ty" },
        no_com_reader_niuke: { text: "Mã số COM của máy đọc" },
          
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        saveConfirm: { text: MS0064 },
        checkDateKigen: { text: MS0618 },
        // TODO: 画面の仕様に応じて以下の列幅を変更してください。
        cd_kojo_width: { number: 100 },
        nm_kojo_width: { number: 250 },
        dt_nendo_start_width: { number: 175 },
        no_yubin1_width: { number: 90 },
        no_yubin2_width: { number: 90 },
        nm_jusho_1_width: { number: 215 },
        nm_jusho_2_width: { number: 215 },
        nm_jusho_3_width: { number: 215 },
        no_tel_1_width: { number: 110 },
        no_tel_2_width: { number: 110 },
        no_fax_1_width: { number: 110 },
        no_fax_2_width: { number: 110 },
        kbn_haigo_keisan_hoho_width: { number: 155 },
        nm_kbn_haigo_keisan_hoho_width: { number: 190 },
        dt_kigen_chokuzen_width: { number: 190 },
        dt_kigen_chikai_width: { number: 130 },
        no_com_reader_niuke_width: { number: 155 },
        dt_create_width: { number: 100 },
        dt_update_width: { number: 100 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("vi", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。

        dt_nendo_start: {
            rules: {
                required: "Tháng bắt đầu năm tài chính",
                month: true,
                maxbytelength: 2
            },
            messages: {
                required: MS0042,
                month: MS0449,
                maxbytelength: MS0012
            }
        },
        no_yubin1: {
            rules: {
                haneisukigo: true,
                maxbytelength: 10
            },
            messages: {
                haneisukigo: MS0439,
                maxbytelength: MS0012
            }
        },
        no_yubin2: {
            rules: {
                haneisukigo: true,
                maxbytelength: 10
            },
            messages: {
                haneisukigo: MS0439,
                maxbytelength: MS0012
            }
        },
        nm_jusho_1: {
            rules: {
                maxbytelength: 30
            },
            messages: {
                maxbytelength: MS0012
            }
        },
        nm_jusho_2: {
            rules: {
                maxbytelength: 30
            },
            messages: {
                maxbytelength: MS0012
            }
        },
        nm_jusho_3: {
            rules: {
                maxbytelength: 30
            },
            messages: {
                maxbytelength: MS0012
            }
        },
        no_tel_1: {
            rules: {
                haneisukigo: true,
                maxbytelength: 20
            },
            messages: {
                haneisukigo: MS0439,
                maxbytelength: MS0012
            }
        },
        no_tel_2: {
            rules: {
                haneisukigo: true,
                maxbytelength: 20
            },
            messages: {
                haneisukigo: MS0439,
                maxbytelength: MS0012
            }
        },
        no_fax_1: {
            rules: {
                haneisukigo: true,
                maxbytelength: 20
            },
            messages: {
                haneisukigo: MS0439,
                maxbytelength: MS0012
            }
        },
        no_fax_2: {
            rules: {
                haneisukigo: true,
                maxbytelength: 20
            },
            messages: {
                haneisukigo: MS0439,
                maxbytelength: MS0012
            }
        },
        dt_kigen_chokuzen: {
            rules: {
                //required: "Very near to expiry date",
                required: "Số ngày ngay trước khi hết hạn",
                number: true,
                digits: [2],
                range: [1, 99]
            },
            messages: {
                required: MS0042,
                number: MS0441,
                digits: MS0576,
                range: MS0450
            }
        },
        dt_kigen_chikai: {
            rules: {
                //required: "Near to expiry date",
                required: "Số ngày gần hết hạn",
                number: true,
                digits: [2],
                range: [1, 99]
            },
            messages: {
                required: MS0042,
                number: MS0441,
                digits: MS0576,
                range: MS0450
            }
        },
        no_com_reader_niuke: {
            rules: {
                number: true,
                digits: [2],
                range: [1, 99]
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
        // 一覧
        colchange: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }

        },
        // 詳細
        save: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        detail: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        }
    });

    //// ページデータ -- End
})();