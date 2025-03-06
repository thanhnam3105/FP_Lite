(function () {

    var lang = App.ui.pagedata.lang("ja", {
        _pageTitle: { text: "ログイン" },
        userId: { text: "ユーザーID" },
        password: { text: "パスワード" },
        persistantLogin: { text: "ログインしたままにする"},
    });

    App.ui.pagedata.validation("ja", {
        userId: {
            rules: { required: true },
            messages: { required: "ユーザーIDは必須です。" }
        },
        password: {
            rules: {
                required: true
            },
            messages: {
                required: "パスワードは必須です。"
            }
        }
    });
})();
