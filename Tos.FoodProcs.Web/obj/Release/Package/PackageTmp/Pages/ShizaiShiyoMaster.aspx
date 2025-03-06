<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="ShizaiShiyoMaster.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.ShizaiShiyoMaster" %>

<asp:Content ID="Content1" ContentPlaceHolderID="IncludeContent" runat="server">
    <script src="<%=ResolveUrl("~/Resources/pages/pagedata-shizaishiyomaster." + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
    <script src="<%=ResolveUrl("~/Resources/grid/grid.locale-" + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        /* 画面デザイン -- Start */
        
        /* TODO：画面の仕様に応じて以下のスタイルを変更してください。 */
        .not-editable-cell
        {
        }
        
        .search-criteria .conditionname-label
        {
            width: 15em;
        }

        button.hinmei-button
        {
            width: 110px;
        }

        button.line-button
        {
            width: 110px;
        }
		
		button.hinmei-button .icon
		{
			background-position: -48px -80px;
		}
		
		button.line-button .icon
		{
			background-position: -48px -80px;
		}
        
        .search-criteria .item-label {
            width: 10em;
        }

        .search-criteria .nm_han_label {
            width: 5em;
        }

        .search-criteria .no_han_select {
            width: 5em;
        }

        /* 背景色 */
        .mishiyo-shizai TD {
            background-color:grey;
        }

        .part-header {
            line-height: 30px!important;
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
                validationSetting2 = App.ui.pagedata.validation2(App.ui.page.lang),
                querySetting = { skip: 0, top: pageLangText.topCount.text, count: 0 },
                isDataLoading = false,
                isSearch = false, // 検索フラグ
                isCriteriaChange = false, // 検索条件変更フラグ
                isCreated = false, // 新規版フラグ
                isDelShizai = false, // 資材削除フラグ
                userRoles = App.ui.page.user.Roles[0], // ログインユーザー権限
                shinkiHanNo = 0;
                isClickSave = false;
                isClickSearch = false;

            var confFlg = false;
            // グリッドコントロール固有の変数宣言
            var grid = $("#item-grid"),
                lastScrollTop = 0,
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
                changeSetFirst = new App.ui.page.changeSet(),
                changeSetSecond = new App.ui.page.changeSet(),
            // コピーデータ要
                changeSetThird = new App.ui.page.changeSet(),
                firstCol = 3,
                shizaiCodeCol = 1,
                shizaiNameCol = 2,
                duplicateCol = 999,
                currentRow = 0,
                currentCol = firstCol;
            // TODO: ここまで

            var preClass;
            var preSelectedRow;

            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            var han,
                nisugata,
            // 多言語対応にしたい項目を変数にする
                hinName = "nm_hinmei_" + App.ui.page.lang;
            // TODO：ここまで

            // ダイアログ固有の変数宣言
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            var saveConfirmDialog = $(".save-confirm-dialog"),
                deleteConfirmDialog = $(".delete-confirm-dialog"),
                findConfirmDialog = $(".find-confirm-dialog"),
                hinmeiDialog = $(".hinmei-dialog"),
                shizaiDialog = $(".shizai-dialog");
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
            // urlよりパラメーターを取得
            var parameters = getParameters();
            // ヘッダー情報を変数に格納
            var hinmeiCode = App.ifUndefOrNull(parameters["cd_hinmei"], "");

            // ユーザー権限による操作制御定義を定義します。
            App.ui.pagedata.operation.applySetting(App.ui.page.user.Roles[0], App.ui.page.lang);
            $(function () {
                if (userRoles == pageLangText.viewer.text) {
                    $("#shinkiHan-button").css("display", "none");
                    $(".add-button").css("display", "none");
                    $(".delete-button").css("display", "none");
                    $("#shizai-button").css("display", "none");
                    $(".save-button").css("display", "none");
                    $(".delete_shizai-button").css("display", "none");
                }
            });

            // <summary>現在日時を取得</summary>
            var getDate = function () {
                // >>> 2014.02.21 中村 日付形式の言語対応のため、処理を差し替えました。

                // TODO : 確認次第、このコメントと不要な処理の削除をお願いいたします。
                //                var date = new Date();
                //                return [date.getFullYear(),
                //                        ('0' + (date.getMonth() + 1)).slice(-2),
                //                        ('0' + date.getDate()).slice(-2)]
                //                        .join('/') + " 00:00:00";
                return App.data.getDateString(new Date(), true) + " 00:00:00";

                // <<<
            };

            //// 変数宣言 -- End

            //// コントロール定義 -- Start

            // ダイアログ固有のコントロール定義
            saveConfirmDialog.dlg();
            deleteConfirmDialog.dlg();
            findConfirmDialog.dlg();

            // 品名ダイアログ定義
            hinmeiDialog.dlg({
                url: "Dialog/HinmeiDialog.aspx",
                name: "HinmeiDialog",
                closed: function (e, data, data2) {
                    // エラーメッセージのクリア
                    App.ui.page.notifyAlert.clear();
                    $(".shizai-dialog 0 all").remove();
                    if (data == "canceled") {
                        return;
                    }
                    else {
                        $("#id_cd_hinmei").val(data);
                        $("#nm_hinmei").text(data2);

                        // 品名コード変更処理
                        loading(pageLangText.nowProgressing.text, "cd_hinmei");
                    }
                }
            });
            // 資材ダイアログ定義
            shizaiDialog.dlg({
                url: "Dialog/HinmeiDialog.aspx",
                name: "HinmeiDialog",
                closed: function (e, data, data2) {
                    // エラーメッセージのクリア
                    App.ui.page.notifyAlert.clear();
                    $(".shizai-dialog 0 all").remove();
                    if (data == "canceled") {
                        return;
                    }
                    else {
                        var selectedRowId = getSelectedRowId(false);
                        grid.setCell(selectedRowId, "cd_shizai", data);
                        grid.setCell(selectedRowId, hinName, data2);

                        // 更新状態の変更セットに変更データを追加
                        var changeData = setCreatedChangeDataFirst(grid.getRowData(selectedRowId));
                        changeSetFirst.addUpdated(selectedRowId, "cd_shizai", data, changeData);
                        // データチェック
                        validateCell(selectedRowId, "cd_shizai", data, grid.getColumnIndexByName("cd_shizai"));
                        setRelatedValue(getSelectedRowId(false), "cd_shizai", data, grid.getColumnIndexByName("cd_shizai"));
                    }
                }
            });

            /// <summary>ダイアログを開きます。</summary>
            var showSaveConfirmDialog = function () {
                saveConfirmDialogNotifyInfo.clear();
                saveConfirmDialogNotifyAlert.clear();
                saveConfirmDialog.draggable(true);
                saveConfirmDialog.dlg("open");
            };
            var showDeleteConfirmDialog = function () {
                deleteConfirmDialogNotifyInfo.clear();
                deleteConfirmDialogNotifyAlert.clear();
                deleteConfirmDialog.draggable(true);
                deleteConfirmDialog.dlg("open");
            };
            /// <summary> 検索確認ダイアログを開きます。 </summary>
            var showFindConfirmDialog = function () {
                findConfirmDialogNotifyInfo.clear();
                findConfirmDialogNotifyAlert.clear();
                findConfirmDialog.draggable(true);
                findConfirmDialog.dlg("open");
            };
            /// <summary>ダイアログを閉じます。</summary>
            var closeSaveConfirmDialog = function () {
                saveConfirmDialog.dlg("close");
            };
            var closeDeleteConfirmDialog = function () {
                deleteConfirmDialog.dlg("close");
            };
            /// <summary> 検索確認ダイアログを閉じます。 </summary>
            var closeFindConfirmDialog = function () {
                findConfirmDialog.dlg("close");
            };

            // グリッドコントロール固有のコントロール定義
            var selectCol;
            grid.jqGrid({
                // TODO：画面の仕様に応じて以下の列名の定義を変更してください。
                colNames: [
                    pageLangText.cd_shizai.text + pageLangText.requiredMark.text
                    , pageLangText.nm_shizai.text
                    , pageLangText.nm_nisugata_hyoji.text
                    , pageLangText.nm_tani_shiyo.text
                    , pageLangText.su_shiyo.text + pageLangText.requiredMark.text
                    , ""
                    , ""
                    , ""
                    , ""
                ],
                // TODO：ここまで
                // TODO：画面の仕様に応じて以下の列モデルの定義を変更してください。
                colModel: [
                    { name: 'cd_shizai', width: 150, editable: true },
                    { name: hinName, width: 350, sortable: false, editable: false },
                    { name: 'nm_nisugata_hyoji', width: 200, sortable: false, editable: false },
                    { name: 'nm_tani', width: 120, sortable: false, editable: false },
                    { name: 'su_shiyo', width: 125, editable: true, sorttype: "float", align: "right",
                        align: "right", formatter: 'number',
                        formatoptions: { thousandsSeparator: ",", decimalPlaces: 6, defaultValue: "0" }
                    },
                    { name: 'cd_hinmei', hidden: true, hidedlg: true },
                    { name: 'no_han', hidden: true, hidedlg: true },
                    { name: 'body_ts', hidden: true, hidedlg: true },
                    { name: 'hinmei_flg_mishiyo', hidden: true, hidedlg: true }
                ],
                // TODO：ここまで
                datatype: "local",
                shrinkToFit: false,
                multiselect: false,
                rownumbers: true,
                cellEdit: true,
                onRightClickRow: function (rowid) {
                    $("#" + rowid).removeClass("ui-state-highlight").find("td").click();
                },
                cellsubmit: 'clientArray',
                hoverrows: false,
                loadonce: true,
                onSortCol: function () {
                    grid.setGridParam({ rowNum: grid.getGridParam("records") });
                },
                loadComplete: function () {

                    // 背景色保持するための変数を初期化
                    preClass = "";
                    preSelectedRow = 0;

                    var ids = grid.jqGrid('getDataIDs');
                    for (var i = 0; i < ids.length; i++) {
                        var id = ids[i];
                        // TODO：画面の仕様に応じて以下の操作可否の定義を変更してください。
                        if (grid.jqGrid('getCell', id, 'body_ts')) {
                            grid.jqGrid('setCell', id, 'cd_shizai', '', 'not-editable-cell');
                        }
                        // TODO：ここまで

                        // 未使用資材の背景色をグレーにする
                        var mishiyoShizai = grid.getCell(id, "hinmei_flg_mishiyo");

                        if (mishiyoShizai == pageLangText.trueFlg.text) {
                            $("#" + id, grid).addClass("mishiyo-shizai");
                        }
                    }
                    // グリッドの先頭行選択
                    //var idNum = grid.getGridParam("selrow");
                    //if (idNum == null) {
                        //$("#1 > td").click();
                    //}
                    //else {
                        //$("#" + idNum).removeClass("ui-state-highlight").find("td").click();
                    //}
                },
                beforeEditCell: function (selectedRowId, cellName, value, iRow, iCol) {
                    currentRow = iRow;
                    currentCol = iCol;
                },
                afterEditCell: function (selectedRowId, cellName, value, iRow, iCol) {
                    // Enter キーでカーソルを移動
                    grid.moveCell(cellName, iRow, iCol);
                },
                beforeSaveCell: function (selectedRowId, cellName, value, iRow, iCol) {
                    // セルバリデーション
                    validateCell(selectedRowId, cellName, value, iCol);
                },
                afterSaveCell: function (selectedRowId, cellName, value, iRow, iCol) {
                    // 関連項目の設定
                    setRelatedValue(selectedRowId, cellName, value, iCol);
                    // 更新状態の変更データの設定
                    var changeData = setUpdatedChangeDataFirst(grid.getRowData(selectedRowId));
                    // 更新状態の変更セットに変更データを追加
                    changeSetFirst.addUpdated(selectedRowId, cellName, value, changeData);
                },
                onCellSelect: function (rowid, icol, cellcontent) {
                    selectCol = icol;

                    // 属性を除いた行に除いた属性を戻す
                    $("#" + preSelectedRow, grid).addClass(preClass);

                    // 未使用の資材に付与した属性を除く
                    // 未使用の資材の場合は背景色保持の変数に値を設定する
                    var mishiyoShizai = grid.getCell(rowid, "hinmei_flg_mishiyo");
                    if (mishiyoShizai == pageLangText.trueFlg.text) {
                        $("#" + rowid, grid).removeClass("mishiyo-shizai");
                        preClass = 'mishiyo-shizai';
                        preSelectedRow = rowid;
                        // 未使用の資材でない場合は背景色保持の変数を初期化する
                    } else {
                        $("#" + rowid, grid).removeClass("mishiyo-shizai");
                        preClass = "";
                        preSelectedRow = 0;
                    }
                },
                ondblClickRow: function (rowid) {
                    if (checkShowDialog(rowid)) {
                        //var iCol = grid[0].p.iCol;
                        var iCol = selectCol;
                        // 資材一覧セレクタ起動
                        if (iCol == shizaiCodeCol || iCol == shizaiNameCol) {
                            // 検索条件変更チェック
                            if (isCriteriaChange) {
                                showCriteriaChange("navigate");
                                return;
                            }
                            showShizaiDialog(rowid);
                        }
                    }
                }
            });

            /// <summary>セルの関連項目を設定します。</summary>
            /// <param name="selectedRowId">選択行ID</param>
            /// <param name="cellName">列名</param>
            /// <param name="value">元となる項目の値</param>
            /// <param name="iCol">項目の列番号</param>
            var setRelatedValue = function (selectedRowId, cellName, value, iCol) {
                // TODO：画面の仕様に応じて以下の関連項目を設定を変更してください。
                if (cellName == "cd_shizai") {
                    var serviceUrl = "../Services/FoodProcsService.svc/vw_ma_hinmei_04()?$filter=cd_hinmei eq '" + value
                                        + "' and kbn_hin eq " + pageLangText.shizaiHinKbn.text
                                        + " and flg_mishiyo_hin eq " + pageLangText.falseFlg.text
                                        + " and flg_mishiyo_tani eq " + pageLangText.falseFlg.text + "&$top=1",
                        elementCode = "cd_hinmei",
                        codeName;
                    App.deferred.parallel({
                        // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                        codeName: App.ajax.webget(serviceUrl)
                        // TODO: ここまで
                    }).done(function (result) {
                        // TODO: 画面の仕様に応じて以下のサービス呼び出し成功時の処理を変更してください。
                        var row = grid.getRowData(selectedRowId);
                        codeName = result.successes.codeName.d;
                        if (codeName.length > 0 && codeName[0].cd_hinmei === value) {
                            grid.setCell(selectedRowId, hinName, codeName[0][hinName]);
                            grid.setCell(selectedRowId, "nm_nisugata_hyoji", codeName[0]["nm_nisugata"]);
                            grid.setCell(selectedRowId, "nm_tani", codeName[0]["nm_tani"]);
                        }
                        else {
                            grid.setCell(selectedRowId, hinName, null);
                            grid.setCell(selectedRowId, "nm_nisugata_hyoji", null);
                            grid.setCell(selectedRowId, "nm_tani", null);
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
                }
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
            $(".colchange-button").on("click", function (e) {
                // 検索条件変更チェック
                if (isCriteriaChange) {
                    showCriteriaChange("colchange");
                    return;
                }
                showColumnSettingDialog(e);
            });

            //// コントロール定義 -- End

            //// 操作制御定義 -- Start

            // 操作制御定義を定義します。
            App.ui.pagedata.operation.applySetting(App.ui.page.user.Roles[0], App.ui.page.lang);
            //// 操作制御定義 -- End

            //// 事前データロード -- Start 

            // 日付の多言語対応
            var datePickerFormat = pageLangText.dateFormatUS.text;
            if (App.ui.page.langCountry != 'en-US') {
                datePickerFormat = pageLangText.dateFormat.text;
            }
            // TODO：画面の仕様に応じて以下の datepicker の設定を変更してください。
            $("#id_dt_from").on("keyup", App.data.addSlashForDateString);
            $("#id_dt_from").datepicker({
                dateFormat: datePickerFormat,
                // 有効範囲：1975/1/1～システム日付より50年後
                minDate: new Date(1975, 1 - 1, 1),
                maxDate: "+50y"
            });

            /*
            // 画面アーキテクチャ共通の事前データロード
            App.deferred.parallel({
            loading: App.ui.loading.show(pageLangText.nowProgressing.text),
            // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
            hinmei: App.ajax.webget("../Services/FoodProcsService.svc/ma_hinmei?$filter=cd_hinmei eq '" + hinmeiCode + "' and kbn_hin eq " + pageLangText.seihinHinKbn.text + "&$select=" + hinName),
            nisugata: App.ajax.webget("../Services/FoodProcsService.svc/ma_hinmei?$filter=cd_hinmei eq '" + hinmeiCode + "' and kbn_hin eq " + pageLangText.seihinHinKbn.text + "&$select=nm_nisugata_hyoji")
            // TODO: ここまで
            }).done(function (result) {
            // TODO: 画面の仕様に応じて以下のサービス呼び出し成功時の処理を変更してください。
            if (!App.isUndefOrNull(result.successes.hinmei.d[0])) {
            //if (App.ui.page.lang === "ja") {
            //$("#nm_hinmei").text(result.successes.hinmei.d[0].nm_hinmei_ja);
            //}
            //else if (App.ui.page.lang === "en") {
            //$("#nm_hinmei").text(result.successes.hinmei.d[0].nm_hinmei_en);
            //}
            //else if (App.ui.page.lang === "zh") {
            //$("#nm_hinmei").text(result.successes.hinmei.d[0].nm_hinmei_zh);
            //}
            $("#nm_hinmei").text(result.successes.hinmei.d[0][hinName]);
            }
            if (!App.isUndefOrNull(result.successes.nisugata.d[0])) {
            $("#nm_nisugata_hyoji").text(App.ifUndefOrNull(result.successes.nisugata.d[0].nm_nisugata_hyoji, ""));
            }
            $("#id_cd_hinmei").val(hinmeiCode);
            getCodeName(hinmeiCode);
            // TODO: ここまで
            }).fail(function (result) {
            var length = result.key.fails.length,
            messages = [];
            for (var i = 0; i < length; i++) {
            var keyName = result.key.fails[i];
            messages.push(keyName + " " + result.fails[keyName].message);
            }
            App.ui.page.notifyAlert.message(messages).show();
            }).always(function () {
            App.ui.loading.close();
            });
            */

            // 版番号コンボボックスの作成
            var createdHanNoComboBox = function (code) {
                $("#id_no_han").children().remove();
                if (App.isUndefOrNull(code)) {
                    // 製品コードが入力されていない場合、製品情報をクリアして版番号を初期化する
                    clearSeihinInfo();
                    return;
                }

                App.deferred.parallel({
                    //loading: App.ui.loading.show(pageLangText.nowProgressing.text),
                    // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                    han: App.ajax.webgetSync("../Services/FoodProcsService.svc/ma_shiyo_h?$filter=cd_hinmei eq '" + code + "'&$select=no_han&$orderby=no_han desc"),
                    hanMax: App.ajax.webgetSync("../Services/FoodProcsService.svc/ma_shiyo_h?$filter=cd_hinmei eq '" + code + "'&$select=no_han&$orderby=no_han desc&$top=1")
                    // TODO: ここまで
                }).done(function (result) {
                    // TODO: 画面の仕様に応じて以下のサービス呼び出し成功時の処理を変更してください。
                    if (!App.isUndefOrNull(result.successes.hanMax.d[0])) {
                        $("#no_han_max").text(result.successes.hanMax.d[0].no_han);
                    }
                    else {
                        $("#no_han_max").text(pageLangText.hanNoShokichi.text);
                    }
                    // 検索用ドロップダウンの設定
                    if (!App.isUndefOrNull(result.successes.han.d[0])) {
                        App.ui.appendOptions($("#id_no_han"), "no_han", "no_han", result.successes.han.d, false);
                        $("#shinkiHan-button").attr("disabled", false);
                        isCreated = false;
                    }
                    else {
                        clearHanNoComboBox();
                        //isCreated = true;
                    }
                    // TODO: ここまで
                }).fail(function (result) {
                    var length = result.key.fails.length, messages = [];
                    for (var i = 0; i < length; i++) {
                        var keyName = result.key.fails[i];
                        messages.push(keyName + " " + result.fails[keyName].message);
                    }
                    App.ui.page.notifyAlert.message(messages).show();
                }).always(function () {
                    //App.ui.loading.close();
                });
            };

            // 画面アーキテクチャ共通の事前データロード

            // pageLangTextを用いた事前データロード
            // TODO: 画面の仕様に応じて以下の処理を変更してください。
            //masterKubun = pageLangText.masterKubunId.data;
            // 検索用ドロップダウンの設定
            //App.ui.appendOptions($(".search-criteria [name='masterKubun']"), "id", "name", masterKubun, false);
            //// 事前データロード -- End

            //// 検索処理 -- Start

            // 画面アーキテクチャ共通の検索処理

            /// <summary>クエリオブジェクトの設定</summary>
            var query = function () {
                var query = {
                    url: "../Services/FoodProcsService.svc/vw_ma_shiyo_01",
                    filter: createFilter(),
                    orderby: "cd_shizai",   // ソート条件
                    skip: querySetting.skip,
                    top: querySetting.top,
                    inlinecount: "allpages"
                }
                return query;
            };

            /// <summary>フィルター条件の設定</summary>
            var createFilter = function () {
                var criteria = $(".search-criteria").toJSON(),
                    filters = [];
                // フィルター条件
                filters.push("cd_hinmei eq '" + criteria.cd_hinmei + "'");
                filters.push("no_han eq " + $("#id_no_han").val());
                filters.push("kbn_hin eq " + pageLangText.shizaiHinKbn.text);
                //filters.push("hinmei_flg_mishiyo eq " + pageLangText.falseFlg.text);
                filters.push("tani_flg_mishiyo eq " + pageLangText.falseFlg.text);

                return filters.join(" and ");
            };
            /// <summary>データ検索を行います。</summary>
            /// <param name="query">クエリオブジェクト</param>
            var searchItems = function (query) {
                closeFindConfirmDialog();
                if (isDataLoading === true) {
                    return;
                }
                isDataLoading = true;
                App.ajax.webget(
                // WCF Data ServicesのODataシステムクエリオプションを生成
                    App.data.toODataFormat(query)
                ).done(function (result) {
                    // 検索フラグを立てる
                    isSearch = true;
                    // データバインド
                    bindData(result);
                    var yukoHizuke = $("#id_dt_from");
                    yukoHizuke.attr("readonly", false);
                    yukoHizuke.datepicker("option", "showOn", 'focus');
                    var criteria = $(".search-criteria").toJSON();
                    if (result.d.results.length > 0) {
                        // 検索条件を閉じる
                        closeCriteria();
                        isCriteriaChange = false;
                        $("#id_ts").val(result.d.results[0].header_ts);
                        // 有効日付のセット
                        var fromDate = result.d.results[0].dt_from
                            , mishiyoFlag = result.d.results[0].flg_mishiyo;
                        if (App.isUndefOrNull(fromDate) || fromDate == "") {
                            if (criteria.no_han == pageLangText.hanNoShokichi.text) {
                                yukoHizuke.datepicker("setDate", new Date(1975, 1 - 1, 1));
                            }
                            else {
                                yukoHizuke.datepicker("setDate", getDate());
                            }
                        }
                        else {
                            yukoHizuke.datepicker("setDate", App.data.getDate(fromDate));
                        }
                        var colModel = grid.getGridParam("colModel");
                        // 未使用フラグのセット
                        if (mishiyoFlag == pageLangText.trueFlg.text) {
                            //$('#id_flg_mishiyo').attr('checked', 'checked');
                            $('#id_flg_mishiyo').attr('checked', true);
                            colModel[grid.getColumnIndexByName("su_shiyo")].editable = false;
                        }
                        else {
                            //$('#id_flg_mishiyo').attr('checked');
                            $('#id_flg_mishiyo').attr('checked', false);
                            colModel[grid.getColumnIndexByName("su_shiyo")].editable = true;
                        }
                        // 有効日付の操作付加を設定
                        if (criteria.no_han == pageLangText.hanNoShokichi.text || mishiyoFlag == pageLangText.trueFlg.text) {
                            yukoHizuke.attr("readonly", true);
                            yukoHizuke.datepicker("option", "showOn", '');
                        }
                        $("#shinkiHan-button").attr("disabled", false);
                    }
                    else {
                        // 有効日付のセット
                        if (criteria.no_han == pageLangText.hanNoShokichi.text) {
                            yukoHizuke.datepicker("setDate", new Date(1975, 1 - 1, 1));
                            yukoHizuke.attr("readonly", true);
                            yukoHizuke.datepicker("option", "showOn", '');
                        }
                        else {
                            yukoHizuke.datepicker("setDate", getDate());
                        }
                    }
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                    App.ui.loading.close();
                }).always(function () {
                    // ローディングの終了
                    App.ui.loading.close();
                    isDataLoading = false;
                });
            };

            /// 品名コード変更時
            //$(".search-criteria [name='cd_hinmei']").on("change", function (e) {
            //    createdHanNoComboBox($(".search-criteria [name='cd_hinmei']").val());
            //});

            // 品名コード変更時の処理
            var changeHinmeiCode = function () {
                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();

                var code = $("#id_cd_hinmei").val();
                //createdHanNoComboBox(code);
                //getCodeName(code);

                // 製品のが存在する場合
                if (getCodeName(code)) {

                    // 版コンボボックスを作成する。
                    createdHanNoComboBox(code);
                    App.ui.loading.close();
                }

            };

            /// <summary>検索条件を閉じます。</summary>
            var closeCriteria = function () {
                var criteria = $(".search-criteria");
                if (!criteria.find(".part-body").is(":hidden")) {
                    criteria.find(".search-part-toggle").click();
                }
            };

            /// <summary>検索条件を開きます。</summary>
            var openCriteria = function () {
                var criteria = $(".search-criteria");
                if (criteria.find(".part-body").is(":hidden")) {
                    criteria.find(".search-part-toggle").click();
                }
            };

            // 検索前処理
            var checkSearch = function () {
                closeFindConfirmDialog();
                if (!isCriteriaChange && !noChange()) {
                    showFindConfirmDialog();
                }
                else {
                    clearState();
                    isClickSearch = true;
                    // 検索前バリデーション
                    var result = $(".part-body .item-list").validation().validate();
                    isClickSearch = false;
                    if (result.errors.length) {
                        // ローディングの終了
                        App.ui.loading.close();
                        return;
                    }
                    searchItems(new query());
                }
            };

            /// <summary>有効日付の操作制御を設定する</summary>
            var ctrlYukoHizuke = function (hanNo) {
                var hizuke = $("#id_dt_from");
                if (hanNo == pageLangText.hanNoShokichi.text) {
                    hizuke.attr("readonly", true);
                    hizuke.datepicker("option", "showOn", '');
                }
                else {
                    hizuke.attr("readonly", false);
                    hizuke.datepicker("option", "showOn", 'focus');
                }
            };

            /// <summary>検索ボタンクリック時のイベント処理を行います。</summary>
            $(".find-button").on("click", function () {
                loading(pageLangText.nowProgressing.text, "find-button");
            });

            /// <summary>製品情報のクリア処理</summary>
            var clearSeihinInfo = function () {
                $("#nm_hinmei").text("");
                $("#nm_nisugata_hyoji").text("");
                clearHanNoComboBox();   // 版番号の初期化
            };
            /// <summary>版番号コンボボックスの初期化</summary>
            var clearHanNoComboBox = function () {
                $("#id_no_han").children().remove();
                $("#no_han_max").text(pageLangText.hanNoShokichi.text);
                var hanShokichi = { d: [{ id: "1", name: "1"}] }
                App.ui.appendOptions($("#id_no_han"), "id", "name", hanShokichi.d, false);
                $("#shinkiHan-button").attr("disabled", true);
                isCreated = true;
            };

            /// <summary>製品情報取得用のサービスURLを取得します。</summary>
            /// <param name="seihinCode">製品コード</param>
            var getSeihinServiceUrl = function (seihinCode) {
                var serviceUrl = "../Services/FoodProcsService.svc/vw_ma_hinmei_04()?$filter=cd_hinmei eq '" + seihinCode
                                    + "' and (kbn_hin eq " + pageLangText.seihinHinKbn.text + " or kbn_hin eq  "
                                    + pageLangText.jikaGenryoHinKbn.text + ")" + " and flg_mishiyo_hin eq "
                                    + pageLangText.falseFlg.text + " and flg_mishiyo_tani eq " + pageLangText.falseFlg.text + "&$top=1"
                return serviceUrl;
            };
            /// <summary>製品コードより、製品情報を取得して設定します。</summary>
            /// <param name="code">製品コード</param>
            var getCodeName = function (code) {
                // 製品コードが空文字の場合は処理中止
                if (code == "") {
                    clearHanNoComboBox();
                    return;
                }

                var serviceUrl = getSeihinServiceUrl(code)
                    , isValidate
                    , elementName = hinName;
                //App.ui.loading.show(pageLangText.nowProgressing.text);

                App.deferred.parallel({
                    codeName: App.ajax.webgetSync(serviceUrl)
                }).done(function (result) {
                    // サービス呼び出し成功時
                    codeName = result.successes.codeName.d;
                    if (codeName.length > 0 && codeName[0].cd_hinmei === code) {
                        var hinName = codeName[0][elementName];
                        $("#nm_hinmei").text(hinName ? hinName : "");
                        $("#nm_nisugata_hyoji").text(getCheckNullValue(codeName[0]["nm_nisugata"]));

                        // 版番号コンボボックス作成処理
                        //createdHanNoComboBox(code);
                        isValidate = true;
                    }
                    //else if ($(".search-criteria").toJSON().cd_hinmei) {
                    //else if (App.isUndefOrNull(code)) {
                    else {
                        App.ui.page.notifyAlert.message(pageLangText.notFound.text, $("#id_cd_hinmei")).show();
                        clearSeihinInfo();
                        //App.ui.loading.close();
                        isValidate = false;
                    }
                    //else {
                    //    $("#id_cd_hinmei").text("");
                    //    clearSeihinInfo();
                    //}
                }).fail(function (result) {
                    var length = result.key.fails.length,
                            messages = [];
                    for (var i = 0; i < length; i++) {
                        var keyName = result.key.fails[i];
                        var value = result.fails[keyName];
                        messages.push(keyName + " " + value.message);
                    }
                    App.ui.page.notifyAlert.message(messages).show();
                    //App.ui.loading.close();
                    isValidate = false;
                }).always(function () {
                    // ローディングの終了
                    //App.ui.loading.close();
                });

                return isValidate;
            };

            /// <summary>値がnullまたはundefineの場合、空文字を返却する。</summary>
            var getCheckNullValue = function (value) {
                if (App.isUndefOrNull(value)) {
                    return "";
                }
                return value;
            };

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
                $("#id_dt_from").datepicker("setDate", "");
                $('#id_flg_mishiyo').attr('checked', false);
                isDelShizai = false;

                // TODO: 画面の仕様に応じて以下のパラメータ設定を変更してください。
                currentRow = 0;
                currentCol = firstCol;
                // 変更セットの作成
                changeSetFirst = new App.ui.page.changeSet();
                changeSetSecond = new App.ui.page.changeSet();
                changeSetThird = new App.ui.page.changeSet();
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
                querySetting.skip = querySetting.skip + result.d.results.length;
                querySetting.count = parseInt(result.d.__count);
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
                    $("#id_ts").val(result.d.results[0].header_ts);
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
                    //更新対象データを初期化します
                    changeSet = new App.ui.page.changeSet();
                    var ids = grid.jqGrid('getDataIDs');
                    //追加された行を削除します
                    for (var i = 0; i < ids.length; i++) {
                        var id = ids[i];
                        if (!grid.jqGrid('getCell', id, 'ts')) {
                            grid.delRowData(id);
                        }
                    }
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
            /// <summary> ダイアログ情報メッセージの設定 </summary>
            var findConfirmDialogNotifyInfo = App.ui.notify.info(findConfirmDialog, {
                container: ".find-confirm-dialog .dialog-slideup-area .info-message",
                messageContainerQuery: "ul",
                show: function () {
                    findConfirmDialog.find(".info-message").show();
                },
                clear: function () {
                    findConfirmDialog.find(".info-message").hide();
                }
            });
            /// <summary> ダイアログ警告メッセージの設定 </summary>
            var findConfirmDialogNotifyAlert = App.ui.notify.alert(findConfirmDialog, {
                container: ".find-confirm-dialog .dialog-slideup-area .alert-message",
                messageContainerQuery: "ul",
                show: function () {
                    findConfirmDialog.find(".alert-message").show();
                },
                clear: function () {
                    findConfirmDialog.find(".alert-message").hide();
                }
            });

            //// メッセージ表示 -- End

            //// データ変更処理 -- Start

            // グリッドコントロール固有のデータ変更処理

            /// <summary>グリッドの選択行の行IDを取得します。 </summary>
            var getSelectedRowId = function (isAdd) {
                var selectedRowId = grid.getGridParam("selrow"),
                    ids = grid.getDataIDs(),
                    recordCount = grid.getGridParam("records");
                // レコードがない場合は処理を抜ける
                if (recordCount == 0) {
                    if (!isAdd) {
                        // 情報メッセージのクリア
                        App.ui.page.notifyInfo.clear();
                        App.ui.page.notifyInfo.message(pageLangText.noRecords.text).show();
                    }
                    return;
                }
                // 選択行なしの場合の行選択
                if (App.isUnusable(selectedRowId)) {
                    selectedRowId = ids[0]; // 先頭行
                }
                currentRow = $('#' + selectedRowId)[0].rowIndex;

                return selectedRowId;
            };
            /// <summary>新規行データの設定を行います。</summary>
            var setAddData = function () {
                var criteria = $(".search-criteria").toJSON();
                var resultList = $(".result-list").toJSON();
                var addData = {
                    "cd_hinmei": criteria.cd_hinmei,
                    "no_han": criteria.no_han,
                    "dt_from": resultList.dt_from,
                    "cd_shizai": "",
                    "su_shiyo": null,
                    "dt_create": null,
                    "cd_create": App.ui.page.user.Code,
                    "dt_update": null,
                    "cd_update": App.ui.page.user.Code,
                    "ts": ""
                };
                return addData;
            };
            /// <summary>コピー行データの設定を行います。</summary>
            /// <param name="row">選択行</param>
            var setCopyData = function (row) {
                return $.extend({}, row,
                    { "cd_create": App.ui.page.user.Code,
                        "cd_update": App.ui.page.user.Code
                    });
            };
            /// <summary>追加状態の変更セットに追加する変更データの設定を行います。</summary>
            /// <param name="newRow">新規行データ</param>
            var setCreatedChangeDataFirst = function (newRow) {
                var changeData = {
                    "cd_hinmei": newRow.cd_hinmei,
                    "no_han": newRow.no_han,
                    "dt_from": newRow.dt_from,
                    "cd_shizai": newRow.cd_shizai,
                    "su_shiyo": newRow.su_shiyo,
                    "dt_create": null,
                    "cd_create": App.ui.page.user.Code,
                    "dt_update": null,
                    "cd_update": App.ui.page.user.Code,
                    "ts": newRow.body_ts
                };
                return changeData;
            };
            /// <summary>更新状態の変更セットに追加する変更データの設定を行います。</summary>
            /// <param name="row">選択行</param>
            var setUpdatedChangeDataFirst = function (row) {
                var changeData = {
                    "cd_hinmei": row.cd_hinmei,
                    "no_han": row.no_han,
                    "dt_from": row.dt_from,
                    "cd_shizai": row.cd_shizai,
                    "su_shiyo": row.su_shiyo,
                    "dt_create": row.dt_create,
                    "cd_create": row.cd_create,
                    "dt_update": null,
                    "cd_update": App.ui.page.user.Code,
                    "ts": row.body_ts
                };
                return changeData;
            };
            /// <summary>削除状態の変更セットに追加する変更データの設定を行います。</summary>
            /// <param name="row">選択行</param>
            var setDeletedChangeDataFirst = function (row) {
                // 資材削除
                var changeData;
                if (isDelShizai) {
                    changeData = {
                        "cd_hinmei": row.cd_hinmei,
                        "ts": row.body_ts
                    };
                }
                else {
                    changeData = {
                        "cd_hinmei": row.cd_hinmei,
                        "no_han": row.no_han,
                        "cd_shizai": row.cd_shizai,
                        "ts": row.body_ts
                    };
                }
                return changeData;
            };

            /// <summary>新規行を追加します。</summary>
            /// <param name="e">イベントデータ</param>
            var addData = function (e) {
                App.ui.page.notifyAlert.clear();
                if (grid.getGridParam("records") >= pageLangText.maxAddRowCount.text) {
                    App.ui.page.notifyAlert.message(App.str.format(MS0692, pageLangText.maxAddRowCount.text)).show();
                    return;
                }
                // 選択行のID取得
                var selectedRowId = getSelectedRowId(true),
                    position = "after";
                // 新規行データの設定
                var newRowId = App.uuid(),
                    addData = setAddData();
                if (App.isUndefOrNull(selectedRowId)) {
                    // 末尾にデータ追加
                    grid.addRowData(newRowId, addData);
                    currentRow = 0;
                }
                else {
                    // セル編集内容の保存
                    grid.saveCell(currentRow, currentCol);
                    // 選択行の任意の位置にデータ追加
                    grid.addRowData(newRowId, addData, position, selectedRowId);
                }
                // 追加状態の変更セットに変更データを追加
                changeSetFirst.addCreated(newRowId, setCreatedChangeDataFirst(addData));
                // セルを選択して入力モードにする
                grid.editCell(currentRow + 1, firstCol, true);

                // 属性を除いた行に除いた属性を戻す
                $("#" + preSelectedRow, grid).addClass(preClass);

                // 未使用の資材に付与した属性を除く
                // 未使用の資材の場合は背景色保持の変数に値を設定する
                var mishiyoShizai = grid.getCell(currentRow + 1, "hinmei_flg_mishiyo");
                if (mishiyoShizai == pageLangText.trueFlg.text) {
                    $("#" + currentRow + 1, grid).removeClass("mishiyo-shizai");
                    preClass = 'mishiyo-shizai';
                    preSelectedRow = rowid;
                    // 未使用の資材でない場合は背景色保持の変数を初期化する
                } else {
                    $("#" + currentRow + 1, grid).removeClass("mishiyo-shizai");
                    preClass = "";
                    preSelectedRow = 0;
                }
            };

            /// <summary>追加ボタンクリック時のイベント処理を行います。</summary>
            $(".add-button").on("click", function (e) {
                // 検索済であるかチェック
                if (!isSearch) {
                    App.ui.page.notifyInfo.message(MS0621).show();
                    return;
                }
                // 検索条件変更チェック
                if (isCriteriaChange) {
                    showCriteriaChange("lineAdd");
                    return;
                }
                // 未使用版の場合は、何もしない
                if ($('#id_flg_mishiyo').prop('checked')) {
                    return;
                }
                addData();
            });

            /// <summary>行を削除します。</summary>
            /// <param name="e">イベントデータ</param>
            var deleteData = function (e) {
                // 選択行のID取得
                var selectedRowId = getSelectedRowId();
                if (App.isUndefOrNull(selectedRowId)) {
                    return;
                }
                // セル編集内容の保存
                grid.saveCell(currentRow, currentCol);
                // カレント行のエラーメッセージを削除
                removeAlertRow(selectedRowId);
                // 削除状態の変更データの設定
                var changeData = setDeletedChangeDataFirst(grid.getRowData(selectedRowId));
                // 削除データを更新セットに追加
                changeSetFirst.addDeleted(selectedRowId, changeData);
                // 選択行の行データ削除
                grid.delRowData(selectedRowId);
                if (grid.getGridParam("records") > 0) {
                    // セルを選択して入力モードにする
                    grid.editCell(currentRow === 1 ? currentRow : currentRow - 1, currentCol, true);
                }
            };

            /// <summary>資材を削除します。</summary>
            /// <param name="e">イベントデータ</param>
            var deleteShizaiData = function (e) {
                // ダイアログを閉じる
                closeDeleteConfirmDialog();
                isDelShizai = true;
                var criteria = $(".search-criteria").toJSON();
                // 削除データを更新セットに追加
                changeSetThird.addDeleted(1, criteria);

                // 変更セットの初期化
                changeSetFirst = new App.ui.page.changeSet();
                changeSetSecond = new App.ui.page.changeSet();

                // 保存
                saveData();
            };
            /// <summary>削除ボタンクリック時のイベント処理を行います。</summary>
            $(".delete-button").on("click", function (e) {
                // 検索条件変更チェック
                if (isCriteriaChange) {
                    showCriteriaChange("lineDel");
                    return;
                }
                // 未使用版の場合は、何もしない
                if ($('#id_flg_mishiyo').prop('checked')) {
                    return;
                }
                // 明細行が0件の場合、削除処理を中止する
                if (grid.getGridParam("records") == 0) {
                    App.ui.page.notifyAlert.message(MS0442).show();
                    return;
                }
                //if (grid.getGridParam("records") == 1) {
                //    App.ui.page.notifyAlert.message(MS0132).show();
                //    return;
                //}
                deleteData();
            });

            //// データ変更処理 -- End

            //// 保存処理 -- Start

            // グリッドコントロール固有の保存処理

            // <summary>データに変更がないかどうかを返します。</summary>
            var noChange = function () {
                // 新規版の場合は変更ありとする
                if (App.isUnusable(changeSetFirst) || changeSetFirst.noChange()) {
                    return (App.isUnusable(changeSetSecond) || changeSetSecond.noChange());
                }
                return false;
            };
            /// <summary>編集内容の保存</summary>
            var saveEdit = function () {
                grid.saveCell(currentRow, currentCol);
            };
            /// <summary>更新データを取得します。</summary>
            var getPostData = function () {
                ChangeSets = {};
                ChangeSets.First = changeSetFirst.getChangeSetData();
                ChangeSets.Second = changeSetSecond.getChangeSetData();
                ChangeSets.Third = changeSetThird.getChangeSetData();
                return JSON.stringify(ChangeSets);
            };
            /// <summary>データ変更エラーハンドリングを行います。</summary>
            /// <param name="result">エラーの戻り値</param>
            var handleSaveDataError = function (result) {
                var ret = JSON.parse(result.rawText);
                if (App.isUndefOrNull(ret.First) && App.isUndefOrNull(ret.Second) && App.isUndefOrNull(ret.Third)) {
                    App.ui.page.notifyAlert.message(result.message).show();
                    return;
                }
                var ids = grid.getDataIDs(),
                    newId,
                    value,
                    unique,
                    current,
                // TODO: 画面の仕様に応じて以下の変数を変更します。
                    checkCol = grid.getColumnIndexByName("cd_shizai");
                // TODO: ここまで
                // 【明細】データ整合性エラーのハンドリングを行います。
                if (App.isArray(ret.First) && ret.First.length > 0) {
                    for (var i = 0; i < ret.First.length; i++) {
                        // TODO: 画面の仕様に応じて以下の値を変更します。
                        if (ret.First[i].InvalidationName === "Exists" || ret.First[i].InvalidationName === "NotExists") {
                            // TODO: ここまで
                            for (var j = 0; j < ids.length; j++) {
                                value = grid.getCell(ids[j], checkCol);
                                retValue = ret.First[i].Data.cd_shizai;
                                if (value === retValue && !grid.getCell(ids[j], "body_ts")) {
                                    unique = ids[j] + "_" + checkCol;
                                    App.ui.page.notifyAlert.message(pageLangText.invalidation.text + ret.First[i].Message, unique).show();
                                    // 対象セルの背景変更
                                    grid.setCell(ids[j], checkCol, ret.First[i].Data.cd_shizai, { background: '#ff6666' });
                                }
                            }
                            // 存在チェック
                            if (ret.First[i].Message != null) {
                                App.ui.page.notifyAlert.message(pageLangText.invalidation.text + ret.First[i].Message, unique).show();
                            }
                        }
                    }
                }
                // 【明細】更新時同時実行制御エラーのハンドリングを行います。
                if (!App.isUndefOrNull(ret.First.Updated) && ret.First.Updated.length > 0) {
                    for (var i = 0; i < ret.First.Updated.length; i++) {
                        for (p in changeSetFirst.changeSet.updated) {
                            if (!changeSetFirst.changeSet.updated.hasOwnProperty(p)) {
                                continue;
                            }
                            // TODO: 画面の仕様に応じて以下の値を変更します。
                            value = grid.getCell(p, checkCol);
                            retValue = ret.First.Updated[i].Requested.cd_shizai;
                            // TODO: ここまで
                            if (isNaN(value) || value === retValue) {
                                // 更新状態の変更セットから変更データを削除
                                changeSetFirst.removeUpdated(p);

                                // 他のユーザーによって削除されていた場合
                                if (App.isUndefOrNull(ret.First.Updated[i].Current)) {
                                    // 対象行の削除
                                    grid.delRowData(p);
                                    // メッセージの表示
                                    App.ui.page.notifyAlert.message(pageLangText.duplicate.text + pageLangText.deletedDuplicate.text).show();
                                }
                                else {
                                    unique = p + "_" + duplicateCol;
                                    // TODO: 画面の仕様に応じて以下の値を変更します。
                                    current = grid.getRowData(p);
                                    $.extend(current, ret.First.Updated[i].Current);
                                    // TODO: ここまで

                                    // 対象行の更新
                                    grid.setRowData(p, current);
                                    // エラーメッセージの表示
                                    App.ui.page.notifyAlert.message(pageLangText.duplicate.text + pageLangText.updatedDuplicate.text, unique).show();
                                }
                            }
                        }
                    }
                }
                // 【明細】削除時同時実行制御エラーのハンドリングを行います。
                if (!App.isUndefOrNull(ret.First.Deleted) && ret.First.Deleted.length > 0) {
                    for (var i = 0; i < ret.First.Deleted.length; i++) {
                        for (p in changeSetFirst.changeSet.deleted) {
                            if (!changeSetFirst.changeSet.deleted.hasOwnProperty(p)) {
                                continue;
                            }
                            // TODO: 画面の仕様に応じて以下の値を変更します。
                            if (!App.isUndefOrNull(changeSetFirst.changeSet.deleted[p].cd_shizai)) {
                                value = changeSetFirst.changeSet.deleted[p].cd_shizai;
                                retValue = ret.First.Deleted[i].Requested.cd_shizai;
                                if (isNaN(value) || value === retValue) {
                                    // 削除状態の変更セットから変更データを削除
                                    changeSetFirst.removeDeleted(p);

                                    // 他のユーザーによって削除されていた場合
                                    if (App.isUndefOrNull(ret.First.Deleted[i].Current)) {
                                        // メッセージの表示
                                        App.ui.page.notifyAlert.message(pageLangText.duplicate.text + pageLangText.deletedDuplicate.text).show();
                                    }
                                    else {
                                        // メッセージの表示
                                        App.ui.page.notifyAlert.message(pageLangText.duplicate.text + pageLangText.unDeletedDuplicate.text).show();
                                        confFlg = true;
                                    }
                                }
                            }
                            // TODO: ここまで
                        }
                    }
                }
                // 【コピーデータ】データ整合性エラーのハンドリングを行います。
                if (App.isArray(ret.Third) && ret.Third.length > 0) {
                    // TODO: 画面の仕様に応じて以下の値を変更します。
                    if (ret.Third[0].InvalidationName === "Exists") {
                        // 他のユーザーによってコピー元資材が削除されていた場合
                        if (!App.isUndefOrNull(ret.Third[0].Message)) {
                            // メッセージの表示
                            App.ui.page.notifyAlert.message(pageLangText.invalidation.text + ret.Third[0].Message, unique).show();
                        }
                    }
                }
                // 【明細】データ整合性エラーのハンドリングを行います。
                if (App.isArray(ret.Second) && ret.Second.length > 0) {
                    for (var i = 0; i < ret.Second.length; i++) {
                        // TODO: 画面の仕様に応じて以下の値を変更します。
                        if (ret.Second[i].InvalidationName === "Exists" || ret.Second[i].InvalidationName === "NotExists") {
                            // TODO: ここまで
                            App.ui.page.notifyAlert.message(pageLangText.invalidation.text + ret.Second[i].Message, unique).show();
                            // 対象セルの背景変更
                            // grid.setCell(ids[j], checkCol, ret.Second[i].Data.cd_shizai, { background: '#ff6666' });
                        }
                    }
                }
                // 【ヘッダー】更新時同時実行制御エラーのハンドリングを行います。
                if (!App.isUndefOrNull(ret.Second.Updated) && ret.Second.Updated.length > 0) {
                    for (var i = 0; i < ret.Second.Updated.length; i++) {
                        for (p in changeSetSecond.changeSet.updated) {
                            if (!changeSetSecond.changeSet.updated.hasOwnProperty(p)) {
                                continue;
                            }
                            // TODO: 画面の仕様に応じて以下の値を変更します。
                            value_a = $("#id_cd_hinmei").val();
                            retValue_a = ret.Second.Updated[i].Requested.cd_hinmei;
                            value_b = $("#id_no_han").val();
                            retValue_b = ret.Second.Updated[i].Requested.no_han;
                            // TODO: ここまで

                            if ((isNaN(value_a) || value_a === retValue_a) && (isNaN(value_b) || value_b === retValue_b)) {
                                // 更新状態の変更セットから変更データを削除
                                changeSetSecond.removeUpdated(p);

                                // 対象項目の更新
                                $("#id_dt_from").val(ret.Second.Updated[i].Current.dt_from);
                                if (ret.Second.Updated[i].Current.flg_mishiyo === pageLangText.trueFlag.text) {
                                    $('#id_flg_mishiyo').attr('checked', 'checked');
                                }
                                else {
                                    $('#id_flg_mishiyo').attr('checked');
                                }
                                // エラーメッセージの表示
                                App.ui.page.notifyAlert.message(
                                    pageLangText.duplicate.text + pageLangText.updatedDuplicate.text, unique).show();
                            } else if (confFlg == false) {
                                // エラーメッセージの表示
                                App.ui.page.notifyAlert.message(
                                    pageLangText.duplicate.text + pageLangText.updatedDuplicate.text, unique).show();
                            }
                        }
                    }
                }
                // 【ヘッダー】削除時同時実行制御エラーのハンドリングを行います。
                if (!App.isUndefOrNull(ret.Second.Deleted) && ret.Second.Deleted.length > 0) {
                    // 他のユーザーによって削除されていた場合
                    if (App.isUndefOrNull(ret.Second.Deleted[0].Current)) {
                        // メッセージの表示
                        App.ui.page.notifyAlert.message(
                            App.str.format(pageLangText.duplicate.text + pageLangText.hanNotExists.text, pageLangText.cd_haigo.text)
                        ).show();
                    }
                    else {
                        // TODO：画面の仕様に応じて更新後のデータ状態をセットしてください。
                        var body = $(".part-body");
                        var data = {
                            "dt_from": ret.Second.Deleted[0].Current.dt_from,
                            "flg_mishiyo": ret.Second.Deleted[0].Current.flg_mishiyo
                        };
                        // TODO：ここまで
                        // カレントのデータを画面へ表示
                        body.toForm(data);
                        // エラーメッセージの表示
                        App.ui.page.notifyAlert.message(pageLangText.duplicate.text + pageLangText.updatedDuplicate.text).show();
                    }
                }
            };

            /// <summary>有効日付のバリデーションチェックを行います。</summary>
            var checkYukoHizuke = function () {
                var isVali = true;
                var resultHizuke = $(".vali-yuko-hizuke").validation().validate();
                if (resultHizuke.errors.length) {
                    isVali = false;
                }
                return isVali;
            };
            /// <summary>ヘッダーの更新データをセットします。</summary>
            var setChangeSetSecond = function () {
                // 有効日付のバリデーションチェック
                if (!checkYukoHizuke()) {
                    App.ui.loading.close();
                    return;
                }

                var partBody = $(".part-body").toJSON()
                    , criteria = $(".search-criteria").toJSON();
                if ($('#id_flg_mishiyo').prop('checked')) {
                    partBody.flg_mishiyo = pageLangText.trueFlg.text;
                }
                else {
                    partBody.flg_mishiyo = pageLangText.falseFlg.text;
                }
                changeSetSecond = new App.ui.page.changeSet();
                // 更新データをJSONオブジェクトに変換
                var postDataSecond = $.extend({}, partBody, criteria);
                var dt_from = postDataSecond.dt_from;

                // 有効日付に入力がある場合、登録用にフォーマットをかける
                if (dt_from != "") {
                    postDataSecond.dt_from = App.data.getDateTimeStringForQueryNoUtc(App.date.localDate(dt_from));
                }

                if (isCreated) {
                    // 配合名マスタの新規版の内容を格納
                    changeSetSecond.addCreated(1, postDataSecond);
                }
                else {
                    // 配合名マスタの変更内容を格
                    changeSetSecond.addUpdated(1, null, null, postDataSecond);
                }
            };

            /// <summary>変更を保存します。</summary>
            /// <param name="e">イベントデータ</param>
            var saveData = function (e) {
                closeSaveConfirmDialog();
                confFlg = false;
                // 情報メッセージのクリア
                //App.ui.page.notifyInfo.clear();
                // ローディングの表示
                App.ui.loading.show(pageLangText.nowSaving.text);

                // if (!isCreated && !isDelShizai) {
                if (!isDelShizai) {
                    // ヘッダーの更新データをセットする
                    setChangeSetSecond();
                }

                // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                var saveUrl = "../api/ShizaiShiyoMaster";
                // TODO: ここまで

                App.ajax.webpost(
                    saveUrl, getPostData()
                ).done(function (result) {
                    var retIsDelShizai = isDelShizai;
                    // 検索前の状態に戻す
                    clearState();
                    // 資材使用削除処理のとき
                    if (retIsDelShizai) {
                        createdHanNoComboBox($("#cd_hinmei").val());
                        openCriteria();
                        App.ui.page.notifyInfo.message(MS0039).show();
                        App.ui.loading.close();
                    }
                    else {
                        // データ検索
                        searchItems(new query());
                        App.ui.page.notifyInfo.message(pageLangText.successMessage.text).show();
                    }
                    isCreated = false;
                }).fail(function (result) {
                    // データ変更エラーハンドリングを行います。
                    handleSaveDataError(result);
                    App.ui.loading.close();
                }).always(function () {
                    // ローディングの終了
                    //App.ui.loading.close();
                    // 有効日付の操作制御を設定する
                    ctrlYukoHizuke($("#id_no_han").val());
                });
            };

            /// <summary>保存前チェック</summary>
            var checkSave = function () {
                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();
                // 編集内容の保存
                saveEdit();

                isClickSave = true;

                // 変更セット内にバリデーションエラーがある場合は処理を抜ける
                if (!validateChangeSet() || !checkYukoHizuke()) {
                    App.ui.loading.close(); // ローディングの終了
                    return;
                }

                isClickSave = false;

                // 変更がない場合は処理を抜ける
                if (noChange() || grid.getGridParam("records") <= 0) {
                    App.ui.page.notifyInfo.message(pageLangText.noChange.text).show();
                    App.ui.loading.close(); // ローディングの終了
                    return;
                }

                // 同じ有効日付が他の版に存在しないこと
                if (!isValidYukoHizuke()) {
                    App.ui.loading.close(); // ローディングの終了
                }
                else {
                    // チェックがすべて終わってからローディング表示を終了させる
                    App.ui.loading.close();
                    // 保存確認ダイアログを表示する
                    showSaveConfirmDialog();
                }

                // 保存確認ダイアログを表示する
                //showSaveConfirmDialog();
            };

            /// <summary>保存ボタンクリック時のイベント処理を行います。</summary>
            $(".save-button").on("click", function () {
                // 検索済であるかチェック
                if (!isSearch) {
                    App.ui.page.notifyInfo.message(MS0621).show();
                    return;
                }
                // 検索条件変更チェック
                if (isCriteriaChange) {
                    showCriteriaChange("save");
                    return;
                }
                loading(pageLangText.nowProgressing.text, "save-button");
            });

            //// 保存処理 -- End

            //// バリデーション -- Start

            /// <summary>同じ有効日付が他の版に存在しないこと</summary>
            var isValidYukoHizuke = function () {
                var isValid = true;
                var criteria = $(".result-list").toJSON(),
                    code = $("#id_cd_hinmei").val(),
                    han = $("#id_no_han").val();

                var query = "../Services/FoodProcsService.svc/ma_shiyo_h()?$filter=cd_hinmei eq '" + code
                                    + "' and dt_from eq DateTime'" + App.data.getDateTimeStringForQueryNoUtc(criteria.dt_from)
                                    + "' and no_han ne " + han + "&$top=1";
                App.ajax.webgetSync(
                    query
                ).done(function (result) {
                    // 検索結果件数が0件以上：他の版に存在するので、エラーとする
                    if (result.d.length > 0) {
                        App.ui.page.notifyAlert.message(MS0691, $("#id_dt_from")).show();
                        isValid = false;
                    }
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                    isValid = false;
                });
                return isValid;
            };

            // グリッドコントロール固有のバリデーション

            // TODO: 画面の仕様に応じて以下のカスタムバリデーション定義を変更してください。

            /// <summary>データベース問い合わせチェックを行います。</summary>
            /// <param name="shizaiCode">資材コード</param>
            var isValidShizaiCode = function (shizaiCode) {
                var isValid = true;

                App.ajax.webgetSync("../Services/FoodProcsService.svc/vw_ma_hinmei_04()?$filter=cd_hinmei eq '" + shizaiCode
                                    + "' and kbn_hin eq " + pageLangText.shizaiHinKbn.text
                                    + " and flg_mishiyo_hin eq " + pageLangText.falseFlg.text
                                    + " and flg_mishiyo_tani eq " + pageLangText.falseFlg.text + "&$top=1"
                ).done(function (result) {
                    // !! 存在チェック
                    if (result.d.length == 0) {
                        // 検索結果件数が0件の場合
                        // 品名マスタ存在チェックエラー
                        //$("#nm_hinmei").text("");
                        validationSetting.cd_shizai.messages.custom = App.str.format(MS0049, pageLangText.cd_shizai.text);
                        isValid = false;
                    } else if (result.d.length > 0 && result.d[0].cd_hinmei !== shizaiCode) {
                        validationSetting.cd_shizai.messages.custom = pageLangText.notFound.text;
                        isValid = false;
                    }
                    //else {
                    //    $("#nm_hinmei").text(result.d[0][hinName]);
                    //}
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                });
                return isValid;
            };

            /// <summary>品名コード入力チェック</summary>
            /// <param name="hinmeiCode">コード</param>
            var isValidHinmeiCode = function (hinmeiCode) {
                var isValid = true;

                var serviceUrl = getSeihinServiceUrl(hinmeiCode);
                App.ajax.webgetSync(
                    serviceUrl
                ).done(function (result) {
                    // !! 存在チェック
                    if (result.d.length == 0) {
                        // 検索結果件数が0件の場合
                        // 品名マスタ存在チェックエラー
                        //$("#nm_hinmei").text("");
                        //validationSetting.cd_hinmei.messages.custom = App.str.format(MS0049, pageLangText.cd_hinmei.text);
                        isValid = false;
                    }
                    //else {
                    //    $("#nm_hinmei").text(result.d[0][hinName]);
                    //}
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                });
                return isValid;
            };

            // 検索条件品名コード：カスタムバリデーション
            validationSetting.cd_hinmei.rules.custom = function (value) {
                //return isValidHinmeiCode(value);
                var isValidate = getCodeName(value);

                if (!isClickSave && !isClickSearch) {
                    // 版コンボボックスを作成する。
                    createdHanNoComboBox(value);
                }
                
                return isValidate;
            };

            // 資材コード：カスタムバリデーション
            validationSetting.cd_shizai.rules.custom = function (value) {
                return isValidShizaiCode(value);
            };

            // TODO: ここまで

            // グリッドのバリデーション設定
            var v = Aw.validation({
                items: validationSetting
            });
            // 有効日付のバリデーション設定
            var w = Aw.validation({
                items: validationSetting2,
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
            $(".vali-yuko-hizuke").validation(w);

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
                for (p in changeSetFirst.changeSet.created) {
                    if (!changeSetFirst.changeSet.created.hasOwnProperty(p)) {
                        continue;
                    }
                    // カレントの行バリデーションを実行
                    if (!validateRow(p)) {
                        return false;
                    }
                }
                for (p in changeSetFirst.changeSet.updated) {
                    if (!changeSetFirst.changeSet.updated.hasOwnProperty(p)) {
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

            /// <summary>品名ダイアログを起動する</summary>
            var showHinmeiDialog = function () {
                var option = { id: "hinmei", multiselect: false, param1: pageLangText.seihinJikagenHinDlgParam.text, ismishiyo: pageLangText.falseFlg.text };
                hinmeiDialog.draggable(true);
                hinmeiDialog.dlg("open", option);
            };

            /// <summary>資材一覧セレクタを起動する</summary>
            /// <param name="rowid">選択行ID</param>
            var showShizaiDialog = function (rowid) {
                // フォーカスを隣カラムへ移動させる(※値貼り付け後のバグ対策)
                $("#" + rowid + " td:eq('" + (grid.getColumnIndexByName("cd_shizai") + 1) + "')").click();
                var option = { id: 'shizai', multiselect: false, param1: pageLangText.shizaiHinDlgParam.text, ismishiyo: pageLangText.falseFlg.text };
                shizaiDialog.draggable(true);
                shizaiDialog.dlg("open", option);
            };

            /// <summary>検索条件変更チェックメッセージを出力します。</summary>
            /// <param name="outMessage">出力メッセージ</param>
            var showCriteriaChange = function (outMessage) {
                // 情報メッセージのクリア
                App.ui.page.notifyInfo.clear();
                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();
                var alertMessage = "";
                switch (outMessage) {
                    case "navigate":
                        alertMessage = pageLangText.navigate.text;
                        break;
                    case "rowChange":
                        alertMessage = pageLangText.rowChange.text;
                        break;
                    case "lineAdd":
                        alertMessage = pageLangText.lineAdd.text;
                        break;
                    case "lineDel":
                        alertMessage = pageLangText.lineDel.text;
                        break;
                    case "save":
                        alertMessage = pageLangText.save.text;
                        break;
                    case "del":
                        alertMessage = pageLangText.del.text;
                        break;
                    case "colchange":
                        alertMessage = pageLangText.colchange.text;
                        break;
                    case "output":
                        alertMessage = pageLangText.output.text;
                        break;
                    case "copy":
                        alertMessage = pageLangText.copy.text;
                        break;
                }
                // 情報メッセージ出力
                App.ui.page.notifyAlert.message(
                        App.str.format(pageLangText.criteriaChange.text, pageLangText.searchCriteria.text, alertMessage)
                ).show();
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
                    if (fnc == "save-button") {
                        checkSave();
                    }
                    else if (fnc == "find-button") {
                        checkSearch();
                    }
                    else if (fnc == "cd_hinmei") {
                        changeHinmeiCode();
                    }
                });
                deferred.resolve();
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
                if (!App.isUndefOrNull(grid.getCell(rowid, "body_ts")) && grid.getCell(rowid, "body_ts") != "") {
                    return false;
                }
                return true;
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

            /// <summary>検索条件品名コード検索ボタンクリック時のイベント処理を行います。</summary>
            $("#hinmei-button").on("click", function (e) {
                // 品名セレクタ起動
                showHinmeiDialog();
            });

            /// <summary>有効日付変更時の処理を行います。</summary>
            $("#id_dt_from").on("change", function () {
                setChangeSetSecond();
            });

            /// <summary>未使用フラグ変更時の処理を行います。</summary>
            $("#id_flg_mishiyo").on("change", function () {
                setChangeSetSecond();
                var yukoHizuke = $("#id_dt_from");
                var colModel = grid.getGridParam("colModel");
                if ($('#id_flg_mishiyo').prop('checked')) {
                    yukoHizuke.attr("readonly", true);
                    yukoHizuke.datepicker("option", "showOn", '');
                    colModel[grid.getColumnIndexByName("su_shiyo")].editable = false;
                }
                else {
                    yukoHizuke.attr("readonly", false);
                    yukoHizuke.datepicker("option", "showOn", 'focus');
                    colModel[grid.getColumnIndexByName("su_shiyo")].editable = true;
                }
            });

            /// <summary>版番号変更時の処理を行います。</summary>
            $("#id_no_han").on("change", function () {
                if (shinkiHanNo != $("#id_no_han").val()) {
                    isCreated = false;
                }
                else {
                    isCreated = true;
                }
            });

            /// <summary>検索条件/製品コードのイベント処理を行います。</summary>
            $("#id_cd_hinmei").dblclick(function () {
                // ダブルクリック時：品名ダイアログを開く
                showHinmeiDialog();
            })
            .change(function () {
                // 値変更時
                var hinCode = $("#id_cd_hinmei").val();
                if (hinCode == "") {
                    // 空の場合、製品名、荷姿を空白にし、版番号に初期値を設定する
                    clearSeihinInfo();
                }
                //else {
                //    // 製品名、荷姿、版番号の取得処理へ
                //    getCodeName(hinCode);
                //}
            });

            /// <summary>新規版を取得する</summary>
            var getShinkiHan = function () {
                var code = $("#id_cd_hinmei").val()
                    , _no_han = $("#id_no_han").val();

                App.ajax.webgetSync(
                    "../Services/FoodProcsService.svc/ma_shiyo_h?$filter=cd_hinmei eq '" + code + "'&$select=no_han&$orderby=no_han desc"
                ).done(function (result) {
                    if (!App.isUndefOrNull(result.d) && result.d.length > 0) {
                        shinkiHanNo = parseInt(result.d[0].no_han) + 1;
                        if (_no_han != shinkiHanNo && $("#no_han_max").text() != shinkiHanNo) {
                            var no_han = { d: [{ id: shinkiHanNo, name: shinkiHanNo}] };
                            App.ui.appendOptions($(".search-criteria [name='no_han']"), "id", "name", no_han.d, false);
                            $("#id_no_han").val(shinkiHanNo);
                            $("#no_han_max").text(shinkiHanNo);
                            // 新規フラグをセット
                            isCreated = true;
                            // isCriteriaChange = true;

                            // 有効日付の操作制御を設定する
                            ctrlYukoHizuke(shinkiHanNo);
                        }
                        else {
                            //                            isCriteriaChange = false;
                            App.ui.page.notifyInfo.message(MS0700).show();
                        }
                    }
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                }).always(function () {
                    App.ui.loading.close();
                });
                return shinkiHanNo;
            };

            /// <summary>資材検索ボタンクリック時のイベント処理を行います。</summary>
            $("#shizai-button").on("click", function (e) {
                if (checkShowDialog(rowid)) {
                    // 検索済であるかチェック
                    if (!isSearch) {
                        App.ui.page.notifyInfo.message(MS0621).show();
                        return;
                    }
                    // 検索条件変更チェック
                    if (isCriteriaChange) {
                        showCriteriaChange("navigate");
                        return;
                    }
                    // 各種チェック
                    if (!checkRecordCount()) {
                        return;
                    }
                    var rowid = getSelectedRowId(false);
                    if (checkShowDialog(rowid)) {
                        showShizaiDialog(rowid);
                    }
                }
            });

            /// <summary>資材削除ボタンクリック時のイベント処理を行います。</summary>
            $(".delete_shizai-button").on("click", function (e) {
                // 検索条件変更チェック
                if (isCriteriaChange) {
                    showCriteriaChange("del");
                    return;
                }
                // 検索済であるかチェック
                if (!isSearch) {
                    App.ui.page.notifyInfo.message(MS0621).show();
                    return;
                }
                // 削除確認ダイアログを表示する
                showDeleteConfirmDialog();
            });

            /// <summary>コピーボタン(新規版)クリック時のイベント処理を行います。</summary>
            $("#shinkiHan-button").on("click", function (e) {
                // 検索済であるかチェック
                if (!isSearch) {
                    App.ui.page.notifyInfo.message(MS0621).show();
                    return;
                }
                // 検索条件変更チェック
                if (isCriteriaChange) {
                    showCriteriaChange("copy");
                    return;
                }
                clearState();

                // 新規版を取得する
                getShinkiHan();
                // 有効日付にシステム日付をセットする
                $("#id_dt_from").datepicker("setDate", getDate());

                // ヘッダの新規版の内容を格納
                setChangeSetSecond();

                searchItemsShinkiHan();
            });

            /// <summary>新規版を取得します。</summary>
            var searchItemsShinkiHan = function () {
                var criteria = $(".search-criteria").toJSON(),
                    query = {
                        url: "../api/ShizaiShiyoMaster"
                        , cd_hinmei: criteria.cd_hinmei
                        , no_han: criteria.no_han
                        , top: querySetting.top
                    };
                App.ajax.webgetSync(
                    App.data.toWebAPIFormat(query)
                ).done(function (result) {
                    // 検索フラグを立てる
                    isSearch = true;
                    if (result.__count > 0) {
                        // データバインド
                        bindDataShinkiHan(result);
                        for (var i = 0; i < result.__count; i++) {
                            changeSetFirst.addCreated(i + 1, setCreatedChangeDataFirst(result.d[i]));
                        }
                    }
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                    App.ui.loading.close();
                });
            };

            /// <summary>データをバインドします。</summary>
            /// <param name="result">検索結果</param>
            var bindDataShinkiHan = function (result) {
                grid.setGridParam({ rowNum: querySetting.top });
                var resultCount = parseInt(result.__count);
                if (resultCount > querySetting.top) {
                    App.ui.page.notifyInfo.message(
                        App.str.format(MS0568, resultCount, querySetting.top)).show();
                    querySetting.count = querySetting.top;
                }
                else {
                    querySetting.count = resultCount;
                }
                displayCount(resultCount);
                var currentData = grid.getGridParam("data").concat(result.d);
                grid.setGridParam({ data: currentData }).trigger('reloadGrid', [{ current: true}]);
                App.ui.page.notifyInfo.message(App.str.format(
                    pageLangText.searchResultCount.text, querySetting.count, resultCount)).show();
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

            // 検索条件に変更が発生した場合
            $(".search-criteria").on("change", function () {
                // 検索後の状態で検索条件が変更された場合
                if (isSearch) {
                    isCriteriaChange = true;
                }
            });

            /// <summary>画面リサイズ時のイベント処理を行います。</summary>
            $(App.ui.page).on("resized", resizeContents);

            /// <summary>保存確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".save-confirm-dialog .dlg-yes-button").on("click", saveData);
            /// <summary>保存確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".save-confirm-dialog .dlg-no-button").on("click", function () {
                // ローディングの終了
                //App.ui.loading.close();
                closeSaveConfirmDialog();
            });
            /// <summary>削除確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".delete-confirm-dialog .dlg-yes-button").on("click", deleteShizaiData);
            /// <summary>削除確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".delete-confirm-dialog .dlg-no-button").on("click", function () {
                // ローディングの終了
                App.ui.loading.close();
                closeDeleteConfirmDialog();
            });

            /// <summary>検索確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".find-confirm-dialog .dlg-yes-button").on("click", function () {
                clearState();
                loading(pageLangText.nowProgressing.text, "find-button");
            });
            /// <summary>検索確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".find-confirm-dialog .dlg-no-button").on("click", function () {
                // ローディングの終了
                App.ui.loading.close();
                closeFindConfirmDialog();
            });

            /// <summary>データに変更があり、未保存の状態でページを離れる際に確認を行います。</summary>
            /// 別画面に遷移したりするときに実行する関数の定義
            var onBeforeUnload = function () {
                //データを変更したかどうかは各画面でチェックし、保持する
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
                }
            };
            /// <summary>メニューボタンクリック時のイベント処理を行います。</summary>
            $(".menu-button").on("click", backToMenu);

            // 品名マスタから遷移してきたとき用の処理
            $("#id_cd_hinmei").val(hinmeiCode);

            //getCodeName(hinmeiCode);

            // 版コンボボックスを作成する。
            //createdHanNoComboBox(hinmeiCode);

            // 製品が存在する場合
            if (getCodeName(hinmeiCode)) {

                // 版コンボボックスを作成する。
                createdHanNoComboBox(hinmeiCode);
            }
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
                    <table>
                        <tr>
                            <td style="width: 480px;">
                                <span class="item-label" data-app-text="cd_hinmei"></span>
                                <input type="text" name="cd_hinmei" id="id_cd_hinmei" />
                                <button type="button" class="dialog-button" name="hinmei-button" id="hinmei-button">
                                    <span class="icon"></span><span data-app-text="codeSearch"></span>
                                </button>
                            </td>
                            <td style="width: 30px;">&nbsp;</td>
                            <td style="width: 400px;">
                                <span class="item-label" data-app-text="nm_han"></span>
                                <select class="no_han_select" name="no_han" id="id_no_han"></select>
                                <span class="conditionname-label" data-app-text="slash"></span>
                                <span class="conditionname-label" id="no_han_max"></span>
                                <button type="button" class="dialog-button" name="shinkiHan-button" id="shinkiHan-button" data-app-operation="shinkiHan">
                                    <span data-app-text="nm_shinki_han"></span>
                                </button>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <span class="item-label" data-app-text="nm_hinmei"></span>
                                <span class="conditionname-label" id="nm_hinmei"></span>
                            </td>
                            <td>&nbsp;</td>
                            <td>
                                <span class="item-label" data-app-text="nm_nisugata_hyoji"></span>
                                <span class="conditionname-label" id="nm_nisugata_hyoji"></span>
                            </td>
                        </tr>
                    </table>
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
        <h3 id="listHeader" class="part-header" >
            <span data-app-text="_meisaiTitle" style="padding-right: 10px;"></span>
            <span class="list-count" id="list-count" ></span>
            <span style="" class="list-loading-message" id="list-loading-message" ></span>
        </h3>
        <div class="part-body">
            <ul class="item-list">
                <li>
                    <label class="vali-yuko-hizuke">
                        <span class="item-label" data-app-text="dt_from"></span>
                        <input type="text" name="dt_from" id="id_dt_from" class="data-app-format" data-app-format="date" />
                        <input type="hidden" name="ts" id="id_ts" />
                    </label>
                    <label>
                        <span class="item-label" data-app-text="notUse"></span>
                        <input type="checkbox" name="flg_mishiyo" id="id_flg_mishiyo" />
                        <span class="item-label" data-app-text="flg_mishiyo"></span>
                    </label>
                </li>
            </ul>
        </div>
        <!-- グリッドコントロール固有のデザイン -- Start -->
        <div class="part-body" id="result-grid">
            <div class="item-command">
                <button type="button" class="colchange-button" data-app-operation="colchange">
                    <span class="icon"></span><span data-app-text="colchange"></span>
                </button>
                <button type="button" class="add-button" name="add-button" data-app-operation="add">
                    <span class="icon"></span><span data-app-text="add"></span>
                </button>
                <button type="button" class="delete-button" name="delete-button" data-app-operation="del">
                    <span class="icon"></span><span data-app-text="del"></span>
                </button>
                <button type="button" class="dialog-button" id="shizai-button" name="shizaiIchiran" data-app-operation="shizai">
                    <span class="icon"></span><span data-app-text="shizaiIchiran"></span>
                </button>
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
        <button type="button" class="save-button" name="save-button" data-app-operation="save"><span class="icon"></span><span data-app-text="save"></span></button>
        <%--<button type="button" class="copy-button" name="copy_shizai" data-app-operation="copy"><span data-app-text="copy"></span></button>--%>
        <button type="button" class="delete_shizai-button" name="delete_shizai" data-app-operation="delete_shizai"><span data-app-text="delete_shizai"></span></button>
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
    <!-- TODO: 画面の仕様に応じて以下のダイアログの設定を変更してください。 -->
    <div class="hinmei-dialog">
    </div>
    <div class="shizai-dialog">
    </div>
    <!-- 資材削除確認コンファーム -->
    <div class="delete-confirm-dialog" style="display: none;">
        <div class="dialog-header">
            <h4 data-app-text="confirmTitle"></h4>
        </div>
        <div class="dialog-body" style="padding: 10px; width: 100%;">
            <div class="part-body">
                <span data-app-text="deleteShizaiConfirm"></span>
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
    <!-- 保存確認コンファーム -->
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
            <div class="command" style="position: absolute; left: 10px; top: 5px">
                <button class="dlg-yes-button" name="dlg-yes-button" data-app-text="yes"></button>
            </div>
            <div class="command" style="position: absolute; right: 5px; top: 5px;">
                <button class="dlg-no-button" name="dlg-no-button" data-app-text="no"></button>
            </div>
        </div>
    </div>
    <!-- 検索確認コンファーム -->
    <div class="find-confirm-dialog" style="display: none;">
        <div class="dialog-header">
            <h4 data-app-text="confirmTitle"></h4>
        </div>
        <div class="dialog-body" style="padding: 10px; width: 100%;">
            <div class="part-body">
                <span data-app-text="findConfirm"></span>
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
