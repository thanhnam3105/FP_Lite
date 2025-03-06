<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="HistoryChangeMaster.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.HistoryChangeMaster" %>

<asp:Content ID="Content1" ContentPlaceHolderID="IncludeContent" runat="server">
    <script src="<%=ResolveUrl("~/Resources/pages/pagedata-historychangemaster." + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
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
        .ui-jqgrid .ui-jqgrid-htable th {
            height: auto;
            padding: 0 2px 0 2px;
        }

            .ui-jqgrid .ui-jqgrid-htable th div {
                overflow: hidden;
                position: relative;
                height: auto;
            }

            .ui-th-column, .ui-jqgrid .ui-jqgrid-htable th.ui-th-column {
                overflow: hidden;
                white-space: nowrap;
                text-align: center;
                border-top: 0px none;
                border-bottom: 0px none;
                vertical-align: middle;
            }

        .part-body .con-list-left {
            float: left;
            width: 440px;
        }

        .part-body .con-list-right {
            margin-left: 300px;
        }

        .hinmei-dialog {
            background-color: White;
            width: 550px;
        }

        .padding-head {
            width: 150px!important;
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
                querySetting = { skip: 0, top: 1000, count: 0 },
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
                nm_genshizai = "nm_genshizai_" + App.ui.page.lang,  // 多言語対応：品名
                nm_seihin = "nm_seihin_" + App.ui.page.lang;  // 多言語対応：製品名
            // TODO: ここまで
            //// 変数宣言 -- End

            //// コントロール定義 -- Start

            // 英語化対応　言語によって幅を調節
            $(".search-criteria .item-label").css("width", pageLangText.each_lang_width.number);
            $("#ari_nomi").css("width", pageLangText.ari_nomi_width.number);
            $("#flg_mishiyobun").css("width", pageLangText.flg_mishiyobun_width.number);
            $("#flg_today_jisseki").css("width", pageLangText.flg_today_jisseki_width.number);

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
                        $(".search-criteria [name='cd_hinmei']").val(data).change();
                        $(".search-criteria [name='nm_hinmei']").val(data2);
                        $(".search-criteria [name='nm_hinmei']").attr("title", data2);
                        getCodeName(data);
                    }
                }
            });

            /// <summary>品情報取得用のサービスURLを取得します。</summary>
            /// <param name="seihinCode">製品コード</param>
            var getHinServiceUrl = function (hinCode) {
                var hinKbn = $("#id_kbn_hin").val();
                var serviceUrl = "../Services/FoodProcsService.svc/ma_hinmei?$filter=cd_hinmei eq '" + hinCode
                                  + "' and kbn_hin eq " + hinKbn
                //                + " and flg_mishiyo eq " + pageLangText.falseFlg.text + "&$top=1"
                                  + "&$top=1"
                return serviceUrl;
            };

            /// <summary>品コードより、品情報を取得して設定します。</summary>
            /// <param name="code">製品コード</param>
            var getCodeName = function (code) {
                var isValid = false;
                // 品コードが空文字の場合は処理中止
                if (App.isUndefOrNull(code) || code == "") {
                    $("#nm_hinmei").val("");
                    return true;
                }

                App.ui.loading.show(pageLangText.nowProgressing.text);
                //検索前チェック
                var codeQuery = {
                    url: "../api/HistoryChangeMaster",
                    con_hinmeiCode: code
                };

                App.ajax.webgetSync(
                     App.data.toWebAPIFormat(codeQuery)
                 ).done(function (results) {
                     var hinName = "nm_hinmei_" + App.ui.page.lang;

                     if (results.length > 0) {
                         isValid = true;
                         var result = results[0];
                         $("#nm_hinmei").val(result[hinName]);
                     }
                     else {
                         // 品名情報部分のクリア
                         $("#nm_hinmei").val("");
                     }
                 }).fail(function (result) {
                     App.ui.loading.close();
                     var length = result.key.fails.length,
                         messages = [];
                     for (var i = 0; i < length; i++) {
                         var keyName = result.key.fails[i];
                         var value = result.fails[keyName];
                         messages.push(keyName + " " + value.message);
                     }
                     App.ui.page.notifyAlert.message(messages).show();
                 }).always(function () {
                     if (!isDataLoading) {
                         // ローディング終了
                         App.ui.loading.close();
                     }
                 });
                return isValid;
            };

            /// <summary>検索条件の設定</summary>
            var createFilterDialog = function () {
                var criteria = $(".search-criteria").toJSON(), filters = [];

                filters.push("kbn_hin eq " + pageLangText.seihinHinKbn.text + " or kbn_hin eq "
							+ pageLangText.genryoHinKbn.text + " or kbn_hin eq "
							+ pageLangText.shizaiHinKbn.text + " or kbn_hin eq "
							+ pageLangText.jikaGenryoHinKbn.text);

                if (!App.isUndefOrNull(criteria.cd_hinmei)) {
                    filters.push("cd_hinmei eq '" + criteria.cd_hinmei + "'");
                }
                return filters.join(" and ");
            };

            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            // ダイアログ固有の変数宣言
            var menuConfirmDialog = $(".menu-confirm-dialog");

            // ダイアログ固有のコントロール定義
            menuConfirmDialog.dlg();

            /// 品名一覧ボタン：品名マスタセレクタを起動する
            var showHinmeiDialog = function () {

                // 検索条件/品区分の値によってパラメーターを変更する
                var optParam = pageLangText.maHinmeiHinDlgParam.text;

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
            var newDateMMDDFormat = pageLangText.dateMMDDFormatUS.text;
            var dateTimeMMDDYYHHIIFormat = pageLangText.dateTimeMMDDYYHHIIFormatUS.text;
            if (App.ui.page.langCountry !== 'en-US') {
                datePickerFormat = pageLangText.dateFormat.text;
                newDateFormat = pageLangText.dateNewFormat.text;
                newDateMMDDFormat = pageLangText.dateMMDDFormat.text;
                dateTimeMMDDYYHHIIFormat = pageLangText.dateTimeMMDDYYHHIIFormat.text;
            }

            /// <summary>終了日の初期値を取得する。</summary>
            var getDateTo = function () {
                var dayVal = new Date().getDate();
                var returnVal = new Date();
                if (dayVal == 1) {
                    // 開始日が1日の場合はその月の末日を設定する
                    returnVal = new Date(new Date().getFullYear(), new Date().getMonth() + 1, 0);
                }
                else {
                    // それ以外は開始日の31日後を設定する
                    returnVal.setDate(returnVal.getDate() + 31);
                }

                return returnVal;
            };

            /// <summary>時間を省いたシステム日付を日付オブジェクトで取得する</summary>
            var getSystemDate = function () {
                var sysdate = new Date(new Date().getFullYear(), new Date().getMonth(), new Date().getDate());
                return sysdate;
            };

            // datepickerの設定
            $("#dt_hiduke_from, #dt_hiduke_to, #dt_update_from, #dt_update_to").on("keyup", App.data.addSlashForDateString);
            $("#dt_hiduke_from, #dt_hiduke_to, #dt_update_from, #dt_update_to").datepicker({
                dateFormat: datePickerFormat,
                minDate: new Date(1975, 1 - 1, 1),
                maxDate: "+10y"
            });
            //$("#dt_hiduke_from").detepicker = App.date.startOfDay(new Date());
            //$("#dt_hiduke_to").datepicker("setDate", getDateTo());

            grid.jqGrid({
                colNames: [
                    pageLangText.kbn_data.text,
                    pageLangText.kbn_shori.text,
                    pageLangText.dt_hizuke.text,
                    pageLangText.cd_hinmei.text,
                    pageLangText.nm_seihin.text,
                    pageLangText.su_henko.text,
                    pageLangText.su_henko_hasu.text,
                    pageLangText.tr_lot.text,
                    pageLangText.dt_henko.text,
                    pageLangText.cd_henko.text,
                    pageLangText.nm_henko.text,
                    pageLangText.biko.text
                ],
                colModel: [
                    { name: 'kbn_data', width: 120, sorttype: "text", formatter: getDataType },
                    { name: 'kbn_shori', width: 145, sorttype: "text", formatter: getShoriType },
                    {
                        name: 'dt_hizuke', width: pageLangText.last_date_width.number, sorttype: "text", editable: false, align: "right",
                        formatter: "date",
                        formatoptions: {
                            srcformat: newDateFormat, newformat: newDateFormat
                        }
                    },
                    { name: 'cd_hinmei', width: 130, sorttype: "text", align: "right" },
                    { name: nm_hinmei, width: 170, sorttype: "text" },                    
                    { name: 'su_henko', width: 220, sorttype: "text", align: "right" },
                    { name: 'su_henko_hasu', width: 180, sorttype: "text", align: "right" },
                    { name: 'no_lot', width: 170, sorttype: "text" },
                    {
                        name: 'dt_update', width: 170, editable: false,
                        formatter: "date",
                        formatoptions: {
                            srcformat: dateTimeMMDDYYHHIIFormat, newformat: dateTimeMMDDYYHHIIFormat
                        }
                    },
                    { name: 'cd_update', width: 120, sorttype: "text", align: "right" },
                    { name: 'nm_tanto', width: 300, sorttype: "text" },
                    { name: 'biko', width: 300, sorttype: "text" }
                ],
                datatype: "local",
                shrinkToFit: false,
                multiselect: false,
                hoverrows: false,
                rownumbers: true,
                loadComplete: function () {
                    // グリッドの先頭行選択
                    grid.setSelection(1, false);

                    var ids = grid.jqGrid('getDataIDs'),
                        criteria = $(".search-criteria").toJSON();

                    for (var i = 0; i < ids.length; i++) {
                        var id = ids[i];
                        var biko = grid.getCell(id, "biko");
                        if (!App.isUndefOrNull(biko)) {
                            var biko1 = biko.replace("[1]", pageLangText.nm_riyu.text);
                            var biko2 = biko1.replace("[2]", pageLangText.biko.text);
                            var biko3 = biko2.replace("[3]", pageLangText.genka_busho.text);                           

                            grid.jqGrid('setCell', id, 'biko', biko3, 'not-editable-cell');
                        }
                    }                   
                }
            });

            /// <summary>Get name type data</summary>
            /// <param name="cellvalue">ステータス区分</param>
            /// <param name="options">オプション</param>
            /// <param name="rowObject">行情報</param>
            function getDataType(cellvalue, options, rowObject) {
                var status = "";
                if (cellvalue == pageLangText.ProductionPlan.number) {
                    status = pageLangText.ProductionPlan.text;
                }
                if (cellvalue == pageLangText.adjusted.number) {
                    status = pageLangText.adjusted.text;
                }
                return status;
            }

            /// <summary>Get name type Shori</summary>
            /// <param name="cellvalue">ステータス区分</param>
            /// <param name="options">オプション</param>
            /// <param name="rowObject">行情報</param>
            function getShoriType(cellvalue, options, rowObject) {
                var status = "";
                if (cellvalue == pageLangText.New.number) {
                    status = pageLangText.New.text;
                }
                if (cellvalue == pageLangText.Change.number) {
                    status = pageLangText.Change.text;
                }
                if (cellvalue == pageLangText.Delete.number) {
                    status = pageLangText.Delete.text;
                }
                return status;
            }


            /// <summary>時間を省いたシステム日付を日付オブジェクトで取得する</summary>
            var getSystemDate = function () {
                var sysdate = new Date(new Date().getFullYear(), new Date().getMonth(), new Date().getDate());
                return sysdate;
            };

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

            // 検索用ドロップダウン：品区分が変更されたときの分類取得処理
            var searchBunruiCode = function (hin_Kubun) {
                // 品区分の値を元に、品分類コンボボックスの値を取得します。

                // 品分類の中身をクリア
                $(".search-criteria [name='cd_bunrui'] option").remove();

                App.deferred.parallel({
                    // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                    hin_bunrui: App.ajax.webget("../Services/FoodProcsService.svc/ma_bunrui?$filter=flg_mishiyo eq "
                    + pageLangText.shiyoMishiyoFlg.text + " and kbn_hin eq " + hin_Kubun
                    + "&$orderby=cd_bunrui")
                    // TODO: ここまで
                }).done(function (result) {
                    // TODO: 画面の仕様に応じて以下のサービス呼び出し成功時の処理を変更してください。
                    var hinBunrui = result.successes.hin_bunrui.d;
                    var target = $(".search-criteria [name='cd_bunrui']");
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
                                        + pageLangText.jikaGenryoHinKbn.text + " & orderby=kbn_hin")
                // TODO: ここまで
            }).done(function (result) {
                // TODO: 画面の仕様に応じて以下のサービス呼び出し成功時の処理を変更してください。
                var hinKubun = result.successes.kbn_hin.d;
                App.ui.appendOptions($(".search-criteria [name='kbn_hin']"), "kbn_hin", "nm_kbn_hin", hinKubun, false);

                // 分類の設定
                searchBunruiCode(hinKubun[0].kbn_hin);

                //受払区分のコンボを作成する。
                $('#kbn_data_rireki').append($('<option>').html("").val(null));
                $('#kbn_data_rireki').append($('<option>').html(pageLangText.ProductionPlan.text).val(pageLangText.ProductionPlan.number));
                $('#kbn_data_rireki').append($('<option>').html(pageLangText.adjusted.text).val(pageLangText.adjusted.number));

                $('#kbn_shori_rireki').append($('<option>').html("").val(null));
                $('#kbn_shori_rireki').append($('<option>').html(pageLangText.New.text).val(pageLangText.New.number));
                $('#kbn_shori_rireki').append($('<option>').html(pageLangText.Change.text).val(pageLangText.Change.number));
                $('#kbn_shori_rireki').append($('<option>').html(pageLangText.Delete.text).val(pageLangText.Delete.number));

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
                var query = {
                    url: "../api/HistoryChangeMaster",
                    kbn_data: criteria.kbn_data,
                    kbn_shori: criteria.kbn_shori,
                    dt_hiduke_from: App.isUndefOrNull(criteria.dt_hiduke_from) ? null : App.data.getDateTimeStringForQueryNoUtc(criteria.dt_hiduke_from),
                    dt_hiduke_to: App.isUndefOrNull(criteria.dt_hiduke_to) ? null : App.data.getDateTimeStringForQueryNoUtc(criteria.dt_hiduke_to),
                    cd_hinmei: criteria.cd_hinmei,
                    dt_update_from: App.isUndefOrNull(criteria.dt_update_from) ? null : App.data.getDateTimeStringForQueryNoUtc(criteria.dt_update_from),
                    dt_update_to: App.isUndefOrNull(criteria.dt_update_to) ? null : App.data.getDateTimeStringForQueryNoUtc(criteria.dt_update_to),
                    cd_nm_tanto: encodeURIComponent(criteria.cd_nm_tanto),
                    top: querySetting.top,
                    inlinecount: "allpages"
                }

                return query;
            };

            /// <summary>検索用：実在庫ありのみの状態を返却</summary>
            var getFlgZaiko = function (criteria) {
                var flgZaiko = pageLangText.systemValueZero.text;
                if (!App.isUndefOrNull(criteria.ari_nomi)) {
                    // 在庫ありのみ
                    flgZaiko = pageLangText.systemValueOne.text;
                }
                return flgZaiko;
            };

            /// <summary>検索用：未使用分含む状態を返却</summary>
            var getFlgMishiyobun = function (criteria) {
                var flgMishiyo = pageLangText.systemValueZero.text;
                if (!App.isUndefOrNull(criteria.flg_mishiyobun)) {
                    // 未使用分含まない　使用のみ
                    flgMishiyo = pageLangText.systemValueOne.text;
                }
                return flgMishiyo;
            };

            /// <summary>検索用：当日は実績を表示の状態を返却</summary>
            var getFlgTodayJisseki = function (criteria) {
                var flgTodayJissekio = pageLangText.systemValueZero.text;
                if (!App.isUndefOrNull(criteria.flg_today_jisseki)) {
                    // 未使用分含まない　使用のみ
                    flgTodayJissekio = pageLangText.systemValueOne.text;
                }
                return flgTodayJissekio;
            };

            /// <summary>データ検索を行います。</summary>
            /// <param name="query">クエリオブジェクト</param>
            var searchItems = function (query) {
                if (isDataLoading === true) {
                    return;
                }

                var checkHiduke = findData();
                if (checkHiduke == false) {
                    return;
                }

                isDataLoading = true;

                // ローディングの表示
                App.ui.loading.show(pageLangText.nowProgressing.text);
                $("#list-loading-message").text(pageLangText.nowLoading.text);

                App.ajax.webget(
					App.data.toWebAPIFormat(query)
				).then(function (result) {
				    if (parseInt(result.__count) === 0) {
				        App.ui.page.notifyAlert.message(MS0037).show();
				    }
				    else {
				        // データバインド
				        bindData(result);
				        // 検索条件を閉じる
				        closeCriteria();
				    }
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
                    resultCount = result.__count,
                    //resultCount = result.d.length;

                result = result.d;

                querySetting.skip = querySetting.skip + resultCount;
                querySetting.count = parseInt(resultCount);

                // 検索結果が上限数を超えていた場合
                if (parseInt(resultCount) > querySetting.top) {
                    // 上限数を超えた検索結果は削除する
                    result.splice(querySetting.top, resultCount);
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
                grid.setFrozenColumns().trigger('reloadGrid', [{ current: true }]);

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

            $(".search-criteria .group-date").on("change", function (e) {
                var criteria = $(".search-criteria").toJSON();
                
                $(".search-criteria #dt_hiduke_from").removeClass("error");
                $(".search-criteria #dt_update_from").removeClass("error");                

                var result = $(".search-criteria").validation().validate();
                if (result.errors.length) {
                    return;
                }
            });

            /// <summary>検索前チェック</summary>
            var findData = function () {
                // 情報メッセージのクリア
                App.ui.page.notifyInfo.clear();
                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();

                // 開始日 <= 終了日 であること
                var criteria = $(".search-criteria").toJSON();
               
                $(".search-criteria #dt_hiduke_from").removeClass("error");
                $(".search-criteria #dt_update_from").removeClass("error");
                if (App.isUndefOrNull(criteria.dt_hiduke_from) && App.isUndefOrNull(criteria.dt_update_from)) {
                    App.ui.page.notifyAlert.message(
                        App.str.format(MS0790, pageLangText.dt_from.text, pageLangText.dt_update_from.text), $(".search-criteria").find("#dt_hiduke_from")
                    ).show();
                    $(".search-criteria #dt_hiduke_from").addClass("error");
                    $(".search-criteria #dt_update_from").addClass("error");
                    return false;
                }

                var errorDate = false;
                if (!App.isUndefOrNull(criteria.dt_hiduke_to)) {
                    if (criteria.dt_hiduke_from > criteria.dt_hiduke_to) {
                        App.ui.page.notifyAlert.message(
                            App.str.format(MS0019, pageLangText.dt_to.text, pageLangText.dt_from.text), $(".search-criteria").find("#dt_hiduke_to")
                        ).show();
                        errorDate = true;
                    }
                }

                if (!App.isUndefOrNull(criteria.dt_update_to)) {
                    if (criteria.dt_update_from > criteria.dt_update_to) {
                        App.ui.page.notifyAlert.message(
                            App.str.format(MS0019, pageLangText.dt_update_to.text, pageLangText.dt_update_from.text), $(".search-criteria").find("#dt_update_to")
                        ).show();
                        errorDate = true;
                    }
                }
                if (errorDate) {
                    return false;
                }

            };

            // TODO：ここまで
            //// バリデーション -- End

            //// 各種処理 -- Start

            //Excel出力前チェックを行います。
            var checkExcel = function () {
                // 情報メッセージのクリア
                App.ui.page.notifyInfo.clear();
                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();

                var result = $(".search-criteria").validation().validate();
                if (result.errors.length) {
                    return;
                }

                var checkHiduke = findData();
                if (checkHiduke == false) {
                    return;
                }

                printExcel();
            };

            /// <summary>Excelファイル出力を行います。</summary>
            /// <param name="e">イベントデータ</param>
            var printExcel = function (e) {
                var criteria = $(".search-criteria").toJSON();
                // 画面の入力項目をURLへ渡す
               
                var dataType = "";
                if (criteria.kbn_data == pageLangText.ProductionPlan.number) {
                    dataType = pageLangText.ProductionPlan.text;
                }
                if (criteria.kbn_data == pageLangText.adjusted.number) {
                    dataType = pageLangText.adjusted.text;
                }

                var shoriType = "";            
                if (criteria.kbn_shori == pageLangText.New.number) {
                    shoriType = pageLangText.New.text;
                }
                if (criteria.kbn_shori == pageLangText.Change.number) {
                    shoriType = pageLangText.Change.text;
                }
                if (criteria.kbn_shori == pageLangText.Delete.number) {
                    shoriType = pageLangText.Delete.text;
                }

                var query = {
                    url: "../api/HistoryChangeMasterExcel",
                    kbn_data: criteria.kbn_data,
                    kbn_shori: criteria.kbn_shori,
                    dt_hiduke_from: App.isUndefOrNull(criteria.dt_hiduke_from) ? null : App.data.getDateTimeStringForQueryNoUtc(criteria.dt_hiduke_from),
                    dt_hiduke_to: App.isUndefOrNull(criteria.dt_hiduke_to) ? null : App.data.getDateTimeStringForQueryNoUtc(criteria.dt_hiduke_to),
                    cd_hinmei: criteria.cd_hinmei,
                    dt_update_from: App.isUndefOrNull(criteria.dt_update_from) ? null : App.data.getDateTimeStringForQueryNoUtc(criteria.dt_update_from),
                    dt_update_to: App.isUndefOrNull(criteria.dt_update_to) ? null : App.data.getDateTimeStringForQueryNoUtc(criteria.dt_update_to),
                    cd_nm_tanto: encodeURIComponent(criteria.cd_nm_tanto),

                    nm_hinmei: encodeURIComponent(criteria.nm_hinmei),
                    lang: App.ui.page.lang,
                    userName: encodeURIComponent(App.ui.page.user.Name),
                    today: App.data.getDateTimeStringForQuery(new Date(), true),
                    UTC: new Date().getTimezoneOffset() / 60,

                    ProductionPlan_num: pageLangText.ProductionPlan.number,
                    ProductionPlan_text: encodeURIComponent(pageLangText.ProductionPlan.text),
                    adjusted_num: pageLangText.adjusted.number,
                    adjusted_text: encodeURIComponent(pageLangText.adjusted.text),

                    New_num: pageLangText.New.number,
                    New_text: encodeURIComponent(pageLangText.New.text),
                    Change_num: pageLangText.Change.number,
                    Change_text: encodeURIComponent(pageLangText.Change.text),
                    Delete_num: pageLangText.Delete.number,
                    Delete_text: encodeURIComponent(pageLangText.Delete.text),

                    col_riyu: encodeURIComponent(pageLangText.nm_riyu.text),
                    col_biko: encodeURIComponent(pageLangText.biko.text),
                    col_genka: encodeURIComponent(pageLangText.genka_busho.text),
                };

                // 処理中を表示する
                App.ui.loading.show(pageLangText.nowProgressing.text);
                var url = App.data.toWebAPIFormat(query);

                // 出力処理
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
                if (app_util.prototype.getCookieValue(pageLangText.HistoryChangeMasterCookie.text) == pageLangText.checkCookie.text) {
                    app_util.prototype.deleteCookie(pageLangText.HistoryChangeMasterCookie.text);
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
                clearState();
                var result = $(".search-criteria").validation().validate();
                if (result.errors.length) {
                    return;
                }
                searchItems(new query());
            });

             //validate Date (start) and Update date (start)
            //$(".search-criteria #dt_hiduke_from").on("change", function (e) {
            //    var result = $(".search-criteria").validation().validate();
            //});

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

            /// <summary>検索条件変更時のイベント処理を行います。</summary>
            $("#id_hinCode").dblclick(function () {
                // ダブルクリック時：品名ダイアログを開く
                showHinmeiDialog();
            });

            validationSetting.cd_hinmei.rules.custom = function (value) {
                return getCodeName(value);
            };

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
            <ul class="item-list item-command">
                <li>
                    <label>
                        <span class="item-label padding-head" data-app-text="DataPartition"></span>
                        <select name="kbn_data" id="kbn_data_rireki">
                        </select>
                        <span class="item-label" style="width: 30px;"></span>
                    </label>
                    <label>
                        <span class="item-label padding-head" data-app-text="ProcessingDivision"></span>
                        <select name="kbn_shori" id="kbn_shori_rireki">
                        </select>
                    </label>
                </li>

                <li>
                    <label>
                        <span class="item-label padding-head" data-app-text="dt_from"></span>
                        <input type="text" style="width: 156px" name="dt_hiduke_from" id="dt_hiduke_from" class="group-date"/>
                        <span class="item-label" data-app-text="between" style="text-align: center; width: 30px;"></span>
                        <span class="item-label padding-head" data-app-text="dt_to"></span>
                        <input type="text" style="width: 156px" name="dt_hiduke_to" id="dt_hiduke_to"/>
                    </label>
                </li>

                <li>
                    <label>
                        <span class="item-label padding-head" data-app-text="dt_update_from"></span>
                        <input type="text" style="width: 156px" name="dt_update_from" id="dt_update_from" class="group-date"/>
                        <span class="item-label" data-app-text="between" style="text-align: center; width: 30px;"></span>
                        <span class="item-label padding-head" data-app-text="dt_update_to"></span>
                        <input type="text" style="width: 156px" name="dt_update_to" id="dt_update_to"/>
                    </label>
                </li>

                <li>
                    <label>
                        <span class="item-label padding-head" data-app-text="hinCode"></span>
                        <input type="text" name="cd_hinmei" id="id_hinCode" maxlength="14" style="width: 156px" />
                        <input type="text" name="nm_hinmei" id="nm_hinmei" maxlength="14" style="width: 156px" title="" disabled />
                    </label>
                    <button type="button" class="dialog-button hinmei-button" name="hinmei-button">
                        <span class="icon"></span><span data-app-text="hinmeiIchiran"></span>
                    </button>
                </li>

                <li>
                    <span class="item-label padding-head" data-app-text="name"></span>
                    <input type="text" style="width: 156px" name="cd_nm_tanto" id="Text3" />
                </li>

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
            <h4 data-app-text="confirmTitle"></h4>
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
    <%--<div class="command-detail" style="right: 1px; display: none;">
        <button type="button" class="menu-button" name="menu-button">
            <span class="icon"></span><span data-app-text="menu"></span>
        </button>
    </div>--%>
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
