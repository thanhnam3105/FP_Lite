<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="SeizoLineMaster.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.SeizoLineMaster" %>

<asp:Content ID="Content1" ContentPlaceHolderID="IncludeContent" runat="server">
    <script src="<%=ResolveUrl("~/Resources/pages/pagedata-seizolinemaster." + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
    <script src="<%=ResolveUrl("~/Resources/grid/grid.locale-" + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        /* 画面デザイン -- Start */
        
        /* TODO：画面の仕様に応じて以下のスタイルを変更してください。 */
        .not-editable-cell
        {
        }
        
        .search-criteria .conditionname-label
        {
            width: 15em;
        }
		
		button.line-button .icon
		{
			background-position: -48px -80px;
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

        .part-header {
            line-height: 30px!important;
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
                querySetting = { skip: 0, top: 100, count: 0 },
                isDataLoading = false,
                isSearch = false, // 検索フラグ
                isCriteriaChange = false,   // 検索条件変更フラグ
                searchCondition;

            // グリッドコントロール固有の変数宣言
            var grid = $("#item-grid"),
                lastScrollTop = 0,
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
                changeSet = new App.ui.page.changeSet(),
                firstCol = 3,
                lineNameCol = 4,
                duplicateCol = 999,
                currentRow = 0,
                currentCol = firstCol;
            // TODO: ここまで

            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            var masterKubun,
                haigoCode;
            // TODO：ここまで

            // ダイアログ固有の変数宣言
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            var saveConfirmDialog = $(".save-confirm-dialog"),
                searchConfirmDialog = $(".search-confirm-dialog"),
                hinmeiDialog = $(".hinmei-dialog"),
                lineDialog = $(".line-dialog");
            // TODO：ここまで
            
            //// 変数宣言 -- End

            //// コントロール定義 -- Start

            // ダイアログ固有のコントロール定義
            saveConfirmDialog.dlg();
            searchConfirmDialog.dlg();

    		hinmeiDialog.dlg({
    			url: "Dialog/HinmeiDialog.aspx",
    			name: "HinmeiDialog",
    			closed: function (e, data, data2) {
    				if (data == "canceled") {
    					return;
    				} else {
    					$("#condition-haigocode").val(data);
    					$("#condition-haigoname").text(data2);
    				}
    			}
    		});
            // ラインダイアログ定義
            lineDialog.dlg({
                url: "Dialog/LineDialog.aspx",
                name: "LineDialog",
                closed: function (e, data, data2) {
                    // エラーメッセージのクリア
                    App.ui.page.notifyAlert.clear();
                    $(".line-dialog 0 all").remove();
                    if (data == "canceled") {
                        return;
                    }
                    else {
                        var selectedRowId = getSelectedRowId(false);
                        grid.setCell(selectedRowId, "cd_line", data);
                        grid.setCell(selectedRowId, "nm_line", data2);

						// 更新状態の変更セットに変更データを追加
						var changeData = setCreatedChangeData(grid.getRowData(selectedRowId));
						changeSet.addUpdated(selectedRowId, "cd_line", data, changeData);
                        // データチェック
                        validateCell(selectedRowId, "cd_line", data, grid.getColumnIndexByName("cd_line"));
                    }
                }
            });

            /// <summary>ダイアログを開きます。</summary>
            var showSaveConfirmDialog = function () {
                saveConfirmDialogNotifyInfo.clear();
                saveConfirmDialogNotifyAlert.clear();
                saveConfirmDialog.draggable(true);
                saveConfirmDialog.dlg("open");
            };
	        var showSearchConfirmDialog = function () {
	            // 検索前に変更をチェック
	            if (noChange()) {
	                findData();
	            } else {
	                searchConfirmDialogNotifyInfo.clear();
	                searchConfirmDialogNotifyAlert.clear();
	                searchConfirmDialog.draggable(true);
	                searchConfirmDialog.dlg("open");
	            }
	        };

            /// <summary>ダイアログを閉じます。</summary>
            var closeSaveConfirmDialog = function () {
                saveConfirmDialog.dlg("close");
            };
			var closeSearchConfirmDialog = function () {
	            searchConfirmDialog.dlg("close");
	        };

            // グリッドコントロール固有のコントロール定義
            var selectCol;
            grid.jqGrid({
                // TODO：画面の仕様に応じて以下の列名の定義を変更してください。
                colNames: [
                    pageLangText.masterKubun.text, pageLangText.haigoCode.text, pageLangText.seizoLineCode.text+ pageLangText.requiredMark.text,
                    pageLangText.seizoLineName.text, pageLangText.yusenNumber.text+ pageLangText.requiredMark.text, pageLangText.mishiyoFlag.text,
                    pageLangText.torokuCode.text, pageLangText.torokuDate.text, pageLangText.ts.text
                ],
                // TODO：ここまで
                // TODO：画面の仕様に応じて以下の列モデルの定義を変更してください。
                colModel: [
                    { name: 'kbn_master', width: 80, editable: false, classes: 'not-editable-cell', sortable: false, hidden: true, hidedlg: true, align: 'left' },
                    { name: 'cd_haigo', width: 80, editable: false, classes: 'not-editable-cell', sortable: true, sorttype: 'text', hidden: true, hidedlg: true, align: 'left' },
                    { name: 'cd_line', width: 100, editable: true, sortable: true, hidden: false, hidedlg: false, align: 'center' },
                    { name: 'nm_line', width: 300, editable: false, classes: 'not-editable-cell', sortable: true, hidden: false, hidedlg: false, align: 'left' },
                    { name: 'no_juni_yusen', width: 80, editable: true, sortable: true, hidden: false, hidedlg: false, align: 'center' },
                    { name: 'seizo_line_mishiyo', width: 100, editable: true, hidden: false, edittype: 'checkbox',
                        editoptions: { value: "1:0" }, formatter: 'checkbox', formatoptions: { disabled: false }, align: 'center'
                    },
                    { name: 'cd_create', width: 80, hidden: true, hidedlg: true, editable: false, sorttype: "text" },
                    { name: 'dt_create', width: 120, hidden: true, hidedlg: true, editable: false, sorttype: "date" },
                    { name: 'ts', width: 120, hidden: true, hidedlg: true }
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
                        // TODO：画面の仕様に応じて以下の操作可否の定義を変更してください。
                        if (grid.jqGrid('getCell', id, 'ts')) {
                            grid.jqGrid('setCell', id, 'cd_line', '', 'not-editable-cell');
                            grid.jqGrid('setCell', id, 'no_juni_yusen', '', 'not-editable-cell');
                        }
                        // TODO：ここまで
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
                    setRelatedValue(selectedRowId, cellName, value, iCol);
                    // 更新状態の変更データの設定
                    var changeData = setUpdatedChangeData(grid.getRowData(selectedRowId));
                    // 更新状態の変更セットに変更データを追加
                    changeSet.addUpdated(selectedRowId, cellName, value, changeData);
                    // 関連項目の設定を変更セットに反映
                    // setRelatedChangeData(selectedRowId, cellName, value, changeData);
                },
                onCellSelect: function (rowid, icol, cellcontent) {
                    selectCol = icol;
                },
                ondblClickRow: function (rowid) {
                    if (checkShowDialog(rowid)) {
                        var iCol = grid[0].p.iCol;
                        // ラインセレクタ起動
                        if (iCol === grid.getColumnIndexByName("cd_line")
                                || iCol === grid.getColumnIndexByName("nm_line")) {
                            // 検索条件変更チェック
                            if (isCriteriaChange) {
                                showCriteriaChange("navigate");
                                return;
                            }
                            showLineDialog(rowid);
                        }
                    }
                }
            });

            // <summary>チェックボックス操作時のグリッド値更新を行います</summary>
            $(document).on("click", "#item-grid .jqgrow td :checkbox", function () {
                // 参考：iRowにて記述する場合
                //var iRow = grid.getInd($(this).parent("td").parent("tr").attr("id"));
                var iCol = $(this).parent("td").parent("tr").find("td").index($(this).parent("td")),
                    selectedRowId = $(this).parent("td").parent("tr").attr("id"),
                    cellName = "flg_mishiyo",
                    value;
                saveEdit();

                // 更新状態の変更データの設定
                var changeData = setUpdatedChangeData(grid.getRowData(selectedRowId));

                // TODO：画面の仕様に応じて以下の定義を変更してください。
                value = changeData["flg_mishiyo"];
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
                var serviceUrl = "../Services/FoodProcsService.svc/ma_line()?$filter=cd_line eq '" + grid.getCell(selectedRowId, "cd_line") + "' and flg_mishiyo eq " + pageLangText.shiyoMishiyoFlg.text + "&$top=1",
                    elementCode = "cd_line",
                    elementName = "nm_line",
                    codeName;
                App.deferred.parallel({
                    // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                    codeName: App.ajax.webget(serviceUrl)
                    // TODO: ここまで
                }).done(function (result) {
                    // TODO: 画面の仕様に応じて以下のサービス呼び出し成功時の処理を変更してください。
                    var row = grid.getRowData(selectedRowId);
                    codeName = result.successes.codeName.d;
                    if (codeName.length > 0) {
                        grid.setCell(selectedRowId, "nm_line", codeName[0][elementName]);
                    }
                    else {
                        grid.setCell(selectedRowId, "nm_line", null);
                    }
                    // TODO: ここまで
                }).fail(function (result) {
                    var length = result.key.fails.length,
                            messages = [];
                    for (var i = 0; i < length; i++) {
                        var keyName = result.key.fails[i];
                        var value = result.fails[keyName];
                        messages.push(keyName + " " + value.message);
                    }

                    App.ui.page.notifyAlert.message(messages).show();
                });
                // TODO：ここまで
            };
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
            $(".colchange-button").on("click", function (e) {
                // 検索条件変更チェック
                if (isCriteriaChange) {
                    showCriteriaChange("colchange");
                    return;
                }
                showColumnSettingDialog(e);
            });

            //// コントロール定義 -- End

            //// 操作制御定義 -- Start

            // 操作制御定義を定義します。
            App.ui.pagedata.operation.applySetting(App.ui.page.user.Roles[0], App.ui.page.lang);

            //// 操作制御定義 -- End

            //// 事前データロード -- Start 

            // 画面アーキテクチャ共通の事前データロード
            
            // pageLangTextを用いた事前データロード
            // TODO: 画面の仕様に応じて以下の処理を変更してください。
            masterKubun = pageLangText.masterKubunId.data;
            // 検索用ドロップダウンの設定
            App.ui.appendOptions($(".search-criteria [name='masterKubun']"), "id", "name", masterKubun, false);
            //// 事前データロード -- End

            //// 検索処理 -- Start

            // 画面アーキテクチャ共通の検索処理

            /// <summary>クエリオブジェクトの設定</summary>
            var query = function () {
                var query = {
                    // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                    url: "../Services/FoodProcsService.svc/vw_ma_seizo_line_01",
                    // TODO: ここまで
                    filter: createFilter(),
                    // TODO: 画面の仕様に応じて以下のソート条件を変更してください。
                    orderby: "no_juni_yusen, cd_line",
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
                searchCondition = criteria;
                // TODO: 画面の仕様に応じて以下のフィルター条件を変更してください。
                if (!App.isUndefOrNull(criteria.masterKubun) && criteria.masterKubun.length > 0) {
                    filters.push("kbn_master eq " + criteria.masterKubun);
                }
                if (!App.isUndefOrNull(criteria.haigoCode) && criteria.haigoCode.length > 0) {
                    filters.push("cd_haigo eq '" + criteria.haigoCode + "'");
                }
                // TODO: ここまで

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
                $("#list-loading-message").text(
                    App.str.format(
                        pageLangText.nowListLoading.text,
                        querySetting.skip + 1,
                        querySetting.top
                    )
                );
                App.ajax.webget(
                // WCF Data ServicesのODataシステムクエリオプションを生成
                    App.data.toODataFormat(query)
                ).done(function (result) {
                    // 検索フラグを立てる
                    isSearch = true;
                    // データバインド
                    bindData(result);
                    // グリッドの先頭行選択
                    var idNum = grid.getGridParam("selrow");
                    if (idNum == null) {
                        $("#1 > td").click();
                    } else {
                        $("#" + idNum).removeClass("ui-state-highlight").find("td").click();
                    }
                    //querySetting.top = 40;
                    // 検索条件を閉じる
                    closeCriteria();
                    isCriteriaChange = false;
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
            /// <summary>検索ボタンクリック時のイベント処理を行います。</summary>
            var findData = function () {
                closeSearchConfirmDialog();
                //querySetting.top = 500;
                clearState();
                // 検索前バリデーション
                var result = $(".part-body .item-list").validation().validate();
                if (result.errors.length) {
                    return;
                }
                searchItems(new query());
            };
	        /// <summary>検索ボタンクリック時のイベント処理を行います。</summary>
	        $(".find-button").on("click", showSearchConfirmDialog);

            /// <summary>検索条件表示用コード名の検索を行います。</summary>
            /// <param name="masterKubun">クエリオブジェクト</param>
            /// <param name="code">クエリオブジェクト</param>
            var getCodeName = function (masterKubun, code) {
                var serviceUrl,
                    elementCode,
                    elementName,
                    codeName;
                switch (masterKubun) {
                    case "1":
                        serviceUrl = "../Services/FoodProcsService.svc/ma_hinmei()?$filter=cd_hinmei eq '" + code + "' and (kbn_hin eq " + pageLangText.seihinHinKbn.text + " or kbn_hin eq " + pageLangText.jikaGenryoHinKbn.text + ") and flg_mishiyo eq " + pageLangText.shiyoMishiyoFlg.text + "&$top=1";
                        elementCode = "cd_hinmei";
                        elementName = "nm_hinmei_" + "<%=System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName%>";
                        break;
                    case "2":
                        serviceUrl = "../Services/FoodProcsService.svc/ma_haigo_mei()?$filter=cd_haigo eq '" + code + "' and flg_mishiyo eq " + pageLangText.shiyoMishiyoFlg.text + "&$top=1";
                        elementCode = "cd_haigo";
                        elementName = "nm_haigo_" + "<%=System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName%>";
                        break;
                    default:
                        serviceUrl = "";
                        elementCode = "";
                        elementName = "";
                        return;
                }
                App.deferred.parallel({
                    // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                    codeName: App.ajax.webget(serviceUrl)
                    // TODO: ここまで
                }).done(function (result) {
                    // TODO: 画面の仕様に応じて以下のサービス呼び出し成功時の処理を変更してください。
                    codeName = result.successes.codeName.d;
                    if (codeName.length > 0) {
                        $("#condition-haigoname").text(codeName[0][elementName]);
                    }
                    else {
                        if ($(".search-criteria").toJSON().haigoCode) {
                            App.ui.page.notifyAlert.message(pageLangText.notFound.text, $("#condition-haigocode")).show();
                        }
                        $("#condition-haigoname").text("");
                    }
                    // TODO: ここまで
                }).fail(function (result) {
                    var length = result.key.fails.length,
                            messages = [];
                    for (var i = 0; i < length; i++) {
                        var keyName = result.key.fails[i];
                        var value = result.fails[keyName];
                        messages.push(keyName + " " + value.message);
                    }

                    App.ui.page.notifyAlert.message(messages).show();
                });
            };
            
            /// <summary>検索条件変更時のイベント処理を行います。</summary>
            $("#condition-masterkubun").on("change", function () {
                var criteria = $(".search-criteria").toJSON();
                getCodeName(criteria.masterKubun, criteria.haigoCode);
            });

            // 検索条件に変更が発生した場合
            $(".search-criteria").on("change", function () {
                // 検索後の状態で検索条件が変更された場合
                if (isSearch) {
                    isCriteriaChange = true;
                }
            });

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
                querySetting.skip = 0;
                querySetting.count = 0;
                displayCount();
                isCriteriaChange = false;
                isSearch = false;

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
            /*
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
            */
            /// <summary>グリッドスクロール時のイベント処理を行います。</summary>
            $(".ui-jqgrid-bdiv").scroll(function (e) {
                // 後続データ検索
                //nextSearchItems(this);
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
                // TODO: 画面の仕様に応じて以下の項目を変更してください。
                var getMasterKubun = function () {
                    if (!App.isUndefOrNull(searchCondition)) {
                        return searchCondition.masterKubun;
                    }
                    else { return ""; }
                };
                var getHaigoCode= function () {
                    if (!App.isUndefOrNull(searchCondition)) {
                        return searchCondition.haigoCode;
                    }
                    else { return ""; }
                };
                var addData = {
                    "kbn_master": getMasterKubun(),
                    "cd_haigo": getHaigoCode(),
                    "no_juni_yusen": "",
                    "cd_line": "",
                    "nm_line": "",
                    "flg_mishiyo": pageLangText.falseFlg.text,
                    "dt_create": new Date(),
                    "cd_create": App.ui.page.user.Code,
                    "dt_update": new Date(),
                    "cd_update": App.ui.page.user.Code
                };
                // TODO: ここまで

                return addData;
            };
            /// <summary>コピー行データの設定を行います。</summary>
            /// <param name="row">選択行</param>
            var setCopyData = function (row) {
                // TODO: 画面の仕様に応じて以下の項目の初期値を変更してください。
                return $.extend({}, row,
                    { "cd_create": App.ui.page.user.Code,
                        "cd_update": App.ui.page.user.Code
                    });
                // TODO: ここまで
            };
            /// <summary>追加状態の変更セットに追加する変更データの設定を行います。</summary>
            /// <param name="newRow">新規行データ</param>
            var setCreatedChangeData = function (newRow) {
                // TODO: 画面の仕様に応じて以下の項目を変更してください。
                var changeData = {
                    "kbn_master": newRow.kbn_master,
                    "cd_haigo": newRow.cd_haigo,
                    "no_juni_yusen": newRow.no_juni_yusen,
                    "cd_line": newRow.cd_line,
                    "flg_mishiyo": newRow.seizo_line_mishiyo,
                    "dt_create": new Date(),
                    "cd_create": App.ui.page.user.Code,
                    "dt_update": new Date(),
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
                    "kbn_master": row.kbn_master,
                    "cd_haigo": row.cd_haigo,
                    "no_juni_yusen": row.no_juni_yusen,
                    "cd_line": row.cd_line,
//                    "nm_line": row.nm_line,
                    "flg_mishiyo": row.seizo_line_mishiyo,
                    "dt_create": row.dt_create,
                    "cd_create": row.cd_create,
                    "dt_update": new Date(),
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
                    "kbn_master": row.kbn_master,
                    "cd_haigo": row.cd_haigo,
                    "no_juni_yusen": row.no_juni_yusen,
                    "cd_line": row.cd_line,
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

                // TODO: ここまで
            };

            /// <summary>新規行を追加します。</summary>
            /// <param name="e">イベントデータ</param>
            var addData = function (e) {
                // 選択行のID取得
                var selectedRowId = getSelectedRowId(true),
                    position = "after";
                //position = "before";
                // 新規行データの設定
                var newRowId = App.uuid(),
                    addData = setAddData();
                if (App.isUndefOrNull(selectedRowId)) {
                    if (!searchCondition) {
                        // 情報メッセージのクリア
                        App.ui.page.notifyInfo.clear();
                        App.ui.page.notifyInfo.message(pageLangText.noRecords.text).show();
                        return;
                    }
                    // 末尾にデータ追加
                    grid.addRowData(newRowId, addData);
                    currentRow = 0;
                } else {
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
            $(".add-button").on("click", function (e) {
                // 検索済であるかチェック
                if (!isSearch) {
                    App.ui.page.notifyInfo.message(MS0621).show();
                    return;
                }
                // 検索条件変更チェック
                if (isCriteriaChange) {
                    showCriteriaChange("lineAdd");
                    return;
                }
                addData();
            });

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
                // 選択行の行データ削除
                grid.delRowData(selectedRowId);
                if (grid.getGridParam("records") > 0) {
                    // セルを選択して入力モードにする
                    grid.editCell(currentRow === 1 ? currentRow : currentRow - 1, currentCol, true);
                }
            };
            /// <summary>削除ボタンクリック時のイベント処理を行います。</summary>
            $(".delete-button").on("click", function (e) {
                // 検索条件変更チェック
                if (isCriteriaChange) {
                    showCriteriaChange("lineDel");
                    return;
                }
                deleteData();
            });

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
                    checkCol_a = 3;
                    checkCol_b = 5;
                // TODO: ここまで

                // データ整合性エラーのハンドリングを行います。
                if (App.isArray(ret) && ret.length > 0) {
                    for (var i = 0; i < ret.length; i++) {

                        for (var j = 0; j < ids.length; j++) {
                            // TODO: 画面の仕様に応じて以下の値を変更します。
                            value_a = grid.getCell(ids[j], checkCol_a);
                            value_b = parseInt(grid.getCell(ids[j], checkCol_b), 10);
                            ts = grid.getCell(ids[j], "ts");
                            retValue_a = ret[i].Data.cd_line;
                            retValue_b = ret[i].Data.no_juni_yusen;
                            // TODO: ここまで

                            //if (value_a === retValue_a && value_b === retValue_b && !ts) {
                            //if (value_a === retValue_a && value_b === retValue_b) {
                            if (value_b === retValue_b ) {
                                // TODO: 画面の仕様に応じて以下のロジックを変更します。
                                if (ret[i].InvalidationName === "NotExsists") {
                                //if (ret[i].ColumnName === "keys") {
                                    unique = ids[j] + "_" + checkCol_a + "_" + checkCol_b;

                                    // エラーメッセージの表示
                                    App.ui.page.notifyAlert.message(
                                        pageLangText.invalidation.text + ret[i].Message, unique).show();
                                    // 対象セルの背景変更
                                    //grid.setCell(ids[j], firstCol, ret[i].Data.cd_line, { background: '#ff6666' });
                                    grid.setCell(ids[j], firstCol + 2, ret[i].Data.no_juni_yusen, { background: '#ff6666' });
                                }
                                else {
                                    // エラーメッセージの表示
                                    App.ui.page.notifyAlert.message(
                                        pageLangText.invalidation.text + ret[i].Message).show();
                                }
                                // TODO: ここまで
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
                            value_a = grid.getCell(p, checkCol_a);
                            retValue_a = ret.Updated[i].Requested.cd_line;
                            value_b = parseInt(grid.getCell(p, checkCol_b), 10);
                            retValue_b = ret.Updated[i].Requested.no_juni_yusen;
                            // TODO: ここまで

                            if ((isNaN(value_a) || value_a === retValue_a) && (isNaN(value_b) || value_b === retValue_b)) {
                                // 更新状態の変更セットから変更データを削除
                                changeSet.removeUpdated(p);

                                // 他のユーザーによって削除されていた場合
                                if (App.isUndefOrNull(ret.Updated[i].Current)) {
                                    // 対象行の削除
                                    grid.delRowData(p);
                                    // メッセージの表示
                                    App.ui.page.notifyAlert.message(
                                        pageLangText.duplicate.text + pageLangText.deletedDuplicate.text).show();
                                } else {
                                    unique = p + "_" + duplicateCol;

                                    // TODO: 画面の仕様に応じて以下の値を変更します。
                                    current = grid.getRowData(p);
                                    current.cd_haigo = ret.Updated[i].Current.cd_haigo;
                                    current.no_juni_yusen = ret.Updated[i].Current.no_juni_yusen;
                                    current.cd_line = ret.Updated[i].Current.cd_line;
                                    current.flg_mishiyo = ret.Updated[i].Current.flg_mishiyo;
                                    current.ts = ret.Updated[i].Current.ts;
                                    // TODO: ここまで

                                    // 対象行の更新
                                    grid.setRowData(p, current);
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
                            value = changeSet.changeSet.deleted[p].cd_setsubi;
                            retValue = ret.Deleted[i].Requested.cd_setsubi;
                            // TODO: ここまで

                            if (isNaN(value) || value === retValue) {
                                // 削除状態の変更セットから変更データを削除
                                changeSet.removeDeleted(p);

                                // 他のユーザーによって削除されていた場合
                                if (App.isUndefOrNull(ret.Deleted[i].Current)) {
                                    // メッセージの表示
                                    App.ui.page.notifyAlert.message(
                                        pageLangText.duplicate.text + pageLangText.deletedDuplicate.text).show();
                                } else {
                                    // メッセージの表示
                                    App.ui.page.notifyAlert.message(
                                        pageLangText.duplicate.text + pageLangText.unDeletedDuplicate.text).show();
                                }
                            }
                        }
                    }
                }
            };

            /// <summary>変更を保存します。</summary>
            /// <param name="e">イベントデータ</param>
            var saveData = function (e) {
                closeSaveConfirmDialog();
                // 情報メッセージのクリア
                App.ui.page.notifyInfo.clear();
                // ローディングの表示
                App.ui.loading.show(pageLangText.nowSaving.text);

                // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                var saveUrl = "../api/SeizoLineMaster";
                // TODO: ここまで

                App.ajax.webpost(
                    saveUrl, getPostData()
                ).done(function (result) {
                    // 検索前の状態に初期化
                    clearState();
                    App.ui.page.notifyInfo.message(pageLangText.successMessage.text).show();
                    // データ検索
                    //querySetting.top = 500;
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
                // 編集内容の保存
                saveEdit();
    			// 変更セット内にバリデーションエラーがある場合は処理を抜ける
    			if (!validateChangeSet()) {
                    // ローディングの終了
                    App.ui.loading.close();
    				return;
    			}
    			// エラーメッセージのクリア
    			App.ui.page.notifyAlert.clear();
    			// 変更がない場合は処理を抜ける
    			if (noChange()) {
    				App.ui.page.notifyInfo.message(pageLangText.noChange.text).show();
                    // ローディングの終了
                    App.ui.loading.close();
    				return;
    			}
                // 保存確認ダイアログを表示する
    			showSaveConfirmDialog();
    		}

            /// <summary>保存ボタンクリック時のイベント処理を行います。</summary>
            $(".save-button").on("click", function () {
                // 検索条件変更チェック
                if (isCriteriaChange) {
                    showCriteriaChange("save");
                    return;
                }
                loading(pageLangText.nowProgressing.text, "save-button");
            });

            //// 保存処理 -- End

            //// バリデーション -- Start

            // グリッドコントロール固有のバリデーション

            // TODO: 画面の仕様に応じて以下のカスタムバリデーション定義を変更してください。
            
            /// <summary>データベース問い合わせチェックを行います。</summary>
            /// <param name="lineCode">ラインコード</param>
            var isValidLineCode = function (lineCode) {
                var isValid = false;

                App.ajax.webgetSync("../Services/FoodProcsService.svc/ma_line()?$filter=cd_line eq '" + lineCode + "' and flg_mishiyo eq " + pageLangText.shiyoMishiyoFlg.text + "&$top=1"
                ).done(function (result) {
                    // 入力項目のバリデーション
                    $.each(result.d, function (index, data) {
                        if (data.cd_line === lineCode) {
                            isValid = true;
                            return false;
                        }
                    });
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                });
                validationSetting.cd_line.messages.custom = App.str.format(MS0049, pageLangText.seizoLineCode.text);
                return isValid;
            };

            validationSetting.cd_line.rules.custom = function (value) {
                return isValidLineCode(value);
            };

            /// <summary>検索条件コード入力チェック</summary>
            /// <param name="hinmeiCode">コード</param>
            var isValidCode = function (code) {
                var isValid = true
                    , masterKubun = $("#condition-masterkubun").val()
                    , serviceUrl = ""
                    , name = "";
                if (masterKubun == pageLangText.seihinHinKbn.text) {
                    serviceUrl = "../Services/FoodProcsService.svc/ma_hinmei()?$filter=cd_hinmei eq '" + code + "' and flg_mishiyo eq " + pageLangText.shiyoMishiyoFlg.text + "&$top=1";
                    name = "nm_hinmei_" + App.ui.page.lang;
                }
                else if (masterKubun == pageLangText.genryoHinKbn.text) {
                    serviceUrl = "../Services/FoodProcsService.svc/ma_haigo_mei()?$filter=cd_haigo eq '" + code + "' and flg_mishiyo eq " + pageLangText.shiyoMishiyoFlg.text + "&$top=1";
                    name = "nm_haigo_" + App.ui.page.lang;
                }
                App.ajax.webgetSync(serviceUrl
                ).done(function (result) {
                    // !! 存在チェック
                    if (result.d.length === 0) {
                        // 検索結果件数が0件の場合
                        // 品名マスタ存在チェックエラー
                        $("#condition-haigoname").text("");
                        validationSetting.haigoCode.messages.custom = App.str.format(MS0049, pageLangText.haigoCode.text);
                        isValid = false;
                    }
                    else {
                        $("#condition-haigoname").text(result.d[0][name]);
                    }
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                });
                return isValid;
            }

            // 検索条件ード：カスタムバリデーション
            validationSetting.haigoCode.rules.custom = function (value) {
                return isValidCode(value);
            };
            // TODO: ここまで

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

    		/// 品名ダイアログを開く
    		var showHinmeiDialog = function () {
    			var criteria = $(".search-criteria").toJSON();
    			openHinmeiDialog("hinmei", criteria.masterKubun, hinmeiDialog);
    		}

    		/// 品名ダイアログを起動する
    		var openHinmeiDialog = function (dlgName, msKbn, dialog) {
    			var option;
    			switch (msKbn) {
    				case pageLangText.hinmeiMasterSeizoLineMasterKbn.text:
    					option = { id: dlgName, multiselect: false, param1: pageLangText.seihinJikagenHinDlgParam.text };
    					break;
    				case pageLangText.haigoMasterSeizoLineMasterKbn.text:
    					option = { id: dlgName, multiselect: false, param1: pageLangText.shikakariHinDlgParam.text };
    					break;
    				default:
    					break;
    			}
    			dialog.draggable(true);
    			dialog.dlg("open", option);
    		}
            /// <summary> ラインマスタセレクタを起動する </summary>
            var showLineDialog = function (rowid) {
                // フォーカスを隣カラムへ移動させる(※値貼り付け後のバグ対策)
                $("#" + rowid + " td:eq('" + (grid.getColumnIndexByName("cd_line") + 1) + "')").click();
                var option = {id: 'line', multiselect: false };
                lineDialog.draggable(true);
                lineDialog.dlg("open", option);
            }
            /// <summary>検索条件変更チェックメッセージを出力します。</summary>
            /// <param name="outMessage">出力メッセージ</param>
            var showCriteriaChange = function (outMessage) {
                // 情報メッセージのクリア
                App.ui.page.notifyInfo.clear();
                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();
                switch (outMessage) {
                    case "navigate":
                        var alertMessage = pageLangText.navigate.text;
                        break;
                    case "rowChange":
                        var alertMessage = pageLangText.rowChange.text;
                        break;
                    case "lineAdd":
                        var alertMessage = pageLangText.lineAdd.text;
                        break;
                    case "lineDel":
                        var alertMessage = pageLangText.lineDel.text;
                        break;
                    case "save":
                        var alertMessage = pageLangText.save.text;
                        break;
                    case "del":
                        var alertMessage = pageLangText.del.text;
                        break;
                    case "colchange":
                        var alertMessage = pageLangText.colchange.text;
                        break;
                    case "output":
                        var alertMessage = pageLangText.output.text;
                        break;
                }
            }
            /// <summary>ローディングの表示</summary>
            var loading = function (msgid, fnc) {
                App.ui.loading.show(msgid);
                var deferred = $.Deferred();
                deferred
                .then(function() {
                    var d = new $.Deferred;
                    setTimeout(function() {
                        App.ui.loading.show(msgid);
                        d.resolve();
                    }, 50);
                    return d;
                })
                .then(function() {
                    if (fnc === "save-button") {
                        checkSave();
                    }
                    else if (fnc === "find-button") {
                        checkSearch();
                    }
                    else if (fnc === "check-button") {
                        checkAll();
                    }
                    else if (fnc === "excel-button") {
                        checkExcel();
                    }
                });
                deferred.resolve();
            }

            /// <summary> レコード件数チェック </summary>
            var checkRecordCount = function () {
                recordCount = grid.getGridParam("records");
                    // レコードがない場合は処理を抜ける
                if (recordCount == 0) {
                    App.ui.page.notifyInfo.message(pageLangText.noRecords.text).show();
                    return false;
                }
                return true;
            };
            /// <summary> ダイアログの起動可否のチェック </summary>
            var checkShowDialog = function (rowid) {
                // 各種フラグによるチェック
                if (!App.isUndefOrNull(grid.getCell(rowid, "ts")) && grid.getCell(rowid, "ts") != "") {
                    return false;
                }
                return true;
            }

            /// <summary>ファンクションキー対応処理</summary>
            /// <param name="e">イベントデータ</param>
            var processFunctionKey = function (e) {
                var processed = false;
                // TODO: 画面の仕様に応じて以下のファンクションキー毎の処理を定義します。
                if (e.keyCode === App.ui.keys.F2) {
                    // F2の処理
                    processed = true;
                } else if (e.keyCode === App.ui.keys.F3) {
                    //F3の処理
                    processed = true;
                }
                // TODO: ここまで
                if (processed) {
                    //何か処理を行なっていた場合、ブラウザ既定の動作を無効にする
                    e.preventDefault();
                }
            };

    		/// <summary>検索条件品名コード検索ボタンクリック時のイベント処理を行います。</summary>
    		$("#hinmei_kensaku-button").on("click", function (e) {
    			// 品名セレクタ起動
    			showHinmeiDialog();
    		});
            /// <summary>ライン検索ボタンクリック時のイベント処理を行います。</summary>
            $(".line-button").on("click", function (e) {
                // 検索条件変更チェック
                if (isCriteriaChange) {
                    showCriteriaChange("navigate");
                    return;
                }
                // 各種チェック
                if (!checkRecordCount()) {
                    return;
                }
                var rowid = getSelectedRowId(false);
                if (checkShowDialog(rowid)) {
                    showLineDialog(rowid);
                }
            });

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

            // <summary>保存確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".save-confirm-dialog .dlg-no-button").on("click", function () {
                // ローディングの終了
                App.ui.loading.close();
                closeSaveConfirmDialog();
            });

	        /// <summary>検索確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
	        $(".search-confirm-dialog .dlg-yes-button").on("click", findData);

	        // <summary>検索確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
	        $(".search-confirm-dialog .dlg-no-button").on("click", closeSearchConfirmDialog);
            
            /// <summary>クリアボタンクリック時のイベント処理を行います。</summary>
            //$(".clear-button").on("click", showClearConfirmDialog);

            var clearData = function () {
                changeSet = new App.ui.page.changeSet();
                location.reload();
            };

            // <summary>前ページよりパラメータを取得し、条件によって初期表示時に検索を行います。</summary>
            // TODO: 画面の仕様に応じて以下の値を変更します。
            var paramMasterKubun = "<%= Page.Request.QueryString.Get("kbn_master") %>",
                paramHaigoCode = "<%= Page.Request.QueryString.Get("cd_haigo") %>";
            if ( (!App.isUndefOrNull(paramMasterKubun) && paramMasterKubun.length > 0)
                    || (!App.isUndefOrNull(paramHaigoCode) && paramHaigoCode.length > 0) ) {
                    $("#condition-masterkubun").val(paramMasterKubun);
                    $("#condition-haigocode").val(paramHaigoCode);
                    var criteria = $(".search-criteria").toJSON();
                    getCodeName(criteria.masterKubun, criteria.haigoCode);
                    $(".find-button").trigger("click");
            }
	        /// <summary>データに変更があり、未保存の状態でページを離れる際に確認を行います。</summary>
	        //別画面に遷移したりするときに実行する関数の定義
	        var onBeforeUnload = function () {
	            //var rowid = getSelectedRowId(false);
	            //$("#" + rowid + " td:eq('" + grid.getColumnIndexByName("flg_mishiyo") + "')").click();
	            //データを変更したかどうかは各画面でチェックし、保持する
                if (!noChange()) {
	                return pageLangText.unloadWithoutSave.text;
	            }
	        }
	        $(window).on('beforeunload', onBeforeUnload);   //beforeunloadイベントに関数を割り当て
	        //formをsubmit（ログオフ）する場合、beforeunloadイベントを発生させないようにする
	        $('form').on('submit', function () {
	            $(window).off('beforeunload');
	        });
	        $("#loginButton").attr('onclick', '');  //クリック時の記述を削除
	        $("#loginButton").on('click', function () {
	            //var rowid = getSelectedRowId(false);
	            //$("#" + rowid + " td:eq('" + grid.getColumnIndexByName("flg_mishiyo") + "')").click();
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

	        // <summary>前ページよりパラメータを取得し、条件によって初期表示時に検索を行います。</summary>
	        // TODO: 画面の仕様に応じて以下の値を変更します。

	        // TODO: ここまで

	        var backToMenu = function () {
	            //var rowid = getSelectedRowId(false);
	            //$("#" + rowid + " td:eq('" + grid.getColumnIndexByName("flg_mishiyo") + "')").click();
	            // IEバグによる例外発生をキャッチします。例外発生時は何もしません。
	            try {
	                document.location = pageLangText.menuPath.url;
	            }
                catch (e) {
	            }
	        };
	        /// <summary>メニューボタンクリック時のイベント処理を行います。</summary>
	        $(".menu-button").on("click", backToMenu);


	        // 製造ライン未登録一覧画面から遷移してきたときの処理
	        /// <summary>URLからクエリ文字列を取得します。</summary>
	        var getParameters = function () {
	            var pamameters = {},
					keyValue,
					parameterStartPos = window.location.href.indexOf('?') + 1,
					queryStrings;

	            if (parameterStartPos > 0) {
	                queryStrings = window.location.href.slice(parameterStartPos).split('&');
	            }
	            if (!App.isUnusable(queryStrings)) {
	                for (var i = 0; i < queryStrings.length; i++) {
	                    keyValue = queryStrings[i].split('=');
	                    pamameters[keyValue[0]] = keyValue[1];
	                }
	            }
	            return pamameters;
	        };

	        // urlよりパラメーターを取得
	        var parameters = getParameters();
	        var paramKubun = parameters["kbnHaigo"];
	        var paramCode = parameters["cdHaigo"];
	        if (!App.isUndefOrNull(paramKubun) && !App.isUndefOrNull(paramCode)) {
	            $("#condition-masterkubun").val(paramKubun);
	            $("#condition-haigocode").val(paramCode);
	            // 品コードから原資材情報を取得
	            isValidCode(paramCode);
	            // パラメーターを条件に検索処理を行う
	            findData();
	        }
	        // 製造ライン未登録一覧画面から遷移してきたときの処理：ここまで
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
                        <span class="item-label" data-app-text="masterKubun"></span>
                        <select name="masterKubun" id="condition-masterkubun">
                        </select>
                    </label>
                </li>
                <li>
                    <label>
                        <span class="item-label" data-app-text="haigoCode"></span>
                        <input type="text" name="haigoCode" id="condition-haigocode" />
                    </label>
                    <button type="button" class="dialog-button" id="hinmei_kensaku-button" >
                        <span class="icon"></span><span data-app-text="codeSearch"></span>
                    </button>
                </li>
                <li>
                    <label>
                        <span class="item-label" data-app-text="haigoName"></span>
                        <span class="conditionname-label" id="condition-haigoname"></span>
                    </label>
                </li>
                <!-- TODO: ここまで -->
            </ul>
        </div>
        <div class="part-footer">
            <div class="command">
                <button type="button" class="find-button" name="find-button" data-app-operation="search">
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
                <button type="button" class="colchange-button" data-app-operation="colchange"><span class="icon"></span><span data-app-text="colchange"></span></button>
                <button type="button" class="add-button" name="add-button" data-app-operation="add"><span class="icon"></span><span data-app-text="add"></span></button>
                <button type="button" class="delete-button" name="delete-button" data-app-operation="del"><span class="icon"></span><span data-app-text="del"></span></button>
                <button type="button" class="line-button" name="line-ichiran-button" data-app-operation="line"><span class="icon"></span><span data-app-text="lineIchiran"></span></button>
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
    <div class="search-confirm-dialog" style="display: none;">
        <div class="dialog-header">
            <h4 data-app-text="confirmTitle"></h4>
        </div>
        <div class="dialog-body" style="padding: 10px; width: 100%;">
            <div class="part-body">
                <span data-app-text="searchConfirm"></span>
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
    <div class="hinmei-dialog">
    </div>
	<div class="line-dialog">
	</div>
    <!-- TODO: ここまで  -->

    <!-- 画面デザイン -- End -->
</asp:Content>
