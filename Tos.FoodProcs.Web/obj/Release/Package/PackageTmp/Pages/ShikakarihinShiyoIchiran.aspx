<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="ShikakarihinShiyoIchiran.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.ShikakarihinShiyoIchiran" %>

<asp:Content ID="Content1" ContentPlaceHolderID="IncludeContent" runat="server">
    <script src="<%=ResolveUrl("~/Resources/pages/pagedata-shikakarihinshiyoichiran." + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
    <script src="<%=ResolveUrl("~/Resources/grid/grid.locale-" + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        /* 画面デザイン -- Start */
        
        /* TODO：画面の仕様に応じて以下のスタイルを変更してください。 */
        .search-criteria .conditionname-label
        {
            width: 15em;
        }

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
                isDataLoading = false,
                isSearch = false, // 検索フラグ
                isCriteriaChange = false,   // 検索条件変更フラグ
                searchCondition;

            // グリッドコントロール固有の変数宣言
            var grid = $("#item-grid"),
                lastScrollTop = 0,
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
                changeSet = new App.ui.page.changeSet(),
                firstCol = 3,
                duplicateCol = 999,
                currentRow = 0,
                currentCol = firstCol;
            // TODO: ここまで
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            var masterKubun,
                haigoCode;
            var hinmeiName = 'nm_hinmei_' + App.ui.page.lang,
                haigoName = 'nm_haigo_' + App.ui.page.lang;
            // TODO：ここまで
            // ダイアログ固有の変数宣言
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            var hinmeiDialog = $(".hinmei-dialog");
            // TODO：ここまで

            // urlよりパラメーターを取得
            var getParameters = function () {
                var parameters = {},
                    keyValue,
                    parameterStartPos = window.location.href.indexOf('?') + 1,
                    queryStrings;

                queryStrings = window.location.href.slice(parameterStartPos).split('&');

                if (!App.isUnusable(queryStrings)) {
                    for (var i = 0; i < queryStrings.length; i++) {
                        keyValue = queryStrings[i].split('=');
                        parameters[keyValue[0]] = keyValue[1];
                    }
                }
                return parameters;
            };

            //// 変数宣言 -- End

            //// コントロール定義 -- Start

            // ダイアログ固有のコントロール定義
            //searchConfirmDialog.dlg();

            hinmeiDialog.dlg({
                url: "Dialog/HinmeiDialog.aspx",
                name: "HinmeiDialog",
                closed: function (e, data, data2) {
                    if (data == "canceled") {
                        return;
                    }
                    else {
                        $("#shikakariCode").val(data);
                        $("#shikakariName").text(data2);
                    }
                }
            });

            // 日付の多言語対応
            var datePickerFormat = pageLangText.dateFormatUS.text;
            var newDateFormat = pageLangText.dateNewFormatUS.text;
            if (App.ui.page.langCountry !== 'en-US') {
                datePickerFormat = pageLangText.dateFormat.text;
                newDateFormat = pageLangText.dateNewFormat.text;
            }
            // TODO：画面の仕様に応じて以下の datepicker の設定を変更してください。
            $(".search-criteria [name='dt_shikomi_search']").on("keyup", App.data.addSlashForDateString);
            //$(".search-criteria [name='dt_shikomi_search']").detepicker = App.date.startOfDay(new Date());
            $(".search-criteria [name='dt_shikomi_search']").datepicker({
                dateFormat: datePickerFormat,
                minDate: new Date(1975, 1 - 1, 1),
                maxDate: "+1y"
            });
            $(".search-criteria [name='dt_shikomi_search']").datepicker("setDate", new Date());

            // グリッドコントロール固有のコントロール定義
            var selectCol;
            grid.jqGrid({
                // TODO：画面の仕様に応じて以下の列名の定義を変更してください。
                colNames: [
                    pageLangText.flg_keikaku.text,
                    pageLangText.dt_shikomi.text,
                    pageLangText.nm_shokuba_shikomi.text,
                    pageLangText.nm_line_shikomi.text,
                    pageLangText.wt_shikomi_keikaku.text,
                    pageLangText.no_lot_shikakari.text,
                    pageLangText.flg_label.text,
                    pageLangText.flg_label_hasu.text,
                    pageLangText.dt_seihin_seizo.text,
                    pageLangText.nm_shokuba_seizo.text,
                    pageLangText.nm_line_seizo.text,
                    pageLangText.cd_hinmei.text,
                    pageLangText.nm_hinmei.text,
                    pageLangText.su_seizo_yotei.text,
                    pageLangText.no_lot_seihin.text,
                    pageLangText.cd_shikakari_hin.text,
                    pageLangText.nm_haigo.text,
                    pageLangText.no_lot_shikakari_oya.text
                ],
                // TODO：ここまで
                // TODO：画面の仕様に応じて以下の列モデルの定義を変更してください。
                colModel: [
                    { name: 'flg_keikaku', width: 50, editable: false, hidden: false, edittype: 'checkbox',
                        editoptions: { value: "1:0" }, formatter: 'checkbox', formatoptions: { disabled: true }, align: 'center'
                    },
                    { name: 'dt_shikomi', width: 100, hidedlg: true,
                        formatter: "date",
                        formatoptions: {
                            srcformat: newDateFormat, newformat: newDateFormat
                        }
                    },
                    { name: 'nm_shokuba_shikomi', width: 210 },
                    { name: 'nm_line_shikomi', width: 195 },
                    { name: 'wt_shikomi_keikaku',
                        width: 200, editable: false, formatter: 'number',
                        formatoptions: { decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 6 },
                        sortable: false, sorttype: 'float', align: 'right'
                    },
                    { name: 'no_lot_shikakari', width: 120 },
                    { name: 'flg_label', width: 110, editable: false, hidden: false, edittype: 'checkbox',
                        editoptions: { value: "1:0" }, formatter: 'checkbox', formatoptions: { disabled: true }, align: 'center'
                    },
                    { name: 'flg_label_hasu', width: 120, editable: false, hidden: false, edittype: 'checkbox',
                        editoptions: { value: "1:0" }, formatter: 'checkbox', formatoptions: { disabled: true }, align: 'center'
                    },
                    { name: 'dt_seihin_seizo', width: 100, hidedlg: true,
                        formatter: "date",
                        formatoptions: {
                            srcformat: newDateFormat, newformat: newDateFormat
                        }
                    },
                    { name: 'nm_shokuba_seizo', width: 200 },
                    { name: 'nm_line_seizo', width: 150 },
                    { name: 'cd_hinmei', width: 90 },
                    { name: hinmeiName, width: 200 },
                    { name: 'su_seizo_yotei',
                        width: 120, editable: false, formatter: 'number',
                        formatoptions: { thousandsSeparator: ",", decimalPlaces: 0 },
                        sortable: false, sorttype: 'float', align: 'right'
                    },
                    { name: 'no_lot_seihin', width: 120 },
                    { name: 'cd_shikakari_hin', width: 160 },
                    { name: haigoName, width: 120 },
                    { name: 'no_lot_shikakari_oya', width: 120 }
                ],
                // TODO：ここまで
                datatype: "local",
                shrinkToFit: false,
                multiselect: false,
                rownumbers: true,
                cellEdit: true,
                cellsubmit: 'clientArray',
                onCellSelect: function (rowid, icol, cellcontent) {
                    selectCol = icol;
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
            $(".colchange-button").on("click", function (e) {
                showColumnSettingDialog(e);
            });

            //// コントロール定義 -- End

            //// 操作制御定義 -- Start

            // 操作制御定義を定義します。
            App.ui.pagedata.operation.applySetting(App.ui.page.user.Roles[0], App.ui.page.lang);

            //// 操作制御定義 -- End


            //// 検索処理 -- Start

            // 画面アーキテクチャ共通の検索処理

            /// <summary>クエリオブジェクトの設定</summary>
            var query = function () {
                var criteria = $(".search-criteria").toJSON();
                var query = {
                    // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                    url: "../api/ShikakarihinShiyoIchiran"
                    , dt_shikomi_search: App.data.getDateTimeStringForQueryNoUtc(criteria.dt_shikomi_search)
                    , shikakariCode: criteria.shikakariCode
                    , no_han: pageLangText.hanNoShokichi.text
                    , skip: querySetting.skip
                    , top: querySetting.top
                    , isExcel: false
                };
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
                        pageLangText.nowListLoading.text,
                        querySetting.skip + 1,
                        querySetting.top
                    )
                );
                App.ajax.webget(
                // WCF Data ServicesのODataシステムクエリオプションを生成
                    App.data.toWebAPIFormat(query)
                ).done(function (result) {
                    // 検索フラグを立てる
                    isSearch = true;
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
                    querySetting.top = 40;
                    // 検索条件を閉じる
                    closeCriteria();
                    isCriteriaChange = false;
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
            var findData = function () {
                //closeSearchConfirmDialog();
                querySetting.top = 500;
                clearState();
                // 検索前バリデーション
                var result = $(".part-body .item-list").validation().validate();
                if (result.errors.length) {
                    return;
                }
                searchItems(new query());
            };
            /// <summary>検索ボタンクリック時のイベント処理を行います。</summary>
            $(".find-button").on("click", findData);

            /// <summary>検索条件表示用コード名の検索を行います。</summary>
            /// <param name="masterKubun">クエリオブジェクト</param>
            /// <param name="code">クエリオブジェクト</param>
            var getCodeName = function (code) {
                App.ui.page.notifyAlert.clear();
                var serviceUrl,
                    elementCode,
                    elementName,
                    codeName;
                serviceUrl = "../Services/FoodProcsService.svc/ma_haigo_mei()?$filter=cd_haigo eq '"
                    + code + "' and no_han eq " + pageLangText.hanNoShokichi.text + "&$top=1";
                elementCode = "cd_haigo";
                elementName = "nm_haigo_" + App.ui.page.lang;
                App.deferred.parallel({
                    // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                    codeName: App.ajax.webget(serviceUrl)
                    // TODO: ここまで
                }).done(function (result) {
                    // TODO: 画面の仕様に応じて以下のサービス呼び出し成功時の処理を変更してください。
                    codeName = result.successes.codeName.d;
                    if (codeName.length > 0) {
                        $("#shikakariName").text(codeName[0][elementName]);
                    }
                    else {
                        if ($(".search-criteria").toJSON().shikakariCode) {
                        }
                        $("#shikakariName").text("");
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
                });
            };

            /// <summary>存在チェック</summary>
            /// <param name="colName">カラム物理名</param>
            /// <param name="code">コード値</param>
            var isValidCode = function (name, code) {
                var isValid = true;
                var serviceUrl;
                serviceUrl = "../Services/FoodProcsService.svc/ma_haigo_mei()?$filter=cd_haigo eq '" + code
                    + "' and no_han eq " + pageLangText.hanNoShokichi.text + "&$top=1";
                App.ajax.webgetSync(serviceUrl
                ).done(function (result) {
                    if (result.d.length === 0) {
                        isValid = false;
                    }
                    else {
                        isValid = true;
                    }
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                });
                return isValid;
            };
            /// <summary>検索条件変更時のイベント処理を行います。</summary>
            $("#shikakariCode").on("change", function () {
                var criteria = $(".search-criteria").toJSON();
                getCodeName(criteria.shikakariCode);
            });
            validationSetting.shikakariCode.rules.custom = function (value) {
                return isValidCode("shikakariCode", value);
            };
            // 検索条件に変更が発生した場合
            $(".search-criteria").on("change", function () {
                // 検索後の状態で検索条件が変更された場合
                if (isSearch) {
                    isCriteriaChange = true;
                }
            });

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
                isCriteriaChange = false;
                isSearch = false;

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
                     App.str.format("{0}/{1} " + pageLangText.itemCount.text, querySetting.skip, querySetting.count)
                );
            };
            /// <summary>データをバインドします。</summary>
            /// <param name="result">検索結果</param>
            var bindData = function (result) {
                querySetting.skip = querySetting.skip + result.d.length;
                querySetting.count = parseInt(result.__count);
                // グリッドの表示件数を更新
                grid.setGridParam({ rowNum: querySetting.skip });
                displayCount();
                // データバインド
                var currentData = grid.getGridParam("data").concat(result.d);
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

            //// メッセージ表示 -- End

            // グリッドコントロール固有の保存処理
            // <summary>データに変更がないかどうかを返します。</summary>
            var noChange = function () {
                return (App.isUnusable(changeSet) || changeSet.noChange());
            };

            //// バリデーション -- Start

            // TODO: 画面の仕様に応じて以下のカスタムバリデーション定義を変更してください。
            // グリッドのバリデーション設定
            var v = Aw.validation({
                items: validationSetting
            });
            //// バリデーション -- End

            /// 品名ダイアログを開く
            var showHinmeiDialog = function () {
                var criteria = $(".search-criteria").toJSON();
                openHinmeiDialog("hinmei", hinmeiDialog);
            };

            /// 品名ダイアログを起動する
            var openHinmeiDialog = function (dlgName, dialog) {
                var option;
                option = { id: dlgName, multiselect: false, param1: pageLangText.shikakariHinDlgParam.text };
                dialog.draggable(true);
                dialog.dlg("open", option);
            };

            /// <summary> レコード件数チェック </summary>
            var checkRecordCount = function () {
                recordCount = grid.getGridParam("records");
                // レコードがない場合は処理を抜ける
                if (recordCount == 0) {
                    App.ui.page.notifyInfo.message(pageLangText.noRecords.text).show();
                    return false;
                }
                return true;
            };
            /// <summary> ダイアログの起動可否のチェック </summary>
            var checkShowDialog = function (rowid) {
                // 各種フラグによるチェック
                if (!App.isUndefOrNull(grid.getCell(rowid, "ts")) && grid.getCell(rowid, "ts") != "") {
                    return false;
                }
                return true;
            }

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
                    // F3の処理
                    processed = true;
                }
                // TODO: ここまで
                if (processed) {
                    //何か処理を行なっていた場合、ブラウザ既定の動作を無効にする
                    e.preventDefault();
                }
            };

            /// <summary>検索条件仕掛品一覧ボタンクリック時のイベント処理を行います。</summary>
            $("#shikakariSearch").on("click", function (e) {
                // 品名セレクタ起動
                showHinmeiDialog();
            });

            /// <summary>検索条件仕掛品コードダブルクリック時のイベント処理を行います。</summary>
            $("#shikakariCode").dblclick(function () {
                // 品名セレクタ起動
                showHinmeiDialog();
            });

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
                    resultPartStyle = resultPart[0].currentStyle || document.defaultView.getComputedStyle(resultPart[0], "");

                resultPart.height(container[0].clientHeight - searchPart[0].clientHeight - ((parseInt(resultPartStyle.marginTop, 10) * 3) || 0));
                grid.setGridWidth(resultPart[0].clientWidth - 5);
                //結果一覧のパートの高さ - パートのヘッダーの高さ - パート内のボタンのコマンドの高さ - jqGrid のカラムヘッダーの高さ
                grid.setGridHeight(resultPart[0].clientHeight - resultPartHeader[0].clientHeight - resultPartCommands[0].clientHeight - resultPart.find(".ui-jqgrid-hdiv")[0].clientHeight - 35);
            };
            /// <summary>画面リサイズ時のイベント処理を行います。</summary>
            $(App.ui.page).on("resized", resizeContents);

            // <summary>前ページよりパラメータを取得し、条件によって初期表示時に検索を行います。</summary>
            // TODO: 画面の仕様に応じて以下の値を変更します。
            var paramHaigoCode = '<%= Page.Request.QueryString.Get("cdHaigo") %>';
            $("#shikakariCode").val(paramHaigoCode);
            var criteria = $(".search-criteria").toJSON();
            getCodeName(criteria.shikakariCode);

            /// <summary>Excelファイル出力を行います。</summary>
            var printExcel = function (e) {
                var criteria = $(".search-criteria").toJSON();
                var query = {
                    url: "../api/ShikakarihinShiyoIchiranExcel",
                    dt_shikomi_search: App.data.getDateTimeStringForQueryNoUtc(criteria.dt_shikomi_search),
                    shikakariCode: criteria.shikakariCode,
                    shikakariName: encodeURIComponent($("#shikakariName").text()),
                    no_han: pageLangText.hanNoShokichi.text,
                    skip: querySetting.skip,
                    top: querySetting.top
                };

                // 必要な情報を渡します
                var url = App.data.toWebAPIFormat(query)
                url = url + "&lang=" + App.ui.page.lang
                          + "&UTC=" + new Date().getTimezoneOffset() / 60
                          + "&userName=" + encodeURIComponent(App.ui.page.user.Name);
                window.open(url, '_parent');
            };

            /// <summary>ダウンロードボタンクリック時のチェック処理</summary>
            var prePrintExcel = function () {
                App.ui.page.notifyInfo.clear();
                App.ui.page.notifyAlert.clear();
                // 明細があるかどうかをチェックし、無い場合は処理を中止します。
                if (querySetting.count == 0) {
                    App.ui.page.notifyInfo.message(pageLangText.noRecords.text).show();
                    return;
                }
                // 検索条件の変更をチェック
                if (isCriteriaChange) {
                    App.ui.page.notifyAlert.message(
                         App.str.format(pageLangText.criteriaChange.text, pageLangText.searchCriteria.text, pageLangText.output.text)
                    ).show();
                    return;
                }
                printExcel();
            };

            /// <summary>Excelボタンクリック時のイベント処理を行います。</summary>
            $(".excel-button").on("click", prePrintExcel);

            /// <summary>データに変更があり、未保存の状態でページを離れる際に確認を行います。</summary>
            //別画面に遷移したりするときに実行する関数の定義
            var onBeforeUnload = function () {
                if (!noChange()) {
                    return pageLangText.unloadWithoutSave.text;
                }
            };
            $(window).on('beforeunload', onBeforeUnload);   //beforeunloadイベントに関数を割り当て
            //formをsubmit（ログオフ）する場合、beforeunloadイベントを発生させないようにする
            $('form').on('submit', function () {
                $(window).off('beforeunload');
            });
            $("#loginButton").attr('onclick', '');  //クリック時の記述を削除
            $("#loginButton").on('click', function () {
                $(window).off('beforeunload');  //ログオフボタンをクリックしたときはbeforunloadイベントを発生させない
                if (!noChange()) {
                    var ans = confirm(pageLangText.unloadWithoutSave.text);
                    if (ans == false) {
                        $(window).on('beforeunload', onBeforeUnload);   //イベントを外したままだと、他のボタンで機能しないので、再設定
                        return false;
                    }
                }
                __doPostBack('ctl00$loginButton', '');
            });

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

    <!-- 検索条件と検索ボタン -->
    <div class="content-part search-criteria">
        <h3 class="part-header" data-app-text="searchCriteria"><a class="search-part-toggle" href="#"></a></h3>
        <div class="part-body">
            <ul class="item-list">
                <!-- TODO: 画面の仕様に応じて以下の検索条件を変更してください。-->
                <li>
                    <label>
                        <span class="item-label" data-app-text="dt_shikomi_search" data-tooltip-text="dt_shikomi_search"></span>
                        <input type="text" name="dt_shikomi_search" id="dt_shikomi_search" maxlength="10" />
                    </label>
                </li>
                <li>
                    <label>
                        <span class="item-label" data-app-text="shikakariCode"></span>
                        <input type="text" name="shikakariCode" id="shikakariCode" maxlength="14" />
                    </label>
                    <button type="button" class="dialog-button" id="shikakariSearch" >
                        <span class="icon"></span><span data-app-text="shikakariSearch"></span>
                    </button>
                </li>
                <li>
                    <label>
                        <span class="item-label" data-app-text="shikakariName"></span>
                        <span class="shikakariName" id="shikakariName"></span>
                    </label>
                </li>
                <!-- TODO: ここまで -->
            </ul>
        </div>
        <div class="part-footer">
            <div class="command">
                <button type="button" class="find-button" name="find-button">
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
            <span data-app-text="resultList" style="padding-right: 10px;"></span>
            <span class="list-count" id="list-count" ></span>
            <span style="padding-left: 50px;" class="list-loading-message" id="list-loading-message" ></span>
        </h3>
        <div class="part-body" id="result-grid">
            <div class="item-command">
                <button type="button" class="colchange-button"><span class="icon"></span><span data-app-text="colchange"></span></button>
            </div>
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
        <button type="button" class="excel-button" name="excel-button" data-app-operation="excel">
            <span class="icon"></span>
            <span data-app-text="excel"></span>
        </button>
        <!-- TODO: ここまで -->
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
    <!--
    <div class="search-confirm-dialog" style="display: none;">
        <div class="dialog-header">
            <h4 data-app-text="confirmTitle"></h4>
        </div>
        <div class="dialog-body" style="padding: 10px; width: 100%;">
            <div class="part-body">
                <span data-app-text="searchConfirm"></span>
            </div>
        </div>
    </div>
    -->
    <div class="hinmei-dialog">
    </div>
    <!-- TODO: ここまで  -->

    <!-- 画面デザイン -- End -->
</asp:Content>
