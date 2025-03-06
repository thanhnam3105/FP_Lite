<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="HinmeiMasterIchiran.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.HinmeiMasterIchiran" %>

<asp:Content ID="Content1" ContentPlaceHolderID="IncludeContent" runat="server">
    <script src="<%=ResolveUrl("~/Resources/pages/pagedata-hinmeimasterichiran." + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
    <script src="<%=ResolveUrl("~/Resources/grid/grid.locale-" + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
    <script src="<%=ResolveUrl("~/Scripts/util/app-util.js") %>" type="text/javascript"></script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        /* 画面デザイン -- Start */

        /* TODO：画面の仕様に応じて以下のスタイルを変更してください。 */
        .search-criteria .item-label {
            width: 8em;
        }

        .list-part-detail-content .item-list-left {
            float: left;
            width: 31%;
        }

        .list-part-detail-content .item-list-center {
            float: left;
            width: 35%;
        }

        .list-part-detail-content .item-list-right {
            float: right;
            width: 33%;
            margin-left: 0%;
        }
        
        .list-part-detail-content select {
            width: 5em;
        }
        
        .list-part-detail-content .item-command{
            margin-bottom: 0px;
            border-bottom: none;
        }

        .torihiki-dialog {
            background-color: White;
            width: 550px;
        }

        .torihiki2-dialog {
            background-color: White;
            width: 550px;
        }

        .seizo-dialog {
            background-color: White;
            width: 550px;
        }

        .haigo-dialog {
            background-color: White;
            width: 550px;
        }
        .line-dialog {
            background-color: White;
            width: 500px;
        }

        .item-literalOnly {
            display: inline-block;
            background-color: #F2F2F2;
            border-width: thin;
            border-style: solid;
            border-color: #ACADB3
        }
        .text-align-right {
            text-align: right;
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
        .item-hidden
        {
            display: none;
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
            */

            //// 変数宣言 -- Start

            // 画面アーキテクチャ共通の変数宣言
            var pageLangText = App.ui.pagedata.lang(App.ui.page.lang),
                validationSetting = App.ui.pagedata.validation(App.ui.page.lang),
                validationSetting2 = App.ui.pagedata.validation2(App.ui.page.lang),
                //querySetting = { skip: 0, top: 100, count: 0 },
                querySetting = { skip: 0, top: 300, count: 0 },
                isDataLoading = false;

            // グリッドコントロール固有の変数宣言
            var grid = $("#item-grid"),
                changeSet = new App.ui.page.changeSet(),
                duplicateCol = 999,
                currentRow = 0,
                firstCol = 1,
                maxRecord = 1000,
                nextScrollTop = 0,
                isChanged = false,
                hinmeiName = 'nm_hinmei_' + App.ui.page.lang,
                haigoName = 'nm_haigo_' + App.ui.page.lang,
                lang = App.ui.page.lang,
                nmHin;  // 原資材購入先マスタ遷移用

            // 英語化対応　言語によって幅を調節
            $(".list-part-detail-content .item-label").css("width", pageLangText.each_lang_width.text);
            $(".list-part-detail-content .item-label-right").css("width", pageLangText.item_label_right_width.text);
            $(".list-part-detail-content .item-label-right").css("display", "inline-block");
            $(".list-part-detail-content .unit ").css("width", pageLangText.unit_width.text);
            $(".list-part-detail-content .header-part ").css("width", pageLangText.header_width.text);
            // 未使用チェックボックス時のみ幅を詰める
            $("#fushiyo").css("width", pageLangText.each_fushiyo_width.text);

            // 通貨言語対応　言語によって通貨名変更
            var browseLang = App.ui.page.lang;
            var browseLangCountry = App.ui.page.langCountry;
            var browseCurrency;
            if (browseLang == "ja") {
                $(".currency").text(pageLangText.currencyJa.text);
                browseCurrency = pageLangText.currencyJa.text;
            }
            else if (browseLang == "zh") {
                $(".currency").text(pageLangText.currencyZh.text);
                browseCurrency = pageLangText.currencyZh.text;
            }
            else {
                if (browseLangCountry == "en-US") {
                    $(".currency").text(pageLangText.currencyUs.text);
                    browseCurrency = pageLangText.currencyUs.text;
                }
                else if (browseLangCountry == "en-MY") {
                    $(".currency").text(pageLangText.currencyMs.text);
                    browseCurrency = pageLangText.currencyMs.text;
                }
                else {
                    $(".currency").text(pageLangText.currencyVn.text);
                    browseCurrency = pageLangText.currencyVn.text;
                }
            }

            var torihiki1Dialog = $(".torihiki-dialog");
            var torihiki2Dialog = $(".torihiki2-dialog");
            var seizoDialog = $(".seizo-dialog");
            var haigoDialog = $(".haigo-dialog");

            var bunruiCode;
            var hokanKubun;
            var hinKubun;
            var tani;
            var zeiKubun;
            var niukeCode;
            var kuraireKubun;
            var location;
            var kuraBasho;
            var jotaiKubun;
            var isRequiredCheck;

            var isAdd;
            var isCopy;
            var rowShowData;
            var rowlineCheck;
            var loading;
            var beforeKbnHin;
            var checkFlgMaxMin = false;
            var kbnKotei;
            var kbnTaniHasu;

            // 単位区分によって換算区分の表示名を切り替える
            var nm_kanzan_kg = pageLangText.tani_Kg_text.text;
            var nm_kanzan_Li = pageLangText.tani_L_text.text;
            if (pageLangText.kbn_tani_LB_GAL.text === App.ui.page.user.kbn_tani) {
                nm_kanzan_kg = pageLangText.tani_LB_text.text;
                nm_kanzan_Li = pageLangText.tani_Gal_text.text;
            }

            //// 変数宣言 -- End

            //// コントロール定義 -- Start
            // ダイアログ固有の変数宣言
            var saveConfirmDialog = $(".save-confirm-dialog"),
                saveCompleteDialog = $(".save-complete-dialog"),
                deleteConfirmDialog = $(".delete-confirm-dialog"),
                deleteCompleteDialog = $(".delete-complete-dialog"),
                showgridConfirmDialog = $(".showgrid-confirm-dialog"),
                clearConfirmDialog = $(".clear-confirm-dialog");

            // ダイアログ固有のコントロール定義
            saveConfirmDialog.dlg();
            saveCompleteDialog.dlg();
            deleteConfirmDialog.dlg();
            deleteCompleteDialog.dlg();
            showgridConfirmDialog.dlg();
            clearConfirmDialog.dlg();

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
            var showShowgridConfirmDialog = function () {
                showgridConfirmDialogNotifyInfo.clear();
                showgridConfirmDialogNotifyAlert.clear();
                showgridConfirmDialog.draggable(true);
                showgridConfirmDialog.dlg("open");
            };
            var showClearConfirmDialog = function () {
                clearConfirmDialogNotifyInfo.clear();
                clearConfirmDialogNotifyAlert.clear();
                clearConfirmDialog.draggable(true);
                clearConfirmDialog.dlg("open");
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
            var closeShowgridConfirmDialog = function () {
                showgridConfirmDialog.dlg("close");
            };
            var closeClearConfirmDialog = function () {
                clearConfirmDialog.dlg("close");
            };

            // 日付の多言語対応
            var dateSrcFormat = pageLangText.dateSrcFormatUS.text;
            var newDateFormat = pageLangText.dateTimeNewFormatUS.text;
            if (App.ui.page.langCountry !== 'en-US') {
                dateSrcFormat = pageLangText.dateSrcFormat.text;
                newDateFormat = pageLangText.dateTimeNewFormat.text;
            }

            // グリッドコントロール固有のコントロール定義

            grid.jqGrid({
                colNames: [
                    pageLangText.cd_hinmei.text
                    , pageLangText.nm_hinmei.text
                    , pageLangText.nm_nisugata_hyoji.text
                    , pageLangText.nm_hinmei_ryaku.text
                    , pageLangText.nm_kbn_hin.text
                    , pageLangText.kbn_hin.text
                    , pageLangText.wt_nisugata_naiyo.text
                    , pageLangText.su_iri.text
                    , pageLangText.wt_ko.text
                    , pageLangText.kbn_kanzan.text
                    , pageLangText.nm_kbn_kanzan.text
                    , pageLangText.cd_tani_nonyu.text
                    , pageLangText.tani_nonyu.text
                    , pageLangText.cd_tani_shiyo.text
                    , pageLangText.tani_shiyo.text
                    , pageLangText.ritsu_hiju.text
                    , pageLangText.tan_ko.text
                    , pageLangText.cd_bunrui.text
                    , pageLangText.nm_bunrui.text
                //, pageLangText.dd_shomi.text
                    , pageLangText.kikan_kaifumae_shomi_tani.text
                //, pageLangText.dd_kaifugo_shomi.text
                    , pageLangText.kikan_kaifugo_shomi_tani.text
                    , pageLangText.kikan_kaitogo_shomi_tani.text
                    , pageLangText.kbn_hokan.text
                    , pageLangText.nm_hokan.text
                    , pageLangText.kbn_kaifugo_hokan.text
                    , pageLangText.nm_kaifugo_hokan.text
                    , pageLangText.kbn_kaitogo_hokan.text
                    , pageLangText.nm_kaitogo_hokan.text
                    , pageLangText.kbn_jotai.text
                    , pageLangText.nm_kbn_jotai.text
                    , pageLangText.kbn_zei.text
                    , pageLangText.nm_zei.text // 一覧用の税区分：英語だと間に改行が入る為
                    , pageLangText.ritsu_budomari.text
                    , pageLangText.su_zaiko_min.text
                    , pageLangText.su_zaiko_max.text
                    , pageLangText.cd_niuke_basho.text
                    , pageLangText.nm_niuke.text
                    , pageLangText.dd_leadtime.text
                    , pageLangText.biko.text
                    , pageLangText.flg_mishiyo.text
                    , pageLangText.cd_hanbai_1.text
                    , pageLangText.nm_torihiki1.text
                    , pageLangText.cd_hanbai_2.text
                    , pageLangText.nm_torihiki2.text
                    , pageLangText.cd_haigo.text
                    , pageLangText.nm_haigo.text
                    , pageLangText.cd_jan.text
                    , pageLangText.su_batch_dekidaka.text
                    , pageLangText.su_palette.text
                    , pageLangText.kin_romu.text
                    , pageLangText.kin_keihi_cs.text
                    , pageLangText.kbn_kuraire.text
                    , pageLangText.nm_kbn_kuraire.text
                    , pageLangText.tan_nonyu.text
                //, pageLangText.flg_tenkai.text
                    , pageLangText.cd_seizo.text
                    , pageLangText.nm_seizo.text
                    , pageLangText.cd_maker_hin.text
                    , pageLangText.su_hachu_lot_size.text
                    , pageLangText.cd_kura.text
                    , pageLangText.nm_kura.text
                    , pageLangText.dt_create.text
                    , pageLangText.dt_update.text
                    , pageLangText.cd_create.text
                    , pageLangText.cd_update.text
                    , pageLangText.ts.text
                    , pageLangText.cd_location.text
                    , pageLangText.dd_kotei.text
                    , pageLangText.cd_tani_nonyu_hasu.text
                    , pageLangText.flg_testitem.text
                    , pageLangText.flg_trace_taishogai.text
                ],

                colModel: [
                    { name: 'cd_hinmei', width: pageLangText.cd_hinmei_width.number, frozen: true, sorttype: "int" },
                    { name: hinmeiName, width: pageLangText.nm_hinmei_width.number, frozen: true, sorttype: "text" },
                    { name: 'nm_nisugata_hyoji', width: pageLangText.nm_nisugata_hyoji_width.number, frozen: true, sorttype: "text" },
                    { name: 'nm_hinmei_ryaku', width: pageLangText.nm_hinmei_ryaku_width.number, sorttype: "text", hidden: true },
                    { name: 'nm_kbn_hin', width: pageLangText.nm_kbn_hin_width.number, sorttype: "text", hidden: true },
                    { name: 'kbn_hin', width: 0, hidden: true, hidedlg: true },
                    { name: 'wt_nisugata_naiyo', width: pageLangText.wt_nisugata_naiyo_width.number, sorttype: "float", align: "right", hidden: true,
                        formatter: 'number',
                        formatoptions: {
                            decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 6, defaultValue: ""
                        }
                    },
                    { name: 'su_iri', width: pageLangText.su_iri_width.number, sorttype: "int", align: "right",
                        formatter: 'integer',
                        formatoptions: {
                            thousandsSeparator: ",", defaultValue: ""
                        }
                    },
                    { name: 'wt_ko', width: pageLangText.wt_ko_width.number, sorttype: "float", align: "right",
                        formatter: 'number',
                        formatoptions: {
                            decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 6, defaultValue: ""
                        }
                    },
                    { name: 'kbn_kanzan', width: 0, hidden: true, hidedlg: true },
                    { name: 'nm_kbn_kanzan', width: pageLangText.nm_kbn_kanzan_width.number, sorttype: "text", align: "center",
                        formatter: function (cellvalue, options, rowObject) {
                            var kbn = rowObject.kbn_kanzan;
                            var ret = nm_kanzan_kg;
                            if (kbn == pageLangText.lCdTani.text) {
                                ret = nm_kanzan_Li;
                            }
                            return ret;
                        }
                    },
                    { name: 'cd_tani_nonyu', width: 0, hidden: true, hidedlg: true },
                    { name: 'tani_nonyu', width: pageLangText.tani_nonyu_width.number, sorttype: "text", align: "center" },
                    { name: 'cd_tani_shiyo', width: 0, hidden: true, hidedlg: true },
                    { name: 'tani_shiyo', width: pageLangText.tani_shiyo_width.number, sorttype: "text", align: "center" },
                    { name: 'ritsu_hiju', width: pageLangText.ritsu_hiju_width.number, sorttype: "float", align: "right", hidden: true,
                        formatter: 'number',
                        formatoptions: {
                            decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 4, defaultValue: ""
                        }
                    },
                    { name: 'tan_ko', width: pageLangText.tan_ko_width.number, sorttype: "float", align: "right", hidden: true,
                        formatter: 'number',
                        formatoptions: {
                            decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 4, defaultValue: ""
                        }
                    },
                    { name: 'cd_bunrui', width: 0, hidden: true, hidedlg: true },
                    { name: 'nm_bunrui', width: pageLangText.nm_bunrui_width.number, sorttype: "text" },
                    { name: 'dd_shomi', width: pageLangText.dd_shomi_width.number, sorttype: "int", align: "right" },
                //{ name: 'kikan_kaifumae_shomi_tani', width: pageLangText.kikan_kaifumae_shomi_tani_width.number, sorttype: "text",
                //    formatter: function () {
                //        return pageLangText.shomiTaniMae.text;
                //    }
                //},
                    {name: 'dd_kaifugo_shomi', width: pageLangText.dd_kaifugo_shomi_width.number, sorttype: "int", align: "right" },
                //{ name: 'kikan_kaifugo_shomi_tani', width: pageLangText.kikan_kaifugo_shomi_tani_width.number, sorttype: "text",
                //    formatter: function () {
                //        return pageLangText.shomiTaniAto.text;
                //    }
                //},
                    { name: 'dd_kaitogo_shomi', width: pageLangText.dd_kaitogo_shomi_width.number, sorttype: "int", align: "right" },
                    {name: 'kbn_hokan', width: 0, hidden: true, hidedlg: true },
                    { name: 'nm_hokan', width: pageLangText.nm_hokan_width.number, sorttype: "text" },
                    { name: 'kbn_kaifugo_hokan', width: 0, hidden: true, hidedlg: true },
                    { name: 'nm_kaifugo_hokan', width: pageLangText.nm_kaifugo_hokan_width.number, sorttype: "text" },
                    { name: 'kbn_kaitogo_hokan', width: 0, hidden: true, hidedlg: true },
                    { name: 'nm_kaitogo_hokan', width: pageLangText.nm_kaitogo_hokan_width.number, sorttype: "text" },
                    { name: 'kbn_jotai', width: 0, hidden: true, hidedlg: true },
                    { name: 'nm_kbn_jotai', width: pageLangText.nm_kbn_jotai_width.number, sorttype: "text" },
                    { name: 'kbn_zei', width: 0, hidden: true, hidedlg: true },
                    { name: 'nm_zei', width: 70, sorttype: "text", hidden: true, hidedlg: true },
                    { name: 'ritsu_budomari', width: pageLangText.ritsu_budomari_width.number, sorttype: "float", align: "right",
                        formatter: 'number',
                        formatoptions: {
                            decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 2, defaultValue: ""
                        }
                    },
                    { name: 'su_zaiko_min', width: pageLangText.su_zaiko_min_width.number, sorttype: "float", align: "right",
                        formatter: 'number',
                        formatoptions: {
                            decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 6, defaultValue: ""
                        }
                    },
                    { name: 'su_zaiko_max', width: pageLangText.su_zaiko_max_width.number, sorttype: "float", align: "right", hidden: true,
                        formatter: 'number',
                        formatoptions: {
                            decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 6, defaultValue: ""
                        }
                    },
                    { name: 'cd_niuke_basho', width: 0, hidden: true, hidedlg: true },
                    { name: 'nm_niuke', width: pageLangText.nm_niuke_width.number, sorttype: "text", hidden: true },
                    { name: 'dd_leadtime', width: pageLangText.dd_leadtime_width.number, sorttype: "int", align: "right", hidden: true },
                    { name: 'biko', width: 0, hidden: true, hidedlg: true },
                    { name: 'flg_mishiyo', width: pageLangText.flg_mishiyo_width.number, editable: false, edittype: "checkbox",
                        formatter: "checkbox", align: 'center', editoptions: { value: "1:0" }
                    },
                    { name: 'cd_hanbai_1', width: 0, hidden: true, hidedlg: true },
                    { name: 'nm_torihiki1', width: pageLangText.nm_torihiki1_width.number, sorttype: "text", hidden: true, hidedlg: true },
                    { name: 'cd_hanbai_2', width: 0, hidden: true, hidedlg: true },
                    { name: 'nm_torihiki2', width: pageLangText.nm_torihiki2_width.number, sorttype: "text", hidden: true, hidedlg: true },
                    { name: 'cd_haigo', width: pageLangText.cd_haigo_width.number, sorttype: "text" },
                    { name: haigoName, width: pageLangText.nm_haigo_width.number, sorttype: "text" },
                    { name: 'cd_jan', width: pageLangText.cd_jan_width.number, sorttype: "int", hidden: true, hidedlg: true },
                    { name: 'su_batch_dekidaka', width: pageLangText.su_batch_dekidaka_width.number, sorttype: "float", align: "right", hidden: true,
                        formatter: 'number',
                        formatoptions: {
                            decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 2, defaultValue: ""
                        }
                    },
                    { name: 'su_palette', width: pageLangText.su_palette_width.number, sorttype: "int", align: "right", hidden: true, hidedlg: true,
                        formatter: 'integer',
                        formatoptions: {
                            thousandsSeparator: ",", defaultValue: ""
                        }
                    },
                    { name: 'kin_romu', width: pageLangText.kin_romu_width.number, sorttype: "float", align: "right", hidden: true,
                        formatter: 'number',
                        formatoptions: {
                            decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 4, defaultValue: ""
                        }
                    },
                    { name: 'kin_keihi_cs', width: pageLangText.kin_keihi_cs_width.number, sorttype: "float", align: "right", hidden: true,
                        formatter: 'number',
                        formatoptions: {
                            decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 4, defaultValue: ""
                        }
                    },
                    { name: 'kbn_kuraire', width: 0, hidden: true, hidedlg: true },
                    { name: 'nm_kbn_kuraire', width: pageLangText.nm_kbn_kuraire_width.number, sorttype: "text", align: "center", hidden: true, hidedlg: true },
                    { name: 'tan_nonyu', width: 120, sorttype: "float", align: "right", hidden: true,
                        formatter: 'number',
                        formatoptions: {
                            decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 4, defaultValue: ""
                        }
                    },
                //{ name: 'flg_tenkai', width: pageLangText.nm_kbn_kuraire_width.number, editable: false, edittype: "checkbox", hidden: true,
                //    formatter: "checkbox", align: 'center', editoptions: { value: "1:0" }
                //},
                    {name: 'cd_seizo', width: 120, sorttype: "text", hidden: true, hidedlg: true },
                    { name: 'nm_seizo', width: 200, sorttype: "text", hidden: true, hidedlg: true },
                    { name: 'cd_maker_hin', width: 130, sorttype: "text", hidden: true, hidedlg: true },
                    { name: 'su_hachu_lot_size', width: 130, sorttype: "float", align: "right", hidden: true,
                        formatter: 'number',
                        formatoptions: {
                            decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 2, defaultValue: ""
                        }
                    },
                    { name: 'cd_kura', width: 0, hidden: true, hidedlg: true },
                    { name: 'nm_kura', width: 200, sorttype: "text", hidden: true },
                    { name: 'dt_create', width: 0, hidden: true, hidedlg: true,
                        formatter: "date",
                        formatoptions: {
                            srcformat: dateSrcFormat, newformat: newDateFormat
                        }
                    },
                    { name: 'dt_update', width: 0, hidden: true, hidedlg: true,
                        formatter: "date",
                        formatoptions: {
                            srcformat: dateSrcFormat, newformat: newDateFormat
                        }
                    },
                    { name: 'cd_create', width: 0, hidden: true, hidedlg: true },
                    { name: 'cd_update', width: 0, hidden: true, hidedlg: true },
                    { name: 'ts', width: 0, hidden: true, hidedlg: true },
                    { name: 'cd_location', width: 0, hidden: true, hidedlg: true },
                    { name: 'dd_kotei', width: 0, hidden: true, hidedlg: true },
                    { name: 'cd_tani_nonyu_hasu', width: 0, hidden: true, hidedlg: true },

                    { name: 'flg_testitem', width: 0, hidden: true, editable: false, edittype: "checkbox",
                        formatter: "checkbox", align: 'center', editoptions: { value: "1:0" }
                    },
                    {
                        name: 'flg_trace_taishogai', width: 0, hidden: true, hidedlg: true, editable: false, edittype: "checkbox",
                        formatter: "checkbox", align: 'center', editoptions: { value: "1:0" }
                    },

                ],
                datatype: "local",
                shrinkToFit: false,
                multiselect: false,
                rownumbers: true,
                hoverrows: false,
                gridComplete: function () {
                    // グリッドの先頭行選択
                    // gridCompleteまたはloadCompleteに記述しないとグリッドのソートで先頭行が選択されない
                    grid.setSelection(1, false);
                },
                ondblClickRow: function (selectedRowId) {
                    isAdd = false;
                    isCopy = false;
                    showDetail(false, false);
                }
            });

            // <summary>品区分によるグリッドの表示カラムを制御</summary>
            var changeColumnSetting = function () {
                var _kbn_hin = $(".search-criteria [name='kbn_hin']").val();
                switch (_kbn_hin) {
                    case pageLangText.seihinHinKbn.text:     // 製品
                    case pageLangText.jikaGenryoHinKbn.text: // 自家原料
                        grid.hideCol(["cd_seizo", "nm_seizo", "cd_maker_hin", "su_hachu_lot_size", "nm_kura"]);
                        grid.showCol(["cd_haigo", haigoName]);
                        break;
                    case pageLangText.genryoHinKbn.text: // 原料
                    case pageLangText.shizaiHinKbn.text: // 資材
                        //grid.showCol(["cd_seizo", "nm_seizo", "cd_maker_hin", "su_hachu_lot_size", "nm_kura"]);
                        grid.hideCol(["nm_torihiki1", "nm_torihiki2", "cd_haigo", haigoName, "cd_jan",
                                        "su_batch_dekidaka", "su_palette", "kin_romu", "kin_keihi_cs", "nm_kbn_kuraire",
                        //"tan_nonyu", "flg_tenkai"]);
                                        "tan_nonyu"]);
                        break;
                    case "": // 
                        grid.showCol(["cd_haigo", haigoName]);
                        break;
                    default:
                        break;
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
            $(".colchange-button").on("click", showColumnSettingDialog);

            /// <summary>更新時の同時実行制御エラー時、対象行にDBから取得した値を再設定する。</summary>
            /// <param name="retCurrent">DBから取得した値</param>
            /// <return>再設定した行情報</return>
            var setCurrentData = function (retCurrent) {
                var currentData = {
                    "cd_hinmei": retCurrent.cd_hinmei,
                    "nm_hinmei_ja": retCurrent.nm_hinmei_ja,
                    "nm_hinmei_en": retCurrent.nm_hinmei_en,
                    "nm_hinmei_zh": retCurrent.nm_hinmei_zh,
                    "nm_hinmei_vi": retCurrent.nm_hinmei_vi,
                    "nm_hinmei_ryaku": retCurrent.nm_hinmei_ryaku,
                    "kbn_hin": retCurrent.kbn_hin,
                    "nm_nisugata_hyoji": retCurrent.nm_nisugata_hyoji,
                    "wt_nisugata_naiyo": retCurrent.wt_nisugata_naiyo,
                    "su_iri": retCurrent.su_iri,
                    "wt_ko": retCurrent.wt_ko,
                    "cd_tani_nonyu": retCurrent.cd_tani_nonyu,
                    "cd_tani_shiyo": retCurrent.cd_tani_shiyo,
                    "ritsu_hiju": retCurrent.ritsu_hiju,
                    "tan_ko": retCurrent.tan_ko,
                    "cd_bunrui": retCurrent.cd_bunrui,
                    "dd_kaifugo_shomi": retCurrent.dd_kaifugo_shomi,
                    "dd_kaitogo_shomi": retCurrent.dd_kaitogo_shomi,
                    "dd_shomi": retCurrent.dd_shomi,
                    "kbn_hokan": retCurrent.kbn_hokan,
                    "kbn_kaifugo_hokan": retCurrent.kbn_kaifugo_hokan,
                    "kbn_kaitogo_hokan": retCurrent.kbn_kaitogo_hokan,
                    "kbn_jotai": retCurrent.kbn_jotai,
                    "kbn_zei": retCurrent.kbn_zei,
                    "ritsu_budomari": retCurrent.ritsu_budomari,
                    "su_zaiko_max": retCurrent.su_zaiko_max,
                    "su_zaiko_min": retCurrent.su_zaiko_min,
                    "cd_niuke_basho": retCurrent.cd_niuke_basho,
                    "dd_leadtime": retCurrent.dd_leadtime,
                    "biko": retCurrent.biko,
                    "su_batch_dekidaka": retCurrent.su_batch_dekidaka,
                    "su_palette": retCurrent.su_palette,
                    "kin_romu": retCurrent.kin_romu,
                    "kin_keihi_cs": retCurrent.kin_keihi_cs,
                    "kbn_kuraire": retCurrent.kbn_kuraire,
                    "tan_nonyu": retCurrent.tan_nonyu,
                    "cd_maker_hin": retCurrent.cd_maker_hin,
                    "su_hachu_lot_size": retCurrent.su_hachu_lot_size,
                    "cd_haigo": retCurrent.cd_haigo,
                    "cd_hanbai_1": retCurrent.cd_hanbai_1,
                    "nm_torihiki1": retCurrent.nm_torihiki1,
                    "cd_hanbai_2": retCurrent.cd_hanbai_2,
                    "nm_torihiki2": retCurrent.nm_torihiki2,
                    "cd_seizo": retCurrent.cd_seizo,
                    "nm_seizo": retCurrent.nm_seizo,
                    "cd_jan": retCurrent.cd_jan,
                    "kbn_kanzan": retCurrent.kbn_kanzan,
                    //"flg_tenkai": retCurrent.flg_tenkai,
                    "cd_kura": retCurrent.cd_kura,
                    "cd_create": retCurrent.cd_create,
                    "dt_create": getFormatDate(retCurrent.dt_create),
                    "cd_update": retCurrent.cd_update,
                    "dt_update": getFormatDate(retCurrent.dt_update),
                    "flg_mishiyo": retCurrent.flg_mishiyo,
                    "ts": retCurrent.ts,
                    "location": retCurrent.cd_location,
                    "flg_testitem": retCurrent.flg_testitem,
                    "flg_trace_taishogai": retCurrent.flg_trace_taishogai
                };

                return currentData;
            };

            //// コントロール定義 -- End

            //// メッセージ表示 -- Start
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
            //// メッセージ表示 -- End
            //---------------------------------------------------------
            //2019/07/24 trinh.bd Task #14029
            //------------------------START----------------------------
            //// 操作制御定義
            //App.ui.pagedata.operation.applySetting(App.ui.page.user.Roles[0], App.ui.page.lang);
            var kbn_ma_hinmei = App.ui.page.user.kbn_ma_hinmei;
            if (kbn_ma_hinmei == pageLangText.isRoleFisrt.number) {
                App.ui.pagedata.operation.applySetting("isRoleFisrt", App.ui.page.lang);
            }
            else if (kbn_ma_hinmei == pageLangText.isRoleSecond.number) {
                App.ui.pagedata.operation.applySetting("isRoleSecond", App.ui.page.lang);
            } else {
                App.ui.pagedata.operation.applySetting("NotRole", App.ui.page.lang);
            }

            //原資材購入先マスタで「権限なし（空白）」の場合、品名明細画面の「購入先マスタ」ボタンを非表示にする。
            var kbn_ma_konyusaki = App.ui.page.user.kbn_ma_konyusaki;
            if (kbn_ma_konyusaki == pageLangText.isRoleKonyusaki.number) {
                $("[data-app-operation='konyuButton']").remove();
            } else {
                $("[data-app-operation='konyuButton']").show();
            }
            //------------------------END------------------------------
            //// 事前データロード -- Start 
            var createFilterDialog = function (_gamen) {
                var criteria,
                filters = [];
                if (_gamen == "ichiran") {
                    criteria = $(".search-criteria").toJSON();
                }
                else {
                    criteria = $(".list-part-detail-content").toJSON();
                }

                filters.push("kbn_hin eq " + criteria.kbn_hin);
                filters.push("flg_mishiyo eq " + pageLangText.shiyoMishiyoFlg.text);

                return filters.join(" and ");
            };

            // 画面アーキテクチャ共通の事前データロード
            App.deferred.parallel({
                loading: App.ui.loading.show(pageLangText.nowProgressing.text),
                // 品区分
                hinKubun: App.ajax.webget("../Services/FoodProcsService.svc/ma_kbn_hin?$filter=kbn_hin eq " + pageLangText.seihinHinKbn.text
                    + " or kbn_hin eq " + pageLangText.genryoHinKbn.text + " or kbn_hin eq " + pageLangText.shizaiHinKbn.text + " or kbn_hin eq "
                    + pageLangText.jikaGenryoHinKbn.text + "&$orderby=kbn_hin"),
                // 保管区分
                hokanKubun: App.ajax.webget("../Services/FoodProcsService.svc/ma_kbn_hokan?$filter=flg_mishiyo eq "
                    + pageLangText.shiyoMishiyoFlg.text + "&$orderby=cd_hokan_kbn"),
                // 単位
                tani: App.ajax.webget("../Services/FoodProcsService.svc/ma_tani?$filter=flg_mishiyo eq "
                    + pageLangText.shiyoMishiyoFlg.text + "&$orderby=cd_tani"),
                // 税区分
                //zeiKubun: App.ajax.webget("../Services/FoodProcsService.svc/ma_zei?$orderby=kbn_zei"),
                // 荷受場所
                niukeCode: App.ajax.webget("../Services/FoodProcsService.svc/vw_ma_niuke_kbn_niuke?$orderby=cd_niuke_basho"),
                // 庫場所
                kuraBasho: App.ajax.webget("../Services/FoodProcsService.svc/ma_kura?$filter=flg_mishiyo eq "
                    + pageLangText.shiyoMishiyoFlg.text + "&$orderby=cd_kura"),
                // 庫入区分
                //kuraireKubun: App.ajax.webget("../Services/FoodProcsService.svc/ma_kbn_kuraire?$orderby=kbn_kuraire"),
                // 状態区分
                jotaiKubun: App.ajax.webget("../Services/FoodProcsService.svc/ma_kbn_jotai?$filter=kbn_jotai eq "
                    + pageLangText.kotaiJotaiKbn.text + " or kbn_jotai eq " + pageLangText.ekitaiJotaiKbn.text
                    + " or kbn_jotai eq " + pageLangText.hankotaiJotaiKbn.text
                    + "&$orderby=kbn_jotai"),
                //ロケーション
                location: App.ajax.webget("../Services/FoodProcsService.svc/ma_location?$filter=flg_mishiyo eq " + pageLangText.shiyoMishiyoFlg.text + "&$orderby=cd_location"),
                //固定日区分
                kbnKotei: App.ajax.webget("../Services/FoodProcsService.svc/cn_kino_sentaku?$filter=kbn_kino eq " + pageLangText.kinoKoteibiKbn.number),
                //納入単位(端数)区分
                kbnTaniHasu: App.ajax.webget("../Services/FoodProcsService.svc/cn_kino_sentaku?$filter=kbn_kino eq " + pageLangText.kinoTaniHasuKbn.number),
                // 必須チェック切替区分
                kinoRequiredKbn: App.ajax.webget("../Services/FoodProcsService.svc/cn_kino_sentaku?$filter=kbn_kino eq " + pageLangText.kinoRequiredKbn.number)
            }).done(function (result) {
                hinKubun = result.successes.hinKubun.d;
                tani = result.successes.tani.d;
                hokanKubun = result.successes.hokanKubun.d;
                //zeiKubun = result.successes.zeiKubun.d;
                niukeCode = result.successes.niukeCode.d;
                kuraBasho = result.successes.kuraBasho.d;
                //kuraireKubun = result.successes.kuraireKubun.d;
                location = result.successes.location.d;
                jotaiKubun = result.successes.jotaiKubun.d;
                var kinoRequiredKbn = result.successes.kinoRequiredKbn.d;
                if (result.successes.kbnKotei.d.length == 0) {
                    kbnKotei = 0;
                }
                else {
                    kbnKotei = result.successes.kbnKotei.d[0].kbn_kino_naiyo;
                }
                if (result.successes.kbnTaniHasu.d.length == 0) {
                    kbnTaniHasu = 0;
                }
                else {
                    kbnTaniHasu = result.successes.kbnTaniHasu.d[0].kbn_kino_naiyo;
                }

                // 必須チェック切替区分(賞味期間、開封後賞味期間、保管区分、開封後保管区分)
                if (kinoRequiredKbn.length) {
                    isRequiredCheck = kinoRequiredKbn[0].kbn_kino_naiyo;
                }
                else {
                    // 取得できない場合は必須で設定します。
                    isRequiredCheck = pageLangText.kinoRequired.number;
                }

                // 検索用ドロップダウンの設定
                App.ui.appendOptions($(".search-criteria [name='kbn_hin']"), "kbn_hin", "nm_kbn_hin", hinKubun, false);
                App.ui.appendOptions($(".search-criteria [name='kbn_hokan']"), "cd_hokan_kbn", "nm_hokan_kbn", hokanKubun, true);
                searchBunruiCode("ichiran");
                // 詳細用ドロップダウンの設定
                App.ui.appendOptions($(".list-part-detail-content [name='cd_tani_nonyu']"), "cd_tani", "nm_tani", tani, false);
                App.ui.appendOptions($(".list-part-detail-content [name='cd_tani_shiyo']"), "cd_tani", "nm_tani", tani, false);
                App.ui.appendOptions($(".list-part-detail-content [name='kbn_hokan_detail']"), "cd_hokan_kbn", "nm_hokan_kbn", hokanKubun, true);
                App.ui.appendOptions($(".list-part-detail-content [name='kbn_kaifugo_hokan_detail']"), "cd_hokan_kbn", "nm_hokan_kbn", hokanKubun, true);
                App.ui.appendOptions($(".list-part-detail-content [name='kbn_kaitogo_hokan_detail']"), "cd_hokan_kbn", "nm_hokan_kbn", hokanKubun, true);
                //App.ui.appendOptions($(".list-part-detail-content [name='kbn_zei']"), "kbn_zei", "nm_zei", zeiKubun, false);
                App.ui.appendOptions($(".list-part-detail-content [name='cd_niuke_basho']"), "cd_niuke_basho", "nm_niuke", niukeCode, true);
                App.ui.appendOptions($(".list-part-detail-content [name='cd_kura']"), "cd_kura", "nm_kura", kuraBasho, true);
                App.ui.appendOptions($(".list-part-detail-content [name='kbn_hin']"), "kbn_hin", "nm_kbn_hin", hinKubun, false);
                //App.ui.appendOptions($(".list-part-detail-content [name='kbn_kuraire']"), "kbn_kuraire", "nm_kbn_kuraire", kuraireKubun, false);
                App.ui.appendOptions($(".list-part-detail-content [name='cd_location']"), "cd_location", "nm_location", location, true);
                App.ui.appendOptions($(".list-part-detail-content [name='kbn_jotai']"), "kbn_jotai", "nm_kbn_jotai", jotaiKubun, true);
                App.ui.appendOptions($(".list-part-detail-content [name='cd_tani_nonyu_hasu']"), "cd_tani", "nm_tani", tani, false);
                searchBunruiCode("toroku");
                setLiteral("cd_hinmei", pageLangText.cd_hinmei.text, true);
                setLiteral("kbn_hin", pageLangText.nm_kbn_hin.text, true);
                setLiteral("su_iri", pageLangText.su_iri.text, true);
                setLiteral("wt_ko", pageLangText.wt_ko.text, true);
                setLiteral("nm_hinmei_ja", pageLangText.nm_hinmei_ja.text, true);
                setLiteral("nm_hinmei_en", pageLangText.nm_hinmei_en.text, true);
                setLiteral("nm_hinmei_zh", pageLangText.nm_hinmei_zh.text, true);
                setLiteral("nm_hinmei_vi", pageLangText.nm_hinmei_vi.text, true);
            }).fail(function (result) {
                var length = result.key.fails.length,
                        messages = [];
                for (var i = 0; i < length; i++) {
                    var keyName = result.key.fails[i];
                    var value = result.fails[keyName];
                    messages.push(keyName + " " + value.message);
                }

                App.ui.loading.close();
                App.ui.page.notifyAlert.message(messages).show();
            }).always(function () {
                App.ui.loading.close();
            });

            // 検索用ドロップダウン（データベース名）の設定
            var searchBunruiCode = function (_gamen, _value) {
                var _query = {
                    url: "../Services/FoodProcsService.svc/ma_bunrui",
                    filter: createFilterDialog(_gamen),
                    orderby: "cd_bunrui"
                }
                App.ajax.webgetSync(
                    App.data.toODataFormat(_query)
                ).done(function (result) {
                    //                    var bunruiCode = result.d;
                    bunruiCode = result.d;
                    // 検索用ドロップダウンの設定
                    if (_gamen == "ichiran") {
                        $(".search-criteria [name='cd_bunrui'] > option").remove();
                        App.ui.appendOptions($(".search-criteria [name='cd_bunrui']"), "cd_bunrui", "nm_bunrui", bunruiCode, true);
                        // 保管区分のクリア
                        $("#id_kbn_hokan").val("");
                        // 品区分が資材のとき：保管区分を操作不可にする
                        if ($("#id_kbn_hin").val() == pageLangText.shizaiHinKbn.text) {
                            $("#id_kbn_hokan").attr("disabled", true);
                        }
                        else {
                            $("#id_kbn_hokan").attr("disabled", false);
                        }
                    }
                    else {
                        $(".list-part-detail-content [name='cd_bunrui'] > option").remove();
                        App.ui.appendOptions($(".list-part-detail-content [name='cd_bunrui']"), "cd_bunrui", "nm_bunrui", bunruiCode, false);
                    }
                    if (_value) {
                        $(".list-part-detail-content [name='cd_bunrui']").val(_value);
                    }
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                });
            };

            // 品区分による項目制御の設定（詳細画面）
            var controlDispDetail = function () {
                var _kbnHin = $(".list-part-detail-content [name='kbn_hin']").val();

                // 全項目クリア
                $(".list-part-detail-content .all").attr("disabled", false).css("background-color", "");
                setLiteral("ritsu_hiju", pageLangText.ritsu_hiju.text, false);
                //setLiteral("kbn_zei", pageLangText.kbn_zei.text, false);
                setLiteral("cd_haigo", pageLangText.nm_haigo.text, false);
                //setLiteral("kbn_kuraire", pageLangText.kbn_kuraire.text, false);
                //setLiteral("line-label", pageLangText.line.text, false);
                setLiteral("cd_niuke_basho", pageLangText.cd_niuke_basho.text, false);
                // 2020/08/19 #696 Add BRC.sonoyama start
                if (isRequiredCheck === pageLangText.kinoRequired.number) {
                    setLiteral("dd_shomi", pageLangText.dd_shomi.text, false);
                    setLiteral("dd_kaifugo_shomi", pageLangText.dd_kaifugo_shomi.text, false);
                    setLiteral("kbn_hokan_detail", pageLangText.kbn_hokan.text, false);
                    setLiteral("kbn_kaifugo_hokan_detail", pageLangText.kbn_kaifugo_hokan.text, false);
                }
                // 2020/08/19 #696 Add BRC.sonoyama end

                if (kbnKotei != pageLangText.kbnKoteibiShiyo.number) {
                    $(".kbnKotei").css("display", "none");
                }
                if (kbnTaniHasu != pageLangText.kbnTaniHasuShiyo.number) {
                    $(".kbnTaniHasu").css("display", "none");
                }
                switch (_kbnHin) {
                    case pageLangText.seihinHinKbn.text: // 製品
                        $(".list-part-detail-content .seihin-disp-no").attr("disabled", true).css("background-color", "#F2F2F2");
                        setLiteral("ritsu_hiju", pageLangText.ritsu_hiju.text, true);
                        setLiteral("cd_haigo", pageLangText.nm_haigo.text, true);
                        //setLiteral("kbn_kuraire", pageLangText.kbn_kuraire.text, true);
                        //setLiteral("line-label", pageLangText.line.text, true);
                        $(".list-part-detail-content [name='flg_trace_taishogai']").attr("disabled", true).attr('checked', false);
                        break;
                    case pageLangText.jikaGenryoHinKbn.text: // 自家原料
                        $(".list-part-detail-content .jikagen-disp-no").attr("disabled", true).css("background-color", "#F2F2F2");
                        setLiteral("ritsu_hiju", pageLangText.ritsu_hiju.text, true);
                        //setLiteral("kbn_zei", pageLangText.kbn_zei.text, true);
                        setLiteral("cd_haigo", pageLangText.nm_haigo.text, true);
                        //setLiteral("kbn_kuraire", pageLangText.kbn_kuraire.text, true);
                        //setLiteral("line-label", pageLangText.line.text, true);
                        setLiteral("cd_niuke_basho", pageLangText.cd_niuke_basho.text, true);
                        // 2020/08/19 #696 Add BRC.sonoyama start
                        if (isRequiredCheck === pageLangText.kinoRequired.number) {
                            setLiteral("dd_shomi", pageLangText.dd_shomi.text, true);
                            setLiteral("dd_kaifugo_shomi", pageLangText.dd_kaifugo_shomi.text, true);
                            setLiteral("kbn_hokan_detail", pageLangText.kbn_hokan.text, true);
                            setLiteral("kbn_kaifugo_hokan_detail", pageLangText.kbn_kaifugo_hokan.text, true);
                        }
                        // 2020/08/19 #696 Add BRC.sonoyama end
                        $(".list-part-detail-content [name='flg_trace_taishogai']").attr("disabled", false);
                        break;
                    case pageLangText.genryoHinKbn.text: // 原料
                        $(".list-part-detail-content .genryo-disp-no").attr("disabled", true).css("background-color", "#F2F2F2");
                        setLiteral("ritsu_hiju", pageLangText.ritsu_hiju.text, true);
                        //setLiteral("kbn_zei", pageLangText.kbn_zei.text, true);
                        setLiteral("cd_niuke_basho", pageLangText.cd_niuke_basho.text, true);
                        // 2020/08/19 #696 Add BRC.sonoyama start
                        if (isRequiredCheck === pageLangText.kinoRequired.number) {
                            setLiteral("dd_shomi", pageLangText.dd_shomi.text, true);
                            setLiteral("dd_kaifugo_shomi", pageLangText.dd_kaifugo_shomi.text, true);
                            setLiteral("kbn_hokan_detail", pageLangText.kbn_hokan.text, true);
                            setLiteral("kbn_kaifugo_hokan_detail", pageLangText.kbn_kaifugo_hokan.text, true);
                        }
                        // 2020/08/19 #696 Add BRC.sonoyama end
                        $(".list-part-detail-content [name='flg_trace_taishogai']").attr("disabled", false);
                        break;
                    case pageLangText.shizaiHinKbn.text: // 資材
                        $(".list-part-detail-content .shizai-disp-no").attr("disabled", true).css("background-color", "#F2F2F2");
                        //setLiteral("kbn_zei", pageLangText.kbn_zei.text, true);
                        setLiteral("cd_niuke_basho", pageLangText.cd_niuke_basho.text, true);
                        $(".list-part-detail-content [name='flg_trace_taishogai']").attr("disabled", true).attr('checked', false);
                        break;
                    default:
                        break;
                }
            };

            // 検索条件：品区分変更時の処理
            $(".search-criteria [name='kbn_hin']").on("change", function (e) {
                searchBunruiCode("ichiran");
            });
            // 詳細：品区分
            //$(".list-part-detail-content [name='kbn_hin']").on("change", function (e) {
            $(".list-part-detail-content [name='kbn_hin']")
            // 変更時の処理
                .on("change", function (e) {
                    // 変更前の区分にバリデーションエラーが残っていた場合は品区分を戻す
                    if (!checkValidationHinKbn(beforeKbnHin)) {
                        App.ui.page.notifyInfo.clear();
                        App.ui.page.notifyInfo.message(pageLangText.inputValueError.text).show();
                        $(".list-part-detail-content [name='kbn_hin']").val(beforeKbnHin);
                        return;
                    }

                    App.ui.page.notifyAlert.clear();
                    searchBunruiCode("toroku");
                    controlDispDetail();
                })
            // フォーカスをあてたときの処理：チェック用に、変更前の品区分を保持しておく
                .focusin(function () {
                    beforeKbnHin = $(".list-part-detail-content [name='kbn_hin']").val();
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

                var criteria = $(".search-criteria").toJSON();

                var query = {
                    url: "../api/HinmeiMaster",
                    con_kbn_hin: criteria.kbn_hin,
                    con_bunrui: criteria.cd_bunrui,
                    con_kbn_hokan: criteria.kbn_hokan,
                    con_hinmei: encodeURIComponent(criteria.nm_hinmei),
                    mishiyo_hyoji: criteria.flg_mishiyo,
                    lang: App.ui.page.lang,
                    kbnUriagesaki: pageLangText.uriagesakiToriKbn.text,
                    kbnSeizomoto: pageLangText.seizomotoToriKbn.text,
                    flgShiyo: pageLangText.shiyoMishiyoFlg.text,
                    hanNo: pageLangText.systemValueOne.text,
                    //filter: createFilter(),
                    //orderby: "cd_hinmei, kbn_hin, cd_bunrui",
                    //skip: querySetting.skip,
                    top: querySetting.top
                    //inlinecount: "allpages"
                };
                return query;
            };
            /// <summary>フィルター条件の設定</summary>
            var createFilter = function () {
                var criteria = $(".search-criteria").toJSON(),
                    filters = [];

                if (!App.isUndefOrNull(criteria.cd_bunrui) && criteria.cd_bunrui.length > 0) {
                    filters.push("cd_bunrui eq '" + criteria.cd_bunrui + "'");
                }
                if (!App.isUndefOrNull(criteria.kbn_hokan) && criteria.kbn_hokan.length > 0) {
                    filters.push("kbn_hokan eq '" + criteria.kbn_hokan + "'");
                }
                if (!App.isUndefOrNull(criteria.kbn_hin) && criteria.kbn_hin.length > 0) {
                    filters.push("kbn_hin eq " + criteria.kbn_hin);
                }
                if (!App.isUndefOrNull(criteria.nm_hinmei) && criteria.nm_hinmei.length > 0) {
                    filters.push("substringof('" + encodeURIComponent(criteria.nm_hinmei) + "', " + hinmeiName + ") eq true");
                }
                if (criteria.flg_mishiyo == pageLangText.shiyoMishiyoFlg.text) {
                    filters.push("flg_mishiyo eq " + criteria.flg_mishiyo);
                }

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
                //$("#list-loading-message").text(
                //    App.str.format(
                //        pageLangText.nowListLoading.text,
                //        querySetting.skip + 1,
                //        querySetting.top
                //    )
                //);
                $("#list-loading-message").text(pageLangText.nowLoading.text);
                App.ajax.webget(
                    App.data.toWebAPIFormat(query)
                ).done(function (result) {
                    // データバインド
                    bindData(result);
                    // 検索条件を閉じる
                    closeCriteria();
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                }).always(function () {
                    // ローディングの終了
                    setTimeout(function () {
                        $("#list-loading-message").text("");
                        isDataLoading = false;
                    }, 500);
                    App.ui.loading.close();
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
                var searchPart = $(".search-criteria"),
                    result;
                result = searchPart.validation().validate();
                if (result.errors.length) {
                    return;
                }
                showGrid();
                clearState();
                changeColumnSetting();
                searchItems(new query());
            });

            // グリッドコントロール固有の検索処理

            /// <summary>検索前の状態に初期化します。</summary>
            var clearState = function () {
                // データクリア
                grid.clearGridData();
                lastScrollTop = 0;
                nextScrollTop = 0;
                querySetting.skip = 0;
                querySetting.count = 0;
                displayCount();

                currentRow = 0;

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
                var resultLength = result.d.length,
                    resultCount = result.__count;
                result = result.d;

                querySetting.skip = querySetting.skip + resultCount;
                querySetting.count = parseInt(resultCount);

                // 検索結果が上限数を超えていた場合
                if (parseInt(resultLength) > querySetting.top) {
                    // 上限数を超えた検索結果は削除する
                    result.splice(querySetting.top, resultLength);
                    querySetting.skip = querySetting.top;
                    App.ui.page.notifyAlert.message(pageLangText.limitOver.text).show();
                }

                // グリッドの表示件数を更新
                grid.setGridParam({ rowNum: querySetting.skip });
                displayCount();
                // カラムの固定解除
                grid.destroyFrozenColumns();
                // データバインド
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

            //// 検索処理 -- End

            //// データ変更処理 -- Start

            /// <summary>新規行データの設定を行います。</summary>
            var setAddData = function () {
                // kbn_kanzan,line,flg_tenkai,cd_kura
                var addData = {
                    "cd_hinmei": "",
                    "nm_hinmei_ja": "",
                    "nm_hinmei_en": "",
                    "nm_hinmei_zh": "",
                    "nm_hinmei_vi": "",
                    "nm_hinmei_ryaku": "",
                    "kbn_hin": $("#id_kbn_hin").val(),
                    "nm_nisugata_hyoji": "",
                    "wt_nisugata_naiyo": "",
                    "su_iri": "",
                    "wt_ko": "",
                    "cd_tani_nonyu": pageLangText.caseCdTani.text,
                    "cd_tani_shiyo": pageLangText.kgCdTani.text,
                    "ritsu_hiju": "1.0000",
                    "tan_ko": "",
                    "cd_bunrui": $("#id_cd_bunrui").val(),
                    "dd_shomi": "",
                    "dd_kaifugo_shomi": "",
                    "dd_kaitogo_shomi": "",
                    "kbn_hokan": "",
                    "kbn_kaifugo_hokan": "",
                    "kbn_kaitogo_hokan": "",
                    "kbn_jotai": "",
                    "kbn_zei": pageLangText.sotoZeiKbn.text,
                    "ritsu_budomari": "",
                    "su_zaiko_min": "",
                    "su_zaiko_max": "",
                    "cd_niuke_basho": "",
                    "dd_leadtime": "",
                    "biko": "",
                    "su_batch_dekidaka": "",
                    "su_palette": "",
                    "kin_romu": "",
                    "kin_keihi_cs": "",
                    "kbn_kuraire": pageLangText.sokuKuraireKuraireKbn.text,
                    "tan_nonyu": "",
                    "cd_maker_hin": "",
                    "su_hachu_lot_size": "",
                    "cd_haigo": "",
                    "nm_haigo": "",
                    "cd_hanbai_1": "",
                    "nm_torihiki1": "",
                    "cd_hanbai_2": "",
                    "nm_torihiki2": "",
                    "cd_seizo": "",
                    "nm_seizo": "",
                    "cd_jan": "",
                    "flg_tenkai": pageLangText.falseFlg.text,
                    "kbn_kanzan": pageLangText.kgKanzanKbn.text,
                    "cd_kura": "",
                    "dt_create": "",
                    "dt_update": "",
                    "flg_mishiyo": pageLangText.shiyoMishiyoFlg.text,
                    "ts": "",
                    "location": "",
                    "dd_kotei": "0",
                    "cd_tani_nonyu_hasu": "",
                    "flg_testitem": pageLangText.falseFlg.text,
                    "flg_trace_taishogai": pageLangText.falseFlg.text,
                };

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
                    //                    selectedRowId = ids[recordCount - 1]; //最終行
                    selectedRowId = ids[0]; // 先頭行
                }
                currentRow = $('#' + selectedRowId)[0].rowIndex;

                return selectedRowId;
            };

            //// データ変更処理 -- End

            //// 保存処理 -- Start

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
                        App.ui.page.notifyAlert.message(
                            pageLangText.invalidation.text + ret[0].Message).show();
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
                        var data = setCurrentData(upCurrent);
                        // カレントのデータを詳細画面へ表示
                        detailContent.toForm(data);

                        searchBunruiCode("toroku", data.cd_bunrui);
                        controlDispDetail();
                        getTorihiki(upCurrent.cd_hanbai_1, pageLangText.uriagesakiToriKbn.text, "torihiki1", "hanbai_1", pageLangText.nm_torihiki1.text);
                        getTorihiki(upCurrent.cd_hanbai_2, pageLangText.uriagesakiToriKbn.text, "torihiki2", "hanbai_2", pageLangText.nm_torihiki2.text);
                        getTorihiki(upCurrent.cd_seizo, pageLangText.seizomotoToriKbn.text, "seizo", "seizo", pageLangText.nm_seizo.text);
                        getHaigo(upCurrent.cd_haigo);

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
                        var delData = setCurrentData(delCurrent);
                        // カレントのデータを詳細画面へ表示
                        detailContent.toForm(delData);

                        searchBunruiCode("toroku", delData.cd_bunrui);
                        controlDispDetail();
                        getTorihiki(delCurrent.cd_hanbai_1, pageLangText.uriagesakiToriKbn.text, "torihiki1", "hanbai_1", pageLangText.nm_torihiki1.text);
                        getTorihiki(delCurrent.cd_hanbai_2, pageLangText.uriagesakiToriKbn.text, "torihiki2", "hanbai_2", pageLangText.nm_torihiki2.text);
                        getTorihiki(delCurrent.cd_seizo, pageLangText.seizomotoToriKbn.text, "seizo", "seizo", pageLangText.nm_seizo.text);
                        getHaigo(delCurrent.cd_haigo);

                        // エラーメッセージの表示
                        App.ui.page.notifyAlert.message(
                            pageLangText.duplicate.text + pageLangText.updatedDuplicate.text).show();
                    }
                }
            };

            /// <summary>変更前の処理を実施。</summary>
            var saveCheck = function (e) {
                // 変更がない場合は処理を抜ける
                if (!isChanged) {
                    App.ui.page.notifyInfo.message(pageLangText.noChange.text).show();
                    return;
                }

                // 情報メッセージのクリア
                App.ui.page.notifyInfo.clear();

                // 品区分に対応したバリデーション
                var kbn_hin = $(".list-part-detail-content [name='kbn_hin']").val();
                if (!checkValidationHinKbn(kbn_hin)) {
                    return;
                }

                // 原料、自家原料の場合のチェック
                var result = $(".validGenryoRequired").validation().validate();
                if (result.errors.length) {
                    return false;
                }

                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();

                // 新規・コピー以外：品区分が製品・自家原料の時
                //var listCdHin = $("#list-count").text();
                //if (!App.isUndefOrNull(listCdHin) && listCdHin.length > 0) {
                //    var cd_hin = $(".list-part-detail-content [name='cd_hinmei']").val();
                //    // 結果一覧に品名コードがない場合は新規
                //    if (kbn_hin == pageLangText.seihinHinKbn.text || kbn_hin == pageLangText.jikaGenryoHinKbn.text) {
                //        // ライン登録有無チェック
                //        if (!checkLineToroku(cd_hin, 'validation')) {
                //            return;
                //        }
                //    }
                //}

                // 確認メッセージ
                showSaveConfirmDialog();
            };

            /// <summary>変更を保存します。</summary>
            var saveData = function (e) {
                closeSaveConfirmDialog();
                // 情報メッセージのクリア
                App.ui.page.notifyInfo.clear();

                var detailContent = $(".list-part-detail-content"),
                    result;

                // エラーメッセージのクリア
                App.ui.page.notifyAlert.clear();
                // ローディングの表示
                App.ui.loading.show(pageLangText.nowSaving.text);

                // 更新データをJSONオブジェクトに変換
                var postData = detailContent.toJSON();
                postData["flg_mishiyo"] = App.ifUndefOrNull($(".list-part-detail-content [name='flg_mishiyo']:checked").val(), '0');
                postData["flg_tenkai"] = pageLangText.falseFlg.text;
                postData["kbn_zei"] = pageLangText.falseFlg.text;
                if (postData.ts != null && !(isAdd || isCopy)) {
                    postData["cd_update"] = App.ui.page.user.Code;
                }
                else {
                    postData["cd_create"] = App.ui.page.user.Code;
                    postData["cd_update"] = App.ui.page.user.Code;
                };

                postData["flg_testitem"] = App.ifUndefOrNull($(".list-part-detail-content [name='flg_testitem']:checked").val(), '0');
                // 品区分は自家原料または原料になる場合、トレース対象外は有効にします。
                if (postData["kbn_hin"] == pageLangText.jikaGenryoHinKbn.text || postData["kbn_hin"] == pageLangText.genryoHinKbn.text) {
                    postData["flg_trace_taishogai"] = App.ifUndefOrNull($(".list-part-detail-content [name='flg_trace_taishogai']:checked").val(), '0');
                }
                else {
                    postData["flg_trace_taishogai"] = null;
                }

                // 品区分が「原料」の場合、「一個の量の単位」を「使用単位」に設定する
                var kbn_hin = $(".list-part-detail-content [name='kbn_hin']").val();
                if (kbn_hin == pageLangText.genryoHinKbn.text) {
                    var kbnKanzan = $(".list-part-detail-content [name='kbn_kanzan']:checked").val();
                    postData["cd_tani_shiyo"] = kbnKanzan;
                }
                postData["nm_haigo"] = "";
                //postData["kbn_hokan"] = postData["kbn_hokan_detail"];
                //postData["kbn_kaifugo_hokan"] = postData["kbn_kaifugo_hokan_detail"];
                var changeSet = new App.ui.page.changeSet();

                if (postData.ts != null && !(isAdd || isCopy)) {
                    changeSet.addUpdated(App.uuid, null, null, postData);
                }
                else {
                    changeSet.addCreated(App.uuid, postData);
                }

                var data = changeSet.getChangeSet();
                //var changeData = changeSet.getChangeSetData();
                //var data = JSON.stringify(changeData);
                var saveUrl = "../api/HinmeiMaster";
                App.ajax.webpost(
                    saveUrl, data
                ).done(function (result) {
                    // 保存終了メッセージ
                    showSaveCompleteDialog();
                }).fail(function (result) {
                    // データ変更エラーハンドリングを行います。
                    handleSaveDataError(result);
                }).always(function () {
                    // ローディングの終了
                    App.ui.loading.close();
                    // ローディングの表示(処理中です)
                    //App.ui.loading.show(pageLangText.nowProgressing.text);
                });
            };

            //  更新完了
            var saveComplete = function (e) {
                closeSaveCompleteDialog();
                // ローディングの表示(処理中です)
                App.ui.loading.show(pageLangText.nowProgressing.text);
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
                postData["nm_haigo"] = "";
                var changeSet = new App.ui.page.changeSet();
                if (postData.ts != null) {
                    changeSet.addDeleted(App.uuid, postData);
                }
                var data = changeSet.getChangeSet();
                //var changeData = changeSet.getChangeSetData();
                //var data = JSON.stringify(changeData);
                // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                var saveUrl = "../api/HinmeiMaster";
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

            //// 保存処理 -- Start

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
            $(".validation-seihin").validation(v);
            $(".validation-jikagen").validation(v);
            $(".validation-genryo").validation(v);
            $(".validation-shizai").validation(v);
            $(".vali_cd_torihiki1").validation(v);
            $(".vali_cd_torihiki2").validation(v);
            $(".vali_cd_seizo").validation(v);
            $(".vali_cd_haigo").validation(v);
            $(".vali-zaiko-min").validation(v);
            $(".vali-zaiko-max").validation(v);
            $(".validGenryoRequired").validation(v);

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

            // 品コードの重複チェック
            var isValidHinmeiCode = function (hinmeiCode) {
                var isValid = true;
                var _query = {
                    url: "../Services/FoodProcsService.svc/ma_hinmei",
                    filter: "cd_hinmei eq '" + hinmeiCode + "'",
                    top: 1
                }
                // 品コード入力の場合のみチェック
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

            // 配合コードの重複チェック
            var isValidHaigoCode = function (hinmeiCode, haigoCode, kbn) {
                var isValid = true;
                var _query = {
                    url: "../Services/FoodProcsService.svc/ma_hinmei",
                    filter: "kbn_hin eq " + kbn +
                             "and flg_mishiyo eq " + pageLangText.shiyoMishiyoFlg.text +
                             "and cd_haigo eq '" + haigoCode + "'" +
                             "and cd_hinmei ne '" + hinmeiCode + "'",
                    top: 1
                }
                App.ajax.webgetSync(
                        App.data.toODataFormat(_query)
                    ).done(function (result) {
                        if (result.d.length != 0) {
                            isValid = false;
                        }
                    }).fail(function (result) {
                        App.ui.page.notifyAlert.message(result.message).show();
                    });
                return isValid;
            };

            //品名の表示切替判定
            if (App.ui.page.user.kbn_hinmei_kirikae == pageLangText.kbn_hinmei_kirikae_ja.number) {
                validationSetting.nm_hinmei_ja.rules.custom = function (value) {
                    validationSetting.nm_hinmei_ja.messages.custom = App.str.format(pageLangText.requiredMsg.text, pageLangText.msg_nm_hinmei_ja.text);
                    return isValidHinmeiName();
                };
            }
            else if (App.ui.page.user.kbn_hinmei_kirikae == pageLangText.kbn_hinmei_kirikae_en.number) {
                validationSetting.nm_hinmei_en.rules.custom = function (value) {
                    validationSetting.nm_hinmei_en.messages.custom = App.str.format(pageLangText.requiredMsg.text, pageLangText.msg_nm_hinmei_en.text);
                    return isValidHinmeiName();
                };
            }
            else if (App.ui.page.user.kbn_hinmei_kirikae == pageLangText.kbn_hinmei_kirikae_zh.number) {
                validationSetting.nm_hinmei_zh.rules.custom = function (value) {
                    validationSetting.nm_hinmei_zh.messages.custom = App.str.format(pageLangText.requiredMsg.text, pageLangText.msg_nm_hinmei_zh.text);
                    return isValidHinmeiName();
                };
            }
            else if (App.ui.page.user.kbn_hinmei_kirikae == pageLangText.kbn_hinmei_kirikae_vi.number) {
                validationSetting.nm_hinmei_vi.rules.custom = function (value) {
                    validationSetting.nm_hinmei_vi.messages.custom = App.str.format(pageLangText.requiredMsg.text, pageLangText.msg_nm_hinmei_vi.text);
                    return isValidHinmeiName();
                };
            }
            else {
                validationSetting.nm_hinmei_ja.rules.custom = function (value) {
                    return isValidHinmeiName();
                };
                validationSetting.nm_hinmei_en.rules.custom = function (value) {
                    return isValidHinmeiName();
                };
                validationSetting.nm_hinmei_zh.rules.custom = function (value) {
                    return isValidHinmeiName();
                };
                validationSetting.nm_hinmei_vi.rules.custom = function (value) {
                    return isValidHinmeiName();
                };
            }

            validationSetting.cd_hinmei.rules.custom = function (value) {
                return isValidHinmeiCode(value);
            };
            /*
            validationSetting.nm_hinmei_ja.rules.custom = function (value) {
            return isValidHinmeiName();
            };
            validationSetting.nm_hinmei_en.rules.custom = function (value) {
            return isValidHinmeiName();
            };
            validationSetting.nm_hinmei_zh.rules.custom = function (value) {
            return isValidHinmeiName();
            };
            */
            //原料自家原料の場合、賞味期間は必須
            //validationSetting.dd_shomi.messages.custom = App.str.format(pageLangText.requiredMsg.text, pageLangText.dd_shomi.text);
            validationSetting.dd_shomi.rules.custom = function (value) {
                //return isValidGenryoRequired(value);
                // 必須チェック切替区分.任意の場合は必須チェックをしない
                var isNotRequired = isRequiredCheck === pageLangText.kinoNotRequired.number;
                if (isNotRequired || isValidGenryoRequired(value)) {
                    // 0日でないことをチェック
                    validationSetting.dd_shomi.messages.custom = App.str.format(pageLangText.inputGreater.text, pageLangText.dd_shomi.text.replace(/<br>/, ""), "0");
                    return isValidGenryoNotZero(value);
                }
                else {
                    // 必須エラー
                    validationSetting.dd_shomi.messages.custom = App.str.format(pageLangText.requiredMsg.text, pageLangText.dd_shomi.text.replace(/<br>/, ""));
                    return false;
                }
            };
            //原料自家原料の場合、開封後賞味期間は必須
            //validationSetting.dd_kaifugo_shomi.messages.custom = App.str.format(pageLangText.requiredMsg.text, pageLangText.dd_kaifugo_shomi.text);
            validationSetting.dd_kaifugo_shomi.rules.custom = function (value) {
                //return isValidGenryoRequired(value);
                // 必須チェック切替区分.任意の場合は必須チェックをしない
                var isNotRequired = isRequiredCheck === pageLangText.kinoNotRequired.number;
                if (isNotRequired || isValidGenryoRequired(value)) {
                    // 0日でないことをチェック
                    validationSetting.dd_kaifugo_shomi.messages.custom = App.str.format(pageLangText.inputGreater.text, pageLangText.dd_kaifugo_shomi.text.replace(/<br>/, " "), "0");
                    return isValidGenryoNotZero(value);
                }
                else {
                    // 必須エラー
                    validationSetting.dd_kaifugo_shomi.messages.custom = App.str.format(pageLangText.requiredMsg.text, pageLangText.dd_kaifugo_shomi.text.replace(/<br>/, " "));
                    return false;
                }
            };
            //原料自家原料の場合、保管区分は必須
            validationSetting.kbn_hokan_detail.messages.custom = App.str.format(pageLangText.requiredMsg.text, pageLangText.kbn_hokan.text);
            validationSetting.kbn_hokan_detail.rules.custom = function (value) {
                // 必須チェック切替区分.任意の場合は必須チェックをしない
                var isNotRequired = isRequiredCheck === pageLangText.kinoNotRequired.number;
                return isNotRequired || isValidGenryoRequired(value);
            };
            //原料自家原料の場合、開封後保管区分は必須
            validationSetting.kbn_kaifugo_hokan_detail.messages.custom = App.str.format(pageLangText.requiredMsg.text, pageLangText.kbn_kaifugo_hokan.text.replace(/<br>/, " "));
            validationSetting.kbn_kaifugo_hokan_detail.rules.custom = function (value) {
                // 必須チェック切替区分.任意の場合は必須チェックをしない
                var isNotRequired = isRequiredCheck === pageLangText.kinoNotRequired.number;
                return isNotRequired || isValidGenryoRequired(value);
            };

            validationSetting.su_zaiko_min.rules.custom = function (value) {
                var valiObj = validationSetting.su_zaiko_min;
                var isVali = isValidMinMaxZaiko(valiObj);
                if (isVali && !checkFlgMaxMin) {
                    checkFlgMaxMin = true;  // ループ回避用
                    // 最大在庫のエラーも解除するためチェック実施
                    $(".vali-zaiko-max").validation().validate();
                }
                checkFlgMaxMin = false;
                return isVali;
            };
            validationSetting.su_zaiko_max.rules.custom = function (value) {
                var valiObj = validationSetting.su_zaiko_max;
                var isVali = isValidMinMaxZaiko(valiObj);
                if (isVali && !checkFlgMaxMin) {
                    checkFlgMaxMin = true;  // ループ回避用
                    // 最低在庫のエラーも解除するためチェック実施
                    $(".vali-zaiko-min").validation().validate();
                }
                checkFlgMaxMin = false;
                return isVali;
            };

            // ■仕掛残計上機能OFF対応(機能ONは下のコメントアウトをオープンして下さい):重複チェックの無効化
            //validationSetting.cd_haigo.messages.custom = pageLangText.OverlapHaigoCode.text;
            //validationSetting.cd_haigo.rules.custom = function (value) {

            //    var hinmeiCode = $(".list-part-detail-content [name='cd_hinmei']").val(),
            //        kbn_hin = $(".list-part-detail-content [name='kbn_hin']").val(),
            //        haigoCode = $(".list-part-detail-content [name='cd_haigo']"),
            //        isNotRequired = (kbn_hin !== pageLangText.jikaGenryoHinKbn.text);

            //    return isNotRequired || isValidHaigoCode(hinmeiCode, value, kbn_hin);
            //};

            // 品名の入力チェック
            var isValidHinmeiName = function (e) {
                var jaHinmei = $("#nm_hinmei_detail_ja").val(),
                    enHinmei = $("#nm_hinmei_detail_en").val(),
                    zhHinmei = $("#nm_hinmei_detail_zh").val(),
                    viHinmei = $("#nm_hinmei_detail_vi").val();
                if ((App.isUndefOrNull(jaHinmei) || (App.isStr(jaHinmei) && jaHinmei.length === 0)) &&
                   (App.isUndefOrNull(enHinmei) || (App.isStr(enHinmei) && enHinmei.length === 0)) &&
                   (App.isUndefOrNull(zhHinmei) || (App.isStr(zhHinmei) && zhHinmei.length === 0)) &&
                   (App.isUndefOrNull(viHinmei) || (App.isStr(viHinmei) && viHinmei.length === 0))) {
                    return false;
                }
                return true;
            };
            //原料・自家原料の場合は必須チェックをします。
            var isValidGenryoRequired = function (value) {
                // 品区分取得
                var detailHinKubun = $(".list-part-detail-content [name='kbn_hin']").val();
                // 製品、資材はチェックをしない
                if (detailHinKubun === pageLangText.seihinHinKbn.text
                    || detailHinKubun === pageLangText.shizaiHinKbn.text) {
                    return true;
                }
                else if (detailHinKubun === pageLangText.genryoHinKbn.text
                        || detailHinKubun === pageLangText.jikaGenryoHinKbn.text) {
                    return !(App.isUndefOrNull(value) || !App.isStr(value) || value.length === 0);
                }
                // 品区分が正しく取得できない場合はエラーにします。
                return false;
            };
            //製品・原料・自家原料の場合は0より大きいかをチェックします。
            var isValidGenryoNotZero = function (value) {
                // 品区分取得
                var detailHinKubun = $(".list-part-detail-content [name='kbn_hin']").val();
                // 資材はチェックをしない
                if (detailHinKubun === pageLangText.shizaiHinKbn.text) {
                    return true;
                }
                else if (detailHinKubun === pageLangText.seihinHinKbn.text
                        || detailHinKubun === pageLangText.genryoHinKbn.text
                        || detailHinKubun === pageLangText.jikaGenryoHinKbn.text) {
                    return value !== "0";
                }
                // 品区分が正しく取得できない場合はエラーにします。
                return false;
            };
            // 最低/最大在庫の入力チェック：最大在庫＜最低在庫の場合flaseを返す
            var isValidMinMaxZaiko = function (valiObj) {
                var maxZaiko = getThousandsSeparatorDel($("#id_su_zaiko_max").val()),
                    minZaiko = getThousandsSeparatorDel($("#id_su_zaiko_min").val());
                if (parseFloat(maxZaiko) < parseFloat(minZaiko)) {
                    // メッセージ引数が複数のcustomはappにないので、個別で設定
                    valiObj.messages.custom =
	                    App.str.format(valiObj.messages.custom
		                    , valiObj.params.custom[0]
		                    , valiObj.params.custom[1]);
                    return false;
                }
                return true;
            };

            //荷受場所に値が選択されているかを確認
            validationSetting.cd_niuke_basho.messages.custom = App.str.format(pageLangText.requiredMsg.text, pageLangText.cd_niuke_basho.text);
            validationSetting.cd_niuke_basho.rules.custom = function (value) {
                var isNotRequired = isRequiredCheck === pageLangText.kinoNotRequired.number;
                return isNotRequired || isValidGenryoRequired(value);
            };

            var IsCalledEvent = false;  // changeイベント内で同様の処理を行わせない（ループを防ぐ）ため、trueの場合は処理回避
            $(".list-part-detail-content [name='nm_hinmei_ja']").on("change", function () {
                if (!IsCalledEvent) {
                    IsCalledEvent = true;   // ループの回避
                    $(".list-part-detail-content [name='nm_hinmei_en']").change();
                    $(".list-part-detail-content [name='nm_hinmei_zh']").change();
                    $(".list-part-detail-content [name='nm_hinmei_vi']").change();
                    IsCalledEvent = false;  // フラグを戻す
                }
            });
            $(".list-part-detail-content [name='nm_hinmei_en']").on("change", function () {
                if (!IsCalledEvent) {
                    IsCalledEvent = true;
                    $(".list-part-detail-content [name='nm_hinmei_ja']").change();
                    $(".list-part-detail-content [name='nm_hinmei_zh']").change();
                    $(".list-part-detail-content [name='nm_hinmei_vi']").change();
                    IsCalledEvent = false;
                }
            });
            $(".list-part-detail-content [name='nm_hinmei_zh']").on("change", function () {
                if (!IsCalledEvent) {
                    IsCalledEvent = true;
                    $(".list-part-detail-content [name='nm_hinmei_ja']").change();
                    $(".list-part-detail-content [name='nm_hinmei_en']").change();
                    $(".list-part-detail-content [name='nm_hinmei_vi']").change();
                    IsCalledEvent = false;
                }
            });
            $(".list-part-detail-content [name='nm_hinmei_vi']").on("change", function () {
                if (!IsCalledEvent) {
                    IsCalledEvent = true;
                    $(".list-part-detail-content [name='nm_hinmei_ja']").change();
                    $(".list-part-detail-content [name='nm_hinmei_en']").change();
                    $(".list-part-detail-content [name='nm_hinmei_zh']").change();
                    IsCalledEvent = false;
                }
            });

            // ライン登録有無チェック（validation用）
            var checkLineToroku = function (hinmeiCode, mode) {
                var isValid = true;
                var _query = {
                    url: "../Services/FoodProcsService.svc/ma_seizo_line",
                    filter: "cd_haigo eq '" + hinmeiCode + "' and kbn_master eq " + pageLangText.hinmeiMasterSeizoLineMasterKbn.text
                    + " and flg_mishiyo eq " + pageLangText.shiyoMishiyoFlg.text,
                    top: 1
                };
                App.ajax.webgetSync(
                    App.data.toODataFormat(_query)
                ).done(function (result) {
                    if (result.d.length <= 0) {
                        if (mode == 'check') {
                            chk_line_detail.innerText = pageLangText.lineNG.text;
                        }
                        else {
                            App.ui.page.notifyAlert.message(App.str.format(MS0042, pageLangText.lineSearch.text), $("#chk_line")).show();
                            isValid = false;
                        }
                    }
                    else {
                        if (mode == 'check') {
                            chk_line_detail.innerText = pageLangText.lineOK.text;
                        }
                    }
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(MS0079).show();
                });

                return isValid;
            };

            /// 引数の品区分に対応したバリデーションを実行する
            /// <param name="kbnHin">品区分</param>
            var checkValidationHinKbn = function (kbnHin) {
                var detailContent = null;
                switch (kbnHin) {
                    case pageLangText.seihinHinKbn.text:      // 製品
                        detailContent = $(".validation-seihin");
                        break;
                    case pageLangText.jikaGenryoHinKbn.text:  // 自家原料
                        detailContent = $(".validation-jikagen");
                        break;
                    case pageLangText.genryoHinKbn.text:      // 原料
                        detailContent = $(".validation-genryo");
                        break;
                    case pageLangText.shizaiHinKbn.text:      // 資材
                        detailContent = $(".validation-shizai");
                        break;
                    default:
                        break;
                }

                if (App.isUndefOrNull(detailContent)) {
                    // 品区分が選択されていない場合は処理を抜ける(ありえないパターンだが念の為)
                    App.ui.page.notifyAlert.message(
                        App.str.format(pageLangText.requiredMsg.text, pageLangText.kbn_hin.text)
                    ).show();
                    return false;
                }

                // 変更セット内にバリデーションエラーがある場合は処理を抜ける
                result = detailContent.validation().validate();
                if (result.errors.length) {
                    return false;
                }

                return true;
            };

            //// バリデーション -- End

            /// <summary>追加ボタンクリック時のイベント処理を行います。</summary>
            $(".add-button").on("click", function (e) {
                isAdd = true;
                isCopy = false;
                showDetail(true, false);
            });

            /// <summary>コピーボタンクリック時のイベント処理を行います。</summary>
            $(".copy-button").on("click", function (e) {
                var selectedRowId = getSelectedRowId();
                if (App.isUndefOrNull(selectedRowId)) {
                    return;
                }
                isAdd = false;
                isCopy = true;
                showDetail(false, true);
            });


            // Cookieを1秒ごとにチェックする
            var onComplete = function () {
                if (app_util.prototype.getCookieValue(pageLangText.hinmeiMasterCookie.text) == pageLangText.checkCookie.text) {
                    app_util.prototype.deleteCookie(pageLangText.hinmeiMasterCookie.text);
                    //ローディング終了
                    App.ui.loading.close();
                }
                else {
                    // 再起してCookieが作成されたか監視
                    setTimeout(onComplete, 1000);
                }
            };

            /// <summary>Excelファイル出力を行います。</summary>
            var printExcel = function (e) {
                var criteria = $(".search-criteria").toJSON();
                // 画面の入力項目をURLへ渡す
                //url = "../api/HinmeiMasterIchiranExcel";

                // 検索条件：品区分
                var hinKbn = pageLangText.noSelectConditionExcel.text;
                if (!App.isUndefOrNull(criteria.kbn_hin) && criteria.kbn_hin.length > 0) {
                    hinKbn = $("#id_kbn_hin option:selected").text();
                }
                // 検索条件：分類
                var bunrui = pageLangText.noSelectConditionExcel.text;
                if (!App.isUndefOrNull(criteria.cd_bunrui) && criteria.cd_bunrui.length > 0) {
                    bunrui = $("#id_cd_bunrui option:selected").text();
                }
                // 検索条件：保管区分
                var hokan = pageLangText.noSelectConditionExcel.text;
                if (!App.isUndefOrNull(criteria.kbn_hokan) && criteria.kbn_hokan.length > 0) {
                    hokan = $("#id_kbn_hokan option:selected").text();
                }

                var query = {
                    url: "../api/HinmeiMasterIchiranExcel",
                    con_kbn_hin: criteria.kbn_hin,
                    con_bunrui: criteria.cd_bunrui,
                    con_kbn_hokan: criteria.kbn_hokan,
                    con_hinmei: encodeURIComponent(criteria.nm_hinmei),
                    mishiyo_hyoji: criteria.flg_mishiyo,
                    lang: App.ui.page.lang,
                    kbnUriagesaki: pageLangText.uriagesakiToriKbn.text,
                    kbnSeizomoto: pageLangText.seizomotoToriKbn.text,
                    flgShiyo: pageLangText.shiyoMishiyoFlg.text,
                    hanNo: pageLangText.systemValueOne.text,
                    local_today: App.data.getDateTimeStringForQuery(new Date(), true)
                };
                // 処理中を表示する
                App.ui.loading.show(pageLangText.nowProgressing.text);

                var url = App.data.toWebAPIFormat(query);

                url = url + "&hinKbn=" + encodeURIComponent(hinKbn)
                          + "&bunrui=" + encodeURIComponent(bunrui)
                          + "&hokan=" + encodeURIComponent(hokan)
                          + "&userName=" + encodeURIComponent(App.ui.page.user.Name);

                // 出力処理
                window.open(url, '_parent');
                // Cookieを監視する
                onComplete();
            };
            /// <summary>エクセルボタンクリック時のイベント処理を行います。</summary>
            $(".excel-button").on("click", printExcel);

            /// <summary>ダウンロードボタンクリック時のオーバレイ処理を行います。</summary>
            var downloadOverlay = function () {
                App.ui.loading.show(pageLangText.nowProgressing.text);
                printPdf();
                App.ui.loading.close();
            };
            /// <summary>PDFファイル出力を行います。</summary>
            var printPdf = function (e) {
                var hinCode = $("#cd_hinmei").val();
                var query = {
                    url: "../api/HinmeiMasterPDF",
                    con_hinmei: hinCode,
                    lang: App.ui.page.lang,
                    kbnUriagesaki: pageLangText.uriagesakiToriKbn.text,
                    kbnSeizomoto: pageLangText.seizomotoToriKbn.text,
                    flgShiyo: pageLangText.shiyoMishiyoFlg.text,
                    hanNo: pageLangText.systemValueOne.text,
                    //userName: App.ui.page.user.Name,
                    //uuid: App.uuid()
                    local_today: App.data.getDateTimeStringForQuery(new Date(), true)
                };
                var url = App.data.toWebAPIFormat(query);
                url = url + "&userName=" + encodeURIComponent(App.ui.page.user.Name)
                            + "&uuid=" + App.uuid() + "&browseCurrency=" + browseCurrency;
                // PDF出力処理
                window.open(url, '_parent');
            };
            /// <summary>印刷ボタンクリック時のイベント処理を行います。</summary>
            $(".pdf-button").on("click", function () {
                // 印刷前チェック：明細に変更がないこと
                if (isChanged) {
                    App.ui.page.notifyInfo.message(
                         App.str.format(pageLangText.pdfChangeMeisai.text
                            , pageLangText.meisai.text
                            , pageLangText.print.text)
                    ).show();
                    return;
                }

                // 出力前処理へ
                downloadOverlay();
            });

            /// <summary>品区分チェックの判定結果</summary>
            /// <param name="checkKbn">チェック対象の品区分</param>
            /// <param name="checkType">イベント(押下されたボタン)名</param>
            /// <return>判定OK：true 判定NG：false</return>
            var judgmentHinKubun = function (checkKbn, checkType) {
                var isJudg = false;
                switch (checkType) {
                    case "shizai":
                    case "line":
                        // ======= 資材使用ボタン、ライン登録
                        // 品区分が「製品」または「自家原料」かどうか
                        if (checkKbn == pageLangText.seihinHinKbn.text
                                || checkKbn == pageLangText.jikaGenryoHinKbn.text) {
                            isJudg = true;
                        }
                        break;
                    case "konyu":
                        // ======= 原資材購入先ボタン
                        // 品区分が「原料」または「資材」または「自家原料」かどうか
                        if (checkKbn == pageLangText.genryoHinKbn.text
                                || checkKbn == pageLangText.shizaiHinKbn.text
                                || checkKbn == pageLangText.jikaGenryoHinKbn.text) {
                            isJudg = true;
                        }
                        break;
                }
                return isJudg;
            };
            /// <summary>遷移前の存在チェック＋品区分チェック処理</summary>
            /// <param name="msgParam">エラーメッセージ用パラメーター</param>
            /// <param name="checkType">イベント(押下されたボタン)名</param>
            var checkHinKubun = function (msgParam, checkType) {
                var isValid = true;
                App.ui.page.notifyInfo.clear();
                App.ui.page.notifyAlert.clear();

                // 新規追加ではないこと(一度保存されていること)
                var listCdHin = $("#list-count").text();
                if (App.isUndefOrNull(listCdHin) || listCdHin.length == 0) {
                    // 結果一覧に品名コードがない場合は新規(infoで出力)
                    App.ui.page.notifyInfo.message(pageLangText.navigateError.text).show();
                    return false;
                }

                var cdHin = $("#cd_hinmei").val();
                var _query = {
                    url: "../Services/FoodProcsService.svc/ma_hinmei",
                    filter: "cd_hinmei eq '" + cdHin + "' and flg_mishiyo eq " + pageLangText.shiyoMishiyoFlg.text,
                    top: 1
                };
                App.ajax.webgetSync(
                    App.data.toODataFormat(_query)
                ).done(function (result) {
                    if (result.d.length == 1) {
                        // 品区分チェック
                        var kbnHin = result.d[0].kbn_hin;
                        if (!judgmentHinKubun(kbnHin, checkType)) {
                            // エラーメッセージ(infoで出力)
                            App.ui.page.notifyInfo.message(
                                App.str.format(pageLangText.lineTorokuHinKbnError.text, msgParam)
                            ).show();
                            isValid = false;
                        }
                    }
                    else {
                        // マスタに存在しない場合、エラー
                        App.ui.page.notifyAlert.message(pageLangText.lineTorokuHinCdError.text).show();
                        isValid = false;
                    }
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(MS0079).show();
                });

                // チェックOK
                return isValid;
            };
            /// <summary>ライン登録画面へ遷移します</summary>
            var toLine = function (e) {
                // チェック処理
                var msgLine = pageLangText.errorHinKbnParamLine.text + pageLangText.kbn_hin.text;
                if (!checkHinKubun(msgLine, "line")) {
                    return;
                }

                var url = "./SeizoLineMaster.aspx",
                    cdHinmei = $("#cd_hinmei").val();

                // 引数設定設定
                url += "?kbn_master=" + pageLangText.hinmeiMasterSeizoLineMasterKbn.text;   // 品名マスタ
                url += "&cd_haigo=" + cdHinmei;

                try {
                    window.location = url;
                }
                catch (e) {
                    // 何もしない
                }
            };

            /// <summary>資材使用マスタ画面へ遷移します</summary>
            var toShizai = function (e) {
                // チェック処理
                var msgShizai = pageLangText.errorHinKbnParamShiza.text + pageLangText.kbn_hin.text;
                if (!checkHinKubun(msgShizai, "shizai")) {
                    return;
                }

                var url = "./ShizaiShiyoMaster.aspx",
                    cdHinmei = $("#cd_hinmei").val();

                // 引数設定設定
                url += "?cd_hinmei=" + cdHinmei;

                try {
                    window.location = url;
                }
                catch (e) {
                    // 何もしない
                }
            };

            /// <summary>購入先マスタ画面へ遷移します</summary>
            var toKonyu = function (e) {
                // チェック処理
                var msgShizai = pageLangText.errorHinKbnParamKonyu.text + pageLangText.kbn_hin.text;
                if (!checkHinKubun(msgShizai, "konyu")) {
                    return;
                }

                var url = "./GenshizaiKonyusakiMaster.aspx",
                    cdHin = $("#cd_hinmei").val();

                // 引数設定設定
                url += "?cdHin=" + cdHin;
                if (!App.isUndefOrNull(nmHin)) {
                    url += "&nmHin=" + nmHin;
                }

                try {
                    window.location = url;
                }
                catch (e) {
                    // 何もしない
                }
            };

            /// <summary>データのクリアを行います。</summary>
            var clearData = function () {
                closeClearConfirmDialog();
                //ページをリロード
                var _bunruiCode;
                changeSet = new App.ui.page.changeSet();

                _bunruiCode = rowShowData.cd_bunrui;
                $(".list-part-detail-content").toForm(rowShowData);
                searchBunruiCode("toroku", _bunruiCode);
                chk_line_detail.innerText = rowlineCheck;
                App.ui.page.notifyAlert.clear();
                controlDispDetail();
                isChanged = false;
            };
            /// <summary>クリアボタンクリック時のイベント処理を行います。</summary>
            $(".clear-button").on("click", showClearConfirmDialog);

            /// <summary>詳細を表示します。</summary>
            var showDetail = function (isAdd, isCopy) {
                App.ui.page.notifyAlert.clear();
                // ローディング表示
                App.ui.loading.show(pageLangText.nowProgressing.text);

                var selectedRowId = grid.jqGrid("getGridParam", "selrow"),
                    code = "",
                    row;
                // スクロール位置の保存
                nextScrollTop = $(".ui-jqgrid-bdiv").scrollTop();

                // 品コード欄の制御（一旦リセット）
                //$(".list-part-detail-content [name='cd_hinmei']").attr("disabled", false).css("background-color", "");
                $("#cd_hinmei").attr("disabled", false).css("background-color", "");


                // 品名マスタの換算区分をKg・L → LB・GALとする。
                //phuc add start
                if (pageLangText.kbn_tani_LB_GAL.text === App.ui.page.user.kbn_tani) {
                    $(".labelLB").show();
                    $(".labelKg").hide();

                    $(".labelGAL").show();
                    $(".labelL").hide();
                }
                else {
                    $(".labelLB").hide();
                    $(".labelKg").show();

                    $(".labelGAL").hide();
                    $(".labelL").show();
                }
                //phuc add end


                if (isAdd) {
                    row = setAddData();
                    // 品区分が資材の場合：比重をクリアする
                    if ($("#id_kbn_hin").val() == pageLangText.shizaiHinKbn.text) {
                        row.ritsu_hiju = "";
                    }

                    // 詳細の表示処理へ
                    gridHideDetailShow(isAdd, isCopy, row);
                }
                else {
                    if (App.isUnusable(selectedRowId)) {
                        return;
                    }
                    row = grid.jqGrid("getRowData", selectedRowId);
                    //_bunruiCode = row.cd_bunrui;
                    code = row.cd_hinmei;

                    // 多言語対応済みの配合名を詳細の配合名に設定
                    var nmHaigo = grid.getCell(selectedRowId, haigoName);
                    $("#nm_haigo_detail").text(nmHaigo);

                    // getRowDataから取得した値は改行コードが削除されるので
                    // 備考、品名(日本語、英語、中国語)はDBから再取得して設定しなおす
                    var _data;
                    App.deferred.parallel({
                        _data: App.ajax.webget("../Services/FoodProcsService.svc/ma_hinmei?$filter=cd_hinmei eq '" + code
                                + "'&$select=cd_hinmei, nm_hinmei_ja, nm_hinmei_en, nm_hinmei_zh, nm_hinmei_vi, biko")
                    }).done(function (result) {
                        _data = result.successes._data.d;
                        if (_data.length == 0) {
                            // データが取得できなかった場合、エラーメッセージを表示して後続処理を行わない
                            App.ui.page.notifyAlert.message(MS0037).show();
                            // ローディング終了
                            App.ui.loading.close();
                        }
                        else {
                            row.biko = _data[0].biko;
                            row.nm_hinmei_ja = _data[0].nm_hinmei_ja;
                            row.nm_hinmei_en = _data[0].nm_hinmei_en;
                            row.nm_hinmei_zh = _data[0].nm_hinmei_zh;
                            row.nm_hinmei_vi = _data[0].nm_hinmei_vi;
                            // 原資材購入先マスタ遷移用に品名を保持
                            nmHin = row[hinmeiName];
                            // 詳細の表示処理へ
                            gridHideDetailShow(isAdd, isCopy, row);
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
                }
            };
            /// <summary>検索条件、グリッドの非表示、詳細の表示処理とライン登録有無チェック</summary>
            var gridHideDetailShow = function (isAdd, isCopy, row) {
                App.ui.page.notifyAlert.clear();
                var detailContent = $(".list-part-detail-content"),
                    gridContent = $(".list-part-grid-content");

                // 検索条件、グリッドを非表示にして詳細を表示します。
                $(".search-criteria").hide("fast", function () {
                    gridContent.hide("fast", function () {
                        if (isCopy) {
                            row.cd_hinmei = "";
                            row.dt_create = "";
                            row.dt_update = "";
                            row.flg_mishiyo = "0";
                        }
                        detailContent.toForm(row);
                        detailContent.show("fast");
                        searchBunruiCode("toroku");
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
                        $("#list-count").text(row.cd_hinmei);
                        $("#list-results").on("click", showGrid);
                    }).promise().done(function () {
                        $(".command-grid").hide("fast");
                        $(".command-detail").show("fast").promise().done(function () {
                            // 分類を設定(新規：検索条件で選択した分類　既存：DBより取得した値)
                            $(".list-part-detail-content [name='cd_bunrui']").val(row.cd_bunrui);
                            rowShowData = row;
                        });
                        // 画面をリサイズ
                        resizeContents();
                        // 品区分による使用可否項目の制御
                        controlDispDetail();
                        // ローディング終了
                        App.ui.loading.close();
                    });
                });

                // ライン登録有無チェック
                if (!isAdd && !isCopy) {
                    var lineServiceUrl,
                        lineList;

                    lineServiceUrl = "../Services/FoodProcsService.svc/ma_seizo_line?$filter=kbn_master eq "
                        + pageLangText.hinmeiMasterSeizoLineMasterKbn.text + " and cd_haigo eq '" + row.cd_hinmei + "' and flg_mishiyo eq "
                        + pageLangText.shiyoMishiyoFlg.text + " &$top=1";

                    App.deferred.parallel({
                        lineList: App.ajax.webgetSync(lineServiceUrl)
                    }).done(function (result) {
                        lineList = result.successes.lineList.d;
                        if (lineList.length > 0) {
                            chk_line_detail.innerText = pageLangText.lineOK.text;
                        }
                        else {
                            chk_line_detail.innerText = pageLangText.lineNG.text;
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
                    // 品コード欄の制御（更新の場合は変更不可）
                    $(".list-part-detail-content [name='cd_hinmei']").attr("disabled", true).css("background-color", "#F2F2F2");
                    // 新規以外は印刷ボタン、資材使用ボタン、購入先ボタンを表示する
                    $(".command-detail [name='pdf-button']").attr("disabled", false).css("display", "");
                    $(".command-detail [name='shizai-button']").attr("disabled", false).css("display", "");
                    $(".command-detail [name='konyu-button']").attr("disabled", false).css("display", "");
                    /* 2022/29/03 - 22094: -START FP-Lite ChromeBrowser Modify */
                    $(".item-command [name='delete-button']").attr("disabled", false).css("display", "");
                    /* 2022/29/03 - 22094: -END FP-Lite ChromeBrowser Modify */
                    // 権限「Admin」「Operator」「Editor」のときのみ、削除ボタン押下可とする
                    //var roles = App.ui.page.user.Roles[0];
                    //if (roles == pageLangText.admin.text || roles == pageLangText.operator.text || roles == pageLangText.editor.text) {
                    //    $(".item-command [name='delete-button']").attr("disabled", false).css("display", "");
                    //}
                }
                else {
                    chk_line_detail.innerText = " ";
                    // 新規のときは印刷ボタン、資材使用ボタン、削除ボタン、購入先ボタンを非表示にする
                    $(".command-detail [name='pdf-button']").attr("disabled", true).css("display", "none");
                    $(".command-detail [name='shizai-button']").attr("disabled", false).css("display", "none");
                    $(".command-detail [name='konyu-button']").attr("disabled", false).css("display", "none");
                    $(".item-command [name='delete-button']").attr("disabled", true).css("display", "none");
                }

                //ロケーションの表示判定
                if (App.ui.page.user.locationCode != pageLangText.locationKbn_ari.number) {
                    $(".list-part-detail-content [name='cd_location']").css("display", "none");
                    $(".cd_location").css("display", "none");
                }
                //品名の表示切替判定
                if (App.ui.page.user.kbn_hinmei_kirikae == pageLangText.kbn_hinmei_kirikae_ja.number) {
                    $(".list-part-detail-content [name='nm_hinmei_en']").css("display", "none");
                    $(".list-part-detail-content [name='nm_hinmei_zh']").css("display", "none");
                    $(".list-part-detail-content [name='nm_hinmei_vi']").css("display", "none");
                    $(".nm_hinmei_detail_en").css("display", "none");
                    $(".nm_hinmei_detail_zh").css("display", "none");
                    $(".nm_hinmei_detail_vi").css("display", "none");
                } else if (App.ui.page.user.kbn_hinmei_kirikae == pageLangText.kbn_hinmei_kirikae_en.number) {
                    $(".list-part-detail-content [name='nm_hinmei_ja']").css("display", "none");
                    $(".list-part-detail-content [name='nm_hinmei_zh']").css("display", "none");
                    $(".list-part-detail-content [name='nm_hinmei_vi']").css("display", "none");
                    $(".nm_hinmei_detail_ja").css("display", "none");
                    $(".nm_hinmei_detail_zh").css("display", "none");
                    $(".nm_hinmei_detail_vi").css("display", "none");
                } else if (App.ui.page.user.kbn_hinmei_kirikae == pageLangText.kbn_hinmei_kirikae_zh.number) {
                    $(".list-part-detail-content [name='nm_hinmei_ja']").css("display", "none");
                    $(".list-part-detail-content [name='nm_hinmei_en']").css("display", "none");
                    $(".list-part-detail-content [name='nm_hinmei_vi']").css("display", "none");
                    $(".nm_hinmei_detail_ja").css("display", "none");
                    $(".nm_hinmei_detail_en").css("display", "none");
                    $(".nm_hinmei_detail_vi").css("display", "none");
                }
                else if (App.ui.page.user.kbn_hinmei_kirikae == pageLangText.kbn_hinmei_kirikae_vi.number) {
                    $(".list-part-detail-content [name='nm_hinmei_ja']").css("display", "none");
                    $(".list-part-detail-content [name='nm_hinmei_en']").css("display", "none");
                    $(".list-part-detail-content [name='nm_hinmei_zh']").css("display", "none");
                    $(".nm_hinmei_detail_ja").css("display", "none");
                    $(".nm_hinmei_detail_en").css("display", "none");
                    $(".nm_hinmei_detail_zh").css("display", "none");
                }
                rowlineCheck = chk_line_detail.innerText;
            };

            /// <summary>グリッドを表示します。</summary>
            var showGrid = function () {
                closeShowgridConfirmDialog();
                isChanged = false;

                var d = $.Deferred();
                App.ui.page.notifyAlert.clear();

                // 詳細を非表示にしてグリッド、検索条件を表示します。
                $(".list-part-detail-content").hide("fast", function () {
                    $(".search-criteria").show("fast", function () {
                        $(".list-part-grid-content").show("fast", function () {
                            // 画面をリサイズ
                            resizeContents();
                        });
                        $("#list-count").text(
                            App.str.format("{0}/{1}", querySetting.skip, querySetting.count)
                        );
                        $("#list-arrow").remove();
                        $('#list-results').unbind('hover');
                        $('#list-results').unbind('click');
                        $('#list-results').css("cursor", "default");
                        $('#list-results').css("background-color", "#efefef");
                        d.resolve();
                        grid.closest(".ui-jqgrid-bdiv").scrollTop(nextScrollTop);
                    });
                });
                $(".command-grid").show("fast");
                $(".command-detail").hide("fast");

                return d.promise();
            };

            /// <summary>一覧へ戻るボタンクリック時のイベント処理を行います。</summary>
            var showGridCheck = function () {
                // 権限「Admin」「Operator」「Editor」のときのみ、内容チェックを行う
                var roles = App.ui.page.user.Roles[0];
                if (roles == pageLangText.admin.text || roles == pageLangText.operator.text || roles == pageLangText.editor.text) {
                    if (isChanged) {
                        showShowgridConfirmDialog();
                    }
                    else {
                        showGrid();
                    }
                }
                else {
                    showGrid();
                }
            };
            $(".list-button").on("click", showGridCheck);

            /// <summary>詳細ボタンクリック時のイベント処理を行います。</summary>
            $(".detail-button").on("click", function (e) {
                var selectedRowId = getSelectedRowId();
                if (App.isUndefOrNull(selectedRowId)) {
                    return;
                }
                isAdd = false;
                isCopy = false;
                showDetail(false, false);
            });

            torihiki1Dialog.dlg({
                url: "Dialog/TorihikisakiDialog.aspx",
                name: "TorihikisakiDialog",
                closed: function (e, data, data2) {
                    if (data == "canceled") {
                        return;
                    }
                    else {
                        $("#cd_torihiki1_detail").val(data);
                        $("#nm_torihiki1_detail").text(data2);
                        isChanged = true;
                        // 再チェック
                        $(".vali_cd_torihiki1").validation().validate();
                    }
                }
            });
            /// <summary>販売先１検索ボタンクリック時のイベント処理を行います。</summary>
            $("#torihiki1-button").on("click", function (e) {
                torihiki1Dialog.draggable(true);
                var option = { id: 'torihiki1-list', multiselect: false, param1: pageLangText.uriagesakiToriKbn.text };
                torihiki1Dialog.dlg("open", option);
            });

            torihiki2Dialog.dlg({
                url: "Dialog/TorihikisakiDialog.aspx",
                name: "TorihikisakiDialog",
                closed: function (e, data, data2) {
                    if (data == "canceled") {
                        return;
                    }
                    else {
                        $("#cd_torihiki2_detail").val(data);
                        $("#nm_torihiki2_detail").text(data2);
                        isChanged = true;
                        // 再チェック
                        $(".vali_cd_torihiki2").validation().validate();
                    }
                }
            });
            /// <summary>販売先２検索ボタンクリック時のイベント処理を行います。</summary>
            $("#torihiki2-button").on("click", function (e) {
                torihiki2Dialog.draggable(true);
                var option = { id: 'torihiki2-list', multiselect: false, param1: pageLangText.uriagesakiToriKbn.text };
                torihiki2Dialog.dlg("open", option);
            });

            seizoDialog.dlg({
                url: "Dialog/TorihikisakiDialog.aspx",
                name: "TorihikisakiDialog",
                closed: function (e, data, data2) {
                    if (data == "canceled") {
                        return;
                    }
                    else {
                        $("#cd_seizo_detail").val(data);
                        $("#nm_seizo_detail").text(data2);
                        isChanged = true;
                        // 再チェック
                        $(".vali_cd_seizo").validation().validate();
                    }
                }
            });
            /// <summary>製造元検索ボタンクリック時のイベント処理を行います。</summary>
            $("#seizo-button").on("click", function (e) {
                seizoDialog.draggable(true);
                var option = { id: 'seizo-list', multiselect: false, param1: pageLangText.seizomotoToriKbn.text };
                seizoDialog.dlg("open", option);
            });

            haigoDialog.dlg({
                url: "Dialog/HinmeiDialog.aspx",
                name: "HinmeiDialog",
                closed: function (e, data, data2) {
                    if (data == "canceled") {
                        return;
                    }
                    else {
                        $("#cd_haigo_detail").val(data);
                        $("#nm_haigo_detail").text(data2);
                        isChanged = true;
                        // 再チェック
                        $(".vali_cd_haigo").validation().validate();
                    }
                }
            });
            /// <summary>配合名検索ボタンクリック時のイベント処理を行います。</summary>
            $("#haigo-button").on("click", function (e) {
                haigoDialog.draggable(true);
                var option = { id: 'haigo-list', multiselect: false, param1: pageLangText.shikakariHinDlgParam.text };
                haigoDialog.dlg("open", option);
            });

            var getHaigo = function (code) {
                var serviceUrl,
                    elementCode,
                    elementName,
                    codeName;

                serviceUrl = "../Services/FoodProcsService.svc/ma_haigo_mei?$filter=cd_haigo eq '" + code + "' and no_han eq "
                    + pageLangText.hanNoShokichi.text + " and flg_mishiyo eq " + pageLangText.shiyoMishiyoFlg.text + " &$top=1";
                elementCode = "cd_haigo";
                elementName = haigoName;

                App.deferred.parallel({
                    codeName: App.ajax.webget(serviceUrl)
                }).done(function (result) {
                    codeName = result.successes.codeName.d;
                    if (codeName.length > 0) {
                        $("#nm_haigo_detail").text(codeName[0][elementName]);
                    }
                    else if (code) {
                        $("#nm_haigo_detail").text("");
                        $("#cd_haigo_detail").val("");
                        App.ui.page.notifyAlert.message(App.str.format(MS0022, pageLangText.nm_haigo.text), $("#cd_haigo_detail")).show();
                    }
                    else {
                        $("#cd_haigo_detail").val("");
                        $("#nm_haigo_detail").text("");
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
            };

            /// <summary>配合名コード変更時のイベント処理を行います。</summary>
            $("#cd_haigo_detail").on("change", function () {
                var value = $("#cd_haigo_detail").val();
                getHaigo(value);
            });

            /// <summary>取引先マスタを検索し、取引先名を取得します。</summary>
            var getTorihiki = function (code, kbn, id, id2, literal) {
                var serviceUrl,
                    elementCode,
                    elementName,
                    codeName,
                    item;

                item = "cd_" + id2;
                serviceUrl = "../Services/FoodProcsService.svc/ma_torihiki?$filter=cd_torihiki eq '" + code + "' and flg_mishiyo eq "
                    + pageLangText.shiyoMishiyoFlg.text + " and kbn_torihiki eq " + kbn + "&$top=1";
                elementCode = "cd_torihiki";
                elementName = "nm_torihiki";

                App.deferred.parallel({
                    codeName: App.ajax.webget(serviceUrl)
                }).done(function (result) {
                    codeName = result.successes.codeName.d;
                    if (codeName.length > 0) {
                        $("#nm_" + id + "_detail").text(codeName[0][elementName]);
                    }
                    else if ($(".list-part-detail-content").toJSON()[item]) {
                        $("#nm_" + id + "_detail").text("");
                        $("#cd_" + id + "_detail").val("");
                        App.ui.page.notifyAlert.message(App.str.format(MS0022, literal), $("#cd_" + id + "_detail")).show();
                    }
                    else {
                        $("#nm_" + id + "_detail").text("");
                        $("#cd_" + id + "_detail").val("");
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
            };

            /// <summary>販売先１(取引先コード2)変更時のイベント処理を行います。</summary>
            $("#cd_torihiki1_detail").on("change", function () {
                var value = $("#cd_torihiki1_detail").val();
                getTorihiki(value, pageLangText.uriagesakiToriKbn.text, "torihiki1", "hanbai_1", pageLangText.nm_torihiki1.text);
            });

            /// <summary>販売先２(取引先コード2)変更時のイベント処理を行います。</summary>
            $("#cd_torihiki2_detail").on("change", function () {
                var value = $("#cd_torihiki2_detail").val();
                getTorihiki(value, pageLangText.uriagesakiToriKbn.text, "torihiki2", "hanbai_2", pageLangText.nm_torihiki2.text);
            });

            /// <summary>製造元名コード変更時のイベント処理を行います。</summary>
            $("#cd_seizo_detail").on("change", function () {
                var value = $("#cd_seizo_detail").val();
                getTorihiki(value, pageLangText.seizomotoToriKbn.text, "seizo", "seizo", pageLangText.nm_seizo.text);
            });

            // 入力項目変更時のイベント処理：数値のフォーマット
            $(".list-part-detail-content .format-thousands-Separator").on("change", function () {
                setThousandsSeparator(this);
            });

            // 入力項目（JANコード）変更時のイベント処理：0埋め
            //$(".list-part-detail-content [name='cd_jan']").on("change", function () {
            $("#id_cd_jan").on("change", function () {
                var value = $("#id_cd_jan").val();
                if (value) {
                    value = padZero(value, 13);
                    $("#id_cd_jan").val(value);
                }
            });

            /// <summary>ライン登録ボタンクリック時のイベント処理を行います。</summary>
            $("#line-button").on("click", function (e) {
                toLine();   // 製造可能ラインマスタ画面へ遷移する
            });

            /// <summary>資材使用ボタンクリック時のイベント処理を行います。</summary>
            $(".shizai-button").on("click", function (e) {
                toShizai();   // 資材使用マスタ画面へ遷移する
            });

            /// <summary>原資材購入先ボタンクリック時のイベント処理を行います。</summary>
            $(".konyu-button").on("click", function (e) {
                toKonyu();   // 原資材購入先マスタ画面へ遷移する
            });

            // コンテンツに変更が発生した場合は、
            $(".list-part-detail-content").on("change", function () {
                isChanged = true;
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

            // メニューへ戻る
            var backToMenu = function () {
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

            // ZERO埋め
            function padZero(str, len) {
                var slen = str.length;
                var _zero = "";
                for (var i = 0; i < len; i++) {
                    _zero = _zero + "0";
                }
                return (_zero + str).slice(len * -1);
            }

            /// <summary>メニューボタンクリック時のイベント処理を行います。</summary>
            $(".menu-button").on("click", backToMenu);

            /// <summary>保存ボタンクリック時のイベント処理を行います。</summary>
            $(".save-button").on("click", saveCheck);
            /// <summary>保存確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".save-confirm-dialog .dlg-yes-button").on("click", saveData);
            /// <summary>保存確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".save-confirm-dialog .dlg-no-button").on("click", closeSaveConfirmDialog);
            /// <summary>保存完了ダイアログの「閉じる」ボタンクリック時のイベント処理を行います。</summary>
            $(".save-complete-dialog .dlg-close-button").on("click", saveComplete);

            /// <summary>未保存の状態でページ遷移確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".showgrid-confirm-dialog .dlg-yes-button").on("click", showGrid);
            /// <summary>未保存の状態でページ遷移確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".showgrid-confirm-dialog .dlg-no-button").on("click", closeShowgridConfirmDialog);

            /// <summary>クリア確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".clear-confirm-dialog .dlg-yes-button").on("click", clearData);
            // <summary>クリア確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".clear-confirm-dialog .dlg-no-button").on("click", closeClearConfirmDialog);

            /// <summary>削除ボタンクリック時のイベント処理を行います。</summary>
            $(".delete-button").on("click", deleteCheck);
            /// <summary>削除確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".delete-confirm-dialog .dlg-yes-button").on("click", deleteData);
            /// <summary>削除確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".delete-confirm-dialog .dlg-no-button").on("click", closeDeleteConfirmDialog);
            /// <summary>削除完了ダイアログの「閉じる」ボタンクリック時のイベント処理を行います。</summary>
            $(".delete-complete-dialog .dlg-close-button").on("click", deleteComplete);

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
                    resultPartCommands = resultPart.find(".item-command");

                var resultPart0 = resultPart[0];
                var resultPartStyle = resultPart0.currentStyle || document.defaultView.getComputedStyle(resultPart0, "");

                var resultPartHeight = container[0].clientHeight - searchPart[0].clientHeight - ((parseInt(resultPartStyle.marginTop, 10) * 3) || 0);
                resultPart.height(resultPartHeight);
                grid.setGridWidth(resultPart0.clientWidth - 5);
                //結果一覧のパートの高さ - パートのヘッダーの高さ - パート内のボタンのコマンドの高さ - jqGrid のカラムヘッダーの高さ
                var gridHeight = resultPart0.clientHeight - resultPartHeader[0].clientHeight - resultPartCommands[0].clientHeight - resultPart.find(".ui-jqgrid-hdiv")[0].clientHeight - 35;
                grid.setGridHeight(gridHeight);
            };
            /// <summary>画面リサイズ時のイベント処理を行います。</summary>
            $(App.ui.page).on("resized", resizeContents);
        });
    </script>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <!-- 画面デザイン -- Start -->

    <!-- 検索条件と検索ボタン -->
    <div class="content-part search-criteria">
        <h3 class="part-header" data-app-text="searchCriteria"><a class="search-part-toggle" href="#"></a></h3>
        <div class="part-body">

            <ul class="item-list item-list-left">
                <li>
                    <label>
                        <span class="item-label" data-app-text="nm_kbn_hin"></span>
                        <select id="id_kbn_hin" name="kbn_hin" style="width: auto;" ></select>
                    </label>
                </li>
                <li>
                    <label>
                        <span class="item-label" data-app-text="nm_bunrui"></span>
                        <select id="id_cd_bunrui" name="cd_bunrui" style=" width: 28em;"></select>
                    </label>
                </li>
                <li>
                    <label>
                        <span class="item-label" data-app-text="kbn_hokan" data-tooltip-text="kbn_hokan"></span>
                        <select id="id_kbn_hokan" name="kbn_hokan" style=" width: 28em;"></select>
                    </label>
                </li>
            </ul>
            <ul class="item-list item-list-right">
                <li>
                    <label>
                        <span class="item-label" data-app-text="nm_hinmei"></span>
                        <input type="text" name="nm_hinmei" maxlength="50" size="50" style=" width: 27em;"/>
                    </label>
                </li>
                <li>
                    <span class="item-label" data-app-text="mishiyo" data-tooltip-text="mishiyo"></span>
                    <label>
                        <input type="radio" name="flg_mishiyo" value="1" />
                        <span class="item-label" data-app-text="ari" style=" width: 4em;"></span>
                    </label>
                    <label>
                        <input type="radio" name="flg_mishiyo" value="0" checked />
                        <span class="item-label" data-app-text="nashi"></span>
                    </label>
                </li>
            </ul>
        </div>
        <div class="part-footer">
            <div class="command command-grid">
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
        <h3 id="listHeader" class="part-header">
            <span data-app-text="resultList" style="padding-right: 10px; padding-bottom: 4px;" id="list-results"></span>
            <span class="list-count" id="list-count"></span>
            <span style="padding-left: 50px;" class="list-loading-message" id="list-loading-message"></span>
        </h3>
        <div class="part-body" id="result-grid">
            <div class="list-part-grid-content">
                <div class="item-command" style="left: 17px; right: 17px;">
                    <button type="button" class="colchange-button" data-app-operation="colchange"><span class="icon"></span><span data-app-text="colchange"></span></button>
                    <button type="button" class="add-button" name="add-button" data-app-operation="add"><span class="icon"></span><span data-app-text="add"></span></button>
                    <button type="button" class="detail-button" name="detail-button" data-app-operation="detail"><span class="icon"></span><span data-app-text="detail"></span></button>
                    <button type="button" class="copy-button" name="copy-button" data-app-operation="copy"><span class="icon"></span><span data-app-text="copy"></span></button>
                </div>
                <table id="item-grid" data-app-operation="itemGrid">
                </table>
            </div>
            <!-- 詳細 -->
            <div class="list-part-detail-content"  style="display:none;">
                <div class="item-command" style="left: 17px; right: 17px;">
                    <button type="button" class="list-button" name="list-button"><span class="icon"></span><span data-app-text="list"></span></button>
                    <!-- button type="button" class="save-button" name="save-button" data-app-operation="save"><span class="icon"></span><span data-app-text="save"></span></button -->
                    <button type="button" class="delete-button" name="delete-button" data-app-operation="del"><span class="icon"></span><span data-app-text="del"></span></button>
                </div>
                <ul class="content-part" style="height:2.5em">
                    <li>
<!--                       <label class="item-list-left"> -->
<!--                            <span class="item-label header-part" style="margin-left: 10px; margin-top: 5px;"> -->
<!--                                <span data-app-text="notUse"></span> -->
<!--                                <input type="checkbox" name="flg_mishiyo" value="1" /> -->
<!--                                <span data-app-text="flg_mishiyo"></span> -->
<!--                            </span> -->
<!--                        </label> -->
                        <span class="item-list-left">
                            <!-- id指定で幅を言語によって調整 -->
                            <span class="item-label" id="fushiyo" data-app-text="notUse" data-tooltip-text="notUse" style="margin-left: 10px; margin-top: 9px;"></span>
                            <!-- ラベルで囲み、チェックボックス有効範囲を指定する -->
                            <label>
                                <input type="checkbox" name="flg_mishiyo" value="1" />
                                <span data-app-text="flg_mishiyo"></span>
                            </label>
                        </span>
                        <label class="item-list-center">
                            <span class="item-label" data-app-text="dt_create" style="margin-top: 10px"></span>
                            <span class="item-label header-part data-app-format" id="id_dt_create" name="dt_create" data-app-format="dateTime" style="width: 160px;"></span>
                            <!-- input name="dt_create" class="readonly-txt data-app-format" data-app-format="dateTime" readonly="readonly" tabindex="-1" / -->
                        </label>
                        <label class="item-list-right" style="width: 33%;">
                            <span class="item-label" data-app-text="dt_update" style="margin-top: 10px"></span>
                            <span class="item-label header-part data-app-format" id="id_dt_update" name="dt_update" data-app-format="dateTime" style="width: 160px;"></span>
                            <!-- input name="dt_update" class="readonly-txt data-app-format" data-app-format="dateTime" readonly="readonly" tabindex="-1" / -->
                        </label>
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
                    <li class="validation-seihin validation-jikagen validation-genryo validation-shizai">
                        <label>
                            <span class="item-label" data-app-text="cd_hinmei"></span>
                            <input id="cd_hinmei" type="text" name="cd_hinmei" maxlength="14" />
                        </label>
                    </li>
                    <li class="validation-seihin validation-jikagen validation-genryo validation-shizai">
                        <label>
                            <span class="item-label nm_hinmei_detail_ja" data-app-text="nm_hinmei_ja" data-tooltip-text="nm_hinmei_ja"></span>
                            <input type="text" id="nm_hinmei_detail_ja" name="nm_hinmei_ja" maxlength="50" />
                        </label>
                    </li>
                    <li class="validation-seihin validation-jikagen validation-genryo validation-shizai">
                        <label>
                            <span class="item-label nm_hinmei_detail_en" data-app-text="nm_hinmei_en" data-tooltip-text="nm_hinmei_en"></span>
                            <input type="text" id="nm_hinmei_detail_en" name="nm_hinmei_en" maxlength="50" />
                        </label>
                    </li>
                    <li class="validation-seihin validation-jikagen validation-genryo validation-shizai">
                        <label>
                            <span class="item-label nm_hinmei_detail_zh" data-app-text="nm_hinmei_zh" data-tooltip-text="nm_hinmei_zh"></span>
                            <input type="text" id="nm_hinmei_detail_zh" name="nm_hinmei_zh" maxlength="50" />
                        </label>
                    </li>
                    <li class="validation-seihin validation-jikagen validation-genryo validation-shizai">
                        <label>
                            <span class="item-label nm_hinmei_detail_vi" data-app-text="nm_hinmei_vi" data-tooltip-text="nm_hinmei_vi"></span>
                            <input type="text" id="nm_hinmei_detail_vi" name="nm_hinmei_vi" maxlength="50" />
                        </label>
                    </li>
                    <li class="validation-seihin validation-jikagen validation-genryo validation-shizai">
                        <label>
                            <span class="item-label" data-app-text="nm_hinmei_ryaku" data-tooltip-text="nm_hinmei_ryaku"></span>
                            <input type="text" name="nm_hinmei_ryaku" maxlength="50" />
                        </label>
                    </li>
                    <li class="validation-seihin validation-jikagen validation-genryo validation-shizai">
                        <label>
                            <!-- 2014.10.22:品区分は編集不可とする -->
                            <span class="item-label" data-app-text="nm_kbn_hin" name="nm_kbn_hin_detail"></span>
                            <select name="kbn_hin" style="width: 153px; background-color: #F2F2F2;" disabled="disabled"></select>
                        </label>
                    </li>
                    <li class="validation-seihin validation-jikagen validation-genryo validation-shizai">
                        <label>
                            <span class="item-label" data-app-text="nm_nisugata_hyoji"></span>
                            <input type="text" name="nm_nisugata_hyoji" maxlength="50" />
                        </label>
                    </li>
                    <li class="validation-seihin validation-jikagen validation-genryo validation-shizai">
                        <label>
                            <span class="item-label" data-app-text="wt_nisugata_naiyo" data-tooltip-text="wt_nisugata_naiyo"></span>
                            <input type="text" name="wt_nisugata_naiyo" class="text-align-right format-thousands-Separator data-app-number" comma="6" />
                        </label>
                    </li>
                    <li class="validation-seihin validation-jikagen validation-genryo validation-shizai">
                        <label>
                            <span class="item-label" data-app-text="su_iri" data-tooltip-text="su_iri"></span>
                            <input type="text" name="su_iri" class="text-align-right format-thousands-Separator data-app-number" />
                        </label>
                    </li>
                    <li class="validation-seihin validation-jikagen validation-genryo validation-shizai">
                        <label>
                            <span class="item-label" data-app-text="wt_ko" data-tooltip-text="wt_ko"></span>
                            <input type="text" name="wt_ko" class="text-align-right format-thousands-Separator data-app-number" comma="6" />
                        </label>
                    </li>
                    <li>
                        <span class="item-label" data-app-text="kbn_kanzan" data-tooltip-text="kbn_kanzan"></span>
                        <label style="width:50px;">
                            <input class="shizai-disp-no all" type="radio" name="kbn_kanzan" value="4" checked="checked" /><span class="item-label unit labelKg " data-app-text="labelKg"></span><span class="item-label unit labelLB " data-app-text="labelLB"></span>
                        </label>
                        <label style="width:50px;">
                            <input class="shizai-disp-no all" type="radio" name="kbn_kanzan" value="11" /><span class="item-label unit labelL" data-app-text="labelL"></span><span class="item-label unit labelGAL" data-app-text="labelGAL"></span>
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="cd_tani_nonyu"></span>
                            <select class="seihin-disp-no all" name="cd_tani_nonyu" style="width: 153px;"></select>
                        </label>
                    </li>
                    <li class="validation-jikagen validation-genryo validation-shizai kbnTaniHasu">
                        <label>
                            <span class="item-label" data-app-text="cd_tani_nonyu_hasu"></span>
                            <select class="seihin-disp-no all" name="cd_tani_nonyu_hasu" style="width: 153px;"></select>
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="cd_tani_shiyo"></span>
                            <select class="seihin-disp-no genryo-disp-no all" name="cd_tani_shiyo" style="width: 153px;"></select>
                        </label>
                    </li>
                    <li class="validation-seihin validation-jikagen validation-genryo">
                        <label>
                            <span class="item-label" data-app-text="ritsu_hiju"></span>
                            <input id="id_ritsu_hiju" class="shizai-disp-no all text-align-right format-thousands-Separator data-app-number" comma="4" type="text" name="ritsu_hiju" />
                        </label>
                    </li>
                    <li class="validation-jikagen validation-genryo validation-shizai">
                        <label>
                            <span class="item-label" data-app-text="tan_ko"></span>
                            <input type="text" name="tan_ko" class="text-align-right format-thousands-Separator data-app-number" comma="4" /><span class="item-label unit currency" style="margin-left:4px;" data-app-text="currencyEn"></span>
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label" data-app-text="cd_bunrui"></span>
                            <select name="cd_bunrui" style="width: 153px;"></select>
                        </label>
                    </li>
                    <li class="validation-seihin validation-jikagen validation-genryo validGenryoRequired">
                        <label>
                            <span class="item-label" data-app-text="dd_shomi"></span>
                            <input class="shizai-disp-no all text-align-right" type="text" maxlength="4" name="dd_shomi" />
                            <span class="item-label unit" data-app-text="labelDay"></span>
                        </label>
                    </li>
                    <li class="validation-jikagen validation-genryo validGenryoRequired">
                        <label>
                            <span class="item-label" data-app-text="dd_kaifugo_shomi" data-tooltip-text="dd_kaifugo_shomi"></span>
                            <input class="seihin-disp-no shizai-disp-no all text-align-right" type="text" maxlength="4" name="dd_kaifugo_shomi" />
                            <span class="item-label unit" data-app-text="labelDay"></span>
                        </label>
                    </li>
                </ul>
                <ul class="item-list item-list-center clearfix">
                    <li class="validGenryoRequired">
                        <label>
                            <span class="item-label-right" data-app-text="kbn_hokan" data-tooltip-text="kbn_hokan"></span>
                            <%--<select class="shizai-disp-no all" name="kbn_hokan" style="width: 153px;"></select>--%>
                            <select class="shizai-disp-no all" data-form-item="kbn_hokan" name="kbn_hokan_detail" style="width: 153px;"></select>
                        </label>
                    </li>
                    <li class="validGenryoRequired">
                        <label>
                            <span class="item-label-right" data-app-text="kbn_kaifugo_hokan" data-tooltip-text="kbn_kaifugo_hokan"></span>
                            <%--<select class="seihin-disp-no shizai-disp-no all" name="kbn_kaifugo_hokan" style="width: 153px;"></select>--%>
                            <select class="seihin-disp-no shizai-disp-no all" data-form-item="kbn_kaifugo_hokan" name="kbn_kaifugo_hokan_detail" style="width: 153px;"></select>
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label-right" data-app-text="kbn_jotai"></span>
                            <select class="seihin-disp-no shizai-disp-no all" name="kbn_jotai" style="width: 153px;"></select>
                        </label>
                    </li>
                    <li class="validation-jikagen validation-genryo validation-shizai item-hidden">
                        <label>
                            <span class="item-label-right" data-app-text="kbn_zei"></span>
                            <select class="seihin-disp-no all" name="kbn_zei" style="width: 153px;"></select>
                        </label>
                    </li>
                    <li class="validation-jikagen validation-genryo validation-shizai">
                        <label>
                            <span class="item-label-right" data-app-text="ritsu_budomari"></span>
                            <input class="seihin-disp-no all text-align-right format-thousands-Separator data-app-number" comma="2" type="text" name="ritsu_budomari" />
                            <span class="item-label unit" data-app-text="labelPercent"></span>
                        </label>
                    </li>
                    <li class="validation-jikagen validation-genryo validation-shizai vali-zaiko-min">
                        <label>
                            <span class="item-label-right" data-app-text="su_zaiko_min"></span>
                            <input id="id_su_zaiko_min" class="seihin-disp-no all text-align-right format-thousands-Separator data-app-number" comma="6" type="text" name="su_zaiko_min" />
                        </label>
                    </li>
                    <li class="validation-jikagen validation-genryo validation-shizai vali-zaiko-max">
                        <label>
                            <span class="item-label-right" data-app-text="su_zaiko_max"></span>
                            <input id="id_su_zaiko_max" class="seihin-disp-no all text-align-right format-thousands-Separator data-app-number" comma="6" type="text" name="su_zaiko_max" />
                        </label>
                    </li>
                    <!-- <li> / -->
                    <li class="validation-jikagen validation-genryo validation-shizai vali-zaiko-max">
                        <label>
                            <span class="item-label-right" data-app-text="cd_niuke_basho"></span>
                            <select class="seihin-disp-no all" name="cd_niuke_basho" style="width: 153px;"></select>
                        </label>
                    </li>
                    <li class="validation-jikagen validation-genryo validation-shizai">
                        <label>
                            <span class="item-label-right" data-app-text="dd_leadtime" data-tooltip-text="dd_leadtime"></span>
                            <input class="seihin-disp-no all text-align-right" type="text" name="dd_leadtime" maxlength="3" />
                            <span class="item-label unit" data-app-text="labelDay"></span>
                        </label>
                    </li>
                    <ul class="item-list item-command">
                        <li>
                            <span class="item-label-right" data-app-text="line" data-tooltip-text="line"></span>
                            <label name="line-label">
                                <button type="button" class="dialog-button shizai-disp-no genryo-disp-no all" id="line-button" name="line-button" data-app-operation="lineButton">
                                    <span class="icon"></span><span data-app-text="lineSearch"></span>
                                </button>
                            </label>
                            <span id="chk_line_detail" name="chk_line" style="width:100px;"></span>
                        </li>
                    </ul>
                    <ul class="item-list item-command">
                        <li class="validation-seihin validation-jikagen vali_cd_torihiki1 item-hidden">
                            <label>
                                <span class="item-label-right" data-app-text="nm_torihiki1"></span>
                                <input class="dialog-button shizai-disp-no genryo-disp-no all" id="cd_torihiki1_detail" type="text" name="cd_hanbai_1" style="width:120px; " maxlength="13" />
                                <button type="button" class="dialog-button shizai-disp-no genryo-disp-no all" id="torihiki1-button" name="torihiki1-button" data-app-operation="torihiki1Button">
                                    <span class="icon" ></span><span data-app-text="codeSearch"></span>
                                </button>
                            </label>
                        </li>
                        <li class="validation-seihin validation-jikagen vali_cd_torihiki1 item-hidden">
                            <label>
                                <span class="item-label-right">&nbsp;</span>
                                <span class="item-label" id="nm_torihiki1_detail" name="nm_torihiki1" style="width:210px; white-space:nowrap; overflow:hidden;"></span>
                            </label>
                        </li>
                    </ul>
                    <ul class="item-list item-command">
                        <li class="validation-seihin validation-jikagen vali_cd_torihiki2 item-hidden">
                            <label>
                                <span class="item-label-right" data-app-text="nm_torihiki2"></span>
                                <input class="dialog-button shizai-disp-no genryo-disp-no all" id="cd_torihiki2_detail" type="text" name="cd_hanbai_2" style="width:120px;" maxlength="13" />
                                <button type="button" class="dialog-button shizai-disp-no genryo-disp-no all" id="torihiki2-button" name="torihiki2-button" data-app-operation="torihiki2Button">
                                    <span class="icon"></span><span data-app-text="codeSearch"></span>
                                </button>
                            </label>
                        </li>
                        <li class="validation-seihin validation-jikagen vali_cd_torihiki1 item-hidden">
                            <label>
                                <span class="item-label-right">&nbsp;</span>
                                <span class="item-label" id="nm_torihiki2_detail" name="nm_torihiki2" style="width:210px; white-space:nowrap; overflow:hidden;"></span>
                            </label>
                        </li>
                    </ul>
                    <ul class="item-list item-command">
                        <li class="validation-seihin validation-jikagen vali_cd_haigo">
                            <label>
                                <span class="item-label-right" data-app-text="nm_haigo"></span>
                                <input class="dialog-button shizai-disp-no genryo-disp-no all" id="cd_haigo_detail" type="text" name="cd_haigo" style="width:120px;" maxlength="14" />
                                <button type="button" class="dialog-button shizai-disp-no genryo-disp-no all" id="haigo-button" name="haigo-button" data-app-operation="haigoButton">
                                    <span class="icon"></span><span data-app-text="codeSearch"></span>
                                </button>
                            </label>
                        </li>
                        <li class="validation-seihin validation-jikagen vali_cd_haigo">
                            <label>
                                <span class="item-label">&nbsp;</span>
                                <span id="nm_haigo_detail" name="nm_haigo" style="width:225px; white-space:nowrap; overflow:hidden;"></span>
                            </label>
                        </li>
                    </ul>
                    <li class="validation-seihin validation-jikagen item-hidden">
                        <label>
                            <span class="item-label-right" data-app-text="cd_jan"></span>
                            <input id="id_cd_jan" class="dialog-button shizai-disp-no genryo-disp-no all" type="text" name="cd_jan" maxlength="13" />
                        </label>
                    </li>                   
                    <li class="validation-jikagen validation-genryo validation-shizai kbnKotei">
                        <label>
                            <span class="item-label-right" data-app-text="dd_kotei"></span>
                            <input class="seihin-disp-no all text-align-right" type="text" name="dd_kotei" maxlength="3" />
                            <span class="item-label unit" data-app-text="labelDay"></span>
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label-right" data-app-text="flg_testitem"></span>
                            <input type="checkbox" name="flg_testitem" value="1" />
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label-right" data-app-text="flg_trace_taishogai"></span>
                            <input type="checkbox" name="flg_trace_taishogai" value="1" />
                        </label>
                    </li>
                    <!--<li class="validation-jikagen validation-genryo validation-shizai kbnTaniHasu">
                        <label>
                            <span class="item-label-right" data-app-text="cd_tani_nonyu_hasu"></span>
                            <select class="seihin-disp-no all" name="cd_tani_nonyu_hasu" style="width: 153px;"></select>
                        </label>
                    </li>-->
                    <li class="validation-jikagen validation-genryo validGenryoRequired kaitogoShomi">
                        <label>
                            <span class="item-label-right" data-app-text="dd_kaitogo_shomi" data-tooltip-text="dd_kaitogo_shomi"></span>
                            <input class="seihin-disp-no shizai-disp-no all text-align-right" type="text" maxlength="4" name="dd_kaitogo_shomi" />
                            <span class="item-label unit" data-app-text="labelDay"></span>
                        </label>
                    </li>
                    <li class="validGenryoRequired kaitogoHokan">
                        <label>
                            <span class="item-label-right" data-app-text="kbn_kaitogo_hokan" data-tooltip-text="kbn_kaitogo_hokan"></span>
                            <select class="seihin-disp-no shizai-disp-no all" data-form-item="kbn_kaitogo_hokan" name="kbn_kaitogo_hokan_detail" style="width: 153px;"></select>
                        </label>
                    </li>
                </ul>
                <ul class="item-list item-list-right clearfix">
                    <li class="validation-seihin validation-jikagen">
                        <label>
                            <span class="item-label-right" data-app-text="su_batch_dekidaka" data-tooltip-text="su_batch_dekidaka"></span>
                            <input class="dialog-button shizai-disp-no genryo-disp-no all text-align-right format-thousands-Separator data-app-number" comma="2" type="text" name="su_batch_dekidaka" />
                            <span class="item-label unit" data-app-text="labelCase"></span>
                        </label>
                    </li>
                    <li class="validation-seihin validation-jikagen item-hidden">
                        <label>
                            <span class="item-label-right" data-app-text="su_palette"></span>
                            <input class="dialog-button shizai-disp-no genryo-disp-no all text-align-right format-thousands-Separator data-app-number" type="text" name="su_palette" maxlength="4" />
                            <span class="item-label unit" data-app-text="labelCase"></span>
                        </label>
                    </li>
                    <li class="validation-seihin validation-jikagen">
                        <label>
                            <span class="item-label-right" data-app-text="kin_romu" data-tooltip-text="kin_romu"></span>
                            <input class="dialog-button shizai-disp-no genryo-disp-no all text-align-right format-thousands-Separator data-app-number" comma="4" type="text" name="kin_romu" />
                            <span class="item-label unit currency" data-app-text="currencyEn"></span>
                        </label>
                    </li>
                    <li class="validation-seihin validation-jikagen">
                        <label>
                            <span class="item-label-right" data-app-text="kin_keihi_cs"></span>
                            <input class="dialog-button shizai-disp-no genryo-disp-no all text-align-right format-thousands-Separator data-app-number" comma="4" type="text" name="kin_keihi_cs" />
                            <span class="item-label unit currency" data-app-text="labelEn"></span>
                        </label>
                    </li>
                    <li class="item-hidden">
                        <label>
                            <span class="item-label-right" data-app-text="kbn_kuraire"></span>
                            <select class="dialog-button shizai-disp-no genryo-disp-no all" name="kbn_kuraire" style="width: 153px;"></select>
                        </label>
                    </li>
                    <li class="validation-jikagen">
                        <label>
                            <span class="item-label-right" data-app-text="tan_nonyu"></span>
                            <input class="seihin-disp-no genryo-disp-no shizai-disp-no all text-align-right format-thousands-Separator data-app-number" comma="4" type="text" name="tan_nonyu" />
                            <span class="item-label unit currency" data-app-text="labelEn"></span>
                        </label>
                    </li>
                    <!-- <li class="validation-jikagen">
                        <label>
                            <span class="item-label-right" data-app-text="flg_tenkai"></span>
                            <input class="seihin-disp-no genryo-disp-no shizai-disp-no all" type="checkbox" name="flg_tenkai" value="1" />
                            <span class="item-label unit" data-app-text="labelTenkai"></span>
                        </label>
                    </li> -->
                    <ul class="item-list item-command">
                    <li class="validation-genryo validation-shizai vali_cd_seizo item-hidden">
                        <label>
                            <span class="item-label-right" data-app-text="nm_seizo"></span>
                            <input class="seihin-disp-no jikagen-disp-no all" id="cd_seizo_detail" type="text" name="cd_seizo" style="width:120px;" maxlength="13" />
                            <button type="button" class="dialog-button seihin-disp-no jikagen-disp-no all" id="seizo-button" name="seizo-button" data-app-operation="seizoButton">
                                <span class="icon"></span><span data-app-text="codeSearch"></span>
                            </button>
                        </label>
                    </li>
                    <li class="validation-genryo validation-shizai item-hidden">
                        <label>
                            <span class="item-label-right">&nbsp;</span>
                            <span class="item-label" id="nm_seizo_detail" name="nm_seizo" style="width:210px; white-space:nowrap; overflow:hidden;"></span>
                        </label>
                    </li>
                   </ul>
                    <li class="validation-genryo validation-shizai item-hidden">
                        <label>
                            <span class="item-label-right" data-app-text="cd_maker_hin"></span>
                            <input class="seihin-disp-no jikagen-disp-no all" type="text" name="cd_maker_hin" maxlength="13" />
                        </label>
                    </li>
                    <li class="validation-genryo validation-shizai">
                        <label>
                            <span class="item-label-right" data-app-text="su_hachu_lot_size"></span>
                            <input type="text" class="seihin-disp-no jikagen-disp-no all text-align-right format-thousands-Separator data-app-number" comma="2" name="su_hachu_lot_size" />
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label-right" data-app-text="cd_kura"></span>
                            <select class="seihin-disp-no jikagen-disp-no all" name="cd_kura" style="width: 153px;"></select>
                        </label>
                    </li>
                    <li>
                        <label>
                            <span class="item-label-right cd_location" data-app-text="cd_location"></span>
                            <select class="seihin-disp-no jikagen-disp-no all" name="cd_location" style="width: 153px;"></select>
                        </label>
                    </li>
                    <li class="validation-seihin validation-jikagen validation-genryo validation-shizai">
                        <label>
                            <span class="item-label-right" data-app-text="biko" style="vertical-align: top;"></span>
                            <textarea name="biko" id="id_biko" cols="30" rows="4" style="ime-mode: active;"></textarea>
                        </label>
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
                </ul>
                <div class="clearfix">
                </div>
            </div>
        </div>
        <!-- グリッドコントロール固有のデザイン -- End -->
    </div>
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
            <div class="command-detail" style="position: absolute; left: 10px; top: 5px;">
                <button class="dlg-yes-button" name="dlg-yes-button" data-app-text="yes"></button>
            </div>
            <div class="command-detail" style="position: absolute; right: 5px; top: 5px;">
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
            <div class="command-detail" style="position: absolute; left: 10px; top: 5px">
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
            <div class="command-detail" style="position: absolute; left: 10px; top: 5px">
                <button class="dlg-yes-button" name="dlg-yes-button" data-app-text="yes"></button>
            </div>
            <div class="command-detail" style="position: absolute; right: 5px; top: 5px;">
                <button class="dlg-no-button" name="dlg-no-button" data-app-text="no"></button>
            </div>
        </div>
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
            <div class="command-detail" style="position: absolute; left: 10px; top: 5px">
                <button class="dlg-yes-button" name="dlg-yes-button" data-app-text="yes"></button>
            </div>
            <div class="command-detail" style="position: absolute; right: 5px; top: 5px;">
                <button class="dlg-no-button" name="dlg-no-button" data-app-text="no"></button>
            </div>
        </div>
    </div>
    <!-- 画面デザイン -- End -->
</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="FooterContent" runat="server">
    <!-- 画面デザイン -- Start -->

    <!-- 画面アーキテクチャ共通のデザイン -- Start -->
    <div class="command command-grid" style="left: 1px;">
        <button type="button" class="excel-button" name="excel-button" data-app-operation="excel"><span data-app-text="excel"></span></button>
    </div>
    <div class="command-detail" style="left: 1px; display:none;">
        <button type="button" class="save-button" name="save-button" data-app-operation="save">
            <span class="icon"></span><span data-app-text="save"></span>
        </button>
        <button type="button" class="pdf-button" name="pdf-button" data-app-operation="print"><span data-app-text="print"></span></button>
        <button type="button" class="clear-button" name="clear-button" data-app-operation="clear"><span data-app-text="clear"></span></button>
        <button type="button" class="shizai-button" name="shizai-button" data-app-operation="shizaiButton"><span data-app-text="shizaiButton"></span></button>
        <button type="button" class="konyu-button" name="konyu-button" data-app-operation="konyuButton"><span data-app-text="konyuButton"></span></button>
    </div>
    <div class="command command-grid" style="right: 9px;">
        <button type="button" class="menu-button" name="menu-button">
            <span class="icon"></span>
            <span data-app-text="menu"></span>
        </button>
    </div>
    <div class="command-detail" style="right: 9px; display:none;">
        <button type="button" class="menu-button" name="menu-button">
            <span class="icon"></span>
            <span data-app-text="menu"></span>
        </button>
    </div>
    <div class="command command-grid" style="right: 9px;">
    </div>
    <!-- 画面アーキテクチャ共通のデザイン -- End -->

    <!-- 画面デザイン -- End -->
</asp:Content>
<asp:Content ID="Content5" ContentPlaceHolderID="DialogsContent" runat="server">
    <!-- 画面デザイン -- Start -->
    <div class="torihiki-dialog">
    </div>
    <div class="torihiki2-dialog">
    </div>
    <div class="seizo-dialog">
    </div>
    <div class="haigo-dialog">
    </div>

    <!-- 画面デザイン -- End -->
</asp:Content>
