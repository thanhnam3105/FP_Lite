<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="GekkanShikakarihinKeikaku.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.GekkanShikakarihinKeikaku" %>

<asp:Content ID="Content1" ContentPlaceHolderID="IncludeContent" runat="server">
    <script src="<%=ResolveUrl("~/Resources/pages/pagedata-gekkanshikakarihinkeikaku." + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
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
        
        .save-confirm-dialog
        {
            background-color: White;
            width: 350px;
        }
        
        .save-confirm-dialog .part-body
        {
            width: 95%;
        }
        
        /*
        <%--.search-criteria .item-label
        {
            width: 7em;
        }--%>
        */

        .search-confirm-dialog
        {
            background-color: White;
            width: 350px;
        }
                
        .search-confirm-dialog .part-body
        {
            width: 95%;
        }
        
        .dateinput-confirm-dialog
        {
            background-color: White;
            width: 350px;
        }
                
        .dateinput-confirm-dialog .part-body
        {
            width: 95%;
        }
        
        .lotdelete-confirm-dialog
        {
            background-color: White;
            width: 350px;
        }
                
        .lotdelete-confirm-dialog .part-body
        {
            width: 95%;
        }
        
        .kakutei-confirm-dialog-upd
        {
            background-color: White;
            width: 350px;
        }
        
        .kakutei-confirm-dialog-upd .part-body
        {
            width: 95%;
        }
        
        .kakutei-confirm-dialog-del
        {
            background-color: White;
            width: 350px;
        }
        
        .kakutei-confirm-dialog-del .part-body
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

        .not-editable-cell
        {
            color: Gray;
        }
        
        .seihin-dialog
        {
            background-color: White;
            width: 620px;
        }
        
        .seihin-search-dialog
        {
            background-color: White;
            width: 620px;
        }
        
        button.seihin-button .icon
        {
            background-position: -48px -80px;
        }
        
        .line-dialog
        {
            background-color: White;
			width: 550px;
        }
        
        button.line-button .icon
        {
            background-position: -48px -80px;
        }

        .part-body .item-list-left li
        {
            float: left;
            width: 440px;
        }
        .part-body .item-list-right li
        {
            margin-left: 445px;
        }
        .part-footer
        {
            clear: left;
        }

        .date-input-box
        {
            width: 100px;
        }

        /*
        button.seihin-button
        {
            width: 225px;
        }

        button.line-button
        {
            width: 50px;
        }
        */
        
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
                isDataLoading = false;

            // グリッドコントロール固有の変数宣言
            var grid = $("#item-grid"),
                lastScrollTop = 0,
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
                changeSet = new App.ui.page.changeSet(),
            //firstCol = 3,
                firstCol = 2,
                duplicateCol = 999,
                currentRow = 0,
                currentCol = firstCol;

            // TODO: ここまで

            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            var shokubaCode, // 検索条件のコンボボックス
                lineCode, // 検索条件のコンボボックス
                yobiHidukeId = pageLangText.yobiHidukeId.data,
            // 必要日：セルのフォーカスを外す際に利用する。（編集対象セルではない）
                forcusCol = 1,
                seizoDateCol = 3,
                oyaShikakariNameCol = 4,
                hinCodeCol = 5,
                shikakarihinNameCol = 6,
                gassanNameCol = 7,
                taniNameCol = 8,
                shikakariKeikakuWeightCol = 10,
                lineNameCol = 12,
                lineCodeCol = 11,
                isYukoCol = 23,
            // 多言語対応にしたい項目を変数にする
                haigoName = 'nm_haigo_' + App.ui.page.lang,
                shikakariName = 'nm_shikakari_' + App.ui.page.lang,
                gassanKbnId = pageLangText.gassanKubunId.data, // 合算区分データオブジェクト
                isSearch = false,
                isCriteriaChange = false,
                selectedDateInputRow,
                selDateOption,
                filedownload,
                fileIngterval,
                loading;

            // 画面固有のグローバル変数定義
            // 他画面との競合を防ぐためにオブジェクトに格納する。
            var keikakuGamenObject = new Object();
            // 入力チェックエラーフラグ
            keikakuGamenObject.varidErrFlg = false;

            // 英語化対応　言語によって幅を調節
            $(".search-criteria .item-label").css("width", pageLangText.each_lang_width.number);

            // TODO：ここまで

            // ダイアログ固有の変数宣言
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            var saveConfirmDialog = $(".save-confirm-dialog"),
                searchConfirmDialog = $(".search-confirm-dialog"),
            // 計画確定確認ダイアログ(更新時)
                kakuteiConfirmDialogUpd = $(".kakutei-confirm-dialog-upd"),
            // 計画確定確認ダイアログ(削除時)
                kakuteiConfirmDialogDel = $(".kakutei-confirm-dialog-del"),
                dateInputConfirmDialog = $(".dateinput-confirm-dialog"),
                lotDeleteConfirmDialog = $(".lotdelete-confirm-dialog"),
                seihinDialog = $(".seihin-dialog"),
                seihinSearchDialog = $(".seihin-search-dialog"),
                lineDialog = $(".line-dialog");
            // TODO：ここまで

            //// 変数宣言 -- End

            //// コントロール定義 -- Start

            // ダイアログ固有のコントロール定義
            saveConfirmDialog.dlg();
            searchConfirmDialog.dlg();
            dateInputConfirmDialog.dlg();
            lotDeleteConfirmDialog.dlg();
            // 計画確定確認ダイアログ(更新時)
            kakuteiConfirmDialogUpd.dlg();
            // 計画確定確認ダイアログ(削除時)
            kakuteiConfirmDialogDel.dlg();

            /// <summary>保存確認ダイアログを開きます。</summary>
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
            /// <summary>ダイアログを開きます。</summary>
            var showDateInputConfirmDialog = function (id, opt) {
                // 現在の選択行をチェック
                selectedDateInputRow = id;
                selDateOption = opt; // ダイアログを保存
                dateInputConfirmDialogNotifyInfo.clear();
                dateInputConfirmDialogNotifyAlert.clear();
                dateInputConfirmDialog.draggable(true);
                dateInputConfirmDialog.dlg("open");
            };
            /// <summary>ダイアログを開きます。</summary>
            var showLotDeleteConfirmDialog = function (id, opt) {
                // 現在の選択行をチェック
                lotDeleteConfirmDialogNotifyInfo.clear();
                lotDeleteConfirmDialogNotifyAlert.clear();
                lotDeleteConfirmDialog.draggable(true);
                lotDeleteConfirmDialog.dlg("open");
            };

            /// <summary> 計画確定確認ダイアログ(更新時)を開きます</summary>///
            var showKakuteiConfirmDialogUpd = function () {
                kakuteiConfirmDialogUpdNotifyInfo.clear();
                kakuteiConfirmDialogUpd.draggable(true);
                kakuteiConfirmDialogUpd.dlg("open");
            }

            /// <summary> 計画確定確認ダイアログ(削除時)を開きます</summary>///
            var showKakuteiConfirmDialogDel = function () {
                kakuteiConfirmDialogDelNotifyInfo.clear();
                kakuteiConfirmDialogDel.draggable(true);
                kakuteiConfirmDialogDel.dlg("open");
            }

            /// <summary>ダイアログを閉じます。</summary>
            var closeSaveConfirmDialog = function () {
                saveConfirmDialog.dlg("close");
            };
            var closeSearchConfirmDialog = function () {
                searchConfirmDialog.dlg("close");
            };
            var closeDateInputConfirmDialog = function () {
                dateInputConfirmDialog.dlg("close");
            };
            var closeLotDeleteConfirmDialog = function () {
                lotDeleteConfirmDialog.dlg("close");
            };

            /// <summary>計画確定確認ダイアログ(更新時)を閉じます</summary>
            var closeKakuteiConfirmDialogUpd = function () {

                // 製造日クリック時に開いた場合は閉じる際に、再度、編集モードにする。
                if (currentCol === seizoDateCol) {
                    // 選択行IDを取得する。
                    var selectedRowId = getSelectedRowId(false);
                    // 製造日を編集モードにする。
                    grid.jqGrid('editCell', selectedRowId, seizoDateCol, true);
                }

                // 計画確定確認ダイアログを閉じる。
                kakuteiConfirmDialogUpd.dlg("close");

            };

            /// <summary>計画確定確認ダイアログ(削除時)を閉じます</summary>
            var closeKakuteiConfirmDialogDel = function () {
                // 計画確定確認ダイアログを閉じる。
                kakuteiConfirmDialogDel.dlg("close");

                // 行削除時は行削除を実行する。
                preDeleteCheck();

            };

            // 日付確認時戻り処理
            var clearInputOldDate = function () {
                if (!App.isUndefOrNull(selDateOption)) {
                    // ダイアログが選択されていれば、ダイアログ起動
                    switch (selDateOption) {
                        case "seizodate":
                            // 過去日付選択
                            grid.setCell(selectedDateInputRow, "dt_seizo", null);
                            grid.jqGrid('editCell', selectedDateInputRow, seizoDateCol, true);
                            break;
                        case "seihin":
                            showSeihinDialog();
                            break;
                    }
                }
                closeDateInputConfirmDialog();
            };

            // 製品ダイアログ生成
            seihinDialog.dlg({
                url: "Dialog/HinmeiDialog.aspx",
                name: "HinmeiDialog",
                closed: function (e, data, data2) {

                    // 計画確定ダイアログが表示されることがあるので閉じる。
                    kakuteiConfirmDialogUpd.dlg("close");

                    if (data == "canceled") {
                        return;
                    }
                    else {
                        var selectedRowId = getSelectedRowId(false);
                        grid.setCell(selectedRowId, "cd_hinmei", data);
                        grid.setCell(selectedRowId, shikakariName, data2);

                        // 取得したコードについているデータを取得
                        setRelatedHinmeiCode(selectedRowId, data);
                        validateCell(selectedRowId, "cd_hinmei", data, hinCodeCol);
                        validateCell(selectedRowId, "nm_tani", grid.getCell(selectedRowId, "nm_tani"), taniNameCol);
                        validateCell(selectedRowId, "nm_gassan_kbn", grid.getCell(selectedRowId, "nm_gassan_kbn"), gassanNameCol);

                        // 更新状態の変更セットに変更データを追加
                        var changeData = setCreatedChangeData(grid.getRowData(selectedRowId));
                        changeSet.addCreated(selectedRowId, "cd_hinmei", data, changeData);
                        changeSet.addCreated(selectedRowId, "cd_line", grid.getCell(selectedRowId, "cd_line"), changeData);
                        changeSet.addCreated(selectedRowId, "ritsu_kihon", grid.getCell(selectedRowId, "ritsu_kihon"), changeData);
                        changeSet.addCreated(selectedRowId, "wt_haigo_gokei", grid.getCell(selectedRowId, "wt_haigo_gokei"), changeData);
                    }
                }
            });

            // 検索用製品ダイアログ生成
            seihinSearchDialog.dlg({
                url: "Dialog/HinmeiDialog.aspx",
                name: "HinmeiDialog",
                closed: function (e, data, data2) {
                    if (data == "canceled") {
                        return;
                    }
                    else {
                        $(".search-criteria [name='cd_hinmei_search']").val(data);
                        $("#nm_hinmei_search_label").text(data2);
                        // 検索バリデーションを実行
                        $(".part-body .item-list").validation().validate();
                    }
                }
            });

            // ラインダイアログ生成
            lineDialog.dlg({
                url: "Dialog/SeizoLineDialog.aspx",
                name: "SeizoLineDialog",
                closed: function (e, data, data2) {
                    if (data == "canceled") {
                        return;
                    }
                    else {
                        var selectedRowId = getSelectedRowId(false);
                        grid.setCell(selectedRowId, "cd_line", data);
                        grid.setCell(selectedRowId, "nm_line", data2);

                        // 更新状態の変更セットに変更データを追加
                        var changeData = setCreatedChangeData(grid.getRowData(selectedRowId));
                        //changeSet.addUpdated(selectedRowId, "cd_line", data, changeData);
                        changeSet.addCreated(selectedRowId, changeData);
                    }
                }
            });

            /// <summary>datepickerの有効範囲を設定する：1975/1/1～システム日付より1年後</summary>
            var setDatepickerRange = function (dateElm) {
                dateElm.datepicker("option", 'minDate', new Date(1975, 1 - 1, 1));
                dateElm.datepicker("option", 'maxDate', "+1y");
            };

            // 日付の多言語対応
            var datePickerFormat = pageLangText.dateFormatUS.text;
            var newDateMMDDFormat = pageLangText.dateMMDDFormatUS.text;
            var newDateFormat = pageLangText.dateNewFormatUS.text;
            var newDateTimeFormat = pageLangText.dateTimeNewFormatUS.text;
            if (App.ui.page.langCountry !== 'en-US') {
                datePickerFormat = pageLangText.dateFormat.text;
                newDateMMDDFormat = pageLangText.dateMMDDFormat.text;
                newDateFormat = pageLangText.dateNewFormat.text;
                newDateTimeFormat = pageLangText.dateTimeNewFormat.text;
            }
            // datepicker の設定を変更してください。
            $('#dt_hiduke_from').datepicker({
                maxDate: $('#dt_hiduke_to').val(),
                numberOfMonths: 3,
                showCurrentAtPos: 1,  //月の表示開始
                stepMonths: 3,
                dateFormat: datePickerFormat,
                onSelect: function (dateText, inst) {
                    $('#dt_hiduke_to').datepicker('option', 'minDate', dateText);
                }
            });

            $('#dt_hiduke_to').datepicker({
                minDate: $('#dt_hiduke_from').val(),
                numberOfMonths: 3,
                showCurrentAtPos: 1,
                stepMonths: 3,
                dateFormat: datePickerFormat,
                onSelect: function (dateText, inst) {
                    $('#dt_hiduke_from').datepicker('option', 'maxDate', dateText);
                }
            });
            // TODO：ここまで

            // グリッドコントロール固有のコントロール定義
            grid.jqGrid({
                // TODO：画面の仕様に応じて以下の列名の定義を変更してください。
                colNames: [
                    pageLangText.dt_hitsuyo.text
                    , pageLangText.dt_hitusyo_yobi.text
                    , pageLangText.dt_shikomi.text + pageLangText.requiredMark.text
                    , pageLangText.nm_hinmei.text
                    , pageLangText.cd_shikakari.text + pageLangText.requiredMark.text
                    , pageLangText.nm_shikakarihin.text
                    , pageLangText.kbn_gassan.text
                    , pageLangText.tan_shiyo.text
                    , pageLangText.wt_hituyo.text
                    , pageLangText.wt_shikomi.text + pageLangText.requiredMark.text
                    , pageLangText.cd_line.text + pageLangText.requiredMark.text
                    , pageLangText.nm_line.text
                    , pageLangText.blank.text
                    , pageLangText.no_lot_shikakari.text
                    , pageLangText.blank.text
                    , pageLangText.blank.text
                    , pageLangText.blank.text
                    , pageLangText.blank.text
                    , pageLangText.blank.text
                    , pageLangText.blank.text
                    , pageLangText.no_lot_oya.text
                    , pageLangText.no_lot_seihin.text
                    , pageLangText.blank.text
                    , pageLangText.blank.text
                    , pageLangText.blank.text
                    , pageLangText.blank.text
                    , pageLangText.blank.text
                // 製造実績フラグ
                    , "hidden"
                // 仕込計画確定フラグ
                    , "hidden"
                // 仕込実績フラグ
                    , "hidden"
                // ラベル発行済みフラグ
                    , "hidden"
                // 端数ラベル発行済みフラグ
                    , "hidden"
                ],
                // TODO：ここまで
                // TODO：画面の仕様に応じて以下の列モデルの定義を変更してください。
                colModel: [
                    { name: 'dt_hitsuyo_tukihi', width: pageLangText.dt_hitsuyo_tukihi_width.number, align: "center",
                        formatter: "date",
                        formatoptions: {
                            srmformat: newDateTimeFormat
                            , newformat: newDateMMDDFormat
                        }
                    },
                    { name: 'dt_hitsuyo_yobi', width: pageLangText.dt_hitsuyo_yobi_width.number, align: "center",
                        formatter: "date",
                        formatoptions: {
                            srcformat: newDateTimeFormat
                           , newformat: pageLangText.dateDayFormat.text
                        }
                    },
                    { name: 'dt_seizo', width: pageLangText.dt_seizo_width.number, editable: true,
                        formatter: "date",
                        formatoptions: {
                            srcformat: newDateTimeFormat
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
                                        $("#" + idNum + " td:eq('" + oyaShikakariNameCol + "')").click();
                                    }
                                });
                            }
                        },
                        unformat: unformatDate
                    },
                //{ name: haigoName, width: pageLangText.nm_haigo_width.number, editable: false, sorttype: "text" },
                //{ name: 'cd_hinmei', width: pageLangText.cd_hinmei_width.number, editable: true, sorttype: "text" },
                //{ name: shikakariName, width: pageLangText.nm_shikakari_width.number, editable: false, sorttype: "text" },
                    {name: haigoName, width: pageLangText.nm_haigo_width.number, editable: false },
                    { name: 'cd_hinmei', width: pageLangText.cd_hinmei_width.number, editable: true },
                    { name: shikakariName, width: pageLangText.nm_shikakari_width.number, editable: false },
                    { name: 'nm_gassan_kbn', width: pageLangText.nm_gassan_kbn_width.number, editable: false, formatter: gassanKbnFormatter },
                    { name: 'nm_tani', width: pageLangText.nm_tani_width.number, editable: false },
                //{ name: 'wt_hitsuyo', width: pageLangText.wt_hitsuyo_width.number, editable: false, align: "right", sorttype: "float",
                //formatter: 'number',
                //formatoptions: {
                //decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 0, defaultValue: 0
                // }
                //},
                    {name: 'wt_hitsuyo', width: pageLangText.wt_hitsuyo_width.number, editable: false, align: "right",
                    formatter: 'number',
                    formatoptions: {
                        // decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 0, defaultValue: 0
                        decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 3, defaultValue: 0
                    }
                },
                //{ name: 'wt_shikomi_keikaku', width: pageLangText.wt_shikomi_keikaku_width.number, editable: true, align: "right", sorttype: "float",
                // formatter: 'number',
                // formatoptions: {
                //decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 6, defaultValue: 0
                // }
                // },
                    {name: 'wt_shikomi_keikaku', width: pageLangText.wt_shikomi_keikaku_width.number, editable: true, align: "right",
                    formatter: 'number',
                    formatoptions: {
                        // decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 6, defaultValue: 0
                        decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 3, defaultValue: 0
                    }
                },
                    { name: 'cd_line', width: pageLangText.cd_line_width.number, editable: true },
                    { name: 'nm_line', width: pageLangText.nm_line_width.number, editable: false },
                    { name: 'flg_gassan_shikomi', hidden: true, hidedlg: true },
                    { name: 'no_lot_shikakari', width: pageLangText.no_lot_shikakari_width.number },
                    { name: 'flg_kyujitsu', hidden: true, hidedlg: true, formatter: kyujitsuFormatter },
                    { name: 'flg_shukujitsu', hidden: true, hidedlg: true },
                    { name: 'cd_shokuba', hidden: true, hidedlg: true },
                    { name: 'data_key', hidden: true, hidedlg: true },
                    { name: 'dt_seizo_hidden', hidden: true, hidedlg: true },
                    { name: 'dt_hitsuyo_hidden', hidden: true, hidedlg: true },
                    { name: 'no_lot_shikakari_oya', width: pageLangText.no_lot_shikakari_oya_width.number },
                    { name: 'no_lot_seihin', width: pageLangText.no_lot_seihin_width.number },
                    { name: 'isYukoHaigoCode', hidden: true, hidedlg: true },
                    { name: 'ritsu_kihon', hidden: true, hidedlg: true },
                    { name: 'wt_haigo_gokei', hidden: true, hidedlg: true },
                    { name: 'oyaCnt', hidden: true, hidedlg: true },
                    { name: 'id', hidden: true, hidedlg: true, key: true }
                // 製品実績フラグ
                    , { name: 'flg_jisseki', hidden: true, hidedlg: true }
                // 仕込計画確定フラグ
                    , { name: 'flg_keikaku', hidden: true, hidedlg: true }
                // 仕込実績フラグ
                    , { name: 'flg_shikakari_jisseki', hidden: true, hidedlg: true }
                // ラベル発行済みフラグ
                    , { name: 'flg_label', hidden: true, hidedlg: true }
                // 端数ラベル発行済みフラグ
                    , { name: 'flg_label_hasu', hidden: true, hidedlg: true }
                ],
                // TODO：ここまで
                datatype: "local",
                shrinkToFit: false,
                multiselect: false,
                rownumbers: true,
                cellEdit: true,
                onRightClickRow: function (rowid) {
                    $(".ui-datepicker").css("display", "none");
                    $("#" + rowid).removeClass("ui-state-highlight").find("td").click();
                },
                cellsubmit: 'clientArray',
                loadonce: true,
                onSortCol: function () {
                    grid.setGridParam({ rowNum: grid.getGridParam("records") });
                },
                loadComplete: function () {
                    // 変数宣言
                    var ids = grid.jqGrid('getDataIDs');

                    // TODO：ここから
                    // 製品ロット・配合名がある場合は、仕込日/仕掛品名操作不可
                    for (var i = 0; i < ids.length; i++) {
                        var id = ids[i];
                        var lotSeihin = grid.getCell(id, "no_lot_seihin");
                        var lotOya = grid.getCell(id, "no_lot_shikakari_oya");
                        var oyaCnt = grid.getCell(id, "oyaCnt");
                        var cdLine = grid.getCell(id, "cd_line");
                        var lotShikakari = grid.getCell(id, "no_lot_shikakari");

                        // 製品ロット／親ロットが登録済みの場合、操作不可
                        if (!lotSeihin == "" || !lotOya == "" || oyaCnt > 0) {
                            grid.jqGrid('setCell', id, 'dt_seizo', '', 'not-editable-cell');
                            grid.jqGrid('setCell', id, 'cd_hinmei', '', 'not-editable-cell');
                            grid.jqGrid('setCell', id, 'cd_line', '', 'not-editable-cell');
                        }

                        // 仕掛品ロッドNo.がある場合
                        if (!App.isUndefOrNull(lotShikakari) && !lotShikakari == "") {
                            grid.jqGrid('setCell', id, 'cd_line', '', 'not-editable-cell');
                        }

                        // 休日色を付ける
                        if (pageLangText.seihinHinKbn.text == grid.getCell(id, "flg_kyujitsu")) {
                            grid.toggleClassRow(this.rows[i + 1].id, "kyujitsuColor");
                        }

                        // 仕込実績がある場合
                        if (grid.getCell(id, "flg_shikakari_jisseki") == 1) {
                            // 製造日を編集不可に設定
                            grid.jqGrid('setCell', id, 'dt_seizo', '', 'not-editable-cell');
                            // 品名コードを編集不可に設定
                            grid.jqGrid('setCell', id, 'cd_hinmei', '', 'not-editable-cell');
                            // 計画仕込量を編集不可に設定
                            grid.jqGrid('setCell', id, 'wt_shikomi_keikaku', '', 'not-editable-cell');
                            // ラインコードを編集不可に設定
                            grid.jqGrid('setCell', id, 'cd_line', '', 'not-editable-cell');
                        }

                    }

                    // グリッドの先頭行を選択
                    //$("#" + 1).removeClass("ui-state-highlight").find("td").click();
                    $("#" + 1 + " > td:nth-child(" + forcusCol + ")").click();
                    // TODO：ここまで
                },
                beforeEditCell: function (selectedRowId, cellName, value, iRow, iCol) {
                    currentRow = iRow;
                    currentCol = iCol;

                    // 仕込計画確定が確定しているかラベルが発行済みの場合は注意ダイアログを表示する。
                    if ((iCol === shikakariKeikakuWeightCol || iCol === hinCodeCol)
                        && checkJissekiData(selectedRowId)) {
                        // 計画確定確認ダイアログを表示する。
                        showKakuteiConfirmDialogUpd();
                    }
                },
                afterEditCell: function (selectedRowId, cellName, value, iRow, iCol) {
                    // Enter キーでカーソルを移動
                    grid.moveCell(cellName, iRow, iCol);
                    selectCol = iCol;
                },
                beforeSaveCell: function (selectedRowId, cellName, value, iRow, iCol) {
                    // セルバリデーション
                    //validateCell(selectedRowId, cellName, value, iCol);
                    if (!validateCell(selectedRowId, cellName, value, iCol)) {
                        // バリデーションエラーの場合、バリデーションエラーフラグを立てる
                        keikakuGamenObject.varidErrFlg = true;
                    }
                },
                afterSaveCell: function (selectedRowId, cellName, value, iRow, iCol) {

                    // バリデーションエラーの場合はリストアして処理を終わる。
                    if (keikakuGamenObject.varidErrFlg) {
                        // リストア
                        grid.restoreCell(iRow, iCol);
                        // バリデーションエラーフラグの初期化
                        keikakuGamenObject.varidErrFlg = false;
                        return;
                    }

                    // 関連項目の設定
                    // 更新状態の変更セットに変更データを追加
                    // 品名コード選択時は、関連項目も取得
                    if (iCol == hinCodeCol) {
                        var seizoDate = grid.getCell(selectedRowId, "dt_seizo");
                        var res_dtSeizo = validateCell(selectedRowId, "dt_seizo", seizoDate, seizoDateCol);
                        if (res_dtSeizo) {
                            // 仕掛品コードでバリデーションエラーが発生していなければ、関連データを取得する
                            if (validateCell(selectedRowId, "cd_hinmei", value, hinCodeCol)) {
                                // 取得したコードについているデータを取得
                                setRelatedHinmeiCode(selectedRowId, value);
                                // 再チェックでエラー状態の解除
                                validateCell(selectedRowId, "cd_hinmei", value, hinCodeCol);
                                validateCell(selectedRowId, "nm_tani", grid.getCell(selectedRowId, "nm_tani"), taniNameCol);
                                validateCell(selectedRowId, "nm_gassan_kbn", grid.getCell(selectedRowId, "nm_gassan_kbn"), gassanNameCol);
                                validateCell(selectedRowId, "isYukoHaigoCode", grid.getCell(selectedRowId, "isYukoHaigoCode"), isYukoCol);
                            }
                            else {

                                // 品名情報をクリアする
                                clearHinmeiInfo(selectedRowId);

                            }
                        }
                        else {
                            // 品名情報をクリアする
                            clearHinmeiInfo(selectedRowId);
                            grid.setCell(selectedRowId, "cd_hinmei", null);
                            // ライン情報をクリアする
                            //grid.setCell(selectedRowId, "nm_line", null);
                            //grid.setCell(selectedRowId, "cd_line", null);
                        }
                    }


                    if (iCol == lineCodeCol) {
                        var hinCd = grid.getCell(selectedRowId, "cd_hinmei");
                        var res_cdHin = validateCell(selectedRowId, "cd_hinmei", hinCd, hinCodeCol);
                        if (res_cdHin) {
                            // 取得したコードについているデータを取得
                            setRelatedLine(selectedRowId, hinCd, value);
                        }
                    }

                    // 変更データの変数設定
                    var changeData;
                    // 更新
                    // 追加状態のデータ設定
                    changeData = setCreatedChangeData(grid.getRowData(selectedRowId));
                    // 追加状態の変更セットに変更データを追加
                    changeSet.addCreated(selectedRowId, changeData);
                    //}

                    // 過去製造日を入力した場合に、確認
                    if (iCol === seizoDateCol) {
                        if (value.match(/^\d{4}\/\d{2}\/\d{2}$/)) { // 日付確認
                            if (new Date(new Date().setHours(0, 0, 0, 0)) > App.date.localDate(value)) {
                                showDateInputConfirmDialog(selectedRowId, "seizodate");
                            }
                        }
                        else if (value.match(/^\d{2}\/\d{2}\/\d{4}$/)) { // 日付確認
                            if (new Date(new Date().setHours(0, 0, 0, 0)) > App.date.localDate(value)) {
                                showDateInputConfirmDialog(selectedRowId, "seizodate");
                            }
                        }
                    }
                },
                onCellSelect: function (rowid, icol, cellcontent) {
                    selectCol = icol;
                    // 製造日の場合は、datepickerの制御のため、ここでダイアログ表示する。
                    if (icol === seizoDateCol && checkJissekiData(rowid)) {
                        // 計画確定確認ダイアログを表示する。
                        showKakuteiConfirmDialogUpd();
                    }
                },
                ondblClickRow: function (rowid) {

                    // 仕込実績フラグ
                    var flg_shikakari_jisseki;
                    // 製品ロット番号
                    var no_lot_seihin;
                    // 親仕掛品ロット番号
                    var no_lot_shikakari_oya;
                    // 編集不可フラグ
                    var isUneditable = false;

                    // 入力チェック
                    if (selectCol === seizoDateCol || selectCol === shikakariKeikakuWeightCol
                        || selectCol === hinCodeCol || selectCol === shikakarihinNameCol) {

                        // 仕込実績フラグを取得
                        flg_shikakari_jisseki = grid.getCell(rowid, "flg_shikakari_jisseki");

                        // 製品計画ロット番号を取得。
                        no_lot_seihin = grid.getCell(rowid, "no_lot_seihin");
                        // 親仕掛品ロット番号を取得。
                        no_lot_shikakari_oya = grid.getCell(rowid, "no_lot_shikakari_oya");

                        // 仕込実績がある場合
                        if (flg_shikakari_jisseki == 1) {
                            // メッセージを表示する。
                            // MS0801:{0}が確定済みです。データの{1}はできません。[仕込実績、更新]
                            App.ui.page.notifyInfo.message(
                             App.str.format(pageLangText.jissekiCheck.text, pageLangText.shikakariJisseki.text, pageLangText.upd.text)
                            ).show();

                            isUneditable = true;
                        }

                        // 製品計画からつくられた場合
                        // ※仕込量は変更可のためチェックしない。
                        if (((!App.isUndefOrNull(no_lot_seihin) && no_lot_seihin != "")
                            || (!App.isUndefOrNull(no_lot_shikakari_oya) && no_lot_shikakari_oya != ""))
                            && selectCol != shikakariKeikakuWeightCol) {

                            // メッセージを表示する。
                            // MS0708:製品計画画面から作られた計画に対しては、この操作はできません
                            App.ui.page.notifyInfo.message(MS0708).show();

                            isUneditable = true;
                        }
                    }

                    // 編集不可判定
                    if (isUneditable) {
                        // 編集不可の場合は処理を終了する
                        return;
                    }

                    // 権限が管理者、作業者の場合のみ実行
                    var roles = App.ui.page.user.Roles[0];
                    if (roles == pageLangText.admin.text || roles == pageLangText.operator.text) {
                        // 仕掛品一覧（品名セレクタ起動）
                        if (selectCol == hinCodeCol || selectCol == shikakarihinNameCol) {
                            checkSeihinDialog(rowid);
                        }
                        // ライン一覧
                        if (selectCol == lineCodeCol || selectCol == lineNameCol) {
                            checkLineDialog(rowid);
                        }
                    }

                    // 計画確定ダイアログが表示されることがあるので閉じる。
                    kakuteiConfirmDialogUpd.dlg("close");
                }
            });

            /// <summary>日付型のセルをunformatします</summary>
            function unformatDate(cellvalue, options) {
                var nbsp = String.fromCharCode(160);
                if (cellvalue == nbsp) {
                    return "";
                }
                return cellvalue;
            };

            /// <summary>
            ///     <p>再選択処理</p>
            ///     <p>行を再選択し、フォーカスを外します。</p>
            /// </summary>
            var reSelectRow = function () {
                kakuteiConfirmDialogUpd.dlg("close");
                kakuteiConfirmDialogDel.dlg("close");

                // 対象行を設定する。
                var selectedRowId = getSelectedRowId(false)

                // ダイアログを閉じるときに、対象セルからのフォーカスを外す
                $("#" + selectedRowId + " > td:nth-child(" + forcusCol + ")").click();
            };

            /// <summary>品名コード、仕掛品名称、換算区分、単位、基本倍率、合計配合重量を空白にする</summary>
            /// <param name="selectedRowId">選択行ID</param>
            var clearHinmeiInfo = function (selectedRowId) {
                grid.setCell(selectedRowId, shikakariName, null);
                grid.setCell(selectedRowId, "flg_gassan_shikomi", null);
                grid.setCell(selectedRowId, "nm_gassan_kbn", null);
                grid.setCell(selectedRowId, "nm_tani", null);
                grid.setCell(selectedRowId, "wt_hitsuyo", 0);
                grid.setCell(selectedRowId, "wt_shikomi_keikaku", 0);
                grid.setCell(selectedRowId, "nm_line", null);
                grid.setCell(selectedRowId, "cd_line", null);
                grid.setCell(selectedRowId, "no_lot_shikakari", null);
                grid.setCell(selectedRowId, "isYukoHaigoCode", false);
                grid.setCell(selectedRowId, "ritsu_kihon", null);
                grid.setCell(selectedRowId, "wt_haigo_gokei", null);
            };

            /// <summary>セルの関連項目を設定します。</summary>
            /// <param name="selectedRowId">選択行ID</param>
            /// <param name="value">品コード</param>
            var setRelatedHinmeiCode = function (selectedRowId, value) {
                // 手入力時は名称も取得
                // 行データを取得する
                var data = grid.getRowData(selectedRowId),
                    hinmei,
                    seizoLine;
                var dateSeizo = data.dt_seizo;
                if (typeof dateSeizo === "string"
                    && dateSeizo.match(/^\d{2}\/\d{2}\/\d{4}/) && App.ui.page.langCountry !== 'en-US') {
                    dateSeizo = dateSeizo.replace(/^(\d{2})\/(\d{2})\/(\d{4})/, "$2/$1/$3");
                }
                App.deferred.parallel({
                    // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                    loading: App.ui.loading.show(pageLangText.nowProgressing.text),
                    // 品名を取得
                    hinmei: App.ajax.webgetSync(App.data.toWebAPIFormat(
                                            { url: "../api/YukoHaigoMei"
                                                , cd_hinmei: value
                                                , dt_seizo: dateSeizo
                                                , flg_mishiyo: pageLangText.shiyoMishiyoFlg.text
                                            })),

                    // 製造可能ライン(優先一位)
                    seizoLine: App.ajax.webgetSync("../Services/FoodProcsService.svc/vw_ma_seizo_line_01()?$filter="
                                                + "seizo_line_mishiyo eq " + pageLangText.shiyoMishiyoFlg.text
                                                + " and line_mishiyo eq " + pageLangText.shiyoMishiyoFlg.text
                                                + " and kbn_master eq " + pageLangText.haigoMasterSeizoLineMasterKbn.text
                                                + " and cd_haigo eq '" + value
                                                + "' and cd_shokuba eq '" + data.cd_shokuba
                                                + "' & $orderby=no_juni_yusen,cd_line & $top=1")

                    // TODO: ここまで
                }).done(function (result) {
                    // TODO: 画面の仕様に応じて以下のサービス呼び出し成功時の処理を変更してください。
                    hinmei = result.successes.hinmei.d;
                    seizoLine = result.successes.seizoLine.d;

                    if (App.isUndefOrNull(hinmei[0])) {
                        // 品名コード未登録の場合、仕掛品名称、換算区分、単位、基本倍率、合計配合重量を空白にする
                        clearHinmeiInfo(selectedRowId);
                    }
                    else {
                        // 取得できた場合、その内容を設定
                        var res = result.successes.hinmei.d[0];
                        grid.setCell(selectedRowId, shikakariName, res[haigoName]);
                        grid.setCell(selectedRowId, "flg_gassan_shikomi", res["flg_gassan_shikomi"]);
                        grid.setCell(selectedRowId, "nm_gassan_kbn", res["flg_gassan_shikomi"]); // gridのフォーマッタで表示
                        grid.setCell(selectedRowId, "nm_tani", res["nm_tani"]);
                        grid.setCell(selectedRowId, "isYukoHaigoCode", true);
                        grid.setCell(selectedRowId, "ritsu_kihon", res["ritsu_kihon"]);
                        grid.setCell(selectedRowId, "wt_haigo_gokei", res["wt_haigo_gokei"]);
                    }

                    var selLineCode = null;
                    if (App.isUndefOrNull(seizoLine[0])) {
                        // 製造ライン未登録
                        grid.setCell(selectedRowId, "nm_line", null);
                        grid.setCell(selectedRowId, "cd_line", null);
                        //grid.setCell(selectedRowId, "cd_line", selLineCode);
                    }
                    else {
                        // 取得できた場合、その内容を設定
                        grid.setCell(selectedRowId, "cd_line", "", { background: 'none' });
                        selLineCode = result.successes.seizoLine.d[0]["cd_line"];
                        grid.setCell(selectedRowId, "nm_line", result.successes.seizoLine.d[0]["nm_line"]);
                        grid.setCell(selectedRowId, "cd_line", selLineCode);
                    }
                    // ラインのバリデーション
                    validateCell(selectedRowId, "cd_line", grid.getCell(selectedRowId, "cd_line"), lineCodeCol);
                    //validateCell(selectedRowId, "nm_line", grid.getCell(selectedRowId, "nm_line"), lineNameCol);

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

            };

            /// <summary>セルの関連項目を設定します。</summary>
            /// <param name="selectedRowId">選択行ID</param>
            /// <param name="hicCd">品コード</param>
            /// <param name="value">入力したコード</param>
            var setRelatedLine = function (selectedRowId, hinCd, val) {
                // 手入力時は名称も取得
                // 行データを取得する
                var data = grid.getRowData(selectedRowId),
                    seizoLine;
                App.deferred.parallel({
                    // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                    loading: App.ui.loading.show(pageLangText.nowProgressing.text),
                    // 製造可能ライン(優先一位)
                    seizoLine: App.ajax.webgetSync("../Services/FoodProcsService.svc/vw_ma_seizo_line_01()?$filter="
                                                + "seizo_line_mishiyo eq " + pageLangText.shiyoMishiyoFlg.text
                                                + " and line_mishiyo eq " + pageLangText.shiyoMishiyoFlg.text
                                                + " and kbn_master eq " + pageLangText.haigoMasterSeizoLineMasterKbn.text
                                                + " and cd_haigo eq '" + hinCd
                                                + "' and cd_line eq '" + val
                                                + "' and cd_shokuba eq '" + data.cd_shokuba
                                                + "' & orderby=no_juni_yusen,cd_line & $top=1")

                    // TODO: ここまで
                }).done(function (result) {
                    // TODO: 画面の仕様に応じて以下のサービス呼び出し成功時の処理を変更してください。
                    seizoLine = result.successes.seizoLine.d;
                    var selLineCode = "",
                        unique = selectedRowId + "_" + lineCodeCol;
                    if (App.isUndefOrNull(seizoLine[0])) {
                        // 製造ライン未登録
                        grid.setCell(selectedRowId, "nm_line", null);
                        grid.setCell(selectedRowId, "cd_line", null);
                        //grid.setCell(selectedRowId, "cd_line", selLineCode);
                        App.ui.page.notifyAlert.message(
                                 App.str.format(MS0022, pageLangText.cd_line.text)
                            , unique).show();
                        //{0}は有効な値ではありません。(MS0022)
                        //指定された%sは存在しません。(MS0049)

                        // セルの背景色を赤くする。
                        grid.setCell(selectedRowId, "cd_line", "", { background: '#ff6666' });
                    }
                    else {
                        // 取得できた場合、その内容を設定
                        grid.setCell(selectedRowId, "cd_line", "", { background: 'none' });
                        selLineCode = result.successes.seizoLine.d[0]["cd_line"];
                        grid.setCell(selectedRowId, "nm_line", result.successes.seizoLine.d[0]["nm_line"]);
                        grid.setCell(selectedRowId, "cd_line", selLineCode);
                        // ラインのバリデーション
                        validateCell(selectedRowId, "cd_line", grid.getCell(selectedRowId, "cd_line"), lineCodeCol);
                    }
                    // ラインのバリデーション
                    //validateCell(selectedRowId, "cd_line", grid.getCell(selectedRowId, "cd_line"), lineCodeCol);
                    //validateCell(selectedRowId, "nm_line", grid.getCell(selectedRowId, "nm_line"), lineNameCol);

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

            /// <summary>合算区分表示時のイベント処理を行います。</summary>
            function gassanKbnFormatter(cellvalue, options, rowObject) {
                // 合算区分の表示
                var gassanKbn = rowObject.flg_gassan_shikomi;
                gassanKbn = App.isUndefOrNull(gassanKbn) ? cellvalue : gassanKbn;
                if (App.isUndefOrNull(gassanKbn)) {
                    return "";
                }

                for (var i = 0; i < gassanKbnId.length; i++) {
                    if (gassanKbn == gassanKbnId[i].id) {
                        // TODO：置換する文字内容の変更
                        return gassanKbnId[i].name;
                    }
                }

                // フォーマット前の値を返却
                return cellvalue;
            }

            /// <summary>休日表示イベント処理を行います。</summary>
            function kyujitsuFormatter(cellvalue, options, rowObject) {
                // 休日表示
                if (App.isUndefOrNull(cellvalue)) {
                    return cellvalue;
                }

                if (pageLangText.kyujitsuKyujitsuFlg.value == cellvalue) {
                    grid.toggleClassRow(options.rowId, "kyujitsuColor");
                }

                return cellvalue;
            }

            /// <summary>計画確定チェック処理</summary>
            var checkJissekiData = function (rowId) {

                var result = false;

                if (grid.getCell(rowId, "flg_keikaku") == 1
                    || grid.getCell(rowId, "flg_label") == 1
                    || grid.getCell(rowId, "flg_label_hasu") == 1) {

                    result = true;
                }

                return result;
            };

            //// コントロール定義 -- End

            //// 操作制御定義 -- Start

            // 操作制御定義を定義します。
            App.ui.pagedata.operation.applySetting(App.ui.page.user.Roles[0], App.ui.page.lang);

            //// 操作制御定義 -- End

            //// 事前データロード -- Start 

            // 画面アーキテクチャ共通の事前データロード
            App.deferred.parallel({
                loading: App.ui.loading.show(pageLangText.nowProgressing.text),
                // 未使用フラグ：１　にて抽出
                shokubaCode: App.ajax.webgetSync("../Services/FoodProcsService.svc/ma_shokuba()?$filter=flg_mishiyo eq "
                                            + pageLangText.shiyoMishiyoFlg.text + " & orderby eq cd_shokuba")
            }).done(function (result) {
                // サービス呼び出し成功時の処理
                shokubaCode = result.successes.shokubaCode.d;
                var shokubaTarget = $(".search-criteria [name='shokubaCode']");
                // 検索用ドロップダウンの設定
                App.ui.appendOptions(shokubaTarget, "cd_shokuba", "nm_shokuba", shokubaCode, false);
                // 当日日付を挿入
                var dt_searchFrom = $('#dt_hiduke_from'),
                    dt_searchTo = $('#dt_hiduke_to');
                dt_searchFrom.datepicker("setDate", new Date()).on("keyup", App.data.addSlashForDateString);
                dt_searchTo.datepicker("setDate",
                    new Date(((new Date()).setMonth((new Date()).getMonth() + 1)))
                ).on("keyup", App.data.addSlashForDateString);
                // 選択の限度を設定
                setDatepickerRange(dt_searchFrom);
                setDatepickerRange(dt_searchTo);
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
            var queryWeb = function () {
                var criteria = $(".search-criteria").toJSON();
                var query = {
                    // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                    url: "../api/GekkanShikakarihinKeikaku",
                    // TODO: ここまで
                    // TODO: 画面の仕様に応じて以下の検索条件を変更してください。
                    cd_shokuba: criteria.shokubaCode,
                    dt_hiduke_from: App.data.getDateTimeStringForQueryNoUtc(criteria.dt_hiduke_search_from),
                    dt_hiduke_to: App.data.getDateTimeStringForQueryNoUtc(criteria.dt_hiduke_search_to),
                    cd_hinmei_search: criteria.cd_hinmei_search,
                    no_lot_search: criteria.no_lot_search,
                    select_lot_search: criteria.lotRadio,
                    // TODO: ここまで
                    skip: querySetting.skip,
                    top: querySetting.top

                }
                return query;
            };

            /// <summary>データ検索を行います。</summary>
            /// <param name="query">クエリオブジェクト</param>
            var searchItems = function (queryWeb) {
                if (isDataLoading === true) {
                    return;
                }
                isDataLoading = true;
                // ローディングの表示
                $("#list-loading-message").text(
                    pageLangText.nowLoading.text
                //App.str.format(
                //    pageLangText.nowListLoading.text,
                //    querySetting.skip + 1,
                //    querySetting.top
                //)
                );
                // スクロール位置保持
                nextScrollTop = $(".ui-jqgrid-bdiv").scrollTop(); //・+ 30;
                App.ajax.webget(
                // WCF Data ServicesのODataシステムクエリオプションを生成
                   App.data.toWebAPIFormat(queryWeb)
                ).done(function (result) {
                    // データバインド
                    if (parseInt(result.__count) === 0) {
                        App.ui.page.notifyAlert.message(MS0037).show();
                    }
                    else {
                        // データバインド
                        bindData(result);
                        // 検索条件を閉じる
                        closeCriteria();
                        // 選択行を先頭にする
                        grid.editCell(1, firstCol, false);
                    }
                    $(".ui-jqgrid-hdiv").scrollLeft(0); // 明細のスクロール位置をリセット

                    // 検索フラグを立てる
                    isSearch = true;
                    isCriteriaChange = false;
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

                //日付内容チェックを行います
                if (checkDateSearch() == false) {
                    App.ui.loading.close();
                    return;
                }

                searchItems(new queryWeb());
            };
            $(".find-button").on("click", showSearchConfirmDialog); //showSearchConfirmDialog

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
                querySetting.skip = querySetting.skip + result.d.length;
                querySetting.count = parseInt(result.__count);
                // グリッドの表示件数を更新
                grid.setGridParam({ rowNum: querySetting.skip });
                displayCount(querySetting.count, querySetting.count);
                // データバインド
                var currentData = grid.getGridParam("data").concat(result.d);
                grid.setGridParam({ data: currentData }).trigger('reloadGrid', [{ current: true}]);
                if (querySetting.count <= 0) {
                    App.ui.page.notifyAlert.message(pageLangText.notFound.text).show();
                }
                else if (querySetting.count > querySetting.top) {
                    App.ui.page.notifyInfo.message(
                    App.str.format(MS0568, querySetting.count, querySetting.top)).show();
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
                    // データ検索
                    searchItems(new queryWeb());
                }
            };
            /// <summary>グリッドスクロール時のイベント処理を行います。</summary>
            $(".ui-jqgrid-bdiv").scroll(function (e) {
                // 後続データ検索
                //nextSearchItems(this);
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
            }
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
            // 日付確認ダイアログ情報メッセージの設定
            var dateInputConfirmDialogNotifyInfo = App.ui.notify.info(dateInputConfirmDialog, {
                container: ".dateinput-confirm-dialog .dialog-slideup-area .info-message",
                messageContainerQuery: "ul",
                show: function () {
                    dateInputConfirmDialog.find(".info-message").show();
                },
                clear: function () {
                    dateInputConfirmDialog.find(".info-message").hide();
                }
            });
            // ロット削除確認ダイアログ情報メッセージの設定
            var lotDeleteConfirmDialogNotifyInfo = App.ui.notify.info(lotDeleteConfirmDialog, {
                container: ".lotdelete-confirm-dialog .dialog-slideup-area .info-message",
                messageContainerQuery: "ul",
                show: function () {
                    lotDeleteConfirmDialog.find(".info-message").show();
                },
                clear: function () {
                    lotDeleteConfirmDialog.find(".info-message").hide();
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

            // 仕込計画確定確認ダイアログ情報メッセージの設定
            var kakuteiConfirmDialogUpdNotifyInfo = App.ui.notify.info(kakuteiConfirmDialogUpd, {
                container: ".kakutei-confirm-dialog-upd .dialog-slideup-area .info-message",
                messageContainerQuery: "ul",
                show: function () {
                    kakuteiConfirmDialogUpd.find(".info-message").show();
                },
                clear: function () {
                    kakuteiConfirmDialogUpd.find(".info-message").hide();
                }
            });

            // 仕込計画確定確認ダイアログ情報メッセージの設定
            var kakuteiConfirmDialogDelNotifyInfo = App.ui.notify.info(kakuteiConfirmDialogDel, {
                container: ".kakutei-confirm-dialog-del .dialog-slideup-area .info-message",
                messageContainerQuery: "ul",
                show: function () {
                    kakuteiConfirmDialogDel.find(".info-message").show();
                },
                clear: function () {
                    kakuteiConfirmDialogDel.find(".info-message").hide();
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
            var dateInputConfirmDialogNotifyAlert = App.ui.notify.alert(dateInputConfirmDialog, {
                container: ".dateinput-confirm-dialog .dialog-slideup-area .alert-message",
                messageContainerQuery: "ul",
                show: function () {
                    dateInputConfirmDialog.find(".alert-message").show();
                },
                clear: function () {
                    dateInputConfirmDialog.find(".alert-message").hide();
                }
            });
            var lotDeleteConfirmDialogNotifyAlert = App.ui.notify.alert(lotDeleteConfirmDialog, {
                container: ".lotdelete-confirm-dialog .dialog-slideup-area .alert-message",
                messageContainerQuery: "ul",
                show: function () {
                    lotDeleteConfirmDialog.find(".alert-message").show();
                },
                clear: function () {
                    lotDeleteConfirmDialog.find(".alert-message").hide();
                }
            });
            //// メッセージ表示 -- End

            //// データ変更処理 -- Start

            // グリッドコントロール固有のデータ変更処理

            /// <summary>グリッドの選択行の行製造ロットNoを取得します。 </summary>
            var getSelectedRowLotNo = function () {
                var id = grid.getGridParam("selrow");
                var lotNo = grid.getCell(id, "no_lot_seihin");

                // Lotがない場合は処理を抜ける
                if (!lotNo == "") {
                    App.ui.page.notifyInfo.message(pageLangText.notSeihinLotDelCheck.text).show();
                    return false;
                }
                return true;
            };

            /// <summary>グリッドの選択行の親仕掛品ロットNoを取得します。 </summary>
            var getSelectedRowOyaLotNo = function () {
                var id = grid.getGridParam("selrow");
                var lotNo = grid.getCell(id, "no_lot_shikakari_oya");

                // Lotがない場合は処理を抜ける
                if (!lotNo == "") {
                    App.ui.page.notifyInfo.message(
                        App.str.format(MS0452, pageLangText.rd_lotOya.text)
                    ).show();
                    return false;
                }
                return true;
            };

            /// <summary>グリッドの選択行の仕込実績フラグを取得します。</summary>
            var getSelectedRowShikomiJisseki = function () {
                var id = grid.getGridParam("selrow");

                // 仕込実績がある場合はメッセージを表示する。
                if (grid.getCell(id, "flg_shikakari_jisseki") == 1) {
                    App.ui.page.notifyInfo.message(
                         App.str.format(pageLangText.jissekiCheck.text, pageLangText.shikakariJisseki.text, pageLangText.del.text)
                    ).show();
                    return false;
                }
                return true;
            };

            /// <summary>グリッドの選択行の仕込計画確定フラグを取得します。</summary>
            var getSelectedRowShikomiKakutei = function () {
                var id = grid.getGridParam("selrow");

                // 仕込計画が確定しているか、ラベル発行済みの場合
                if (checkJissekiData(id)) {

                    return false;
                }
                return true;
            };

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

            /// <summary>選択行が編集不可であるかどうか</summary>
            /// <param name="rowid">選択行のID</param>
            /// <param name="flgMsg">infoメッセージを表示するかどうか</param>
            /// <returns>不可(editable)の場合はtrue、可能の場合はtrue</returns>
            var checkSelectRowEdit = function (rowid, flgMsg) {
                var index = grid.jqGrid("getInd", rowid, true);
                var noteditable = $('td[role="gridcell"]', (index)).hasClass("not-editable-cell");
                if (noteditable && flgMsg) {
                    App.ui.page.notifyInfo.message(MS0708).show();
                }
                return noteditable;
            };

            /// <summary>新規行データの設定を行います。</summary>
            var setAddData = function (row) {
                // TODO: 画面の仕様に応じて以下の項目を変更してください。
                var addData = {
                    "dt_hitsuyo_tukihi": row.dt_hitsuyo_hidden,
                    "dt_hitsuyo_yobi": row.dt_hitsuyo_hidden,
                    "cd_hinmei": "",
                    //"hinmeiName": "",
                    //"su_seizo_yotei": 0,
                    //"su_seizo_jisseki": 0,
                    "wt_hitsuyo": 0,
                    "wt_shikomi_keikaku": 0,
                    "flg_kyujitsu": row.flg_kyujitsu,
                    "cd_shokuba": row.cd_shokuba,
                    "cd_line": row.cd_line,
                    "dt_hitsuyo_hidden": row.dt_hitsuyo_hidden,
                    //"flg_gassan_shikomi": 0,
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
                    "wt_hitsuyo": newRow.wt_hitsuyo,
                    "wt_shikomi_keikaku": newRow.wt_shikomi_keikaku,
                    "cd_shokuba": newRow.cd_shokuba,
                    "data_key": newRow.data_key,
                    "flg_kyujitsu": newRow.flg_kyujitsu,
                    "no_lot_seihin": newRow.no_lot_seihin,
                    "cd_hinmei": newRow.cd_hinmei,
                    "cd_shokuba": newRow.cd_shokuba,
                    "cd_line": newRow.cd_line,
                    "dt_seizo": App.data.getDateTimeStringForQueryNoUtc(App.date.localDate(newRow.dt_seizo)),
                    "no_lot_shikakari": newRow.no_lot_shikakari,
                    "no_lot_shikakari_oya": newRow.no_lot_shikakari_oya,
                    "dt_hitsuyo": newRow.dt_hitsuyo_hidden,
                    "ritsu_kihon": newRow.ritsu_kihon,
                    "wt_haigo_gokei": newRow.wt_haigo_gokei,
                    "flg_gassan_shikomi": newRow.flg_gassan_shikomi,
                    "id": newRow.id
                };
                // TODO: ここまで

                return changeData;
            };
            /// <summary>更新状態の変更セットに追加する変更データの設定を行います。</summary>
            /// <param name="row">選択行</param>
            var setUpdatedChangeData = function (row) {
                // TODO: 画面の仕様に応じて以下の項目を変更してください。
                var changeData = {
                    "wt_hitsuyo": row.wt_hitsuyo,
                    "wt_shikomi_keikaku": row.wt_shikomi_keikaku,
                    "data_key": row.data_key,
                    "no_lot_seihin": row.no_lot_seihin,
                    "cd_hinmei": row.cd_hinmei,
                    "cd_shokuba": row.cd_shokuba,
                    "cd_line": row.cd_line,
                    "dt_seizo": row.dt_seizo_hidden,
                    "no_lot_shikakari": row.no_lot_shikakari,
                    "no_lot_shikakari_oya": row.no_lot_shikakari_oya,
                    "dt_hitsuyo": row.dt_hitsuyo_hidden,
                    "ritsu_kihon": row.ritsu_kihon,
                    "wt_haigo_gokei": row.wt_haigo_gokei,
                    "flg_gassan_shikomi": row.flg_gassan_shikomi
                };
                // TODO: ここまで

                return changeData;
            };
            /// <summary>削除状態の変更セットに追加する変更データの設定を行います。</summary>
            /// <param name="row">選択行</param>
            var setDeletedChangeData = function (row) {
                // TODO: 画面の仕様に応じて以下の項目を変更してください。
                var changeData = {
                    "data_key": row.data_key,
                    "no_lot_seihin": row.no_lot_seihin,
                    "cd_hinmei": row.cd_hinmei,
                    "cd_shokuba": row.cd_shokuba,
                    "cd_line": row.cd_line,
                    "dt_seizo": row.dt_seizo_hidden,
                    "no_lot_shikakari": row.no_lot_shikakari,
                    "no_lot_shikakari_oya": row.no_lot_shikakari_oya,
                    "flg_gassan_shikomi": row.flg_gassan_shikomi
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

            /// <summary>新規行を追加します。</summary>
            /// <param name="e">イベントデータ</param>
            var addData = function (e) {
                // 選択行のID取得
                var selectedRowId = getSelectedRowId(false),
                    position = "after";
                if (App.isUndefOrNull(selectedRowId)) {
                    return;
                }
                // 新規行データの設定
                var newRowId = App.uuid(),
                    addData = setAddData(grid.getRowData(selectedRowId));
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
                grid.editCell(currentRow + 1, currentCol, true);
            };
            /// <summary>追加ボタンクリック時のイベント処理を行います。</summary>
            $(".add-button").on("click", function () {
                var idNum = grid.getGridParam("selrow");
                $("#" + idNum + " td:eq('" + (taniNameCol) + "')").click();
                addData();
            });

            /// 仕掛品チェック
            var isShikakariCheck = function (selrow) {
                // 行データを取得する
                var data = grid.getRowData(selrow),
                    cnt,
                    res;

                App.deferred.parallel({
                    // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                    loading: App.ui.loading.show(pageLangText.nowProgressing.text),
                    // 品名を取得
                    res: App.ajax.webgetSync(App.data.toWebAPIFormat(
                                            { url: "../api/GekkanShikakarihinShiyoLotCheck"
                                                , no_lot_shikakari: data.no_lot_shikakari
                                                , no_lot_shikakari_oya: data.no_lot_shikakari_oya
                                            }))

                    // TODO: ここまで
                }).done(function (result) {
                    // TODO: 画面の仕様に応じて以下のサービス呼び出し成功時の処理を変更してください。
                    res = result.successes.res.d[0].cnt;
                    cnt = res;
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
                return cnt;
            }

            /// <summary>行を削除します。</summary>
            /// <param name="e">イベントデータ</param>
            var deleteData = function (e) {
                // ダイアログ消去
                closeLotDeleteConfirmDialog();
                // 選択行のID取得
                var selectedRowId = getSelectedRowId(false);
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
                    // セルを選択して入力モードにする
                    grid.editCell(currentRow === 1 ? currentRow : currentRow - 1, currentCol, true);
                }
            };

            /// <summary>行を削除します。</summary>
            /// <param name="e">イベントデータ</param>
            var deleteDataCheck = function (e) {
                // 削除不可フラグ
                var isUnDelete = false;
                // 選択行のID取得
                var selectedRowId = getSelectedRowId(false);
                if (App.isUndefOrNull(selectedRowId)) {
                    return;
                }

                // 製造ロットが登録されている場合はリターン
                var isSelectedRowLotNo = getSelectedRowLotNo();
                if (!isSelectedRowLotNo) {
                    //return;
                    isUnDelete = true;
                }

                // 親仕掛品ロットが登録されている場合はリターン
                var isSelectedRowOyaLotNo = getSelectedRowOyaLotNo();
                if (!isSelectedRowOyaLotNo) {
                    //return;
                    isUnDelete = true;
                }

                // 仕込実績が登録されている場合はリターン
                var isSelectedRowShikomiJisseki = getSelectedRowShikomiJisseki();
                if (!isSelectedRowShikomiJisseki) {
                    //return;
                    isUnDelete = true;
                }

                // 削除不可の場合は処理を抜ける。
                if (isUnDelete) {
                    return;
                }

                // 仕込計画が確定している場合はダイアログを表示し、リターン
                var isSelectedRowShikomiKakutei = getSelectedRowShikomiKakutei();
                if (!isSelectedRowShikomiKakutei) {
                    // 計画確定確認ダイアログを表示
                    showKakuteiConfirmDialogDel();
                    //return;
                    isUnDelete = true;
                }

                // 削除不可でない場合は削除処理を実行する。
                if (!isUnDelete) {

                    // 削除前チェック処理を実行する。
                    preDeleteCheck();
                }

            };


            /// <summary> 他仕掛品利用チェック処理 </summary>
            var preDeleteCheck = function () {

                // 選択行のID取得
                var selectedRowId = getSelectedRowId(false);

                if (App.isUndefOrNull(selectedRowId)) {
                    return;
                }

                // 削除対象行が、ほかの仕掛品で利用されているかチェック
                var cnt = isShikakariCheck(selectedRowId);
                if (!App.isUndefOrNull(cnt)) {
                    if (cnt > 0) {
                        // 確認
                        showLotDeleteConfirmDialog();
                        return;
                    }
                    deleteData();
                }
            };

            /// <summary>削除ボタンクリック時のイベント処理を行います。</summary>
            $(".delete-button").on("click", deleteDataCheck);

            /// <summary>明細/仕掛品の品名ダイアログを開くときのチェック処理</summary>
            var checkSeihinDialog = function (rowid) {
                ///// チェック処理
                if (App.isUndefOrNull(rowid)) {
                    // 選択行がない場合は処理を抜ける
                    return;
                }

                //                // 編集可能行であるかどうか
                //                var noteditable = checkSelectRowEdit(rowid, true);
                //                if (noteditable) {
                //                    return;
                //                }

                // 仕込日に入力があるかどうか
                var seizoDate = grid.getCell(getSelectedRowId(false), "dt_seizo");
                var res = validateCell(rowid, "dt_seizo", seizoDate, seizoDateCol);
                if (!res) {
                    return;
                }
                // 過去日付の入力チェック
                if (!isEditOldDateInfo(rowid, "seihin")) {
                    return;
                }

                // 行選択
                $("#" + rowid).removeClass("ui-state-highlight").find("td").click();

                // ダイアログを開く
                showSeihinDialog();
            };
            /// <summary>明細/仕掛品の品名ダイアログを開きます。</summary>
            var showSeihinDialog = function () {
                var selectedRowId = getSelectedRowId();
                if (App.isUndefOrNull(selectedRowId)) {
                    return;
                }
                saveEdit(); // jqGrid保存でバグ対応

                // 製造日を取得
                var seizoDate = grid.jqGrid('getCell', selectedRowId, 'dt_seizo');
                seizoDate = new Date(seizoDate);
                // 検索条件を取得
                var criteria = $(".search-criteria").toJSON();

                //var option = { id: 'seihin', multiselect: false, param1: pageLangText.shikakariHinKbn.text };
                var option = { id: 'seihin', multiselect: false
                    , param1: pageLangText.keikakuShikakariDlgParam.text
                    , param2: App.data.getDateTimeStringForQueryNoUtc(seizoDate)
                    , param4: criteria.shokubaCode
                };

                seihinDialog.draggable(true);
                //seihinDialog.draggable({ containment: document.body, scroll: false });    // Chromeだと正常に動作しないのでコメントアウト
                seihinDialog.dlg("open", option);
            };
            /// <summary>明細/仕掛品検索ボタンクリック時のイベント処理を行います。</summary>
            $(".seihin-button").on("click", function (e) {
                var selectedRowId = getSelectedRowId();
                checkSeihinDialog(selectedRowId);
            });

            /// <summary>検索条件/仕掛品の品名ダイアログを開きます。</summary>
            var showSeihinSearchDialog = function () {
                saveEdit(); // jqGrid保存でバグ対応
                var option = { id: 'seihinSerch', multiselect: false, param1: pageLangText.shikakariHinKbn.text };
                seihinSearchDialog.draggable(true);
                seihinSearchDialog.dlg("open", option);
            };
            /// <summary>検索条件/コード検索ボタンクリック時のイベント処理を行います。</summary>
            $("#btn_hinmei_search").on("click", function (e) {
                // dialog起動
                showSeihinSearchDialog();
            });
            /// 検索条件/仕掛品コードダブルクリック時のイベント処理を行います。
            $("#cd_hinmei_search").dblclick(function () {
                // 品名ダイアログを開く
                showSeihinSearchDialog();
            });

            /// <summary>検索条件表示用コード名の検索を行います。</summary>
            var setHinmei = function () {
                var code = $("#cd_hinmei_search").val();

                // 空白の場合は名称も空白でリターン
                if (code === "" || App.isUndefOrNull(code)) {
                    $("#nm_hinmei_search_label").text("");
                    return;
                }

                var serviceUrl = "../Services/FoodProcsService.svc/ma_haigo_mei()?$filter=cd_haigo eq '" + code
                    + "' and no_han eq " + pageLangText.hanNoShokichi.text
                    + " and flg_mishiyo eq " + pageLangText.falseFlg.text + "&$top=1",
                    elementCode = "cd_haigo",
                    elementName = haigoName,
                    codeName;

                App.deferred.parallel({
                    // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                    codeName: App.ajax.webgetSync(serviceUrl)
                    // TODO: ここまで
                }).done(function (result) {
                    // TODO: 画面の仕様に応じて以下のサービス呼び出し成功時の処理を変更してください。
                    codeName = result.successes.codeName.d;
                    if (codeName.length > 0) {
                        $("#nm_hinmei_search_label").text(codeName[0][elementName]);
                    }
                    else {
                        $("#nm_hinmei_search_label").text("");
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

            /// <summary>検索条件 品名コード入力時のイベント処理を行います。</summary>
            $("#cd_hinmei_search").on("change", function (e) {
                App.ui.page.notifyAlert.clear();
                setHinmei();
            });

            /// <summary>ライン一覧ダイアログを開くときのチェック処理</summary>
            var checkLineDialog = function (rowid) {
                if (App.isUndefOrNull(rowid)) {
                    return;
                }

                // 編集可能行であるかどうか
                //var noteditable = checkSelectRowEdit(rowid, true);
                var noteditable = checkSelectRowEdit(rowid, false);
                if (noteditable) {
                    return;
                }

                // 仕掛品コードが存在すること
                var selHinCode = grid.getCell(getSelectedRowId(false), "cd_hinmei");
                if (App.isUndefOrNull(selHinCode) || selHinCode == "") {
                    validateCell(rowid, "cd_hinmei", selHinCode, hinCodeCol);
                    return;
                }

                // ダイアログを開く
                showLineDialog(selHinCode);
            };
            /// <summary>ライン一覧ダイアログを開きます</summary>
            /// <param name="selHinCode">選択行の品名コード</param>
            var showLineDialog = function (selHinCode) {
                // 行選択
                var idNum = grid.getGridParam("selrow");
                $("#" + idNum).removeClass("ui-state-highlight").find("td").click();

                var option = { id: 'seizoLine', multiselect: false
                    , param1: grid.getCell(getSelectedRowId(false), "cd_shokuba")
                    , param2: selHinCode
                    , param3: pageLangText.haigoMasterSeizoLineMasterKbn.text
                };
                lineDialog.draggable(true);
                lineDialog.dlg("open", option);
            };
            /// <summary>ライン一覧ボタンクリック時のイベント処理を行います。</summary>
            $(".line-button").on("click", function (e) {
                var selectedRowId = getSelectedRowId();
                checkLineDialog(selectedRowId);
            });
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
                var saveUrl = "../api/GekkanShikakarihinKeikaku";
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
            /// <summary>保存前チェック</summary>
            var checkSave = function () {
                // 情報メッセージのクリア
                App.ui.page.notifyInfo.clear();
                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();

                // チェック処理
                // 対象行が存在するか確認
                //var selectedRowId = getSelectedRowId(),
                ///    position = "after";
                //if (App.isUndefOrNull(selectedRowId)) {
                //    App.ui.loading.close();
                //    return;
                //}
                // 変更セット内にバリデーションエラーがある場合は処理を抜ける
                if (!validateChangeSet()) {
                    App.ui.loading.close();
                    return;
                }
                // 変更がない場合は処理を抜ける
                if (noChange()) {
                    App.ui.page.notifyInfo.message(pageLangText.noChange.text).show();
                    App.ui.loading.close();
                    return;
                }
                // 仕込日 > 必要日の場合はエラーとする
                // created
                if (!checkShikomiDate(changeSet.changeSet.created)) {
                    App.ui.loading.close();
                    return;
                }
                // updated
                if (!checkShikomiDate(changeSet.changeSet.updated)) {
                    App.ui.loading.close();
                    return;
                }
                else {
                    // チェックがすべて終わってからローディング表示を終了させる
                    App.ui.loading.close();
                }

                // 保存確認ダイアログを開く
                //showSaveConfirmDialog();
                saveData();
            };
            /// <summary>保存ボタンクリック時のイベント処理を行います。</summary>
            //$(".save-button").on("click", showSaveConfirmDialog);
            $(".save-button").on("click", function () {
                // 編集内容の保存
                saveEdit();

                // ローディング表示
                App.ui.loading.show(pageLangText.nowProgressing.text);

                // チェック処理が始まるとローディング画像が表示されない為、setTimeoutで間を入れる
                setTimeout(function () {
                    checkSave();    // 保存前チェックの実行
                }, 100);
            });

            //// 保存処理 -- End

            //// バリデーション -- Start

            // グリッドコントロール固有のバリデーション

            // TODO: 画面の仕様に応じて以下のカスタムバリデーション定義を変更してください。
            // バリデーション設定
            // 品コードに付随する設定が正しいかどうか
            /// 操作時の日付判定
            var isEditOldDateInfo = function (selRow, dlg) {
                var date = grid.getCell(selRow, "dt_hitsuyo_hidden");
                date = $.datepicker.formatDate(pageLangText.dateFormat.text, App.data.getDate(date))
                if (isOlderDate(date)) {
                    // 過去日付なら確認
                    showDateInputConfirmDialog(selRow, dlg);
                    return false;
                }
                return true;
            };

            /// 日付比較
            /// <param name="date">比較日付</param>
            /// <return>結果(frue/false)
            var isOlderDate = function (date) {
                var today = $.datepicker.formatDate(pageLangText.dateFormat.text, new Date());
                return date < today;
            };

            /// <summary>仕込日と必要日の比較チェック</summary>
            /// 仕込日 > 必要日の場合はエラーとする
            var checkShikomiDate = function (changeSetData) {
                var isValid = true;

                for (var validRow in changeSetData) {
                    var dtShikomi = App.date.localDate(grid.getCell(validRow, "dt_seizo"));
                    var dtHitsuyo = App.data.getDate(grid.getCell(validRow, "dt_hitsuyo_hidden"));
                    dtHitsuyo = App.date.localDate(dtHitsuyo);
                    //var dtHitsuyo = grid.jqGrid('getCell', validRow, 'dt_seizo_hidden');
                    if (dtShikomi.getTime() > dtHitsuyo.getTime()) {
                        var unique = validRow + "_" + seizoDateCol;
                        grid.setCell(validRow, seizoDateCol, "", { background: '#ff6666' });
                        App.ui.page.notifyAlert.message(MS0112, unique).show();
                        isValid = false;
                        break;
                    }
                }
                return isValid;
            };

            //品コード
            //validationSetting.cd_hinmei.rules.custom = function (value) {
            //    return true;
            //};

            //品コード(検索)
            validationSetting.cd_hinmei_search.rules.custom = function (value) {
                //var code = $(".search-criteria [name='cd_hinmei_search']").val(),
                var code = $("#cd_hinmei_search").val(),
                    label = $("#nm_hinmei_search_label").text();

                // 入力があった場合、ラベルがセットされているかをチェック
                if (App.isUndefOrNull(code) || code === "") {
                    return true;
                }

                if (App.isUndefOrNull(label) || label === "") {
                    return false;
                }

                return true;
            };

            // コードが有効かどうか
            var isYuko = function (v) {
                if (v == "false") {
                    return false;
                }
                return true;
            };

            //有効フラグ
            //validationSetting.isYukoHaigoCode.rules.custom = function (value) {
            //    return isYuko(value);
            //};

            /*
            // 仕込量が適切かどうか
            var isValidRange = function (obj, value) {
            if (value == "") {
            return true;
            }
            //カンマがあったら削除
            value = value.toString();
            value = value.replace(/,/g, "");
            if (!App.isNum(value)) {
            if (App.isNumeric(value)) {
            value = parseFloat(value);
            }
            else {
            return false;
            }
            }
            // メッセージにパラメータセット
            obj.messages.custom
            = App.str.format(obj.messages.custom, obj.params.custom[0], obj.params.custom[1], obj.params.custom[2]);
            return value >= obj.params.custom[1] && value <= obj.params.custom[2];
            };
            //仕込量
            validationSetting.wt_shikomi_keikaku.rules.custom = function (value) {
            return isValidRange(validationSetting.wt_shikomi_keikaku, value);
            };
            */

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
                // 有効版の判定用
                var isSelYukoVal = "";

                // 有効版コード判定時には、最終的にフォーカスを充てるセルを変える
                var unique = iCol != isYukoCol ? selectedRowId + "_" + iCol : selectedRowId + "_" + hinCodeCol,
                    val = {},
                    result;

                // エラーメッセージの解除
                App.ui.page.notifyAlert.remove(unique);

                // 有効版の判定時に、リターン値を入力した値に戻す
                if (iCol == isYukoCol) {
                    isSelYukoVal = value; // 退避
                    value = grid.getCell(selectedRowId, "cd_hinmei");
                }

                grid.setCell(selectedRowId, iCol, value, { background: 'none' });

                if (iCol == isYukoCol) {
                    val[cellName] = isSelYukoVal;
                    iCol = hinCodeCol;
                }
                else {
                    // 通常
                    val[cellName] = value;
                }

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

            /// <summary>仕込計画確定確認ダイアログ(更新用)の「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".kakutei-confirm-dialog-upd .dlg-yes-button").on("click", closeKakuteiConfirmDialogUpd);

            // <summary>仕込計画確定確認ダイアログ(更新用)の「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".kakutei-confirm-dialog-upd .dlg-no-button").on("click", reSelectRow);

            /// <summary>仕込計画確定確認ダイアログ(削除用)の「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".kakutei-confirm-dialog-del .dlg-yes-button").on("click", closeKakuteiConfirmDialogDel);

            // <summary>仕込計画確定確認ダイアログ(削除用)の「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".kakutei-confirm-dialog-del .dlg-no-button").on("click", reSelectRow);

            /// <summary>日付入力確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".dateinput-confirm-dialog .dlg-yes-button").on("click", function () {
                if (!App.isUndefOrNull(selDateOption)) {
                    switch (selDateOption) {
                        case "seizodate":
                            closeDateInputConfirmDialog();
                            break;
                        case "seihin":
                            clearInputOldDate();
                            break;
                    }
                }
            });

            // <summary>日付入力確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".dateinput-confirm-dialog .dlg-no-button").on("click", function () {
                if (!App.isUndefOrNull(selDateOption)) {
                    switch (selDateOption) {
                        case "seizodate":
                            clearInputOldDate();
                            break;
                        case "seihin":
                            closeDateInputConfirmDialog();
                            break;
                    }
                }
            });

            /// <summary>検索確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".lotdelete-confirm-dialog .dlg-yes-button").on("click", deleteData);

            // <summary>検索確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".lotdelete-confirm-dialog .dlg-no-button").on("click", closeLotDeleteConfirmDialog);


            /// 月の初日を取得
            var getFromFirstDateStringForQuery = function (date) {
                var result = new Date(date.getFullYear(), date.getMonth(), 1, 00, 00, 00);

                return App.data.getDateTimeStringForQueryNoUtc(result, false);
            }

            /// 月の末日を取得
            var getFromLastDateStringForQuery = function (date) {
                var result = new Date(date.getFullYear(), date.getMonth() + 1, 0, 23, 59, 59);
                return App.data.getDateTimeStringForQueryNoUtc(result, false);
            }

            /// 当日を取得
            var getTodayDateStringForQuery = function (date) {
                var result = new Date(date.getFullYear(), date.getMonth(), date.getDate(), 00, 00, 00);

                return App.data.getDateTimeStringForQueryNoUtc(result, false);
            }

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

            /// <summary>Excelファイル出力を行います。</summary>
            var printExcel = function (e) {
                var criteria = $(".search-criteria").toJSON();
                var query = {
                    // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                    url: "../api/GekkanShikakarihinKeikakuExcel",
                    // TODO: ここまで
                    cd_shokuba: criteria.shokubaCode,
                    dt_hiduke_from: App.data.getDateTimeStringForQueryNoUtc(criteria.dt_hiduke_search_from),
                    dt_hiduke_to: App.data.getDateTimeStringForQueryNoUtc(criteria.dt_hiduke_search_to),
                    nm_shokuba: encodeURIComponent($(".search-criteria [name='shokubaCode'] option:selected").text()),
                    cd_hinmei_search: criteria.cd_hinmei_search,
                    cd_hinmei: encodeURIComponent($("#nm_hinmei_search_label").text()),
                    no_lot_search: criteria.no_lot_search,
                    select_lot_search: criteria.lotRadio,
                    // 固定文言
                    strSeihin: pageLangText.rd_lotSeihin.text,
                    strOyaShikakari: pageLangText.rd_lotOya.text,
                    strShikakari: pageLangText.rd_lotShikakari.text,
                    // TODO: ここまで
                    skip: querySetting.skip,
                    top: querySetting.top
                };
                // 処理中を表示する
                App.ui.loading.show(pageLangText.nowProgressing.text);

                // 必要な情報を渡します
                var url = App.data.toWebAPIFormat(query);
                url = url + "&lang=" + App.ui.page.lang
                          + "&today=" + App.data.getDateTimeStringForQuery(new Date(), true)
                          + "&userName=" + encodeURIComponent(App.ui.page.user.Name);

                window.open(url, '_parent');
                // Cookieを監視する
                onComplete();
            };

            /// <summary>ダウンロードボタンクリック時のチェック処理</summary>
            var prePrintExcel = function () {
                App.ui.page.notifyAlert.clear();
                // 検索前バリデーション
                var result = $(".part-body .item-list").validation().validate();
                if (result.errors.length) {
                    return;
                }
                // 明細の変更をチェック
                if (!noChange()) {
                    App.ui.page.notifyAlert.message(pageLangText.unprintableCheck.text
                    ).show();
                    return;
                }
                printExcel();
            };
            /// <summary>Excelボタンクリック時のイベント処理を行います。</summary>
            $(".excel-button").on("click", prePrintExcel);

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
        });

        // Cookieを1秒ごとにチェックする
        var onComplete = function () {
            if (app_util.prototype.getCookieValue(pageLangText.gekkanShikakarihinKeikakuCookie.text) == pageLangText.checkCookie.text) {
                app_util.prototype.deleteCookie(pageLangText.gekkanShikakarihinKeikakuCookie.text);
                //ローディング終了
                App.ui.loading.close();
            }
            else {
                // 再起してCookieが作成されたか監視
                setTimeout(onComplete, 1000);
            }
        };

        /// <summary>検索時のチェック処理を行います。</summary>
        var checkDateSearch = function () {
            var criteria = $(".search-criteria").toJSON();

            // 検索条件/日付チェック
            var dateFrom = new Date(Date.parse(criteria.dt_hiduke_search_from));
            var dateFromFullYear = dateFrom.getFullYear() +
                                        ("0" + (dateFrom.getMonth() + 1)).slice(-2) +
                                        ("0" + (dateFrom.getDate())).slice(-2);
            var dateTo = new Date(Date.parse(criteria.dt_hiduke_search_to));
            var dateToFullYear = dateTo.getFullYear() +
                                        ("0" + (dateTo.getMonth() + 1)).slice(-2) +
                                        ("0" + (dateTo.getDate())).slice(-2);

            // 日付(開始)が日付(終了)より日付が過去の場合
            if (dateFromFullYear > dateToFullYear) {
                // エラーを表示して処理終了
                App.ui.page.notifyAlert.message(App.str.format(pageLangText.inputDateError.text, pageLangText.dt_hiduke_start.text, pageLangText.dt_hiduke_end.text), $("#dt_hiduke_from")).show();
                return false;
            }
            return true;
        };
    </script>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <!-- 画面デザイン -- Start -->

    <!-- 検索条件と検索ボタン -->
    <div class="content-part search-criteria">
        <h3 class="part-header" data-app-text="searchCriteria"><a class="search-part-toggle" href="#"></a></h3>
        <div class="part-body">
            <ul class="item-list item-command item-list-left">
                <!-- TODO: 画面の仕様に応じて以下の検索条件を変更してください。-->
                <li>
                    <label>
                        <span class="item-label" data-app-text="dt_hiduke_search"></span>
                        <input type="text" id="dt_hiduke_from" name="dt_hiduke_search_from"  class="date-input-box" maxlength="10" />
                    </label>
                    <label>
                        <span data-app-text="namisen"></span>
                    </label>
                    <label>
                        <input type="text" id="dt_hiduke_to" name="dt_hiduke_search_to"  class="date-input-box" maxlength="10" />
                    </label>
                <br/>
                    <!-- 仕掛品 -->
                    <label>
                        <span class="item-label" data-app-text="cd_hinmei_search" data-tooltip-text="cd_hinmei_search"></span>
                        <input class="no_lot_search" type="text" name="cd_hinmei_search" id="cd_hinmei_search" />
                        <button type="button" class="dialog-button" id="btn_hinmei_search">
                            <span class="icon"></span><span data-app-text="codeSearch"></span>
                        </button>
                    </label>
                <br/>
                    <label>
                        <span class="item-label" data-app-text="nm_hinmei_search" data-tooltip-text="nm_hinmei_search"></span>
                        <span class="nm_hinmei_search_label" id="nm_hinmei_search_label"></span>
                    </label>
                </li>
                <!-- TODO: ここまで -->
            </ul>
            <ul class="item-list item-list-right">
                <li>
                    <label>
                        <span class="item-label" data-app-text="nm_shokuba_search" data-tooltip-text="nm_shokuba_search"></span>
                        <select name="shokubaCode">
                        </select>
                    </label>
                <br/>
                    <label>
                        <span class="item-label" data-app-text="no_lot_search"></span>
                    </label>
                    <label>
                        <input type="radio" name="lotRadio" id="lotNashi" value="0" checked="checked" />
                        <span class="item-label-radio" data-app-text="rd_lotNashi"></span>
                    </label>
                    <label>
                        <input type="radio" name="lotRadio" id="lotSeihin" value="1" />
                        <span class="item-label-radio" data-app-text="rd_lotSeihin"></span>
                    </label>
                    <label>
                        <input type="radio" name="lotRadio" id="lotOya" value="2" />
                        <span class="item-label-radio" data-app-text="rd_lotOya" data-tooltip-text="rd_lotOya"></span>
                    </label>
                    <label>
                        <input type="radio" name="lotRadio" id="lotShikakari" value="3" />
                        <span class="item-label-radio" data-app-text="rd_lotShikakari" data-tooltip-text="rd_lotShikakari"></span>
                    </label>
                    <label>&nbsp;</label>
                    <label>
                        <input class="no_lot_search" type="text" name="no_lot_search" id="no_lot_search" />
                    </label>
                </li>
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
                <button type="button" class="add-button" name="add-button" data-app-operation="addButton"><span class="icon"></span><span data-app-text="add"></span></button>
                <button type="button" class="delete-button" name="delete-button" data-app-operation="deleteButton"><span class="icon"></span><span data-app-text="del"></span></button>
                <button type="button" class="seihin-button" name="seihin-button" data-app-operation="seihinIchiran"><span class="icon"></span><span data-app-text="seihinIchiran"></span></button>
                <button type="button" class="line-button" name="line-button" data-app-operation="lineIchiran"><span class="icon"></span><span data-app-text="lineIchiran"></span></button>
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
    <div class="save-confirm-dialog" style="display:none">
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
    <div class="search-confirm-dialog" style="display:none">
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
    <div class="lotdelete-confirm-dialog" style="display:none">
        <div class="dialog-header">
            <h4 data-app-text="confirmTitle"></h4>
        </div>
        <div class="dialog-body" style="padding: 10px; width: 100%;">
            <div class="part-body">
                <span data-app-text="lotDeleteConfirm"></span>
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
    <div class="dateinput-confirm-dialog" style="display:none">
        <div class="dialog-header">
            <h4 data-app-text="confirmTitle"></h4>
        </div>
        <div class="dialog-body" style="padding: 10px; width: 100%;">
            <div class="part-body">
                <span data-app-text="dateInputConfirm"></span>
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
    <!-- 計画確定確認ダイアログ(更新用) -->
    <div class="kakutei-confirm-dialog-upd" style="display:none">
        <div class="dialog-header">
            <h4 data-app-text="confirmTitle"></h4>
        </div>
        <div class="dialog-body" style="padding: 10px; width: 100%;">
            <div class="part-body">
                <span data-app-text="shikomiUpdateCheck"></span>
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
        <!-- 計画確定確認ダイアログ(削除用) -->
    <div class="kakutei-confirm-dialog-del" style="display:none">
        <div class="dialog-header">
            <h4 data-app-text="confirmTitle"></h4>
        </div>
        <div class="dialog-body" style="padding: 10px; width: 100%;">
            <div class="part-body">
                <span data-app-text="shikomiDeleteCheck"></span>
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
    <div class="seihin-dialog">
	</div>
    <div class="seihin-search-dialog">
	</div>
    <div class="line-dialog">
	</div>
    <!-- TODO: ここまで  -->

    <!-- 画面デザイン -- End -->
</asp:Content>
