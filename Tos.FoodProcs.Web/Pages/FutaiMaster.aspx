<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="FutaiMaster.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.FutaiMaster" %>

<asp:Content ID="Content1" ContentPlaceHolderID="IncludeContent" runat="server">
    <script src="<%=ResolveUrl("~/Resources/pages/pagedata-futaimaster." + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
    <script src="<%=ResolveUrl("~/Resources/grid/grid.locale-" + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        /* 画面デザイン -- Start */
        
        /* TODO：画面の仕様に応じて以下のスタイルを変更してください。 */
        /* ヘッダー折り返し用の設定 */
        .ui-jqgrid .ui-jqgrid-htable th 
        {
            height:auto;
            padding: 0 2px 0 2px;
        }
        .ui-jqgrid .ui-jqgrid-htable th div 
        {
            overflow: hidden;
            position:relative;
            height:auto;
        }
        .ui-th-column, .ui-jqgrid .ui-jqgrid-htable th.ui-th-column 
        {
            overflow: hidden;
            white-space: nowrap;
            text-align:center;
            border-top : 0px none;
            border-bottom : 0px none;
            vertical-align:middle;
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
            var pageLangText = App.ui.pagedata.lang(App.ui.page.lang),
                validationSetting = App.ui.pagedata.validation(App.ui.page.lang),
                querySetting = { skip: 0, top: 500, count: 0 },
                isDataLoading = false;

            // グリッドコントロール固有の変数宣言
            var grid = $("#item-grid"),
                lastScrollTop = 0,
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
                changeSet = new App.ui.page.changeSet(),
                firstCol = 1,
                duplicateCol = 999,
                currentRow = 0,
                currentCol = firstCol,
                errRows = new Array();   // エラー行の格納用

            // TODO: ここまで

            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            var flg_delete = false;
            // TODO：ここまで

            // ダイアログ固有の変数宣言
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            var saveConfirmDialog = $(".save-confirm-dialog");
            // TODO：ここまで

            //// 変数宣言 -- End

            //// コントロール定義 -- Start

            // ダイアログ固有のコントロール定義
            saveConfirmDialog.dlg();

            /// <summary>ダイアログを開きます。</summary>
            var showSaveConfirmDialog = function () {
                saveConfirmDialogNotifyInfo.clear();
                saveConfirmDialogNotifyAlert.clear();
                saveConfirmDialog.dlg("open");
            };
            /// <summary>ダイアログを閉じます。</summary>
            var closeSaveConfirmDialog = function () {
                saveConfirmDialog.dlg("close");
            };

            // グリッドコントロール固有のコントロール定義
            grid.jqGrid({
                // TODO：画面の仕様に応じて以下の列名の定義を変更してください。
                colNames: [
                    pageLangText.cd_futai.text + pageLangText.requiredMark.text
                    , pageLangText.nm_futai.text + pageLangText.requiredMark.text
                    , pageLangText.flg_mishiyo.text
                    , pageLangText.ts.text
                    , pageLangText.cd_create.text
                    , pageLangText.dt_create.text
                    , pageLangText.dt_update.text
                ],
                // TODO：ここまで
                // TODO：画面の仕様に応じて以下の列モデルの定義を変更してください。
                colModel: [
                    { name: 'cd_futai', width: 100, hidden: false, editable: true, sorttype: "text" },
                    { name: 'nm_futai', width: 500, hidden: false, editable: true, sorttype: "text" },
                    { name: 'flg_mishiyo', width: 80, editable: true, hidden: false, edittype: 'checkbox',
                        editoptions: { value: "1:0" }, formatter: "checkbox", formatoptions: { disabled: false }, align: 'center'
                    },
                    { name: 'ts', width: 0, hidden: true, hidedlg: true },
                    { name: 'cd_create', width: 0, hidden: true, hidedlg: true },
                    { name: 'dt_create', width: 0, hidden: true, hidedlg: true },
                    { name: 'dt_update', width: 0, hidden: true, hidedlg: true }
                ],
                // TODO：ここまで
                datatype: "local",
                shrinkToFit: false,
                multiselect: false,
                rownumbers: true,
                cellEdit: true,
                onRightClickRow: function (rowid) {
                    $("#" + rowid).removeClass("ui-state-highlight").find("td").click();
                },
                loadonce: true,
                onSortCol: function () {
                    grid.setGridParam({ rowNum: grid.getGridParam("records") });
                },
                cellsubmit: 'clientArray',
                loadComplete: function () {
                    var ids = grid.jqGrid('getDataIDs');
                    for (var i = 0; i < ids.length; i++) {
                        var id = ids[i];
                        if (grid.jqGrid('getCell', id, 'ts')) {
                            grid.jqGrid('setCell', id, 'cd_futai', '', 'not-editable-cell');
                        }
                    }
                },
                gridComplete: function () {
                    // グリッドの先頭行選択
                    var idNum = grid.getGridParam("selrow");
                    if (idNum == null) {
                        $("#1 > td").click();
                    }
                    else {
                        $("#" + idNum).removeClass("ui-state-highlight").find("td").click();
                    }
                },
                beforeEditCell: function (selectedRowId, cellName, value, iRow, iCol) {
                    currentRow = iRow;
                    currentCol = iCol;
                },
                afterEditCell: function (selectedRowId, cellName, value, iRow, iCol) {
                    // Enter キーでカーソルを移動
                    grid.moveCell(cellName, iRow, iCol);
                },
                beforeSaveCell: function (selectedRowId, cellName, value, iRow, iCol) {
                    // セルバリデーション
                    validateCell(selectedRowId, cellName, value, iCol);
                },
                afterSaveCell: function (selectedRowId, cellName, value, iRow, iCol) {
                    // 関連項目の設定
                    //setRelatedValue(selectedRowId, cellName, value, iCol);
                    // 更新状態の変更データの設定
                    var changeData = setUpdatedChangeData(grid.getRowData(selectedRowId));
                    // 更新状態の変更セットに変更データを追加
                    changeSet.addUpdated(selectedRowId, cellName, value, changeData);
                    // 関連項目の設定を変更セットに反映
                    //setRelatedChangeData(selectedRowId, cellName, value, changeData);
                }
            });

            /// <summary>チェックボックス操作時のグリッド値更新を行います</summary>
            $(document).on("click", "#item-grid .jqgrow td :checkbox", function () {
                var iCol = $(this).parent("td").parent("tr").find("td").index($(this).parent("td")),
                    selectedRowId = $(this).parent("td").parent("tr").attr("id"),
                    cellName = grid.getGridParam("colModel")[iCol].name,
                    value;
                saveEdit();
                // 更新状態の変更データの設定
                var changeData = setUpdatedChangeData(grid.getRowData(selectedRowId));
                // 更新値の設定
                value = changeData[cellName];
                // 更新状態の変更セットに変更データを追加
                changeSet.addUpdated(selectedRowId, cellName, value, changeData);
            });

            /// <summary>セルの関連項目を設定します。</summary>
            /// <param name="selectedRowId">選択行ID</param>
            /// <param name="cellName">列名</param>
            /// <param name="value">元となる項目の値</param>
            /// <param name="iCol">項目の列番号</param>
            //var setRelatedValue = function (selectedRowId, cellName, value, iCol) {
            //    // TODO：画面の仕様に応じて以下の関連項目を設定を変更してください。
            //    // TODO：ここまで
            //};

            /// <summary>非表示列設定ダイアログの表示を行います。</summary>
            /// <param name="e">イベントデータ</param>
            var showColumnSettingDialog = function (e) {
                var params = {
                    width: 300,
                    heitht: 230,
                    dataheight: 180,
                    modal: true,
                    drag: true,
                    caption: pageLangText.colchange.text,
                    bCancel: pageLangText.cancel.text,
                    bSubmit: pageLangText.save.text
                };
                grid.setColumns(params);
            };
            /// <summary>グリッドの列変更ボタンクリック時のイベント処理を行います。</summary>
            $(".colchange-button").on("click", showColumnSettingDialog);

            //// コントロール定義 -- End

            //// 操作制御定義 -- Start

            // 操作制御定義を定義します。
            App.ui.pagedata.operation.applySetting(App.ui.page.user.Roles[0], App.ui.page.lang);

            //// 操作制御定義 -- End

            //// 事前データロード -- Start
            /// <summary>データ検索を行います。</summary>
            /// <param name="query">クエリオブジェクト</param>
            var searchItems = function (query) {
                if (isDataLoading === true) {
                    return;
                }
                isDataLoading = true;
                // ローディングの表示
                //$("#list-loading-message").text(
                //    App.str.format(
                //        pageLangText.nowListLoading.text,
                //        querySetting.skip + 1,
                //        querySetting.top
                //    )
                //);
                $("#list-loading-message").text(pageLangText.nowLoading.text);
                App.ajax.webget(
                // WCF Data ServicesのODataシステムクエリオプションを生成
                    App.data.toODataFormat(query)
                ).done(function (result) {
                    // データバインド
                    bindData(result);
                    // 500件検索は初回のみ。次回からは40件ずつ。
                    querySetting.top = 40;

                    // 検索条件を閉じる
                    closeCriteria();
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                }).always(function () {
                    setTimeout(function () {
                        $("#list-loading-message").text("");
                        isDataLoading = false;
                    }, 500);
                });
            };

            // 画面アーキテクチャ共通の事前データロード
            //App.deferred.parallel({
            // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
            // TODO: ここまで
            //}).done(function (result) {
            // TODO: 画面の仕様に応じて以下のサービス呼び出し成功時の処理を変更してください。

            // 検索用ドロップダウンの設定
            // TODO: ここまで
            //}).fail(function (result) {
            //    var length = result.key.fails.length,
            //                messages = [];
            //    for (var i = 0; i < length; i++) {
            //        var keyName = result.key.fails[i];
            //        var value = result.fails[keyName];
            //        messages.push(keyName + " " + value.message);
            //    }
            //    App.ui.page.notifyAlert.message(messages).show();
            //});

            //// 事前データロード -- End

            //// 検索処理 -- Start

            // 画面アーキテクチャ共通の検索処理

            /// <summary>クエリオブジェクトの設定</summary>
            var query = function () {
                var query = {
                    // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                    url: "../Services/FoodProcsService.svc/ma_futai",
                    // TODO: ここまで
                    filter: createFilter(),
                    // TODO: 画面の仕様に応じて以下のソート条件を変更してください。
                    orderby: "cd_futai",
                    // TODO: ここまで
                    skip: querySetting.skip,
                    top: querySetting.top,
                    inlinecount: "allpages"
                }
                return query;
            };
            /// <summary>フィルター条件の設定</summary>
            var createFilter = function () {
                var criteria = $(".search-criteria").toJSON(),
                    filters = [];
                // TODO: 画面の仕様に応じて以下のフィルター条件を変更してください。
                if (!App.isUndefOrNull(criteria.cd_futai) && criteria.cd_futai.length > 0) {
                    filters.push("cd_futai eq " + criteria.cd_futai);
                }
                if (!App.isUndefOrNull(criteria.nm_futai) && criteria.nm_futai.length > 0) {
                    filters.push("nm_futai eq " + criteria.nm_futai);
                }
                // TODO: ここまで

                return filters.join(" and ");
            };

            /// <summary>検索条件を閉じます。</summary>
            var closeCriteria = function () {
                var criteria = $(".search-criteria");
                if (!criteria.find(".part-body").is(":hidden")) {
                    criteria.find(".search-part-toggle").click();
                }
            };
            /// <summary>検索ボタンクリック時のイベント処理を行います。</summary>
            $(".find-button").on("click", function () {
                clearState();
                searchItems(new query());
            });

            // グリッドコントロール固有の検索処理

            /// <summary>検索前の状態に初期化します。</summary>
            var clearState = function () {
                // データクリア
                grid.clearGridData();
                lastScrollTop = 0;
                querySetting.skip = 0;
                querySetting.count = 0;
                displayCount();

                // TODO: 画面の仕様に応じて以下のパラメータ設定を変更してください。
                currentRow = 0;
                currentCol = firstCol;
                // 変更セットの作成
                changeSet = new App.ui.page.changeSet();
                // TODO: ここまで

                // 情報メッセージのクリア
                App.ui.page.notifyInfo.clear();
                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();
            };
            /// <summary>データ取得件数を表示します。</summary>
            var displayCount = function () {
                $("#list-count").text(
                     App.str.format("{0}/{1}", querySetting.skip, querySetting.count)
                );
            };
            /// <summary>データをバインドします。</summary>
            /// <param name="result">検索結果</param>
            var bindData = function (result) {
                querySetting.skip = querySetting.skip + result.d.results.length;
                querySetting.count = parseInt(result.d.__count);
                // グリッドの表示件数を更新
                grid.setGridParam({ rowNum: querySetting.skip });
                displayCount();
                // データバインド
                var currentData = grid.getGridParam("data").concat(result.d.results);
                grid.setGridParam({ data: currentData }).trigger('reloadGrid', [{ current: true}]);
                App.ui.page.notifyInfo.message(
                     App.str.format(pageLangText.searchResultCount.text, querySetting.skip, querySetting.count)
                ).show();
            };
            /// <summary>後続データ検索を行います。</summary>
            /// <param name="target">グリッド</param>
            var nextSearchItems = function (target) {
                var scrollTop = lastScrollTop;
                if (scrollTop === target.scrollTop) {
                    return;
                }
                if (querySetting.skip === querySetting.count) {
                    return;
                }
                lastScrollTop = target.scrollTop;
                if (target.scrollHeight - target.scrollTop <= $(target).outerHeight()) {
                    //更新対象データを初期化します
                    changeSet = new App.ui.page.changeSet();
                    var ids = grid.jqGrid('getDataIDs');
                    //追加された行を削除します
                    for (var i = 0; i < ids.length; i++) {
                        var id = ids[i];
                        if (!grid.jqGrid('getCell', id, 'ts')) {
                            grid.delRowData(id);
                        }
                    }
                    // データ検索
                    searchItems(new query());
                }
            };
            /// <summary>グリッドスクロール時のイベント処理を行います。</summary>
            $(".ui-jqgrid-bdiv").scroll(function (e) {
                // 後続データ検索
                nextSearchItems(this);
            });

            //// 検索処理 -- End

            //// メッセージ表示 -- Start

            // グリッドコントロール固有のメッセージ表示

            /// <summary>カレント行のエラーメッセージを削除します。</summary>
            /// <param name="selectedRowId">選択行ID</param>
            var removeAlertRow = function (selectedRowId) {
                var unique,
                    colModel = grid.getGridParam("colModel");

                for (var i = 0; i < colModel.length; i++) {
                    unique = selectedRowId + "_" + i;
                    App.ui.page.notifyAlert.remove(unique);
                }
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
            }
            /// <summary>エラー一覧クリック時の処理を行います。</summary>
            /// <param name="data">エラー情報</param>
            var handleNotifyAlert = function (data) {
                //data.unique でキーが取得できる
                //data.handledにtrueを指定することでデフォルトの動作(キーがHTMLElementの場合にフォーカスを当てる処理)の実行をキャンセルする
                data.handled = true;
                // エラーのセル情報を取得
                var info = getAlertInfo(data.unique),
                    iRow = $('#' + info.selectedRowId)[0].rowIndex;

                // 同時実行制御エラーの場合は編集可能なセルの先頭列を選択
                if (info.iCol === duplicateCol) {
                    info.iCol = firstCol;
                }

                // セルを選択して入力モードにする
                grid.editCell(iRow, info.iCol, true);
            };

            /// <summary>エラー一覧クリック時のイベント処理を行います。</summary>
            $(App.ui.page.notifyAlert).on("itemselected", function (e, data) {
                // エラー一覧クリック時の処理
                handleNotifyAlert(data);
            });

            // ダイアログ固有のメッセージ表示

            // ダイアログ情報メッセージの設定
            var saveConfirmDialogNotifyInfo = App.ui.notify.info(saveConfirmDialog, {
                container: ".save-confirm-dialog .dialog-slideup-area .info-message",
                messageContainerQuery: "ul",
                show: function () {
                    //saveConfirmDialog.find(".info-message").show();
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
                    //saveConfirmDialog.find(".alert-message").show();
                },
                clear: function () {
                    saveConfirmDialog.find(".alert-message").hide();
                }
            });

            //// メッセージ表示 -- End

            //// データ変更処理 -- Start

            // グリッドコントロール固有のデータ変更処理

            /// <summary>グリッドの選択行の行IDを取得します。 </summary>
            var getSelectedRowId = function (isAdd) {
                var selectedRowId = grid.getGridParam("selrow"),
                    ids = grid.getDataIDs(),
                    recordCount = grid.getGridParam("records");
                // レコードがない場合は処理を抜ける
                if (recordCount == 0) {
                    if (!isAdd) {
                        App.ui.page.notifyInfo.message(pageLangText.noRecords.text).show();
                    }
                    return;
                }
                // 選択行なしの場合は最終行を選択
                if (App.isUnusable(selectedRowId)) {
                    selectedRowId = ids[0];
                }
                currentRow = $('#' + selectedRowId)[0].rowIndex;

                return selectedRowId;
            };
            /// <summary>新規行データの設定を行います。</summary>
            var setAddData = function () {
                // TODO: 画面の仕様に応じて以下の項目を変更してください。
                var addData = {
                    "cd_futai": "",
                    "nm_futai": "",
                    "flg_mishiyo": pageLangText.shiyoMishiyoFlg.text,
                    "cd_update": App.ui.page.user.Code,
                    "cd_create": App.ui.page.user.Code
                };
                // TODO: ここまで

                return addData;
            };
            /// <summary>コピー行データの設定を行います。</summary>
            /// <param name="row">選択行</param>
            var setCopyData = function (row) {
                // TODO: 画面の仕様に応じて以下の項目の初期値を変更してください。
                return $.extend({}, row);
                // TODO: ここまで
            };

            // <summary>現在日時を取得</summary>
            var getDateTime = function () {
                var date = new Date();
                return [date.getFullYear(),
                        ('0' + (date.getMonth() + 1)).slice(-2),
                        ('0' + date.getDate()).slice(-2)]
                        .join('/') + ' ' + date.toLocaleTimeString();
            };

            /// <summary>追加状態の変更セットに追加する変更データの設定を行います。</summary>
            /// <param name="newRow">新規行データ</param>
            var setCreatedChangeData = function (newRow) {
                // TODO: 画面の仕様に応じて以下の項目を変更してください。
                var changeData = {
                    "cd_futai": newRow.cd_futai,
                    "nm_futai": newRow.nm_futai,
                    "flg_mishiyo": newRow.flg_mishiyo,
                    "cd_create": App.ui.page.user.Code,
                    "dt_update": "",
                    "cd_update": App.ui.page.user.Code
                };
                // TODO: ここまで

                return changeData;
            };
            /// <summary>更新状態の変更セットに追加する変更データの設定を行います。</summary>
            /// <param name="row">選択行</param>
            var setUpdatedChangeData = function (row) {
                // TODO: 画面の仕様に応じて以下の項目を変更してください。
                var changeData = {
                    "cd_futai": row.cd_futai,
                    "nm_futai": row.nm_futai,
                    "flg_mishiyo": row.flg_mishiyo,
                    "dt_create": row.dt_create,
                    "cd_create": row.cd_create,
                    "dt_update": "",
                    "cd_update": App.ui.page.user.Code,
                    "ts": row.ts
                };
                // TODO: ここまで

                return changeData;
            };
            /// <summary>削除状態の変更セットに追加する変更データの設定を行います。</summary>
            /// <param name="row">選択行</param>
            var setDeletedChangeData = function (row) {
                // TODO: 画面の仕様に応じて以下の項目を変更してください。
                var changeData = {
                    "cd_futai": row.cd_futai,
                    "ts": row.ts
                };
                // TODO: ここまで

                return changeData;
            };
            /// <summary>関連項目の設定を変更セットに反映します。</summary>
            /// <param name="selectedRowId">選択行ID</param>
            /// <param name="cellName">列名</param>
            /// <param name="value">元となる項目の値</param>
            var setRelatedChangeData = function (selectedRowId, cellName, value, changeData) {
                // TODO: 画面の仕様に応じて以下の処理を変更してください。
                if (cellName === "ArticleName") {
                    changeSet.addUpdated(selectedRowId, "cd_hin", value, changeData);
                }
                // TODO: ここまで
            };


            /// <summary>コピー行を追加します。</summary>
            /// <param name="e">イベントデータ</param>
            var copyData = function (e) {
                // 選択行のID取得
                var selectedRowId = getSelectedRowId(),
                    position = "after";
                if (App.isUndefOrNull(selectedRowId)) {
                    return;
                }
                // 行バリデーションエラーがある場合
                if (!validateRow(selectedRowId)) {
                    return;
                }
                // セル編集内容の保存
                grid.saveCell(currentRow, currentCol);
                // コピー行データの設定
                var newRowId = App.uuid(),
                    copyData = setCopyData(grid.getRowData(selectedRowId));
                // 選択行の任意の位置にデータ追加
                grid.addRowData(newRowId, copyData, position, selectedRowId);
                // 追加状態の変更セットに変更データを追加
                changeSet.addCreated(newRowId, setCreatedChangeData(copyData));
                // セルを選択して入力モードにする
                grid.editCell(currentRow + 1, currentCol, true);
            };
            /// <summary>コピーボタンクリック時のイベント処理を行います。</summary>
            $(".copy-button").on("click", copyData);

            /// <summary>行を削除します。</summary>
            /// <param name="e">イベントデータ</param>
            var deleteData = function (e) {
                // 選択行のID取得
                var selectedRowId = getSelectedRowId();
                if (App.isUndefOrNull(selectedRowId)) {
                    return;
                }
                // セル編集内容の保存
                grid.saveCell(currentRow, currentCol);
                // カレント行のエラーメッセージを削除
                removeAlertRow(selectedRowId);
                // 削除状態の変更データの設定
                var changeData = setDeletedChangeData(grid.getRowData(selectedRowId));
                // 削除状態の変更セットに変更データを追加
                changeSet.addDeleted(selectedRowId, changeData);
                flg_delete = true;
                // 選択行の行データ削除
                grid.delRowData(selectedRowId);
                if (grid.getGridParam("records") > 0) {
                    // セルを選択して入力モードにする
                    grid.editCell(currentRow === 1 ? currentRow : currentRow - 1, currentCol, true);
                }
            };
            /// <summary>削除ボタンクリック時のイベント処理を行います。</summary>
            $(".delete-button").on("click", deleteData);

            /// <summary>新規行を追加します。</summary>
            /// <param name="e">イベントデータ</param>
            var addData = function (e) {
                // 選択行のID取得
                var selectedRowId = getSelectedRowId(true),
                    position = "after";
                // 新規行データの設定
                var newRowId = App.uuid(),
                    addData = setAddData();
                if (App.isUndefOrNull(selectedRowId)) {
                    // 末尾にデータ追加
                    grid.addRowData(newRowId, addData);
                    currentRow = 0;
                }
                else {
                    // セル編集内容の保存
                    grid.saveCell(currentRow, currentCol);
                    // 選択行の任意の位置にデータ追加
                    grid.addRowData(newRowId, addData, position, selectedRowId);
                }
                // 追加状態の変更セットに変更データを追加
                changeSet.addCreated(newRowId, setCreatedChangeData(addData));
                // セルを選択して入力モードにする
                grid.editCell(currentRow + 1, firstCol, true);
            };

            /// <summary>追加ボタンボタンクリック時のイベント処理を行います。</summary>
            $(".add-button").on("click", addData);

            //// データ変更処理 -- End

            //// 保存処理 -- Start

            // グリッドコントロール固有の保存処理

            // <summary>データに変更がないかどうかを返します。</summary>
            var noChange = function () {
                return (App.isUnusable(changeSet) || changeSet.noChange());
            };
            /// <summary>編集内容の保存</summary>
            var saveEdit = function () {
                grid.saveCell(currentRow, currentCol);
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
                    App.ui.page.notifyAlert.message(result.message).show();
                    return;
                }

                var ids = grid.getDataIDs(),
                    newId,
                    value,
                    unique,
                    current,
                // TODO: 画面の仕様に応じて以下の変数を変更します。
                    checkCol = 1;
                // TODO: ここまで

                // データ整合性エラーのハンドリングを行います。
                if (App.isArray(ret) && ret.length > 0) {
                    for (var i = 0; i < ret.length; i++) {
                        // TODO: 画面の仕様に応じて以下の値を変更します。
                        if (ret[i].InvalidationName === "NotExsists") {
                            // TODO: ここまで

                            for (var j = 0; j < ids.length; j++) {
                                // TODO: 画面の仕様に応じて以下の値を変更します。
                                value = grid.getCell(ids[j], checkCol);
                                retValue = ret[i].Data.cd_futai;
                                // TODO: ここまで

                                if (value === retValue) {
                                    // TODO: 画面の仕様に応じて以下のロジックを変更します。
                                    unique = ids[j] + "_" + firstCol;

                                    // エラーメッセージの表示
                                    App.ui.page.notifyAlert.message(
                                        pageLangText.invalidation.text + ret[i].Message, unique).show();
                                    // 対象セルの背景変更
                                    grid.setCell(ids[j], firstCol, ret[i].Data.cd_futai, { background: '#ff6666' });
                                    // TODO: ここまで
                                }
                            }
                        }
                        else if (ret[i].InvalidationName === "DuplicateKey") {

                            for (var j = 0; j < ids.length; j++) {
                                value = grid.getCell(ids[j], checkCol);
                                retValue = ret[i].Data.cd_futai;

                                if (value == retValue) {
                                    unique = ids[j] + "_" + checkCol;
                                    // エラー行を追加
                                    errRows.push(ids[j]);

                                    // エラーメッセージの表示
                                    App.ui.page.notifyAlert.message(
                                            pageLangText.invalidation.text + ret[i].Message, unique).show();
                                    // 対象セルの背景変更
                                    grid.setCell(ids[j], checkCol, retValue, { background: '#ff6666' });
                                }
                            }
                        }
                        else {
                            // 更新オブジェクトから削除を行う
                            for (p in changeSet.changeSet.deleted) {
                                if (!changeSet.changeSet.deleted.hasOwnProperty(p)) {
                                    continue;
                                }

                                // TODO: 画面の仕様に応じて以下の値を変更します。
                                value = changeSet.changeSet.deleted[p].cd_futai;
                                retValue = ret[i].Data.cd_futai;
                                // TODO: ここまで

                                if (value === retValue) {
                                    // 削除状態の変更セットから変更データを削除
                                    changeSet.removeDeleted(p);

                                    // エラーメッセージの表示
                                    App.ui.page.notifyAlert.message(
                                        pageLangText.unDeletableRecord.text + ret[i].Message).show();
                                    //App.ui.page.notifyAlert.message(ret[i].Message).show();
                                }
                            }
                        }
                    }
                }
                // 更新時同時実行制御エラーのハンドリングを行います。
                if (!App.isUndefOrNull(ret.Updated) && ret.Updated.length > 0) {
                    for (var i = 0; i < ret.Updated.length; i++) {
                        for (p in changeSet.changeSet.updated) {
                            if (!changeSet.changeSet.updated.hasOwnProperty(p)) {
                                continue;
                            }

                            // TODO: 画面の仕様に応じて以下の値を変更します。
                            value = grid.getCell(p, checkCol);
                            retValue = ret.Updated[i].Requested.cd_futai;
                            // TODO: ここまで

                            if (value === retValue) {
                                // 更新状態の変更セットから変更データを削除
                                changeSet.removeUpdated(p);

                                // 他のユーザーによって削除されていた場合
                                if (App.isUndefOrNull(ret.Updated[i].Current)) {
                                    // 対象行の削除
                                    grid.delRowData(p);
                                    // メッセージの表示
                                    App.ui.page.notifyAlert.message(
                                        pageLangText.duplicate.text + pageLangText.deletedDuplicate.text).show();
                                }
                                else {
                                    unique = p + "_" + duplicateCol;

                                    // TODO: 画面の仕様に応じて以下の値を変更します。
                                    current = grid.getRowData(p);
                                    current.cd_futai = ret.Updated[i].Current.cd_futai;
                                    current.nm_futai = ret.Updated[i].Current.nm_futai;
                                    current.flg_mishiyo = ret.Updated[i].Current.flg_mishiyo;
                                    current.ts = ret.Updated[i].Current.ts;
                                    // TODO: ここまで

                                    // 対象行の更新
                                    grid.setRowData(p, current);
                                    grid.setCell(ids[p - 1], firstCol, retValue, { background: '#ff6666' });
                                    // エラーメッセージの表示
                                    App.ui.page.notifyAlert.message(
                                        pageLangText.duplicate.text + pageLangText.updatedDuplicate.text, unique).show();
                                }
                            }
                        }
                    }
                }
                // 削除時同時実行制御エラーのハンドリングを行います。
                if (!App.isUndefOrNull(ret.Deleted) && ret.Deleted.length > 0) {
                    for (var i = 0; i < ret.Deleted.length; i++) {
                        for (p in changeSet.changeSet.deleted) {
                            if (!changeSet.changeSet.deleted.hasOwnProperty(p)) {
                                continue;
                            }

                            // TODO: 画面の仕様に応じて以下の値を変更します。
                            value = changeSet.changeSet.deleted[p].cd_futai;
                            retValue = ret.Deleted[i].Requested.cd_futai;
                            // TODO: ここまで

                            if (value === retValue) {
                                // 削除状態の変更セットから変更データを削除
                                changeSet.removeDeleted(p);

                                // 他のユーザーによって削除されていた場合
                                if (App.isUndefOrNull(ret.Deleted[i].Current)) {
                                    // メッセージの表示
                                    App.ui.page.notifyAlert.message(
                                        pageLangText.duplicate.text + pageLangText.deletedDuplicate.text).show();
                                }
                                else {
                                    // メッセージの表示
                                    App.ui.page.notifyAlert.message(
                                        pageLangText.duplicate.text + pageLangText.unDeletedDuplicate.text).show();
                                }
                            }
                        }
                    }
                }
            };

            /// 重複エラーで変えたセルの背景色をクリアする
            /// <param name="errIds">対象行のID配列</param>
            var clearErrBgcorror = function (errIds) {
                for (var i = 0; i < errIds.length; i++) {
                    var id = errIds[i];
                    // 対象セルの背景リセット
                    grid.setCell(id, firstCol, '', { background: 'none' });
                }
            };
            /// <summary>変更を保存します。</summary>
            /// <param name="e">イベントデータ</param>
            var saveData = function (e) {
                closeSaveConfirmDialog();
                // 情報メッセージのクリア
                App.ui.page.notifyInfo.clear();
                // 編集内容の保存
                saveEdit();
                // 変更セット内にバリデーションエラーがある場合は処理を抜ける
                if (!validateChangeSet()) {
                    return;
                }
                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();
                // 変更がない場合は処理を抜ける
                if (noChange()) {
                    App.ui.page.notifyInfo.message(pageLangText.noChange.text).show();
                    return;
                }
                // ローディングの表示
                App.ui.loading.show(pageLangText.nowSaving.text);

                // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                var saveUrl = "../api/FutaiMaster";
                // TODO: ここまで
                App.ajax.webpost(
                    saveUrl, getPostData()
                ).done(function (result) {
                    // 検索前の状態に初期化
                    clearState();
                    App.ui.page.notifyInfo.message(pageLangText.successMessage.text).show();
                    flg_delete = false;
                    // データ検索
                    querySetting.top = 500;
                    searchItems(new query());
                }).fail(function (result) {
                    // データ変更エラーハンドリングを行います。
                    handleSaveDataError(result);
                }).always(function () {
                    // ローディングの終了
                    App.ui.loading.close();
                });
            };
            /// <summary>保存前チェック</summary>
            var checkSave = function () {
                // 情報メッセージのクリア
                App.ui.page.notifyInfo.clear();
                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();
                // 編集内容の保存
                saveEdit();
                // 内部エラーになった行の背景色をすべてリセット
                clearErrBgcorror(errRows);

                if (grid.getDataIDs().length == 0 && flg_delete === false) {
                    App.ui.page.notifyInfo.message(pageLangText.noRecords.text).show();
                    return;
                }

                // 変更がない場合は処理を抜ける
                if (noChange()) {
                    App.ui.page.notifyInfo.message(pageLangText.noChange.text).show();
                    return;
                }
                // 変更セット内にバリデーションエラーがある場合は処理を抜ける
                if (!validateChangeSet()) {
                    return;
                }
                showSaveConfirmDialog();
            };
            /// <summary>保存ボタンクリック時のイベント処理を行います。</summary>
            $(".save-button").on("click", checkSave);

            //// 保存処理 -- End

            // グリッドのバリデーション設定
            var v = Aw.validation({
                items: validationSetting
            });

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
                App.ui.page.notifyAlert.remove(unique);
                grid.setCell(selectedRowId, iCol, value, { background: 'none' });
                val[cellName] = value;
                // バリデーションのコールバック関数の実行をスキップ
                result = v.validate(val, { suppressCallback: false });
                if (result.errors.length) {
                    // エラーメッセージの表示
                    App.ui.page.notifyAlert.message(result.errors[0].message, unique).show();
                    // 対象セルの背景変更
                    grid.setCell(selectedRowId, iCol, value, { background: '#ff6666' });
                    return false;
                }
                return true;
            };

            /// <summary>カレントの行バリデーションを実行します。</summary>
            /// <param name="selectedRowId">選択行ID</param>
            var validateRow = function (selectedRowId) {
                var isValid = true,
                    colModel = grid.getGridParam("colModel"),
                    iRow = $('#' + selectedRowId)[0].rowIndex;
                // 行番号はチェックしない
                for (var i = 1; i < colModel.length; i++) {
                    // セルを選択して入力モードを解除する
                    grid.editCell(iRow, i, false);
                    // セルバリデーション
                    if (!validateCell(selectedRowId, colModel[i].name, grid.getCell(selectedRowId, colModel[i].name), i)) {
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

            //// バリデーション -- End

            /// <summary>ファンクションキー対応処理</summary>
            /// <param name="e">イベントデータ</param>
            var processFunctionKey = function (e) {
                var processed = false;
                // TODO: 画面の仕様に応じて以下のファンクションキー毎の処理を定義します。
                if (e.keyCode === App.ui.keys.F2) {
                    // F2の処理
                    processed = true;
                }
                else if (e.keyCode === App.ui.keys.F3) {
                    //F3の処理
                    processed = true;
                }
                // TODO: ここまで
                if (processed) {
                    //何か処理を行なっていた場合、ブラウザ既定の動作を無効にする
                    e.preventDefault();
                }
            };
            /// <summary>キーダウン時のイベント処理を行います。</summary>
            $(window).on("keydown", processFunctionKey);

            /// <summary>検索パートの開閉ボタン押下時のイベントを定義します。</summary>
            $(".search-part-toggle").on("click", function (e) {
                var target = $(e.target),
                    holder = $(e.target).closest(".content-part"),
                    partheader = holder.find(".part-header"),
                    partbody = holder.find(".part-body"),
                    partfooter = holder.find(".part-footer"),
                    container = $(".content-container");

                container.css("overflow", "hidden");
                $.when(partbody.slideToggle().promise(), partfooter.slideToggle().promise()).done(function () {
                    partheader.toggleClass("part-close");
                    resizeContents();
                    container.css("overflow", "auto");
                });
            });

            /// <summary>コンテンツのリサイズを行います。</summary>
            var resizeContents = function (e) {
                var container = $(".content-container"),
                    searchPart = $(".search-criteria"),
                    resultPart = $(".result-list"),
                    resultPartHeader = resultPart.find(".part-header"),
                    resultPartCommands = resultPart.find(".item-command"),
                    resultPartStyle = resultPart[0].currentStyle || document.defaultView.getComputedStyle(resultPart[0], "");
                resultPart.height(container[0].clientHeight - searchPart[0].clientHeight - ((parseInt(resultPartStyle.marginTop, 10) * 3) || 0));
                grid.setGridWidth(resultPart[0].clientWidth - 5);
                //結果一覧のパートの高さ - パートのヘッダーの高さ - パート内のボタンのコマンドの高さ - jqGrid のカラムヘッダーの高さ
                grid.setGridHeight(resultPart[0].clientHeight - resultPartHeader[0].clientHeight - resultPartCommands[0].clientHeight - resultPart.find(".ui-jqgrid-hdiv")[0].clientHeight - 35);
            };
            /// <summary>画面リサイズ時のイベント処理を行います。</summary>
            $(App.ui.page).on("resized", resizeContents);

            /// <summary>保存確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".save-confirm-dialog .dlg-yes-button").on("click", saveData);
            /// <summary>保存確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".save-confirm-dialog .dlg-no-button").on("click", closeSaveConfirmDialog);

            // 検索処理
            searchItems(new query());

            var onBeforeUnload = function () {
                // データを変更したかどうかは各画面でチェックし、保持する
                if (!noChange()) {
                    return pageLangText.unloadWithoutSave.text;
                }
            }
            $(window).on('beforeunload', onBeforeUnload);   //beforeunloadイベントに関数を割り当て
            // formをsubmit（ログオフ）する場合、beforeunloadイベントを発生させないようにする
            $('form').on('submit', function () {
                $(window).off('beforeunload');
            });
            $("#loginButton").attr('onclick', '');  //クリック時の記述を削除
            $("#loginButton").on('click', function () {
                $(window).off('beforeunload');  //ログオフボタンをクリックしたときはbeforunloadイベントを発生させない
                if (!noChange()) {
                    var ans = confirm(pageLangText.unloadWithoutSave.text);
                    if (ans == false) {
                        $(window).on('beforeunload', onBeforeUnload);   //イベントを外したままだと、他のボタンで機能しないので、再設定
                        return false;
                    }
                }
                __doPostBack('ctl00$loginButton', '');
            });
            // メニューへ戻る
            var backToMenu = function () {
                try {
                    window.location = pageLangText.menuPath.url;
                } catch (e) {
                    // 何もしない
                }
            };
            /// <summary>メニューボタンクリック時のイベント処理を行います。</summary>
            $(".menu-button").on("click", backToMenu);
        });
    </script>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <!-- 画面デザイン -- Start -->

    <!-- 検索条件と検索ボタン -->
    <div class="content-part search-criteria" style="display: none;"></div>

    <!-- 検索結果一覧 -->
    <div class="content-part result-list">
        <!-- グリッドコントロール固有のデザイン -- Start -->
        <h3 id="listHeader" class="part-header" >
            <span data-app-text="resultList" style="padding-right: 10px;"></span>
            <span class="list-count" id="list-count" ></span>
            <span style="padding-left: 50px;" class="list-loading-message" id="list-loading-message" ></span>
        </h3>
        <div class="part-body" id="result-grid">
            <div class="item-command" style="left: 17px; right: 17px;">
                <button type="button" class="colchange-button" data-app-operation="colchange"><span class="icon"></span><span data-app-text="colchange"></span></button>
                <button type="button" class="add-button" name="add-button" data-app-operation="add"><span class="icon"></span><span data-app-text="add"></span></button>
                <button type="button" class="delete-button" name="delete-button" data-app-operation="del"><span class="icon"></span><span data-app-text="del"></span></button>
            </div>
            <table id="item-grid" data-app-operation="itemGrid">
            </table>
        </div>
        <!-- グリッドコントロール固有のデザイン -- End -->
    </div>

    <!-- 画面デザイン -- End -->
</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="FooterContent" runat="server">
    <!-- 画面デザイン -- Start -->

    <!-- 画面アーキテクチャ共通のデザイン -- Start -->
    <div class="command" style="left: 1px;">
        <button type="button" class="save-button" name="save-button" data-app-operation="save">
            <span class="icon"></span>
            <span data-app-text="save"></span>
        </button>
    </div>
    <div class="command" style="right: 9px;">
        <button type="button" class="menu-button" name="menu-button">
            <span class="icon"></span>
            <span data-app-text="menu"></span>
        </button>
    </div>
    <!-- 画面アーキテクチャ共通のデザイン -- End -->

    <!-- 画面デザイン -- End -->
</asp:Content>
<asp:Content ID="Content5" ContentPlaceHolderID="DialogsContent" runat="server">
    <!-- 画面デザイン -- Start -->
    
    <!-- ダイアログ固有のデザイン -- Start -->

    <!-- TODO: 画面の仕様に応じて以下のダイアログの設定を変更してください。 -->
    <div class="save-confirm-dialog" style="display: none;">
        <div class="dialog-header">
            <h4 data-app-text="confirmTitle"></h4>
        </div>
        <div class="dialog-body" style="padding: 10px; width: 100%;">
            <div class="part-body" id="confirm-form">
                <span data-app-text="saveConfirm"></span>
            </div>
        </div>
    <!-- TODO: ここまで  -->
        <div class="dialog-footer">
            <div class="command" style="position: absolute; left: 10px; top: 5px">
                <button class="dlg-yes-button" name="dlg-yes-button" data-app-text="yes"></button>
            </div>
            <div class="command" style="position: absolute; right: 5px; top: 5px;">
                <button class="dlg-no-button" name="dlg-no-button" data-app-text="no"></button>
            </div>
        </div>
    </div>

    <!-- 画面デザイン -- End -->
</asp:Content>
