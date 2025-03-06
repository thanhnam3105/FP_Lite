<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SeizoJissekiSentakuDialog.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.Dialog.SeizoJissekiSentakuDialog" %>

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
        $.dlg.register("SeizoJissekiSentakuDialog", {
            // TODO：ここまで
            initialize: function (context) {
                //// 変数宣言 -- Start
                var elem = context.element,
                    pageLangText = App.ui.pagedata.lang(App.ui.page.lang);
                var seihinName = "nm_hinmei_" + App.ui.page.lang;

                // 多言語対応　言語によって幅を調節
                $(".dialog-content .item-label").css("width", pageLangText.seizoJissekiDlgn_itemLabel_width.number);

                // パラメータからmultiselectを設定
                var multiselect = false;
                if (context.data.multiselect) {
                    multiselect = context.data.multiselect;
                }
                var shikakariCode = context.data.param1;
                var shikakariName = context.data.param2;

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
                    isDialogLoading = false;
                // パラメータからグリッドのIDを設定
                dialog_grid.attr("id", context.data.id);

                // 日付の多言語対応
                var datePickerFormat = pageLangText.dateFormatUS.text,
                    newDateFormat = pageLangText.dateNewFormatUS.text;
                if (App.ui.page.langCountry !== 'en-US') {
                    datePickerFormat = pageLangText.dateFormat.text;
                    newDateFormat = pageLangText.dateNewFormat.text;
                }

                /// <summary>終了日の初期値:システム日付の7日後を取得する。</summary>
                var getDateTo = function () {
                    var returnVal = new Date();
                    returnVal.setDate(returnVal.getDate() + 7);
                    return returnVal;
                };

                /// <summary>初期値設定</summary>
                var setHeaderValue = function () {
                    $("#date_from").datepicker("setDate", new Date());
                    $("#date_to").datepicker("setDate", getDateTo());
                    $("#cd_shikakari").text(shikakariCode);
                    $("#nm_shikakari").text(shikakariName);
                };

                // datepicker の設定
                $("#date_from, #date_to").on("keyup", App.data.addSlashForDateString);
                $("#date_from, #date_to").datepicker({
                    dateFormat: datePickerFormat,
                    minDate: new Date(1975, 1 - 1, 1)
                    //maxDate: "+10y"
                });
                setHeaderValue();

                /*
                // 画面アーキテクチャ共通の事前データロード
                var shokuba;
                App.deferred.parallel({
                // ローディングの表示
                loading: App.ui.loading.show(pageLangText.nowProgressing.text),
                shokuba: App.ajax.webget("../Services/FoodProcsService.svc/ma_shokuba?"
                + "$filter=flg_mishiyo eq " + pageLangText.falseFlg.text)
                }).done(function (result) {
                shokuba = result.successes.shokuba.d;
                App.ui.appendOptions($(".dialog-search-criteria [name='shokuba']"), "cd_shokuba", "nm_shokuba", shokuba, true);
                }).fail(function (result) {
                var length = result.key.fails.length,
                messages = [];
                for (var i = 0; i < length; i++) {
                var keyName = result.key.fails[i];
                var value = result.fails[keyName];
                messages.push(keyName + " " + value.message);
                }
                App.ui.page.notifyAlert.message(messages).show();
                }).always(function () {
                // ローディングの終了
                App.ui.loading.close();
                });
                */

                /// <summary>検索用URLの設定</summary>
                var queryDialog = function () {
                    var dtFrom = App.date.localDate($("#date_from").val()),
                        dtTo = App.date.localDate($("#date_to").val());

                    var query = { url: "../api/SeizoJissekiSentakuDialog"
                                  , dt_from: App.data.getDateTimeStringForQueryNoUtc(dtFrom)
                                  , dt_to: App.data.getDateTimeStringForQueryNoUtc(dtTo)
                                  , cd_haigo: shikakariCode
                                  , lang: App.ui.page.lang
                                  , top: querySettingDialog.top
                                  , user: App.ui.page.user.Code
                    };
                    return query;
                };

                /// <summary>検索処理の実施</summary>
                /// <param name="_query">検索URL</param>
                var searchItemsDialog = function (_query) {
                    if (isDialogLoading === true) {
                        return;
                    }
                    App.ui.loading.show(pageLangText.nowProgressing.text, ".dialog-content");
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
                        App.ui.loading.close(".dialog-content");
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
						App.str.format("{0}/{1}", querySettingDialog.skip, querySettingDialog.count));
                };
                /// <summary>データをバインドします。</summary>
                /// <param name="result">検索結果</param>
                var bindDataDialog = function (result) {
                    var resultCount = parseInt(result.__count);
                    var resultData = result.d;
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

                // ダイアログ内のグリッド定義
                dialog_grid.jqGrid({
                    colNames: [
                        pageLangText.seizoJissekiDlg_code.text
                        , pageLangText.kbn_hin_dlg.text
                        , pageLangText.kbn_hin_dlg.text
                        , pageLangText.seizoJissekiDlg_hinmei.text
                        , pageLangText.dt_seizo_dlg.text
                        , pageLangText.seizoJissekiDlg_seizoSu.text
                        , pageLangText.seizoJissekiDlg_lotNo.text
                        , "flg_testitem"
                    ],
                    colModel: [
                        { name: 'cd_hinmei', width: 120, align: "left" },
                        { name: 'kbn_hin', width: 0, hidden: true, hidedlg: true },
                        { name: 'nm_kbn_hin', width: 110, align: "left" },
                        { name: seihinName, width: 165, align: "left" },
                        { name: 'dt_seizo', width: 120, align: "left",
                            formatter: "date",
                            formatoptions: {
                                srcformat: newDateFormat, newformat: newDateFormat
                            }
                        },
                        { name: 'su_seizo', width: 130, align: "right",
                            formatter: 'number',
                            formatoptions: {
                                decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 0, defaultValue: "0"
                            }
                        },
                        { name: 'no_lot_seihin', width: 120, align: "left" },
                        { name: 'flg_testitem', width: 0, hidden: true, hidedlg: true }
                    ],
                    datatype: "local",
                    shrinktofit: false,
                    multiselect: multiselect,
                    hoverrows: false,
                    rownumbers: true,
                    height: 160,
                    loadComplete: function () {
                        // グリッドの先頭行選択：loadCompleteに記述しないとグリッドのソートで先頭行が選択されない
                        dialog_grid.setSelection(1, false);
                    },
                    ondblClickRow: function (rowid) {
                        var returnCode = returnSelectedDialog();
                        if (returnCode != "noSelect") {
                            closeDialog(returnCode);
                        }
                    }
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
                };

                /// <summary>閉じる/選択共通：画面の終了処理</summary>
                var closeDialog = function (ret) {
                    clearStateDialog(); // 画面のクリア処理
                    $("#cd_shikakari").text("");
                    $("#nm_shikakari").text("");
                    context.close(ret);
                };

                /// <summary>選択したコードを書き出します</summary>
                var returnSelectedDialog = function () {
                    var rowId = dialog_grid.jqGrid("getGridParam", "selrow");
                    if (rowId == null || rowId.length == 0) {
                        dialogNotifyInfo.message(pageLangText.noSelect.text).show();
                        return "noSelect";
                    }
                    var row = dialog_grid.jqGrid("getRowData", rowId);
                    var retArray = {
                        "cd_hinmei": row.cd_hinmei
                        , "nm_hinmei": row[seihinName]
                        , "dt_seizo": row.dt_seizo
                        , "no_lot": row.no_lot_seihin
                        , "kbn_hin": row.kbn_hin
                        , "nm_kbn_hin": row.nm_kbn_hin
                        , "flg_testitem": row.flg_testitem
                    };
                    return retArray;
                };

                // <summary>ダイアログの閉じるボタンクリック時のイベント処理を行います。</summary>
                elem.find(".dlg-close-button").on("click", function () {
                    closeDialog("canceled");
                });

                // <summary>ダイアログの選択ボタンクリック時のイベント処理を行います。</summary>
                elem.find(".dlg-select-button").on("click", function () {
                    var returnCode = returnSelectedDialog();
                    if (returnCode != "noSelect") {
                        context.close(returnCode);
                    }
                });

                /// <summary>ダイアログの検索ボタンクリック時のイベント処理を行います。</summary>
                elem.find(".dlg-find-button").on("click", function () {
                    if (isDialogLoading == true) {
                        return;
                    }
                    dialogNotifyInfo.clear();
                    dialogNotifyAlert.clear();

                    // バリデーション
                    var result = $(".dialog-body .item-list").validation().validate();
                    if (result.errors.length) {
                        return;
                    }

                    // チェック：検索開始日 <= 検索終了日であること
                    var dt_from = App.date.localDate($("#date_from").val()),
                        dt_to = App.date.localDate($("#date_to").val());
                    if (dt_from > dt_to) {
                        dialogNotifyAlert.message(
                            App.str.format(MS0019, pageLangText.endDate.text, pageLangText.startDate.text)
                        ).show();
                        return;
                    }

                    clearStateDialog();
                    searchItemsDialog(new queryDialog());
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
                    // ダイアログ再オープン時の処理
                    clearCriteriaDialog();
                    //clearStateDialog();
                    setHeaderValue();
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
        <!-- TODO: 画面の仕様に応じて以下のダイアログの設定を変更してください。 -->
        <div class="dialog-header">
            <h4 data-app-text="seizoJissekiDialog">
            </h4>
        </div>
        <div class="dialog-body" style="padding: 10px; width: 95%;">
            <div class="dialog-search-criteria">
				<div class="part-body">
					<ul class="item-list">
						<li>
					        <label>
						        <span class="item-label" data-app-text="seizoJissekiDlg_date"></span>
						        <input type="text" name="hizuke_from" id="date_from" maxlength="10" style="width: 110px" />
					        </label>
                            <span data-app-text="date_between"></span>
                            <label>
                                <input type="text" name="hizuke_to" id="date_to" maxlength="10" style="width: 110px" />
                            </label>
                        </li>
						<li>
					        <label>
                                <span class="item-label" data-app-text="seizoJissekiDlg_shikakari"></span>
						        <span id="cd_shikakari"></span>
					        </label>
                            <span data-app-text="colon"></span>
					        <label>
						        <span id="nm_shikakari"></span>
					        </label>
                        </li>
					</ul>
				</div>
				<div class="part-footer">
					<!--<div class="command" style="left: 1px;">-->
					<div class="command" style="left: 1px;">
						<button class="dlg-find-button" name="dlg-find-button" data-app-text="search">
						</button>
					</div>
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
