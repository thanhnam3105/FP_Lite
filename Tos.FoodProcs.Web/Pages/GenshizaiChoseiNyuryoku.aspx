<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="GenshizaiChoseiNyuryoku.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.GenshizaiChoseiNyuryoku" %>

<asp:Content ID="Content1" ContentPlaceHolderID="IncludeContent" runat="server">
    <script src="<%=ResolveUrl("~/Resources/pages/pagedata-genshizaichoseinyuryoku." + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
    <script src="<%=ResolveUrl("~/Resources/grid/grid.locale-" + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
    <script src="<%=ResolveUrl("~/Resources/systemconst." + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
    <!-- 業務用の共通処理のロード -->
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

        
        /* excel一括出力ダイアログのスタイル */
		.excel-ikatsu-dialog
		{
			background-color: White;
			width: 550px;
		}
       
        
        .seihin-dialog
        {
            background-color: White;
            width: 550px;
        }
        
        .shikakarizan-dialog{
            background-color: White;
            width: 550px;
        }
        
        button.genshizai-button .icon
        {
            background-position: -48px -80px;
        }

        button.seihin-button .icon
        {
            background-position: -48px -80px;
        }   

        button.shikakariZan-button .icon
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
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
                changeSet = new App.ui.page.changeSet(),
                firstCol = 3,
                duplicateCol = 999,
                currentRow = 0,
                currentCol = firstCol,
                hinCodeCol = 1,
                hinNameCol = 2,
                seihinCodeCol = 17,  //製品コード
                seihinNameCol = 18,  //製品名
                seihinLotNoCol = 16; //製品ロット
            // 機能区分
            var kbnGenkaHasei = 0,
                genkaHasei = pageLangText.kinoGenkaHaseiBUshoShiyoSuru.number,
                kbnSoko = 0,
                sokoShiyo = pageLangText.kinoSokoShiyoSuru.number;


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
                        var selectedRowId = getSelectedRowId(false);
                        // 品名マスタセレクタから取得した品名コードを設定
                        grid.setCell(selectedRowId, "cd_hinmei", data);
                        // 取得した品名コードを元に、品区分や使用単位を取得する
                        setRelatedValue(selectedRowId, "cd_hinmei", "", "");

                        // 更新状態の変更セットに変更データを追加
                        var changeData = setCreatedChangeData(grid.getRowData(selectedRowId));
                        changeSet.addUpdated(selectedRowId, "cd_hinmei", data, changeData);
                        // 再チェックで背景色とメッセージのリセット
                        validateCell(selectedRowId, "cd_hinmei", grid.getCell(selectedRowId, "cd_hinmei"), hinCodeCol);
                    }
                }
            });

            // 製品一覧：品名ダイアログ
            var seihinDialog = $(".seihin-dialog");
            seihinDialog.dlg({
                url: "Dialog/HinmeiDialog.aspx",
                name: "HinmeiDialog",
                closed: function (e, data, data2) {
                    if (data == "canceled") {
                        return;
                    }
                    else {
                        var selectedRowId = getSelectedRowId(false);
                        grid.setCell(selectedRowId, "cd_seihin", data);
                        grid.setCell(selectedRowId, seihinName, data2);

                        // 更新状態の変更セットに変更データを追加
                        var changeData = setCreatedChangeData(grid.getRowData(selectedRowId));
                        changeSet.addUpdated(selectedRowId, "cd_seihin", data, changeData);
                        // 再チェックで背景色とメッセージのリセット
                        validateCell(selectedRowId, "cd_seihin", grid.getCell(selectedRowId, "cd_seihin"), seihinCodeCol);
                    }
                }
            });


            // 製品一覧：仕掛残一覧ダイアログ
            var shikakariZanDialog = $(".shikakarizan-dialog");
            shikakariZanDialog.dlg({
                url: "Dialog/ShikakariZanIchiranDialog.aspx",
                name: "shikakariZanIchiranDialog",
                closed: function (e, data, data2, data3) {
                    if (data == "canceled") {
                        return;
                    }
                    else {
                        var selectedRowId = getSelectedRowId(false);
                        grid.setCell(selectedRowId, "cd_seihin", data);
                        grid.setCell(selectedRowId, seihinName, data2);
                        grid.setCell(selectedRowId, "no_lot_seihin", data3);

                        // 更新状態の変更セットに変更データを追加
                        var changeData = setCreatedChangeData(grid.getRowData(selectedRowId));
                        changeSet.addUpdated(selectedRowId, "cd_seihin", data, changeData);
                        changeSet.addUpdated(selectedRowId, hinmeiName, data2, changeData);
                        changeSet.addUpdated(selectedRowId, "no_lot_seihin", data3, changeData);
                        // 再チェックで背景色とメッセージのリセット
                        flgValiNolot = checkNolot(selectedRowId, data3);
                        validateCell(selectedRowId, "no_lot_seihin", grid.getCell(selectedRowId, "no_lot_seihin"), seihinLotNoCol);
                    }
                }
            });
            //excel(一括出力)ダイアログ           
            var excelIkatsuDialog = $(".excel-ikatsu-dialog");
            excelIkatsuDialog.dlg({
                url: "Dialog/GenshizaichoseinyuryokuExcelIkatsuDialog.aspx",
                name: "GenshizaichoseinyuryokuExcelIkatsuDialog",
                closed: function (e, data, data2) {
                    if (data == "canceled") {
                        return;
                    }
                }
                });

            // TODO: ここまで

            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            var hinKubun, // 検索条件のコンボボックス
            // 多言語対応にしたい項目を変数にする
                hinmeiName = 'nm_hinmei_' + App.ui.page.lang,
                seihinName = 'nm_seihin_' + App.ui.page.lang,
                combChoseiRiyu,  // 明細の調整理由
                combGenkaBusho,  // 明細の原価発生部署
                //combSoko,        // 明細の倉庫
                initRiyuCode,    // 初期値用の調整理由コード
                initRiyuName,    // 初期値用の調整理由名前
                //initSokoCode,    // 初期値用の倉庫コード
                //initSokoName,    // 初期値用の倉庫名
                initGenkaCode,    // 初期値用の原価発生部署コード
                initGenkaName;    // 初期値用の原価発生部署名
            var combChoseiRiyuCopy = new Array();  // 明細の調整理由(返品除外)
            var combChoseiRiyuOrigin = new Array();  // 明細の調整理由(コピー)
            var flgValiNolot = true;    //製品ロットの値が書き替わって(いる：false いない：true)

            // TODO：ここまで

            // ダイアログ固有の変数宣言
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            var saveConfirmDialog = $(".save-confirm-dialog"),
                searchConfirmDialog = $(".search-confirm-dialog");

            // 品名一覧の引数
            var getHinKbnParam = function () {
                // 検索条件の品区分によって抽出条件を変更する
                var hinKbnParam = "";
                if (App.isUndefOrNull(searchCondition)) {
                    // 未検索時は空を設定（searchConditionがundefinedの為）
                    searchCondition = getSearchConDef();
                }

                if (searchCondition.hinKubun == pageLangText.genryoHinKbn.text) {
                    hinKbnParam = pageLangText.genryoHinDlgParam.text;
                }
                else if (searchCondition.hinKubun == pageLangText.shizaiHinKbn.text) {
                    hinKbnParam = pageLangText.shizaiHinDlgParam.text;
                }
                else if (searchCondition.hinKubun == pageLangText.jikaGenryoHinKbn.text) {
                    hinKbnParam = pageLangText.jikaGenryoHinDlgParam.text;
                }
                else {
                    hinKbnParam = pageLangText.genshizaiJikagenHinDlgParam.text;
                }
                return hinKbnParam;
            };

            // 初期表示時の検索条件を取得する
            var getSearchConDef = function () {
                return {
                    dt_chosei_hassei: App.date.startOfDay(new Date()),
                    hinKubun: null
                };
            };

            // TODO：ここまで

            //// 変数宣言 -- End

            //// コントロール定義 -- Start

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
                $("#" + idNum).removeClass("ui-state-highlight").find("td").click();

                var hinKbnParam = getHinKbnParam();
                var option = { id: 'genshizai', multiselect: false, param1: hinKbnParam };
                genshizaiDialog.draggable(true);
                genshizaiDialog.dlg("open", option);
            };

            /// 製品：品名マスタセレクタを起動する
            var showSeihinDialog = function () {
                // 行選択。セレクタ起動後に保存などのボタン押下で値がクリアされる不具合の対応。
                var idNum = grid.getGridParam("selrow");
                $("#" + idNum).removeClass("ui-state-highlight").find("td").click();

                var option = { id: 'seihin', multiselect: false, param1: pageLangText.seihinJikagenHinDlgParam.text };
                seihinDialog.draggable(true);
                seihinDialog.dlg("open", option);

            };

            /// 仕掛残一覧マスタセレクタを起動する   
            var showShikakariZanIchiranDialog = function () {

                saveEdit();
                var idNum = grid.getGridParam("selrow"),
                cd_hinmei = grid.getCell(idNum, "cd_hinmei"),
                nm_hinmei = grid.getCell(idNum, hinmeiName);
                $("#" + idNum).removeClass("ui-state-highlight").find("td").click();

                if (App.isUndefOrNull(cd_hinmei) || cd_hinmei == "") {
                    grid.setCell(idNum, "cd_hinmei", "", { background: '#ff6666' });
                    App.ui.page.notifyAlert.message(
                    App.str.format(pageLangText.noInputHinmeiCode.text, pageLangText.cd_hinmei.text),
                        idNum + "_" + hinCodeCol
                    )
                    return;
                }



                var option = { id: 'ShikakariZanIchiranDialog'
                              , multiselect: false
                              , param1: cd_hinmei
                              , param2: nm_hinmei
                };

                shikakariZanDialog.draggable(true);
                shikakariZanDialog.dlg("open", option);
            };

            var showGenshizaichoseinyuryokuExcelIkatsuDialog = function () {
                // ダイアログ：原資材一覧のドラッグを可能とする
                excelIkatsuDialog.draggable(true);
                // ダイアログ：原資材一覧(品名マスタ検索を原料と資材で絞る)を開く
                var option = {
                                id: 'excelIkatsu'
                                , multiselect: false
                                , param1: pageLangText.genshizaiJikagenHinDlgParam.text
                };
                excelIkatsuDialog.dlg("open",option);
            };
            /// <summary>ダイアログを開きます。</summary>
            var showSaveConfirmDialog = function () {
                // 対象行が存在するか確認
                //var selectedRowId = getSelectedRowId(),
                //    position = "after";
                //if (App.isUndefOrNull(selectedRowId)) {
                //    return;
                //}
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
            var datePickerFormat = pageLangText.dateFormatUS.text;
            var newDateFormat = pageLangText.dateNewFormatUS.text;
            if (App.ui.page.langCountry !== 'en-US') {
                datePickerFormat = pageLangText.dateFormat.text;
                newDateFormat = pageLangText.dateNewFormat.text;
            }

            // TODO：画面の仕様に応じて以下の datepicker の設定を変更してください。
            $("#condition-date").on("keyup", App.data.addSlashForDateString);
            $("#condition-date").datepicker({ dateFormat: datePickerFormat });
            // 有効範囲：1970/1/1～システム日付より1年後
            $("#condition-date").datepicker("option", 'minDate', new Date(1970, 1 - 1, 1));
            $("#condition-date").datepicker("option", 'maxDate', "+1y");
            // TODO：ここまで

            // グリッドコントロール固有のコントロール定義
            grid.jqGrid({
                // TODO：画面の仕様に応じて以下の列名の定義を変更してください。
                colNames: [
                    pageLangText.cd_hinmei.text + pageLangText.requiredMark.text,
                    pageLangText.nm_hinmei.text,
                    pageLangText.kbn_hin.text,
                    pageLangText.nm_kbn_hin.text,
                    pageLangText.nm_nisugata.text,
                    pageLangText.tani_shiyo.text,
                    pageLangText.su_chosei.text + pageLangText.requiredMark.text,
                    pageLangText.su_chosei.text,
                    pageLangText.cd_riyu.text,
                    pageLangText.nm_riyu.text + pageLangText.requiredMark.text,
                    pageLangText.biko.text,
                    pageLangText.genka_busho.text,
                    pageLangText.genka_busho.text,
                    pageLangText.cd_soko.text,
                    pageLangText.cd_soko.text,
                    pageLangText.no_lot_seihin.text,
                    pageLangText.cd_seihin.text,
                    pageLangText.nm_seihin.text,
                    pageLangText.cd_update.text,
                    pageLangText.nm_update.text,
                    pageLangText.dt_update.text,
                    pageLangText.flg_mishiyo.text,
                    pageLangText.no_seq.text,
                    pageLangText.anbun_no_seq,

                    // TOsVN - 20089 - START -----------------------------
                    "hidden",
                    "hidden",
                    "hidden",
                    "hidden",
                    "hidden",
                    "hidden",
                    // --------------- END -------------------------------
                ],
                // TODO：ここまで
                // TODO：画面の仕様に応じて以下の列モデルの定義を変更してください。
                colModel: [
                    { name: 'cd_hinmei', width: pageLangText.cd_hinmei_width.number, editable: true, sorttype: "text" },
                    { name: hinmeiName, width: pageLangText.nm_hinmei_width.number, editable: false, sorttype: "text" },
                    { name: 'kbn_hin', width: 0, hidden: true, hidedlg: true },
                    { name: 'nm_kbn_hin', width: pageLangText.nm_kbn_hin_width.number, editable: false, sorttype: "text", align: "center" },
                    { name: 'nm_nisugata', width: pageLangText.nm_nisugata_width.number, editable: false, sorttype: "text" },
                    { name: 'tani_shiyo', width: pageLangText.tani_shiyo_width.number, editable: false, sorttype: "text" },
                    { name: 'su_chosei', width: pageLangText.su_chosei_width.number, editable: true, align: "right", sorttype: "float",
                        formatter: 'number',
                        formatoptions: {
                            decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 3, defaultValue: "0"
                        }
                    },                   
                    { name: 'su_chosei_initial', width: pageLangText.su_chosei_width.number, hidden: true, hidedlg: true,
                        formatter: 'number',
                        formatoptions: {
                            decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 3, defaultValue: "0"
                        }
                    },
                    { name: 'cd_riyu', width: 0, hidden: true, hidedlg: true },                    
                    { name: 'nm_riyu', width: pageLangText.nm_riyu_width.number, editable: true, sorttype: "text", edittype: 'select',
                        editoptions: {
                            value: function () {
                                // グリッド内のドロップダウンの生成：調整理由
                                return grid.prepareDropdown(combChoseiRiyu, "nm_riyu", "cd_riyu");
                            }
                        }
                    },                   
                    { name: 'biko', width: pageLangText.biko_width.number, editable: true, sorttype: "text" },                    
                    { name: 'cd_genka_center', width: 0, hidden: true, hidedlg: true },                    
                    { name: 'nm_genka_center', width: pageLangText.nm_genka_width.number, editable: true, sorttype: "text", edittype: 'select',
                        editoptions: {
                            value: function () {
                                if (genkaHasei == pageLangText.kinoGenkaHaseiBUshoShiyoSuru.number) {
                                    // グリッド内のドロップダウンの生成：原価発生部署
                                    return grid.prepareDropdown(combGenkaBusho, "nm_genka_center", "cd_genka_center");
                                }
                            }
                        }
                    },                    
                    { name: 'cd_soko', width: 0, hidden: true, hidedlg: true },
                    //{ name: 'nm_soko', width: pageLangText.nm_soko_width.number, editable: true, hidedlg: false, sorttype: "text", edittype: 'select',
                        //editoptions: {
                            //value: function () {
                                //if (sokoShiyo == pageLangText.kinoGenkaHaseiBUshoShiyoSuru.number) {
                                    // グリッド内のドロップダウンの生成：倉庫
                                    //return grid.prepareDropdown(combSoko, "nm_soko", "cd_soko");
                                //}
                            //}
                        //}
                    //},
                    { name: 'nm_soko', width: pageLangText.cd_hinmei_width.number, editable: false, sorttype: "text" },

                    // ■仕掛残計上機能OFF対応(機能ONは属性「hidden」と「hidedlg」をfalseにするか、除去して下さい)
                    { name: 'no_lot_seihin', width: 110, editable: true, align: 'left', sorttype: "text", hidden: true, hidedlg: true },
                    { name: 'cd_seihin', width: pageLangText.cd_seihin_width.number, editable: true, sorttype: "text" },
                    { name: seihinName, width: pageLangText.nm_seihin_width.number, editable: false, sorttype: "text" },
                    { name: 'cd_update', width: 0, hidden: true, hidedlg: true },
                    { name: 'nm_update', width: pageLangText.nm_update_width.number, editable: false, sorttype: "text" },
                    { name: 'dt_update', width: pageLangText.dt_update_width.number, sorttype: "text", align: "center",
                        formatter: "date",
                        formatoptions: {
                            srcformat: newDateFormat, newformat: newDateFormat
                        }
                    },
                    { name: 'flg_mishiyo', width: 0, hidden: true, hidedlg: true },
                    { name: 'no_seq', width: 0, hidden: true, hidedlg: true },
                    { name: 'anbun_no_seq', width: 0, hidden: true, hidedlg: true },

                    // TOsVN - 20089 - START -----------------------------
                    {
                        name: 'su_chosei_old', width: pageLangText.su_chosei_width.number, editable: false, hidden: true, hidedlg: true,
                        formatter: 'number',
                        formatoptions: {
                            decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 3, defaultValue: "0"
                        }
                    },
                    { name: 'cd_riyu_old', width: 0, hidden: true, hidedlg: true },
                    { name: 'nm_riyu_text', width: 0, sorttype: "text", hidden: true, hidedlg: true },
                    { name: 'biko_old', width: pageLangText.biko_width.number, hidden: true, hidedlg: true, sorttype: "text" },
                    { name: 'cd_genka_center_old', width: 0, hidden: true, hidedlg: true },
                    { name: 'nm_genka_center_text', width: 0, sorttype: "text", hidden: true, hidedlg: true },
                    // --------------- END -------------------------------
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
                    var ids = grid.jqGrid('getDataIDs'),
                        criteria = $(".search-criteria").toJSON();

                    for (var i = 0; i < ids.length; i++) {
                        var id = ids[i];
                        // TODO : ここから
                        // 検索後の値がマイナスの場合、文字色を赤くする
                        if (0 > parseFloat(grid.getCell(id, "su_chosei"))) {
                            grid.setCell(id, "su_chosei", '', { color: '#ff6666' });
                        }

                        //理由コードが返品・返品取消の場合、レコードを変更不可にする
                        var cd_riyu_select = grid.getCell(id, 'cd_riyu');
                        //if (cd_riyu_select == pageLangText.kbn_zaiko_chosei_henpin.text) {
                        if (cd_riyu_select == pageLangText.kbn_zaiko_chosei_henpin.text || cd_riyu_select == pageLangText.kbn_zaiko_chosei_henpintorikeshi.text) {
                            grid.jqGrid('setCell', id, 'cd_hinmei', '', 'not-editable-cell');
                            grid.jqGrid('setCell', id, 'nm_hinmei', '', 'not-editable-cell');
                            grid.jqGrid('setCell', id, 'su_chosei', '', 'not-editable-cell');
                            grid.jqGrid('setCell', id, 'cd_riyu', '', 'not-editable-cell');
                            grid.jqGrid('setCell', id, 'nm_riyu', '', 'not-editable-cell');
                            grid.jqGrid('setCell', id, 'biko', '', 'not-editable-cell');
                            grid.jqGrid('setCell', id, 'cd_genka_center', '', 'not-editable-cell');
                            grid.jqGrid('setCell', id, 'nm_genka_center', '', 'not-editable-cell');
                            grid.jqGrid('setCell', id, 'cd_soko', '', 'not-editable-cell');
                            grid.jqGrid('setCell', id, 'nm_soko', '', 'not-editable-cell');
                            grid.jqGrid('setCell', id, 'cd_seihin', '', 'not-editable-cell');
                            grid.jqGrid('setCell', id, seihinName, '', 'not-editable-cell');
                        }
                        //理由コードが返品・返品取消以外の場合、製品コード・原資材コードを変更不可にする
                        else {
                            grid.jqGrid('setCell', id, 'cd_hinmei', '', 'not-editable-cell');
                            grid.jqGrid('setCell', id, 'nm_hinmei', '', 'not-editable-cell');
                            grid.jqGrid('setCell', id, 'cd_seihin', '', 'not-editable-cell');
                            grid.jqGrid('setCell', id, seihinName, '', 'not-editable-cell');
                        }

                        // TODO：ここまで
                        // TOsVN - 20089 trung.nq - add su_chosei, cd_riyu, biko, cd_genka_center old value
                        // --------------- START -----------------------
                        grid.jqGrid('setCell', id, 'su_chosei_old', grid.getCell(id, "su_chosei"), 'not-editable-cell');
                        grid.jqGrid('setCell', id, 'cd_riyu_old', grid.getCell(id, "cd_riyu"), 'not-editable-cell');
                        grid.jqGrid('setCell', id, 'biko_old', grid.getCell(id, "biko"), 'not-editable-cell');
                        grid.jqGrid('setCell', id, 'cd_genka_center_old', grid.getCell(id, "cd_genka_center"), 'not-editable-cell');
                        // ---------------- END ------------------------
                    }
                    //返品除外したコンボボックスセット
                    combChoseiRiyu = combChoseiRiyuCopy;

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
                    //製品ロット№の存在チェック
                    if (cellName == "no_lot_seihin") {
                        flgValiNolot = true;
                        grid.setCell(selectedRowId, iCol, value, { background: 'none' });
                        flgValiNolot = checkNolot(selectedRowId, value);

                    }
                    // セルバリデーション
                    validateCell(selectedRowId, cellName, value, iCol);
                },
                afterSaveCell: function (selectedRowId, cellName, value, iRow, iCol) {
                    if (cellName == "nm_genka_center" && genkaHasei != pageLangText.kinoGenkaHaseiBUshoShiyoSuru.number) {
                        return;
                    }
                    if (cellName == "nm_soko" && sokoShiyo != pageLangText.kinoGenkaHaseiBUshoShiyoSuru.number) {
                        return;
                    }

                    // 関連項目の設定
                    setRelatedValue(selectedRowId, cellName, value, iCol);



                    // 変更データの変数設定
                    var changeData;
                    // シーケンス番号が存在すれば更新、しなければ新規
                    // 更新
                    if (grid.jqGrid('getCell', selectedRowId, 'no_seq')) {
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
                    // 権限「Admin」「Operator」のときのみ、セレクタを起動する
                    if (App.ui.page.user.Roles[0] == pageLangText.admin.text
                        || App.ui.page.user.Roles[0] == pageLangText.operator.text) {

                        //理由コードが返品の場合、利用不可にする
                        //var cd_riyu_select = grid.getCell(rowid, 'cd_riyu');
                        //if (cd_riyu_select == pageLangText.kbn_zaiko_chosei_henpin.text) {
                        //既存データ行の場合、利用不可にする
                        if (grid.jqGrid('getCell', rowid, 'no_seq')) {
                            // 対象項目が原資材・製品の場合
                            if (selectCol === hinCodeCol || selectCol === hinNameCol || selectCol === seihinCodeCol || selectCol === seihinNameCol) {
                                //エラーメッセージ(MS0831)の表示
                                App.ui.page.notifyAlert.message(pageLangText.noDisplayDialog.text).show();
                            }
                        } else {
                            // 原資材一覧（品名セレクタ起動）
                            if (selectCol === hinCodeCol || selectCol === hinNameCol) {
                                showGenshizaiDialog();
                            }

                            // 製品一覧（品名セレクタ起動）
                            if (selectCol === seihinCodeCol || selectCol === seihinNameCol) {
                                showSeihinDialog();
                            }

                            // 仕掛残一覧（製造実績セレクタ起動）
                            if (selectCol === seihinLotNoCol) {
                                showShikakariZanIchiranDialog();

                            }
                        }
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
                // 調整数の文字色
                var target = "su_chosei",
                    changeData;
                if (cellName === "su_chosei") {
                    // 負の数の場合：文字色を赤色に変更
                    if (0 > parseFloat(grid.getCell(selectedRowId, target))) {
                        grid.setCell(selectedRowId, target, '', { color: '#ff6666' });
                    }
                    else {
                        // 正の数の場合：文字色を黒に変更
                        grid.setCell(selectedRowId, target, '', { color: '#000000' });
                    }
                }
                // コンボボックスのコードの設定
                // 理由コード、原価センターコード、倉庫コード
                //if (cellName === "nm_riyu" || cellName === "nm_genka_center" || cellName === "nm_soko") {
                if (cellName === "nm_riyu" || cellName === "nm_genka_center") {
                    var comboCodeName = "cd_" + cellName.substr(3);
                    //grid.setCell(selectedRowId, "cd_riyu", value);
                    grid.setCell(selectedRowId, comboCodeName, value);
                    // 更新状態の変更セットに変更データを追加
                    changeData = setUpdatedChangeData(grid.getRowData(selectedRowId));
                    //changeSet.addUpdated(selectedRowId, "cd_riyu", value, changeData);
                    changeSet.addUpdated(selectedRowId, comboCodeName, value, changeData);
                    // セルバリデーション
                    //validateCell(selectedRowId, "cd_riyu", value, iCol - 1);
                }

                if (cellName == "su_chosei") {
                    changeSet.addUpdated(selectedRowId, "su_shiyo", value, changeData);
                }

                // コードから名称を取得する：原資材名または製品名
                if (cellName === "cd_hinmei" || cellName === "cd_seihin") {
                    var serviceUrl,
			            elementCode,
			            elementName1,
			            elementName2,
			            elementName3,
			            elementName4,
			            nameCellName1,
			            nameCellName2,
			            nameCellName3,
			            nameCellName4,
			            codeName,
			            lang = App.ui.page.lang;
                    switch (cellName) {
                        case "cd_seihin":
                            serviceUrl = "../Services/FoodProcsService.svc/ma_hinmei()?$filter=cd_hinmei eq '" + grid.getCell(selectedRowId, "cd_seihin")
                                + "' and ( kbn_hin eq " + pageLangText.seihinHinKbn.text
                                + "  or kbn_hin eq " + pageLangText.jikaGenryoHinKbn.text
                                + " ) and flg_mishiyo eq " + pageLangText.shiyoMishiyoFlg.text + "&$top=1";
                            elementCode = "cd_hinmei";
                            elementName1 = "nm_hinmei_" + lang;
                            nameCellName1 = seihinName;
                            codeName;
                            break;
                        case "cd_hinmei":
                            // 検索条件の品区分によって抽出条件を変更する
                            var strWhere = "";
                            if (App.isUndefOrNull(searchCondition)) {
                                // 未検索時は空を設定（searchConditionがundefinedの為）
                                searchCondition = getSearchConDef();
                            }
                            if (!App.isUndefOrNull(searchCondition.hinKubun) && searchCondition.hinKubun.length > 0) {
                                strWhere = "kbn_hin eq " + searchCondition.hinKubun;
                            }
                            else {
                                strWhere = "(kbn_hin eq " + pageLangText.genryoHinKbn.text + " or kbn_hin eq " + pageLangText.shizaiHinKbn.text + " or kbn_hin eq " + pageLangText.jikaGenryoHinKbn.text + ")";
                            }

                            serviceUrl = "../Services/FoodProcsService.svc/vw_ma_hinmei_04?$filter=cd_hinmei eq '"
                                + grid.getCell(selectedRowId, "cd_hinmei") + "' and " + strWhere
                                + " and flg_mishiyo_hin eq " + pageLangText.shiyoMishiyoFlg.text + "&$top=1";
                            elementCode = "cd_hinmei";
                            elementName1 = "nm_hinmei_" + lang;
                            elementName2 = "nm_kbn_hin";
                            elementName3 = "nm_nisugata";
                            elementName4 = "nm_tani";
                            nameCellName1 = hinmeiName;
                            nameCellName2 = "nm_kbn_hin";
                            nameCellName3 = "nm_nisugata";
                            nameCellName4 = "tani_shiyo";
                            codeName;
                            break;
                        default:
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
                            grid.setCell(selectedRowId, nameCellName1, codeName[0][elementName1]);
                            grid.setCell(selectedRowId, nameCellName2, codeName[0][elementName2]);
                            grid.setCell(selectedRowId, nameCellName3, codeName[0][elementName3]);
                            grid.setCell(selectedRowId, nameCellName4, codeName[0][elementName4]);

                            // 品名コードの場合：倉庫の初期値
                            // 右は下に変更// 品名マスタ．ロケーションコードより、ロケーションマスタ．倉庫コードを設定する。
                            // 品名マスタ．荷受場所コードより、倉庫マスタ．倉庫コードを設定する。
                            if (cellName === "cd_hinmei") {
                                //var sokoCode = codeName[0]["cd_soko"];
                                //if (!App.isUndefOrNull(sokoCode) && sokoCode.length > 0) {
                                //   grid.setCell(selectedRowId, "cd_soko", codeName[0]["cd_soko"]);
                                //   grid.setCell(selectedRowId, "nm_soko", codeName[0]["nm_soko"]);
                                var niukeCode = codeName[0]["cd_niuke_basho"];
                                if (!App.isUndefOrNull(niukeCode) && niukeCode.length > 0) {
                                    // 明細のリストボックスを変更
                                    //var sokoIndex = grid.getColumnIndexByName("nm_soko"),
                                        //choseiIndex = grid.getColumnIndexByName("su_chosei"),
                                        //$sokoCol, tmpVal;
                                    //grid.setCell(selectedRowId, "cd_soko", niukeCode);
                                    //grid.editCell(currentRow, sokoIndex, true);
                                    //$sokoCol = $("#item-grid #" + selectedRowId + " select[name='nm_soko']");
                                    //$sokoCol.val(niukeCode);
                                    //tmpVal = $sokoCol.val();
                                    //if (niukeCode !== tmpVal) {
                                        //$sokoCol.val(initSokoCode);
                                        //grid.setCell(selectedRowId, "cd_soko", initSokoCode);
                                    //}
                                    //grid.editCell(currentRow, choseiIndex, true);

                                    var choseiIndex = grid.getColumnIndexByName("su_chosei");
                                    grid.editCell(currentRow, choseiIndex, true);

                                }
                                //else {
                                    //grid.setCell(selectedRowId, "cd_soko", initSokoCode);
                                    //grid.setCell(selectedRowId, "nm_soko", initSokoName);
                                //}

                                // 倉庫情報の取得
                                var sokoInfoResult = getSokoInfo(codeName[0]["cd_hinmei"]);

                                // 取得した倉庫コードと倉庫名を画面に設定
                                grid.setCell(selectedRowId, "cd_soko", sokoInfoResult.sokoCode);
                                grid.setCell(selectedRowId, "nm_soko", sokoInfoResult.sokoName);

                                // 変更情報に倉庫コードを設定する
                                changeSet.addUpdated(selectedRowId, "cd_soko", sokoInfoResult.sokoCode, changeData);

                            }
                        }
                        else {
                            grid.setCell(selectedRowId, nameCellName1, null);
                            grid.setCell(selectedRowId, nameCellName2, null);
                            grid.setCell(selectedRowId, nameCellName3, null);
                            grid.setCell(selectedRowId, nameCellName4, null);
                            grid.setCell(selectedRowId, "cd_soko", null);
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
                //製品ロット№から取得する
                if (cellName == "no_lot_seihin") {

                    var url = "../Services/FoodProcsService.svc/vw_tr_keikaku_seihin_exists?$filter=cd_hinmei eq '"
                                    + grid.getCell(selectedRowId, "cd_hinmei") + "'"
                                    + " and  no_lot_seihin eq '" + grid.getCell(selectedRowId, "no_lot_seihin") + "'"
                                    + " and flg_mishiyo eq " + pageLangText.shiyoMishiyoFlg.text,
                        item;
                    App.deferred.parallel({
                        // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                        item: App.ajax.webgetSync(url)
                        // TODO: ここまで
                    }).done(function (result) {
                        // TODO: 画面の仕様に応じて以下のサービス呼び出し成功時の処理を変更してください。
                        var row = grid.getRowData(selectedRowId);
                        item = result.successes.item.d;
                        if (item.length > 0) {
                            grid.setCell(selectedRowId, 'cd_seihin', item[0]['cd_hinmei']);
                            grid.setCell(selectedRowId, seihinName, item[0][hinmeiName]);
                        } else {
                            grid.setCell(selectedRowId, 'cd_seihin', null);
                            grid.setCell(selectedRowId, seihinName, null);
                        }
                    }).fail(function (result) {
                        App.ui.page.notifyAlert.message(result.messages).show();
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

            //// コントロール定義 -- End

            //// 操作制御定義 -- Start

            // 操作制御定義を定義します。
            App.ui.pagedata.operation.applySetting(App.ui.page.user.Roles[0], App.ui.page.lang);

            //// 操作制御定義 -- End

            //// 事前データロード -- Start 

            // 画面アーキテクチャ共通の事前データロード
            var loading;

            App.deferred.parallel({
                // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                // ローディング
                loading: App.ui.loading.show(pageLangText.nowProgressing.text),
                // 品区分
                hinKubun: App.ajax.webget("../Services/FoodProcsService.svc/ma_kbn_hin?$filter=kbn_hin eq "
                    + pageLangText.genryoHinKbn.text + " or kbn_hin eq " + pageLangText.shizaiHinKbn.text
                    + " or kbn_hin eq " + pageLangText.jikaGenryoHinKbn.text + "&$orderby=kbn_hin"),
                // 明細の調整理由
//                combChoseiRiyu: App.ajax.webget("../Services/FoodProcsService.svc/ma_riyu?$filter=kbn_bunrui_riyu eq "
//                    + pageLangText.choseiRiyuKbn.text + "&$orderby=cd_riyu"),
                combChoseiRiyu: App.ajax.webget("../Services/FoodProcsService.svc/ma_riyu?$filter=kbn_bunrui_riyu eq " + pageLangText.choseiRiyuKbn.text
                     //+ " and cd_riyu ne '" + pageLangText.kbn_zaiko_chosei_henpin.text + "' &$orderby=cd_riyu"),
                     + " and cd_riyu ne '" + pageLangText.kbn_zaiko_chosei_henpin.text
                     + "' and cd_riyu ne '" + pageLangText.kbn_zaiko_chosei_henpintorikeshi.text + "' &$orderby=cd_riyu"),
                // 明細の原価発生部署
                combGenkaBusho: App.ajax.webget("../Services/FoodProcsService.svc/vw_ma_genka_center_01?$filter=flg_mishiyo eq "
                    + pageLangText.falseFlg.text + "&$orderby=cd_genka_center")
                // 明細の倉庫
                //combSoko: App.ajax.webget("../Services/FoodProcsService.svc/ma_soko?$filter=flg_mishiyo eq "
                    //+ pageLangText.falseFlg.text + "&$orderby=cd_soko")
                // TODO: ここまで
            }).done(function (result) {
                // TODO: 画面の仕様に応じて以下のサービス呼び出し成功時の処理を変更してください。
                hinKubun = result.successes.hinKubun.d;
                combChoseiRiyu = result.successes.combChoseiRiyu.d;

                combChoseiRiyuOrigin = combChoseiRiyu;
                for (var i = 0; i < combChoseiRiyu.length; i++) {
                    //返品・返品取消は除外
                    //if (combChoseiRiyu[i].cd_riyu == pageLangText.kbn_zaiko_chosei_henpin.text) {
                    if (combChoseiRiyu[i].cd_riyu == pageLangText.kbn_zaiko_chosei_henpin.text || combChoseiRiyu[i].cd_riyu == pageLangText.kbn_zaiko_chosei_henpintorikeshi.text) {
                        //
                    }
                    else {
                        combChoseiRiyuCopy.push(combChoseiRiyu[i]);
                    }
                }
                combGenkaBusho = result.successes.combGenkaBusho.d;
                //combSoko = result.successes.combSoko.d;
                if (combChoseiRiyu.length > 0) {
                    // 初期値用の調整理由を設定
                    initRiyuCode = combChoseiRiyu[0].cd_riyu;
                    initRiyuName = combChoseiRiyu[0].nm_riyu;
                }
                //if (combSoko.length > 0) {
                    // 初期値用の倉庫を設定
                    //initSokoCode = combSoko[0].cd_soko;
                    //initSokoName = combSoko[0].nm_soko;
                //}
                if (combGenkaBusho.length > 0) {
                    // 初期値用の原価発生部署を設定
                    // initGenkaCode = combGenkaBusho[0].cd_genka_center;
                    // initGenkaName = combGenkaBusho[0].nm_genka_center;
                    var genkaDefault = app_util.prototype.getDefaultGenkaBusho(combGenkaBusho);
                    initGenkaCode = genkaDefault.cd_genka_center;
                    initGenkaName = genkaDefault.nm_genka_center;
                }
                // delete combChoseiRiyu[1];
                // 検索用ドロップダウンの設定
                var target = $("#condition-hinKubun")
                App.ui.appendOptions(target, "kbn_hin", "nm_kbn_hin", hinKubun, true);

                // 当日日付を挿入
                $("#condition-date").datepicker("setDate", new Date());

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

            /// <summary>原価発生部署使用区分の取得</summary>
            var getKbnGenkaHaseiBusho = function () {
                App.deferred.parallel({
                    kbnGenkaHasei: App.ajax.webgetSync("../Services/FoodProcsService.svc/cn_kino_sentaku()?$filter=kbn_kino eq "
                    	+ pageLangText.kinoGenkaHaseiBUshoShiyoKbn.number)
                }).done(function (result) {
                    kbnGenkaHasei = result.successes.kbnGenkaHasei.d;
                    if (kbnGenkaHasei.length > 0) {
                        genkaHasei = kbnGenkaHasei[0].kbn_kino_naiyo;
                    }
                    else {
                        genkaHasei = "";
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
            };
            getKbnGenkaHaseiBusho();
            if (genkaHasei != pageLangText.kinoGenkaHaseiBUshoShiyoSuru.number) {
                // 「原価発生部署使用区分.する」以外の場合、原価発生部署は非表示にする
                grid.jqGrid('hideCol', "nm_genka_center");
                grid.setColProp('nm_genka_center', { hidedlg: true });
            }

            /// <summary>倉庫使用区分の取得</summary>
            var getKbnSokoBusho = function () {
                App.deferred.parallel({
                    kbnSoko: App.ajax.webgetSync("../Services/FoodProcsService.svc/cn_kino_sentaku()?$filter=kbn_kino eq "
                    	+ pageLangText.kinoSokoShiyoKbn.number)
                }).done(function (result) {
                    kbnSoko = result.successes.kbnSoko.d;
                    if (kbnSoko.length > 0) {
                        sokoShiyo = kbnSoko[0].kbn_kino_naiyo;
                    }
                    else {
                        sokoShiyo = "";
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
            };
            getKbnSokoBusho();
            if (sokoShiyo != pageLangText.kinoGenkaHaseiBUshoShiyoSuru.number) {
                // 「倉庫使用区分の取得.する」以外の場合、倉庫は非表示にする
                grid.jqGrid('hideCol', "nm_soko");
                grid.setColProp('nm_soko', { hidedlg: true });
            }

            /// <summary>品名コードに紐づく倉庫情報の取得</summary>
            var getSokoInfo = function (cdHinmei) {

                // 倉庫コード、倉庫名格納用の連想配列を定義
                var sokoInfoResult = { sokoCode: "", sokoName: "" };

                // 倉庫情報を取得する
                App.deferred.parallel({
                    sokoInfo: App.ajax.webgetSync("../Services/FoodProcsService.svc/vw_soko_info?$filter=cd_hinmei eq '" + cdHinmei + "'")
                }).done(function (result) {

                    // 取得結果を変数に設定
                    var sokoInfo = result.successes.sokoInfo.d;

                    // 取得できた場合は倉庫コードと倉庫名を連想配列に設定
                    if (sokoInfo.length > 0) {
                        sokoInfoResult.sokoCode = sokoInfo[0].cd_soko;
                        sokoInfoResult.sokoName = sokoInfo[0].nm_soko;
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

                return sokoInfoResult;
            }

            //// 事前データロード -- End

            //// 検索処理 -- Start

            // 画面アーキテクチャ共通の検索処理

            /// <summary>クエリオブジェクトの設定</summary>
            var query = function () {
                var query = {
                    // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                    url: "../Services/FoodProcsService.svc/vw_tr_chosei_01",
                    // TODO: ここまで
                    filter: createFilter(),
                    // TODO: 画面の仕様に応じて以下のソート条件を変更してください。
                    orderby: "cd_hinmei",
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
                    filters = [];
                searchCondition = criteria;
                // TODO: 画面の仕様に応じて以下のフィルター条件を変更してください。
                if (!App.isUndefOrNull(criteria.dt_chosei_hassei)) {
                    filters.push("dt_hizuke eq DateTime'" + App.data.getDateTimeStringForQueryNoUtc(criteria.dt_chosei_hassei) + "'");
                }
                if (!App.isUndefOrNull(criteria.hinKubun) && criteria.hinKubun.length > 0) {
                    filters.push("kbn_hin eq " + criteria.hinKubun);
                }
                else {
                    // 品区分に選択がない場合、原料と資材と自家原料を取得
                    filters.push("(kbn_hin eq " + pageLangText.genryoHinKbn.text
                            + " or kbn_hin eq " + pageLangText.shizaiHinKbn.text
                            + " or kbn_hin eq " + pageLangText.jikaGenryoHinKbn.text + ")");
                }
                filters.push("kbn_bunrui_riyu eq " + pageLangText.choseiRiyuKbn.text);
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
                    // グリッドの先頭行選択
                    var idNum = grid.getGridParam("selrow");
                    if (idNum == null) {
                        $("#1 > td").click();
                    }
                    else {
                        $("#" + idNum).removeClass("ui-state-highlight").find("td").click();
                    }
                    // 検索条件を閉じる
                    closeCriteria();
                    $(".ui-jqgrid-hdiv").scrollLeft(0); // 明細のスクロール位置をリセット
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
                //1コンボボックスのリセット
                combChoseiRiyu = combChoseiRiyuOrigin;

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

                // TODO：検索結果が上限数を超えていた場合
                if (parseInt(result.d.__count) > querySetting.top) {
                    App.ui.page.notifyAlert.message(pageLangText.limitOver.text).show();
                }
                // TODO：上限数チェック：ここまで

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
                // 検索時の調整発生日。未検索時は現在日付。
                if (App.isUndefOrNull(searchCondition)) {
                    searchCondition = getSearchConDef();
                }

                var addData = {
                    "dt_hizuke": App.data.getDateTimeStringForQueryNoUtc(App.date.localDate(searchCondition.dt_chosei_hassei)),
                    "kbn_hin": "",
                    "nm_kbn_hin": "",
                    "cd_hinmei": "",
                    "nm_hinmei": "",
                    "nm_nisugata": "",
                    "tani_shiyo": "",
                    "su_chosei": 0.000,
                    "cd_riyu": initRiyuCode,
                    "nm_riyu": initRiyuName,
                    "biko": "",
                    "cd_genka_center": initGenkaCode,
                    "nm_genka_center": initGenkaName,
                    //"cd_soko": initSokoCode,
                    //"nm_soko": initSokoName,
                    "cd_soko": "",
                    "nm_soko": "",
                    "cd_soko": "",
                    "nm_soko": "",
                    "cd_seihin": "",
                    "nm_seihin": "",
                    "dt_update": new Date(),
                    "nm_update": App.ui.page.user.Name,
                    "cd_update": App.ui.page.user.Code,
                    "no_lot_seihin": "",
                    "kbn_shiyo_jisseki_anbun": pageLangText.shiyoJissekiAnbunKubunChosei.text,
                    "no_lot": "",
                    "no_seq_shiyo_yojitsu_anbun": "",
                    "su_shiyo": 0.000
                };
                // TODO: ここまで

                return addData;
            };

            /// <summary>追加状態の変更セットに追加する変更データの設定を行います。</summary>
            /// <param name="newRow">新規行データ</param>
            var setCreatedChangeData = function (newRow) {
                // TODO: 画面の仕様に応じて以下の項目を変更してください。

                // 検索時の調整発生日。未検索時は現在日付。
                if (App.isUndefOrNull(searchCondition)) {
                    searchCondition = getSearchConDef();
                }

                var changeData = {
                    //"dt_hizuke": App.date.startOfDay(searchCondition.dt_chosei_hassei),
                    "dt_hizuke": App.data.getDateTimeStringForQueryNoUtc(App.date.localDate(searchCondition.dt_chosei_hassei)),
                    "kbn_hin": newRow.kbn_hin,
                    "nm_kbn_hin": newRow.nm_kbn_hin,
                    "cd_hinmei": newRow.cd_hinmei,
                    "cd_riyu": newRow.cd_riyu,                    
                    "su_chosei": newRow.su_chosei,                   
                    "biko": newRow.biko,                    
                    "cd_genka_center": newRow.cd_genka_center,                   
                    "cd_soko": newRow.cd_soko,
                    "cd_seihin": newRow.cd_seihin,
                    "no_seq": newRow.no_seq,
                    "dt_update": new Date(),
                    "cd_update": App.ui.page.user.Code,
                    "no_lot_seihin": newRow.no_lot_seihin,
                    "kbn_shiyo_jisseki_anbun": pageLangText.shiyoJissekiAnbunKubunChosei.text,
                    "no_lot": newRow.no_seq,
                    "no_seq_shiyo_yojitsu_anbun": newRow.anbun_no_seq,
                    "su_shiyo": newRow.su_chosei,

                    "cd_riyu_old": newRow.cd_riyu_old,
                    "nm_riyu_text": newRow.nm_riyu,
                    "su_chosei_old": newRow.su_chosei_old,
                    "biko_old": newRow.biko_old,
                    "cd_genka_center_old": newRow.cd_genka_center_old,
                    "nm_genka_center_text": newRow.nm_genka_center

                };
                // TODO: ここまで

                return changeData;
            };
            /// <summary>更新状態の変更セットに追加する変更データの設定を行います。</summary>
            /// <param name="row">選択行</param>
            var setUpdatedChangeData = function (row) {
                // TODO: 画面の仕様に応じて以下の項目を変更してください。

                // 検索時の調整発生日。未検索時は現在日付。
                if (App.isUndefOrNull(searchCondition)) {
                    searchCondition = getSearchConDef();
                }

                var changeData = {
                    //"dt_hizuke": App.date.startOfDay(searchCondition.dt_chosei_hassei),
                    "dt_hizuke": App.data.getDateTimeStringForQueryNoUtc(App.date.localDate(searchCondition.dt_chosei_hassei)),
                    "kbn_hin": row.kbn_hin,  //getHinKubun(),
                    "nm_kbn_hin": row.nm_kbn_hin,
                    "cd_hinmei": row.cd_hinmei,
                    "cd_riyu": row.cd_riyu,
                    "su_chosei": row.su_chosei,
                    "biko": row.biko,
                    "cd_genka_center": row.cd_genka_center,
                    "cd_soko": row.cd_soko,
                    "cd_seihin": row.cd_seihin,
                    "no_seq": row.no_seq,
                    "dt_update": new Date(),
                    "cd_update": App.ui.page.user.Code,
                    "no_lot_seihin": row.no_lot_seihin,
                    "kbn_shiyo_jisseki_anbun": pageLangText.shiyoJissekiAnbunKubunChosei.text,
                    "no_lot": row.no_seq,
                    "no_seq_shiyo_yojitsu_anbun": row.anbun_no_seq,
                    "su_shiyo": row.su_chosei,

                    "cd_riyu_old": row.cd_riyu_old,
                    "nm_riyu_text": row.nm_riyu,
                    "su_chosei_old": row.su_chosei_old,
                    "biko_old": row.biko_old,
                    "cd_genka_center_old": row.cd_genka_center_old,
                    "nm_genka_center_text": row.nm_genka_center
                };
                // TODO: ここまで

                return changeData;
            };
            /// <summary>削除状態の変更セットに追加する変更データの設定を行います。</summary>
            /// <param name="row">選択行</param>
            var setDeletedChangeData = function (row) {
                // TODO: 画面の仕様に応じて以下の項目を変更してください。
                var changeData = {
                    "dt_hizuke": App.data.getDateTimeStringForQueryNoUtc(App.date.localDate(searchCondition.dt_chosei_hassei)),
                    "kbn_hin": row.kbn_hin,  //getHinKubun(),
                    "nm_kbn_hin": row.nm_kbn_hin,
                    "cd_hinmei": row.cd_hinmei,
                    "cd_riyu": row.cd_riyu,
                    "su_chosei": row.su_chosei,
                    "biko": row.biko,
                    "cd_genka_center": row.cd_genka_center,
                    "cd_soko": row.cd_soko,
                    "cd_seihin": row.cd_seihin,
                    "no_seq": row.no_seq,
                    "dt_update": new Date(),
                    "cd_update": App.ui.page.user.Code,
                    "no_lot_seihin": row.no_lot_seihin,
                    "kbn_shiyo_jisseki_anbun": pageLangText.shiyoJissekiAnbunKubunChosei.text,
                    "no_lot": row.no_seq,
                    "no_seq_shiyo_yojitsu_anbun": row.anbun_no_seq,
                    "su_shiyo": row.su_chosei
                };
                // TODO: ここまで

                return changeData;
            };

            /// <summary>関連項目の設定を変更セットに反映します。</summary>
            /// <param name="selectedRowId">選択行ID</param>
            /// <param name="cellName">列名</param>
            /// <param name="value">元となる項目の値</param>
            //var setRelatedChangeData = function (selectedRowId, cellName, value, changeData) {
            //    // TODO: 画面の仕様に応じて以下の処理を変更してください。
            //    if (cellName === "ArticleName") {
            //        //changeSet.addUpdated(selectedRowId, "cd_hinmei", value, changeData);
            //    }
            //    // TODO: ここまで
            //};

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
            };
            /// <summary>追加ボタンクリック時のイベント処理を行います。</summary>
            $(".add-button").on("click", addData);

            /// <summary>行を削除します。</summary>
            /// <param name="e">イベントデータ</param>
            var deleteData = function (e) {
                // 選択行のID取得
                var selectedRowId = getSelectedRowId();
                if (App.isUndefOrNull(selectedRowId)) {
                    return;
                }

                //削除対象行が返品・返品取消の場合エラーアラート出力
                grid.saveCell(currentRow, currentCol);
                var cellName = 'cd_riyu';
                var cd_riyu_select = grid.getCell(selectedRowId, cellName);
                //if (cd_riyu_select == pageLangText.kbn_zaiko_chosei_henpin.text) {
                if (cd_riyu_select == pageLangText.kbn_zaiko_chosei_henpin.text || cd_riyu_select == pageLangText.kbn_zaiko_chosei_henpintorikeshi.text) {
                    var cellName = 'nm_riyu';
                    var nm_riyu_select = grid.getCell(selectedRowId, cellName);
                    App.ui.page.notifyAlert.message(
                        App.str.format(pageLangText.griddelError.text, nm_riyu_select)
                    ).show();

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

            /// <summary>原資材検索ボタンクリック時のイベント処理を行います。</summary>
            $(".genshizai-button").on("click", function (e) {
                if (!checkRecordCount()) {
                    return;
                }
                //既存データ行の場合、エラーメッセージ(MS0831)を表示
                if (grid.jqGrid('getCell', grid.getGridParam("selrow"), 'no_seq')) {
                    App.ui.page.notifyAlert.message(pageLangText.noDisplayDialog.text).show();
                }
                else {
                    showGenshizaiDialog();
                }
            });

            /// <summary>製品検索ボタンクリック時のイベント処理を行います。</summary>
            $(".seihin-button").on("click", function (e) {
                if (!checkRecordCount()) {
                    return;
                }
                //既存データ行の場合、エラーメッセージ(MS0831)を表示
                if (grid.jqGrid('getCell', grid.getGridParam("selrow"), 'no_seq')) {
                    App.ui.page.notifyAlert.message(pageLangText.noDisplayDialog.text).show();
                }
                else {
                    showSeihinDialog();
                }
            });

            /// <summary>仕掛残一覧ボタンクリック時のイベント処理を行います。</summary>
            $(".shikakariZan-button").on("click", function (e) {
                if (!checkRecordCount()) {
                    return;
                }
                showShikakariZanIchiranDialog();
            });


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
                // 日付系は文字列に変換して比較する
                var choseiDateSearchCreate = App.data.getDateTimeString(criteria.dt_chosei_hassei);
                if (App.isUndefOrNull(searchCondition)) {
                    // 未検索時は初期表示値を設定（searchConditionがundefinedの為）
                    searchCondition = getSearchConDef();
                }
                choseiDateSearchCon = App.data.getDateTimeString(searchCondition.dt_chosei_hassei);

                if (criteria.hinKubun != searchCondition.hinKubun) {
                    return true;
                }
                if (choseiDateSearchCreate != choseiDateSearchCon) {
                    return true;
                }
                return false;
            };

            //調整数が0の場合、保存できません
            var suChoseiCheck = function () {
                var ids = grid.jqGrid('getDataIDs');
                for (var i = 0; i < ids.length; i++) {
                    var id = ids[i];
                        //suChosei = grid.getCell(id, "su_chosei");
                    if (grid.getCell(id, "su_chosei") == 0) {
                        return false;
                    }
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
                    unique,
                    current,
                // TODO: 画面の仕様に応じて以下の変数を変更します。
                    checkCol = 11;
                // TODO: ここまで

                // データ整合性エラーのハンドリングを行います。
                if (App.isArray(ret) && ret.length > 0) {
                    for (var i = 0; i < ret.length; i++) {
                        // TODO: 画面の仕様に応じて以下の値を変更します。
                        if (ret[i].InvalidationName === "NotExsists") {
                            // TODO: ここまで

                            for (var j = 0; j < ids.length; j++) {
                                // TODO: 画面の仕様に応じて以下の値を変更します。
                                value = parseInt(grid.getCell(ids[j], checkCol), 10);
                                retValue = ret[i].Data.no_seq;
                                // TODO: ここまで

                                if (isNaN(value) || value === retValue) {
                                    // TODO: 画面の仕様に応じて以下のロジックを変更します。
                                    unique = ids[j] + "_" + firstCol;

                                    // エラーメッセージの表示
                                    App.ui.page.notifyAlert.message(
                                        pageLangText.invalidation.text + ret[i].Message, unique).show();
                                    // 対象セルの背景変更
                                    grid.setCell(ids[j], firstCol, ret[i].Data.no_seq, { background: '#ff6666' });
                                    // TODO: ここまで
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
                                value = parseInt(changeSet.changeSet.deleted[p].no_seq, 10)
                                retValue = ret[i].Data.no_seq;
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
                            value = parseInt(grid.getCell(p, checkCol), 10);
                            retValue = ret.Updated[i].Requested.no_seq;
                            // TODO: ここまで

                            if (isNaN(value) || value === retValue) {
                                // 更新状態の変更セットから変更データを削除
                                changeSet.removeUpdated(p);

                                var upCurrent = ret.Updated[i].Current;
                                // 他のユーザーによって削除されていた場合
                                if (App.isUndefOrNull(upCurrent)) {
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
                                    current.cd_hinmei = upCurrent.cd_hinmei;
                                    current[hinmeiName] = upCurrent[hinmeiName];
                                    current.kbn_hin = upCurrent.kbn_hin;
                                    current.nm_kbn_hin = upCurrent.nm_kbn_hin;
                                    current.nm_nisugata = upCurrent.nm_nisugata;
                                    current.tani_shiyo = upCurrent.tani_shiyo;
                                    current.su_chosei = upCurrent.su_chosei;
                                    current.cd_riyu = upCurrent.cd_riyu;
                                    current.nm_riyu = upCurrent.nm_riyu;
                                    current.biko = upCurrent.biko;
                                    current.cd_seihin = upCurrent.cd_seihin;
                                    current[seihinName] = upCurrent[seihinName];
                                    current.cd_update = upCurrent.cd_update;
                                    current.nm_update = upCurrent.nm_update;
                                    current.dt_update = upCurrent.dt_update;
                                    current.flg_mishiyo = upCurrent.flg_mishiyo;
                                    current.no_seq = upCurrent.no_seq;
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
                            retValue = ret.Deleted[i].Requested.no_seq;
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
                // 確認ダイアログのクローズ
                closeSaveConfirmDialog();
                // 情報メッセージのクリア
                App.ui.page.notifyInfo.clear();
                // ローディングの表示
                App.ui.loading.show(pageLangText.nowSaving.text);

                // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                var saveUrl = "../api/GenshizaiChoseiNyuryoku";
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
            /// <summary>保存ボタンクリック時のイベント処理を行います。</summary>
            //$(".save-button").on("click", showSaveConfirmDialog);
            $(".save-button").on("click", function () {

                var currentData;

                // 編集内容の保存
                saveEdit();

                currentData = grid.getRowData();

                // チェック処理
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
                //調整数が０の場合、保存できません
                if (!suChoseiCheck()) {
                    App.ui.loading.close();
                    App.ui.page.notifyAlert.message(MS0735).show();
                    return;
                }
                // 検索条件が変更されている場合は処理を抜ける
                if (changeCondition()) {
                    App.ui.page.notifyAlert.message(pageLangText.changeCondition.text).show();
                    return;
                }
                for (var i = 0; i < currentData.length; i++) {
                    if (!checkRangeShikakari(currentData[i])) {
                        App.ui.page.notifyAlert.message(pageLangText.rangeOver.text).show();
                        return;
                    }
                }
                //showSaveConfirmDialog();
                setTimeout(saveData, 1);
            });

            checkRangeShikakari = function (targetRow) {
                // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                var checkResult = true,
                    selectedRowId = getSelectedRowId(true),

                    _query = { url: "../api/GenshizaiChoseiNyuryoku"
                            , "before_su_chosei": targetRow.su_chosei_initial
                            , "after_su_chosei": targetRow.su_chosei
                            , "no_lot_seihin": targetRow.no_lot_seihin
                            , "kbn_shiyo_jisseki_anbun": pageLangText.shiyoJissekiAnbunKubunChosei.text
                            , "no_lot": targetRow.no_seq
                            , "no_seq_shiyo_yojitsu_anbun": targetRow.anbun_no_seq
                    };

                if (targetRow.no_lot_seihin != null && targetRow.no_lot_seihin != "") {

                    App.ajax.webgetSync(
                        App.data.toWebAPIFormat(_query)
                    ).done(function (result) {
                        if (result.__count == 0) {
                            checkResult = false;
                        }
                    }).fail(function (result) {
                        // データ変更エラーハンドリングを行います。
                        App.ui.page.notifyAlert.message(result.message).show();
                    });

                }

                return checkResult;
            };


            //// 保存処理 -- End

            //// バリデーション -- Start

            // グリッドコントロール固有のバリデーション

            // TODO: 画面の仕様に応じて以下のカスタムバリデーション定義を変更してください。

            /// <summary>データベース問い合わせチェックを行います。</summary>
            /// <param name="value">原資材コードまたは製品コード</param>
            /// <param name="selectCol">チェック対象のセル番号</param>
            var isValidArticleCD = function (value, selectCol) {
                var isValid = true;

                // 原資材コードの場合
                if (selectCol == hinCodeCol) {
                    // 検索条件の品区分によって抽出条件を変更する
                    var strWhere = "";
                    if (App.isUndefOrNull(searchCondition)) {
                        // 未検索時は空を設定（searchConditionがundefinedの為）
                        searchCondition = getSearchConDef();
                    }
                    if (!App.isUndefOrNull(searchCondition.hinKubun) && searchCondition.hinKubun.length > 0) {
                        strWhere = "and kbn_hin eq " + searchCondition.hinKubun;
                    }
                    else {
                        strWhere = "and (kbn_hin eq " + pageLangText.genryoHinKbn.text + " or kbn_hin eq "
                            + pageLangText.shizaiHinKbn.text + " or kbn_hin eq " + pageLangText.jikaGenryoHinKbn.text + ")";
                    }
                }
                else if (selectCol == seihinCodeCol && value != "") {
                    strWhere = "and (kbn_hin eq " + pageLangText.seihinHinKbn.text + " or kbn_hin eq "
                        + pageLangText.jikaGenryoHinKbn.text + ")";
                }
                else {
                    return true;
                }
                var _query = {
                    url: "../Services/FoodProcsService.svc/ma_hinmei",
                    filter: "flg_mishiyo eq " + pageLangText.shiyoMishiyoFlg.text
                        + " and cd_hinmei eq '" + value + "' " + strWhere,
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

            /// <summary>データベース問い合わせチェックを行います。</summary>
            /// <param name="selectedRowId">チェック対象の行番号</param>
            var checkNolot = function (selectedRowId, no_lot_seihin) {
                var isValid = true,
                // 選択行のID取得
                selectedRow = grid.getRowData(selectedRowId),
                cd_hinmei = selectedRow.cd_hinmei,
                _query = {
                    url: "../Services/FoodProcsService.svc/vw_tr_keikaku_seihin_exists",
                    filter: "flg_mishiyo eq " + pageLangText.shiyoMishiyoFlg.text
                        + " and no_lot_seihin eq '" + no_lot_seihin + "' " + " and cd_hinmei eq '" + cd_hinmei + "' ",
                    top: 1
                };
                if (no_lot_seihin == null || no_lot_seihin == "") {
                    return isValid; ;
                }
                App.ajax.webgetSync(
                       App.data.toODataFormat(_query)
                ).done(function (result) {
                    // サービス呼び出し成功時の処理
                    if (result.d.length == 0) {
                        isValid = false;
                    }
                }).fail(function (result) {
                    isValid = false;
                    App.ui.page.notifyAlert.message(result.message).show();
                });

                return isValid;
            };

            validationSetting.cd_hinmei.rules.custom = function (value) {
                return isValidArticleCD(value, hinCodeCol);
            };
            validationSetting.cd_seihin.rules.custom = function (value) {
                return isValidArticleCD(value, seihinCodeCol);
            };

            validationSetting.no_lot_seihin.rules.custom = function (value) {
                return flgValiNolot;
            }



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
                    //製品ロット№の存在チェック
                    if (colModel[i].name == "no_lot_seihin") {
                        flgValiNolot = checkNolot(selectedRowId, grid.getCell(selectedRowId, colModel[i].name));
                    }
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
            }
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

            /// <summary>ダウンロードボタンクリック時のオーバレイ処理を行います。</summary>
            var downloadOverlay = function () {
                //App.ui.loading.show(pageLangText.nowProgressing.text);
                printExcel();
                //App.ui.loading.close();
            };
            /// <summary>Excelファイル出力を行います。</summary>
            var printExcel = function (e) {

                var query = {
                    // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                    url: "../api/GenshizaiChoseiNyuryokuExcel",
                    // TODO: ここまで
                    filter: createFilter(),
                    // TODO: 画面の仕様に応じて以下のソート条件を変更してください。
                    orderby: "cd_hinmei"
                    // TODO: ここまで
                };
                // 処理中を表示する
                App.ui.loading.show(pageLangText.nowProgressing.text);

                // 必要な情報を渡します
                var container = $(".search-criteria").toJSON(),
                    hinKbnName = pageLangText.noSelectConditionExcel.text;
                if (!App.isUndefOrNull(container.hinKubun)) {
                    hinKbnName = $("#condition-hinKubun option:selected").text();
                }
                var url = App.data.toODataFormat(query);
                url = url + "&lang=" + App.ui.page.lang + "&hinKubun=" + encodeURIComponent(hinKbnName) + "&userName=" + encodeURIComponent(App.ui.page.user.Name)
                    + "&UTC=" + new Date().getTimezoneOffset() / 60
                    + "&today=" + App.data.getDateTimeStringForQuery(new Date(), true);
                window.open(url, '_parent');
                // Cookieを監視する
                onComplete();
            };
            /// <summary>Excelボタンクリック時のイベント処理を行います。</summary>
            $(".excel-button").on("click", function () {
                // 編集内容の保存
                saveEdit();

                //// 出力前チェック ////
                // 検索条件の必須チェック
                var result = $(".part-body .item-list").validation().validate();
                if (result.errors.length) {
                    return;
                }
                // 明細に変更がないこと
                if (!noChange()) {
                    App.ui.page.notifyInfo.message(pageLangText.excelChangeMeisai.text).show();
                    return;
                }

                // 出力処理へ
                downloadOverlay();
            });
            /// <summary>Excel(一括出力)ボタンクリック時のイベント処理を行います。</summary>
            $(".excelikatsu-button").on("click", showGenshizaichoseinyuryokuExcelIkatsuDialog);
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
                if (app_util.prototype.getCookieValue(pageLangText.genshizaiChoseiNyuryokuCookie.text) == pageLangText.checkCookie.text) {
                    app_util.prototype.deleteCookie(pageLangText.genshizaiChoseiNyuryokuCookie.text);
                    //ローディング終了
                    App.ui.loading.close();
                }
                else {
                    // 再起してCookieが作成されたか監視
                    setTimeout(onComplete, 1000);
                }
            };
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
                        <span class="item-label" data-app-text="dt_chosei_hassei"></span>
                        <input type="text" name="dt_chosei_hassei" id="condition-date" />
                    </label>
                </li>
                <li>
                    <label>
                        <span class="item-label" data-app-text="kbn_hin"></span>
                        <select name="hinKubun" id="condition-hinKubun">
                        </select>
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
                <button type="button" class="genshizai-button" name="genshizai-button" data-app-operation="hinmeiIchiran"><span class="icon"></span><span data-app-text="genshizaiIchiran"></span></button>
                <button type="button" class="seihin-button" name="seihin-button" data-app-operation="seihinIchiran"><span class="icon"></span><span data-app-text="seihinIchiran"></span></button>
                <%-- ■仕掛残計上機能OFF対応(機能ONは下のコメントアウトをオープンして下さい):仕掛残一覧ダイアログ起動ボタンの非表示--%>
                <%--<button type="button" class="shikakariZan-button" name="shikakariZan-button" data-app-operation="shikakariZanIchiran"><span class="icon"></span><span data-app-text="shikakariZanIchiran"></span></button>--%>
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
        <button type="button" class="excelikatsu-button" name="excelikatsu-button" data-app-operation="excelikatsuexcel">
            <span data-app-text="excelIkatsu"></span>
        </button>
        <!--
        <button type="button" class="searchList-button">
            <span data-app-text="compoundList"></span></button>
                                                            -->
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
    <div class="seihin-dialog">
    </div>
    <div class="shikakarizan-dialog">
    </div>
    <div class="excel-ikatsu-dialog">
	</div>
    <!-- TODO: ここまで  -->

    <!-- 画面デザイン -- End -->
</asp:Content>
