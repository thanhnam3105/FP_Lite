<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="LineMitorokuIchiran.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.LineMitorokuIchiran" %>

<asp:Content ID="Content1" ContentPlaceHolderID="IncludeContent" runat="server">
    <script src="<%=ResolveUrl("~/Resources/pages/pagedata-linemitorokuichiran." + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
    <script src="<%=ResolveUrl("~/Resources/grid/grid.locale-" + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        /* 画面デザイン -- Start */
        
        /* TODO：画面の仕様に応じて以下のスタイルを変更してください。 */
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
                querySetting = { skip: 0, top: 500, count: 0 },
                isDataLoading = false;

            // グリッドコントロール固有の変数宣言
            var grid = $("#item-grid");
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            firstCol = 1,
            currentRow = 0,
            hinmeiName = 'nm_hinmei_' + App.ui.page.lang;
            // TODO: ここまで

            //// 変数宣言 -- End

            //// コントロール定義 -- Start

            // グリッドコントロール固有のコントロール定義
            grid.jqGrid({
                // TODO：画面の仕様に応じて以下の列名の定義を変更してください。
                colNames: [
                    pageLangText.cd_hinmei.text
                    , pageLangText.nm_hinmei.text
                ],
                // TODO：画面の仕様に応じて以下の列モデルの定義を変更してください。
                colModel: [
                    { name: 'cd_hinmei', width: 120, sorttype: "text", frozen: true, resizable: false },
                    { name: hinmeiName, width: 320, sorttype: "text", frozen: true, resizable: true }
                ],
                // TODO：ここまで
                datatype: "local",
                shrinkToFit: false,
                multiselect: false,
                rownumbers: true
            });

            //// コントロール定義 -- End

            //// 操作制御定義 -- Start
            // 操作制御定義を定義します。
            App.ui.pagedata.operation.applySetting(App.ui.page.user.Roles[0], App.ui.page.lang);
            //// 操作制御定義 -- End

            //// 事前データロード -- Start 
            // TODO: 画面の仕様に応じて以下の処理を変更してください。
            var masterKubun = pageLangText.masterKubunId.data;
            // 検索用ドロップダウンの設定
            App.ui.appendOptions($(".search-criteria [name='masterKubun']"), "id", "name", masterKubun, false);
            //// 事前データロード -- End

            //// 検索処理 -- Start

            // 画面アーキテクチャ共通の検索処理
            /// <summary>クエリオブジェクトの設定</summary>
            var query = function () {
                var criteria = $(".search-criteria").toJSON(),
                    kbnSeizoLineMaster = criteria.masterKubun;
                if (kbnSeizoLineMaster === pageLangText.hinmeiMasterSeizoLineMasterKbn.text) {
                    var controllerName = "LineMitorokuHinmei";
                } else if (kbnSeizoLineMaster === pageLangText.haigoMasterSeizoLineMasterKbn.text) {
                    var controllerName = "LineMitorokuHaigo";
                }
                var query = {
                    // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                    url: "../api/" + controllerName
                    , flg_mishiyo: pageLangText.shiyoMishiyoFlg.text
		            , kbn_master: kbnSeizoLineMaster
		            , searchHan: pageLangText.hanNoShokichi.text
                    , kbn_seihin: pageLangText.seihinHinKbn.text
                    , kbn_jikagen: pageLangText.jikaGenryoHinKbn.text
                    // TODO: ここまで
                    , skip: querySetting.skip
                    , top: querySetting.top
                }
                return query;
            };
            /// <summary>フィルター条件の設定</summary>
            var createFilter = function () {
                var criteria = $(".search-criteria").toJSON(),
                    filters = [];
                // TODO: 画面の仕様に応じて以下のフィルター条件を変更してください。
                // TODO: ここまで
                return filters.join(" and ");
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
                    App.data.toWebAPIFormat(query)
                ).done(function (result) {
                    if (parseInt(result.__count) === 0) {
                        App.ui.page.notifyAlert.message(MS0037).show();
                    } else {
                        // データバインド
                        bindData(result);
                        // グリッドの先頭行選択
                        grid.setSelection(firstCol, false);
                        // 検索条件を閉じる
                        closeCriteria();
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
            /// <summary>検索条件を閉じます。</summary>
            var closeCriteria = function () {
                var criteria = $(".search-criteria");
                if (!criteria.find(".part-body").is(":hidden")) {
                    criteria.find(".search-part-toggle").click();
                }
            };
            /// <summary>検索ボタンクリック時のイベント処理を行います。</summary>
            $(".find-button").on("click", function () {
                clearState();
                searchItems(new query());
            });

            // グリッドコントロール固有の検索処理

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
                // TODO: ここまで

                // 情報メッセージのクリア
                App.ui.page.notifyInfo.clear();
                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();
            };
            /// <summary>データ取得件数を表示します。</summary>
            var displayCount = function (resultCount) {
                $("#list-count").text(
                     App.str.format("{0}/{1} " + pageLangText.itemCount.text, querySetting.count, resultCount)
                );
            };

            /// <summary>データをバインドします。</summary>
            /// <param name="result">検索結果</param>
            var bindData = function (result) {
                // グリッドの表示件数を更新
                grid.setGridParam({ rowNum: querySetting.top });
                var resultCount = parseInt(result.__count);
                if (resultCount > querySetting.top) {
                    App.ui.page.notifyInfo.message(
                                    App.str.format(MS0568, querySetting.count, querySetting.count)).show();
                    querySetting.count = querySetting.top;
                }
                else {
                    querySetting.count = resultCount;
                }
                displayCount(resultCount);
                // データバインド
                var currentData = grid.getGridParam("data").concat(result.d);
                grid.setGridParam({ data: currentData }).trigger('reloadGrid', [{ current: true}]);
                App.ui.page.notifyInfo.message(
                                 App.str.format(pageLangText.searchResultCount.text, querySetting.count, resultCount)
                            ).show();
            };

            //// 検索処理 -- End

            //// コントロール定義 -- Start

            //// コントロール定義 -- End

            //// メッセージ表示 -- Start

            //// メッセージ表示 -- End

            //// データ変更処理 -- Start
            /// <summary>グリッドの選択行の行IDを取得します。 </summary>
            var getSelectedRowId = function () {
                var selectedRowId = grid.getGridParam("selrow"),
                    ids = grid.getDataIDs(),
                    recordCount = grid.getGridParam("records");
                // レコードがない場合は処理を抜ける
                if (recordCount == 0) {
                    App.ui.page.notifyInfo.message(pageLangText.noRecords.text).show();
                    return;
                }
                // 選択行なしの場合の行選択
                if (App.isUnusable(selectedRowId)) {
                    selectedRowId = ids[0]; // 先頭行
                }
                currentRow = $('#' + selectedRowId)[0].rowIndex;

                return selectedRowId;
            };

            //// データ変更処理 -- End

            //// 保存処理 -- Start

            //// 保存処理 -- End

            //// バリデーション -- Start
            //// バリデーション -- End

            /// <summary>ページ遷移を行います。</summary>
            /// <param name="pageFileName">遷移先ファイル名</param>
            var navigate = function (pageFileName) {
                var criteria = $(".search-criteria").toJSON(),
                    kbnSeizoLineMaster = criteria.masterKubun,
                    selectedRowId = getSelectedRowId();
                // データが存在しない場合処理を抜ける
                if (App.isUndefOrNull(selectedRowId)) {
                    return;
                }
                // 選択行のデータ取得
                var row = grid.jqGrid("getRowData", selectedRowId);
                // 遷移先のurl設定
                var url = "./" + pageFileName + ".aspx";
                // TODO: 画面遷移時に渡すパラメータを設定
                url += "?cdHaigo=" + row.cd_hinmei;
                url += "&kbnHaigo=" + kbnSeizoLineMaster;
                // TODO: ここまで
                window.location = url;
            };

            /// <summary>ライン登録ボタンクリック時のイベント処理を行います。</summary>
            $(".lineSave-button").on("click", function () {
                navigate("SeizoLineMaster")
            });


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
                    resultPartStyle = resultPart[0].currentStyle || document.defaultView.getComputedStyle(resultPart[0], "");

                resultPart.height(container[0].clientHeight - searchPart[0].clientHeight - ((parseInt(resultPartStyle.marginTop, 10) * 3) || 0));
                grid.setGridWidth(resultPart[0].clientWidth - 5);
                //結果一覧のパートの高さ - パートのヘッダーの高さ - パート内のボタンのコマンドの高さ - jqGrid のカラムヘッダーの高さ
                grid.setGridHeight(resultPart[0].clientHeight - resultPartHeader[0].clientHeight - resultPart.find(".ui-jqgrid-hdiv")[0].clientHeight - 35);
            };
            /// <summary>画面リサイズ時のイベント処理を行います。</summary>
            $(App.ui.page).on("resized", resizeContents);

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

    <!-- 検索条件と検索ボタン -->
    <div class="content-part search-criteria">
        <h3 class="part-header" data-app-text="searchCriteria"><a class="search-part-toggle" href="#"></a></h3>
        <div class="part-body">
            <ul class="item-list">
                <!-- TODO: 画面の仕様に応じて以下の検索条件を変更してください。-->
                <li>
                    <label>
                        <span class="item-label" data-app-text="masterKubun"></span>
                        <select name="masterKubun" id="condition-masterKubun"></select>
                    </label>
                </li>
                <!-- TODO: ここまで -->
            </ul>
        </div>
        <div class="part-footer">
            <div class="command">
                <button type="button" class="find-button" data-app-operation="search">
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
            <span data-app-text="resultList" style="padding-right: 10px; padding-bottom: 4px;" id="list-results" ></span>
            <span class="list-count" id="list-count" ></span>
            <span style="padding-left: 50px;" class="list-loading-message" id="list-loading-message" ></span>
        </h3>
        <div class="part-body" id="result-grid">
            <div class="list-part-grid-content">
                <table id="item-grid">
                </table>
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
        <button type="button" class="lineSave-button" data-app-operation="lineSave" name="lineSave-button"><span data-app-text="lineSave"></span></button>
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
    <!-- TODO: ここまで  -->
    <!-- ダイアログ固有のデザイン -- End -->
    <!-- 画面デザイン -- End -->
</asp:Content>
<asp:Content ID="Content5" ContentPlaceHolderID="DialogsContent" runat="server">
    <!-- 画面デザイン -- Start -->
    <!-- 画面デザイン -- End -->
</asp:Content>
