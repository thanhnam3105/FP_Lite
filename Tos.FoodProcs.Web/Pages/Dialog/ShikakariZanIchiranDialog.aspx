<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ShikakariZanIchiranDialog.aspx.cs"
    Inherits="Tos.FoodProcs.Web.Pages.Dialog.ShikakariZanIchiranDialog" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
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
        .dialog-content .dialog-criteria-chomiprint
        {
            border-bottom: solid 1px #efefef;
            border-left: solid 1px #efefef;
            border-top: solid 1px #efefef;
            padding-top: 1em;
            padding-left: 1.5em;
            height: 65px;
        }
        .dialog-content .dialog-criteria-chomiprint .part-footer
        {
            margin-top: 1em;
            margin-right: .5em;
            position: relative;
            height: 40px;
            border-top: solid 1px #dbdbdb;
        }
        .dialog-content .dialog-criteria-chomiprint .part-footer .command
        {
            position: absolute;
            display: inline-block;
            right: 0;
        }
        .dialog-content .dialog-result-list
        {
            margin-top: 10px;
        }
        .dialog-content .dialog-criteria-chomiprint .part-footer .command button
        {
            top: 5px;
            padding: 0px;
            min-width: 100px;
            margin-right: 0;
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
        
        ul.check-hyo-area li
        {
            height: 30px;
        }
        
        /* チェック時の色 */
        
        .checkLabelCol.ui-state-active
        {
            background: #008000;
        }
        
        .checkLabelCol.ui-state-active span.ui-button-text span
        {
            color: #FFFFFF;
        }
        
        .checkedcol
        {
            background: #008000;
            color: #FFFFFF;
        }
        .date_start
        {
            width: 100px;
        }
        .date_end
        {
            width: 100px;
        }
        .date_between
        {
            width: 30px;
        }
        
        /* TODO：ここまで */
        
        /* 画面デザイン -- End */
    </style>
    <script type="text/javascript">
        // TODO：画面の仕様に応じて以下のダイアログ名を変更してください。
        $.dlg.register("shikakariZanIchiranDialog", {
            // TODO：ここまで
            initialize: function (context) {
                var elem = context.element
                , hinmeiCode = context.data.param1
                , seihinName = context.data.param2
                , $shikakariZanCode = elem.find(".cd-hinmei")
                , $shikakariZanName = elem.find(".nm-seihin")
                , multiselect = context.data.multiselect
                , lang = App.ui.page.lang
                , pageLangText = App.ui.pagedata.lang(lang)
                , dialog_grid = elem.find(".dialog-result-list [name='dialog-list']")
                , querySettingDialog = { skip: 0, top: 500, count: 0 }
                , isDialogLoading = false
                , nextScrollTopDialog = 0
                , lastScrollTopDialog = 0
                , datePickerFormat
                , newDateFormat
                , today = new Date()
                // ダイアログ情報メッセージの設定
                , dialogNotifyInfo = App.ui.notify.info(elem, {
                    container: elem.find(".dialog-slideup-area .dialog-info-message"),
                    messageContainerQuery: "ul",
                    show: function () {
                        elem.find(".dialog-info-message").show();
                    },
                    clear: function () {
                        elem.find(".dialog-info-message").hide();
                    }
                })
                // ダイアログ警告メッセージの設定
	            , dialogNotifyAlert = App.ui.notify.alert(elem, {
	                container: elem.find(".dialog-slideup-area .dialog-alert-message"),
	                messageContainerQuery: "ul",
	                show: function () {
	                    elem.find(".dialog-alert-message").show();
	                },
	                clear: function () {
	                    elem.find(".dialog-alert-message").hide();
	                }
	            });


                // パラメータからグリッドのIDを設定
                dialog_grid.attr("id", context.data.id);

                //ラベル初期表示設定
                $shikakariZanCode.text(hinmeiCode + '：');
                $shikakariZanName.text(seihinName);

                //日付の設定
                if (App.ui.page.langCountry !== 'en-US') {
                    datePickerFormat = pageLangText.dateFormat.text;
                    newDateFormat = pageLangText.dateNewFormat.text;

                } else {
                    datePickerFormat = pageLangText.dateFormatUS.text;
                    newDateFormat = pageLangText.dateNewFormatUS.text;
                }

                // ダイアログ内のグリッド定義
                dialog_grid.jqGrid({
                    // TODO：画面の仕様に応じて以下の列名の定義を変更してください。
                    colNames: [
						pageLangText.dt_seizo_dlg.text
						, pageLangText.seizoJissekiDlg_seizoSu.text
						, pageLangText.seizoJissekiDlg_lotNo.text
                        , pageLangText.cd_hinmei_dlg.text
                        , pageLangText.nm_hinmei_dlg.text
					],
                    // TODO：ここまで
                    // TODO：画面の仕様に応じて以下の列モデルの定義を変更してください。
                    colModel: [
						{ name: 'dt_seizo', width: 140, align: "left",
						    formatter: "date",
						    formatoptions: {
						        srcformat: newDateFormat, newformat: newDateFormat
						    }
						},
						{ name: 'su_seizo_jisseki', width: 170, align: "right" },
                        { name: 'no_lot_seihin', width: 170, align: "left" },
                        { name: 'cd_hinmei', width: 170, align: "left", hidden: true },
                        { name: 'nm_hinmei', width: 170, align: "left", hidden: true }
					],
                    // TODO：ここまで
                    datatype: "local",
                    shrinkToFit: false,
                    multiselect: multiselect,
                    rownumbers: false,
                    hoverrows: false,
                    height: 138,
                    gridComplete: function () {
                        dialog_grid.closest(".ui-jqgrid-bdiv").scrollTop(nextScrollTopDialog);
                    },
                    loadComplete: function () {

                        if (!multiselect) {
                            // 複数行選択をしない場合
                            // グリッドの先頭行選択：loadCompleteに記述しないとグリッドのソートで先頭行が選択されない
                            dialog_grid.setSelection(1, false);
                        }
                    },
                    ondblClickRow: function (rowid) {
                        var returnCode = returnSelectedDialog();
                        if (returnCode != "noSelect") {
                            context.close(returnCode);
                        }
                    }
                });


                // TODO：画面の仕様に応じて以下の datepicker の設定を変更してください。
                elem.find("#condition-date-start").on("keyup", App.data.addSlashForDateString);
                elem.find("#condition-date-end").on("keyup", App.data.addSlashForDateString);

                elem.find("#condition-date-start").datepicker({ dateFormat: datePickerFormat });
                elem.find("#condition-date-end").datepicker({ dateFormat: datePickerFormat });

                // 有効範囲：1975/1/1～
                elem.find("#condition-date-start").datepicker("option", 'minDate', new Date(1975, 1 - 1, 1));
                elem.find("#condition-date-end").datepicker("option", 'minDate', new Date(1975, 1 - 1, 1));

                // デフォルト日付を挿入
                elem.find("#condition-date-start").datepicker("setDate", new Date(today.getFullYear(), today.getMonth(), today.getDate() - 7));
                elem.find("#condition-date-end").datepicker("setDate", new Date(today.getFullYear(), today.getMonth(), today.getDate() + 7));


                //ローカル関数設定
                var clearStateDialog = function () {
                    // データクリア
                    dialog_grid.clearGridData();
                    querySettingDialog.skip = 0;
                    querySettingDialog.count = 0;
                    lastScrollTopDialog = 0;
                    nextScrollTopDialog = 0;
                    displayCountDialog();
                    isDialogLoading = false;
                    // 情報メッセージのクリア
                    dialogNotifyInfo.clear();
                    // エラーメッセージのクリア
                    dialogNotifyAlert.clear();
                };

                /// <summary>データ取得件数を表示します。</summary>
                var displayCountDialog = function () {
                    elem.find(".list-count-dialog").text(
						App.str.format("{0}/{1}", querySettingDialog.skip, querySettingDialog.count));
                };

                /// <summary>データをバインドします。</summary>
                /// <param name="result">検索結果</param>
                var bindDataDialog = function (result) {

                    var resultCount = result.d.__count;
                    var resultData = result.d.results;
                    if (App.isUndefOrNull(resultCount)) {
                        // result.d.__countがUndefの場合、ストアド検索なので取得先を変更する
                        resultCount = parseInt(result.__count);
                        resultData = result.d;
                    }
                    querySettingDialog.count = resultCount;

                    // 検索結果が上限数を超えていた場合
                    if (parseInt(resultCount) > querySettingDialog.top) {
                        querySettingDialog.skip = querySettingDialog.top;
                        dialogNotifyAlert.message(MS0011).show();
                    }
                    else {
                        querySettingDialog.skip = resultCount;
                    }

                    // グリッドの表示件数を更新
                    dialog_grid.setGridParam({ rowNum: querySettingDialog.skip });
                    displayCountDialog();
                    // データバインド
                    var currentData = dialog_grid.getGridParam("data").concat(resultData);
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

                /// <summary>検索条件をクリアします</summary>
                var clearCriteriaDialog = function () {
                    // TODO：画面の仕様に応じて検索条件の初期値を設定してください。
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
                    // TODO：ここまで
                };

                /// <summary>日付の整合性チェック</summary>
                var checkDate = function () {
                    var criteria = elem.find(".dialog-search-criteria").toJSON()
                        , seizo_date_start = App.data.getDateTimeStringForQueryNoUtc(criteria.hizuke_from)
                        , seizo_date_end = App.data.getDateTimeStringForQueryNoUtc(criteria.hizuke_to);

                    return (seizo_date_start <= seizo_date_end)
                }



                /// <summary>クエリオブジェクトの設定</summary>
                var queryDialogWeb = function () {
                    var criteria = elem.find(".dialog-search-criteria").toJSON(),
                        urlStr = { url: "../api/ShikakariZanIchiranDialog"
                                   , cd_hinmei: hinmeiCode == null ? "" : encodeURIComponent(hinmeiCode)
                                   , seizo_date_start: App.data.getDateTimeStringForQueryNoUtc(criteria.hizuke_from)
                                   , seizo_date_end: App.data.getDateTimeStringForQueryNoUtc(criteria.hizuke_to)
                                   , lang: lang
                        };
                    return urlStr;
                };

                /// <summary>検索処理の実行</summary>
                var searchItemsDialog = function (_query) {
                    // ローディングの表示
                    App.ui.loading.show(pageLangText.nowProgressing.text, ".dialog-content");

                    isDialogLoading = true;
                    nextScrollTopDialog = elem.find("#shikakariZanIchiranDialog").find(".ui-jqgrid-bdiv").scrollTop();
                    App.ajax.webget(
    	                App.data.toWebAPIFormat(_query)
					).done(function (result) {
					    // データバインド
					    bindDataDialog(result);
					}).fail(function (result) {
					    dialogNotifyAlert.message(result.message).show();
					}).always(function () {
					    // 検索ボタンダブルクリックで検索結果がおかしくならないようsetTimeoutで間を入れる
					    // ＃不要な検索処理が走ってしまう為
					    setTimeout(function () {
					        isDialogLoading = false;
					    }, 500);
					    // ローディングの終了
					    App.ui.loading.close(".dialog-content");
					});
                };

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



                /// <summary>ダイアログの検索ボタンクリック時のイベント処理を行います。</summary>
                elem.find(".dlg-find-button").on("click", function () {
                    clearStateDialog();

                    // バリデーション
                    var result = $(".dialog-body .item-list").validation().validate();
                    if (result.errors.length) {
                        return;
                    }

                    if (!checkDate()) {
                        dialogNotifyAlert.message(App.str.format(pageLangText.startDateOverEndDate.text, pageLangText.startDate.text, pageLangText.endDate.text)).show();
                        return;
                    }
                    searchItemsDialog(new queryDialogWeb());
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

                /// <summary>選択したコードを書き出します</summary>
                var returnSelectedDialog = function () {
                    var selArray;
                    if (dialog_grid.getGridParam("multiselect")) {
                        selArray = dialog_grid.jqGrid("getGridParam", "selarrrow");
                        if (!App.isArray(selArray) || selArray.length == 0) {
                            dialogNotifyInfo.message(pageLangText.noSelect.text).show();
                            return "noSelect";
                        } else if (selArray.length > pageLangText.limitMultiSelect.text) {
                            // error message
                            dialogNotifyInfo.message(
                                App.str.format(pageLangText.multiSelect.text, pageLangText.limitMultiSelect.text)
                            ).show();
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
                        cd_seihin = [],
                        nm_seihin = [];
                        no_lot = [];
                    // TODO：画面の仕様に応じて返却文字列を指定してください。
                    for (var i = 0; i < selArray.length; i++) {
                        row = dialog_grid.jqGrid("getRowData", selArray[i]);
                        cd_seihin.push(row.cd_hinmei);
                        nm_seihin.push(row.nm_hinmei);
                        no_lot.push(row.no_lot_seihin);
                    }
                    // TODO：ここまで
                    return [cd_seihin.join(", "), nm_seihin.join(", "), no_lot.join(", ")];
                };


                /// <summary>ダイアログを開きます。</summary>
                this.reopen = function (option) {
                    // ダイアログ再オープン時の処理

                    //検索条件クリア
                    clearCriteriaDialog();
                    clearStateDialog();

                    hinmeiCode = option.param1 ? option.param1 : "";
                    seihinName = option.param2 ? option.param2 : "";

                    //ラベル初期表示設定
                    $shikakariZanCode.text(hinmeiCode + '：');
                    $shikakariZanName.text(seihinName);

                    // デフォルト日付を挿入
                    elem.find("#condition-date-start").datepicker("setDate", new Date(today.getFullYear(), today.getMonth(), today.getDate() - 7));
                    elem.find("#condition-date-end").datepicker("setDate", new Date(today.getFullYear(), today.getMonth(), today.getDate() + 7));

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
            <h4 data-app-text="ShikakariZanIchiranDialog">
            </h4>
        </div>
        <div class="dialog-body" style="padding: 10px; width: 95%;">
            <div class="dialog-search-criteria">
                <div class="part-body">
                    <ul class="item-list">
                        <li>
                            <label>
                                <span class="item-label" data-app-text="shikakariZanDlg_date"></span>
                            </label>
                            <label>
                                <input type="text" class="date_start" name="hizuke_from" id="condition-date-start" />
                            </label>
                            <label>
                                <span class="date_between" data-app-text="date_between"></span>
                            </label>
                            <label>
                                <input type="text" class="date_end" name="hizuke_to" id="condition-date-end" />
                            </label>
                        </li>
                        <li>
                            <label>
                                <span class="item-label" data-app-text="shikakariZanDlg_nm_shikakari"></span>
                            </label>
                            <label>
                                <span class="cd-hinmei"></span>
                            </label>
                            <label>
                                <span class="nm-seihin"></span>
                            </label>
                        </li>
                    </ul>
                </div>
                <div class="part-footer">
                    <div class="command">
                        <button class="dlg-find-button" name="dlg-find-button" data-app-text="search">
                        </button>
                    </div>
                </div>
            </div>
            <div class="dialog-result-list">
                <!-- グリッドコントロール固有のデザイン -- Start -->
                <h3 id="listHeader" class="part-header">
                    <span data-app-text="resultList" style="padding-right: 10px; padding-bottom: 4px;"
                        id="list-results"></span><span class="list-count list-count-dialog" id="list-count">
                        </span>
                </h3>
                <div class="part-body" style="height: 170px;" id="shikakariZanIchiranDialog">
                    <table name="dialog-list">
                    </table>
                </div>
            </div>
        </div>
        <!-- TODO: ここまで  -->
        <div class="dialog-footer">
            <div class="command" style="position: absolute; left: 10px; top: 5px">
                <button class="dlg-select-button" name="dlg-select-button" data-app-text="select">
                </button>
            </div>
            <div class="command" style="position: absolute; right: 5px; top: 5px;">
                <button class="dlg-close-button" name="dlg-close-button" data-app-text="close">
                </button>
            </div>
        </div>
        <div class="message-area dialog-slideup-area">
            <div class="dialog-alert-message" style="display: none" data-app-text="title:alertTitle">
                <ul>
                </ul>
            </div>
            <div class="dialog-info-message" style="display: none" data-app-text="title:infoTitle">
                <ul>
                </ul>
            </div>
        </div>
    </div>
</body>
</html>
