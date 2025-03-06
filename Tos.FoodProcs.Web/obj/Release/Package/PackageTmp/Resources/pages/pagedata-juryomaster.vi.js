(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("vi", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Master trọng lượng" },
        cd_hinmei: { text: "Mã" },
        nm_hinmei: { text: "Tên" },
        wt_kowake: { text: "Trọng lượng" },
        kbn_jotai: { text: "Loại trạng thái" },
        kbn_hin: { text: "Loại nguyên liệu" },
        cd_hinmei_kensaku: { text: "Mã nguyên liệu" },
        nm_hinmei_kensaku: { text: "Tên nguyên liệu" },
        dt_create: { text: "Ngày giờ tạo" },
        cd_create: { text: "Người tạo" },
        ts: { text: "Timestamp" },
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        // TODO: 画面の仕様に応じて以下の列幅を変更してください。
        cd_hinmei_width: { number: 130 },
        nm_hinmei_width: { number: 500 },
        wt_kowake_width: { number: 130 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("vi", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。

        cd_hinmei: {
            rules: {
            	alphanumForCode: true,
                maxlength: 14,
                custom: false
            },
            params: {
                custom: "Mã"
            },
            messages: {
                alphanumForCode: MS0439,
                maxlength: MS0012,
                custom: MS0049
            }
        },
        wt_kowake: {
            rules: {
                required: "Trọng lượng",
                number: true,
                pointlength: [6, 6, false]
            },
            messages: {
                required: MS0042,
                number: MS0441,
                pointlength: MS0440
            }
        },
        cd_hinmei_kensaku: {
            rules: {
                alphanum: true,
                maxlength: 14,
                custom: false
            },
            params: {
                custom: "Mã nguyên liệu"
            },
            messages: {
                alphanum: MS0439,
                maxlength: MS0012,
                custom: MS0049
            }
        },
        kbn_hin: {
            rules: {
                custom: false
            },
            params: {
                custom: "Mã nguyên liệu"
            },
            messages: {
            	custom: MS0049
            }

        }
        //  TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("vi", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
        search: {
            Warehouse: { visible: false }
        },
        colchange: {
            Warehouse: { visible: false }
        },
        add: {
            Purchase: { visible: false },
            Warehouse: { visible: false }
        },
        del: {
            Purchase: { visible: false },
            Warehouse: { visible: false }
        },
        hinmei: {
            Purchase: { visible: false },
            Warehouse: { visible: false }
        },
        save: {
            Purchase: { visible: false },
            Warehouse: { visible: false }
        }
        // TODO: ここまで
    });

    //// ページデータ -- End
})();