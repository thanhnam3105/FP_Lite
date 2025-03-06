<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
	CodeBehind="SeizoNippo.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.SeizoNippo" %>

<asp:Content ID="Content1" ContentPlaceHolderID="IncludeContent" runat="server">
	<script src="<%=ResolveUrl("~/Resources/pages/pagedata-seizonippo." + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
		type="text/javascript"></script>
	<script src="<%=ResolveUrl("~/Resources/grid/grid.locale-" + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
		type="text/javascript"></script>
    <script src="<%=ResolveUrl("~/Scripts/util/app-util.js") %>" type="text/javascript"></script>
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
		
		.hinmei-dialog
		{
			background-color: White;
			width: 550px;
		}
		
		.seizoLine-dialog
		{
			background-color: White;
			width: 550px;
		}
        button.add-button
        {
            width: 80px;
        }
        button.delete-button
        {
            width: 80px;
        }
		
		button.hinmei-button .icon
		{
			background-position: -48px -80px;
		}
		
		button.line-button .icon
		{
			background-position: -48px -80px;
		}

        button.reflect-button .icon
        {
            background-position: -48px -80px;
        }
        
        .delete-confirm-dialog,
        .confirm-dialog
        {
            background-color: White;
            width: 350px;
        }
                
        .delete-confirm-dialog .part-body,
        .confirm-dialog .part-body
        {
            width: 95%;
            padding-bottom: 5px;
        }
        .confirm-delete-tracing-dialog
        {
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
	        subGrid対応でjqGridの共通イベントを上書きます。
	        subGridは主明細の行(HTMLタグのtr)にgridを作成している(grid as subgrid)。
	        iRow:HTMLのtrタグ単位の行番号がセットされている。
	        主明細が2行でもその間にsubGridがある場合、主明細の2行目のiRowは3となる。
	        $t.rows:HTMLのtrタグ単位でオブジェクトを保持している。iRowと同様の仕様。
	        getDataIDs関数:指定したgridの行IDを配列で返すjqGridの共通関数。
	        grid単位のため、間にsubGridがある場合でも要素の数は変わらない。
	        HTMLのtrタグ単位であるiRowと連動しない。
	        */
	        jQuery.jgrid.extend({
	            // <summary>編集可能な次のセルを検索し、移動する</summary>
	            moveNextEditable: function (iRow, iCol) {
	                return this.each(function () {
	                    var $t = this,
	                        nCol = false,
	                        subGridCnt = 0,
	                        rowId;

	                    for (var i = iRow; i < $t.rows.length; i++) {
	                        //rowId = $($t).jqGrid("getDataIDs")[i - 1];
	                        rowId = $t.rows[i].id;

	                        if (!$t.grid || $t.p.cellEdit !== true) { return; }
	                        if (rowId === "") { continue; }

	                        // 同じ行で編集可能な次のセルを検索する
	                        for (var j = iCol + 1; j < $t.p.colModel.length; j++) {
	                            if ($t.p.colModel[j].editable === true && $t.p.colModel[j].hidden === false
	                                && !$("#" + rowId + " td:eq(" + j + ")").hasClass("not-editable-cell")) {
	                                nCol = j; break;
	                            }
	                        }
	                        if (nCol !== false) {
	                            // 同じ行で編集可能な次のセルがある場合、次のセルに移動する
	                            $($t).jqGrid("editCell", i, nCol, true);
	                            return;
	                        } else {
	                            // 同じ行で編集可能な次のセルがない場合、次の行の編集可能な先頭セルに移動する
	                            iCol = 0;
	                        }
	                    }
	                });
	            },
	            // <summary>編集可能な前のセルを検索し、移動する</summary>
	            movePrevEditable: function (iRow, iCol) {
	                return this.each(function () {
	                    var $t = this,
                            nCol = false,
                            subGridCnt = 0,
                            rowId;

	                    for (var i = iRow; i > 0; i--) {
	                        //rowId = $($t).jqGrid("getDataIDs")[i - 1];
	                        rowId = $t.rows[i].id;

	                        if (!$t.grid || $t.p.cellEdit !== true) { return; }
	                        if (rowId === "") { continue; }

	                        // 同じ行で編集可能な前のセルを検索する
	                        for (var j = iCol - 1; j >= 0; j--) {
	                            if ($t.p.colModel[j].editable === true && $t.p.colModel[j].hidden === false
                                    && !$("#" + rowId + " td:eq(" + j + ")").hasClass("not-editable-cell")) {
	                                nCol = j; break;
	                            }
	                        }
	                        if (nCol !== false) {
	                            // 同じ行で編集可能な前のセルがある場合、前のセルに移動する
	                            $($t).jqGrid("editCell", i, nCol, true);
	                            return;
	                        } else {
	                            // 同じ行で編集可能な前のセルがない場合、前の行の編集可能な最終セルに移動する
	                            iCol = $t.p.colModel.length;
	                        }
	                    }
	                });
	            },
	            // <summary>次のセルへ移動する</summary>
	            moveNextCell: function (iRow, iCol) {
	                return this.each(function () {
	                    var $t = this,
                            nCol = false,
                            rowId;
	                    for (var i = iRow; i < $t.rows.length; i++) {
	                        //rowId = $($t).jqGrid("getDataIDs")[i - 1];
	                        rowId = $t.rows[i].id;
	                        if (!$t.grid || $t.p.cellEdit !== true) {
	                            return;
	                        }
	                        if (rowId === "") { continue; }

	                        // 同じ行で編集可能な次のセルを検索する
	                        for (var j = iCol + 1; j < $t.p.colModel.length; j++) {
	                            nCol = j;
	                            break;
	                        }
	                        if (nCol !== false) {
	                            //$("#" + iRow + " td:eq('" + (iCol + 1) + "')").click();
	                            $("#" + rowId + " td:eq('" + (iCol + 1) + "')").click();
	                            return;
	                        }
	                        else {
	                            // 同じ行で編集可能な次のセルがない場合、次の行の編集可能な先頭セルに移動する
	                            iCol = 0;
	                        }
	                    }
	                });
	            },
	            // <summary>前のセルへ移動する</summary>
	            movePrevCell: function (iRow, iCol) {
	                return this.each(function () {
	                    var $t = this,
                            nCol = false,
                            rowId;
	                    for (var i = iRow; i > 0; i--) {
	                        //rowId = $($t).jqGrid("getDataIDs")[i - 1];
	                        rowId = $t.rows[i].id;
	                        if (!$t.grid || $t.p.cellEdit !== true) {
	                            return;
	                        }
	                        if (rowId === "") { continue; }

	                        // 同じ行で編集可能な前のセルを検索する
	                        for (var j = iCol - 1; j >= 0; j--) {
	                            nCol = j;
	                            break;
	                        }
	                        if (nCol !== false) {
	                            //$("#" + iRow + " td:eq('" + (iCol + 1) + "')").click();
	                            $("#" + rowId + " td:eq('" + (iCol + 1) + "')").click();
	                            return;
	                        }
	                        else {
	                            // 同じ行で編集可能な前のセルがない場合、前の行の編集可能な最終セルに移動する
	                            iCol = $t.p.colModel.length;
	                        }
	                    }
	                });
	            }
	        });

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
                querySetting = { skip: 0, top: pageLangText.topCount.text, count: 0 },
                isDataLoading = false,
                isSearch = false, // 検索フラグ
                isCriteriaChange = false,   // 検索条件変更フラグ
                userRoles = App.ui.page.user.Roles[0]; // ログインユーザー権限

	        // グリッドコントロール固有の変数宣言
	        var grid = $("#item-grid"),
                lastScrollTop = 0,
	        // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
                changeSet = new App.ui.page.changeSet(),
                firstCol = 2,
                duplicateCol = 999,
                currentRow = 0,
                currentCol = firstCol,
	        //    hinCodeCol = 3,
	        //    lineCodeCol = 4,
	        //    seizoJitsuSuCol = 7,
	        //    shomiCol = 8,
	        //    seihinLotCol = 9,
	        //    noLotHyojiCol = 18,
	        //    batchCol = 19,
	            bairitsuCol = 23,
	        //    reflectChkCol = 27,
                isMishiyo = false, // 明細内の未使用データの有無を示すフラグ
                checkButtonStatus = pageLangText.falseFlg.text, // 全チェック機能用、チェックボックスのステータス
                nm_hinmeiName = "nm_hinmei_" + App.ui.page.lang, // 品名多言語対応
                checkedRow = new Array();
	        var kbnShomi = 0;        // 明細/賞味期限チェック切替
	        var isAutoCalcShomiDate = 0; // 明細/賞味期限の自動計算フラグ
	        var preRowId = undefined;

	        // 内訳用の変数宣言
	        var subGridChangeSet = new App.ui.page.changeSet();

	        // TODO: ここまで

	        // TODO: 画面固有の変数宣言
	        var hinDialogParam = pageLangText.seihinJikagenHinDlgParam.text,
                isLineSelect = false,
                searchCriteriaSet;
	        var confirmId = "";
	        // TODO: ここまで

	        // ダイアログ固有の変数宣言
	        var hinmeiDialog = $(".hinmei-dialog"),
                seizoLineDialog = $(".seizoLine-dialog"),
                saveConfirmDialog = $(".save-confirm-dialog"),
                findConfirmDialog = $(".find-confirm-dialog"),
                deleteConfirmDialog = $(".delete-confirm-dialog"),
                confirmDialog = $(".confirm-dialog"),
	            confirmDeleteTracingDialog = $(".confirm-delete-tracing-dialog");

	        //// 変数宣言 -- End

	        //// コントロール定義 -- Start

	        /// ダイアログ固有のコントロール定義 -- Start

	        // 品名ダイアログ定義
	        hinmeiDialog.dlg({
	            url: "Dialog/HinmeiDialog.aspx",
	            name: "HinmeiDialog",
	            closed: function (e, data, data2) {
	                // エラーメッセージを削除
	                App.ui.page.notifyAlert.clear();
	                if (data == "canceled") {
	                    return;
	                }
	                else {
	                    var selectedRowId = getSelectedRowId(false);
	                    grid.setCell(selectedRowId, "cd_hinmei", data);
	                    grid.setCell(selectedRowId, nm_hinmeiName, data2);

	                    // 更新状態の変更セットに変更データを追加
	                    var changeData = setCreatedChangeData(grid.getRowData(selectedRowId));
	                    changeSet.addUpdated(selectedRowId, "cd_hinmei", data, changeData);
	                    // データチェック
	                    if (validateCell(selectedRowId, "cd_hinmei", data, grid.getColumnIndexByName("cd_hinmei"))) {

	                       ///自動賞味期限入力
	                        setRelatedValue(selectedRowId, "cd_hinmei", data, null);
	                        // 更新状態の変更データの設定
	                        var changeData = setUpdatedChangeData(grid.getRowData(selectedRowId));
	                        // 更新状態の変更セットに変更データを追加	                      
                            changeSet.addUpdated(selectedRowId, "dt_shomi", changeData.dt_shomi, changeData);
	                   
	                        // ライン情報をセットする
	                       // setLine(selectedRowId, data);
	                    }
	                }
	            }
	        });
	        // 製造ラインダイアログ定義
	        seizoLineDialog.dlg({
	            url: "Dialog/SeizoLineDialog.aspx",
	            name: "SeizoLineDialog",
	            closed: function (e, data, data2) {
	                // エラーメッセージのクリア
	                App.ui.page.notifyAlert.clear();
	                $(".seizoLine-dialog 0 all").remove();
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
	        // コンファームダイアログ定義
	        saveConfirmDialog.dlg();
	        findConfirmDialog.dlg();
	        deleteConfirmDialog.dlg();
	        confirmDialog.dlg();
	        confirmDeleteTracingDialog.dlg();

	        /// ダイアログ固有のコントロール定義 -- End

	        // 日付の多言語対応
	        var datePickerFormat = pageLangText.dateFormatUS.text,
                newDateFormat = pageLangText.dateNewFormatUS.text;
	        if (App.ui.page.langCountry !== 'en-US') {
	            datePickerFormat = pageLangText.dateFormat.text;
	            newDateFormat = pageLangText.dateNewFormat.text;
	        }
	        // TODO：画面の仕様に応じて以下の datepicker の設定を変更してください。
	        $("#condition-dt_seizo").on("keyup", App.data.addSlashForDateString);
	        $("#condition-dt_seizo").detepicker = App.date.startOfDay(new Date());
	        $("#condition-dt_seizo").datepicker({
	            dateFormat: datePickerFormat,
	            minDate: new Date(1975, 1 - 1, 1),
	            maxDate: "+1y"
	        });

	        /// <summary>日付時刻型のセルをunformatします</summary>
	        function unformatDateTime(cellvalue, options) {
	            var nbsp = String.fromCharCode(160);
	            if (cellvalue == nbsp) {
	                return "";
	            }
	            return cellvalue;
	        }
	        // TODO：ここまで

	        /// <summary>明細の制御を行います</summary>
	        var controlCells = function (rowId) {
	            // 内訳表示を制御
	            if (grid.getCell(rowId, "flg_uchiwake") === "") {
	                $("#" + rowId + " td.sgcollapsed", grid).unbind('click').html('');
	            }
	            if (grid.getCell(rowId, "flg_zan") !== "") {

	                // 親明細の制御を行う。
	                ctrlCellItem(rowId, 'flg_jisseki', false);
	                ctrlCellItem(rowId, 'cd_hinmei', false);
	                ctrlCellItem(rowId, 'cd_line', false);
	                ctrlCellItem(rowId, 'su_seizo_jisseki', false);
	                ctrlCellItem(rowId, 'dt_shomi', false);
	                ctrlCellItem(rowId, 'no_lot_hyoji', false);
	                ctrlCellItem(rowId, 'su_batch_jisseki', false);
	                ctrlCellItem(rowId, 'check_reflect', false);

	                $("#" + rowId, grid).find("input[type='checkbox']").prop({ "disabled": true });
	            }
	        }

	        /// <summary>内訳を表示できる状態にするかどうかを</summary>
	        /// <summary>親明細行のフラグをみて制御します。</summary>
	        var controlSubGridRows = function () {
	            var ids = grid.jqGrid('getDataIDs'),
                    i = 0, len = ids.length;
	            for (; i < len; i++) {
	                controlCells(ids[i]);
	            }
	        }

	        /// <summary>全ての内訳にある編集可能セルを保存します。</summary>
	        var saveCellSubGrid = function () {
	            var subGrids = grid.find("tr.ui-subgrid");
	            subGrids.each(function (i, ele) {
	                var _grid = $(ele).find("table.ui-jqgrid-btable"),
                        ids = _grid.getDataIDs(),
                        i = 0, len = ids.length,
                        model = _grid.getGridParam("colModel"),
                        j = 0, jLen = model.length;

	                for (; i < len; i++) {
	                    for (j = 0; j < jLen; j++) {
	                        if (model[j].editable) {
	                            _grid.editCell(i + 1, j, false);
	                            _grid.saveCell(i + 1, j);
	                        }
	                    }
	                }
	            });
	        }

	        // グリッドコントロール固有のコントロール定義
	        var selectCol;
	        /// グリッドの宣言
	        grid.jqGrid({
	            colNames: [
                    pageLangText.flg_jisseki.text,
                    pageLangText.cd_hinmei.text + pageLangText.requiredMark.text,
                    pageLangText.nm_hinmei.text,
                    pageLangText.cd_line.text + pageLangText.requiredMark.text,
                    pageLangText.nm_line.text,
                    pageLangText.su_seizo_yotei.text,
                    pageLangText.su_seizo_jisseki.text + pageLangText.requiredMark.text,
                    pageLangText.dd_shomi_kigen.text,
                    pageLangText.no_lot_seihin.text,
                    pageLangText.kbn_denso.text,
                    pageLangText.dt_update.text,
                    pageLangText.flg_mishiyo.text,
                    pageLangText.flg_mishiyo.text,
                    pageLangText.flg_mishiyo.text,
                    pageLangText.flg_denso.text,
                    pageLangText.dt_seizo.text,
                    "editableFlag",
                    pageLangText.shokuba.text,
                    "isJissekiChange",
                    pageLangText.no_lot_hyoji.text,
                    pageLangText.batch.text,
                    pageLangText.bairitsu.text,
                    "hidden",
                    "hidden",
                    "hidden",
                    "hidden",
                    pageLangText.check_reflect.text,
                    "isRemoveJissekiCheck",
                    pageLangText.dd_shomi.text,
                    "isCheckAnbun", // 確定チェックを手動で変更した場合、または製造実績数を手動で変更した場合はフラグを真にします。
                    "id_row",
                    "flg_uchiwake",
                    "flg_zan",
                    "kbn_hin"
                ],
	            colModel: [
                    { name: 'flg_jisseki', width: pageLangText.flg_jisseki_width.number, editable: true, hidden: false, edittype: 'checkbox',
                        align: 'center', editoptions: { value: "1:0" }, formatter: 'checkbox',
                        formatoptions: { disabled: false }, classes: 'not-editable-cell'
                    },
                    { name: 'cd_hinmei', width: 120, editable: true, align: 'left', sorttype: "text" },
                    { name: nm_hinmeiName, width: 220, editable: false, align: 'left', sorttype: "text" },
                    { name: 'cd_line', width: 120, editable: true, align: 'left', sorttype: "text" },
                    { name: 'nm_line', width: 220, editable: false, align: 'left', sorttype: "text" },
                    { name: 'su_seizo_yotei', width: pageLangText.su_seizo_yotei_width.number, editable: false, sorttype: "int", align: "right",
                        formatter: 'integer',
                        formatoptions: {
                            thousandsSeparator: ",", defaultValue: ""
                        }
                    },
                    {
                        name: 'su_seizo_jisseki', width: pageLangText.su_seizo_jisseki_width.number, editable: true, sorttype: "float", align: "right",
                        formatter: 'number',
                        formatoptions: {
                            decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 3, defaultValue: ""
                        }
                    },
                    { name: 'dt_shomi', width: pageLangText.dd_shomi_kigen_width.number, editable: true, sorttype: "date", align: "left",
                        formatter: "date",
                        formatoptions: {
                            srcformat: newDateFormat, newformat: newDateFormat
                        },
                        editoptions: {
                            dataInit: function (el) {
                                $(el).datepicker({ dateFormat: datePickerFormat });
                                $(el).on("keyup", App.data.addSlashForDateString);
                                $(el).datepicker("option", "maxDate", new Date(pageLangText.maxDate.text));
                                $(el).datepicker("option", "minDate", new Date(pageLangText.minDate.text));
                            }
                        , maxlength: 10
                        },
                        unformat: unformatDateTime
                    },
                    { name: 'no_lot_seihin', width: 110, editable: false, sorttype: "text" },
                    { name: 'kbn_denso', width: 0, hidden: true, hidedlg: true, editable: false, edittype: 'checkbox',
                        editoptions: { value: "1:0" }, formatter: 'checkbox', formatoptions: { disabled: false }, align: 'center'
                    },
                    { name: 'dt_update', width: 0, hidden: true, hidedlg: true },
                    { name: 'flg_mishiyo_hinmei', width: 0, hidden: true, hidedlg: true },
                    { name: 'flg_mishiyo_line', width: 0, hidden: true, hidedlg: true },
                    { name: 'flg_mishiyo_seizo_line', width: 0, hidden: true, hidedlg: true },
                    { name: 'flg_denso', width: 0, hidden: true, hidedlg: true },
                    { name: 'dt_seizo', width: pageLangText.dt_seizo_width.number, sorttype: "date",
                        formatter: "date",
                        formatoptions: {
                            srcformat: newDateFormat, newformat: newDateFormat
                        }
                    },
                    { name: 'editableFlag', width: 0, hidden: true, hidedlg: true },
                    { name: 'cd_shokuba', width: 0, hidden: true, hidedlg: true },
                    { name: 'isJissekiChange', width: 0, hidden: true, hidedlg: true },
                    { name: 'no_lot_hyoji', width: 125, editable: true, align: 'left', sorttype: "text" },
                    { name: 'su_batch_jisseki', hidden: false, hidedlg: false, width: 100,
                        editable: true, sorttype: "text", align: 'right',
                        formatter: 'number',
                        formatoptions: {
                            decimalSeparator: ".", thousandsSeparator: "", decimalPlaces: 0, defaultValue: ""
                        }
                    },
                    { name: 'ritsu_kihon', hidden: false, hidedlg: false, width: 70,
                        editable: true, sorttype: "text", align: 'right',
                        formatter: 'number',
                        formatoptions: {
                            decimalSeparator: ".", thousandsSeparator: "", decimalPlaces: 2, defaultValue: ""
                        }
                    },
                    { name: 'wt_ko', width: 0, hidden: true, hidedlg: true },
                    { name: 'su_iri', width: 0, hidden: true, hidedlg: true },
                    { name: 'wt_haigo_gokei', width: 0, hidden: true, hidedlg: true },
                    { name: 'haigo_budomari', width: 0, hidden: true, hidedlg: true },
                    { name: 'check_reflect', hidden: false, hidedlg: false, width: 125, edittype: 'checkbox',
                        align: 'center', editoptions: { value: "1:0" }, formatter: 'checkbox',
                        formatoptions: { disabled: false }, classes: 'not-editable-cell'
                    },
                    { name: 'isRemoveJissekiCheck', width: 0, hidden: true, hidedlg: true },
                    { name: 'dd_shomi', width: 0, hidden: true, hidedlg: true },
	            // SPで取得しないので、初期値は必ず空白。
	            // 手動で確定チェックまたは製造実績数を修正した場合にフラグが真になる。
	            // 真のものはSAP使用予実按分トランをチェックする。
	            // 真のものはSAP使用予実按分トランを更新する。
                    {name: 'isCheckAnbun', width: 0, hidden: true, hidedlg: true },
	            // 内訳との結びつきを行IDで行います。
                    {name: 'id_row', width: 0, hidden: true, hidedlg: true },
                    { name: 'flg_uchiwake', width: 0, hidden: true, hidedlg: true },
                    { name: 'flg_zan', width: 0, hidden: true, hidedlg: true},//仕掛残であれば製品ロット番号がはいる
                    { name: 'kbn_hin', width: 0, hidden: true, hidedlg: true}
                    
                ],
	            datatype: "local",
	            shrinkToFit: false,
	            multiselect: false,
	            rownumbers: true,
	            //autoencode: true, // テキストタイプのセル内にHTMLタグを書き込めるようにするか(true:しない、デフォルトはfalse)
	            cellEdit: true,
	            onRightClickRow: function (rowid) {
	                $("#" + rowid).removeClass("ui-state-highlight").find("td").click();
	            },
	            cellsubmit: 'clientArray',
	            loadonce: true,
	            onSortCol: function () {
	                grid.setGridParam({ rowNum: grid.getGridParam("records") });
	            },
	            // subGridの定義
	            subGrid: true,
	            subGridOptions: {
	                "plusicon": "ui-icon-triangle-1-e",
	                "minusicon": "ui-icon-triangle-1-s",
	                "openicon": "ui-icon-arrowreturn-1-e",
	                "reloadOnExpand": false,
	                "selectOnExpand": false
	            },
	            subGridBeforeExpand: function (subGrid_id, row_id) {
	                grid.editCell(grid.find("#" + row_id)[0].rowIndex, firstCol, false);
	            },
	            subGridRowExpanded: function (subGrid_id, row_id) {
	                var subGrid_table_id = subGrid_id + "_t",
                        subGrid;

	                $("#" + subGrid_id).html("<table id='" + subGrid_table_id + "' class='scroll'></table>");
	                subGrid = $("#" + subGrid_table_id);
	                subGrid.jqGrid({
	                    datatype: "local",
	                    colNames: [
                            pageLangText.dt_seizo.text
                            , pageLangText.cd_hinmei.text
                            , pageLangText.nm_hinmei.text
                            , pageLangText.su_zaiko.text
                            , pageLangText.su_shiyo.text

                            , "su_shiyo_shikakari"
                            , "no_seq_shiyo_yojitsu_anbun"
                            , "no_seq_shiyo_yojitsu"
                            , "no_lot_seihin"
                            , "no_lot_shikakari"
                            , "id_row_parent"
                            , "con_su_shiyo"
                            , "dt_shomi"
                            , "cd_seihin"
                            , "no_lot_shikakari"
                        ],
	                    colModel: [
                            { name: "dt_seizo", sortable: false, width: 100, editable: false, align: "center",
                                formatter: "date",
                                formatoptions: {
                                    srcformat: newDateFormat, newformat: newDateFormat
                                }
                            },
                            { name: "cd_hinmei", sortable: false, width: 100, editable: false },
                            { name: nm_hinmeiName, sortable: false, width: 250, editable: false },
                            {
                                name: "su_zaiko", sortable: false, width: 120,
                                editable: false,
                                formatter: changeZeroToBlankCeiling, formatoptions: { decimalPlaces: 3 },
                                align: 'right'
                            },
                            {
                                name: "su_shiyo", sortable: false, width: 110,
                                editable: true,
                                editoptions: { onfocus: 'this.select()' },
                                formatter: changeZeroToBlankCeiling,
                                formatoptions: {
                                    decimalPlaces: 3
                                },
                                align: 'right'
                            },
                            { name: "su_shiyo_shikakari", hidden: true, hidedlg: true, editable: false },
                            { name: "no_seq_shiyo_yojitsu_anbun", hidden: true, hidedlg: true, editable: false },
                            { name: "no_seq_shiyo_yojitsu", hidden: true, hidedlg: true, editable: false },
                            { name: "no_lot_seihin", hidden: true, hidedlg: true, editable: false },
                            { name: "no_lot_shikakari", hidden: true, hidedlg: true, editable: false },
                            { name: "id_row_parent", hidden: true, hidedlg: true, editable: false },
                            { name: "con_su_shiyo", hidden: true, hidedlg: true, editable: false },
                            {
                                name: "dt_shomi", hidden: true, hidedlg: true, editable: false,
                                formatter: "date",
                                formatoptions: {
                                    srcformat: newDateFormat, newformat: newDateFormat
                                }
                            },
                            { name: "cd_seihin", hidden: true, hidedlg: true, editable: false },
                            { name: "no_lot_shikakari", hidden: true, hidedlg: true, editable: false }
                        ],
	                    height: '100%',
	                    width: '700px',
	                    shrinkToFit: false,
	                    multiselect: false,
	                    rownumbers: false,
	                    cellEdit: true,
	                    cellsubmit: 'clientArray',
	                    afterEditCell: function (rowId, cellName, value, iRow, iCol) {
	                        // カーソルを移動
	                        subGrid.moveCell(cellName, iRow, iCol);
	                    },
	                    afterSaveCell: function (rowId, cellName, value, iRow, iCol) {
	                        var changeData = subGrid.getRowData(rowId),
                                saveStatus;

	                        if (cellName === "su_shiyo") {
	                            value = value ? value : subGrid.getCell(rowId, cellName);
	                        }

	                        validateCell(rowId, cellName, value, iCol, subGrid);

	                        // 日付をNoUTCに修正
	                        var seizoDateCondition = $("#condition-dt_seizo").val(),
                                formatToDateStringNoUtc = App.data.getDateTimeStringForQueryNoUtc,
                                getStartOfDay = App.date.startOfDay,
                                getLocalDate = App.date.localDate;
	                        changeData.con_dt_seizo = formatToDateStringNoUtc(getStartOfDay(getLocalDate(changeData.dt_seizo))); // チェック用
	                        changeData.dt_seizo = formatToDateStringNoUtc(getStartOfDay(getLocalDate(seizoDateCondition)));     // 登録用
	                        changeData.dt_shomi = formatToDateStringNoUtc(getStartOfDay(getLocalDate(changeData.dt_shomi)));

	                        // 変更セットから一度削除
	                        subGridChangeSet.removeCreated(rowId);
	                        subGridChangeSet.removeUpdated(rowId);
	                        subGridChangeSet.removeDeleted(rowId);

	                        // Created, Updated, Deletedの判定
	                        saveStatus = getSubGridSaveStatus(changeData);
	                        if (saveStatus === "Updated") {
	                            // 更新状態の変更セットに変更データを追加
	                            subGridChangeSet.addUpdated(rowId, cellName, value, changeData);
	                        }
	                        else if (saveStatus === "Created" || saveStatus === "Deleted") {
	                            // 登録・削除状態の変更セットに変更データを追加
	                            subGridChangeSet["add" + saveStatus](rowId, changeData);
	                        }
	                    },
	                    ondblClickRow: function (rowid) {
	                        return false;
	                    }
	                });

	                // subGridの検索とバインド
	                setSubGridData(row_id, subGrid);
	            },
	            loadComplete: function () {
	                var ids = grid.jqGrid('getDataIDs')
                        , id
                        , flgMishiyo
                        , flgJisseki
                        , updateDate
                        , ddShomiMaHin
                        , dtShomi;
	                for (var i = 0; i < ids.length; i++) {
	                    id = ids[i];

	                    // 行IDをセット
	                    grid.setCell(id, 'id_row', id);

	                    flgJisseki = grid.jqGrid('getCell', id, 'flg_jisseki');
	                    dtShomi = grid.jqGrid('getCell', id, 'dt_shomi');
	                    ddShomiMaHin = grid.jqGrid('getCell', id, 'dd_shomi');

	                    if (dtShomi == "" && isAutoCalcShomiDate == pageLangText.kinoSeizoNippoShomiKigenAutoCalcSuru.number) {
	                        //製造計画トラン.賞味期限が空の場合、製造日 + 品名マスタ.賞味期間 - 1を初期表示
	                        var dtSeizoCondition = $("#condition-dt_seizo").val();
	                        var dtSeizo = App.date.localDate(dtSeizoCondition);
	                        var strShomi = '';
	                        var strShomi2 = '';

	                        if (ddShomiMaHin == "") {
	                            ddShomiMaHin = 0;
	                        } else {
	                            ddShomiMaHin = parseInt(ddShomiMaHin);
	                            strShomi = new Date(dtSeizo.setDate(dtSeizo.getDate() + ddShomiMaHin - 1));
	                            strShomi2 = App.data.getDateString(strShomi, true);
	                        }
	                        grid.setCell(i + 1, "dt_shomi", strShomi2);
	                    }

	                    // 既存行は品名コードとラインコードの編集不可
	                    ctrlCellItem(id, "cd_hinmei", false);
	                    ctrlCellItem(id, "cd_line", false);

	                    // 確定フラグや未使用フラグによる操作可否の定義
	                    setCellEditable(id, flgJisseki);
	                    controlCells(id);
	                    //倍率を操作不可に変更
	                    grid.jqGrid('setCell', id, 'ritsu_kihon', '', 'not-editable-cell');
	                }

	                // 未使用のレコードが存在する場合はメッセージを表示
	                if (isMishiyo) {
	                    App.ui.page.notifyInfo.message(pageLangText.mishiyoMessage.text).show();
	                }

	                // グリッドの先頭行選択
	                if (ids.length > 0) {
	                    grid.editCell(1, firstCol, false);

	                    // 先頭行を前回選択行として保持。
	                    preRowId = ids[0];
	                }
	            },
	            gridComplete: function () {
	                var row
                        , rowid
                        , criteria = $(".search-criteria").toJSON()
                        , cd_line = criteria.line;
	                for (var iRow = 0; iRow < this.rows.length; iRow++) {
	                    row = this.rows[iRow];
	                    rowid = row.id;

	                    // subGridの場合はスキップ
	                    if ($(row).hasClass("ui-subgrid")) {
	                        continue;
	                    }

	                    if ($.inArray('jqgrow', row.className.split(' ')) > 0) {
	                        // TODO：画面の仕様に応じて以下を変更してください。
	                        // チェックボックスの値を取得
	                        if (grid.getCell(rowid, "flg_mishiyo_hinmei") == pageLangText.trueFlg.text
                                    || grid.getCell(rowid, "flg_mishiyo_line") == pageLangText.trueFlg.text
                                    || grid.getCell(rowid, "flg_mishiyo_seizo_line") == pageLangText.trueFlg.text) {
	                            grid.toggleClassRow(rowid, "attention");
	                            isMishiyo = true;
	                        }
	                        // TODO：ここまで
	                    }
	                    // 検索条件：ラインコード有のときラインコードを操作不可とする
	                    if (!App.isUndefOrNull(cd_line) && cd_line != "") {
	                        isLineSelect = true;
	                        grid.jqGrid('setCell', rowid, 'cd_line', '', 'not-editable-cell');
	                    }
	                    else {
	                        isLineSelect = false;
	                    }
	                }
	                if (isLineSelect && grid.getCell(rowid, "cd_line") != "" && grid.getCell(rowid, "nm_line") === "") {
	                    grid.setCell(rowid, "nm_line", $("#condition-line option:selected").text());
	                }
	            },
	            beforeEditCell: function (selectedRowId, cellName, value, iRow, iCol) {
	                currentRow = iRow;
	                currentCol = iCol;
	                // カーソルを移動
	                //grid.moveAnyCell(cellName, iRow, iCol);
	            },
	            afterEditCell: function (selectedRowId, cellName, value, iRow, iCol) {
	                // カーソルを移動
	                //grid.moveAnyCell(cellName, iRow, iCol);
	                grid.moveCell(cellName, iRow, iCol);
	            },
	            beforeSaveCell: function (selectedRowId, cellName, value, iRow, iCol) {
	                // カーソルを移動
	                //grid.moveAnyCell(cellName, iRow, iCol);
	                // セルバリデーション
	                if (validateCell(selectedRowId, cellName, value, iCol)) {
	                    // バリデーションOKの場合

	                    // 関連項目の設定
	                    setRelatedValue(selectedRowId, cellName, value, iCol);
	                    if (cellName == 'dt_shomi') {
	                        value = App.data.getDateTimeStringForQueryNoUtc(App.date.localDate(value));
	                    }

	                    // 更新状態の変更データの設定
	                    var changeData = setUpdatedChangeData(grid.getRowData(selectedRowId));
	                    // 更新状態の変更セットに変更データを追加
	                    changeSet.addUpdated(selectedRowId, cellName, value, changeData);

	                    if (cellName === "cd_hinmei") {
	                        // 更新状態の変更セットに変更データを追加
	                        changeSet.addUpdated(selectedRowId, "dt_shomi", changeData.dt_shomi, changeData);
	                    }
	                }
	            },
	            afterSaveCell: function (selectedRowId, cellName, value, iRow, iCol) {
	                // カーソルを移動
	                //grid.moveAnyCell(cellName, iRow, iCol);
	            },
	            onCellSelect: function (rowid, icol, cellcontent) {
	                selectCol = icol;
	            },
	            ondblClickRow: function (rowid) {
	                if (rowid.toString().split("_").length === 2) {
	                    return false;
	                }

	                var iCol = grid[0].p.iCol;
	                // 品名セレクタ起動
	                if (iCol === grid.getColumnIndexByName("cd_hinmei") || iCol === grid.getColumnIndexByName(nm_hinmeiName)) {
	                    if (checkShowDialog(rowid)) {
	                        // 検索条件変更チェック
	                        if (isCriteriaChange) {
	                            //showCriteriaChange("navigate");
	                            showCriteriaChange("execute");
	                            return;
	                        }
	                        showHinmeiDialog(rowid);
	                    }
	                }
	                // ラインセレクタ起動
	                else if (iCol === grid.getColumnIndexByName("cd_line") || iCol === grid.getColumnIndexByName("nm_line")) {
	                    if (checkShowDialog(rowid)) {
	                        // 検索条件変更チェック
	                        if (isCriteriaChange) {
	                            //showCriteriaChange("navigate");
	                            showCriteriaChange("execute");
	                            return;
	                        }
	                        showSeizoLineDialog(rowid);
	                    }
	                }
	                    // 倍率がダブルクリックされた場合
	                else if (selectCol === bairitsuCol) {
	                    // 倍率を編集可能にする
	                    grid.deleteColumnClass(rowid, 'ritsu_kihon', 'not-editable-cell');
	                }
	            }
	        });
	        /// <summary>セルの関連項目を設定します。</summary>
	        /// <param name="selectedRowId">選択行ID</param>
	        /// <param name="cellName">列名</param>
	        /// <param name="value">元となる項目の値</param>
	        /// <param name="iCol">項目の列番号</param>
	        var setRelatedValue = function (selectedRowId, cellName, value, iCol) {
	            // TODO：画面の仕様に応じて以下の関連項目を設定を変更してください。
	            if (cellName === "cd_hinmei" || cellName === "cd_line") {
	                var serviceUrl,
                        elementCode,
                        elementName,
                        codeName,
                        criteria = $(".search-criteria").toJSON();
	                switch (cellName) {
	                    case "cd_line":
	                        var cd_line = criteria.line
	                        if (App.isUndefOrNull(cd_line) || cd_line === "") {
	                            cd_line = grid.getCell(selectedRowId, cellName);
	                        }
	                        serviceUrl = "../Services/FoodProcsService.svc/vw_ma_seizo_line_02()?$filter="
                                    + "kbn_master eq " + pageLangText.hinmeiMasterSeizoLineMasterKbn.text
                                    + " and seizo_line_mishiyo eq " + pageLangText.falseFlg.text
                                    + " and line_mishiyo eq " + pageLangText.falseFlg.text
                                    + " and cd_haigo eq '" + grid.getCell(selectedRowId, "cd_hinmei") + "'"
                                    + " and cd_shokuba eq '" + $(".search-criteria").toJSON().shokuba + "'"
                                    + " and cd_line eq '" + cd_line + "'";
	                        elementCode = cellName;
	                        elementName = "nm_line";
	                        codeName;
	                        break;
	                    case "cd_hinmei":
	                        serviceUrl = "../Services/FoodProcsService.svc/ma_hinmei()?$filter=cd_hinmei eq '"
                                + grid.getCell(selectedRowId, cellName) + "' and flg_mishiyo eq "
                                + pageLangText.falseFlg.text + " and (kbn_hin eq " + pageLangText.seihinHinKbn.text
                                + " or kbn_hin eq " + pageLangText.jikaGenryoHinKbn.text + ")"
                                + "&$top=1";
	                        elementCode = cellName;
	                        elementName = nm_hinmeiName;
	                        codeName;
	                        break;
	                    default:
	                        break;
	                }
	                App.deferred.parallel({
	                    // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
	                    codeName: App.ajax.webgetSync(serviceUrl)
	                    // TODO: ここまで
	                }).done(function (result) {
	                    // TODO: 画面の仕様に応じて以下のサービス呼び出し成功時の処理を変更してください。
	                    var row = grid.getRowData(selectedRowId);
	                    codeName = result.successes.codeName.d;
	                    if (!App.isUndefOrNull(codeName) && codeName.length > 0) {
	                        grid.setCell(selectedRowId, elementName, codeName[0][elementName]);
	                        if (!isLineSelect && cellName === "cd_hinmei") {
	                            // 品コードを入力かつ検索条件にラインが指定されていない
	                            setLine(selectedRowId, grid.getCell(selectedRowId, cellName));
	                        }
	                        else if (isLineSelect && cellName === "cd_hinmei") {
	                            // 品コードを入力かつ検索条件にラインが指定されている
                                // 配合情報を取得する
	                            var cd_line = grid.getCell(selectedRowId, "cd_line");
	                            var cd_hinmei = grid.getCell(selectedRowId, "cd_hinmei");
	                            setHaigoInfo(selectedRowId, cd_hinmei, cd_line);
	                        }

	                        if (cellName === "cd_hinmei") {
	                            var ddShomiMaHin
                                    , dtShomi
                                    , cdKbnHinMaHin;
	                            var dtSeizoCondition = $("#condition-dt_seizo").val();
	                            var dtSeizo = App.date.localDate(dtSeizoCondition);
	                            var strShomi;
	                            var strShomi2;

	                            //品名マスタの賞味期間を取得
	                            ddShomiMaHin = codeName[0].dd_shomi;

	                            if (ddShomiMaHin != null && ddShomiMaHin > 0) {
	                                //製造日 + 品名マスタ.賞味期間 - 1 を表示
	                                ddShomiMaHin = parseInt(ddShomiMaHin);
	                                strShomi = new Date(dtSeizo.setDate(dtSeizo.getDate() + ddShomiMaHin - 1));
	                                strShomi2 = App.data.getDateString(strShomi, true);
	                            }
	                            grid.setCell(selectedRowId, "dt_shomi", strShomi2);
	                            
	                            //品名マスタの品区分を取得
	                            cdKbnHinMaHin = codeName[0].kbn_hin;
	                            //品区分が取得できた場合のみ、画面の隠し項目に値を格納
	                            if (cdKbnHinMaHin != null && cdKbnHinMaHin != "") {
	                                grid.setCell(selectedRowId, "kbn_hin", cdKbnHinMaHin);
	                            }
	                        }
	                    }
	                    else {
	                        grid.setCell(selectedRowId, elementName, null);
	                        grid.setCell(selectedRowId, "ritsu_kihon", null);
	                        grid.setCell(selectedRowId, "check_reflect", "0");
	                        grid.setCell(selectedRowId, "cd_line", null);
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
	            }
	            if (cellName == "su_seizo_jisseki" || cellName == "no_lot_hyoji") {
	                // 製造実績数、表示用ロット番号が修正された場合は、保存時に確定チェックをつける為、修正フラグをONにする
	                // また意図的に確定チェックを外した場合のフラグを初期化する
	                grid.jqGrid('setCell', selectedRowId, 'isJissekiChange', pageLangText.trueFlg.text);
	                grid.jqGrid('setCell', selectedRowId, 'isRemoveJissekiCheck', null);
	            }
	            if (kbnShomi == pageLangText.kinoShomikigenRequired.number) {
	                if (cellName == "dt_shomi") {
	                    grid.jqGrid('setCell', selectedRowId, 'isJissekiChange', pageLangText.trueFlg.text);
	                    grid.jqGrid('setCell', selectedRowId, 'isRemoveJissekiCheck', null);
	                }
	            }
	            if (cellName === "su_seizo_jisseki") {
	                // 製造実績数を編集した場合は按分チェックフラグを真にします。
	                setCellAndChangeSet(selectedRowId, "isCheckAnbun", pageLangText.trueFlg.text);
	            }
	            // TODO：ここまで
	        };

	        ///<summary>内訳情報を取得します</summary>
	        ///<summary>引数のsubGridがundefinedでない場合は行を作成します</summary>
	        var getSubGridData = function (parentRowId, subGrid) {
	            var query = new getSubGridQuery(parentRowId),
	                seihinCode = grid.getCell(parentRowId, "cd_hinmei"),
                    seihinLotNo = grid.getCell(parentRowId, "no_lot_seihin"),
                    doSet = !App.isUndef(subGrid),
                    rows = [];
	            App.ui.loading.show(pageLangText.nowProgressing.text);

	            App.ajax["webget" + (doSet ? "" : "Sync")](
	              App.data.toWebAPIFormat(query)
                ).done(function (result) {
                    result = result.d;

                    // データバインド
                    if (result.length > 0) {
                        var i, len, record, row, j, subGridKey;
                        for (i = 0, len = result.length; i < len; i++) {
                            record = result[i];
                            row = {};
                            j = 0;
                            subGridKey = parentRowId + "_" + (i + 1);

                            // 行情報の補填
                            record.subGridKey = subGridKey;
                            record.id_row_parent = parentRowId;                 // 親明細行ID
                            record.cd_seihin = seihinCode;                      // 親明細行製品コード
                            record.no_lot_seihin = seihinLotNo;                 // 親明細行製品ロット番号
                            record.dt_seizo = App.data.getDate(record.dt_seizo);
                            record.dt_shomi = App.data.getDate(record.dt_shomi);
                            rows.push(record);

                            // 行追加
                            if (doSet) {
                                subGrid.addRowData(subGridKey, record);

                                if (App.date.startOfDay(App.date.localDate(subGrid.getCell(subGridKey, "dt_shomi"))) < App.date.startOfDay(new Date())) {
                                    // 賞味期限が切れている場合は編集不可
                                    subGrid.setCell(subGridKey, 'su_shiyo', '', 'not-editable-cell');
                                }
                            }
                        }
                    }
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                }).always(function () {
                    // ローディングの終了
                    App.ui.loading.close();
                });

	            return rows;
	        }

	        // サブグリッド用のデータ取得
	        var setSubGridData = function (row_id, subGrid) {
	            App.ui.page.notifyAlert.clear();
	            getSubGridData(row_id, subGrid);
	        }

	        /// <summary>内訳明細の対象データがどの変更セットに属するかを返します。</summary>
	        /// <param name="value">内訳明細1行分のデータ</param>
	        var getSubGridSaveStatus = function (data) {
	            // 仕掛残の[使用予実トラン].[シーケンス番号]が空白の場合はCreated
	            // 但し使用量の論理値が偽の場合は新規登録しません。
	            if (!data.no_seq_shiyo_yojitsu) {
	                return parseFloat(data.su_shiyo) ? "Created" : "";
	            }
	            // 内訳/編集可能項目/使用数が0の場合はDeleted
	            if (!parseFloat(data.su_shiyo)) {
	                return "Deleted";
	            }

	            return "Updated";
	        }

	        /// <summary>値のカンマ区切りを除去して数値にして返却します。</summary>
	        /// <param name="value">値</param>
	        var deleteThousandsSeparator = function (value) {
	            var retVal = 0;
	            if (value != "") {
	                retVal = parseFloat(new String(value).replace(/,/g, ""));
	            }
	            return retVal;
	        };

	        /// <summary>値をカンマ区切りにして返却します。</summary>
	        /// <param name="value">値</param>
	        var setThousandsSeparator = function (value) {
	            var str = value;
	            var num = new String(str).replace(/,/g, "");
	            while (num != (num = num.replace(/^(-?\d+)(\d{3})/, "$1,$2")));
	            return num;
	        };

	        /// <summary>【切り上げ版】値が0だった場合、0を返却します。</summary>
	        /// <param name="value">セルの値</param>
	        /// <param name="options">オプション</param>
	        /// <param name="rowObj">行データ</param>
	        function changeZeroToBlankCeiling(value, options, rowObj) {
	            var returnVal = deleteThousandsSeparator(value);
	            if (returnVal == 0 || isNaN(returnVal)) {
	                returnVal = "0.000";
	            }
	            else {
	                // 小数点以下の桁数を固定にする
	                var fixeVal = options.colModel.formatoptions.decimalPlaces; // 丸め位置
	                var kanzan = Math.pow(10, parseInt(fixeVal, 10));   // べき乗
	                // 指定の桁数以降は切り上げ
	                var kanzanVal = Math.ceil(App.data.trimFixed(returnVal * kanzan));
	                returnVal = App.data.trimFixed(kanzanVal / kanzan);
	                // ゼロ埋め
	                returnVal = returnVal.toFixed(fixeVal); // toFixed：収まらない場合は四捨五入される
	                // カンマ区切りにする
	                returnVal = setThousandsSeparator(returnVal);
	            }
	            return returnVal;
	        }

	        //// コントロール定義 -- End

	        //// 操作制御定義 -- Start

	        // ユーザー権限による操作制御定義を定義します。
	        App.ui.pagedata.operation.applySetting(App.ui.page.user.Roles[0], App.ui.page.lang);
	        $(function () {
	            if (userRoles === pageLangText.editor.text
                        || userRoles === pageLangText.viewer.text) {
	                $(".save-button").css("display", "none");
	                $(".check-button").css("display", "none");
	                $(".add-button").css("display", "none");
	                $(".delete-button").css("display", "none");
	                $(".hinmei-button").css("display", "none");
	                $(".line-button").css("display", "none");
	            }
	        });

	        //// 操作制御定義 -- End

	        //// 事前データロード -- Start 

	        // 画面アーキテクチャ共通の事前データロード
	        var shokuba,
                line;
	        App.deferred.parallel({
	            // ローディングの表示
	            loading: App.ui.loading.show(pageLangText.nowProgressing.text),
	            // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
	            shokuba: App.ajax.webget("../Services/FoodProcsService.svc/ma_shokuba?"
                                + "$filter=flg_mishiyo eq " + pageLangText.falseFlg.text),
	            shomi: App.ajax.webgetSync("../Services/FoodProcsService.svc/cn_kino_sentaku()?$filter=kbn_kino eq " + pageLangText.kinoShomikigenKbn.number),
	            shomiCalc: App.ajax.webgetSync("../Services/FoodProcsService.svc/cn_kino_sentaku()?$filter=kbn_kino eq " + pageLangText.kinoSeizoNippoShomiKigenAutoCalc.number)
	            // TODO: ここまで)
	        }).done(function (result) {
	            // TODO: 画面の仕様に応じて以下のサービス呼び出し成功時の処理を変更してください。
	            shokuba = result.successes.shokuba.d;
	            shomi = result.successes.shomi.d;
	            var shomiCalc = result.successes.shomiCalc.d;
	            if (shomi.length > 0) {
	                kbnShomi = shomi[0].kbn_kino_naiyo;
	            } else {
	                kbnShomi = "";
	            }

	            // 明細/賞味期限の自動区分
	            if (shomiCalc.length) {
	                isAutoCalcShomiDate = shomiCalc[0].kbn_kino_naiyo;
	            }
	            else {
	                // 取得できない場合は表示します。
	                isAutoCalcShomiDate = pageLangText.kinoSeizoNippoShomiKigenAutoCalcSuru.number;
	            }

	            // 検索用ドロップダウンの設定
	            App.ui.appendOptions($("#condition-shokuba"), "cd_shokuba", "nm_shokuba", shokuba, false);
	            createLineCombobox();
	            // 当日日付を挿入
	            $("#condition-dt_seizo").datepicker("setDate", new Date());
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
	            // ローディングの終了
	            App.ui.loading.close();
	        });

	        //// 事前データロード -- End


	        //// 検索処理 -- Start

	        // 画面アーキテクチャ共通の検索処理

	        /// <summary>サブグリッドクエリオブジェクトの設定</summary>
	        var getSubGridQuery = function (rowId) {
	            var rowdata = grid.getRowData(rowId),
	                query = {
	                    // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
	                    url: "../api/SeizoNippoUchiwake",
	                    // TODO: ここまで
	                    cd_hinmei: rowdata.cd_hinmei,
	                    no_lot_seihin: rowdata.no_lot_seihin,
	                    // TODO: ここまで
	                    skip: 0,
	                    top: 100
	                };
	            return query;
	        };

	        /// <summary>クエリオブジェクトの設定</summary>
	        var query = function () {
	            var query = {
	                // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
	                url: "../Services/FoodProcsService.svc/vw_tr_keikaku_seihin_01",
	                // TODO: ここまで
	                filter: createFilter(),
	                // TODO: 画面の仕様に応じて以下のソート条件を変更してください。
	                orderby: "cd_hinmei, no_lot_seihin",
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
	            var seizoDate = criteria.dt_seizo;

	            // TODO: 画面の仕様に応じて以下のフィルター条件を変更してください。
	            filters.push("dt_seizo eq DateTime'" + App.data.getDateTimeStringForQueryNoUtc(criteria.dt_seizo) + "'");
	            filters.push("cd_shokuba eq '" + criteria.shokuba + "'");
	            filters.push("kbn_master eq " + pageLangText.hinmeiMasterSeizoLineMasterKbn.text);
	            if (!App.isUndefOrNull(criteria.line) && criteria.line.length > 0) {
	                filters.push("cd_line eq '" + criteria.line + "'");
	            }
	            // TODO: ここまで

	            return filters.join(" and ");
	        };
	        // 検索前処理
	        var checkSearch = function () {
	            if (!isCriteriaChange && !noChange()) {
	                showFindConfirmDialog();
	            }
	            else {
	                clearState();
	                // 検索前バリデーション
	                var result = $(".part-body .item-list").validation().validate();
	                if (result.errors.length) {
	                    // ローディングの終了
	                    App.ui.loading.close();
	                    return;
	                }
	                searchItems(new query());
	            }
	        };
	        /// <summary>データ検索を行います。</summary>
	        /// <param name="query">クエリオブジェクト</param>
	        var searchItems = function (query) {
	            closeFindConfirmDialog();
	            if (isDataLoading == true) {
	                return;
	            }
	            isDataLoading = true;
	            // ローディングの表示
	            $("#list-loading-message").text(pageLangText.nowLoading.text);

	            var criteria = $(".search-criteria").toJSON(),
                    _query = {
                        url: "../api/SeizoNippo",
                        dt_seizo: App.data.getDateTimeStringForQueryNoUtc(App.date.localDate(criteria.dt_seizo)),
                        cd_shokuba: criteria.shokuba,
                        cd_line: criteria.line,
                        skip: querySetting.skip,
                        top: querySetting.top
                    };

	            App.ajax.webget(
	            // WCF Data ServicesのODataシステムクエリオプションを生成
	            //    App.data.toODataFormat(query)
                    App.data.toWebAPIFormat(_query)
                ).done(function (result) {
                    // 検索フラグを立てる
                    isSearch = true;
                    if (result.d.length == "0") {
                        App.ui.page.notifyAlert.message(MS0037).show();
                    }
                    else {
                        // データバインド
                        bindData(result);
                        // 検索条件を閉じる
                        closeCriteria();
                        $(".ui-jqgrid-hdiv").scrollLeft(0); // 明細のスクロール位置をリセット
                        isCriteriaChange = false;
                    }
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                }).always(function () {
                    setTimeout(function () {
                        // ローディングの終了
                        $("#list-loading-message").text("");
                        App.ui.loading.close();
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
	            var resultCount = parseInt(result.d[0].cnt);
	            if (resultCount > querySetting.top) {
	                App.ui.page.notifyInfo.message(
                        App.str.format(MS0568, resultCount, querySetting.top)).show();
	                querySetting.count = querySetting.top;
	            }
	            else {
	                querySetting.count = resultCount;
	            }
	            displayCount(resultCount);
	            // データバインド
	            var currentData = grid.getGridParam("data").concat(result.d);
	            grid.setGridParam({ data: currentData }).trigger('reloadGrid', [{ current: true}]);
	            App.ui.page.notifyInfo.message(App.str.format(
                    pageLangText.searchResultCount.text, querySetting.count, resultCount)).show();
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
	        var getAlertInfo = function (unique, isSubGrid) {
	            var info = {},
                    splits;

	            if (isSubGrid === true) {
	                splits = unique.split("_");
	                info.selectedRowId = splits[0] + '_' + splits[1];
	                info.iCol = parseInt(splits[2], 10);
	            }
	            else {
	                splits = unique.split("_");
	                info.selectedRowId = splits[0];
	                info.iCol = parseInt(splits[1], 10);
	            }

	            return info;
	        };
	        /// <summary>エラー一覧クリック時の処理を行います。</summary>
	        /// <param name="data">エラー情報</param>
	        var handleNotifyAlert = function (data, _subGrid) {
	            //data.unique でキーが取得できる
	            //data.handledにtrueを指定することでデフォルトの動作(キーがHTMLElementの場合にフォーカスを当てる処理)の実行をキャンセルする
	            // グリッド内のエラーの場合、data.uniqueがstringになるため以下の条件分岐を追加
	            if (!App.isStr(data.unique)) {
	                data.handled = false;
	                return;
	            }
	            data.handled = true;
	            // エラーのセル情報を取得
	            var isSubGrid = !App.isUndef(_subGrid),
                    info = getAlertInfo(data.unique, isSubGrid),
                    iRow = $('#' + info.selectedRowId)[0].rowIndex;

	            // 同時実行制御エラーの場合は編集可能なセルの先頭列を選択
	            if (info.iCol === duplicateCol) {
	                info.iCol = firstCol;
	            }

	            // セルを選択して入力モードにする
	            if (isSubGrid && _subGrid.length === 1) {
	                _subGrid.find('#' + info.selectedRowId).find('td:eq(' + info.iCol + ')').trigger('click');
	                return;
	            }
	            else if (!isSubGrid) {
	                grid.editCell(iRow, info.iCol, true);
	            }
	        };

	        // ダイアログ固有のメッセージ表示

	        // 保存確認メッセージの設定
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
	        // 検索確認メッセージの設定
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
	        // 削除確認メッセージの設定
	        var deleteConfirmDialogNotifyInfo = App.ui.notify.info(deleteConfirmDialog, {
	            container: ".delete-confirm-dialog .dialog-slideup-area .info-message",
	            messageContainerQuery: "ul",
	            show: function () {
	                deleteConfirmDialog.find(".info-message").show();
	            },
	            clear: function () {
	                deleteConfirmDialog.find(".info-message").hide();
	            }
	        });
	        var deleteConfirmDialogNotifyAlert = App.ui.notify.alert(deleteConfirmDialog, {
	            container: ".delete-confirm-dialog .dialog-slideup-area .alert-message",
	            messageContainerQuery: "ul",
	            show: function () {
	                deleteConfirmDialog.find(".alert-message").show();
	            },
	            clear: function () {
	                deleteConfirmDialog.find(".alert-message").hide();
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

	            // 選択行なしの場合、先頭行を選択
	            if (App.isUnusable(selectedRowId) || selectedRowId === "") {
	                selectedRowId = ids[0];
	            }
	            currentRow = $('#' + selectedRowId)[0].rowIndex;

	            return selectedRowId;
	        };
	        /// <summary>新規行データの設定を行います。</summary>
	        //var setAddData = function (rowid) {
	        var setAddData = function (newRowId) {
	            // TODO: 画面の仕様に応じて以下の項目を変更してください。
	            var criteria = $(".search-criteria").toJSON(),
                    nmLine = $("#condition-line option:selected").text();
	            var addData = {
	                "flg_jisseki": pageLangText.falseFlg.text
                    , "cd_hinmei": null
                    , nm_hinmeiName: null
                    , "cd_line": criteria.line
                    , "nm_line": nmLine
                    , "su_seizo_yotei": null
                    , "su_seizo_jisseki": null
                    , "dt_shomi": null
                    , "no_lot_seihin": null
                    , "kbn_denso": pageLangText.falseFlg.text
                    , "dt_update": null
                    , "flg_mishiyo_hinmei": pageLangText.falseFlg.text
                    , "flg_mishiyo_line": pageLangText.falseFlg.text
                    , "flg_mishiyo_seizo_line": pageLangText.falseFlg.text
                    , "flg_denso": pageLangText.falseFlg.text
                    , "dt_seizo": criteria.dt_seizo
                    , "editableFlag": pageLangText.trueFlg.text
                    , "cd_shokuba": criteria.shokuba
                    , "su_batch_jisseki": null
                    , "no_lot_hyoji": null
                    , "isCheckAnbun": ""    // 保存処理で必要なため追加
                    , "id_row": newRowId
                    , "flg_uchiwake": ""
                    , "kbn_hin": ""
	            };
	            // TODO: ここまで

	            return addData;
	        };
	        /// <summary>追加状態の変更セットに追加する変更データの設定を行います。</summary>
	        /// <param name="newRow">新規行データ</param>
	        var setCreatedChangeData = function (newRow) {
	            // TODO: 画面の仕様に応じて以下の項目を変更してください。
	            var criteria = $(".search-criteria").toJSON();
	            var changeData = {
	                "dt_seizo": App.data.getDateTimeStringForQueryNoUtc(App.date.localDate(newRow.dt_seizo)),
	                "cd_shokuba": newRow.cd_shokuba,
	                "cd_line": newRow.cd_line,
	                "cd_hinmei": newRow.cd_hinmei,
	                "su_seizo_yotei": newRow.su_seizo_yotei,
	                "su_seizo_jisseki": newRow.su_seizo_jisseki,
	                "flg_jisseki": newRow.flg_jisseki,
	                "kbn_denso": newRow.kbn_denso,
	                "flg_denso": newRow.flg_denso,
	                //"dt_update": new Date(),
	                "dt_update": newRow.dt_update,
	                "su_batch_jisseki": newRow.su_batch_jisseki,
	                "no_lot_seihin": newRow.no_lot_seihin,
	                "dt_shomi": (App.isUndefOrNull(newRow.dt_shomi) || newRow.dt_shomi == "") ? "" : App.data.getDateTimeStringForQueryNoUtc(App.date.localDate(newRow.dt_shomi)),
	                "no_lot_hyoji": newRow.no_lot_hyoji
                    , "isCheckAnbun": newRow.isCheckAnbun    // 保存処理で必要なため追加
                    , "id_row": newRow.id_row
                    , "flg_uchiwake": newRow.flg_uchiwake
	            };
	            // TODO: ここまで

	            return changeData;
	        };
	        /// <summary>更新状態の変更セットに追加する変更データの設定を行います。</summary>
	        /// <param name="row">選択行</param>
	        var setUpdatedChangeData = function (row) {
	            var dtShomi;
	            if (row.dt_shomi == "" || row.dt_shomi == " ") {
	                dtShomi = null;
	            }
	            else {
	                dtShomi = App.data.getDateTimeStringForQueryNoUtc(App.date.localDate(row.dt_shomi));
	            }
	            // TODO: 画面の仕様に応じて以下の項目を変更してください。
	            var changeData = {
	                "no_lot_seihin": row.no_lot_seihin,
	                "dt_seizo": App.data.getDateTimeStringForQueryNoUtc(App.date.localDate(row.dt_seizo)),
	                "cd_shokuba": row.cd_shokuba,
	                "cd_line": row.cd_line,
	                "cd_hinmei": row.cd_hinmei,
	                "su_seizo_yotei": row.su_seizo_yotei,
	                "su_seizo_jisseki": row.su_seizo_jisseki,
	                "flg_jisseki": row.flg_jisseki,
	                "kbn_denso": row.kbn_denso,
	                "flg_denso": row.flg_denso,
	                //"dt_update": new Date(),
	                "dt_update": row.dt_update,
	                "su_batch_jisseki": row.su_batch_jisseki,
	                "dt_shomi": dtShomi,
	                "no_lot_hyoji": row.no_lot_hyoji
                    , "isCheckAnbun": row.isCheckAnbun    // 保存処理で必要なため追加
                    , "id_row": row.id_row
                    , "flg_uchiwake": row.flg_uchiwake
	            };
	            // TODO: ここまで

	            return changeData;
	        };
	        /// <summary>削除状態の変更セットに追加する変更データの設定を行います。</summary>
	        /// <param name="row">選択行</param>
	        var setDeletedChangeData = function (row) {
	            // TODO: 画面の仕様に応じて以下の項目を変更してください。
	            var changeData = {
	                "no_lot_seihin": row.no_lot_seihin,
	                "dt_seizo": App.data.getDateTimeStringForQueryNoUtc(App.date.localDate(row.dt_seizo)),
	                "cd_shokuba": row.cd_shokuba,
	                "cd_line": row.cd_line,
	                "cd_hinmei": row.cd_hinmei,
	                "su_seizo_yotei": row.su_seizo_yotei,
	                "su_seizo_jisseki": row.su_seizo_jisseki,
	                "flg_jisseki": row.flg_jisseki,
	                "kbn_denso": row.kbn_denso,
	                "flg_denso": row.flg_denso,
	                //"dt_update": new Date()
	                "id_row": row.id_row,
	                "flg_uchiwake": row.flg_uchiwake
	            };
	            // TODO: ここまで

	            return changeData;
	        };

	        // subGrid表示セルのクリックイベントをunbindします。
	        var unbindSubGrid = function () {
	            var ids = grid.getDataIDs();
	            for (var i = 0, len = ids.length; i < len; i++) {
	                $("#" + ids[i] + " [aria-describedby='item-grid_subgrid']").unbind("click");
	            }
	        }

	        /// <summary>新規行を追加します。</summary>
	        /// <param name="e">イベントデータ</param>
	        var addData = function (e) {

	            // 一度subgridをunbind
	            unbindSubGrid();

	            // 選択行のID取得
	            var selectedRowId = getSelectedRowId(true),
                    position = "after";
	            //position = "before";
	            // 新規行データの設定
	            var newRowId = App.uuid(),
	            //    addData = setAddData(selectedRowId);
	                addData = setAddData(newRowId),
                    skipRow = 1;
	            if (App.isUndefOrNull(selectedRowId)) {
	                // 末尾にデータ追加
	                grid.addRowData(newRowId, addData);
	                currentRow = 0;
	            }
	            else {
	                // セル編集内容の保存
	                grid.saveCell(currentRow, currentCol);

	                if (grid.find("#" + selectedRowId).closest("tr").next().hasClass("ui-subgrid")) {
	                    // 選択行の一つ後が内訳の場合
	                    skipRow = 2;
	                }

	                // 選択行の任意の位置にデータ追加
	                grid.addRowData(newRowId, addData, position, selectedRowId);
	            }
	            // 追加状態の変更セットに変更データを追加
	            changeSet.addCreated(newRowId, setCreatedChangeData(addData));
	            // セルを選択して入力モードにする
	            grid.editCell(currentRow + skipRow, firstCol, true);

	            // 確定checkboxにチェックをつけます。
	            autoFlagKakutei();

	            // 内訳表示の制御を行います。
	            controlSubGridRows();
	        };

	        /// <summary>任意の親明細に紐付く内訳情報を削除します。</summary>
	        var deleteSubGridData = function (rowId) {
	            var subGridData = getSubGridData(rowId, undefined),
                    i = 0, len = subGridData.length,
                    rowData;

	            for (; i < len; i++) {
	                rowData = subGridData[i];

	                if (App.isNull(rowData.no_seq_shiyo_yojitsu)) {
	                    continue;
	                }

	                // データの修正
	                rowData.dt_seizo = App.data.getDateTimeStringForQueryNoUtc(App.date.startOfDay(rowData.dt_seizo));
	                rowData.dt_shomi = App.data.getDateTimeStringForQueryNoUtc(App.date.startOfDay(rowData.dt_shomi));
	                rowData.su_shiyo = 0;

	                // ステータスを削除状態でセット
	                subGridChangeSet.addDeleted(rowData.subGridKey, rowData);
	            }

	            // subGridを削除
	            grid.find("#" + rowId).next(".ui-subgrid").remove();
	        }

	        /// <summary>行を削除します。</summary>
	        /// <param name="e">イベントデータ</param>
	        var deleteData = function (e) {
	            // エラーメッセージのクリア
	            App.ui.page.notifyAlert.clear();
	            var selectedRowId = getSelectedRowId()
                    , seizoYoteiSu = grid.getCell(selectedRowId, "su_seizo_yotei")
                    , skipRow = 1;
	            if (App.isUndefOrNull(selectedRowId)) {
	                return;
	            }
	            if (pageLangText.kakuteiKakuteiFlg.text === grid.getCell(selectedRowId, "flg_jisseki")) {
	                App.ui.page.notifyAlert.message(App.str.format(MS0168, pageLangText.del.text)).show();
	                return;
	            }
	            if (!App.isUndefOrNull(seizoYoteiSu) && seizoYoteiSu != "" && seizoYoteiSu > 0) {
	                App.ui.page.notifyAlert.message(App.str.format(MS0452, pageLangText._seizo.text)).show();
	                return;
	            }

	            // セル編集内容の保存
	            grid.saveCell(currentRow, currentCol);
	            removeAlertRow(selectedRowId);

	            // 削除対象に仕掛残が紐付く場合
	            if (grid.getCell(selectedRowId, "flg_uchiwake") !== "") {
	                deleteSubGridData(selectedRowId);
	            }

	            if (grid.find("#" + selectedRowId).closest("tr").prev().hasClass("ui-subgrid")) {
	                // 削除行の一つ前が内訳の場合、削除した後に内訳を選択しないようにします。
	                skipRow = 2;
	            }

	            // 削除状態の変更データの設定
	            var changeData = setDeletedChangeData(grid.getRowData(selectedRowId));
	            // 削除状態の変更セットに変更データを追加
	            changeSet.addDeleted(selectedRowId, changeData);
	            // 選択行の行データ削除
	            grid.delRowData(selectedRowId);
	            if (grid.getGridParam("records") > 0) {
	                // セルを選択して入力モードにする
	                //grid.editCell(currentRow === 1 ? currentRow : currentRow - 1, currentCol, true);
	                currentRow = currentRow <= skipRow ? currentRow : currentRow - skipRow;
	                grid.editCell(currentRow, currentCol, true);

	                // 前回選択行を選択した行に変更します。
	                autoFlagKakutei();
	            }
	            else {
	                preRowId = undefined;
	            }
	        };

	        /// <summary>0か空白の場合は、指定した値を返却する</summary>
	        /// <param name="target">チェックする値</param>
	        /// <param name="setValue">指定値</param>
	        var changeNullToValue = function (target, setValue) {
	            if (target == 0 || target == "") {
	                return parseFloat(setValue);
	            }
	            return parseFloat(target);
	        };
	        /// <summary>C/S数の計算と反映処理</summary>
	        var calcCaseReflect = function () {
	            for (var i = 0; i < checkedRow.length; i++) {
	                var id = checkedRow[i],
                        targetCellName = "su_seizo_jisseki";    // 計算結果を設定する項目のname
	                // 対象行の明細/バッチ数もしくは倍率が0以下または空白の場合は、C/S数をクリアする
	                var batch = grid.getCell(id, "su_batch_jisseki");   // バッチ数
	                var bairitsu = grid.getCell(id, "ritsu_kihon");   // 倍率
	                if (batch == 0 || batch == "" || bairitsu <= 0 || bairitsu == "") {
	                    grid.setCell(id, targetCellName, null);
	                }
	                else {
	                    // ========== 計算処理
	                    // 対象の行から計算用の各値を取得
	                    batch = parseFloat(batch);
	                    var bairitsu = changeNullToValue(grid.getCell(id, "ritsu_kihon"), 1);       // 倍率
	                    var haigoJuryo = changeNullToValue(grid.getCell(id, "wt_haigo_gokei"), 0);  // 合計配合重量(隠し項目)
	                    var wt_ko = changeNullToValue(grid.getCell(id, "wt_ko"), 1);                // 一個の量(隠し項目)
	                    var irisu = changeNullToValue(grid.getCell(id, "su_iri"), 1);               // 入数(隠し項目)
	                    var budomari = changeNullToValue(grid.getCell(id, "haigo_budomari"), pageLangText.budomariShokichi.text);    // 歩留
	                    var kanzan = parseFloat(pageLangText.budomariShokichi.text);
	                    // エラーメッセージ用ユニークキー
	                    //var unique = id + "_" + seizoJitsuSuCol;
	                    var unique = id + "_" + grid.getColumnIndexByName('su_seizo_jisseki');

	                    // ■（明細/バッチ数 ｘ (配合名マスタ．合計配合重量 × 明細/倍率）） ÷
	                    //      （品名マスタ．一個の量 ｘ 品名マスタ．入数） × （配合名マスタ．歩留 ÷ 換算(100)）
	                    var juryo_bairitsu = App.data.trimFixed(haigoJuryo * bairitsu);
	                    var calcVal1 = App.data.trimFixed(batch * juryo_bairitsu);
	                    var su_ko_iri = App.data.trimFixed(wt_ko * irisu);
	                    budomari = App.data.trimFixed(budomari / kanzan);
	                    var calcVal2 = App.data.trimFixed(calcVal1 / su_ko_iri);

	                    var resultCase = App.data.trimFixed(calcVal2 * budomari);
	                    if(grid.getCell(id, "kbn_hin") == '7' ) {
	                        resultCase = Math.ceil(resultCase / 0.001) * 0.001; //小数点第4位で切り上げ
	                    }else{
	                        resultCase = Math.floor(resultCase);    // 小数点以下は切り捨て
	                    }

	                    // 結果が上限桁数を超えていた場合はエラーメッセージを表示してcontinue
	                    if (resultCase > 9999999999) {
	                        var targetCode = grid.getCell(id, "cd_hinmei");
	                        var maximErrMsg = App.str.format(
                                MS0032
                                , targetCode + pageLangText.msg_param.text
                            );
	                        App.ui.page.notifyAlert.message(maximErrMsg, unique).show();
	                        continue;
	                    }
	                    else {
	                        // 計算結果を設定
	                        grid.setCell(id, targetCellName, resultCase);
	                    }
	                }
	                // データ設定
	                var changeData = setCreatedChangeData(grid.getRowData(id));
	                changeSet.addUpdated(id, targetCellName, resultCase, changeData);

	                // 製造実績数が修正された場合は、保存時に確定チェックをつける為、修正フラグをONにする
	                grid.jqGrid('setCell', id, 'isJissekiChange', pageLangText.trueFlg.text);
	                grid.jqGrid('setCell', id, 'isRemoveJissekiCheck', null);

	                // 製造実績数が修正された場合は按分チェックフラグを真にします。
	                setCellAndChangeSet(id, "isCheckAnbun", pageLangText.trueFlg.text);
	            }
	            // ローディングの終了
	            App.ui.loading.close();
	        };
	        /// <summary>C/S数反映ボタンのチェック処理</summary>
	        var checkReflect = function () {
	            // ローディング
	            App.ui.loading.show(pageLangText.nowProgressing.text);

	            // チェック行のクリア
	            checkedRow = new Array();
	            // 編集内容の保存
	            //saveEdit();
	            grid.saveCell(currentRow, currentCol);

	            // 行が選択できなかったら、返却
	            var selectedRowId = getSelectedRowId(false);
	            if (App.isUndefOrNull(selectedRowId)) {
	                App.ui.loading.close();
	                return;
	            }
	            // チェックされた行を取得する
	            var ids = grid.jqGrid('getDataIDs')
                    , cnt = 0
                    , isOldDay = false;
	            for (var i = 0; i < ids.length; i++) {
	                var id = ids[i];
	                var chk = grid.getCell(id, "check_reflect");
	                if (chk == pageLangText.trueFlg.text) {
	                    var code = grid.getCell(id, "cd_line");
	                    // ラインコードに入力がなければSKIP
	                    if (code != "") {
	                        checkedRow[cnt] = id;
	                        cnt++;
	                    }
	                }
	            }

	            // チェックがひとつもない場合は処理を終了する
	            if (cnt == 0) {
	                // infoで表示する
	                App.ui.loading.close();
	                App.ui.page.notifyInfo.message(MS0037).show();
	                return;
	            }
	            else {
	                // lengthプロパティを設定
	                checkedRow.length = cnt;
	                // C/S数の計算と反映処理
	                calcCaseReflect();
	            }
	        };
	        /// <summary>C/S数反映ボタンクリック時のイベント処理を行います。</summary>
	        $(".reflect-button").on("click", function () {
	            // チェック処理が始まるとローディング画像が表示されない為、setTimeoutで間を入れる
	            setTimeout(function () {
	                checkReflect();
	            }, 100);
	        });

	        //// データ変更処理 -- End

	        //// 保存処理 -- Start

	        // グリッドコントロール固有の保存処理

	        // <summary>データに変更がないかどうかを返します。</summary>
	        var noChange = function () {
	            //return App.isUnusable(changeSet) || changeSet.noChange());
	            var isExistsSubGrid = !App.isUnusable(subGridChangeSet);
	            return (App.isUnusable(changeSet) || (isExistsSubGrid && changeSet.noChange() && subGridChangeSet.noChange()))
                    || (App.isUnusable(changeSet) || (isExistsSubGrid === false && changeSet.noChange()))
	        };
	        /// <summary>編集内容の保存</summary>
	        var saveEdit = function () {
	            grid.saveCell(currentRow, currentCol);
	            saveCellSubGrid();
	        };

	        /// <summary>更新データを取得します。</summary>
	        var getPostData = function () {
	            //return changeSet.getChangeSet();
	            var changeSets = {
	                First: changeSet.getChangeSetData(),
	                Second: subGridChangeSet.getChangeSetData()
	            };
	            return JSON.stringify(changeSets);
	        };
	        /// <summary>データ変更エラーハンドリングを行います。</summary>
	        /// <param name="result">エラーの戻り値</param>
	        var handleSaveDataError = function (result) {
	            var ret = JSON.parse(result.rawText);
	            if (!App.isArray(ret) && App.isUndefOrNull(ret.Updated) && App.isUndefOrNull(ret.Deleted)) {

	                if (result.message === "uchiwakeZaiko") {
	                    App.ui.page.notifyAlert.message(MS0778).show();
	                    return;
	                }

	                App.ui.page.notifyAlert.message(result.message).show();
	                return;
	            }
	            var ids = grid.getDataIDs(),
                    newId,
                    value,
                    unique,
                    current;
	            // TODO: 画面の仕様に応じて以下の変数を変更します。
	            // TODO: ここまで

	            // データ整合性エラーのハンドリングを行います。
	            if (App.isArray(ret) && ret.length > 0) {
	                for (var i = 0; i < ret.length; i++) {
	                    // エラーメッセージの表示
	                    App.ui.page.notifyAlert.message(
                            pageLangText.invalidation.text + App.str.format(ret[i].Message, pageLangText._seizo.text)).show();
	                    // TODO: ここまで
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
	        /// <summary>変更を保存します。</summary>
	        /// <param name="e">イベントデータ</param>
	        var saveData = function (e) {
	            closeSaveConfirmDialog();
	            closeDeleteConfirmDialog();

	            // エラーメッセージのクリア
	            App.ui.page.notifyAlert.clear();
	            // 情報メッセージのクリア
	            App.ui.page.notifyInfo.clear();

	            // 製造実績数が修正されていた場合は確定にチェックする
	            //checkJissekiFlag();

	            // 削除対象の荷受番号がトレース用ロットトランの存在をチェックします。
	            var query = {
	                url: "../api/SeizoNippoLotTrace",
	                value: changeSet.getChangeSetData()
	            }

	            App.ajax.webpost(
                    "../api/SeizoNippoLotTrace", JSON.stringify(changeSet.getChangeSetData())
                ).done(function (result) {
                    if (result.__count > 0) {
                        var message = MS0783 + "<br><br>",
                            splashChar = "/",
                            colonChar = ":",
                            maxNumber = 3,
                            length = result.__count >= maxNumber ? maxNumber : result.__count;

                        for (var i = 0; i < length; i++) {
                            var dt_seizo = !App.isUndefOrNull(result.d[i].dt_seizo) ? App.data.getDate(result.d[i].dt_seizo) : null;

                            message += App.str.format(
                                pageLangText.detailMessageMS0783.text,
                                !App.isUndefOrNull(result.d[i].no_lot_seihin) ? result.d[i].no_lot_seihin : "",
                                !App.isUndefOrNull(result.d[i].no_lot_shikakari) ? result.d[i].no_lot_shikakari : "",
                                (!App.isUndefOrNull(dt_seizo) ? App.data.toDoubleDigits(dt_seizo["getMonth"]() + 1) : "") + splashChar + (!App.isUndefOrNull(dt_seizo) ? App.data.toDoubleDigits(dt_seizo["getDate"]()) : "")
                            );
                        }

                        if (result.__count > maxNumber) {
                            message += App.str.format("<br>" + pageLangText.moreOtherRows.text, result.__count - maxNumber);
                        }

                        $(".confirm-delete-tracing-message").html(message);
                        showDeleteTracingConfirmDialog();
                    }
                    else {
                        continueToSave();
                    }
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                    App.ui.loading.close();
                }).always(function () {
                });
	        };

	        var continueToSave = function () {
	            // ローディングの表示
	            App.ui.loading.show(pageLangText.nowSaving.text);

	            // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
	            var saveUrl = "../api/SeizoNippo";
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
                    // 確認ダイアログを閉めます
                    closeDeleteTracingConfirmDialog();

                    // ローディングの終了
                    App.ui.loading.close();
                });
            }

            var stopSave = function () {
                closeDeleteTracingConfirmDialog();
            }

	        /// <summary>保存前チェック</summary>
	        var checkSave = function () {
	            // エラーメッセージのクリア
	            App.ui.page.notifyAlert.clear();
	            // 編集内容の保存
	            saveEdit();
	            var isReturn = false;
	            // 変更がない場合は処理を抜ける
	            if (noChange()) {
	                App.ui.page.notifyInfo.message(pageLangText.noChange.text).show();
	                App.ui.loading.close();
	                return;
	            }
	            // 変更セット内にバリデーションエラーがある場合は処理を抜ける
	            if (!validateChangeSet()) {
	                App.ui.loading.close();
	                return;
	            }

	            // 内訳の変更セット内にバリデーションエラーがある場合は処理を抜ける
	            if (!validateChangeSetSubGrid()) {
	                App.ui.loading.close();
	                return;
	            }

	            if (kbnShomi == pageLangText.kinoShomikigenRequired.number) {
	                if (!shomiCheck()) {
	                    App.ui.loading.close();
	                    return
	                }
	            }
       
	            if (!seizoJissekicheck()) {
	                App.ui.loading.close();
	                App.ui.page.notifyAlert.message(MS0806).show();
	                return;
	            }

	            // 関連する按分データを削除するため、対象の伝送状態をチェックする
	            if (!getDensochu()) {
	                // 伝送中の場合は処理中止
	                App.ui.loading.close();
	                App.ui.page.notifyAlert.message(MS0749).show();
	                return;
	            }

	            // 製造実績数が修正されていた場合は確定にチェックする
	            checkJissekiFlag();

	            // 製造実績数0で確定保存する場合はエラー
	            // 按分画面に不要な製造実績が表示される事を防止・製造実績I/Fで実績０の取込エラーが起きる事を防止
	            //	            if (!checkKakuteiJissekiSuZero(changeSet.changeSet.created)
	            //                        || !checkKakuteiJissekiSuZero(changeSet.changeSet.updated)) {
	            //	                App.ui.loading.close();
	            //	                //App.ui.page.notifyAlert.message(MS0753).show();
	            //	                return;
	            //	            }

	            ///// 各明細のチェック
	            //// mikakutei:確定チェックを外して保存する際、按分テーブルに登録があればtrueとなる
	            //// denso_sumi:削除対象の按分データに伝送済のものがある場合はtrueとなる
	            //// param:対象の製品ロット番号
	            //var flgs = { "mikakutei": false, "denso_sumi": false, "param": "" };
	            //flgs = checkDensojotai(flgs);

	            //// 確定チェックを外して保存する際、按分テーブルに登録がある場合はエラー
	            //if (flgs.mikakutei) {
	            //    App.ui.loading.close();
	            //    App.ui.page.notifyAlert.message(
	            //        App.str.format(MS0754, flgs.param)).show();
	            //    return;
	            //}

	            // 製造予定数・製造実績数の0チェックする
	            if (!suryoZeroCheck()) {
	                // チェックNGの場合は処理中止
	                App.ui.loading.close();
	                return;
	            }

	            if (getAnbunDataAll(changeSet.changeSet.updated, true)) {
	                App.ui.loading.close();
	                confirmId = "AnbunUpd";
	                showConfirmDialog(MS0762);
	                return;
	            }

	            checkSave02();

	            //App.ui.loading.close();
	            //if (flgs.denso_sumi) {
	            //    // 削除対象の按分データに伝送済のものがある場合は確認ダイアログを表示する
	            //    showDeleteConfirmDialog();
	            //}
	            //else {
	            //    //showSaveConfirmDialog();
	            //    saveData();
	            //}
	        };

	        /// <summary>保存前チェック02</summary>
	        var checkSave02 = function () {
	            if (getAnbunDataAll(changeSet.changeSet.deleted, false)) {
	                App.ui.loading.close();
	                confirmId = "AnbunDel";
	                showConfirmDialog(MS0763);
	                return;
	            }

	            App.ui.loading.close();
	            saveData();
	        };

	        /// <summary>保存時の確定チェック処理</summary>
	        var checkJissekiFlag = function () {
	            var ids = grid.jqGrid('getDataIDs'),
                    id,
                    cellName = "flg_jisseki";

	            for (var i = 0; i < ids.length; i++) {
	                id = ids[i];

	                var isJisseki = grid.jqGrid('getCell', id, 'isJissekiChange');
	                var isRemoved = grid.jqGrid('getCell', id, 'isRemoveJissekiCheck');
	                if (isJisseki == pageLangText.trueFlg.text && isRemoved == "") {
	                    // 製造実績数の修正フラグがONの場合、確定にチェックする
	                    // 但し意図的にフラグをoffにした場合はこの処理を行わない
	                    var changeData = setUpdatedChangeData(grid.getRowData(id));
	                    changeSet.addUpdated(id, cellName, pageLangText.trueFlg.text, changeData);
	                }
	            }
	        };

	        /// <summary>使用予実按分トランから伝送中のデータを取得します</summary>
	        var getDensochu = function () {
	            var isValid = true;
	            var _query = {
	                url: "../Services/FoodProcsService.svc/tr_sap_shiyo_yojitsu_anbun",
	                filter: "kbn_jotai_denso eq " + pageLangText.densoJotaiKbnDensochu.text,
	                top: 1
	            };

	            App.ajax.webgetSync(
                    App.data.toODataFormat(_query)
                ).done(function (result) {
                    if (result.d.length > 0) {
                        // 一件でも伝送中があれば連携中なので、処理を中止する
                        isValid = false;
                    }
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                    App.ui.loading.close();
                });
	            return isValid;
	        };
	        /// <summary>各明細のチェック処理</summary>
	        /// <param name="flgs">チェック用フラグの配列</param>
	        var checkDensojotai = function (flgs) {
	            var updated = changeSet.changeSet.updated;
	            for (upId in updated) {
	                var upData = updated[upId];

	                // 確定以外の場合
	                if (upData.flg_jisseki != pageLangText.trueFlg.text) {
	                    // 按分トランにデータがあるかどうか
	                    if (getAnbunData(upData.no_lot_seihin)) {
	                        // 実績数が編集されていなければOKとする
	                        var isChange = grid.jqGrid('getCell', upId, 'isJissekiChange')
	                        if (isChange != pageLangText.trueFlg.text) {
	                            continue;
	                        }

	                        // データがある場合はエラーとするため、この時点で処理を抜ける
	                        flgs.mikakutei = true;
	                        flgs.param = upData.no_lot_seihin;
	                        return flgs;
	                    }

	                    // 伝送状態が伝送済のデータがあるかどうか
	                    if (getDensosumi(upData.no_lot_seihin)) {
	                        // 伝送済のデータが1件でも存在した時点で処理を抜ける
	                        flgs.denso_sumi = true;
	                        return flgs;
	                    }
	                }
	            }

	            var deleted = changeSet.changeSet.deleted;
	            for (delId in deleted) {
	                var delData = deleted[delId];

	                // 按分トランにデータがあるかどうか
	                if (getAnbunData(delData.no_lot_seihin)) {
	                    // データがある場合はエラーとするため、この時点で処理を抜ける
	                    flgs.mikakutei = true;
	                    flgs.param = delData.no_lot_seihin;
	                    return flgs;
	                }

	                // 伝送状態が伝送済のデータがあるかどうか
	                if (getDensosumi(upData.no_lot_seihin)) {
	                    flgs.denso_sumi = true;
	                    return flgs;
	                }
	            }

	            return flgs;
	        };
	        /// <summary>使用予実按分トランから伝送済のデータを取得します</summary>
	        /// <param name="seihinLot">製品ロット番号</param>
	        var getDensosumi = function (seihinLot) {
	            var isSumi = false;
	            var _query = {
	                url: "../Services/FoodProcsService.svc/vw_tr_sap_shiyo_yojitsu_anbun_02",
	                filter: "no_lot_seihin eq '" + seihinLot
                        + "' and kbn_jotai_denso eq " + pageLangText.densoJotaiKbnDensosumi.text,
	                top: 1
	            };

	            App.ajax.webgetSync(
                    App.data.toODataFormat(_query)
                ).done(function (result) {
                    if (result.d.length > 0) {
                        isSumi = true;
                    }
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                    App.ui.loading.close();
                });
	            return isSumi;
	        };

	        /// <summary>按分データの存在チェックを行います。</summary>
	        /// <param name="data">チェック対象のchangeSet</param>
	        /// <param name="isUpdate">changeSetがUpdatedなら真、Deletedなら偽</param>
	        var getAnbunDataAll = function (data, isUpdate) {
	            var filter = ""
                    , filterOption = new Array()
                    , no_lot_seihin
                    , query = {}
	                , isExist = false
                    , strFormat = App.str.format;

	            for (var d in data) {
	                if (!data.hasOwnProperty(d)) {
	                    continue;
	                }

	                // 製品ロット番号がない場合、もしくは按分チェックフラグが真でなければスキップする
	                no_lot_seihin = data[d].no_lot_seihin;
	                if (App.isUndefOrNull(no_lot_seihin)
                        || (isUpdate && data[d].isCheckAnbun != pageLangText.trueFlg.text)) {
	                    continue;
	                }
	                filterOption.push(strFormat("no_lot_seihin eq '{0}'", no_lot_seihin));
	            }

	            // 対象になる製品ロット番号がなければ按分トランのチェックを行わない。
	            if (filterOption.length === 0) {
	                return false;
	            }

	            filter = filterOption.join(" or ");
	            if (isUpdate) {
	                // 更新処理の場合は伝送済みまたは伝送待ちを条件に追加する
	                filter = strFormat("( {0} )", filter);
	                filter = filter + " and (kbn_jotai_denso eq {0} or kbn_jotai_denso eq {1})";
	                filter = strFormat(filter, pageLangText.densoJotaiKbnDensomachi.text, pageLangText.densoJotaiKbnDensosumi.text);
	            }

	            // 検索条件
	            query = {
	                url: "../Services/FoodProcsService.svc/tr_sap_shiyo_yojitsu_anbun",
	                filter: filter,
	                top: 1
	            };

	            // 検索処理
	            App.ajax.webgetSync(
                    App.data.toODataFormat(query)
                ).done(function (result) {
                    if (result.d.length > 0) {
                        // 一件でも存在すればtrue
                        isExist = true;
                    }
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                    App.ui.loading.close();
                });
	            return isExist;
	        };

	        /// <summary>製造実績数0で確定した場合はエラー</summary>
	        /// <param name="checkData">チェック対象のchangeSet</param>
	        //	        var checkKakuteiJissekiSuZero = function (checkData) {
	        //	            for (p in checkData) {
	        //	                var data = checkData[p];
	        //	                if (data.flg_jisseki == pageLangText.trueFlg.text
	        //                        && data.su_seizo_jisseki == 0) {
	        //	                    var unique = p + "_" + firstCol;
	        //	                    App.ui.page.notifyAlert.message(MS0753, unique).show();
	        //	                    return false;
	        //	                }
	        //	            }
	        //	            return true;
	        //	        };
	        /// <summary>チェック対象の製品が使用予実按分トランに登録があるかどうか</summary>
	        /// <param name="seihinLot">製品ロット番号</param>
	        var getAnbunData = function (seihinLot) {
	            var isExist = false;
	            var _query = {
	                url: "../Services/FoodProcsService.svc/tr_sap_shiyo_yojitsu_anbun",
	                filter: "no_lot_seihin eq '" + seihinLot + "'",
	                top: 1
	            };

	            App.ajax.webgetSync(
                    App.data.toODataFormat(_query)
                ).done(function (result) {
                    if (result.d.length > 0) {
                        // 一件でも存在すればtrue
                        isExist = true;
                    }
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                    App.ui.loading.close();
                });
	            return isExist;
	        };

            /// <summary>行追加：変更セット毎に製造実績数0チェックを実施</summary>
            /// <summary>更新：変更セット毎に製造予定数/製造実績数0チェック　および　更新データの存在チェックを実施</summary>
            /// <summary>＜返却値＞成功：True,失敗：False</summary>
            var suryoZeroCheck = function () {
                var suJitsu = 0;
                var noLotSeihin = '';
                var msId = '';
                // 行追加データをチェック
                for (p in changeSet.changeSet.created) {
                    if (!changeSet.changeSet.created.hasOwnProperty(p)) {
                        continue;
                    }
                    // 製造実績数
                    suJitsu = grid.jqGrid('getCell', p, 'su_seizo_jisseki');
                    if (suJitsu == 0) {
                        // セルを選択して入力モードを解除する
                        grid.editCell(p, grid.getColumnIndexByName('su_seizo_jisseki'), false);
                        // エラー背景色セット
                        grid.setCell(p, 'su_seizo_jisseki', suJitsu, { background: "#ff6666" });
                        // エラーメッセージの表示
                        App.ui.page.notifyAlert.message(MS0829, p + "_" + grid.getColumnIndexByName("su_seizo_jisseki")).show();
                        return false;
                    }
                }
                // 更新データをチェック
                for (p in changeSet.changeSet.updated) {
                    if (!changeSet.changeSet.updated.hasOwnProperty(p)) {
                        continue;
                    }
                    // 製造実績数
                    suJitsu = grid.jqGrid('getCell', p, 'su_seizo_jisseki');
                    // 製品ロット番号
                    noLotSeihin = grid.jqGrid('getCell', p, 'no_lot_seihin');
                    // メッセージID
                    msId = isValidSuYotei(noLotSeihin);
                    if (suJitsu == 0 && msId == 'MS0829') {
                        // セルを選択して入力モードを解除する
                        grid.editCell(p, grid.getColumnIndexByName('su_seizo_jisseki'), false);
                        // エラー背景色セット
                        grid.setCell(p, 'su_seizo_jisseki', suJitsu, { background: "#ff6666" });
                        // エラーメッセージの表示
                        App.ui.page.notifyAlert.message(MS0829, p + "_" + grid.getColumnIndexByName("su_seizo_jisseki")).show();
                        return false;
                    } else if (msId == 'MS0823') {
                        // セルを選択して入力モードを解除する
                        grid.editCell(p, grid.getColumnIndexByName('cd_hinmei'), false);
                        // エラーメッセージの表示
                        App.ui.page.notifyAlert.message(MS0823).show();
                        return false;
                    }
                }
                return true;
            };

            /// <summary>製造予定数のDBデータに対して0チェックを行います。</summary>
            /// <summary>＜返却値＞メッセージID</summary>
            /// <param name="value">製品ロット番号</param>
            var isValidSuYotei = function (value) {
                // メッセージID
                var msId = ''
                    , _query = {
                        url: "../Services/FoodProcsService.svc/tr_keikaku_seihin",
                        filter: "no_lot_seihin eq '" + value + "'",
                        top: 1
                    };
                App.ajax.webgetSync(
                    App.data.toODataFormat(_query)
                ).done(function (result) {
                    if (result.d.length == 0) {
                        // 更新対象が存在しない場合、エラー
                        msId = 'MS0823';
                    } else if (result.d[0].su_seizo_yotei == 0) {
                        // 製造予定数が0の場合、エラー
                        msId = 'MS0829';
                    };
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                });
                return msId;
            };

	        //// 保存処理 -- End

	        //// バリデーション -- Start

	        // グリッドコントロール固有のバリデーション

	        // TODO: 画面の仕様に応じて以下のカスタムバリデーション定義を変更してください。
	        validationSetting.cd_hinmei.rules.custom = function (value) {
	            // 検索条件にラインが選択されているとき
	            if (isLineSelect) {
	                if (!isValidCode("cd_hinmei", value)) {
	                    return false;
	                }
	                if (!isValidCode("cd_hinmei_seizoline", value)) {
	                    return false;
	                }
	                return true;
	            }
	            return isValidCode("cd_hinmei", value);
	        };

	        // 賞味期限の必須チェック
	        var isValidDtShomi = function (dt) {
	            var isValid = true;
	            if (kbnShomi == pageLangText.kinoShomikigenRequired.number) {
	                if (dt == "") {
	                    isValid = false;
	                } else {
	                    isValid = true;
	                }
	            } else {
	                isValid = true;
	            }
	            return isValid;
	        };

	        validationSetting.dt_shomi.rules.custom = function (value) {
	            return isValidDtShomi(value);
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
	        var validateCell = function (selectedRowId, cellName, value, iCol, _subGrid) {
	            var unique = selectedRowId + "_" + iCol,
                    val = {},
                    result, _grid,
                    isSubGrid = !App.isUndef(_subGrid);

	            // 内訳でのエラーを表示するために明細を指定します。
	            _grid = isSubGrid ? _subGrid : grid;

	            // エラーメッセージの解除
	            App.ui.page.notifyAlert.remove(unique);
	            _grid.setCell(selectedRowId, iCol, value, { background: 'none' });
	            val[cellName] = value;
	            // バリデーションのコールバック関数の実行をスキップ
	            result = v.validate(val, { suppressCallback: false });
	            if (result.errors.length) {
	                // エラーメッセージの表示
	                App.ui.page.notifyAlert.message(result.errors[0].message, unique).show();
	                // 対象セルの背景変更
	                _grid.setCell(selectedRowId, iCol, value, { background: '#ff6666' });
	                return false;
	            }

	            // subGrid編集時のチェック
	            if (isSubGrid && cellName === "su_shiyo") {
	                var zaikoVal = parseFloat(_grid.getCell(selectedRowId, "su_zaiko")),
                        conShiyoVal = parseFloat(_grid.getCell(selectedRowId, "con_su_shiyo")),
                        sumVal = App.data.trimFixed(zaikoVal + conShiyoVal);
	                if (sumVal < parseFloat(value)) {
	                    // エラーメッセージの表示
	                    App.ui.page.notifyAlert.message(App.str.format(MS0450, [0, sumVal.toString()]), unique).show();
	                    // 対象セルの背景変更
	                    _grid.setCell(selectedRowId, iCol, value, { background: '#ff6666' });
	                    return false;
	                }
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
	        /// <summary>カレントの行バリデーションを実行します。</summary>
	        /// <param name="selectedRowId">選択行ID</param>
	        var validateRowSubGrid = function (rowId) {
	            var isValid = true,
                    subGridId = "item-grid_" + rowId.split("_")[0] + "_t",
                    _grid = $("#" + subGridId),
                    colModel = _grid.getGridParam("colModel"),
                    iRow = $('#' + rowId)[0].rowIndex;

	            for (var i = 0; i < colModel.length; i++) {
	                if (colModel[i].name === "su_shiyo"
                        && !validateCell(rowId, "su_shiyo", _grid.getCell(rowId, "su_shiyo"), i, _grid)) {
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

	        /// <summary>変更セットのバリデーションを実行します。</summary>
	        var validateChangeSetSubGrid = function () {
	            for (p in subGridChangeSet.changeSet.created) {
	                if (!subGridChangeSet.changeSet.created.hasOwnProperty(p)) {
	                    continue;
	                }
	                // カレントの行バリデーションを実行
	                if (!validateRowSubGrid(p)) {
	                    return false;
	                }
	            }
	            for (p in subGridChangeSet.changeSet.updated) {
	                if (!subGridChangeSet.changeSet.updated.hasOwnProperty(p)) {
	                    continue;
	                }
	                // カレントの行バリデーションを実行
	                if (!validateRowSubGrid(p)) {
	                    return false;
	                }
	            }
	            return true;
	        };

	        var shomiCheck = function () {
	            for (p in changeSet.changeSet.created) {
	                if (!changeSet.changeSet.created.hasOwnProperty(p)) {
	                    continue;
	                }
	                var shomi = App.date.startOfDay(App.date.localDate(grid.jqGrid('getCell', p, 'dt_shomi')));
	                var seizo = App.date.startOfDay(App.date.localDate(grid.jqGrid('getCell', p, 'dt_seizo')));
	                if (seizo > shomi) {
	                    App.ui.page.notifyAlert.message(
                            App.str.format(pageLangText.shomiErr.text
                                , pageLangText.dt_seizo.text
                                , pageLangText.dd_shomi_kigen.text
	                    //), p + "_" + shomiCol).show();
                            ), p + "_" + grid.getColumnIndexByName("dt_shomi")).show();
	                    grid.setCell(p, 'dt_shomi', "", { background: "ff6666" });
	                    return false;
	                }
	            }
	            for (p in changeSet.changeSet.updated) {
	                if (!changeSet.changeSet.updated.hasOwnProperty(p)) {
	                    continue;
	                }
	                var shomi = App.date.startOfDay(App.date.localDate(grid.jqGrid('getCell', p, 'dt_shomi')));
	                var seizo = App.date.startOfDay(App.date.localDate(grid.jqGrid('getCell', p, 'dt_seizo')));
	                if (seizo > shomi) {
	                    App.ui.page.notifyAlert.message(
                            App.str.format(pageLangText.shomiErr.text
                                , pageLangText.dt_seizo.text
                                , pageLangText.dd_shomi_kigen.text
	                    //), p + "_" + shomiCol).show();
                            ), p + "_" + grid.getColumnIndexByName("dt_shomi")).show();
	                    grid.setCell(p, 'dt_shomi', "", { background: "ff6666" });
	                    return false;
	                }
	            }
	            return true;
	        };

	        var seizoJissekicheck = function () {
	            var ids = grid.jqGrid('getDataIDs');
	                check_flg = true;
	            for (var i = 0; i < ids.length; i++) {
	                var id = ids[i],
                        suSeizoJisseki = grid.getCell(id, "su_seizo_jisseki");
                        cdHinmei = grid.getCell(id, "cd_hinmei");
	                if (suSeizoJisseki - Math.floor(suSeizoJisseki) !== 0) {
	                    var hinkubun,
                           // check_flg = true;
                        kbn_cd = new Array();
	                    App.deferred.parallel({
	                        hinkubun: App.ajax.webgetSync(
                                   "../Services/FoodProcsService.svc/ma_hinmei()?$filter=kbn_hin eq "
                                   + pageLangText.seihinHinKbn.text
                                   + " and cd_hinmei eq '" + grid.getCell(id, "cd_hinmei") + "'"
                                )
	                    }).done(function (result) {
	                        hinkubun = result.successes.hinkubun.d;
	                            for (var j = 0; j < hinkubun.length; j++) {
	                                kbn_cd = hinkubun[j]["cd_hinmei"]
	                                if (kbn_cd === grid.getCell(id, "cd_hinmei")) {
	                                    check_flg = false;
	                                }
	                            }
	                    }).fail(function (result) {
	                        App.ui.loading.close();
	                        App.ui.page.notifyAlert.message(MS0082).show();
	                    });
	                }
	            }
	            return check_flg;
	        };

	        /// <summary>データベース問い合わせチェックを行います。</summary>
	        /// <param name="colName">カラム物理名</param>
	        /// <param name="code">コード値</param>
	        var isValidCode = function (colName, code) {
	            var isValid = false
                    , _query
                    , url = ""
					, cd_line = $(".search-criteria").toJSON().line
                    , rowid = getSelectedRowId(false);
	            switch (colName) {
	                case "cd_hinmei":
	                    _query = {
	                        url: "../Services/FoodProcsService.svc/ma_hinmei",
	                        filter: "cd_hinmei eq '" + code + "' and flg_mishiyo eq " + pageLangText.falseFlg.text
                                    + " and (kbn_hin eq " + pageLangText.seihinHinKbn.text
                                    + " or kbn_hin eq " + pageLangText.jikaGenryoHinKbn.text + ")",
	                        top: 1
	                    }
	                    break;
	                case "cd_hinmei_seizoline":
	                    _query = {
	                        url: "../Services/FoodProcsService.svc/vw_ma_seizo_line_02",
	                        filter: "kbn_master eq " + pageLangText.hinmeiMasterSeizoLineMasterKbn.text
                                    + " and (seizo_line_mishiyo eq " + pageLangText.falseFlg.text
                                    + " or line_mishiyo eq " + pageLangText.falseFlg.text + ")"
                                    + " and cd_haigo eq '" + code + "'"
                                    + " and cd_shokuba eq '" + $(".search-criteria").toJSON().shokuba + "'"
                                    + " and cd_line eq '" + cd_line + "'",
	                        top: 1
	                    }
	                    break;
	                case "cd_line":
	                    _query = {
	                        url: "../Services/FoodProcsService.svc/vw_ma_seizo_line_02",
	                        filter: "kbn_master eq " + pageLangText.hinmeiMasterSeizoLineMasterKbn.text
                                    + " and seizo_line_mishiyo eq " + pageLangText.falseFlg.text
                                    + " and line_mishiyo eq " + pageLangText.falseFlg.text
                                    + " and cd_haigo eq '" + grid.getCell(rowid, "cd_hinmei") + "'"
                                    + " and cd_shokuba eq '" + $(".search-criteria").toJSON().shokuba + "'"
                                    + " and cd_line eq '" + code + "'",
	                        top: 1
	                    }
	                    break;
	                default:
	                    return;
	            }
	            App.ajax.webgetSync(
                    App.data.toODataFormat(_query)
                ).done(function (result) {
                    if (result.d.length > 0) {
                        isValid = true;
                    }
                    else if (colName === "cd_hinmei") {
                        if (!isLineSelect) {
                            grid.setCell(rowid, "cd_line", null);
                            grid.setCell(rowid, "nm_line", null);
                            validationSetting.cd_hinmei.messages.custom = MS0049;
                            // 更新状態の変更セットに変更データを追加
                            var changeData = setCreatedChangeData(grid.getRowData(rowid));
                            changeSet.addUpdated(rowid, "cd_line", "", changeData);
                        }
                    }
                    else if (colName === "cd_hinmei_seizoline") {
                        validationSetting.cd_hinmei.messages.custom = MS0657;
                    }
                    else if (colName === "cd_line") {
                        if (grid.getCell(rowid, "cd_hinmei") === "") {
                            validationSetting.cd_line.messages.custom = MS0664;
                        }
                        else {
                            validationSetting.cd_line.messages.custom = MS0049;
                        }
                    }
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                });
	            return isValid;
	        };
	        /// <summary>数値項目の値チェックを行います</summary>
	        var isValidDecimalCheck = function (colName, value) {
	            var isValid = true;
	            switch (colName) {
	                case "su_seizo_yotei":
	                    if (!App.isUndefOrNull(value) && value != "" && value > 0) {
	                        isValid = false;
	                    }
	                    break;
	            }
	            return isValid;
	        };

	        //// バリデーション -- End

	        /// 各種処理の定義 -- Start

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
	        /// <summary>前ページよりパラメータを取得し、条件によって初期表示時に検索を行います。</summary>
	        // TODO: 画面の仕様に応じて以下の値を変更します。
	        var paramMasterKubun = '<%= Page.Request.QueryString.Get("kbn_master") %>',
                paramHaigoCode = '<%= Page.Request.QueryString.Get("cd_haigo") %>';
	        if ((!App.isUndefOrNull(paramMasterKubun) && paramMasterKubun.length > 0)
                        || (!App.isUndefOrNull(paramHaigoCode) && paramHaigoCode.length > 0)) {
	            $("#condition-masterkubun").val(paramMasterKubun);
	            $("#condition-haigocode").val(paramHaigoCode);
	            $(".find-button").trigger("click");
	        }
	        // TODO: ここまで
	        /// <summary> メニューへ戻る処理。 </summary>
	        var backToMenu = function () {
	            // IEバグによる例外発生をキャッチします。例外発生時は何もしません。
	            try {
	                document.location = pageLangText.menuPath.url;
	            }
	            catch (e) {
	                // 何もしない
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
	        /// <summary>データに変更があり、未保存の状態でページを離れる際に確認を行います。</summary>
	        //別画面に遷移したりするときに実行する関数の定義
	        var onBeforeUnload = function () {
	            //データを変更したかどうかは各画面でチェックし、保持する
	            if (!noChange()) {
	                return pageLangText.unloadWithoutSave.text;
	            }
	        };

	        // Cookieを1秒ごとにチェックする
	        var onComplete = function () {
	            if (app_util.prototype.getCookieValue(pageLangText.SeizoNippoCookie.text) == pageLangText.checkCookie.text) {
	                app_util.prototype.deleteCookie(pageLangText.SeizoNippoCookie.text);
	                //ローディング終了
	                App.ui.loading.close();
	            }
	            else {
	                // 再起してCookieが作成されたか監視
	                setTimeout(onComplete, 1000);
	            }
	        };
	        /// <summary>Excelファイル出力を行います。</summary>
	        var printExcel = function (isAllLine, e) {
	            isChanged = false;
	            var criteria = $(".search-criteria").toJSON();
	            var query = {
	                url: "../api/SeizoNippoExcel",
	                dt_seizo: App.data.getDateTimeStringForQueryNoUtc(criteria.dt_seizo),
	                cd_shokuba: criteria.shokuba,
	                cd_line: criteria.line,
	                skip: querySetting.skip,
	                top: querySetting.top,
	                lang: App.ui.page.lang,
	                UTC: new Date().getTimezoneOffset() / 60,
	                userName: encodeURIComponent(App.ui.page.user.Name),
	                today: App.data.getDateTimeStringForQuery(new Date(), true)
	            }

	            // 処理中を表示する
	            App.ui.loading.show(pageLangText.nowProgressing.text);
	            // 必要な情報を渡します
	            var url = App.data.toWebAPIFormat(query);
	            // ローディングの終了
	            //App.ui.loading.close();

	            window.open(url, '_parent');
	            // Cookieを監視する
	            onComplete();
	        };
	        /// <summary> クリア処理 </summary>
	        var clearData = function () {
	            changeSet = new App.ui.page.changeSet();
	            location.reload();
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
	        };
	        /// <summary>全チェック／解除処理</summary>
	        var checkAll = function () {
	            // 全チェックの状態を設定する
	            if (checkButtonStatus === pageLangText.checkBoxCheckOn.text) {
	                checkButtonStatus = pageLangText.checkBoxCheckOff.text;
	            }
	            else {
	                checkButtonStatus = pageLangText.checkBoxCheckOn.text;
	            }
	            var ids = grid.jqGrid('getDataIDs'),
                    jissekiCol = grid.getColumnIndexByName('flg_jisseki');
	            for (var i = 0; i < ids.length; i++) {
	                var id = ids[i];
	                // 未使用行には何もしない
	                if (grid.jqGrid('getCell', id, 'flg_mishiyo_hinmei') === pageLangText.trueFlg.text
                            || grid.jqGrid('getCell', id, 'flg_mishiyo_line') === pageLangText.trueFlg.text
                            || grid.jqGrid('getCell', id, 'flg_mishiyo_seizo_line') === pageLangText.trueFlg.text) {
	                    continue;
	                }

	                // 不活性時はスキップします。
	                if ($("#" + id, grid).find("td:eq(" + jissekiCol + ") input[type='checkbox']").prop("disabled")) {
	                    continue;
	                }

	                // 状態のセット
	                grid.setCell(id, 'flg_jisseki', checkButtonStatus);

	                // 確定チェックボックスを意図的に変更した場合は按分チェックフラグを真にします。
	                setCellAndChangeSet(id, "isCheckAnbun", pageLangText.trueFlg.text);

	                // 更新状態の変更データの設定
	                var changeData = setUpdatedChangeData(grid.getRowData(id));
	                // 更新状態の変更セットに変更データを追加
	                changeSet.addUpdated(id, "flg_jisseki", checkButtonStatus, changeData);
	                // セルの操作可否を設定する
	                //setCellEditable(id, grid.getCell(id, 'flg_jisseki'));
	                setCellEditable(id, checkButtonStatus);
	            }
	            // ローディングの終了
	            App.ui.loading.close();
	        };
	        /// <summary>検索条件変更チェックメッセージを出力します。</summary>
	        /// <param name="outMessage">出力メッセージ</param>
	        var showCriteriaChange = function (outMessage) {
	            // 情報メッセージのクリア
	            App.ui.page.notifyInfo.clear();
	            // エラーメッセージのクリア
	            App.ui.page.notifyAlert.clear();
	            var alertMessage = "";
	            switch (outMessage) {
	                case "navigate":
	                    alertMessage = pageLangText.navigate.text;
	                    break;
	                case "rowChange":
	                    alertMessage = pageLangText.rowChange.text;
	                    break;
	                case "lineAdd":
	                    alertMessage = pageLangText.lineAdd.text;
	                    break;
	                case "lineDel":
	                    alertMessage = pageLangText.lineDel.text;
	                    break;
	                case "save":
	                    alertMessage = pageLangText.save.text;
	                    break;
	                case "del":
	                    alertMessage = pageLangText.del.text;
	                    break;
	                case "colchange":
	                    alertMessage = pageLangText.colchange.text;
	                    break;
	                case "output":
	                    alertMessage = pageLangText.output.text;
	                    break;
	                case "checkAndReset":
	                    alertMessage = pageLangText.checkAndReset.text;
	                    break;
	                case "execute":
	                    alertMessage = pageLangText.execute.text;
	                    break;
	            }
	            // 情報メッセージ出力
	            App.ui.page.notifyAlert.message(App.str.format(
                    pageLangText.criteriaChange.text, pageLangText.searchCriteria.text, alertMessage)).show();
	        };

	        /// <summary>チェックボックスの操作可/不可の切替</summary>
	        /// <param name="rowId">行番号</param>
	        /// <param name="cellName">セル名</param>
	        /// <param name="bool">操作可：true　操作不可：false</param>
	        var ctrlCheckBox = function (rowId, cellName, bool) {
	            var id = parseInt(rowId) - 1;
	            if (bool) {
	                // 操作可
	                $(".jqgrow:eq(" + (id) + ") td:eq(" + grid.getColumnIndexByName(cellName) + ") input:checkbox").attr("disabled", false);
	            }
	            else {
	                // 操作不可
	                $(".jqgrow:eq(" + (id) + ") td:eq(" + grid.getColumnIndexByName(cellName) + ") input:checkbox").attr("disabled", true);
	            }
	        };
	        /// <summary>テキストボックス項目の操作可/不可の切替</summary>
	        /// <param name="rowId">行番号</param>
	        /// <param name="cellName">セル名</param>
	        /// <param name="bool">操作可：false　操作不可：true</param>
	        var ctrlCellItem = function (rowId, cellName, bool) {
	            if (bool) {
	                // 操作可
	                grid.deleteColumnClass(rowId, cellName, 'not-editable-cell');
	            }
	            else {
	                // 操作不可
	                grid.jqGrid('setCell', rowId, cellName, '', 'not-editable-cell');
	            }
	        };
	        /// <summary> セルの操作可否を設定する </summary>
	        /// <param name="value">確定チェックボックスの値</param>
	        var setCellEditable = function (rowId, value) {
	            var flgMishiyo = pageLangText.falseFlg.text,
                    flgKakutei = value,
                    ctrlBool = true,    // 操作可：true 操作不可：false
                    updateDate = grid.jqGrid('getCell', rowId, 'dt_update');    // 既存行かどうかの判定用

	            ///// 未使用行の判定
	            // 品名マスタ、ラインマスタ、製造ラインマスタのいずれかの未使用フラグが未使用状態の場合、未使用フラグにtrueを設定
	            if (grid.jqGrid('getCell', rowId, 'flg_mishiyo_hinmei') == pageLangText.trueFlg.text
                        || grid.jqGrid('getCell', rowId, 'flg_mishiyo_line') == pageLangText.trueFlg.text
                        || grid.jqGrid('getCell', rowId, 'flg_mishiyo_seizo_line') == pageLangText.trueFlg.text) {
	                flgMishiyo = pageLangText.trueFlg.text;
	                // 未使用行の場合、確定チェックボックスを操作不可とする
	                ctrlCheckBox(rowId, "flg_jisseki", false);
	            }

	            // 未使用行または確定チェックボックスにチェックが入った状態の場合
	            if (flgMishiyo == pageLangText.trueFlg.text || flgKakutei == pageLangText.trueFlg.text) {
	                // 編集可能項目を編集不可とする
	                ctrlBool = false;
	            }

	            ///// 各項目の編集可否の設定
	            if (App.isUndefOrNull(updateDate) || updateDate == "") {
	                // 更新日に値がない場合は新規行（既存行の品名コードとラインコードは操作不可のまま）
	                ctrlCellItem(rowId, "cd_hinmei", ctrlBool);
	                if (!isLineSelect) {
	                    // 検索条件/ラインコードに入力がない場合
	                    ctrlCellItem(rowId, "cd_line", ctrlBool);
	                }
	            }
	            ctrlCellItem(rowId, "su_seizo_jisseki", ctrlBool);
	            ctrlCellItem(rowId, "su_batch_jisseki", ctrlBool);
	            ctrlCellItem(rowId, "dt_shomi", ctrlBool);
	            ctrlCellItem(rowId, "no_lot_hyoji", ctrlBool);

	            // 反映チェックボックス
	            grid.setCell(rowId, "check_reflect", "0");  // 一度リセット
	            ctrlCheckBox(rowId, "check_reflect", ctrlBool);

	            // 実績checkboxのチェックを外した場合はisRemoveJissekiCheckフラグを立てる
	            if (ctrlBool === true) {
	                grid.jqGrid('setCell', rowId, 'isRemoveJissekiCheck', true);
	            }
	        };

	        /// ラインコンボ作成
	        var createLineCombobox = function () {
	            var criteria = $(".search-criteria").toJSON();
	            App.deferred.parallel({
	                line: App.ajax.webget("../Services/FoodProcsService.svc/ma_line?$filter=cd_shokuba eq '" + criteria.shokuba + "' and flg_mishiyo eq 0")
	            }).done(function (result) {
	                line = result.successes.line.d;
	                // 検索用ドロップダウンの設定
	                $("#condition-line > option").remove();
	                App.ui.appendOptions($("#condition-line"), "cd_line", "nm_line", line, true);
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
	        /// <summary>検索前の状態に初期化します。</summary>
	        var clearState = function () {
	            // データクリア
	            grid.clearGridData();
	            lastScrollTop = 0;
	            querySetting.skip = 0;
	            querySetting.count = 0;
	            displayCount();
	            isMishiyo = false;
	            isSearch = false;
	            isCriteriaChange = false;
	            checkButtonStatus = pageLangText.falseFlg.text;

	            // TODO: 画面の仕様に応じて以下のパラメータ設定を変更してください。
	            currentRow = 0;
	            currentCol = firstCol;
	            // 変更セットの作成
	            changeSet = new App.ui.page.changeSet();
	            subGridChangeSet = new App.ui.page.changeSet();
	            // TODO: ここまで

	            // 情報メッセージのクリア
	            App.ui.page.notifyInfo.clear();
	            // エラーメッセージのクリア
	            App.ui.page.notifyAlert.clear();
	        };

	        /// <summary> ラインを取得する </summary>
	        /// <param name="rowid">対象行のID</param>
	        /// <param name="cd_hinmei">製品コード</param>
	        var setLine = function (rowid, cd_hinmei) {
	            // エラーメッセージのクリア
	            App.ui.page.notifyAlert.clear();
	            var codeName,
                    criteria = $(".search-criteria").toJSON();
	            App.deferred.parallel({
	                // ローディング
	                loading: App.ui.loading.show(pageLangText.nowProgressing.text),
	                // 品名を取得
	                codeName: App.ajax.webget("../Services/FoodProcsService.svc/vw_ma_seizo_line_01()?$filter="
                            + "kbn_master eq " + pageLangText.hinmeiMasterSeizoLineMasterKbn.text
                            + "and cd_haigo eq '" + cd_hinmei + "'"
                            + "and cd_shokuba eq '" + criteria.shokuba + "'"
                            + "and seizo_line_mishiyo eq " + pageLangText.falseFlg.text
                            + "&$top=1"
                            + "&$orderby=no_juni_yusen")
	            }).done(function (result) {
	                // フォーカスを隣カラムへ移動させる(※値貼り付け後のバグ対策)
	                $("#" + rowid + " td:eq('" + (grid.getColumnIndexByName("cd_line") + 1) + "')").click();

	                var codeName = result.successes.codeName.d
                        , changeData = setCreatedChangeData(grid.getRowData(rowid))
                        , cd_line = "";
	                if (!App.isUndefOrNull(codeName) && codeName.length > 0) {
	                    cd_line = codeName[0]["cd_line"];
	                    grid.setCell(rowid, "cd_line", cd_line);
	                    grid.setCell(rowid, "nm_line", codeName[0]["nm_line"]);
	                    changeSet.addUpdated(rowid, "cd_line", cd_line, changeData);
	                    validateCell(rowid, "cd_line", cd_line, grid.getColumnIndexByName("cd_line"));
	                    // 製品直下の配合情報を取得する
	                    setHaigoInfo(rowid, cd_hinmei, cd_line);
	                }
	                else {
	                    grid.setCell(rowid, "cd_line", null);
	                    grid.setCell(rowid, "nm_line", null);
	                    grid.setCell(rowid, "ritsu_kihon", null);
	                    grid.setCell(rowid, "check_reflect", "0");
	                    changeSet.addUpdated(rowid, "cd_line", null, changeData);
	                    // ローディングの終了
	                    App.ui.loading.close();
	                    App.ui.page.notifyAlert.message(MS0616).show();
	                }

	                // ラインコードの次の編集可能Cellへ移動
	                var curRow = $("#" + rowid)[0].rowIndex,
                        curCol = grid.getColumnIndexByName("cd_line");
	                grid.moveNextEditable(curRow, curCol, currentRow);
	            }).fail(function (result) {
	                var messages = [], keyName;
	                for (var i = 0; i < result.key.fails.length; i++) {
	                    keyName = result.key.fails[i];
	                    messages.push(keyName + " " + result.fails[keyName].message);
	                }
	                // ローディングの終了
	                App.ui.loading.close();
	                App.ui.page.notifyAlert.message(messages).show();
	            });
	        };

	        /// <summary> 製品直下の配合情報を取得する </summary>
	        /// <param name="rowid">対象行のID</param>
	        /// <param name="cd_hinmei">製品コード</param>
	        /// <param name="cd_line">ラインコード</param>
	        var setHaigoInfo = function (rowid, cd_hinmei, cd_line) {
	            // エラーメッセージのクリア
	            App.ui.page.notifyAlert.clear();
	            var hinmei,
                    //dt_seizo = App.data.getDateTimeStringForQueryNoUtc(new Date(grid.getCell(rowid, "dt_seizo")));
                    dt_seizo = App.data.getDateTimeStringForQueryNoUtc(App.date.localDate(grid.getCell(rowid, "dt_seizo")));
	            App.deferred.parallel({
	                // ローディング
	                loading: App.ui.loading.show(pageLangText.nowProgressing.text),
	                // C/S数反映用の情報を取得
	                hinmei: App.ajax.webget(App.data.toWebAPIFormat(
                                            { url: "../api/YukoHaigoMeiSeizoLine"
                                                , cd_hinmei: cd_hinmei
                                                , dt_seizo: dt_seizo
                                                , flg_mishiyo: pageLangText.falseFlg.text
                                                , cd_line: cd_line
                                                , kbn_master: pageLangText.hinmeiMasterSeizoLineMasterKbn.text
                                            }))
	            }).done(function (result) {
	                // フォーカスを隣カラムへ移動させる(※値貼り付け後のバグ対策)
	                //$("#" + rowid + " td:eq('" + (grid.getColumnIndexByName("cd_line") + 1) + "')").click();
	                var hinmei = result.successes.hinmei.d;

	                if (!App.isUndefOrNull(hinmei) && hinmei.length > 0) {
	                    // 倍率、合計配合重量、入数、個重量、歩留の設定
	                    var res = result.successes.hinmei.d[0];
	                    grid.setCell(rowid, 'ritsu_kihon', res['ritsu_kihon']);
	                    grid.setCell(rowid, 'wt_haigo_gokei', res['wt_haigo_gokei']);
	                    grid.setCell(rowid, 'su_iri', res['su_iri']);
	                    grid.setCell(rowid, 'wt_ko', res['wt_ko']);
	                    grid.setCell(rowid, 'haigo_budomari', res['haigo_budomari']);
	                }
	                else {
	                    // 有効配合が取得できなかった場合、倍率、合計配合重量、入数、個重量、歩留をクリアする
	                    grid.setCell(rowid, 'ritsu_kihon', null);
	                    grid.setCell(rowid, 'wt_haigo_gokei', null);
	                    grid.setCell(rowid, 'su_iri', null);
	                    grid.setCell(rowid, 'wt_ko', null);
	                    grid.setCell(rowid, 'haigo_budomari', null);
	                }
	            }).fail(function (result) {
	                var messages = [], keyName;
	                for (var i = 0; i < result.key.fails.length; i++) {
	                    keyName = result.key.fails[i];
	                    messages.push(keyName + " " + result.fails[keyName].message);
	                }
	                App.ui.page.notifyAlert.message(messages).show();
	            }).always(function () {
	                // ローディングの終了
	                App.ui.loading.close();
	            });
	        };

	        /// <summary> Excel出力前チェック </summary>
	        var checkExcel = function () {
	            var isReturn = false;
	            // 検索条件変更チェック
	            //if (isCriteriaChange) {
	            //    showCriteriaChange("output");
	            //    isReturn = true;
	            //}
	            if (!checkRecordCount()) {
	                isReturn = true;
	            }
	            if (!noChange()) {
	                // 明細が変更されている場合、メッセージを表示しExcelファイル出力処理を中止する
	                App.ui.page.notifyInfo.message(pageLangText.gridChange.text).show();
	                isReturn = true;
	            }
	            if (isReturn) {
	                // ローディングの終了
	                App.ui.loading.close();
	                return;
	            }
	            printExcel(false);
	        };

	        /// <summary> 必須項目チェック(空欄があればfalse) </summary>
	        var checkRequireds = function (rowId) {
	            return !(grid.getCell(rowId, "cd_hinmei") == ""
	                    || grid.getCell(rowId, "cd_line") == ""
	                    || grid.getCell(rowId, "su_seizo_jisseki") == "");
	        };

	        /// <summary> 確定チェックに自動でチェックを付けていいか判断します。(付ける場合はtrue) </summary>
	        var checkKakutei = function (rowId) {
	            // 実績数が変更されているかつ自分で確定チェックを外していない必須項目が入力済みかつ未確定の場合はtrue
	            return grid.getCell(rowId, "isJissekiChange") !== ""
	            //&& grid.getCell(rowId, "dt_update") != ""
                        && grid.getCell(rowId, "isRemoveJissekiCheck") === ""
                        && checkRequireds(rowId)
                        && grid.getCell(rowId, "flg_jisseki") === pageLangText.mikakuteiKakuteiFlg.text
	        };

	        /// <summary> 画面明細とchangeSetに値をセットします。 </summary>
	        var setCellAndChangeSet = function (rowId, cellName, value) {
	            var changeData;
	            grid.setCell(rowId, cellName, value);
	            changeData = setUpdatedChangeData(grid.getRowData(rowId));
	            changeSet.addUpdated(rowId, cellName, changeData[cellName], changeData);
	        };

	        /// <summary> 実績を変更している場合は確定checkboxにチェックをつけます。 </summary>
	        var autoFlagKakutei = function (e) {

	            // 選択した行を取得
	            var newRowId = getSelectedRowId(false);

	            // 選択行が取得できない場合は処理を中止
	            // checkboxは選択行クラスが移動しないので処理を中止
	            if (App.isUndef(newRowId)
                    || (e && $(e.target).attr("type") === "checkbox")) {
	                return;
	            }

	            // 前回選択行がない場合は処理を中止
	            if (App.isUndef(preRowId)) {
	                preRowId = newRowId;
	                return;
	            }

	            // 前回選択行と今回選択行が違う場合に処理を行います。
	            if (preRowId !== newRowId) {

	                // 確定チェックボックスにチェックをつけるか判断
	                if (checkKakutei(preRowId)) {

	                    // 確定フラグにチェックをつけてchangeSetを更新します。
	                    setCellAndChangeSet(preRowId, "flg_jisseki", pageLangText.kakuteiKakuteiFlg.text);

	                    // 編集可能セルを編集不可にします。
	                    setCellEditable(preRowId, pageLangText.kakuteiKakuteiFlg.text);
	                }

	                // 今回選択行を前回選択行として保持します。
	                preRowId = newRowId;
	            }
	        };

	        /// 各種処理の定義 -- End

	        /// ダイアログ処理の定義 ---start

	        /// <summary> 品名マスタセレクタを起動する </summary>
	        var showHinmeiDialog = function (rowid) {
	            //$("#" + rowid + " td:eq('" + (selectCol + 1) + "')").click();
	            // saveEdit()をすることで後からjqGridの保存処理が実行されないようにします。
	            //saveEdit();
	            grid.saveCell(currentRow, currentCol);
	            var option = { id: 'hinmei', param1: hinDialogParam, ismishiyo: pageLangText.falseFlg.text };
	            hinmeiDialog.draggable(true);
	            hinmeiDialog.dlg("open", option);
	        };
	        /// <summary> 製造ラインマスタセレクタを起動する </summary>
	        var showSeizoLineDialog = function (rowid) {
	            if (isLineSelect) {
	                App.ui.page.notifyInfo.message(
                        App.str.format(MS0186, pageLangText.line.text, pageLangText.line.text)
                    ).show();
	                return;
	            }

	            //var hinmeiCode = grid.getCell(getSelectedRowId(false), "cd_hinmei")
	            var hinmeiCode = grid.getCell(rowid, "cd_hinmei")
	            if (App.isUndefOrNull(hinmeiCode) || hinmeiCode === "") {
	                App.ui.page.notifyAlert.clear();
	                //var uniqueKey = rowid + "_" + hinCodeCol;
	                var uniqueKey = rowid + "_" + grid.getColumnIndexByName("cd_hinmei");
	                App.ui.page.notifyAlert.message(
                        App.str.format(MS0042, pageLangText.cd_hinmei.text), uniqueKey
                    ).show();
	                return;
	            }
	            //$("#" + rowid + " td:eq('" + (selectCol + 1) + "')").click();
	            //saveEdit();
	            grid.saveCell(currentRow, currentCol);
	            // 初期検索のために職場コードを渡す
	            var criteria = $(".search-criteria").toJSON();
	            var shokubaCode = criteria.shokuba
                    , option = { id: 'seizoLine', multiselect: false
                                , param1: shokubaCode
                                , param2: hinmeiCode
                                , param3: pageLangText.hinmeiMasterSeizoLineMasterKbn.text
                    };
	            seizoLineDialog.draggable(true);
	            seizoLineDialog.dlg("open", option);
	        };
	        /// <summary> 保存確認ダイアログを開きます。 </summary>
	        var showSaveConfirmDialog = function () {
	            saveConfirmDialogNotifyInfo.clear();
	            saveConfirmDialogNotifyAlert.clear();
	            saveConfirmDialog.draggable(true);
	            saveConfirmDialog.dlg("open");
	        };
	        /// <summary> 検索確認ダイアログを開きます。 </summary>
	        var showFindConfirmDialog = function () {
	            findConfirmDialogNotifyInfo.clear();
	            findConfirmDialogNotifyAlert.clear();
	            findConfirmDialog.draggable(true);
	            findConfirmDialog.dlg("open");
	        };
	        /// <summary>削除確認ダイアログを開きます。</summary>
	        var showDeleteConfirmDialog = function () {
	            deleteConfirmDialogNotifyInfo.clear();
	            deleteConfirmDialogNotifyAlert.clear();
	            deleteConfirmDialog.draggable(true);
	            deleteConfirmDialog.dlg("open");
	        };
	        /// <summary>確認ダイアログを開きます。</summary>
	        var showConfirmDialog = function (msg) {
	            setConfirmDialogMessage(msg);
	            confirmDialog.draggable(true);
	            confirmDialog.dlg("open");
	        };
	        /// <summary> 保存確認ダイアログを閉じます。 </summary>
	        var closeSaveConfirmDialog = function () {
	            saveConfirmDialog.dlg("close");
	        };
	        /// <summary> 検索確認ダイアログを閉じます。 </summary>
	        var closeFindConfirmDialog = function () {
	            findConfirmDialog.dlg("close");
	        };
	        /// <summary> 削除確認ダイアログを閉じます。 </summary>
	        var closeDeleteConfirmDialog = function () {
	            deleteConfirmDialog.dlg("close");
	        };
	        /// <summary> 確認ダイアログを閉じます。 </summary>
	        var closeConfirmDialog = function () {
	            confirmDialog.dlg("close");
	        };
	        // 確認ダイアログのメッセージを設定します。
	        var setConfirmDialogMessage = function (msg) {
	            confirmDialog.find(".dialog-body .part-body span").html(msg);
	        };

	        /// <summary>ダイアログを開きます（原料ロットトレース情報登録チェック）。</summary>
	        // 確認ダイアログ
	        var showDeleteTracingConfirmDialog = function () {
	            var windowHeight = $(window).innerHeight();

	            confirmDeleteTracingDialog.dlg("open");
	            confirmDeleteTracingDialog.css("width", "650");
	            confirmDeleteTracingDialog.closest(".dlg-holder").css("top", windowHeight / 3);
	        }

	        /// <summary>ダイアログを開きます（原料ロットトレース情報登録チェック）。</summary>
	        // 確認ダイアログ
	        var closeDeleteTracingConfirmDialog = function () {
	            confirmDeleteTracingDialog.dlg("close");
	        }

	        /// <summary> ダイアログの起動可否のチェック </summary>
	        var checkShowDialog = function (rowid) {
	            var iCol = grid[0].p.iCol
                    , bool = false;
	            // 各種フラグによるチェック
	            if (grid.getCell(rowid, "editableFlag") == pageLangText.trueFlg.text
                        && grid.getCell(rowid, "flg_mishiyo_hinmei") == pageLangText.falseFlg.text
                        && grid.getCell(rowid, "flg_mishiyo_line") == pageLangText.falseFlg.text
                        && grid.getCell(rowid, "flg_mishiyo_seizo_line") == pageLangText.falseFlg.text
                        && grid.getCell(rowid, "flg_jisseki") == pageLangText.falseFlg.text) {
	                bool = true;
	            }
	            else {
	                // エラーメッセージを表示
	                App.ui.page.notifyAlert.clear();
	                App.ui.page.notifyAlert.message(App.str.format(MS0044, pageLangText.msg_newLine.text)).show();
	            }
	            return bool;
	        };

	        /// ダイアログ処理の定義 -- End

	        //// イベント処理定義 -- Start

	        /// <summary>検索ボタンクリック時のイベント処理を行います。</summary>
	        $(".find-button").on("click", function () {
	            loading(pageLangText.nowProgressing.text, "find-button");
	        });
	        /// <summary>保存ボタンクリック時のイベント処理を行います。</summary>
	        $(".save-button").on("click", function () {
	            // 検索条件変更チェック
	            if (isCriteriaChange) {
	                showCriteriaChange("save");
	                return;
	            }
	            loading(pageLangText.nowProgressing.text, "save-button");
	        });
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
	        /// <summary>削除ボタンクリック時のイベント処理を行います。</summary>
	        $(".delete-button").on("click", function (e) {

	            // 情報メッセージのクリア
	            App.ui.page.notifyInfo.clear();
	            // エラーメッセージのクリア
	            App.ui.page.notifyAlert.clear();

	            var selectedRowId = getSelectedRowId(false);

	            // 検索条件変更チェック
	            if (isCriteriaChange) {
	                showCriteriaChange("lineDel");
	                return;
	            }

	            deleteData();
	        });
	        /// <summary>エラー一覧クリック時のイベント処理を行います。</summary>
	        $(App.ui.page.notifyAlert).on("itemselected", function (e, data) {

	            // subGrid判定
	            var ary = data.unique.split('_'),
                    _subGrid;
	            if (ary.length === 3) {
	                _subGrid = $("#item-grid_" + ary[0]);
	            }

	            // エラー一覧クリック時の処理
	            handleNotifyAlert(data, _subGrid);
	        });
	        /// <summary>全チェック/解除ボタンクリック時のイベント処理を行います。</summary>
	        $(".check-button").on("click", function (e) {
	            // 検索条件変更チェック
	            if (isCriteriaChange) {
	                showCriteriaChange("checkAndReset");
	                return;
	            }
	            if (!checkRecordCount()) {
	                return;
	            }
	            loading(MS0620, "check-button");
	        });
	        /// <summary>チェックボックス操作時のグリッド値更新を行います</summary>
	        $(document).on("click", "#item-grid .jqgrow td :checkbox", function () {

	            // 参考：iRowにて記述する場合
	            var iCol = $(this).parent("td").parent("tr").find("td").index($(this).parent("td")),
                    selectedRowId = $(this).parent("td").parent("tr").attr("id"),
                    cellName = grid.getGridParam("colModel")[iCol].name,
                    value, reflectChkCol;

	            // 反映対象チェックボックスの場合は後続処理を行わない(チェックボックスの値を保存したりはしないので)
	            reflectChkCol = grid.getColumnIndexByName("check_reflect");
	            if (iCol == reflectChkCol) {
	                return;
	            }

	            //$("#" + rowid + " td:eq('" + (selectCol + 1) + "')").click();
	            $("#" + selectedRowId).removeClass("ui-state-highlight").find("td:nth-child(" + (firstCol + 1) + ")").click();    // 行選択

	            // 確定チェックボックスを意図的に変更した場合は按分チェックフラグを真にします。
	            setCellAndChangeSet(selectedRowId, "isCheckAnbun", pageLangText.trueFlg.text);

	            // 更新状態の変更データの設定
	            var changeData = setUpdatedChangeData(grid.getRowData(selectedRowId));

	            // TODO：画面の仕様に応じて以下の定義を変更してください。
	            value = changeData[cellName];
	            // TODO：ここまで

	            // 更新状態の変更セットに変更データを追加
	            changeSet.addUpdated(selectedRowId, cellName, value, changeData);
	            if (cellName === "flg_jisseki") {
	                setCellEditable(selectedRowId, value);
	            }
	        });
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
	            // 結果一覧のパートの高さ - パートのヘッダーの高さ - パート内のボタンのコマンドの高さ - jqGrid のカラムヘッダーの高さ
	            grid.setGridHeight(resultPart[0].clientHeight - resultPartHeader[0].clientHeight - resultPartCommands[0].clientHeight - resultPart.find(".ui-jqgrid-hdiv")[0].clientHeight - 35);
	        };
	        /// <summary>画面リサイズ時のイベント処理を行います。</summary>
	        $(App.ui.page).on("resized", resizeContents);
	        /// <summary>明細のセル移動などでセルを離れた場合に実行されます。</summary>
	        $(document).on("blur", "#item-grid .jqgrow td", function (e) {
	            // 確定checkboxにチェックをつけます。
	            autoFlagKakutei(e);
	        });
	        /// <summary>保存確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
	        $(".save-confirm-dialog .dlg-yes-button").on("click", saveData);
	        /// <summary>保存確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
	        $(".save-confirm-dialog .dlg-no-button").on("click", function () {
	            // ローディングの終了
	            App.ui.loading.close();
	            closeSaveConfirmDialog();
	        });

	        /// <summary>削除確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
	        $(".delete-confirm-dialog .dlg-yes-button").on("click", saveData);
	        /// <summary>削除確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
	        $(".delete-confirm-dialog .dlg-no-button").on("click", closeDeleteConfirmDialog);

	        /// <summary> 確認ダイアログのボタンイベント処理を行います。 </summary>
	        $(".confirm-delete-tracing-dialog .dlg-yes-button").on("click", continueToSave);
	        $(".confirm-delete-tracing-dialog .dlg-no-button").on("click", stopSave);

	        /// <summary>メニューボタンクリック時のイベント処理を行います。</summary>
	        $(".menu-button").on("click", backToMenu);
	        /// <summary>品名検索ボタンクリック時のイベント処理を行います。</summary>
	        $(".hinmei-button").on("click", function (e) {
	            // 検索条件変更チェック
	            if (isCriteriaChange) {
	                //showCriteriaChange("navigate");
	                showCriteriaChange("execute");
	                return;
	            }
	            if (!checkRecordCount()) {
	                return;
	            }
	            var rowid = getSelectedRowId(false);
	            if (checkShowDialog(rowid)) {
	                showHinmeiDialog(rowid);
	            }
	        });
	        /// <summary>ライン検索ボタンクリック時のイベント処理を行います。</summary>
	        $(".line-button").on("click", function (e) {
	            // 検索条件変更チェック
	            if (isCriteriaChange) {
	                //showCriteriaChange("navigate");
	                showCriteriaChange("execute");
	                return;
	            }
	            // 各種チェック
	            //if (!checkRecordCount() || isLineSelect) {
	            if (!checkRecordCount()) {
	                return;
	            }
	            var rowid = getSelectedRowId(false);
	            if (checkShowDialog(rowid)) {
	                showSeizoLineDialog(rowid);
	            }
	        });
	        $("#condition-shokuba").on("change", function () {
	            // ラインコンボ作成
	            createLineCombobox("");
	        });
	        /// <summary> グリッドの列変更ボタンクリック時のイベント処理を行います。 </summary>
	        $(".colchange-button").on("click", function (e) {
	            // 検索条件変更チェック
	            if (isCriteriaChange) {
	                showCriteriaChange("colchange");
	                return;
	            }
	            showColumnSettingDialog(e);
	        });

	        /// <summary> beforeunloadイベントに関数を割り当て </summary>
	        $(window).on('beforeunload', onBeforeUnload);

	        /// <summary> formをsubmit（ログオフ）する場合、beforeunloadイベントを発生させないようにする </summary>
	        $('form').on('submit', function () {
	            $(window).off('beforeunload');
	        });
	        /// <summary> ログインボタンクリック時の記述を削除 </summary>
	        $("#loginButton").attr('onclick', '');
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
	        // 検索条件に変更が発生した場合
	        $(".search-criteria").on("change", function () {
	            // 検索後の状態で検索条件が変更された場合
	            if (isSearch) {
	                isCriteriaChange = true;
	            }
	        });
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
	        /// <summary>エクセルボタンクリック時のイベント処理を行います。</summary>
	        $(".excel-button").on("click", function (e) {
	            loading(pageLangText.nowProgressing.text, "excel-button");
	        });

	        /// <summary>確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
	        $(".confirm-dialog .dlg-yes-button").on("click", function () {
	            closeConfirmDialog();
	            var tmpConfirmId = confirmId;
	            confirmId = "";
	            switch (tmpConfirmId) {
	                case "AnbunUpd": checkSave02(); break;
	                case "AnbunDel": saveData(); break;
	                default: break;
	            }
	        });

	        // <summary>確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
	        $(".confirm-dialog .dlg-no-button").on("click", closeConfirmDialog);

	        // <summary>確認ダイアログの「OK」ボタンクリック時のイベント処理を行います。</summary>
	        $(".confirm-dialog .dlg-ok-button").on("click", closeConfirmDialog);
	        //// イベント処理定義 -- End
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
						<span class="item-label" data-app-text="dt_seizo"></span>
						<input type="text" name="dt_seizo" id="condition-dt_seizo" maxlength="10" />
					</label>
				</li>
				<li>
					<label>
						<span class="item-label" data-app-text="shokuba" data-tooltip-text="shokuba"></span>
						<select name="shokuba" id="condition-shokuba" style="width: 320px;">
						</select>
					</label>
				</li>
				<li>
					<label>
						<span class="item-label" data-app-text="line"></span>
						<select name="line" id="condition-line" style="width: 320px;">
						</select>
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
			<span data-app-text="resultList" style="padding-right: 10px;"></span>
            <span class="list-count" id="list-count"></span>
            <span style="padding-left: 50px;" class="list-loading-message" id="list-loading-message"></span>
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
				<button type="button" class="check-button" name="check-button" data-app-operation="check">
					<span class="icon"></span><span data-app-text="checkAndReset"></span>
				</button>
				<button type="button" class="hinmei-button" name="hinmei-button" data-app-operation="hinmei">
					<span class="icon"></span><span data-app-text="hinmeiIchiran"></span>
				</button>
				<button type="button" class="line-button" name="line-button" data-app-operation="line">
					<span class="icon"></span><span data-app-text="lineIchiran"></span>
				</button>
                <button type="button" class="reflect-button" name="reflect-button" data-app-operation="csReflect">
                    <span class="icon"></span><span data-app-text="csReflect"></span>
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
		<button type="button" class="save-button" name="save-button" data-app-operation="save">
			<span class="icon"></span><span data-app-text="save"></span>
		</button>
		<button type="button" class="excel-button" name="excel-button" data-app-operation="excel">
			<span data-app-text="excel"></span>
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
</asp:Content><asp:Content ID="Content5" ContentPlaceHolderID="DialogsContent" runat="server">
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
    <div class="delete-confirm-dialog" style="display: none;">
        <div class="dialog-header">
            <h4 data-app-text="confirmTitle"></h4>
        </div>
        <div class="dialog-body" style="padding: 10px; width: 100%;">
            <div class="part-body">
                <span data-app-text="deleteConfirm"></span>
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
    <!-- 確認ダイアログ(原料ロットトレース情報登録チェック（削除の場合のみ）) -->
	<div class="confirm-delete-tracing-dialog">	
        <div class="dialog-header">	
            <h4 data-app-text="confirmTitle"></h4>	
        </div>	
        <div class="dialog-body" style="padding: 10px">
            <div class="part-body">	
                 <span class="confirm-delete-tracing-message"></span>
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
    <!-- 確認ダイアログ -->
    <div class="confirm-dialog" style="display: none;">
        <div class="dialog-header">
            <h4 data-app-text="confirmTitle"></h4>
        </div>
        <div class="dialog-body" style="padding: 10px; width: 100%;">
            <div class="part-body">
                <span data-app-text="searchConfirm"></span>
            </div>
        </div>
        <div class="dialog-footer">
            <div class="command" style="position: absolute; left: 10px; top: 5px;">
                <button class="dlg-yes-button" name="dlg-yes-button" data-app-text="yes"></button>
            </div>
            <div class="command" style="position: absolute; right: 5px; top: 5px;">
                <button class="dlg-no-button" name="dlg-no-button" data-app-text="no"></button>
            </div>
            <div class="command" style="position: absolute; right: 5px; top: 5px; display: none;">
                <button class="dlg-ok-button" name="dlg-ok-button" data-app-text="yes"></button>
            </div>
        </div>
    </div>
	<!-- TODO: ここまで  -->
	<!-- TODO: 画面の仕様に応じて以下のダイアログの設定を変更してください。 -->
	<div class="hinmei-dialog">
	</div>
	<div class="seizoLine-dialog">
	</div>
	<!-- TODO: ここまで  -->
	<!-- 画面デザイン -- End -->
</asp:Content>

