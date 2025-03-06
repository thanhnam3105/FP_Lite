<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="JikaGenryoLotSentakuDialog.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.Dialog.JikaGenryoLotSentakuDialog" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <style type="text/css">
       .jika-genryo-lot-sentaku-dlg
        {
            background-color: white;
            width: 605px;
        }
        .jika-genryo-lot-sentaku-dlg .item-label
        {
            width: 12em;
            line-height: 180%;
        }
        .jika-genryo-lot-sentaku-dlg .item-input
        {
            width: 140px;
        }
        .jika-genryo-lot-sentaku-dlg .item-input-date
        {
            width: 70px;
        }
        .jika-genryo-lot-sentaku-dlg .dialog-search-criteria
        {
            border: solid 1px #efefef;
            padding-top: 0.5em;
            padding-left: 0.5em;
            padding-right: 0.5em;
        }
        .jika-genryo-lot-sentaku-dlg .dialog-search-criteria .part-footer
        {
            margin-top: 1em;
            margin-left: .5em;
            position: relative;
            height: 40px;
            border-top: solid 1px #dbdbdb;
        }
        .jika-genryo-lot-sentaku-dlg .dialog-search-criteria .part-footer .command
        {
            position: absolute;
            display: inline-block;
            right: 0;
        }
        .jika-genryo-lot-sentaku-dlg .dialog-result-list
        {
            margin-top: 10px;
        }
        .jika-genryo-lot-sentaku-dlg .dialog-search-criteria .part-footer .command button
        {
            position: relative;
            margin-left: .5em;
            top: 5px;
            padding: 0px;
            min-width: 100px;
            margin-right: 0;
        }
        .jika-genryo-lot-sentaku-dlg .dialog-body
        {
            height: 330px;
        }
        .jika-genryo-lot-sentaku-dlg .ui-jqgrid-btable .ui-state-highlight, 
        .ui-jqgrid-btable .selected-row
        {
            border: 1px solid #999999;
            background: #fce188 50% 50% repeat-x;
            color: #363636;
        }
    </style>
    <script type="text/javascript">
        $.dlg.register("JikaGenryoLotSentakuDialog", {
            initialize: function (context) {
                var elem = context.element,
                    cd_genshizai = context.data.cd_genshizai ? context.data.cd_genshizai : "",
                    nm_genshizai = context.data.nm_genshizai ? context.data.nm_genshizai : "",
                    dt_seizo = context.data.dt_seizo,
                    no_lot_para = [],
				    lang = App.ui.page.lang;
                no_lot_para = context.data.no_lot != null ? context.data.no_lot.split(',') : "";
                var pageLangText = App.ui.pagedata.lang(lang);
                var validationSetting = App.ui.pagedata.validation(lang);

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

                var datePickerFormat = pageLangText.dateFormatUS.text,
                    dateSrcTable = pageLangText.dateSrcFormatUS.text,
                    dateNewTable = pageLangText.dateSrcFormatUS.text;

                if (App.ui.page.langCountry !== 'en-US') {
                    datePickerFormat = pageLangText.dateFormat.text;
                    dateNewTable = pageLangText.dateNewFormat.text;
                }

                var dtStart = elem.find(".dialog-search-criteria [name='dt_seizo_start']");
                dtStart.datepicker({ dateFormat: datePickerFormat });
                dtStart.on("keyup", App.data.addSlashForDateString);
                dtStart.datepicker("setDate", "");
                dtStart.datepicker("option", "maxDate", new Date(pageLangText.maxDate.text));
                dtStart.datepicker("option", "minDate", new Date(pageLangText.minDate.text));

                var dtEnd = elem.find(".dialog-search-criteria [name='dt_seizo_end']");
                dtEnd.datepicker({ dateFormat: datePickerFormat });
                dtEnd.on("keyup", App.data.addSlashForDateString);
                dtEnd.datepicker("setDate", "");
                dtEnd.datepicker("option", "maxDate", new Date(pageLangText.maxDate.text));
                dtEnd.datepicker("option", "minDate", new Date(pageLangText.minDate.text));

                elem.find(".find-button").focus();

                var bindHeader = function (cd_genshizai, nm_genshizai) {
                    elem.find(".cd_genshizai").text(cd_genshizai);
                    elem.find(".nm_genshizai").text(nm_genshizai);
                };
                bindHeader(cd_genshizai, nm_genshizai);

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

                Aw.validation.addMethod("greaterdate_from", function (value, param) {
                    var criteria = elem.find(".dialog-search-criteria").toJSON();

                    if (!criteria.dt_seizo_start || !criteria.dt_seizo_end)
                        return true;
                    if (isDatestring(elem.find("input[name='dt_seizo_start']").val()) == false ||
                        isDatestring(elem.find("input[name='dt_seizo_end']").val()) == false)
                        return true;

                    var from = new Date(criteria.dt_seizo_start);
                    var to = new Date(criteria.dt_seizo_end);
                    return greaterDateFrom(from, to);
                });

                var greaterDateFrom = function (from, to) {
                    if (to >= from) {
                        return true;
                    }
                    return false;
                };

                var dialog_grid = elem.find(".dialog-result-list [name='dialog-list']"),
				    querySettingDialog = { skip: 0, top: 500, count: 0 },
				    isDialogLoading = false,
                    nextScrollTopDialog = 0,
				    lastScrollTopDialog = 0,
                    firstCol = 1;

                dialog_grid.attr("id", context.data.id);
                dialog_grid.jqGrid({
                    colNames: [
						pageLangText.jika_genryo_sentaku_delete.text,
						pageLangText.jika_genryo_sentaku_date.text,
						pageLangText.jika_genryo_sentaku_nofpro.text,
                        pageLangText.jika_genryo_sentaku_lotno.text,
					    pageLangText.jika_genryo_sentaku_exdate.text
					],
                    colModel: [
						{ name: 'checkbox_select', edittype: 'checkbox', editable: true, width: pageLangText.jika_genryo_sentaku_delete.number, resizable: false, align: "center", sortable: false,
						    formatter: "checkbox",
						    editoptions: {
						        value: "true:false"
						    },
						    formatoptions: {
						        disabled: false
						    }
						},
						{ name: 'dt_seizo', width: pageLangText.jika_genryo_sentaku_date.number, align: "left", resizable: false,
						    formatter: "date",
						    formatoptions: {
						        srcformat: dateSrcTable,
						        newformat: dateNewTable
						    }
						},
						{ name: 'su_seizo_jisseki', width: pageLangText.jika_genryo_sentaku_nofpro.number, align: "right", resizable: false, sorttype: "integer",
						    formatter: 'number',
						    formatoptions: {
						        decimalSeparator: ".",
						        thousandsSeparator: ",",
						        decimalPlaces: 0,
						        defaultValue: ""
						    }
						},
						{ name: 'no_lot_seihin', width: pageLangText.jika_genryo_sentaku_lotno.number, align: "left" },
                        { name: 'dt_shomi', width: pageLangText.jika_genryo_sentaku_exdate.number, align: "left", resizable: false,
                            formatter: "date",
                            formatoptions: {
                                srcformat: dateSrcTable,
                                newformat: dateNewTable
                            }
                        }
					],
                    datatype: "local",
                    shrinkToFit: false,
                    rownumbers: false,
                    hoverrows: false,
                    height: 140,
                    gridComplete: function () {
                        dialog_grid.setSelection(firstCol, true);
                        dialog_grid.find("input[type='checkbox']").bind("change", function (e) {
                            var target = $(e.target);
                            var rowId = target.closest("tr").attr("id");
                            dialog_grid.setSelection(rowId, true);

                            if (target.is(":checked")) {

                                var data = dialog_grid.getRowData(rowId),
                                    checkbox = dialog_grid.find("input:checked"),
                                    length_checkbox = checkbox.length;
                                dialogNotifyInfo.message(App.str.format(MS0045, data.no_lot)).clear();
                                for (var i = 0; i < no_lot_para.length; i++) {
                                    if (data.no_lot_seihin == no_lot_para[i]) {
                                        target.prop("checked", false);
                                        dialogNotifyInfo.message(App.str.format(MS0045, data.no_lot_seihin)).show();
                                        return;
                                    }
                                }

                                for (var i = 0; i < length_checkbox; i++) {
                                    var item = dialog_grid.find(checkbox[i]),
                                        rowIdCheckbox = item.closest("tr").attr("id"),
                                        dataCheckbox = dialog_grid.getRowData(rowIdCheckbox);

                                    if (dataCheckbox.no_lot_seihin == data.no_lot_seihin && rowIdCheckbox != rowId) {
                                        target.prop("checked", false);
                                        dialogNotifyInfo.message(App.str.format(MS0045, data.no_lot_seihin)).show();
                                        return;
                                    }
                                }
                            }
                        });
                    }
                });

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
                    if (cd_genshizai)
                        filters.push("cd_hinmei eq '" + cd_genshizai + "'");
                    if (criteria.dt_seizo_start)
                        filters.push("dt_seizo ge DateTime'" + App.data.getFromDateStringForQuery(criteria.dt_seizo_start) + "'");
                    if (criteria.dt_seizo_end)
                        filters.push("dt_seizo le DateTime'" + App.data.getToDateStringForQuery(criteria.dt_seizo_end) + "'");
                    filters.push("flg_jisseki eq " + pageLangText.jissekiYojitsuFlg.text);
                    filters.push("dt_shomi ge DateTime'" + dt_seizo + "'");
                    return filters.join(" and ");
                };

                /// <summary>検索処理の実行</summary>
                var searchItemsDialog = function (_query) {
                    App.ui.loading.show(pageLangText.nowProgressing.text, elem);

                    isDialogLoading = true;
                    var exeQuery = "";
                    exeQuery = App.data.toODataFormat(_query);
                    App.ajax.webget(exeQuery).done(function (result) {
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
                        url: "../Services/FoodProcsService.svc/tr_keikaku_seihin",
                        filter: createFilterDialog(),
                        orderby: "dt_seizo, no_lot_seihin",
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
                $(".jika-genryo-lot-sentaku-dlg").validation(searchValidation);

                var initDialog = function () {
                    elem.find(".list-count-dialog").text("");
                    dtStart.datepicker("setDate", "");
                    dtEnd.datepicker("setDate", "");
                    clearStateDialog();
                };

                var checkValidateDate = function (e) {
                    $(".jika-genryo-lot-sentaku-dlg").validation().validate();
                }

                elem.find(".dialog-search-criteria [name='dt_seizo_start']").on("change", function (e) { checkValidateDate(e) });
                elem.find(".dialog-search-criteria [name='dt_seizo_end']").on("change", function (e) { checkValidateDate(e) });

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
                        no_lot = [];
                    for (i; i < length; i++) {
                        var item = dialog_grid.find(checkbox[i]);
                        if (item.is(":checked")) {
                            hasData = true;
                            var key = item.closest("tr").attr("id"),
                                data = dialog_grid.getRowData(key);
                            no_lot.push(data.no_lot_seihin);
                        }
                    }
                    if (hasData == false) {
                        dialogNotifyAlert.message(MS0443).show();
                    }
                    else {
                        initDialog();
                        context.close([no_lot.join(",")]);
                    }
                });

                elem.find(".find-button").on("click", function () {
                    if (isDialogLoading == true) {
                        return;
                    }
                    var result = $(".jika-genryo-lot-sentaku-dlg").validation().validate();
                    if (result.errors.length) {
                        return;
                    }

                    clearStateDialog();
                    searchItemsDialog(new queryDialogWeb());
                });
                searchItemsDialog(new queryDialogWeb());
                this.reopen = function (option) {
                    setTimeout(function () {
                        elem.find(".find-button").focus();
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
            <h4 data-app-text="JikaGenryoLotSentakuDialog">
            </h4>
        </div>
        <div class="dialog-body" style="padding: 10px;">
            <div class="dialog-search-criteria">
                <div class="part-body">
                    <ul class="item-list">
                        <li>
                            <label>
                                <span class="item-label" style="width: 150px;" data-app-text="jika_genryo_sentaku_item_name_code"></span>
                            </label>
                            <span name="cd_genshizai" class="cd_genshizai" style="padding-right: 10px; font-weight:bold"></span>
                            <span name="nm_genshizai" class="nm_genshizai" style="font-weight: bold"></span>
                        </li>
                        <li>
                            <label>
                                <span class="item-label" style="width: 150px;" data-app-text="jika_genryo_sentaku_date"></span>
                            </label>
                            <input class="item-input-date" name="dt_seizo_start" maxlength="10"/>
                            <span data-app-text="date_between"></span>
                            <input class="item-input-date" name="dt_seizo_end" maxlength="10"/>
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
                <div class="part-body" style="height: 170px;" id="">
                    <table name="dialog-list">
                    </table>
                </div>
            </div>
        </div>
        <div class="dialog-footer">
            <div class="command" style="position: absolute; left: 10px; top: 5px">
                <button class="dlg-select-button" name="dlg-select-button" data-app-text="select">
                </button>
            </div>
            <div class="command" style="position: absolute; right: 10px; top: 5px;">
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
