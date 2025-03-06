(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("vi", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Master dây chuyền sản xuất" },
        shokuba: { text: "Bộ phận SX", tooltip: "Bộ phận sản xuất" },
        lineCode: { text: "Mã dây chuyền" },
        lineName: { text: "Tên dây chuyền" },
        mishiyoFlag: { text: "Không sử dụng" },
        createCode: { text: "Người đăng ký" },
        createDate: { text: "Ngày đăng ký" },
        updateDate: { text: "Ngày cập nhật" },
        ts: { text: "Time stamp" },
        saveConfirm: { text: MS0064 },
        searchConfirm: { text: MS0065 },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        noRecords: { text: MS0442 },
        notFound: { text: MS0037 },
        noSelect: { text: MS0443 },
        noChange: { text: MS0444 },
        unloadWithoutSave: { text: MS0066 },
        searchBefore: { text: MS0621 },
        changeCondition: { text: MS0299 },
        // TODO: 画面の仕様に応じて以下の列幅を変更してください。
        cd_line_width: { number: 120 },
        nm_line_width: { number: 450 },
        flg_mishiyo_width: { number: 100 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("vi", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        shokuba: {
            rules: {
                required: "Bộ phận SX"
            },
            messages: {
                required: MS0004
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
        nm_line: {
            rules: {
                illegalchara: true,
                required: "Tên dây chuyền",
                maxbytelength: 20
            },
            messages: {
                illegalchara: MS0005,
                required: MS0042,
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
        save: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Purchase: { visible: false },
            Warehouse: { visible: false }
        },
        colchange: {
            Warehouse: { visible: false }
        },
        add: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Purchase: { visible: false },
            Warehouse: { visible: false }
        },
        del: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Purchase: { visible: false },
            Warehouse: { visible: false }
        }
        // TODO: ここまで
    });

    //// ページデータ -- End
})();