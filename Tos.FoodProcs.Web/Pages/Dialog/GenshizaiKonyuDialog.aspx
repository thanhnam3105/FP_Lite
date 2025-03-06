<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="GenshizaiKonyuDialog.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.Dialog.GenshizaiKonyuDialog" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <style type="text/css">
        /* 画面デザイン -- Start */
        .dialog-content .item-label {
            width: 9em !important;
            line-height: 180%;
        }
        .dialog-content .item-input
        {
            width: 12em;
            line-height: 180%;
        }
        .dialog-content .dialog-search-criteria
        {
            border: solid 1px #efefef;
            padding-top: 0.5em;
            padding-left: 0.5em;
        }
        .dialog-content .dialog-search-criteria .part-footer
        {
            margin-top: 1em;
            margin-left: .5em;
            margin-right: .5em;
            position: relative;
            height: 40px;
            border-top: solid 1px #dbdbdb;
        }
        .dialog-content .dialog-search-criteria .part-footer .command
        {
            /*position: absolute;*/
            display: inline-block;
            right: 0;
        }
        .dialog-content .dialog-result-list
        {
            margin-top: 10px;
        }
        .dialog-content .dialog-search-criteria .part-footer .command button
        {
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
        $.dlg.register("GenshizaiKonyuDialog", {
            initialize: function (context) {
                //// 変数宣言 -- Start
                var elem = context.element,
                    pageLangText = App.ui.pagedata.lang(App.ui.page.lang),
                    param_cd_hinmei = context.data.param1;

                // 品名コードの設定
                $("#cd-hinmei").text(param_cd_hinmei);

                // パラメータからmultiselectを設定
                var multiselect = false;
                if (context.data.multiselect) {
                    multiselect = context.data.multiselect;
                }

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

                var dialog_grid = elem.find("#dialog-list"),
                    querySettingDialog = { skip: 0, top: 500, count: 0 },
                    isDialogLoading = false;

                // パラメータからグリッドのIDを設定
                dialog_grid.attr("id", context.data.id);

                /// <summary>クエリオブジェクトの設定</summary>
                var queryDialog = function () {
                    var criteria = elem.find(".dialog-search-criteria").toJSON();
                    var query = {
                        url: "../api/GenshizaiKonyuDialog"
                        , cd_hinmei: param_cd_hinmei
                        , flg_mishiyo: pageLangText.shiyoMishiyoFlg.text
                        , nm_torihiki: encodeURIComponent(criteria.nm_torihiki)
                        , skip: querySettingDialog.skip
                        , top: querySettingDialog.top
                        , inlinecount: "allpages"
                    }
                    return query;
                };

                var searchItemsDialog = function (_query) {
                    if (isDialogLoading === true) {
                        return;
                    }
                    isDialogLoading = true;

                    App.ajax.webget(
                        App.data.toWebAPIFormat(_query)
                    ).done(function (result) {
                        // データバインド
                        bindDataDialog(result);
                    }).fail(function (result) {
                        dialogNotifyInfo.message(result.message).show();
                    }).always(function () {
                        isDialogLoading = false;
                    });
                };

                var clearStateDialog = function () {
                    // データクリア
                    dialog_grid.clearGridData();
                    querySettingDialog.skip = 0;
                    querySettingDialog.count = 0;
                    displayCountDialog();
                    // 情報メッセージのクリア
                    dialogNotifyInfo.clear();
                    // エラーメッセージのクリア
                    dialogNotifyAlert.clear();
                };

                /// <summary>データ取得件数を表示します。</summary>
                var displayCountDialog = function () {
                    $(".list-count-dialog").text(
                        App.str.format("{0}/{1}", querySettingDialog.skip, querySettingDialog.count)
                    );
                };

                /// <summary>データをバインドします。</summary>
                /// <param name="result">検索結果</param>
                var bindDataDialog = function (result) {
                    var resultCount = parseInt(result.length);
                    clearStateDialog();
                    querySettingDialog.skip = querySettingDialog.skip + result.length;
                    querySettingDialog.count = resultCount;

                    // TODO：検索結果が上限数を超えていた場合
                    if (resultCount > querySettingDialog.top) {
                        // 上限数を超えた検索結果は削除する
                        result.splice(querySettingDialog.top, resultCount);
                        querySettingDialog.skip = result.length;
                        dialogNotifyAlert.message(pageLangText.limitOver.text).show();
                    }
                    // TODO：上限数チェック：ここまで

                    // グリッドの表示件数を更新
                    dialog_grid.setGridParam({ rowNum: querySettingDialog.skip });
                    displayCountDialog();
                    // データバインド
                    var currentData = dialog_grid.getGridParam("data").concat(result);
                    dialog_grid.setGridParam({ data: currentData }).trigger('reloadGrid', [{ current: true}]);
                    // 取得完了メッセージの表示
                    if (querySettingDialog.count <= 0) {
                        dialogNotifyAlert.message(pageLangText.notFound.text).show();
                    }
                    else {
                        dialogNotifyInfo.message(
                            App.str.format(pageLangText.searchResultCount.text, querySettingDialog.skip, querySettingDialog.count)
                        ).show();
                    }
                };

                // ダイアログ内のグリッド定義
                dialog_grid.jqGrid({
                    colNames: [
                    // 隠し項目：品名コード
                        pageLangText.cd_hinmei.text,
                    // 明細/優先番号
                        pageLangText.juni_yusen.text,
                    // 明細/コード(物流)
                        pageLangText.cd_torihiki_butsu.text,
                    // 明細/取引先名(物流)
                        pageLangText.nm_torihiki_butsu.text,
                    // 明細/コード(商流)
                        pageLangText.cd_torihiki_sho.text,
                    // 明細/取引先名(商流)
                        pageLangText.nm_torihiki_sho.text
                    ],
                    colModel: [
                    // 隠し項目：品名コード
                        {name: 'cd_hinmei', width: 0, hidden: true, hidedlg: true },
                    // 明細/優先番号
                        {name: 'juni_yusen', width: 55, sorttype: "int", align: "right" },
                    // 明細/コード(物流)
                        {name: 'cd_torihiki_butsu', width: 105, sorttype: "text", align: "left" },
                    // 明細/取引先名(物流)
                        {name: 'nm_torihiki_butsu', width: 155, sorttype: "text", align: "left" },
                    // 明細/コード(商流)
                        {name: 'cd_torihiki_sho', width: 125, sorttype: "text", align: "left" },
                    // 明細/取引先名(商流)
                        {name: 'nm_torihiki_sho', width: 155, sorttype: "text", align: "left" }
                    ],
                    datatype: "local",
                    shrinkToFit: false,
                    multiselect: multiselect,
                    rownumbers: true,
                    hoverrows: false,
                    height: 150,
                    loadComplete: function () {
                        // グリッドの先頭行選択：loadCompleteに記述しないとグリッドのソートで先頭行が選択されない
                        dialog_grid.setSelection(1, false);
                    },
                    ondblClickRow: function (rowid) {
                        var returnCode = returnSelectedDialog();
                        if (returnCode != "noSelect") {
                            context.close(returnCode);
                        }
                    }
                });

                /// <summary>選択したコードを書き出します</summary>
                var returnSelectedDialog = function () {
                    var selArray;
                    if (dialog_grid.getGridParam("multiselect")) {
                        selArray = dialog_grid.jqGrid("getGridParam", "selarrrow");
                        if (!App.isArray(selArray) || selArray.length == 0) {
                            dialogNotifyInfo.message(pageLangText.noSelect.text).show();
                            return "noSelect";
                        }
                    } else {
                        selArray = [];
                        selArray[0] = dialog_grid.jqGrid("getGridParam", "selrow");
                        if (selArray[0] == null || selArray.length == 0) {
                            dialogNotifyInfo.message(pageLangText.noSelect.text).show();
                            return "noSelect";
                        }
                    }
                    var row,
                        selHinCode = [],
                        selJuni = [],
                        selToriCode = [],
                        selToriName = [],
                        selToriCode2 = [],
                        selToriName2 = [];
                    for (var i = 0; i < selArray.length; i++) {
                        row = dialog_grid.jqGrid("getRowData", selArray[i]);
                        // 選択された明細行の各項目を配列に設定する
                        selHinCode.push(row.cd_hinmei);
                        selJuni.push(row.juni_yusen);
                        selToriCode.push(row.cd_torihiki_butsu);
                        selToriName.push(row.nm_torihiki_butsu);
                        selToriCode2.push(row.cd_torihiki_sho);
                        selToriName2.push(row.nm_torihiki_sho);
                    }
                    // 選択された明細行の各項目を返却する
                    return [selHinCode.join(", "),
                            selJuni.join(", "),
                            selToriCode.join(", "),
                            selToriName.join(", "),
                            selToriCode2.join(", "),
                            selToriName2.join(", ")];
                };

                /// <summary>ダイアログの検索ボタンクリック時のイベント処理を行います。</summary>
                elem.find(".dlg-find-button").on("click", function () {
                    clearStateDialog();
                    searchItemsDialog(new queryDialog());
                });

                // <summary>ダイアログの閉じるボタンクリック時のイベント処理を行います。</summary>
                elem.find(".dlg-close-button").on("click", function () {
                    context.close("canceled");
                });

                // <summary>ダイアログの選択ボタンクリック時のイベント処理を行います。</summary>
                elem.find(".dlg-select-button").on("click", function () {
                    var returnCode = returnSelectedDialog();
                    if (returnCode != "noSelect") {
                        context.close(returnCode);
                    }
                });

                /// <summary>ダイアログを開きます。</summary>
                this.reopen = function (option) {
                // ダイアログ再オープン時の処理
                    clearStateDialog();
                    // 品名コードの設定
                    param_cd_hinmei = option.param1;
                    $("#cd-hinmei").text(param_cd_hinmei);
                    $("#con_nm_torihiki").val("");
                    searchItemsDialog(new queryDialog());
                };

                // 初回検索処理
                // loadCompleteで実施するとグリッドのソート毎に検索後のメッセージが表示されてしまう為、初回読み込みの一番最後に検索処理を実施する
                searchItemsDialog(new queryDialog());
            }
        });
    </script>
</head>
<body>
    <!-- ダイアログ固有のデザイン -- Start -->
    <div class="dialog-content">
        <div class="dialog-header">
            <h4 data-app-text="genshizaikonyuDialog">
            </h4>
        </div>
        <div class="dialog-body" style="padding: 10px; width: 95%;">
            <div class="dialog-search-criteria">
                <div class="part-body" >
                    <ul class="item-list">
                        <li>
                            <!-- 品名コード -->
                            <span class="item-label" data-app-text="con_cd_hinmei"></span>
                            <span class="item-label" id="cd-hinmei"></span>
                        </li>
                        <li>
                            <label>
                                <span class="item-label" data-app-text="torihikisakiName"></span>
                                <input type="text" id="con_nm_torihiki" name="nm_torihiki" style="width: 300px;" maxlength="50" />
                            </label>
                        </li>
                    </ul>
                </div>
                <div class="part-footer">
                    <div class="command">
                        <button class="dlg-find-button" name="dlg-find-button" data-app-text="search"></button>
                    </div>
                </div>
            </div>
            <div class="dialog-result-list">
                <!-- グリッドコントロール固有のデザイン -- Start -->
                <h3 id="listHeader" class="part-header">
                    <span data-app-text="resultList" style="padding-right: 10px; padding-bottom: 4px;" id="list-results"></span>
                    <span class="list-count list-count-dialog" id="list-count"></span>
                </h3>
                <div class="part-body" style="height: 180px;">
                    <table id="dialog-list">
                    </table>
                </div>
            </div>
        </div>
        <div class="dialog-footer">
            <!-- ボタン：選択 -->
            <div class="command" style="position: absolute; left: 10px; top: 5px">
                <button class="dlg-select-button" name="dlg-select-button" data-app-text="select">
                </button>
            </div>
            <!-- ボタン：閉じる -->
            <div class="command" style="position: absolute; right: 10px; top: 5px;">
                <button class="dlg-close-button" name="dlg-close-button" data-app-text="close">
                </button>
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
