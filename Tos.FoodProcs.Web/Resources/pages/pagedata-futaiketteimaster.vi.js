(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("vi", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Master quy định kiểu đóng gói" },
        wt_kowake: { text: "Trọng lượng" },
        cd_tani: { text: "Đơn vị" },
        cd_futai: { text: "Mã kiểu đóng gói" },
        nm_futai: { text: "Tên kiểu đóng gói" },
        flg_mishiyo: { text: "Không sử dụng" },
        kbn_jotai: { text: "Loại trạng thái" },
        cd_hinmei: { text: "Mã sản phẩm" },
        kbn_hin: { text: "Loại sản phẩm" },
        nm_hinmei: { text: "Tên sản phẩm" },
        dt_create: { text: "Ngày tạo" },
        cd_create: { text: "Người tạo" },
        ts: { text: "Time stamp" },

        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        noRecords: { text: MS0442 },
        noSelect: { text: MS0443 },
        noChange: { text: MS0444 },
        unloadWithoutSave: { text: MS0066 },
        saveConfirm: { text: MS0064 },
        clearConfirm: { text: MS0070 },
        searchBefore: { text: MS0621 },
        changeCondition: { text: MS0299 },
        overSearchCount: { text: MS0624 },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の列幅を変更してください。
        wt_kowake_width: { number: 130 },
        cd_tani_width: { number: 120 },
        cd_futai_width: { number: 110 },
        nm_futai_width: { number: 500 },
        flg_mishiyo_width: { number: 95 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("vi", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。

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
        cd_tani: {
            rules: {
                required: "Đơn vị"
            },
            messages: {
                required: MS0042
            }
        },
        cd_futai: {
            rules: {
                required: "Mã kiểu đóng gói",
                alphanum: true,
                maxlength: 10
            },
            params: {
                custom: "Mã kiểu đóng gói"
            },
            messages: {
                required: MS0042,
                alphanum: MS0439,
                maxlength: MS0012,
                custom: MS0049
            }
        },        
        cd_hinmei: {
            rules: {
                alphanum: true,
                maxlength: 14
            },
            params: {
                custom: "Mã sản phẩm"
            },
            messages: {
                alphanum: MS0439,
                maxlength: MS0012,
                custom: MS0049
            }
        }
        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("vi", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
        search: {
            Warehouse: { visible: false }
        },
        save: {
            Purchase: { visible: false },
            Warehouse: { visible: false }
        },
        clear: {
            Purchase: { visible: false },
            Warehouse: { visible: false }
        },
        toroku: {
            Warehouse: { visible: false }
        },
        colchange: {
            Warehouse: { visible: false }
        },
        futai: {
            Purchase: { visible: false },
            Warehouse: { visible: false }
        },
        add: {
            Purchase: { visible: false },
            Warehouse: { visible: false }
        },
        del: {
            Purchase: { visible: false },
            Warehouse: { visible: false }
        }
        // TODO: ここまで
    });

    //// ページデータ -- End
})();