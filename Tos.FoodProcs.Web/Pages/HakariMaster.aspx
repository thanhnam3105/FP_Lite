<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="HakariMaster.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.HakariMaster" %>

<asp:Content ID="Content1" ContentPlaceHolderID="IncludeContent" runat="server">
    <script src="<%=ResolveUrl("~/Resources/pages/pagedata-hakarimaster." + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
    <script src="<%=ResolveUrl("~/Resources/grid/grid.locale-" + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        /* 画面デザイン -- Start */
        
        /* TODO：画面の仕様に応じて以下のスタイルを変更してください。 */
        /* ↓add↓ */
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
                isDataLoading = false;

            // グリッドコントロール固有の変数宣言
            var grid = $("#item-grid"),
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
                lastScrollTop = 0,
                changeSet = new App.ui.page.changeSet(),
                isChanged = false;

            // 詳細用コンボボックス
            //fundo,  // 分銅
            //tani,   // 単位
            //baurateKbn,     // ボーレート区分
            //parityKbn,      // パリティ
            //databitKbn,     // データ長
            //stopbitKbn,     // ストップビット
            //handshakeKbn;   // ハンドシェイク
            // TODO: ここまで

            //// 変数宣言 -- End

            //// コントロール定義 -- Start

            // ダイアログ固有の変数宣言
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            var saveConfirmDialog = $(".save-confirm-dialog"),
                saveCompleteDialog = $(".save-complete-dialog"),
                deleteConfirmDialog = $(".delete-confirm-dialog"),
                deleteCompleteDialog = $(".delete-complete-dialog"),
                menuConfirmDialog = $(".menu-confirm-dialog"),
                showgridConfirmDialog = $(".showgrid-confirm-dialog");

            // ダイアログ固有のコントロール定義
            saveConfirmDialog.dlg();
            saveCompleteDialog.dlg();
            deleteConfirmDialog.dlg();
            deleteCompleteDialog.dlg();
            menuConfirmDialog.dlg();
            showgridConfirmDialog.dlg();

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
            var showDeleteConfirmDialog = function () {
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
            var showShowgridConfirmDialog = function () {
                showgridConfirmDialogNotifyInfo.clear();
                showgridConfirmDialogNotifyAlert.clear();
                showgridConfirmDialog.draggable(true);
                showgridConfirmDialog.dlg("open");
            };

            /// <summary>ダイアログを閉じます。</summary>
            var closeSaveConfirmDialog = function () {
                saveConfirmDialog.dlg("close");
            };
            var closeSaveCompleteDialog = function () {
                saveCompleteDialog.dlg("close");
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
            var closeShowgridConfirmDialog = function () {
                showgridConfirmDialog.dlg("close");
            };

            // グリッドコントロール固有のコントロール定義

            /// <summary>詳細を表示します。</summary>
            var showDetail = function (isAdd, selectedRowId) {
                //if (!isAdd) {
                //    var selectedRowId = getSelectedRowId();
                //    if (App.isUndefOrNull(selectedRowId)) {
                //        return;
                //    }
                //}

                // 詳細のcomboxデータを取得
                //getComboxData();

                var detailContent = $(".list-part-detail-content"),
                    gridContent = $(".list-part-grid-content"),
                    row;

                if (isAdd) {
                    row = setAddData();
                }
                else {
                    if (App.isUnusable(selectedRowId)) {
                        return;
                    }
                    row = grid.jqGrid("getRowData", selectedRowId);
                }

                // TODO：画面の仕様に応じて以下の詳細の項目の設定を変更してください。
                // TODO：ここまで

                App.ui.page.notifyAlert.clear();
                // 検索条件、グリッドを非表示にして詳細を表示します。
                $(".search-criteria").hide("fast", function () {
                    gridContent.hide("fast", function () {
                        detailContent.toForm(row);
                        detailContent.show("fast");
                        //$(".search-criteria").hide("fast");

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
                        $("#list-count").text(row.cd_hakari);
                        $("#list-results").on("click", showGrid);
                    }).promise().done(function () {
                        // EXCELボタンを非表示にする
                        $(".command [name='excel-button']").attr("disabled", true).css("display", "none");
                        // 保存ボタンを表示する
                        $(".command [name='save-button']").attr("disabled", false).css("display", "");
                        // 更新の場合(タイムスタンプが存在した場合)
                        var ts = $("#id_ts").val();
                        if (!App.isUndefOrNull(ts) && ts != "") {
                            // 秤コードを編集不可
                            $("#id_cdHakari").attr("readonly", true).css("background-color", "#F2F2F2");
                            var roles = App.ui.page.user.Roles[0];
                            // 権限「Admin」「Operator」「Editor」のときのみ、削除ボタン押下可とする
                            if (roles == pageLangText.admin.text || roles == pageLangText.operator.text || roles == pageLangText.editor.text) {
                                $(".item-command [name='delete-button']").attr("disabled", false).css("display", "");
                            }
                        }
                        else {
                            // 秤コードを入力可
                            $("#id_cdHakari").attr("readonly", false).css("background-color", "");
                            // 削除ボタン非表示
                            $(".item-command [name='delete-button']").attr("disabled", true).css("display", "none");
                        }
                    });
                });
            };

            /// <summary>グリッドを表示します。</summary>
            var showGrid = function () {
                closeShowgridConfirmDialog();
                isChanged = false;

                var d = $.Deferred();
                App.ui.page.notifyAlert.clear();

                // 詳細を非表示にしてグリッド、検索条件を表示します。
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

                    // EXCELボタンを表示する
                    $(".command [name='excel-button']").attr("disabled", false).css("display", "");
                    // 保存ボタンを非表示にする
                    $(".command [name='save-button']").attr("disabled", true).css("display", "none");

                    d.resolve();
                });

                return d.promise();
            };

            var newDateFormat = pageLangText.dateTimeNewFormatUS.text;
            if (App.ui.page.langCountry !== 'en-US') {
                newDateFormat = pageLangText.dateTimeNewFormat.text;
            }

            grid.jqGrid({
                // TODO：画面の仕様に応じて以下の列名の定義を変更してください。
                colNames: [
                    pageLangText.cd_hakari.text,
                    pageLangText.nm_hakari.text,
                    pageLangText.cd_tani.text,
                    pageLangText.nm_tani.text,
                //pageLangText.joken_tushin.text,
                    pageLangText.kbn_baurate.text,
                    pageLangText.kbn_parity.text,
                    pageLangText.kbn_databit.text,
                    pageLangText.kbn_stopbit.text,
                    pageLangText.kbn_handshake.text,
                // 隠し項目用
                    pageLangText.kbn_baurate.text,
                    pageLangText.kbn_parity.text,
                    pageLangText.kbn_databit.text,
                    pageLangText.kbn_stopbit.text,
                    pageLangText.kbn_handshake.text,

                    pageLangText.nm_antei.text,
                    pageLangText.nm_fuantei.text,
                    pageLangText.no_ichi_juryo.text,
                    pageLangText.su_keta.text,
                    pageLangText.su_ichi_fugo.text,
                    pageLangText.cd_fundo.text,
                    pageLangText.wt_fundo.text,
                    //pageLangText.flg_fugo.text,
                    pageLangText.flg_mishiyo.text,
                    pageLangText.cd_create.text,
                    pageLangText.dt_create.text,
                    pageLangText.cd_update.text,
                    pageLangText.dt_update.text,
                    pageLangText.ts.text,
                    pageLangText.flg_hakari_check.text
                ],
                // TODO：画面の仕様に応じて以下の列モデルの定義を変更してください。
                colModel: [
                    { name: 'cd_hakari', width: pageLangText.cd_hakari_width.number, align: "left", sorttype: "text", frozen: true, resizable: true },
                    { name: 'nm_hakari', width: pageLangText.nm_hakari_width.number, align: "left", sorttype: "text", frozen: true, resizable: true },
                    { name: 'cd_tani', width: 0, hidden: true, hidedlg: true },
                    { name: 'nm_tani', width: pageLangText.nm_tani_width.number, align: "left", sorttype: "text" },
                //{ name: 'joken_tushin', width: 80, align: "left", sorttype: "text" },
                    {name: 'nm_kbn_baurate', width: pageLangText.nm_kbn_baurate_width.number, align: "left", sorttype: "text" },
                    { name: 'nm_kbn_parity', width: pageLangText.nm_kbn_parity_width.number, align: "left", sorttype: "text" },
                    { name: 'nm_kbn_databit', width: pageLangText.nm_kbn_databit_width.number, align: "left", sorttype: "text" },
                    { name: 'nm_kbn_stopbit', width: pageLangText.nm_kbn_stopbit_width.number, align: "left", sorttype: "text" },
                    { name: 'nm_kbn_handshake', width: pageLangText.nm_kbn_handshake_width.number, align: "left", sorttype: "text" },
                    { name: 'kbn_baurate', width: 0, hidden: true, hidedlg: true },
                    { name: 'kbn_parity', width: 0, hidden: true, hidedlg: true },
                    { name: 'kbn_databit', width: 0, hidden: true, hidedlg: true },
                    { name: 'kbn_stopbit', width: 0, hidden: true, hidedlg: true },
                    { name: 'kbn_handshake', width: 0, hidden: true, hidedlg: true },
                    { name: 'nm_antei', width: pageLangText.nm_antei_width.number, align: "center", sorttype: "text" },
                    { name: 'nm_fuantei', width: pageLangText.nm_fuantei_width.number, align: "center", sorttype: "text" },
                    { name: 'no_ichi_juryo', width: pageLangText.no_ichi_juryo_width.number, align: "right", sorttype: "int" },
                    { name: 'su_keta', width: pageLangText.su_keta_width.number, align: "right", sorttype: "int" },
                    { name: 'su_ichi_fugo', width: pageLangText.su_ichi_fugo_width.number, align: "right", sorttype: "int" },
                    { name: 'cd_fundo', width: 0, hidden: true, hidedlg: true },
                    { name: 'wt_fundo', width: pageLangText.wt_fundo_width.number, align: "right", sorttype: "int" },
//                    { name: 'flg_fugo', width: pageLangText.flg_fugo_width.number, editable: false, edittype: "checkbox",
//                        editoptions: { value: "1:0" }, formatter: "checkbox", align: 'center'
//                    },
                    { name: 'flg_mishiyo', width: pageLangText.flg_mishiyo_width.number, editable: false, edittype: "checkbox",
                        editoptions: { value: "1:0" }, formatter: "checkbox", align: 'center'
                    },
                    { name: 'cd_create', width: 0, hidden: true, hidedlg: true },
                    { name: 'dt_create', width: 0, hidden: true, hidedlg: true,
                        formatter: "date",
                        formatoptions: {
                            srcformat: newDateFormat, newformat: newDateFormat
                        }
                    },
                    { name: 'cd_update', width: 0, hidden: true, hidedlg: true },
                    { name: 'dt_update', width: 0, hidden: true, hidedlg: true,
                        formatter: "date",
                        formatoptions: {
                            srcformat: newDateFormat, newformat: newDateFormat
                        }
                    },
                    { name: 'ts', width: 0, hidden: true, hidedlg: true },
                    { name: 'flg_hakari_check', width: pageLangText.flg_mishiyo_width.number, editable: false, edittype: "checkbox",
                        editoptions: { value: "1:0" }, formatter: "checkbox", align: 'center'
                    }
                  ],
                // TODO：ここまで
                datatype: "local",
                shrinkToFit: false,
                multiselect: false,
                rownumbers: true,
                hoverrows: false,
                loadComplete: function () {
                    // グリッドの先頭行選択
                    grid.setSelection(1, false);
                },
                ondblClickRow: function (selectedRowId) {
                    //showDetail(false);
                    getComboxData(false);
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

            //// 操作制御定義 -- Start

            // 操作制御定義を定義します。
            App.ui.pagedata.operation.applySetting(App.ui.page.user.Roles[0], App.ui.page.lang);

            //// 操作制御定義 -- End

            //// 事前データロード -- Start

            // 画面アーキテクチャ共通の事前データロード
            var loading,
                baurateKbn,     // ボーレート区分
                parityKbn,      // パリティ
                databitKbn,     // データ長
                stopbitKbn,     // ストップビット
                handshakeKbn;   // ハンドシェイク

            App.deferred.parallel({
                // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                // ローディング
                loading: App.ui.loading.show(pageLangText.nowProgressing.text),
                // ボーレート区分
                baurateKbn: App.ajax.webget("../Services/FoodProcsService.svc/ma_kbn_baurate?$orderby=kbn_baurate"),
                // パリティ
                parityKbn: App.ajax.webget("../Services/FoodProcsService.svc/ma_kbn_parity?$orderby=kbn_parity"),
                // データ長
                databitKbn: App.ajax.webget("../Services/FoodProcsService.svc/ma_kbn_databit?$orderby=kbn_databit"),
                // ストップビット
                stopbitKbn: App.ajax.webget("../Services/FoodProcsService.svc/ma_kbn_stopbit?$orderby=kbn_stopbit"),
                // ハンドシェイク
                handshakeKbn: App.ajax.webget("../Services/FoodProcsService.svc/ma_kbn_handshake?$orderby=kbn_handshake")
                // TODO: ここまで
            }).done(function (result) {
                // TODO: 画面の仕様に応じて以下のサービス呼び出し成功時の処理を変更してください。
                var baurateKbn = result.successes.baurateKbn.d,
                    parityKbn = result.successes.parityKbn.d,
                    databitKbn = result.successes.databitKbn.d,
                    stopbitKbn = result.successes.stopbitKbn.d,
                    handshakeKbn = result.successes.handshakeKbn.d;

                App.ui.appendOptions($(".list-part-detail-content [name='kbn_baurate']"), "kbn_baurate", "nm_kbn_baurate", baurateKbn, true);
                App.ui.appendOptions($(".list-part-detail-content [name='kbn_parity']"), "kbn_parity", "nm_kbn_parity", parityKbn, true);
                App.ui.appendOptions($(".list-part-detail-content [name='kbn_databit']"), "kbn_databit", "nm_kbn_databit", databitKbn, true);
                App.ui.appendOptions($(".list-part-detail-content [name='kbn_stopbit']"), "kbn_stopbit", "nm_kbn_stopbit", stopbitKbn, true);
                App.ui.appendOptions($(".list-part-detail-content [name='kbn_handshake']"), "kbn_handshake", "nm_kbn_handshake", handshakeKbn, true);
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

            /// 詳細画面のコンボボックスデータ取得処理
            // 単位と標準分銅はリアルタイムに反映したい為、詳細を開くタイミングで毎回読み込む
            var getComboxData = function (isAdd) {
                // チェック処理
                if (!isAdd) {
                    var selectedRowId = getSelectedRowId();
                    if (App.isUndefOrNull(selectedRowId)) {
                        return;
                    }
                }

                var fundo,  // 分銅
                    tani;   // 単位
                // comboxのクリア
                $(".item-combox option").remove();

                App.deferred.parallel({
                    // ローディングの表示
                    loading: App.ui.loading.show(pageLangText.nowProgressing.text),

                    // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                    // 単位
                    tani: App.ajax.webget("../Services/FoodProcsService.svc/ma_tani?$filter=flg_mishiyo eq "
                        + pageLangText.shiyoMishiyoFlg.text + "&$orderby=cd_tani"),
                    // 分銅
                    fundo: App.ajax.webget("../Services/FoodProcsService.svc/ma_fundo?$filter=flg_mishiyo eq "
                        + pageLangText.shiyoMishiyoFlg.text + "&$orderby=cd_fundo") //未使用フラグ０のものだけを取得
                    // TODO: ここまで
                }).done(function (result) {
                    // TODO: 画面の仕様に応じて以下のサービス呼び出し成功時の処理を変更してください。
                    var cd_tani = result.successes.tani.d,
                        cd_fundo = result.successes.fundo.d;

                    // 詳細用ドロップダウンの設定
                    App.ui.appendOptions($(".list-part-detail-content [name='cd_tani']"), "cd_tani", "nm_tani", cd_tani, true);
                    App.ui.appendOptions($(".list-part-detail-content [name='cd_fundo']"), "cd_fundo", "wt_fundo", cd_fundo, true);
                    setLiteral("cd_hakari", pageLangText.cd_hakari.text, true);
                    setLiteral("nm_antei", pageLangText.nm_antei.text, true);
                    setLiteral("nm_hakari", pageLangText.nm_hakari.text, true);
                    setLiteral("nm_fuantei", pageLangText.nm_fuantei.text, true);
                    setLiteral("cd_tani", pageLangText.cd_tani.text, true);
                    setLiteral("no_ichi_juryo", pageLangText.no_ichi_juryo.text, true);
                    setLiteral("kbn_baurate", pageLangText.kbn_baurate.text, true);
                    setLiteral("su_keta", pageLangText.su_keta.text, true);
                    setLiteral("kbn_parity", pageLangText.kbn_parity.text, true);
                    setLiteral("su_ichi_fugo", pageLangText.su_ichi_fugo.text, true);
                    setLiteral("kbn_databit", pageLangText.kbn_databit.text, true);
                    setLiteral("cd_fundo", pageLangText.cd_fundo.text, true);
                    setLiteral("kbn_stopbit", pageLangText.kbn_stopbit.text, true);
                    // setLiteral("flg_fugo", pageLangText.flg_fugo.text, true);
                    setLiteral("kbn_handshake", pageLangText.kbn_handshake.text, true);

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
                    // ローディングの終了
                    App.ui.loading.close();
                    // 詳細画面を開く
                    showDetail(isAdd, selectedRowId);
                });
            };

            //// カンマ区切り処理
            var splitComma = function (str) {
                str = str.replace(/,/g, '');
                if (str.match(/^(|-)[0-9]+$/)) {
                    str = str.replace(/^[0]+([0-9]+)/g, '$1');
                    str = str.replace(/([0-9]{1,3})(?=(?:[0-9]{3})+$)/g, '$1,');
                }
                return str;
            };
            //// カンマ区切りで表示する
            var setComma = function (target) {
                var targetVal = target.val();
                var val = targetVal.indexOf(".", 0);
                if (val == -1) {
                    var str = splitComma(targetVal);
                    target.val(str);
                }
                else {
                    var splitVal = targetVal.split('.');
                    var result = splitComma(splitVal[0]);
                    target.val(result + "." + splitVal[1]);
                }
            };

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
                var query = {
                    // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                    url: "../Services/FoodProcsService.svc/vw_ma_hakari_01",
                    // TODO: ここまで
                    filter: createFilter(),
                    orderby: "cd_hakari",
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
                //filters.push("mt_flg_mishiyo eq " + pageLangText.shiyoMishiyoFlg.text);
                //filters.push("mf_flg_mishiyo eq " + pageLangText.shiyoMishiyoFlg.text);
                if (!App.isUndefOrNull(criteria.nm_hakari) && criteria.nm_hakari.length > 0) {
                    filters.push(("(substringof('" + encodeURIComponent(criteria.nm_hakari)
                        + "', nm_hakari) eq true or substringof('" + encodeURIComponent(criteria.nm_hakari) + "', cd_hakari) eq true)"));
                }
                if (criteria.flg_mishiyo_kensaku === "0") {
                    filters.push("flg_mishiyo eq " + criteria.flg_mishiyo_kensaku);
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
                $("#list-loading-message").text(pageLangText.nowLoading.text);
                App.ajax.webget(
                // WCF Data ServicesのODataシステムクエリオプションを生成
                    App.data.toODataFormat(query)
                ).done(function (result) {
                    // データバインド
                    bindData(result);
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
            /// <summary>検索ボタンクリック時のイベント処理を行います。</summary>
            $(".find-button").on("click", function () {
                clearState();
                showGrid().done(function () {
                    searchItems(new query())
                });
            });

            // グリッドコントロール固有の検索処理

            /// <summary>検索前の状態に初期化します。</summary>
            var clearState = function () {
                // データクリア
                grid.clearGridData();
                lastScrollTop = 0;
                querySetting.skip = 0;
                querySetting.count = 0;
                displayCount();

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

                // 検索結果が上限数を超えていた場合
                if (parseInt(querySetting.count) > querySetting.top) {
                    querySetting.skip = querySetting.top;
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
            /*
            /// <summary>後続データ検索を行います。</summary>
            /// <param name="target">グリッド</param>
            var nextSearchItems = function (target) {
            var scrollTop = lastScrollTop;
            if (scrollTop == target.scrollTop) {
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
            */

            //// 検索処理 -- End

            //// メッセージ表示 -- Start
            //// メッセージ表示 -- End

            //// データ変更処理 -- Start

            /// <summary>新規行データの設定を行います。</summary>
            var setAddData = function () {
                // TODO: 画面の仕様に応じて以下の項目を変更してください。
                var addData = {
                    "cd_hakari": "",
                    "nm_hakari": "",
                    "cd_tani": "",
                    "kbn_baurate": "",
                    "kbn_parity": "",
                    "kbn_databit": "",
                    "kbn_stopbit": "",
                    "kbn_handshake": "",
                    "nm_antei": "",
                    "nm_fuantei": "",
                    "su_keta": "",
                    "su_ichi_dot": 0,
                    "su_ichi_fugo": "",
                    "cd_fundo": "",
                    "flg_fugo": 0,
                    "no_ichi_juryo": "",
                    "flg_mishiyo": 0,
                    "dt_create": "",
                    "cd_create": "",
                    "dt_update": "",
                    "cd_update": "",
                    "ts": ""
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
                // 選択行なしの場合の行選択
                if (App.isUnusable(selectedRowId)) {
                    //  selectedRowId = ids[recordCount - 1]; //最終行
                    selectedRowId = ids[0]; // 先頭行
                }
                currentRow = $('#' + selectedRowId)[0].rowIndex;

                return selectedRowId;
            };

            //// データ変更処理 -- End

            //// 保存処理 -- Start

            // グリッド固有の保存処理
            // コンテンツに変更が発生した場合は、
            $(".list-part-detail-content").on("change", function () {
                isChanged = true;
            });

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
                    else {
                        App.ui.page.notifyAlert.message(
                            pageLangText.unDeletableRecord.text + ret[0].Message).show();
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
                        var upData = {
                            "cd_hakari": upCurrent.cd_hakari,
                            "nm_hakari": upCurrent.nm_hakari,
                            "cd_tani": upCurrent.cd_tani,
                            "kbn_baurate": upCurrent.kbn_baurate,
                            "kbn_parity": upCurrent.kbn_parity,
                            "kbn_databit": upCurrent.kbn_databit,
                            "kbn_stopbit": upCurrent.kbn_stopbit,
                            "kbn_handshake": upCurrent.kbn_handshake,
                            "nm_antei": upCurrent.nm_antei,
                            "nm_fuantei": upCurrent.nm_fuantei,
                            "su_keta": upCurrent.su_keta,
                            "su_ichi_dot": upCurrent.su_ichi_dot,
                            "su_ichi_fugo": upCurrent.su_ichi_fugo,
                            "cd_fundo": upCurrent.cd_fundo,
                            "flg_fugo": upCurrent.flg_fugo,
                            "no_ichi_juryo": upCurrent.no_ichi_juryo,
                            "dt_create": getFormatDate(upCurrent.dt_create),
                            "cd_create": upCurrent.cd_create,
                            "dt_update": getFormatDate(upCurrent.dt_update),
                            "cd_update": upCurrent.cd_update,
                            "flg_mishiyo": upCurrent.flg_mishiyo,
                            "no_com": upCurrent.no_com,
                            "ts": upCurrent.ts
                        };
                        // TODO: ここまで

                        // カレントのデータを詳細画面へ表示
                        detailContent.toForm(upData);

                        // エラーメッセージの表示
                        App.ui.page.notifyAlert.message(
                                        pageLangText.duplicate.text + pageLangText.updatedDuplicate.text).show();
                    }

                }
                // 削除時同時実行制御エラーのハンドリングを行います。
                if (!App.isUndefOrNull(ret.Deleted) && ret.Deleted.length > 0) {
                    var delCurrent = ret.Deleted[0].Current;
                    // 他のユーザーによって削除されていた場合
                    if (App.isUndefOrNull(delCurrent)) {
                        // メッセージの表示
                        App.ui.page.notifyAlert.message(
                            pageLangText.duplicate.text + pageLangText.deletedDuplicate.text).show();
                    }
                    else {
                        detailContent = $(".list-part-detail-content");
                        // TODO: 画面の仕様に応じて更新後のデータ状態をセットします
                        var delData = {
                            "cd_hakari": delCurrent.cd_hakari,
                            "nm_hakari": delCurrent.nm_hakari,
                            "cd_tani": delCurrent.cd_tani,
                            "kbn_baurate": delCurrent.kbn_baurate,
                            "kbn_parity": delCurrent.kbn_parity,
                            "kbn_databit": delCurrent.kbn_databit,
                            "kbn_stopbit": delCurrent.kbn_stopbit,
                            "kbn_handshake": delCurrent.kbn_handshake,
                            "nm_antei": delCurrent.nm_antei,
                            "nm_fuantei": delCurrent.nm_fuantei,
                            "su_keta": delCurrent.su_keta,
                            "su_ichi_dot": delCurrent.su_ichi_dot,
                            "su_ichi_fugo": delCurrent.su_ichi_fugo,
                            "cd_fundo": delCurrent.cd_fundo,
                            "flg_fugo": delCurrent.flg_fugo,
                            "no_ichi_juryo": delCurrent.no_ichi_juryo,
                            "dt_create": getFormatDate(delCurrent.dt_create),
                            "cd_create": delCurrent.cd_create,
                            "dt_update": getFormatDate(delCurrent.dt_update),
                            "cd_update": delCurrent.cd_update,
                            "flg_mishiyo": delCurrent.flg_mishiyo,
                            "no_com": delCurrent.no_com,
                            "ts": delCurrent.ts
                        };
                        // TODO: ここまで

                        // カレントのデータを詳細画面へ表示
                        detailContent.toForm(delData);

                        // エラーメッセージの表示
                        App.ui.page.notifyAlert.message(
                                        pageLangText.duplicate.text + pageLangText.updatedDuplicate.text).show();
                    }
                }
            };

            // <summary>データに変更がないかどうかを返します。</summary>
            var noChange = function () {
                return (App.isUnusable(changeSet) || changeSet.noChange());
            };

            /// <summary>更新データを取得します。</summary>
            var getPostData = function () {
                return changeSet.getChangeSet();
            };

            /// <summary>変更を保存します。</summary>
            /// <param name="e">イベントデータ</param>
            //  更新前処理
            var saveCheck = function (e) {
                // 変更がない場合は処理を抜ける
                if (!isChanged) {
                    App.ui.page.notifyInfo.message(pageLangText.noChange.text).show();
                    return;
                }

                // 情報メッセージのクリア
                App.ui.page.notifyInfo.clear();

                var detailContent = $(".list-part-detail-content"),
                    result;
                // 変更セット内にバリデーションエラーがある場合は処理を抜ける
                result = detailContent.validation().validate();
                if (result.errors.length) {
                    return;
                }
                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();
                // 確認メッセージ
                showSaveConfirmDialog();
            };

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
                if (!App.isUndefOrNull(postData.ts)) {
                    postData["cd_update"] = App.ui.page.user.Code;
                }
                else {
                    postData["cd_create"] = App.ui.page.user.Code;
                    postData["cd_update"] = App.ui.page.user.Code;
                };
                // TODO: ここまで
                var changeSet = new App.ui.page.changeSet();

                // TODO: 画面の仕様に応じて新規/更新にて処理を変更してください。
                if (!App.isUndefOrNull(postData.ts)) {
                    changeSet.addUpdated(App.uuid, null, null, postData);
                }
                else {
                    changeSet.addCreated(App.uuid, postData);
                }
                // TODO: ここまで
                var data = changeSet.getChangeSet();
                // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                var saveUrl = "../api/HakariMaster";
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


            /// <summary>削除します。</summary>
            /// <param name="e">イベントデータ</param>
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

            //  削除
            var deleteData = function (e) {
                closeDeleteConfirmDialog();
                // 情報メッセージのクリア
                App.ui.page.notifyInfo.clear();

                // ローディングの表示
                App.ui.loading.show(pageLangText.nowSaving.text);

                var detailContent = $(".list-part-detail-content"),
                    result;
                // 変更セット内にバリデーションエラーがある場合は処理を抜ける
                // チェックしない
                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();

                // 更新データをJSONオブジェクトに変換
                var postData = detailContent.toJSON();
                var changeSet = new App.ui.page.changeSet();
                if (postData.ts != null) {
                    changeSet.addDeleted(App.uuid, postData);
                }
                var data = changeSet.getChangeSet();
                // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                var saveUrl = "../api/HakariMaster";
                // TODO: ここまで

                App.ajax.webpost(
                    saveUrl, data
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

            //// バリデーション -- End

            /// <summary>追加ボタンボタンクリック時のイベント処理を行います。</summary>
            $(".add-button").on("click", function (e) {
                //showDetail(true);
                getComboxData(true);
            });

            /// <summary>詳細ボタンクリック時のイベント処理を行います。</summary>
            $(".detail-button").on("click", function (e) {
                //showDetail(false);
                getComboxData(false);
            });


            /// <summary>一覧へ戻るボタンクリック時のイベント処理を行います。</summary>
            var showGridCheck = function () {
                if (isChanged) {
                    showShowgridConfirmDialog();
                }
                else {
                    showGrid();
                };
            };
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

            /// <summary>削除ボタンクリック時のイベント処理を行います。</summary>
            $(".delete-button").on("click", deleteCheck);
            /// <summary>削除確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".delete-confirm-dialog .dlg-yes-button").on("click", deleteData);
            /// <summary>削除確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".delete-confirm-dialog .dlg-no-button").on("click", closeDeleteConfirmDialog);
            /// <summary>削除完了ダイアログの「閉じる」ボタンクリック時のイベント処理を行います。</summary>
            $(".delete-complete-dialog .dlg-close-button").on("click", deleteComplete);

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
                container: ".save-Complete-dialog .dialog-slideup-area .alert-message",
                messageContainerQuery: "ul",
                show: function () {
                    saveCompleteDialog.find(".alert-message").show();
                },
                clear: function () {
                    saveCompleteDialog.find(".alert-message").hide();
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
                container: ".delete-Complete-dialog .dialog-slideup-area .alert-message",
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

            /// <summary>Excelファイル出力を行います。</summary>
            var printExcel = function (e) {
                isChanged = false;
                var criteria = $(".search-criteria").toJSON();
                // TODO：画面の入力項目をURLへ渡す
                url = "../api/HakariMasterIchiranExcel";

                // 必要な引数を渡します 
                if (!App.isUndefOrNull(criteria.nm_hakari)) {
                    url += "?nm_hakari=" + criteria.nm_hakari;
                }
                else {
                    url += "?nm_hakari=" + "";
                }
                url += "&flg_mishiyo_kensaku=" + criteria.flg_mishiyo_kensaku;
                url += "&lang=" + App.ui.page.lang;
                url += "&userName=" + App.ui.page.user.Name;

                // TODO: ここまで

                window.open(url, '_parent');
            };

            /// <summary>エクセルボタンクリック時のイベント処理を行います。</summary>
            $(".excel-button").on("click", printExcel);

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
                closeMenuConfirmDialog();
                isChanged = false;
                window.location = pageLangText.menuPath.url;
            };
            /// <summary>メニューボタンクリック時のイベント処理を行います。</summary>
            $(".menu-button").on("click", backToMenuCheck);
            /// <summary>未保存の状態でページ遷移確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".menu-confirm-dialog .dlg-yes-button").on("click", backToMenu);
            /// <summary>未保存の状態でページ遷移確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".menu-confirm-dialog .dlg-no-button").on("click", closeMenuConfirmDialog);

            // <summary>数値項目に関する各イベント処理</summary>
            $("#id_no_ichi_juryo, #id_su_keta, #id_su_ichi_fugo")
                .focusout(function () {
                    var target = $(this);

                    // 値が空の場合、0を設定する
                    var val = target.val();
                    if (App.isUndefOrNull(val) || val == "") {
                        target.val(0);
                    }
                    // カンマ区切り付与
                    setComma(target);
                })
                .focusin(function () {
                    var target = $(this);

                    // カンマ区切りを外す
                    var str = target.val();
                    str = str.replace(/,/g, '');
                    target.val(str);
                });

            /// <summary>データに変更があり、未保存の状態でページを離れる際に確認を行います。</summary>
            $(window).on('beforeunload', function () {
                if (isChanged) {
                    return pageLangText.unloadWithoutSave.text;
                }
            });

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
                        <span class="item-label" data-app-text="nm_hakari"></span>
                        <input type="text" name="nm_hakari" maxlength="50" size="30" />
                    </label>
                </li>
                <li>
                    <span class="item-label" data-app-text="flg_mishiyo_kensaku"></span>
                    <label>
                         <input type="radio" name="flg_mishiyo_kensaku" value="1" />
                         <span class="item-label" data-app-text="ari" style="width: 60px;"></span>
                    </label>
                    <label>
                         <input type="radio" name="flg_mishiyo_kensaku" value="0" checked />
                         <span class="item-label" data-app-text="nashi" style="width: 60px;"></span>
                    </label>
　              </li>
                <!-- TODO: ここまで -->
            </ul>
        </div>
        <div class="part-footer">
            <div class="command">
                <button type="button" class="find-button">
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
            <span data-app-text="resultList" style="padding-right: 10px; padding-bottom: 4px;" id="list-results" ></span>
            <span class="list-count" id="list-count" ></span>
            <span style="padding-left: 50px;" class="list-loading-message" id="list-loading-message" ></span>
        </h3>
        <div class="part-body" id="result-grid">
            <div class="list-part-grid-content">
                <div class="item-command" style="left: 17px; right: 17px;">
                    <button type="button" class="colchange-button"><span class="icon"></span><span data-app-text="colchange"></span></button>
                    <button type="button" class="add-button" name="add-button" data-app-operation="add"><span class="icon"></span><span data-app-text="add"></span></button>
                    <button type="button" class="detail-button" name="detail-button"><span class="icon"></span><span data-app-text="detail"></span></button>
                </div>
                <table id="item-grid">
                </table>
            </div>
            
            <div class="list-part-detail-content" style="display:none;">
                <div class="item-command" style="left: 17px; right: 17px; height: 30px;">
                    <button type="button" class="list-button" name="list-button"><span class="icon"></span><span data-app-text="list"></span></button>
                    <!-- <button type="button" class="save-button" name="save-button" data-app-operation="save"><span class="icon"></span><span data-app-text="save"></span></button> -->
                    <button type="button" class="delete-button" name="delete-button" data-app-operation="del"><span class="icon"></span><span data-app-text="del"></span></button>
                </div>

                <ul class="item-list item-list-left">
                    <!-- TODO: 画面の仕様に応じて以下の項目を変更してください。 -->
                    <li>
                        <label>
                            <span class="item-label" data-app-text="flg_mishiyo_shosai"></span>
                            <input type="checkbox" name="flg_mishiyo" data-app-validation="flg_mishiyo" value="1" checked />
                            <span class="item-label" data-app-text="flg_mishiyo"></span>
                        </label>
                    </li>
                    <li>
                    <!-- 空白行を入れたいだけです -->
                        <label>
                          <span class="item-label" data-app-text=""></span>
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="cd_hakari"></span>
                            <input type="text" id="id_cdHakari" name="cd_hakari" data-app-validation="cd_hakari" />
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="nm_hakari"></span>
                            <input type="text" name="nm_hakari" data-app-validation="nm_hakari" />
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="nm_tani"></span>
                            <select class="item-combox" name="cd_tani" data-app-validation="cd_tani"></select>
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="kbn_baurate"></span>
                            <select name="kbn_baurate" data-app-validation="kbn_baurate"></select>
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="kbn_parity"></span>
                            <select name="kbn_parity" data-app-validation="kbn_parity"></select>
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="kbn_databit"></span>
                            <select name="kbn_databit" data-app-validation="kbn_databit"></select>
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="kbn_stopbit"></span>
                            <select name="kbn_stopbit" data-app-validation="kbn_stopbit"></select>
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="kbn_handshake"></span>
                            <select name="kbn_handshake" data-app-validation="kbn_handshake"></select>
                        </label>
                    </li>
                    <li></li>
                   <!-- TODO: ここまで -->

                </ul>
                <ul class="item-list item-list-right clearfix">
                    <!-- TODO: 画面の仕様に応じて以下の項目を変更してください。 -->
                    <li>
                        <label>
                            <span class="item-label" data-app-text="dt_create"></span>
                            <span class="item-label" id="id_dt_create" name="dt_create" data-app-format="dateTime" style="width: 160px;"></span>
                            <!-- <input class="readonly-txt" type="text" name="dt_create" data-app-format="dateTime" readonly="readonly" /> -->
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="dt_update"></span>
                            <span class="item-label" id="id_dt_update" name="dt_update" data-app-format="dateTime" style="width: 160px;"></span>
                            <!-- <input class="readonly-txt" type="text" name="dt_update" data-app-format="dateTime" readonly="readonly" /> -->
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="nm_antei"></span>
                            <input type="text" name="nm_antei" data-app-validation="nm_antei" />
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="nm_fuantei"></span>
                            <input type="text" name="nm_fuantei"  data-app-validation="nm_fuantei" />
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="no_ichi_juryo"></span>
                            <input type="text" id="id_no_ichi_juryo" class="text-align-right" name="no_ichi_juryo" data-app-validation="no_ichi_juryo" />
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="su_keta"></span>
                            <input type="text" id="id_su_keta" name="su_keta" class="text-align-right data-app-number" data-app-validation="su_keta" />
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="su_ichi_fugo"></span>
                            <input type="text" id="id_su_ichi_fugo" class="text-align-right data-app-number" type="text" name="su_ichi_fugo" data-app-validation="su_ichi_fugo" />
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="wt_fundo"></span>
                            <select class="item-combox" name="cd_fundo" data-app-validation="cd_fundo"></select>
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="flg_hakari_check"></span>
                            <input type="checkbox" name="flg_hakari_check"  value="1" checked="checked" />
                        </label>
                    </li>
                    <!--
                    <li>
                        <label>
                            <span class="item-label" data-app-text="disp_fugo"></span>
                            <input type="checkbox" name="flg_fugo" data-app-validation="flg_fugo" value="1" checked="checked" />
                             <span class="item-label" data-app-text="dispFugoMsg"></span>
                        </label>
                    </li>
                    -->
                    <li>
                        <input type="hidden" id="id_ts" name="ts" />
                    </li>
                    <li>
                        <input type="hidden" name="cd_create" />
                    </li>
                    <li>
                        <input type="hidden" name="cd_update" />
                    </li>
                    <!-- TODO: ここまで -->
                </ul>
                <div class="clearfix">
                </div>
            </div>
        </div>
        <!-- グリッドコントロール固有のデザイン -- End -->
    </div>
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
    <div class="save-complete-dialog" style="display: none;">
        <div class="dialog-header">
            <h4 data-app-text="confirmTitle"></h4>
        </div>
        <div class="dialog-body" style="padding: 10px; width: 100%;">
            <div class="part-body">
                <span data-app-text="saveComplete"></span>
            </div>
        </div>
        <div class="dialog-footer">
            <div class="command" style="position: absolute; left: 10px; top: 5px">
                <button class="dlg-close-button" name="dlg-close-button" data-app-text="close"></button>
            </div>
        </div>
    </div>
    <div class="delete-confirm-dialog" style="display: none;">
        <div class="dialog-header">
            <h4 data-app-text="confirmTitle"></h4>
        </div>
        <div class="dialog-body" style="padding: 10px; width: 100%;">
            <div class="part-body">
                <span data-app-text="deleteConfirm"></span>
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
    <div class="showgrid-confirm-dialog" style="display: none;">
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
<asp:Content ID="Content4" ContentPlaceHolderID="FooterContent" runat="server">
    <!-- 画面デザイン -- Start -->

    <!-- 画面アーキテクチャ共通のデザイン -- Start -->
    <div class="command" style="left: 1px;">
        <button type="button" class="excel-button" name="excel-button"><span data-app-text="excel"></span></button>
        <button type="button" class="save-button" name="save-button" data-app-operation="save" style="display: none;">
            <span class="icon"></span><span data-app-text="save"></span>
        </button>
    </div>
    <div class="command" style="right: 9px;">
        <button type="button" class="menu-button" name="menu-button"><span class="icon"></span><span data-app-text="menu"></span></button>
    </div>
    <!-- 画面アーキテクチャ共通のデザイン -- End -->

    <!-- 画面デザイン -- End -->
</asp:Content>
<asp:Content ID="Content5" ContentPlaceHolderID="DialogsContent" runat="server">
    <!-- 画面デザイン -- Start -->
    <!-- 画面デザイン -- End -->
</asp:Content>
