(function () {

    var lang = App.ui.pagedata.lang("zh", {
        _pageTitle: { text: "登录" },
        userId: { text: "用户ID" },
        password: { text: "密码" },
        persistantLogin: { text: "维持登录"},
    });

    App.ui.pagedata.validation("zh", {
        userId: {
            rules: { required: true },
            messages: { required: "用户ID为必须输入内容。" }
        },
        password: {
            rules: {
                required: true
            },
            messages: {
                required: "密码为必须输入内容。"
            }
        }
    });
})();
