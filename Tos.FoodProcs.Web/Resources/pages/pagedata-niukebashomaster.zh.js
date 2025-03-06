
(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("zh", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        //_pageTitle: { text: "领货地点主表" },
        _pageTitle: { text: "入库地点主表" },
        cd_niuke: { text: "编号" },
        //nm_niuke: { text: "领货地点名" },
        nm_niuke: { text: "入库地点名" },
        jusho_1: { text: "住址１" },
        jusho_2: { text: "住址２" },
        jusho_3: { text: "住址３" },
        flg_mishiyo: { text: "未使用" },
        ts: { text: "时间标记" },
        cd_toroku: { text: "登录者" },
        dt_toroku: { text: "登录日期" },
        saveConfirm: { text: MS0064 },
        kbn_niuke_basho: { text: "入库地点区分" },

        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        noRecords: { text: MS0442 },
        noSelect: { text: MS0443 },
        noChange: { text: MS0444 },
        unloadWithoutSave: { text: MS0066 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("zh", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。

        cd_niuke_basho: {
            rules: {
                required: "编号",
                alphanum: true,
                maxlength: 10
            },
            messages: {
                required: MS0042,
                alphanum: MS0439,
                maxlength: MS0012
            }
        },
        nm_niuke: {
            rules: {
                //required: "领货地点名",
                required: "入库地点名",
                maxbytelength: 50
            },
            messages: {
                required: MS0042,
                maxbytelength: MS0012
            }
        },
        kbn_niuke_basho: {
            rules: {
                required: "入库地点区分",
                custom: true
            },
            params: {
                custom: "入库地点区分"
            },
            messages: {
                required: MS0042,
                custom: MS0042
            }
        },
        nm_jusho_1: {
            rules: {
                maxbytelength: 30
            },
            messages: {
                maxbytelength: MS0012
            }
        },
        nm_jusho_2: {
            rules: {
                maxbytelength: 30
            },
            messages: {
                maxbytelength: MS0012
            }
        },
        nm_jusho_3: {
            rules: {
                maxbytelength: 30
            },
            messages: {
                maxbytelength: MS0012
            }
        }

        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("zh", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
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
