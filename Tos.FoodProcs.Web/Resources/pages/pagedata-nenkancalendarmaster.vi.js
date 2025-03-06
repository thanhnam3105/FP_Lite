(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("vi", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Master lịch năm" },
        yy_nendo: { text: "Năm" },
        dt_nendo_start: { text: "Tháng bắt đầu niên độ" },
        kojoKyujitsu: { text: "TLNN của xưởng SX",tooltip: "Thiết lập ngày nghỉ của xưởng sản xuất" },
        ippanKyujitsu: { text: "TLNN thông thường", tooltip: "Thiết lập ngày nghỉ thông thường" },
        kyujitsu: { text: "Ngày nghỉ" },
        kaijo: { text: "Hủy" },
        yobi: { text: "Thứ" },
        dt_yobi_1: { text: "Tháng 1" },
        dt_yobi_2: { text: "Tháng 2" },
        dt_yobi_3: { text: "Tháng 3" },
        dt_yobi_4: { text: "Tháng 4" },
        dt_yobi_5: { text: "Tháng 5" },
        dt_yobi_6: { text: "Tháng 6" },
        dt_yobi_7: { text: "Tháng 7" },
        dt_yobi_8: { text: "Tháng 8" },
        dt_yobi_9: { text: "Tháng 9" },
        dt_yobi_10: { text: "Tháng 10" },
        dt_yobi_11: { text: "Tháng 11" },
        dt_yobi_12: { text: "Tháng 12" },
        dt_1: { text: "Tháng 1" },
        dt_2: { text: "Tháng 2" },
        dt_3: { text: "Tháng 3" },
        dt_4: { text: "Tháng 4" },
        dt_5: { text: "Tháng 5" },
        dt_6: { text: "Tháng 6" },
        dt_7: { text: "Tháng 7" },
        dt_8: { text: "Tháng 8" },
        dt_9: { text: "Tháng 9" },
        dt_10: { text: "Tháng 10" },
        dt_11: { text: "Tháng 11" },
        dt_12: { text: "Tháng 12" },
        flg_kyujitsu: { text: "Cờ báo ngày nghỉ" },
        flg_shukujitsu: { text: "Cờ báo ngày lễ" },
        memo_1: { text: "※Thiết lập ngày nghỉ của xưởng SX là thiết lập ngày xưởng không hoạt động. (Phản ánh lên kế hoạch nhập)" },
        memo_2: { text: "※Thiết lập ngày nghỉ thông thường là thiết lập ngày nghỉ bình thường." },
        ts: { text: "Time stamp" },
        cd_create: { text: "Người đăng ký" },
        dt_create: { text: "Ngày đăng ký" },
        // TODO: ここまで

        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        noRecords: { text: MS0442 },
        notFound: { text: MS0037 },
        noSelect: { text: MS0443 },
        noChange: { text: MS0444 },
        saveConfirm: { text: MS0064 },
        findConfirm: { text: MS0065 },
        unloadWithoutSave: { text: MS0066 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("vi", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        masterKubun: {
            rules: {
                required: "Loại master"
            },
            messages: {
                required: MS0004
            }
        },
        haigoCode: {
            rules: {
                required: "Mã công thức",
                alphanum: true,
                maxbytelength: 14
            },
            messages: {
                required: MS0004,
                alphanum: MS0439,
                maxbytelength: MS0012
            }
        },
        cd_line: {
            rules: {
                required: "Mã dây chuyền",
                alphanum: true,
                maxbytelength: 10
            },
            messages: {
                required: MS0042,
                alphanum: MS0439,
                maxbytelength: MS0012
            }
        },
        no_yusen: {
            rules: {
                required: "Thứ tự",
                digits: true,
                range: [1, 99],
                maxbytelength: 2
            },
            messages: {
                required: MS0042,
                digits: MS0005,
                range: MS0009,
                maxbytelength: MS0012
            }
        }
        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("vi", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
        search: {
            Manufacture: { visible: false }
        },
        settei: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        save: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        }
        // TODO: ここまで
    });

    //// ページデータ -- End
})();