<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="TorihikisakiMaster.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.TorihikisakiMaster" %>

<asp:Content ID="Content1" ContentPlaceHolderID="IncludeContent" runat="server">
    <script src="<%=ResolveUrl("~/Resources/pages/pagedata-torihikisakimaster." + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
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
        
        .part-body .con-list-left li
        {
            float: left;
            width: 350px;
        }
        
        .part-body .con-list-right li
        {
            margin-left: 300px;
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
            var nonyusho,
                kbnTorihiki;
            var isCriteriaChanged = false;
            // TODO: ここまで
            //// 変数宣言 -- End

            //// コントロール定義 -- Start
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            // ダイアログ固有の変数宣言
            var saveConfirmDialog = $(".save-confirm-dialog"),
                saveCompleteDialog = $(".save-complete-dialog"),
                clearConfirmDialog = $(".clear-confirm-dialog"),
                showgridConfirmDialog = $(".showgrid-confirm-dialog"),
                deleteConfirmDialog = $(".delete-confirm-dialog"),
                deleteCompleteDialog = $(".delete-complete-dialog"),
                menuConfirmDialog = $(".menu-confirm-dialog");

            // ダイアログ固有のコントロール定義
            saveConfirmDialog.dlg();
            saveCompleteDialog.dlg();
            clearConfirmDialog.dlg()
            showgridConfirmDialog.dlg();
            deleteConfirmDialog.dlg();
            deleteCompleteDialog.dlg();
            menuConfirmDialog.dlg();

            /// <summary>ダイアログを開きます。</summary>
            var showSaveConfirmDialog = function () {
                saveConfirmDialogNotifyInfo.clear();
                saveConfirmDialogNotifyAlert.clear();
                saveConfirmDialog.draggable(true);
                saveConfirmDialog.dlg("open");
            };
            var showSaveCompleteDialog = function () {
                saveCompleteDialogNotifyInfo.clear();
                saveCompleteDialogNotifyAlert.clear();
                saveCompleteDialog.draggable(true);
                saveCompleteDialog.dlg("open");
            };
            var showClearConfirmDialog = function () {
                clearConfirmDialogNotifyInfo.clear();
                clearConfirmDialogNotifyAlert.clear();
                clearConfirmDialog.draggable(true);
                clearConfirmDialog.dlg("open");
            };
            var showShowgridConfirmDialog = function () {
                showgridConfirmDialogNotifyInfo.clear();
                showgridConfirmDialogNotifyAlert.clear();
                showgridConfirmDialog.draggable(true);
                showgridConfirmDialog.dlg("open");
            };
            var showDeleteConfirmDialog = function () {
                recordCount = grid.getGridParam("records");
                // レコードがない場合は処理を抜ける
                if (recordCount == 0) {
                    App.ui.page.notifyInfo.message(pageLangText.noRecords.text).show();
                    return;
                }
                deleteConfirmDialogNotifyInfo.clear();
                deleteConfirmDialogNotifyAlert.clear();
                deleteConfirmDialog.draggable(true);
                deleteConfirmDialog.dlg("open");
            };
            var showDeleteCompleteDialog = function () {
                deleteCompleteDialogNotifyInfo.clear();
                deleteCompleteDialogNotifyAlert.clear();
                deleteCompleteDialog.draggable(true);
                deleteCompleteDialog.dlg("open");
            };
            var showMenuConfirmDialog = function () {
                menuConfirmDialogNotifyInfo.clear();
                menuConfirmDialogNotifyAlert.clear();
                menuConfirmDialog.draggable(true);
                menuConfirmDialog.dlg("open");
            };

            /// <summary>ダイアログを閉じます。</summary>
            var closeSaveConfirmDialog = function () {
                saveConfirmDialog.dlg("close");
            };
            var closeSaveCompleteDialog = function () {
                saveCompleteDialog.dlg("close");
            };
            var closeClearConfirmDialog = function () {
                clearConfirmDialog.dlg("close");
            };
            var closeShowgridConfirmDialog = function () {
                showgridConfirmDialog.dlg("close");
            };
            var closeDeleteConfirmDialog = function () {
                deleteConfirmDialog.dlg("close");
            };
            var closeDeleteCompleteDialog = function () {
                deleteCompleteDialog.dlg("close");
            };
            var closeMenuConfirmDialog = function () {
                menuConfirmDialog.dlg("close");
            };

            // 日付の多言語対応
            var newDateFormat = pageLangText.dateTimeNewFormatUS.text;
            if (App.ui.page.langCountry != 'en-US') {
                newDateFormat = pageLangText.dateTimeNewFormat.text;
            }

            grid.jqGrid({
                colNames: [
                    pageLangText.cd_torihiki.text,
                    pageLangText.nm_torihiki.text,
                    pageLangText.nm_torihiki_ryaku.text,
                    pageLangText.nm_busho.text,
                    pageLangText.kbn_torihiki.text,
                    pageLangText.nm_kbn_torihiki.text,
                    pageLangText.no_yubin.text,
                    pageLangText.nm_jusho.text,
                    pageLangText.no_tel.text,
                    pageLangText.no_fax.text,
                    pageLangText.e_mail.text,
                    pageLangText.nm_tanto_1.text,
                    pageLangText.nm_tanto_2.text,
                    pageLangText.nm_tanto_3.text,
                    pageLangText.kbn_keishiki_nonyusho.text,
                    pageLangText.nm_kbn_keishiki_nonyusho.text,
                    pageLangText.kbn_keisho_nonyusho.text,
                    pageLangText.nm_kbn_keisho_nonyusho.text,
                    pageLangText.kbn_hin.text,
                    pageLangText.biko.text,
                    pageLangText.cd_maker.text,
                    pageLangText.flg_pikking.text,
                    pageLangText.flg_mishiyo.text,
                    pageLangText.dt_create.text,
                    pageLangText.cd_create.text,
                    pageLangText.dt_update.text,
                    pageLangText.cd_update.text,
                    pageLangText.ts.text
                ],
                colModel: [
                    { name: 'cd_torihiki', width: 110, sorttype: "text", frozen: true },
                    { name: 'nm_torihiki', width: 200, sorttype: "text", frozen: true },
                    { name: 'nm_torihiki_ryaku', width: 160, sorttype: "text", frozen: true },
                    { name: 'nm_busho', width: 140, sorttype: "text" },
                    { name: 'kbn_torihiki', width: 0, hidden: true, hidedlg: true },
                    { name: 'nm_kbn_torihiki', width: 100, align: "center", sorttype: "text" },
                    { name: 'no_yubin', width: 100, sorttype: "text" },
                    { name: 'nm_jusho', width: 320, sorttype: "text" },
                    { name: 'no_tel', width: 120, sorttype: "text" },
                    { name: 'no_fax', width: 120, sorttype: "text" },
                    { name: 'e_mail', width: 160, sorttype: "text" },
                    { name: 'nm_tanto_1', width: 120, sorttype: "text" },
                    { name: 'nm_tanto_2', width: 120, sorttype: "text" },
                    { name: 'nm_tanto_3', width: 120, sorttype: "text" },
                    { name: 'kbn_keishiki_nonyusho', width: 0, hidden: true, hidedlg: true },
                    { name: 'nm_kbn_keishiki_nonyusho', width: 135, sorttype: "text", formatter: setKbnName },
                    { name: 'kbn_keisho_nonyusho', width: 0, hidden: true, hidedlg: true },
                    { name: 'nm_kbn_keisho_nonyusho', width: 90, sorttype: "text", formatter: setKbnName, align: "center" },
                    { name: 'kbn_hin', width: 0, hidden: true, hidedlg: true },
                    { name: 'biko', width: 180, sorttype: "text" },
                    { name: 'cd_maker', width: 120, sorttype: "text" },
                    { name: 'flg_pikking', width: 0, hidden: true, hidedlg: true },
                    { name: 'flg_mishiyo', width: 70, editable: false, edittype: "checkbox",
                        editoptions: { value: "1:0" },
                        formatter: "checkbox",
                        cellattr: setCheckBox,
                        align: 'center'
                    },
                    { name: 'dt_create', width: 0, hidden: true, hidedlg: true,
                        formatter: "date",
                        formatoptions: {
                            srcformat: newDateFormat, newformat: newDateFormat
                        }
                    },
                    { name: 'cd_create', width: 0, hidden: true, hidedlg: true },
                    { name: 'dt_update', width: 0, hidden: true, hidedlg: true,
                        formatter: "date",
                        formatoptions: {
                            srcformat: newDateFormat, newformat: newDateFormat
                        }
                    },
                    { name: 'cd_update', width: 0, hidden: true, hidedlg: true },
                    { name: 'ts', width: 0, hidden: true, hidedlg: true }
                ],
                datatype: "local",
                shrinkToFit: false,
                multiselect: false,
                hoverrows: false,
                rownumbers: true,
                loadComplete: function () {
                    // グリッドの先頭行選択
                    grid.setSelection(1, false);
                },
                ondblClickRow: function (selectedRowId) {
                    isAdd = false;
                    isCopy = false;
                    showDetail(false, false);
                }
            });

            /// <summary> 未使用データの設定を行います。</summary>
            /// <param name="cellvalue">セルの値</param>
            /// <param name="options">行のオプション</param>
            /// <param name="rowObject">行データ</param>
            function setCheckBox(cellvalue, options, rowObject) {
                var row = this.rows[0];
                if ($.inArray('jqgrow', row.className.split(' ')) > 0) {
                    if (rowObject.flg_mishiyo == 1) {
                        grid.toggleClassRow(options.rowId, "attention");
                        isMishiyo = true;
                    }
                }
            }

            /// <summary> 納入形式区分名・敬称区分名の設定を行います。</summary>
            /// <param name="cellvalue">セルの値</param>
            /// <param name="options">行のオプション</param>
            /// <param name="rowObject">行データ</param>
            function setKbnName(cellvalue, options, rowObject) {
                var cellname = options.colModel.name;
                if (cellname == 'nm_kbn_keishiki_nonyusho') {
                    // 納入形式区分名を表示
                    var kbn = rowObject.kbn_keishiki_nonyusho;
                    if (kbn == pageLangText.suNonyuKeishikiKbn.text) {
                        return pageLangText.nm_keishiki_nonyu.text;
                    }
                    else if (kbn == pageLangText.suShiyouKeishikiKbn.text) {
                        return pageLangText.nm_keishiki_shiyou.text;
                    }
                    else {
                        return pageLangText.shokikaShokichi.text;
                    }
                } else if (cellname == 'nm_kbn_keisho_nonyusho') {
                    // 敬称区分名を表示
                    var kbn = rowObject.kbn_keisho_nonyusho;
                    if (kbn == pageLangText.samaKeishoKbn.text) {
                        return pageLangText.nm_keisho_sama.text;
                    }
                    else if (kbn == pageLangText.onchuKeishoKbn.text) {
                        return pageLangText.nm_keisho_onchu.text;
                    }
                    else if (kbn == pageLangText.nashiKeishoKbn.text) {
                        return pageLangText.nm_keisho_nashi.text;
                    }
                    else {
                        return pageLangText.shokikaShokichi.text;
                    }
                }
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
            // TODO：ここまで
            //// コントロール定義 -- End

            //// メッセージ表示 -- Start
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
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
            var saveCompleteDialogNotifyInfo = App.ui.notify.info(saveCompleteDialog, {
                container: ".save-complete-dialog .dialog-slideup-area .info-message",
                messageContainerQuery: "ul",
                show: function () {
                    saveCompleteDialog.find(".info-message").show();
                },
                clear: function () {
                    saveCompleteDialog.find(".info-message").hide();
                }
            });
            var clearConfirmDialogNotifyInfo = App.ui.notify.info(clearConfirmDialog, {
                container: ".clear-confirm-dialog .dialog-slideup-area .info-message",
                messageContainerQuery: "ul",
                show: function () {
                    clearConfirmDialog.find(".info-message").show();
                },
                clear: function () {
                    clearConfirmDialog.find(".info-message").hide();
                }
            });
            var showgridConfirmDialogNotifyInfo = App.ui.notify.info(showgridConfirmDialog, {
                container: ".showgrid-confirm-dialog .dialog-slideup-area .info-message",
                messageContainerQuery: "ul",
                show: function () {
                    showgridConfirmDialog.find(".info-message").show();
                },
                clear: function () {
                    showgridConfirmDialog.find(".info-message").hide();
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
            var deleteCompleteDialogNotifyInfo = App.ui.notify.info(deleteCompleteDialog, {
                container: ".delete-complete-dialog .dialog-slideup-area .info-message",
                messageContainerQuery: "ul",
                show: function () {
                    deleteCompleteDialog.find(".info-message").show();
                },
                clear: function () {
                    deleteCompleteDialog.find(".info-message").hide();
                }
            });
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
            var saveCompleteDialogNotifyAlert = App.ui.notify.alert(saveCompleteDialog, {
                container: ".save-complete-dialog .dialog-slideup-area .alert-message",
                messageContainerQuery: "ul",
                show: function () {
                    saveCompleteDialog.find(".alert-message").show();
                },
                clear: function () {
                    saveCompleteDialog.find(".alert-message").hide();
                }
            });
            var clearConfirmDialogNotifyAlert = App.ui.notify.alert(clearConfirmDialog, {
                container: ".clear-confirm-dialog .dialog-slideup-area .alert-message",
                messageContainerQuery: "ul",
                show: function () {
                    clearConfirmDialog.find(".alert-message").show();
                },
                clear: function () {
                    clearConfirmDialog.find(".alert-message").hide();
                }
            });
            var showgridConfirmDialogNotifyAlert = App.ui.notify.alert(showgridConfirmDialog, {
                container: ".showgrid-confirm-dialog .dialog-slideup-area .alert-message",
                messageContainerQuery: "ul",
                show: function () {
                    showgridConfirmDialog.find(".alert-message").show();
                },
                clear: function () {
                    showgridConfirmDialog.find(".alert-message").hide();
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
            var deleteCompleteDialogNotifyAlert = App.ui.notify.alert(deleteCompleteDialog, {
                container: ".delete-complete-dialog .dialog-slideup-area .alert-message",
                messageContainerQuery: "ul",
                show: function () {
                    deleteCompleteDialog.find(".alert-message").show();
                },
                clear: function () {
                    deleteCompleteDialog.find(".alert-message").hide();
                }
            });
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
            $(function () {
                if (userRoles === pageLangText.viewer.text) {
                    $(".save-button").css("display", "none");
                    $(".clear-button").css("display", "none");
                    $(".add-button").css("display", "none");
                    $(".copy-button").css("display", "none");
                    $(".delete-button").css("display", "none");
                }
                if (userRoles === pageLangText.operator.text) {
                    $(".add-button").css("display", "none");
                    $(".copy-button").css("display", "none");
                    $(".delete-button").css("display", "none");
                }
            });
            //// 操作制御定義 -- End

            //// 事前データロード -- Start 
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            // 画面アーキテクチャ共通の事前データロード
            nonyusho = pageLangText.nonyushoId.data;

            App.deferred.parallel({
                // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                loading: App.ui.loading.show(pageLangText.nowProgressing.text),
                kbn_torihiki: App.ajax.webget("../Services/FoodProcsService.svc/ma_kbn_torihiki()")
                // TODO: ここまで
            }).done(function (result) {
                // TODO: 画面の仕様に応じて以下のサービス呼び出し成功時の処理を変更してください。
                var kbn_torihiki = result.successes.kbn_torihiki.d;

                // 検索用ドロップダウンの設定
                App.ui.appendOptions($(".search-criteria [name='kbn_torihiki']"), "kbn_torihiki", "nm_kbn_torihiki", kbn_torihiki, true);
                // 詳細用ドロップダウンの設定
                App.ui.appendOptions($(".list-part-detail-content [name='kbn_torihiki']"), "kbn_torihiki", "nm_kbn_torihiki", kbn_torihiki, false);
                App.ui.appendOptions($(".list-part-detail-content [name='nonyusho']"), "id", "name", nonyusho, false);

                setLiteral("cd_torihiki", pageLangText.cd_torihiki.text, true);
                setLiteral("nm_torihiki", pageLangText.nm_torihiki.text, true);

                // URLのクエリ文字列で検索条件が指定された場合はその条件で検索
                var parameters = getParameters();

                if (!App.isUnusable(parameters["kbn_torihiki"])) {
                    $(".search-criteria [name='kbn_torihiki']").val(parameters["kbn_torihiki"]);
                    searchItems(new query());
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
            }).always(function () {
                App.ui.loading.close();
            });

            // リテラルの必須マークの制御（詳細画面）
            var setLiteral = function (komoku, text, flg) {
                var lbl = $(".list-part-detail-content [name=" + komoku + "]").prev();
                if (flg) {
                    lbl.html(text + pageLangText.requiredMark.text);
                }
                else {
                    lbl.html(text);
                }
            };

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
                        pamameters[keyValue[0]] = keyValue[1];
                    }
                }
                return pamameters;
            };
            // TODO：ここまで
            //// 事前データロード -- End

            //// 検索処理 -- Start
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            // 画面アーキテクチャ共通の検索処理

            // 画面アーキテクチャ共通の検索処理
            $(".search-criteria").on("change", function (e) {
                isCriteriaChanged = true;
            });

            /// <summary>クエリオブジェクトの設定</summary>
            var query = function () {
                var query = {
                    // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                    url: "../Services/FoodProcsService.svc/vw_ma_torihiki_01",
                    // TODO: ここまで
                    filter: createFilter(),
                    orderby: "cd_torihiki",
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

                // TODO: 画面の仕様に応じて以下のフィルター条件を変更してください。
                if (!App.isUndefOrNull(criteria.kbn_torihiki) && criteria.kbn_torihiki.length > 0) {
                    filters.push("kbn_torihiki eq " + criteria.kbn_torihiki);
                }
                if (!App.isUndefOrNull(criteria.con_nm_torihiki) && criteria.con_nm_torihiki.length > 0) {
                    //filters.push("substringof('" + encodeURIComponent(criteria.con_nm_torihiki) + "', nm_torihiki) eq true");
                    filters.push("(substringof('" + encodeURIComponent(criteria.con_nm_torihiki) + "', nm_torihiki)"
                        + "or substringof('" + encodeURIComponent(criteria.con_nm_torihiki) + "', cd_torihiki))");
                }
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
                $("#list-loading-message").text(
                    pageLangText.nowLoading.text
                //    App.str.format(
                //        pageLangText.nowListLoading.text,
                //        querySetting.skip + 1,
                //        querySetting.top
                //    )
                );
                App.ajax.webget(
                // WCF Data ServicesのODataシステムクエリオプションを生成
                    App.data.toODataFormat(query)
                ).done(function (result) {
                    // データバインド
                    bindData(result);
                    isCriteriaChanged = false;
                    // 検索条件を閉じる
                    closeCriteria();
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
                querySetting.skip = querySetting.skip + result.d.results.length;
                querySetting.count = parseInt(result.d.__count);

                // 検索結果が上限値を超えていた場合はメッセージを表示する
                if (querySetting.count > querySetting.top) {
                    App.ui.page.notifyAlert.message(pageLangText.limitOver.text).show();
                }

                // グリッドの表示件数を更新
                grid.setGridParam({ rowNum: querySetting.skip });
                displayCount();
                // カラムの固定解除
                grid.destroyFrozenColumns();
                // データバインド
                var currentData = grid.getGridParam("data").concat(result.d.results);
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
            /// <summary>新規行データの設定を行います。</summary>
            var setAddData = function (row) {
                // TODO: 画面の仕様に応じて以下の項目を変更してください。
                var addData = {
                    "cd_torihiki": "",
                    "nm_torihiki": "",
                    "nm_busho": "",
                    "nm_torihiki_ryaku": "",
                    "nm_tanto_1": "",
                    "nm_tanto_2": "",
                    "nm_tanto_3": "",
                    "no_yubin": "",
                    "nm_jusho": "",
                    "no_tel": "",
                    "no_fax": "",
                    "biko": "",
                    "kbn_torihiki": 1,
                    "nonyusho": 1,
                    "kbn_keisho_nonyusho": 1,
                    "cd_maker": "",
                    "e_mail": "",
                    "dt_update": "",
                    "cd_update": "",
                    "dt_create": "",
                    "cd_create": "",
                    "ts": "",
                    "flg_mishiyo": 0
                };
                // TODO: ここまで

                return addData;
            };

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

            /// <summary>削除状態の変更セットに追加する変更データの設定を行います。</summary>
            /// <param name="row">選択行</param>
            var setDeletedChangeData = function (row) {
                // TODO: 画面の仕様に応じて以下の項目を変更してください。
                var changeData = {
                    "cd_torihiki": row.cd_torihiki,
                    "nm_torihiki": row.nm_torihiki,
                    "nm_busho": row.nm_busho,
                    "nm_torihiki_ryaku": row.nm_torihiki_ryaku,
                    "nm_tanto_1": row.nm_tanto_1,
                    "nm_tanto_2": row.nm_tanto_2,
                    "nm_tanto_3": row.nm_tanto_3,
                    "no_yubin": row.no_yubin,
                    "nm_jusho": row.nm_jusho,
                    "no_tel": row.no_tel,
                    "no_fax": row.no_fax,
                    "biko": row.biko,
                    "kbn_torihiki": row.kbn_torihiki,
                    "kbn_keisho_nonyusho": row.kbn_keisho_nonyusho,
                    "cd_maker": row.cd_maker,
                    "e_mail": row.e_mail,
                    "dt_update": row.dt_update,
                    "dt_create": row.dt_create,
                    "ts": row.ts
                };
                // TODO: ここまで
                return changeData;
            };

            /// <summary>更新データを取得します。</summary>
            var getPostData = function () {
                return changeSet.getChangeSet();
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

                // データ整合性エラーのハンドリングを行います。
                if (App.isArray(ret) && ret.length > 0) {
                    if (ret[0].InvalidationName === "NotExsists") {
                        // エラーメッセージの表示
                        App.ui.page.notifyAlert.message(
                            pageLangText.invalidation.text + ret[0].Message).show();
                    }
                    else if (ret[0].InvalidationName === "UnDeletableRecord") {
                        //App.ui.page.notifyAlert.message(
                        //    pageLangText.invalidation.text + ret[0].Message).show();
                        App.ui.page.notifyAlert.message(ret[0].Message).show();
                        changeSet = new App.ui.page.changeSet();
                    }
                    else {
                        App.ui.page.notifyAlert.message(
                            pageLangText.unDeletableRecord.text + "：" + ret[0].Message).show();
                    }
                }

                // 更新時同時実行制御エラーのハンドリングを行います。
                if (!App.isUndefOrNull(ret.Updated) && ret.Updated.length > 0) {
                    var upCurrent = ret.Updated[0].Current;
                    // 他のユーザーによって削除されていた場合
                    if (App.isUndefOrNull(upCurrent)) {
                        // メッセージの表示
                        App.ui.page.notifyAlert.message(
                            pageLangText.duplicate.text + pageLangText.deletedDuplicate.text).show();
                    }
                    else {
                        detailContent = $(".list-part-detail-content");
                        // TODO: 画面の仕様に応じて更新後のデータ状態をセットします
                        var data = {
                            "cd_torihiki": upCurrent.cd_torihiki,
                            "nm_torihiki": upCurrent.nm_torihiki,
                            "nm_busho": upCurrent.nm_busho,
                            "nm_torihiki_ryaku": upCurrent.nm_torihiki_ryaku,
                            "nm_tanto_1": upCurrent.nm_tanto_1,
                            "nm_tanto_2": upCurrent.nm_tanto_2,
                            "nm_tanto_3": upCurrent.nm_tanto_3,
                            "no_yubin": upCurrent.no_yubin,
                            "nm_jusho": upCurrent.nm_jusho,
                            "no_tel": upCurrent.no_tel,
                            "no_fax": upCurrent.no_fax,
                            "biko": upCurrent.biko,
                            "kbn_torihiki": upCurrent.kbn_torihiki,
                            //"kbn_keishiki_nonyusho": upCurrent.kbn_keishiki_nonyusho,
                            "kbn_keisho_nonyusho": upCurrent.kbn_keisho_nonyusho,
                            "cd_maker": upCurrent.cd_maker,
                            "e_mail": upCurrent.e_mail,
                            "flg_mishiyo": upCurrent.flg_mishiyo,
                            "dt_update": upCurrent.dt_update,
                            "dt_create": upCurrent.dt_create,
                            "ts": upCurrent.ts
                        };
                        // 取引先区分による、納入書形式の制御処理
                        controllNonyushoKeishiki(upCurrent.kbn_torihiki, upCurrent.kbn_keishiki_nonyusho);
                        // TODO: ここまで

                        // カレントのデータを詳細画面へ表示
                        detailContent.toForm(data);

                        // エラーメッセージの表示
                        App.ui.page.notifyAlert.message(
                            pageLangText.duplicate.text + pageLangText.updatedDuplicate.text).show();
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
                            value = changeSet.changeSet.deleted[p].cd_torihiki;
                            retValue = ret.Deleted[i].Requested.cd_torihiki;
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
            // TODO：ここまで
            //// エラーハンドリング -- End

            //// 保存処理 -- Start


            /// <summary>変更を保存します。</summary>
            //  更新
            var saveData = function (e) {
                closeSaveConfirmDialog();
                // 情報メッセージのクリア
                App.ui.page.notifyInfo.clear();

                // 更新データをJSONオブジェクトに変換
                var postData = $(".list-part-detail-content").toJSON();

                // ローディングの表示
                App.ui.loading.show(pageLangText.nowSaving.text);

                // TODO: 画面の仕様に応じて以下の項目を変更してください。
                postData["kbn_keishiki_nonyusho"] = $(".list-part-detail-content [name='nonyusho']").val();
                if (isAdd || isCopy) {
                    postData["cd_create"] = App.ui.page.user.Code;
                    postData["dt_create"] = new Date();
                    postData["cd_update"] = App.ui.page.user.Code;
                    postData["dt_update"] = new Date();
                }
                else {
                    postData["cd_update"] = App.ui.page.user.Code;
                    postData["dt_update"] = new Date();
                };
                // TODO: ここまで
                var changeSet = new App.ui.page.changeSet();

                // TODO: 画面の仕様に応じて新規/更新にて処理を変更してください。
                if (isAdd || isCopy) {
                    changeSet.addCreated(App.uuid, postData);
                }
                else {
                    changeSet.addUpdated(App.uuid, null, null, postData);
                }
                // TODO: ここまで
                var data = changeSet.getChangeSet();
                // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                var saveUrl = "../api/TorihikisakiMaster";
                // TODO: ここまで
                // TODO: ここまで
                App.ajax.webpost(
                    saveUrl, data
                ).done(function (result) {
                    showSaveCompleteDialog();
                }).fail(function (result) {
                    // データ変更エラーハンドリングを行います。
                    handleSaveDataError(result);
                }).always(function () {
                    // ローディングの終了
                    App.ui.loading.close();
                });
                // TODO: ここまで
            };

            //  更新完了
            var saveComplete = function (e) {
                closeSaveCompleteDialog();
                // 検索前の状態に初期化
                clearState();
                // データ検索
                showGrid().done(function () {
                    searchItems(new query())
                });
            };

            //  削除前処理
            var deleteCheck = function (e) {
                // 情報メッセージのクリア
                App.ui.page.notifyInfo.clear();

                var detailContent = $(".list-part-detail-content"),
                    result;
                // 変更セット内にバリデーションエラーがある場合は処理を抜ける
                // チェックしない
                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();
                // 確認メッセージ  
                showDeleteConfirmDialog();
            };

            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            /// <summary>行を削除します。</summary>
            /// <param name="e">イベントデータ</param>
            var deleteData = function (e) {
                // 選択行のID取得
                var selectedRowId = getSelectedRowId();
                if (App.isUndefOrNull(selectedRowId)) {
                    return;
                }
                // 削除状態の変更データの設定
                var changeData = setDeletedChangeData(grid.getRowData(selectedRowId));
                // 削除状態の変更セットに変更データを追加
                changeSet.addDeleted(selectedRowId, changeData);
                // データの保存
                saveDeleteData();
            };
            var saveDeleteData = function (e) {
                closeDeleteConfirmDialog();
                // 情報メッセージのクリア
                App.ui.page.notifyInfo.clear();

                // ローディングの表示
                App.ui.loading.show(pageLangText.nowSaving.text);


                // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                var saveUrl = "../api/TorihikisakiMaster";
                // TODO: ここまで

                App.ajax.webpost(
                    saveUrl, getPostData()
                ).done(function (result) {

                    showDeleteCompleteDialog();

                }).fail(function (result) {
                    // データ変更エラーハンドリングを行います。
                    handleSaveDataError(result);
                }).always(function () {
                    // ローディングの終了
                    App.ui.loading.close();
                });
                // TODO: ここまで
            };

            //  削除完了
            var deleteComplete = function (e) {
                closeDeleteCompleteDialog();
                // 検索前の状態に初期化
                clearState();
                // データ検索
                showGrid().done(function () {
                    searchItems(new query())
                });
            };

            //// 保存処理 -- End

            //// バリデーション -- Start
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            // グリッド固有のバリデーション
            // 詳細のバリデーション設定
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

            $(".list-part-detail-content").validation(v);

            // 一覧画面のバリデーション設定
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
            $(".search-criteria").validation(w);

            // 取引先コードの重複チェック
            var isValidTorihikiCode = function (torihikiCode) {
                var isValid = true;
                var _query = {
                    url: "../Services/FoodProcsService.svc/ma_torihiki",
                    filter: "cd_torihiki eq '" + torihikiCode + "'",
                    top: 1
                }
                // 取引先コード入力の場合のみチェック
                if (isAdd || isCopy) {
                    App.ajax.webgetSync(
                        App.data.toODataFormat(_query)
                    ).done(function (result) {
                        if (result.d.length > 0) {
                            isValid = false;
                        }
                    }).fail(function (result) {
                        App.ui.page.notifyAlert.message(result.message).show();
                    });
                }
                else {
                    isValid = true;
                }
                return isValid;
            };

            validationSetting.cd_torihiki.rules.custom = function (value) {
                return isValidTorihikiCode(value);
            };


            // TODO：ここまで
            //// バリデーション -- End

            //// 各種処理 -- Start
            //            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            //            /// <summary>行を削除します。</summary>
            //            /// <param name="e">イベントデータ</param>

            //Excel出力前チェックを行います。
            var checkExcel = function () {
                // 情報メッセージのクリア
                App.ui.page.notifyInfo.clear();
                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();
                // 明細があるかどうかをチェックし、無い場合は処理を中止します。
                if (querySetting.count == 0) {
                    App.ui.page.notifyInfo.message(pageLangText.noRecords.text).show();
                    return;
                }

                // 検索条件に変更がないかチェックを行う
                if (isCriteriaChanged) {
                    App.ui.page.notifyInfo.message(pageLangText.changeCriteria.text).show();
                    return;
                }
                printExcel();
            }

            /// <summary>Excelファイル出力を行います。</summary>
            var printExcel = function (e) {
                var queryExcel = {
                    // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                    url: "../api/TorihikisakiMasterIchiranExcel",
                    // TODO: ここまで
                    filter: createFilter(),
                    // TODO: 画面の仕様に応じて以下のソート条件を変更してください。
                    orderby: "cd_torihiki"
                    // TODO: ここまで
                };
                // 処理中を表示する
                App.ui.loading.show(pageLangText.nowProgressing.text);

                // TODO：画面の入力項目をURLへ渡す
                //url = "../api/TorihikisakiMasterIchiranExcel";
                var criteria = $(".search-criteria").toJSON(),
                    url = App.data.toODataFormat(queryExcel);

                // 引数設定：取引先区分
                if (!App.isUndefOrNull(criteria.kbn_torihiki) && criteria.kbn_torihiki.length > 0) {
                    url += "&kbn_torihiki=" + criteria.kbn_torihiki;
                }
                else {
                    url += "&kbn_torihiki=" + 0;
                }

                // 引数設定：取引先名称
                if (!App.isUndefOrNull(criteria.con_nm_torihiki) && criteria.con_nm_torihiki.length > 0) {
                    url += "&nm_torihiki=" + encodeURIComponent(criteria.con_nm_torihiki);
                }
                else {
                    url += "&nm_torihiki=" + null;
                }

                // 引数設定：未使用フラグ
                url += "&flg_mishiyo=" + criteria.flg_mishiyo;
                //if (criteria.flg_mishiyo == pageLangText.shiyoMishiyoFlg.text) {
                //    url += "&flg_mishiyo=" + criteria.flg_mishiyo;
                //}
                //else {
                //    url += "&flg_mishiyo=" + null;
                //}
                // TODO: ここまで
                url += "&lang=" + App.ui.page.lang;
                url += "&userName=" + encodeURIComponent(App.ui.page.user.Name);
                url += "&today=" + App.data.getDateTimeStringForQuery(new Date(), true);

                window.open(url, '_parent');
                // Cookieを監視する
                onComplete();
            };

            // Cookieを1秒ごとにチェックする
            var onComplete = function () {
                if (app_util.prototype.getCookieValue(pageLangText.torihikisakiMasterCookie.text) == pageLangText.checkCookie.text) {
                    app_util.prototype.deleteCookie(pageLangText.torihikisakiMasterCookie.text);
                    //ローディング終了
                    App.ui.loading.close();
                }
                else {
                    // 再起してCookieが作成されたか監視
                    setTimeout(onComplete, 1000);
                }
            };


            /// <summary>データのクリアを行います。</summary>
            var clearData = function () {
                closeClearConfirmDialog();
                //ページをリロード
                changeSet = new App.ui.page.changeSet();
                $(".list-part-detail-content").toForm(rowShowData);
                App.ui.page.notifyAlert.clear();
                isChanged = false;
            };

            /// <summary>詳細を表示します。</summary>
            var showDetail = function (isAdd, isCopy) {
                //var selectedRowId = grid.jqGrid("getGridParam", "selrow"),
                var detailContent = $(".list-part-detail-content"),
                    gridContent = $(".list-part-grid-content"),
                    row,
                // nextScrollTop = $(".ui-jqgrid-bdiv").scrollTop(),
                    code,
                    _bunruiCode;
                //取引先コードを読み取りだけに設定します。
                $("#id_cdTorihiki").attr("readonly", true).css("background-color", "#F2F2F2");

                /// <summary>追加の画面表示します。</summary>
                if (isAdd) {
                    row = setAddData();
                    kbnTorihikiSelect(isAdd, isCopy, row);
                    //取引先コードの読み取り設定を解除します。
                    $("#id_cdTorihiki").attr("readonly", false).css("background-color", "#FFFFFF");
                }
                else {
                    // チェック処理
                    if (!isAdd) {
                        var selectedRowId = getSelectedRowId();
                        if (App.isUndefOrNull(selectedRowId)) {
                            return;
                        }
                    }
                    //if (App.isUnusable(selectedRowId)) {
                    //    return;
                    //}

                    /// <summary>コピー画面表示します。</summary>
                    if (isCopy) {
                        //取引先コードの読み取り設定を解除します。
                        $("#id_cdTorihiki").attr("readonly", false).css("background-color", "#FFFFFF");
                    }
                    var serviceUrl,
                    item;
                    code = grid.jqGrid("getRowData", selectedRowId).cd_torihiki;
                    kbnTorihiki = grid.jqGrid("getRowData", selectedRowId).kbn_torihiki;

                    if (kbnTorihiki === "1") {
                        $("select[name='nonyusho'] option[value=0]").remove();
                        $("select[name='nonyusho']").val(grid.jqGrid("getRowData", selectedRowId).kbn_keishiki_nonyusho);
                        $("select[name='nonyusho']").attr("disabled", false);
                    }
                    else {
                        $("select[name='nonyusho']").append($('<option>').html("").val(0));
                        $("select[name='nonyusho']").val(0);
                        $("select[name='nonyusho']").attr("disabled", true);
                    }
                    serviceUrl = "../Services/FoodProcsService.svc/vw_ma_torihiki_01?$filter=cd_torihiki eq '" + code + "' &$top=1";

                    App.deferred.parallel({
                        // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                        item: App.ajax.webgetSync(serviceUrl)
                        // TODO: ここまで
                    }).done(function (result) {
                        // TODO: 画面の仕様に応じて以下のサービス呼び出し成功時の処理を変更してください。
                        item = result.successes.item.d;
                        if (item.length > 0) {
                            row = item[0];
                            kbnTorihikiSelect(isAdd, isCopy, row);
                        }
                        else {
                            // データが取得できなかった場合、エラーメッセージを表示して後続処理を行わない
                            App.ui.page.notifyInfo.message(
                                App.str.format(pageLangText.duplicate.text + pageLangText.deletedDuplicate.text)).show();
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
                        row = null;
                    });
                }
            };

            var kbnTorihikiSelect = function (isAdd, isCopy, row) {
                var criteria = $(".search-criteria").toJSON();

                if (criteria.kbn_torihiki == "1" || App.isUndefOrNull(criteria.kbn_torihiki)) {
                    $("select[name='nonyusho'] option[value=0]").remove();
                    $("select[name='nonyusho']").val(grid.jqGrid("getRowData", selectedRowId).kbn_keishiki_nonyusho);
                    $("select[name='nonyusho']").attr("disabled", false);
                }
                else {
                    $("select[name='nonyusho']").append($('<option>').html("").val(0));
                    //$("select[name='nonyusho']").val(0);
                    $("select[name='nonyusho']").attr("disabled", true);
                    //$("#detail_kbn_torihiki").val(criteria.kbn_torihiki);
                }


                // TODO：画面の仕様に応じて以下の詳細の項目の設定を変更してください。
                // TODO：ここまで

                App.ui.page.notifyAlert.clear();

                var selectedRowId = grid.jqGrid("getGridParam", "selrow"),
                    gridContent = $(".list-part-grid-content"),
                    detailContent = $(".list-part-detail-content");
                //row;

                // 検索条件、グリッドを非表示にして詳細を表示します。
                $(".search-criteria").hide("fast", function () {
                    gridContent.hide("fast", function () {
                        if (isCopy) {
                            row.cd_torihiki = "";
                        }
                        detailContent.toForm(row);
                        detailContent.show("fast");
                        $("#list-results").hover(
                            function () {
                                $("#list-results").css("cursor", "pointer");
                                $(this).css("background-color", "#87cefa");
                            },
                            function () {
                                $("#list-results").css("cursor", "default");
                                $(this).css("background-color", "#efefef");
                            }
                        );

                        $("#list-count").before("<span class='list-arrow' id='list-arrow'></span>");
                        $("#list-count").text(row.cd_torihiki);
                        $("#list-results").on("click", showGrid);
                    }).promise().done(function () {

                        $(".command-grid").hide("fast");
                        rowShowData = row;
                        $("select[name='nonyusho']").val(0);
                        $("#detail_kbn_torihiki").val(criteria.kbn_torihiki);
                        $(".command-detail").show("fast").promise().done();
                    });
                });
            };

            /// <summary>グリッドを表示します。</summary>
            var showGrid = function () {
                closeShowgridConfirmDialog();
                isChanged = false;

                var d = $.Deferred();
                App.ui.page.notifyAlert.clear();

                // 詳細を非表示にしてグリッドを表示します。
                $(".list-part-detail-content").hide("fast", function () {
                    $(".search-criteria").show("fast");
                    $(".list-part-grid-content").show("fast");
                    $("#list-count").text(
                        App.str.format("{0}/{1}", querySetting.skip, querySetting.count)
                    );

                    $("#list-arrow").remove();
                    $('#list-results').unbind('hover');
                    $('#list-results').unbind('click');
                    $('#list-results').css("cursor", "default");
                    $('#list-results').css("background-color", "#efefef");
                    d.resolve();

                });
                $(".command-grid").show("fast");
                $(".command-detail").hide("fast");

                return d.promise();
            };

            /// <summary>一覧へ戻るボタンクリック時のイベント処理を行います。</summary>
            var showGridCheck = function () {
                if (isChanged) {
                    showShowgridConfirmDialog();
                }
                else {
                    showGrid();
                };
            };

            /// <summary>変更前の処理を実施。</summary>
            var saveCheck = function (e) {
                // 情報メッセージのクリア
                App.ui.page.notifyInfo.clear();
                var detailContent,
                    result;

                detailContent = $(".list-part-detail-content");
                // 変更セット内にバリデーションエラーがある場合は処理を抜ける
                result = detailContent.validation().validate();
                if (result.errors.length) {
                    return;
                }

                // 変更がない場合は処理を抜ける
                if (!isChanged) {
                    App.ui.page.notifyInfo.message(pageLangText.noChange.text).show();
                    return;
                }

                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();
                // 確認メッセージ
                showSaveConfirmDialog();
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

            /// <summary>データに変更があり、未保存の状態でページを離れる際に確認を行います。</summary>
            var backToMenuCheck = function () {
                if (isChanged) {
                    showMenuConfirmDialog();
                }
                else {
                    backToMenu();
                };
            };
            // メニューへ戻る
            var backToMenu = function () {
                try {
                    window.location = pageLangText.menuPath.url;
                }
                catch (e) {
                    // 何もしない
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
                showGrid();
                clearState();
                searchItems(new query());
                //                clearState();
                //                showGrid().done(function () {
                //                    searchItems(new query())
                //                });
            });
            /// <summary>列変更ボタンクリック時のイベント処理を行います。</summary>
            $(".colchange-button").on("click", showColumnSettingDialog);
            /// <summary>追加ボタンクリック時のイベント処理を行います。</summary>
            $(".add-button").on("click", function (e) {
                App.ui.page.notifyAlert.clear();
                isAdd = true;
                isCopy = false;
                showDetail(true, false);
            });
            /// <summary>詳細ボタンクリック時のイベント処理を行います。</summary>
            $(".detail-button").on("click", function (e) {
                App.ui.page.notifyAlert.clear();
                isAdd = false;
                isCopy = false;
                showDetail(false, false);
            });
            /// <summary>コピーボタンクリック時のイベント処理を行います。</summary>
            $(".copy-button").on("click", function (e) {
                App.ui.page.notifyAlert.clear();
                isAdd = false;
                isCopy = true;
                showDetail(false, true);
            });
            /// <summary>エクセルボタンクリック時のイベント処理を行います。</summary>
            $(".excel-button").on("click", checkExcel);

            /// <summary>削除ボタンクリック時のイベント処理を行います。</summary>
            $(".delete-button").on("click", deleteCheck);
            /// <summary>削除確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".delete-confirm-dialog .dlg-yes-button").on("click", deleteData);
            /// <summary>削除確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".delete-confirm-dialog .dlg-no-button").on("click", closeDeleteConfirmDialog);
            /// <summary>保存完了ダイアログの「閉じる」ボタンクリック時のイベント処理を行います。</summary>
            $(".delete-complete-dialog .dlg-close-button").on("click", deleteComplete);

            /// <summary>メニューボタンクリック時のイベント処理を行います。</summary>
            $(".menu-button").on("click", backToMenu);
            /// <summary>未保存の状態でページ遷移確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".menu-confirm-dialog .dlg-yes-button").on("click", backToMenu);
            /// <summary>未保存の状態でページ遷移確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".menu-confirm-dialog .dlg-no-button").on("click", closeMenuConfirmDialog);

            //// 詳細画面固有のボタン
            /// <summary>一覧へ戻るボタンクリック時のイベント処理を行います。</summary>
            $(".list-button").on("click", showGridCheck);

            /// <summary>未保存の状態でページ遷移確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".showgrid-confirm-dialog .dlg-yes-button").on("click", showGrid);
            /// <summary>未保存の状態でページ遷移確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".showgrid-confirm-dialog .dlg-no-button").on("click", closeShowgridConfirmDialog);

            /// <summary>保存ボタンクリック時のイベント処理を行います。</summary>
            $(".save-button").on("click", saveCheck);
            /// <summary>保存確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".save-confirm-dialog .dlg-yes-button").on("click", saveData);
            /// <summary>保存確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".save-confirm-dialog .dlg-no-button").on("click", closeSaveConfirmDialog);
            /// <summary>保存完了ダイアログの「閉じる」ボタンクリック時のイベント処理を行います。</summary>
            $(".save-complete-dialog .dlg-close-button").on("click", saveComplete);

            /// <summary>クリアボタンクリック時のイベント処理を行います。</summary>
            $(".clear-button").on("click", showClearConfirmDialog);
            /// <summary>クリア確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".clear-confirm-dialog .dlg-yes-button").on("click", clearData);
            /// <summary>クリア確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".clear-confirm-dialog .dlg-no-button").on("click", closeClearConfirmDialog);

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
            // コンテンツに変更が発生した場合は、
            $(".list-part-detail-content").on("change", function () {
                isChanged = true;
            });

            // 取引先区分による、納入書形式の制御処理
            var controllNonyushoKeishiki = function (kubun, value) {
                if (kubun == "1" || App.isUndefOrNull(kubun)) {
                    $("select[name='nonyusho'] option[value=0]").remove();
                    $("select[name='nonyusho']").attr("disabled", false);
                }
                else {
                    $("select[name='nonyusho']").append($('<option>').html("").val(0));
                    $("select[name='nonyusho']").attr("disabled", true);
                }
                $("select[name='nonyusho']").val(value);
            };

            // コンテンツに変更が発生した場合は、
            $(".list-part-detail-content .select-kbn-torihiki").on("change", function () {
                isChanged = true;

                kbnTorihiki = $(".list-part-detail-content [name='kbn_torihiki']").val();

                // 取引先区分による、納入書形式の制御処理
                var value = 0;
                if (kbnTorihiki === "1") {
                    value = 1;
                }
                controllNonyushoKeishiki(kbnTorihiki, value);
                //if (kbnTorihiki === "1") {
                //    $("select[name='nonyusho'] option[value=0]").remove();
                //    $("select[name='nonyusho']").attr("disabled", false);
                //    $("select[name='nonyusho']").val(1);
                //}
                //else {
                //    $("select[name='nonyusho']").append($('<option>').html("").val(0));
                //    $("select[name='nonyusho']").attr("disabled", true);
                //    $("select[name='nonyusho']").val(0);
                //}
            });
            /// <summary>データに変更があり、未保存の状態でページを離れる際に確認を行います。</summary>
            $(window).on('beforeunload', function () {
                if (isChanged) {
                    return pageLangText.unloadWithoutSave.text;
                }
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
                        <span class="item-label" data-app-text="kbn_torihiki"></span>
                        <select name="kbn_torihiki"></select>
                    </label>
                <br/>
                    <label>
                        <span class="item-label"></span>
                    </label>
                </li>
            </ul>
            <ul class="item-list con-list-right">
                <li>
                    <label>
                        <span class="item-label" data-app-text="nm_torihiki"></span>
                        <input type="text" name="con_nm_torihiki" maxlength ="50" size="40" />
                    </label>
                </li>
                <li>
                    <label>
                        <span class="item-label" data-app-text="display_unused" data-tooltip-text="display_unused"></span>
                        <input type="radio" name="flg_mishiyo" value="1" />
                        <span data-app-text="nm_flg_mishiyo_ari"></span>
                    </label>
                    <label>
                        <input type="radio" name="flg_mishiyo" value="0" checked />
                        <span data-app-text="nm_flg_mishiyo_nashi"></span>
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
                    <button type="button" class="add-button" name="add-button" data-app-operation="add">
                        <span class="icon"></span><span data-app-text="add"></span>
                    </button>
                    <button type="button" class="delete-button" name="delete-button" data-app-operation="del">
                        <span class="icon"></span><span data-app-text="del"></span>
                    </button>
                    <button type="button" class="detail-button" name="detail-button" data-app-operation="detail">
                        <span class="icon"></span><span data-app-text="detail"></span>
                    </button>
                    <button type="button" class="copy-button" name="copy-button" data-app-operation="copy">
                        <span class="icon"></span><span data-app-text="copy"></span>
                    </button>
                </div>

                <table id="item-grid">
                </table>

            </div>
            <div class="list-part-detail-content" style="display: none;">
                <div class="item-command" style="left: 17px; right: 17px;">
                    <button type="button" class="list-button" name="list-button">
                        <span class="icon"></span><span data-app-text="list"></span>
                    </button>
                </div>
                <ul class="content-part" style="height: 4em">
                    <li>
                        <span class="item-label" style="width: 40%; margin-left: 10px; margin-top: 5px;">
                            <span data-app-text="notUse"></span>
                            <input type="checkbox" name="flg_mishiyo" value="1" />
                            <span data-app-text="flg_mishiyo"></span>
                        </span>
                        <span class="item-label" style="width: 40%; margin-top: 5px;">
                            <span data-app-text="dt_create"></span>
                            <span name="dt_create" readonly="readonly" tabindex="-1" class="data-app-format" data-app-format="dateTime"></span>
                        </span>
                    </li>
                    <li>
                        <span class="item-label" style="width: 40%; margin-left: 10px;"></span>
                        <span class="item-label" style="width: 40%;">
                            <span data-app-text="dt_update"></span>
                            <span name="dt_update" readonly="readonly" tabindex="-1" class="data-app-format" data-app-format="dateTime"></span>
                        </span>
                    </li>
                </ul>
                <ul>
                    <li>
                        <label>
                            <span class="item-label" data-app-text=""></span>
                        </label>
                    </li>
                </ul>
                <ul class="item-list item-list-left">
                    <!-- TODO: 画面の仕様に応じて以下の項目を変更してください。 -->
                    <li>
                        <label>
                            <span class="item-label" data-app-text="cd_torihiki"></span>
                            <input type="text" name="cd_torihiki" id="id_cdTorihiki" data-app-validation="cd_torihiki" />
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="nm_torihiki"></span>
                            <input type="text" name="nm_torihiki" data-app-validation="nm_torihiki" />
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="nm_busho"></span>
                            <input type="text" name="nm_busho" data-app-validation="nm_busho" />
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="nm_torihiki_ryaku"></span>
                            <input type="text" name="nm_torihiki_ryaku" />
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="nm_tanto_1"></span>
                            <input type="text" name="nm_tanto_1" data-app-validation="nm_tanto_1" />
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="nm_tanto_2"></span>
                            <input type="text" name="nm_tanto_2" data-app-validation="nm_tanto_2"/>
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="nm_tanto_3"></span>
                            <input type="text" name="nm_tanto_3" data-app-validation="nm_tanto_3"/>
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="nm_jusho"></span>
                            <input type="text" name="no_yubin"/>
                        </label>
                    </li>
                    <!-- TODO: ここまで -->
                </ul>
                <ul class="item-list item-list-right clearfix">
                    <!-- TODO: 画面の仕様に応じて以下の項目を変更してください。 -->
                    <li>
                        <label>
                            <span class="item-label" data-app-text="nm_kbn_torihiki"></span>
                            <select id="detail_kbn_torihiki" class="select-kbn-torihiki" name="kbn_torihiki" data-app-validation="nm_kbn_torihiki">
                            </select>
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="kbn_keishiki_nonyusho"></span>
                            <select name="nonyusho">
                            </select>
                        </label>
                    </li>
                    <li><span class="item-label" data-app-text="kbn_keisho_nonyusho"></span>
                        <label>
                            <input type="radio" name="kbn_keisho_nonyusho" value="1"/><span data-app-text="nm_keisho_sama"></span>
                        </label>
                        <label>
                            <input type="radio" name="kbn_keisho_nonyusho" value="2"/><span data-app-text="nm_keisho_onchu"></span>
                        </label>
                        <label>
                            <input type="radio" name="kbn_keisho_nonyusho" value="3" /><span data-app-text="nm_keisho_nashi"></span>
                        </label>
                    </li>
                    <li>
                        <input type="hidden" name="UpateTimestamp" />
                    </li>
                    <li>
                        <input type="hidden" name="ts" />
                    </li>
                    <li>
                        <input type="hidden" name="cd_create" />
                    </li>
                    <li>
                        <input type="hidden" name="cd_update" />
                    </li>
                    <!-- TODO: ここまで -->
                </ul>
                <ul class="item-list">
                    <!-- TODO: 画面の仕様に応じて以下の項目を変更してください。 -->
                    <li>
                        <label>
                            <span class="item-label"></span>
                            <input type="text" name="nm_jusho" style="width: 550px;" />
                        </label>
                    </li>
                </ul>
                <ul class="item-list item-list-left">
                    <li>
                        <label>
                            <span class="item-label" data-app-text="no_tel"></span>
                            <input type="text" name="no_tel" data-app-validation="no_tel"/>
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="no_fax"></span>
                            <input type="text" name="no_fax" data-app-validation="no_fax"/>
                        </label>
                    </li>
                    <!-- TODO: ここまで -->
                </ul>
                <ul class="item-list item-list-right clearfix">
                    <li>
                        <label>
                            <span class="item-label" data-app-text="cd_maker"></span>
                            <input type="text" name="cd_maker" data-app-validation="cd_maker"  />
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="e_mail"></span>
                            <input type="text" name="e_mail" data-app-validation="e_mail"/>
                        </label>
                    </li>
                    <!-- TODO: ここまで -->
                </ul>
                <ul class="item-list">
                    <!-- TODO: 画面の仕様に応じて以下の項目を変更してください。 -->
                    <li>
                        <label>
                            <span class="item-label" data-app-text="biko"></span>
                            <input type="text" id="biko" name="biko" style="width: 550px;" />
                        </label>
                    </li>
                </ul>

                <div class="clearfix">
                </div>

            </div>
        </div>
    </div>
    <!-- グリッドコントロール固有のデザイン -- End -->
    
    <div class="delete-confirm-dialog" style="display: none;">
        <div class="dialog-header">
            <h4 data-app-text="confirmTitle">
            </h4>
        </div>
        <div class="dialog-body" style="padding: 10px; width: 100%;">
            <div class="part-body">
                <span data-app-text="deleteConfirm"></span>
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
    <div class="save-confirm-dialog" style="display: none;">
        <div class="dialog-header">
            <h4 data-app-text="confirmTitle">
            </h4>
        </div>
        <div class="dialog-body" style="padding: 10px; width: 100%;">
            <div class="part-body">
                <span data-app-text="saveConfirm"></span>
            </div>
        </div>
        <div class="dialog-footer">
            <div class="command-detail" style="position: absolute; left: 10px; top: 5px;">
                <button class="dlg-yes-button" name="dlg-yes-button" data-app-text="yes" >
                </button>
            </div>
            <div class="command-detail" style="position: absolute; right: 5px; top: 5px;">
                <button class="dlg-no-button" name="dlg-no-button" data-app-text="no">
                </button>
            </div>
        </div>
    </div>
    <div class="save-complete-dialog" style="display: none;">
        <div class="dialog-header">
            <h4 data-app-text="confirmTitle">
            </h4>
        </div>
        <div class="dialog-body" style="padding: 10px; width: 100%;">
            <div class="part-body">
                <span data-app-text="saveComplete"></span>
            </div>
        </div>
        <div class="dialog-footer">
            <div class="command-detail" style="position: absolute; left: 10px; top: 5px">
                <button class="dlg-close-button" name="dlg-close-button" data-app-text="close">
                </button>
            </div>
        </div>
    </div>
    <div class="showgrid-confirm-dialog" style="display: none;">
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
            <div class="command-detail" style="position: absolute; left: 10px; top: 5px">
                <button class="dlg-yes-button" name="dlg-yes-button" data-app-text="yes">
                </button>
            </div>
            <div class="command-detail" style="position: absolute; right: 5px; top: 5px;">
                <button class="dlg-no-button" name="dlg-no-button" data-app-text="no">
                </button>
            </div>
        </div>
    </div>
    <div class="clear-confirm-dialog" style="display: none;">
        <div class="dialog-header">
            <h4 data-app-text="confirmTitle">
            </h4>
        </div>
        <div class="dialog-body" style="padding: 10px; width: 100%;">
            <div class="part-body">
                <span data-app-text="clearConfirm"></span>
            </div>
        </div>
        <div class="dialog-footer">
            <div class="command-detail" style="position: absolute; left: 10px; top: 5px">
                <button class="dlg-yes-button" name="dlg-yes-button" data-app-text="yes">
                </button>
            </div>
            <div class="command-detail" style="position: absolute; right: 5px; top: 5px;">
                <button class="dlg-no-button" name="dlg-no-button" data-app-text="no">
                </button>
            </div>
        </div>
    </div>
    <div class="delete-complete-dialog" style="display: none;">
        <div class="dialog-header">
            <h4 data-app-text="confirmTitle"></h4>
        </div>
        <div class="dialog-body" style="padding: 10px; width: 100%;">
            <div class="part-body">
                <span data-app-text="deleteComplete"></span>
            </div>
        </div>
        <div class="dialog-footer">
            <div class="command" style="position: absolute; left: 10px; top: 5px">
                <button class="dlg-close-button" name="dlg-close-button" data-app-text="close"></button>
            </div>
        </div>
    </div>
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
    <div class="command-detail" style="left: 1px; display: none;">
        <button type="button" class="save-button" name="save-button" data-app-operation="save">
            <span class="icon"></span><span data-app-text="save"></span>
        </button>
        <button type="button" class="clear-button" name="clear-button" data-app-operation="clear">
            <span class="icon"></span><span data-app-text="clear"></span>
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
    <!-- 画面デザイン -- End -->
</asp:Content>