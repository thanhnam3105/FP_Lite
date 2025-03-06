<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="GenryoShiyoryoKeisan.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.GenryoShiyoryoKeisan" %>

<asp:Content ID="Content1" ContentPlaceHolderID="IncludeContent" runat="server">
    <script src="<%=ResolveUrl("~/Resources/pages/pagedata-genryoshiyoryokeisan." + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
    <script src="<%=ResolveUrl("~/Resources/grid/grid.locale-" + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
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
        
        .search-criteria select
        {
            width: 20em;
        }
        
        .search-criteria .item-label
        {
            width: 10em;
        }
        .ui-jqgrid .ui-jqgrid-htable TH DIV
        {
            overflow: hidden;
            position: relative;
            height: auto;            
        }
        .ui-jqgrid .ui-jqgrid-htable TH.ui-th-column
        {
            vertical-align: middle;
        }
        /* TODO：ここまで */

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
                isFirst = true, // 初回フラグ
                searchCondition;

            // 英語化対応　言語によって幅を調節
            $(".search-criteria .item-label").css("width", pageLangText.each_lang_width.number);

            // グリッドコントロール固有の変数宣言
            var grid = $("#item-grid"),
                lastScrollTop = 0,
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
                changeSet = new App.ui.page.changeSet(),
                firstCol = 1,
                dtShukkoCol = 1,
                cdHinmeiCol = 2,
                wtShiyoZanCol = 7,
            //kuradashiSuCol = 9,
                kuradashiSuCol = 11
            kuradashiHasuCol = 12,
                duplicateCol = 999,
                currentRow = 0,
                currentCol = firstCol;

            // TODO: ここまで

            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            var bunruiCode, // 検索条件のコンボボックス：分類
                hinKubun,   // 検索条件のコンボボックス：品区分
                Kbnshokuba, // 機能選択(EXCEL(職場別) 非表示:0 表示:1)
            // 多言語対応にしたい項目を変数にする
                hinmeiName = 'nm_hinmei_' + App.ui.page.lang,
                loading;
            // TODO：ここまで

            // ダイアログ固有の変数宣言
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            var saveConfirmDialog = $(".save-confirm-dialog"),
                searchConfirmDialog = $(".search-confirm-dialog"),
                shokubaSentakuDialog = $(".shokuba-sentaku-dialog");
            // TODO：ここまで

            //// 変数宣言 -- End

            //// コントロール定義 -- Start

            // ダイアログ固有のコントロール定義
            saveConfirmDialog.dlg();
            searchConfirmDialog.dlg();

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
            var datePickerFormat = pageLangText.dateFormatUS.text,
                newDateFormat = pageLangText.dateNewFormatUS.text;
            if (App.ui.page.langCountry !== 'en-US') {
                datePickerFormat = pageLangText.dateFormat.text;
                newDateFormat = pageLangText.dateNewFormat.text;
            }
            // TODO：画面の仕様に応じて以下の datepicker の設定を変更してください。
            $("#dt_hiduke_search").on("keyup", App.data.addSlashForDateString);
            $("#dt_hiduke_search").datepicker({ dateFormat: datePickerFormat });
            // TODO：ここまで

            // グリッドコントロール固有のコントロール定義
            grid.jqGrid({
                colNames: [
                    pageLangText.dt_shukko.text + pageLangText.requiredMark.text
                    , pageLangText.cd_hinmei.text
                    , pageLangText.nm_hinmei.text
                    , pageLangText.nm_nisugata_hyoji.text
                    , pageLangText.nm_tani.text
                    , pageLangText.su_shiyo_sum.text
                    , pageLangText.wt_shiyo_zan.text + pageLangText.requiredMark.text
                    , pageLangText.qty_hitsuyo.text
                    , pageLangText.cd_tani_kuradashi.text
                    , pageLangText.nm_tani_kuradashi.text
                    , pageLangText.su_kuradashi_su.text
                    , pageLangText.su_kuradashi_hasu.text
                    , pageLangText.flg_kakutei.text
                    , pageLangText.kbn_status.text
                    , pageLangText.nm_bunrui.text
                    , "su_iri"
                    , "wt_ko"
                    , "ritsu_hiju"
                    , "dt_create"
                ],
                colModel: [
                    { name: 'dt_shukko', width: 110, editable: true,
                        formatter: "date",
                        formatoptions: {
                            srcformat: newDateFormat
                            , newformat: newDateFormat
                        },
                        editoptions: {
                            dataInit: function (el) {
                                $(el).on("keyup", App.data.addSlashForDateString);
                                $(el).datepicker({ dateFormat: datePickerFormat
                                    , minDate: new Date(1975, 1 - 1, 1)
                                    , maxDate: "+1y"
                                    , onClose: function (dateText, inst) {
                                        // カレンダーを閉じた後は他のセルにフォーカスを当てる
                                        // ＃セルの見た目が編集状態のままとなっている為、tabなどでセル移動できそうで紛らわしい
                                        var idNum = grid.getGridParam("selrow");
                                        $("#" + idNum + " td:eq('" + cdHinmeiCol + "')").click();
                                    }
                                });
                            }
                        },
                        unformat: unformatDate
                    },
                    { name: 'cd_hinmei', width: 120, editable: false, sorttype: "text" },
                    { name: hinmeiName, width: 220, editable: false, sorttype: "text" },
                    { name: 'nm_nisugata_hyoji', width: 120, editable: false, sorttype: "text" },
                    { name: 'nm_tani', width: 80, editable: false, sorttype: "text" },
                    { name: 'su_shiyo_sum', width: 120, editable: false, align: "right", sorttype: "float",
                        formatter: 'number',
                        formatoptions: {
                            decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 3, defaultValue: "0"
                        }
                    },
                    { name: 'wt_shiyo_zan', width: 120, editable: true, align: "right", sorttype: "float",
                        editoptions: { maxlength: 11 },
                        formatter: 'number',
                        formatoptions: {
                            decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 3, defaultValue: ""
                        }
                    },
                    { name: 'qty_hitsuyo', width: 120, editable: false, align: "right", sorttype: "float",
                        formatter: 'number',
                        formatoptions: {
                            decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 3, defaultValue: ""
                        }
                    },
                    { name: 'cd_tani_nonyu', hidden: true, hidedlg: true },
                    { name: 'nm_tani_kuradashi', width: 70, editable: false, sorttype: "text" },
                    { name: 'su_kuradashi', width: 90, editable: true, align: "right", sorttype: "float",
                        formatter: 'number',
                        formatoptions: {
                            decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 0, defaultValue: "0"
                        }
                    },
                    { name: 'su_kuradashi_hasu', width: 90, editable: true, align: "right", sorttype: "float",
                        hidden: true, hidedlg: false,
                        formatter: commaReplace, unformat: unCommaReplace,
                        formatoptions: { decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 0, defaultValue: "0" }
                    },
                    { name: 'flg_kakutei', width: pageLangText.flg_kakutei_width.number, editable: true, hidden: false, edittype: 'checkbox',
                        align: 'center', editoptions: { value: "1:0" }, formatter: 'checkbox',
                        formatoptions: { disabled: false }, classes: 'not-editable-cell'
                    },
                    { name: 'kbn_status', width: 90, editable: false, sorttype: "text", formatter: getStatus },
                    { name: 'nm_bunrui', width: 200, editable: false, sorttype: "text" },
                    { name: 'su_iri', width: 0, hidden: true, hidedlg: true },
                    { name: 'wt_ko', width: 0, hidden: true, hidedlg: true },
                    { name: 'ritsu_hiju', width: 0, hidden: true, hidedlg: true },
                    { name: 'dt_create', width: 0, hidden: true, hidedlg: true }
                ],
                datatype: "local",
                shrinkToFit: false,
                multiselect: false,
                rownumbers: true,
                cellEdit: true,
                cellsubmit: 'clientArray',
                loadComplete: function () {
                    // 変数宣言
                    var ids = grid.jqGrid('getDataIDs'),
                        criteria = $(".search-criteria").toJSON();

                    for (var i = 0; i < ids.length; i++) {
                        var id = ids[i];
                        /*
                        // 必要量の計算処理：庫出依頼数の計算で使用するため、先に計算する
                        setRelatedValue(id, "wt_shiyo_zan", grid.getCell(id, "wt_shiyo_zan"), wtShiyoZanCol);
                        // 検索後の初回のみ
                        if (isFirst) {
                        // 確定フラグにチェックがある場合、出庫日、前日残、庫出依頼数を操作不可とする
                        var flg = grid.getCell(id, "flg_kakutei");
                        if (flg == pageLangText.trueFlg.text) {
                        grid.jqGrid('setCell', id, 'dt_shukko', '', 'not-editable-cell');
                        grid.jqGrid('setCell', id, 'wt_shiyo_zan', '', 'not-editable-cell');
                        grid.jqGrid('setCell', id, 'su_kuradashi', '', 'not-editable-cell');
                        }

                        // ステータスが「済」の場合、確定フラグを操作不可とする
                        var status = grid.getCell(id, "kbn_status");
                        //if (status == pageLangText.jushinStatusKbnSumi.text) {
                        if (status == pageLangText.arranged.text) {
                        $(".jqgrow:eq(" + (i) + ") td:eq(" + grid.getColumnIndexByName("flg_kakutei") + ") input:checkbox").attr("disabled", true);
                        }

                        // データが無い場合、庫出依頼数を計算する
                        if (grid.jqGrid('getCell', id, 'dt_create') == "") {
                        var kuradashiIrai = calcSuKuradashi(id);
                        grid.setCell(id, "su_kuradashi", kuradashiIrai);
                        }
                        }*/
                        // 必要量の計算処理：庫出依頼数の計算で使用するため、先に計算する
                        setRelatedValue(id, "wt_shiyo_zan", grid.getCell(id, "wt_shiyo_zan"), wtShiyoZanCol);

                        // 確定フラグにチェックがある場合、出庫日、前日残、庫出依頼数を操作不可とする
                        var flg = grid.getCell(id, "flg_kakutei");
                        if (flg == pageLangText.trueFlg.text) {
                            grid.jqGrid('setCell', id, 'dt_shukko', '', 'not-editable-cell');
                            grid.jqGrid('setCell', id, 'wt_shiyo_zan', '', 'not-editable-cell');
                            grid.jqGrid('setCell', id, 'su_kuradashi', '', 'not-editable-cell');
                            grid.jqGrid('setCell', id, 'su_kuradashi_hasu', '', 'not-editable-cell');
                        }

                        // ステータスが「済」の場合、確定フラグを操作不可とする
                        var status = grid.getCell(id, "kbn_status");
                        //if (status == pageLangText.jushinStatusKbnSumi.text) {
                        if (status == pageLangText.arranged.text) {
                            $(".jqgrow:eq(" + (i) + ") td:eq(" + grid.getColumnIndexByName("flg_kakutei") + ") input:checkbox").attr("disabled", true);
                        }

                        // データが無い場合、庫出依頼数を計算する
                        if (grid.jqGrid('getCell', id, 'dt_create') == "") {
                            var kuradashiIrai = calcSuKuradashi(id);
                            grid.setCell(id, "su_kuradashi", kuradashiIrai);
                        }

                        // 庫出依頼端数のformatterを初期表示で有効にするために端数をセット
                        grid.setCell(id, "su_kuradashi_hasu", grid.getCell(id, "su_kuradashi_hasu"));
                    }

                    // グリッドの先頭行選択
                    var idNum = grid.getGridParam("selrow");
                    if (idNum == null) {
                        $("#1 > td").click();
                    }
                    else {
                        $("#" + idNum).removeClass("ui-state-highlight").find("td").click();
                    }
                    isFirst = false;
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
                    // 出庫日の場合は、10時固定の変換処理をする
                    if (cellName == "dt_shukko") {
                        value = App.data.getDateTimeStringForQueryNoUtc(App.date.localDate(value));
                    }

                    // 関連項目の設定
                    setRelatedValue(selectedRowId, cellName, value, iCol);
                    // 変更データの変数設定
                    var changeData;
                    // 作成日を確認し、更新か新規かを切り分ける
                    if (grid.jqGrid('getCell', selectedRowId, 'dt_create')) {
                        ///// 更新
                        // 更新状態の変更データの設定
                        changeData = setUpdatedChangeData(grid.getRowData(selectedRowId));
                        // 更新状態の変更セットに変更データを追加
                        changeSet.addUpdated(selectedRowId, cellName, value, changeData);
                    }
                    else {
                        ///// 新規
                        // 追加状態のデータ設定
                        changeData = setCreatedChangeData(grid.getRowData(selectedRowId));
                        // 追加状態の変更セットに変更データを追加
                        changeSet.addCreated(selectedRowId, changeData);
                    }
                    // 関連項目の設定を変更セットに反映
                    setRelatedChangeData(selectedRowId, cellName, value, changeData);
                }
            });
            grid.jqGrid('setGroupHeaders', {
                useColSpanStyle: true,
                groupHeaders: [
                    { startColumnName: 'su_kuradashi', numberOfColumns: 2, titleText: pageLangText.su_kuradashi_sum.text }
                ]
            });

            /// <summary>日付型のセルをunformatします</summary>
            function unformatDate(cellvalue, options) {
                var nbsp = String.fromCharCode(160);
                if (cellvalue == nbsp) {
                    return "";
                }
                return cellvalue;
            }

            // カンマ付与
            function commaReplace(cellval, opts, rowData) {
                var str;
                var op = $.extend({}, opts.integer);
                if (!App.isUndef(opts.colModel) && !App.isUndef(opts.colModel.formatoptions)) {
                    op = $.extend({}, op, opts.colModel.formatoptions);
                }
                if ($.fmatter.isEmpty(cellval)) {
                    str = op.defaultValue;
                }
                else {
                    str = $.fmatter.util.NumberFormat(cellval, op);
                }
                if (grid.getCell(opts.rowId, "cd_tani_nonyu") == pageLangText.kgKanzanKbn.text
                    || grid.getCell(opts.rowId, "cd_tani_nonyu") == pageLangText.lKanzanKbn.text) {

                    str = str.replace(/,/g, "");
                    if (str === "") {
                        return str;
                    }
                    if (str.length == 1) {
                        return ".00" + str;

                    } else if (str.length == 2) {
                        return ".0" + str;

                    } else {
                        return "." + str;
                    }
                }
                return str;
            };

            // カンマ除去
            function unCommaReplace(cellval, opts) {
                if (grid.getCell(opts.rowId, "cd_tani_nonyu") == pageLangText.kgKanzanKbn.text
                    || grid.getCell(opts.rowId, "cd_tani_nonyu") == pageLangText.lKanzanKbn.text) {

                    if (cellval != "") {
                        cellval = parseInt(cellval.replace(".", ""), 10).toString();
                    }
                    return cellval.replace(".", "");
                }
                else {
                    return cellval.replace(/,/g, "");
                }
            };

            /// <summary>ステータス区分による表示名称を取得</summary>
            /// <param name="cellvalue">ステータス区分</param>
            /// <param name="options">オプション</param>
            /// <param name="rowObject">行情報</param>
            function getStatus(cellvalue, options, rowObject) {
                var status = pageLangText.yet.text; // 未
                if (cellvalue == pageLangText.jushinStatusKbnSumi.text) {
                    status = pageLangText.arranged.text;    // 済
                }
                return status;
            }

            /// <summary>必要量の文字色を設定する。マイナスなら赤、それ以外は黒。</summary>
            /// <param name="rowId">対象ID</param>
            /// <param name="value">必要量</param>
            var setFontColor = function (rowId, value) {
                var target = "qty_hitsuyo";
                if (0 > parseFloat(value)) {
                    // 負の数
                    grid.setCell(rowId, target, '', { color: '#000000' });
                }
                else {
                    // 正の数
                    grid.setCell(rowId, target, '', { color: '#ff6666' });
                }
            };

            /// <summary>庫出依頼数の計算処理</summary>
            /// <param name="rowId">対象ID</param>
            var calcSuKuradashi = function (rodId) {
                var rowData = grid.getRowData(rodId);
                var su_iri = parseFloat(rowData.su_iri),
                    wt_ko = parseFloat(rowData.wt_ko),
                    qtyHitsuyo = parseFloat(rowData.qty_hitsuyo),
                    kuradashiIrai = 0;
                // 入数と個重量が0以上の場合、庫出依頼数を計算する
                if (su_iri > 0 && wt_ko > 0) {
                    // 明細/必要量 ÷ ([品名マスタ].[個重量] ｘ [品名マスタ].[入数])
                    var ko_iri = App.data.trimFixed(wt_ko * su_iri);
                    kuradashiIrai = App.data.trimFixed(qtyHitsuyo / ko_iri);

                    // 小数点第１位切り上げ
                    kuradashiIrai = Math.ceil(kuradashiIrai);

                    // 計算結果が0以下の場合は0を設定する
                    if (kuradashiIrai < 0) {
                        kuradashiIrai = 0;
                    }
                }

                return kuradashiIrai;
            };

            /// <summary>セルの関連項目を設定します。</summary>
            /// <param name="selectedRowId">選択行ID</param>
            /// <param name="cellName">列名</param>
            /// <param name="value">元となる項目の値</param>
            /// <param name="iCol">項目の列番号</param>
            var setRelatedValue = function (selectedRowId, cellName, value, iCol) {
                // TODO：画面の仕様に応じて以下の関連項目を設定を変更してください。
                //var row = grid.getRowData(selectedRowId);

                ///// 前日残
                if (cellName === "wt_shiyo_zan") {
                    // 必要量を計算する
                    var shiyoSum = parseFloat(grid.getCell(selectedRowId, "su_shiyo_sum")),
                        qtyHitsuyo = 0;

                    // 値が空白やnullの場合は0を設定する
                    var isNamber = App.isNumeric(shiyoSum);
                    if (App.isUndefOrNull(shiyoSum) || shiyoSum == "" || !isNamber) {
                        shiyoSum = 0;
                    }
                    isNamber = App.isNumeric(value);
                    if (App.isUndefOrNull(value) || value == "" || !isNamber) {
                        value = 0;
                    }

                    // 整数にしてから計算する(小数点第三位にする)
                    var shiyoZan = App.data.trimFixed(value * 1000);
                    shiyoSum = App.data.trimFixed(shiyoSum * 1000);
                    // 三位以下は切り捨て
                    shiyoZan = Math.floor(shiyoZan);
                    shiyoSum = Math.floor(shiyoSum);

                    // 必要量 = 使用予定量 - 前日残
                    qtyHitsuyo = App.data.trimFixed(shiyoSum - shiyoZan);

                    if (qtyHitsuyo != 0) {
                        // 小数点付きに戻す
                        qtyHitsuyo = App.data.trimFixed(qtyHitsuyo / 1000);
                    }

                    // 必要量をグリッドに設定
                    grid.setCell(selectedRowId, "qty_hitsuyo", qtyHitsuyo);

                    // 負の数となった場合、文字色を赤色に変更
                    setFontColor(selectedRowId, qtyHitsuyo);
                }
                // TODO：ここまで
            };

            /// <summary>チェックボックス操作時のグリッド値更新を行います</summary>
            $(document).on("click", "#item-grid .jqgrow td :checkbox", function () {
                // 参考：iRowにて記述する場合
                var iCol = $(this).parent("td").parent("tr").find("td").index($(this).parent("td")),
                    selectedRowId = $(this).parent("td").parent("tr").attr("id"),
                    cellName = grid.getGridParam("colModel")[iCol].name,
                    value;

                $("#" + selectedRowId).removeClass("ui-state-highlight").find("td:nth-child(" + firstCol + ")").click();    // 行選択

                // 更新状態の変更データの設定
                var changeData = setUpdatedChangeData(grid.getRowData(selectedRowId));

                value = changeData[cellName];

                // 作成日を確認し、更新か新規かを切り分ける
                if (grid.jqGrid('getCell', selectedRowId, 'dt_create')) {
                    ///// 更新
                    // 更新状態の変更データの設定
                    changeData = setUpdatedChangeData(grid.getRowData(selectedRowId));
                    // 更新状態の変更セットに変更データを追加
                    changeSet.addUpdated(selectedRowId, cellName, value, changeData);
                }
                else {
                    ///// 新規
                    // 追加状態のデータ設定
                    changeData = setCreatedChangeData(grid.getRowData(selectedRowId));
                    // 追加状態の変更セットに変更データを追加
                    changeSet.addCreated(selectedRowId, changeData);
                }
            });

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

            $("#dt_shukko_henko").datepicker({ dateFormat: datePickerFormat });
            $("#dt_shukko_henko").on("keyup", App.data.addSlashForDateString);
            var showCalender = function () {
                checkedRow = new Array();
                // 行が選択できなかったら、返却
                var selectedRowId = getSelectedRowId(false);
                if (App.isUndefOrNull(selectedRowId)) {
                    App.ui.loading.close();
                    return;
                }

                var hoge = $("#dt_shukko_henko").val();
                if (hoge == "") {
                    return;
                }
                // チェックされた行を取得する
                var ids = grid.jqGrid('getDataIDs')
                    , cnt = 0
                    , isOldDay = false;
                for (var i = 0; i < ids.length; i++) {
                    var id = ids[i];
                    var chk = grid.getCell(id, "flg_kakutei");
                    if (chk == "0") {
                        // コードに入力がなければSKIP
                        //var code = grid.getCell(id, "cd_hinmei");
                        //if (code != "") {
                        checkedRow[cnt] = id;
                        cnt++;
                    }
                }
                for (var i = 0; i < checkedRow.length; i++) {
                    var id = checkedRow[i];
                    grid.setCell(id, "dt_shukko", hoge);
                    // 変更データの変数設定
                    var changeData;
                    // 作成日を確認し、更新か新規かを切り分ける
                    if (grid.jqGrid('getCell', id, 'dt_create')) {
                        ///// 更新
                        // 更新状態の変更データの設定
                        changeData = setUpdatedChangeData(grid.getRowData(id));
                        // 更新状態の変更セットに変更データを追加
                        changeSet.addUpdated(id, "dt_shukko", App.data.getDateTimeStringForQueryNoUtc(App.date.localDate(hoge)), changeData);
                    }
                    else {
                        ///// 新規
                        // 追加状態のデータ設定
                        changeData = setCreatedChangeData(grid.getRowData(id));
                        // 追加状態の変更セットに変更データを追加
                        changeSet.addCreated(id, changeData);
                    }
                    // 関連項目の設定を変更セットに反映
                    setRelatedChangeData(id, "dt_shukko", hoge, changeData);
                }
            };
            /// <summary>グリッドの出庫日変更ボタンクリック時のイベント処理を行います。</summary>
            $(".shukkobi-button").on("click", showCalender);

            /// <summary>全チェック／解除処理</summary>
            var checkAll = function () {
                var ids = grid.jqGrid('getDataIDs');
                for (var i = 0; i < ids.length; i++) {
                    var id = ids[i];
                    var jushin = grid.jqGrid('getCell', id, 'kbn_status');
                    if (jushin != pageLangText.arranged.text) {
                        grid.setCell(id, 'flg_kakutei', 1);
                        // 変更データの変数設定
                        var changeData;
                        // 作成日を確認し、更新か新規かを切り分ける
                        if (grid.jqGrid('getCell', id, 'dt_create')) {
                            ///// 更新
                            // 更新状態の変更データの設定
                            changeData = setUpdatedChangeData(grid.getRowData(id));
                            // 更新状態の変更セットに変更データを追加
                            changeSet.addUpdated(id, "flg_kakutei", 1, changeData);
                        }
                        else {
                            ///// 新規
                            // 追加状態のデータ設定
                            changeData = setCreatedChangeData(grid.getRowData(id));
                            // 追加状態の変更セットに変更データを追加
                            changeSet.addCreated(id, changeData);
                        }
                        // 関連項目の設定を変更セットに反映
                        setRelatedChangeData(id, "flg_kakutei", 1, changeData);
                    }
                }
            };
            /// <summary>全チェックボタンクリック時のイベント処理を行います。</summary>
            $(".check-button").on("click", function (e) {
                checkAll();
            });
            //// コントロール定義 -- End

            //// 操作制御定義 -- Start

            // 操作制御定義を定義します。
            App.ui.pagedata.operation.applySetting(App.ui.page.user.Roles[0], App.ui.page.lang);

            //// 操作制御定義 -- End

            //// 事前データロード -- Start 

            // 画面アーキテクチャ共通の事前データロード
            App.deferred.parallel({
                loading: App.ui.loading.show(pageLangText.nowProgressing.text),
                // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                // 品区分：原料、資材、自家原料
                hinKubun: App.ajax.webget("../Services/FoodProcsService.svc/ma_kbn_hin?$filter=kbn_hin eq "
                    + pageLangText.genryoHinKbn.text + " or kbn_hin eq " + pageLangText.shizaiHinKbn.text
                    + " or kbn_hin eq " + pageLangText.jikaGenryoHinKbn.text + "&$orderby=kbn_hin"),
                //職場別
                Kbnshokuba: App.ajax.webget("../Services/FoodProcsService.svc/cn_kino_sentaku?$filter=kbn_kino eq " + pageLangText.Kbnshokuba.number)
                // TODO: ここまで
            }).done(function (result) {
                // TODO: 画面の仕様に応じて以下のサービス呼び出し成功時の処理を変更してください。
                hinKubun = result.successes.hinKubun.d;

                var targetHinKbn = $("#condition-kbn_hin");
                // 検索用ドロップダウンの設定
                App.ui.appendOptions(targetHinKbn, "kbn_hin", "nm_kbn_hin", hinKubun, true);

                // 当日日付を挿入
                $("#dt_hiduke_search").datepicker("setDate", new Date());

                // 初期表示時の検索条件を設定
                searchCondition = $(".search-criteria").toJSON();

                //職場別
                //if (result.successes.Kbnshokuba.d.length != 0) {
                //kinoKbn = result.successes.Kbnshokuba.d[0].kbn_kino_naiyo;
                //if (kinoKbn == pageLangText.KbnshokubaAri.number) {

                //  表示処理
                // $(".shokubabetsu-excel-button").css("display", false);
                //} else {
                // 非表示処理
                //(kinoKbn == pageLangText.KbnshokubaNashi.number)
                //$(".shokubabetsu-excel-button").css("display", "none");
                //}
                //}

                /// 庫出依頼職場表示切替区分の設定
                // 庫出依頼職場表示切替区分が取得できなかった場合
                if (result.successes.Kbnshokuba.d.length == 0) {

                    // 庫出依頼職場表示切替区分 0:非表示 を設定する
                    kinoKbn = 0;
                }
                else
                {
                    // 取得した機能区分内容を設定する
                    kinoKbn = result.successes.Kbnshokuba.d[0].kbn_kino_naiyo;
                }

                // 庫出依頼職場表示切替区分 0:非表示 の場合
                if (kinoKbn == pageLangText.KbnshokubaNashi.number) {

                    // 職場別Excelボタンを非表示にする
                    $(".shokubabetsu-excel-button").css("display", "none");

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
                var criteria = $(".search-criteria").toJSON();
                searchCondition = criteria;
                var query = {
                    // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                    url: "../api/ShiyoryoKeisan",
                    con_hizuke: App.data.getDateTimeStringForQueryNoUtc(criteria.dt_hiduke_search),
                    con_bunrui: criteria.bunruiCode,
                    hinKubun: criteria.kubunHin,
                    flg_yojitsu: getYojitsuFlag(criteria.dt_hiduke_search),
                    utc: -(new Date().getTimezoneOffset() / 60),
                    // TODO: ここまで
                    top: querySetting.top
                }
                return query;
            };
            /// <summary>検索用：予実フラグ「予定」または「実績」を返却。
            /// 検索条件日付が過去の場合は「実績」、当日以降の場合は「予定」が返却される。</summary>
            /// <param name="dt_hizuke">検索条件日付</param>
            var getYojitsuFlag = function (dt_hizuke) {
                var yojitsuFlg = pageLangText.jissekiYojitsuFlg.text,
                    hizuke = App.data.getDateString(dt_hizuke, true),
                    sysdate = App.data.getDateString(new Date(), true);
                if (App.date.localDate(hizuke) >= App.date.localDate(sysdate)) {
                    yojitsuFlg = pageLangText.yoteiYojitsuFlg.text;
                }
                return yojitsuFlg;
            };
            /// <summary>フィルター条件の設定</summary>
            //var createFilter = function () {
            //    var criteria = $(".search-criteria").toJSON(),
            //        filters = [];
            //
            //    // TODO: 画面の仕様に応じて以下のフィルター条件を変更してください。
            //    if (!App.isUndefOrNull(criteria.dt_hiduke_search)) {
            //        filters.push("dt_hiduke ge DateTime'" + App.data.getFromDateStringForQuery(criteria.dt_hiduke_search) + "'");
            //    }
            //    // TODO: ここまで
            //
            //    return filters.join(" and ");
            //};
            /// <summary>データ検索を行います。</summary>
            /// <param name="query">クエリオブジェクト</param>
            var searchItems = function (query) {
                if (isDataLoading === true) {
                    return;
                }
                isDataLoading = true;
                // ローディングの表示
                $("#list-loading-message").text(
                    App.str.format(pageLangText.nowLoading.text)
                );
                App.ajax.webget(
                    App.data.toWebAPIFormat(query)
                ).done(function (result) {
                    isFirst = true; // 初回フラグをONにする
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
                var result = $(".search-criteria").validation().validate();
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
            $(".search-criteria").validation(searchValidation);

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

                // TODO：検索結果が上限数を超えていた場合
                if (parseInt(result.length) > querySetting.top) {
                    // 上限数を超えた検索結果は削除する
                    result.splice(querySetting.top, result.length);
                    querySetting.skip = result.length;
                    App.ui.page.notifyAlert.message(pageLangText.limitOver.text).show();
                }
                // TODO：上限数チェック：ここまで

                // グリッドの表示件数を更新
                grid.setGridParam({ rowNum: querySetting.skip });
                displayCount();
                // データバインド
                var currentData = grid.getGridParam("data").concat(result);
                grid.setGridParam({ data: currentData });
                // カラムの固定
                grid.setFrozenColumns().trigger('reloadGrid', [{ current: true}]);
                if (querySetting.count <= 0) {
                    // 検索結果0件
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

            /// <summary>追加状態の変更セットに追加する変更データの設定を行います。</summary>
            /// <param name="newRow">新規行データ</param>
            var setCreatedChangeData = function (newRow) {
                // TODO: 画面の仕様に応じて以下の項目を変更してください。
                var changeData = {
                    "dt_hizuke": App.data.getDateTimeStringForQueryNoUtc(App.date.localDate(searchCondition.dt_hiduke_search)),
                    "dt_shukko": App.data.getDateTimeStringForQueryNoUtc(App.date.localDate(newRow.dt_shukko)),
                    "wt_shiyo_zan": newRow.wt_shiyo_zan,
                    "su_kuradashi": newRow.su_kuradashi,
                    "su_kuradashi_hasu": newRow.su_kuradashi_hasu,
                    "flg_kakutei": newRow.flg_kakutei,
                    "cd_create": App.ui.page.user.Code,
                    "cd_update": App.ui.page.user.Code,
                    "cd_hinmei": newRow.cd_hinmei
                };
                // TODO: ここまで

                return changeData;
            };
            /// <summary>更新状態の変更セットに追加する変更データの設定を行います。</summary>
            /// <param name="row">選択行</param>
            var setUpdatedChangeData = function (row) {
                // TODO: 画面の仕様に応じて以下の項目を変更してください。
                var changeData = {
                    "dt_hizuke": App.data.getDateTimeStringForQueryNoUtc(App.date.localDate(searchCondition.dt_hiduke_search)),
                    "dt_shukko": App.data.getDateTimeStringForQueryNoUtc(App.date.localDate(row.dt_shukko)),
                    "wt_shiyo_zan": row.wt_shiyo_zan,
                    "su_kuradashi": row.su_kuradashi,
                    "su_kuradashi_hasu": row.su_kuradashi_hasu,
                    "flg_kakutei": row.flg_kakutei,
                    "cd_update": App.ui.page.user.Code,
                    "cd_hinmei": row.cd_hinmei
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

                ///// 前日残
                if (cellName == "wt_shiyo_zan") {
                    // 確定フラグが「確定」ではない場合
                    var kakutei = grid.getCell(selectedRowId, "flg_kakutei");
                    if (kakutei != pageLangText.trueFlg.text) {
                        // 庫出依頼数の計算処理
                        var kuradashiIrai = calcSuKuradashi(selectedRowId);

                        // 庫出依頼数をグリッドに設定
                        grid.setCell(selectedRowId, "su_kuradashi", kuradashiIrai);
                        changeSet.addUpdated(selectedRowId, "su_kuradashi", kuradashiIrai, changeData);
                    }
                }
                else if (cellName === "su_kuradashi_hasu") {
                    kuradashiMarumeCalc(selectedRowId, changeData);
                }
                // TODO: ここまで
            };

            /// <summary>庫出端数を編集した場合に換算する処理を定義します。</summary>
            /// <param name="rowId">選択行ID</param>
            /// <param name="rowData">選択行データ</param>
            var kuradashiMarumeCalc = function (rowId, rowData) {
                var kuradashisu = parseInt(rowData.su_kuradashi.toString(), 10);
                var kuradashihasu = parseInt(rowData.su_kuradashi_hasu.toString(), 10);
                var irisu = parseFloat(grid.getCell(rowId, "su_iri"));

                // 入数が0か庫出数、庫出端数が数値でなければ処理は行いません。
                if (!(irisu === 0 || isNaN(kuradashisu) || isNaN(kuradashihasu))) {
                    var kanzanHasu = 0;
                    var trimFixed = App.data.trimFixed;
                    var taniCode, isKgOrL, changeData;

                    // 納入単位コードがKgかLの場合は端数がそれぞれgとmlになるので、入数に1000をかけます。
                    taniCode = grid.getCell(rowId, 'cd_tani_nonyu');
                    isKgOrL = taniCode == pageLangText.kgKanzanKbn.text || taniCode == pageLangText.lKanzanKbn.text;
                    irisu = isKgOrL ? (irisu * 1000) : irisu;

                    // 最初に数・端数を端数へ換算(整数のみを想定)
                    kanzanHasu = kuradashisu * irisu;
                    kanzanHasu = kanzanHasu + kuradashihasu;

                    // 数・端数に換算
                    kuradashisu = parseInt(trimFixed(kanzanHasu / irisu), 10);
                    kuradashihasu = trimFixed(kanzanHasu % irisu);

                    // 行にセット
                    grid.setCell(rowId, "su_kuradashi", kuradashisu);
                    grid.setCell(rowId, "su_kuradashi_hasu", kuradashihasu);

                    // 新しい行データを再取得してchangeSetに更新をかけます。
                    changeData = setUpdatedChangeData(grid.getRowData(rowId));
                    changeSet.addUpdated(rowId, "su_kuradashi", kuradashisu, changeData);
                    changeSet.addUpdated(rowId, "su_kuradashi_hasu", kuradashihasu, changeData);

                    validateCell(rowId, "su_kuradashi", kuradashisu, kuradashiSuCol);
                    validateCell(rowId, "su_kuradashi_hasu", kuradashihasu, kuradashiHasuCol);
                }

                return grid.getCell(rowId, "su_kuradashi_hasu");
            };

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
                var hizukeCreate = App.data.getDateTimeString(criteria.dt_hiduke_search);
                hizukeSearch = App.data.getDateTimeString(searchCondition.dt_hiduke_search);

                // 分類
                if (criteria.bunruiCode != searchCondition.bunruiCode) {
                    return true;
                }
                // 日付
                if (hizukeCreate != hizukeSearch) {
                    return true;
                }
                // 品区分
                if (criteria.kubunHin != searchCondition.kubunHin) {
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

                var saveUrl = "../api/ShiyoryoKeisan";

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
                    App.ui.loading.close();
                }).always(function () {
                    // ローディングの終了
                    App.ui.loading.close();
                });
            };
            /// <summary>保存前チェック</summary>
            var checkSave = function () {
                // 編集内容の保存
                //saveEdit();

                // チェック処理
                // 検索条件の必須チェック
                var result = $(".search-criteria").validation().validate();
                if (result.errors.length) {
                    App.ui.loading.close();
                    return;
                }
                // 変更セット内にバリデーションエラーがある場合は処理を抜ける
                if (!validateChangeSet()) {
                    App.ui.loading.close();
                    return;
                }
                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();
                // 変更がない場合は処理を抜ける
                if (noChange()) {
                    App.ui.page.notifyInfo.message(pageLangText.noChange.text).show();
                    App.ui.loading.close();
                    return;
                }
                // 検索条件が変更されている場合は処理を抜ける
                if (changeCondition()) {
                    App.ui.page.notifyAlert.message(
                         App.str.format(pageLangText.criteriaChange.text, pageLangText.searchCriteria.text, pageLangText.save.text)
                    ).show();
                    App.ui.loading.close();
                    return;
                }
                else {
                    // チェックがすべて終わってからローディング表示を終了させる
                    App.ui.loading.close();
                }

                // 保存時ダイアログを開く
                //showSaveConfirmDialog();
                saveData();
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

            /// <summary>品区分変更時のイベント処理を行います。</summary>
            var setHinBunrui = function () {
                // 品区分の値を元に、品分類コンボボックスの値を取得します。

                // 品分類の中身をクリア
                $("#condition-bunrui option").remove();

                var criteria = $(".search-criteria").toJSON();
                var hinKbnParam = criteria.kubunHin;
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
                    var target = $("#condition-bunrui");
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
            $("#condition-kbn_hin").on("change", setHinBunrui);

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
                var bunruiNm = pageLangText.noSelectConditionExcel.text,
                    hinKbnNm = pageLangText.noSelectConditionExcel.text,
                    hizuke = App.data.getDateTimeStringForQueryNoUtc(criteria.dt_hiduke_search);

                if (!App.isUndefOrNull(criteria.bunruiCode)) {
                    bunruiNm = $("#condition-bunrui option:selected").text();
                }
                if (!App.isUndefOrNull(criteria.kubunHin)) {
                    hinKbnNm = $("#condition-kbn_hin option:selected").text();
                }

                var query = {
                    url: "../api/GenryoShiyoryoKeisanExcel",
                    lang: App.ui.page.lang,
                    con_hizuke: hizuke,
                    con_bunrui: criteria.bunruiCode,
                    bunruiName: encodeURIComponent(bunruiNm),
                    hinKubun: criteria.kubunHin,
                    hinKubunName: encodeURIComponent(hinKbnNm),
                    flg_yojitsu: getYojitsuFlag(criteria.dt_hiduke_search),
                    userName: encodeURIComponent(App.ui.page.user.Name),
                    outputDate: App.data.getDateTimeStringForQuery(new Date(), true),
                    utc: -(new Date().getTimezoneOffset() / 60)
                };

                // 処理中を表示する
                App.ui.loading.show(pageLangText.nowProgressing.text);
                // 必要な情報を渡します
                var url = App.data.toWebAPIFormat(query);

                // 出力処理
                window.open(url, '_parent');
                // Cookieを監視する
                onComplete();
            };
            /// <summary>ダウンロードボタンクリック時のオーバレイ処理を行います。</summary>
            var downloadOverlay = function () {
                App.ui.page.notifyAlert.clear();

                // 検索条件の必須チェック
                var result = $(".search-criteria").validation().validate();
                if (result.errors.length) {
                    return;
                }
                // 明細の変更をチェック
                if (!noChange()) {
                    App.ui.page.notifyAlert.message(pageLangText.unprintableCheck.text
                    ).show();
                    return;
                }

                // Excelファイル出力へ
                printExcel();
            };

            //Cookieを1秒ごとにチェックする
            var onComplete = function () {
                if (app_util.prototype.getCookieValue(pageLangText.genryoShiyoKeisanCookie.text) == pageLangText.checkCookie.text) {
                    app_util.prototype.deleteCookie(pageLangText.genryoShiyoKeisanCookie.text);
                    //ローディング終了
                    App.ui.loading.close();
                }
                else {
                    // 再起してCookieが作成されたか監視
                    setTimeout(onComplete, 1000);
                }
            };

            /// <summary>Excelボタンクリック時のイベント処理を行います。</summary>
            $(".excel-button").on("click", downloadOverlay);

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

            /// <summary>Excel(職場選択)ボタンクリック時のイベント処理を行います。</summary>
            $(".shokubabetsu-excel-button").on("click", function (e) {
                // 情報/エラーメッセージのクリア
                App.ui.page.notifyInfo.clear();
                App.ui.page.notifyAlert.clear();

                // 検索条件の必須チェック
                var result = $(".search-criteria").validation().validate();
                if (result.errors.length) {
                    return;
                }
                // 明細の変更をチェック
                if (!noChange()) {
                    App.ui.page.notifyAlert.message(pageLangText.unprintableCheck.text
                    ).show();
                    return;
                }

                var criteria = $(".search-criteria").toJSON();
                var bunruiNm = pageLangText.noSelectConditionExcel.text,
                    hinKbnNm = pageLangText.noSelectConditionExcel.text,
                    hizuke = App.data.getDateTimeStringForQueryNoUtc(criteria.dt_hiduke_search);

                if (!App.isUndefOrNull(criteria.bunruiCode)) {
                    bunruiNm = $("#condition-bunrui option:selected").text();
                }
                if (!App.isUndefOrNull(criteria.kubunHin)) {
                    hinKbnNm = $("#condition-kbn_hin option:selected").text();
                }

                var option = {
                    id: 'shokubaSentaku', multiselect: true
                    , param1: hizuke
                    , param2: criteria.kubunHin
                    , param3: encodeURIComponent(hinKbnNm)
                    , param4: criteria.bunruiCode
                    , param5: encodeURIComponent(bunruiNm)
                    , param6: getYojitsuFlag(criteria.dt_hiduke_search)
                    , param7: -(new Date().getTimezoneOffset() / 60)
                };

                shokubaSentakuDialog.draggable(true);
                shokubaSentakuDialog.dlg("open", option);
            });

            // 個別ラベルダイアログの生成
            shokubaSentakuDialog.dlg({
                url: "Dialog/ShokubaSentakuDialog.aspx",
                name: "ShokubaSentakuDialog",
                closed: function (e, data, data2) {
                    if (data == "canceled") {
                        return;
                    }
                    else {
                        // 特に何もしない
                    }
                }
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
            <ul class="item-list">
                <!-- TODO: 画面の仕様に応じて以下の検索条件を変更してください。-->
                <li>
                    <label>
                        <span class="item-label" data-app-text="dt_hiduke_search"></span>
                        <input type="text" id="dt_hiduke_search" name="dt_hiduke_search" maxlength="10"/>
                    </label>
                </li>
                <li>
                    <label>
                        <span class="item-label" data-app-text="kbn_hin_search"></span>
                        <select name="kubunHin" id="condition-kbn_hin">
                        </select>
                    </label>
                </li>
                <li>
                    <label>
                        <span class="item-label" data-app-text="nm_bunrui"></span>
                        <select name="bunruiCode" id="condition-bunrui">
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
                <button type="button" class="shukkobi-button" id="shukkobi-button" data-app-operation="shukkobi"><span class="icon"></span><span data-app-text="shukkobi"></span></button>
                <input type="text" class="dt_shukko_henko" id="dt_shukko_henko" name="dt_shukko_henko" maxlength="10" style="width: 80px;"/>
				<button type="button" class="check-button" name="check-button" data-app-operation="check">
					<span class="icon"></span><span data-app-text="allCheck"></span>
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
            <span class="icon"></span>
            <span data-app-text="save"></span>
        </button>
        <button type="button" class="excel-button" name="excel-button" data-app-operation="excel">
            <!--<span class="icon"></span>-->
            <span data-app-text="excel"></span>
        </button>
         <button type="button" class="shokubabetsu-excel-button" name="shokubabetsu-excel-button" data-app-operation="shokubaExcel">
            <!--<span class="icon"></span>-->
            <span data-app-text="shokubaExcel"></span>
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
    <div class="save-confirm-dialog">
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
    <div class="search-confirm-dialog">
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
    <div class="shokuba-sentaku-dialog">
	</div>
    <!-- TODO: ここまで  -->

    <!-- 画面デザイン -- End -->
</asp:Content>
