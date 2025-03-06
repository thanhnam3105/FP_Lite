<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="BomMasterDensoIchiran.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.BomMasterDensoIchiran" %>

<asp:Content ID="Content1" ContentPlaceHolderID="IncludeContent" runat="server">
    <script src="<%=ResolveUrl("~/Resources/pages/pagedata-bommasterdensoichiran." + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
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

        .list-part-detail-content .item-list-left {
            float: left;
            width: 33%;
        }

        .list-part-detail-content .item-list-center {
            float: left;
            width: 33%;
        }

        .list-part-detail-content .item-list-right {
            float: right;
            width: 33%;
            margin-left: 0%;
        }
        
        .list-part-detail-content select {
            width: 5em;
        }
        
        .list-part-detail-content .item-command{
            margin-bottom: 0px;
            border-bottom: none;
        }

        .hinmei-dialog
        {
            background-color: White;
            width: 570px;
        }

        .item-literalOnly {
            display: inline-block;
            background-color: #F2F2F2;
            border-width: thin;
            border-style: solid;
            border-color: #ACADB3
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
        #nm_seihin_search
        {
            width: 350px;
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
                isDataLoading = false,
                lang = App.ui.page.lang;

            // グリッドコントロール固有の変数宣言
            var grid = $("#item-grid"),
                changeSet = new App.ui.page.changeSet(),
                duplicateCol = 999,
                currentRow = 0,
                firstCol = 1,
                maxRecord = 1000,
                nextScrollTop = 0,
                isChanged = false,
                seihinName = 'nm_seihin_' + lang,
                hinmeiName = 'nm_hinmei_' + lang,
                haigoName = 'nm_haigo_' + lang,
                loading;
            var chk_dt_denso,
                chk_dt_nonyu;

            // 英語化対応　言語によって幅を調節
            $(".search-criteria .item-label").css("width", pageLangText.each_lang_width.number);
            $(".search-criteria .item-denso").css("width", pageLangText.lang_item_denso.number);
            $(".search-criteria .denso-tbl").css("width", pageLangText.lang_denso_tbl.number);

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
            var dateformat = function (elm) {
                elm.datepicker({ dateFormat: datePickerFormat });
                elm.on("keyup", App.data.addSlashForDateString);
                elm.datepicker("setDate", new Date);
                elm.datepicker("option", "maxDate", new Date(pageLangText.maxDate.text));
                elm.datepicker("option", "minDate", new Date(pageLangText.minDate.text));
            };
            dateformat($("#dt_denso_start"));
            dateformat($("#dt_denso_end"));

            /// 製品、配合、品名のコード検索のダイアログ
            var dlg_elmCode,
                dlg_elmName;
            var hinmeiDialog = $(".hinmei-dialog");
            hinmeiDialog.dlg({
                url: "Dialog/HinmeiDialog.aspx",
                name: "HinmeiDialog",
                closed: function (e, data, data2) {
                    if (data == "canceled") {
                        return;
                    }
                    else {
                        // 品名マスタセレクタから取得した名称とコードを設定
                        dlg_elmName.text(data2);
                        dlg_elmCode.val(data);
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
                    pageLangText.kbn_denso.text,
                    pageLangText.cd_seihin.text,
                    pageLangText.nm_seihin.text,
                    pageLangText.dt_from.text,
                    pageLangText.su_kihon.text,
                    pageLangText.cd_hinmei.text,
                    pageLangText.nm_hinmei.text,
                    pageLangText.su_hinmoku.text,
                    pageLangText.cd_tani.text,
                    pageLangText.cd_tani.text,
                    pageLangText.su_kaiso.text,
                    pageLangText.cd_haigo.text,
                    pageLangText.nm_haigo.text,
                    pageLangText.no_kotei.text,
                    pageLangText.no_tonyu.text
                ],
                colModel: [
                    { name: 'dt_denso', width: 150, sorttype: "date",
                        formatter: "date",
                        formatoptions: {
                            srcformat: newDateTimeFormat, newformat: newDateTimeFormat
                        }
                    },
                    { name: 'kbn_denso_SAP', width: pageLangText.kbn_denso_width.number, sorttype: "text", align: "left",
                        formatter: setDensoKubun
                    },
                    { name: 'cd_seihin', width: 120, editable: false, align: 'left', sorttype: "text" },
                    { name: seihinName, width: 250, editable: false, align: 'left', sorttype: "text" },
                    { name: 'dt_from', width: pageLangText.dt_from_width.number, sorttype: "date",
                        formatter: "date",
                        formatoptions: {
                            srcformat: newDateFormat, newformat: newDateFormat
                        }
                    },
                    { name: 'su_kihon', width: pageLangText.su_kihon_width.number, sorttype: "int", align: "right",
                        formatter: 'integer',
                        formatoptions: {
                            thousandsSeparator: ",", decimalPlaces: 0, defaultValue: ""
                        }
                    },
                    { name: 'cd_hinmei', width: 120, editable: false, align: 'left', sorttype: "text" },
                    { name: hinmeiName, width: 220, editable: false, align: 'left', sorttype: "text" },
                    { name: 'su_hinmoku', width: pageLangText.su_hinmoku_width.number, sorttype: "int", align: "right",
                        formatter: 'integer',
                        formatoptions: {
                            thousandsSeparator: ",", decimalPlaces: 0, defaultValue: ""
                        }
                    },
                    { name: 'cd_tani', width: 0, hidden: true, hidedlg: true },
                    { name: 'nm_tani', width: 80, editable: false, align: 'left', sorttype: "text" },
                    { name: 'su_kaiso', width: pageLangText.su_kaiso_width.number, editable: false, align: 'right', sorttype: "text" },
                    { name: 'cd_haigo', width: 120, editable: false, align: 'left', sorttype: "text" },
                    { name: haigoName, width: 230, editable: false, align: 'left', sorttype: "text",
                        formatter: setHaigoName
                    },
                    { name: 'no_kotei', width: pageLangText.no_kotei_width.number, editable: false, align: 'left', sorttype: "text" },
                    { name: 'no_tonyu', width: 200, editable: false, align: 'left', sorttype: "text" }
                ],
                datatype: "local",
                shrinkToFit: false,
                multiselect: false,
                rownumbers: true,
                hoverrows: false,
                gridComplete: function () {
                    // グリッドの先頭行選択
                    // gridCompleteまたはloadCompleteに記述しないとグリッドのソートで先頭行が選択されない
                    var idNum = grid.getGridParam("selrow");
                    if (App.isUndefOrNull(idNum)) {
                        $("#1 > td").click();
                    }
                    else {
                        $("#" + idNum).removeClass("ui-state-highlight").find("td").click();
                    }
                }
            });
            // 伝送区分の名称を設定
            function setDensoKubun(value, options, rowObj) {
                var returnVal;
                var densoData = pageLangText.densoKunbunId.data;
                for (var i = 0; i < densoData.length; i++) {
                    if (value == densoData[i].id) {
                        returnVal = densoData[i].name;
                        break;
                    }
                }
                return returnVal;
            }
            // 配合名の設定
            function setHaigoName(value, options, rowObj) {
                var returnVal = value;
                // 配合名称がすべてnullのときは資材(配合コードには製品コードが入っている)なので、製品名を設定にする
                var name_j = rowObj.nm_haigo_ja,
                    name_e = rowObj.nm_haigo_en,
                    name_z = rowObj.nm_haigo_zh;
                    name_v = rowObj.nm_haigo_vi;
                if ((App.isUndefOrNull(name_j) || name_j == "")
                    && (App.isUndefOrNull(name_e) || name_e == "")
                    && (App.isUndefOrNull(name_z) || name_z == "")
                    && (App.isUndefOrNull(name_v) || name_v == "")) {
                    var nm_seihin = rowObj[seihinName];
                    if (App.isUndefOrNull(nm_seihin)) {
                        // 製品名がnullの場合は空文字
                        returnVal = "";
                    }
                    else {
                        returnVal = rowObj[seihinName];
                    }
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

            /// <summary>クエリオブジェクトの設定</summary>
            var query = function () {
                var query = {
                    url: "../Services/FoodProcsService.svc/vw_ma_sap_bom_denso_pool",
                    filter: createFilter(),
                    orderby: "dt_denso desc, cd_seihin, su_kaiso, cd_haigo, cd_hinmei, kbn_denso_SAP desc",
                    top: querySetting.top,
                    inlinecount: "allpages"
                }
                return query;
            };

            /// <summary>フィルター条件の設定</summary>
            var createFilter = function () {
                var criteria = $(".search-criteria").toJSON(),
                    filters = [];
                filters.push("dt_denso ge DateTime'" + App.data.getDateTimeStringForQueryNoUtc(criteria.dt_denso_start) + "'");
                filters.push("dt_denso le DateTime'" + App.data.getDateTimeStringForQueryNoUtc(criteria.dt_denso_end) + "'");
                if (!App.isUndefOrNull(criteria.cd_seihin)) {
                    filters.push("cd_seihin eq '" + criteria.cd_seihin + "'");
                }
                if (!App.isUndefOrNull(criteria.cd_haigo)) {
                    filters.push("cd_haigo eq '" + criteria.cd_haigo + "'");
                }
                if (!App.isUndefOrNull(criteria.cd_hinmei)) {
                    filters.push("cd_hinmei eq '" + criteria.cd_hinmei + "'");
                }

                return filters.join(" and ");
            };

            /// <summary>データ検索を行います。</summary>
            /// <param name="query">クエリオブジェクト</param>
            var searchItems = function (query) {
                //closeFindConfirmDialog();
                if (isDataLoading == true) {
                    return;
                }
                // ローディングの表示
                $("#list-loading-message").text(pageLangText.nowLoading.text);
                isDataLoading = true;
                App.ajax.webget(
                    App.data.toODataFormat(query)
                ).done(function (result) {
                    // 検索フラグを立てる
                    isSearch = true;
                    if (result.d.__count == "0") {
                        App.ui.page.notifyAlert.message(pageLangText.notFound.text).show();
                    }
                    else {
                        // データバインド
                        bindData(result);
                        // 検索条件を閉じる
                        closeCriteria();
                        $(".ui-jqgrid-hdiv").scrollLeft(0); // 明細のスクロール位置をリセット
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

                // 検索条件/伝送日チェック
                var DateFrom = new Date($("#dt_denso_start").datepicker("getDate")),
                    DateTo = new Date($("#dt_denso_end").datepicker("getDate")),
                    unique = $("#dt_denso_start");
                // 開始日 > 終了日の場合はエラー
                if (DateFrom > DateTo) {
                    App.ui.page.notifyAlert.message(
                        App.str.format(pageLangText.inputDateError.text, pageLangText.dateDensoEn.text, pageLangText.dateDensoSt.text)
                        , unique
                    ).show();
                    return false;
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
                querySetting.skip = result.d.results.length;
                querySetting.count = parseInt(result.d.__count);

                // 検索結果が上限数を超えていた場合
                if (parseInt(result.d.__count) > querySetting.top) {
                    App.ui.page.notifyAlert.message(
                        App.str.format(pageLangText.overSearchNumber.text, querySetting.count, querySetting.top)
                    ).show();
                }

                // グリッドの表示件数を更新
                grid.setGridParam({ rowNum: querySetting.skip });
                displayCount();
                // データバインド
                var currentData = grid.getGridParam("data").concat(result.d.results);
                grid.setGridParam({ data: currentData }).trigger('reloadGrid', [{ current: true}]);
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

            /// <summary>品名マスタ検索：製品コード、品名コードの検索処理</summary>
            /// <param name="hinmeiCode">製品コードまたは品名コード</param>
            /// <param name="flgSeihin">製品コードの検索の場合はtrue</param>
            var isValidHinmeiCode = function (hinmeiCode, flgSeihin) {
                var isValid = true;
                var elmName = $("#nm_seihin_search");

                // where句の作成
                var whereKubun = "cd_hinmei eq '" + hinmeiCode;
                if (flgSeihin) {
                    // 製品コード検索の場合
                    whereKubun = whereKubun + "' and kbn_hin eq " + pageLangText.seihinHinKbn.text;
                }
                else {
                    // 品名コード検索の場合
                    whereKubun = whereKubun + "' and ( kbn_hin eq " + pageLangText.genryoHinKbn.text
                        + " or kbn_hin eq " + pageLangText.shizaiHinKbn.text + ")";
                    // 名称の設定先を品名に変える
                    elmName = $("#nm_hinmei_search");
                }

                // 品名コードに入力がなければ名称をクリアして処理を中止する
                if (hinmeiCode == "") {
                    elmName.text("");
                    return isValid;
                }

                var queryHin = {
                    url: "../Services/FoodProcsService.svc/vw_ma_hinmei_03",
                    filter: whereKubun,
                    orderby: "cd_hinmei",
                    select: "cd_hinmei, " + hinmeiName,
                    skip: 0,
                    top: 1,
                    inlinecount: "allpages"
                };

                App.ajax.webgetSync(
                    App.data.toODataFormat(queryHin)
                ).done(function (result) {
                    if (result.d.__count == 0) {
                        // 取得件数0（該当なし）
                        elmName.text("");
                        isValid = false;
                    }
                    else {
                        // 取得OK
                        var hinName = result.d.results[0][hinmeiName];
                        if (App.isUndefOrNull(hinName)) {
                            hinName = "";
                        }
                        elmName.text(hinName);
                        isValid = true;
                    }
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                });
                return isValid;
            };

            /// <summary>配合名マスタ検索：配合コードの検索処理</summary>
            /// <param name="haigoCode">配合コード</param>
            var isValidHaigoCode = function (haigoCode) {
                var isValid = true;
                if (haigoCode == "") {
                    $("#nm_haigo_search").text("");
                    return isValid;
                }

                var query = {
                    url: "../api/YukoHaigoMei"
                    , cd_hinmei: haigoCode
                    , dt_seizo: App.data.getDateTimeStringForQueryNoUtc(new Date())
                    , flg_mishiyo: pageLangText.falseFlg.text
                };
                App.ajax.webgetSync(
                    App.data.toWebAPIFormat(query)
                ).done(function (result) {
                    if (result.__count == 0) {
                        // 取得件数0（該当なし）
                        $("#nm_haigo_search").text("");
                        isValid = false;
                    }
                    else {
                        // 取得OK
                        var name = result.d[0][haigoName];
                        if (App.isUndefOrNull(name)) {
                            name = "";
                        }
                        $("#nm_haigo_search").text(name);
                        isValid = true;
                    }
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                });
                return isValid;
            };

            // 検索条件/製品コード：カスタムバリデーション
            validationSetting.cd_seihin.rules.custom = function (value) {
                return isValidHinmeiCode(value, true);
            };
            // 検索条件/配合コード：カスタムバリデーション
            validationSetting.cd_haigo.rules.custom = function (value) {
                return isValidHaigoCode(value);
            };
            // 検索条件/品名コード：カスタムバリデーション
            validationSetting.cd_hinmei.rules.custom = function (value) {
                return isValidHinmeiCode(value, false);
            };

            var createFilterDialog = function () {
                var criteria = $(".search-criteria").toJSON(),
                        filters = [];
                // TODO: 画面の仕様に応じて以下のフィルター条件を変更してください。
                // 分類名指定
                filters.push("cd_torihiki eq '" + criteria.cd_torihiki + "'");
                // TODO：ここまで

                return filters.join(" and ");
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

            // メニュー画面へ戻ります
            var backToMenu = function () {
                try {
                    window.location = pageLangText.menuPath.url;
                }
                catch (e) {
                    // 何もしない
                }
            };

            /// <summary>メニューボタンクリック時のイベント処理を行います。</summary>
            $(".menu-button").on("click", backToMenu);

            /// <summary>品名検索ダイアログを表示する処理を行います。</summary>
            /// <param name="buttonName">押下されたボタンの名前</param>
            var showHinmeiDialog = function (buttonName) {
                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();

                // 押下されたボタンによってパラメーターを変更する(デフォルト：製品)
                var kbnDialog = pageLangText.seihinHinDlgParam.text;
                if (buttonName == "haigo") {
                    kbnDialog = pageLangText.shikakariHinDlgParam.text;
                }
                else if (buttonName == "hinmei") {
                    kbnDialog = pageLangText.genshizaiHinDlgParam.text;
                }

                var option = { id: 'hinmeiDialog', multiselect: false, param1: kbnDialog };
                hinmeiDialog.draggable(true);
                hinmeiDialog.dlg("open", option);
            };
            var dlgSeihin = function () {
                dlg_elmCode = $("#cd_seihin");
                dlg_elmName = $("#nm_seihin_search");
                showHinmeiDialog("seihin");
            };
            var dlgHaigo = function () {
                dlg_elmCode = $("#cd_haigo");
                dlg_elmName = $("#nm_haigo_search");
                showHinmeiDialog("haigo");
            };
            var dlgHinmei = function () {
                dlg_elmCode = $("#cd_hinmei");
                dlg_elmName = $("#nm_hinmei_search");
                showHinmeiDialog("hinmei");
            };

            /// <summary>コードテキストボックスダブルクリック時のイベント処理を行います。</summary>
            $("#cd_seihin").on("dblclick", dlgSeihin);
            $("#cd_haigo").on("dblclick", dlgHaigo);
            $("#cd_hinmei").on("dblclick", dlgHinmei);
            /// <summary>コード検索ボタンクリック時のイベント処理を行います。</summary>
            $("#seihin-category-button").on("click", dlgSeihin);
            $("#haigo-category-button").on("click", dlgHaigo);
            $("#hinmei-category-button").on("click", dlgHinmei);
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
                    <table class="denso-tbl" height="25">
                        <tr>
                            <td height="20" width="235" style="padding-bottom: 5px;">
                                <span class="item-denso" data-app-text="dateDensoSt"></span>
                                <input type="text" name="dt_denso_start" id="dt_denso_start" />
                            </td>
                            <td height="20" width="30" style="padding-bottom: 5px;" align="center">
                                <span data-app-text="to" />
                            </td>
                            <td height="20" width="235" style="padding-bottom: 5px;">
                                <span class="item-denso" data-app-text="dateDensoEn"></span>
                                <input type="text" name="dt_denso_end" id="dt_denso_end" />
                            </td>
                        </tr>
                    </table>
                </li>
                <li>
                    <table width="800" height="31">
                        <tr>
                            <td width="270" style="vertical-align: middle;">
                                <span class="item-label" data-app-text="codeSeihin"></span>
						        <input type="text" class="changeCheck" name="cd_seihin" id="cd_seihin" maxlength="14" />
                            </td>
                            <td width="530" style="vertical-align: middle;">
                                <button type="button" class="dialog-button" id="seihin-category-button">
                                    <span class="icon"></span><span data-app-text="codeSearch"></span>
                                </button>
                                <span id="nm_seihin_search" style="width: 400px; margin-left:10px;"></span>
                            </td>
                        </tr>
                    </table>
                </li>
                <li>
                    <table width="800" height="31">
                        <tr>
                            <td width="270" style="vertical-align: middle;">
                                <span class="item-label" data-app-text="codeHaigo"></span>
						        <input type="text" class="changeCheck" name="cd_haigo" id="cd_haigo" maxlength="14" />
                            </td>
                            <td width="530" style="vertical-align: middle;">
                                <button type="button" class="dialog-button" id="haigo-category-button">
                                    <span class="icon"></span><span data-app-text="codeSearch"></span>
                                </button>
                                <span id="nm_haigo_search" style="width: 400px; margin-left:10px;"></span>
                            </td>
                        </tr>
                    </table>
                </li>
                <li>
                    <table width="800" height="31">
                        <tr>
                            <td width="270" style="vertical-align: middle;">
                                <span class="item-label" data-app-text="codeHinmei"></span>
						        <input type="text" class="changeCheck" name="cd_hinmei" id="cd_hinmei" maxlength="14" />
                            </td>
                            <td width="530" style="vertical-align: middle;">
                                <button type="button" class="dialog-button" id="hinmei-category-button">
                                    <span class="icon"></span><span data-app-text="codeSearch"></span>
                                </button>
                                <span id="nm_hinmei_search" style="width: 400px; margin-left:10px;"></span>
                            </td>
                        </tr>
                    </table>
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
