<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="HendoHyoSimulation.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.HendoHyoSimulation" %>

<asp:Content ID="Content1" ContentPlaceHolderID="IncludeContent" runat="server">
    <script src="<%=ResolveUrl("~/Resources/pages/pagedata-hendohyosimulation." + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
    <script src="<%=ResolveUrl("~/Resources/grid/grid.locale-" + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
    <script src="<%=ResolveUrl("~/Scripts/util/app-util.js") %>" type="text/javascript"></script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        /* 画面デザイン -- Start */
        
        /* 固定表示部のスタイル */
        .part-body .item-label
        {
            display: inline-block;
        }
        /*.search-criteria .item-label
        {
            width: 5em;
        }
        .part-genshi .item-label
        {
            width: 9em;
        }
        */
        /* 原資材情報のスタイル */
        .content-part .part-genshi
        {
            display: inline-block;
        }
        .part-genshi .item-list li
        {
            margin-bottom: .6em;
        }

        /* グリッドのスタイル */
        .part-grid
        {
            margin: .3em;
        }
        #simulation-grid
        {
            padding: 0px;
            overflow: hidden;
        }
        #genryo-grid
        {
            padding: 0px;
            overflow: hidden;
        }
        #shizai-grid
        {
            padding: 0px;
            overflow: hidden;
        }

        /* 休日の背景色設定 */
        .kyujitsu-row
        {
            background: #ffc0cb;
            border: 1px solid #aaaaaa;
        }

        /* 未使用行の背景色設定 */
        .mishiyo-row
        {
            background: #c0c0c0;
            border: 1px solid #aaaaaa;
        }

        /* 検索時ダイアログのスタイル */
        .search-confirm-dialog
        {
            background-color: White;
            width: 350px;
        }
        .search-confirm-dialog .part-body
        {
            width: 95%;
        }

        /* 保存時ダイアログのスタイル */
        .save-confirm-dialog
        {
            background-color: White;
            width: 350px;
        }
        .save-confirm-dialog .part-body
        {
            width: 95%;
        }

        /* 計画作成ボタン押下時ダイアログのスタイル */
        .keikaku-confirm-dialog
        {
            background-color: White;
            width: 350px;
        }
        .keikaku-confirm-dialog .part-body
        {
            width: 95%;
        }

        /* 製品一覧ダイアログ：検索条件/製品一覧ボタン押下時のスタイル */
        .con-seihin-button-dialog
        {
            background-color: White;
            width: 550px;
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
        /* 画面デザイン -- End */
    </style>
    <script type="text/javascript">

        $(App.ui.page).on("ready", function () {
            //// 変数宣言 -- Start

            // 画面アーキテクチャ共通の変数宣言
            var pageLangText = App.ui.pagedata.lang(App.ui.page.lang),
                validationSetting = App.ui.pagedata.validation(App.ui.page.lang),
                querySetting = { skip: 0, top: 40, count: 0 },
                isDataLoading = false;

            // 英語化対応　言語によって幅を調節
            $(".search-criteria .item-label").css("width", pageLangText.each_lang_width.number);

            // グリッドコントロール固有の変数宣言
            var simuGrid = $("#item-grid1"),
                genGrid = $("#item-grid2"),
                shiGrid = $("#item-grid3"),
            // 変更データ格納領域
                changeSet = new App.ui.page.changeSet(),
            // 検索条件格納領域
                searchCriteriaSet,
            // 現在日付
                todayDate,
            // バリデーションエラーフラグ
                varidErrFlg = false,
            // 品名(多言語対応)
                hinName = 'nm_hinmei_' + App.ui.page.lang,
            // 製品入数
                seihinSuIri,
            // 変更前製造予定数
                befSuSeizoYotei = 0,
            // 変更後製造予定数
                aftSuSeizoYotei = 0,
            // 明細原料件数
                cntGenryo = 0,
            // 明細資材件数
                cntShizai = 0,
            // 選択原資材：原資材コード
                selGenshiCdGenshizai,
            // 選択原資材：原資材名
                selGenshiNmGenshizai,
            // 選択原資材：品区分
                selGenshiKbnHin,
            // 選択原資材：取引先コード２
                selGenshiCdTorihiki2,
            // 選択原資材：納入単価
                selGenshiTanNonyu,
            // 選択原資材：税区分
                selGenshiKbnZei,
            // 選択原資材：変更前使用量
                selGenshiBefWtShiyo,
            // 選択原資材：変更後使用量
                selGenshiAftWtShiyo,
            // 変更レコード格納領域
                updateRow,
                firstCol = 1,
                duplicateCol = 999,
                currentRow = 0,
                currentCol = firstCol,
                nonyuYoteiCol = 5,
                loading,
            // 小数点ありの計算用。整数に戻す際に使用する
            //    KANZAN = 100;   // 2014.03.05時点では小数点以下2桁なので100
                KANZAN = 1000;   // 2016.10.31時点では小数点以下3桁なので1000

            var cd_GenryoAri = false;
            var cd_ShizaiAri = false;

            // ダイアログ固有の変数宣言
            // ダイアログ(品名マスタ検索)：検索条件/製品一覧ボタン押下時
            var seihinDialog = $(".con-seihin-button-dialog");
            seihinDialog.dlg({
                url: "Dialog/HinmeiDialog.aspx",
                name: "HinmeiDialog",
                closed: function (e, data, data2) {
                    App.ui.loading.close();
                    if (data == "canceled") {
                        // キャンセルされた場合、ダイアログを閉じる
                        return;
                    }
                    else {
                        // 取得した品名コード、品名を、検索条件/品名コード、検索条件/品名に設定
                        $("#condition-cd_hinmei").val(data);
                        $("#condition-nm_hinmei").text(data2);
                        // 再チェックで背景色とメッセージのリセット
                        App.ui.page.notifyAlert.remove($("#condition-cd_hinmei"));
                        $("#condition-cd_hinmei").change();
                    }
                }
            });

            var searchConfirmDialog = $(".search-confirm-dialog"),
                saveConfirmDialog = $(".save-confirm-dialog"),
                keikakuConfirmDialog = $(".keikaku-confirm-dialog");

            //// 変数宣言 -- End

            //// コントロール定義 -- Start

            // ダイアログ固有のコントロール定義
            searchConfirmDialog.dlg();
            saveConfirmDialog.dlg();
            keikakuConfirmDialog.dlg();

            /// <summary>ダイアログを開きます。</summary>
            // 検索時ダイアログを開く
            var showSearchConfirmDialog = function () {
                // 検索前に変更をチェック
                if (noChange()) {
                    searchLoading();
                }
                else {
                    searchConfirmDialogNotifyInfo.clear();
                    searchConfirmDialogNotifyAlert.clear();
                    searchConfirmDialog.draggable(true);
                    searchConfirmDialog.dlg("open");
                }
            };
            /// <summary>ローディングの表示</summary>
            var searchLoading = function () {
                App.ui.loading.show(pageLangText.nowProgressing.text);
                var deferred = $.Deferred();
                deferred
                .then(function () {
                    var d = new $.Deferred;
                    setTimeout(function () {
                        App.ui.loading.show(pageLangText.nowProgressing.text);
                        d.resolve();
                    }, 50);
                    return d;
                })
                .then(function () {
                    // 検索処理
                    findData();
                });
                deferred.resolve();
            };

            // 保存時ダイアログを開く
            var showSaveConfirmDialog = function () {
                saveConfirmDialogNotifyInfo.clear();
                saveConfirmDialogNotifyAlert.clear();
                saveConfirmDialog.draggable(true);
                saveConfirmDialog.dlg("open");
            };

            // 計画作成時ダイアログを開く
            var showKeikakuConfirmDialog = function () {
                keikakuConfirmDialogNotifyInfo.clear();
                keikakuConfirmDialogNotifyAlert.clear();
                keikakuConfirmDialog.draggable(true);
                keikakuConfirmDialog.dlg("open");
            };

            /// ダイアログ：製品一覧を開く
            var showSeihinDialog = function () {
                App.ui.loading.show("");    // ローディング

                // ダイアログ：取引先一覧のドラッグを可能とする
                seihinDialog.draggable(true);
                // ダイアログ：原資材一覧(品名マスタ検索を原料と資材で絞る)を開く
                var option = { id: 'seihin', multiselect: false, param1: pageLangText.seihinHinDlgParam.text };
                seihinDialog.dlg("open", option);
            };

            /// <summary>ダイアログを閉じます。</summary>
            // 検索時ダイアログを閉じる
            var closeSearchConfirmDialog = function () {
                searchConfirmDialog.dlg("close");
            };

            // 保存時ダイアログを閉じる
            var closeSaveConfirmDialog = function () {
                saveConfirmDialog.dlg("close");
            };

            // 計画作成時ダイアログを閉じる
            var closeKeikakuConfirmDialog = function () {
                keikakuConfirmDialog.dlg("close");
            };

            // 日付系の多言語対応
            var datePickerFormat = pageLangText.dateFormatUS.text;
            var dateSrcFormat = pageLangText.dateSrcFormatUS.text;
            var newDateMMDDFormat = pageLangText.dateMMDDFormatUS.text;
            var newDateFormat = pageLangText.dateNewFormatUS.text;
            if (App.ui.page.langCountry !== 'en-US') {
                datePickerFormat = pageLangText.dateFormat.text;
                dateSrcFormat = pageLangText.dateSrcFormat.text;
                newDateMMDDFormat = pageLangText.dateMMDDFormat.text;
                newDateFormat = pageLangText.dateNewFormat.text;
            }
            // 検索条件/日付
            $("#condition-dt_hizuke").datepicker({ dateFormat: datePickerFormat });
            // 検索条件/日付の範囲制限：システム日付(当日) ～ システム日付の10年後
            $("#condition-dt_hizuke").datepicker("option", 'minDate', new Date());
            $("#condition-dt_hizuke").datepicker("option", 'maxDate', "+10y");
            // スラッシュ自動付与
            $("#condition-dt_hizuke").on("keyup", App.data.addSlashForDateString).datepicker({ dateFormat: datePickerFormat });

            // グリッドコントロール固有のコントロール定義
            // 明細(シミュレーションスプレッド)
            simuGrid.jqGrid({
                colNames: [
                // 明細/日
                    pageLangText.dt_hizuke.text,
                // 隠し項目：年月日
                    pageLangText.dt_ymd.text,
                // 隠し項目：休日フラグ
                    pageLangText.flg_kyujitsu.text,
                // 隠し項目：検索時変更前納入数
                    pageLangText.save_before_su_nonyu.text,
                // 隠し項目：変更前納入数
                    pageLangText.before_su_nonyu.text,
                // 明細/(変更後)納入数
                    pageLangText.after_su_nonyu.text,
                // 明細/変更前使用量
                    pageLangText.before_wt_shiyo.text,
                // 明細/変更後使用量
                    pageLangText.after_wt_shiyo.text,
                // 明細/変更前在庫量
                    pageLangText.before_wt_zaiko.text,
                // 明細/変更後在庫量
                    pageLangText.after_wt_zaiko.text,
                // 隠し項目：個数
                    pageLangText.su_ko.text,
                // 隠し項目：入数                
                    pageLangText.su_iri.text,
                // 隠し項目：納入単位
                    pageLangText.cd_tani.text,
                // 明細/実在庫
                    pageLangText.su_zaiko.text,
                // 隠し項目：納入数変更フラグ
                    "flg_nonyu_change"
                ],
                colModel: [
                    { name: 'dt_hizuke', width: pageLangText.dt_hizuke_width.number, editable: false, sortable: false, align: "center", formatter: "date",
                        formatoptions: { srcformat: dateSrcFormat, newformat: newDateMMDDFormat },
                        unformat: unformatDate
                    },
                    { name: 'dt_ymd', width: 0, hidden: true, hidedlg: true, formatter: "date",
                        formatoptions: { srcformat: dateSrcFormat, newformat: newDateFormat }
                    },
                    { name: 'flg_kyujitsu', width: 0, hidden: true, hidedlg: true },
                    { name: 'save_before_su_nonyu', width: 0, hidden: true, hidedlg: true },
                    { name: 'before_su_nonyu', width: 0, hidden: true, hidedlg: true },
                    { name: 'after_su_nonyu', width: pageLangText.after_su_nonyu_width.number, editable: true, sortable: false, align: "right",
                        formatter: changeZeroToBlank,
                        //formatoptions: { decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 2, defaultValue: "" }
                        formatoptions: { decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 3, defaultValue: "" }
                    },
                    { name: 'before_wt_shiyo', width: pageLangText.before_wt_shiyo_width.number, editable: false, sortable: false, align: "right", formatter: changeZeroToBlank,
                        //formatoptions: { decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 2, defaultValue: "" }
                        formatoptions: { decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 3, defaultValue: "" }
                    },
                    { name: 'after_wt_shiyo', width: pageLangText.after_wt_shiyo_width.number, editable: false, sortable: false, align: "right", formatter: changeZeroToBlank,
                        //formatoptions: { decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 2, defaultValue: "" }
                        formatoptions: { decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 3, defaultValue: "" }
                    },
                    { name: 'before_wt_zaiko', width: pageLangText.before_wt_zaiko_width.number, editable: false, sortable: false, align: "right", formatter: 'number',
                        //formatoptions: { decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 2, defaultValue: "" }
                        formatoptions: { decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 3, defaultValue: "" }
                    },
                    { name: 'after_wt_zaiko', width: pageLangText.after_wt_zaiko_width.number, editable: false, sortable: false, align: "right", formatter: 'number',
                        //formatoptions: { decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 2, defaultValue: "" }
                        formatoptions: { decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 3, defaultValue: "" }
                    },
                    { name: 'su_ko', width: 0, hidden: true, hidedlg: true },
                    { name: 'su_iri', width: 0, hidden: true, hidedlg: true },
                    { name: 'cd_tani', width: 0, hidden: true, hidedlg: true },
                    { name: 'su_zaiko', width: pageLangText.su_zaiko_width.number, editable: false, sortable: false, align: "right", formatter: 'number',
                        //formatoptions: { decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 2, defaultValue: "" }
                        formatoptions: { decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 3, defaultValue: "" }
                    },
                    { name: 'flg_nonyu_change', width: 0, hidden: true, hidedlg: true }
                ],
                datatype: "local",
                shrinkToFit: false,
                multiselect: false,
                rownumbers: false,
                cellEdit: true,
                onRightClickRow: function (rowid) {
                    $("#" + rowid).removeClass("ui-state-highlight").find("td").click();
                },
                cellsubmit: 'clientArray',
                loadComplete: function () {
                    var ids = simuGrid.jqGrid('getDataIDs');
                    if (ids.length > 0) {
                        // グリッドの先頭行選択
                        $("#" + 1).removeClass("ui-state-highlight").find("td").click();
                    }
                },
                beforeEditCell: function (selectedRowId, cellName, value, iRow, iCol) {
                    currentRow = iRow;
                    currentCol = iCol;
                    // Enter キーでカーソルを移動
                    simuGrid.moveCell(cellName, iRow, iCol);
                },
                afterEditCell: function (selectedRowId, cellName, value, iRow, iCol) {
                    // Enter キーでカーソルを移動
                    simuGrid.moveCell(cellName, iRow, iCol);
                },
                beforeSaveCell: function (selectedRowId, cellName, value, iRow, iCol) {
                    if (value == "") {
                        return;
                    }
                    // カンマ区切り除去(formatterが自前なので、カンマ区切りが除去されない為)
                    var val = deleteThousandsSeparator(value);
                    if (!validateCell(selectedRowId, cellName, val, iCol)) {
                        // バリデーションエラーの場合、バリデーションエラーフラグを立てる
                        varidErrFlg = true;
                    }
                },
                afterSaveCell: function (selectedRowId, cellName, value, iRow, iCol) {
                    var changeNonyuData;
                    if (!varidErrFlg) {
                        // バリデーションエラーが発生していない場合

                        if (cellName == "after_su_nonyu") {
                            // 明細/(変更後)納入数変更時

                            // 関連項目の設定
                            setRelatedValue(selectedRowId);
                            // 納入数を編集したフラグを立てる
                            simuGrid.jqGrid('setCell', selectedRowId, 'flg_nonyu_change', pageLangText.trueFlg.text);

                            // 変更レコードの設定
                            updateRow = simuGrid.getRowData(selectedRowId);

                            if (updateRow.after_su_nonyu != ""
                                && deleteThousandsSeparator(updateRow.after_su_nonyu) > 0) {
                                // 明細/(変更後)納入数に『0』以上の値が入力された場合

                                // 追加用の変更データの設定
                                changeNonyuData = setCreatedChangeNonyuData(updateRow);
                                // 追加状態の変更セットに変更データを追加
                                changeSet.addCreated(selectedRowId, changeNonyuData);
                            }
                            else {
                                // 明細/(変更後)納入数に『0』が入力、または値がクリアされた場合

                                if (!App.isUndefOrNull(changeSet.changeSet.created[selectedRowId])) {
                                    // 追加状態の変更セットが存在する場合

                                    // 追加状態の変更セットから変更データを削除
                                    changeSet.removeCreated(selectedRowId);
                                }

                                if (updateRow.save_before_su_nonyu != "") {
                                    // 隠し項目：検索時変更前納入数に値が入っている場合

                                    // 削除用の変更データの設定
                                    changeNonyuData = setDeletedChangeNonyuData(updateRow);
                                    // 削除状態の変更セットに変更データを追加
                                    changeSet.addDeleted(selectedRowId, changeNonyuData);
                                }
                            }

                            var jitsuZaiko = simuGrid.getCell(iRow, "su_zaiko");
                            if (App.isUndefOrNull(jitsuZaiko) || jitsuZaiko.length == 0) {
                                // 実在庫がなければ在庫量更新処理を実施
                                updateWtZaiko(updateRow, selectedRowId);
                            }
                        }
                    }
                    else {
                        // バリデーションエラーが発生している場合

                        if (isNaN(simuGrid.getCell(selectedRowId, cellName))) {
                            // セルの入力値が数値でない場合

                            // 対象のセルにnullを設定(『NaN』表示のクリア対応)
                            simuGrid.setCell(selectedRowId, cellName, null);
                        }
                    }

                    // バリデーションエラーフラグの初期化
                    varidErrFlg = false;
                },
                onCellSelect: function (rowid, icol, cellcontent) {
                    // 選択列の設定
                    selectCol = icol;
                }
            });

            // 明細原料(原料スプレッド)
            genGrid.jqGrid({
                colNames: [
                // 明細原料/コード
                    pageLangText.cd_genryo.text,
                // 明細原料/原料名
                    pageLangText.nm_genryo.text,
                // 隠し項目：未使用フラグ
                    pageLangText.flg_mishiyo.text,
                // 隠し項目：変更前使用量
                    pageLangText.genryo_bef_wt_shiyo.text,
                // 明細原料/使用量
                    pageLangText.genryo_wt_shiyo.text,
                // 隠し項目：変更前在庫量
                    pageLangText.genryo_bef_wt_zaiko.text,
                // 明細原料/在庫量
                    pageLangText.genryo_wt_zaiko.text,
                // 隠し項目：納入リードタイム
                    pageLangText.dd_leadtime.text,
                // 隠し項目：最低在庫
                    pageLangText.su_zaiko_min.text,
                // 隠し項目：発注ロットサイズ
                    pageLangText.su_hachu_lot_size.text,
                // 隠し項目：使用単位コード
                    pageLangText.cd_tani_shiyo.text,
                // 隠し項目：納入単位コード
                    pageLangText.cd_tani_nonyu.text,
                // 隠し項目：品区分
                    pageLangText.kbn_hin.text,
                // 隠し項目：納入単価
                    pageLangText.tan_nonyu.text,
                // 隠し項目：税区分
                    pageLangText.kbn_zei.text
                ],
                colModel: [
                // 明細原料/コード
                    {name: 'recipeHinmeiCode', width: pageLangText.recipeHinmeiCode_width.number, editable: false, sortable: false, align: 'left' },
                // 明細原料/原料名
                    {name: 'recipeHinmeiName', width: pageLangText.recipeHinmeiName_width.number, editable: false, sortable: false, align: 'left' },
                // 隠し項目：未使用フラグ
                    {name: 'flg_mishiyo', width: 0, hidden: true, hidedlg: true, formatter: genGridRowColorFormat },
                // 隠し項目：変更前使用量
                    {name: 'genryo_bef_wt_shiyo', width: 0, hidden: true, hidedlg: true, formatter: 'number',
                    //formatoptions: { decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 2, defaultValue: "" }
                    formatoptions: { decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 3, defaultValue: "" }
                },
                // 明細原料/使用量
                    {name: 'genryo_wt_shiyo', width: pageLangText.genryo_wt_shiyo_width.number, editable: false, sortable: false, align: "right", formatter: 'number',
                    //formatoptions: { decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 2, defaultValue: "" }
                    formatoptions: { decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 3, defaultValue: 0.000 }
                },
                // 隠し項目：変更前在庫量
                    {name: 'genryo_bef_wt_zaiko', width: 0, hidden: true, hidedlg: true },
                // 明細原料/在庫量
                    {name: 'genryo_wt_zaiko', width: pageLangText.genryo_wt_zaiko_width.number, editable: false, sortable: false, align: "right", formatter: 'number',
                    //formatoptions: { decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 2, defaultValue: "" }
                    formatoptions: { decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 3, defaultValue: "" }
                },
                // 隠し項目：納入リードタイム
                    {name: 'dd_leadtime', width: 0, hidden: true, hidedlg: true },
                // 隠し項目：最低在庫
                    {name: 'su_zaiko_min', width: 0, hidden: true, hidedlg: true , formatter: 'number',
                    formatoptions: { decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 3, defaultValue: "" }
                },
                // 隠し項目：発注ロットサイズ
                    {name: 'su_hachu_lot_size', width: 0, hidden: true, hidedlg: true },
                // 隠し項目：使用単位コード
                    {name: 'cd_tani_shiyo', width: 0, hidden: true, hidedlg: true },
                // 隠し項目：納入単位コード
                    {name: 'cd_tani_nonyu', width: 0, hidden: true, hidedlg: true },
                // 隠し項目：品区分
                    {name: 'kbn_hin', width: 0, hidden: true, hidedlg: true },
                // 隠し項目：納入単価
                    {name: 'tan_nonyu', width: 0, hidden: true, hidedlg: true },
                // 隠し項目：税区分
                    {name: 'kbn_zei', width: 0, hidden: true, hidedlg: true }
                ],
                datatype: "local",
                shrinkToFit: false,
                multiselect: false,
                rownumbers: true,
                cellEdit: true,
                onRightClickRow: function (rowid) {
                    shiGrid.resetSelection();
                    var elm = $("#" + rowid, genGrid);
                    $(elm).removeClass("ui-state-highlight").find("td").click();
                },
                cellsubmit: 'clientArray',
                loadComplete: function () {
                    var ids = genGrid.jqGrid('getDataIDs');
                    // グリッドの先頭行選択
                    if (ids.length > 0) {
                        $("#" + 1).removeClass("ui-state-highlight").find("td").click();
                    }
                },
                onCellSelect: function (rowid, icol, cellcontent) {
                    // 資材スプレッドの行選択を解除
                    shiGrid.resetSelection();
                },
                ondblClickRow: function (selectedRowId) {
                    // 検索前バリデーション
                    var result = $(".search-criteria").validation().validate();
                    if (result.errors.length) {
                        return;
                    }

                    var inputValue = $("#condition-after_change").val();
                    // 変更後製造予定数の設定
                    if (App.isUndefOrNull(inputValue)
                        || inputValue.length === 0) {
                        // 変更後製造予定数が入力されていない場合

                        // 変更後製造予定数に『0』を表示させる(変更後製造予定数クリア時に変数『aftSuSeizoYotei』には0が代入されている)
                        $("#condition-after_change").val(aftSuSeizoYotei);
                    }

                    // 検索条件変更チェック
                    if (!noChangeCriteria()) {
                        // 検索条件が変更されている場合

                        // メッセージの表示
                        App.ui.page.notifyInfo.message(
                            App.str.format(pageLangText.changeCriteria.text, pageLangText.searchCriteria.text, pageLangText.show.text)
                        ).show();
                    }
                    else {
                        // 検索条件が変更されていない場合

                        // 原資材情報のクリア
                        clearInfoGenshi();
                        // 選択原資材：原資材コードの設定
                        selGenshiCdGenshizai = genGrid.getCell(selectedRowId, "recipeHinmeiCode");
                        // 選択原資材：原資材名の設定
                        selGenshiNmGenshizai = genGrid.getCell(selectedRowId, "recipeHinmeiName");
                        // 選択原資材：品区分の設定
                        selGenshiKbnHin = genGrid.getCell(selectedRowId, "kbn_hin");
                        // 選択原資材：納入単価の設定
                        selGenshiTanNonyu = genGrid.getCell(selectedRowId, "tan_nonyu");
                        // 選択原資材：税区分の設定
                        selGenshiKbnZei = genGrid.getCell(selectedRowId, "kbn_zei");
                        // 選択原資材：変更前使用量の設定
                        selGenshiBefWtShiyo = deleteThousandsSeparator(genGrid.getCell(selectedRowId, "genryo_bef_wt_shiyo"));
                        // 選択原資材：変更後使用量の設定
                        selGenshiAftWtShiyo = deleteThousandsSeparator(genGrid.getCell(selectedRowId, "genryo_wt_shiyo"));
                        // 原資材情報の設定
                        setGenshiInfo(selectedRowId);
                    }
                }
            });

            // 明細資材(資材スプレッド)
            shiGrid.jqGrid({
                colNames: [
                // 明細資材/コード
                    pageLangText.cd_shizai.text,
                // 明細資材/資材名
                    pageLangText.nm_shizai.text,
                // 隠し項目：未使用フラグ
                    pageLangText.flg_mishiyo.text,
                // 隠し項目：使用数
                    pageLangText.su_shiyo.text,
                // 隠し項目：歩留
                    pageLangText.ritsu_budomari.text,
                // 隠し項目：変更前使用量
                    pageLangText.shizai_bef_wt_shiyo.text,
                // 明細資材/使用量
                    pageLangText.shizai_wt_shiyo.text,
                // 隠し項目：変更前在庫量
                    pageLangText.shizai_bef_wt_zaiko.text,
                // 明細資材/在庫量
                    pageLangText.shizai_wt_zaiko.text,
                // 隠し項目：納入リードタイム
                    pageLangText.dd_leadtime.text,
                // 隠し項目：最低在庫
                    pageLangText.su_zaiko_min.text,
                // 隠し項目：発注ロットサイズ
                    pageLangText.su_hachu_lot_size.text,
                // 隠し項目：使用単位コード
                    pageLangText.cd_tani_shiyo.text,
                // 隠し項目：納入単位コード
                    pageLangText.cd_tani_nonyu.text,
                // 隠し項目：品区分
                    pageLangText.kbn_hin.text,
                // 隠し項目：納入単価
                    pageLangText.tan_nonyu.text,
                // 隠し項目：税区分
                    pageLangText.kbn_zei.text
                ],
                colModel: [
                // 明細資材/コード
                    {name: 'cd_shizai', width: pageLangText.cd_shizai_width.number, editable: false, sortable: false, align: 'left' },
                // 明細資材/資材名
                    {name: 'nm_shizai', width: pageLangText.nm_shizai_width.number, editable: false, sortable: false, align: 'left' },
                // 隠し項目：未使用フラグ
                    {name: 'flg_mishiyo', width: 0, hidden: true, hidedlg: true, formatter: shiGridRowColorFormat },
                // 隠し項目：使用数
                    {name: 'su_shiyo', width: 0, hidden: true, hidedlg: true },
                // 隠し項目：歩留
                    {name: 'ritsu_budomari', width: 0, hidden: true, hidedlg: true },
                // 隠し項目：変更前使用量
                    {name: 'shizai_bef_wt_shiyo', width: 0, hidden: true, hidedlg: true, formatter: 'number',
                    //formatoptions: { decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 2, defaultValue: "" }
                    formatoptions: { decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 3, defaultValue: "" }
                },
                // 明細資材/使用量
                    {name: 'shizai_wt_shiyo', width: pageLangText.shizai_wt_shiyo_width.number, editable: false, sortable: false, align: "right", formatter: 'number',
                    //formatoptions: { decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 2, defaultValue: "" }
                    formatoptions: { decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 3, defaultValue: 0.000 }
                },
                // 隠し項目：変更前在庫量
                    {name: 'shizai_bef_wt_zaiko', width: 0, hidden: true, hidedlg: true },
                // 明細資材/在庫量
                    {name: 'shizai_wt_zaiko', width: pageLangText.shizai_wt_zaiko_width.number, editable: false, sortable: false, align: "right", formatter: 'number',
                    //formatoptions: { decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 2, defaultValue: "" }
                    formatoptions: { decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 3, defaultValue: "" }
                },
                // 隠し項目：納入リードタイム
                    {name: 'dd_leadtime', width: 0, hidden: true, hidedlg: true },
                // 隠し項目：最低在庫
                    {name: 'su_zaiko_min', width: 0, hidden: true, hidedlg: true ,formatter: 'number',
                    formatoptions: { decimalSeparator: ".", thousandsSeparator: "", decimalPlaces: 3, defaultValue: "" }
                },
                // 隠し項目：発注ロットサイズ
                    {name: 'su_hachu_lot_size', width: 0, hidden: true, hidedlg: true },
                // 隠し項目：使用単位コード
                    {name: 'cd_tani_shiyo', width: 0, hidden: true, hidedlg: true },
                // 隠し項目：納入単位コード
                    {name: 'cd_tani_nonyu', width: 0, hidden: true, hidedlg: true },
                // 隠し項目：品区分
                    {name: 'kbn_hin', width: 0, hidden: true, hidedlg: true },
                // 隠し項目：納入単価
                    {name: 'tan_nonyu', width: 0, hidden: true, hidedlg: true },
                // 隠し項目：税区分
                    {name: 'kbn_zei', width: 0, hidden: true, hidedlg: true }
                ],
                datatype: "local",
                shrinkToFit: false,
                multiselect: false,
                rownumbers: true,
                cellEdit: true,
                onRightClickRow: function (rowid) {
                    genGrid.resetSelection();
                    var elm = $("#" + rowid, shiGrid);
                    $(elm).removeClass("ui-state-highlight").find("td").click();
                },
                cellsubmit: 'clientArray',
                loadComplete: function () {
                    var ids = shiGrid.jqGrid('getDataIDs');
                    // グリッドの先頭行選択
                    if (ids.length > 0) {
                        $("#" + 1).removeClass("ui-state-highlight").find("td").click();
                    }
                },
                onCellSelect: function (rowid, icol, cellcontent) {
                    // 原料スプレッドの行選択を解除
                    genGrid.resetSelection();
                },
                ondblClickRow: function (selectedRowId) {
                    // 検索前バリデーション
                    var result = $(".search-criteria").validation().validate();
                    if (result.errors.length) {
                        return;
                    }

                    var inputValue = $("#condition-after_change").val();
                    // 変更後製造予定数の設定
                    if (App.isUndefOrNull(inputValue)
                        || inputValue.length === 0) {
                        // 変更後製造予定数が入力されていない場合

                        // 変更後製造予定数に『0』を表示させる(変更後製造予定数クリア時に変数『aftSuSeizoYotei』には0が代入されている)
                        $("#condition-after_change").val(aftSuSeizoYotei);
                    }

                    // 検索条件変更チェック
                    if (!noChangeCriteria()) {
                        // 検索条件が変更されている場合

                        // メッセージの表示
                        App.ui.page.notifyInfo.message(
                            App.str.format(pageLangText.changeCriteria.text, pageLangText.searchCriteria.text, pageLangText.show.text)
                        ).show();
                    }
                    else {
                        // 検索条件が変更されていない場合

                        // 原資材情報のクリア
                        clearInfoGenshi();
                        // 選択原資材：原資材コードの設定
                        selGenshiCdGenshizai = shiGrid.getCell(selectedRowId, "cd_shizai");
                        // 選択原資材：原資材名の設定
                        selGenshiNmGenshizai = shiGrid.getCell(selectedRowId, "nm_shizai");
                        // 選択原資材：品区分の設定
                        selGenshiKbnHin = shiGrid.getCell(selectedRowId, "kbn_hin");
                        // 選択原資材：納入単価の設定
                        selGenshiTanNonyu = shiGrid.getCell(selectedRowId, "tan_nonyu");
                        // 選択原資材：税区分の設定
                        selGenshiKbnZei = shiGrid.getCell(selectedRowId, "kbn_zei");
                        // 選択原資材：変更前使用量の設定
                        selGenshiBefWtShiyo = deleteThousandsSeparator(shiGrid.getCell(selectedRowId, "shizai_bef_wt_shiyo"));
                        // 選択原資材：変更後使用量の設定
                        selGenshiAftWtShiyo = deleteThousandsSeparator(shiGrid.getCell(selectedRowId, "shizai_wt_shiyo"));
                        // 原資材情報の設定
                        setGenshiInfo(selectedRowId);
                    }
                }
            });

            /// <summary>明細原料(原料スプレッド)の行の背景色をformatします</summary>
            function genGridRowColorFormat(cellValue, option, rowObject) {
                if (cellValue === parseInt(pageLangText.mishiyoMishiyoFlg.text)) {
                    var elm = $("#" + option.rowId, genGrid);
                    elm.toggleClass("ui-widget-content");
                    elm.toggleClass("mishiyo-row");
                }
                return cellValue;
            }

            /// <summary>明細資材(資材スプレッド)の行の背景色をformatします</summary>
            function shiGridRowColorFormat(cellValue, option, rowObject) {
                if (cellValue === parseInt(pageLangText.mishiyoMishiyoFlg.text)) {
                    var elm = $("#" + option.rowId, shiGrid);
                    elm.toggleClass("ui-widget-content");
                    elm.toggleClass("mishiyo-row");
                }
                return cellValue;
            }

            /// <summary>日付型のセルをunformatします</summary>
            function unformatDate(cellValue, options) {
                var nbsp = String.fromCharCode(160);
                if (cellValue == nbsp) {
                    return "";
                }
                return cellValue;
            }

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
                    //var kanzan = Math.pow(10, parseInt(fixeVal));   // べき乗
                    // 指定の桁数以降は切捨て
                    //returnVal = Math.floor(App.data.trimFixed(returnVal * kanzan)) / kanzan;
                    // ゼロ埋め
                    returnVal = returnVal.toFixed(fixeVal); // toFixed：収まらない場合は四捨五入される
                    // カンマ区切りにする
                    returnVal = setThousandsSeparator(returnVal);
                }
                return returnVal;
            }
            /*
            /// <summary>【切り上げ版】小数点以下三位を切り上げする</summary>
            /// <param name="value">セルの値</param>
            /// <param name="options">オプション</param>
            /// <param name="rowObj">行データ</param>
            function changeZeroToBlankCeiling(value, options, rowObj) {
            var returnVal = deleteThousandsSeparator(value);
            if (App.isUndefOrNull(returnVal) || isNaN(returnVal)) {
            returnVal = "";
            }
            else {
            // 小数点以下の桁数を固定にする
            var fixeVal = options.colModel.formatoptions.decimalPlaces; // 丸め位置
            var kanzan = Math.pow(10, parseInt(fixeVal));   // べき乗
            // 指定の桁数以降は切り上げ
            var kanzanVal = Math.ceil(App.data.trimFixed(returnVal * kanzan));
            returnVal = App.data.trimFixed(kanzanVal / kanzan);
            // ゼロ埋め
            returnVal = returnVal.toFixed(fixeVal); // toFixed：収まらない場合は四捨五入される
            // カンマ区切りにする
            returnVal = setThousandsSeparator(returnVal);
            }
            return returnVal;
            }*/

            /// <summary>値のカンマ区切りを除去して数値にして返却します。</summary>
            /// <param name="value">値</param>
            var deleteThousandsSeparator = function (value) {
                return parseFloat(new String(value).replace(/,/g, ""));
            };

            /// <summary>値をカンマ区切りにして返却します。</summary>
            /// <param name="value">値</param>
            var setThousandsSeparator = function (value) {
                var str = value;
                var num = new String(str).replace(/,/g, "");
                while (num != (num = num.replace(/^(-?\d+)(\d{3})/, "$1,$2")));
                return num;
            };

            // <summary>現在日付をスラッシュ区切りで取得する</summary>
            var getDate = function () {
                var date = new Date();
                if (App.ui.page.lang == 'ja' || App.ui.page.lang == 'zh') {
                    date = [date.getFullYear(), ('0' + (date.getMonth() + 1)).slice(-2), ('0' + date.getDate()).slice(-2)].join('/');
                }
                else if (App.ui.page.langCountry == 'en-US') {
                    date = [('0' + (date.getMonth() + 1)).slice(-2), ('0' + date.getDate()).slice(-2), date.getFullYear()].join('/');
                }
                else {
                    date = [('0' + date.getDate()).slice(-2), ('0' + (date.getMonth() + 1)).slice(-2), date.getFullYear()].join('/');
                }
                return date;
            };

            /// <summary>時間を省いたシステム日付を日付オブジェクトで取得する</summary>
            var getSystemDate = function () {
                var sysdate = new Date(new Date().getFullYear(), new Date().getMonth(), new Date().getDate());
                return sysdate;
            };

            // <summary>nullまたは0の場合デフォルト値を設定。値があればparseFloatする。</summary>
            /// <param name="value">チェックする値</param>
            /// <param name="defValu">デフォルト値</param>
            var setDefaultOrParseFloat = function (value, defValu) {
                var resultVal = defValu;
                if (!App.isUndefOrNull(value) && value != 0 && value != "") {
                    resultVal = parseFloat(value);
                }
                return resultVal;
            };

            // <summary>使用量、在庫量による在庫数の計算処理</summary>
            /// <param name="val1">在庫数</param>
            /// <param name="val2">変更前数</param>
            /// <param name="val3">変更後数</param>
            var calZaikoShiyo = function (val1, val2, val3) {
                // 小数点つきの値を整数に直してから計算する
                var wtZaiko = App.data.trimFixed(val1 * KANZAN) | 0,
                //beforeSuryo = App.data.trimFixed(val2 * KANZAN) | 0,
                    beforeSuryo = Math.ceil(App.data.trimFixed(val2 * KANZAN)) | 0,
                    afterSuryo = App.data.trimFixed(val3 * KANZAN) | 0;

                // 在庫量 + 変更前数 - 変更後数
                var returnVal = App.data.trimFixed((wtZaiko + beforeSuryo - afterSuryo) / KANZAN);

                return returnVal;
            };

            // <summary>納入量による在庫数の計算処理</summary>
            /// <param name="val1">在庫数</param>
            /// <param name="val2">変更前数</param>
            /// <param name="val3">変更後数</param>
            var calZaikoNonyu = function (val1, val2, val3) {
                // 小数点つきの値を整数に直してから計算する
                var wtZaiko = App.data.trimFixed(val1 * KANZAN) | 0,
                    beforeSuryo = App.data.trimFixed(val2 * KANZAN) | 0,
                    afterSuryo = App.data.trimFixed(val3 * KANZAN) | 0;

                // 在庫量 - 変更前数 + 変更後数
                var returnVal = App.data.trimFixed((wtZaiko - beforeSuryo + afterSuryo) / KANZAN);

                return returnVal;
            };

            /// <summary>更新状態の変更セットに変更データを追加します。</summary>
            /// <param name="selectedRowId">選択行ID</param>
            /// <param name="cellName">列名</param>
            var changeSetUpdated = function (selectedRowId, cellName) {
                // 更新状態の変更データの設定
                var changeData = setUpdatedChangeData(simuGrid.getRowData(selectedRowId));
                // 更新値の設定
                var value = changeData[cellName];
                // 更新状態の変更セットに変更データを追加
                changeSet.addUpdated(selectedRowId, cellName, value, changeData);
            };

            /// <summary>原資材情報を設定します。</summary>
            /// <param name="selectedRowId">選択行ID</param>
            var setGenshiInfo = function (selectedRowId) {
                // メッセージ欄をクリア
                App.ui.page.notifyInfo.clear();
                App.ui.page.notifyAlert.clear();

                App.deferred.parallel({
                    // ローディングの表示
                    //loading: App.ui.loading.show(pageLangText.nowProgressing.text),
                    // [原資材購入先マスタ]取得SQL
                    maKonyu: App.ajax.webgetSync(
                    "../Services/FoodProcsService.svc/ma_konyu()?$filter=cd_hinmei eq '"
                    + selGenshiCdGenshizai
                    + "' and flg_mishiyo eq "
                    + pageLangText.shiyoMishiyoFlg.text
                    + "&$orderby=no_juni_yusen"
                    + "&$top=1")
                }).done(function (result) {
                    // [原資材購入先マスタ]の取得
                    maKonyu = result.successes.maKonyu.d;

                    var cdKonyu = "",
                        nmKonyu = "",
                        leadTime = "",
                        minZaiko = "",
                        hachuLot = "",
                        nonyuTani = "",
                        shiyoTani;

                    if (!App.isUndefOrNull(maKonyu) && maKonyu.length > 0) {
                        // [原資材購入先マスタ]が取得できた場合

                        // 原資材情報/購入先コードに取得した[原資材購入先マスタ].[取引先コード]を設定
                        cdKonyu = maKonyu[0]["cd_torihiki"];
                        // 原資材情報/購入先名に取得した[取引先マスタ].[取引先名]を設定
                        nmKonyu = getNmKonyu(maKonyu[0]["cd_torihiki"]);
                        // 原資材情報/納入リードタイムに取得した[原資材購入先マスタ].[納入リードタイム]を設定
                        leadTime = maKonyu[0]["su_leadtime"];
                        // 原資材情報/発注ロットサイズに取得した[原資材購入先マスタ].[発注ロットサイズ]と納入単位名を連結して設定
                        hachuLot = maKonyu[0]["su_hachu_lot_size"];
                        // [原資材購入先マスタ].[納入単位]を基に取得した納入単位名
                        nonyuTani = getNmTani(maKonyu[0]["cd_tani_nonyu"]);

                        if (selGenshiKbnHin === pageLangText.genryoHinKbn.text
                                || selGenshiKbnHin === pageLangText.jikaGenryoHinKbn.text) {
                            // 選択原資材：品区分が原料または自家原料の場合

                            // 明細原料(原料スプレッド)の隠し項目：最低在庫を設定
                            minZaiko = genGrid.getCell(selectedRowId, "su_zaiko_min");
                            // 明細原料(原料スプレッド)の隠し項目：使用単位コードをもとに取得した使用単位名を設定
                            shiyoTani = getNmTani(genGrid.getCell(selectedRowId, "cd_tani_shiyo"));
                        }
                        else {
                            // 選択原資材：品区分が資材の場合

                            // 明細資材(資材スプレッド)の隠し項目：最低在庫を設定
                            minZaiko = shiGrid.getCell(selectedRowId, "su_zaiko_min");
                            // 明細資材(資材スプレッド)の隠し項目：使用単位コードをもとに取得した使用単位名を設定
                            shiyoTani = getNmTani(shiGrid.getCell(selectedRowId, "cd_tani_shiyo"));
                        }

                        // 選択原資材：取引先コード２に取得した[原資材購入先マスタ].[取引先コード２]を設定
                        selGenshiCdTorihiki2 = maKonyu[0]["cd_torihiki2"];
                        // 選択原資材：納入単価に取得した[原資材購入先マスタ].[納入単価]を設定
                        selGenshiTanNonyu = maKonyu[0]["tan_nonyu"];
                    }
                    else {
                        // [原資材購入先マスタ]が取得できなかった場合

                        if (selGenshiKbnHin === pageLangText.genryoHinKbn.text
                                || selGenshiKbnHin === pageLangText.jikaGenryoHinKbn.text) {
                            /// 選択原資材：品区分が原料または自家原料の場合

                            // 明細原料(原料スプレッド)の隠し項目：納入リードタイムを設定
                            leadTime = genGrid.getCell(selectedRowId, "dd_leadtime");
                            // 明細原料(原料スプレッド)の隠し項目：最低在庫を設定
                            minZaiko = changeValueNullToBlank(genGrid.getCell(selectedRowId, "su_zaiko_min"));
                            // 明細原料(原料スプレッド)の隠し項目：発注ロットサイズ
                            hachuLot = genGrid.getCell(selectedRowId, "su_hachu_lot_size");
                            // 明細原料(原料スプレッド)の隠し項目：納入単位名
                            nonyuTani = getNmTani(genGrid.getCell(selectedRowId, "cd_tani_nonyu"));
                            // 明細原料(原料スプレッド)の隠し項目：使用単位コード
                            shiyoTani = getNmTani(genGrid.getCell(selectedRowId, "cd_tani_shiyo"));
                        }
                        else {
                            /// 選択原資材：品区分が資材の場合

                            // 明細資材(資材スプレッド)の隠し項目：納入リードタイムを設定
                            leadTime = shiGrid.getCell(selectedRowId, "dd_leadtime");
                            // 明細資材(資材スプレッド)の隠し項目：最低在庫を設定
                            minZaiko = changeValueNullToBlank(shiGrid.getCell(selectedRowId, "su_zaiko_min"));
                            // 明細資材(資材スプレッド)の隠し項目：発注ロットサイズ
                            hachuLot = shiGrid.getCell(selectedRowId, "su_hachu_lot_size");
                            // 明細資材(資材スプレッド)の隠し項目：納入単位名
                            nonyuTani = getNmTani(shiGrid.getCell(selectedRowId, "cd_tani_nonyu"));
                            // 明細資材(資材スプレッド)の隠し項目：使用単位コード
                            shiyoTani = getNmTani(shiGrid.getCell(selectedRowId, "cd_tani_shiyo"));
                        }
                    }

                    /// 原資材情報の設定
                    $("#genshi-cd_konyu").text(cdKonyu);
                    $("#genshi-nm_konyu").text(nmKonyu)
                    $("#genshi-leadtime").text(leadTime);
                    if (!App.isUndefOrNull(minZaiko)) {
                        $("#genshi-zaiko_min").text(setThousandsSeparator(minZaiko));
                    }
                    else {
                        $("#genshi-zaiko_min").text("");
                    }
                    if (!App.isUndefOrNull(hachuLot)) {
                        // 発注ロットサイズと納入単位名を連結して設定
                        $("#genshi-hachu_lot_size").text(setThousandsSeparator(hachuLot) + nonyuTani);
                    }
                    else {
                        $("#genshi-hachu_lot_size").text("");
                    }
                    $("#genshi-tani_shiyo").text(shiyoTani);

                    // シミュレーションスプレッドの項目名の設定
                    setLabel_suNonyu();

                    // 計算在庫存在チェック
                    if (noZaiko()) {
                        // 選択された原資材コードについて11日前の計算在庫が存在しない場合

                        // 計算在庫存在チェックエラーメッセージ表示
                        App.ui.page.notifyAlert.message(App.str.format(pageLangText.zaikoNotFound.text)).show();
                    }
                    else {
                        // 選択された原資材コードについて11日前の計算在庫が存在する場合

                        // 明細(シミュレーションスプレッド)の設定
                        setSimuInfo(selectedRowId);
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
                    App.ui.loading.close();
                    //}).always(function () {
                    // ローディングの終了
                    //App.ui.loading.close();
                });
            };

            /// <summary>[単位マスタ]より[単位名]を取得します。</summary>
            /// <param name="param_cd_tani">単位コード</param>
            var getNmTani = function (param_cd_tani) {
                var nmTani = "";
                App.deferred.parallel({
                    // [単位マスタ]取得SQL
                    maTani: App.ajax.webgetSync(
                    "../Services/FoodProcsService.svc/ma_tani()?$filter=cd_tani eq '"
                    + param_cd_tani
                    + "' and flg_mishiyo eq "
                    + pageLangText.shiyoMishiyoFlg.text
                    + "&$top=1")
                }).done(function (result) {
                    // [単位マスタ]の取得
                    maTani = result.successes.maTani.d;

                    if (!App.isUndefOrNull(maTani)
                        && maTani.length > 0) {
                        // [単位マスタ]が取得できた場合

                        // 戻り値に取得した[単位マスタ].[単位名]を設定
                        nmTani = maTani[0]["nm_tani"];
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
                    App.ui.loading.close();
                });
                return nmTani;
            };

            /// <summary>[取引先マスタ]より[取引先名]を取得します。</summary>
            /// <param name="param_cd_torihiki">取引先コード</param>
            var getNmKonyu = function (param_cd_torihiki) {
                var nmKonyu = "";
                App.deferred.parallel({
                    // [取引先マスタ]取得SQL
                    maTorihiki: App.ajax.webgetSync(
                    "../Services/FoodProcsService.svc/ma_torihiki()?$filter=cd_torihiki eq '"
                    + param_cd_torihiki
                    + "' and flg_mishiyo eq "
                    + pageLangText.shiyoMishiyoFlg.text
                    + "&$top=1")
                }).done(function (result) {
                    // [取引先マスタ]の取得
                    maTorihiki = result.successes.maTorihiki.d;

                    if (!App.isUndefOrNull(maTorihiki)
                        && maTorihiki.length > 0) {
                        // [取引先マスタ]が取得できた場合

                        // 戻り値に取得した[取引先マスタ].[取引先名]を設定
                        nmKonyu = maTorihiki[0]["nm_torihiki"];
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
                    App.ui.loading.close();
                });
                return nmKonyu;
            };

            /// <summary>選択された原資材コードについて11日前の計算在庫が存在するかチェックします。</summary>
            var noZaiko = function () {
                var isError = false,
                    criteria = $(".search-criteria").toJSON(),
                    beforeElevenDate = new Date(criteria.con_dt_hizuke.getFullYear(), criteria.con_dt_hizuke.getMonth(), criteria.con_dt_hizuke.getDate() - 11),
                    query = {
                        url: "../Services/FoodProcsService.svc/tr_genshizai_keikaku",
                        filter: "cd_hinmei eq '" + selGenshiCdGenshizai + "'",
                        top: 1
                    };
                // 原資材計画管理トラン存在チェック
                App.ajax.webgetSync(
                    App.data.toODataFormat(query)
                ).done(function (result) {
                    if (result.d.length === 0) {
                        // 検索結果件数が0件の場合

                        // 計算在庫存在チェックエラー
                        isError = true;
                    }
                    else {
                        // 検索結果が取得できた場合
                        var dtZaikoKeisan = result.d[0]["dt_zaiko_keisan"];
                        if (!App.isUndefOrNull(dtZaikoKeisan)) {
                            if (App.date.localDate(App.data.getDate(dtZaikoKeisan), true) < App.date.localDate(beforeElevenDate, true)) {
                                // 取得した[原資材計画管理トラン].[計算在庫自動作成最終日] < 検索日付の11日前 の場合

                                // 計算在庫存在チェックエラー
                                isError = true;
                            }
                        }
                        else {
                            // 取得した[原資材計画管理トラン].[計算在庫自動作成最終日]が存在しない場合
                            // 計算在庫存在チェックエラー
                            isError = true;
                        }
                    }
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                    App.ui.loading.close();
                });
                return isError;
            };

            /// <summary>明細(シミュレーションスプレッド)を取得し設定します。</summary>
            /// <param name="selectedRowId">選択行ID</param>
            var setSimuInfo = function (selectedRowId) {
                var criteria = $(".search-criteria").toJSON(),
                    query = {
                        url: "../api/HendoHyoSimulation",
                        con_cd_hinmei: selGenshiCdGenshizai,
                        con_dt_hizuke: App.data.getDateTimeStringForQueryNoUtc(criteria.con_dt_hizuke),
                        one_day_flg: null,
                        flg_yojitsu_yo: pageLangText.yoteiYojitsuFlg.text,
                        flg_yojitsu_ji: pageLangText.jissekiYojitsuFlg.text,
                        today: App.data.getDateTimeStringForQueryNoUtc(getSystemDate())
                    };
                // 明細(シミュレーションスプレッド)検索
                App.ajax.webgetSync(
                    App.data.toWebAPIFormat(query)
                ).done(function (result) {
                    if (result.length > 0) {
                        // 検索結果が取得できた場合

                        // changeSetをリセット
                        changeSet = new App.ui.page.changeSet()
                        // 明細のスクロール位置をリセット
                        $(".ui-jqgrid-hdiv").scrollLeft(0);
                        // データクリア
                        simuGrid.clearGridData();
                        // データバインド
                        bindSimuData(result);
                        // 変更後情報の設定
                        setAfterInfo(selectedRowId);
                        // 明細(シミュレーションスプレッド)制御設定
                        setControlSimuGrid();
                    }
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                    App.ui.loading.close();
                });
            };

            /// <summary>変更後情報を設定します。</summary>
            /// <param name="selectedRowId">選択行ID</param>
            var setAfterInfo = function (selectedRowId) {
                var ids = simuGrid.jqGrid('getDataIDs'),
                    criteria = $(".search-criteria").toJSON(),
                    dtHizuke = App.data.getDateString(criteria.con_dt_hizuke, true),
                    wkBefWtShiyo,
                    wkAftWtShiyo;
                for (var i = 0; i < ids.length; i++) {
                    var id = ids[i],
                        wkBefWtZaiko = deleteThousandsSeparator(simuGrid.getCell(id, "before_wt_zaiko"));
                    wkBefWtShiyo = simuGrid.getCell(id, "before_wt_shiyo");

                    if (!App.isUndefOrNull(wkBefWtShiyo)
                        && wkBefWtShiyo.length > 0) {
                        // 変更前使用量が設定されている場合

                        // 変更前使用量を数値変換
                        wkBefWtShiyo = deleteThousandsSeparator(wkBefWtShiyo);
                    }
                    else {
                        // 変更前使用量が設定されていない場合

                        // 変更前使用量に『0』を設定
                        wkBefWtShiyo = 0;
                    }

                    var simDate = App.date.localDate(simuGrid.getCell(id, "dt_ymd"));
                    var targetDate = App.date.localDate(dtHizuke);
                    var sysdate = App.date.localDate(getDate());

                    // ----- 使用量の設定処理 -----
                    if (simDate.getTime() == targetDate.getTime()) {
                        ///// 指定日＝明細の日付の場合

                        // 変更前使用量：SPで計算済なので、ここでは特に設定しない

                        // 変更後使用量：『変更前使用量 - 選択原資材：変更前使用量 + 選択原資材：変更後使用量』を設定
                        simuGrid.setCell(id, "after_wt_shiyo", wkBefWtShiyo - selGenshiBefWtShiyo + selGenshiAftWtShiyo);
                    }

                    // ----- 在庫量の設定処理 -----
                    if (sysdate.getTime() == targetDate.getTime() && simDate.getTime() == targetDate.getTime()) {
                        ///// 指定日が当日 かつ 指定日＝明細の日付の場合
                        var jitsuZaiko = simuGrid.getCell(id, "su_zaiko");
                        if (!App.isUndefOrNull(jitsuZaiko) && jitsuZaiko.length > 0) {
                            // 実在庫数が存在すれば、変更前在庫量と変更後在庫量に実在庫数を設定し、計算処理は行わない
                            simuGrid.setCell(id, "before_wt_zaiko", jitsuZaiko);
                            simuGrid.setCell(id, "after_wt_zaiko", jitsuZaiko);
                            // 使用量をクリア
                            selGenshiBefWtShiyo = 0;
                            selGenshiAftWtShiyo = 0;
                        }
                        else {
                            simuGrid.setCell(id, "after_wt_zaiko", calZaikoShiyo(wkBefWtZaiko, selGenshiBefWtShiyo, selGenshiAftWtShiyo));
                        }
                    }
                    else if (simDate >= targetDate) {
                        ///// 指定日以降の場合

                        // 変更後在庫量に『変更前在庫量 + 選択原資材：変更前使用量 - 選択原資材：変更後使用量』を設定
                        simuGrid.setCell(id, "after_wt_zaiko", calZaikoShiyo(wkBefWtZaiko, selGenshiBefWtShiyo, selGenshiAftWtShiyo));
                    }
                    else {
                        ///// 指定日より過去日の場合

                        // 変更後在庫量に変更前在庫量を設定
                        simuGrid.setCell(id, "after_wt_zaiko", wkBefWtZaiko);
                    }
                }
            };

            /// <summary>セルの関連項目を設定します。</summary>
            /// <param name="selectedRowId">選択行ID</param>
            /// <param name="cellName">列名</param>
            /// <param name="value">元となる項目の値</param>
            /// <param name="iCol">項目の列番号</param>
            var setRelatedValue = function (selectedRowId) {
                var nonyu = simuGrid.jqGrid('getCell', selectedRowId, 'after_su_nonyu') ? simuGrid.jqGrid('getCell', selectedRowId, 'after_su_nonyu') : "0",
                    su_ko = simuGrid.jqGrid('getCell', selectedRowId, 'su_ko') ? simuGrid.jqGrid('getCell', selectedRowId, 'su_ko') : "0",
                    su_iri = simuGrid.jqGrid('getCell', selectedRowId, 'su_iri') ? simuGrid.jqGrid('getCell', selectedRowId, 'su_iri') : "0",
                    cd_tani = simuGrid.jqGrid('getCell', selectedRowId, 'cd_tani');

                nonyu = deleteThousandsSeparator(nonyu);
                su_ko = deleteThousandsSeparator(su_ko);
                su_iri = deleteThousandsSeparator(su_iri);

                // 個数ｘ入数
                //var su_ko_iri = App.data.calculatorMultiply(su_ko, su_iri);
                var su_ko_iri = App.data.trimFixed(su_ko * su_iri);
                // 納入数 ÷（個数ｘ入数）
                //var calcNonyu = App.data.calculatorDivide(nonyu, su_ko_iri);
                var calcNonyu = App.data.trimFixed(nonyu / su_ko_iri);

                ///// 納入単位へ換算【ビジネスルール：BIZ00008】
                //var nonyu_cs = Math.floor(nonyu / (su_ko * su_iri));
                nonyu_cs = Math.floor(calcNonyu);
                var nonyuVal2 = 0,
                    calHasu = 0;
                if (cd_tani == pageLangText.kgCdTani.text || cd_tani == pageLangText.lCdTani.text) {
                    // 単位がKgまたはLの場合
                    // ((使用単位 / (1個の量×入数)) - 納入単位(納入数))×1000
                    //nonyu_hasu = (Math.floor(nonyu / (su_ko * su_iri) * 1000) - (Math.floor(nonyu / (su_ko * su_iri)) * 1000)) / 1000;
                    //nonyu_hasu = (Math.floor(calcNonyu * 1000) - (nonyu_cs * 1000)) / 1000;

                    // 保存処理に合わせて切り上げ
                    calHasu = Math.ceil(App.data.trimFixed((calcNonyu - nonyu_cs) * 1000));
                    nonyu_hasu = App.data.trimFixed((calHasu / 1000) * 1000);
                    // DBは小数以下2ケタなので、2ケタ以下を切り捨てる
                    //nonyu_hasu = App.data.trimFixed(Math.floor(nonyu_hasu * 100) / 100);
                    // DBは小数以下3ケタなので、3ケタ以下を切り捨てる
                    nonyu_hasu = App.data.trimFixed(Math.floor(nonyu_hasu * KANZAN) / KANZAN);

                    // 【ビジネスルール：BIZ00009】
                    nonyuVal2 = App.data.trimFixed(nonyu_hasu / 1000);
                }
                else {
                    // 上記以外の場合
                    // ((使用単位 / (1個の量×入数)) - 納入単位(納入数))×入数
                    //nonyu_hasu = Math.ceil((Math.ceil(nonyu / (su_ko * su_iri) * 1000) - (nonyu_cs * 1000)) * su_iri / 10) / 100;
                    //var calValue1 = App.data.calculatorSubtract((Math.ceil(calcNonyu * 1000)), (nonyu_cs * 1000));
                    //var calValue2 = App.data.calculatorMultiply(calValue1, su_iri);
                    //nonyu_hasu = Math.ceil(calValue2 / 10) / 100;

                    // 保存処理に合わせて切り上げ
                    //calHasu = Math.ceil(App.data.trimFixed((calcNonyu - nonyu_cs) * 1000));
                    //nonyu_hasu = App.data.trimFixed((calHasu / 1000) * su_iri);
                    calHasu = Math.floor(App.data.trimFixed(App.data.trimFixed(calcNonyu - nonyu_cs) * 1000));
                    nonyu_hasu = Math.ceil(App.data.trimFixed(App.data.trimFixed(calHasu / 1000) * su_iri));

                    //nonyu_hasu = Math.ceil(calValue2);  // 端数があれば1C/S切り上げる場合。その場合は発注ロットサイズ分足す。
                    // DBは小数以下2ケタなので、2ケタ以下を切り捨てる
                    //nonyu_hasu = App.data.trimFixed(Math.floor(nonyu_hasu * 100) / 100);

                    // 【ビジネスルール：BIZ00009】
                    nonyuVal2 = App.data.trimFixed(nonyu_hasu * su_ko);
                    if (nonyuVal2 != 0 && nonyuVal2 < parseInt(su_ko, 10)) {
                        nonyuVal2 = parseInt(su_ko, 10);
                    }
                }

                ///// 使用単位へ換算
                //nonyu = nonyu_cs * (su_ko * su_iri) + (nonyu_hasu * su_ko);
                //var nonyuVal1 = App.data.calculatorMultiply(nonyu_cs, su_ko_iri);
                var nonyuVal1 = App.data.trimFixed(nonyu_cs * su_ko_iri);
                //var nonyuVal2 = App.data.calculatorMultiply(nonyu_hasu, su_ko);
                nonyu = App.data.trimFixed(nonyuVal1 + nonyuVal2);

                simuGrid.jqGrid('setCell', selectedRowId, 'after_su_nonyu', nonyu);
            };

            /// <summary>在庫量の更新を行います。</summary>
            /// <param name="updateRow">変更行データ</param>
            /// <param name="selectedRowId">変更行番号</param>
            var updateWtZaiko = function (updateRow, selectedRowId) {
                var ids = simuGrid.jqGrid('getDataIDs'),
                    updateDate = updateRow.dt_ymd,
                    wkBefSuNonyu = updateRow.before_su_nonyu,
                    wkAftSuNonyu = updateRow.after_su_nonyu;
                //wkBefWtZaiko,
                //wkAftWtZaiko;
                if (wkBefSuNonyu.length > 0) {
                    // 変更前納入数に値が入っている場合

                    // 変更前納入数を数値変換
                    wkBefSuNonyu = deleteThousandsSeparator(wkBefSuNonyu);
                }
                else {
                    // 変更前納入数に値が入っていない場合

                    // 変更前納入数に『0』を設定
                    wkBefSuNonyu = 0;
                }

                if (wkAftSuNonyu.length > 0) {
                    // 変更後納入数に値が入っている場合

                    // 変更後納入数を数値変換
                    wkAftSuNonyu = deleteThousandsSeparator(wkAftSuNonyu);
                }
                else {
                    // 変更後納入数に値が入っていない場合

                    // 変更後納入数に『0』を設定
                    wkAftSuNonyu = 0;
                }

                for (var i = 0; i < ids.length; i++) {
                    var id = ids[i];
                    var dtYmd = App.date.localDate(simuGrid.getCell(id, "dt_ymd"));
                    if (dtYmd.getTime() == App.date.localDate(updateDate).getTime()) {
                        // 在庫更新日の場合

                        var jitsuZaiko = simuGrid.getCell(id, "su_zaiko");
                        if (!App.isUndefOrNull(jitsuZaiko) && jitsuZaiko.length > 0) {
                            ///// 実在庫数が存在すれば、変更前在庫量と変更後在庫量に実在庫数を設定し、計算処理は行わない
                            simuGrid.setCell(id, "before_wt_zaiko", jitsuZaiko);
                            simuGrid.setCell(id, "after_wt_zaiko", jitsuZaiko);
                        }
                        else {
                            // 変更前在庫量と変更後在庫量の計算と設定処理
                            setWtZaiko(id, wkBefSuNonyu, wkAftSuNonyu);
                        }
                    }
                    else if (dtYmd > App.date.localDate(updateDate)) {
                        ///// 在庫更新日の翌日以降の場合

                        // 変更前在庫量と変更後在庫量の計算と設定処理
                        setWtZaiko(id, wkBefSuNonyu, wkAftSuNonyu);
                    }
                }
                // 変更前納入数の設定
                simuGrid.setCell(selectedRowId, "before_su_nonyu", wkAftSuNonyu);
            };

            /// <summary>変更前在庫量と変更後在庫量の計算と設定処理</summary>
            /// <param name="id">変更行番号</param>
            /// <param name="wkBefSuNonyu">変更前納入数</param>
            /// <param name="wkBefSuNonyu">変更後納入数</param>
            var setWtZaiko = function (id, wkBefSuNonyu, wkAftSuNonyu) {
                var wkBefWtZaiko = deleteThousandsSeparator(simuGrid.getCell(id, "before_wt_zaiko"));
                var wkAftWtZaiko = deleteThousandsSeparator(simuGrid.getCell(id, "after_wt_zaiko"));
                // 変更前在庫量に『検索時変更前在庫量 - 変更前納入数 + 変更後納入数』を設定
                //simuGrid.setCell(id, "before_wt_zaiko", wkBefWtZaiko - wkBefSuNonyu + wkAftSuNonyu);
                simuGrid.setCell(id, "before_wt_zaiko", calZaikoNonyu(wkBefWtZaiko, wkBefSuNonyu, wkAftSuNonyu));
                if (deleteThousandsSeparator(simuGrid.getCell(id, "before_wt_zaiko")) < 0) {
                    // 変更前在庫量 < 0 の場合

                    // 変更前在庫量の文字色を変更
                    simuGrid.setCell(id, "before_wt_zaiko", '', { color: '#ff0000' });
                }
                else {

                    // 変更前在庫量の文字色を変更
                    simuGrid.setCell(id, "before_wt_zaiko", '', { color: '#000000' });
                }
                // 変更後在庫量に『検索時変更後在庫量 - 変更前納入数 + 変更後納入数』を設定
                //simuGrid.setCell(id, "after_wt_zaiko", wkAftWtZaiko - wkBefSuNonyu + wkAftSuNonyu);
                simuGrid.setCell(id, "after_wt_zaiko", calZaikoNonyu(wkAftWtZaiko, wkBefSuNonyu, wkAftSuNonyu));
                if (deleteThousandsSeparator(simuGrid.getCell(id, "after_wt_zaiko")) < 0) {
                    // 変更後在庫量 < 0 の場合

                    // 変更後在庫量の文字色を変更
                    simuGrid.setCell(id, "after_wt_zaiko", '', { color: '#ff0000' });
                }
                else {
                    // 変更後在庫量の文字色を変更
                    simuGrid.setCell(id, "after_wt_zaiko", '', { color: '#000000' });
                }
            };

            /// <summary>シミュレーションスプレッド．ヘッダー名の設定処理</summary>
            var setLabel_suNonyu = function () {
                var colModel = simuGrid.jqGrid("getGridParam", "colModel"),
                    nonyuCol = simuGrid.getColumnIndexByName("after_su_nonyu");
                // 選択した原資材スプレッドの品区分が自家原料の場合は「製造数」、それ以外は「納入数」
                if (selGenshiKbnHin == pageLangText.jikaGenryoHinKbn.text) {
                    simuGrid.jqGrid("setLabel", colModel[nonyuCol].name, pageLangText.su_seizo.text);
                }
                else {
                    simuGrid.jqGrid("setLabel", colModel[nonyuCol].name, pageLangText.after_su_nonyu.text);
                }
            };

            /// <summary>値がnullの場合は空白を返却する</summary>
            var changeValueNullToBlank = function (value) {
                var ret = "";
                if (!App.isUndefOrNull(value)) {
                    ret = value;
                }
                return ret;
            };

            //// コントロール定義 -- End

            //// 操作制御定義 -- Start

            // 操作制御定義を定義します。
            App.ui.pagedata.operation.applySetting(App.ui.page.user.Roles[0], App.ui.page.lang);

            /// <summary>明細(シミュレーションスプレッド)の制御を設定します。</summary>
            var setControlSimuGrid = function () {
                var ids = simuGrid.jqGrid('getDataIDs'),
                    todayDate = getDate();
                for (var i = 0; i < ids.length; i++) {
                    var id = ids[i];
                    // 納入数(製造数)の編集制御
                    if (selGenshiKbnHin == pageLangText.jikaGenryoHinKbn.text) {
                        // 選択した原資材スプレッドの品区分が自家原料の場合はすべて編集不可
                        simuGrid.jqGrid('setCell', id, 'after_su_nonyu', '', 'not-editable-cell');
                    }
                    else {
                        if (App.date.localDate(simuGrid.getCell(id, "dt_ymd")) < App.date.localDate(todayDate)) {
                            // 現在日付より過去日の場合

                            // 納入数を編集不可とする
                            simuGrid.jqGrid('setCell', id, 'after_su_nonyu', '', 'not-editable-cell');
                        }
                    }
                    if (simuGrid.getCell(id, "flg_kyujitsu") == pageLangText.trueFlg.text) {
                        // 休日の場合

                        // 明細行の背景色を変更する
                        simuGrid.toggleClassRow(id, "kyujitsu-row");
                    }
                    if (deleteThousandsSeparator(simuGrid.getCell(id, "before_wt_zaiko")) < 0) {
                        // 変更前在庫量 < 0 の場合

                        // 変更前在庫量の文字色を変更
                        simuGrid.setCell(id, "before_wt_zaiko", '', { color: '#ff0000' });
                    }
                    if (deleteThousandsSeparator(simuGrid.getCell(id, "after_wt_zaiko")) < 0) {
                        // 変更後在庫量 < 0 の場合

                        // 変更後在庫量の文字色を変更
                        simuGrid.setCell(id, "after_wt_zaiko", '', { color: '#ff0000' });
                    }
                }
            };

            /// <summary>明細原料(原料スプレッド)の制御を設定します。</summary>
            var setControlGenGrid = function () {
                var ids = genGrid.jqGrid('getDataIDs');
                for (var i = 0; i < ids.length; i++) {
                    var id = ids[i];
                    if (deleteThousandsSeparator(genGrid.getCell(id, "genryo_wt_zaiko")) < 0) {
                        // 在庫量 < 0 の場合

                        // 在庫量の文字色を変更
                        genGrid.setCell(id, "genryo_wt_zaiko", '', { color: '#ff0000' });
                    }
                }
            };

            /// <summary>明細資材(資材スプレッド)の制御を設定します。</summary>
            var setControlShiGrid = function () {
                var ids = shiGrid.jqGrid('getDataIDs');
                for (var i = 0; i < ids.length; i++) {
                    var id = ids[i];
                    if (deleteThousandsSeparator(shiGrid.getCell(id, "shizai_wt_zaiko")) < 0) {
                        // 在庫量 < 0 の場合

                        // 在庫量の文字色を変更
                        shiGrid.setCell(id, "shizai_wt_zaiko", '', { color: '#ff0000' });
                    }
                }
            };

            //// 操作制御定義 -- End

            //// 事前データロード -- Start 

            // 画面アーキテクチャ共通の事前データロード
            App.deferred.parallel({
                // ローディングの表示
                loading: App.ui.loading.show(pageLangText.nowProgressing.text)
            }).done(function (result) {
                // 検索条件/日付に当日日付を設定する
                $("#condition-dt_hizuke").datepicker("setDate", new Date());
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

            /// <summary>変更前製造予定数を取得します。</summary>
            var searchBefSuSeizoYotei = function () {
                var criteria = $(".search-criteria").toJSON();
                query = {
                    url: "../Services/FoodProcsService.svc/vw_tr_keikaku_seihin_02",
                    filter: "dt_seizo eq DateTime'" + App.data.getDateTimeStringForQueryNoUtc(criteria.con_dt_hizuke) +
                            "' and cd_hinmei eq '" + criteria.con_cd_hinmei +
                            "'",
                    top: 1
                };
                // ローディングの表示
                App.ui.loading.show(pageLangText.nowSaving.text);

                // 変更前製造予定数検索
                App.ajax.webgetSync(
                    App.data.toODataFormat(query)
                ).done(function (result) {
                    if (result.d.length > 0) {
                        // 検索結果が取得できた場合

                        // 検索条件/製造予定に取得した変更前製造予定数を設定
                        befSuSeizoYotei = parseInt(result.d[0]["sum_su_seizo_yotei"]);
                        $("#condition-seizo_yotei").text(
                                result.d[0]["sum_su_seizo_yotei"].replace(/((?:^-)?\d{1,3})(?=(?:\d{3})+(?!\d))/g, '$1,')
                            );
                    }
                    else {
                        // 検索結果が取得できない場合

                        // 検索条件/製造予定に0を設定
                        befSuSeizoYotei = 0;
                        $("#condition-seizo_yotei").text(befSuSeizoYotei);
                    }

                }).fail(function (result) {
                    // 内部エラー発生時
                    App.ui.page.notifyAlert.message(result.message).show();
                    App.ui.loading.close();
                    return;
                }).always(function () {
                    // ローディングの終了
                    App.ui.loading.close();
                });
            };

            /// <summary>明細原料クエリオブジェクトの設定</summary>
            var queryGenryo = function (su_seizo) {
                var criteria = $(".search-criteria").toJSON();
                var genryoQuery = {
                    url: "../api/HendoHyoSimulation",
                    hinmeiCode: criteria.con_cd_hinmei,
                    su_seizo_yotei: su_seizo,
                    dt_seizo: App.data.getDateTimeStringForQueryNoUtc(criteria.con_dt_hizuke),
                    shiyoFlag: pageLangText.shiyoMishiyoFlg.text
                };
                return genryoQuery;
            };

            /// <summary>明細資材クエリオブジェクトの設定</summary>
            var queryShizai = function () {
                var criteria = $(".search-criteria").toJSON();
                var shizaiQuery = {
                    url: "../api/HendoHyoSimulation",
                    seiziDate: App.data.getDateTimeStringForQueryNoUtc(criteria.con_dt_hizuke),
                    hinCode: criteria.con_cd_hinmei,
                    shiyoFlag: pageLangText.shiyoMishiyoFlg.text
                };
                return shizaiQuery;
            };

            /// <summary>検索条件を保持する</summary>
            var saveSearchCriteria = function () {
                var criteria = $(".search-criteria").toJSON();
                searchCriteriaSet = {
                    "con_dt_hizuke": criteria.con_dt_hizuke,
                    "con_cd_hinmei": criteria.con_cd_hinmei,
                    "con_after_change": criteria.con_after_change
                };
            };

            /// <summary>検索条件の変更チェック</summary>
            var noChangeCriteria = function () {
                var criteria = $(".search-criteria").toJSON();
                if (App.isUndefOrNull(searchCriteriaSet)
                    || (criteria.con_dt_hizuke.toString() == searchCriteriaSet.con_dt_hizuke.toString()
                        && criteria.con_cd_hinmei == searchCriteriaSet.con_cd_hinmei
                        && criteria.con_after_change == searchCriteriaSet.con_after_change)) {
                    // 検索条件が指定されていなかった または 検索条件が変更されていない場合、変更なしを返却する
                    return true;
                }
                // 検索条件が変更されている場合、変更ありを返却する
                return false;
            };

            /// <summary>明細原料(原料スプレッド)の検索を行います。</summary>
            /// <param name="query">クエリオブジェクト</param>
            var searchGenryo = function () {
                //var su_yotei = $("#condition-seizo_yotei").text();
                var su_yotei = $("#condition-seizo_yotei").text().split(",").join("");
                var yoteiQuery = new queryGenryo(su_yotei);

                // 検索処理1：変更前の使用量
                // コントローラー呼び出して原料スプレッドの検索を行う
                App.ajax.webgetSync(
                    App.data.toWebAPIFormat(yoteiQuery)
                ).done(function (result) {
                    //// 検索処理1の成功時

                    // 変更後C/S数をカンマ区切りを除去してから取得
                    var su_change = $("#condition-after_change").val().split(",").join("");
                    var changeQuery = new queryGenryo(su_change);
                    // データバインド
                    bindGenryoData(result);
                    // 明細原料関連情報設定
                    setGenryoWtShiyo("genryo_bef_wt_shiyo", result);    // 変更前使用量

                    // 検索処理2：変更後の使用量
                    App.ajax.webgetSync(
                        App.data.toWebAPIFormat(changeQuery)
                    ).done(function (result) {
                        //// 検索処理2の成功時

                        // 明細原料関連情報設定
                        setGenryoWtShiyo("genryo_wt_shiyo", result);    // 明細原料/使用量
                        setGenryoRelatedValue();
                        // 明細原料(原料スプレッド)制御設定
                        setControlGenGrid();
                    }).fail(function (result) {
                        App.ui.page.notifyAlert.message(result.message).show();
                        App.ui.loading.close();
                        isDataLoading = false;
                    })

                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                    App.ui.loading.close();
                    isDataLoading = false;
                })
            };

            /// <summary>明細原料(原料スプレッド)の使用量を設定します。</summary>
            var setGenryoWtShiyo = function (cellName, reslut) {
                var ids = genGrid.jqGrid('getDataIDs');
                for (var i = 0; i < ids.length; i++) {
                    var id = ids[i];
                    genGrid.setCell(id, cellName, reslut[i].hitsuyoJuryo);
                }
            };
            /// <summary>明細原料(原料スプレッド)の関連情報を設定します。</summary>
            var setGenryoRelatedValue = function () {
                var ids = genGrid.jqGrid('getDataIDs');
                for (var i = 0; i < ids.length; i++) {
                    var id = ids[i],
                    //cdGenryo = genGrid.getCell(id, "cd_genryo"),
                        cdGenryo = genGrid.getCell(id, "recipeHinmeiCode"),
                        nmGenryo;
                    // 品名マスタ情報の設定
                    setMaHinmei(id, cdGenryo, pageLangText.genryoHinKbn.text);
                    //nmGenryo = genGrid.getCell(id, "nm_genryo");
                    nmGenryo = genGrid.getCell(id, "recipeHinmeiName");
                    if (cd_GenryoAri == true) {
                        setZaiko(id, cdGenryo, pageLangText.genryoHinKbn.text);
                    }
                    /*
                    if (!App.isUndefOrNull(nmGenryo)
                    && nmGenryo.length > 0) {
                    // 品名が取得できた場合

                    // 在庫設定処理
                    setZaiko(id, cdGenryo, pageLangText.genryoHinKbn.text);
                    }
                    */
                    if (i == 0) {
                        // 明細原料1件目の場合

                        // 選択原資材：原資材コードの設定
                        selGenshiCdGenshizai = genGrid.getCell(id, "recipeHinmeiCode");
                        // 選択原資材：原資材名の設定
                        selGenshiNmGenshizai = genGrid.getCell(id, "recipeHinmeiName");
                        // 選択原資材：品区分の設定
                        selGenshiKbnHin = genGrid.getCell(id, "kbn_hin");
                        // 選択原資材：納入単価の設定
                        selGenshiTanNonyu = genGrid.getCell(id, "tan_nonyu");
                        // 選択原資材：税区分の設定
                        selGenshiKbnZei = genGrid.getCell(id, "kbn_zei");
                        // 選択原資材：変更前使用量の設定
                        selGenshiBefWtShiyo = deleteThousandsSeparator(genGrid.getCell(id, "genryo_bef_wt_shiyo"));
                        // 選択原資材：変更後使用量の設定
                        selGenshiAftWtShiyo = deleteThousandsSeparator(genGrid.getCell(id, "genryo_wt_shiyo"));
                        // 原資材情報の設定
                        setGenshiInfo(id);
                    }
                }
            };

            /// <summary>明細資材(資材スプレッド)の検索を行います。</summary>
            /// <param name="query">クエリオブジェクト</param>
            var searchShizai = function (query) {
                // 検索条件を元にデータを取得
                App.ajax.webgetSync(
                    App.data.toWebAPIFormat(query)
                ).done(function (result) {
                    // データバインド
                    bindShizaiData(result);
                    // 明細資材関連情報設定
                    setShizaiRelatedValue();
                    // 明細資材(資材スプレッド)制御設定
                    setControlShiGrid();
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                    App.ui.loading.close();
                    isDataLoading = false;
                }).always(function () {
                    if (isDataLoading) {
                        App.ui.loading.close();
                        // メッセージの表示
                        App.ui.page.notifyInfo.message(pageLangText.finishCalc.text).show();
                    }
                    setTimeout(function () {
                        isDataLoading = false;
                    }, 500);
                });
            };

            /// <summary>明細資材(資材スプレッド)の関連情報を設定します。</summary>
            var setShizaiRelatedValue = function () {
                var ids = shiGrid.jqGrid('getDataIDs');
                for (var i = 0; i < ids.length; i++) {
                    var id = ids[i],
                        cdShizai = shiGrid.getCell(id, "cd_shizai"),
                        nmShizai;
                    // 品名マスタ情報の設定
                    setMaHinmei(id, cdShizai, pageLangText.shizaiHinKbn.text);
                    nmShizai = shiGrid.getCell(id, "nm_shizai");

                    if (cd_ShizaiAri == true) {
                        // 計算用ワークの設定
                        var wkSuShiyo = shiGrid.getCell(id, "su_shiyo"),
                            wkRitsuBudomari = shiGrid.getCell(id, "ritsu_budomari"),
                            wkBefWtShiyo,
                            wkAftWtShiyo;

                        // null(NaN)対応
                        wkSuShiyo = setDefaultOrParseFloat(wkSuShiyo, 0);
                        wkRitsuBudomari = setDefaultOrParseFloat(wkRitsuBudomari, parseFloat(pageLangText.budomariShokichi.text));

                        // 隠し項目：変更前使用量の設定
                        //wkBefWtShiyo = befSuSeizoYotei * wkSuShiyo / wkRitsuBudomari * KANZAN;
                        var calBefVal = App.data.trimFixed(befSuSeizoYotei * wkSuShiyo);
                        wkBefWtShiyo = App.data.trimFixed(calBefVal / wkRitsuBudomari * 100);
                        shiGrid.setCell(id, "shizai_bef_wt_shiyo", Math.ceil(App.data.trimFixed(wkBefWtShiyo * KANZAN)) / KANZAN);
                        // 明細資材/使用量の設定
                        //wkAftWtShiyo = aftSuSeizoYotei * wkSuShiyo / wkRitsuBudomari * KANZAN;
                        var calAftVal = App.data.trimFixed(aftSuSeizoYotei * wkSuShiyo);
                        wkAftWtShiyo = App.data.trimFixed(calAftVal / wkRitsuBudomari * 100);
                        shiGrid.setCell(id, "shizai_wt_shiyo", Math.ceil(App.data.trimFixed(wkAftWtShiyo * KANZAN)) / KANZAN);
                        // 在庫設定処理
                        setZaiko(id, cdShizai, pageLangText.shizaiHinKbn.text);
                    }

                    if (cntGenryo == 0
                        && i == 0) {
                        // 明細原料件数 = 0件 かつ 明細資材1件目の場合

                        // 選択原資材：原資材コードの設定
                        selGenshiCdGenshizai = shiGrid.getCell(id, "cd_shizai");
                        // 選択原資材：原資材名の設定
                        selGenshiNmGenshizai = shiGrid.getCell(id, "nm_shizai");
                        // 選択原資材：品区分の設定
                        selGenshiKbnHin = shiGrid.getCell(id, "kbn_hin");
                        // 選択原資材：納入単価の設定
                        selGenshiTanNonyu = shiGrid.getCell(id, "tan_nonyu");
                        // 選択原資材：税区分の設定
                        selGenshiKbnZei = shiGrid.getCell(id, "kbn_zei");
                        // 選択原資材：変更前使用量の設定
                        selGenshiBefWtShiyo = deleteThousandsSeparator(shiGrid.getCell(id, "shizai_bef_wt_shiyo"));
                        // 選択原資材：変更後使用量の設定
                        selGenshiAftWtShiyo = deleteThousandsSeparator(shiGrid.getCell(id, "shizai_wt_shiyo"));
                        // 原資材情報の設定
                        setGenshiInfo(id);
                    }
                }
            };

            /// <summary>品名マスタから各種情報を取得し設定します。</summary>
            /// <param name="selectedRowId">選択行ID</param>
            /// <param name="param_cd_hinmei">品名コード</param>
            /// <param name="param_kbn_hin">品区分</param>
            var setMaHinmei = function (selectedRowId, param_cd_hinmei, param_kbn_hin) {
                var query = {
                    url: "../Services/FoodProcsService.svc/ma_hinmei",
                    filter: "cd_hinmei eq '" + param_cd_hinmei + "'",
                    top: 1
                };
                // 品名マスタ検索
                App.ajax.webgetSync(
                    App.data.toODataFormat(query)
                ).done(function (result) {
                    if (result.d.length > 0) {
                        // 検索結果が取得できた場合

                        if (param_kbn_hin == pageLangText.genryoHinKbn.text) {
                            // 品区分が原料の場合
                            cd_GenryoAri = true;
                            cd_ShizaiAri = false;
                            // 隠し項目：未使用フラグに取得した[品名マスタ].[未使用フラグ]を設定
                            genGrid.setCell(selectedRowId, "flg_mishiyo", result.d[0]["flg_mishiyo"]);
                            // 明細原料/原料名に取得した[品名マスタ].[品名]を設定
                            genGrid.setCell(selectedRowId, "recipeHinmeiName", result.d[0][hinName]);
                            // 隠し項目：納入リードタイムに取得した[品名マスタ].[納入リードタイム]を設定
                            genGrid.setCell(selectedRowId, "dd_leadtime", result.d[0]["dd_leadtime"]);
                            // 隠し項目：最低在庫に取得した[品名マスタ].[最低在庫]を設定(小数第四位を切り捨てる)
                            genGrid.setCell(selectedRowId, "su_zaiko_min", result.d[0]["su_zaiko_min"]);
                            // 隠し項目：発注ロットサイズに取得した[品名マスタ].[発注ロットサイズ]を設定
                            genGrid.setCell(selectedRowId, "su_hachu_lot_size", result.d[0]["su_hachu_lot_size"]);
                            // 隠し項目：使用単位コードに取得した[品名マスタ].[使用単位コード]を設定
                            genGrid.setCell(selectedRowId, "cd_tani_shiyo", result.d[0]["cd_tani_shiyo"]);
                            // 隠し項目：納入単位コードに取得した[品名マスタ].[納入単位コード]を設定
                            genGrid.setCell(selectedRowId, "cd_tani_nonyu", result.d[0]["cd_tani_nonyu"]);
                            // 隠し項目：品区分に取得した[品名マスタ].[品区分]を設定
                            genGrid.setCell(selectedRowId, "kbn_hin", result.d[0]["kbn_hin"]);
                            // 隠し項目：納入単価に取得した[品名マスタ].[納入単価]を設定
                            genGrid.setCell(selectedRowId, "tan_nonyu", result.d[0]["tan_nonyu"]);
                            // 隠し項目：税区分に取得した[品名マスタ].[税区分]を設定
                            genGrid.setCell(selectedRowId, "kbn_zei", result.d[0]["kbn_zei"]);
                        }
                        else {
                            // 品区分が資材の場合
                            cd_GenryoAri = false;
                            cd_ShizaiAri = true;
                            // 隠し項目：未使用フラグに取得した[品名マスタ].[未使用フラグ]を設定
                            shiGrid.setCell(selectedRowId, "flg_mishiyo", result.d[0]["flg_mishiyo"]);
                            // 明細資材/原料名に取得した[品名マスタ].[品名]を設定
                            shiGrid.setCell(selectedRowId, "nm_shizai", result.d[0][hinName]);
                            // 隠し項目：歩留に取得した[品名マスタ].[歩留]を設定
                            shiGrid.setCell(selectedRowId, "ritsu_budomari", result.d[0]["ritsu_budomari"]);
                            // 隠し項目：納入リードタイムに取得した[品名マスタ].[納入リードタイム]を設定
                            shiGrid.setCell(selectedRowId, "dd_leadtime", result.d[0]["dd_leadtime"]);
                            // 隠し項目：最低在庫に取得した[品名マスタ].[最低在庫]を設定
                            shiGrid.setCell(selectedRowId, "su_zaiko_min", result.d[0]["su_zaiko_min"]);
                            // 隠し項目：発注ロットサイズに取得した[品名マスタ].[発注ロットサイズ]を設定
                            shiGrid.setCell(selectedRowId, "su_hachu_lot_size", result.d[0]["su_hachu_lot_size"]);
                            // 隠し項目：使用単位コードに取得した[品名マスタ].[使用単位コード]を設定
                            shiGrid.setCell(selectedRowId, "cd_tani_shiyo", result.d[0]["cd_tani_shiyo"]);
                            // 隠し項目：納入単位コードに取得した[品名マスタ].[納入単位コード]を設定
                            shiGrid.setCell(selectedRowId, "cd_tani_nonyu", result.d[0]["cd_tani_nonyu"]);
                            // 隠し項目：品区分に取得した[品名マスタ].[品区分]を設定
                            shiGrid.setCell(selectedRowId, "kbn_hin", result.d[0]["kbn_hin"]);
                            // 隠し項目：納入単価に取得した[品名マスタ].[納入単価]を設定
                            shiGrid.setCell(selectedRowId, "tan_nonyu", result.d[0]["tan_nonyu"]);
                            // 隠し項目：税区分に取得した[品名マスタ].[税区分]を設定
                            shiGrid.setCell(selectedRowId, "kbn_zei", result.d[0]["kbn_zei"]);
                        }
                    }
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                    App.ui.loading.close();
                });
            };

            /// <summary>在庫情報を取得し設定します。</summary>
            /// <param name="selectedRowId">選択行ID</param>
            /// <param name="param_cd_hinmei">品名コード</param>
            /// <param name="param_kbn_hin">品区分</param>
            var setZaiko = function (selectedRowId, param_cd_hinmei, param_kbn_hin) {
                var wkBefWtZaiko,
                    wkBefWtShiyo,
                    wkAftWtShiyo,
                    criteria = $(".search-criteria").toJSON(),
                    query = {
                        url: "../api/HendoHyoSimulation",
                        con_cd_hinmei: param_cd_hinmei,
                        con_dt_hizuke: App.data.getDateTimeStringForQueryNoUtc(criteria.con_dt_hizuke),
                        flg_one_day: pageLangText.trueFlg.text,
                        flg_yojitsu_yo: pageLangText.yoteiYojitsuFlg.text,
                        flg_yojitsu_ji: pageLangText.jissekiYojitsuFlg.text,
                        today: App.data.getDateTimeStringForQueryNoUtc(getSystemDate())
                    };
                // 計算在庫検索
                App.ajax.webgetSync(
                    App.data.toWebAPIFormat(query)
                ).done(function (result) {
                    if (result.length > 0) {
                        // 検索結果が取得できた場合

                        // 変更前在庫量の設定
                        wkBefWtZaiko = parseFloat(result[0]["before_wt_zaiko"]);

                        if (param_kbn_hin === pageLangText.genryoHinKbn.text) {
                            // 品区分が原料の場合

                            // 変更前使用量、変更後使用量の設定
                            wkBefWtShiyo = deleteThousandsSeparator(genGrid.getCell(selectedRowId, "genryo_bef_wt_shiyo"));
                            wkAftWtShiyo = deleteThousandsSeparator(genGrid.getCell(selectedRowId, "genryo_wt_shiyo"));
                            // 隠し項目：変更前在庫量に取得した変更前在庫量を設定
                            genGrid.setCell(selectedRowId, "genryo_bef_wt_zaiko", wkBefWtZaiko);
                            // 明細原料/在庫量に『変更前在庫量 + 変更前使用量 - 変更後使用量』を設定
                            //genGrid.setCell(selectedRowId, "genryo_wt_zaiko", wkBefWtZaiko + wkBefWtShiyo - wkAftWtShiyo);
                            genGrid.setCell(selectedRowId, "genryo_wt_zaiko", calZaikoShiyo(wkBefWtZaiko, wkBefWtShiyo, wkAftWtShiyo));
                        }
                        else {
                            // 品区分が資材の場合

                            // 変更前使用量、変更後使用量の設定
                            wkBefWtShiyo = deleteThousandsSeparator(shiGrid.getCell(selectedRowId, "shizai_bef_wt_shiyo"));
                            wkAftWtShiyo = deleteThousandsSeparator(shiGrid.getCell(selectedRowId, "shizai_wt_shiyo"));
                            // 隠し項目：変更前在庫量に取得した変更前在庫量を設定
                            shiGrid.setCell(selectedRowId, "shizai_bef_wt_zaiko", wkBefWtZaiko);
                            // 明細資材/在庫量に『変更前在庫量 + 変更前使用量 - 変更後使用量』を設定
                            //shiGrid.setCell(selectedRowId, "shizai_wt_zaiko", wkBefWtZaiko + wkBefWtShiyo - wkAftWtShiyo);
                            shiGrid.setCell(selectedRowId, "shizai_wt_zaiko", calZaikoShiyo(wkBefWtZaiko, wkBefWtShiyo, wkAftWtShiyo));
                        }
                    }
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                    App.ui.loading.close();
                });
            };

            /// <summary>データ検索を行います。</summary>
            var searchItems = function () {
                isDataLoading = true;

                var inputValue = $("#condition-after_change").val();
                // 変更後製造予定数の設定
                if (App.isUndefOrNull(inputValue)
                    || inputValue.length === 0) {
                    // 変更後製造予定数が入力されていない場合

                    // 変更後製造予定数に『0』を表示させる
                    $("#condition-after_change").val(aftSuSeizoYotei);
                }
                // 検索条件の保持
                saveSearchCriteria();

                // 検索処理開始
                // 明細原料(原料スプレッド)の検索
                searchGenryo();
                if (isDataLoading) {
                    // 明細資源(資源スプレッド)の検索
                    searchShizai(new queryShizai());
                }
                // 検索処理終了
                if (cntGenryo === 0
                    && cntShizai === 0) {
                    // 明細原料件数、明細資源件数がともに0件の場合はエラーメッセージを表示する
                    App.ui.page.notifyAlert.message(pageLangText.notFound.text).show();
                }
            };

            /// <summary>検索処理を行います。</summary>
            var findData = function () {
                // ダイアログを閉じる
                closeSearchConfirmDialog();
                // 検索前の状態に初期化
                clearState();
                // 検索前バリデーション
                var result = $(".search-criteria").validation().validate();
                if (result.errors.length) {
                    // ローディングの終了
                    App.ui.loading.close();
                    return;
                }
                // データ検索
                searchItems();
            };

            /// <summary>計算ボタンクリック時のイベント処理を行います。</summary>
            $(".calc-button").on("click", showSearchConfirmDialog);

            // グリッドコントロール固有の検索処理

            /// <summary>検索前の状態に初期化します。</summary>
            var clearState = function () {
                // 明細原料(原料スプレッド)のクリア
                genGrid.clearGridData();
                // 明細資材(資材スプレッド)のクリア
                shiGrid.clearGridData();
                // 原資材情報のクリア
                clearInfoGenshi();
                // 各変数の初期化
                querySetting.skip = 0;
                querySetting.count = 0;
                currentRow = 0;
                currentCol = firstCol;
                // 変更セットの再作成
                changeSet = new App.ui.page.changeSet();

                // 情報メッセージのクリア
                App.ui.page.notifyInfo.clear();
                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();
            };

            /// <summary>原資材情報をクリアします。</summary>
            var clearInfoGenshi = function () {
                // 明細(シミュレーションスプレッド)のクリア
                simuGrid.clearGridData();
                // 原資材情報の各項目を初期化
                $("#genshi-cd_konyu").text("");
                $("#genshi-nm_konyu").text("");
                $("#genshi-leadtime").text("");
                $("#genshi-zaiko_min").text("");
                $("#genshi-hachu_lot_size").text("");
                $("#genshi-tani_shiyo").text("");
                // 選択原資材の各変数を初期化
                selGenshiCdGenshizai = null;
                selGenshiNmGenshizai = null;
                selGenshiKbnHin = null;
                selGenshiCdTorihiki2 = null;
                selGenshiTanNonyu = null;
                selGenshiKbnZei = null;
                selGenshiBefWtShiyo = 0;
                selGenshiAftWtShiyo = 0;
            };

            /// <summary>明細原料(原料スプレッド)データをバインドします。</summary>
            var bindGenryoData = function (result) {
                // 明細原料件数の設定
                cntGenryo = result.length;
                if (cntGenryo > 0) {
                    // グリッドの表示件数を更新
                    genGrid.setGridParam({ rowNum: cntGenryo });
                    // データバインド
                    var currentData = genGrid.getGridParam("data").concat(result);
                    genGrid.setGridParam({ data: currentData }).trigger('reloadGrid', [{ current: true}]);
                }
            };

            /// <summary>明細資材(資材スプレッド)データをバインドします。</summary>
            /// <param name="result">検索結果</param>
            var bindShizaiData = function (result) {
                // 明細資材件数の設定
                cntShizai = result.length;
                if (cntShizai > 0) {
                    // グリッドの表示件数を更新
                    shiGrid.setGridParam({ rowNum: cntShizai });
                    // データバインド
                    var currentData = shiGrid.getGridParam("data").concat(result);
                    shiGrid.setGridParam({ data: currentData }).trigger('reloadGrid', [{ current: true}]);
                }
            };

            /// <summary>明細(シミュレーションスプレッド)データをバインドします。</summary>
            /// <param name="result">検索結果</param>
            var bindSimuData = function (result) {
                // グリッドの表示件数を更新
                simuGrid.setGridParam({ rowNum: result.length });
                // データバインド
                var currentData = simuGrid.getGridParam("data").concat(result);
                simuGrid.setGridParam({ data: currentData }).trigger('reloadGrid', [{ current: true}]);
            };

            //// 検索処理 -- End

            //// メッセージ表示 -- Start

            // グリッドコントロール固有のメッセージ表示

            /// <summary>カレント行のエラーメッセージを削除します。</summary>
            /// <param name="selectedRowId">選択行ID</param>
            var removeAlertRow = function (selectedRowId) {
                var unique,
                    colModel = simuGrid.getGridParam("colModel");

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
                // data.unique でキーが取得できる
                // data.handledにtrueを指定することでデフォルトの動作(キーがHTMLElementの場合にフォーカスを当てる処理)の実行をキャンセルする
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
                simuGrid.editCell(iRow, info.iCol, true);
            };

            /// <summary>エラー一覧クリック時のイベント処理を行います。</summary>
            $(App.ui.page.notifyAlert).on("itemselected", function (e, data) {
                // エラー一覧クリック時の処理
                handleNotifyAlert(data);
            });

            // ダイアログ固有のメッセージ表示

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

            // 検索時ダイアログ警告メッセージの設定
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

            // 保存時ダイアログ情報メッセージの設定
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

            // 保存時ダイアログ警告メッセージの設定
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

            // 計画作成時ダイアログ情報メッセージの設定
            var keikakuConfirmDialogNotifyInfo = App.ui.notify.info(keikakuConfirmDialog, {
                container: ".keikaku-confirm-dialog .dialog-slideup-area .info-message",
                messageContainerQuery: "ul",
                show: function () {
                    keikakuConfirmDialog.find(".info-message").show();
                },
                clear: function () {
                    keikakuConfirmDialog.find(".info-message").hide();
                }
            });

            // 計画作成時ダイアログ警告メッセージの設定
            var keikakuConfirmDialogNotifyAlert = App.ui.notify.alert(keikakuConfirmDialog, {
                container: ".keikaku-confirm-dialog .dialog-slideup-area .alert-message",
                messageContainerQuery: "ul",
                show: function () {
                    keikakuConfirmDialog.find(".alert-message").show();
                },
                clear: function () {
                    keikakuConfirmDialog.find(".alert-message").hide();
                }
            });

            //// メッセージ表示 -- End

            //// データ変更処理 -- Start

            // グリッドコントロール固有のデータ変更処理

            /// <summary>グリッドの選択行の行IDを取得します。 </summary>
            var getSelectedRowId = function (isAdd) {
                var selectedRowId = simuGrid.getGridParam("selrow"),
                    ids = simuGrid.getDataIDs(),
                    recordCount = simuGrid.getGridParam("records");
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
            /// <param name="updateRow">変更行データ</param>
            var setCreatedChangeNonyuData = function (updateRow) {
                var changeData = {
                    "flg_yojitsu": pageLangText.yoteiYojitsuFlg.text,
                    "no_nonyu": null,
                    "dt_nonyu": App.data.getDateTimeStringForQueryNoUtc(App.date.localDate(updateRow.dt_ymd)),
                    "cd_hinmei": selGenshiCdGenshizai,
                    "su_nonyu": updateRow.after_su_nonyu,
                    "su_nonyu_hasu": null,
                    "cd_torihiki": $("#genshi-cd_konyu").text(),
                    "cd_torihiki2": selGenshiCdTorihiki2,
                    "tan_nonyu": selGenshiTanNonyu,
                    "kin_kingaku": 0,
                    "no_nonyusho": null,
                    "kbn_zei": selGenshiKbnZei,
                    "kbn_denso": null,
                    "flg_kakutei": null,
                    "dt_seizo": null,
                    "su_ko": updateRow.su_ko,
                    "su_iri": updateRow.su_iri,
                    "cd_tani": updateRow.cd_tani,
                    "flg_nonyu_change": updateRow.flg_nonyu_change
                };
                return changeData;
            };

            /// <summary>削除状態の変更セットに追加する変更データの設定を行います。</summary>
            /// <param name="updateRow">変更行データ</param>
            var setDeletedChangeNonyuData = function (updateRow) {
                var changeData = {
                    "flg_yojitsu": pageLangText.yoteiYojitsuFlg.text,
                    "no_nonyu": null,
                    "dt_nonyu": App.data.getDateTimeStringForQueryNoUtc(App.date.localDate(updateRow.dt_ymd)),
                    "cd_hinmei": selGenshiCdGenshizai,
                    "su_nonyu": null,
                    "su_nonyu_hasu": null,
                    "cd_torihiki": null,
                    "cd_torihiki2": null,
                    "tan_nonyu": null,
                    "kin_kingaku": null,
                    "no_nonyusho": null,
                    "kbn_zei": null,
                    "kbn_denso": null,
                    "flg_kakutei": null,
                    "dt_seizo": null,
                    "su_ko": null,
                    "su_iri": null,
                    "cd_tani": null,
                    "flg_nonyu_change": null
                };
                return changeData;
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
                simuGrid.saveCell(currentRow, currentCol);
            };

            /// <summary>更新データを取得します。</summary>
            var getPostData = function () {
                return changeSet.getChangeSet();
            };

            /// <summary>データ変更エラーハンドリングを行います。</summary>
            /// <param name="result">エラーの戻り値</param>
            var handleSaveDataError = function (result) {
                var ret = JSON.parse(result.rawText);

                if (!App.isArray(ret)
                    && App.isUndefOrNull(ret.Updated)
                    && App.isUndefOrNull(ret.Deleted)) {
                    App.ui.page.notifyAlert.message(result.message).show();
                    return;
                }

                // 削除時同時実行制御エラーのハンドリングを行います。
                if (!App.isUndefOrNull(ret.Deleted)
                    && ret.Deleted.length > 0) {
                    for (var i = 0; i < ret.Deleted.length; i++) {

                        // 他のユーザーによって削除されていた場合
                        if (App.isUndefOrNull(ret.Deleted[i].Current)) {

                            // エラーメッセージの表示
                            App.ui.page.notifyAlert.message(
                                pageLangText.duplicate.text + pageLangText.deletedDuplicate.text).show();
                        }
                    }
                }
            };

            /// <summary>変更を保存します。</summary>
            /// <param name="e">イベントデータ</param>
            var saveData = function (e) {
                // 保存時ダイアログを閉じる
                closeSaveConfirmDialog();
                // ローディングの表示
                App.ui.loading.show(pageLangText.nowSaving.text);

                var saveUrl = "../api/HendoHyoSimulation";

                App.ajax.webpost(
                    saveUrl, getPostData()
                ).done(function (result) {
                    // 検索前の状態に初期化
                    clearState();
                    // データ検索
                    searchItems();
                    // 正常終了メッセージ出力
                    App.ui.page.notifyInfo.message(pageLangText.successMessage.text).show();
                }).fail(function (result) {
                    // データ変更エラーハンドリングを行います。
                    handleSaveDataError(result);
                }).always(function () {
                    // ローディングの終了
                    App.ui.loading.close();
                });
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
                    var errDate = simuGrid.jqGrid('getCell', rowId, 'dt_ymd');
                    if (nonyuData.length > 1) {
                        // 同日に複数件存在する場合はエラー
                        App.ui.page.notifyAlert.message(
                            App.str.format(MS0734, pageLangText.param_su_nonyu.text, errDate), err_unique
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
                var isValid = true,
                    changeData = changeSet.changeSet.created;
                for (p in changeData) {
                    if (!changeData.hasOwnProperty(p)) {
                        continue;
                    }
                    var upData = changeData[p];
                    // 編集された納入予定のみを対象とする
                    if (upData.flg_nonyu_change == pageLangText.trueFlg.text) {
                        var val_code = upData.cd_hinmei,
                            val_date = upData.dt_nonyu;
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
                var inputValue = $("#condition-after_change").val();
                // 情報メッセージのクリア
                App.ui.page.notifyInfo.clear();
                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();
                // 編集内容の保存
                saveEdit();
                if (noChange()) {
                    // 明細が変更されていない場合、メッセージを表示し保存処理を中止する
                    App.ui.page.notifyInfo.message(pageLangText.noChange.text).show();
                    return;
                }
                // 変更後製造予定数の設定
                if (App.isUndefOrNull(inputValue)
                        || inputValue.length === 0) {
                    // 変更後製造予定数が入力されていない場合

                    // 変更後製造予定数に『0』を表示させる(変更後製造予定数クリア時に変数『aftSuSeizoYotei』には0が代入されている)
                    $("#condition-after_change").val(aftSuSeizoYotei);
                }
                // 保存前バリデーション
                var result = $(".search-criteria").validation().validate();
                if (result.errors.length) {
                    return;
                }
                // 検索条件変更チェック
                if (!noChangeCriteria()) {
                    App.ui.page.notifyInfo.message(
                        App.str.format(pageLangText.changeCriteria.text, pageLangText.searchCriteria.text, pageLangText.save.text)
                    ).show();
                    return;
                }
                // 購入先マスタが存在しない場合はエラー
                var cd_torihiki = $("#genshi-cd_konyu").text();
                if (cd_torihiki == "") {
                    App.ui.page.notifyAlert.message(
                        App.str.format(MS0055, pageLangText.konyusaki.text, pageLangText.konyusakiMaster.text)
                    ).show();
                    return;
                }
                // 変更セット内にバリデーションエラーがある場合は処理を抜ける
                if (!validateChangeSet()) {
                    return;
                }
                // 納入予定のチェック
                if (!checkNonyuSu()) {
                    return;
                }

                // 保存時ダイアログを開く
                //showSaveConfirmDialog();
                saveData();
            };

            /// <summary>保存ボタンクリック時のイベント処理を行います。</summary>
            $(".save-button").on("click", checkSave);

            //// 保存処理 -- End

            //// バリデーション -- Start

            /// <summary>バリデーション実行</summary>
            var actValidation = Aw.validation({
                items: validationSetting,
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
                            if (results[i].item === "con_after_change"
                                && isNaN($("#condition-after_change").val())) {
                                // 検索条件/変更後に数値以外の値が入力された場合

                                // 検索条件/変更後にnullを設定(『NaN』表示のクリア対応)
                                $("#condition-after_change").val(null);
                            }
                        }
                    }
                }
            });

            /// <summary>検索条件バリデーションを行います。</summary>
            $(".search-criteria").validation(actValidation);

            // グリッドコントロール固有のバリデーション
            // 検索条件/品名コード：品名マスタ存在チェック
            var isValidCdHinmeiExists = function (cdHinmei) {
                var isValid = true,
                    query = {
                        url: "../Services/FoodProcsService.svc/ma_hinmei",
                        filter: "cd_hinmei eq '" + cdHinmei +
                                "' and kbn_hin eq " + pageLangText.seihinHinKbn.text +
                                " and flg_mishiyo eq " + pageLangText.shiyoMishiyoFlg.text,
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
                        isValid = false;
                    }
                    else {
                        // 検索結果が取得できた場合

                        // 検索条件/品名に取得した[品名マスタ].[品名]を設定
                        var nmHin = result.d[0][hinName];
                        if (App.isUndefOrNull(nmHin)) {
                            nmHin = "";
                        }
                        $("#condition-nm_hinmei").text(nmHin);
                        // 製品入数に取得した[品名マスタ].[入数]を設定
                        seihinSuIri = parseInt(result.d[0]["su_iri"]);
                    }
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                });
                return isValid;
            };

            // バリデーション設定(検索条件/品名コード：品名マスタ存在チェック)
            validationSetting.con_cd_hinmei.rules.custom = function (value) {
                return isValidCdHinmeiExists(value);
            };

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
                simuGrid.setCell(selectedRowId, iCol, value, { background: 'none' });
                val[cellName] = value;
                // バリデーション実行
                result = v.validate(val, { suppressCallback: false });
                if (result.errors.length) {
                    // エラーメッセージの表示
                    App.ui.page.notifyAlert.message(result.errors[0].message, unique).show();
                    // 対象セルの背景変更
                    simuGrid.setCell(selectedRowId, iCol, value, { background: '#ff6666' });
                    return false;
                }
                return true;
            };

            /// <summary>カレントの行バリデーションを実行します。</summary>
            /// <param name="selectedRowId">選択行ID</param>
            var validateRow = function (selectedRowId) {
                var isValid = true,
                    colModel = simuGrid.getGridParam("colModel"),
                    iRow = $('#' + selectedRowId)[0].rowIndex;
                // 行番号はチェックしない
                for (var i = 1; i < colModel.length; i++) {
                    // セルを選択して入力モードを解除する
                    simuGrid.editCell(iRow, i, false);
                    // セルバリデーション
                    if (!validateCell(selectedRowId, colModel[i].name, simuGrid.getCell(selectedRowId, colModel[i].name), i)) {
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
                if (e.keyCode === App.ui.keys.F2) {
                    // F2の処理
                    processed = true;
                }
                else if (e.keyCode === App.ui.keys.F3) {
                    // F3の処理
                    processed = true;
                }
                if (processed) {
                    // 何か処理を行なっていた場合、ブラウザ既定の動作を無効にする
                    e.preventDefault();
                }
            };

            /// <summary>キーダウン時のイベント処理を行います。</summary>
            $(window).on("keydown", processFunctionKey);

            /// <summary>コンテンツのリサイズを行います。</summary>
            var resizeContents = function (e) {
                var container = $(".content-container"),
                    searchPart = $(".search-criteria"),
                    genshiPart = $(".part-genshi"),
                    resultPart = $(".result-list"),
                    resultPartStyle = resultPart[0].currentStyle || document.defaultView.getComputedStyle(resultPart[0], "");

                // 高さの調整
                resultPart.height(container[0].clientHeight - searchPart[0].clientHeight - ((parseInt(resultPartStyle.marginTop, 10) * 3) || 0));
                var gridHeight = resultPart[0].clientHeight - resultPart.find(".ui-jqgrid-hdiv")[0].clientHeight - 50;
                simuGrid.setGridHeight(gridHeight);
                genGrid.setGridHeight((gridHeight - 28) / 2);
                shiGrid.setGridHeight((gridHeight - 28) / 2);
                // 幅の調整
                simuGrid.setGridWidth((searchPart[0].clientWidth * 0.985));
                genGrid.setGridWidth((resultPart[0].clientWidth * 0.49));
                shiGrid.setGridWidth((resultPart[0].clientWidth * 0.49));
            };

            /// <summary>画面リサイズ時のイベント処理を行います。</summary>
            $(App.ui.page).on("resized", resizeContents);

            /// <summary>検索確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".search-confirm-dialog .dlg-yes-button").on("click", findData);
            /// <summary>検索確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".search-confirm-dialog .dlg-no-button").on("click", closeSearchConfirmDialog);

            /// <summary>保存確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".save-confirm-dialog .dlg-yes-button").on("click", saveData);
            /// <summary>保存確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".save-confirm-dialog .dlg-no-button").on("click", closeSaveConfirmDialog);

            /// <summary>計画作成確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".keikaku-confirm-dialog .dlg-yes-button").on("click", function () {
                closeKeikakuConfirmDialog();
                openGekkanSeihinKeikaku();
            });
            /// <summary>計画作成確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".keikaku-confirm-dialog .dlg-no-button").on("click", closeKeikakuConfirmDialog);

            /// <summary>検索条件/品名コード変更時のイベント処理を行います。</summary>
            $("#condition-cd_hinmei, #condition-dt_hizuke").on("change", function () {
                // 検索条件/品名を初期化
                $("#condition-nm_hinmei").text("");

                // 品名コードが未入力の場合は処理を終了する
                var cdHin = $("#condition-cd_hinmei").val();
                if (App.isUndefOrNull(cdHin) || cdHin.length == 0) {
                    return;
                }

                // 製造予定数の取得前処理
                var result = $(".search-criteria").validation().validate();
                if (result.errors.length) {
                    // チェックＮＧの場合は空白にする
                    $("#condition-seizo_yotei").text("");
                    return;
                }
                // 製造予定数の取得処理
                searchBefSuSeizoYotei();
            });

            /// <summary>検索条件/製品一覧ボタンクリック時のイベント処理を行います。</summary>
            $(".condition-seihin-button").on("click", function (e) {
                // ダイアログ：製品一覧を開く
                showSeihinDialog();
            });
            /// <summary>検索条件/品名コードダブルクリック時のイベント処理を行います。</summary>
            $("#condition-cd_hinmei").dblclick(function () {
                // ダイアログ：製品一覧を開く
                showSeihinDialog();
            });

            /// <summary>検索条件/変更後変更時のイベント処理を行います。</summary>
            $("#condition-after_change").on("change", function () {
                var inputValue = $("#condition-after_change").val();
                if (App.isUndefOrNull(inputValue)
                    || inputValue.length == 0) {
                    // 入力値が削除された場合

                    // 変更後製造予定数に0を設定
                    aftSuSeizoYotei = 0;
                }
                else {
                    // 値が入力された場合

                    if (!isNaN(inputValue)) {
                        // 数値が入力された場合

                        // 変更後製造予定数に入力値(前ゼロ消去)を設定
                        aftSuSeizoYotei = Number(inputValue);
                        // 検索条件/変更後にカンマ編集した変更後製造予定数を設定
                        $("#condition-after_change").val(String(aftSuSeizoYotei).replace(/((?:^-)?\d{1,3})(?=(?:\d{3})+(?!\d))/g, '$1,'));
                    }
                }
            });

            /// <summary>月間製品計画に遷移する</summary>
            /// 取得成功時、取得したコードを引数に設定し、月間製品計画に遷移する
            var openGekkanSeihinKeikaku = function () {
                // 製造ラインマスタ、ラインマスタ、職場マスタから職場コードとラインコードを取得する
                var criteria = $(".search-criteria").toJSON();
                keikakuQuery = {
                    url: "../api/HendoHyoSimulation",
                    hinCode: criteria.con_cd_hinmei,
                    shiyoFlag: pageLangText.shiyoMishiyoFlg.text
                };
                App.ajax.webgetSync(
                    App.data.toWebAPIFormat(keikakuQuery)
                ).done(function (result) {
                    if (result.length === 1) {
                        // 検索結果件数が1件の場合
                        changeSet = new App.ui.page.changeSet();    // MS0066を表示させないため、変更内容をクリアする
                        // 取得したコードを引数に、月間製品計画に遷移する
                        var url = "./GekkanSeihinKeikaku.aspx";
                        url += "?dt_hiduke_search=" + $("#condition-dt_hizuke").val();
                        url += "&shokubaCode=" + result[0].cd_shokuba;
                        url += "&lineCode=" + result[0].cd_line;
                        window.location = url;
                    }
                    else {
                        // 検索結果が1件以外の場合
                        // エラーメッセージを表示し、処理を終了する
                        App.ui.page.notifyAlert.message(pageLangText.line_shokuba_codeNotFound.text).show();
                    }
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                });
            };
            /// <summary>計画作成ボタンクリック時のイベント処理を行います。</summary>
            $(".planmake-button").on("click", function () {
                // 情報メッセージのクリア
                App.ui.page.notifyInfo.clear();
                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();

                //// チェック処理
                // 検索前バリデーション
                var result = $(".search-criteria").validation().validate();
                if (result.errors.length) {
                    return;
                }
                // 検索条件が変更されていないこと
                //if (!noChangeCriteria()) {
                //    App.ui.page.notifyInfo.message(
                //        App.str.format(pageLangText.changeCriteria.text, pageLangText.searchCriteria.text, pageLangText.planmake.text)
                //    ).show();
                //    return;
                //}

                // 明細行に変更がある場合の確認
                if (!noChange()) {
                    showKeikakuConfirmDialog();
                }
                else {
                    // 月間製品計画へ
                    openGekkanSeihinKeikaku();
                }
            });

            /// <summary>ダウンロードボタンクリック時のオーバレイ処理を行います。</summary>
            var downloadOverlay = function () {
                // ローディングの表示
               // App.ui.loading.show(pageLangText.nowProgressing.text);
                // Excelファイル出力
                printExcel();
                // ローディングの終了
               // App.ui.loading.close();
            };

             //Cookieを1秒ごとにチェックする
            var onComplete = function () {
                if (app_util.prototype.getCookieValue(pageLangText.hendoHyoSimulationCookie.text) == pageLangText.checkCookie.text) {
                    app_util.prototype.deleteCookie(pageLangText.hendoHyoSimulationCookie.text);
                    //ローディング終了
                    App.ui.loading.close();
                }
                else {
                    // 再起してCookieが作成されたか監視
                    setTimeout(onComplete, 1000);
                }
            };

            /// <summary>Excelファイル出力を行います。</summary>
            var printExcel = function (e) {
                var criteria = $(".search-criteria").toJSON();
                // 検索条件ヘッダー：デフォルトは原料
                var hdCdGenshizai = pageLangText.str_genryo.text + pageLangText.str_code.text,
                    hdNmGenshizai = pageLangText.str_genryo.text + pageLangText.str_name.text,
                    itemHeadNonyu = pageLangText.after_su_nonyu.text.replace(/<br>/, " "); // Excelに表示されてしまうので除去します。

                if (selGenshiKbnHin === pageLangText.jikaGenryoHinKbn.text) {
                    // 選択原資材：品区分が自家原料の場合

                    // 明細ヘッダー/納入数に『製造数』を設定
                    itemHeadNonyu = pageLangText.su_seizo_excel.text;
                }
                else if (selGenshiKbnHin === pageLangText.shizaiHinKbn.text) {
                    // 選択原資材：品区分が資材の場合

                    // 検索条件ヘッダー/原資材コードに『資材コード』を設定
                    hdCdGenshizai = pageLangText.str_shizai.text + pageLangText.str_code.text;
                    // 検索条件ヘッダー/原資材名に『資材名』を設定
                    hdNmGenshizai = pageLangText.str_shizai.text + pageLangText.str_name.text;
                }

                var query = {
                    url: "../api/HendoHyoSimulationExcel",
                    con_cd_hinmei: selGenshiCdGenshizai,
                    con_dt_hizuke: App.data.getDateTimeStringForQueryNoUtc(criteria.con_dt_hizuke),
                    one_day_flg: null,
                    flg_yojitsu_yo: pageLangText.yoteiYojitsuFlg.text,
                    flg_yojitsu_ji: pageLangText.jissekiYojitsuFlg.text
                };

                // 処理中を表示する
                App.ui.loading.show(pageLangText.nowProgressing.text);
                var url = App.data.toWebAPIFormat(query);
                url = url + "&lang=" + App.ui.page.lang
                          + "&hdCdGenshizai=" + hdCdGenshizai
                          + "&hdNmGenshizai=" + encodeURIComponent(hdNmGenshizai)
                          + "&cdSeihin=" + criteria.con_cd_hinmei
                          + "&nmSeihin=" + encodeURIComponent($("#condition-nm_hinmei").text())
                          + "&seizoYotei=" + befSuSeizoYotei
                          + "&afterChange=" + aftSuSeizoYotei
                          + "&nmGenshizai=" + selGenshiNmGenshizai
                          + "&taniShiyo=" + encodeURIComponent($("#genshi-tani_shiyo").text())
                          + "&zaikoMin=" + ($("#genshi-zaiko_min").text() ? $("#genshi-zaiko_min").text() : " ")
                          + "&befWtShiyo=" + selGenshiBefWtShiyo
                          + "&aftWtShiyo=" + selGenshiAftWtShiyo
                          + "&strSeizoYotei=" + (setThousandsSeparator(befSuSeizoYotei) + " " + pageLangText.con_str_case.text)
                          + "&strAfterChange=" + (setThousandsSeparator(aftSuSeizoYotei) + " " + pageLangText.con_str_case.text)
                          + "&userName=" + encodeURIComponent(App.ui.page.user.Name)
                          + "&outputDate=" + App.data.getDateTimeStringForQuery(new Date(), true)
                          + "&today=" + App.data.getDateTimeStringForQueryNoUtc(getSystemDate())
                          + "&itemHeadNonyu=" + itemHeadNonyu;

                // Excelファイル出力
                window.open(url, '_parent');
                // Cookieを監視する
                onComplete();
            };

            /// <summary>Excelボタンクリック時のイベント処理を行います。</summary>
            $(".excel-button").on("click", function () {
                // 明細原料件数、明細資材件数がともに0件の場合、何もしない
                if (cntGenryo === 0 && cntShizai === 0) {
                    return;
                }
                // 検索前バリデーション
                var inputValue = $("#condition-after_change").val(),
                    result = $(".search-criteria").validation().validate();
                if (result.errors.length) {
                    return;
                }

                // 変更後製造予定数の設定
                if (App.isUndefOrNull(inputValue)
                    || inputValue.length == 0) {
                    // 変更後製造予定数が入力されていない場合

                    // 変更後製造予定数に『0』を表示させる(変更後製造予定数クリア時に変数『aftSuSeizoYotei』には0が代入されている)
                    $("#condition-after_change").val(aftSuSeizoYotei);
                }

                // 検索条件変更チェック
                if (!noChangeCriteria()) {
                    // 検索条件が変更されている場合、メッセージを表示しExcelファイル出力処理を中止する
                    App.ui.page.notifyInfo.message(
                        App.str.format(pageLangText.changeCriteria.text, pageLangText.searchCriteria.text, pageLangText.output.text)
                    ).show();
                    return;
                }

                // 計算在庫存在チェック
                if (noZaiko()) {
                    // 選択された原資材コードについて11日前の計算在庫が存在しない場合、メッセージを表示しExcelファイル出力処理を中止する
                    App.ui.page.notifyAlert.message(App.str.format(pageLangText.zaikoNotFound.text)).show();
                    return;
                }

                if (!noChange()) {
                    // 明細が変更されている場合、メッセージを表示しExcelファイル出力処理を中止する
                    App.ui.page.notifyInfo.message(pageLangText.gridChange.text).show();
                    return;
                }

                // 出力処理へ
                downloadOverlay();
            });

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

            /// <summary>メニューへボタンクリック時のイベント処理を行います。</summary>
            var backToMenu = function () {
                // IEバグによる例外発生をキャッチします。例外発生時は何もしません。
                try {
                    document.location = pageLangText.menuPath.url;
                }
                catch (e) {
                    // なにもしない
                }
            };

            /// <summary>メニューへボタンクリック時のイベント処理を行います。</summary>
            $(".menu-button").on("click", backToMenu);
        });
    </script>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <!-- 画面デザイン -- Start -->
    <!-- 検索条件と検索ボタン -->
    <div style="width: 50%; float: left;" id="left-head">
        <div class="content-part search-criteria" style="height: 198px;">
            <h3 class="part-header" data-app-text="searchCriteria"></h3>
            <div class="part-body">
                <ul class="item-list">
                    <li>
                        <!-- 検索条件/日付 -->
                        <label>
                            <span class="item-label" data-app-text="con_dt_hizuke"></span>
                            <input type="text" name="con_dt_hizuke" id="condition-dt_hizuke" style="width: 98px;" />
                        </label>
                    </li>
                    <li>
                        <!-- 検索条件/品名コード -->
                        <label>
                            <span class="item-label" data-app-text="con_cd_hinmei"></span>
                            <input type="text" name="con_cd_hinmei" id="condition-cd_hinmei" style="width: 98px;" maxlength="14" />
                        </label>
                        <!-- ボタン：検索条件/製品一覧 -->
                        <button type="button" class="condition-seihin-button" name="con_seihin_button" data-app-operation="seihinIchiran">
                            <span class="icon"></span><span data-app-text="seihinIchiran"></span>
                        </button>
                    </li>
                    <li>
                        <!-- 検索条件/品名 -->
                        <label>
                            <span class="item-label" data-app-text="con_nm_hinmei"></span>
                            <span name="con_nm_hinmei" id="condition-nm_hinmei" style="width: 350px;"></span>
                        </label>
                    </li>
                    <li>
                        <!-- 検索条件/製造予定 -->
                        <label>
                            <span class="item-label" data-app-text="con_seizo_yotei"></span>
                            <span name="con_seizo_yotei" id="condition-seizo_yotei" style="width: 41px; text-align: right; display: inline-block" maxlength="6"></span>
                        </label>
                        <!-- 検索条件/固定文言：C/S -->
                        <label>
                            <span data-app-text="con_str_case"></span>
                        </label>
                        <!-- 検索条件/固定文言：→ -->
                        <label>
                            <span data-app-text="con_str_arrow" style="padding-right: .75em; padding-left: .75em;"></span>
                        </label>
                        <!-- 検索条件/変更後 -->
                        <label>
                            <span data-app-text="con_after_change"></span>
                            <input type="text" name="con_after_change" id="condition-after_change" style="width: 41px; text-align: right;" maxlength="5"
                             onfocus="this.value=this.value.replace(/,/g, '')"/>
                        </label>
                        <!-- 検索条件/固定文言：C/S -->
                        <label>
                            <span data-app-text="con_str_case"></span>
                        </label>
                    </li>
                </ul>
            </div>
            <div class="part-footer">
                <div class="command">
                    <!-- ボタン：検索条件/計算 -->
                    <button type="button" class="calc-button" name="calc_button" data-app-operation="calc">
                        <span class="icon"></span>
                        <span data-app-text="calculate"></span>
                    </button>
                </div>
            </div>
        </div>
    </div>
    <div style="width: 49%; float: right;" id="right-head">
        <div class="content-part part-genshi" id="result-genshi" style="height: 198px; border: none; padding: 1px;">
            <div class="part-body">
                <ul class="item-list" style="padding-top: 11px; padding-left: 2px;">
                    <li>
                        <!-- 原資材情報/購入先コード -->
                        <label>
                            <span class="item-label" data-app-text="genshi_cd_konyu"></span>
                            <span class="item-label" name="genshi_cd_konyu" id="genshi-cd_konyu" style="width: 325px;"></span>
                        </label>
                    </li>
                    <li>
                        <!-- 原資材情報/購入先名 -->
                        <label>
                            <span class="item-label" data-app-text="genshi_nm_konyu"></span>
                            <span class="item-label" name="genshi_nm_konyu" id="genshi-nm_konyu" style="width: 325px;"></span>
                        </label>
                    </li>
                    <li>
                        <!-- 原資材情報/納入リードタイム -->
                        <label>
                            <span class="item-label" data-app-text="genshi_leadtime"></span>
                            <span class="item-label" name="genshi_leadtime" id="genshi-leadtime" style="width: 325px;"></span>
                        </label>
                    </li>
                    <li>
                        <!-- 原資材情報/最低在庫 -->
                        <label>
                            <span class="item-label" data-app-text="genshi_zaiko_min"></span>
                            <span class="item-label" name="genshi_zaiko_min" id="genshi-zaiko_min" style="width: 325px;"></span>
                        </label>
                    </li>
                    <li>
                        <!-- 原資材情報/発注ロットサイズ -->
                        <label>
                            <span class="item-label" data-app-text="genshi_hachu_lot_size"></span>
                            <span class="item-label" name="genshi_hachu_lot_size" id="genshi-hachu_lot_size" style="width: 325px;"></span>
                        </label>
                    </li>
                    <li>
                        <!-- 原資材情報/使用単位 -->
                        <label>
                            <span class="item-label" data-app-text="genshi_tani_shiyo"></span>
                            <span class="item-label" name="genshi_tani_shiyo" id="genshi-tani_shiyo" style="width: 325px;"></span>
                        </label>
                    </li>
                </ul>
            </div>
        </div>
    </div>

    <!-- 検索結果一覧 -->
    <div class="result-list">
        <!-- グリッドコントロール固有のデザイン -- Start -->
        <div style="float: left; width: 50%;" id="left-grid">
            <div class="part-grid" id="simulation-grid">
                <!-- 明細(シミュレーションスプレッド) -->
                <table id="item-grid1"></table>
            </div>
        </div>
        <div style="float: right; width: 50%;" id="right-grid">
            <div class="part-grid" id="genryo-grid">
                <!-- 明細原料(原料スプレッド) -->
                <table id="item-grid2"></table>
            </div>
            <div class="part-grid" id="shizai-grid">
                <!-- 明細資材(資材スプレッド) -->
                <table id="item-grid3"></table>
            </div>
        </div>
        <!-- グリッドコントロール固有のデザイン -- End -->
    </div>

    <!-- 画面デザイン -- End -->
</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="FooterContent" runat="server">
    <!-- 画面デザイン -- Start -->

    <!-- 画面アーキテクチャ共通のデザイン -- Start -->
    <div class="command" style="left: 1px;">
        <!-- ボタン：保存 -->
        <button type="button" class="save-button" name="save_button" data-app-operation="save">
            <span class="icon"></span>
            <span data-app-text="save"></span>
        </button>
        <!-- ボタン：計画作成 -->
        <button type="button" class="planmake-button" name="planmake_button" data-app-operation="planmake">
            <span data-app-text="planmake"></span>
        </button>
        <!-- ボタン：EXCEL -->
        <button type="button" class="excel-button" name="excel_button" data-app-operation="excel">
            <span data-app-text="excel"></span>
        </button>
    </div>
    <div class="command" style="right: 9px;">
        <!-- ボタン：メニューへ -->
        <button type="button" class="menu-button" name="menu_button">
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
    <!-- 検索時ダイアログ -->
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
            <div class="command" style="position: absolute; left: 10px; top: 5px;">
                <button class="dlg-yes-button" name="dlg-yes-button" data-app-text="yes"></button>
            </div>
            <div class="command" style="position: absolute; right: 5px; top: 5px;">
                <button class="dlg-no-button" name="dlg-no-button" data-app-text="no"></button>
            </div>
        </div>
    </div>
    <!-- 保存時ダイアログ -->
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
            <div class="command" style="position: absolute; left: 10px; top: 5px;">
                <button class="dlg-yes-button" name="dlg-yes-button" data-app-text="yes"></button>
            </div>
            <div class="command" style="position: absolute; right: 5px; top: 5px;">
                <button class="dlg-no-button" name="dlg-no-button" data-app-text="no"></button>
            </div>
        </div>
    </div>
    <!-- 計画作成ボタン押下時の確認ダイアログ -->
    <div class="keikaku-confirm-dialog" style="display: none;">
        <div class="dialog-header">
            <h4 data-app-text="confirmTitle"></h4>
        </div>
        <div class="dialog-body" style="padding: 10px; width: 100%;">
            <div class="part-body">
                <span data-app-text="keikakuConfirm"></span>
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
    <!-- 製品一覧ダイアログ：検索条件/製品一覧ボタン押下時 -->
    <div class="con-seihin-button-dialog">
    </div>
    <!-- 画面デザイン -- End -->
</asp:Content>
