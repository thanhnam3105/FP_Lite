<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="GenshizaiKonyusakiMaster.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.GenshizaiKonyusakiMaster" %>

<asp:Content ID="Content1" ContentPlaceHolderID="IncludeContent" runat="server">
    <script src="<%=ResolveUrl("~/Resources/pages/pagedata-genshizaikonyusakimaster." + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
    <script src="<%=ResolveUrl("~/Resources/grid/grid.locale-" + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
    <script src="<%=ResolveUrl("~/Resources/systemconst." + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
    <script src="<%=ResolveUrl("~/Scripts/util/app-util.js") %>" type="text/javascript"></script>
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
        
        .part-body .item-list-left li
        {
            float: left;
            width: 240px;
        }

        .search-criteria select
        {
            width: 20em;
        }
        
        .save-confirm-dialog
        {
            background-color: White;
            width: 350px;
        }
        
        .save-confirm-dialog .part-body
        {
            width: 95%;
        }
        
        .search-criteria .item-label
        {
            width: 10em;
        }

        .genshizai-dialog
        {
            background-color: White;
            width: 550px;
        }

        .torihiki-dialog
        {
            background-color: White;
            width: 550px;
        }

        .gram-dialog
        {
            background-color: White;
            width: 480px;
        }

        button.torihiki-button .icon
        {
            background-position: -48px -80px;
        }

        button.gram-button .icon
        {
            background-position: -48px -80px;
        }
        
        button.genshizai-button .icon
        {
            background-position: -48px -80px;
        }
        
        .search-confirm-dialog
        {
            background-color: White;
            width: 350px;
        }
                
        .search-confirm-dialog .part-body
        {
            width: 95%;
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
                searchCondition;

            // 英語化対応　言語によって幅を調節
            $(".search-criteria .item-label").css("width", pageLangText.each_lang_width.number);

            // グリッドコントロール固有の変数宣言
            var grid = $("#item-grid"),
                lastScrollTop = 0,
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
                changeSet = new App.ui.page.changeSet(),
                firstCol = 2,
                duplicateCol = 999,
                currentRow = 0,
                currentCol = firstCol,
                torihikiCodeCol = 3,
                torihikiNameCol = 4,
                wkNonyuCol = 14,
                torihikiCode2Col = 17,
                torihikiName2Col = 18,
                hinCodeCol = 1,
                selectCellNo = 0;
            var kbnTaniHasu;
            // 原資材一覧：品名ダイアログ
            var genshizaiDialog = $(".genshizai-dialog");
            genshizaiDialog.dlg({
                url: "Dialog/HinmeiDialog.aspx",
                name: "HinmeiDialog",
                closed: function (e, data, data2) {
                    if (data == "canceled") {
                        return;
                    }
                    else {
                        // 品名マスタセレクタから取得した原資材名とコードを設定
                        $("#condition-name").text(data2);
                        $("#condition-code").val(data);
                        // 再チェックで背景色とメッセージのリセット
                        $(".part-body .item-list").validation().validate();
                    }
                }
            });

            // 取引先一覧：取引先ダイアログ
            var torihikiDialog = $(".torihiki-dialog");
            torihikiDialog.dlg({
                url: "Dialog/TorihikisakiDialog.aspx",
                name: "TorihikisakiDialog",
                closed: function (e, data, data2) {
                    if (data == "canceled") {
                        return;
                    }
                    else {
                        var selectedRowId = getSelectedRowId(false),
                            nmTorihikiCode = "cd_torihiki",
                            selTorihikiCd = torihikiCodeCol;
                        // ダイアログ起動時に、取引先コード2が選択されていた場合は取引先コード2に設定
                        // 取引先2以外は取引先コードに設定する
                        if (selectCellNo == torihikiCode2Col || selectCellNo == torihikiName2Col) {
                            nmTorihikiCode = "cd_torihiki2";
                            selTorihikiCd = torihikiCode2Col;
                            grid.setCell(selectedRowId, nmTorihikiCode, data);
                            grid.setCell(selectedRowId, "nm_torihiki2", data2);
                        }
                        else {
                            grid.setCell(selectedRowId, nmTorihikiCode, data);
                            grid.setCell(selectedRowId, "nm_torihiki", data2);
                        }
                        // 更新状態の変更データの設定と、更新状態の変更セットに変更データを追加
                        //var changeData = setCreatedChangeData(grid.getRowData(selectedRowId));
                        var changeData = setUpdatedChangeData(grid.getRowData(selectedRowId));
                        changeSet.addUpdated(selectedRowId, nmTorihikiCode, data, changeData);
                        // 再チェックで背景色とメッセージのリセット
                        validateCell(selectedRowId, nmTorihikiCode, grid.getCell(selectedRowId, nmTorihikiCode), selTorihikiCd);
                        // 起動時に選択した方の取引先コードを選択(どちらが選択されたのかわかりづらい為)
                        grid.editCell(selectedRowId, selTorihikiCd, true);
                    }
                }
            });

            // グラム入力：グラム単位入力ダイアログ
            var gramTaniDialog = $(".gram-dialog");
            gramTaniDialog.dlg({
                url: "Dialog/GramTaniDialog.aspx",
                name: "GramTaniDialog",
                closed: function (e, data) {
                    if (data == "canceled") {
                        return;
                    }
                    else {
                        var selectedRowId = getSelectedRowId(false);
                        grid.setCell(selectedRowId, "wt_nonyu", data);
                        // 更新状態の変更セットに変更データを追加
                        var changeData = setCreatedChangeData(grid.getRowData(selectedRowId));
                        changeSet.addUpdated(selectedRowId, "wt_nonyu", data, changeData);
                        // 再チェックで背景色とメッセージのリセット
                        validateCell(selectedRowId, "wt_nonyu", grid.getCell(selectedRowId, "wt_nonyu"), wkNonyuCol);
                    }
                }
            });

            // TODO: ここまで

            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            var hinKubun, // 検索条件のコンボボックス
            // 多言語対応にしたい項目を変数にする
                hinName = 'nm_hinmei_' + App.ui.page.lang,
                conHinName,     // 検索条件の品名(原資材名)
                nonyuTani,      // 納入単位
                initNonyuCode,  // 初期値用の納入単位コード
                initNonyuName,  // 初期値用の納入単位名
                hinmeiInfo,    // 初期値用の品マス情報
                errRows = new Array();   // エラー行の格納用
            // TODO：ここまで

            // ダイアログ固有の変数宣言
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            var saveConfirmDialog = $(".save-confirm-dialog"),
                searchConfirmDialog = $(".search-confirm-dialog");

            // TODO：ここまで

            //// 変数宣言 -- End

            //// コントロール定義 -- Start

            // 取引先ダイアログから値を取得して設定します。
            // DLG呼び出し時、取引先コード2または取引先名2を選択していた場合は取引先コード2へ、
            // 上記以外は取引先コード1へ値を設定する。
            var setTorihikisaki = function (celCode, celName, data) {
                var selectedRowId = getSelectedRowId(false);
                grid.setCell(selectedRowId, celCode, data[0]);
                grid.setCell(selectedRowId, celName, data[1]);
            };

            // ダイアログ固有のコントロール定義
            saveConfirmDialog.dlg();
            searchConfirmDialog.dlg();

            /// レコード件数チェック
            var checkRecordCount = function () {
                recordCount = grid.getGridParam("records");
                // レコードがない場合は処理を抜ける
                if (recordCount == 0) {
                    App.ui.page.notifyInfo.message(pageLangText.noRecords.text).show();
                    return false;
                }
                return true;
            };

            /// 原資材：品名マスタセレクタを起動する
            var showGenshizaiDialog = function () {
                // 行選択。セレクタ起動後に保存などのボタン押下で値がクリアされる不具合の対応。
                var idNum = grid.getGridParam("selrow");
                //$("#" + idNum).removeClass("ui-state-highlight").find("td").click();
                $("#" + idNum + " td:eq('" + (hinCodeCol) + "')").click();

                var option = { id: 'genshizai', multiselect: false, param1: pageLangText.genshizaiJikagenHinDlgParam.text };
                genshizaiDialog.draggable(true);
                genshizaiDialog.dlg("open", option);
            };

            /// 取引先：取引先マスタセレクタを起動する
            var showTorihikiDialog = function () {
                var roles = App.ui.page.user.Roles[0];
                // 権限が「Viewer」以外ならセレクタを起動する
                if (roles != pageLangText.viewer.text) {
                    // 行選択。セレクタ起動後に保存などのボタン押下で値がクリアされる不具合の対応。
                    //var idNum = grid.getGridParam("selrow");
                    //$("#" + idNum).removeClass("ui-state-highlight").find("td").click();
                    //$("#" + idNum + " td:eq('" + (hinCodeCol) + "')").click();
                    saveEdit();

                    var option = { id: 'torihiki', multiselect: false, param1: pageLangText.shiiresakiToriKbn.text };
                    torihikiDialog.draggable(true);
                    torihikiDialog.dlg("open", option);
                }
            };

            /// グラム入力：グラム単位入力セレクタを起動する
            var showGramTaniDialog = function () {
                var roles = App.ui.page.user.Roles[0];
                // 権限が「Viewer」以外ならセレクタを起動する
                if (roles != pageLangText.viewer.text) {
                    // 行選択。セレクタ起動後に保存などのボタン押下で値がクリアされる不具合の対応。
                    var idNum = grid.getGridParam("selrow");
                    //$("#" + idNum).removeClass("ui-state-highlight").find("td").click();
                    $("#" + idNum + " td:eq('" + (hinCodeCol) + "')").click();
                    var wtNonyu = grid.getCell(idNum, "wt_nonyu");

                    var option = { id: 'gram', multiselect: false, param: wtNonyu };
                    gramTaniDialog.draggable(true);
                    gramTaniDialog.dlg("open", option);
                }
            };

            /// <summary>ダイアログを開きます。</summary>
            var showSaveConfirmDialog = function () {
                saveConfirmDialogNotifyInfo.clear();
                saveConfirmDialogNotifyAlert.clear();
                saveConfirmDialog.draggable(true);
                saveConfirmDialog.dlg("open");
            };
            // 検索時のダイアログ
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

            // 日付の多言語対応
            var dateSrcFormat = pageLangText.dateSrcFormatUS.text;
            var newDateFormat = pageLangText.dateNewFormatUS.text;
            if (App.ui.page.langCountry !== 'en-US') {
                dateSrcFormat = pageLangText.dateSrcFormat.text;
                newDateFormat = pageLangText.dateNewFormat.text;
            }

            // グリッドコントロール固有のコントロール定義
            var selectCol;
            grid.jqGrid({
                // TODO：画面の仕様に応じて以下の列名の定義を変更してください。
                colNames: [
                    pageLangText.cd_hinmei.text,
                    pageLangText.no_juni_yusen.text + pageLangText.requiredMark.text,
                    pageLangText.cd_torihiki.text + pageLangText.requiredMark.text,
                    pageLangText.nm_torihiki.text,
                    pageLangText.nm_nisugata_hyoji.text,
                    pageLangText.cd_tani_nonyu.text,
                    pageLangText.tani_nonyu.text + pageLangText.requiredMark.text,
                    pageLangText.cd_tani_nonyu_hasu.text,
                    pageLangText.tani_nonyu_hasu.text + pageLangText.requiredMark.text,
                    pageLangText.tan_nonyu.text + pageLangText.requiredMark.text,
                    pageLangText.tan_nonyu_new.text,
                    pageLangText.dt_tanka_new.text,
                    pageLangText.su_hachu_lot_size.text,
                    pageLangText.wt_nonyu.text + pageLangText.requiredMark.text,
                    pageLangText.su_iri.text + pageLangText.requiredMark.text,
                    pageLangText.su_leadtime.text + pageLangText.requiredMark.text,
                    pageLangText.cd_torihiki2.text,
                    pageLangText.nm_torihiki2.text,
                    pageLangText.flg_mishiyo.text,
                    pageLangText.ts.text
                //'id'
                ],
                // TODO：ここまで
                // TODO：画面の仕様に応じて以下の列モデルの定義を変更してください。
                colModel: [
                    { name: "cd_hinmei", width: 0, hidden: true, hidedlg: true },
                    { name: "no_juni_yusen", width: pageLangText.no_juni_yusen_width.number, editable: true, sorttype: "float", align: "right" },
                    { name: "cd_torihiki", width: pageLangText.cd_torihiki_width.number, editable: true, sorttype: "text" },
                    { name: "nm_torihiki", width: pageLangText.nm_torihiki_width.number, editable: false, sorttype: "text" },
                    { name: "nm_nisugata_hyoji", width: pageLangText.nm_nisugata_hyoji_width.number, editable: true, sorttype: "text" },
                    { name: "cd_tani_nonyu", width: 0, hidden: true, hidedlg: true },
                    { name: "tani_nonyu", width: pageLangText.tani_nonyu_width.number, editable: true, sorttype: "text", edittype: "select",
                        editoptions: {
                            value: function () {
                                // グリッド内のドロップダウンの生成
                                return grid.prepareDropdown(nonyuTani, "nm_tani", "cd_tani");
                            }
                        }
                    },
                    { name: "cd_tani_nonyu_hasu", width: 0, hidden: true, hidedlg: true },
                    { name: "tani_nonyu_hasu", width: pageLangText.tani_nonyu_width.number, hidden: true, hidedlg: true, editable: true, sorttype: "text", edittype: "select",
                        editoptions: {
                            value: function () {
                                if (kbnTaniHasu == pageLangText.kbnTaniHasuShiyo.number) {
                                    // グリッド内のドロップダウンの生成
                                    return grid.prepareDropdown(nonyuTani, "nm_tani", "cd_tani");
                                }
                            }
                        }
                    },
                    { name: "tan_nonyu", width: pageLangText.tan_nonyu_width.number, editable: true, align: "right", sorttype: "float",
                        formatter: "number",
                        formatoptions: {
                            decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 4, defaultValue: ""
                        }
                    },
                    { name: "tan_nonyu_new", width: pageLangText.tan_nonyu_new_width.number, editable: true, align: "right", sorttype: "float",
                        formatter: "number",
                        formatoptions: {
                            decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 4, defaultValue: ""
                        }
                    },
                    { name: "dt_tanka_new", width: pageLangText.dt_tanka_new_width.number, editable: true, sorttype: "text",
                        formatter: "date",
                        formatoptions: {
                            srcformat: dateSrcFormat, newformat: newDateFormat
                        },
                        editoptions: {
                            dataInit: function (el) {
                                var datePickerFormat = pageLangText.dateFormatUS.text;
                                if (App.ui.page.langCountry !== 'en-US') {
                                    datePickerFormat = pageLangText.dateFormat.text;
                                }
                                $(el).on("keyup", App.data.addSlashForDateString);
                                $(el).datepicker({ dateFormat: datePickerFormat
                                    , onClose: function (dateText, inst) {
                                        // カレンダーを閉じた後は他のセルにフォーカスを当てる
                                        // ＃セルの見た目が編集状態のままとなっている為、tabなどでセル移動できそうで紛らわしい
                                        var idNum = grid.getGridParam("selrow");
                                        $("#" + idNum + " td:eq('" + (hinCodeCol) + "')").click();
                                    }
                                });
                            }
                        },
                        unformat: unformatDate
                    },
                    { name: "su_hachu_lot_size", width: pageLangText.su_hachu_lot_size_width.number, editable: true, align: "right", sorttype: "float",
                        formatter: "number",
                        formatoptions: {
                            decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 2, defaultValue: ""
                        }
                    },
                    { name: "wt_nonyu", width: pageLangText.wt_nonyu_width.number, editable: true, align: "right", sorttype: "float",
                        formatter: "number",
                        formatoptions: {
                            decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 6, defaultValue: ""
                        }
                    },
                    { name: "su_iri", width: pageLangText.su_iri_width.number, editable: true, align: "right", sorttype: "float",
                        formatter: "integer",
                        formatoptions: {
                            thousandsSeparator: ",", defaultValue: ""
                        }
                    },
                    { name: "su_leadtime", width: pageLangText.su_leadtime_width.number, editable: true, align: "right", sorttype: "float",
                        formatter: "integer",
                        formatoptions: {
                            thousandsSeparator: ",", defaultValue: ""
                        }
                    },
                    { name: "cd_torihiki2", width: pageLangText.cd_torihiki2_width.number, editable: true, sorttype: "text" },
                    { name: "nm_torihiki2", width: pageLangText.nm_torihiki2_width.number, editable: false, sorttype: "text" },
                    { name: 'flg_mishiyo', width: pageLangText.flg_mishiyo_width.number, editable: true, edittype: 'checkbox', align: 'center',
                        editoptions: { value: "1:0" }, formatter: 'checkbox', formatoptions: { disabled: false }
                    },
                    { name: "ts", width: 0, hidden: true, hidedlg: true }
                //{ name: "id", width: 0, hidden: false, hidedlg: true, key:true }
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
                    // 変数宣言
                    var ids = grid.jqGrid('getDataIDs');

                    for (var i = 0; i < ids.length; i++) {
                        var id = ids[i];
                        // TODO : ここから
                        // 既存行の優先順位は編集不可にする
                        if (grid.jqGrid('getCell', id, 'ts')) {
                            grid.jqGrid('setCell', id, 'no_juni_yusen', '', 'not-editable-cell');
                            // TODO：ここまで
                        }
                    }

                    // グリッドの先頭行選択
                    //if (ids.length > 0) {
                    //    $("#1 td:eq('" + (firstCol) + "')").click();
                    //}
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
                    // Enter キーでカーソルを移動
                    grid.moveCell(cellName, iRow, iCol);
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
                    if(cellName == "tani_nonyu_hasu" && kbnTaniHasu != pageLangText.kbnTaniHasuShiyo.number){
                        return;
                    }
                    // 関連項目の設定
                    setRelatedValue(selectedRowId, cellName, value, iCol);

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
                },
                onCellSelect: function (rowid, icol, cellcontent) {
                    selectCol = icol;
                },
                ondblClickRow: function (rowid) {
                    // 取引先コード、取引先名、取引先コード2、取引先名2
                    if (selectCol === torihikiCodeCol || selectCol === torihikiNameCol
                            || selectCol === torihikiCode2Col || selectCol === torihikiName2Col) {
                        // 取引先一覧を起動する
                        selectCellNo = selectCol;
                        showTorihikiDialog();
                    }

                    // 一個の量
                    if (selectCol === wkNonyuCol) {
                        // グラム入力セレクタを起動する
                        showGramTaniDialog();
                    }
                }
            });

            /// <summary>日付型のセルをunformatします</summary>
            function unformatDate(cellvalue, options) {
                var nbsp = String.fromCharCode(160);
                if (cellvalue == nbsp) {
                    return "";
                }
                return cellvalue;
            }

            /// <summary>セルの関連項目を設定します。</summary>
            /// <param name="selectedRowId">選択行ID</param>
            /// <param name="cellName">列名</param>
            /// <param name="value">元となる項目の値</param>
            /// <param name="iCol">項目の列番号</param>
            var setRelatedValue = function (selectedRowId, cellName, value, iCol) {
                // TODO：画面の仕様に応じて以下の関連項目を設定を変更してください。
                var changeData;

                // 納入単位の設定
                if (cellName === "tani_nonyu") {
                    grid.setCell(selectedRowId, "cd_tani_nonyu", value);
                    // 更新状態の変更セットに変更データを追加
                    changeData = setUpdatedChangeData(grid.getRowData(selectedRowId));
                    changeSet.addUpdated(selectedRowId, "cd_tani_nonyu", value, changeData);
                    // セルバリデーション
                    validateCell(selectedRowId, "cd_tani_nonyu", value, iCol - 1);
                }
                // 納入単位(端数)の設定
                if (cellName === "tani_nonyu_hasu") {
                    grid.setCell(selectedRowId, "cd_tani_nonyu_hasu", value);
                    // 更新状態の変更セットに変更データを追加
                    changeData = setUpdatedChangeData(grid.getRowData(selectedRowId));
                    changeSet.addUpdated(selectedRowId, "cd_tani_nonyu_hasu", value, changeData);
                    // セルバリデーション
                    validateCell(selectedRowId, "cd_tani_nonyu_hasu", value, iCol - 1);
                }
                // 取引先コードから名称を取得する
                if (cellName === "cd_torihiki" || cellName === "cd_torihiki2") {
                    var serviceUrl,
			            elementName = "nm_torihiki",
			            nameCellName,
			            codeName;

                    serviceUrl = "../Services/FoodProcsService.svc/ma_torihiki?$filter=cd_torihiki eq '"
                                + value + "' and kbn_torihiki eq " + pageLangText.shiiresakiToriKbn.text
                                + " and flg_mishiyo eq " + pageLangText.shiyoMishiyoFlg.text + "&$top=1";
                    codeName;
                    if (cellName === "cd_torihiki2") {
                        nameCellName = "nm_torihiki2";
                    }
                    else {
                        nameCellName = "nm_torihiki";
                    }

                    App.deferred.parallel({
                        // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                        codeName: App.ajax.webget(serviceUrl)
                        // TODO: ここまで
                    }).done(function (result) {
                        // TODO: 画面の仕様に応じて以下のサービス呼び出し成功時の処理を変更してください。
                        var row = grid.getRowData(selectedRowId);
                        codeName = result.successes.codeName.d;
                        if (!App.isUndefOrNull(codeName) && codeName.length > 0) {
                            grid.setCell(selectedRowId, nameCellName, codeName[0][elementName]);
                        }
                        else {
                            grid.setCell(selectedRowId, nameCellName, null);
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

            /// 値をyyyy/MM/ddにする
            /// <param name="valDate">変換する値</param>
            var getFormatDate = function (valDate) {
                if (!App.isUndefOrNull(valDate) && valDate != "") {
                    var date = App.data.getDate(valDate);
                    //var formatDate = App.data.getDateString(date, true);
                    var formatDate = App.data.localDate(date, true);
                    return formatDate;
                }
                else {
                    return "";
                }
            };
            /// 納入単位コードから該当の単位名を取得する
            /// <param name="codeVal">納入単位コード</param>
            /// <return>単位名称</return>
            var getTaniName = function (codeVal) {
                var list = nonyuTani,
                    nmTani = "";
                for (var i = 0; i < list.length; i++) {
                    if (list[i].cd_tani == codeVal) {
                        nmTani = list[i].nm_tani;
                        break;
                    }
                }
                return nmTani;
            };
            /// <summary>更新時の同時実行制御エラー時、対象行にDBから取得した値を再設定する。</summary>
            /// <param name="current">対象行</param>
            /// <param name="retCurrent">DBから取得した値</param>
            /// <return>再設定した行情報</return>
            var setCurrentData = function (current, retCurrent) {
                current.cd_torihiki = retCurrent.cd_torihiki;
                current.nm_torihiki = retCurrent.nm_torihiki;
                current.nm_nisugata_hyoji = retCurrent.nm_nisugata_hyoji;
                current.cd_tani_nonyu = retCurrent.cd_tani_nonyu;
                current.tan_nonyu = retCurrent.tan_nonyu;
                current.tan_nonyu_new = retCurrent.tan_nonyu_new;
                current.dt_tanka_new = getFormatDate(retCurrent.dt_tanka_new);
                current.su_hachu_lot_size = retCurrent.su_hachu_lot_size;
                current.wt_nonyu = retCurrent.wt_nonyu;
                current.su_iri = retCurrent.su_iri;
                current.su_leadtime = retCurrent.su_leadtime;
                current.cd_torihiki2 = retCurrent.cd_torihiki2;
                current.nm_torihiki2 = retCurrent.nm_torihiki2;
                current.flg_mishiyo = retCurrent.flg_mishiyo;
                current.ts = retCurrent.ts;
                // 納入単位を取得して設定する
                current.tani_nonyu = getTaniName(current.cd_tani_nonyu);
                current.tani_nonyu_hasu = getTaniName(current.cd_tani_nonyu_hasu);

                return current;
            };

            /// 内部エラーで変えた行の背景色をクリアする
            /// <param name="errIds">対象行のID配列</param>
            var clearErrBgcorror = function (errIds) {
                for (var i = 0; i < errIds.length; i++) {
                    var id = errIds[i];
                    // 対象セルの背景リセット
                    grid.setCell(id, firstCol, '', { background: 'none' });
                    grid.setCell(id, torihikiCodeCol, '', { background: 'none' });
                }
            };

            //// コントロール定義 -- End

            //---------------------------------------------------------
            //2019/07/24 trinh.bd Task #14029
            //------------------------START----------------------------
            //// 操作制御定義 -- Start

            // 操作制御定義を定義します。
            //App.ui.pagedata.operation.applySetting(App.ui.page.user.Roles[0], App.ui.page.lang);
            //// 操作制御定義 -- End
            var kbn_ma_konyusaki = App.ui.page.user.kbn_ma_konyusaki;
            if (kbn_ma_konyusaki == pageLangText.isRoleFisrt.number) {
                App.ui.pagedata.operation.applySetting("isRoleFisrt", App.ui.page.lang);
            }
            else if (kbn_ma_konyusaki == pageLangText.isRoleSecond.number) {
                App.ui.pagedata.operation.applySetting("isRoleSecond", App.ui.page.lang);
            } else {
                App.ui.pagedata.operation.applySetting("NotRole", App.ui.page.lang);
            }
            //------------------------END------------------------------

            //// 事前データロード -- Start 

            // 画面アーキテクチャ共通の事前データロード
            var loading;

            App.deferred.parallel({
                // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                // ローディング
                loading: App.ui.loading.show(pageLangText.nowProgressing.text),
                // 明細の納入単位
                nonyuTani: App.ajax.webget("../Services/FoodProcsService.svc/ma_tani?$filter=flg_mishiyo eq "
                    + pageLangText.shiyoMishiyoFlg.text + "&$orderby=cd_tani"),
                kbnTaniHasu: App.ajax.webget("../Services/FoodProcsService.svc/cn_kino_sentaku?$filter=kbn_kino eq " + pageLangText.kinoTaniHasuKbn.number)
                // TODO: ここまで
            }).done(function (result) {
                // TODO: 画面の仕様に応じて以下のサービス呼び出し成功時の処理を変更してください。
                nonyuTani = result.successes.nonyuTani.d;
                if (result.successes.kbnTaniHasu.d.length == 0) {
                    kbnTaniHasu = 0;
                } else {
                    kbnTaniHasu = result.successes.kbnTaniHasu.d[0].kbn_kino_naiyo;
                }
                if (kbnTaniHasu == pageLangText.kbnTaniHasuShiyo.number) {
                    grid.jqGrid('showCol', "tani_nonyu_hasu");
                    grid.setColProp('tani_nonyu_hasu', { hidedlg: false });
                }
                if (nonyuTani.length > 0) {
                    // 初期値用の納入単位を設定
                    initNonyuCode = nonyuTani[0].cd_tani;
                    initNonyuName = nonyuTani[0].nm_tani;
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
            }).always(function () {
                App.ui.loading.close();
            });

            //// 事前データロード -- End

            //// 検索処理 -- Start

            // 画面アーキテクチャ共通の検索処理

            /// <summary>クエリオブジェクトの設定</summary>
            var query = function () {
                var query = {
                    // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                    url: "../Services/FoodProcsService.svc/vw_ma_konyu_02",
                    // TODO: ここまで
                    filter: createFilter(),
                    // TODO: 画面の仕様に応じて以下のソート条件を変更してください。
                    orderby: "no_juni_yusen",
                    // TODO: ここまで
                    //skip: querySetting.skip,
                    top: querySetting.top,
                    inlinecount: "allpages"
                }
                return query;
            };
            /// <summary>フィルター条件の設定</summary>
            var createFilter = function () {
                var criteria = $(".search-criteria").toJSON(),
                    filters = [],
                    hinmei = $("#condition-name").text();
                //searchCondition = criteria;   // ChromeだとtoJSONでラベルの値を取得できない為
                searchCondition = { cd_hinmei: criteria.cd_hinmei, nm_hinmei: hinmei };

                // TODO: 画面の仕様に応じて以下のフィルター条件を変更してください。
                filters.push("cd_hinmei eq '" + criteria.cd_hinmei + "'");
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
                        pageLangText.nowLoading.text,
                //pageLangText.nowListLoading.text,
                        querySetting.skip + 1,
                        querySetting.top
                    )
                );
                App.ajax.webget(
                // WCF Data ServicesのODataシステムクエリオプションを生成
                    App.data.toODataFormat(query)
                ).done(function (result) {
                    // データバインド
                    bindData(result);
                    // 検索条件を閉じる
                    closeCriteria();
                    $(".ui-jqgrid-hdiv").scrollLeft(0); // 明細のスクロール位置をリセット

                    // 品名マスタ検索
                    searchHinmeiMaster();

                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                    //}).always(function () {
                    //setTimeout(function () {
                    //    $("#list-loading-message").text("");
                    //    isDataLoading = false;
                    //}, 500);
                });
            };
            /// <summary>検索条件を閉じます。</summary>
            var closeCriteria = function () {
                var criteria = $(".search-criteria");
                if (!criteria.find(".part-body").is(":hidden")) {
                    criteria.find(".search-part-toggle").click();
                }
            };
            /// <summary>新規行の初期値用に、品名マスタ情報を取得します。</summary>
            var searchHinmeiMaster = function () {
                var queryMaHin = {
                    url: "../Services/FoodProcsService.svc/vw_ma_hinmei_10",
                    filter: "cd_hinmei eq '" + searchCondition.cd_hinmei + "' "
                        + "and flg_mishiyo_hin eq " + pageLangText.shiyoMishiyoFlg.text,
                    top: 1
                };
                App.ajax.webgetSync(
                    App.data.toODataFormat(queryMaHin)
                ).done(function (result) {
                    if (result.d.length > 0) {
                        hinmeiInfo = result.d[0];
                    }
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                }).always(function () {
                    setTimeout(function () {
                        $("#list-loading-message").text("");
                        isDataLoading = false;
                    }, 500);
                });
            };

            /// <summary>検索ボタンクリック時のイベント処理を行います。</summary>
            var findData = function () {
                closeSearchConfirmDialog();
                clearState();
                // 検索前バリデーション
                var result = $(".part-body .item-list").validation().validate();
                if (result.errors.length) {
                    return;
                }
                searchItems(new query());
            };
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
                //querySetting.skip = querySetting.skip + result.d.results.length;
                querySetting.skip = result.d.results.length;
                querySetting.count = parseInt(result.d.__count);

                // 検索結果が上限数を超えていた場合
                if (querySetting.count > querySetting.top) {
                    App.ui.page.notifyAlert.message(
                        App.str.format(pageLangText.limitOver.text, querySetting.count, querySetting.top)
                    ).show();
                }
                // 上限数チェック：ここまで

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

                // 同時実行制御エラーの場合は取引先コードを選択
                if (info.iCol === duplicateCol) {
                    info.iCol = torihikiCodeCol;
                }

                // セルを選択して入力モードにする
                grid.editCell(iRow, info.iCol, true);
            };

            /// <summary>エラー一覧クリック時のイベント処理を行います。</summary>
            $(App.ui.page.notifyAlert).on("itemselected", function (e, data) {
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

            // 検索時ダイアログ情報メッセージの設定
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
                        App.ui.page.notifyInfo.message(pageLangText.noRecords.text).show();
                    }
                    return;
                }
                // 選択行なしの場合は最終行を選択
                if (App.isUnusable(selectedRowId)) {
                    selectedRowId = ids[recordCount - 1];
                }
                currentRow = $('#' + selectedRowId)[0].rowIndex;

                return selectedRowId;
            };

            /// <summary>新規行データの設定を行います。</summary>
            var setAddData = function () {
                // TODO: 画面の仕様に応じて以下の項目を変更してください。
                var nonyuCd = hinmeiInfo.cd_tani,
                    nonyuNm = hinmeiInfo.nm_tani;
                var nonyuCdHasu = hinmeiInfo.cd_tani_hasu,
                    nonyuNmHasu = hinmeiInfo.nm_tani_hasu;
                if (App.isUndefOrNull(nonyuCd) || App.isUndefOrNull(nonyuNm)) {
                    // 品名マスタの納入単位が単位マスタに存在しないコードだった場合、
                    // 明細/納入単位プルダウンの先頭の値を設定する
                    nonyuCd = initNonyuCode;
                    nonyuNm = initNonyuName;
                }
                if (App.isUndefOrNull(nonyuCdHasu) || App.isUndefOrNull(nonyuNmHasu)) {
                    // 品名マスタの納入単位が単位マスタに存在しないコードだった場合、
                    // 明細/納入単位プルダウンの先頭の値を設定する
                    nonyuCdHasu = initNonyuCode;
                    nonyuNmHasu = initNonyuName;
                }
                var addData = {
                    "cd_hinmei": searchCondition.cd_hinmei,
                    "no_juni_yusen": "",
                    "cd_torihiki": "",
                    "nm_torihiki": "",
                    "cd_torihiki2": "",
                    "nm_torihiki2": "",
                    "nm_nisugata_hyoji": hinmeiInfo.nm_nisugata_hyoji,
                    "cd_tani_nonyu": nonyuCd,
                    "tani_nonyu": nonyuNm,
                    "cd_tani_nonyu_hasu": nonyuCdHasu,
                    "tani_nonyu_hasu": nonyuNmHasu,
                    "tan_nonyu": hinmeiInfo.tan_ko,
                    "wt_nonyu": hinmeiInfo.wt_ko,
                    "su_iri": hinmeiInfo.su_iri,
                    "su_leadtime": hinmeiInfo.dd_leadtime,
                    "su_hachu_lot_size": hinmeiInfo.su_hachu_lot_size,
                    "tan_nonyu_new": 0,
                    "dt_tanka_new": "",
                    "flg_mishiyo": pageLangText.falseFlg.text,
                    "cd_create": App.ui.page.user.Code,
                    "cd_update": App.ui.page.user.Code,
                    "ts": "",
                    "id": App.uuid()
                };
                // TODO: ここまで

                return addData;
            };

            /// <summary>追加状態の変更セットに追加する変更データの設定を行います。</summary>
            /// <param name="newRow">新規行データ</param>
            var setCreatedChangeData = function (newRow) {
                // TODO: 画面の仕様に応じて以下の項目を変更してください。
                var changeData = {
                    "cd_hinmei": newRow.cd_hinmei,
                    "no_juni_yusen": newRow.no_juni_yusen,
                    "cd_torihiki": newRow.cd_torihiki,
                    "cd_torihiki2": newRow.cd_torihiki2,
                    "nm_nisugata_hyoji": newRow.nm_nisugata_hyoji,
                    "cd_tani_nonyu": newRow.cd_tani_nonyu,
                    "tan_nonyu": newRow.tan_nonyu,
                    "wt_nonyu": newRow.wt_nonyu,
                    "su_iri": newRow.su_iri,
                    "su_leadtime": newRow.su_leadtime,
                    "su_hachu_lot_size": newRow.su_hachu_lot_size,
                    "tan_nonyu_new": newRow.tan_nonyu_new,
                    "dt_tanka_new": newRow.dt_tanka_new == "" ? "" : App.data.getDateTimeStringForQueryNoUtc(App.date.localDate(newRow.dt_tanka_new)),
                    "flg_mishiyo": newRow.flg_mishiyo,
                    "cd_create": App.ui.page.user.Code,
                    "cd_update": App.ui.page.user.Code,
                    "ts": newRow.ts,
                    "cd_tani_nonyu_hasu": newRow.cd_tani_nonyu_hasu,
                };
                // TODO: ここまで

                return changeData;
            };
            /// <summary>更新状態の変更セットに追加する変更データの設定を行います。</summary>
            /// <param name="row">選択行</param>
            var setUpdatedChangeData = function (row) {
                // TODO: 画面の仕様に応じて以下の項目を変更してください。
                var changeData = {
                    "cd_hinmei": row.cd_hinmei,
                    "no_juni_yusen": row.no_juni_yusen,
                    "cd_torihiki": row.cd_torihiki,
                    "cd_torihiki2": row.cd_torihiki2,
                    "nm_nisugata_hyoji": row.nm_nisugata_hyoji,
                    "cd_tani_nonyu": row.cd_tani_nonyu,
                    "tan_nonyu": row.tan_nonyu,
                    "wt_nonyu": row.wt_nonyu,
                    "su_iri": row.su_iri,
                    "su_leadtime": row.su_leadtime,
                    "su_hachu_lot_size": row.su_hachu_lot_size,
                    "tan_nonyu_new": row.tan_nonyu_new,
                    "dt_tanka_new": row.dt_tanka_new == "" ? "" : App.data.getDateTimeStringForQueryNoUtc(App.date.localDate(row.dt_tanka_new)),
                    "flg_mishiyo": row.flg_mishiyo,
                    "cd_update": App.ui.page.user.Code,
                    "ts": row.ts,
                    "cd_tani_nonyu_hasu": row.cd_tani_nonyu_hasu,
                };
                // TODO: ここまで

                return changeData;
            };
            /// <summary>削除状態の変更セットに追加する変更データの設定を行います。</summary>
            /// <param name="row">選択行</param>
            var setDeletedChangeData = function (row) {
                // TODO: 画面の仕様に応じて以下の項目を変更してください。
                var changeData = {
                    "cd_hinmei": row.cd_hinmei,
                    "no_juni_yusen": row.no_juni_yusen,
                    "cd_torihiki": row.cd_torihiki,
                    "ts": row.ts
                };
                // TODO: ここまで

                return changeData;
            };

            /// <summary>関連項目の設定を変更セットに反映します。</summary>
            /// <param name="selectedRowId">選択行ID</param>
            /// <param name="cellName">列名</param>
            /// <param name="value">元となる項目の値</param>
            //var setRelatedChangeData = function (selectedRowId, cellName, value, changeData) {
            // TODO: 画面の仕様に応じて以下の処理を変更してください。
            //    if (cellName === "ArticleName") {
            //changeSet.addUpdated(selectedRowId, "cd_hinmei", value, changeData);
            //    }
            // TODO: ここまで
            //};

            /// <summary>新規行を追加します。</summary>
            /// <param name="e">イベントデータ</param>
            var addData = function (e) {
                ///// チェック処理
                var criteria = $(".search-criteria").toJSON();
                // 正しい原資材コードが入力されていること
                // 検索後の原資材名があるということはマスタに存在するコードである
                if (App.isUndefOrNull(searchCondition) || App.isUndefOrNull(searchCondition.nm_hinmei)) {
                    App.ui.page.notifyAlert.clear();
                    App.ui.page.notifyAlert.message(pageLangText.searchBefore.text).show();
                    return;
                }
                // 検索条件が変更されていないこと
                if (criteria.cd_hinmei != searchCondition.cd_hinmei) {
                    App.ui.page.notifyAlert.clear();
                    App.ui.page.notifyAlert.message(pageLangText.changeCondition.text).show();
                    return;
                }
                // 明細行数が最大値未満であること
                if (grid.getGridParam("records") >= querySetting.top) {
                    App.ui.page.notifyAlert.clear();
                    App.ui.page.notifyAlert.message(pageLangText.addRecordMax.text).show();
                    return;
                };

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
            $(".add-button").on("click", function () {
                // 行選択。セレクタ起動後に保存などのボタン押下で値がクリアされる不具合の対応。
                var idNum = grid.getGridParam("selrow");
                $("#" + idNum + " td:eq('" + (hinCodeCol) + "')").click();

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
                // 削除状態の変更セットに変更データを追加
                changeSet.addDeleted(selectedRowId, changeData);
                // 選択行の行データ削除
                grid.delRowData(selectedRowId);
                if (grid.getGridParam("records") > 0) {
                    // セルを選択する
                    //grid.editCell(currentRow === 1 ? currentRow : currentRow - 1, currentCol, true);
                    grid.editCell(currentRow === 1 ? currentRow : currentRow - 1, firstCol, true);
                }
            };
            /// <summary>削除ボタンクリック時のイベント処理を行います。</summary>
            $(".delete-button").on("click", deleteData);

            //// データ変更処理 -- End

            //// 保存処理 -- Start

            // グリッドコントロール固有の保存処理

            // <summary>データに変更がないかどうかを返します。</summary>
            var noChange = function () {
                return (App.isUnusable(changeSet) || changeSet.noChange());
            };
            // <summary>検索条件に変更がないかどうかを返します。</summary>
            var changeCondition = function () {
                var criteria = $(".search-criteria").toJSON();
                if (criteria.cd_hinmei != searchCondition.cd_hinmei) {
                    return true;
                }
                return false;
            };
            // <summary>新単価と新単価切替日の相関チェック結果を返します。</summary>
            var compNewTanka = function (rowId) {
                var newTanka = grid.getCell(rowId, "tan_nonyu_new"),
                        newTankaDate = grid.getCell(rowId, "dt_tanka_new");

                // 新単価に入力があり、新単価切替日の入力がない場合はエラー
                if (newTanka > 0 && newTankaDate.length == 0) {
                    App.ui.page.notifyAlert.message(
                             App.str.format(pageLangText.compNewTanka.text,
                                pageLangText.tan_nonyu_new.text, pageLangText.dt_tanka_new.text)
                        ).show();
                    grid.setCell(rowId, "dt_tanka_new", newTankaDate, { background: '#ff6666' });
                    return false;
                }
                else {
                    grid.setCell(rowId, "dt_tanka_new", newTankaDate, { background: 'none' });
                }

                // 新単価切替日に入力があり、新単価の入力がない場合はエラー
                if (newTankaDate.length > 0 && newTanka.length == 0) {
                    App.ui.page.notifyAlert.message(
                             App.str.format(pageLangText.compNewTanka.text,
                                pageLangText.dt_tanka_new.text, pageLangText.tan_nonyu_new.text)
                        ).show();
                    grid.setCell(rowId, "tan_nonyu_new", newTanka, { background: '#ff6666' });
                    return false;
                }
                else {
                    grid.setCell(rowId, "tan_nonyu_new", newTanka, { background: 'none' });
                }
                return true;
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
                    retValue,
                    unique,
                    current,
                // TODO: 画面の仕様に応じて以下の変数を変更します。
                    checkColYusenNo = 2,    // 優先順位
                    checkColTorihiki = 3,   // 取引先コード
                    checkColNonyuTani = 7;   // 納入単位
                // TODO: ここまで

                // データ整合性エラーのハンドリングを行います。
                if (App.isArray(ret) && ret.length > 0) {
                    for (var i = 0; i < ret.length; i++) {
                        // TODO: 画面の仕様に応じて以下の値を変更します。
                        if (ret[i].InvalidationName === "DuplicateKey") {
                            // TODO: ここまで

                            for (var j = 0; j < ids.length; j++) {
                                // TODO: 画面の仕様に応じて以下の値を変更します。
                                value = grid.getCell(ids[j], checkColYusenNo);
                                retValue = ret[i].Data.no_juni_yusen;
                                // TODO: ここまで

                                if (value == retValue) {
                                    // TODO: 画面の仕様に応じて以下のロジックを変更します。
                                    unique = ids[j] + "_" + firstCol;
                                    // エラー行を追加
                                    errRows.push(ids[j]);

                                    // エラーメッセージの表示
                                    App.ui.page.notifyAlert.message(
                                            pageLangText.invalidation.text + ret[i].Message, unique).show();
                                    // 対象セルの背景変更
                                    grid.setCell(ids[j], checkColYusenNo, retValue, { background: '#ff6666' });
                                }
                                // TODO: ここまで
                            }
                        }
                        else if (ret[i].InvalidationName === "DuplicateItem") {
                            // TODO: ここまで

                            for (var j = 0; j < ids.length; j++) {
                                // TODO: 画面の仕様に応じて以下の値を変更します。
                                value = grid.getCell(ids[j], checkColTorihiki);
                                retValue = ret[i].Data.cd_torihiki;
                                // TODO: ここまで

                                // TODO: 画面の仕様に応じて以下のロジックを変更します。
                                if (value == retValue) {
                                    unique = ids[j] + "_" + checkColTorihiki;
                                    // エラー行を追加
                                    errRows.push(ids[j]);

                                    // エラーメッセージの表示
                                    App.ui.page.notifyAlert.message(
                                            pageLangText.invalidation.text + ret[i].Message, unique).show();
                                    // 対象セルの背景変更
                                    grid.setCell(ids[j], checkColTorihiki, retValue, { background: '#ff6666' });
                                }
                                // TODO: ここまで
                            }
                        }
                        else if (ret[i].InvalidationName === "NotExsists") {
                            // TODO: ここまで

                            for (var j = 0; j < ids.length; j++) {
                                // TODO: 画面の仕様に応じて以下の値を変更します。
                                value = grid.getCell(ids[j], firstCol);
                                retValue = ret[i].Data.no_juni_yusen;
                                // TODO: ここまで

                                // TODO: 画面の仕様に応じて以下のロジックを変更します。
                                if (value == retValue) {
                                    unique = ids[j] + "_" + checkColNonyuTani;
                                    // エラーメッセージの表示
                                    App.ui.page.notifyAlert.message(
                                            pageLangText.invalidation.text + ret[i].Message, unique).show();
                                    // 対象セルの背景変更(コードではなく名称の背景を変更する)
                                    grid.setCell(ids[j], checkColNonyuTani, "", { background: '#ff6666' });
                                }
                                // TODO: ここまで
                            }
                        }
                        else {
                            // 更新オブジェクトから削除を行う
                            for (p in changeSet.changeSet.deleted) {
                                if (!changeSet.changeSet.deleted.hasOwnProperty(p)) {
                                    continue;
                                }

                                // TODO: 画面の仕様に応じて以下の値を変更します。
                                value = parseInt(changeSet.changeSet.deleted[p].no_juni_yusen, 10)
                                retValue = ret[i].Data.no_juni_yusen;
                                // TODO: ここまで

                                if (isNaN(value) || value === retValue) {
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
                            value = grid.getCell(p, checkColYusenNo);
                            retValue = ret.Updated[i].Requested.no_juni_yusen;
                            // TODO: ここまで

                            if (value == retValue) {
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
                                    var upCur = grid.getRowData(p),
                                        upRetCur = ret.Updated[i].Current;
                                    current = setCurrentData(upCur, upRetCur);
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
                            value = parseInt(changeSet.changeSet.deleted[p].no_seq, 10)
                            retValue = ret.Deleted[i].Requested.ts;
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
                                    unique = p + "_" + duplicateCol;

                                    // TODO: 画面の仕様に応じて以下の値を変更します。
                                    var delCur = grid.getRowData(p),
                                        delRetCur = ret.Deleted[i].Current;
                                    current = setCurrentData(delCur, delRetCur);
                                    // TODO: ここまで

                                    // 対象行の更新
                                    grid.setRowData(p, current);
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
                // 確認ダイアログのクローズ
                closeSaveConfirmDialog();
                // 情報メッセージのクリア
                App.ui.page.notifyInfo.clear();
                // ローディングの表示
                App.ui.loading.show(pageLangText.nowSaving.text);

                // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                var saveUrl = "../api/GenshizaiKonyusakiMaster";
                // TODO: ここまで

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
                    App.ui.loading.close();
                });
            };
            /// <summary>保存前チェック</summary>
            var checkSave = function () {
                // 内部エラーになった行の背景色をすべてリセット
                clearErrBgcorror(errRows);

                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();
                // エラー行格納変数のクリア
                errRows = new Array();

                // チェック処理
                /*
                //明細が0件の場合は処理を抜ける
                var inputRow = grid.jqGrid("getGridParam", "selrow")
                if (App.isUnusable(inputRow)) {
                App.ui.page.notifyAlert.message(pageLangText.noSelect.text).show();
                App.ui.loading.close();
                return;
                }
                */
                // 変更セット内にバリデーションエラーがある場合は処理を抜ける
                if (!validateChangeSet()) {
                    App.ui.loading.close();
                    return;
                }
                // 検索条件が変更されている場合は処理を抜ける
                if (changeCondition()) {
                    App.ui.page.notifyInfo.message(pageLangText.changeCondition.text).show();
                    App.ui.loading.close();
                    return;
                }
                // 変更がない場合は処理を抜ける
                if (noChange()) {
                    App.ui.page.notifyInfo.message(pageLangText.noChange.text).show();
                    App.ui.loading.close();
                    return;
                }
                else {
                    // チェックがすべて終わってからローディング表示を終了させる
                    App.ui.loading.close();
                }

                // 保存時ダイアログを開く
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

            //// 保存処理 -- End

            //// バリデーション -- Start

            // グリッドコントロール固有のバリデーション

            // TODO: 画面の仕様に応じて以下のカスタムバリデーション定義を変更してください。

            /// <summary>データベース問い合わせチェックを行います。</summary>
            /// <param name="value">取引先コード</param>
            var isValidArticleCD = function (value) {
                var isValid = true;

                if (App.isUndefOrNull(value)
                    || value.length === 0) {
                    return isValid;
                }

                var _query = {
                    url: "../Services/FoodProcsService.svc/ma_torihiki",
                    filter: "cd_torihiki eq '" + value + "'"
                        + " and kbn_torihiki eq " + pageLangText.shiiresakiToriKbn.text
                        + " and flg_mishiyo eq " + pageLangText.shiyoMishiyoFlg.text,
                    top: 1
                }
                App.ajax.webgetSync(
                    App.data.toODataFormat(_query)
                ).done(function (result) {
                    // サービス呼び出し成功時の処理
                    if (result.d.length == 0) {
                        isValid = false;
                    }
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                });
                return isValid;
            };

            /// <summary>原資材名を取得します。(マスタ存在チェック)</summary>
            /// <param name="cdHinmei">原資材コード</param>
            var isValidHinCode = function (cdHinmei) {
                var isValid = true,
                    query = {
                        url: "../Services/FoodProcsService.svc/ma_hinmei",
                        filter: "cd_hinmei eq '" + cdHinmei +
                                "' and (kbn_hin eq " + pageLangText.genryoHinKbn.text +
                                " or kbn_hin eq " + pageLangText.shizaiHinKbn.text +
                                " or kbn_hin eq " + pageLangText.jikaGenryoHinKbn.text +
                                ") and flg_mishiyo eq " + pageLangText.shiyoMishiyoFlg.text,
                        top: 1
                    };
                // 品名コードが未入力の場合はチェックを行わない
                if (App.isUndefOrNull(cdHinmei)
                    || cdHinmei.length === 0) {
                    return isValid;
                }

                // 品名マスタ存在チェック
                App.ajax.webgetSync(
                    App.data.toODataFormat(query)
                ).done(function (result) {
                    if (result.d.length === 0) {
                        // 検索結果件数が0件の場合

                        // 品名マスタ存在チェックエラー
                        $("#condition-name").text("");
                        isValid = false;
                    }
                    else {
                        // 検索結果が取得できた場合

                        // 検索条件/品名に取得した原資材名を設定
                        var nmHin = result.d[0][hinName];
                        $("#condition-name").text(nmHin ? nmHin : "");
                    }
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                });
                return isValid;
            };
            // 原資材コードからフォーカスを外したタイミングで名称取得処理を行う
            validationSetting.cd_hinmei.rules.custom = function (value) {
                return isValidHinCode(value);
            };

            validationSetting.cd_torihiki.rules.custom = function (value) {
                return isValidArticleCD(value);
            };
            validationSetting.cd_torihiki2.rules.custom = function (value) {
                return isValidArticleCD(value);
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
                    // 新単価と新単価切替日の相関チェックを実行
                    if (!compNewTanka(p)) {
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
                    // 新単価と新単価切替日の相関チェックを実行
                    if (!compNewTanka(p)) {
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
                    // F3の処理
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

            /// <summary>検索確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".search-confirm-dialog .dlg-yes-button").on("click", findData);

            // <summary>検索確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".search-confirm-dialog .dlg-no-button").on("click", closeSearchConfirmDialog);

            /// <summary>データに変更があり、未保存の状態でページを離れる際に確認を行います。</summary>
            //別画面に遷移したりするときに実行する関数の定義
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

            /// 検索条件/原資材のイベント処理を行います。
            $("#condition-code").dblclick(function () {
                // ダブルクリック時：品名ダイアログを開く
                showGenshizaiDialog();
            })
            .change(function () {
                // 値変更字：空の場合、原資材名を空白にする
                var hinCode = $("#condition-code").val();
                if (hinCode == "") {
                    $("#condition-name").text("");
                }
            });

            /// <summary>チェックボックス操作時のグリッド値更新を行います</summary>
            $(document).on("click", "#item-grid .jqgrow td :checkbox", function () {
                // 参考：iRowにて記述する場合
                var iCol = $(this).parent("td").parent("tr").find("td").index($(this).parent("td")),
                    selectedRowId = $(this).parent("td").parent("tr").attr("id"),
                    cellName = grid.getGridParam("colModel")[iCol].name,
                    value;
                saveEdit();

                // 更新状態の変更データの設定
                var changeData = setUpdatedChangeData(grid.getRowData(selectedRowId));

                // TODO：画面の仕様に応じて以下の定義を変更してください。
                value = changeData[cellName];
                // TODO：ここまで

                // 更新状態の変更セットに変更データを追加
                changeSet.addUpdated(selectedRowId, cellName, value, changeData);
            });

            /// <summary>原資材検索ボタンクリック時のイベント処理を行います。</summary>
            $(".genshizai-button").on("click", function (e) {
                showGenshizaiDialog();
            });

            /// <summary>取引先一覧ボタンクリック時のイベント処理を行います。</summary>
            $(".torihiki-button").on("click", function (e) {
                if (!checkRecordCount()) {
                    return;
                }
                selectCellNo = selectCol;
                showTorihikiDialog();
            });

            /// <summary>グラム入力ボタンクリック時のイベント処理を行います。</summary>
            $(".gram-button").on("click", function (e) {
                if (!checkRecordCount()) {
                    return;
                }
                showGramTaniDialog();
            });

            /// <summary>ダウンロードボタンクリック時のオーバレイ処理を行います。</summary>
            var downloadOverlay = function () {
                //App.ui.loading.show(pageLangText.nowProgressing.text);
                printExcel();
                //App.ui.loading.close();
            };
            /// <summary>Excelファイル出力を行います。</summary>
            var printExcel = function (e) {
                var criteria = $(".search-criteria").toJSON(),
                    filterStr = "cd_hinmei eq '" + criteria.cd_hinmei + "'";

                // 原資材コードが入力されていなかった場合、品区分を原料と資材で絞って全件取得する
                if (App.isUndefOrNull(criteria.cd_hinmei)) {
                    filterStr = "kbn_hin eq " + pageLangText.genryoHinKbn.text
                            + " or kbn_hin eq " + pageLangText.shizaiHinKbn.text;
                }

                var query = {
                    // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                    url: "../api/GenshizaiKonyusakiMasterExcel",
                    // TODO: ここまで
                    filter: filterStr,
                    // TODO: 画面の仕様に応じて以下のソート条件を変更してください。
                    orderby: "cd_hinmei, no_juni_yusen"
                    // TODO: ここまで
                };
                // 処理中を表示する
                App.ui.loading.show(pageLangText.nowProgressing.text);

                var hinCode = $("#condition-code").val(),
                    hinName = encodeURIComponent($("#condition-name").text());

                var url = App.data.toODataFormat(query);
                // 必要な情報をURLに設定
                url = url + "&lang=" + App.ui.page.lang + "&hinCode=" + hinCode + "&hinName=" + hinName
                    + "&userName=" + encodeURIComponent(App.ui.page.user.Name) + "&today=" + App.data.getDateTimeStringForQuery(new Date(), true);
                window.open(url, '_parent');
                // Cookieを監視する
                onComplete();
            };
            /// <summary>Excelボタンクリック時のイベント処理を行います。</summary>
            $(".excel-button").on("click", function () {
                // 情報メッセージのクリア
                App.ui.page.notifyInfo.clear();
                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();
                // 明細があるかどうかをチェックし、無い場合は処理を中止します。
                if (querySetting.count == 0) {
                    App.ui.page.notifyInfo.message(pageLangText.noRecords.text).show();
                    return;
                }
                // 検索条件が変更されている場合は処理を抜ける
                if (changeCondition()) {
                    App.ui.page.notifyInfo.message(pageLangText.changeCondition.text).show();
                    return;
                }
                // 編集内容の保存
                saveEdit();

                //// 出力前チェック ////
                // 明細に変更がないこと
                if (!noChange()) {
                    App.ui.page.notifyInfo.message(pageLangText.excelChangeMeisai.text).show();
                    return;
                }

                // 出力処理へ
                downloadOverlay();
            });

            /// <summary>メニューボタンクリック時のイベント処理を行います。</summary>
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

            //Cookieを1秒ごとにチェックする
            var onComplete = function () {
                if (app_util.prototype.getCookieValue(pageLangText.genshizaiKonyusakiMasterCookie.text) == pageLangText.checkCookie.text) {
                    app_util.prototype.deleteCookie(pageLangText.genshizaiKonyusakiMasterCookie.text);
                    //ローディング終了
                    App.ui.loading.close();
                }
                else {
                    // 再起してCookieが作成されたか監視
                    setTimeout(onComplete, 1000);
                }
            };


            // 品名マスタ画面から遷移してきたときの処理
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
				/* 2022/29/03 - 22094: -START FP-Lite ChromeBrowser Modify */
                var isValid = true,
                     query = {
                         url: "../Services/FoodProcsService.svc/ma_hinmei",
                         filter: "cd_hinmei eq '" + pamameters.cdHin + "'",
                         top: 1,
                         select: "nm_hinmei_en, nm_hinmei_zh, nm_hinmei_vi"
                     };
                App.ajax.webgetSync(
                    App.data.toODataFormat(query)
                ).done(function (result) {
                    if (result.d.length === 0) {
                        $("#condition-name").text("");
                    }
                    else {
                        pamameters.nmHin = result.d[0][hinName];
                    }
                });
				/* 2022/29/03 - 22094: -END FP-Lite ChromeBrowser Modify */
                return pamameters;
            };

            // urlよりパラメーターを取得
            var parameters = getParameters();
            var paramCode = parameters["cdHin"];
            var paramName = parameters["nmHin"];
            if (!App.isUndefOrNull(paramCode)) {
                $("#condition-code").val(paramCode);
                if (!App.isUndefOrNull(paramName)) {
                    $("#condition-name").text(paramName);
                }
                // パラメーターを条件に検索処理を行う
                //findData();
            }
            // 品名マスタ画面から遷移してきたときの処理：ここまで
        });
    </script>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <!-- 画面デザイン -- Start -->

    <!-- 検索条件と検索ボタン -->
    <div class="content-part search-criteria">
        <h3 class="part-header" data-app-text="searchCriteria"><a class="search-part-toggle" href="#"></a></h3>
        <div class="part-body">
            <ul class="item-list item-list-right item-command">
                <li>
                    <label>
                        <span class="item-label" data-app-text="cd_hinmei"></span>
                        <input type="text" name="cd_hinmei" id="condition-code" maxlength="14" style="width: 110px;" />
                    </label>
                    <label>
                        <button type="button" class="genshizai-button" name="genshizai-button"><span class="icon"></span><span data-app-text="genshizaiIchiran"></span></button>
                    </label>
                    <label>
                        <!--<span class="item-label" style="width: 80px;">&nbsp;</span>-->
                        <span class="item-label" data-app-text="nm_hinmei" style="margin-left: 20px;"></span>
                        <!-- input type="text" class="readonly-txt" name="hinName" id="condition-name" readonly="readonly" style="width: 300px;" / -->
                        <span id="condition-name" style="width: 300px"></span>
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
                <button type="button" class="torihiki-button" name="torihiki-button" data-app-operation="torihikiIchiran"><span class="icon"></span><span data-app-text="torihikiIchiran"></span></button>
                <button type="button" class="gram-button" name="gram-button" data-app-operation="gram"><span class="icon"></span><span data-app-text="gramNyuryoku"></span></button>
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
        <button type="button" class="excel-button" name="excel-button" data-app-operation="excel">
            <!--<span class="icon"></span>-->
            <span data-app-text="excel"></span>
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
    <div class="genshizai-dialog">
    </div>
    <div class="torihiki-dialog">
    </div>
    <div class="gram-dialog">
    </div>
    <!-- TODO: ここまで  -->

    <!-- 画面デザイン -- End -->
</asp:Content>
