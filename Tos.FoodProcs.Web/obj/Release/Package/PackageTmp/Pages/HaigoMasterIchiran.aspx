<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="HaigoMasterIchiran.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.HaigoMasterIchiran" %>

<asp:Content ID="Content1" ContentPlaceHolderID="IncludeContent" runat="server">
    <script src="<%=ResolveUrl("~/Resources/pages/pagedata-haigomasterichiran." + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
    <script src="<%=ResolveUrl("~/Resources/grid/grid.locale-" + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
    <script src="<%=ResolveUrl("~/Scripts/util/app-util.js") %>" type="text/javascript"></script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        /* 画面デザイン -- Start */
        
        /* TODO：画面の仕様に応じて以下のスタイルを変更してください。 */
        /* ヘッダー折り返し用の設定 */
        .ui-jqgrid .ui-jqgrid-htable th 
        {
            height:30px;
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

        input[name="nm_haigo"] {
            width: 60%
        }

        .part-header {
            line-height: 30px!important;
        }
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
                //querySetting = { skip: 0, top: 100, count: 0 },
                querySetting = { skip: 0, top: 300, count: 0 },
                isDataLoading = false;

            // グリッドコントロール固有の変数宣言
            var grid = $("#item-grid");
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            changeSet = new App.ui.page.changeSet(),
            firstCol = 1,
            currentRow = 0,
            newHanNo = 1,
            //isMishiyo = false,
            haigoName = 'nm_haigo_' + App.ui.page.lang,
            kanzanKubun = pageLangText.kanzanKubunId.data,
            tenkaiKubun = pageLangText.tenkaiKubunId.data;

            // 単位区分によって換算区分の表示名を切り替える
            var nm_kanzan_kg = pageLangText.tani_Kg_text.text;
            var nm_kanzan_Li = pageLangText.tani_L_text.text;
            if (pageLangText.kbn_tani_LB_GAL.text === App.ui.page.user.kbn_tani) {
                nm_kanzan_kg = pageLangText.tani_LB_text.text;
                nm_kanzan_Li = pageLangText.tani_Gal_text.text;
            }
            // TODO: ここまで

            // ダイアログ固有の変数宣言
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            var deleteConfirmDialog = $(".delete-confirm-dialog"),
                deleteCompleteDialog = $(".delete-complete-dialog");

            // ダイアログ固有のコントロール定義
            deleteConfirmDialog.dlg();
            deleteCompleteDialog.dlg();

            /// <summary>ダイアログを開きます。</summary>
            var showDeleteConfirmDialog = function () {
                recordCount = grid.getGridParam("records");
                // レコードがない場合は処理を抜ける
                if (recordCount == 0) {
                    App.ui.page.notifyInfo.message(pageLangText.noRecords.text).show();
                    return;
                }
                deleteConfirmDialogNotifyInfo.clear();
                deleteConfirmDialogNotifyAlert.clear();
                deleteConfirmDialog.draggable(true);
                deleteConfirmDialog.dlg("open");
            };

            /// <summary>ダイアログを開きます。</summary>
            var showDeleteCompleteDialog = function () {
                deleteCompleteDialogNotifyInfo.clear();
                deleteCompleteDialogNotifyAlert.clear();
                deleteCompleteDialog.draggable(true);
                deleteCompleteDialog.dlg("open");
            }

            /// <summary>ダイアログを閉じます。</summary>
            var closeDeleteConfirmDialog = function () {
                deleteConfirmDialog.dlg("close");
            };

            /// <summary>ダイアログを閉じます。</summary>
            var closeDeleteCompleteDialog = function () {
                deleteCompleteDialog.dlg("close");
            };

            //// 変数宣言 -- End

            //// コントロール定義 -- Start

            // 英語化対応　言語によって幅を調節
            $(".search-criteria .item-label").css("width", pageLangText.each_lang_width.number);

            // 日付の多言語対応
            var newDateFormat = pageLangText.dateNewFormatUS.text;
            var datePickerFormat = pageLangText.dateFormatUS.text;
            if (App.ui.page.langCountry !== 'en-US') {
                newDateFormat = pageLangText.dateNewFormat.text;
                datePickerFormat = pageLangText.dateFormat.text;
            }

            // datepickerの設定
            (function () {
                var $dt_from = $("#dt_from");
                $dt_from.on("keyup", App.data.addSlashForDateString);
                $dt_from.datepicker({
                    dateFormat: datePickerFormat,
                    minDate: new Date(1975, 1 - 1, 1),
                    maxDate: new Date(3000, 12 - 1, 31)
                });
                $dt_from.val(App.data.getDateString(new Date(), true));
            })();

            // グリッドコントロール固有のコントロール定義
            grid.jqGrid({
                // TODO：画面の仕様に応じて以下の列名の定義を変更してください。
                colNames: [
                    pageLangText.cd_haigo.text
                    , pageLangText.nm_haigo.text
                    , pageLangText.nm_haigo_ryaku.text
                    , pageLangText.cd_bunrui.text
                    , pageLangText.nm_bunrui.text
                    , pageLangText.no_han.text
                    , pageLangText.dt_from_meisai.text
                    , pageLangText.ritsu_budomari.text
                    , pageLangText.wt_kihon.text
                    , pageLangText.ritsu_kihon.text
                    , pageLangText.kbn_kanzan.text
                    , pageLangText.ritsu_hiju.text
                    , pageLangText.flg_gassan_shikomi.text
                    , pageLangText.wt_saidai_shikomi.text
                    , pageLangText.flg_shorihin.text
                    , pageLangText.cd_line.text
                    , pageLangText.nm_line.text
                    , pageLangText.no_yusen.text
                    , pageLangText.flg_tenkai.text
                    , pageLangText.flg_mishiyo_item.text
                    , pageLangText.ts.text
                    , pageLangText.kbn_kanzan.text
                ],
                // TODO：画面の仕様に応じて以下の列モデルの定義を変更してください。
                colModel: [
                    { name: 'cd_haigo', width: pageLangText.cd_haigo_width.number, sortable: true, frozen: true, resizable: false },
                    { name: haigoName, width: pageLangText.nm_haigo_width.number, sortable: true, frozen: true, resizable: true },
                    { name: 'nm_haigo_ryaku', width: pageLangText.nm_haigo_ryaku_width.number, sortable: true, resizable: true },
                    { name: 'cd_bunrui', width: 120, hidden: true, hidedlg: true, sortable: false, resizable: true },
                    { name: 'nm_bunrui', width: pageLangText.nm_bunrui_width.number, sortable: true, resizable: true },
                    { name: 'no_han', width: pageLangText.no_han_width.number, sortable: true, resizable: true, align: 'right' },
                    { name: 'dt_from', width: pageLangText.dt_from_width.number, sortable: false, resizable: true, sorttype: "date",
                        hidden: true, hidedlg: true,
                        formatter: "date", formatoptions: { srcformat: newDateFormat, newformat: newDateFormat }
                    },
                    { name: 'ritsu_budomari', width: pageLangText.ritsu_budomari_width.number, sortable: true, align: 'right',
                        formatter: 'number',
                        formatoptions: {
                            decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 2, defaultValue: ""
                        }
                    },
                    { name: 'wt_kihon', width: 120, hidden: true, sortable: true, align: 'right' },
                    { name: 'ritsu_kihon', width: pageLangText.ritsu_kihon_width.number, sortable: true, align: 'right',
                        formatter: 'number',
                        formatoptions: {
                            decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 2, defaultValue: ""
                        }
                    },
                    { name: 'nm_tani', width: pageLangText.kbn_kanzan_width.number, sortable: true, align: 'left',
                        formatter: function (cellvalue, options, rowObject) {
                            var kbn = rowObject.kbn_kanzan;
                            var ret = nm_kanzan_kg;
                            if (kbn == pageLangText.lCdTani.text) {
                                ret = nm_kanzan_Li;
                            }
                            return ret;
                        }
                    },
                    { name: 'ritsu_hiju', width: pageLangText.ritsu_hiju_width.number, sortable: true, align: 'right',
                        formatter: 'number',
                        formatoptions: {
                            decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 2, defaultValue: ""
                        }
                    },
                    { name: 'flg_gassan_shikomi', width: pageLangText.flg_gassan_shikomi_width.number, sortable: true, editable: false, edittype: "checkbox",
                        formatter: "checkbox", align: 'center'
                    },
                    { name: 'wt_saidai_shikomi', width: pageLangText.wt_saidai_shikomi_width.number, sortable: true, align: "right",
                        formatter: 'number',
                        formatoptions: {
                            decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 6, defaultValue: ""
                        }
                    },
                    { name: 'flg_shorihin', width: pageLangText.flg_shorihin_width.number, sortable: true, editable: false, edittype: "checkbox",
                        formatter: "checkbox", align: 'center'
                    },
                    { name: 'cd_line', width: pageLangText.cd_line_width.number, sortable: true },
                    { name: 'nm_line', width: pageLangText.nm_line_width.number, sortable: true },
                    { name: 'no_juni_yusen', width: pageLangText.no_juni_yusen_width.number, sortable: true, align: 'right' },
                    { name: 'flg_tenkai', width: pageLangText.flg_tenkai_width.number, sortable: true, editable: false, align: 'left', formatter: tenkaiFormatter },
                    { name: 'flg_mishiyo', width: pageLangText.flg_mishiyo_width.number, sortable: true, editable: false, edittype: "checkbox",
                        editoptions: { value: "1:0" },
                        formatter: "checkbox",
                        formatoptions: { disabled: true },
                        align: 'center'
                    },
                    { name: 'ts', width: 0, hidden: true, hidedlg: true },
                    { name: 'kbn_kanzan', width: 0, hidden: true, hidedlg: true }
                ],
                // TODO：ここまで
                datatype: "local",
                shrinkToFit: false,
                multiselect: false,
                rownumbers: true,
                hoverrows: false,
                gridComplete: function () {
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
                    // 配合レシピ画面を開く
                    $("[name='recipe-button']").click();
                }
            });

            /// <summary>グリッド表示時のイベント処理を行います。</summary>
            function kanzanFormatter(cellvalue, options, rowObject) {
                // 権限名の表示
                var kanzanName = "";
                if (App.isUndefOrNull(cellvalue)) {
                    return "";
                }
                $.each(kanzanKubun, function (index) {
                    if (cellvalue === kanzanKubun[index].id) {
                        // TODO: 置換する文字内容の変更
                        kanzanName = kanzanKubun[index].name;
                    }
                });
                return kanzanName;
            }

            function tenkaiFormatter(cellvalue, options, rowObject) {
                // 権限名の表示
                var tenkaiName = "";
                if (App.isUndefOrNull(cellvalue)) {
                    return "";
                }
                $.each(tenkaiKubun, function (index) {
                    if (cellvalue === tenkaiKubun[index].id) {
                        // TODO: 置換する文字内容の変更
                        tenkaiName = tenkaiKubun[index].name;
                    }
                });
                return tenkaiName;
            }

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

            //---------------------------------------------------------
            //2019/07/24 trinh.bd Task #14029
            //------------------------START----------------------------
            //// 操作制御定義 -- Start
            // 操作制御定義を定義します。
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
            //// 操作制御定義 -- End
            //------------------------END------------------------------

            //// 事前データロード -- Start 

            // 画面アーキテクチャ共通の事前データロード
            App.deferred.parallel({
                loading: App.ui.loading.show(pageLangText.nowProgressing.text),
                // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                bunrui: App.ajax.webget("../Services/FoodProcsService.svc/ma_bunrui?$filter=kbn_hin eq " + pageLangText.shikakariHinKbn.text + " and flg_mishiyo eq " + pageLangText.shiyoMishiyoFlg.text + "&$orderby=cd_bunrui") //品区分が仕掛品のものだけを取得
                // TODO: ここまで
            }).done(function (result) {
                // TODO: 画面の仕様に応じて以下のサービス呼び出し成功時の処理を変更してください。
                var cd_bunrui = result.successes.bunrui.d;
                // 検索用ドロップダウンの設定
                App.ui.appendOptions($(".search-criteria [name='cd_bunrui']"), "cd_bunrui", "nm_bunrui", cd_bunrui, true);
                $(".search-criteria [name='cd_bunrui']").val(criteriaBunruiCode);
                $("input:radio[name='flg_mishiyo']").val([criteriaMishiyoFlg]); // []が無いと反映されない
                $("#dt_from").val(dt_yuko);
                // 他画面からの遷移の場合、検索を行う。
                if (handle == "HaigoMasterIchiran") {
                    searchItems(new query());
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

            // urlよりパラメーターを取得
            var parameters = getParameters();
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            var criteriaBunruiCode = App.ifUndefOrNull(parameters["cd_bunrui"], pageLangText.shokikaShokichi.text)
                , criteriaHaigoName = decodeURIComponent(App.ifUndefOrNull(parameters["haigoName"], pageLangText.shokikaShokichi.text))
                , handle = App.ifUndefOrNull(parameters["handle"], pageLangText.shokikaShokichi.text);
            // string型にするために空白を足す(replaceのため)
            var param_mishiyoFlg = "" + App.ifUndefOrNull(parameters["mishiyoFlg"], pageLangText.falseFlg.text);
            var criteriaMishiyoFlg = param_mishiyoFlg.replace("#", ""); // URLの最後に#が付いた状態でF5をしたときの不具合対応
            var dt_yuko = decodeURIComponent(App.ifUndefOrNull(parameters["dt_yuko"], App.data.getDateString(new Date(), true)).toString().replace("#", ""));
            $("[name='nm_haigo']").val(criteriaHaigoName);
            // TODO：ここまで
            //// 事前データロード -- End

            //// 検索処理 -- Start

            // 画面アーキテクチャ共通の検索処理

            /// <summary>クエリオブジェクトの設定</summary>
            var query = function () {
                var criteria = $(".search-criteria").toJSON();
                var query = {
                    url: "../api/HaigoMasterIchiran"
		            , kbn_hin: pageLangText.shikakariHinKbn.text
		            , kbn_master: pageLangText.haigoMasterSeizoLineMasterKbn.text
                    //, dt_shokichi: pageLangText.dateShokichi.text
                    , dt_shokichi: App.data.getDateTimeStringForQueryNoUtc(new Date(pageLangText.dateShokichi.text))
                    , flg_mishiyo: criteria.flg_mishiyo
                    , cd_bunrui: criteria.cd_bunrui
                    , nm_haigo: encodeURIComponent(criteria.nm_haigo)
                    , lang: App.ui.page.lang
                    //, skip: querySetting.skip
                    , top: querySetting.top
                    //, sysDate: App.data.getDateTimeStringForQueryNoUtc(new Date())
                    //, dt_from: App.data.getDateTimeStringForQueryNoUtc(new Date($("#dt_from").val()))
                    , dt_from: App.data.getDateTimeStringForQueryNoUtc(App.date.localDate($("#dt_from").val()))
                }
                return query;
            };
            /// <summary>フィルター条件の設定</summary>
            var createFilter = function () {
                var criteria = $(".search-criteria").toJSON(),
                    filters = [];

                // TODO: 画面の仕様に応じて以下のフィルター条件を変更してください。
                if (!App.isUndefOrNull(criteria.cd_bunrui) && criteria.cd_bunrui.length > 0) {
                    filters.push("cd_bunrui eq '" + criteria.cd_bunrui + "'");
                }
                if (!App.isUndefOrNull(criteria.nm_haigo) && criteria.nm_haigo.length > 0) {
                    filters.push(("substringof('" + encodeURIComponent(criteria.nm_haigo) + "', haigoName) eq true or substringof('" + encodeURIComponent(criteria.nm_haigo) + "', cd_haigo) eq true"));
                }
                if (criteria.flg_mishiyo == 0) {
                    filters.push("flg_mishiyo eq " + criteria.flg_mishiyo);
                }
                filters.push("no_han eq " + pageLangText.hanNoShokichi.text);
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
                    App.data.toWebAPIFormat(query)
                ).done(function (result) {
                    // データバインド
                    bindData(result);
                    // 検索条件を閉じる
                    closeCriteria();
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
                //isMishiyo = false;
                displayCount();

                // TODO: 画面の仕様に応じて以下のパラメータ設定を変更してください。
                currentRow = 0;
                // TODO: ここまで

                // 情報メッセージのクリア
                App.ui.page.notifyInfo.clear();
                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();
                // 削除用changeSetを初期化
                changeSet = new App.ui.page.changeSet();
            };
            /// <summary>データ取得件数を表示します。</summary>
            var displayCount = function () {
                $("#list-count").text(
                     App.str.format("{0}/{1} " + pageLangText.itemCount.text, querySetting.skip, querySetting.count)
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

            //// コントロール定義 -- Start

            //// コントロール定義 -- End

            //// メッセージ表示 -- Start

            //// メッセージ表示 -- End

            //// データ変更処理 -- Start
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
                // 選択行なしの場合の行選択
                if (App.isUnusable(selectedRowId)) {
                    //                    selectedRowId = ids[recordCount - 1]; //最終行
                    selectedRowId = ids[0]; // 先頭行
                }
                currentRow = $('#' + selectedRowId)[0].rowIndex;

                return selectedRowId;
            };
            /// <summary>削除状態の変更セットに追加する変更データの設定を行います。</summary>
            /// <param name="row">選択行</param>
            var setDeletedChangeData = function (row) {
                // TODO: 画面の仕様に応じて以下の項目を変更してください。
                var changeData = {
                    "cd_haigo": row.cd_haigo,
                    "no_han": pageLangText.hanNoShokichi.text,
                    "ts": row.ts
                };
                // TODO: ここまで

                return changeData;
            };
            //// データ変更処理 -- End

            //// 保存処理 -- Start

            // グリッド固有の保存処理

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

                var ids = grid.getDataIDs(),
                    newId,
                    value,
                    unique,
                    current,
                // TODO: 画面の仕様に応じて以下の変数を変更します。
                    checkCol = 1;
                // TODO: ここまで
                // データ整合性エラーのハンドリングを行います。
                if (App.isArray(ret) && ret.length > 0) {
                    for (var i = 0; i < ret.length; i++) {
                        for (var j = 0; j < ids.length; j++) {
                            // TODO: 画面の仕様に応じて以下の値を変更します。
                            value = grid.getCell(ids[j], checkCol);
                            retValue = ret[i].Data.cd_haigo;
                            // TODO: ここまで

                            if (value === retValue) {
                                // TODO: 画面の仕様に応じて以下のロジックを変更します。
                                if (ret[i].InvalidationName === "NotExsists") {
                                    unique = ids[j] + "_" + firstCol;

                                    // エラーメッセージの表示
                                    App.ui.page.notifyAlert.message(
                                        pageLangText.invalidation.text + ret[i].Message, unique).show();
                                    // 対象セルの背景変更
                                    grid.setCell(ids[j], firstCol, ret[i].Data.cd_haigo, { background: '#ff6666' });
                                }
                                else {
                                    // エラーメッセージの表示
                                    App.ui.page.notifyAlert.message(
                                        pageLangText.invalidation.text + ret[i].Message).show();
                                }
                                // TODO: ここまで
                            }
                        }
                    }
                }
                // 削除時同時実行制御エラーのハンドリングを行います。
                if (!App.isUndefOrNull(ret.Deleted) && ret.Deleted.length > 0) {
                    for (var i = 0; i < ret.Deleted.length; i++) {
                        for (p in changeSet.changeSet.deleted) {
                            if (!changeSet.changeSet.deleted.hasOwnProperty(p)) {
                                continue;
                            }

                            // TODO: 画面の仕様に応じて以下の値を変更します。
                            value = changeSet.changeSet.deleted[p].cd_haigo
                            retValue = ret.Deleted[i].Requested.cd_haigo;
                            // TODO: ここまで

                            if (isNaN(value) || value === retValue) {
                                // 削除状態の変更セットから変更データを削除
                                changeSet.removeDeleted(p);

                                // 他のユーザーによって削除されていた場合
                                if (App.isUndefOrNull(ret.Deleted[i].Current)) {
                                    // メッセージの表示
                                    App.ui.page.notifyAlert.message(
                                        pageLangText.duplicate.text + pageLangText.deletedDuplicate.text).show();
                                }
                                else {
                                    // メッセージの表示
                                    App.ui.page.notifyAlert.message(
                                        pageLangText.duplicate.text + pageLangText.unDeletedDuplicate.text).show();
                                }
                            }
                        }
                    }
                }
            };

            /// <summary>変更を保存します。</summary>
            /// <param name="e">イベントデータ</param>
            var saveData = function (e) {
                // ダイアログを閉じる
                closeDeleteConfirmDialog();
                // 情報メッセージのクリア
                App.ui.page.notifyInfo.clear();
                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();
                // ローディングの表示
                App.ui.loading.show(pageLangText.nowSaving.text);
                // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                var saveUrl = "../api/HaigoMasterIchiran";
                // TODO: ここまで
                App.ajax.webpost(
                    saveUrl, getPostData()
                ).done(function (result) {
                    // 保存完了メッセージ出力
                    showDeleteCompleteDialog();
                }).fail(function (result) {
                    // データ変更エラーハンドリングを行います。
                    handleSaveDataError(result);
                }).always(function () {
                    // ローディングの終了
                    App.ui.loading.close();
                });
            };

            /// <summary>削除完了</summary>
            var deleteComplete = function () {
                closeDeleteCompleteDialog();
                // 検索前の状態に初期化
                clearState();
                // データ検索
                searchItems(new query())
            };

            //// 保存処理 -- End

            //// バリデーション -- Start

            /// <summary>検索条件のデータを取得します。</summary>
            /// <param name="criteriaPart">検索条件のデータ</param>
            var getCriteriaData = function (criteriaPart) {
                var criteriaData = pageLangText.shokikaShokichi.text;
                if (!App.isUndefOrNull(criteriaPart)) {
                    criteriaData = criteriaPart;
                }
                return criteriaData;
            };

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

            /// <summary>ページ遷移を行います。</summary>
            var navigate = function (e) {
                // TODO：画面の仕様に応じて変更してください。
                var button = e.currentTarget.className;
                // 追加の場合は行選択されていなくても画面遷移
                if (button !== "add-button") {
                    var selectedRowId = getSelectedRowId();
                    // データが存在しない場合処理を抜ける
                    if (App.isUndefOrNull(selectedRowId)) {
                        return;
                    }
                    // 選択行のデータ取得
                    var row = grid.jqGrid("getRowData", selectedRowId);
                }
                var criteria = $(".search-criteria").toJSON();
                var bunruiCode = getCriteriaData(criteria.cd_bunrui);
                var haigoName = getCriteriaData(criteria.nm_haigo);
                var mishiyoFlg = getCriteriaData(criteria.flg_mishiyo);
                var pDt_yuko = criteria.dt_from ? $("#dt_from").val() : App.data.getDateString(new Date(), true);
                var url = "./HaigoMaster.aspx";
                // 遷移先のurlを設定
                if (button == "recipe-button") {
                    url = "./HaigoRecipeMaster.aspx";
                }
                /// 遷移時に渡すパラメータを設定
                // 配合コード
                if (button == "add-button") {
                    url += "?cdHaigo=";
                }
                else {
                    url += "?cdHaigo=" + row.cd_haigo;
                }
                // 版番号
                if (button == "add-button") {
                    url += "&no_han=" + newHanNo;
                }
                else {
                    url += "&no_han=" + grid.getCell(getSelectedRowId(), "no_han"); ;
                }
                //url += "&no_han=" + newHanNo;
                url += "&handle=" + button;
                url += "&cd_bunrui=" + bunruiCode;
                url += "&haigoName=" + haigoName;
                url += "&mishiyoFlg=" + mishiyoFlg;
                url += "&dt_yuko=" + pDt_yuko;
                // TODO: ここまで
                window.location = url;
            };

            /// <summary>追加ボタンクリック時のイベント処理を行います。</summary>
            $(".add-button").on("click", navigate);

            /// <summary>コピーボタンクリック時のイベント処理を行います。</summary>
            $(".copy-button").on("click", navigate);

            /// <summary>詳細ボタンクリック時のイベント処理を行います。</summary>
            $(".detail-button").on("click", navigate);

            /// <summary>レシピボタンクリック時のイベント処理を行います。</summary>
            $(".recipe-button").on("click", navigate);

            /// <summary>ライン登録画面にページ遷移を行います。</summary>
            var showLine = function () {
                var selectedRowId = getSelectedRowId();
                // データが存在しない場合処理を抜ける
                if (App.isUndefOrNull(selectedRowId)) {
                    return;
                }

                var row = grid.jqGrid("getRowData", selectedRowId);
                // 遷移先のurlを設定
                var url = "./SeizoLineMaster.aspx";
                // 遷移時に渡すパラメータを設定
                url += "?cd_haigo=" + row.cd_haigo;
                url += "&kbn_master=" + pageLangText.haigoMasterSeizoLineMasterKbn.text;
                // 画面遷移
                window.location = url;
            };
            /// <summary>ライン登録ボタンクリック時のイベント処理を行います。</summary>
            $(".line-button").on("click", showLine);

            /// <summary>仕掛品使用一覧にページ遷移を行います。</summary>
            var showShikakari = function (e) {
                var selectedRowId = getSelectedRowId();
                // データが存在しない場合処理を抜ける
                if (App.isUndefOrNull(selectedRowId)) {
                    return;
                }
                var row = grid.jqGrid("getRowData", selectedRowId);
                // 遷移先のurlを設定
                var url = "./ShikakarihinShiyoIchiran.aspx";
                // 遷移時に渡すパラメータを設定
                url += "?cdHaigo=" + row.cd_haigo;
                // 画面遷移
                window.location = url;
            };
            /// <summary>仕掛品使用ボタンクリック時のイベント処理を行います。</summary>
            $(".shikakari-button").on("click", showShikakari);

            /// <summary>行を削除します。</summary>
            /// <param name="e">イベントデータ</param>
            var deleteData = function (e) {
                // 選択行のID取得
                var selectedRowId = getSelectedRowId();
                if (App.isUndefOrNull(selectedRowId)) {
                    return;
                }
                // 削除状態の変更データの設定
                var changeData = setDeletedChangeData(grid.getRowData(selectedRowId));
                // 削除状態の変更セットに変更データを追加
                changeSet.addDeleted(selectedRowId, changeData);
                // データの保存
                saveData();
            };

            /// <summary>削除ボタンクリック時のイベント処理を行います。</summary>
            $(".del-button").on("click", showDeleteConfirmDialog);

            // Cookieを1秒ごとにチェックする
            var onComplete = function () {
                if (app_util.prototype.getCookieValue(pageLangText.haigoMasterIchiranCookie.text) == pageLangText.checkCookie.text) {
                    app_util.prototype.deleteCookie(pageLangText.haigoMasterIchiranCookie.text);
                    //ローディング終了
                    App.ui.loading.close();
                }
                else {
                    // 再起してCookieが作成されたか監視
                    setTimeout(onComplete, 1000);
                }
            };

            /// <summary>Excelファイル出力を行います。</summary>
            var printExcel = function (e) {
                // 情報メッセージのクリア
                App.ui.page.notifyInfo.clear();
                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();
                // レコード数を取得
                //var recordCount = grid.getGridParam("records");
                // レコードがない場合は処理を抜ける
                //if (recordCount == 0) {
                //    App.ui.page.notifyInfo.message(pageLangText.noRecords.text).show();
                //    return;
                //}

                var criteria = $(".search-criteria").toJSON();
                var query = {
                    // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                    url: "../api/HaigoMasterIchiranExcel",
                    // TODO: ここまで
                    filter: createFilter(),
                    orderby: "cd_haigo"
                };
                // 処理中を表示する
                App.ui.loading.show(pageLangText.nowProgressing.text);

                var bunruiCode = getCriteriaData(criteria.cd_bunrui);
                var bunruiName = pageLangText.shokikaShokichi.text;
                if (!App.isUndefOrNull(criteria.cd_bunrui)) {
                    bunruiName = $("#condition-bunruiCode option:selected").text();
                }
                var haigoName = getCriteriaData(criteria.nm_haigo);

                var _url = App.data.toODataFormat(query);
                _url = _url
                    + "&lang=" + App.ui.page.lang
                    + "&kbn_hin=" + pageLangText.shikakariHinKbn.text
                    + "&kbn_master=" + pageLangText.haigoMasterSeizoLineMasterKbn.text
                //  + "&dt_shokichi=" + pageLangText.dateShokichi.text
                    + "&dt_shokichi=" + App.data.getDateTimeStringForQueryNoUtc(new Date(pageLangText.dateShokichi.text))
                    + "&flg_mishiyo=" + criteria.flg_mishiyo
                    + "&cd_bunrui=" + bunruiCode
                    + "&bunruiName=" + encodeURIComponent(bunruiName)
                    + "&haigoName=" + encodeURIComponent(haigoName)
                    + "&UTC=" + new Date().getTimezoneOffset() / 60
                    + "&today=" + App.data.getDateTimeStringForQuery(new Date(), true)
                //  + "&sysDate=" + App.data.getDateTimeStringForQueryNoUtc(new Date())
                //  + "&dt_from=" + App.data.getDateTimeStringForQueryNoUtc(new Date(App.data.getDateString(new Date($("#dt_from").val()), true)));
                    + "&dt_from=" + App.data.getDateTimeStringForQueryNoUtc(App.date.localDate($("#dt_from").val()));

                window.open(_url, '_parent');
                // Cookieを監視する
                onComplete();
            };

            /// <summary> Excel出力前チェック </summary>
            var checkExcel = function () {
                var isReturn = false;
                if (isReturn) {
                    // ローディングの終了
                    App.ui.loading.close();
                    return;
                }
                printExcel();
            };

            /// <summary>ローディングの表示</summary>
            var loading = function (msgid, fnc) {
                App.ui.loading.show(msgid);
                var deferred = $.Deferred();
                deferred
                .then(function () {
                    var d = new $.Deferred;
                    setTimeout(function () {
                        App.ui.loading.show(msgid);
                        d.resolve();
                    }, 50);
                    return d;
                })
                .then(function () {
                    if (fnc === "excel-button") {
                        checkExcel();
                    }
                });
                deferred.resolve();
            };

            /// <summary>印刷ボタンクリック時のイベント処理を行います。</summary>
            $(".excel-button").on("click", function (e) {
                //loading(pageLangText.nowProgressing.text, "excel-button");
                printExcel();
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
                    resultPartCommands = resultPart.find(".item-command"),
                    resultPartStyle = resultPart[0].currentStyle || document.defaultView.getComputedStyle(resultPart[0], "");

                resultPart.height(container[0].clientHeight - searchPart[0].clientHeight - ((parseInt(resultPartStyle.marginTop, 10) * 3) || 0));
                grid.setGridWidth(resultPart[0].clientWidth - 5);
                //結果一覧のパートの高さ - パートのヘッダーの高さ - パート内のボタンのコマンドの高さ - jqGrid のカラムヘッダーの高さ
                grid.setGridHeight(resultPart[0].clientHeight - resultPartHeader[0].clientHeight - resultPartCommands[0].clientHeight - resultPart.find(".ui-jqgrid-hdiv")[0].clientHeight - 35);
            };
            /// <summary>画面リサイズ時のイベント処理を行います。</summary>
            $(App.ui.page).on("resized", resizeContents);

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

            /// <summary>削除確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".delete-confirm-dialog .dlg-yes-button").on("click", deleteData);
            /// <summary>削除確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".delete-confirm-dialog .dlg-no-button").on("click", closeDeleteConfirmDialog);

            /// <summary>削除完了ダイアログの「閉じる」ボタンクリック時のイベント処理を行います。</summary>
            $(".delete-complete-dialog .dlg-close-button").on("click", deleteComplete);

            /// ダイアログ情報メッセージの設定
            // 削除確認
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
            // 削除完了
            var deleteCompleteDialogNotifyInfo = App.ui.notify.info(deleteCompleteDialog, {
                container: ".delete-complete-dialog .dialog-slideup-area .info-message",
                messageContainerQuery: "ul",
                show: function () {
                    deleteCompleteDialog.find(".info-message").show();
                },
                clear: function () {
                    deleteCompleteDialog.find(".info-message").hide();
                }
            });

            /// ダイアログ警告メッセージの設定
            // 削除確認
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
            // 削除完了
            var deleteCompleteDialogNotifyAlert = App.ui.notify.alert(deleteCompleteDialog, {
                container: ".delete-complete-dialog .dialog-slideup-area .alert-message",
                messageContainerQuery: "ul",
                show: function () {
                    deleteCompleteDialog.find(".alert-message").show();
                },
                clear: function () {
                    deleteCompleteDialog.find(".alert-message").hide();
                }
            });
        });
    </script>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <!-- 画面デザイン -- Start -->

    <!-- 検索条件と検索ボタン -->
    <div class="content-part search-criteria">
        <h3 class="part-header" data-app-text="searchCriteria"><a class="search-part-toggle" href="#"></a></h3>
        <div class="part-body">
            <table>
            <tr>
            <td style="width: 560px;">
            <ul class="item-list">
                <!-- TODO: 画面の仕様に応じて以下の検索条件を変更してください。-->
                <li>
                    <span style="width: 50%;">
                        <span class="item-label" data-app-text="nm_bunrui" data-tooltip-text="nm_bunrui"></span>
                        <select name="cd_bunrui" id="condition-bunruiCode"></select>
                    </span>
                </li>
                <li>
                    <span class="item-label" data-app-text="nm_haigo"></span>
                    <input type="text" name="nm_haigo" maxlength="50" size="50"/>
                </li>
                <li>
                    <span class="item-label"  data-app-text="mishiyo" data-tooltip-text="mishiyo"></span>
                    <input type="radio" name="flg_mishiyo" value="1" /><span data-app-text="flg_shiyo"></span>
                    <input type="radio" name="flg_mishiyo" value="0" checked /><span data-app-text="flg_mishiyo"></span>
                </li>
            </ul>
            </td>
            <td>
                <ul class="item-list">
                <li>
                    <span class="item-label" data-app-text="dt_from_criteria"></span>
                    <input type="text" id="dt_from" name="dt_from" maxlength="10" size="12"/>
                </li>
                </ul>
            </TD>
            </tr>
            </table>
                <!-- TODO: ここまで -->
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
                <div class="item-command" style="left: 17px; right: 17px;">
                    <button type="button" class="colchange-button" data-app-operation="colchange"><span class="icon"></span><span data-app-text="colchange"></span></button>
                    <button type="button" class="add-button" name="add-button" data-app-operation="add"><span class="icon"></span><span data-app-text="add"></span></button>
                    <button type="button" class="detail-button" name="detail-button" data-app-operation="detail"><span class="icon"></span><span data-app-text="detail"></span></button>
                    <button type="button" class="copy-button" name="copy-button" data-app-operation="copy"><span class="icon"></span><span data-app-text="copy"></span> </button>
                </div>
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
        <button type="button" class="excel-button" name="excel-button" data-app-operation="excel"><span data-app-text="excel"></span></button>
        <!-- TODO: 画面の仕様に応じて以下のボタンを変更してください。 -->
        <button type="button" class="del-button" name="del-button" data-app-operation="del"><span data-app-text="delHaigo"></span> </button>
        <button type="button" class="recipe-button" name="recipe-button" data-app-operation="recipe"><span data-app-text="recipe"></span></button>
        <button type="button" class="shikakari-button" name="shikakari-button" data-app-operation="shikakari"><span data-app-text="shikakari"></span></button>
        <button type="button" class="line-button" name="line-button" data-app-operation="line"><span data-app-text="lineSave"></span></button>
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
    <div class="delete-complete-dialog" style="display: none;">
        <div class="dialog-header">
            <h4 data-app-text="confirmTitle"></h4>
        </div>
        <div class="dialog-body" style="padding: 10px; width: 100%;">
            <div class="part-body">
                <span data-app-text="deleteComplete"></span>
            </div>
        </div>
        <div class="dialog-footer">
            <div class="command" style="position: absolute; left: 10px; top: 5px">
                <button class="dlg-close-button" name="dlg-close-button" data-app-text="close"></button>
            </div>
        </div>
    </div>
    <!-- TODO: ここまで  -->
    <!-- ダイアログ固有のデザイン -- End -->
    <!-- 画面デザイン -- End -->
</asp:Content>
<asp:Content ID="Content5" ContentPlaceHolderID="DialogsContent" runat="server">
    <!-- 画面デザイン -- Start -->
    <!-- 画面デザイン -- End -->
</asp:Content>
