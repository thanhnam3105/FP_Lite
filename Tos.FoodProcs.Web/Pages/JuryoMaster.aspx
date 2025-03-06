<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="JuryoMaster.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.JuryoMaster" %>

<asp:Content ID="Content1" ContentPlaceHolderID="IncludeContent" runat="server">
    <script src="<%=ResolveUrl("~/Resources/pages/pagedata-juryomaster." + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
    <script src="<%=ResolveUrl("~/Resources/grid/grid.locale-" + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        /* 画面デザイン -- Start */
        
        /* TODO：画面の仕様に応じて以下のスタイルを変更してください。 */
        
        .search-criteria .item-label
        {
            width: 8em;
        }
        
        .pad-apace
        {
            padding-left: 3em;
        }
        
        .hinmei-dialog {
            background-color: White;
            width: 550px;
        } 
        
        .hinmei-dialog2 {
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

            // 画面アーキテクチャ共通の変数宣言
            var pageLangText = App.ui.pagedata.lang(App.ui.page.lang),
                validationSetting = App.ui.pagedata.validation(App.ui.page.lang),
                querySetting = { skip: 0, top: 500, count: 0 },
                isDataLoading = false,
                userRoles = App.ui.page.user.Roles[0];

            // グリッドコントロール固有の変数宣言
            var grid = $("#item-grid"),
                lastScrollTop = 0,
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
                changeSet = new App.ui.page.changeSet(),
                firstCol = 1,
                duplicateCol = 999,
                currentRow = 0,
                currentCol = firstCol,
                hinmeiCodeCol = 1,
                hinmeiNameCol = 2,
                nextScrollTop = 0;

            // チェックボックスを直接編集した際に値が反映されない問題の回避策
            // チェックボックスを使用した列のcolModelに以下オプションを追加してください
            // "formatter: fn_formatValue, unformat: fn_unformatValue"
            var fn_formatValue = function (celldata, options, rowobject) {
                showdata = options.colModel.editoptions.value()[celldata];
                return $(document.createElement('span')).attr('original-value', celldata).text(showdata)[0].outerHTML;
            };

            var fn_unformatValue = function (celldata, options, cellobject) {
                return $(cellobject).children('span').attr('original-value');
            };

            // TODO: ここまで

            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            var kbn_jotai
                , kbn_hin
                , searchCriteriaSetting = { kbn_jotai: null
                                    , kbn_hin: null
                                    , cd_hinmei_kensaku: null
                }
                , loading;

            //// コントロール定義 -- Start

            // ダイアログ固有の変数宣言
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            var saveConfirmDialog = $(".save-confirm-dialog"),
                findConfirmDialog = $(".find-confirm-dialog");

            var hinmeiDialog = $(".hinmei-dialog");
            var hinmeiDialog2 = $(".hinmei-dialog2");

            // ダイアログ固有のコントロール定義
            saveConfirmDialog.dlg();
            findConfirmDialog.dlg();

            /// <summary>保存確認ダイアログを開きます。</summary>
            var showSaveConfirmDialog = function () {
                saveConfirmDialogNotifyInfo.clear();
                saveConfirmDialogNotifyAlert.clear();
                saveConfirmDialog.draggable(true);
                saveConfirmDialog.dlg("open");
            };
            /// <summary>検索確認ダイアログを開きます。</summary>
            var showFindConfirmDialog = function () {
                findConfirmDialogNotifyInfo.clear();
                findConfirmDialogNotifyAlert.clear();
                findConfirmDialog.draggable(true);
                findConfirmDialog.dlg("open");
            };
            /// <summary>検索確認ダイアログを閉じます。</summary>
            var closeFindConfirmDialog = function () {
                findConfirmDialog.dlg("close");
            };
            /// <summary>保存確認ダイアログを閉じます。</summary>
            var closeSaveConfirmDialog = function () {
                saveConfirmDialog.dlg("close");
            };

            hinmeiDialog.dlg({
                url: "Dialog/HinmeiDialog.aspx",
                name: "HinmeiDialog",
                closed: function (e, data, data2) {
                    if (data == "canceled") {
                        return;
                    }
                    else {
                        $(".search-criteria [name='cd_hinmei_kensaku']").val(data);
                        $("#condition-nm_hinmei").text(data2);
                        clearMessage();
                    }
                }
            });

            hinmeiDialog2.dlg({
                url: "Dialog/HinmeiDialog.aspx",
                name: "HinmeiDialog",
                closed: function (e, data, data2) {
                    if (data == "canceled") {
                        return;
                    }
                    else {
                        var selectedRowId = getSelectedRowId(false);
                        grid.setCell(selectedRowId, "cd_hinmei", data);
                        grid.setCell(selectedRowId, "nm_hinmei", data2);

                        // 更新状態の変更セットに変更データを追加
                        var changeData = setCreatedChangeData(grid.getRowData(selectedRowId));
                        changeSet.addUpdated(selectedRowId, "cd_hinmei", data, changeData);
                        clearMessage();
                    }
                }
            });

            // ダイアログ情報メッセージの設定
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
            // ダイアログ警告メッセージの設定
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

            /// 品名ダイアログを開く
            var showHinmeiDialogGrid = function () {
                var criteria = $(".search-criteria").toJSON();
                var jotaiKbn = criteria.kbn_jotai;
                var hinKbn = criteria.kbn_hin;
                if (jotaiKbn === pageLangText.sonotaJotaiKbn.text) {
                    if (selectCol === hinmeiCodeCol || selectCol === hinmeiNameCol) {
                        //$("#" + getSelectedRowId(false) + " td:eq('" + (selectCol + 1) + "')").click();
                        saveEdit();
                        openHinmeiDialog("hinmei2", hinKbn, hinmeiDialog2);
                    }
                }
            };

            /// 品名ダイアログを開く
            var showHinmeiDialog = function () {
                var criteria = $(".search-criteria").toJSON();
                var hinKbn = criteria.kbn_hin;
                openHinmeiDialog("hinmei", hinKbn, hinmeiDialog);
            };

            /// 品名ダイアログを起動する
            var openHinmeiDialog = function (dlgName, hinKbn, dialog) {
                var option;
                switch (hinKbn) {
                    case pageLangText.genryoHinKbn.text:
                        option = { id: dlgName, multiselect: false, param1: pageLangText.genryoHinDlgParam.text };
                        break;
                    case pageLangText.shikakariHinKbn.text:
                        option = { id: dlgName, multiselect: false, param1: pageLangText.shikakariHinDlgParam.text };
                        break;
                    default:
                        break;
                }
                dialog.draggable(true);
                dialog.dlg("open", option);
            };

            /// <summary>検索条件を保持する</summary>
            var saveSearchCriteria = function () {
                var criteria = $(".search-criteria").toJSON();
                searchCriteriaSetting = {
                    "kbn_jotai": criteria.kbn_jotai,
                    "kbn_hin": criteria.kbn_hin,
                    "cd_hinmei_kensaku": criteria.cd_hinmei_kensaku
                };
            };

            // 日付の多言語対応
            var newDateFormat = pageLangText.dateTimeNewFormatUS.text;
            if (App.ui.page.langCountry !== 'en-US') {
                newDateFormat = pageLangText.dateTimeNewFormat.text;
            }

            // グリッドコントロール固有のコントロール定義
            var selectCol;
            grid.jqGrid({
                // TODO：画面の仕様に応じて以下の列名の定義を変更してください。
                colNames: [
                    pageLangText.cd_hinmei.text,
                    pageLangText.nm_hinmei.text,
                    pageLangText.wt_kowake.text + pageLangText.requiredMark.text,
                    pageLangText.kbn_jotai.text,
                    pageLangText.kbn_hin.text,
                    pageLangText.dt_create.text,
                    pageLangText.cd_create.text,
                    pageLangText.ts.text
                ],
                // TODO：ここまで
                // TODO：画面の仕様に応じて以下の列モデルの定義を変更してください。
                colModel: [
                    { name: 'cd_hinmei', width: pageLangText.cd_hinmei_width.number, hidden: false, editable: true, sorttype: "text" },
                    { name: 'nm_hinmei', width: pageLangText.nm_hinmei_width.number, hidden: false, editable: false, sorttype: "text" },
                    { name: 'wt_kowake', width: pageLangText.wt_kowake_width.number, hidden: false, editable: true, sorttype: "float", align: "right",
                        formatter: 'number',
                        formatoptions: {
                            decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 6, defaultValue: ""
                        }
                    },
                    { name: 'kbn_jotai', width: 0, hidden: true, hidedlg: true },
                    { name: 'kbn_hin', width: 0, hidden: true, hidedlg: true },
                    { name: 'dt_create', width: 0, hidden: true, hidedlg: true,
                        formatter: "date",
                        formatoptions: {
                            srcformat: newDateFormat, newformat: newDateFormat
                        }
                    },
                    { name: 'cd_create', width: 0, hidden: true, hidedlg: true },
                    { name: 'ts', width: 0, hidden: true, hidedlg: true }
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
                loadComplete: function () {
                    var ids = grid.jqGrid('getDataIDs');
                    for (var i = 0; i < ids.length; i++) {
                        var id = ids[i];
                        // TODO：画面の仕様に応じて以下の操作可否の定義を変更してください。
                        if (grid.jqGrid('getCell', id, 'ts')) {
                            grid.jqGrid('setCell', id, 'cd_hinmei', '', 'not-editable-cell');
                        }
                        // TODO：ここまで
                    }
                },
                gridComplete: function () {
                    // 検索条件を保持する
                    saveSearchCriteria();
                    // スクロールを保持した位置に戻す
                    grid.closest(".ui-jqgrid-bdiv").scrollTop(nextScrollTop);

                    // グリッドの先頭行選択
                    // gridCompleteまたはloadCompleteに記述しないとグリッドのソートで先頭行が選択されない
                    var idNum = grid.getGridParam("selrow");
                    if (idNum == null) {
                        $("#1 > td").click();
                    }
                    else {
                        $("#" + idNum).removeClass("ui-state-highlight").find("td").click();
                    }
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
                    var changeData = setUpdatedChangeData(grid.getRowData(selectedRowId));
                    // 更新状態の変更セットに変更データを追加
                    changeSet.addUpdated(selectedRowId, cellName, value, changeData);
                    // 関連項目の設定を変更セットに反映
                    setRelatedChangeData(selectedRowId, cellName, value, changeData);
                },
                onCellSelect: function (rowid, icol, cellcontent) {
                    selectCol = icol;
                },
                ondblClickRow: function (rowid) {
                    if (userRoles === pageLangText.viewer.text
                            || grid.jqGrid('getCell', getSelectedRowId(false), 'ts') != "") {
                        return;
                    }
                    else {
                        showHinmeiDialogGrid();
                    }
                }
            });
            /// <summary>セルの関連項目を設定します。</summary>
            /// <param name="selectedRowId">選択行ID</param>
            /// <param name="cellName">列名</param>
            /// <param name="value">元となる項目の値</param>
            /// <param name="iCol">項目の列番号</param>
            var setRelatedValue = function (selectedRowId, cellName, value, iCol) {
                var serviceUrl,
                    elementCode,
                    elementName,
                    codeName;
                var criteria = $(".search-criteria").toJSON();
                var hinKbn = criteria.kbn_hin;
                switch (hinKbn) {
                    case pageLangText.genryoHinKbn.text:
                        serviceUrl = "../Services/FoodProcsService.svc/ma_hinmei()?$filter=cd_hinmei eq '" + grid.getCell(selectedRowId, "cd_hinmei")
                                        + "'and kbn_hin eq " + parseInt(hinKbn, 10) + "&$top=1";
                        elementCode = "cd_hinmei";
                        elementName = "nm_hinmei_" + App.ui.page.lang;
                        break;
                    case pageLangText.shikakariHinKbn.text:
                        serviceUrl = "../Services/FoodProcsService.svc/ma_haigo_mei()?$filter=cd_haigo eq '" + grid.getCell(selectedRowId, "cd_hinmei")
                                        + "' and no_han eq " + pageLangText.hanNoShokichi.text + "&$top=1";
                        elementCode = "cd_haigo";
                        elementName = "nm_haigo_" + App.ui.page.lang;
                        break;
                    default:
                        serviceUrl = "";
                        elementCode = "";
                        elementName = "";
                        return;
                }
                App.deferred.parallel({
                    // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                    codeName: App.ajax.webget(serviceUrl)
                    // TODO: ここまで
                }).done(function (result) {
                    // TODO: 画面の仕様に応じて以下のサービス呼び出し成功時の処理を変更してください。
                    var row = grid.getRowData(selectedRowId);
                    codeName = result.successes.codeName.d;
                    if (codeName.length > 0) {
                        grid.setCell(selectedRowId, "nm_hinmei", codeName[0][elementName]);
                    }
                    else {
                        grid.setCell(selectedRowId, "nm_hinmei", null);
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
            $(function () {
                if (userRoles === pageLangText.viewer.text) {
                    $(".add-button").css("display", "none");
                    $(".delete-button").css("display", "none");
                    $(".hinmei-button").css("display", "none");
                    $(".save-button").css("display", "none");
                }
            });

            //// 操作制御定義 -- End

            //// 事前データロード -- Start 

            // 画面アーキテクチャ共通の事前データロード

            // TODO: 画面の仕様に応じて以下の処理を変更してください。
            // 検索用ドロップダウンの設定
            /// 状態区分コンボ取得
            App.deferred.parallel({
                loading: App.ui.loading.show(pageLangText.nowProgressing.text),

                kbn_jotai: App.ajax.webget("../Services/FoodProcsService.svc/ma_kbn_jotai()")
            }).done(function (result) {
                kbn_jotai = result.successes.kbn_jotai.d;
                // 検索用ドロップダウンの設定
                App.ui.appendOptions($(".search-criteria [name='kbn_jotai']"), "kbn_jotai", "nm_kbn_jotai", kbn_jotai, false);
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
            /// 品区分コンボ取得
            var createKbnHinCombobox = function () {
                App.deferred.parallel({
                    kbn_hin: App.ajax.webget("../Services/FoodProcsService.svc/ma_kbn_hin?$filter=kbn_hin eq " + pageLangText.genryoHinKbn.text + " or kbn_hin eq " + pageLangText.shikakariHinKbn.text)
                }).done(function (result) {
                    kbn_hin = result.successes.kbn_hin.d;
                    // 検索用ドロップダウンの設定
                    $(".search-criteria [name='kbn_hin'] > option").remove();
                    App.ui.appendOptions($(".search-criteria [name='kbn_hin']"), "kbn_hin", "nm_kbn_hin", kbn_hin, false);
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

            // TODO: ここまで

            //// 事前データロード -- End

            //// 検索処理 -- Start

            // 状態区分に応じて品名コードを取得
            var getHinmeiCode = function (jotaiKbn, hinmeiCd) {
                if (pageLangText.sonotaJotaiKbn.text != jotaiKbn) {
                    return pageLangText.hinCodeMitorokuchi.text;
                }
                return hinmeiCd;
            };
            // 状態区分に応じて品区分を取得
            var getHinKubun = function (obj) {
                switch (obj.kbn_jotai) {
                    case pageLangText.shikakariJotaiKbn.text:
                        return pageLangText.shikakariHinKbn.text;
                        break;
                    case pageLangText.sonotaJotaiKbn.text:
                        return obj.kbn_hin;
                        break;
                    default:
                        return pageLangText.genryoHinKbn.text;
                        break;
                }
            };

            // 画面アーキテクチャ共通の検索処理

            /// <summary>クエリオブジェクトの設定</summary>
            var queryWeb = function () {
                var criteria = $(".search-criteria").toJSON();
                var query = {
                    // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                    url: "../api/JuryoMaster"
                    // TODO: ここまで
                    // TODO: 画面の仕様に応じて検索条件を変更してください。
                    , kbn_jotai: criteria.kbn_jotai
                    , kbn_hin: getHinKubun(criteria)
                    , cd_hinmei: getHinmeiCode(criteria.kbn_jotai, criteria.cd_hinmei_kensaku)
                    , lang: "<%=System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName %>"
                    // TODO: ここまで
                    , skip: querySetting.skip
                    , top: querySetting.top
                };
                return query;
            };

            /// <summary>フィルター条件の設定</summary>
            var createFilter = function () {
                var criteria = $(".search-criteria").toJSON(),
                    filters = [];

                if (criteria.kbn_jotai !== pageLangText.sonotaJotaiKbn.text) {
                    // TODO: 画面の仕様に応じて以下のフィルター条件を変更してください。
                    filters.push("kbn_jotai eq " + parseInt(criteria.kbn_jotai));
                }
                else {
                    filters.push("kbn_jotai eq " + parseInt(criteria.kbn_jotai));

                    if (!App.isUndefOrNull(criteria.kbn_hin) && criteria.kbn_hin.length > 0) {
                        filters.push("kbn_hin eq " + parseInt(criteria.kbn_hin));
                    }

                    if (!App.isUndefOrNull(criteria.cd_hinmei_kensaku) && criteria.cd_hinmei_kensaku.length > 0) {
                        filters.push("cd_hinmei eq '" + criteria.cd_hinmei_kensaku + "'");
                    }
                }
                // TODO: ここまで

                return filters.join(" and ");
            };
            /// <summary>検索条件の変更チェック</summary>
            //            var noChangeCriteria = function () {
            //                var criteria = $(".search-criteria").toJSON();

            //                if (App.isUndefOrNull(searchCriteriaSet) || searchCriteriaSet === ""
            //                        || (criteria.kbn_jotai === searchCriteriaSet.kbn_jotai
            //                            && criteria.kbn_hin === searchCriteriaSet.kbn_hin
            //                            && criteria.cd_hinmei_kensaku === searchCriteriaSet.cd_hinmei_kensaku)) {
            //                    return true;
            //                }
            //                return false;

            //            };
            /// <summary>データ検索を行います。</summary>
            /// <param name="query">クエリオブジェクト</param>
            var searchItems = function (query) {
                closeFindConfirmDialog();
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
                // スクロール位置保持
                nextScrollTop = $(".ui-jqgrid-bdiv").scrollTop();
                App.ajax.webget(
                    App.data.toWebAPIFormat(query)
                ).done(function (result) {
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
                if (!noChange()) {
                    showFindConfirmDialog();
                }
                else {
                    clearState();
                    var criteria = $(".search-criteria").toJSON();
                    if (criteria.kbn_jotai === pageLangText.sonotaJotaiKbn.text) {
                        // 検索前バリデーション
                        // 品区分のバリデーションは検索時不要なため、メッセージを一旦削除する
                        validationSetting.kbn_hin.messages.custom = "";
                        var result = $(".part-body .item-list").validation().validate();
                        validationSetting.kbn_hin.messages.custom = App.str.format(MS0049, pageLangText.cd_hinmei_kensaku.text);
                        if (result.errors.length) {
                            return;
                        }
                    }
                    searchItems(new queryWeb());
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

            /// メッセージをクリアする
            var clearMessage = function () {
                // 情報メッセージのクリア
                App.ui.page.notifyInfo.clear();
                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();
            };

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
            var displayCount = function (resultCount) {
                if (App.isUndefOrNull(resultCount)) {
                    resultCount = 0;
                }
                $("#list-count").text(
                     App.str.format("{0}/{1} " + pageLangText.itemCount.text, querySetting.count, resultCount)
                );
            };
            /// <summary>データをバインドします。</summary>
            /// <param name="result">検索結果</param>
            var bindData = function (result) {
                // グリッドの表示件数を更新
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
                // データバインド
                var currentData = grid.getGridParam("data").concat(result.d);
                grid.setGridParam({ data: currentData }).trigger('reloadGrid', [{ current: true}]);
                App.ui.page.notifyInfo.message(
                     App.str.format(pageLangText.searchResultCount.text, querySetting.count, resultCount)
                ).show();
            };

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
            }
            /// <summary>エラー一覧クリック時の処理を行います。</summary>
            /// <param name="data">エラー情報</param>
            var handleNotifyAlert = function (data) {
                //data.unique でキーが取得できる
                //data.handledにtrueを指定することでデフォルトの動作(キーがHTMLElementの場合にフォーカスを当てる処理)の実行をキャンセルする
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
                        App.ui.page.notifyInfo.message(pageLangText.noRecords.text).show();
                    }
                    return;
                }
                // 選択行なしの場合、先頭行を選択
                if (App.isUnusable(selectedRowId)) {
                    selectedRowId = ids[0];
                }
                currentRow = $('#' + selectedRowId)[0].rowIndex;

                return selectedRowId;
            };
            /// <summary>新規行データの設定を行います。</summary>
            var setAddData = function () {
                // TODO: 画面の仕様に応じて以下の項目を変更してください。
                var criteria = $(".search-criteria").toJSON()
                    , kbn_jotai = criteria.kbn_jotai
                    , kbn_hin = getHinKubun(criteria)
                    , cd_hinmei = getHinmeiCode(criteria.kbn_jotai, criteria.cd_hinmei_kensaku);
                var addData = {
                    "kbn_jotai": kbn_jotai,
                    "kbn_hin": kbn_hin,
                    "cd_hinmei": cd_hinmei,
                    "nm_hinmei": setHinmei(kbn_hin, cd_hinmei, true),
                    "wt_kowake": null
                };

                // TODO: ここまで

                return addData;
            };

            /// <summary>追加状態の変更セットに追加する変更データの設定を行います。</summary>
            /// <param name="newRow">新規行データ</param>
            var setCreatedChangeData = function (newRow) {
                // TODO: 画面の仕様に応じて以下の項目を変更してください。
                var changeData = {
                    "kbn_jotai": newRow.kbn_jotai,
                    "kbn_hin": getHinKubun(newRow),
                    "cd_hinmei": getHinmeiCode(newRow.kbn_jotai, newRow.cd_hinmei),
                    "wt_kowake": newRow.wt_kowake,
                    "cd_create": App.ui.page.user.Code,
                    "cd_update": App.ui.page.user.Code
                };
                // TODO: ここまで

                return changeData;
            };
            /// <summary>更新状態の変更セットに追加する変更データの設定を行います。</summary>
            /// <param name="row">選択行</param>
            var setUpdatedChangeData = function (row) {
                // TODO: 画面の仕様に応じて以下の項目を変更してください。
                var changeData = {
                    "kbn_jotai": row.kbn_jotai,
                    "kbn_hin": row.kbn_hin,
                    "cd_hinmei": row.cd_hinmei,
                    "wt_kowake": row.wt_kowake,
                    "dt_create": App.date.localDate(row.dt_create),
                    "cd_create": row.cd_create,
                    "cd_update": App.ui.page.user.Code,
                    "ts": row.ts
                };
                // TODO: ここまで

                return changeData;
            };
            /// <summary>削除状態の変更セットに追加する変更データの設定を行います。</summary>
            /// <param name="row">選択行</param>
            var setDeletedChangeData = function (row) {
                // TODO: 画面の仕様に応じて以下の項目を変更してください。
                var changeData = {
                    "kbn_jotai": row.kbn_jotai,
                    "kbn_hin": row.kbn_hin,
                    "cd_hinmei": row.cd_hinmei,
                    "ts": row.ts
                };
                // TODO: ここまで

                return changeData;
            };
            /// <summary>関連項目の設定を変更セットに反映します。</summary>
            /// <param name="selectedRowId">選択行ID</param>
            /// <param name="cellName">列名</param>
            /// <param name="value">元となる項目の値</param>
            var setRelatedChangeData = function (selectedRowId, cellName, value, changeData) {
                // TODO: 画面の仕様に応じて以下の処理を変更してください。
                // TODO: ここまで
            };


            /// <summary>行を削除します。</summary>
            /// <param name="e">イベントデータ</param>
            var deleteData = function (e) {
                // 情報メッセージのクリア
                App.ui.page.notifyInfo.clear();
                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();

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
                var changeData = setDeletedChangeData(grid.getRowData(selectedRowId));
                // 削除状態の変更セットに変更データを追加
                changeSet.addDeleted(selectedRowId, changeData);
                // 選択行の行データ削除
                grid.delRowData(selectedRowId);
                if (grid.getGridParam("records") > 0) {
                    // セルを選択して入力モードにする
                    grid.editCell(currentRow === 1 ? currentRow : currentRow - 1, currentCol, true);
                }
            };
            /// <summary>削除ボタンクリック時のイベント処理を行います。</summary>
            $(".delete-button").on("click", deleteData);

            /// <summary>新規行を追加します。</summary>
            /// <param name="e">イベントデータ</param>
            var addData = function (e) {
                clearMessage();
                // 選択行のID取得
                var selectedRowId = getSelectedRowId(true),
                    position = "after";

                var criteria = $(".search-criteria").toJSON();
                if (criteria.kbn_jotai !== pageLangText.sonotaJotaiKbn.text
                        || !App.isUndefOrNull(criteria.cd_hinmei_kensaku)) {
                    if (grid.getGridParam("records") > 0) {
                        // 既に1行存在する場合、追加不可
                        App.ui.page.notifyAlert.message(MS0052).show();
                        return;
                    }
                }

                // 新規行データの設定
                var newRowId = App.uuid()
                    , addData = setAddData();
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
                changeSet.addCreated(newRowId, setCreatedChangeData(addData));
                // セルを選択して入力モードにする
                if (criteria.kbn_jotai === pageLangText.sonotaJotaiKbn.text) {
                    grid.editCell(currentRow + 1, firstCol, true);
                }
                else {
                    grid.editCell(currentRow + 1, firstCol + 2, true);
                    //状態区分＝「その他」以外は入力不可
                    grid.jqGrid('setCell', newRowId, 'cd_hinmei', '', 'not-editable-cell');
                }
                selectCol = firstCol;
            };

            /// <summary>追加ボタンボタンクリック時のイベント処理を行います。</summary>
            $(".add-button").on("click", addData);

            //// データ変更処理 -- End

            //// 保存処理 -- Start

            // グリッドコントロール固有の保存処理

            // <summary>データに変更がないかどうかを返します。</summary>
            var noChange = function () {
                return (App.isUnusable(changeSet) || changeSet.noChange());
            };
            /// <summary>編集内容の保存</summary>
            var saveEdit = function () {
                grid.saveCell(currentRow, currentCol);
            };
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
                        // TODO: 画面の仕様に応じて以下の値を変更します。
                        if (ret[i].InvalidationName === "NotExsists") {
                            // TODO: ここまで

                            for (var j = 0; j < ids.length; j++) {
                                // TODO: 画面の仕様に応じて以下の値を変更します。
                                value = grid.getCell(ids[j], checkCol);
                                retValue = ret[i].Data.cd_hinmei;
                                ts = grid.getCell(ids[j], "ts");
                                // TODO: ここまで

                                if (value === retValue && !ts) {
                                    // TODO: 画面の仕様に応じて以下のロジックを変更します。
                                    unique = ids[j] + "_" + checkCol;

                                    // エラーメッセージの表示
                                    App.ui.page.notifyAlert.message(
                                        pageLangText.invalidation.text + ret[i].Message, unique).show();
                                    // 対象セルの背景変更
                                    grid.setCell(ids[j], firstCol, ret[i].Data.cd_hinmei, { background: '#ff6666' });
                                    // TODO: ここまで
                                }
                            }
                        }
                        else {
                            // 更新オブジェクトから削除を行う
                            for (p in changeSet.changeSet.deleted) {
                                if (!changeSet.changeSet.deleted.hasOwnProperty(p)) {
                                    continue;
                                }

                                // TODO: 画面の仕様に応じて以下の値を変更します。
                                value = changeSet.changeSet.deleted[p].cd_hinmei;
                                retValue = ret.Data.cd_hinmei;
                                // TODO: ここまで

                                if (isNaN(value) || value === retValue) {
                                    // 削除状態の変更セットから変更データを削除
                                    changeSet.removeDeleted(p);

                                    // エラーメッセージの表示
                                    App.ui.page.notifyAlert.message(
                                        pageLangText.unDeletableRecord.text + ret[i].Message).show();
                                }
                            }
                        }
                    }
                }
                // 更新時同時実行制御エラーのハンドリングを行います。
                if (!App.isUndefOrNull(ret.Updated) && ret.Updated.length > 0) {
                    for (var i = 0; i < ret.Updated.length; i++) {
                        for (p in changeSet.changeSet.updated) {
                            if (!changeSet.changeSet.updated.hasOwnProperty(p)) {
                                continue;
                            }

                            // TODO: 画面の仕様に応じて以下の値を変更します。
                            value = grid.getCell(p, checkCol);
                            retValue = ret.Updated[i].Requested.cd_hinmei;
                            // TODO: ここまで

                            if (isNaN(value) || value === retValue) {
                                // 更新状態の変更セットから変更データを削除
                                changeSet.removeUpdated(p);

                                // 他のユーザーによって削除されていた場合
                                if (App.isUndefOrNull(ret.Updated[i].Current)) {
                                    // 対象行の削除
                                    grid.delRowData(p);
                                    // メッセージの表示
                                    App.ui.page.notifyAlert.message(
                                        pageLangText.duplicate.text + pageLangText.deletedDuplicate.text).show();
                                }
                                else {
                                    unique = p + "_" + duplicateCol;

                                    // TODO: 画面の仕様に応じて以下の値を変更します。
                                    current = grid.getRowData(p);
                                    current.cd_hinmei = ret.Updated[i].Current.cd_hinmei;
                                    current.wt_kowake = ret.Updated[i].Current.wt_kowake;
                                    current.ts = ret.Updated[i].Current.ts;
                                    // TODO: ここまで

                                    // 対象行の更新
                                    grid.setRowData(p, current);
                                    // エラーメッセージの表示
                                    App.ui.page.notifyAlert.message(
                                        pageLangText.duplicate.text + pageLangText.updatedDuplicate.text, unique).show();
                                }
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
                            value = changeSet.changeSet.deleted[p].cd_hinmei;
                            retValue = ret.Deleted[i].Requested.cd_hinmei;
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
                closeSaveConfirmDialog();
                // 情報メッセージのクリア
                App.ui.page.notifyInfo.clear();
                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();
                // ローディングの表示
                App.ui.loading.show(pageLangText.nowSaving.text);
                // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                var saveUrl = "../api/JuryoMaster";
                // TODO: ここまで
                App.ajax.webpost(
                    saveUrl, getPostData()
                ).done(function (result) {
                    // 検索前の状態に初期化
                    clearState();
                    App.ui.page.notifyInfo.message(pageLangText.successMessage.text).show();
                    // データ検索
                    searchItems(new queryWeb());
                }).fail(function (result) {
                    // データ変更エラーハンドリングを行います。
                    handleSaveDataError(result);
                }).always(function () {
                    // ローディングの終了
                    App.ui.loading.close();
                });
            };
            /// 検索条件変更チェック
            var noChangeCriteria = function () {
                var criteria = $(".search-criteria").toJSON();
                var bool = true;
                if (searchCriteriaSetting.kbn_jotai != criteria.kbn_jotai) {
                    bool = false;
                    $(".item-list [name='kbn_jotai']").val(searchCriteriaSetting.kbn_jotai).change();
                }
                if (searchCriteriaSetting.kbn_hin != criteria.kbn_hin) {
                    bool = false;
                    $(".item-list [name='kbn_hin']").val(searchCriteriaSetting.kbn_hin).change();
                }
                if (searchCriteriaSetting.cd_hinmei_kensaku != criteria.cd_hinmei_kensaku) {
                    bool = false;
                    $(".item-list [name='cd_hinmei_kensaku']").val(searchCriteriaSetting.cd_hinmei_kensaku).change();
                }
                return bool;
            };
            /// <summary>保存前チェック</summary>
            var checkSave = function () {
                // 編集内容の保存
                saveEdit();
                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();

                // 検索条件が変更されていないか
                if (!noChangeCriteria()) {
                    App.ui.page.notifyAlert.message(MS0575).show();
                    return;
                }
                // 変更がない場合は処理を抜ける
                if (noChange()) {
                    App.ui.page.notifyInfo.message(pageLangText.noChange.text).show();
                    return;
                }
                // 変更セット内にバリデーションエラーがある場合は処理を抜ける
                if (!validateChangeSet()) {
                    return;
                }
                showSaveConfirmDialog();
            };
            /// <summary>保存ボタンクリック時のイベント処理を行います。</summary>
            $(".save-button").on("click", checkSave);

            //// 保存処理 -- End

            //// バリデーション -- Start

            // グリッドコントロール固有のバリデーション

            // TODO: 画面の仕様に応じて以下のカスタムバリデーション定義を変更してください。

            /// <summary>品名コード入力チェッ：ク</summary>
            /// <param name="hinmeiCode">コード</param>
            var isValidHinmeiCode = function (hinCode) {
                clearMessage();
                var isValid = true
                    , criteria = $(".search-criteria").toJSON()
                    , jotaiKbn = criteria.kbn_jotai
                    , hinKbn = criteria.kbn_hin;
                // 状態区分がその他の時のみ品コード入力があるため、チェック
                if (jotaiKbn === pageLangText.sonotaJotaiKbn.text) {
                    if (hinCode != "" && !App.isUndefOrNull(hinCode)) {
                        var selectedRowId = getSelectedRowId()
                            , url;
                        // 品区分により参照テーブルを切り替える 
                        if (pageLangText.genryoHinKbn.text === hinKbn) {
                            url = "../Services/FoodProcsService.svc/ma_hinmei()?$filter=cd_hinmei eq '"
                                    + hinCode + "'and kbn_hin eq " + hinKbn + "&$top=1";
                        }
                        else if (pageLangText.shikakariHinKbn.text === hinKbn) {
                            url = "../Services/FoodProcsService.svc/ma_haigo_mei()?$filter=cd_haigo eq '"
                                    + hinCode + "'and no_han eq " + pageLangText.hanNoShokichi.text + "&$top=1";
                        }

                        App.ajax.webgetSync(url
                        ).done(function (result) {
                            // !! 存在チェック
                            if (result.d.length === 0) {
                                validationSetting.cd_hinmei.messages.custom = App.str.format(MS0049, pageLangText.cd_hinmei.text);
                                isValid = false;
                            }
                        }).fail(function (result) {
                            //App.ui.page.notifyAlert.message(result.message).show();
                        });
                    }
                    else {
                        //App.ui.page.notifyAlert.message(App.str.format(MS0042, pageLangText.cd_hinmei.text)).show();
                        validationSetting.cd_hinmei.messages.custom = App.str.format(MS0042, pageLangText.cd_hinmei.text);
                        isValid = false;
                    }
                }
                return isValid;
            };
            validationSetting.cd_hinmei.rules.custom = function (value) {
                return isValidHinmeiCode(value);
            };

            /// <summary>検索条件表示用コード名の検索を行います。</summary>
            /// <param name="masterKubun">クエリオブジェクト</param>
            /// <param name="code">クエリオブジェクト</param>
            var isValidKensakuHinmeiCode = function () {
                var url
                    , isValid = true
                    , criteria = $(".search-criteria").toJSON()
                    , jotaiKbn = criteria.kbn_jotai
                    , hinKbn = criteria.kbn_hin
                    , hinCode = criteria.cd_hinmei_kensaku;
                if (hinCode != "" && !App.isUndefOrNull(hinCode)) {
                    var url;
                    // 品区分により参照テーブルを切り替える 
                    if (pageLangText.genryoHinKbn.text === hinKbn) {
                        url = "../Services/FoodProcsService.svc/ma_hinmei()?$filter=cd_hinmei eq '"
                                + hinCode + "'and kbn_hin eq " + hinKbn + "&$top=1";
                    }
                    else if (pageLangText.shikakariHinKbn.text === hinKbn) {
                        url = "../Services/FoodProcsService.svc/ma_haigo_mei()?$filter=cd_haigo eq '"
                                + hinCode + "' and no_han eq " + pageLangText.hanNoShokichi.text + "&$top=1";
                    }

                    App.ajax.webgetSync(url
                    ).done(function (result) {
                        // !! 存在チェック
                        if (result.d.length === 0) {
                            validationSetting.cd_hinmei_kensaku.messages.custom = App.str.format(MS0049, pageLangText.cd_hinmei.text);
                            isValid = false;
                        }
                    }).fail(function (result) {
                        //                    	App.ui.page.notifyAlert.message(result.message).show();
                    });
                }
                return isValid;
            };
            validationSetting.cd_hinmei_kensaku.rules.custom = function (value) {
                return isValidKensakuHinmeiCode();
            };
            validationSetting.kbn_hin.rules.custom = function (value) {
                return isValidKensakuHinmeiCode();
            };
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
                    // F3の処理
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
                    resultPartStyle = resultPart[0].currentStyle || document.defaultView.getComputedStyle(resultPart[0], "");

                resultPart.height(container[0].clientHeight - searchPart[0].clientHeight - ((parseInt(resultPartStyle.marginTop, 10) * 3) || 0));
                grid.setGridWidth(resultPart[0].clientWidth - 5);
                //結果一覧のパートの高さ - パートのヘッダーの高さ - パート内のボタンのコマンドの高さ - jqGrid のカラムヘッダーの高さ
                grid.setGridHeight(resultPart[0].clientHeight - resultPartHeader[0].clientHeight - resultPartCommands[0].clientHeight - resultPart.find(".ui-jqgrid-hdiv")[0].clientHeight - 35);
            };
            /// <summary>画面リサイズ時のイベント処理を行います。</summary>
            $(App.ui.page).on("resized", resizeContents);

            /// <summary>検索条件表示用コード名の検索を行います。</summary>
            /// <param name="masterKubun">クエリオブジェクト</param>
            /// <param name="code">クエリオブジェクト</param>
            var setHinmei = function (kbn, code, isGrid) {
                clearMessage();
                if (code === "" || App.isUndefOrNull(code)) {
                    $("#condition-nm_hinmei").text("");
                    return;
                }
                var serviceUrl,
                elementCode,
                elementName,
                codeName;

                if (code != "" && !App.isUndefOrNull(code)) {
                    if (kbn == pageLangText.genryoHinKbn.text) {
                        serviceUrl = "../Services/FoodProcsService.svc/ma_hinmei()?$filter=cd_hinmei eq '" + code + "'and kbn_hin eq " + kbn + "&$top=1";
                        elementCode = "cd_hinmei";
                        elementName = "nm_hinmei_" + App.ui.page.lang;
                    }
                    else if (kbn == pageLangText.shikakariHinKbn.text) {
                        serviceUrl = "../Services/FoodProcsService.svc/ma_haigo_mei()?$filter=cd_haigo eq '" + code + "' and no_han eq " + pageLangText.hanNoShokichi.text + "&$top=1";
                        elementCode = "cd_haigo";
                        elementName = "nm_haigo_" + App.ui.page.lang;
                    }
                }
                App.deferred.parallel({
                    // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                    codeName: App.ajax.webget(serviceUrl)
                    // TODO: ここまで
                }).done(function (result) {
                    // TODO: 画面の仕様に応じて以下のサービス呼び出し成功時の処理を変更してください。
                    codeName = result.successes.codeName.d;
                    if (codeName.length > 0) {
                        if (isGrid) {
                            grid.setCell(getSelectedRowId(false), "nm_hinmei", codeName[0][elementName]);
                        }
                        else {
                            $("#condition-nm_hinmei").text(codeName[0][elementName]);
                        }
                    }
                    else {
                        if (isGrid) {
                            grid.setCell(getSelectedRowId(false), "nm_hinmei", "");
                        }
                        else {
                            $("#condition-nm_hinmei").text("");
                        }
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

            /// <summary>検索条件変更時のイベント処理を行います。</summary>
            $("#condition-kbn_hin").on("change", function () {
                App.ui.page.notifyAlert.clear();
                var criteria = $(".search-criteria").toJSON()
                setHinmei(criteria.kbn_hin, criteria.cd_hinmei_kensaku, false);
            });

            /// <summary>検索条件変更時のイベント処理を行います。</summary>
            $("#condition-cd_hinmei").on("change", function () {
                App.ui.page.notifyAlert.clear();
                var criteria = $(".search-criteria").toJSON();
                setHinmei(criteria.kbn_hin, criteria.cd_hinmei_kensaku, false);
            });

            /// <summary>検索条件変更時のイベント処理を行います。</summary>
            $("#condition-jotai").on("change", function () {
                // 品名情報クリア
                $("#condition-kbn_hin").attr("value", "");
                $("#condition-cd_hinmei").attr("value", "");
                $("#condition-nm_hinmei").text("");

                var criteria = $(".search-criteria").toJSON();
                var kbn = criteria.kbn_jotai;
                if (kbn === pageLangText.sonotaJotaiKbn.text) {
                    createKbnHinCombobox("");
                    $("#condition-kbn_hin").removeAttr("disabled");
                    $("#condition-cd_hinmei").removeAttr("disabled");
                    $("#hinmei_kensaku-button").removeAttr("disabled");
                }
                else {
                    $("#condition-kbn_hin").attr("disabled", "disabled");
                    $("#condition-cd_hinmei").attr("disabled", "disabled");
                    $("#hinmei_kensaku-button").attr("disabled", "disabled");
                }
            });

            var clearData = function () {
                location.reload();
            };

            /// <summary>保存確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".save-confirm-dialog .dlg-yes-button").on("click", saveData);

            // <summary>保存確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".save-confirm-dialog .dlg-no-button").on("click", closeSaveConfirmDialog);

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

            // TODO ダイアログ情報メッセージの設定
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

            /// <summary>明細品名コード検索ボタンクリック時のイベント処理を行います。</summary>
            $(".hinmei-button").on("click", function (e) {
                if (grid.jqGrid('getCell', getSelectedRowId(false), 'ts')) {
                    return;
                }
                else {
                    showHinmeiDialogGrid();
                }
            });

            /// <summary>検索条件品名コード検索ボタンクリック時のイベント処理を行います。</summary>
            $("#hinmei_kensaku-button").on("click", function (e) {
                // 品名セレクタ起動
                showHinmeiDialog();
            });

            /// <summary>データに変更があり、未保存の状態でページを離れる際に確認を行います。</summary>
            //別画面に遷移したりするときに実行する関数の定義
            var onBeforeUnload = function () {
                //データを変更したかどうかは各画面でチェックし、保持する
                if (!noChange()) {
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
                if (!noChange()) {
                    var ans = confirm(pageLangText.unloadWithoutSave.text);
                    if (ans == false) {
                        $(window).on('beforeunload', onBeforeUnload);   //イベントを外したままだと、他のボタンで機能しないので、再設定
                        return false;
                    }
                }
                __doPostBack('ctl00$loginButton', '');
            });

            /// <summary>クリア確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".find-confirm-dialog .dlg-yes-button").on("click", function () {
                clearState();
                searchItems(new queryWeb());
            });
            // <summary>クリア確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".find-confirm-dialog .dlg-no-button").on("click", closeFindConfirmDialog);

        });
    </script>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <!-- 画面デザイン -- Start -->

    <!-- 検索条件と検索ボタン -->
    <div class="content-part search-criteria">
        <h3 class="part-header" data-app-text="searchCriteria"><a class="search-part-toggle" href="#"></a></h3>
        <div class="part-body">
            <ul class="item-list item-command">
                <!-- TODO: 画面の仕様に応じて以下の検索条件を変更してください。-->
                <li>
                    <label>
                        <span class="item-label" data-app-text="kbn_jotai"></span>
                        <select name="kbn_jotai" id="condition-jotai"></select>
                        <span class="item-label" style="width:30px">&nbsp;</span>
                    </label>
                    <label>
                        <span class="item-label" data-app-text="kbn_hin"></span>
                        <select class="kbn_hin" name="kbn_hin" id="condition-kbn_hin" disabled ></select>
                        <span class="item-label" style="width:30px"></span>
                    </label>
                </li>
                <li>
                    <label>
                        <span class="item-label">&nbsp;</span>
                        <span class="item-label" style="width:154px">&nbsp;</span>
                    </label>
                    <label>
                        <span class="item-label pad-apace" data-app-text="cd_hinmei_kensaku"></span>
                        <input class="cd_hinmei_kensaku" type="text" name="cd_hinmei_kensaku" id="condition-cd_hinmei" disabled="disabled" />
                        <button type="button" class="dialog-button" id="hinmei_kensaku-button" disabled="disabled" >
                            <span class="icon"></span><span data-app-text="codeSearch"></span>
                        </button>
                    </label>
                </li>
                <li>
                    <label>
                        <span class="item-label">&nbsp;</span>
                        <span class="item-label" style="width:154px">&nbsp;</span>
                    </label>
                    <label>
                        <span class="item-label pad-apace" data-app-text="nm_hinmei_kensaku"></span>
                        <span class="conditionname-label" id="condition-nm_hinmei"></span>
                    </label>
                </li>
                <!-- TODO: ここまで -->
            </ul>
        </div>
        <div class="part-footer">
            <div class="command" style="left: 1px;">
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
        <h3 id="listHeader" class="part-header" >
            <span data-app-text="resultList" style="padding-right: 10px;"></span>
            <span class="list-count" id="list-count" ></span>
            <span style="padding-left: 50px;" class="list-loading-message" id="list-loading-message" ></span>
        </h3>
        <div class="part-body" id="result-grid">
            <div class="item-command">
                <button type="button" class="colchange-button" data-app-operation="save">
                    <span class="icon"></span><span data-app-text="colchange"></span>
                </button>
                <button type="button" class="add-button" name="add-button" data-app-operation="add">
                    <span class="icon"></span><span data-app-text="add"></span>
                </button>
                <button type="button" class="delete-button" name="delete-button" data-app-operation="del">
                    <span class="icon"></span><span data-app-text="del"></span>
                </button>
				<button type="button" class="hinmei-button" name="hinmei-button" data-app-operation="hinmei">
					<span class="icon"></span><span data-app-text="hinmeiIchiran"></span>
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
        <button type="button" class="save-button" name="save-button" data-app-operation="save">
            <span class="icon"></span>
            <span data-app-text="save"></span>                                                 
        </button>
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
    <!-- TODO: ここまで  -->

    <!-- 画面デザイン -- End -->
</asp:Content>
<asp:Content ID="Content5" ContentPlaceHolderID="DialogsContent" runat="server">
    <!-- 画面デザイン -- Start -->

    <!-- ダイアログ固有のデザイン -- Start -->

    <!-- TODO: 画面の仕様に応じて以下のダイアログの設定を変更してください。 -->

    <div class="hinmei-dialog">
    </div>

    <div class="hinmei-dialog2">
    </div>


    <!-- TODO: ここまで  -->

    <!-- 画面デザイン -- End -->
</asp:Content>
