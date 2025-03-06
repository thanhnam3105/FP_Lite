(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("vi", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Master phân loại nhóm" },
        hinKubun: { text: "Loại dữ liệu" },
        bunruiCode: { text: "Mã" },
        bunruiName: { text: "Tên" },
        mishiyoFlag: { text: "Không sử dụng" },
        createCode: { text: "Người đăng ký" },
        createDate: { text: "Ngày đăng ký" },
        ts: { text: "Time stamp" },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        noRecords: { text: MS0442 },
        saveConfirm: { text: MS0064 },
        saveComplete: { text: MS0036 },
        searchConfirm: { text: MS0065 },
        notFound: { text: MS0037 },
        noSelect: { text: MS0443 },
        noChange: { text: MS0444 },
        unloadWithoutSave: { text: MS0066 },
        overSearchCount: { text: MS0624 },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の列幅を変更してください。
        cd_bunrui_width: { number: 120 },
        nm_bunrui_width: { number: 450 },
        flg_mishiyo_width: { number: 95 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("vi", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        hinKubun: {
            rules: {
                required: "Loại dữ liệu"
            },
            messages: {
                required: MS0004
            }
        },
        cd_bunrui: {
            rules: {
                required: "Mã",
                alphanum: true,
                maxbytelength: 10
            },
            messages: {
                required: MS0042,
                alphanum: MS0439,
                maxbytelength: MS0012
            }
        },
        nm_bunrui: {
            rules: {
                required: "Tên",
                illegalchara: true,
                maxbytelength: 50
            },
            messages: {
                required: MS0042,
                illegalchara: MS0005,
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
        save: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
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
        }
        // TODO: ここまで
    });

    //// ページデータ -- End
})();