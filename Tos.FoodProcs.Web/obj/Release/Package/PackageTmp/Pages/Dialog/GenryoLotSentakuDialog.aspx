<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="GenryoLotSentakuDialog.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.Dialog.GenryoLotSentakuDialog" %>
    
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">

<head runat="server">
    <title></title>
    <style type="text/css">
        .genryo-lot-sentaku-dlg
        {
            background-color: White;
            width: 600px;
        }
        .genryo-lot-sentaku-dlg .item-label
        {
            width: 150px;
            line-height: 180%;
        }
        .genryo-lot-sentaku-dlg .item-input
        {
            width: 140px;
        }
        .genryo-lot-sentaku-dlg .item-input-date
        {
            width: 70px;
        }
        .genryo-lot-sentaku-dlg .dialog-search-criteria
        {
            border: solid 1px #efefef;
            padding-top: 0.5em;
            padding-left: 0.5em;
        }
        .genryo-lot-sentaku-dlg .dialog-search-criteria .part-footer
        {
            margin-top: 1em;
            margin-left: .5em;
            margin-right: .5em;
            position: relative;
            height: 40px;
            border-top: solid 1px #dbdbdb;
        }
        .genryo-lot-sentaku-dlg .dialog-search-criteria .part-footer .command
        {
            position: absolute;
            display: inline-block;
            right: 0;
        }
        .genryo-lot-sentaku-dlg .dialog-result-list
        {
            margin-top: 10px;
        }
        .genryo-lot-sentaku-dlg .dialog-search-criteria .part-footer .command button
        {
            position: relative;
            margin-left: .5em;
            top: 5px;
            padding: 0px;
            min-width: 100px;
            margin-right: 0;
        }
    </style>
    <script type="text/javascript">

        $.dlg.register("GenryoLotSentakuDialog", {
            // TODO：ここまで
            initialize: function (context) {
                //// 変数宣言 -- Start
                var elem = context.element,
                    cd_genshizai = context.data.cd_genshizai ? context.data.cd_genshizai : "",
                    nm_genshizai = context.data.nm_genshizai ? context.data.nm_genshizai : "",
                    dt_seizo = context.data.dt_seizo,
                    no_lot_para = [],
				    lang = App.ui.page.lang;
                no_lot_para = context.data.no_lot != null ? context.data.no_lot.split(',') : "";
                var pageLangText = App.ui.pagedata.lang(lang);
                var validationSetting = App.ui.pagedata.validation(lang);

                // ダイアログ情報メッセージの設定
                var dialogNotifyInfo = App.ui.notify.info(elem, {
                    container: elem.find(".dialog-slideup-area .dialog-info-message"),
                    messageContainerQuery: "ul",
                    show: function () {
                        elem.find(".dialog-info-message").show();
                    },
                    clear: function () {
                        elem.find(".dialog-info-message").hide();
                    }
                });
                // ダイアログ警告メッセージの設定
                var dialogNotifyAlert = App.ui.notify.alert(elem, {
                    container: elem.find(".dialog-slideup-area .dialog-alert-message"),
                    messageContainerQuery: "ul",
                    show: function () {
                        elem.find(".dialog-alert-message").show();
                    },
                    clear: function () {
                        elem.find(".dialog-alert-message").hide();
                    }
                });

                // 日付を設定します。
                var datePickerFormat = pageLangText.dateFormatUS.text,
                    dateSrcTable = pageLangText.dateSrcFormatUS.text,
                    dateNewTable = pageLangText.dateSrcFormatUS.text;
                if (App.ui.page.langCountry !== 'en-US') {
                    datePickerFormat = pageLangText.dateFormat.text;
                    dateNewTable = pageLangText.dateNewFormat.text;
                }

                var dtNiukeStart = elem.find(".dialog-search-criteria [name='dt_niuke_start']");
                dtNiukeStart.datepicker({ dateFormat: datePickerFormat });
                dtNiukeStart.on("keyup", App.data.addSlashForDateString);
                dtNiukeStart.datepicker("setDate", "");
                dtNiukeStart.datepicker("option", "maxDate", new Date(pageLangText.maxDate.text));
                dtNiukeStart.datepicker("option", "minDate", new Date(pageLangText.minDate.text));

                var dtNiukeEnd = elem.find(".dialog-search-criteria [name='dt_niuke_end']");
                dtNiukeEnd.datepicker({ dateFormat: datePickerFormat });
                dtNiukeEnd.on("keyup", App.data.addSlashForDateString);
                dtNiukeEnd.datepicker("setDate", "");
                dtNiukeEnd.datepicker("option", "maxDate", new Date(pageLangText.maxDate.text));
                dtNiukeEnd.datepicker("option", "minDate", new Date(pageLangText.minDate.text));

                var dtYoteiNiukeStart = elem.find(".dialog-search-criteria [name='dt_yotei_niuke_start']");
                dtYoteiNiukeStart.datepicker({ dateFormat: datePickerFormat });
                dtYoteiNiukeStart.on("keyup", App.data.addSlashForDateString);
                dtYoteiNiukeStart.datepicker("setDate", "");
                dtYoteiNiukeStart.datepicker("option", "maxDate", new Date(pageLangText.maxDate.text));
                dtYoteiNiukeStart.datepicker("option", "minDate", new Date(pageLangText.minDate.text));

                var dtYoteiNiukeEnd = elem.find(".dialog-search-criteria [name='dt_yotei_niuke_end']");
                dtYoteiNiukeEnd.datepicker({ dateFormat: datePickerFormat });
                dtYoteiNiukeEnd.on("keyup", App.data.addSlashForDateString);
                dtYoteiNiukeEnd.datepicker("setDate", "");
                dtYoteiNiukeEnd.datepicker("option", "maxDate", new Date(pageLangText.maxDate.text));
                dtYoteiNiukeEnd.datepicker("option", "minDate", new Date(pageLangText.minDate.text));

                elem.find(".dialog-search-criteria [name='no_lot_search']").focus();

                var isDatestring = function (value) {
                    if (App.ui.page.lang == 'ja' || App.ui.page.lang == 'zh') {
                        if (!(/^[0-9]{4}\/[0-9]{2}\/[0-9]{2}$/.test(value))) {
                            return false;
                        }
                    } else {
                        if (!(/^[0-9]{2}\/[0-9]{2}\/[0-9]{4}$/.test(value))) {
                            return false;
                        }
                    }
                    if (App.ui.page.langCountry == 'en-US') {
                        var year = parseInt(value.substr(pageLangText.yearStartPosUS.number, 4), 10);
                        var month = parseInt(value.substr(pageLangText.monthStartPosUS.number, 2), 10);
                        var day = parseInt(value.substr(pageLangText.dayStartPosUS.number, 2), 10);
                    } else {
                        var year = parseInt(value.substr(pageLangText.yearStartPos.number, 4), 10);
                        var month = parseInt(value.substr(pageLangText.monthStartPos.number, 2), 10);
                        var day = parseInt(value.substr(pageLangText.dayStartPos.number, 2), 10);
                    }
                    var inputDate = new Date(year, month - 1, day);
                    return (inputDate.getFullYear() == year && inputDate.getMonth() == month - 1 && inputDate.getDate() == day);
                };

                Aw.validation.addMethod("greaterdate_niuke_from", function (value, param) {
                    var criteria = elem.find(".dialog-search-criteria").toJSON(),
                        from,
                        to;
                    if (!criteria.dt_niuke_start || !criteria.dt_niuke_end)
                        return true;
                    if (isDatestring(elem.find("input[name='dt_niuke_start']").val()) == false ||
                        isDatestring(elem.find("input[name='dt_niuke_end']").val()) == false)
                        return true;
                    from = new Date(criteria.dt_niuke_start);
                    to = new Date(criteria.dt_niuke_end);
                    return greaterDateFrom(from, to);
                });

                Aw.validation.addMethod("greaterdate_yoteiniuke_from", function (value, param) {
                    var criteria = elem.find(".dialog-search-criteria").toJSON(),
                        from,
                        to;

                    if (!criteria.dt_yotei_niuke_start || !criteria.dt_yotei_niuke_end)
                        return true;
                    if (isDatestring(elem.find("input[name='dt_yotei_niuke_start']").val()) == false ||
                        isDatestring(elem.find("input[name='dt_yotei_niuke_end']").val()) == false)
                        return true;

                    from = new Date(criteria.dt_yotei_niuke_start);
                    to = new Date(criteria.dt_yotei_niuke_end);
                    return greaterDateFrom(from, to);
                });

                var greaterDateFrom = function (from, to) {
                    if (to >= from) {
                        return true;
                    }
                    return false;
                };

                //// 事前データロード -- Start 
                var dialog_grid = elem.find(".dialog-result-list [name='dialog-list']"),
                    querySettingDialog = { skip: 0, top: 500, count: 0 },
                    isDialogLoading = false,
                    nextScrollTopDialog = 0,
				    lastScrollTopDialog = 0,
                    firstCol = 1;
                dialog_grid.attr("id", context.data.id);

                var bindHeader = function (cd_genshizai, nm_genshizai) {
                    elem.find(".cd_genshizai").text(cd_genshizai);
                    elem.find(".nm_genshizai").text(nm_genshizai);
                };

                bindHeader(cd_genshizai, nm_genshizai);

                // ダイアログ内のグリッド定義
                dialog_grid.jqGrid({
                    colNames: [
                        pageLangText.genryo_sentaku_checkbox_dlg.text,
                        pageLangText.genryo_sentaku_datereceive_dlg.text,
	                    pageLangText.genryo_sentaku_datedelivery_dlg.text,
                        pageLangText.genryo_sentaku_datedeadline_dlg.text,
	                    pageLangText.genryo_sentaku_lotNo.text, ''
					],
                    colModel: [
                        { name: 'checkbox', resizable: false, width: pageLangText.genryo_sentaku_checkbox_dlg.number, align: 'center', edittype: 'checkbox', editable: true, sortable: false,
                            formatter: 'checkbox',
                            editoptions: {
                                value: "True:False"
                            },
                            formatoptions: {
                                disabled: false
                            }
                        },
						{ name: 'dt_niuke', width: pageLangText.genryo_sentaku_datereceive_dlg.number, align: "left", resizable: false,
						    formatter: "date",
						    formatoptions: {
						        srcformat: dateSrcTable,
						        newformat: dateNewTable
						    }
						},
						{ name: 'dt_nonyu', width: pageLangText.genryo_sentaku_datedelivery_dlg.number, align: "left", resizable: false,
						    formatter: "date",
						    formatoptions: {
						        srcformat: dateSrcTable,
						        newformat: dateNewTable
						    }
						},
                        { name: 'dt_kigen', width: pageLangText.genryo_sentaku_datedeadline_dlg.number, align: "left", resizable: false,
                            formatter: "date",
                            formatoptions: {
                                srcformat: dateSrcTable,
                                newformat: dateNewTable
                            }
                        },
						{ name: 'no_lot', width: pageLangText.genryo_sentaku_lotNo.number, align: "left" },
                        { name: 'no_niuke', width: 0, hidden: true }
					],
                    datatype: "local",
                    shrinkToFit: false,
                    multiselect: false,
                    rownumbers: false,
                    hoverrows: false,
                    height: pageLangText.genryo_sentaku_height_table.number,
                    multiboxonly: true,
                    loadonce: true,
                    gridComplete: function () {
                        dialog_grid.setSelection(firstCol, true);
                        dialog_grid.find("input[type='checkbox']").bind("change", function (e) {
                            var target = dialog_grid.find(e.target);
                            var rowId = target.closest("tr").attr("id");
                            dialog_grid.setSelection(rowId, true);
                            if (target.is(":checked")) {
                                var data = dialog_grid.getRowData(rowId),
                                    checkbox = dialog_grid.find("input:checked"),
                                    length_checkbox = checkbox.length;
                                dialogNotifyInfo.message(App.str.format(MS0045, data.no_lot)).clear();
                                for (var i = 0; i < no_lot_para.length; i++) {
                                    if (data.no_lot == no_lot_para[i]) {
                                        target.prop("checked", false);
                                        dialogNotifyInfo.message(App.str.format(MS0045, data.no_lot)).show();
                                        return;
                                    }
                                }

                                for (var i = 0; i < length_checkbox; i++) {
                                    var item = dialog_grid.find(checkbox[i]),
                                        rowIdCheckbox = item.closest("tr").attr("id"),
                                        dataCheckbox = dialog_grid.getRowData(rowIdCheckbox);

                                    if (dataCheckbox.no_lot == data.no_lot && rowIdCheckbox != rowId) {
                                        target.prop("checked", false);
                                        dialogNotifyInfo.message(App.str.format(MS0045, data.no_lot)).show();
                                        return;
                                    }
                                }
                            }
                        });
                    }
                });

                var checkDuplicate = function (rowId, value) {
                    var checkbox = dialog_grid.find("input[type='checkbox']"),
                        i = 0,
                        length = checkbox.length;
                    for (i; i < length; i++) {
                        var item = dialog_grid.find(checkbox[i]);
                        if (item.is(":checked")) {
                            var key = item.closest("tr").attr("id"),
                                data = dialog_grid.getRowData(key);
                            for (var i = 0; i < no_lot_para.length; i++) {
                                if (no_lot_para[i] == data.no_lot)
                                    return false;
                            }
                        }
                    }
                    return true;
                };

                var clearStateDialog = function () {
                    dialog_grid.clearGridData();
                    querySettingDialog.skip = 0;
                    querySettingDialog.count = 0;
                    lastScrollTopDialog = 0;
                    nextScrollTopDialog = 0;
                    isDialogLoading = false;
                    dialogNotifyInfo.clear();
                    dialogNotifyAlert.clear();
                };


                var createFilterDialog = function () {
                    var criteria = elem.find(".dialog-search-criteria").toJSON(),
                        filters = [];
                    if (cd_genshizai.length)
                        filters.push("cd_hinmei eq '" + cd_genshizai + "'");
                    if (criteria.dt_niuke_start)
                        filters.push("dt_niuke ge DateTime'" + App.data.getFromDateStringForQuery(criteria.dt_niuke_start) + "'");
                    if (criteria.dt_niuke_end)
                        filters.push("dt_niuke le DateTime'" + App.data.getToDateStringForQuery(criteria.dt_niuke_end) + "'");

                    if (criteria.dt_yotei_niuke_start)
                        filters.push("dt_nonyu ge DateTime'" + App.data.getFromDateStringForQuery(criteria.dt_yotei_niuke_start) + "'");
                    if (criteria.dt_yotei_niuke_end)
                        filters.push("dt_nonyu le DateTime'" + App.data.getToDateStringForQuery(criteria.dt_yotei_niuke_end) + "'");

                    if (criteria.no_lot_search)
                        filters.push("no_lot eq '" + criteria.no_lot_search.replace(/^\s+|\s+$/g, '') + "'");
                    filters.push("no_seq eq 1");
                    filters.push("dt_kigen ge DateTime'" + dt_seizo + "'");
                    return filters.join(" and ");
                };

                /// <summary>検索処理の実行</summary>
                var searchItemsDialog = function (_query) {
                    App.ui.loading.show(pageLangText.nowProgressing.text, elem);

                    isDialogLoading = true;
                    var exeQuery = "";
                    exeQuery = App.data.toODataFormat(_query);
                    App.ajax.webget(
                        exeQuery
					).done(function (result) {
					    bindDataDialog(result);
					}).fail(function (result) {
					    dialogNotifyAlert.message(result.message).show();
					}).always(function () {
					    setTimeout(function () {
					        isDialogLoading = false;
					    }, 500);
					    App.ui.loading.close(elem);
					});
                };

                // <summary>クエリオブジェクトの設定</summary>
                var queryDialogWeb = function () {
                    var query = {
                        url: "../Services/FoodProcsService.svc/vw_tr_niuke_lot_sentaku",
                        filter: createFilterDialog(),
                        orderby: "dt_niuke,dt_nonyu",
                        skip: querySettingDialog.skip,
                        top: querySettingDialog.top,
                        inlinecount: "allpages"
                    };
                    return query;
                };

                /// <summary>データをバインドします。</summary>
                /// <param name="result">検索結果</param>
                var bindDataDialog = function (result) {
                    var resultCount = result.d.__count;
                    var resultData = result.d.results;
                    if (App.isUndefOrNull(resultCount)) {
                        resultCount = parseInt(result.__count);
                        resultData = result.d;
                    }
                    querySettingDialog.count = resultCount;

                    if (parseInt(resultCount) > querySettingDialog.top) {
                        querySettingDialog.skip = querySettingDialog.top;
                        dialogNotifyInfo.message(MS0011).show();
                    }
                    else {
                        querySettingDialog.skip = resultCount;
                    }

                    dialog_grid.setGridParam({ rowNum: querySettingDialog.skip });
                    displayCountDialog();

                    var currentData = dialog_grid.getGridParam("data").concat(resultData);
                    dialog_grid.setGridParam({ data: currentData }).trigger('reloadGrid', [{ current: true}]);

                    if (querySettingDialog.count <= 0) {
                        dialogNotifyInfo.message(MS0037).show();
                    }
                    else {
                        dialog_grid.setSelection(firstCol, true);
                        dialogNotifyInfo.message(
                            App.str.format(pageLangText.searchResultCount.text, querySettingDialog.skip, querySettingDialog.count)
                        ).show();
                    }
                };

                /// <summary>データ取得件数を表示します。</summary>
                var displayCountDialog = function () {
                    elem.find(".list-count-dialog").text(
						App.str.format("{0}/{1}", querySettingDialog.skip, querySettingDialog.count));
                };

                /// <summary>検索前バリデーションの初期化</summary>
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
                $(".genryo-lot-sentaku-dlg").validation(searchValidation);

                var checkValidateDate = function (e) {
                    $(".genryo-lot-sentaku-dlg").validation().validate();
                }

                elem.find(".dialog-search-criteria input[name='dt_niuke_start']").on("change", function (e) { checkValidateDate(e) });
                elem.find(".dialog-search-criteria input[name='dt_niuke_end']").on("change", function (e) { checkValidateDate(e) });
                elem.find(".dialog-search-criteria input[name='dt_yotei_niuke_start']").on("change", function (e) { checkValidateDate(e) });
                elem.find(".dialog-search-criteria input[name='dt_yotei_niuke_end']").on("change", function (e) { checkValidateDate(e) });

                elem.find(".find-button").on("click", function () {
                    if (isDialogLoading == true) {
                        return;
                    }
                    var result = $(".genryo-lot-sentaku-dlg").validation().validate();
                    if (result.errors.length) {
                        return;
                    }

                    clearStateDialog();
                    searchItemsDialog(new queryDialogWeb());
                });
                searchItemsDialog(new queryDialogWeb());
                var initDialog = function () {
                    elem.find(".cd_genshizai").text("");
                    elem.find(".nm_genshizai").text("");
                    elem.find("input[name='no_lot_search']").val("");
                    elem.find(".list-count-dialog").text("");

                    dtYoteiNiukeStart.datepicker("setDate", "");
                    dtYoteiNiukeEnd.datepicker("setDate", "");
                    dtNiukeStart.datepicker("setDate", "");
                    dtNiukeEnd.datepicker("setDate", "");

                    clearStateDialog();
                };

                elem.find(".dlg-close-button").on("click", function () {
                    initDialog();
                    context.close("canceled");
                });

                elem.find(".dlg-select-button").on("click", function () {
                    dialogNotifyAlert.message(MS0443).clear();
                    var checkbox = dialog_grid.find("input[type='checkbox']"),
                        i = 0,
                        length = checkbox.length,
                        hasData = false,
                        no_lot = [],
                        no_niuke = [];
                    for (i; i < length; i++) {
                        var item = dialog_grid.find(checkbox[i]);
                        if (item.is(":checked")) {
                            hasData = true;
                            var key = item.closest("tr").attr("id"),
                                data = dialog_grid.getRowData(key);
                            no_lot.push(data.no_lot);
                            no_niuke.push(data.no_niuke);
                        }
                    }
                    if (hasData == false) {
                        dialogNotifyAlert.message(MS0443).show();
                    }
                    else {
                        initDialog();
                        context.close([no_lot.join(","), no_niuke.join(",")]);
                    }
                });

                this.reopen = function (option) {
                    setTimeout(function () {
                        elem.find("input[name='no_lot_search']").focus();
                    }, 0);
                    cd_genshizai = option.cd_genshizai;
                    nm_genshizai = option.nm_genshizai;
                    no_lot_para = option.no_lot != null ? option.no_lot.split(',') : "";
                    dt_seizo = option.dt_seizo;
                    bindHeader(cd_genshizai, nm_genshizai);
                    searchItemsDialog(new queryDialogWeb());
                };
            }
        });
    </script>
