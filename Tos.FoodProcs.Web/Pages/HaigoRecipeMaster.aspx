<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="HaigoRecipeMaster.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.HaigoRecipeMaster" %>

<asp:Content ID="Content1" ContentPlaceHolderID="IncludeContent" runat="server">
    <script src="<%=ResolveUrl("~/Resources/pages/pagedata-haigorecipemaster." + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
    <script src="<%=ResolveUrl("~/Resources/grid/grid.locale-" + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
    <!-- 業務用の共通処理のロード -->
    <script src="<%=ResolveUrl("~/Scripts/util/app-util.js") %>" type="text/javascript"></script>
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
        .part-body .item-list-left
        {
            float: left;
            width: 400px;
        }
        .part-body .item-list-left li
        {
            margin-bottom: .2em;
        }
        .part-body .item-list-right
        {
            margin-left: 400px;
        }
        .part-body .item-list-right li
        {
            margin-bottom: .2em;
        }
        .search-criteria select
        {
            width: 12em;
        }
        /*<%--.search-criteria .item-label
        {
            width: 10em;
        }--%>*/
        .result-list .item-label
        {
            width: 10em;
        }
        table.part-body-footer
        {
            border-collapse: separate;
            border-spacing: 15px 1px;
            position: relative; 
            top: 1%;
        }
        table.part-body-footer td
        {
            vertical-align: top;
        }
        .deleteHan-confirm-dialog,
        .replan-confirm-dialog
        {
            background-color: White;
            width: 350px;
        }
        
        .deleteHan-confirm-dialog .part-body,
        .replan-confirm-dialog .part-body
        {
            width: 95%;
        }
        .deleteAll-confirm-dialog 
        {
            background-color: White;
            width: 350px;
        }
        
        .deleteAll-confirm-dialog .part-body 
        {
            width: 95%;
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
                querySetting = { skip: 0, top: 100, count: 0 },
                isDataLoading = false,

            // TODO：画面アーキテクチャ共通の変数宣言
                hanNoMax = 0,
                koteiNoMax = 0,
                hanNoNew = 0,
                koteiNoNew = 0,
                isCreated = false,  // 新規フラグ
                isChanged = false,  // 変更フラグ
                isSagyoShiji = false, // 作業指示フラグ
                isShikakari = false, // 仕掛品フラグ
                isSearch = false, // 検索フラグ
                isCriteriaChange = false,   // 検索条件変更フラグ
                isKoteiBlank = false, // 工程空白フラグ
                haigoNameCountry = 'nm_haigo_' + App.ui.page.lang,
                hinmeiName = 'nm_hinmei_' + App.ui.page.lang,
                isChangedHinkan = false, // 品管チェック変更フラグ
                isChangedSeizo = false,  // 製造チェック変更フラグ
                hanNoCurrent = 0;        // 現在の版数


            var newDateFormat = pageLangText.dateTimeNewFormat.text;
            if (App.ui.page.langCountry == 'en-US') {
                newDateFormat = pageLangText.dateTimeNewFormatUS.text;
            }
            // 多言語対応　言語によって幅を調節
            $(".search-criteria .item-label").css("width", pageLangText.each_lang_width.number);
            $("#id_qty_shiage").css("width", pageLangText.qty_shiage_width.number);
            $("#id_totalQtyHaigo").css("width", pageLangText.totalQtyHaigo_width.number);
            $("#id_labelChomieki").css("width", pageLangText.labelChomieki_width.number);
            $("#id_wt_chomieki").css("width", pageLangText.wt_chomieki_width.number);
            $("#id_maisu").css("width", pageLangText.maisu_width.number);
            $("#id_cd_tanto_koshin").css("width", pageLangText.cd_tanto_koshin_width.number);
            $("#id_kbn_hinkan").css("width", pageLangText.kbn_hinkan_width.number);
            $("#id_kbn_seizo").css("width", pageLangText.kbn_seizo_width.number);
            // TODO: ここまで

            // グリッドコントロール固有の変数宣言
            var grid = $("#item-grid"),
                lastScrollTop = 0,
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
                changeSetFirst = new App.ui.page.changeSet(),
                changeSetSecond = new App.ui.page.changeSet(),
                firstCol = 3,
                duplicateCol = 999,
                currentRow = 0,
                currentCol = firstCol,
                tonyuCol = 1,
                hinCodeCol = 4,
                hinNameCol = 5,
                markCol = 7,
                budomariCol = 15,
                futaiCol = 21;

            var haigoMei,
                han,
                kotei,
                hinKbn,
                kinoKbn = 0,
                plc;

            var hinmeiDialog = $(".hinmei-dialog"),
                markDialog = $(".mark-dialog"),
                futaiDialog = $(".futai-dialog");

            var currentRowId = 0,
                flg_move = false;

            // 単位区分によって換算区分の表示名を切り替える
            var nm_kanzan_kg = pageLangText.tani_Kg_text.text;
            var nm_kanzan_Li = pageLangText.tani_L_text.text;
            if (pageLangText.kbn_tani_LB_GAL.text === App.ui.page.user.kbn_tani) {
                nm_kanzan_kg = pageLangText.tani_LB_text.text;
                nm_kanzan_Li = pageLangText.tani_Gal_text.text;
            }
            // TODO: ここまで

            /// <summary>グリッドのコンボボックス列のformatterに指定してください</summary>
            /// <param name="celldata">セルデータ</param>
            /// <param name="options">オプション</param>
            /// <param name="rowobject">行オブジェクト</param>
            var fn_formatValue = function (celldata, options, rowobject) {
                var showdata = options.colModel.editoptions.value()[celldata];
                // return $(document.createElement('span')).attr('original-value', celldata).text(showdata)[0].outerHTML;
                var result;
                if (celldata == null || celldata === "") {
                    // コンボボックスの表示項目がnullの時は、コードに空文字を設定する
                    result = $(document.createElement('span')).attr('original-value', '').text(showdata)[0].outerHTML;
                } else {
                    // それ以外の時は、コードにセルデータを設定する
                    result = $(document.createElement('span')).attr('original-value', celldata).text(showdata)[0].outerHTML;
                }
                return result;
            };

            var fn_unformatValue = function (celldata, options, cellobject) {
                return $(cellobject).children('span').attr('original-value');
            };

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
            var haigoCode = App.ifUndefOrNull(parameters["cdHaigo"], pageLangText.shokikaShokichi.text)
                , noHan = App.ifUndefOrNull(parameters["no_han"], pageLangText.hanNoShokichi.text)
                , cd_bunrui = parameters["cd_bunrui"]
                , haigoName = parameters["haigoName"]
                , mishiyoFlg = App.ifUndefOrNull(parameters["mishiyoFlg"], pageLangText.shiyoMishiyoFlg.text)
                , dt_yuko = App.ifUndef(parameters["dt_yuko"], "").toString().replace("#", "");

            // <summary>現在日時を取得</summary>
            var getDate = function () {
                var date = new Date();
                if (App.ui.page.lang == 'ja' || App.ui.page.lang == 'zh') {
                    date = [date.getFullYear(), ('0' + (date.getMonth() + 1)).slice(-2), ('0' + date.getDate()).slice(-2)].join('/');
                }
                else if (App.ui.page.langCountry == 'en-US') {
                    date = [('0' + (date.getMonth() + 1)).slice(-2), ('0' + date.getDate()).slice(-2), date.getFullYear()].join('/');
                }
                else {
                    date = [('0' + date.getDate()).slice(-2), ('0' + (date.getMonth() + 1)).slice(-2), date.getFullYear()].join('/');
                }
                return date;
            };
            // ダイアログ固有の変数宣言
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            var clearConfirmDialog = $(".clear-confirm-dialog"),
                saveConfirmDialog = $(".save-confirm-dialog"),
                saveCompleteDialog = $(".save-complete-dialog"),
                deleteHanConfirmDialog = $(".deleteHan-confirm-dialog"),
                deleteAllConfirmDialog = $(".deleteAll-confirm-dialog"),
                searchConfirmDialog = $(".search-confirm-dialog"),
                menuConfirmDialog = $(".menu-confirm-dialog"),
                replanConfirmDialog = $(".replan-confirm-dialog");

            // <summary>品名ダイアログをオープンする</summary>
            var openHinmeiDlg = function () {
                var selectedRowId = getSelectedRowId(),
                    option;
                switch (grid.getCell(selectedRowId, "kbn_hin")) {
                    case pageLangText.genryoHinKbn.text:
                        option = { id: 'hinmei', multiselect: false, param1: pageLangText.genryoHinDlgParam.text };
                        break;
                    case pageLangText.shikakariHinKbn.text:
                        option = { id: 'hinmei', multiselect: false, param1: pageLangText.shikakariHinDlgParam.text };
                        break;
                    case pageLangText.jikaGenryoHinKbn.text:
                        option = { id: 'hinmei', multiselect: false, param1: pageLangText.jikaGenryoHinDlgParam.text };
                        break;
                    case pageLangText.sagyoShijiHinKbn.text:
                        option = { id: 'hinmei', multiselect: false, param1: pageLangText.sagyoShijiHinDlgParam.text };
                        break;
                    default:
                        return;
                }
                hinmeiDialog.draggable(true);
                hinmeiDialog.dlg("open", option);
            };
            // TODO：ここまで
            //// 変数宣言 -- End

            //// コントロール定義 -- Start
            // ダイアログ固有のコントロール定義
            clearConfirmDialog.dlg();
            saveConfirmDialog.dlg();
            saveCompleteDialog.dlg();
            deleteHanConfirmDialog.dlg();
            deleteAllConfirmDialog.dlg();
            searchConfirmDialog.dlg();
            menuConfirmDialog.dlg();
            replanConfirmDialog.dlg();


            // ダイアログ固有のコントロール定義
            /// <summary>ダイアログを開きます。</summary>
            var showClearConfirmDialog = function () {
                clearConfirmDialogNotifyInfo.clear();
                clearConfirmDialogNotifyAlert.clear();
                clearConfirmDialog.draggable(true);
                clearConfirmDialog.dlg("open");
            };

            /// <summary>ダイアログを開きます。</summary>
            var showSaveConfirmDialog = function () {
                saveConfirmDialogNotifyInfo.clear();
                saveConfirmDialogNotifyAlert.clear();
                saveConfirmDialog.draggable(true);
                saveConfirmDialog.dlg("open");
            };
            /// <summary>ダイアログを開きます。</summary>
            var showDeleteHanConfirmDialog = function () {
                deleteHanConfirmDialogNotifyInfo.clear();
                deleteHanConfirmDialogNotifyAlert.clear();
                deleteHanConfirmDialog.draggable(true);
                deleteHanConfirmDialog.dlg("open");
            };
            /// <summary>ダイアログを開きます。</summary>
            var showDeleteAllConfirmDialog = function () {
                deleteAllConfirmDialogNotifyInfo.clear();
                deleteAllConfirmDialogNotifyAlert.clear();
                deleteAllConfirmDialog.draggable(true);
                deleteAllConfirmDialog.dlg("open");
            };
            // <summary>ダイアログを開きます。</summary>
            var showSearchConfirmDialog = function () {
                // 検索前に変更をチェック
                if (isChanged) {
                    searchConfirmDialogNotifyInfo.clear();
                    searchConfirmDialogNotifyAlert.clear();
                    searchConfirmDialog.draggable(true);
                    searchConfirmDialog.dlg("open");
                }
                else {
                    clearState();
                    searchItems();
                }
            };

            /// <summary>ダイアログを開きます。</summary>
            var showMenuConfirmDialog = function () {
                menuConfirmDialogNotifyInfo.clear();
                menuConfirmDialogNotifyAlert.clear();
                menuConfirmDialog.draggable(true);
                menuConfirmDialog.dlg("open");
            };

            /// <summary>ダイアログを開きます。</summary>
            var showSaveCompleteDialog = function () {
                saveCompleteDialogNotifyInfo.clear();
                saveCompleteDialogNotifyAlert.clear();
                saveCompleteDialog.draggable(true);
                saveCompleteDialog.dlg("open");
            };

            /// <summary>ダイアログを開きます。</summary>
            var showReplanConfirmDialog = function () {
                replanConfirmDialog.draggable(true);
                replanConfirmDialog.dlg("open");
            };

            /// <summary>ダイアログを閉じます。</summary>
            var closeClearConfirmDialog = function () {
                clearConfirmDialog.dlg("close");
            };
            var closeSaveConfirmDialog = function () {
                saveConfirmDialog.dlg("close");
            };
            var closeDeleteHanConfirmDialog = function () {
                deleteHanConfirmDialog.dlg("close");
            };
            var closeDeleteAllConfirmDialog = function () {
                deleteAllConfirmDialog.dlg("close");
            };
            var closeSearchConfirmDialog = function () {
                searchConfirmDialog.dlg("close");
            };
            var closeMenuConfirmDialog = function () {
                menuConfirmDialog.dlg("close");
            };
            var closeSaveCompleteDialog = function () {
                saveCompleteDialog.dlg("close");
            };
            var closeReplanConfirmDialog = function () {
                replanConfirmDialog.dlg("close");
                showSaveConfirmDialog();
            };

            // afterSaveCell
            var fncAfterSaveCell = function (selectedRowId, cellName, value, iRow, iCol) {
                // 関連項目の設定
                setRelatedValue(selectedRowId, cellName, value, iCol);
                // 更新状態の変更データの設定
                var changeDataFirst = setUpdatedChangeDataFirst(grid.getRowData(selectedRowId));
                // 更新状態の変更セットに変更データを追加
                changeSetFirst.addUpdated(selectedRowId, cellName, value, changeDataFirst);
                // 関連項目の設定を変更セットに反映
                //setRelatedChangeDataFirst(selectedRowId, cellName, value, changeDataFirst);

                //運転登録項目の操作可否
                ctrlPlc(selectedRowId, false);

                // TODO：画面の仕様に応じて追加してください。
                // チェック者名のクリア
                hinkanTantoClear();
                seizoTantoClear();
                // 重量計算
                setJuryo();
                // システム外小分のチェックボックス操作
                cntrlSystemgaiKowake(selectedRowId, cellName, value);
                // 荷姿重量、荷姿数の入力可否操作
                cntrlNisugata(selectedRowId, cellName, value, false);
                // 変更フラグをセット
                isChanged = true;
                // TODO：ここまで
            };

            // 日付の多言語対応
            var datePickerFormat = pageLangText.dateFormatUS.text;
            if (App.ui.page.langCountry !== 'en-US') {
                datePickerFormat = pageLangText.dateFormat.text;
            }
            // datepicker の設定
            $("#id_dt_from").on("keyup", App.data.addSlashForDateString);
            $("#id_dt_from").datepicker({
                dateFormat: datePickerFormat,
                minDate: new Date(1975, 1 - 1, 1)
            });
            // 有効範囲：1975/1/1～システム日付より50年後
            $("#id_dt_from").datepicker("option", 'minDate', new Date(1975, 1 - 1, 1));
            // TODO：ここまで

            //this.createGrid = (function () {
            // グリッドコントロール固有のコントロール定義
            grid.jqGrid({
                // TODO：画面の仕様に応じて以下の列名の定義を変更してください。
                colNames: [
                        pageLangText.no_tonyu.text
                        , pageLangText.no_kotei.text
                        , pageLangText.kbn_hin.text + pageLangText.requiredMark.text
                        , pageLangText.cd_hinmei.text + pageLangText.requiredMark.text
                        , pageLangText.nm_hinmei.text
                        , pageLangText.cd_mark.text
                        , pageLangText.mark.text
                        , pageLangText.wt_shikomi.text + pageLangText.requiredMark.text
                        , pageLangText.nm_tani_shiyo.text
                        , pageLangText.wt_nisugata.text
                        , pageLangText.su_nisugata.text
                        , pageLangText.wt_kowake.text
                        , pageLangText.su_kowake.text
                        , pageLangText.flg_kowake_systemgai.text
                        , pageLangText.ritsu_budomari.text + pageLangText.requiredMark.text
                        , pageLangText.ritsu_hiju.text
                        , pageLangText.su_settei.text
                        , pageLangText.su_settei_max.text
                        , pageLangText.su_settei_min.text
                        , pageLangText.cd_futai.text
                        , pageLangText.nm_futai.text
                        , pageLangText.nm_plc_komoku.text
                        , pageLangText.dt_create.text
                        , pageLangText.cd_create.text
                        , pageLangText.dt_update.text
                        , pageLangText.cd_update.text
                        , pageLangText.ts.text
                        , pageLangText.nm_haigo_total.text
                        , pageLangText.no_seq.text
                        , pageLangText.nm_hinmei.text
                        , pageLangText.cd_tani_shiyo.text
                    ],
                // TODO：ここまで
                // TODO：画面の仕様に応じて以下の列モデルの定義を変更してください。
                colModel: [
                        { name: 'no_tonyu', width: 0, hidden: true, editable: false, hidedlg: true },
                        { name: 'no_kotei', width: pageLangText.no_kotei_width.number, sortable: false, editable: false, resizable: false },
                        { name: 'kbn_hin', width: pageLangText.kbn_hin_width.number, sortable: false, editable: true, resizable: false, hidden: false, edittype: 'select',
                            editoptions: {
                                value: function () {
                                    // グリッド内のドロップダウンの生成
                                    return grid.prepareDropdown(hinKbn, "nm_kbn_hin", "kbn_hin");
                                }
                            }, formatter: fn_formatValue, unformat: fn_unformatValue
                        },
                        { name: 'cd_hinmei', width: pageLangText.cd_hinmei_width.number, sortable: false, editable: true, resizable: false },
                        { name: 'nm_hinmei', width: pageLangText.nm_hinmei_width.number, sortable: false, editable: true, resizable: true },
                        { name: 'cd_mark', width: 0, hidden: true, hidedlg: true },
                        { name: 'mark', width: pageLangText.mark_width.number, sortable: false, editable: true, resizable: false },
                        { name: 'wt_shikomi', width: pageLangText.wt_shikomi_width.number, sortable: false, editable: true, resizable: false, align: 'right',
                            formatter: changeZeroToBlankTruncate,
                            formatoptions: {
                                decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 6, defaultValue: ""
                            }
                        },
                        { name: 'nm_tani_shiyo', width: pageLangText.nm_tani_shiyo_width.number, sortable: false, editable: false, resizable: true,
                            formatter: function (cellvalue, options, rowObject) {
                                var kbn = rowObject.cd_tani_shiyo;
                                var ret = nm_kanzan_kg;
                                if (kbn == pageLangText.lCdTani.text) {
                                    ret = nm_kanzan_Li;
                                }
                                return ret;
                            }
                        },
                        { name: 'wt_nisugata', width: pageLangText.wt_nisugata_width.number, sortable: false, editable: true, resizable: false, align: 'right',
                            formatter: changeZeroToBlankTruncate,
                            formatoptions: {
                                decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 6, defaultValue: ""
                            }
                        },
                        { name: 'su_nisugata', width: pageLangText.su_nisugata_width.number, sortable: false, editable: true, resizable: false, align: 'right', integer: true,
                            formatter: 'integer',
                            formatoptions: {
                                thousandsSeparator: ","
                            }
                        },
                        { name: 'wt_kowake', width: pageLangText.wt_kowake_width.number, sortable: false, editable: true, resizable: false, align: 'right',
                            formatter: changeZeroToBlankTruncate,
                            formatoptions: {
                                decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 6, defaultValue: ""
                            }
                        },
                        { name: 'su_kowake', width: pageLangText.su_kowake_width.number, sortable: false, editable: true, resizable: false, align: 'right', integer: true,
                            formatter: 'integer',
                            formatoptions: {
                                thousandsSeparator: ","
                            }
                        },
                        { name: 'flg_kowake_systemgai', width: pageLangText.flg_kowake_systemgai_width.number, edittype: "checkbox", editable: true, resizable: false, hidden: false,
                            editoptions: { value: "1:0" }, formatter: 'checkbox', formatoptions: { disabled: false }, align: "center"
                        },
                        { name: 'ritsu_budomari', width: pageLangText.ritsu_budomari_width.number, sortable: false, editable: true, resizable: false, align: 'right',
                            formatter: 'number',
                            formatoptions: {
                                decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 2, defaultValue: ""
                            }
                        },
                        { name: 'ritsu_hiju', width: pageLangText.ritsu_hiju_width.number, sortable: false, editable: true, resizable: false, align: 'right',
                            formatter: 'number',
                            formatoptions: {
                                decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 3, defaultValue: ""
                            }
                        },
                        { name: 'su_settei', width: pageLangText.su_settei_width.number, sortable: false, editable: true, resizable: false, align: 'right',
                            formatter: 'number',
                            formatoptions: {
                                decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 3, defaultValue: ""
                            }
                        },
                        { name: 'su_settei_max', width: pageLangText.su_settei_max_width.number, sortable: false, editable: true, resizable: false, align: 'right',
                            formatter: 'number',
                            formatoptions: {
                                decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 3, defaultValue: ""
                            }
                        },
                        { name: 'su_settei_min', width: pageLangText.su_settei_min_width.number, sortable: false, editable: true, resizable: false, align: 'right',
                            formatter: 'number',
                            formatoptions: {
                                decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 3, defaultValue: ""
                            }
                        },
                        { name: 'cd_futai', width: 0, hidden: true, hidedlg: true },
                        { name: 'nm_futai', width: pageLangText.nm_futai_width.number, sortable: false, editable: false, resizable: true, align: 'left' },
                        { name: 'no_plc_komoku', width: 0, sortable: false, editable: true, resizable: false, hidden: true, hidedlg: true, edittype: 'select',
                            editoptions: {
                                value: function () {
                                    // グリッド内のドロップダウンの生成
                                    return app_util.prototype.makeJQGridDropDownStr(grid, plc, "nm_komoku", "no_komoku", true);
                                },
                                dataInit: function (elem) {
                                    // グリッド内のドロップダウンの幅を設定
                                    $(elem).width(130);
                                }
                            }, // formatter: fn_formatValue, unformat: fn_unformatValue
                            formatter: app_util.prototype.getFormatValueJQGridDropDownStr, unformat: fn_unformatValue
                        },
                        { name: 'dt_create', width: 0, hidden: true, hidedlg: true,
                            formatter: "date",
                            formatoptions: { srcformat: newDateFormat, newformat: newDateFormat }
                        },
                        { name: 'cd_create', width: 0, hidden: true, hidedlg: true },
                        { name: 'dt_update', width: 0, hidden: true, hidedlg: true,
                            formatter: "date",
                            formatoptions: { srcformat: newDateFormat, newformat: newDateFormat }
                        },
                        { name: 'cd_update', width: 0, hidden: true, hidedlg: true },
                        { name: 'ts', width: 0, hidden: true, hidedlg: true },
                        { name: 'juryo', width: 0, hidden: true, hidedlg: true,
                            formatter: 'number',
                            formatoptions: {
                                decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 6, defaultValue: ""
                            }
                        },
                        { name: 'no_seq', width: 0, hidden: true, hidedlg: true },
                        { name: hinmeiName, width: 0, hidden: true, hidedlg: true },
                        { name: 'cd_tani_shiyo', width: 0, hidden: true, hidedlg: true }
                    ],
                // TODO：ここまで
                datatype: "local",
                shrinkToFit: false,
                multiselect: false,
                rownumbers: true,
                hoverrows: false,
                cellEdit: true,
                cellsubmit: 'clientArray',
                footerrow: true, // 下部に固定rowを追加
                loadComplete: function () {
                    var ids = grid.jqGrid('getDataIDs'),
                        i = 0,
                        len = ids.length;

                    for (; i < len; i++) {
                        var id = ids[i];

                        // 作業指示の場合はシステム外小分のチェックボックスを操作不可にします。
                        cntrlSystemgaiKowake(id, "kbn_hin", grid.getCell(id, "kbn_hin"));

                        // マークが1～9の場合は、荷姿重量と荷姿数をクリアし操作不可にします。
                        cntrlNisugata(id, "mark", grid.getCell(id, "mark"), true);

                        // マークが「L」以外の場合は、運転登録項目をクリアし操作不可にします。
                        ctrlPlc(id, true);
                    }
                },
                gridComplete: function () {
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
                    // Enter キーでカーソルを移動
                    grid.moveCell(cellName, iRow, iCol);
                },
                afterEditCell: function (selectedRowId, cellName, value, iRow, iCol) {
                    // Enter キーでカーソルを移動
                    grid.moveCell(cellName, iRow, iCol);
                    selectCol = iCol;
                    currentRowId = selectedRowId;
                },
                beforeSaveCell: function (selectedRowId, cellName, value, iRow, iCol) {
                    // カーソルを移動
                    //grid.moveAnyCell(cellName, iRow, iCol);
                    if (cellName != 'kbn_hin' && cellName != 'cd_hinmei' && cellName != 'mark' && cellName != 'nm_hinmei') {
                        if (value != "") {
                            // カンマ区切り除去(formatterが自前なので、カンマ区切りが除去されない為)
                            var val = deleteThousandsSeparator(value);
                            // セルバリデーション
                            validateCell(selectedRowId, cellName, val, iCol);
                        }
                    }
                    else if (cellName === 'nm_hinmei') {
                        // セルバリデーション
                        validateCell(selectedRowId, cellName, value, iCol);
                    }
                    // セルバリデーション
                    //validateCell(selectedRowId, cellName, value, iCol);
                },
                afterSaveCell: function (selectedRowId, cellName, value, iRow, iCol) {
                    fncAfterSaveCell(selectedRowId, cellName, value, iRow, iCol);
                },
                onCellSelect: function (rowid, icol, cellcontent) {
                    selectCol = icol;
                },
                ondblClickRow: function (rowid) {
                    // 検索条件変更チェック
                    if (isCriteriaChange) {
                        showCriteriaChange("navigate");
                        return;
                    }
                    // 工程空白チェック
                    if (isKoteiBlank) {
                        // 情報メッセージ出力
                        showKoteiBlank();
                        return;
                    }
                    // 品名一覧
                    if (selectCol === hinCodeCol || selectCol === hinNameCol) {
                        openHinmeiDlg();
                    }
                    // マーク一覧
                    if (selectCol === markCol) {
                        showMarcDialog();
                    }
                    // 風袋一覧
                    if (selectCol === futaiCol) {
                        futaiDialog.draggable(true);
                        futaiDialog.dlg("open", { multiselect: false });
                    }
                    //checkKasaneSystemgaiKowake();
                    checkKasane(false);
                }
            });
            //})();

            /// <summary>関連項目取得用のUrlを品区分毎に設定します。</summary>
            /// <param name="hinKbn">品区分</param>
            /// <param name="selectedRowId">選択行ID</param>
            var getServiceUrl = function (hinKbn, selectedRowId) {
                // 品区分によって取得元変更
                var serviceUrl;
                switch (hinKbn) {
                    case pageLangText.genryoHinKbn.text:
                        serviceUrl = "../Services/FoodProcsService.svc/vw_ma_hinmei_02()?$filter=cd_hinmei eq '" + grid.getCell(selectedRowId, "cd_hinmei")
                            + "' and kbn_hin eq " + pageLangText.genryoHinKbn.text + " and flg_mishiyo_hin eq " + pageLangText.shiyoMishiyoFlg.text + "&$top=1"
                        break;
                    case pageLangText.shikakariHinKbn.text:
                        //serviceUrl = "../Services/FoodProcsService.svc/vw_ma_haigo_mei_01()?$filter=cd_haigo eq '"
                        //    + grid.getCell(selectedRowId, "cd_hinmei") + "' and no_han eq " + pageLangText.hanNoShokichi.text + " and kbn_hin eq "
                        //    + pageLangText.shikakariHinKbn.text + " and flg_mishiyo eq " + pageLangText.shiyoMishiyoFlg.text + "&$top=1"
                        serviceUrl = App.data.toWebAPIFormat({
                            url: "../api/HaigoMasterCommon"
                            , cd_haigo: grid.getCell(selectedRowId, "cd_hinmei")
                            , sysDate: App.data.getDateTimeStringForQueryNoUtc(new Date(), true)
                        });
                        break;
                    case pageLangText.jikaGenryoHinKbn.text:
                        serviceUrl = "../Services/FoodProcsService.svc/vw_ma_hinmei_02()?$filter=cd_hinmei eq '" + grid.getCell(selectedRowId, "cd_hinmei")
                            + "' and kbn_hin eq " + pageLangText.jikaGenryoHinKbn.text + " and flg_mishiyo_hin eq " + pageLangText.shiyoMishiyoFlg.text + "&$top=1"
                        break;
                    case pageLangText.sagyoShijiHinKbn.text:
                        serviceUrl = "../Services/FoodProcsService.svc/vw_ma_sagyo_mark_01()?$filter=cd_hinmei eq '" + grid.getCell(selectedRowId, "cd_hinmei")
                            + "' and flg_mishiyo eq " + pageLangText.shiyoMishiyoFlg.text + "&$top=1"
                        break;
                    default:
                        serviceUrl = "../Services/FoodProcsService.svc/vw_ma_hinmei_02()?$filter=cd_hinmei eq '" + grid.getCell(selectedRowId, "cd_hinmei")
                            + "' and flg_mishiyo_hin eq " + pageLangText.shiyoMishiyoFlg.text + "&$top=1"
                        break;
                };
                return serviceUrl;
            }
            /// <summary>関連情報のクリア</summary>
            /// <param name="selectedRowId">選択行ID</param>
            var hinmeiInfoClear = function (selectedRowId) {
                grid.setCell(selectedRowId, "cd_hinmei", null);
                grid.setCell(selectedRowId, hinmeiName, null);
                grid.setCell(selectedRowId, "nm_hinmei", null);
                grid.setCell(selectedRowId, "wt_haigo", $(".search-criteria [name='wt_kihon']").val());
                grid.setCell(selectedRowId, "cd_mark", pageLangText.kowakeMarkCode.text);
                grid.setCell(selectedRowId, "mark", null);
                grid.setCell(selectedRowId, "cd_tani_shiyo", null);
                grid.setCell(selectedRowId, "nm_tani_shiyo", null);
                grid.setCell(selectedRowId, "cd_futai", null);
                grid.setCell(selectedRowId, "nm_futai", null);
                grid.setCell(selectedRowId, "no_plc_komoku", null);
                grid.setCell(selectedRowId, "wt_kihon", 0);
                grid.setCell(selectedRowId, "wt_shikomi", 0);
                grid.setCell(selectedRowId, "wt_nisugata", 0);
                grid.setCell(selectedRowId, "su_nisugata", 0);
                grid.setCell(selectedRowId, "wt_kowake", 0);
                grid.setCell(selectedRowId, "su_kowake", 0);
                grid.setCell(selectedRowId, "ritsu_hiju", 0);
                grid.setCell(selectedRowId, "ritsu_budomari", 0);
                grid.setCell(selectedRowId, "flg_mishiyo", 0);
                grid.setCell(selectedRowId, "su_settei", 0);
                grid.setCell(selectedRowId, "su_settei_max", 0);
                grid.setCell(selectedRowId, "su_settei_min", 0);
            };

            /// <summary>値のカンマ区切りを除去して数値にして返却します。</summary>
            /// <param name="value">値</param>
            var deleteThousandsSeparator = function (value) {
                var retVal = 0;
                if (value != "") {
                    retVal = parseFloat(new String(value).replace(/,/g, ""));
                }
                return retVal;
            };
            /// <summary>値をカンマ区切りにして返却します。</summary>
            /// <param name="value">値</param>
            var setThousandsSeparator = function (value) {
                var str = value;
                var num = new String(str).replace(/,/g, "");
                while (num != (num = num.replace(/^(-?\d+)(\d{3})/, "$1,$2")));
                return num;
            };

            /// <summary>【切り捨て版】値が0だった場合、空白を返却します。</summary>
            /// <param name="value">セルの値</param>
            /// <param name="options">オプション</param>
            /// <param name="rowObj">行データ</param>
            function changeZeroToBlankTruncate(value, options, rowObj) {
                var returnVal = deleteThousandsSeparator(value);
                if (returnVal == 0 || isNaN(returnVal)) {
                    returnVal = "";
                }
                else {
                    // 小数点以下の桁数を固定にする
                    var fixeVal = options.colModel.formatoptions.decimalPlaces; // 丸め位置
                    var kanzan = Math.pow(10, parseInt(fixeVal));   // べき乗
                    // 指定の桁数以降は切り捨て
                    var kanzanVal = Math.floor(App.data.trimFixed(returnVal * kanzan));
                    returnVal = App.data.trimFixed(kanzanVal / kanzan);
                    // ゼロ埋め
                    returnVal = returnVal.toFixed(fixeVal); // toFixed：収まらない場合は四捨五入される
                    // カンマ区切りにする
                    returnVal = setThousandsSeparator(returnVal);
                }
                return returnVal;
            }

            /// <summary>セルの関連項目を設定します。</summary>
            /// <param name="selectedRowId">選択行ID</param>
            /// <param name="cellName">列名</param>
            /// <param name="value">元となる項目の値</param>
            /// <param name="iCol">項目の列番号</param>
            var setRelatedValue = function (selectedRowId, cellName, value, iCol) {
                // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                // 名称取得処理
                if (cellName === "kbn_hin") {
                    hinmeiInfoClear(selectedRowId);
                }
                var elementName,
                    serviceUrl,
                    codeName;
                if (cellName === "cd_hinmei") {
                    // 初期化
                    isSagyoShiji = false;
                    isShikakari = false;
                    // 選択行の品区分を取得
                    var hinKbn = grid.getCell(selectedRowId, "kbn_hin");
                    // 品区分によってデータの取得元を変更
                    serviceUrl = getServiceUrl(hinKbn, selectedRowId);
                    // 品区分によって取得項目名を変更
                    if (hinKbn == pageLangText.shikakariHinKbn.text) {
                        elementName = haigoNameCountry;
                        isSagyoShiji = false;
                        isShikakari = true;
                    }
                    else if (hinKbn == pageLangText.sagyoShijiHinKbn.text) {
                        elementName = hinmeiName;
                        isSagyoShiji = true;
                        isShikakari = false;
                    }
                    else {
                        elementName = hinmeiName;
                        isSagyoShiji = false;
                        isShikakari = false;
                    }
                    // 関連データ検索
                    App.deferred.parallel({
                        // DBから値を取得する前に変更セットへの保存されてしまう為、webgetではなくwebgetSyncで実行する
                        codeName: App.ajax.webgetSync(serviceUrl)
                    }).done(function (result) {
                        var row = grid.getRowData(selectedRowId);
                        codeName = result.successes.codeName.d;
                        // 関連データセット
                        if (codeName.length > 0 && codeName[0].cd_hinmei === value) {
                            grid.setCell(selectedRowId, hinmeiName, codeName[0][elementName]);
                            grid.setCell(selectedRowId, "nm_hinmei", codeName[0][elementName]);
                            changeSetFirst.addUpdated(selectedRowId, "nm_hinmei", codeName[0][elementName], null);
                            if (isSagyoShiji) {
                                grid.setCell(selectedRowId, "cd_mark", codeName[0]["cd_mark"]);
                                grid.setCell(selectedRowId, "mark", codeName[0]["mark"]);
                                changeSetFirst.addUpdated(selectedRowId, "cd_mark", codeName[0]["cd_mark"], null);
                                //changeSetFirst.addUpdated(selectedRowId, "mark", codeName[0]["mark"], null);
                                grid.setCell(selectedRowId, "cd_tani_shiyo", null);
                                grid.setCell(selectedRowId, "nm_tani_shiyo", null);
                            }
                            else {
                                grid.setCell(selectedRowId, "cd_mark", pageLangText.kowakeMarkCode.text);
                                //grid.setCell(selectedRowId, "mark", pageLangText.kowakeMarkKbn.text);
                                grid.setCell(selectedRowId, "mark", null);
                                cntrlNisugata(selectedRowId, "mark", pageLangText.kowakeMarkKbn.text, false);
                                changeSetFirst.addUpdated(selectedRowId, "cd_mark", pageLangText.kowakeMarkCode.text, null);
                                grid.setCell(selectedRowId, "ritsu_hiju", codeName[0]["ritsu_hiju"]);
                                changeSetFirst.addUpdated(selectedRowId, "ritsu_hiju", codeName[0]["ritsu_hiju"], null);

                                // 取得した歩留がNULLだった場合は100を設定する
                                var budomari = codeName[0]["ritsu_budomari"];
                                if (App.isUndefOrNull(budomari)) {
                                    budomari = pageLangText.budomariShokichi.text;
                                }
                                grid.setCell(selectedRowId, "ritsu_budomari", budomari);
                                changeSetFirst.addUpdated(selectedRowId, "ritsu_budomari", budomari, null);

                                if (isShikakari) {
                                    grid.setCell(selectedRowId, "cd_tani_shiyo", codeName[0]["kbn_kanzan"]);
                                    grid.setCell(selectedRowId, "nm_tani_shiyo", codeName[0]["nm_tani_shiyo"]);
                                }
                                else {
                                    grid.setCell(selectedRowId, "cd_tani_shiyo", codeName[0]["cd_tani"]);
                                    grid.setCell(selectedRowId, "nm_tani_shiyo", codeName[0]["nm_tani"]);
                                }
                            }
                            // validationチェック
                            validateCell(selectedRowId, "cd_hinmei", value, iCol);
                        }
                        else {
                            var unique = selectedRowId + "_" + iCol;
                            if (codeName.length > 0) {
                                App.ui.page.notifyAlert.message(pageLangText.notFound.text, unique).show();
                            } else {
                                App.ui.page.notifyAlert.message(App.str.format(MS0049, pageLangText.cd_hinmei.text), unique).show();
                            }
                            grid.setCell(selectedRowId, iCol, "", { background: '#ff6666' });
                            // 取得出来なかった場合は関連情報クリア
                            hinmeiInfoClear(selectedRowId);
                        }
                        // 更新状態の変更データの設定
                        var changeDataFirst = setUpdatedChangeDataFirst(grid.getRowData(selectedRowId));
                        // 更新状態の変更セットに変更データを追加
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
                if (cellName == "mark") {
                    serviceUrl = "../Services/FoodProcsService.svc/ma_mark()?$filter=mark eq '" + value + "'&$top=1",
                    elementName = "cd_mark";

                    App.deferred.parallel({
                        codeName: App.ajax.webgetSync(serviceUrl)
                    }).done(function (result) {
                        var row = grid.getRowData(selectedRowId);
                        codeName = result.successes.codeName.d;
                        if (codeName.length > 0) {
                            grid.setCell(selectedRowId, elementName, codeName[0][elementName]);
                            grid.setCell(selectedRowId, "mark", codeName[0]["mark"]);
                            changeSetFirst.addUpdated(selectedRowId, elementName, codeName[0][elementName], null);
                            changeSetFirst.addUpdated(selectedRowId, "mark", codeName[0]["mark"], null);
                        }
                        else {
                            grid.setCell(selectedRowId, "cd_mark", null);
                            changeSetFirst.addUpdated(selectedRowId, "cd_mark", null, null);
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
                    });
                    // マークがL以外だった場合にPLC項目番号の項目を空にする
                    if (grid.getCell(selectedRowId, "cd_mark") !== pageLangText.ryuryokeiMarkCode.text) {
                        grid.setCell(selectedRowId, "no_plc_komoku", null);
                        changeSetFirst.addUpdated(selectedRowId, "no_plc_komoku", null, null);
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
            $(".colchange-button").on("click", function (e) {
                // 検索条件変更チェック
                if (isCriteriaChange) {
                    showCriteriaChange("colchange");
                    return;
                }
                // 工程空白チェック
                if (isKoteiBlank) {
                    // 情報メッセージ出力
                    showKoteiBlank();
                    return;
                }
                showColumnSettingDialog(e);
            });

            // 多言語対応
            $("[name='nm_haigo']").attr("name", haigoNameCountry);
            //// コントロール定義 -- End

            //---------------------------------------------------------
            //2019/07/24 trinh.bd Task #14029
            //------------------------START----------------------------
            //// 操作制御定義 -- Start

            // 操作制御定義を定義します。
            //App.ui.pagedata.operation.applySetting(App.ui.page.user.Roles[0], App.ui.page.lang);
            var kbn_ma_haigo = App.ui.page.user.kbn_ma_haigo;
            if (kbn_ma_haigo == pageLangText.isRoleFisrt.number) {
                App.ui.pagedata.operation.applySetting("isRoleFisrt", App.ui.page.lang);
            }
            else if (kbn_ma_haigo == pageLangText.isRoleSecond.number) {
                App.ui.pagedata.operation.applySetting("isRoleSecond", App.ui.page.lang);
            } else {
                App.ui.pagedata.operation.applySetting("NotRole", App.ui.page.lang);
            }
            //// 操作制御定義 -- End
            //------------------------END------------------------------

            //// 事前データロード -- Start 
            // コンボボックスに格納するデータをGROUP BYする。
            function groupBy(data, index) {
                var j = 0;
                var group = {};
                group[j] = data[0];
                $.each(data, function (i, value) {
                    if (value[index] !== group[j][index]) {
                        j = j + 1;
                        group[j] = value;
                    }
                })
                if (!App.isUndefOrNull(group[0])) {
                    return group;
                }
                else {
                    return data;
                }
            }

            /// <summary>最大工程を取得します。</summary>
            var maxKotei = function (no_kotei) {
                koteiList = new Array();
                $.each(no_kotei, function (i, value) {
                    koteiList[i] = value.no_kotei;
                });
                var max = Math.max.apply(null, koteiList);
                return parseInt(max);
            };

            // 画面アーキテクチャ共通の事前データロード
            App.deferred.parallel({
                loading: App.ui.loading.show(pageLangText.nowProgressing.text),
                // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                haigoMei: App.ajax.webget("../Services/FoodProcsService.svc/vw_ma_haigo_mei_01?$filter=cd_haigo eq '" + haigoCode + "' and no_han eq " + noHan + " and kbn_hin eq " + pageLangText.shikakariHinKbn.text + "&$orderby=no_han"), //該当配合コードの版を取得
                han: App.ajax.webget("../Services/FoodProcsService.svc/ma_haigo_mei?$filter=cd_haigo eq '" + haigoCode + "'&$select=no_han&$orderby=no_han desc"),
                hinKbn: App.ajax.webget("../Services/FoodProcsService.svc/ma_kbn_hin?$filter=kbn_hin eq " + pageLangText.genryoHinKbn.text + " or kbn_hin eq " + pageLangText.shikakariHinKbn.text + " or kbn_hin eq " + pageLangText.jikaGenryoHinKbn.text + " or kbn_hin eq " + pageLangText.sagyoShijiHinKbn.text + "&$select=kbn_hin,nm_kbn_hin&$orderby=kbn_hin"),
                plc: App.ajax.webget("../Services/FoodProcsService.svc/ma_plc?$orderby=no_komoku asc"),
                kbnPlc: App.ajax.webget("../Services/FoodProcsService.svc/cn_kino_sentaku?$filter=kbn_kino eq " + pageLangText.kinoPlcHyojiKbn.number)
                // TODO: ここまで
            }).done(function (result) {
                // TODO: 画面の仕様に応じて以下のサービス呼び出し成功時の処理を変更してください。
                // 配合名マスタにデータがある場合はデータセット
                if (!App.isUndefOrNull(result.successes.haigoMei.d[0])) {
                    // 版コードの取得
                    var no_han = result.successes.han.d;
                    // 品区分の取得
                    hinKbn = result.successes.hinKbn.d;
                    //機能選択よりPlcありの場合、運転登録項目を設定する
                    if (result.successes.kbnPlc.d.length != 0) {
                        kinoKbn = result.successes.kbnPlc.d[0].kbn_kino_naiyo;
                        if (kinoKbn == pageLangText.kbnPlcAri.number) {
                            //運転登録データの取得
                            plc = result.successes.plc.d;
                            // 運転登録項目を表示する
                            grid.jqGrid('showCol', "no_plc_komoku");
                            grid.setColProp('no_plc_komoku', { hidedlg: false });
                        }
                    }
                    // 検索条件の設定
                    var criteria = $(".search-criteria"),
                    // 検索データの定義
                    data = result.successes.haigoMei.d[0];
                    // データのバインド
                    criteria.toForm(data);
                    // 検索用ドロップダウンの設定
                    App.ui.appendOptions($(".search-criteria [name='no_han']"), "no_han", "no_han", no_han, false);
                    // 最大版・工程の取得
                    if (result.successes.han.d.length == 0) {
                        hanNoMax = 0;
                        koteiNoMax = 0;
                        $("[name='no_kotei']").append($('<option>').html(pageLangText.koteiNoShokichi.text).val(pageLangText.koteiNoShokichi.text));
                        $("[name='no_kotei']").val(pageLangText.koteiNoShokichi.text)
                        $('.nm_shinki_han').attr('disabled', true);
                        $('.nm_shinki_kotei').attr('disabled', true);
                    }
                    else {
                        hanNoMax = parseInt(result.successes.han.d[0].no_han);
                        searchKoteiNo();
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
            }).always(function () {
                App.ui.loading.close();
            });

            // <summary>工程コンボボックスのセット</summary>
            var searchKoteiNo = function () {
                var hanNo = getHanNo();
                // 画面アーキテクチャ共通の事前データロード
                App.deferred.parallel({
                    // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                    kotei: App.ajax.webget("../Services/FoodProcsService.svc/vw_ma_haigo_recipe_01?$filter=cd_haigo eq '" + haigoCode + "' and no_han eq " + hanNo + "&$select=no_han,no_kotei&$orderby=no_kotei")
                    // TODO: ここまで
                }).done(function (result) {
                    // TODO: 画面の仕様に応じて以下のサービス呼び出し成功時の処理を変更してください。
                    // 工程コードの取得
                    var no_kotei = groupBy(result.successes.kotei.d, "no_kotei");
                    // 検索用ドロップダウンの初期化
                    $(".search-criteria [name='no_kotei']").empty();
                    // 検索用ドロップダウンの設定
                    App.ui.appendOptions($(".search-criteria [name='no_kotei']"), "no_kotei", "no_kotei", no_kotei, true);
                    // 最大版・工程の取得
                    if (result.successes.kotei.d.length == 0) {
                        hanNoMax = 0;
                        koteiNoMax = 0;
                        $("[name='no_kotei']").append($('<option>').html(pageLangText.koteiNoShokichi.text).val(pageLangText.koteiNoShokichi.text));
                        $("[name='no_kotei']").val(pageLangText.koteiNoShokichi.text)
                        $('.nm_shinki_han').attr('disabled', true);
                        $('.nm_shinki_kotei').attr('disabled', true);
                    }
                    else {
                        koteiNoMax = maxKotei(no_kotei);
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

            //// 事前データロード -- End

            //// 検索処理 -- Start

            // 画面アーキテクチャ共通の検索処理

            /// <summary>検索条件に表示されている版を取得します。</summary>
            var getHanNo = function () {
                return $("[name='no_han']").val();
            };

            /// <summary>データ検索用の版を取得します。</summary>
            var getSearchHanNo = function () {
                if (hanNoNew == getHanNo()) {
                    if (hanNoNew == 1) {
                        return
                    }
                    else {
//                        searchHanNo = hanNoNew - 1;
                        searchHanNo = hanNoCurrent;
                    }
                }
                else {
                    searchHanNo = getHanNo();
                }
                return searchHanNo;
            };

            /// <summary> 数値の長さを取得します。</summary>
            var getDecimalLength = function (value) {
                var list = (value + '').split('.')
                    , isDeci = false;
                isDeci = !App.isUndef(list[1]) && list[1].length > 0;
                return isDeci ? list[1].length : 0;
            }

            /// <summary> 乗算処理をします。</summary>
            var multiply = function (value1, value2) {
                var intValue1 = +(value1 + '').replace('.', ''),
                    intValue2 = +(value2 + '').replace('.', ''),
                    decimalLength = getDecimalLength(value1) + getDecimalLength(value2),
                    result;

                result = (intValue1 * intValue2) / Math.pow(10, decimalLength);
                return result;
            }

            /// <summary> 除算処理をします。</summary>
            var divide = function (value1, value2) {
                var intValue2 = +(value2 + '').replace('.', '');
                var valAry = value2.toString().split(".");
                var deciLen = valAry.length == 2 ? valAry[1].length : 0;
                var numerator = Math.pow(10, deciLen);
                var result = multiply(value1, (numerator / intValue2));

                return result;
            }

            /// <summary> 減算処理をします。</summary>
            var subtract = function (value1, value2) {
                var max = Math.max(getDecimalLength(value1), getDecimalLength(value2)),
                        k = Math.pow(10, max);
                return (multiply(value1, k) + multiply(value2, k)) / k;
            }

            // 重量の計算 合計行の設定
            var setJuryo = function () {
                var kbnKanzan = $("[name='kbn_kanzan']").val();
                var haigoJuryo = grid.jqGrid('getCol', 'wt_shikomi', true);  //配合重量を取得
                var hiju = grid.jqGrid('getCol', 'ritsu_hiju', true);    //比重を取得
                var shiyoTani = grid.jqGrid('getCol', 'cd_tani_shiyo', true);   //使用単位を取得
                var kbnHinGrid = grid.jqGrid('getCol', 'kbn_hin', true); //品区分を取得
                var ids = grid.getDataIDs();
                var rowTotal = 0;
                for (var i = 0; i < haigoJuryo.length; i++) {
                    var selectedRowId = ids[i];
                    if (hiju[i].value == 0) {
                        // 比重が0の場合は1とする
                        hiju[i].value = 1;
                    }
                    if (kbnHinGrid[i].value == pageLangText.sagyoShijiHinKbn.text) {
                        // 品区分が「作業指示」の場合、明細/配合重量=0とする
                        grid.setCell(selectedRowId, "juryo", 0);
                        continue;
                    }
                    // 品区分が原料、自家原料、仕掛品の場合
                    var wk = 0;
                    if (kbnKanzan == pageLangText.kgKanzanKbn.text) {
                        // 配合名マスタの換算区分が'Kg'の場合
                        wk = haigoJuryo[i].value * hiju[i].value;
                        if (shiyoTani[i].value == pageLangText.kgKanzanKbn.text) {
                            // 明細．使用単位が「Kg」のとき
                            wk = haigoJuryo[i].value;
                        }
                    }
                    else {
                        // 配合名マスタの換算区分が'Kg'以外の場合
                        wk = haigoJuryo[i].value / hiju[i].value;
                        if (shiyoTani[i].value == pageLangText.lKanzanKbn.text) {
                            // 明細．使用単位が「L」のとき
                            wk = haigoJuryo[i].value;
                        }
                    }
                    // 小数点以下6桁にする(四捨五入)
                    wk = App.data.trimFixed(Math.round(getThousandsSeparatorDel(wk) * 1000000) / 1000000);
                    //wk = Math.round(wk * 1000000) / 1000000;
                    grid.setCell(selectedRowId, "juryo", wk);
                    rowTotal = subtract(rowTotal, wk);
                    grid.jqGrid('footerData', 'set', { wt_shikomi: rowTotal });
                    grid.jqGrid('footerData', 'set', { juryo: rowTotal });
                }
                //setTotal(); // 合計の計算処理へ
            };
            /// <summary>システム外小分の操作可否を制御します。</summary>
            /// <param name="id">行ID</param>
            /// <param name="cName">セル名</param>
            /// <param name="val">値</param>
            var cntrlSystemgaiKowake = function (id, cName, val) {
                if (cName !== "kbn_hin") {
                    return;
                }

                var checkbox = $("#" + id).find(":checkbox");
                if (val === pageLangText.sagyoShijiHinKbn.text) {
                    // 作業指示の場合

                    // チェックボックスがチェックされている場合はチェックを外す
                    if (checkbox.is(":checked")) {
                        checkbox.prop("checked", false);
                        // 更新状態の変更データの設定
                        var changeDataFirst = setUpdatedChangeDataFirst(grid.getRowData(id));
                        // 更新状態の変更セットに変更データを追加
                        changeSetFirst.addUpdated(id, "flg_kowake_systemgai", pageLangText.checkBoxCheckOff.text, changeDataFirst);
                    }

                    // システム外小分のチェックボックスを非活性化
                    grid.setCell(id, "flg_kowake_systemgai", '', 'not-editable-cell');
                    checkbox.attr("disabled", "disabled");
                }
                else {
                    // 作業指示以外の場合
                    // システム外小分のチェックボックスを活性化
                    checkbox.parent().removeClass('not-editable-cell');
                    checkbox.removeAttr("disabled");
                }
            };

            /// <summary>荷姿重量と荷姿数データの設定を行います。</summary>
            var setNisugataData = function (row) {
                // TODO: 画面の仕様に応じて以下の項目を変更してください。
                var addNisugataData = {
                    "wt_nisugata": 0
                    , "su_nisugata": 0
                };

                return addNisugataData;
            };

            /// <summary>荷姿重量と荷姿数の操作可否を制御します。</summary>
            /// <param name="id">行ID</param>
            /// <param name=cntrlNisugata"cName">セル名</param>
            /// <param name="val">値</param>
            var cntrlNisugata = function (id, cName, val, firstFlg) {
                if (cName !== "mark" && cName !== "cd_mark") {
                    return;
                }

                var markVal = grid.getCell(id, "mark");
                var nisugataWt = $("#" + id).find("[aria-describedby='item-grid_wt_nisugata']");
                var nisugataSu = $("#" + id).find("[aria-describedby='item-grid_su_nisugata']");

                //マークが1～9かをチェック
                if (markVal > 0 && markVal < 10) {
                    //クリア、非活性にする
                    grid.setCell(id, "wt_nisugata", '', 'not-editable-cell');
                    grid.setCell(id, "su_nisugata", '', 'not-editable-cell');
                    grid.setCell(id, "wt_nisugata", null);
                    grid.setCell(id, "su_nisugata", null);

                    if (firstFlg === false) {
                        // 更新状態の変更データの設定
                        var changeData = setNisugataData(grid.getRowData(id));

                        // TODO：画面の仕様に応じて以下の定義を変更してください。
                        value = changeData["wt_nisugata"];
                        value2 = changeData["su_nisugata"];

                        // 更新状態の変更セットに変更データを追加
                        changeSetFirst.addUpdated(id, "wt_nisugata", value, changeData);
                        changeSetFirst.addUpdated(id, "su_nisugata", value2, changeData);
                    }
                }
                else {
                    //活性にする
                    nisugataWt.removeClass('not-editable-cell');
                    nisugataSu.removeClass('not-editable-cell');
                    return;
                }
            };

            /// <summary>運転登録項目の操作可否を制御します。</summary>
            /// <param name="id">行ID</param>
            /// <param name="firstFlg">ページ読み込み時・新規行か否か</param>
            var ctrlPlc = function (id, firstFlg) {
                //対象行に設定されているマークを取得
                var markVal = grid.getCell(id, "mark");
                //マークがLまたはSの場合運転登録活性
                // if (markVal != pageLangText.ryuryokeiMarkKbn.text) 
                if (markVal != pageLangText.ryuryokeiMarkKbn.text && markVal != pageLangText.sagyoMarkKbn.text)
                {

                    //対象行の運転登録の項目をクリア、非活性にする
                    grid.setCell(id, "no_plc_komoku", null, 'not-editable-cell');
                    grid.setCell(id, "no_plc_komoku", null, { background: '' });
                } else {
                    //対象行の運転登録の項目を活性にする
                    grid.deleteColumnClass(id, 'no_plc_komoku', 'not-editable-cell');
                }
                return;
            };

            /*
            var setTotal = function () {
            var totalHaigo = grid.jqGrid('getCol', 'juryo', false, 'sum');
            grid.jqGrid('footerData', 'set', { wt_shikomi: totalHaigo });
            grid.jqGrid('footerData', 'set', { juryo: totalHaigo });
            };
            */
            /// <summary>データ検索を行います。</summary>
            /// <param name="query">クエリオブジェクト</param>
            var searchItems = function () {
                // データロード中の場合は中止
                if (isDataLoading) {
                    return;
                }
                isDataLoading = true;
                //var hanNo = getHanNo();
                var hanNo = getSearchHanNo();
                closeSearchConfirmDialog();
                // ローディングの表示
                //$("#list-loading-message").text(pageLangText.nowLoading.text);
                App.ui.loading.show(pageLangText.nowLoading.text);
                // 配合名マスタ検索処理
                App.deferred.parallel({
                    // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。

                    // 該当配合コード・版のデータを取得
                    haigoBody: App.ajax.webget("../Services/FoodProcsService.svc/vw_ma_haigo_mei_01?$filter=cd_haigo eq '"
                        + $("[name='cd_haigo']").val() + "' and no_han eq " + hanNo + " and kbn_hin eq "
                        + pageLangText.shikakariHinKbn.text),
                    // 1版の配合名マスタを取得
                    mishiyoFlg: App.ajax.webget("../Services/FoodProcsService.svc/ma_haigo_mei?$filter=cd_haigo eq '"
                        + $("[name='cd_haigo']").val() + "' and no_han eq " + pageLangText.hanNoShokichi.text
                        + "&$select=flg_mishiyo")

                    // TODO: ここまで
                }).done(function (result) {
                    // TODO: 画面の仕様に応じて以下のサービス呼び出し成功時の処理を変更してください。
                    // 配合名マスタ部分のデータ設定
                    var body = $(".part-body");
                    // 検索フラグを立てる
                    isSearch = true;
                    if (App.isUndefOrNull(result.successes.haigoBody.d[0])) {
                        App.ui.loading.close();
                        // データが存在しない場合処理を抜ける
                        App.ui.page.notifyAlert.message(pageLangText.haigoNotExists.text).show();
                        $("#list-loading-message").text("");
                        isDataLoading = false;
                        return;
                    }
                    else if (pageLangText.hanNoShokichi.text != getHanNo()
                            && result.successes.mishiyoFlg.d[0].flg_mishiyo == pageLangText.mishiyoMishiyoFlg.text) {
                        App.ui.loading.close();
                        // 1版以外検索時、1版が未使用の場合処理を抜ける
                        App.ui.page.notifyAlert.message(pageLangText.mishiyoError.text).show();
                        $("#list-loading-message").text("");
                        isDataLoading = false;
                        return;
                    }
                    else {
                        // 検索データの定義
                        var data = result.successes.haigoBody.d[0];
                    }
                    // 新規版の場合
                    if (hanNoNew == getHanNo()) {
                        // toFormで新規版をセット
                        data.no_han = hanNoNew;
                        data.flg_tanto_hinkan = pageLangText.systemValueZero.text;
                        data.cd_tanto_seizo = pageLangText.shokikaShokichi.text;
                        data.nm_tanto_hinkan = pageLangText.shokikaShokichi.text;
                        data.dt_hinkan_koshin = pageLangText.shokikaShokichi.text;
                        data.flg_tanto_seizo = pageLangText.systemValueZero.text;
                        data.cd_tanto_hinkan = pageLangText.shokikaShokichi.text;
                        data.nm_tanto_seizo = pageLangText.shokikaShokichi.text;
                        data.dt_seizo_koshin = pageLangText.shokikaShokichi.text;
                        // 新規フラグをセット
                        isCreated = true;
                    }
                    // 1版の場合
                    if (pageLangText.hanNoShokichi.text == getHanNo()) {
                        $("#id_dt_from").attr("disabled", true);
                    }
                    else {
                        $("#id_dt_from").attr("disabled", false);
                    }
                    // 有効開始日：DB値が1975年未満だった場合に表示がおかしくなる為、フォーマットしなおす
                    var dtFrom = App.data.getDate(data.dt_from);
                    data.dt_from = App.data.getDateString(dtFrom, true);

                    // データのバインド
                    body.toForm(data);

                    // 合計行の単位設定
                    grid.jqGrid('footerData', 'set', { nm_tani_shiyo: data.nm_tani_shiyo });
                    // 明細の検索
                    searchGrid(new query());
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
                    isDataLoading = false;
                });
            };

            /// <summary>クエリオブジェクトの設定</summary>
            var query = function () {
                var query = {
                    // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                    url: "../Services/FoodProcsService.svc/vw_ma_haigo_recipe_01",
                    // TODO: ここまで
                    filter: createFilter(),
                    // TODO: 画面の仕様に応じて以下のソート条件を変更してください。
                    orderby: "no_kotei,no_tonyu",
                    // TODO: ここまで
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
                if (!App.isUndefOrNull(criteria.cd_haigo) && criteria.cd_haigo.length > 0) {
                    filters.push("cd_haigo eq '" + criteria.cd_haigo + "'");
                }
                if (!App.isUndefOrNull(criteria.no_han) && criteria.no_han.length > 0) {
                    var hanNo;
                    if (hanNoNew == getHanNo() || (koteiNoNew == $("[name='no_kotei']").val() && getHanNo() !== 1)) {
                        hanNo = getSearchHanNo();
                    }
                    else {
                        hanNo = getHanNo();
                    }
                    filters.push("no_han eq " + hanNo);
                }
                if (!App.isUndefOrNull(criteria.no_kotei) && criteria.no_kotei.length > 0) {
                    filters.push("no_kotei eq " + criteria.no_kotei);
                }
                filters.push("no_han_shikakari eq " + pageLangText.hanNoShokichi.text);
                //TODO: ここまで

                return filters.join(" and ");
            };

            /// <summary>明細を検索します。</summary>
            var searchGrid = function (query) {
                // 検索条件をJSON形式に変換
                var criteria = $(".search-criteria").toJSON();
                // 明細の検索
                App.ajax.webget(
                // WCF Data ServicesのODataシステムクエリオプションを生成
                    App.data.toODataFormat(query)
                ).done(function (result) {
                    // レシピにデータがない場合
                    if (result.d.__count == "0") {
                        App.ui.loading.close();
                        // 検索条件を閉じる
                        closeCriteria();
                        isDataLoading = false;
                        $("#list-loading-message").text("");
                        // レシピ状態の設定
                        $("[data-form-item='con_recipe']").text(pageLangText.createRecipe.text);
                        return;
                    };
                    // レシピ状態の設定
                    $("[data-form-item='con_recipe']").text(pageLangText.changeRecipe.text);
                    // データバインド
                    bindData(result);
                    // 新規版の場合
                    if (hanNoNew == getHanNo()) {
                        // レシピ状態の設定
                        $("[data-form-item='con_recipe']").text(pageLangText.createRecipe.text);
                        for (var i = 0; i < result.d.results.length; i++) {
                            changeSetFirst.addCreated(i + 1, setCreatedChangeDataFirst(result.d.results[i]));
                        }
                    }
                    // 工程が空白の場合
                    if (App.isUndefOrNull(criteria.no_kotei) || criteria.no_kotei.length == 0) {
                        isKoteiBlank = true;
                    }
                    isCriteriaChange = false;
                    // 検索条件を閉じる
                    closeCriteria();
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                }).always(function () {
                    App.ui.loading.close();
                    setTimeout(function () {
                        $("#list-loading-message").text("");
                        isDataLoading = false;
                    }, 500);
                });
                // TODO: ここまで
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
                showSearchConfirmDialog();
            });

            // グリッドコントロール固有の検索処理

            /// <summary>検索前の状態に初期化します。</summary>
            var clearState = function () {
                // データクリア
                grid.clearGridData();
                //hanNoNew = 0,
                //koteiNoNew = 0,
                lastScrollTop = 0;
                querySetting.skip = 0;
                querySetting.count = 0;
                displayCount();

                // TODO: 画面の仕様に応じて以下のパラメータ設定を変更してください。
                currentRow = 0;
                currentCol = firstCol;
                // フラグの戻し
                isCreated = false;
                isChanged = false;
                isKoteiBlank = false;
                isSearch = false;
                isCriteriaChange = false;
                $("#id_dt_from").attr("disabled", false);
                // 変更セットの作成
                changeSetFirst = new App.ui.page.changeSet();
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
                // グリッドの表示件数を更新
                grid.setGridParam({ rowNum: querySetting.skip });
                displayCount();
                // データバインド
                var currentData = grid.getGridParam("data").concat(result.d.results);
                grid.setGridParam({ data: currentData }).trigger('reloadGrid', [{ current: true}]);
                // 重量計算
                setJuryo();
                App.ui.page.notifyInfo.message(
                     App.str.format(pageLangText.searchResultCount.text, querySetting.skip, querySetting.count)
                ).show();
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
                    searchItems();
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
            }
            /// <summary>エラー一覧クリック時の処理を行います。(for grid)</summary>
            /// <param name="data">エラー情報</param>
            var handleNotifyAlert = function (data) {
                // data.unique でキーが取得できる
                // data.handledにtrueを指定することでデフォルトの動作(キーがHTMLElementの場合にフォーカスを当てる処理)の実行をキャンセルする
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
            // クリアダイアログ情報メッセージの設定
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
            // 保存確認ダイアログ情報メッセージの設定
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
            // 保存完了ダイアログ情報メッセージの設定
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

            // 配合版削除ダイアログ情報メッセージの設定
            var deleteHanConfirmDialogNotifyInfo = App.ui.notify.info(deleteHanConfirmDialog, {
                container: ".deleteHan-confirm-dialog .dialog-slideup-area .info-message",
                messageContainerQuery: "ul",
                show: function () {
                    deleteHanConfirmDialog.find(".info-message").show();
                },
                clear: function () {
                    deleteHanConfirmDialog.find(".info-message").hide();
                }
            });
            // 配合全版削除ダイアログ情報メッセージの設定
            var deleteAllConfirmDialogNotifyInfo = App.ui.notify.info(deleteAllConfirmDialog, {
                container: ".deleteAll-confirm-dialog .dialog-slideup-area .info-message",
                messageContainerQuery: "ul",
                show: function () {
                    deleteAllConfirmDialog.find(".info-message").show();
                },
                clear: function () {
                    deleteAllConfirmDialog.find(".info-message").hide();
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

            // メニューボタン押下時情報メッセージの設定
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
            // クリアダイアログ警告メッセージの設定
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
            // 保存確認ダイアログ警告メッセージの設定
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
            // 保存完了ダイアログ警告メッセージの設定
            var saveCompleteDialogNotifyAlert = App.ui.notify.alert(saveCompleteDialog, {
                container: ".save-complete-dialog .dialog-slideup-area .alert-message",
                messageContainerQuery: "ul",
                show: function () {
                    saveCompleteDialog.find(".alert-message").show();
                },
                clear: function () {
                    saveCompleteDialog.find(".alert-message").show();
                }
            });
            // 配合版削除ダイアログ警告メッセージの設定
            var deleteHanConfirmDialogNotifyAlert = App.ui.notify.alert(deleteHanConfirmDialog, {
                container: ".deleteHan-confirm-dialog .dialog-slideup-area .alert-message",
                messageContainerQuery: "ul",
                show: function () {
                    deleteHanConfirmDialog.find(".alert-message").show();
                },
                clear: function () {
                    deleteHanConfirmDialog.find(".alert-message").hide();
                }
            });
            // 配合全版削除ダイアログ警告メッセージの設定
            var deleteAllConfirmDialogNotifyAlert = App.ui.notify.alert(deleteAllConfirmDialog, {
                container: ".deleteAll-confirm-dialog .dialog-slideup-area .alert-message",
                messageContainerQuery: "ul",
                show: function () {
                    deleteAllConfirmDialog.find(".alert-message").show();
                },
                clear: function () {
                    deleteAllConfirmDialog.find(".alert-message").hide();
                }
            });
            // 検索時ダイアログ警告メッセージの設定
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
            // メニューボタン押下時メッセージの設定
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

            /// <summary>データに変更があり、未保存の状態でページを離れる際に確認を行います。</summary>
            //別画面に遷移したりするときに実行する関数の定義
            var onBeforeUnload = function () {
                //データを変更したかどうかは各画面でチェックし、保持する
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
            //// メッセージ表示 -- End

            //// データ変更処理 -- Start

            // グリッドコントロール固有のデータ変更処理
            /// <summary>レコードが存在するかチェックします。 </summary>
            /// <param name="isAdd">行追加かどうか</param>
            var recordCheck = function (isAdd) {
                var recordCount = grid.getGridParam("records");
                // レコードがない場合は処理を抜ける
                if (recordCount == 0) {
                    if (!isAdd) {
                        App.ui.page.notifyInfo.message(pageLangText.noRecords.text).show();
                        return false;
                    }
                    return false;
                }
                return true;
            };

            /// <summary>グリッドの選択行の行IDを取得します。 </summary>
            /// <param name="isAdd">行追加かどうか</param>
            var getSelectedRowId = function (isAdd) {
                var selectedRowId = grid.getGridParam("selrow"),
                    ids = grid.getDataIDs();
                // レコード０件チェック
                if (!recordCheck(isAdd)) {
                    return;
                }
                // 選択行なしの場合は最終行を選択
                if (App.isUnusable(selectedRowId)) {
                    var recordCount = grid.getGridParam("records");
                    selectedRowId = ids[recordCount - 1];
                }
                currentRow = $('#' + selectedRowId)[0].rowIndex;

                return selectedRowId;
            };
            /// <summary>グリッドの選択行の１行違いのIDを取得します。 </summary>
            var getSelectedNeighborRowId = function (direction) {
                var selectedRowId = grid.getGridParam("selrow"),
                    ids = grid.getDataIDs(),
                    recordCount = grid.getGridParam("records");
                // レコードが０件チェック
                if (!recordCheck(false)) {
                    return;
                };
                for (var i = 0; i < recordCount; i++) {
                    if (ids[i] == selectedRowId) {
                        if (direction == 'up-button') {
                            return ids[i - 1];
                        }
                        else if (direction == 'down-button') {
                            return ids[i + 1];
                        }
                    }
                }
            };
            /// <summary>新規行データの設定を行います。</summary>
            var setAddDataFirst = function () {
                // TODO: 画面の仕様に応じて以下の項目を変更してください。
                var addDataFirst = {
                    "cd_haigo": haigoCode
                    , "no_han": getHanNo()
                    , "wt_haigo": $(".search-criteria [name='wt_kihon']").val()
                    , "no_kotei": $(".search-criteria [name='no_kotei']").val()
                    , "no_tonyu": ""
                    , "kbn_hin": pageLangText.genryoHinKbn.text
                    , "cd_hinmei": ""
                    , "nm_hinmei": ""
                    , "cd_mark": ""
                    , "wt_kihon": 0
                    , "wt_shikomi": 0
                    , "wt_nisugata": 0
                    , "su_nisugata": 0
                    , "wt_kowake": 0
                    , "su_kowake": 0
                    , "flg_kowake_systemgai": 0
                    , "cd_futai": 0
                    , "no_plc_komoku": null
                    , "ritsu_hiju": 0
                    , "ritsu_budomari": 0
                    , "flg_mishiyo": 0
                    , "dt_create": new Date()
                    , "cd_create": App.ui.page.user.Code
                    , "dt_update": new Date()
                    , "cd_update": App.ui.page.user.Code
                    , "su_settei": 0
                    , "su_settei_max": 0
                    , "su_settei_min": 0
                };
                // TODO: ここまで

                return addDataFirst;
            };
            /// <summary>コピー行データの設定を行います。</summary>
            /// <param name="row">選択行</param>
            var setCopyData = function (row) {
                // TODO: 画面の仕様に応じて以下の項目の初期値を変更してください。
                return $.extend({}, row, "");
                // TODO: ここまで
            };
            /// <summary>追加状態の変更セットに追加する変更データの設定を行います。</summary>
            /// <param name="newRow">新規行データ</param>
            var setCreatedChangeDataFirst = function (newRow) {
                // TODO: 画面の仕様に応じて以下の項目を変更してください。
                var changeDataFirst = {
                    "cd_haigo": haigoCode
                    , "no_han": getHanNo()
                    , "wt_haigo": $(".search-criteria [name='wt_kihon']").val()
                    , "no_kotei": $(".search-criteria [name='no_kotei']").val()
                    , "kbn_hin": newRow.kbn_hin
                    , "no_tonyu": newRow.no_tonyu
                    , "cd_hinmei": newRow.cd_hinmei
                    , "nm_hinmei": newRow.nm_hinmei
                    , "cd_mark": newRow.cd_mark
                    , "wt_kihon": 0
                    , "wt_shikomi": newRow.wt_shikomi
                    , "wt_nisugata": newRow.wt_nisugata
                    , "su_nisugata": newRow.su_nisugata
                    , "wt_kowake": newRow.wt_kowake
                    , "su_kowake": newRow.su_kowake
                    , "flg_kowake_systemgai": newRow.flg_kowake_systemgai
                    , "cd_futai": newRow.cd_futai
                    , "no_plc_komoku": newRow.no_plc_komoku
                    , "ritsu_hiju": newRow.ritsu_hiju
                    , "ritsu_budomari": newRow.ritsu_budomari
                    , "flg_mishiyo": 0
                    , "dt_create": new Date()
                    , "cd_create": App.ui.page.user.Code
                    , "dt_update": new Date()
                    , "cd_update": App.ui.page.user.Code
                    , "su_settei": newRow.su_settei
                    , "su_settei_max": newRow.su_settei_max
                    , "su_settei_min": newRow.su_settei_min
                    , "no_seq": newRow.no_seq
                };
                // TODO: ここまで

                return changeDataFirst;
            };

            /// <summary>更新状態の変更セットに追加する変更データの設定を行います。</summary>
            /// <param name="row">選択行</param>
            var setUpdatedChangeDataFirst = function (row) {
                // TODO: 画面の仕様に応じて以下の項目を変更してください。
                var changeDataFirst = {
                    "cd_haigo": haigoCode
                    , "no_han": getHanNo()
                    , "wt_haigo": $(".search-criteria [name='wt_kihon']").val()
                    , "no_kotei": $(".search-criteria [name='no_kotei']").val()
                    , "kbn_hin": row.kbn_hin
                    , "no_tonyu": row.no_tonyu
                    , "cd_hinmei": row.cd_hinmei
                    , "nm_hinmei": row.nm_hinmei
                    , "cd_mark": row.cd_mark
                    , "wt_kihon": 0
                    , "wt_shikomi": row.wt_shikomi
                    , "wt_nisugata": row.wt_nisugata
                    , "su_nisugata": row.su_nisugata
                    , "wt_kowake": row.wt_kowake
                    , "su_kowake": row.su_kowake
                    , "flg_kowake_systemgai": row.flg_kowake_systemgai
                    , "cd_futai": row.cd_futai
                    , "no_plc_komoku": row.no_plc_komoku
                    , "ritsu_hiju": row.ritsu_hiju
                    , "ritsu_budomari": row.ritsu_budomari
                    , "flg_mishiyo": 0
                    , "dt_create": App.date.localDate(row.dt_create)
                    , "cd_create": row.cd_create
                    , "dt_update": new Date()
                    , "cd_update": App.ui.page.user.Code
                    , "su_settei": row.su_settei
                    , "su_settei_max": row.su_settei_max
                    , "su_settei_min": row.su_settei_min
                    , "no_seq": row.no_seq
                    , "ts": row.ts
                };
                // TODO: ここまで

                return changeDataFirst;
            };

            /// <summary>削除状態の変更セットに追加する変更データの設定を行います。</summary>
            /// <param name="row">選択行</param>
            var setDeletedChangeDataFirst = function (row) {
                // TODO: 画面の仕様に応じて以下の項目を変更してください。
                var changeDataFirst = {
                    "cd_haigo": haigoCode
                    , "no_han": getHanNo()
                    , "wt_haigo": $(".search-criteria [name='wt_kihon']").val()
                    , "no_kotei": $(".search-criteria [name='no_kotei']").val()
                    , "kbn_hin": row.kbn_hin
                    , "no_tonyu": row.no_tonyu
                    , "cd_hinmei": row.cd_hinmei
                    , "nm_hinmei": row.nm_hinmei
                    , "cd_mark": row.cd_mark
                    , "wt_kihon": 0
                    , "wt_shikomi": row.wt_shikomi
                    , "wt_nisugata": row.wt_nisugata
                    , "su_nisugata": row.su_nisugata
                    , "wt_kowake": row.wt_kowake
                    , "su_kowake": row.su_kowake
                    , "flg_kowake_systemgai": row.flg_kowake_systemgai
                    , "cd_futai": row.cd_futai
                    , "no_plc_komoku": row.no_plc_komoku
                    , "ritsu_hiju": row.ritsu_hiju
                    , "ritsu_budomari": row.ritsu_budomari
                    , "flg_mishiyo": 0
                    , "dt_create": App.date.localDate(row.dt_create)
                    , "cd_create": row.cd_create
                    , "dt_update": new Date()
                    , "cd_update": App.ui.page.user.Code
                    , "su_settei": row.su_settei
                    , "su_settei_max": row.su_settei_max
                    , "su_settei_min": row.su_settei_min
                    , "no_seq": row.no_seq
                    , "ts": row.ts
                };
                // TODO: ここまで

                return changeDataFirst;
            };
            /// <summary>関連項目の設定を変更セットに反映します。</summary>
            /// <param name="selectedRowId">選択行ID</param>
            /// <param name="cellName">列名</param>
            /// <param name="value">元となる項目の値</param>
            //var setRelatedChangeDataFirst = function (selectedRowId, cellName, value, changeDataFirst) {
            // TODO: 画面の仕様に応じて以下の処理を変更してください。
            //                if (cellName === "cd_hinmei") {
            //                    changeSetFirst.addUpdated(selectedRowId, "nm_hinmei", grid.getCell(selectedRowId, hinmeiName), changeDataFirst);
            //                }
            // TODO: ここまで
            //};

            /// <summary>新規行を追加します。</summary>
            /// <param name="e">イベントデータ</param>
            var addDataFirst = function (e) {
                // 選択行のID取得
                var selectedRowId = getSelectedRowId(true),
                    position = "after",
                    editCol = 1;
                // 新規行データの設定
                var newRowId = App.uuid(),
                    addDataFirst = setAddDataFirst();
                if (App.isUndefOrNull(selectedRowId)) {
                    // 末尾にデータ追加
                    grid.addRowData(newRowId, addDataFirst);
                    currentRow = 0;
                }
                else {
                    // セル編集内容の保存
                    saveEdit();
                    // 選択行の任意の位置にデータ追加
                    grid.addRowData(newRowId, addDataFirst, position, selectedRowId);
                }
                //運転登録項目制御
                ctrlPlc(newRowId, true);
                // 行番号を投入順とする。
                addDataFirst.no_tonyu = currentRow + 1;
                // 追加状態の変更セットに変更データを追加
                changeSetFirst.addCreated(newRowId, setCreatedChangeDataFirst(addDataFirst));
                // 現在行を保持
                var editRow = parseInt(currentRow);
                // 下の行の投入順を１ずつ上げる
                for (var i = (currentRow + 1); i - 1 < grid.getGridParam("records"); i++) {
                    // セルを選択して入力モードにする
                    //grid.editCell(i, currentCol, true);
                    //grid.editCell(i, hinNameCol, true);
                    grid.editCell(i, editCol, true);
                    // 選択行の行ID取得
                    var forRowId = getSelectedRowId(true);
                    // 投入順をセットする
                    grid.setCell(forRowId, tonyuCol, i);
                    // 関連処理の実行
                    fncAfterSaveCell(forRowId, "no_tonyu", i, i, tonyuCol);
                }
                // セルを選択して入力モードにする
                //grid.editCell(editRow + 1, hinNameCol, true);
                grid.editCell(editRow + 1, editCol, true);
            };
            /// <summary>追加ボタンクリック時のイベント処理を行います。</summary>
            $(".add-button").on("click", function (e) {
                // 他イベント中は処理しない
                if (isDataLoading) {
                    return;
                }

                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();

                // 検索実行チェック
                if (!isSearch) {
                    showBeforeSearch();
                    return;
                }
                // 検索条件変更チェック
                if (isCriteriaChange) {
                    showCriteriaChange("lineAdd");
                    return;
                }
                // 工程空白チェック
                if (isKoteiBlank) {
                    // 情報メッセージ出力
                    showKoteiBlank();
                    return;
                }
                // 最大行数チェック：9999以上は追加できない(投入番号がdecimal(4,0)の為)
                var records = grid.getGridParam("records");
                if (records > 9999) {
                    App.ui.page.notifyAlert.message(MS0052).show();
                    return;
                }

                // 行追加
                addDataFirst(e);
            });

            /// <summary>コピー行を追加します。</summary>
            /// <param name="direction">↑(up)↓(down)</param>
            var copyDataFirst = function (direction, neighborRowId) {
                // 選択行のID取得
                var selectedRowId = getSelectedRowId();
                if (App.isUndefOrNull(selectedRowId)) {
                    return;
                }
                // 行バリデーションエラーがある場合
                if (!validateRow(selectedRowId)) {
                    return;
                }
                // コピーデータを追加する方向を決定
                var position,
                    tonyuNo;
                if (direction == "up") {
                    position = "before";
                    tonyuNo = currentRow - 1;
                }
                else if (direction == "down") {
                    position = "after";
                    tonyuNo = currentRow + 1;
                }
                // 移動される行の投入順を取得
                neighborTonyuNo = currentRow;
                // コピー行データの設定
                var copyDataFirst = setCopyData(grid.getRowData(selectedRowId));
                // 選択行のデータを削除
                grid.delRowData(selectedRowId);
                // 選択行の任意の位置にデータ追加
                //                grid.addRowData(newRowId, copyDataFirst, position, selectedRowId);
                grid.addRowData(selectedRowId, copyDataFirst, position, neighborRowId);
                // 投入順をセットする
                grid.setCell(selectedRowId, tonyuCol, tonyuNo)
                // 関連処理の実行
                fncAfterSaveCell(selectedRowId, "no_tonyu", tonyuNo, tonyuNo, tonyuCol);
                // 投入順をセットする
                grid.setCell(neighborRowId, tonyuCol, neighborTonyuNo);
                // 関連処理の実行
                fncAfterSaveCell(neighborRowId, "no_tonyu", neighborTonyuNo, neighborTonyuNo, tonyuCol);
            };

            /// <summary>行を削除します。</summary>
            /// <param name="e">イベントデータ</param>
            var deleteDataFirst = function (e) {
                // 選択行のID取得
                var selectedRowId = getSelectedRowId();
                if (App.isUndefOrNull(selectedRowId)) {
                    return;
                }
                // セル編集内容の保存
                saveEdit();
                // カレント行のエラーメッセージを削除
                removeAlertRow(selectedRowId);
                // 削除状態の変更データの設定
                var changeDataFirst = setDeletedChangeDataFirst(grid.getRowData(selectedRowId));
                // 削除状態の変更セットに変更データを追加
                changeSetFirst.addDeleted(selectedRowId, changeDataFirst);
                // 選択行の行データ削除
                grid.delRowData(selectedRowId);
                // 現在行を保持
                var editRow = parseInt(currentRow),
                    tmpTonyuCol = grid.getColumnIndexByName("no_tonyu");
                // 下の行の投入順を１ずつ下げる
                for (var i = currentRow; i - 1 < grid.getGridParam("records"); i++) {
                    // セルを選択して入力モードにする
                    //grid.editCell(i, currentCol, true);
                    //grid.editCell(i, hinNameCol, true);
                    grid.editCell(i, tmpTonyuCol, true);
                    // 選択行の行ID取得
                    var rowId = getSelectedRowId(true);
                    // 行を回復させる
                    grid.restoreRow(rowId);
                    // 投入順をセットする
                    grid.setCell(rowId, tonyuCol, i)
                    // 関連処理の実行
                    fncAfterSaveCell(rowId, "no_tonyu", i, i, tonyuCol);
                }
                // チェック者名のクリア
                hinkanTantoClear();
                seizoTantoClear();
                //合計再計算処理
                setJuryo();
                if (grid.getGridParam("records") > 0) {
                    // セルを選択して入力モードにする
                    //grid.editCell(editRow === 1 ? editRow : editRow - 1, currentCol, true);
                    //grid.editCell(editRow === 1 ? editRow : editRow - 1, hinNameCol, true);
                    grid.editCell(editRow === 1 ? editRow : editRow - 1, tmpTonyuCol, true);
                }
                // 変更フラグをセット
                isChanged = true;
            };
            /// <summary>削除ボタンクリック時のイベント処理を行います。</summary>
            $(".delete-button").on("click", function (e) {
                // 検索条件変更チェック
                if (isCriteriaChange) {
                    showCriteriaChange("lineDel");
                    return;
                }
                // 工程空白チェック
                if (isKoteiBlank) {
                    // 情報メッセージ出力
                    showKoteiBlank();
                    return;
                }
                // 行削除
                deleteDataFirst(e);
            });

            /// <summary>選択行を１行上に移動します。</summary>
            var moveRow = function (direction) {
                flg_move = true;

                var editRow = currentRow,
                    selectedNeighborRowId;

                // ↑↓を判断
                //var direction = e.currentTarget.className,

                // 選択行のID取得
                selectedRowId = getSelectedRowId(true);

                // セル編集内容の保存
                //saveEdit();

                if (direction == "up") {
                    // 選択行の位置を保持
                    editRow = currentRow - 1;
                    // 一行上の行のrowIdを取得
                    selectedNeighborRowId = getSelectedNeighborRowId("up-button");
                }
                else if (direction == "down") {
                    // 選択行の位置を保持
                    editRow = currentRow + 1;
                    // 一行下の行のrowIdを取得
                    selectedNeighborRowId = getSelectedNeighborRowId("down-button");
                }
                // 端の行で上下出来ない場合は処理を抜ける
                if (App.isUndefOrNull(selectedNeighborRowId)) {
                    flg_move = false;
                    return;
                }
                else {
                    // コピー行を追加する
                    if (direction == "up") {
                        copyDataFirst("up", selectedNeighborRowId);
                    }
                    else if (direction == "down") {
                        copyDataFirst("down", selectedNeighborRowId);
                    }
                    // セルを選択して入力モードにする
                    grid.editCell(editRow, hinNameCol, true);
                }
                flg_move = false;
            };
            /// <summary>↑ボタンクリック時のイベント処理を行います。</summary>
            $(".up-button").on("click", function (e) {
                // 検索条件変更チェック
                if (isCriteriaChange) {
                    showCriteriaChange("rowChange");
                    return;
                }
                // 工程空白チェック
                if (isKoteiBlank) {
                    // 情報メッセージ出力
                    showKoteiBlank();
                    return;
                }
                moveRow("up");
            });

            /// <summary>↓ボタンクリック時のイベント処理を行います。</summary>
            $(".down-button").on("click", function (e) {
                // 検索条件変更チェック
                if (isCriteriaChange) {
                    showCriteriaChange("rowChange");
                    return;
                }
                // 工程空白チェック
                if (isKoteiBlank) {
                    // 情報メッセージ出力
                    showKoteiBlank();
                    return;
                }
                moveRow("down");
            });

            //// データ変更処理 -- End

            //// 保存処理 -- Start

            // グリッドコントロール固有の保存処理

            /// <summary>担当者名取得処理</summary>
            /// <param name="tantoCode">担当者コード</param>
            /// <param name="element">要素</param>
            var setTantoName = function (tantoCode, element) {
                App.deferred.parallel({
                    // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                    tantoInfo: App.ajax.webget("../Services/FoodProcsService.svc/ma_tanto()?$filter=cd_tanto eq '" + tantoCode + "'")
                    // TODO: ここまで
                }).done(function (result) {
                    var tantoName = result.successes.tantoInfo.d[0].nm_tanto;
                    $("[name='" + element + "']").text(tantoName);
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

            /// <summary>編集内容の保存</summary>
            var saveEdit = function () {
                grid.saveCell(currentRow, currentCol);
            };
            /// <summary>更新データを取得します。</summary>
            var getPostData = function () {
                ChangeSets = {};
                ChangeSets.First = changeSetFirst.getChangeSetData();
                ChangeSets.Second = changeSetSecond.getChangeSetData();
                return JSON.stringify(ChangeSets);
            };

            /// <summary>データ変更エラーハンドリングを行います。</summary>
            /// <param name="result">エラーの戻り値</param>
            var handleSaveDataError = function (result) {
                var ret = JSON.parse(result.rawText);
                // データが存在しない場合は処理を抜ける
                if (App.isUndefOrNull(ret.First) && App.isUndefOrNull(ret.Second)) {
                    App.ui.page.notifyAlert.message(result.message).show();
                    return;
                }
                var ids = grid.getDataIDs(),
                    newId,
                    value,
                    unique,
                    current,
                // TODO: 画面の仕様に応じて以下の変数を変更します。
                    checkCol = 27;  // no_seq
                // TODO: ここまで
                // データ整合性エラーのハンドリングを行います。
                if (App.isArray(ret.First) && ret.First.length > 0) {
                    for (var i = 0; i < ret.First.length; i++) {
                        // TODO: 画面の仕様に応じて以下の値を変更します。
                        if (ret.First[i].InvalidationName === "Exists" || ret.First[i].InvalidationName === "NotExsists") {
                            // TODO: ここまで
                            for (var j = 0; j < ids.length; j++) {
                                // TODO: 画面の仕様に応じて以下の値を変更します。
                                value = parseInt(grid.getCell(ids[j], checkCol), 10);
                                retValue = ret.First[i].Data.no_seq;
                                // TODO: ここまで

                                if (isNaN(value) || value === retValue) {
                                    // TODO: 画面の仕様に応じて以下のロジックを変更します。
                                    unique = ids[j] + "_" + firstCol;
                                    if (ret.First[i].InvalidationName === "Exists") {
                                        // TODO：画面の仕様に応じて更新後のデータ状態をセットします
                                        // メッセージの表示(配合レシピマスタに既に存在している場合)
                                        App.ui.page.notifyAlert.message(
                                            App.str.format(pageLangText.existsError.text, pageLangText.haigoName.text, pageLangText.haigoRecipe.text)
                                        ).show();
                                        // メッセージの表示(配合レシピマスタに存在していない場合)
                                    }
                                    else if (ret.First[i].InvalidationName === "NotExsists") {
                                        App.ui.page.notifyAlert.message(
                                            App.str.format(pageLangText.hanNotExists.text, pageLangText.haigoRecipe.text)
                                        ).show();
                                        // TODO：ここまで
                                    }
                                    // 対象セルの背景変更
                                    grid.setCell(ids[j], hinCodeCol, ret.First[i].Data.cd_hinmei, { background: '#ff6666' });
                                    // TODO: ここまで
                                }
                            }
                        }
                        else {
                            // 更新オブジェクトから削除を行う
                            for (p in changeSetFirst.changeSet.deleted) {
                                if (!changeSetFirst.changeSet.deleted.hasOwnProperty(p)) {
                                    continue;
                                }

                                // TODO: 画面の仕様に応じて以下の値を変更します。
                                value = parseInt(changeSetFirst.changeSet.deleted[p].no_seq, 10)
                                retValue = ret.First[i].Data.no_seq;
                                // TODO: ここまで

                                if (isNaN(value) || value === retValue) {
                                    // 削除状態の変更セットから変更データを削除
                                    changeSetFirst.removeDeleted(p);

                                    // エラーメッセージの表示
                                    App.ui.page.notifyAlert.message(
                                            pageLangText.unDeletableRecord.text + ret.First[i].Message).show();
                                }
                            }
                        }
                    }
                }
                // データ整合性エラーのハンドリングを行います。
                if (App.isArray(ret.Second) && ret.Second.length > 0) {
                    if (ret.Second[0].InvalidationName === "Exists") {
                        // TODO：画面の仕様に応じて更新後のデータ状態をセットします
                        // メッセージの表示(配合名マスタに既に存在している場合)
                        App.ui.page.notifyAlert.message(
                            App.str.format(pageLangText.existsError.text, pageLangText.haigoName.text, pageLangText.nm_haigo.text)
                        ).show();
                        // メッセージの表示(配合名マスタに存在していない場合)
                    }
                    else if (ret.Second[0].InvalidationName === "NotExsists") {
                        App.ui.page.notifyAlert.message(
                            App.str.format(pageLangText.hanNotExists.text, pageLangText.ma_haigo_mei.text)
                        ).show();
                        // TODO：ここまで
                    }
                    else if (ret.Second[0].InvalidationName === "UnDeletableRecord") {
                        App.ui.page.notifyAlert.message(
                            pageLangText.unDeletableRecord.text + ret.Second[0].Message).show();
                    }
                    else {
                        App.ui.page.notifyAlert.message(
                            pageLangText.invalidation.text + ret.Second[0].Message
                        ).show();
                    }
                }
                // 更新時同時実行制御エラーのハンドリングを行います。
                if (!App.isUndefOrNull(ret.First.Updated) && ret.First.Updated.length > 0) {
                    for (var i = 0; i < ret.First.Updated.length; i++) {
                        for (p in changeSetFirst.changeSet.updated) {
                            if (!changeSetFirst.changeSet.updated.hasOwnProperty(p)) {
                                continue;
                            }

                            // TODO: 画面の仕様に応じて以下の値を変更します。
                            value = parseInt(grid.getCell(p, checkCol), 10);
                            retValue = ret.First.Updated[i].Requested.no_seq;
                            // TODO: ここまで

                            if (isNaN(value) || value === retValue) {
                                // 更新状態の変更セットから変更データを削除
                                changeSetFirst.removeUpdated(p);

                                // 他のユーザーによって削除されていた場合
                                if (App.isUndefOrNull(ret.First.Updated[i].Current)) {
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
                                    $.extend(current, ret.First.Updated[i].Current);
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
                // 更新時同時実行制御エラーのハンドリングを行います。
                if (!App.isUndefOrNull(ret.Second.Updated) && ret.Second.Updated.length > 0) {
                    // 他のユーザーによって削除されていた場合
                    var upCurrent = ret.Second.Updated[0].Current;
                    if (App.isUndefOrNull(upCurrent)) {

                        // メッセージの表示
                        App.ui.page.notifyAlert.message(
                            App.str.format(pageLangText.duplicate.text + pageLangText.hanNotExists.text, pageLangText.cd_haigo.text)
                        ).show();
                    }
                    else {
                        // 更新後のデータ状態をセット
                        var body = $(".part-body");
                        var data = {
                            "nm_haigo_ja": upCurrent.nm_haigo_ja,
                            "nm_haigo_en": upCurrent.nm_haigo_en,
                            "nm_haigo_zh": upCurrent.nm_haigo_zh,
                            "nm_haigo_vi": upCurrent.nm_haigo_vi,
                            "nm_haigo_ryaku": upCurrent.nm_haigo_ryaku,
                            "ritsu_budomari": upCurrent.ritsu_budomari,
                            "wt_kihon": upCurrent.wt_kihon,
                            "ritsu_kihon": upCurrent.ritsu_kihon,
                            "flg_gassan_shikomi": upCurrent.flg_gassan_shikomi,
                            "wt_saidai_shikomi": upCurrent.wt_saidai_shikomi,
                            "wt_haigo": upCurrent.wt_haigo,
                            "wt_haigo_gokei": upCurrent.wt_haigo_gokei,
                            "biko": upCurrent.biko,
                            "no_seiho": upCurrent.no_seiho,
                            "cd_tanto_seizo": upCurrent.cd_tanto_seizo,
                            "dt_seizo_koshin": upCurrent.dt_seizo_koshin,
                            "cd_tanto_hinkan": upCurrent.cd_tanto_hinkan,
                            "dt_hinkan_koshin": upCurrent.dt_hinkan_koshin,
                            "dt_from": upCurrent.dt_from,
                            "kbn_kanzan": upCurrent.kbn_kanzan,
                            "ritsu_hiju": upCurrent.ritsu_hiju,
                            "flg_shorihin": upCurrent.flg_shorihin,
                            "flg_tanto_hinkan": upCurrent.flg_tanto_hinkan,
                            "flg_tanto_seizo": upCurrent.flg_tanto_seizo,
                            "kbn_shiagari": upCurrent.kbn_shiagari,
                            "cd_bunrui": upCurrent.cd_bunrui,
                            "flg_mishiyo": upCurrent.flg_mishiyo,
                            "dt_create": upCurrent.dt_create,
                            "cd_create": upCurrent.cd_create,
                            "dt_update": upCurrent.dt_update,
                            "cd_update": upCurrent.cd_update,
                            "wt_kowake": upCurrent.wt_kowake,
                            "su_kowake": upCurrent.su_kowake,
                            "ts": upCurrent.ts,
                            "flg_tenkai": upCurrent.flg_tenkai,
                            "dd_shomi": upCurrent.dd_shomi,
                            "kbn_hokan": upCurrent.kbn_hokan

                        };

                        // カレントのデータを画面へ表示
                        body.toForm(data);

                        // 品管・製造担当者名をセット
                        setTantoName(ret.Second.Updated[0].Current.cd_tanto_hinkan, "nm_tanto_hinkan");
                        setTantoName(ret.Second.Updated[0].Current.cd_tanto_seizo, "nm_tanto_seizo");

                        // エラーメッセージの表示
                        App.ui.page.notifyAlert.message(
                                        pageLangText.duplicate.text + pageLangText.updatedDuplicate.text).show();
                    }
                }
                // 削除時同時実行制御エラーのハンドリングを行います。
                if (!App.isUndefOrNull(ret.First.Deleted) && ret.First.Deleted.length > 0) {
                    for (var i = 0; i < ret.First.Deleted.length; i++) {
                        for (p in changeSetFirst.changeSet.deleted) {
                            if (!changeSetFirst.changeSet.deleted.hasOwnProperty(p)) {
                                continue;
                            }

                            // TODO: 画面の仕様に応じて以下の値を変更します。
                            value = parseInt(changeSetFirst.changeSet.deleted[p].no_seq, 10)
                            retValue = ret.First.Deleted[i].Requested.no_seq;
                            // TODO: ここまで

                            if (isNaN(value) || value === retValue) {
                                // 削除状態の変更セットから変更データを削除
                                changeSetFirst.removeDeleted(p);

                                // 他のユーザーによって削除されていた場合
                                if (App.isUndefOrNull(ret.First.Deleted[i].Current)) {
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
                // 削除時同時実行制御エラーのハンドリングを行います。
                if (!App.isUndefOrNull(ret.Second.Deleted) && ret.Second.Deleted.length > 0) {
                    // 他のユーザーによって削除されていた場合
                    var delCurrent = ret.Second.Deleted[0].Current;
                    if (App.isUndefOrNull(delCurrent)) {

                        // メッセージの表示
                        App.ui.page.notifyAlert.message(
                            App.str.format(pageLangText.duplicate.text + pageLangText.hanNotExists.text, pageLangText.cd_haigo.text)
                        ).show();
                    }
                    else {
                        // 更新後のデータ状態をセット
                        var bodyDel = $(".part-body");
                        var dataDel = {
                            "no_seiho": delCurrent.no_seiho,
                            "dt_from": delCurrent.dt_from,
                            "flg_mishiyo": delCurrent.flg_mishiyo,
                            "biko": delCurrent.biko,
                            "kbn_shiagari": delCurrent.kbn_shiagari,
                            "wt_kowake": delCurrent.wt_kowake,
                            "flg_tanto_hinkan": delCurrent.flg_tanto_hinkan,
                            "cd_tanto_hinkan": delCurrent.cd_tanto_hinkan,
                            "dt_hinkan_koshin": delCurrent.dt_hinkan_koshin,
                            "wt_haigo_gokei": delCurrent.wt_haigo_gokei,
                            "su_kowake": delCurrent.su_kowake,
                            "flg_tanto_seizo": delCurrent.flg_tanto_seizo,
                            "cd_tanto_seizo": delCurrent.cd_tanto_seizo,
                            "dt_seizo_koshin": delCurrent.dt_seizo_koshin
                        };

                        // カレントのデータを画面へ表示
                        bodyDel.toForm(dataDel);

                        // 品管・製造担当者名をセット
                        setTantoName(delCurrent.cd_tanto_hinkan, "nm_tanto_hinkan");
                        setTantoName(delCurrent.cd_tanto_seizo, "nm_tanto_seizo");

                        // エラーメッセージの表示
                        App.ui.page.notifyAlert.message(
                                        pageLangText.duplicate.text + pageLangText.updatedDuplicate.text).show();
                    }
                }
            };

            /// <summary>保存完了処理</summary>
            var saveComplete = function () {
                // 保存完了ダイアログを閉じる
                closeSaveCompleteDialog();
                // データ変更フラグの初期化
                isChanged = false
                // 配合マスタ一覧画面に遷移
                navigate("HaigoMasterIchiran");
            };

            /// <summary>重ねマークコードの場合はtrueを返します。</summary>
            /// <param name="mCode">マークコード</param>
            var isKasaneMark = function (mCode) {
                switch (mCode) {
                    case pageLangText.kasane1MarkCode.text:
                    case pageLangText.kasane2MarkCode.text:
                    case pageLangText.kasane3MarkCode.text:
                    case pageLangText.kasane4MarkCode.text:
                    case pageLangText.kasane5MarkCode.text:
                    case pageLangText.kasane6MarkCode.text:
                    case pageLangText.kasane7MarkCode.text:
                    case pageLangText.kasane8MarkCode.text:
                    case pageLangText.kasane9MarkCode.text:
                        return true;
                    default:
                        return false;
                };
            }

            /// <summary>同一の重ねマークチェックを行います。</summary>
            //var checkKasaneSystemgaiKowake = function () {
            var checkKasane = function (doCheckChain) {
                var ids = grid.jqGrid('getDataIDs'),
                    i = 0,
                    len = ids.length,
                    dataObj = {};

                // 編集内容の保存
                saveEdit();

                // チェック用配列の作成
                for (; i < len; i++) {
                    var id = ids[i];
                    var markCode = grid.getCell(id, "cd_mark");

                    // 重ねマーク以外はスキップ
                    if (!isKasaneMark(markCode)) { continue; }

                    var ary = dataObj[markCode];
                    if (typeof ary !== "object") {
                        ary = new Array();
                        ary.push(new Array());
                        ary.push(new Array());
                    }
                    ary[0].push(grid.getCell(id, "flg_kowake_systemgai"));
                    ary[1].push(grid.getCell(id, "no_tonyu"));
                    dataObj[markCode] = ary;
                }

                // 本チェック処理
                for (var p in dataObj) {

                    // プロパティでない場合はスキップ、配列がない場合はスキップ
                    if (!dataObj.hasOwnProperty(p)) { continue; }
                    if (App.isUndef(dataObj[p][0])) { continue; }
                    if (App.isUndef(dataObj[p][1])) { continue; }

                    // 配列と一番目のフラグを取得
                    var ary = dataObj[p];
                    var flg = ary[0][0];
                    var num = ary[1][0];

                    // 同じ重ねマークのレシピは8個まで
                    if (ary[0].length > 8) {
                        App.ui.page.notifyAlert.message(MS0265).show();
                        return false;
                    }

                    for (var q = 1, qLen = ary[0].length; q < qLen; q++) {

                        // フラグの論理値が違う場合はエラーを表示する
                        if (flg != ary[0][q]) {
                            App.ui.page.notifyAlert.message(MS0767).show();
                            return false;
                        }

                        // 同じ重ねマークで投入番号が連なっていない場合はエラーを表示する
                        if (doCheckChain && !App.isUndef(ary[1][q]) && ++num != +ary[1][q]) {
                            App.ui.page.notifyAlert.message(MS0782).show();
                            return false;
                        }
                    }
                }
                return true;
            };

            /// <summary>選択した版より大きくて使用されている最小の版の有効開始日付を取得します。</summary>
            /// <summary>そのあと仕掛品計画サマリに実績存在チェックを行います。</summary>
            var getFromDate = function () {
                var haigoCode = $(".search-criteria").toJSON().cd_haigo;
                var noHan = getHanNo();
                var whereQuery = "cd_haigo eq '{0}' and no_han gt {1}";
                var query = {
                    url: "../Services/FoodProcsService.svc/ma_haigo_mei",
                    filter: App.str.format(whereQuery, haigoCode, noHan),
                    orderby: "no_han",
                    inlinecount: "allpages"
                }

                // 有効開始日付を取得する処理
                App.ajax.webgetSync(
                    App.data.toODataFormat(query)
                ).done(function (result) {
                    var fromDate = "";
                    if (result.d.__count !== "0") {
                        var records = result.d.results;
                        var i, len, record = "";
                        for (i = 0, len = records.length; i < len; i++) {
                            record = records[i];
                            if (record.flg_mishiyo + "" === pageLangText.shiyoMishiyoFlg.text) {
                                // 未使用フラグ．使用の場合は有効開始日付を保持
                                var getDateString = App.data.getDateString;
                                var getDate = App.data.getDate;
                                fromDate = getDateString(getDate(record.dt_from), false);
                                break;
                            }
                        }
                    }

                    // 実績の検索を行います。
                    checkJissekiExist(checkJissekiQuery(fromDate));

                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                });
            };

            /// <summary>仕掛の実績検索用クエリを作成</summary>
            /// <param name="date2">選択している版+１の有効開始日付(String)</param>
            var checkJissekiQuery = function (date2) {
                var haigoCode = $(".search-criteria").toJSON().cd_haigo;
                //                var date1 = new Date($(".part-body #id_dt_from").val());
                var date1 = $(".part-body #id_dt_from").val();
                var today = App.date.startOfDay(new Date());
                var filters = [];

                // 有効開始日付が当日より過去日付の場合は当日を条件にします。
                if (date1 < today) {
                    date1 = today;
                }

                // 10:00に設定
                //                var getDateTimeStrNoUtc = App.data.getDateTimeStringForQueryNoUtc;
                //                date1 = getDateTimeStrNoUtc(date1);
                date1 = App.data.getDateTimeStringForQueryNoUtc(App.date.localDate(date1));

                // 検索条件を設定
                filters.push(App.str.format("cd_shikakari_hin eq '{0}'", haigoCode));
                filters.push(App.str.format("dt_seizo ge datetime'{0}'", date1));

                if (date2 != "") {
                    // 選択している版+１がある場合
                    //                    date2 = getDateTimeStrNoUtc(new Date(date2));
                    date2 = App.data.getDateTimeStringForQueryNoUtc(App.date.localDate(date2));
                    filters.push(App.str.format("dt_seizo lt datetime'{0}'", date2));
                }

                var query = {
                    url: "../Services/FoodProcsService.svc/su_keikaku_shikakari",
                    filter: filters.join(" and "),
                    orderby: "dt_seizo",
                    inlinecount: "allpages"
                }
                return query;
            };

            /// <summary>仕掛の実績検索</summary>
            var checkJissekiExist = function (jissekiQuery) {
                // 0:計画有実績無、1:計画無または実績有、2:エラー
                var isExists = "1";

                App.ajax.webgetSync(
                    App.data.toODataFormat(jissekiQuery)
                ).done(function (result) {
                    // 計画が一件でもあれば全てチェックを行う

                    if (result.d.__count !== "0") {
                        //                        isExists = "0";
                        var records = result.d.results;
                        var i, len;

                        for (i = 0, len = records.length; i < len; i++) {
                            var data = records[i];

                            //予定が1つでもあればその時点で確認ダイアログを表示
                            if (data.flg_jisseki + "" === pageLangText.falseFlg.text) {
                                isExists = "0";
                                break;
                            }

                            //                            // 実績があればその時点で処理を終了
                            //                            // 通常の保存確認ダイアログを表示する。
                            //                            if (data.flg_jisseki + "" === pageLangText.trueFlg.text) {
                            //                                isExists = "1";
                            //                                break;
                            //                            }
                        }
                    }
                }).fail(function (result) {
                    isExists = "2";
                    App.ui.page.notifyAlert.message(result.message).show();
                }).always(function () {
                    switch (isExists) {
                        case "0": // 計画があるが実績がない
                            showReplanConfirmDialog();
                            break;
                        case "1": // 計画がないまたは実績がある
                            showSaveConfirmDialog();
                            break;
                        default:
                            break;
                    };
                });
            };

            /// <summary>クエリオブジェクトの設定</summary>
            /// <param name="画面の配合合計重量"</param>
            var searchQuery = function (haigoGokei) {
                var container = $(".part-body").toJSON();
                var query = {
                    url: "../api/CalcHaigoGokeiJuryo"
		            , cd_haigo: container.cd_haigo
		            , no_han: container.no_han
                    , no_kotei: container.no_kotei
		            , kbn_kanzan: container.kbn_kanzan
                    , wt_haigo_gokei: getThousandsSeparatorDel(haigoGokei)
                }
                return query;
            };

            /// <summary>配合合計重量の差分を取得します。</summary>
            var searchHaigoGokei = function (searchQuery, isDeleted) {
                App.ajax.webget(
                    App.data.toWebAPIFormat(searchQuery)
                ).done(function (result) {
                    var result_haigo_gokei = getThousandsSeparator(result[0].wt_haigo_gokei, 6);
                    $("[name='wt_haigo_gokei']").val(result_haigo_gokei);

                    if (isDeleted) {
                        saveData(isDeleted);
                    }
                    else {
                        //showSaveConfirmDialog();
                        getFromDate(); // 有効開始日付を取得して仕掛品計画の実績存在チェックをします。
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

            /// <summary>変更を保存します。</summary>
            /// <param name="isDeleted">削除フラグ</param>
            var saveCheck = function (isDeleted) {
                // 保存確認ダイアログを閉じる
                closeSaveConfirmDialog();
                // 配合版削除確認ダイアログを閉じる
                closeDeleteHanConfirmDialog();
                // 配合全版削除確認ダイアログを閉じる
                closeDeleteAllConfirmDialog();
                // 情報メッセージのクリア
                App.ui.page.notifyInfo.clear();
                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();
                // 編集内容の保存
                saveEdit();

                // 変更セット内にバリデーションエラーがある場合は処理を抜ける
                if (!validateChangeSet()) {
                    return;
                }
                //var partBody = $(".part-body")
                var partBody = $(".part-body .item-list-left, .part-body .item-list-right, .part-body .part-body-footer")
                    , result;
                result = partBody.validation().validate();
                if (result.errors.length) {
                    return;
                }

                // 配合削除か新規版以外は変更チェックを行う
                if (!isDeleted && hanNoNew != getHanNo()) {
                    // 変更がない場合は処理を抜ける
                    if (!isChanged) {
                        App.ui.page.notifyInfo.message(pageLangText.noChange.text).show();
                        return;
                    }
                }

                // 重ねのチェック
                //if (!checkKasaneSystemgaiKowake()) {
                if (!checkKasane(true)) {
                    //App.ui.page.notifyAlert.message(MS0767).show();
                    return;
                }

                var partBodyJSON = partBody.toJSON();

                if (partBodyJSON["kbn_shiagari"] == pageLangText.totalHaigoQty.text) {
                    searchHaigoGokei(new searchQuery(grid.jqGrid('footerData', 'get').juryo), isDeleted);
                }
                else {
                    if (isDeleted) {
                        saveData(isDeleted);
                    }
                    else {
                        //showSaveConfirmDialog();
                        getFromDate(); // 有効開始日付を取得して仕掛品計画の実績存在チェックをします。
                    }
                }
            };
            /// <summary>変更を保存します。</summary>
            /// <param name="isDeleted">削除フラグ</param>
            var saveData = function (isDeleted) {
                // TODO：画面の仕様に応じて保存対象のデータをセットしてください。
                var partBody = $(".part-body")
                // TODO：ここまで
                // 配合名マスタの変更セットを初期化
                // 配合レシピの変更内容を初期化
                changeSetSecond = new App.ui.page.changeSet();
                // ローディングの表示
                App.ui.loading.show(pageLangText.nowSaving.text);
                // 更新データをJSONオブジェクトに変換
                var postDataBodySecond = partBody.toJSON();
                // 配合重量をセット
                postDataBodySecond["wt_haigo"] = $("[name ='wt_kihon']").val();
                // TODO: 画面の仕様に応じて新規/更新/削除にて処理を変更してください。
                if (isDeleted) {
                    // 配合レシピの変更内容を初期化
                    changeSetFirst = new App.ui.page.changeSet();
                    // 配合名マスタの削除内容を格納
                    changeSetSecond.addDeleted(1, postDataBodySecond);
                }
                else if (isCreated) {
                    // 作成者をセット
                    postDataBodySecond["cd_create"] = App.ui.page.user.Code;
                    // 更新者をセット
                    postDataBodySecond["cd_update"] = App.ui.page.user.Code;
                    // 配合名マスタの新規内容を格納
                    changeSetSecond.addCreated(1, postDataBodySecond);
                }
                else {
                    // 更新者をセット
                    postDataBodySecond["cd_update"] = App.ui.page.user.Code;
                    // 配合名マスタの変更内容を格納
                    changeSetSecond.addUpdated(1, null, null, postDataBodySecond);
                };
                // 日付を10時固定にする
                var dtFrom = $("#id_dt_from").val();
                var dtHinkan = $("#id_dt_hinkan").text();
                var dtSeizo = $("#id_dt_seizo").text();
                postDataBodySecond["dt_from"] = App.data.getDateTimeStringForQueryNoUtc(App.date.localDate(dtFrom));
                if (!App.isUndefOrNull(dtHinkan) && dtHinkan != "") {
                    postDataBodySecond["dt_hinkan_koshin"] = App.data.getDateTimeStringForQueryNoUtc(App.date.localDate(dtHinkan));
                }
                if (!App.isUndefOrNull(dtSeizo) && dtSeizo != "") {
                    postDataBodySecond["dt_seizo_koshin"] = App.data.getDateTimeStringForQueryNoUtc(App.date.localDate(dtSeizo));
                }

                // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                var saveUrl = "../api/HaigoRecipeMaster";
                // TODO: ここまで

                App.ajax.webpost(
                    saveUrl, getPostData()
                ).done(function (result) {
                    // 新規版の場合は新規版を初期化
                    if (isCreated) {
                        hanNoMax = hanNoNew;
                        hanNoNew = 0;
                        $('.nm_shinki_han').attr('disabled', false);
                        $('.nm_shinki_kotei').attr('disabled', false);
                    }

                    // 終了メッセージの切替
                    if (isDeleted) {
                        // 削除の場合：deleteComplete(MS0039)
                        $("#id_saveComplete").text(pageLangText.deleteComplete.text);
                    }
                    else {
                        // 削除以外(保存)の場合：saveComplete(MS0036)
                        $("#id_saveComplete").text(pageLangText.saveComplete.text);
                    }
                    // 終了メッセージ表示
                    showSaveCompleteDialog();
                }).fail(function (result) {
                    // データ変更エラーハンドリングを行います。
                    handleSaveDataError(result);
                }).always(function () {
                    // ローディングの終了
                    App.ui.loading.close();
                });
            };

            /// <summary>歩留チェックを行います。</summary>
            var checkRitsuBudomari = function () {
                var isValid = true;
                var ids = grid.jqGrid('getDataIDs');

                for (var i = 0; i < ids.length; i++) {
                    var id = ids[i];
                    var hinKbn = grid.getCell(id, "kbn_hin");

                    // 品区分が「作業指示」以外の場合
                    if (hinKbn != pageLangText.sagyoShijiHinKbn.text) {
                        var ritsuBudomari = parseFloat(grid.getCell(id, "ritsu_budomari"));
                        var unique = id + "_" + budomariCol;
                        if (ritsuBudomari <= 0) {
                            // 歩留が0以下の場合エラー
                            App.ui.page.notifyAlert.message(
                                App.str.format(MS0618, pageLangText.ritsu_budomari.text, 0)
                                , unique
                            ).show();
                            // 対象セルの背景変更
                            grid.setCell(id, budomariCol, ritsuBudomari, { background: '#ff6666' });
                            isValid = false;
                            break;
                        }
                        else {
                            // エラー色を解除
                            grid.setCell(id, budomariCol, ritsuBudomari, { background: '' });
                        }
                    }
                }
                return isValid;
            };

            /// <summary>マークP時の重量マスタチェックを行います。</summary>
            var checkMarkSpiceWeight = function () {
                var isValid = true;
                var ids = grid.jqGrid('getDataIDs');

                var wt_LimitWeight = 1;

                for (var i = 0; i < ids.length; i++) {
                    var id = ids[i];
                    var cdMark = grid.getCell(id, "cd_mark");

                    if (cdMark == pageLangText.spiceMarkCode.text) {
                        var cdHinmei = grid.getCell(id, "cd_hinmei");
                        var kbnHin = grid.getCell(id, "kbn_hin");
                        var wt_kowakeManual = grid.getCell(id, "wt_kowake");

                        if (wt_kowakeManual) {
                            //小分手動設定されている場合、リミットを超えているかチェック
                            if (wt_kowakeManual >= wt_LimitWeight) {
                                isValid = false;
                                break;
                            }
                        } else {
                            //小分手動設定されていない場合、重量マスタの定義値がリミットを超えているかチェック

                            var queryJuryoCheck = {
                                url: "../api/HaigoRecipeMaster",
                                cd_hinmei: cdHinmei,
                                kbn_hin: kbnHin,
                                kbn_jotai_sonota: pageLangText.sonotaJotaiKbn.text,
                                kbn_jotai_shikakari: pageLangText.shikakariJotaiKbn.text,
                                kbn_hin_genryo: pageLangText.genryoHinKbn.text,
                                kbn_hin_shikakari: pageLangText.shikakariHinKbn.text
                            }

                            App.ajax.webgetSync(
                            App.data.toWebAPIFormat(queryJuryoCheck)
                            ).done(function (result) {
                                if (result.d.length > 0) {
                                    var wt_CheckKowake;
                                    wt_CheckKowake = result.d[0].wt_kowake;
                                    if (wt_CheckKowake >= wt_LimitWeight) {
                                        isValid = false;
                                    }
                                }
                            }).fail(function (result) {
                                //
                            }).always(function () {
                                //
                            });

                            if (isValid == false) {
                                break;
                            }
                        }
                    }
                }

                return isValid;
            }

            /// <summary>保存ボタンクリック時のイベント処理を行います。</summary>
            $(".save-button").on("click", function (e) {
                App.ui.page.notifyAlert.clear();
                var check_hinkan = $("#flg_tanto_hinkan").attr("checked");
                var check_seizo = $("#flg_tanto_seizo").attr("checked");

                $("#" + getSelectedRowId(false)).removeClass("ui-state-highlight").find("td:nth-child(" + firstCol + ")").click();

                if (check_hinkan === "checked" && isChangedHinkan) {
                    $("#flg_tanto_hinkan").attr("checked", "checked");
                    $("[name='cd_tanto_hinkan']").val(App.ui.page.user.Code);
                    $("[name='nm_tanto_hinkan']").text(App.ui.page.user.Name);
                    $("[name='dt_hinkan_koshin']").text(getDate());
                }

                if (check_seizo === "checked" && isChangedSeizo) {
                    $("#flg_tanto_seizo").attr("checked", "checked");
                    $("[name='cd_tanto_seizo']").val(App.ui.page.user.Code);
                    $("[name='nm_tanto_seizo']").text(App.ui.page.user.Name);
                    $("[name='dt_seizo_koshin']").text(getDate());
                }

                // 編集内容の保存
                saveEdit();

                // 検索条件変更チェック
                if (isCriteriaChange) {
                    showCriteriaChange("save");
                    return;
                }
                // 工程空白チェック
                if (isKoteiBlank) {
                    // 情報メッセージ出力
                    showKoteiBlank();
                    return;
                }
                // 合計配合重量チェック
                var gogeiJuryo = parseFloat(grid.jqGrid('footerData', 'get').juryo);
                if (gogeiJuryo > parseFloat(pageLangText.max_juryo.number)) {
                    App.ui.page.notifyAlert.message(
                        App.str.format(MS0666, pageLangText.haigo_total.text, 0, pageLangText.max_juryo.number)
                    ).show();
                    return;
                }
                // 歩留チェック：品区分が「作業指示」以外のとき、歩留が0の場合はエラー
                var checkResult = checkRitsuBudomari();
                if (!checkResult) {
                    return;
                }

                // マーク重量チェック
                var checkMarkResult = checkMarkSpiceWeight();
                if (!checkMarkResult) {
                    App.ui.page.notifyAlert.message(
                        App.str.format(pageLangText.kowakejuryoError.text)
                    ).show();
                    return;
                }

                // 共通チェック処理
                saveCheck(false);

                // 確認メッセージ
                //showSaveConfirmDialog();
            });

            /// <summary>配合削除ボタンクリック時のイベント処理を行います。</summary>
            $(".deleteHaigo-button").on("click", function (e) {
                // 検索条件変更チェック
                if (isCriteriaChange) {
                    showCriteriaChange("del");
                    return;
                }
                // 版チェック
                if (getHanNo() !== '1') {
                    // 該当版削除確認メッセージ
                    showDeleteHanConfirmDialog();
                }
                else {
                    // 全版削除確認メッセージ
                    showDeleteAllConfirmDialog();
                }
            });

            /// <summary>チェックボックス操作時のグリッド値更新を行います</summary>
            $(document).on("click", "#item-grid .jqgrow td :checkbox", function () {

                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();

                // 参考：iRowにて記述する場合
                var iCol = $(this).parent("td").parent("tr").find("td").index($(this).parent("td")),
                    selectedRowId = $(this).parent("td").parent("tr").attr("id"),
                    cellName = grid.getGridParam("colModel")[iCol].name,
                    value;

                //$("#" + rowid + " td:eq('" + (selectCol + 1) + "')").click();
                $("#" + selectedRowId).removeClass("ui-state-highlight").find("td:nth-child(" + firstCol + ")").click();    // 行選択

                // 更新状態の変更データの設定
                var changeData = setUpdatedChangeDataFirst(grid.getRowData(selectedRowId));

                // TODO：画面の仕様に応じて以下の定義を変更してください。
                value = changeData[cellName];
                // TODO：ここまで

                // 更新状態の変更セットに変更データを追加
                changeSetFirst.addUpdated(selectedRowId, cellName, value, changeData);
            });

            //// 保存処理 -- End

            //// バリデーション -- Start

            // TODO: 画面の仕様に応じて以下のカスタムバリデーション定義を変更してください。

            /// <summary>データベース問い合わせチェックを行います。</summary>
            /// <param name="hinmeiCode">品コード</param>
            var isValidHinmeiName = function (hinmeiCode) {
                if (flg_move) {
                    return true;
                }
                var isValid = false;
                var selectedRowId = getSelectedRowId(true);
                //var selectedRowId = currentRowId; // 行削除時に不具合が出るため、getSelectedRowIdで行番号を取得する
                // 選択行の品区分を取得
                var hinKbn = grid.getCell(selectedRowId, "kbn_hin");
                // 品区分毎の品コード取得先を設定
                var serviceUrl = getServiceUrl(hinKbn, selectedRowId);
                // 仕掛品は配合コードと照合する
                var elementCode = 'cd_hinmei';
                if (hinKbn == pageLangText.shikakariHinKbn.text) {
                    elementCode = 'cd_haigo';
                }
                App.ajax.webgetSync(
                    serviceUrl
                ).done(function (result) {
                    // サービス呼び出し成功時の処理
                    if (result.d.length > 0) {
                        isValid = true;
                    }
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                });
                return isValid;
            };

            // 品名コード
            validationSetting.cd_hinmei.rules.custom = function (inputHinCode) {
                if (event && event.srcElement && event.srcElement.name
                    && event.srcElement.name === "save-button") {
                    var criteriaHaigoCode = $(".search-criteria").toJSON().cd_haigo;
                    var selectedRowId = getSelectedRowId(false);
                    var hinKubun = grid.getCell(selectedRowId, "kbn_hin");
                    criteriaHaigoCode = App.ifUndefOrNull(criteriaHaigoCode, "");
                    inputHinCode = App.ifUndefOrNull(inputHinCode, "");

                    if (inputHinCode === criteriaHaigoCode
                    && hinKubun === pageLangText.shikakariHinKbn.text) {
                        return false;
                    }
                }
                return true;
            };

            // 品名チェック
            //validationSetting.cd_hinmei.rules.custom = function (value) {
            //    return isValidHinmeiName(value);
            //};

            // マーク入力チェック
            validationSetting.mark.rules.custom = function (value) {
                value = App.ifUndefOrNull(value, "");
                var isValid = true;
                var selectedRowId = grid.getGridParam("selrow");
                markCode = grid.getCell(selectedRowId, "cd_mark");
                switch (grid.getCell(selectedRowId, "kbn_hin")) {
                    // 品区分が「原料」「仕掛品」「自家原料」の場合                                                                                                                                                                                                                                                                 
                    case pageLangText.genryoHinKbn.text:
                    case pageLangText.shikakariHinKbn.text:
                    case pageLangText.jikaGenryoHinKbn.text:
                        /*
                        switch (value) {
                        case pageLangText.kowakeMarkKbn.text:
                        //case pageLangText.kowakeMarkKbn.text:
                        case pageLangText.kasane1MarkKbn.text:
                        case pageLangText.kasane2MarkKbn.text:
                        case pageLangText.kasane3MarkKbn.text:
                        case pageLangText.kasane4MarkKbn.text:
                        case pageLangText.kasane5MarkKbn.text:
                        case pageLangText.kasane6MarkKbn.text:
                        case pageLangText.kasane7MarkKbn.text:
                        case pageLangText.kasane8MarkKbn.text:
                        case pageLangText.kasane9MarkKbn.text:
                        case pageLangText.spiceMarkKbn.text:
                        case pageLangText.nisugataTonyuMarkKbn.text:
                        case pageLangText.ryuryokeiMarkKbn.text:

                        break;
                        default:
                        isValid = false;
                        */
                        switch (markCode) {
                            case pageLangText.kowakeMarkCode.text:
                            case pageLangText.kasane1MarkCode.text:
                            case pageLangText.kasane2MarkCode.text:
                            case pageLangText.kasane3MarkCode.text:
                            case pageLangText.kasane4MarkCode.text:
                            case pageLangText.kasane5MarkCode.text:
                            case pageLangText.kasane6MarkCode.text:
                            case pageLangText.kasane7MarkCode.text:
                            case pageLangText.kasane8MarkCode.text:
                            case pageLangText.kasane9MarkCode.text:
                            case pageLangText.spiceMarkCode.text:
                            case pageLangText.nisugataTonyuMarkCode.text:
                            case pageLangText.ryuryokeiMarkCode.text:

                                break;
                            default:
                                isValid = false;
                        };
                        break;
                    // 品区分が「作業指示」の場合                                                                                                                                                                                                                                                                                                           
                    case pageLangText.sagyoShijiHinKbn.text:
                        /*
                        switch (value) {
                        case pageLangText.kakuhanMarkKbn.text:
                        case pageLangText.hyojiMarkKbn.text:
                        case pageLangText.RIMarkKbn.text:
                        case pageLangText.sagyoMarkKbn.text:
                        break;
                        default:
                        isValid = false;
                        */
                        switch (markCode) {
                            case pageLangText.kakuhanMarkCode.text:
                            case pageLangText.hyojiMarkCode.text:
                            case pageLangText.RIMarkCode.text:
                            case pageLangText.sagyoMarkCode.text:
                                break;
                            default:
                                isValid = false;
                        };
                        break;
                    default:
                        isValid = false;
                };
                return isValid;
            };

            /// <summary>データベース問い合わせチェックを行います。</summary>
            /// <param name="wtShikomi">配合重量</param>
            var isValidWtShikomi = function (wtShikomi) {
                if (flg_move) {
                    return true;
                }
                var isValid = true;
                var selectedRowId = getSelectedRowId(true);
                //var selectedRowId = currentRowId; // 行削除時に不具合が出るため、getSelectedRowIdで行番号を取得する
                // 選択行の品区分を取得
                var hinKbn = grid.getCell(selectedRowId, "kbn_hin");

                // 品区分が作業指示以外で配合重量がnullの場合はエラーとする
                if (hinKbn != pageLangText.sagyoShijiHinKbn.text) {
                    if (App.isUndefOrNull(wtShikomi) || wtShikomi.length == 0) {
                        isValid = false
                    }
                }
                return isValid;
            };
            // 配合重量の必須チェック
            validationSetting.wt_shikomi.rules.custom = function (value) {
                // 作業指示以外は必須
                return isValidWtShikomi(value);
            };

            // 仕上重量直接入力の必須チェック
            validationSetting.wt_haigo_gokei.rules.custom = function (value) {
                // 仕上重量の決定で直接入力が選択されている場合
                if ($("input:radio[name='kbn_shiagari']:checked").val() == "1") {
                    //if (App.isUndefOrNull(wt_haigo_gokei.value) || (App.isStr(wt_haigo_gokei.value) && wt_haigo_gokei.value.length === 0)) {
                    if (App.isUndefOrNull(value) || (App.isStr(value) && value.length === 0)) {
                        return false;
                    }
                }
                return true;
            }
            // TODO: ここまで

            // グリッドコントロール固有のバリデーション
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

                // 上の背景色をなくした処理でチェックボックスの非活性が解けるので再度非活性にする
                if (cellName === "flg_kowake_systemgai" && grid.getCell(selectedRowId, "kbn_hin") === pageLangText.sagyoShijiHinKbn.text) {
                    var checkbox = $("#" + selectedRowId + " td:eq(" + iCol + ")").find(":checkbox");
                    checkbox.prop("disabled", true);
                }

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

            // grid以外のバリデーション設定
            var v2 = Aw.validation({
                //items: validationSetting,
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
            $(".part-body .item-list-left, .part-body .item-list-right, .part-body .part-body-footer").validation(v2);
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

                resultPart.height(container[0].clientHeight - searchPart[0].clientHeight - ((parseInt(resultPartStyle.marginTop, 10) * 3) || 0) - 160);
                grid.setGridWidth(resultPart[0].clientWidth - 5);
                //グリッドの高さ設定　結果一覧のパートの高さ - パートのヘッダーの高さ - パート内のボタンのコマンドの高さ - jqGrid のカラムヘッダーの高さ
                grid.setGridHeight(resultPart[0].clientHeight - resultPartHeader[0].clientHeight - resultPartCommands[0].clientHeight - resultPart.find(".ui-jqgrid-hdiv")[0].clientHeight - 25);
            };
            /// <summary>画面リサイズ時のイベント処理を行います。</summary>
            $(App.ui.page).on("resized", resizeContents);

            /// <summary>ページ遷移を行います。</summary>
            /// <param name="pageFileName">遷移先ファイル名</param>
            var navigate = function (pageFileName) {
                // TODO：画面の仕様に応じて変更してください。
                var url = "./" + pageFileName + ".aspx";
                url += "?cd_bunrui=" + cd_bunrui;
                url += "&haigoName=" + haigoName;
                var button = pageFileName;
                if (pageFileName === "HaigoMaster") {
                    button = "detail-button";
                    // 遷移時に渡すパラメータを設定
                    url += "&cdHaigo=" + haigoCode;
                    url += "&no_han=" + getHanNo();
                }
                url += "&handle=" + button;
                url += "&mishiyoFlg=" + mishiyoFlg;
                url += "&dt_yuko=" + dt_yuko;
                // TODO: ここまで
                window.location = url;
            };

            /// <summary>一覧へ戻るボタンクリック時のイベント処理を行います。</summary>
            $(".list-button").on("click", function (e) {
                // 検索条件変更チェック
                if (isCriteriaChange) {
                    showCriteriaChange("navigate");
                    return;
                }
                try {
                    // 一覧画面に戻る
                    navigate("HaigoMasterIchiran");
                } catch (e) {
                }
            });

            /// <summary>詳細ボタンクリック時のイベント処理を行います。</summary>
            $(".detail-button").on("click", function (e) {
                // 検索条件変更チェック
                if (isCriteriaChange) {
                    showCriteriaChange("navigate");
                    return;
                }
                // 新規版チェック
                if (hanNoNew == getHanNo()) {
                    showNavigateError(pageLangText.navigateErrorDetail.text);
                    return;
                }
                navigate("HaigoMaster");

            });

            /// <summary>PDFファイル出力を行います。</summary>
            var printPDF = function (e) {
                var criteria = $(".search-criteria").toJSON();
                var container = $(".part-body").toJSON(),
                    nameHaigo = $("[name='" + haigoNameCountry + "']").val();
                str = "";

                // 日付がnull、undefの場合は空白を設定
                if (App.ifUndefOrNull(container.dt_hinkan_koshin, "") != "") {
                    container.dt_hinkan_koshin = App.data.getDateString(container.dt_hinkan_koshin, true);
                }
                if (App.ifUndefOrNull(container.dt_seizo_koshin, "") != "") {
                    container.dt_seizo_koshin = App.data.getDateString(container.dt_seizo_koshin, true);
                }
                // 配合名がnullの場合は空文字を設定
                if (App.isUndefOrNull(nameHaigo)) {
                    nameHaigo = "";
                }
                // 仕掛品分類がnullの場合は空文字を設定
                var bunrui = container.nm_bunrui;
                if (App.isUndefOrNull(bunrui)) {
                    bunrui = "";
                }
                // 調味液ラベル重量がnullの場合は空文字を設定
                var juryo = container.wt_kowake;
                if (App.isUndefOrNull(juryo)) {
                    juryo = "";
                }
                // 調味液ラベル枚数がnullの場合は空文字を設定
                var maisu = container.su_kowake;
                if (App.isUndefOrNull(maisu)) {
                    maisu = "";
                }
                // 製法番号がnullの場合は空文字を設定
                var seihoNo = container.no_seiho;
                if (App.isUndefOrNull(seihoNo)) {
                    seihoNo = "";
                }
                // 備考がnullの場合は空文字を設定
                var biko = container.biko;
                if (App.isUndefOrNull(biko)) {
                    biko = "";
                }
                // 未使用フラグがnullの場合は0を設定
                var flgMishiyo = container.flg_mishiyo;
                if (App.isUndefOrNull(flgMishiyo)) {
                    flgMishiyo = pageLangText.falseFlg.text;
                }
                // TODO：画面の入力項目をURLへ渡す
                var query = {
                    // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                    url: "../api/HaigoRecipeMasterPDF",
                    // TODO: ここまで
                    //filter: createFilter(),
                    //orderby: "cd_haigo"
                    lang: App.ui.page.lang,
                    //uuid: App.uuid(),
                    cd_haigo: container.cd_haigo,
                    nm_haigo: encodeURIComponent(nameHaigo),
                    nm_bunrui: encodeURIComponent(bunrui),
                    wt_haigo_gokei: container.wt_haigo_gokei,
                    wt_kowake: juryo,
                    su_kowake: maisu,
                    wt_kihon: container.wt_kihon,
                    no_han: container.no_han,
                    no_kotei: container.no_kotei,
                    no_seiho: encodeURIComponent(seihoNo),
                    biko: encodeURIComponent(biko),
                    dt_from: App.data.getDateString(container.dt_from, true),
                    //nm_tanto_hinkan: encodeURIComponent(App.ifUndefOrNull(container.nm_tanto_hinkan, "")),
                    //dt_hinkan_koshin: container.dt_hinkan_koshin,
                    //nm_tanto_seizo: encodeURIComponent(App.ifUndefOrNull(container.nm_tanto_seizo, "")),
                    //dt_seizo_koshin: container.dt_seizo_koshin,
                    nm_tanto_hinkan: $('.part-body [name="nm_tanto_hinkan"]').text(),
                    dt_hinkan_koshin: $('.part-body [name="dt_hinkan_koshin"]').text(),
                    nm_tanto_seizo: $('.part-body [name="nm_tanto_seizo"]').text(),
                    dt_seizo_koshin: $('.part-body [name="dt_seizo_koshin"]').text(),
                    flg_mishiyo: flgMishiyo,
                    local_today: App.data.getDateTimeStringForQuery(new Date(), true)
                }
                // PDF出力用URLを取得
                var url = App.data.toWebAPIFormat(query);
                url = url + "&nm_login=" + encodeURIComponent(App.ui.page.user.Name)
                            + "&uuid=" + App.uuid();

                window.open(url, '_parent');
            };
            /// <summary>印刷ボタンクリック時のイベント処理を行います。</summary>
            $(".print-button").on("click", function (e) {
                // 他イベント中は処理しない
                if (isDataLoading) {
                    return;
                }

                // 検索実行チェック
                if (!isSearch) {
                    showBeforeSearch();
                    return;
                }
                // 検索条件変更チェック
                if (isCriteriaChange) {
                    showCriteriaChange("output");
                    return;
                }
                // 工程空白チェック
                if (isKoteiBlank) {
                    // 情報メッセージ出力
                    showKoteiBlank();
                    return;
                }
                // 新規版チェック
                if (hanNoNew == getHanNo()) {
                    showNavigateError(pageLangText.navigateErrorPrint.text);
                    return;
                }
                // 明細チェック：明細に変更がないこと
                if (isChanged) {
                    App.ui.page.notifyInfo.message(
                         App.str.format(pageLangText.criteriaChange.text
                            , pageLangText.meisai.text
                            , pageLangText.print.text)
                    ).show();
                    return;
                }
                printPDF();
            });

            // 検索条件に変更が発生した場合
            $(".search-criteria").on("change", function () {
                // 検索後の状態で検索条件が変更された場合
                if (isSearch) {
                    isCriteriaChange = true;
                }
            });

            /// <summary>データのクリアを行います。</summary>
            var clearData = function () {
                // ページをリロード
                window.location.reload();
                // 変更フラグの初期化
                isChanged = false;
            };

            /// <summary>品管チェック者名のクリアを行います。</summary>
            var hinkanTantoClear = function () {
                $("#flg_tanto_hinkan").attr("checked", false);
                $("[name='cd_tanto_hinkan']").val(pageLangText.shokikaShokichi.text);
                $("[name='dt_hinkan_koshin']").text(pageLangText.shokikaShokichi.text);
                $("[name='nm_tanto_hinkan']").text(pageLangText.shokikaShokichi.text);
            };

            /// <summary>製造チェック者名のクリアを行います。</summary>
            var seizoTantoClear = function () {
                $("#flg_tanto_seizo").attr("checked", false);
                $("[name='cd_tanto_seizo']").val(pageLangText.shokikaShokichi.text);
                $("[name='dt_seizo_koshin']").text(pageLangText.shokikaShokichi.text);
                $("[name='nm_tanto_seizo']").text(pageLangText.shokikaShokichi.text);
            };

            /// <summary>版Noの最大値チェックを行います。</summary>
            var checkHanNo = function (hanNo) {
                return (hanNo >= pageLangText.maxHanNo.text);
            };

            /// <summary>新規版を取得します。</summary>
            var setNewHan = function () {
                // 情報メッセージのクリア
                App.ui.page.notifyInfo.clear();
                // エラーメッセージのクリア
                //App.ui.page.notifyAlert.clear();
                if (checkHanNo(hanNoMax)) {
                    App.ui.page.notifyAlert.message(pageLangText.overNumber.text, $("#id_no_han")).show();
                    return;
                }
                hanNoCurrent = getHanNo();
                hanNoNew = hanNoMax + 1;
                $("[name='no_han']").prepend($('<option>').html(hanNoNew).val(hanNoNew));
                $("[name='no_han']").val(hanNoNew);
                searchKoteiNo();

                // 再検索を実施する。
                clearState();
                searchItems();
            };
            $(".nm_shinki_han").on("click", setNewHan);

            /// <summary>新規工程を取得します。</summary>
            var setNewKotei = function () {
                // 情報メッセージのクリア
                App.ui.page.notifyInfo.clear();
                // エラーメッセージのクリア
                //App.ui.page.notifyAlert.clear();
                if (checkHanNo(koteiNoMax)) {
                    App.ui.page.notifyAlert.message(pageLangText.overNumber.text, $("#id_no_kotei")).show();
                    return;
                }
                else {
                    if (koteiNoNew == 0) {
                        koteiNoNew = koteiNoMax + 1;
                        $("[name='no_kotei']").append($('<option>').html(koteiNoNew).val(koteiNoNew));
                        $("[name='no_kotei']").val(koteiNoNew);
                        $('.nm_shinki_han').attr('disabled', true);
                        $('.nm_shinki_kotei').attr('disabled', true);
                        // 検索処理
                        showSearchConfirmDialog();
                    }
                };
            };
            $(".nm_shinki_kotei").on("click", setNewKotei);

            hinmeiDialog.dlg({
                url: "Dialog/HinmeiDialog.aspx",
                name: "HinmeiDialog",
                closed: function (e, data, data2) {
                    if (data == "canceled") {
                        return;
                    }
                    else {
                        var selectedRowId = getSelectedRowId();
                        // ロストフォーカス時の値クリアを回避
                        //$("#" + selectedRowId + " td:eq('" + (selectCol + 1) + "')").click();
                        saveEdit();
                        // 選択値をセット
                        grid.setCell(selectedRowId, "cd_hinmei", data);
                        // セルバリデーション実行
                        validateCell(selectedRowId, "cd_hinmei", data, hinCodeCol);
                        // セル保存後の処理実行
                        //fncAfterSaveCell(selectedRowId, "cd_hinmei", data, currentRow, currentCol);
                        fncAfterSaveCell(selectedRowId, "cd_hinmei", data, currentRow, hinCodeCol);
                    }
                }
            });

            /// <summary>品名一覧ボタンクリック時のイベント処理を行います。</summary>
            $("#hinmei-button").on("click", function (e) {
                // 検索条件変更チェック
                if (isCriteriaChange) {
                    showCriteriaChange("navigate");
                    return;
                }
                // 工程空白チェック
                if (isKoteiBlank) {
                    // 情報メッセージ出力
                    showKoteiBlank();
                    return;
                }
                openHinmeiDlg(e);
            });

            markDialog.dlg({
                url: "Dialog/MarkDialog.aspx",
                name: "MarkDialog",
                closed: function (e, data, data2) {
                    if (data == "canceled") {
                        return;
                    }
                    else {
                        var selectedRowId = getSelectedRowId();
                        // 選択値をセット
                        grid.setCell(selectedRowId, "cd_mark", data);
                        if (data2 == "") {
                            grid.setCell(selectedRowId, "mark", null);
                        }
                        else {
                            grid.setCell(selectedRowId, "mark", data2);
                        }
                        // セルバリデーション実行
                        validateCell(selectedRowId, "mark", data2, markCol);
                        // セル保存後の設定
                        fncAfterSaveCell(selectedRowId, "cd_mark", data, currentRow, currentCol);
                    }
                }
            });

            /// マークマスタセレクタを起動する
            var showMarcDialog = function () {
                // ロストフォーカス時の値クリアを回避
                var selectedRowId = getSelectedRowId(false);
                $("#" + selectedRowId + " td:eq('" + (tonyuCol) + "')").click();

                markDialog.draggable(true);
                markDialog.dlg("open", { multiselect: false });
            };
            /// <summary>マーク一覧ボタンクリック時のイベント処理を行います。</summary>
            $("#mark-button").on("click", function (e) {
                // 検索条件変更チェック
                if (isCriteriaChange) {
                    showCriteriaChange("navigate");
                    return;
                }
                // 工程空白チェック
                if (isKoteiBlank) {
                    // 情報メッセージ出力
                    showKoteiBlank();
                    return;
                }
                // レコード０件チェック
                if (!recordCheck(false)) {
                    return;
                };
                showMarcDialog();
            });

            futaiDialog.dlg({
                url: "Dialog/FutaiDialog.aspx",
                name: "FutaiDialog",
                closed: function (e, data, data2) {
                    if (data == "canceled") {
                        return;
                    }
                    else {
                        var selectedRowId = getSelectedRowId(false);
                        // ロストフォーカス時の値クリアを回避
                        //$("#" + selectedRowId + " td:eq('" + (selectCol + 1) + "')").click();
                        saveEdit();
                        grid.setCell(selectedRowId, "cd_futai", data);
                        grid.setCell(selectedRowId, "nm_futai", data2);
                        // 更新状態の変更セットに変更データを追加
                        fncAfterSaveCell(selectedRowId, "cd_futai", data, currentRow, currentCol);
                    }
                }
            });

            /// <summary>風袋一覧ボタンクリック時のイベント処理を行います。</summary>
            $("#futai-button").on("click", function (e) {
                // 検索条件変更チェック
                if (isCriteriaChange) {
                    showCriteriaChange("navigate");
                    return;
                }
                // 工程空白チェック
                if (isKoteiBlank) {
                    // 情報メッセージ出力
                    showKoteiBlank();
                    return;
                }
                // レコード０件チェック
                if (!recordCheck(false)) {
                    return;
                };
                var option = { id: 'futai', multiselect: false };
                futaiDialog.draggable(true);
                futaiDialog.dlg("open", option);
            });

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
                }
                // 情報メッセージ出力
                App.ui.page.notifyAlert.message(
                        App.str.format(pageLangText.criteriaChange.text, pageLangText.searchCriteria.text, alertMessage)
                    ).show();
            };

            /// <summary>工程空白チェックメッセージを出力します。</summary>
            var showKoteiBlank = function () {
                // 情報メッセージのクリア
                App.ui.page.notifyInfo.clear();
                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();
                // 情報メッセージ出力
                App.ui.page.notifyAlert.message(pageLangText.koteiBlank.text).show();
            };

            /// <summary>検索実行チェックメッセージを出力します。</summary>
            var showBeforeSearch = function () {
                // 情報メッセージのクリア
                App.ui.page.notifyInfo.clear();
                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();
                // 情報メッセージ出力
                App.ui.page.notifyAlert.message(pageLangText.beforeSearch.text).show();
            };

            /// <summary>遷移エラーメッセージを出力します。</summary>
            var showNavigateError = function (errMsg) {
                // 情報メッセージのクリア
                App.ui.page.notifyInfo.clear();
                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();
                // 情報メッセージ出力
                App.ui.page.notifyAlert.message(errMsg).show();
            };

            /// <summary>配合版変更時のイベント処理を行います。</summary>
            $("[name='no_han']").on("change", function (e) {
                searchKoteiNo(e);
            });

            /// <summary>データに変更があり、未保存の状態でページを離れる際に確認を行います。</summary>
            var backToMenuCheck = function () {
                if (isChanged) {
                    showMenuConfirmDialog();
                }
                else {
                    backToMenu();
                }
            };

            var backToMenu = function () {
                //closeMenuConfirmDialog();
                //isChanged = false;
                // IEバグによる例外発生をキャッチします。例外発生時は何もしません。
                try {
                    window.location = pageLangText.menuPath.url;
                }
                catch (e) {
                    // 何もしない
                }
            };

            // 3桁のカンマ区切りの値をセット
            function setThousandsSeparator(target) {
                var value = $(target).val();
                var comma = $(target).attr("comma");
                value = getThousandsSeparator(value, comma);
                $(target).val(value);
            }

            // 3桁のカンマ区切りの値を取得
            function getThousandsSeparator(targetValue, comma) {
                // カンマとスペースを除去
                var value = getThousandsSeparatorDel(targetValue);
                // カンマ区切り
                while (value != (value = value.replace(/^(-?\d+)(\d{3})/, "$1,$2")));
                // 数値以外の場合
                if (isNaN(parseInt(value))) {
                    value = "";
                }
                else {
                    if (!App.isUndefOrNull(comma) && comma.length > 0) {
                        // 小数点以下のフォーマット
                        var _str = value.indexOf(".");
                        var _keta;
                        if (_str < 0) {
                            value = value + ".";
                            _keta = comma;
                        }
                        else {
                            _keta = comma - (value.length - _str - 1);
                        }
                        for (var i = 1; i <= _keta; i++) {
                            value = value + "0";
                        }
                    }
                }
                return value;
            }

            // 3桁のカンマ区切りを除外した値をセット
            function setThousandsSeparatorDel(target) {
                var value = $(target).val();
                value = setThousandsSeparatorDel(value);
                $(target).val(value);
            }

            // 3桁のカンマ区切りを除外した値を取得
            function getThousandsSeparatorDel(value) {
                value = "" + value;
                // スペースとカンマを削除
                return value.replace(/^\s+|\s+$|,/g, "");
            }

            /// <summary>クリアボタンクリック時のイベント処理を行います。</summary>
            $(".clear-button").on("click", showClearConfirmDialog);
            /// <summary>クリア確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".clear-confirm-dialog .dlg-yes-button").on("click", clearData);
            // <summary>クリア確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".clear-confirm-dialog .dlg-no-button").on("click", closeClearConfirmDialog);

            /// <summary>保存確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".save-confirm-dialog .dlg-yes-button").on("click", function () {
                // 保存処理　引数１：削除かどうか
                //saveCheck(false);
                closeSaveConfirmDialog();
                saveData(false);
            });
            // <summary>保存確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".save-confirm-dialog .dlg-no-button").on("click", closeSaveConfirmDialog);
            /// <summary>保存完了ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".save-complete-dialog .dlg-close-button").on("click", saveComplete);

            /// <summary>版削除確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".deleteHan-confirm-dialog .dlg-yes-button").on("click", function () {
                // 保存処理　引数１：削除かどうか
                saveCheck(true);
            });
            // <summary>版削除確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".deleteHan-confirm-dialog .dlg-no-button").on("click", closeDeleteHanConfirmDialog);

            /// <summary>全版削除確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".deleteAll-confirm-dialog .dlg-yes-button").on("click", function () {
                // 保存処理　引数１：削除かどうか
                saveCheck(true);
            });
            // <summary>全版削除確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".deleteAll-confirm-dialog .dlg-no-button").on("click", closeDeleteAllConfirmDialog);

            /// <summary>検索確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".search-confirm-dialog .dlg-yes-button").on("click", function () {
                clearState();
                searchItems();
            });
            // <summary>検索確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".search-confirm-dialog .dlg-no-button").on("click", closeSearchConfirmDialog);

            /// <summary>未保存の状態でページ遷移確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".menu-confirm-dialog .dlg-yes-button").on("click", backToMenu);
            /// <summary>未保存の状態でページ遷移確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".menu-confirm-dialog .dlg-no-button").on("click", closeMenuConfirmDialog);

            /// <summary>計画再立案確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".replan-confirm-dialog .dlg-yes-button").on("click", function () {
                closeReplanConfirmDialog();
                showSaveConfirmDialog();
            });

            /// <summary>メニューボタンクリック時のイベント処理を行います。</summary>
            //$(".menu-button").on("click", backToMenuCheck);
            $(".menu-button").on("click", backToMenu);

            // コンテンツに変更が発生した場合は、
            $(".result-list").on("change", function (e) {
                if (e.target.id !== "flg_tanto_hinkan" && e.target.id !== "flg_tanto_seizo") {
                    hinkanTantoClear();
                    seizoTantoClear();
                    isChanged = true;
                }
            });

            /// <summary>品管チェックボックスクリック時のイベント処理を行います。</summary>
            $("#flg_tanto_hinkan").on("click", function (e) {
                // 変更フラグをセット
                isChanged = true;
                if ($("#flg_tanto_hinkan").attr("checked") === "checked") {
                    $("[name='cd_tanto_hinkan']").val(App.ui.page.user.Code);
                    $("[name='nm_tanto_hinkan']").text(App.ui.page.user.Name);
                    $("[name='dt_hinkan_koshin']").text(getDate());
                    isChangedHinkan = true;
                }
                else {
                    hinkanTantoClear();
                    isChangedHinkan = false;
                }
            });

            /// <summary>製造チェックボックスクリック時のイベント処理を行います。</summary>
            $("#flg_tanto_seizo").on("click", function (e) {
                // 変更フラグをセット
                isChanged = true;
                if ($("#flg_tanto_seizo").attr("checked") === "checked") {
                    $("[name='cd_tanto_seizo']").val(App.ui.page.user.Code);
                    $("[name='nm_tanto_seizo']").text(App.ui.page.user.Name);
                    $("[name='dt_seizo_koshin']").text(getDate());
                    isChangedSeizo = true;
                }
                else {
                    seizoTantoClear();
                    isChangedSeizo = false;
                }
            });

            // 入力項目変更時のイベント処理：数値のフォーマット
            $(".format-thousands-Separator").on("change", function () {
                setThousandsSeparator(this);
            });

            // 換算区分をKg・L → LB・GALとする。
            //phuc add start
            if (pageLangText.kbn_tani_LB_GAL.text === App.ui.page.user.kbn_tani) {
                $(".class_tani_LB").show();
                $(".class_tani_Kg").hide();
            } else {
                $(".class_tani_LB").hide();
                $(".class_tani_Kg").show();
            }
            //phuc add end
        });
    </script>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <!-- 画面デザイン -- Start -->

    <!-- 検索条件と検索ボタン -->
    <div class="content-part search-criteria">
        <h3 class="part-header" data-app-text="searchCriteria"><a class="search-part-toggle" href="#"></a></h3>
        <div class="part-body">
            <ul class="item-list-left">
                <!-- TODO: 画面の仕様に応じて以下の検索条件を変更してください。-->
                <li>
                    <label>
                        <span class="item-label" data-app-text="cd_haigo"></span>
                        <input type="text" style="background-color: #F2F2F2" name="cd_haigo" readonly="readonly" />
                    </label>
                </li>
                <li>
                    <label>
                        <span class="item-label" data-app-text="nm_haigo"></span>
                        <input type="text" style="background-color: #F2F2F2" name="nm_haigo" readonly="readonly" />
                        <input type="hidden" name="nm_haigo_ja" />
                        <input type="hidden" name="nm_haigo_en" />
                        <input type="hidden" name="nm_haigo_zh" />
                        <input type="hidden" name="nm_haigo_vi" />
                        <input type="hidden" name="nm_haigo_ryaku" />
                    </label>
                </li>
                <li>
                    <label>
                        <span class="item-label" data-app-text="nm_bunrui" data-tooltip-text="nm_bunrui"></span>
                        <input type="hidden" name="cd_bunrui" />
                        <input type="text" style="background-color: #F2F2F2" name="nm_bunrui" readonly="readonly" />
                    </label>
                </li>
                <!-- TODO: ここまで -->
            </ul>
            <ul class="item-list-right">
                <li>
                    <label>
                        <input type="hidden" name="wt_kihon" />
                    </label>
                </li>
                <li>
                    <label>
                        <span class="item-label" data-app-text="nm_han"></span>
                        <select name="no_han" id="id_no_han"></select>
                    </label>
                    <input type="button" class="nm_shinki_han" name="nm_shinki_han" data-app-text="nm_shinki_han" data-app-operation="nm_shinki_han" />
                </li>
                <li>
                    <label>
                        <span class="item-label" data-app-text="nm_kotei"></span>
                        <select name="no_kotei" id="id_no_kotei"></select>
                    </label>
                    <input type="button" class="nm_shinki_kotei" name="nm_shinki_kotei" data-app-text="nm_shinki_kotei" data-app-operation="nm_shinki_kotei" />
                </li>
            </ul>
            <ul>
                <li>
                    <input type="hidden" name="kbn_kanzan" />
                </li>
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
        <h3 id="listHeader" class="part-header">
            <span data-app-text="resultList" style="padding-right: 10px;"></span>
            <span class="list-count" id="list-count"></span>
            <span style="padding-left: 50px;" class="list-loading-message" id="list-loading-message"></span>
        </h3>
        <div class="part-body">
            <ul class="item-list-left">
                <li>
                    <label>
                        <span class="item-label" data-app-text="con_recipe" data-tooltip-text="con_recipe"></span>
                        <label data-form-item="con_recipe"></label>
                    </label>
                </li>
                <li>
                    <label>
                        <span class="item-label" data-app-text="no_seiho" data-tooltip-text="no_seiho"></span>
                        <input type="text" name="no_seiho" />
                    </label>
                </li>
                <li>
                    <label>
                        <span class="item-label" data-app-text="dt_yuko"></span>
                        <input type="text" id="id_dt_from" name="dt_from" class="data-app-format" data-app-format="date" />
                    </label>
                </li>
            </ul>
            <ul class="item-list-right">
                <li>
                </li>
                <li>
                    <label>
                        <span class="item-label" data-app-text="notUse" data-tooltip-text="notUse"></span>
                        <input type="checkbox" name="flg_mishiyo" value="1" />
                        <span class="item-label" data-app-text="flg_mishiyo"></span>
                    </label>
                </li>
                <li>
                    <label>
                        <span class="item-label" data-app-text="biko" style="vertical-align:top;"></span>
                        <textarea name="biko" cols="50" wrap="soft"rows="2" maxlength="200"></textarea>
                        <!--<input type="text" name="biko" style="width: 20em;" />-->
                        <input type="hidden" name="cd_create" />
                        <input type="hidden" name="dt_create" class="data-app-format" data-app-format="datetime" />
                        <input type="hidden" name="cd_update" />
                        <input type="hidden" name="dt_update" class="data-app-format" data-app-format="datetime" />
                        <input type="hidden" name="flg_tenkai" />
                        <input type="hidden" name="ritsu_budomari" />
                        <input type="hidden" name="ritsu_hiju" />
                        <input type="hidden" name="ritsu_kihon" />
                        <input type="hidden" name="flg_gassan_shikomi" />
                        <input type="hidden" name="flg_shorihin" />
                        <input type="hidden" name="flg_tenkai" />
                        <input type="hidden" name="dd_shomi" />
                        <input type="hidden" name="kbn_hokan" />
                        <input type="hidden" name="ts" />
                    </label>
                </li>
            </ul>
        </div>
        <!-- グリッドコントロール固有のデザイン -- Start -->
        <div class="part-body" id="result-grid">
            <div class="item-command">
                <button type="button" class="list-button" name="list-button"><span class="icon"></span><span data-app-text="list"></span></button>
                <button type="button" class="colchange-button" data-app-operation="colchange"><span class="icon"></span><span data-app-text="colchange"></span></button>
                <button type="button" class="add-button" name="add-button" data-app-operation="add"><span class="icon"></span><span data-app-text="add"></span></button>
                <button type="button" class="delete-button" name="delete-button" data-app-operation="del"><span class="icon"></span><span data-app-text="del"></span></button>
                <button type="button" class="dialog-button" id="hinmei-button" name="hinmeiIchiran" data-app-operation="hinmeiIchiran"><span class="icon"></span><span data-app-text="hinmeiIchiran"></span></button>
                <button type="button" class="dialog-button" id="mark-button" name="markIchiran" data-app-operation="markIchiran"><span class="icon"></span><span data-app-text="markIchiran"></span></button>
                <button type="button" class="dialog-button" id="futai-button" name="futaiIchiran" data-app-operation="futaiIchiran"><span class="icon"></span><span data-app-text="futaiIchiran"></span></button>
            </div>
            <table id="item-grid" data-app-operation="itemGrid">
            </table>
        </div>
        <!-- グリッドコントロール固有のデザイン -- End -->
        <!-- フッター部分のデザイン -- Start -->
        <div class="part-body">
        <table class="part-body-footer">
        <!-- <table class="part-body"> -->
            <tbody>
                <tr>
                    <td rowspan="2" id="id_qty_shiage" data-app-text="qty_shiage"></td>
                    <td>
                        <input type="radio" name="kbn_shiagari" value="0" />
                        <label id="id_totalQtyHaigo" data-app-text="totalQtyHaigo"></label>
                    </td>
                    <td rowspan="2" id="id_labelChomieki" data-app-text="labelChomieki"></td>
                    <td>
                        <label id="id_wt_chomieki" data-app-text="wt_chomieki"></label>
                    </td>
                    <td>
                        <input type="text" class="format-thousands-Separator data-app-number" name="wt_kowake" style="width: 6em; text-align: right" comma="6" />
                    </td>
                    <td>
                        <label class="class_tani_Kg" data-app-text="tani_kg"></label>
                        <label class="class_tani_LB" data-app-text="tani_LB"></label>
                    </td>
                    <td rowspan="2" id="id_cd_tanto_koshin" data-app-text="cd_tanto_koshin"></td>
                    <td>
                        <label id="id_kbn_hinkan" data-app-text="kbn_hinkan"></label>
                    </td>
                    <td>
                        <input type="checkbox" id="flg_tanto_hinkan" name="flg_tanto_hinkan" value="1" data-app-operation="tanto_hinkan" />
                        <input type="hidden" name="cd_tanto_hinkan" />
                        <label type="text" name="nm_tanto_hinkan" style="width: 8em"></label>
                        <label type="text" id="id_dt_hinkan" name="dt_hinkan_koshin" style="width: 8em" class="data-app-format" data-app-format="date"></label>
                    </td>
                </tr>
                <tr>
                    <td>
                        <input type="radio" name="kbn_shiagari" value="1" />
                        <input type="text" class="format-thousands-Separator data-app-number" name="wt_haigo_gokei" style="text-align: right" data-app-validation="wt_haigo_gokei" comma="6" /><label class="class_tani_Kg" data-app-text="tani_kg"></label><label class="class_tani_LB" data-app-text="tani_LB"></label>
                        <input type="hidden" name="wt_saidai_shikomi" data-app-validation="wt_saidai_shikomi" />
                    </td>
                    <td>
                        <label id="id_maisu" data-app-text="maisu"></label>
                    </td>
                    <td>
                        <input type="text" class="format-thousands-Separator data-app-number" name="su_kowake" style="width: 6em; text-align: right" />
                    </td>
                    <td>
                        <label data-app-text="tani_mai"></label>
                    </td>
                    <td>
                        <label id="id_kbn_seizo" data-app-text="kbn_seizo"></label>
                    </td>
                    <td>
                        <input type="checkbox" id="flg_tanto_seizo" name="flg_tanto_seizo" value="1" data-app-operation="tanto_seizo" />
                        <input type="hidden" name="cd_tanto_seizo" />
                        <label name="nm_tanto_seizo" style="width: 8em"></label>
                        <label id="id_dt_seizo" name="dt_seizo_koshin" style="width: 8em" class="data-app-format" data-app-format="date"></label>
                    </td>
                </tr>
            </tbody>
        </table>
        </div>
        <!-- フッター部分のデザイン -- End -->
    </div>

    <!-- 画面デザイン -- End -->
</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="FooterContent" runat="server">
    <!-- 画面デザイン -- Start -->

    <!-- 画面アーキテクチャ共通のデザイン -- Start -->
    <div class="command" style="left: 1px;">
        <button type="button" class="save-button" name="save-button" data-app-operation="save"><span class="icon"></span><span data-app-text="save"></span></button>
        <button type="button" class="print-button" name="print-button" data-app-operation="print"><span class="icon"></span><span data-app-text="print"></span></button>
        <!-- TODO: 画面の仕様に応じて以下のボタンを変更してください。 -->
        <button type="button" class="clear-button" name="clear-button" data-app-operation="clear"><span class="icon"></span><span data-app-text="clear"></span></button>
        <button type="button" class="deleteHaigo-button" name="deleteHaigo-button" data-app-operation="deleteHaigo"><span data-app-text="deleteHaigo"></span></button>
        <button type="button" class="up-button" name="up-button" data-app-operation="up"><span data-app-text="up"></span></button>
        <button type="button" class="down-button" name="down-button" data-app-operation="down"><span data-app-text="down"></span></button>
        <button type="button" class="detail-button" name="detail" data-app-operation="detail"><span data-app-text="detail"></span></button>
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
    <div class="mark-dialog">
    </div>
    <div class="futai-dialog">
    </div>
    <div class="clear-confirm-dialog" style="display: none;">
        <div class="dialog-header">
            <h4 data-app-text="confirmTitle"></h4>
        </div>
        <div class="dialog-body" style="padding: 10px; width: 100%;">
            <div class="part-body">
                <span data-app-text="clearConfirm"></span>
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
                <span id="id_saveComplete" data-app-text="saveComplete"></span>
            </div>
        </div>
        <div class="dialog-footer">
            <div class="command" style="position: absolute; right: 5px; top: 5px;">
                <button class="dlg-close-button" name="dlg-close-button" data-app-text="close"></button>
            </div>
        </div>
    </div>
    <div class="deleteHan-confirm-dialog" style="display: none;">
        <div class="dialog-header">
            <h4 data-app-text="confirmTitle"></h4>
        </div>
        <div class="dialog-body" style="padding: 10px; width: 100%;">
            <div class="part-body">
                <span data-app-text="deleteHanConfirm"></span>
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
    <div class="deleteAll-confirm-dialog" style="display: none;">
        <div class="dialog-header">
            <h4 data-app-text="confirmTitle"></h4>
        </div>
        <div class="dialog-body" style="padding: 10px; width: 100%;">
            <div class="part-body">
                <span data-app-text="deleteAllConfirm"></span>
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
    <div class="search-confirm-dialog" style="display: none;">
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
    <!-- 計画再立案を促すメッセージダイアログ -->
    <div class="replan-confirm-dialog" style="display: none;">
        <div class="dialog-header">
            <h4 data-app-text="confirmTitle"></h4>
        </div>
        <div class="dialog-body" style="padding: 10px; width: 100%;">
            <div class="part-body">
                <span data-app-text="replanConfirm"></span>
            </div>
        </div>
        <div class="dialog-footer">
            <div class="command" style="position: absolute; right: 5px; top: 5px;">
                <button class="dlg-yes-button" name="dlg-yes-button" data-app-text="yes"></button>
            </div>
        </div>
    </div>
    <!-- TODO: ここまで  -->
    <!-- 画面デザイン -- End -->
</asp:Content>
