<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="KeisanZaikoSakusei.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.KeisanZaikoSakusei" %>
<asp:Content ID="Content1" ContentPlaceHolderID="IncludeContent" runat="server">
    <script src="<%=ResolveUrl("~/Resources/pages/pagedata-keisanzaikosakusei." + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
    <script src="<%=ResolveUrl("~/Resources/grid/grid.locale-" + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
    <script src="<%=ResolveUrl("~/Resources/systemconst." + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
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

        .hinmei-dialog
        {
            background-color: White;
            width: 570px;
        }
        
        button.genshizai-button .icon
        {
            background-position: -48px -80px;
        }
        
        .start-confirm-dialog
        {
            background-color: White;
            width: 350px;
        }
                
        .start-confirm-dialog .part-body
        {
            width: 95%;
        }
        
        .delete-confirm-dialog
        {
            background-color: White;
            width: 350px;
        }
                
        .delete-confirm-dialog .part-body
        {
            width: 95%;
        }
        
        .allGenshizai-confirm-dialog
        {
            background-color: White;
            width: 350px;
        }
                
        .allGenshizai-confirm-dialog .part-body
        {
            width: 95%;
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
                validationSetting = App.ui.pagedata.validation(App.ui.page.lang);
            //querySetting = { skip: 0, top: 40, count: 0 },

            // グリッドコントロール固有の変数宣言
            var grid = $("#item-grid"),
                lastScrollTop = 0,
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
                hinName = 'nm_hinmei_' + App.ui.page.lang,
                changeSet = new App.ui.page.changeSet(),
                firstCol = 3,
                duplicateCol = 999,
                currentRow = 0,
                currentCol = firstCol;
            var dtFrom = $(".search-criteria [name='dt_from']");    // 計算初日
            var dtTo = $(".search-criteria [name='dt_to']");    // 計算末日
            var con_hinmei = "";    // 引数条件の用品名コード

            // 品名選択時のダイアログ
            var hinmeiDialog = $(".hinmei-dialog");
            hinmeiDialog.dlg({
                url: "Dialog/HinmeiDialog.aspx",
                name: "HinmeiDialog",
                closed: function (e, data, data2) {
                    if (data == "canceled") {
                        return;
                    }
                    else {
                        // 品名マスタセレクタから取得した原資材名とコードを設定
                        $("#id_nm_hinmei").text(data2);
                        $("#id_cd_hinmei").val(data);
                        // 再チェックで背景色とメッセージのリセット
                        $(".part-body .item-list").validation().validate();
                    }
                }
            });

            // TODO: ここまで

            // ダイアログ固有の変数宣言
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            var startConfirmDialog = $(".start-confirm-dialog"),
                deleteConfirmDialog = $(".delete-confirm-dialog"),
                allGenshizaiConfirmDialog = $(".allGenshizai-confirm-dialog"),
                completeDialog = $(".complete-dialog");
            // TODO：ここまで

            //// 変数宣言 -- End

            //// コントロール定義 -- Start

            // ダイアログ固有のコントロール定義
            startConfirmDialog.dlg();
            deleteConfirmDialog.dlg();
            allGenshizaiConfirmDialog.dlg();
            completeDialog.dlg();

            /// 品名マスタセレクタを起動する
            var showHinmeiDialog = function () {
                option = { id: 'hinmei', multiselect: false, param1: pageLangText.genshizaiJikagenHinDlgParam.text };
                hinmeiDialog.draggable(true);
                //hinmeiDialog.draggable({ containment: document.body, scroll: false });    // IE以外では挙動がおかしい？保留中
                hinmeiDialog.dlg("open", option);
            };

            /// <summary>ダイアログを開きます。</summary>
            // 計算在庫作成確認時のダイアログ
            var showStartConfirmDialog = function () {
                startConfirmDialogNotifyInfo.clear();
                startConfirmDialogNotifyAlert.clear();
                startConfirmDialog.draggable(true);
                //startConfirmDialog.draggable({ containment: document.body, scroll: false });    // IE以外では挙動がおかしい？保留中
                startConfirmDialog.dlg("open");
            };
            // 計算在庫の破棄確認時のダイアログ
            var showDeleteConfirmDialog = function () {
                deleteConfirmDialogNotifyInfo.clear();
                deleteConfirmDialogNotifyAlert.clear();
                deleteConfirmDialog.draggable(true);
                //deleteConfirmDialog.draggable({ containment: document.body, scroll: false });   // IE以外では挙動がおかしい？保留中
                deleteConfirmDialog.dlg("open");
            };
            // 全原資材選択時の確認ダイアログ
            var showAllGenshizaiConfirmDialog = function () {
                allGenshizaiConfirmDialogNotifyInfo.clear();
                allGenshizaiConfirmDialogNotifyAlert.clear();
                allGenshizaiConfirmDialog.draggable(true);
                //allGenshizaiConfirmDialog.draggable({ containment: document.body, scroll: false }); // IE以外では挙動がおかしい？保留中
                allGenshizaiConfirmDialog.dlg("open");
            };
            // 計算終了ダイアログ
            var showCompleteDialog = function () {
                completeDialogNotifyInfo.clear();
                completeDialogNotifyAlert.clear();
                completeDialog.draggable(true);
                completeDialog.dlg("open");
            };

            /// <summary>ダイアログを閉じます。</summary>
            var closeStartConfirmDialog = function () {
                startConfirmDialog.dlg("close");
            };
            var closeDeleteConfirmDialog = function () {
                deleteConfirmDialog.dlg("close");
            };
            var closeAllGenshizaiConfirmDialog = function () {
                allGenshizaiConfirmDialog.dlg("close");
            };
            var closeCompleteDialog = function () {
                completeDialog.dlg("close");
            };

            // 多言語対応
            var datePickerFormat = pageLangText.dateFormatUS.text;
            if (App.ui.page.langCountry != 'en-US') {
                datePickerFormat = pageLangText.dateFormat.text;
            }

            // TODO：画面の仕様に応じて以下の datepicker の設定を変更してください。
            dtFrom.on("keyup", App.data.addSlashForDateString);
            dtFrom.datepicker({ dateFormat: datePickerFormat });
            dtTo.on("keyup", App.data.addSlashForDateString);
            dtTo.datepicker({ dateFormat: datePickerFormat });
            // TODO：ここまで

            // グリッドコントロール固有のコントロール定義
            grid.jqGrid({
                // TODO：画面の仕様に応じて以下の列名の定義を変更してください。
                colNames: [
                    pageLangText.cd_hinmei.text,
                    pageLangText.nm_hinmri.text,
                    pageLangText.dt_from.text,
                    pageLangText.dt_to.text
                ],
                // TODO：ここまで
                // TODO：画面の仕様に応じて以下の列モデルの定義を変更してください。
                colModel: [
                    { name: 'cd_hinmei', width: 0, hidden: true, hidedlg: true },
                    { name: 'nm_hinmri', width: 0, hidden: true, hidedlg: true },
                    { name: 'dt_from', width: 0, hidden: true, hidedlg: true },
                    { name: 'dt_to', width: 0, hidden: true, hidedlg: true }
                ],
                // TODO：ここまで
                datatype: "local",
                shrinkToFit: false,
                multiselect: false,
                rownumbers: false,
                cellEdit: false,
                cellsubmit: 'clientArray'
            });

            //// コントロール定義 -- End

            //// 操作制御定義 -- Start

            // 操作制御定義を定義します。
            App.ui.pagedata.operation.applySetting(App.ui.page.user.Roles[0], App.ui.page.lang);

            //// 操作制御定義 -- End

            //// 事前データロード -- Start 

            /// <summary>時間を省いたシステム日付を日付オブジェクトで取得する</summary>
            var getSystemDate = function () {
                var sysdate = new Date(new Date().getFullYear(), new Date().getMonth(), new Date().getDate());
                return sysdate;
            };

            /// <summary>原資材計画管理トランの検索クエリを取得する</summary>
            /// <param name="code">品名コード</param>
            var getQueryUrl = function (hinCode) {
                var str = "../Services/FoodProcsService.svc/vw_tr_genshizai_keikaku_01";
                if (!App.isUndefOrNull(hinCode)) {
                    str = "../Services/FoodProcsService.svc/tr_genshizai_keikaku?$filter=cd_hinmei eq '"
                        + hinCode + "'";
                }
                return str;
            };

            /// <summary>在庫計算日を設定する</summary>
            var setZaikoKeisanDate = function () {
                var dt_kaishi = getSystemDate();
                var dt_matsu = getSystemDate();

                $(".search-criteria [name='dt_from']").datepicker("setDate", dt_kaishi);
                // 在庫計算末日：初日＋作成できる最大期間日数を挿入
                var maxKikan = parseInt(pageLangText.maxPeriod.text);
                dt_matsu.setDate(dt_matsu.getDate() + maxKikan);
                $(".search-criteria [name='dt_to']").datepicker("setDate", dt_matsu);
            };
            // 初期表示処理：在庫計算日を設定する
            setZaikoKeisanDate();

            // 画面アーキテクチャ共通の事前データロード
            //var loading;
            //App.deferred.parallel({
            //    // ローディング
            //    loading: App.ui.loading.show(pageLangText.nowProgressing.text)
            //}).done(function (result) {
            //    // サービス呼び出し成功
            //
            //}).fail(function (result) {
            //    var length = result.key.fails.length,
            //        messages = [];
            //    for (var i = 0; i < length; i++) {
            //        var keyName = result.key.fails[i];
            //        var value = result.fails[keyName];
            //        messages.push(keyName + " " + value.message);
            //    }
            //    App.ui.page.notifyAlert.message(messages).show();
            //
            //}).always(function () {
            //    App.ui.loading.close();
            //});

            //// 事前データロード -- End

            //// 検索処理 -- Start
            //// 検索処理 -- End

            //// 作成条件の各処理 -- Start

            /// <summary>クエリオブジェクトの設定</summary>
            var queryZaikoKeisan = function () {
                var query = {
                    url: "../Services/FoodProcsService.svc/tr_genshizai_keikaku",
                    filter: createFilter(),
                    inlinecount: "allpages"
                };
                return query;
            };
            /// <summary>フィルター条件の設定</summary>
            var createFilter = function () {
                var criteria = $(".search-criteria").toJSON(),
                    filters = [];
                searchCondition = criteria;
                filters.push("dt_zaiko_keisan ge DateTime'" + App.data.getDateTimeStringForQuery(criteria.dt_from) + "'");
                filters.push("dt_zaiko_keisan le DateTime'" + App.data.getDateTimeStringForQuery(criteria.dt_to) + "'");
                if (!App.isUndefOrNull(con_hinmei)) {
                    filters.push("cd_hinmei eq '" + con_hinmei + "'");
                }

                return filters.join(" and ");
            };
            /// <summary>計算在庫作成済みの情報を取得する</summary>
            /// 原資材計画管理トラン.計算在庫自動作成最終日を取得する
            var getKeisanZaikoDate = function () {
                var keikakuQuery = queryZaikoKeisan();
                // ローディングの表示
                App.ui.loading.show(pageLangText.nowProgressing.text)
                App.ajax.webget(
                    App.data.toODataFormat(keikakuQuery)
                ).done(function (result) {
                    // 取得処理成功時

                    // ローディング終了
                    App.ui.loading.close();

                    // データが存在した場合
                    if (result.d.__count > 0) {
                        showDeleteConfirmDialog();
                    }
                    else {
                        showStartConfirmDialog();
                    }

                }).fail(function (result) {
                    // ローディング終了
                    App.ui.loading.close();
                    // サービス呼び出し失敗時
                    if (result.message != "") {
                        App.ui.page.notifyAlert.message(result.message).show();
                    }
                    else {
                        App.ui.page.notifyAlert.message(MS0084).show();
                    }
                });
            };

            /// <summary>計算在庫作成処理</summary>
            /// <param name="query">クエリオブジェクト</param>
            var createKeisanZaiko = function () {
                // ローディング開始
                App.ui.loading.show(pageLangText.nowProgressing.text);

                var criteria = $(".search-criteria").toJSON();
                //url = url + "?dtFrom=" + App.data.getDateTimeStringForQuery(criteria.dt_from)
                //    + "&dtTo=" + App.data.getDateTimeStringForQuery(criteria.dt_to)
                //    + "&hinCd=" + con_hinmei
                //    + "&user=" + App.ui.page.user.Code
                //    + "&today=" + App.data.getDateTimeStringForQuery(getSystemDate());
                // 必要な情報をURLに設定
                var urlParam = {
                    url: "../api/KeisanZaikoSakusei"
                    , dtFrom: App.data.getDateTimeStringForQuery(criteria.dt_from)
                    , dtTo: App.data.getDateTimeStringForQuery(criteria.dt_to)
                    , hinCd: con_hinmei
                    , user: App.ui.page.user.Code
                    , today: App.data.getDateTimeStringForQuery(getSystemDate())
                    , lang: App.ui.page.lang
                    , con_kbn_hin: null
                    , con_bunrui: ""
                    , con_kurabasho: ""
                    , con_nm_hinmei: ""
                };
                var url = App.data.toWebAPIFormat(urlParam);

                App.ajax.webpost(
                    url
                ).done(function (result) {
                    // 作成完了メッセージの表示
                    //App.ui.page.notifyInfo.message(pageLangText.creatCompletion.text).show();
                    showCompleteDialog();
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                    App.ui.loading.close();
                }).always(function () {
                    // ローディング終了
                    App.ui.loading.close();
                });
            };

            /// <summary>在庫計算開始ボタンクリック時のイベント処理を行います。</summary>
            var calculationStart = function () {
                // メッセージとエラー枠のクリア
                App.ui.page.notifyInfo.clear();
                App.ui.page.notifyAlert.clear();
                //resetBorder("#id_dt_from");
                //resetBorder("#id_dt_to");
                //resetBorder("#id_cd_hinmei");

                // チェック処理
                if (!checkCondition()) {
                    return;
                }

                // 「全原資材について～」が選択されていた場合、確認ダイアログを表示する
                var selectVal = $("input:radio[name='select_type']:checked").val();
                if (selectVal == pageLangText.selectAllGenshizai.text) {
                    con_hinmei = "";    // 引数用品名コードをクリア
                    showAllGenshizaiConfirmDialog();
                }
                else {
                    // 引数用品名コードに作成条件の品名コードを設定
                    con_hinmei = $(".search-criteria").toJSON().cd_hinmei;
                    // 計算在庫作成済情報取得処理
                    //getKeisanZaikoDate();
                    // 作成開始確認ダイアログ
                    showStartConfirmDialog();
                }
            };
            /// <summary>在庫計算開始ボタンクリック時のチェック処理を行います。</summary>
            var checkCondition = function () {
                var isValid = true,
                    commentValid = true;

                ///// バリデーション
                var result = $(".part-body .item-list").validation().validate();
                if (result.errors.length) {
                    return false;
                }

                ///// 相関チェック
                var criteria = $(".search-criteria").toJSON();
                var firstDay = criteria.dt_from,
                    endOfMonth = criteria.dt_to;
                // エラー一覧クリック用ユニークキー
                var uniqueFrom = $("#id_dt_from");
                var uniqueTo = $("#id_dt_to");
                var uniqueHin = $("#id_cd_hinmei");

                // 「以下の品名コードの～」が選択されている場合、品名コードは必須
                var selectVal = $("input:radio[name='select_type']:checked").val();
                if (selectVal == pageLangText.selectGenshizai.text) {
                    var hinmei = $("#id_nm_hinmei").text();
                    if (App.isUndefOrNull(hinmei) || hinmei == "") {
                        //setErrorBorder("#id_cd_hinmei");
                        App.ui.page.notifyAlert.message(pageLangText.hinmeiCheck.text, uniqueHin).show();
                        isValid = false;
                    }
                }

                // 在庫計算開始日＜在庫計算末日であること
                if (firstDay > endOfMonth) {
                    setErrorMessage(uniqueFrom);
                    setErrorMessage(uniqueTo);
                    //setErrorBorder("#id_dt_from");
                    //setErrorBorder("#id_dt_to");
                    /*
                    App.ui.page.notifyAlert.message(
                    App.str.format(
                    pageLangText.dateCheck.text
                    , pageLangText.dt_to.text
                    , pageLangText.dt_from.text)
                    , uniqueFrom
                    ).show();
                    */
                    isValid = false;
                }

                // 初日～末日が最大期間日数以内であること
                var maxKikan = parseInt(pageLangText.maxPeriod.text);
                firstDay.setDate(firstDay.getDate() + maxKikan);
                if (firstDay < endOfMonth) {
                    setErrorDiff(uniqueFrom);
                    setErrorDiff(uniqueTo);
                    //App.ui.page.notifyAlert.message(pageLangText.dateCheckPeriod.text, uniqueFrom).show();
                    /*
                    App.ui.page.notifyAlert.message(pageLangText.dateCheckPeriod.text, uniqueFrom).show();
                    setErrorBorder("#id_dt_from");
                    setErrorBorder("#id_dt_to");
                    */
                    isValid = false;
                }

                return isValid;
            };

            // 枠線をエラー状態にする
            var setErrorDiff = function (targetId) {
                App.ui.page.notifyAlert.message(App.str.format(pageLangText.dateCheckPeriod.text), targetId).show();
            };
            // 枠線をエラー状態にする
            var setErrorMessage = function (targetId) {
                App.ui.page.notifyAlert.message(App.str.format(pageLangText.dateCheck.text, pageLangText.dt_to.text, pageLangText.dt_from.text), targetId).show();
            };
            // 枠線をエラー状態にする
            var setErrorBorder = function (targetId) {
                // border→colorの順でないと色が変わらないので注意
                $(targetId).css({ "border": "solid 2px", "border-color": "#FF6666" });
            };
            // エラー状態の枠線を元に戻す
            var resetBorder = function (targetId) {
                $(targetId).css({ "border": "solid 1px", "border-color": "" });
            };

            /// <summary>在庫計算開始ボタンクリック</summary>
            $(".keisan-button").on("click", function () {
                calculationStart();
            });

            //// 作成条件の各処理 -- End

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
            // ダイアログ情報メッセージの設定

            // 計算在庫作成確認時ダイアログ情報メッセージの設定
            var startConfirmDialogNotifyInfo = App.ui.notify.info(startConfirmDialog, {
                container: ".start-confirm-dialog .dialog-slideup-area .info-message",
                messageContainerQuery: "ul",
                show: function () {
                    startConfirmDialog.find(".info-message").show();
                },
                clear: function () {
                    startConfirmDialog.find(".info-message").hide();
                }
            });
            // 計算在庫の破棄確認時ダイアログ情報メッセージの設定
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
            // 全原資材選択時の確認ダイアログ情報メッセージの設定
            var allGenshizaiConfirmDialogNotifyInfo = App.ui.notify.info(allGenshizaiConfirmDialog, {
                container: ".allGenshizai-confirm-dialog .dialog-slideup-area .info-message",
                messageContainerQuery: "ul",
                show: function () {
                    allGenshizaiConfirmDialog.find(".info-message").show();
                },
                clear: function () {
                    allGenshizaiConfirmDialog.find(".info-message").hide();
                }
            });
            // 計算完了ダイアログ情報メッセージの設定
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

            // ダイアログ警告メッセージの設定
            var startConfirmDialogNotifyAlert = App.ui.notify.alert(startConfirmDialog, {
                container: ".start-confirm-dialog .dialog-slideup-area .alert-message",
                messageContainerQuery: "ul",
                show: function () {
                    startConfirmDialog.find(".alert-message").show();
                },
                clear: function () {
                    startConfirmDialog.find(".alert-message").hide();
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
            var allGenshizaiConfirmDialogNotifyAlert = App.ui.notify.alert(allGenshizaiConfirmDialog, {
                container: ".allGenshizai-confirm-dialog .dialog-slideup-area .alert-message",
                messageContainerQuery: "ul",
                show: function () {
                    allGenshizaiConfirmDialog.find(".alert-message").show();
                },
                clear: function () {
                    allGenshizaiConfirmDialog.find(".alert-message").hide();
                }
            });
            var completeDialogNotifyAlert = App.ui.notify.alert(completeDialog, {
                container: ".complete-dialog .dialog-slideup-area .alert-message",
                messageContainerQuery: "ul",
                show: function () {
                    completeDialog.find(".alert-message").show();
                },
                clear: function () {
                    completeDialog.find(".alert-message").hide();
                }
            });

            //// メッセージ表示 -- End

            //// データ変更処理 -- Start
            //// データ変更処理 -- End

            /// <summary>原資材一覧ボタンクリック時のイベント処理を行います。</summary>
            $(".genshizai-button").on("click", function (e) {
                showHinmeiDialog();
            });

            /// 検索条件/原資材のイベント処理を行います。
            $("#id_cd_hinmei").dblclick(function () {
                // ダブルクリック時：品名ダイアログを開く
                showHinmeiDialog();
            });

            //// 保存処理 -- Start
            //// 保存処理 -- End

            //// バリデーション -- Start

            // グリッドコントロール固有のバリデーション

            /// <summary>原資材名を取得します。(マスタ存在チェック)</summary>
            /// <param name="cdHinmei">原資材コード</param>
            var isValidHinCode = function (cdHinmei) {
                var isValid = true,
                    query = {
                        url: "../Services/FoodProcsService.svc/ma_hinmei",
                        filter: "cd_hinmei eq '" + cdHinmei +
                                "' and (kbn_hin eq " + pageLangText.genryoHinKbn.text +
                                " or kbn_hin eq " + pageLangText.shizaiHinKbn.text +
                                " or kbn_hin eq " + pageLangText.jikaGenryoHinKbn.text +
                                ") and flg_mishiyo eq " + pageLangText.shiyoMishiyoFlg.text,
                        top: 1
                    };
                // 品名コードが未入力の場合はチェックを行わない
                if (App.isUndefOrNull(cdHinmei)
                    || cdHinmei.length === 0) {
                    $("#id_nm_hinmei").text("");
                    return isValid;
                }

                // 品名マスタ存在チェック
                App.ajax.webgetSync(
                    App.data.toODataFormat(query)
                ).done(function (result) {
                    if (result.d.length === 0) {
                        // 検索結果件数が0件の場合

                        // 品名マスタ存在チェックエラー
                        $("#id_nm_hinmei").text("");
                        isValid = false;
                    }
                    else {
                        // 検索結果が取得できた場合

                        // 検索条件/品名に取得した原資材名を設定
                        $("#id_nm_hinmei").text(result.d[0][hinName]);
                    }
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                    isValid = false;
                });
                return isValid;
            };
            // 原資材コードからフォーカスを外したタイミングで名称取得処理を行う
            validationSetting.cd_hinmei.rules.custom = function (value) {
                return isValidHinCode(value);
            };

            // グリッドのバリデーション設定
            var v = Aw.validation({
                items: validationSetting
            });

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

            //// バリデーション -- End

            /// <summary>ファンクションキー対応処理</summary>
            /// <param name="e">イベントデータ</param>
            var processFunctionKey = function (e) {
                var processed = false;
                // ファンクションキー毎の処理を定義します。
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
                    searchPart = $(".search-criteria");
            };
            /// <summary>画面リサイズ時のイベント処理を行います。</summary>
            $(App.ui.page).on("resized", resizeContents);

            /// <summary>計算在庫を作成確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".start-confirm-dialog .dlg-yes-button").on("click", function () {
                closeStartConfirmDialog();
                createKeisanZaiko();
            });
            // <summary>計算在庫を作成確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".start-confirm-dialog .dlg-no-button").on("click", closeStartConfirmDialog);

            /// <summary>計算在庫の破棄確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".delete-confirm-dialog .dlg-yes-button").on("click", function () {
                closeDeleteConfirmDialog();
                createKeisanZaiko();
            });
            // <summary>計算在庫の破棄確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".delete-confirm-dialog .dlg-no-button").on("click", closeDeleteConfirmDialog);

            /// <summary>全原資材選択時の確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".allGenshizai-confirm-dialog .dlg-yes-button").on("click", function () {
                closeAllGenshizaiConfirmDialog();
                //getKeisanZaikoDate();
                createKeisanZaiko();
            });
            // <summary>全原資材選択時の確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".allGenshizai-confirm-dialog .dlg-no-button").on("click", closeAllGenshizaiConfirmDialog);

            /// <summary>計算完了ダイアログの「閉じる」ボタンクリック時のイベント処理を行います。</summary>
            $(".complete-dialog .dlg-close-button").on("click", closeCompleteDialog);

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
    </script>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <!-- 画面デザイン -- Start -->

    <!-- 出力条件 -->
    <div class="content-part search-criteria">
        <h3 class="part-header" data-app-text="selectCriteria"></h3>
        <div class="part-body">
            <ul class="item-list item-command">
                <!-- TODO: 画面の仕様に応じて以下の項目を変更してください。-->
                <li>
                    <!-- ラジオボタン：全原資材 -->
                    <label>
                        <input type="radio" name="select_type" id="id_all_genshizai" value="1" checked="checked" />
                        <span class="item-label" style="width: 230px" data-app-text="label_all_genshizai"></span>
                    </label>
                </li>
                <li>
                    <!-- ラジオボタン：以下の品名コードの原資材 -->
                    <label>
                        <input type="radio" name="select_type" id="id_genshizai" value="2" />
                        <span class="item-label" style="width: 350px" data-app-text="label_genshizai"></span>
                    </label>
                </li>
                <li>
                    <!-- スペース -->
                    <label>
                        <span class="item-label">&nbsp;</span>
                    </label>
                </li>
                <li>
                    <!-- 品名コード -->
                    <label>
                        <span class="item-label" style="width: 120px" data-app-text="cd_hinmei"></span>
                        <input type="text" id="id_cd_hinmei" name="cd_hinmei" style="width: 120px" maxlength="14" />
                    </label>
                    <!-- ボタン：原資材一覧 -->
                    <label>
                        <button type="button" class="dialog-button genshizai-button" name="genshizai-button" data-app-operation="genshizaiIchiran" style="width:120px;">
                            <span class="icon"></span><span data-app-text="genshizaiIchiran"></span>
                        </button>
                    </label>
                    <!-- 品名 -->
                    <label>
                        <span class="item-label" id="id_nm_hinmei" name="nm_hinmei" style="width: 300px"></span>
                    </label>
                </li>
                <li>
                    <!-- スペース -->
                    <label>
                        <span class="item-label">&nbsp;</span>
                    </label>
                </li>
                <li>
                    <!-- 在庫計算開始日 -->
                    <label>
                        <span class="item-label" style="width: 120px" data-app-text="dt_from"></span>
                        <input type="text" name="dt_from" id="id_dt_from" style="width: 120px" />
                        <span class="item-label" style="width: 30px">&nbsp;</span>
                    </label>
                    <label>
                        <span class="item-label" style="width: 40px" data-app-text="between"></span>
                    </label>
                    <!-- 在庫計算末日 -->
                    <label>
                        <span class="item-label" style="width: 120px" data-app-text="dt_to"></span>
                        <input type="text" name="dt_to" id="id_dt_to" style="width: 120px" />
                        <span class="item-label" style="width: 30px">&nbsp;</span>
                    </label>
                </li>
                <li>
                    <!-- スペース -->
                    <label>
                        <span class="item-label">&nbsp;</span>
                    </label>
                </li>
                <!-- TODO: ここまで -->
            </ul>
        </div>
    </div>

    <!-- 画面デザイン -- End -->
