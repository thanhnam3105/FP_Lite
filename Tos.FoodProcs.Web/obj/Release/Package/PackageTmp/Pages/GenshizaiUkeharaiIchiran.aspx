<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="GenshizaiUkeharaiIchiran.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.GenshizaiUkeharaiIchiran" %>

<asp:Content ID="Content1" ContentPlaceHolderID="IncludeContent" runat="server">
    <script src="<%=ResolveUrl("~/Resources/pages/pagedata-genshizaiukeharaiichiran." + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
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
            height: auto;
            padding: 0 2px 0 2px;
        }
        .ui-jqgrid .ui-jqgrid-htable th div
        {
            overflow: hidden;
            position: relative;
            height: auto;
        }
        .ui-th-column, .ui-jqgrid .ui-jqgrid-htable th.ui-th-column
        {
            overflow: hidden;
            white-space: nowrap;
            text-align: center;
            border-top: 0px none;
            border-bottom: 0px none;
            vertical-align: middle;
        }
        
        .part-body .con-list-left
        {
            float: left;
            width: 440px;
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
                        $(".search-criteria [name='cd_genshizai']").val(data);
                        $("#id_nm_genshizai").text(data2);
                    }
                }
            });

            /// <summary>検索条件変更時のイベント処理を行います。</summary>
            $("#id_cd_genshizai").dblclick(function () {
                // ダブルクリック時：品名ダイアログを開く
                showHinmeiDialog();
            })
            .change(function () {
                var hinCode = $("#id_cd_genshizai").val();
                getCodeName(hinCode);
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
                // 品コードが空文字の場合は処理中止
                if (code == "") {
                    $("#id_nm_genshizai").text("");
                    return;
                }
                //検索前チェック
                App.ui.page.notifyAlert.clear();
                var result = $(".search-criteria").validation().validate();
                if (result.errors.length) {
                    return;
                }

                var serviceUrl = getHinServiceUrl(code)
                    , elementName = nm_hinmei;
                App.ui.loading.show(pageLangText.nowProgressing.text);

                App.deferred.parallel({
                    codeName: App.ajax.webget(serviceUrl)
                }).done(function (result) {
                    // サービス呼び出し成功時
                    codeName = result.successes.codeName.d;
                    if (codeName.length > 0) {
                        var hinName = codeName[0][elementName];

                        $("#id_nm_genshizai").text(hinName ? hinName : "");

                    } else {
                        App.ui.page.notifyAlert.clear();
                        App.ui.page.notifyAlert.message(pageLangText.notFound.text, $("#id_cd_hinmei")).show();
                        $("#id_nm_genshizai").text("");
                        App.ui.loading.close();
                    }

                }).fail(function (result) {
                    var length = result.key.fails.length,
                            messages = [];
                    for (var i = 0; i < length; i++) {
                        var keyName = result.key.fails[i];
                        var value = result.fails[keyName];
                        messages.push(keyName + " " + value.message);
                    }
                    App.ui.page.notifyAlert.message(messages).show();
                    App.ui.loading.close();
                }).always(function () {
                    // ローディングの終了
                    App.ui.loading.close();

                });
            };

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
            var newDateMMDDFormat = pageLangText.dateMMDDFormatUS.text;
            if (App.ui.page.langCountry !== 'en-US') {
                datePickerFormat = pageLangText.dateFormat.text;
                newDateFormat = pageLangText.dateNewFormat.text;
                newDateMMDDFormat = pageLangText.dateMMDDFormat.text;
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
            $("#dt_hiduke_from, #dt_hiduke_to").on("keyup", App.data.addSlashForDateString);
            $("#dt_hiduke_from, #dt_hiduke_to").datepicker({
                dateFormat: datePickerFormat,
                minDate: new Date(1975, 1 - 1, 1),
                maxDate: "+10y"
            });
            $("#dt_hiduke_from").detepicker = App.date.startOfDay(new Date());
            $("#dt_hiduke_to").datepicker("setDate", getDateTo());

            grid.jqGrid({
                colNames: [
                    pageLangText.cd_genshizai.text,
                    pageLangText.nm_genshizai.text,
                    pageLangText.dt_hiduke.text,
                    pageLangText.kbn_ukeharai.text,
                    pageLangText.su_nyusyukko.text,
                    pageLangText.nm_shokuba.text,
                    pageLangText.nm_line.text,
                    pageLangText.no_lot.text,
                    pageLangText.cd_seihin.text,
                    pageLangText.nm_seihin.text,
                    pageLangText.nm_memo.text
                ],
                colModel: [
                    { name: 'cd_genshizai', width: 120, sorttype: "text" },
                    { name: nm_genshizai, width: 220, sorttype: "text" },
                    { name: 'dt_hiduke', width: pageLangText.last_date_width.number, sorttype: "text", editable: false,
                        formatter: "date",
                        formatoptions: {
                            srcformat: newDateFormat, newformat: newDateFormat
                        }
                    },
                    { name: 'kbn_ukeharai', width: pageLangText.kbn_ukeharai_width.number, sorttype: "text", formatter: setUkeharaiKbn },
                    { name: 'su_nyusyukko', width: 120, sorttype: "text", align: "right",
                        formatter: 'number',
                        formatoptions: {
                            //decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 2, defaultValue: "0.00"
                            decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 3, defaultValue: "0.000"
                        }
                    },
                    { name: 'nm_shokuba', width: 80, sorttype: "text" },
                    { name: 'nm_line', width: 140, sorttype: "text" },
                    { name: 'no_lot', width: 150, sorttype: "text" },
                    { name: 'cd_seihin', width: 120, sorttype: "text" },
                    { name: nm_seihin, width: 220, sorttype: "text" },
                    { name: 'nm_memo', width: 250, sorttype: "text" }
                ],
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

            /// <summary>受払フラグの表示文言を設定します</summary>
            /// 0：納入予定　1：納入実績　2：使用予定　3：使用実績　4：調整数
            function setUkeharaiKbn(cellvalue, options, rowObject) {
                var resultValue = "";
                if (!App.isUndefOrNull(cellvalue)) {
                    //納入予定
                    if (cellvalue == pageLangText.ukeharaiNounyuYoteiKbn.text) {
                        resultValue = pageLangText.nonyuYotei.text;
                    }
                    //納入実績
                    else if (cellvalue == pageLangText.ukeharaiNounyuJissekiKbn.text) {
                        resultValue = pageLangText.nonyuJisseki.text;
                    }
                    //使用予定
                    else if (cellvalue == pageLangText.ukeharaiShiyoYoteiKbn.text) {
                        resultValue = pageLangText.shiyoYotei.text;
                    }
                    //使用実績
                    else if (cellvalue == pageLangText.ukeharaiShiyoJissekiKbn.text) {
                        resultValue = pageLangText.shiyoJisseki.text;
                    }
                    //調整数
                    else if (cellvalue == pageLangText.ukeharaiChoseiKbn.text) {
                        resultValue = pageLangText.chosei.text;
                    }
                    //製造予定
                    else if (cellvalue == pageLangText.ukeharaiSeizoYoteiKbn.text) {
                        resultValue = pageLangText.seizoYotei.text;
                    }
                    //製造実績
                    else if (cellvalue == pageLangText.ukeharaiSeizoJissekiKbn.text) {
                        resultValue = pageLangText.seizoJisseki.text;
                    }
                }

                return resultValue;
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

                // 当日日付を挿入
                $(".search-criteria [name='dt_hiduke_from']").datepicker("setDate", new Date(((new Date()).setDate(1))));
                $(".search-criteria [name='dt_hiduke_to']").datepicker("setDate", new Date(new Date().getFullYear(), new Date().getMonth() + 1, 0));
                // 未使用分含むにチェックを入れる
                $(".search-criteria [name='flg_mishiyobun']").attr("checked", true);

                //受払区分のコンボを作成する。
                $('#id_kbn_ukeharai_sel').append($('<option>').html("").val(null));
                $('#id_kbn_ukeharai_sel').append($('<option>').html(pageLangText.nonyuYotei.text).val(0));
                $('#id_kbn_ukeharai_sel').append($('<option>').html(pageLangText.nonyuJisseki.text).val(1));
                $('#id_kbn_ukeharai_sel').append($('<option>').html(pageLangText.shiyoYotei.text).val(2));
                $('#id_kbn_ukeharai_sel').append($('<option>').html(pageLangText.shiyoJisseki.text).val(3));
                $('#id_kbn_ukeharai_sel').append($('<option>').html(pageLangText.chosei.text).val(4));
                $('#id_kbn_ukeharai_sel').append($('<option>').html(pageLangText.seizoYotei.text).val(5));
                $('#id_kbn_ukeharai_sel').append($('<option>').html(pageLangText.seizoJisseki.text).val(6));

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
                if (App.isUndefOrNull(con_bunrui)) {
                    // 分類が選択されていなかった場合、文字列のnullを設定する
                    con_bunrui = "null";
                }

                var query = {
                    url: "../api/GenshizaiUkeharaiIchiran",
                    kbn_hin: criteria.kbn_hin,
                    cd_bunrui: criteria.cd_bunrui,
//                    dt_hiduke_from: App.data.getDateTimeStringForQuery(criteria.dt_hiduke_from),
//                    dt_hiduke_to: App.data.getDateTimeStringForQuery(criteria.dt_hiduke_to),
                    dt_hiduke_from: App.data.getDateTimeStringForQueryNoUtc(criteria.dt_hiduke_from),
                    dt_hiduke_to: App.data.getDateTimeStringForQueryNoUtc(criteria.dt_hiduke_to),

                    cd_genshizai: criteria.cd_genshizai,
                    flg_mishiyobun: getFlgMishiyobun(criteria), //検索条件　未使用分含む
                    flg_shiyo: pageLangText.shiyoMishiyoFlg.text, //未使用フラグ：使用 0
                    flg_zaiko: getFlgZaiko(criteria),
                    flg_today_jisseki: getFlgTodayJisseki(criteria),
//                    dt_today: App.data.getDateTimeStringForQuery(getSystemDate()),
                    dt_today: App.data.getDateTimeStringForQueryNoUtc(getSystemDate()),

                    cd_kg: pageLangText.kgKanzanKbn.text,
                    cd_li: pageLangText.lKanzanKbn.text,
                    //予実フラグ
                    flg_yojitsu_yotei: pageLangText.yoteiYojitsuFlg.text,
                    flg_yojitsu_jisseki: pageLangText.jissekiYojitsuFlg.text,
                    //確定フラグ
                    flg_jisseki_kakutei: pageLangText.kakuteiKakuteiFlg.text,
                    //品区分
                    kbn_genryo: pageLangText.genryoHinKbn.text,
                    kbn_shizai: pageLangText.shizaiHinKbn.text,
                    kbn_jikagenryo: pageLangText.jikaGenryoHinKbn.text,
                    //受払区分　
                    NounyuYoteiKbn: pageLangText.ukeharaiNounyuYoteiKbn.text,
                    NounyuJissekiKbn: pageLangText.ukeharaiNounyuJissekiKbn.text,
                    ShiyoYoteiKbn: pageLangText.ukeharaiShiyoYoteiKbn.text,
                    ShiyoJissekiKbn: pageLangText.ukeharaiShiyoJissekiKbn.text,
                    ChoseiKbn: pageLangText.ukeharaiChoseiKbn.text,
                    seizoYoteiKbn: pageLangText.ukeharaiSeizoYoteiKbn.text,
                    seizoJissekiKbn: pageLangText.ukeharaiSeizoJissekiKbn.text,
                    // 理由区分(調整理由)
                    choseiRiyuKbn: pageLangText.choseiRiyuKbn.text,
                    ukeharaiKbn: $('[name=kbn_ukeharai_sel]').val(),
                    maxCount: querySetting.top
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
                ).done(function (result) {
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

            /// <summary>検索前チェック</summary>
            var findData = function () {
                // 情報メッセージのクリア
                App.ui.page.notifyInfo.clear();
                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();

                // 開始日 <= 終了日 であること
                var criteria = $(".search-criteria").toJSON();
                if (criteria.dt_hiduke_from > criteria.dt_hiduke_to) {
                    App.ui.page.notifyAlert.message(
                        App.str.format(MS0019, pageLangText.endDate.text, pageLangText.startDate.text)
                    ).show();
                    return false;
                }

                // 開始日～終了日が最大期間日数以内であること
                var startDay = criteria.dt_hiduke_from;
                var maxKikan = parseInt(pageLangText.maxPeriod.text);
                startDay.setDate(startDay.getDate() + maxKikan);
                if (startDay < criteria.dt_hiduke_to) {
                    App.ui.page.notifyAlert.message(App.str.format(MS0716, maxKikan)).show();
                    return false;
                }

                clearState();
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

                printExcel();
            };

            /// <summary>Excelファイル出力を行います。</summary>
            /// <param name="e">イベントデータ</param>
            var printExcel = function (e) {
                var criteria = $(".search-criteria").toJSON();
                // 画面の入力項目をURLへ渡す
                //url = "../api/HinmeiMasterIchiranExcel";

                // 検索条件：品区分
                var hinKbnName = pageLangText.noSelectConditionExcel.text;
                if (!App.isUndefOrNull(criteria.kbn_hin)) {
                    hinKbnName = $("#id_kbn_hin option:selected").text();
                }

                // 検索条件：分類
                var hinBunruiName = pageLangText.noSelectConditionExcel.text;
                if (!App.isUndefOrNull(criteria.cd_bunrui)) {
                    hinBunruiName = $("#id_cd_bunrui option:selected").text();
                  }

                // 検索条件：品名
                var hinName = $("#id_nm_genshizai").text();
                if (App.isUndefOrNull(hinName)) {
                  var hinName = $("#id_nm_genshizai").text("");
                }

                // 検索条件：未使用分含む
                var mishiyoubun = pageLangText.noSelectConditionExcel.text;
                if (!App.isUndefOrNull(criteria.flg_mishiyobun)) {
                    mishiyoubun = pageLangText.onCheckBoxExcel.text;
                }
                // 検索条件：ありのみ
                var ariNomi = pageLangText.noSelectConditionExcel.text;
                if (!App.isUndefOrNull(criteria.ari_nomi)) {
                    ariNomi = pageLangText.onCheckBoxExcel.text;
                }

                var ukeharaiName = pageLangText.noSelectConditionExcel.text;
                if (!App.isUndefOrNull(criteria.kbn_ukeharai_sel)) {
                    ukeharaiName = $("#id_kbn_ukeharai_sel option:selected").text();
                }

                var query = {
                    url: "../api/GenshizaiUkeharaiIchiranExcel",
                    kbn_hin: criteria.kbn_hin,
                    cd_bunrui: criteria.cd_bunrui,
                    //                    dt_hiduke_from: App.data.getDateTimeStringForQuery(criteria.dt_hiduke_from),
                    //                    dt_hiduke_to: App.data.getDateTimeStringForQuery(criteria.dt_hiduke_to),
                    dt_hiduke_from: App.data.getDateTimeStringForQueryNoUtc(criteria.dt_hiduke_from),
                    dt_hiduke_to: App.data.getDateTimeStringForQueryNoUtc(criteria.dt_hiduke_to),

                    cd_genshizai: criteria.cd_genshizai,
                    flg_mishiyobun: getFlgMishiyobun(criteria), //検索条件　未使用分含む
                    flg_shiyo: pageLangText.shiyoMishiyoFlg.text, //未使用フラグ：使用 0
                    flg_zaiko: getFlgZaiko(criteria),
                    flg_today_jisseki: getFlgTodayJisseki(criteria),
                    //                    dt_today: App.data.getDateTimeStringForQuery(getSystemDate()),
                    dt_today: App.data.getDateTimeStringForQueryNoUtc(getSystemDate()),

                    cd_kg: pageLangText.kgKanzanKbn.text,
                    cd_li: pageLangText.lKanzanKbn.text,
                    //予実フラグ
                    flg_yojitsu_yotei: pageLangText.yoteiYojitsuFlg.text,
                    flg_yojitsu_jisseki: pageLangText.jissekiYojitsuFlg.text,
                    //確定フラグ
                    flg_jisseki_kakutei: pageLangText.kakuteiKakuteiFlg.text,
                    //品区分
                    kbn_genryo: pageLangText.genryoHinKbn.text,
                    kbn_shizai: pageLangText.shizaiHinKbn.text,
                    kbn_jikagenryo: pageLangText.jikaGenryoHinKbn.text,
                    //受払区分　
                    NounyuYoteiKbn: pageLangText.ukeharaiNounyuYoteiKbn.text,
                    NounyuJissekiKbn: pageLangText.ukeharaiNounyuJissekiKbn.text,
                    ShiyoYoteiKbn: pageLangText.ukeharaiShiyoYoteiKbn.text,
                    ShiyoJissekiKbn: pageLangText.ukeharaiShiyoJissekiKbn.text,
                    ChoseiKbn: pageLangText.ukeharaiChoseiKbn.text,
                    seizoYoteiKbn: pageLangText.ukeharaiSeizoYoteiKbn.text,
                    seizoJissekiKbn: pageLangText.ukeharaiSeizoJissekiKbn.text,
                    // 理由区分(調整理由)
                    choseiRiyuKbn: pageLangText.choseiRiyuKbn.text,
                    ukeharaiKbn: $('[name=kbn_ukeharai_sel]').val(),
                    ukeharaiName: ukeharaiName,
                    lang: App.ui.page.lang,
                    hinKubunName: encodeURIComponent(hinKbnName),
                    hinBunruiName: encodeURIComponent(hinBunruiName),
                    hinName: encodeURIComponent(hinName),
                    mishiyoubun: encodeURIComponent(mishiyoubun),
                    ariNomi: encodeURIComponent(ariNomi),
                    userName: encodeURIComponent(App.ui.page.user.Name),
                    today: App.data.getDateTimeStringForQuery(new Date(), true)
                    //today: App.data.getDateTimeStringForQueryNoUtc(new Date(), true)//出力日時は10時固定にしない
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
                if (app_util.prototype.getCookieValue(pageLangText.genshizaiUkeharaiIchiranCookie.text) == pageLangText.checkCookie.text) {
                    app_util.prototype.deleteCookie(pageLangText.genshizaiUkeharaiIchiranCookie.text);
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
                        <span class="item-label" style="width: 50px" data-app-text="dt_hiduke_search"></span>
                        <input type="text" name="dt_hiduke_from" id="dt_hiduke_from" style="width: 100px;" />
                    </label>
                    <label>
                        <span data-app-text="between"></span>
                    </label>
                    <label>
                        <input type="text" name="dt_hiduke_to" id="dt_hiduke_to" style="width: 100px;" />
                    </label>
                    <br />
                    <label>
                        <span class="item-label">&nbsp;</span> <span class="item-label" style="width: 123px">
                            &nbsp;</span>
                    </label>
                    <br />
                    <label>
                        <input type="checkbox" name="flg_mishiyobun" /><span class="item-label" id="flg_mishiyobun" style="width: 300px" 
                           data-app-text="flg_mishiyobun"></span>
                    </label>
                    <br />
                    <label>
                        <input type="checkbox" name="ari_nomi" /><span class="item-label" id="ari_nomi" style="width: 320px"
                            data-app-text="ari_nomi"></span>
                    </label>
                    <br />
                    <label>
                        <input type="checkbox" name="flg_today_jisseki" /><span class="item-label" id="flg_today_jisseki" style="width: 320px"
                            data-app-text="flg_today_jisseki"></span>
                    </label>
                </li>
            </ul>
            <ul class="item-list item-list-right">
                <li>
                    <label>
                        <span class="item-label" style="width: 90px" data-app-text="hinKubun"></span>
                        <select name="kbn_hin" id="id_kbn_hin">
                        </select>
                    </label>
                </li>
                <li>
                    <label>
                        <span class="item-label" style="width: 90px" data-app-text="hinBunrui"></span>
                        <select name="cd_bunrui" id="id_cd_bunrui">
                        </select>
                    </label>
                </li>
                <li>
                    <label>
                        <span class="item-label" data-app-text="hinCode"></span>
                        <input type="text" name="cd_genshizai" id="id_cd_genshizai" maxlength="14" style="width: 110px" />
                    </label>
                    <button type="button" class="hinmei-button" id="hincode-button">
                        <span class="icon"></span><span data-app-text="codeSearch"></span>
                    </button>
                </li>
                <li>
                    <label>
                        <span class="item-label" data-app-text="hinName"></span>
                        <span class="nm_genshizai" id="id_nm_genshizai"></span>
                    </label>
                </li>
                <li>
                    <label>
                        <span class="item-label" style="width: 90px" data-app-text="ukeKubun"></span>
                        <select name="kbn_ukeharai_sel" id="id_kbn_ukeharai_sel">
                        </select>
                    </label>
                </li>
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
        <button type="button" class="menu-button" name="menu-button">
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
