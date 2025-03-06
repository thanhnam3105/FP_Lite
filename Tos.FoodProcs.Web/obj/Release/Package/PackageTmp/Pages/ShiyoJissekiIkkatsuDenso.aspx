<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="ShiyoJissekiIkkatsuDenso.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.ShiyoJissekiIkkatsuDenso" %>
<asp:Content ID="Content1" ContentPlaceHolderID="IncludeContent" runat="server">
    <script src="<%=ResolveUrl("~/Resources/pages/pagedata-shiyojissekiikkatsudenso." + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
    <script src="<%=ResolveUrl("~/Resources/grid/grid.locale-" + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
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

        /*
        #result-grid
        {
            padding: 0px;
            overflow: hidden;
        }
        */
        
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

            //// 変数宣言 -- End

            //// コントロール定義 -- Start

            // 日付の多言語対応
            var datePickerFormat = pageLangText.dateFormatUS.text;
            if (App.ui.page.langCountry !== 'en-US') {
                datePickerFormat = pageLangText.dateFormat.text;
            }
            // datepickerの設定
            $("#id_dt_from, #id_dt_to").on("keyup", App.data.addSlashForDateString);
            $("#id_dt_from, #id_dt_to").datepicker({
                dateFormat: datePickerFormat,
                minDate: new Date(1975, 1 - 1, 1)
                //maxDate: "+10y"
            });
            $("#id_dt_from, #id_dt_to").datepicker("setDate", new Date());

            //// コントロール定義 -- End

            //// 操作制御定義 -- Start

            // 操作制御定義を定義します。
            App.ui.pagedata.operation.applySetting(App.ui.page.user.Roles[0], App.ui.page.lang);
            //// 操作制御定義 -- End

            //// 事前データロード -- Start
            //// 事前データロード -- End

            //// 検索処理 -- Start
            //// 検索処理 -- End

            //// メッセージ表示 -- Start

            // グリッドコントロール固有のメッセージ表示

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

            //// メッセージ表示 -- End

            //// データ変更処理 -- Start
            //// データ変更処理 -- End

            //// 保存処理 -- Start

            /// <summary>対象データ存在チェック</summary>
            /// <param name="dtFrom">伝送開始日</param>
            /// <param name="dtTo">伝送終了日</param>
            var checkTargetDate = function (dtFrom, dtTo) {
                var isValid = true,
                    _query1 = {
                        url: "../Services/FoodProcsService.svc/tr_sap_shiyo_yojitsu_anbun",
                        filter: "dt_shiyo_shikakari ge DateTime'" + App.data.getDateTimeStringForQueryNoUtc(dtFrom)
                            + "' and dt_shiyo_shikakari le DateTime'" + App.data.getDateTimeStringForQueryNoUtc(dtTo) + "'",
                        top: 1
                    };

                App.ajax.webgetSync(
                    App.data.toODataFormat(_query1)
                ).done(function (result) {
                    // 使用予実按分トランの指定期間内にデータない場合は処理中止
                    if (result.d.length == 0) {
                        isValid = false;
                    }
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                    isValid = false;
                });
                return isValid;
            };

            /// <summary>伝送中データ存在チェック</summary>
            var checkDensoJotaiKubun = function () {
                var isValid = true,
                    _query2 = {
                        url: "../Services/FoodProcsService.svc/tr_sap_shiyo_yojitsu_anbun",
                        filter: "kbn_jotai_denso eq " + pageLangText.densoJotaiKbnDensochu.text,
                        top: 1
                    };

                App.ajax.webgetSync(
                    App.data.toODataFormat(_query2)
                ).done(function (result) {
                    // 伝送中のデータがあればSAP連携中なので、処理を中止する
                    if (result.d.length > 0) {
                        isValid = false;
                    }
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                    isValid = false;
                });
                return isValid;
            };

            /// <summary>使用予実按分トラン更新処理</summary>
            /// <param name="dtFrom">伝送開始日</param>
            /// <param name="dtTo">伝送終了日</param>
            var updateAnbunData = function (dtFrom, dtTo) {

                var url = "../api/ShiyoJissekiIkkatsuDenso";
                // 必要な情報をURLに設定
                url = url + "?startDate=" + App.data.getDateTimeStringForQueryNoUtc(dtFrom)
                    + "&endDate=" + App.data.getDateTimeStringForQueryNoUtc(dtTo)
                    + "&lang=" + App.ui.page.lang
                    + "&user=" + App.ui.page.user.Code;

                App.ajax.webpost(
                    url
                ).done(function (result) {
                    // 処理完了メッセージの表示
                    App.ui.page.notifyInfo.message(MS0342).show();
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                }).always(function () {
                    // ローディング終了
                    App.ui.loading.close();
                });
            };

            /// <summary>保存時チェック処理</summary>
            var checkSave = function () {
                ///// チェック処理
                // バリデーション
                var result = $(".part-body .item-list").validation().validate();
                if (result.errors.length) {
                    App.ui.loading.close();
                    return;
                }

                // 伝送開始日 <= 伝送終了日であること
                var dt_from = App.date.localDate($("#id_dt_from").val()),
                    dt_to = App.date.localDate($("#id_dt_to").val());
                if (dt_from > dt_to) {
                    App.ui.page.notifyAlert.message(
                        App.str.format(pageLangText.dateCheck.text, pageLangText.dt_to.text, pageLangText.dt_from.text)
                    ).show();
                    App.ui.loading.close();
                    return;
                }

                // 対象データ存在チェック
                if (!checkTargetDate(dt_from, dt_to)) {
                    App.ui.page.notifyAlert.message(pageLangText.noTargetData.text).show();
                    App.ui.loading.close();
                    return;
                }

                // 伝送中データ存在チェック
                if (!checkDensoJotaiKubun()) {
                    App.ui.page.notifyAlert.message(pageLangText.existsDensoChu.text).show();
                    App.ui.loading.close();
                    return;
                }

                ///// 更新処理へ
                updateAnbunData(dt_from, dt_to);
            };

            /// <summary>保存ボタンクリック時のイベント処理を行います。</summary>
            $(".save-button").on("click", function (e) {
	            // メッセージのクリア
	            App.ui.page.notifyInfo.clear();
	            App.ui.page.notifyAlert.clear();

                // ローディング開始
                App.ui.loading.show(pageLangText.nowProgressing.text);

                // チェック処理が始まるとローディング画像が表示されない為、setTimeoutで間を入れる
                setTimeout(function () {
                    checkSave();    // 保存処理の実行
                }, 100);
            });

            //// 保存処理 -- End

            //// バリデーション -- Start

            // グリッドコントロール固有のバリデーション
            // グリッドのバリデーション設定
            //var v = Aw.validation({
            //    items: validationSetting
            //});

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

            /// <summary>コンテンツのリサイズを行います。</summary>
            var resizeContents = function (e) {
                var container = $(".content-container"),
                    searchPart = $(".search-criteria");
            };
            /// <summary>画面リサイズ時のイベント処理を行います。</summary>
            $(App.ui.page).on("resized", resizeContents);

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

    <!-- 出力条件 -->
    <div class="content-part search-criteria">
        <h3 class="part-header" data-app-text="selectCriteria"></h3>
        <div class="part-body">
            <ul class="item-list item-command">
                <li>
                    <!-- スペース -->
                    <label>
                        <span class="item-label">&nbsp;</span>
                    </label>
                </li>
                <li>
                    <!-- 伝送開始日 -->
                    <label>
                        <span class="item-label" style="width: 120px" data-app-text="dt_from"></span>
                        <input type="text" name="dt_from" id="id_dt_from" style="width: 120px" />
                        <span style="width: 30px">&nbsp;</span>
                    </label>
                    <label>
                        <span data-app-text="between"></span>
                    </label>
                    <!-- 伝送終了日 -->
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
            </ul>
        </div>
    </div>

    <!-- 画面デザイン -- End -->
</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="FooterContent" runat="server">
    <!-- 画面デザイン -- Start -->

    <!-- 画面アーキテクチャ共通のデザイン -- Start -->
    <div class="command" style="left: 1px;">
        <button type="button" class="save-button" name="save-button" data-app-operation="save">
            <span class="icon"></span><span data-app-text="save"></span>
        </button>
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

    <!-- 画面デザイン -- End -->
</asp:Content>
