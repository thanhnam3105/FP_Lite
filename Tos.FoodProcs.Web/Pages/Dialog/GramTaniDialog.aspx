<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="GramTaniDialog.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.Dialog.GramTaniDialog" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <style type="text/css">
        /* 画面デザイン -- Start */
        .dialog-content .item-label {
            width: 8em;
            line-height: 180%;
        }
        .dialog-content .item-input {
            width: 12em;
            line-height: 180%;
        }
        .dialog-content .dialog-search-criteria {
            border: solid 1px #efefef;
            padding-top: 0.5em;
            padding-left: 0.5em;
        }
        .dialog-content .dialog-search-criteria .part-footer {
            margin-top: 1em;
            margin-left: .5em;
            margin-right: .5em;
            position: relative;
            height: 40px;
            border-top: solid 1px #dbdbdb;
        }
        .dialog-content .dialog-search-criteria .part-footer .command {
          position: absolute;
          display: inline-block;
          right: 0;
        }
        .dialog-content .dialog-result-list {
            margin-top: 10px;
        }
        .dialog-content .dialog-search-criteria .part-footer .command button {
          position: relative;
          margin-left: .5em;
          top: 5px;
          padding: 0px;
          min-width: 100px;
          margin-right: 0;
        }
        /* 画面デザイン -- End */
    </style>
    <script type="text/javascript" >
        $.dlg.register("GramTaniDialog", {
            initialize: function (context) {
                //// 変数宣言 -- Start
                var elem = context.element,
                    pageLangText = App.ui.pagedata.lang(App.ui.page.lang),
                    paramNonyu = context.data.param;
                // ダイアログ情報メッセージの設定
                var dialogNotifyInfo = App.ui.notify.info(elem, {
                    container: elem.find(".dialog-slideup-area .info-message"),
                    messageContainerQuery: "ul",
                    show: function () {
                        elem.find(".info-message").show();
                    },
                    clear: function () {
                        elem.find(".info-message").hide();
                    }
                });
                // ダイアログ警告メッセージの設定
                var dialogNotifyAlert = App.ui.notify.alert(elem, {
                    container: elem.find(".dialog-slideup-area .alert-message"),
                    messageContainerQuery: "ul",
                    show: function () {
                        elem.find(".alert-message").show();
                    },
                    clear: function () {
                        elem.find(".alert-message").hide();
                    }
                });

                var dialog_grid = elem.find(".dialog-result-list [name='dialog-list']"),
                    wtNonyu = $("#id_gramWtNonyu"); // 一個の量
                // パラメータからグリッドのIDを設定
                dialog_grid.attr("id", context.data.id);

                // ダイアログ内のグリッド定義
                dialog_grid.jqGrid({
                    colNames: [
                        pageLangText.gramWtNonyu.text
                    ],
                    colModel: [
                        { name: 'gramWtNonyu', width: 100, align: "center" }
                    ],
                    datatype: "local",
                    shrinkToFit: false,
                    height: 240
                });

                //// カンマ区切り処理
                var splitComma = function (str) {
                    str = str.replace(/,/g, '');
                    if (str.match(/^(|-)[0-9]+$/)) {
                        str = str.replace(/^[0]+([0-9]+)/g, '$1');
                        str = str.replace(/([0-9]{1,3})(?=(?:[0-9]{3})+$)/g, '$1,');
                    }
                    return str;
                };
                //// 「一個の量」をカンマ区切りで表示する
                var setComma = function () {
                    var nonyu = wtNonyu.val();
                    var val = nonyu.indexOf(".", 0);
                    if (val == -1) {
                        var str = splitComma(nonyu);
                        wtNonyu.val(str);
                    }
                    else {
                        var splitVal = nonyu.split('.');
                        var result = splitComma(splitVal[0]);
                        wtNonyu.val(result + "." + splitVal[1]);
                    }
                };

                //// 選択行の「一個の量(Kg)」を初期値として設定する
                var setInitialValue = function () {
                    var param = paramNonyu;
                    if (param == "") {
                        param = 0;
                    }
                    var value = parseFloat(param) * 1000;
                    wtNonyu.val(value.toFixed(3));
                    setComma(); // カンマ区切りで表示
                };
                setInitialValue();

                //// 入力項目のチェック
                var checkWtNonyu = function () {
                    if (checkLength(wtNonyu.val())) {
                        wtNonyu.css({ "border": "solid 1px", "border-color": "" });
                    }
                    else {
                        wtNonyu.css({ "border": "solid 2px", "border-color": "#FF6666" });
                        return false;
                    }
                    return true;
                };

                var clearStateDialog = function () {
                    // データクリア
                    wtNonyu.val("");
                    wtNonyu.css({ "border": "solid 1px", "border-color": "" });
                    // 情報メッセージのクリア
                    dialogNotifyInfo.clear();
                    // エラーメッセージのクリア
                    dialogNotifyAlert.clear();
                };

                /// <summary>入力した数値を画面に戻します。</summary>
                var returnSelectedDialog = function () {
                    var gramWtNonyu = wtNonyu.val();
                    var result = 0;

                    // カンマ区切り除去
                    gramWtNonyu = gramWtNonyu.replace(/,/g, '');

                    if (!App.isNumeric(gramWtNonyu)) {
                        result = "0";  // 文字列の0として返却しないと、objectとして返却されてしまいNaNとなる為
                    }
                    else {
                        gramWtNonyu = parseFloat(gramWtNonyu) / 1000;
                        result = gramWtNonyu.toFixed(6);
                    }

                    return result;
                };

                // <summary>ダイアログのキャンセルボタンクリック時のイベント処理を行います。</summary>
                elem.find(".dlg-cancel-button").on("click", function () {
                    context.close("canceled");
                });

                // <summary>ダイアログのOKボタンクリック時のイベント処理を行います。</summary>
                elem.find(".dlg-ok-button").on("click", function () {
                    // 入力内容のチェック
                    dialogNotifyAlert.clear();
                    // 検索前バリデーション
                    var result = $(".dialog-body .item-list").validation().validate();
                    if (result.errors.length) {
                        return;
                    }

                    var returnCode = returnSelectedDialog();
                    if (returnCode != "noSelect") {
                        context.close(returnCode);
                    }
                });

                // <summary>入力項目に関する各イベント処理</summary>
                wtNonyu
                .focusout(function () {
                    // 値が空の場合、0を設定する
                    var val = wtNonyu.val();
                    if (App.isUndefOrNull(val) || val == "") {
                        wtNonyu.val(0);
                    }
                    // カンマ区切り付与
                    setComma();
                })
                .focusin(function () {
                    // カンマ区切りを外す
                    var str = wtNonyu.val();
                    str = str.replace(/,/g, '');
                    wtNonyu.val(str);
                });

                /// バリデーション
                /// <summary>検索バリデーションの初期化</summary>
                var searchValidation = Aw.validation({
                    items: App.ui.pagedata.validation(App.ui.page.lang),
                    handlers: {
                        success: function (results) {
                            var i = 0, l = results.length;
                            for (; i < l; i++) {
                                dialogNotifyAlert.remove(results[i].element);
                            }
                        },
                        error: function (results) {
                            var i = 0, l = results.length;
                            for (; i < l; i++) {
                                dialogNotifyAlert.message(results[i].message, results[i].element).show();
                            }
                        }
                    }
                });
                $(".dialog-body .item-list").validation(searchValidation);

                /// <summary>ダイアログを開きます。</summary>
                this.reopen = function (option) {
                    paramNonyu = option.param;
                    dialogNotifyInfo.clear();
                    dialogNotifyAlert.clear();
                    clearStateDialog();
                    setInitialValue();
                };
            }
        });
    </script>
