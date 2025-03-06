(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("zh", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        //_pageTitle: { text: "生产可能线主表" },
        _pageTitle: { text: "生产可能生产线主表" },
        masterKubun: { text: "主表区分" },
        haigoCode: { text: "编号" },
        haigoName: { text: "名称" },
        seizoLineCode: { text: "生产线编号" },
        seizoLineName: { text: "生产线名" },
        yusenNumber: { text: "顺序" },
        mishiyoFlag: { text: "未使用" },
        torokuCode: { text: "登录者" },
        torokuDate: { text: "登录日期" },
        ts: { text: "时间标记" },
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

    App.ui.pagedata.validation("zh", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        masterKubun: {
            rules: {
                required: "主表区分"
            },
            messages: {
                required: MS0004
            }
        },
        haigoCode: {
            rules: {
                required: "配料编号",
                alphanum: true,
                maxbytelength: 14,
                custom: true
            },
            params: {
                custom: "配料编号"
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
                required: "生产线编号",
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
                required: "顺序",
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
    App.ui.pagedata.operation("zh", {
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
