
(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("vi", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Master chỉ thị sản xuất" },
        cd_sagyo: { text: "Mã chỉ thị sản xuất" },
        nm_sagyo: { text: "Tên chỉ thị sản xuất" },
        detail: { text: "Chi tiết" },
        cd_mark: { text: "Nhãn" },
        flg_mishiyo: { text: "Không<br>sử dụng" },
        ts: { text: "Timestamp" },
        cd_create: { text: "Người đăng ký" },
        dt_create: { text: "Ngày đăng ký" },
        saveConfirm: { text: MS0064 },

        // 検索条件
        con_sagyo: { text: "Operation name" },

        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        noRecords: { text: MS0442 },
        noSelect: { text: MS0443 },
        noChange: { text: MS0444 },
        notFound: { text: MS0037 },
        unloadWithoutSave: { text: MS0066 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("vi", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。

        cd_sagyo: {
            rules: {
                required: "Mã",
                alphanum: true,
                maxlength: 10
            },
            messages: {
                required: MS0042,
                alphanum: MS0439,
                maxlength: MS0012
            }
        },
        nm_sagyo: {
            rules: {
                illegalchara: true,
                required: "Tên chỉ thị sản xuất",
                maxbytelength: 50
            },
            messages: {
                illegalchara: MS0005,
                required: MS0042,
                maxbytelength: MS0012
            }
        },
        detail: {
            rules: {
                illegalchara: true,
                maxbytelength: 4000
            },
            messages: {
                illegalchara: MS0005,
                maxbytelength: MS0012
            }
        },
        cd_mark: {
            rules: {
                required: "Nhãn"
            },
            messages: {
                required: MS0042
            }
        }
        // TODO: ここまで
    });
    App.ui.pagedata.validation2("en", {
        // 検索条件のバリデーション
        con_sagyo: {
            rules: {
                illegalchara: true,
                maxbytelength: 50
            },
            messages: {
                illegalchara: MS0005,
                maxbytelength: MS0012
            }
        }
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("vi", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
        save: {
            Manufacture: { visible: false },
            Purchase: { visible: false },
            Warehouse: { visible: false }
        },
        colchange: {
            Warehouse: { visible: false }
        },
        add: {
            Manufacture: { visible: false },
            Purchase: { visible: false },
            Warehouse: { visible: false }
        },
        del: {
            Manufacture: { visible: false },
            Purchase: { visible: false },
            Warehouse: { visible: false }
        },
        search: {
            Warehouse: { visible: false }
        },
        "grid:itemGrid.cd_sagyo": {
            Manufacture: { visible: false },
            Purchase: { visible: false },
            Warehouse: { visible: false }
        }
        // TODO: ここまで
    });

    //// ページデータ -- End
})();