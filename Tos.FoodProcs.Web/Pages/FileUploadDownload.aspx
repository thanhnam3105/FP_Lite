<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="FileUploadDownload.aspx.cs"
Inherits="Tos.FoodProcs.Web.Pages.FileUploadDownload" %>

<asp:Content ID="Content1" ContentPlaceHolderID="IncludeContent" runat="server">
    <script src="<%=ResolveUrl("~/Resources/pages/pagedata-fileuploaddownload." + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
    <script src="../Scripts/uploadfile.js" type="text/javascript"></script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        /* 画面デザイン -- Start */
        
        /* TODO：画面の仕様に応じて以下のスタイルを変更してください。 */
        .part-body .item-label
        {
            display: inline-block;
        }
        
        .part-body .item-list li
        {
            margin-bottom: .2em;
        }
        
        .csv-upload-dialog {
            background-color: White;
            width: 350px;
        }
        
        .fixed-upload-dialog {
            background-color: White;
            width: 350px;
        }
        
        .fixed-upload-dialog .item-label {
            width: 8em;
        }
        
        .dialog-footer .command button {
            margin-right: .5em;
        }
        
        .search-criteria .item-label
        {
            width: 8em;
        }

        .category-dialog {
            background-color: White;
            width: 400px;
        }
        .category-dialog2 {
            background-color: White;
            width: 400px;
        }
        /* TODO：ここまで */
        
        /* 画面デザイン -- End */
    </style>
    <script type="text/javascript">
        $(App.ui.page).on("ready", function () {
            /*
            画面処理のコードブロックは以下の内容で構成されています。

            ■ ページデータ (/Resources/pages/pagedata-ページ名.ロケール名.js)
            ■ 画面デザイン
            ■ コントロール定義
            ■ 変数宣言
            ■ 事前データロード
            ■ 検索処理
            ■ メッセージ表示
            ■ データ変更処理
            ■ 保存処理
            ■ バリデーション
            ■ 操作制御定義

            各コードブロック名を選択し Ctrl+F キーを押下することで
            Visual Studio の検索ダイアログを使用して該当のコードにジャンプできます。
            ・「TODO」で検索すると画面の仕様に応じて変更が必要なコードにジャンプできます。
            ・「画面アーキテクチャ共通」で検索すると画面アーキテクチャで共通のコードにジャンプできます。
            ・「グリッドコントロール固有」で検索するとグリッドコントロール固有のコードにジャンプできます。
            ・「ダイアログ固有」で検索するとダイアログ固有のコードにジャンプできます。
            */

            //// 変数宣言 -- Start

            // 画面アーキテクチャ共通の変数宣言
            var pageLangText = App.ui.pagedata.lang(App.ui.page.lang);

            // ダイアログ固有の変数宣言
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            var csvDialog = $(".csv-upload-dialog"),
                fixedDialog = $(".fixed-upload-dialog"),
                fixedDialogNotifyInfo = App.ui.notify.info(fixedDialog, {
                    container: ".fixed-upload-dialog .dialog-slideup-area .info-message",
                    messageContainerQuery: "ul",
                    show: function () {
                        fixedDialog.find(".info-message").show();
                    },
                    clear: function () {
                        fixedDialog.find(".info-message").hide();
                    }
                }),
                fixedDialogNotifyAlert = App.ui.notify.alert(fixedDialog, {
                    container: ".fixed-upload-dialog .dialog-slideup-area .alert-message",
                    messageContainerQuery: "ul",
                    show: function () {
                        fixedDialog.find(".alert-message").show();
                    },
                    clear: function () {
                        fixedDialog.find(".alert-message").hide();
                    }
                });
            var categoryDialog = $(".category-dialog");
            var categoryDialog2 = $(".category-dialog2");

            // TODO：ここまで

            //// 変数宣言 -- End

            //// コントロール定義 -- Start

            // ダイアログ固有のコントロール定義

            /// <summary>ダイアログ固有のコントロール定義を行います。</summary>
            /// <param name="url">呼出すダイアログのurl</param>
            /// <param name="name">呼び出すダイアログの定義名</param>
            /// <param name="closed">ダイアログを閉じたときの挙動</param>

            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            csvDialog.dlg({
                url: "Dialog/CsvUploadDialog.aspx",
                name: "CsvUploadDialog",
                closed: function (e, data) {
                    alert(JSON.stringify(data));
                }
            });

            fixedDialog.dlg();

            categoryDialog.dlg({
                url: "Dialog/CategoryDialog.aspx",
                name: "CategoryDialog",
                closed: function (e, data) {
                    if (data == "canceled") {
                        return;
                    } else {
                        $(".search-criteria [name='categoryCode']").val(data);
                    }
                }
            });

            categoryDialog2.dlg({
                url: "Dialog/CategoryDialog.aspx",
                name: "CategoryDialog",
                closed: function (e, data, data2) {
                    if (data == "canceled") {
                        return;
                    } else {
                        $(".search-criteria [name='categoryCode2']").val(data);
                        $(".search-criteria [name='categoryName2']").val(data2);
                    }
                }
            });
            // TODO：ここまで

            //// コントロール定義 -- End

            //// 操作制御定義 -- Start
            //// 操作制御定義 -- End

            //// 事前データロード -- Start 
            //// 事前データロード -- End

            //// 検索処理 -- Start
            //// 検索処理 -- End

            //// メッセージ表示 -- Start
            //// メッセージ表示 -- End

            //// データ変更処理 -- Start
            //// データ変更処理 -- End

            //// 保存処理 -- Start
            //// 保存処理 -- End

            //// バリデーション -- Start
            //// バリデーション -- End

            /// <summary>CSVアップロードボタンクリック時のイベント処理を行います。</summary>
            $(".csv-upload-button").on("click", function (e) {
                csvDialog.dlg("open");
            });
            /// <summary>CSVダウンロードボタンクリック時のイベント処理を行います。</summary>
            $(".csv-download-button").on("click", function (e) {
                window.open("../api/CSVFile", '_parent', 'download');
            });

            /// <summary>固定長アップロードボタンクリック時のイベント処理を行います。</summary>
            $(".fixed-upload-button").on("click", function (e) {
                fixedDialogNotifyInfo.clear();
                fixedDialogNotifyAlert.clear();
                $("[name='fixed-file1']").replaceWith('<input type="file" name="fixed-file1" id="fixed-file1" />');
                $("[name='fixed-file2']").replaceWith('<input type="file" name="fixed-file2" id="fixed-file2" />');

                fixedDialog.dlg("open");
            });
            /// <summary>固定長アップロードダイアログのアップロードボタンクリック時のイベント処理を行います。</summary>
            $(".fixed-upload-dialog .dlg-upload-button").on("click", function (e) {
                fixedDialogNotifyInfo.clear();
                fixedDialogNotifyAlert.clear();
                fixedDialogNotifyInfo.message(pageLangText.uploading.text).show();

                $(".fixed-upload-form").uploadfile({
                    url: "../api/FixedFile"
                }).done(function (result) {
                    fixedDialogNotifyInfo.message(pageLangText.successMessage.text).show();
                    setTimeout(function () { fixedDialog.dlg("close"); }, 500);
                }).fail(function (result) {
                    fixedDialogNotifyInfo.clear();
                    fixedDialogNotifyAlert.message(result.message).show();
                    //                    setTimeout(function () { fixedDialog.dlg("close"); }, 500);
                });
            });
            // <summary>固定長アップロードダイアログのキャンセルボタンクリック時のイベント処理を行います。</summary>
            $(".fixed-upload-dialog .dlg-upload-cancel-button").on("click", function (e) {
                fixedDialog.dlg("close");
            });
            /// <summary>固定長ダウンロードボタンクリック時のイベント処理を行います。</summary>
            $(".fixed-download-button").on("click", function (e) {
                window.open("../api/FixedFile", '_parent', 'download');
            });

            /// <summary>カテゴリコード検索ボタンクリック時のイベント処理を行います。</summary>
            $("#category-button").on("click", function (e) {
                var option = {id: 'category1', multiselect: true}; // 他に渡したいパラメータがあればoptionの中に追加可能。idとmultiselectは共通
                categoryDialog.dlg("open", option);
            });

            /// <summary>カテゴリコード検索ボタンクリック時のイベント処理を行います。</summary>
            $("#category-button2").on("click", function (e) {
                var option = {id: 'category2', multiselect: false};
                categoryDialog2.dlg("open", option);
            });

        });
    </script>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <!-- 画面デザイン -- Start -->
    <!-- 検索条件と検索ボタン -->
    <div class="content-part search-criteria">
        <h3 class="part-header" data-app-text="codeSearchDialog"></h3>
        <div class="part-body">
            <ul class="item-list item-command">
                <!-- TODO: 画面の仕様に応じて以下の検索条件を変更してください。-->
                <li>
                    <label>
                        <span class="item-label" data-app-text="categoryCode"></span>
                        <input type="text" name="categoryCode" />
                        <button type="button" class="dialog-button" id="category-button">
                            <span class="icon"></span><span data-app-text="codeSearch"></span>
                        </button>
                    </label>
                </li>
                <li>
                    <label>
                        <span class="item-label" data-app-text="categoryCode"></span>
                        <input type="text" name="categoryCode2" />
                        <button type="button" class="dialog-button" id="category-button2">
                            <span class="icon"></span><span data-app-text="codeSearch"></span>
                        </button>
                    </label>
                    <input type="text" name="categoryName2" class="readonly-txt" readonly="readonly"/>
                </li>
                <!-- TODO: ここまで -->
            </ul>
        </div>
    </div>
    <!-- 画面デザイン -- End -->
