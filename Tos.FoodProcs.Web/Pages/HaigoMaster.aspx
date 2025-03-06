<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="HaigoMaster.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.HaigoMaster" %>

<asp:Content ID="Content1" ContentPlaceHolderID="IncludeContent" runat="server">
    <script src="<%=ResolveUrl("~/Resources/pages/pagedata-haigomaster." + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
    <script src="<%=ResolveUrl("~/Resources/grid/grid.locale-" + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        /* 画面デザイン -- Start */
        
        /* TODO：画面の仕様に応じて以下のスタイルを変更してください。 */
        .header-content li
        {
            display: block;
        }

        .header-content {
            margin-left: 10px;
            margin-right: 10px;
        }
        
        .list-part-detail-content .item-list-left {
            float: left;
            width: 50%;
        }
        
        .list-part-detail-content .item-list-right {
            margin-left: 50%;
            width: 50%;
        }

        input
        {
            vertical-align: middle;
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
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
                isChanged = false;
            // TODO：ここまで

            // urlよりパラメーターを取得
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

            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            // urlよりパラメーターを取得
            var parameters = getParameters();
            var cd_haigo = parameters["cdHaigo"]
                , no_han = parameters["no_han"]
                , cd_bunrui = parameters["cd_bunrui"]
                , haigoName = parameters["haigoName"]
                , mishiyoFlg = parameters["mishiyoFlg"]
                , dt_yuko = App.ifUndef(parameters["dt_yuko"], "").toString().replace("#", "");

            // 遷移状態を取得
            handle = parameters.handle;
            if (handle == "detail-button") {
                $(".content-part [name='cd_haigo']").attr("disabled", true).css("background-color", "#F2F2F2");
            };
            // TODO：ここまで

            //// 変数宣言 -- End

            //// コントロール定義 -- Start
            // ダイアログ固有の変数宣言
            var clearConfirmDialog = $(".clear-confirm-dialog"),
                saveConfirmDialog = $(".save-confirm-dialog"),
                saveCompleteDialog = $(".save-complete-dialog");

            // ダイアログ固有のコントロール定義
            clearConfirmDialog.dlg();
            saveConfirmDialog.dlg();
            saveCompleteDialog.dlg();
            //            navigateConfirmDialog.dlg();

            /// <summary>ダイアログを開きます。</summary>
            var showClearConfirmDialog = function () {
                clearConfirmDialogNotifyInfo.clear();
                clearConfirmDialogNotifyAlert.clear();
                clearConfirmDialog.draggable(true);
                clearConfirmDialog.dlg("open");
            };

            /// <summary>ダイアログを開きます。</summary>
            var showSaveConfirmDialog = function () {
                saveConfirmDialogNotifyInfo.clear();
                saveConfirmDialogNotifyAlert.clear();
                saveConfirmDialog.draggable(true);
                saveConfirmDialog.dlg("open");
            };

            /// <summary>ダイアログを開きます。</summary>
            var showSaveCompleteDialog = function () {
                saveCompleteDialogNotifyInfo.clear();
                saveCompleteDialogNotifyAlert.clear();
                saveCompleteDialog.draggable(true);
                saveCompleteDialog.dlg("open");
            };

            var closeClearConfirmDialog = function () {
                clearConfirmDialog.dlg("close");
            };

            /// <summary>ダイアログを閉じます。</summary>
            var closeSaveConfirmDialog = function () {
                saveConfirmDialog.dlg("close");
            };

            /// <summary>ダイアログを閉じます。</summary>
            var closeSaveCompleteDialog = function () {
                saveCompleteDialog.dlg("close");
            };

            //// コントロール定義 -- End
            //---------------------------------------------------------
            //2019/07/24 trinh.bd Task #14029
            //------------------------START----------------------------
            //// 操作制御定義
            //App.ui.pagedata.operation.applySetting(App.ui.page.user.Roles[0], App.ui.page.lang);
            var kbn_ma_haigo = App.ui.page.user.kbn_ma_haigo;
            if (kbn_ma_haigo == pageLangText.isRoleFisrt.number) {
                App.ui.pagedata.operation.applySetting("isRoleFisrt", App.ui.page.lang);
            }
            else if (kbn_ma_haigo == pageLangText.isRoleSecond.number) {
                App.ui.pagedata.operation.applySetting("isRoleSecond", App.ui.page.lang);
            } else {
                App.ui.pagedata.operation.applySetting("NotRole", App.ui.page.lang);
            }
            //------------------------END------------------------------

            //// 事前データロード -- Start
            // 情報メッセージのクリア
            App.ui.page.notifyInfo.clear();
            // エラーメッセージのクリア
            App.ui.page.notifyAlert.clear();

            // 画面アーキテクチャ共通の事前データロード
            App.deferred.parallel({
                loading: App.ui.loading.show(pageLangText.nowProgressing.text),
                // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                bunrui: App.ajax.webget("../Services/FoodProcsService.svc/ma_bunrui?$filter=kbn_hin eq " + pageLangText.shikakariHinKbn.text + " and flg_mishiyo eq " + pageLangText.shiyoMishiyoFlg.text + "&$orderby=cd_bunrui"), //品区分5のものだけを取得
                lineSave: App.ajax.webget("../Services/FoodProcsService.svc/ma_seizo_line?$filter=cd_haigo eq '" + cd_haigo + "' and flg_mishiyo eq " + pageLangText.shiyoMishiyoFlg.text + " and kbn_master eq " + pageLangText.haigoMasterSeizoLineMasterKbn.text),
                hokan: App.ajax.webget("../Services/FoodProcsService.svc/ma_kbn_hokan?$filter=flg_mishiyo eq " + pageLangText.shiyoMishiyoFlg.text + "&$orderby=cd_hokan_kbn")
                // TODO: ここまで
            }).done(function (result) {
                // TODO: 画面の仕様に応じて以下のサービス呼び出し成功時の処理を変更してください。
                var cd_bunrui = result.successes.bunrui.d;
                var exsistLine = result.successes.lineSave.d;
                var kbn_hokan = result.successes.hokan.d;
                // TODO: ここまで
                // TODO: 画面の仕様に応じてドロップダウンの設定を変更してください。
                App.ui.appendOptions($(".list-part-detail-content [name='cd_bunrui']"), "cd_bunrui", "nm_bunrui", cd_bunrui, true);
                App.ui.appendOptions($(".list-part-detail-content [name='kbn_hokan']"), "cd_hokan_kbn", "nm_hokan_kbn", kbn_hokan, true);
                // TODO: ここまで
                // TODO: 画面の仕様に応じてデータ設定を変更してください。
                // ライン登録設定
                if (exsistLine.length > 0) {
                    $(".content-part [name='lineSave']").text(pageLangText.lineOK.text);
                }
                else {
                    $(".content-part [name='lineSave']").text(pageLangText.lineNG.text);
                }
                // 詳細項目にデータ設定
                if (!App.isUnusable(parameters["cdHaigo"])) {
                    if (parameters["handle"] != "add-button") {
                        searchItems(new query());
                    }
                    else {
                        dataSetting(handle);
                    }
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

            // 換算区分をKg・L → LB・GALとする。
            //phuc add start
            if (pageLangText.kbn_tani_LB_GAL.text === App.ui.page.user.kbn_tani) {
                $(".labelLB").show();
                $(".labelKg").hide();

                $(".labelGAL").show();
                $(".labelL").hide();
            } else {
                $(".labelLB").hide();
                $(".labelKg").show();

                $(".labelGAL").hide();
                $(".labelL").show();
            }
            //phuc add end

            //品名の表示切替判定
            if (App.ui.page.user.kbn_hinmei_kirikae == pageLangText.kbn_hinmei_kirikae_ja.number) {
                $(".list-part-detail-content [name='nm_haigo_en']").css("display", "none");
                $(".list-part-detail-content [name='nm_haigo_zh']").css("display", "none");
                $(".list-part-detail-content [name='nm_haigo_vi']").css("display", "none");
                $(".nm_haigo_detail_en").css("display", "none");
                $(".nm_haigo_detail_zh").css("display", "none");
                $(".nm_haigo_detail_vi").css("display", "none");
            } else if (App.ui.page.user.kbn_hinmei_kirikae == pageLangText.kbn_hinmei_kirikae_en.number) {
                $(".list-part-detail-content [name='nm_haigo_ja']").css("display", "none");
                $(".list-part-detail-content [name='nm_haigo_zh']").css("display", "none");
                $(".list-part-detail-content [name='nm_haigo_vi']").css("display", "none");
                $(".nm_haigo_detail_ja").css("display", "none");
                $(".nm_haigo_detail_zh").css("display", "none");
                $(".nm_haigo_detail_vi").css("display", "none");
            } else if (App.ui.page.user.kbn_hinmei_kirikae == pageLangText.kbn_hinmei_kirikae_zh.number) {
                $(".list-part-detail-content [name='nm_haigo_ja']").css("display", "none");
                $(".list-part-detail-content [name='nm_haigo_en']").css("display", "none");
                $(".list-part-detail-content [name='nm_haigo_vi']").css("display", "none");
                $(".nm_haigo_detail_ja").css("display", "none");
                $(".nm_haigo_detail_en").css("display", "none");
                $(".nm_haigo_detail_vi").css("display", "none");
            }
            else if (App.ui.page.user.kbn_hinmei_kirikae == pageLangText.kbn_hinmei_kirikae_vi.number) {
                $(".list-part-detail-content [name='nm_haigo_ja']").css("display", "none");
                $(".list-part-detail-content [name='nm_haigo_en']").css("display", "none");
                $(".list-part-detail-content [name='nm_haigo_zh']").css("display", "none");
                $(".nm_haigo_detail_ja").css("display", "none");
                $(".nm_haigo_detail_en").css("display", "none");
                $(".nm_haigo_detail_zh").css("display", "none");
            }

            //// 事前データロード -- End

            //// 検索処理 -- Start
            // 画面アーキテクチャ共通の検索処理
            // TODO: 画面の仕様に応じて変更してください。
            /// <summary>遷移状態によりデータを設定</summary>
            /// <param name="handle">遷移元画面のボタン</param>
            var dataSetting = function (handle) {
                if (handle === "add-button") {
                    // TODO: 取得したデータよりキー項目を制御
                    $(".content-part [name='no_han']").text(pageLangText.hanNoShokichi.text);
                    $(".content-part [name='flg_mishiyo']:checked").attr("checked", false);
                    $(".content-part [name='dt_from']").text(pageLangText.dateShokichi.text);
                    $(".content-part [name='ritsu_budomari']").val(pageLangText.budomariShokichi.text);
                    $(".content-part [name='wt_kihon']").val(pageLangText.juryoShokichi.text);
                    $(".content-part [name='ritsu_kihon']").val(pageLangText.ritsuKihonShokichi.text);
                    $(".content-part [name='ritsu_hiju']").val(pageLangText.hijuShokichi.text);
                    $(".content-part [name='flg_gassan_shikomi']").val([pageLangText.gassanFlgShokichi.text]);
                    //$(".content-part [name='kbn_kanzan']").val([pageLangText.kgKanzanKbn.text]);
                    $(".content-part [name='dt_create']").text(pageLangText.shokikaShokichi.text);
                    $(".content-part [name='cd_create']").val(pageLangText.shokikaShokichi.text);
                    $(".content-part [name='dt_update']").text(pageLangText.shokikaShokichi.text);
                    $(".content-part [name='cd_update']").val(pageLangText.shokikaShokichi.text);
                    $(".content-part [name='lineSave']").text(pageLangText.lineTorokuShokichi.text);
                    $(".content-part [name='flg_tenkai']").val([pageLangText.tenkaiFlgShokichi.text]);
                    $(".content-part [name='wt_haigo_gokei']").val(pageLangText.systemValueZero.text);
                    // TODO: ここまで
                }
                if (handle === "copy-button") {
                    // TODO: 取得したデータよりキー項目を制御
                    $(".content-part [name='no_han']").text(pageLangText.hanNoShokichi.text);
                    $(".content-part [name='flg_mishiyo']:checked").attr("checked", false);
                    $(".content-part [name='dt_from']").text(pageLangText.dateShokichi.text);
                    $(".content-part [name='cd_haigo']").val(pageLangText.shokikaShokichi.text);
                    $(".content-part [name='flg_tanto_hinkan']").val(pageLangText.shokikaShokichi.text);
                    // $(".content-part [name='dt_hinkan_koshin']").val(pageLangText.shokikaShokichi.text);
                    $(".content-part [name='flg_tanto_seizo']").val(pageLangText.shokikaShokichi.text);
                    // $(".content-part [name='dt_seizo_koshin']").val(pageLangText.shokikaShokichi.text);
                    $(".content-part [name='dt_create']").text(pageLangText.shokikaShokichi.text);
                    $(".content-part [name='cd_create']").val(pageLangText.shokikaShokichi.text);
                    $(".content-part [name='dt_update']").text(pageLangText.shokikaShokichi.text);
                    $(".content-part [name='cd_update']").val(pageLangText.shokikaShokichi.text);
                    $(".content-part [name='lineSave']").text(pageLangText.lineTorokuShokichi.text);
                    // TODO: ここまで
                }
            };
            /// <summary>追加状態の変更セットに追加する変更データの設定を行います。</summary>
            /// <param name="newRow">新規行データ</param>
            var setCreatedChangeDataSecond = function (newData) {
                // TODO: 画面の仕様に応じて以下の項目を変更してください。
                var changeData = {
                    "no_seq": "",
                    "cd_haigo": "",
                    //"no_han": newData.no_han,
                    "no_han": pageLangText.hanNoShokichi.text,
                    "wt_haigo": "",
                    "no_kotei": newData.no_kotei,
                    "no_tonyu": newData.no_tonyu,
                    "kbn_hin": newData.kbn_hin,
                    "cd_hinmei": newData.cd_hinmei,
                    "nm_hinmei": newData.nm_hinmei,
                    "cd_mark": newData.cd_mark,
                    "wt_kihon": newData.wt_kihon,
                    "wt_shikomi": newData.wt_shikomi,
                    "wt_nisugata": newData.wt_nisugata,
                    "su_nisugata": newData.su_nisugata,
                    "wt_kowake": newData.wt_kowake,
                    "su_kowake": newData.su_kowake,
                    "cd_futai": newData.cd_futai,
                    "ritsu_hiju": newData.ritsu_hiju,
                    "ritsu_budomari": newData.ritsu_budomari,
                    "flg_mishiyo": newData.flg_mishiyo,
                    "dt_create": "",
                    "cd_create": "",
                    "dt_update": "",
                    "cd_update": "",
                    "su_settei": newData.su_settei,
                    "su_settei_max": newData.su_settei_max,
                    "su_settei_min": newData.su_settei_min,
                    "flg_kowake_systemgai": newData.flg_kowake_systemgai
                };
                // TODO: ここまで

                return changeData;
            };
            /// <summary>追加状態の変更セットに追加する変更データの設定を行います。</summary>
            /// <param name="newRow">新規行データ</param>
            var setCreatedChangeDataThird = function (newData) {
                // TODO: 画面の仕様に応じて以下の項目を変更してください。
                var changeData = {
                    "kbn_master": newData.kbn_master,
                    "cd_haigo": "",
                    "no_juni_yusen": newData.no_juni_yusen,
                    "cd_line": newData.cd_line,
                    "flg_mishiyo": newData.flg_mishiyo,
                    "dt_create": "",
                    "cd_create": "",
                    "dt_update": "",
                    "cd_update": ""
                };
                // TODO: ここまで

                return changeData;
            };
            /// <summary>コピーデータを設定</summary>
            /// <param name="cd_haigo">コピー元配合コード</param>
            var copyDataSet = function (cd_haigo) {
                App.deferred.parallel({
                    // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                    //maHaigoRecipe: App.ajax.webget("../Services/FoodProcsService.svc/ma_haigo_recipe?$filter=cd_haigo eq '" + cd_haigo + "' and no_han eq " + pageLangText.hanNoShokichi.text),
                    maHaigoRecipe: App.ajax.webget("../Services/FoodProcsService.svc/ma_haigo_recipe?$filter=cd_haigo eq '" + cd_haigo + "' and no_han eq " + no_han),
                    maSeizoLine: App.ajax.webget("../Services/FoodProcsService.svc/ma_seizo_line?$filter=cd_haigo eq '" + cd_haigo + "' and kbn_master eq " + pageLangText.haigoMasterSeizoLineMasterKbn.text)
                    // TODO：ここまで
                }).done(function (result) {
                    // TODO：画面の仕様に応じて以下の項目を変更してください。
                    // 配合レシピマスタ
                    changeSetSecond = new App.ui.page.changeSet();
                    // 製造ラインマスタ
                    changeSetThird = new App.ui.page.changeSet();
                    //for (var i = 0; i < result.d.length; i++) {
                    for (var i = 0; i < result.successes.maHaigoRecipe.d.length; i++) {
                        changeSetSecond.addCreated(i, setCreatedChangeDataSecond(result.successes.maHaigoRecipe.d[i]));
                    }
                    for (var i = 0; i < result.successes.maSeizoLine.d.length; i++) {
                        changeSetThird.addCreated(i, setCreatedChangeDataThird(result.successes.maSeizoLine.d[i]));
                    }
                    // TODO：ここまで
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                }).always(function () {
                    setTimeout(function () {
                        $("#list-loading-message").text("");
                        isDataLoading = false;
                    }, 500);
                });
            };
            // TODO: ここまで

            /// <summary>クエリオブジェクトの設定</summary>
            var query = function () {
                var query = {
                    // TODO：画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                    url: "../Services/FoodProcsService.svc/ma_haigo_mei",
                    // TODO：ここまで
                    filter: createFilter(),
                    inlinecount: "allpages"
                }
                return query;
            };
            /// <summary>フィルター条件の設定</summary>
            var createFilter = function () {
                var filters = [];
                // TODO：画面の仕様に応じて以下のフィルター条件を変更してください。
                filters.push("cd_haigo eq '" + cd_haigo + "'");
                filters.push("no_han eq " + no_han);
                // TODO：ここまで

                return filters.join(" and ");
            };
            /// <summary>データ検索を行います。</summary>
            /// <param name="query">クエリオブジェクト</param>
            var searchItems = function (query) {
                // 情報メッセージのクリア
                App.ui.page.notifyInfo.clear();
                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();
                if (isDataLoading === true) {
                    return;
                }
                isDataLoading = true;
                // ローディングの表示
                //$("#list-loading-message").text(
                //    App.str.format(
                //        pageLangText.nowListLoading.text,
                //        querySetting.skip + 1,
                //        querySetting.top
                //    )
                //);
                App.ajax.webget(
                // WCF Data ServicesのODataシステムクエリオプションを生成
                    App.data.toODataFormat(query)
                ).done(function (result) {
                    // 有効期間：DB値が1975年未満だった場合に表示がおかしくなる為、フォーマットしなおす
                    var resultData = result.d.results[0];
                    var dtFrom = App.data.getDate(resultData.dt_from);
                    result.d.results[0].dt_from = App.data.getDateString(dtFrom, true);

                    // データバインド
                    bindData(result).done(function () {
                        dataSetting(handle)
                    });
                    if (handle == "copy-button") {
                        copyDataSet(cd_haigo);
                    }
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                }).always(function () {
                    setTimeout(function () {
                        $("#list-loading-message").text("");
                        isDataLoading = false;
                    }, 500);
                });
            };

            /// <summary>データをバインドします。</summary>
            /// <param name="result">検索結果</param>
            var bindData = function (result) {
                var d = $.Deferred();
                // TODO：画面の仕様に応じてバインド箇所を変更してください。
                var detailContent = $(".content-part"),
                // TODO：ここまで
                    data = result.d.results[0];
                detailContent.toForm(data);
                d.resolve();
                return d.promise();
            };

            //// 検索処理 -- End

            //// 保存処理 -- Start
            /// <summary>データ変更エラーハンドリングを行います。</summary>
            /// <param name="result">エラーの戻り値</param>
            var handleSaveDataError = function (result) {
                var ret = JSON.parse(result.rawText);
                // データが存在しない場合は処理を抜ける
                if (App.isUndefOrNull(ret.First) && App.isUndefOrNull(ret.Second) && App.isUndefOrNull(ret.Third)) {
                    App.ui.page.notifyAlert.message(result.message).show();
                    return;
                }

                // 新規時データ整合性エラーのハンドリングを行います。
                if ((App.isArray(ret.First) && ret.First.length > 0) || (App.isArray(ret.Second) && ret.Second.length > 0) || (App.isArray(ret.Third) && ret.Third.length > 0)) {
                    var errorMsg = "";
                    if (ret.First[0].InvalidationName === "Exists") {
                        // 配合名一覧に存在している場合
                        errorMsg = pageLangText.ma_haigo_mei.text + ret.First[0].Message;
                        //App.ui.page.notifyAlert.message(pageLangText.ma_haigo_mei.text + ret.First[0].Message).show();
                    }
                    else if (ret.Second[0].InvalidationName === "Exists") {
                        // 配合レシピに存在している場合
                        errorMsg = pageLangText.ma_haigo_recipe.text + ret.Second[0].Message;
                        //App.ui.page.notifyAlert.message(pageLangText.ma_haigo_recipe.text + ret.Second[0].Message).show();
                    }
                    else if (ret.Third[0].InvalidationName === "Exists") {
                        // 製造ラインマスタに存在している場合
                        errorMsg = pageLangText.ma_seizo_line.text + ret.Third[0].Message;
                        //App.ui.page.notifyAlert.message(pageLangText.ma_seizo_line.text + ret.Third[0].Message).show();
                    }
                    // メッセージの表示
                    App.ui.page.notifyAlert.message(errorMsg, $("#id_cd_haigo")).show();
                }
                // 更新時同時実行制御エラーのハンドリングを行います。
                if (!App.isUndefOrNull(ret.First.Updated) && ret.First.Updated.length > 0) {
                    // 他のユーザーによって削除されていた場合
                    var upCurrent = ret.First.Updated[0].Current;
                    if (App.isUndefOrNull(upCurrent)) {

                        // メッセージの表示
                        App.ui.page.notifyAlert.message(
                            pageLangText.duplicate.text + pageLangText.deletedDuplicate.text).show();
                    }
                    else {
                        // 更新後のデータ状態をセット
                        detailContent = $(".content-part");
                        var data = {
                            "nm_haigo_ja": upCurrent.nm_haigo_ja,
                            "nm_haigo_en": upCurrent.nm_haigo_en,
                            "nm_haigo_zh": upCurrent.nm_haigo_zh,
                            "nm_haigo_vi": upCurrent.nm_haigo_vi,
                            "nm_haigo_ryaku": upCurrent.nm_haigo_ryaku,
                            "ritsu_budomari": upCurrent.ritsu_budomari,
                            "wt_kihon": upCurrent.wt_kihon,
                            "ritsu_kihon": upCurrent.ritsu_kihon,
                            "flg_gassan_shikomi": upCurrent.flg_gassan_shikomi,
                            "wt_saidai_shikomi": upCurrent.wt_saidai_shikomi,
                            "wt_haigo": upCurrent.wt_haigo,
                            "wt_haigo_gokei": upCurrent.wt_haigo_gokei,
                            "biko": upCurrent.biko,
                            "no_seiho": upCurrent.no_seiho,
                            "cd_tanto_seizo": upCurrent.cd_tanto_seizo,
                            "dt_seizo_koshin": upCurrent.dt_seizo_koshin,
                            "cd_tanto_hinkan": upCurrent.cd_tanto_hinkan,
                            "dt_hinkan_koshin": upCurrent.dt_hinkan_koshin,
                            "dt_from": upCurrent.dt_from,
                            "kbn_kanzan": upCurrent.kbn_kanzan,
                            "ritsu_hiju": upCurrent.ritsu_hiju,
                            "flg_shorihin": upCurrent.flg_shorihin,
                            "flg_tanto_hinkan": upCurrent.flg_tanto_hinkan,
                            "flg_tanto_seizo": upCurrent.flg_tanto_seizo,
                            "kbn_shiagari": upCurrent.kbn_shiagari,
                            "cd_bunrui": upCurrent.cd_bunrui,
                            "flg_mishiyo": upCurrent.flg_mishiyo,
                            "dt_create": upCurrent.dt_create,
                            "cd_create": upCurrent.cd_create,
                            "dt_update": upCurrent.dt_update,
                            "cd_update": upCurrent.cd_update,
                            "wt_kowake": upCurrent.wt_kowake,
                            "su_kowake": upCurrent.su_kowake,
                            "ts": upCurrent.ts,
                            "flg_tenkai": upCurrent.flg_tenkai,
                            "dd_shomi": upCurrent.dd_shomi,
                            "kbn_hokan": upCurrent.kbn_hokan
                        };

                        // カレントのデータを画面へ表示
                        detailContent.toForm(data);

                        // エラーメッセージの表示
                        App.ui.page.notifyAlert.message(
                            pageLangText.duplicate.text + pageLangText.updatedDuplicate.text).show();
                    }
                }
            };
            /// <summary>配列数を調べて返します。</summary>
            /// <param name="obj">オブジェクト</param>
            var countLength = function (obj) {
                var len = 0;
                for (var key in obj) {
                    ++len;
                }
                return len;
            };
            /// <summary>変更を保存します。</summary>
            /// <param name="e">イベントデータ</param>
            var saveData = function (e) {
                closeSaveConfirmDialog();
                // TODO：画面の仕様に応じて保存対象のデータをセットしてください。
                var detailContent = $(".list-part-detail-content");
                // TODO：ここまで
                // 更新データをJSONオブジェクトに変換
                var postData = detailContent.toJSON(),

                // TODO：画面の仕様に応じて以下の項目を変更してください。
                changeSetFirst = new App.ui.page.changeSet();
                // TODO：ここまで

                // TODO：画面の仕様に応じて新規/更新にて処理を変更してください。
                postData["flg_mishiyo"] = App.ifUndefOrNull($("[name ='flg_mishiyo']:checked").val(), '0');
                postData["flg_tenkai"] = App.ifUndefOrNull($("[name ='flg_tenkai']:checked").val(), '0');
                var dtFromDateTime = App.data.getDateTimeStringForQueryNoUtc(App.date.localDate($("[name = 'dt_from']").text()));
                postData["dt_from"] = dtFromDateTime;
                postData["dt_update"] = new Date();
                postData["cd_update"] = App.ui.page.user.Code;
                if (handle === "detail-button") {
                    var dtCreateDateTime = App.date.localDate($("[name = 'dt_create']").text());
                    postData["dt_create"] = dtCreateDateTime;
                    postData["no_han"] = $("[name ='no_han']").text();
                    changeSetFirst.addUpdated(1, null, null, postData);
                }
                else {
                    postData["no_han"] = pageLangText.hanNoShokichi.text;
                    postData["dt_create"] = new Date();
                    postData["cd_create"] = App.ui.page.user.Code;
                    postData["wt_haigo"] = $("[name='wt_kihon']").val();
                    postData["wt_haigo_gokei"] = $("[name='wt_haigo_gokei']").val();
                    postData["flg_tanto_hinkan"] = pageLangText.falseFlg.text;
                    postData["cd_tanto_hinkan"] = null;
                    postData["dt_hinkan_koshin"] = null;
                    postData["flg_tanto_seizo"] = pageLangText.falseFlg.text;
                    postData["cd_tanto_seizo"] = null;
                    postData["dt_seizo_koshin"] = null;
                    changeSetFirst.addCreated(1, postData);
                }
                // TODO：ここまで
                ChangeSets = {};
                ChangeSets.First = changeSetFirst.getChangeSetData();
                // TODO：画面の仕様に応じて処理を変更してください。
                if (handle === "copy-button") {
                    // 配合レシピ
                    for (var i = 0; i < countLength(changeSetSecond.changeSet.created); i++) {
                        changeSetSecond.changeSet.created[i].cd_haigo = $("[name ='cd_haigo']").val();
                        changeSetSecond.changeSet.created[i].wt_haigo = $("[name ='wt_haigo']").val();
                        changeSetSecond.changeSet.created[i].dt_create = new Date();
                        changeSetSecond.changeSet.created[i].cd_create = App.ui.page.user.Code;
                        changeSetSecond.changeSet.created[i].dt_update = new Date();
                        changeSetSecond.changeSet.created[i].cd_update = App.ui.page.user.Code;
                    }
                    ChangeSets.Second = changeSetSecond.getChangeSetData();
                    // 製造ラインマスタ
                    for (var i = 0; i < countLength(changeSetThird.changeSet.created); i++) {
                        changeSetThird.changeSet.created[i].cd_haigo = $("[name ='cd_haigo']").val();
                        changeSetThird.changeSet.created[i].dt_create = new Date();
                        changeSetThird.changeSet.created[i].cd_create = App.ui.page.user.Code;
                        changeSetThird.changeSet.created[i].dt_update = new Date();
                        changeSetThird.changeSet.created[i].cd_update = App.ui.page.user.Code;
                    }
                    ChangeSets.Third = changeSetThird.getChangeSetData();
                }
                // TODO：ここまで

                changeSets = JSON.stringify(ChangeSets);

                var data = changeSets
                // TODO：画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                var saveUrl = "../api/HaigoMaster";
                // TODO：ここまで

                // ローディングの表示
                App.ui.loading.show(pageLangText.nowSaving.text);

                App.ajax.webpost(
                    saveUrl, data
                ).done(function (result) {
                    // 保存終了メッセージ表示
                    showSaveCompleteDialog();
                }).fail(function (result) {
                    // データ変更エラーハンドリングを行います。
                    handleSaveDataError(result);
                }).always(function () {
                    // ローディングの終了
                    App.ui.loading.close();
                });
            };

            /// <summary>保存完了処理</summary>
            var saveComplete = function () {
                closeSaveCompleteDialog();
                // 変更フラグを初期化
                isChanged = false;
                // 配合マスタ一覧画面に遷移
                navigate("HaigoMasterIchiran");
            };

            //// 保存処理 -- End

            //// バリデーション -- Start

            // TODO：画面の仕様に応じてバリデーションを追加してください。
            /// <summary>いずれか一つは必須チェック</summary>
            /// <param name="e">イベントデータ</param>
            var isValidHaigoName = function (e) {
                var jaHaigo = $(".list-part-detail-content [name='nm_haigo_ja']").val()
                    , enHaigo = $(".list-part-detail-content [name='nm_haigo_en']").val()
                    , zhHaigo = $(".list-part-detail-content [name='nm_haigo_zh']").val()
                    , viHaigo = $(".list-part-detail-content [name='nm_haigo_vi']").val();
                if ((App.isUndefOrNull(jaHaigo) || (App.isStr(jaHaigo) && jaHaigo.length === 0)) &&
                   (App.isUndefOrNull(enHaigo) || (App.isStr(enHaigo) && enHaigo.length === 0)) &&
                   (App.isUndefOrNull(zhHaigo) || (App.isStr(zhHaigo) && zhHaigo.length === 0)) &&
                   (App.isUndefOrNull(viHaigo) || (App.isStr(viHaigo) && viHaigo.length === 0))) {
                    return false;
                }
                return true;
            };

            //品名の表示切替判定
            if (App.ui.page.user.kbn_hinmei_kirikae == pageLangText.kbn_hinmei_kirikae_ja.number) {
                // 配合名(日本語)が変更された場合
                validationSetting.nm_haigo_ja.rules.custom = function () {
                    validationSetting.nm_haigo_ja.messages.custom = App.str.format(pageLangText.requiredInput.text, pageLangText.msg_nm_haigo_ja.text);
                    return isValidHaigoName();
                };
            } else if (App.ui.page.user.kbn_hinmei_kirikae == pageLangText.kbn_hinmei_kirikae_en.number) {
                // 配合名(英語)が変更された場合
                validationSetting.nm_haigo_en.rules.custom = function () {
                    validationSetting.nm_haigo_en.messages.custom = App.str.format(pageLangText.requiredInput.text, pageLangText.msg_nm_haigo_en.text);
                    return isValidHaigoName();
                };
            } else if (App.ui.page.user.kbn_hinmei_kirikae == pageLangText.kbn_hinmei_kirikae_zh.number) {
                // 配合名(中国語)が変更された場合
                validationSetting.nm_haigo_zh.rules.custom = function () {
                    validationSetting.nm_haigo_zh.messages.custom = App.str.format(pageLangText.requiredInput.text, pageLangText.msg_nm_haigo_zh.text);
                    return isValidHaigoName();
                };
            } else if (App.ui.page.user.kbn_hinmei_kirikae == pageLangText.kbn_hinmei_kirikae_vi.number) {
                // 配合名(中国語)が変更された場合
                validationSetting.nm_haigo_vi.rules.custom = function () {
                    validationSetting.nm_haigo_vi.messages.custom = App.str.format(pageLangText.requiredInput.text, pageLangText.msg_nm_haigo_vi.text);
                    return isValidHaigoName();
                };
            } else {
                // 配合名(日本語)が変更された場合
                validationSetting.nm_haigo_ja.rules.custom = function () {
                    return isValidHaigoName();
                };
                // 配合名(英語)が変更された場合
                validationSetting.nm_haigo_en.rules.custom = function () {
                    return isValidHaigoName();
                };
                // 配合名(中国語)が変更された場合
                validationSetting.nm_haigo_zh.rules.custom = function () {
                    return isValidHaigoName();
                };
                // 配合名()が変更された場合
                validationSetting.nm_haigo_vi.rules.custom = function () {
                    return isValidHaigoName();
                };
            }
            /*
            // 配合名(日本語)が変更された場合
            validationSetting.nm_haigo_ja.rules.custom = function () {
            return isValidHaigoName();
            };
            // 配合名(英語)が変更された場合
            validationSetting.nm_haigo_en.rules.custom = function () {
            return isValidHaigoName();
            };
            // 配合名(中国語)が変更された場合
            validationSetting.nm_haigo_zh.rules.custom = function () {
            return isValidHaigoName();
            };
            */
            var IsCalledEvent = false;  // changeイベント内で同様の処理を行わせない（ループを防ぐ）ため、trueの場合は処理回避
            $(".list-part-detail-content [name='nm_haigo_ja']").on("change", function () {
                if (!IsCalledEvent) {
                    IsCalledEvent = true;   // ループの回避
                    $(".list-part-detail-content [name='nm_haigo_en']").change();
                    $(".list-part-detail-content [name='nm_haigo_zh']").change();
                    $(".list-part-detail-content [name='nm_haigo_vi']").change();
                    IsCalledEvent = false;  // フラグを戻す
                }
            });
            $(".list-part-detail-content [name='nm_haigo_en']").on("change", function () {
                if (!IsCalledEvent) {
                    IsCalledEvent = true;
                    $(".list-part-detail-content [name='nm_haigo_ja']").change();
                    $(".list-part-detail-content [name='nm_haigo_zh']").change();
                    $(".list-part-detail-content [name='nm_haigo_vi']").change();
                    IsCalledEvent = false;
                }
            });
            $(".list-part-detail-content [name='nm_haigo_zh']").on("change", function () {
                if (!IsCalledEvent) {
                    IsCalledEvent = true;
                    $(".list-part-detail-content [name='nm_haigo_ja']").change();
                    $(".list-part-detail-content [name='nm_haigo_en']").change();
                    $(".list-part-detail-content [name='nm_haigo_vi']").change();
                    IsCalledEvent = false;
                }
            });
            $(".list-part-detail-content [name='nm_haigo_vi']").on("change", function () {
                if (!IsCalledEvent) {
                    IsCalledEvent = true;
                    $(".list-part-detail-content [name='nm_haigo_ja']").change();
                    $(".list-part-detail-content [name='nm_haigo_en']").change();
                    $(".list-part-detail-content [name='nm_haigo_zh']").change();
                    IsCalledEvent = false;
                }
            });
            // TODO：ここまで

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

            /// <summary>ページ遷移を行います。</summary>
            /// <param name="pageFileName">遷移先ファイル名</param>
            var navigate = function (pageFileName) {
                isChangedData();
                var url = "./" + pageFileName + ".aspx";
                url += "?cd_bunrui=" + cd_bunrui;
                url += "&haigoName=" + haigoName;
                url += "&mishiyoFlg=" + mishiyoFlg;
                url += "&dt_yuko=" + dt_yuko;
                // TODO: 画面遷移時に渡すパラメータを設定
                if (pageFileName == "HaigoMasterIchiran") {
                    url += "&handle=" + pageFileName;
                }
                else if (pageFileName == "SeizoLineMaster") {
                    url += "&cd_haigo=" + cd_haigo;
                    url += "&kbn_master=" + pageLangText.haigoMasterSeizoLineMasterKbn.text;
                }
                else {
                    url += "&cdHaigo=" + cd_haigo;
                    url += "&no_han=" + no_han;
                    url += "&kbnHaigo=" + pageLangText.haigoMasterSeizoLineMasterKbn.text;
                }
                // TODO: ここまで
                window.location = url;
            };

            /// <summary>データのクリアを行います。</summary>
            var clearData = function () {
                //ページをリロード
                window.location.reload();
                //変更フラグの初期化
                isChanged = false;
            };

            /// <summary>データに変更があり、保存を行うか確認します。</summary>
            var isChangedData = function () {
                if (isChanged) {
                    return pageLangText.navigateConfirm.text;
                }
            };

            /// <summary>遷移エラーメッセージを出力します。</summary>
            var showNavigateError = function () {
                // 情報メッセージのクリア
                App.ui.page.notifyInfo.clear();
                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();
                // 情報メッセージ出力
                App.ui.page.notifyAlert.message(pageLangText.navigateError.text).show();
            };

            /// <summary>一覧へ戻るボタンクリック時のイベント処理を行います。</summary>
            $(".list-button").on("click", function () {
                try {
                    navigate("HaigoMasterIchiran")
                } catch (e) {
                }

            });

            /// <summary>ライン登録ボタンクリック時のイベント処理を行います。</summary>
            $(".lineSave-button").on("click", function () {
                if (handle == "add-button") {
                    showNavigateError();
                    return;
                }
                navigate("SeizoLineMaster")
            });

            /// <summary>レシピボタンクリック時のイベント処理を行います。</summary>
            $(".recipe-button").on("click", function () {
                if (handle == "add-button") {
                    showNavigateError();
                    return;
                }
                navigate("HaigoRecipeMaster");
            });

            /// <summary>クリアボタンクリック時のイベント処理を行います。</summary>
            $(".clear-button").on("click", showClearConfirmDialog);

            /// <summary>クリア確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".clear-confirm-dialog .dlg-yes-button").on("click", clearData);
            /// <summary>クリア確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".clear-confirm-dialog .dlg-no-button").on("click", closeClearConfirmDialog);

            /// <summary>保存ボタンクリック時のイベント処理を行います。</summary>
            $(".save-button").on("click", function (e) {
                // 情報メッセージのクリア
                App.ui.page.notifyInfo.clear();
                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();
                var detailContent = $(".list-part-detail-content")
                    , result;

                // 変更がない場合は処理を抜ける
                if (!isChanged) {
                    App.ui.page.notifyInfo.message(pageLangText.noChange.text).show();
                    return;
                }

                // 変更セット内にバリデーションエラーがある場合は処理を抜ける
                result = detailContent.validation().validate();
                if (result.errors.length) {
                    return;
                }

                // 調味液にチェックがついている場合の必須チェック
                if (App.ifUndefOrNull($("[name ='flg_shorihin']:checked").val(), '0') == "1") {
                    if ($("[name ='dd_shomi']").val() == "") {
                        App.ui.page.notifyAlert.message(App.str.format(pageLangText.chomiCheck.text, pageLangText.dd_shomi.text), $("[name ='dd_shomi']")).show();
                        return;
                    }
                    if ($("[name ='kbn_hokan']").val() == "") {
                        App.ui.page.notifyAlert.message(App.str.format(pageLangText.chomiCheck.text, pageLangText.kbn_hokan.text), $("[name ='kbn_hokan']")).show();
                        return;
                    }
                }

                // 確認メッセージ
                showSaveConfirmDialog();
            });

            /// <summary>保存確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".save-confirm-dialog .dlg-yes-button").on("click", saveData);

            /// <summary>保存確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".save-confirm-dialog .dlg-no-button").on("click", closeSaveConfirmDialog);

            /// <summary>保存確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".save-complete-dialog .dlg-close-button").on("click", saveComplete);

            // コンテンツに変更が発生した場合は、
            $(".part-body").on("change", function () {
                isChanged = true;
            });

            // 3桁のカンマ区切りの値を取得
            function getThousandsSeparator(targetValue, comma) {
                // カンマとスペースを除去
                var value = getThousandsSeparatorDel(targetValue);
                // カンマ区切り
                while (value != (value = value.replace(/^(-?\d+)(\d{3})/, "$1,$2")));
                // 数値以外の場合
                if (isNaN(parseInt(value))) {
                    value = "";
                }
                else {
                    if (!App.isUndefOrNull(comma) && comma.length > 0) {
                        // 小数点以下のフォーマット
                        var _str = value.indexOf(".");
                        var _keta;
                        if (_str < 0) {
                            value = value + ".";
                            _keta = comma;
                        }
                        else {
                            _keta = comma - (value.length - _str - 1);
                        }
                        for (var i = 1; i <= _keta; i++) {
                            value = value + "0";
                        }
                    }
                }
                return value;
            }
            // 3桁のカンマ区切りを除外した値を取得
            function getThousandsSeparatorDel(value) {
                value = "" + value;
                // スペースとカンマを削除
                return value.replace(/^\s+|\s+$|,/g, "");
            }
            // 3桁のカンマ区切りの値をセット
            function setThousandsSeparator(target) {
                var value = $(target).val();
                var comma = $(target).attr("comma");
                value = getThousandsSeparator(value, comma);
                $(target).val(value);
            }
            // 入力項目変更時のイベント処理：数値のフォーマット
            $(".list-part-detail-content .format-thousands-Separator").on("change", function () {
                setThousandsSeparator(this);
            });

            ///<summary>データに変更があり、未保存の状態でページを離れる際に確認を行います。</summary>
            // 別画面に遷移したりするときに実行する関数の定義
            var onBeforeUnload = function () {
                //データを変更したかどうかは各画面でチェックし、保持する
                if (isChanged) {
                    return pageLangText.unloadWithoutSave.text;
                }
            }
            $(window).on('beforeunload', onBeforeUnload);   //beforeunloadイベントに関数を割り当て
            // formをsubmit（ログオフ）する場合、beforeunloadイベントを発生させないようにする
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

            // TODO ダイアログ情報メッセージの設定
            var clearConfirmDialogNotifyInfo = App.ui.notify.info(clearConfirmDialog, {
                container: ".clear-confirm-dialog .dialog-slideup-area .info-message",
                messageContainerQuery: "ul",
                show: function () {
                    clearConfirmDialog.find(".info-message").show();
                },
                clear: function () {
                    clearConfirmDialog.find(".info-message").hide();
                }
            });

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

            var saveCompleteDialogNotifyInfo = App.ui.notify.info(saveCompleteDialog, {
                container: ".save-complete-dialog .dialog-slideup-area .info-message",
                messageContainerQuery: "ul",
                show: function () {
                    saveCompleteDialog.find(".info-message").show();
                },
                clear: function () {
                    saveCompleteDialog.find(".info-message").hide();
                }
            });

            // ダイアログ警告メッセージの設定
            var clearConfirmDialogNotifyAlert = App.ui.notify.alert(clearConfirmDialog, {
                container: ".clear-confirm-dialog .dialog-slideup-area .alert-message",
                messageContainerQuery: "ul",
                show: function () {
                    clearConfirmDialog.find(".alert-message").show();
                },
                clear: function () {
                    clearConfirmDialog.find(".alert-message").hide();
                }
            });

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

            var saveCompleteDialogNotifyAlert = App.ui.notify.alert(saveCompleteDialog, {
                container: ".save-complete-dialog .dialog-slideup-area .alert-message",
                messageContainerQuery: "ul",
                show: function () {
                    saveCompleteDialog.find(".alert-message").show();
                },
                clear: function () {
                    saveCompleteDialog.find(".alert-message").show();
                }
            });

            var backToMenu = function () {
                // IEバグによる例外発生をキャッチします。例外発生時は何もしません。
                try {
                    document.location = "./MainMenu.aspx";
                } catch (e) {
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
                        <span class="item-label" style="width: 33%;">
                            <span data-app-text="no_han">
                            </span>
                            <label name="no_han"></label>
                        </span>
                        <span class="item-label" style="width: 33%;">
                            <span data-app-text="notUse" data-tooltip-text="notUse">
                            </span>
                            <input type="checkbox" name="flg_mishiyo" value="1"/>
                            <span data-app-text="flg_mishiyo"></span>
                        </span>
                        <label class="item-label" style="width: 33%;">
                            <span data-app-text="dt_create">
                            </span>
                            <span name="dt_create" readonly="readonly" tabindex="-1" class="data-app-format" data-app-format="datetime"></span>
                        </label>
                    </li>
                    <li>
                        <label class="item-label" style="width: 33%;">
                            <span data-app-text="dt_from">
                            </span>
                            <span name="dt_from" readonly="readonly" tabindex="-1" class="data-app-format" data-app-format="date"></span>～
                        </label>
                        <span  class="item-label" style="width: 33%;">
                        </span>
                        <label class="item-label" style="width: 33%;">
                            <span data-app-text="dt_update" >
                            </span>
                            <span name="dt_update" readonly="readonly" tabindex="-1" class="data-app-format" data-app-format="datetime"></span>
                        </label>
                    </li>
                </ul>
            </div>
        </div>
    </div>

    <!-- グリッドコントロール固有のデザイン -- Start -->
        <div class="part-body" id="result-grid">
            <div class="item-command">
                <button type="button" class="list-button" name="list-button"><span class="icon"></span><span data-app-text="list"></span></button>
            </div>
        </div>
        <!-- グリッドコントロール固有のデザイン -- End -->

    <!-- 検索結果一覧 -->
    <div class="content-part result-list">
        <!-- グリッドコントロール固有のデザイン -- Start -->
        <div class="part-body" id="detail-content">
            <div class="list-part-detail-content">
                <ul class="item-list item-list-left">
                    <!-- TODO: 画面の仕様に応じて以下の項目を変更してください。 -->
                    <li>
                        <label>
                            <span class="item-label" data-app-text="cd_haigo"></span><input type="text" id="id_cd_haigo" name="cd_haigo"　data-app-validation="cd_haigo"/>
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label nm_haigo_detail_ja" data-app-text="nm_haigo_ja" data-tooltip-text="nm_haigo_ja"></span><input type="text" name="nm_haigo_ja" data-app-validation="nm_haigo_ja" style="width: 280px;"/>
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label nm_haigo_detail_en" data-app-text="nm_haigo_en" data-tooltip-text="nm_haigo_en"></span><input type="text" name="nm_haigo_en" data-app-validation="nm_haigo_en" style="width: 280px;"/>
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label nm_haigo_detail_zh" data-app-text="nm_haigo_zh" data-tooltip-text="nm_haigo_zh"></span><input type="text" name="nm_haigo_zh" data-app-validation="nm_haigo_zh" style="width: 280px;"/>
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label nm_haigo_detail_vi" data-app-text="nm_haigo_vi" data-tooltip-text="nm_haigo_vi"></span><input type="text" name="nm_haigo_vi" data-app-validation="nm_haigo_vi" style="width: 280px;"/>
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="nm_haigo_ryaku"></span><input type="text" name="nm_haigo_ryaku" style="width: 280px;"/>
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="ritsu_budomari"></span><input type="text" name="ritsu_budomari" style="text-align: right" data-app-validation="ritsu_budomari"/><span>%</span>
                        </label>
                    </li>
                    <li>
                        <label>
                            <!--<span class="item-label" data-app-text="wt_kihon"></span><input type="text" name="wt_kihon" style="text-align: right" data-app-validation="wt_kihon"/>-->
                            <input type="hidden" name="wt_kihon"/>
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="ritsu_kihon"></span><input type="text" name="ritsu_kihon" style="text-align: right" data-app-validation="ritsu_kihon"/>
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="ritsu_hiju"></span><input type="text" name="ritsu_hiju" style="text-align: right" data-app-validation="ritsu_hiju"/>
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="wt_saidai_shikomi"></span><input type="text" class="format-thousands-Separator data-app-number" name="wt_saidai_shikomi" style="text-align: right" data-app-validation="wt_saidai_shikomi"/>
                        </label>
                    </li>
                    <!-- TODO: ここまで -->
                </ul>
                <ul class="item-list item-list-right clearfix">
                    <!-- TODO: 画面の仕様に応じて以下の項目を変更してください。 -->
                    <li>
                        <label>
                            <span class="item-label" data-app-text="nm_bunrui"></span>
                            <select name="cd_bunrui"></select>
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="shikomi_gassan" data-tooltip-text="shikomi_gassan"></span><input type="checkbox" name="flg_gassan_shikomi" value="1" />
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="kbn_kanzan"></span>
                            <label>
                                <input type="radio" name="kbn_kanzan" value="4" checked="checked"/><span class="item-label unit labelKg " data-app-text="labelKg" style="width:30px;"></span><span class="item-label unit labelLB " data-app-text="labelLB" style="width:30px;"></span>
                            </label>                           
                            <label>
                                <input type="radio" name="kbn_kanzan" value="11" /><span class="item-label unit labelL" data-app-text="labelL"></span><span class="item-label unit labelGAL" data-app-text="labelGAL"></span>
                            </label>                           
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="flg_shorihin"></span><input type="checkbox" name="flg_shorihin" value="1" />
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="lineSave"></span><label name="lineSave"></label>
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="flg_tenkai"></span><input type="checkbox" name="flg_tenkai" value="1" />
                        </label>
                    </li>



                    <li>
                        <label>
                            <span class="item-label" data-app-text="dd_shomi"></span>
                            <input type="text" name="dd_shomi" style="text-align: right; width:156px;" data-app-validation="dd_shomi"/>
                            <span class="item-label" data-app-text="labelDay"></span>
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="kbn_hokan"></span>
                            <select name="kbn_hokan"></select>
                        </label>
                    </li>

                    <li>
                        <input type="hidden" name="wt_haigo"/>
                    </li>
                    <li>
                        <input type="hidden" name="wt_haigo_gokei"/>
                    </li>
                    <li>
                        <input type="hidden" name="biko"/>
                    </li>
                    <li>
                        <input type="hidden" name="no_seiho"/>
                    </li>
                    <li>
                        <input type="hidden" name="cd_tanto_seizo"/>
                    </li>
                    <li>
                        <input type="hidden" name="dt_seizo_koshin"/>
                    </li>
                    <li>
                        <input type="hidden" name="cd_tanto_hinkan"/>
                    </li>
                    <li>
                        <input type="hidden" name="dt_hinkan_koshin"/>
                    </li>
                    <li>
                        <input type="hidden" name="flg_tanto_hinkan"/>
                    </li>
                    <li>
                        <input type="hidden" name="flg_tanto_seizo"/>
                    </li>
                    <li>
                        <input type="hidden" name="kbn_shiagari"/>
                    </li>
                    <li>
                        <input type="hidden" name="cd_create"/>
                    </li>
                    <li>
                        <input type="hidden" name="cd_update"/>
                    </li>
                    <li>
                        <input type="hidden" name="wt_kowake"/>
                    </li>
                    <li>
                        <input type="hidden" name="su_kowake"/>
                    </li>
                    <li>
                        <input type="hidden" name="ts"/>
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
        <button type="button" class="lineSave-button" name="lineSave-button" data-app-operation="lineSave"><span data-app-text="lineSave"></span></button>
        <button type="button" class="recipe-button" name="recipe-button" data-app-operation="recipe"><span data-app-text="recipe"></span></button>
        <button type="button" class="clear-button" name="clear-button" data-app-operation="clear">
            <span class="icon"></span>
            <span data-app-text="clear"></span>
        </button>
        <!-- TODO: ここまで -->
    </div>
    <div class="command" style="right: 9px;">
    </div>
    <div class="command" style="right: 9px;">
        <button type="button" class="menu-button" name="menu-button">
            <span class="icon"></span>
            <span data-app-text="menu"></span>
        </button>
    </div>
    <!-- 画面アーキテクチャ共通のデザイン -- End -->

    <!-- ダイアログ固有のデザイン -- Start -->

    <!-- TODO: 画面の仕様に応じて以下のダイアログの設定を変更してください。 -->
    <div class="clear-confirm-dialog" style="display: none;">
        <div class="dialog-header">
            <h4 data-app-text="confirmTitle"></h4>
        </div>
        <div class="dialog-body" style="padding: 10px; width: 100%;">
            <div class="part-body">
                <span data-app-text="clearConfirm"></span>
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
    <div class="save-confirm-dialog" style="display: none;">
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
    <div class="save-complete-dialog" style="display: none;">
        <div class="dialog-header">
            <h4 data-app-text="confirmTitle"></h4>
        </div>
        <div class="dialog-body" style="padding: 10px; width: 100%;">
            <div class="part-body">
                <span data-app-text="saveComplete"></span>
            </div>
        </div>
        <div class="dialog-footer">
            <div class="command" style="text-align:left; padding-left: 5px; padding-top: 5px;">
                <button class="dlg-close-button" name="dlg-close-button" data-app-text="close"></button>
            </div>
        </div>
    </div>
    <!-- TODO: ここまで  -->

    <!-- 画面デザイン -- End -->
</asp:Content>
