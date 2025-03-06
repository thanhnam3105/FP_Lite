
(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("vi", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Master thiết lập đơn vị" },
        cd_tani: { text: "Mã đơn vị" },
        nm_tani: { text: "Tên đơn vị" },
        flg_kinshi: { text: "Cấm" },
        flg_mishiyo: { text: "Không sử dụng" },
        dt_create: { text: "Ngày đăng ký" },
        cd_create: { text: "Người đăng ký" },
        dt_update: { text: "Ngày cập nhật" },
        cd_update: { text: "Người cập nhật" },
        ts: { text: "Timestamp" },
        saveConfirm: { text: MS0064 },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        noRecords: { text: MS0442 },
        notFound: { text: MS0037 },
        noSelect: { text: MS0443 },
        noChange: { text: MS0444 },
        unloadWithoutSave: { text: MS0066 }
        
        // TODO: ここまで
    });

    App.ui.pagedata.validation("vi", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        
        cd_tani: {
            rules: {
                required: "Mã đơn vị",
                alphanum: true,
                maxlength: 10
            },
            messages: {
                required: MS0042,
                alphanum: MS0439,
                maxlength: MS0012
            }
        },
        nm_tani: {
            rules: {
                required: "Đơn vị",
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
    // 権限設定
    App.ui.pagedata.operation("vi", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
        colchange: {
            Manufacture: { visible: false }
        },
        save: {
            Manufacture: { visible: false },
            Warehouse: { visible: false }
        }
        // TODO: ここまで
    });
    //// ページデータ -- End
})();