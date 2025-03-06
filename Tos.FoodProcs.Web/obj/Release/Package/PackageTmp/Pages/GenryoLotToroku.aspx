<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="GenryoLotToroku.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.GenryoLotToroku" %>

<asp:Content ID="Content1" ContentPlaceHolderID="IncludeContent" runat="server">
    <script src="<%=ResolveUrl("~/Resources/pages/pagedata-genryolottoroku." + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
    <script src="<%=ResolveUrl("~/Resources/grid/grid.locale-" + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        .content-container .content-part .part-footer .command {
          position: absolute;
          display: inline-block;
          right: 0;
        }
        .ui-jqgrid-btable .ui-state-highlight, .ui-jqgrid-btable .selected-row
        {
            border: 1px solid #999999;
            background: #fce188 50% 50% repeat-x;
            color: #363636;
        }
        .ui-jqgrid .ui-jqgrid-htable th
        {
            vertical-align: middle !important;
        }
        .ui-jqgrid .ui-jqgrid-htable th div 
        {
            height:auto;
            overflow:hidden;
            padding-right:4px;
            padding-top:2px;
            position:relative;
            white-space:normal !important;
        }
        .content-container .content-part .part-footer .command 
        {
          position: absolute;
          display: inline-block;
          right: 0;
        }
        button.genryo-lot-sentaku .icon
        {
            background-position: -48px -80px;
        }
        button.genryo-lot-torikeshi .icon
        {
            background-position: -48px -80px;
        }  
        .background-grey
        {
            border: 1px solid #999999;
            background: #BDBDBD 50% 50% repeat-x;
        }  
        .hinmei-dialog
        {
            background-color: White;
            width: 570px;
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
        /*.ui-jqgrid tr.jqgrow td {
            word-wrap: break-word;
            white-space: pre-wrap;
            overflow: hidden;
            height: auto;
            vertical-align: middle;
        }*/
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
            /**
            * function get parameter from url
            * url: localhost:xxxxx/Pages/GenryoLotToroku.aspx?no_lot_shikakari=&cd_hinmei=&dt_seizo=&dt_seizo_st=
            &dt_seizo_en=&cd_shokuba=&cd_line=&chk_mi_sakusei=&chk_mi_denso=&chk_denso_machi=&chk_denso_zumi=
            &chk_mi_toroku=&chk_ichibu_mi_toroku=&chk_toroku_sumi=
            **/
            var getUrlVars = function () {
                var vars = [], hash;
                var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
                for (var i = 0; i < hashes.length; i++) {
                    hash = hashes[i].split('=');
                    vars[hash[0]] = hash[1].replace('#', '');
                }
                return vars;
            }

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
            //// 変数宣言 -- Start
            // 画面アーキテクチャ共通の変数宣言
            var lang = App.ui.page.lang,
                pageLangText = App.ui.pagedata.lang(lang),
                validationSetting = App.ui.pagedata.validation(lang),
                querySetting = { skip: 0, top: 500, count: 0 },
                isDataLoading = false,
                parameter = getUrlVars();
            $("input[name='no_lot_shikakari']").val(parameter.no_lot_shikakari);
            $("input[name='cd_hinmei']").val(parameter.cd_hinmei);

            // グリッドコントロール固有の変数宣言
            var grid = $("#item-grid"),
                firstCol = 1,
                currentRow = 0,
                currentCol = firstCol,
                duplicateCol = 999,
                hinmeiName = 'nm_hinmei_' + lang,
                changeSet = new App.ui.page.changeSet(),
                isRegistered = false,
                flg_cd_hinmei_changed = false,
                flg_no_lot_changed = false;
            $(".find-button").focus();
            // 日付の多言語対応
            var datePickerFormat = pageLangText.dateFormatUS.text,
                gridSrcFormat = pageLangText.dateSrcFormatUS.text,
                gridNewFormat = pageLangText.dateNewFormatUS.text;

            if (App.ui.page.langCountry !== 'en-US') {
                datePickerFormat = pageLangText.dateFormat.text;
                gridSrcFormat = pageLangText.dateSrcFormat.text;
                gridNewFormat = pageLangText.dateNewFormat.text;
            }
            //var dt_seizo = ;
            // 日付
            //            var dtHiduke = $(".search-criteria [name='dt_hiduke']");
            //            dtHiduke.datepicker({ dateFormat: datePickerFormat });
            //            dtHiduke.on("keyup", App.data.addSlashForDateString);
            //            dtHiduke.datepicker("setDate", new Date(dt_seizo));
            //            dtHiduke.datepicker("option", "maxDate", new Date(pageLangText.maxDate.text));
            //            dtHiduke.datepicker("option", "minDate", new Date(pageLangText.minDate.text));
            $(".search-criteria [name='dt_hiduke']").val(attachedDateSlash(parameter.dt_seizo.toString()));
            var cd_haigo = $(".search-criteria").find("input[name='cd_hinmei']").val();
            var filter = [];
            filter.push("cd_haigo eq '" + cd_haigo + "'");

            var query = {
                url: "../Services/FoodProcsService.svc/ma_haigo_mei",
                filter: filter.join(" and "),
                inlinecount: "allpages"
            };

            App.ui.loading.show(pageLangText.nowProgressing.text);
            isDialogLoading = true;
            App.ajax.webget(
                App.data.toODataFormat(query)
			).done(function (result) {
			    if (parseInt(result.d.__count) > 0) {
			        var item = result.d.results[0];
			        $(".search-criteria").find("span[name='nm_hinmei']").text(item["nm_haigo_" + lang]);
			        if (App.isNull(item["nm_haigo_" + lang])) {
			            $(".search-criteria").find("span[name='nm_hinmei']").text(item["nm_haigo_ryaku"]);
			        }
			    }
			}).fail(function (result) {
			    App.ui.page.notifyInfo.message(result.message).show();
			}).always(function () {
			    setTimeout(function () {
			        isDataLoading = false;
			    }, 500);
			    App.ui.loading.close();
			});
            //// 変数宣言 -- End    

            // グリッドコントロール固有のコントロール定義
            grid.jqGrid({
                colNames: [
                    pageLangText.flg_henko.text
                    , pageLangText.no_kotei.text
                    , pageLangText.no_tonyu.text
                    , pageLangText.cd_hinmei.text
                    , pageLangText.nm_hinmei_ryaku.text
                    , pageLangText.nm_nisugata_hyoji.text
                    , pageLangText.nm_tani_shiyo.text
                    , pageLangText.no_lot.text
                    , pageLangText.biko.text
                    , pageLangText.blank.text
                    , pageLangText.blank.text
                    , pageLangText.blank.text
                    , pageLangText.blank.text
                    , pageLangText.blank.text
                    , pageLangText.blank.text
                    , pageLangText.blank.text
                    , pageLangText.blank.text
                ],
                colModel: [
                    { name: 'flg_henko', resizable: false, width: pageLangText.flg_henko.number, align: 'center', edittype: 'checkbox',
                        editable: false, sortable: false,
                        formatter: 'checkbox',
                        editoptions: {
                            value: "True:False"
                        }
                    },
                    { name: 'no_kotei', width: pageLangText.no_kotei.number, editable: false },
                    { name: 'no_tonyu', width: pageLangText.no_tonyu.number, editable: false },
                    { name: 'cd_hinmei', width: pageLangText.cd_hinmei.number, sorttype: "text", resizable: false, editable: true },
                    { name: 'nm_hinmei_ryaku', width: pageLangText.nm_hinmei_ryaku.number, sorttype: "text", editable: false },
                    { name: 'nm_nisugata_hyoji', width: pageLangText.nm_nisugata_hyoji.number, sorttype: "text", resizable: false, editable: false },
                    { name: 'nm_tani_shiyo', width: pageLangText.nm_tani_shiyo.number, sorttype: "text", resizable: false, editable: false },
                    { name: 'no_lot', width: pageLangText.no_lot.number, sorttype: "text", resizable: true, editable: false },
                    { name: 'biko', width: pageLangText.biko.number, sorttype: "text", resizable: false, editable: true },
                    { name: 'kbn_hin', width: pageLangText.blank.number, hidden: true, hidedlg: true },
                    { name: 'flg_trace_taishogai', width: pageLangText.blank.number, hidden: true, hidedlg: true },

                    { name: 'cd_tani_shiyo', width: pageLangText.blank.number, hidden: true, hidedlg: true },
                    { name: 'no_niuke', width: pageLangText.blank.number, hidden: true, hidedlg: true },
                    { name: 'no_lot_shikakari', width: pageLangText.blank.number, hidden: true, hidedlg: true },
                    { name: 'cd_shikakari_hin', width: pageLangText.blank.number, hidden: true, hidedlg: true },
                    { name: 'dt_seizo', width: pageLangText.blank.number, hidden: true, hidedlg: true },
                    { name: 'cd_hinmei_old', width: pageLangText.blank.number, hidden: true, hidedlg: true }
                ],
                datatype: 'local',
                cellEdit: true,
                shrinkToFit: false,
                rownumbers: true,
                loadonce: true,
                cellsubmit: 'clientArray',
                ondblClickRow: function (rowid, iRow, iCol, e) {
                    $("#" + rowid).removeClass("ui-state-highlight").find("td").click();
                    var data = grid.getRowData(rowid);
                    if (iCol == getIColModel("cd_hinmei") && data.kbn_hin != pageLangText.shikakariHinKbn.text && data.flg_trace_taishogai != 1) {
                        var kbnDialog = pageLangText.genryoLotTorokuDlgParam.text;

                        var option = { id: 'hinmeiDialog', multiselect: false, param1: kbnDialog };
                        hinmeiDialog.draggable(true);
                        hinmeiDialog.dlg("open", option);
                    }
                },
                onSortCol: function () {
                    grid.setGridParam({ rowNum: grid.getGridParam("records") });
                },
                afterInsertRow: function (rowid, rowdata, rowelem) {
                    if (rowdata.kbn_hin == pageLangText.shikakariHinKbn.text || rowdata.flg_trace_taishogai == 1) {
                        $("#" + rowid).addClass("background-grey");
                        grid.jqGrid("setCell", rowid, "cd_hinmei", "", "not-editable-cell");
                        grid.jqGrid("setCell", rowid, "no_lot", null);
                        grid.jqGrid("setCell", rowid, "biko", null, "not-editable-cell");
                        grid.jqGrid("setCell", rowid, "no_niuke", null);
                    }
                    if (isRegistered == false) {
                        var changeData = setCreatedChangeData(grid.getRowData(rowid));
                        changeSet.addCreated(rowid, changeData);
                    }
                    if (App.isUndefOrNull(rowelem["nm_hinmei_" + lang]) || rowelem["nm_hinmei_" + lang].toString().length == 0) {
                        grid.jqGrid("setCell", rowid, "nm_hinmei_ryaku", rowelem.nm_hinmei_ryaku);
                    }
                    else {
                        grid.jqGrid("setCell", rowid, "nm_hinmei_ryaku", rowelem["nm_hinmei_" + lang]);
                    }
                },
                gridComplete: function () {
                    $("#" + firstCol).removeClass("ui-state-highlight").find("td").click();
                    App.ui.page.notifyAlert.clear();
                },
                onRightClickRow: function (rowid) {
                    $("#" + rowid).removeClass("ui-state-highlight").find("td").click();
                },
                afterEditCell: function (selectedRowId, cellName, value, iRow, iCol) {
                    grid.moveCell(cellName, iRow, iCol);
                },
                beforeEditCell: function (selectedRowId, cellName, value, iRow, iCol) {
                    currentRow = iRow;
                    currentCol = iCol;
                },
                afterSaveCell: function (selectedRowId, cellName, value, iRow, iCol) {
                    if (cellName == "cd_hinmei") {
                        if (validateCell(selectedRowId, "cd_hinmei", value, iCol)) {
                            var changeData = setUpdatedChangeData(grid.getRowData(selectedRowId));
                            changeSet.addUpdated(selectedRowId, "cd_hinmei", value, changeData);
                            changeSet.addUpdated(selectedRowId, "no_niuke", grid.getRowData(selectedRowId).no_niuke, changeData);
                        }

                        return;
                    }

                    // 関連項目の設定
                    validateCell(selectedRowId, cellName, value, iCol);
                    // 更新状態の変更データの設定
                    var changeData = setUpdatedChangeData(grid.getRowData(selectedRowId));
                    // 更新状態の変更セットに変更データを追加
                    changeSet.addUpdated(selectedRowId, cellName, value, changeData);
                },
                beforeSaveCell: function (selectedRowId, cellName, value, iRow, iCol) {
                    if (cellName == "cd_hinmei") {
                        setRelatedHinmeiCode(selectedRowId, value);
                        validationSetting.cd_hinmei.params.custom = selectedRowId;
                        validateCell(selectedRowId, "cd_hinmei", value, iCol);
                        validationSetting.no_lot.params.custom = selectedRowId;
                        validateCell(selectedRowId, "no_lot", grid.getRowData(selectedRowId).no_lot, getIColModel("no_lot"));

                        return;
                    }
                }
            });

            validationSetting.cd_hinmei.rules.custom = function (value, param) {
                if (value == "") {
                    return false;
                }
                var selectedRowId;
                if (!App.isUndef(param))
                    selectedRowId = param;
                else
                    selectedRowId = getSelectedRowId(false);
                var data = grid.getRowData(selectedRowId);
                if (data.kbn_hin == pageLangText.genryoHinKbn.text || data.kbn_hin == pageLangText.jikaGenryoHinKbn.text) {
                    if (data.cd_hinmei != "" && data.nm_hinmei_ryaku == "") {
                        return false;
                    }
                }
                else {
                    if (data.kbn_hin == "")
                        return false;
                }
                return true;
            };

            //validationSetting.no_lot.rules.custom = function (value, param) {
            //    if (value == "") {
            //        var selectedRowId;
            //        if (!App.isUndef(param))
            //            selectedRowId = param;
            //        else
            //            selectedRowId = getSelectedRowId(false);
            //        if ($("#" + selectedRowId).hasClass("background-grey")) {
            //            return true;
            //        }
            //        var data = grid.getRowData(selectedRowId);
            //        if (data.kbn_hin == "")
            //            return true;
            //        //var data = grid.getRowData(selectedRowId);
            //        //if (data.kbn_hin == pageLangText.genryoHinKbn.text)
            //        return false;
            //        //                    if (data.kbn_hin == pageLangText.shikakariHinKbn.text || data.flg_trace_taishogai == 1)
            //        //                        return true;
            //        //                    if (data.nm_hinmei_ryaku == "") {
            //        //                        return true;
            //        //                    }
            //        //                    return false;
            //        //return true;
            //    }
            //    return true;
            //};

            var setRelatedHinmeiCode = function (selectedRowId, value) {
                if (value == "") {
                    clearRow(selectedRowId);
                    var data = grid.getRowData(selectedRowId);
                    validateCell(selectedRowId, "no_lot", data.no_lot, getIColModel("no_lot"));
                    return;
                }
                var filter = [];
                filter.push("cd_hinmei eq '" + value + "'");
                filter.push("(kbn_hin eq " + pageLangText.genryoHinKbn.text + " or kbn_hin eq " + pageLangText.jikaGenryoHinKbn.text + ")");

                var queryHin = {
                    url: "../Services/FoodProcsService.svc/vw_ma_hinmei_12",
                    filter: filter.join(" and "),
                    inlinecount: "allpages"
                };

                App.ajax.webgetSync(
                    App.data.toODataFormat(queryHin)
                ).done(function (result) {
                    if (result.d.__count > 0) {
                        var res = result.d.results[0];
                        if (!res[hinmeiName]) {
                            grid.setCell(selectedRowId, "nm_hinmei_ryaku", res["nm_hinmei_ryaku"]);
                        }
                        else {
                            grid.setCell(selectedRowId, "nm_hinmei_ryaku", res[hinmeiName]);
                        }
                        grid.setCell(selectedRowId, "nm_nisugata_hyoji", res.nm_nisugata_hyoji);
                        grid.setCell(selectedRowId, "nm_tani_shiyo", res.nm_tani_shiyo);
                        grid.setCell(selectedRowId, "no_lot", null);
                        grid.setCell(selectedRowId, "no_niuke", null);
                        grid.setCell(selectedRowId, "kbn_hin", res.kbn_hin);
                        grid.setCell(selectedRowId, "flg_trace_taishogai", res.flg_trace_taishogai);
                        grid.setCell(selectedRowId, "cd_tani_shiyo", res.cd_tani_shiyo);
                        grid.setCell(selectedRowId, "flg_henko", 1);
                        flg_cd_hinmei_changed = true;

                        var criteria = $(".search-criteria").toJSON();
                        var q = {
                                url: "../api/GenryoLotToroku"
                                , dt_hiduke: criteria.dt_hiduke
                                , no_lot: criteria.no_lot_shikakari
                                , cd_hinmei: value
                                //, no_tonyu: criteria.no_tonyu
                                , no_tonyu: grid.getCell(selectedRowId, "no_tonyu")
                                , flg_lost_focus: true
                         }

                        App.ajax.webgetSync(
                            App.data.toWebAPIFormat(q)
                        ).done(function (resultNiuke) {

                            if (resultNiuke.__count > 0) {
                                grid.setCell(selectedRowId, "no_lot", resultNiuke.d[0]["no_lot"]);
                                grid.setCell(selectedRowId, "no_niuke", resultNiuke.d[0]["no_niuke"]);
                            }
                            validateCell(selectedRowId, "cd_hinmei", value, getIColModel("cd_hinmei"));
                            var data = grid.getRowData(selectedRowId);
                            validateCell(selectedRowId, "no_lot", data.no_lot, getIColModel("no_lot"));
                            var changeData = setUpdatedChangeData(grid.getRowData(selectedRowId));
                            changeSet.addUpdated(selectedRowId, "cd_hinmei", value, changeData);
                            changeSet.addUpdated(selectedRowId, "no_niuke", data.no_niuke, changeData);
                            changeSet.addUpdated(selectedRowId, "flg_henko", data.flg_henko, changeData);
                            changeSet.addUpdated(selectedRowId, "kbn_hin", data.kbn_hin, changeData);
                        });
                    }
                    else {
                        clearRow(selectedRowId);
                        validationSetting.cd_hinmei.params.custom = selectedRowId;
                        validateCell(selectedRowId, "cd_hinmei", value, getIColModel("cd_hinmei"));
                    }
                }).fail(function (result) {
                    var length = result.key.fails.length,
                        messages = [];
                    for (var i = 0; i < length; i++) {
                        var keyName = result.key.fails[i];
                        var value = result.fails[keyName];
                        messages.push(keyName + " " + value.message);
                    }
                    clearRow(selectedRowId);
                    App.ui.page.notifyAlert.message(messages).show();
                }).always(function () {
                    App.ui.loading.close();
                });

            };

            var clearRow = function (selectedRowId) {
                grid.setCell(selectedRowId, "nm_hinmei_ryaku", null);
                grid.setCell(selectedRowId, "nm_nisugata_hyoji", null);
                grid.setCell(selectedRowId, "nm_tani_shiyo", null);
                grid.setCell(selectedRowId, "no_lot", null);
                grid.setCell(selectedRowId, "no_niuke", null);
                grid.setCell(selectedRowId, "kbn_hin", null);
                grid.setCell(selectedRowId, "flg_trace_taishogai", null);
                grid.setCell(selectedRowId, "cd_tani_shiyo", null);
            }

            var setCreatedChangeData = function (row) {
                var changeData = {
                    "cd_hinmei": row.cd_hinmei,
                    "nm_hinmei_ryaku": row.nm_hinmei_ryaku,
                    "cd_tani_shiyo": row.cd_tani_shiyo,
                    "nm_tani_shiyo": row.nm_tani_shiyo,
                    "kbn_hin": row.kbn_hin,
                    "flg_trace_taishogai": row.flg_trace_taishogai,
                    "no_lot": row.no_lot,
                    "biko": row.biko,
                    "no_kotei": row.no_kotei,
                    "no_tonyu": row.no_tonyu,
                    "no_niuke": row.no_niuke,
                    "no_lot_shikakari": row.no_lot_shikakari,
                    "dt_seizo": row.dt_seizo,
                    "cd_shikakari_hin": row.cd_shikakari_hin,
                    "flg_henko": row.flg_henko
                };

                return changeData;
            };

            var setUpdatedChangeData = function (row) {
                var changeData = {
                    "cd_hinmei": row.cd_hinmei,
                    "nm_hinmei_ryaku": row.nm_hinmei_ryaku,
                    "cd_tani_shiyo": row.cd_tani_shiyo,
                    "nm_tani_shiyo": row.nm_tani_shiyo,
                    "kbn_hin": row.kbn_hin,
                    "flg_trace_taishogai": row.flg_trace_taishogai,
                    "no_lot": row.no_lot,
                    "biko": row.biko,
                    "no_kotei": row.no_kotei,
                    "no_tonyu": row.no_tonyu,
                    "no_niuke": row.no_niuke,
                    "no_lot_shikakari": row.no_lot_shikakari,
                    "dt_seizo": row.dt_seizo,
                    "cd_shikakari_hin": row.cd_shikakari_hin,
                    "flg_henko": row.flg_henko,
                    "cd_hinmei_old": row.cd_hinmei_old
                };

                return changeData;
            };

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
                App.ui.page.notifyAlert.remove(unique);
                grid.setCell(selectedRowId, iCol, value, { background: 'none' });
                val[cellName] = value;
                result = v.validate(val, { suppressCallback: false });
                if (result.errors.length) {
                    App.ui.page.notifyAlert.message(result.errors[0].message, unique).show();
                    grid.setCell(selectedRowId, iCol, value, { background: '#ff6666' });
                    return false;
                }
                return true;
            };

            var getIColModel = function (colName) {
                var colModel = grid.getGridParam("colModel");
                for (var i = 1; i < colModel.length; i++) {
                    if (colModel[i].name == colName)
                        return i;
                }
                return -1;
            };

            /// <summary>カレントの行バリデーションを実行します。</summary>
            /// <param name="selectedRowId">選択行ID</param>
            var validateRow = function (selectedRowId) {
                var isValid = true,
                    colModel = grid.getGridParam("colModel"),
                    iRow = $('#' + selectedRowId)[0].rowIndex;
                for (var i = 1; i < colModel.length; i++) {
                    grid.editCell(iRow, i, false);
                    if (!validateCell(selectedRowId, colModel[i].name, grid.getCell(selectedRowId, colModel[i].name), i)) {
                        isValid = false;
                    }
                }
                return isValid;
            };

            var validateAllTable = function () {
                var isValid = true,
                    rowErr = [];
                var countRow = grid.jqGrid('getGridParam', 'records');
                for (var i = 1; i <= countRow; i++) {
                    if (!validateRow(i)) {
                        isValid = false;
                        rowErr.push(i);
                    }
                }
                if (rowErr.length > 0)
                    $("#" + rowErr[0]).removeClass("ui-state-highlight").find("td").click();
                else
                    $("#" + firstCol).removeClass("ui-state-highlight").find("td").click();
                return isValid;
            };

            /// <summary>変更セットのバリデーションを実行します。</summary>
            var validateChangeSet = function () {
                var isValid = true,
                    rowErr = [];
                for (p in changeSet.changeSet.created) {
                    if (!changeSet.changeSet.created.hasOwnProperty(p)) {
                        continue;
                    }

                    if (!validateRow(p)) {
                        isValid = false;
                        rowErr.push(p);
                    }
                }
                for (p in changeSet.changeSet.updated) {
                    if (!changeSet.changeSet.updated.hasOwnProperty(p)) {
                        continue;
                    }

                    if (!validateRow(p)) {
                        isValid = false;
                        rowErr.push(p);
                    }
                }
                if (rowErr.length > 0)
                    $("#" + rowErr[0]).removeClass("ui-state-highlight").find("td").click();
                else
                    $("#" + firstCol).removeClass("ui-state-highlight").find("td").click();
                return isValid;
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
                data.handled = true;
                var info = getAlertInfo(data.unique),
                    iRow = $('#' + info.selectedRowId)[0].rowIndex;

                if (info.iCol === duplicateCol) {
                    info.iCol = firstCol;
                }

                grid.editCell(iRow, info.iCol, true);
            };

            /// <summary>エラー一覧クリック時のイベント処理を行います。</summary>
            $(App.ui.page.notifyAlert).on("itemselected", function (e, data) {
                handleNotifyAlert(data);
            });

            //// 操作制御定義 -- Start
            // 操作制御定義を定義します。
            App.ui.pagedata.operation.applySetting(App.ui.page.user.Roles[0], lang);
            //// 操作制御定義 -- End

            //// 検索処理 -- Start
            // 画面アーキテクチャ共通の検索処理
            /// <summary>クエリオブジェクトの設定</summary>
            var query = function (flg_register) {
                var criteria = $(".search-criteria").toJSON();

                var q = {
                    url: "../api/GenryoLotToroku"
                    , dt_hiduke: App.data.getDateTimeStringForQueryNoUtc(App.date.localDate(criteria.dt_hiduke))
                    , no_lot: criteria.no_lot_shikakari
                    , cd_hinmei: criteria.cd_hinmei
                    , flg_registered: flg_register
                    , lang: lang
                    , skip: querySetting.skip
                    , top: querySetting.top
                }
                return q;
            };

            /// <summary>フィルター条件の設定</summary>
            var createFilter = function () {
                var criteria = $(".search-criteria").toJSON(),
                    filters = [];
                return filters.join(" and ");
            };

            /// <summary>データ検索を行います。</summary>
            /// <param name="query">クエリオブジェクト</param>
            var searchItems = function (query) {
                if (isDataLoading === true) {
                    return;
                }
                isDataLoading = true;
                $("#list-loading-message").text(
                    App.str.format(
                        pageLangText.nowListLoading.text,
                        querySetting.skip + 1,
                        querySetting.top
                    )
                );
                App.ajax.webget(
                    App.data.toWebAPIFormat(query)
                ).done(function (result) {
                    if (parseInt(result.__count) === 0) {
                        App.ui.page.notifyAlert.message(MS0037).show();
                        displayCount(parseInt(result.__count));
                    } else {
                        bindData(result);
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
                clearState();
                var criteria = $(".search-criteria").toJSON(),
                    no_lot_shikakari = criteria.no_lot_shikakari;

                searchShikakari(no_lot_shikakari);
            });

            var searchShikakari = function (no_lot_shikakari) {
                flg_cd_hinmei_changed = false;
                var filter = [];

                if (no_lot_shikakari)
                    filter.push("no_lot_shikakari eq '" + no_lot_shikakari + "'");

                var queryShi = {
                    url: "../Services/FoodProcsService.svc/tr_lot_trace",
                    filter: filter.join(" and "),
                    inlinecount: "allpages"
                };

                App.ui.loading.show(pageLangText.nowProgressing.text);
                isDialogLoading = true;
                App.ajax.webget(
                    App.data.toODataFormat(queryShi)
				).done(function (result) {
				    if (parseInt(result.d.__count) > 0) {
				        //after register
				        isRegistered = true;
				        searchItems(new query(true));
				    }
				    else {
				        //before register
				        isRegistered = false;
				        searchItems(new query(false));
				    }
				}).fail(function (result) {
				    App.ui.page.notifyInfo.message(result.message).show();
				}).always(function () {
				    setTimeout(function () {
				        isDataLoading = false;
				    }, 500);
				    App.ui.loading.close();
				});
            };
            searchShikakari(parameter.no_lot_shikakari);

            // グリッドコントロール固有の検索処理
            /// <summary>検索前の状態に初期化します。</summary>
            var clearState = function () {
                grid.clearGridData();
                lastScrollTop = 0;
                querySetting.skip = 0;
                querySetting.count = 0;
                displayCount();
                currentRow = 0;
                currentCol = firstCol;
                changeSet = new App.ui.page.changeSet();
                App.ui.page.notifyInfo.clear();
                App.ui.page.notifyAlert.clear();
            };

            /// <summary>データ取得件数を表示します。</summary>
            var displayCount = function (resultCount) {
                $("#list-count").text(
                     App.str.format("{0}/{1}", querySetting.count, resultCount)
                );
            };

            /// <summary>データをバインドします。</summary>
            /// <param name="result">検索結果</param>
            var bindData = function (result) {
                grid.setGridParam({ rowNum: querySetting.top });
                var resultCount = parseInt(result.__count);
                if (resultCount > querySetting.top) {
                    App.ui.page.notifyInfo.message(App.str.format(MS0568, querySetting.count, querySetting.count)).show();
                    querySetting.count = querySetting.top;
                }
                else {
                    querySetting.count = resultCount;
                }
                displayCount(resultCount);
                var currentData = grid.getGridParam("data").concat(result.d);
                grid.setGridParam({ data: currentData }).trigger('reloadGrid', [{ current: true}]);
                App.ui.page.notifyInfo.message(App.str.format(pageLangText.searchResultCount.text, querySetting.count, resultCount)).show();
            };

            //// 検索処理 -- End
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
                    resultPartStyle = resultPart[0].currentStyle || document.defaultView.getComputedStyle(resultPart[0], "");

                resultPart.height(container[0].clientHeight - searchPart[0].clientHeight - ((parseInt(resultPartStyle.marginTop, 10) * 3) || 0));
                grid.setGridWidth(resultPart[0].clientWidth - 5);
                grid.setGridHeight(resultPart[0].clientHeight - resultPartHeader[0].clientHeight - resultPart.find(".ui-jqgrid-hdiv")[0].clientHeight - 35);
            };

            /// <summary>画面リサイズ時のイベント処理を行います。</summary>
            $(App.ui.page).on("resized", resizeContents);

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

            ///load dialog
            $("#genryoSentaku").on("click", function () {
                var selectedRowId = getSelectedRowId(false);
                $("#" + selectedRowId).removeClass("ui-state-highlight").find("td").click();
                var key = grid.getGridParam("selrow"),
                    rowData = grid.getRowData(key);
                if (rowData.kbn_hin == pageLangText.shikakariHinKbn.text || rowData.flg_trace_taishogai == 1)
                    return;
                var criteria = $(".search-criteria").toJSON();
                var dt_seizo = App.data.getFromDateStringForQuery(App.date.localDate(criteria.dt_hiduke));
                var option = {
                    cd_genshizai: rowData.cd_hinmei,
                    nm_genshizai: rowData.nm_hinmei_ryaku,
                    no_lot: rowData.no_lot,
                    dt_seizo: dt_seizo
                };

                if (rowData.kbn_hin == pageLangText.genryoHinKbn.text) {
                    option.id = 'genryoLotSentakuDialog';
                    genryoLotSentaku.dlg("open", option);
                    genryoLotSentaku.draggable(true);
                }
                else if (rowData.kbn_hin == pageLangText.jikaGenryoHinKbn.text) {
                    option.id = 'jikaGenryoLotSentakuDialog';
                    jikaGenryoLotSentaku.dlg("open", option);
                    jikaGenryoLotSentaku.draggable(true);
                }
            });

            var genryoLotSentaku = $(".genryo-lot-sentaku-dlg");
            genryoLotSentaku.dlg({
                url: "Dialog/GenryoLotSentakuDialog.aspx",
                name: "GenryoLotSentakuDialog",
                closed: function (e, dlg_no_lot, dlg_no_niuke) {
                    if (dlg_no_lot == "canceled") {
                        return;
                    }
                    var selectedRowId = grid.getGridParam("selrow"),
                        data = grid.getRowData(selectedRowId),
                        no_lot,
                        no_niuke;

                    if (data.no_lot == '') {
                        no_lot = dlg_no_lot;
                        no_niuke = dlg_no_niuke;
                    }
                    else {
                        no_lot = data.no_lot + ',' + dlg_no_lot;
                        no_niuke = data.no_niuke + ',' + dlg_no_niuke;
                    }
                    grid.jqGrid('setCell', selectedRowId, 'no_lot', no_lot);
                    grid.jqGrid('setCell', selectedRowId, 'no_niuke', no_niuke);
                    flg_no_lot_changed = true;
                    var changeData = setUpdatedChangeData(grid.getRowData(selectedRowId));
                    changeSet.addUpdated(selectedRowId, "no_lot", no_lot, changeData);
                    changeSet.addUpdated(selectedRowId, "no_niuke", no_niuke, changeData);
                    validateRow(selectedRowId);
                }
            });

            var jikaGenryoLotSentaku = $(".jika-genryo-lot-sentaku-dlg");
            jikaGenryoLotSentaku.dlg({
                url: "Dialog/JikaGenryoLotSentakuDialog.aspx",
                name: "JikaGenryoLotSentakuDialog",
                closed: function (e, dlg_no_lot) {
                    if (dlg_no_lot == "canceled") {
                        return;
                    }
                    var selectedRowId = grid.getGridParam("selrow"),
                        data = grid.getRowData(selectedRowId),
                        no_lot;

                    if (data.no_lot == '') {
                        no_lot = dlg_no_lot;
                    }
                    else {
                        no_lot = data.no_lot + ',' + dlg_no_lot;
                    }

                    grid.jqGrid('setCell', selectedRowId, 'no_lot', no_lot);
                    grid.jqGrid('setCell', selectedRowId, 'no_niuke', no_lot);
                    flg_no_lot_changed = true;
                    var changeData = setUpdatedChangeData(grid.getRowData(selectedRowId));
                    changeSet.addUpdated(selectedRowId, "no_lot", no_lot, changeData);
                    changeSet.addUpdated(selectedRowId, "no_niuke", no_lot, changeData);
                    validateRow(selectedRowId);
                }
            });

            $("#genryoTorikeshi").on("click", function () {
                var selectedRowId = getSelectedRowId(false);
                $("#" + selectedRowId).removeClass("ui-state-highlight").find("td").click();
                var key = grid.getGridParam("selrow"),
                    rowData = grid.getRowData(key);
                if (rowData.kbn_hin == pageLangText.shikakariHinKbn.text || rowData.flg_trace_taishogai == 1)
                    return;

                var criteria = $(".search-criteria").toJSON();
                var option = {
                    cd_genshizai: rowData.cd_hinmei,
                    nm_genshizai: rowData.nm_hinmei_ryaku,
                    no_lot_shikakari: criteria.no_lot_shikakari,
                    no_kotei: rowData.no_kotei,
                    no_tonyu: rowData.no_tonyu
                };
                if (rowData.kbn_hin == pageLangText.genryoHinKbn.text) {
                    option.id = 'GenryoLotTorikeshiDialog';
                    genryoLotTorikeshi.dlg("open", option);
                    genryoLotTorikeshi.draggable(true);
                }
                else if (rowData.kbn_hin == pageLangText.jikaGenryoHinKbn.text) {
                    option.id = 'jikaGenryoLotTorikeshiDialog';
                    jikaGenryoLotTorikeshi.dlg("open", option);
                    jikaGenryoLotTorikeshi.draggable(true);
                }
            });

            var genryoLotTorikeshi = $(".genryo-lot-torikeshi-dlg");
            genryoLotTorikeshi.dlg({
                url: "Dialog/GenryoLotTorikeshiDialog.aspx",
                name: "GenryoLotTorikeshiDialog",
                closed: function (e, no_lot_dlg) {
                    if (no_lot_dlg == "canceled") {
                        return;
                    }
                    var selectedRowId = grid.getGridParam("selrow"),
                        data = grid.getRowData(selectedRowId),
                        no_lot = [],
                        no_niuke = [],
                        no_lot_cancle = [],
                        no_lot_result = [],
                        no_niuke_result = [];

                    no_lot = data.no_lot.split(',');
                    no_niuke = data.no_niuke.split(',');
                    no_lot_cancle = no_lot_dlg.split(',');

                    for (var i = 0; i < no_lot.length; i++) {
                        var item = no_lot[i],
                            isCancle = false;
                        for (var j = 0; j < no_lot_cancle.length; j++) {
                            if (item == no_lot_cancle[j])
                                isCancle = true;
                        }
                        if (isCancle == false) {
                            no_lot_result.push(item);
                            no_niuke_result.push(no_niuke[i]);
                        }
                    }

                    grid.jqGrid('setCell', selectedRowId, 'no_lot', no_lot_result.length == 0 ? null : no_lot_result.join(","));
                    grid.jqGrid('setCell', selectedRowId, 'no_niuke', no_niuke_result.length == 0 ? null : no_niuke_result.join(","));
                    flg_no_lot_changed = true;
                    var changeData = setUpdatedChangeData(grid.getRowData(selectedRowId));
                    changeSet.addUpdated(selectedRowId, "no_niuke", no_niuke_result.join(","), changeData);
                    validateRow(selectedRowId);
                }
            });

            var jikaGenryoLotTorikeshi = $(".jika-genryo-lot-torikeshi-dlg");
            jikaGenryoLotTorikeshi.dlg({
                url: "Dialog/JikaGenryoLotTorikeshiDialog.aspx",
                name: "JikaGenryoLotTorikeshiDialog",
                closed: function (e, no_lot_dlg) {
                    if (no_lot_dlg == "canceled") {
                        return;
                    }
                    var selectedRowId = grid.getGridParam("selrow"),
                        data = grid.getRowData(selectedRowId),
                        no_lot = [],
                        no_niuke = [],
                        no_lot_cancle = [],
                        no_lot_result = [],
                        no_niuke_result = [];

                    no_lot = data.no_lot.split(',');
                    no_niuke = data.no_niuke.split(',');
                    no_lot_cancle = no_lot_dlg.split(',');

                    for (var i = 0; i < no_lot.length; i++) {
                        var item = no_lot[i],
                            isCancle = false;
                        for (var j = 0; j < no_lot_cancle.length; j++) {
                            if (item == no_lot_cancle[j])
                                isCancle = true;
                        }
                        if (isCancle == false) {
                            no_lot_result.push(item);
                            no_niuke_result.push(no_niuke[i]);
                        }
                    }
                    grid.jqGrid('setCell', selectedRowId, 'no_lot', no_lot_result.length == 0 ? null : no_lot_result.join(","));
                    grid.jqGrid('setCell', selectedRowId, 'no_niuke', no_niuke_result.length == 0 ? null : no_niuke_result.join(","));
                    flg_no_lot_changed = true;
                    var changeData = setUpdatedChangeData(grid.getRowData(selectedRowId));
                    changeSet.addUpdated(selectedRowId, "no_niuke", no_niuke_result.join(","), changeData);
                    validateRow(selectedRowId);
                }
            });

            /// <summary>グリッドの選択行の行IDを取得します。 </summary>
            var getSelectedRowId = function (isAdd) {
                var selectedRowId = grid.getGridParam("selrow"),
                    ids = grid.getDataIDs(),
                    recordCount = grid.getGridParam("records");
                if (recordCount == 0) {
                    if (!isAdd) {
                        App.ui.page.notifyInfo.message(pageLangText.noRecords.text).show();
                    }
                    return;
                }
                if (App.isUnusable(selectedRowId)) {
                    selectedRowId = ids[recordCount - 1];
                }
                currentRow = $('#' + selectedRowId)[0].rowIndex;

                return selectedRowId;
            };

            var hinmeiDialog = $(".hinmei-dialog");
            hinmeiDialog.dlg({
                url: "Dialog/HinmeiDialog.aspx",
                name: "HinmeiDialog",
                closed: function (e, data, data2) {
                    if (data == "canceled") {
                        return;
                    }
                    else {
                        var selectedRowId = getSelectedRowId(false);
                        grid.setCell(selectedRowId, "cd_hinmei", data);
                        var changeData = setUpdatedChangeData(grid.getRowData(selectedRowId));
                        changeSet.addUpdated(selectedRowId, "cd_hinmei", data, changeData);
                        validationSetting.cd_hinmei.params.custom = selectedRowId;
                        validationSetting.no_lot.params.custom = selectedRowId;
                        setRelatedHinmeiCode(selectedRowId, data);
                    }
                }
            });

            /// <summary>データ変更エラーハンドリングを行います。</summary>
            /// <param name="result">エラーの戻り値</param>
            var handleSaveDataError = function (result) {
                var ret = JSON.parse(result.rawText);

                if (!App.isArray(ret) && App.isUndefOrNull(ret.Updated) && App.isUndefOrNull(ret.Deleted)) {
                    App.ui.page.notifyAlert.message(result.message).show();
                    return;
                }
            };

            /// <summary>編集内容の保存</summary>
            var saveEdit = function () {
                grid.saveCell(currentRow, currentCol);
            };

            // <summary>データに変更がないかどうかを返します。</summary>
            var noChange = function () {
                return (App.isUnusable(changeSet) || changeSet.noChange());
            };

            /// <summary>更新データを取得します。</summary>
            var getPostData = function () {
                return changeSet.getChangeSet();
            };

            var confirmDialog = $(".save-confirm-dialog");
            confirmDialog.dlg();

            /// <summary>ダイアログを開きます。</summary>
            var showSaveConfirmDialog = function () {
                confirmDialog.draggable(true);
                confirmDialog.dlg("open");
            };

            var closeConfirm = function () {
                confirmDialog.dlg("close");
            };

            var checkChanged = function () {
                validationSetting.cd_hinmei.params.custom = null;
                validationSetting.no_lot.params.custom = null;
                $("#" + firstCol).removeClass("ui-state-highlight").find("td").click();
                if (flg_cd_hinmei_changed == true) {
                    if (!validateChangeSet()) {
                        return;
                    }
                    showSaveConfirmDialog();
                }
                else {
                    saveData();
                }
            };

            var saveData = function () {
                validationSetting.cd_hinmei.params.custom = null;
                validationSetting.no_lot.params.custom = null;
                flg_no_lot_changed = false;
                confirmDialog.dlg("close");
                App.ui.page.notifyInfo.clear();
                saveEdit();
                if (isDataLoading == true)
                    return;
                if (!validateChangeSet()) {
                    return;
                }

                if (isRegistered == true) {
                    if (!validateAllTable())
                        return;
                }


                App.ui.page.notifyAlert.clear();
                if (noChange()) {
                    App.ui.page.notifyInfo.message(pageLangText.noChange.text).show();
                    return;
                }

                App.ui.loading.show(pageLangText.nowSaving.text);
                isDataLoading = true;
                var criteria = $(".search-criteria").toJSON(),
                     no_lot_shikakari = criteria.no_lot_shikakari;
                var saveUrl = "../api/GenryoLotToroku";
                App.ajax.webpost(
                    saveUrl, getPostData()
                ).done(function (result) {
                    clearState();
                    App.ui.page.notifyInfo.message(pageLangText.successMessage.text).show();
                    var criteria = $(".search-criteria").toJSON(),
                    no_lot_shikakari = criteria.no_lot_shikakari;
                    searchShikakari(no_lot_shikakari);
                }).fail(function (result) {
                    handleSaveDataError(result);
                }).always(function () {
                    isDataLoading = false;
                    App.ui.loading.close();
                });
            };

            $(".dlg-yes-button").on("click", saveData);
            $(".dlg-no-button").on("click", closeConfirm);
            $(".save-button").on("click", checkChanged);

            /// <summary>メニューボタンクリック時のイベント処理を行います。</summary>
            /// <summary>仕込日報に遷移する。遷移後、仕込日報はリロードする。</summary>
            var backToNippo = function () {
                // IEバグによる例外発生をキャッチします。例外発生時は何もしません。
                try {
                    var url = "./ShikomiNippo.aspx";
                    url += "?dt_seizo_st=" + parameter.dt_seizo_st;
                    url += "&dt_seizo_en=" + parameter.dt_seizo_en;
                    url += "&cd_shokuba=" + parameter.cd_shokuba;
                    url += "&cd_line=" + parameter.cd_line;
                    // 伝送状況チェックボックス
                    url += "&chk_mi_sakusei=" + parameter.chk_mi_sakusei;
                    url += "&chk_mi_denso=" + parameter.chk_mi_denso;
                    url += "&chk_denso_machi=" + parameter.chk_denso_machi;
                    url += "&chk_denso_zumi=" + parameter.chk_denso_zumi;
                    // 登録状況チェックボックス
                    url += "&chk_mi_toroku=" + parameter.chk_mi_toroku;
                    url += "&chk_ichibu_mi_toroku=" + parameter.chk_ichibu_mi_toroku;
                    url += "&chk_toroku_sumi=" + parameter.chk_toroku_sumi;
                    window.location = url;
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
    <div class="content-part search-criteria">
        <h3 class="part-header" data-app-text="searchCriteria"><a class="search-part-toggle" href="#"></a></h3>
        <div class="part-body">
            <ul class="item-list">
                <li>
                    <label>
                        <span class="item-label" data-app-text="dt_hiduke_search"></span>
                        <input type="text" name="dt_hiduke" maxlength="10" disabled/>
                    </label>
                </li>
                <li>
                    <label>
                        <span class="item-label" data-app-text="no_lot_search"></span>
                        <input type="text" name="no_lot_shikakari" maxlength="50" disabled/>
                    </label>
                </li>
                <li>
                    <label>
                        <span class="item-label" data-app-text="cd_hinmei_search"></span>
                        <input type="text" name="cd_hinmei" disabled/>
                        <span name="nm_hinmei"></span>
                    </label>
                </li>
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
    <div class="content-part result-list">
        <h3 id="listHeader" class="part-header" >
            <span data-app-text="resultList" style="padding-right: 10px; padding-bottom: 4px;" id="list-results" ></span>
            <span class="list-count" id="list-count" ></span>
            <span style="padding-left: 50px;" class="list-loading-message" id="list-loading-message" ></span>
        </h3>
        <div class="part-body" id="result-grid">
            <div class="item-command">
                <button type="button" class="colchange-button" data-app-operation="colchange">
                    <span class="icon"></span><span data-app-text="colchange">
                    </span>
                </button>
                <button type="button" class="genryo-lot-sentaku" id="genryoSentaku" name="genryo-lot-sentaku-button" data-app-operation="genryoLotSentaku">
                    <span class="icon"></span><span data-app-text="genryoLotSentakuButton"></span>
                </button>
                <button type="button" id="genryoTorikeshi" class="genryo-lot-torikeshi" name="genryo-lot-torikeshi-button" data-app-operation="genryoLotTorikeshi">
                    <span class="icon"></span><span data-app-text="genryoLotTorikeshiButton"></span>
                </button>
            </div>
            <table id="item-grid" data-app-operation="itemGrid">
            </table>
        </div>
    </div>
</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="FooterContent" runat="server">
    <div class="command" style="left: 1px;">
        <button type="button" class="save-button" data-app-operation="save" name="save-button">
            <span class="icon"></span><span data-app-text="save"></span>
        </button>
    </div>
    <div class="command" style="right: 9px;">
    </div>
    <div class="command" style="right: 9px;">
        <button type="button" class="close-button" name="close-button">
            <span class="icon"></span>
            <span data-app-text="close"></span>
        </button>
    </div>
</asp:Content>
<asp:Content ID="Content5" ContentPlaceHolderID="DialogsContent" runat="server">
    <div class="genryo-lot-sentaku-dlg"></div>
    <div class="jika-genryo-lot-sentaku-dlg"></div>
    <div class="genryo-lot-torikeshi-dlg"></div>
    <div class="jika-genryo-lot-torikeshi-dlg"></div>
    <div class="hinmei-dialog"></div>
    <div class="save-confirm-dialog" style="display:none">
        <div class="dialog-header">
            <h4 data-app-text="confirmTitle"></h4>
        </div>
        <div class="dialog-body" style="padding: 10px; width: 100%;">
            <div class="part-body">
                <span data-app-text="contentConfirm"></span>
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
</asp:Content>
