<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="NonyuIraishoList.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.NonyuIraishoList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="IncludeContent" runat="server">
    <script src="<%=ResolveUrl("~/Resources/pages/pagedata-nonyuiraisholist." + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
    <script src="<%=ResolveUrl("~/Resources/grid/grid.locale-" + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
    <script src="<%=ResolveUrl("~/Resources/systemconst." + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        /* 画面デザイン -- Start */
        
        /* TODO：画面の仕様に応じて以下のスタイルを変更してください。 */
        .part-body .item-label
        {
            display: inline-block;
        }
        
        #result-grid
        {
            padding: 0px;
            overflow: hidden;
        }
        
        .part-body .item-list li
        {
            margin-bottom: .2em;
        }

        .header-content {
            margin-left: 10px;
            margin-right: 10px;
        }
        
        .search-criteria select
        {
            width: 20em;
        }
        
        .search-criteria .item-label
        {
            width: 10em;
        }
                
        .search-confirm-dialog
        {
            background-color: White;
            width: 350px;
        }
                
        .search-confirm-dialog .part-body
        {
            width: 95%;
        }
        
        .pagemaxim-confirm-dialog
        {
            background-color: White;
            width: 430px;
        }
                
        .pagemaxim-confirm-dialog .part-body
        {
            width: 95%;
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
                searchCondition;

            // グリッドコントロール固有の変数宣言
            var grid = $("#item-grid"),
                lastScrollTop = 0,
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
                changeSet = new App.ui.page.changeSet(),
                firstCol = 1,
                duplicateCol = 999,
                currentRow = 0,
                currentCol = firstCol,
                printType = "0",
                headerContent = {
                    hachuNo: "",
                    kaishaName: "",
                    renrakusaki: "",
                    renrakusakiTel: "",
                    renrakusakiFax: "",
                    nohinsaki: "",
                    nohinsakiAdd: ""
                };
            // TODO: ここまで

            var torihikisaki,  // 検索条件のコンボボックス：取引先
                hinmeiName = 'nm_hinmei_' + App.ui.page.lang;   // 多言語対応

            // 時刻を除いたシステム日付
            var systemDate = new Date(new Date().getFullYear(), new Date().getMonth(), new Date().getDate());

            // ダイアログ固有の変数宣言
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            var searchConfirmDialog = $(".search-confirm-dialog");
            var pageMaximConfirmDialog = $(".pagemaxim-confirm-dialog");

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
                        //pamameters[keyValue[0]] = keyValue[1];
                        // Chromeだと半角スペースなどが自動でエンコードされているので、デコード処理が必要
                        pamameters[keyValue[0]] = decodeURIComponent(keyValue[1]);
                    }
                }
                return pamameters;
            };

            /// <summary>文字列内の空白(全半角どちらも)を除去する</summary>
            var delBlank = function (str) {
                if (!App.isUndefOrNull(str)) {
                    str = str + ""; // 数値型で受け取った場合の対策。空文字を足すことでstringに変換する。
                    str = str.replace(/[\s　]/g, "");
                }
                return str;
            };

            /// <summary>nullは空文字に変換する</summary>
            var nullToBlank = function (str) {
                if (App.isUndefOrNull(str)) {
                    str = "";
                }
                return str;
            };

            /// <summary>カンマで区切られた文字列を分解します。</summary>
            var splitComma = function (str) {
                var array = "";
                if (!App.isUndefOrNull(str)) {
                    array = str.split(',');
                }
                return array;
            };

            // 1の場合はtrue、それ以外はfalseを返却
            var changeFlag = function (flg) {
                if (!App.isUndefOrNull(flg)) {
                    if (flg == pageLangText.trueFlg.text) {
                        return true;
                    }
                }
                return false;
            };

            // 作成日にスラッシュを付与
            var attachedDateSlash = function (date) {
                if (App.ui.page.lang == 'ja' || App.ui.page.lang == 'zh') {
                    var val = date.substr(0, 4) + "/" + date.substr(4, 2) + "/" + date.substr(6, 2);
                    return val;
                }
                else {
                    var val = date.substr(0, 2) + "/" + date.substr(2, 2) + "/" + date.substr(4, 4);
                    return val;
                }
            };

            // urlよりパラメーターを取得
            var parameters = getParameters();
            var paramTorihiki = parameters["to"],
                paramHin = parameters["hi"];
            var dt_create = attachedDateSlash(parameters["dt"]);
            var yotei = changeFlag(parameters["yo"]);
            var bunrui = changeFlag(parameters["bu"]);
            var cd_niuke = parameters["ni"];
            var comment = parameters["co"];
            // 印刷用パラメーター(カンマ区切りで渡す為)
            var printHinCd = paramHin;
            var printTorihikiCd = paramTorihiki;
            // パラメーター用の開始日と終了日
            var creDateFrom = App.date.localDate(dt_create),
                creDateTo = App.date.localDate(dt_create);
            creDateTo.setDate(creDateTo.getDate() + 30);
            creDateFrom = App.data.getDateTimeStringForQueryNoUtc(creDateFrom);
            creDateTo = App.data.getDateTimeStringForQueryNoUtc(creDateTo);

            /// <summary>配列データをorで連結する</summary>
            var connectionArray = function (array, property) {
                var queryStr = "";
                if (App.isUndefOrNull(array)) {
                    return queryStr;
                }
                else {
                    if (array.length == 1) {
                        queryStr = property + " eq '" + array[0] + "'";
                    }
                    else if (array.length > 0) {
                        queryStr = "( ";
                        for (var i = 0; array.length > i; i++) {
                            queryStr += property + " eq '" + array[i] + "' ";
                            if (i + 1 == array.length) {
                                break;
                            }
                            else {
                                queryStr += "or ";
                            }
                        }
                        queryStr += ")";
                    }
                    else {
                        return queryStr;
                    }
                }
                return queryStr;
            };

            /// <summary>検索条件/取引先：取引先情報の抽出条件クエリを取得する</summary>
            /// <param name="torihikiCd">選択された取引先コード</param>
            /// <param name="cd_hin">選択された品名コード</param>
            var getQueryTorihiki = function (torihikiCd, cd_hin) {
                var result,
                    paramCode = "",
                    flgHin = "",
                    flgYotei = pageLangText.falseFlg.text;

                if (App.isUndefOrNull(torihikiCd) || torihikiCd == "") {
                    // 取引先コードがない場合(品名選択のみの場合)
                    paramCode = cd_hin;
                    // 品名選択のみフラグON
                    flgHin = pageLangText.trueFlg.text;
                }
                else {
                    // 取引先コードが選択されていた場合
                    paramCode = torihikiCd;
                    // 品名選択のみフラグOFF
                    flgHin = pageLangText.falseFlg.text;
                }
                if (yotei) {
                    // 「予定なしも出力」にチェックが入っていた場合、予定なしフラグON
                    flgYotei = pageLangText.trueFlg.text;
                }

                //// 抽出処理
                var query = {
                    url: "../api/NonyuIraishoList",
                    dateFrom: creDateFrom,
                    dateTo: creDateTo,
                    sysdate: App.data.getDateTimeStringForQueryNoUtc(systemDate),
                    codes: paramCode,
                    flgHin: flgHin,
                    flgYotei: flgYotei
                };

                return App.data.toWebAPIFormat(query);
            };

            // TODO：ここまで

            //// 変数宣言 -- End

            //// コントロール定義 -- Start

            // ダイアログ固有のコントロール定義
            searchConfirmDialog.dlg();
            pageMaximConfirmDialog.dlg();

            /// レコード件数チェック
            var checkRecordCount = function () {
                recordCount = grid.getGridParam("records");
                // レコードがない場合は処理を抜ける
                if (recordCount == 0) {
                    App.ui.page.notifyInfo.message(pageLangText.noRecords.text).show();
                    return false;
                }
                return true;
            };

            /// <summary>ダイアログを開きます。</summary>
            // 検索時のダイアログ
            var showSearchConfirmDialog = function () {
                searchConfirmDialogNotifyInfo.clear();
                searchConfirmDialogNotifyAlert.clear();
                searchConfirmDialog.draggable(true);
                searchConfirmDialog.dlg("open");
            };
            // 上限印刷数オーバー時のダイアログ
            var showPageMaximConfirmDialog = function () {
                pageMaximConfirmDialogNotifyInfo.clear();
                pageMaximConfirmDialogNotifyAlert.clear();
                pageMaximConfirmDialog.draggable(true);
                pageMaximConfirmDialog.dlg("open");
            };

            /// <summary>ダイアログを閉じます。</summary>
            var closeSearchConfirmDialog = function () {
                searchConfirmDialog.dlg("close");
            };
            /// <summary>ダイアログを閉じます。</summary>
            var closePageMaximConfirmDialog = function () {
                pageMaximConfirmDialog.dlg("close");
            };

            // 日付の多言語対応
            var newDateFormat;
            if (App.ui.page.langCountry !== 'en-US') {
                newDateFormat = pageLangText.listDateFormat.text;
            }
            else {
                newDateFormat = pageLangText.listDateFormatUS.text;
            }
            // グリッドコントロール固有のコントロール定義
            grid.jqGrid({
                // 列名の定義
                colNames: [
                    pageLangText.cd_hinmei.text,
                    pageLangText.nm_hinmei.text,
                    pageLangText.nm_nisugata_hyoji.text,
                    pageLangText.tani_nonyu.text,
                    pageLangText.nm_bunrui.text,
                    pageLangText.dt_nonyu.text,
                    pageLangText.su_nonyu.text,
                    pageLangText.juryo.text
                ],
                // 列モデルの定義
                colModel: [
                    { name: 'cd_hinmei', width: pageLangText.cd_hinmei_width.number, editable: false, sorttype: "text" },
                    { name: hinmeiName, width: 300, editable: false, sorttype: "text" },
                    { name: 'nm_nisugata_hyoji', width: 120, editable: false, sorttype: "text" },
                    { name: 'nm_tani', width: 70, editable: false, sorttype: "text" },
                    { name: 'nm_bunrui', width: 200, editable: false, hidedlg: true },
                    { name: 'dt_nonyu', width: 100, sorttype: "text", align: "left",
                        formatter: "date",
                        formatoptions: {
                            srcformat: newDateFormat, newformat: newDateFormat
                        }
                    },
                    { name: 'su_nonyu', width: 70, editable: false, align: "right", sorttype: "float",
                        formatter: 'number',
                        formatoptions: {
                            decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 2, defaultValue: "0"
                        }
                    },
                    { name: 'juryo', width: 110, editable: false, align: "right", sorttype: "float",
                        formatter: 'number',
                        formatoptions: {
                            decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 3, defaultValue: "0"
                        }
                    }
                ],
                datatype: "local",
                shrinkToFit: false,
                multiselect: false,
                rownumbers: true,
                cellEdit: true,
                cellsubmit: 'clientArray'
                //loadComplete: function () {
                // 変数宣言
                //var ids = grid.jqGrid('getDataIDs'),
                //    criteria = $(".search-criteria").toJSON();
                //for (var i = 0; i < ids.length; i++) {
                //     var id = ids[i];
                // TODO : ここから
                // TODO：ここまで
                //}
                //}
            });

            /// <summary>セルの関連項目を設定します。</summary>
            /// <param name="selectedRowId">選択行ID</param>
            /// <param name="cellName">列名</param>
            /// <param name="value">元となる項目の値</param>
            /// <param name="iCol">項目の列番号</param>
            var setRelatedValue = function (selectedRowId, cellName, value, iCol) {
                // TODO：画面の仕様に応じて以下の関連項目を設定を変更してください。
                // TODO：ここまで
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
            /// <summary>グリッドの列変更ボタンクリック時のイベント処理を行います。</summary>
            $(".colchange-button").on("click", showColumnSettingDialog);

            //// コントロール定義 -- End

            //// 操作制御定義 -- Start

            // 操作制御定義を定義します。
            App.ui.pagedata.operation.applySetting(App.ui.page.user.Roles[0], App.ui.page.lang);

            //// 操作制御定義 -- End

            //// 事前データロード -- Start 

            // 画面アーキテクチャ共通の事前データロード
            var loading;
            App.deferred.parallel({
                // ローディング
                loading: App.ui.loading.show(pageLangText.nowProgressing.text),
                torihikisaki: App.ajax.webget(getQueryTorihiki(paramTorihiki, paramHin))
            }).done(function (result) {

                // 作成開始日の設定
                $(".search-criteria [name='dt_sakusei_kaishi']").text(dt_create);

                var resultTorihiki = result.successes.torihikisaki;
                if (resultTorihiki.length == 0) {
                    // 取得した取引先が0件だった場合
                    // 「メニューへ」以外のボタンをすべて使用不可にし、「該当なし」のメッセージを表示する
                    $(".command [name='find-button']").attr("disabled", true).css("display", "none");
                    $(".command [name='pdf-button']").attr("disabled", true).css("display", "none");
                    $(".command [name='pdf-button-all']").attr("disabled", true).css("display", "none");
                    closeCriteria();    // 検索条件を閉じる
                    App.ui.loading.close();
                    App.ui.page.notifyAlert.message(pageLangText.notFound.text).show();
                    return;
                }
                else if (resultTorihiki.length < 2) {
                    // 取引先が2件未満の場合、全件印刷ボタンを使用不可にする
                    $(".command [name='pdf-button-all']").attr("disabled", true).css("display", "none");
                }
                // 検索用ドロップダウンの設定
                var target = $(".search-criteria [name='torihikisaki']")
                App.ui.appendOptions(target, "cd_torihiki", "nm_torihiki", resultTorihiki, false);

                // 発注番号の採番
                getHachuNumber(new queryHachuNo());

                // ヘッダー情報の取得
                getHeader();

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
            });

            /// <summary>発注番号用クエリオブジェクトの設定</summary>
            var queryHachuNo = function () {
                var query = {
                    url: "../api/NonyuIraishoList",
                    saibanKbn: pageLangText.hachuSaibanKbn.text,
                    prefix: pageLangText.hachuPrefix.text,
                    top: 1
                }

                return query;
            };

            // 日付文字列から年月を6桁で取得します。
            // <param name="date">日付文字列</param>
            var getYearMonthString = function (date) {
                if (App.ui.page.langCountry !== 'en-US') {
                    return date.substr(pageLangText.yearStartPos.number, 4) + date.substr(pageLangText.monthStartPos.number, 2);
                }
                else {
                    return date.substr(pageLangText.yearStartPosUS.number, 4) + date.substr(pageLangText.monthStartPosUS.number, 2);
                }
            };

            // 発注番号を作成します。
            // ログイン工場コード - 検索条件/取引先コード - 作成開始日の年月 - 採番した番号
            // <param name="saibanNo">採番した番号</param>
            var createHachuNo = function (saibanNo) {
                var criteria = $(".search-criteria").toJSON();
                var kojoCode = App.ui.page.user.BranchCode,
                    torihikiCode = criteria.torihikisaki,
                    hachuNumber,
                    JOIN_STR = "-";
                // 作成開始日を年月にする
                var createDate = getYearMonthString(dt_create);
                hachuNumber = kojoCode + JOIN_STR + torihikiCode + JOIN_STR + createDate + JOIN_STR + saibanNo;
                return hachuNumber;
            };
            /// <summary>発注番号を採番します</summary>
            /// <param name="query">クエリオブジェクト</param>
            var getHachuNumber = function (query) {
                //App.ajax.webget(
                App.ajax.webgetSync(
                    App.data.toWebAPIFormat(query)
                ).done(function (result) {
                    // 発注番号の設定
                    var hachuNumber = createHachuNo(result);
                    $(".header-content [name='hachuNo']").text(hachuNumber);
                    headerContent.hachuNo = hachuNumber;
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                });
            };

            /// <summary>納品先の住所1～3を連結し、空白を除去する。</summary>
            /// <param name="val">納品先情報(荷受場所マスタ情報)</param>
            var getNohinsakiJusho = function (val) {
                var jusho1 = nullToBlank(val.nm_jusho_1)
                    , jusho2 = nullToBlank(val.nm_jusho_2)
                    , jusho3 = nullToBlank(val.nm_jusho_3);
                var address = jusho1 + jusho2 + jusho3;
                return delBlank(address);
            };
            // ヘッダー情報の取得
            var getHeader = function () {
                App.deferred.parallel({
                    // 連絡先：工場マスタ
                    //renrakusaki: App.ajax.webget("../Services/FoodProcsService.svc/ma_kojo?$filter=cd_kaisha eq '"
                    //    + App.ui.page.user.KaishaCode + "' and  cd_kojo eq '" + App.ui.page.user.BranchCode + "'"),
                    renrakusaki: App.ajax.webget("../Services/FoodProcsService.svc/ma_kojo?$orderby=cd_kaisha,cd_kojo&$top=1"),
                    // 納品先：荷受場所マスタ
                    nohinsaki: App.ajax.webget("../Services/FoodProcsService.svc/ma_niuke?$filter=cd_niuke_basho eq '" + cd_niuke + "'")
                }).done(function (result) {
                    renrakusaki = result.successes.renrakusaki.d;
                    nohinsaki = result.successes.nohinsaki.d;

                    if (!App.isUndefOrNull(renrakusaki[0])) {
                        var renrakusaki = renrakusaki[0];
                        // 連絡先の設定
                        $(".header-content [name='renrakusaki']").text(App.ui.page.user.Branch);
                        if (!App.isUndefOrNull(renrakusaki.no_tel_1) && renrakusaki.no_tel_1.length > 0) {
                            $(".header-content [name='renrakusaki_tel']").text(renrakusaki.no_tel_1);
                            headerContent.renrakusakiTel = renrakusaki.no_tel_1;
                        }
                        if (!App.isUndefOrNull(renrakusaki.no_fax_1) && renrakusaki.no_fax_1.length > 0) {
                            $(".header-content [name='renrakusaki_fax']").text(renrakusaki.no_fax_1);
                            headerContent.renrakusakiFax = renrakusaki.no_fax_1;
                        }
                        headerContent.renrakusaki = App.ui.page.user.Branch;
                        headerContent.kaishaName = App.ui.page.user.Organization;
                    }
                    if (!App.isUndefOrNull(nohinsaki[0])) {
                        var nohinsaki = nohinsaki[0],
                            address = getNohinsakiJusho(nohinsaki);
                        // 納品先の設定
                        $(".header-content [name='nohinsaki']").text(nohinsaki.nm_niuke);
                        $(".header-content [name='nohinsaki_add']").text(address);
                        headerContent.nohinsaki = nohinsaki.nm_niuke;
                        headerContent.nohinsakiAdd = address;
                    }

                    // 初期検索
                    searchItems(new query());

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
            };

            //// 事前データロード -- End

            //// 検索処理 -- Start

            // 画面アーキテクチャ共通の検索処理

            /// <summary>クエリオブジェクトの設定</summary>
            var query = function () {
                var criteria = $(".search-criteria").toJSON();
                searchCondition = criteria;

                var query = {
                    url: "../api/NonyuIraishoList",
                    torihikiCode: criteria.torihikisaki,
                    hinCode: printHinCd,
                    dateFrom: creDateFrom,
                    dateTo: creDateTo,
                    sysdate: App.data.getDateTimeStringForQueryNoUtc(systemDate),
                    skip: querySetting.skip
                    //inlinecount: "allpages"
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
                // ローディングの表示
                $("#list-loading-message").text(
                    App.str.format(
                        pageLangText.nowLoading.text,
                        querySetting.skip + 1,
                        querySetting.top
                    )
                );
                App.ajax.webget(
                    App.data.toWebAPIFormat(query)
                ).done(function (result) {
                    // データバインド
                    bindData(result);
                    // グリッドの先頭行選択
                    var idNum = grid.getGridParam("selrow");
                    if (idNum == null) {
                        $("#1 > td").click();
                    }
                    else {
                        $("#" + idNum).removeClass("ui-state-highlight").find("td").click();
                    }
                    // 検索条件を閉じる
                    closeCriteria();
                    $(".ui-jqgrid-hdiv").scrollLeft(0); // 明細のスクロール位置をリセット
                }).fail(function (result) {
                    if (result.message != "") {
                        App.ui.page.notifyAlert.message(result.message).show();
                    }
                    else {
                        App.ui.page.notifyAlert.message(MS0084).show();
                    }
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
            var findData = function () {
                closeSearchConfirmDialog();
                clearState();
                // 検索前バリデーション
                var result = $(".part-body .item-list").validation().validate();
                if (result.errors.length) {
                    return;
                }
                // 発注番号の採番
                getHachuNumber(new queryHachuNo());
                // 検索処理の実行
                searchItems(new query());
            };
            $(".find-button").on("click", findData);

            // グリッドコントロール固有の検索処理

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
            var displayCount = function () {
                $("#list-count").text(
                     App.str.format("{0}/{1}", querySetting.skip, querySetting.count)
                );
            };
            /// <summary>データをバインドします。</summary>
            /// <param name="result">検索結果</param>
            var bindData = function (result) {
                querySetting.count = querySetting.skip + result.length;

                // 検索結果が40件を超えていた場合
                if (parseInt(result.length) > querySetting.top) {
                    // 40件を超えた検索結果は削除する
                    result.splice(querySetting.top, result.length);
                }
                querySetting.skip = querySetting.skip + result.length;

                // グリッドの表示件数を更新
                grid.setGridParam({ rowNum: querySetting.skip });
                displayCount();
                // データバインド
                var currentData = grid.getGridParam("data").concat(result);
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
            /// <summary>後続データ検索を行います。</summary>
            /// <param name="target">グリッド</param>
            var nextSearchItems = function (target) {
                var scrollTop = lastScrollTop;
                if (scrollTop === target.scrollTop) {
                    return;
                }
                if (querySetting.skip === querySetting.count) {
                    return;
                }
                lastScrollTop = target.scrollTop;
                if (target.scrollHeight - target.scrollTop <= $(target).outerHeight()) {
                    // データ検索
                    searchItems(new query());
                }
            };
            /// <summary>グリッドスクロール時のイベント処理を行います。</summary>
            $(".ui-jqgrid-bdiv").scroll(function (e) {
                // 後続データ検索
                nextSearchItems(this);
            });

            //// 検索処理 -- End

            //// メッセージ表示 -- Start

            // グリッドコントロール固有のメッセージ表示

            /// <summary>カレント行のエラーメッセージを削除します。</summary>
            /// <param name="selectedRowId">選択行ID</param>
            var removeAlertRow = function (selectedRowId) {
                var unique,
                    colModel = grid.getGridParam("colModel");

                for (var i = 0; i < colModel.length; i++) {
                    unique = selectedRowId + "_" + i;
                    App.ui.page.notifyAlert.remove(unique);
                }
            };
            /// <summary>エラーのセル情報を取得します。</summary>
            /// <param name="unique">エラーを特定するキー</param>
            var getAlertInfo = function (unique) {
                var info = {},
                    splits;
                splits = unique.split("_");
                info.selectedRowId = splits[0];
                info.iCol = parseInt(splits[1], 10);

                return info;
            };
            /// <summary>エラー一覧クリック時の処理を行います。</summary>
            /// <param name="data">エラー情報</param>
            var handleNotifyAlert = function (data) {
                //data.unique でキーが取得できる
                //data.handledにtrueを指定することでデフォルトの動作(キーがHTMLElementの場合にフォーカスを当てる処理)の実行をキャンセルする

                // グリッド内のエラーの場合、data.uniqueがstringになるため以下の条件分岐を追加
                if (!App.isStr(data.unique)) {
                    data.handled = false;
                    return;
                }
                data.handled = true;

                // エラーのセル情報を取得
                var info = getAlertInfo(data.unique),
                    iRow = $('#' + info.selectedRowId)[0].rowIndex;

                // 同時実行制御エラーの場合は編集可能なセルの先頭列を選択
                if (info.iCol === duplicateCol) {
                    info.iCol = firstCol;
                }

                // セルを選択して入力モードにする
                grid.editCell(iRow, info.iCol, true);
            };

            /// <summary>エラー一覧クリック時のイベント処理を行います。</summary>
            $(App.ui.page.notifyAlert).on("itemselected", function (e, data) {
                // エラー一覧クリック時の処理
                handleNotifyAlert(data);
            });

            // ダイアログ固有のメッセージ表示
            // ダイアログ情報メッセージの設定

            // 検索時ダイアログ情報メッセージの設定
            var searchConfirmDialogNotifyInfo = App.ui.notify.info(searchConfirmDialog, {
                container: ".search-confirm-dialog .dialog-slideup-area .info-message",
                messageContainerQuery: "ul",
                show: function () {
                    searchConfirmDialog.find(".info-message").show();
                },
                clear: function () {
                    searchConfirmDialog.find(".info-message").hide();
                }
            });
            // 印刷時ページが上限値に達したときのダイアログ情報メッセージの設定
            var pageMaximConfirmDialogNotifyInfo = App.ui.notify.info(pageMaximConfirmDialog, {
                container: ".pagemaxim-confirm-dialog .dialog-slideup-area .info-message",
                messageContainerQuery: "ul",
                show: function () {
                    pageMaximConfirmDialog.find(".info-message").show();
                },
                clear: function () {
                    pageMaximConfirmDialog.find(".info-message").hide();
                }
            });

            // ダイアログ警告メッセージの設定
            var searchConfirmDialogNotifyAlert = App.ui.notify.alert(searchConfirmDialog, {
                container: ".search-confirm-dialog .dialog-slideup-area .alert-message",
                messageContainerQuery: "ul",
                show: function () {
                    searchConfirmDialog.find(".alert-message").show();
                },
                clear: function () {
                    searchConfirmDialog.find(".alert-message").hide();
                }
            });
            var pageMaximConfirmDialogNotifyAlert = App.ui.notify.alert(pageMaximConfirmDialog, {
                container: ".pagemaxim-confirm-dialog .dialog-slideup-area .alert-message",
                messageContainerQuery: "ul",
                show: function () {
                    pageMaximConfirmDialog.find(".alert-message").show();
                },
                clear: function () {
                    pageMaximConfirmDialog.find(".alert-message").hide();
                }
            });

            //// メッセージ表示 -- End

            //// データ変更処理 -- Start
            //// データ変更処理 -- End

            //// 保存処理 -- Start
            //// 保存処理 -- End

            //// バリデーション -- Start

            // グリッドコントロール固有のバリデーション

            // TODO: 画面の仕様に応じて以下のカスタムバリデーション定義を変更してください。
            // TODO: ここまで

            // グリッドのバリデーション設定
            var v = Aw.validation({
                items: validationSetting
            });

            /// <summary>カレントのセルバリデーションを実行します。</summary>
            /// <param name="selectedRowId">選択行ID</param>
            /// <param name="cellName">列名</param>
            /// <param name="value">エラー項目の値</param>
            /// <param name="iCol">エラー項目の列番号</param>
            var validateCell = function (selectedRowId, cellName, value, iCol) {
                var unique = selectedRowId + "_" + iCol,
                    val = {},
                    result;
                // エラーメッセージの解除
                App.ui.page.notifyAlert.remove(unique);
                grid.setCell(selectedRowId, iCol, value, { background: 'none' });
                val[cellName] = value;
                // バリデーションのコールバック関数の実行をスキップ
                result = v.validate(val, { suppressCallback: false });
                if (result.errors.length) {
                    // エラーメッセージの表示
                    App.ui.page.notifyAlert.message(result.errors[0].message, unique).show();
                    // 対象セルの背景変更
                    grid.setCell(selectedRowId, iCol, value, { background: '#ff6666' });
                    return false;
                }
                return true;
            };

            /// <summary>カレントの行バリデーションを実行します。</summary>
            /// <param name="selectedRowId">選択行ID</param>
            var validateRow = function (selectedRowId) {
                var isValid = true,
                    colModel = grid.getGridParam("colModel"),
                    iRow = $('#' + selectedRowId)[0].rowIndex;
                // 行番号はチェックしない
                for (var i = 1; i < colModel.length; i++) {
                    // セルを選択して入力モードを解除する
                    grid.editCell(iRow, i, false);
                    // セルバリデーション
                    if (!validateCell(selectedRowId, colModel[i].name, grid.getCell(selectedRowId, colModel[i].name), i)) {
                        isValid = false;
                    }
                }
                return isValid;
            };

            /// <summary>変更セットのバリデーションを実行します。</summary>
            var validateChangeSet = function () {
                for (p in changeSet.changeSet.created) {
                    if (!changeSet.changeSet.created.hasOwnProperty(p)) {
                        continue;
                    }
                    // カレントの行バリデーションを実行
                    if (!validateRow(p)) {
                        return false;
                    }
                }
                for (p in changeSet.changeSet.updated) {
                    if (!changeSet.changeSet.updated.hasOwnProperty(p)) {
                        continue;
                    }
                    // カレントの行バリデーションを実行
                    if (!validateRow(p)) {
                        return false;
                    }
                }
                return true;
            };

            //// バリデーション -- End

            /// <summary>ファンクションキー対応処理</summary>
            /// <param name="e">イベントデータ</param>
            var processFunctionKey = function (e) {
                var processed = false;
                // TODO: 画面の仕様に応じて以下のファンクションキー毎の処理を定義します。
                if (e.keyCode === App.ui.keys.F2) {
                    // F2の処理
                    processed = true;
                }
                else if (e.keyCode === App.ui.keys.F3) {
                    //F3の処理
                    processed = true;
                }
                // TODO: ここまで
                if (processed) {
                    //何か処理を行なっていた場合、ブラウザ既定の動作を無効にする
                    e.preventDefault();
                }
            };
            /// <summary>キーダウン時のイベント処理を行います。</summary>
            $(window).on("keydown", processFunctionKey);

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
                    resultPartStyle = resultPart[0].currentStyle || document.defaultView.getComputedStyle(resultPart[0], ""),
                    partBody = $(".part-body");

                // ヘッダーを入れての高さ調整(partBody.outeHeight(true)-16) 16はpaddingなどの分の微調整
                resultPart.height(container[0].clientHeight - searchPart[0].clientHeight - ((parseInt(resultPartStyle.marginTop, 10) * 3) || 0) - partBody.outerHeight(true) - 16);
                grid.setGridWidth(resultPart[0].clientWidth - 5);
                //結果一覧のパートの高さ - パートのヘッダーの高さ - パート内のボタンのコマンドの高さ - jqGrid のカラムヘッダーの高さ
                grid.setGridHeight(resultPart[0].clientHeight - resultPartHeader[0].clientHeight - resultPartCommands[0].clientHeight - resultPart.find(".ui-jqgrid-hdiv")[0].clientHeight - 16);
            };
            /// <summary>画面リサイズ時のイベント処理を行います。</summary>
            $(App.ui.page).on("resized", resizeContents);

            /// <summary>チェックページ数を超えていたときの印刷確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".pagemaxim-confirm-dialog .dlg-yes-button").on("click", function () {
                closePageMaximConfirmDialog();
                // 時間がかかる為、その間操作しないよう注意メッセージ：infoだと数秒で消えてしまう為、alertで表示
                App.ui.page.notifyAlert.message(pageLangText.notOperate.text).show();
                // 出力処理へ
                downloadOverlay();
            });
            // <summary>チェックページ数を超えていたときの印刷確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".pagemaxim-confirm-dialog .dlg-no-button").on("click", closePageMaximConfirmDialog);

            /// <summary>ダウンロードボタンクリック時のオーバレイ処理を行います。</summary>
            var downloadOverlay = function () {
                App.ui.loading.show(pageLangText.nowProgressing.text);
                printPdf();
                App.ui.loading.close();

                // 発注番号の採番 ★★保留★★現状だとPDF処理前に発番されてしまう(2013.10.07)
                getHachuNumber(new queryHachuNo());
            };
            /// <summary>PDFファイル出力を行います。</summary>
            var printPdf = function () {

                //var query = {
                //    url: "../api/NonyuIraishoListPDF"
                //    //filter: createFilter(),
                //    //orderby: "cd_hinmei"
                //}

                // PDF出力用URLを取得
                var url = getPdfUrl();

                // PDF出力処理
                window.open(url, '_parent');

                //App.ajax.webget(
                //url
                //window.open(url, '_parent')
                //).done(function (result) {
                //alert("done");
                // 発注番号の再採番
                //getHachuNumber(new queryHachuNo());
                //}).fail(function (result) {
                //alert("fail");
                //getHachuNumber(new queryHachuNo());
                //}).always(function () {
                //  alert("always");
                //App.ui.loading.close();
                //});
            };
            // 引数のパラメーターを設定したPDF出力用URLを取得
            var getPdfUrl = function () {
                // 必要な情報を取得
                var container = $(".search-criteria").toJSON(),
                    str = "",
                    colMaximums = getColMaximums();

                //var url = App.data.toODataFormat(query),
                //var url = App.data.toWebAPIFormat(query),
                var query = {
                    url: "../api/NonyuIraishoListPDF",
                    "lang": App.ui.page.lang,
                    "langCountry": App.ui.page.langCountry,
                    "uuid": App.uuid(),
                    "printType": printType,
                    "yotei": yotei,
                    "bunrui": encodeURIComponent(bunrui),
                    "niukeCode": cd_niuke,
                    "hachuNo": encodeURIComponent(headerContent.hachuNo),
                    "dateFrom": creDateFrom,
                    "dateTo": creDateTo,
                    "cdLoginKaisha": App.ui.page.user.KaishaCode,
                    "cdLoginKojo": App.ui.page.user.BranchCode,
                    "renrakusaki": encodeURIComponent(headerContent.renrakusaki),
                    "renTel": encodeURIComponent(headerContent.renrakusakiTel),
                    "renFax": encodeURIComponent(headerContent.renrakusakiFax),
                    "nohinsaki": encodeURIComponent(headerContent.nohinsaki),
                    "nohinsakiAdd": encodeURIComponent(headerContent.nohinsakiAdd),
                    "torihikisaki": encodeURIComponent(container.torihikisaki),
                    "kbnKeishiki": container.torihiki_tani,
                    "comment": encodeURIComponent(comment),
                    "kaishaName": encodeURIComponent(headerContent.kaishaName),
                    "sysdate": App.data.getDateTimeStringForQueryNoUtc(systemDate),
                    "hinCode": printHinCd,
                    "torihikiCode": printTorihikiCd,
                    "maxPages": pageLangText.pageMaximums.text,
                    "maxColumn": colMaximums, // ★TODO
                    "local_today": App.data.getDateTimeStringForQuery(new Date(), true)
                };

                // URLにパラメータを設定
                //for (var key in param) {
                //    str += ("&" + key + "=" + param[key]);
                //}
                url = App.data.toWebAPIFormat(query);

                return url;
            };
            /// <summary>PDFの出力件数(ページ数)のチェック</summary>
            /// <param name="query">クエリオブジェクト</param>
            var checkPageCount = function () {
                // 情報メッセージのクリア
                App.ui.page.notifyInfo.clear();
                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();

                // ローディング開始
                App.ui.loading.show(pageLangText.nowProgressing.text);

                var container = $(".search-criteria").toJSON(),
                    colMaximums = getColMaximums();

                var query = {
                    url: "../api/NonyuIraishoListPDFCount",
                    printType: printType,
                    yotei: yotei,
                    bunrui: bunrui,
                    niukeCode: cd_niuke,
                    dateFrom: creDateFrom,
                    dateTo: creDateTo,
                    torihikisaki: container.torihikisaki,
                    sysdate: App.data.getDateTimeStringForQueryNoUtc(systemDate),
                    hinCode: printHinCd,
                    torihikiCode: printTorihikiCd,
                    maxPages: pageLangText.pageMaximums.text,
                    maxColumn: colMaximums
                    //top: 1
                }

                App.ajax.webget(
                    App.data.toWebAPIFormat(query)
                ).done(function (result) {
                    App.ui.loading.close(); // ローディング終了
                    // ページがチェック数を超えていた場合、確認DLGを表示する
                    var cautionPages = parseInt(pageLangText.pageCautions.text);
                    var maxPages = parseInt(pageLangText.pageMaximums.text);
                    if (result > cautionPages) {
                        if (result > maxPages) {
                            // 上限数を超えていた場合、出力しない
                            App.ui.page.notifyAlert.message(
                                App.str.format(pageLangText.pageMaximumsOver.text, maxPages)
                            ).show();
                        }
                        else {
                            showPageMaximConfirmDialog();
                        }
                    }
                    else {
                        // 出力処理へ
                        downloadOverlay();
                    }
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                }).always(function () {
                    // ローディング終了
                    App.ui.loading.close();
                });
            };
            /// <summary>選択された出力種別から、1ページに出力する最大列数を取得します。</summary>
            var getColMaximums = function () {
                var resultColMaximums = pageLangText.pdfColMaximums5.text, // 初期値横・5ページ
                    selectVal = $("input:radio[name='select_layout']:checked").val();

                // 選択値が増えても修正しやすいよう、switchで処理します
                switch (selectVal) {
                    case "2":
                        // 縦の場合は2ページ
                        resultColMaximums = pageLangText.pdfColMaximums2.text;
                        break;
                    //case "":     
                    //    // XXXの場合はnページ     
                    //    resultColMaximums = "";     
                    //    break;     
                }

                return resultColMaximums;
            };
            /// <summary>印刷ボタンクリック時のイベント処理を行います。</summary>
            $(".pdf-button").on("click", function () {
                // 出力処理へ
                printType = pageLangText.systemValueZero.text;
                // チェック処理
                checkPageCount();
            });
            /// <summary>全印刷ボタンクリック時のイベント処理を行います。</summary>
            $(".pdf-button-all").on("click", function () {
                // 出力処理へ
                printType = pageLangText.systemValueTwo.text;

                // 検索条件の取引先コードをすべて取得する
                //var torihiki = torihikisaki;
                var torihiki = $("#condition-torihikisaki").children();
                var code;
                if (torihiki.length > 1) {
                    code = torihiki[0].value;
                    for (var i = 1; i < torihiki.length; i++) {
                        code += ("," + torihiki[i].value);
                    }
                }
                else {
                    code = torihiki[0].value;
                }
                printTorihikiCd = code;

                // チェック処理
                checkPageCount();
            });

            /// <summary>メニューボタンクリック時のイベント処理を行います。</summary>
            var backToMenu = function () {
                // IEバグによる例外発生をキャッチします。例外発生時は何もしません。
                try {
                    document.location = pageLangText.menuPath.url;
                }
                catch (e) {
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

    <!-- 画面ヘッダー -->
    <div class="content-part header-content">
        <div class="part-body">
            <div class="item-list">
                <ul>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="hachuNo" style="width: 100px"></span>
                            <span class="item-label" name="hachuNo" style="width: 450px"></span>
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="renrakusaki" style="width: 100px"></span>
                            <span class="item-label" name="renrakusaki" style="width: 450px"></span>
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" style="width: 100px;"></span>
                            <span class="item-label" data-app-text="renrakusaki_tel" style="width: 40px"></span>
                            <span class="item-label" name="renrakusaki_tel" style="width: 180px"></span>
                            <span class="item-label" data-app-text="renrakusaki_fax" style="width: 40px"></span>
                            <span class="item-label" name="renrakusaki_fax" style="width: 180px"></span>
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="nohinsaki" style="width: 100px"></span>
                            <span class="item-label" name="nohinsaki" style="width: 450px"></span>
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" style="width: 100px;"></span>
                            <span class="item-label" name="nohinsaki_add" style="width: 450px"></span>
                        </label>
                    </li>
                    <li>
                        <!-- レイアウト用の空欄 -->
                        <label>
                            <span class="item-label" style="width: 50px">&nbsp;</span>
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="print_layout" style="width: 100px;"></span>
                        </label>
                        <!-- 印刷レイアウト選択：横（デフォルト） -->
                        <label>
                            <input type="radio" name="select_layout" id="select_yoko" value="1" checked="checked" /><span class="item-label" style="width: 100px" data-app-text="layout_yoko"></span>
                        </label>
                        <!-- 印刷レイアウト選択：縦 -->
                        <label>
                            <input type="radio" name="select_layout" id="select_tate" value="2" /><span class="item-label" style="width: 100px" data-app-text="layout_tate"></span>
                        </label>
                    </li>
                </ul>
            </div>
        </div>
    </div>

    <!-- 検索条件と検索ボタン -->
    <div class="content-part search-criteria">
        <h3 class="part-header" data-app-text="searchCriteria"><a class="search-part-toggle" href="#"></a></h3>
        <div class="part-body">
            <ul class="item-list">
                <!-- TODO: 画面の仕様に応じて以下の検索条件を変更してください。-->
                <li>
                    <label>
                        <span class="item-label" data-app-text="dt_sakusei_kaishi"></span>
                        <span class="item-label" name="dt_sakusei_kaishi" id="condition-date" style="width: 160px"></span>
                    </label>
                </li>
                <li>
                    <label>
                        <span class="item-label" data-app-text="nm_torihiki"></span>
                        <select name="torihikisaki" id="condition-torihikisaki" style="width: 400px">
                        </select>
                        <span class="item-label" name="torihiki_tani" data-app-text="torihiki_tani"></span>
                    </label>
                </li>
                <!-- TODO: ここまで -->
            </ul>
        </div>
        <div class="part-footer">
            <div class="command">
                <button type="button" class="find-button" name="find-button" data-app-operation="search">
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
            <span data-app-text="resultList" style="padding-right: 10px;"></span>
            <span class="list-count" id="list-count" ></span>
            <span style="padding-left: 50px;" class="list-loading-message" id="list-loading-message"></span>
        </h3>
        <div class="part-body" id="result-grid">
            <div class="item-command" style="left: 17px; right: 17px;">&nbsp;</div>
            <table id="item-grid" data-app-operation="itemGrid">
            </table>
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
        <button type="button" class="pdf-button" name="pdf-button" data-app-operation="pdf">
            <!--<span class="icon"></span>-->
            <span data-app-text="print"></span>
        </button>
        <button type="button" class="pdf-button-all" name="pdf-button-all" data-app-operation="pdfAll">
            <!--<span class="icon"></span>-->
            <span data-app-text="allPrint"></span>
        </button>
    </div>
    <div class="command" style="right: 9px;">
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
    <!-- ダイアログ固有のデザイン -- Start -->

    <!-- TODO: 画面の仕様に応じて以下のダイアログの設定を変更してください。 -->
    <div class="pagemaxim-confirm-dialog" style="display: none;">
        <div class="dialog-header">
            <h4 data-app-text="confirmTitle"></h4>
        </div>
        <div class="dialog-body" style="padding: 10px; width: 100%;">
            <div class="part-body">
                <span data-app-text="pageCautionsOverConfirm"></span>
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
    <!-- TODO: ここまで  -->

    <!-- 画面デザイン -- End -->
</asp:Content>
