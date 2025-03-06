<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="MainMenu.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.MainMenu" %>

<asp:Content ID="Content1" ContentPlaceHolderID="IncludeContent" runat="server">
    <script src="<%=ResolveUrl("~/Resources/pages/pagedata-mainmenu." + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
    <script src="<%=ResolveUrl("~/Resources/grid/grid.locale-" + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        /* 画面デザイン -- Start */
        .main-menu {
            margin : 15px;
	        width: 600px;
        }
        .main-menu a{
	        display: block;
	        height: 30px;
	        line-height: 30px;
	        background-color: var(--theme-color);
	        color: #ffffff;
	        vertical-align: middle;
	        text-decoration: none;
	        padding-left: 15px;
	        border: 1px solid var(--theme-color);
        }
        .main-menu a:hover {
            background-color: transparent;
            color: var(--theme-color);
            border: 1px solid var(--theme-color);
        }
        .main-menu li {
	        border-top: 1px solid #ffffff;  
	        border-left: 1px solid #ffffff;  
        }
        .main-menu li ul {
	        display:none;
	        margin-left:1em;
        }
        .main-menu li a span {
          background-image: url('../Styles/images/ui-icons_ffffff_256x240.png');
          background-repeat: no-repeat;
          display: inline-block;
          width: 15px;
          height: 15px;
          position: relative;
          top: 3px;
          left: 4px;
          background-position: -32px 0px;
        }
        .main-menu li a:hover span {
          background-image: url('../Styles/images/ui-icons_2e83ff_256x240.png');
        }
        /* TODO：ここまで */
        
        /* 画面デザイン -- End */
    </style>
    <script type="text/javascript">
        $(App.ui.page).on("ready", function () {
            // 表示、非表示の設定
            var isVisibleRole = function (item, role) {

                var visible = false,
                    i;

                if (!item.visible) {
                    return true;
                }

                // visible が "*" 以外の文字列で指定されていて、 role と一致しない場合は表示しない
                if (App.isStr(item.visible) && item.visible !== "*" && item.visible !== role) {
                    return visible;
                }
                // visible が 配列で role とどれも一致しない場合は表示しない
                else if (App.isArray(item.visible)) {

                    for (i = 0; i < item.visible.length; i++) {
                        if (item.visible[i] === role) {
                            visible = true;
                            break;
                        }
                    }

                    return visible;
                }
                // visible が 関数で戻り値が false の場合は表示しない
                else if (App.isFunc(item.visible)) {
                    return item.visible(role);
                }

                return true;
            };

            // menu.jsから、リンク要素を抽出
            var createItemsElement = function (items, zIndex, role) {
                var ul = $("<ul></ul>"),
                    li,
                    i,
                    item;

                for (i = 0; i < items.length; i++) {

                    item = items[i];
                    if (!isVisibleRole(item, role)) {
                        continue;
                    }

                    li = $("<li></li>");

                    if (item.items && item.items.length) {
                        li.append("<a href='" + (item.url ? item.url : "#") + "'>" + item.display + "<span></span>&nbsp;</a>");
                        li.append(createItemsElement(item.items, zIndex, role));
                        ul.append(li);
                    }
                    else if (item.url) {
                        li.append("<a href='" + item.url + "'>" + item.display + "</a>");
                        ul.append(li);
                    } else {
                        //作成する必要のないメニュー
                    }

                }

                return ul;
            };


            // メニュー作成
            var ddl = App.ui.ddlmenu.settingsObj[App.ui.page.lang] || { setting: [], title: "" };

            var role = App.ui.page.user.Roles[0]
            role = App.ifUndefOrNull(role, "");
            var root = createItemsElement(ddl.setting || [], 1001, role);
            root.addClass("main-menu");
            // 作成したメニューを、クラスへセットします
            $(".mainmenu-container").append(root);

            // menuを階層型アコーディオンで表示します
            $(".mainmenu-container").each(function () {
                $("li > a", this).each(function (index) {
                    var $this = $(this);
                    if (index > 0) $this.next().hide();
                    $this.mousedown(function () {
                        var params = { height: "toggle", opacity: "toggle" };
                        $(this).next().animate(params).parent().siblings()
                        .children("ul:visible").animate(params);
                        return false;
                    });
                });
            });

        });
    </script>

</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <!-- 画面デザイン -- Start -->
    <div class="mainmenu-container">
    </div>
    <!-- 画面アーキテクチャ共通のデザイン -- End -->

    <!-- 画面デザイン -- End -->
</asp:Content>
<asp:Content ID="Content5" ContentPlaceHolderID="DialogsContent" runat="server">
    <!-- 画面デザイン -- Start -->
    <!-- 画面デザイン -- End -->
</asp:Content>