</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="FooterContent" runat="server">
    <!-- 画面デザイン -- Start -->

    <!-- 画面アーキテクチャ共通のデザイン -- Start -->
    <div class="command" style="left: 1px;">
        <!-- TODO: 画面の仕様に応じて以下のボタンを変更してください。 -->
        <button type="button" class="csv-upload-button" name="csv-upload-button">
            <span data-app-text="csvupload"></span></button>
        <button type="button" class="csv-download-button" name="csv-download-button">
            <span data-app-text="csvdownload"></span></button>
        <button type="button" class="fixed-upload-button" name="fixed-upload-button">
            <span data-app-text="fixedupload"></span></button>
        <button type="button" class="fixed-download-button" name="fixed-download-button">
            <span data-app-text="fixeddownload"></span></button>
        <!-- TODO: ここまで -->
    </div>
    <div class="command" style="right: 9px;">
    </div>
    <!-- 画面アーキテクチャ共通のデザイン -- End -->

    <!-- 画面デザイン -- End -->
</asp:Content>
<asp:Content ID="Content5" ContentPlaceHolderID="DialogsContent" runat="server">
    <!-- 画面デザイン -- Start -->

    <!-- ダイアログ固有のデザイン -- Start -->

    <!-- TODO: 画面の仕様に応じて以下のダイアログの設定を変更してください。 -->
    <div class="csv-upload-dialog">
    </div>
    <!-- TODO: ここまで  -->

    <!-- TODO: 画面の仕様に応じて以下のダイアログの設定を変更してください。 -->
    <div class="category-dialog">
    </div>
    <div class="category-dialog2">
    </div>
    <!-- TODO: ここまで  -->

    <!-- TODO: 画面の仕様に応じて以下のダイアログの設定を変更してください。 -->
    <div class="fixed-upload-dialog">
        <div class="dialog-header">
            <h4 data-app-text="fixedTitle"></h4>
        </div>
        <div class="dialog-body" style="padding: 10px; width: 100%;">
            <div class="part-body fixed-upload-form">
                <ul class="item-list">
                    <li>
                        <label>
                            <span class="item-label" data-app-text="file1"></span>
                            <input type="file" name="fixed-file1" id="fixed-file1" />
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="file2"></span>
                            <input type="file" name="fixed-file2" id="fixed-file2" />
                        </label>
                    </li>
                </ul>
            </div>
        </div>
    <!-- TODO: ここまで  -->
        <div class="dialog-footer">
            <div class="command" style="position: absolute; left: 10px; top: 5px">
                <button class="dlg-upload-button" name="dlg-upload-button" data-app-text="upload"></button>
            </div>
            <div class="command" style="position: absolute; right: 5px; top: 5px;">
                <button class="dlg-upload-cancel-button" name="dlg-upload-cancel-button" data-app-text="cancel"></button>
            </div>
        </div>
        <div class="message-area dialog-slideup-area" >
            <div class="alert-message" style="display: none" data-app-text="title:alertTitle" >
                <ul>        
                </ul>
            </div>
            <div class="info-message" style="display: none" data-app-text="title:infoTitle" >
                <ul>
                </ul>
            </div>
        </div>
    </div>
    <!-- ダイアログ固有のデザイン -- End -->

    <!-- 画面デザイン -- End -->
</asp:Content>