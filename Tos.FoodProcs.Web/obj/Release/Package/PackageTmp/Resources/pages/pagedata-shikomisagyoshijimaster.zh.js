
(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("zh", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "投放作业指示主表" },
        cd_sagyo: { text: "投放作业指示编号" },
        nm_sagyo: { text: "投放作业指示名" },
        detail: { text: "详细" },
        cd_mark: { text: "标记" },
        flg_mishiyo: { text: "未使用" },
        ts: { text: "时间标记" },
        cd_create: { text: "登录者" },
        dt_create: { text: "登录日期" },
        saveConfirm: { text: MS0064 },

        // 検索条件
        con_sagyo: { text: "投放作业指示" },

        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        noRecords: { text: MS0442 },
        noSelect: { text: MS0443 },
        noChange: { text: MS0444 },
        notFound: { text: MS0037 },
        unloadWithoutSave: { text: MS0066 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("zh", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。

        cd_sagyo: {
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
        nm_sagyo: {
            rules: {
                illegalchara: true,
                required: "投放作业指示名",
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
                required: "标记"
            },
            messages: {
                required: MS0042
            }
        }
        // TODO: ここまで
    });
    App.ui.pagedata.validation2("zh", {
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
    App.ui.pagedata.operation("zh", {
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