</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="FooterContent" runat="server">
    <!-- 画面デザイン -- Start -->

    <!-- 画面アーキテクチャ共通のデザイン -- Start -->
    <div class="command" style="left: 1px;">
        <!-- TODO: 画面の仕様に応じて以下のボタンを変更してください。 -->
        <button type="button" class="keisan-button" name="keisan-button" data-app-operation="keisanStart" style="width: 140px;">
            <span class="icon"></span>
            <span data-app-text="keisan_start"></span>
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
    <div class="start-confirm-dialog" style="display: none;">
        <div class="dialog-header">
            <h4 data-app-text="confirmTitle"></h4>
        </div>
        <div class="dialog-body" style="padding: 10px; width: 100%;">
            <div class="part-body">
                <span data-app-text="startConfirm"></span>
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
    <div class="allGenshizai-confirm-dialog" style="display: none;">
        <div class="dialog-header">
            <h4 data-app-text="confirmTitle"></h4>
        </div>
        <div class="dialog-body" style="padding: 10px; width: 100%;">
            <div class="part-body">
                <span data-app-text="allGenshizaiConfirm"></span>
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
    <div class="complete-dialog" style="display: none;">
        <div class="dialog-header">
            <h4 data-app-text="confirmTitle"></h4>
        </div>
        <div class="dialog-body" style="padding: 10px; width: 100%;">
            <div class="part-body">
                <span data-app-text="creatCompletion"></span>
            </div>
        </div>
        <div class="dialog-footer">
            <div class="command-detail" style="position: absolute; left: 10px; top: 5px">
                <button class="dlg-close-button" name="dlg-close-button" data-app-text="close"></button>
            </div>
        </div>
    </div>
    <div class="hinmei-dialog">
    </div>
    <!-- TODO: ここまで  -->

    <!-- 画面デザイン -- End -->
</asp:Content>
