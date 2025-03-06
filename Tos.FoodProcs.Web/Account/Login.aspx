<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="Tos.FoodProcs.Web.Account.Login" 
 ClientIDMode="Static" EnableViewState="false" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="X-UA-Compatible" content="IE=8" />
    <title></title>
    <link media="all" rel="stylesheet" href="<%=ResolveUrl("~/Styles/style.css") %>" type="text/css" />
    <style type="text/css">
        .container {
            width: 100%;
            margin-top: 40px;
            text-align:center;
        }
        
        .login-container {
            margin-left:auto;
            margin-right:auto;
            width: 400px;
            margin:0px auto; 
            text-align:left;
        }
        
        .login-container input[type=text], .login-container input[type=password] {
            padding: 6px;
            font-size: 12pt;
            width: 320px;
            ime-mode: disabled;
        }
        
        .input-hint {
            color: #cccccc;
        }
        
        .login-container div {
            padding: 4px;
        }
        
        #password, #userid {
            display: none;
        }
        
        button {
            height: 30px;
            top: 5px;
            padding: 0px;
            min-width: 100px;
        }
        
        .command {
            margin-top: 10px;
            margin-left: 6px;
        }
    </style>
    <script src="<%=ResolveUrl("~/Scripts/jquery-1.8.2.js") %>" type="text/javascript"></script>
    <script src="<%=ResolveUrl("~/Scripts/jquery-ui-1.9.1.custom.js") %>" type="text/javascript"></script>
    <script src="<%=ResolveUrl("~/Scripts/ie6.js") %>" type="text/javascript"></script>
    <script src="<%=ResolveUrl("~/Scripts/app.js") %>" type="text/javascript"></script>
    <script src="<%=ResolveUrl("~/Scripts/ui.js") %>" type="text/javascript"></script>
    <script src="<%=ResolveUrl("~/Resources/message." + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>" type="text/javascript"></script>
    <script src="<%=ResolveUrl("~/Resources/pagedata-all." + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>" type="text/javascript"></script>
    <script src="<%=ResolveUrl("~/Resources/account/pagedata-login." + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>" type="text/javascript"></script>
    <script type="text/javascript">
        $(document).ready(function () {
            App.ui.page.lang = "<%= System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName%>";
            App.ui.pagedata.lang.applySetting(App.ui.page.lang);
            $(".header-container, .menu-container").css("background-color", "<%=colorMenuBar%>");

            var validation = Aw.validation({
                items: App.ui.pagedata.validation(App.ui.page.lang),
                handlers: {
                    success: function (results) {
                        var i = 0, l = results.length;
                        for (; i < l; i++) {
                            App.ui.page.notifyAlert.remove();
                            $("#" + results[i].element.id + "hint").removeClass("error");
                        }
                    },
                    error: function (results) {
                        var i = 0, l = results.length;
                        for (; i < l; i++) {
                            App.ui.page.notifyAlert.message(results[i].message).show();
                            $("#" + results[i].element.id + "hint").addClass("error");
                        }
                    }
                }
            });

            $(".login-container").validation(validation);

            // 通知の設定
            App.ui.page.setNotify(App.ui.notify.info(document.body, {
                container: ".slideup-area .info-message",
                messageContainerQuery: "ul",
                show: function () {
                    $(".info-message").show();
                },
                clear: function () {
                    $(".info-message").hide();
                }
            }), App.ui.notify.alert(document.body, {
                container: ".slideup-area .alert-message",
                messageContainerQuery: "ul",
                show: function () {
                    $(".alert-message").show();
                },
                clear: function () {
                    $(".alert-message").hide();
                }
            }));

            var userIdElem = $("#userid"),
                userIdHintElem = $("#useridhint");

            $("#passwordhint, #useridhint").on("focus", function (e) {
                $("#" + e.currentTarget.id.replace("hint", "")).show().focus();
                $("#" + e.currentTarget.id).hide();
            });

            $("#password, #userid").on("blur", function (e) {
                if ($(this).val().length > 0) {
                    return;
                }
                $("#" + e.currentTarget.id + "hint").show();
                $("#" + e.currentTarget.id).hide();
            });

            if (userIdElem.val()) {
                userIdElem.show();
                userIdHintElem.hide();
            }

            //ログインエラー
            var loginError = '<%= getLoginError() %>',
                loginErrorId = App.uuid();

            //エラーメッセージを表示
            if (loginError) {
                App.ui.page.notifyAlert.message(loginError, loginErrorId).show();
                $("#userid").focus();
            }

            $("#login").on("click", function () {
                App.ui.page.notifyAlert.clear();
                var result = $(".login-container").validation().validate();
                if (loginError) {
                    App.ui.page.notifyAlert.remove(loginErrorId);
                }
                if (result.errors.length) {
                    return;
                }
                $("#form1").submit();
            });
            if (loginError) {
                App.ui.page.notifyAlert.message(loginError, loginErrorId).show();
            }

            $(".login-container").on("keydown", function (evt) {
                if (evt.keyCode === 13) {
                    $("#login").click();
                }
            });

        });
    </script>
</head>
<body>
    <form id="form1" runat="server">
    <header>
       <div class="header-container">
       </div>
    </header>
    <div class="container">
        <div class="login-container">
            <div>
                <div>
                    <span class="item-label" data-app-text="userId"></span>
                </div>
                <div>
                    <input type="text" id="useridhint" data-app-text="value:userId" readonly="readonly" class="input-hint" />
                    <input type="text" runat="server" id="userid" data-app-validation="userId" />
                </div>
                <div>
                    <span class="item-label" data-app-text="password"></span>
                </div>
                <div>
                    <input type="text" id="passwordhint" data-app-text="value:password" readonly="readonly" class="input-hint" />
                    <input type="password" runat="server" id="password" data-app-validation="passowrd" />
                </div>
                <div>
                    <input type="checkbox" runat="server" id="persistlogin" />
                    <label for="persistlogin" data-app-text="persistantLogin"></label>
                    <!-- 内部ver確認用（手動変更） -->
                    <span class="item-label" style="color: white; margin-left: 30px">ver:1.0</span>
                </div>
            </div>
            <div class="command">
                <button id="login" type="button" data-app-text="login"></button>
            </div>
        </div>
    </div>
    </form>
    <footer>
        <div class="footer-container">
            <div class="message-area slideup-area">
                <div class="alert-message" data-app-text="title:alertTitle" style="display: none" title="">
                    <ul>
                    </ul>
                </div>
                <div class="info-message" data-app-text="title:infoTitle" style="display: none" title="">
                    <ul>
                    </ul>
                </div>
            </div>
        </div>
    </footer>
</body>
</html>
