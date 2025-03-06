<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="GenkaIchiran.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.GenkaIchiran" %>

<asp:Content ID="Content1" ContentPlaceHolderID="IncludeContent" runat="server">
    <script src="<%=ResolveUrl("~/Resources/pages/pagedata-genkaichiran." + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
    <script src="<%=ResolveUrl("~/Resources/grid/grid.locale-" + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
    <script src="<%=ResolveUrl("~/Scripts/util/app-util.js") %>" type="text/javascript"></script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        /* 画面デザイン -- Start */

        /*
            2014/5/28 ADMAX中村　このモックアップは品名マスタ画面(HinmeiMasterIchiran.aspx)をコピーして作成しています。
            変更箇所は[ADMAX中村]から辿れます。
        */

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

        #id_nm_seihin {
            width: 400px !important;
        }
        /* >>> 2014/5/28 ADMAX中村 ここから：原価一覧用のCSS追加 */
        .ui-datepicker-calendar {
            display:none;
        }
        /* <<< */
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

            // 英語化対応　言語によって幅を調節
            $(".search-criteria .item-label").css("width", pageLangText.each_lang_width.number);

            //// 変数宣言 -- End

            //// コントロール定義 -- Start

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
                        $("#id_nm_seihin").text(data2);
                        $("#id_cd_seihin").val(data);
                        // 再チェックで背景色とメッセージのリセット
                        $(".part-body .item-list").validation().validate();
                    }
                }
            });

            // ダイアログ固有の変数宣言
            var saveConfirmDialog = $(".save-confirm-dialog");

            // ダイアログ固有のコントロール定義
            saveConfirmDialog.dlg();

            /// 品名マスタセレクタを起動する
            var showHinmeiDialog = function () {
                var dlgParam = pageLangText.seihinHinDlgParam.text;
                option = { id: 'hinmei', multiselect: false, param1: dlgParam };
                hinmeiDialog.draggable(true);
                //hinmeiDialog.draggable({ containment: document.body, scroll: false });    // IE以外では挙動がおかしい？保留中
                hinmeiDialog.dlg("open", option);
            };

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

            // 日付の多言語対応
            var dateSrcFormat = pageLangText.dateSrcFormatUS.text;
            var newDateFormat = pageLangText.dateTimeNewFormatUS.text;
            if (App.ui.page.langCountry !== 'en-US') {
                dateSrcFormat = pageLangText.dateSrcFormat.text;
                newDateFormat = pageLangText.dateTimeNewFormat.text;
            }

            // TODO：画面の仕様に応じて以下の datepicker の設定を変更してください。
            // >>> 2014/5/28 ADMAX中村 ここから：年月のみのdatepickerの設定
            $("#id_dt_seizo").datepicker({
                changeMonth: true,
                changeYear: true,
                showButtonPanel: true,
                dateFormat: pageLangText.yearMonthFormat.text,
                minDate: new Date(2000, 1 - 1, 1),  // 有効範囲：2000/1～3000/12
                maxDate: new Date(3000, 12 - 1, 1),
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
            })
            // 初期値：システム日付を設定
            $("#id_dt_seizo").datepicker("setDate", new Date());
            // <<< ここまで
            // TODO：ここまで

            // >>> 2014/5/28 ADMAX中村 ここから：検索条件．年月（必須項目）への*印追加処理
            // 必須項目
            $("#id_dt_seizo").prev().text(pageLangText.dt_seizo.text + pageLangText.requiredMark.text);
            // <<< ここまで

            // グリッドコントロール固有のコントロール定義

            /// <summary>明細項目の計算処理</summary>
            var calMeisai = function () {

                var ids = grid.jqGrid('getDataIDs');
                for (var i = 0; i < ids.length; i++) {
                    var id = ids[i],
                        su_seizo = parseFloat(grid.getCell(id, "su_seizo_jisseki")),    // 製造数
                        genryo = parseFloat(grid.getCell(id, "kin_genryo")),            // 原料
                        shizai = parseFloat(grid.getCell(id, "kin_shizai")),            // 資材
                        genka_cs = parseFloat(grid.getCell(id, "tan_genka_cs")),        // 原価単価_CS
                        genka_romu = parseFloat(grid.getCell(id, "tan_genka_romu")),    // 原価単価_労務
                        genka_keihi = parseFloat(grid.getCell(id, "tan_genka_keihi"));  // 原価単価_経費

                    // 金額：製造数ｘ原価単価_CS
                    var kingaku = App.data.trimFixed(su_seizo * genka_cs);
                    // 材料費計：原料＋資材
                    var zairyo = App.data.trimFixed(genryo + shizai);
                    // 労務費：製造数ｘ原価単価_労務
                    var romu = App.data.trimFixed(su_seizo * genka_romu);
                    // 経費：製造数ｘ原価単価_経費
                    var keihi = App.data.trimFixed(su_seizo * genka_keihi);
                    // 経費計：労務費＋経費
                    var keihiTotal = App.data.trimFixed(romu + keihi);
                    // 原価：材料費計＋経費計
                    var genka = App.data.trimFixed(zairyo + keihiTotal);
                    // 粗利：金額－原価
                    var arari = App.data.trimFixed(kingaku - genka);

                    // ---------- 明細への設定
                    // 明細/金額
                    grid.setCell(id, "kin_kingaku", kingaku);
                    // 明細/材料費計
                    grid.setCell(id, "kei_zairyo", zairyo);
                    // 明細/労務費
                    grid.setCell(id, "kin_roumu", romu);
                    // 明細/経費
                    grid.setCell(id, "kin_kei", keihi);
                    // 明細/経費計
                    grid.setCell(id, "kei_keihi", keihiTotal);
                    // 明細/原価
                    grid.setCell(id, "kin_genka", genka);
                    // 明細/粗利
                    grid.setCell(id, "kin_arari", arari);
                }
            };

            // >>> 2014/5/28 ADMAX中村 ここから：明細の設定
            grid.jqGrid({
                colNames: [
                    pageLangText.cd_seihin.text
                    , pageLangText.nm_seihin.text
                    , pageLangText.nm_nisugata.text
                    , pageLangText.su_seizo_cs.text
                    , pageLangText.tan_cs.text
                    , pageLangText.kin_kingaku.text
                    , pageLangText.kin_genryo.text
                    , pageLangText.kin_shizai.text
                    , pageLangText.kei_zairyo.text
                    , pageLangText.kin_roumu.text
                    , pageLangText.kin_kei.text
                    , pageLangText.kei_keihi.text
                    , pageLangText.kin_genka.text
                    , pageLangText.kin_arari.text
                    , "hidden_tan_genka_romu"
                    , "hidden_tan_genka_keihi"
                ],
                colModel: [
                    { name: 'cd_hinmei', width: pageLangText.cd_seihin_width.number, frozen: true, sorttype: "text", align: "left" },
                    { name: hinmeiName, width: pageLangText.nm_seihin_width.number, frozen: true, sorttype: "text", align: "left" },
                    { name: 'nm_nisugata_hyoji', width: pageLangText.nm_nisugata_hyoji_width.number, frozen: true, sorttype: "text", align: "left" },
                    { name: 'su_seizo_jisseki', width: pageLangText.su_seizo_width.number, frozen: true, sorttype: "int", align: "right",
                        formatter: 'integer',
                        formatoptions: {
                            thousandsSeparator: ",", decimalPlaces: 0, defaultValue: "0"
                        }
                    },
                    { name: 'tan_genka_cs', width: pageLangText.tan_cs_hyoji_width.number, sorttype: "int", align: "right",
                        formatter: 'integer',
                        formatoptions: {
                            thousandsSeparator: ",", decimalPlaces: 0, defaultValue: "0"
                        }
                    },
                    { name: 'kin_kingaku', width: pageLangText.kin_kingaku_width.number, sorttype: "int", align: "right",
                        formatter: 'integer',
                        formatoptions: {
                            thousandsSeparator: ",", decimalPlaces: 0, defaultValue: "0"
                        }
                    },
                    { name: 'kin_genryo', width: pageLangText.kin_genryo_width.number, sorttype: "int", align: "right",
                        formatter: 'integer',
                        formatoptions: {
                            thousandsSeparator: ",", decimalPlaces: 0, defaultValue: "0"
                        }
                    },
                    { name: 'kin_shizai', width: pageLangText.kin_shizai_width.number, sorttype: "int", align: "right",
                        formatter: 'integer',
                        formatoptions: {
                            thousandsSeparator: ",", decimalPlaces: 0, defaultValue: "0"
                        }
                    },
                    { name: 'kei_zairyo', width: pageLangText.kei_zairyo_width.number, sorttype: "int", align: "right",
                        formatter: 'integer',
                        formatoptions: {
                            thousandsSeparator: ",", decimalPlaces: 0, defaultValue: "0"
                        }
                    },
                    { name: 'kin_roumu', width: pageLangText.kin_roumu_width.number, sorttype: "int", align: "right",
                        formatter: 'integer',
                        formatoptions: {
                            thousandsSeparator: ",", decimalPlaces: 0, defaultValue: "0"
                        }
                    },
                    { name: 'kin_kei', width: pageLangText.kin_kei_width.number, sorttype: "int", align: "right",
                        formatter: 'integer',
                        formatoptions: {
                            thousandsSeparator: ",", decimalPlaces: 0, defaultValue: "0"
                        }
                    },
                    { name: 'kei_keihi', width: pageLangText.kei_keihi_width.number, sorttype: "int", align: "right",
                        formatter: 'integer',
                        formatoptions: {
                            thousandsSeparator: ",", decimalPlaces: 0, defaultValue: "0"
                        }
                    },
                    { name: 'kin_genka', width: pageLangText.kin_genka_width.number, sorttype: "int", align: "right",
                        formatter: 'integer',
                        formatoptions: {
                            thousandsSeparator: ",", decimalPlaces: 0, defaultValue: "0"
                        }
                    },
                    { name: 'kin_arari', width: pageLangText.kin_arari_width.number, sorttype: "int", align: "right",
                        formatter: 'integer',
                        formatoptions: {
                            thousandsSeparator: ",", decimalPlaces: 0, defaultValue: "0"
                        }
                    },
                    { name: 'tan_genka_romu', width: 0, hidden: true, hidedlg: true },
                    { name: 'tan_genka_keihi', width: 0, hidden: true, hidedlg: true }
                ],
                // <<< ここまで
                datatype: "local",
                shrinkToFit: false,
                multiselect: false,
                rownumbers: true,
                hoverrows: false,
                gridComplete: function () {
                    var ids = grid.jqGrid('getDataIDs');
                    if (ids.length > 0) {
                        // 明細項目の計算処理
                        calMeisai();

                        // グリッドの先頭行選択
                        // gridCompleteまたはloadCompleteに記述しないとグリッドのソートで先頭行が選択されない
                        grid.setSelection(1, false);
                    }
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

            //// 操作制御定義
            App.ui.pagedata.operation.applySetting(App.ui.page.user.Roles[0], App.ui.page.lang);

            //// 事前データロード -- Start

            // 画面アーキテクチャ共通の事前データロード
            // >>> 2014/5/28 ADMAX中村 ここから：検索条件のコンボボックスのデータ取得処理を変更
            App.deferred.parallel({
                loading: App.ui.loading.show(pageLangText.nowProgressing.text),
                // 職場
                nmShokuba: App.ajax.webget("../Services/FoodProcsService.svc/ma_shokuba?$filter=flg_mishiyo eq " + pageLangText.falseFlg.text),
                // ライン
                //nmLine: App.ajax.webget("../Services/FoodProcsService.svc/ma_line?$filter=flg_mishiyo eq " + pageLangText.falseFlg.text),
                // 分類
                nmBunrui: App.ajax.webget("../Services/FoodProcsService.svc/ma_bunrui?$filter=flg_mishiyo eq " + pageLangText.falseFlg.text)
            }).done(function (result) {
                nmShokuba = result.successes.nmShokuba.d;
                //nmLine = result.successes.nmLine.d;
                nmBunrui = result.successes.nmBunrui.d;
                // 検索用ドロップダウンの設定
                App.ui.appendOptions($("#id_cd_shokuba"), "cd_shokuba", "nm_shokuba", nmShokuba, true);
                //App.ui.appendOptions($(".search-criteria [name='nm_line']"), "cd_line", "nm_line", nmLine, true);
                App.ui.appendOptions($("#id_cd_bunrui"), "cd_bunrui", "nm_bunrui", nmBunrui, true);
                setLine();  // ラインの設定
                // <<< ここまで
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

            /// <summary>ライン取得用クエリオブジェクトの設定</summary>
            var queryLine = function () {
                var query = {
                    url: "../Services/FoodProcsService.svc/ma_line",
                    filter: createLineFilter(),
                    inlinecount: "allpages"
                };
                return query;
            };
            /// <summary>ライン取得用フィルター条件の設定</summary>
            var createLineFilter = function () {
                var criteria = $(".search-criteria").toJSON(),
                    filters = [];

                filters.push("flg_mishiyo eq " + pageLangText.falseFlg.text);
                if (!App.isUndefOrNull(criteria.nm_shokuba)) {
                    filters.push("cd_shokuba eq '" + criteria.nm_shokuba + "'");
                }

                return filters.join(" and ");
            };
            /// <summary>検索条件：職場変更時のイベント処理を行います。</summary>
            var setLine = function () {
                // 職場の値を元に、ラインコンボボックスの値を再設定します。

                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();
                var query = queryLine();
                // ローディングの表示
                //App.ui.loading.show(pageLangText.nowProgressing.text)
                App.ajax.webget(
                    App.data.toODataFormat(query)
                ).done(function (result) {
                    // 取得処理成功時

                    // データが存在した場合
                    if (result.d.__count > 0) {
                        // ラインの中身をクリア
                        $("#id_cd_line option").remove();
                        // 検索用ドロップダウンの設定
                        App.ui.appendOptions($("#id_cd_line"), "cd_line", "nm_line", result.d.results, true);
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
                    //}).always(function () {
                    //    App.ui.loading.close();
                });
            };
            $("#id_cd_shokuba").on("change", setLine);

            /// 値をyyyy/MM/dd hh:mm:ddにする
            var getFormatDate = function (valDate) {
                var date = App.data.getDate(valDate);
                var formatDate = App.data.getDateTimeString(date, true);
                return formatDate;
            };

            //// 事前データロード -- End

            //// 検索処理 -- Start

            // 画面アーキテクチャ共通の検索処理

            /// <summary>クエリオブジェクトの設定</summary>
            var query = function () {

                var criteria = $(".search-criteria").toJSON();
                var con_dt_from = new Date(criteria.dt_seizo.getFullYear(), criteria.dt_seizo.getMonth(), 1),
                    con_dt_to = new Date(criteria.dt_seizo.getFullYear(), criteria.dt_seizo.getMonth() + 1, 0);

                // マスタ単価使用のチェック有無
                var master_tanka = pageLangText.falseFlg.text;
                if ($("#id_master_tanka").prop('checked')) {
                    master_tanka = pageLangText.trueFlg.text;
                }

                var query = {
                    url: "../api/GenkaIchiran",
                    dt_from: App.data.getDateTimeStringForQueryNoUtc(con_dt_from),
                    dt_to: App.data.getDateTimeStringForQueryNoUtc(con_dt_to),
                    cd_shokuba: criteria.nm_shokuba,
                    cd_line: criteria.nm_line,
                    cd_bunrui: criteria.nm_bunrui,
                    cd_hinmei: criteria.cd_seihin,
                    lang: App.ui.page.lang,
                    tanka_settei: criteria.select_tanka,
                    master_tanka: master_tanka,
                    top: querySetting.top
                }
                return query;
            };
            /// <summary>データ検索を行います。</summary>
            /// <param name="query">クエリオブジェクト</param>
            var searchItems = function (query) {
                if (isDataLoading === true) {
                    return;
                }
                isDataLoading = true;
                nextScrollTop = $(".ui-jqgrid-bdiv").scrollTop() - 30;
                // ローディングの表示
                $("#list-loading-message").text(pageLangText.nowLoading.text);
                App.ajax.webget(
                    App.data.toWebAPIFormat(query)
                ).done(function (result) {
                    // データバインド
                    bindData(result);
                    // 検索条件を閉じる
                    closeCriteria();
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                }).always(function () {
                    // ローディングの終了
                    setTimeout(function () {
                        $("#list-loading-message").text("");
                        isDataLoading = false;
                    }, 500);
                    App.ui.loading.close();
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
                var result = $(".part-body .item-list").validation().validate();
                if (result.errors.length) {
                    return;
                }
                clearState();
                searchItems(new query());
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

                currentRow = 0;

                // 情報メッセージのクリア
                App.ui.page.notifyInfo.clear();
                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();
            };
            /// <summary>データ取得件数を表示します。</summary>
            var displayCount = function () {
                $("#list-count").text(
                     App.str.format("{0}/{1}", querySetting.skip, querySetting.count)
                );
            };
            /// <summary>データをバインドします。</summary>
            /// <param name="result">検索結果</param>
            var bindData = function (result) {
                var resultLength = result.d.length,
                    resultCount = result.__count;
                result = result.d;

                querySetting.skip = querySetting.skip + resultCount;
                querySetting.count = parseInt(resultCount);

                // 検索結果が上限数を超えていた場合
                if (parseInt(resultLength) > querySetting.top) {
                    // 上限数を超えた検索結果は削除する
                    result.splice(querySetting.top, resultLength);
                    querySetting.skip = querySetting.top;
                    App.ui.page.notifyAlert.message(pageLangText.limitOver.text).show();
                }

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

            //// データ変更処理 -- End

            //// 保存処理 -- Start
            //// 保存処理 -- Start

            //// バリデーション -- Start

            // グリッド固有のバリデーション

            /// <summary>品名を取得します。(マスタ存在チェック)</summary>
            /// <param name="cdHinmei">原資材コード</param>
            var isValidHinCode = function (cdHinmei) {
                // 品名コードが未入力の場合はチェックを行わない
                if (App.isUndefOrNull(cdHinmei)
                    || cdHinmei.length === 0) {
                    $("#id_nm_seihin").text("");
                    return true;
                }

                var isValid = true,
                    query = {
                        url: "../Services/FoodProcsService.svc/ma_hinmei",
                        filter: "cd_hinmei eq '" + cdHinmei + "' and "
                                + "kbn_hin eq " + pageLangText.seihinHinKbn.text
                                + " and flg_mishiyo eq " + pageLangText.shiyoMishiyoFlg.text,
                        top: 1
                    };

                // 品名マスタ存在チェック
                App.ajax.webgetSync(
                    App.data.toODataFormat(query)
                ).done(function (result) {
                    if (result.d.length === 0) {
                        // 検索結果件数が0件の場合

                        // 品名マスタ存在チェックエラー
                        $("#id_nm_seihin").text("");
                        isValid = false;
                    }
                    else {
                        // 検索結果が取得できた場合

                        // 検索条件/品名に取得した原資材名を設定
                        $("#id_nm_seihin").text(result.d[0][hinmeiName]);
                    }
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                    isValid = false;
                });
                return isValid;
            };
            // 品名コードからフォーカスを外したタイミングで名称取得処理を行う
            validationSetting.cd_seihin.rules.custom = function (value) {
                return isValidHinCode(value);
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

            /// <summary>Excelファイル出力を行います。</summary>
            var printExcel = function (e) {
                var criteria = $(".search-criteria").toJSON();
                var con_dt_from = new Date(criteria.dt_seizo.getFullYear(), criteria.dt_seizo.getMonth(), 1),
                    con_dt_to = new Date(criteria.dt_seizo.getFullYear(), criteria.dt_seizo.getMonth() + 1, 0);
                // マスタ単価使用のチェック有無
                var master_tanka = pageLangText.falseFlg.text;
                if ($("#id_master_tanka").prop('checked')) {
                    master_tanka = pageLangText.trueFlg.text;
                }

                // 検索条件：年月
                var nengetsu = $("#id_dt_seizo").val();
                // 検索条件：職場
                var shokuba = pageLangText.noSelectConditionExcel.text;
                if (!App.isUndefOrNull(criteria.nm_shokuba) && criteria.nm_shokuba.length > 0) {
                    shokuba = $("#id_cd_shokuba option:selected").text();
                }
                // 検索条件：ライン
                var line = pageLangText.noSelectConditionExcel.text;
                if (!App.isUndefOrNull(criteria.nm_line) && criteria.nm_line.length > 0) {
                    line = $("#id_cd_line option:selected").text();
                }
                // 検索条件：分類
                var bunrui = pageLangText.noSelectConditionExcel.text;
                if (!App.isUndefOrNull(criteria.nm_bunrui) && criteria.nm_bunrui.length > 0) {
                    bunrui = $("#id_cd_bunrui option:selected").text();
                }
                // 検索条件：製品名
                var nm_seihin = $("#id_nm_seihin").text();
                // 検索条件：単価設定
                var tankaSetei = pageLangText.tanaoroshi_tanka.text;
                if (criteria.select_tanka == 2) {
                    tankaSetei = pageLangText.nonyu_tanka.text;
                }
                // 検索条件：マスタ単価使用
                var masterTanka = pageLangText.noSelectConditionExcel.text;
                if (master_tanka == pageLangText.trueFlg.text) {
                    masterTanka = pageLangText.onCheckBoxExcel.text;
                }

                var query = {
                    url: "../api/GenkaIchiranExcel",
                    // 検索条件
                    dt_from: App.data.getDateTimeStringForQueryNoUtc(con_dt_from),
                    dt_to: App.data.getDateTimeStringForQueryNoUtc(con_dt_to),
                    cd_shokuba: criteria.nm_shokuba,
                    cd_line: criteria.nm_line,
                    cd_bunrui: criteria.nm_bunrui,
                    cd_hinmei: criteria.cd_seihin,
                    lang: App.ui.page.lang,
                    tanka_settei: criteria.select_tanka,
                    master_tanka: master_tanka,
                    // EXCEL用ヘッダー情報など
                    nengetsu: nengetsu,
                    shokubaName: encodeURIComponent(shokuba),
                    lineName: encodeURIComponent(line),
                    bunrui: encodeURIComponent(bunrui),
                    hinmei: encodeURIComponent(nm_seihin),
                    tankaSettei: tankaSetei,
                    masterTanka: masterTanka,
                    userName: encodeURIComponent(App.ui.page.user.Name),
                    today: App.data.getDateTimeStringForQuery(new Date(), true)
                };
                // 処理中を表示する
                App.ui.loading.show(pageLangText.nowProgressing.text);
                var url = App.data.toWebAPIFormat(query);

                // 出力処理
                window.open(url, '_parent');
                // Cookieを監視する
                onComplete();
            };
            /// <summary>EXCELボタンクリック時のイベント処理を行います。</summary>
            $(".excel-button").on("click", printExcel);

            /// <summary>製品一覧ボタンクリック時のイベント処理を行います。</summary>
            $("#id_seihin_button").on("click", function (e) {
                showHinmeiDialog();
            });

            /// 検索条件/製品コードのイベント処理を行います。
            $("#id_cd_seihin").dblclick(function () {
                // ダブルクリック時：品名ダイアログを開く
                showHinmeiDialog();
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

            // Cookieを1秒ごとにチェックする
            var onComplete = function () {
                if (app_util.prototype.getCookieValue(pageLangText.genkaIchiranCookie.text) == pageLangText.checkCookie.text) {
                    app_util.prototype.deleteCookie(pageLangText.genkaIchiranCookie.text);
                    //ローディング終了
                    App.ui.loading.close();
                }
                else {
                    // 再起してCookieが作成されたか監視
                    setTimeout(onComplete, 1000);
                }
            };

            /// <summary>保存確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            //$(".save-confirm-dialog .dlg-yes-button").on("click", saveData);
            /// <summary>保存確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            //$(".save-confirm-dialog .dlg-no-button").on("click", closeSaveConfirmDialog);

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
                    resultPartCommands = resultPart.find(".item-command");

                var resultPart0 = resultPart[0];
                var resultPartStyle = resultPart0.currentStyle || document.defaultView.getComputedStyle(resultPart0, "");

                var resultPartHeight = container[0].clientHeight - searchPart[0].clientHeight - ((parseInt(resultPartStyle.marginTop, 10) * 3) || 0);
                resultPart.height(resultPartHeight);
                grid.setGridWidth(resultPart0.clientWidth - 5);
                //結果一覧のパートの高さ - パートのヘッダーの高さ - パート内のボタンのコマンドの高さ - jqGrid のカラムヘッダーの高さ
                var gridHeight = resultPart0.clientHeight - resultPartHeader[0].clientHeight - resultPartCommands[0].clientHeight - resultPart.find(".ui-jqgrid-hdiv")[0].clientHeight - 35;
                grid.setGridHeight(gridHeight);
            };
            /// <summary>画面リサイズ時のイベント処理を行います。</summary>
            $(App.ui.page).on("resized", resizeContents);
        });
    </script>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <!-- 画面デザイン -- Start -->

    <!-- 検索条件と検索ボタン -->
    <div class="content-part search-criteria">
        <h3 class="part-header" data-app-text="searchCriteria"><a class="search-part-toggle" href="#"></a></h3>
        <div class="part-body">
            <!-- >>> 2014/5/28 ADMAX中村 ここから：原価一覧用検索条件を作成 -->
            <ul class="item-list item-list-left">
                <li>
                    <!-- 年月 -->
                    <label>
                        <span class="item-label" data-app-text="dt_seizo"></span>
                        <input type="text" id="id_dt_seizo" name="dt_seizo" style=" width: 8em;" />
                    </label>
                </li>
                <li>
                    <!-- 職場 -->
                    <label>
                        <span class="item-label" data-app-text="nm_shokuba" data-tooltip-text="nm_shokuba"></span>
                        <select id="id_cd_shokuba" name="nm_shokuba" style=" width: 28em;"></select>
                    </label>
                </li>
                <li>
                    <!-- ライン -->
                    <label>
                        <span class="item-label" data-app-text="nm_line"></span>
                        <select id="id_cd_line" name="nm_line" style=" width: 28em;"></select>
                    </label>
                </li>
                <li>
                    <!-- 分類 -->
                    <label>
                        <span class="item-label" data-app-text="nm_bunrui"></span>
                        <select id="id_cd_bunrui" name="nm_bunrui" style=" width: 28em;"></select>
                    </label>
                </li>
                <li>
                    <!-- 製品コード -->
                    <label>
                        <span class="item-label" data-app-text="cd_seihin"></span>
                        <input type="text" id="id_cd_seihin" name="cd_seihin" style="width: 120px" maxlength="14" />
                    </label>
                    <!-- 製品一覧ボタン -->
                    <label class="item-command">
                        <button type="button" id="id_seihin_button" class="dialog-button seihin-button" name="seihin-button" data-app-operation="seihinIchiran">
                            <span class="icon"></span><span data-app-text="seihinIchiran"></span>
                        </button>
                    </label>
                </li>
                <li>
                    <!-- 製品名 -->
                    <label>
                        <span class="item-label">&nbsp;</span>
                        <span class="item-label" id="id_nm_seihin" name="nm_seihin" ></span>
                    </label>
                </li>
                <li>
                    <!-- 単価設定 -->
                    <span class="item-label" data-app-text="tanka_settei"></span>
                    <label>
                        <input type="radio" name="select_tanka" id="tanaoroshi_tanka" value="1" checked="checked" /><span class="item-label" style="width: 120px" data-app-text="tanaoroshi_tanka"></span>
                    </label>
                    <label>
                        <input type="radio" name="select_tanka" id="nonyu_tanka" value="2" /><span class="item-label" style="width: 160px" data-app-text="nonyu_tanka"></span>
                    </label>
                    <label>
                        <input type="checkbox" id="id_master_tanka" checked="checked" />
                        <span data-app-text="master_tanka"></span>
                    </label>
                </li>
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
    <div class="command command-grid" style="left: 1px;">
        <button type="button" class="excel-button" name="excel-button" data-app-operation="excel"><span data-app-text="excel"></span></button>
    </div>
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
