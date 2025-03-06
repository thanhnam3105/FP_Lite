<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="SeizoJissekiSentaku.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.SeizoJissekiSentaku" %>

<asp:Content ID="Content1" ContentPlaceHolderID="IncludeContent" runat="server">
    <script src="<%=ResolveUrl("~/Resources/pages/pagedata-seizojissekisentaku." + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
    <script src="<%=ResolveUrl("~/Resources/grid/grid.locale-" + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
    <!-- 業務用の共通処理のロード -->
    <script src="<%=ResolveUrl("~/Scripts/util/app-util.js") %>" type="text/javascript"></script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        /* 画面デザイン -- Start */
        
        /* 画面の仕様に応じて以下のスタイルを変更してください。 */
        .part-body .item-label
        {
            display: inline-block;
        }
        .part-body .total-label
        {
            display: inline-block;
        }
        #result-grid
        {
            padding: 0px;
            overflow: hidden;
        }

        .part-body .item-list-left {
            float: left;
            width: 450px;
        }

        .part-body .item-list-center {
            float: left;
            width: 300px;
        }

        .part-body .item-list-right {
            float: left;
            width: 300px;
        }

        .result-list .item-label
        {
            width: 10em;
        }

        .result-list .total-label
        {
            width: 120px;
        }

        .seizo-dialog
        {
            background-color: White;
            width: 870px;
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
        /* ヘッダー折り返し用の設定：ここまで */
        
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
                isDataLoading = false;

            // 多言語対応　言語によって幅を調節
            $(".result-list .item-label").css("width", pageLangText.each_lang_width.number);

            // 日付の多言語対応
            var dateSrcFormat = pageLangText.dateSrcFormatUS.text;
            var newDateFormat = pageLangText.dateNewFormatUS.text;
            var datePickerFormat = pageLangText.dateFormatUS.text;
            if (App.ui.page.langCountry !== 'en-US') {
                dateSrcFormat = pageLangText.dateSrcFormat.text;
                newDateFormat = pageLangText.dateNewFormat.text;
                datePickerFormat = pageLangText.dateFormat.text;
            }

            // グリッドコントロール固有の変数宣言
            var grid = $("#item-grid"),
                lastScrollTop = 0,
            // 画面の仕様に応じて以下の変数宣言を変更
                changeSet = new App.ui.page.changeSet(),
                firstCol = 1,
                duplicateCol = 999,
                currentRow = 0,
                currentCol = firstCol,
                kbnAnbunCol = 1,
                seizoDateCol = 2,
                kbnHinCol = 3,
                seihinCodeCol = 4,
                seihinNameCol = 5,
                seihinLotCol = 6,
                shiyoRyoCol = 7,
                choseiRiyuCol = 9,
                genkaBushoCol = 11,
                sokoCol = 13,
                kbnDensoCol = 15,
                isChanged = false,
                isAnbun = false,    // true:按分データあり false:按分データなし
                seihinName = 'nm_hinmei_' + App.ui.page.lang,
                recordCount = 0,    // 追加時のチェック用
            // プルダウンの値取得用
                anbunCombox = pageLangText.anbunKubunId.data,
                riyuCombox,
                genkaCombox,
                sokoCombox;
            var errRows = new Array();   // エラー行の格納用

            // ヘッダー：前画面情報
            var header = {
                "dt_shikomi": ""
                , "cd_haigo": ""
                , "nm_haigo": ""
                , "no_lot_shikakari": ""
                , "batch": 0
                , "batch_hasu": 0
                , "wt_shikomi": 0
                , "bairitsu": 0
                , "bairitsu_hasu": 0
                , "shokuba": ""
                , "line": ""
                // ↓trunkにしかない項目だが、いちおう入れておく(2015.06.29)
                , "kakutei": "0"
                , "mikakutei": "0"
            };

            // 按分区分を「調整」にしたときに設定する初期値
            var initData = {
                "cd_riyu": ""
                , "nm_riyu": ""
                , "cd_genka": ""
                , "nm_genka": ""
                , "cd_soko": ""
                , "nm_soko": ""
            };

            // セレクタ：製造検索
            var seizoDialog = $(".seizo-dialog");
            seizoDialog.dlg({
                url: "Dialog/SeizoJissekiSentakuDialog.aspx",
                name: "SeizoJissekiSentakuDialog",
                closed: function (e, data, data2) {
                    App.ui.loading.close();
                    if (data == "canceled") {
                        return;
                    }
                    else {
                        var selectedRowId = getSelectedRowId();
                        // 選択値をセット
                        grid.setCell(selectedRowId, "cd_hinmei", data.cd_hinmei);
                        grid.setCell(selectedRowId, seihinName, data.nm_hinmei);
                        grid.setCell(selectedRowId, "dt_shiyo_shikakari", data.dt_seizo);
                        grid.setCell(selectedRowId, "no_lot_seihin", data.no_lot);
                        grid.setCell(selectedRowId, "kbn_hin", data.kbn_hin);
                        grid.setCell(selectedRowId, "nm_kbn_hin", data.nm_kbn_hin);
                        grid.setCell(selectedRowId, "flg_testitem", data.flg_testitem);

                        //対象セルの背景をリセット
                        grid.setCell(selectedRowId, "kbn_shiyo_jisseki_anbun", '', { background: 'none' });
                        saveEdit();
                        // セルバリデーション実行
                        validateCell(selectedRowId, "dt_shiyo_shikakari", data.dt_seizo, seizoDateCol);
                        // 関連項目の設定
                        var changeData = setUpdatedChangeData(grid.getRowData(selectedRowId));
                        setRelatedChangeData(selectedRowId, "cd_seihin", data, changeData);
                    }
                }
            });
            /// <summary>製造検索ダイアログをオープンする</summary>
            var openSeizoDlg = function () {
                App.ui.page.notifyInfo.clear();
                App.ui.page.notifyAlert.clear();

                // 按分区分のチェック
                var rowId = getSelectedRowId();
                var anbunKbn = grid.getCell(rowId, "kbn_shiyo_jisseki_anbun");
                //「調整」の場合：処理中止
                if (anbunKbn == pageLangText.shiyoJissekiAnbunKubunChosei.text) {
                    App.ui.page.notifyAlert.message(MS0751).show();
                    return;
                }
                //「残」の場合：処理中止
                if (anbunKbn == pageLangText.shiyoJissekiAnbunKubunZan.text) {
                    App.ui.page.notifyAlert.message(MS0780).show();
                    return;
                }

                App.ui.loading.show(pageLangText.openDialog.text);
                saveEdit();
                var option = { id: 'seizo', multiselect: false, param1: header.cd_haigo, param2: header.nm_haigo };
                seizoDialog.draggable(true);
                seizoDialog.dlg("open", option);
            };

            /// <summary>グリッドのコンボボックス列のformatterに指定してください</summary>
            /// <param name="celldata">セルデータ</param>
            /// <param name="options">オプション</param>
            /// <param name="rowobject">行オブジェクト</param>
            var fn_formatValue = function (celldata, options, rowobject) {
                showdata = options.colModel.editoptions.value()[celldata];
                return $(document.createElement('span')).attr('original-value', celldata).text(showdata)[0].outerHTML;
            };
            var fn_unformatValue = function (celldata, options, cellobject) {
                return $(cellobject).children('span').attr('original-value');
            };

            /// <summary>スラッシュなし日付(例：20150625)にスラッシュを付与</summary>
            /// <param name="date">値</param>
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

            /// <summary>urlよりパラメーターを取得</summary>
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

                // ヘッダー情報を変数に格納
                header.no_lot_shikakari = App.ifUndefOrNull(parameters["no_lot_shikakari"], "")
                , header.cd_haigo = App.ifUndefOrNull(parameters["cd_hinmei"], "")
                , header.nm_haigo = decodeURIComponent(parameters["nm_hinmei"])
                , header.dt_shikomi = attachedDateSlash(parameters["dt_shikomi"])
                , header.dt_shikomi_st = attachedDateSlash(parameters["dt_shikomi_st"])
                , header.dt_shikomi_en = attachedDateSlash(parameters["dt_shikomi_en"])
                , header.shokuba = App.ifUndefOrNull(parameters["cd_shokuba"], "")
                , header.line = App.ifUndefOrNull(parameters["cd_line"], "")
                // 伝送状況チェックボックス
                , header.chk_mi_sakusei = App.ifUndefOrNull(parameters["chk_mi_sakusei"], "")
                , header.chk_mi_denso = App.ifUndefOrNull(parameters["chk_mi_denso"], "")
                , header.chk_denso_machi = App.ifUndefOrNull(parameters["chk_denso_machi"], "")
                , header.chk_denso_zumi = App.ifUndefOrNull(parameters["chk_denso_zumi"], "")
                // 登録状況チェックボックス
                , header.chk_mi_toroku = App.ifUndefOrNull(parameters["chk_mi_toroku"], "") 
                , header.chk_ichibu_mi_toroku = App.ifUndefOrNull(parameters["chk_ichibu_mi_toroku"], "")
                , header.chk_toroku_sumi = App.ifUndefOrNull(parameters["chk_toroku_sumi"], "") 

                , header.batch = App.ifUndefOrNull(parameters["batch"], 0)
                , header.batch_hasu = App.ifUndefOrNull(parameters["batchHasu"], 0)
                , header.wt_shikomi = App.ifUndefOrNull(parameters["suShikomi"], 0)
                , header.bairitsu = App.ifUndefOrNull(parameters["bairitsu"], 0)
                , header.bairitsu_hasu = App.ifUndefOrNull(parameters["bairitsuHasu"], 0)                    
                , header.kakutei = App.ifUndefOrNull(parameters["kakutei"], "")
                , header.mikakutei = App.ifUndefOrNull(parameters["mikakutei"], "");

                // ヘッダー情報をヘッダーに設定
                $("#dt_shikomi").text(header.dt_shikomi);
                $("#cd_haigo").text(header.cd_haigo);
                $("#nm_haigo").text(header.nm_haigo);
                $("#no_lot_shikakari").text(header.no_lot_shikakari);
                $("#batch").text(setThousandsSeparator(header.batch));
                $("#batch_hasu").text(setThousandsSeparator(header.batch_hasu));
                $("#wt_shikomi").text(setThousandsSeparator(header.wt_shikomi));
                $("#bairitsu").text(setThousandsSeparator(header.bairitsu));
                $("#bairitsu_hasu").text(setThousandsSeparator(header.bairitsu_hasu));
            };
            getParameters();

            /// <summary>時間を省いたシステム日付を日付オブジェクトで取得する</summary>
            var getSystemDate = function () {
                var sysdate = new Date(new Date().getFullYear(), new Date().getMonth(), new Date().getDate());
                return sysdate;
            };

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
            var saveConfirmDialog = $(".save-confirm-dialog"),
                saveCompleteDialog = $(".save-complete-dialog");

            //// 変数宣言 -- End

            //// コントロール定義 -- Start

            // ダイアログ固有のコントロール定義
            saveConfirmDialog.dlg();
            saveCompleteDialog.dlg();

            /// <summary>ダイアログを開きます。</summary>
            // 保存確認
            var showSaveConfirmDialog = function () {
                saveConfirmDialogNotifyInfo.clear();
                saveConfirmDialogNotifyAlert.clear();
                saveConfirmDialog.draggable(true);
                saveConfirmDialog.dlg("open");
            };
            // 保存完了
            var showSaveCompleteDialog = function () {
                saveCompleteDialogNotifyInfo.clear();
                saveCompleteDialogNotifyAlert.clear();
                saveCompleteDialog.draggable(true);
                saveCompleteDialog.dlg("open");
            };

            /// <summary>ダイアログを閉じます。</summary>
            // 保存確認
            var closeSaveConfirmDialog = function () {
                saveConfirmDialog.dlg("close");
            };
            // 保存完了
            var closeSaveCompleteDialog = function () {
                saveCompleteDialog.dlg("close");
            };

            /// <summary>afterSaveCell</summary>
            /// <param name="selectedRowId">選択行ID</param>
            /// <param name="cellName">列名</param>
            /// <param name="value">元となる項目の値</param>
            /// <param name="iRow">項目の行番号</param>
            /// <param name="iCol">項目の列番号</param>
            var fncAfterSaveCell = function (selectedRowId, cellName, value, iRow, iCol) {
                // 関連項目の設定
                setRelatedValue(selectedRowId, cellName, value, iCol);

                var targetCell = cellName;

                // プルダウン系の場合は更新先が変わる
                if (cellName == "nm_riyu") {
                    targetCell = "cd_riyu";
                }
                else if (cellName == "nm_genka_center") {
                    targetCell = "cd_genka_center";
                }
                else if (cellName == "nm_soko") {
                    targetCell = "cd_soko";
                }
                // 一度gridに変更値をセット
                grid.setCell(selectedRowId, targetCell, value);

                var changeData;
                if (grid.jqGrid('getCell', selectedRowId, 'no_seq')) {
                    /// 更新
                    // 更新状態の変更データの設定
                    changeData = setUpdatedChangeData(grid.getRowData(selectedRowId));
                    // 更新状態の変更セットに変更データを追加
                    changeSet.addUpdated(selectedRowId, targetCell, changeData[targetCell], changeData);
                }
                else {
                    /// 新規
                    // 追加状態のデータ設定
                    changeData = setCreatedChangeData(grid.getRowData(selectedRowId));
                    // 追加状態の変更セットに変更データを追加
                    changeSet.addCreated(selectedRowId, changeData);
                }
                // 更新状態の変更データの設定
                //var changeData = setUpdatedChangeData(grid.getRowData(selectedRowId));
                // 更新状態の変更セットに変更データを追加
                //changeSet.addUpdated(selectedRowId, targetCell, value, changeData);

                if (cellName === "kbn_shiyo_jisseki_anbun") {
                    //使用実績按分区分変更時、明細の更新
                    setRelatedChangeAllData(selectedRowId, cellName, value, changeData);
                    //合計差異の計算
                    setRelatedValue(selectedRowId, "su_shiyo_shikakari", changeData.su_shiyo_shikakari, iCol);
                }

                // 変更フラグをセット
                isChanged = true;
            };

            // グリッドコントロール固有のコントロール定義
            grid.jqGrid({
                colNames: [
                    pageLangText.kbn_anbun.text
                    , pageLangText.dt_seizo.text + pageLangText.requiredMark.text
                    , pageLangText.kbn_hin.text
                    , pageLangText.cd_seihin.text
                    , pageLangText.nm_seihin.text
                    , pageLangText.no_lot_seihin.text
                    , pageLangText.wt_shikakari_shiyo.text + pageLangText.requiredMark.text
                    , pageLangText.chosei_riyu.text
                    , pageLangText.chosei_riyu.text
                    , pageLangText.genka_busho.text
                    , pageLangText.genka_busho.text
                    , pageLangText.soko.text
                    , pageLangText.soko.text
                    , pageLangText.kbn_denso.text
                    , pageLangText.kbn_denso.text
                    , pageLangText.kbn_hin.text
                    , "no_seq"
                    , "ts"
                    , "con_kbn_shiyo_jisseki_anbun"
                    , "con_no_lot_seihin"
                    , "flg_testitem"
                ],
                colModel: [
                    { name: 'kbn_shiyo_jisseki_anbun', width: pageLangText.kbn_anbun_width.number, sortable: false, editable: true, hidden: false, edittype: 'select',
                        editoptions: {
                            value: function () {
                                // グリッド内のドロップダウンの生成
                                return grid.prepareDropdown(anbunCombox, "name", "id");
                            }
                        }, formatter: fn_formatValue, unformat: fn_unformatValue
                    },
                    { name: 'dt_shiyo_shikakari', width: pageLangText.dt_seizo_width.number, editable: true, sorttype: "text", align: "center",
                        formatter: "date",
                        formatoptions: { srcformat: dateSrcFormat, newformat: newDateFormat },
                        editoptions: {
                            dataInit: function (el) {
                                $(el).on("keyup", App.data.addSlashForDateString);
                                $(el).datepicker({ dateFormat: datePickerFormat
                                , onClose: function (dateText, inst) {
                                    // カレンダーを閉じた後は他のセルにフォーカスを当てる
                                    // ＃セルの見た目が編集状態のままとなっている為、tabなどでセル移動できそうで紛らわしい
                                    var idNum = grid.getGridParam("selrow");
                                    $("#" + idNum + " td:eq('" + (kbnHinCol) + "')").click();
                                }
                                });
                            }
                        },
                        unformat: unformatDate
                    },
                    { name: 'nm_kbn_hin', width: pageLangText.kbn_hin_width.number, sortable: "text", editable: false },
                    { name: 'cd_hinmei', width: pageLangText.cd_seihin_width.number, sortable: "text", editable: false },
                    { name: seihinName, width: pageLangText.nm_seihin_width.number, sortable: "text", editable: false },
                    { name: 'no_lot_seihin', width: pageLangText.no_lot_seihin_width.number, sortable: "text", editable: false },
                    { name: 'su_shiyo_shikakari', width: pageLangText.wt_shikakari_shiyo_width.number, sortable: false, editable: true, resizable: false, align: 'right',
                        formatter: 'number',
                        formatoptions: {
                            //decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 6, defaultValue: "0.000000"
                            decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 3, defaultValue: "0.000"
                        }
                    },
                    { name: 'cd_riyu', width: 0, hidden: true, hidedlg: true },
                    { name: 'nm_riyu', width: pageLangText.chosei_riyu_width.number, sortable: "text", editable: true, edittype: 'select',
                        editoptions: {
                            value: function () {
                                // グリッド内のドロップダウンの生成
                                return grid.prepareDropdown(riyuCombox, "nm_riyu", "cd_riyu");
                            }
                        }//, formatter: fn_formatValue, unformat: fn_unformatValue
                    },
                    { name: 'cd_genka_center', width: 0, hidden: true, hidedlg: true },
                    { name: 'nm_genka_center', width: pageLangText.genka_busho_width.number, sortable: "text", editable: true, edittype: 'select',
                        editoptions: {
                            value: function () {
                                // グリッド内のドロップダウンの生成
                                return grid.prepareDropdown(genkaCombox, "nm_genka_center", "cd_genka_center");
                            }
                        }//, formatter: fn_formatValue, unformat: fn_unformatValue
                    },
                    { name: 'cd_soko', width: 0, hidden: true, hidedlg: true },
                    { name: 'nm_soko', width: pageLangText.soko_width.number, sortable: "text", editable: true, edittype: 'select',
                        hidden: true, hidedlg: true,
                        editoptions: {
                            value: function () {
                                // グリッド内のドロップダウンの生成
                                return grid.prepareDropdown(sokoCombox, "nm_soko", "cd_soko");
                            }
                        }//, formatter: fn_formatValue, unformat: fn_unformatValue
                    },
                    { name: 'kbn_jotai_denso', width: 0, hidden: true, hidedlg: true },
                    { name: 'kbn_denso', width: pageLangText.kbn_denso_width.number, editable: false, sorttype: "text", formatter: getDensoJotai },
                    { name: 'kbn_hin', width: 0, hidden: true, hidedlg: true },
                    { name: 'no_seq', width: 0, hidden: true, hidedlg: true },
                    { name: 'ts', width: 0, hidden: true, hidedlg: true },
                    { name: 'con_kbn_shiyo_jisseki_anbun', width: 0, hidden: true, hidedlg: true },
                    { name: 'con_no_lot_seihin', width: 0, hidden: true, hidedlg: true },
                    { name: 'flg_testitem', width: 0, hidden: true, hidedlg: true}
                ],
                datatype: "local",
                shrinkToFit: false,
                multiselect: false,
                rownumbers: true,
                hoverrows: false,
                cellEdit: true,
                cellsubmit: 'clientArray',
                footerrow: false,
                loadComplete: function () {
                    // データなし検索の場合、検索結果をchangeSetへ設定する
                    var ids = grid.jqGrid('getDataIDs');
                    for (var i = 0; i < ids.length; i++) {
                        var id = ids[i];

                        if (!isAnbun) {
                            // 按分データがない場合：changeSetへの設定処理
                            setGridDataCreated(id);
                            isChanged = true;
                        }
                        // 制御処理
                        ctrlGridAnbunKubun(id);
                    }

                    // グリッドの先頭行選択
                    // loadCompleteに記述しないとグリッドのソートで先頭行が選択されない
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
                },
                beforeSaveCell: function (selectedRowId, cellName, value, iRow, iCol) {
                    // カーソルを移動
                    grid.moveAnyCell(cellName, iRow, iCol);
                    // セルバリデーション
                    validateCell(selectedRowId, cellName, value, iCol);
                },
                afterSaveCell: function (selectedRowId, cellName, value, iRow, iCol) {
                    fncAfterSaveCell(selectedRowId, cellName, value, iRow, iCol);
                },
                onCellSelect: function (rowid, icol, cellcontent) {
                    selectCol = icol;
                },
                ondblClickRow: function (rowid) {
                    // 製造検索
                    if (selectCol === seihinCodeCol || selectCol === seihinNameCol) {
                        // 権限による制御
                        var roles = App.ui.page.user.Roles[0];
                        if (roles == pageLangText.admin.text || roles == pageLangText.manufacture.text || roles == pageLangText.purchase.text) {
                            openSeizoDlg();
                        }
                    }
                }
            });

            /// <summary>日付型のセルをunformatします</summary>
            /// <param name="cellvalue">値</param>
            /// <param name="options">セルのオプション</param>
            function unformatDate(cellvalue, options) {
                var nbsp = String.fromCharCode(160);
                if (cellvalue == nbsp) {
                    return "";
                }
                return cellvalue;
            }

            /// <summary>伝送状態区分による表示名称を取得</summary>
            /// <param name="cellvalue">ステータス区分</param>
            /// <param name="options">オプション</param>
            /// <param name="rowObject">行情報</param>
            function getDensoJotai(cellvalue, options, rowObject) {
                var kbn = pageLangText.densoJotaiKbnMidenso.text; // デフォルト：未伝送
                var ret = "",
                    value = rowObject.kbn_jotai_denso;

                if (!App.isUndefOrNull(value) && value !== "") {
                    kbn = value;
                }
                ret = App.str.format(pageLangText.densoJotaiId.data[kbn].name);
                return ret;
            }

            /// <summary>関連情報のクリア</summary>
            /// <param name="selectedRowId">選択行ID</param>
            var meisaiClear = function (selectedRowId) {
                var kbn = grid.getCell(selectedRowId, "kbn_shiyo_jisseki_anbun");

                grid.setCell(selectedRowId, "dt_shiyo_shikakari", null);
                grid.setCell(selectedRowId, "nm_kbn_hin", null);
                grid.setCell(selectedRowId, "cd_hinmei", null);
                grid.setCell(selectedRowId, seihinName, null);
                grid.setCell(selectedRowId, "no_lot_seihin", null);
                grid.setCell(selectedRowId, "su_shiyo_shikakari", 0);
                grid.setCell(selectedRowId, "flg_testitem", null);

                // 按分区分を「調整」に変更した場合、調整理由、原価発生部署、倉庫に初期値を設定する
                if (kbn == pageLangText.shiyoJissekiAnbunKubunChosei.text) {
                    grid.setCell(selectedRowId, "cd_riyu", initData.cd_riyu);
                    grid.setCell(selectedRowId, "nm_riyu", initData.nm_riyu);
                    grid.setCell(selectedRowId, "cd_genka_center", initData.cd_genka);
                    grid.setCell(selectedRowId, "nm_genka_center", initData.nm_genka);
                    //grid.setCell(selectedRowId, "cd_soko", initData.cd_soko);
                    //grid.setCell(selectedRowId, "nm_soko", initData.nm_soko);
                }
                else {
                    grid.setCell(selectedRowId, "cd_riyu", null);
                    grid.setCell(selectedRowId, "nm_riyu", null);
                    grid.setCell(selectedRowId, "cd_genka_center", null);
                    grid.setCell(selectedRowId, "nm_genka_center", null);
                    //grid.setCell(selectedRowId, "cd_soko", null);
                    //grid.setCell(selectedRowId, "nm_soko", null);
                }
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

            /// <summary> 仕掛品使用量の明細合計を計算します。</summary>
            var calcMeisaiGokei = function () {
                var ids = grid.jqGrid('getDataIDs'),
                    meisaiGokeiHyoji = 0;
                //var KANZAN = parseInt(1000000); // 小数点以下6桁なので1000000倍
                var KANZAN = parseInt(1000); // 小数点以下3桁なので1000倍

                for (var i = 0; i < ids.length; i++) {
                    var id = ids[i];

                    // 小数点のまま計算すると結果がおかしなことになるため、一度小数点を除いてから計算する
                    var su_shiyo = parseFloat(grid.getCell(id, "su_shiyo_shikakari"));
                    su_shiyo = App.data.trimFixed(su_shiyo * KANZAN);

                    meisaiGokeiHyoji = App.data.trimFixed(meisaiGokeiHyoji + su_shiyo);
                }
                //// 1000000で割って小数点の位置を戻す
                // 1000で割って小数点の位置を戻す
                meisaiGokeiHyoji = App.data.trimFixed(meisaiGokeiHyoji / KANZAN);

                return parseFloat(meisaiGokeiHyoji);
            };

            /// <summary>セルの関連項目を設定します。</summary>
            /// <param name="selectedRowId">選択行ID</param>
            /// <param name="cellName">列名</param>
            /// <param name="value">元となる項目の値</param>
            /// <param name="iCol">項目の列番号</param>
            var setRelatedValue = function (selectedRowId, cellName, value, iCol) {
                var elementName,
                    serviceUrl,
                    codeName;

                // 使用実績按分区分
                if (cellName === "kbn_shiyo_jisseki_anbun") {
                    // 変更時は明細をクリアする
                    meisaiClear(selectedRowId);

                    searchHinMaster(selectedRowId, value);
                    // 項目の制御処理
                    ctrlGridAnbunKubun(selectedRowId);
                }

                // 仕掛品使用量
                if (cellName === "su_shiyo_shikakari") {
                    // 明細合計と合計差異を計算する
                    var meisaiGokei = calcMeisaiGokei(),
                        gokeiSai = 0;

                    // 小数点のまま計算すると結果がおかしなことになるため、一度小数点を除いてから計算する
                    //var KANZAN = parseInt(1000000); // 小数点以下6桁なので1000000倍
                    var KANZAN = parseInt(1000); // 小数点以下3桁なので1000倍
                    var h_shikomi = App.data.trimFixed(parseFloat(header.wt_shikomi) * KANZAN);
                    var m_gokei = App.data.trimFixed(meisaiGokei * KANZAN);

                    gokeiSai = App.data.trimFixed(h_shikomi - m_gokei);

                    //// 1000000で割って小数点の位置を戻す
                    // 1000で割って小数点の位置を戻す
                    gokeiSai = App.data.trimFixed(gokeiSai / KANZAN);

                    if (gokeiSai != 0) {
                        // 差異があれば赤字
                        $("#gokei_sai").css("color", "#ff6666");
                    }
                    else {
                        // 差異がなければ黒字
                        $("#gokei_sai").css("color", "#000000");
                    }

                    // 0埋め処理 toFixed：収まらない場合は四捨五入される
                    //var fixVal = 6;
                    var fixVal = 3;
                    meisaiGokei = meisaiGokei.toFixed(fixVal);
                    gokeiSai = gokeiSai.toFixed(fixVal);

                    $("#meisai_gokei").text(setThousandsSeparator(meisaiGokei));
                    $("#gokei_sai").text(setThousandsSeparator(gokeiSai));
                }
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
                showColumnSettingDialog(e);
            });

            /// 内部エラーで変えた行の背景色をクリアする
            /// <param name="errIds">対象行のID配列</param>
            var clearErrBgcorror = function (errIds) {
                for (var i = 0; i < errIds.length; i++) {
                    var id = errIds[i];
                    // 対象セルの背景リセット
                    grid.setCell(id, seihinLotCol, '', { background: 'none' });
                }
            };

            //// コントロール定義 -- End

            //// 操作制御定義 -- Start

            // 操作制御定義を定義します。
            App.ui.pagedata.operation.applySetting(App.ui.page.user.Roles[0], App.ui.page.lang);

            /// <summary>按分区分による項目の制御</summary>
            /// <param name="rowId">選択行ID</param>
            var ctrlGridAnbunKubun = function (rowId) {
                var rowData = grid.getRowData(rowId);
                var kbn = rowData.kbn_shiyo_jisseki_anbun;

                // 按分区分が調整の場合、明細の日付、調整理由、原価発生部署、倉庫を操作可能とする
                if (kbn == pageLangText.shiyoJissekiAnbunKubunChosei.text) {
                    grid.deleteColumnClass(rowId, 'dt_shiyo_shikakari', 'not-editable-cell');
                    grid.deleteColumnClass(rowId, 'nm_riyu', 'not-editable-cell');
                    grid.deleteColumnClass(rowId, 'nm_genka_center', 'not-editable-cell');
                    //grid.deleteColumnClass(rowId, 'nm_soko', 'not-editable-cell');
                }
                else {
                    grid.jqGrid('setCell', rowId, 'dt_shiyo_shikakari', '', 'not-editable-cell');
                    grid.jqGrid('setCell', rowId, 'nm_riyu', '', 'not-editable-cell');
                    grid.jqGrid('setCell', rowId, 'nm_genka_center', '', 'not-editable-cell');
                    //grid.jqGrid('setCell', rowId, 'nm_soko', '', 'not-editable-cell');
                }
            };

            //// 操作制御定義 -- End

            //// 事前データロード -- Start

            // 画面アーキテクチャ共通の事前データロード
            App.deferred.parallel({
                loading: App.ui.loading.show(pageLangText.nowProgressing.text),
                // 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
//                riyuCombox: App.ajax.webget("../Services/FoodProcsService.svc/ma_riyu?$filter=kbn_bunrui_riyu eq " + pageLangText.choseiRiyuKbn.text + "&$orderby=cd_riyu"),  //20230724 DEL
                riyuCombox: App.ajax.webget("../Services/FoodProcsService.svc/ma_riyu?$filter=kbn_bunrui_riyu eq " + pageLangText.choseiRiyuKbn.text + "and cd_riyu ne '" + 161 + "' &$orderby=cd_riyu"),    //20230724 ADD
                genkaCombox: App.ajax.webget("../Services/FoodProcsService.svc/ma_genka_center?$filter=flg_mishiyo eq " + pageLangText.falseFlg.text + "&$orderby=cd_genka_center"),
                sokoCombox: App.ajax.webget("../Services/FoodProcsService.svc/ma_soko?$filter=flg_mishiyo eq " + pageLangText.falseFlg.text + "&$orderby=cd_soko")
            }).done(function (result) {
                /// サービス呼び出し成功
                riyuCombox = result.successes.riyuCombox.d;
                genkaCombox = result.successes.genkaCombox.d;
                sokoCombox = result.successes.sokoCombox.d;

                // 初期値用にinitDataへ設定
                if (riyuCombox.length > 0) {
                    initData.cd_riyu = riyuCombox[0].cd_riyu;
                    initData.nm_riyu = riyuCombox[0].nm_riyu;
                }
                if (genkaCombox.length > 0) {
                    //initData.cd_genka = genkaCombox[0].cd_genka_center;
                    //initData.nm_genka = genkaCombox[0].nm_genka_center;
                    var genkaDefault = app_util.prototype.getDefaultGenkaBusho(genkaCombox);
                    initData.cd_genka = genkaDefault.cd_genka_center;
                    initData.nm_genka = genkaDefault.nm_genka_center;
                }
                if (sokoCombox.length > 0) {
                    initData.cd_soko = sokoCombox[0].cd_soko;
                    initData.nm_soko = sokoCombox[0].nm_soko;
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
            }).always(function () {
                /// 初期表示：検索処理
                initialDisp();
            });

            //// 事前データロード -- End

            //// 検索処理 -- Start

            /// <summary>初期表示処理</summary>
            var initialDisp = function () {
                //App.ui.loading.show(pageLangText.nowProgressing.text);

                // データ存在チェック：使用予実按分トランに入力データが存在するかどうか
                var _query = {
                    url: "../Services/FoodProcsService.svc/tr_sap_shiyo_yojitsu_anbun",
                    filter: "no_lot_shikakari eq '" + header.no_lot_shikakari + "'",
                    top: 1
                };
                App.ajax.webgetSync(
                    App.data.toODataFormat(_query)
                ).done(function (result) {
                    // サービス呼び出し成功時の処理
                    if (result.d.length > 0) {
                        // データが存在する場合：使用予実按分トランを基に明細情報を取得する
                        isAnbun = true;
                        searchItemsExistData();
                    }
                    else {
                        // データが存在しない場合：製品計画トランを基に按分計算を行い、明細情報を取得する
                        isAnbun = false;
                        searchItemsNoData();

                    }
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                });
            };
            /// <summary>使用予実按分トランを基に明細情報を取得する</summary>
            var searchItemsExistData = function () {
                var query = {
                    url: "../Services/FoodProcsService.svc/vw_tr_sap_shiyo_yojitsu_anbun_01",
                    filter: "no_lot_shikakari eq '" + header.no_lot_shikakari
                        + "' and (kbn_shiyo_jisseki_anbun eq '" + pageLangText.shiyoJissekiAnbunKubunSeizo.text
                        + "' or kbn_shiyo_jisseki_anbun eq '" + pageLangText.shiyoJissekiAnbunKubunZan.text
                        + "' or kbn_bunrui_riyu eq " + pageLangText.choseiRiyuKbn.text + ")",
                    orderby: "kbn_hin, kbn_jotai_denso, cd_hinmei",
                    //top: querySetting.top,
                    inlinecount: "allpages"
                };

                App.ajax.webget(
                    App.data.toODataFormat(query)
                ).done(function (result) {
                    // データバインド
                    bindData(result, true);
                    $(".ui-jqgrid-hdiv").scrollLeft(0); // 明細のスクロール位置をリセット
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                }).always(function () {
                    setTimeout(function () {
                        $("#list-loading-message").text("");
                        isDataLoading = false;
                    }, 500);
                    // ローディングの終了
                    App.ui.loading.close();
                });
            };
            /// <summary>製品計画トランを基に按分計算を行い、明細情報を取得する</summary>
            var searchItemsNoData = function () {
                var queryNoData = {
                    url: "../api/SeizoJissekiSentaku",
                    dt_shikomi: App.data.getDateTimeStringForQueryNoUtc(App.date.localDate(header.dt_shikomi)),
                    cd_haigo: header.cd_haigo,
                    su_shikomi: header.wt_shikomi,
                    kbn_jotai_denso: pageLangText.densoJotaiKbnMidenso.text,
                    kbn_anbun_seizo: pageLangText.shiyoJissekiAnbunKubunSeizo.text,
                    no_lot_shikakari:header.no_lot_shikakari,
                    top: querySetting.top
                };

                App.ajax.webget(
                   App.data.toWebAPIFormat(queryNoData)
                ).done(function (result) {
                    // データバインド
                    bindData(result, false);
                    $(".ui-jqgrid-hdiv").scrollLeft(0); // 明細のスクロール位置をリセット
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                }).always(function () {
                    setTimeout(function () {
                        $("#list-loading-message").text("");
                        isDataLoading = false;
                    }, 500);
                    // ローディングの終了
                    App.ui.loading.close();
                });
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

                // 画面の仕様に応じて以下のパラメータ設定を変更してください。
                currentRow = 0;
                currentCol = firstCol;

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
            /// <param name="isAnbunData">按分トランデータが存在するかどうか</param>
            var bindData = function (result, isAnbunData) {
                var bindData,
                    cntSkip = 0,
                    cntData = 0;

                // view検索とSP検索でresultの中身が変わるので、処理を分岐する
                if (isAnbunData) {
                    // 按分トランデータが存在する場合(view)
                    cntSkip = querySetting.skip + result.d.results.length;
                    cntData = parseInt(result.d.__count);
                    recordCount = cntData;
                    bindData = result.d.results;
                }
                else {
                    // 按分トランデータが存在しなかった場合(SP)
                    cntData = parseInt(result.__count);
                    cntSkip = querySetting.skip + cntData;
                    bindData = result.d;
                }

                querySetting.skip = cntSkip;
                querySetting.count = cntData;

                // グリッドの表示件数を更新
                grid.setGridParam({ rowNum: querySetting.skip });
                displayCount(querySetting.count, querySetting.count);

                // データバインド
                var currentData = grid.getGridParam("data").concat(bindData);
                grid.setGridParam({ data: currentData }).trigger('reloadGrid', [{ current: true}]);

                if (querySetting.count <= 0) {
                    // 検索結果0件
                    App.ui.page.notifyAlert.message(pageLangText.notFound.text).show();
                }
                else if (querySetting.count > querySetting.top) {
                    // 検索結果が上限数を超えた場合
                    App.ui.page.notifyInfo.message(
                    App.str.format(MS0624, querySetting.count, querySetting.top)).show();
                    querySetting.count = querySetting.top;
                }
                else {
                    // 該当件数の表示
                    App.ui.page.notifyInfo.message(
                        App.str.format(pageLangText.searchResultCount.text, querySetting.skip, querySetting.count)
                    ).show();
                }

                // 明細合計と合計差異の設定
                setRelatedValue(0, "su_shiyo_shikakari", 0, shiyoRyoCol);
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
            };
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

            /// ダイアログ固有のメッセージ表示

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

            /// <summary>新規行データの設定を行います。</summary>
            var setAddData = function () {
                var addData = {
                    "kbn_shiyo_jisseki_anbun": pageLangText.shiyoJissekiAnbunKubunSeizo.text
                    , "dt_shiyo_shikakari": ""
                    , "nm_kbn_hin": ""
                    , "cd_hinmei": ""
                    , "no_lot_shikakari": header.no_lot_shikakari
                    , "no_lot_seihin": ""
                    , "su_shiyo_shikakari": 0
                    , "cd_riyu": ""
                    , "nm_riyu": ""
                    , "cd_genka_center": ""
                    , "nm_genka_center": ""
                    , "cd_soko": null
                    , "nm_soko": null
                    , "kbn_jotai_denso": pageLangText.densoJotaiKbnMidenso.text
                    , "kbn_denso": ""
                    , "no_seq": ""
                    , "recordCount": recordCount
                };

                return addData;
            };

            /// <summary>追加状態の変更セットに追加する変更データの設定を行います。</summary>
            /// <param name="newRow">新規行データ</param>
            var setCreatedChangeData = function (newRow) {
                // 画面の仕様に応じて以下の項目を変更してください。
                var dtShiyo = newRow.dt_shiyo_shikakari == "" ? "" : App.data.getDateTimeStringForQueryNoUtc(App.date.localDate(newRow.dt_shiyo_shikakari));

                var changeData = {
                    "kbn_shiyo_jisseki_anbun": newRow.kbn_shiyo_jisseki_anbun
                    , "dt_shiyo_shikakari": dtShiyo
                    , "nm_kbn_hin": newRow.nm_kbn_hin
                    , "cd_hinmei": newRow.cd_hinmei
                    , "no_lot_shikakari": header.no_lot_shikakari
                    , "no_lot_seihin": newRow.no_lot_seihin
                    , "su_shiyo_shikakari": newRow.su_shiyo_shikakari
                    , "cd_riyu": newRow.cd_riyu
                    , "nm_riyu": newRow.nm_riyu
                    , "cd_genka_center": newRow.cd_genka_center
                    , "nm_genka_center": newRow.nm_genka_center
                    //, "cd_soko": newRow.cd_soko
                    //, "nm_soko": newRow.nm_soko
                    , "cd_soko": null
                    , "nm_soko": null
                    , "kbn_jotai_denso": newRow.kbn_jotai_denso
                    //, "kbn_denso": newRow.kbn_denso
                    //, "no_seq": newRow.no_seq
                    , "recordCount": recordCount
                    , "cd_haigo": header.cd_haigo
                };
                // ここまで

                return changeData;
            };

            /// <summary>更新状態の変更セットに追加する変更データの設定を行います。</summary>
            /// <param name="row">選択行</param>
            var setUpdatedChangeData = function (row) {
                // 画面の仕様に応じて以下の項目を変更してください。
                var dtShiyo = row.dt_shiyo_shikakari == "" ? "" : App.data.getDateTimeStringForQueryNoUtc(App.date.localDate(row.dt_shiyo_shikakari));

                var changeData = {
                    "kbn_shiyo_jisseki_anbun": row.kbn_shiyo_jisseki_anbun
                    , "dt_shiyo_shikakari": dtShiyo
                    , "nm_kbn_hin": row.nm_kbn_hin
                    , "cd_hinmei": row.cd_hinmei
                    , "no_lot_shikakari": header.no_lot_shikakari
                    , "no_lot_seihin": row.no_lot_seihin
                    , "su_shiyo_shikakari": row.su_shiyo_shikakari
                    , "cd_riyu": row.cd_riyu
                    , "nm_riyu": row.nm_riyu
                    , "cd_genka_center": row.cd_genka_center
                    , "nm_genka_center": row.nm_genka_center
                    //, "cd_soko": row.cd_soko
                    //, "nm_soko": row.nm_soko
                    , "cd_soko": null
                    , "nm_soko": null
                    //, "kbn_jotai_denso": row.kbn_jotai_denso
                    , "kbn_jotai_denso": pageLangText.densoJotaiKbnMidenso.text
                    //, "kbn_denso": row.kbn_denso
                    , "no_seq": row.no_seq
                    , "ts": row.ts
                    , "recordCount": recordCount
                    , "cd_haigo": header.cd_haigo
                    , "con_no_lot_seihin": row.con_no_lot_seihin
                };
                // ここまで

                return changeData;
            };

            /// <summary>削除状態の変更セットに追加する変更データの設定を行います。</summary>
            /// <param name="row">選択行</param>
            var setDeletedChangeData = function (row) {
                // 画面の仕様に応じて以下の項目を変更してください。
                var changeData = {
                    "kbn_shiyo_jisseki_anbun": row.kbn_shiyo_jisseki_anbun
                    , "dt_shiyo_shikakari": App.data.getDateTimeStringForQueryNoUtc(App.date.localDate(row.dt_shiyo_shikakari))
                    , "cd_hinmei": row.cd_hinmei
                    , "no_lot_shikakari": header.no_lot_shikakari
                    , "no_lot_seihin": row.no_lot_seihin
                    , "no_seq": row.no_seq
                    , "ts": row.ts
                    , "recordCount": recordCount
                    , "con_no_lot_seihin": row.con_no_lot_seihin
                };
                // ここまで

                return changeData;
            };
            /// <summary>関連項目の設定を変更セットに反映します。</summary>
            /// <param name="selectedRowId">選択行ID</param>
            /// <param name="cellName">列名</param>
            /// <param name="value">元となる項目の値</param>
            var setRelatedChangeData = function (selectedRowId, cellName, value, changeData) {
                if (cellName === "cd_seihin") {
                    var dtShiyo = App.date.localDate(grid.getCell(selectedRowId, "dt_shiyo_shikakari"));
                    dtShiyo = App.data.getDateTimeStringForQueryNoUtc(dtShiyo);
                    changeSet.addUpdated(selectedRowId, "cd_hinmei", grid.getCell(selectedRowId, "cd_hinmei"), changeData);
                    changeSet.addUpdated(selectedRowId, "dt_shiyo_shikakari", dtShiyo, changeData);
                    changeSet.addUpdated(selectedRowId, "no_lot_seihin", grid.getCell(selectedRowId, "no_lot_seihin"), changeData);
                }
                isChanged = true;
            };

            /// <summary>関連項目の設定を変更セットに反映します。</summary>
            /// <param name="selectedRowId">選択行ID</param>
            /// <param name="cellName">列名</param>
            /// <param name="value">元となる項目の値</param>
            var setRelatedChangeAllData = function (selectedRowId, cellName, value, changeData) {

                var changeData = setUpdatedChangeData(grid.getRowData(selectedRowId));

                var dtShiyo = App.date.localDate(grid.getCell(selectedRowId, "dt_shiyo_shikakari"));
                dtShiyo = App.data.getDateTimeStringForQueryNoUtc(dtShiyo);

                changeSet.addUpdated(selectedRowId, "kbn_shiyo_jisseki_anbun", changeData.kbn_shiyo_jisseki_anbun, changeData);
                changeSet.addUpdated(selectedRowId, "cd_hinmei", changeData.cd_hinmei, changeData);
                changeSet.addUpdated(selectedRowId, "no_lot_shikakari", changeData.no_lot_shikakari, changeData);
                changeSet.addUpdated(selectedRowId, "no_lot_seihin", changeData.no_lot_seihin);
                changeSet.addUpdated(selectedRowId, "su_shiyo_shikakari", changeData.su_shiyo_shikakari, changeData);
                changeSet.addUpdated(selectedRowId, "cd_riyu", changeData.cd_riyu, changeData);
                changeSet.addUpdated(selectedRowId, "nm_riyu", changeData.nm_riyu, changeData);
                changeSet.addUpdated(selectedRowId, "cd_genka_center", changeData.cd_genka_center, changeData);
                changeSet.addUpdated(selectedRowId, "nm_genka_center", changeData.nm_genka_center, changeData);
                //changeSet.addUpdated(selectedRowId, "cd_soko", changeData.cd_soko, changeData);
                //changeSet.addUpdated(selectedRowId, "nm_soko", changeData.nm_soko, changeData);
                changeSet.addUpdated(selectedRowId, "kbn_jotai_denso", changeData.kbn_jotai_denso, changeData);
                changeSet.addUpdated(selectedRowId, "no_seq", changeData.no_seq, changeData);

                //isChanged = true;
            };

            /// <summary>検索結果をchangeSet.Createdにセットする。</summary>
            /// 按分トランにデータがなかった場合、製品計画トランからの検索結果をそのまま保存できるようにchangeSetに入れる
            /// <param name="rowId">対象行</param>
            var setGridDataCreated = function (rowId) {
                // 既存行データの設定
                var addData = grid.getRowData(rowId);
                // 変更セットにデータを追加
                changeSet.addCreated(rowId, setCreatedChangeData(addData));
            };

            /// <summary>新規行を追加します。</summary>
            /// <param name="e">イベントデータ</param>
            var addData = function (e) {
                // 選択行のID取得
                var selectedRowId = getSelectedRowId(true),
                    position = "after";
                //position = "before";
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
                changeSet.addCreated(newRowId, setCreatedChangeData(addData));
                // 項目制御
                ctrlGridAnbunKubun(newRowId);
                // カーソルを次の行へ
                grid.editCell(currentRow + 1, kbnHinCol, true);
            };
            /// <summary>追加ボタンクリック時のイベント処理を行います。</summary>
            $(".add-button").on("click", function (e) {
                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();

                // 最大行数チェック：9999以上は追加できない(投入番号がdecimal(4,0)の為)
                var records = grid.getGridParam("records");
                if (records > 9999) {
                    App.ui.page.notifyAlert.message(MS0052).show();
                    return;
                }

                // 行追加
                addData(e);
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
                var changeData = setDeletedChangeData(grid.getRowData(selectedRowId));
                // 削除状態の変更セットに変更データを追加
                changeSet.addDeleted(selectedRowId, changeData);
                // 選択行の行データ削除
                grid.delRowData(selectedRowId);

                // 明細合計と合計差異の設定:入力モードにする前に実施しないと追加行の値が取得されないので注意
                setRelatedValue(0, "su_shiyo_shikakari", 0, shiyoRyoCol);

                if (grid.getGridParam("records") > 0) {
                    // セルを選択して入力モードにする
                    grid.editCell(currentRow === 1 ? currentRow : currentRow - 1, currentCol, true);
                }

                // 変更フラグをセット
                isChanged = true;
            };
            /// <summary>削除ボタンクリック時のイベント処理を行います。</summary>
            $(".delete-button").on("click", function (e) {
                deleteData(e);
            });

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
                // 画面の仕様に応じて以下の変数を変更します。
                    checkCol = 1;

                // データ整合性エラーのハンドリングを行います。
                if (App.isArray(ret) && ret.length > 0) {
                    for (var i = 0; i < ret.length; i++) {
                        // 同時実行エラー：すでにデータが存在した場合
                        if (ret[i].InvalidationName === "Exists") {
                            unique = ids[i] + "_" + firstCol;

                            // エラーメッセージの表示
                            App.ui.page.notifyAlert.message(
                            //pageLangText.updatedDuplicate.text + ret[i].Message, unique).show();
                                pageLangText.duplicate.text + pageLangText.updatedDuplicate.text).show();
                            // 対象セルの背景変更
                            //grid.setCell(ids[j], firstCol, ret[i].Data.no_seq, { background: '#ff6666' });
                        }
                        else if (ret[i].InvalidationName === "DuplicateItem") {
                            // 重複エラー：製品ロット番号の重複時
                            for (var j = 0; j < ids.length; j++) {
                                value = grid.getCell(ids[j], seihinLotCol);
                                retValue = ret[i].Data.no_lot_seihin;

                                if (value == retValue) {
                                    unique = ids[j] + "_" + seihinLotCol;
                                    // エラー行を追加
                                    errRows.push(ids[j]);

                                    // エラーメッセージの表示
                                    App.ui.page.notifyAlert.message(
                                            pageLangText.invalidation.text + ret[i].Message, unique).show();
                                    // 対象セルの背景変更
                                    grid.setCell(ids[j], seihinLotCol, retValue, { background: '#ff6666' });
                                }
                            }
                        }
                        else {
                            // エラーメッセージの表示
                            App.ui.page.notifyAlert.message(
                                pageLangText.invalidation.text + ret[i].Message).show();
                        }
                    }
                }

                // 更新時同時実行制御エラーのハンドリングを行います。
                if (!App.isUndefOrNull(ret.Updated) && ret.Updated.length > 0) {
                    for (var ii = 0; ii < ret.Updated.length; ii++) {
                        for (p in changeSet.changeSet.updated) {
                            if (!changeSet.changeSet.updated.hasOwnProperty(p)) {
                                continue;
                            }

                            var upCurrent = ret.Updated[ii].Current;
                            // 他のユーザーによって削除されていた場合
                            if (App.isUndefOrNull(upCurrent)) {
                                // 対象行の削除
                                grid.delRowData(p);
                                // メッセージの表示
                                App.ui.page.notifyAlert.message(
                                        pageLangText.duplicate.text + pageLangText.deletedDuplicate.text).show();
                            }
                            else {
                                // 他のユーザーに変更されていた場合
                                unique = p + "_" + duplicateCol;

                                // DBの最新状態を取得
                                /*
                                current = grid.getRowData(p);
                                current.kbn_shiyo_jisseki_anbun = upCurrent.kbn_shiyo_jisseki_anbun;
                                var date = App.data.getDate(upCurrent.dt_shiyo_shikakari);
                                var formatDate = App.data.getDateString(date, true);
                                current.dt_shiyo_shikakari = formatDate;
                                current.nm_kbn_hin = upCurrent.nm_kbn_hin;
                                current.cd_hinmei = upCurrent.cd_hinmei;
                                current[seihinName] = upCurrent[seihinName];
                                current.no_lot_seihin = upCurrent.no_lot_seihin;
                                current.cd_riyu = upCurrent.cd_riyu;
                                current.nm_riyu = upCurrent.nm_riyu;
                                current.cd_genka_center = upCurrent.cd_genka_center;
                                current.nm_genka_center = upCurrent.nm_genka_center;
                                current.cd_soko = upCurrent.cd_soko;
                                current.nm_soko = upCurrent.nm_soko;
                                current.kbn_jotai_denso = upCurrent.kbn_jotai_denso;
                                current.kbn_denso = upCurrent.kbn_denso;
                                current.kbn_hin = upCurrent.kbn_hin;
                                current.ts = upCurrent.ts;

                                // 対象行の更新
                                grid.setRowData(p, current);
                                */
                                // エラーメッセージの表示
                                App.ui.page.notifyAlert.message(
                                        pageLangText.duplicate.text + pageLangText.updatedDuplicate.text, unique).show();
                            }
                        }
                    }
                }
                // 削除時同時実行制御エラーのハンドリングを行います。
                if (!App.isUndefOrNull(ret.Deleted) && ret.Deleted.length > 0) {
                    for (var iii = 0; iii < ret.Deleted.length; iii++) {
                        for (p in changeSet.changeSet.deleted) {
                            if (!changeSet.changeSet.deleted.hasOwnProperty(p)) {
                                continue;
                            }

                            value = parseInt(changeSet.changeSet.deleted[p].no_seq, 10)
                            retValue = ret.Deleted[iii].Requested.no_seq;

                            if (isNaN(value) || value === retValue) {
                                // 削除状態の変更セットから変更データを削除
                                changeSet.removeDeleted(p);

                                // 他のユーザーによって削除されていた場合
                                if (App.isUndefOrNull(ret.Deleted[iii].Current)) {
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
                // 確認ダイアログのクローズ
                closeSaveConfirmDialog();
                // ローディングの表示
                App.ui.loading.show(pageLangText.nowSaving.text);

                var saveUrl = "../api/SeizoJissekiSentaku";

                App.ajax.webpost(
                    saveUrl, getPostData()
                ).done(function (result) {
                    // 検索前の状態に初期化
                    //clearState();
                    isChanged = false;
                    // 終了メッセージ表示
                    //showSaveCompleteDialog();
                    // 日報画面に戻る
                    App.ui.loading.show(pageLangText.nowProgressing.text);
                    backToNippo();
                }).fail(function (result) {
                    // データ変更エラーハンドリングを行います。
                    App.ui.loading.close();
                    handleSaveDataError(result);
                }).always(function () {
                    //App.ui.loading.close();
                });
            };
            /// <summary>保存ボタンクリック時のイベント処理を行います。</summary>
            $(".save-button").on("click", function () {
                // 編集内容の保存
                saveEdit();

                // 内部エラーになった行の背景色をすべてリセット
                clearErrBgcorror(errRows);

                // 変更がない場合は処理を抜ける
                if (noChange()) {
                    App.ui.page.notifyInfo.message(pageLangText.noChange.text).show();
                    return;
                }
                // メッセージのクリア
                App.ui.page.notifyInfo.clear();
                App.ui.page.notifyAlert.clear();
                // エラー行格納変数のクリア
                errRows = new Array();

                /// チェック処理
                // 変更セット内にバリデーションエラーがある場合は処理を抜ける
                if (!validateChangeSet()) {
                    return;
                }
                //return false;

                /// 相関チェック
                // 明細に伝送待ちまたは伝送中が存在しないこと
                if (!checkDensoJotaiKubun()) {
                    App.ui.page.notifyAlert.message(MS0748).show();
                    return;
                }

                //使用実績按分区分「製造」のときに品名が「テスト品」でないこと
                if (!checkTesthin()) {
                    App.ui.page.notifyAlert.message(MS0802).show();
                    return;
                }

                // 明細/仕掛品使用量の合計値とヘッダー/仕込量が合致していること
                var m_gokei = deleteThousandsSeparator($("#meisai_gokei").text());
                var h_shikomi = deleteThousandsSeparator(header.wt_shikomi);
                if (h_shikomi != m_gokei) {
                    App.ui.page.notifyAlert.message(MS0747).show();
                    return;
                }

                // 製造実績選択画面の日付が仕込日より過去でないことの確認
                // 変数定義
                var dtShikomi = App.date.localDate(header.dt_shikomi);
                var dtShikomiFullYear = dtShikomi.getFullYear() +
                                        ("0" + (dtShikomi.getMonth() + 1)).slice(-2) +
                                        ("0" + (dtShikomi.getDate())).slice(-2);
                var gridIDs = grid.getDataIDs();
                var gridRowLength = grid.getDataIDs().length;
                var errCheck = false;

                // 登録明細分処理する
                for (var i = 0; i < gridRowLength; i++) {

                    // 変数定義
                    var dtShikakari = App.date.localDate(grid.getCell(gridIDs[i], "dt_shiyo_shikakari"));
                    var dtShikakariFullYear = dtShikakari.getFullYear() +
                                        ("0" + (dtShikakari.getMonth() + 1)).slice(-2) +
                                        ("0" + (dtShikakari.getDate())).slice(-2);
                    currentCol = seizoDateCol;
                    currentRow = i + 1;

                    // 背景を白にする。
                    grid.setCell(gridIDs[i], "dt_shiyo_shikakari", '', { background: 'none' });

                    // 過去日付なら背景を赤にする。
                    if (dtShikakariFullYear < dtShikomiFullYear) {

                        // 行選択を解除する。
                        grid.resetSelection(gridIDs[i]);

                        // セルを選択して入力モードを解除する
                        grid.editCell(currentRow, currentCol, false);

                        // 背景を赤にする。
                        grid.setCell(gridIDs[i], "dt_shiyo_shikakari", '', { background: 'red' });

                        // エラーフラグ
                        errCheck = true;
                    }
                }

                // エラーがあれば処理終了
                if (errCheck == true) {

                    // エラーメッセージの表示
                    App.ui.page.notifyAlert.message(MS0794).show();
                    return;
                }

                //showSaveConfirmDialog();
                saveData();
            });

            /// データ存在チェック関数のストアド実行
            var checkData = function (row, isDeleted) {
                //残以外の場合
                var rowId = getSelectedRowId();
                var anbunKbn = grid.getCell(rowId, "kbn_shiyo_jisseki_anbun");
                var beforeAnbunKbn = grid.getCell(rowId, "con_kbn_shiyo_jisseki_anbun");
                if (!(beforeAnbunKbn == pageLangText.shiyoJissekiAnbunKubunZan.text && anbunKbn == pageLangText.shiyoJissekiAnbunKubunZan.text)) {
                    return true;
                };

                var noLotSeihin;
                if (beforeAnbunKbn == pageLangText.shiyoJissekiAnbunKubunZan.text) {
                    noLotSeihin = row.no_lot_seihin;
                } else {
                    noLotSeihin = null;
                };

                var query = {
                    url: "../api/SeizoJissekiSentakuZaikoCheck",
                    after_su_shiyo_shikakari: isDeleted ? 0 : row.su_shiyo_shikakari,
                    no_lot_seihin: noLotSeihin,
                    kbn_shiyo_jisseki_anbun: row.kbn_shiyo_jisseki_anbun
                },
                isValid = true;

                App.ajax.webgetSync(
                   App.data.toWebAPIFormat(query)
                ).done(function (result) {

                    // サービス呼び出し成功時の処理
                    if (result == null || result.length <= 0) {
                        //件数が0件の時
                        //エラー表示
                        App.ui.page.notifyAlert.message(pageLangText.shiyoErr.text).show();
                        isValid = false;
                    }

                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                    isValid = false;
                });

                return isValid;
            };

            /// <summary>関連するデータが伝送待ちまたは伝送中かどうか</summary>
            var checkDensoJotaiKubun = function () {
                var isCeheck = true;
                var check_query = {
                    url: "../Services/FoodProcsService.svc/tr_sap_shiyo_yojitsu_anbun",
                    filter: "no_lot_shikakari eq '" + header.no_lot_shikakari
                        + "' and (kbn_jotai_denso eq " + pageLangText.densoJotaiKbnDensomachi.text
                        + "or kbn_jotai_denso eq " + pageLangText.densoJotaiKbnDensochu.text + ")",
                    select: "no_seq, no_lot_shikakari",
                    top: 1,
                    inlinecount: "allpages"
                };

                App.ajax.webgetSync(
                    App.data.toODataFormat(check_query)
                ).done(function (result) {
                    if (result.d.__count > 0) {
                        isCeheck = false;
                    }
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                });
                return isCeheck;
            };

            /// <summary>使用実績按分区分「製造」のときに品名が「テスト品」かどうか</summary>
            /// <return>判定結果[False:「製造」且つ「テスト品」, True:それ以外] </return>
            var checkTesthin = function () {
                
                //変数定義
                var gridIDs = grid.getDataIDs();
                var gridRowLength = gridIDs.length;

                //登録明細分確認
                for (var i = 0; i < gridRowLength; i++) {

                    //変数定義
                    var flg_testitem = grid.getCell(gridIDs[i], "flg_testitem");
                    var kbn_shiyo_jisseki_anbun = grid.getCell(gridIDs[i], "kbn_shiyo_jisseki_anbun");

                    //使用実績按分区分「製造」且つ「テスト品」であれば「false」を返して処理終了
                    if (kbn_shiyo_jisseki_anbun == pageLangText.shiyoJissekiAnbunKubunSeizo.text
                            && flg_testitem == pageLangText.flgTestItem.number) {

                        //セルの背景を赤にする
                        grid.setCell(gridIDs[i], "kbn_shiyo_jisseki_anbun", '', { background: '#ff6666' });
                        return false;
                    }
                }
                return true;
            };

            //// 保存処理 -- End

            //// バリデーション -- Start

            // グリッドコントロール固有のバリデーション
            // グリッドのバリデーション設定
            var v = Aw.validation({
                items: validationSetting
            });

            $(".validation-seizo").validation(v);
            $(".validation-chosei").validation(v);

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
                // 按分区分「調整」のときの必須チェック
                var anbunKbn = grid.getCell(selectedRowId, "kbn_shiyo_jisseki_anbun");
                if (anbunKbn == pageLangText.shiyoJissekiAnbunKubunChosei.text) {
                    if (cellName == "nm_riyu" || cellName == "nm_genka_center" /*|| cellName == "nm_soko"*/) {
                        if (value == "") {
                            var paramName = grid.jqGrid("getGridParam", "colNames")[iCol];
                            App.ui.page.notifyAlert.message(App.str.format(MS0042, paramName), unique).show();
                            grid.setCell(selectedRowId, iCol, value, { background: '#ff6666' });
                            return false;
                        }
                    }
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
                    // カレントの行バリデーションを実行
                    if (!checkData(changeSet.changeSet.updated[p], false)) {
                        return false;
                    }
                }
                for (p in changeSet.changeSet.deleted) {
                    if (!changeSet.changeSet.deleted.hasOwnProperty(p)) {
                        continue;
                    }
                }
                return true;
            };

            //// バリデーション -- End

            //明細/使用実績按分区分が区分/コード一覧#使用実績按分区分#残の場合
            var searchHinMaster = function (selectedRowId, value) {
                if (value == pageLangText.shiyoJissekiAnbunKubunZan.text) {

                    // データ存在チェック
                    var hinquery = {
                        url: "../Services/FoodProcsService.svc/vw_ma_hinmei_11",
                        filter: "cd_haigo eq '" + header.cd_haigo + "'"
                                + " and kbn_hin eq " + pageLangText.jikaGenryoHinKbn.text
                                + " and flg_mishiyo eq " + pageLangText.shiyoMishiyoFlg.text,
                        top: 1
                    };
                    App.ajax.webgetSync(
                    App.data.toODataFormat(hinquery)
                    ).done(function (result) {
                        // サービス呼び出し成功時の処理
                        if (result.d.length > 0) {
                            // 賞味期間のチェック
                            if (result.d[0].dd_shomi != null) {
                                var data = result.d[0];
                                //画面表示
                                grid.setCell(selectedRowId, "dt_shiyo_shikakari", $("#dt_shikomi").text());
                                grid.setCell(selectedRowId, "nm_kbn_hin", data.nm_kbn_hin);
                                grid.setCell(selectedRowId, "cd_hinmei", data.cd_hinmei);
                                grid.setCell(selectedRowId, "kbn_hin", data.kbn_hin);
                                grid.setCell(selectedRowId, seihinName, data[seihinName]);
                            } else {
                                //エラー表示
                                App.ui.page.notifyAlert.message(pageLangText.shomiErr.text).show();
                                //背景色を赤にする
                                grid.setCell(selectedRowId, "cd_hinmei", '', { background: '#ff6666' });
                            }
                        }
                        else {
                            // 件数0件の場合：エラー表示
                            App.ui.page.notifyAlert.message(pageLangText.kensuErr.text).show();
                            //背景色を赤にする
                            grid.setCell(selectedRowId, "cd_hinmei", '', { background: '#ff6666' });
                        }
                    }).fail(function (result) {
                        App.ui.page.notifyAlert.message(result.message).show();
                    });

                }

            };

            /// <summary>ファンクションキー対応処理</summary>
            /// <param name="e">イベントデータ</param>
            var processFunctionKey = function (e) {
                var processed = false;
                // 画面の仕様に応じて以下のファンクションキー毎の処理を定義します。
                if (e.keyCode === App.ui.keys.F2) {
                    // F2の処理
                    processed = true;
                }
                else if (e.keyCode === App.ui.keys.F3) {
                    // F3の処理
                    processed = true;
                }
                // ここまで
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
                    resultPart = $(".result-list"),
                    resultPartHeader = resultPart.find(".part-header"),
                    resultPartCommands = resultPart.find(".item-command"),
                    resultPartStyle = resultPart[0].currentStyle || document.defaultView.getComputedStyle(resultPart[0], "");

                resultPart.height(container[0].clientHeight - ((parseInt(resultPartStyle.marginTop, 10) * 3) || 0) - 90);
                grid.setGridWidth(resultPart[0].clientWidth - 5);
                //グリッドの高さ設定　結果一覧のパートの高さ - パートのヘッダーの高さ - パート内のボタンのコマンドの高さ - jqGrid のカラムヘッダーの高さ
                grid.setGridHeight(resultPart[0].clientHeight - resultPartHeader[0].clientHeight - resultPartCommands[0].clientHeight - resultPart.find(".ui-jqgrid-hdiv")[0].clientHeight - 25);
            };
            /// <summary>画面リサイズ時のイベント処理を行います。</summary>
            $(App.ui.page).on("resized", resizeContents);

            /// <summary>製造検索ボタンクリック時のイベント処理を行います。</summary>
            $("#seizo-button").on("click", function (e) {
                openSeizoDlg();
            });

            /// <summary>検索実行チェックメッセージを出力します。</summary>
            var showBeforeSearch = function () {
                // 情報メッセージのクリア
                App.ui.page.notifyInfo.clear();
                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();
                // 情報メッセージ出力
                App.ui.page.notifyAlert.message(pageLangText.beforeSearch.text).show();
            };

            /// <summary>保存確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".save-confirm-dialog .dlg-yes-button").on("click", function () {
                closeSaveConfirmDialog();
                saveData();
            });
            // <summary>保存確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".save-confirm-dialog .dlg-no-button").on("click", closeSaveConfirmDialog);

            /// <summary>保存完了ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".save-complete-dialog .dlg-close-button").on("click", function () {
                App.ui.loading.close();
                App.ui.loading.show(pageLangText.nowProgressing.text);
                closeSaveCompleteDialog();
                backToNippo();
            });

            // コンテンツに変更が発生した場合は、
            //$(".result-list").on("change", function (e) {
            //    if (e.target.id !== "flg_tanto_hinkan" && e.target.id !== "flg_tanto_seizo") {
            //        hinkanTantoClear();
            //        seizoTantoClear();
            //        isChanged = true;
            //    }
            //});

            /// <summary>データに変更があり、未保存の状態でページを離れる際に確認を行います。</summary>
            //別画面に遷移したりするときに実行する関数の定義
            var onBeforeUnload = function () {
                //データを変更したかどうかは各画面でチェックし、保持する
                if (isChanged) {
                    return pageLangText.unloadWithoutSave.text;
                }
            };
            $(window).on('beforeunload', onBeforeUnload);   //beforeunloadイベントに関数を割り当て
            // formをsubmit（ログオフ）する場合、beforeunloadイベントを発生させないようにする
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

            /// <summary>仕込日報に遷移する。遷移後、仕込日報はリロードする。</summary>
            var backToNippo = function () {
                // IEバグによる例外発生をキャッチします。例外発生時は何もしません。
                try {
                    var url = "./ShikomiNippo.aspx";
                    url += "?dt_seizo_st=" + header.dt_shikomi_st.replace(/[\/]/g, "");
                    url += "&dt_seizo_en=" + header.dt_shikomi_en.replace(/[\/]/g, "");
                    url += "&cd_shokuba=" + header.shokuba;
                    url += "&cd_line=" + header.line;
                    // 伝送状況チェックボックス
                    url += "&chk_mi_sakusei=" + header.chk_mi_sakusei;
                    url += "&chk_mi_denso=" + header.chk_mi_denso;
                    url += "&chk_denso_machi=" + header.chk_denso_machi;
                    url += "&chk_denso_zumi=" + header.chk_denso_zumi;
                    // 登録状況チェックボックス
                    url += "&chk_mi_toroku=" + header.chk_mi_toroku;
                    url += "&chk_ichibu_mi_toroku=" + header.chk_ichibu_mi_toroku;
                    url += "&chk_toroku_sumi=" + header.chk_toroku_sumi;

                    url += "&kakutei=" + header.kakutei;
                    url += "&mikakutei=" + header.mikakutei;

                    document.location = url;
                }
                catch (e) {
                    App.ui.loading.close();
                    // 何もしない
                }
            };
            /// <summary>閉じるボタンクリック時のイベント処理を行います。</summary>
            $(".close-button").on("click", backToNippo);
        });
    </script>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <!-- 画面デザイン -- Start -->

    <!-- 検索結果一覧 -->
    <div class="content-part result-list">
        <h3 id="listHeader" class="part-header">
            <span data-app-text="resultList" style="padding-right: 10px;"></span>
            <span class="list-count" id="list-count"></span>
            <span style="padding-left: 50px;" class="list-loading-message" id="list-loading-message"></span>
        </h3>
        <div class="part-body">
                <!-- 画面の仕様に応じて以下のヘッダー部を変更してください。-->
            <ul class="item-list-left">
                <!-- ヘッダー：左 -->
                <li>
                    <label>
                        <span class="item-label" data-app-text="dt_shikomi"></span>
                        <span id="dt_shikomi"></span>
                    </label>
                </li>
                <li>
                    <label>
                        <span class="item-label" data-app-text="cd_haigo"></span>
                        <span id="cd_haigo"></span>
                    </label>
                </li>
                <li>
                    <label>
                        <span class="item-label" data-app-text="nm_haigo"></span>
                        <span id="nm_haigo"></span>
                    </label>
                </li>
                <li>
                    <label>
                        <span class="item-label" data-app-text="no_lot_shikakari"></span>
                        <span id="no_lot_shikakari"></span>
                    </label>
                </li>
            </ul>
            <ul class="item-list-center">
                <!-- ヘッダー：中 -->
                <li>
                    <label>
                        <span class="item-label" data-app-text="batch"></span>
                        <span id="batch"></span>
                    </label>
                </li>
                <li>
                    <label>
                        <span class="item-label" data-app-text="batch_hasu"></span>
                        <span id="batch_hasu"></span>
                    </label>
                </li>
                <li>
                    <label>
                        <span class="item-label" data-app-text="wt_shikomi"></span>
                        <span id="wt_shikomi"></span>
                    </label>
                </li>
            </ul>
            <ul class="item-list-right">
                <!-- ヘッダー：右 -->
                <li>
                    <label>
                        <span class="item-label" data-app-text="bairitsu"></span>
                        <span id="bairitsu"></span>
                    </label>
                </li>
                <li>
                    <label>
                        <span class="item-label" data-app-text="bairitsu_hasu"></span>
                        <span id="bairitsu_hasu"></span>
                    </label>
                </li>
            </ul>
            <!-- ヘッダー部: ここまで -->
        </div>
        <!-- グリッドコントロール固有のデザイン -- Start -->
        <div class="part-body" id="result-grid">
            <div class="item-command">
                <button type="button" class="colchange-button" data-app-operation="colchange"><span class="icon"></span><span data-app-text="colchange"></span></button>
                <button type="button" class="add-button" name="add-button" data-app-operation="add"><span class="icon"></span><span data-app-text="add"></span></button>
                <button type="button" class="delete-button" name="delete-button" data-app-operation="del"><span class="icon"></span><span data-app-text="del"></span></button>
                <button type="button" class="dialog-button" id="seizo-button" name="seizoIchiran" data-app-operation="seizoDlg"><span class="icon"></span><span data-app-text="seizoIchiran"></span></button>
            </div>
            <div style="text-align: right">
                <span class="item-label" data-app-text="meisai_gokei"></span>
                <span class="total-label" id="meisai_gokei"></span>
                <span class="item-label" data-app-text="gokei_sai"></span>
                <span class="total-label" id="gokei_sai" style="padding-right: 20px;"></span>
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
        <button type="button" class="save-button" name="save-button" data-app-operation="save"><span class="icon"></span><span data-app-text="save"></span></button>
    </div>
    <div class="command" style="right: 9px;">
        <button type="button" class="close-button" name="close-button">
            <span class="icon"></span>
            <span data-app-text="close"></span>
        </button>    
    </div>
    <!-- 画面アーキテクチャ共通のデザイン -- End -->

    <!-- 画面デザイン -- End -->
</asp:Content>
<asp:Content ID="Content5" ContentPlaceHolderID="DialogsContent" runat="server">
    <!-- 画面デザイン -- Start -->
    <!-- 画面の仕様に応じて以下のダイアログの設定を変更してください。 -->
    <div class="seizo-dialog">
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
    <!-- 画面デザイン -- End -->
</asp:Content>
