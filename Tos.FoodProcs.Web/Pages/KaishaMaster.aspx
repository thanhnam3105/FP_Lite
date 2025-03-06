<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="KaishaMaster.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.KaishaMaster" %>

<asp:Content ID="Content1" ContentPlaceHolderID="IncludeContent" runat="server">
    <script src="<%=ResolveUrl("~/Resources/pages/pagedata-kaishamaster." + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
    <script src="<%=ResolveUrl("~/Resources/grid/grid.locale-" + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        /* 画面デザイン -- Start */
        
        /* TODO：画面の仕様に応じて以下のスタイルを変更してください。 */
        #detail-content
        {
            padding: 0px;
        }

        .header-content {
            margin-left: 10px;
            margin-right: 10px;
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
                querySetting = { skip: 0, top: 40, count: 0 },
                isDataLoading = false,
                userRoles = App.ui.page.user.Roles[0]; // ログインユーザー権限


            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            changeSet = new App.ui.page.changeSet(),
            duplicateCol = 999,
            currentRow = 0;
            isChanged = false;
            // TODO: ここまで

            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            // ダイアログ固有の変数宣言 -- Start
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            var saveConfirmDialog = $(".save-confirm-dialog");
            // TODO：ここまで

            //// 変数宣言 -- End


            //// 事前データロード -- Start
            // 画面アーキテクチャ共通の事前データロード
            App.deferred.parallel({
            // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
            //
            // TODO: ここまで
        }).done(function (result) {
            // TODO: 画面の仕様に応じて以下のサービス呼び出し成功時の処理を変更してください。
            //
            // ドロップダウンの設定
            //
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

        //// 事前データロード -- End

        //// 検索処理 -- Start

        // 画面アーキテクチャ共通の検索処理

        /// <summary>クエリオブジェクトの設定</summary>
        var query = function () {
            var query = {
                // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                url: "../Services/FoodProcsService.svc/ma_kaisha",
                // TODO: ここまで
                filter: createFilter(),
                inlinecount: "allpages"
            }
            return query;
        };
        /// <summary>フィルター条件の設定</summary>
        var createFilter = function () {
            var filters = [],
                    criteria = parameters["cd_kaisha"];

            // TODO: 画面の仕様に応じて以下のフィルター条件を変更してください。
            //filters.push("cd_kaisha eq '" + criteria + "'");
            // TODO: ここまで

            //return filters.join(" and ");
        };
        /// <summary>データ検索を行います。</summary>
        /// <param name="query">クエリオブジェクト</param>
        var searchItems = function (query) {
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
            App.ajax.webget(
            // WCF Data ServicesのODataシステムクエリオプションを生成
                    App.data.toODataFormat(query)
                ).done(function (result) {
                    // データバインド
                    bindData(result);
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                }).always(function () {
                    setTimeout(function () {
                        $("#list-loading-message").text("");
                        isDataLoading = false;
                    }, 500);
                });
        };

        var getParameters = function () {
            var parameters = {},
                    keyValue,
                    parameterStartPos = window.location.href.indexOf('?') + 1,
                    queryStrings;

            queryStrings = window.location.href.slice(parameterStartPos).split('&');

            if (!App.isUnusable(queryStrings)) {
                for (var i = 0; i < queryStrings.length; i++) {
                    keyValue = queryStrings[i].split('=');
                    parameters[keyValue[0]] = keyValue[1];
                }
            }
            return parameters;
        };

        var parameters = getParameters();

        if (!App.isUnusable(parameters["cd_kaisha"])) {
            searchItems(new query());
        }
        /// <summary>検索前の状態に初期化します。</summary>
        var clearState = function () {
            // データクリア
            //grid.clearGridData();
            lastScrollTop = 0;
            querySetting.skip = 0;
            querySetting.count = 0;
            //displayCount();

            // TODO: 画面の仕様に応じて以下のパラメータ設定を変更してください。

            // 変更セットの作成
            changeSet = new App.ui.page.changeSet();
            // TODO: ここまで

            // 情報メッセージのクリア
            App.ui.page.notifyInfo.clear();
            // エラーメッセージのクリア
            App.ui.page.notifyAlert.clear();
        };

        /// <summary>データをバインドします。</summary>
        /// <param name="result">検索結果</param>
        var bindData = function (result) {

            headerContent = $(".header-content");
            detailContent = $(".list-part-detail-content");

            headerContent.toForm(result.d.results[0]);
            detailContent.toForm(result.d.results[0]);

        };

        //// 検索処理 -- End

        //// コントロール定義 -- Start

        // ダイアログ固有のコントロール定義
        saveConfirmDialog.dlg();

        /// <summary>ダイアログを開きます。</summary>
        var showSaveConfirmDialog = function () {
            saveConfirmDialogNotifyInfo.clear();
            saveConfirmDialogNotifyAlert.clear();
            saveConfirmDialog.dlg("open");
        };
        /// <summary>ダイアログを閉じます。</summary>
        var closeSaveConfirmDialog = function () {
            saveConfirmDialog.dlg("close");
        };

        // ダイアログ固有の変数宣言 -- End

        // グリッドコントロール固有のコントロール定義

        /// <summary>詳細を表示します。</summary>

        // TODO：画面の仕様に応じて以下の詳細の項目の設定を変更してください。

        // TODO：ここまで

        App.ui.page.notifyAlert.clear();

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

        // ユーザー権限による操作制御定義を定義します。
        App.ui.pagedata.operation.applySetting(App.ui.page.user.Roles[0], App.ui.page.lang);
        $(function () {
            if (userRoles === pageLangText.operator.text || userRoles === pageLangText.editor.text
                        || userRoles === pageLangText.viewer.text) {
                $(".save-button").css("display", "none");

            }
        });

        //// 操作制御定義 -- End

        //// メッセージ表示 -- Start
        // ダイアログ情報メッセージの設定
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

        //// メッセージ表示 -- End

        //// 保存処理 -- Start

        // グリッド固有の保存処理
        // コンテンツに変更が発生した場合は、
        $(".list-part-detail-content").on("change", function () {
            isChanged = true;
        });

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
            // データ整合性エラーのハンドリングを行います。
            if (App.isArray(ret) && ret.length > 0) {
                if (ret[0].InvalidationName === "NotExsists") {
                    // エラーメッセージの表示
                    App.ui.page.notifyAlert.message(
                            pageLangText.invalidation.text + ret[0].Message).show();
                } else {
                    App.ui.page.notifyAlert.message(
                            pageLangText.unDeletableRecord.text + ret[0].Message).show();
                }
            }
            // 更新時同時実行制御エラーのハンドリングを行います。
            if (!App.isUndefOrNull(ret.Updated) && ret.Updated.length > 0) {
                // 他のユーザーによって削除されていた場合
                if (App.isUndefOrNull(ret.Updated[0].Current)) {
                    // メッセージの表示
                    App.ui.page.notifyAlert.message(
                            pageLangText.duplicate.text + pageLangText.deletedDuplicate.text).show();
                }
                else {
                    detailContent = $(".list-part-detail-content");
                    // TODO: 画面の仕様に応じて更新後のデータ状態をセットします
                    var data = {
                        "cd_kaisha": ret.Updated[0].Current.cd_kaisha,
                        "nm_kaisha": ret.Updated[0].Current.nm_kaisha,
                        "no_yubin": ret.Updated[0].Current.no_yubin,
                        "nm_jusho_1": ret.Updated[0].Current.nm_jusho_1,
                        "nm_jusho_2": ret.Updated[0].Current.nm_jusho_2,
                        "nm_jusho_3": ret.Updated[0].Current.nm_jusho_3,
                        "no_tel_1": ret.Updated[0].Current.no_tel_1,
                        "no_tel_2": ret.Updated[0].Current.no_tel_2,
                        "no_fax_1": ret.Updated[0].Current.no_fax_1,
                        "no_fax_2": ret.Updated[0].Current.no_fax_2,
                        "dt_create": ret.Updated[0].Current.dt_create,
                        "dt_update": ret.Updated[0].Current.dt_update,
                        "ts": ret.Updated[0].Current.ts,
                        "cd_create": ret.Updated[0].Current.cd_create
                    };
                    // TODO: ここまで

                    // カレントのデータを詳細画面へ表示
                    detailContent.toForm(data);

                    // エラーメッセージの表示
                    App.ui.page.notifyAlert.message(
                                        pageLangText.duplicate.text + pageLangText.updatedDuplicate.text).show();
                }

            }
        };

        /// <summary>変更を保存します。</summary>
        /// <param name="e">イベントデータ</param>

        var saveData = function (e) {
            closeSaveConfirmDialog();
            // 情報メッセージのクリア
            App.ui.page.notifyInfo.clear();

            // 更新データをJSONオブジェクトに変換
            var postData = $(".list-part-detail-content").toJSON();

            // ローディングの表示
            App.ui.loading.show(pageLangText.nowSaving.text);

            // TODO: 画面の仕様に応じて以下の項目を変更してください。
            if (!App.isUndefOrNull(postData.ts)) {
                postData["cd_update"] = App.ui.page.user.Code;
            }
            else {
                postData["cd_create"] = App.ui.page.user.Code;
                postData["cd_update"] = App.ui.page.user.Code;
            };
            // TODO: ここまで
            var changeSet = new App.ui.page.changeSet();

            // TODO: 画面の仕様に応じて新規/更新にて処理を変更してください。
            if (!App.isUndefOrNull(postData.ts)) {
                changeSet.addUpdated(App.uuid, null, null, postData);
            }
            else {
                changeSet.addCreated(App.uuid, postData);
            }

            var data = changeSet.getChangeSet();

            // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
            var saveUrl = "../api/KaishaMaster";
            // TODO: ここまで

            App.ajax.webpost(
                    saveUrl, data
                ).done(function (result) {
                    // 検索前の状態に初期化
                    clearState();
                    isChanged = false;
                    App.ui.page.notifyInfo.message(pageLangText.successMessage.text).show();
                }).fail(function (result) {
                    // データ変更エラーハンドリングを行います。
                    handleSaveDataError(result);
                }).always(function () {
                    // データ検索
                    searchItems(new query());
                    // ローディングの終了
                    App.ui.loading.close();
                });
        };
        //// 保存処理 -- End

        //// バリデーション -- Start

        // グリッド固有のバリデーション

        // 詳細のバリデーション設定
        var v = Aw.validation({
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
        $(".list-part-detail-content").validation(v);

        //// バリデーション -- End

        /// <summary>保存ボタンクリック時のイベント処理を行います。</summary>
        $(".save-button").on("click", function () {
            var detailContent = $(".list-part-detail-content"),
                    result;
            App.ui.page.notifyInfo.clear();
            // 変更がない場合は処理を抜ける
            if (!isChanged) {
                App.ui.page.notifyInfo.message(pageLangText.noChange.text).show();
                return;
            }
            result = detailContent.validation().validate();
            // 変更セット内にバリデーションエラーがある場合は処理を抜ける
            if (!result.errors.length) {
                showSaveConfirmDialog();
            };
        });


        // 検索処理
        searchItems(new query());

        /// <summary>保存確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
        $(".save-confirm-dialog .dlg-yes-button").on("click", saveData);
        // <summary>保存確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
        $(".save-confirm-dialog .dlg-no-button").on("click", closeSaveConfirmDialog);

        /// <summary>データに変更があり、未保存の状態でページを離れる際に確認を行います。</summary>
        //別画面に遷移したりするときに実行する関数の定義
        var onBeforeUnload = function () {
            //データを変更したかどうかは各画面でチェックし、保持する
            if (isChanged) {
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
            if (isChanged) {
                var ans = confirm(pageLangText.unloadWithoutSave.text);
                if (ans == false) {
                    $(window).on('beforeunload', onBeforeUnload);   //イベントを外したままだと、他のボタンで機能しないので、再設定
                    return false;
                }
            }
            __doPostBack('ctl00$loginButton', '');
        });

        // <summary>前ページよりパラメータを取得し、条件によって初期表示時に検索を行います。</summary>
        // TODO: 画面の仕様に応じて以下の値を変更します。

        // TODO: ここまで

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

    <!-- 画面ヘッダー -->
    <div class="content-part">
        <div class="part-body">
            <div class="header-content">
                <ul>
                    <li>
                        <label>
                            <span class="item-label" style="margin-left: 650px; margin-right:5px;" data-app-text="dt_create"></span><span name="dt_create" readonly="readonly" tabindex="-1" class="data-app-format" data-app-format="dateTime"></span>
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" style="margin-left: 650px; margin-right:5px;" data-app-text="dt_update"></span><span name="dt_update" readonly="readonly" tabindex="-1" class="data-app-format" data-app-format="dateTime"></span>
                        </label>
                    </li>
                </ul>
            </div>
        </div>
    </div>

    <!-- 検索結果一覧 -->
    <div class="content-part result-list">
        <!-- グリッドコントロール固有のデザイン -- Start -->
        <div class="part-body" id="detail-content">
            <div class="list-part-detail-content">
            <!--    <ul class="item-list item-list-left">-->
                <ul class="item-list">
                    <!-- TODO: 画面の仕様に応じて以下の項目を変更してください。 -->
                    <li>
                        <label>
                            <span class="item-label" data-app-text="cd_kaisha"></span>
                            <input class="readonly-txt" type="text" name="cd_kaisha" readonly="true"/>
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="nm_kaisha"></span>
                            <input type="text" data-app-validation="nm_kaisha" style="width: 20em;" name="nm_kaisha"/>

                        </label>
                    </li>
                </ul> 

                <ul class="item-list item-list-left">
                    <li>
                        <label>
                            <span class="item-label" data-app-text="nm_jusho"></span>
                            <input type="text" data-app-validation="no_yubin" style="width: 5em;" name="no_yubin"/>
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label"></span>
                            <input type="text" data-app-validation="nm_jusho_1" style="width: 15em;" name="nm_jusho_1"/>
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label"></span>
                            <input type="text" data-app-validation="nm_jusho_2" style="width: 15em;" name="nm_jusho_2"/>
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label"></span>
                            <input type="text" data-app-validation="nm_jusho_3" style="width: 15em;" name="nm_jusho_3"/>
                        </label>
                    </li>
                </ul>
                    <!-- TODO: ここまで -->


                <ul class="item-list item-list-right clearfix">
                    <!-- TODO: 画面の仕様に応じて以下の項目を変更してください。 -->
                    

                    
                    <li>
                        <label>
                            <span class="item-label" data-app-text="no_tel_1"></span>
                            <input type="text" data-app-validation="no_tel_1" name="no_tel_1"/>
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="no_tel_2"></span>
                            <input type="text" data-app-validation="no_tel_2" name="no_tel_2"/>
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="no_fax_1"></span>
                            <input type="text" data-app-validation="no_fax_1" name="no_fax_1"/>
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="no_fax_2"></span>
                            <input type="text" data-app-validation="no_fax_2" name="no_fax_2"/>
                        </label>
                    </li>
                    <li>
                        <input type="hidden" name="ts" />
                    </li>
                    <li>
                        <input type="hidden" name="cd_create" />
                    </li>
                    <li>
                        <input type="hidden" name="dt_create" />
                    </li>
                    <!-- TODO: ここまで -->
                </ul>
                <div class="clearfix">
                </div>
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
        <!-- TODO: 画面の仕様に応じて以下のボタンを変更してください。 -->
        <button type="button" class="save-button" name="save-button" data-app-operation="save">
            <span class="icon"></span>
            <span data-app-text="save"></span>
        </button>
    </div>
    <div class="command" style="right: 9px;">
        <button type="button" class="menu-button" name="menu-button">
            <span class="icon"></span>
            <span data-app-text="menu"></span>
        </button>
        <!-- TODO: ここまで -->
    </div>
    <div class="command-detail" style="left: 1px; display:none;">
        <button type="button" class="line-button" name="line-button"><span data-app-text="lineSave"></span> </button>
    </div>
    <div class="command" style="right: 9px;">
    </div>
    <!-- 画面アーキテクチャ共通のデザイン -- End -->

    <!-- 画面デザイン -- End -->
</asp:Content>

<asp:Content ID="Content5" ContentPlaceHolderID="DialogsContent" runat="server">
    
    <!-- 画面デザイン -- Start -->
    
    <!-- ダイアログ固有のデザイン -- Start -->

    <!-- TODO: 画面の仕様に応じて以下のダイアログの設定を変更してください。 -->
    <div class="save-confirm-dialog" style="display: none;">
        <div class="dialog-header">
            <h4 data-app-text="confirmTitle"></h4>
        </div>
        <div class="dialog-body" style="padding: 10px; width: 100%;">
            <div class="part-body" id="confirm-form">
                <span data-app-text="saveConfirm"></span>
            </div>
        </div>
    <!-- TODO: ここまで  -->
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
