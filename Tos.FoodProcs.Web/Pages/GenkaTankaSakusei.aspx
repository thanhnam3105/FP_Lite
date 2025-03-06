<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="GenkaTankaSakusei.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.GenkaTankaSakusei" %>
<asp:Content ID="Content1" ContentPlaceHolderID="IncludeContent" runat="server">
    <script src="<%=ResolveUrl("~/Resources/pages/pagedata-genkatankasakusei." + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
    <script src="<%=ResolveUrl("~/Resources/grid/grid.locale-" + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        /* 画面デザイン -- Start */
        
        /*
            2014/5/28 ADMAX中村　このモックアップは計算在庫作成画面(KeisanZaikoSakusei.aspx)をコピーして作成しています。
            変更箇所は[ADMAX中村]から辿れます。
        */
        
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
                
        /* >>> 2014/5/28 ADMAX中村 ここから：原価計算用にCSS追加 */
        .ui-datepicker-calendar {
            display:none;
        }
        /* <<< ここまで */
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
            // 原価単価作成時の引数
            var dt_from,
                dt_to;

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
            var startConfirmDialog = $(".start-confirm-dialog");
            var deleteConfirmDialog = $(".delete-confirm-dialog");
            // TODO：ここまで

            //// 変数宣言 -- End

            //// コントロール定義 -- Start

            // ダイアログ固有のコントロール定義
            startConfirmDialog.dlg();
            deleteConfirmDialog.dlg();

            /// 品名マスタセレクタを起動する
            var showHinmeiDialog = function () {
                var dlgParam = getHinKubunParam();
                option = { id: 'hinmei', multiselect: false, param1: dlgParam };
                hinmeiDialog.draggable(true);
                //hinmeiDialog.draggable({ containment: document.body, scroll: false });    // IE以外では挙動がおかしい？保留中
                hinmeiDialog.dlg("open", option);
            };

            /// <summary>ダイアログを開きます。</summary>
            // 原価単価作成確認時のダイアログ
            var showStartConfirmDialog = function () {
                startConfirmDialogNotifyInfo.clear();
                startConfirmDialogNotifyAlert.clear();
                startConfirmDialog.draggable(true);
                //startConfirmDialog.draggable({ containment: document.body, scroll: false });    // IE以外では挙動がおかしい？保留中
                startConfirmDialog.dlg("open");
            };
            // 原価単価の破棄確認時のダイアログ
            var showDeleteConfirmDialog = function () {
                deleteConfirmDialogNotifyInfo.clear();
                deleteConfirmDialogNotifyAlert.clear();
                deleteConfirmDialog.draggable(true);
                //deleteConfirmDialog.draggable({ containment: document.body, scroll: false });   // IE以外では挙動がおかしい？保留中
                deleteConfirmDialog.dlg("open");
            };

            /// <summary>ダイアログを閉じます。</summary>
            var closeStartConfirmDialog = function () {
                startConfirmDialog.dlg("close");
            };
            var closeDeleteConfirmDialog = function () {
                deleteConfirmDialog.dlg("close");
            };

            // 多言語対応
            var datePickerFormat = pageLangText.dateFormatUS.text;
            if (App.ui.page.langCountry != 'en-US') {
                datePickerFormat = pageLangText.dateFormat.text;
            }

            // TODO：画面の仕様に応じて以下の datepicker の設定を変更してください。
            // >>> 2014/5/28 ADMAX中村 ここから：年月のみのdatepickerの設定
            $("#id_dt_keisan").datepicker({
                changeMonth: true,
                changeYear: true,
                showButtonPanel: true,
                dateFormat: pageLangText.yearMonthFormat.text,
                minDate: new Date(1975, 1 - 1, 1),  // 有効範囲：1975/1～2999/12
                maxDate: new Date(2999, 12 - 1, 1),
                onClose: function (dateText, inst) {
                    //criteriaChange();
                    if (inst.lastVal != dateText) {
                        if (/^[0-9]{4}\/[0-9]{2}$/.test(dateText)) {
                            var month = dateText.split("/")[1] - 1;
                            var year = dateText.split("/")[0];
                            $(this).datepicker('option', 'defaultDate', new Date(year, month, 1));
                            $(this).datepicker('setDate', new Date(year, month, 1));
                        }
                    }
                    else {
                        var month = $("#ui-datepicker-div .ui-datepicker-month :selected").val();
                        var year = $("#ui-datepicker-div .ui-datepicker-year :selected").val();
                        $(this).datepicker('option', 'defaultDate', new Date(year, month, 1));
                        $(this).datepicker('setDate', new Date(year, month, 1));
                    }
                    // var res = $(".part-body .item-list").validation().validate();
                }
            });
            // 初期値：システム日付を設定
            $("#id_dt_keisan").datepicker("setDate", new Date());
            // <<< ここまで
            // TODO：ここまで

            // >>> 2014/5/28 ADMAX中村 ここから：検索条件．年月（必須項目）への*印追加処理
            // 必須項目
            $("#id_dt_keisan").prev().text(pageLangText.dt_keisan.text + pageLangText.requiredMark.text);
            // <<< ここまで

            //// コントロール定義 -- End

            //// 操作制御定義 -- Start

            // 操作制御定義を定義します。
            App.ui.pagedata.operation.applySetting(App.ui.page.user.Roles[0], App.ui.page.lang);

            //// 操作制御定義 -- End

            //// 事前データロード -- Start
            App.deferred.parallel({
                // ローディング
                loading: App.ui.loading.show(pageLangText.nowProgressing.text),
                // 品区分
                hinKubun: App.ajax.webget("../Services/FoodProcsService.svc/ma_kbn_hin?$filter=kbn_hin eq "
                    + pageLangText.seihinHinKbn.text + " or kbn_hin eq " + pageLangText.genryoHinKbn.text + " or kbn_hin eq "
                    + pageLangText.shizaiHinKbn.text + " or kbn_hin eq " + pageLangText.jikaGenryoHinKbn.text + "&$orderby=kbn_hin")
            }).done(function (result) {
                hinKubun = result.successes.hinKubun.d;
                // 検索用ドロップダウンの設定
                App.ui.appendOptions($("#id_kbn_hin"), "kbn_hin", "nm_kbn_hin", hinKubun, true);
            }).fail(function (result) {
                var length = result.key.fails.length,
                        messages = [];
                for (var i = 0; i < length; i++) {
                    var keyName = result.key.fails[i];
                    var value = result.fails[keyName];
                    messages.push(keyName + " " + value.message);
                }

                App.ui.loading.close();
                App.ui.page.notifyAlert.message(messages).show();
            }).always(function () {
                App.ui.loading.close();
            });

            /// <summary>時間を省いたシステム日付を日付オブジェクトで取得する</summary>
            var getSystemDate = function () {
                var sysdate = new Date(new Date().getFullYear(), new Date().getMonth(), new Date().getDate());
                return sysdate;
            };

            /// <summary>品名ダイアログの品区分パラメーターを取得する</summary>
            var getHinKubunParam = function () {
                var criteria = $(".search-criteria").toJSON(),
                    hinKbnParam = pageLangText.maHinmeiHinDlgParam.text;
                switch (criteria.kbn_hin) {
                    case pageLangText.seihinHinKbn.text:
                        hinKbnParam = pageLangText.seihinHinDlgParam.text;
                        break;
                    case pageLangText.genryoHinKbn.text:
                        hinKbnParam = pageLangText.genryoHinDlgParam.text;
                        break;
                    case pageLangText.shizaiHinKbn.text:
                        hinKbnParam = pageLangText.shizaiHinDlgParam.text;
                        break;
                    case pageLangText.jikaGenryoHinKbn.text:
                        hinKbnParam = pageLangText.jikaGenryoHinDlgParam.text;
                        break;
                }
                return hinKbnParam;
            };

            //// 事前データロード -- End

            //// 検索処理 -- Start
            //// 検索処理 -- End

            //// 作成条件の各処理 -- Start

            /// <summary>クエリオブジェクトの設定</summary>
            var queryGenkaTanka = function () {
                var query = {
                    url: "../Services/FoodProcsService.svc/vw_tr_genka_tanka_01",
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
                dt_from = new Date(criteria.dt_keisan.getFullYear(), criteria.dt_keisan.getMonth(), 1);
                dt_to = new Date(criteria.dt_keisan.getFullYear(), criteria.dt_keisan.getMonth() + 1, 0);

                filters.push("dt_genka_keisan ge DateTime'" + App.data.getDateTimeStringForQueryNoUtc(dt_from) + "'");
                filters.push("dt_genka_keisan le DateTime'" + App.data.getDateTimeStringForQueryNoUtc(dt_to) + "'");
                if (!App.isUndefOrNull(criteria.kbn_hin)) {
                    filters.push("kbn_hin eq " + criteria.kbn_hin);
                }
                if (!App.isUndefOrNull(criteria.nm_bunrui)) {
                    filters.push("cd_bunrui eq '" + criteria.nm_bunrui + "'");
                }
                if (!App.isUndefOrNull(criteria.cd_hinmei)) {
                    filters.push("cd_hinmei eq '" + criteria.cd_hinmei + "'");
                }

                return filters.join(" and ");
            };
            /// <summary>原価単価トランの情報を取得する</summary>
            var getGenkaTankaData = function () {
                var keikakuQuery = queryGenkaTanka();
                var resultBool = false;

                // ローディングの表示
                App.ui.loading.show(pageLangText.nowProgressing.text)
                App.ajax.webgetSync(
                    App.data.toODataFormat(keikakuQuery)
                ).done(function (result) {
                    // 取得処理成功時

                    // ローディング終了
                    App.ui.loading.close();

                    // データが存在した場合
                    if (result.d.__count > 0) {
                        resultBool = true;
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

                return resultBool;
            };

            /// <summary>原価単価作成処理</summary>
            /// <param name="query">クエリオブジェクト</param>
            var createGenkaTanka = function () {
                // ローディング開始
                App.ui.loading.show(pageLangText.nowProgressing.text);

                var criteria = $(".search-criteria").toJSON();
                var query = {
                    url: "../api/GenkaTankaSakusei",
                    dt_from: App.data.getDateTimeStringForQueryNoUtc(dt_from),
                    dt_to: App.data.getDateTimeStringForQueryNoUtc(dt_to),
                    kbn_hin: criteria.kbn_hin,
                    cd_bunrui: criteria.nm_bunrui,
                    cd_hinmei: criteria.cd_hinmei,
                    max_genka: pageLangText.maxGenkaTanka.text,
                    today: App.data.getDateTimeStringForQueryNoUtc(getSystemDate())
                };

                App.ajax.webpost(
                    App.data.toWebAPIFormat(query)
                ).done(function (result) {
                    // 作成完了メッセージの表示
                    App.ui.page.notifyInfo.message(pageLangText.creatCompletion.text).show();
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                    App.ui.loading.close();
                }).always(function () {
                    // ローディング終了
                    App.ui.loading.close();
                });
            };

            /// <summary>原価単価作成ボタンクリック時のイベント処理を行います。</summary>
            var calculationStart = function () {
                // メッセージとエラー枠のクリア
                App.ui.page.notifyInfo.clear();
                App.ui.page.notifyAlert.clear();

                // チェック処理
                if (!checkCondition()) {
                    return;
                }

                // 原価単価トランの情報を取得する
                if (getGenkaTankaData()) {
                    // 一件以上存在した場合の確認ダイアログ
                    showDeleteConfirmDialog();
                }
                else {
                    // 0件だった場合の確認ダイアログ
                    showStartConfirmDialog();
                }
            };
            /// <summary>原価単価作成ボタンクリック時のチェック処理を行います。</summary>
            var checkCondition = function () {
                var isValid = true;

                ///// バリデーション
                var result = $(".part-body .item-list").validation().validate();
                if (result.errors.length) {
                    return false;
                }

                return isValid;
            };
            /// <summary>原価単価作成ボタンクリック</summary>
            $(".sakusei-button").on("click", function () {
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

            // 原価単価作成確認時ダイアログ情報メッセージの設定
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
            // 原価単価トランの破棄確認時ダイアログ情報メッセージの設定
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

            //// メッセージ表示 -- End

            //// データ変更処理 -- Start
            //// データ変更処理 -- End

            /// <summary>品名一覧ボタンクリック時のイベント処理を行います。</summary>
            $("#id_hinmei_button").on("click", function (e) {
                showHinmeiDialog();
            });

            /// 検索条件/品名コードのイベント処理を行います。
            $("#id_cd_hinmei").dblclick(function () {
                // ダブルクリック時：品名ダイアログを開く
                showHinmeiDialog();
            });

            //// 保存処理 -- Start
            //// 保存処理 -- End

            //// バリデーション -- Start

            // グリッドコントロール固有のバリデーション

            /// <summary>品名を取得します。(マスタ存在チェック)</summary>
            /// <param name="cdHinmei">原資材コード</param>
            var isValidHinCode = function (cdHinmei) {
                // 品名コードが未入力の場合はチェックを行わない
                if (App.isUndefOrNull(cdHinmei)
                    || cdHinmei.length === 0) {
                    $("#id_nm_hinmei").text("");
                    return true;
                }

                var isValid = true,
                    query = {
                        url: "../Services/FoodProcsService.svc/ma_hinmei",
                        filter: "cd_hinmei eq '" + cdHinmei + "' and "
                                + "(kbn_hin eq " + pageLangText.seihinHinKbn.text
                                    + " or kbn_hin eq " + pageLangText.genryoHinKbn.text
                                    + " or kbn_hin eq " + pageLangText.shizaiHinKbn.text
                                    + " or kbn_hin eq " + pageLangText.jikaGenryoHinKbn.text
                                + ") and flg_mishiyo eq " + pageLangText.shiyoMishiyoFlg.text,
                        top: 1
                    };

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
            // 品名コードからフォーカスを外したタイミングで名称取得処理を行う
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

            /// <summary>品区分入力時のイベント処理を行います。</summary>
            var setHinBunrui = function () {
                // 品区分の値を元に、品分類コンボボックスの値を取得します。

                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();
                // 品分類の中身をクリア
                $("#id_bunrui option").remove();
                // 品名コード、品名をクリア
                $("#id_cd_hinmei").val("");
                $("#id_nm_hinmei").text("");

                var criteria = $(".search-criteria").toJSON();
                var hinKbnParam = criteria.kbn_hin;
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
                    var target = $("#id_bunrui");
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
            $("#id_kbn_hin").on("change", setHinBunrui);

            /// <summary>原価単価作成確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".start-confirm-dialog .dlg-yes-button").on("click", function () {
                closeStartConfirmDialog();
                createGenkaTanka();
            });
            // <summary>原価単価作成確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".start-confirm-dialog .dlg-no-button").on("click", closeStartConfirmDialog);

            /// <summary>原価単価破棄確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".delete-confirm-dialog .dlg-yes-button").on("click", function () {
                closeDeleteConfirmDialog();
                createGenkaTanka();
            });
            // <summary>原価単価破棄確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".delete-confirm-dialog .dlg-no-button").on("click", closeDeleteConfirmDialog);

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

    <!-- 出力条件 -->
    <div class="content-part search-criteria">
        <h3 class="part-header" data-app-text="selectCriteria"></h3>
        <div class="part-body">
            <ul class="item-list item-list-left">
                <li>
                    <!-- 年月 -->
                    <label>
                        <span class="item-label" data-app-text="dt_keisan"></span>
                        <input type="text" id="id_dt_keisan" name="dt_keisan" style=" width: 8em;" />
                    </label>
                </li>
                <li>
                    <!-- 品区分 -->
                    <label>
                        <span class="item-label" data-app-text="kbn_hin"></span>
                        <select id="id_kbn_hin" name="kbn_hin" style=" width: 26em;"></select>
                    </label>
                </li>
                <li>
                    <!-- 空白行 -->
                    <label>
                        <span class="item-label">&nbsp;</span>
                    </label>
                </li>
                <li>
                    <!-- 分類 -->
                    <label>
                        <span class="item-label" data-app-text="nm_bunrui"></span>
                        <select id="id_bunrui" name="nm_bunrui" style=" width: 26em;"></select>
                    </label>
                </li>
                <li>
                    <!-- 品名コード -->
                    <label>
                        <span class="item-label" data-app-text="cd_hinmei"></span>
                        <input type="text" id="id_cd_hinmei" name="cd_hinmei" style="width: 120px" maxlength="14" />
                    </label>
                    <!-- 品名一覧ボタン -->
                    <label class="item-command">
                        <button type="button" id="id_hinmei_button" class="dialog-button hinmei-button" name="hinmei-button" data-app-operation="hinmeiIchiran" >
                            <span class="icon"></span><span data-app-text="hinmeiIchiran"></span>
                        </button>
                    </label>
                </li>
                <li>
                    <!-- 品名 -->
                    <label>
                        <span class="item-label">&nbsp;</span>
                        <span class="item-label" id="id_nm_hinmei" name="nm_hinmei" style="width: 500px"></span>
                    </label>
                </li>
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
        <button type="button" class="sakusei-button" name="sakusei-button" data-app-operation="sakuseiStart" style="width: 140px;">
            <span class="icon"></span>
            <span data-app-text="sakusei_start"></span>
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
    <div class="hinmei-dialog">
    </div>
    <!-- TODO: ここまで  -->

    <!-- 画面デザイン -- End -->
</asp:Content>
