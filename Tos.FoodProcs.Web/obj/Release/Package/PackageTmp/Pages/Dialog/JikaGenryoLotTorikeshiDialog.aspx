<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="JikaGenryoLotTorikeshiDialog.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.Dialog.JikaGenryoLotTorikeshiDialog" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <style type="text/css">
        .jika-genryo-lot-torikeshi-dlg
        {
            background-color: White;
            width: 585px;
        }
        .jika-genryo-lot-torikeshi-dlg .item-label {
            width: 8em;
            line-height: 180%;
        }
        .jika-genryo-lot-torikeshi-dlg .dialog-search-criteria {
            border: solid 1px #efefef;
            padding-top: 0.5em;
            padding-left: 0.5em;
        }
        .jika-genryo-lot-torikeshi-dlg .dialog-search-criteria .part-footer {
            margin-top: 1em;
            margin-left: .5em;
            margin-right: .5em;
            position: relative;
            height: 40px;
            border-top: solid 1px #dbdbdb;
        }
        .jika-genryo-lot-torikeshi-dlg .dialog-search-criteria .part-footer .command {
          display: inline-block;
          right: 0;
        }
        .jika-genryo-lot-torikeshi-dlg .dialog-result-list {
            margin-top: 10px;
        }
        .jika-genryo-lot-torikeshi-dlg .dialog-search-criteria .part-footer .command button {
          position: relative;
          margin-left: .5em;
          top: 5px;
          padding: 0px;
          min-width: 100px;
          margin-right: 0;
        }
        .jika-genryo-lot-torikeshi-dlg .ui-jqgrid-btable .ui-state-highlight,
        .ui-jqgrid-btable .selected-row
        {
            border: 1px solid #999999;
            background: #fce188 50% 50% repeat-x;
            color: #363636;
        }
    </style>
    <script type="text/javascript">
        $.dlg.register("JikaGenryoLotTorikeshiDialog", {
            initialize: function (context) {
                var elem = context.element,
                    cd_genshizai = context.data.cd_genshizai ? context.data.cd_genshizai : "",
                    nm_genshizai = context.data.nm_genshizai ? context.data.nm_genshizai : "",
                    no_lot = context.data.no_lot_shikakari,
                    no_kotei = context.data.no_kotei,
                    no_tonyu = context.data.no_tonyu,
				    lang = App.ui.page.lang;
                var pageLangText = App.ui.pagedata.lang(lang);

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
                var dateSrcTable = pageLangText.dateSrcFormatUS.text,
                    dateNewTable = pageLangText.dateSrcFormatUS.text;
                if (App.ui.page.langCountry !== 'en-US') {
                    dateNewTable = pageLangText.dateNewFormat.text;
                }

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
						pageLangText.jika_genryo_dlg_delete.text,
						pageLangText.jika_genryo_dlg_manufature_date.text,
						pageLangText.jika_genryo_dlg_no_of_product.text,
						pageLangText.jika_genryo_dlg_lot_no.text,
						pageLangText.jika_genryo_dlg_expiry_date.text
					],
                    colModel: [
						{ name: 'isDelete', resizable: false, width: pageLangText.jika_genryo_dlg_delete.number, align: 'center', edittype: 'checkbox', editable: true, sortable: false,
						    formatter: 'checkbox',
						    editoptions: {
						        value: "True:False"
						    },
						    formatoptions: {
						        disabled: false
						    }
						},
						{ name: 'dt_seizo', width: pageLangText.jika_genryo_dlg_manufature_date.number, align: "left", resizable: false,
						    formatter: "date",
						    formatoptions: {
						        srcformat: dateSrcTable,
						        newformat: dateNewTable
						    }
						},
						{ name: 'su_seizo_jisseki', width: pageLangText.jika_genryo_dlg_no_of_product.number, align: 'right' },
						{ name: 'no_lot_seihin', width: pageLangText.jika_genryo_dlg_lot_no.number, align: "left" },
						{ name: 'dt_shomi', width: pageLangText.jika_genryo_dlg_expiry_date.number, align: "left", resizable: false,
						    formatter: "date",
						    formatoptions: {
						        srcformat: dateSrcTable, newformat: dateNewTable
						    }
						}
					],
                    datatype: "local",
                    shrinkToFit: false,
                    multiselect: false,
                    rownumbers: false,
                    hoverrows: false,
                    height: 185,
                    multiboxonly: true,
                    loadonce: true,
                    gridComplete: function () {
                        dialog_grid.setSelection(firstCol, true);
                        $("input[type='checkbox']").bind("change", function (e) {
                            var target = $(e.target);
                            var rowId = target.closest("tr").attr("id");
                            dialog_grid.setSelection(rowId, true);
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

                /// <summary>検索処理の実行</summary>
                var searchItemsDialog = function (_query) {
                    App.ui.loading.show(pageLangText.nowProgressing.text, elem);

                    isDialogLoading = true;
                    var exeQuery = "";
                    exeQuery = App.data.toWebAPIFormat(_query);
                    App.ajax.webget(exeQuery
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
                        url: "../api/JikaGenryoLotTorikeshiDialog",
                        cd_hinmei: cd_genshizai,
                        no_lot_shikakari: no_lot,
                        no_kotei: no_kotei,
                        no_tonyu: no_tonyu
                    };
                    return query;
                };

                /// <summary>データをバインドします。</summary>
                /// <param name="result">検索結果</param>
                var bindDataDialog = function (result) {
                    var resultCount = parseInt(result.length);
                    clearStateDialog();
                    querySettingDialog.skip = querySettingDialog.skip + result.length;
                    querySettingDialog.count = resultCount;

                    if (resultCount > querySettingDialog.top) {
                        result.splice(querySettingDialog.top, resultCount);
                        querySettingDialog.skip = result.length;
                        dialogNotifyAlert.message(pageLangText.limitOver.text).show();
                    }

                    // グリッドの表示件数を更新
                    dialog_grid.setGridParam({ rowNum: querySettingDialog.skip });
                    displayCountDialog();
                    // データバインド
                    var currentData = dialog_grid.getGridParam("data").concat(result);
                    dialog_grid.setGridParam({ data: currentData }).trigger('reloadGrid', [{ current: true}]);
                    // 取得完了メッセージの表示
                    if (querySettingDialog.count <= 0) {
                        dialogNotifyInfo.message(MS0037).show();
                    }
                    else {
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

                var initDialog = function () {
                    elem.find(".cd_genshizai").text("");
                    elem.find(".nm_genshizai").text("");
                    elem.find(".list-count-dialog").text("");

                    clearStateDialog();
                };

                clearStateDialog();
                searchItemsDialog(new queryDialogWeb());

                elem.find(".dlg-close-button").on("click", function () {
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

                this.reopen = function (option) {
                    clearStateDialog();
                    cd_genshizai = option.cd_genshizai;
                    nm_genshizai = option.nm_genshizai;
                    no_lot = option.no_lot_shikakari;
                    no_kotei = option.no_kotei;
                    no_tonyu = option.no_tonyu;
                    bindHeader(cd_genshizai, nm_genshizai);
                    searchItemsDialog(new queryDialogWeb());
                };
            }
        });
    </script>
</head>
<body>
    <div class="dialog-content" style="">
        <div class="dialog-header">
            <h4 data-app-text="jikaGenryoLotTorikeshiDialog"></h4>
        </div>
        <div class="dialog-body" style="padding: 10px;">
            <div class="dialog-search-criteria" style="padding-bottom: 10px;">
                <label>
				    <span class="item-label" style="padding-right:10px;" data-app-text="jika_genryo_item_nm_code"></span>
                </label>
                <span name="cd_genshizai" class="cd_genshizai" style="padding-right: 10px; font-weight: bold"></span>
                <span name="nm_genshizai" class="nm_genshizai" style="font-weight: bold"></span>
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
            <div class="command" style="position: absolute; left: 10px; top:5px;">
                <button class="dlg-select-button" name="select" data-app-text="deleting"></button>
            </div>
            <div class="command" style="position: absolute; right: 10px; top: 5px;">
                <button class="dlg-close-button" name="close" data-app-text="close"></button>
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
