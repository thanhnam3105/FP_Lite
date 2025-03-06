(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("vi", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Master dây chuyền có thể sản xuất" },
        masterKubun: { text: "Loại master" },
        haigoCode: { text: "Mã" },
        haigoName: { text: "Tên" },
        seizoLineCode: { text: "Mã dây chuyền" },
        seizoLineName: { text: "Tên dây chuyền" },
        yusenNumber: { text: "Thứ tự" },
        mishiyoFlag: { text: "Không sử dụng" },
        torokuCode: { text: "Người đăng ký" },
        torokuDate: { text: "Ngày đăng ký" },
        ts: { text: "Timestamp" },
        saveConfirm: { text: MS0064 },
        clearConfirm: { text: MS0070 },
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
                maxbytelength: 14,
				custom: true
            },
            params: {
                custom: "Mã công thức"
            },
            messages: {
                required: MS0004,
                alphanum: MS0439,
                maxbytelength: MS0012,
                custom: MS0049
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
                alphanum: MS0005,
                maxbytelength: MS0012,
                custom: MS0049
            }
        },
        no_juni_yusen: {
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
        line: {
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