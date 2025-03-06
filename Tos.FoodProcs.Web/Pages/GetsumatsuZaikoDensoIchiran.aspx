<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="GetsumatsuZaikoDensoIchiran.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.GetsumatsuZaikoDensoIchiran" %>

<asp:Content ID="Content1" ContentPlaceHolderID="IncludeContent" runat="server">
    <script src="<%=ResolveUrl("~/Resources/pages/pagedata-getsumatsuzaikodensoichiran." + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
    <script src="<%=ResolveUrl("~/Resources/grid/grid.locale-" + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        /* 画面デザイン -- Start */


        /* TODO：画面の仕様に応じて以下のスタイルを変更してください。 */
        .search-criteria .item-label {
            width: 8em;
        }
        .hinmei-dialog
        {
            background-color: White;
            width: 570px;
        }
        .text-align-right {
            text-align: right;
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
        #nm_hinmei_search
        {
            width: 350px;
        }
		#chk_denso,#chk_zaiko
		{
            margin-left: 3px;
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
            */

            //// 変数宣言 -- Start

            // 画面アーキテクチャ共通の変数宣言
            var pageLangText = App.ui.pagedata.lang(App.ui.page.lang),
                validationSetting = App.ui.pagedata.validation(App.ui.page.lang),
                querySetting = { skip: 0, top: 500, count: 0 },
                isDataLoading = false;

            // グリッドコントロール固有の変数宣言
            var grid = $("#item-grid"),
                changeSet = new App.ui.page.changeSet(),
                duplicateCol = 999,
                currentRow = 0,
                firstCol = 1,
                maxRecord = 1000,
                nextScrollTop = 0,
                isChanged = false,
                hinmeiName = 'nm_hinmei_' + App.ui.page.lang,
                lang = App.ui.page.lang;
            var loading;
            var chk_dt_denso,
                chk_dt_zaiko;

            // 英語化対応　言語によって幅を調節
            $(".search-criteria .item-label").css("width", pageLangText.each_lang_width.number);

            //// 変数宣言 -- End

            //// コントロール定義 -- Start

            // TODO：画面の仕様に応じて以下の datepicker の設定を変更してください。
            // 日付の多言語対応
            var datePickerFormat = pageLangText.dateFormatUS.text,
                newDateFormat = pageLangText.dateNewFormatUS.text,
                newDateTimeFormat = pageLangText.dateTimeNewFormatUS.text;
            if (App.ui.page.langCountry !== 'en-US') {
                datePickerFormat = pageLangText.dateFormat.text;
                newDateFormat = pageLangText.dateNewFormat.text;
                newDateTimeFormat = pageLangText.dateTimeNewFormat.text;
            }

            var dateformat = function (code) {
                $(".search-criteria [name='" + code + "']").datepicker({ dateFormat: datePickerFormat });
                $(".search-criteria [name='" + code + "']").on("keyup", App.data.addSlashForDateString);
                $(".search-criteria [name='" + code + "']").datepicker("setDate", new Date);
                $(".search-criteria [name='" + code + "']").datepicker("option", "maxDate", new Date(pageLangText.maxDate.text));
                $(".search-criteria [name='" + code + "']").datepicker("option", "minDate", new Date(pageLangText.minDate.text));
            }
            dateformat('dt_denso_start');
            dateformat('dt_denso_end');
            dateformat('dt_zaiko_start');
            dateformat('dt_zaiko_end');

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
                        $("#nm_hinmei_search").text(data2);
                        $("#cd_hinmei").val(data);
                        // 再チェックで背景色とメッセージのリセット
                        //$(".part-body .item-list").validation().validate();
                    }
                }
            });

            // ダイアログ固有の変数宣言
            var saveConfirmDialog = $(".save-confirm-dialog");

            // ダイアログ固有のコントロール定義
            saveConfirmDialog.dlg();

            /// <summary>ダイアログを開きます。</summary>
            var showSaveConfirmDialog = function () {
                saveConfirmDialogNotifyInfo.clear();
                saveConfirmDialogNotifyAlert.clear();
                saveConfirmDialog.draggable(true);
                saveConfirmDialog.dlg("open");
            };

            /// <summary>ダイアログを閉じます。</summary>
            var closeSaveConfirmDialog = function () {
                saveConfirmDialog.dlg("close");
            };

            // グリッドコントロール固有のコントロール定義

            //明細の設定
            grid.jqGrid({
                colNames: [
                    pageLangText.dt_denso.text,
                    pageLangText.kbn_denso_SAP.text,
                    pageLangText.dt_tanaoroshi.text,
                    pageLangText.cd_hinmei.text,
                    pageLangText.nm_hinmei.text,
                    pageLangText.cd_hokan.text,
                    pageLangText.nm_hokan.text,
                    pageLangText.su_tanaoroshi.text,
                    pageLangText.cd_tani.text,
                    pageLangText.nm_tani.text,
                    pageLangText.kbn_zaiko.text

                ],
                colModel: [
                    { name: 'dt_denso', width: pageLangText.dt_denso_width.number, sorttype: "date",
                        formatter: "date",
                        formatoptions: {
                            srcformat: newDateTimeFormat, newformat: newDateTimeFormat
                        }
                    },
                    { name: 'kbn_denso_SAP', width: pageLangText.kbn_denso_sap_width.number, frozen: true, sorttype: "text", align: "left",
                        formatter: setname
                    },
                    { name: 'dt_tanaoroshi', width: pageLangText.dt_tanaoroshi_width.number, sorttype: "date",
                        formatter: "date",
                        formatoptions: {
                            srcformat: newDateFormat, newformat: newDateFormat
                        }
                    },
                    { name: 'cd_hinmei', width: pageLangText.cd_hinmei_width.number, editable: true, align: 'left', sorttype: "text" },
                    { name: hinmeiName, width: pageLangText.nm_hinmei_width.number, editable: true, align: 'left', sorttype: "text" },
                    { name: 'hokan_basho', width: pageLangText.no_lot_seihin_width.number, editable: true, align: 'left', sorttype: "text" },
                    { name: 'nm_soko', width: pageLangText.no_lot_seihin_width.number, editable: true, align: 'left', sorttype: "text" },
                    { name: 'su_tanaoroshi', width: pageLangText.su_seizo_keikaku_width.number, sorttype: "int", align: "right",
                        formatter: 'integer',
                        formatoptions: {
                            thousandsSeparator: ",", decimalPlaces: 6, defaultValue: "0"
                        }
                    },
                    { name: 'cd_tani', width: pageLangText.cd_tani_width.number, editable: true, align: 'left', sorttype: "text" },
                    { name: 'nm_tani', width: pageLangText.nm_tani_width.number, editable: true, align: 'left', sorttype: "text" },
                    { name: 'nm_kbn_zaiko', width: pageLangText.nm_tani_width.number, editable: true, align: 'left', sorttype: "text" }
                ],
                datatype: "local",
                shrinkToFit: false,
                multiselect: false,
                rownumbers: true,
                hoverrows: false,
                gridComplete: function () {
                    var ids = grid.jqGrid('getDataIDs');
                    if (ids.length > 0) {
                        // 明細項目の計算処理

                        // グリッドの先頭行選択
                        // gridCompleteまたはloadCompleteに記述しないとグリッドのソートで先頭行が選択されない
                        grid.setSelection(1, false);
                    }
                }
            });
            function setname(value, options, rowObj) {
                var returnVal;
                if (value == 1) {
                    returnVal = pageLangText.kbn_add.text;
                }
                else if (value == 2) {
                    returnVal = pageLangText.kbn_upd.text;
                }
                else {
                    returnVal = pageLangText.kbn_del.text;
                }
                return returnVal;
            }

            /// <summary>非表示列設定ダイアログの表示を行います。</summary>
            /// <param name="e">イベントデータ</param>
            var showColumnSettingDialog = function (e) {
                var dlgHeight = (grid.getGridParam("height") - 30 < 230 ? (grid.getGridParam("height") - 30) : 230);
                var dataHeight = dlgHeight - 50;
                var params = {
                    width: 300,
                    heitht: dlgHeight,
                    dataheight: dataHeight,
                    modal: true,
                    drag: false,
                    recreateForm: true,
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

            //// 事前データロード -- End

            //// 検索処理 -- Start

            // 画面アーキテクチャ共通の検索処理
            $(".search-criteria").on("change", function (e) {
                isCriteriaChanged = true;
            });

            /// <summary>クエリオブジェクトの設定</summary>
            var query = function () {
                var criteria = $(".search-criteria").toJSON();
                var flgDenso = pageLangText.falseFlg.text,
                    flgZaiko = pageLangText.falseFlg.text;
                //putChar = pageLangText.seihinLotPrefixSaibanKbn.text + pageLangText.lotPutOnChar.text;

                // チェックボックスの判定
                if (criteria.chk_denso == "on") {
                    flgDenso = pageLangText.trueFlg.text;
                }
                if (criteria.chk_zaiko == "on") {
                    flgZaiko = pageLangText.trueFlg.text;
                }

                var query = {
                    url: "../api/GetsumatsuZaikoDensoIchiran",
                    dt_denso_from: App.data.getDateTimeStringForQueryNoUtc(criteria.dt_denso_start),
                    dt_denso_to: App.data.getDateTimeStringForQueryNoUtc(criteria.dt_denso_end),
                    dt_zaiko_from: App.data.getDateTimeStringForQueryNoUtc(criteria.dt_zaiko_start),
                    dt_zaiko_to: App.data.getDateTimeStringForQueryNoUtc(criteria.dt_zaiko_end),
                    cd_hinmei: encodeURIComponent(criteria.cd_hinmei),
                    chk_denso: flgDenso,
                    chk_zaiko: flgZaiko,
                    kbn_zaiko: criteria.select_kbn_zaiko,
                    top: querySetting.top
                };

                return query;
            };
            /// <summary>フィルター条件の設定</summary>
            //var createFilter = function () {
            //    var criteria = $(".search-criteria").toJSON(),
            //        filters = [];
            //    // TODO: 画面の仕様に応じて以下のフィルター条件を変更してください。
            //    if (!App.isUndefOrNull(criteria.cd_seihin)) {
            //        filters.push("cd_hinmei eq '" + criteria.cd_seihin + "'");
            //    }
            //    // TODO: ここまで
            //
            //    return filters.join(" and ");
            //};

            /// <summary>データ検索を行います。</summary>
            /// <param name="query">クエリオブジェクト</param>
            var searchItems = function (query) {
                //closeFindConfirmDialog();
                if (isDataLoading == true) {
                    return;
                }
                isDataLoading = true;
                // ローディングの表示
                $("#list-loading-message").text(pageLangText.nowLoading.text);
                App.ajax.webget(
                // WCF Data ServicesのODataシステムクエリオプションを生成
                //App.data.toODataFormat(query)
                    App.data.toWebAPIFormat(query)
                ).done(function (result) {
                    // 検索フラグを立てる
                    isSearch = true;
                    if (result.__count == 0) {
                        App.ui.page.notifyAlert.message(pageLangText.notFound.text).show();
                        // 検索条件を閉じる
                        closeCriteria();
                        $(".ui-jqgrid-hdiv").scrollLeft(0); // 明細のスクロール位置をリセット
                        isCriteriaChange = false;
                    } else {
                        // データバインド
                        bindData(result);
                        // 検索条件を閉じる
                        closeCriteria();
                        $(".ui-jqgrid-hdiv").scrollLeft(0); // 明細のスクロール位置をリセット
                        isCriteriaChange = false;                    
                    }
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                }).always(function () {
                    setTimeout(function () {
                        // ローディングの終了
                        $("#list-loading-message").text("");
                        App.ui.loading.close();
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

            /// <summary>検索時のチェック処理を行います。</summary>
            var checkDateSearch = function () {
                var criteria = $(".search-criteria").toJSON();

                // 項目が1つは入力されているかチェック
                if ((App.isUndefOrNull(criteria.chk_denso)) && (App.isUndefOrNull(criteria.chk_zaiko))
                  && (App.isUndefOrNull(criteria.cd_hinmei))
                ) {
                    App.ui.page.notifyAlert.message(App.str.format(pageLangText.inputCheck.text, pageLangText.requiredInput.text), $("#chk_denso")).show();
                    return false;
                }

                //検索条件/伝送日チェック
                if (criteria.chk_denso != null) {
                    var DateFrom = new Date($(".search-criteria [name='dt_denso_start']").datepicker("getDate"));
                    var DateTo = new Date($(".search-criteria [name='dt_denso_end']").datepicker("getDate"));
                    if (DateFrom > DateTo) {
                        App.ui.page.notifyAlert.message(App.str.format(pageLangText.inputDateError.text, pageLangText.dateDensoEn.text, pageLangText.dateDensoSt.text), $("#dt_denso_start")).show();
                        return false;
                    }
                    chk_dt_denso = pageLangText.chk_search_on.text;
                }
                else {
                    chk_dt_denso = pageLangText.chk_search_non.text;
                }
                //検索条件/製造日チェック
                if (criteria.chk_zaiko != null) {
                    var DateFrom = new Date($(".search-criteria [name='dt_zaiko_start']").datepicker("getDate"));
                    var DateTo = new Date($(".search-criteria [name='dt_zaiko_end']").datepicker("getDate"));
                    if (DateFrom > DateTo) {
                        App.ui.page.notifyAlert.message(App.str.format(pageLangText.inputDateError.text, pageLangText.dateTanaoroshiEn.text, pageLangText.dateTanaoroshiSt.text), $("#dt_zaiko_start")).show();
                        return false;
                    }
                    chk_dt_zaiko = pageLangText.chk_search_on.text;
                }
                else {
                    chk_dt_zaiko = pageLangText.chk_search_non.text;
                }
                return true;
            };

            /// <summary>検索ボタンクリック時のイベント処理を行います。</summary>
            $(".find-button").on("click", function () {
                clearState();
                // 検索条件のバリデーションチェック
                var result = $(".search-criteria").validation().validate();
                if (result.errors.length) {
                    return;
                };
                //日付内容チェックを行います
                if (checkDateSearch() == true) {
                    searchItems(new query());
                }
            });

            // グリッドコントロール固有の検索処理

            /// <summary>検索前の状態に初期化します。</summary>
            var clearState = function () {
                // データクリア
                grid.clearGridData();
                lastScrollTop = 0;
                nextScrollTop = 0;
                querySetting.skip = 0;
                querySetting.count = 0;
                displayCount();

                // TODO: 画面の仕様に応じて以下のパラメータ設定を変更してください。
                currentRow = 0;
                currentCol = firstCol;
                // 変更セットの作成
                changeSet = new App.ui.page.changeSet();
                // TODO: ここまで

                // 情報メッセージのクリア
                App.ui.page.notifyInfo.clear();
                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();
            };
            /// <summary>データ取得件数を表示します。</summary>
            var displayCount = function (count) {
                $("#list-count").text(
                     App.str.format("{0}/{1}", querySetting.skip, querySetting.count)
                );
            };

            /// <summary>データをバインドします。</summary>
            /// <param name="result">検索結果</param>
            var bindData = function (result) {
                querySetting.skip = result.d.length;
                querySetting.count = parseInt(result.__count);

                if (querySetting.count > querySetting.top) {
                    App.ui.page.notifyAlert.message(
                        App.str.format(pageLangText.overData.text, querySetting.count, querySetting.top)
                    ).show();
                }

                // グリッドの表示件数を更新
                grid.setGridParam({ rowNum: querySetting.skip });
                displayCount();
                // データバインド
                grid.destroyFrozenColumns();
                var currentData = grid.getGridParam("data").concat(result.d);
                grid.setGridParam({ data: currentData });
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

            //// バリデーション -- Start

            var isValidHinmeiCode = function (hinmeiCode) {
                var isValid = true;

                var criteria = $(".search-criteria").toJSON();
                var queryHin = {
                    // TODO: 画面の仕様に応じて以下のエンドポイントを変更してください。
                    url: "../Services/FoodProcsService.svc/vw_ma_hinmei_03",
                    filter: "cd_hinmei eq '" + criteria.cd_hinmei + "' and (kbn_hin eq " + pageLangText.genryoHinKbn.text + " or kbn_hin eq " + pageLangText.shizaiHinKbn.text + ")",
                    orderby: "cd_hinmei",
                    select: "cd_hinmei, " + hinmeiName + ", nm_kbn_hin, nm_naiyo",
                    skip: 0,
                    top: 1,
                    inlinecount: "allpages"
                };

                App.ajax.webgetSync(
                    App.data.toODataFormat(queryHin)
                ).done(function (result) {
                    if (result.d.__count == 0) {
                        if ($("#cd_hinmei").val() == "") {
                            $("#nm_hinmei_search").text("");
                            isValid = true;
                        }
                        else {
                            $("#nm_hinmei_search").text("");
                            isValid = false;
                        }
                    }
                    else {
                        if (App.isUndefOrNull(result.d.results[0][hinmeiName])) {
                            $("#nm_hinmei_search").text("");
                        } else {
                            $("#nm_hinmei_search").text(result.d.results[0][hinmeiName]);
                        }
                        isValid = true;
                    }
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                });
                return isValid;
            };

            // 検索条件品名コード：カスタムバリデーション
            validationSetting.cd_hinmei.rules.custom = function (value) {
                return isValidHinmeiCode(value);
            };

            // 検索条件のバリデーション設定
            var v2 = Aw.validation({
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
            $(".search-criteria").validation(v2);

            //// バリデーション -- End

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
            /*
            /// <summary>Excelファイル出力を行います。</summary>
            var printExcel = function (e) {
            var criteria = $(".search-criteria").toJSON();
            var query = {
            url: "../api/NiukeJissekiTraceExcel",
            cd_hinmei: criteria.cd_hinmei,
            nm_hinmei: criteria.nm_genryo_search,
            chk_dt_denso: chk_dt_denso,
            dt_niuke_st: App.data.getDateTimeStringForQuery(criteria.dt_niuke_start),
            dt_niuke_en: App.data.getDateTimeStringForQuery(criteria.dt_niuke_end),
            chk_dt_seizo: chk_dt_seizo,
            dt_seizo_st: App.data.getDateTimeStringForQuery(criteria.dt_seizo_start),
            dt_seizo_en: App.data.getDateTimeStringForQuery(criteria.dt_seizo_end),
            chk_dt_kigen: chk_dt_kigen,
            dt_kigen_st: App.data.getDateTimeStringForQuery(criteria.dt_kigen_start),
            dt_kigen_en: App.data.getDateTimeStringForQuery(criteria.dt_kigen_end),
            chk_no_denpyo: chk_no_denpyo,
            no_denpyo: criteria.no_denpyo,
            chk_no_lot: chk_no_lot,
            genryoLot: criteria.genryoLot,
            chk_cd_torihiki: chk_cd_torihiki,
            cd_torihiki: criteria.cd_torihiki,
            nm_torihiki: criteria.nm_torihiki_search,
            skip: querySetting.skip,
            top: querySetting.top,
            lang: App.ui.page.lang
            };
            var url = App.data.toWebAPIFormat(query);
            window.open(url, '_parent');
            };

            var checkExcel = function () {
            // 情報メッセージのクリア
            App.ui.page.notifyInfo.clear();
            // エラーメッセージのクリア
            App.ui.page.notifyAlert.clear();
            // 明細があるかどうかをチェックし、無い場合は処理を中止します。
            if (querySetting.count == 0) {
            App.ui.page.notifyAlert.message(pageLangText.noRecords.text).show();
            return;
            }
            // 検索条件に変更がないかチェックを行う
            if (isCriteriaChanged) {
            App.ui.page.notifyAlert.message(App.str.format(pageLangText.criteriaChanged.text, pageLangText.searchCriteria.text, pageLangText.printExcel.text)).show();
            return;
            }
            printExcel();
            }

            /// <summary>Excelボタンクリック時のイベント処理を行います。</summary>
            $(".excel-button").on("click", checkExcel);
            */
            // メニュー画面へ戻ります
            var backToMenu = function () {
                try {
                    window.location = pageLangText.menuPath.url;
                } catch (e) {
                    // 何もしない
                }
            };

            /// <summary>メニューボタンクリック時のイベント処理を行います。</summary>
            $(".menu-button").on("click", backToMenu);

            /// <summary> 品名検索ダイアログを表示する処理を行います。 </summary>
            var showHinmeiDialog = function () {
                kbnDialog = pageLangText.seihinHinDlgParam.text;
                var option = { id: 'genryo', multiselect: false, param1: pageLangText.genshizaiHinDlgParam.text };
                hinmeiDialog.draggable(true);
                hinmeiDialog.dlg("open", option);
                return;
            };

            /// <summary> 品名コードテキストボックスダブルクリック時のイベント処理を行います。</summary>
            $("#cd_hinmei").on("dblclick", showHinmeiDialog);
            /// <summary> 品名一覧ボタンクリック時のイベント処理を行います。</summary>
            $("#hinmei-category-button").on("click", showHinmeiDialog);

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
                    <table width="90%">
                        <tr>
                            <td width="5%"  height="20" style="padding-bottom: 5px;">
                                <input type="checkbox" name="chk_denso" id="chk_denso" checked="checked"/>
                                <span class="item-label" data-app-text="dateDensoSt"></span>
                                <input type="text" name="dt_denso_start" id="dt_denso_start" />
                                <span class="item-label" data-app-text="to" style="text-align:center; width:30px;"></span>
                                <span class="item-label" data-app-text="dateDensoEn"></span>
                                <input type="text" name="dt_denso_end" id="dt_denso_end" />
                            </td>
                        </tr>
                        <tr>
                            <td width="5%"  height="20" style="padding-bottom: 5px;">
                                <input type="checkbox" name="chk_zaiko" id="chk_zaiko" checked="checked"/>
                                <span class="item-label" data-app-text="dateTanaoroshiSt"></span>
                                <input type="text" name="dt_zaiko_start" id="dt_zaiko_start" />
                                <span class="item-label" data-app-text="to" style="text-align:center; width:30px;"></span>
                                <span class="item-label" data-app-text="dateTanaoroshiEn"></span>
                                <input type="text" name="dt_zaiko_end" id="dt_zaiko_end" />
                            </td>
                        </tr>
                    </table>
                </li>
                <li>
                    <label>
                        <span class="item-label" data-app-text="codeHinmei" style="padding-left:26px;"></span>
						<input type="text" class="changeCheck" name="cd_hinmei" id="cd_hinmei" maxlength="14" />
                    <button type="button" class="dialog-button" id="hinmei-category-button">
                        <span class="icon"></span><span data-app-text="codeSearch"></span>
                    </button>
                        <span class="item-label"  name="nm_hinmei_search" id="nm_hinmei_search" readonly="readonly" style="margin-left:23px;"></span>
                    </label>
                </li>
                <li>
                    <label>
                        <input type="radio" name="select_kbn_zaiko" id="kbnRyohin1" value="0" checked="checked" />
                        <span class="item-label" style="width: 55px" data-app-text="Both"></span>
                    </label>
                    <label>
                        <input type="radio" name="select_kbn_zaiko" id="kbnRyohin" value="1" />
                        <span class="item-label" style="width: 50px" data-app-text="Ryohin"></span>
                    </label>
                    <label>
                        <input type="radio" name="select_kbn_zaiko" id="kbnHoryu" value="2" />
                        <span class="item-label" style="width: 50px" data-app-text="Horyuhin"></span>
                    </label>
                </li>
                <!-- TODO: ここまで -->
            </ul>
            <!-- <<< ここまで -->
        </div>
        <div class="part-footer">
            <div class="command command-grid">
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
        <h3 id="listHeader" class="part-header">
            <span data-app-text="resultList" style="padding-right: 10px; padding-bottom: 4px;" id="list-results"></span>
            <span class="list-count" id="list-count"></span>
            <span style="padding-left: 50px;" class="list-loading-message" id="list-loading-message"></span>
        </h3>
        <div class="part-body" id="result-grid">
            <div class="list-part-grid-content">
                <div class="item-command" style="left: 17px; right: 17px;">
                    <button type="button" class="colchange-button" data-app-operation="colchange"><span class="icon"></span><span data-app-text="colchange"></span></button>
                </div>
                <table id="item-grid" data-app-operation="itemGrid">
                </table>
            </div>
        </div>
        <!-- グリッドコントロール固有のデザイン -- End -->
    </div>
    <!-- TODO: 画面の仕様に応じて以下のダイアログの設定を変更してください。 -->
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
            <div class="command-detail" style="position: absolute; left: 10px; top: 5px;">
                <button class="dlg-yes-button" name="dlg-yes-button" data-app-text="yes"></button>
            </div>
            <div class="command-detail" style="position: absolute; right: 5px; top: 5px;">
                <button class="dlg-no-button" name="dlg-no-button" data-app-text="no"></button>
            </div>
        </div>
    </div>
    <!-- 画面デザイン -- End -->
</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="FooterContent" runat="server">
    <!-- 画面デザイン -- Start -->

    <!-- 画面アーキテクチャ共通のデザイン -- Start -->
    <!-- 明細画面ボタン（左） -->
    <!--
    <div class="command command-grid" style="left: 1px;">
        <button type="button" class="excel-button" name="excel-button" data-app-operation="excel"><span data-app-text="excel"></span></button>
    </div>
    -->
    <!-- 明細画面ボタン（右） -->
    <div class="command command-grid" style="right: 9px;">
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
    <div class="hinmei-dialog">
    </div>
    <!-- 画面デザイン -- End -->
</asp:Content>
