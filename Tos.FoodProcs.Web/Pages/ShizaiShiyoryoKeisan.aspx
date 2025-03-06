<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="ShizaiShiyoryoKeisan.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.ShizaiShiyoryoKeisan" %>

<asp:Content ID="Content1" ContentPlaceHolderID="IncludeContent" runat="server">
    <script src="<%=ResolveUrl("~/Resources/pages/pagedata-shizaishiyoryokeisan." + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
    <script src="<%=ResolveUrl("~/Resources/grid/grid.locale-" + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
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
        
        .search-criteria select
        {
            width: 20em;
        }
        
        .save-confirm-dialog
        {
            background-color: White;
            width: 350px;
        }
        
        .save-confirm-dialog .part-body
        {
            width: 95%;
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
        .ui-jqgrid .ui-jqgrid-htable TH DIV
        {
            overflow: hidden;
            position: relative;
            height: auto;            
        }
        .ui-jqgrid .ui-jqgrid-htable TH.ui-th-column
        {
            vertical-align: middle;
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
            var bunruiCode, //検索条件のコンボボックス
            // 多言語対応にしたい項目を変数にする
                hinmeiName = 'nm_hinmei_' + App.ui.page.lang,
                loading;

            // TODO：ここまで

            // ダイアログ固有の変数宣言
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            var saveConfirmDialog = $(".save-confirm-dialog"),
                searchConfirmDialog = $(".search-confirm-dialog");
            // TODO：ここまで

            //// 変数宣言 -- End

            //// コントロール定義 -- Start

            // ダイアログ固有のコントロール定義
            saveConfirmDialog.dlg();
            searchConfirmDialog.dlg();

            /// <summary>ダイアログを開きます。</summary>
            var showSaveConfirmDialog = function () {
                // 対象行が存在するか確認
                var selectedRowId = getSelectedRowId(),
                    position = "after";
                if (App.isUndefOrNull(selectedRowId)) {
                    return;
                }
                saveConfirmDialogNotifyInfo.clear();
                saveConfirmDialogNotifyAlert.clear();
                saveConfirmDialog.draggable(true);
                saveConfirmDialog.dlg("open");
            };
            // 検索時のダイアログ
            var showSearchConfirmDialog = function () {
                // 検索前に変更をチェック
                if (noChange()) {
                    findData();
                } else {
                    searchConfirmDialogNotifyInfo.clear();
                    searchConfirmDialogNotifyAlert.clear();
                    searchConfirmDialog.draggable(true);
                    searchConfirmDialog.dlg("open");
                }
            };

            /// <summary>ダイアログを閉じます。</summary>
            var closeSaveConfirmDialog = function () {
                saveConfirmDialog.dlg("close");
            };
            var closeSearchConfirmDialog = function () {
                searchConfirmDialog.dlg("close");
            };

            // 除算処理
            Math._getDecimalLength = function (value) {
                var list = (value + '').split('.'), result = 0;
                if (list[1] !== undefined && list[1].length > 0) {
                    result = list[1].length;
                }
                return result;
            };

            Math.multiply = function (value1, value2) {
                var intValue1 = +(value1 + '').replace('.', ''),
                    intValue2 = +(value2 + '').replace('.', ''),
                    decimalLength = Math._getDecimalLength(value1) + Math._getDecimalLength(value2),
                    result;
                result = (intValue1 * intValue2) / Math.pow(10, decimalLength);
                return result;
            };

            if (App.ui.page.langCountry !== 'en-US') {
                var datePickerFormat = pageLangText.dateFormat.text;
            } else {
                var datePickerFormat = pageLangText.dateFormatUS.text;
            }
            // TODO：画面の仕様に応じて以下の datepicker の設定を変更してください。
            $(".search-criteria [name='dt_hiduke_search']").on("keyup", App.data.addSlashForDateString);
            $(".search-criteria [name='dt_hiduke_search']").datepicker({ dateFormat: datePickerFormat });
            // TODO：ここまで

            // グリッドコントロール固有のコントロール定義
            grid.jqGrid({
                // TODO：画面の仕様に応じて以下の列名の定義を変更してください。
                colNames: [
                    pageLangText.nm_bunrui.text
                    , pageLangText.cd_hinmei.text
                    , pageLangText.nm_hinmei.text
                    , pageLangText.nm_nisugata_hyoji.text
                    , pageLangText.nm_tani.text
                    , pageLangText.su_shiyo_sum.text
                    , pageLangText.wt_shiyo_zan.text + pageLangText.requiredMark.text
                    , pageLangText.qty_hitsuyo.text
                    , pageLangText.qty_hitsuyoNonyu.text, pageLangText.qty_hitsuyoNonyuHasu.text
                    , pageLangText.nm_torihiki_ryaku.text
                    , pageLangText.zan_hiduke.text
                    , pageLangText.dt_hiduke.text
                    , "", "", ""
                ],
                // TODO：ここまで
                // TODO：画面の仕様に応じて以下の列モデルの定義を変更してください。
                colModel: [
                    { name: 'nm_bunrui', width: 150, editable: false, sorttype: "text" },
                    { name: 'cd_hinmei', width: 120, editable: false, sorttype: "text" },
                    { name: hinmeiName, width: 220, editable: false, sorttype: "text" },
                    { name: 'nm_nisugata_hyoji', width: 100, editable: false, sorttype: "text" },
                    { name: 'nm_tani', width: 80, editable: false, align: "center", sorttype: "text" },
                    { name: 'su_shiyo_sum', width: 120, editable: false, align: "right", sorttype: "float",
                        formatter: 'number',
                        formatoptions: {
                            decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 3, defaultValue: "0"
                        }
                    },
                    { name: 'wt_shiyo_zan', width: 120, editable: true, align: "right", sorttype: "float",
                        editoptions: { maxlength: 11 },
                        formatter: 'number',
                        formatoptions: {
                            decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 3, defaultValue: ""
                        }
                    },
                    { name: 'qty_hitsuyo', width: 120, editable: false, align: "right", sorttype: "float",
                        formatter: 'number',
                        formatoptions: {
                            decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 3, defaultValue: ""
                        }
                    },
                    { name: 'qty_hitsuyoNonyu', width: 120, editable: false, align: "right", sorttype: "float",
                        formatter: 'number',
                        formatoptions: {
                            decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 0, defaultValue: "0"
                        }
                    },
                    { name: 'qty_hitsuyoNonyuHasu', width: 120, editable: false, align: "right", sorttype: "float",
                        formatter: 'number',
                        formatoptions: {
                            decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 3, defaultValue: "0.000"
                        }
                    },
                    { name: 'nm_torihiki_ryaku', width: 210, editable: false, sorttype: "text" },
                    { name: 'zan_hiduke', width: 0, hidden: true, hidedlg: true },
                    { name: 'dt_hiduke', width: 0, hidden: true, hidedlg: true },
                    { name: 'su_iri', width: 0, hidden: true, hidedlg: true },
                    { name: 'wt_ko', width: 0, hidden: true, hidedlg: true },
                    { name: 'cd_tani_nonyu', width: 0, hidden: true, hidedlg: true }
                ],
                // TODO：ここまで
                datatype: "local",
                shrinkToFit: false,
                multiselect: false,
                rownumbers: true,
                cellEdit: true,
                cellsubmit: 'clientArray',
                loadComplete: function () {
                    // 変数宣言
                    var ids = grid.jqGrid('getDataIDs'),
                        criteria = $(".search-criteria").toJSON();

                    for (var i = 0; i < ids.length; i++) {
                        var id = ids[i];
                        // TODO : ここから
                        // 検索後の値がマイナスの場合、文字色を赤くする
                        if (0 > parseFloat(grid.getCell(id, "qty_hitsuyo"))) {
                            grid.setCell(id, "qty_hitsuyo", '', { color: '#ff6666' });
                        }
                        setRelatedValue(id, "wt_shiyo_zan", grid.getCell(id, "wt_shiyo_zan"), 7);
                        // TODO：ここまで
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
                    // 変更データの変数設定
                    var changeData;
                    // タイムスタンプを確認し、更新か新規かを切り分ける
                    // 更新
                    if (grid.jqGrid('getCell', selectedRowId, 'zan_hiduke')) {
                        // 更新状態の変更データの設定
                        changeData = setUpdatedChangeData(grid.getRowData(selectedRowId));
                        // 更新状態の変更セットに変更データを追加
                        changeSet.addUpdated(selectedRowId, cellName, value, changeData);
                        // 新規
                    } else {
                        // 追加状態のデータ設定
                        changeData = setCreatedChangeData(grid.getRowData(selectedRowId));
                        // 追加状態の変更セットに変更データを追加
                        changeSet.addCreated(selectedRowId, changeData);
                    }

                    // 関連項目の設定を変更セットに反映
                    setRelatedChangeData(selectedRowId, cellName, value, changeData);
                }
            });
            /// <summary>セルの関連項目を設定します。</summary>
            /// <param name="selectedRowId">選択行ID</param>
            /// <param name="cellName">列名</param>
            /// <param name="value">元となる項目の値</param>
            /// <param name="iCol">項目の列番号</param>
            var setRelatedValue = function (selectedRowId, cellName, value, iCol) {
                // TODO：画面の仕様に応じて以下の関連項目を設定を変更してください。
                // 必要量再計算
                var target = "qty_hitsuyo";
                if (cellName === "wt_shiyo_zan") {
                    var row = grid.getRowData(selectedRowId),
                        shiyoSum = row.su_shiyo_sum,
                        qtyHitsuyo = 0;
                    var qtyHitsuyoNonyu = 0,
                        qtyHitsuyoNonyuHasu = 0;

                    // 値が空白やnullの場合は0を設定する
                    var isNamber = App.isNumeric(shiyoSum);
                    if (App.isUndefOrNull(shiyoSum) || shiyoSum == "" || !isNamber) {
                        shiyoSum = 0;
                    }
                    isNamber = App.isNumeric(value);
                    if (App.isUndefOrNull(value) || value == "" || !isNamber) {
                        value = 0;
                    }

                    // 整数にしてから計算する(小数点第三位にする。三位以下は切り捨て)
                    //var shiyoZan = Math.floor((value * 1000)) / 1000;
                    //var shiyoZan = ~ ~(value * 1000);
                    var shiyoZan = Math.multiply(value, 1000);
                    //shiyoSum = ~ ~(shiyoSum * 1000);
                    shiyoSum = Math.multiply(shiyoSum, 1000);
                    // 必要量 = 使用予定量 - 前日残
                    qtyHitsuyo = shiyoSum - shiyoZan;

                    if (qtyHitsuyo != 0) {
                        // 小数点付きに戻す
                        qtyHitsuyo = qtyHitsuyo / 1000;
                    }

                    // 必要量をグリッドに設定
                    grid.setCell(selectedRowId, target, qtyHitsuyo);

                    // 負の数となった場合、文字色を赤色に変更
                    if (0 > parseFloat(grid.getCell(selectedRowId, target))) {
                        grid.setCell(selectedRowId, target, '', { color: '#ff6666' });
                    } else {
                        // 正の数なら、文字色を黒に戻す
                        grid.setCell(selectedRowId, target, '', { color: '#000000' });
                    }
                    if (row.wt_ko > 0) {
                        qtyHitsuyoNonyu = parseInt(qtyHitsuyo / (row.wt_ko * row.su_iri));
                        qtyHitsuyoNonyuHasu = qtyHitsuyo % (row.wt_ko * row.su_iri);

                        if (row.cd_tani_nonyu == pageLangText.kgCdTani.text || row.cd_tani_nonyu == pageLangText.lCdTani.text) {
                            qtyHitsuyoNonyuHasu = qtyHitsuyoNonyuHasu * 1000;
                        } else {
                            qtyHitsuyoNonyuHasu = qtyHitsuyoNonyuHasu / row.wt_ko;
                            // 小数点第二位を切上げ：JSの場合、一度切り捨ててから切り上げを行う
                            qtyHitsuyoNonyuHasu = Math.floor(qtyHitsuyoNonyuHasu * 100) / 100;
                            qtyHitsuyoNonyuHasu = Math.ceil(qtyHitsuyoNonyuHasu * 10) / 10;
                        }
                        grid.setCell(selectedRowId, "qty_hitsuyoNonyu", qtyHitsuyoNonyu);
                        grid.setCell(selectedRowId, "qty_hitsuyoNonyuHasu", qtyHitsuyoNonyuHasu);

                        // 負の数となった場合、文字色を赤色に変更
                        if (0 > parseFloat(grid.getCell(selectedRowId, "qty_hitsuyoNonyu"))) {
                            grid.setCell(selectedRowId, "qty_hitsuyoNonyu", '', { color: '#ff6666' });
                        } else {
                            // 正の数なら、文字色を黒に戻す
                            grid.setCell(selectedRowId, "qty_hitsuyoNonyu", '', { color: '#000000' });
                        }
                        // 負の数となった場合、文字色を赤色に変更
                        if (0 > parseFloat(grid.getCell(selectedRowId, "qty_hitsuyoNonyuHasu"))) {
                            grid.setCell(selectedRowId, "qty_hitsuyoNonyuHasu", '', { color: '#ff6666' });
                        } else {
                            // 正の数なら、文字色を黒に戻す
                            grid.setCell(selectedRowId, "qty_hitsuyoNonyuHasu", '', { color: '#000000' });
                        }
                    } else {
                        grid.setCell(selectedRowId, "qty_hitsuyoNonyu", "0");
                        grid.setCell(selectedRowId, "qty_hitsuyoNonyu", '', { color: '#000000' });
                        grid.setCell(selectedRowId, "qty_hitsuyoNonyuHasu", "0.000");
                        grid.setCell(selectedRowId, "qty_hitsuyoNonyuHasu", '', { color: '#000000' });

                    }
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
            $(".colchange-button").on("click", showColumnSettingDialog);

            //// コントロール定義 -- End

            //// 操作制御定義 -- Start

            // 操作制御定義を定義します。
            App.ui.pagedata.operation.applySetting(App.ui.page.user.Roles[0], App.ui.page.lang);

            //// 操作制御定義 -- End

            //// 事前データロード -- Start 

            // 画面アーキテクチャ共通の事前データロード
            App.deferred.parallel({
                loading: App.ui.loading.show(pageLangText.nowProgressing.text),
                // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                // 品区分：資材　未使用フラグ：使用　にて抽出
                bunruiCode: App.ajax.webget("../Services/FoodProcsService.svc/ma_bunrui()?$filter=kbn_hin eq " + pageLangText.shizaiHinKbn.text
                                            + " and flg_mishiyo eq " + pageLangText.shiyoMishiyoFlg.text
                                            + " &$orderby=cd_bunrui")
                // TODO: ここまで
            }).done(function (result) {
                // TODO: 画面の仕様に応じて以下のサービス呼び出し成功時の処理を変更してください。
                bunruiCode = result.successes.bunruiCode.d;
                var target = $(".search-criteria [name='bunruiCode']")
                // 検索用ドロップダウンの設定
                App.ui.appendOptions(target, "cd_bunrui", "nm_bunrui", bunruiCode, true);

                // 当日日付を挿入
                $(".search-criteria [name='dt_hiduke_search']").datepicker("setDate", new Date());

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
                var criteria = $(".search-criteria").toJSON();
                searchCondition = criteria;
                var query = {
                    // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                    //url: "../Services/FoodProcsService.svc/vw_tr_zan_01",
                    url: "../api/ShiyoryoKeisan",
                    con_hizuke: App.data.getDateTimeStringForQuery(criteria.dt_hiduke_search),
                    con_bunrui: criteria.bunruiCode,
                    hinKubun: pageLangText.shizaiHinKbn.text,
                    flg_yojitsu: getYojitsuFlag(criteria.dt_hiduke_search),
                    flg_jikagen: pageLangText.systemValueZero.text, // 自家原料が選択されているかどうか。資材に自家原料はないので「0」固定
                    flg_shiyo: pageLangText.shiyoMishiyoFlg.text,
                    kbn_jikagen: pageLangText.jikaGenryoHinKbn.text,
                    // TODO: ここまで
                    //filter: createFilter(),
                    // TODO: 画面の仕様に応じて以下のソート条件を変更してください。
                    //orderby: "cd_hinmei",
                    // TODO: ここまで
                    //skip: querySetting.skip,
                    top: querySetting.top
                    //inlinecount: "allpages"
                }
                return query;
            };
            /// <summary>検索用：予実フラグ「予定」または「実績」を返却。
            /// 検索条件日付が過去の場合は「実績」、当日以降の場合は「予定」が返却される。</summary>
            /// <param name="dt_hizuke">検索条件日付</param>
            var getYojitsuFlag = function (dt_hizuke) {
                var yojitsuFlg = pageLangText.jissekiYojitsuFlg.text,
                    hizuke = App.data.getDateString(dt_hizuke, true),
                    sysdate = App.data.getDateString(new Date(), true);
                if (App.date.localDate(hizuke) >= App.date.localDate(sysdate)) {
                    yojitsuFlg = pageLangText.yoteiYojitsuFlg.text;
                }
                return yojitsuFlg;
            };
            /// <summary>フィルター条件の設定</summary>
            var createFilter = function () {
                var criteria = $(".search-criteria").toJSON(),
                    filters = [];

                // TODO: 画面の仕様に応じて以下のフィルター条件を変更してください。
                if (!App.isUndefOrNull(criteria.dt_hiduke_search)) {
                    filters.push("dt_hiduke ge DateTime'" + App.data.getFromDateStringForQuery(criteria.dt_hiduke_search) + "'");
                    filters.push("dt_hiduke le DateTime'" + App.data.getToDateStringForQuery(criteria.dt_hiduke_search) + "'");
                    // 納入予実の判定　当日以降（当日含）：予定、それ以外：実績
                    if (new Date() < criteria.dt_hiduke_search) {
                        filters.push("flg_yojitsu eq " + pageLangText.yoteiYojitsuFlg.text);
                    } else {
                        filters.push("flg_yojitsu eq " + pageLangText.jissekiYojitsuFlg.text);
                    };
                }
                if (!App.isUndefOrNull(criteria.bunruiCode) && criteria.bunruiCode.length > 0) {
                    filters.push("cd_bunrui eq'" + criteria.bunruiCode + "'");
                }
                filters.push("kbn_hin eq " + pageLangText.shizaiHinKbn.text);
                filters.push("konyu_mishiyo eq " + pageLangText.shiyoMishiyoFlg.text);
                filters.push("tani_mishiyo eq " + pageLangText.shiyoMishiyoFlg.text);
                filters.push("torihiki_mishiyo eq " + pageLangText.shiyoMishiyoFlg.text);
                filters.push("bunrui_mishiyo eq " + pageLangText.shiyoMishiyoFlg.text);
                filters.push("su_shiyo_sum ne " + pageLangText.systemValueZero.text);
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
                    App.str.format(
                        pageLangText.nowListLoading.text,
                        querySetting.skip + 1,
                        querySetting.top
                    )
                );
                App.ajax.webget(
                // WCF Data ServicesのODataシステムクエリオプションを生成
                //App.data.toODataFormat(query)
                    App.data.toWebAPIFormat(query)
                ).done(function (result) {
                    // データバインド
                    bindData(result);
                    // グリッドの先頭行選択
                    var idNum = grid.getGridParam("selrow");
                    if (idNum == null) {
                        $("#1 > td").click();
                    } else {
                        $("#" + idNum).removeClass("ui-state-highlight").find("td").click();
                    }
                    // 検索条件を閉じる
                    closeCriteria();
                    $(".ui-jqgrid-hdiv").scrollLeft(0); // 明細のスクロール位置をリセット
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
                closeSearchConfirmDialog();
                clearState();
                // 検索前バリデーション
                //var result = $(".part-body .item-list").validation().validate();
                var result = $(".search-criteria").validation().validate();
                if (result.errors.length) {
                    return;
                }
                searchItems(new query());
            };
            $(".find-button").on("click", showSearchConfirmDialog); //showSearchConfirmDialog

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
            //$(".part-body .item-list").validation(searchValidation);
            $(".search-criteria").validation(searchValidation);

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
                //querySetting.skip = querySetting.skip + result.d.results.length;
                //querySetting.count = parseInt(result.d.__count);
                querySetting.skip = querySetting.skip + result.length;
                querySetting.count = parseInt(result.length);

                // TODO：検索結果が上限数を超えていた場合
                if (parseInt(result.length) > querySetting.top) {
                    // 上限数を超えた検索結果は削除する
                    result.splice(querySetting.top, result.length);
                    querySetting.skip = result.length;
                    App.ui.page.notifyAlert.message(pageLangText.limitOver.text).show();
                }
                // TODO：上限数チェック：ここまで

                // グリッドの表示件数を更新
                grid.setGridParam({ rowNum: querySetting.skip });
                displayCount();
                // データバインド
                //var currentData = grid.getGridParam("data").concat(result.d.results);
                //grid.setGridParam({ data: currentData }).trigger('reloadGrid', [{ current: true}]);
                var currentData = grid.getGridParam("data").concat(result);
                grid.setGridParam({ data: currentData });
                // カラムの固定
                grid.setFrozenColumns().trigger('reloadGrid', [{ current: true}]);
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
            //    if (scrollTop === target.scrollTop) {
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
                // 選択行なしの場合は最終行を選択
                if (App.isUnusable(selectedRowId)) {
                    selectedRowId = ids[recordCount - 1];
                }
                currentRow = $('#' + selectedRowId)[0].rowIndex;

                return selectedRowId;
            };

            /// <summary>追加状態の変更セットに追加する変更データの設定を行います。</summary>
            /// <param name="newRow">新規行データ</param>
            var setCreatedChangeData = function (newRow) {
                // TODO: 画面の仕様に応じて以下の項目を変更してください。
                var changeData = {
                    "dt_hizuke": eval(newRow.dt_hiduke.replace(/\/Date\((\d+)\)\//gi, "new Date($1)")),
                    "cd_hinmei": newRow.cd_hinmei,
                    "wt_shiyo_zan": newRow.wt_shiyo_zan
                };
                // TODO: ここまで

                return changeData;
            };
            /// <summary>更新状態の変更セットに追加する変更データの設定を行います。</summary>
            /// <param name="row">選択行</param>
            var setUpdatedChangeData = function (row) {
                // TODO: 画面の仕様に応じて以下の項目を変更してください。
                var changeData = {
                    "dt_hizuke": eval(row.dt_hiduke.replace(/\/Date\((\d+)\)\//gi, "new Date($1)")),
                    "cd_hinmei": row.cd_hinmei,
                    "wt_shiyo_zan": row.wt_shiyo_zan
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
                if (cellName === "ArticleName") {
                    changeSet.addUpdated(selectedRowId, "cd_hinmei", value, changeData);
                }
                // TODO: ここまで
            };

            //// データ変更処理 -- End

            //// 保存処理 -- Start

            // グリッドコントロール固有の保存処理

            // <summary>データに変更がないかどうかを返します。</summary>
            var noChange = function () {
                return (App.isUnusable(changeSet) || changeSet.noChange());
            };
            // <summary>検索条件に変更がないかどうかを返します。</summary>
            var changeCondition = function () {
                var criteria = $(".search-criteria").toJSON();
                // 日付系は文字列に変換して比較する
                var hizukeCreate = App.data.getDateTimeString(criteria.dt_hiduke_search);
                hizukeSearch = App.data.getDateTimeString(searchCondition.dt_hiduke_search);

                if (criteria.bunruiCode != searchCondition.bunruiCode) {
                    return true;
                }
                if (hizukeCreate != hizukeSearch) {
                    return true;
                }
                return false;
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

                // TODO: 画面の仕様に応じて以下の変数を変更します。
                // TODO: ここまで
                // データ整合性エラーのハンドリングを行います。

            };
            /// <summary>変更を保存します。</summary>
            /// <param name="e">イベントデータ</param>
            var saveData = function (e) {
                // 確認ダイアログのクローズ
                closeSaveConfirmDialog();
                // 情報メッセージのクリア
                App.ui.page.notifyInfo.clear();
                // ローディングの表示
                App.ui.loading.show(pageLangText.nowSaving.text);

                var saveUrl = "../api/ShiyoryoKeisan";

                App.ajax.webpost(
                    saveUrl, getPostData()
                ).done(function (result) {
                    // 検索前の状態に初期化
                    clearState();
                    App.ui.page.notifyInfo.message(pageLangText.successMessage.text).show();
                    // データ検索
                    searchItems(new query());
                }).fail(function (result) {
                    // データ変更エラーハンドリングを行います。
                    handleSaveDataError(result);
                }).always(function () {
                    // ローディングの終了
                    App.ui.loading.close();
                });
            };
            /// <summary>保存前チェック</summary>
            var checkSave = function () {
                // 編集内容の保存
                //saveEdit();

                // チェック処理
                // 検索条件の必須チェック
                var result = $(".search-criteria").validation().validate();
                if (result.errors.length) {
                    App.ui.loading.close();
                    return;
                }
                // 変更セット内にバリデーションエラーがある場合は処理を抜ける
                if (!validateChangeSet()) {
                    App.ui.loading.close();
                    return;
                }
                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();
                // 変更がない場合は処理を抜ける
                if (noChange()) {
                    App.ui.page.notifyInfo.message(pageLangText.noChange.text).show();
                    App.ui.loading.close();
                    return;
                }
                // 検索条件が変更されている場合は処理を抜ける
                if (changeCondition()) {
                    App.ui.page.notifyAlert.message(
                         App.str.format(
                            pageLangText.criteriaChange.text
                            , pageLangText.searchCriteria.text
                            , pageLangText.save.text
                         )
                    ).show();
                    App.ui.loading.close();
                    return;
                } else {
                    // チェックがすべて終わってからローディング表示を終了させる
                    App.ui.loading.close();
                }

                // 保存時ダイアログを開く
                showSaveConfirmDialog();
            };
            /// <summary>保存ボタンクリック時のイベント処理を行います。</summary>
            //$(".save-button").on("click", showSaveConfirmDialog);
            $(".save-button").on("click", function () {
                // 編集内容の保存
                saveEdit();

                // ローディング表示
                App.ui.loading.show(pageLangText.nowProgressing.text);

                // チェック処理が始まるとローディング画像が表示されない為、setTimeoutで間を入れる
                setTimeout(function () {
                    checkSave();    // 保存処理の実行
                }, 100);
            });

            //// 保存処理 -- End

            //// バリデーション -- Start

            // グリッドコントロール固有のバリデーション

            // TODO: 画面の仕様に応じて以下のカスタムバリデーション定義を変更してください。

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
                } else if (e.keyCode === App.ui.keys.F3) {
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
                    resultPartStyle = resultPart[0].currentStyle || document.defaultView.getComputedStyle(resultPart[0], "");

                resultPart.height(container[0].clientHeight - searchPart[0].clientHeight - ((parseInt(resultPartStyle.marginTop, 10) * 3) || 0));
                grid.setGridWidth(resultPart[0].clientWidth - 5);
                //結果一覧のパートの高さ - パートのヘッダーの高さ - パート内のボタンのコマンドの高さ - jqGrid のカラムヘッダーの高さ
                grid.setGridHeight(resultPart[0].clientHeight - resultPartHeader[0].clientHeight - resultPartCommands[0].clientHeight - resultPart.find(".ui-jqgrid-hdiv")[0].clientHeight - 35);
            };
            /// <summary>画面リサイズ時のイベント処理を行います。</summary>
            $(App.ui.page).on("resized", resizeContents);

            /// <summary>保存確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".save-confirm-dialog .dlg-yes-button").on("click", saveData);

            // <summary>保存確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".save-confirm-dialog .dlg-no-button").on("click", closeSaveConfirmDialog);

            /// <summary>検索確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".search-confirm-dialog .dlg-yes-button").on("click", findData);

            // <summary>検索確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".search-confirm-dialog .dlg-no-button").on("click", closeSearchConfirmDialog);

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

            /// <summary>Excelファイル出力を行います。</summary>
            var printExcel = function (e) {
                var query = {
                    // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                    url: "../api/ShizaiShiyoryoKeisanExcel",
                    // TODO: ここまで
                    //filter: createFilter(),
                    // TODO: 画面の仕様に応じて以下のソート条件を変更してください。
                    orderby: "cd_hinmei"
                    // TODO: ここまで
                }
                // 必要な情報を渡します
                var criteria = $(".search-criteria").toJSON();
                var bunruiCd = criteria.bunruiCode,
                    bunruiNm = $("#condition-bunrui option:selected").text(),
                    hizuke = App.data.getDateTimeStringForQuery(criteria.dt_hiduke_search);

                var url = App.data.toODataFormat(query),
                    param = {
                        "lang": App.ui.page.lang,
                        "hiduke": hizuke,
                        "bunruiCode": bunruiCd,
                        "bunruiName": bunruiNm,
                        "hinKubun": pageLangText.shizaiHinKbn.text,
                        "flgYojitsu": getYojitsuFlag(criteria.dt_hiduke_search),
                        "flgJikagen": pageLangText.systemValueZero.text,
                        "flgShiyobun": pageLangText.shiyoMishiyoFlg.text,
                        "kbnJikagen": pageLangText.jikaGenryoHinKbn.text,
                        "userName": App.ui.page.user.Name
                    };
                url = getExcelUrl(url, param);
                //var url = App.data.toODataFormat(query);
                //var criteria = $(".search-criteria").toJSON();
                //url = url + "&lang=" + App.ui.page.lang + "&hiduke=" + App.data.getDateString(criteria.dt_hiduke_search)
                //    + "&kbn_hin=" + pageLangText.shizaiHinKbn.text + "&cd_bunrui=" + criteria.bunruiCode;
                window.open(url, '_parent');

            };
            // 引数のパラメーターを設定したEXCEL出力用URLを取得
            var getExcelUrl = function (url, param) {
                var str = "";
                for (var key in param) {
                    str += ("&" + key + "=" + param[key]);
                }
                return url + str;
            };
            /// <summary>ダウンロードボタンクリック時のオーバレイ処理を行います。</summary>
            var downloadOverlay = function () {
                App.ui.page.notifyAlert.clear();

                // 検索条件の必須チェック
                var result = $(".search-criteria").validation().validate();
                if (result.errors.length) {
                    return;
                }
                // 明細の変更をチェック
                if (!noChange()) {
                    App.ui.page.notifyAlert.message(pageLangText.unprintableCheck.text
                    ).show();
                    return;
                }

                // Excelファイル出力へ
                printExcel();
            };
            /// <summary>Excelボタンクリック時のイベント処理を行います。</summary>
            $(".excel-button").on("click", downloadOverlay);

            /// <summary>メニューボタンクリック時のイベント処理を行います。</summary>
            var backToMenu = function () {
                // IEバグによる例外発生をキャッチします。例外発生時は何もしません。
                try {
                    document.location = "./MainMenu.aspx";
                } catch (e) {
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
                        <span class="item-label" data-app-text="dt_hiduke_search"></span>
                        <input type="text" name="dt_hiduke_search" maxlength="10"/>
                    </label>
                </li>
                <li>
                    <label>
                        <span class="item-label" data-app-text="nm_bunrui"></span>
                        <select name="bunruiCode" id="condition-bunrui">
                        </select>
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
        <h3 id="listHeader" class="part-header" >
            <span data-app-text="resultList" style="padding-right: 10px;"></span>
            <span class="list-count" id="list-count" ></span>
            <span style="padding-left: 50px;" class="list-loading-message" id="list-loading-message" ></span>
        </h3>
        <div class="part-body" id="result-grid">
            <div class="item-command">
                <button type="button" class="colchange-button" data-app-operation="colchange"><span class="icon"></span><span data-app-text="colchange"></span></button>
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
        <button type="button" class="save-button" name="save-button" data-app-operation="save">
            <span class="icon"></span>
            <span data-app-text="save"></span>
        </button>
        <button type="button" class="excel-button" name="excel-button" data-app-operation="excel">
            <!--<span class="icon"></span>-->
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
    <div class="save-confirm-dialog">
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
    <div class="search-confirm-dialog">
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
    <!-- TODO: ここまで  -->

    <!-- 画面デザイン -- End -->
</asp:Content>
