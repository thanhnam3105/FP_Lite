<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
	CodeBehind="ShikomiNippo.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.ShikomiNippo" meta:resourcekey="PageResource1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="IncludeContent" runat="server">
	<script src="<%=ResolveUrl("~/Resources/pages/pagedata-shikominippo." + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
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
		
		button.hinmei-button .icon
		{
			background-position: -48px -80px;
		}
		
		button.line-button .icon
		{
			background-position: -48px -80px;
		}

        button.seizoJisseki-button .icon
		{
			background-position: -48px -80px;
		}
		
		button.lotToroku-button .icon
		{
			background-position: -48px -80px;
		}
		
		button.lotTorokuZenbu-button .icon
		{
			background-position: -48px -80px;
		}
        
        .delete-confirm-dialog
        {
            background-color: White;
            width: 350px;
        }
                
        .delete-confirm-dialog .part-body
        {
            width: 95%;
            padding-bottom: 5px;
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

        .search-criteria .item-label {
            width: 13em;
        }
		/* TODO：ここまで */
		
		/* 画面デザイン -- End */
	</style>
	<script type="text/javascript">
    	/**
		* Mathオブジェクトを拡張 
		*/
		var Math = Math || {};


		/**
		* 与えられた値の小数点以下の桁数を返す 
		* multiply, subtractで使用
		* 
		* 例)
		*   10.12  => 2  
		*   99.999 => 3
		*   33.100 => 1
		*/
		Math._getDecimalLength = function (value) {
			var list = (value + '').split('.'), result = 0;
			if (list[1] !== undefined && list[1].length > 0) {
				result = list[1].length;
			}
			return result;
		};


		/**
		* 乗算処理
		*
		* value1, value2から小数点を取り除き、整数値のみで乗算を行う。 
		* その後、小数点の桁数Nの数だけ10^Nで除算する
		*/
		Math.multiply = function (value1, value2, value3) {
			var intValue1 = +(value1 + '').replace('.', ''),
                intValue2 = +(value2 + '').replace('.', ''),
                intValue3 = +(value3 + '').replace('.', ''),
                decimalLength = Math._getDecimalLength(value1) + Math._getDecimalLength(value2) + Math._getDecimalLength(value3),
                result;

			result = (intValue1 * intValue2 * intValue3) / Math.pow(10, decimalLength);

			return result;
		};

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
                isDataLoading = false,
                isSearch = false,   // 検索条件変更フラグ
                isCriteriaChange = false,   // 検索条件変更フラグ
                userRoles = App.ui.page.user.Roles[0];

		    // グリッドコントロール固有の変数宣言
		    var grid = $("#item-grid"),
                //querySetting = { skip: 0, top: pageLangText.topCount.text, count: 0 },
                querySetting = { skip: 0, top: pageLangText.topCount500.text, count: 0 },
                lastScrollTop = 0,
		    // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
                changeSet = new App.ui.page.changeSet(),
                firstCol = 1,
                nmHaigoCol = 3,
                duplicateCol = 999,
                currentRow = 0,
                currentCol = firstCol,
                isMishiyo = false,
                isChecked = pageLangText.falseFlg.text,
                checkButtonStatus = pageLangText.falseFlg.text,
                checkButtonTorokuStatus = pageLangText.falseFlg.text,
                nm_haigoName = "nm_haigo_" + App.ui.page.lang,
                currentHeaderCriteria = {};
		    // TODO: ここまで

		    // TODO: 画面固有の変数宣言
		    var hinDialogParam = pageLangText.shikakariHinKbn.text,
                isLineSelect = false,
                searchCriteriaSet;
		    var preRowId = undefined;
		    // TODO: ここまで

		    // ダイアログ固有の変数宣言
		    var hinmeiDialog = $(".hinmei-dialog"),
                seizoLineDialog = $(".seizoLine-dialog"),
                saveConfirmDialog = $(".save-confirm-dialog"),
                findConfirmDialog = $(".find-confirm-dialog"),
                deleteConfirmDialog = $(".delete-confirm-dialog");

		    // スラッシュなし日付(例：20150625)にスラッシュを付与
		    var attachedDateSlash = function (date) {
		        if (App.ui.page.lang == 'ja' || App.ui.page.lang == 'zh') {
		            var val = date.substr(0, 4) + "/" + date.substr(4, 2) + "/" + date.substr(6, 2);
		            return val;
		        }
		        else {
		            var val = date.substr(0, 2) + "/" + date.substr(2, 2) + "/" + date.substr(4, 4);
		            return val;
		        }
		    };
		    /// <summary>urlよりパラメーターを取得</summary>
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
		    var url_parameters = getParameters();

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
		                var selectedRowId = getSelectedRowId(false),
                            criteria = $(".search-criteria").toJSON();
		                grid.setCell(selectedRowId, "cd_shikakari_hin", data);
		                //						grid.setCell(selectedRowId, nm_haigoName, data2);

		                // 更新状態の変更セットに変更データを追加
		                var changeData = setCreatedChangeData(grid.getRowData(selectedRowId));
		                changeSet.addUpdated(selectedRowId, "cd_shikakari_hin", data, changeData);

		                if (validateCell(selectedRowId, "cd_shikakari_hin", data,
                                grid.getColumnIndexByName("cd_shikakari_hin"))) {
		                    setRelatedValue(selectedRowId, "cd_shikakari_hin", data, null);
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
		                if (validateCell(selectedRowId, "cd_line", data, grid.getColumnIndexByName("cd_line"))) {
		                    setRelatedValue(selectedRowId, "cd_line", data, null);
		                }
		            }
		        }
		    });
		    // コンファームダイアログ定義
		    saveConfirmDialog.dlg();
		    findConfirmDialog.dlg();
		    deleteConfirmDialog.dlg();

		    /// ダイアログ固有のコントロール定義 -- End

		    // 日付の多言語対応
		    var datePickerFormat = pageLangText.dateFormatUS.text,
                newDateFormat = pageLangText.dateNewFormatUS.text;
		    if (App.ui.page.langCountry !== 'en-US') {
		        datePickerFormat = pageLangText.dateFormat.text;
		        newDateFormat = pageLangText.dateNewFormat.text;
		    }
		    // datepicker の設定
		    $("#condition-dt_seizo_from").on("keyup", App.data.addSlashForDateString);
		    $("#condition-dt_seizo_from").detepicker = App.date.startOfDay(new Date());
		    $("#condition-dt_seizo_from").datepicker({
		        dateFormat: datePickerFormat,
		        minDate: new Date(1975, 1 - 1, 1),
		        maxDate: "+1y"
		    });

		    $("#condition-dt_seizo_to").on("keyup", App.data.addSlashForDateString);
		    $("#condition-dt_seizo_to").detepicker = App.date.startOfDay(new Date());
		    $("#condition-dt_seizo_to").datepicker({
		        dateFormat: datePickerFormat,
		        minDate: new Date(1975, 1 - 1, 1),
		        maxDate: "+1y"
		    });

		    // グリッドコントロール固有のコントロール定義
		    var selectCol;
		    grid.jqGrid({
		        colNames: [
                    pageLangText.flg_jisseki.text,
                    pageLangText.dt_seizo.text,
                    pageLangText.cd_shikakari_hin.text + pageLangText.requiredMark.text,
                    pageLangText.nm_haigo.text,
                    pageLangText.cd_line.text + pageLangText.requiredMark.text,
                    pageLangText.nm_line.text,
                    pageLangText.nm_tani.text,
                    pageLangText.ritsu_jisseki.text + pageLangText.requiredMark.text,
                    pageLangText.ritsu_jisseki_hasu.text,
                    pageLangText.su_batch_jisseki.text + pageLangText.requiredMark.text,
                    pageLangText.su_batch_jisseki_hasu.text,
                    pageLangText.wt_zaiko_jisseki.text,
                    pageLangText.wt_shikomi_keikaku.text,
                    pageLangText.wt_shikomi_jisseki.text,
                    pageLangText.wt_haigo_gokei.text,
                    pageLangText.wt_hitsuyo.text,
                    pageLangText.wt_shikomi_zan.text,
                    pageLangText.no_lot_shikakari.text,
                    'flg_haigo_mishiyo',
                    'flg_tani_mishiyo',
                    'flg_line_mishiyo',
                    'flg_seizo_line_mishiyo',
                    'no_han',
                    'isAdded',
                    'editableFlag',
                    'mishiyoFlag',
                    'isJissekiChange',
                    'isRemoveJissekiCheck',
                    pageLangText.densoJotai.text,
                    pageLangText.flg_toroku.text,
                    'kbn_toroku_jotai',
                    pageLangText.kbn_toroku_jotai.text,
                ],
		        colModel: [
                    { name: 'flg_jisseki', width: pageLangText.flg_jisseki_width.number, editable: true, hidden: false, edittype: 'checkbox', sortable: false,
                        align: 'center', editoptions: { value: "1:0" }, formatter: 'checkbox',
                        formatoptions: { disabled: false }, classes: 'not-editable-cell'
                    },
                    { name: 'dt_seizo', width: 0, hidden: true, hidedlg: true,
                        formatter: "date",
                        formatoptions: {
                            srcformat: newDateFormat, newformat: newDateFormat
                        }
                    },
                    { name: 'cd_shikakari_hin', width: 110, editable: true, align: 'left', sorttype: "text" },
                    { name: nm_haigoName, width: 220, editable: false, align: 'left', sorttype: "text" },
                    { name: 'cd_line', width: 110, editable: true, align: 'left', sorttype: "text" },
                    { name: 'nm_line', width: 220, editable: false, align: 'left', sorttype: "text" },
                    { name: 'nm_tani', width: 70, editable: false, align: 'left', sorttype: "text" },
                    { name: 'ritsu_jisseki', width: 115, editable: true, sorttype: "float", align: "right",
                        formatter: 'number',
                        //formatoptions: { thousandsSeparator: ",", decimalPlaces: 6, defaultValue: "" }
                        formatoptions: { thousandsSeparator: ",", decimalPlaces: 2, defaultValue: "0.00" }
                    },
                    { name: 'ritsu_jisseki_hasu', width: 115, editable: true, sorttype: "float",
                        align: "right", formatter: 'number',
                        //formatoptions: { thousandsSeparator: ",", decimalPlaces: 6, defaultValue: "" }
                        formatoptions: { thousandsSeparator: ",", decimalPlaces: 2, defaultValue: "0.00" }
                    },
                    { name: 'su_batch_jisseki', width: 115, editable: true, sorttype: "float",
                        align: "right", formatter: 'number',
                        //formatoptions: { thousandsSeparator: ",", decimalPlaces: 6, defaultValue: "" }
                        formatoptions: { thousandsSeparator: ",", decimalPlaces: 0, defaultValue: "0" }
                    },
                    { name: 'su_batch_jisseki_hasu', width: 115, editable: true, sorttype: "float",
                        align: "right", formatter: 'number',
                        //formatoptions: { thousandsSeparator: ",", decimalPlaces: 6, defaultValue: "" }
                        formatoptions: { thousandsSeparator: ",", decimalPlaces: 0, defaultValue: "0" }
                    },
                    { name: 'wt_zaiko_jisseki', width: 115, editable: true, hidden: true, hidedlg: true,
                        align: "right", formatter: 'number',
                        //formatoptions: { thousandsSeparator: ",", decimalPlaces: 6, defaultValue: "" }
                        formatoptions: { thousandsSeparator: ",", decimalPlaces: 3, defaultValue: "0.000" }
                    },
                    { name: 'wt_shikomi_keikaku', width: pageLangText.wt_shikomi_keikaku_width.number, editable: false, align: 'right',
                        sorttype: "float", formatter: 'number',
                        //formatoptions: { thousandsSeparator: ",", decimalPlaces: 6, defaultValue: "" }
                        formatoptions: { thousandsSeparator: ",", decimalPlaces: 3, defaultValue: "0.000" }
                    },
                    { name: 'wt_shikomi_jisseki', width: 120, editable: false, align: 'right',
                        sorttype: "float", formatter: 'number',
                        //formatoptions: { thousandsSeparator: ",", decimalPlaces: 6, defaultValue: "" }
                        formatoptions: { thousandsSeparator: ",", decimalPlaces: 3, defaultValue: "0.000" }
                    },
                    { name: 'wt_haigo_gokei', width: 0, editable: false, align: 'right', hidden: true, hidedlg: true,
                        sorttype: "int", formatter: 'number',
                        //formatoptions: { thousandsSeparator: ",", decimalPlaces: 0, defaultValue: "" }
                        formatoptions: { thousandsSeparator: ",", decimalPlaces: 6, defaultValue: "" }
                    },
                    { name: 'wt_hitsuyo', width: 120, editable: false, align: 'right',
                        sorttype: "float", formatter: 'number',
                        //formatoptions: { thousandsSeparator: ",", decimalPlaces: 6, defaultValue: "" }
                        formatoptions: { thousandsSeparator: ",", decimalPlaces: 3, defaultValue: "0.000" }
                    },
                    { name: 'wt_shikomi_zan', width: 140, editable: false, align: 'right', hidden: true, hidedlg: true,
                        sorttype: "float", formatter: 'number',
                        //formatoptions: { thousandsSeparator: ",", decimalPlaces: 6, defaultValue: "" }
                        formatoptions: { thousandsSeparator: ",", decimalPlaces: 3, defaultValue: "" }
                    },
                    { name: 'no_lot_shikakari', width: 110, editable: false, sorttype: "text", align: "center" },
                    { name: 'flg_haigo_mishiyo', width: 0, hidden: true, hidedlg: true },
                    { name: 'flg_tani_mishiyo', width: 0, hidden: true, hidedlg: true },
                    { name: 'flg_line_mishiyo', width: 0, hidden: true, hidedlg: true },
                    { name: 'flg_seizo_line_mishiyo', width: 0, hidden: true, hidedlg: true },
                    { name: 'no_han', width: 0, hidden: true, hidedlg: true },
                    { name: 'isAdded', width: 0, hidden: true, hidedlg: true }, 
                    { name: 'editableFlag', width: 0, hidden: true, hidedlg: true },
                    { name: 'mishiyoFlag', width: 0, hidden: true, hidedlg: true },
                    { name: 'isJissekiChange', width: 0, hidden: true, hidedlg: true },
                    { name: 'isRemoveJissekiCheck', width: 0, hidden: true, hidedlg: true },
                    { name: 'kbn_jotai_denso', width: pageLangText.densoJotai_width.number, editable: false,
                        align: 'left', sorttype: "text", formatter: getDensoJotai
                    },
                    { name: 'flg_toroku', width: pageLangText.flg_toroku_width.number, editable: true, edittype: 'checkbox',
                        align: 'center', editoptions: { value: "1:0" }, formatter: 'checkbox',
                        formatoptions: { disabled: true }, classes: 'not-editable-cell'
                    },
                    { name: 'kbn_toroku_jotai', width: 0, hidden: true, hidedlg: true },
                    { name: 'nm_toroku_jotai', width: pageLangText.nm_toroku_jotai.number, editable: false,
                        align: 'left', sorttype: "text", formatter: getTorokuJotai
                    },
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
		            // 検索条件/製造日（開始）～（終了）が1日の場合、非表示とする。
		            var criteria = $(".search-criteria").toJSON(),
                    dateFrom = criteria.con_dt_seizo_from,
                    dateTo = criteria.con_dt_seizo_to,
                    diff = dateTo - dateFrom,
                    diffDay = diff / pageLangText.oneDay.text;

		            if (diffDay == 0) {
		                grid.jqGrid("hideCol", "dt_seizo");
		                grid.setColProp("dt_seizo", { hidedlg: true }).trigger("reloadGrid");
		                $(".add-button").attr("disabled", false);
		            }
		            else {
		                grid.jqGrid("showCol", "dt_seizo").trigger("reloadGrid");
		                grid.setColProp("dt_seizo", { hidedlg: false }).trigger("reloadGrid");
		                $(".add-button").attr("disabled", true);
		            }

		            var ids = grid.jqGrid('getDataIDs');
		            for (var i = 0; i < ids.length; i++) {
		                var id = ids[i],
                            haigoMishiyo = grid.jqGrid('getCell', id, 'flg_haigo_mishiyo'),
                            taniMishiyo = grid.jqGrid('getCell', id, 'flg_tani_mishiyo'),
                            flgJisseki = grid.jqGrid('getCell', id, 'flg_jisseki'),
                            flgToroku = grid.jqGrid('getCell', id, 'flg_toroku'),
                            kbnTorokuJotai = grid.jqGrid('getCell', id, 'kbn_toroku_jotai'),
                            updateDate = grid.jqGrid('getCell', id, 'dt_update');

		                // 既存データのコード項目は常に操作不可とする
		                if (pageLangText.trueFlg.text != grid.jqGrid('getCell', id, 'isAdded')) {
		                    grid.jqGrid('setCell', id, 'cd_shikakari_hin', '', 'not-editable-cell');
		                    grid.jqGrid('setCell', id, 'cd_line', '', 'not-editable-cell');
		                }

		                // 画面の仕様に応じて以下の操作可否の定義を変更してください。
		                grid.jqGrid('setCell', id, 'editableFlag', pageLangText.falseFlg.text);
		                grid.jqGrid('setCell', id, 'mishiyoFlag', pageLangText.falseFlg.text);
		                if (haigoMishiyo === pageLangText.trueFlg.text
                                || taniMishiyo === pageLangText.trueFlg.text
                                || flgJisseki === pageLangText.trueFlg.text) {
		                    grid.jqGrid('setCell', id, 'cd_shikakari_hin', '', 'not-editable-cell');
		                    grid.jqGrid('setCell', id, 'cd_line', '', 'not-editable-cell');
		                    grid.jqGrid('setCell', id, 'ritsu_jisseki', '', 'not-editable-cell');
		                    grid.jqGrid('setCell', id, 'ritsu_jisseki_hasu', '', 'not-editable-cell');
		                    grid.jqGrid('setCell', id, 'su_batch_jisseki', '', 'not-editable-cell');
		                    grid.jqGrid('setCell', id, 'su_batch_jisseki_hasu', '', 'not-editable-cell');
		                    grid.jqGrid('setCell', id, 'wt_zaiko_jisseki', '', 'not-editable-cell');
		                    if (haigoMishiyo === pageLangText.trueFlg.text
                                    || taniMishiyo === pageLangText.trueFlg.text) {
		                        $("#" + (i + 1) + " td:eq(" + grid.getColumnIndexByName("flg_jisseki") + ") input").attr("disabled", true);
		                        grid.jqGrid('setCell', id, 'mishiyoFlag', pageLangText.trueFlg.text);
		                    }
		                }

		                //「確定チェック」がチェックOnで、「登録状況」が未登録の場合は、登録チェックOnに更新		                
		                if (flgJisseki == pageLangText.chk_search_on.text && kbnTorokuJotai == pageLangText.densoJotaiKbnMisakusei.text) {
		                    $("#" + (i + 1) + " td:eq(" + grid.getColumnIndexByName("flg_toroku") + ") input").attr("disabled", false);
		                }
		                else {
		                    $("#" + (i + 1) + " td:eq(" + grid.getColumnIndexByName("flg_toroku") + ") input").attr("disabled", true);
		                }
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
		                if ($.inArray('jqgrow', row.className.split(' ')) > 0) {
		                    // チェックボックスの値を取得
		                    if (grid.getRowData(iRow).flg_haigo_mishiyo === pageLangText.trueFlg.text
                                        || grid.getRowData(iRow).flg_tani_mishiyo === pageLangText.trueFlg.text) {
		                        grid.toggleClassRow(rowid, "attention");
		                        isMishiyo = true;
		                    }
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
		            setRelatedValue(selectedRowId, cellName, value, iCol);
		            // 更新状態の変更データの設定
		            var changeData = setUpdatedChangeData(grid.getRowData(selectedRowId));
		            // 更新状態の変更セットに変更データを追加
		            changeSet.addUpdated(selectedRowId, cellName, value, changeData);

		        },
		        onCellSelect: function (rowid, icol, cellcontent) {
		            selectCol = icol;
		        },
		        ondblClickRow: function (rowid, iRow, iCol) {
		            // 検索条件変更チェック
		            if (isCriteriaChange) {
		                showCriteriaChange("navigate");
		                return;
		            }

		            if (checkShowDialog(rowid)) {
		                // 検索条件変更チェック
		                if (isCriteriaChange) {
		                    showCriteriaChange("navigate");
		                    return;
		                }
		                // 品名セレクタ起動
		                if (selectCol === grid.getColumnIndexByName("cd_shikakari_hin")
                                    || selectCol === grid.getColumnIndexByName(nm_haigoName)) {
		                    showHinmeiDialog(rowid);
		                }
		                // ラインセレクタ起動
		                else if (!isLineSelect && (selectCol === grid.getColumnIndexByName("cd_line")
                                                        || selectCol === grid.getColumnIndexByName("nm_line"))) {
		                    showSeizoLineDialog(rowid);
		                }
		            }
		        }
		    });

		    /// <summary>伝送状態区分による表示名称を取得</summary>
		    /// <param name="cellvalue">ステータス区分</param>
		    /// <param name="options">オプション</param>
		    /// <param name="rowObject">行情報</param>
		    function getDensoJotai(cellvalue, options, rowObject) {
		        var kbn = pageLangText.densoJotaiKbnMisakusei.text; // デフォルト：未作成
		        var ret = "",
                    value = rowObject.kbn_jotai_denso;

		        if (!App.isUndefOrNull(value) && value != "") {
		            kbn = value;
		        }
		        ret = App.str.format(pageLangText.densoJotaiId.data[kbn].name);
		        return ret;
		    }
		    /// <summary>登録状態区分による表示名称を取得</summary>
		    /// <param name="cellvalue">ステータス区分</param>
		    /// <param name="options">オプション</param>
		    /// <param name="rowObject">行情報</param>
		    function getTorokuJotai(cellvalue, options, rowObject) {
		        var kbn = pageLangText.densoJotaiKbnMisakusei.text; // デフォルト：未作成
		        var ret = "",
                    value = rowObject.kbn_toroku_jotai;

		        if (!App.isUndefOrNull(value) && value != "") {
		            kbn = value;
		        }
		        ret = App.str.format(pageLangText.torokuJotaiId.data[kbn].name);
		        return ret;
		    }

		    /// <summary>セルの関連項目を設定します。</summary>
		    /// <param name="selectedRowId">選択行ID</param>
		    /// <param name="cellName">列名</param>
		    /// <param name="value">元となる項目の値</param>
		    /// <param name="iCol">項目の列番号</param>
		    var setRelatedValue = function (selectedRowId, cellName, value, iCol) {
		        // TODO：画面の仕様に応じて以下の関連項目を設定を変更してください。
		        if (cellName === "cd_shikakari_hin" || cellName === "cd_line") {
		            var serviceUrl,
                        elementCode,
                        elementName,
                        codeName,
                        criteria = $(".search-criteria").toJSON();
		            switch (cellName) {
		                case "cd_shikakari_hin":
		                    serviceUrl = "../Services/FoodProcsService.svc/ma_haigo_mei()?"
                                    + "&$orderby=dt_from desc"
                                    + "&$filter=cd_haigo eq '" + value + "'"
                                    + " and flg_mishiyo eq " + pageLangText.falseFlg.text
                                    + " and dt_from le DateTime'" + App.data.getDateTimeStringForQueryNoUtc(criteria.con_dt_seizo_from) + "'",
                                    +"&$top=1";
		                    elementCode = cellName;
		                    elementName = nm_haigoName;
		                    codeName;
		                    break;
		                case "cd_line":
		                    var cd_line = criteria.line
		                    if (App.isUndefOrNull(cd_line) || cd_line === "") {
		                        cd_line = grid.getCell(selectedRowId, cellName);
		                    }
		                    serviceUrl = "../Services/FoodProcsService.svc/vw_ma_seizo_line_01()?"
                                    + "&$orderby=no_juni_yusen"
                                    + "&$filter=cd_line eq '" + value + "'"
                                    + " and kbn_master eq " + pageLangText.haigoMasterSeizoLineMasterKbn.text
                                    + " and cd_haigo eq '" + grid.getCell(selectedRowId, "cd_shikakari_hin") + "'"
                                    + " and cd_shokuba eq '" + criteria.shokuba + "'"
                                    + " and seizo_line_mishiyo eq " + pageLangText.falseFlg.text
                                    + "&$top=1";
		                    elementCode = cellName;
		                    elementName = "nm_line";
		                    codeName;
		                    break;
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
		                    grid.setCell(selectedRowId, elementName, codeName[0][elementName]);
		                    if (cellName === "cd_shikakari_hin") {
		                        // 検索条件ライン未選択時
		                        if (!isLineSelect) {
		                            setLine(selectedRowId, grid.getCell(selectedRowId, cellName));
		                        }
		                        setShiyoTani(selectedRowId, value);
		                        grid.setCell(selectedRowId, "wt_haigo_gokei", codeName[0]["wt_haigo_gokei"]);
		                        // 更新状態の変更セットに変更データを追加
		                        var changeData = setCreatedChangeData(grid.getRowData(selectedRowId));
		                        changeSet.addUpdated(selectedRowId, "wt_haigo_gokei", value, changeData);
		                    }
		                }
		                else {
		                    // 名称クリア
		                    grid.setCell(selectedRowId, elementName, null);
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
		        if (cellName != "cd_line") {
		            // 仕込量算出
		            calcShikomiryo(selectedRowId);
		            // 当日残算出
		            calcTojitsuZan(selectedRowId);
		        }
		        if (cellName == "ritsu_jisseki" || cellName == "ritsu_jisseki_hasu"
                    || cellName == "su_batch_jisseki" || cellName == "su_batch_jisseki_hasu") {
		            // 仕込量が修正された場合は、保存時に確定チェックをつける為、修正フラグをONにする
		            grid.jqGrid('setCell', selectedRowId, 'isJissekiChange', pageLangText.trueFlg.text);
		            grid.jqGrid('setCell', selectedRowId, 'isRemoveJissekiCheck', null);
		        }
		    };

		    // 製造実績選択画面に遷移する
		    var openSeizoJissekiSentaku = function (rowId) {
		        var rowData = grid.getRowData(rowId),
                    criteria = $(".search-criteria").toJSON(),
                    // 伝送状況チェックボックス
                    chk_mi_sakusei = pageLangText.chk_search_non.text,
		            chk_mi_denso = pageLangText.chk_search_non.text,
		            chk_denso_machi = pageLangText.chk_search_non.text,
		            chk_denso_zumi = pageLangText.chk_search_non.text,
                    // 登録状況チェックボックス
                    chk_mi_toroku = pageLangText.chk_search_non.text,
		            chk_ichibu_mi_toroku = pageLangText.chk_search_non.text,
		            chk_toroku_sumi = pageLangText.chk_search_non.text;


		        // 伝送状況チェックボックス
		        if (!App.isUndefOrNull(criteria.chk_mi_sakusei)) {
		            chk_mi_sakusei = pageLangText.chk_search_on.text;
		        }
		        if (!App.isUndefOrNull(criteria.chk_mi_denso)) {
		            chk_mi_denso = pageLangText.chk_search_on.text;
		        }
		        if (!App.isUndefOrNull(criteria.chk_denso_machi)) {
		            chk_denso_machi = pageLangText.chk_search_on.text;
		        }
		        if (!App.isUndefOrNull(criteria.chk_denso_zumi)) {
		            chk_denso_zumi = pageLangText.chk_search_on.text;
		        }

                // 登録状況チェックボックス
		        if (!App.isUndefOrNull(criteria.chk_mi_toroku)) {
		            chk_mi_toroku = pageLangText.chk_search_on.text;
		        }
		        if (!App.isUndefOrNull(criteria.chk_ichibu_mi_toroku)) {
		            chk_ichibu_mi_toroku = pageLangText.chk_search_on.text;
		        }
		        if (!App.isUndefOrNull(criteria.chk_toroku_sumi)) {
		            chk_toroku_sumi = pageLangText.chk_search_on.text;
		        }

		        // 選択行が確定されていない場合は処理中止
		        if (pageLangText.trueFlg.text != rowData.flg_jisseki) {
		            App.ui.page.notifyAlert.message(
                        App.str.format(MS0044, pageLangText.msg_kakuteiData.text)
                    ).show();
		            return;
		        }

		        var url = "./SeizoJissekiSentaku.aspx";
		        url += "?no_lot_shikakari=" + encodeURIComponent(rowData.no_lot_shikakari);
		        url += "&cd_hinmei=" + encodeURIComponent(rowData.cd_shikakari_hin);
		        url += "&nm_hinmei=" + encodeURIComponent(rowData[nm_haigoName]);
		        url += "&dt_shikomi=" + rowData.dt_seizo.replace(/[\/]/g, "");
		        url += "&dt_shikomi_st=" + App.data.getDateString(criteria.con_dt_seizo_from, true).replace(/[\/]/g, "");
		        url += "&dt_shikomi_en=" + App.data.getDateString(criteria.con_dt_seizo_to, true).replace(/[\/]/g, "");
		        url += "&cd_shokuba=" + criteria.shokuba;
		        url += "&cd_line=" + criteria.line;
                // 伝送状況チェックボックス
		        url += "&chk_mi_sakusei=" + chk_mi_sakusei;
		        url += "&chk_mi_denso=" + chk_mi_denso;
		        url += "&chk_denso_machi=" + chk_denso_machi;
		        url += "&chk_denso_zumi=" + chk_denso_zumi;
		        // 登録状況チェックボックス
		        url += "&chk_mi_toroku=" + chk_mi_toroku;
		        url += "&chk_ichibu_mi_toroku=" + chk_ichibu_mi_toroku;
		        url += "&chk_toroku_sumi=" + chk_toroku_sumi;
		        url += "&batch=" + rowData.su_batch_jisseki;
		        url += "&batchHasu=" + rowData.su_batch_jisseki_hasu;
		        url += "&suShikomi=" + rowData.wt_shikomi_jisseki;
		        url += "&bairitsu=" + rowData.ritsu_jisseki;
		        url += "&bairitsuHasu=" + rowData.ritsu_jisseki_hasu;

		        window.location = url;
		    };

		    // 検索後の条件を取ります。
		    var getCurrentHeaderCriteria = function () {
		        var criteria = $(".search-criteria").toJSON(),
                    // 伝送状況チェックボックス
                    chk_mi_sakusei = pageLangText.chk_search_non.text,
		            chk_mi_denso = pageLangText.chk_search_non.text,
		            chk_denso_machi = pageLangText.chk_search_non.text,
		            chk_denso_zumi = pageLangText.chk_search_non.text,
                    // 登録状況チェックボックス
                    chk_mi_toroku = pageLangText.chk_search_non.text,
		            chk_ichibu_mi_toroku = pageLangText.chk_search_non.text,
		            chk_toroku_sumi = pageLangText.chk_search_non.text,
                    currentHeaderCriteria = {};

                // 伝送状況チェックボックス
		        if (!App.isUndefOrNull(criteria.chk_mi_sakusei)) {
		            chk_mi_sakusei = pageLangText.chk_search_on.text;
		        }
		        if (!App.isUndefOrNull(criteria.chk_mi_denso)) {
		            chk_mi_denso = pageLangText.chk_search_on.text;
		        }
		        if (!App.isUndefOrNull(criteria.chk_denso_machi)) {
		            chk_denso_machi = pageLangText.chk_search_on.text;
		        }
		        if (!App.isUndefOrNull(criteria.chk_denso_zumi)) {
		            chk_denso_zumi = pageLangText.chk_search_on.text;
		        }

                // 登録状況チェックボックス
		        if (!App.isUndefOrNull(criteria.chk_mi_toroku)) {
		            chk_mi_toroku = pageLangText.chk_search_on.text;
		        }
		        if (!App.isUndefOrNull(criteria.chk_ichibu_mi_toroku)) {
		            chk_ichibu_mi_toroku = pageLangText.chk_search_on.text;
		        }
		        if (!App.isUndefOrNull(criteria.chk_toroku_sumi)) {
		            chk_toroku_sumi = pageLangText.chk_search_on.text;
		        }

		        currentHeaderCriteria.dt_seizo_st = App.data.getDateString(criteria.con_dt_seizo_from, true).replace(/[\/]/g, "");
		        currentHeaderCriteria.dt_seizo_en = App.data.getDateString(criteria.con_dt_seizo_to, true).replace(/[\/]/g, "");
		        currentHeaderCriteria.cd_shokuba = criteria.shokuba;
		        currentHeaderCriteria.cd_line = criteria.line;
                // 伝送状況チェックボックス
		        currentHeaderCriteria.chk_mi_sakusei = chk_mi_sakusei;
		        currentHeaderCriteria.chk_mi_denso = chk_mi_denso;
		        currentHeaderCriteria.chk_denso_machi = chk_denso_machi;
		        currentHeaderCriteria.chk_denso_zumi = chk_denso_zumi;
                // 登録状況チェックボックス
		        currentHeaderCriteria.chk_mi_toroku = chk_mi_toroku;
		        currentHeaderCriteria.chk_ichibu_mi_toroku = chk_ichibu_mi_toroku;
		        currentHeaderCriteria.chk_toroku_sumi = chk_toroku_sumi;

		        return currentHeaderCriteria;
		    }

		    // 原料ロット番号画面に遷移する
		    var openGenryoLotToroku = function (rowId) {
		        var rowData = grid.getRowData(rowId);

		        // 選択行が確定されていない場合は処理中止
		        if (pageLangText.trueFlg.text != rowData.flg_jisseki) {
		            App.ui.page.notifyAlert.message(
                        App.str.format(MS0044, pageLangText.msg_kakuteiData.text)
                    ).show();
		            return;
		        }

		        var url = "./GenryoLotToroku.aspx";
		        // 遷移時に渡すパラメータを設定
		        url += "?no_lot_shikakari=" + encodeURIComponent(rowData.no_lot_shikakari);
		        url += "&cd_hinmei=" + encodeURIComponent(rowData.cd_shikakari_hin);
		        url += "&dt_seizo=" + rowData.dt_seizo.replace(/[\/]/g, "");
		        url += "&dt_seizo_st=" + currentHeaderCriteria.dt_seizo_st;
		        url += "&dt_seizo_en=" + currentHeaderCriteria.dt_seizo_en;
		        url += "&cd_shokuba=" + currentHeaderCriteria.cd_shokuba;
		        url += "&cd_line=" + currentHeaderCriteria.cd_line;
                // 伝送状況チェックボックス
		        url += "&chk_mi_sakusei=" + currentHeaderCriteria.chk_mi_sakusei;
		        url += "&chk_mi_denso=" + currentHeaderCriteria.chk_mi_denso;
		        url += "&chk_denso_machi=" + currentHeaderCriteria.chk_denso_machi;
		        url += "&chk_denso_zumi=" + currentHeaderCriteria.chk_denso_zumi;
                // 登録状況チェックボックス
		        url += "&chk_mi_toroku=" + currentHeaderCriteria.chk_mi_toroku;
		        url += "&chk_ichibu_mi_toroku=" + currentHeaderCriteria.chk_ichibu_mi_toroku;
		        url += "&chk_toroku_sumi=" + currentHeaderCriteria.chk_toroku_sumi;

		        window.location = url;
		    };

		    //// コントロール定義 -- End

		    //// 操作制御定義 -- Start

		    // 操作制御定義を定義します。
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
		            $(".lotTorokuZenbu-button").css("display", "none");
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
                                + "$filter=flg_mishiyo eq " + pageLangText.falseFlg.text + "&$select=cd_shokuba,nm_shokuba")
		        // TODO: ここまで
		    }).done(function (result) {
		        shokuba = result.successes.shokuba.d;
		        // 検索用ドロップダウンの設定
		        App.ui.appendOptions($("#condition-shokuba"), "cd_shokuba", "nm_shokuba", shokuba, false);

		        // パラメーターが存在すれば、再検索を行う
		        var param_line = "";
		        var dtSeizoFrom = url_parameters["dt_seizo_st"];
		        var dtSeizoTo = url_parameters["dt_seizo_en"];
		        if (!App.isUndefOrNull(dtSeizoFrom) && dtSeizoFrom != "" && !App.isUndefOrNull(dtSeizoTo) && dtSeizoTo != "") {
		            $("#condition-dt_seizo_from").datepicker("setDate", App.date.localDate(attachedDateSlash(dtSeizoFrom)));
		            $("#condition-dt_seizo_to").datepicker("setDate", App.date.localDate(attachedDateSlash(dtSeizoTo)));
		            $("#condition-shokuba").val(url_parameters["cd_shokuba"]);
		            param_line = url_parameters["cd_line"];
		        }
		        else {
		            // 当日日付を挿入
		            $("#condition-dt_seizo_from").datepicker("setDate", new Date());
		            $("#condition-dt_seizo_to").datepicker("setDate", new Date());
		        }

                // 伝送状況チェックボックスを設定
		        if (!App.isUndefOrNull(url_parameters["chk_mi_sakusei"]) && url_parameters["chk_mi_sakusei"]) {
		            if (url_parameters["chk_mi_sakusei"] == pageLangText.chk_search_on.text)
		                $("#chk_mi_sakusei").attr('checked', true);
		            else
		                $("#chk_mi_sakusei").attr('checked', false);
		        }

		        if (!App.isUndefOrNull(url_parameters["chk_mi_denso"]) && url_parameters["chk_mi_denso"]) {
		            if (url_parameters["chk_mi_denso"] == pageLangText.chk_search_on.text)
		                $("#chk_mi_denso").attr('checked', true);
		            else
		                $("#chk_mi_denso").attr('checked', false);
		        }

		        if (!App.isUndefOrNull(url_parameters["chk_denso_machi"]) && url_parameters["chk_denso_machi"]) {
		            if (url_parameters["chk_denso_machi"] == pageLangText.chk_search_on.text)
		                $("#chk_denso_machi").attr('checked', true);
		            else
		                $("#chk_denso_machi").attr('checked', false);
		        }

		        if (!App.isUndefOrNull(url_parameters["chk_denso_zumi"]) && url_parameters["chk_denso_zumi"]) {
		            if (url_parameters["chk_denso_zumi"] == pageLangText.chk_search_on.text)
		                $("#chk_denso_zumi").attr('checked', true);
		            else
		                $("#chk_denso_zumi").attr('checked', false);
		        }

                // 登録状況チェックボックスを設定
		        if (!App.isUndefOrNull(url_parameters["chk_mi_toroku"]) && url_parameters["chk_mi_toroku"]) {
		            if (url_parameters["chk_mi_toroku"] == pageLangText.chk_search_on.text)
		                $("#chk_mi_toroku").attr('checked', true);
		            else
		                $("#chk_mi_toroku").attr('checked', false);
		        }

		        if (!App.isUndefOrNull(url_parameters["chk_ichibu_mi_toroku"]) && url_parameters["chk_ichibu_mi_toroku"]) {
		            if (url_parameters["chk_ichibu_mi_toroku"] == pageLangText.chk_search_on.text)
		                $("#chk_ichibu_mi_toroku").attr('checked', true);
		            else
		                $("#chk_ichibu_mi_toroku").attr('checked', false);
		        }

		        if (!App.isUndefOrNull(url_parameters["chk_toroku_sumi"]) && url_parameters["chk_toroku_sumi"]) {
		            if (url_parameters["chk_toroku_sumi"] == pageLangText.chk_search_on.text)
		                $("#chk_toroku_sumi").attr('checked', true);
		            else
		                $("#chk_toroku_sumi").attr('checked', false);
		        }

		        createLineCombobox(url_parameters);

		    }).fail(function (result) {
		        App.ui.loading.close();
		        var keyName, messages = [];
		        for (var i = 0; i < result.key.fails.length; i++) {
		            keyName = result.key.fails[i];
		            messages.push(keyName + " " + result.fails[keyName].message);
		        }
		        App.ui.page.notifyAlert.message(messages).show();
		    }).always(function () {
		        //App.ui.loading.close();
		    });

		    //// 事前データロード -- End

		    //// 検索処理 -- Start

		    // 画面アーキテクチャ共通の検索処理

		    /// <summary>クエリオブジェクトの設定</summary>
		    var query = function () {
		        var criteria = $(".search-criteria").toJSON(),
		            // 伝送状況チェックボックス
                    chk_mi_sakusei = pageLangText.chk_search_non.text,
		            chk_mi_denso = pageLangText.chk_search_non.text,
		            chk_denso_machi = pageLangText.chk_search_non.text,
		            chk_denso_zumi = pageLangText.chk_search_non.text,
                    // 登録状況チェックボックス
                    chk_mi_toroku = pageLangText.chk_search_non.text,
		            chk_ichibu_mi_toroku = pageLangText.chk_search_non.text,
		            chk_toroku_sumi = pageLangText.chk_search_non.text;

		        // 伝送状況チェックボックス
		        if (!App.isUndefOrNull(criteria.chk_mi_sakusei)) {
		            chk_mi_sakusei = pageLangText.chk_search_on.text;
		        }
		        if (!App.isUndefOrNull(criteria.chk_mi_denso)) {
		            chk_mi_denso = pageLangText.chk_search_on.text;
		        }
		        if (!App.isUndefOrNull(criteria.chk_denso_machi)) {
		            chk_denso_machi = pageLangText.chk_search_on.text;
		        }
		        if (!App.isUndefOrNull(criteria.chk_denso_zumi)) {
		            chk_denso_zumi = pageLangText.chk_search_on.text;
		        }

                // 登録状況チェックボックス
		        if (!App.isUndefOrNull(criteria.chk_mi_toroku)) {
		            chk_mi_toroku = pageLangText.chk_search_on.text;
		        }
		        if (!App.isUndefOrNull(criteria.chk_ichibu_mi_toroku)) {
		            chk_ichibu_mi_toroku = pageLangText.chk_search_on.text;
		        }
		        if (!App.isUndefOrNull(criteria.chk_toroku_sumi)) {
		            chk_toroku_sumi = pageLangText.chk_search_on.text;
		        }

		        var query = {
		            url: "../api/ShikomiNippo"
                    , dt_seizo_st: App.data.getDateTimeStringForQueryNoUtc(criteria.con_dt_seizo_from)
                    , dt_seizo_en: App.data.getDateTimeStringForQueryNoUtc(criteria.con_dt_seizo_to)
                    , cd_shokuba: criteria.shokuba
                    , cd_line: criteria.line
                    // 伝送状況チェックボックス
                    , chk_mi_sakusei: chk_mi_sakusei
                    , chk_mi_denso: chk_mi_denso
                    , chk_denso_machi: chk_denso_machi
                    , chk_denso_zumi: chk_denso_zumi
                    // 登録状況チェックボックス
                    , chk_mi_toroku: chk_mi_toroku
                    , chk_ichibu_mi_toroku: chk_ichibu_mi_toroku
                    , chk_toroku_sumi: chk_toroku_sumi
                    , skip: querySetting.skip
                    , top: querySetting.top
		        }
		        return query;
		    };
		    /// <summary>検索条件を検索時の状態に戻す</summary>
		    var returnCriteria = function () {
		        var criteria = $(".search-criteria").toJSON();
		        $("#condition-dt_seizo_from").val(App.data.getDateString(searchCriteriaSet.dt_seizo, true));
		        $("#condition-dt_seizo_to").val(App.data.getDateString(searchCriteriaSet.dt_seizo, true));
		        $("#condition-shokuba").val(searchCriteriaSet.shokuba);
		        $("#condition-line").text(searchCriteriaSet.line);
		    };
		    // <summary>検索前処理</summary>
		    var checkSearch = function () {
		        // 検索前バリデーション
		        var result = $(".part-body .item-list").validation().validate();
		        if (result.errors.length > 0) {
		            // ローディングの終了
		            App.ui.loading.close();
		            return;
		        }

		        //日付内容チェックを行います
		        if (checkDateSearch() == false) {
		            App.ui.loading.close();
		            return;
		        }

		        if (/*!isCriteriaChange && */!noChange()) {
		            showFindConfirmDialog();
		        }
		        else {
		            clearState();
		            searchItems(new query());
		        }
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
                    App.data.toWebAPIFormat(query)
                ).done(function (result) {
                    // 検索フラグを立てる
                    isSearch = true;
                    if (result.__count === 0) {
                        App.ui.page.notifyAlert.message(MS0037).show();
                    }
                    else {
                        // データバインド
                        bindData(result);
                        // 検索条件を閉じる
                        closeCriteria();
                        $(".ui-jqgrid-hdiv").scrollLeft(0); // 明細のスクロール位置をリセット
                    }

                    isCriteriaChange = false;
                    currentHeaderCriteria = getCurrentHeaderCriteria();
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                }).always(function () {
                    setTimeout(function () {
                        // ローディングの終了
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
		        checkButtonTorokuStatus = pageLangText.falseFlg.text;

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
		        if (App.isUndefOrNull(resultCount) || resultCount === "") {
		            resultCount = 0;
		        }
		        $("#list-count").text(
                     App.str.format("{0}/{1} " + pageLangText.itemCount.text, querySetting.count, resultCount)
                );
		    };
		    /// <summary>データをバインドします。</summary>
		    /// <param name="result">検索結果</param>
		    var bindData = function (result) {
		        grid.setGridParam({ rowNum: querySetting.top });
		        var resultCount = parseInt(result.__count);
		        if (resultCount > querySetting.top) {
		            App.ui.page.notifyInfo.message(
                        App.str.format(MS0568, resultCount, querySetting.top)).show();
		            querySetting.count = querySetting.top;
		        }
		        else {
		            querySetting.count = resultCount;
		        }
		        displayCount(resultCount);

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
		        // 選択行なしの場合の行選択
		        if (App.isUnusable(selectedRowId)) {
		            // selectedRowId = ids[recordCount - 1]; // 最終行
		            selectedRowId = ids[0]; // 先頭行
		        }
		        currentRow = $('#' + selectedRowId)[0].rowIndex;

		        return selectedRowId;
		    };
		    /// <summary>新規行データの設定を行います。</summary>
		    var setAddData = function () {
		        // TODO: 画面の仕様に応じて以下の項目を変更してください。
		        var criteria = $(".search-criteria").toJSON();
		        var addData = {
		            "dt_seizo": criteria.con_dt_seizo_from
                    , "cd_shokuba": criteria.shokuba
                    , "cd_line": criteria.line
                    , "nm_line": $("#condition-line option:selected").text()
                    , "flg_jisseki": pageLangText.falseFlg.text
                    , "cd_shikakari_hin": ""
                    , "ritsu_jisseki": null
                    , "ritsu_jisseki_hasu": null
                    , "su_batch_jisseki": null
                    , "su_batch_jisseki_hasu": null
                    , "wt_zaiko_jisseki": null
                    , "wt_shikomi_jisseki": 0
                    , "wt_shikomi_zan": 0
                    , "wt_haigo_gokei": 0
                    , "no_lot_shikakari": ""
                    , "flg_haigo_mishiyo": pageLangText.falseFlg.text
                    , "flg_tani_mishiyo": pageLangText.falseFlg.text
                    , "flg_line_mishiyo": pageLangText.falseFlg.text
                    , "flg_seizo_line_mishiyo": pageLangText.falseFlg.text
                    , "isAdded": pageLangText.trueFlg.text
                    , "editableFlag": pageLangText.trueFlg.text
                    , "mishiyoFlag": pageLangText.falseFlg.text
                    , "flg_toroku": pageLangText.falseFlg.text
                    , "kbn_jotai_denso": pageLangText.densoJotaiKbnMisakusei.text
                    , "kbn_toroku_jotai": pageLangText.torokuJotaiKbnMitoroku.text
                    , "nm_toroku_jotai": pageLangText.torokuJotaiId.data[0].name
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
		            "dt_seizo": App.data.getDateTimeStringForQueryNoUtc(App.date.localDate(newRow.dt_seizo))
                    , "cd_shokuba": criteria.shokuba
                    , "cd_line": newRow.cd_line
                    , "flg_jisseki": newRow.flg_jisseki
                    , "cd_shikakari_hin": newRow.cd_shikakari_hin
                    , "ritsu_jisseki": newRow.ritsu_jisseki
                    , "ritsu_jisseki_hasu": newRow.ritsu_jisseki_hasu
                    , "su_batch_jisseki": newRow.su_batch_jisseki
                    , "su_batch_jisseki_hasu": newRow.su_batch_jisseki_hasu
                    , "wt_zaiko_jisseki": newRow.wt_zaiko_jisseki
                    , "wt_shikomi_jisseki": newRow.wt_shikomi_jisseki
                    , "wt_shikomi_zan": newRow.wt_shikomi_zan
                    , "no_lot_shikakari": newRow.no_lot_shikakari
                    , "flg_toroku": newRow.flg_toroku
                    , "kbn_jotai_denso": newRow.kbn_jotai_denso
                    , "kbn_toroku_jotai": newRow.kbn_toroku_jotai
                    , "nm_toroku_jotai": newRow.nm_toroku_jotai
		        };
		        // TODO: ここまで
		        return changeData;
		    };
		    /// <summary>更新状態の変更セットに追加する変更データの設定を行います。</summary>
		    /// <param name="row">選択行</param>
		    var setUpdatedChangeData = function (row) {
		        // TODO: 画面の仕様に応じて以下の項目を変更してください。
		        var criteria = $(".search-criteria").toJSON();
		        var changeData = {
		            //"dt_seizo": criteria.con_dt_seizo_from
		            "dt_seizo": App.data.getDateTimeStringForQueryNoUtc(App.date.localDate(row.dt_seizo))
					, "flg_jisseki": row.flg_jisseki
                    , "cd_shikakari_hin": row.cd_shikakari_hin
                    , "cd_line,": row.cd_line
                    , "ritsu_jisseki": row.ritsu_jisseki
                    , "ritsu_jisseki_hasu": row.ritsu_jisseki_hasu
                    , "su_batch_jisseki": row.su_batch_jisseki
                    , "su_batch_jisseki_hasu": row.su_batch_jisseki_hasu
                    , "wt_zaiko_jisseki": row.wt_zaiko_jisseki
                    , "wt_shikomi_jisseki": row.wt_shikomi_jisseki
                    , "wt_shikomi_zan": row.wt_shikomi_zan
                    , "no_lot_shikakari": row.no_lot_shikakari
                    , "flg_toroku": row.flg_toroku
                    , "kbn_jotai_denso": row.kbn_jotai_denso
                    , "kbn_toroku_jotai": row.kbn_toroku_jotai
                    , "nm_toroku_jotai": row.nm_toroku_jotai
		        };
		        // TODO: ここまで
		        return changeData;
		    };
		    /// <summary>削除状態の変更セットに追加する変更データの設定を行います。</summary>
		    /// <param name="row">選択行</param>
		    var setDeletedChangeData = function (row) {
		        // TODO: 画面の仕様に応じて以下の項目を変更してください。
		        var criteria = $(".search-criteria").toJSON();
		        var changeData = {
		            "cd_shikakari_hin": row.cd_shikakari_hin,
		            "cd_line": row.cd_line,
		            "no_lot_shikakari": row.no_lot_shikakari,
		            "dt_seizo": App.data.getDateTimeStringForQueryNoUtc(App.date.localDate(row.dt_seizo))
		        };
		        // TODO: ここまで
		        return changeData;
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

		        // 確定checkboxにチェックをつけます。
		        autoFlagKakutei();
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
		        if (pageLangText.kakuteiKakuteiFlg.text === grid.getCell(selectedRowId, "flg_jisseki")) {
		            App.ui.page.notifyAlert.message(App.str.format(MS0168, pageLangText.del.text)).show();
		            return;
		        }
		        if (!App.isUndefOrNull(grid.getCell(selectedRowId, "wt_shikomi_keikaku"))
                        && grid.getCell(selectedRowId, "wt_shikomi_keikaku") != ""
		        //        && grid.getCell(selectedRowId, "wt_shikomi_keikaku") != "0") {
                        && parseFloat(grid.getCell(selectedRowId, "wt_shikomi_keikaku")) != parseFloat("0")) {
		            App.ui.page.notifyAlert.message(App.str.format(MS0452, pageLangText.shikomi.text)).show();
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

		            // 前回選択行を選択した行に変更します。
		            autoFlagKakutei();
		        }
		        else {
		            preRowId = undefined;
		        }
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
                    checkCol_a = 3,
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
		                    retValue_b = ret[i].Data.no_yusen;
		                    // TODO: ここまで
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
		        App.ui.page.notifyInfo.clear();
		        App.ui.page.notifyAlert.clear();
		        // ローディングの表示
		        App.ui.loading.show(pageLangText.nowSaving.text);

		        // 仕込量が修正されていた場合は確定にチェックする
		        checkJissekiFlag();

		        // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
		        var saveUrl = "../api/ShikomiNippo";
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
		        // エラーメッセージのクリア
		        App.ui.page.notifyInfo.clear();
		        App.ui.page.notifyAlert.clear();
		        // 編集内容の保存
		        saveEdit();

		        // 変更がない場合は処理を抜ける
		        if (noChange()) {
		            App.ui.loading.close();
		            App.ui.page.notifyInfo.message(pageLangText.noChange.text).show();
		            return;
		        }
		        // 変更セット内にバリデーションエラーがある場合は処理を抜ける
		        if (!validateChangeSet()) {
		            App.ui.loading.close();
		            return;
		        }

		        /// 伝送状態チェック
		        // 伝送中の場合は処理中止
		        if (!getDensochu()) {
		            App.ui.loading.close();
		            App.ui.page.notifyAlert.message(MS0749).show();
		            return;
		        }

                // 仕込量（予定）・仕込量の0チェックする
                if (!suryoZeroCheck()) {
                    // チェックNGの場合は処理中止
                    App.ui.loading.close();
                    return;
                }

                var rowid = 0
		        //整合性チェック
                if (!checkSeigo(rowid)) {
                    //チェックNGの場合は処理中止
                    App.ui.loading.close();
                    App.ui.page.notifyAlert.message(App.str.format(MS0131, pageLangText.save.text), rowid).show();
                    return;
                }

                App.ui.loading.close();
		        if (checkDensojotai()) {
		            // 削除対象の按分データに伝送済のものがある場合は確認ダイアログを表示する
		            showDeleteConfirmDialog();
		        }
		        else {
		            //showSaveConfirmDialog();
		            saveData();
		        }
		    };
		    /// <summary>保存時の確定チェック処理</summary>
		    var checkJissekiFlag = function () {
		        var ids = grid.jqGrid('getDataIDs'),
                    id,
                    cellName = "flg_jisseki",
                    cellNameFlgToroku = "flg_toroku";

		        for (var i = 0; i < ids.length; i++) {
		            id = ids[i];

		            var isJisseki = grid.jqGrid('getCell', id, 'isJissekiChange');
		            var isRemoved = grid.jqGrid('getCell', id, 'isRemoveJissekiCheck');
		            if (isJisseki == pageLangText.trueFlg.text && isRemoved == "") {
		                // 仕込量の修正フラグがONの場合、確定にチェックする
		                // 但し意図的にフラグをoffにした場合はこの処理を行わない
		                var changeData = setUpdatedChangeData(grid.getRowData(id));
		                changeSet.addUpdated(id, cellName, pageLangText.trueFlg.text, changeData);
		                changeSet.addUpdated(id, cellNameFlgToroku, pageLangText.trueFlg.text, changeData);
		            }
		        }
		    }

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

            /// <summary>行追加：変更セット毎に仕込量0チェックを実施</summary>
            /// <summary>更新：変更セット毎に仕込量（予定）/仕込量0チェック　および　更新データの存在チェックを実施</summary>
            /// <summary>＜返却値＞成功：True,失敗：False</summary>
            var suryoZeroCheck = function () {
                var suJitsu = 0;
                var noLotShikakarihin = '';
                var msId = '';
                // 行追加データをチェック
                for (p in changeSet.changeSet.created) {
                    if (!changeSet.changeSet.created.hasOwnProperty(p)) {
                        continue;
                    }
                    // 仕込量
                    suJitsu = grid.jqGrid('getCell', p, 'wt_shikomi_jisseki');
                    if (suJitsu == 0) {
                        // セルを選択して入力モードを解除する
                        grid.editCell(p, grid.getColumnIndexByName('wt_shikomi_jisseki'), false);
                        // エラー背景色セット
                        grid.setCell(p, 'wt_shikomi_jisseki', suJitsu, { background: "#ff6666" });
                        // エラーメッセージの表示
                        App.ui.page.notifyAlert.message(MS0829, p + "_" + grid.getColumnIndexByName("wt_shikomi_jisseki")).show();
                        return false;
                    }
                }
                // 更新データをチェック
                for (p in changeSet.changeSet.updated) {
                    if (!changeSet.changeSet.updated.hasOwnProperty(p)) {
                        continue;
                    }
                    // 仕込量
                    suJitsu = grid.jqGrid('getCell', p, 'wt_shikomi_jisseki');
                    // 仕掛品ロット番号
                    noLotShikakarihin = grid.jqGrid('getCell', p, 'no_lot_shikakari');
                    // メッセージID
                    msId = isValidSuYotei(noLotShikakarihin);
                    if (suJitsu == 0 && msId == 'MS0829') {
                        // セルを選択して入力モードを解除する
                        grid.editCell(p, grid.getColumnIndexByName('wt_shikomi_jisseki'), false);
                        // エラー背景色セット
                        grid.setCell(p, 'wt_shikomi_jisseki', suJitsu, { background: "#ff6666" });
                        // エラーメッセージの表示
                        App.ui.page.notifyAlert.message(MS0829, p + "_" + grid.getColumnIndexByName("wt_shikomi_jisseki")).show();
                        return false;
                    } else if (msId == 'MS0823') {
                        // セルを選択して入力モードを解除する
                        grid.editCell(p, grid.getColumnIndexByName('cd_shikakari_hin'), false);
                        // エラーメッセージの表示
                        App.ui.page.notifyAlert.message(MS0823).show();
                        return false;
                    }
                }
                return true;
            };

            /// <summary>仕込量（予定）のDBデータに対して0チェックを行います。</summary>
            /// <summary>＜返却値＞メッセージID</summary>
            /// <param name="value">仕掛品ロット番号</param>
            var isValidSuYotei = function (value) {
                // メッセージID
                var msId = ''
                    , _query = {
                        url: "../Services/FoodProcsService.svc/su_keikaku_shikakari",
                        filter: "no_lot_shikakari eq '" + value + "'",
                        top: 1
                    };
                App.ajax.webgetSync(
                    App.data.toODataFormat(_query)
                ).done(function (result) {
                    if (result.d.length == 0) {
                        // 更新対象が存在しない場合、エラー
                        msId = 'MS0823';
                    } else if (result.d[0].wt_shikomi_keikaku == 0) {
                        // 仕込量（予定）が0の場合、エラー
                        msId = 'MS0829';
                    };
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                });
                return msId;
            };

		    /// <summary>伝送状態が伝送済のデータがあるかどうか</summary>
		    var checkDensojotai = function () {
		        var updated = changeSet.changeSet.updated;
		        for (upId in updated) {
		            var upData = updated[upId];
		            if (getDensosumi(upData.no_lot_shikakari)) {
		                // 伝送済のデータが1件でも存在した時点で処理を抜ける
		                return true;
		            }
		        }

		        var deleted = changeSet.changeSet.deleted;
		        for (delId in deleted) {
		            var delData = deleted[delId];
		            if (getDensosumi(delData.no_lot_shikakari)) {
		                return true;
		            }
		        }

		        return false;
		    };
		    /// <summary>使用予実按分トランから伝送済のデータを取得します</summary>
		    /// <param name="shikakariLot">仕掛品ロット番号</param>
		    var getDensosumi = function (shikakariLot) {
		        var isSumi = false;
		        var _query = {
		            url: "../Services/FoodProcsService.svc/tr_sap_shiyo_yojitsu_anbun",
		            filter: "no_lot_shikakari eq '" + shikakariLot
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

		    /// <summary>整合性チェック</summary>
		    var checkSeigo = function (rowid) {
		        var flgHantei = true

		        // 仕込量が修正されていた場合は確定にチェックする
		        checkJissekiFlag();

		        // 行追加データをチェック
		        for (p in changeSet.changeSet.created) {
		            if (!changeSet.changeSet.created.hasOwnProperty(p)) {
		                continue;
		            }
		            var flgJisseki = grid.jqGrid('getCell', p, 'flg_jisseki');
		            var flgJissekiChange = grid.jqGrid('getCell', p, 'isJissekiChange');
		            var cdShikakarihin = grid.jqGrid('getCell', p, 'cd_shikakari_hin');
		            if (flgJisseki == pageLangText.chk_search_on.text || flgJissekiChange == 1) {
		                // 確定データに対してフラグが成立しているか整合性チェックを実施する
		                var yukoHan = getYukoHan(p, cdShikakarihin);
		                var _query = {
		                    url: "../Services/FoodProcsService.svc/ma_haigo_mei",
		                    filter: "cd_haigo eq '" + cdShikakarihin + "'"
                                + " and no_han eq " + yukoHan
                                + " and flg_tanto_hinkan eq " + pageLangText.trueFlg.text
		                        + " and flg_tanto_seizo eq " + pageLangText.trueFlg.text,
		                    top: 1
		                };

		                App.ajax.webgetSync(
                            App.data.toODataFormat(_query)
                        ).done(function (result) {
                            if (result.d.length == 0) {
                                rowid = p
                                flgHantei = false;
                            }
                        }).fail(function (result) {
                            App.ui.page.notifyAlert.message(result.message).show();
                            App.ui.loading.close();
                        });
		            }
		        }
		        // 更新データをチェック
		        for (p in changeSet.changeSet.updated) {
		            if (!changeSet.changeSet.updated.hasOwnProperty(p)) {
		                continue;
		            }
		            var flgJisseki = grid.jqGrid('getCell', p, 'flg_jisseki');
		            var flgJissekiChange = grid.jqGrid('getCell', p, 'isJissekiChange');
		            var cdShikakarihin = grid.jqGrid('getCell', p, 'cd_shikakari_hin');
		            if (flgJisseki == pageLangText.chk_search_on.text || flgJissekiChange == 1) {
		                // 確定データに対してフラグが成立しているか整合性チェックを実施する
		                var yukoHan = getYukoHan(p, cdShikakarihin);
		                var _query = {
		                    url: "../Services/FoodProcsService.svc/ma_haigo_mei",
		                    filter: "cd_haigo eq '" + cdShikakarihin + "'"
                                + " and no_han eq " + yukoHan
                                + " and flg_tanto_hinkan eq " + pageLangText.trueFlg.text
		                        + " and flg_tanto_seizo eq " + pageLangText.trueFlg.text,
		                    top: 1
		                };

		                App.ajax.webgetSync(
                            App.data.toODataFormat(_query)
                        ).done(function (result) {
                            if (result.d.length == 0) {
                                rowid = p
                                flgHantei = false;
                            }
                        }).fail(function (result) {
                            App.ui.page.notifyAlert.message(result.message).show();
                            App.ui.loading.close();
                        });
		            }
		        }
		        return flgHantei;
		    };

		    //// 保存処理 -- End

		    //// バリデーション -- Start

		    // グリッドコントロール固有のバリデーション

		    // TODO: 画面の仕様に応じて以下のカスタムバリデーション定義を変更してください。
		    validationSetting.cd_shikakari_hin.rules.custom = function (value) {
		        // 検索条件にラインが選択されているとき
		        if (isLineSelect) {
		            if (!isValidCode("cd_shikakari_hin", value)) {
		                return false;
		            }
		            else if (!isValidCode("cd_shikakari_hin_seizoline", value)) {
		                return false;
		            }
		            return true;
		        }
		        return isValidCode("cd_shikakari_hin", value);
		    };
		    validationSetting.cd_line.rules.custom = function (value) {
		        return isValidCode("cd_line", value);
		    };
		    /// 倍率カスタムバリデーション
		    validationSetting.ritsu_jisseki.rules.custom = function (value) {
		        return calcValid(validationSetting.ritsu_jisseki);
		    };
		    /// 倍率(端数)カスタムバリデーション
		    validationSetting.ritsu_jisseki_hasu.rules.custom = function (value) {
		        return calcValid(validationSetting.ritsu_jisseki_hasu);
		    };
		    /// Ｂ数カスタムバリデーション
		    validationSetting.su_batch_jisseki.rules.custom = function (value) {
		        return calcValid(validationSetting.su_batch_jisseki);
		    };
		    /// Ｂ数(端数)カスタムバリデーション
		    validationSetting.su_batch_jisseki_hasu.rules.custom = function (value) {
		        return calcValid(validationSetting.su_batch_jisseki_hasu);
		    };
		    /// 残使用量カスタムバリデーション
		    validationSetting.wt_zaiko_jisseki.rules.custom = function (value) {
		        return calcValid(validationSetting.wt_zaiko_jisseki);
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
		    /// <summary>データベース問い合わせチェックを行います。</summary>
		    /// <param name="colName">カラム物理名</param>
		    /// <param name="code">コード値</param>
		    var isValidCode = function (colName, value) {
		        var isValid = false
                    , _query
                    , url = ""
					, criteria = $(".search-criteria").toJSON()
                    , rowid = getSelectedRowId(false);
		        switch (colName) {
		            case "cd_shikakari_hin":
		                _query = {
		                    url: "../Services/FoodProcsService.svc/ma_haigo_mei",
		                    filter: "cd_haigo eq '" + value
                                    + "' and flg_mishiyo eq " + pageLangText.falseFlg.text,
		                    top: 1
		                }
		                break;
		            case "cd_shikakari_hin_seizoline":
		                _query = {
		                    url: "../Services/FoodProcsService.svc/vw_ma_seizo_line_02",
		                    filter: "kbn_master eq " + pageLangText.haigoMasterSeizoLineMasterKbn.text
                                    + " and (seizo_line_mishiyo eq " + pageLangText.falseFlg.text
                                    + " or line_mishiyo eq " + pageLangText.falseFlg.text + ")"
                                    + " and cd_haigo eq '" + value + "'"
                                    + " and cd_shokuba eq '" + criteria.shokuba + "'"
                                    + " and cd_line eq '" + criteria.line + "'",
		                    top: 1
		                }
		                break;
		            case "cd_line":
		                _query = {
		                    url: "../Services/FoodProcsService.svc/vw_ma_seizo_line_01",
		                    filter: "kbn_master eq " + pageLangText.haigoMasterSeizoLineMasterKbn.text
                                + " and cd_haigo eq '" + grid.getCell(rowid, "cd_shikakari_hin") + "'"
                                + " and cd_shokuba eq '" + criteria.shokuba + "'"
                                + " and seizo_line_mishiyo eq " + pageLangText.falseFlg.text
                                + " and cd_line eq '" + value + "'",
		                    orderby: "no_juni_yusen",
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
                    else if (colName === "cd_shikakari_hin") {
                        if (!isLineSelect) {
                            grid.setCell(rowid, "cd_line", null);
                            grid.setCell(rowid, "nm_line", null);
                            validationSetting.cd_shikakari_hin.messages.custom = MS0049;
                            // 更新状態の変更セットに変更データを追加
                            var changeData = setCreatedChangeData(grid.getRowData(rowid));
                            changeSet.addUpdated(rowid, "cd_line", "", changeData);
                        }
                    }
                    else if (colName === "cd_shikakari_hin_seizoline") {
                        validationSetting.cd_shikakari_hin.messages.custom = MS0657;
                    }
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                });
		        return isValid;
		    };

		    //// バリデーション -- End

		    /// ダイアログ処理の定義 -- Start

		    /// <summary> 品名マスタセレクタを起動する </summary>
		    var showHinmeiDialog = function (rowid) {
		        //// フォーカスを隣カラムへ移動させる(※値貼り付け後のバグ対策)
		        //$("#" + rowid + " td:eq('" + (selectCol + 1) + "')").click();
		        // 上の対策だと確定のセルを選択すると品名コードにフォーカスが移動するので不十分。
		        // saveEdit()をすることで後からjqGridの保存処理が実行されないようにします。
		        saveEdit();
		        var option = { id: 'hinmei', param1: hinDialogParam };
		        hinmeiDialog.draggable(true);
		        // ローディングの終了
		        App.ui.loading.close();
		        hinmeiDialog.dlg("open", option);
		    };
		    /// <summary> 製造ラインマスタセレクタを起動する </summary>
		    var showSeizoLineDialog = function (rowid) {
		        var hinmeiCode = grid.getCell(getSelectedRowId(false), "cd_shikakari_hin");
		        if (App.isUndefOrNull(hinmeiCode) || hinmeiCode === "") {
		            return;
		        }
		        //$("#" + rowid + " td:eq('" + (selectCol + 1) + "')").click();
		        saveEdit();
		        // 初期検索のために職場コードを渡す
		        var criteria = $(".search-criteria").toJSON()
                    , option = { id: 'seizoLine', multiselect: false
                                , param1: criteria.shokuba
                                , param2: hinmeiCode
                                , param3: pageLangText.haigoMasterSeizoLineMasterKbn.text
                    };
		        seizoLineDialog.draggable(true);
		        seizoLineDialog.dlg("open", option);
		    };
		    /// <summary>保存ダイアログを開きます。 </summary>
		    var showSaveConfirmDialog = function () {
		        saveConfirmDialogNotifyInfo.clear();
		        saveConfirmDialogNotifyAlert.clear();
		        saveConfirmDialog.draggable(true);
		        saveConfirmDialog.dlg("open");
		    };
		    /// <summary>検索確認ダイアログを開きます。</summary>
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
		    /// <summary>非表示列設定ダイアログの表示を行います。</summary>
		    /// <param name="e">イベントデータ</param>
		    var showColumnSettingDialog = function (e) {
		        var params = {
		            width: 300,
		            heitht: 230,
		            dataheight: 180,
		            modal: true,
		            drag: true,
		            recreateForm: true,
		            caption: pageLangText.colchange.text,
		            bCancel: pageLangText.cancel.text,
		            bSubmit: pageLangText.save.text
		        };
		        grid.setColumns(params);
		    };
		    /// <summary> ダイアログの起動可否のチェック </summary>
		    var checkShowDialog = function (rowid) {
		        if (grid.jqGrid('getCell', rowid, 'flg_jisseki') === pageLangText.falseFlg.text
                        && grid.jqGrid('getCell', rowid, 'flg_haigo_mishiyo') === pageLangText.falseFlg.text
                        && grid.jqGrid('getCell', rowid, 'flg_tani_mishiyo') === pageLangText.falseFlg.text
                        && grid.jqGrid('getCell', rowid, 'flg_line_mishiyo') === pageLangText.falseFlg.text
                        && grid.jqGrid('getCell', rowid, 'flg_seizo_line_mishiyo') === pageLangText.falseFlg.text
                        && pageLangText.trueFlg.text === grid.jqGrid('getCell', rowid, 'isAdded')) {
		            return true;
		        }
		        return false;
		    };

		    /// ダイアログ処理の定義 -- End

		    /// 各種処理の定義 -- Start

		    /// <summary> ラインを取得する </summary>
		    var setLine = function (rowid, cd_shikakari_hin) {
		        // エラーメッセージのクリア
		        App.ui.page.notifyAlert.clear();
		        var codeName,
                    criteria = $(".search-criteria").toJSON();
		        App.deferred.parallel({
		            codeName: App.ajax.webget("../Services/FoodProcsService.svc/vw_ma_seizo_line_01()?"
                            + "&$orderby=no_juni_yusen"
                            + "&$filter=kbn_master eq " + pageLangText.haigoMasterSeizoLineMasterKbn.text
                            + "and cd_haigo eq '" + cd_shikakari_hin + "'"
                            + "and cd_shokuba eq '" + criteria.shokuba + "'"
                            + "and seizo_line_mishiyo eq " + pageLangText.falseFlg.text
                            + "&$top=1")
		        }).done(function (result) {
		            // フォーカスを隣カラムへ移動させる(※値貼り付け後のバグ対策)
		            $("#" + rowid + " td:eq('" + (grid.getColumnIndexByName("cd_line") + 1) + "')").click();

		            var codeName = result.successes.codeName.d
                        , changeData = setCreatedChangeData(grid.getRowData(rowid));
		            if (!App.isUndefOrNull(codeName) && codeName.length > 0) {
		                var cd_line = codeName[0]["cd_line"];
		                grid.setCell(rowid, "cd_line", cd_line);
		                grid.setCell(rowid, "nm_line", codeName[0]["nm_line"]);
		                changeSet.addUpdated(rowid, "cd_line", cd_line, changeData);
		                validateCell(rowid, "cd_line", cd_line, grid.getColumnIndexByName("cd_line"))
		            }
		            else {
		                grid.setCell(rowid, "cd_line", null);
		                grid.setCell(rowid, "nm_line", null);
		                changeSet.addUpdated(rowid, "cd_line", null, changeData);
		                App.ui.page.notifyAlert.message(MS0616).show();
		            }
		        }).fail(function (result) {
		            var messages = [], keyName;
		            for (var i = 0; i < result.key.fails.length; i++) {
		                keyName = result.key.fails[i];
		                messages.push(keyName + " " + result.fails[keyName].message);
		            }
		            App.ui.page.notifyAlert.message(messages).show();
		        });
		    };
		    /// 使用単位を取得する
		    var setShiyoTani = function (rowid, cd_shikakari_hin) {
		        var codeName,
                    url = "../Services/FoodProcsService.svc/vw_ma_tani_01()?$filter="
                            + "cd_haigo eq '" + cd_shikakari_hin + "' and flg_mishiyo eq " + pageLangText.falseFlg.text,
                    yukoHan = getYukoHan(rowid, cd_shikakari_hin);
		        if (yukoHan != "") {
		            url = url + " and no_han eq " + yukoHan;
		        }
		        App.deferred.parallel({
		            codeName: App.ajax.webget(url)
		        }).done(function (result) {
		            var codeName = result.successes.codeName.d;
		            if (!App.isUndefOrNull(codeName) && codeName.length > 0) {
		                grid.setCell(rowid, "nm_tani", codeName[0]["nm_tani"]);
		            }
		            else {
		                grid.setCell(rowid, "nm_tani", "");
		            }
		        }).fail(function (result) {
		            var messages = [], keyName;
		            for (var i = 0; i < result.key.fails.length; i++) {
		                keyName = result.key.fails[i];
		                messages.push(keyName + " " + result.fails[keyName].message);
		            }
		            App.ui.page.notifyAlert.message(messages).show();
		        });
		        return;
		    };
		    /// 配合名マスタの有効な版番号を取得する
		    var getYukoHan = function (rowid, cd_shikakari_hin) {
		        var criteria = $(".search-criteria").toJSON(),
                    no_han = "",
                    _query = {
                        url: "../Services/FoodProcsService.svc/ma_haigo_mei",
                        filter: "cd_haigo eq '" + cd_shikakari_hin + "'"
                            + " and flg_mishiyo eq " + pageLangText.falseFlg.text
                            + " and dt_from le DateTime'" + App.data.getDateTimeStringForQueryNoUtc(criteria.con_dt_seizo_from) + "'",
                        orderby: "dt_from desc",
                        top: 1
                    };
		        App.ajax.webgetSync(
					App.data.toODataFormat(_query)
				).done(function (result) {
				    var codeName = result.d;
				    if (!App.isUndefOrNull(codeName) && codeName.length > 0) {
				        no_han = codeName[0]["no_han"];
				    }
				}).fail(function (result) {
				    App.ui.page.notifyAlert.message(result.message).show();
				});
		        return no_han;
		    };
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
		    /// ラインコンボ作成
		    var createLineCombobox = function (param) {
		        var criteria = $(".search-criteria").toJSON();
		        App.deferred.parallel({
		            lineCmb: App.ajax.webget("../Services/FoodProcsService.svc/ma_line?$filter=cd_shokuba eq '"
                                + criteria.shokuba + "' and flg_mishiyo eq " + pageLangText.falseFlg.text
                                + "&$select=cd_line,nm_line")
		        }).done(function (result) {
		            lineCmb = result.successes.lineCmb.d;
		            // 検索用ドロップダウンの設定
		            $("#condition-line > option").remove();
		            App.ui.appendOptions($("#condition-line"), "cd_line", "nm_line", lineCmb, true);
		        }).fail(function (result) {
		            App.ui.loading.close();
		            var length = result.key.fails.length,
                            messages = [];
		            for (var i = 0; i < length; i++) {
		                var keyName = result.key.fails[i];
		                var value = result.fails[keyName];
		                messages.push(keyName + " " + value.message);
		            }
		            App.ui.page.notifyAlert.message(messages).show();
		        }).always(function () {
		            if (!App.isUndefOrNull(param["dt_seizo_st"]) && param["dt_seizo_st"] != "" && !App.isUndefOrNull(param["dt_seizo_en"]) && param["dt_seizo_en"] != "") {
		                $("#condition-line").val(param["cd_line"]);
		                searchItems(new query());
		            }
		            else {
		                App.ui.loading.close();
		            }
		        });
		    };
		    /// <summary> 確定チェックボックスの状態によりセルの操作可否を設定する </summary>
		    var setCellEditable = function (rowid, isKakutei) {
		        // 確定チェックボックスに値によりセルの操作状態を設定する
		        var editableFlag = grid.getCell(rowid, "editableFlag")
                    , mishiyoFlag = grid.getCell(rowid, "mishiyoFlag");
		        // 未使用行の場合、何もしない
		        if (mishiyoFlag === pageLangText.trueFlg.text) {
		            return;
		        }
		        // 新規行であること
		        if (pageLangText.trueFlg.text === editableFlag) {
		            if (pageLangText.trueFlg.text === isKakutei) {
		                grid.jqGrid('setCell', rowid, 'cd_shikakari_hin', '', 'not-editable-cell');
		                if (!isLineSelect) {
		                    grid.jqGrid('setCell', rowid, 'cd_line', '', 'not-editable-cell');
		                }
		                grid.jqGrid('setCell', rowid, 'ritsu_jisseki', '', 'not-editable-cell');
		                grid.jqGrid('setCell', rowid, 'ritsu_jisseki_hasu', '', 'not-editable-cell');
		                grid.jqGrid('setCell', rowid, 'su_batch_jisseki', '', 'not-editable-cell');
		                grid.jqGrid('setCell', rowid, 'su_batch_jisseki_hasu', '', 'not-editable-cell');
		                grid.jqGrid('setCell', rowid, 'wt_zaiko_jisseki', '', 'not-editable-cell');
		            }
		            else {
		                grid.deleteColumnClass(rowid, 'cd_shikakari_hin', 'not-editable-cell');
		                if (!isLineSelect) {
		                    grid.deleteColumnClass(rowid, 'cd_line', 'not-editable-cell');
		                }
		                grid.deleteColumnClass(rowid, 'ritsu_jisseki', 'not-editable-cell');
		                grid.deleteColumnClass(rowid, 'ritsu_jisseki_hasu', 'not-editable-cell');
		                grid.deleteColumnClass(rowid, 'su_batch_jisseki', 'not-editable-cell');
		                grid.deleteColumnClass(rowid, 'su_batch_jisseki_hasu', 'not-editable-cell');
		                grid.deleteColumnClass(rowid, 'wt_zaiko_jisseki', 'not-editable-cell');
		                grid.jqGrid('setCell', rowid, 'isRemoveJissekiCheck', true);
		            }
		        }
		        // 既存行
		        else {
		            if (pageLangText.trueFlg.text === isKakutei) {
		                grid.jqGrid('setCell', rowid, 'ritsu_jisseki', '', 'not-editable-cell');
		                grid.jqGrid('setCell', rowid, 'ritsu_jisseki_hasu', '', 'not-editable-cell');
		                grid.jqGrid('setCell', rowid, 'su_batch_jisseki', '', 'not-editable-cell');
		                grid.jqGrid('setCell', rowid, 'su_batch_jisseki_hasu', '', 'not-editable-cell');
		                grid.jqGrid('setCell', rowid, 'wt_zaiko_jisseki', '', 'not-editable-cell');
		            }
		            else {
		                grid.deleteColumnClass(rowid, 'ritsu_jisseki', 'not-editable-cell');
		                grid.deleteColumnClass(rowid, 'ritsu_jisseki_hasu', 'not-editable-cell');
		                grid.deleteColumnClass(rowid, 'su_batch_jisseki', 'not-editable-cell');
		                grid.deleteColumnClass(rowid, 'su_batch_jisseki_hasu', 'not-editable-cell');
		                grid.deleteColumnClass(rowid, 'wt_zaiko_jisseki', 'not-editable-cell');
		                grid.jqGrid('setCell', rowid, 'isRemoveJissekiCheck', true);
		            }
		        }
		    };
		    /// ローディングの表示
		    var loading = function (msgid, fnc) {
		        App.ui.loading.show(msgid);
		        var deferred = $.Deferred();
		        deferred
                .then(function () {
                    var d = new $.Deferred;
                    setTimeout(function () {
                        App.ui.loading.show(msgid);
                        d.resolve();
                    }, 10);
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
                    else if (fnc === "lotToroku-zenbu-button") {
                        checkAllToroku();
                    }
                    else if (fnc === "excel-button") {
                        checkExcel();
                    }
                });
		        deferred.resolve();
		    };
		    var checkAll = function () {
		        // 全チェックの状態を設定する
		        if (checkButtonStatus === pageLangText.checkBoxCheckOn.text) {
		            checkButtonStatus = pageLangText.checkBoxCheckOff.text;
		        }
		        else {
		            checkButtonStatus = pageLangText.checkBoxCheckOn.text;
		        }
		        var ids = grid.jqGrid('getDataIDs');
		        for (var i = 0; i < ids.length; i++) {
		            var id = ids[i];
		            // 未使用行には何もしない
		            if (pageLangText.trueFlg.text === grid.getCell(id, "mishiyoFlag")) {
		                continue;
		            }
		            grid.setCell(id, 'flg_jisseki', checkButtonStatus);

		            // 更新状態の変更データの設定
		            var changeData = setUpdatedChangeData(grid.getRowData(id));
		            // 更新状態の変更セットに変更データを追加
		            changeSet.addUpdated(id, "flg_jisseki", checkButtonStatus, changeData);
		            // セルの操作可否を設定する
		            setCellEditable(id, grid.getCell(id, 'flg_jisseki'));

		            //「確定チェック」がチェックOnで、「登録状況」が未登録の場合は、登録チェックOnに更新
		            if (changeData["flg_jisseki"] == pageLangText.chk_search_on.text && grid.getCell(id, "kbn_toroku_jotai") == pageLangText.densoJotaiKbnMisakusei.text) {
		                $("#" + (i + 1) + " td:eq(" + grid.getColumnIndexByName("flg_toroku") + ") input").attr("disabled", false);
		            }
		            else {
		                grid.setCell(id, 'flg_toroku', pageLangText.chk_search_non.text);
		                $("#" + (i + 1) + " td:eq(" + grid.getColumnIndexByName("flg_toroku") + ") input").attr("disabled", true);

		                // 更新状態の変更セットに変更データを追加
		                changeSet.addUpdated(id, 'flg_toroku', pageLangText.falseFlg.text, changeData);
		            }
		        }
		        // ローディングの終了
		        App.ui.loading.close();
		    };
		    var checkAllToroku = function () {
		        // 全チェックの状態を設定する
		        if (checkButtonTorokuStatus === pageLangText.checkBoxCheckOn.text) {
		            checkButtonTorokuStatus = pageLangText.checkBoxCheckOff.text;
		        }
		        else {
		            checkButtonTorokuStatus = pageLangText.checkBoxCheckOn.text;
		        }
		        var ids = grid.jqGrid('getDataIDs');
		        for (var i = 0; i < ids.length; i++) {
		            var id = ids[i];

		            if (grid.getCell(id, "flg_jisseki") == pageLangText.chk_search_on.text && grid.getCell(id, "kbn_toroku_jotai") == pageLangText.densoJotaiKbnMisakusei.text) {
		                grid.setCell(id, 'flg_toroku', checkButtonTorokuStatus);
		                $("#" + (i + 1) + " td:eq(" + grid.getColumnIndexByName("flg_toroku") + ") input").attr("disabled", false);

		                // 更新状態の変更データの設定
		                var changeData = setUpdatedChangeData(grid.getRowData(id));
		                // 更新状態の変更セットに変更データを追加
		                changeSet.addUpdated(id, "flg_toroku", checkButtonTorokuStatus, changeData);
		                // セルの操作可否を設定する
		                setCellEditable(id, grid.getCell(id, 'flg_toroku'));
		            }
		        }
		        // ローディングの終了
		        App.ui.loading.close();
		    };
		    /// <summary> Excel出力前チェック </summary>
		    var checkExcel = function () {
		        var isReturn = false;
		        // 検索条件変更チェック
		        if (isCriteriaChange) {
		            showCriteriaChange("output");
		            isReturn = true;
		        }
		        if (!checkRecordCount()) {
		            isReturn = true;
		        }
		        if (!noChange()) {
		            // 明細が変更されている場合、メッセージを表示しexcelファイル出力処理を中止する
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
		    /// <summary>Excelファイル出力を行います。</summary>
		    var printExcel = function (isAllLine, e) {
		        isChanged = false;
		        var criteria = $(".search-criteria").toJSON(),
                    // 伝送状況チェックボックス
		            chk_mi_sakusei = pageLangText.chk_search_non.text,
		            chk_mi_denso = pageLangText.chk_search_non.text,
		            chk_denso_machi = pageLangText.chk_search_non.text,
		            chk_denso_zumi = pageLangText.chk_search_non.text,
                    // 登録状況チェックボックス
		            chk_mi_toroku = pageLangText.chk_search_non.text,
		            chk_ichibu_mi_toroku = pageLangText.chk_search_non.text,
		            chk_toroku_sumi = pageLangText.chk_search_non.text;

                // 伝送状況チェックボックス
		        if (!App.isUndefOrNull(criteria.chk_mi_sakusei)) {
		            chk_mi_sakusei = pageLangText.chk_search_on.text;
		        }
		        if (!App.isUndefOrNull(criteria.chk_mi_denso)) {
		            chk_mi_denso = pageLangText.chk_search_on.text;
		        }
		        if (!App.isUndefOrNull(criteria.chk_denso_machi)) {
		            chk_denso_machi = pageLangText.chk_search_on.text;
		        }
		        if (!App.isUndefOrNull(criteria.chk_denso_zumi)) {
		            chk_denso_zumi = pageLangText.chk_search_on.text;
		        }

                // 登録状況チェックボックス
		        if (!App.isUndefOrNull(criteria.chk_mi_toroku)) {
		            chk_mi_toroku = pageLangText.chk_search_on.text;
		        }
		        if (!App.isUndefOrNull(criteria.chk_ichibu_mi_toroku)) {
		            chk_ichibu_mi_toroku = pageLangText.chk_search_on.text;
		        }
		        if (!App.isUndefOrNull(criteria.chk_toroku_sumi)) {
		            chk_toroku_sumi = pageLangText.chk_search_on.text;
		        }

		        var query = {
		            url: "../api/ShikomiNippoExcel",
		            dt_seizo_st: App.data.getDateTimeStringForQueryNoUtc(criteria.con_dt_seizo_from),
		            dt_seizo_en: App.data.getDateTimeStringForQueryNoUtc(criteria.con_dt_seizo_to),
		            cd_shokuba: criteria.shokuba,
		            nm_shokuba: $(".search-criteria [name='shokuba'] option:selected").text(),
		            cd_line: criteria.line,
		            nm_line: $(".search-criteria [name='line'] option:selected").text(),
		            chk_mi_sakusei: chk_mi_sakusei,
		            chk_mi_denso: chk_mi_denso,
		            chk_denso_machi: chk_denso_machi,
		            chk_denso_zumi: chk_denso_zumi,
		            chk_mi_toroku: chk_mi_toroku,
		            chk_ichibu_mi_toroku: chk_ichibu_mi_toroku,
		            chk_toroku_sumi: chk_toroku_sumi,
		            lbl_mi_sakusei: $(".search-criteria #chk_mi_sakusei").is(':checked') ? pageLangText.onCheckBoxExcel.text : pageLangText.noSelectConditionExcel.text,
		            lbl_mi_denso: $(".search-criteria #chk_mi_denso").is(':checked') ? pageLangText.onCheckBoxExcel.text : pageLangText.noSelectConditionExcel.text,
		            lbl_denso_machi: $(".search-criteria #chk_denso_machi").is(':checked') ? pageLangText.onCheckBoxExcel.text : pageLangText.noSelectConditionExcel.text,
		            lbl_denso_zumi: $(".search-criteria #chk_denso_zumi").is(':checked') ? pageLangText.onCheckBoxExcel.text : pageLangText.noSelectConditionExcel.text,
		            lbl_mi_toroku: $(".search-criteria #chk_mi_toroku").is(':checked') ? pageLangText.onCheckBoxExcel.text : pageLangText.noSelectConditionExcel.text,
		            lbl_ichibu_mi_toroku: $(".search-criteria #chk_ichibu_mi_toroku").is(':checked') ? pageLangText.onCheckBoxExcel.text : pageLangText.noSelectConditionExcel.text,
		            lbl_toroku_sumi: $(".search-criteria #chk_toroku_sumi").is(':checked') ? pageLangText.onCheckBoxExcel.text : pageLangText.noSelectConditionExcel.text,
		            skip: querySetting.skip,
		            top: querySetting.top,
		            lang: App.ui.page.lang,
		            today: App.data.getDateTimeStringForQuery(new Date(), true),
		            userName: encodeURIComponent(App.ui.page.user.Name)
		        };

		        // 処理中を表示する
		        //App.ui.loading.show(pageLangText.nowProgressing.text);
		        // 必要な情報を渡します
		        var url = App.data.toWebAPIFormat(query);
		        // ローディングの終了
		        //App.ui.loading.close();

		        window.open(url, '_parent');
		        // Cookieを監視する
		        onComplete();
		    };
		    /// <summary> 必須項目チェック(空欄があればfalse) </summary>
		    var checkRequireds = function (rowId) {
		        return !(grid.getCell(rowId, "cd_shikakari_hin") == ""
	                    || grid.getCell(rowId, "cd_line") == ""
                        || grid.getCell(rowId, "ritsu_jisseki") == ""
	                    || grid.getCell(rowId, "su_batch_jisseki") == "");
		    };
		    /// <summary> 確定チェックに自動でチェックを付けていいか判断します。(付ける場合はtrue) </summary>
		    var checkKakutei = function (rowId) {
		        // 実績数が変更されているかつ既存行かつ必須項目が入力済みかつ未確定の場合はtrue
		        return grid.getCell(rowId, "isJissekiChange") !== ""
		        //&& grid.getCell(rowId, "isAdded") != pageLangText.trueFlg.text
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
		        }
		        // 情報メッセージ出力
		        App.ui.page.notifyAlert.message(
                        App.str.format(pageLangText.criteriaChange.text, pageLangText.searchCriteria.text, alertMessage)
                    ).show();
		    };
		    /// <summary>仕込量算出</summary>
		    var calcShikomiryo = function (rowid) {
		        var wt_haigo_gokei = grid.getCell(rowid, "wt_haigo_gokei")
                    , ritsu_jisseki = grid.getCell(rowid, "ritsu_jisseki")
                    , ritsu_jisseki_hasu = grid.getCell(rowid, "ritsu_jisseki_hasu")
                    , su_batch_jisseki = grid.getCell(rowid, "su_batch_jisseki")
                    , su_batch_jisseki_hasu = grid.getCell(rowid, "su_batch_jisseki_hasu")
		        // 算出
                    , shikomiryo = Math.multiply(wt_haigo_gokei, ritsu_jisseki, su_batch_jisseki)
                            + Math.multiply(wt_haigo_gokei, ritsu_jisseki_hasu, su_batch_jisseki_hasu);
		        if (shikomiryo <= 0) {
		            shikomiryo = 0;
		        }
		        var shikomiKiriage = Math.ceil(shikomiryo * 1000) / 1000;
		        //grid.setCell(rowid, "wt_shikomi_jisseki", shikomiryo);
		        //grid.setCell(rowid, "wt_shikomi_jisseki", shikomiKiriage);
		        if (shikomiKiriage == 0) {
                    // 計算結果の反映
		            grid.setCell(rowid, "wt_shikomi_jisseki", shikomiKiriage);
		        } else {
		            // 計算結果の反映　および　背景色を元に戻す
		            grid.setCell(rowid, "wt_shikomi_jisseki", shikomiKiriage, { background: 'none' });
                    // エラーメッセージのクリア
		            App.ui.page.notifyAlert.remove(rowid + "_" + grid.getColumnIndexByName("wt_shikomi_jisseki"));
		        }
		        var changeData = setCreatedChangeData(grid.getRowData(rowid));
		        if (!changeData) {
		            changeData = setUpdatedChangeData(grid.getRowData(rowid));
		        }
		        //changeSet.addUpdated(rowid, "wt_shikomi_jisseki", shikomiryo, changeData);
		        changeSet.addUpdated(rowid, "wt_shikomi_jisseki", shikomiKiriage, changeData);
		    };
		    /// 計算結果チェック
		    var calcValid = function (validObj) {
		        var rowid = getSelectedRowId(false);
		        // 仕込量、当日残を算出
		        calcShikomiryo(rowid);
		        calcTojitsuZan(rowid);
		        var shikomiryo = grid.getCell(rowid, "wt_shikomi_jisseki")
                    , tojitsuzan = grid.getCell(rowid, "wt_shikomi_zan")
                    , param0 = validObj.params.custom[0]
                    , param1 = validObj.params.custom[1]
                    , param2 = validObj.params.custom[2];
		        if ((shikomiryo < param1 || shikomiryo > param2)
                        && (tojitsuzan < param1 || tojitsuzan > param2)) {
		            validObj.messages.custom
                        = App.str.format(validObj.messages.custom, param0, param1, param2);
		            return false;
		        }
		        return true;
		    };
		    /// <summary>当日残算出</summary>
		    var calcTojitsuZan = function (rowid) {
		        var wt_shikomi_jisseki = grid.getCell(rowid, "wt_shikomi_jisseki")
                    , wt_zaiko_jisseki = grid.getCell(rowid, "wt_zaiko_jisseki")
                    , wt_hitsuyo = grid.getCell(rowid, "wt_hitsuyo");
		        // 算出
		        var tojitsuZan = parseFloat(wt_shikomi_jisseki != "" ? wt_shikomi_jisseki : "0")
                        + parseFloat(wt_zaiko_jisseki != "" ? wt_zaiko_jisseki : "0")
                        - parseFloat(wt_hitsuyo != "" ? wt_hitsuyo : "0");
		        if (tojitsuZan <= 0) {
		            tojitsuZan = 0;
		        }
		        grid.setCell(rowid, "wt_shikomi_zan", tojitsuZan);
		        var changeData = setCreatedChangeData(grid.getRowData(rowid));
		        if (!changeData) {
		            changeData = setUpdatedChangeData(grid.getRowData(rowid));
		        }
		        changeSet.addUpdated(rowid, "wt_shikomi_zan", tojitsuZan, changeData);
		    };
		    var backToMenu = function () {
		        // IEバグによる例外発生をキャッチします。例外発生時は何もしません。
		        try {
		            document.location = pageLangText.menuPath.url;
		        }
		        catch (e) {
		            // 何もしない
		        }
		    };

		    // Cookieを1秒ごとにチェックする
		    var onComplete = function () {
		        if (app_util.prototype.getCookieValue(pageLangText.shikomiNippoCookie.text) == pageLangText.checkCookie.text) {
		            app_util.prototype.deleteCookie(pageLangText.shikomiNippoCookie.text);
		            //ローディング終了
		            App.ui.loading.close();
		        }
		        else {
		            // 再起してCookieが作成されたか監視
		            setTimeout(onComplete, 1000);
		        }
		    };

		    /// 各種処理の定義 -- End

		    //// イベント処理定義 -- Start

		    /// <summary>検索パートの開閉ボタン押下時のイベントを定義します。</summary>

		    /// <summary>月を追加する関数。</summary>
		    var addMonth = function (date, months) {
		        var newDate = new Date(date),
                    getDate = newDate.getDate();
    
		        newDate.setMonth(newDate.getMonth() + months);
    
		        // 月を追加した後、「newDate」の日付が「getDate」の日付より小さい場合は、前月の最終日を取得します。
		        if (newDate.getDate() < getDate) {
		            newDate.setDate(0);
		        }

		        return newDate;
		    }

		    /// <summary>検索時のチェック処理を行います。</summary>
		    var checkDateSearch = function () {
		        var criteria = $(".search-criteria").toJSON();

		        //検索条件/製造日チェック
		        var DateFrom = new Date($(".search-criteria [name='con_dt_seizo_from']").datepicker("getDate"));
		        var DateTo = new Date($(".search-criteria [name='con_dt_seizo_to']").datepicker("getDate"));
		        if (DateFrom > DateTo) {
		            App.ui.page.notifyAlert.message(App.str.format(pageLangText.inputDateError.text, pageLangText.dt_seizo_end.text, pageLangText.dt_seizo_start.text), $("#condition-dt_seizo_from")).show();
		            return false;
		        }
		        //var diff = DateTo - DateFrom;
		        //var diffDay = diff / pageLangText.oneDay.text;
		        //if (diffDay > pageLangText.dt_diff.text) {
		        //    App.ui.page.notifyAlert.message(App.str.format(pageLangText.dateDiffError.text, pageLangText.dt_seizo.text, pageLangText.dt_diff.text), $("#condition-dt_seizo_from")).show();
		        //    return false;
		        //}

		        var addRangeMonth = addMonth(DateFrom, pageLangText.month_diff.text)
		        if (addRangeMonth < DateTo) {
		            App.ui.page.notifyAlert.message(App.str.format(pageLangText.dateDiffError.text, pageLangText.dt_seizo.text), $("#condition-dt_seizo_from")).show();
		            return false;
		        }

		        return true;
		    };

		    /// <summary>検索ボタンクリック時のイベント処理を行います。</summary>
		    $(".find-button").on("click", function () {
		        loading(pageLangText.nowProgressing.text, "find-button");
		    });
		    // 検索条件に変更が発生した場合
		    $(".search-criteria").on("change", function () {
		        // 検索後の状態で検索条件が変更された場合
		        if (isSearch) {
		            isCriteriaChange = true;
		        }
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
		    // <summary>チェックボックス操作時のグリッド値更新を行います</summary>
		    $(document).on("click", "#item-grid .jqgrow td :checkbox", function () {
		        var iCol = $(this).parent("td").parent("tr").find("td").index($(this).parent("td")),
                    rowid = $(this).parent("td").parent("tr").attr("id"),
                    cellName = grid.getGridParam("colModel")[iCol].name,
                    cellNameFlgToroku = "flg_toroku",
		            value;

		        saveEdit();

		        // 更新状態の変更データの設定
		        var changeData = setUpdatedChangeData(grid.getRowData(rowid));
		        // TODO：画面の仕様に応じて以下の定義を変更してください。
		        value = changeData[cellName];
		        // TODO：ここまで
		        // 更新状態の変更セットに変更データを追加
		        changeSet.addUpdated(rowid, cellName, value, changeData);
		        // 確定チェックボックスに値によりセルの操作状態を設定する
		        var editableFlag = grid.getCell(rowid, "editableFlag");
		        // 確定データは操作不可とする
		        if (cellName === "flg_jisseki") {
		            setCellEditable(rowid, value);

		            //「確定チェック」がチェックOnで、「登録状況」が未登録の場合は、登録チェックOnに更新
		            if (value == pageLangText.chk_search_on.text && grid.getCell(rowid, "kbn_toroku_jotai") == pageLangText.densoJotaiKbnMisakusei.text) {
		                $(this).parent("td").parent("tr").find("td:eq(" + grid.getColumnIndexByName(cellNameFlgToroku) + ") input").attr("disabled", false);
		            }
		            else {
		                grid.setCell(rowid, cellNameFlgToroku, pageLangText.chk_search_non.text);
		                $(this).parent("td").parent("tr").find("td:eq(" + grid.getColumnIndexByName(cellNameFlgToroku) + ") input").attr("disabled", true);

		                // 更新状態の変更セットに変更データを追加
		                changeSet.addUpdated(rowid, cellNameFlgToroku, pageLangText.falseFlg.text, changeData);
		            }
		        }
		    });
		    /// <summary>グリッドの列変更ボタンクリック時のイベント処理を行います。</summary>
		    $(".colchange-button").on("click", function (e) {
		        // 検索条件変更チェック
		        if (isCriteriaChange) {
		            showCriteriaChange("colchange");
		            return;
		        }
		        showColumnSettingDialog();
		    });
		    /// <summary>削除ボタンクリック時のイベント処理を行います。</summary>
		    $(".delete-button").on("click", function (e) {
		        // 検索条件変更チェック
		        if (isCriteriaChange) {
		            showCriteriaChange("lineDel");
		            return;
		        }
		        deleteData();
		    });
		    /// <summary>追加ボタンクリック時のイベント処理を行います。</summary>
		    $(".add-button").on("click", function (e) {
		        if ($(this).is(":disabled")) {
		            return;
		        }

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
		        grid.setGridHeight(resultPart[0].clientHeight - resultPartHeader[0].clientHeight - resultPartCommands[0].clientHeight
                    - resultPart.find(".ui-jqgrid-hdiv")[0].clientHeight - 35);
		    };
		    /// <summary>画面リサイズ時のイベント処理を行います。</summary>
		    $(App.ui.page).on("resized", resizeContents);
		    /// <summary>明細内のセル移動などでセルを離れた場合に実行されます。</summary>
		    $(document).on("blur", "#item-grid .jqgrow td", function (e) {
		        // 確定checkboxにチェックをつけます。
		        autoFlagKakutei(e);
		    });
		    /// <summary>保存確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
		    $(".save-confirm-dialog .dlg-yes-button").on("click", saveData);
		    /// <summary>保存確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
		    $(".save-confirm-dialog .dlg-no-button").on("click", closeSaveConfirmDialog);
		    /// <summary>クリア確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
		    $(".find-confirm-dialog .dlg-yes-button").on("click", function () {
		        clearState();
		        loading(pageLangText.nowProgressing.text, "find-button");
		    });
		    /// <summary>クリア確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
		    $(".find-confirm-dialog .dlg-no-button").on("click", function () {
		        // ローディングの終了
		        App.ui.loading.close();

		        closeFindConfirmDialog();
		    });

		    /// <summary>削除確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
		    $(".delete-confirm-dialog .dlg-yes-button").on("click", saveData);
		    /// <summary>削除確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
		    $(".delete-confirm-dialog .dlg-no-button").on("click", closeDeleteConfirmDialog);

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
		    /// <summary>メニューボタンクリック時のイベント処理を行います。</summary>
		    $(".menu-button").on("click", backToMenu);
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
		    /// <summary>品名検索ボタンクリック時のイベント処理を行います。</summary>
		    $(".hinmei-button").on("click", function (e) {
		        // 検索条件変更チェック
		        if (isCriteriaChange) {
		            showCriteriaChange("navigate");
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
		            showCriteriaChange("navigate");
		            return;
		        }
		        // 各種チェック
		        if (!checkRecordCount() || isLineSelect) {
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
		    /// <summary>ロット登録全チェック/解除ボタンクリック時のイベント処理を行います。</summary>
		    $(".lotTorokuZenbu-button").on("click", function (e) {
		        // 検索条件変更チェック
		        if (isCriteriaChange) {
		            showCriteriaChange("checkAndReset");
		            return;
		        }
		        if (!checkRecordCount()) {
		            return;
		        }
		        loading(MS0620, "lotToroku-zenbu-button");
		    });
		    /// <summary>EXCELボタンクリック時のイベント処理を行います。</summary>
		    $(".excel-button").on("click", function () {
		        loading(pageLangText.nowProgressing.text, "excel-button");
		    });
		    /// <summary>グリッドの列変更ボタンクリック時のイベント処理を行います。</summary>
		    $(".colchange-button").on("click", showColumnSettingDialog);
		    /// <summary>エラー一覧クリック時のイベント処理を行います。</summary>
		    $(App.ui.page.notifyAlert).on("itemselected", function (e, data) {
		        // エラー一覧クリック時の処理
		        handleNotifyAlert(data);
		    });
		    /// <summary>製造実績選択ボタンクリック時のイベント処理を行います。</summary>
		    $(".seizoJisseki-button").on("click", function () {
		        App.ui.page.notifyInfo.clear();
		        App.ui.page.notifyAlert.clear();

		        if (!checkRecordCount()) {
		            return;
		        }
		        if (!noChange()) {
		            App.ui.page.notifyInfo.message(
                        App.str.format(MS0048, pageLangText.meisai.text, pageLangText.execute.text)
                    ).show();
		            return;
		        }
		        openSeizoJissekiSentaku(getSelectedRowId(false));
		    });
		    /// <summary>原料登録ボタンクリック時のイベント処理を行います。</summary>
		    $(".lotToroku-button").on("click", function () {
		        App.ui.page.notifyInfo.clear();
		        App.ui.page.notifyAlert.clear();

		        if (!checkRecordCount()) {
		            return;
		        }
		        if (!noChange()) {
		            App.ui.page.notifyInfo.message(
                        App.str.format(MS0048, pageLangText.meisai.text, pageLangText.execute.text)
                    ).show();
		            return;
		        }
		        openGenryoLotToroku(getSelectedRowId(false));
		    });

		    //// イベント処理定義 -- Start
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
                        <span class="item-label" data-app-text="dt_seizo_start"></span>
                        <input type="text" name="con_dt_seizo_from" id="condition-dt_seizo_from" maxlength="10" />
                        <span class="item-label" data-app-text="between" style="text-align:center; width:30px;"></span>
                        <span class="item-label" data-app-text="dt_seizo_end"></span>
                        <input type="text" name="con_dt_seizo_to" id="condition-dt_seizo_to" maxlength="10" />
					</label>
				</li>
				<li>
					<label>
						<span class="item-label" data-app-text="shokuba"></span>
						<select name="shokuba" id="condition-shokuba" style="width: 138px">
						</select>
					</label>
				</li>
				<li>
					<label>
						<span class="item-label" data-app-text="line"></span>
						<select name="line" id="condition-line" style="width: 138px">
						</select>
					</label>
                </li>
                <!-- 伝送状態 -->
                <li>
                    <label>
                        <!-- 伝送状態ラベル -->
                        <span class="item-label" data-app-text="denso_jokyo"></span>

                        <!-- 未作成チェックボックス -->
                        <input type="checkbox" name="chk_mi_sakusei" id="chk_mi_sakusei" checked="checked"/>
                        <label class="item-label" data-app-text="mi_sakusei" for="chk_mi_sakusei"></label>
                        
                        <!-- 未電送チェックボックス -->
                        <input type="checkbox" name="chk_mi_denso" id="chk_mi_denso" checked="checked"/>
                        <label class="item-label" data-app-text="mi_denso" for="chk_mi_denso"></label>

                        <!-- 伝送待ちチェックボックス -->
                        <input type="checkbox" name="chk_denso_machi" id="chk_denso_machi" checked="checked"/>
                        <label class="item-label" data-app-text="denso_machi" for="chk_denso_machi"></label>

                        <!-- 伝送済みチェックボックス -->
                        <input type="checkbox" name="chk_denso_zumi" id="chk_denso_zumi" checked="checked"/>
                        <label class="item-label" data-app-text="denso_zumi" for="chk_denso_zumi"></label>
                    </label>
				</li>
                <li>
                    <label>
                        <span class="item-label" data-app-text="toroku_jokyo"></span>

                        <input type="checkbox" name="chk_mi_toroku" id="chk_mi_toroku" checked="checked"/>
                        <label class="item-label" data-app-text="mi_toroku" for="chk_mi_toroku"></label>

                        <input type="checkbox" name="chk_ichibu_mi_toroku" id="chk_ichibu_mi_toroku" checked="checked"/>
                        <label class="item-label" data-app-text="ichibu_mi_toroku" for="chk_ichibu_mi_toroku"></label>

                        <input type="checkbox" name="chk_toroku_sumi" id="chk_toroku_sumi" checked="checked"/>
                        <label class="item-label" data-app-text="toroku_sumi" for="chk_toroku_sumi"></label>
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
					<span class="icon"></span><span data-app-text="shikakariHinIchiran"></span>
				</button>
				<button type="button" class="line-button" name="line-button" data-app-operation="line">
					<span class="icon"></span><span data-app-text="lineIchiran"></span>
				</button>
				<button type="button" class="seizoJisseki-button" name="seizoJisseki-button" data-app-operation="seizoJisseki">
					<span class="icon"></span><span data-app-text="seizoJissekiSentaku"></span>
				</button>
                <button type="button" class="lotToroku-button" name="lotToroku-button" data-app-operation="lotToroku">
					<span class="icon"></span><span data-app-text="lotToroku"></span>
				</button>
                <button type="button" class="lotTorokuZenbu-button" name="lotToroku-zenbu-button" data-app-operation="lotTorokuZenbu">
					<span class="icon"></span><span data-app-text="lotTorokuZenbu"></span>
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
	<!-- TODO: ここまで  -->
	<!-- TODO: 画面の仕様に応じて以下のダイアログの設定を変更してください。 -->
	<div class="hinmei-dialog">
	</div>
	<div class="seizoLine-dialog">
	</div>
	<!-- TODO: ここまで  -->
	<!-- 画面デザイン -- End -->
</asp:Content>
