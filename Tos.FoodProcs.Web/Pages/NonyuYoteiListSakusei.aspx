<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="NonyuYoteiListSakusei.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.NonyuYoteiListSakusei" %>

<asp:Content ID="Content1" ContentPlaceHolderID="IncludeContent" runat="server">
    <script src="<%=ResolveUrl("~/Resources/pages/pagedata-nonyuyoteilistsakusei." + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
    <script src="<%=ResolveUrl("~/Resources/grid/grid.locale-" + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
    <script src="<%=ResolveUrl("~/Scripts/util/app-util.js") %>" type="text/javascript"></script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        /* 画面デザイン -- Start */
        
        /* 付加空白設定 */
        .pad-apace
        {
            padding-left: 3em;
        }

        /* 固定表示部のスタイル */
        .part-body
        {
            margin: .2em;
        }
        .part-body .item-label
        {
            display: inline-block;
        }
        .part-body .part-no-nonyusho
        {
            display: inline-block;
        }
        .search-criteria .item-label
        {
            width: 6em;
        }

        /* グリッドのスタイル */
        #result-grid
        {
            padding: 0px;
            overflow: hidden;
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

        /* 取引先一覧ダイアログ：検索条件/取引先一覧ボタン押下時のスタイル */
        .con-torihikisaki-button-dialog
        {
            background-color: White;
            width: 550px;
        }

        /* 原資材一覧ダイアログのスタイル */
        .genshizai-dialog
        {
            background-color: White;
            width: 550px;
        }
        
        /* 取引先一覧ダイアログ：取引先一覧ボタン押下時のスタイル */
        .torihikisaki-button-dialog
        {
            background-color: White;
            width: 700px;
        }

        button.condition-torihiki-button {
          height: 30px;
          position: relative;
          top: 5px;
          padding: 0px;
          min-width: 110px;
          margin-right: 0;
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
                querySetting = { skip: 0, top: 500, count: 0 },
                isSearch = false, // 検索フラグ
                isCriteriaChange = false,   // 検索条件変更フラグ
                isDataLoading = false;

            // 英語化対応　言語によって幅を調節
            $(".search-criteria .item-label").css("width", pageLangText.each_lang_width.number);

            // 画面固有の変数宣言
            var hinKbnSearchCondition = null;

            // グリッドコントロール固有の変数宣言
            var grid = $("#item-grid"),
            // 変更データ格納領域
                changeSet = new App.ui.page.changeSet(),
            // 検索条件格納領域
                searchCriteriaSet,
            // バリデーションエラーフラグ
                varidErrFlg = false,
            // 確定ステータス(初期値は未確定)
                kakuteiStatus = pageLangText.mikakuteiKakuteiFlg.text,
            // 列番号：隠し項目：納入番号
            //    noNonyuCol = 1,
            // 列番号：明細/納入書番号
            //    noNonyushoCol = 3,
            // 列番号：明細/原資材コード
                cdHinmeiCol = 5,
            // 列番号：明細/原資材名
            //    nmGenshizaiCol = 6,
            // 列番号：明細/納入予定日
            //    dtNonyuYoteiCol = 10,
            // 列番号：明細/納入予定
            //    suNonyuYoteiCol = 11,
            // 列番号：明細/納入実績
            //    suNonyuCol = 12,
            //    suNonyuCol = 13,
            // 列番号：明細/端数
            //    suNonyuHasuCol = 14,
            //    suNonyuHasuCol = 15,
            // 列番号：明細/納入単価
            //tanNonyuCol = 15,
            //    tanNonyuCol = 21,
            //    tanNonyuCol = 22,
            // 列番号：明細/金額
            //kinKingakuCol = 20,
            //    kinKingakuCol = 26,
                kinKingakuCol = 27,
            // 列番号：明細/取引先１(物流)
            //nmTorihikiCol = 26,
            //    nmTorihikiCol = 16,
            //    nmTorihikiCol = 17,
            // 列番号：明細/取引先２(商流)
            //nmTorihiki2Col = 28,
            //    nmTorihiki2Col = 18,
            //    nmTorihiki2Col = 19,
            // コンボボックス：検索条件/品区分
                comboKbnHin,
            // コンボボックス：検索条件/品分類
                comboBunruiHin,
            // コンボボックス：検索条件/品位状態
                comboJotaiHini,
            // グリッド内ドロップダウン：明細/税区分
                comboNmZei,
            // グリッド内ドロップダウン：明細/入庫区分
                comboKbnNyuko = pageLangText.nyukoKunbunId.data,
            // 初期値用：明細/税区分
                initKbnZei,
                initNmZei,
            // 原資材名(多言語対応)
                genshizaiName = 'nm_hinmei_' + App.ui.page.lang,
            // 品名マスタ
                maHinmei,
            // 原資材購入先マスタ
                maKonyu,
            // 変更レコード格納領域
                updateRow,
            // 最終編集行ＩＤ
                lastEditRowId,
                firstCol = 1,
                duplicateCol = 999,
                currentRow = 0,
                currentCol = firstCol,
                loading;
            var flgEdit = false;
            // 機能区分
            var kbnNonyuJiseki,
                nonyuJiseki = pageLangText.kinoNonyuJisekiNyuryokuKa.number;
            var kbnNyukoKubun,
                nyukoKubun = pageLangText.kinoNyukoKubunNyuryokuAri.number;

            // ダイアログ固有の変数宣言
            // ダイアログ(取引先マスタ検索)：検索条件/取引先一覧ボタン押下時
            var torihikisakiDialog = $(".con-torihikisaki-button-dialog");
            torihikisakiDialog.dlg({
                url: "Dialog/TorihikisakiDialog.aspx",
                name: "TorihikisakiDialog",
                closed: function (e, data, data2) {
                    if (data == "canceled") {
                        // キャンセルされた場合、ダイアログを閉じる
                        return;
                    }
                    else {
                        // 取得した取引先コード、取引先名を、検索条件/取引先コード、検索条件/取引先名に設定
                        $("#condition-cd_torihiki").val(data);
                        $("#condition-nm_torihiki").text(data2);
                    }
                }
            });

            // ダイアログ(品名マスタ検索)：原資材一覧ボタン押下時・明細/原資材コード、明細/原資材名ダブルクリック時
            var genshizaiDialog = $(".genshizai-dialog");
            genshizaiDialog.dlg({
                url: "Dialog/HinmeiDialog.aspx",
                name: "HinmeiDialog",
                closed: function (e, data, data2) {
                    if (data == "canceled") {
                        // キャンセルされた場合、ダイアログを閉じる
                        return;
                    }
                    else {
                        // 選択行の取得
                        var selectedRowId = getSelectedRowId(false);
                        // 取得した品名コード、品名を選択行の明細/原資材コード、明細/原資材名に設定
                        grid.setCell(selectedRowId, "cd_hinmei", data);
                        changeSetUpdated(selectedRowId, "cd_hinmei");
                        grid.setCell(selectedRowId, genshizaiName, data2);
                        // 取得した品名コードの関連情報を設定する
                        /*
                        if (setCdHinmeiRelatedValue(selectedRowId, data, data2)) {
                        // 明細/確定の設定処理
                        if (grid.getCell(selectedRowId, "flg_kakutei") === pageLangText.mikakuteiKakuteiFlg.text) {
                        // 明細/確定が未チェックの場合

                        // 明細/確定にチェックを入れる
                        grid.setCell(selectedRowId, "flg_kakutei", pageLangText.kakuteiKakuteiFlg.text);
                        // 更新状態の変更セットに変更データを追加
                        changeSetUpdated(selectedRowId, "flg_kakutei");
                        }
                        // 明細/原資材コード・明細/取引先１(物流)：組み合わせ重複チェック
                        //checkCombinationDuplicate();
                        }
                        */
                        // 取得した品名コードの関連情報を設定する
                        setCdHinmeiRelatedValue(selectedRowId, data, data2);     
                    }
                }
            });

            // ダイアログ(原資材購入先マスタ検索)：取引先一覧ボタン押下時
            var genshizaiKonyuDialog = $(".torihikisaki-button-dialog");
            genshizaiKonyuDialog.dlg({
                url: "Dialog/GenshizaiKonyuDialog.aspx",
                name: "GenshizaiKonyuDialog",
                closed: function (e, data, data2, data3, data4, data5, data6) {
                    if (data == "canceled") {
                        // キャンセルされた場合、ダイアログを閉じる
                        return;
                    }
                    else {
                        // 選択行の取得
                        var selectedRowId = getSelectedRowId(false);
                        // 取得したコード(物流)を隠し項目：取引先コードに設定
                        grid.setCell(selectedRowId, "cd_torihiki", data3);
                        changeSetUpdated(selectedRowId, "cd_torihiki");

                        if (!App.isUndefOrNull(data4)
                            && data4.length > 0) {
                            // 取引先名(物流)が取得できた場合

                            // 取得した取引先名(物流)を明細/取引先１(物流)に設定
                            grid.setCell(selectedRowId, "nm_torihiki", data4);
                            // 再チェックで背景色とメッセージのリセット
                            validateCell(selectedRowId, "nm_torihiki", grid.getCell(selectedRowId, "nm_torihiki"), grid.getColumnIndexByName("nm_torihiki"));
                        }
                        else {
                            // 取引先名(物流)が取得できなかった場合

                            // nullを明細/取引先１(物流)に設定
                            grid.setCell(selectedRowId, "nm_torihiki", null);
                        }

                        if (!App.isUndefOrNull(data5)
                            && data5.length > 0) {
                            // コード(商流)が取得できた場合

                            // 取得したコード(商流)を隠し項目：取引先コード２に設定
                            grid.setCell(selectedRowId, "cd_torihiki2", data5);
                            changeSetUpdated(selectedRowId, "cd_torihiki2");
                        }
                        else {
                            // コード(商流)が取得できなかった場合

                            // nullを隠し項目：取引先コード２に設定
                            grid.setCell(selectedRowId, "cd_torihiki2", null);
                            changeSetUpdated(selectedRowId, "cd_torihiki2");
                        }

                        if (!App.isUndefOrNull(data6)
                            && data6.length > 0) {
                            // 取引先名(商流)が取得できた場合

                            // 取得した取引先名(商流)を明細/取引先２(商流)に設定
                            grid.setCell(selectedRowId, "nm_torihiki2", data6);
                            // 再チェックで背景色とメッセージのリセット
                            validateCell(selectedRowId, "nm_torihiki2", grid.getCell(selectedRowId, "nm_torihiki2"), grid.getColumnIndexByName("nm_torihiki2"));
                        }
                        else {
                            // 取引先名(商流)が取得できなかった場合

                            // nullを明細/取引先２(商流)に設定
                            grid.setCell(selectedRowId, "nm_torihiki2", null);
                        }

                        // 取得した原資材購入先の関連情報を設定する
                        setKonyuRelatedValue(selectedRowId, data, data2);
                        /*
                        // 明細/確定の設定処理
                        if (grid.getCell(selectedRowId, "flg_kakutei") === pageLangText.mikakuteiKakuteiFlg.text) {
                        // 明細/確定が未チェックの場合

                        // 明細/確定にチェックを入れる
                        grid.setCell(selectedRowId, "flg_kakutei", pageLangText.kakuteiKakuteiFlg.text);
                        // 更新状態の変更セットに変更データを追加
                        changeSetUpdated(selectedRowId, "flg_kakutei");
                        }
                        */
                        // 明細/入庫区分の編集フラグに更新を入れる
                        grid.setCell(selectedRowId, "flg_edit_kbn_nyuko", 1);
                        // 更新状態の変更セットに変更データを追加
                        changeSetUpdated(selectedRowId, "flg_edit_kbn_nyuko");
                        // 明細/入庫区分以外の編集フラグに更新を入れる
                        grid.setCell(selectedRowId, "flg_edit_meisai", 1);
                        // 更新状態の変更セットに変更データを追加
                        changeSetUpdated(selectedRowId, "flg_edit_meisai");
                        // 明細/原資材コード・明細/取引先１(物流)：組み合わせ重複チェック
                        //checkCombinationDuplicate();
                    }
                }
            });

            var searchConfirmDialog = $(".search-confirm-dialog"),
                saveConfirmDialog = $(".save-confirm-dialog");

            //// 変数宣言 -- End

            //// コントロール定義 -- Start

            // ダイアログ固有のコントロール定義
            searchConfirmDialog.dlg();
            saveConfirmDialog.dlg();

            /// 明細行件数チェック
            var checkRecordCount = function () {
                recordCount = grid.getGridParam("records");
                if (recordCount == 0) {
                    // 明細行が存在しない場合は、メッセージを表示し処理を行わない
                    App.ui.page.notifyInfo.message(pageLangText.noRecords.text).show();
                    return false;
                }
                return true;
            };

            /// <summary>ダイアログを開きます。</summary>
            // 検索時ダイアログを開く
            var showSearchConfirmDialog = function () {
                // 検索前に変更をチェック
                if (noChange()) {
                    // 検索処理
                    findData();
                }
                else {
                    searchConfirmDialogNotifyInfo.clear();
                    searchConfirmDialogNotifyAlert.clear();
                    searchConfirmDialog.draggable(true);
                    searchConfirmDialog.dlg("open");
                }
            };

            // 保存時ダイアログを開く
            var showSaveConfirmDialog = function () {
                saveConfirmDialogNotifyInfo.clear();
                saveConfirmDialogNotifyAlert.clear();
                saveConfirmDialog.draggable(true);
                saveConfirmDialog.dlg("open");
            };

            /// ダイアログ：取引先一覧を開く
            var showTorihikisakiDialog = function () {
                // ダイアログ：取引先一覧のドラッグを可能とする
                torihikisakiDialog.draggable(true);
                // ダイアログ：取引先一覧(取引先マスタ検索を「取引先区分 = 仕入先」で絞る)を開く
                var option = { id: 'torihikisaki', multiselect: false, param1: pageLangText.shiiresakiToriKbn.text };
                torihikisakiDialog.dlg("open", option);
            };

            // 品名一覧の引数
            var getHinKbnParam = function () {
                // 検索条件の品区分によって抽出条件を変更する
                var hinKbnParam = "";
                if (App.isUndefOrNull(searchCriteriaSet)) {
                    // 未検索時は空を設定（searchConditionがundefinedの為）
                    hinKbnParam = pageLangText.genshizaiHinDlgParam.text;
                }

                if (searchCriteriaSet.con_kbn_hin == pageLangText.genryoHinKbn.text) {
                    hinKbnParam = pageLangText.genryoHinDlgParam.text;
                }
                else if (searchCriteriaSet.con_kbn_hin == pageLangText.shizaiHinKbn.text) {
                    hinKbnParam = pageLangText.shizaiHinDlgParam.text;
                }
                else {
                    hinKbnParam = pageLangText.genshizaiHinDlgParam.text;
                }
                return hinKbnParam;
            };

            /// ダイアログ：原資材一覧を開く
            var showGenshizaiDialog = function () {
                // ダイアログ：原資材一覧のドラッグを可能とする
                genshizaiDialog.draggable(true);

                var hinKbnParam = getHinKbnParam();
                // ダイアログ：原資材一覧(品名マスタ検索を原料と資材で絞る)を開く
                //                var option = { id: 'genshizai', multiselect: false, param1: pageLangText.genshizaiHinDlgParam.text };
                var option = { id: 'genshizai', multiselect: false, param1: hinKbnParam };
                genshizaiDialog.dlg("open", option);
            };

            /// ダイアログ：原資材購入先一覧を開く
            var showGenshizaiKonyuDialog = function (param_cd_hinmei) {
                // ダイアログ：原資材購入先一覧のドラッグを可能とする
                genshizaiKonyuDialog.draggable(true);
                // ダイアログ：原資材購入先一覧(原資材購入先マスタ検索を指定された原資材コードで絞る)を開く
                var option = { id: 'genshizaiKonyu', multiselect: false, param1: param_cd_hinmei };
                genshizaiKonyuDialog.dlg("open", option);
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

            // 日付系の多言語対応
            var datePickerFormat = pageLangText.dateFormatUS.text,
                newDateFormat = pageLangText.dateNewFormatUS.text;
            if (App.ui.page.langCountry !== 'en-US') {
                datePickerFormat = pageLangText.dateFormat.text;
                newDateFormat = pageLangText.dateNewFormat.text;
            }
            // 検索条件/日付
            $("#condition-dt_nonyu").on("keyup", App.data.addSlashForDateString);
            $("#condition-dt_nonyu").datepicker({ dateFormat: datePickerFormat });
            // 検索条件/日付の範囲制限：1975/01/01 ～ システム日付の10年後
            $("#condition-dt_nonyu").datepicker("option", 'minDate', new Date(1975, 1 - 1, 1));
            $("#condition-dt_nonyu").datepicker("option", 'maxDate', "+10y");

            // グリッドコントロール固有のコントロール定義
            grid.jqGrid({
                colNames: [
                /*
                // 隠し項目：納入番号
                pageLangText.no_nonyu.text,
                // 明細/確定
                pageLangText.flg_kakutei.text,
                // 明細/納入書番号
                pageLangText.no_nonyusho.text,
                // 明細/品分類
                pageLangText.nm_bunrui.text,
                // 明細/原資材コード
                pageLangText.cd_hinmei.text + pageLangText.requiredMark.text,
                // 明細/原資材名
                pageLangText.nm_genshizai.text,
                // 明細/荷姿
                pageLangText.nm_nisugata_hyoji.text,
                // 隠し項目：納入単位コード
                pageLangText.cd_tani_nonyu.text,
                // 明細/納入単位
                pageLangText.nm_tani.text,
                // 明細/納入予定日
                pageLangText.dt_nonyu_yotei.text,
                // 明細/納入予定
                pageLangText.su_nonyu_yo.text,
                // 明細/納入実績
                pageLangText.su_nonyu_ji.text + pageLangText.requiredMark.text,
                // 隠し項目：検索時納入実績
                pageLangText.save_su_nonyu_ji.text,
                // 明細/端数
                pageLangText.su_nonyu_hasu.text,
                // 明細/納入単価
                pageLangText.tan_nonyu.text,
                // 隠し項目：原資材購入先マスタ納入単価
                pageLangText.ma_tan_nonyu.text,
                // 隠し項目：原資材購入先マスタ新納入単価
                pageLangText.ma_tan_nonyu_new.text,
                // 隠し項目：原資材購入先マスタ新単価切替日
                pageLangText.ma_dt_tanka_new.text,
                // 隠し項目：入数
                pageLangText.su_iri.text,
                // 明細/金額
                pageLangText.kin_kingaku.text + pageLangText.requiredMark.text,
                // 隠し項目/入庫区分
                pageLangText.kbn_nyuko.text,
                // 明細/入庫区分
                pageLangText.kbn_nyuko.text,
                // 隠し項目：税区分
                pageLangText.kbn_zei.text,
                // 明細/税区分
                pageLangText.nm_zei.text,
                // 隠し項目：取引先コード
                pageLangText.cd_torihiki.text,
                // 明細/取引先１(物流)
                pageLangText.nm_torihiki.text + pageLangText.requiredMark.text,
                // 隠し項目：取引先コード２
                pageLangText.cd_torihiki2.text,
                // 明細/取引先２(商流)
                pageLangText.nm_torihiki2.text,
                // 明細/納入日
                pageLangText.dt_nonyu.text + pageLangText.requiredMark.text,
                // 隠し項目：入庫区分の編集フラグ
                "hidden",
                // 隠し項目：入庫区分以外の編集フラグ
                "hidden",
                // 隠し項目：予定の取引先コード１
                "hidden",
                // 隠し項目：検索時納入予定日
                "hidden"
                */
                // 明細/確定
                    pageLangText.flg_kakutei.text,
                // 隠し項目：納入番号
                    pageLangText.no_nonyu.text,
                // 明細/納入書番号
                    pageLangText.no_nonyusho.text,
                // 明細/品分類
                    pageLangText.nm_bunrui.text,
                // 明細/原資材コード
                    pageLangText.cd_hinmei.text + pageLangText.requiredMark.text,
                // 明細/原資材名
                    pageLangText.nm_genshizai.text,
                // 明細/荷姿
                    pageLangText.nm_nisugata_hyoji.text,
                // 隠し項目：納入単位コード
                    pageLangText.cd_tani_nonyu.text,
                // 明細/納入単位
                    pageLangText.nm_tani.text,
                // 隠し項目：納入単位コード(端数)
                    pageLangText.cd_tani_nonyu_hasu.text,
                // 明細/納入単位(端数)
                    pageLangText.nm_tani_hasu.text,
                // 明細/納入予定日
                    pageLangText.dt_nonyu_yotei.text,
                // 明細/納入予定
                    pageLangText.su_nonyu_yo.text,
                // 明細/納入予定端数
                    pageLangText.su_nonyu_yo_hasu.text,
                // 明細/納入日
                    pageLangText.dt_nonyu.text + pageLangText.requiredMark.text,
                // 明細/納入実績
                    pageLangText.su_nonyu_ji.text + pageLangText.requiredMark.text,
                // 隠し項目：検索時納入実績
                    pageLangText.save_su_nonyu_ji.text,
                // 明細/端数
                    pageLangText.su_nonyu_hasu.text,
                // 隠し項目：取引先コード
                    pageLangText.cd_torihiki.text,
                // 明細/取引先１(物流)
                    pageLangText.nm_torihiki.text + pageLangText.requiredMark.text,
                // 隠し項目：取引先コード２
                    pageLangText.cd_torihiki2.text,
                // 明細/取引先２(商流)
                    pageLangText.nm_torihiki2.text,
                // 隠し項目/入庫区分
                    pageLangText.kbn_nyuko.text,
                // 明細/入庫区分
                    pageLangText.kbn_nyuko.text,
                // 明細/納入単価
                    pageLangText.tan_nonyu.text,
                // 隠し項目：原資材購入先マスタ納入単価
                    pageLangText.ma_tan_nonyu.text,
                // 隠し項目：原資材購入先マスタ新納入単価
                    pageLangText.ma_tan_nonyu_new.text,
                // 隠し項目：原資材購入先マスタ新単価切替日
                    pageLangText.ma_dt_tanka_new.text,
                // 隠し項目：入数
                    pageLangText.su_iri.text,
                // 明細/金額
                    pageLangText.kin_kingaku.text + pageLangText.requiredMark.text,
                // 隠し項目：税区分
                    pageLangText.kbn_zei.text,
                // 明細/税区分
                    pageLangText.nm_zei.text,
                //// 明細/納入日
                //    pageLangText.dt_nonyu.text + pageLangText.requiredMark.text,
                // 隠し項目：入庫区分の編集フラグ
                    "hidden",
                // 隠し項目：入庫区分以外の編集フラグ
                    "hidden",
                // 隠し項目：予定の取引先コード１
                    "hidden",
                // 隠し項目：検索時納入予定日
                    "hidden",
                // 隠し項目：納入予定番号
                    "hidden",
                // 隠し項目：荷受実績存在フラグ(存在する場合は1)
                    "isExistsNiukeJisseki"
                ],
                colModel: [
                /*
                // 隠し項目：納入番号
                {name: 'no_nonyu', width: 0, hidden: true, hidedlg: true },
                // 明細/確定
                {name: 'flg_kakutei', width: pageLangText.flg_kakutei_width.number, editable: true, edittype: 'checkbox', align: 'center',
                editoptions: { value: "1:0" }, formatter: 'checkbox', formatoptions: { disabled: false }
                },
                // 明細/納入書番号
                {name: 'no_nonyusho', width: pageLangText.no_nonyusho_width.number, editable: true, sorttype: "text", align: 'left' },
                // 明細/品分類
                {name: 'nm_bunrui', width: pageLangText.nm_bunrui_width.number, editable: false, sorttype: "text", align: 'left' },
                // 明細/原資材コード
                {name: 'cd_hinmei', width: pageLangText.cd_hinmei_width.number, editable: true, sorttype: "text", align: 'left' },
                // 明細/原資材名
                {name: genshizaiName, width: pageLangText.nm_genshizai_width.number, editable: false, sorttype: "text", align: 'left' },
                // 明細/荷姿
                {name: 'nm_nisugata_hyoji', width: pageLangText.nm_nisugata_hyoji_width.number, editable: false, sorttype: "text", align: 'left' },
                // 隠し項目：納入単位コード
                {name: 'cd_tani_nonyu', width: 0, hidden: true, hidedlg: true },
                // 明細/納入単位
                {name: 'nm_tani', width: pageLangText.nm_tani_width.number, editable: false, sorttype: "text", align: 'center' },
                // 明細/納入予定日
                {name: 'dt_nonyu_yotei', width: pageLangText.dt_nonyu_width.number, editable: true, sorttype: "date", align: "center", formatter: "date",
                formatoptions: { srcformat: newDateFormat, newformat: newDateFormat },
                editoptions: {
                dataInit: function (el) {
                $(el).on("keyup", App.data.addSlashForDateString);
                $(el).datepicker({ dateFormat: datePickerFormat
                , onClose: function (dateText, inst) {
                // カレンダーを閉じた後は他のセルにフォーカスを当てる
                // ＃セルの見た目が編集状態のままとなっている為、tabなどでセル移動できそうで紛らわしい
                var idNum = grid.getGridParam("selrow");
                $("#" + idNum + " td:eq('" + (noNonyuCol) + "')").click();
                }
                });
                }
                },
                unformat: unformatDate
                },
                // 明細/納入予定
                {name: 'su_nonyu_yo', width: pageLangText.su_nonyu_yo_width.number, editable: true, sorttype: "int", align: "right", formatter: 'number',
                formatoptions: { thousandsSeparator: ",", decimalPlaces: 2, defaultValue: "" }
                },
                // 明細/納入実績
                {name: 'su_nonyu_ji', width: pageLangText.su_nonyu_ji_width.number, editable: true, sorttype: "int", align: "right", formatter: 'number',
                formatoptions: { thousandsSeparator: ",", decimalPlaces: 0, defaultValue: "" }
                },
                // 隠し項目：検索時納入実績
                {name: 'save_su_nonyu_ji', width: 0, hidden: true, hidedlg: true },
                // 明細/端数
                {name: 'su_nonyu_hasu', width: pageLangText.su_nonyu_hasu_width.number, editable: true, sorttype: "int", align: "right",
                formatter: commaReplace,
                unformat: unCommaReplace,
                formatoptions: { thousandsSeparator: ",", decimalPlaces: 0, defaultValue: "" }
                },
                // 明細/納入単価
                {name: 'tan_nonyu', width: pageLangText.tan_nonyu_width.number, editable: true, sorttype: "float", align: "right", formatter: 'number',
                formatoptions: { decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 3, defaultValue: "" }
                },
                // 隠し項目：原資材購入先マスタ納入単価
                {name: 'ma_tan_nonyu', width: 0, hidden: true, hidedlg: true },
                // 隠し項目：原資材購入先マスタ新納入単価
                {name: 'ma_tan_nonyu_new', width: 0, hidden: true, hidedlg: true },
                // 隠し項目：原資材購入先マスタ新単価切替日
                {name: 'ma_dt_tanka_new', width: 0, hidden: true, hidedlg: true, formatter: "date",
                formatoptions: { srcformat: pageLangText.dateSrcFormat.text, newformat: pageLangText.dateNewFormat.text }
                },
                // 隠し項目：入数
                {name: 'su_iri', width: 0, hidden: true, hidedlg: true },
                // 明細/金額
                {name: 'kin_kingaku', width: pageLangText.kin_kingaku_width.number, editable: true, sorttype: "int", align: "right", formatter: 'number',
                formatoptions: { thousandsSeparator: ",", decimalPlaces: 0, defaultValue: "" }
                },
                // 隠し項目：入庫区分
                {name: 'kbn_nyuko', width: 0, hidden: true, hidedlg: true },
                // 明細/入庫区分名
                {name: 'nm_nyuko', width: pageLangText.kbn_nyuko_width.number, editable: true, sorttype: "text", align: "left", edittype: 'select',
                editoptions: {
                value: function () {
                // グリッド内ドロップダウン生成処理
                return grid.prepareDropdown(comboKbnNyuko, "name", "id");
                }
                }
                },
                // 隠し項目：税区分
                {name: 'kbn_zei', width: 0, hidden: true, hidedlg: true },
                // 明細/税区分
                {name: 'nm_zei', width: pageLangText.nm_zei_width.number, editable: true, sorttype: "text", align: "left", edittype: 'select',
                editoptions: {
                value: function () {
                // グリッド内ドロップダウン生成処理
                return grid.prepareDropdown(comboNmZei, "nm_zei", "kbn_zei");
                }
                }
                },
                // 隠し項目：取引先コード
                {name: 'cd_torihiki', width: 0, hidden: true, hidedlg: true },
                // 明細/取引先１(物流)
                {name: 'nm_torihiki', width: pageLangText.nm_torihiki_width.number, editable: false, sorttype: "text", align: 'left' },
                // 隠し項目：取引先コード２
                {name: 'cd_torihiki2', width: 0, hidden: true, hidedlg: true },
                // 明細/取引先２(商流)
                {name: 'nm_torihiki2', width: pageLangText.nm_torihiki2_width.number, editable: false, sorttype: "text", align: 'left' },
                // 明細/納入実績日
                {name: 'dt_nonyu', width: pageLangText.dt_nonyu_width.number, editable: true, sorttype: "date", align: "center", formatter: "date",
                formatoptions: { srcformat: newDateFormat, newformat: newDateFormat },
                editoptions: {
                dataInit: function (el) {
                $(el).on("keyup", App.data.addSlashForDateString);
                $(el).datepicker({ dateFormat: datePickerFormat
                , onClose: function (dateText, inst) {
                // カレンダーを閉じた後は他のセルにフォーカスを当てる
                // ＃セルの見た目が編集状態のままとなっている為、tabなどでセル移動できそうで紛らわしい
                var idNum = grid.getGridParam("selrow");
                $("#" + idNum + " td:eq('" + (noNonyuCol) + "')").click();
                }
                });
                }
                },
                unformat: unformatDate
                },
                // 隠し項目：入庫区分の編集フラグ
                {name: 'flg_edit_kbn_nyuko', width: 0, hidden: true, hidedlg: true },
                // 隠し項目：入庫区分以外の編集フラグ
                {name: 'flg_edit_meisai', width: 0, hidden: true, hidedlg: true },
                // 隠し項目：予定の取引先コード１
                {name: 'cd_torihiki_yotei', width: 0, hidden: true, hidedlg: true },
                // 隠し項目：検索時納入予定日
                {name: 'save_dt_nonyu_yotei', width: 0, hidden: true, hidedlg: true, formatter: "date",
                formatoptions: { srcformat: newDateFormat, newformat: newDateFormat }
                }
                */
                // 明細/確定
                    {name: 'flg_kakutei', width: pageLangText.flg_kakutei_width.number, editable: true, edittype: 'checkbox', align: 'center',
                    editoptions: { value: "1:0" }, formatter: 'checkbox', formatoptions: { disabled: false }
                    },
                // 隠し項目：納入番号
                    { name: 'no_nonyu', width: pageLangText.no_nonyu_width.number, hidden: false, hidedlg: false },
                // 明細/納入書番号
                    {name: 'no_nonyusho', width: pageLangText.no_nonyusho_width.number, editable: true, sorttype: "text", align: 'left' },
                // 明細/品分類
                    {name: 'nm_bunrui', width: pageLangText.nm_bunrui_width.number, editable: false, sorttype: "text", align: 'left' },
                // 明細/原資材コード
                    {name: 'cd_hinmei', width: pageLangText.cd_hinmei_width.number, editable: true, sorttype: "text", align: 'left' },
                // 明細/原資材名
                    {name: genshizaiName, width: pageLangText.nm_genshizai_width.number, editable: false, sorttype: "text", align: 'left' },
                // 明細/荷姿
                    {name: 'nm_nisugata_hyoji', width: pageLangText.nm_nisugata_hyoji_width.number, editable: false, sorttype: "text", align: 'left' },
                // 隠し項目：納入単位コード
                    {name: 'cd_tani_nonyu', width: 0, hidden: true, hidedlg: true },
                // 明細/納入単位
                    {name: 'nm_tani', width: pageLangText.nm_tani_width.number, editable: false, sorttype: "text", align: 'center' },
                // 隠し項目：納入単位コード(端数)
                    {name: 'cd_tani_nonyu_hasu', width: 0, hidden: true, hidedlg: true },
                // 明細/納入単位(端数)
                    {name: 'nm_tani_hasu', width: pageLangText.nm_tani_width.number, editable: false, sorttype: "text", align: 'center' },
                // 明細/納入予定日
                    {name: 'dt_nonyu_yotei', width: pageLangText.dt_nonyu_width.number, editable: true, sorttype: "date", align: "center", formatter: "date",
                    formatoptions: { srcformat: newDateFormat, newformat: newDateFormat },
                    editoptions: {
                        dataInit: function (el) {
                            $(el).on("keyup", App.data.addSlashForDateString);
                            $(el).datepicker({ dateFormat: datePickerFormat
                                , onClose: function (dateText, inst) {
                                    // カレンダーを閉じた後は他のセルにフォーカスを当てる
                                    // ＃セルの見た目が編集状態のままとなっている為、tabなどでセル移動できそうで紛らわしい
                                    var idNum = grid.getGridParam("selrow");
                                    $("#" + idNum + " td:eq('" + grid.getColumnIndexByName("no_nonyu") + "')").click();
                                }
                            });
                        }
                    },
                    unformat: unformatDate
                },
                // 明細/納入予定
                    {name: 'su_nonyu_yo', width: pageLangText.su_nonyu_yo_width.number, editable: true, sorttype: "int", align: "right", formatter: 'number',
                    formatoptions: { thousandsSeparator: ",", decimalPlaces: 0, defaultValue: "" }
                },
                // 明細/納入予定端数
                    {name: 'su_nonyu_yo_hasu', width: pageLangText.su_nonyu_hasu_width.number, editable: true, sorttype: "int", align: "right",
                    formatter: commaReplace,
                    unformat: unCommaReplace,
                    formatoptions: { thousandsSeparator: ",", decimalPlaces: 0, defaultValue: "" }
                },
                // 明細/納入実績日
                    {name: 'dt_nonyu', width: pageLangText.dt_nonyu_width.number, editable: false, sorttype: "date", align: "center", formatter: "date",
                    formatoptions: { srcformat: newDateFormat, newformat: newDateFormat },
                    editoptions: {
                        dataInit: function (el) {
                            $(el).on("keyup", App.data.addSlashForDateString);
                            $(el).datepicker({ dateFormat: datePickerFormat
                                , onClose: function (dateText, inst) {
                                    // カレンダーを閉じた後は他のセルにフォーカスを当てる
                                    // ＃セルの見た目が編集状態のままとなっている為、tabなどでセル移動できそうで紛らわしい
                                    var idNum = grid.getGridParam("selrow");
                                    $("#" + idNum + " td:eq('" + grid.getColumnIndexByName("no_nonyu") + "')").click();
                                }
                            });
                        }
                    },
                    unformat: unformatDate
                },
                // 明細/納入実績
                    {name: 'su_nonyu_ji', width: pageLangText.su_nonyu_ji_width.number, editable: false, sorttype: "int", align: "right", formatter: 'number',
                    formatoptions: { thousandsSeparator: ",", decimalPlaces: 0, defaultValue: "" }
                },
                // 隠し項目：検索時納入実績
                    {name: 'save_su_nonyu_ji', width: 0, hidden: true, hidedlg: true },
                // 明細/端数
                    {name: 'su_nonyu_hasu', width: pageLangText.su_nonyu_hasu_width.number, editable: false, sorttype: "int", align: "right",
                    formatter: commaReplace,
                    unformat: unCommaReplace,
                    formatoptions: { thousandsSeparator: ",", decimalPlaces: 0, defaultValue: "" }
                },
                // 隠し項目：取引先コード
                    {name: 'cd_torihiki', width: 0, hidden: true, hidedlg: true },
                // 明細/取引先１(物流)
                    {name: 'nm_torihiki', width: pageLangText.nm_torihiki_width.number, editable: false, sorttype: "text", align: 'left' },
                // 隠し項目：取引先コード２
                    {name: 'cd_torihiki2', width: 0, hidden: true, hidedlg: true },
                // 明細/取引先２(商流)
                    {name: 'nm_torihiki2', width: pageLangText.nm_torihiki2_width.number, editable: false, sorttype: "text", align: 'left' },
                // 隠し項目：入庫区分
                    {name: 'kbn_nyuko', width: 0, hidden: true, hidedlg: true },
                // 明細/入庫区分名
                    {name: 'nm_nyuko', width: pageLangText.kbn_nyuko_width.number, editable: true, sorttype: "text", align: "left", edittype: 'select',
                    editoptions: {
                        value: function () {
                            // グリッド内ドロップダウン生成処理
                            return grid.prepareDropdown(comboKbnNyuko, "name", "id");
                        }
                    }
                },
                // 明細/納入単価
                    {name: 'tan_nonyu', width: pageLangText.tan_nonyu_width.number, editable: true, sorttype: "float", align: "right", formatter: 'number',
                    formatoptions: { decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 3, defaultValue: "" }
                },
                // 隠し項目：原資材購入先マスタ納入単価
                    {name: 'ma_tan_nonyu', width: 0, hidden: true, hidedlg: true },
                // 隠し項目：原資材購入先マスタ新納入単価
                    {name: 'ma_tan_nonyu_new', width: 0, hidden: true, hidedlg: true },
                // 隠し項目：原資材購入先マスタ新単価切替日
                    {name: 'ma_dt_tanka_new', width: 0, hidden: true, hidedlg: true, formatter: "date",
                    formatoptions: { srcformat: pageLangText.dateSrcFormat.text, newformat: pageLangText.dateNewFormat.text }
                },
                // 隠し項目：入数
                    {name: 'su_iri', width: 0, hidden: true, hidedlg: true },
                // 明細/金額
                    {name: 'kin_kingaku', width: pageLangText.kin_kingaku_width.number, editable: true, sorttype: "int", align: "right", formatter: 'number',
                    formatoptions: { thousandsSeparator: ",", decimalPlaces: 0, defaultValue: "" }
                },
                // 隠し項目：税区分
                    {name: 'kbn_zei', width: 0, hidden: true, hidedlg: true },
                // 明細/税区分
                    {name: 'nm_zei', width: pageLangText.nm_zei_width.number, editable: true, sorttype: "text", align: "left", edittype: 'select',
                    editoptions: {
                        value: function () {
                            // グリッド内ドロップダウン生成処理
                            return grid.prepareDropdown(comboNmZei, "nm_zei", "kbn_zei");
                        }
                    }
                },
                //// 明細/納入実績日
                //    {name: 'dt_nonyu', width: pageLangText.dt_nonyu_width.number, editable: true, sorttype: "date", align: "center", formatter: "date",
                //    formatoptions: { srcformat: newDateFormat, newformat: newDateFormat },
                //    editoptions: {
                //        dataInit: function (el) {
                //            $(el).on("keyup", App.data.addSlashForDateString);
                //            $(el).datepicker({ dateFormat: datePickerFormat
                //                , onClose: function (dateText, inst) {
                //                    // カレンダーを閉じた後は他のセルにフォーカスを当てる
                //                    // ＃セルの見た目が編集状態のままとなっている為、tabなどでセル移動できそうで紛らわしい
                //                    var idNum = grid.getGridParam("selrow");
                //                    $("#" + idNum + " td:eq('" + (noNonyuCol) + "')").click();
                //                }
                //            });
                //        }
                //    },
                //    unformat: unformatDate
                //},
                // 隠し項目：入庫区分の編集フラグ
                    {name: 'flg_edit_kbn_nyuko', width: 0, hidden: true, hidedlg: true },
                // 隠し項目：入庫区分以外の編集フラグ
                    {name: 'flg_edit_meisai', width: 0, hidden: true, hidedlg: true },
                // 隠し項目：予定の取引先コード１
                    {name: 'cd_torihiki_yotei', width: 0, hidden: true, hidedlg: true },
                // 隠し項目：検索時納入予定日
                    {name: 'save_dt_nonyu_yotei', width: 0, hidden: true, hidedlg: true, formatter: "date",
                    formatoptions: { srcformat: newDateFormat, newformat: newDateFormat }
                },
                // 隠し項目：納入予定番号
                    {name: 'no_nonyu_yotei', width: 0, hidden: true, hidedlg: true },
                // 隠し項目：荷受実績存在フラグ(存在する場合は1)
                    {name: 'isExistsNiukeJisseki', width: 0, hidden: true, hidedlg: true }
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
                    var ids = grid.jqGrid('getDataIDs');
                    for (var i = 0; i < ids.length; i++) {
                        var id = ids[i],
                            suNonyuYo = grid.getCell(id, "su_nonyu_yo"),
                            suNonyuJi = grid.getCell(id, "su_nonyu_ji"),
                            kbnNyuko = grid.getCell(id, "kbn_nyuko");
                        /*
                        if (!App.isUndefOrNull(suNonyuYo)
                        && suNonyuYo.length > 0) {
                        // 明細/納入予定が設定されている場合

                        // 明細/原資材コードを編集不可とする
                        grid.jqGrid('setCell', id, 'cd_hinmei', '', 'not-editable-cell');
                        }*/
                        if (!App.isUndefOrNull(suNonyuJi)
                            && suNonyuJi.length > 0) {
                            // 明細/納入実績が設定されている場合

                            // 明細/納入予定日を編集不可とする
                            grid.jqGrid('setCell', id, 'dt_nonyu_yotei', '', 'not-editable-cell');
                            // 明細/納入予定数を編集不可とする
                            grid.jqGrid('setCell', id, 'su_nonyu_yo', '', 'not-editable-cell');
                            // 明細/品名コードを編集不可とする
                            grid.jqGrid('setCell', id, 'cd_hinmei', '', 'not-editable-cell');
                            // 明細/納入予定端数を編集不可とする
                            grid.jqGrid('setCell', id, 'su_nonyu_yo_hasu', '', 'not-editable-cell');
                        }

                        // 入庫区分の設定
                        var nyukoName = "";
                        if (!App.isUndefOrNull(kbnNyuko)) {
                            for (var j = 0; j < comboKbnNyuko.length; j++) {
                                if (kbnNyuko == comboKbnNyuko[j].id) {
                                    nyukoName = comboKbnNyuko[j].name;
                                    break;
                                }
                            }
                        }
                        grid.setCell(id, "nm_nyuko", nyukoName);

                    }
                    // グリッドの先頭行選択
                    if (ids.length > 0) {
                        $("#1 td:eq('" + (firstCol) + "')").click();
                    }
                },
                beforeEditCell: function (selectedRowId, cellName, value, iRow, iCol) {
                    currentRow = iRow;
                    currentCol = iCol;
                    // Enter キーでカーソルを移動
                    grid.moveCell(cellName, iRow, iCol);
                },
                afterEditCell: function (selectedRowId, cellName, value, iRow, iCol) {
                    // 最終編集行ＩＤを保存
                    lastEditRowId = selectedRowId;

                    // Enter キーでカーソルを移動
                    grid.moveCell(cellName, iRow, iCol);
                },
                beforeSaveCell: function (selectedRowId, cellName, value, iRow, iCol) {
                    if (!validateCell(selectedRowId, cellName, value, iCol)) {
                        // バリデーションエラーの場合、バリデーションエラーフラグを立てる
                        varidErrFlg = true;
                    }
                },
                afterSaveCell: function (selectedRowId, cellName, value, iRow, iCol) {
                    if (!varidErrFlg) {
                        // バリデーションエラーが発生していない場合

                        if (cellName === 'su_nonyu_yo_hasu') {
                            var SuCase = parseFloat(grid.getCell(selectedRowId, 'su_nonyu_yo')),
                                SuHasu = parseFloat(value),
                                SuIri = parseFloat(grid.getCell(selectedRowId, 'su_iri')),
                                cdNonyuTani = grid.getCell(selectedRowId, 'cd_tani_nonyu');

                            if (!App.isNumeric(SuCase)) {
                                SuCase = 0;
                            }

                            if (!App.isNumeric(SuIri) || SuIri == 0) {
                                SuIri = 1;
                            }

                            // 納入単位コードがKgかLの場合は端数がそれぞれgとmlになるので、入数に1000をかける
                            var isKgOrL = cdNonyuTani == pageLangText.kgKanzanKbn.text || cdNonyuTani == pageLangText.lKanzanKbn.text;
                            SuIri = isKgOrL ? (SuIri * 1000) : SuIri;

                            // 丸め処理
                            if (SuIri <= SuHasu) {
                                // 端数に合わせて換算処理を行い、C/S数と端数を再算出
                                var kanzan = App.data.trimFixed(SuCase * SuIri) + SuHasu;
                                SuCase = parseInt(App.data.trimFixed(kanzan / SuIri), 10);
                                SuHasu = App.data.trimFixed(kanzan % SuIri);

                                // 対象セルとchangeSetに反映
                                grid.setCell(selectedRowId, 'su_nonyu_yo', SuCase);
                                grid.setCell(selectedRowId, 'su_nonyu_yo_hasu', SuHasu);
                                changeSetUpdated(selectedRowId, "su_nonyu_yo");
                                changeSetUpdated(selectedRowId, "su_nonyu_yo_hasu");
                                }
                        }

                        // 編集フラグの設定：入庫区分または納入予定日か、それ以外か
                        if (cellName === "nm_nyuko" || cellName === "dt_nonyu_yotei" || cellName === "su_nonyu_yo") {
                            grid.setCell(selectedRowId, "flg_edit_kbn_nyuko", pageLangText.trueFlg.text);
                            changeSetUpdated(selectedRowId, "flg_edit_kbn_nyuko");
                        }
                        else {
                            grid.setCell(selectedRowId, "flg_edit_meisai", pageLangText.trueFlg.text);
                            changeSetUpdated(selectedRowId, "flg_edit_meisai");
                        }

                        // 更新項目設定処理
                        if (cellName === "su_nonyu_ji") {
                            // 明細/納入実績入力時

                            // 変更前レコードの設定
                            updateRow = grid.getRowData(selectedRowId);
                            // 変更データの設定
                            var changeData = setUpdatedChangeData(updateRow);

                            if ((updateRow.su_nonyu_yo != "" || updateRow.su_nonyu_yo_hasu != "")
                                && updateRow.save_su_nonyu_ji === "") {
                                // 納入予定があったデータに対しての納入実績新規登録の場合

                                if (updateRow.su_nonyu_ji != "") {
                                    // 納入実績新規登録の場合

                                    if (!App.isUndefOrNull(changeSet.changeSet.updated[selectedRowId])) {
                                        // 変更状態の変更セットが存在する場合

                                        // 変更状態の変更セットから変更データを削除
                                        changeSet.removeUpdated(selectedRowId);
                                    }
                                    // 追加状態の変更セットに変更データを追加
                                    changeSet.addCreated(selectedRowId, changeData);
                                }
                                else {
                                    // 納入実績新規登録の取消の場合

                                    // 追加状態の変更セットから変更データを削除
                                    changeSet.removeCreated(selectedRowId);
                                }
                            }
                            else {
                                // 納入実績更新の場合

                                // 更新状態の変更セットに変更データを追加
                                changeSet.addUpdated(selectedRowId, "su_nonyu", value, changeData);
                            }
                        }
                        else {
                            // 上記以外の項目入力時

                            // 更新状態の変更セットに変更データを追加
                            changeSetUpdated(selectedRowId, cellName);
                        }

                        // 関連項目設定処理
                        if (cellName === "cd_hinmei") {
                            // 明細/原資材コード入力時

                            // 品名コードの関連情報を設定する
                            setCdHinmeiRelatedValue(selectedRowId, value, null);
                            //if (setCdHinmeiRelatedValue(selectedRowId, value, null)) {
                            // 明細/原資材コード・明細/取引先１(物流)：組み合わせ重複チェック
                            //checkCombinationDuplicate();
                            //}
                        }
                        else if (cellName === "su_nonyu_ji"
                            || cellName === "su_nonyu_hasu"
                            || cellName === "tan_nonyu") {
                            // 明細/納入実績、明細/端数、明細/納入単価入力時

                            // 金額計算処理
                            calcKingaku(selectedRowId);
                        }
                        else if (cellName === "nm_zei") {
                            // 明細/税区分入力時

                            // 隠し項目：税区分の設定
                            grid.setCell(selectedRowId, "kbn_zei", value);
                            // 更新状態の変更セットに変更データを追加
                            changeSetUpdated(selectedRowId, "kbn_zei");
                        }
                        else if (cellName === "dt_nonyu") {
                            // 明細/納入日入力時

                            if (!App.isUndefOrNull(grid.getCell(selectedRowId, "ma_tan_nonyu_new"))
                                && grid.getCell(selectedRowId, "ma_tan_nonyu_new").length > 0
                                && !App.isUndefOrNull(grid.getCell(selectedRowId, "dt_nonyu"))
                                && grid.getCell(selectedRowId, "dt_nonyu").length > 0
                                && grid.getCell(selectedRowId, "ma_dt_tanka_new") <= grid.getCell(selectedRowId, "dt_nonyu")) {
                                // 隠し項目：原資材購入先マスタ新納入単価が設定されている かつ
                                // 隠し項目：原資材購入先マスタ新単価切替日 <= 明細/納入日 の場合

                                // 明細/納入単価に隠し項目：原資材購入先マスタ新納入単価を設定
                                grid.setCell(selectedRowId, "tan_nonyu", grid.getCell(selectedRowId, "ma_tan_nonyu_new"));
                            }
                            else {
                                // 上記以外の場合

                                // 明細/納入単価に隠し項目：原資材購入先マスタ納入単価を設定
                                grid.setCell(selectedRowId, "tan_nonyu", grid.getCell(selectedRowId, "ma_tan_nonyu"));
                            }

                            // 明細/納入単価のバリデーション
                            if (validateCell(selectedRowId, "tan_nonyu", grid.getCell(selectedRowId, "tan_nonyu"), grid.getColumnIndexByName("tan_nonyu"))) {
                                // バリデーションエラーでない場合

                                // 更新状態の変更セットに変更データを追加
                                changeSetUpdated(selectedRowId, "tan_nonyu");
                            }

                            // 金額計算処理
                            calcKingaku(selectedRowId);
                        }
                        else if (cellName === "nm_nyuko") {
                            // 入庫区分コンボボックスのコードの設定

                            // 隠し項目：入庫区分の設定
                            grid.setCell(selectedRowId, "kbn_nyuko", value);
                            // 更新状態の変更セットに変更データを追加
                            changeSetUpdated(selectedRowId, "kbn_nyuko");
                        }

                        // 明細/確定の設定処理
                        /*
                        if (grid.getCell(selectedRowId, "flg_kakutei") === pageLangText.mikakuteiKakuteiFlg.text) {
                        // 明細/確定が未チェックの場合

                        // 明細/確定にチェックを入れる
                        grid.setCell(selectedRowId, "flg_kakutei", pageLangText.kakuteiKakuteiFlg.text);
                        // 更新状態の変更セットに変更データを追加
                        changeSetUpdated(selectedRowId, "flg_kakutei");
                        }
                        */
                    }
                    else {
                        // バリデーションエラーが発生している場合

                        if (cellName === "cd_hinmei") {
                            // 明細/原資材コード入力時

                            // 明細/品分類にnullを設定
                            grid.setCell(selectedRowId, "nm_bunrui", null);
                            // 明細/原資材名にnullを設定
                            grid.setCell(selectedRowId, genshizaiName, null);
                            // 明細/荷姿にnullを設定
                            grid.setCell(selectedRowId, "nm_nisugata_hyoji", null);
                            // 隠し項目：納入単位コードにnullを設定
                            grid.setCell(selectedRowId, "cd_tani_nonyu", null);
                            // 明細/納入単位にnullを設定
                            grid.setCell(selectedRowId, "nm_tani", null);
                            // 隠し項目：納入単位コードにnullを設定
                            grid.setCell(selectedRowId, "cd_tani_nonyu_hasu", null);
                            // 明細/納入単位にnullを設定
                            grid.setCell(selectedRowId, "nm_tani_hasu", null);
                            // 明細/納入単価にnullを設定
                            grid.setCell(selectedRowId, "tan_nonyu", null);
                            changeSetUpdated(selectedRowId, "tan_nonyu");
                            // 隠し項目：税区分にnullを設定
                            grid.setCell(selectedRowId, "kbn_zei", null);
                            changeSetUpdated(selectedRowId, "kbn_zei");
                            // 明細/税区分にnullを設定
                            grid.setCell(selectedRowId, "nm_zei", null);
                            // 隠し項目：取引先コードにnullを設定
                            grid.setCell(selectedRowId, "cd_torihiki", null);
                            changeSetUpdated(selectedRowId, "cd_torihiki");
                            // 明細/取引先１(物流)にnullを設定
                            grid.setCell(selectedRowId, "nm_torihiki", null);
                            // 隠し項目：取引先コード２にnullを設定
                            grid.setCell(selectedRowId, "cd_torihiki2", null);
                            changeSetUpdated(selectedRowId, "cd_torihiki2");
                            // 明細/取引先２(商流)にnullを設定
                            grid.setCell(selectedRowId, "nm_torihiki2", null);
                        }
                        else if (cellName === "su_nonyu_ji"
                            || cellName === "su_nonyu_hasu"
                            || cellName === "tan_nonyu"
                            || cellName === "kin_kingaku") {
                            // 明細/納入実績、明細/端数、明細/納入単価、明細/金額入力時

                            if (isNaN(grid.getCell(selectedRowId, cellName))) {
                                // セルの入力値が数値でない場合

                                // 対象のセルにnullを設定(『NaN』表示のクリア対応)
                                grid.setCell(selectedRowId, cellName, null);
                            }
                        }
                    }

                    // バリデーションエラーフラグの初期化
                    varidErrFlg = false;
                },
                onCellSelect: function (rowid, icol, cellcontent) {
                    // 選択列の設定
                    selectCol = icol;

                    if (selectCol === grid.getColumnIndexByName("no_nonyusho")) {
                        // 明細/納入書番号クリック時

                        // 納入書番号連続設定のチェック状況を取得
                        var setNoNonyusho = $("#set-no-nonyusho").attr("checked");

                        if (!App.isUndefOrNull(setNoNonyusho)) {
                            // 納入書番号連続設定がチェックされている場合

                            // 連続設定用納入書番号にエラーがある場合は、明細/納入書番号の設定をしない
                            var result = $(".part-no-nonyusho").validation().validate();
                            if (!result.errors.length) {
                                //var copyNoNonyusho = copy_no_nonyusho.value;
                                var copyNoNonyusho = $("#copy-no-nonyusho").val();

                                if (!App.isUndefOrNull(copyNoNonyusho)
                                && copyNoNonyusho.length > 0) {
                                    // 連続設定用納入書番号が入力されている場合

                                    // 明細/納入書番号の設定
                                    grid.setCell(rowid, "no_nonyusho", copyNoNonyusho);
                                    // 更新状態の変更セットに変更データを追加
                                    changeSetUpdated(rowid, "no_nonyusho");
                                    // バリデーション実施
                                    validateCell(rowid, "no_nonyusho", copyNoNonyusho, icol);
                                }
                            }
                        }
                    }
                },
                ondblClickRow: function (selectedRowId) {
                    if (nonyuJiseki == pageLangText.kinoNonyuJisekiNyuryokuKa.number) {
                        if (selectCol === grid.getColumnIndexByName("cd_hinmei") || selectCol === grid.getColumnIndexByName(genshizaiName)) {
                            // 明細/原資材コード、明細/原資材名ダブルクリック時

                            //var suNonyuYo = grid.getCell(selectedRowId, "su_nonyu_yo");
                            //if (App.isUndefOrNull(suNonyuYo)
                            //|| suNonyuYo.length === 0) {
                            //    // 明細/納入予定が設定されていない場合
                            var nonyuJissekiSu = grid.jqGrid('getCell', selectedRowId, "save_su_nonyu_ji");
                            if (nonyuJissekiSu.length === 0) {
                                // 「afterSaveCell」などが動作しないよう、隠し項目：納入番号をダミーでクリックして回避する
                                $("#" + selectedRowId + " td:eq('" + grid.getColumnIndexByName("no_nonyu") + "')").click();
                                // ダイアログ：原資材一覧を開く
                                showGenshizaiDialog();
                            }
                        }

                        if (selectCol === grid.getColumnIndexByName("nm_torihiki") || selectCol === grid.getColumnIndexByName("nm_torihiki2")) {
                            // 明細/取引先１(物流)、明細/取引先２(商流)ダブルクリック時

                            var nonyuJissekiSu = grid.jqGrid('getCell', selectedRowId, "save_su_nonyu_ji");
                            if (nonyuJissekiSu.length === 0) {

                                // 「afterSaveCell」などが動作しないよう、隠し項目：納入番号をダミーでクリックして回避する
                            $("#" + selectedRowId + " td:eq('" + grid.getColumnIndexByName("no_nonyu") + "')").click();
                                // 変更前レコードの取得
                                updateRow = grid.getRowData(selectedRowId);
                                // ダイアログ：原資材購入先一覧を開く
                                showGenshizaiKonyuDialog(updateRow.cd_hinmei);
                            }
                        }
                    }
                }
            });
            // カンマ付与
            function commaReplace(cellval, opts, rowData) {
                var str;
                var op = $.extend({}, opts.integer);
                if (opts.colModel !== undefined && !$.fmatter.isUndefined(opts.colModel.formatoptions)) {
                    op = $.extend({}, op, opts.colModel.formatoptions);
                }
                if ($.fmatter.isEmpty(cellval)) {
                    str = op.defaultValue;
                }
                else {
                    str = $.fmatter.util.NumberFormat(cellval, op);
                }
                if (rowData.cd_tani_nonyu == pageLangText.kgKanzanKbn.text
                        || grid.getCell(opts.rowId, "cd_tani_nonyu") == pageLangText.kgKanzanKbn.text
                        || rowData.cd_tani_nonyu == pageLangText.lKanzanKbn.text
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
            }
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
            }

            /// <summary>日付型のセルをunformatします</summary>
            function unformatDate(cellvalue, options) {
                var nbsp = String.fromCharCode(160);
                if (cellvalue == nbsp) {
                    return "";
                }
                return cellvalue;
            }

            /// <summary>納入実績区分の取得</summary>
            var getKbnNonyuJiseki = function () {
                App.deferred.parallel({
                    kbnNonyuJiseki: App.ajax.webgetSync("../Services/FoodProcsService.svc/cn_kino_sentaku()?$filter=kbn_kino eq "
                    	+ pageLangText.kinoNonyuJisekiKbn.number)
                }).done(function (result) {
                    kbnNonyuJiseki = result.successes.kbnNonyuJiseki.d;
                    if (kbnNonyuJiseki.length > 0) {
                        nonyuJiseki = kbnNonyuJiseki[0].kbn_kino_naiyo;
                        if (nonyuJiseki != pageLangText.kinoNonyuJisekiNyuryokuKa.number) {
                            // 「納入実績区分.入力可」以外の場合、参照のみとする(すべての明細は入力不可、入力用ボタンを非表示にする)
                            grid.setColProp('flg_kakutei', { editable: false, formatoptions: { disabled: true} });
                            grid.setColProp('no_nonyusho', { editable: false });
                            grid.setColProp('su_nonyu_ji', { editable: false });
                            grid.setColProp('su_nonyu_hasu', { editable: false });
                            grid.setColProp('tan_nonyu', { editable: false });
                            grid.setColProp('kin_kingaku', { editable: false });
                            grid.setColProp('nm_zei', { editable: false });
                            grid.setColProp('dt_nonyu', { editable: false });
                            $("#add_button").attr("disabled", true).css("display", "none");
                            $("#del_button").attr("disabled", true).css("display", "none");
                            $("#check_button").attr("disabled", true).css("display", "none");
                            $("#genshizai_button").attr("disabled", true).css("display", "none");
                            $("#torihiki_button").attr("disabled", true).css("display", "none");
                            $("#set-no-nonyusho").attr("disabled", true).css("display", "none");
                        }
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
            getKbnNonyuJiseki();

            /// <summary>入庫区分入力区分の取得</summary>
            var getKbnNyukoNyuryoku = function () {
                App.deferred.parallel({
                    kbnNyukoKubun: App.ajax.webgetSync("../Services/FoodProcsService.svc/cn_kino_sentaku()?$filter=kbn_kino eq "
                    	+ pageLangText.kinoNyukoNyuryokuKubun.number)
                }).done(function (result) {
                    kbnNyukoKubun = result.successes.kbnNyukoKubun.d;
                    if (kbnNyukoKubun.length > 0) {
                        nyukoKubun = kbnNyukoKubun[0].kbn_kino_naiyo;
                        if (nyukoKubun != pageLangText.kinoNyukoKubunNyuryokuAri.number) {
                            // 「入庫区分入力区分.入力可」以外の場合、入庫区分は非表示にする
                            grid.jqGrid('hideCol', "nm_nyuko");
                            grid.setColProp('nm_nyuko', { hidedlg: true });
                            if (nonyuJiseki != pageLangText.kinoNonyuJisekiNyuryokuKa.number) {
                                // さらに「納入実績区分.入力可」以外の場合、保存ボタンを非表示にする
                                $(".command [name='save-button']").attr("disabled", false).css("display", "none");
                            }
                        }
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
            getKbnNyukoNyuryoku();

            /// <summary>チェックボックス操作時のグリッド値更新を行います</summary>
            $(document).on("click", "#item-grid .jqgrow td :checkbox", function () {
                if (nonyuJiseki == pageLangText.kinoNonyuJisekiNyuryokuKa.number) {
                    var iCol = $(this).parent("td").parent("tr").find("td").index($(this).parent("td")),
                    selectedRowId = $(this).parent("td").parent("tr").attr("id"),
                    cellName = grid.getGridParam("colModel")[iCol].name,
                    value;
                    saveEdit();

                    // 更新状態の変更データの設定
                    var changeData = setUpdatedChangeData(grid.getRowData(selectedRowId));
                    // 更新値の設定
                    value = changeData[cellName];
                    // 更新状態の変更セットに変更データを追加
                    changeSet.addUpdated(selectedRowId, cellName, value, changeData);
                }
            });

            /// <summary>更新状態の変更セットに変更データを追加します。</summary>
            /// <param name="selectedRowId">選択行ID</param>
            /// <param name="cellName">列名</param>
            var changeSetUpdated = function (selectedRowId, cellName) {
                // 更新状態の変更データの設定
                var changeData = setUpdatedChangeData(grid.getRowData(selectedRowId));
                // 更新値の設定
                var value = changeData[cellName];
                // 更新状態の変更セットに変更データを追加
                changeSet.addUpdated(selectedRowId, cellName, value, changeData);
            };

            /// <summary>品名コードの関連項目を設定します。</summary>
            /// <param name="selectedRowId">選択行ID</param>
            /// <param name="param_cd_hinmei">品名コード</param>
            /// <param name="param_nm_hinmei">品名</param>
            var setCdHinmeiRelatedValue = function (selectedRowId, param_cd_hinmei, param_nm_hinmei) {
                var unique = selectedRowId + "_" + grid.getColumnIndexByName("cd_hinmei");

                var isValid = true;
                App.deferred.parallel({
                    // ローディングの表示
                    loading: App.ui.loading.show(pageLangText.nowProgressing.text),
                    // [品名マスタ]取得SQL
                    maHinmei: App.ajax.webgetSync(
                    "../Services/FoodProcsService.svc/ma_hinmei()?$filter=cd_hinmei eq '"
                    + param_cd_hinmei
                    + "' and (kbn_hin eq "
                    + pageLangText.genryoHinKbn.text
                    + " or kbn_hin eq "
                    + pageLangText.shizaiHinKbn.text
                    + ") and flg_mishiyo eq "
                    + pageLangText.shiyoMishiyoFlg.text
                    + "&$top=1"),
                    // [原資材購入先マスタ]取得SQL
                    maKonyu: App.ajax.webgetSync(
                    "../Services/FoodProcsService.svc/ma_konyu()?$filter=cd_hinmei eq '"
                    + param_cd_hinmei
                    + "' and flg_mishiyo eq "
                    + pageLangText.shiyoMishiyoFlg.text
                    + "&$orderby=no_juni_yusen"
                    + "&$top=1")
                }).done(function (result) {
                    // [品名マスタ]の取得
                    maHinmei = result.successes.maHinmei.d;

                    if (!App.isUndefOrNull(maHinmei) && maHinmei.length > 0) {
                        // [品名マスタ]が取得できた場合
                        // 取得した品名コードを設定
                        //grid.setCell(selectedRowId, "cd_torihiki", data3);
                        changeSetUpdated(selectedRowId, "cd_hinmei");
                        // 明細/入庫区分の編集フラグに更新を入れる
                        grid.setCell(selectedRowId, "flg_edit_kbn_nyuko", 1);
                        // 更新状態の変更セットに変更データを追加
                        changeSetUpdated(selectedRowId, "flg_edit_kbn_nyuko");
                        // 明細/入庫区分以外の編集フラグに更新を入れる
                        grid.setCell(selectedRowId, "flg_edit_meisai", 1);
                        // 更新状態の変更セットに変更データを追加
                        changeSetUpdated(selectedRowId, "flg_edit_meisai");
                        if (App.isUndefOrNull(param_nm_hinmei)) {
                            // 引数の品名が未設定の場合(原資材コード手入力時)

                            // 明細/原資材名に取得した[品名マスタ].[品名]を設定
                            grid.setCell(selectedRowId, genshizaiName, maHinmei[0][genshizaiName]);
                        }

                        if (!App.isUndefOrNull(maHinmei[0]["kbn_hin"])
                            && !App.isUndefOrNull(maHinmei[0]["cd_bunrui"])) {
                            // [品名マスタ].[品区分]、[品名マスタ].[分類コード]がともに取得できた場合

                            // 明細/品分類の設定
                            setNmBunrui(selectedRowId, maHinmei[0]["kbn_hin"], maHinmei[0]["cd_bunrui"]);
                        }
                        else {
                            // [品名マスタ].[品区分]、[品名マスタ].[分類コード]のいずれかが取得できなかった場合

                            // 明細/品分類にnullを設定
                            grid.setCell(selectedRowId, "nm_bunrui", null);
                        }

                        if (!App.isUndefOrNull(maHinmei[0]["kbn_zei"])) {
                            // [品名マスタ].[税区分]が取得できた場合

                            // 隠し項目：税区分に取得した[品名マスタ].[税区分]を設定
                            grid.setCell(selectedRowId, "kbn_zei", maHinmei[0]["kbn_zei"]);
                            changeSetUpdated(selectedRowId, "kbn_zei");
                            // 明細/税区分の設定
                            setNmZei(selectedRowId, maHinmei[0]["kbn_zei"]);
                        }
                        else {
                            // [品名マスタ].[税区分]が取得できなかった場合

                            // 隠し項目：税区分にnullを設定
                            grid.setCell(selectedRowId, "kbn_zei", null);
                            changeSetUpdated(selectedRowId, "kbn_zei");
                            // 明細/税区分にnullを設定
                            grid.setCell(selectedRowId, "nm_zei", null);
                        }

                        // [原資材購入先マスタ]の取得
                        maKonyu = result.successes.maKonyu.d;

                        if (!App.isUndefOrNull(maKonyu)
                            && maKonyu.length > 0) {
                            // [原資材購入先マスタ]が取得できた場合

                            // エラーメッセージの解除
                            App.ui.page.notifyAlert.remove(unique);

                            if (!App.isUndefOrNull(maKonyu[0]["nm_nisugata_hyoji"])) {
                                // [原資材購入先マスタ].[荷姿表示用]が取得できた場合

                                // 明細/荷姿に取得した[原資材購入先マスタ].[荷姿表示用]を設定
                                grid.setCell(selectedRowId, "nm_nisugata_hyoji", maKonyu[0]["nm_nisugata_hyoji"]);
                            }
                            else {
                                // [原資材購入先マスタ].[荷姿表示用]が取得できなかった場合

                                // 明細/荷姿にnullを設定
                                grid.setCell(selectedRowId, "nm_nisugata_hyoji", null);
                            }

                            // 隠し項目：納入単位コードに取得した[原資材購入先マスタ].[納入単位コード]を設定
                            grid.setCell(selectedRowId, "cd_tani_nonyu", maKonyu[0]["cd_tani_nonyu"]);
                            // 明細/納入単位の設定
                            setNmTani(selectedRowId, maKonyu[0]["cd_tani_nonyu"], false);
                           // 隠し項目：納入単位コードに取得した[原資材購入先マスタ].[納入単位コード]を設定
                            grid.setCell(selectedRowId, "cd_tani_nonyu_hasu", maKonyu[0]["cd_tani_nonyu_hasu"]);
                            // 明細/納入単位の設定
                            setNmTani(selectedRowId, maKonyu[0]["cd_tani_nonyu_hasu"], true);
                            // 隠し項目：原資材購入先マスタ納入単価に取得した[原資材購入先マスタ].[納入単価]を設定
                            grid.setCell(selectedRowId, "ma_tan_nonyu", maKonyu[0]["tan_nonyu"]);

                            if (!App.isUndefOrNull(maKonyu[0]["tan_nonyu_new"])
                                && !App.isUndefOrNull(maKonyu[0]["dt_tanka_new"])) {
                                // 取得した[原資材購入先マスタ].[新納入単価]、[原資材購入先マスタ].[新単価切替日]がともにNULL以外の場合

                                // 隠し項目：原資材購入先マスタ新納入単価に取得した[原資材購入先マスタ].[新納入単価]を設定
                                grid.setCell(selectedRowId, "ma_tan_nonyu_new", maKonyu[0]["tan_nonyu_new"]);
                                // 隠し項目：原資材購入先マスタ新単価切替日に取得した[原資材購入先マスタ].[新単価切替日]を設定
                                var dtTankaNew = App.data.getDate(maKonyu[0]["dt_tanka_new"]);
                                grid.setCell(selectedRowId, "ma_dt_tanka_new", App.data.getDateString(dtTankaNew, true));
                            }
                            else {
                                // 上記以外の場合

                                // 隠し項目：原資材購入先マスタ新納入単価にnullを設定
                                grid.setCell(selectedRowId, "ma_tan_nonyu_new", null);
                                // 隠し項目：原資材購入先マスタ新単価切替日にnullを設定
                                grid.setCell(selectedRowId, "ma_dt_tanka_new", null);
                            }

                            if (!App.isUndefOrNull(grid.getCell(selectedRowId, "ma_tan_nonyu_new"))
                                && grid.getCell(selectedRowId, "ma_tan_nonyu_new").length > 0
                                && !App.isUndefOrNull(grid.getCell(selectedRowId, "dt_nonyu"))
                                && grid.getCell(selectedRowId, "dt_nonyu").length > 0
                                && grid.getCell(selectedRowId, "ma_dt_tanka_new") <= grid.getCell(selectedRowId, "dt_nonyu")) {
                                // 隠し項目：原資材購入先マスタ新納入単価が設定されている かつ
                                // 隠し項目：原資材購入先マスタ新単価切替日 <= 明細/納入日 の場合

                                // 明細/納入単価に隠し項目：原資材購入先マスタ新納入単価を設定
                                grid.setCell(selectedRowId, "tan_nonyu", grid.getCell(selectedRowId, "ma_tan_nonyu_new"));
                            }
                            else {
                                // 上記以外の場合

                                // 明細/納入単価に隠し項目：原資材購入先マスタ納入単価を設定
                                grid.setCell(selectedRowId, "tan_nonyu", grid.getCell(selectedRowId, "ma_tan_nonyu"));
                            }

                            // 明細/納入単価のバリデーション
                            if (validateCell(selectedRowId, "tan_nonyu", grid.getCell(selectedRowId, "tan_nonyu"), grid.getColumnIndexByName("tan_nonyu"))) {
                                // バリデーションエラーでない場合

                                // 更新状態の変更セットに変更データを追加
                                changeSetUpdated(selectedRowId, "tan_nonyu");
                            }

                            // 隠し項目：入数に取得した[原資材購入先マスタ].[入数]を設定
                            grid.setCell(selectedRowId, "su_iri", maKonyu[0]["su_iri"]);
                            // 隠し項目：取引先コードに取得した[原資材購入先マスタ].[取引先コード]を設定
                            grid.setCell(selectedRowId, "cd_torihiki", maKonyu[0]["cd_torihiki"]);
                            changeSetUpdated(selectedRowId, "cd_torihiki");
                            // 明細/取引先１(物流)の設定
                            setNmTorihiki(selectedRowId, maKonyu[0]["cd_torihiki"], "nm_torihiki");

                            if (!App.isUndefOrNull(maKonyu[0]["cd_torihiki2"])) {
                                // [原資材購入先マスタ].[取引先コード２]が取得できた場合

                                // 隠し項目：取引先コード２に取得した[原資材購入先マスタ].[取引先コード２]を設定
                                grid.setCell(selectedRowId, "cd_torihiki2", maKonyu[0]["cd_torihiki2"]);
                                changeSetUpdated(selectedRowId, "cd_torihiki2");
                                // 明細/取引先２(商流)の設定
                                setNmTorihiki(selectedRowId, maKonyu[0]["cd_torihiki2"], "nm_torihiki2");
                            }
                            else {
                                // [原資材購入先マスタ].[取引先コード２]が取得できなかった場合

                                // 隠し項目：取引先コード２にnullを設定
                                grid.setCell(selectedRowId, "cd_torihiki2", null);
                                changeSetUpdated(selectedRowId, "cd_torihiki2");
                                // 明細/取引先２(商流)にnullを設定
                                grid.setCell(selectedRowId, "nm_torihiki2", null);
                            }

                            // 金額計算処理
                            calcKingaku(selectedRowId);
                        }
                        else {
                            // [原資材購入先マスタ]が取得できなかった場合

                            // 明細/荷姿にnullを設定
                            grid.setCell(selectedRowId, "nm_nisugata_hyoji", null);
                            // 隠し項目：納入単位コードにnullを設定
                            grid.setCell(selectedRowId, "cd_tani_nonyu", null);
                            // 明細/納入単位にnullを設定
                            grid.setCell(selectedRowId, "nm_tani", null);
                            // 隠し項目：納入単位コードにnullを設定
                            grid.setCell(selectedRowId, "cd_tani_nonyu_hasu", null);
                            // 明細/納入単位にnullを設定
                            grid.setCell(selectedRowId, "nm_tani_hasu", null);
                            // 明細/納入単価にnullを設定
                            grid.setCell(selectedRowId, "tan_nonyu", null);
                            changeSetUpdated(selectedRowId, "tan_nonyu");
                            // 隠し項目：原資材購入先マスタ納入単価にnullを設定
                            grid.setCell(selectedRowId, "ma_tan_nonyu", null);
                            // 隠し項目：原資材購入先マスタ新納入単価にnullを設定
                            grid.setCell(selectedRowId, "ma_tan_nonyu_new", null);
                            // 隠し項目：原資材購入先マスタ新単価切替日にnullを設定
                            grid.setCell(selectedRowId, "ma_dt_tanka_new", null);
                            // 隠し項目：入数にnullを設定
                            grid.setCell(selectedRowId, "su_iri", null);
                            // 隠し項目：取引先コードにnullを設定
                            grid.setCell(selectedRowId, "cd_torihiki", null);
                            changeSetUpdated(selectedRowId, "cd_torihiki");
                            // 明細/取引先１(物流)にnullを設定
                            grid.setCell(selectedRowId, grid.getColumnIndexByName("nm_torihiki"), null, { background: '#ff6666' });
                            // 隠し項目：取引先コード２にnullを設定
                            grid.setCell(selectedRowId, "cd_torihiki2", null);
                            changeSetUpdated(selectedRowId, "cd_torihiki2");
                            // 明細/取引先２(商流)にnullを設定
                            grid.setCell(selectedRowId, "nm_torihiki2", null);

                            // 原資材購入先マスタ存在チェックエラー
                            isValid = false;
                            // 原資材購入先マスタ存在チェックエラーメッセージ表示
                            App.ui.page.notifyAlert.message(App.str.format(pageLangText.konyuNotFound.text), unique).show();
                        }
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
                    // 再チェックで背景色とメッセージのリセット
                    validateCell(selectedRowId, "nm_torihiki", grid.getCell(selectedRowId, "nm_torihiki"), grid.getColumnIndexByName("nm_torihiki"));
                    // 再チェックで背景色とメッセージのリセット
                    validateCell(selectedRowId, "cd_hinmei", grid.getCell(selectedRowId, "cd_hinmei"), grid.getColumnIndexByName("cd_hinmei"));
                    // ローディングの終了
                    App.ui.loading.close();
                });
                return isValid;
            };

            /// <summary>原資材購入先の関連項目を設定します。</summary>
            /// <param name="selectedRowId">選択行ID</param>
            /// <param name="param_cd_hinmei">品名コード</param>
            /// <param name="param_no_juni_yusen">優先順位番号</param>
            var setKonyuRelatedValue = function (selectedRowId, param_cd_hinmei, param_no_juni_yusen) {
                App.deferred.parallel({
                    // ローディングの表示
                    loading: App.ui.loading.show(pageLangText.nowProgressing.text),
                    // [原資材購入先マスタ]取得SQL
                    maKonyu: App.ajax.webgetSync(
                    "../Services/FoodProcsService.svc/ma_konyu()?$filter=cd_hinmei eq '"
                    + param_cd_hinmei
                    + "' and no_juni_yusen eq "
                    + param_no_juni_yusen
                    + " and flg_mishiyo eq "
                    + pageLangText.shiyoMishiyoFlg.text
                    + "&$top=1")
                }).done(function (result) {
                    // [原資材購入先マスタ]の取得
                    maKonyu = result.successes.maKonyu.d;

                    if (!App.isUndefOrNull(maKonyu)
                        && maKonyu.length > 0) {
                        // [原資材購入先マスタ]が取得できた場合

                        if (!App.isUndefOrNull(maKonyu[0]["nm_nisugata_hyoji"])) {
                            // [原資材購入先マスタ].[荷姿表示用]が取得できた場合

                            // 明細/荷姿に取得した[原資材購入先マスタ].[荷姿表示用]を設定
                            grid.setCell(selectedRowId, "nm_nisugata_hyoji", maKonyu[0]["nm_nisugata_hyoji"]);
                        }
                        else {
                            // [原資材購入先マスタ].[荷姿表示用]が取得できなかった場合

                            // 明細/荷姿にnullを設定
                            grid.setCell(selectedRowId, "nm_nisugata_hyoji", null);
                        }

                        // 隠し項目：納入単位コードに取得した[原資材購入先マスタ].[納入単位コード]を設定
                        grid.setCell(selectedRowId, "cd_tani_nonyu", maKonyu[0]["cd_tani_nonyu"]);
                        // 明細/納入単位の設定
                         setNmTani(selectedRowId, maKonyu[0]["cd_tani_nonyu"], false);
                        // 隠し項目：納入単位コードに取得した[原資材購入先マスタ].[納入単位コード]を設定
                        grid.setCell(selectedRowId, "cd_tani_nonyu_hasu", maKonyu[0]["cd_tani_nonyu_hasu"]);
                        // 明細/納入単位の設定
                        setNmTani(selectedRowId, maKonyu[0]["cd_tani_nonyu_hasu"], true);
                        // 隠し項目：原資材購入先マスタ納入単価に取得した[原資材購入先マスタ].[納入単価]を設定
                        grid.setCell(selectedRowId, "ma_tan_nonyu", maKonyu[0]["tan_nonyu"]);

                        if (!App.isUndefOrNull(maKonyu[0]["tan_nonyu_new"])
                            && !App.isUndefOrNull(maKonyu[0]["dt_tanka_new"])) {
                            // 取得した[原資材購入先マスタ].[新納入単価]、[原資材購入先マスタ].[新単価切替日]がともにNULL以外の場合

                            // 隠し項目：原資材購入先マスタ新納入単価に取得した[原資材購入先マスタ].[新納入単価]を設定
                            grid.setCell(selectedRowId, "ma_tan_nonyu_new", maKonyu[0]["tan_nonyu_new"]);
                            // 隠し項目：原資材購入先マスタ新単価切替日に取得した[原資材購入先マスタ].[新単価切替日]を設定
                            var dtTankaNew = App.data.getDate(maKonyu[0]["dt_tanka_new"]);
                            grid.setCell(selectedRowId, "ma_dt_tanka_new", App.data.getDateString(dtTankaNew, true));
                        }
                        else {
                            // 上記以外の場合

                            // 隠し項目：原資材購入先マスタ新納入単価にnullを設定
                            grid.setCell(selectedRowId, "ma_tan_nonyu_new", null);
                            // 隠し項目：原資材購入先マスタ新単価切替日にnullを設定
                            grid.setCell(selectedRowId, "ma_dt_tanka_new", null);
                        }

                        if (!App.isUndefOrNull(grid.getCell(selectedRowId, "ma_tan_nonyu_new"))
                            && grid.getCell(selectedRowId, "ma_tan_nonyu_new").length > 0
                            && !App.isUndefOrNull(grid.getCell(selectedRowId, "dt_nonyu"))
                            && grid.getCell(selectedRowId, "dt_nonyu").length > 0
                            && grid.getCell(selectedRowId, "ma_dt_tanka_new") <= grid.getCell(selectedRowId, "dt_nonyu")) {
                            // 隠し項目：原資材購入先マスタ新納入単価が設定されている かつ
                            // 隠し項目：原資材購入先マスタ新単価切替日 <= 明細/納入日 の場合

                            // 明細/納入単価に隠し項目：原資材購入先マスタ新納入単価を設定
                            grid.setCell(selectedRowId, "tan_nonyu", grid.getCell(selectedRowId, "ma_tan_nonyu_new"));
                        }
                        else {
                            // 上記以外の場合

                            // 明細/納入単価に隠し項目：原資材購入先マスタ納入単価を設定
                            grid.setCell(selectedRowId, "tan_nonyu", grid.getCell(selectedRowId, "ma_tan_nonyu"));
                        }

                        // 明細/納入単価のバリデーション
                        if (validateCell(selectedRowId, "tan_nonyu", grid.getCell(selectedRowId, "tan_nonyu"), grid.getColumnIndexByName("tan_nonyu"))) {
                            // バリデーションエラーでない場合

                            // 更新状態の変更セットに変更データを追加
                            changeSetUpdated(selectedRowId, "tan_nonyu");
                        }

                        // 隠し項目：入数に取得した[原資材購入先マスタ].[入数]を設定
                        grid.setCell(selectedRowId, "su_iri", maKonyu[0]["su_iri"]);

                        // 金額計算処理
                        calcKingaku(selectedRowId);
                    }
                    else {
                        // [原資材購入先マスタ]が取得できなかった場合

                        // 明細/荷姿にnullを設定
                        grid.setCell(selectedRowId, "nm_nisugata_hyoji", null);
                        // 隠し項目：納入単位コードにnullを設定
                        grid.setCell(selectedRowId, "cd_tani_nonyu", null);
                        // 明細/納入単位にnullを設定
                        grid.setCell(selectedRowId, "nm_tani", null);
                        // 隠し項目：納入単位コードにnullを設定
                        grid.setCell(selectedRowId, "cd_tani_nonyu_hasu", null);
                        // 明細/納入単位にnullを設定
                        grid.setCell(selectedRowId, "nm_tani_hasu", null);
                        // 明細/納入単価にnullを設定
                        grid.setCell(selectedRowId, "tan_nonyu", null);
                        changeSetUpdated(selectedRowId, "tan_nonyu");
                        // 隠し項目：原資材購入先マスタ納入単価にnullを設定
                        grid.setCell(selectedRowId, "ma_tan_nonyu", null);
                        // 隠し項目：原資材購入先マスタ新納入単価にnullを設定
                        grid.setCell(selectedRowId, "ma_tan_nonyu_new", null);
                        // 隠し項目：原資材購入先マスタ新単価切替日にnullを設定
                        grid.setCell(selectedRowId, "ma_dt_tanka_new", null);
                        // 隠し項目：入数にnullを設定
                        grid.setCell(selectedRowId, "su_iri", null);
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

            /// <summary>分類名を設定します。</summary>
            /// <param name="selectedRowId">選択行ID</param>
            /// <param name="param_kbn_hin">品区分</param>
            /// <param name="param_cd_bunrui">分類コード</param>
            var setNmBunrui = function (selectedRowId, param_kbn_hin, param_cd_bunrui) {
                App.deferred.parallel({
                    // [分類マスタ]取得SQL
                    maBunrui: App.ajax.webgetSync(
                    "../Services/FoodProcsService.svc/ma_bunrui()?$filter=kbn_hin eq "
                    + param_kbn_hin
                    + " and cd_bunrui eq '"
                    + param_cd_bunrui
                    + "' and flg_mishiyo eq "
                    + pageLangText.shiyoMishiyoFlg.text
                    + "&$top=1")
                }).done(function (result) {
                    // [分類マスタ]の取得
                    maBunrui = result.successes.maBunrui.d;

                    if (!App.isUndefOrNull(maBunrui)
                        && maBunrui.length > 0) {
                        // [分類マスタ]が取得できた場合

                        // 明細/品分類に取得した[分類マスタ].[分類名]を設定
                        grid.setCell(selectedRowId, "nm_bunrui", maBunrui[0]["nm_bunrui"]);
                    }
                    else {
                        // [分類マスタ]が取得できなかった場合

                        // 明細/品分類にnullを設定
                        grid.setCell(selectedRowId, "nm_bunrui", null);
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

            /// <summary>税名を設定します。</summary>
            /// <param name="selectedRowId">選択行ID</param>
            /// <param name="param_kbn_zei">税区分</param>
            var setNmZei = function (selectedRowId, param_kbn_zei) {
                App.deferred.parallel({
                    // [税マスタ]取得SQL
                    maZei: App.ajax.webgetSync(
                    "../Services/FoodProcsService.svc/ma_zei()?$filter=kbn_zei eq "
                    + param_kbn_zei
                    + "&$top=1")
                }).done(function (result) {
                    // [税マスタ]の取得
                    maZei = result.successes.maZei.d;

                    if (!App.isUndefOrNull(maZei)
                        && maZei.length > 0) {
                        // [税マスタ]が取得できた場合

                        // 明細/税区分に取得した[税マスタ].[税名]を設定
                        grid.setCell(selectedRowId, "nm_zei", maZei[0]["nm_zei"]);
                    }
                    else {
                        // [税マスタ]が取得できなかった場合

                        // 明細/税区分にnullを設定
                        grid.setCell(selectedRowId, "nm_zei", null);
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

            /// <summary>単位名を設定します。</summary>
            /// <param name="selectedRowId">選択行ID</param>
            /// <param name="param_cd_tani">単位コード</param>
             var setNmTani = function (selectedRowId, param_cd_tani, isPartial) {
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

                        // 明細/納入単位に取得した[単位マスタ].[単位名]を設定
                        grid.setCell(selectedRowId, (isPartial ? "nm_tani_hasu" : "nm_tani"), maTani[0]["nm_tani"]);
                    }
                    else {
                        // [単位マスタ]が取得できなかった場合

                        // 明細/納入単位にnullを設定
                        grid.setCell(selectedRowId, (isPartial ? "nm_tani_hasu" : "nm_tani"), null);
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

            /// <summary>取引先名を設定します。</summary>
            /// <param name="selectedRowId">選択行ID</param>
            /// <param name="param_cd_torihiki">取引先コード</param>
            /// <param name="cellName">列名</param>
            var setNmTorihiki = function (selectedRowId, param_cd_torihiki, cellName) {
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

                        // 指定された列に取得した[取引先マスタ].[取引先名]を設定
                        grid.setCell(selectedRowId, cellName, maTorihiki[0]["nm_torihiki"]);
                    }
                    else {
                        // [取引先マスタ]が取得できなかった場合

                        // 指定された列にnullを設定
                        grid.setCell(selectedRowId, cellName, null);
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

            /// <summary>明細/金額を計算します。</summary>
            /// <param name="selectedRowId">選択行ID</param>
            var calcKingaku = function (selectedRowId) {
                var wkTanNonyu,
                    wkSuNonyu,
                    wkHasu,
                    wkSuIri,
                    wkKingaku;
                if (!App.isUndefOrNull(grid.getCell(selectedRowId, "su_nonyu_ji"))
                    && grid.getCell(selectedRowId, "su_nonyu_ji").length > 0
                    && !App.isUndefOrNull(grid.getCell(selectedRowId, "tan_nonyu"))
                    && grid.getCell(selectedRowId, "tan_nonyu").length > 0
                    && !App.isUndefOrNull(grid.getCell(selectedRowId, "su_iri"))
                    && grid.getCell(selectedRowId, "su_iri").length > 0) {
                    // 明細/納入実績、明細/納入単価、隠し項目：入数が全て設定されている場合

                    // ワーク納入単価、ワーク納入実績、ワーク入数の設定
                    wkTanNonyu = parseFloat(grid.getCell(selectedRowId, "tan_nonyu"));
                    wkSuNonyu = parseInt(grid.getCell(selectedRowId, "su_nonyu_ji"));
                    wkSuIri = parseInt(grid.getCell(selectedRowId, "su_iri"));

                    if (!App.isUndefOrNull(grid.getCell(selectedRowId, "su_nonyu_hasu"))
                        && grid.getCell(selectedRowId, "su_nonyu_hasu").length > 0) {
                        // 明細/端数が設定されている場合
                        if (grid.getCell(selectedRowId, "cd_tani_nonyu") == pageLangText.kgKanzanKbn.text
                            || grid.getCell(selectedRowId, "cd_tani_nonyu") == pageLangText.lKanzanKbn.text) {
                            wkHasu = parseInt(grid.getCell(selectedRowId, "su_nonyu_hasu").replace(".", ""), 10);
                            //parseInt(".101".replace(".", ""), 10).toString();
                        } else {
                            // ワーク端数に明細/端数を設定
                            wkHasu = parseInt(grid.getCell(selectedRowId, "su_nonyu_hasu"));
                        }
                    }
                    else {
                        // 明細/端数が設定されていない場合

                        // ワーク端数に『0』を設定
                        wkHasu = 0;
                    }

                    if (wkSuIri != 0) {
                        // ワーク入数 != 0 の場合

                        if (grid.getCell(selectedRowId, "cd_tani_nonyu") === pageLangText.kgKanzanKbn.text
                            || grid.getCell(selectedRowId, "cd_tani_nonyu") === pageLangText.lKanzanKbn.text) {
                            // 隠し項目：納入単位コード = 「Ｋｇ」 または 「Ｌ」 の場合

                            // ワーク金額 = ワーク納入単価 * (ワーク納入実績 + (ワーク端数 / ワーク入数 / 1000))
                            wkKingaku = wkTanNonyu * (wkSuNonyu + (wkHasu / wkSuIri / 1000));
                        }
                        else {
                            // 上記以外の場合

                            // ワーク金額 = ワーク納入単価 * (ワーク納入実績 + (ワーク端数 / ワーク入数))
                            wkKingaku = wkTanNonyu * (wkSuNonyu + (wkHasu / wkSuIri));
                        }
                    }
                    else {
                        // ワーク入数 = 0 の場合

                        // ワーク金額 = ワーク納入単価 * ワーク納入実績
                        wkKingaku = wkTanNonyu * wkSuNonyu;
                    }

                    // 明細/金額の設定
                    grid.setCell(selectedRowId, "kin_kingaku", wkKingaku);

                    // 明細/金額のバリデーション
                    if (validateCell(selectedRowId, "kin_kingaku", wkKingaku, grid.getColumnIndexByName("kin_kingaku"))) {
                        // バリデーションエラーでない場合

                        // 更新状態の変更セットに変更データを追加
                        changeSetUpdated(selectedRowId, "kin_kingaku");
                    }
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
                // ローディングの表示
                loading: App.ui.loading.show(pageLangText.nowProgressing.text),
                // コンボボックス：検索条件/品区分の抽出SQL(品区分 = 原料 OR 資材 で抽出)
                comboKbnHin: App.ajax.webget(
                    "../Services/FoodProcsService.svc/ma_kbn_hin()?$filter=kbn_hin eq "
                    + pageLangText.genryoHinKbn.text
                    + " or kbn_hin eq "
                    + pageLangText.shizaiHinKbn.text
                    + "&$orderby=kbn_hin"),
                // コンボボックス：検索条件/品位状態の抽出SQL(未使用フラグ = 使用 で抽出)
                comboJotaiHini: App.ajax.webget(
                    "../Services/FoodProcsService.svc/ma_kbn_hokan()?$filter=flg_mishiyo eq "
                    + pageLangText.shiyoMishiyoFlg.text
                    + "&$orderby=cd_hokan_kbn"),
                // グリッド内ドロップダウン：明細/税区分の抽出SQL 
                comboNmZei: App.ajax.webget(
                    "../Services/FoodProcsService.svc/ma_zei()?$orderby=kbn_zei")
            }).done(function (result) {
                // コンボボックス：検索条件/品区分の設定
                comboKbnHin = result.successes.comboKbnHin.d;
                var targetHin = $("#condition-kbn_hin");
                App.ui.appendOptions(targetHin, "kbn_hin", "nm_kbn_hin", comboKbnHin, true);

                // コンボボックス：検索条件/品分類の作成
                createBunruiCombobox();

                // コンボボックス：検索条件/品位状態の設定
                comboJotaiHini = result.successes.comboJotaiHini.d;
                var targetJotai = $("#condition-kbn_hokan");
                App.ui.appendOptions(targetJotai, "cd_hokan_kbn", "nm_hokan_kbn", comboJotaiHini, true);

                // グリッド内ドロップダウン：明細/税区分の設定
                comboNmZei = result.successes.comboNmZei.d;
                if (comboNmZei.length > 0) {
                    // 初期値用の税区分を設定
                    initKbnZei = comboNmZei[0].kbn_zei;
                    initNmZei = comboNmZei[0].nm_zei;
                }

                // 検索条件/日付に当日日付を設定する
                $("#condition-dt_nonyu").datepicker("setDate", new Date());
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

            // コンボボックス：検索条件/品分類の作成処理
            var createBunruiCombobox = function () {
                var criteria = $(".search-criteria").toJSON();
                App.deferred.parallel({
                    comboBunruiHin: App.ajax.webget(
                        "../Services/FoodProcsService.svc/ma_bunrui?$filter=kbn_hin eq "
                        + criteria.con_kbn_hin
                        + " and flg_mishiyo eq "
                        + pageLangText.shiyoMishiyoFlg.text
                        + "&$orderby=cd_bunrui")
                }).done(function (result) {
                    // コンボボックス：検索条件/品分類の設定
                    comboBunruiHin = result.successes.comboBunruiHin.d;
                    $("#condition-bunrui_hin > option").remove();
                    App.ui.appendOptions($("#condition-bunrui_hin"), "cd_bunrui", "nm_bunrui", comboBunruiHin, true);
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

            //// 事前データロード -- End

            //// 検索処理 -- Start

            // 画面アーキテクチャ共通の検索処理

            /// <summary>クエリオブジェクトの設定</summary>
            var queryWeb = function () {
                var criteria = $(".search-criteria").toJSON(),
                    query = {
                        url: "../api/NonyuYoteiListSakusei",
                        con_dt_nonyu: App.data.getDateTimeStringForQueryNoUtc(criteria.con_dt_nonyu),
                        con_kbn_hin: criteria.con_kbn_hin,
                        con_cd_bunrui: criteria.con_cd_bunrui,
                        con_kbn_hokan: criteria.con_kbn_hokan,
                        con_cd_torihiki: criteria.con_cd_torihiki,
                        flg_yojitsu_yo: pageLangText.yoteiYojitsuFlg.text,
                        flg_yojitsu_ji: pageLangText.jissekiYojitsuFlg.text,
                        flg_mishiyo: pageLangText.shiyoMishiyoFlg.text
                    };
                return query;
            };

            /// <summary>検索条件を保持する</summary>
            var saveSearchCriteria = function () {
                var criteria = $(".search-criteria").toJSON();
                searchCriteriaSet = {
                    "con_dt_nonyu": criteria.con_dt_nonyu,
                    "con_kbn_hin": criteria.con_kbn_hin,
                    "con_cd_bunrui": criteria.con_cd_bunrui,
                    "con_kbn_hokan": criteria.con_kbn_hokan,
                    "con_flg_torihiki": criteria.con_flg_torihiki,
                    "con_cd_torihiki": criteria.con_cd_torihiki
                };
            };

            /// <summary>検索条件の変更チェック</summary>
            var noChangeCriteria = function () {
                var criteria = $(".search-criteria").toJSON();
                if (App.isUndefOrNull(searchCriteriaSet)
                    || searchCriteriaSet.length === 0
                    || (criteria.con_dt_nonyu.toString() === searchCriteriaSet.con_dt_nonyu.toString()
                        && criteria.con_kbn_hin === searchCriteriaSet.con_kbn_hin
                        && criteria.con_cd_bunrui === searchCriteriaSet.con_cd_bunrui
                        && criteria.con_kbn_hokan === searchCriteriaSet.con_kbn_hokan
                        && criteria.con_flg_torihiki === searchCriteriaSet.con_flg_torihiki
                        && criteria.con_cd_torihiki === searchCriteriaSet.con_cd_torihiki)) {
                    // 検索条件が指定されていなかった または 検索条件が変更されていない場合、変更なしを返却する
                    return true;
                }
                // 検索条件が変更されている場合、変更ありを返却する
                return false;
            };

            /// <summary>データ検索を行います。</summary>
            /// <param name="queryweb">クエリオブジェクト</param>
            var searchItems = function (queryWeb) {
                if (isDataLoading === true) {
                    return;
                }
                isDataLoading = true;
                // ローディングの表示
                $("#list-loading-message").text(
                    App.str.format(
                        pageLangText.nowListLoading.text,
                        querySetting.skip + 1,
                        querySetting.top
                    )
                );
                // 検索条件の保持
                saveSearchCriteria();
                // 検索条件を元にデータを取得
                App.ajax.webget(
                    App.data.toWebAPIFormat(queryWeb)
                ).done(function (result) {
                    // 検索フラグを立てる
                    isSearch = true;
                    // データバインド
                    bindData(result);
                    if (result.length > 0) {
                        // 該当データが存在した場合、検索条件を閉じる
                        closeCriteria();
                        isCriteriaChange = false;
                    }
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

            /// <summary>検索処理を行います。</summary>
            var findData = function () {
                // エラーフラグ
                var flgErr = false;
                // ダイアログを閉じる
                closeSearchConfirmDialog();
                // 検索前の状態に初期化
                clearState();
                // 検索前バリデーション
                var result = $(".search-criteria").validation().validate();
                if (result.errors.length) {
                    flgErr = true;
                }
                // 取引先コード必須入力チェック
                var criteria = $(".search-criteria").toJSON();
                if (criteria.con_flg_torihiki === pageLangText.conFlgTorihiki_sentaku.text
                    && App.isUndefOrNull(criteria.con_cd_torihiki)) {
                    App.ui.page.notifyAlert.message(
                        App.str.format(pageLangText.required.text, pageLangText.con_cd_torihiki.text), $("#condition-cd_torihiki")).show();
                    flgErr = true;
                }
                // エラー処理
                if (flgErr) {
                    return;
                }
                // データ検索
                searchItems(new queryWeb());
            };

            /// <summary>検索ボタンクリック時のイベント処理を行います。</summary>
            $(".find-button").on("click", showSearchConfirmDialog);

            // グリッドコントロール固有の検索処理

            /// <summary>検索前の状態に初期化します。</summary>
            var clearState = function () {
                // データクリア
                grid.clearGridData();
                // 各変数の初期化
                querySetting.skip = 0;
                querySetting.count = 0;
                displayCount();
                currentRow = 0;
                currentCol = firstCol;
                // 変更セットの再作成
                changeSet = new App.ui.page.changeSet();
                isSearch = false;
                isCriteriaChange = false;

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
                querySetting.count = result.length;
                if (result.length > querySetting.top) {
                    // 検索結果件数が上限数を超えた場合

                    // 超過分を検索結果から削除する
                    result.splice(querySetting.top, result.length);
                    querySetting.skip = result.length;
                    App.ui.page.notifyAlert.message(pageLangText.limitOver.text).show();
                }

                // グリッドの表示件数を更新
                grid.setGridParam({ rowNum: querySetting.skip });
                displayCount();
                // データバインド
                var currentData = grid.getGridParam("data").concat(result);
                grid.setGridParam({ data: currentData }).trigger('reloadGrid', [{ current: true}]);
                if (querySetting.count <= 0) {
                    App.ui.page.notifyAlert.message(pageLangText.notFound.text).show();
                }
                else {
                    App.ui.page.notifyInfo.message(
                        App.str.format(pageLangText.searchResultCount.text, querySetting.skip, querySetting.count)).show();
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
                grid.editCell(iRow, info.iCol, true);
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
                // 検索条件の取得
                var criteria = $(".search-criteria").toJSON();

                var kbnNyuko = null,
                    nmNyuko = null;
                if (nyukoKubun == pageLangText.kinoNyukoKubunNyuryokuAri.number) {
                    // 入庫区分入力区分が「あり」の場合のみ、初期値を設定する
                    kbnNyuko = pageLangText.nyukoKunbunId.data[0].id;
                    nmNyuko = pageLangText.nyukoKunbunId.data[0].name;
                }

                // 新規行の設定
                var addData = {
                    "no_nonyu": null,
                    "flg_kakutei": pageLangText.mikakuteiKakuteiFlg.text,
                    "no_nonyusho": null,
                    "nm_bunrui": null,
                    "cd_hinmei": null,
                    "nm_genshizai": null,
                    "nm_nisugata_hyoji": null,
                    "cd_tani_nonyu": null,
                    "nm_tani": null,
                    "cd_tani_nonyu_hasu": null,
                    "nm_tani_hasu": null,
                    "su_nonyu_yo": null,
                    "su_nonyu_yo_hasu": null,
                    "su_nonyu_ji": null,
                    "save_su_nonyu_ji": null,
                    "su_nonyu_hasu": null,
                    "tan_nonyu": null,
                    "ma_tan_nonyu": null,
                    "ma_tan_nonyu_new": null,
                    "ma_dt_tanka_new": null,
                    "su_iri": null,
                    "kin_kingaku": null,
                    "kbn_nyuko": kbnNyuko,
                    "nm_nyuko": nmNyuko,
                    "kbn_zei": initKbnZei,
                    "nm_zei": initNmZei,
                    "cd_torihiki": null,
                    "nm_torihiki": null,
                    "cd_torihiki2": null,
                    "nm_torihiki2": null,
                    "dt_nonyu": null,
                    "dt_nonyu_yotei": null,
                    "flg_edit_meisai": pageLangText.trueFlg.text
                };

                return addData;
            };

            /// <summary>追加状態の変更セットに追加する変更データの設定を行います。</summary>
            /// <param name="newRow">新規行データ</param>
            var setCreatedChangeData = function (newRow) {
                var changeData = {
                    "flg_yojitsu": pageLangText.jissekiYojitsuFlg.text,
                    "no_nonyu": null,
                    "dt_nonyu": App.data.getDateTimeStringForQueryNoUtc(new Date(newRow.dt_nonyu)),
                    "cd_hinmei": newRow.cd_hinmei,
                    "su_nonyu": newRow.su_nonyu_ji,
                    "su_nonyu_hasu": newRow.su_nonyu_hasu,
                    "cd_torihiki": newRow.cd_torihiki,
                    "cd_torihiki2": newRow.cd_torihiki2,
                    "tan_nonyu": newRow.tan_nonyu,
                    "kin_kingaku": newRow.kin_kingaku,
                    "kbn_nyuko": newRow.kbn_nyuko,
                    "no_nonyusho": newRow.no_nonyusho,
                    "kbn_zei": newRow.kbn_zei,
                    "kbn_denso": null,
                    "flg_kakutei": newRow.flg_kakutei,
                    "dt_seizo": null,
                    "dt_nonyu_yotei": App.data.getDateTimeStringForQueryNoUtc(new Date(newRow.dt_nonyu_yotei)),
                    "flg_edit_kbn_nyuko": newRow.flg_edit_kbn_nyuko,
                    "flg_edit_meisai": newRow.flg_edit_meisai,
                    "su_nonyu_yo": newRow.su_nonyu_yo,
                    "su_nonyu_yo_hasu": newRow.su_nonyu_yo_hasu
                };

                return changeData;
            };

            /// <summary>新規行を追加します。</summary>
            /// <param name="e">イベントデータ</param>
            var addData = function (e) {
                // 選択行のID取得と任意の位置の設定
                var selectedRowId = getSelectedRowId(true),
                    position = "after";
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

                // 明細/納入予定日を編集不可とする
                //grid.jqGrid('setCell', newRowId, 'dt_nonyu_yotei', '', 'not-editable-cell');

                // セルを選択して入力モードにする
                grid.editCell(currentRow + 1, firstCol, true);
            };

            /// <summary>行追加ボタンクリック時のイベント処理を行います。</summary>
            $(".lineadd-button").on("click", function (e) {
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

            /// <summary>更新状態の変更セットに追加する変更データの設定を行います。</summary>
            /// <param name="row">選択行</param>
            var setUpdatedChangeData = function (row) {
                var changeData = {
                    "flg_yojitsu": pageLangText.jissekiYojitsuFlg.text,
                    "no_nonyu": row.no_nonyu,
                    "dt_nonyu": App.data.getDateTimeStringForQueryNoUtc(App.date.localDate(row.dt_nonyu)),
                    "cd_hinmei": row.cd_hinmei,
                    "su_nonyu": row.su_nonyu_ji,
                    "su_nonyu_hasu": row.su_nonyu_hasu,
                    "cd_torihiki": row.cd_torihiki,
                    "cd_torihiki2": row.cd_torihiki2,
                    "tan_nonyu": row.tan_nonyu,
                    "kin_kingaku": row.kin_kingaku,
                    "kbn_nyuko": row.kbn_nyuko,
                    "no_nonyusho": row.no_nonyusho,
                    "kbn_zei": row.kbn_zei,
                    "kbn_denso": null,
                    "flg_kakutei": row.flg_kakutei,
                    "dt_seizo": null,
                    "dt_nonyu_yotei": App.data.getDateTimeStringForQueryNoUtc(App.date.localDate(row.dt_nonyu_yotei)),
                    "flg_edit_kbn_nyuko": row.flg_edit_kbn_nyuko,
                    "flg_edit_meisai": row.flg_edit_meisai,
                    "su_nonyu_yo": row.su_nonyu_yo,
                    "su_nonyu_yo_hasu": row.su_nonyu_yo_hasu,
                    "no_nonyu_yotei": row.no_nonyu_yotei
                };

                return changeData;
            };

            /// <summary>削除状態の変更セットに追加する変更データの設定を行います。</summary>
            /// <param name="row">選択行</param>
            var setDeletedChangeData = function (row) {
                var changeData = {
                    "flg_yojitsu": null,
                    "no_nonyu": row.no_nonyu,
                    "dt_nonyu": null,
                    "cd_hinmei": row.cd_hinmei,
                    "su_nonyu": null,
                    "su_nonyu_hasu": null,
                    "cd_torihiki": row.cd_torihiki,
                    "cd_torihiki2": null,
                    "tan_nonyu": null,
                    "kin_kingaku": null,
                    "kbn_nyuko": row.kbn_nyuko,
                    "no_nonyusho": row.no_nonyusho,
                    "kbn_zei": null,
                    "kbn_denso": null,
                    "flg_kakutei": null,
                    "dt_seizo": null,
                    "dt_nonyu_yotei": null
                };

                return changeData;
            };

            /// <summary>行を削除します。</summary>
            /// <param name="e">イベントデータ</param>
            var deleteData = function (e) {
                // 選択行のID取得
                var selectedRowId = getSelectedRowId();
                if (App.isUndefOrNull(selectedRowId)) {
                    return;
                }

                // 荷受実績がある場合はエラーを表示して処理を中止します。
                App.ui.page.notifyAlert.clear();
                if (grid.getCell(selectedRowId, "isExistsNiukeJisseki") === pageLangText.trueFlg.text) {
                    App.ui.page.notifyAlert.message(pageLangText.niukeJissekiExists.text).show();
                    return;
                }

                App.ui.page.notifyAlert.clear();
                var isCheck = CheckExistsDataNiuke(selectedRowId);
                if (isCheck) {
                    App.ui.page.notifyAlert.message(pageLangText.canNotUpdateDataOld.text).show();
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
                    // 最終編集行ＩＤを保存
                    lastEditRowId = getSelectedRowId();
                }
            };

            /// <summary>行削除ボタンクリック時のイベント処理を行います。</summary>
            $(".linedelete-button").on("click", function (e) {
                // 検索条件変更チェック
                if (isCriteriaChange) {
                    showCriteriaChange("lineDel");
                    return;
                }
                deleteData();
            });


            /// <summary>Check Exists Data Niuke。</summary>
            /// <param name="selectedRowId"></param>
            var CheckExistsDataNiuke = function (selectedRowId) {
                var isValid = false,
                    strId = "#" + currentRow + "_{0}",
                    val_no_nonyu = grid.getCell(selectedRowId, "no_nonyu"),
                    val_cd_hinmei = App.isUndefOrNull($(App.str.format(strId, "cd_hinmei")).val())
                                    ? grid.getCell(selectedRowId, "cd_hinmei") : $(App.str.format(strId, "cd_hinmei")).val();
                

                if ((App.isUndefOrNull(val_cd_hinmei) || val_cd_hinmei == "") ||
                    (App.isUndefOrNull(val_no_nonyu) || val_no_nonyu == "")) {
                    return isValid;
                }

                var query = {
                    url: "../api/NonyuYoteiListSakusei/GetExistsDataActualDelivery",
                    p_no_nonyu: val_no_nonyu,
                    p_cd_hinmei: val_cd_hinmei
                };

                App.ajax.webgetSync(
                    App.data.toWebAPIFormat(query)
                ).done(function (result) {
                    isValid = result;
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                });
                return isValid;
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

                if (!App.isArray(ret)
                    && App.isUndefOrNull(ret.Updated)
                    && App.isUndefOrNull(ret.Deleted)) {
                    App.ui.page.notifyAlert.message(result.message).show();
                    return;
                }

                // 更新時同時実行制御エラーのハンドリングを行います。
                if (!App.isUndefOrNull(ret.Updated)
                    && ret.Updated.length > 0) {
                    for (var i = 0; i < ret.Updated.length; i++) {

                        // 他のユーザーによって削除されていた場合
                        if (App.isUndefOrNull(ret.Updated[i].Current)) {

                            // エラーメッセージの表示
                            App.ui.page.notifyAlert.message(
                                pageLangText.duplicate.text + pageLangText.deletedDuplicate.text).show();
                        }
                    }
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

                var saveUrl = "../api/NonyuYoteiListSakusei";

                App.ajax.webpost(
                    saveUrl, getPostData()
                ).done(function (result) {
                    // 検索前の状態に初期化
                    clearState();
                    // 正常終了メッセージ出力
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
                // 最終編集行ＩＤのクリア
                lastEditRowId = null;
                // 情報メッセージのクリア
                App.ui.page.notifyInfo.clear();
                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();
                // 編集内容の保存
                saveEdit();
                if (noChange()) {
                    // 明細が変更されていない場合、メッセージを表示し保存処理を中止する
                    App.ui.page.notifyInfo.message(pageLangText.noChange.text).show();
                    App.ui.loading.close();
                    return;
                }
                // 検索条件変更チェック
                if (!noChangeCriteria()) {
                    App.ui.page.notifyInfo.message(
                        App.str.format(pageLangText.changeCriteria.text, pageLangText.searchCriteria.text, pageLangText.save.text)
                    ).show();
                    App.ui.loading.close();
                    return;
                }
                // 変更セット内にバリデーションエラーがある場合は処理を抜ける
                if (!validateChangeSet()) {
                    App.ui.loading.close();
                    return;
                }
                /*
                // 明細/納入予定日のチェック
                if (!checkNonyuYoteiDate()) {
                App.ui.loading.close();
                return;
                }
                else {
                // チェックがすべて終わってからローディング表示を終了させる
                App.ui.loading.close();
                }*/
                App.ui.loading.close();
                // 明細/原資材コード・明細/取引先１(物流)：組み合わせ重複チェックエラーの場合は処理を抜ける
                //if (!checkCombinationDuplicate()) {
                //    return;
                //}

                // 最終編集行ＩＤのクリア
                //lastEditRowId = null;

                // 保存時ダイアログを開く
                //showSaveConfirmDialog();
                saveData();
            };

            /// <summary>保存ボタンクリック時のイベント処理を行います。</summary>
            $(".save-button").on("click", function () {
                App.ui.loading.show(pageLangText.nowProgressing.text);

                // チェック処理が始まるとローディング画像が表示されない為、setTimeoutで間を入れる
                setTimeout(function () {
                    checkSave();    // 保存処理の実行
                }, 100);
            });

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
                        }
                    }
                }
            });
            /// <summary>検索条件バリデーションを行います。</summary>
            $(".search-criteria").validation(actValidation);
            /// <summary>納入書番号連続設定エリアバリデーションを行います。</summary>
            $(".part-no-nonyusho").validation(actValidation);

            // グリッドコントロール固有のバリデーション
            // 検索条件/取引先コード：取引先マスタ存在チェック
            var isValidCdTorihikiExists = function (cdTorihiki) {
                var isValid = true,
                    query = {
                        url: "../Services/FoodProcsService.svc/ma_torihiki",
                        filter: "cd_torihiki eq '" + cdTorihiki +
                                "' and kbn_torihiki eq " + pageLangText.shiiresakiToriKbn.text +
                                " and flg_mishiyo eq " + pageLangText.shiyoMishiyoFlg.text,
                        top: 1
                    };
                // 取引先コードが未入力の場合はチェックを行わない
                if (App.isUndefOrNull(cdTorihiki)
                    || cdTorihiki.length === 0) {
                    return isValid;
                }

                // 取引先マスタ存在チェック
                App.ajax.webgetSync(
                    App.data.toODataFormat(query)
                ).done(function (result) {
                    if (result.d.length === 0) {
                        // 検索結果件数が0件の場合

                        // 取引先マスタ存在チェックエラー
                        isValid = false;
                    }
                    else {
                        // 検索結果が取得できた場合

                        // 検索条件/取引先名に取得した[取引先マスタ].[取引先名]を設定
                        $("#condition-nm_torihiki").text(result.d[0]["nm_torihiki"]);
                    }
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                });
                return isValid;
            };

            // 納入書番号連続設定：入力必須チェック
            var isValidNoNonyushoRequired = function (noNonyusho) {
                var isValid = true,
                    setNoNonyusho = $("#set-no-nonyusho").attr("checked");
                // 入力必須チェック
                if (!App.isUndefOrNull(setNoNonyusho)
                    && (App.isUndefOrNull(noNonyusho)
                        || noNonyusho.length === 0)) {
                    // 納入書番号連続設定がチェックされていて連続設定用納入書番号が入力されていない場合

                    // 入力不可チェックエラー
                    isValid = false;
                }
                return isValid;
            };

            // 明細/原資材コード：品名マスタ存在チェック
            var isValidCdHinmeiExists = function (cdHinmei) {
                // 検索条件の品区分によって抽出条件を変更する
                var strWhere = "";
                validationSetting.cd_hinmei.messages.custom = pageLangText.specifiedParamDoesNotExist.text;
                if (App.isUndefOrNull(searchCriteriaSet)
                        || (App.isUndefOrNull(searchCriteriaSet.con_kbn_hin) || searchCriteriaSet.con_kbn_hin.length == 0)) {
                    strWhere = "(kbn_hin eq " + pageLangText.genryoHinKbn.text + " or kbn_hin eq " + pageLangText.shizaiHinKbn.text + ")";
                }
                else {
                    strWhere = "kbn_hin eq " + searchCriteriaSet.con_kbn_hin;
                }
                var isValid = true,
                    query = {
                        url: "../Services/FoodProcsService.svc/ma_hinmei",
                        filter: "cd_hinmei eq '" + cdHinmei +
                                "' and " + strWhere +
                                " and flg_mishiyo eq " + pageLangText.shiyoMishiyoFlg.text,
                        top: 1
                    };
                // 品名マスタ存在チェック
                App.ajax.webgetSync(
                    App.data.toODataFormat(query)
                ).done(function (result) {
                    if (result.d.length === 0) {
                        // 検索結果件数が0件の場合

                        // 品名マスタ存在チェックエラー
                        isValid = false;
                    }
                    else
                    {
                        // 絶対比較（大文字と小文字）
                        var maHinmei = result.d;
                        if (maHinmei[0].cd_hinmei !== cdHinmei) {
                            isValid = false;
                            validationSetting.cd_hinmei.messages.custom = pageLangText.notFound.text;
                        }
                    }
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                });
                return isValid;
            };

            // 明細/端数：入力不可チェック
            var isValidSuNonyuHasuNotInput = function (suNonyuHasu) {
                var isValid = true,
                    cdTaniNonyu;
                if (!App.isUndefOrNull(lastEditRowId)) {
                    // 最終編集行ＩＤが設定されている場合

                    // 最終編集行ＩＤの隠し項目：納入単位コードをチェック対象とする
                    cdTaniNonyu = grid.getCell(lastEditRowId, "cd_tani_nonyu");
                }
                else {
                    // 最終編集行ＩＤが設定されていない場合

                    // 現在選択行ＩＤの隠し項目：納入単位コードをチェック対象とする
                    cdTaniNonyu = grid.getCell(getSelectedRowId(), "cd_tani_nonyu");
                }
                // 入力不可チェック
                if (!App.isUndefOrNull(suNonyuHasu)
                    && suNonyuHasu.length > 0
                    && suNonyuHasu !== "0" // 0を許可
                    && (cdTaniNonyu === pageLangText.maiCdTani.text
                        || cdTaniNonyu === pageLangText.honCdTani.text
                        || cdTaniNonyu === pageLangText.kanCdTani.text)) {
                    // 明細/端数に値が入力されている かつ
                    // 隠し項目：納入単位コード = 「枚」 または 「本」 または 「缶」 の場合

                    // 入力不可チェックエラー
                    isValid = false;
                }
                return isValid;
            };

            // 明細/納入予定日：入力チェック
            var isValidDtNonyuYoteiInput = function (rowId) {
                var isValid = true,
                    dtNonyuYotei = App.date.localDate(grid.getCell(rowId, "dt_nonyu_yotei")),
                    save_su_nonyu_ji = grid.getCell(rowId, "save_su_nonyu_ji");

                // 検索時の実績数がある場合はチェック不要
                if (App.isUndefOrNull(save_su_nonyu_ji) || save_su_nonyu_ji == "") {
                    var su_nonyu_yo = grid.getCell(rowId, "su_nonyu_yo"),
                        su_nonyu_ji = grid.getCell(rowId, "su_nonyu_ji"),
                        before_dt_nonyu = grid.getCell(rowId, "save_dt_nonyu_yotei"),
                    //valiObj = validationSetting.dt_nonyu_yotei,
                        sysdate = new Date(new Date().getFullYear(), new Date().getMonth(), new Date().getDate()),
                        unique = rowId + "_" + grid.getColumnIndexByName("dt_nonyu_yotei");

                    if (su_nonyu_ji != "" && before_dt_nonyu != dtNonyuYotei) {
                        // 実績数が入力された場合は納入予定日の変更不可
                        //valiObj.messages.custom = MS0164;
                        App.ui.page.notifyAlert.message(MS0164, unique).show();
                        isValid = false;
                    }
                    else if (su_nonyu_yo != "" && dtNonyuYotei == "") {
                        // 納入予定がある場合は納入予定日は必須
                        App.ui.page.notifyAlert.message(MS0738, unique).show();
                        isValid = false;
                    }
                    //else if (su_nonyu_ji == "" && new Date(dtNonyuYotei) < sysdate) {
                    else if (su_nonyu_ji == "" && dtNonyuYotei < sysdate) {
                        // システム日付より過去への変更は不可(実績数がない場合のみチェック)
                        App.ui.page.notifyAlert.message(MS0127, unique).show();
                        isValid = false;
                    }
                }
                return isValid;
            };

            // 納入トランまたは荷受に、納入予定日・品名コードがすでに存在しているかどうか
            var getNonyuYotei = function (rowId) {
                // 納入トランまたは荷受に、変更先の日付・同品名コードが存在する場合はエラー
                var ret = true,
                    date = new Date(App.date.localDate(grid.getCell(rowId, "dt_nonyu_yotei"))),
                    code = grid.getCell(rowId, "cd_hinmei"),
                    torihiki = grid.getCell(rowId, "cd_torihiki_yotei"),
                    kbn_nyuko = grid.getCell(rowId, "kbn_nyuko"),
                    no_nonyu = grid.getCell(rowId, "no_nonyu"),
                    trNonyu,
                    trNiuke;

                // 納入トランから検索
                var queryNonyu = {
                    url: "../Services/FoodProcsService.svc/tr_nonyu",
                    filter: "cd_hinmei eq '" + code + "' and dt_nonyu eq DateTime'" + App.data.getDateTimeStringForQueryNoUtc(date)
                        + "' and cd_torihiki eq '" + torihiki + "' and no_nonyu ne '" + no_nonyu + "'",
                    top: 1
                };
                App.ajax.webgetSync(
                    App.data.toODataFormat(queryNonyu)
                ).done(function (resultNonyu) {
                    if (resultNonyu.d.length > 0) {
                        // 1件でも取得できた場合はすでに納入予定があるのでエラーとする
                        ret = false;
                    }
                    else {
                        // 納入トランになければ荷受トランをチェック
                        var queryNiuke = {
                            url: "../Services/FoodProcsService.svc/tr_niuke",
                            filter: "cd_hinmei eq '" + code + "' and dt_niuke eq DateTime'" + App.data.getDateTimeStringForQueryNoUtc(date)
                                + "' and kbn_nyuko eq " + kbn_nyuko + " and cd_torihiki eq '" + torihiki + "'",
                            top: 1
                        };
                        App.ajax.webgetSync(
                            App.data.toODataFormat(queryNiuke)
                        ).done(function (resultNiuke) {
                            if (resultNiuke.d.length > 0) {
                                // 1件でも取得できた場合はすでに納入予定があるのでエラーとする
                                ret = false;
                            }
                        }).fail(function (result) {
                            App.ui.page.notifyAlert.message(result.message).show();
                        });
                    }
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                });

                return ret;
            };
            var checkNonyuYoteiDate = function () {
                var ret = true;

                // 既存行のみのチェック
                for (p in changeSet.changeSet.updated) {
                    if (!changeSet.changeSet.updated.hasOwnProperty(p)) {
                        continue;
                    }

                    // 納入予定日が変更されていた場合のみチェックする
                    var before = grid.getCell(p, "save_dt_nonyu_yotei"),
                        after = grid.getCell(p, "dt_nonyu_yotei");
                    if (after != "" && before != after) {

                        // 納入予定日の入力チェック
                        if (!isValidDtNonyuYoteiInput(p)) {
                            ret = false;
                            break;
                        }

                        // 変更先の納入予定日にすでに納入予定がある場合はエラー
                        if (!getNonyuYotei(p)) {
                            var unique = p + "_" + grid.getColumnIndexByName("dt_nonyu_yotei");
                            App.ui.page.notifyAlert.message(MS0739, unique).show();
                            ret = false;
                            break;
                        }
                    }
                }
                return ret;
            };

            // バリデーション設定(検索条件/取引先コード：取引先マスタ存在チェック)
            validationSetting.con_cd_torihiki.rules.custom = function (value) {
                return isValidCdTorihikiExists(value);
            };

            // バリデーション設定(納入書番号連続設定：入力必須チェック)
            validationSetting.copy_no_nonyusho.rules.custom = function (value) {
                return isValidNoNonyushoRequired(value);
            };

            // バリデーション設定(明細/原資材コード：品名マスタ存在チェック)
            validationSetting.cd_hinmei.rules.custom = function (value) {
                return isValidCdHinmeiExists(value);
            };

            // バリデーション設定(明細/予定端数：入力不可チェック)
            validationSetting.su_nonyu_yo_hasu.rules.custom = function (value) {
                return isValidSuNonyuHasuNotInput(value);
            };

            // バリデーション設定(明細/実績端数：入力不可チェック)
            validationSetting.su_nonyu_hasu.rules.custom = function (value) {
                return isValidSuNonyuHasuNotInput(value);
            };

            // バリデーション設定(明細/納入予定日：入力チェック)
            //validationSetting.dt_nonyu_yotei.rules.custom = function (value) {
            //    return isValidDtNonyuYoteiInput(value);
            //};

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
                // バリデーション実行
                if (cellName === "su_nonyu_hasu" || cellName === "su_nonyu_yo_hasu") {
                    // 明細/端数の場合

                    // バリデーションのコールバック関数の実行をスキップ(カスタムバリデーション用にメッセージの引数を渡す)
                    result = v.validate(val, { suppressCallback: false, customRuleParam: grid.getCell(selectedRowId, "nm_tani") });
                }
                else {
                    // 上記以外の場合

                    // バリデーションのコールバック関数の実行をスキップ
                    result = v.validate(val, { suppressCallback: false });
                }
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
                    var cellName = colModel[i].name;
                    var cellEdit = colModel[i].editable;

                    //// 編集項目のみチェックする
                    //if (!cellEdit || App.isUndefOrNull(cellEdit)) {
                    // 編集項目のみチェックする(取引先は必須チェックを行う)
                    if ((!cellEdit || App.isUndefOrNull(cellEdit)) && cellName !== "nm_torihiki") {
                        continue;
                    }

                    // セルを選択して入力モードを解除する
                    grid.editCell(iRow, i, false);
                    // セルバリデーション
                    if (!validateCell(selectedRowId, cellName, grid.getCell(selectedRowId, cellName), i)) {
                        isValid = false;
                        break;
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
                    //相関チェック
                    var dateYotei = grid.getCell(p, "dt_nonyu_yotei");
                    var suYotei = grid.getCell(p, "su_nonyu_yo");
                    var hasuYotei = grid.getCell(p, "su_nonyu_yo_hasu");
                    var yoteiData = [dateYotei, suYotei, hasuYotei].join("");
                    //if ((dateYotei == "" && suYotei != "") || (dateYotei != "" && suYotei == "")) {
                    if (yoteiData.length > 0
                        && (dateYotei.length === 0 || (suYotei.length === 0 && hasuYotei.length === 0))) {
                        if (dateYotei == "") {
                            var unique = p + "_" + grid.getColumnIndexByName("dt_nonyu_yotei");
                            App.ui.page.notifyAlert.message(App.str.format(pageLangText.required.text, pageLangText.reqYoteiDate.text), unique).show();
                            grid.setCell(p, grid.getColumnIndexByName("dt_nonyu_yotei"), dateYotei, { background: '#ff6666' });
                        }
                        if (suYotei == "") {
                            var unique = p + "_" + grid.getColumnIndexByName("su_nonyu_yo");
                            App.ui.page.notifyAlert.message(App.str.format(pageLangText.required.text, pageLangText.reqYoteiSu.text), unique).show();
                            grid.setCell(p, grid.getColumnIndexByName("su_nonyu_yo"), suYotei, { background: '#ff6666' });
                        }
                        return;
                    }
                    if (dateYotei != "" && suYotei.length === 0) {
                        grid.setCell(p, "su_nonyu_yo", 0);
                    }
                    if (dateYotei != "" && hasuYotei.length === 0) {
                        grid.setCell(p, "su_nonyu_yo_hasu", 0);
                    }
                    var dateJisseki = grid.getCell(p, "dt_nonyu");
                    var suJisseki = grid.getCell(p, "su_nonyu_ji");
                    var suJissekiHasu = grid.getCell(p, "su_nonyu_hasu");
                    var kinJisseki = grid.getCell(p, "kin_kingaku");
                    if (dateJisseki != "" || (suJisseki != "" && suJisseki != 0) || (suJissekiHasu != "" && suJissekiHasu != 0) || (kinJisseki != "" && kinJisseki != 0)) {
                        if (dateJisseki == "" || (suJisseki == "" && suJissekiHasu == "") || kinJisseki == "") {
                            var unique = p + "_" + grid.getColumnIndexByName("su_nonyu_ji");
                            App.ui.page.notifyAlert.message(App.str.format(pageLangText.required.text, pageLangText.reqJisseki.text), unique).show();
                            //grid.setCell(p, suNonyuCol, suJisseki, { background: '#ff6666' });
                            return;
                        }
                    }
                    if (dateYotei == "" && suYotei == "" && dateJisseki == "" && suJisseki == "" && suJissekiHasu == "" && (kinJisseki == "" || kinJisseki == 0)) {
                        var unique = p + "_" + grid.getColumnIndexByName("dt_nonyu_yotei");
                        App.ui.page.notifyAlert.message(App.str.format(pageLangText.required.text, pageLangText.reqYoteiData.text), unique).show();
                        return;
                    }

                    // 納入予定数と納入予定端数の両方が0の場合はエラー
                    var nonyuSu = grid.getCell(p, 'su_nonyu_yo');
                    var nonyuHasu = grid.getCell(p, 'su_nonyu_yo_hasu');
                    var gokei = parseFloat(nonyuSu) + parseFloat(nonyuHasu);
                    if (!gokei > 0) {
                        // エラーメッセージの表示
                        App.ui.page.notifyAlert.message(pageLangText.suNonyuYoteiZero.text, unique).show();
                        // 対象セルの背景変更
                        grid.setCell(p, 'su_nonyu_yo', '', { background: '#ff6666' });
                        grid.setCell(p, 'su_nonyu_yo_hasu', '', { background: '#ff6666' });
                        return;
                    }
                }
                for (p in changeSet.changeSet.updated) {
                    if (!changeSet.changeSet.updated.hasOwnProperty(p)) {
                        continue;
                    }
                    /*
                    // 入庫区分または納入予定日のみの変更の場合はバリデーションチェックはしない
                    // (実績の保存を行わないため)
                    var flg_edit_yotei = grid.getCell(p, "flg_edit_kbn_nyuko");
                    var flg_edit_meisai = grid.getCell(p, "flg_edit_meisai");
                    if (flg_edit_yotei == pageLangText.trueFlg.text
                    && flg_edit_meisai != pageLangText.trueFlg.text) {
                    continue;
                    }*/

                    // カレントの行バリデーションを実行
                    if (!validateRow(p)) {
                        return false;
                    }
                    //相関チェック
                    var dateYotei = grid.getCell(p, "dt_nonyu_yotei");
                    var suYotei = grid.getCell(p, "su_nonyu_yo");
                    var hasuYotei = grid.getCell(p, "su_nonyu_yo_hasu");
                    var yoteiData = [dateYotei, suYotei, hasuYotei].join("");
                    //if ((dateYotei == "" && suYotei != "") || (dateYotei != "" && suYotei == "")) {
                    if (yoteiData.length > 0
                        && (dateYotei.length === 0 || (suYotei.length === 0 && hasuYotei.length === 0))) {
                        if (dateYotei == "") {
                            var unique = p + "_" + grid.getColumnIndexByName("dt_nonyu_yotei");
                            App.ui.page.notifyAlert.message(App.str.format(pageLangText.required.text, pageLangText.reqYoteiDate.text), unique).show();
                            grid.setCell(p, grid.getColumnIndexByName("dt_nonyu_yotei"), dateYotei, { background: '#ff6666' });
                        }
                        if (suYotei == "") {
                            var unique = p + "_" + grid.getColumnIndexByName("su_nonyu_yo");
                            App.ui.page.notifyAlert.message(App.str.format(pageLangText.required.text, pageLangText.reqYoteiSu.text), unique).show();
                            grid.setCell(p, grid.getColumnIndexByName("su_nonyu_yo"), suYotei, { background: '#ff6666' });
                        }
                        return;
                    }
                    if (dateYotei != "" && suYotei.length === 0) {
                        grid.setCell(p, "su_nonyu_yo", 0);
                    }
                    if (dateYotei != "" && hasuYotei.length === 0) {
                        grid.setCell(p, "su_nonyu_yo_hasu", 0);
                    }
                    if (dateYotei == "" && suYotei == "") {
                        changeSet.changeSet.updated[p].flg_edit_kbn_nyuko = 0;
                    } else {
                        changeSet.changeSet.updated[p].flg_edit_kbn_nyuko = 1;
                    }
                    var dateJisseki = grid.getCell(p, "dt_nonyu");
                    var suJisseki = grid.getCell(p, "su_nonyu_ji");
                    var suJissekiHasu = grid.getCell(p, "su_nonyu_hasu");
                    var kinJisseki = grid.getCell(p, "kin_kingaku");
                    if (dateJisseki != "" || (suJisseki != "" && suJisseki != 0) || (suJissekiHasu != "" && suJissekiHasu != 0) || (kinJisseki != "" && kinJisseki != 0)) {
                        if (dateJisseki == "" || (suJisseki == "" && suJissekiHasu == "") || kinJisseki == "") {
                            var unique = p + "_" + grid.getColumnIndexByName("su_nonyu_ji");
                            App.ui.page.notifyAlert.message(App.str.format(pageLangText.required.text, pageLangText.reqJisseki.text), unique).show();
                            //grid.setCell(p, suNonyuCol, suJisseki, { background: '#ff6666' });
                            return;
                        }
                        changeSet.changeSet.updated[p].flg_edit_meisai = 1;
                    } else {
                        changeSet.changeSet.updated[p].flg_edit_meisai = 0;
                    }
                    if (dateYotei == "" && suYotei == "" && dateJisseki == "" && suJisseki == "" && suJissekiHasu == "" && (kinJisseki == "" || kinJisseki == 0)) {
                        var unique = p + "_" + grid.getColumnIndexByName("dt_nonyu_yotei");
                        App.ui.page.notifyAlert.message(App.str.format(pageLangText.required.text, pageLangText.reqYoteiData.text), unique).show();
                        return;
                    }

                    // 納入予定数と納入予定端数の両方が0の場合はエラー
                    var nonyuSu = grid.getCell(p, 'su_nonyu_yo');
                    var nonyuHasu = grid.getCell(p, 'su_nonyu_yo_hasu');
                    var gokei = parseFloat(nonyuSu) + parseFloat(nonyuHasu);
                    if (!gokei > 0) {
                        // エラーメッセージの表示
                        App.ui.page.notifyAlert.message(pageLangText.suNonyuYoteiZero.text, unique).show();
                        // 対象セルの背景変更
                        grid.setCell(p, 'su_nonyu_yo', '', { background: '#ff6666' });
                        grid.setCell(p, 'su_nonyu_yo_hasu', '', { background: '#ff6666' });
                        return;
                    }
                }
                return true;
            };

            //// バリデーション -- End

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
                App.ui.page.notifyAlert.message(App.str.format(
                    pageLangText.criteriaChange.text, pageLangText.searchCriteria.text, alertMessage)).show();
            }

            /// <summary>明細/原資材コード・明細/取引先１(物流)：組み合わせ重複チェック</summary>
            var checkCombinationDuplicate = function () {
                var isCheck = true,
                    ids = grid.jqGrid('getDataIDs');
                // 全行数分繰り返し処理する
                for (var i = 0; i < ids.length; i++) {
                    // 明細/原資材コード、明細/取引先１(物流)のエラー解除
                    App.ui.page.notifyAlert.remove(ids[i] + "_" + grid.getColumnIndexByName("cd_hinmei"));
                    grid.setCell(ids[i], grid.getColumnIndexByName("cd_hinmei"), grid.getCell(ids[i], "cd_hinmei"), { background: 'none' });
                    App.ui.page.notifyAlert.remove(ids[i] + "_" + grid.getColumnIndexByName("nm_torihiki"));
                    grid.setCell(ids[i], grid.getColumnIndexByName("nm_torihiki"), grid.getCell(ids[i], "nm_torihiki"), { background: 'none' });

                    for (var j = 0; j < ids.length; j++) {
                        if (ids[i] === ids[j]) {
                            // 同一行はチェック対象外
                            continue;
                        }
                        // 組み合わせ重複チェック
                        if (grid.getCell(ids[i], "cd_hinmei") === grid.getCell(ids[j], "cd_hinmei")
                            && grid.getCell(ids[i], "cd_torihiki") === grid.getCell(ids[j], "cd_torihiki")) {
                            // 明細/原資材コードと隠し項目：取引先コードの組み合わせが同一の場合

                            // 明細/原資材コード、明細/取引先１(物流)の背景変更
                            grid.setCell(ids[i], grid.getColumnIndexByName("cd_hinmei"), grid.getCell(ids[i], "cd_hinmei"), { background: '#ff6666' });
                            grid.setCell(ids[i], grid.getColumnIndexByName("nm_torihiki"), grid.getCell(ids[i], "nm_torihiki"), { background: '#ff6666' });

                            // 組み合わせ重複チェックエラー
                            isCheck = false
                            // 次の明細行をチェック
                            break;
                        }
                    }
                }
                if (!isCheck) {
                    // 組み合わせ重複チェックエラーの場合

                    // 組み合わせ重複チェックエラーメッセージ表示
                    App.ui.page.notifyAlert.message(App.str.format(pageLangText.combinationduplicate.text)).show();
                }
                return isCheck;
            };

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

            /// <summary>検索確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".search-confirm-dialog .dlg-yes-button").on("click", findData);

            /// <summary>検索確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".search-confirm-dialog .dlg-no-button").on("click", closeSearchConfirmDialog);

            /// <summary>保存確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".save-confirm-dialog .dlg-yes-button").on("click", saveData);

            /// <summary>保存確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".save-confirm-dialog .dlg-no-button").on("click", closeSaveConfirmDialog);

            /// <summary>コンボボックス：検索条件/品区分変更時のイベント処理を行います。</summary>
            $("#condition-kbn_hin").on("change", function () {
                // コンボボックス：検索条件/品分類の作成処理
                createBunruiCombobox("");
            });

            /// <summary>ラジオボタン：検索条件/取引先変更時のイベント処理を行います。</summary>
            $(".search-criteria [name='con_flg_torihiki']").on("click", function (e) {
                var criteria = $(".search-criteria").toJSON();
                if (criteria.con_flg_torihiki === pageLangText.conFlgTorihiki_zen.text) {
                    // ラジオボタン：検索条件/取引先で『全取引先』が選択された場合

                    // 検索条件/取引先コード、検索条件/取引先名のクリア
                    $("#condition-cd_torihiki").attr("value", "");
                    $("#condition-nm_torihiki").text("");

                    // 検索条件/取引先コード、ボタン：検索条件/取引先一覧を無効化
                    $("#condition-cd_torihiki").attr("disabled", "disabled");
                    //$(".condition-torihiki-button").attr("disabled", "disabled");
                    $(".condition-torihiki-button").attr("disabled", true);
                }
                else {
                    // ラジオボタン：検索条件/取引先で『取引先選択』が選択された場合

                    // 検索条件/取引先コード、ボタン：検索条件/取引先一覧を有効化
                    $("#condition-cd_torihiki").removeAttr("disabled");
                    $(".condition-torihiki-button").removeAttr("disabled");
                }
            });

            /// <summary>検索条件/取引先コード変更時のイベント処理を行います。</summary>
            $("#condition-cd_torihiki").on("change", function () {
                // 検索条件/取引先名を初期化
                $("#condition-nm_torihiki").text("");
            });

            /// <summary>検索条件/取引先一覧ボタンクリック時のイベント処理を行います。</summary>
            $(".condition-torihiki-button").on("click", function (e) {
                // ダイアログ：取引先一覧を開く
                showTorihikisakiDialog();
            });

            /// <summary>全チェック/解除ボタンクリック時のイベント処理を行います。</summary>
            $(".check-button").on("click", function (e) {
                // 検索条件変更チェック
                if (isCriteriaChange) {
                    showCriteriaChange("checkAndReset");
                    return;
                }

                // グリッドから全行のIDを取得
                var ids = grid.jqGrid('getDataIDs');
                // 全行数分繰り返し処理する
                for (var i = 0; i < ids.length; i++) {
                    if (kakuteiStatus === pageLangText.mikakuteiKakuteiFlg.text) {
                        // 確定ステータスが未確定の場合

                        if (grid.getCell(ids[i], "flg_kakutei") === pageLangText.mikakuteiKakuteiFlg.text) {
                            // 明細/確定が未チェックの場合

                            // 明細/確定にチェックを入れる
                            grid.setCell(ids[i], "flg_kakutei", pageLangText.kakuteiKakuteiFlg.text);
                            // 更新状態の変更セットに変更データを追加
                            changeSetUpdated(ids[i], "flg_kakutei");
                        }
                    }
                    else {
                        // 確定ステータスが確定の場合

                        if (grid.getCell(ids[i], "flg_kakutei") === pageLangText.kakuteiKakuteiFlg.text) {
                            // 明細/確定がチェック済の場合

                            // 明細/確定のチェックを外す
                            grid.setCell(ids[i], "flg_kakutei", pageLangText.mikakuteiKakuteiFlg.text);
                            // 更新状態の変更セットに変更データを追加
                            changeSetUpdated(ids[i], "flg_kakutei");
                        }
                    }
                }
                // 確定ステータスの更新
                if (kakuteiStatus === pageLangText.mikakuteiKakuteiFlg.text) {
                    // 確定ステータスを未確定から確定に更新する
                    kakuteiStatus = pageLangText.kakuteiKakuteiFlg.text;
                }
                else {
                    // 確定ステータスを確定から未確定に更新する
                    kakuteiStatus = pageLangText.mikakuteiKakuteiFlg.text
                }
            });

            /// <summary>原資材一覧ボタンクリック時のイベント処理を行います。</summary>
            $(".genshizai-button").on("click", function (e) {
                if (!checkRecordCount()) {
                    // 明細行が存在しない場合は、何もしない
                    return;
                }
                // 選択行の取得
                var selectedRowId = getSelectedRowId(false),
                    suNonyuYo = grid.getCell(selectedRowId, "su_nonyu_yo");
                //if (App.isUndefOrNull(suNonyuYo)
                //    || suNonyuYo.length === 0) {
                // 明細/納入予定が設定されていない場合
                var nonyuJissekiSu = grid.jqGrid('getCell', selectedRowId, "save_su_nonyu_ji");
                if (nonyuJissekiSu.length === 0) {
                    // 「afterSaveCell」などが動作しないよう、隠し項目：納入番号をダミーでクリックして回避する
                    $("#" + selectedRowId + " td:eq('" + grid.getColumnIndexByName("no_nonyu") + "')").click();
                    // ダイアログ：原資材一覧を開く
                    showGenshizaiDialog();
                }
            });

            /// <summary>取引先一覧ボタンクリック時のイベント処理を行います。</summary>
            $(".torihiki-button").on("click", function (e) {
                if (!checkRecordCount()) {
                    // 明細行が存在しない場合は、何もしない
                    return;
                }
                // 選択行の取得
                var selectedRowId = getSelectedRowId(false);

                var nonyuJissekiSu = grid.jqGrid('getCell', selectedRowId, "save_su_nonyu_ji");
                if (nonyuJissekiSu.length === 0) {

                    // 「afterSaveCell」などが動作しないよう、隠し項目：納入番号をダミーでクリックして回避する
                 $("#" + selectedRowId + " td:eq('" + grid.getColumnIndexByName("no_nonyu") + "')").click();
                    // 変更前レコードの取得
                    updateRow = grid.getRowData(selectedRowId);
                    // ダイアログ：原資材購入先一覧を開く
                    showGenshizaiKonyuDialog(updateRow.cd_hinmei);
                }
            });

            /// <summary>納入書番号連続設定変更時のイベント処理を行います。</summary>
            $("#set-no-nonyusho").on("change", function () {
                if (!App.isUndefOrNull(lastEditRowId)) {
                    // 納入書番号連続設定変更前にグリッドの編集が行われていた場合

                    // グリッドの入力可能項目からフォーカスを外すため、最終編集行の隠し項目：納入番号をダミーでクリックする
                    $("#" + lastEditRowId + " td:eq('" + grid.getColumnIndexByName("no_nonyu") + "')").click();
                }

                // 納入書番号連続設定のチェック状況を取得
                var setNoNonyusho = $("#set-no-nonyusho").attr("checked");
                if (!App.isUndefOrNull(setNoNonyusho)) {
                    // 納入書番号連続設定がチェックされている場合

                    // 連続設定用納入書番号を有効化
                    $("#copy-no-nonyusho").removeAttr("disabled");
                }
                else {

                    // 連続設定用納入書番号のクリア
                    $("#copy-no-nonyusho").attr("value", "");
                    // 連続設定用納入書番号を無効化
                    $("#copy-no-nonyusho").attr("disabled", "disabled");
                }

                // 納入書番号連続設定エリアバリデーションを動作させる
                $("#copy-no-nonyusho").change();
            });

            /// <summary>ダウンロードボタンクリック時のオーバレイ処理を行います。</summary>
            var downloadOverlay = function () {
                // ローディングの表示
                //App.ui.loading.show(pageLangText.nowProgressing.text);
                // Excelファイル出力
                printExcel();
                // ローディングの終了
                //App.ui.loading.close();
            };

            /// <summary>Excelファイル出力を行います。</summary>
            var printExcel = function (e) {
                var criteria = $(".search-criteria").toJSON(),
                    nmKbnHin = pageLangText.noSelectConditionExcel.text,
                    nmCdBunrui = pageLangText.noSelectConditionExcel.text,
                    nmKbnHokan = pageLangText.noSelectConditionExcel.text,
                    nmFlgTorihiki = pageLangText.nmFlgTorihiki_zen.text,
                    nmCdTorihiki = pageLangText.noSelectConditionExcel.text,
                    nmNmTorihiki = pageLangText.noSelectConditionExcel.text;

                // 検索条件出力内容設定：検索条件が指定されている場合「未選択」を条件に置き換える
                // 検索条件/品区分
                if (!App.isUndefOrNull(criteria.con_kbn_hin)) {
                    nmKbnHin = $("#condition-kbn_hin option:selected").text();
                }
                // 検索条件/品分類
                if (!App.isUndefOrNull(criteria.con_cd_bunrui)) {
                    nmCdBunrui = $("#condition-bunrui_hin option:selected").text();
                }
                // 検索条件/品位状態
                if (!App.isUndefOrNull(criteria.con_kbn_hokan)) {
                    nmKbnHokan = $("#condition-kbn_hokan option:selected").text();
                }
                // 検索条件/取引先、検索条件/取引先コード、検索条件/取引先名
                if (criteria.con_flg_torihiki === pageLangText.conFlgTorihiki_sentaku.text) {
                    nmFlgTorihiki = pageLangText.nmFlgTorihiki_sentaku.text;
                    nmCdTorihiki = criteria.con_cd_torihiki,
                    //nmNmTorihiki = criteria.con_nm_torihiki;  // ChromeだとtoJSONでラベルの値が取得できない
                    nmNmTorihiki = $("#condition-nm_torihiki").text();
                }

                var query = {
                    url: "../api/NonyuYoteiListSakuseiExcel",
                    con_dt_nonyu: App.data.getDateTimeStringForQueryNoUtc(criteria.con_dt_nonyu),
                    con_kbn_hin: criteria.con_kbn_hin,
                    con_cd_bunrui: criteria.con_cd_bunrui,
                    con_kbn_hokan: criteria.con_kbn_hokan,
                    con_cd_torihiki: criteria.con_cd_torihiki,
                    flg_yojitsu_yo: pageLangText.yoteiYojitsuFlg.text,
                    flg_yojitsu_ji: pageLangText.jissekiYojitsuFlg.text,
                    flg_mishiyo: pageLangText.shiyoMishiyoFlg.text
                };
                // 処理中を表示する
                App.ui.loading.show(pageLangText.nowProgressing.text);
                var url = App.data.toWebAPIFormat(query);
                url = url + "&lang=" + App.ui.page.lang
                          + "&nmKbnHin=" + encodeURIComponent(nmKbnHin)
                          + "&nmCdBunrui=" + encodeURIComponent(nmCdBunrui)
                          + "&nmKbnHokan=" + encodeURIComponent(nmKbnHokan)
                          + "&nmFlgTorihiki=" + encodeURIComponent(nmFlgTorihiki)
                          + "&nmCdTorihiki=" + encodeURIComponent(nmCdTorihiki)
                          + "&nmNmTorihiki=" + encodeURIComponent(nmNmTorihiki)
                          + "&userName=" + encodeURIComponent(App.ui.page.user.Name)
                          + "&today=" + App.data.getDateTimeStringForQuery(new Date(), true);

                // Excelファイル出力
                window.open(url, '_parent');
                // Cookieを監視する
                onComplete();
            };

            // Cookieを1秒ごとにチェックする
            var onComplete = function () {
                if (app_util.prototype.getCookieValue(pageLangText.nonyuYoteiListSakuseiCookie.text) == pageLangText.checkCookie.text) {
                    app_util.prototype.deleteCookie(pageLangText.nonyuYoteiListSakuseiCookie.text);
                    //ローディング終了
                    App.ui.loading.close();
                }
                else {
                    // 再起してCookieが作成されたか監視
                    setTimeout(onComplete, 1000);
                }
            };

            /// <summary>Excelボタンクリック時のイベント処理を行います。</summary>
            $(".excel-button").on("click", function () {
                if (!checkRecordCount()) {
                    return;
                }
                // エラーフラグ
                var flgErr = false;

                // 検索前バリデーション
                var result = $(".search-criteria").validation().validate();
                if (result.errors.length) {
                    flgErr = true;
                }
                // 取引先コード必須入力チェック
                var criteria = $(".search-criteria").toJSON();
                if (criteria.con_flg_torihiki === pageLangText.conFlgTorihiki_sentaku.text
                    && App.isUndefOrNull(criteria.con_cd_torihiki)) {
                    App.ui.page.notifyAlert.message(
                        App.str.format(pageLangText.required.text, pageLangText.con_cd_torihiki.text), $("#condition-cd_torihiki")).show();
                    flgErr = true;
                }
                // エラー処理
                if (flgErr) {
                    return;
                }

                // 検索条件変更チェック
                if (!noChangeCriteria()) {
                    App.ui.page.notifyInfo.message(
                        App.str.format(pageLangText.changeCriteria.text, pageLangText.searchCriteria.text, pageLangText.output.text)
                    ).show();
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

            // 検索条件に変更が発生した場合
            $(".search-criteria").on("change", function () {
                // 検索後の状態で検索条件が変更された場合
                if (isSearch) {
                    isCriteriaChange = true;
                }
            });

            /// <summary>データに変更があり、未保存の状態でページを離れる際に確認を行います。</summary>
            $(window).on('beforeunload', function () {
                if (!noChange()) {
                    return pageLangText.unloadWithoutSave.text;
                }
            });

            /// <summary>メニューへボタンクリック時のイベント処理を行います。</summary>
            var backToMenu = function () {
                // IEバグによる例外発生をキャッチします。例外発生時は何もしません。
                try {
                    document.location = pageLangText.menuPath.url;
                }
                catch (e) {
                    // 何もしない
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
    <div class="content-part search-criteria">
        <h3 class="part-header" data-app-text="searchCriteria"><a class="search-part-toggle" href="#"></a></h3>
        <div class="part-body">
            <ul class="item-list">
                <li>
                    <!-- 検索条件/日付 -->
                    <label>
                        <span class="item-label" data-app-text="con_dt_nonyu"></span>
                        <input type="text" name="con_dt_nonyu" id="condition-dt_nonyu" style="width: 155px;"/>
                    </label>
                    <span class="pad-apace"></span>
                    <!-- ラジオボタン：検索条件/取引先 -->
                    <label>
                        <input type="radio" name="con_flg_torihiki" value="0" checked/>
                        <span class="item-label" style="width: 110px" data-app-text="all_torihiki" data-tooltip-text="all_torihiki"></span>
                    </label>
                    <label>
                        <input type="radio" name="con_flg_torihiki" value="1"/>
                        <span class="item-label" style="width: 130px" data-app-text="select_torihiki" data-tooltip-text="select_torihiki"></span>
                    </label>
                </li>
                <li>
                    <!-- コンボボックス：検索条件/品区分 -->
                    <label>
                        <span class="item-label" data-app-text="con_kbn_hin" data-tooltip-text="con_kbn_hin"></span>
                        <select name="con_kbn_hin" id="condition-kbn_hin">
                        </select>
                    </label>
                    <!-- 見出し：検索条件/取引先1(物流) -->
                    <label>
                        <span class="pad-apace" data-app-text="con_head_nm_torihiki" data-tooltip-text="con_head_nm_torihiki"></span>
                    </label>
                </li>
                <li>
                    <!-- コンボボックス：検索条件/品分類 -->
                    <label>
                        <span class="item-label" data-app-text="con_cd_bunrui" data-tooltip-text="con_cd_bunrui"></span>
                        <select name="con_cd_bunrui" id="condition-bunrui_hin">
                        </select>
                    </label>
                    <!-- 検索条件/取引先コード -->
                    <label>
                        <span class="item-label pad-apace" data-app-text="con_cd_torihiki" data-tooltip-text="con_cd_torihiki"></span>
                        <input type="text" name="con_cd_torihiki" id="condition-cd_torihiki" style="width: 92px;" maxlength="13" disabled="disabled" />
                    </label>
                    <!-- ボタン：検索条件/取引先一覧 -->
                    <label>
                        <button type="button" class="condition-torihiki-button" name="condition-torihiki-button" disabled="disabled" style="padding: 0 10px;">
                            <span class="icon"></span>
                            <span data-app-text="torihikiIchiran" data-tooltip-text="torihikiIchiran"></span>
                        </button>
                    </label>
                </li>
                <li>
                    <!-- コンボボックス：検索条件/品位状態 -->
                    <label>
                        <span class="item-label" data-app-text="con_kbn_hokan" data-tooltip-text="con_kbn_hokan"></span>
                        <select name="con_kbn_hokan" id="condition-kbn_hokan">
                        </select>
                    </label>
                    <!-- 検索条件/取引先名 -->
                    <label>
                        <span class="item-label pad-apace" data-app-text="con_nm_torihiki" data-tooltip-text="con_nm_torihiki"></span>
                        <span name="con_nm_torihiki" id="condition-nm_torihiki" style="width: 325px;"></span>
                    </label>
                </li>
            </ul>
        </div>
        <div class="part-footer">
            <div class="command">
                <!-- ボタン：検索条件/検索 -->
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
                <!-- ボタン：列変更 -->
                <button type="button" class="colchange-button" name="colchange_button" data-app-operation="colChangeButton">
                    <span class="icon"></span><span data-app-text="colchange"></span>
                </button>
                <!-- ボタン：行追加 -->
                <button type="button" class="lineadd-button" id="add_button" name="lineadd_button" data-app-operation="lineAddButton">
                    <span class="icon"></span><span data-app-text="lineAdd"></span>
                </button>
                <!-- ボタン：行削除 -->
                <button type="button" class="linedelete-button" id="del_button" name="linedelete_button" data-app-operation="lineDeleteButton">
                    <span class="icon"></span><span data-app-text="lineDel"></span>
                </button>
                <!-- ボタン：全チェック/解除 -->
                <button type="button" class="check-button" id="check_button" name="check_button" data-app-operation="checkButton">
                    <span class="icon"></span><span data-app-text="checkAndReset"></span>
                </button>
                <!-- ボタン：原資材一覧 -->
                <button type="button" class="genshizai-button" id="genshizai_button" name="genshizai_button" data-app-operation="genshizaiButton">
                    <span class="icon"></span><span data-app-text="genshizaiIchiran"></span>
                </button>
                <!-- ボタン：取引先一覧 -->
                <button type="button" class="torihiki-button" id="torihiki_button" name="torihiki_button" data-app-operation="torihikiButton">
                    <span class="icon"></span><span data-app-text="torihikiIchiran"></span>
                </button>
                <span class="pad-apace"></span>
                <!-- 納入書番号連続設定エリア -->
                <div class="part-no-nonyusho">
                    <!-- チェックボックス：納入書番号連続設定 -->
                    <label>
                        <input type="checkbox" name="set_no_nonyusho" id="set-no-nonyusho" data-app-operation="setNoNonyusho"/>
                        <span class="item-label" data-app-operation="setNoNonyusho" style="width: auto;" data-app-text="set_no_nonyusho" data-tooltip-text="set_no_nonyusho"></span>
                    </label>
                    <!-- 連続設定用納入書番号 -->
                    <input type="text" name="copy_no_nonyusho" id="copy-no-nonyusho" data-app-operation="setNoNonyusho" style="width: 142px;" maxlength="20" disabled="disabled" />
                </div>
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
        <!-- ボタン：保存 -->
        <button type="button" class="save-button" name="save-button" data-app-operation="save">
            <span class="icon"></span>
            <span data-app-text="save"></span>
        </button>
        <!-- ボタン：EXCEL -->
        <button type="button" class="excel-button" name="excel-button" data-app-operation="excel">
            <!--<span class="icon"></span>-->
            <span data-app-text="excel"></span>
        </button>
    </div>
    <div class="command" style="right: 9px;">
        <!-- ボタン：メニューへ -->
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
    <!-- 取引先一覧ダイアログ：検索条件/取引先一覧ボタン押下時 -->
    <div class="con-torihikisaki-button-dialog">
    </div>
    <!-- 原資材一覧ダイアログ -->
    <div class="genshizai-dialog">
    </div>
    <!-- 原資材購入先ダイアログ：明細/取引先一覧ボタン押下時 -->
    <div class="torihikisaki-button-dialog">
    </div>
    <!-- 画面デザイン -- End -->
</asp:Content>
