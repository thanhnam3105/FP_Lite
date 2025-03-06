<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="NenkanCalendarMaster.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.NenkanCalendarMaster" %>

<asp:Content ID="Content1" ContentPlaceHolderID="IncludeContent" runat="server">
    <script src="<%=ResolveUrl("~/Resources/pages/pagedata-nenkancalendarmaster." + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
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
            color: Gray;
        }

        .search-criteria .conditionname-label
        {
            width: 15em;
        }
        
        /** 休日&祝日 */
        .kyushuku-col
        {
            background-color: #FFA500;
            color: #FF0000;
            font-weight: bold;
        }
        
        /** 休日 */
        .kyujitsu-col
        {
            background-color: #FFC0CB;
            color: #FF0000;
            font-weight: bold;
        }
        
        /** 祝日 */
        .shukujitsu-col
        {
            background-color: #FFFF00;
            color: #FF0000;
            font-weight: bold;
        }
        
        /** 平日 */
        .heijitsu-col
        {
            background-color: #FFFFFF;
            color: Black;
            font-weight: normal;
        }
        
        /* SelectedRowColor:#fce188 */
        /* 行選択時の共通カラーを解除 */
        .ui-jqgrid-btable .ui-state-highlight, .ui-jqgrid-btable .selected-row {
            border: 1px solid #999999; 
            background: #fcfaf8 50% 50%; 
            color: #363636; 
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
                querySetting = { skip: 0, top: 31, count: 0 },
                isDataLoading = false,
                searchCondition,
                userRoles = App.ui.page.user.Roles[0];

            // グリッドコントロール固有の変数宣言
            var grid = $("#item-grid"),
                lastScrollTop = 0,
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
                changeSet = new App.ui.page.changeSet(),
                firstCol = 1,
                duplicateCol = 999,
                currentRow = 0,
                currentCol = firstCol;
            // TODO : ここまで

            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            var yobi,
                selectCol,
                nendoStartMonth,
                searchCriteriaSetting = { yy_nendo_criteria: null };

            // TODO : 定数
            var KOJO_KYUJITSU = "1",
                IPPAN_KYUJITSU = "2",
                WEEK = ["日", "月", "火", "水", "木", "金", "土"];

            // TODO：ここまで

            // ダイアログ固有の変数宣言
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            var saveConfirmDialog = $(".save-confirm-dialog"),
                findConfirmDialog = $(".find-confirm-dialog");
            // TODO：ここまで

            //// 変数宣言 -- End

            //// コントロール定義 -- Start

            // ダイアログ固有のコントロール定義
            saveConfirmDialog.dlg();
            findConfirmDialog.dlg();

            /// <summary>ダイアログを開きます。</summary>
            var showSaveConfirmDialog = function () {
                saveConfirmDialogNotifyInfo.clear();
                saveConfirmDialogNotifyAlert.clear();
                saveConfirmDialog.draggable(true);
                saveConfirmDialog.dlg("open");
            };
            var showFindConfirmDialog = function () {
                findConfirmDialogNotifyInfo.clear();
                findConfirmDialogNotifyAlert.clear();
                findConfirmDialog.draggable(true);
                findConfirmDialog.dlg("open");
            };
            /// <summary>ダイアログを閉じます。</summary>
            var closeSaveConfirmDialog = function () {
                saveConfirmDialog.dlg("close");
            };
            var closeFindConfirmDialog = function () {
                findConfirmDialog.dlg("close");
            };

            /// 検索条件を保持する
            var saveSearchCriteria = function () {
                var criteria = $(".search-criteria").toJSON();
                searchCriteriaSetting = {
                    yy_nendo_criteria: criteria.yy_nendo
                };
            };

            // グリッドコントロール固有のコントロール定義
            grid.jqGrid({
                // TODO：画面の仕様に応じて以下の列名の定義を変更してください。
                colNames: [
                    pageLangText.dt_yobi_1.text,
                    pageLangText.dt_yobi_2.text,
                    pageLangText.dt_yobi_3.text,
                    pageLangText.dt_yobi_4.text,
                    pageLangText.dt_yobi_5.text,
                    pageLangText.dt_yobi_6.text,
                    pageLangText.dt_yobi_7.text,
                    pageLangText.dt_yobi_8.text,
                    pageLangText.dt_yobi_9.text,
                    pageLangText.dt_yobi_10.text,
                    pageLangText.dt_yobi_11.text,
                    pageLangText.dt_yobi_12.text,
                    '',
                    pageLangText.flg_kyujitsu.text,
                    pageLangText.flg_shukujitsu.text,
                    pageLangText.flg_kyujitsu.text,
                    pageLangText.flg_shukujitsu.text,
                    pageLangText.flg_kyujitsu.text,
                    pageLangText.flg_shukujitsu.text,
                    pageLangText.flg_kyujitsu.text,
                    pageLangText.flg_shukujitsu.text,
                    pageLangText.flg_kyujitsu.text,
                    pageLangText.flg_shukujitsu.text,
                    pageLangText.flg_kyujitsu.text,
                    pageLangText.flg_shukujitsu.text,
                    pageLangText.flg_kyujitsu.text,
                    pageLangText.flg_shukujitsu.text,
                    pageLangText.flg_kyujitsu.text,
                    pageLangText.flg_shukujitsu.text,
                    pageLangText.flg_kyujitsu.text,
                    pageLangText.flg_shukujitsu.text,
                    pageLangText.flg_kyujitsu.text,
                    pageLangText.flg_shukujitsu.text,
                    pageLangText.flg_kyujitsu.text,
                    pageLangText.flg_shukujitsu.text,
                    pageLangText.flg_kyujitsu.text,
                    pageLangText.flg_shukujitsu.text,
                    pageLangText.dt_1.text,
                    pageLangText.dt_2.text,
                    pageLangText.dt_3.text,
                    pageLangText.dt_4.text,
                    pageLangText.dt_5.text,
                    pageLangText.dt_6.text,
                    pageLangText.dt_7.text,
                    pageLangText.dt_8.text,
                    pageLangText.dt_9.text,
                    pageLangText.dt_10.text,
                    pageLangText.dt_11.text,
                    pageLangText.dt_12.text,
                    pageLangText.yy_nendo.text,
                    pageLangText.dt_nendo_start.text,
                    pageLangText.cd_create.text,
                    pageLangText.dt_create.text,
                    pageLangText.ts.text,
                    pageLangText.ts.text,
                    pageLangText.ts.text,
                    pageLangText.ts.text,
                    pageLangText.ts.text,
                    pageLangText.ts.text,
                    pageLangText.ts.text,
                    pageLangText.ts.text,
                    pageLangText.ts.text,
                    pageLangText.ts.text,
                    pageLangText.ts.text,
                    pageLangText.ts.text
                ],
                // TODO：ここまで
                // TODO：画面の仕様に応じて以下の列モデルの定義を変更してください。
                colModel: [
                    { name: 'dt_yobi_1', width: 60, align: "center", sortable: false, formatter: emptyFormatter },
                    { name: 'dt_yobi_2', width: 60, align: "center", sortable: false },
                    { name: 'dt_yobi_3', width: 60, align: "center", sortable: false },
                    { name: 'dt_yobi_4', width: 60, align: "center", sortable: false },
                    { name: 'dt_yobi_5', width: 60, align: "center", sortable: false },
                    { name: 'dt_yobi_6', width: 60, align: "center", sortable: false },
                    { name: 'dt_yobi_7', width: 60, align: "center", sortable: false },
                    { name: 'dt_yobi_8', width: 60, align: "center", sortable: false },
                    { name: 'dt_yobi_9', width: 60, align: "center", sortable: false },
                    { name: 'dt_yobi_10', width: 60, align: "center", sortable: false },
                    { name: 'dt_yobi_11', width: 60, align: "center", sortable: false },
                    { name: 'dt_yobi_12', width: 60, align: "center", sortable: false },
                    { name: 'no', width: 25, align: "center", sortable: false, classes: 'ui-state-default jqgrid-rownum' },
                    { name: 'dt_1', width: 0, hidden: true, hidedlg: true },
                    { name: 'dt_2', width: 0, hidden: true, hidedlg: true },
                    { name: 'dt_3', width: 0, hidden: true, hidedlg: true },
                    { name: 'dt_4', width: 0, hidden: true, hidedlg: true },
                    { name: 'dt_5', width: 0, hidden: true, hidedlg: true },
                    { name: 'dt_6', width: 0, hidden: true, hidedlg: true },
                    { name: 'dt_7', width: 0, hidden: true, hidedlg: true },
                    { name: 'dt_8', width: 0, hidden: true, hidedlg: true },
                    { name: 'dt_9', width: 0, hidden: true, hidedlg: true },
                    { name: 'dt_10', width: 0, hidden: true, hidedlg: true },
                    { name: 'dt_11', width: 0, hidden: true, hidedlg: true },
                    { name: 'dt_12', width: 0, hidden: true, hidedlg: true },
                    { name: 'kyujitsu_1', width: 0, hidden: true, hidedlg: true },
                    { name: 'shukujitsu_1', width: 0, hidden: true, hidedlg: true },
                    { name: 'kyujitsu_2', width: 0, hidden: true, hidedlg: true },
                    { name: 'shukujitsu_2', width: 0, hidden: true, hidedlg: true },
                    { name: 'kyujitsu_3', width: 0, hidden: true, hidedlg: true },
                    { name: 'shukujitsu_3', width: 0, hidden: true, hidedlg: true },
                    { name: 'kyujitsu_4', width: 0, hidden: true, hidedlg: true },
                    { name: 'shukujitsu_4', width: 0, hidden: true, hidedlg: true },
                    { name: 'kyujitsu_5', width: 0, hidden: true, hidedlg: true },
                    { name: 'shukujitsu_5', width: 0, hidden: true, hidedlg: true },
                    { name: 'kyujitsu_6', width: 0, hidden: true, hidedlg: true },
                    { name: 'shukujitsu_6', width: 0, hidden: true, hidedlg: true },
                    { name: 'kyujitsu_7', width: 0, hidden: true, hidedlg: true },
                    { name: 'shukujitsu_7', width: 0, hidden: true, hidedlg: true },
                    { name: 'kyujitsu_8', width: 0, hidden: true, hidedlg: true },
                    { name: 'shukujitsu_8', width: 0, hidden: true, hidedlg: true },
                    { name: 'kyujitsu_9', width: 0, hidden: true, hidedlg: true },
                    { name: 'shukujitsu_9', width: 0, hidden: true, hidedlg: true },
                    { name: 'kyujitsu_10', width: 0, hidden: true, hidedlg: true },
                    { name: 'shukujitsu_10', width: 0, hidden: true, hidedlg: true },
                    { name: 'kyujitsu_11', width: 0, hidden: true, hidedlg: true },
                    { name: 'shukujitsu_11', width: 0, hidden: true, hidedlg: true },
                    { name: 'kyujitsu_12', width: 0, hidden: true, hidedlg: true },
                    { name: 'shukujitsu_12', width: 0, hidden: true, hidedlg: true },
                    { name: 'yy_nendo', width: 0, hidden: true, hidedlg: true },
                    { name: 'dt_nendo_start', width: 0, hidden: true, hidedlg: true },
                    { name: 'cd_create', width: 0, hidden: true, hidedlg: true },
                    { name: 'dt_create', width: 0, hidden: true, hidedlg: true },
                    { name: 'ts_1', width: 0, hidden: true, hidedlg: true },
                    { name: 'ts_2', width: 0, hidden: true, hidedlg: true },
                    { name: 'ts_3', width: 0, hidden: true, hidedlg: true },
                    { name: 'ts_4', width: 0, hidden: true, hidedlg: true },
                    { name: 'ts_5', width: 0, hidden: true, hidedlg: true },
                    { name: 'ts_6', width: 0, hidden: true, hidedlg: true },
                    { name: 'ts_7', width: 0, hidden: true, hidedlg: true },
                    { name: 'ts_8', width: 0, hidden: true, hidedlg: true },
                    { name: 'ts_9', width: 0, hidden: true, hidedlg: true },
                    { name: 'ts_10', width: 0, hidden: true, hidedlg: true },
                    { name: 'ts_11', width: 0, hidden: true, hidedlg: true },
                    { name: 'ts_12', width: 0, hidden: true, hidedlg: true }
                ],
                // TODO：ここまで
                datatype: "local",
                shrinkToFit: false,
                multiselect: false,
                rownumbers: true,
                hoverrows: false,
                cellEdit: false,
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
                },
                loadComplete: function () {
                    // TODO：ここから																									
                    // 月を表示させる																									
                    var dt = grid.getCell(1, "dt_1");
                    if (!dt) {
                        return;
                    }
                    var colNames = grid.jqGrid("getGridParam", "colNames");
                    var colModel = grid.jqGrid("getGridParam", "colModel");
                    var colNum = 0;
                    for (var i = 1; i <= pageLangText.monthCount.text; i++) {
                        colNum = i;
                        dt = App.data.getDate(grid.getCell(1, "dt_" + i));
                        grid.jqGrid("setLabel", colModel[colNum].name,
                            App.str.format(pageLangText.monthNameId.data[dt.getMonth()].shortName));
                    }
                    // TODO：ここまで																									
                },
                gridComplete: function () {
                    // 検索条件を保持する
                    saveSearchCriteria();
                },
                onCellSelect: function (rowid, icol, cellcontent) {
                    selectCol = icol;
                },
                ondblClickRow: function (rowid) {
                    if (userRoles != pageLangText.admin.text) {
                        if (userRoles != pageLangText.purchase.text) {
                            return;
                        }
                    }
                    var criteria = $(".search-criteria").toJSON();
                    var kbnKyujitsu = criteria.kbn_kyujitsu;
                    var flgShuku = grid.jqGrid("getCell", rowid, "shukujitsu_" + selectCol);
                    var flgKyu = grid.jqGrid("getCell", rowid, "kyujitsu_" + selectCol);
                    var className,
                        _flgKyu,
                        _flgShuku,
                        cellName;

                    // 色の決定、フラグ値をセットする
                    if (kbnKyujitsu === KOJO_KYUJITSU) {
                        if (flgKyu === "0" && flgShuku === "0") {
                            className = "kyujitsu-col";
                            _flgKyu = "1";
                            _flgShuku = flgShuku;
                        }
                        else if (flgKyu === "1" && flgShuku === "1") {
                            className = "shukujitsu-col";
                            _flgKyu = "0";
                            _flgShuku = flgShuku;
                        }
                        else if (flgKyu === "1" && flgShuku === "0") {
                            className = "heijitsu-col";
                            _flgKyu = "0";
                            _flgShuku = flgShuku;
                        }
                        else if (flgKyu === "0" && flgShuku === "1") {
                            className = "kyushuku-col";
                            _flgKyu = "1";
                            _flgShuku = flgShuku;
                        }
                    }
                    else if (kbnKyujitsu === IPPAN_KYUJITSU) {
                        if (flgKyu === "1" && flgShuku === "1") {
                            className = "kyujitsu-col";
                            _flgShuku = "0";
                            _flgKyu = flgKyu;
                        }
                        else if (flgKyu === "0" && flgShuku === "0") {
                            className = "shukujitsu-col";
                            _flgShuku = "1";
                            _flgKyu = flgKyu;
                        }
                        else if (flgKyu === "0" && flgShuku === "1") {
                            className = "heijitsu-col";
                            _flgShuku = "0";
                            _flgKyu = flgKyu;
                        }
                        else if (flgKyu === "1" && flgShuku === "0") {
                            className = "kyushuku-col";
                            _flgShuku = "1";
                            _flgKyu = flgKyu;
                        }
                    }

                    grid.editCell(rowid, selectCol, true);
                    grid.toggleClassCol(rowid, selectCol, className);
                    grid.setCell(rowid, 'kyujitsu_' + selectCol, _flgKyu);
                    grid.setCell(rowid, 'shukujitsu_' + selectCol, _flgShuku);
                    grid.editCell(rowid, selectCol, false);

                    var count = changeSet.getChangeSetData().Updated.length;
                    setUpdatedChangeData(rowid, count, selectCol, _flgKyu, _flgShuku);
                    selectCol = "";
                }
            });

            var emptyFormatter = function (el, cellval, opts) {
                if (App.isNull(cellVal)) {
                    $(el).html("-");
                }
            };

            /// <summary>セルの関連項目を設定します。</summary>
            /// <param name="selectedRowId">選択行ID</param>
            /// <param name="cellName">列名</param>
            /// <param name="value">元となる項目の値</param>
            /// <param name="iCol">項目の列番号</param>
            var setRelatedValue = function (selectedRowId, cellName, value, iCol) {
                // TODO：画面の仕様に応じて以下の関連項目を設定を変更してください。
                // TODO：ここまで
            };

            var changeCol = function (rowid, isKyujitsu, isShukujitsu) {
                if (isKyujitsu === 0) {
                    if (isShukujitsu === 1) {
                        grid.toggleClassCol(rowid, selectCol, "kyushuku-col");
                    }
                    else {
                        grid.toggleClassCol(rowid, selectCol, "kyujitsu-col");
                    }
                    return 1;
                }
                else {
                    if (isShukujitsu === 1) {
                        grid.toggleClassCol(rowid, selectCol, "shukujitsu-col");
                    }
                    else {
                        grid.toggleClassCol(rowid, selectCol, "heijitsu-col");
                    }
                    return 0;
                }
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
            $(function () {
                if (userRoles === pageLangText.operator.text
                        || userRoles === pageLangText.editor.text
                        || userRoles === pageLangText.viewer.text) {
                    $(".settei-button").css("display", "none");
                    $(".save-button").css("display", "none");
                    $("#id-settei_1").css("display", "none");
                    $("#id-settei_2").css("display", "none");
                }
            });

            //// 操作制御定義 -- End

            //// 事前データロード -- Start 

            // 画面アーキテクチャ共通の事前データロード
            yobi = pageLangText.yobiId.data;
            App.ui.appendOptions($(".search-criteria [name='yobi']"), "id", "name", yobi, false);


            /// <summary>年度開始月を取得する</summary>
            $(function () {
                App.ui.loading.show(pageLangText.nowProgressing.text);

                var serviceUrl = "../Services/FoodProcsService.svc/ma_kojo()?$filter=cd_kaisha eq '"
                    + App.ui.page.user.KaishaCode + "' and cd_kojo eq '" + App.ui.page.user.BranchCode + "'&$top=1"
                    , elementCode = "dt_nendo_start"
                    , codeName;

                App.deferred.parallel({
                    // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                    codeName: App.ajax.webget(serviceUrl)
                    // TODO: ここまで
                }).done(function (result) {
                    // TODO: 画面の仕様に応じて以下のサービス呼び出し成功時の処理を変更してください。
                    codeName = result.successes.codeName.d;
                    if (codeName.length > 0) {
                        nendoStartMonth = codeName[0][elementCode];
                    }
                    else if ($(".search-criteria").toJSON().haigoCode) {
                        messages.push(pageLangText.notFound.text);
                        App.ui.page.notifyAlert.message(messages).show();
                    }

                    //1950年～システム日付より50年まで表示
                    var year = 1950;
                    var date = new Date();
                    maxYear = parseInt(date.getFullYear()) + 50;
                    for (var i = maxYear; i >= 1950; i--) {
                        if (i === year) {
                            $(".search-criteria [name='yy_nendo']").append('<option value="' + i.toString() + '" selected>' + i + '</option>');
                        } else {
                            $(".search-criteria [name='yy_nendo']").append('<option value="' + i.toString() + '">' + i + '</option>');
                        }
                    }

                    var yy = date.getFullYear();
                    var mm = date.getMonth() + 1;
                    var sysYear = (yy < 2000) ? yy + 1900 : yy;

                    var addyy = 0;
                    if (nendoStartMonth <= 6) {
                        if (mm <= nendoStartMonth) {
                            addyy = -1;
                        }
                    }
                    else {
                        if (mm > nendoStartMonth) {
                            addyy = +1;
                        }
                    }

                    $(".search-criteria [name='yy_nendo']").val(yy + addyy);
                    $(".search-criteria [name='yy_nendo']").bind('change', function () { })

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
                    App.ui.loading.close();
                }).always(function () {
                    App.ui.loading.close();
                });
                return nendoStartMonth;
            });

            //// 事前データロード -- End

            //// 検索処理 -- Start

            // 画面アーキテクチャ共通の検索処理

            var queryWeb = function () {
                var criteria = $(".search-criteria").toJSON();

                // 標準時間と現地時間の差分をhh単位で取得
                //var add_hh = (new Date()).getTimezoneOffset() / 60;
                var add_hh = 0;    // 2014.10.16：仕様が10時固定となり不要のため、ダミー値を設定
                //if (add_hh < 0) {
                //    add_hh = add_hh * -1;    // マイナスを削除
                //}

                var query = {
                    // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                    url: "../api/NenkanCalendarMaster"
                    // TODO: ここまで
                    , yy_nendo: criteria.yy_nendo
                    , cd_kaisha: App.ui.page.user.KaishaCode
                    , cd_kojo: App.ui.page.user.BranchCode
                    , dt_nendo_start: nendoStartMonth
                    , cd_user: App.ui.page.user.Code
                    , lang: App.ui.page.lang
                    , skip: querySetting.skip
                    , top: querySetting.top
                    , add_hh: add_hh
                }
                return query;
            };
            /// <summary>データ検索を行います。</summary>
            /// <param name="query">クエリオブジェクト</param>
            var searchItems = function (query) {
                closeFindConfirmDialog();
                App.ui.loading.show(pageLangText.nowProgressing.text);
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
                    App.data.toWebAPIFormat(query)
                ).done(function (result) {
                    // データバインド
                    bindData(result);
                    changeGridRowColor();
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                    App.ui.loading.close();
                }).always(function () {
                    setTimeout(function () {
                        $("#list-loading-message").text("");
                        isDataLoading = false;
                    }, 500);
                    App.ui.loading.close();
                });
            };

            /// <summary>フィルター条件の設定</summary>
            var createFilter = function () {
                var criteria = $(".search-criteria").toJSON(),
                    filters = [];
                searchCondition = criteria;
                // TODO: 画面の仕様に応じて以下のフィルター条件を変更してください。
                if (!App.isUndefOrNull(criteria.yy_nendo) && criteria.yy_nendo.length > 0) {
                    filters.push("yy_nendo eq " + "'" + criteria.yy_nendo + "'");
                }
                // TODO: ここまで

                return filters.join(" and ");
            };

            /// <summary>フィルター条件の設定</summary>
            var kojoCreateFilter = function () {
                var filters = [];
                // TODO: 画面の仕様に応じて以下のフィルター条件を変更してください。
                filters.push("cd_kaisha eq " + "'" + App.ui.page.user.KaishaCode + "'");
                filters.push("cd_kojo eq " + "'" + App.ui.page.user.BranchCode + "'");
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
                if (!noChange()) {
                    showFindConfirmDialog();
                }
                else {
                    clearState();
                    searchItems(new queryWeb());
                }
            });

            $("#id-kbn_ippan").on("click", function () {
                $(".settei-button").attr("disabled", "disabled");
                $("#condition-yobi").attr("disabled", "disabled");
                $("#id-flg_kyujitsu").attr("disabled", "disabled");
                $("#id-flg_kaijo").attr("disabled", "disabled");
            });

            $("#id-kbn_kojo").on("click", function () {
                $(".settei-button").removeAttr("disabled");
                $("#condition-yobi").removeAttr("disabled");
                $("#id-flg_kyujitsu").removeAttr("disabled");
                $("#id-flg_kaijo").removeAttr("disabled");
            });

            /// <summary>明細行の背景色を変更する。</summary>																		
            var changeGridRowColor = function () {
                if (grid[0].rows.length === 0) {
                    return;
                }
                var iData;
                for (var iRow = 1; iRow < grid[0].rows.length; iRow++) {
                    iData = iRow - 1;
                    colColorChange(iRow, "1",
                            grid[0].p.data[iData].kyujitsu_1, grid[0].p.data[iData].shukujitsu_1);
                    colColorChange(iRow, "2",
                            grid[0].p.data[iData].kyujitsu_2, grid[0].p.data[iData].shukujitsu_2);
                    colColorChange(iRow, "3",
                            grid[0].p.data[iData].kyujitsu_3, grid[0].p.data[iData].shukujitsu_3);
                    colColorChange(iRow, "4",
                            grid[0].p.data[iData].kyujitsu_4, grid[0].p.data[iData].shukujitsu_4);
                    colColorChange(iRow, "5",
                            grid[0].p.data[iData].kyujitsu_5, grid[0].p.data[iData].shukujitsu_5);
                    colColorChange(iRow, "6",
                            grid[0].p.data[iData].kyujitsu_6, grid[0].p.data[iData].shukujitsu_6);
                    colColorChange(iRow, "7",
                            grid[0].p.data[iData].kyujitsu_7, grid[0].p.data[iData].shukujitsu_7);
                    colColorChange(iRow, "8",
                            grid[0].p.data[iData].kyujitsu_8, grid[0].p.data[iData].shukujitsu_8);
                    colColorChange(iRow, "9",
                            grid[0].p.data[iData].kyujitsu_9, grid[0].p.data[iData].shukujitsu_9);
                    colColorChange(iRow, "10",
                            grid[0].p.data[iData].kyujitsu_10, grid[0].p.data[iData].shukujitsu_10);
                    colColorChange(iRow, "11",
                            grid[0].p.data[iData].kyujitsu_11, grid[0].p.data[iData].shukujitsu_11);
                    colColorChange(iRow, "12",
                            grid[0].p.data[iData].kyujitsu_12, grid[0].p.data[iData].shukujitsu_12);
                }
            };
            /// <summary>カラムのクラスを差し替える</summary>
            var colColorChange = function (rowid, cellId, isKyu, isShuku) {
                if (isKyu === 1 && isShuku === 1) {
                    grid.toggleClassCol(rowid, cellId, "kyushuku-col");
                }
                else if (isKyu === 1 && isShuku === 0) {
                    grid.toggleClassCol(rowid, cellId, "kyujitsu-col");
                }
                else if (isKyu === 0 && isShuku === 1) {
                    grid.toggleClassCol(rowid, cellId, "shukujitsu-col");
                }
                else {
                    grid.toggleClassCol(rowid, cellId, "");
                }
            };

            /// <summary>休日を設定する</summary>
            /// iRow		行番号
            /// name		月を示す名称
            /// cellId		セルId
            /// kbnKyujitsu	休日区分
            /// flgKyujitsu	休日フラグ
            /// yobiName	曜日
            var setKyujitsu = function (iRow, cellId, kbnKyujitsu, flgKyujitsu, yobiName) {
                var shukujitsuCellName = "shukujitsu_" + cellId
                    , kyujitsuCellName = "kyujitsu_" + cellId
                    , flgShuku = grid.jqGrid('getCell', iRow, shukujitsuCellName)
                    , flgKyu = grid.jqGrid('getCell', iRow, kyujitsuCellName)
                    , _flgKyu = flgKyu
                    , _flgShuku = flgShuku
                    , className;

                if (yobiName === grid.jqGrid("getCell", iRow, "dt_yobi_" + cellId)) {
                    // 色の決定、フラグ値をセットする
                    // ◎解除の場合
                    if (flgKyujitsu === "0") {
                        _flgKyu = "0";
                        if (flgShuku === "1") {
                            className = "shukujitsu-col";
                        }
                        else {
                            className = "heijitsu-col";
                        }
                    }
                    else {
                        // ◎休日の場合
                        _flgKyu = "1";
                        className = "kyujitsu-col";
                        if (flgShuku === "1") {
                            className = "kyushuku-col";
                        }
                    }

                    // クラスと値をセットする
                    grid.toggleClassCol(iRow, cellId, className);
                    grid.jqGrid("setCell", iRow, kyujitsuCellName, _flgKyu);
                    var count = changeSet.getChangeSetData().Updated.length;
                    setUpdatedChangeData(iRow, count, cellId, _flgKyu, _flgShuku);
                }
            };

            /// <summary>休日設定をカレンダーに表示します。</summary>
            var configCalendar = function () {
                var criteria = $(".search-criteria").toJSON();
                var kbnKyujitsu = criteria.kbn_kyujitsu;
                var flgKyujitsu = criteria.flg_kyujitsu;
                //    			var yobiName = WEEK[criteria.yobi];
                var yobiName = pageLangText.yobiId.data[criteria.yobi].shortName;

                var index = 0;
                for (var iRow = 1; iRow < grid[0].rows.length; iRow++) {
                    setKyujitsu(iRow, "1", kbnKyujitsu, flgKyujitsu, yobiName);
                    setKyujitsu(iRow, "2", kbnKyujitsu, flgKyujitsu, yobiName);
                    setKyujitsu(iRow, "3", kbnKyujitsu, flgKyujitsu, yobiName);
                    setKyujitsu(iRow, "4", kbnKyujitsu, flgKyujitsu, yobiName);
                    setKyujitsu(iRow, "5", kbnKyujitsu, flgKyujitsu, yobiName);
                    setKyujitsu(iRow, "6", kbnKyujitsu, flgKyujitsu, yobiName);
                    setKyujitsu(iRow, "7", kbnKyujitsu, flgKyujitsu, yobiName);
                    setKyujitsu(iRow, "8", kbnKyujitsu, flgKyujitsu, yobiName);
                    setKyujitsu(iRow, "9", kbnKyujitsu, flgKyujitsu, yobiName);
                    setKyujitsu(iRow, "10", kbnKyujitsu, flgKyujitsu, yobiName);
                    setKyujitsu(iRow, "11", kbnKyujitsu, flgKyujitsu, yobiName);
                    setKyujitsu(iRow, "12", kbnKyujitsu, flgKyujitsu, yobiName);
                }
                App.ui.loading.close();
            };

            /// <summary>設定ボタンクリック時のイベント処理を行います。</summary>
            $(".settei-button").on("click", function () {
                var msg = pageLangText.nowProgressing.text;
                App.ui.loading.show(msg);
                var deferred = $.Deferred();
                deferred
                .then(function () {
                    var d = new $.Deferred;
                    setTimeout(function () {
                        App.ui.loading.show(msg);
                        d.resolve();
                    }, 50);
                    return d;
                })
                .then(function () {
                    configCalendar();
                });
                deferred.resolve();
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
                // グリッドの表示件数を更新
                grid.setGridParam({ rowNum: querySetting.top });
                // データバインド
                var currentData = grid.getGridParam("data").concat(result.d);
                grid.setGridParam({ data: currentData }).trigger('reloadGrid', [{ current: true}]);
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
            // ダイアログ情報メッセージの設定
            var findConfirmDialogNotifyInfo = App.ui.notify.info(findConfirmDialog, {
                container: ".find-confirm-dialog .dialog-slideup-area .info-message",
                messageContainerQuery: "ul",
                show: function () {
                    findConfirmDialog.find(".info-message").show();
                },
                clear: function () {
                    findConfirmDialog.find(".info-message").hide();
                }
            });
            // ダイアログ警告メッセージの設定
            var findConfirmDialogNotifyAlert = App.ui.notify.alert(findConfirmDialog, {
                container: ".find-confirm-dialog .dialog-slideup-area .alert-message",
                messageContainerQuery: "ul",
                show: function () {
                    findConfirmDialog.find(".alert-message").show();
                },
                clear: function () {
                    findConfirmDialog.find(".alert-message").hide();
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
                    // selectedRowId = ids[recordCount - 1]; // 最終行
                    selectedRowId = ids[0]; // 先頭行
                }
                currentRow = $('#' + selectedRowId)[0].rowIndex;

                return selectedRowId;
            };

            /// <summary>更新状態の変更セットに追加する変更データの設定を行います。</summary>
            /// <param name="row">選択行</param>
            var setUpdatedChangeData = function (rowId, count, col, flgKyujitsu, flgShukujitsu) {
                var row = grid.getRowData(rowId);
                if (!row.dt_1) {
                    return;
                }

                var dt_hizuke = App.data.getDate(grid.getCell(rowId, "dt_" + col));
                if (!dt_hizuke) {
                    dt_hizuke = new Date(grid.getCell(rowId, "dt_" + col));
                }

                // TODO: 画面の仕様に応じて以下の項目を変更してください。
                changeSet.addUpdated(count, "flg_kyujitsu", flgKyujitsu, {
                    "yy_nendo": row.yy_nendo,
                    "dt_hizuke": dt_hizuke,
                    "flg_kyujitsu": flgKyujitsu,
                    "flg_shukujitsu": flgShukujitsu,
                    "cd_create": row.cd_create,
                    "dt_create": row.dt_create,
                    "dt_update": null, // サーバにてセットする
                    "cd_update": App.ui.page.user.Code,
                    "ts": grid.getCell(rowId, "ts_" + col)
                });
                // TODO: ここまで

            };
            /// <summary>関連項目の設定を変更セットに反映します。</summary>
            /// <param name="selectedRowId">選択行ID</param>
            /// <param name="cellName">列名</param>
            /// <param name="value">元となる項目の値</param>
            var setRelatedChangeData = function (selectedRowId, cellName, value, changeData) {
                // TODO: 画面の仕様に応じて以下の処理を変更してください。

                // TODO: ここまで
            };

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

                if (!App.isArray(ret) && App.isUndefOrNull(ret.Updated)) {
                    App.ui.page.notifyAlert.message(result.message).show();
                    return;
                }

                var ids = grid.getDataIDs(),
                    newId,
                    value,
                    unique,
                    current,
                // TODO: 画面の仕様に応じて以下の変数を変更します。
                    checkCol_a = 1,
        			checkCol_b = 12;
                // TODO: ここまで

                // データ整合性エラーのハンドリングを行います。
                if (App.isArray(ret) && ret.length > 0) {
                    for (var i = 0; i < ret.length; i++) {
                        for (var j = 0; j < ids.length; j++) {
                            // TODO: 画面の仕様に応じて以下の値を変更します。
                            value_a = grid.getCell(ids[j], checkCol_a);
                            value_b = parseInt(grid.getCell(ids[j], checkCol_b), 10);
                            ts = grid.getCell(ids[j], "ts");
                            //                            retValue_a = ret[i].Data.cd_line;
                            //                            retValue_b = ret[i].Data.no_yusen;
                            // TODO: ここまで

                            //                            if (value_a === retValue_a && value_b === retValue_b && !ts) {
                            if (!ts) {
                                // TODO: 画面の仕様に応じて以下のロジックを変更します。
                                if (ret[i].ColumnName === "keys") {
                                    unique = ids[j] + "_" + checkCol_a + "_" + checkCol_b;

                                    // エラーメッセージの表示
                                    App.ui.page.notifyAlert.message(
                                        pageLangText.invalidation.text + ret[i].Message, unique).show();
                                    // 対象セルの背景変更
                                    grid.setCell(ids[j], firstCol, ret[i].Data.cd_line, { background: '#ff6666' });
                                    grid.setCell(ids[j], firstCol + 2, ret[i].Data.no_yusen, { background: '#ff6666' });
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
                    var isError = false;
                    for (var i = 0; i < ret.Updated.length; i++) {
                        for (p in changeSet.changeSet.updated) {
                            if (!changeSet.changeSet.updated.hasOwnProperty(p)) {
                                continue;
                            }

                            // TODO: 画面の仕様に応じて以下の値を変更します。
                            // TODO: ここまで
                            isError = true;
                        }
                    }
                    // エラーメッセージの表示
                    App.ui.page.notifyAlert.message(
                        pageLangText.duplicate.text, unique).show();
                }
            };
            /// <summary>変更を保存します。</summary>
            /// <param name="e">イベントデータ</param>
            var saveData = function (e) {
                closeSaveConfirmDialog();
                // ローディングの表示
                App.ui.loading.show(pageLangText.nowSaving.text);
                // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                var saveUrl = "../api/NenkanCalendarMaster";
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
                var bool = true;
                if (searchCriteriaSetting.yy_nendo_criteria != criteria.yy_nendo) {
                    bool = false;
                    $(".part-body .command [name='yy_nendo']").val(searchCriteriaSetting.yy_nendo_criteria).change();
                }
                return bool;
            };
            /// <summary>保存前チェック</summary>
            var checkSave = function () {
                // 情報メッセージのクリア
                clearMessage();
                // 編集内容の保存
                saveEdit();
                // 検索条件が変更されていないか
                if (!noChangeCriteria()) {
                    App.ui.page.notifyAlert.message(MS0575).show();
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
            //    		$(".save-button").on("click", showSaveConfirmDialog);

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

            /// <summary>変更セットのバリデーションを実行します。</summary>
            var validateChangeSet = function () {
                for (p in changeSet.changeSet.created) {
                    if (!changeSet.changeSet.created.hasOwnProperty(p)) {
                        continue;
                    }
                    /*/ カレントの行バリデーションを実行
                    if (!validateRow(p)) {
                    return false;
                    }*/
                }
                for (p in changeSet.changeSet.updated) {
                    if (!changeSet.changeSet.updated.hasOwnProperty(p)) {
                        continue;
                    }
                    /*/ カレントの行バリデーションを実行
                    if (!validateRow(p)) {
                    return false;
                    }*/
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
            $(".save-confirm-dialog .dlg-no-button").on("click", closeSaveConfirmDialog);

            /// <summary>クリア確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".find-confirm-dialog .dlg-yes-button").on("click", function () {
                clearState();
                searchItems(new queryWeb());
            });

            // <summary>クリア確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".find-confirm-dialog .dlg-no-button").on("click", closeFindConfirmDialog);

            /// <summary>データに変更があり、未保存の状態でページを離れる際に確認を行います。</summary>
            $(window).on('beforeunload', function () {
                if (!noChange()) {
                    return pageLangText.unloadWithoutSave.text;
                }
            });

            var backToMenu = function () {
                // IEバグによる例外発生をキャッチします。例外発生時は何もしません。
                try {
                    document.location = pageLangText.menuPath.url;
                }
                catch (e) {
                    // 何もしない
                }
            };
            /// <summary>メニューボタンクリック時のイベント処理を行います。</summary>
            $(".menu-button").on("click", backToMenu);

            /// メッセージをクリアする
            var clearMessage = function () {
                // 情報メッセージのクリア
                App.ui.page.notifyInfo.clear();
                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();
            };

        });
    </script>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <!-- 画面デザイン -- Start -->
    <!-- 検索条件と検索ボタン -->
    <div class="content-part search-criteria">
        <h3 class="part-header" data-app-text="search_configCriteria">
            <a class="search-part-toggle" href="#"></a>
        </h3>
        <div class="part-body" style="height: 4em;">
            <!-- TODO: 画面の仕様に応じて以下の検索条件を変更してください。-->
            <span class="command" style="width: 50%;">
                <label style="vertical-align: middle;">
                    <span class="item-label" data-app-text="yy_nendo" style="width: 3em;"></span>
                    <select name="yy_nendo" id="condition-yy_nendo">
                    </select>
                </label>
            </span>
            <span class="command" id="id-settei_1" style="position: absolute; left: 45%; width: 55%;">
                <label>
                    <input type="radio" name="kbn_kyujitsu" id="id-kbn_kojo" value="1" checked />
                    <span class="item-label" data-app-text="kojoKyujitsu" data-tooltip-text="kojoKyujitsu"></span>
                </label>
                <label>
                    <input type="radio" name="kbn_kyujitsu" id="id-kbn_ippan" value="2" /><span class="item-label"
                        data-app-text="ippanKyujitsu" data-tooltip-text="ippanKyujitsu"></span>
                </label>
            </span>
            <br />
            <!-- 検索ボタン -->
            <%--<span class="command" style="padding-left: 25%; width: 40%;">--%>
            <span class="command" style="width: 40%;">
                <button type="button" class="find-button" name="find-button" style="vertical-align: text-top;" data-app-operation="search">
                    <span class="icon"></span><span data-app-text="search"></span>
                </button>
            </span>
            <!-- 設定エリア -->
            <span class="command" id="id-settei_2" style="position: absolute; left: 45%; width: 60%;">
                <label>
                    <input type="radio" name="flg_kyujitsu" id="id-flg_kyujitsu" value="1" checked /><span
                        class="item-label" data-app-text="kyujitsu"></span>
                </label>
                <label>
                    <input type="radio" name="flg_kyujitsu" id="id-flg_kaijo" value="0" /><span class="item-label"
                        data-app-text="kaijo"></span>
                </label>
                <label>
                    <select name="yobi" id="condition-yobi" style="width: 6em;">
                    </select>
                </label>
                <label style="width: 20%;">
                </label>
                <!-- 設定ボタン -->
                <button type="button" class="settei-button" name="settei-button" style="vertical-align: text-top;" data-app-operation="settei">
                    <span class="icon"></span><span data-app-text="config"></span>
                </button>
            </span>
        </div>
    </div>
    <!-- 検索結果一覧 -->
    <div class="content-part result-list">
        <!-- グリッドコントロール固有のデザイン -- Start -->
        <h3 id="listHeader" class="part-header" style="display: none;">
            <span data-app-text="resultList" style="padding-right: 10px;"></span><span class="list-count"
                id="list-count"></span><span style="padding-left: 50px;" class="list-loading-message"
                    id="list-loading-message"></span>
        </h3>
        <div class="part-body" id="result-grid">
            <div class="item-command">
                <table style="height: 3em;">
                    <tr>
                        <td style="position: absolute; left: 50%; width: 50%;">
                            <span data-app-text="memo_1"></span>
                        </td>
                    </tr>
                    <tr>
                        <td style="position: absolute; left: 50%; width: 50%;">
                            <span data-app-text="memo_2"></span>
                        </td>
                    </tr>
                </table>
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
            <span class="icon"></span><span data-app-text="save"></span>
        </button>
        <!-- TODO: ここまで -->
    </div>
    <div class="command" style="right: 9px;">
        <button type="button" class="menu-button" name="menu-button">
            <span class="icon"></span><span data-app-text="menu"></span>
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
    <div class="find-confirm-dialog" style="display: none;">
        <div class="dialog-header">
            <h4 data-app-text="confirmTitle">
            </h4>
        </div>
        <div class="dialog-body" style="padding: 10px; width: 100%;">
            <div class="part-body">
                <span data-app-text="findConfirm"></span>
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
    <!-- TODO: ここまで  -->
    <!-- 画面デザイン -- End -->
</asp:Content>