</head>
<body>
    <!-- ダイアログ固有のデザイン -- Start -->
    <div class="dialog-content">
        <!-- TODO: 画面の仕様に応じて以下のダイアログの設定を変更してください。 -->
            <div class="dialog-header">
                <h4 data-app-text="gramTaniDialog"></h4>
            </div>
            <div class="dialog-body" style="padding: 10px; width: 95%;">
                <div class="dialog-search-criteria">
                    <div class="part-body" >
                        <ul class="item-list">
                            <li>
                                <label>
                                    <span class="item-label" data-app-text="gramWtNonyu"></span>
                                </label>
                            </li>
                            <li>
                                <label>
                                    <input type="text" id="id_gramWtNonyu" name="gramWtNonyu" style="width: 150px; text-align:right;" data-app-validation="gramWtNonyu" maxlength="13" />ｇ
                                </label>
                            </li>
                            <li>
                                <label>
                                    <span class="item-label" data-app-text="gramMsg" style="width: 95%; color: #ff0000;"></span>
                                </label>
                            </li>
                        </ul>
                    </div>
                </div>
            </div>
        <!-- TODO: ここまで  -->
            <div class="dialog-footer">
                <div class="command" style="position: absolute; left: 10px; top: 5px">
                    <button class="dlg-ok-button" name="dlg-ok-button" data-app-text="ok"></button>
                </div>
                <div class="command" style="position: absolute; right: 5px; top: 5px;">
                    <button class="dlg-cancel-button" name="dlg-cancel-button" data-app-text="cancel"></button>
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

</body>
</html>
