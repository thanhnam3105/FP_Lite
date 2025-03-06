<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="GenshizaiShikakarihinShiyoIchiran.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.GenshizaiShikakarihinShiyoIchiran" %>

<asp:Content ID="Content1" ContentPlaceHolderID="IncludeContent" runat="server">
    <script src="<%=ResolveUrl("~/Resources/pages/pagedata-genshizaishikakarihinshiyoichiran." + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
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
        
        .part-body .con-list-left
        {
            float: left;
            width: 350px;
        }
        
        .part-body .con-list-right
        {
            margin-left: 300px;
        }

        .hinmei-dialog
        {
            background-color: White;
            width: 550px;
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
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            // 画面アーキテクチャ共通の変数宣言
            var pageLangText = App.ui.pagedata.lang(App.ui.page.lang),
                validationSetting = App.ui.pagedata.validation(App.ui.page.lang),
                validationSetting2 = App.ui.pagedata.validation2(App.ui.page.lang),
                querySetting = { skip: 0, top: 500, count: 0 },
                isDataLoading = false,
                loading,
                userRoles = App.ui.page.user.Roles[0];

            // グリッドコントロール固有の変数宣言
            var grid = $("#item-grid"),
                changeSet = new App.ui.page.changeSet(),
                lastScrollTop = 0,
                isMishiyo = false,
                currentRow = 0,
                firstCol = 1,
                isChanged = false;

            // 画面固有の変数宣言
            var kbn_hin,
                nm_hinmei = "nm_hinmei_" + App.ui.page.lang,  // 多言語対応：品名
                nm_haigo = "nm_haigo_" + App.ui.page.lang,    // 多言語対応：配合名(仕掛品名)
                nm_seihin = "nm_seihin_" + App.ui.page.lang;  // 多言語対応：製品名
            // TODO: ここまで
            //// 変数宣言 -- End

            //// コントロール定義 -- Start

            // 英語化対応　言語によって幅を調節
            $(".search-criteria .item-label").css("width", pageLangText.each_lang_width.number);

            // 原資材一覧：品名ダイアログ
            var hinmeiDialog = $(".hinmei-dialog");
            hinmeiDialog.dlg({
                url: "Dialog/HinmeiDialog.aspx",
                name: "HinmeiDialog",
                closed: function (e, data, data2) {
                    if (data == "canceled") {
                        return;
                    }
                    else {
                        // 品名マスタセレクタから取得した名称を検索条件/名称に上書きする
                        $("#id_name").val(data2);
                    }
                }
            });

            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            // ダイアログ固有の変数宣言
            var menuConfirmDialog = $(".menu-confirm-dialog");

            // ダイアログ固有のコントロール定義
            menuConfirmDialog.dlg();

            /// 品名一覧ボタン：品名マスタセレクタを起動する
            var showHinmeiDialog = function () {

                // 検索条件/品区分の値によってパラメーターを変更する
                var hinKubun = $("#id_kbn_hin").val(),
                    optParam = pageLangText.genshizaiJikagenShikakariHinDlgParam.text;
                switch (hinKubun) {
                    case pageLangText.genryoHinKbn.text:
                        // 原料の場合
                        optParam = pageLangText.genryoHinDlgParam.text;
                        break;
                    case pageLangText.shizaiHinKbn.text:
                        // 資材の場合
                        optParam = pageLangText.shizaiHinDlgParam.text;
                        break;
                    case pageLangText.shikakariHinKbn.text:
                        // 仕掛品の場合
                        optParam = pageLangText.shikakariHinDlgParam.text;
                        break;
                    case pageLangText.jikaGenryoHinKbn.text:
                        // 自家原料の場合
                        optParam = pageLangText.jikaGenryoHinDlgParam.text;
                        break;
                }

                var option = { id: 'hinmei', multiselect: false, param1: optParam };
                hinmeiDialog.draggable(true);
                hinmeiDialog.dlg("open", option);
            };

            /// <summary>ダイアログを開きます。</summary>
            var showMenuConfirmDialog = function () {
                menuConfirmDialogNotifyInfo.clear();
                menuConfirmDialogNotifyAlert.clear();
                menuConfirmDialog.draggable(true);
                menuConfirmDialog.dlg("open");
            };

            /// <summary>ダイアログを閉じます。</summary>
            var closeMenuConfirmDialog = function () {
                menuConfirmDialog.dlg("close");
            };

            // 日付の多言語対応
            var datePickerFormat = pageLangText.dateFormatUS.text;
            var newDateFormat = pageLangText.dateNewFormatUS.text;
            if (App.ui.page.langCountry !== 'en-US') {
                datePickerFormat = pageLangText.dateFormat.text;
                newDateFormat = pageLangText.dateNewFormat.text;
            }

            // datepicker設定
            var $dt_from = $("#dt_from");
            $dt_from.on("keyup", App.data.addSlashForDateString);
            $dt_from.datepicker({ dateFormat: datePickerFormat });
            // 有効範囲：1970/1/1～3000/12/31
            $dt_from.datepicker("option", 'minDate', new Date(1970, 1 - 1, 1));
            $dt_from.datepicker("option", 'maxDate', new Date(3000, 12 - 1, 31));
            $dt_from.datepicker("setDate", new Date());

            /// ■ プロと用■一覧に表示するダミーデータ
            var gridData = [
	            {
	                nm_kbn_hin: "自家原料"    // 仕掛品：Unfinished product
                    , cd_hinmei: "00000000001234"
                    , nm_hinmei_ja: "団子"
                    , mishiyo_hin: "使用"
                    , cd_shikakari: "0000001111222A"
                    , nm_haigo_ja: "きび団子"
                    , no_han: 1
                    , mishiyo_shikakari: "未使用"
                    , cd_seihin: "0000009370405z"
                    , nm_seihin_ja: "三色団子セット"
                    , mishiyo_seihin: "使用"
                    , dt_saishu_shikomi_yotei: new Date("2014/08/11")
                    , dt_saishu_shikomi: new Date("2014/06/02")
                    , dt_saishu_seizo_yotei: new Date("2014/07/09")
                    , dt_saishu_seizo: new Date("2014/05/24")
	            }
            ];

            grid.jqGrid({
                colNames: [
                    pageLangText.kubun.text,
                    pageLangText.cd_hinmei.text,
                    pageLangText.nm_hinmei.text,
                    pageLangText.mishiyo.text,
                    pageLangText.cd_shikakari.text,
                    pageLangText.nm_shikakari.text,
                    pageLangText.wt_haigo.text,
                    pageLangText.su_shiyo.text,
                    pageLangText.no_han.text,
                    pageLangText.mishiyo.text,
                    pageLangText.cd_seihin.text,
                    pageLangText.nm_seihin.text,
                    pageLangText.mishiyo.text,
                    pageLangText.dt_saishu_shikomi_yotei.text,
                    pageLangText.dt_saishu_shikomi.text,
                    pageLangText.dt_saishu_seizo_yotei.text,
                    pageLangText.dt_saishu_seizo.text
                ],
                colModel: [
                    { name: 'nm_kbn_hin', width: pageLangText.nm_kbn_hin_width.number, sorttype: "text" },
                    { name: 'cd_hinmei', width: 120, sorttype: "text" },
                    { name: nm_hinmei, width: 200, sorttype: "text" },
                    { name: 'mishiyo_hin', width: 70, sorttype: "text", formatter: setMishiyoFlag },
                    { name: 'cd_shikakari', width: 120, sorttype: "text", hidedlg: false },
                    { name: nm_haigo, width: 200, sorttype: "text", hidedlg: false },
                    { name: 'wt_haigo', width: 80, sorttype: "text", align: "right", editable: false,
                        formatter: changeZeroToBlankTruncate,
                        formatoptions: {
                            decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 6, defaultValue: ""
                        }
                    },
                    { name: 'su_shiyo', width: 80, sorttype: "text", align: "right", editable: false, hidden: true, 
                        formatter: changeZeroToBlankTruncate,
                        formatoptions: {
                            decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 6, defaultValue: ""
                        }
                    },
                    { name: 'no_han', width: 60, sorttype: "text", align: "right" },
                    { name: 'mishiyo_shikakari', width: 70, sorttype: "text", formatter: setMishiyoFlag },
                    { name: 'cd_seihin', width: 120, sorttype: "text" },
                    { name: nm_seihin, width: 200, sorttype: "text" },
                    { name: 'mishiyo_seihin', width: 70, sorttype: "text", formatter: setMishiyoFlag },
                    { name: 'dt_saishu_shikomi_yotei', width: pageLangText.last_date_width.number, sorttype: "text", editable: false, hidedlg: false,
                        formatter: "date",
                        formatoptions: {
                            srcformat: newDateFormat, newformat: newDateFormat
                        }
                    },
                    { name: 'dt_saishu_shikomi', width: pageLangText.last_date_width.number, sorttype: "text", editable: false, hidedlg: false,
                        formatter: "date",
                        formatoptions: {
                            srcformat: newDateFormat, newformat: newDateFormat
                        }
                    },
                    { name: 'dt_saishu_seizo_yotei', width: pageLangText.last_date_width.number, sorttype: "text", editable: false,
                        formatter: "date",
                        formatoptions: {
                            srcformat: newDateFormat, newformat: newDateFormat
                        }
                    },
                    { name: 'dt_saishu_seizo', width: pageLangText.last_date_width.number, sorttype: "text", editable: false,
                        formatter: "date",
                        formatoptions: {
                            srcformat: newDateFormat, newformat: newDateFormat
                        }
                    }
                ],
                //data: gridData, // 表示したいデータ
                datatype: "local",
                shrinkToFit: false,
                multiselect: false,
                hoverrows: false,
                rownumbers: true,
                loadComplete: function () {
                    // グリッドの先頭行選択
                    grid.setSelection(1, false);
                }
            });

            /// <summary>未使用フラグの表示文言を設定します</summary>
            /// 0：使用　1：未使用　nullまたは空文字：空白
            function setMishiyoFlag(cellvalue, options, rowObject) {
                var resultValue = "";
                if (!App.isUndefOrNull(cellvalue)) {
                    if (cellvalue == pageLangText.falseFlg.text) {
                        resultValue = pageLangText.shiyo.text;
                    }
                    else {
                        resultValue = pageLangText.mishiyo.text;
                    }
                }

                return resultValue;
            }

            /// <summary>時間を省いたシステム日付を日付オブジェクトで取得する</summary>
            var getSystemDate = function () {
                var sysdate = new Date(new Date().getFullYear(), new Date().getMonth(), new Date().getDate());
                return sysdate;
            };

            /// <summary>値のカンマ区切りを除去して数値にして返却します。</summary>
            /// <param name="value">値</param>
            var deleteThousandsSeparator = function (value) {
                var retVal = 0;
                if (value != "") {
                    retVal = parseFloat(new String(value).replace(/,/g, ""));
                }
                return retVal;
            };
            /// <summary>値をカンマ区切りにして返却します。</summary>
            /// <param name="value">値</param>
            var setThousandsSeparator = function (value) {
                var str = value;
                var num = new String(str).replace(/,/g, "");
                while (num != (num = num.replace(/^(-?\d+)(\d{3})/, "$1,$2")));
                return num;
            };
            /// <summary>【切り捨て版】値がnullだった場合、空白を返却します。</summary>
            /// <param name="value">セルの値</param>
            /// <param name="options">オプション</param>
            /// <param name="rowObj">行データ</param>
            function changeZeroToBlankTruncate(value, options, rowObj) {
                var returnVal = deleteThousandsSeparator(value);
//                if (returnVal == 0 || isNaN(returnVal)) {
                if (isNaN(returnVal)) {
                    returnVal = "";
                }
                else {
                    // 小数点以下の桁数を固定にする
                    var fixeVal = options.colModel.formatoptions.decimalPlaces; // 丸め位置
                    var kanzan = Math.pow(10, parseInt(fixeVal));   // べき乗
                    // 指定の桁数以降は切り捨て
                    var kanzanVal = Math.floor(App.data.trimFixed(returnVal * kanzan));
                    returnVal = App.data.trimFixed(kanzanVal / kanzan);
                    // ゼロ埋め
                    returnVal = returnVal.toFixed(fixeVal); // toFixed：収まらない場合は四捨五入される
                    // カンマ区切りにする
                    returnVal = setThousandsSeparator(returnVal);
                }
                return returnVal;
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

            /// <summary>項目の表示/非表示切替処理</summary>
            /// <param name="dispCol">表示：showCol　非表示：hideCol</param>
            var setHideCol = function (dispCol, bool) {
                // 「列変更」の表示切替
                //grid.getColProp("cd_shikakari").hidedlg = bool;
                //grid.getColProp(nm_haigo).hidedlg = bool;
                //grid.getColProp("dt_saishu_shikomi_yotei").hidedlg = bool;
                //grid.getColProp("dt_saishu_shikomi").hidedlg = bool;

                // 明細への表示切替
//                grid.jqGrid(dispCol, ["cd_shikakari", nm_haigo, "dt_saishu_shikomi_yotei", "dt_saishu_shikomi"]);
                grid.jqGrid(dispCol, ["cd_shikakari", nm_haigo, "dt_saishu_shikomi_yotei", "dt_saishu_shikomi", "wt_haigo"]);
                if (dispCol == 'hideCol'){
                    grid.jqGrid('showCol', ["su_shiyo"]);
                }
                else {
                    grid.jqGrid('hideCol', ["su_shiyo"]);
                }
            };
            /// <summary>検索時の検索条件/品区分による明細の表示制御処理</summary>
            var ctrlItemDisp = function () {
                var criteria = $(".search-criteria").toJSON();

                if (criteria.kbn_hin == pageLangText.shizaiHinKbn.text) {
                    // 検索条件/品区分が「資材」の場合
                    setHideCol("hideCol", true);
                }
                else {
                    // 検索条件/品区分が「資材」以外の場合
                    setHideCol("showCol", false);
                }
            };

            // 検索用ドロップダウン：品区分が変更されたときの分類取得処理
            var searchBunruiCode = function (hinKubun) {
                // 品区分の値を元に、品分類コンボボックスの値を取得します。

                // 品分類の中身をクリア
                $(".search-criteria [name='bunrui'] option").remove();

                App.deferred.parallel({
                    // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                    hinBunrui: App.ajax.webget("../Services/FoodProcsService.svc/ma_bunrui?$filter=flg_mishiyo eq "
                    + pageLangText.shiyoMishiyoFlg.text + " and kbn_hin eq " + hinKubun
                    + "&$orderby=cd_bunrui")
                    // TODO: ここまで
                }).done(function (result) {
                    // TODO: 画面の仕様に応じて以下のサービス呼び出し成功時の処理を変更してください。
                    hinBunrui = result.successes.hinBunrui.d;
                    var target = $(".search-criteria [name='bunrui']");
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

            // TODO：ここまで
            //// コントロール定義 -- End

            //// メッセージ表示 -- Start
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            // ダイアログ情報メッセージの設定
            var menuConfirmDialogNotifyInfo = App.ui.notify.info(menuConfirmDialog, {
                container: ".menu-confirm-dialog .dialog-slideup-area .info-message",
                messageContainerQuery: "ul",
                show: function () {
                    menuConfirmDialog.find(".info-message").show();
                },
                clear: function () {
                    menuConfirmDialog.find(".info-message").hide();
                }
            });

            // ダイアログ警告メッセージの設定
            var menuConfirmDialogNotifyAlert = App.ui.notify.alert(menuConfirmDialog, {
                container: ".menu-confirm-dialog .dialog-slideup-area .alert-message",
                messageContainerQuery: "ul",
                show: function () {
                    menuConfirmDialog.find(".alert-message").show();
                },
                clear: function () {
                    menuConfirmDialog.find(".alert-message").hide();
                }
            });

            // TODO：ここまで
            //// メッセージ表示 -- End

            //// 操作制御定義 -- Start
            App.ui.pagedata.operation.applySetting(App.ui.page.user.Roles[0], App.ui.page.lang);
            //// 操作制御定義 -- End

            //// 事前データロード -- Start 
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            // 画面アーキテクチャ共通の事前データロード
            App.deferred.parallel({
                // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                loading: App.ui.loading.show(pageLangText.nowProgressing.text),
                kbn_hin: App.ajax.webget("../Services/FoodProcsService.svc/ma_kbn_hin()?$filter=kbn_hin eq "
                                        + pageLangText.genryoHinKbn.text + " or kbn_hin eq  "
                                        + pageLangText.shizaiHinKbn.text + " or kbn_hin eq  "
                                        + pageLangText.shikakariHinKbn.text + " or kbn_hin eq  "
                                        + pageLangText.jikaGenryoHinKbn.text + " & orderby=kbn_hin")
                // TODO: ここまで
            }).done(function (result) {
                // TODO: 画面の仕様に応じて以下のサービス呼び出し成功時の処理を変更してください。
                var con_kbn_hin = result.successes.kbn_hin.d;
                App.ui.appendOptions($(".search-criteria [name='kbn_hin']"), "kbn_hin", "nm_kbn_hin", con_kbn_hin, false);

                // 分類の設定
                searchBunruiCode(con_kbn_hin[0].kbn_hin);
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
            // TODO：ここまで
            //// 事前データロード -- End

            //// 検索処理 -- Start

            /// <summary>クエリオブジェクトの設定</summary>
            var query = function () {
                var criteria = $(".search-criteria").toJSON();
                var con_bunrui = criteria.bunrui;
                var con_dt_from = criteria.dt_from;

                if (App.isUndefOrNull(con_bunrui)) {
                    // 分類が選択されていなかった場合、文字列のnullを設定する
                    con_bunrui = "null";
                }

                if (!App.isUndefOrNull(con_dt_from)) {
                    con_dt_from = App.data.getDateTimeStringForQueryNoUtc(con_dt_from);
                }

                var query = {
                    url: "../api/GenshizaiShikakarihinShiyoIchiran",
                    kbn_hin: criteria.kbn_hin,
                    bunrui: con_bunrui,
                    hinmei: encodeURIComponent(criteria.con_name),
                    dt_from: con_dt_from,
                    lang: App.ui.page.lang,
                    today: App.data.getDateTimeStringForQueryNoUtc(getSystemDate()),
                    maxCount: querySetting.top,
                    shiyoMishiyoFlag: pageLangText.shiyoMishiyoFlg.text
                }

                return query;
            };

            /// <summary>フィルター条件の設定</summary>
            var createFilter = function () {
                var criteria = $(".search-criteria").toJSON(),
                    filters = [];

                // TODO: 画面の仕様に応じて以下のフィルター条件を変更してください。
                if (criteria.flg_mishiyo == 0) {
                    filters.push("flg_mishiyo eq " + criteria.flg_mishiyo);
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
                App.ui.loading.show(pageLangText.nowProgressing.text);
                $("#list-loading-message").text(pageLangText.nowLoading.text);
                App.ajax.webget(
                    App.data.toWebAPIFormat(query)
                ).done(function (result) {
                    // 項目制御
                    //ctrlItemDisp();
                    // データバインド
                    bindData(result);
                    // 検索条件を閉じる
                    closeCriteria();
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                    App.ui.loading.close();
                }).always(function () {
                    setTimeout(function () {
                        $("#list-loading-message").text("");
                        isDataLoading = false;
                        App.ui.loading.close();
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

            // グリッドコントロール固有の検索処理
            /// <summary>検索前の状態に初期化します。</summary>
            var clearState = function () {
                // データクリア
                grid.clearGridData();
                lastScrollTop = 0;
                querySetting.skip = 0;
                querySetting.count = 0;
                displayCount();

                currentRow = 0;
                currentCol = firstCol;
                // 変更セットの作成
                changeSet = new App.ui.page.changeSet();
                // TODO: 画面の仕様に応じて以下のパラメータ設定を変更してください。
                // TODO: ここまで

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

                ctrlItemDisp();

                // データバインド
                var currentData = grid.getGridParam("data").concat(result);
                grid.setGridParam({ data: currentData });
                // カラムの固定
                grid.setFrozenColumns().trigger('reloadGrid', [{ current: true}]);

                // 検索処理の終了メッセージ
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
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。

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
                // 選択行なしの場合は最終行を選択
                if (App.isUnusable(selectedRowId)) {
                    selectedRowId = ids[0];
                }
                currentRow = $('#' + selectedRowId)[0].rowIndex;

                return selectedRowId;
            };

            // TODO：ここまで
            //// データ変更処理 -- End

            //// エラーハンドリング -- Start
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            /// <summary>データ変更エラーハンドリングを行います。</summary>
            /// <param name="result">エラーの戻り値</param>
            var handleSaveDataError = function (result) {
                var ret = JSON.parse(result.rawText);

                if (!App.isArray(ret) && App.isUndefOrNull(ret.Updated) && App.isUndefOrNull(ret.Deleted)) {
                    App.ui.page.notifyAlert.message(result.message).show();
                    return;
                }
            };
            // TODO：ここまで
            //// エラーハンドリング -- End

            //// 保存処理 -- Start
            //// 保存処理 -- End

            //// バリデーション -- Start
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            // グリッド固有のバリデーション

            // 一覧画面のバリデーション設定
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
            $(".search-criteria").validation(v);

            // TODO：ここまで
            //// バリデーション -- End

            //// 各種処理 -- Start

            //Excel出力前チェックを行います。
            var checkExcel = function () {
                // 情報メッセージのクリア
                App.ui.page.notifyInfo.clear();
                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();

                printExcel();
            };

            /// <summary>Excelファイル出力を行います。</summary>
            /// <param name="e">イベントデータ</param>
            var printExcel = function (e) {
                var queryExcel = {
                    url: "../api/GenshizaiShikakarihinShiyoIchiranExcel",
                    orderby: "cd_hinmei"
                };
                // 処理中を表示する
                App.ui.loading.show(pageLangText.nowProgressing.text);
                var criteria = $(".search-criteria").toJSON(),
                    url = App.data.toODataFormat(queryExcel),
                    con_dt_from = criteria.dt_from;

                // 引数設定：品区分
                var hinKbnName = $("#id_kbn_hin option:selected").text();
                // 引数設定：分類
                // 初期値を「未選択」とし、値があればそれを設定する
                var hinBunruiName = pageLangText.noSelectConditionExcel.text;
                if (!App.isUndefOrNull(criteria.bunrui)) {
                    hinBunruiName = $("#id_bunrui option:selected").text();
                }

                if (!App.isUndefOrNull(con_dt_from)) {
                    con_dt_from = App.data.getDateTimeStringForQueryNoUtc(con_dt_from);
                }

                url = url + "&kbn_hin=" + criteria.kbn_hin + "&bunrui=" + encodeURIComponent(criteria.bunrui) + "&hinmei=" + encodeURIComponent(criteria.con_name)
                    + "&today=" + App.data.getDateTimeStringForQueryNoUtc(getSystemDate()) + "&lang=" + App.ui.page.lang
                    + "&kbnName=" + encodeURIComponent(hinKbnName) + "&bunruiName=" + encodeURIComponent(hinBunruiName)
                    + "&userName=" + encodeURIComponent(App.ui.page.user.Name)
                    + "&outputDate=" + App.data.getDateTimeStringForQuery(new Date(), true)
                    + "&dt_from=" + con_dt_from
                    + "&shiyoMishiyoFlag=" + pageLangText.shiyoMishiyoFlg.text;

                window.open(url, '_parent');
                // Cookieを監視する
                onComplete();
            };

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

            // メニューへ戻る
            var backToMenu = function () {
                try {
                    window.location = pageLangText.menuPath.url;
                }
                catch (e) {
                    // 何もしない
                }
            };

            // Cookieを1秒ごとにチェックする
            var onComplete = function () {
                if (app_util.prototype.getCookieValue(pageLangText.genshizaiShikakarihinShiyoIchiranCookie.text) == pageLangText.checkCookie.text) {
                    app_util.prototype.deleteCookie(pageLangText.genshizaiShikakarihinShiyoIchiranCookie.text);
                    //ローディング終了
                    App.ui.loading.close();
                }
                else {
                    // 再起してCookieが作成されたか監視
                    setTimeout(onComplete, 1000);
                }
            };

            // TODO：ここまで
            //// 各種処理 -- End

            //// イベント処理 -- Start
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            //// 一覧画面固有のボタン
            /// <summary>検索ボタンクリック時のイベント処理を行います。</summary>
            $(".find-button").on("click", function () {
                var result = $(".search-criteria").validation().validate();
                if (result.errors.length) {
                    return;
                }
                clearState();
                searchItems(new query());
            });

            /// <summary>検索条件：品区分変更時のイベント処理</summary>
            $("#id_kbn_hin").on("change", function (e) {
                var criteria = $(".search-criteria").toJSON();
                var hinKbnParam = criteria.kbn_hin;
                if (App.isUndefOrNull(hinKbnParam)) {
                    return;
                }
                searchBunruiCode(hinKbnParam);
            });

            /// <summary>品名一覧ボタンクリック時のイベント処理を行います。</summary>
            $(".hinmei-button").on("click", function (e) {
                showHinmeiDialog();
            });

            /// <summary>列変更ボタンクリック時のイベント処理を行います。</summary>
            $(".colchange-button").on("click", showColumnSettingDialog);

            /// <summary>エクセルボタンクリック時のイベント処理を行います。</summary>
            $(".excel-button").on("click", checkExcel);

            /// <summary>メニューボタンクリック時のイベント処理を行います。</summary>
            $(".menu-button").on("click", backToMenu);

            //// その他のイベント処理
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
            // TODO: ここまで
            //// イベント処理 -- End
        });
    </script>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <!-- 画面デザイン -- Start -->
    <!-- 検索条件と検索ボタン -->
    <div class="content-part search-criteria">
        <h3 class="part-header" data-app-text="searchCriteria">
            <a class="search-part-toggle" href="#"></a>
        </h3>
        <div class="part-body">
            <ul class="item-list con-list-left">
                <!-- TODO: 画面の仕様に応じて以下の検索条件を変更してください。-->
                <li>
                    <label>
                        <span class="item-label" data-app-text="kbn_hin"></span>
                        <select name="kbn_hin" id="id_kbn_hin" style="width: 7em;"></select>
                    </label>
                <br/>
                    <label>
                        <span class="item-label" data-app-text="bunrui"></span>
                        <select name="bunrui" id="id_bunrui" style="width: 17em;"></select>
                    </label>
                </li>
            </ul>
            <ul class="item-list con-list-right item-command">
                <li>
                    <label>
                        <span class="item-label" data-app-text="name"></span>
                        <input type="text" name="con_name" id="id_name" maxlength ="50" size="40" />
                    </label>
                    <label>
                        <button type="button" class="hinmei-button" name="hinmei-button"><span class="icon"></span><span data-app-text="hinmeiIchiran"></span></button>
                    </label>
                <br/>
                    <label>
                        <span class="item-label" data-app-text="dt_from"></span>
                        <input type="text" name="dt_from" id="dt_from" maxlength ="10" size="10" />
                    </label>
                </li>
                <%--<li>
                    <label>
                        <span class="item-label"></span>
                    </label>
                </li>--%>
                <!-- TODO: ここまで -->
            </ul>
        </div>
        <div class="part-footer">
            <div class="command command-grid">
                <button type="button" class="find-button" data-app-operation="search">
                    <span class="icon"></span><span data-app-text="search"></span>
                </button>
            </div>
        </div>
    </div>
    <!-- 検索結果一覧 -->
    <div class="content-part result-list">
        <!-- グリッドコントロール固有のデザイン -- Start -->
        <h3 id="listHeader" class="part-header">
            <span data-app-text="resultList" style="padding-right: 10px; padding-bottom: 4px;"
                id="list-results"></span><span class="list-count" id="list-count"></span><span style="padding-left: 50px;"
                    class="list-loading-message" id="list-loading-message"></span>
        </h3>
        <div class="part-body" id="result-grid">
           <div class="list-part-grid-content">
                <div class="item-command" style="left: 17px; right: 17px;">
                    <button type="button" class="colchange-button" data-app-operation="colchange">
                        <span class="icon"></span><span data-app-text="colchange"></span>
                    </button>
                </div>

                <table id="item-grid">
                </table>

            </div>
       </div>
    </div>
    <!-- グリッドコントロール固有のデザイン -- End -->
    
    <div class="menu-confirm-dialog" style="display: none;">
        <div class="dialog-header">
            <h4 data-app-text="confirmTitle">
            </h4>
        </div>
        <div class="dialog-body" style="padding: 10px; width: 100%;">
            <div class="part-body">
                <span data-app-text="unloadWithoutSave"></span>
            </div>
        </div>
        <div class="dialog-footer">
            <div class="command" style="position: absolute; left: 10px; top: 5px">
                <button class="dlg-yes-button" name="dlg-yes-button" data-app-text="yes">
                </button>
            </div>
            <div class="command" style="position: absolute; right: 5px; top: 5px;">
                <button class="dlg-no-button" name="dlg-no-button" data-app-text="no">
                </button>
            </div>
        </div>
    </div>
    <!-- 画面デザイン -- End -->
</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="FooterContent" runat="server">
    <!-- 画面デザイン -- Start -->
    <!-- 画面アーキテクチャ共通のデザイン -- Start -->
    <div class="command command-grid" style="left: 1px;">
        <button type="button" class="excel-button" name="excel-button" data-app-operation="excel">
            <span class="icon"></span><span data-app-text="excel"></span>
        </button>
    </div>
    <div class="command command-grid" style="right: 1px;">
        <button type="button" class="menu-button" name="menu-button">
            <span class="icon"></span><span data-app-text="menu"></span>
        </button>
    </div>
    <div class="command-detail" style="right: 1px; display: none;">
        <button type="button" class="menu-button" name="menu-button" >
            <span class="icon"></span><span data-app-text="menu"></span>
        </button>
    </div>
    <!-- 画面アーキテクチャ共通のデザイン -- End -->
    <!-- 画面デザイン -- End -->
</asp:Content>
<asp:Content ID="Content5" ContentPlaceHolderID="DialogsContent" runat="server">
    <!-- 画面デザイン -- Start -->

    <!-- TODO: 画面の仕様に応じて以下のダイアログの設定を変更してください。 -->
    <div class="hinmei-dialog">
    </div>
    <!-- TODO: ここまで  -->

    <!-- 画面デザイン -- End -->
</asp:Content>