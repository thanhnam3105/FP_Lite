<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
	CodeBehind="FutaiKetteiMaster.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.FutaiKetteiMaster" %>

<asp:Content ID="Content1" ContentPlaceHolderID="IncludeContent" runat="server">
	<script src="<%=ResolveUrl("~/Resources/pages/pagedata-futaiketteimaster." + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
		type="text/javascript"></script>
	<script src="<%=ResolveUrl("~/Resources/grid/grid.locale-" + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
		type="text/javascript"></script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
	<style type="text/css">
		/* 画面デザイン -- Start */
		
		/* TODO：画面の仕様に応じて以下のスタイルを変更してください。 */
		.search-criteria .item-label
		{
			width: 8em;
		}
		
		.pad-apace
		{
			padding-left: 3em;
		}
		
		button.futai-button .icon
		{
			background-position: -48px -80px;
		}
		
		button.toroku-button .icon
		{
			background-position: -48px -80px;
		}
		
		button.hinmei-button .icon
		{
			background-position: -48px -80px;
		}
		
		.futai-dialog
		{
			background-color: White;
			width: 550px;
		}

		.hinmei-dialog
		{
			background-color: White;
			width: 550px;
		}

		.toroku-dialog
		{
			background-color: White;
			width: 700px;
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
                isSearch = false, // 検索フラグ
                isCriteriaChange = false,   // 検索条件変更フラグ
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
                genryoDialogParam = pageLangText.genryoHinDlgParam.text,
                shikakariDialogParam = pageLangText.shikakariHinDlgParam.text,
                jikaGenryoDlgParam = pageLangText.jikaGenryoHinDlgParam.text,
                futaiCodeCol = 3,
                futaiNameCol = 4,
                flgMishiyoCol = 5,
                selectRowCol = 5,   // 先頭行選択時に指定する、ダミーセル
                nextScrollTop = 0,
                errRows = new Array();   // エラー行の格納用
	        var comboChange = false;
	        // チェックボックスを直接編集した際に値が反映されない問題の回避策
	        // チェックボックスを使用した列のcolModelに以下オプションを追加してください
	        // "formatter: fn_formatValue, unformat: fn_unformatValue"
	        var fn_formatValue = function (celldata, options, rowobject) {
	            showdata = options.colModel.editoptions.value()[celldata];
	            return $(document.createElement('span')).attr('original-value', celldata).text(showdata)[0].outerHTML;
	        };

	        var fn_unformatValue = function (celldata, options, cellobject) {
	            return $(cellobject).children('span').attr('original-value');
	        };

	        // TODO: ここまで

	        // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
	        var searchCriteriaSetting = {
	            kbn_jotai: null
                , kbn_hin: null
                , cd_hinmei: null
	        };

	        //// コントロール定義 -- Start

	        // ダイアログ生成
	        var hinmeiDialog = $(".hinmei-dialog");
	        hinmeiDialog.dlg({
	            url: "Dialog/HinmeiDialog.aspx",
	            name: "HinmeiDialog",
	            closed: function (e, data, data2) {
	                if (data == "canceled") {
	                    return;
	                }
	                else {
	                    var selectedRowId = getSelectedRowId(false);
	                    $(".item-list [name='cd_hinmei']").val(data).change();
	                    $(".item-list [name='nm_hinmei']").val(data2);

	                    // 更新状態の変更セットに変更データを追加
	                    var changeData = setCreatedChangeData(grid.getRowData(selectedRowId));
	                    changeSet.addUpdated(selectedRowId, "cd_hinmei", data, changeData);
	                }
	            }
	        });
	        var futaiDialog = $(".futai-dialog");
	        futaiDialog.dlg({
	            url: "Dialog/FutaiDialog.aspx",
	            name: "FutaiDialog",
	            closed: function (e, data, data2) {
	                if (data == "canceled") {
	                    return;
	                }
	                else {
	                    var selectedRowId = getSelectedRowId(false);
	                    grid.setCell(selectedRowId, "cd_futai", data);
	                    grid.setCell(selectedRowId, "nm_futai", data2);

	                    // 更新状態の変更セットに変更データを追加
	                    var changeData = setCreatedChangeData(grid.getRowData(selectedRowId));
	                    changeSet.addUpdated(selectedRowId, "cd_futai", data, changeData);
	                    // 再チェックで背景色とメッセージのリセット
	                    validateCell(selectedRowId, "cd_futai", grid.getCell(selectedRowId, "cd_futai"), futaiCodeCol);
	                }
	            }
	        });
	        var torokuDialog = $(".toroku-dialog");
	        torokuDialog.dlg({
	            url: "Dialog/FutaiKetteiTorokuIchiranDialog.aspx",
	            name: "FutaiKetteiTorokuIchiranDialog",
	            closed: function (e, data, data2, data3) {
	                if (data == "canceled") {
	                    return;
	                }
	                else {
	                    $("#condition-cd_hinmei").val(data);
	                    $("#condition-nm_hinmei").text(data2);
	                    $("#condition-kbn_hin").val(data3);

	                    // 再チェックでエラー背景などをリセット
	                    $(".part-body .item-list").validation().validate();
	                }
	            }
	        });

	        // ダイアログ固有の変数宣言
	        // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
	        var saveConfirmDialog = $(".save-confirm-dialog"),
                searchConfirmDialog = $(".search-confirm-dialog");

	        // ダイアログ固有のコントロール定義
	        saveConfirmDialog.dlg();
	        searchConfirmDialog.dlg();

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
	            }
                else {
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

	        /// 検索条件を保持する
	        var saveSearchCriteria = function () {
	            var criteria = $(".search-criteria").toJSON();
	            searchCriteriaSetting = {
	                kbn_jotai: criteria.kbn_jotai,
	                kbn_hin: criteria.kbn_hin,
	                cd_hinmei: criteria.cd_hinmei
	            };
	        };

	        // グリッドコントロール固有のコントロール定義
	        var selectCol;
	        grid.jqGrid({
	            // TODO：画面の仕様に応じて以下の列名の定義を変更してください。
	            colNames: [
                    pageLangText.wt_kowake.text + pageLangText.requiredMark.text
                    , pageLangText.cd_tani.text + pageLangText.requiredMark.text
	            //, pageLangText.nm_tani.text
                    , pageLangText.cd_futai.text + pageLangText.requiredMark.text
                    , pageLangText.nm_futai.text
                    , pageLangText.flg_mishiyo.text
                    , pageLangText.kbn_jotai.text
                    , pageLangText.cd_hinmei.text
                    , pageLangText.dt_create.text
                    , pageLangText.cd_create.text
                    , pageLangText.ts.text
                    , pageLangText.kbn_hin.text
                ],
	            // TODO：ここまで
	            // TODO：画面の仕様に応じて以下の列モデルの定義を変更してください。
	            colModel: [
                    { name: 'wt_kowake', width: pageLangText.wt_kowake_width.number, hidden: false, editable: true, sorttype: "float", align: "right",
                        formatter: 'number',
                        formatoptions: {
                            decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 6, defaultValue: ""
                        }
                    },
                    { name: 'cd_tani', width: pageLangText.cd_tani_width.number, editable: true, hidden: false, edittype: 'select', sorttype: "text",
                        editoptions: {
                            value: function () {
                                // グリッド内のドロップダウンの生成
                                return grid.prepareDropdown(tani, "nm_tani", "cd_tani");
                            }
                        }, formatter: fn_formatValue, unformat: fn_unformatValue, align: 'center'
                    },
                    { name: 'cd_futai', width: pageLangText.cd_futai_width.number, hidden: false, editable: true, sorttype: "text" },
                    { name: 'nm_futai', width: pageLangText.nm_futai_width.number, editable: false, sorttype: "text" },
                    { name: 'flg_mishiyo', width: pageLangText.flg_mishiyo_width.number, editable: true, hidden: false, edittype: 'checkbox',
                        editoptions: { value: "1:0" }, formatter: "checkbox", formatoptions: { disabled: false }, align: 'center'
                    },
                    { name: 'kbn_jotai', width: 0, hidden: true, hidedlg: true },
                    { name: 'cd_hinmei', widt: 0, hidden: true, hidedlg: true },
                    { name: 'dt_create', width: 0, hidden: true, hidedlg: true },
                    { name: 'cd_create', width: 0, hidden: true, hidedlg: true },
                    { name: 'ts', width: 0, hidden: true, hidedlg: true },
                    { name: 'kbn_hin', width: 0, hidden: true, hidedlg: true }
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
	                setRelatedChangeData(selectedRowId, cellName, value, changeData);
	                if (cellName === "cd_futai") {
	                    if (!App.isUndefOrNull(value) && value != "") {
	                        getCodeName(value, "cd_futai", selectedRowId);
	                    }
	                    else {
	                        grid.setCell(selectedRowId, "nm_futai", null);
	                    }
	                }
	            },
	            loadComplete: function () {
	                var ids = grid.jqGrid('getDataIDs'),
	                    id;
	                for (var i = 0; i < ids.length; i++) {
	                    id = ids[i];
	                    if (grid.jqGrid('getCell', id, 'ts')) {
                            // 既存行は風袋コードを編集不可にする：ここで読み込まれる＝既存行
                            grid.jqGrid('setCell', id, 'cd_futai', '', 'not-editable-cell');

                            // 未使用フラグが立っていた場合、未使用以外の項目を編集不可とする
                            var flgMishiyo = grid.jqGrid('getCell', id, 'flg_mishiyo');
	                        if (flgMishiyo == pageLangText.trueFlg.text) {
	                            grid.jqGrid('setCell', id, 'wt_kowake', '', 'not-editable-cell');
	                            grid.jqGrid('setCell', id, 'cd_tani', '', 'not-editable-cell');
	                        }
                        }
	                }
	            },
	            gridComplete: function () {
	                // 検索条件を保持する
	                //saveSearchCriteria();
	                // 先頭行を選択する
                    // グリッドの先頭行選択
                    var idNum = grid.getGridParam("selrow");
                    if (idNum == null) {
                        $("#1 > td").click();
                    }
                    else {
                        $("#" + idNum).removeClass("ui-state-highlight").find("td").click();
                    }
	            },
	            onCellSelect: function (rowid, icol, cellcontent) {
	                selectCol = icol;
	            },
	            ondblClickRow: function (rowid) {
	                // 風袋コードまたは風袋名をダブルクリック時
	                if (selectCol == grid.getColumnIndexByName("cd_futai")
                        || selectCol == grid.getColumnIndexByName("nm_futai")) {
	                    // 風袋マスタ一覧起動
	                    showFutaiDialog();
	                }
	            }
	        });

	        /// <summary>チェックボックス操作時のグリッド値更新を行います</summary>
	        $(document).on("click", "#item-grid .jqgrow td :checkbox", function () {
                selectCol = flgMishiyoCol;
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
	        var setRelatedValue = function (selectedRowId, cellName, value, iCol) {
	            // TODO：画面の仕様に応じて以下の関連項目を設定を変更してください。
	            // 単位コード再設定
	            if (cellName === "nm_tani") {
	                grid.setCell(selectedRowId, "cd_tani", value);
	            }
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
	        $(".colchange-button").on("click", showColumnSettingDialog);

	        //// コントロール定義 -- End

	        //// 操作制御定義 -- Start

	        // 操作制御定義を定義します。
	        App.ui.pagedata.operation.applySetting(App.ui.page.user.Roles[0], App.ui.page.lang);
	        //// 操作制御定義 -- End

	        //// 事前データロード -- Start 

	        // 画面アーキテクチャ共通の事前データロード
	        var kbn_jotai,
                kbn_hin,
                tani,
                loading;

	        // TODO: 画面の仕様に応じて以下の処理を変更してください。
	        App.deferred.parallel({
	            // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
	            loading: App.ui.loading.show(pageLangText.nowProgressing.text),

	            kbn_jotai: App.ajax.webget("../Services/FoodProcsService.svc/ma_kbn_jotai?$filter=kbn_jotai ne " + pageLangText.shikakariJotaiKbn.text),
	            kbn_hin: App.ajax.webget("../Services/FoodProcsService.svc/ma_kbn_hin?$filter="
                    + "kbn_hin eq " + parseInt(pageLangText.genryoHinKbn.text) + " or kbn_hin eq " + parseInt(pageLangText.shikakariHinKbn.text) + " or kbn_hin eq " + parseInt(pageLangText.jikaGenryoHinKbn.text)),
	            tani: App.ajax.webget("../Services/FoodProcsService.svc/ma_tani?$filter=flg_mishiyo eq " + pageLangText.shiyoMishiyoFlg.text)
	            // TODO: ここまで
	        }).done(function (result) {
	            // TODO: 画面の仕様に応じて以下のサービス呼び出し成功時の処理を変更してください。
	            kbn_jotai = result.successes.kbn_jotai.d;
	            kbn_hin = result.successes.kbn_hin.d;
	            tani = result.successes.tani.d;
	            // 検索用ドロップダウンの設定
	            App.ui.appendOptions($(".search-criteria [name='kbn_jotai']"), "kbn_jotai", "nm_kbn_jotai", kbn_jotai, false);
	            App.ui.appendOptions($(".search-criteria [name='kbn_hin']"), "kbn_hin", "nm_kbn_hin", kbn_hin, false);
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
	        }).always(function () {
	            App.ui.loading.close();
	        });

	        // TODO: ここまで

	        //// 事前データロード -- End

	        //// 検索処理 -- Start

	        // 画面アーキテクチャ共通の検索処理

	        /// <summary>クエリオブジェクトの設定</summary>
	        var queryWeb = function () {
	            var criteria = $(".search-criteria").toJSON();
	            saveSearchCriteria();   // 検索条件を保持する

	            var query = {
	                // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
	                url: "../api/FutaiKetteiMaster"
                    , kbn_jotai: criteria.kbn_jotai
                    , cd_hinmei: criteria.cd_hinmei
	                // TODO: ここまで
                    , skip: querySetting.skip
                    , top: querySetting.top
                    , kbn_hin: criteria.kbn_hin
	            }
	            return query;
	        };

	        /// <summary>データ検索を行います。</summary>
	        /// <param name="queryweb">クエリオブジェクト</param>
	        var searchItems = function (queryWeb) {
	            if (isDataLoading === true) {
	                return;
	            }
	            isDataLoading = true;
	            // ローディングの表示
	            $("#list-loading-message").text(
                    pageLangText.nowLoading.text
	            //App.str.format(
	            //    pageLangText.nowListLoading.text,
	            //    querySetting.skip + 1,
	            //    querySetting.top
	            //)
                );
	            App.ajax.webget(
                    App.data.toWebAPIFormat(queryWeb)
                ).done(function (result) {
                    // 検索フラグを立てる
                    isSearch = true;
                    if (parseInt(result.__count) === 0) {
                        App.ui.page.notifyAlert.message(MS0037).show();
                    }
                    else {
                        // データバインド
                        bindData(result);
                        // 検索条件を閉じる
                        closeCriteria();
                    }
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

	        var findData = function () {
	            closeSearchConfirmDialog();

	            clearState();
	            var criteria = $(".search-criteria").toJSON();
	            if (criteria.kbn_jotai == pageLangText.sonotaJotaiKbn.text) {
	                // 検索前バリデーション
	                var result = $(".part-body .item-list").validation().validate();
	                if (result.errors.length) {
	                    return;
	                }
	            }
	            searchItems(new queryWeb());
	        };
	        /// <summary>検索ボタンクリック時のイベント処理を行います。</summary>
	        $(".find-button").on("click", showSearchConfirmDialog);

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
	            nextScrollTop = 0;
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
	        var displayCount = function (resultCount) {
	            if (App.isUndefOrNull(resultCount)) {
	                resultCount = 0;
	            }
	            $("#list-count").text(
                     App.str.format("{0}/{1} " + pageLangText.itemCount.text, querySetting.count, resultCount)
                );
	        };
	        /// <summary>データをバインドします。</summary>
	        /// <param name="result">検索結果</param>
	        var bindData = function (result) {
	            // グリッドの表示件数を更新
	            grid.setGridParam({ rowNum: querySetting.top });
	            var resultCount = parseInt(result.__count);
	            if (resultCount > querySetting.top) {
                    // 検索結果が上限数を超えていた場合
	                App.ui.page.notifyAlert.message(
                        App.str.format(pageLangText.overSearchCount.text, resultCount, querySetting.top)
                    ).show();
	                querySetting.count = querySetting.top;
	            }
	            else {
	                querySetting.count = resultCount;
	            }
	            displayCount(resultCount);
	            // データバインド
	            var currentData = grid.getGridParam("data").concat(result.d);
	            grid.setGridParam({ data: currentData }).trigger('reloadGrid', [{ current: true}]);
	            App.ui.page.notifyInfo.message(
                     App.str.format(pageLangText.searchResultCount.text, querySetting.count, resultCount)
                ).show();
	        };

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
	            // 選択行なしの場合は最上行を選択
	            if (App.isUnusable(selectedRowId)) {
	                selectedRowId = ids[0]; // 先頭行
	            }
	            currentRow = $('#' + selectedRowId)[0].rowIndex;

	            return selectedRowId;
	        };

	        /// <summary>新規行データの設定を行います。</summary>
	        var setAddData = function () {
	            // TODO: 画面の仕様に応じて以下の項目を変更してください。
	            var criteria = $(".search-criteria").toJSON();
	            var hinmeiCode = criteria.cd_hinmei;
	            if (App.isUndefOrNull(hinmeiCode)) {
	                hinmeiCode = "";
	            }
	            var jotaiKubun = criteria.kbn_jotai,
                    hinKubun;
	            if (pageLangText.sonotaJotaiKbn.text === jotaiKubun) {
	                hinKubun = criteria.kbn_hin
	            }
	            else {
	                hinKubun = parseInt(pageLangText.systemValueZero.text);
	            }
	            var addData = {
	                "kbn_jotai": criteria.kbn_jotai,
	                "kbn_hin": hinKubun,
	                "cd_hinmei": hinmeiCode,
	                "cd_futai": "",
	                "nm_futai": "",
	                "wt_kowake": null,
	                "cd_tani": tani[0].cd_tani,
	                "flg_mishiyo": 0
	            };
	            // TODO: ここまで

	            return addData;
	        };
	        /// <summary>コピー行データの設定を行います。</summary>
	        /// <param name="row">選択行</param>
	        var setCopyData = function (row) {
	            // TODO: 画面の仕様に応じて以下の項目の初期値を変更してください。
	            return $.extend({}, row, { "kenninId": 0 });
	            // TODO: ここまで
	        };
	        /// <summary>追加状態の変更セットに追加する変更データの設定を行います。</summary>
	        /// <param name="newRow">新規行データ</param>
	        var setCreatedChangeData = function (newRow) {
	            // TODO: 画面の仕様に応じて以下の項目を変更してください。
	            var changeData = {
	                "kbn_jotai": newRow.kbn_jotai,
	                "kbn_hin": newRow.kbn_hin,
	                "cd_hinmei": newRow.cd_hinmei,
	                "cd_futai": newRow.cd_futai,
	                "wt_kowake": newRow.wt_kowake,
	                "cd_tani": newRow.cd_tani,
	                "flg_mishiyo": newRow.flg_mishiyo,
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
	                "kbn_jotai": row.kbn_jotai,
	                "kbn_hin": row.kbn_hin,
	                "cd_hinmei": row.cd_hinmei,
	                "cd_futai": row.cd_futai,
	                "wt_kowake": row.wt_kowake,
	                "cd_tani": row.cd_tani,
	                "flg_mishiyo": row.flg_mishiyo,
	                "dt_create": App.data.getDate(row.dt_create),
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
	                "kbn_jotai": row.kbn_jotai,
	                "kbn_hin": row.kbn_hin,
	                "cd_hinmei": row.cd_hinmei,
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
	                changeSet.addUpdated(selectedRowId, "cd_hinmei", value, changeData);
	            }
	            // TODO: ここまで
	        };

	        /// <summary>行を削除します。</summary>
	        /// <param name="e">イベントデータ</param>
	        var deleteData = function (e) {
	            // エラーメッセージのクリア
	            App.ui.page.notifyAlert.clear();

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
	            //if (isCriteriaChange) {
	            //    showCriteriaChange("lineDel");
	            //    return;
	            //}
	            deleteData();
	        });

	        /// <summary>新規行を追加します。</summary>
	        /// <param name="e">イベントデータ</param>
	        var addData = function (e) {
	            App.ui.page.notifyAlert.clear();
	            ///// チェック処理
	            // 検索後であること
	            if (App.isUndefOrNull(searchCriteriaSetting.kbn_jotai)) {
	                App.ui.page.notifyAlert.message(pageLangText.searchBefore.text).show();
	                return;
	            }

	            var criteria = $(".search-criteria").toJSON();
	            // 検索条件が変更されていないこと
	            if (!noChangeCriteria()) {
	                App.ui.page.notifyAlert.message(pageLangText.changeCondition.text).show();
	                return;
	            }

	            // 状態区分が「その他」の場合
	            if (criteria.kbn_jotai == pageLangText.sonotaJotaiKbn.text) {
	                // 正しい品名コードが入力されていること
	                var result = $(".part-body .item-list").validation().validate();
	                if (result.errors.length) {
	                    return;
	                }
	            }

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
	            //grid.setCell(currentRow + 1, 'cd_tani', tani[0].cd_tani);
	            // セルを選択して入力モードにする
	            grid.editCell(currentRow + 1, firstCol, true);
	        };

	        /// <summary>追加ボタンボタンクリック時のイベント処理を行います。</summary>
	        $(".add-button").on("click", function () {
	            // 行選択。セレクタ起動後に保存などのボタン押下で値がクリアされる不具合の対応。
	            var idNum = grid.getGridParam("selrow");
	            $("#" + idNum + " td:eq('" + (selectRowCol) + "')").click();

	            addData();
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
                                current;
	            // TODO: 画面の仕様に応じて以下の変数を変更します。
	            checkCol = grid.getColumnIndexByName("cd_futai");
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
	                            ts = grid.getCell(ids[j], "ts");
	                            // TODO: ここまで

	                            if (value === retValue) {
	                                // TODO: 画面の仕様に応じて以下のロジックを変更します。
	                                unique = ids[j] + "_" + checkCol;

	                                // エラーメッセージの表示
	                                App.ui.page.notifyAlert.message(
                                                    pageLangText.invalidation.text + ret[i].Message, unique).show();
	                                // 対象セルの背景変更
	                                grid.setCell(ids[j], grid.getColumnIndexByName("cd_futai"), ret[i].Data.cd_futai, { background: '#ff6666' });
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

	                        if (isNaN(value) || value === retValue) {
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
	                                current.wt_kowake = ret.Updated[i].Current.wt_kowake;
	                                current.cd_tani = ret.Updated[i].Current.cd_tani;
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
	                        value = changeSet.changeSet.deleted[p].cd_futai;
	                        retValue = ret.Deleted[i].Requested.cd_futai;
	                        // TODO: ここまで

	                        if (isNaN(value) || value === retValue) {
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

	            // ローディングの表示
	            App.ui.loading.show(pageLangText.nowSaving.text);

	            // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
	            var saveUrl = "../api/FutaiKetteiMaster";
	            // TODO: ここまで

	            App.ajax.webpost(
                    saveUrl, getPostData()
                ).done(function (result) {
                    // 検索前の状態に初期化
                    clearState();
                    App.ui.page.notifyInfo.message(pageLangText.successMessage.text).show();
                    // データ検索
                    searchItems(new queryWeb());
                }).fail(function (result) {
                    // データ変更エラーハンドリングを行います。
                    handleSaveDataError(result);
                }).always(function () {
                    // ローディングの終了
                    App.ui.loading.close();
                });
	        };

	        /// 検索条件変更チェック
	        var noChangeCriteria = function () {
	            var criteria = $(".search-criteria").toJSON();
	            if (searchCriteriaSetting.kbn_jotai != criteria.kbn_jotai) {
	                return false;
	            }
	            if (searchCriteriaSetting.kbn_hin != criteria.kbn_hin) {
	                return false;
	            }
	            if (searchCriteriaSetting.cd_hinmei != criteria.cd_hinmei) {
	                return false;
	            }
	            return true;
	        };
	        /// <summary>保存前チェック</summary>
	        var checkSave = function () {
	            // メッセージのクリア
	            clearMessage();
	            // 編集内容の保存
	            saveEdit();
	            // 内部エラーになった行の背景色をすべてリセット
	            clearErrBgcorror(errRows);

	            // 変更がない場合は処理を抜ける
	            if (noChange()) {
	                App.ui.page.notifyInfo.message(pageLangText.noChange.text).show();
	                return;
	            }
	            // 検索条件が変更されていないか
	            if (!noChangeCriteria()) {
	                App.ui.page.notifyAlert.message(pageLangText.changeCondition.text).show();
	                return;
	            }
	            // 変更セット内にバリデーションエラーがある場合は処理を抜ける
	            if (!validateChangeSet()) {
	                return;
	            }
	            showSaveConfirmDialog();
	        };
	        /// <summary>保存ボタンクリック時のイベント処理を行います。</summary>
	        $(".save-button").on("click", checkSave); //showSaveConfirmDialog);

	        //// 保存処理 -- End

	        //// バリデーション -- Start

	        // グリッドコントロール固有のバリデーション

	        // TODO: 画面の仕様に応じて以下のカスタムバリデーション定義を変更してください。
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

	        /// <summary>ページ遷移を行います。</summary>
	        var navigate = function (e) {
	            // TODO：画面の仕様に応じて以下の遷移先ページのURLを変更してください。
	            var criteria = $(".search-criteria").toJSON(),
                    url = "/Pages/SearchList.aspx";
	            if (!App.isUndefOrNull(criteria.categoryCode) && criteria.categoryCode.length > 0) {
	                url += "?category=" + criteria.categoryCode;
	            }
	            // TODO: ここまで
	            window.location = url;
	        };
	        /// <summary>配合一覧ボタンクリック時のイベント処理を行います。</summary>
	        $(".searchList-button").on("click", navigate);

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

	        /// メッセージをクリアする
	        var clearMessage = function () {
	            // 情報メッセージのクリア
	            App.ui.page.notifyInfo.clear();
	            // エラーメッセージのクリア
	            App.ui.page.notifyAlert.clear();
	        };

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

	        /// <summary>検索条件表示用コード名の検索を行います。</summary>
	        /// <param name="masterKubun">クエリオブジェクト</param>
	        /// <param name="code">クエリオブジェクト</param>
	        var getConditionCodeName = function (hinKubun, code) {
	            clearMessage();
	            var serviceUrl,
                    elementCode,
                    elementName,
                    codeName;
	            switch (hinKubun) {
	                case pageLangText.genryoHinKbn.text:
	                    // 品名マスタ参照
	                    serviceUrl = "../Services/FoodProcsService.svc/ma_hinmei()?$filter=cd_hinmei eq '" + code + "'"
                                        + " and kbn_hin eq " + parseInt(pageLangText.genryoHinKbn.text)
                                        + " and flg_mishiyo eq " + parseInt(pageLangText.shiyoMishiyoFlg.text) + "&$top=1";
	                    elementCode = "cd_hinmei";
	                    elementName = "nm_hinmei_" + App.ui.page.lang;
	                    break;
	                case pageLangText.shikakariHinKbn.text:
	                    // 配合名マスタ参照
	                    serviceUrl = "../Services/FoodProcsService.svc/ma_haigo_mei()?$filter=cd_haigo eq '" + code + "'"
                                        + " and flg_mishiyo eq " + parseInt(pageLangText.shiyoMishiyoFlg.text)
                                        + " and no_han eq " + parseInt(pageLangText.hanNoShokichi.text)
                                        + "&$top=1";
	                    elementCode = "cd_haigo";
	                    elementName = "nm_haigo_" + App.ui.page.lang;
	                    break;
	                case pageLangText.jikaGenryoHinKbn.text:
	                    // 品名マスタ参照
	                    serviceUrl = "../Services/FoodProcsService.svc/ma_hinmei()?$filter=cd_hinmei eq '" + code + "'"
                                        + " and kbn_hin eq " + parseInt(pageLangText.jikaGenryoHinKbn.text)
                                        + " and flg_mishiyo eq " + parseInt(pageLangText.shiyoMishiyoFlg.text) + "&$top=1";
	                    elementCode = "cd_hinmei";
	                    elementName = "nm_hinmei_" + App.ui.page.lang;
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
	                    $("#condition-nm_hinmei").text(codeName[0][elementName]);
	                }
	                else {
	                    $("#condition-nm_hinmei").text("");
	                    //App.ui.page.notifyAlert.message(App.str.format(MS0049, pageLangText.cd_hinmei.text)).show();
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
	        var getCodeName = function (code, cellName, iRow) {
	            clearMessage();
	            var serviceUrl,
                    elementCode,
                    elementName,
                    codeName;
	            switch (cellName) {
	                case "cd_futai":
	                    serviceUrl = "../Services/FoodProcsService.svc/ma_futai()?$filter=cd_futai eq '" + code
                            + "' and flg_mishiyo eq " + pageLangText.falseFlg.text + "&$top=1";
	                    elementCode = "cd_futai";
	                    elementName = "nm_futai";
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
	                    grid.setCell(iRow, "nm_futai", codeName[0][elementName]);
	                }
	                else {
	                    $("#condition-nm_futai").text("");
	                    App.ui.page.notifyAlert.message(App.str.format(MS0049, pageLangText.cd_futai.text)).show();
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

	        // 検索条件に変更が発生した場合
	        $(".search-criteria").on("change", function () {
	            // 検索後の状態で検索条件が変更された場合
	            if (isSearch) {
	                isCriteriaChange = true;
	            }
	        });

	        /// <summary>検索条件変更時のイベント処理を行います。</summary>
	        $("#condition-cd_hinmei").on("change", function () {
	            var criteria = $(".search-criteria").toJSON();
	            getConditionCodeName(criteria.kbn_hin, criteria.cd_hinmei);
	        });

	        /// <summary>検索条件変更時のイベント処理を行います。</summary>
	        $("#condition-jotai").on("change", function () {
	            // 品名情報クリア
	            $("#condition-cd_hinmei").attr("value", "");
	            $("#condition-kbn_hin").val(pageLangText.genryoHinKbn.text);
	            $("#condition-nm_hinmei").text("");

	            var criteria = $(".search-criteria").toJSON();
	            var kbn = criteria.kbn_jotai;
	            if (kbn === pageLangText.sonotaJotaiKbn.text) {
	                $("#condition-kbn_hin").removeAttr("disabled");
	                $("#condition-cd_hinmei").removeAttr("disabled");
	                $("#hinmei-button").removeAttr("disabled");
	                $("#toroku-button").removeAttr("disabled");
	                //validationSetting.kbn_hin = {
	                //    rules: { required: pageLangText.kbn_hin.text }, messages: { required: MS0042 }
	                //};
	                validationSetting.cd_hinmei = {
	                    rules: { required: pageLangText.cd_hinmei.text, alphanum: true, maxlength: 14 },
	                    params: { custom: pageLangText.cd_hinmei.text },
	                    messages: { required: MS0042, alphanum: MS0439, maxlength: MS0012, custom: MS0049 }
	                };
	                setCustomCdHinmei();
	            }
	            else {
	                $("#condition-kbn_hin").attr("disabled", "disabled");
	                $("#condition-cd_hinmei").attr("disabled", "disabled");
	                $("#hinmei-button").attr("disabled", "disabled");
	                $("#toroku-button").attr("disabled", "disabled");
	                //validationSetting.kbn_hin = {
	                //    rules: {}, messages: {}
	                //};
	                validationSetting.cd_hinmei = {
	                    rules: { alphanum: true, maxlength: 14 },
	                    params: { custom: "品名コード" },
	                    messages: { alphanum: MS0439, maxlength: MS0012, custom: MS0049 }
	                };
	                setCustomCdHinmei();
	            }
	        });

	        var clearData = function () {
	            location.reload();
	        };

	        /// <summary>保存確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
	        $(".save-confirm-dialog .dlg-yes-button").on("click", saveData);

	        // <summary>保存確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
	        $(".save-confirm-dialog .dlg-no-button").on("click", closeSaveConfirmDialog);

	        /// <summary>クリアボタンクリック時のイベント処理を行います。</summary>
	        //$(".clear-button").on("click", showClearConfirmDialog);

	        /// <summary>検索確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
	        $(".search-confirm-dialog .dlg-yes-button").on("click", findData);

	        // <summary>検索確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
	        $(".search-confirm-dialog .dlg-no-button").on("click", closeSearchConfirmDialog);

	        /// <summary>データに変更があり、未保存の状態でページを離れる際に確認を行います。</summary>
	        $(window).on('beforeunload', function () {
	            if (!noChange()) {
	                return pageLangText.unloadWithoutSave.text;
	            }
	        });

	        // TODO ダイアログ情報メッセージの設定
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

	        var isValidCode = function (colName, code) {
	            var isValid = false
                    , _query
                    , url = "";
	            switch (colName) {
	                case "genryo":
	                    _query = {
	                        url: "../Services/FoodProcsService.svc/ma_hinmei",
	                        filter: "cd_hinmei eq '" + code + "' and kbn_hin eq " + pageLangText.genryoHinKbn.text
                                + " and flg_mishiyo eq " + pageLangText.shiyoMishiyoFlg.text,
	                        top: 1
	                    }
	                    break;
	                case "shikakari":
	                    _query = {
	                        url: "../Services/FoodProcsService.svc/ma_haigo_mei",
	                        filter: "cd_haigo eq '" + code + "' and no_han eq " + pageLangText.hanNoShokichi.text
                                + " and flg_mishiyo eq " + pageLangText.shiyoMishiyoFlg.text,
	                        top: 1
	                    }
	                    break;
	                case "jikagenryo":
	                    _query = {
	                        url: "../Services/FoodProcsService.svc/ma_hinmei",
	                        filter: "cd_hinmei eq '" + code + "' and kbn_hin eq " + pageLangText.jikaGenryoHinKbn.text
                                + " and flg_mishiyo eq " + pageLangText.shiyoMishiyoFlg.text,
	                        top: 1
	                    }
	                    break;
	                case "cd_futai":
	                    _query = {
	                        url: "../Services/FoodProcsService.svc/ma_futai",
	                        filter: "cd_futai eq '" + code + "' and flg_mishiyo eq " + pageLangText.shiyoMishiyoFlg.text,
	                        top: 1
	                    }
	                    break;
	                default:
	                    // MS0010：値が無効です
	                    App.ui.page.notifyAlert.message(MS0010).show();
	                    return isValid;
	            }
	            App.ajax.webgetSync(
                    App.data.toODataFormat(_query)
                ).done(function (result) {
                    if (result.d.length > 0) {
                        isValid = true;
                    }
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                });

	            return isValid;
	        };

	        validationSetting.cd_futai.rules.custom = function (value, param) {
	            return isValidCode("cd_futai", value);
	        };

	        /// 品名コードのカスタムバリデーションを設定します
	        var setCustomCdHinmei = function () {
	            validationSetting.cd_hinmei.rules.custom = function (value, param) {
	                var isValid = true;
	                if (!App.isUndefOrNull(value) && value.length > 0) {
	                    var criteria = $(".search-criteria").toJSON();
	                    // 選択された品名区分が『原料』の場合
	                    if (criteria.kbn_hin == pageLangText.genryoHinKbn.text) {
	                        isValid = isValidCode("genryo", value);
	                    }
	                    // 選択された品名区分が『仕掛品』の場合
	                    else if (criteria.kbn_hin == pageLangText.shikakariHinKbn.text) {
	                        isValid = isValidCode("shikakari", value);
	                    }
	                    else if (criteria.kbn_hin == pageLangText.jikaGenryoHinKbn.text) {
	                        isValid = isValidCode("jikagenryo", value);
	                    }
	                }
	                return isValid;
	            };
	        };
	        setCustomCdHinmei();

	        // TODO ここまで

	        /// <summary>風袋一覧画面を開きます。</summary>
	        var showFutaiDialog = function () {
	            var rowid = getSelectedRowId();
	            if (App.isUndefOrNull(rowid)) {
	                return;
	            }

	            // 追加行かつ未使用フラグが立っていない行のみ有効
	            var timeStamp = grid.jqGrid('getCell', rowid, 'ts'),
                    flgMishiyo = grid.jqGrid('getCell', rowid, 'flg_mishiyo');
	            if (timeStamp == "" && flgMishiyo == pageLangText.falseFlg.text) {
	                // フォーカスを隣カラムへ移動させる(※値貼り付け後のバグ対策)
	                $("#" + rowid + " td:eq('" + grid.getColumnIndexByName("flg_mishiyo") + "')").click();
	                if (!checkRecordCount()) {
	                    return;
	                }
	                var option = { id: 'futai', multiselect: false };
	                futaiDialog.draggable(true);
	                futaiDialog.dlg("open", option);
	            }
	            else {
	                App.ui.page.notifyInfo.message(MS0702).show();
	            }
	        };
	        /// <summary>風袋一覧ボタンクリック時のイベント処理を行います。</summary>
	        $(".futai-button").on("click", showFutaiDialog);

	        /// <summary>登録一覧ボタンクリック時のイベント処理を行います。</summary>
	        $("#toroku-button").on("click", function (e) {
	            var rowid = getSelectedRowId(true),
                    criteria = $(".search-criteria").toJSON();
	            var option = { id: 'toroku', multiselect: false, param1: criteria.kbn_hin };
	            torokuDialog.draggable(true);
	            torokuDialog.dlg("open", option);
	        });

	        /// <summary>コード検索ボタンクリック時のイベント処理を行います。</summary>
	        $("#hinmei-button").on("click", function (e) {
	            var hinKubun = $("#condition-kbn_hin").val(),
                    param;
	            switch (hinKubun) {
	                case pageLangText.genryoHinKbn.text:
	                    param = genryoDialogParam;
	                    break;
	                case pageLangText.shikakariHinKbn.text:
	                    param = shikakariDialogParam;
	                    break;
	                case pageLangText.jikaGenryoHinKbn.text:
	                    param = jikaGenryoDlgParam;
	                    break;
	            }
	            var option = { id: 'hinmei', multiselect: false, param1: param };
	            hinmeiDialog.dlg("open", option);
	        });
	        $("#condition-kbn_hin").on("change", function () {
	            $("#condition-cd_hinmei").change();
	        });
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
	                document.location = "./MainMenu.aspx";
	            } catch (e) {
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
	<div class="content-part search-criteria">
		<h3 class="part-header" data-app-text="searchCriteria">
			<a class="search-part-toggle" href="#"></a>
		</h3>
		<div class="part-body">
			<ul class="item-list">
				<!-- TODO: 画面の仕様に応じて以下の検索条件を変更してください。-->
				<li>
					<label>
						<span class="item-label" data-app-text="kbn_jotai"></span>
						<select name="kbn_jotai" id="condition-jotai"></select>
						<span class="item-label" style="width: 30px">&nbsp;</span>
					</label>
					<label>
						<span class="item-label" data-app-text="kbn_hin"></span>
                        <select name="kbn_hin" id="condition-kbn_hin" disabled></select>
					</label>
				</li>
				<li>
					<label>
						<span class="item-label">&nbsp;</span> <span class="item-label" style="width: 154px">
							&nbsp;</span>
					</label>
					<label>
						<span class="item-label pad-apace" data-app-text="cd_hinmei"></span>
						<input type="text" name="cd_hinmei" id="condition-cd_hinmei" style="width: 156px" disabled="disabled" />
					</label>
					<button type="button" class="dialog-button" name="hinmei-button" id="hinmei-button" disabled="disabled">
						<span class="icon"></span><span data-app-text="codeSearch"></span>
					</button>
                    <button type="button" class="dialog-button" name="toroku-button" id="toroku-button" disabled="disabled" data-app-operation="toroku">
                        <span class="icon"></span><span data-app-text="torokuIchiran"></span>
                    </button>
				</li>
				<li>
					<label>
						<span class="item-label">&nbsp;</span> <span class="item-label" style="width: 154px">
							&nbsp;</span>
					</label>
					<label>
						<span class="item-label pad-apace" data-app-text="nm_hinmei"></span><span class="conditionname-label"
							name="nm_hinmei" id="condition-nm_hinmei"></span>
					</label>
				</li>
				<!-- TODO: ここまで -->
			</ul>
		</div>
		<div class="part-footer">
			<div class="command">
				<button type="button" class="find-button" name="find-button" data-app-operation="search">
					<span class="icon"></span><span data-app-text="search"></span>
				</button>
			</div>
		</div>
	</div>
	<!-- 検索結果一覧 -->
	<div class="content-part result-list">
		<!-- グリッドコントロール固有のデザイン -- Start -->
		<h3 id="listHeader" class="part-header">
			<span data-app-text="resultList" style="padding-right: 10px;"></span><span class="list-count"
				id="list-count"></span><span style="padding-left: 50px;" class="list-loading-message"
					id="list-loading-message"></span>
		</h3>
		<div class="part-body" id="result-grid">
			<div class="item-command">
				<button type="button" class="colchange-button" data-app-operation="colchange">
					<span class="icon"></span><span data-app-text="colchange"></span>
				</button>
				<button type="button" class="add-button" name="add-button" data-app-operation="add">
					<span class="icon"></span><span data-app-text="add"></span>
				</button>
				<button type="button" class="delete-button" name="delete-button" data-app-operation="del">
					<span class="icon"></span><span data-app-text="del"></span>
				</button>
				<button type="button" class="futai-button" name="futai-button" data-app-operation="futai">
					<span class="icon"></span><span data-app-text="futaiIchiran"></span>
				</button>
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
			<span class="icon"></span><span data-app-text="save"></span>
		</button>
	</div>
    <div class="command" style="right: 9px;">
        <button type="button" class="menu-button" name="menu-button">
            <span class="icon"></span>
            <span data-app-text="menu"></span>
        </button>
    </div>
	<!-- 画面アーキテクチャ共通のデザイン -- End -->
	<!-- ダイアログ固有のデザイン -- Start -->
	<!-- TODO: 画面の仕様に応じて以下のダイアログの設定を変更してください。 -->
	<div class="save-confirm-dialog" style="display: none;">
		<div class="dialog-header">
			<h4 data-app-text="confirmTitle">
			</h4>
		</div>
		<div class="dialog-body" style="padding: 10px; width: 100%;">
			<div class="part-body">
				<span data-app-text="saveConfirm"></span>
			</div>
		</div>
		<div class="dialog-footer">
			<div class="command" style="position: absolute; left: 10px; top: 5px">
				<button class="dlg-yes-button" name="dlg-yes-button" data-app-text="yes">
				</button>
			</div>
			<div class="command" style="position: absolute; right: 5px; top: 5px;">
				<button class="dlg-no-button" name="dlg-no-button" data-app-text="no">
				</button>
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
	<!-- TODO: ここまで  -->
	<!-- 画面デザイン -- End -->
</asp:Content>
<asp:Content ID="Content5" ContentPlaceHolderID="DialogsContent" runat="server">
	<!-- 画面デザイン -- Start -->
	<!-- TODO: 画面の仕様に応じて以下のダイアログの設定を変更してください。 -->
	<div class="futai-dialog">
	</div>
	<div class="hinmei-dialog">
	</div>
	<div class="toroku-dialog">
	</div>
	<!-- TODO: ここまで  -->
	<!-- 画面デザイン -- End -->
</asp:Content>
