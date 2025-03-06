<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="GokeiHyojiDialog.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.Dialog.GokeiHyojiDialog" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <style type="text/css">
        /* 画面デザイン -- Start */
        
        /* TODO：画面の仕様に応じて以下のスタイルを変更してください。 */
        .dialog-content .item-label
        {
            width: 8em;
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
            position: absolute;
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
        /* TODO：ここまで */
        
        /* 画面デザイン -- End */
    </style>
    <script type="text/javascript">
        // TODO：画面の仕様に応じて以下のダイアログ名を変更してください。
        $.dlg.register("GokeiHyojiDialog", {
            // TODO：ここまで
            initialize: function (context) {
                //// 変数宣言 -- Start
                var elem = context.element
                    , lang = App.ui.page.lang
                    , isFirstLoad = true // 初回起動時
                    , pageLangText = App.ui.pagedata.lang(App.ui.page.lang);

                // パラメータからmultiselectを設定
                var multiselect = false;
                if (context.data.multiselect) {
                    multiselect = context.data.multiselect;
                }
                var searchHidukeFrom = context.data.param1,
                    searchHidukeTo = context.data.param2,
                    todayHiduke = context.data.param3,
                    shokubaCode = context.data.param4,
                    lineCode = context.data.param5,
                    selectSearchHiduke = context.data.param6,
                    selectShokubaName = context.data.param7,
                    selectLineName = context.data.param8;


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
				    querySettingDialog = { skip: 0, top: 500, count: 0 },
				    isDialogLoading = false,
				    lastScrollTopDialog = 0;
                // パラメータからグリッドのIDを設定
                dialog_grid.attr("id", context.data.id);

                /// <summary>データ取得件数を表示します。</summary>
                var displayCountDialog = function () {
                    $(".list-count-dialog").text(
                        App.str.format("{0}/{1}", querySettingDialog.skip, querySettingDialog.count)
                    );
                };

                var clearStateDialog = function () {
                    // データクリア
                    dialog_grid.clearGridData();
                    querySettingDialog.skip = 0;
                    querySettingDialog.count = 0;
                    lastScrollTopDialog = 0;
                    displayCountDialog();
                    // 情報メッセージのクリア
                    dialogNotifyInfo.clear();
                    // エラーメッセージのクリア
                    dialogNotifyAlert.clear();
                };

                /// <summary>クエリオブジェクトの設定<summary>
                var queryDialog = function () {
                    var query = {
                        // TODO: 画面の仕様に応じて以下のエンドポイントを変更してください。
                        url: "../api/GokeiHyoji",
                        cd_shokuba: shokubaCode,
                        cd_line: lineCode,
                        flg_jisseki: pageLangText.jissekiYojitsuFlg.text,
                        dt_hiduke_from: searchHidukeFrom,
                        dt_hiduke_to: searchHidukeTo,
                        dt_hiduke_today: todayHiduke,
                        // 件数の条件
                        skip: querySettingDialog.skip,
                        top: querySettingDialog.top
                        // TODO：ここまで

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
                        $("#selectSearchHiduke").text(selectSearchHiduke);
                        $("#selectShokubaName").text(selectShokubaName);
                        $("#selectLineName").text(selectLineName);
                        bindDataDialog(result);
                    }).fail(function (result) {
                        dialogNotifyInfo.message(result.message).show();
                    }).always(function () {
                        isDialogLoading = false;
                    });
                };

                // ダイアログ内のグリッド定義
                dialog_grid.jqGrid({
                    // todo：画面の仕様に応じて以下の列名の定義を変更してください。
                    colNames: [
                        pageLangText.cd_seihin_dlg.text,
                        pageLangText.nm_seihin_dlg.text,
                        pageLangText.nm_gokei_dlg.text
                    ],
                    // todo：ここまで
                    // todo：画面の仕様に応じて以下の列モデルの定義を変更してください。
                    colModel: [
                        { name: 'cd_hinmei', width: 115, align: "left" },
                        { name: 'nm_hinmei_' + lang, width: 240, align: "left" },
                        { name: 'su_seizo', width: 150, align: "right" }
                    ],
                    // todo：ここまで
                    datatype: "local",
                    shrinktofit: false,
                    multiselect: multiselect,
                    rownumbers: false,
                    height: 150,
                    loadComplete: function () {
                        if (isFirstLoad) {
                            isFirstLoad = false;
                            $(searchItemsDialog(new queryDialog()));
                        }
	                    if (!multiselect) {
	                        // 複数行選択をしない場合
	                        // グリッドの先頭行選択：loadCompleteに記述しないとグリッドのソートで先頭行が選択されない
	                        dialog_grid.setSelection(1, false);
	                    }
                    }
                });

                /// <summary>データをバインドします。</summary>
                /// <param name="result">検索結果</param>
                var bindDataDialog = function (result) {
                    querySettingDialog.skip = querySettingDialog.skip + result.d.length;
                    querySettingDialog.count = parseInt(result.__count);
                    // グリッドの表示件数を更新
                    dialog_grid.setGridParam({ rowNum: querySettingDialog.skip });
                    displayCountDialog(querySettingDialog.count, querySettingDialog.count);
                    // データバインド
                    var currentData = dialog_grid.getGridParam("data").concat(result.d);
                    dialog_grid.setGridParam({ data: currentData }).trigger('reloadGrid', [{ current: true}]);
                    // 取得完了メッセージの表示
                    dialogNotifyInfo.message(
						App.str.format(pageLangText.searchResultCount.text, querySettingDialog.skip,
						querySettingDialog.count)).show();
                };

                /// <summary>後続データ検索を行います。</summary>
                /// <param name="target">グリッド</param>
                var nextSearchItemsDialog = function (target) {
                    var scrollTopDialog = lastScrollTopDialog;
                    if (scrollTopDialog == target.scrollTop) {
                        return;
                    }
                    if (querySettingDialog.skip === querySettingDialog.count) {
                        return;
                    }
                    lastScrollTopDialog = target.scrollTop;
                    if (target.scrollHeight - target.scrollTop <= $(target).outerHeight()) {
                        // データ検索
                        searchItemsDialog(new queryDialog());
                    }
                };
                /// <summary>グリッドスクロール時のイベント処理を行います。</summary>
                elem.find(".ui-jqgrid-bdiv").scroll(function (e) {
                    // 後続データ検索
                    nextSearchItemsDialog(this);
                });


                /// <summary>検索条件をクリアします</summary>
                var clearCriteriaDialog = function () {
                    var criteria = elem.find(".dialog-search-criteria");
                    var controls = criteria.find("*").not(":button");
                    $.each(controls, function () {
                        var control = $(this);
                        if (control.is(":text")) {
                            control.val("");
                        }
                        if (control.is(":checkbox")) {
                            control.attr("checked", false);
                        }
                        if (control.is("select")) {
                            control.find("option[selected='selected']").removeAttr("selected");
                            control.find("option:first").attr("selected", "selected");
                        }
                    });
                    // TODO：画面の仕様に応じて検索条件の初期値を設定してください。
                    // gridのmultiselect all select row 用checkbox のクリア
                    elem.find("#cb_" + dialog_grid[0].id).attr("checked", false);
                    // TODO：ここまで
                };

                /// <summary>選択したコードを書き出します</summary>
                var returnSelectedDialog = function () {
                    var selArray;
                    if (dialog_grid.getGridParam("multiselect")) {
                        selArray = dialog_grid.jqGrid("getGridParam", "selarrrow");
                        if (!App.isArray(selArray) || selArray.length == 0) {
                            dialogNotifyInfo.message(pageLangText.noSelect.text).show();
                            return "noSelect";
                        }
                    }
                    else {
                        selArray = [];
                        selArray[0] = dialog_grid.jqGrid("getGridParam", "selrow");
                        if (selArray[0] == null || selArray.length == 0) {
                            dialogNotifyInfo.message(pageLangText.noSelect.text).show();
                            return "noSelect";
                        }
                    }
                    var row,
                        selCode = [],
                        selName = [];
                    // TODO：画面の仕様に応じて返却文字列を指定してください。
                    for (var i = 0; i < selArray.length; i++) {
                        row = dialog_grid.jqGrid("getRowData", selArray[i]);
                        selCode.push(row.cd_line);
                        selName.push(row.nm_line);
                    }
                    // TODO：ここまで
                    return [selCode.join(", "), selName.join(", ")];
                };

                // <summary>ダイアログの閉じるボタンクリック時のイベント処理を行います。</summary>
                elem.find(".dlg-close-button").on("click", function () {
                    context.close("canceled");
                });

                /// <summary>ダイアログを開きます。</summary>
                this.reopen = function (option) {
                    dialogNotifyInfo.clear();
                    dialogNotifyAlert.clear();
                    clearCriteriaDialog();
                    clearStateDialog();
                    // 条件をセット
                    searchHidukeFrom = option.param1,
                    searchHidukeTo = option.param2,
                    todayHiduke = option.param3,
                    shokubaCode = option.param4,
                    lineCode = option.param5,
    				selectSearchHiduke = option.param6,
                    selectShokubaName = option.param7,
                    selectLineName = option.param8;
                    searchItemsDialog(new queryDialog());
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
            <h4 data-app-text="gokeiHyojiDialog">
            </h4>
        </div>
        <div class="dialog-body" style="padding: 10px; width: 95%;">
            <div class="dialog-search-criteria">
				<div class="part-body">
					<span id="selectSearchHiduke" data-app-text="searchHiduke"></span>
                    <span>&nbsp;&nbsp;&nbsp;</span>
                    <span id="selectShokubaName" data-app-text="shokubaName"></span>
                    <span>&nbsp;&nbsp;&nbsp;</span>
                    <span id="selectLineName" data-app-text="lineName"></span>
				</div>
			</div>
            <div class="dialog-result-list">
                <!-- グリッドコントロール固有のデザイン -- Start -->
                <h3 id="listHeader" class="part-header">
                    <span data-app-text="resultList" style="padding-right: 10px; padding-bottom: 4px;"
                        id="list-results"></span><span class="list-count list-count-dialog" id="list-count"></span>
                </h3>
                <div class="part-body" style="height: 200px;">
                    <table name="dialog-list">
                    </table>
                </div>
            </div>
        </div>
        <!-- TODO: ここまで  -->
        <div class="dialog-footer">
            <div class="command" style="position: absolute; right: 5px; top: 5px;">
                <button class="dlg-close-button" name="dlg-close-button" data-app-text="close">
                </button>
            </div>
        </div>
        <div class="message-area dialog-slideup-area">
            <div class="alert-message" style="display: none" data-app-text="title:alertTitle">
                <ul>
                </ul>
            </div>
            <div class="info-message" style="display: none" data-app-text="title:infoTitle">
                <ul>
                </ul>
            </div>
        </div>
    </div>
</body>
</html>
