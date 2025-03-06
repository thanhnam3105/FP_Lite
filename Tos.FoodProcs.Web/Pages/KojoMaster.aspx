<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="KojoMaster.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.KojoMaster" %>

<asp:Content ID="Content1" ContentPlaceHolderID="IncludeContent" runat="server">
    <script src="<%=ResolveUrl("~/Resources/pages/pagedata-kojomaster." + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
    <script src="<%=ResolveUrl("~/Resources/grid/grid.locale-" + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        /* 画面デザイン -- Start */
        
        /* TODO：画面の仕様に応じて以下のスタイルを変更してください。 */        
        .item-label {
            width: 8em;
        }
               
        .list-part-detail-content .item-list-left {
            float: left;
            width: 500px;
        }
        
        .list-part-detail-content .item-list-right {
            margin-left: 500px;
            width: 500px;
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

        .list-part-detail-content .item-label {
            width: 15em;
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
                isDataLoading = false;

            // グリッドコントロール固有の変数宣言
            var grid = $("#item-grid"),
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
                lastScrollTop = 0,
                firstCol = 1,
                isChanged = false;

            // 画面固有の変数宣言
            var haigoKeisanHoho;
            // TODO: ここまで

            //// 変数宣言 -- End

            //// コントロール定義 -- Start

            // グリッドコントロール固有のコントロール定義

            /// <summary>詳細を表示します。</summary>
            var showDetail = function (isAdd) {
                if (App.ui.page.user.Roles[0] == "Manufacture" || App.ui.page.user.Roles[0] == "Quality" || App.ui.page.user.Roles[0] == "Warehouse") {
                    return;
                }

                var selectedRowId = grid.jqGrid("getGridParam", "selrow"),
                    detailContent = $(".list-part-detail-content"),
                    gridContent = $(".list-part-grid-content"),
                    row;

                if (App.isUnusable(selectedRowId)) {
                    return;
                }
                row = grid.jqGrid("getRowData", selectedRowId);

                // TODO：画面の仕様に応じて以下の詳細の項目の設定を変更してください。
                /*
                row.CategoryCode = row.CategoryMaster_CategoryCode;
                row.CategoryName = row.CategoryMaster_CategoryName;
                row.ArticleDivisionCD = row.ArticleDivisionMaster_ArticleDivisionCD;
                row.ArticleDivisionName = row.ArticleDivisionMaster_ArticleDivisionName;
                row.FacilitiesCD = row.FacilitiesMaster_FacilitiesCD;
                row.FacilitiesName = row.FacilitiesMaster_FacilitiesName;
                delete row.CategoryMaster_CategoryCode;
                delete row.CategoryMaster_CategoryName;
                delete row.ArticleDivisionMaster_ArticleDivisionCD;
                delete row.ArticleDivisionMaster_ArticleDivisionName;
                delete row.FacilitiesMaster_FacilitiesCD;
                delete row.FacilitiesMaster_FacilitiesName;
                */
                // TODO：ここまで

                App.ui.page.notifyAlert.clear();

                // グリッドを非表示にして詳細を表示します。
                gridContent.hide("fast", function () {
                    detailContent.toForm(row);
                    detailContent.show("fast");

                    $("#list-results").hover(
                        function () {
                            $("#list-results").css("cursor", "pointer");
                            $(this).css("background-color", "#87cefa");
                        },
                        function () {
                            $("#list-results").css("cursor", "default");
                            $(this).css("background-color", "#efefef");
                        }
                    );

                    $("#list-count").before("<span class='list-arrow' id='list-arrow'></span>");
                    $("#list-count").text(row.CombinationCD);
                    $("#list-results").on("click", showGrid);
                });
            };

            /// <summary>グリッドを表示します。</summary>
            var showGrid = function () {
                var d = $.Deferred();
                App.ui.page.notifyAlert.clear();

                // 詳細を非表示にしてグリッドを表示します。
                $(".list-part-detail-content").hide("fast", function () {
                    $(".list-part-grid-content").show("fast");
                    $("#list-count").text(
                        App.str.format("{0}/{1}" + pageLangText.itemCount.text, querySetting.skip, querySetting.count)
                    );

                    $("#list-arrow").remove();
                    $('#list-results').unbind('hover');
                    $('#list-results').unbind('click');
                    $('#list-results').css("cursor", "default");
                    $('#list-results').css("background-color", "#efefef");
                    d.resolve();

                });

                return d.promise();
            };

            // ダイアログ固有の変数宣言 -- Start
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            var saveConfirmDialog = $(".save-confirm-dialog"),
                saveCompleteDialog = $(".save-complete-dialog");
            // TODO：ここまで

            //// 変数宣言 -- End

            //// コントロール定義 -- Start

            // ダイアログ固有のコントロール定義
            saveConfirmDialog.dlg();
            saveCompleteDialog.dlg();

            /// <summary>ダイアログを開きます。</summary>
            var showSaveConfirmDialog = function () {
                saveConfirmDialogNotifyInfo.clear();
                saveConfirmDialogNotifyAlert.clear();
                saveConfirmDialog.draggable(true);
                saveConfirmDialog.dlg("open");
            };
            var showSaveCompleteDialog = function () {
                saveCompleteDialogNotifyInfo.clear();
                saveCompleteDialogNotifyAlert.clear();
                saveCompleteDialog.draggable(true);
                saveCompleteDialog.dlg("open");
            };

            /// <summary>ダイアログを閉じます。</summary>
            var closeSaveConfirmDialog = function () {
                saveConfirmDialog.dlg("close");
            };
            var closeSaveCompleteDialog = function () {
                saveCompleteDialog.dlg("close");
            };

            // ダイアログ固有の変数宣言 -- End
            if (App.ui.page.langCountry !== 'en-US') {
                var newDateFormat = pageLangText.dateNewFormat.text;
            } else {
                var newDateFormat = pageLangText.dateNewFormatUS.text;
            }
            grid.jqGrid({
                // TODO：画面の仕様に応じて以下の列名の定義を変更してください。
                colNames: [
                    pageLangText.cd_kojo.text,
                    pageLangText.nm_kojo.text,
                    pageLangText.dt_nendo_start.text,
                    pageLangText.no_yubin1.text, pageLangText.no_yubin2.text,
                    pageLangText.jusho_1.text, pageLangText.jusho_2.text, pageLangText.jusho_3.text,
                    pageLangText.tel_1.text, pageLangText.tel_2.text,
                    pageLangText.fax_1.text, pageLangText.fax_2.text,
                    pageLangText.kbn_haigo_keisan_hoho.text,
                    pageLangText.nm_kbn_haigo_keisan_hoho.text,
                    pageLangText.dt_kigen_chokuzen.text,
                    pageLangText.dt_kigen_chikai.text,
                    pageLangText.no_com_reader_niuke.text,
                    pageLangText.dt_toroku.text,
                    pageLangText.dt_henko.text,
                    pageLangText.ts.text,
                    pageLangText.cd_toroku.text,
                    pageLangText.cd_kaisha.text
                ],
                // TODO：画面の仕様に応じて以下の列モデルの定義を変更してください。
                colModel: [
                    { name: 'cd_kojo', width: pageLangText.cd_kojo_width.number, hidden: false, sortable: false, frozen: true, resizable: false },
                    { name: 'nm_kojo', width: pageLangText.nm_kojo_width.number, hidden: false, sortable: false, frozen: true, resizable: false },
                    { name: 'dt_nendo_start', width: pageLangText.dt_nendo_start_width.number, align: "center", hidden: false, sorttype: "date" },
                    { name: 'no_yubin1', width: pageLangText.no_yubin1_width.number, hidden: false, sortable: false },
                    { name: 'no_yubin2', width: pageLangText.no_yubin2_width.number, hidden: false, sortable: false },
                    { name: 'nm_jusho_1', width: pageLangText.nm_jusho_1_width.number, hidden: false, sortable: false },
                    { name: 'nm_jusho_2', width: pageLangText.nm_jusho_2_width.number, hidden: false, sortable: false },
                    { name: 'nm_jusho_3', width: pageLangText.nm_jusho_3_width.number, hidden: false, sortable: false },
                    { name: 'no_tel_1', width: pageLangText.no_tel_1_width.number, hidden: false, sortable: false },
                    { name: 'no_tel_2', width: pageLangText.no_tel_2_width.number, hidden: false, sortable: false },
                    { name: 'no_fax_1', width: pageLangText.no_fax_1_width.number, hidden: false, sortable: false },
                    { name: 'no_fax_2', width: pageLangText.no_fax_2_width.number, hidden: false, sortable: false },
                    { name: 'kbn_haigo_keisan_hoho', width: pageLangText.kbn_haigo_keisan_hoho_width.number, hidden: true, sortable: false },
                    { name: 'nm_kbn_haigo_keisan_hoho', width: pageLangText.nm_kbn_haigo_keisan_hoho_width.number, hidden: false, sortable: false },
                    { name: 'dt_kigen_chokuzen', width: pageLangText.dt_kigen_chokuzen_width.number, align: "right", hidden: false, sortable: false },
                    { name: 'dt_kigen_chikai', width: pageLangText.dt_kigen_chikai_width.number, align: "right", hidden: false, sortable: false },
                    { name: 'no_com_reader_niuke', width: pageLangText.no_com_reader_niuke_width.number, align: "right", hidden: false, sortable: false },
                    { name: 'dt_create', width: pageLangText.dt_create_width.number, hidden: false, sortable: false,
                        formatter: "date",
                        formatoptions: {
                            srcformat: newDateFormat, newformat: newDateFormat
                        }
                    },
                    { name: 'dt_update', width: pageLangText.dt_update_width.number, hidden: false, sortable: false,
                        formatter: "date",
                        formatoptions: {
                            srcformat: newDateFormat, newformat: newDateFormat
                        }
                    },
                    { name: 'ts', width: 0, hidden: true, hidedlg: true },
                    { name: 'cd_create', width: 0, hidden: true, hidedlg: true },
                    { name: 'cd_kaisha', width: 0, hidden: true, hidedlg: true }
                ],
                // TODO：ここまで
                datatype: "local",
                shrinkToFit: false,
                multiselect: false,
                rownumbers: true,
                ondblClickRow: function (selectedRowId) {
                    showDetail(false);
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

            //// 操作制御定義
            App.ui.pagedata.operation.applySetting(App.ui.page.user.Roles[0], App.ui.page.lang);

            //// 事前データロード -- Start 

            // 画面アーキテクチャ共通の事前データロード
            App.deferred.parallel({
                haigoKeisanHoho: App.ajax.webget("../Services/FoodProcsService.svc/ma_kbn_haigo_keisan_hoho?$filter=flg_mishiyo eq "
                    + pageLangText.shiyoMishiyoFlg.text + "&$orderby=kbn_haigo_keisan_hoho")
            }).done(function (result) {
                haigoKeisanHoho = result.successes.haigoKeisanHoho.d;
                App.ui.appendOptions($(".list-part-detail-content [name='kbn_haigo_keisan_hoho']"), "kbn_haigo_keisan_hoho", "nm_kbn_haigo_keisan_hoho", haigoKeisanHoho, false);
                //App.ui.appendOptions($(".list-part-detail-content [name='kbn_kuraire']"), "kbn_kuraire", "nm_kbn_kuraire", kuraireKubun, false);
                setLiteral("dt_nendo_start", pageLangText.dt_nendo_start.text, true);
                setLiteral("dt_kigen_chokuzen", pageLangText.dt_kigen_chokuzen.text, true);
                setLiteral("dt_kigen_chikai", pageLangText.dt_kigen_chikai.text, true);
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

            // リテラルの必須マークの制御（詳細画面）
            var setLiteral = function (komoku, text, flg) {
                var lbl = $(".list-part-detail-content [name=" + komoku + "]").prev();
                if (flg) {
                    lbl.html(text + "*");
                }
                else {
                    lbl.html(text);
                }
            };

            //// 事前データロード -- End

            //// 検索処理 -- Start

            // 画面アーキテクチャ共通の検索処理

            /// <summary>クエリオブジェクトの設定</summary>
            var query = function () {
                var query = {
                    // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                    url: "../Services/FoodProcsService.svc/vw_ma_kojo_01",
                    // TODO: ここまで
                    filter: createFilter(),
                    // TODO: 画面の仕様に応じて以下のソート条件を変更してください。
                    orderby: "cd_kojo",
                    // TODO: ここまで
                    skip: querySetting.skip,
                    top: querySetting.top,
                    inlinecount: "allpages"
                }
                return query;
            };
            /// <summary>フィルター条件の設定</summary>
            var createFilter = function () {
                var filters = [];

                // TODO: 画面の仕様に応じて以下のフィルター条件を変更してください。
                if (!App.isUndefOrNull(App.ui.page.user.KaishaCode) && App.ui.page.user.KaishaCode.length > 0) {
                    filters.push("cd_kaisha eq '" + App.ui.page.user.KaishaCode + "'");
                }
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
                $("#list-loading-message").text(pageLangText.nowLoading.text);
                App.ajax.webget(
                // WCF Data ServicesのODataシステムクエリオプションを生成
                    App.data.toODataFormat(query)
                ).done(function (result) {
                    // データバインド
                    bindData(result);
                    //グリッドの先頭行選択
                    grid.setSelection(firstCol, false);
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                }).always(function () {
                    setTimeout(function () {
                        $("#list-loading-message").text("");
                        isDataLoading = false;
                    }, 500);
                });
            };

            // グリッドコントロール固有の検索処理
            /// <summary>データ取得件数を表示します。</summary>
            var displayCount = function () {
                $("#list-count").text(
                     App.str.format("{0}/{1}" + pageLangText.itemCount.text, querySetting.skip, querySetting.count)
                );
            };
            /// <summary>データをバインドします。</summary>
            /// <param name="result">検索結果</param>
            var bindData = function (result) {
                querySetting.skip = querySetting.skip + result.d.results.length;
                querySetting.count = parseInt(result.d.__count);
                // グリッドの表示件数を更新
                grid.setGridParam({ rowNum: querySetting.skip });
                displayCount();
                // カラムの固定解除
                grid.destroyFrozenColumns();
                // データバインド
                var currentData = grid.getGridParam("data").concat(result.d.results);
                grid.setGridParam({ data: currentData });
                // カラムの固定
                grid.setFrozenColumns().trigger('reloadGrid', [{ current: true}]);
                App.ui.page.notifyInfo.message(
                     App.str.format(pageLangText.searchResultCount.text, querySetting.skip, querySetting.count)
                ).show();
            };
            /// <summary>後続データ検索を行います。</summary>
            /// <param name="target">グリッド</param>
            //var nextSearchItems = function (target) {
            //    var scrollTop = lastScrollTop;
            //    if (scrollTop == target.scrollTop) {
            //        return;
            //    }
            //    if (querySetting.skip === querySetting.count) {
            //        return;
            //    }
            //    lastScrollTop = target.scrollTop;
            //    if (target.scrollHeight - target.scrollTop <= $(target).outerHeight()) {
            //        // データ検索
            //        searchItems(new query());
            //    }
            //};
            /// <summary>グリッドスクロール時のイベント処理を行います。</summary>
            //$(".ui-jqgrid-bdiv").scroll(function (e) {
            //    // 後続データ検索
            //    nextSearchItems(this);
            //});

            //// 検索処理 -- End

            //// メッセージ表示 -- Start

            //// メッセージ表示 -- End

            //// データ変更処理 -- Start

            /// <summary>新規行データの設定を行います。</summary>

            //// データ変更処理 -- End

            //// 保存処理 -- Start

            // グリッド固有の保存処理

            /// <summary>検索前の状態に初期化します。</summary>
            var clearState = function () {
                // データクリア
                grid.clearGridData();
                lastScrollTop = 0;
                querySetting.skip = 0;
                querySetting.count = 0;
                displayCount();
                isChanged = false;

                // TODO: 画面の仕様に応じて以下のパラメータ設定を変更してください。
                // TODO: ここまで

                // 情報メッセージのクリア
                App.ui.page.notifyInfo.clear();
                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();
            };

            // ダイアログ固有のメッセージ表示

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
                container: ".save-Complete-dialog .dialog-slideup-area .alert-message",
                messageContainerQuery: "ul",
                show: function () {
                    saveCompleteDialog.find(".alert-message").show();
                },
                clear: function () {
                    saveCompleteDialog.find(".alert-message").hide();
                }
            });

            //// メッセージ表示 -- End

            /// <summary>データ変更エラーハンドリングを行います。</summary>
            /// <param name="result">エラーの戻り値</param>
            var handleSaveDataError = function (result) {
                var ret = JSON.parse(result.rawText);

                if (!App.isArray(ret) && App.isUndefOrNull(ret.Updated) && App.isUndefOrNull(ret.Deleted)) {
                    App.ui.page.notifyAlert.message(result.message).show();
                    return;
                }
                // 更新時同時実行制御エラーのハンドリングを行います。
                if (!App.isUndefOrNull(ret.Updated) && ret.Updated.length > 0) {
                    var upCurrent = ret.Updated[0].Current;
                    // 他のユーザーによって削除されていた場合
                    if (App.isUndefOrNull(upCurrent)) {
                        // メッセージの表示
                        App.ui.page.notifyAlert.message(
                            pageLangText.duplicate.text + pageLangText.deletedDuplicate.text).show();
                    }
                    else {
                        detailContent = $(".list-part-detail-content");
                        // TODO: 画面の仕様に応じて更新後のデータ状態をセットします
                        var data = {
                            "cd_kojo": upCurrent.cd_kojo,
                            "nm_kojo": upCurrent.nm_kojo,
                            "dt_nendo_start": upCurrent.dt_nendo_start,
                            "no_yubin1": upCurrent.no_yubin1,
                            "no_yubin2": upCurrent.no_yubin2,
                            "nm_jusho_1": upCurrent.nm_jusho_1,
                            "nm_jusho_2": upCurrent.nm_jusho_2,
                            "nm_jusho_3": upCurrent.nm_jusho_3,
                            "no_tel_1": upCurrent.no_tel_1,
                            "no_tel_2": upCurrent.no_tel_2,
                            "no_fax_1": upCurrent.no_fax_1,
                            "no_fax_2": upCurrent.no_fax_2,
                            "kbn_haigo_keisan_hoho": upCurrent.kbn_haigo_keisan_hoho,
                            "nm_kbn_haigo_keisan_hoho": upCurrent.kbn_haigo_keisan_hoho,
                            "dt_kigen_chokuzen": upCurrent.dt_kigen_chokuzen,
                            "dt_kigen_chikai": upCurrent.dt_kigen_chikai,
                            "no_com_reader_niuke": upCurrent.no_com_reader_niuke,
                            "dt_create": upCurrent.dt_create,
                            "dt_update": upCurrent.dt_update,
                            "ts": upCurrent.ts,
                            "cd_update": upCurrent.cd_update,
                            "cd_kaisha": upCurrent.cd_kaisha
                        };
                        // TODO: ここまで

                        // カレントのデータを詳細画面へ表示
                        detailContent.toForm(data);
                        /*
                        App.ui.page.notifyAlert.message(App.str.format(pageLangText.noHinmeiCd.text,
                        pageLangText.cd_hinmei.text), cd_hinmei).show();
                        */
                        // エラーメッセージの表示
                        App.ui.page.notifyAlert.message(App.str.format(pageLangText.duplicate.text + pageLangText.updatedDuplicate.text)).show();
                    }
                }
            };

            /// <summary>保存前のチェック処理を行います。</summary>
            /// <param name="e">イベントデータ</param>
            var saveCheck = function (e) {

                // 情報メッセージのクリア
                App.ui.page.notifyInfo.clear();
                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();

                // 変更がない場合は処理を抜ける
                if (!isChanged) {
                    App.ui.page.notifyInfo.message(pageLangText.noChange.text).show();
                    return;
                }
                var detailContent = $(".list-part-detail-content"),
                    result;
                // 変更セット内にバリデーションエラーがある場合は処理を抜ける
                result = detailContent.validation().validate();
                if (result.errors.length) {
                    return;
                }

                // エラー一覧クリック用ユニークキー
                var uniqueChokuzen = $("#id_dt_kigen_chokuzen");
                var uniqueTikai = $("#id_dt_kigen_chikai");
                // 期限切れ直前日数　<　期限切れ近い日数であること
                var chokuzen = parseInt(uniqueChokuzen.val()),
                    chikai = parseInt($("#id_dt_kigen_chikai").val());
                if (chokuzen >= chikai) {
                    setErrorMessage(uniqueChokuzen);
                    setErrorMessage(uniqueTikai);
                    return;
                }
                // 確認メッセージ
                showSaveConfirmDialog();
            };
            /// <summary>変更を保存します。</summary>
            /// <param name="e">イベントデータ</param>
            var saveData = function (e) {
                closeSaveConfirmDialog();

                // ローディングの表示
                App.ui.loading.show(pageLangText.nowSaving.text);

                // 更新データをJSONオブジェクトに変換
                var detailContent = $(".list-part-detail-content");
                var postData = detailContent.toJSON();

                // TODO: 画面の仕様に応じて以下の項目を変更してください。
                postData["cd_update"] = App.ui.page.user.Code;
                //postData["dt_update"] = new Date();
                // TODO: ここまで
                var changeSet = new App.ui.page.changeSet();

                // TODO: 画面の仕様に応じて新規/更新にて処理を変更してください。
                changeSet.addUpdated(App.uuid, null, null, postData);
                // TODO: ここまで
                var data = changeSet.getChangeSet();

                // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                var saveUrl = "../api/KojoMaster";
                // TODO: ここまで
                App.ajax.webpost(
                    saveUrl, data
                ).done(function (result) {
                    // 保存終了メッセージ
                    showSaveCompleteDialog();
                }).fail(function (result) {
                    // データ変更エラーハンドリングを行います。
                    handleSaveDataError(result);
                }).always(function () {
                    // ローディングの終了
                    App.ui.loading.close();
                });
                // TODO: ここまで
            };

            //// 保存処理 -- End

            //// バリデーション -- Start

            // 枠線をエラー状態にする
            var setErrorMessage = function (targetId) {
                App.ui.page.notifyAlert.message(
                        App.str.format(pageLangText.checkDateKigen.text
                            , pageLangText.dt_kigen_chikai.text
                            , pageLangText.dt_kigen_chokuzen.text
                        ), targetId
                    ).show();
            };

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

            /// <summary>コンテンツのリサイズを行います。</summary>
            var resizeContents = function (e) {
                var container = $(".content-container"),
                    resultPart = $(".result-list"),
                    resultPartHeader = resultPart.find(".part-header"),
                    resultPartCommands = resultPart.find(".item-command"),
                    resultPartStyle = resultPart[0].currentStyle || document.defaultView.getComputedStyle(resultPart[0], "");

                resultPart.height(container[0].clientHeight - ((parseInt(resultPartStyle.marginTop, 10) * 3) || 0));
                grid.setGridWidth(resultPart[0].clientWidth - 5);
                //結果一覧のパートの高さ - パートのヘッダーの高さ - パート内のボタンのコマンドの高さ - jqGrid のカラムヘッダーの高さ
                grid.setGridHeight(resultPart[0].clientHeight - resultPartHeader[0].clientHeight - resultPartCommands[0].clientHeight - resultPart.find(".ui-jqgrid-hdiv")[0].clientHeight - 35);
            };
            /// <summary>画面リサイズ時のイベント処理を行います。</summary>
            $(App.ui.page).on("resized", resizeContents);

            // 検索処理
            searchItems(new query());

            // コンテンツに変更が発生した場合は、
            $(".list-part-detail-content").on("change", function () {
                isChanged = true;
            });

            var onBeforeUnload = function () {
                // データを変更したかどうかは各画面でチェックし、保持する
                if (isChanged) {
                    return pageLangText.unloadWithoutSave.text;
                }
            }
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
            /// <summary>データに変更があり、未保存の状態でページを離れる際に確認を行います。</summary>
            //$(window).on('beforeunload', function () {
            //    return pageLangText.unloadWithoutSave.text;
            //});

            /// <summary>詳細ボタンクリック時のイベント処理を行います。</summary>
            $(".detail-button").on("click", function (e) {
                showDetail(false);
            });

            /// <summary>保存ボタンクリック時のイベント処理を行います。</summary>
            $(".save-button").on("click", saveCheck);

            /// <summary>一覧へ戻るボタンクリック時のイベント処理を行います。</summary>
            $(".list-button").on("click", showGrid);

            /// <summary>保存確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".save-confirm-dialog .dlg-yes-button").on("click", saveData);
            // <summary>保存確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".save-confirm-dialog .dlg-no-button").on("click", closeSaveConfirmDialog);

            /// <summary>保存完了ダイアログの「閉じる」ボタンクリック時のイベント処理を行います。</summary>
            $(".save-complete-dialog .dlg-close-button").on("click", function () {
                closeSaveCompleteDialog();
                // 検索前の状態に初期化
                clearState();
                showGrid().done(function () {
                    searchItems(new query())
                });
            });

            // メニューへ戻る
            var backToMenu = function () {
                try {
                    window.location = pageLangText.menuPath.url;
                } catch (e) {
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
                <div class="item-command" style="left: 17px; right: 17px;">
                    <button type="button" class="colchange-button" data-app-operation="colchange"><span class="icon"></span><span data-app-text="colchange"></span></button>
                    <button type="button" class="detail-button" name="detail-button" data-app-operation="detail"><span class="icon"></span><span data-app-text="detail"></span></button>
                </div>
                <table id="item-grid">
                </table>
            </div>
            
            <div class="list-part-detail-content" style="display:none;">
                <div class="item-command" style="left: 17px; right: 17px;">
                    <button type="button" class="list-button" name="list-button" data-app-operation="list"><span class="icon"></span><span data-app-text="list"></span></button>
                    <button type="button" class="save-button" name="save-button" data-app-operation="save"><span class="icon"></span><span data-app-text="save"></span></button>
                </div>
                <ul class="item-list item-list-left">
                    <!-- TODO: 画面の仕様に応じて以下の項目を変更してください。 -->
                    <li>
                        <label>
                            <span class="item-label" data-app-text="cd_kojo"></span>
                            <input class="readonly-txt" type="text" name="cd_kojo" readonly="true" />
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="nm_kojo"></span>
                            <input class="readonly-txt" type="text" name="nm_kojo" readonly="true" />
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="dt_nendo_start"></span>
                            <input type="text" name="dt_nendo_start" data-app-validation="dt_nendo_start" />
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="no_com_reader_niuke"></span>
                            <input type="text" name="no_com_reader_niuke" style="text-align:right;" data-app-validation="no_com_reader_niuke" />
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="no_yubin1"></span>
                            <input type="text" name="no_yubin1" data-app-validation="no_yubin1" />
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="no_yubin2"></span>
                            <input type="text" name="no_yubin2" data-app-validation="no_yubin2" />
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="jusho_1"></span>
                            <input type="text" name="nm_jusho_1"  data-app-validation="nm_jusho_1" style="width:250px" />
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="jusho_2"></span>
                            <input type="text" name="nm_jusho_2"  data-app-validation="nm_jusho_2" style="width:250px" />
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="jusho_3"></span>
                            <input type="text" name="nm_jusho_3"  data-app-validation="nm_jusho_3" style="width:250px" />
                        </label>
                    </li>
                </ul>
                <ul class="item-list item-list-right clearfix">
                    <li>
                        <label>
                            <span class="item-label" data-app-text="tel_1"></span>
                            <input type="text" name="no_tel_1" data-app-validation="no_tel_1" />
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="tel_2"></span>
                            <input type="text" name="no_tel_2" data-app-validation="no_tel_2" />
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="fax_1"></span>
                            <input type="text" name="no_fax_1"  data-app-validation="no_fax_1" />
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="fax_2"></span>
                            <input type="text" name="no_fax_2"  data-app-validation="no_fax_2" />
                        </label>
                    </li>

                    <li>
                        <label>
                            <span class="item-label" data-app-text="kbn_haigo_keisan_hoho"></span>
                            <select name="kbn_haigo_keisan_hoho" style="width:153px;"></select>
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="dt_kigen_chokuzen"></span>
                            <input type="text" id="id_dt_kigen_chokuzen" name="dt_kigen_chokuzen" style="text-align:right;" data-app-validation="dt_kigen_chokuzen" />
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="dt_kigen_chikai"></span>
                            <input type="text" id="id_dt_kigen_chikai" name="dt_kigen_chikai" style="text-align:right;" data-app-validation="dt_kigen_chikai" />
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="dt_toroku"></span>
                            <span class="item-label data-app-format" id="id_dt_create" name="dt_create" data-app-format="dateTime" style="width: 160px;"></span>
                            <!-- input class="readonly-txt" type="text" name="dt_toroku" readonly="true" data-app-format="date"/ -->
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="dt_henko"></span>
                            <span class="item-label data-app-format" id="id_dt_update" name="dt_update" data-app-format="dateTime" style="width: 160px;"></span>
                            <!-- input class="readonly-txt" type="text" name="dt_henko" readonly="true" data-app-format="date"/ -->
                        </label>
                    </li>
                    <li>
                    <input type="hidden" name="ts" />
                    </li>
                    <li>
                    <input type="hidden" name="cd_create" />
                    </li>
                    <li>
                    <input type="hidden" name="cd_kaisha" />
                    </li>
                    <!-- TODO: ここまで -->
                </ul>
                <ul class="item-list item-list-right clearfix">
                    <!-- TODO: 画面の仕様に応じて以下の項目を変更してください。 -->
                    
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
        
    </div>
    <div class="command" style="right: 9px;">
        <button type="button" class="menu-button" name="menu-button" data-app-operation="menu">
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
            <div class="command-detail" style="position: absolute; left: 10px; top: 5px">
                <button class="dlg-close-button" name="dlg-close-button" data-app-text="close"></button>
            </div>
        </div>
    </div>

    <!-- 画面デザイン -- End -->

</asp:Content>
