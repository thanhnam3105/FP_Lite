<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="GenshizaiZaikoNyuryoku.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.GenshizaiZaikoNyuryoku" %>

<asp:Content ID="Content1" ContentPlaceHolderID="IncludeContent" runat="server">
    <script src="<%=ResolveUrl("~/Resources/pages/pagedata-genshizaizaikonyuryoku." + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
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
            width: 310px;
        }
        
        .part-body .item-list-right li
        {
            margin-left: 300px;
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

        .search-confirm-dialog,
        .confirm-dialog,
        .zaikocopy-confirm-dialog,
        .retrasmitinventory-confirm-dialog
        {
            background-color: White;
            width: 350px;
        }
                
        .search-confirm-dialog .part-body,
        .confirm-dialog .part-body,
        .zaikocopy-confirm-dialog .part-body,
        .retrasmitinventory-confirm-dialog .part-body
        {
            width: 95%;
        }
        
        .csv-upload-dialog
        {
            background-color: White;
            width: 650px;
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
        .complete-dialog
        {
            background-color: White;
            width: 350px;
        }
                
        .complete-dialog .part-body
        {
            width: 95%;
        }
        .error-dialog
        {
            background-color: White;
            width: 350px;
        }  
        .error-dialog .part-body
        {
            width: 95%;
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
                querySetting = { skip: 0, top: 1000, count: 0 },
                isDataLoading = false,
                searchCondition,
                isUpdate = false;//更新フラグ

            // グリッドコントロール固有の変数宣言
            var grid = $("#item-grid"),
                lastScrollTop = 0,
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
                changeSet = new App.ui.page.changeSet(),
                firstCol = 3,
                duplicateCol = 999,
                currentRow = 0,
                currentCol = firstCol,
                totalKingaku = 0;
            // TODO: ここまで

            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            var hinKubun, // 検索条件：品区分のコンボボックス
                hinBunrui, // 検索条件：品分類のコンボボックス
                kurabasho, // 検索条件：庫場所のコンボボックス
                souko,
                soukoHyoji,
            // 多言語対応にしたい項目を変数にする
                hinmeiName = 'nm_hinmei_' + App.ui.page.lang;  // 原資材名

            // 英語化対応　言語によって幅を調節
            $(".search-criteria .item-label").css("width", pageLangText.each_lang_width.number);
            $("#ari_nomi").css("width", pageLangText.ari_nomi_width.number);

            // TODO：ここまで

            // ダイアログ固有の変数宣言
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            var saveConfirmDialog = $(".save-confirm-dialog"),
                searchConfirmDialog = $(".search-confirm-dialog"),
                confirmDialog = $(".confirm-dialog"),
                csvUpDialog = $(".csv-upload-dialog"),
                zaikocopyConfirmDialog = $(".zaikocopy-confirm-dialog");
            // 在庫伝送確認ダイアログを開く
            retrasmitInventoryConfirmDialog = $(".retrasmitinventory-confirm-dialog");
            completeDialog = $(".complete-dialog");
            errorDialog = $(".error-dialog");

            // 在庫再伝送了ダイアログ情報メッセージの設定
            var completeDialogNotifyInfo = App.ui.notify.info(completeDialog, {
                container: ".complete-dialog .dialog-slideup-area .info-message",
                messageContainerQuery: "ul",
                show: function () {
                    completeDialog.find(".info-message").show();
                },
                clear: function () {
                    completeDialog.find(".info-message").hide();
                }
            });

            // 品名一覧の引数
            var getHinKbnParam = function () {
                // 検索条件の品区分によって抽出条件を変更する
                var hinKbnParam = "";
                if (App.isUndefOrNull(searchCondition)) {
                    // 未検索時は空を設定（searchConditionがundefinedの為）
                    searchCondition = getSearchConDef();
                }

                if (searchCondition.hinKubun == pageLangText.genryoHinKbn.text) {
                    hinKbnParam = pageLangText.hinmeiDlgParam_genryo.text;
                }
                else if (searchCondition.hinKubun == pageLangText.shizaiHinKbn.text) {
                    hinKbnParam = pageLangText.hinmeiDlgParam_shizai.text;
                }
                else {
                    hinKbnParam = pageLangText.hinmeiDlgParam_genshizai.text;
                }
                return hinKbnParam;
            };

            // 初期表示時の検索条件を取得する
            var getSearchConDef = function () {
                return {
                    dt_zaiko: App.date.startOfDay(new Date()),
                    hinKubun: null,
                    hinBunrui: null,
                    kurabasho: null,
                    souko: null,
                    shiyoubun: "on",
                    //mishiyoubun: "on",
                    mishiyoubun: "off",
                    ari_nomi: null,
                    hinmei: null,
                    select_kbn_zaiko: 0
                };
            };

            // 実在庫数(納入単位)を取得する
            var getJitsuzaikoNonyu = function (juryo, irisu, zaikoShiyo) {
                var jitsuzaikoNonyu = 0.000;
                if (juryo > 0 && zaikoShiyo > 0 && irisu > 0) {
                    jitsuzaikoNonyu = zaikoShiyo / (juryo * irisu);
                    // 小数以下は切り捨て
                    jitsuzaikoNonyu = Math.floor(jitsuzaikoNonyu);
                }
                return jitsuzaikoNonyu;
            };

            // 実在庫端数(納入単位)を取得する
            var getJitsuzaikoHasu = function (juryo, irisu, cdTani, zaikoShiyo) {
                var jitsuzaikoHasu = 0.000;
                if (juryo > 0 && zaikoShiyo > 0 && irisu > 0) {
                    jitsuzaikoHasu = zaikoShiyo % (juryo * irisu);
                    if (cdTani == pageLangText.kgKanzanKbn.text || cdTani == pageLangText.lKanzanKbn.text) {
                        // 納入単位がKgまたはLの場合
                        jitsuzaikoHasu = jitsuzaikoHasu * 1000;
                    }
                    else {
                        jitsuzaikoHasu = jitsuzaikoHasu / juryo;
                    }
                    // 小数点第二位を切上げ：JSの場合、一度切り捨ててから切り上げを行う
                    jitsuzaikoHasu = Math.floor(jitsuzaikoHasu * 100) / 100;
                    jitsuzaikoHasu = Math.ceil(jitsuzaikoHasu * 10) / 10;
                }
                return jitsuzaikoHasu;
            };

            // 実在庫数(使用単位)を取得する
            var getJitsuzaikoShiyo = function (juryo, irisu, cdTani, zaikoNonyu, zaikoNonyuHasu) {
                var jitsuzaikoShiyo = 0.000;
                if (juryo > 0 && irisu > 0) {
                    if (cdTani == pageLangText.kgKanzanKbn.text || cdTani == pageLangText.lKanzanKbn.text) {
                        // 納入単位がKgまたはLの場合
                        if (zaikoNonyuHasu > 0) {
                            jitsuzaikoShiyo = zaikoNonyu * juryo * irisu + (zaikoNonyuHasu / 1000);
                        }
                        else {
                            jitsuzaikoShiyo = zaikoNonyu * juryo * irisu;
                        }
                    }
                    else {
                        jitsuzaikoShiyo = ((zaikoNonyu * irisu) + zaikoNonyuHasu) * juryo;
                    }
                    // 小数点第七位を切上げ：JSの場合、一度切り捨ててから切り上げを行う
                    //jitsuzaikoShiyo = Math.floor(jitsuzaikoShiyo * 10000000) / 10000000;
                    //jitsuzaikoShiyo = Math.ceil(jitsuzaikoShiyo * 1000000) / 1000000;
                    // 小数点第四位を切上げ：JSの場合、切り上げを行う
                    jitsuzaikoShiyo = Math.floor(jitsuzaikoShiyo * 10000) / 10000;
                    jitsuzaikoShiyo = Math.ceil(jitsuzaikoShiyo * 1000) / 1000;
                }
                return jitsuzaikoShiyo;
            };

            // 金額を取得する
            var getKingaku = function (juryo, tanka, zaikoShiyo) {
                var kingaku = 0;
                if (tanka != 0 && zaikoShiyo != 0 && juryo > 0) {
                    kingaku = (zaikoShiyo / juryo) * tanka;
                }
                // 小数以下は切り捨て
                return Math.floor(kingaku);
            };

            // TODO：ここまで

            //// 変数宣言 -- End

            //// コントロール定義 -- Start

            // ダイアログ固有のコントロール定義
            saveConfirmDialog.dlg();
            searchConfirmDialog.dlg();
            confirmDialog.dlg();
            zaikocopyConfirmDialog.dlg();
            // 在庫伝送確認ダイアログ
            retrasmitInventoryConfirmDialog.dlg();
            completeDialog.dlg();
            errorDialog.dlg();
            // CSVアップロードダイアログ生成
            csvUpDialog.dlg({
                url: "Dialog/CsvUploadDialog.aspx",
                name: "CsvUploadDialog",
                closed: function (e, data) {
                    if (data == "canceled") {
                        App.ui.loading.close();
                        return;
                    }
                    else {
                        // 保存成功の確認ダイアログを表示します。
                        showConfirmDialog(pageLangText.successMessage.text);
                        findData();
                    }
                }
            });

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

            /// <summary>ダイアログを開きます。</summary>
            var showSaveConfirmDialog = function () {
                // 対象行が存在するか確認
                var selectedRowId = getSelectedRowId(),
                    position = "after";
                if (App.isUndefOrNull(selectedRowId)) {
                    return;
                }
                saveConfirmDialogNotifyInfo.clear();
                saveConfirmDialogNotifyAlert.clear();
                saveConfirmDialog.draggable(true);
                saveConfirmDialog.dlg("open");
            };
            // 検索時のダイアログ
            var showSearchConfirmDialog = function () {
                // 検索前に変更をチェック
                if (!isUpdate) {
                    findData();
                }
                else {
                    searchConfirmDialogNotifyInfo.clear();
                    searchConfirmDialogNotifyAlert.clear();
                    searchConfirmDialog.draggable(true);
                    searchConfirmDialog.dlg("open");
                }
            };
            // 確認ダイアログ
            var showConfirmDialog = function (msg) {
                setConfirmDialogMessage(msg);
                confirmDialog.draggable(true);
                confirmDialog.dlg("open");
            };
            // 在庫コピー確認ダイアログ
            var showZaikocopyConfirmDialog = function (msg) {
                setZaikocopyConfirmDialogMessage(msg);
                zaikocopyConfirmDialog.draggable(true);
                zaikocopyConfirmDialog.dlg("open");
            };
            // 在庫伝送確認ダイアログ
            var showRetrasmitInventoryConfirmDialog = function (msg) {
                setRetrasmitInventoryConfirmDialogMessage(msg);
                retrasmitInventoryConfirmDialog.draggable(true);
                retrasmitInventoryConfirmDialog.dlg("open");
            };
            // 在庫伝送エラーダイアログ
            var showErrorDialog = function (msg) {
                setErrorDialogMessage(msg);
                errorDialog.draggable(true);
                errorDialog.dlg("open");
            };
            // 在庫伝送完了ダイアログ
            var showCompleteDialog = function (msg) {
                setCompleteDialogMessage(msg);
                completeDialog.draggable(true);
                completeDialog.dlg("open");
            };

            /// <summary>ダイアログを閉じます。</summary>
            var closeSaveConfirmDialog = function () {
                saveConfirmDialog.dlg("close");
            };
            var closeSearchConfirmDialog = function () {
                searchConfirmDialog.dlg("close");
            };
            var closeConfirmDialog = function () {
                confirmDialog.dlg("close");
            };
            var closeZaikocopyConfirmDialog = function () {
                zaikocopyConfirmDialog.dlg("close");
            };
            // 在庫伝送確認ダイアログを閉じた時の処理
            var closeRetrasmitInventoryConfirmDialog = function () {
                retrasmitInventoryConfirmDialog.dlg("close");
            };
            // 在庫伝送完了ダイアログを閉じた時の処理
            var closeCompleteDialog = function () {
                completeDialog.dlg("close");
                searchItems(new query());
            };
            // 在庫伝送エラーダイアログを閉じた時の処理
            var closeErrorDialog = function () {
                errorDialog.dlg("close");
            };

            // 確認ダイアログのメッセージを設定します。
            var setConfirmDialogMessage = function (msg) {
                confirmDialog.find(".dialog-body .part-body span").text(msg);
            };

            var setZaikocopyConfirmDialogMessage = function (msg) {
                zaikocopyConfirmDialog.find(".dialog-body .part-body span").text(msg);
            };
            // 在庫伝送確認ダイアログのメッセージを設定する
            var setRetrasmitInventoryConfirmDialogMessage = function (msg) {
                retrasmitInventoryConfirmDialog.find(".dialog-body .part-body span").text(msg);
            };
            var setCompleteDialogMessage = function (msg) {
                completeDialog.find(".dialog-body .part-body span").text(msg);
            };
            //　在庫伝送エラーダイアログのメッセージを設定する
            var setErrorDialogMessage = function (msg) {
                errorDialog.find(".dialog-body .part-body span").text(msg);
            };

            // 日付の多言語対応
            var datePickerFormat = pageLangText.dateFormatUS.text;
            var newDateFormat = pageLangText.dateNewFormatUS.text;
            if (App.ui.page.langCountry !== 'en-US') {
                datePickerFormat = pageLangText.dateFormat.text;
                newDateFormat = pageLangText.dateNewFormat.text;
            }
            // datepicker の設定
            var conditionDate = $("#condition-date");
            conditionDate.datepicker({ dateFormat: datePickerFormat });
            // 有効範囲：1970/1/1～システム日付より1年後
            conditionDate.datepicker("option", 'minDate', new Date(1975, 1 - 1, 1));
            conditionDate.datepicker("option", 'maxDate', "+1y");
            // スラッシュ自動付与
            conditionDate.on("keyup", App.data.addSlashForDateString).datepicker({ dateFormat: datePickerFormat });

            // グリッドコントロール固有のコントロール定義
            grid.jqGrid({
                // TODO：画面の仕様に応じて以下の列名の定義を変更してください。
                colNames: [
                    pageLangText.hinBunrui.text,
                    pageLangText.cd_hinmei.text,
                    pageLangText.nm_hinmei.text,
                    pageLangText.nm_nisugata.text,
                    pageLangText.tani_nonyu.text,
                    pageLangText.tani_shiyo.text,
                    pageLangText.keisan_zaiko.text,
                    pageLangText.jitsuzaiko_nonyu.text + pageLangText.requiredMark.text,
                    pageLangText.jitsuzaiko_hasu.text + pageLangText.requiredMark.text,
                    pageLangText.su_zaiko.text + pageLangText.requiredMark.text,
                    pageLangText.sokoCode.text,
                    pageLangText.sokoName.text,
                    pageLangText.dt_kakutei_zaiko.text,
                    //BRC t.Sato 2021/03/11 Start -->
                    //pageLangText.tanka.text,
                    pageLangText.tan_tana.text,
                    //BRC t.Sato 2021/03/11 End <--
                    pageLangText.kingaku.text,
                    pageLangText.flg_mishiyo.text,
                    pageLangText.wt_ko.text,
                    pageLangText.su_iri.text,
                    pageLangText.nm_hinkbn.text,
                    pageLangText.cd_tani_nonyu.text,
                    pageLangText.cd_kura.text,
                    pageLangText.nm_kura.text,
                    //BRC quang.l 2022/04/21 #1699 Start -->
                    pageLangText.dt_update.text,
                    pageLangText.tan_tana.text
                    //BRC quang.l 2022/04/21 #1699 End <--
                ],
                // TODO：ここまで
                // TODO：画面の仕様に応じて以下の列モデルの定義を変更してください。
                colModel: [
                    { name: 'nm_bunrui', width: pageLangText.nm_bunrui_width.number, editable: false, sorttype: "text" },
                    { name: 'cd_hinmei', width: pageLangText.cd_hinmei_width.number, editable: false, sorttype: "text" },
                    { name: hinmeiName, width: pageLangText.nm_hinmei_width.number, editable: false, sorttype: "text" },
                    { name: 'nm_nisugata_hyoji', width: pageLangText.nm_nisugata_hyoji_width.number, editable: false, sorttype: "text" },
                    { name: 'tani_nonyu', width: pageLangText.tani_nonyu_width.number, editable: false, sorttype: "text" },
                    { name: 'tani_shiyo', width: pageLangText.tani_shiyo_width.number, editable: false, sorttype: "text" },
                    {
                        name: 'su_keisan_zaiko', width: pageLangText.su_keisan_zaiko_width.number, editable: false, align: "right", sorttype: "float",
                        formatter: 'number',
                        formatoptions: {
                            decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 3, defaultValue: "0.000"
                        }
                    },
                    {
                        name: 'jitsuzaiko_nonyu', width: pageLangText.jitsuzaiko_nonyu_width.number, editable: true, align: "right", sorttype: "float",
                        formatter: 'number',
                        formatoptions: {
                            decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 1, defaultValue: "0.0"
                        }
                    },
                    {
                        name: 'jitsuzaiko_hasu', width: pageLangText.jitsuzaiko_hasu_width.number, editable: true, align: "right", sorttype: "float",
                        formatter: 'number',
                        formatoptions: {
                            decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 1, defaultValue: "0.0"
                        }
                    },
                    {
                        name: 'su_zaiko', width: pageLangText.su_zaiko_width.number, editable: true, align: "right", sorttype: "float",
                        formatter: 'number',
                        formatoptions: {
                            //decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 6, defaultValue: "0.000000"
                            decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 3, defaultValue: "0.000"
                        }
                    },
                    { name: 'cd_soko', width: pageLangText.nm_soko_width.number, editable: false, sorttype: "text", hidden: true, hidedlg: true },
                    { name: 'nm_soko', width: pageLangText.nm_soko_width.number, editable: false, sorttype: "text", hidden: true, hidedlg: true },
                    {
                        name: 'dt_jisseki_zaiko', width: pageLangText.dt_jisseki_zaiko_width.number, sorttype: "text", align: "center",
                        formatter: "date",
                        formatoptions: {
                            srcformat: newDateFormat, newformat: newDateFormat
                        }
                    },
                    {
                        name: 'tan_tana', width: pageLangText.tan_ko_width.number, editable: true, align: "right", sorttype: "float",
                        formatter: 'number',
                        formatoptions: {
                            decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 0, defaultValue: "0.0"
                        }
                    },
                    {
                        name: 'kingaku', width: pageLangText.kingaku_width.number, editable: false, align: "right", sorttype: "float",
                        formatter: 'number',
                        formatoptions: {
                            decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 0, defaultValue: "0"
                        }
                    },
                    {
                        name: 'flg_mishiyo', width: pageLangText.flg_mishiyo_width.number, editable: false, edittype: 'checkbox',
                        editoptions: { value: "1:0" }, formatter: 'checkbox', align: 'center'
                    },
                    { name: 'wt_ko', width: 0, hidden: true, hidedlg: true },
                    { name: 'su_iri', width: 0, hidden: true, hidedlg: true },
                    { name: 'nm_hinkbn', width: 0, hidden: true, hidedlg: true },
                    { name: 'cd_tani_nonyu', width: 0, hidden: true, hidedlg: true },
                    { name: 'cd_kura', width: 0, hidden: true, hidedlg: true },
                    { name: 'nm_kura', width: 0, hidden: true, hidedlg: true },
                    //BRC quang.l 2022/04/21 #1699 Start -->
                    { name: 'dt_update', width: 0, hidden: true, hidedlg: true },
                    {
                        name: 'tan_tana_bef', width: 0, hidden: true, hidedlg: true , editable: false,
                        formatter: 'number',
                        formatoptions: {
                            decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 0, defaultValue: "0.0"
                        }
                    }
                    //BRC quang.l 2022/04/21 #1699 End <--
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
                loadComplete: function () {
                    // 変数宣言
                    var ids = grid.jqGrid('getDataIDs'),
                        criteria = $(".search-criteria").toJSON(),
                        totalKingakuHyoji = 0;
                    // 合計金額のリセット
                    totalKingaku = 0;

                    for (var i = 0; i < ids.length; i++) {
                        var id = ids[i];
                        // TODO : ここから
                        // 合計金額の計算
                        var kingaku = parseFloat(grid.getCell(id, "kingaku"));
                        totalKingaku = parseInt(totalKingaku) + parseInt(kingaku);
                        totalKingakuHyoji = App.data.toSeparatedDigits(totalKingaku);

                        //実績データがないものはすべて更新対象とする
                        var dt_jisseki = grid.getCell(id, "dt_jisseki_zaiko");
                        if (dt_jisseki.indexOf("/") == -1) {
                            // 更新状態の変更データの設定
                            changeData = setUpdatedChangeData(grid.getRowData(id));

                            // 実在庫数(使用単位)を保持
                            changeSet.addUpdated(id, "su_zaiko", changeData.su_zaiko, changeData);
                        }
                        // TODO：ここまで
                    }
                    // 合計金額の設定
                    $("#total-kingaku").text(totalKingakuHyoji);

                    //更新フラグをおろす
                    isUpdate = false;
                },
                gridComplete: function () {
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
                    //grid.moveCell(cellName, iRow, iCol);
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
                    // 数値以外が入力された場合、デフォルト値(0)を設定する：数値
                    if (!isFinite(value)) {
                        value = 0;
                        grid.setCell(selectedRowId, iCol, value);
                    }

                    // 関連項目の設定
                    setRelatedValue(selectedRowId, cellName, value, iCol);
                    // 変更データの変数設定
                    var changeData;
                    // 更新状態の変更データの設定
                    changeData = setUpdatedChangeData(grid.getRowData(selectedRowId));

                    // 保存するのは実在庫数(使用単位)と単価
                    if (cellName == "tan_tana") {
                        changeSet.addUpdated(selectedRowId, cellName, value, changeData);
                    }
                    else {
                        // 単価以外は実在庫数(使用単位)
                        changeSet.addUpdated(selectedRowId, "su_zaiko", changeData.su_zaiko, changeData);
                    }
                    //更新フラグを立てる
                    isUpdate = true;
                    // 関連項目の設定を変更セットに反映
                    //setRelatedChangeData(selectedRowId, cellName, value, changeData);
                },
                onCellSelect: function (rowid, icol, cellcontent) {
                    selectCol = icol;
                }
            });

            /// <summary>セルの関連項目を設定します。</summary>
            /// <param name="selectedRowId">選択行ID</param>
            /// <param name="cellName">列名</param>
            /// <param name="value">元となる項目の値</param>
            /// <param name="iCol">項目の列番号</param>
            var setRelatedValue = function (selectedRowId, cellName, value, iCol) {
                // TODO：画面の仕様に応じて以下の関連項目を設定を変更してください。

                // 実在庫数の再計算用変数
                var juryo = parseFloat(grid.getCell(selectedRowId, "wt_ko")),
                    irisu = parseFloat(grid.getCell(selectedRowId, "su_iri")),
                    tanka = parseFloat(grid.getCell(selectedRowId, "tan_tana")),
                    cdTani = grid.getCell(selectedRowId, "cd_tani_nonyu"),
                    zaikoNonyu = parseFloat(grid.getCell(selectedRowId, "jitsuzaiko_nonyu")),
                    zaikoNonyuHasu = parseFloat(grid.getCell(selectedRowId, "jitsuzaiko_hasu")),
                    zaikoShiyo = parseFloat(grid.getCell(selectedRowId, "su_zaiko"));
                // 金額計算用変数
                var kingaku = 0,
                    beforeKingaku = parseInt(grid.getCell(selectedRowId, "kingaku")),
                    totalKingakuHyoji;

                // 実在庫数(納入単位)または実在庫端数(納入単位)
                if (cellName === "jitsuzaiko_nonyu" || cellName === "jitsuzaiko_hasu") {
                    // 実在庫数(使用単位)と金額の再計算をする
                    zaikoShiyo = getJitsuzaikoShiyo(juryo, irisu, cdTani, zaikoNonyu, zaikoNonyuHasu);
                    grid.setCell(selectedRowId, "su_zaiko", zaikoShiyo);
                    kingaku = getKingaku(juryo, tanka, zaikoShiyo);
                    grid.setCell(selectedRowId, "kingaku", kingaku);
                }

                // 実在庫数(使用単位)
                if (cellName === "su_zaiko") {
                    // 実在庫数(納入単位)と実在庫端数(納入単位)と金額の再計算をする
                    zaikoNonyu = getJitsuzaikoNonyu(juryo, irisu, zaikoShiyo);
                    grid.setCell(selectedRowId, "jitsuzaiko_nonyu", zaikoNonyu);
                    zaikoNonyuHasu = getJitsuzaikoHasu(juryo, irisu, cdTani, zaikoShiyo);
                    grid.setCell(selectedRowId, "jitsuzaiko_hasu", zaikoNonyuHasu);
                    kingaku = getKingaku(juryo, tanka, zaikoShiyo);
                    grid.setCell(selectedRowId, "kingaku", kingaku);
                }

                // 実在庫数(納入単位/使用単位)、端数に変更があった場合、合計金額の再計算をする
                if (cellName === "jitsuzaiko_nonyu" || cellName === "jitsuzaiko_hasu" || cellName === "su_zaiko") {
                    totalKingaku = (parseInt(totalKingaku) - parseInt(beforeKingaku)) + parseInt(kingaku);
                    totalKingakuHyoji = App.data.toSeparatedDigits(totalKingaku);
                    $("#total-kingaku").text(totalKingakuHyoji);
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
            App.deferred.parallel({
                // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                // ローディング
                loading: App.ui.loading.show(pageLangText.nowProgressing.text),
                // 品区分
                hinKubun: App.ajax.webget("../Services/FoodProcsService.svc/ma_kbn_hin?$filter=kbn_hin eq "
                    + pageLangText.genryoHinKbn.text + " or kbn_hin eq " + pageLangText.shizaiHinKbn.text
                    + " or kbn_hin eq " + pageLangText.jikaGenryoHinKbn.text + "&$orderby=kbn_hin"),
                // 庫場所
                kurabasho: App.ajax.webget("../Services/FoodProcsService.svc/ma_kura?$filter=flg_mishiyo eq "
                    + pageLangText.shiyoMishiyoFlg.text + "&$orderby=cd_kura"),
                // 倉庫
                souko: App.ajax.webget("../Services/FoodProcsService.svc/ma_soko?$filter=flg_mishiyo eq "
                    + pageLangText.shiyoMishiyoFlg.text + "&$orderby=cd_soko"),
                // 倉庫表示区分
                soukoHyoji: App.ajax.webgetSync("../Services/FoodProcsService.svc/cn_kino_sentaku()?$filter=kbn_kino eq " + 13)//pageLangText.kinoDensoHyojiKbn.number)
                // 在庫伝送ボタン表示区分
                , zaikoDensoHyoji: App.ajax.webgetSync("../Services/FoodProcsService.svc/cn_kino_sentaku()?$filter=kbn_kino eq " + pageLangText.kinoZaikoDensoButtonHyojiKbn.number)
                // TODO: ここまで
            }).done(function (result) {
                // TODO: 画面の仕様に応じて以下のサービス呼び出し成功時の処理を変更してください。
                hinKubun = result.successes.hinKubun.d;
                kurabasho = result.successes.kurabasho.d;
                souko = result.successes.souko.d;
                soukoHyoji = result.successes.soukoHyoji.d;
                if (soukoHyoji.length > 0) {
                    soukoHyoji = soukoHyoji[0].kbn_kino_naiyo;
                } else {
                    soukoHyoji = "";
                }
                if (soukoHyoji == pageLangText.kinoSokoShiyoSuru.number) {
                    grid.jqGrid('showCol', "nm_soko");
                    grid.setColProp('nm_soko', { hidedlg: false });
                    $(".soko-label").css("display", "");
                }

                // 在庫伝送ボタンの表示・非表示の制御
                var zaikoDensoHyoji = pageLangText.kbnZaikoDensoButtonNashi.number;
                if (result.successes.zaikoDensoHyoji.d.length > 0) {
                    zaikoDensoHyoji = result.successes.zaikoDensoHyoji.d[0].kbn_kino_naiyo;
                }
                if (zaikoDensoHyoji == pageLangText.kbnZaikoDensoButtonNashi.number) {
                    // 在庫伝送ボタンを非表示にする
                    $(".retrasmit-inventory-button").css("display", "none");
                }

                var targetHinKbn = $(".search-criteria [name='hinKubun']");
                var targetKura = $(".search-criteria [name='kurabasho']");
                var targetSouko = $(".search-criteria [name='souko']");

                // 検索用ドロップダウンの設定
                App.ui.appendOptions(targetHinKbn, "kbn_hin", "nm_kbn_hin", hinKubun, true);
                App.ui.appendOptions(targetKura, "cd_kura", "nm_kura", kurabasho, true);
                App.ui.appendOptions(targetSouko, "cd_soko", "nm_soko", souko, true);

                // 当日日付を挿入
                $(".search-criteria [name='dt_zaiko']").datepicker("setDate", new Date());
                // 使用分にチェックを入れる
                $(".search-criteria [name='shiyoubun']").attr("checked", true);
                //$(".search-criteria [name='mishiyoubun']").attr("checked", true);
                $(".search-criteria [name='mishiyoubun']").attr("checked", false);

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
                var criteria = $(".search-criteria").toJSON();
                searchCondition = criteria;
                var zaikoKbn;
                if (criteria.select_kbn_zaiko == 0) {
                    zaikoKbn = pageLangText.ryohinZaikoKbn.text;
                } else {
                    zaikoKbn = pageLangText.horyuZaikoKbn.text;
                }



                var query = {
                    // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                    url: "../api/GenshizaiZaikoNyuryoku",
                    con_dt_zaiko: App.data.getDateTimeStringForQueryNoUtc(criteria.dt_zaiko),
                    con_kbn_hin: criteria.hinKubun,
                    con_hin_bunrui: criteria.hinBunrui,
                    con_kurabasho: criteria.kurabasho,
                    con_hinmei: encodeURIComponent(criteria.hinmei),
                    flg_shiyobun: getFlgShiyobun(criteria),
                    flg_zaiko: getFlgZaiko(criteria),
                    hasu_floor_decimal: 100,
                    hasu_ceil_decimal: 10,
                    lang: App.ui.page.lang,
                    shiyo_flag: pageLangText.shiyoMishiyoFlg.text,
                    mishiyo_flag: pageLangText.mishiyoMishiyoFlg.text,
                    tani_kg: pageLangText.kgKanzanKbn.text,
                    tani_L: pageLangText.lKanzanKbn.text,
                    genryo: pageLangText.genryoHinKbn.text,
                    shizai: pageLangText.shizaiHinKbn.text,
                    jikagenryo: pageLangText.jikaGenryoHinKbn.text,
                    // TODO: ここまで
                    //skip: querySetting.skip,
                    top: querySetting.top,
                    kbn_zaiko: zaikoKbn,
                    cd_soko: criteria.souko
                    //inlinecount: "allpages"
                }

                return query;
            };
            /// <summary>検索用：使用分/未使用分の状態を返却</summary>
            var getFlgShiyobun = function (criteria) {
                var flgShiyobun;
                if (!App.isUndefOrNull(criteria.shiyoubun) && !App.isUndefOrNull(criteria.mishiyoubun)) {
                    // 使用分、未使用分：両方にチェックがある場合
                    flgShiyobun = pageLangText.systemValueTwo.text;
                }
                else {
                    if (!App.isUndefOrNull(criteria.shiyoubun)) {
                        // 使用分
                        flgShiyobun = pageLangText.systemValueZero.text;
                    }
                    if (!App.isUndefOrNull(criteria.mishiyoubun)) {
                        // 未使用分
                        flgShiyobun = pageLangText.systemValueOne.text;
                    }
                }
                return flgShiyobun;
            };
            /// <summary>検索用：実在庫ありのみの状態を返却</summary>
            var getFlgZaiko = function (criteria) {
                var flgZaiko = pageLangText.systemValueZero.text;
                if (!App.isUndefOrNull(criteria.ari_nomi)) {
                    // 在庫ありのみ
                    flgZaiko = pageLangText.systemValueOne.text;
                }
                return flgZaiko;
            };

            /// <summary>フィルター条件の設定</summary>
            var createFilter = function () {
                var criteria = $(".search-criteria").toJSON(),
                    filters = [];
                searchCondition = criteria;
                // TODO: 画面の仕様に応じて以下のフィルター条件を変更してください。
                if (!App.isUndefOrNull(criteria.hinKubun) && criteria.hinKubun.length > 0) {
                    // 品区分
                    filters.push("kbn_hin eq " + criteria.hinKubun);
                }
                else {
                    // 品区分に選択がない場合、原料、資材、自家原料を取得
                    filters.push("(kbn_hin eq " + pageLangText.genryoHinKbn.text + " or kbn_hin eq "
                        + pageLangText.shizaiHinKbn.text + " or kbn_hin eq " + pageLangText.jikaGenryoHinKbn.text + ")");
                }
                if (!App.isUndefOrNull(criteria.hinBunrui)) {
                    // 品分類
                    filters.push("cd_bunrui eq '" + criteria.hinBunrui + "'");
                }
                if (!App.isUndefOrNull(criteria.kurabasho)) {
                    // 庫場所
                    filters.push("cd_kura eq '" + criteria.kurabasho + "'");
                }
                if (!App.isUndefOrNull(criteria.hinmei)) {
                    // 品名
                    filters.push("substringof('" + encodeURIComponent(criteria.hinmei) + "', " + hinmeiName + ") eq true");
                }
                if (!App.isUndefOrNull(criteria.shiyoubun) && !App.isUndefOrNull(criteria.mishiyoubun)) {
                    // 使用分、未使用分：両方にチェックがある場合
                    filters.push("(flg_mishiyo eq " + pageLangText.shiyoMishiyoFlg.text
                        + " or flg_mishiyo eq " + pageLangText.mishiyoMishiyoFlg.text + ")");
                }
                else {
                    if (!App.isUndefOrNull(criteria.shiyoubun)) {
                        // 使用分
                        filters.push("flg_mishiyo eq " + pageLangText.shiyoMishiyoFlg.text);
                    }
                    if (!App.isUndefOrNull(criteria.mishiyoubun)) {
                        // 未使用分
                        filters.push("flg_mishiyo eq " + pageLangText.mishiyoMishiyoFlg.text);
                    }
                }
                if (!App.isUndefOrNull(criteria.ari_nomi)) {
                    // 在庫ありのみ
                    filters.push("su_zaiko ne " + pageLangText.systemValueZero.text);
                    filters.push("su_keisan_zaiko ne " + pageLangText.systemValueZero.text);
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
                        pageLangText.nowLoading.text,
                //pageLangText.nowListLoading.text,
                        querySetting.skip + 1,
                        querySetting.top
                    )
                );
                App.ajax.webget(
                // WCF Data ServicesのODataシステムクエリオプションを生成
                //App.data.toODataFormat(query)
                    App.data.toWebAPIFormat(query)
                ).done(function (result) {
                    // データバインド
                    bindData(result);
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
                // 使用分か未使用分のいずれかは必須
                var shiyoubun = $(".search-criteria [name='shiyoubun']").attr("checked");
                var mishiyoubun = $(".search-criteria [name='mishiyoubun']").attr("checked");
                if (App.isUndefOrNull(shiyoubun) && App.isUndefOrNull(mishiyoubun)) {
                    App.ui.page.notifyAlert.message(pageLangText.checkboxCondition.text).show();
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
                querySetting.skip = querySetting.skip + result.length;
                querySetting.count = parseInt(result.length);

                // 検索結果が上限数を超えていた場合
                if (parseInt(result.length) > querySetting.top) {
                    // 上限数を超えた検索結果は削除する
                    result.splice(querySetting.top, result.length);
                    querySetting.skip = result.length;
                    App.ui.page.notifyAlert.message(pageLangText.limitOver.text).show();
                }
                // 上限数チェック：ここまで

                // グリッドの表示件数を更新
                grid.setGridParam({ rowNum: querySetting.skip });
                displayCount();
                // データバインド
                var currentData = grid.getGridParam("data").concat(result);
                grid.setGridParam({ data: currentData });
                // カラムの固定
                grid.setFrozenColumns().trigger('reloadGrid', [{ current: true }]);
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

            /// <summary>追加状態の変更セットに追加する変更データの設定を行います。</summary>
            /// <param name="newRow">新規行データ</param>
            var setCreatedChangeData = function (newRow) {
                // TODO: 画面の仕様に応じて以下の項目を変更してください。
                var changeData = {
                    "cd_hinmei": newRow.cd_hinmei,
                    //"dt_hizuke": App.date.startOfDay(searchCondition.dt_zaiko),
                    "dt_hizuke": App.data.getDateTimeStringForQueryNoUtc(App.date.localDate(searchCondition.dt_zaiko)),
                    "su_zaiko": newRow.su_zaiko,    // 実在庫数(使用単位)
                    "tan_tana": newRow.tan_tana,    // 単価
                    "dt_jisseki_zaiko": new Date(),
                    "dt_update": new Date(),
                    "cd_update": App.ui.page.user.Code
                };
                // TODO: ここまで

                return changeData;
            };
            /// <summary>更新状態の変更セットに追加する変更データの設定を行います。</summary>
            /// <param name="row">選択行</param>
            var setUpdatedChangeData = function (row) {
                var criteria = $(".search-criteria").toJSON();
                var cdSoko;
                if (criteria.select_kbn_zaiko == 0) {
                    zaikoKbn = pageLangText.ryohinZaikoKbn.text;
                }
                else {
                    zaikoKbn = pageLangText.horyuZaikoKbn.text;
                }
                if (soukoHyoji == pageLangText.kinoSokoShiyoSuru.number) {
                    // 「機能選択マスタ．倉庫使用区分．使用する」の場合
                    cdSoko = row.cd_soko;
                }
                else {
                    //cdSoko = "";
                    if (App.isUndefOrNull(row.cd_soko)) {
                        // 既存データに倉庫コードがなければ、倉庫マスタの先頭行の値を設定する
                        // ＃検索の段階で倉庫マスタの先頭行の値が設定されているが、念のため。
                        cdSoko = souko[0].cd_soko;
                    }
                    else {
                        cdSoko = row.cd_soko;
                    }
                }
                // TODO: 画面の仕様に応じて以下の項目を変更してください。
                var changeData = {
                    "cd_hinmei": row.cd_hinmei,
                    //"dt_hizuke": App.date.startOfDay(searchCondition.dt_zaiko),
                    "dt_hizuke": App.data.getDateTimeStringForQueryNoUtc(App.date.localDate(searchCondition.dt_zaiko)),
                    "su_zaiko": row.su_zaiko,    // 実在庫数(使用単位)
                    "tan_tana": row.tan_tana,    // 単価
                    "dt_jisseki_zaiko": new Date(),
                    //BRC quang.l 2022/04/21 #1699 Start -->
                    //"dt_update": new Date(),
                    "dt_update": row.dt_update,
                    //BRC quang.l 2022/04/21 #1699 End <--
                    "cd_update": App.ui.page.user.Code,
                    "kbn_zaiko": zaikoKbn,
                    "cd_soko": cdSoko,
                    //BRC quang.l 2022/04/21 #1699 Start -->
                    "tan_tana_bef": row.tan_tana_bef
                    //BRC quang.l 2022/04/21 #1699 End <--
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
            //        changeSet.addUpdated(selectedRowId, "cd_hinmei", value, changeData);
            //    }
            //    // TODO: ここまで
            //};

            /// <summary>品区分入力時のイベント処理を行います。</summary>
            var setHinBunrui = function () {
                // 品区分の値を元に、品分類コンボボックスの値を取得します。

                // 品分類の中身をクリア
                $(".search-criteria [name='hinBunrui'] option").remove();

                var criteria = $(".search-criteria").toJSON();
                var hinKbnParam = criteria.hinKubun;
                if (App.isUndefOrNull(hinKbnParam)) {
                    return;
                }
                App.deferred.parallel({
                    // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                    hinBunrui: App.ajax.webget("../Services/FoodProcsService.svc/ma_bunrui?$filter=flg_mishiyo eq "
                    + pageLangText.shiyoMishiyoFlg.text + " and kbn_hin eq " + hinKbnParam
                    + "&$orderby=cd_bunrui")
                    // TODO: ここまで
                }).done(function (result) {
                    // TODO: 画面の仕様に応じて以下のサービス呼び出し成功時の処理を変更してください。
                    hinBunrui = result.successes.hinBunrui.d;
                    var target = $(".search-criteria [name='hinBunrui']");
                    // 検索用ドロップダウンの設定
                    App.ui.appendOptions(target, "cd_bunrui", "nm_bunrui", hinBunrui, true);
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
            $(".search-criteria [name='hinKubun']").on("change", setHinBunrui);

            /// <summary>計算在庫コピー処理を行います。</summary>
            var copyKeisanZaiko = function () {
                var rowIds = grid.jqGrid('getDataIDs'),
                    cellName = "su_zaiko",
                    zaikoSuColIndex = grid.getColumnIndexByName(cellName),
                    rowId,
                    i, len,
                    keisanZaikoSu;

                // 計算在庫数(使用単位)を実在庫数(使用単位)にコピーします。
                for (i = 0, len = rowIds.length; i < len; i++) {
                    // 行ID取得
                    rowId = rowIds[i];

                    // 計算在庫数(使用単位)を取得
                    keisanZaikoSu = grid.getCell(rowId, "su_keisan_zaiko");

                    // 実在庫数(使用単位)に表示
                    grid.setCell(rowId, cellName, keisanZaikoSu);

                    // 関連項目の設定
                    setRelatedValue(rowId, cellName, keisanZaikoSu, zaikoSuColIndex);

                    // 更新状態の変更データの設定
                    changeData = setUpdatedChangeData(grid.getRowData(rowId));

                    // 実在庫数(使用単位)を保持
                    changeSet.addUpdated(rowId, cellName, changeData.su_zaiko, changeData);
                }
                //showConfirmDialog(pageLangText.endCopy.text);
            };

            /// <summary>計算在庫コピー前チェック処理を行います。</summary>
            var checkCopyKeisanZaiko = function (isCheckRec) {
                if (grid && isCheckRec && grid.getGridParam("records") === 0) {
                    return;
                }

                // 明細行の追加、削除、変更がないこと。
                if (isUpdate) {
                    App.ui.page.notifyInfo.message(
                        App.str.format(
                            pageLangText.criteriaChange.text
                            , pageLangText.meisai.text,
                            (isCheckRec ? pageLangText.copyKeisanZaiko.text : pageLangText.csvUpload.text)
                        )).show();
                    return false;
                }

                // 件削除件が検索時から変更されていないこと。
                if (changeCondition()) {
                    App.ui.page.notifyInfo.message(pageLangText.changeCondition.text).show();
                    return false;
                }

                return true;
            };
            $(".copy-keisan-zaiko-button").on("click", function () {
                if (checkCopyKeisanZaiko(true)) {
                    copyKeisanZaiko();
                }
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
                var zaikoDateSearchCreate = App.data.getDateTimeString(criteria.dt_zaiko);
                if (App.isUndefOrNull(searchCondition)) {
                    // 未検索時は初期表示値を設定（searchConditionがundefinedの為）
                    searchCondition = getSearchConDef();
                }
                zaikoDateSearchCon = App.data.getDateTimeString(searchCondition.dt_zaiko);

                if (zaikoDateSearchCreate != zaikoDateSearchCon) {
                    return true;
                }
                if (criteria.hinKubun != searchCondition.hinKubun) {
                    return true;
                }
                if (criteria.hinBunrui != searchCondition.hinBunrui) {
                    return true;
                }
                if (criteria.kurabasho != searchCondition.kurabasho) {
                    return true;
                }
                if (criteria.hinmei != searchCondition.hinmei) {
                    return true;
                }
                if (criteria.shiyoubun != searchCondition.shiyoubun) {
                    return true;
                }
                if (criteria.mishiyoubun != searchCondition.mishiyoubun) {
                    return true;
                }
                if (criteria.ari_nomi != searchCondition.ari_nomi) {
                    return true;
                }
                if (criteria.select_kbn_zaiko != searchCondition.select_kbn_zaiko) {
                    return true;
                }
                return false;
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
                                retValue = ret[i].Data.cd_hinmei;
                                // TODO: ここまで

                                if (isNaN(value) || value === retValue) {
                                    // TODO: 画面の仕様に応じて以下のロジックを変更します。
                                    unique = ids[j] + "_" + firstCol;

                                    // エラーメッセージの表示
                                    App.ui.page.notifyAlert.message(
                                        pageLangText.invalidation.text + ret[i].Message, unique).show();
                                    // 対象セルの背景変更
                                    grid.setCell(ids[j], firstCol, ret[i].Data.zan_id, { background: '#ff6666' });
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
                                value = parseInt(changeSet.changeSet.deleted[p].cd_hinmei, 10)
                                retValue = ret[i].Data.cd_hinmei;
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
                            retValue = ret.Updated[i].Requested.cd_hinmei;
                            // TODO: ここまで

                            if (isNaN(value) || value === retValue) {
                                // 更新状態の変更セットから変更データを削除
                                changeSet.removeUpdated(p);

                                // 他のユーザーによって削除されていた場合
                                var upCurrent = ret.Updated[i].Current;
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
                                    current.dt_hiduke = App.data.getDate(upCurrent.dt_hiduke);
                                    current.su_zaiko = App.data.getDate(upCurrent.su_zaiko);
                                    current.dt_update = App.data.getDate(upCurrent.dt_update);
                                    current.cd_update = upCurrent.cd_update;
                                    current.tan_tana = upCurrent.tan_tana;
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
                            value = parseInt(changeSet.changeSet.deleted[p].cd_hinmei, 10)
                            retValue = ret.Deleted[i].Requested.cd_hinmei;
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
                var saveUrl = "../api/GenshizaiZaikoNyuryoku";
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
            //        $(".save-button").on("click", showSaveConfirmDialog);
            $(".save-button").on("click", function () {
                // チェック処理：明細の有無
                var selectedRowId = getSelectedRowId();
                if (App.isUndefOrNull(selectedRowId)) {
                    return;
                }
                // 編集内容の保存
                saveEdit();

                // チェック処理
                // 変更セット内にバリデーションエラーがある場合は処理を抜ける
                if (!validateChangeSet()) {
                    return;
                }
                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();
                // 検索条件が変更されている場合は処理を抜ける
                if (changeCondition()) {
                    App.ui.page.notifyInfo.message(pageLangText.changeCondition.text).show();
                    return;
                }
                // 変更がない場合は処理を抜ける
                if (noChange()) {
                    App.ui.page.notifyInfo.message(pageLangText.noChange.text).show();
                    return;
                }
                //showSaveConfirmDialog();
                saveData();
            });

            //// 保存処理 -- End

            //// バリデーション -- Start

            // グリッドコントロール固有のバリデーション

            // TODO: 画面の仕様に応じて以下のカスタムバリデーション定義を変更してください。

            /// <summary>データベース問い合わせチェックを行います。</summary>
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

                // TODO：在庫入力のみの個別実装：数値しか入力がないこと前提
                // 数値以外が入力された場合、afterSaveCellでデフォルト値(0)を設定するのでチェック不要
                if (!isFinite(value)) {
                    return true;
                }
                // TODO：個別実装ここまで

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
                    if (changeSet.changeSet.updated[p].su_zaiko > 0) {
                        if (!changeSet.changeSet.updated.hasOwnProperty(p)) {
                            continue;
                        }
                        // カレントの行バリデーションを実行
                        if (!validateRow(p)) {
                            return false;
                        }
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
                    // 何か処理を行なっていた場合、ブラウザ既定の動作を無効にする
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

            /// <summary>計算在庫値での実在庫コピー処理を行います。</summary>
            var ZaikoCopy = function (e) {
                // 確認ダイアログのクローズ
                closeZaikocopyConfirmDialog();

                // ローディングの表示
                App.ui.loading.show(pageLangText.nowSaving.text);
                $("#list-loading-message").text(
                App.str.format(
                    pageLangText.nowLoading.text,
                    querySetting.skip + 1,
                    querySetting.top
                    )
                );

                // 抽出対象検索式設定
                var criteria = $(".search-criteria").toJSON();
                searchCondition = criteria;
                var zaikoKbn;
                if (criteria.select_kbn_zaiko == 0) {
                    zaikoKbn = pageLangText.ryohinZaikoKbn.text;
                } else {
                    zaikoKbn = pageLangText.horyuZaikoKbn.text;
                }

                var query_zaikocopy = {
                    // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                    url: "../api/GenshizaiZaikoNyuryokuZaikoCopy",
                    con_dt_zaiko: App.data.getDateTimeStringForQueryNoUtc(criteria.dt_zaiko),
                    con_kbn_hin: criteria.hinKubun,
                    con_hin_bunrui: criteria.hinBunrui,
                    con_kurabasho: criteria.kurabasho,
                    con_hinmei: encodeURIComponent(criteria.hinmei),
                    flg_shiyobun: getFlgShiyobun(criteria),
                    flg_zaiko: getFlgZaiko(criteria),
                    hasu_floor_decimal: 100,
                    hasu_ceil_decimal: 10,
                    lang: App.ui.page.lang,
                    shiyo_flag: pageLangText.shiyoMishiyoFlg.text,
                    mishiyo_flag: pageLangText.mishiyoMishiyoFlg.text,
                    tani_kg: pageLangText.kgKanzanKbn.text,
                    tani_L: pageLangText.lKanzanKbn.text,
                    genryo: pageLangText.genryoHinKbn.text,
                    shizai: pageLangText.shizaiHinKbn.text,
                    jikagenryo: pageLangText.jikaGenryoHinKbn.text,
                    top: querySetting.top,
                    kbn_zaiko: zaikoKbn,
                    cd_soko: criteria.souko,
                    cd_update: App.ui.page.user.Code
                    // TODO: ここまで
                };

                App.ajax.webpost(
                    App.data.toWebAPIFormat(query_zaikocopy)
                ).done(function (result) {
                    // 検索前の状態に初期化
                    clearState();
                    //App.ui.page.notifyInfo.message(pageLangText.successMessage.text).show();
                    // データ検索
                    searchItems(new query());
                }).fail(function (result) {
                    // データ変更エラーハンドリングを行います。
                    handleSaveDataError(result);
                }).always(function () {
                    // ローディングの終了
                    App.ui.loading.close();
                });
            }
            /// <summary>在庫伝送の処理を行います。</summary>
            var RetrasmitInventory = function () {
                // 在庫伝送確認ダイアログのクローズ
                closeRetrasmitInventoryConfirmDialog();
                // 検索条件取得
                var criteria = $(".search-criteria").toJSON();
                // ローディング開始
                App.ui.loading.show(pageLangText.nowProgressing.text);
                // 在庫伝送処理を行うリクエストを作成
                var query_retrasmitInventory = {
                    url: "../api/GenshizaiZaikoNyuryokuZaikoRetrasmit",
                    con_dt_zaiko: App.data.getDateTimeStringForQueryNoUtc(criteria.dt_zaiko),

                    kbnCreate: pageLangText.kbnCreate.number,
                    kbnUpdate: pageLangText.kbnUpdate.number,
                    kbnDelete: pageLangText.kbnDelete.number,
                    flg_true: pageLangText.flg_true.number,
                    flg_false: pageLangText.flg_false.number,
                    kbnGenryo: pageLangText.kbnGenryo.number,
                    kbnShizai: pageLangText.kbnShizai.number,
                    kbnJikagen: pageLangText.kbnJikagen.number,
                    kbnZaiko: pageLangText.kbnZaiko.number,

                }

                App.ajax.webpostSync(
                    App.data.toWebAPIFormat(query_retrasmitInventory)
                ).done(function (result) {
                    // 検索前の状態に初期化
                    clearState();
                    //                    showCompleteDialog(
                    //                        App.str.format(
                    //                            pageLangText.retrasmittingCompletion.text, 
                    //                            App.data.getDateString(criteria.dt_zaiko, true)));
                    // 在庫伝送完了ダイアログを表示する
                    showCompleteDialog(
                        App.str.format(
                            pageLangText.trasmittingCompletion.text,
                        App.data.getDateString(criteria.dt_zaiko, true)));
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                    App.ui.loading.close();
                    return false;
                }).always(function () {
                    // ローディングの終了
                    App.ui.loading.close();
                    return true;
                });
            }

            /// <summary>コンテンツのリサイズを行います。</summary>
            var resizeContents = function (e) {
                var container = $(".content-container"),
                    searchPart = $(".search-criteria"),
                    resultPart = $(".result-list"),
                    resultPartHeader = resultPart.find(".part-header"),
                    resultPartCommands = resultPart.find(".item-command"),
                    resultPartStyle = resultPart[0].currentStyle || document.defaultView.getComputedStyle(resultPart[0], "");

                //resultPart.height(container[0].clientHeight - searchPart[0].clientHeight - ((parseInt(resultPartStyle.marginTop, 10) * 3) || 0));
                resultPart.height(container[0].clientHeight - searchPart[0].clientHeight - ((parseInt(resultPartStyle.marginTop, 10) * 3) || 0) - 20);
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

            /// <summary>確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".confirm-dialog .dlg-yes-button").on("click", closeConfirmDialog);

            // <summary>確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".confirm-dialog .dlg-no-button").on("click", closeConfirmDialog);

            // <summary>確認ダイアログの「OK」ボタンクリック時のイベント処理を行います。</summary>
            $(".confirm-dialog .dlg-ok-button").on("click", closeConfirmDialog);

            /// <summary>在庫コピー確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".zaikocopy-confirm-dialog .dlg-yes-button").on("click", ZaikoCopy);

            // <summary>在庫コピー確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".zaikocopy-confirm-dialog .dlg-no-button").on("click", closeZaikocopyConfirmDialog);

            // <summary>在庫伝送確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".retrasmitinventory-confirm-dialog .dlg-yes-button").on("click", RetrasmitInventory);

            // <summary>在庫伝送確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".retrasmitinventory-confirm-dialog .dlg-no-button").on("click", closeRetrasmitInventoryConfirmDialog);

            // <summary>在庫伝送完了ダイアログの「閉じる」ボタンクリック時のイベント処理を行います。</summary>
            $(".complete-dialog .dlg-close-button").on("click", closeCompleteDialog);

            // <summary>在庫伝送エラーダイアログの「閉じる」ボタンクリック時のイベント処理を行います。</summary>
            $(".error-dialog .dlg-close-button").on("click", closeErrorDialog);

            /// <summary>データに変更があり、未保存の状態でページを離れる際に確認を行います。</summary>
            //別画面に遷移したりするときに実行する関数の定義
            var onBeforeUnload = function () {
                //データを変更したかどうかは各画面でチェックし、保持する
                if (isUpdate) {
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
                if (isUpdate) {
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
               // App.ui.loading.show(pageLangText.nowProgressing.text);
                printExcel();
               //App.ui.loading.close();
                //App.ui.page.notifyInfo.message(pageLangText.successExcel.text).show();
            };
            /// <summary>Excelファイル出力を行います。</summary>
            var printExcel = function (e) {

                // 選択なしまたは入力なしの場合、「未選択」を設定する
                var container = $(".search-criteria").toJSON(),
                    hinKbnName = pageLangText.noSelectConditionExcel.text;
                var zaikoKbn;
                if (container.select_kbn_zaiko == 0) {
                    zaikoKbn = pageLangText.ryohinZaikoKbn.text;
                }
                else {
                    zaikoKbn = pageLangText.horyuZaikoKbn.text;
                }
                if (!App.isUndefOrNull(container.hinKubun)) {
                    hinKbnName = $("#condition-hinKubun option:selected").text();
                }
                var hinBunruiName = pageLangText.noSelectConditionExcel.text;
                if (!App.isUndefOrNull(container.hinBunrui)) {
                    hinBunruiName = $("#condition-hinBunrui option:selected").text();
                }
                var kurabashoName = pageLangText.noSelectConditionExcel.text;
                if (!App.isUndefOrNull(container.kurabasho)) {
                    kurabashoName = $("#condition-kurabasho option:selected").text();
                }
                var hinName = pageLangText.noSelectConditionExcel.text;
                if (!App.isUndefOrNull(container.hinmei)) {
                    hinName = container.hinmei;
                }
                var shiyoubun = pageLangText.noSelectConditionExcel.text;
                if (!App.isUndefOrNull(container.shiyoubun)) {
                    shiyoubun = pageLangText.onCheckBoxExcel.text;
                }
                var mishiyoubun = pageLangText.noSelectConditionExcel.text;
                if (!App.isUndefOrNull(container.mishiyoubun)) {
                    mishiyoubun = pageLangText.onCheckBoxExcel.text;
                }
                var ariNomi = pageLangText.noSelectConditionExcel.text;
                if (!App.isUndefOrNull(container.ari_nomi)) {
                    ariNomi = pageLangText.onCheckBoxExcel.text;
                }
                var sokoName = pageLangText.noSelectConditionExcel.text;
                if (!App.isUndefOrNull(container.souko)) {
                    sokoName = $("#condition-souko option:selected").text();
                }
                // 検索用
                var flgShiyobun = getFlgShiyobun(container),
                    flgZaiko = getFlgZaiko(container),
                    zaikoDate = App.data.getDateTimeStringForQueryNoUtc(container.dt_zaiko);

                // 出力用の情報を設定
                var query = {
                    url: "../api/GenshizaiZaikoNyuryokuExcel",
                    // 検索用
                    con_dt_zaiko: App.data.getDateTimeStringForQueryNoUtc(container.dt_zaiko),
                    con_kbn_hin: container.hinKubun,
                    con_hin_bunrui: container.hinBunrui,
                    con_kurabasho: container.kurabasho,
                    con_hinmei: encodeURIComponent(container.hinmei),
                    flg_shiyobun: flgShiyobun,
                    flg_zaiko: flgZaiko,
                    hasu_floor_decimal: 100,
                    hasu_ceil_decimal: 10,
                    cd_soko: container.souko,
                    // ヘッダー用
                    lang: App.ui.page.lang,
                    hinKubunName: encodeURIComponent(hinKbnName),
                    hinBunruiName: encodeURIComponent(hinBunruiName),
                    kurabashoName: encodeURIComponent(kurabashoName),
                    shiyoubun: encodeURIComponent(shiyoubun),
                    mishiyoubun: encodeURIComponent(mishiyoubun),
                    ariNomi: encodeURIComponent(ariNomi),
                    userName: encodeURIComponent(App.ui.page.user.Name),
                    today: App.data.getDateTimeStringForQuery(new Date(), true), // 出力日時用(サーバー時間だとズレがあるので画面で取得したシステム日付を渡す)
                    kbn_zaiko: zaikoKbn,
                    sokoName: encodeURIComponent(sokoName)
                };

                // 処理中を表示する
                App.ui.loading.show(pageLangText.nowProgressing.text);
                var url = App.data.toWebAPIFormat(query);

                window.open(url, '_parent');
                // Cookieを監視する
                onComplete();
            };
            /// <summary>Excelボタンクリック時のイベント処理を行います。</summary>
            $(".excel-button").on("click", function () {
                //// 出力前チェック ////
                // 検索条件の必須チェック
                var result = $(".part-body .item-list").validation().validate();
                if (result.errors.length) {
                    return;
                }
                // 使用分か未使用分のいずれかは必須
                var shiyoubun = $(".search-criteria [name='shiyoubun']").attr("checked");
                var mishiyoubun = $(".search-criteria [name='mishiyoubun']").attr("checked");
                if (App.isUndefOrNull(shiyoubun) && App.isUndefOrNull(mishiyoubun)) {
                    App.ui.page.notifyAlert.message(pageLangText.checkboxCondition.text).show();
                    return;
                }
                // 明細に変更がないこと
                if (isUpdate) {
                    App.ui.page.notifyInfo.message(pageLangText.excelChangeMeisai.text).show();
                    return;
                }

                // 出力処理へ
                downloadOverlay();
            });

            $(".csv-upload-button").on("click", function () {
                if (checkCopyKeisanZaiko(false)) {


                    var criteria = $(".search-criteria").toJSON();
                    var zaikoKbn, params, option;

                    // 在庫区分の決定
                    if (criteria.select_kbn_zaiko == 0) {
                        zaikoKbn = pageLangText.ryohinZaikoKbn.text;
                    }
                    else {
                        zaikoKbn = pageLangText.horyuZaikoKbn.text;
                    }

                    // 引数
                    params = {
                        con_dt_zaiko: App.data.getDateTimeStringForQueryNoUtc(criteria.dt_zaiko)
                        , kbn_zaiko: zaikoKbn
                        , cd_soko: criteria.souko
                        , lit_hinCode: pageLangText.cd_hinmei.text
                        , lit_zaikoNonyu: pageLangText.jitsuzaiko_nonyu.text.replace(/<br>/, "")
                        , lit_zaikohasuNonyu: pageLangText.jitsuzaiko_hasu.text.replace(/<br>/, "")
                        , lit_zaikoShiyo: pageLangText.su_zaiko.text.replace(/<br>/, "")
                        , lit_zaikoDate: pageLangText.dt_kakutei_zaiko.text.replace(/<br>/, "")
                        //BRC t.Sato 2021/03/11 Start -->
                        //, lit_tanaTank: pageLangText.tanka.text
                        , lit_tanaTank: pageLangText.tan_tana.text
                        //BRC t.Sato 2021/03/11 End <--
                    }

                    option = {
                        workId: "1"
                        , params: params
                    };
                    csvUpDialog.draggable(true);
                    csvUpDialog.dlg("open", option);
                }
            });

            /// <summary>メニューボタンクリック時のイベント処理を行います。</summary>
            var backToMenu = function () {
                // IEバグによる例外発生をキャッチします。例外発生時は何もしません。
                try {
                    document.location = pageLangText.menuPath.url;
                }
                catch (e) {
                    // なにもしない
                }
            };
            /// <summary>メニューボタンクリック時のイベント処理を行います。</summary>
            $(".menu-button").on("click", backToMenu);

            //Cookieを1秒ごとにチェックする
            var onComplete = function () {
                if (app_util.prototype.getCookieValue(pageLangText.genshizaiZaikoNyuryokuCookie.text) == pageLangText.checkCookie.text) {
                    app_util.prototype.deleteCookie(pageLangText.genshizaiZaikoNyuryokuCookie.text);
                    //ローディング終了
                    App.ui.loading.close();
                }
                else {
                    // 再起してCookieが作成されたか監視
                    setTimeout(onComplete, 1000);
                }
            };

            /// <summary>在庫コピー処理前チェック処理を行います。</summary>
            var checkZaikoCopy = function (e) {
                //明細行が追加／変更／削除されていないこと
                // 明細に変更がないこと
                if (isUpdate) {
                    App.ui.page.notifyInfo.message(pageLangText.zaikocopyChangeMeisai.text).show();
                    return false;
                }

                //検索時の検索条件が変更されていないこと。
                if (changeCondition()) {
                    App.ui.page.notifyInfo.message(pageLangText.changeCondition.text).show();
                    return false;
                }
                return true;
            }

            /// <summary>在庫コピーボタンクリック時のイベント処理を行います。</summary>
            $(".zaiko-copy-button").on("click", function () {
                if (checkZaikoCopy() == true) {
                    showZaikocopyConfirmDialog();
                }
            });

            //            /// <summary>在庫再伝送処理前チェック処理を行います。</summary>
            //            var checkRetrasmitInventory = function (criteria) {
            //                // 検索条件が変更されている場合は処理を抜ける
            //                if (changeCondition()) {
            //                    App.ui.page.notifyInfo.message(pageLangText.changeCondition.text).show();
            //                    return false;
            //                }

            //                // 在庫再伝送のデータない場合は処理を抜ける
            //                var _query1 = {
            //                    url: "../Services/FoodProcsService.svc/tr_sap_getsumatsu_zaiko_denso_taisho_zen",
            //                    filter: "dt_tanaoroshi eq DateTime'" + App.data.getDateTimeStringForQueryNoUtc(criteria.dt_zaiko) +
            //                                "'", top: 1
            //                };
            //                var isChecked = true;

            //                App.ajax.webgetSync(
            //                    App.data.toODataFormat(_query1)
            //                ).done(function (result) {
            //                    if (result.d.length == 0) {
            //                        isChecked = false;
            //                        App.ui.page.notifyAlert.message(
            //                            App.str.format(
            //                                pageLangText.noDataRetrasmit.text,
            //                                App.data.getDateString(criteria.dt_zaiko, true))).show();
            //                        App.ui.loading.close();

            //                    }
            //                }).fail(function (result) {
            //                    isChecked = false;
            //                    App.ui.page.notifyAlert.message(result.message).show();
            //                });
            //                return isChecked;
            //            }
            /// <summary>在庫伝送処理前チェック処理を行います。</summary>
            //var checkTrasmitInventory = function (criteria) {
            //    var isChecked = true;
            //    // 検索条件が変更されている場合はfalseを返す
            //    if (changeCondition()) {
            //        App.ui.page.notifyInfo.message(pageLangText.changeCondition.text).show();
            //        isChecked = false;
            //    }
            //    return isChecked;
            //}

            /// <summary>在庫伝送ボタンクリック時のイベント処理を行います。</summary>                
            $(".retrasmit-inventory-button").on("click", function () {
                App.ui.page.notifyInfo.clear();
                App.ui.page.notifyAlert.clear();

                //// 伝送前チェック ////
                // 検索条件の必須チェック
                var result = $(".part-body .item-list").validation().validate();
                if (result.errors.length) {
                    return;
                }

                var isValid = false,
                    densoData;
                App.deferred.parallel({
                    densoData: App.ajax.webgetSync("../Services/FoodProcsService.svc/ma_batch_control?$filter=id_jobnet eq  '" + pageLangText.id_jobnet.text + "' and flg_shori eq " + pageLangText.flg_shori.text)
                }).done(function (result) {
                    densoData = result.successes.densoData.d;
                    if (densoData.length == 0) {
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
                if (isValid == false) {
                    showErrorDialog(pageLangText.trasmittingError.text);
                    return;
                }
                var criteria = $(".search-criteria").toJSON();
                //                //在庫再伝送処理を行います。     
                //                if (checkRetrasmitInventory(criteria) == true) {
                //                    showRetrasmitInventoryConfirmDialog(
                //                        App.str.format(
                //                            pageLangText.retrasmitInventoryConfirm.text, 
                //                            App.data.getDateString(criteria.dt_zaiko, true)));
                //                }
                // 在庫伝送処理を行います。
                //if (checkTrasmitInventory(criteria) == true) {
                    showRetrasmitInventoryConfirmDialog(
                    App.str.format(
                        pageLangText.trasmitInventoryConfirm.text,
                        App.data.getDateString(criteria.dt_zaiko, true)));
                //}
                return;
            });
        });
    </script>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <!-- 画面デザイン -- Start -->

    <!-- 検索条件と検索ボタン -->
    <div class="content-part search-criteria">
        <h3 class="part-header" data-app-text="searchCriteria"><a class="search-part-toggle" href="#"></a></h3>
        <div class="part-body">
            <ul class="item-list item-list-left">
                <!-- TODO: 画面の仕様に応じて以下の検索条件を変更してください。-->
                <li>
                    <label>
                        <span class="item-label" style="width: 70px" data-app-text="dt_zaiko"></span>
                        <input type="text" name="dt_zaiko" id="condition-date" />
                    </label>
                <br/>
                    <label>
                        <span class="item-label">&nbsp;</span> <span class="item-label" style="width: 123px">&nbsp;</span>
                    </label>
                <br/>
                    <label>
                        <input type="checkbox" name="shiyoubun" id="condition-shiyoubun" /><span class="item-label" style="width: 60px" data-app-text="shiyoubun"></span>
                    </label>
                    <label>
                        <input type="checkbox" name="mishiyoubun" id="condition-mishiyoubun" /><span class="item-label" style="width: 70px" data-app-text="mishiyoubun"></span>
                    </label>
                <br/>
                    <label>
                        <input type="checkbox" name="ari_nomi" /><span class="item-label" id="ari_nomi" data-app-text="ari_nomi"></span>
                    </label>
                <br/>
                    <label>
                        <input type="radio" name="select_kbn_zaiko" id="kbnRyohin" value="0" checked="checked" />
                        <span class="item-label" style="width: 30px" data-app-text="ryohin"></span>
                    </label>
                    <label>
                        <input type="radio" name="select_kbn_zaiko" id="kbnHoryu" value="1" />
                        <span class="item-label" style="width: 30px" data-app-text="horyu"></span>
                    </label>
                </li>

            </ul>
            <ul class="item-list item-list-right">
                <li>
                    <label>
                        <span class="item-label" style="width: 90px" data-app-text="hinKubun"></span>
                        <select name="hinKubun" id="condition-hinKubun">
                        </select>
                    </label>
                </li>
                <li>
                    <label>
                        <span class="item-label" style="width: 90px" data-app-text="hinBunrui"></span>
                        <select name="hinBunrui" id="condition-hinBunrui">
                        </select>
                    </label>
                </li>
                <li>
                    <label>
                        <span class="item-label" style="width: 90px" data-app-text="kurabasho"></span>
                        <select name="kurabasho" id="condition-kurabasho">
                        </select>
                    </label>
                </li>
                <li>
                    <label>
                        <span class="item-label soko-label" style="width: 90px; display:none" data-app-text="soko"></span>
                        <select class="soko-label" name="souko" id="condition-souko" style="display:none" >
                        </select>
                    </label>
                </li>
                <li>
                    <label>
                        <span class="item-label" style="width: 90px" data-app-text="hinmei"></span>
                        <input type="text" style="width: 262px" name="hinmei" maxlength="50" />
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
<!--                <button type="button" class="copy-keisan-zaiko-button" data-app-operation="copyKeisanZaiko"><span class="icon"></span><span data-app-text="copyKeisanZaiko"></span></button> -->
            </div>
            <div style="text-align: right">
                <span class="item-label" data-app-text="totalKingaku" style="width:150px;"></span>
                <span class="item-label" id="total-kingaku" style="padding-right: 20px; width: 150px;"></span>
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
        <button type="button" class="csv-upload-button" name="csv-upload-button" data-app-operation="csvUpload">
            <!--<span class="icon"></span>-->
            <span data-app-text="csvUpload"></span>
        </button>
        <button type="button" class="zaiko-copy-button" name="zaiko-copy-button" data-app-operation="zaikoCopy">
            <!--<span class="icon"></span>-->
            <span data-app-text="zaikoCopy"></span>
        </button>
        <!--在庫伝送ボタン -->
        <button type="button" class="retrasmit-inventory-button" name="retrasmit-inventory-button" data-app-operation="retrasmitInventory">
            <!--<span class="icon"></span>-->
            <span data-app-text="retrasmitInventory"></span>
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
    <div class="seihin-dialog">
    </div>
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
            <div class="command" style="position: absolute; left: 10px; top: 5px; display: none;">
                <button class="dlg-yes-button" name="dlg-yes-button" data-app-text="yes"></button>
            </div>
            <div class="command" style="position: absolute; right: 5px; top: 5px; display: none;">
                <button class="dlg-no-button" name="dlg-no-button" data-app-text="no"></button>
            </div>
            <div class="command" style="position: absolute; right: 5px; top: 5px">
                <button class="dlg-ok-button" name="dlg-ok-button" data-app-text="yes"></button>
            </div>
        </div>
    </div>
    <div class="csv-upload-dialog">
	</div>
    <div class="zaikocopy-confirm-dialog" style="display: none;">
        <div class="dialog-header">
            <h4 data-app-text="confirmTitle"></h4>
        </div>
        <div class="dialog-body" style="padding: 10px; width: 100%;">
            <div class="part-body">
                <span data-app-text="zaikocopyConfirm"></span>
            </div>
        </div>
        <div class="dialog-footer">
            <div class="command" style="position: absolute; left: 10px; top: 5px;">
                <button class="dlg-yes-button" name="dlg-yes-button" data-app-text="yes"></button>
            </div>
            <div class="command" style="position: absolute; right: 5px; top: 5px;">
                <button class="dlg-no-button" name="dlg-no-button" data-app-text="no"></button>
            </div>
        </div>
    </div>
    <!-- 在庫伝送確認ダイアログ -->
    <div class="retrasmitinventory-confirm-dialog" style="display: none;">
        <div class="dialog-header">
            <h4 data-app-text="confirmTitle"></h4>
        </div>
        <div class="dialog-body" style="padding: 10px; width: 100%;">
            <div class="part-body">
                <span data-app-text="retrasmitInventoryConfirm"></span>
            </div>
        </div>
        <div class="dialog-footer">
            <div class="command" style="position: absolute; left: 10px; top: 5px;">
                <button class="dlg-yes-button" name="dlg-yes-button" data-app-text="yes"></button>
            </div>
            <div class="command" style="position: absolute; right: 5px; top: 5px;">
                <button class="dlg-no-button" name="dlg-no-button" data-app-text="no"></button>
            </div>
        </div>
    </div>
    <!-- 在庫伝送完了ダイアログ -->
    <div class="complete-dialog" style="display: none;">
        <div class="dialog-header">
            <h4 data-app-text="confirmTitle"></h4>
        </div>
        <div class="dialog-body" style="padding: 10px; width: 100%;">
            <div class="part-body">
                <span data-app-text="retrasmittingCompletion"></span>
            </div>
        </div>
        <div class="dialog-footer">
            <div class="command-detail" style="position: absolute; left: 10px; top: 5px">
                <button class="dlg-close-button" name="dlg-close-button" data-app-text="close"></button>
            </div>
        </div>
    </div>
    <!-- 在庫伝送エラーダイアログ -->
    <div class="error-dialog" style="display: none;">
        <div class="dialog-header">
            <h4 data-app-text="confirmTitle"></h4>
        </div>
        <div class="dialog-body" style="padding: 10px; width: 100%;">
            <div class="part-body">
                <span data-app-text="retrasmittingError"></span>
            </div>
        </div>
        <div class="dialog-footer">
            <div class="command-detail" style="position: absolute; left: 10px; top: 5px">
                <button class="dlg-close-button" name="dlg-close-button" data-app-text="close"></button>
            </div>
        </div>
    </div>
    <!-- TODO: ここまで  -->

    <!-- 画面デザイン -- End -->
</asp:Content>
