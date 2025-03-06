<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="GenshizaiNonyuKeikakuSakusei.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.GenshizaiNonyuKeikakuSakusei" %>
<asp:Content ID="Content1" ContentPlaceHolderID="IncludeContent" runat="server">
    <script src="<%=ResolveUrl("~/Resources/pages/pagedata-genshizainonyukeikakusakusei." + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
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

            // 英語化対応　言語によって幅を調節
            $(".search-criteria .item-label").css("width", pageLangText.each_lang_width.number);

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
            checkFlg = false;   // 計算開始ボタン押下時であるフラグ
            var dtFrom = $(".search-criteria [name='dt_from']");    // 計算初日
            var dtTo = $(".search-criteria [name='dt_to']");    // 計算末日
            var con_hinmei = "";    // 引数条件の用品名コード

            // trueの場合は1、それ以外は0を返却
            var changeFlag = function (flg) {
                if (!App.isUndefOrNull(flg)) {
                    if (flg) {
                        return pageLangText.trueFlg.text;
                    }
                }
                return pageLangText.falseFlg.text;
            };

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
                option = { id: 'hinmei', multiselect: false, param1: pageLangText.genshizaiHinDlgParam.text };
                hinmeiDialog.draggable(true);
                hinmeiDialog.dlg("open", option);
            };

            /// <summary>ダイアログを開きます。</summary>
            // 納入計画作成確認時のダイアログ
            var showStartConfirmDialog = function () {
                startConfirmDialogNotifyInfo.clear();
                startConfirmDialogNotifyAlert.clear();
                startConfirmDialog.draggable(true);
                startConfirmDialog.dlg("open");
            };
            // 納入計画の破棄確認時のダイアログ
            var showDeleteConfirmDialog = function () {
                deleteConfirmDialogNotifyInfo.clear();
                deleteConfirmDialogNotifyAlert.clear();
                deleteConfirmDialog.draggable(true);
                deleteConfirmDialog.dlg("open");
            };
            // 全原資材選択時の確認ダイアログ
            var showAllGenshizaiConfirmDialog = function () {
                allGenshizaiConfirmDialogNotifyInfo.clear();
                allGenshizaiConfirmDialogNotifyAlert.clear();
                allGenshizaiConfirmDialog.draggable(true);
                allGenshizaiConfirmDialog.dlg("open");
            };
            // 計画作成完了ダイアログ
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

            // 日付の多言語対応
            var datePickerFormat = pageLangText.dateFormatUS.text;
            if (App.ui.page.langCountry !== 'en-US') {
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

            /// <summary>システム日付の翌日を取得する</summary>
            var getSystemDateNextDay = function () {
                var sysdate = new Date(new Date().getFullYear(), new Date().getMonth(), new Date().getDate() + 1);
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

            /// <summary>変動計算初日を取得し、設定する</summary>
            /// <param name="queryUrl">検索用クエリ</param>
            /// <param name="initFlg">初期値を設定する場合はtrue</param>
            var setNonyuKeikakuDate = function (queryUrl, initFlg) {
                App.deferred.parallel({
                    // ローディング開始
                    loading: App.ui.loading.show(pageLangText.nowProgressing.text),
                    // 原資材計画管理情報
                    genshizaiKeikaku: App.ajax.webget(queryUrl)
                }).done(function (result) {
                    // サービス呼び出し成功時の処理
                    genshizaiKeikaku = result.successes.genshizaiKeikaku.d;
                    var dt_keikaku = getSystemDateNextDay();
                    var dt_matsujitsu = getSystemDateNextDay();
                    var data = genshizaiKeikaku[0];

                    if (!initFlg) {
                        if (!App.isUndefOrNull(data) && data != "") {
                            // 日付が取得できた、かつ取得した日付がシステム日付の翌日以降である場合
                            if (App.data.getDate(data.dt_keikaku_nonyu) > dt_keikaku) {
                                // 取得した日付を設定する
                                dt_keikaku = App.data.getDate(data.dt_keikaku_nonyu);
                                dt_matsujitsu = App.data.getDate(data.dt_keikaku_nonyu);
                            }
                        }
                    }
                    dtFrom.datepicker("setDate", dt_keikaku);
                    // 変動計算末日：初日＋作成できる最大期間日数を挿入
                    var maxKikan = parseInt(pageLangText.maxPeriod.text);
                    dt_matsujitsu.setDate(dt_matsujitsu.getDate() + maxKikan);
                    dtTo.datepicker("setDate", dt_matsujitsu);

                }).fail(function (result) {
                    // エラー発生時の処理
                    var length = result.key.fails.length,
                        messages = [];
                    for (var i = 0; i < length; i++) {
                        var keyName = result.key.fails[i];
                        var value = result.fails[keyName];
                        messages.push(keyName + " " + value.message);
                    }
                    App.ui.page.notifyAlert.message(messages).show();
                }).always(function () {
                    // 処理終了：ローディング表示の終了
                    App.ui.loading.close();
                });
            };

            // 画面アーキテクチャ共通の事前データロード
            var loading;
            App.deferred.parallel({
                // ローディング
                loading: App.ui.loading.show(pageLangText.nowProgressing.text)
            }).done(function (result) {
                // サービス呼び出し成功

                // 変動計算初日に有効範囲の設定：システム日付の翌日～(上限なし)
                dtFrom.datepicker("option", 'minDate', getSystemDateNextDay());
                dtTo.datepicker("option", 'minDate', getSystemDateNextDay());
                // 変動計算日の初期値設定
                setNonyuKeikakuDate(getQueryUrl(), true);

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
            //// 検索処理 -- End

            //// 作成条件の各処理 -- Start

            /// <summary>クエリオブジェクトの設定</summary>
            var queryNonyuKeikaku = function () {
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
                filters.push("dt_keikaku_nonyu ge DateTime'" + App.data.getDateTimeStringForQueryNoUtc(criteria.dt_from) + "'");
                filters.push("dt_keikaku_nonyu le DateTime'" + App.data.getDateTimeStringForQueryNoUtc(criteria.dt_to) + "'");
                if (!App.isUndefOrNull(con_hinmei)) {
                    filters.push("cd_hinmei eq '" + con_hinmei + "'");
                }

                return filters.join(" and ");
            };
            /// <summary>納入計画作成済みの情報を取得する</summary>
            var getNonyuKeikaku = function () {
                var keikakuQuery = queryNonyuKeikaku();
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
            /// <summary>納入計画作成用の計算在庫作成処理</summary>
            var calcKeisanZaiko = function () {
                // ローディング開始
                App.ui.loading.show(pageLangText.nowProgressing.text);

                var criteria = $(".search-criteria").toJSON(),
                    sysdate = getSystemDateNextDay();
                sysdate.setDate(sysdate.getDate() - 1); // 当日を取得するため、１日引く

                // 必要な情報をURLに設定
                var urlParam = {
                    url: "../api/GenshizaiNonyuKeikakuSakusei"
                    , dtFrom: "{0}"
                    , dtTo: "{1}"
                    , hinCd: (con_hinmei == "") ? "null" : con_hinmei
                    , user: App.ui.page.user.Code
                    , today: App.data.getDateTimeStringForQueryNoUtc(sysdate)
                    , dtHendoFrom: App.data.getDateTimeStringForQueryNoUtc(criteria.dt_from)
                    , dtHendoTo: App.data.getDateTimeStringForQueryNoUtc(criteria.dt_to)
                };

                // 選択した日付を分割
                var dateObj = [],
                    splitDays = pageLangText.splitDays.number,
                    url;

                // 日付object取得
                getDateSplitObject(dateObj, criteria.dt_from, criteria.dt_to, splitDays);

                setTimeout(function () { // 処理中のgifを表示する
                    $.each(dateObj, function (index, item) {
                        var isSuccess = true,
                        url = App.str.format(App.data.toWebAPIFormat(urlParam)
                            , App.data.getDateTimeStringForQueryNoUtc(item.from)
                            , App.data.getDateTimeStringForQueryNoUtc(item.to));
                        // 計算在庫更新処理を実行
                        App.ajax.webpostSync(
                            url
                        ).done(function (result) {
                            if (index == dateObj.length - 1) {
                                // 納入計画作成処理
                                createNonyuKeikaku();
                            }
                        }).fail(function (result) {
                            App.ui.page.notifyAlert.message(result.message).show();
                            App.ui.loading.close();
                            isSuccess = false;
                        });
                        return isSuccess;
                    });
                }, 1000);
            };

            /// <summary>納入計画作成処理</summary>
            var createNonyuKeikaku = function () {
                // ローディング開始
                //App.ui.loading.show(pageLangText.nowProgressing.text);

                var criteria = $(".search-criteria").toJSON(),
                    url = "../api/GenshizaiNonyuKeikakuSakusei",
                    sysdate = getSystemDateNextDay();
                sysdate.setDate(sysdate.getDate() - 1);
                // 必要な情報をURLに設定
                url = url + "?dtFrom=" + App.data.getDateTimeStringForQueryNoUtc(criteria.dt_from)
                    + "&dtTo=" + App.data.getDateTimeStringForQueryNoUtc(criteria.dt_to)
                    + "&hinCd=" + ((con_hinmei == "") ? "null" : con_hinmei)
                    + "&user=" + App.ui.page.user.Code
                    + "&leadtime=" + pageLangText.dtNonyuLeadtime.text
                    + "&sysdate=" + App.data.getDateTimeStringForQueryNoUtc(sysdate);

                App.ajax.webpost(
                    url
                ).done(function (result) {
                    // 作成完了メッセージの表示
                    //App.ui.page.notifyInfo.message(pageLangText.creatCompletion.text).show();
                    var msg = pageLangText.creatCompletion.text;   // デフォルトは通常の完了メッセージ
                    if (result != "") {
                        // resultに値がある場合はSKIP対象がある旨のメッセージを設定する
                        msg = MS0741;
                    }
                    $("#comp_dlg").text(msg);

                    showCompleteDialog();
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                }).always(function () {
                    // ローディング終了
                    App.ui.loading.close();
                });
            };

            /// <summary>変動計算開始ボタンクリック時のイベント処理を行います。</summary>
            var calculationStart = function () {
                // メッセージとエラー枠のクリア
                App.ui.page.notifyInfo.clear();
                App.ui.page.notifyAlert.clear();
                resetBorder("#id_dt_from");
                resetBorder("#id_dt_to");
                resetBorder("#id_cd_hinmei");

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
                    // 納入計画作成済情報取得処理
                    con_hinmei = $("#id_cd_hinmei").val();
                    getNonyuKeikaku();
                }
            };
            /// <summary>変動計算開始ボタンクリック時のチェック処理を行います。</summary>
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
                        setErrorBorder("#id_cd_hinmei");
                        App.ui.page.notifyAlert.message(pageLangText.hinmeiCheck.text, uniqueHin).show();
                        isValid = false;
                    }
                }

                // 初日は翌日以降であること
                if (firstDay <= App.date.startOfDay(new Date())) {
                    App.ui.page.notifyAlert.message(pageLangText.dateCheckFromDate.text, uniqueFrom).show();
                    setErrorBorder("#id_dt_from");
                    isValid = false;
                }

                // 初日は休日フラグが立っていないこと
                if (!isValidStartDate(firstDay, uniqueFrom)) {
                    setErrorBorder("#id_dt_from");
                    isValid = false;
                }

                // 変動計算初日＜変動計算末日であること
                if (firstDay > endOfMonth) {
                    setErrorBorder("#id_dt_from");
                    setErrorBorder("#id_dt_to");
                    App.ui.page.notifyAlert.message(
                        App.str.format(
                            pageLangText.dateCheck.text
                            , pageLangText.dt_to.text
                            , pageLangText.dt_from.text)
                        , uniqueFrom
                    ).show();
                    isValid = false;
                }

                // 初日～末日が最大期間日数以内であること
                var maxKikan = parseInt(pageLangText.maxPeriod.text);
                firstDay.setDate(firstDay.getDate() + maxKikan);
                if (firstDay < endOfMonth) {
                    App.ui.page.notifyAlert.message(pageLangText.dateCheckPeriod.text, uniqueFrom).show();
                    setErrorBorder("#id_dt_from");
                    setErrorBorder("#id_dt_to");
                    isValid = false;
                }

                return isValid;
            };
            /// <summary>変動計算初日の休日チェック</summary>
            /// <param name="startDate">変動計算初日</param>
            var isValidStartDate = function (startDate, uniqueFrom) {
                var isValid = true,
                    query = {
                        url: "../Services/FoodProcsService.svc/ma_calendar",
                        filter: "dt_hizuke eq DateTime'" + App.data.getDateTimeStringForQueryNoUtc(startDate) + "'",
                        top: 1
                    };
                // 変動計算初日が未入力の場合はチェックを行わない
                if (App.isUndefOrNull(startDate) || startDate.length === 0) {
                    return isValid;
                }

                // カレンダーマスタから値を取得
                App.ajax.webgetSync(
                    App.data.toODataFormat(query)
                ).done(function (result) {
                    if (result.d.length == 1) {
                        // 休日フラグが立っていた場合
                        if (result.d[0].flg_kyujitsu == pageLangText.kyujitsuKyujitsuFlg.value) {
                            App.ui.page.notifyAlert.message(pageLangText.kyujitsuCheck.text, uniqueFrom).show();
                            isValid = false;
                        }
                    }
                    else {
                        // 該当データが存在しませんでした。(MS0037)
                        App.ui.page.notifyAlert.message(MS0037).show();
                        isValid = false;
                    }
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                    isValid = false;
                });
                return isValid;
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

            /// <summary>変動計算開始ボタンクリック</summary>
            $(".keisan-button").on("click", function () {
                checkFlg = true;
                calculationStart();
                checkFlg = false;
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

            // 納入計画作成確認時ダイアログ情報メッセージの設定
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
            // 納入計画の破棄確認時ダイアログ情報メッセージの設定
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
            var allGenshizaiConfirmDialogNotifyInfo = App.ui.notify.info(deleteConfirmDialog, {
                container: ".allGenshizai-confirm-dialog .dialog-slideup-area .info-message",
                messageContainerQuery: "ul",
                show: function () {
                    allGenshizaiConfirmDialog.find(".info-message").show();
                },
                clear: function () {
                    allGenshizaiConfirmDialog.find(".info-message").hide();
                }
            });
            // 計画作成完了ダイアログ情報メッセージの設定
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
                                ") and flg_mishiyo eq " + pageLangText.shiyoMishiyoFlg.text,
                        top: 1
                    };
                // 品名コードが未入力の場合はチェックを行わない
                if (App.isUndefOrNull(cdHinmei)
                    || cdHinmei.length === 0) {
                    $("#id_nm_hinmei").text("");
                    // 計算開始ボタン押下時以外は変動計算日の再設定
                    if (!checkFlg) {
                        setNonyuKeikakuDate(getQueryUrl(), true);
                    }
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

                        // 計算開始ボタン押下時以外は品名と変動計算日の再設定を行う
                        if (!checkFlg) {
                            // 検索条件/品名に取得した原資材名を設定
                            $("#id_nm_hinmei").text(result.d[0][hinName]);
                            // 変動計算日の再設定
                            setNonyuKeikakuDate(getQueryUrl(result.d[0]["cd_hinmei"]), false);
                        }
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

            /// <summary>コンテンツのリサイズを行います。</summary>
            var resizeContents = function (e) {
                var container = $(".content-container"),
                    searchPart = $(".search-criteria");
            };
            /// <summary>画面リサイズ時のイベント処理を行います。</summary>
            $(App.ui.page).on("resized", resizeContents);

            /// <summary>納入計画を作成確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".start-confirm-dialog .dlg-yes-button").on("click", function () {
                closeStartConfirmDialog();
                //createNonyuKeikaku();
                // 先に計算在庫の再計算処理を行う
                calcKeisanZaiko();
            });
            // <summary>納入計画を作成確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".start-confirm-dialog .dlg-no-button").on("click", closeStartConfirmDialog);

            /// <summary>納入計画の破棄確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".delete-confirm-dialog .dlg-yes-button").on("click", function () {
                closeDeleteConfirmDialog();
                //createNonyuKeikaku();
                // 先に計算在庫の再計算処理を行う
                calcKeisanZaiko();
            });
            // <summary>納入計画の破棄確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".delete-confirm-dialog .dlg-no-button").on("click", closeDeleteConfirmDialog);

            /// <summary>全原資材選択時の確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".allGenshizai-confirm-dialog .dlg-yes-button").on("click", function () {
                closeAllGenshizaiConfirmDialog();
                getNonyuKeikaku();
            });
            // <summary>全原資材選択時の確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".allGenshizai-confirm-dialog .dlg-no-button").on("click", closeAllGenshizaiConfirmDialog);

            /// <summary>計画作成完了ダイアログの「閉じる」ボタンクリック時のイベント処理を行います。</summary>
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
                        <span style="width: 230px" data-app-text="label_all_genshizai"></span>
                    </label>
                </li>
                <li>
                    <!-- ラジオボタン：以下の品名コードの原資材 -->
                    <label>
                        <input type="radio" name="select_type" id="id_genshizai" value="2" />
                        <span style="width: 350px" data-app-text="label_genshizai"></span>
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
                        <button type="button" class="dialog-button genshizai-button" name="genshizai-button" data-app-operation="genshizaiIchiran" style="min-width:120px;">
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
                    <!-- 変動計算初日 -->
                    <label>
                        <span class="item-label" style="width: 120px" data-app-text="dt_from"></span>
                        <input type="text" name="dt_from" id="id_dt_from" style="width: 120px" />
                        <span style="width: 30px">&nbsp;</span>
                    </label>
                    <label>
                        <span data-app-text="between"></span>
                    </label>
                    <!-- 変動計算末日 -->
                    <label>
                        <span class="item-label" style="width: 120px" data-app-text="dt_to"></span>
                        <input type="text" name="dt_to" id="id_dt_to" style="width: 120px" />
                        <span style="width: 30px">&nbsp;</span>
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
        <button type="button" class="keisan-button" name="keisan-button" data-app-operation="keisanStart" style="min-width: 140px;">
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
                <span id="comp_dlg"></span>
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
