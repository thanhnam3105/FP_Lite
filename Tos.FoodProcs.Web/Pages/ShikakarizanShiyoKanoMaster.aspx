<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="ShikakarizanShiyoKanoMaster.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.ShikakarizanShiyoKanoMaster" %>

<asp:Content ID="Content1" ContentPlaceHolderID="IncludeContent" runat="server">
    <script src="<%=ResolveUrl("~/Resources/pages/pagedata-shikakarizanshiyokanomaster." + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
    <script src="<%=ResolveUrl("~/Resources/grid/grid.locale-" + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        /* 画面デザイン -- Start */
        
        /* TODO：画面の仕様に応じて以下のスタイルを変更してください。 */
        .search-criteria .conditionname-label
        {
            width: 15em;
        }

        button.hinmei-button
        {
            width: 110px;
        }
		
		button.hinmei-button .icon
		{
			background-position: -48px -80px;
		}
        
        .search-criteria .item-label {
            width: 9em;
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
                validationSetting2 = App.ui.pagedata.validation2(App.ui.page.lang),
                querySetting = { skip: 0, top: pageLangText.topCount.text, count: 0 },
                isDataLoading = false,
                isSearch = false, // 検索フラグ
                isCriteriaChange = false, // 検索条件変更フラグ
                userRoles = App.ui.page.user.Roles[0]; // ログインユーザー権限

            // グリッドコントロール固有の変数宣言
            var grid = $("#item-grid"),
                lastScrollTop = 0,
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
                changeSet = new App.ui.page.changeSet(),
                firstCol = 1,
                duplicateCol = 999,
                currentRow = 0,
                currentCol = firstCol,
                isClickSearch = false;
            // TODO: ここまで

            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            // 多言語対応にしたい項目を変数にする
            var hinName = "nm_hinmei_" + App.ui.page.lang;

            // TODO：ここまで

            // ダイアログ固有の変数宣言
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            var saveConfirmDialog = $(".save-confirm-dialog"),
                deleteConfirmDialog = $(".delete-confirm-dialog"),
                findConfirmDialog = $(".find-confirm-dialog"),
                hinmeiDialog = $(".hinmei-dialog"),
                shikakarizanDialog = $(".jikagenryo-dialog");
            // TODO：ここまで

            // urlよりパラメーターを取得
            var getParameters = function () {
                var parameters = {},
                    keyValue,
                    parameterStartPos = window.location.href.indexOf('?') + 1,
                    queryStrings;

                queryStrings = window.location.href.slice(parameterStartPos).split('&');

                if (!App.isUnusable(queryStrings)) {
                    for (var i = 0; i < queryStrings.length; i++) {
                        keyValue = queryStrings[i].split('=');
                        parameters[keyValue[0]] = keyValue[1];
                    }
                }
                return parameters;
            };
            // urlよりパラメーターを取得
            var parameters = getParameters();

            // ユーザー権限による操作制御定義を定義します。
            App.ui.pagedata.operation.applySetting(App.ui.page.user.Roles[0], App.ui.page.lang);
            $(function () {
                if (userRoles == pageLangText.viewer.text) {
                    // TODO：画面の仕様に応じて以下の処理を変更してください。
                    $(".add-button").css("display", "none");
                    $(".delete-button").css("display", "none");
                    $(".save-button").css("display", "none");
                    // TODO：ここまで
                }
            });

            //// 変数宣言 -- End

            //// コントロール定義 -- Start

            // ダイアログ固有のコントロール定義
            saveConfirmDialog.dlg();
            deleteConfirmDialog.dlg();
            findConfirmDialog.dlg();

            // 品名ダイアログ定義
            hinmeiDialog.dlg({
                url: "Dialog/HinmeiDialog.aspx",
                name: "HinmeiDialog",
                closed: function (e, data, data2) {
                    // エラーメッセージのクリア
                    App.ui.page.notifyAlert.clear();
                    if (data == "canceled") {
                        return;
                    }
                    else {
                        var selectedRowId = getSelectedRowId(false);
                        grid.setCell(selectedRowId, "cd_seihin", data);
                        grid.setCell(selectedRowId, hinName, data2);

                        // 更新状態の変更セットに変更データを追加
                        var changeData = setCreatedChangeData(grid.getRowData(selectedRowId));
                        changeSet.addUpdated(selectedRowId, "cd_seihin", data, changeData);
                        // データチェック
                        validateCell(selectedRowId, "cd_seihin", data, grid.getColumnIndexByName("cd_seihin"));
                        setRelatedValue(getSelectedRowId(false), "cd_seihin", data, grid.getColumnIndexByName("cd_seihin"));
                    }
                }
            });
            // 仕掛残ダイアログ定義
            shikakarizanDialog.dlg({
                url: "Dialog/HinmeiDialog.aspx",
                name: "HinmeiDialog",
                closed: function (e, data, data2) {
                    // エラーメッセージのクリア
                    App.ui.page.notifyAlert.clear();
                    if (data == "canceled") {
                        return;
                    }
                    else {
                        $("#cd_shikakari_zan").val(data);
                        $("#nm_shikakari_zan").text(data2);

                        // 品名コード変更処理
                        loading(pageLangText.nowProgressing.text, "cd_shikakari_zan");
                    }
                }
            });

            /// <summary>ダイアログを開きます。</summary>
            var showSaveConfirmDialog = function () {
                saveConfirmDialog.draggable(true);
                saveConfirmDialog.dlg("open");
            };
            var showDeleteConfirmDialog = function () {
                deleteConfirmDialog.draggable(true);
                deleteConfirmDialog.dlg("open");
            };
            /// <summary> 検索確認ダイアログを開きます。 </summary>
            var showFindConfirmDialog = function () {
                findConfirmDialog.draggable(true);
                findConfirmDialog.dlg("open");
            };
            /// <summary>ダイアログを閉じます。</summary>
            var closeSaveConfirmDialog = function () {
                saveConfirmDialog.dlg("close");
            };
            var closeDeleteConfirmDialog = function () {
                deleteConfirmDialog.dlg("close");
            };
            /// <summary> 検索確認ダイアログを閉じます。 </summary>
            var closeFindConfirmDialog = function () {
                findConfirmDialog.dlg("close");
            };

            // グリッドコントロール固有のコントロール定義
            var selectCol;
            grid.jqGrid({
                // TODO：画面の仕様に応じて以下の列名の定義を変更してください。
                colNames: [
                    pageLangText.no_juni_hyoji.text
                    , pageLangText.cd_seihin.text
                    , pageLangText.nm_seihin.text
                    , pageLangText.nm_nisugata_hyoji.text
                    , pageLangText.flg_mishiyo.text
                    , ""
                    , ""
                    , ""
                    , ""
                    , ""
                    , ""
                ],
                // TODO：ここまで
                // TODO：画面の仕様に応じて以下の列モデルの定義を変更してください。
                colModel: [
                    {
                        name: 'no_juni_hyoji', width: 75, editable: true, align: 'center',
                        formatter: 'integer',
                        formatoptions: { defaultValue: "" }
                    },
                    { name: 'cd_seihin', width: 150, sortable: false, editable: true },
                    { name: hinName, width: 350, sortable: false, editable: false },
                    { name: 'nm_nisugata_hyoji', width: 150, sortable: false, editable: false },
                    { name: 'flg_mishiyo_shikakarizan', hidden: false, hidedlg: false, width: 70, edittype: 'checkbox',
                        align: 'center', editoptions: { value: "1:0" }, formatter: 'checkbox',
                        formatoptions: { disabled: false }, classes: 'not-editable-cell'
                    },
                    { name: 'cd_hinmei', width: 0, hidden: true, hidedlg: true },
                    { name: 'cd_create', width: 0, hidden: true, hidedlg: true },
                    { name: 'dt_create', width: 0, hidden: true, hidedlg: true },
                    { name: 'cd_update', width: 0, hidden: true, hidedlg: true },
                    { name: 'dt_update', width: 0, hidden: true, hidedlg: true },
                    { name: 'ts', width: 0, hidden: true, hidedlg: true },
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
                cellsubmit: 'clientArray',
                hoverrows: false,
                loadonce: true,
                onSortCol: function () {
                    grid.setGridParam({ rowNum: grid.getGridParam("records") });
                },
                loadComplete: function () {
                    var ids = grid.jqGrid('getDataIDs');
                    for (var i = 0; i < ids.length; i++) {
                        var id = ids[i];
                        // TODO：画面の仕様に応じて以下の操作可否の定義を変更してください。
                        if (grid.getCell(id, 'ts') !== "") {
                            grid.setCell(id, 'no_juni_hyoji', '', 'not-editable-cell');
                        }
                        // TODO：ここまで
                    }
                    // グリッドの先頭行選択
                    var idNum = grid.getGridParam("selrow");
                    if (idNum == null) {
                        $("#1 > td").click();
                    }
                    else {
                        $("#" + idNum).removeClass("ui-state-highlight").find("td").click();
                    }

                    //// 画面IDおよびテーブル区分を設定
                    //grid.setGridParam({
                    //    screenID: pageLangText.shikakarizanShiyoKanoMasterGamenKbn.text,
                    //    kbn_table: 1
                    //});
                    //// 列変更データを表示
                    //grid.initDisplayColumns();
                },
                beforeEditCell: function (selectedRowId, cellName, value, iRow, iCol) {
                    currentRow = iRow;
                    currentCol = iCol;
                },
                afterEditCell: function (selectedRowId, cellName, value, iRow, iCol) {
                    // Enter キーでカーソルを移動
                    grid.moveCell(cellName, iRow, iCol);
                    selectCol = iCol;
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
                },
                onCellSelect: function (rowid, icol, cellcontent) {
                    // セルクリック時の列番号を保持
                    // afterEditCellでTab(Enter)Key移動先の列番号を保持
                    selectCol = icol;
                },
                ondblClickRow: function (rowid) {
                    var hinCodeCol = grid.getColumnIndexByName("cd_seihin"),
                        hinNameCol = grid.getColumnIndexByName(hinName);

                    // ダブルクリックした列が品コードか品名なら一覧ダイアログを開きます。
                    if (selectCol === hinCodeCol || selectCol === hinNameCol) {
                        // 一覧セレクタ起動前チェック
                        checkHinmeiDialog();
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

                saveEdit();
                // 更新状態の変更データの設定
                var changeData = setUpdatedChangeData(grid.getRowData(selectedRowId));

                // TODO：画面の仕様に応じて以下の定義を変更してください。
                value = changeData["flg_mishiyo"];
                // TODO：ここまで

                // 更新状態の変更セットに変更データを追加
                changeSet.addUpdated(selectedRowId, "flg_mishiyo", value, changeData);

            });

            /// <summary>セルの関連項目を設定します。</summary>
            /// <param name="selectedRowId">選択行ID</param>
            /// <param name="cellName">列名</param>
            /// <param name="value">元となる項目の値</param>
            /// <param name="iCol">項目の列番号</param>
            var setRelatedValue = function (selectedRowId, cellName, value, iCol) {
                // TODO：画面の仕様に応じて以下の関連項目を設定を変更してください。
                if (cellName === "cd_seihin") {
                    // コードから製品情報を取得します。
                    getCodeName(value, selectedRowId);
                }
                // TODO：ここまで
            };

            /// <summary>非表示列設定ダイアログの表示を行います。</summary>
            /// <param name="e">イベントデータ</param>
            var showColumnSettingDialog = function (e) {
                var dlgHeight = (grid.getGridParam("height") - 30 < 230 ? (grid.getGridParam("height") - 30) : 230);
                var dataHeight = dlgHeight - 50;
                var params = {
                    width: 300,
                    heitht: dlgHeight,
                    dataheight: dataHeight,
                    modal: true,
                    drag: false,
                    recreateForm: true,
                    caption: pageLangText.colchange.text,
                    bCancel: pageLangText.cancel.text,
                    bSubmit: pageLangText.save.text,
                    //// 列変更機能：登録処理
                    //afterSubmitForm: grid.saveColumnData
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

            //// 事前データロード -- End

            //// 検索処理 -- Start

            // 画面アーキテクチャ共通の検索処理

            /// <summary>クエリオブジェクトの設定</summary>
            var query = function () {
                // TODO：画面の仕様に応じて以下のクエリの定義を変更してください。
                var query = {
                    url: "../Services/FoodProcsService.svc/vw_ma_shikakari_zan_shiyo_01",
                    filter: createFilter(),
                    orderby: "no_juni_hyoji",
                    skip: querySetting.skip,
                    top: querySetting.top,
                    inlinecount: "allpages"
                }
                // TODO：ここまで。
                return query;
            };

            /// <summary>フィルター条件の設定</summary>
            var createFilter = function () {
                var criteria = $(".search-criteria").toJSON(),
                    filters = [],
                    shiyoFlag = pageLangText.shiyoMishiyoFlg.text;
                // TODO：画面の仕様に応じて以下のフィルター条件を変更してください。
                filters.push(App.str.format("cd_hinmei eq '{0}'", criteria.cd_shikakari_zan));
                // TODO：ここまで。
                return filters.join(" and ");
            };
            /// <summary>データ検索を行います。</summary>
            /// <param name="query">クエリオブジェクト</param>
            var searchItems = function (query) {
                closeFindConfirmDialog();
                if (isDataLoading === true) {
                    return;
                }
                isDataLoading = true;
                App.ajax.webget(
                // WCF Data ServicesのODataシステムクエリオプションを生成
                    App.data.toODataFormat(query)
                ).done(function (result) {
                    // 検索フラグを立てる
                    isSearch = true;
                    // データバインド
                    bindData(result);

                    var criteria = $(".search-criteria").toJSON();
                    if (result.d.results.length > 0) {
                        // 検索条件を閉じる
                        closeCriteria();
                        isCriteriaChange = false;
                    }

                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                    App.ui.loading.close();
                }).always(function () {
                    // ローディングの終了
                    App.ui.loading.close();
                    isDataLoading = false;
                });
            };

            // 仕掛残コード変更時の処理
            var changeShikakarizanCode = function () {
                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();

                var code = $("#cd_shikakari_zan").val();
                getCodeName(code, undefined);
            };

            /// <summary>検索条件を閉じます。</summary>
            var closeCriteria = function () {
                var criteria = $(".search-criteria");
                if (!criteria.find(".part-body").is(":hidden")) {
                    criteria.find(".search-part-toggle").click();
                }
            };

            /// <summary>検索条件を開きます。</summary>
            var openCriteria = function () {
                var criteria = $(".search-criteria");
                if (criteria.find(".part-body").is(":hidden")) {
                    criteria.find(".search-part-toggle").click();
                }
            };

            // 検索前処理
            var checkSearch = function () {
                closeFindConfirmDialog();
                isClickSearch = true;
                var result = $(".part-body .item-list").validation().validate();
                if (result.errors.length) {
                    // ローディングの終了
                    App.ui.loading.close();
                    return;
                }

                if (!isCriteriaChange && !noChange()) {
                    showFindConfirmDialog();
                }
                else {
                    clearState();
                    // 検索前バリデーション
                    searchItems(new query());
                }
            };

            /// <summary>検索ボタンクリック時のイベント処理を行います。</summary>
            $(".find-button").on("click", function () {
                loading(pageLangText.nowProgressing.text, "find-button");
            });

            /// <summary>製品情報のクリア処理</summary>
            var clearShikakarizanInfo = function () {
                $("#nm_shikakari_zan").text("");
            };

            /// <summary>品名マスタ仕掛残情報を検索条件にセットします。</summary>
            /// <param name="shikakarizanInfo">品名マスタ仕掛残情報</param>
            var setSeihinInfo = function (hinInfo, rowId) {
                if (App.isUndef(hinInfo)) {
                    // 取得できない場合
                    grid.setCell(rowId, "cd_seihin", null);
                    grid.setCell(rowId, hinName, null);
                    grid.setCell(rowId, "nm_nisugata_hyoji", null);
                }
                else {
                    grid.setCell(rowId, "cd_seihin", hinInfo["cd_hinmei"]);
                    grid.setCell(rowId, hinName, hinInfo[hinName]);
                    grid.setCell(rowId, "nm_nisugata_hyoji", hinInfo["nm_nisugata"]);
                }
            }

            /// <summary>品名マスタ仕掛残情報を検索条件にセットします。</summary>
            /// <param name="shikakarizanInfo">品名マスタ仕掛残情報</param>
            var setShikakarizanInfo = function (shikakarizanInfo) {
                if (App.isUndef(shikakarizanInfo)) {
                    // 取得できない場合
                    App.ui.page.notifyAlert.message(App.str.format(MS0049, pageLangText.cd_shikakari_zan.text), $("#cd_shikakari_zan")).show();
                    clearShikakarizanInfo();
                }
                else {
                    var name = shikakarizanInfo[hinName]; //返却値がnm_hinmei_ja, nm_hinmei_enの形
                    $("#cd_shikakari_zan").val(shikakarizanInfo.cd_hinmei);
                    $("#nm_shikakari_zan").text(App.ifUndefOrNull(name, ""));
                }
            }

            /// <summary>製品情報取得用のサービスURLを取得します。</summary>
            /// <param name="seihinCode">製品コード</param>
            var getSeihinServiceUrl = function (seihinCode) {
                var serviceUrl = "../Services/FoodProcsService.svc/vw_ma_hinmei_04()?$filter="
                                    + "cd_hinmei eq '" + seihinCode + "'"
                                    + " and (kbn_hin eq " + pageLangText.seihinHinKbn.text + " or kbn_hin eq  " + pageLangText.jikaGenryoHinKbn.text + ")"
                                    + " and flg_mishiyo_hin eq " + pageLangText.falseFlg.text
                                    + " and flg_mishiyo_tani eq " + pageLangText.falseFlg.text
                                    + "&$top=1"
                return serviceUrl;
            };

            /// <summary>仕掛残情報取得用のサービスURLを取得します。</summary>
            /// <param name="shikakarizanCode">仕掛残コード</param>
            var getShikakarizanServiceUrl = function (shikakarizanCode) {
                var serviceUrl = "../Services/FoodProcsService.svc/ma_hinmei()?$filter="
                                    + "cd_hinmei eq '" + shikakarizanCode + "'"
                                    + " and flg_mishiyo eq " + pageLangText.shiyoMishiyoFlg.text
                                    + " and kbn_hin eq " + pageLangText.jikaGenryoHinKbn.text
                                    + "&$top=1"
                return serviceUrl;
            };

            /// <summary>コードより、品情報を取得して設定します。</summary>
            /// <summary>検索条件と明細から呼び出されます。</summary>
            /// <param name="code">製品コード</param>
            /// <param name="rowId">明細からの場合は行ID。検索条件からはundefined</param>
            var getCodeName = function (code, rowId) {
                // 仕掛残コードが空文字の場合は処理中止
                if (code == "") {
                    return;
                }
                App.ui.loading.show(pageLangText.nowProgressing.text);
                var serviceUrl, isSeihin;

                // 行IDがある場合は明細からの呼び出しと判断します。
                isSeihin = !App.isUndef(rowId);

                // 呼び出しによってサービスを変更します。
                serviceUrl = isSeihin ? getSeihinServiceUrl(code) : getShikakarizanServiceUrl(code);

                App.deferred.parallel({
                    hinMaster: App.ajax.webget(serviceUrl)
                }).done(function (result) {
                    // サービス呼び出し成功時
                    var hinMaster = result.successes.hinMaster.d[0];

                    // 取得データを対象にセットします。
                    isSeihin ? setSeihinInfo(hinMaster, rowId) : setShikakarizanInfo(hinMaster);
                    App.ui.loading.close();

                }).fail(function (result) {
                    var length = result.key.fails.length,
                            messages = [];
                    for (var i = 0; i < length; i++) {
                        var keyName = result.key.fails[i];
                        var value = result.fails[keyName];
                        messages.push(keyName + " " + value.message);
                    }
                    App.ui.page.notifyAlert.message(messages).show();
                    App.ui.loading.close();
                }).always(function () {
                    // ローディングの終了
                    App.ui.loading.close();
                });
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
                else if (querySetting.count > querySetting.top) {
                    App.ui.page.notifyInfo.message(
                    App.str.format(MS0624, querySetting.count, querySetting.top)).show();
                    querySetting.count = querySetting.top;
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
                grid.editCell(iRow, info.iCol, true);
            };

            /// <summary>エラー一覧クリック時のイベント処理を行います。</summary>
            $(App.ui.page.notifyAlert).on("itemselected", function (e, data) {
                // エラー一覧クリック時の処理
                handleNotifyAlert(data);
            });

            // ダイアログ固有のメッセージ表示

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
                var criteria = $(".search-criteria").toJSON();
                var resultList = $(".result-list").toJSON();

                // TODO: 画面の仕様に応じて以下の新規データを変更してください。
                var addData = {
                    "cd_hinmei": criteria.cd_shikakari_zan,
                    "no_juni_hyoji": null,
                    "cd_seihin": null,
                    "flg_mishiyo_shikakarizan": pageLangText.shiyoMishiyoFlg.text,
                    "dt_create": null,
                    "cd_create": App.ui.page.user.Code,
                    "dt_update": null,
                    "cd_update": App.ui.page.user.Code,
                    "ts": null
                };
                // TODO: ここまで。
                return addData;
            };

            /// <summary>追加状態の変更セットに追加する変更データの設定を行います。</summary>
            /// <param name="newRow">新規行データ</param>
            var setCreatedChangeData = function (newRow) {
                // TODO: 画面の仕様に応じて以下のセットデータを変更してください。
                var changeData = {
                    "cd_hinmei": newRow.cd_hinmei,
                    "no_juni_hyoji": newRow.no_juni_hyoji,
                    "cd_seihin": newRow.cd_seihin,
                    "flg_mishiyo": newRow.flg_mishiyo_shikakarizan,
                    "dt_create": null,
                    "cd_create": App.ui.page.user.Code,
                    "dt_update": null,
                    "cd_update": App.ui.page.user.Code,
                    "ts": newRow.ts
                };
                // TODO: ここまで。
                return changeData;
            };
            /// <summary>更新状態の変更セットに追加する変更データの設定を行います。</summary>
            /// <param name="row">選択行</param>
            var setUpdatedChangeData = function (row) {
                // TODO: 画面の仕様に応じて以下のセットデータを変更してください。
                var changeData = {
                    "cd_hinmei": row.cd_hinmei,
                    "no_juni_hyoji": row.no_juni_hyoji,
                    "cd_seihin": row.cd_seihin,
                    "flg_mishiyo": row.flg_mishiyo_shikakarizan,
                    "dt_create": row.dt_create,
                    "cd_create": row.cd_create,
                    "dt_update": null,
                    "cd_update": App.ui.page.user.Code,
                    "ts": row.ts
                };
                // TODO: ここまで。
                return changeData;
            };
            /// <summary>削除状態の変更セットに追加する変更データの設定を行います。</summary>
            /// <param name="row">選択行</param>
            var setDeletedChangeData = function (row) {
                // TODO: 画面の仕様に応じて以下のセットデータを変更してください。
                var changeData = {
                    "cd_hinmei": row.cd_hinmei,
                    "no_juni_hyoji": row.no_juni_hyoji,
                    "cd_seihin": row.cd_seihin,
                    "ts": row.ts
                };
                // TODO: ここまで。
                return changeData;
            };

            /// <summary>新規行を追加します。</summary>
            /// <param name="e">イベントデータ</param>
            var addData = function (e) {
                App.ui.page.notifyAlert.clear();
                if (grid.getGridParam("records") >= pageLangText.topCount.text) {
                    App.ui.page.notifyAlert.message(MS0052).show();
                    return;
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
                    App.ui.page.notifyAlert.message(MS0299).show();
                    return;
                }
                addData();
            });

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
                // 削除データを更新セットに追加
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
                // 検索済であるかチェック
                if (!isSearch) {
                    App.ui.page.notifyInfo.message(MS0621).show();
                    return;
                }

                // 検索条件変更チェック
                if (isCriteriaChange) {
                    App.ui.page.notifyAlert.message(MS0299).show();
                    return;
                }

                // 明細行が0件の場合、削除処理を中止する
                if (grid.getGridParam("records") == 0) {
                    App.ui.page.notifyAlert.message(MS0442).show();
                    return;
                }

                deleteData();
            });

            //// データ変更処理 -- End

            //// 保存処理 -- Start

            // グリッドコントロール固有の保存処理

            // <summary>データに変更がないかどうかを返します。</summary>
            var noChange = function () {
                if (!App.isUnusable(changeSet)) {
                    return changeSet.noChange();
                }
                return true;
            };
            /// <summary>編集内容の保存</summary>
            var saveEdit = function () {
                grid.saveCell(currentRow, currentCol);
            };
            /// <summary>更新データを取得します。</summary>
            var getPostData = function () {
                var ChangeSet = changeSet.getChangeSetData();
                return JSON.stringify(ChangeSet);
            };
            /// <summary>データ変更エラーハンドリングを行います。</summary>
            /// <param name="result">エラーの戻り値</param>
            var handleSaveDataError = function (result) {
                var ret = JSON.parse(result.rawText);
                if (App.isUndefOrNull(ret)) {
                    App.ui.page.notifyAlert.message(result.message).show();
                    return;
                }
                var ids = grid.getDataIDs(),
                    newId,
                    value1,
                    value2,
                    retValue1,
                    retValue2,
                    unique,
                    current,
                    isShown = false,
                // TODO: 画面の仕様に応じて以下の変数を変更します。
                    checkCol1 = grid.getColumnIndexByName("cd_hinmei"),
                    checkCol2 = grid.getColumnIndexByName("no_juni_hyoji"),
                    checkCol3 = grid.getColumnIndexByName("cd_seihin"),
                    checkCol4 = grid.getColumnIndexByName("ts");
                // TODO: ここまで
                // 【明細】データ整合性エラーのハンドリングを行います。
                if (App.isArray(ret) && ret.length > 0) {
                    for (var i = 0; i < ret.length; i++) {
                        var vName = ret[i].InvalidationName.toString().split("_"),
                            isSkiped = false;
                        retValue1 = ret[i].Data.cd_hinmei;
                        retValue2 = ret[i].Data.no_juni_hyoji + "";


                        // TODO: 画面の仕様に応じて以下の値を変更します。
                        if (ret[i].InvalidationName === "Exists" || ret[i].InvalidationName === "NotExists" || vName[0] === "DuplicateKey") {
                            // TODO: ここまで
                            for (var j = 0; j < ids.length; j++) {
                                var checkCol = checkCol2;
                                value1 = grid.getCell(ids[j], checkCol1);
                                value2 = grid.getCell(ids[j], checkCol2);
                                if (value1 === retValue1 && value2 === retValue2) {

                                    // Existsの場合は製品コードまでチェックします
                                    if(ret[i].InvalidationName === "Exists"){
                                        var retValue4 = ret[i].Data.ts || "",
                                            value4 = grid.getCell(ids[j], checkCol4);
                                        if(retValue4 !== value4){
                                            continue;
                                        }
                                    }

                                    unique = ids[j] + "_" + checkCol2;
                                    if (!App.isUndef(vName[1]) && vName[1] === "2") {
                                        unique = ids[j] + "_" + checkCol3;
                                        checkCol = checkCol3;
                                    }
                                    App.ui.page.notifyAlert.message(pageLangText.invalidation.text + ret[i].Message, unique).show();
                                    isShown = true;
                                    // 対象セルの背景変更
                                    grid.setCell(ids[j], checkCol, '', { background: '#ff6666' });
                                    break;
                                }
                            }
                            // 存在チェック
                            if (ret[i].Message != null && !isShown) {
                                App.ui.page.notifyAlert.message(pageLangText.invalidation.text + ret[i].Message, unique).show();
                                isShown = true;
                                break;
                            }
                        }
                        // その他チェック
                        if (ret[0].Message != null && !isShown) {
                            App.ui.page.notifyAlert.message(pageLangText.invalidation.text + ret[0].Message).show();
                            isShown = true;
                            break;
                        }
                    }
                }
                // 【明細】更新時同時実行制御エラーのハンドリングを行います。
                if (!App.isUndefOrNull(ret.Updated) && ret.Updated.length > 0) {
                    for (var i = 0; i < ret.Updated.length; i++) {
                        for (p in changeSet.changeSet.updated) {
                            if (!changeSet.changeSet.updated.hasOwnProperty(p)) {
                                continue;
                            }
                            // TODO: 画面の仕様に応じて以下の値を変更します。
                            value1 = grid.getCell(p, checkCol1);
                            value2 = grid.getCell(p, checkCol2);
                            retValue1 = ret.Updated[i].Requested.cd_hinmei;
                            retValue2 = ret.Updated[i].Requested.no_juni_hyoji + "";
                            // TODO: ここまで
                            if (isNaN(value1) || (value1 === retValue1 && value2 === retValue2)) {
                                // 更新状態の変更セットから変更データを削除
                                changeSet.removeUpdated(p);

                                // 他のユーザーによって削除されていた場合
                                if (App.isUndefOrNull(ret.Updated[i].Current)) {
                                    // 対象行の削除
                                    grid.delRowData(p);
                                    // メッセージの表示
                                    App.ui.page.notifyAlert.message(pageLangText.duplicate.text + pageLangText.deletedDuplicate.text).show();
                                }
                                else {
                                    unique = p + "_" + duplicateCol;
                                    // TODO: 画面の仕様に応じて以下の値を変更します。
                                    current = grid.getRowData(p);
                                    $.extend(current, ret.Updated[i].Current);
                                    // TODO: ここまで

                                    // 対象行の更新
                                    grid.setRowData(p, current);
                                    // エラーメッセージの表示
                                    App.ui.page.notifyAlert.message(pageLangText.duplicate.text + pageLangText.updatedDuplicate.text, unique).show();
                                }
                                isShown = true;
                                break;
                            }
                        }
                    }
                }
                // 【明細】削除時同時実行制御エラーのハンドリングを行います。
                if (!App.isUndefOrNull(ret.Deleted) && ret.Deleted.length > 0) {
                    for (var i = 0; i < ret.Deleted.length; i++) {
                        for (p in changeSet.changeSet.deleted) {
                            if (!changeSet.changeSet.deleted.hasOwnProperty(p)) {
                                continue;
                            }
                            // TODO: 画面の仕様に応じて以下の値を変更します。
                            if (!App.isUndefOrNull(changeSet.changeSet.deleted[p].cd_shikakari_zan)) {
                                value1 = changeSet.changeSet.deleted[p].cd_hinmei;
                                value2 = changeSet.changeSet.deleted[p].no_juni_hyoji + "";
                                retValue1 = ret.Deleted[i].Requested.cd_hinmei;
                                retValue2 = ret.Deleted[i].Requested.no_juni_hyoji + "";
                                if (isNaN(value1) || (value1 === retValue1 && value2 === retValue2)) {
                                    // 削除状態の変更セットから変更データを削除
                                    changeSet.removeDeleted(p);

                                    // 他のユーザーによって削除されていた場合
                                    if (App.isUndefOrNull(ret.Deleted[i].Current)) {
                                        // メッセージの表示
                                        App.ui.page.notifyAlert.message(pageLangText.duplicate.text + pageLangText.deletedDuplicate.text).show();
                                    }
                                    else {
                                        // メッセージの表示
                                        App.ui.page.notifyAlert.message(pageLangText.duplicate.text + pageLangText.unDeletedDuplicate.text).show();
                                        confFlg = true;
                                    }
                                    isShown = true;
                                    break;
                                }
                            }
                            // TODO: ここまで
                        }
                    }
                }
            };

            /// <summary>変更を保存します。</summary>
            /// <param name="e">イベントデータ</param>
            var saveData = function (e) {
                closeSaveConfirmDialog();
                confFlg = false;
                // ローディングの表示
                App.ui.loading.show(pageLangText.nowSaving.text);

                // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                var saveUrl = "../api/ShikakarizanShiyoKanoMaster";
                // TODO: ここまで

                App.ajax.webpost(
                    saveUrl, getPostData()
                ).done(function (result) {
                    // 検索前の状態に戻す
                    clearState();

                    // データ検索
                    searchItems(new query());
                    App.ui.page.notifyInfo.message(pageLangText.successMessage.text).show();

                    isCreated = false;
                }).fail(function (result) {
                    // データ変更エラーハンドリングを行います。
                    handleSaveDataError(result);
                    App.ui.loading.close();
                }).always(function () {
                    // ローディングの終了
                    App.ui.loading.close();
                });
            };

            /// <summary>保存前チェック</summary>
            var checkSave = function () {
                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();
                // 編集内容の保存
                saveEdit();

                var result = $(".part-body .item-list").validation().validate();
                if (result.errors.length) {
                    App.ui.loading.close(); // ローディングの終了
                    return false;
                }

                // 変更セット内にバリデーションエラーがある場合は処理を抜ける
                if (!validateChangeSet()) {
                    App.ui.loading.close(); // ローディングの終了
                    return;
                }
                // 変更がない場合は処理を抜ける
                if (noChange()) {// && grid.getGridParam("records") <= 0) {
                    App.ui.page.notifyInfo.message(pageLangText.noChange.text).show();
                    App.ui.loading.close(); // ローディングの終了
                    return;
                }

                // チェックがすべて終わってからローディング表示を終了させる
                App.ui.loading.close();
                // 保存確認ダイアログを表示する
                showSaveConfirmDialog();
            };

            /// <summary>保存ボタンクリック時のイベント処理を行います。</summary>
            $(".save-button").on("click", function () {
                // 検索済であるかチェック
                if (!isSearch) {
                    App.ui.page.notifyInfo.message(MS0621).show();
                    return;
                }
                // 検索条件変更チェック
                if (isCriteriaChange) {
                    App.ui.page.notifyAlert.message(MS0299).show();
                    return;
                }
                loading(pageLangText.nowProgressing.text, "save-button");
            });

            //// 保存処理 -- End

            //// バリデーション -- Start

            // グリッドコントロール固有のバリデーション

            // TODO: 画面の仕様に応じて以下のカスタムバリデーション定義を変更してください。

            /// <summary>品名コード入力チェック</summary>
            /// <param name="hinmeiCode">コード</param>
            var isValidHinmeiCode = function (hinmeiCode) {
                var isValid = true;

                var serviceUrl = getSeihinServiceUrl(hinmeiCode);
                App.ajax.webgetSync(
                    serviceUrl
                ).done(function (result) {
                    // 存在チェック
                    if (result.d.length == 0) {
                        // 検索結果件数が0件の場合
                        // 品名マスタ存在チェックエラー
                        isValid = false;
                    }
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                });
                return isValid;
            };

            // 検索条件仕掛残コード：カスタムバリデーション
            validationSetting.cd_shikakari_zan.rules.custom = function (value) {
                validationSetting.cd_shikakari_zan.messages.custom =
                        App.str.format(MS0049, pageLangText.cd_shikakari_zan.text);
                var val = $("#nm_shikakari_zan").text(),
                    isCheck = isClickSearch;
                isClickSearch = false;
                return !(isCheck && val === "");
            };
            // 明細品名コード：カスタムバリデーション
            validationSetting.cd_seihin.rules.custom = function (value) {
                validationSetting.cd_seihin.messages.custom =
                        App.str.format(MS0049, pageLangText.cd_seihin.text);
                return isValidHinmeiCode(value);
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

            /// <summary>品一覧セレクタを起動する</summary>
            var showShikakarizanDialog = function () {
                // TODO: 画面の仕様に応じて以下のパラメータを変更してください。
                var option = {
                    id: "jikagen",
                    multiselect: false,
                    param1: pageLangText.jikaGenryoHinDlgParam.text,
                    ismishiyo: pageLangText.falseFlg.text
                };
                // TODO: ここまで。
                shikakarizanDialog.draggable(true);
                shikakarizanDialog.dlg("open", option);
            };

            /// <summary>品一覧セレクタを起動する</summary>
            /// <param name="rowid">選択行ID</param>
            var showHinmeiDialog = function (rowid) {
                // フォーカスを外します(※値貼り付け後のバグ対策)
                saveEdit();

                var option = {
                    id: 'hinmei',
                    multiselect: false,
                    param1: pageLangText.seihinJikagenHinDlgParam.text,
                    ismishiyo: pageLangText.falseFlg.text
                };
                hinmeiDialog.draggable(true);
                hinmeiDialog.dlg("open", option);
            };

            /// <summary>検索条件変更チェックメッセージを出力します。</summary>
            /// <param name="outMessage">出力メッセージ</param>
            var showCriteriaChange = function (outMessage) {
                // 情報メッセージのクリア
                App.ui.page.notifyInfo.clear();
                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();
                var alertTarget = pageLangText[outMessage];
                if (App.isUndef(alertTarget)) {
                    return false;
                }

                // 情報メッセージ出力
                App.ui.page.notifyAlert.message(
                        App.str.format(pageLangText.criteriaChange.text, pageLangText.searchCriteria.text, alertTarget.text)
                ).show();
            };
            /// <summary>ローディングの表示</summary>
            var loading = function (msgid, fnc) {
                App.ui.loading.show(msgid);
                var deferred = $.Deferred();
                deferred
                .then(function () {
                    var d = new $.Deferred;
                    setTimeout(function () {
                        App.ui.loading.show(msgid);
                        d.resolve();
                    }, 50);
                    return d;
                })
                .then(function () {
                    if (fnc == "save-button") {
                        checkSave();
                    }
                    else if (fnc == "find-button") {
                        checkSearch();
                    }
                    else if (fnc == "cd_shikakari_zan") {
                        changeShikakarizanCode();
                    }
                });
                deferred.resolve();
            };

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
                    // F3の処理
                    processed = true;
                }
                // TODO: ここまで
                if (processed) {
                    //何か処理を行なっていた場合、ブラウザ既定の動作を無効にする
                    e.preventDefault();
                }
            };

            /// <summary>検索条件品名コード検索ボタンクリック時のイベント処理を行います。</summary>
            $("#shikakarizan-button").on("click", showShikakarizanDialog);

            /// <summary>検索条件/製品コードのイベント処理を行います。</summary>
            $("#cd_shikakari_zan").on("dblclick", showShikakarizanDialog)
            .on("change", function () {

                var result = $(".part-body .item-list").validation().validate();
                if (result.errors.length) {
                    return false;
                }

                // 値変更時
                var shikakarizanCode = $("#cd_shikakari_zan").val();
                if (shikakarizanCode == "") {
                    // 空の場合、品名を空白にする
                    clearShikakarizanInfo();
                }
                else {
                    // 仕掛残取得処理へ
                    changeShikakarizanCode(shikakarizanCode, false);
                }
            });

            /// <summary>品検索ダイアログ表示前チェックを行います。</summary>
            var checkHinmeiDialog = function () {
                var rowId = getSelectedRowId(false);
                // 検索済であるかチェック
                if (!isSearch) {
                    App.ui.page.notifyInfo.message(MS0621).show();
                    return false;
                }
                // 検索条件変更チェック
                if (isCriteriaChange) {
                    showCriteriaChange("navigate");
                    return false;
                }
                // 各種チェック
                if (!checkRecordCount()) {
                    return false;
                }
                showHinmeiDialog(rowId);
            };

            /// <summary>品検索ボタンクリック時のイベント処理を行います。</summary>
            $("#hinmei-button").on("click", checkHinmeiDialog);

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

            // 検索条件に変更が発生した場合
            $(".search-criteria").on("change", function () {
                // 検索後の状態で検索条件が変更された場合
                if (isSearch) {
                    isCriteriaChange = true;
                }
            });

            /// <summary>画面リサイズ時のイベント処理を行います。</summary>
            $(App.ui.page).on("resized", resizeContents);

            /// <summary>保存確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".save-confirm-dialog .dlg-yes-button").on("click", saveData);
            /// <summary>保存確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".save-confirm-dialog .dlg-no-button").on("click", closeSaveConfirmDialog);

            /// <summary>検索確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".find-confirm-dialog .dlg-yes-button").on("click", function () {
                clearState();
                loading(pageLangText.nowProgressing.text, "find-button");
            });
            /// <summary>検索確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".find-confirm-dialog .dlg-no-button").on("click", function () {
                // ローディングの終了
                App.ui.loading.close();
                closeFindConfirmDialog();
            });

            /// <summary>データに変更があり、未保存の状態でページを離れる際に確認を行います。</summary>
            /// 別画面に遷移したりするときに実行する関数の定義
            var onBeforeUnload = function () {
                //データを変更したかどうかは各画面でチェックし、保持する
                if (!noChange()) {
                    return pageLangText.unloadWithoutSave.text;
                }
            };
            $(window).on('beforeunload', onBeforeUnload);   //beforeunloadイベントに関数を割り当て
            //formをsubmit（ログオフ）する場合、beforeunloadイベントを発生させないようにする
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

            var backToMenu = function () {
                // IEバグによる例外発生をキャッチします。例外発生時は何もしません。
                try {
                    document.location = pageLangText.menuPath.url;
                }
                catch (e) {
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
        <h3 class="part-header" data-app-text="searchCriteria"><a class="search-part-toggle" href="#"></a></h3>
        <div class="part-body">
            <ul class="item-list">
                <!-- TODO: 画面の仕様に応じて以下の検索条件を変更してください。-->
                    <table>
                        <tr>
                            <td style="width: 480px;">
                                <span class="item-label" data-app-text="cd_shikakari_zan"></span>
                                <input type="text" name="cd_shikakari_zan" id="cd_shikakari_zan" />
                                <button type="button" class="dialog-button" name="shikakarizan-button" id="shikakarizan-button" data-app-operation="hinmei">
                                    <span class="icon"></span><span data-app-text="codeSearch"></span>
                                </button>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <span class="item-label" data-app-text="nm_shikakari_zan"></span>
                                <span class="conditionname-label" id="nm_shikakari_zan"></span>
                            </td>
                        </tr>
                    </table>
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
        <h3 id="listHeader" class="part-header" >
            <span data-app-text="_meisaiTitle" style="padding-right: 10px;"></span>
            <span class="list-count" id="list-count" ></span>
            <span style="" class="list-loading-message" id="list-loading-message" ></span>
        </h3>
        <div class="part-body">
            <ul class="item-list">
            </ul>
        </div>
        <!-- グリッドコントロール固有のデザイン -- Start -->
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
                <button type="button" class="dialog-button" id="hinmei-button" name="hinmeiIchiran" data-app-operation="hinmei">
                    <span class="icon"></span><span data-app-text="seihinIchiran"></span>
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
        <!-- TODO: 画面の仕様に応じて以下のボタンを変更してください。 -->
        <button type="button" class="save-button" name="save-button" data-app-operation="save"><span class="icon"></span><span data-app-text="save"></span></button>
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
    <!-- TODO: 画面の仕様に応じて以下のダイアログの設定を変更してください。 -->
    <div class="hinmei-dialog">
    </div>
    <div class="jikagenryo-dialog">
    </div>
    <!-- 保存確認コンファーム -->
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
    <!-- 検索確認コンファーム -->
    <div class="find-confirm-dialog" style="display: none;">
        <div class="dialog-header">
            <h4 data-app-text="confirmTitle"></h4>
        </div>
        <div class="dialog-body" style="padding: 10px; width: 100%;">
            <div class="part-body">
                <span data-app-text="findConfirm"></span>
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
    <div class="menu-confirm-dialog" style="display: none;">
        <div class="dialog-header">
            <h4 data-app-text="confirmTitle"></h4>
        </div>
        <div class="dialog-body" style="padding: 10px; width: 100%;">
            <div class="part-body">
                <span data-app-text="unloadWithoutSave"></span>
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
