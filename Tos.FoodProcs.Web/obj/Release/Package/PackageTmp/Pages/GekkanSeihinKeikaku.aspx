<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="GekkanSeihinKeikaku.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.GekkanSeihinKeikaku" %>

<asp:Content ID="Content1" ContentPlaceHolderID="IncludeContent" runat="server">
    <script src="<%=ResolveUrl("~/Resources/pages/pagedata-gekkanseihinkeikaku." + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
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
        
        .kakutei-confirm-dialog
        {
            background-color: White;
            width: 350px;
        }
        
        .kakutei-confirm-dialog .part-body
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
        
        .jissekidata-confirm-dialog
        {
            background-color: White;
            width: 400px;
        }
                
        .jissekidata-confirm-dialog .part-body
        {
            width: 95%;
            padding-bottom: 5px;
        }
        
        .olddateinput-confirm-dialog
        {
            background-color: White;
            width: 350px;
        }
                
        .olddateinput-confirm-dialog .part-body
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
        .ui-datepicker-calendar {
            display:none;
        }
        .not-editable-cell
        {
            color: Gray;
        }
        
        .seihin-dialog
        {
            background-color: White;
            width: 550px;
        }
        
        button.seihin-button .icon
        {
            background-position: -48px -80px;
        }
        
        .yasumi-dialog
        {
            background-color: White;
            width: 450px;
        }
        
        button.yasumi-button .icon
        {
            background-position: -48px -80px;
        }
        
        .gokei-dialog
        {
            background-color: White;
            width: 550px;
        }
        
        button.gokei-button .icon
        {
            background-position: -208px -128px;
        }
        
        .kyujitu-color
        {
            background-color: red;
        }
        
        .jisseki-body 
        {
            margin-right: 20px;
            padding-top: 5px;
            border-top: 2px double #efefef ;
        }
        
        button.reflect-button .icon
        {
            background-position: -48px -80px;
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
                isDataLoading = false;

            // グリッドコントロール固有の変数宣言
            var grid = $("#item-grid"),
                lastScrollTop = 0,
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
                changeSet = new App.ui.page.changeSet(),
                firstCol = 3,
                duplicateCol = 999,
                currentRow = 0,
                currentCol = firstCol;

            // TODO: ここまで

            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            var shokubaCode, // 検索条件のコンボボックス
                lineCode, // 検索条件のコンボボックス
                jissekiData, // 実績があるデータ変更時のチェックデータ 
                yobiHidukeId = pageLangText.yobiHidukeId.data,
                yasumiRiyuCol = 2,
                forcusCol = 4,
                seihinCodeCol = 5,
                seihinNameCol = 6,
                seizoYoteiSuCol = 8,
                batchCol = 17,
                bairitsuCol = 18,
                reflectChkCol = 19,
                unitQuantityCol = 20,   // wt_ko
            // 多言語対応にしたい項目を変数にする
                hinmeiName = 'nm_hinmei_' + App.ui.page.lang,
                isSearch = false,
                isCriteriaChange = false,
                oldDateInputCheckRow,
                oldDateOption,
                filedownload,
                fileIngterval,
                loading,
                checkedRow = new Array(),
                varidErrFlg = false;   // バリデーションエラーフラグ

            //TOsVN 17035 nt.toan 2020/04/23 Start -->
            var preLastSelectedRow,
                preUpdateControlFlg = 0;
            //TOsVN 17035 nt.toan 2020/04/23 End <--

            // 画面固有のグローバル変数定義
            // 他画面との競合を防ぐためにオブジェクトに格納する。
            var keikakuGamenObject = new Object();

            // 変更前セル情報
            keikakuGamenObject.beforeCellInfo = new Object();
            // 選択行ID
            keikakuGamenObject.beforeCellInfo.selectedRowId = null;
            // 列名称
            keikakuGamenObject.beforeCellInfo.cellName = null;
            // セルの値
            keikakuGamenObject.beforeCellInfo.value = null;
            // 行番号
            keikakuGamenObject.beforeCellInfo.iRow = null;
            // 列番号
            keikakuGamenObject.beforeCellInfo.iCol = null;
            // 行情報
            keikakuGamenObject.beforeCellInfo.rowData = null;

            // 変更前セル情報(temp)
            keikakuGamenObject.tempBeforeCellInfo = new Object();
            // 選択行ID
            keikakuGamenObject.tempBeforeCellInfo.selectedRowId = null;
            // 列名称
            keikakuGamenObject.tempBeforeCellInfo.cellName = null;
            // セルの値
            keikakuGamenObject.tempBeforeCellInfo.value = null;
            // 行番号
            keikakuGamenObject.tempBeforeCellInfo.iRow = null;
            // 列番号
            keikakuGamenObject.tempBeforeCellInfo.iCol = null;
            // 行情報
            keikakuGamenObject.tempBeforeCellInfo.rowData = null;

            // 保存フラグ(保存ボタン押下時にtrueになり、保存実行・キャンセルでfalseに戻る。)
            keikakuGamenObject.saveFlg = false
            // 実績ダイアログフラグ（実績確認ダイアログ表示中はtrue、非表示時はfalse）
            keikakuGamenObject.jissekiDlgFlg = false

            // TODO：ここまで

            // ダイアログ固有の変数宣言
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            var saveConfirmDialog = $(".save-confirm-dialog"),
                searchConfirmDialog = $(".search-confirm-dialog"),
                oldDateInputConfirmDialog = $(".olddateinput-confirm-dialog"),
            // 計画確定確認ダイアログ(更新時)
                jissekiDataConfirmDialog = $(".jissekidata-confirm-dialog"),
            // 計画確定確認ダイアログ(削除時)
                kakuteiConfirmDialog = $(".kakutei-confirm-dialog"),
                seihinDialog = $(".seihin-dialog"),
                gokeiDialog = $(".gokei-dialog"),
                yasumiDialog = $(".yasumi-dialog");
            // TODO：ここまで

            //// 変数宣言 -- End

            //// コントロール定義 -- Start

            // ダイアログ固有のコントロール定義
            saveConfirmDialog.dlg();
            searchConfirmDialog.dlg();
            oldDateInputConfirmDialog.dlg();
            // 計画確定確認ダイアログ(更新時)
            jissekiDataConfirmDialog.dlg();
            // 計画確定確認ダイアログ(削除時)
            kakuteiConfirmDialog.dlg();

            /// <summary>
            ///     計画確定確認ダイアログ表示
            ///     計画が確定している行削除時に確認ダイアログを開きます。
            /// </summary>
            var showKakuteiConfirmDialog = function () {

                kakuteiConfirmDialogNotifyInfo.clear();
                kakuteiConfirmDialog.draggable(true);
                kakuteiConfirmDialog.dlg("open");
            }

            /// <summary>画面で変更された値をセル情報に設定する。</summary>
            var preSave = function () {

                //TOsVN 17035 nt.toan 2020/04/23 Start -->
                // 明細行の選択行情報を保持
                preLastSelectedRow = getSelectedRowId(true)
                if (currentRow != preLastSelectedRow) {
                    preLastSelectedRow = currentRow;
                }
                //TOsVN 17035 nt.toan 2020/04/23 End <--
                keikakuGamenObject.saveFlg = true;

                // 対象行が存在するか確認
                var selectedRowId = getSelectedRowId(),
                    position = "after";

                if (App.isUndefOrNull(selectedRowId)) {

                    // 保存フラグをfalseに変更
                    keikakuGamenObject.saveFlg = false;
                    return;
                }

                // 情報メッセージのクリア
                App.ui.page.notifyInfo.clear();
                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();

                // 編集中の場合は、編集内容を保存する。
                if (checkEditCell()) {
                    saveEdit();

                }

                if (!keikakuGamenObject.jissekiDlgFlg) {

                    // 計画確定確認ダイアログ表示中でない場合は、保存確認ダイアログ表示処理を実行する。
                    showSaveConfirmDialog();
                }

                //if (!App.isUndefOrNull(changeCreate)) {
                //    showSaveConfirmDialog();
                //}
                //else {

                // 編集内容の保存
                //saveEdit();

                //}
                //showSaveConfirmDialog();

            };
            // -----------------------------------------------------------------------------


            /// <summary>ダイアログを開きます。</summary>
            var showSaveConfirmDialog = function () {

                // 保存フラグをfalseに変更
                keikakuGamenObject.saveFlg = false;

                // 変更セット内にバリデーションエラーがある場合は処理を抜ける
                if (!validateChangeSet()) {
                    return;
                }

                // エラーメッセージのクリア
                //App.ui.page.notifyAlert.clear();

                // 変更がない場合は処理を抜ける
                if (noChange()) {
                    App.ui.page.notifyInfo.message(pageLangText.noChange.text).show();
                    return;
                }
                // 検索条件の変更をチェック
                if (isCriteriaChange) {
                    App.ui.page.notifyAlert.message(
                         App.str.format(pageLangText.criteriaChange.text, pageLangText.searchCriteria.text, pageLangText.save.text)
                    ).show();
                    return;
                }

                saveConfirmDialogNotifyInfo.clear();
                saveConfirmDialogNotifyAlert.clear();
                jissekiDataConfirmDialogNotifyInfo.clear();
                jissekiDataConfirmDialogNotifyAlert.clear();

                // changeSet内の対象となるロットを取得
                // 変数宣言したjissekiDataに格納する
                // ＯＫの場合、nullが入る
                // getJissekiCount();

                // 按分テーブルに登録があればエラーとする
                // isValid:チェック結果。エラー時はfalseが入る。
                // lotNo:対象の製品ロット番号
                var checkInfo = { "isValid": true, "lotNo": "" };
                checkInfo = deleteCheckShiyoYojitsuAnbun(checkInfo);
                if (!checkInfo.isValid) {
                    App.ui.page.notifyAlert.message(
                        App.str.format(MS0754, checkInfo.lotNo)).show();
                    return;
                }
                saveConfirmDialog.draggable(true);
                saveConfirmDialog.dlg("open");
                //saveData();

                // changeSet内のロットが、確定/ラベル発行済みかをチェック
                //                if (!App.isUndefOrNull(jissekiData)) {
                //                    // 実績あり
                //                    // ラジオをデフォルトに戻す
                //                    $("#radio_case").prop("checked", true);
                //                    jissekiDataConfirmDialog.draggable(true);
                //                    jissekiDataConfirmDialog.dlg("open");
                //                }
                //                else {
                // 通常の確認
                //saveConfirmDialog.draggable(true);
                //saveConfirmDialog.dlg("open");
                //saveData();
                //               }
            };

            /// <summary>編集中判定処理</summary>
            var checkEditCell = function () {
                var $t = $("#item-grid")[0];
                var checkResult = true;

                if (!$t.grid || $t.p.cellEdit !== true) {
                    checkResult = false;
                }

                return checkResult;
            };

            /// <summary>仕込計画確定・ラベル発行済み判定処理</summary>
            var checkJissekiData = function (rowId) {

                var result = false;

                if (grid.getCell(rowId, "flg_shikomi") == 1
                    || grid.getCell(rowId, "flg_label") == 1
                    || grid.getCell(rowId, "flg_label_hasu") == 1) {

                    result = true;
                }

                return result;
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
            var showOldDateInputConfirmDialog = function (val, opt) {
                // 現在の選択行をチェック
                oldDateInputCheckRow = val;
                oldDateOption = opt; // ダイアログを保存
                oldDateInputConfirmDialogNotifyInfo.clear();
                oldDateInputConfirmDialogNotifyAlert.clear();
                oldDateInputConfirmDialog.draggable(true);
                oldDateInputConfirmDialog.dlg("open");
            };

            /// <summary>ダイアログを閉じます。</summary>
            var closeSaveConfirmDialog = function () {
                // 保存フラグをfalseに変更
                keikakuGamenObject.saveFlg = false;
                // ダイアログを閉じる。
                saveConfirmDialog.dlg("close");
            };

            /// <summary>仕込計画確定確認ダイアログを閉じます。</summary>
            var closeKakuteiConfirmDialog = function () {
                kakuteiConfirmDialog.dlg("close");
            };

            var closeSearchConfirmDialog = function () {
                searchConfirmDialog.dlg("close");
            };


            /// <summary> 過去日入力確認ダイアログを閉じます。[いいえ]選択時 </summary>
            var closeOldDateInputConfirmDialogNo = function () {
                // ダイアログを閉じる。
                oldDateInputConfirmDialog.dlg("close");
                // 選択セルのフォーカスを外す。
                reSelectRow(oldDateInputCheckRow, forcusCol);
            };

            /// <summary> 過去日入力確認ダイアログを閉じます。[はい]選択時 </summary>
            var closeOldDateInputConfirmDialog = function () {
                if (!App.isUndefOrNull(oldDateOption)) {
                    // ダイアログが選択されていれば、ダイアログ起動
                    switch (oldDateOption) {
                        case "yasumi":
                            openYasumiDialog();
                            break;
                        case "seihin":
                            openSeihinDialog();
                            break;
                        case "seihinCol":
                            // 一度editモードを外して、再度editさせる
                            $("#" + oldDateInputCheckRow + " > td:nth-child(" + forcusCol + ")").click();
                            grid.jqGrid('editCell', oldDateInputCheckRow, seihinCodeCol, true);
                            $("#" + oldDateInputCheckRow + " > td:eq(" + seihinCodeCol + ")").click();
                            break;
                        case "yoteiSuCol":
                            // 一度editモードを外して、再度editさせる
                            $("#" + oldDateInputCheckRow + " > td:nth-child(" + forcusCol + ")").click();
                            grid.jqGrid('editCell', oldDateInputCheckRow, seizoYoteiSuCol, true);
                            $("#" + oldDateInputCheckRow + " > td:eq(" + seizoYoteiSuCol + ")").click();
                            break;
                        case "batchCol":
                            // 一度editモードを外して、再度editさせる
                            $("#" + oldDateInputCheckRow + " > td:nth-child(" + forcusCol + ")").click();
                            grid.jqGrid('editCell', oldDateInputCheckRow, seizoYoteiSuCol, true);
                            $("#" + oldDateInputCheckRow + " > td:eq(" + batchCol + ")").click();
                            break;
                        case "bairitsuCol":
                            // 一度editモードを外して、再度editさせる
                            $("#" + oldDateInputCheckRow + " > td:nth-child(" + forcusCol + ")").click();
                            grid.jqGrid('editCell', oldDateInputCheckRow, seizoYoteiSuCol, true);
                            $("#" + oldDateInputCheckRow + " > td:eq(" + bairitsuCol + ")").click();
                            break;
                        case "reflect":
                            // editモードを外して、反映処理を行う
                            $("#" + oldDateInputCheckRow + " > td:nth-child(" + forcusCol + ")").click();
                            // ローディング
                            App.ui.loading.show(pageLangText.nowProgressing.text);
                            // C/S数の計算と反映処理
                            calcCaseReflect();
                            break;
                    }
                }
                oldDateInputConfirmDialog.dlg("close");
            };

            /// <summary>
            ///     仕込計画確定確認ダイアログ(更新時)を閉じます。
            ///     [キャンセル]選択時
            /// </summary>
            var closeAndSetJissekiDataConfirmDialog = function () {

                // 前選択行ID
                var beforeSelectedRowId = keikakuGamenObject.beforeCellInfo.selectedRowId;
                var beforeRow = keikakuGamenObject.beforeCellInfo.iRow;
                // 前選択行情報（編集前）
                var beforeCol = keikakuGamenObject.beforeCellInfo.iCol;
                // 前選択セルの値
                var beforeValue = keikakuGamenObject.beforeCellInfo.value;

                // 編集前データに戻す。
                grid.setCell(beforeRow, beforeCol, beforeValue);

                // セルのフォーカスを外す。
                reSelectRow(beforeSelectedRowId, forcusCol);

                keikakuGamenObject.saveFlg = false;

                closeJissekiDataConfirmDialog();
                // 裏側で過去日確認ダイアログが表示されていることがあるので、一緒に閉じる。
                oldDateInputConfirmDialog.dlg("close");
            };

            /// <summary>
            ///     仕込計画確定確認ダイアログ(更新時)を閉じます。
            ///     [OK]選択時
            /// </summary>
            var closeJissekiDiarog = function () {

                // ダイアログを閉じる。
                closeJissekiDataConfirmDialog();

                var select = $(".jissekidata-confirm-dialog").toJSON().radio_jisseki;
                // 変更データの変数設定
                var changeData;
                // ダイアログ表示時の選択行IDを取得する。
                var selectedRowId = keikakuGamenObject.beforeCellInfo.selectedRowId;

                // チェンジセットにセット（すべてCreated)
                // 追加状態のデータ設定
                changeData = setCreatedChangeData(grid.getRowData(selectedRowId));
                changeData.henkozumi_data = select;
                // 追加状態の変更セットに変更データを追加
                changeSet.addCreated(selectedRowId, changeData);

                if (keikakuGamenObject.saveFlg) {

                    // 保存ボタン押下時は保存確認ダイアログを表示する。
                    showSaveConfirmDialog();
                }

            };

            /// <summary>
            ///     仕込計画確定確認ダイアログ(更新時)を閉じます。
            /// </summary>
            var closeJissekiDataConfirmDialog = function () {
                keikakuGamenObject.jissekiDlgFlg = false;
                jissekiDataConfirmDialog.dlg("close");
            };

            // var reSelectRow = function () {
            //     oldDateInputConfirmDialog.dlg("close");
            //     // ダイアログを閉じるときに、対象セルからのフォーカスを外す
            //     $("#" + oldDateInputCheckRow + " > td:nth-child(" + forcusCol + ")").click();
            // };

            /// <summary> 行再選択処理 </summary>
            /// <param name="rowId">選択行ID</param>
            /// <param name="iCol">選択列番号</param>
            var reSelectRow = function (rowId, iCol) {
                // 対象セルからのフォーカスを外す。
                $("#" + rowId + " > td:nth-child(" + iCol + ")").click();
            };

            // 製品ダイアログ生成
            seihinDialog.dlg({
                url: "Dialog/HinmeiDialog.aspx",
                name: "HinmeiDialog",
                closed: function (e, data, data2) {
                    if (data == "canceled") {
                        return;
                    }
                    else {
                        var selectedRowId = getSelectedRowId(false);
                        grid.setCell(selectedRowId, "cd_hinmei", data);
                        grid.setCell(selectedRowId, hinmeiName, data2);

                        setRelatedHinCodeValue(selectedRowId, data);
                        //validateCell(selectedRowId, hinmeiName, grid.getCell(selectedRowId, seihinNameCol), seihinNameCol);
                        validateCell(selectedRowId, "wt_ko", grid.getCell(selectedRowId, unitQuantityCol), unitQuantityCol);
                        // 更新状態の変更セットに変更データを追加
                        var changeData = setCreatedChangeData(grid.getRowData(selectedRowId));
                        changeSet.addCreated(selectedRowId, changeData);
                        //changeSet.addUpdated(selectedRowId, "cd_hinmei", data.cd_hinmei, changeData);
                    }
                }
            });

            // 合計ダイアログ生成
            gokeiDialog.dlg({
                url: "Dialog/GokeiHyojiDialog.aspx",
                name: "GokeiHyojiDialog",
                closed: function (e, data, data2) {
                    return;
                }
            });

            // 休みダイアログ生成
            yasumiDialog.dlg({
                url: "Dialog/YasumiSentakuDialog.aspx",
                name: "YasumiSentakuDialog",
                closed: function (e, data, data2) {
                    if (data == "canceled") {
                        return;
                    }
                    else {
                        var selectedRowId = getSelectedRowId(false);
                        // 休日をセットした日付を取得
                        var key = grid.getCell(selectedRowId, "dt_seizo");

                        //if (data != pageLangText.kyujitsuKaijyo.text) {
                        grid.setCell(selectedRowId, "nm_riyu", '', { color: '#FF0000' });
                        // 休日が設定された場合は、changesetにダミーデータをいれ、バリデーション回避
                        // 製品と実績数を入れる

                        // 複数ラインにある場合を想定し、対象となるラインすべてに休日をセット
                        var ids = grid.jqGrid('getDataIDs');
                        for (var i = 0; i < ids.length; i++) {
                            var id = ids[i];
                            var dt = grid.getCell(id, "dt_seizo");
                            if (key === dt) {
                                grid.setCell(id, "cd_riyu", data);
                                grid.setCell(id, "nm_riyu", data2);
                                // 休日解除以外は、文字色を赤にする。操作可否を変更する
                                var cellcolor,
                                    celledit,
                                    isKaijyo = data == pageLangText.kyujitsuKaijyo.text;
                                if (isKaijyo) {
                                    // 解除選択時
                                    cellcolor = '#000000';
                                    grid.jqGrid('setCell', id, "nm_riyu", '', { color: cellcolor });
                                    var tr = grid[0].rows.namedItem(id),
                                        seihintd = tr.cells[seihinCodeCol],
                                        yoteisutd = tr.cells[seizoYoteiSuCol],
                                        batch = tr.cells[batchCol],
                                        reflect = tr.cells[reflectChkCol];

                                    //編集不可を解除しないようにする
                                    //$(seihintd).removeClass('not-editable-cell');
                                    //$(yoteisutd).removeClass('not-editable-cell');
                                    //$(batch).removeClass('not-editable-cell');
                                    //$(reflect).removeClass('not-editable-cell');

                                    //編集不可設定付与(製品コード、製造予定数、バッチ数、反映チェックボックス、倍率）
                                    grid.jqGrid('setCell', id, 'cd_hinmei', '', 'not-editable-cell')
                                        .jqGrid('setCell', id, 'su_seizo_yotei', '', 'not-editable-cell')
                                        .jqGrid('setCell', id, 'su_batch_keikaku', '', 'not-editable-cell')
                                        .jqGrid('setCell', id, 'check_reflect', '', 'not-editable-cell')
                                        .jqGrid('setCell', id, 'ritsu_kihon', '', 'not-editable-cell');

                                    // 解除を選択したとき、対象行のデータが削除対象にあれば、消す
                                }
                                else {
                                    // 休日選択時
                                    cellcolor = '#FF0000';
                                    // 値セット
                                    grid.jqGrid('setCell', id, "nm_riyu", '', { color: cellcolor })
                                        .jqGrid('setCell', id, 'cd_hinmei', '', 'not-editable-cell')
                                        .jqGrid('setCell', id, 'su_seizo_yotei', '', 'not-editable-cell')
                                        .jqGrid('setCell', id, 'su_batch_keikaku', '', 'not-editable-cell')
                                        .jqGrid('setCell', id, 'check_reflect', '', 'not-editable-cell');

                                    var lotNo = (grid.getCell(id, "no_lot_seihin"));
                                    // 変更データを取得
                                    var changeData = setCreatedChangeData(grid.getRowData(id));
                                    // 選択した行にすでに製品ロットがあれば、削除対象に入れる
                                    // if (!App.isUndefOrNull(lotNo)) {
                                    if (!App.isUndefOrNull(lotNo) && lotNo !== "") {
                                        changeSet.addDeleted(id, changeData);
                                    }

                                    // 表示値をクリア
                                    grid.setCell(id, "cd_hinmei", null)
                                        .setCell(id, hinmeiName, null)
                                        .setCell(id, "su_seizo_yotei", null)
                                        .setCell(id, "su_seizo_jisseki", null)
                                        .setCell(id, "no_lot_seihin", null)
                                        .setCell(id, "nm_nisugata_hyoji", null)
                                        .setCell(id, "su_batch_keikaku", null)
                                        .setCell(id, "ritsu_keikaku", null)
                                        .setCell(id, "check_reflect", "0");
                                }

                                // 変更データを取得
                                var changeData = setCreatedChangeData(grid.getRowData(id));
                                // 更新状態の変更セットに変更データを追加
                                changeSet.addCreated(id, changeData);
                            }
                        }
                    }
                }
            });

            // TODO：画面の仕様に応じて以下の datepicker の設定を変更してください。
            $(".search-criteria [name='dt_hiduke_search']").datepicker({
                changeMonth: true,
                changeYear: true,
                //maxDate: "+3Y",
                //minDate: "-3Y",
                showButtonPanel: true,
                dateFormat: pageLangText.yearMonthFormat.text,
                onClose: function (dateText, inst) {
                    criteriaChange();
                    var month,
                        year;
                    if (inst.lastVal != dateText) {
                        //if (/^[0-9]{4}\/[0-9]{2}$/.test(dateText)) {  // en版で正常に動作しない為コメントアウト
                        if (App.ui.page.lang == "en") {
                            // 英語圏はmm/yyyy
                            month = dateText.split("/")[0] - 1;
                            year = dateText.split("/")[1];
                        }
                        else {
                            // en以外(日本、中国)はyyyy/mm
                            month = dateText.split("/")[1] - 1;
                            year = dateText.split("/")[0];
                        }
                        $(this).datepicker('option', 'defaultDate', new Date(year, month, 1));
                        $(this).datepicker('setDate', new Date(year, month, 1));
                        //}
                    }
                    else {
                        month = $("#ui-datepicker-div .ui-datepicker-month :selected").val();
                        year = $("#ui-datepicker-div .ui-datepicker-year :selected").val();
                        $(this).datepicker('option', 'defaultDate', new Date(year, month, 1));
                        $(this).datepicker('setDate', new Date(year, month, 1));
                    }
                    var res = $(".part-body .item-list").validation().validate();
                }
            });
            // TODO：ここまで

            // グリッドコントロール固有のコントロール定義
            grid.jqGrid({
                // TODO：画面の仕様に応じて以下の列名の定義を変更してください。
                colNames: [
                    pageLangText.cd_riyu.text, pageLangText.nm_riyu.text,
                    pageLangText.dt_seizo.text, pageLangText.dt_seizo_yobi.text, pageLangText.cd_hinmei.text + pageLangText.requiredMark.text,
                    pageLangText.nm_hinmei.text, pageLangText.nm_nisugata.text, pageLangText.su_seizo_yotei.text + pageLangText.requiredMark.text,
                    // TOsVN - 20089 trung.nq - add su_seizo_yotei old value
                    "hidden",
                    // END - add su_seizo_yotei old value ------------------
                    pageLangText.su_seizo_jisseki.text, pageLangText.blank.text, pageLangText.blank.text,
                    pageLangText.blank.text, pageLangText.blank.text, pageLangText.no_lot_seihin.text,
                    pageLangText.blank.text
                    , pageLangText.batch.text
                    , pageLangText.bairitsu.text
                    , pageLangText.check_reflect.text
                    , "hidden"
                    , "hidden"
                    , "hidden"
                    , "hidden"
                    , "hidden"
                // 製造実績フラグ
                    , "hidden"
                // 仕込実績フラグ
                    , "hidden"
                // 仕込計画確定フラグ
                    , "hidden"
                // ラベル発行済みフラグ
                    , "hidden"
                // 端数ラベル発行済みフラグ
                    , "hidden"
                // 更新日時
                    , pageLangText.blank.text
                ],
                // TODO：ここまで
                // TODO：画面の仕様に応じて以下の列モデルの定義を変更してください。
                colModel: [
                    { name: 'cd_riyu', width: 60, hidden: true, hidedlg: true },
                    { name: 'nm_riyu', width: pageLangText.nm_hinmei_width.number, editable: false },
                    { name: 'dt_seizo', width: pageLangText.dt_seizo_width.number, editable: false, align: "center",
                        formatter: "date",
                        formatoptions: {
                            srcformat: pageLangText.dateTimeNewFormat.text, newformat: pageLangText.dateDDFormat.text
                        }
                    },
                    { name: 'dt_seizo_yobi', width: pageLangText.dt_seizo_yobi_width.number, editable: false, align: "center",
                        formatter: "date",
                        formatoptions: {
                            srcformat: pageLangText.dateTimeNewFormat.text, newformat: pageLangText.dateDayFormat.text
                        }
                    },
                    { name: 'cd_hinmei', width: pageLangText.cd_hinmei_width.number, editable: true, align: "left" },
                    { name: hinmeiName, width: pageLangText.nm_hinmei_width.number, editable: false },
                    { name: 'nm_nisugata_hyoji', width: pageLangText.nm_nisugata_hyoji_width.number, editable: false },
                    { name: 'su_seizo_yotei', width: pageLangText.su_seizo_yotei_width.number, editable: true, align: "right", sorttype: "float",
                        formatter: 'number',
                        formatoptions: {
                            decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 0, defaultValue: ""
                        }
                    },
                    // TOsVN - 20089 trung.nq - add su_seizo_yotei old value
                    // --------------- START -----------------------
                    {
                        name: 'su_seizo_yotei_old', width: pageLangText.su_seizo_yotei_width.number, editable: true, align: "right", sorttype: "float", hidden: true, hidedlg: true,
                        formatter: 'number',
                        formatoptions: {
                            decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 0, defaultValue: ""
                        }
                    },
                    // ---------------- END ------------------------

                    { name: 'su_seizo_jisseki', width: pageLangText.su_seizo_jisseki_width.number, editable: false, align: "right", sorttype: "float",
                        formatter: 'number',
                        formatoptions: {
                            decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 0, defaultValue: ""
                        }
                    },
                    { name: 'dt_seizo_hidden', hidden: true, hidedlg: true },
                    { name: 'flg_kyujitsu', hidden: true, hidedlg: true },
                    { name: 'cd_line_search', hidden: true, hidedlg: true },
                    { name: 'cd_shokuba_search', hidden: true, hidedlg: true },
                    { name: 'no_lot_seihin', hidden: true },
                    { name: 'id', hidden: true, hidedlg: true, key: true }
                    , { name: 'su_batch_keikaku', hidden: false, hidedlg: false, width: 100,
                        editable: true, sorttype: "text", align: 'right',
                        formatter: 'number',
                        formatoptions: {
                            decimalSeparator: ".", thousandsSeparator: "", decimalPlaces: 0, defaultValue: ""
                        }
                    }
                    , { name: 'ritsu_kihon', hidden: false, hidedlg: false, width: 100,
                        editable: true, sorttype: "text", align: 'right',
                        formatter: 'number',
                        formatoptions: {
                            decimalSeparator: ".", thousandsSeparator: "", decimalPlaces: 2, defaultValue: ""
                        }
                    }
                    , { name: 'check_reflect', hidden: false, hidedlg: false, width: 110, edittype: 'checkbox',
                        align: 'center', editoptions: { value: "1:0" }, formatter: 'checkbox',
                        formatoptions: { disabled: false }, classes: 'not-editable-cell'
                    }
                    , { name: 'wt_ko', hidden: true, hidedlg: true }
                    , { name: 'su_iri', hidden: true, hidedlg: true }
                    , { name: 'cd_haigo', hidden: true, hidedlg: true }
                    , { name: 'wt_haigo_gokei', hidden: true, hidedlg: true }
                    , { name: 'haigo_budomari', hidden: true, hidedlg: true }
                // 製造実績フラグ
                    , { name: 'flg_seihin_jisseki', hidden: true, hidedlg: true }
                // 仕込実績フラグ
                    , { name: 'flg_shikakari_jisseki', hidden: true, hidedlg: true }
                // 仕込計画確定フラグ
                    , { name: 'flg_shikomi', hidden: true, hidedlg: true }
                // ラベル発行済みフラグ
                    , { name: 'flg_label', hidden: true, hidedlg: true }
                // 端数ラベル発行済みフラグ
                    , { name: 'flg_label_hasu', hidden: true, hidedlg: true }
                // 更新日時
                    , { name: 'dt_update', hidden: true, hidedlg: true }
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
                loadonce: true,
                onSortCol: function () {
                    grid.setGridParam({ rowNum: grid.getGridParam("records") });
                },
                loadComplete: function () {
                    // 変数宣言
                    var ids = grid.jqGrid('getDataIDs');
                    // TODO：ここから
                    // 過去分は操作不可
                    for (var i = 0; i < ids.length; i++) {
                        var id = ids[i];
                        // TOsVN - 20089 trung.nq - add su_seizo_yotei old value
                        // --------------- START -----------------------
                        grid.jqGrid('setCell', id, 'su_seizo_yotei_old', grid.getCell(id, "su_seizo_yotei"), 'not-editable-cell');
                        // ---------------- END ------------------------

                        //if (!App.isUndefOrNull(grid.getCell(id, "cd_hinmei")) && grid.getCell(id, "cd_hinmei").length > 0) {
                        if (!App.isUndefOrNull(grid.getCell(id, "no_lot_seihin")) && grid.getCell(id, "no_lot_seihin").length > 0) {
                            grid.jqGrid('setCell', id, 'cd_hinmei', '', 'not-editable-cell');
                        }
                        // 年間カレンダマスタの休み
                        if (pageLangText.seihinHinKbn.text == grid.getCell(id, "flg_kyujitsu")) {
                            grid.toggleClassRow(this.rows[i + 1].id, "kyujitsuColor");
                        }

                        // 製造実績・仕込実績あり
                        if (grid.getCell(id, "flg_seihin_jisseki") == 1
                            || grid.getCell(id, "flg_shikakari_jisseki") == 1) {

                            // 製造数を編集不可にする。
                            grid.jqGrid('setCell', id, 'su_seizo_yotei', '', 'not-editable-cell');
                            // バッチ数を編集不可にする。
                            grid.jqGrid('setCell', id, 'su_batch_keikaku', '', 'not-editable-cell');
                        }

                        // 休日計画トランの休み
                        if (grid.getCell(id, "cd_riyu") != "") {
                            // コード、製造数、バッチ数、反映対象を入力できなくする
                            grid.jqGrid('setCell', id, 'cd_hinmei', '', 'not-editable-cell')
                                .jqGrid('setCell', id, 'su_seizo_yotei', '', 'not-editable-cell')
                                .jqGrid('setCell', id, 'su_batch_keikaku', '', 'not-editable-cell')
                                .jqGrid('setCell', id, 'check_reflect', '', 'not-editable-cell');
                            // 文字色を赤にする
                            grid.setCell(id, "nm_riyu", '', { color: '#FF0000' });
                        }
                        //倍率を操作不可に変更
                        grid.jqGrid('setCell', id, 'ritsu_kihon', '', 'not-editable-cell');
                        // TODO：ここまで
                    }
                    //TOsVN 17035 nt.toan 2020/04/23 Start -->
                    // 選択行情報を保持している場合、該当する行を選択状態に変更
                    if (preLastSelectedRow != undefined) {
                        var ids = grid.getDataIDs()
                        , recordCount = grid.getGridParam("records");
                        // 選択行より取得件数が少ない場合、最終行を選択状態に変更
                        if (preLastSelectedRow > recordCount) {
                            preLastSelectedRow = recordCount;
                        }
                        $("#" + preLastSelectedRow, grid).focus();
                        grid.editCell(preLastSelectedRow, 1, true);
                        preUpdateControlFlg = 1;

                    }
                    //TOsVN 17035 nt.toan 2020/04/23 End <--
                    // TODO：ここまで
                },
                beforeEditCell: function (selectedRowId, cellName, value, iRow, iCol) {
                    currentRow = iRow;
                    currentCol = iCol;

                    // 選択行ID
                    keikakuGamenObject.tempBeforeCellInfo.selectedRowId = selectedRowId;
                    // 列名称
                    keikakuGamenObject.tempBeforeCellInfo.cellName = cellName;
                    // セルの値
                    keikakuGamenObject.tempBeforeCellInfo.value = value;
                    // 行番号
                    keikakuGamenObject.tempBeforeCellInfo.iRow = iRow;
                    // 列番号
                    keikakuGamenObject.tempBeforeCellInfo.iCol = iCol;
                    // 行情報
                    keikakuGamenObject.tempBeforeCellInfo.rowData = grid.getRowData(selectedRowId);

                    // 過去日付チェック（数量、製品コード選択時）
                    if (iCol === seihinCodeCol) {
                        isEditOldDateInfo(getSelectedRowId(), "seihinCol");
                    }
                    else if (iCol === seizoYoteiSuCol) {
                        isEditOldDateInfo(getSelectedRowId(), "yoteiSuCol");
                    }
                    else if (iCol === batchCol) {
                        isEditOldDateInfo(getSelectedRowId(), "batchCol");
                    }
                    else if (iCol === bairitsuCol) {
                        isEditOldDateInfo(getSelectedRowId(), "bairitsuCol");
                    }
                },
                afterEditCell: function (selectedRowId, cellName, value, iRow, iCol) {
                    // Enter キーでカーソルを移動
                    grid.moveCell(cellName, iRow, iCol);
                },
                beforeSaveCell: function (selectedRowId, cellName, value, iRow, iCol) {

                    // セルバリデーション
                    //validateCell(selectedRowId, cellName, value, iCol);
                    if (!validateCell(selectedRowId, cellName, value, iCol)) {
                        // バリデーションエラーの場合、バリデーションエラーフラグを立てる
                        varidErrFlg = true;
                    }
                },
                afterSaveCell: function (selectedRowId, cellName, value, iRow, iCol) {

                    // 選択行ID
                    keikakuGamenObject.beforeCellInfo.selectedRowId = keikakuGamenObject.tempBeforeCellInfo.selectedRowId;
                    // 列名称
                    keikakuGamenObject.beforeCellInfo.cellName = keikakuGamenObject.tempBeforeCellInfo.cellName;
                    // セルの値
                    keikakuGamenObject.beforeCellInfo.value = keikakuGamenObject.tempBeforeCellInfo.value;
                    // 行番号
                    keikakuGamenObject.beforeCellInfo.iRow = keikakuGamenObject.tempBeforeCellInfo.iRow;
                    // 列番号
                    keikakuGamenObject.beforeCellInfo.iCol = keikakuGamenObject.tempBeforeCellInfo.iCol;
                    // 行情報
                    keikakuGamenObject.beforeCellInfo.rowData = keikakuGamenObject.tempBeforeCellInfo.rowData;

                    if (!varidErrFlg) {
                        // バリデーションエラーが発生していない場合
                        // 関連項目の設定
                        if (iCol === seihinCodeCol) {
                            setRelatedHinCodeValue(selectedRowId, value);
                            validateCell(selectedRowId, "wt_ko", grid.getCell(selectedRowId, unitQuantityCol), unitQuantityCol);
                        }

                        // 変更された対象セルを持つレコードの実績チェック
                        if (checkEditCell() && checkJissekiData(selectedRowId)) {

                            // 編集セル且つ、仕込計画確定済みの場合は確認ダイアログを表示する。
                            showJissekiDataConfirmDialog();

                        }
                        else {

                            // 変更データの変数設定
                            var changeData;
                            // チェンジセットにセット（すべてCreated)
                            // 追加状態のデータ設定
                            changeData = setCreatedChangeData(grid.getRowData(selectedRowId));
                            // 追加状態の変更セットに変更データを追加
                            changeSet.addCreated(selectedRowId, changeData);

                        }

                    } else {

                        // バリデーションエラー時はリストアする。
                        grid.restoreCell(iRow, iCol);
                    }

                    // バリデーションエラーフラグの初期化
                    varidErrFlg = false;
                },
                onCellSelect: function (rowid, icol, cellcontent) {
                    selectCol = icol;
                },
                ondblClickRow: function (rowid) {
                    var riyuCd = grid.getCell(rowid, "cd_riyu");
                    var flg_check = 0;

                    // 削除データか更新データかを区別する。更新＝true。
                    var henkouFlg = true;

                    // 選択行データの実績チェック
                    flg_check = checkKakutei(rowid);

                    if (selectCol != yasumiRiyuCol
                        && riyuCd != ""
                        && riyuCd != pageLangText.kyujitsuKaijyo.text) {
                        // 解除以外の理由区分が入っている場合、入力できないことを促す
                        if (selectCol === seihinCodeCol || selectCol === seihinNameCol || selectCol === seizoYoteiSuCol || selectCol === bairitsuCol) {
                            App.ui.page.notifyInfo.message(MS0125).show();
                        }
                    }
                    else {
                        //var isCdEditalbe = $(this).getColProp("cd_hinmei").editable;
                        if (selectCol === seihinCodeCol || selectCol === seihinNameCol) {
                            // 製品一覧（品名セレクタ起動）
                            var tr = grid[0].rows.namedItem(rowid),
                            seihintd = tr.cells[seihinCodeCol];
                            var hasNotEditClass = $(seihintd).hasClass('not-editable-cell');
                            if (hasNotEditClass == false) {
                                // 過去日確認：コードはクリック時にチェックしているので不要
                                if (selectCol === seihinNameCol) {
                                    if (isEditOldDateInfo(getSelectedRowId(), "seihin")) {
                                        $("#" + rowid).removeClass("ui-state-highlight").find("td:nth-child(" + forcusCol + ")").click();    // 行選択
                                        openSeihinDialog();
                                    }
                                }
                                else {
                                    $("#" + rowid).removeClass("ui-state-highlight").find("td:nth-child(" + forcusCol + ")").click();    // 行選択
                                    openSeihinDialog();
                                }
                            }
                        }
                        else if (selectCol === yasumiRiyuCol) {// && hasNotEditClass == false) {
                            // 休みダイアログ
                            $("#" + rowid).removeClass("ui-state-highlight").find("td").click();    // 行選択
                            if (isEditOldDateInfo(getSelectedRowId(), "yasumi")) {
                                openYasumiDialog();
                            }
                        }
                        // 製造数またはバッチ数がダブルクリックされた場合
                        else if (selectCol === seizoYoteiSuCol || selectCol === batchCol) {

                            // インフォメーション選択して表示する。
                            showInfoMsg(flg_check, henkouFlg);

                        }
                        // 倍率がダブルクリックされ、休日解除が設定されていない場合
                        else if (selectCol === bairitsuCol && riyuCd != pageLangText.kyujitsuKaijyo.text) {
                            // 倍率を編集可能にする
                            grid.deleteColumnClass(rowid, 'ritsu_kihon', 'not-editable-cell');
                        }
                    }
                }
            });

            /// <summary>セルの関連項目を設定します。</summary>
            /// <param name="selectedRowId">選択行ID</param>
            /// <param name="value">品コード</param>
            var setRelatedHinCodeValue = function (selectedRowId, value) {
                // 手入力時は名称も取得
                // 行データを取得する
                var data = grid.getRowData(selectedRowId),
                    hinmei;
                var seizoDate = App.data.getDateTimeStringForQueryNoUtc(App.data.getDate(data.dt_seizo_hidden));

                App.deferred.parallel({
                    // ローディング
                    loading: App.ui.loading.show(pageLangText.nowProgressing.text),
                    // 品名を取得
                    hinmei: App.ajax.webgetSync(App.data.toWebAPIFormat(
                                            { url: "../api/YukoHaigoMeiSeizoLine"
                                                , cd_hinmei: value
                                                , dt_seizo: seizoDate
                                                , flg_mishiyo: pageLangText.falseFlg.text
                                                , cd_line: data.cd_line_search
                                                , kbn_master: pageLangText.hinmeiMasterSeizoLineMasterKbn.text
                                            }))
                }).done(function (result) {
                    ///// サービス呼び出し成功時の処理
                    var uniqueSeihinCd = selectedRowId + "_" + seihinCodeCol;
                    hinmei = result.successes.hinmei.d;
                    // 製造数、実績数、バッチ数、反映チェックをクリアする
                    grid.setCell(selectedRowId, 'su_seizo_yotei', null);
                    grid.setCell(selectedRowId, 'su_seizo_jisseki', null);
                    grid.setCell(selectedRowId, 'su_batch_keikaku', null);
                    grid.setCell(selectedRowId, 'check_reflect', pageLangText.falseFlg.text);
                    // エラーメッセージ解除
                    //App.ui.page.notifyAlert.remove(uniqueSeihinCd);

                    if (App.isUndefOrNull(hinmei[0])) {
                        // 品名コード未登録の場合、名称、荷姿、倍率、合計配合重量をクリアする
                        grid.setCell(selectedRowId, hinmeiName, null);
                        grid.setCell(selectedRowId, 'nm_nisugata_hyoji', null);
                        grid.setCell(selectedRowId, 'ritsu_kihon', null);
                        grid.setCell(selectedRowId, 'wt_haigo_gokei', null);
                        grid.setCell(selectedRowId, 'su_iri', null);
                        grid.setCell(selectedRowId, 'wt_ko', null);
                        grid.setCell(selectedRowId, 'haigo_budomari', null);
                        // エラーメッセージ
                        //App.ui.page.notifyAlert.message(MS0122, uniqueSeihinCd).show();
                        //grid.setCell(selectedRowId, seihinCodeCol, value, { background: '#ff6666' });
                    }
                    else {
                        // ========== 取得できた場合
                        // 品名と荷姿と倍率と合計配合重量の設定
                        var res = result.successes.hinmei.d[0];
                        grid.setCell(selectedRowId, hinmeiName, res[hinmeiName]);
                        grid.setCell(selectedRowId, 'nm_nisugata_hyoji', res['nm_nisugata_hyoji']);
                        grid.setCell(selectedRowId, 'ritsu_kihon', res['ritsu_kihon']);
                        grid.setCell(selectedRowId, 'wt_haigo_gokei', res['wt_haigo_gokei']);
                        grid.setCell(selectedRowId, 'su_iri', res['su_iri']);
                        grid.setCell(selectedRowId, 'wt_ko', res['wt_ko']);
                        grid.setCell(selectedRowId, 'haigo_budomari', res['haigo_budomari']);
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
                }).always(function () {
                    // ローディングの終了
                    App.ui.loading.close();
                });
            };

            /// 操作時の日付判定
            var isEditOldDateInfo = function (selRow, dlg) {
                var date = App.data.getDate(grid.getCell(selRow, "dt_seizo_hidden"));
                date = App.data.getDateTimeStringForQueryNoUtc(App.date.localDate(date));
                if (isOlderDate(date)) {
                    // 過去日付なら確認
                    showOldDateInputConfirmDialog(selRow, dlg);
                    return false;
                }
                return true;
            };

            /// 日付比較
            /// <param name="date">比較日付</param>
            /// <return>結果(frue/false)
            var isOlderDate = function (date) {
                var today = App.data.getDateTimeStringForQueryNoUtc(App.date.localDate(new Date(), true));
                return date < today;
            };

            /// <summary>ラインコンボ事前データロード</summary>
            /// <param name="shokubaCode">職場コード</param>
            var setLineComboData = function (shokubaCode, noParam, paramLineCode) {
                App.deferred.parallel({
                    // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
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
                    App.ui.appendOptions(lineTarget, "cd_line", "nm_line", lineCode, false);
                    if (!noParam) {
                        $(".search-criteria [name='lineCode']").val(paramLineCode);
                        findData();
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

            //// 検索処理 -- Start

            // 画面アーキテクチャ共通の検索処理

            /// <summary>クエリオブジェクトの設定</summary>
            var queryWeb = function () {
                var criteria = $(".search-criteria").toJSON();
                var query = {
                    // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                    url: "../api/GekkanSeihinKeikaku",
                    // TODO: ここまで
                    // TODO: 画面の仕様に応じて以下の検索条件を変更してください。
                    cd_shokuba: criteria.shokubaCode,
                    cd_line: criteria.lineCode,
                    cd_riyu: pageLangText.kyujitsuRiyuKbn.text,
                    flg_mishiyo: pageLangText.shiyoMishiyoFlg.text,
                    dt_hiduke_from: getFromFirstDateStringForQuery(criteria.dt_hiduke_search),
                    dt_hiduke_to: getFromLastDateStringForQuery(criteria.dt_hiduke_search),
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
                App.ui.loading.show(pageLangText.nowProgressing.text);
                $("#list-loading-message").text(
                    App.str.format(
                        pageLangText.nowListLoading.text,
                        querySetting.skip + 1,
                        querySetting.top
                    )
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
                        //TOsVN 17035 nt.toan 2020/04/23 Start -->
                        // 保存処理の場合は選択行情報の初期化を行わない
                        if (preUpdateControlFlg == 1 && preLastSelectedRow != undefined) {
                            preLastSelectedRow = undefined;
                            preUpdateControlFlg = 0;
                        }
                        //TOsVN 17035 nt.toan 2020/04/23 End <--
                        // グリッドの先頭行選択
                        var idNum = grid.getGridParam("selrow");
                        if (idNum == null) {
                            $("#1 > td:nth-child(" + forcusCol + ")").click();
                        }
                        else {
                            $("#" + idNum).removeClass("ui-state-highlight").find("td:nth-child(" + forcusCol + ")").click();
                        }
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
                    }, 1000);
                    App.ui.loading.close();
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

            /// 実績数の取得
            var getJissekiCount = function () {

                App.ui.loading.show(pageLangText.nowSaving.text);
                var url = "../api/GekkanSeihinKeikakuJisseki";

                // 対象となるロットが可変のため、GETでなくPOSTで検索を実施
                App.ajax.webpostSync(
                // WCF Data ServicesのODataシステムクエリオプションを生成
                //App.data.toWebAPIFormat(queryJisseki)
                    url, getPostData()
                ).done(function (result) {
                    // 成功の場合は、対象のデータなしのため、特に何もしない
                    jissekiData = null;
                }).fail(function (result) {
                    // 失敗の場合は、返却に対象データが返ってくるため、内容を取り出し、件数返却
                    jissekiData = JSON.parse(result.rawText);
                }).always(function () {
                    // ローディングの終了
                    App.ui.loading.close();
                });
            };

            //// 検索処理 -- End

            //// 事前データロード -- Start 

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
                var shokubaTarget = $("#shokubaComBoxId");
                App.ui.appendOptions(shokubaTarget, "cd_shokuba", "nm_shokuba", shokubaCode, false);
                // URLのクエリ文字列で検索条件が指定された場合はその条件で検索
                var parameters = getParameters();
                var noParam = App.isUnusable(parameters["dt_hiduke_search"]);
                if (!noParam) {
                    $("#shokubaComBoxId").val(parameters["shokubaCode"]);
                }

                // 検索用ドロップダウンの設定
                if (result.successes.shokubaCode.d.length > 0) {
                    // URLにあった場合は、その職場をセット
                    if (!noParam) {
                        setLineComboData(parameters["shokubaCode"], noParam, parameters["lineCode"]);
                    }
                    else {
                        setLineComboData(shokubaCode[0].cd_shokuba, true, "");
                    }
                }
                // 当日日付を挿入
                $("#id_dt_hiduke_search").on("keyup", App.data.addSlashForMonthString);
                if (!noParam) {
                    var dt_search = App.date.localDate(parameters["dt_hiduke_search"]);
                    $("#id_dt_hiduke_search").datepicker("setDate", dt_search);
                    //$("#id_dt_hiduke_search").datepicker("setDate", new Date(parameters["dt_hiduke_search"]));

                }
                else {
                    $("#id_dt_hiduke_search").datepicker("setDate", new Date());
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
            // 日付確認ダイアログ情報メッセージの設定
            var oldDateInputConfirmDialogNotifyInfo = App.ui.notify.info(oldDateInputConfirmDialog, {
                container: ".olddateinput-confirm-dialog .olddialog-slideup-area .info-message",
                messageContainerQuery: "ul",
                show: function () {
                    oldDateInputConfirmDialog.find(".info-message").show();
                },
                clear: function () {
                    oldDateInputConfirmDialog.find(".info-message").hide();
                }
            });
            var oldDateInputConfirmDialogNotifyAlert = App.ui.notify.alert(oldDateInputConfirmDialog, {
                container: ".olddateinput-confirm-dialog .olddialog-slideup-area .alert-message",
                messageContainerQuery: "ul",
                show: function () {
                    oldDateInputConfirmDialog.find(".alert-message").show();
                },
                clear: function () {
                    oldDateInputConfirmDialog.find(".alert-message").hide();
                }
            });
            //　実績データダイアログメッセージの設定
            var jissekiDataConfirmDialogNotifyInfo = App.ui.notify.info(jissekiDataConfirmDialog, {
                container: ".jissekidata-confirm-dialog .olddialog-slideup-area .info-message",
                messageContainerQuery: "ul",
                show: function () {
                    jissekiDataConfirmDialog.find(".info-message").show();
                },
                clear: function () {
                    jissekiDataConfirmDialog.find(".info-message").hide();
                }
            });
            var jissekiDataConfirmDialogNotifyAlert = App.ui.notify.alert(jissekiDataConfirmDialog, {
                container: ".jissekidata-confirm-dialog .dialog-slideup-area .alert-message",
                messageContainerQuery: "ul",
                show: function () {
                    jissekiDataConfirmDialog.find(".alert-message").show();
                },
                clear: function () {
                    jissekiDataConfirmDialog.find(".alert-message").hide();
                }
            });
            // 仕込計画確定確認ダイアログ情報(削除時)メッセージの設定
            var kakuteiConfirmDialogNotifyInfo = App.ui.notify.info(kakuteiConfirmDialog, {
                container: ".kakutei-confirm-dialog .dialog-slideup-area .info-message",
                messageContainerQuery: "ul",
                show: function () {
                    kakuteiConfirmDialog.find(".info-message").show();
                },
                clear: function () {
                    kakuteiConfirmDialog.find(".info-message").hide();
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
            var setAddData = function (row) {
                // TODO: 画面の仕様に応じて以下の項目を変更してください。
                var addData = {
                    "cd_riyu": row.cd_riyu,
                    "nm_riyu": row.nm_riyu,
                    "dt_seizo": row.dt_seizo_hidden,
                    "dt_seizo_yobi": row.dt_seizo_hidden,
                    "dt_seizo_hidden": row.dt_seizo_hidden,
                    "cd_hinmei": "",
                    "hinmeiName": "",
                    "nm_nisugata": "",
                    "su_seizo_yotei": "",
                    "su_seizo_jisseki": "",
                    "flg_kyujitsu": 0,
                    "cd_line_search": row.cd_line_search,
                    "cd_shokuba_search": row.cd_shokuba_search,
                    "id": App.uuid(),
                    "su_batch_keikaku": ""
                };
                // TODO: ここまで
                return addData;
            };
            /// <summary>追加状態の変更セットに追加する変更データの設定を行います。</summary>
            /// <param name="newRow">新規行データ</param>
            var setCreatedChangeData = function (newRow) {
                // TODO: 画面の仕様に応じて以下の項目を変更してください。
                var changeData = {
                    "cd_riyu": newRow.cd_riyu,
                    "dt_seizo": newRow.dt_seizo_hidden,
                    "cd_hinmei": newRow.cd_hinmei,
                    "su_seizo_yotei": newRow.su_seizo_yotei,
                    "su_seizo_yotei_old": newRow.su_seizo_yotei_old,
                    "cd_line": newRow.cd_line_search,
                    "cd_shokuba": newRow.cd_shokuba_search,
                    "no_lot_seihin": newRow.no_lot_seihin,
                    "henkozumi_data": "",
                    "id": newRow.id,
                    "su_batch_keikaku": newRow.su_batch_keikaku,
                    "dt_update": newRow.dt_update
                };
                // TODO: ここまで

                return changeData;
            };

            /// <summary>削除状態の変更セットに追加する変更データの設定を行います。</summary>
            /// <param name="row">選択行</param>
            var setDeletedChangeData = function (row) {
                // TODO: 画面の仕様に応じて以下の項目を変更してください。
                var changeData = {
                    "cd_riyu": row.cd_riyu,
                    "dt_seizo": row.dt_seizo_hidden,
                    "cd_hinmei": row.cd_hinmei,
                    "su_seizo_yotei": row.su_seizo_yotei,
                    "cd_line": row.cd_line_search,
                    "cd_shokuba": row.cd_shokuba_search,
                    "no_lot_seihin": row.no_lot_seihin,
                    "dt_update": row.dt_update
                };
                // TODO: ここまで

                return changeData;
            };

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
                if (addData.cd_riyu !== ""
                    && addData.cd_riyu !== pageLangText.kyujitsuKaijyo.text) {
                    // 休日理由が設定されている場合、行追加不可(休日解除の時は許可)
                    App.ui.page.notifyInfo.message(MS0828).show();
                    return;
                }
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
                // add したときに、理由区分がを判定し、文字色セット
                var riyuCd = addData.cd_riyu;
                if (riyuCd != "" && riyuCd != pageLangText.kyujitsuKaijyo.text) {
                    // 文字色を赤にする -解除の場合は不要 
                    grid.setCell(newRowId, "nm_riyu", '', { color: '#FF0000' });
                }
                if (riyuCd != "" && riyuCd == pageLangText.kyujitsuKaijyo.text) {
                   //編集不可設定付与(製品コード、製造予定数、バッチ数、反映チェックボックス、倍率）
                   grid.jqGrid('setCell', newRowId, 'cd_hinmei', '', 'not-editable-cell')
                       .jqGrid('setCell', newRowId, 'su_seizo_yotei', '', 'not-editable-cell')
                       .jqGrid('setCell', newRowId, 'su_batch_keikaku', '', 'not-editable-cell')
                       .jqGrid('setCell', newRowId, 'check_reflect', '', 'not-editable-cell')
                       .jqGrid('setCell', newRowId, 'ritsu_kihon', '', 'not-editable-cell');
                }
                // 追加状態の変更セットに変更データを追加
                changeSet.addCreated(newRowId, setCreatedChangeData(addData));
                // セルを選択して入力モードにする
                grid.editCell(currentRow + 1, currentCol, true);
            };
            /// <summary>追加ボタンクリック時のイベント処理を行います。</summary>
            $(".add-button").on("click", addData);

            /// <summary>行を削除します。</summary>
            /// <param name="e">イベントデータ</param>
            var deleteData = function (e) {
                // 選択行のID取得
                var selectedRowId = getSelectedRowId();
                var flg_check = 0;

                //　削除データか更新データかを区別します。削除データ=false
                var henkouFlg = false;

                if (App.isUndefOrNull(selectedRowId)) {
                    return;
                }

                // 選択行の実績、計画確定のチェック処理を行う。
                flg_check = checkKakutei(selectedRowId);

                // 製造実績または仕込実績がある場合
                if (flg_check.flg_seihin_jisseki == true || flg_check.flg_shikakari_jisseki == true) {

                    // インフォメーション表示
                    showInfoMsg(flg_check, henkouFlg);
                    return;

                }

                // 仕込計画がある場合
                else if (flg_check.flg_shikomi == true) {

                    // 仕込計画確定チェック確認ダイアログの表示
                    showKakuteiConfirmDialog();
                    return;
                }

                doDelete();
            };

            var doDelete = function () {
                closeKakuteiConfirmDialog();
                var selectedRowId = getSelectedRowId();
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

            /// <summary>製品検索ボタンクリック時のイベント処理を行います。</summary>
            var openSeihinDialog = function (e) {
                var selectedRowId = getSelectedRowId();
                if (App.isUndefOrNull(selectedRowId)) {
                    return;
                }
                // 行選択
                //var idNum = grid.getGridParam("selrow");
                //$("#" + idNum).removeClass("ui-state-highlight").find("td").click();
                saveEdit();

                // 製造日を取得
                var seizoDate = grid.jqGrid('getCell', selectedRowId, 'dt_seizo_hidden');
                seizoDate = App.data.getDate(seizoDate);
                // 検索条件を取得
                var criteria = $(".search-criteria").toJSON();

                //var option = { id: 'seihin', multiselect: false, param1: pageLangText.seihinHinKbn.text };
                var option = { id: 'seihin', multiselect: false
                    , param1: pageLangText.keikakuSeihinHinDlgParam.text
                    , param2: App.data.getDateTimeStringForQueryNoUtc(seizoDate)
                    , param3: criteria.lineCode
                };
                seihinDialog.draggable(true);
                seihinDialog.dlg("open", option);
            };

            $(".seihin-button").on("click", function () {
                var selectedRowId = getSelectedRowId(false);
                if (App.isUndefOrNull(selectedRowId)) {
                    return;
                }

                // 休日チェック
                var riyuCd = grid.getCell(selectedRowId, "cd_riyu");
                if (riyuCd != "" && riyuCd != pageLangText.kyujitsuKaijyo.text) {
                    App.ui.page.notifyInfo.message(MS0125).show();
                    return;
                }

                // 製品修正チェック 操作不可の場合、リターン
                var tr = grid[0].rows.namedItem(selectedRowId),
                    seihintd = tr.cells[seihinCodeCol];
                var hasNotEditClass = $(seihintd).hasClass('not-editable-cell');
                if (hasNotEditClass == true) {
                    return;
                }

                if (isEditOldDateInfo(getSelectedRowId(), "seihin")) {
                    $("#" + selectedRowId).removeClass("ui-state-highlight").find("td:nth-child(" + forcusCol + ")").click(); // 行選択
                    openSeihinDialog();
                }
            });

            /// <summary>合計表示ボタンクリック時のイベント処理を行います。</summary>
            $(".gokei-button").on("click", function (e) {
                var selectedRowId = getSelectedRowId();
                if (App.isUndefOrNull(selectedRowId)) {
                    return;
                }
                // 行選択
                var idNum = grid.getGridParam("selrow");
                $("#" + idNum).removeClass("ui-state-highlight").find("td:nth-child(" + 2 + ")").click();

                var criteria = $(".search-criteria").toJSON();
                var option = { id: 'gokeiHyoji', multiselect: false
                    , param1: getFromFirstDateStringForQuery(criteria.dt_hiduke_search) //初日
                    , param2: getFromLastDateStringForQuery(criteria.dt_hiduke_search) //末日
                    //, param3: getTodayDateStringForQuery(criteria.dt_hiduke_search) //当日
                    , param3: getTodayDateStringForQuery(new Date()) //当日
                    , param4: criteria.shokubaCode
                    , param5: criteria.lineCode
                    , param6: $(".search-criteria [name='dt_hiduke_search']").val()
                    , param7: $(".search-criteria [name='shokubaCode'] option:selected").text()
                    , param8: $(".search-criteria [name='lineCode'] option:selected").text()

                };
                gokeiDialog.draggable(true);
                gokeiDialog.dlg("open", option);
            });

            /// <summary>休み一覧ボタンクリック時のイベント処理を行います。</summary>
            var openYasumiDialog = function (e) {
                var selectedRowId = getSelectedRowId();
                if (App.isUndefOrNull(selectedRowId)) {
                    return;
                }

                // 行選択
                var idNum = grid.getGridParam("selrow");
                $("#" + idNum).removeClass("ui-state-highlight").find("td").click();

                var option = { id: 'yasumiSentaku', multiselect: false
                    , param1: $(".search-criteria [name='shokubaCode'] option:selected").text()
                    , param2: $(".search-criteria [name='lineCode'] option:selected").text()

                };
                yasumiDialog.draggable(true);
                yasumiDialog.dlg("open", option);
            };

            $(".yasumi-button").on("click", function () {
                // 行が選択できなかったら、返却
                var selectedRowId = getSelectedRowId(false);
                if (App.isUndefOrNull(selectedRowId)) {
                    return;
                }

                if (isEditOldDateInfo(getSelectedRowId(), "yasumi")) {
                    openYasumiDialog();
                }
            });

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
                    var id = checkedRow[i];
                    // 対象行の明細/バッチ数もしくは倍率が0以下または空白の場合は、C/S数をクリアする
                    var batch = grid.getCell(id, "su_batch_keikaku");   // バッチ数
                    var bairitsu = grid.getCell(id, "ritsu_kihon");   // バッチ数
                    if (batch == 0 || batch == "" || bairitsu <= 0 || bairitsu == "" ) {
                        grid.setCell(id, "su_seizo_yotei", null);
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
                        var unique = id + "_" + seizoYoteiSuCol;

                        // ■（明細/バッチ数 ｘ (配合名マスタ．合計配合重量 × 明細/倍率）） ÷
                        //      （品名マスタ．一個の量 ｘ 品名マスタ．入数） × （配合名マスタ．歩留 ÷ 換算(100)）
                        //var resultCase = (batch * (haigoJuryo * bairitsu)) / (wt_ko * irisu) * (budomari / kanzan);
                        // 小数点以下は切り捨て
                        //resultCase = Math.floor(resultCase);

                        // JSの小数点の計算による誤差を考慮して、共通の計算関数を使用する
                        var juryo_bairitsu = App.data.trimFixed(haigoJuryo * bairitsu);
                        var calcVal1 = App.data.trimFixed(batch * juryo_bairitsu);
                        var su_ko_iri = App.data.trimFixed(wt_ko * irisu);
                        budomari = App.data.trimFixed(budomari / kanzan);
                        var calcVal2 = App.data.trimFixed(calcVal1 / su_ko_iri);

                        var resultCase = App.data.trimFixed(calcVal2 * budomari);
                        resultCase = Math.floor(resultCase);    // 小数点以下は切り捨て

                        // 結果が上限桁数を超えていた場合はエラーメッセージを表示してcontinue
                        if (resultCase > 9999999999) {
                            var targetDate = App.data.getDate(grid.getCell(id, "dt_seizo_hidden"));
                            // ブラウザの言語設定によって、使用する日付フォーマットを選択する
                            var useFormat;
                            if (App.ui.page.langCountry === "en-US") {
                                useFormat = pageLangText.dateFormatUS.text;
                            } else {
                                useFormat = pageLangText.dateFormat.text;
                            }
                            targetDate = $.datepicker.formatDate(useFormat, targetDate);

                            var targetCode = grid.getCell(id, "cd_hinmei");
                            var maximErrMsg = App.str.format(
                                MS0032
                                , targetDate + "：" + targetCode + pageLangText.msg_param.text
                            );
                            App.ui.page.notifyAlert.message(maximErrMsg, unique).show();
                            continue;
                        }
                        else {
                            // 計算結果を設定
                            grid.setCell(id, "su_seizo_yotei", resultCase);
                        }
                    }
                    // 編集内容の保存
                    //grid.saveCell(id, seizoYoteiSuCol);
                    // チェンジセットにセット（すべてCreated)
                    // 追加状態のデータ設定
                    var changeData = setCreatedChangeData(grid.getRowData(id));
                    // 追加状態の変更セットに変更データを追加
                    changeSet.addCreated(id, changeData);
                }
                // ローディングの終了
                App.ui.loading.close();
            };
            /// <summary>C/S数反映ボタンのチェック処理</summary>
            var checkReflect = function () {
                // ローディング
                App.ui.loading.show(pageLangText.nowProgressing.text);

                // vlidation
                // メッセージのクリア
                App.ui.page.notifyInfo.clear();
                App.ui.page.notifyAlert.clear();
                // チェック行のクリア
                checkedRow = new Array();
                // 編集内容の保存
                saveEdit();
                // 変更セット内にバリデーションエラーがある場合は処理を抜ける
                //if (!validateChangeSet()) {
                //    App.ui.loading.close();
                //    return;
                //}

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
                        // コードに入力がなければSKIP
                        var code = grid.getCell(id, "cd_hinmei");
                        if (code != "") {
                            checkedRow[cnt] = id;
                            cnt++;

                            if (!isOldDay) {
                                // 過去日かどうか
                                var date = grid.getCell(id, "dt_seizo_hidden");
                                date = $.datepicker.formatDate(pageLangText.dateFormat.text, App.data.getDate(date))
                                isOldDay = isOlderDate(date);
                            }
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

                // lengthプロパティを設定
                checkedRow.length = cnt;

                // 過去日が含まれていた場合、確認ダイアログを表示する
                if (isOldDay) {
                    showOldDateInputConfirmDialog(checkedRow[0], "reflect");  // 選択行は対象の先頭
                }
                else {
                    // C/S数の計算と反映処理
                    calcCaseReflect();
                }
                App.ui.loading.close();
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
            // 検索条件に変更が発生した場合
            var criteriaChange = function () {
                // 検索後の状態で検索条件が変更された場合
                if (isSearch) {
                    isCriteriaChange = true;
                }
            };
            $(".search-criteria").on("change", criteriaChange);

            // <summary>データに変更がないかどうかを返します。</summary>
            var noChange = function () {

                if (changeSet.getChangeSetData().Created.length != 0
                    || changeSet.getChangeSetData().Deleted.length != 0
                    || changeSet.getChangeSetData().Updated.length != 0) {

                    // 更新データが存在する場合は、falseを返却する。
                    return false;

                }

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

            /// 更新データに、ラジオボタンの値をセットします
            var setJissekiDataRadio = function () {
                // ダイアログの結果を取得
                var select = $(".jissekidata-confirm-dialog").toJSON().radio_jisseki;

                // changeSet内の対象のロットNoに対して、ラジオの値をセット
                // createdのみに値が入るので、その中をループさせる
                var changesetLen = changeSet.getChangeSetData().Created.length,
                    jissekiDataLen = jissekiData.__count,
                    lotNo;

                for (var i = 0; i < jissekiDataLen; i++) {
                    // 設定が必要なロットNoを選択
                    lotNo = jissekiData.d[i].no_lot_seihin;
                    for (var j = 0; j < changesetLen; j++) {
                        // ロットが同一だった場合、チェックボックスの値をchangeSetにセットする
                        var d = changeSet.getChangeSetData().Created[j];
                        if (lotNo == d.no_lot_seihin) {
                            d.henkozumi_data = select;
                        }
                    }
                }
            };

            /// <summary>変更を保存します。</summary>
            /// <param name="e">イベントデータ</param>
            var saveData = function (e) {
                // 確認ダイアログのクローズ
                closeSaveConfirmDialog();
                closeJissekiDataConfirmDialog();
                // ローディングの表示
                App.ui.loading.show(pageLangText.nowSaving.text);

                // 実績データがあった場合、チェンジセットにラジオの結果をセットする
                if (!App.isUndefOrNull(jissekiData)) {
                    setJissekiDataRadio();
                }

                // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                var saveUrl = "../api/GekkanSeihinKeikaku";
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
            /// <summary>保存ボタンクリック時のイベント処理を行います。</summary>
            //$(".save-button").on("click", showSaveConfirmDialog);
            $(".save-button").on("click", preSave);

            /// <summary>削除対象の製品ロット番号が按分トランにあるかどうか</summary>
            /// <param name="checkInfo">チェック情報</param>
            var deleteCheckShiyoYojitsuAnbun = function (checkInfo) {
                var deleted = changeSet.changeSet.deleted;
                for (delId in deleted) {
                    var delData = deleted[delId];

                    // 按分トランにデータがあるかどうか
                    if (getAnbunData(delData.no_lot_seihin)) {
                        // データがある場合はエラーとするため、この時点で処理を抜ける
                        checkInfo.isValid = false;
                        checkInfo.lotNo = delData.no_lot_seihin;
                        return checkInfo;
                    }
                }

                return checkInfo;
            };
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

            //// 保存処理 -- End

            //// バリデーション -- Start

            // グリッドコントロール固有のバリデーション

            // TODO: 画面の仕様に応じて以下のカスタムバリデーション定義を変更してください。

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
            // 製造数
            validationSetting.su_seizo_yotei.rules.custom = function (value) {
                return isValidRange(validationSetting.su_seizo_yotei, value);
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
                // 製品名のカラムの場合は、フォーカス変更
                var unique = iCol != seihinNameCol ? selectedRowId + "_" + iCol : selectedRowId + "_" + seihinNameCol,
                    val = {},
                    hinmeiVal,
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
                    // 解除以外の理由コードがある場合は、チェックは不要
                    // 解除コードがあった場合でも、入力があればチェック
                    var riyuCd = grid.getCell(selectedRowId, "cd_riyu");
                    if ((riyuCd != "" && riyuCd != pageLangText.kyujitsuKaijyo.text)
                        || riyuCd == pageLangText.kyujitsuKaijyo.text && grid.getCell(selectedRowId, "cd_hinmei") == "") {
                        continue;
                    }
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

            /// <summary>
            ///     実績・確定状況判定処理
            ///     選択行の実績と計画確定のチェック処理を実行します。
            /// </summary>
            /// <param name="selectedRowId">選択行ID</param>
            /// <retuern>実績・確定チェック結果</return>
            var checkKakutei = function (selectedRowId) {

                // 返却用データ格納用オブジェクト
                var checkFlg = new Object();
                // 製造実績フラグ
                checkFlg.flg_seihin_jisseki = false;
                // 仕込実績フラグ
                checkFlg.flg_shikakari_jisseki = false;
                // 仕込計画確定フラグ
                checkFlg.flg_shikomi = false;

                // 製造実績判定
                if (grid.getCell(selectedRowId, "flg_seihin_jisseki") == 1) {
                    // 製造実績フラグをtrue(製造実績あり）に変更
                    checkFlg.flg_seihin_jisseki = true;
                }

                // 仕込実績判定
                if (grid.getCell(selectedRowId, "flg_shikakari_jisseki") == 1) {
                    // 仕込実績フラグをtrue(仕込実績あり）に変更
                    checkFlg.flg_shikakari_jisseki = true;
                }

                // 仕込計画確定判定
                if (grid.getCell(selectedRowId, "flg_shikomi") == 1
                    || grid.getCell(selectedRowId, "flg_label") == 1
                    || grid.getCell(selectedRowId, "flg_label_hasu") == 1) {

                    // 仕込計画確定フラグをtrue(仕込計画確定済み）に変更
                    checkFlg.flg_shikomi = true;
                }

                // 結果を返却
                return checkFlg;
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

            /// <summary>
            ///     インフォメーション表示処理
            ///     実績ごとのメッセージを表示する。
            /// </summary>
            /// <param name="checkFlg">実績フラグ</param>
            /// <param name="henkouFlg">変更フラグ</param>
            var showInfoMsg = function (checkFlg, henkouFlg) {
                // メッセージに渡す引数。
                var msgParam = null;

                if (henkouFlg) {
                    // セル編集の場合：更新
                    msgParam = pageLangText.upd.text;
                } else {
                    // 行削除の場合：削除
                    msgParam = pageLangText.del.text;
                }

                // 製造実績がある場合
                if (checkFlg.flg_seihin_jisseki === true) {
                    // インフォーメーション表示
                    App.ui.page.notifyInfo.message(
                         App.str.format(pageLangText.jissekiCheck.text, pageLangText.seizoJisseki.text, msgParam)
                    ).show();
                }

                // 仕込実績がある場合
                if (checkFlg.flg_shikakari_jisseki === true) {
                    // インフォーメーション表示
                    App.ui.page.notifyInfo.message(
                         App.str.format(pageLangText.jissekiCheck.text, pageLangText.shikakariJisseki.text, msgParam)
                    ).show();
                }
            };

            /// <summary>
            ///     仕込計画確定確認ダイアログ(更新時)表示
            ///     仕込計画確定確認ダイアログを表示します。
            /// </summary>
            var showJissekiDataConfirmDialog = function () {

                keikakuGamenObject.jissekiDlgFlg = true;
                // ダイアログを表示する。
                $("#radio_case").prop("checked", true);
                jissekiDataConfirmDialogNotifyInfo.clear();
                jissekiDataConfirmDialog.draggable(true);
                jissekiDataConfirmDialog.dlg("open");

            };

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

            /// <summary>仕込計画確定確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".kakutei-confirm-dialog .dlg-yes-button").on("click", doDelete);

            // <summary>仕込計画確定確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".kakutei-confirm-dialog .dlg-no-button").on("click", closeKakuteiConfirmDialog);

            /// <summary>検索確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".search-confirm-dialog .dlg-yes-button").on("click", findData);

            // <summary>検索確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".search-confirm-dialog .dlg-no-button").on("click", closeSearchConfirmDialog);

            /// <summary>日付入力確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".olddateinput-confirm-dialog .dlg-yes-button").on("click", closeOldDateInputConfirmDialog);

            // <summary>日付入力確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            //$(".olddateinput-confirm-dialog .dlg-no-button").on("click", reSelectRow);
            $(".olddateinput-confirm-dialog .dlg-no-button").on("click", closeOldDateInputConfirmDialogNo);

            /// <summary>実績確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            //$(".jissekidata-confirm-dialog .dlg-yes-button").on("click", saveData);
            $(".jissekidata-confirm-dialog .dlg-yes-button").on("click", closeJissekiDiarog);

            // <summary>実績確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            //$(".jissekidata-confirm-dialog .dlg-no-button").on("click", closeJissekiDataConfirmDialog);
            $(".jissekidata-confirm-dialog .dlg-no-button").on("click", closeAndSetJissekiDataConfirmDialog);

            // <summary>実績確認ダイアログの文言を改行させる
            $("#jissekiMsg").html(pageLangText.jissekiDataConfirm.text);

            /// 月の初日を取得
            var getFromFirstDateStringForQuery = function (date) {
                var result = new Date(date.getFullYear(), date.getMonth(), 1, 00, 00, 00);

                return App.data.getDateTimeStringForQueryNoUtc(result, false);
            };

            /// 月の末日を取得
            var getFromLastDateStringForQuery = function (date) {
                var result = new Date(date.getFullYear(), date.getMonth() + 1, 0, 23, 59, 59);
                return App.data.getDateTimeStringForQueryNoUtc(result, false);
            };

            /// 当日を取得
            var getTodayDateStringForQuery = function (date) {
                var result = new Date(date.getFullYear(), date.getMonth(), date.getDate(), 00, 00, 00);

                return App.data.getDateTimeStringForQuery(result, false);
            };

            /// 職場コンボ変更時
            $("#shokubaComBoxId").change(function () {
                setLineComboData(this.value, true, "");
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


            /// <summary>Excelファイル出力を行います。</summary>
            var printExcel = function (isAllLine, e) {
                var criteria = $(".search-criteria").toJSON();
                var query = {
                    // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                    url: "../api/GekkanSeihinKeikakuExcel",
                    // TODO: ここまで
                    cd_shokuba: criteria.shokubaCode,
                    cd_line: criteria.lineCode,
                    cd_riyu: pageLangText.kyujitsuRiyuKbn.text,
                    flg_mishiyo: pageLangText.shiyoMishiyoFlg.text,
                    dt_hiduke_from: getFromFirstDateStringForQuery(criteria.dt_hiduke_search),
                    dt_hiduke_to: getFromLastDateStringForQuery(criteria.dt_hiduke_search),
                    nm_shokuba: encodeURIComponent($(".search-criteria [name='shokubaCode'] option:selected").text()),
                    nm_line: encodeURIComponent($(".search-criteria [name='lineCode'] option:selected").text()),
                    // TODO: ここまで
                    skip: querySetting.skip,
                    top: querySetting.top
                };

                // 処理中を表示する
                App.ui.loading.show(pageLangText.nowProgressing.text);

                // 必要な情報を渡します
                var url = App.data.toWebAPIFormat(query);
                url = url + "&lang=" + App.ui.page.lang
                          + "&hiduke=" + getFromLastDateStringForQuery(criteria.dt_hiduke_search)
                          + "&UTC=" + new Date().getTimezoneOffset() / 60
                          + "&userName=" + encodeURIComponent(App.ui.page.user.Name)
                          + "&isAllLine=" + isAllLine
                          + "&today=" + App.data.getDateTimeStringForQuery(new Date(), true); // 出力日時用(サーバー時間だとズレがあるので画面で取得したシステム日付を渡す)
                window.open(url, '_parent');

                // Cookieを監視する
                onComplete();
            };

            /// <summary>ダウンロードボタンクリック時のチェック処理</summary>
            var prePrintExcel = function (isAllLine) {
                App.ui.page.notifyAlert.clear();
                // 明細の変更をチェック
                if (!noChange()) {
                    App.ui.page.notifyAlert.message(pageLangText.unprintableCheck.text
                    ).show();
                    return;
                }
                // 検索条件の変更をチェック
                if (isCriteriaChange) {
                    App.ui.page.notifyAlert.message(
                         App.str.format(pageLangText.criteriaChange.text, pageLangText.searchCriteria.text, pageLangText.output.text)
                    ).show();
                    return;
                }
                // 検索条件のバリデーション
                var res = $(".part-body .item-list").validation().validate();
                if (res.errors.length > 0) {
                    return;
                }

                printExcel(isAllLine);
            };
            /// <summary>Excelボタンクリック時のイベント処理を行います。</summary>
            $(".excel-button").on("click", function () {
                prePrintExcel(false);
            });

            /// <summary>全ラインExcelボタンクリック時のイベント処理を行います。</summary>
            $(".zenLine-button").on("click", function () {
                prePrintExcel(true);
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

            // Cookieを1秒ごとにチェックする
            var onComplete = function () {
                if (app_util.prototype.getCookieValue(pageLangText.gekkanSeihinKeikakuCookie.text) == pageLangText.checkCookie.text) {
                    app_util.prototype.deleteCookie(pageLangText.gekkanSeihinKeikakuCookie.text);
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
                        <span class="item-label" data-app-text="dt_hiduke_search"></span>
                        <input type="text" id="id_dt_hiduke_search" name="dt_hiduke_search" maxlength="7"/>
                    </label>
                </li>
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
                        <select name="lineCode" id="id_lineCode">
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
                <button type="button" class="add-button" name="add-button" data-app-operation="addButton"><span class="icon"></span><span data-app-text="add"></span></button>
                <button type="button" class="delete-button" name="delete-button" data-app-operation="deleteButton"><span class="icon"></span><span data-app-text="del"></span></button>
                <button type="button" class="seihin-button" name="seihin-button" data-app-operation="seihinIchiran"><span class="icon"></span><span data-app-text="seihinIchiran"></span></button>
                <button type="button" class="yasumi-button" name="yasumi-button" data-app-operation="yasumiIchiran"><span class="icon"></span><span data-app-text="yasumiIchiran"></span></button>
                <button type="button" class="reflect-button" name="reflect-button" data-app-operation="csReflect"><span class="icon"></span><span data-app-text="csReflect"></span></button>
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
        <button type="button" class="zenLine-button" name="zenLine-button" data-app-operation="zenLine">
            <!--<span class="icon"></span>-->
            <span data-app-text="zenLine"></span>
        </button>
        <button type="button" class="gokei-button" name="gokei-button" data-app-operation="total">
            <span class="icon"></span>
            <span data-app-text="gokei"></span>
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
    <!-- 保存確認ダイアログ -->
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
    <!-- 検索確認ダイアログ -->
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
    <!-- 過去日確認ダイアログ -->
    <div class="olddateinput-confirm-dialog" style="display:none">
        <div class="dialog-header">
            <h4 data-app-text="confirmTitle"></h4>
        </div>
        <div class="dialog-body" style="padding: 10px; width: 100%;">
            <div class="part-body">
                <span data-app-text="oldDateInputConfirm"></span>
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
    <!-- 実績確認ダイアログ -->
    <div class="jissekidata-confirm-dialog" style="display:none">
        <div class="dialog-header">
            <h4 data-app-text="confirmTitle"></h4>
        </div>
        <div class="dialog-body" style="padding: 10px; width: 100%;">
            <div class="part-body">
                <span id="jissekiMsg"></span>
            </div>
            <div class="jisseki-body">
                <span  data-app-text="txt_dlg_title"></span>
                <!-- radio -->
                <ul>
                    <li>
                        <span class="item-label"  data-app-text="RoleName"></span>
                        <label>
                            <!-- 製品計画トランまで -->
                            <input type="radio" name="radio_jisseki" id="radio_case" value="1" checked="checked"/>
                            <span class="item-label" data-app-text="txt_radio_case"></span>
                        </label>
                    </li>
                    <li>
                        <span class="item-label"></span>
                        <label>
                            <!-- 通常通り展開 -->
                            <input type="radio" name="radio_jisseki" id="radio_all" value="2" />
                            <span class="item-label" data-app-text="txt_radio_all"></span>
                        </label>
                    </li>
                </ul>
            </div>
        </div>
        <div class="dialog-footer">
            <div class="command" style="position: absolute; left: 10px; top: 5px">
                <!--
                <button class="dlg-yes-button" name="dlg-yes-button" data-app-text="execute"></button>
                -->
                <button class="dlg-yes-button" name="dlg-yes-button" data-app-text="ok"></button>
            </div>
            <div class="command" style="position: absolute; right: 5px; top: 5px;">
                <!--
                <button class="dlg-no-button" name="dlg-no-button" data-app-text="end"></button>
                -->
                <button class="dlg-no-button" name="dlg-no-button" data-app-text="cancel"></button>
            </div>
        </div>
    </div>
    <!-- 計画確定確認ダイアログ(削除時) -->
    <div class="kakutei-confirm-dialog" style="display:none">
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
    <div class="gokei-dialog">
	</div>
    <div class="yasumi-dialog">
	</div>
    <!-- TODO: ここまで  -->

    <!-- 画面デザイン -- End -->
</asp:Content>
