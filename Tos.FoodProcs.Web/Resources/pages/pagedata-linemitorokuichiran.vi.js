(function () {
    var lang = App.ui.pagedata.lang("vi", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Danh sách chưa đăng ký dây chuyền sản xuất" },
        cd_hinmei: { text: "Mã" },
        nm_hinmei: { text: "Tên" },
        lineSave: { text: "Đăng ký dây chuyền SX" },
        notFound: { text: MS0037 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("vi", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("vi", {
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