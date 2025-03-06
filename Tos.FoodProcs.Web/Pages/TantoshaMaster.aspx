<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="TantoshaMaster.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.TantoshaMaster" %>

<asp:Content ID="Content1" ContentPlaceHolderID="IncludeContent" runat="server">
    <script src="<%=ResolveUrl("~/Resources/pages/pagedata-tantoshamaster." + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
    <script src="<%=ResolveUrl("~/Resources/grid/grid.locale-" + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        /* 画面デザイン -- Start */
        
        /* TODO：画面の仕様に応じて以下のスタイルを変更してください。 */
        .list-part-detail-content .item-list-left {
            float: left;
            width: 600px;
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

        .part-header {
            line-height: 30px!important;
        }

        .list-part-detail-content .item-label {
            width: 15em;
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
                querySetting = { skip: 0, top: pageLangText.topCount500.text, count: 0 },
                isDataLoading = false;

            // グリッドコントロール固有の変数宣言
            var grid = $("#item-grid"),
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            // IDプールより取得する権限コンボを作成
                kengenKubun = pageLangText.kengenKubunId.data,
                kubunRoleCommon = pageLangText.roleNewId.data,
                criteriaSelector = $(".search-criteria"),
                loading,
                isAdd = false, // 新規の時ＯＮ
                isSearch = false, // 検索次ＯＮ
                isCriteriaChange = false, // 検索条件変更時ＯＮ
                isResetPass = false, // パスワード変更時ＯＮ
                isChangeDetail = false, // 詳細変更時ＯＮ
                lastScrollTop = 0,
                nextScrollTop = 0;
            // TODO: ここまで

            // ダイアログ固有の変数宣言
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            var saveConfirmDialog = $(".save-confirm-dialog"),
                gridConfirmDialog = $(".showgrid-confirm-dialog"),
                deleteConfirmDialog = $(".delete-confirm-dialog"),
                searchConfirmDialog = $(".search-confirm-dialog");
            // TODO：ここまで

            //// 変数宣言 -- End

            //// コントロール定義 -- Start

            // ダイアログ固有のコントロール定義
            saveConfirmDialog.dlg();
            gridConfirmDialog.dlg();
            deleteConfirmDialog.dlg();
            searchConfirmDialog.dlg();

            /// <summary>ダイアログを開きます。</summary>
            var showSaveConfirmDialog = function () {
                // ダイアログオープン
                saveConfirmDialogNotifyInfo.clear();
                saveConfirmDialogNotifyAlert.clear();
                saveConfirmDialog.draggable(true);
                saveConfirmDialog.dlg("open");
            };
            // 一覧表示時のダイアログ
            var showGridConfirmDialog = function () {
                // 検索前に変更をチェック
                if (!isChangeDetail) {
                    showGrid();
                }
                else {
                    gridConfirmDialogNotifyInfo.clear();
                    gridConfirmDialogNotifyAlert.clear();
                    gridConfirmDialog.draggable(true);
                    gridConfirmDialog.dlg("open");
                }
            };
            // 検索時のダイアログ
            var showSearchConfirmDialog = function () {
                // 検索前に変更をチェック
                if (!isChangeDetail) {
                    findData();
                }
                else {
                    searchConfirmDialogNotifyInfo.clear();
                    searchConfirmDialogNotifyAlert.clear();
                    searchConfirmDialog.draggable(true);
                    searchConfirmDialog.dlg("open");
                }
            };
            // 削除時のダイアログ
            var showDeleteConfirmDialog = function () {
                deleteConfirmDialogNotifyInfo.clear();
                deleteConfirmDialogNotifyAlert.clear();
                deleteConfirmDialog.draggable(true);
                deleteConfirmDialog.dlg("open");
            };

            /// <summary>ダイアログを閉じます。</summary>
            var closeSaveConfirmDialog = function () {
                saveConfirmDialog.dlg("close");
            };
            var closeGridConfirmDialog = function () {
                gridConfirmDialog.dlg("close");
            };
            var closeSearchConfirmDialog = function () {
                searchConfirmDialog.dlg("close");
            };
            var closeDeleteConfirmDialog = function () {
                deleteConfirmDialog.dlg("close");
            };

            // グリッドコントロール固有のコントロール定義

            /// <summary>詳細を表示します。</summary>
            var showDetail = function (handle) {
                var selectedRowId = grid.jqGrid("getGridParam", "selrow"),
                    detailContent = $(".list-part-detail-content"),
                    gridContent = $(".list-part-grid-content"),
                    row;
                nextScrollTop = $(".ui-jqgrid-bdiv").scrollTop();

                if (handle === "add") {
                    row = setAddData();
                }
                else {
                    if (App.isUnusable(selectedRowId)) {
                        App.ui.page.notifyAlert.message(pageLangText.noSelect.text).show();
                        return;
                    }
                    row = grid.jqGrid("getRowData", selectedRowId, true);
                }

                // TODO：画面の仕様に応じて以下の詳細の項目の設定を変更してください。
                // 詳細のチェックボックスへ値をセットする
                checkMishiyoFlag(row.flg_mishiyo);
                checkKyoseiHoshinFlag(row.flg_kyosei_hoshin);
                //---------------------------------------------------------
                //2019/07/23 trinh.bd Task #14029
                //------------------------START----------------------------
                checkShikomiChohyoKubun(row.kbn_shikomi_chohyo);
                //------------------------END------------------------------
                isChangeDetail = false;

                $('#password').val(row.Password);
                $('#passwordConfirm').val(row.Password);
                // TODO：ここまで

                App.ui.page.notifyAlert.clear();

                // 検索条件、グリッドを非表示にして詳細を表示します。
                $(".search-criteria").hide("fast", function () {
                    gridContent.hide("fast", function () {
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

                        if (!(handle === "change")) {
                            isAdd = true; // 新規
                            $(".delete-button").css("display", "none");
                            $(".reset-button").css("display", "none");
                            $("#cd_tanto").removeAttr("disabled");
                            $("#password").removeAttr("disabled");
                            $("#passwordConfirm").removeAttr("disabled");

                            var radioRole = document.getElementsByName("RoleName");
                            if (radioRole[4].checked == true) {
                                document.getElementById('kbn_shikomi_chohyo').disabled = true;
                            }
                            else { document.getElementById('kbn_shikomi_chohyo').disabled = false; }
                            $(radioRole).change(function () {
                                if (radioRole[4].checked == true) {

                                    document.getElementById('kbn_shikomi_chohyo').disabled = true;
                                }
                                else { document.getElementById('kbn_shikomi_chohyo').disabled = false; }
                            })
                        }
                        else {
                            isAdd = false; // 変更
                            // 管理者以外の権限の場合
                            if (App.ui.page.user.Roles[0] != "Admin") {
                                $(".reset-button").css("display", "inline");
                                $("#cd_tanto").attr("disabled", "disabled");
                                $("#nm_tanto").attr("disabled", "disabled");
                                $("#password").attr("disabled", "disabled");
                                $("#passwordConfirm").attr("disabled", "disabled");
                                $("#flg_mishiyo").attr("disabled", "disabled");
                                var radioRole = document.getElementsByName("RoleName");
                                $(radioRole).attr("disabled", "disabled");
                                $("[name='kbn_ma_hinmei']").attr("disabled", "disabled");
                                $("[name='kbn_ma_haigo']").attr("disabled", "disabled");
                                $("[name='kbn_ma_konyusaki']").attr("disabled", "disabled");
                                $("[name='kbn_shikomi_chohyo']").attr("disabled", "disabled");
                                                            
                               // 管理者権限の場合
                            } else {
                                $(".delete-button").css("display", "inline");
                                $(".reset-button").css("display", "inline");
                                $("#cd_tanto").attr("disabled", "disabled");
                                $("#password").attr("disabled", "disabled");
                                $("#passwordConfirm").attr("disabled", "disabled");

                                var radioRole = document.getElementsByName("RoleName");
                                if (radioRole[4].checked == true) {
                                    document.getElementById('kbn_shikomi_chohyo').disabled = true;
                                }
                                else { document.getElementById('kbn_shikomi_chohyo').disabled = false; }

                                $(radioRole).change (function() {
                                    if (radioRole[4].checked == true) {
                                        document.getElementById('kbn_shikomi_chohyo').checked = false;
                                        document.getElementById('kbn_shikomi_chohyo').disabled = true;
                                       
                                    }
                                    else {
                                        document.getElementById('kbn_shikomi_chohyo').disabled = false;
                                    }

                                })
                              
                            }
                            //$(".delete-button").css("display", "inline");
                            //$(".reset-button").css("display", "inline");
                            //$("#cd_tanto").attr("disabled", "disabled");
                            //$("#password").attr("disabled", "disabled");
                            //$("#passwordConfirm").attr("disabled", "disabled");
                        }

                        $("#list-count").before("<span class='list-arrow' id='list-arrow'></span>");
                        $("#list-count").text(row.CombinationCD);
                        $("#list-results").on("click", showGrid);
                    }).promise().done(function () {
                        // 保存ボタンを表示する
                        $(".command [name='save-button']").attr("disabled", false).css("display", "");
                    });
                });
            };

            /// <summary>グリッドを表示します。</summary>
            var showGrid = function () {
                closeGridConfirmDialog();
                isChangeDetail = false;
                var d = $.Deferred();
                App.ui.page.notifyAlert.clear();
                isResetPass = false;
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

                    // 保存ボタンを非表示にする
                    $(".command [name='save-button']").attr("disabled", true).css("display", "none");

                    grid.closest(".ui-jqgrid-bdiv").scrollTop(nextScrollTop);
                    d.resolve();
                });

                return d.promise();
            };

            /// <summary>明細選択行時の動きを定義します。</summary>
            var clickFirstColumn = function (idNum) {
                if (idNum == null) {
                    $("#1 > td").click();
                }
                else {
                    $("#" + idNum).removeClass("ui-state-highlight").find("td").click();
                }
            };

            grid.jqGrid({
                // TODO：画面の仕様に応じて以下の列名の定義を変更してください。
                colNames: [
                    pageLangText.cd_tanto.text
                    , pageLangText.nm_tanto.text
                    , pageLangText.RoleName.text
                    , pageLangText.hinMeiText.text
                    , pageLangText.hinMeiText.text
                    , pageLangText.haigoText.text
                    , pageLangText.haigoText.text
                    , pageLangText.konyuText.text
                    , pageLangText.konyuText.text
                    , pageLangText.insatsuKinoText.text
                    , pageLangText.kyoseiHoshinFlag.text
                    , pageLangText.mishiyoFlag.text
                    //---------------------------------------------------------
                    //2019/07/23 trinh.bd Task #14029
                    //------------------------START----------------------------
                    , pageLangText.blank.text
                    , pageLangText.blank.text
                    , pageLangText.blank.text
                    //------------------------END------------------------------
                ],
                // TODO：画面の仕様に応じて以下の列モデルの定義を変更してください。
                colModel: [
                    { name: 'cd_tanto', width: 100, sorttype: "text", frozen: false },
                    { name: 'nm_tanto', width: 250, sorttype: "text", frozen: false },
                    { name: 'RoleNameText', width: 120, sorttype: "text", formatter: kengenIdFormatter },
                    { name: 'kbn_ma_hinmei', width: 0, hidden: true, hidedlg: true },
                    { name: 'nm_hinmei', width: 140, sorttype: 'text', formatter: getMaHinmei },
                    { name: 'kbn_ma_haigo', width: 0, hidden: true, hidedlg: true },
                    { name: 'nm_haigo', width: 120, sorttype: "text", formatter: getMaHaigo },
                    { name: 'kbn_ma_konyusaki', width: 0, hidden: true, hidedlg: true },
                    { name: 'nm_konyusaki', width: 130, sorttype: "text", formatter: getMaKonyu },
                    { name: 'kbn_shikomi_chohyo', width: 120, editable: false, editoptions: { value: "1:0" }, formatter: 'checkbox', align: 'center' },
                    { name: 'flg_kyosei_hoshin', width: 170, editable: false, editoptions: { value: "1:0" }, formatter: 'checkbox', align: 'center' },
                    { name: 'flg_mishiyo', width: 70, editable: false, editoptions: { value: "1:0" }, formatter: 'checkbox', align: 'center' },
                    { name: 'RoleName', width: 120, hidden: true, hidedlg: true },
                    { name: 'Password', width: 120, hidden: true, hidedlg: true },
                    { name: 'ts', width: 120, hidden: true, hidedlg: true },
                    //---------------------------------------------------------
                    //2019/07/23 trinh.bd Task #14029
                    //------------------------START----------------------------
                    //{ name: 'kbn_ma_hinmei', width: 120, hidden: true, hidedlg: true },
                    //{ name: 'kbn_ma_haigo', width: 120, hidden: true, hidedlg: true },
                    //{ name: 'kbn_ma_konyusaki', width: 120, hidden: true, hidedlg: true },
                    //{ name: 'kbn_shikomi_chohyo', width: 120, hidden: true, hidedlg: true }
                    //------------------------END------------------------------
                ],
                // TODO：ここまで
                datatype: "local",
                shrinkToFit: false,
                multiselect: false,
                rownumbers: true,
                hoverrows: false,
                cellEdit: false,
                loadComplete: function () {
                    // グリッドの先頭行選択
                    var idNum = grid.getGridParam("selrow");
                    clickFirstColumn(idNum);
                    // スクロール調整
                    grid.closest(".ui-jqgrid-bdiv").scrollTop(nextScrollTop);
                },
                //gridComplete: function () {
                //    // スクロール調整
                //    grid.closest(".ui-jqgrid-bdiv").scrollTop(nextScrollTop);
                //},
                ondblClickRow: function (selectedRowId) {
                    App.ui.page.notifyInfo.clear();
                    var selectedRowId = grid.jqGrid("getGridParam", "selrow");
                    var myCode = grid.jqGrid('getCell', selectedRowId, 'cd_tanto');
                    if (App.ui.page.user.Roles[0] != "Admin" && App.ui.page.user.Code != myCode) {
                        App.ui.page.notifyInfo.message(pageLangText.diffCode.text).show();
                        return;
                    }
                    showDetail("change")
                }
            });

            /// <summary>非表示列設定ダイアログの表示を行います。</summary>
            /// <param name="e">イベントデータ</param>
            var showColumnSettingDialog = function (e) {
                var dlgHeight = (grid.getGridParam("height") - 30 < 230 ? (grid.getGridParam("height") - 30) : 230);
                var dataHeight = dlgHeight - 50;
                var params = {
                    width: 300,
                    heitht: dlgHeight,
                    dataheight: dataHeight,
                    modal: true,
                    drag: false,
                    recreateForm: true,
                    caption: pageLangText.colchange.text,
                    bCancel: pageLangText.cancel.text,
                    bSubmit: pageLangText.save.text
                };
                grid.setColumns(params);
            };
            /// <summary>グリッドの列変更ボタンクリック時のイベント処理を行います。</summary>
            $(".colchange-button").on("click", showColumnSettingDialog);


            /// <summary>グリッド表示時のイベント処理を行います。</summary>
            function kengenIdFormatter(cellvalue, options, rowObject) {
                // 権限名の表示
                //var kengenName;
                var kengenName = "";
                if (App.isUndefOrNull(cellvalue)) {
                    //return;
                    return kengenName;
                }

                for (var i = 0; i < kengenKubun.length; i++) {
                    if (cellvalue === kengenKubun[i].id) {
                        // TODO：置換する文字内容の変更
                        kengenName = kengenKubun[i].name;
                    }
                }

                return kengenName;
            }

            /// <param name="cellvalue">ステータス区分</param>
            /// <param name="options">オプション</param>
            /// <param name="rowObject">行情報</param>
            function getMaHinmei(cellvalue, options, rowObject) {
                // var kbn = pageLangText.densoJotaiKbnMisakusei.text; // デフォルト：未作成
                var ret = 0,
                    value = rowObject.kbn_ma_hinmei;

                if (!App.isUndefOrNull(value) && value != "") {
                    ret = value;
                }
                ret = App.str.format(pageLangText.roleNewId.data[ret].name);
                return ret;
            }

            function getMaHaigo(cellvalue, options, rowObject) {
                // var kbn = pageLangText.densoJotaiKbnMisakusei.text; // デフォルト：未作成
                var ret = 0,
                    value = rowObject.kbn_ma_haigo;

                if (!App.isUndefOrNull(value) && value != "") {
                    ret = value;
                }
                ret = App.str.format(pageLangText.roleNewId.data[ret].name);
                return ret;
            }

            function getMaKonyu(cellvalue, options, rowObject) {
                // var kbn = pageLangText.densoJotaiKbnMisakusei.text; // デフォルト：未作成
                var ret = 0,
                    value = rowObject.kbn_ma_konyusaki;

                if (!App.isUndefOrNull(value) && value != "") {
                    ret = value;
                }
                ret = App.str.format(pageLangText.roleNewId.data[ret].name);
                return ret;
            }

            //// コントロール定義 -- End

            //// 操作制御定義 -- Start
            App.ui.pagedata.operation.applySetting(App.ui.page.user.Roles[0], App.ui.page.lang);
            //// 操作制御定義 -- End

            //// 事前データロード -- Start 

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

            // 画面アーキテクチャ共通の事前データロード
            App.deferred.parallel({
                // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                loading: App.ui.loading.show(pageLangText.nowProgressing.text)
                // TODO: ここまで
            }).done(function (result) {
                // TODO: 画面の仕様に応じて以下のサービス呼び出し成功時の処理を変更してください。

                // 検索用ドロップダウンの設定
                App.ui.appendOptions($(".search-criteria [name='kengenKubun']"), "id", "name", kengenKubun, true);
                //---------------------------------------------------------
                //2019/07/23 trinh.bd Task #14029
                //------------------------START----------------------------
                App.ui.appendOptions($(".item-list [name='kbn_ma_hinmei']"), "id", "name", kubunRoleCommon, false);
                App.ui.appendOptions($(".item-list [name='kbn_ma_haigo']"), "id", "name", kubunRoleCommon, false);
                App.ui.appendOptions($(".item-list [name='kbn_ma_konyusaki']"), "id", "name", kubunRoleCommon, false);
                //------------------------END------------------------------

                // 詳細用ドロップダウンの設定
                setLiteral("cd_tanto", pageLangText.cd_tanto.text, true);
                setLiteral("nm_tanto", pageLangText.nm_tanto.text, true);
                setLiteral("password", pageLangText.password.text, true);
                setLiteral("passwordConfirm", pageLangText.passwordConfirm.text, true);

                // URLのクエリ文字列で検索条件が指定された場合はその条件で検索
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


            //// 事前データロード -- End

            //// 検索処理 -- Start

            // 画面アーキテクチャ共通の検索処理

            /// <summary>クエリオブジェクトの設定</summary>
            var query = function () {
                var query = {
                    // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                    url: "../Services/FoodProcsService.svc/vw_ma_tanto_01",
                    // TODO: ここまで
                    filter: createFilter(),
                    orderby: "cd_tanto",
                    skip: querySetting.skip,
                    top: querySetting.top,
                    inlinecount: "allpages"
                }
                return query;
            };
            /// <summary>フィルター条件の設定</summary>
            var createFilter = function () {
                var criteria = criteriaSelector.toJSON(),
                    filters = [];

                // TODO: 画面の仕様に応じて以下のフィルター条件を変更してください。
                if (!App.isUndefOrNull(criteria.tantoshaNameSearchText) && criteria.tantoshaNameSearchText.length > 0) {
                    filters.push("(substringof('" + encodeURIComponent(criteria.tantoshaNameSearchText) + "', cd_tanto) eq true or "
                            + "substringof('" + encodeURIComponent(criteria.tantoshaNameSearchText) + "', nm_tanto) eq true)");
                }
                if (!App.isUndefOrNull(criteria.kengenKubun) && criteria.kengenKubun.length > 0) {
                    filters.push("RoleName eq '" + criteria.kengenKubun + "'");
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
                nextScrollTop = $(".ui-jqgrid-bdiv").scrollTop() - 30;
                // ローディングの表示
                $("#list-loading-message").text(pageLangText.nowLoading.text);
                App.ajax.webget(
                // WCF Data ServicesのODataシステムクエリオプションを生成
                    App.data.toODataFormat(query)
                ).done(function (result) {
                    // データバインド
                    bindData(result);

                    // 検索条件を閉じる
                    isSearch = true,
                    isCriteriaChange = false;
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
                if (!criteriaSelector.find(".part-body").is(":hidden")) {
                    criteriaSelector.find(".search-part-toggle").click();
                }
            };
            /// <summary>検索ボタンクリック時のイベント処理を行います。</summary>
            var findData = function () {
                closeSearchConfirmDialog();
                isChangeDetail = false;
                clearState();
                var result = criteriaSelector.validation().validate();
                if (result.errors.length) {
                    return;
                }
                showGrid().done(function () {
                    searchItems(new query())
                });
            };
            $(".find-button").on("click", showSearchConfirmDialog); //showSearchConfirmDialog

            /// <summary>検索前バリデーション</summary>
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
            criteriaSelector.validation(searchValidation);

            /// <summary>パスワードのクリア</summary>
            var resetPassword = function () {
                isResetPass = true;
                $("#password").removeAttr("disabled").val("");
                $("#passwordConfirm").removeAttr("disabled").val("");
            };

            // グリッドコントロール固有の検索処理

            /// <summary>検索前の状態に初期化します。</summary>
            var clearState = function () {
                // データクリア
                grid.clearGridData();
                nextScrollTop = 0;
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
            /// <summary>後続データ検索を行います。</summary>
            /// <param name="target">グリッド</param>
            //var nextSearchItems = function (target) {
            //    var scrollTop = lastScrollTop;
            //    if (scrollTop == target.scrollTop) {
            //        return;
            //    }
            //    if (querySetting.skip === querySetting.count) {
            //        return;
            //    }
            //    lastScrollTop = target.scrollTop;
            //    if (target.scrollHeight - target.scrollTop <= $(target).outerHeight()) {
            //        // データ検索
            //        searchItems(new query());
            //    }
            //};
            /// <summary>グリッドスクロール時のイベント処理を行います。</summary>
            //$(".ui-jqgrid-bdiv").scroll(function (e) {
            //    // 後続データ検索
            //    nextSearchItems(this);
            //});

            /// <summary>検索条件変更時処理を行います。</summary>
            criteriaSelector.on("change", function () {
                // 検索後の状態で検索条件が変更された場合
                if (isSearch) {
                    isCriteriaChange = true;
                }
            });

            //// 検索処理 -- End

            //// メッセージ表示 -- Start
            // ダイアログ固有のメッセージ表示
            // 保存ダイアログ情報メッセージの設定
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
            // 一覧表示時ダイアログ情報メッセージの設定
            var gridConfirmDialogNotifyInfo = App.ui.notify.info(gridConfirmDialog, {
                container: ".showgrid-confirm-dialog .dialog-slideup-area .info-message",
                messageContainerQuery: "ul",
                show: function () {
                    gridConfirmDialog.find(".info-message").show();
                },
                clear: function () {
                    gridConfirmDialog.find(".info-message").hide();
                }
            });
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
            // 削除時時ダイアログ情報メッセージの設定
            var deleteConfirmDialogNotifyInfo = App.ui.notify.info(deleteConfirmDialog, {
                container: ".delete-confirm-dialog .dialog-slideup-area .info-message",
                messageContainerQuery: "ul",
                show: function () {
                    searchConfirmDialog.find(".info-message").show();
                },
                clear: function () {
                    searchConfirmDialog.find(".info-message").hide();
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
            var gridConfirmDialogNotifyAlert = App.ui.notify.alert(gridConfirmDialog, {
                container: ".showgrid-confirm-dialog .dialog-slideup-area .alert-message",
                messageContainerQuery: "ul",
                show: function () {
                    gridConfirmDialog.find(".alert-message").show();
                },
                clear: function () {
                    gridConfirmDialog.find(".alert-message").hide();
                }
            });
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
            //// メッセージ表示 -- End

            //// データ変更処理 -- Start

            /// <summary>新規行データの設定を行います。</summary>
            var setAddData = function () {
                // TODO: 画面の仕様に応じて以下の項目を変更してください。
                var addData = {
                    "cd_tanto": "",
                    "nm_tanto": "",
                    "RoleName": pageLangText.warehouse.text,
                    "Password": "",
                    "cd_create": App.ui.page.user.Code,
                    "cd_update": App.ui.page.user.Code,
                    "flg_kyosei_hoshin": 0,
                    "flg_mishiyo": 0,
                    "ts": "",
                    //---------------------------------------------------------
                    //2019/07/23 trinh.bd Task #14029
                    //------------------------START----------------------------
                    "kbn_ma_hinmei": 0,
                    "kbn_ma_haigo": 0,
                    "kbn_ma_konyusaki": 0,
                    "kbn_shikomi_chohyo": 0,
                    //------------------------END------------------------------
                };
                // TODO: ここまで

                return addData;
            };

            /// <summary>詳細画面の未使用チェックボックスの値制御。</summary>
            var handleCheckValue = function () {
                var checkBox = $('#flg_mishiyo');
                if (checkBox.is(':checked')) {
                    checkBox.val(pageLangText.mishiyoMishiyoFlg.text);
                }
                else {
                    checkBox.val(pageLangText.shiyoMishiyoFlg.text);
                }
            };
            $("#flg_mishiyo").on("click", handleCheckValue);

            /// <summary>詳細画面の強制歩進チェックボックスの値制御</summary>
            var handleCheckValue = function () {
                var checkBox = $('#flg_kyosei_hoshin');
                if (checkBox.is(':checked')) {
                    checkBox.val(pageLangText.mishiyoMishiyoFlg.text);
                }
                else {
                    checkBox.val(pageLangText.shiyoMishiyoFlg.text);
                }
            };
            $("#flg_kyosei_hoshin").on("click", handleCheckValue);

            //---------------------------------------------------------
            //2019/07/30 trinh.bd Task #14029
            //------------------------START----------------------------
            var handleCheckShikomiValue = function () {
                var checkBox = $('#kbn_shikomi_chohyo');
                if (checkBox.is(':checked')) {
                    checkBox.val(pageLangText.mishiyoMishiyoFlg.text);
                }
                else {
                    checkBox.val(pageLangText.shiyoMishiyoFlg.text);
                }
            };
            $("#kbn_shikomi_chohyo").on("click", handleCheckShikomiValue);
            //------------------------END------------------------------

            //// データ変更処理 -- End

            //// 保存処理 -- Start

            // グリッド固有の保存処理

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
                        var data = {
                            "cd_tanto": upCurrent.cd_tanto,
                            "nm_tanto": upCurrent.nm_tanto,
                            "RoleName": upCurrent.RoleName,
                            "Password": upCurrent.Password,
                            "flg_kyosei_hoshin": upCurrent.flg_kyosei_hoshin,
                            "flg_mishiyo": upCurrent.flg_mishiyo,
                            "ts": upCurrent.ts
                        };
                        // TODO: ここまで

                        // カレントのデータを詳細画面へ表示
                        detailContent.toForm(data);
                        // フラグの値チェック
                        checkMishiyoFlag(data.flg_mishiyo);
                        //checkKyoseiHoshinFlag(row.flg_kyosei_hoshin);
                        checkKyoseiHoshinFlag(data.flg_kyosei_hoshin);
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
                            "cd_tanto": delCurrent.cd_tanto,
                            "nm_tanto": delCurrent.nm_tanto,
                            "RoleName": delCurrent.RoleName,
                            "Password": delCurrent.Password,
                            "flg_kyosei_hoshin": delCurrent.flg_kyosei_hoshin,
                            "flg_mishiyo": delCurrent.flg_mishiyo,
                            "ts": delCurrent.ts
                        };
                        // TODO: ここまで

                        // カレントのデータを詳細画面へ表示
                        detailContent.toForm(delData);
                        // 未使用チェック
                        checkMishiyoFlag(data.flg_mishiyo);
                        // 強制歩進チェック
                        checkKyoseiHoshinFlag(row.flg_kyosei_hoshin);
                        // エラーメッセージの表示
                        App.ui.page.notifyAlert.message(
                                        pageLangText.duplicate.text + pageLangText.updatedDuplicate.text).show();
                    }

                }
            };
            /// <summary>変更を保存します。</summary>
            var saveData = function (saveSatus) {
                // 確認ダイアログのクローズ
                closeSaveConfirmDialog();
                closeDeleteConfirmDialog();

                // 更新データをJSONオブジェクトに変換
                var detailContent = $(".list-part-detail-content");
                var postData = detailContent.toJSON();

                // TODO: 画面の仕様に応じて以下の項目を変更してください。
                postData.cd_create = App.ui.page.user.Code;
                postData.cd_update = App.ui.page.user.Code;
                // TODO: ここまで
                var changeSet = new App.ui.page.changeSet();

                // TODO: 画面の仕様に応じて新規/更新にて処理を変更してください。
                if (saveSatus == "Save") {
                    if (!App.isUndefOrNull(postData.ts) && postData.ts.length > 0) {
                        changeSet.addUpdated(App.uuid, null, null, postData);
                    }
                    else {
                        changeSet.addCreated(App.uuid, postData);
                    }
                }
                else {
                    // 削除時のオブジェクトセット
                    changeSet.addDeleted(App.uuid, postData);
                }
                // TODO: ここまで
                // ローディングの表示
                App.ui.loading.show(pageLangText.nowSaving.text);
                var data = changeSet.getChangeSet();
                // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                var saveUrl = "../api/TantoshaMaster";
                // TODO: ここまで

                App.ajax.webpost(
                    saveUrl, data
                ).done(function (result) {
                    // 検索前の状態に初期化
                    clearState();
                    // データ検索
                    showGrid().done(function () {
                        searchItems(new query())
                    });

                }).fail(function (result) {
                    // データ変更エラーハンドリングを行います。
                    handleSaveDataError(result);
                }).always(function () {
                    // ローディングの終了
                    App.ui.loading.close();
                });
                // TODO: ここまで

            };

            /// <summary>詳細変更時処理を行います。</summary>
            $(".list-part-detail-content").on("change", function () {
                // 検索後の状態で検索条件が変更された場合
                isChangeDetail = true;
            });

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
            $(".validation-newrecord").validation(v);
            $(".password-input").validation(v);

            /// <summary>パスワード比較を行います。</summary>
            /// <param name="password">パスワード</param>
            var isPasswordEqual = function (password) {
                var confirm = $('#passwordConfirm').val();
                if (!confirm == "") {
                    return password === confirm;
                };
                return true;
            };

            validationSetting.password.rules.custom = function (value) {
                return isPasswordEqual(value);
            };

            /// <summary>確認用パスワード入力時のチェックを行います。</summary>
            /// <param name="passwordConfirm">パスワード</param>
            var validatePassword = function (passwordConfirm) {
                $(".password-input").validation().validate();
                return true;
            };

            validationSetting.passwordConfirm.rules.custom = function (value) {
                return validatePassword(value);
            };

            /// <summary>データベース問い合わせチェックを行います。</summary>
            /// <param name="code">担当者コード</param>
            var isTantoExsist = function (code) {
                var isExsist = false;
                // 新規の場合チェック
                if (isAdd) {
                    App.ajax.webgetSync("../Services/FoodProcsService.svc/vw_ma_tanto_01()?$filter=cd_tanto eq '" + code + "'"
                    ).done(function (result) {
                        // 入力項目のバリデーション
                        if (result.d[0] == undefined) {
                            isExsist = true;
                        };
                    }).fail(function (result) {
                        App.ui.page.notifyAlert.message(result.message).show();
                    });
                }
                else {
                    isExsist = true;
                }
                return isExsist;
            };

            validationSetting.cd_tanto.rules.custom = function (value) {
                return isTantoExsist(value);
            };

            //// バリデーション -- End

            /// <summary>追加ボタンボタンクリック時のイベント処理を行います。</summary>
            $(".add-button").on("click", function (e) {
                showDetail("add");
            });

            /// <summary>詳細ボタンクリック時のイベント処理を行います。</summary>
            $(".detail-button").on("click", function (e) {
                App.ui.page.notifyInfo.clear();
                var selectedRowId = grid.jqGrid("getGridParam", "selrow");
                var myCode = grid.jqGrid('getCell', selectedRowId, 'cd_tanto');
                if (App.ui.page.user.Roles[0] != "Admin" && App.ui.page.user.Code != myCode) {
                    App.ui.page.notifyInfo.message(pageLangText.diffCode.text).show();
                    return;
                }
                showDetail("change");
            });

            $(".save-button").on("click", function (e) {
                // 保存前チェック
                App.ui.page.notifyInfo.clear();
                var detailContent,
                    result;

                // validation 切分け
                if (isAdd || isResetPass) {
                    detailContent = $(".list-part-detail-content");
                }
                else {
                    detailContent = $(".validation-newrecord");
                }

                // 変更セット内にバリデーションエラーがある場合は処理を抜ける
                result = detailContent.validation().validate();
                if (result.errors.length) {
                    return;
                }

                // 変更がない場合は処理を抜ける
                if (!isChangeDetail) {
                    App.ui.page.notifyInfo.message(pageLangText.noChange.text).show();
                    return;
                }

                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();
                // ダイアログ起動
                showSaveConfirmDialog();
            });

            $(".delete-button").on("click", function (e) {
                // 情報メッセージのクリア
                App.ui.page.notifyInfo.clear();
                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();
                // ダイアログ起動
                showDeleteConfirmDialog();
            });

            $(".reset-button").on("click", function (e) {
                resetPassword();
            });

            $(".list-button").on("click", showGridConfirmDialog);

            /// <summary>未使用フラグのチェックを行います。</summary>
            var checkMishiyoFlag = function (rowval) {
                var checkBox = $("#flg_mishiyo");
                if (rowval == pageLangText.mishiyoMishiyoFlg.text) {
                    checkBox.val(pageLangText.mishiyoMishiyoFlg.text);
                }
                else {
                    //checkBox.prop("checked", false);
                    checkBox.prop("checked", true);
                    checkBox.click();
                }
            };

            //---------------------------------------------------------
            //2019/07/23 trinh.bd Task #14029
            //------------------------START----------------------------
            /// <summary>印刷機能チェックフラグのチェックを行います。</summary>
            var checkShikomiChohyoKubun = function (rowval) {
                var checkBox = $("#kbn_shikomi_chohyo");
                if (rowval == pageLangText.mishiyoMishiyoFlg.text) {
                    checkBox.val(pageLangText.mishiyoMishiyoFlg.text);
                }
                else {
                    checkBox.prop("checked", true);
                    checkBox.click();
                }
            };
            //------------------------END------------------------------

            /// <summary>強制歩進フラグのチェックを行います。</summary>
            var checkKyoseiHoshinFlag = function (rowval) {
                var checkBox = $("#flg_kyosei_hoshin");
                if (rowval == pageLangText.mishiyoMishiyoFlg.text) {
                    checkBox.val(pageLangText.mishiyoMishiyoFlg.text);
                }
                else {
                    //checkBox.prop("checked", false);
                    checkBox.prop("checked", true);
                    checkBox.click();
                }
            };

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
                    searchPart = criteriaSelector,
                    resultPart = $(".result-list"),
                    resultPartHeader = resultPart.find(".part-header"),
                    resultPartCommands = resultPart.find(".item-command"),
                    resultPartStyle = resultPart[0].currentStyle || document.defaultView.getComputedStyle(resultPart[0], "");

                resultPart.height(container[0].clientHeight - searchPart[0].clientHeight - ((parseInt(resultPartStyle.marginTop, 10) * 3) || 0));
                grid.setGridWidth(resultPart[0].clientWidth - 5);
                //結果一覧のパートの高さ - パートのヘッダーの高さ - パート内のボタンのコマンドの高さ - jqGrid のカラムヘッダーの高さ
                grid.setGridHeight(resultPart[0].clientHeight - resultPartHeader[0].clientHeight - resultPartCommands[0].clientHeight - resultPart.find(".ui-jqgrid-hdiv")[0].clientHeight - 35);
            };

            /// <summary>保存確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".save-confirm-dialog .dlg-yes-button").on("click", function () { saveData("Save"); });
            // <summary>保存確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".save-confirm-dialog .dlg-no-button").on("click", closeSaveConfirmDialog);

            /// <summary>一覧確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".showgrid-confirm-dialog .dlg-yes-button").on("click", showGrid);
            // <summary>一覧確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".showgrid-confirm-dialog .dlg-no-button").on("click", closeGridConfirmDialog);

            /// <summary>検索確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".search-confirm-dialog .dlg-yes-button").on("click", findData);
            // <summary>検索確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".search-confirm-dialog .dlg-no-button").on("click", closeSearchConfirmDialog);

            /// <summary>削除確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".delete-confirm-dialog .dlg-yes-button").on("click", function () { saveData("Delete"); });
            // <summary>削除確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".delete-confirm-dialog .dlg-no-button").on("click", closeDeleteConfirmDialog);

            /// <summary>画面リサイズ時のイベント処理を行います。</summary>
            $(App.ui.page).on("resized", resizeContents);

            /// <summary>データに変更があり、未保存の状態でページを離れる際に確認を行います。</summary>
            //別画面に遷移したりするときに実行する関数の定義
            var onBeforeUnload = function () {
                $("#nm_tanto").blur();
                // データを変更したかどうかは各画面でチェックし、保持する
                if (isChangeDetail) {
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
                $("#nm_tanto").blur();
                $(window).off('beforeunload');  //ログオフボタンをクリックしたときはbeforunloadイベントを発生させない
                if (isChangeDetail) {
                    var ans = confirm(pageLangText.unloadWithoutSave.text);
                    if (ans == false) {
                        $(window).on('beforeunload', onBeforeUnload);   //イベントを外したままだと、他のボタンで機能しないので、再設定
                        return false;
                    }
                }
                __doPostBack('ctl00$loginButton', '');
            });

            /// <summary>メニューボタンクリック時のイベント処理を行います。</summary>
            var backToMenu = function () {
                $("#nm_tanto").blur();
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
                        <span class="item-label" data-app-text="tantoshaNameSearchText"></span>
                        <input type="text" name="tantoshaNameSearchText"/>
                    </label>
                </li>
                <li>
                    <label>
                        <span class="item-label" data-app-text="roleNameSearch"></span>
                        <select name="kengenKubun"></select>
                    </label>
                </li>
                <!-- TODO: ここまで -->
            </ul>
        </div>
        <div class="part-footer">
            <div class="command">
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
        <h3 id="listHeader" class="part-header" >
            <span data-app-text="resultList" style="padding-right: 10px; padding-bottom: 4px;" id="list-results" ></span>
            <span class="list-count" id="list-count" ></span>
            <span style="padding-left: 50px;" class="list-loading-message" id="list-loading-message" ></span>
        </h3>
        <div class="part-body" id="result-grid">
            <div class="list-part-grid-content">
                <div class="item-command" style="left: 17px; right: 17px;">
                     <button type="button" class="colchange-button" data-app-operation="colchange"><span class="icon"></span><span data-app-text="colchange"></span></button>
                    <button type="button" class="add-button" name="add-button" data-app-operation="add"><span class="icon"></span><span data-app-text="add"></span></button>
                    <button type="button" class="detail-button" name="detail-button" data-app-operation="detail"><span class="icon"></span><span data-app-text="detail"></span></button>
                </div>
                <table id="item-grid">
                </table>
            </div>
            
            <div class="list-part-detail-content" style="display:none;">
                <div class="item-command" style="left: 17px; right: 17px;">
                    <button type="button" class="list-button" name="list-button"><span class="icon"></span><span data-app-text="list"></span></button>
                    <!-- <button type="button" class="save-button" name="save-button"><span class="icon"></span><span data-app-text="save"></span></button> -->
                    <button type="button" class="delete-button" name="delete-button" data-app-operation="del"><span class="icon"></span><span data-app-text="del"></span></button>
                    <button type="button" class="reset-button" name="reset-button"><span class="icon"></span><span data-app-text="passwordReset"></span></button>
                </div>
                <ul class="item-list item-list-left">
                    <!-- TODO: 画面の仕様に応じて以下の項目を変更してください。 -->
                    <li class="validation-newrecord">
                        <label>
                            <span class="item-label" data-app-text="cd_tanto"></span>
                            <input type="text" name="cd_tanto" data-app-validation="cd_tanto" id="cd_tanto"  style="width: 6em;"/>
                        </label>
                    </li>
                    <li class="validation-newrecord">
                        <label>
                            <span class="item-label" data-app-text="nm_tanto"></span>
                            <input type="text" id="nm_tanto" name="nm_tanto" data-app-validation="nm_tanto"  style="width: 25em;"/>
                        </label>
                    </li>
                    <li class="password-input">
                        <label>
                            <span class="item-label" data-app-text="password"></span>
                            <input type="password" name="password" id="password" style="width: 15em;"/>
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="passwordConfirm"></span>
                            <input type="password" name="passwordConfirm" id="passwordConfirm" style="width: 15em;"/>
                        </label>
                    </li>
                    <!-- radio -->
                    <li class="validation-newrecord">
                        <span class="item-label"  data-app-text="RoleName"></span>
                        <label>
                            <input type="radio" name="RoleName" value="Admin"/>
                            <span class="item-label" data-app-text="adminText"></span>
                        </label>
                    </li>
                    <li class="validation-newrecord">
                        <span class="item-label"></span>
                        <label>
                            <input type="radio" name="RoleName" value="Manufacture"/>
                            <span class="item-label" data-app-text="manufactureText"></span>
                        </label>
                    </li>
                    <li class="validation-newrecord">
                        <span class="item-label"></span>
                        <label>
                            <input type="radio" name="RoleName" value="Purchase"/>
                            <span class="item-label" data-app-text="purchaseText"></span>
                        </label>
                    </li>
                    <li class="validation-newrecord">
                        <span class="item-label"></span>
                         <label>
                            <input type="radio" name="RoleName" value="Quality"/>
                            <span class="item-label" data-app-text="qualityText"></span>
                        </label>
                    </li>
                    <li class="validation-newrecord">
                        <span class="item-label"></span>
                         <label>
                            <input type="radio" name="RoleName" value="Warehouse"/>
                            <span class="item-label" data-app-text="warehouseText"></span>
                        </label>
                    </li>
                    <%--2019/07/23 trinh.bd Task #14029----%>
                    <%--//------------------------START------------------------------%>
                    <li class="validation-newrecord">
                        <span class="item-label"  data-app-text="kobetsuSetteiText"></span>
                        <label>
                            <span class="item-label"  data-app-text="hinMeiText"></span>
                            <select name="kbn_ma_hinmei"></select>
                        </label>
                    </li>
                    <li class="validation-newrecord">
                        <span class="item-label"></span>
                         <label>
                            <span class="item-label"  data-app-text="haigoText"></span>
                            <select name="kbn_ma_haigo"></select>
                        </label>
                    </li>
                    <li class="validation-newrecord">
                        <span class="item-label"></span>
                         <label>
                            <span class="item-label"  data-app-text="konyuText"></span>
                            <select name="kbn_ma_konyusaki"></select>
                        </label>
                    </li>
                    <li class="validation-newrecord">
                        <span class="item-label"></span>
                        <span class="item-label"  data-app-text="shikakarihinText"></span>
                        <label>
                            <span data-app-text="insatsuKinoText"></span>
                            <input type="checkbox" id="kbn_shikomi_chohyo" name="kbn_shikomi_chohyo" value="kbn_shikomi_chohyo" />
                        </label>
                    </li>
                    <%--//---------------- --------END-------------------- ----------%>
                    <li class="validation-newrecord">
                        <span class="item-label"  data-app-text="kyoseiHoshinFlag"></span>
                        <label>
                            <input type="checkbox" id="flg_kyosei_hoshin" name="flg_kyosei_hoshin" value="flg_kyosei_hoshin" />
                        </label>
                    </li>
                    <li class="validation-newrecord">
                        <span class="item-label"  data-app-text="mishiyoFlag"></span>
                        <label>
                            <input type="checkbox" id="flg_mishiyo" name="flg_mishiyo" />
                        </label>
                    </li>
                    <li>&nbsp;</li>
                    <li>
                        <span data-app-text="inputAnnounceText"></span>
                    </li>
                    <li>
                        <span data-app-text="inputAnnounce2Text"></span>
                    </li>
                    <input type="hidden" name="ts" />
                        
                    <!-- TODO: ここまで -->
                </ul>
            </div>
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
        <button type="button" class="save-button" name="save-button" data-app-operation="save" style="display:none">
            <span class="icon"></span><span data-app-text="save"></span>
        </button>
        <!-- TODO: ここまで -->
    </div>
    <div class="command" style="right: 9px;">
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
    <div class="save-confirm-dialog" style="display:none">
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
    <div class="search-confirm-dialog" style="display:none">
        <div class="dialog-header">
            <h4 data-app-text="confirmTitle"></h4>
        </div>
        <div class="dialog-body" style="padding: 10px; width: 100%;">
            <div class="part-body">
                <span data-app-text="searchConfirm"></span>
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
    <div class="showgrid-confirm-dialog" style="display:none">
        <div class="dialog-header">
            <h4 data-app-text="confirmTitle"></h4>
        </div>
        <div class="dialog-body" style="padding: 10px; width: 100%;">
            <div class="part-body">
                <span data-app-text="showGridConfirm"></span>
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
    <div class="delete-confirm-dialog" style="display:none">
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
    <!-- TODO: ここまで  -->
    <!-- 画面デザイン -- End -->
</asp:Content>
