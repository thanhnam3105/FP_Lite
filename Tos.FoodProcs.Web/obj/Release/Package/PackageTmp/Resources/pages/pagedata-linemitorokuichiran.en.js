(function () {
    var lang = App.ui.pagedata.lang("en", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Manufacture Line Unregistered List" },
        cd_hinmei: { text: "Code" },
        nm_hinmei: { text: "Name" },
        lineSave: { text: "Register line" },
        notFound: { text: MS0037 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("en", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("en", {
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
