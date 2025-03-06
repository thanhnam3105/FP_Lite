<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="KeikokuListSakusei.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.KeikokuListSakusei" %>

<asp:Content ID="Content1" ContentPlaceHolderID="IncludeContent" runat="server">
    <script src="<%=ResolveUrl("~/Resources/pages/pagedata-keikokulistsakusei." + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
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
        
        .part-body .item-list-left
        {
            float: left;
            width: 450px;
        }
        
        .part-body .item-list-center
        {
            float: left;
            /*width: 450px;*/
        }
        
        .part-body .item-list-right li
        {
            float: right;
            margin-left: 0%;
        }
        
        .search-criteria select
        {
            width: 20em;
        }
                
        .search-criteria .item-label
        {
            width: 10em;
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
                firstCol = 1,
                duplicateCol = 999,
                currentRow = 0,
                currentCol = firstCol;
            // TODO: ここまで

            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            var hinKubun, // 検索条件：品区分のコンボボックス
                hinBunrui, // 検索条件：品分類のコンボボックス
                kurabasho, // 検索条件：庫場所のコンボボックス
            // 多言語対応にしたい項目を変数にする
                hinmeiName = 'nm_hinmei_' + App.ui.page.lang;  // 原資材名
            // TODO：ここまで

            // 英語化対応　言語によって幅を調節
            //$(".part-body .item-list-left").css("width", pageLangText.item_list_left_width.number);
            $(".search-criteria .item-label-right").css("width", pageLangText.each_lang_width.number);
            $("#span_zenZaiko_tojitsuShiyo").css("width", pageLangText.zenZaiko_tojitsuShiyo_width.number);
            $("#keikoku_max").css("width", pageLangText.keikoku_max_width.number);
            $("#allGenshizai").css("width", pageLangText.allGenshizai_width.number);

            // ダイアログ固有の変数宣言
            var startConfirmDialog = $(".start-confirm-dialog"),
                allGenshizaiConfirmDialog = $(".allGenshizai-confirm-dialog"),
                completeDialog = $(".complete-dialog");

            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            // TODO：ここまで

            //// 変数宣言 -- End

            //// コントロール定義 -- Start

            // ダイアログ固有のコントロール定義
            startConfirmDialog.dlg();
            allGenshizaiConfirmDialog.dlg();
            completeDialog.dlg();

            /// <summary>ダイアログを開きます。</summary>
            // 計算在庫作成確認時のダイアログ
            var showStartConfirmDialog = function () {
                startConfirmDialogNotifyInfo.clear();
                startConfirmDialogNotifyAlert.clear();
                startConfirmDialog.draggable(true);
                //startConfirmDialog.draggable({ containment: document.body, scroll: false });    // IE以外では挙動がおかしい？保留中
                startConfirmDialog.dlg("open");
            };
            // 全原資材選択時の確認ダイアログ
            var showAllGenshizaiConfirmDialog = function () {
                allGenshizaiConfirmDialogNotifyInfo.clear();
                allGenshizaiConfirmDialogNotifyAlert.clear();
                allGenshizaiConfirmDialog.draggable(true);
                //allGenshizaiConfirmDialog.draggable({ containment: document.body, scroll: false }); // IE以外では挙動がおかしい？保留中
                allGenshizaiConfirmDialog.dlg("open");
            };
            // 計算完了ダイアログ
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
            var closeAllGenshizaiConfirmDialog = function () {
                allGenshizaiConfirmDialog.dlg("close");
            };
            var closeCompleteDialog = function () {
                completeDialog.dlg("close");
            };

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

            /// 月の初日を取得
            var getFromFirstDateStringForQuery = function (date) {
                var result = new Date(date.getFullYear(), date.getMonth(), 1, 00, 00, 00);

                return App.data.getDateString(result, true);
            };

            // 日付系の多言語対応
            var datePickerFormat = pageLangText.dateFormatUS.text;
            var dateSrcFormat = pageLangText.dateSrcFormatUS.text;
            var newDateMMDDFormat = pageLangText.dateMMDDFormatUS.text;
            var dt_hizuke = pageLangText.dt_hizukeUS.text;
            var newDateFormat = pageLangText.dateNewFormatUS.text;
            if (App.ui.page.langCountry != 'en-US') {
                datePickerFormat = pageLangText.dateFormat.text;
                dateSrcFormat = pageLangText.dateSrcFormat.text;
                newDateMMDDFormat = pageLangText.dateMMDDFormat.text;
                dt_hizuke = pageLangText.dt_hizuke.text;
                newDateFormat = pageLangText.dateNewFormat.text;
            }
            // 日付系の多言語対応：ここまで

            // TODO：画面の仕様に応じて以下の datepicker の設定を変更してください。
            $("#condition-date, #condition-date_to").on("keyup", App.data.addSlashForDateString);
            $("#condition-date, #condition-date_to").datepicker({ dateFormat: datePickerFormat });
            // 有効範囲：1970/1/1～システム日付より1年後
            $("#condition-date, #condition-date_to").datepicker("option", 'minDate', new Date(1970, 1 - 1, 1));
            $("#condition-date, #condition-date_to").datepicker("option", 'maxDate', "+10y");
            // TODO：ここまで

            // グリッドコントロール固有のコントロール定義
            grid.jqGrid({
                // TODO：画面の仕様に応じて以下の列名の定義を変更してください。
                colNames: [
                    dt_hizuke,
                    pageLangText.cd_hinmei.text,
                    pageLangText.nm_hinmei.text,
                    pageLangText.nm_nisugata_hyoji.text,
                    pageLangText.tani_shiyo.text,
                    pageLangText.su_zaiko.text,
                    pageLangText.su_zaiko_min.text,
                    pageLangText.su_zaiko_max.text,
                    pageLangText.nm_torihiki.text,
                    pageLangText.dt_hizuke_full.text
                ],
                // TODO：ここまで
                // TODO：画面の仕様に応じて以下の列モデルの定義を変更してください。
                colModel: [
                    { name: 'dt_hizuke', width: pageLangText.dt_hizuke_width.number, sorttype: "text", align: "center", frozen: true,
                        formatter: "date",
                        formatoptions: {
                            srcformat: dateSrcFormat, newformat: newDateMMDDFormat
                        }
                    },
                    { name: 'cd_hinmei', width: pageLangText.cd_hinmei_width.number, editable: false, sorttype: "text", frozen: true },
                    { name: hinmeiName, width: pageLangText.nm_hinmei_width.number, editable: false, sorttype: "text", frozen: true },
                    { name: 'nm_nisugata_hyoji', width: pageLangText.nm_nisugata_hyoji_width.number, editable: false, sorttype: "text" },
                    { name: 'tani_shiyo', width: pageLangText.tani_shiyo_width.number, editable: false, align: "center", sorttype: "text" },
                    { name: 'su_zaiko', width: pageLangText.su_zaiko_width.number, editable: false, align: "right", sorttype: "float",
                        formatter: 'number',
                        formatoptions: {
                            decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 3, defaultValue: "0"
                        }
                    },
                    { name: 'su_zaiko_min', width: pageLangText.su_zaiko_min_width.number, editable: false, align: "right", sorttype: "float",
                        formatter: 'number',
                        formatoptions: {
                            decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 3, defaultValue: "0"
                        }
                    },
                    { name: 'su_zaiko_max', width: pageLangText.su_zaiko_max_width.number, editable: false, align: "right", sorttype: "float",
                        formatter: 'number',
                        formatoptions: {
                            decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 3, defaultValue: "0"
                        }
                    },
                    { name: 'nm_torihiki', width: pageLangText.nm_torihiki_width.number, editable: false, sorttype: "text" },
                    { name: 'dt_hizuke_full', width: 0, hidden: true, hidedlg: true,
                        formatter: "date",
                        formatoptions: {
                            srcformat: dateSrcFormat, newformat: newDateFormat
                        }
                    }
                ],
                // TODO：ここまで
                datatype: "local",
                shrinkToFit: false,
                multiselect: false,
                rownumbers: true,
                cellsubmit: 'clientArray',
                hoverrows: false,
                loadComplete: function () {
                    // 変数宣言
                    var ids = grid.jqGrid('getDataIDs');
                    //criteria = $(".search-criteria").toJSON();

                    for (var i = 0; i < ids.length; i++) {
                        var id = ids[i];
                        // TODO : ここから
                        // 在庫の文字色
                        var zaiko = grid.jqGrid('getCell', id, 'su_zaiko');
                        if (zaiko < 0) {
                            // 在庫 < 0 (負の数)の場合：文字色を赤色に変更
                            grid.setCell(id, "su_zaiko", '', { color: '#ff0000' });
                        }
                        else {
                            // 在庫 < 0 (正の数)の場合：文字色を黒に変更
                            grid.setCell(id, "su_zaiko", '', { color: '#000000' });
                        }
                        // TODO：ここまで
                    }

                    // グリッドの先頭行選択
                    var idNum = grid.getGridParam("selrow");
                    if (idNum == null) {
                        $("#1 > td").click();
                    }
                    else {
                        $("#" + idNum).removeClass("ui-state-highlight").find("td").click();
                    }
                },
                ondblClickRow: function (selectedRowId) {
                    // 原資材変動表画面を開く
                    changesHendohyo(selectedRowId);
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
            /// <summary>システム日付の前日を取得する</summary>
            var getSystemDatePreDay = function () {
                var sysdate = new Date(new Date().getFullYear(), new Date().getMonth(), new Date().getDate() - 1);
                return sysdate;
            };

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
                    + pageLangText.shiyoMishiyoFlg.text + "&$orderby=cd_kura")
                // TODO: ここまで
            }).done(function (result) {
                // TODO: 画面の仕様に応じて以下のサービス呼び出し成功時の処理を変更してください。
                hinKubun = result.successes.hinKubun.d;
                kurabasho = result.successes.kurabasho.d;
                var targetHinKbn = $("#condition-hinKubun");
                var targetKura = $("#condition-kurabasho");

                // 検索用ドロップダウンの設定
                App.ui.appendOptions(targetHinKbn, "kbn_hin", "nm_kbn_hin", hinKubun, true);
                App.ui.appendOptions(targetKura, "cd_kura", "nm_kura", kurabasho, true);

                // 当日日付を挿入
                $("#condition-date").datepicker("setDate", new Date());

                // 在庫計算末日：初日＋作成できる最大期間日数を挿入
                var dt_matsu = getSystemDate();
                var maxKikan = parseInt(pageLangText.maxPeriod.text);
                dt_matsu.setDate(dt_matsu.getDate() + maxKikan);
                $("#condition-date_to").datepicker("setDate", dt_matsu);

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
                var criteria = $(".search-criteria").toJSON(),
                    dt_end = "";
                searchCondition = criteria;

                //if (!App.isUndefOrNull(criteria.dt_target_to)) {
                //    dt_end = App.data.getDateTimeStringForQueryNoUtc(criteria.dt_target_to);
                //}

                var query = {
                    // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                    url: "../api/KeikokuListSakusei",
                    //con_hizuke: App.data.getDateTimeStringForQueryNoUtc(criteria.dt_target),
                    con_hizuke: "{0}",
                    con_kubun: criteria.hinKubun,
                    con_bunrui: criteria.hinBunrui,
                    con_kurabasho: criteria.kurabasho,
                    con_hinmei: encodeURIComponent(criteria.hinmei),
                    con_keikoku_list: getKeikokuList(criteria),
                    con_zaiko_max_flg: getCheckBoxValue(criteria.keikoku_max),
                    lang: App.ui.page.lang,
                    today: App.data.getDateTimeStringForQueryNoUtc(getSystemDate()),
                    //con_dt_end: dt_end,
                    con_dt_end: "{1}",
                    all_genshizai: getCheckBoxValue(criteria.allGenshizai),
                    flg_leadtime: getLeadtime(),
                    // TODO: ここまで
                    //skip: querySetting.skip,
                    top: querySetting.top
                    //inlinecount: "allpages"
                }

                return query;
            };
            /// <summary>クエリオブジェクトの設定</summary>
            var queryLeadtime = function () {
                var criteria = $(".search-criteria").toJSON(),
                    dt_end = "";
                searchCondition = criteria;

                var query = {
                    url: "../api/KeikokuListSakusei",
                    con_hizuke: "{0}",
                    con_dt_end: "{1}",
                    con_kubun: criteria.hinKubun,
                    con_bunrui: criteria.hinBunrui,
                    con_kurabasho: criteria.kurabasho,
                    con_hinmei: encodeURIComponent(criteria.hinmei),
                    lang: App.ui.page.lang,
                    userCode: App.ui.page.user.Code,
                    today: App.data.getDateTimeStringForQueryNoUtc(getSystemDate())
                }

                return query;
            };
            /// <summary>検索用：「警告リスト」or「前日在庫－当日使用」を返却</summary>
            var getKeikokuList = function (criteria) {
                var keikokuList = pageLangText.systemValueZero.text;
                if (!App.isUndefOrNull(criteria.select_keikoku)) {
                    keikokuList = criteria.select_keikoku;
                }
                return keikokuList;
            };
            /// <summary>検索用：チェックボックスにチェックがある場合(onの場合)「1」を返却</summary>
            var getCheckBoxValue = function (value) {
                if (!App.isUndefOrNull(value)) {
                    return pageLangText.systemValueOne.text;
                }
                return pageLangText.systemValueZero.text;
            };
            /// <summary>検索用：「納入リードタイムを加味する」にチェックがあるかどうか</summary>
            var getLeadtime = function () {
                var leadtime = pageLangText.systemValueZero.text;
                if ($("#con_leadtime_kami").prop('checked')) {
                    leadtime = pageLangText.systemValueOne.text;
                }
                return leadtime;
            };

            /// <summary>フィルター条件の設定</summary>
            //var createFilter = function () {
            //var criteria = $(".search-criteria").toJSON(),
            //filters = [];
            //searchCondition = criteria;
            // TODO: 画面の仕様に応じて以下のフィルター条件を変更してください。
            // TODO: ここまで

            //return filters.join(" and ");
            //};
            /// <summary>データ検索を行います。</summary>
            /// <param name="query">クエリオブジェクト</param>
            var searchItems = function (query) {
                if (isDataLoading === true) {
                    return;
                }
                isDataLoading = true;
                // ローディング開始
                App.ui.loading.show(pageLangText.nowProgressing.text);

                var dt_end = "";
                if (!App.isUndefOrNull(searchCondition.dt_target_to)) {
                    // 終了日に値がある場合
                    dt_end = App.data.getDateTimeStringForQueryNoUtc(searchCondition.dt_target_to);
                }

                // 検索用URLの作成
                var url = App.str.format(App.data.toWebAPIFormat(query)
                            , App.data.getDateTimeStringForQueryNoUtc(searchCondition.dt_target)
                            , dt_end);

                App.ajax.webget(
                    //App.data.toWebAPIFormat(query)
                    url
                ).done(function (result) {
                    // データバインド
                    bindData(result);
                    // 検索条件を閉じる
                    closeCriteria();
                    $(".ui-jqgrid-hdiv").scrollLeft(0); // 明細のスクロール位置をリセット
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                    // ローディングの終了
                    App.ui.loading.close();
                }).always(function () {
                    setTimeout(function () {
                        $("#list-loading-message").text("");
                        isDataLoading = false;
                    }, 500);
                    // ローディングの終了
                    App.ui.loading.close();
                });
            };

            /// <summary>納入リードタイムを加味するにチェックがある場合の計算在庫ワーク作成処理</summary>
            /// <param name="queryLeadTime">クエリオブジェクト</param>
            var searchItemsLeadTime = function (queryLeadTime) {
                if (isDataLoading === true) {
                    return;
                }
                isDataLoading = true;

                // 選択した日付を分割
                var dateObj = [],
                    splitDays = pageLangText.splitDays.number,
                    url,
                    resultData;

                // 日付object取得
                getDateSplitObject(dateObj, searchCondition.dt_target, searchCondition.dt_target_to, splitDays);

                // ローディング開始
                App.ui.loading.show(pageLangText.nowProgressing.text);

                setTimeout(function () { // gifを表示する
                    $.each(dateObj, function (index, item) {
                        var isSuccess = true,
                        url = App.str.format(App.data.toWebAPIFormat(queryLeadTime)
                            , App.data.getDateTimeStringForQueryNoUtc(item.from)
                            , App.data.getDateTimeStringForQueryNoUtc(item.to));
                        // 計算処理を実行
                        App.ajax.webpostSync(
                            url
                        ).done(function (result) {
                            if (index == dateObj.length - 1) {
                                // すべての検索が終了したら警告リスト作成処理へ
                                isDataLoading = false;
                                searchItems(new query());
                            }
                        }).fail(function (result) {
                            App.ui.page.notifyAlert.message(result.message).show();
                            App.ui.loading.close();
                            isSuccess = false;
                            isDataLoading = false;
                        });
                        return isSuccess;
                    });
                }, 1000);

                //App.ui.loading.close();
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
                clearState();
                // 検索前バリデーション
                var result = $(".part-body .item-list").validation().validate();
                if (result.errors.length) {
                    return;
                }

                // チェック処理：「納入リードタイムを加味する」にチェックが入っている場合、終了日は必須
                if ($("#con_leadtime_kami").prop('checked')) {
                    var dt_to = $("#condition-date_to").val();
                    if (App.isUndefOrNull(dt_to) || dt_to.length == 0) {
                        var unique = $("#condition-date_to");
                        App.ui.page.notifyAlert.message(MS0726, unique).show();
                        return;
                    }
                    else {
                        // 納入リードを加味した計算在庫の計算処理へ
                        searchItemsLeadTime(new queryLeadtime());
                    }
                }
                else {
                    // 警告リスト作成処理
                    searchItems(new query());
                }
            };
            $(".find-button").on("click", findData);

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
                // カラムの固定解除
                grid.destroyFrozenColumns();
                // データバインド
                //var currentData = grid.getGridParam("data").concat(result.d.results);
                //grid.setGridParam({ data: currentData }).trigger('reloadGrid', [{ current: true}]);
                var currentData = grid.getGridParam("data").concat(result);
                grid.setGridParam({ data: currentData });
                // カラムの固定
                grid.setFrozenColumns().trigger('reloadGrid', [{ current: true}]);
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

            /// <summary>品区分入力時のイベント処理を行います。</summary>
            var setHinBunrui = function () {
                // 品区分の値を元に、品分類コンボボックスの値を取得します。

                // 品分類の中身をクリア
                $("#condition-hinBunrui option").remove();

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
                    var target = $("#condition-hinBunrui");
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
            $("#condition-hinKubun").on("change", setHinBunrui);

            //// データ変更処理 -- End

            //// 保存処理 -- Start
            //// 保存処理 -- End

            //// バリデーション -- Start
            // グリッドコントロール固有のバリデーション
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

            /// <summary>警告リストラジオボタンが選択されたときのイベント処理</summary>
            $("#keikoku_list").click(function () {
                // 「最大在庫も警告」を操作可能にする
                $("#condition-keikoku_max").attr("disabled", false);
            });

            /// <summary>前日在庫－当日資料ラジオボタンが選択されたときのイベント処理</summary>
            $("#zenZaiko_tojitsuShiyo").click(function () {
                // チェックボックスのクリア
                $("#condition-keikoku_max").removeAttr('checked');
                // 「最大在庫も警告」を操作不可にする
                $("#condition-keikoku_max").attr("disabled", true);
            });

            /// <summary>原資材変動表への画面遷移を行う</summary>
            var changesHendohyo = function (selectedRowId) {
                if (!App.isUndefOrNull(selectedRowId)) {
                    var hinCode = grid.getCell(selectedRowId, "cd_hinmei"),
                        date = grid.getCell(selectedRowId, "dt_hizuke_full");
                    date = App.date.localDate(date);
                    //date = new Date(date);


                    // 原資材変動表画面に遷移
                    var url = "./GenshizaiHendoHyo.aspx";
                    // 遷移時に渡すパラメータを設定
                    url += "?cdHin=" + hinCode;
                    url += "&date=" + getFromFirstDateStringForQuery(date);
                    url += "&dateFrom=" + App.data.getDateString(searchCondition.dt_target, true);
                    url += "&dateTo=" + App.data.getDateString(searchCondition.dt_target_to, true);
                    
                    //window.location = url;
                    window.open(url, '_blank');
                }
            };
            /// <summary>変動表ボタンクリック時のイベント処理を行います。</summary>
            $(".hendohyo-button").on("click", function () {
                // 選択行のパラメータを取得
                var selectedRowId = getSelectedRowId();
                changesHendohyo(selectedRowId);
            });

            /// <summary>ダウンロードボタンクリック時のオーバレイ処理を行います。</summary>
            var downloadOverlay = function () {
                //App.ui.loading.show(pageLangText.nowProgressing.text);
                printExcel();
                //App.ui.loading.close();
                //App.ui.page.notifyInfo.message(pageLangText.successExcel.text).show();
            };
            /// <summary>Excelファイル出力を行います。</summary>
            var printExcel = function (e) {

                var query = {
                    // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                    url: "../api/KeikokuListSakuseiExcel",
                    // TODO: ここまで
                    //filter: createFilter(),
                    // TODO: 画面の仕様に応じて以下のソート条件を変更してください。
                    orderby: "cd_hinmei"
                    // TODO: ここまで
                };
                // 処理中を表示する
                App.ui.loading.show(pageLangText.nowProgressing.text);
                // 必要な情報を渡します
                // 初期値を「未選択」とし、入力があればそれを設定する
                var container = $(".search-criteria").toJSON(),
                    hinKbnName = pageLangText.noSelectConditionExcel.text;
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
                //var hinName = pageLangText.noSelectConditionExcel.text;
                //if (!App.isUndefOrNull(container.hinmei)) {
                //    hinName = container.hinmei;
                //}
                var flgKeikokuList = container.select_keikoku,
                    keikokuList = pageLangText.noSelectConditionExcel.text,
                    zenjitsuZaiko = pageLangText.noSelectConditionExcel.text,
                    keikokuMax = pageLangText.noSelectConditionExcel.text,
                    allGenshizai = pageLangText.noSelectConditionExcel.text,
                    leadtime = pageLangText.noSelectConditionExcel.text;
                if (flgKeikokuList == pageLangText.systemValueZero.text) {
                    // 「警告リスト」ラジオボタンが選択されていた場合
                    keikokuList = pageLangText.onCheckBoxExcel.text;
                    if (!App.isUndefOrNull(container.keikoku_max)) {
                        keikokuMax = pageLangText.onCheckBoxExcel.text;
                    }
                }
                else {
                    //「 前日在庫－当日使用」ラジオボタンが選択されていた場合
                    zenjitsuZaiko = pageLangText.onCheckBoxExcel.text;
                }
                // 「全ての原資材を表示」にチェックがある場合
                if (!App.isUndefOrNull(container.allGenshizai)) {
                    allGenshizai = pageLangText.onCheckBoxExcel.text;
                }

                var dt_end = "";
                if (!App.isUndefOrNull(container.dt_target_to)) {
                    dt_end = App.data.getDateTimeStringForQueryNoUtc(container.dt_target_to);
                }

                // 「納入リードタイムを加味する」にチェックがある場合
                if (!App.isUndefOrNull(container.leadtime_kami)) {
                    leadtime = pageLangText.onCheckBoxExcel.text;
                }

                var url = App.data.toODataFormat(query),
                    param = {
                        "lang": App.ui.page.lang,
                        "hinKubunName": encodeURIComponent(hinKbnName),
                        "hinBunruiName": encodeURIComponent(hinBunruiName),
                        "kurabashoName": encodeURIComponent(kurabashoName),
                        "keikokuList": keikokuList,
                        "zenjitsuZaiko": zenjitsuZaiko,
                        "keikokuMax": keikokuMax,
                        "userName": encodeURIComponent(App.ui.page.user.Name),
                        //"searchDateString": container.dt_zaiko,
                        "allGenshizaiDisp": allGenshizai,
                        // 検索用
                        "con_kubun": container.hinKubun,
                        "con_bunrui": container.hinBunrui,
                        "con_kurabasho": container.kurabasho,
                        "con_hinmei": encodeURIComponent(container.hinmei),
                        "con_keikoku_list": flgKeikokuList,
                        "con_zaiko_max_flg": getCheckBoxValue(container.keikoku_max),
                        "all_genshizai": getCheckBoxValue(container.allGenshizai),
                        "flg_leadtime": getLeadtime(),
                        "con_hizuke": App.data.getDateTimeStringForQueryNoUtc(container.dt_target),
                        "con_dt_end": dt_end,
                        "leadtimeKami": leadtime,
                        "today": App.data.getDateTimeStringForQueryNoUtc(getSystemDate()),
                        "outputDate": App.data.getDateTimeStringForQuery(new Date(), true),
                        "UTC": new Date().getTimezoneOffset() / 60,
                        "splitDays": pageLangText.splitDays.number
                    };
                url = getExcelUrl(url, param);

                window.open(url, '_parent');
                // Cookieを監視する
                onComplete();
            };
            // 引数のパラメーターを設定したEXCEL出力用URLを取得
            var getExcelUrl = function (url, param) {
                var str = "";
                for (var key in param) {
                    str += ("&" + key + "=" + param[key]);
                }
                return url + str;
            };
            /// <summary>Excelボタンクリック時のイベント処理を行います。</summary>
            $(".excel-button").on("click", function () {
                //// 出力前チェック ////
                // 検索条件の必須チェック
                var result = $(".part-body .item-list").validation().validate();
                if (result.errors.length) {
                    return;
                }

                // 出力処理へ
                printExcel();
            });


            //2020/09/14 wang start
            // Cookieを1秒ごとにチェックする
            var onComplete = function () {
                if (app_util.prototype.getCookieValue(pageLangText.keikokuListSakuseiCookie.text) == pageLangText.checkCookie.text) {
                    app_util.prototype.deleteCookie(pageLangText.keikokuListSakuseiCookie.text);
                    //ローディング終了
                    App.ui.loading.close();
                }
                else {
                    // 再起してCookieが作成されたか監視
                    setTimeout(onComplete, 1000);
                }
            };

            /// <summary>計算在庫更新ボタンクリック時のチェック処理</summary>
            var checkKeisanZaikoUpdate = function (criteria) {
                //var criteria = $(".search-criteria").toJSON();

                // チェック処理
                var result = $(".part-body .item-list").validation().validate();
                if (result.errors.length) {
                    return false;
                }
                // 計算在庫更新のときは終了日必須
                if (App.isUndefOrNull(criteria.dt_target_to) || criteria.dt_target_to == "") {
                    var unique = $("#condition-date_to");
                    App.ui.page.notifyAlert.message(App.str.format(MS0042, pageLangText.dt_target_to.text), unique).show();
                    return false;
                }

                // 開始日 <= 終了日 であること
                if (criteria.dt_target > criteria.dt_target_to) {
                    App.ui.page.notifyAlert.message(
                        App.str.format(MS0019, pageLangText.dt_target_to.text, pageLangText.dt_target.text)
                    ).show();
                    return false;
                }

                // 開始日～終了日が最大期間日数以内であること
                var startDay = criteria.dt_target;
                var maxKikan = parseInt(pageLangText.maxPeriod.text);
                startDay.setDate(startDay.getDate() + maxKikan);
                if (startDay < criteria.dt_target_to) {
                    App.ui.page.notifyAlert.message(App.str.format(MS0716, maxKikan)).show();
                    return false;
                }

                return true;
            };
            /// 指定した日付範囲を一定期間で分割したオブジェクトを作成します
            /// @param ob 日付オブジェクト
            /// @param fr 開始日
            /// @param to 終了日
            /// @param sp 区切り範囲
            /// return 区切り範囲で区切った日付オブジェクト
            var getDateSplitObject = function (ob, fr, to, sp) {
                var start = new Date(fr), //deepcopy
                    end = new Date(to), //deepcopy
                    stloop, edloop;
                // 比較して範囲内であれば、オブジェクトに格納
                // 目的：指定された期間ごとに、From-Toのオブジェクトセットを作る
                for (var d = fr; d <= to; d.setDate(d.getDate() + sp)) {
                    stloop = d;
                    start = new Date(d); //deepcopy
                    edloop = start.setDate(start.getDate() + sp - 1);
                    if (end < edloop) {
                        edloop = end;
                    }
                    ob.push({ from: new Date(stloop), to: new Date(edloop) });
                }
            };
            /// <summary>計算在庫更新ボタンクリック時のイベント処理を行います。</summary>
            var keisanZaikoUpdate = function () {
                var criteria = $(".search-criteria").toJSON();

                // 必要な情報をURLに設定
                var urlParam = {
                    url: "../api/KeisanZaikoSakusei"
                    , dtFrom: "{0}"
                    , dtTo: "{1}"
                    , hinCd: ""
                    , user: App.ui.page.user.Code
                    , today: App.data.getDateTimeStringForQueryNoUtc(getSystemDate())
                    , lang: App.ui.page.lang
                    , con_kbn_hin: criteria.hinKubun
                    , con_bunrui: criteria.hinBunrui
                    , con_kurabasho: criteria.kurabasho
                    , con_nm_hinmei: encodeURIComponent(criteria.hinmei)
                };

                // 選択した日付を分割
                var dateObj = [],
                    splitDays = pageLangText.splitDays.number,
                    url;

                // 日付object取得
                getDateSplitObject(dateObj, criteria.dt_target, criteria.dt_target_to, splitDays);
                // ローディング開始
                App.ui.loading.show(pageLangText.nowProgressing.text);

                setTimeout(function () { // gifを表示する
                    $.each(dateObj, function (index, item) {
                        var isSuccess = true,
                        url = App.str.format(App.data.toWebAPIFormat(urlParam)
                            , App.data.getDateTimeStringForQueryNoUtc(item.from)
                            , App.data.getDateTimeStringForQueryNoUtc(item.to));
                        // 計算在庫更新処理を実行
                        App.ajax.webpostSync(
                            url
                        ).done(function (result) {
                            // 作成完了メッセージの表示
                            if (index == dateObj.length - 1) {
                                showCompleteDialog();
                            }
                        }).fail(function (result) {
                            App.ui.page.notifyAlert.message(result.message).show();
                            App.ui.loading.close();
                            isSuccess = false;
                        }).always(function () {
                            // ローディング終了
                            if (index == dateObj.length - 1) {
                                App.ui.loading.close();
                            }
                        });
                        return isSuccess;
                    });
                }, 1000);
            };
            $(".update-button").on("click", function () {
                App.ui.page.notifyInfo.clear();
                App.ui.page.notifyAlert.clear();
                var criteria = $(".search-criteria").toJSON();
                // チェック処理
                if (!checkKeisanZaikoUpdate(criteria)) {
                    return;
                }
                else {
                    //// 確認ダイアログを開く
                    if (
                        (App.isUndefOrNull(criteria.hinKubun) || criteria.hinKubun == "")
                        && (App.isUndefOrNull(criteria.hinBunrui) || criteria.hinBunrui == "")
                        && (App.isUndefOrNull(criteria.kurabasho) || criteria.kurabasho == "")
                        && (App.isUndefOrNull(criteria.hinmei) || criteria.hinmei == "")
                    ) {
                        // 検索条件の品区分、品分類、庫場所、品名がすべて指定されていなかった場合
                        // 時間がかかる場合がある旨の確認ダイアログ
                        showAllGenshizaiConfirmDialog();
                    }
                    else {
                        // 通常の確認ダイアログ
                        showStartConfirmDialog();
                    }
                }
            });

            /// <summary>計算在庫を作成確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".start-confirm-dialog .dlg-yes-button").on("click", function () {
                closeStartConfirmDialog();
                keisanZaikoUpdate();
            });
            // <summary>計算在庫を作成確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".start-confirm-dialog .dlg-no-button").on("click", closeStartConfirmDialog);

            /// <summary>全原資材選択時の確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".allGenshizai-confirm-dialog .dlg-yes-button").on("click", function () {
                closeAllGenshizaiConfirmDialog();
                keisanZaikoUpdate();
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
                    // 何もしない
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
                        <input type="text" name="dt_target" id="condition-date" style="width: 100px" />
                    </label>
                    <label><span data-app-text="between"></span></label>
                    <label>
                        <input type="text" name="dt_target_to" id="condition-date_to" style="width: 100px" />
                    </label>
                <br/>
                <br/>
                    <label>
                        <input type="radio" name="select_keikoku" id="keikoku_list" value="0" checked="checked" /><span class="item-label" style="width: 130px" data-app-text="keikoku_min" data-tooltip-text="keikoku_min"></span>
                    </label>
                    <label>
                        <input type="radio" name="select_keikoku" id="zenZaiko_tojitsuShiyo" value="1" /><span class="item-label" id="span_zenZaiko_tojitsuShiyo" style="width: 160px" data-app-text="zenZaiko_tojitsuShiyo" data-tooltip-text="zenZaiko_tojitsuShiyo"></span>
                    </label>
                <br/>
                    <label>
                        <input type="checkbox" name="keikoku_max" id="condition-keikoku_max" /><span class="item-label" id="keikoku_max" style="width: 120px" data-app-text="keikoku_max" data-tooltip-text="keikoku_max"></span>
                    </label>
                    <label>
                        <input type="checkbox" name="allGenshizai" id="con_allGenshizai" /><span class="item-label" id="allGenshizai" style="width: 120px" data-app-text="allGenshizai" data-tooltip-text="allGenshizai"></span>
                    </label>
                <br/>
                    <label>
                        <input type="checkbox" name="leadtime_kami" id="con_leadtime_kami" /><span class="item-label" id="leadtime_kami" style="width: 230px" data-app-text="considersLeadtime" data-tooltip-text="considersLeadtime"></span>
                    </label>
                </li>
            </ul>
            <ul class="item-list item-list-center">
                <li>
                    <label>
                        <span class="item-label item-label-right" style="width: 90px" data-app-text="kbn_hin" data-tooltip-text="kbn_hin"></span>
                        <select name="hinKubun" id="condition-hinKubun">
                        </select>
                    </label>
                <br/>
                    <label>
                        <span class="item-label item-label-right" style="width: 90px" data-app-text="hin_bunrui" data-tooltip-text="hin_bunrui"></span>
                        <select name="hinBunrui" id="condition-hinBunrui">
                        </select>
                    </label>
                <br/>
                    <label>
                        <span class="item-label item-label-right" style="width: 90px" data-app-text="kurabasho" data-tooltip-text="kurabasho"></span>
                        <select name="kurabasho" id="condition-kurabasho">
                        </select>
                    </label>
                <br/>
                    <label>
                        <span class="item-label item-label-right" style="width: 90px" data-app-text="hinmei" data-tooltip-text="hinmei"></span>
                        <input type="text" style="width: 262px" name="hinmei" maxlength="50" />
                    </label>
                </li>
                <!-- TODO: ここまで -->
            </ul>
            <ul class="item-list item-list-right">
                <li>
                    <div class="command" style="right: 9px;">
                        <button type="button" class="update-button" name="update-button" data-app-operation="keisanzaikoUpdate">
                            <span data-app-text="zaiko_update"></span>
                        </button>
                    </div>
                </li>
                <!-- レイアウト調整用の改行：liの中に入れると崩れるのでココで改行する -->
                <br/>
                <br/>
                <br/>
                <br/>
                <br/>
                <br/>
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
        <button type="button" class="excel-button" name="excel-button" data-app-operation="excel">
            <!--<span class="icon"></span>-->
            <span data-app-text="excel"></span>
        </button>
        <button type="button" class="hendohyo-button" name="hendohyo-button" data-app-operation="hendohyo">
            <span data-app-text="hendohyo"></span>
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
    <!-- TODO: ここまで  -->

    <!-- 画面デザイン -- End -->
</asp:Content>