</head>
<body>
    <div class="dialog-content">
        <div class="dialog-header">
            <h4 data-app-text="genryoLotSentakuDialog">
            </h4>
        </div>
        <div class="dialog-body" style="padding: 10px;">
            <div class="dialog-search-criteria">
                <div class="part-body">
                    <ul class="item-list">
                        <li>
                            <label>
                                <span class="item-label" data-app-text="genryo_sentaku_item_nm_code"></span>
                            </label>
                            <span class="cd_genshizai" style="padding-right: 10px;font-weight:bold"></span>
                            <span class="nm_genshizai" style="font-weight:bold"></span>
                        </li>
                        <li>
                            <label>
                                <span class="item-label" data-app-text="genryo_sentaku_datereceive_dlg"></span>
                            </label>
                            <input class="item-input-date" name="dt_niuke_start" maxlength="10"/>
                            <span data-app-text="date_between"></span>
                            <input class="item-input-date" name="dt_niuke_end" maxlength="10"/>
                        </li>
                        <li>
                            <label>
                                <span class="item-label" data-app-text="genryo_sentaku_datedelivery_dlg"></span>
                            </label>
                            <input class="item-input-date" name="dt_yotei_niuke_start" maxlength="10"/>
                            <span data-app-text="date_between"></span>
                            <input class="item-input-date" name="dt_yotei_niuke_end" maxlength="10"/>
                        </li>
                        <li>
                            <label>
                                <span class="item-label" data-app-text="genryo_sentaku_lotNo_dlg"></span>
                            </label>
                            <input class="item-input" type="text" name="no_lot_search" maxlength="14"/>
                            <input style="display: none"/>
                        </li>
                    </ul>
                </div>
                <div class="part-footer">
                    <div class="command">
                        <button type="button" class="find-button" name="dlg-find-button" data-app-operation="search">
					        <span class="icon"></span><span data-app-text="search"></span>
				        </button>
                    </div>
                </div>
            </div>
            <div class="dialog-result-list">
                <h3 id="listHeader" class="part-header">
					<span data-app-text="resultList" style="padding-right: 10px; padding-bottom: 4px;"id="list-results"></span>
					<span class="list-count list-count-dialog" id="list-count"></span>
				</h3>
                <div class="part-body" style="height: 220px;">
                    <table name="dialog-list">
                    </table>
                </div>
            </div>
        </div>
        <div class="dialog-footer">
            <div class="command" style="position: absolute; left: 10px; top: 5px;">
                <button class="dlg-select-button" name="select" data-app-text="select">
                </button>
            </div>
            <div class="command" style="position: absolute; right: 10px; top: 5px;">
                <button class="dlg-close-button" name="close" data-app-text="close">
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
