<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
	CodeBehind="GenshizaiHendoHyo.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.GenshizaiHendoHyo" %>

<asp:Content ID="Content1" ContentPlaceHolderID="IncludeContent" runat="server">
	<script src="<%=ResolveUrl("~/Resources/pages/pagedata-genshizaihendohyo." + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
		type="text/javascript"></script>
	<script src="<%=ResolveUrl("~/Resources/grid/grid.locale-" + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
		type="text/javascript"></script>
    <script src="<%=ResolveUrl("~/Scripts/util/app-util.js") %>" type="text/javascript"></script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
	<style type="text/css">
		/* 画面デザイン -- Start */
		
		/* TODO：画面の仕様に応じて以・下のスタイルを変更してください。 */
		.part-body .item-label
		{
			display: inline-block;
		}
		
		.part-body .value-label
		{
			display: inline-block;
		}
		
		#result-grid
		{
			padding: 0px
			overflow: hidden;
		}
		
		.part-body .item-list li
		{
			margin-bottom: .2em;
		}
		
		.part-body .left
		{
			float: left;
			/*clear: left;*/
			/*margin-right: 20px;*/
			margin-right: 10px;
		}

		.part-body .center
		{
			float: left;
			margin-right: 10px;
		}
		
		.part-body .right
		{
			float: left;
			margin-right: 10px;
		}

		.search-criteria select
		{
			width: 20em;
		}
		
		.search-criteria .conditionname-label
		{
			display: inline-block;
			white-space: nowrap;
			overflow: hidden;
			width: 248px;
			height: 15px;
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
		
		.search-confirm-dialog
		{
			background-color: White;
			width: 350px;
		}
				
		.search-confirm-dialog .part-body
		{
			width: 95%;
		}
		
		/* 原資材一覧ダイアログのスタイル */
		.genshizai-dialog
		{
			background-color: White;
			width: 550px;
		}
		/* 使用一覧ダイアログのスタイル */
		.shiyo-ichiran-dialog
		{
			background-color: White;
			width: 815px;
		}
		
		#item-grid .saturday-col
		{
			color: #0000FF;
			font-weight: bold;
		}
		
		#item-grid .sunday-col
		{
			color: #FF0000;
			font-weight: bold;
		}
				
		/** 休日 */
		.kyujitsu-col
		{
			background-color: #FFC0CB;
			border: #aaa 1px solid;
		}

        .value-grid th
        {
			background-color: #efefef;
	        border: #aaa 1px solid;
            padding-left: 3px;
            padding-right: 3px;
        }
        .value-grid td
        {
			background-color: #FFF;
	        border: #aaa 1px solid;
            padding-left: 3px;
            padding-right: 3px;
            text-align: right;
            white-space: nowrap;
        }
				
		/** 固定日 */
		.kotei-col
		{
			background-color: #FFCC99;
			border: #aaa 1px solid;
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
        /*備考*/
        .biko-text
        { 
           
            height: 88px;
            overflow: hidden;
            border:none;
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
	        //var pageLangText = App.ui.pagedata.lang(App.ui.page.lang),
	        var validationSetting = App.ui.pagedata.validation(App.ui.page.lang),
				querySetting = { skip: 0, top: 40, count: 0 },
				isDataLoading = false;
	        // グリッドコントロール固有の変数宣言
	        var grid = $("#item-grid"),
				lastScrollTop = 0,
	        // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
				changeSet = new App.ui.page.changeSet(),
				firstCol = 3,
				nonyuYoteiCol = 7,
				choseiCol = 11,
                zaikoCol = 14,
				duplicateCol = 999,
				currentRow = 0,
				currentCol = firstCol;
	        // TODO: ここまで

	        // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
	        var hinmeiName = 'nm_hinmei_' + App.ui.page.lang, // 多言語対応にしたい項目を変数にする
				isSearch = false,
				isCriteriaChange = false,
				loadingShow,
                idMap = {};
	        var henkoFlg;
	        $(".value-grid th").css('width', pageLangText.total_width.number);
	        $(".value-grid td").css('width', pageLangText.total_width.number);
	        // TODO：ここまで

	        // ダイアログ固有の変数宣言
	        // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
	        var saveConfirmDialog = $(".save-confirm-dialog"),
				searchConfirmDialog = $(".search-confirm-dialog");

	        // ダイアログ宣言
	        var genshizaiDialog = $(".genshizai-dialog");
	        var shiyoIchiranDialog = $(".shiyo-ichiran-dialog");
	        genshizaiDialog.dlg({
	            url: "Dialog/HinmeiDialog.aspx",
	            name: "HinmeiDialog",
	            closed: function (e, data, data2) {
	                if (data == "canceled") {
	                    // キャンセルされた場合、ダイアログを閉じる
	                    return;
	                }
	                else {
	                    // エラーメッセージのクリア
	                    App.ui.page.notifyAlert.clear();
	                    // 取得した品名コードの関連情報を設定する
	                    $("#id_hinCode").val(data);
	                    getCodeName(data);
	                }
	            }
	        });
	        shiyoIchiranDialog.dlg({
	            url: "Dialog/GenshizaiShiyoIchiranDialog.aspx",
	            name: "GenshizaiShiyoIchiranDialog",
	            closed: function (e, data, data2) {
	                if (data == "canceled") {
	                    // キャンセルされた場合、ダイアログを閉じる
	                    return;
	                }
	            }
	        });
	        // TODO：ここまで

	        //// 変数宣言 -- End

	        //// コントロール定義 -- Start

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
	        /// ダイアログ：原資材一覧を開く
	        var showGenshizaiDialog = function () {
	            // ダイアログ：原資材一覧のドラッグを可能とする
	            genshizaiDialog.draggable(true);
	            // ダイアログ：原資材一覧(品名マスタ検索を原料と資材で絞る)を開く
	            var option = { id: 'genshizai'
                                , multiselect: false
                                , param1: pageLangText.genshizaiJikagenHinDlgParam.text
                                , ismishiyo: pageLangText.falseFlg.text
	            };
	            genshizaiDialog.dlg("open", option);
	        };
	        /// ダイアログ：使用一覧を開く
	        var showShiyoIchiranDialog = function () {
	            // チェック：明細が選択されていること
	            var selectedRowId = getSelectedRowId();
	            if (App.isUndefOrNull(selectedRowId)) {
	                return;
	            }

	            var row = grid.jqGrid("getRowData", selectedRowId);
	            var criteria = $(".search-criteria").toJSON();
	            var option = { id: 'shiyoIchiran'
                                , multiselect: false
                                , hinCode: criteria.hinCode
                                , hizuke: App.date.localDate(row.dt_ymd)
	            };
	            shiyoIchiranDialog.draggable(true);
	            shiyoIchiranDialog.dlg("open", option);
	        };
	        /// <summary>ダイアログを閉じます。</summary>
	        var closeSaveConfirmDialog = function () {
	            // ローディングの終了
	            App.ui.loading.close();
	            saveConfirmDialog.dlg("close");
	        };
	        var closeSearchConfirmDialog = function () {
	            // ローディングの終了
	            App.ui.loading.close();
	            searchConfirmDialog.dlg("close");
	        };

	        // 日付の多言語対応
	        var datePickerFormat = pageLangText.dateFormatUS.text;
	        var newDateFormat = pageLangText.dateNewFormatUS.text;
	        var newDateMMDDFormat = pageLangText.dateMMDDFormatUS.text;
	        if (App.ui.page.langCountry !== 'en-US') {
	            datePickerFormat = pageLangText.dateFormat.text;
	            newDateFormat = pageLangText.dateNewFormat.text;
	            newDateMMDDFormat = pageLangText.dateMMDDFormat.text;
	        }

	        // 検索条件の表示日付の初期設定   20170906 echigo add start
	        var getKino_KensakuDateHyoji = function () {
	            var isKensakuDateHyoji_Check = 0;
	                App.ajax.webgetSync("../Services/FoodProcsService.svc/cn_kino_sentaku?$filter = kbn_kino eq " + pageLangText.kinoKensakuDateHyojiKbn.number
                    ).done(function (result) {
                        var kinoKensakuDateHyojiKbn = result.d;
                        if (kinoKensakuDateHyojiKbn.length == 1) {
                            isKensakuDateHyoji_Check = kinoKensakuDateHyojiKbn[0].kbn_kino_naiyo;     //北京杭州の場合はkbn_kino_naiyo = 1 とする。
                        }
                    }).fail(function (result) {
                        App.ui.page.notifyAlert.message(pageLangText.sysErr.text).show();
                    }).always(function () {
                        App.ui.loading.close();
                    });
	            return isKensakuDateHyoji_Check;
	        }

	        // 開始日の初期値を取得する。
	        var getDateFrom = function () {
	            var isKensakuDateHyoji_Check = getKino_KensakuDateHyoji();
	            var returnVal;
	            if (isKensakuDateHyoji_Check == 1) {
	                //開始日をその月の1日に設定する。
	                //var returnVal = new Date();
	                returnVal = new Date(new Date().getFullYear(), new Date().getMonth(), 1);
	            } else {
	                returnVal = new Date();
	            }
	            return returnVal;
	        };
            // 20170906 echigo add end

	        /// <summary>終了日の初期値を取得する。</summary>
	        var getDateTo = function () {
	            // 20170906 echigo chg start
	            var start_date = $("#condition-date_from").val();
	            start_date = new Date(start_date);
	            var dayVal = start_date.getDate();
	            var returnVal = new Date();
	            // 20170906 echigo chg end
	            if (dayVal == 1) {
	                // 開始日が1日の場合はその月の末日を設定する
	                returnVal = new Date(new Date().getFullYear(), new Date().getMonth() + 1, 0);
	            }
	            else {
	                // それ以外は開始日の31日後を設定する
	                returnVal.setDate(returnVal.getDate() + 31);
	            }

	            return returnVal;
	        };

	        /// <summary>時間を省いたシステム日付を日付オブジェクトで取得する</summary>
	        var getSystemDate = function () {
	            var sysdate = new Date(new Date().getFullYear(), new Date().getMonth(), new Date().getDate());
	            return sysdate;
	        };

	        // datepickerの設定
	        $("#condition-date_from, #condition-date_to").on("keyup", App.data.addSlashForDateString);
	        $("#condition-date_from, #condition-date_to").datepicker({
	            dateFormat: datePickerFormat,
	            minDate: new Date(1975, 1 - 1, 1),
	            maxDate: "+10y"
	        });
	        //$("#condition-date_from").datepicker = App.date.startOfDay(new Date());
	        // 20170906 echigo chg start
	        //$("#condition-date_from").datepicker = App.date.startOfDay(getDateFrom());
	        $("#condition-date_from").datepicker("setDate", getDateFrom());
            // 20170906 echigo chg end
	        $("#condition-date_to").datepicker("setDate", getDateTo());

	        // グリッドコントロール固有のコントロール定義

	        /// <summary>システム日付より固定日まで、明細/納入予定の背景色を変更する</summary>
	        /// <param name="id">対象の行ID</param>
	        /// <param name="koteiDate">固定日</param>
	        /// <param name="currentDate">対象の日付</param>
	        var changeBackground = function (id, koteiDate, currentDate) {
	            var today = App.date.localDate(App.data.getDateString(new Date(), true));   // システム日付
	            if (today < currentDate) {  // 当日=0日なので、当日以降
	                if (koteiDate >= currentDate) {
	                    grid.setCell(id, nonyuYoteiCol, "", { background: '#FFCC99' });
	                    //grid.toggleClassCol(id, nonyuYoteiCol, "kotei-col");  // 納入予定の背景だけ変更する。バリデーション後の再設定時にうまく機能しない…
	                    //grid.toggleClassRow(id, "kotei-col"); // 行全体に色をつける。バリデーション後も色が消えない。
	                }
	            }
	        };
	        // 曜日フォーマッター
	        var yobiFormatter = function (celldata, options, rowobject) {
	            var showdata = "";
	            if (celldata >= 0 && celldata <= pageLangText.yobiId.data.length) {
	                showdata = pageLangText.yobiId.data[celldata].shortName;
	            }
	            for (var i in pageLangText.yobiId.data) {
	                if (pageLangText.yobiId.data[i].shortName === celldata) {
	                    showdata = celldata;
	                }
	            }
	            return showdata;
	        };
	        /// グリッドの宣言
	        grid.jqGrid({
	            // TODO：画面の仕様に応じて以下の列名の定義を変更してください。
	            colNames: [
					pageLangText.cd_hinmei.text,
					"dt_ymd",
                    pageLangText.dt_hizuke.text,
					pageLangText.dt_yobi.text,
					pageLangText.flg_kyujitsu.text,
					pageLangText.flg_shukujitsu.text,
					pageLangText.su_nonyu_yotei.text,
					pageLangText.su_nonyu_jisseki.text,
					pageLangText.su_shiyo_yotei.text,
					pageLangText.su_shiyo_jisseki.text,
					pageLangText.su_chosei.text,
					pageLangText.su_keisanzaiko.text,
					pageLangText.su_keisanzaiko.text,
					pageLangText.su_jitsuzaiko.text,
					pageLangText.su_kurikoshi_zan.text,
                    "kbn_hin",
	            //"su_kurikoshi_zan",
                    pageLangText.su_ko.text,
                    pageLangText.su_iri.text,
                    pageLangText.cd_tani.text,
                    "flg_chosei_change",
                    "flg_zaiko_change",
                    "flg_nonyu_change"
				],
	            // TODO：ここまで
	            // TODO：画面の仕様に応じて以下の列モデルの定義を変更してください。
	            colModel: [
					{ name: 'cd_hinmei',
					    width: 100, editable: false, classes: 'not-editable-cell', sortable: false, sorttype: 'text', hidden: true,
					    hidedlg: true, align: 'left'
					},
					{ name: 'dt_ymd', width: 0, hidden: true, hidedlg: true, formatter: 'date'
					    , formatoptions: { srcformat: newDateFormat, newformat: newDateFormat }
					},
					{ name: 'dt_hizuke',
					    width: pageLangText.dt_hizuke_width.number, editable: false, classes: 'not-editable-cell', sortable: false, sorttype: 'text', align: 'center', formatter: 'date',
					    formatoptions: {
					        srcformat: newDateFormat, newformat: newDateMMDDFormat
					    }
					},
					{ name: 'dt_yobi',
					    width: pageLangText.dt_yobi_width.number, editable: false, classes: 'not-editable-cell', sortable: false, sorttype: 'text', align: 'center', formatter: yobiFormatter
					},
					{ name: 'flg_kyujitsu',
					    width: 50, editable: false, classes: 'not-editable-cell', sortable: false, sorttype: 'text', align: 'center',
					    hidden: true, hidedlg: true
					},
					{ name: 'flg_shukujitsu',
					    width: 50, editable: false, classes: 'not-editable-cell', sortable: false, sorttype: 'text', align: 'center',
					    hidden: true, hidedlg: true
					},
					{ name: 'su_nonyu_yotei',
					    //width: pageLangText.su_nonyu_yotei_width.number, editable: true, formatter: changeZeroToBlankTruncate,
					    width: pageLangText.su_nonyu_yotei_width.number, editable: true, formatter: changeZeroToBlank,
					    //formatoptions: { decimalPlaces: 2 }, editoptions: { onfocus: 'this.select()' },
					    formatoptions: { decimalPlaces: 3 }, editoptions: { onfocus: 'this.select()' },
					    sortable: false, sorttype: 'float', align: 'right'
					},
					{ name: 'su_nonyu_jisseki',
					    width: pageLangText.su_nonyu_jisseki_width.number, editable: false, classes: 'not-editable-cell',
					    //formatter: changeZeroToBlankTruncate, formatoptions: { decimalPlaces: 2 },
					    formatter: changeZeroToBlank, formatoptions: { decimalPlaces: 3 },
					    sortable: false, sorttype: 'float', align: 'right'
					},
					{ name: 'su_shiyo_yotei',
					    width: pageLangText.su_shiyo_yotei_width.number, editable: false, classes: 'not-editable-cell',
					    //formatter: changeZeroToBlankCeiling, formatoptions: { decimalPlaces: 2 },
					    formatter: changeZeroToBlank, formatoptions: { decimalPlaces: 3 },
					    sortable: false, sorttype: 'float', align: 'right'
					},
					{ name: 'su_shiyo_jisseki',
					    width: pageLangText.su_shiyo_jisseki_width.number, editable: false, classes: 'not-editable-cell',
					    //formatter: changeZeroToBlankCeiling, formatoptions: { decimalPlaces: 2 },
					    formatter: changeZeroToBlank, formatoptions: { decimalPlaces: 3 },
					    sortable: false, sorttype: 'float', align: 'right'
					},
					{ name: 'su_chosei',
					    width: pageLangText.su_chosei_width.number, editable: true, sortable: false, sorttype: 'float', align: 'right',
					    //formatter: changeZeroToBlankCeiling, formatoptions: { decimalPlaces: 2, defaultValue: '' },
					    formatter: changeZeroToBlank, formatoptions: { decimalPlaces: 3, defaultValue: '' },
					    editoptions: { onfocus: 'this.select()' }
					},
					{ name: 'su_keisanzaiko',
					    width: 0, editable: false, classes: 'not-editable-cell', hidden: true, hidedlg: true,
					    sortable: false, sorttype: 'float', align: 'right',
					    //formatter: 'number', formatoptions: { decimalPlaces: 6 }
					    formatter: 'number', formatoptions: { decimalPlaces: 3 }
					},
					{ name: 'su_keisanzaiko_disp',
					    //width: pageLangText.su_keisanzaiko_width.number, editable: false, classes: 'not-editable-cell', formatter: 'number', formatoptions: { decimalPlaces: 2 },
					    width: pageLangText.su_keisanzaiko_width.number, editable: false, classes: 'not-editable-cell', formatter: 'number', formatoptions: { decimalPlaces: 3 },
					    sortable: false, sorttype: 'float', align: 'right'
					},
					{ name: 'su_jitsuzaiko',
					    width: pageLangText.su_jitsuzaiko_width.number, editable: true, sortable: false, sorttype: 'float', align: 'right',
					    //formatter: 'number', formatoptions: { decimalPlaces: 2, defaultValue: "" },
					    formatter: 'number', formatoptions: { decimalPlaces: 3, defaultValue: "" },
					    editoptions: { onfocus: 'this.select()' }
					},
					{ name: 'su_kurikoshi_zan',
					    width: 100, editable: false, classes: 'not-editable-cell', sortable: false, sorttype: 'float', align: 'right',
					    hidden: true, hidedlg: true,
					    //formatter: 'number', formatoptions: { decimalPlaces: 2 }
					    formatter: 'number', formatoptions: { decimalPlaces: 3 }
					},
                    { name: 'kbn_hin', width: 0, hidden: true, hidedlg: true },
	            //{ name: 'su_kurikoshi_zan', width: 0, hidden: true, hidedlg: true },
                    {name: 'su_ko', width: 0, hidden: true, hidedlg: true },
                    { name: 'su_iri', width: 0, hidden: true, hidedlg: true },
                    { name: 'cd_tani', width: 0, hidden: true, hidedlg: true },
                    { name: 'flg_chosei_change', width: 0, hidden: true, hidedlg: true },
                    { name: 'flg_zaiko_change', width: 0, hidden: true, hidedlg: true },
                    { name: 'flg_nonyu_change', width: 0, hidden: true, hidedlg: true }
				],
	            // TODO：ここまで
	            datatype: "local",
	            shrinkToFit: false,
	            multiselect: false,
	            rownumbers: true,
	            cellEdit: true,
	            footerrow: true, // 下部に固定rowを追加
	            onRightClickRow: function (rowid) {
	                $("#" + rowid).removeClass("ui-state-highlight").find("td").click();
	            },
	            cellsubmit: 'clientArray',
	            loadComplete: function () {
	                // ヘッダー、フッター名設定
	                var colModel = grid.jqGrid("getGridParam", "colModel")
                        , nonyuJissekiCol = grid.getColumnIndexByName("su_nonyu_jisseki")
                        , nonyuYoteiCol = grid.getColumnIndexByName("su_nonyu_yotei")
                        , kbn_hin = $("#hinKbn").text();
	                if (kbn_hin == pageLangText.jikaGenryoHinKbn.text) {
	                    grid.jqGrid("setLabel", colModel[nonyuJissekiCol].name, pageLangText.su_seizo_jisseki.text);
	                    grid.jqGrid("setLabel", colModel[nonyuYoteiCol].name, pageLangText.su_seizo_yotei.text);
	                }
	                else {
	                    grid.jqGrid("setLabel", colModel[nonyuJissekiCol].name, pageLangText.su_nonyu_jisseki.text);
	                    grid.jqGrid("setLabel", colModel[nonyuYoteiCol].name, pageLangText.su_nonyu_yotei.text);
	                }
	                // 変数宣言
	                var ids = grid.jqGrid('getDataIDs'),
						criteria = $(".search-criteria").toJSON(),
						kurikoshiZaiko = grid.jqGrid('getCell', ids[0], 'su_kurikoshi_zan') ? grid.jqGrid('getCell', ids[0], 'su_kurikoshi_zan') : "",
						todayDate = App.date.localDate(App.data.getDateString(new Date(), true)),
						currentDate;
	                // 固定日を取得
	                var koteiDate = $("#dt_kotei").val();
	                if (!App.isUndefOrNull(koteiDate) && koteiDate != "") {
	                    koteiDate = App.data.getDate(koteiDate);
	                }

	                for (var i = 0; i < ids.length; i++) {
	                    var id = ids[i],
							yobi = (App.date.localDate(grid.jqGrid('getCell', id, 'dt_ymd', yobi))).getDay();
	                    grid.jqGrid('setCell', id, 'dt_yobi', yobi);
	                    switch (grid.jqGrid('getCell', id, 'dt_yobi')) {
	                        case pageLangText.yobiId.data[0].shortName:
	                            grid.jqGrid('setCell', id, 'dt_yobi', '', 'sunday-col');
	                            break;
	                        case pageLangText.yobiId.data[6].shortName:
	                            grid.jqGrid('setCell', id, 'dt_yobi', '', 'saturday-col');
	                            break;
	                        default:
	                    }
	                    currentDate = App.date.localDate(grid.jqGrid('getCell', id, 'dt_ymd'));
	                    if (todayDate >= currentDate) {
	                        grid.jqGrid('setCell', id, 'su_nonyu_yotei', '', 'not-editable-cell');
	                        grid.deleteColumnClass(id, 'su_jitsuzaiko', 'not-editable-cell');
	                        grid.deleteColumnClass(id, 'su_chosei', 'not-editable-cell');
	                    }
	                    if (todayDate < currentDate) {
	                        grid.jqGrid('setCell', id, 'su_jitsuzaiko', '', 'not-editable-cell');
	                        //grid.jqGrid('setCell', id, 'su_chosei', '', 'not-editable-cell');
	                    }
	                    // システム日付より固定日まで、明細/納入予定の背景色を変更する
	                    changeBackground(id, koteiDate, currentDate);
	                    // 納入予定(製造予定)の操作設定
	                    // 20170906 echigo chg start
	                    var current_date = App.date.localDate(grid.jqGrid('getCell', id, 'dt_ymd'));
	                        current_date = App.data.getDateTimeStringForQueryNoUtc(current_date);       // 明細行の日付
	                    var today_date = App.date.localDate(App.data.getDateString(new Date(), true));
	                        today_date = App.data.getDateTimeStringForQueryNoUtc(today_date);　         // 当日の日付
	                    // 20170906 echigo chg end

	                    if (kbn_hin === pageLangText.jikaGenryoHinKbn.text) {
	                        grid.jqGrid('setCell', id, 'su_nonyu_yotei', '', 'not-editable-cell');
	                    }
	                    // 20170906 echigo chg start  【北京導入時課題】当日に納入実績がある場合は、納入予定を編集不可の設定に変更
	                    //else if (todayDate <= currentDate) {
	                        //    var Tmp_nonyu_jisseki = grid.jqGrid('getCell', id, 'su_nonyu_jisseki') ? grid.jqGrid('getCell', id, 'su_nonyu_jisseki') : "0";
	                        //    if (Tmp_nonyu_jisseki == "0") {
	                        //        //grid.deleteColumnClass(id, 'su_nonyu_yotei', 'not-editable-cell');
	                            //    grid.deleteColumnClass(id, 'su_nonyu_yotei', 'not-editable-cell');
	                            //}
	                    //}
	                    else if (today_date == current_date) {  // 当日の場合
	                        var hinCd = $("#id_hinCode").val();
	                        // 納入予定を取得
	                        App.deferred.parallel({
	                            nonyu_yotei: App.ajax.webgetSync("../Services/FoodProcsService.svc/tr_nonyu()?&$filter="
                                 + "cd_hinmei eq '" + hinCd + "'"
                                 + " and " + "dt_nonyu eq Datetime'" + current_date + "'"
                                 + " and " + "flg_yojitsu eq " + "0"
                                 )
	                        }).done(function (result) {
	                            var count_yotei = result.successes.nonyu_yotei.d;   // 納入予定の件数を取得 　
	                            if (count_yotei.length != 0) {
	                                var no_nonyu = [];
	                                for (var x in count_yotei) {
	                                    no_nonyu.push(count_yotei[x].no_nonyu);
	                                }
	                                NonyuJisseki(no_nonyu,id,hinCd);
	                            } else {
	                                grid.deleteColumnClass(id, 'su_nonyu_yotei', 'not-editable-cell');
	                            }
	                        }).fail(function (result) {
	                                App.ui.page.notifyAlert.message(pageLangText.sysErr.text).show();　　// DB接続を失敗した場合 　エラーメッセージを出す
	                        })
	                    }
	                    else if (today_date < current_date) {
	                        grid.deleteColumnClass(id, 'su_nonyu_yotei', 'not-editable-cell');
	                    }
                        // 20170906 echigo chg end
	                }	                    
	                
	                // 繰越在庫の設定
	                $("#kurikoshiZaikoLabel").text(App.data.toSeparatedDigits(kurikoshiZaiko));

	                // 検索品名の設定：検索条件/品名コード + "：" + 検索条件/品名
	                var hinCd = $("#id_hinCode").val(),
	                    hinmei = "";
	                if (hinCd != "") {
	                    hinmei = hinCd + pageLangText.colon.text + $("#hinName").text();
	                }
	                $("#searchHinmei").text(hinmei);
	            },
	            gridComplete: function () {
	                // 変数宣言
	                var ids = grid.jqGrid('getDataIDs');

	                for (var i = 0; i < ids.length; i++) {
	                    var id = ids[i];
	                    // TODO : ここから
	                    idMap[id] = i;  // 行idMapの設定
	                    switch (grid.jqGrid('getCell', id, 'flg_kyujitsu')) {
	                        case "1":
	                            grid.toggleClassRow(id, "kyujitsu-col");
	                            break;
	                        default:
	                    }
	                    // 調整数の文字色
	                    var chosei = grid.jqGrid('getCell', id, 'su_chosei');
	                    changeChoseiSuColor(id, chosei);
	                    // TODO : ここまで
	                }
	                if (ids.length > 0) {
	                    idMap.length = ids.length;  // lengthプロパティを設定
	                    // 関連項目の設定
	                    setRelatedValue(ids[0], null, null, null);
	                }
	            },
	            beforeEditCell: function (selectedRowId, cellName, value, iRow, iCol) {
	                currentRow = iRow;
	                currentCol = iCol;
	                // カーソルを移動
	                grid.moveAnyCell(cellName, iRow, iCol);
	            },
	            afterEditCell: function (selectedRowId, cellName, value, iRow, iCol) {
	                // Enter キーでカーソルを移動
	                grid.moveCell(cellName, iRow, iCol);
	            },
	            beforeSaveCell: function (selectedRowId, cellName, value, iRow, iCol) {
	                if (value != "") {
	                    // カンマ区切り除去(formatterが自前なので、カンマ区切りが除去されない為)
	                    var val = deleteThousandsSeparator(value);
	                    // セルバリデーション
	                    var res = validateCell(selectedRowId, cellName, val, iCol);
	                    if (res && cellName == 'su_nonyu_yotei') {
	                        // 固定日の場合は背景色を変更する：バリデーションで背景色が戻ってしまうので、もう一度設定する
	                        var koteiDate = App.data.getDate($("#dt_kotei").val()),
                                currentDate = App.date.localDate(grid.jqGrid('getCell', selectedRowId, 'dt_ymd'));
	                        changeBackground(selectedRowId, koteiDate, currentDate);
	                    }   // エラーの場合は背景を赤のままにしておくので、固定日の背景色を設定しない
	                }
	            },
	            afterSaveCell: function (selectedRowId, cellName, value, iRow, iCol) {
	                // 重量と入数のチェック
	                if (!checkJuryoAndIrisu()) {
	                    App.ui.page.notifyAlert.clear();
	                    App.ui.page.notifyAlert.message(MS0720).show();
	                    grid.jqGrid('setCell', selectedRowId, cellName, null);  // 空白にする
	                    return;
	                }

	                // 関連項目の設定
	                setRelatedValue(selectedRowId, cellName, value, iCol);

	                // 変更データの変数設定
	                var changeData;

	                // 更新状態の変更データの設定
	                if (!henkoFlg) {
	                    changeData = setUpdatedChangeData(grid.getRowData(selectedRowId));
	                    // 更新状態の変更セットに変更データを追加
	                    if (cellName == 'su_chosei') {
	                        changeSet.addUpdated(selectedRowId, cellName, value, changeData);
	                        // 調整数を編集したフラグを立てる
	                        changeSet.addUpdated(selectedRowId, "flg_chosei_change", pageLangText.trueFlg.text, changeData);
	                    }
	                    else if (cellName == 'su_jitsuzaiko') {
	                        changeSet.addUpdated(selectedRowId, cellName, value, changeData);
	                        // 在庫数を編集したフラグを立てる
	                        changeSet.addUpdated(selectedRowId, "flg_zaiko_change", pageLangText.trueFlg.text, changeData);
	                    }
	                    else if (cellName != 'su_nonyu_yotei') {
	                        changeSet.addUpdated(selectedRowId, cellName, value, changeData);
	                    }
	                    else {
	                        changeSet.addUpdated(selectedRowId, cellName, grid.jqGrid('getCell', selectedRowId, 'su_nonyu_yotei'), changeData);
	                        // 納入予定を編集したフラグを立てる
	                        changeSet.addUpdated(selectedRowId, "flg_nonyu_change", pageLangText.trueFlg.text, changeData);
	                    }

	                    // 計算在庫の変更データ設定を行う
	                    for (var i = selectedRowId; i <= idMap.length; i++) {
	                        //var id = idMap[i];
	                        var id = i;
	                        // 更新状態の変更データの設定
	                        changeData = setUpdatedChangeData(grid.getRowData(id));
	                        // 更新状態の変更セットに変更データを追加
	                        changeSet.addUpdated(id, 'su_keisanzaiko', changeData.su_keisanzaiko, changeData);
	                    }
	                    // 関連項目の設定を変更セットに反映
	                    //setRelatedChangeData(selectedRowId, cellName, value, changeData);
	                }
	            }
	        });

	        // 20170906 echigo add start  納入実績を取得
	        var NonyuJisseki = function (no_nonyu,id,hinCd) {
	            var str = "../Services/FoodProcsService.svc/tr_nonyu()?&$filter="
                        + " cd_hinmei eq '" + hinCd
                        + "' and " + "flg_yojitsu eq " + "1" + " and (";
	            for (var i in no_nonyu) {
	                str = str + " no_nonyu_yotei eq '" + no_nonyu[i] + "'" + " or ";
	            }
	            str = str.slice(0, -3);  //末尾の" or "を削除
	            str = str + " )";
	            // 当日の納入予定に対する納入実績を抽出
	            App.deferred.parallel({
	                nonyu_jisseki: App.ajax.webgetSync(str)
	            }).done(function (result) {
	                var nonyu_jisseki = result.successes.nonyu_jisseki.d;
	                if (nonyu_jisseki.length == 0) {
	                    // 実績数が入力されていない場合は納入予定は変更可
	                    grid.deleteColumnClass(id, 'su_nonyu_yotei', 'not-editable-cell');
	                }
	            }).fail(function (result) {
	                App.ui.page.notifyAlert.message(pageLangText.sysErr.text).show();  // DB接続を失敗した場合 　エラーメッセージを出す
	            })
	        };
	        //20170906 echigo chg end

	        /// <summary>隠し項目の重量と入数が0以上であるかチェックします。0の場合はfalseを返します。</summary>
	        var checkJuryoAndIrisu = function () {
	            var idFirst = 1;
	            var su_ko = grid.jqGrid('getCell', idFirst, 'su_ko'),
                    su_iri = grid.jqGrid('getCell', idFirst, 'su_iri');

	            if (su_ko == 0 || su_iri == 0) {
	                // 入数または重量(個重量)が0の場合、falseを返却
	                return false;
	            }
	            return true;
	        };

	        /// <summary>値によって、調整数の文字色を変更します。</summary>
	        /// <param name="rowId">選択行ID</param>
	        /// <param name="chosei">調整数</param>
	        var changeChoseiSuColor = function (rowId, chosei) {
	            //調整数のカンマを取り除く
	            chosei = Number(chosei.replace(/,/, '') );
	            // 調整数 < 0 (負の数)の場合：文字色を赤色に変更
	            if (chosei < 0) {
	                // 在庫量 < 0 (正の数)の場合：文字色を黒に変更
	                grid.setCell(rowId, "su_chosei", '', { color: '#ff0000' });
	            }
	            else {
	                grid.setCell(rowId, "su_chosei", '', { color: '#000000' });
	            }
	        };

	        /// <summary>計算在庫処理の計算</summary>
	        /// <param name="beforeZaiko">前日在庫</param>
	        /// <param name="nonyu">納入数</param>
	        /// <param name="shiyo">使用数</param>
	        /// <param name="chosei">調整数</param>
	        var calculatorKeisanZaiko = function (beforeZaiko, nonyu, shiyo, chosei) {
	            // 計算在庫数 ＝ 前日在庫 ＋ 納入数 － 使用数 － 調整数
	            //	            var calVal1 = App.data.trimFixed(beforeZaiko + nonyu);
	            //	            var calVal2 = App.data.trimFixed(calVal1 - shiyo);
	            var calVal1 = beforeZaiko + nonyu;
	            var calVal2 = calVal1 - shiyo;
	            //	            var keisanZaiko = App.data.trimFixed(calVal2 - chosei);
	            //	            var keisanZaiko = Math.ceil(App.data.trimFixed((calVal2 - chosei) * 1000)) / 1000;

	            var keisanZaiko = Math.round((calVal2 - chosei) * 10000);
                keisanZaiko = Math.ceil(keisanZaiko / 10) / 1000
	            return keisanZaiko;
	        };

	        /// <summary>セルの関連項目を設定します。</summary>
	        /// <param name="selectedRowId">選択行ID</param>
	        /// <param name="cellName">列名</param>
	        /// <param name="value">元となる項目の値</param>
	        /// <param name="iCol">項目の列番号</param>
	        var setRelatedValue = function (selectedRowId, cellName, value, iCol) {
	            var idFirst = 1;

	            ///// ■調整数
	            if (cellName == "su_chosei") {
	                // 調整数の文字色
	                var chosei = grid.jqGrid('getCell', selectedRowId, 'su_chosei');
	                changeChoseiSuColor(selectedRowId, chosei);
	            }

	            ///// ■納入予定
	            if (cellName == "su_nonyu_yotei") {
	                var nonyu = 0;
	                if (value != "" && value != 0) {
	                    // 納入数の換算処理
	                    var nonyu_cs,
	                    nonyu_hasu,
                        su_ko = grid.jqGrid("getCell", idFirst, "su_ko"),
                        su_iri = grid.jqGrid("getCell", idFirst, "su_iri"),
                        cd_tani = grid.jqGrid("getCell", idFirst, "cd_tani");

	                    nonyu = deleteThousandsSeparator(value);    // カンマ除去

	                    // 個数ｘ入数
	                    var su_ko_iri = App.data.calculatorMultiply(su_ko, su_iri);

	                    //【ビジネスルール：BIZ00008】納入数 ÷（個数ｘ入数）
	                    var calcNonyu = App.data.trimFixed(nonyu / su_ko_iri);
	                    // 納入C/S数
	                    nonyu_cs = Math.floor(calcNonyu);

	                    // 納入端数の計算
	                    var nonyuVal2 = 0,
                        calHasu = 0;
	                    if (cd_tani == pageLangText.kgCdTani.text || cd_tani == pageLangText.lCdTani.text) {
	                        // 単位コードが「Kg」または「L」の場合
	                        // ((使用単位 / (1個の量×入数)) - 納入単位(納入数))×1000

	                        // 保存処理に合わせて切り上げ
	                        //calHasu = Math.ceil(App.data.trimFixed((calcNonyu - nonyu_cs) * 1000));
	                        calHasu = Math.ceil(App.data.trimFixed((calcNonyu - nonyu_cs) * 10000));
	                        nonyu_hasu = App.data.trimFixed((calHasu / 1000) * 1000);
	                        // DBは小数以下2ケタなので、2ケタ以下を切り捨てる
	                        nonyu_hasu = App.data.trimFixed(Math.floor(nonyu_hasu * 100) / 100);

	                        // 【ビジネスルール：BIZ00009】
	                        //nonyuVal2 = App.data.trimFixed(nonyu_hasu / 1000);
	                        nonyuVal2 = App.data.trimFixed(nonyu_hasu / 10000);
	                    }
	                    else {
	                        // ((使用単位 / (1個の量×入数)) - 納入単位(納入数))×入数

	                        // 保存処理に合わせて切り上げ
	                        calHasu = Math.floor(App.data.trimFixed(App.data.trimFixed(calcNonyu - nonyu_cs) * 1000));
	                        nonyu_hasu = Math.ceil(App.data.trimFixed(App.data.trimFixed(calHasu / 1000) * su_iri));

	                        // 【ビジネスルール：BIZ00009】
	                        nonyuVal2 = App.data.trimFixed(nonyu_hasu * su_ko);
	                        if (nonyuVal2 != 0 && nonyuVal2 < parseInt(su_ko, 10)) {
	                            nonyuVal2 = parseInt(su_ko, 10);
	                        }
	                    }
	                    var nonyuVal1 = App.data.trimFixed(nonyu_cs * su_ko_iri);
	                    nonyu = App.data.trimFixed(nonyuVal1 + nonyuVal2);
	                }
	                // 納入数を明細に設定する
	                grid.jqGrid("setCell", selectedRowId, "su_nonyu_yotei", nonyu);
	            }

	            ///// ■計算在庫の計算処理
	            //var ids = idMap;
	            var ids = grid.jqGrid('getDataIDs');
	            henkoFlg = true;
	            var calcKeisanZaiko = function (num) {
	                var idNum = num;
	                var keisanZaiko,
						kurikoshiZaiko,
						nonyu,
						shiyo,
						suffix,
                        hoge,
						chosei,
						zenjitsuZan,
						todayDate = App.date.localDate(App.data.getDateString(new Date, true)).getTime(),
						currentDate = App.date.localDate(grid.jqGrid('getCell', idNum, 'dt_ymd')).getTime();
	                var zai = 0;

	                // 実績か予定かを振り分け 
                    //20170906 echigo chg start
	                if (todayDate <= currentDate) {    //当日の日付　<　明細行の日付の場合
	                //20170906 echigo chg start
	                    suffix = "yotei";
	                }
	                else {
	                    suffix = "jisseki";
	                }
	                // 20170906 echigo chg start  【北京導入時課題】納入実績があれば納入実績を計算在庫に反映
	                if (todayDate >= currentDate) {   //当日の日付　>=　明細行の日付の場合
	                    hoge = "jisseki";
	                }
	                else {
	                    hoge = "yotei";
	                }
	                // 20170906 echigo chg end
	                var tmpKurikoshi = grid.jqGrid('getCell', idFirst, 'su_kurikoshi_zan') ? grid.jqGrid('getCell', idFirst, 'su_kurikoshi_zan') : "0",
                        // 20170906 echigo chg start 【北京導入時課題】納入実績があれば納入実績を計算在庫に反映 
                        //tmpNonyu = grid.jqGrid('getCell', idNum, 'su_nonyu_' + suffix) ? grid.jqGrid('getCell', idNum, 'su_nonyu_' + suffix) : "0",
						tmpNonyu = grid.jqGrid('getCell', idNum, 'su_nonyu_' + hoge) ? grid.jqGrid('getCell', idNum, 'su_nonyu_' + hoge) : grid.jqGrid('getCell', idNum, 'su_nonyu_' + suffix),
                        // 20170906 echigo chg end
                        tmpShiyo = grid.jqGrid('getCell', idNum, 'su_shiyo_' + suffix) ? grid.jqGrid('getCell', idNum, 'su_shiyo_' + suffix) : "0",
						tmpChosei = grid.jqGrid('getCell', idNum, 'su_chosei') ? grid.jqGrid('getCell', idNum, 'su_chosei') : "0",
						tmpZenjitsuZan,
						tmpJitsuZaiko;
	                kurikoshiZaiko = parseFloat(tmpKurikoshi);

	                // カンマ区切りを除去
	                nonyu = deleteThousandsSeparator(tmpNonyu);
	                shiyo = deleteThousandsSeparator(tmpShiyo);
	                chosei = deleteThousandsSeparator(tmpChosei);

	                // 20170906 echigo del start 　【北京導入時課題】実在庫を翌日の計算在庫に設定変更
	                // 実在庫が存在すれば、実在庫を計算在庫数とする
	                //tmpJitsuZaiko = (grid.jqGrid('getCell', idNum, 'su_jitsuzaiko') !== "") ? grid.jqGrid('getCell', idNum, 'su_jitsuzaiko') : "";
	                //if (tmpJitsuZaiko !== "") {
	                    //keisanZaiko = parseFloat(tmpJitsuZaiko);
	                //}
	                // 20170906 echigo del end
	                if (num == 1) {
	                ///// 1行目の時
	                // 計算在庫数の計算処理
	                    //　20170906 echigo add start 　【北京導入時課題】開始日付の前日に実在庫があれ実在庫を繰越在庫（前日在庫）に設定　
	                    var hinCd = $("#id_hinCode").val();
	                    var date_to = $(".search-criteria").toJSON().hizuke;
	                    date_to.setDate(date_to.getDate() - 1);
	                    var date_to_zen = App.data.getDateTimeStringForQueryNoUtc(date_to);
	                     
	                    App.deferred.parallel({
	                        // 検索する品名の開始日の1日前の在庫を取得	                
	                        date_zen: App.ajax.webgetSync("../Services/FoodProcsService.svc/tr_zaiko()?&$filter="
                             + "cd_hinmei eq '" + hinCd
                             + "' and " + "dt_hizuke eq Datetime'" + date_to_zen
                             + "'&$orderby=dt_hizuke desc"
                             + "&$top=1")
	                    }).done(function (result) {
	                        //if (result.successes.date_zen.d.length == 0) {
	                            // 取得できなかった場合、NULLを返却。
	                            //su_zaiko_zen = "";
                                //su_zaiko_zen = 0;
	                        //}
	                        //else {
	                        if (result.successes.date_zen.d.length != 0) 
                            {
	                            // 取得できた場合、情報を返す
	                            su_zaiko_zen = result.successes.date_zen.d[0].su_zaiko;
                                // 繰越在庫に前日在庫を設定する
	                            kurikoshiZaiko = parseFloat(su_zaiko_zen);
	                        }
	                    }).fail(function (result) {
	                        // DB接続を失敗した場合 　エラーメッセージを出してreturn
	                        App.ui.page.notifyAlert.message(pageLangText.sysErr.text).show();
	                    });
	                    //if (kurikoshiZaiko == su_zaiko_zen) {
	                        //kurikoshiZaiko = parseFloat(su_zaiko_zen);
	                    //}
	                   //　20170906 echigo add end
	                        keisanZaiko = calculatorKeisanZaiko(kurikoshiZaiko, nonyu, shiyo, chosei);
	                }else {
	                    ///// 2行目以降の時
	                    var idNum_1 = idMap[num];
	                    // 対象行の前日計算在庫数を取得
	                    tmpZenjitsuZan = (grid.jqGrid('getCell', idNum_1, 'su_jitsuzaiko') !== "") ?
						                grid.jqGrid('getCell', idNum_1, 'su_jitsuzaiko') : grid.jqGrid('getCell', idNum_1, 'su_keisanzaiko');
	                    zenjitsuZan = parseFloat(tmpZenjitsuZan);

	                    // 計算在庫数の計算処理
	                    keisanZaiko = calculatorKeisanZaiko(zenjitsuZan, nonyu, shiyo, chosei);
	                }

	                zai = keisanZaiko;
	                //keisanZaiko = Math.round(keisanZaiko * 100) / 100;

	                grid.jqGrid('setCell', idNum, 'su_keisanzaiko', zai);
	                grid.jqGrid('setCell', idNum, 'su_keisanzaiko_disp', keisanZaiko);
	                if (keisanZaiko < 0) {
	                    // 在庫量 < 0 の場合、在庫量の文字色を変更
	                    grid.setCell(idNum, "su_keisanzaiko_disp", '', { color: '#ff0000' });
	                }
	                else {
	                    grid.setCell(idNum, "su_keisanzaiko_disp", '', { color: '#000000' });
	                }
	                henkoFlg = false;
	            };
	            var calcGokei = function () {
	                var tmpNonyuYotei,
                        tmpNonyuJisseki,
                        tmpShiyoYotei,
                        tmpShiyoJisseki,
                        tmpChosei,
                        gokei = { nonyuYotei: 0, nonyuJisseki: 0, shiyoYotei: 0, shiyoJisseki: 0, chosei: 0 };
	                for (var i = 0; i < ids.length; i++) {
	                    var id = ids[i];
	                    tmpNonyuYotei = grid.jqGrid('getCell', id, 'su_nonyu_yotei') ? grid.jqGrid('getCell', id, 'su_nonyu_yotei') : "0";
	                    tmpNonyuJisseki = grid.jqGrid('getCell', id, 'su_nonyu_jisseki') ? grid.jqGrid('getCell', id, 'su_nonyu_jisseki') : "0";
	                    tmpShiyoYotei = grid.jqGrid('getCell', id, 'su_shiyo_yotei') ? grid.jqGrid('getCell', id, 'su_shiyo_yotei') : "0";
	                    tmpShiyoJisseki = grid.jqGrid('getCell', id, 'su_shiyo_jisseki') ? grid.jqGrid('getCell', id, 'su_shiyo_jisseki') : "0";
	                    tmpChosei = grid.jqGrid('getCell', id, 'su_chosei') ? grid.jqGrid('getCell', id, 'su_chosei') : "0";

	                    // カンマ区切りと小数点を除外してから計算する
	                    //tmpNonyuYotei = Math.floor(deleteThousandsSeparator(tmpNonyuYotei) * 100);
	                    tmpNonyuYotei = deleteThousandsSeparator(tmpNonyuYotei);
	                    //tmpNonyuJisseki = Math.floor(deleteThousandsSeparator(tmpNonyuJisseki) * 100);
	                    tmpNonyuJisseki = deleteThousandsSeparator(tmpNonyuJisseki);

	                    //tmpShiyoYotei = Math.floor(deleteThousandsSeparator(tmpShiyoYotei) * 1000000);
	                    tmpShiyoYotei = deleteThousandsSeparator(tmpShiyoYotei);

	                    //tmpShiyoJisseki = Math.floor(deleteThousandsSeparator(tmpShiyoJisseki) * 1000000);
	                    tmpShiyoJisseki = deleteThousandsSeparator(tmpShiyoJisseki);

	                    //tmpChosei = Math.floor(deleteThousandsSeparator(tmpChosei) * 1000000);
	                    tmpChosei = deleteThousandsSeparator(tmpChosei);

	                    gokei.nonyuYotei = gokei.nonyuYotei + tmpNonyuYotei;
	                    gokei.nonyuJisseki = gokei.nonyuJisseki + tmpNonyuJisseki;
	                    gokei.shiyoYotei = gokei.shiyoYotei + tmpShiyoYotei;
	                    gokei.shiyoJisseki = gokei.shiyoJisseki + tmpShiyoJisseki;
	                    gokei.chosei = gokei.chosei + tmpChosei;
	                }
	                //gokei.nonyuYotei = gokei.nonyuYotei / 100;
	                //gokei.nonyuJisseki = gokei.nonyuJisseki / 100;


	                //gokei.shiyoYotei = gokei.shiyoYotei / 1000000;
	                //gokei.shiyoJisseki = gokei.shiyoJisseki / 1000000;
	                //gokei.chosei = gokei.chosei / 1000000;

	                // フッターに合計を設定
	                var footData = {
	                    dt_yobi: pageLangText.total.text
	                    , dt_hizuke: pageLangText.total.text
	                    , su_nonyu_yotei: gokei.nonyuYotei
                        , su_nonyu_jisseki: gokei.nonyuJisseki
                        , su_shiyo_yotei: gokei.shiyoYotei
                        , su_shiyo_jisseki: gokei.shiyoJisseki
                        , su_chosei: gokei.chosei
	                };
	                grid.footerData('set', footData);
	            };
	            // 編集行以降分の計算在庫数を計算しなおす
	            for (var j = selectedRowId; j <= ids.length; j++) {
	                calcKeisanZaiko(j);
	            }
	            var kurikoshiId = ids.length;
	            //var kurikoshiZan = (grid.jqGrid('getCell', kurikoshiId, 'su_jitsuzaiko') !== "") ?
	            //grid.jqGrid('getCell', kurikoshiId, 'su_jitsuzaiko') : grid.jqGrid('getCell', kurikoshiId, 'su_keisanzaiko_disp');
	            var kurikoshiZan = grid.jqGrid('getCell', kurikoshiId, 'su_keisanzaiko_disp');

	            // 合計行の計算
	            calcGokei();

	            /* 2022/29/03 - 22094: -START FP-Lite ChromeBrowser Modify */
	            //20170906 echigo add start  【北京導入時課題】合計行の合計が負数の場合は赤字に変更
	            if (kurikoshiZan < 0) {
	                $('.ui-jqgrid-ftable td')[13].style.color = '#ff0000';
	            } else {
	                $('.ui-jqgrid-ftable td')[13].style.color = '#000000';
	            }
	            //20170906 echigo add　end
	            /* 2022/29/03 - 22094: -END FP-Lite ChromeBrowser Modify */


	            // フッターに繰越残を設定 カンマ区切りはつけない(数値を設定しないと表示されない)
	            grid.footerData('set', { su_keisanzaiko_disp: kurikoshiZan });
	            // TODO：ここまで
	        };

	        /// <summary>非表示列設定ダイアログの表示を行います。</summary>
	        /// <param name="e">イベントデータ</param>
	        var showColumnSettingDialog = function (e) {
	            var params = {
	                width: 300,
	                height: 230,
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
	        /// <summary>【切り捨て版】値が0だった場合、空白を返却します。</summary>
	        /// <param name="value">セルの値</param>
	        /// <param name="options">オプション</param>
	        /// <param name="rowObj">行データ</param>
	        //	        function changeZeroToBlankTruncate(value, options, rowObj) {
	        //	            var returnVal = deleteThousandsSeparator(value);
	        //	            if (returnVal == 0 || isNaN(returnVal)) {
	        //	                returnVal = "";
	        //	            }
	        //	            else {
	        //	                // 小数点以下の桁数を固定にする
	        //	                var fixeVal = options.colModel.formatoptions.decimalPlaces; // 丸め位置
	        //	                var kanzan = Math.pow(10, parseInt(fixeVal));   // べき乗
	        //	                // 指定の桁数以降は切り捨て
	        //	                var kanzanVal = Math.floor(App.data.trimFixed(returnVal * kanzan));
	        //	                returnVal = App.data.trimFixed(kanzanVal / kanzan);
	        //	                // ゼロ埋め
	        //	                returnVal = returnVal.toFixed(fixeVal); // toFixed：収まらない場合は四捨五入される
	        //	                // カンマ区切りにする
	        //	                returnVal = setThousandsSeparator(returnVal);
	        //	            }
	        //	            return returnVal;
	        //	        }
	        /// <summary>【切り上げ版】値が0だった場合、空白を返却します。</summary>
	        /// <param name="value">セルの値</param>
	        /// <param name="options">オプション</param>
	        /// <param name="rowObj">行データ</param>
	        //	        function changeZeroToBlankCeiling(value, options, rowObj) {
	        //	            var returnVal = deleteThousandsSeparator(value);
	        //	            if (returnVal == 0 || isNaN(returnVal)) {
	        //	                returnVal = "";
	        //	            }
	        //	            else {
	        //	                // 小数点以下の桁数を固定にする
	        //	                var fixeVal = options.colModel.formatoptions.decimalPlaces; // 丸め位置
	        //	                var kanzan = Math.pow(10, parseInt(fixeVal));   // べき乗
	        //	                // 指定の桁数以降は切り上げ
	        //	                var kanzanVal = Math.ceil(App.data.trimFixed(returnVal * kanzan));
	        //	                returnVal = App.data.trimFixed(kanzanVal / kanzan);
	        //	                // ゼロ埋め
	        //	                returnVal = returnVal.toFixed(fixeVal); // toFixed：収まらない場合は四捨五入される
	        //	                // カンマ区切りにする
	        //	                returnVal = setThousandsSeparator(returnVal);
	        //	            }
	        //	            return returnVal;
	        //	        }

	        /// <summary>値が0だった場合、空白を返却します。</summary>
	        /// <param name="value">セルの値</param>
	        /// <param name="options">オプション</param>
	        /// <param name="rowObj">行データ</param>
	        function changeZeroToBlank(value, options, rowObj) {
	            var returnVal = deleteThousandsSeparator(value);
	            if (returnVal == 0 || isNaN(returnVal)) {
	                returnVal = "";
	            }
	            else {
	                // 小数点以下の桁数を固定にする
	                var fixeVal = options.colModel.formatoptions.decimalPlaces; // 丸め位置
	                // ゼロ埋め
	                returnVal = returnVal.toFixed(fixeVal); // toFixed：収まらない場合は四捨五入される
	                // カンマ区切りにする
	                returnVal = setThousandsSeparator(returnVal);
	            }
	            return returnVal;
	        }

	        //// コントロール定義 -- End

	        //// 操作制御定義 -- Start

	        // 操作制御定義を定義します。
	        App.ui.pagedata.operation.applySetting(App.ui.page.user.Roles[0], App.ui.page.lang);

	        //// 操作制御定義 -- End

	        //// 事前データロード -- Start 
	        // 20170906 echigo del start
	        //// 画面アーキテクチャ共通の事前データロード
	        //App.deferred.parallel({
	        //    loadingShow: App.ui.loading.show(pageLangText.nowProgressing.text)
	        //    // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
	        //    // TODO: ここまで
	        //}).done(function (result) {
	        //    // TODO: 画面の仕様に応じて以下のサービス呼び出し成功時の処理を変更してください。
	        //    // 当日日付を挿入
	        //    //$(".search-criteria [name='hizuke']").datepicker("setDate", new Date());
	        //    // TODO: ここまで
	        //}).fail(function (result) {
	        //    var length = result.key.fails.length,
			//			messages = [];
	        //    for (var i = 0; i < length; i++) {
	        //        var keyName = result.key.fails[i];
	        //        var value = result.fails[keyName];
	        //        messages.push(keyName + " " + value.message);
	        //    }

	        //    App.ui.page.notifyAlert.message(messages).show();
	        //}).always(function () {
	        //    App.ui.loading.close();
	        //});

	        //// 事前データロード -- End
	        // 20170906 echigo del end
	        //// 検索処理 -- Start

	        // 画面アーキテクチャ共通の検索処理

	        /// <summary>クエリオブジェクトの設定</summary>
	        var query = function () {
	            var criteria = $(".search-criteria").toJSON();
	            var query = {
	                // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
	                url: "../api/GenshizaiHendoHyo",
	                cd_hinmei: criteria.hinCode,
	                dt_hizuke: App.data.getDateTimeStringForQueryNoUtc(criteria.hizuke),
	                dt_hizuke_to: App.data.getDateTimeStringForQueryNoUtc(criteria.hizuke_to),
	                today: App.data.getDateTimeStringForQueryNoUtc(getSystemDate()),
	                // TODO: ここまで
	                //filter: createFilter(),
	                // TODO: 画面の仕様に応じて以下のソート条件を変更してください。
	                orderby: "cd_hinmei",
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
	            // TODO: ここまで

	            return filters.join(" and ");
	        };
	        /// <summary>データ検索を行います。</summary>
	        /// <param name="query">クエリオブジェクト</param>
	        var searchItems = function (query) {
	            if (isDataLoading === true) {
	                return;
	            }

	            // ローディングの表示
	            App.ui.loading.show(pageLangText.nowProgressing.text);
	            isDataLoading = true;
	            App.ajax.webget(
					App.data.toWebAPIFormat(query)
				).done(function (result) {
				    // データバインド
				    bindData(result);
				    // グリッドの先頭行選択：変動表はグリッドソートがないので、むしろバインド後に選択する
				    var idNum = grid.getGridParam("selrow");
				    if (idNum == null) {
				        $("#1 > td").click();
				    }
				    else {
				        $("#" + idNum).removeClass("ui-state-highlight").find("td").click();
				    }
				    // 検索フラグを立てる
				    isSearch = true;
				    isCriteriaChange = false;
				    // 検索条件を閉じる
				    closeCriteria();
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
	        /// <summary>検索ボタンクリック時のイベント処理を行います。</summary>
	        var findData = function () {
	            closeSearchConfirmDialog();
	            // 情報メッセージのクリア
	            App.ui.page.notifyInfo.clear();
	            // エラーメッセージのクリア
	            App.ui.page.notifyAlert.clear();

	            // 検索前バリデーション
	            var result = $(".part-body .item-list").validation().validate();
	            if (result.errors.length) {
	                // ローディングの終了
	                App.ui.loading.close();
	                return;
	            }

	            // 開始日 <= 終了日 であること
	            var criteria = $(".search-criteria").toJSON();
	            if (criteria.hizuke > criteria.hizuke_to) {
	                App.ui.page.notifyAlert.message(
                        App.str.format(MS0019, pageLangText.endDate.text, pageLangText.startDate.text)
                    ).show();
	                return false;
	            }

	            // 開始日～終了日が最大期間日数以内であること
	            var startDay = criteria.hizuke;
	            var maxKikan = parseInt(pageLangText.maxPeriod.text);
	            startDay.setDate(startDay.getDate() + maxKikan);
	            if (startDay < criteria.hizuke_to) {
	                App.ui.page.notifyAlert.message(App.str.format(MS0716, maxKikan)).show();
	                return;
	            }

	            clearState();

	            // 納入計画自動作成最終日を取得する
	            getNonyuKeikakuDate();
	            searchItems(new query());
	        };
	        $(".find-button").on("click", function () {
	            loading(pageLangText.nowProgressing.text, "find-button");
	        });

	        // <summary>絶対比較（大文字と小文字）。</summary>
	        var absoluteCompareHinmei = function (hinmei, code) {
	            var valid = true;

	            if (App.isUndefOrNull(hinmei) || hinmei.length == 0)
	                return false;

	            if (App.isUndefOrNull(hinmei[0].cd_hinmei))
	                return false;
                	            
	            if (hinmei[0].cd_hinmei !== code) {
	                valid = false;
	            }

	            return valid;
	        };

	        /// <summary>検索条件/品名情報部分をクリアします。</summary>
	        var clearCodeName = function () {
	            $("#hinName").text("");
	            $("#nisugata").text("");
	            $("#hacchuLotSize").text("");
	            $("#nonyuLeadTime").text("");
	            $("#saiteiZaiko").text("");
	            $("#shiyoTani").text("");
	            $("#konyusakiCode").text("");
	            $("#konyusakiName").text("");
	            $("#hinKbn").text("");
	            $("#biko-text").text("");
	            $("#dt_kotei").val("");
	            $(".conditionname-label").each(function () {
	                if ($(this).text() === "null") {
	                    $(this).text("");
	                }
	            });
	        };
	        /// <summary>検索条件表示用コード名の検索を行います。</summary>
	        /// <param name="code">クエリオブジェクト</param>
	        var getCodeName = function (code) {
	            var isValid = false;
	            // 品名コードに入力がなければ処理を抜ける
	            if (App.isUndefOrNull(code)) {
	                clearCodeName();
	                return true;
	            }

	            // ローディング
	            App.ui.loading.show(pageLangText.nowProgressing.text);

	            var codeQuery = {
	                url: "../api/GenshizaiHendoHyo",
	                con_hinmeiCode: code
	            };

	            //App.ajax.webget(
	            App.ajax.webgetSync(
                    App.data.toWebAPIFormat(codeQuery)
                ).done(function (results) {
                    var hinName = "nm_hinmei_" + App.ui.page.lang;
                    if (results.length > 0 && absoluteCompareHinmei(results, code)) {
                        isValid = true;
                        var result = results[0];
                        var kbn_hin = result.kbn_hin;
                        $("#hinName").text(result[hinName]);
                        $("#nisugata").text(result.nm_nisugata_hyoji);
                        $("#hacchuLotSize").text(result.su_hachu_lot_size);
                        $("#nonyuLeadTime").text(result.dd_leadtime);
                        $("#saiteiZaiko").text(result.su_zaiko_min);
                        $("#konyusakiCode").text(result.cd_torihiki);
                        $("#konyusakiName").text(result.nm_torihiki);
                        $("#hinKbn").text(kbn_hin);
                        $("#dt_kotei").val(result.dt_kotei);    // hiddenなのでval
                        $("#cd_niuke_basho").val(result.cd_niuke_basho);    // hiddenなのでval
                        $("#biko-text").text(result.biko);
                        $(".conditionname-label").each(function () {
                            if ($(this).text() === "null") {
                                $(this).text("");
                            }
                        });
                        if (kbn_hin == pageLangText.shizaiHinKbn.text) {
                            getTani(result.cd_tani_shiyo);
                        }
                        else if (kbn_hin == pageLangText.genryoHinKbn.text
                                || kbn_hin == pageLangText.jikaGenryoHinKbn.text) {
                            getTani(result.kbn_kanzan);
                        }
                    }
                    else {
                        // 品名情報部分のクリア
                        clearCodeName();
                    }
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
                    if (!isDataLoading) {
                        // ローディング終了
                        App.ui.loading.close();
                    }
                });
	            return isValid;
	        };

	        /// <summary>使用単位を取得します。</summary>
	        /// <param name="taniCode">検索条件：単位コード</param>
	        var getTani = function (taniCode) {
	            var serviceUrl = "../Services/FoodProcsService.svc/ma_tani()?$filter=cd_tani eq '" + taniCode + "'"
                        + " and flg_mishiyo eq " + pageLangText.falseFlg.text
						+ "&$top=1",
					taniName = "nm_tani",
					codeName;

	            App.deferred.parallel({
	                // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
	                codeName: App.ajax.webget(serviceUrl)
	                // TODO: ここまで
	            }).done(function (result) {
	                // TODO: 画面の仕様に応じて以下のサービス呼び出し成功時の処理を変更してください。
	                codeName = result.successes.codeName.d;
	                if (codeName.length > 0) {
	                    $("#shiyoTani").text(codeName[0][taniName]);
	                }
	                else {
	                    $("#shiyoTani").text("");
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
	        var getNonyuKeikakuDate = function () {
	            var serviceUrl = "../Services/FoodProcsService.svc/tr_genshizai_keikaku()?$filter=cd_hinmei eq '"
                                    + $(".search-criteria").toJSON().hinCode + "'",
					dt_keikaku_nonyu = "dt_keikaku_nonyu",
					codeName;
	            App.deferred.parallel({
	                codeName: App.ajax.webget(serviceUrl)
	            }).done(function (result) {
	                // TODO: 画面の仕様に応じて以下のサービス呼び出し成功時の処理を変更してください。
	                codeName = result.successes.codeName.d;
	                if (codeName.length > 0 && !App.isUndefOrNull(codeName[0][dt_keikaku_nonyu])) {
	                    var date = App.data.getDateString(App.data.getDate(codeName[0][dt_keikaku_nonyu]), true);
	                    $("#dt_keikaku_nonyu").text(date);
	                    if ($(this).text() === "null") {
	                        $(this).text("");
	                    }
	                }
	                else {
	                    $("#dt_keikaku_nonyu").text("");
	                }
	                // TODO: ここまで
	            }).fail(function (result) {
	                var length = result.key.fails.length, messages = [];
	                for (var i = 0; i < length; i++) {
	                    var keyName = result.key.fails[i], value = result.fails[keyName];
	                    messages.push(keyName + " " + value.message);
	                }
	                App.ui.page.notifyAlert.message(messages).show();
	            });
	        };
	        /// <summary>存在チェック</summary>
	        /// <param name="colName">カラム物理名</param>
	        /// <param name="code">コード値</param>
	        /*
	        var isValidCode = function (name, code) {
	        var isValid = false
	        , _query
	        , url = "";
	        var checkQuery = {
	        url: "../api/GenshizaiHendoHyo",
	        con_hinmeiCode: code
	        };

	        App.ajax.webgetSync(
	        App.data.toWebAPIFormat(checkQuery)
	        ).done(function (result) {
	        if (result.length > 0) {
	        isValid = true;
	        }
	        else {
	        // 品名情報部分のクリア
	        clearCodeName();
	        }
	        }).fail(function (result) {
	        App.ui.page.notifyAlert.message(result.message).show();
	        });

	        return isValid;
	        };
	        */
	        /// <summary>検索条件変更時のイベント処理を行います。</summary>
	        $("#id_hinCode").dblclick(function () {
	            // ダブルクリック時：品名ダイアログを開く
	            showGenshizaiDialog();
	        });

	        validationSetting.hinCode.rules.custom = function (value) {
	            //return isValidCode("hinCode", value);
	            return getCodeName(value);
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
	            var resultCount = parseInt(result.__count);
	            querySetting.skip = querySetting.skip + result.d.length;
	            querySetting.count = resultCount;
	            // グリッドの表示件数を更新
	            grid.setGridParam({ rowNum: querySetting.skip });
	            displayCount(querySetting.count, resultCount);
	            // データバインド
	            var currentData = grid.getGridParam("data").concat(result.d);
	            grid.setGridParam({ data: currentData }).trigger('reloadGrid', [{ current: true}]);
	            App.ui.page.notifyInfo.message(
					 App.str.format(pageLangText.searchResultCount.text, querySetting.skip, querySetting.count)
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
	        };
	        /// <summary>エラー一覧クリック時の処理を行います。</summary>
	        /// <param name="data">エラー情報</param>
	        var handleNotifyAlert = function (data) {
	            //data.unique でキーが取得できる
	            //data.handledにtrueを指定することでデフォルトの動作(キーがHTMLElementの場合にフォーカスを当てる処理)の実行をキャンセルする
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
	        // 保存ダイアログ情報メッセージの設定
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

	        /// <summary>更新状態の変更セットに追加する変更データの設定を行います。</summary>
	        /// <param name="row">選択行</param>
	        var setUpdatedChangeData = function (row) {
	            var su_nonyu = 0,
                    kbn_hin = $("#hinKbn").text();
	            // 自家原料の場合は納入トランを作成しないので納入数を0にする
	            if (kbn_hin != pageLangText.jikaGenryoHinKbn.text) {
	                su_nonyu = row.su_nonyu_yotei;
	            }

	            var changeData = {
	                "cd_hinmei": row.cd_hinmei,
	                "dt_hizuke": App.data.getDateTimeStringForQueryNoUtc(App.date.localDate(row.dt_ymd)),
	                "su_nonyu_yotei": su_nonyu,
	                "su_chosei": row.su_chosei,
	                "su_keisanzaiko": row.su_keisanzaiko,
	                "su_jitsuzaiko": row.su_jitsuzaiko,
	                "cd_update": App.ui.page.user.Code,
	                "su_ko": row.su_ko,
	                "su_iri": row.su_iri,
	                "cd_tani": row.cd_tani,
	                "flg_chosei_change": row.flg_chosei_change,
	                "flg_zaiko_change": row.flg_zaiko_change,
	                "flg_nonyu_change": row.flg_nonyu_change,
	                "cd_niuke_basho": $("#cd_niuke_basho").val()
	            };

	            return changeData;
	        };

	        /// <summary>関連項目の設定を変更セットに反映します。</summary>
	        /// <param name="selectedRowId">選択行ID</param>
	        /// <param name="cellName">列名</param>
	        /// <param name="value">元となる項目の値</param>
	        //var setRelatedChangeData = function (selectedRowId, cellName, value, changeData) {
	        //    // TODO: 画面の仕様に応じて以下の処理を変更してください。
	        //    // TODO: ここまで
	        //};

	        //// データ変更処理 -- End

	        //// 保存処理 -- Start

	        // グリッドコントロール固有の保存処理
	        // 検索条件に変更が発生した場合は、
	        $(".search-criteria").on("change", function () {
	            // 検索後の状態で検索条件が変更された場合
	            if (isSearch) {
	                isCriteriaChange = true;
	            }
	        });

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

	            // TODO: 画面の仕様に応じて以下の変数を変更します。
	            // TODO: ここまで
	            // データ整合性エラーのハンドリングを行います。
	        };
	        /// <summary>変更を保存します。</summary>
	        /// <param name="e">イベントデータ</param>
	        var saveData = function (e) {
	            // 確認ダイアログのクローズ
	            closeSaveConfirmDialog();
	            // ローディングの表示
	            App.ui.loading.show(pageLangText.nowSaving.text);
	            // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
	            var saveUrl = "../api/GenshizaiHendoHyo";

	            // TODO: ここまで・
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
	        /// <summary>保存ボタンクリック時のイベント処理を行います。</summary>
	        $(".save-button").on("click", function () {
	            // 検索条件変更チェック
	            App.ui.page.notifyAlert.clear();
	            if (isCriteriaChange) {
	                App.ui.page.notifyAlert.message(
                        App.str.format(pageLangText.criteriaChange.text, pageLangText.searchCriteria.text, pageLangText.save.text)
                    ).show();
	                return;
	            }
	            loading(pageLangText.nowProgressing.text, "save-button");
	        });

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
	            /* 変動表は行追加なし
	            for (p in changeSet.changeSet.created) {
	            if (!changeSet.changeSet.created.hasOwnProperty(p)) {
	            continue;
	            }
	            // カレントの行バリデーションを実行
	            if (!validateRow(p)) {
	            return false;
	            }
	            }
	            */
	            for (p in changeSet.changeSet.updated) {
	                if (!changeSet.changeSet.updated.hasOwnProperty(p)) {
	                    continue;
	                }
	                // カレントの行バリデーションを実行
	                if (!validateRow(p)) {
	                    return false;
	                }
	                else {
	                    // 固定日の場合は背景色を変更する：バリデーションで背景色が戻ってしまうので、もう一度設定する
	                    var koteiDate = App.data.getDate($("#dt_kotei").val()),
                                currentDate = App.date.localDate(grid.jqGrid('getCell', p, 'dt_ymd'));
	                    changeBackground(p, koteiDate, currentDate);
	                }   // エラーの場合は背景を赤のままにしておくので、固定日の背景色を設定
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
					resultPartStyle = resultPart[0].currentStyle || document.defaultView.getComputedStyle(resultPart[0], ""),
					header = $(".header-content");

	            resultPart.height(container[0].clientHeight - searchPart[0].clientHeight - ((parseInt(resultPartStyle.marginTop, 10) * 3) || 0));
	            grid.setGridWidth(resultPart[0].clientWidth - 5);
	            //結果一覧のパートの高さ - パートのヘッダーの高さ - パート内のボタンのコマンドの高さ - jqGrid のカラムヘッダーの高さ
	            grid.setGridHeight(resultPart[0].clientHeight - resultPartHeader[0].clientHeight - resultPartCommands[0].clientHeight - resultPart.find(".ui-jqgrid-hdiv")[0].clientHeight - (35 + 20));   // 最後の20はフッターの分
	            //grid.setGridHeight(resultPart[0].clientHeight - resultPartHeader[0].clientHeight - resultPartCommands[0].clientHeight - resultPart.find(".ui-jqgrid-hdiv")[0].clientHeight - $(".value-grid")[0].clientHeight - 35);
	        };
	        /// <summary>画面リサイズ時のイベント処理を行います。</summary>
	        $(App.ui.page).on("resized", resizeContents);

	        /// <summary>保存確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
	        $(".save-confirm-dialog .dlg-yes-button").on("click", saveData);
	        // <summary>保存確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
	        $(".save-confirm-dialog .dlg-no-button").on("click", closeSaveConfirmDialog);

	        /// <summary>検索確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
	        $(".search-confirm-dialog .dlg-yes-button").on("click", function () {
	            clearState();
	            loading(pageLangText.nowProgressing.text, "find-button");
	        });
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

	        /// <summary>Excelファイル出力を行います。</summary>
	        var printExcel = function (e) {
	            var criteria = $(".search-criteria").toJSON();
	            var query = {
	                url: "../api/GenshizaiHendoHyoExcel"
                    , cd_hinmei: criteria.hinCode
                    , dt_hizuke: App.data.getDateTimeStringForQueryNoUtc(criteria.hizuke)
                    , dt_hizuke_to: App.data.getDateTimeStringForQueryNoUtc(criteria.hizuke_to)
                    , today: App.data.getDateTimeStringForQueryNoUtc(getSystemDate())
                    , lang: App.ui.page.lang
	            };
	            // 処理中を表示する
	            App.ui.loading.show(pageLangText.nowProgressing.text);

	            var url = App.data.toWebAPIFormat(query);

	            // ヘッダー用情報など
	            url = url + "&genshizaiName=" + encodeURIComponent($("#hinName").text())
                    + "&shiyoTani=" + encodeURIComponent($("#shiyoTani").text())
                    + "&konyusakiName=" + encodeURIComponent($("#konyusakiName").text())
                    + "&hinKbn=" + encodeURIComponent($("#hinKbn").text())
                    + "&bikoText=" + encodeURIComponent($("#biko-text").text())
                    + "&utc=" + new Date().getTimezoneOffset() / 60
                    + "&outputDate=" + App.data.getDateTimeStringForQuery(new Date(), true);

	            window.open(url, '_parent');
	            // Cookieを監視する
	            onComplete();
	        };

	        // Cookieを1秒ごとにチェックする
	        var onComplete = function () {
	            if (app_util.prototype.getCookieValue(pageLangText.GenshizaiHendoHyoCookie.text) == pageLangText.checkCookie.text) {
	                app_util.prototype.deleteCookie(pageLangText.GenshizaiHendoHyoCookie.text);
	                //ローディング終了
	                App.ui.loading.close();
	            }
	            else {
	                // 再起してCookieが作成されたか監視
	                setTimeout(onComplete, 1000);
	            }
	        };
	        /// <summary>ダウンロードボタンクリック時のオーバレイ処理を行います。</summary>
	        var downloadOverlay = function () {
	            App.ui.page.notifyAlert.clear();
	            //検索条件入力チェック

	            var result = $(".part-body .item-list").validation().validate();
	            if (result.errors.length) {
	                // ローディングの終了
	                //App.ui.loading.close();
	                return;
	            }

	            // 明細の変更をチェック
	            if (!noChange()) {
	                App.ui.page.notifyAlert.message(pageLangText.unprintableCheck.text
					).show();
	                return;
	            }
	            // 検索条件の変更をチェック
	            //App.ui.page.notifyAlert.clear();
	            if (isCriteriaChange) {
	                App.ui.page.notifyAlert.message(
						 App.str.format(pageLangText.criteriaChange.text, pageLangText.searchCriteria.text, pageLangText.output.text)
					).show();
	                return;
	            }
	            printExcel();
	        };
	        /// <summary>Excelボタンクリック時のイベント処理を行います。</summary>
	        $(".excel-button").on("click", downloadOverlay);

	        /// <summary>使用一覧ボタンクリック時のイベント処理を行います。</summary>
	        $(".shiyo-button").on("click", showShiyoIchiranDialog);

	        /// <summary>メニューボタンクリック時のイベント処理を行います。</summary>
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

	        /// <summary>コード検索ボタンクリック時のイベント処理を行います。</summary>
	        $("#hincode-button").on("click", function (e) {
	            // ダイアログ：原資材一覧を開く
	            showGenshizaiDialog();
	        });
	        $("input[type='text']").on("focus", function () {
	            $(this).select();
	        });

	        /// <summary>検索前チェック</summary>
	        var checkSearch = function () {
	            if (!noChange()) {
	                // ローディングの終了
	                App.ui.loading.close();
	                showSearchConfirmDialog();
	            }
	            else {
	                findData();
	            }
	        };

	        /// <summary>工場マスタから理由コード、原価センターコード、倉庫コードを取得</summary>
	        var getKojoMaster = function () {
	            var kojomaster;
	            var init_kojo = new Object;
	            init_kojo.cd_soko = '';
	            init_kojo.cd_genka_center = '';
	            init_kojo.cd_riyu = '';

	            App.deferred.parallel({
	                // 工場マスタ
	                kojomaster: App.ajax.webgetSync("../Services/FoodProcsService.svc/ma_kojo?$filter=cd_kaisha eq '" +
                            App.ui.page.user.KaishaCode + "' and cd_kojo eq '" + App.ui.page.user.BranchCode + "'")
	            }).done(function (result) {
	                kojomaster = result.successes.kojomaster.d;
	                if (!App.isUndefOrNull(kojomaster[0])) {
	                    init_kojo.cd_riyu = kojomaster[0].cd_riyu;
	                    init_kojo.cd_genka_center = kojomaster[0].cd_genka_center;
	                    init_kojo.cd_soko = kojomaster[0].cd_soko;
	                }
	            }).fail(function (result) {
	                App.ui.page.notifyAlert.message(
                            App.str.format(MS0087, pageLangText.choseiData.text, errDate), err_unique
                        ).show();
	            }).always(function () {

	            });
	            return init_kojo;
	        };

	        /// <summary>調整数のチェック処理を行います。</summary>
	        /// <param name="val_code">品名コード</param>
	        /// <param name="val_date">日付</param>
	        /// <param name="rowId">対象の行番号</param>
	        var targetCheckChoseiSu = function (val_code, val_date, rowId) {
	            var isValid = false,
                    choseiData,
	            //riyuData,
	            //sokoData,
	                checkUrl = "../Services/FoodProcsService.svc/tr_chosei?$filter=cd_hinmei eq '"
                                + val_code + "' and dt_hizuke eq DateTime'" + val_date + "'",
                    err_unique = rowId + "_" + choseiCol;
	            /*
	            riyuUrl = "../Services/FoodProcsService.svc/ma_riyu?$filter=kbn_bunrui_riyu eq "
	            + pageLangText.choseiRiyuKbn.text + "&$orderby=cd_riyu",
	            sokoUrl = "../Services/FoodProcsService.svc/ma_soko?$filter=flg_mishiyo eq "
	            + pageLangText.falseFlg.text + "&$orderby=cd_soko";
	            */
	            App.deferred.parallel({
	                choseiData: App.ajax.webgetSync(checkUrl)
	                //riyuData: App.ajax.webgetSync(riyuUrl),
	                //sokoData: App.ajax.webgetSync(sokoUrl)
	            }).done(function (result) {
	                choseiData = result.successes.choseiData.d;
	                //riyuData = result.successes.riyuData.d;
	                //sokoData = result.successes.sokoData.d;
	                var errDate = grid.jqGrid('getCell', rowId, 'dt_ymd');
	                if (choseiData.length > 1) {
	                    // 同日に複数件存在する場合はエラー
	                    App.ui.page.notifyAlert.message(
                            App.str.format(MS0734, pageLangText.choseiData.text, errDate), err_unique
                        ).show();
	                }
	                else if (choseiData.length == 1) {
	                    //理由、倉庫、原価センターの初期値取得                        
	                    var init_kojo;
	                    init_kojo = getKojoMaster();

	                    // 理由、倉庫、原価センターのいずれかが初期値でない場合エラー
	                    //if (choseiData[0].cd_riyu == riyuData[0].cd_riyu && choseiData[0].cd_genka_center == null && choseiData[0].cd_soko == sokoData[0].cd_soko) {
	                    //	                    if (choseiData[0].cd_riyu == pageLangText.init_cd_riyu.text
	                    //                                && choseiData[0].cd_genka_center == pageLangText.init_cd_genka_center.text
	                    //                                && choseiData[0].cd_soko == pageLangText.init_cd_soko.text) {
	                    if (choseiData[0].cd_riyu == init_kojo.cd_riyu
                                && choseiData[0].cd_genka_center == init_kojo.cd_genka_center
	                    //    && choseiData[0].cd_soko == init_kojo.cd_soko) {
                            && choseiData[0].cd_soko == $("#cd_niuke_basho").val()) {
	                        isValid = true;
	                    }
	                    else {
	                        App.ui.page.notifyAlert.message(
                                App.str.format(
                                    pageLangText.initErr.text
                                    , pageLangText.initChoseiKey.text
                                    , pageLangText.choseiData.text
                                    , errDate), err_unique
                            ).show();
	                    }
	                    //isValid = true;
	                }
	                else {
	                    isValid = true;
	                }
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
	            return isValid;
	        };

	        /// <summary>編集された調整数のみを対象とする。</summary>
	        var checkChoseiSu = function () {
	            var isValid = true;
	            for (p in changeSet.changeSet.updated) {
	                if (!changeSet.changeSet.updated.hasOwnProperty(p)) {
	                    continue;
	                }
	                var upData = changeSet.changeSet.updated[p];
	                // 編集された調整数のみを対象とする
	                if (upData.flg_chosei_change == pageLangText.trueFlg.text) {
	                    var val_code = upData.cd_hinmei,
                            val_date = upData.dt_hizuke;
	                    // チェック処理
	                    var result = targetCheckChoseiSu(val_code, val_date, p);
	                    if (!result) {
	                        isValid = false;
	                        break;
	                    }
	                }
	            }
	            return isValid;
	        };

	        /// <summary>在庫数のチェック処理を行います。</summary>
	        /// <param name="val_code">品名コード</param>
	        /// <param name="val_date">日付</param>
	        /// <param name="rowId">対象の行番号</param>
	        var targetCheckZaikoSu = function (val_code, val_date, rowId) {
	            var isValid = false,
                    zaikoData,
	                checkUrl = "../Services/FoodProcsService.svc/tr_zaiko?$filter=cd_hinmei eq '"
                                + val_code + "' and dt_hizuke eq DateTime'" + val_date
                                + "' and kbn_zaiko eq " + pageLangText.ryohinZaikoKbn.text,
                    err_unique = rowId + "_" + zaikoCol;

	            App.deferred.parallel({
	                zaikoData: App.ajax.webgetSync(checkUrl)
	            }).done(function (result) {
	                zaikoData = result.successes.zaikoData.d;
	                var errDate = grid.jqGrid('getCell', rowId, 'dt_ymd');
	                if (zaikoData.length > 1) {
	                    // 同日に複数件存在する場合はエラー
	                    App.ui.page.notifyAlert.message(
                            App.str.format(MS0734, pageLangText.zaikoData.text, errDate), err_unique
                        ).show();
	                }
	                else if (zaikoData.length == 1) {
	                    // 倉庫が初期値でない場合エラー
	                    //var init_kojo;
	                    //init_kojo = getKojoMaster();
	                    //if (zaikoData[0].cd_soko == init_kojo.cd_soko) {
	                    if (zaikoData[0].cd_soko == $("#cd_niuke_basho").val()) {
	                        isValid = true;
	                    }
	                    else {
	                        App.ui.page.notifyAlert.message(
                                App.str.format(pageLangText.initErr.text
                                    , pageLangText.initZaikoKey.text
                                    , pageLangText.zaikoData.text
                                    , errDate), err_unique
                            ).show();
	                    }
	                    //isValid = true;
	                }
	                else {
	                    isValid = true;
	                }
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
	            return isValid;
	        };
	        /// <summary>編集された在庫数のみを対象とする。</summary>
	        var checkZaikoSu = function () {
	            var isValid = true;
	            for (p in changeSet.changeSet.updated) {
	                if (!changeSet.changeSet.updated.hasOwnProperty(p)) {
	                    continue;
	                }
	                var upData = changeSet.changeSet.updated[p];
	                // 編集された在庫数のみを対象とする
	                if (upData.flg_zaiko_change == pageLangText.trueFlg.text) {
	                    var val_code = upData.cd_hinmei,
                            val_date = upData.dt_hizuke;
	                    // チェック処理
	                    var result = targetCheckZaikoSu(val_code, val_date, p);
	                    if (!result) {
	                        isValid = false;
	                        break;
	                    }
	                }
	            }
	            return isValid;
	        };

	        /// <summary>納入予定のチェック処理を行います。</summary>
	        /// <param name="val_code">品名コード</param>
	        /// <param name="val_date">日付</param>
	        /// <param name="rowId">対象の行番号</param>
	        var targetCheckNonyuSu = function (val_code, val_date, rowId) {
	            var isValid = false,
                    nonyuData,
	                checkUrl = "../Services/FoodProcsService.svc/tr_nonyu?$filter=cd_hinmei eq '"
                                + val_code + "' and dt_nonyu eq DateTime'" + val_date
                                + "' and flg_yojitsu eq " + pageLangText.yoteiYojitsuFlg.text,
                    err_unique = rowId + "_" + nonyuYoteiCol;

	            App.deferred.parallel({
	                nonyuData: App.ajax.webgetSync(checkUrl)
	            }).done(function (result) {
	                nonyuData = result.successes.nonyuData.d;
	                var errDate = grid.jqGrid('getCell', rowId, 'dt_ymd');
	                if (nonyuData.length > 1) {
	                    // 同日に複数件存在する場合はエラー
	                    App.ui.page.notifyAlert.message(
                            App.str.format(MS0734, pageLangText.su_nonyu_yotei.text, errDate), err_unique
                        ).show();
	                }
	                else {
	                    isValid = true;
	                }
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
	            return isValid;
	        };
	        /// <summary>編集された納入予定のみを対象とする。</summary>
	        var checkNonyuSu = function () {
	            var isValid = true;
	            for (p in changeSet.changeSet.updated) {
	                if (!changeSet.changeSet.updated.hasOwnProperty(p)) {
	                    continue;
	                }
	                var upData = changeSet.changeSet.updated[p];
	                // 編集された納入予定のみを対象とする
	                if (upData.flg_nonyu_change == pageLangText.trueFlg.text) {
	                    var val_code = upData.cd_hinmei,
                            val_date = upData.dt_hizuke;
	                    // チェック処理
	                    var result = targetCheckNonyuSu(val_code, val_date, p);
	                    if (!result) {
	                        isValid = false;
	                        break;
	                    }
	                }
	            }
	            return isValid;
	        };

	        /// <summary>保存前チェック</summary>
	        var checkSave = function () {
	            // エラーメッセージのクリア
	            App.ui.page.notifyAlert.clear();
	            // 編集内容の保存
	            saveEdit();
	            var isReturn = false;
	            // 変更セット内にバリデーションエラーがある場合は処理を抜ける
	            if (!validateChangeSet()) {
	                isReturn = true;
	            }
	            // 明細に変更がない場合は処理を抜ける
	            if (noChange()) {
	                App.ui.page.notifyAlert.message(pageLangText.noChange.text
					).show();
	                isReturn = true;
	            }
	            // 納入予定のチェック
	            if (!checkNonyuSu()) {
	                isReturn = true;
	            }
	            // 調整数のチェック
	            if (!checkChoseiSu()) {
	                isReturn = true;
	            }
	            // 在庫数のチェック
	            if (!checkZaikoSu()) {
	                isReturn = true;
	            }

	            // ローディングの終了
	            App.ui.loading.close();
	            if (isReturn) {
	                return;
	            }
	            //showSaveConfirmDialog();
	            saveData();
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
                });
	            deferred.resolve();
	        };

	        ////////// 警告リスト作成画面から遷移してきたときの処理
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
	        //var paramDate = parameters["date"];
	        var paramCode = parameters["cdHin"];
	        var paramDateFrom = parameters["dateFrom"];
	        var paramDateTo = parameters["dateTo"];
	        //if (!App.isUndefOrNull(paramDate) && !App.isUndefOrNull(paramCode)) {
	        if (!App.isUndefOrNull(paramDateFrom) && !App.isUndefOrNull(paramDateTo) && !App.isUndefOrNull(paramCode)) {
	            //$(".search-criteria [name='hizuke']").val(paramDate);
	            $(".search-criteria [name='hinCode']").val(paramCode);
	            // 受け取った開始日の末日を終了日に設定
	            //var dt_end = App.date.localDate(paramDate);
	            //dt_end = new Date(dt_end.getFullYear(), dt_end.getMonth() + 1, 0);
	            //$("#condition-date_to").datepicker("setDate", dt_end);

	            var dt_from = App.date.localDate(paramDateFrom);
	            var dt_end = App.date.localDate(paramDateTo);

	            $("#condition-date_from").datepicker("setDate", dt_from);
	            $("#condition-date_to").datepicker("setDate", dt_end);
	            // 品コードから原資材情報を取得
	            getCodeName(paramCode);
	            // パラメーターを条件に検索処理を行う
	            findData();
	        }
	        ////////// 警告リスト作成画面から遷移してきたときの処理：ここまで
	    });
	</script>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
	<!-- 画面デザイン -- Start -->

	<!-- 検索条件と検索ボタン -->
	<div class="content-part search-criteria">
		<h3 class="part-header" data-app-text="searchCriteria"><a class="search-part-toggle" href="#"></a></h3>
		<div class="part-body">
			<ul class="item-list item-command">
				<!-- TODO: 画面の仕様に応じて以下の検索条件を変更してください。-->
				<li>
					<label>
						<span class="item-label" data-app-text="hizuke"></span>
						<input type="text" name="hizuke" id="condition-date_from" maxlength="10" style="width: 110px" />
					</label>
                    <span data-app-text="between"></span>
                    <label>
                        <input type="text" name="hizuke_to" id="condition-date_to" maxlength="10" style="width: 110px" />
                    </label>
				</li>
				<li>
					<label>
						<span class="item-label" data-app-text="hinCode"></span>
						<input type="text" name="hinCode" id="id_hinCode" maxlength="14" style="width: 110px" />
					</label>
                    <button type="button" class="dialog-button" id="hincode-button">
                        <span class="icon"></span><span data-app-text="codeSearch"></span>
                    </button>
				</li>
			</ul>
			<ul class="item-list left">
				<li>
					<label>
						<span class="item-label" data-app-text="hinName"></span>
						<span class="conditionname-label" id="hinName"></span>
						<span class="conditionname-label" id="hinKbn" style="display: none"></span>
					</label>
				</li>
				<li>
					<label>
						<span class="item-label" data-app-text="nisugata"></span>
						<span class="conditionname-label" id="nisugata"></span>
					</label>
				</li>
				<li>
					<label>
						<span class="item-label" data-app-text="hacchuLotSize" style="height: 18px;"></span>
						<span class="conditionname-label" id="hacchuLotSize" style="height: 18px;"></span>
					</label>
				</li>
				<li>
					<label>
						<span class="item-label" data-app-text="nonyuLeadTime"></span>
						<span class="conditionname-label" id="nonyuLeadTime"></span>
					</label>
				</li>
			</ul>
			<!--<ul class="item-list right">-->
			<ul class="item-list center" >
				<li>
					<label>
						<span class="item-label" data-app-text="saiteiZaiko"></span>
						<span class="conditionname-label" id="saiteiZaiko"></span>
					</label>
				</li>
				<li>
					<label>
						<span class="item-label" data-app-text="shiyoTani" style="height: 18px;"></span>
						<span class="conditionname-label" id="shiyoTani" style="height: 18px;"></span>
					</label>
				</li>
				<li>
					<label>
						<span class="item-label" data-app-text="konyusakiCode"></span>
						<span class="conditionname-label" id="konyusakiCode"></span>
					</label>
				</li>
				<li>
					<label>
						<span class="item-label" data-app-text="konyusakiName"></span>
						<span class="conditionname-label" id="konyusakiName"></span>
					</label>
				</li>
                <li>
                    <input type="hidden" id="dt_kotei" name="dt_kotei" />
                    <input type="hidden" id="cd_niuke_basho" name="cd_niuke_basho" />
                </li>
			</ul>
			<ul class="item-list right" >
				<li>
					<label>
						<span class="item-label biko-text" data-app-text="biko" style="width:50px;"></span>
                        <%--/* 2022/29/03 - 22094: -START FP-Lite ChromeBrowser Modify */--%>
                        <textarea class="biko-text" id="biko-text" readonly="readonly" cols="47" rows="2" style="resize: none;" ></textarea>
                        <%--/* 2022/29/03 - 22094: -END FP-Lite ChromeBrowser Modify */--%>
					</label>
				</li>
			</ul>
		</div>
		<!--<div class="part-footer">-->
		<div class="part-footer" style="clear:left;">
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
		<h3 id="listHeader" class="part-header" style="display: none;" >
			<span data-app-text="resultList" style="padding-right: 10px;"></span>
			<span class="list-count" id="list-count" ></span>
			<span style="padding-left: 50px;" class="list-loading-message" id="list-loading-message" ></span>
		</h3>
		<div class="part-body" id="result-grid">
			<div class="item-command" style="width: 100%;"><!--left: 17px; right: 17px;"-->
                <span class="item-label" data-app-text="dt_keikaku_nonyu"></span>
                <span class="value-label" id="dt_keikaku_nonyu" style="width: 150px;">&nbsp;</span>
                <span class="item-label" data-app-text="kurikoshiZaiko"></span>
                <span class="value-label" id="kurikoshiZaikoLabel" style="width: 120px;">&nbsp</span>
                <span class="value-label" id="searchHinmei" style="width: 500px;">&nbsp</span>
            </div>
			<table id="item-grid" data-app-operation="itemGrid">
			</table>
		</div>
	<!--	<div class="part-body">
			<table class="value-grid" style="margin-left: auto; margin-right: auto;">
				<thead>
					<tr>
						<th>
							<span class="item-label" id="nonyuYoteiGokei" data-app-text="nonyuYoteiGokei"></span>
						</th>
						<th>
							<span class="item-label" id="nonyuJissekiGokei" data-app-text="nonyuJissekiGokei"></span>
						</th>
						<th>
							<span class="item-label" data-app-text="shiyoYoteiGokei"></span>
						</th>
						<th>
							<span class="item-label" data-app-text="shiyoJissekiGokei"></span>
						</th>
						<th>
							<span class="item-label" data-app-text="choseiGokei"></span>
						</th>
						<th>
							<span class="item-label" data-app-text="kurikoshiZan"></span>
						</th>
					</tr>
				</thead>
				<tbody>
					<tr>
						<td>
							<span class="value-label" id="nonyuYoteiGokeiLabel"></span>
						</td>
						<td>
							<span class="value-label" id="nonyuJissekiGokeiLabel"></span>
						</td>
						<td>
							<span class="value-label" id="shiyoYoteiGokeiLabel"></span>
						</td>
						<td>
							<span class="value-label" id="shiyoJissekiGokeiLabel"></span>
						</td>
						<td>
							<span class="value-label" id="choseiGokeiLabel"></span>
						</td>
						<td>
							<span class="value-label" id="kurikoshiZanLabel"></span>
						</td>
					</tr>
				</tbody>
           
			</table>
		</div> -->
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
			<span data-app-text="excel"></span>
		</button>
		<button type="button" class="shiyo-button" name="shiyoexcel-button" data-app-operation="shiyoexcel">
			<span data-app-text="shiyoIchiran"></span>
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
	
	<!-- 原資材一覧ダイアログ -->
	<div class="genshizai-dialog">
	</div>
	<!-- 使用一覧ダイアログ -->
	<div class="shiyo-ichiran-dialog">
	</div>
	<!-- TODO: ここまで  -->

	<!-- 画面デザイン -- End -->
</asp:Content>
