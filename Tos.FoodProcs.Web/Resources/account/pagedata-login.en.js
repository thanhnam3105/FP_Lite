(function () {

    var lang = App.ui.pagedata.lang("en", {
        _pageTitle: { text: "Login" },
        userId: { text: "User id" },
        password: { text: "Password" },
        persistantLogin: { text: "Keep me logged in." },
    });

    App.ui.pagedata.validation("en", {
        userId: {
            rules: { required: true },
            messages: { required: "Please enter your user id." }
        },
        password: {
            rules: {
                required: true
            },
            messages: {
                required: "Please enter your password."
            }
        }
    });
})();
