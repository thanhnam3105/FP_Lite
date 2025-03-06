<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="ShikakarihinShikomiKeikaku.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.ShikakarihinShikomiKeikaku" %>
<asp:Content ID="Content1" ContentPlaceHolderID="IncludeContent" runat="server">
    <script src="<%=ResolveUrl("~/Resources/pages/pagedata-shikakarihinshikomikeikaku." + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
    <script src="<%=ResolveUrl("~/Resources/grid/grid.locale-" + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
    <link href="../Styles/print.css" rel="stylesheet" type="text/css" />
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
            width: 40%;
        }
        
        .part-body .item-list-right li
        {
            margin-left: 400px;
        }
        
        .search-criteria select
        {
            width: 20em;
        }
        
        .line-dialog
		{
			background-color: White;
			width: 550px;
		}
		
		.kobetsu-label-dialog
		{
			background-color: White;
		    width: 90%;
		}
		
		.insatsu-sentaku-dialog
        {
            background-color: White;
            width: 405px;
        }
        
        button.insatsu-sentaku-button .icon
        {
            background-position: -48px -80px;
        }
		
		button.line-button .icon
        {
            background-position: -48px -80px;
        }
        
        .chomieki-label-dialog
        {
            background-color: White;
            /* width: 405px; */
            width: 600px;
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
            querySetting = { skip: 0, top: 500, count: 0 },
            isDataLoading = false;

            // グリッドコントロール固有の変数宣言
            var grid = $("#item-grid"),
            lastScrollTop = 0,
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            changeSet = new App.ui.page.changeSet(),
            firstCol = 3,
            duplicateCol = 999,
            shikomiFlgCol = 3,
            shikomiRyoCol = 10,
            bairitsuCol = 11,
            bairitsuHasuCol = 12,
            batchCol = 13,
            batchHasuCol = 14,
            lastEditCelCol = 14,
            currentRow = 0,
            lastClickedRowId,
            currentCol = firstCol;
            var checkButtonStatus = pageLangText.falseFlg.text; // 全チェック機能用、チェックボックスのステータス
            // TODO: ここまで

            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            var shokubaCode, // 検索条件のコンボボックス
            lineCode, // 検索条件のコンボボックス
            // 多言語対応にしたい項目を変数にする
            haigoName = 'nm_haigo_' + App.ui.page.lang,
            subgridHaigoName = 'haigoHinName_' + App.ui.page.lang,
            isSearch = false,
            isCriteriaChange = false,
            loading;

            var zeroHaigoFlg = false;
            var labelInsatsuErrRowId = "";
            var orgDataList = [];

            // TODO：ここまで

            // ダイアログ固有の変数宣言
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            var saveConfirmDialog = $(".save-confirm-dialog"),
            // 計画確定確認ダイアログ(更新時)
            kakuteiConfirmDialogUpd = $(".kakutei-confirm-dialog-upd"),
            searchConfirmDialog = $(".search-confirm-dialog"),
            kobetsuLabelDialog = $(".kobetsu-label-dialog"),
            chomiekiLabelDialog = $(".chomieki-label-dialog"),
            insatsuSentakuDialog = $(".insatsu-sentaku-dialog"),
            lineDialog = $(".line-dialog");
            // TODO：ここまで

            //// 変数宣言 -- End

            //// コントロール定義 -- Start

            // ダイアログ固有のコントロール定義
            saveConfirmDialog.dlg();
            searchConfirmDialog.dlg();
            kakuteiConfirmDialogUpd.dlg();

            /// <summary>整合性チェック</summary>
            /// <param name="changeSetData">チェック対象の明細データ</param>
            var checkTantoFlag = function (changeSetData) {
                for (var rowId in changeSetData) {
                    var flgKakutei = grid.getCell(rowId, 'flg_shikomi');
                    if (flgKakutei == pageLangText.trueFlg.text) {
                        // 明細/確定にチェックがついている場合
                        var hinkanTanto = grid.getCell(rowId, "flg_tanto_hinkan");
                        var seizoTanto = grid.getCell(rowId, 'flg_tanto_seizo');
                        if (hinkanTanto != pageLangText.trueFlg.text
                            || seizoTanto != pageLangText.trueFlg.text) {
                            // 配合名マスタの「品管担当フラグ」と「製造担当フラグ」にチェックが入っている(承認である)こと
                            // 両方にチェックがない場合はエラー
                            return rowId;
                        }
                    }
                }
                return "";
            };

            /// <summary>
            ///     <p>再選択処理</p>
            ///     <p>行を再選択し、フォーカスを外します。</p>
            /// </summary>
            var reSelectRow = function () {
                kakuteiConfirmDialogUpd.dlg("close");

                // 対象行を設定する。
                var selectedRowId = getSelectedRowId(false)

                // ダイアログを閉じるときに、対象セルからのフォーカスを外す
                $("#" + selectedRowId + " > td:nth-child(" + firstCol + ")").click();
            };

            /// <summary>計画確定チェック処理</summary>
            var checkKakuteiData = function () {

                var result = false;
                var selectedRowId = getSelectedRowId();
                var a = grid.getCell(selectedRowId, "flg_label_hasu");
                var b = grid.getCell(selectedRowId, "flg_label");

                if (grid.getCell(selectedRowId, "flg_shikomi") == 1
                    || grid.getCell(selectedRowId, "flg_label") != ""
                    || grid.getCell(selectedRowId, "flg_label_hasu") != "") {

                    result = true;
                }

                return result;
            };

            /// <summary>仕込実績チェック処理</summary>
            var checkJissekiData = function () {

                var result = false;
                var selectedRowId = getSelectedRowId();

                if (grid.getCell(selectedRowId, "flg_jisseki") == 1) {

                    result = true;
                }

                return result;
            };

            /// <summary>ダイアログを開きます。</summary>
            var showSaveConfirmDialog = function () {
                // 情報/エラーメッセージのクリア
                App.ui.page.notifyInfo.clear();
                App.ui.page.notifyAlert.clear();

                // 対象行が存在するか確認
                var selectedRowId = getSelectedRowId(),
                    position = "after";
                if (App.isUndefOrNull(selectedRowId)) {
                    App.ui.loading.close();
                    return;
                }
                if (isCriteriaChange) {
                    App.ui.page.notifyAlert.message(
                        App.str.format(pageLangText.criteriaChange.text, pageLangText.searchCriteria.text, pageLangText.save.text)
                    ).show();
                    App.ui.loading.close();
                    return;
                }

                // 変更セットから値変更が無い行を除外する
                removeNoChange();

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

                // 整合性チェック
                var created = checkTantoFlag(changeSet.changeSet.created);
                var updated = checkTantoFlag(changeSet.changeSet.updated);
                var checkNum = (created != "") ? created : updated;
                if (checkNum != "") {
                    var uniqueId = checkNum + "_" + shikomiFlgCol;
                    App.ui.page.notifyAlert.message(App.str.format(MS0131, pageLangText.save.text), uniqueId).show();
                    // 対象セルの背景変更
                    grid.setCell(checkNum, shikomiFlgCol, "", { background: '#ff6666' });
                    App.ui.loading.close();
                    return;
                }

                // 内容チェック
                var ids = grid.jqGrid('getDataIDs');
                var minusFlg = true;
                for (var i = 0; i < ids.length; i++) {
                    var rowId = ids[i];
                    var data = changeSet.changeSet.updated[rowId];
                    // 変更対象行であればチェックする
                    if (!App.isUndefOrNull(data)) {
                        var Shikomi = parseFloat(grid.jqGrid('getCell', rowId, 'wt_shikomi_keikaku'));
                        var Hitsuyo = parseFloat(grid.jqGrid('getCell', rowId, 'wt_hitsuyo'));
                        if (Shikomi < Hitsuyo) {
                            minusFlg = false;
                        }
                    }
                }
                if (zeroHaigoFlg) {
                    App.ui.page.notifyAlert.message(pageLangText.zeroHaigo.text).show();
                    App.ui.loading.close();
                    return;
                }

                saveConfirmDialogNotifyInfo.clear();
                saveConfirmDialogNotifyAlert.clear();
                saveConfirmDialog.draggable(true);
                // 確認メッセージの表示
                if (!minusFlg) {
                    //$('.save-confirm-dialog .saveConfirm').text(App.str.format(pageLangText.checkShikomi.text));
                    $('.save-confirm-dialog .saveConfirm').text(pageLangText.checkShikomi.text);
                    App.ui.loading.close();
                    saveConfirmDialog.dlg("open");
                }
                else {
                    //$('.save-confirm-dialog .saveConfirm').text(App.str.format(pageLangText.saveConfirm.text));
                    //$('.save-confirm-dialog .saveConfirm').text(pageLangText.saveConfirm.text);
                    saveData();
                }
                //App.ui.loading.close();
                //saveConfirmDialog.dlg("open");
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

            /// <summary> 計画確定確認ダイアログ(更新時)を開きます</summary>///
            var showKakuteiConfirmDialogUpd = function () {
                kakuteiConfirmDialogUpdNotifyInfo.clear();
                kakuteiConfirmDialogUpd.draggable(true);
                kakuteiConfirmDialogUpd.dlg("open");
            };

            /// <summary>ダイアログを閉じます。</summary>
            var closeSaveConfirmDialog = function () {
                saveConfirmDialog.dlg("close");
            };
            var closeSearchConfirmDialog = function () {
                searchConfirmDialog.dlg("close");
            };

            /// <summary>計画確定確認ダイアログ(更新時)を閉じます</summary>
            var closeKakuteiConfirmDialogUpd = function () {
                // 計画確定確認ダイアログを閉じる。
                kakuteiConfirmDialogUpd.dlg("close");

            };

            // ラインダイアログの生成
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

                        var changeData = setCreatedChangeData(grid.getRowData(selectedRowId));
                        changeSet.addUpdated(selectedRowId, "cd_line", data.cd_line, changeData);
                    }
                }
            });

            // 印刷選択ダイアログ生成
            insatsuSentakuDialog.dlg({
                url: "Dialog/InsatsuSentakuDialog.aspx",
                name: "InsatsuSentakuDialog",
                closed: function (e, data, data2) {
                    if (data == "canceled") {
                        return;
                    }
                    else {
                        // 特に何もしない
                    }
                }
            });

            // 個別ラベルダイアログの生成
            kobetsuLabelDialog.dlg({
                url: "Dialog/LabelInsatsuDialog.aspx",
                name: "LabelInsatsuDialog",
                closed: function (e, data, data2) {
                    if (data == "canceled") {
                        return;
                    }
                    else {
                        // 特に何もしない
                    }
                }
            });

            // 調味液ラベルダイアログ生成
            chomiekiLabelDialog.dlg({
                url: "Dialog/ChomiekiLabelDialog.aspx",
                name: "ChomiekiLabelDialog",
                closed: function (e, data, data2) {
                    if (data == "canceled") {
                        return;
                    }
                    else {
                        // 特に何もしない
                    }
                }
            });

            // 日付の多言語対応
            var datePickerFormat = pageLangText.dateFormatUS.text;
            if (App.ui.page.langCountry != 'en-US') {
                datePickerFormat = pageLangText.dateFormat.text;
            }

            // TODO：画面の仕様に応じて以下の datepicker の設定を変更してください。
            $(".search-criteria [name='dt_hiduke_search']").on("keyup", App.data.addSlashForDateString)
                                                                    .datepicker({ dateFormat: datePickerFormat });
            // TODO：ここまで
            // グリッドコントロール固有のコントロール定義
            grid.jqGrid({
                // TODO：画面の仕様に応じて以下の列名の定義を変更してください。
                colNames: [
                pageLangText.flg_print.text
                , pageLangText.flg_kakutei.text
                , pageLangText.nm_line.text
                , pageLangText.cd_hinmei.text
                , pageLangText.nm_hinmei.text
                , pageLangText.nm_uchiwake.text
                , pageLangText.nm_tani.text
                , pageLangText.wt_hitsuyo.text
                , pageLangText.wt_shikomi.text + pageLangText.requiredMark.text
                , pageLangText.nm_seiki.text + pageLangText.requiredMark.text
                , pageLangText.nm_hasu.text + pageLangText.requiredMark.text
                , pageLangText.nm_seiki.text + pageLangText.requiredMark.text
                , pageLangText.nm_hasu.text + pageLangText.requiredMark.text
                , pageLangText.nm_zan_shikakari.text
                , pageLangText.nm_seiki.text
                , pageLangText.nm_hasu.text
                , pageLangText.nm_seiki.text
                , pageLangText.nm_hasu.text
                , pageLangText.no_lot_shikakarihin.text
                , pageLangText.blank.text
                , pageLangText.blank.text
                , pageLangText.blank.text
                , pageLangText.blank.text
                , pageLangText.blank.text
                , "wt_haigo_keikaku"
                , "wt_haigo_keikaku_hasu"
                , "flg_tanto_hinkan"
                , "flg_tanto_seizo"
                // 仕込実績
                , "hidden"
            ],
                // TODO：ここまで
                // TODO：画面の仕様に応じて以下の列モデルの定義を変更してください。
                colModel: [
                    { name: 'flg_print', width: 40, editable: true, hidden: false, edittype: 'checkbox',
                        align: 'center', editoptions: { value: "1:0" }, formatter: 'checkbox',
                        formatoptions: { disabled: false }, classes: 'not-editable-cell'
                    },
                { name: 'flg_shikomi', width: pageLangText.flg_shikomi_width.number, editable: true, hidden: false, edittype: 'checkbox',
                    editoptions: { value: pageLangText.kakuteiKakuteiFlg.text
                                        + ":"
                                        + pageLangText.mikakuteiKakuteiFlg.text
                    }, formatter: 'checkbox', formatoptions: { disabled: false }, align: 'center', classes: 'not-editable-cell'
                },
                { name: 'nm_line', width: 120, editable: false, sorttype: "text", align: "left" },
                { name: 'cd_shikakari_hin', width: 120, editable: false, align: "left", sorttype: "text" },
                { name: haigoName, width: 250, editable: false, sorttype: "text" },
                { name: 'uchiwake', width: pageLangText.uchiwake_width.number, editable: false, sorttype: "text", align: "center", formatter: uchiwakeFormatter },
                { name: 'nm_tani', width: 50, editable: false, sorttype: "text", align: "center" },
                { name: 'wt_hitsuyo', width: 105, editable: false, sorttype: "float", align: 'right',
                    formatter: 'number',
                    formatoptions: {
                        decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 3, defaultValue: "0"
                    }
                },
                // { name: 'wt_shikomi_keikaku', width: 120, editable: true, sorttype: "float", align: 'right',
                { name: 'wt_shikomi_keikaku', width: 105, editable: true, sorttype: "float", align: 'right',
                    formatter: 'number',
                    formatoptions: {
                       // decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 6, defaultValue: "0"
                       decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 3, defaultValue: "0"
                    }
                },
                { name: 'ritsu_keikaku', width: 40, editable: true, sorttype: "text", align: 'right',
                    formatter: 'number',
                    formatoptions: {
                        decimalSeparator: ".", thousandsSeparator: "", decimalPlaces: 2, defaultValue: "0"
                    }
                },
                { name: 'ritsu_keikaku_hasu', width: 40, editable: true, sorttype: "text", align: 'right',
                    formatter: 'number',
                    formatoptions: {
                        decimalSeparator: ".", thousandsSeparator: "", decimalPlaces: 2, defaultValue: "0"
                    }
                },
                { name: 'su_batch_keikaku', width: 50, editable: true, sorttype: "text", align: 'right',
                    formatter: 'number',
                    formatoptions: {
                        decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 0, defaultValue: "0"
                    }
                },
                { name: 'su_batch_keikaku_hasu', width: 50, editable: true, sorttype: "text", align: 'right',
                    formatter: 'number',
                    formatoptions: {
                        decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 0, defaultValue: "0"
                    }
                },
                { name: 'wt_zan_shikakari', width: pageLangText.wt_zan_shikakari_width.number, editable: false, sorttype: "text", align: 'right',
                    formatter: 'number',
                    formatoptions: {
                        decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 3, defaultValue: "0"
                    }
                },
//                { name: 'su_label_sumi', width: 30, editable: false, align: 'right', sorttype: "text" },
                { name: 'su_label_sumi', width: 40, editable: false, align: 'right', sorttype: "text" },
//                { name: 'su_label_sumi_hasu', width: 30, editable: false, align: 'right', sorttype: "text" },
                { name: 'su_label_sumi_hasu', width: 40, editable: false, align: 'right', sorttype: "text" },
//                { name: 'flg_label', width: 30, editable: false, formatter: imageFormatter },
                { name: 'flg_label', width: 40, editable: false, formatter: imageFormatter },
//                { name: 'flg_label_hasu', width: 30, editable: false, formatter: imageFormatter },
                { name: 'flg_label_hasu', width: 40, editable: false, formatter: imageFormatter },
                { name: 'no_lot_shikakari', width: 150, editable: false, sorttype: "text" },
                { name: 'dt_seizo', hidden: true, hidedlg: true },
                { name: 'cd_shokuba', hidden: true, hidedlg: true },
                { name: 'cd_line', hidden: true, hidedlg: true },
                { name: 'ritsu_kihon', hidden: true, hidedlg: true },
                { name: 'wt_haigo_gokei', hidden: true, hidedlg: true },
                { name: 'wt_haigo_keikaku', hidden: true, hidedlg: true },
                { name: 'wt_haigo_keikaku_hasu', hidden: true, hidedlg: true },
                { name: 'flg_tanto_hinkan', hidden: true, hidedlg: true },
                { name: 'flg_tanto_seizo', hidden: true, hidedlg: true },
                { name: 'flg_jisseki', hidden: true, hidedlg: true }
            ],
            // TODO：ここまで
            datatype: "local",
            shrinkToFit: false,
            //multiselect: true,
            //multiboxonly: true,
            rownumbers: true,
            cellEdit: true,
            cellsubmit: 'clientArray',
            // subgridの定義
            subGrid: true,
            subGridOptions: { "plusicon": "ui-icon-triangle-1-e",
                "minusicon": "ui-icon-triangle-1-s",
                "openicon": "ui-icon-arrowreturn-1-e",
                "reloadOnExpand": false,
                "selectOnExpand": false
            },
            subGridBeforeExpand: function (subGrid_id, row_id) {
                grid.editCell(grid.find("#" + row_id)[0].rowIndex, 2, false);
            },
            subGridRowExpanded: function (subgrid_id, row_id) {

                var subgrid_table_id;
                subgrid_table_id = subgrid_id + "_t";
                $("#" + subgrid_id).html("<table id='" + subgrid_table_id + "' class='scroll'></table>");
                $("#" + subgrid_table_id).jqGrid({

                    datatype: "local",
                    colNames: [pageLangText.nm_haigo.text
                                , pageLangText.wt_shikomi.text
                                , pageLangText.nm_shikakari_oya_sub.text
                                , pageLangText.nm_seihin_sub.text
                    ],
                    colModel: [
                                { name: haigoName, sortable: false, width: 270 },
                                { name: "wt_seisan_yotei", sortable: false, width: 149, align: "right",
                                    formatter: 'number',
                                    formatoptions: {
                                        decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 3, defaultValue: "0"
                                    }
                                },
                                { name: "no_lot_shikakari_oya", sortable: false, width: 120 },
                                { name: "no_lot_seihin", sortable: false, width: 120 }

                    ],
                    height: '100%'
                });

                // 
                var subNames = [haigoName, "wt_seisan_yotei", "no_lot_shikakari_oya", "no_lot_seihin"];
                setGridData(subNames, row_id, subgrid_table_id);

            },
            loadComplete: function () {
                // 変数宣言
                var ids = grid.jqGrid('getDataIDs'),
                    criteria = $(".search-criteria").toJSON();

                for (var i = 0; i < ids.length; i++) {
                    var id = ids[i];
                    // TODO : ここから
                    // 検索後の値がマイナスの場合、文字色を赤くする
                    if (0 > parseFloat(grid.getCell(id, "wt_shikomi_keikaku"))) {
                        grid.setCell(id, "wt_shikomi_keikaku", '', { color: '#ff6666' });
                    }

                    // 内訳表示を制御
                    if (grid.getCell(id, "uchiwake") == "") {
                        $("#" + id + " td.sgcollapsed", grid[2]).unbind('click').html('');
                    }

                    // 仕込量が0の場合
                    if (parseFloat(grid.getCell(id, "wt_shikomi_keikaku")) == 0) {
                        // 確定チェックを編集不可に設定
                        $(".jqgrow:eq(" + i + ") td:eq(" + grid.getColumnIndexByName("flg_shikomi") + ") input:checkbox").attr("disabled", true);
                        // 背景色をグレーに変更する
                        $(".jqgrow:eq(" + i + ") td").css("background-color", '#999999');
                    }

                    // 仕込実績がある場合
                    if (grid.getCell(id, "flg_jisseki") == 1) {
                        // 仕込量を編集不可に設定
                        grid.jqGrid('setCell', id, 'wt_shikomi_keikaku', '', 'not-editable-cell');
                        // 倍率を編集不可に設定
                        grid.jqGrid('setCell', id, 'ritsu_keikaku', '', 'not-editable-cell');
                        // 倍率端数を編集不可に設定
                        grid.jqGrid('setCell', id, 'ritsu_keikaku_hasu', '', 'not-editable-cell');
                        // バッチ数を編集不可に設定
                        grid.jqGrid('setCell', id, 'su_batch_keikaku', '', 'not-editable-cell');
                        // バッチ数端数を編集不可に設定
                        grid.jqGrid('setCell', id, 'su_batch_keikaku_hasu', '', 'not-editable-cell');
                    }

                    // TODO：ここまで
                }
            },
            onCellSelect: function (rowid, icol, cellcontent) {
                selectCol = icol;
            },

            ondblClickRow: function (rowid) {

                // 仕込実績がある場合
                if ((selectCol === shikomiRyoCol || selectCol === bairitsuCol || selectCol === bairitsuHasuCol
                        || selectCol === batchCol || selectCol === batchHasuCol) && checkJissekiData()) {
                    // メッセージを表示する。
                    App.ui.page.notifyInfo.message(
                         App.str.format(pageLangText.jissekiCheck.text, pageLangText.shikakariJisseki.text, pageLangText.upd.text)
                        ).show();
                }

            },

            beforeSelectRow: function (rowid, e) {
                // 複数セルを選択したときにobjが不明になるのを回避
                var obj = $(e.target).closest('td')[0];
                if (!App.isUndefOrNull(obj)) {
                    var i = $.jgrid.getCellIndex(obj),
                        cm = grid.jqGrid('getGridParam', 'colModel');
                    if (cm[i].name !== 'cb') {
                        lastClickedRowId = rowid;
                    }
                }
                return true;
            },
            beforeEditCell: function (selectedRowId, cellName, value, iRow, iCol) {
                currentRow = iRow;
                currentCol = iCol;

                // 操作対象行の変更前データを保持する（各行に対して初回のみ）
                var existFlg = false;
                var preData = setUpdatedChangeData(grid.getRowData(selectedRowId));
                for (var idx in orgDataList) {
                    if (orgDataList[idx].no_lot_shikakari == preData.no_lot_shikakari) {
                        existFlg = true;
                        break;
                    }
                }
                if (!existFlg) {
                    orgDataList.push(preData);
                }

                // 仕込計画確定が確定しているかラベルが発行済みの場合は注意ダイアログを表示する。
                if ((iCol === shikomiRyoCol || iCol === bairitsuCol || iCol === bairitsuHasuCol
                        || iCol === batchCol || iCol === batchHasuCol) && checkKakuteiData()) {
                    // 計画確定確認ダイアログを表示する。
                    showKakuteiConfirmDialogUpd();
                    return;
                }
            },
            afterEditCell: function (selectedRowId, cellName, value, iRow, iCol) {
                // Enter キーでカーソルを移動
                //if (currentCol != lastEditCelCol) {
                //    // その行で最後の編集セル以外の場合にカーソルを移動させる。
                //    // subGridを開いている状態の場合、ありえない位置にカーソルが移動してsubGridの中身がおかしくなることがある為。
                grid.moveCell(cellName, iRow, iCol);
                //}
            },
            beforeSaveCell: function (selectedRowId, cellName, value, iRow, iCol) {
                // 背景色をデフォルトに変更する
                var lineIdx = selectedRowId - 1;
                $(".jqgrow:eq(" + lineIdx + ") td").css("background-color", '');
                
                // セルバリデーション
                validateCell(selectedRowId, cellName, value, iCol);
            },
            afterSaveCell: function (selectedRowId, cellName, value, iRow, iCol) {
                // 関連項目の設定
                setRelatedValue(selectedRowId, cellName, value, iCol);
                // 変更データの変数設定
                var changeData;
                // タイムスタンプを確認し、更新か新規かを切り分ける
                // 更新
                //if (grid.jqGrid('getCell', selectedRowId, 'zan_hiduke')) {
                // 更新状態の変更データの設定
                changeData = setUpdatedChangeData(grid.getRowData(selectedRowId));
                // 更新状態の変更セットに変更データを追加
                changeSet.addUpdated(selectedRowId, cellName, value, changeData);
                changeSet.addUpdated(selectedRowId, "ritsu_keikaku", grid.jqGrid('getCell', selectedRowId, 'ritsu_keikaku'), changeData);
                changeSet.addUpdated(selectedRowId, "ritsu_keikaku_hasu", grid.jqGrid('getCell', selectedRowId, 'ritsu_keikaku_hasu'), changeData);
                changeSet.addUpdated(selectedRowId, "su_batch_keikaku", grid.jqGrid('getCell', selectedRowId, 'su_batch_keikaku'), changeData);
                changeSet.addUpdated(selectedRowId, "su_batch_keikaku_hasu", grid.jqGrid('getCell', selectedRowId, 'su_batch_keikaku_hasu'), changeData);
                changeSet.addUpdated(selectedRowId, "wt_shikomi_keikaku", grid.jqGrid('getCell', selectedRowId, 'wt_shikomi_keikaku'), changeData);
                changeSet.addUpdated(selectedRowId, "wt_haigo_keikaku", grid.jqGrid('getCell', selectedRowId, 'wt_haigo_keikaku'), changeData);
                changeSet.addUpdated(selectedRowId, "wt_haigo_keikaku_hasu", grid.jqGrid('getCell', selectedRowId, 'wt_haigo_keikaku_hasu'), changeData);
                changeSet.addUpdated(selectedRowId, "flg_shikomi", grid.jqGrid('getCell', selectedRowId, 'flg_shikomi'), changeData);
                // 新規
                //} else {
                // 追加状態のデータ設定
                //changeData = setCreatedChangeData(grid.getRowData(selectedRowId));
                // 追加状態の変更セットに変更データを追加
                //  changeSet.addCreated(selectedRowId, changeData);
                //}

                // 関連項目の設定を変更セットに反映
                //setRelatedChangeData(selectedRowId, cellName, value, changeData);

                // 仕込量の値による制御
                var lineIdx = selectedRowId - 1;
                if (parseFloat(grid.jqGrid('getCell', selectedRowId, 'wt_shikomi_keikaku')) == 0) {
                    // 仕込量が0の場合、確定チェックを非活性にし、背景色をグレーに変更する
                    $(".jqgrow:eq(" + lineIdx + ") td:eq(" + grid.getColumnIndexByName("flg_shikomi") + ") input:checkbox").attr("disabled", true);
                    $(".jqgrow:eq(" + lineIdx + ") td").css("background-color", '#999999');
                } else {
                    // 仕込量が0でない場合、確定チェックを活性にする
                    $(".jqgrow:eq(" + lineIdx + ") td:eq(" + grid.getColumnIndexByName("flg_shikomi") + ") input:checkbox").attr("disabled", false);
      
                }

            }
        });
        grid.jqGrid('setGroupHeaders', {
            useColSpanStyle: true,
            groupHeaders: [
                    { startColumnName: 'ritsu_keikaku', numberOfColumns: 2, titleText: pageLangText.nm_ritsu_bai.text },
                    { startColumnName: 'su_batch_keikaku', numberOfColumns: 2, titleText: pageLangText.nm_su_batch.text },
                    { startColumnName: 'su_label_sumi', numberOfColumns: 2, titleText: pageLangText.nm_gokei_label.text },
                    { startColumnName: 'flg_label', numberOfColumns: 2, titleText: pageLangText.nm_label.text }
                ]
        });

        // <summary>チェックボックス操作時のグリッド値更新を行います</summary>
        $(document).on("click", "#item-grid .jqgrow td :checkbox", function () {
            // 行取得
            var iCol = $(this).parent("td").parent("tr").find("td").index($(this).parent("td")),
                    rowId = $(this).parent("td").parent("tr").attr("id"),
                    cellName = grid.getGridParam("colModel")[iCol].name,
                    value;

            // 更新状態の変更データの設定
            if (cellName == "flg_shikomi") {
                // チェックボックスの値
                value = grid.getCell(rowId, cellName);
                saveEdit();

                // ラベル解除
                if (value === pageLangText.mikakuteiKakuteiFlg.text) {
                    grid.setCell(rowId, "flg_label", 0);
                    grid.setCell(rowId, "flg_label_hasu", 0);
                }

                var changeData = setUpdatedChangeData(grid.getRowData(rowId));

                // TODO：画面の仕様に応じて以下の定義を変更してください。
                //value = changeData[cellName];
                // TODO：ここまで

                // 更新状態の変更セットに変更データを追加
                changeSet.addUpdated(rowId, cellName, value, changeData);
                grid.setCell(rowId, cellName, value);

                // 操作対象行の変更前データを保持する（各行に対して初回のみ）
                var existFlg = false;
                var preData = setUpdatedChangeData(grid.getRowData(rowId));
                for (var idx in orgDataList) {
                    if (orgDataList[idx].no_lot_shikakari == preData.no_lot_shikakari) {
                        existFlg = true;
                        break;
                    }
                }
                if (!existFlg) {
                    // 変更前値をセット
                    // イベント発生時点で変更前値は存在しない、チェックボックス項目につき反転値をセットする
                    if (preData.flg_shikomi == pageLangText.mikakuteiKakuteiFlg.text) {
                        // 未確定の場合 -> 前値は確定
                        preData.flg_shikomi = pageLangText.kakuteiKakuteiFlg.text;
                    } else if (preData.flg_shikomi == pageLangText.kakuteiKakuteiFlg.text) {
                        // 確定の場合 -> 前値は未確定
                        preData.flg_shikomi = pageLangText.mikakuteiKakuteiFlg.text;
                    }
                    orgDataList.push(preData);
                }
            }
        });

        // サブグリッド用のデータ取得
        var setGridData = function (subNames, row_id, subgrid_table_id) {
            var querySubGrid = new querySubWeb(row_id);
            var data = [];
            App.ui.loading.show(pageLangText.nowProgressing.text);
            App.ajax.webget(
            // WCF Data ServicesのODataシステムクエリオプションを生成
                    App.data.toWebAPIFormat(querySubGrid)
                ).done(function (result) {
                    // データバインド
                    if (result.__count > 0) {
                        for (var i = 0; i < result.__count; i++) {
                            data[i] = {};
                            data[i][subNames[0]] = result.d[i][haigoName];
                            data[i][subNames[1]] = result.d[i]["wt_shikomi_keikaku"];
                            data[i][subNames[2]] = result.d[i]["no_lot_shikakari_oya"];
                            data[i][subNames[3]] = result.d[i]["no_lot_seihin"];
                        }
                        for (var i = 0; i <= data.length; i++) {
                            $("#" + subgrid_table_id).jqGrid('addRowData', i + 1, data[i]);
                        }
                    }
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                }).always(function () {
                    // ローディングの終了
                    App.ui.loading.close();
                });
        };

        // ラベル出力フラグの表示フォーマット
        function imageFormatter(cellvalue, options, rowObject) {
            if (cellvalue != pageLangText.falseFlg.text) {
                return ("<center><img src='./../Styles/images/ui-label.png' style='vertical-align: bottom;'/></center>");
            }
            else {
                return ("");
            }
        }

        // 内訳表示フォーマッタ
        function uchiwakeFormatter(cellvalue, options, rowObject) {
            var uchiwake = "";
            if (App.isUndefOrNull(cellvalue)) {
                return uchiwake;
            }

            // 内訳が1件以上あれば表示変更
            if (cellvalue >= 1) {
                uchiwake = pageLangText.requiredMark.text;
            }
            return uchiwake;
        }

        /// <summary>セルの関連項目を設定します。</summary>
        /// <param name="selectedRowId">選択行ID</param>
        /// <param name="cellName">列名</param>
        /// <param name="value">元となる項目の値</param>
        /// <param name="iCol">項目の列番号</param>
        var setRelatedValue = function (selectedRowId, cellName, value, iCol) {
            // TODO：画面の仕様に応じて以下の関連項目を設定を変更してください。
            App.ui.page.notifyAlert.clear();
            // 仕込量 計算
            if (cellName === "ritsu_keikaku" || cellName === "ritsu_keikaku_hasu"
                    || cellName === "su_batch_keikaku" || cellName === "su_batch_keikaku_hasu") {
                calcShikomiJuryo(selectedRowId);
                // 仕込重量再計算後、確定を解除、ラベル/ラベル端数をクリアする
                if (cellName === "ritsu_keikaku" || cellName === "su_batch_keikaku") {
                    clearRelatedCell(selectedRowId, "seiki");
                }
                else {
                    clearRelatedCell(selectedRowId, "hasu");
                }
            }
            // 倍率 計算
            if (cellName === "wt_shikomi_keikaku") {
                calcBairitsuBatchSu(selectedRowId);
                // 倍率再計算後、確定を解除、ラベル/ラベル端数をクリアする
                clearRelatedCell(selectedRowId, "all");
            }

            //if (cellName === "flg_shikomi") {
            //
            //}
            //仕掛残 計算
            var tmpShikomi = grid.jqGrid('getCell', selectedRowId, 'wt_shikomi_keikaku'),
                    tmpHitsuyo = grid.jqGrid('getCell', selectedRowId, 'wt_hitsuyo'),
            //tmpZan = tmpShikomi - tmpHitsuyo;
                    tmpZan = Math.ceil(App.data.trimFixed((tmpShikomi - tmpHitsuyo) * 1000)) / 1000;

            grid.setCell(selectedRowId, "wt_zan_shikakari", tmpZan);

            // TODO：ここまで
        };
        /// <summary>仕込量を計算する</summary>
        var calcShikomiJuryo = function (rowid) {
            var criteria = $(".search-criteria").toJSON();
            var haigoWeight = grid.getCell(rowid, "wt_haigo_gokei");
            if (haigoWeight == 0) {
                zeroHaigoFlg = true;
                App.ui.page.notifyAlert.message(pageLangText.zeroHaigo.text).show();
                grid.setCell(rowid, "ritsu_keikaku", 0);
                grid.setCell(rowid, "ritsu_keikaku_hasu", 0);
                grid.setCell(rowid, "su_batch_keikaku", 0);
                grid.setCell(rowid, "su_batch_keikaku_hasu", 0);
                grid.setCell(rowid, "wt_shikomi_keikaku", 0);
                return;
            }
            var query = {
                url: "../api/CalcShikomiJuryo",
                bairitsu: grid.getCell(rowid, "ritsu_keikaku"),
                bairitsuHasu: grid.getCell(rowid, "ritsu_keikaku_hasu"),
                batchSu: grid.getCell(rowid, "su_batch_keikaku"),
                batchSuHasu: grid.getCell(rowid, "su_batch_keikaku_hasu"),
                gokeiHaigoJuryo: grid.getCell(rowid, "wt_haigo_gokei")
            }
            App.ajax.webgetSync(
            // WCF Data ServicesのODataシステムクエリオプションを生成
                App.data.toWebAPIFormat(query)
                ).done(function (result) {
                    // 検索フラグを立てる
                    isSearch = true;
                    if (!App.isUndefOrNull(result)) {
                        grid.setCell(rowid, "wt_shikomi_keikaku", result.shikomiJuryo);
                    }
                    else {
                        grid.setCell(rowid, "wt_shikomi_keikaku", null);
                    }
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
        /// <summary>倍率・バッチ数を計算する</summary>
        var calcBairitsuBatchSu = function (rowid) {
            var criteria = $(".search-criteria").toJSON();
            var haigoWeight = grid.getCell(rowid, "wt_haigo_gokei");
            var query = {
                url: "../api/CalcBairitsuBatchSu",
                shikomiJuryo: grid.getCell(rowid, "wt_shikomi_keikaku"),
                kihonBairitsu: grid.getCell(rowid, "ritsu_kihon"),
                gokeiHaigoJuryo: grid.getCell(rowid, "wt_haigo_gokei")
            }
            if (haigoWeight == 0) {
                zeroHaigoFlg = true;
                App.ui.page.notifyAlert.message(pageLangText.zeroHaigo.text).show();
                grid.setCell(rowid, "ritsu_keikaku", 0);
                grid.setCell(rowid, "ritsu_keikaku_hasu", 0);
                grid.setCell(rowid, "su_batch_keikaku", 0);
                grid.setCell(rowid, "su_batch_keikaku_hasu", 0);
                grid.setCell(rowid, "wt_shikomi_keikaku", 0);
                return;
            }
            App.ajax.webgetSync(
            // WCF Data ServicesのODataシステムクエリオプションを生成
                App.data.toWebAPIFormat(query)
                ).done(function (result) {
                    // 検索フラグを立てる
                    isSearch = true;
                    if (!App.isUndefOrNull(result)) {
                        grid.setCell(rowid, "ritsu_keikaku", result.bairitsu);
                        grid.setCell(rowid, "ritsu_keikaku_hasu", result.bairitsuHasu);
                        grid.setCell(rowid, "su_batch_keikaku", result.batchSu);
                        grid.setCell(rowid, "su_batch_keikaku_hasu", result.batchSuHasu);
                    }
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
        /// <summary>対象をクリアする</summary>
        var clearRelatedCell = function (rowId, kbn) {
            //配合重量計算
            var tmphaigo = grid.jqGrid('getCell', rowId, 'wt_haigo_gokei'),
                    tmpRitsuKeikaku = grid.jqGrid('getCell', rowId, 'ritsu_keikaku'),
                    tmpRitsuKeikakuHasu = grid.jqGrid('getCell', rowId, 'ritsu_keikaku_hasu'),
                    tmpSuKeikaku = grid.jqGrid('getCell', rowId, 'su_batch_keikaku'),
                    tmpSuKeikakuHasu = grid.jqGrid('getCell', rowId, 'su_batch_keikaku_hasu');
            var sei;
            var hasu;
            sei = tmphaigo * tmpRitsuKeikaku * tmpSuKeikaku;
            hasu = tmphaigo * tmpRitsuKeikakuHasu * tmpSuKeikakuHasu;
            grid.setCell(rowId, "wt_haigo_keikaku", sei);
            grid.setCell(rowId, "wt_haigo_keikaku_hasu", hasu);
            grid.setCell(rowId, "flg_shikomi", pageLangText.mikakuteiKakuteiFlg.text);
            if (kbn == "all") {
                grid.setCell(rowId, "flg_label", 0);
                grid.setCell(rowId, "flg_label_hasu", 0);
            }
            else if (kbn == "seiki") {
                grid.setCell(rowId, "flg_label", 0);
            }
            else {
                grid.setCell(rowId, "flg_label_hasu", 0);
            }
        };
        /// <summary>ラインコンボ事前データロード</summary>
        /// <param name="shokubaCode">職場コード</param>
        var setLineComboData = function (shokubaCode) {
            App.deferred.parallel({
                // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                loading: App.ui.loading.show(pageLangText.nowProgressing.text),
                lineCode: App.ajax.webget("../Services/FoodProcsService.svc/ma_line()?$filter=flg_mishiyo eq "
                                            + pageLangText.shiyoMishiyoFlg.text + " and cd_shokuba eq '"
                                            + shokubaCode + "' & orderby eq cd_line")
                // TODO: ここまで
            }).done(function (result) {
                // TODO: 画面の仕様に応じて以下のサービス呼び出し成功時の処理を変更してください。
                lineCode = result.successes.lineCode.d;
                var lineTarget = $(".search-criteria [name='lineCode']");
                lineTarget.empty();
                // 検索用ドロップダウンの設定
                //App.ui.appendOptions(lineTarget, "cd_line", "nm_line", lineCode, false);
                App.ui.appendOptions(lineTarget, "cd_line", "nm_line", lineCode, true);
                // 当日日付を挿入
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
        };

        /// <summary>非表示列設定ダイアログの表示を行います。</summary>
        /// <param name="e">イベントデータ</param>
        var showColumnSettingDialog = function (e) {
            var dlgHeight = (grid.getGridParam("height") - 30 < 230 ? (grid.getGridParam("height") - 30) : 230);
            var dataHeight = dlgHeight - 50;
            var params = {
                width: 300,
                heitht: dlgHeight,
                dataheight: dataHeight,
                modal: true,
                drag: false,
                recreateForm: true,
                caption: pageLangText.colchange.text,
                bCancel: pageLangText.cancel.text,
                bSubmit: pageLangText.save.text
            };
            grid.setColumns(params);
        };
        /// <summary>グリッドの列変更ボタンクリック時のイベント処理を行います。</summary>
        $(".colchange-button").on("click", showColumnSettingDialog);

        /// <summary>全チェック／解除処理</summary>
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
                grid.setCell(id, 'flg_print', checkButtonStatus);
            }
        };
        /// <summary>全チェック/解除ボタンクリック時のイベント処理を行います。</summary>
        $(".check-button").on("click", function (e) {
            checkAll();
        });

        //// コントロール定義 -- End

        //// 操作制御定義 -- Start

        // 操作制御定義を定義します。
        App.ui.pagedata.operation.applySetting(App.ui.page.user.Roles[0], App.ui.page.lang);
            //// 操作制御定義 -- End

        //---------------------------------------------------------
        //2019/07/24 trinh.bd Task #14029
        //------------------------START----------------------------
        var kbn_shikomi_chohyo = App.ui.page.user.kbn_shikomi_chohyo;
        if (kbn_shikomi_chohyo != pageLangText.isRoleFisrt.number) {
            $("[data-app-operation='insatsu_sentaku']").remove();
            $("[data-app-operation='label_kobetsu']").remove();
        }
        //------------------------END------------------------------


        //// 事前データロード -- Start 

        // 画面アーキテクチャ共通の事前データロード
        App.deferred.parallel({
            loading: App.ui.loading.show(pageLangText.nowProgressing.text),
            // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
            shokubaCode: App.ajax.webgetSync("../Services/FoodProcsService.svc/ma_shokuba()?$filter=flg_mishiyo eq "
                                        + pageLangText.shiyoMishiyoFlg.text + " & orderby eq cd_shokuba")
            // TODO: ここまで
        }).done(function (result) {
            // TODO: 画面の仕様に応じて以下のサービス呼び出し成功時の処理を変更してください。
            shokubaCode = result.successes.shokubaCode.d;
            var shokubaTarget = $(".search-criteria [name='shokubaCode']");
            // 検索用ドロップダウンの設定
            App.ui.appendOptions(shokubaTarget, "cd_shokuba", "nm_shokuba", shokubaCode, false);
            setLineComboData(shokubaCode[0].cd_shokuba);
            // 当日日付を挿入
            $(".search-criteria [name='dt_hiduke_search']").datepicker("setDate", new Date());

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
        var queryWeb = function () {
            var criteria = $(".search-criteria").toJSON();
            var query = {
                // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                url: "../api/ShikakarihinShikomiKeikaku",
                // TODO: ここまで
                cd_shokuba: criteria.shokubaCode,
                cd_line: criteria.lineCode,
                flg_kakutei: criteria.kakuteiCheck == "on" ? 1 : 0,
                flg_mikakutei: criteria.mikakuteiCheck == "on" ? 1 : 0,
                dt_hiduke: App.data.getDateTimeStringForQueryNoUtc(criteria.dt_hiduke_search),
                // TODO: ここまで
                skip: querySetting.skip,
                top: querySetting.top

            }
            return query;
        };

        /// <summary>サブグリッドクエリオブジェクトの設定</summary>
        var querySubWeb = function (id) {
            var criteria = $(".search-criteria").toJSON();
            var rowdata = grid.getRowData(id);
            var query = {
                // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                url: "../api/ShikakarihinShikomiKeikakuUchiwake",
                // TODO: ここまで
                cd_shokuba: rowdata.cd_shokuba,
                cd_line: rowdata.cd_line,
                flg_kakutei: criteria.kakuteiCheck == "on" ? 1 : 0,
                flg_mikakutei: criteria.mikakuteiCheck == "on" ? 1 : 0,
                //dt_seizo: App.data.getDateTimeString(App.data.getDate(rowdata.dt_seizo)),
                dt_seizo: App.data.getDateTimeStringForQueryNoUtc(App.data.getDate(rowdata.dt_seizo)),
                cd_shikakari_hin: rowdata.cd_shikakari_hin,
                no_lot_shikakari: rowdata.no_lot_shikakari,
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
            //    App.str.format(
            //        pageLangText.nowListLoading.text,
            //        querySetting.skip + 1,
            //        querySetting.top
            //    )
                );
            App.ajax.webget(
            // WCF Data ServicesのODataシステムクエリオプションを生成
                    App.data.toWebAPIFormat(queryWeb)
                ).done(function (result) {
                    // データバインド
                    bindData(result);

                    // グリッドの先頭行選択
                    var idNum = grid.getGridParam("selrow");
                    if (idNum == null) {
                        $("#1 > td:nth-child(4)").click();
                    }
                    else {
                        $("#" + idNum).removeClass("ui-state-highlight").find("td:eq(2)").click();
                    }
                    $(".ui-jqgrid-hdiv").scrollLeft(0); // 明細のスクロール位置をリセット

                    // 検索フラグを立てる
                    isSearch = true;
                    isCriteriaChange = false;
                    // 検索条件を閉じる
                    closeCriteria();
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
            zeroHaigoFlg = false;
            // TODO: 画面の仕様に応じて以下のパラメータ設定を変更してください。
            currentRow = 0;
            currentCol = firstCol;
            // 変更セットの作成
            changeSet = new App.ui.page.changeSet();
            checkButtonStatus = pageLangText.falseFlg.text;
            orgDataList = [];
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

            if (App.isUndefOrNull(selectedRowId) || selectedRowId.length == 0) {
                selectedRowId = lastClickedRowId;
            }

            currentRow = $('#' + selectedRowId)[0].rowIndex;
            return selectedRowId;
        };

        /// <summary>調味液ラベル発行前の処理 </summary>
        var getDetailChomiData = function (cd, date) {
            // 調味ラベルの基本情報を取得
            var criteria = $(".search-criteria").toJSON(),
                    res;

            var query = {
                url: "../api/YukoHaigoMeiSeihin"
                    , cd_hinmei: cd
                    , dt_seizo: App.data.getDateTimeStringForQueryNoUtc(App.data.getDate(date))
                    , flg_mishiyo: pageLangText.shiyoMishiyoFlg.text
                    , kbn_master: pageLangText.shikakariHinKbn.text
            };
            App.ajax.webgetSync(
            // WCF Data ServicesのODataシステムクエリオプションを生成
                App.data.toWebAPIFormat(query)
                ).done(function (result) {
                    // 取得結果を格納
                    res = result;
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                }).always(function () {
                    setTimeout(function () {
                        // ローディングの終了
                        App.ui.loading.close();
                        isDataLoading = false;
                    }, 500);
                });

            return res;
        };

        /// <summary>グリッドの選択行(チェックボックス)の行IDを取得します。 </summary>
        var getSelectedRowCheckedCount = function (isLabel) {
            // multi select の件数が適切か判断
            // ラベル出力の場合は、選択行が一件であること
            // その他の場合は、一件以上存在すること
            //var selRowIds = grid.jqGrid('getGridParam', 'selarrrow');
            var ids = grid.jqGrid('getDataIDs');
            var selRowIds = new Array();
            var cnt = 0;
            var printFlg;
            var en;
            //var selRowIds = grid.jqGrid('getGridParam', 'selarrrow');
            //var cnt = selRowIds.length;
            //var ids = grid.jqGrid('getDataIDs');
            for (var i = 0; i < ids.length; i++) {
                var id = ids[i];
                printFlg = grid.getCell(id, "flg_print");
                if (printFlg == 1) {
                    selRowIds[cnt] = id;
                    cnt = cnt + 1;
                }
            }

            // レコードがない場合は処理を抜ける
            if (cnt == 0) {
                App.ui.page.notifyAlert.message(pageLangText.noRowChecked.text).show();
                return;
            }

            if (isLabel && cnt > 1) {
                //コメント修正する
                App.ui.page.notifyAlert.message(
                        App.str.format(pageLangText.someRowChecked.text, pageLangText.btn_label_message.text)
                    ).show();
                return
            }

            if (isLabel) {
                // 最後に選択された行のＩＤを返却する
                // 一件しか選択させないので、選択行が返る
                //return grid.getGridParam('selrow');
                //return selRowIds[0];
                return selRowIds;
            }
            else {
                // 帳票出力画面は、対象行すべてを返す
                return selRowIds;
            }
        };

        /// <summary>追加状態の変更セットに追加する変更データの設定を行います。</summary>
        /// <param name="newRow">新規行データ</param>
        var setCreatedChangeData = function (newRow) {
            // TODO: 画面の仕様に応じて以下の項目を変更してください。
            var changeData = {
                "dt_hizuke": eval(newRow.dt_hiduke.replace(/\/Date\((\d+)\)\//gi, "new Date($1)")),
                "cd_hinmei": newRow.cd_hinmei,
                "wt_shiyo_zan": newRow.wt_shiyo_zan
            };
            // TODO: ここまで

            return changeData;
        };
        /// <summary>更新状態の変更セットに追加する変更データの設定を行います。</summary>
        /// <param name="row">選択行</param>
        var setUpdatedChangeData = function (row) {
            // TODO: 画面の仕様に応じて以下の項目を変更してください。
            var changeData = {
                "flg_shikomi": row.flg_shikomi,
                "cd_shikakari_hin": row.cd_shikakari_hin,
                "cd_shokuba": row.cd_shokuba,
                "cd_line": row.cd_line,
                "no_lot_shikakari": row.no_lot_shikakari,
                "dt_seizo": row.dt_seizo,
                "wt_shikomi_keikaku": row.wt_shikomi_keikaku,
                "ritsu_keikaku": row.ritsu_keikaku,
                "ritsu_keikaku_hasu": row.ritsu_keikaku_hasu,
                "su_batch_keikaku": row.su_batch_keikaku,
                "su_batch_keikaku_hasu": row.su_batch_keikaku_hasu,
                "wt_haigo_keikaku": row.wt_haigo_keikaku,
                "wt_haigo_keikaku_hasu": row.wt_haigo_keikaku_hasu
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
            if (cellName === "ArticleName") {
                changeSet.addUpdated(selectedRowId, "cd_hinmei", value, changeData);
            }
            // TODO: ここまで
        };

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

        // <summary>データの値に変更が無いものを変更セットから除外します。</summary>
        var removeNoChange = function () {
            var removeRowId = [];    // 削除リスト

            // 変更セットのうち、変更が無い行を取得
            for (var rowId in changeSet.changeSet.updated) {
                // 変更セットのデータ取得
                var updateInfo = changeSet.changeSet.updated[rowId];
                // 変更前のデータ取得
                var orgInfo = null;
                for (var idx in orgDataList) {
                    if (orgDataList[idx].no_lot_shikakari == updateInfo.no_lot_shikakari) {
                        orgInfo = orgDataList[idx];
                        break;
                    }
                }
                // 変更セットと変更前の比較
                if (updateInfo.flg_shikomi == orgInfo.flg_shikomi                      // 確定
                    && updateInfo.wt_shikomi_keikaku == orgInfo.wt_shikomi_keikaku     // 仕込量
                    && updateInfo.ritsu_keikaku == orgInfo.ritsu_keikaku               // 倍率　正規
                    && updateInfo.ritsu_keikaku_hasu == orgInfo.ritsu_keikaku_hasu     // 倍率　端数
                    && updateInfo.su_batch_keikaku == orgInfo.su_batch_keikaku         // バッチ数　正規
                    && updateInfo.su_batch_keikaku_hasu == orgInfo.su_batch_keikaku_hasu) {  // バッチ数　端数
                    // 各変更可能項目に変更が無い場合、削除リストに追加
                    removeRowId.push(rowId);
                }
            }

            // 変更セットから削除
            for (var removeIdx in removeRowId) {
                changeSet.removeUpdated(removeRowId[removeIdx]);

            }
        };
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

            // 編集内容の保存
            saveEdit();

            // ローディングの表示
            App.ui.loading.show(pageLangText.nowSaving.text);

            // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
            var saveUrl = "../api/ShikakarihinShikomiKeikaku";
            // TODO: ここまで

            App.ajax.webpost(
                    saveUrl, getPostData()
                ).done(function (result) {
                    // 検索前の状態に初期化
                    clearState();
                    App.ui.page.notifyInfo.message(pageLangText.successMessage.text).show();
                    // データ検索
                    searchItems(new queryWeb());
                    resizeContents(); // ヘッダーの崩れ対応
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
            // 編集内容の保存
            saveEdit();

            // ローディング表示
            App.ui.loading.show(pageLangText.nowProgressing.text);

            // チェック処理が始まるとローディング画像が表示されない為、setTimeoutで間を入れる
            setTimeout(function () {
                showSaveConfirmDialog();    // 保存処理の実行
            }, 100);
        });

        /// <summary>ラインボタンクリック時のイベント処理を行います。</summary>
        //$(".line-button").on("click", function (e) {
        //    var code = grid.getCell(getSelectedRowId(false), "cd_shikakari_hin")
        //    var selectedRowId = getSelectedRowId();
        //    if (App.isUndefOrNull(selectedRowId)) {
        //        return;
        //    }
        //    // 行選択
        //    var idNum = grid.getGridParam("selrow");
        //    $("#" + idNum).removeClass("ui-state-highlight").find("td").click();
        //    criteria = $(".search-criteria").toJSON();
        //    var shokubaCode = criteria.shokuba
        //    , option = { id: 'seizoLine', multiselect: false
        //                , param1: shokubaCode
        //                , param2: code
        //                , param3: pageLangText.hinmeiMasterSeizoLineMasterKbn.text
        //    };
        //    lineDialog.draggable(true);
        //    lineDialog.dlg("open", option);
        //});

        /// <summary>ラベル印刷ボタンクリック時のイベント処理を行います。</summary>
        $(".btn_label_kobetsu").on("click", function (e) {
            // 情報/エラーメッセージのクリア
            App.ui.page.notifyInfo.clear();
            App.ui.page.notifyAlert.clear();

            // selectを外します
            var idNum = grid.getGridParam("selrow");
            $("#" + idNum).removeClass("ui-state-highlight").find("td:eq(2)").click();

            // 整合性チェックエラーの背景をリセット
            grid.setCell(labelInsatsuErrRowId, shikomiFlgCol, "", { background: '#' });

            // 明細の変更をチェック
            if (!noChange()) {
                App.ui.page.notifyAlert.message(
                        App.str.format(pageLangText.labelprintCheck.text, pageLangText.meisai.text, pageLangText.btn_label_kobetsu.text)
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
            // 選択されているか
            var printRowId = getSelectedRowCheckedCount(true);
            if (!printRowId) {
                return;
            }
            // 整合性チェック
            // [仕掛品計画サマリー]．[仕込フラグ] = 区分コード一覧#仕込フラグ#確定 であること
            for (var i = 0; i < printRowId.length; i++) {
                var rowId = printRowId[i];
                var flgKakutei = grid.getCell(rowId, "flg_shikomi");
                if (flgKakutei != pageLangText.trueFlg.text) {
                    var uniqueId = rowId + "_" + shikomiFlgCol;
                    App.ui.page.notifyAlert.message(MS0713, uniqueId).show();
                    // 対象セルの背景変更
                    grid.setCell(rowId, shikomiFlgCol, "", { background: '#ff6666' });
                    labelInsatsuErrRowId = rowId;
                    return;
                }
            }
            // 内容チェック
            var Shikomi = parseFloat(grid.jqGrid('getCell', printRowId, 'wt_shikomi_keikaku'));
            if (Shikomi == 0) {
                App.ui.page.notifyAlert.message(pageLangText.zeroShikomi.text).show();
                return;
            }

            // ラベル発行へ情報を渡す
            // var paramHaigo = grid.getCell(printRowId, "cd_shikakari_hin")
            //     + " " + grid.getCell(printRowId, haigoName);

            // データを行ごと取得するようにする
            var rowData = grid.getRowData(printRowId);
            var option = {
                id: 'kobetsuLabel', multiselect: false
                    , param1: rowData["no_lot_shikakari"]
                    //, param2: $(".search-criteria [name='lineCode'] option:selected").text()                    
                    , param2: rowData["nm_line"]
                    , param3: rowData[haigoName]
                    , param4: rowData["wt_shikomi_keikaku"]
                    , param5: rowData["ritsu_keikaku"]
                    , param6: rowData["ritsu_keikaku_hasu"]
                    , param7: rowData["su_batch_keikaku"]
                    , param8: rowData["su_batch_keikaku_hasu"]
                    , param9: rowData["cd_shikakari_hin"]
                    , param10: rowData["dt_seizo"]
            };
            kobetsuLabelDialog.draggable(true);
            kobetsuLabelDialog.dlg("open", option);
        });

        /// <summary>調味液ラベルボタンクリック時のイベント処理を行います。</summary>
        $(".btn_label_chomieki").on("click", function (e) {
            App.ui.page.notifyAlert.clear();

            // selectを外します
            var idNum = grid.getGridParam("selrow");
            $("#" + idNum).removeClass("ui-state-highlight").find("td:eq(2)").click();

            // 明細の変更をチェック
            if (!noChange()) {
                App.ui.page.notifyAlert.message(
                        App.str.format(pageLangText.labelprintCheck.text
                                       , pageLangText.meisai.text
                                       , pageLangText.btn_label_chomieki.text)
                ).show();
                return;
            }
            // 検索条件の変更をチェック
            if (isCriteriaChange) {
                App.ui.page.notifyAlert.message(
                        App.str.format(pageLangText.criteriaChange.text
                                       , pageLangText.searchCriteria.text
                                       , pageLangText.output.text)
                ).show();
                return;
            }
            // 選択されているか
            var printRowId = getSelectedRowCheckedCount(true);
            if (!printRowId) {
                return;
            }

            // 配合の情報を取得し、取得できた場合はラベル出力のデータにする
            // できない場合は、マスタ不備でエラー
            var rowdata = grid.getRowData(printRowId);
            var chomiData = getDetailChomiData(rowdata.cd_shikakari_hin, rowdata.dt_seizo);

            // 調味データがなければ、出力しない
            if (!chomiData.__count > 0) {
                App.ui.page.notifyAlert.message(pageLangText.noChomiData.text).show();
                return;
            }

            // 内容チェック【MS0727】
            if (!checkChomiLabelChomiData(chomiData)) {
                App.ui.page.notifyAlert.message(MS0727).show();
                return;
            }
            // データを行ごと取得するようにする        
            var option = {
                id: 'chomiekiLabel'
                    , multiselect: false
                    , param1: rowdata
                    , param2: chomiData
                    , param3: haigoName
            };
            chomiekiLabelDialog.draggable(true);
            chomiekiLabelDialog.dlg("open", option);
        });
        /// <summary>調味液ラベルボタンクリック時の内容チェック
        /// 【MS0727】以下の条件に一致しない場合はエラー
        /// 　配合名マスタ．処理品フラグが「処理品」かつ、
        /// 　配合名マスタ．賞味期間 > 0 かつ、配合名マスタ．保管区分がnull以外かつ、
        /// 　配合名マスタ．小分重量 > 0 かつ、配合名マスタ．小分け数 > 0 </summary>
        var checkChomiLabelChomiData = function (chomiData) {
            var isValid = false,
                    data = chomiData.d[0];

            if (data.flg_shorihin == pageLangText.shorihinShorihinFlg.text
                    && data.dd_shomi > 0 && data.su_kowake > 0 && data.wt_kowake > 0
                    && !App.isUndefOrNull(data.kbn_hokan)
                ) {
                isValid = true;
            }

            return isValid;
        };

        /// <summary>印刷選択ボタンクリック時のイベント処理を行います。</summary>
        $(".btn_insatsu_sentaku").on("click", function (e) {
            App.ui.page.notifyAlert.clear();

            // selectを外します
            var idNum = grid.getGridParam("selrow");
            $("#" + idNum).removeClass("ui-state-highlight").find("td:eq(2)").click();

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
            // 選択されているか
            var printRowId = getSelectedRowCheckedCount(false);
            if (!printRowId) {
                return;
            }

            var isAllKakutei = true,
                    selectedLotNo = "";
            if (printRowId.length) {
                for (var i = 0; i < printRowId.length; i++) {
                    // 確定フラグがすべて立っているかのチェック
                    if (isAllKakutei && pageLangText.mikakuteiKakuteiFlg.text === grid.getCell(printRowId[i], "flg_shikomi")) {
                        isAllKakutei = false;
                    }
                    // ロットＮｏの取得(CSV形式に)
                    if (i == 0) {
                        selectedLotNo = grid.getCell(printRowId[i], "no_lot_shikakari");
                    }
                    else {
                        selectedLotNo += "," + grid.getCell(printRowId[i], "no_lot_shikakari");
                    }
                }
            }

            // 印刷情報を渡す
            var paramShikomiFlg = isAllKakutei;
            var paramShikakariLot = selectedLotNo;

            var option = {
                id: 'insatsuSentaku'
                    , param1: paramShikomiFlg
                    , param2: $(".search-criteria").toJSON()
                    , param3: paramShikakariLot
            };
            insatsuSentakuDialog.draggable(true);
            insatsuSentakuDialog.dlg("open", option);
        });
        //// 保存処理 -- End

        //// バリデーション -- Start

        // グリッドコントロール固有のバリデーション

        // TODO: 画面の仕様に応じて以下のカスタムバリデーション定義を変更してください。

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

        /// <summary>仕込計画確定確認ダイアログ(更新用)の「はい」ボタンクリック時のイベント処理を行います。</summary>
        $(".kakutei-confirm-dialog-upd .dlg-yes-button").on("click", closeKakuteiConfirmDialogUpd);
        // <summary>仕込計画確定確認ダイアログ(更新用)の「いいえ」ボタンクリック時のイベント処理を行います。</summary>
        $(".kakutei-confirm-dialog-upd .dlg-no-button").on("click", reSelectRow);

        /// 職場コンボ変更時
        $("#shokubaComBoxId").change(function () {
            setLineComboData(this.value);
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
                        <span class="item-label" data-app-text="dt_hiduke_search"></span>
                        <input type="text" name="dt_hiduke_search" maxlength="10"/>
                    </label>
                <br/>
                    <label>
                        <input type="checkbox" name="kakuteiCheck" id="kakuteiCheck" checked="checked" /><span class="item-label" style="width: 100px" data-app-text="flg_kakutei_search"></span>
                    </label>
                    <label>
                        <input type="checkbox" name="mikakuteiCheck" id="mikakuteiCheck" checked="checked" /><span class="item-label" style="width: 100px" data-app-text="flg_mikakutei_search"></span>
                    </label>
                </li>
            </ul>
            <ul class="item-list item-list-right clearfix">
            
                <li>
                    <label>
                        <span class="item-label" data-app-text="nm_shokuba_search" data-tooltip-text="nm_shokuba_search"></span>
                        <select name="shokubaCode" id="shokubaComBoxId">
                        </select>
                    </label>
                </li>
            
                <li>
                    <label>
                        <span class="item-label" data-app-text="nm_line_search"></span>
                        <select name="lineCode">
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
                <button type="button" class="colchange-button" data-app-operation="colchange">
                    <span class="icon"></span><span data-app-text="colchange"></span>
                </button>
				<button type="button" class="check-button" name="check-button" data-app-operation="check">
					<span class="icon"></span><span data-app-text="checkAndReset"></span>
				</button>
                <!--
                <button type="button" class="line-button" name="line-button">
					<span class="icon"></span><span data-app-text="btn_itiran_line"></span>
				</button>
                -->
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
        <button type="button" class="btn_insatsu_sentaku" name="btn_insatsu_sentaku" data-app-operation="insatsu_sentaku">
            <!--<span class="icon"></span>-->
            <span data-app-text="btn_insatsu_sentaku"></span>
        </button>
        <button type="button" class="btn_label_kobetsu" name="btn_label_kobetsu" data-app-operation="label_kobetsu">
            <!--<span class="icon"></span>-->
            <span data-app-text="btn_label_kobetsu"></span>
        </button>
         <button type="button" class="btn_label_chomieki" name="btn_label_chomieki" data-app-operation="label_chomieki">
            <!--<span class="icon"></span>-->
            <span data-app-text="btn_label_chomieki"></span>
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
                <span data-app-text="saveConfirm" class="saveConfirm" ></span>
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
    <!-- TODO: ここまで  -->
    <div class="line-dialog">
	</div>
    <div class="kobetsu-label-dialog">
	</div>
    <div class="chomieki-label-dialog">
	</div>
    <div class="insatsu-sentaku-dialog">
	</div>
    <!-- 画面デザイン -- End -->
</asp:Content>