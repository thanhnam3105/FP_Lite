<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CommentDialog.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.Dialog.CommentDialog" %>

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
          /*position: absolute;*/
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
        // TODO：画面の仕様に応じて以下のダイアログ名を変更してください。
        $.dlg.register("CommentDialog", {
            // TODO：ここまで
            initialize: function (context) {
                //// 変数宣言 -- Start
                var elem = context.element,
                    changeSet = new App.ui.page.changeSet(),
                    firstCol = 1,
                    duplicateCol = 999,
                    currentRow = 0,
                    currentCol = firstCol,
                    commentCodeCol = 1,
                    pageLangText = App.ui.pagedata.lang(App.ui.page.lang),
                    validationSetting = App.ui.pagedata.validation(App.ui.page.lang),
                    errRows = new Array();   // エラー行の格納用

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

                //var dialog_grid = elem.find(".dialog-result-list [name='dialog-list']"),
                var dialog_grid = elem.find("#dialog-list"),
                    querySettingDialog = { skip: 0, top: 500, count: 0 },
                    isDialogLoading = false,
                    lastScrollTopDialog = 0,
                    saveConfirmDialog = elem.find(".save-confirm-dialog"),
                    closeConfirmDialog = elem.find(".close-confirm-dialog");

                // パラメータからグリッドのIDを設定
                dialog_grid.attr("id", context.data.id);

                // パラメータからmultiselectを設定
                var multiselect = false;
                if (context.data.multiselect) {
                    multiselect = context.data.multiselect;
                }

                saveConfirmDialog.dlg();
                /// <summary>ダイアログを開きます。</summary>
                var showSaveConfirmDialog = function () {
                    saveConfirmDialogNotifyInfo.clear();
                    saveConfirmDialogNotifyAlert.clear();
                    saveConfirmDialog.draggable(true);
                    App.ui.block.show(".dialog-content");   // ダイアログをロック
                    saveConfirmDialog.dlg("open");
                };
                /// <summary>ダイアログを閉じます。</summary>
                var closeSaveConfirmDialog = function () {
                    App.ui.block.close(".dialog-content");  // ダイアログのロック解除
                    saveConfirmDialog.dlg("close");
                };
                // ダイアログ情報メッセージの設定
                var saveConfirmDialogNotifyInfo = App.ui.notify.info(saveConfirmDialog, {
                    container: ".save-confirm-dialog .dialog-slideup-area .info-message",
                    messageContainerQuery: "ul",
                    show: function () {
                        saveConfirmDialog.find(".info-message").show();
                    },
                    clear: function () {
                        saveConfirmDialog.find(".info-message").hide();
                    }
                });
                // ダイアログ警告メッセージの設定
                var saveConfirmDialogNotifyAlert = App.ui.notify.alert(saveConfirmDialog, {
                    container: ".save-confirm-dialog .dialog-slideup-area .alert-message",
                    messageContainerQuery: "ul",
                    show: function () {
                        saveConfirmDialog.find(".alert-message").show();
                    },
                    clear: function () {
                        saveConfirmDialog.find(".alert-message").hide();
                    }
                });

                closeConfirmDialog.dlg();
                /// <summary>ダイアログを開きます。</summary>
                var showCloseConfirmDialog = function () {
                    closeConfirmDialogNotifyInfo.clear();
                    closeConfirmDialogNotifyAlert.clear();
                    closeConfirmDialog.draggable(true);
                    App.ui.block.show(".dialog-content");   // ダイアログをロック
                    closeConfirmDialog.dlg("open");
                };
                /// <summary>ダイアログを閉じます。</summary>
                var closeCloseConfirmDialog = function () {
                    App.ui.block.close(".dialog-content");  // ダイアログのロック解除
                    closeConfirmDialog.dlg("close");
                };
                // ダイアログ情報メッセージの設定
                var closeConfirmDialogNotifyInfo = App.ui.notify.info(closeConfirmDialog, {
                    container: ".close-confirm-dialog .dialog-slideup-area .info-message",
                    messageContainerQuery: "ul",
                    show: function () {
                        closeConfirmDialog.find(".info-message").show();
                    },
                    clear: function () {
                        closeConfirmDialog.find(".info-message").hide();
                    }
                });
                // ダイアログ警告メッセージの設定
                var closeConfirmDialogNotifyAlert = App.ui.notify.alert(closeConfirmDialog, {
                    container: ".close-confirm-dialog .dialog-slideup-area .alert-message",
                    messageContainerQuery: "ul",
                    show: function () {
                        closeConfirmDialog.find(".alert-message").show();
                    },
                    clear: function () {
                        closeConfirmDialog.find(".alert-message").hide();
                    }
                });

                // ダイアログ内のグリッド定義
                dialog_grid.jqGrid({
                    // 列名の定義
                    colNames: [
                        pageLangText.cd_comment.text
                        , pageLangText.comment.text
                        , pageLangText.mishiyoFlag.text
                        , pageLangText.seq_comment_dlg.text
                        , pageLangText.torokuDate.text
                        , pageLangText.torokuCode.text
                        , pageLangText.torokuDate.text
                        , pageLangText.torokuCode.text
                    ],
                    // 列モデルの定義
                    colModel: [
                        { name: 'cd_comment', width: 100, editable: true, align: "center", sorttype: "text" },
                        { name: 'comment', width: 550, editable: true, hidden: false, sorttype: "text" },
                        { name: 'flg_mishiyo', width: 0, editable: false, hidden: true, hidedlg: true,
                            edittype: 'checkbox', editoptions: { value: "1:0" }, formatter: 'checkbox', align: 'center',
                            formatoptions: { disabled: false }, classes: 'checkbox-cell'
                        },
                        { name: 'no_seq', width: 0, hidden: true, hidedlg: true },
                        { name: 'dt_create', width: 0, hidden: true, hidedlg: true },
                        { name: 'cd_create', width: 0, hidden: true, hidedlg: true },
                        { name: 'dt_update', width: 0, hidden: true, hidedlg: true },
                        { name: 'cd_update', width: 0, hidden: true, hidedlg: true }
                    ],
                    datatype: "local",
                    shrinkToFit: false,
                    multiselect: multiselect,
                    rownumbers: true,
                    cellEdit: true,
                    hoverrows: false,
                    cellsubmit: 'clientArray',
                    beforeEditCell: function (selectedRowId, cellName, value, iRow, iCol) {
                        currentRow = iRow;
                        currentCol = iCol;
                    },
                    afterEditCell: function (selectedRowId, cellName, value, iRow, iCol) {
                        // Enter キーでカーソルを移動
                        dialog_grid.moveCell(cellName, iRow, iCol);
                    },
                    beforeSaveCell: function (selectedRowId, cellName, value, iRow, iCol) {
                        // セルバリデーション
                        validateCell(selectedRowId, cellName, value, iCol);
                    },
                    afterSaveCell: function (selectedRowId, cellName, value, iRow, iCol) {
                        // 関連項目の設定
                        //setRelatedValue(selectedRowId, cellName, value, iCol);
                        // 更新状態の変更データの設定
                        var changeData = setUpdatedChangeData(dialog_grid.getRowData(selectedRowId));
                        // 更新状態の変更セットに変更データを追加
                        changeSet.addUpdated(selectedRowId, cellName, value, changeData);
                        // 関連項目の設定を変更セットに反映
                        // setRelatedChangeData(selectedRowId, cellName, value, changeData);
                    },
                    loadComplete: function () {
                        var ids = dialog_grid.jqGrid('getDataIDs');
                        if (ids.length > 0) {
                            // グリッドの先頭行選択
                            $("#" + 1).removeClass("ui-state-highlight").find("td").click();
                            // チェックボックスイベントの定義
                            //elem.find(".checkbox-cell").on("click", clickCheckBox);
                        }
                    },
                    //gridComplete: function () {
                    //},
                    //onCellSelect: function (rowid, icol, cellcontent) {
                    //},
                    ondblClickRow: function (rowid) {
                        $("#" + rowid).removeClass("ui-state-highlight").find("td").click();
                        // 選択処理
                        selectClick();
                    },
                    height: 160
                });

                /*
                /// <summary>チェックボックス操作時のグリッド値更新を行います</summary>
                var clickCheckBox = function(e) {
                var target = e.target;
                //(target.type === "checkbox") ? alert("ok") : alert("not");

                if (target.type === "checkbox") {
                saveEdit();
                target.focus();
                var iCol = $(this).parent("td").parent("tr").find("td").index($(this).parent("td")),
                //selectedRowId = $(this).parent("td").parent("tr").attr("id"),
                //selectedRowId = getSelectedRowId(true),
                cellName = "flg_mishiyo",
                value;
                var selectedRowId = getSelectedRowId(true);

                // 更新状態の変更データの設定
                var changeData = setUpdatedChangeData(dialog_grid.getRowData(selectedRowId));
                value = changeData[cellName];

                // 更新状態の変更セットに変更データを追加
                changeSet.addUpdated(selectedRowId, cellName, value, changeData);
                }
                };
                */

                /// <summary>クエリオブジェクトの設定</summary>
                var queryDialog = function () {
                    var query = {
                        // TODO: 画面の仕様に応じて以下のエンドポイントを変更してください。
                        url: "../Services/FoodProcsService.svc/ma_comment",
                        filter: createFilterDialog(),
                        orderby: "cd_comment",
                        select: "no_seq, cd_comment, comment, flg_mishiyo, dt_create, cd_create, dt_update, cd_update",
                        skip: querySettingDialog.skip,
                        top: querySettingDialog.top,
                        // TODO：ここまで
                        inlinecount: "allpages"
                    }
                    return query;
                };
                var createFilterDialog = function () {
                    var criteria = elem.find(".dialog-search-criteria").toJSON(),
                        filters = [];
                    // TODO: 画面の仕様に応じて以下のフィルター条件を変更してください。
                    if (!App.isUndefOrNull(criteria.nm_comment)) {
                        filters.push("substringof('" + encodeURIComponent(criteria.nm_comment) + "', cd_comment) "
                            + "or substringof('" + encodeURIComponent(criteria.nm_comment) + "', comment)");
                    }
                    // TODO：ここまで

                    return filters.join(" and ");
                };
                /// 検索処理
                var searchItemsDialog = function (_query) {
                    if (isDialogLoading === true) {
                        return;
                    }
                    isDialogLoading = true;

                    App.ajax.webget(
                        App.data.toODataFormat(_query)
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
                    lastScrollTopDialog = 0;
                    displayCountDialog();
                    // 情報メッセージのクリア
                    dialogNotifyInfo.clear();
                    // エラーメッセージのクリア
                    dialogNotifyAlert.clear();
                    // changeSetの中身をクリア
                    changeSet = new App.ui.page.changeSet();
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
                    querySettingDialog.skip = querySettingDialog.skip + result.d.results.length;
                    var resultCount = parseInt(result.d.__count);
                    querySettingDialog.count = resultCount;

                    if (resultCount > querySettingDialog.top) {
                        dialogNotifyAlert.message(MS0011).show();
                        querySettingDialog.count = querySettingDialog.top;
                    }
                    else {
                        querySettingDialog.count = resultCount;
                    }

                    // グリッドの表示件数を更新
                    dialog_grid.setGridParam({ rowNum: querySettingDialog.skip });
                    displayCountDialog();
                    // データバインド
                    var currentData = dialog_grid.getGridParam("data").concat(result.d.results);
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
                        selCode.push(row.cd_comment);
                        selName.push(row.comment);
                    }
                    // TODO：ここまで
                    return [selCode.join(", "), selName.join(", ")];
                };

                /// <summary>セルの関連項目を設定します。</summary>
                /// <param name="selectedRowId">選択行ID</param>
                /// <param name="cellName">列名</param>
                /// <param name="value">元となる項目の値</param>
                /// <param name="iCol">項目の列番号</param>
                //var setRelatedValue = function (selectedRowId, cellName, value, iCol) {
                //    // TODO：画面の仕様に応じて以下の関連項目を設定を変更してください。
                //    // TODO：ここまで
                //};

                /// <summary>追加状態の変更セットに追加する変更データの設定を行います。</summary>
                /// <param name="newRow">新規行データ</param>
                var setCreatedChangeData = function (newRow) {
                    var changeData = {
                        "no_seq": newRow.no_seq,
                        "cd_comment": newRow.cd_comment,
                        "comment": newRow.comment,
                        "flg_mishiyo": newRow.flg_mishiyo,
                        "dt_create": newRow.dt_create,
                        "cd_create": newRow.cd_create,
                        "dt_update": new Date(),
                        "cd_update": App.ui.page.user.Code
                    };

                    return changeData;
                };

                /// <summary>更新状態の変更セットに追加する変更データの設定を行います。</summary>
                /// <param name="row">選択行</param>
                var setUpdatedChangeData = function (row) {
                    var changeData = {
                        "no_seq": row.no_seq,
                        "cd_comment": row.cd_comment,
                        "comment": row.comment,
                        "flg_mishiyo": row.flg_mishiyo,
                        "dt_create": row.dt_create,
                        "cd_create": row.cd_create,
                        "dt_update": new Date(),
                        "cd_update": App.ui.page.user.Code
                    };

                    return changeData;
                };

                /// <summary>グリッドの選択行の行IDを取得します。 </summary>
                var getSelectedRowId = function (isAdd) {
                    var selectedRowId = dialog_grid.getGridParam("selrow"),
                    ids = dialog_grid.getDataIDs(),
                    recordCount = dialog_grid.getGridParam("records");
                    // レコードがない場合は処理を抜ける
                    if (recordCount == 0) {
                        if (!isAdd) {
                            // 情報メッセージのクリア
                            dialogNotifyInfo.clear();
                            dialogNotifyInfo.message(pageLangText.noRecords.text).show();
                        }
                        return;
                    }
                    // 選択行なしの場合の行選択
                    if (App.isUnusable(selectedRowId)) {
                        // selectedRowId = ids[recordCount - 1]; // 最終行
                        selectedRowId = ids[0]; // 先頭行
                    }
                    currentRow = elem.find('#' + selectedRowId)[0].rowIndex;

                    return selectedRowId;
                };
                /// <summary>新規行データの設定を行います。</summary>
                var setAddData = function () {
                    var addData = {
                        "cd_comment": "",
                        "comment": "",
                        "flg_mishiyo": pageLangText.falseFlg.text,
                        "dt_create": new Date(),
                        "cd_create": App.ui.page.user.Code,
                        "dt_update": new Date(),
                        "cd_update": App.ui.page.user.Code
                    };

                    return addData;
                };

                /// <summary>新規行を追加します。</summary>
                var addData = function (e) {
                    // 選択行のID取得
                    var selectedRowId = getSelectedRowId(true),
                    position = "after";
                    //position = "before";
                    // 新規行データの設定
                    var newRowId = App.uuid(),
                    addData = setAddData();
                    if (App.isUndefOrNull(selectedRowId)) {
                        // 末尾にデータ追加
                        dialog_grid.addRowData(newRowId, addData);
                        currentRow = 0;
                    }
                    else {
                        // セル編集内容の保存
                        dialog_grid.saveCell(currentRow, currentCol);
                        // 選択行の任意の位置にデータ追加
                        dialog_grid.addRowData(newRowId, addData, position, selectedRowId);
                    }
                    // 追加状態の変更セットに変更データを追加
                    changeSet.addCreated(newRowId, setCreatedChangeData(addData));
                    // セルを選択して入力モードにする
                    dialog_grid.editCell(currentRow + 1, firstCol, true);
                };
                /// <summary>追加ボタンクリック時のイベント処理を行います。</summary>
                elem.find(".add-button").on("click", addData);

                /// <summary>カレント行のエラーメッセージを削除します。</summary>
                /// <param name="selectedRowId">選択行ID</param>
                var removeAlertRow = function (selectedRowId) {
                    var unique,
                        colModel = dialog_grid.getGridParam("colModel");

                    for (var i = 0; i < colModel.length; i++) {
                        unique = selectedRowId + "_" + i;
                        dialogNotifyAlert.remove(unique);
                    }
                };

                /// <summary>削除状態の変更セットに追加する変更データの設定を行います。</summary>
                /// <param name="row">選択行</param>
                var setDeletedChangeData = function (row) {
                    var changeData = {
                        "no_seq": row.no_seq,
                        "cd_comment": row.cd_comment
                    };

                    return changeData;
                };

                /// <summary>行を削除します。</summary>
                /// <param name="e">イベントデータ</param>
                var deleteData = function (e) {
                    // 選択行のID取得
                    var selectedRowId = getSelectedRowId();
                    if (App.isUndefOrNull(selectedRowId)) {
                        return;
                    }
                    // セル編集内容の保存
                    dialog_grid.saveCell(currentRow, currentCol);
                    // カレント行のエラーメッセージを削除
                    removeAlertRow(selectedRowId);
                    // 削除状態の変更データの設定
                    var changeData = setDeletedChangeData(dialog_grid.getRowData(selectedRowId));
                    // 削除状態の変更セットに変更データを追加
                    changeSet.addDeleted(selectedRowId, changeData);
                    // 選択行の行データ削除
                    dialog_grid.delRowData(selectedRowId);
                    if (dialog_grid.getGridParam("records") > 0) {
                        // セルを選択して入力モードにする
                        dialog_grid.editCell(currentRow === 1 ? currentRow : currentRow - 1, currentCol, true);
                    }
                };
                /// <summary>削除ボタンクリック時のイベント処理を行います。</summary>
                $(".delete-button").on("click", deleteData);

                // <summary>データに変更がないかどうかを返します。</summary>
                var noChange = function () {
                    return (App.isUnusable(changeSet) || changeSet.noChange());
                };
                /// <summary>編集内容の保存</summary>
                var saveEdit = function () {
                    dialog_grid.saveCell(currentRow, currentCol);
                };
                /// <summary>更新データを取得します。</summary>
                var getPostData = function () {
                    return changeSet.getChangeSet();
                };

                /// <summary>データ変更エラーハンドリングを行います。</summary>
                /// <param name="result">エラーの戻り値</param>
                var handleSaveDataError = function (result) {
                    var ret = JSON.parse(result.rawText);

                    if (!App.isArray(ret) && App.isUndefOrNull(ret.Updated) && App.isUndefOrNull(ret.Deleted)) {
                        dialogNotifyAlert.message(result.message).show();
                        return;
                    }

                    var ids = dialog_grid.getDataIDs(),
                        newId,
                        value,
                        unique,
                        current,
                        checkCol = commentCodeCol;   // 画面の仕様に応じて変更する

                    // データ整合性エラーのハンドリングを行います。
                    if (App.isArray(ret) && ret.length > 0) {
                        for (var i = 0; i < ret.length; i++) {
                            // TODO: 画面の仕様に応じて以下の値を変更します。
                            if (ret[i].InvalidationName === "keys") {
                                // TODO: ここまで

                                for (var j = 0; j < ids.length; j++) {
                                    // TODO: 画面の仕様に応じて以下の値を変更します。
                                    var errRowId = ids[j];
                                    value = dialog_grid.getCell(errRowId, checkCol);
                                    retValue = ret[i].Data.cd_comment;
                                    // TODO: ここまで

                                    if (value === retValue) {
                                        // TODO: 画面の仕様に応じて以下のロジックを変更します。
                                        unique = errRowId + "_" + checkCol;
                                        // エラー行を追加
                                        errRows.push(errRowId);

                                        // エラーメッセージの表示
                                        dialogNotifyAlert.message(
                                            pageLangText.invalidation.text + ret[i].Message, unique).show();
                                        // 対象セルの背景変更
                                        dialog_grid.setCell(errRowId, checkCol, ret[i].Data.cd_comment, { background: '#ff6666' });
                                        // TODO: ここまで
                                    }
                                }
                            }
                        }
                    }
                };

                // <summary>ダイアログの閉じるボタンクリック時のイベント処理を行います。</summary>
                elem.find(".dlg-close-button").on("click", function () {
                    saveEdit();
                    if (!noChange()) {
                        showCloseConfirmDialog();
                    }
                    else {
                        context.close("canceled");
                    }
                });

                // 選択ボタンクリック時のチェック処理を行います。
                var checkSelectClick = function () {
                    var isChecked = true,
                        selectedRowId = getSelectedRowId(false);

                    // 明細が変更されていないこと
                    if (!noChange()) {
                        dialogNotifyAlert.message(
                            App.str.format(pageLangText.changedNotDo.text,
                            pageLangText.meisai.text, pageLangText.select.text)
                        ).show();
                        return;
                    }

                    // 選択したコメントの未使用フラグが「未使用」だった場合
                    /*
                    var flgMishiyo = dialog_grid.getCell(selectedRowId, "flg_mishiyo");
                    if (flgMishiyo == pageLangText.mishiyoMishiyoFlg.text) {
                    isChecked = false;
                    dialogNotifyAlert.message(
                    App.str.format(pageLangText.flgMishiyo.text,
                    pageLangText.comment.text + pageLangText.cd_comment.text)
                    ).show();
                    }
                    */

                    return isChecked;
                };
                // 選択処理を行います。
                var selectClick = function () {
                    // メッセージのクリア
                    dialogNotifyInfo.clear();
                    dialogNotifyAlert.clear();

                    // 編集内容の保存
                    saveEdit();

                    // チェック
                    if (!checkSelectClick()) {
                        return;
                    }

                    var returnCode = returnSelectedDialog();
                    if (returnCode != "noSelect") {
                        context.close(returnCode);
                    }
                };
                // <summary>ダイアログの選択ボタンクリック時のイベント処理を行います。</summary>
                elem.find(".dlg-select-button").on("click", selectClick);

                // グリッドのバリデーション設定
                var v = Aw.validation({
                    items: validationSetting
                });
                $(".list-part-detail-content").validation(v);

                /// <summary>カレントのセルバリデーションを実行します。</summary>
                /// <param name="selectedRowId">選択行ID</param>
                /// <param name="cellName">列名</param>
                /// <param name="value">エラー項目の値</param>
                /// <param name="iCol">エラー項目の列番号</param>
                var validateCell = function (selectedRowId, cellName, value, iCol) {
                    var unique = selectedRowId + "_" + iCol,
                        val = {},
                        result;
                    // エラーメッセージの解除
                    dialogNotifyAlert.remove(unique);
                    dialog_grid.setCell(selectedRowId, iCol, value, { background: 'none' });
                    val[cellName] = value;
                    // バリデーションのコールバック関数の実行をスキップ
                    result = v.validate(val, { suppressCallback: false });
                    if (result.errors.length) {
                        // エラーメッセージの表示
                        dialogNotifyAlert.message(result.errors[0].message, unique).show();

                        // 対象セルの背景変更
                        dialog_grid.setCell(selectedRowId, iCol, value, { background: '#ff6666' });
                        return false;
                    }
                    return true;
                };
                /// <summary>カレントの行バリデーションを実行します。</summary>
                /// <param name="selectedRowId">選択行ID</param>
                var validateRow = function (selectedRowId) {
                    var isValid = true,
                        colModel = dialog_grid.getGridParam("colModel"),
                        iRow = elem.find('#' + selectedRowId)[0].rowIndex;
                    for (var i = 1; i < colModel.length; i++) {
                        // セルを選択して入力モードを解除する
                        dialog_grid.editCell(iRow, i, false);
                        // セルバリデーション
                        if (!validateCell(selectedRowId, colModel[i].name, dialog_grid.getCell(selectedRowId, colModel[i].name), i)) {
                            isValid = false;
                        }
                    }
                    return isValid;
                };
                /// <summary>変更セットのバリデーションを実行します。</summary>
                var validateChangeSet = function () {
                    for (p in changeSet.changeSet.created) {
                        if (!changeSet.changeSet.created.hasOwnProperty(p)) {
                            continue;
                        }
                        // カレントの行バリデーションを実行
                        if (!validateRow(p)) {
                            return false;
                        }
                    }
                    for (p in changeSet.changeSet.updated) {
                        if (!changeSet.changeSet.updated.hasOwnProperty(p)) {
                            continue;
                        }
                        // カレントの行バリデーションを実行
                        if (!validateRow(p)) {
                            return false;
                        }
                    }
                    return true;
                };

                /// <summary>エラーのセル情報を取得します。</summary>
                /// <param name="unique">エラーを特定するキー</param>
                var getAlertInfo = function (unique) {
                    var info = {},
                    splits;
                    splits = unique.split("_");
                    info.selectedRowId = splits[0];
                    info.iCol = parseInt(splits[1], 10);

                    return info;
                };
                /// <summary>エラー一覧クリック時の処理を行います。</summary>
                /// <param name="data">エラー情報</param>
                var handleNotifyAlert = function (data) {
                    //data.unique でキーが取得できる
                    //data.handledにtrueを指定することでデフォルトの動作(キーがHTMLElementの場合にフォーカスを当てる処理)の実行をキャンセルする

                    // グリッド内のエラーの場合、data.uniqueがstringになるため以下の条件分岐を追加
                    if (!App.isStr(data.unique)) {
                        data.handled = false;
                        return;
                    }
                    data.handled = true;

                    // エラーのセル情報を取得
                    var info = getAlertInfo(data.unique),
                    iRow = $('#' + info.selectedRowId)[0].rowIndex;

                    // 同時実行制御エラーの場合は編集可能なセルの先頭列を選択
                    if (info.iCol === duplicateCol) {
                        info.iCol = firstCol;
                    }

                    // セルを選択して入力モードにする
                    dialog_grid.editCell(iRow, info.iCol, true);
                };
                /// <summary>エラー一覧クリック時のイベント処理を行います。</summary>
                $(dialogNotifyAlert).on("itemselected", function (e, data) {
                    // エラー一覧クリック時の処理
                    handleNotifyAlert(data);
                });

                /// <summary>変更を保存します。</summary>
                /// <param name="e">イベントデータ</param>
                var saveData = function (e) {
                    // 確認ダイアログを閉じる
                    closeSaveConfirmDialog();
                    // 情報メッセージのクリア
                    dialogNotifyInfo.clear();
                    // ローディングの表示
                    App.ui.loading.show(pageLangText.nowSaving.text, ".dialog-content");

                    var saveUrl = "../api/CommentMaster";

                    App.ajax.webpost(
                        saveUrl, getPostData()
                    ).done(function (result) {
                        // 検索前の状態に初期化
                        clearStateDialog();
                        dialogNotifyInfo.message(pageLangText.successMessage.text).show();
                        // データ検索
                        searchItemsDialog(new queryDialog());
                    }).fail(function (result) {
                        // データ変更エラーハンドリングを行います。
                        handleSaveDataError(result);
                        App.ui.loading.close(".dialog-content");
                    }).always(function () {
                        // ローディングの終了
                        App.ui.loading.close(".dialog-content");
                    });
                };

                /// <summary>重複エラーで変えたセルの背景色をクリアする</summary>
                /// <param name="errIds">対象行のID配列</param>
                var clearErrBgcorror = function (errIds) {
                    for (var i = 0; i < errIds.length; i++) {
                        var id = errIds[i];
                        // 対象セルの背景リセット
                        dialog_grid.setCell(id, commentCodeCol, '', { background: 'none' });
                    }
                };
                /// <summary>保存前チェック</summary>
                var saveCheckDialog = function (e) {
                    // 情報メッセージのクリア
                    dialogNotifyInfo.clear();
                    // 編集内容の保存
                    saveEdit();
                    // 内部エラーになった行の背景色をすべてリセット
                    clearErrBgcorror(errRows);
                    // 変更セット内にバリデーションエラーがある場合は処理を抜ける
                    if (!validateChangeSet()) {
                        return;
                    }
                    // エラーメッセージのクリア
                    dialogNotifyAlert.clear();
                    // 変更がない場合は処理を抜ける
                    if (noChange()) {
                        dialogNotifyInfo.message(pageLangText.noChange.text).show();
                        return;
                    }
                    // 保存確認ダイアログを表示
                    showSaveConfirmDialog();
                };

                /// <summary>保存ボタンクリック時のイベント処理を行います。</summary>
                elem.find(".dlg-save-button").on("click", saveCheckDialog);

                /// <summary>ダイアログの検索ボタンクリック時のイベント処理を行います。</summary>
                elem.find(".dlg-find-button").on("click", function () {
                    clearStateDialog();
                    searchItemsDialog(new queryDialog());
                });

                /// <summary>ダイアログを開きます。</summary>
                this.reopen = function () {
                    // ダイアログ再オープン時の処理
                    clearStateDialog();
                    // 検索条件をクリア
                    $("#con_nm_comment").val("");
                    // 検索処理
                    searchItemsDialog(new queryDialog());
                };

                /// <summary>保存確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
                $(".save-confirm-dialog .dlg-yes-button").on("click", saveData);
                /// <summary>保存確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
                $(".save-confirm-dialog .dlg-no-button").on("click", closeSaveConfirmDialog);

                /// <summary>閉じる確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
                $(".close-confirm-dialog .dlg-yes-button").on("click", function () {
                    closeCloseConfirmDialog();
                    context.close("canceled");
                });
                /// <summary>閉じる確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
                $(".close-confirm-dialog .dlg-no-button").on("click", closeCloseConfirmDialog);

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
                <h4 data-app-text="commentDialog"></h4>
            </div>
            <div class="dialog-body" style="padding: 10px; width: 95%;">
                <!-- 検索条件 -->
                <div class="dialog-search-criteria">
                    <div class="part-body" >
                        <ul class="item-list">
                            <li>
                                <label>
                                    <span class="item-label" data-app-text="comment" style="width: 80px;"></span>
                                    <input type="text" id="con_nm_comment" name="nm_comment" style="width: 300px;" maxlength="100" />
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
                    <h3 id="listHeader" class="part-header" >
                        <span data-app-text="resultList" style="padding-right: 10px; padding-bottom: 4px;" id="list-results"></span>
                        <span class="list-count list-count-dialog" id="list-count"></span>
                    </h3>
                    <div class="item-command">
                        <button type="button" class="add-button" name="add-button"><span class="icon"></span><span data-app-text="add"></span></button>
                        <button type="button" class="delete-button" name="delete-button"><span class="icon"></span><span data-app-text="del"></span></button>
                    </div>
                    <div class="part-body" style="height:180px;">
                        <table id="dialog-list"></table>
                    </div>
                </div>
            </div>
        <!-- TODO: ここまで  -->
            <div class="dialog-footer">
                <div class="command" style="position: absolute; left: 10px; top: 5px">
                    <button class="dlg-save-button" name="dlg-save-button" data-app-text="save"></button>
                </div>
                <div class="command" style="position: absolute; right: 115px; top: 5px">
                    <button class="dlg-select-button" name="dlg-select-button" data-app-text="select"></button>
                </div>
                <div class="command" style="position: absolute; right: 5px; top: 5px;">
                    <button class="dlg-close-button" name="dlg-close-button" data-app-text="close"></button>
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

        <!-- TODO: 画面の仕様に応じて以下のダイアログの設定を変更してください。 -->
        <div class="save-confirm-dialog" style="display: none;">
            <div class="dialog-header">
                <h4 data-app-text="confirmTitle"></h4>
            </div>
            <div class="dialog-body" style="padding: 10px; width: 100%;">
                <div class="part-body">
                    <span data-app-text="saveConfirm"></span>
                </div>
            </div>
            <div class="dialog-footer">
                <div class="command" style="position: absolute; left: 10px; top: 5px">
                    <button class="dlg-yes-button" name="dlg-yes-button" data-app-text="yes"></button>
                </div>
                <div class="command" style="position: absolute; right: 5px; top: 5px;">
                    <button class="dlg-no-button" name="dlg-no-button" data-app-text="no"></button>
                </div>
            </div>
        </div>
        <div class="close-confirm-dialog" style="display: none;">
            <div class="dialog-header">
                <h4 data-app-text="confirmTitle"></h4>
            </div>
            <div class="dialog-body" style="padding: 10px; width: 100%;">
                <div class="part-body">
                    <span data-app-text="closeConfirm"></span>
                </div>
            </div>
            <div class="dialog-footer">
                <div class="command" style="position: absolute; left: 10px; top: 5px">
                    <button class="dlg-yes-button" name="dlg-yes-button" data-app-text="yes"></button>
                </div>
                <div class="command" style="position: absolute; right: 5px; top: 5px;">
                    <button class="dlg-no-button" name="dlg-no-button" data-app-text="no"></button>
                </div>
            </div>
        </div>
        <!-- TODO: ここまで  -->
    </div>

</body>
</html>
