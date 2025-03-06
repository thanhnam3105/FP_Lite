(function () {
    var lang = App.ui.pagedata.lang("zh", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "生产线未登录一览" },
        cd_hinmei: { text: "编号" },
        nm_hinmei: { text: "名称" },
        lineSave: { text: "生产线登录" },
        notFound: { text: MS0037 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("zh", {
    // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
    // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("zh", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
        search: {
            Operator: { visible: false },
            Viewer: { visible: false },
            guest: { visible: false },
            Warehouse: { visible: false }
        },
        lineSave: {
            Operator: { visible: false },
            Viewer: { visible: false },
            guest: { visible: false },
            Warehouse: { visible: false }
        }
        // TODO: ここまで
    });
})();
