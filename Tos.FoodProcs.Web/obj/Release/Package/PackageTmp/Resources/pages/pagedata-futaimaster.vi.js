
(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("vi", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Master kiểu đóng gói" },
        cd_futai: { text: "Mã" },
        nm_futai: { text: "Tên kiểu đóng gói" },
        flg_mishiyo: { text: "Không<br>sử dụng" },
        ts: { text: "Time stamp" },
        cd_create: { text: "Người đăng ký" },
        dt_update: { text: "Ngày giờ đăng ký" },
        dt_create: { text: "Ngày giờ tạo" },

        
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        noRecords: { text: MS0442 },
        noSelect: { text: MS0443 },
        noChange: { text: MS0444 },
        unloadWithoutSave: { text: MS0066 },
        saveConfirm: { text: MS0064 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("vi", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        
        cd_futai: {
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
        nm_futai: {
            rules: {
                required: "Tên kiểu đóng gói",
                maxbytelength: 50
            },
            messages: {
                required: MS0042,
                maxbytelength: MS0012
            }
        }
        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("vi", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
        save: {
            Purchase: { visible: false },
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
        }
        // TODO: ここまで
    });

    //// ページデータ -- End
})();