<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="HakariHaniSetteiMaster.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.HakariHaniSetteiMaster" %>

<asp:Content ID="Content1" ContentPlaceHolderID="IncludeContent" runat="server">
    <script src="<%=ResolveUrl("~/Resources/pages/pagedata-hakarihanisetteimaster." + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
    <script src="<%=ResolveUrl("~/Resources/grid/grid.locale-" + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        /* 画面デザイン -- Start */
        
        /* TODO：画面の仕様に応じて以下のスタイルを変更してください。 */
        .part-body .item-label
        {
            display: inline-block;
        }
        
        #result-grid
        {
            padding: 0px;
            overflow: hidden;
        }
        
        .part-body .item-list li
        {
            margin-bottom: .2em;
        }
        
        .search-criteria select
        {
            width: 12em;
        }
        
        .search-criteria .item-label
        {
            width: 10em;
        }
        
        .save-confirm-dialog {
            background-color: White;
            width: 350px;
        }
        
        .search-confirm-dialog {
            background-color: White;
            width: 350px;
        }
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
                isDataLoading = false,
                searchCondition;

            // グリッドコントロール固有の変数宣言
            var grid = $("#item-grid"),
                lastScrollTop = 0,
            // 画面の仕様に応じて以下の変数宣言を変更してください。
                changeSet = new App.ui.page.changeSet(),
                firstCol = 0,
                duplicateCol = 999,
                currentRow = 0,
                currentCol = firstCol,
                shiyoKagenCol = 1,
                shiyoJogenCol = 2,
                tekioKagenCol = 3,
                tekioJogenCol = 4,
                katashiki,  // 検索条件：型式コンボボックス
                errRows = new Array();   // エラー行の格納用
            var checkFlgKagenJogen = false,
                readyFlg = false;   // 初期表示が終了しているかどうか

            // ダイアログ固有の変数宣言
            var saveConfirmDialog = $(".save-confirm-dialog");
            var searchConfirmDialog = $(".search-confirm-dialog");

            //// 変数宣言 -- End

            //// コントロール定義 -- Start

            // ダイアログ固有のコントロール定義
            saveConfirmDialog.dlg();
            searchConfirmDialog.dlg();

            /// <summary>ダイアログを開きます。(保存)</summary>
            var showSaveConfirmDialog = function () {
                saveConfirmDialogNotifyInfo.clear();
                saveConfirmDialogNotifyAlert.clear();
                saveConfirmDialog.dlg("open");
            };
            /// <summary>ダイアログを閉じます。(保存)</summary>
            var closeSaveConfirmDialog = function () {
                saveConfirmDialog.dlg("close");
            };

            /// <summary>ダイアログを開きます。(検索)</summary>
            var showSearchConfirmDialog = function () {
                searchConfirmDialogNotifyInfo.clear();
                searchConfirmDialogNotifyAlert.clear();
                searchConfirmDialog.dlg("open");
            };
            /// <summary>ダイアログを閉じます。(検索)</summary>
            var closeSearchConfirmDialog = function () {
                searchConfirmDialog.dlg("close");
            };

            // グリッドコントロール固有のコントロール定義
            grid.jqGrid({
                colNames: [
                    pageLangText.wt_hani_shiyo_kagen.text
                    , pageLangText.wt_hani_shiyo_jogen.text
                    , pageLangText.wt_hani_tekio_kagen.text
                    , pageLangText.wt_hani_tekio_jogen.text
                    , pageLangText.flg_mishiyo.text
                    , pageLangText.kbn_kasan_jyuryo.text
                    , pageLangText.no_seq.text
                    , pageLangText.ts.text
                ],
                colModel: [
                    { name: 'wt_hani_shiyo_kagen', width: pageLangText.wt_hani_shiyo_kagen_width.number, editable: true, align: "right", sorttype: "float",
                        formatter: 'number',
                        formatoptions: {
                            decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 3, defaultValue: "0.000"
                        }
                    },
                    { name: 'wt_hani_shiyo_jogen', width: pageLangText.wt_hani_shiyo_jogen_width.number, editable: true, align: "right", sorttype: "float",
                        formatter: 'number',
                        formatoptions: {
                            decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 3, defaultValue: "0.000"
                        }
                    },
                    { name: 'wt_hani_tekio_kagen', width: pageLangText.wt_hani_tekio_kagen_width.number, editable: true, align: "right", sorttype: "float",
                        formatter: 'number',
                        formatoptions: {
                            decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 3, defaultValue: "0.000"
                        }
                    },
                    { name: 'wt_hani_tekio_jogen', width: pageLangText.wt_hani_tekio_jogen_width.number, editable: true, align: "right", sorttype: "float",
                        formatter: 'number',
                        formatoptions: {
                            decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 3, defaultValue: "0.000"
                        }
                    },
                    { name: 'flg_mishiyo', width: pageLangText.flg_mishiyo_width.number, editable: true, hidden: false, edittype: 'checkbox',
                        editoptions: { value: "1:0" }, formatter: 'checkbox', formatoptions: { disabled: false }, align: 'center'
                    },
                    { name: 'kbn_kasan_jyuryo', width: 0, hidden: true, hidedlg: true },
                    { name: 'no_seq', width: 0, hidden: true, hidedlg: true },
                    { name: 'ts', width: 0, hidden: true, hidedlg: true }
                ],
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
                    if (readyFlg) {
                        // グリッドの先頭行選択
                        //var idNum = grid.getGridParam("selrow");
                        var idNum = getSelectedRowId(true);
                        if (idNum == null) {
                            $("#1 > td").click();
                        }
                        else {
                            $("#" + idNum).removeClass("ui-state-highlight").find("td").click();
                        }
                    }
                },
                beforeEditCell: function (selectedRowId, cellName, value, iRow, iCol) {
                    currentRow = iRow;
                    currentCol = iCol;
                    // Enter キーでカーソルを移動
                    grid.moveCell(cellName, iRow, iCol);
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

                    // 変更データの変数設定
                    var changeData;
                    // タイムスタンプが存在すれば更新、しなければ新規
                    // 更新
                    if (grid.jqGrid('getCell', selectedRowId, 'ts')) {
                        // 更新状態の変更データの設定
                        changeData = setUpdatedChangeData(grid.getRowData(selectedRowId));
                        // 更新状態の変更セットに変更データを追加
                        changeSet.addUpdated(selectedRowId, cellName, value, changeData);
                        // 新規
                    }
                    else {
                        // 追加状態のデータ設定
                        changeData = setCreatedChangeData(grid.getRowData(selectedRowId));
                        // 追加状態の変更セットに変更データを追加
                        changeSet.addCreated(selectedRowId, changeData);
                    }
                }
            });

            // <summary>チェックボックス操作時のグリッド値更新を行います</summary>
            $(document).on("click", "#item-grid .jqgrow td :checkbox", function () {
                // 参考：iRowにて記述する場合
                //var iRow = grid.getInd($(this).parent("td").parent("tr").attr("id"));
                var iCol = $(this).parent("td").parent("tr").find("td").index($(this).parent("td")),
                    selectedRowId = $(this).parent("td").parent("tr").attr("id"),
                    cellName = grid.getGridParam("colModel")[iCol].name,
                    value;

                // 更新状態の変更データの設定
                var changeData = setUpdatedChangeData(grid.getRowData(selectedRowId));

                // TODO：画面の仕様に応じて以下の定義を変更してください。
                value = changeData[cellName];
                // TODO：ここまで

                // 更新状態の変更セットに変更データを追加
                changeSet.addUpdated(selectedRowId, cellName, value, changeData);

            });

            /// <summary>セルの関連項目を設定します。</summary>
            /// <param name="selectedRowId">選択行ID</param>
            /// <param name="cellName">列名</param>
            /// <param name="value">元となる項目の値</param>
            /// <param name="iCol">項目の列番号</param>
            var setRelatedValue = function (selectedRowId, cellName, value, iCol) {
                // TODO：画面の仕様に応じて以下の関連項目を設定を変更してください。

                // TODO：ここまで
            };
            /// <summary>非表示列設定ダイアログの表示を行います。</summary>
            /// <param name="e">イベントデータ</param>
            var showColumnSettingDialog = function (e) {
                var params = {
                    width: 300,
                    height: 300,
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

            // 画面アーキテクチャ共通の事前データロード
            var loading;
            App.deferred.parallel({
                // ローディング
                loading: App.ui.loading.show(pageLangText.nowProgressing.text),
                katashiki: App.ajax.webget("../Services/FoodProcsService.svc/vw_ma_hakari_02?$filter=flg_mishiyo eq "
                    + pageLangText.shiyoMishiyoFlg.text + "&$orderby=cd_hakari")
            }).done(function (result) {
                katashiki = result.successes.katashiki.d;
                // 検索用ドロップダウンの設定
                App.ui.appendOptions($(".search-criteria [name='katashiki']"), "cd_hakari", "nm_hakari", katashiki, false);
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
                App.ui.loading.close();
            });

            //// 事前データロード -- End

            //// 検索処理 -- Start

            // 画面アーキテクチャ共通の検索処理

            /// <summary>クエリオブジェクトの設定</summary>
            var query = function () {
                var query = {
                    url: "../Services/FoodProcsService.svc/ma_range",
                    filter: createFilter(),
                    orderby: "no_seq",
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
                searchCondition = criteria;
                filters.push("cd_hakari eq '" + criteria.katashiki + "'");
                return filters.join(" and ");
            };
            /// <summary>データ検索を行います。</summary>
            /// <param name="query">クエリオブジェクト</param>
            var searchItems = function (query) {
                if (isDataLoading === true) {
                    return;
                }
                isDataLoading = true;
                // ローディングの表示
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
            /// <summary>検索条件を閉じます。</summary>
            var closeCriteria = function () {
                var criteria = $(".search-criteria");
                if (!criteria.find(".part-body").is(":hidden")) {
                    criteria.find(".search-part-toggle").click();
                }
            };


            // グリッドコントロール固有の検索処理

            /// <summary>検索前バリデーションの初期化</summary>
            var searchValidation = Aw.validation({
                items: App.ui.pagedata.validation(App.ui.page.lang),
                handlers: {
                    success: function (results) {
                        var i = 0, l = results.length;
                        for (; i < l; i++) {
                            App.ui.page.notifyAlert.remove(results[i].element);
                        }
                    },
                    error: function (results) {
                        var i = 0, l = results.length;
                        for (; i < l; i++) {
                            App.ui.page.notifyAlert.message(results[i].message, results[i].element).show();
                        }
                    }
                }
            });
            $(".part-body .item-list").validation(searchValidation);

            /// <summary>検索前の状態に初期化します。</summary>
            var clearState = function () {
                // データクリア
                grid.clearGridData();
                lastScrollTop = 0;
                querySetting.top = 500;
                querySetting.skip = 0;
                querySetting.count = 0;
                displayCount();
                isDataLoading = false;

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
                     App.str.format("{0}/{1} " + pageLangText.itemCount.text, querySetting.skip, querySetting.count)
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
                if (querySetting.count <= 0) {
                    App.ui.page.notifyAlert.message(pageLangText.notFound.text).show();
                }
                else {
                    App.ui.page.notifyInfo.message(
                         App.str.format(pageLangText.searchResultCount.text, querySetting.skip, querySetting.count)
                    ).show();
                }
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
                grid.editCell(iRow, info.iCol, true);
            };

            /// <summary>エラー一覧クリック時のイベント処理を行います。</summary>
            $(App.ui.page.notifyAlert).on("itemselected", function (e, data) {
                // エラー一覧クリック時の処理
                handleNotifyAlert(data);
            });

            // ダイアログ固有のメッセージ表示

            // ダイアログ情報メッセージの設定(保存時)
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
            // ダイアログ警告メッセージの設定(保存時)
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
            // ダイアログ情報メッセージの設定(検索時)
            var searchConfirmDialogNotifyInfo = App.ui.notify.info(searchConfirmDialog, {
                container: ".search-confirm-dialog .dialog-slideup-area .info-message",
                messageContainerQuery: "ul",
                show: function () {
                    searchConfirmDialog.find(".info-message").show();
                },
                clear: function () {
                    searchConfirmDialog.find(".info-message").hide();
                }
            });
            // ダイアログ警告メッセージの設定(検索時)
            var searchConfirmDialogNotifyAlert = App.ui.notify.alert(searchConfirmDialog, {
                container: ".search-confirm-dialog .dialog-slideup-area .alert-message",
                messageContainerQuery: "ul",
                show: function () {
                    searchConfirmDialog.find(".alert-message").show();
                },
                clear: function () {
                    searchConfirmDialog.find(".alert-message").hide();
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
                        // 情報メッセージのクリア
                        App.ui.page.notifyInfo.clear();
                        App.ui.page.notifyInfo.message(pageLangText.noRecords.text).show();
                    }
                    return;
                }
                // 選択行なしの場合の行選択
                if (App.isUnusable(selectedRowId)) {
                    selectedRowId = ids[0]; // 先頭行
                }
                currentRow = $('#' + selectedRowId)[0].rowIndex;

                return selectedRowId;
            };
            /// <summary>新規行データの設定を行います。</summary>
            var setAddData = function () {
                var addData = {
                    "cd_hakari": searchCondition.katashiki,
                    "wt_hani_shiyo_kagen": 0.000,
                    "wt_hani_shiyo_jogen": 0.000,
                    "wt_hani_tekio_kagen": 0.000,
                    "wt_hani_tekio_jogen": 0.000,
                    "kbn_kasan_jyuryo": pageLangText.gramJuryoKasanKbn.text,
                    "cd_create": App.ui.page.user.Code,
                    "cd_update": App.ui.page.user.Code,
                    "flg_mishiyo": pageLangText.shiyoMishiyoFlg.text
                };

                return addData;
            };
            /// <summary>追加状態の変更セットに追加する変更データの設定を行います。</summary>
            /// <param name="newRow">新規行データ</param>
            var setCreatedChangeData = function (newRow) {
                var changeData = {
                    "cd_hakari": searchCondition.katashiki,
                    "wt_hani_shiyo_kagen": newRow.wt_hani_shiyo_kagen,
                    "wt_hani_shiyo_jogen": newRow.wt_hani_shiyo_jogen,
                    "wt_hani_tekio_kagen": newRow.wt_hani_tekio_kagen,
                    "wt_hani_tekio_jogen": newRow.wt_hani_tekio_jogen,
                    "kbn_kasan_jyuryo": newRow.kbn_kasan_jyuryo,
                    "cd_create": App.ui.page.user.Code,
                    "cd_update": App.ui.page.user.Code,
                    "flg_mishiyo": newRow.flg_mishiyo,
                    "ts": newRow.ts
                };

                return changeData;
            };
            /// <summary>更新状態の変更セットに追加する変更データの設定を行います。</summary>
            /// <param name="row">選択行</param>
            var setUpdatedChangeData = function (row) {
                var changeData = {
                    "cd_hakari": searchCondition.katashiki,
                    "wt_hani_shiyo_kagen": row.wt_hani_shiyo_kagen,
                    "wt_hani_shiyo_jogen": row.wt_hani_shiyo_jogen,
                    "wt_hani_tekio_kagen": row.wt_hani_tekio_kagen,
                    "wt_hani_tekio_jogen": row.wt_hani_tekio_jogen,
                    "kbn_kasan_jyuryo": row.kbn_kasan_jyuryo,
                    "cd_update": App.ui.page.user.Code,
                    "flg_mishiyo": row.flg_mishiyo,
                    "no_seq": row.no_seq,
                    "ts": row.ts
                };

                return changeData;
            };
            /// <summary>削除状態の変更セットに追加する変更データの設定を行います。</summary>
            /// <param name="row">選択行</param>
            var setDeletedChangeData = function (row) {
                var changeData = {
                    "no_seq": row.no_seq,
                    "ts": row.ts
                };

                return changeData;
            };
            /// <summary>関連項目の設定を変更セットに反映します。</summary>
            /// <param name="selectedRowId">選択行ID</param>
            /// <param name="cellName">列名</param>
            /// <param name="value">元となる項目の値</param>
            var setRelatedChangeData = function (selectedRowId, cellName, value, changeData) {
                // TODO: 画面の仕様に応じて以下の処理を変更してください。
                // TODO: ここまで
            };

            /// <summary>新規行を追加します。</summary>
            /// <param name="e">イベントデータ</param>
            var addData = function (e) {
                ///// チェック処理
                var criteria = $(".search-criteria").toJSON();
                // 検索前は処理を抜ける
                if (!searchCondition) {
                    App.ui.page.notifyInfo.message(pageLangText.searchBefore.text).show();
                    return;
                }
                // 検索条件が変更されていないこと
                if (criteria.katashiki != searchCondition.katashiki) {
                    App.ui.page.notifyAlert.clear();
                    App.ui.page.notifyAlert.message(pageLangText.changeCondition.text).show();
                    return;
                }

                // 選択行のID取得
                var selectedRowId = getSelectedRowId(true),
                    position = "after";
                //position = "before";
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
            /// <summary>追加ボタンクリック時のイベント処理を行います。</summary>
            $(".add-button").on("click", addData);

            /// <summary>行を削除します。</summary>
            /// <param name="e">イベントデータ</param>
            var deleteData = function (e) {
                // 選択行のID取得
                var selectedRowId = getSelectedRowId(false);
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
                // 選択行の行データ削除
                grid.delRowData(selectedRowId);
                if (grid.getGridParam("records") > 0) {
                    // セルを選択して入力モードにする
                    grid.editCell(currentRow === 1 ? currentRow : currentRow - 1, currentCol, true);
                }
            };
            /// <summary>削除ボタンクリック時のイベント処理を行います。</summary>
            $(".delete-button").on("click", deleteData);

            //// データ変更処理 -- End

            //// 保存処理 -- Start

            // グリッドコントロール固有の保存処理

            // <summary>検索条件に変更がないかどうかを返します。</summary>
            var changeCondition = function () {
                var criteria = $(".search-criteria").toJSON();
                if (criteria.katashiki != searchCondition.katashiki) {
                    return true;
                }
                return false;
            };
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
                    checkCol = 1;
                // 更新時同時実行制御エラーのハンドリングを行います。
                if (!App.isUndefOrNull(ret.Updated) && ret.Updated.length > 0) {
                    for (var i = 0; i < ret.Updated.length; i++) {
                        for (p in changeSet.changeSet.updated) {
                            if (!changeSet.changeSet.updated.hasOwnProperty(p)) {
                                continue;
                            }

                            //value = grid.getCell(p, checkCol);
                            //retValue = ret.Updated[i].Requested.cd_line;

                            //if (isNaN(value) || value === retValue) {
                            // 更新状態の変更セットから変更データを削除
                            changeSet.removeUpdated(p);

                            var upCurrent = ret.Updated[i].Current;
                            unique = p + "_" + checkCol;
                            // 他のユーザーによって削除されていた場合
                            if (App.isUndefOrNull(upCurrent)) {
                                // 対象行の削除
                                //grid.delRowData(p);
                                // メッセージの表示
                                App.ui.page.notifyAlert.message(
                                        pageLangText.duplicate.text + pageLangText.deletedDuplicate.text, unique).show();
                            }
                            else {
                                //unique = p + "_" + duplicateCol;

                                current = grid.getRowData(p);
                                current.wt_hani_shiyo_kagen = upCurrent.wt_hani_shiyo_kagen;
                                current.wt_hani_shiyo_jogen = upCurrent.wt_hani_shiyo_jogen;
                                current.wt_hani_tekio_kagen = upCurrent.wt_hani_tekio_kagen;
                                current.wt_hani_tekio_jogen = upCurrent.wt_hani_tekio_jogen;
                                current.kbn_kasan_jyuryo = upCurrent.kbn_kasan_jyuryo;
                                current.flg_mishiyo = upCurrent.flg_mishiyo;
                                current.no_seq = upCurrent.no_seq;
                                current.ts = upCurrent.ts;

                                // 対象行の更新
                                grid.setRowData(p, current);
                                // エラーメッセージの表示
                                App.ui.page.notifyAlert.message(
                                        pageLangText.duplicate.text + pageLangText.updatedDuplicate.text, unique).show();
                            }
                            //}
                        }
                    }
                }
                // 削除時同時実行制御エラーのハンドリングを行います。
                if (!App.isUndefOrNull(ret.Deleted) && ret.Deleted.length > 0) {
                    for (var j = 0; j < ret.Deleted.length; j++) {
                        for (p in changeSet.changeSet.deleted) {
                            if (!changeSet.changeSet.deleted.hasOwnProperty(p)) {
                                continue;
                            }

                            //value = changeSet.changeSet.deleted[p].cd_line;
                            //retValue = ret.Deleted[j].Requested.cd_line;
                            //if (isNaN(value) || value === retValue) {
                            // 削除状態の変更セットから変更データを削除
                            changeSet.removeDeleted(p);

                            // 他のユーザーによって削除されていた場合
                            if (App.isUndefOrNull(ret.Deleted[j].Current)) {
                                // メッセージの表示
                                App.ui.page.notifyAlert.message(
                                        pageLangText.duplicate.text + pageLangText.deletedDuplicate.text).show();
                            }
                            else {
                                // メッセージの表示
                                App.ui.page.notifyAlert.message(
                                        pageLangText.duplicate.text + pageLangText.unDeletedDuplicate.text).show();
                            }
                            //}
                        }
                    }
                }
            };
            /// <summary>変更を保存します。</summary>
            /// <param name="e">イベントデータ</param>
            var saveData = function (e) {
                //メッセージダイアログを閉じる
                closeSaveConfirmDialog();
                // ローディングの表示
                App.ui.loading.show(pageLangText.nowSaving.text);

                var saveUrl = "../api/HakariHaniSetteiMaster";
                App.ajax.webpost(
                    saveUrl, getPostData()
                ).done(function (result) {
                    // 検索前の状態に初期化
                    clearState();
                    App.ui.page.notifyInfo.message(pageLangText.successMessage.text).show();
                    // データ検索
                    searchItems(new query());
                }).fail(function (result) {
                    // データ変更エラーハンドリングを行います。
                    handleSaveDataError(result);
                }).always(function () {
                    // ローディングの終了
                    changeSet = new App.ui.page.changeSet();
                    App.ui.loading.close();
                });
            };
            /// 重複エラーで変えたセルの背景色をクリアする
            /// <param name="errIds">対象行のID配列</param>
            var clearErrBgcorror = function (errIds) {
                for (var i = 0; i < errIds.length; i++) {
                    var id = errIds[i];
                    // 対象セルの背景リセット
                    grid.setCell(id, shiyoKagenCol, '', { background: 'none' });
                    grid.setCell(id, shiyoJogenCol, '', { background: 'none' });
                }
            };
            /// <summary>保存前チェック</summary>
            var checkSave = function () {
                // 情報メッセージのクリア
                App.ui.page.notifyInfo.clear();
                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();
                // 内部エラーになった行の背景色をすべてリセット
                clearErrBgcorror(errRows);

                // 変更セット内にバリデーションエラーがある場合は処理を抜ける
                if (!validateChangeSet()) {
                    App.ui.loading.close();
                    return;
                }
                // 変更がない場合は処理を抜ける
                if (noChange()) {
                    App.ui.page.notifyInfo.message(pageLangText.noChange.text).show();
                    App.ui.loading.close();
                    return;
                }
                // 検索条件が変更されている場合は処理を抜ける
                if (changeCondition()) {
                    App.ui.page.notifyAlert.message(pageLangText.changeCondition.text).show();
                    App.ui.loading.close();
                    return;
                }

                // 秤量値の重複チェック
                if (!checkRangeDuplicat()) {
                    App.ui.page.notifyAlert.message(pageLangText.rangeDuplicat.text).show();
                    App.ui.loading.close();
                    return;
                }
                else {
                    // チェックがすべて終わってからローディング表示を終了させる
                    App.ui.loading.close();
                }

                // 保存確認ダイアログを開く
                showSaveConfirmDialog();
            };
            /// <summary>保存ボタンクリック時のイベント処理を行います。</summary>
            $(".save-button").on("click", function () {
                // 編集内容の保存
                saveEdit();

                // ローディング表示
                App.ui.loading.show(pageLangText.nowProgressing.text);

                // チェック処理が始まるとローディング画像が表示されない為、setTimeoutで間を入れる
                setTimeout(function () {
                    checkSave();    // 保存処理の実行
                }, 100);
            });
            /// <summary>秤量値の重複チェック
            /// 該当の明細/秤量値(下)＜他の明細の秤量値(下)＜該当の明細/秤量値(上)
            /// もしくは
            /// 該当の明細/秤量値(下)＜他の明細の秤量値(上)＜該当の明細/秤量値(上) でないこと</summary>
            var checkRangeDuplicat = function () {
                var recordCount = grid.getGridParam("records");
                var ids = grid.getDataIDs();
                for (var i = 0; i < recordCount; i++) {
                    // 該当の明細の秤量値(下)と秤量値(上)を取得
                    var targetRowId = ids[i];
                    var targetKagen = getThousandsSeparatorDel(grid.getCell(targetRowId, "wt_hani_shiyo_kagen"));
                    var targetJogen = getThousandsSeparatorDel(grid.getCell(targetRowId, "wt_hani_shiyo_jogen"));

                    // 自分以外の、他の明細の秤量値と比較していく
                    for (var j = 0; j < recordCount; j++) {
                        var checkRowId = ids[j];
                        if (targetRowId == checkRowId) {
                            continue;
                        }
                        var checkKagen = getThousandsSeparatorDel(grid.getCell(checkRowId, "wt_hani_shiyo_kagen"));
                        var checkJogen = getThousandsSeparatorDel(grid.getCell(checkRowId, "wt_hani_shiyo_jogen"));
                        if (parseFloat(targetKagen) <= parseFloat(checkKagen)
                            && parseFloat(checkKagen) <= parseFloat(targetJogen)) {
                            // 該当の明細/秤量値(下)＜他の明細の秤量値(下)＜該当の明細/秤量値(上) だった場合
                            grid.setCell(targetRowId, "wt_hani_shiyo_kagen", targetKagen, { background: '#ff6666' });
                            grid.setCell(targetRowId, "wt_hani_shiyo_jogen", targetJogen, { background: '#ff6666' });
                            grid.setCell(checkRowId, "wt_hani_shiyo_kagen", checkKagen, { background: '#ff6666' });
                            // エラー行を追加
                            errRows.push(targetRowId);
                            errRows.push(checkRowId);
                            return false;
                        }
                        else if (parseFloat(targetKagen) <= parseFloat(checkJogen)
                            && parseFloat(checkJogen) <= parseFloat(targetJogen)) {
                            // 該当の明細/秤量値(下)＜他の明細の秤量値(上)＜該当の明細/秤量値(上) だった場合
                            grid.setCell(targetRowId, "wt_hani_shiyo_kagen", targetKagen, { background: '#ff6666' });
                            grid.setCell(targetRowId, "wt_hani_shiyo_jogen", targetJogen, { background: '#ff6666' });
                            grid.setCell(checkRowId, "wt_hani_shiyo_jogen", checkJogen, { background: '#ff6666' });
                            // エラー行を追加
                            errRows.push(targetRowId);
                            errRows.push(checkRowId);
                            return false;
                        }
                    }
                }
                return true;
            };

            //// 保存処理 -- End

            //// バリデーション -- Start

            // グリッドコントロール固有のバリデーション

            // グリッドのバリデーション設定
            var v = Aw.validation({
                items: validationSetting
            });

            /// カスタムバリデーション定義
            // 秤量値（下）と秤量値（上）
            validationSetting.wt_hani_shiyo_kagen.rules.custom = function (value) {
                var isVali = true;
                var selectedRowId = getSelectedRowId(true);
                var shiyo_kagen = getThousandsSeparatorDel(value);
                var shiyo_jogen = getThousandsSeparatorDel(grid.getCell(selectedRowId, "wt_hani_shiyo_jogen"));
                if (parseFloat(shiyo_jogen) < parseFloat(shiyo_kagen)) {
                    isVali = false;
                }
                else {
                    if (!checkFlgKagenJogen) {
                        checkFlgKagenJogen = true;  // ループ回避用
                        // 秤量値（上）のエラーも解除するためチェック実施
                        validateCell(selectedRowId, "wt_hani_shiyo_jogen", shiyo_jogen, shiyoJogenCol);
                    }
                }
                checkFlgKagenJogen = false;
                return isVali;
            };
            validationSetting.wt_hani_shiyo_jogen.rules.custom = function (value) {
                var isVali = true;
                var selectedRowId = getSelectedRowId(true);
                var shiyo_jogen = getThousandsSeparatorDel(value);
                var shiyo_kagen = getThousandsSeparatorDel(grid.getCell(selectedRowId, "wt_hani_shiyo_kagen"));
                if (parseFloat(shiyo_jogen) < parseFloat(shiyo_kagen)) {
                    isVali = false;
                }
                else {
                    if (!checkFlgKagenJogen) {
                        checkFlgKagenJogen = true;  // ループ回避用
                        // 秤量値（下）のエラーも解除するためチェック実施
                        validateCell(selectedRowId, "wt_hani_shiyo_kagen", shiyo_kagen, shiyoKagenCol);
                    }
                }
                checkFlgKagenJogen = false;
                return isVali;
            };
            /*
            // 下限（ｇ）と上限（ｇ）
            validationSetting.wt_hani_tekio_kagen.rules.custom = function (value) {
                var selectedRowId = getSelectedRowId(true);
                var valiObj = validationSetting.wt_hani_tekio_kagen;
                var tekio_kagen = getThousandsSeparatorDel(value);
                var tekio_jogen = getThousandsSeparatorDel(grid.getCell(selectedRowId, "wt_hani_tekio_jogen"));
                var isVali = isValidKagenJogen(valiObj, tekio_kagen, tekio_jogen);
                if (isVali && !checkFlgKagenJogen) {
                    checkFlgKagenJogen = true;  // ループ回避用
                    // 上限（ｇ）のエラーも解除するためチェック実施
                    validateCell(selectedRowId, "wt_hani_tekio_jogen", tekio_jogen, tekioJogenCol);
                }
                checkFlgKagenJogen = false;
                return isVali;
            };
            validationSetting.wt_hani_tekio_jogen.rules.custom = function (value) {
                var selectedRowId = getSelectedRowId(true);
                var valiObj = validationSetting.wt_hani_tekio_jogen;
                var tekio_jogen = getThousandsSeparatorDel(value);
                var tekio_kagen = getThousandsSeparatorDel(grid.getCell(selectedRowId, "wt_hani_tekio_kagen"));
                var isVali = isValidKagenJogen(valiObj, tekio_kagen, tekio_jogen);
                if (isVali && !checkFlgKagenJogen) {
                    checkFlgKagenJogen = true;  // ループ回避用
                    // 下限（ｇ）のエラーも解除するためチェック実施
                    validateCell(selectedRowId, "wt_hani_tekio_kagen", tekio_kagen, tekioKagenCol);
                }
                checkFlgKagenJogen = false;
                return isVali;
            };
            // 上限/下限の入力チェック：上限＜下限の場合flaseを返す
            var isValidKagenJogen = function (valiObj, kagen, jogen) {
                if (parseFloat(jogen) < parseFloat(kagen)) {
                    // メッセージ引数が複数のcustomはappにないので、個別で設定
                    valiObj.messages.custom =
	                    App.str.format(valiObj.messages.custom
		                    , valiObj.params.custom[0]
		                    , valiObj.params.custom[1]);
                    return false;
                }
                return true;
            };
            */
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
                // ファンクションキー毎の処理を定義します。
                if (e.keyCode === App.ui.keys.F2) {
                    // F2の処理
                    processed = true;
                }
                else if (e.keyCode === App.ui.keys.F3) {
                    //F3の処理
                    processed = true;
                }
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

            var execBeforeUnload = true;
            $(window).on('beforeunload', function () {
                if (execBeforeUnload && !noChange()) {
                    return pageLangText.unloadWithoutSave.text;
                }
            });
            /// <summary>検索ボタンクリック時のイベント処理を行います。</summary>
            $(".find-button").on("click", function () {
                if (!noChange()) {
                    showSearchConfirmDialog();
                }
                else {
                    clearState();
                    searchItems(new query());
                }
            });

            ///検索確認ダイアログ用の検索処理
            var dlgSearchItems = function () {
                closeSearchConfirmDialog();
                clearState();
                searchItems(new query());
            }

            // 3桁のカンマ区切りを除外した値をセット
            function setThousandsSeparatorDel(target) {
                var value = $(target).val();
                value = setThousandsSeparatorDel(value);
                $(target).val(value);
            }

            // 3桁のカンマ区切りを除外した値を取得
            function getThousandsSeparatorDel(value) {
                value = "" + value;
                // スペースとカンマを削除
                return value.replace(/^\s+|\s+$|,/g, "");
            }

            /// <summary>検索確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".search-confirm-dialog .dlg-yes-button").on("click", dlgSearchItems);
            // <summary>検索確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".search-confirm-dialog .dlg-no-button").on("click", closeSearchConfirmDialog);

            /// <summary>保存確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".save-confirm-dialog .dlg-yes-button").on("click", saveData);
            // <summary>保存確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".save-confirm-dialog .dlg-no-button").on("click", closeSaveConfirmDialog);

            var backToMenu = function () {
                // IEバグによる例外発生をキャッチします。例外発生時は何もしません。
                try {
                    document.location = "./MainMenu.aspx"
                }
                catch (e) {
                }
            };
            /// <summary>メニューボタンクリック時のイベント処理を行います。</summary>
            $(".menu-button").on("click", backToMenu);

            var cancelBeforeUnload = function () {
                execBeforeUnload = false;
                setTimeout(function () {
                    execBeforeUnload = true;
                }, 0);
            }
            readyFlg = true;
        });
    </script>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <!-- 画面デザイン -- Start -->

    <!-- 検索条件と検索ボタン -->
    <div class="content-part search-criteria">
        <h3 class="part-header" data-app-text="searchCriteria"><a class="search-part-toggle" href="#"></a></h3>
        <div class="part-body">
            <ul class="item-list">
                <!-- TODO: 画面の仕様に応じて以下の検索条件を変更してください。-->
                <li>
                    <label>
                        <span class="item-label" data-app-text="katashiki" style="width:80px;"></span>
                        <select name="katashiki" id="condition-katashiki" style="width:350px;">
                        </select>
                    </label>
                </li>
                <!-- TODO: ここまで -->
            </ul>
        </div>
        <div class="part-footer">
            <div class="command">
                <button type="button" class="find-button" name="find-button">
                    <span class="icon"></span>
                    <span data-app-text="search"></span>
                </button>
            </div>
        </div>
    </div>

    <!-- 検索結果一覧 -->
    <div class="content-part result-list">
        <!-- グリッドコントロール固有のデザイン -- Start -->
        <h3 id="listHeader" class="part-header" >
            <span data-app-text="resultList" style="padding-right: 10px;"></span>
            <span class="list-count" id="list-count" ></span>
            <span style="padding-left: 50px;" class="list-loading-message" id="list-loading-message" ></span>
        </h3>
        <div class="part-body" id="result-grid">
            <div class="item-command">
                <button type="button" class="colchange-button"><span class="icon"></span><span data-app-text="colchange"></span></button>
                <button type="button" class="add-button" name="add-button" data-app-operation="add"><span class="icon"></span><span data-app-text="add"></span></button>
            <button type="button" class="delete-button" name="delete-button" data-app-operation="del"><span class="icon"></span><span data-app-text="del"></span></button>
            </div>
            <!-- 注記 -->
            <span data-app-text="notes" style="padding-left:5px;"></span>
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

        <!-- TODO: 画面の仕様に応じて以下のボタンを変更してください。 -->
        <button type="button" class="save-button" name="save-button" data-app-operation="save">
            <span class="icon"></span>
            <span data-app-text="save"></span>
        </button>
        <!-- TODO: ここまで -->
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
    <div class="save-confirm-dialog">
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
    <!-- TODO: 画面の仕様に応じて以下のダイアログの設定を変更してください。 -->
    <div class="search-confirm-dialog">
        <div class="dialog-header">
            <h4 data-app-text="confirmTitle"></h4>
        </div>
        <div class="dialog-body" style="padding: 10px; width: 100%;">
            <div class="part-body" id="Div1">
                <span data-app-text="searchConfirm"></span>
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
