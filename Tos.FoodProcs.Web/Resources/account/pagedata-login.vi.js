(function () {

    var lang = App.ui.pagedata.lang("vi", {
        _pageTitle: { text: "Đăng nhập" },
        userId: { text: "ID nhân viên" },
        password: { text: "Mật khẩu" },
        persistantLogin: { text: "Giữ trạng thái đăng nhập"},
    });

    App.ui.pagedata.validation("vi", {
        userId: {
            rules: { required: true },
            messages: { required: "ID nhân viên là mục bắt buộc." }
        },
        password: {
            rules: {
                required: true
            },
            messages: {
                required: "Mật khẩu là mục bắt buộc."
            }
        }
    });
})();