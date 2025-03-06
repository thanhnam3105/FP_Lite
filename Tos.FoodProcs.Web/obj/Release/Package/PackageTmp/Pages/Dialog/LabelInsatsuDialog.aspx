<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LabelInsatsuDialog.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.Dialog.LabelInsatsuDialog" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <style type="text/css">
        /* 画面デザイン -- Start */
        
        /* TODO：画面の仕様に応じて以下のスタイルを変更してください。 */
        .dialog-content-label .item-label
        {
            width: 140px;
            line-height: 180%;
            display: inline-block;
        }
        
        .dialog-content-label .item-label-muji
        {
            /*width: 4em;*/
            width: 5em;
            line-height: 180%;
            display: inline-block;
        }
        
        .dialog-content-label .item-label-seikihasu
        {
            width: 4em;
            line-height: 180%;
            display: inline-block;
        }
        
        .dialog-content-label .item-label-head
        {
            width: 7em;
            line-height: 130%;
            display: inline-block;
            background-color: #E6E6FA;
        }
          
        .dialog-content-label .item-input
        {
            width: 12em;
            line-height: 180%;
        }
        .dialog-content-label .dialog-search-criteria
        {
            border: solid 1px #efefef;
            padding-top: 0.5em;
            padding-left: 0.5em;
            overflow: hidden;
        }
        .dialog-content-label .dialog-search-criteria .part-footer
        {
            margin-top: 1em;
            margin-left: .5em;
            margin-right: .5em;
            position: relative;
            height: 40px;
            border-top: solid 1px #dbdbdb;
        }
        .dialog-content-label .dialog-search-criteria .part-footer .command
        {
            position: absolute;
            display: inline-block;
            right: 0;
        }
        .dialog-content-label .dialog-result-list
        {
            margin-top: 10px;
        }
        .dialog-content-label .dialog-search-criteria .part-footer .command button
        {
            position: relative;
            margin-left: .5em;
            top: 5px;
            padding: 0px;
            min-width: 100px;
            margin-right: 0;
        }
        
        /* グリッドのスタイル */
        .part-grid-up
        {
            margin: .3em;
            /*height: 155px;*/
            /*width: 95%;*/
            width: 94%;
            position:relative;
            /*left: 60px;*/
            left: 80px;
            top: -37px;
            
        }
        .part-grid-down
        {
            margin: .3em;
            /*height: 155px;*/
            /*width: 95%;*/
            width: 94%;
            position:relative;
            /*left: 60px;*/
            left: 80px;
            top: -37px;
        }
        
        #grid-seiki
        {
            padding: 0px;
            
        }
        #grid-hasu
        {
            padding: 0px;
            
        }
        .seiki-area
        {
            height:165px;
        }
        .hasu-area
        {
            height:165px;
            
        }
        /*.ui-button-text*/
        #grid-view .ui-button-text
        {
            min-width:45px;
        }
        #label-hakko .ui-button-text
        {
            min-width:45px;
        }
        .dialog-content-label .item-list li
        {
            margin-bottom: .2em;
            
        }
        
        .dialog-content-label .item-list-left li
        {
            float: left;
            width: 45%;
        }
        
        .dialog-content-label .item-list-right li
        {
            width: 40%;
            margin-left: 45%;
        }
        #grid-view
        {
            position: absolute;
            /*right: 55px;*/
            right: 60px;
            top: 60px;
        }
        .suji-label
        {
            width:5em;
            line-height: 180%;
            display: inline-block;
        }
        .dialog-content-label .dialog-footer .command input
        {
            width : 3em;
            text-align:right;
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
        // TODO：画面の仕様に応じて以下のダイアログ名を変更してください。
        $.dlg.register("LabelInsatsuDialog", {
            // TODO：ここまで
            initialize: function (context) {
                //// 変数宣言 -- Start
                var version;
                var elem = context.element,
                    pageLangText = App.ui.pagedata.lang(App.ui.page.lang),
                    isLabelPrintEnd = true,
                    validationSetting = App.ui.pagedata.validation(App.ui.page.lang),
                // 小分けラベルの各項目桁数
                    kowakeLabelKeta;
                // 枠線表示切替区分
                var kbnWakusen;
                // 小数点表示切替区分
                var ketaShosuten;
                // 正規、端数区分
                var kbnSeikiHasu;
                // 工場マスタ情報
                var kojoInfo;
                // 小分計算区分
                var kbnKowakefutai;
                // パラメータからmultiselectを設定
                //var multiselect = false;
                var multiselect = true;
                if (context.data.multiselect) {
                    multiselect = context.data.multiselect;
                }
                //アレルゲン標示用変数
                var allergyKbn = "";
                var allergyName = "";
                var otherKbn = "";
                var otherName = "";
                //Add tool tip
                App.customTooltip(".kobetsu-label-dialog");
                // 配合基本重量
                var wt_haigo_gokei = 0;

                var shikakariLot = context.data.param1,
                    lineName = context.data.param2,
                    haigoName = context.data.param3,
                    shikomiRyo = context.data.param4,
                    ritsuKeikaku = context.data.param5,
                    ritsuHasu = context.data.param6,
                    batchKeikaku = context.data.param7,
                    batchHasu = context.data.param8,
                    haigoCode = context.data.param9,
                    seizoDate = context.data.param10,
                // 品名の多言語
                    hinmeiName = 'nm_hinmei_' + App.ui.page.lang;

                // ダイアログ情報メッセージの設定
                var dialogNotifyInfo = App.ui.notify.info(elem, {
                    container: elem.find(".dialog-slideup-area .info-message"),
                    messageContainerQuery: "ul",
                    show: function () {
                        elem.find(".info-message").show();
                    },
                    clear: function () {
                        elem.find(".info-message").hide();
                    }
                });
                // ダイアログ警告メッセージの設定
                var dialogNotifyAlert = App.ui.notify.alert(elem, {
                    container: elem.find(".dialog-slideup-area .alert-message"),
                    messageContainerQuery: "ul",
                    show: function () {
                        elem.find(".alert-message").show();
                    },
                    clear: function () {
                        elem.find(".alert-message").hide();
                    }
                });
                App.ui.pagedata.operation.applySetting(App.ui.page.user.Roles[0], App.ui.page.lang);
                var dialog_grid_seiki = $("#dialog-list-seiki"),
                    dialog_grid_hasu = $("#dialog-list-hasu"),
				    querySettingDialog = { skip: 0, top: 500, count: 0 },
				    isDialogLoading = false,
				    lastScrollTopDialog = 0;
                var dt_seizo = App.data.getDateTimeStringForQueryNoUtc(App.data.getDate(seizoDate));

                // 画面アーキテクチャ共通の事前データロード
                App.deferred.parallel({
                    // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                    kowakeLabelKeta: App.ajax.webgetSync("../Services/FoodProcsService.svc/ma_label_read()?$filter=cd_format eq '"
                                            + pageLangText.labelFormatKowake.text + "' & orderby eq no_jun $ select=no_jun,su_byte "),
                    kbnWakusen: App.ajax.webgetSync("../Services/FoodProcsService.svc/cn_kino_sentaku?$filter=kbn_kino eq " + pageLangText.kinoWakusenHyojiKbn.number),
                    //ketaShosuten: App.ajax.webget("../Services/FoodProcsService.svc/ma_kojo"),
                    kojoInfo: App.ajax.webgetSync("../Services/FoodProcsService.svc/ma_kojo"),
                    // 配合名マスタから、最新の版の配合情報を取得
                    //haigoMstData: App.ajax.webget("../Services/FoodProcsService.svc/ma_haigo_mei?&$filter="
                    //+ "cd_haigo eq '" + haigoCode + "' and "
                    //+ "dt_from le DateTime'" + dt_seizo
                    //+ "'&$orderby=dt_from desc"
                    //+ "&$top=1")
                    // TODO: ここまで
                }).done(function (result) {
                    // TODO: 画面の仕様に応じて以下のサービス呼び出し成功時の処理を変更してください。
                    // 小分けラベル発行時に利用する桁数を取得
                    kowakeLabelKeta = result.successes.kowakeLabelKeta.d;
                    // 枠線表示切替区分の設定
                    if (result.successes.kbnWakusen.d.length == 0) {
                        kbnWakusen = 0;
                    } else {
                        kbnWakusen = result.successes.kbnWakusen.d[0].kbn_kino_naiyo;
                    }
                    // 小数点表示切替区分の設定
                    //ketaShosuten = result.successes.ketaShosuten.d[0].su_keta_shosuten;
                    ketaShosuten = result.successes.kojoInfo.d[0].su_keta_shosuten;

                    // 小分計算区分の設定
                    kbnKowakefutai = result.successes.kojoInfo.d[0].kbn_kowake_futai;

                    //wt_haigo_gokei = result.successes.haigoMstData.d[0].wt_haigo_gokei;
                    // TODO: ここまで
                }).fail(function (result) {
                    var length = result.key.fails.length,
                        messages = [];
                    for (var i = 0; i < length; i++) {
                        var keyName = result.key.fails[i];
                        var value = result.fails[keyName];
                        messages.push(keyName + " " + value.message);
                    }
                    dialogNotifyAlert.message(messages).show();
                }).always(function () {
                });

                /// <summary>クエリオブジェクトの設定<summary>
                var queryDialog = function () {
                    var query = {
                        // TODO: 画面の仕様に応じて以下のエンドポイントを変更してください。
                        url: "../api/LabelInsatsu",
                        no_lot_shikakari: shikakariLot,
                        kbn_jotai: pageLangText.sonotaJotaiKbn.text,
                        flg_mishiyo: pageLangText.shiyoMishiyoFlg.text
                        // TODO：ここまで

                    }
                    return query;
                };

                // 検索処理
                var searchItemsDialog = function (_query) {
                    if (isDialogLoading === true) {
                        return;
                    }
                    isDialogLoading = true;
                    // ローディングの表示
                    App.ui.loading.show(pageLangText.nowLoading.text, ".dialog-content-label");

                    App.ajax.webget(
                       App.data.toWebAPIFormat(_query)
                    ).done(function (result) {
                        // データバインド
                        $("#selectLineName").text(lineName);
                        $("#selectHaigoName").text(haigoCode + " " + haigoName);
                        $("#selectJyuryoSoShikomi").text(shikomiRyo);
                        $("#ritsuSeiki").text(ritsuKeikaku);
                        $("#ritsuHasu").text(ritsuHasu);
                        $("#batchSeiki").text(batchKeikaku);
                        $("#batchHasu").text(batchHasu);
                        bindDataDialog(result);
                        bindDataHasuDialog(result);
                        // グリッドの先頭行選択
                        var idNumSeiki = $("#dialog-list-seiki").getGridParam("selrow");
                        if (idNumSeiki == null) {
                            $("#dialog-list-seiki").jqGrid('setSelection', 1, true);
                        }
                        var idNumHasu = $("#dialog-list-hasu").getGridParam("selrow");
                        if (idNumHasu == null) {
                            $("#dialog-list-hasu").jqGrid('setSelection', 1, true);
                        }

                        if (dialog_grid_seiki.getGridParam("records") < 1 && dialog_grid_hasu.getGridParam("records") > 0) {
                            $("#radio-hasu").prop("checked", true);
                            $("#radio-hasu").click();
                        }

                    }).fail(function (result) {
                        //dialogNotifyInfo.message(result.message).show();
                        dialogNotifyAlert.message(result.message).show();
                    }).always(function () {
                        isDialogLoading = false;
                        // ローディングの終了
                        App.ui.loading.close(".dialog-content-label");
                    });
                };
                var clearStateDialog = function () {
                    // データクリア
                    dialog_grid_seiki.clearGridData();
                    dialog_grid_hasu.clearGridData();
                    $("#suKaishiBatch").val("");
                    $("#suShuryoBatch").val("");
                    querySettingDialog.skip = 0;
                    querySettingDialog.count = 0;
                    lastScrollTopDialog = 0;
                    displayCountDialog();
                    // 情報メッセージのクリア
                    dialogNotifyInfo.clear();
                    // エラーメッセージのクリア
                    dialogNotifyAlert.clear();
                };
                /// <summary>データ取得件数を表示します。</summary>
                var displayCountDialog = function () {
                    $(".list-count-dialog").text(
                        App.str.format("{0}/{1}", querySettingDialog.skip, querySettingDialog.count)
                    );
                };
                /// <summary>データをバインドします。</summary>
                /// <param name="result">検索結果</param>
                var bindDataDialog = function (result) {
                    querySettingDialog.skip = querySettingDialog.skip + result.d.length;
                    querySettingDialog.count = parseInt(result.__count);
                    // グリッドの表示件数を更新
                    dialog_grid_seiki.setGridParam({ rowNum: querySettingDialog.skip });
                    displayCountDialog();

                    // 正規バッチがあるデータのみ表示するよう、データの選り分け
                    var len = result.d.length,
                        i = 0,
                        bindDataAry = new Array();
                    for (; i < len; i++) {
                        var seikiData = result.d[i],
                            batch = seikiData.su_batch_keikaku,
                            ritsu = seikiData.ritsu_keikaku;

                        // 荷姿数が0の時
                        if (seikiData.su_nisugata_kowake_seiki == 0) {

                            // 荷姿数と荷姿重量をブランクにする
                            seikiData.su_nisugata_kowake_seiki = " ";
                            seikiData.wt_nisugata = " ";

                        }

                        // 小分数１が0の時
                        if (seikiData.su_kowake1_kowake_seiki == 0) {

                            // 小分数１と小分重量１をブランクにする
                            seikiData.su_kowake1_kowake_seiki = " ";
                            seikiData.wt_kowake1_seiki = " ";

                        }

                        // 小分数２が0の時
                        if (seikiData.su_kowake2_kowake_seiki == 0) {

                            // 小分数２と小分重量２をブランクにする
                            seikiData.su_kowake2_kowake_seiki = " ";
                            seikiData.wt_kowake2_seiki = " ";

                        }

                        if (!App.isUndefOrNull(batch) && !App.isUndefOrNull(ritsu) && batch * ritsu > 0) {
                            bindDataAry.push(seikiData);
                        }
                    }

                    // データバインド正規
                    //var currentDataSeiki = dialog_grid_seiki.getGridParam("data").concat(result.d);
                    var currentDataSeiki = dialog_grid_seiki.getGridParam("data").concat(bindDataAry);
                    dialog_grid_seiki.setGridParam({ data: currentDataSeiki }).trigger('reloadGrid', [{ current: true }]);
                    // 取得完了メッセージの表示
                    dialogNotifyInfo.message(
                         App.str.format(pageLangText.searchResultCount.text, querySettingDialog.skip, querySettingDialog.count)
                    ).show();
                };
                /// <summary>端数データをバインドします。</summary>
                /// <param name="result">検索結果</param>
                var bindDataHasuDialog = function (result) {
                    querySettingDialog.skip = querySettingDialog.skip + result.d.length;
                    querySettingDialog.count = parseInt(result.__count);
                    // グリッドの表示件数を更新
                    //dialog_grid_hasu.setGridParam({ rowNum: dialog_grid_seiki.getGridParam('rowNum') });
                    // 端数を扱っているデータのみ選抜
                    var len = result.d.length;
                    for (var i = 0; i < result.d.length; i++) {
                        //var hasu = result.d[i].su_batch_keikaku_hasu;
                        var hasuData = result.d[i],
                            batch = hasuData.su_batch_keikaku_hasu,
                            ritsu = hasuData.ritsu_keikaku_hasu;

                        // 荷姿数が0の時
                        if (hasuData.su_nisugata_kowake_hasu == 0) {

                            // 荷姿数と荷姿重量をブランクにする
                            hasuData.su_nisugata_kowake_hasu = " ";
                            hasuData.wt_nisugata_hasu = " ";

                        }

                        // 小分数１が0の時
                        if (hasuData.su_kowake1_kowake_hasu == 0) {

                            // 小分数１と小分重量１をブランクにする
                            hasuData.su_kowake1_kowake_hasu = " ";
                            hasuData.wt_kowake1_hasu = " ";

                        }

                        // 小分数２が0の時
                        if (hasuData.su_kowake2_kowake_hasu == 0) {

                            // 小分数２と小分重量２をブランクにする
                            hasuData.su_kowake2_kowake_hasu = " ";
                            hasuData.wt_kowake2_hasu = " ";

                        }

                        //if (App.isUndefOrNull(hasu) || !hasu > 0) {
                        if (App.isUndefOrNull(batch) || App.isUndefOrNull(ritsu) || !(batch * ritsu > 0)) {
                            // json object からデータ削除
                            result.d.splice(i, 1);
                            // objectが一つ減ったので、カウントダウン
                            i--;
                        }
                    }

                    // データバインド端数
                    var currentDataHasu = dialog_grid_hasu.getGridParam("data").concat(result.d);
                    dialog_grid_hasu.setGridParam({ rowNum: currentDataHasu.length });
                    dialog_grid_hasu.setGridParam({ data: currentDataHasu }).trigger('reloadGrid', [{ current: true }]);
                    App.ui.block.show(".part-grid-down");
                };


                //重ねラベルの枚数をチェックします。
                var checkAllShori = function (isAll) {
                    var isValid = true;
                    if (isAll) {
                        //全ラベル印刷時の重ね枚数チェック
                        var seiki = 1,
                            hasu = 2,
                            printSeikiGrid = $("#dialog-list-seiki"),
                            printHasuGrid = $("#dialog-list-hasu");

                        // 全ラベルを印刷するので、正規/端数のループを回す
                        for (var all = seiki; all <= hasu; all++) {
                            //データ取り出し
                            var printGrid;
                            // 対象エリア選択
                            if (all == seiki) {
                                printGrid = printSeikiGrid;
                            }
                            else {
                                printGrid = printHasuGrid;
                            }
                            var kasaneStart = 0;
                            var kasanemarkPrev;
                            var kasanemarkNext;
                            var kasaneSeikiSuPrev;
                            var kasaneHasuSuPrev;
                            var kasaneSeikiSuNext;
                            var kasaneHasuSuNext;


                            var cnt = printGrid.getGridParam("records"); //個別ラベルは一行
                            for (var lcnt = 1; lcnt <= cnt; lcnt++) {
                                var lineData = printGrid.getRowData(lcnt);
                                kasanemarkPrev = lineData.cd_mark;
                                if (parseFloat(pageLangText.kasane1MarkKbn.text) <= parseFloat(kasanemarkPrev)
                                    && parseFloat(kasanemarkPrev) <= parseFloat(pageLangText.kasane9MarkKbn.text)) {
                                    kasaneStart = kasaneStart + 1;
                                    if (kasaneStart == 1) {
                                        kasanemarkNext = kasanemarkPrev;
                                        if (all == seiki) {
                                            kasaneSeikiSuPrev = lineData.su_kowake1_kowake_seiki;
                                            kasaneHasuSuPrev = lineData.su_kowake2_kowake_seiki;
                                        }
                                        else {
                                            kasaneSeikiSuPrev = lineData.su_kowake1_kowake_hasu;
                                            kasaneHasuSuPrev = lineData.su_kowake2_kowake_hasu;
                                        }
                                    }
                                    else {
                                        if (kasanemarkPrev == kasanemarkNext) {
                                            if (all == seiki) {
                                                kasaneSeikiSuNext = lineData.su_kowake1_kowake_seiki;
                                                kasaneHasuSuNext = lineData.su_kowake2_kowake_seiki;
                                            }
                                            else {
                                                kasaneSeikiSuNext = lineData.su_kowake1_kowake_hasu;
                                                kasaneHasuSuNext = lineData.su_kowake2_kowake_hasu;
                                            }
                                            if (kasaneSeikiSuPrev != kasaneSeikiSuNext) {
                                                isValid = false;
                                            }
                                            if (kasaneHasuSuPrev != kasaneHasuSuNext) {
                                                isValid = false;
                                            }
                                        }
                                        else {
                                            kasanemarkNext = kasanemarkPrev;
                                            if (all == seiki) {
                                                kasaneSeikiSuPrev = lineData.su_kowake1_kowake_seiki;
                                                kasaneHasuSuPrev = lineData.su_kowake2_kowake_seiki;
                                            }
                                            else {
                                                kasaneSeikiSuPrev = lineData.su_kowake1_kowake_hasu;
                                                kasaneHasuSuPrev = lineData.su_kowake2_kowake_hasu;
                                            }
                                        }
                                    }
                                }
                                else {
                                    kasaneStart = 0;
                                }
                            }
                        }
                    }
                    else {
                        // 個別ラベル印刷時の重ね枚数チェック[複数行選択対応]
                        var seiki = 1,
                            hasu = 2,
                            select = $("input:radio[name='seikihasuRadio']:checked").val(),
                            printSeikiGrid = $("#dialog-list-seiki"),
                            printHasuGrid = $("#dialog-list-hasu");

                        // 全ラベルを印刷するので、正規/端数のループを回す
                        //データ取り出し
                        var printGrid;
                        // 対象エリア選択
                        if (select == "seiki") {
                            printGrid = printSeikiGrid;
                        }
                        else {
                            printGrid = printHasuGrid;
                        }
                        var kasaneStart = 0;
                        var kasanemarkPrev;
                        var kasanemarkNext;
                        var kasaneSeikiSuPrev;
                        var kasaneHasuSuPrev;
                        var kasaneSeikiSuNext;
                        var kasaneHasuSuNext;


                        var cnt = printGrid.getGridParam("records"); //個別ラベルは一行
                        for (var lcnt = 1; lcnt <= cnt; lcnt++) {
                            var lineData = printGrid.getRowData(lcnt);
                            kasanemarkPrev = lineData.cd_mark;
                            if (parseFloat(pageLangText.kasane1MarkKbn.text) <= parseFloat(kasanemarkPrev)
                                && parseFloat(kasanemarkPrev) <= parseFloat(pageLangText.kasane9MarkKbn.text)) {
                                kasaneStart = kasaneStart + 1;
                                if (kasaneStart == 1) {
                                    kasanemarkNext = kasanemarkPrev;
                                    if (select == "seiki") {
                                        kasaneSeikiSuPrev = lineData.su_kowake1_kowake_seiki;
                                        kasaneHasuSuPrev = lineData.su_kowake2_kowake_seiki;
                                    }
                                    else {
                                        kasaneSeikiSuPrev = lineData.su_kowake1_kowake_hasu;
                                        kasaneHasuSuPrev = lineData.su_kowake2_kowake_hasu;
                                    }
                                }
                                else {
                                    if (kasanemarkPrev == kasanemarkNext) {
                                        if (select == "seiki") {
                                            kasaneSeikiSuNext = lineData.su_kowake1_kowake_seiki;
                                            kasaneHasuSuNext = lineData.su_kowake2_kowake_seiki;
                                        }
                                        else {
                                            kasaneSeikiSuNext = lineData.su_kowake1_kowake_hasu;
                                            kasaneHasuSuNext = lineData.su_kowake2_kowake_hasu;
                                        }
                                        if (kasaneSeikiSuPrev != kasaneSeikiSuNext) {
                                            isValid = false;
                                        }
                                        if (kasaneHasuSuPrev != kasaneHasuSuNext) {
                                            isValid = false;
                                        }
                                    }
                                    else {
                                        kasanemarkNext = kasanemarkPrev;
                                        if (select == "seiki") {
                                            kasaneSeikiSuPrev = lineData.su_kowake1_kowake_seiki;
                                            kasaneHasuSuPrev = lineData.su_kowake2_kowake_seiki;
                                        }
                                        else {
                                            kasaneSeikiSuPrev = lineData.su_kowake1_kowake_hasu;
                                            kasaneHasuSuPrev = lineData.su_kowake2_kowake_hasu;
                                        }
                                    }
                                }
                            }
                            else {
                                kasaneStart = 0;
                            }
                        }


                        ////個別ラベル印刷時の重ね枚数チェック
                        //var printSeikiGrid = $("#dialog-list-seiki"),
                        //printHasuGrid = $("#dialog-list-hasu"),
                        //select = $("input:radio[name='seikihasuRadio']:checked").val(),
                        //printGrid;
                        //// 対象エリア選択
                        //if (select == "seiki") {
                        //    printGrid = printSeikiGrid;
                        //}
                        //else {
                        //    printGrid = printHasuGrid;
                        //}
                        //var cnt = printGrid.getGridParam("records");
                        //// 重ねラベル考慮
                        //var focusedRow = printGrid.getGridParam("selrow");
                        //// 選択した行が重ねマークの場合は、その始まりの重ねを取得する
                        //var clickmark = printGrid.getCell(focusedRow, "cd_mark"),
                        //comparemark,
                        //clickLineNo = focusedRow;
                        //// 重ねラベルかどうか、一行目ではないか
                        //if (parseFloat(pageLangText.kasane1MarkKbn.text) <= parseFloat(clickmark)
                        //    && parseFloat(clickmark) <= parseFloat(pageLangText.kasane9MarkKbn.text)
                        //    && focusedRow > 1) {
                        //    for (var i = focusedRow; i > 0; i--) {
                        //        comparemark = printGrid.getCell(i, "cd_mark");
                        //        if (clickmark == comparemark) {
                        //            clickLineNo = i;
                        //            continue; // さらに一行前を確認
                        //        }
                        //        break;
                        //    }
                        //    // 重ねの始まりを取得
                        //    focusedRow = clickLineNo;
                        //}
                        //var kasaneStart = 0;
                        //var kasanemarkPrev;
                        //var kasanemarkNext;
                        //var kasaneSeikiSuPrev;
                        //var kasaneHasuSuPrev;
                        //var kasaneSeikiSuNext;
                        //var kasaneHasuSuNext;
                        //for (var lcnt = focusedRow; lcnt <= cnt; lcnt++) {
                        //    var lineData = printGrid.getRowData(lcnt);
                        //    kasanemarkPrev = lineData.cd_mark;
                        //    if (parseFloat(pageLangText.kasane1MarkKbn.text) <= parseFloat(kasanemarkPrev)
                        //            && parseFloat(kasanemarkPrev) <= parseFloat(pageLangText.kasane9MarkKbn.text)) {
                        //        kasaneStart = kasaneStart + 1;
                        //        if (kasaneStart == 1) {
                        //            kasanemarkNext = kasanemarkPrev;
                        //            if (select == "seiki") {
                        //                kasaneSeikiSuPrev = lineData.su_kowake1_kowake_seiki;
                        //                kasaneHasuSuPrev = lineData.su_kowake2_kowake_seiki;
                        //            }
                        //            else {
                        //                kasaneSeikiSuPrev = lineData.su_kowake1_kowake_hasu;
                        //                kasaneHasuSuPrev = lineData.su_kowake2_kowake_hasu;
                        //            }
                        //        }
                        //        else {
                        //            if (kasanemarkPrev == kasanemarkNext) {
                        //                if (select == "seiki") {
                        //                    kasaneSeikiSuNext = lineData.su_kowake1_kowake_seiki;
                        //                    kasaneHasuSuNext = lineData.su_kowake2_kowake_seiki;
                        //                }
                        //                else {
                        //                    kasaneSeikiSuNext = lineData.su_kowake1_kowake_hasu;
                        //                    kasaneHasuSuNext = lineData.su_kowake2_kowake_hasu;
                        //                }
                        //                if (kasaneSeikiSuPrev != kasaneSeikiSuNext) {
                        //                    isValid = false;
                        //                }
                        //                if (kasaneHasuSuPrev != kasaneHasuSuNext) {
                        //                    isValid = false;
                        //                }
                        //            }
                        //            else {
                        //                break;
                        //                /*
                        //                kasanemarkNext = kasanemarkPrev;
                        //                if (select == "seiki") {
                        //                kasaneSeikiSuPrev = lineData.su_kowake1_kowake_seiki;
                        //                kasaneHasuSuPrev = lineData.su_kowake2_kowake_seiki;
                        //                } else {
                        //                kasaneSeikiSuPrev = lineData.su_kowake1_kowake_hasu;
                        //                kasaneHasuSuPrev = lineData.su_kowake2_kowake_hasu;
                        //                }
                        //                */
                        //            }
                        //        }
                        //    }
                        //    else {
                        //        kasaneStart = 0;
                        //    }
                        //}
                    }
                    return isValid;
                };

                // <summary>個別ラベル出力 HTML作成エリア</summary>
                $.qrCodePrintArea = function (isAll) {
                    //チェック処理
                    if (!checkAllShori(isAll)) {
                        dialogNotifyAlert.message(pageLangText.unMatchKasane.text).show();
                        return;
                    }

                    var iframe = document.createElement('IFRAME'),
                        doc = null,
                        wk;
                    $(iframe).attr('style', 'position:absolute;width:0px;height:0px;left:-500px;top:-500px;');

                    document.body.appendChild(iframe);
                    doc = iframe.contentWindow.document;
                    var links = window.document.getElementsByTagName('link');
                    for (var i = 0; i < links.length; i++) {
                        if (links[i].rel.toLowerCase() == 'stylesheet') {
                            var html = "";
                            html += '<link type="text/css" rel="stylesheet" ';
                            html += 'href="' + links[i].href + '">';
                            html += '</link>'
                            html;
                            doc.write(html);
                        }
                    }

                    // 印刷
                    if (isAll) {
                        wk = printQR(); //データを元にラベルのHTMLを作成
                    }
                    else {
                        wk = printKobetsuQR();
                    }

                    doc.write(wk);  //HTMLを書き込み
                    // Chromeの場合、QRコードが表示されないことがあるため、
                    // QRコードの読み込み完了まで印刷ダイアログ表示を待機する
                    var delay = 1000; // ハンドラの実行トライ間隔(ms)
                    App.sync.loadQRHandler(function () {
                        toPrintOut(doc, iframe);
                    }, delay, doc);


                    // サマリ登録
                    if (isAll) {
                        updateShikakariKeikakuSum(shikakariLot);
                    }
                };

                // 仕掛サマリを更新
                var updateShikakariKeikakuSum = function (lot) {
                    var saveUrl = "../api/LabelInsatsu";
                    var data = {
                        "no_lot_shikakari": lot
                    };
                    var changeSetLabel = new App.ui.page.changeSet();
                    changeSetLabel.addCreated("0", data)

                    App.ajax.webpost(
                        saveUrl, changeSetLabel.getChangeSet()
                    ).done(function (result) {
                    }).fail(function (result) {
                        // データ変更エラーハンドリングを行います。
                        App.ui.page.notifyAlert.message(result.message).show();
                    }).always(function () {
                        // ローディングの終了
                    });
                };

                // ラベル出力ウィンドウを呼び出す
                var toPrintOut = function (doc, iframe) {
                    doc.close();
                    // セキュリティ更新プログラムによってiframeの印刷ができなくなったので対応（2017/06/16 kaneko.m）
                    if (iframe.contentWindow.document.queryCommandSupported('print')) {
                        iframe.contentWindow.document.execCommand('print', false, null);
                    } else {
                        iframe.contentWindow.focus();
                        iframe.contentWindow.print();
                    }
                    //iframe.contentWindow.PrintX(); IE Only
                    document.body.removeChild(iframe);
                };

                // 日付の多言語対応
                var newDateFormat = pageLangText.dateNewFormatUS.text;
                if (App.ui.page.langCountry !== 'en-US') {
                    newDateFormat = pageLangText.dateNewFormat.text;
                };

                function formatNumber(cellvalue, options, rowObject) {
                    //var val = $.fn.fmatter.number(cellvalue, options);
                    //var val_result = parseFloat(val);
                    //if (App.ui.page.user.kbn_tani === pageLangText.kbn_tani_LB_GAL.text) {
                    //    if (rowObject.cd_mark === pageLangText.cd_mark.text) {
                    //        val_result = val_result.toFixed(3);
                    //    }
                    //    else {
                    //        val_result = val_result.toFixed(6);
                    //    }
                    //}
                    //else {
                    //    if (App.ui.page.user.kbn_tani === pageLangText.kbn_tani_Kg_L.text) {
                    //        if (rowObject.cd_mark === pageLangText.cd_mark.text) {
                    //            val_result = val_result.toFixed(3);
                    //        }
                    //        else {
                    //            val_result = val_result.toFixed(6);
                    //        }
                    //    }
                    //}
                    //return val_result;
                    var iniPos = options.colModel.formatoptions.decimalPlaces,              // 初期値を保持
                        tmpPos = iniPos,
                        val;

                    // 均等小分計算の場合
                    if (kbnKowakefutai === pageLangText.kbnKowakeFutaiKinto.number) {
                        // 工場マスタから取得した小数桁数を設定
                        tmpPos = ketaShosuten;
                    }
                    else {
                        tmpPos = rowObject.cd_mark === pageLangText.cd_mark.text ? 3 : iniPos;  // 小数部の桁数を決定
                    }
                    options.colModel.formatoptions.decimalPlaces = tmpPos;
                    val = $.fn.fmatter.number(cellvalue, options);                          // フォーマット
                    options.colModel.formatoptions.decimalPlaces = iniPos;                  // 初期化処理
                    return val;
                }

                // ダイアログ内のグリッド定義
                dialog_grid_seiki.jqGrid({
                    // todo：画面の仕様に応じて以下の列名の定義を変更してください。
                    colNames: [
                        pageLangText.cd_hinmei_dlg.text
                        , pageLangText.no_kotei_dlg.text
                        , pageLangText.nm_mark_label_dlg.text
                        , pageLangText.nm_genryo_dlg.text
                        , pageLangText.wt_kihon_dlg.text
                        , pageLangText.wt_haigo_dlg.text
                        , pageLangText.nm_tani_shiyo_dlg.text
                        , pageLangText.wt_nisugata_dlg.text, pageLangText.su_nisugata_kowake_dlg.text
                        , pageLangText.wt_kowake1_dlg.text, pageLangText.su_kowake1_kowake_dlg.text
                        , pageLangText.nm_futai1_dlg.text
                        , pageLangText.wt_kowake2_dlg.text, pageLangText.su_kowake2_kowake_dlg.text
                        , pageLangText.nm_futai2_dlg.text, pageLangText.blank.text, pageLangText.blank.text
                        , pageLangText.blank.text, pageLangText.blank.text, pageLangText.blank.text, pageLangText.blank.text
                        , pageLangText.blank.text, pageLangText.blank.text, pageLangText.blank.text, pageLangText.blank.text
                        , pageLangText.blank.text, pageLangText.blank.text, pageLangText.blank.text, pageLangText.blank.text
                        , pageLangText.blank.text, pageLangText.blank.text, pageLangText.blank.text, pageLangText.blank.text
                        , pageLangText.blank.text, pageLangText.blank.text, pageLangText.blank.text, pageLangText.blank.text
                        , pageLangText.blank.text
                    ],
                    // todo：ここまで
                    // todo：画面の仕様に応じて以下の列モデルの定義を変更してください。
                    colModel: [
                        { name: 'cd_hinmei', width: 80, align: "left", sortable: false },
                        { name: 'no_kotei', width: pageLangText.no_kotei_width.number, align: "left", sortable: false },
                        { name: 'nm_mark', width: 80, align: "left", sortable: false },
                        { name: 'nm_hinmei', width: 160, align: "left", sortable: false },
                        {
                            name: 'wt_kihon', hidden: true, hidedlg: true, align: "right", sortable: false,
                            formatter: 'number',
                            formatoptions: {
                                decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 6, defaultValue: "0"
                            }
                        },
                        {
                            name: 'wt_haigo', width: pageLangText.wt_haigo_width.number, align: "right", sortable: false,
                            formatter: formatNumber,
                            formatoptions: {
                                decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 6, defaultValue: "0"
                            }
                        },
                        { name: 'nm_tani', width: 90, align: "left", sortable: false },
                        {
                            name: 'wt_nisugata', width: pageLangText.wt_nisugata_width.number, align: "right", sortable: false,
                            formatter: formatNumber,
                            formatoptions: {
                                decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 6, defaultValue: " "
                            }
                        },
                        { name: 'su_nisugata_kowake_seiki', width: pageLangText.su_nisugata_kowake_seiki_width.number, align: "right", sortable: false },
                        {
                            name: 'wt_kowake1_seiki', width: pageLangText.wt_kowake1_width.number, align: "right", sortable: false,
                            formatter: formatNumber,
                            formatoptions: {
                                decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 6, defaultValue: " "
                            }
                        },
                        { name: 'su_kowake1_kowake_seiki', width: pageLangText.su_kowake1_kowake_width.number, align: "right", sortable: false },
                        { name: 'nm_futai1_seiki', width: 100, align: "left" },
                        {
                            name: 'wt_kowake2_seiki', width: pageLangText.wt_kowake2_width.number, align: "right", sortable: false,
                            formatter: formatNumber,
                            formatoptions: {
                                decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 6, defaultValue: " "
                            }
                        },
                        { name: 'su_kowake2_kowake_seiki', width: pageLangText.su_kowake2_kowake_width.number, align: "right", sortable: false },
                        { name: 'nm_futai2_seiki', width: 100, align: "left", sortable: false },
                        { name: 'kbn_hin', hidden: true, hidedlg: true },
                        { name: 'cd_line', hidden: true, hidedlg: true },
                        { name: 'cd_shokuba', hidden: true, hidedlg: true },
                        { name: 'cd_mark', hidden: true, hidedlg: true },
                        {
                            name: 'dt_seizo', hidden: true, hidedlg: true,
                            formatter: "date",
                            formatoptions: {
                                srcformat: newDateFormat
                                , newformat: newDateFormat
                            }
                        },
                        { name: 'suNisugata', hidden: true, hidedlg: true },
                        { name: 'suKowake1', hidden: true, hidedlg: true },
                        { name: 'suKowake2', hidden: true, hidedlg: true },
                        { name: 'cd_haigo', hidden: true, hidedlg: true },
                        { name: 'soJyuryo', hidden: true, hidedlg: true },
                        { name: 'no_han', hidden: true, hidedlg: true },
                        { name: 'cd_futai1_seiki', hidden: true, hidedlg: true },
                        { name: 'cd_futai2_seiki', hidden: true, hidedlg: true },
                        { name: 'no_lot_shikakari', hidden: true, hidedlg: true },
                        { name: 'su_kowake2_kowake_seiki', hidden: true, hidedlg: true },
                        { name: 'no_tonyu', hidden: true, hidedlg: true },
                        { name: 'su_batch_keikaku_seiki', hidden: true, hidedlg: true },
                        { name: 'su_batch_keikaku_hasu', hidden: true, hidedlg: true },
                        { name: 'kbnAllergy', hidden: true, hidedlg: true },
                        { name: 'nm_Allergy', hidden: true, hidedlg: true },
                        { name: 'kbnOther', hidden: true, hidedlg: true },
                        { name: 'nm_Other', hidden: true, hidedlg: true },
                        { name: 'nm_hinmei_ryaku', hidden: true, hidedlg: true }
                    ],
                    // todo：ここまで
                    datatype: "local",
                    shrinktofit: false,
                    multiselect: multiselect,
                    rownumbers: true,
                    hoverrows: false,
                    height: 130,
                    loadComplete: function () {
                        dialog_grid_seiki.jqGrid('setGridWidth', $("#grid-seiki").width(), false);
                    },
                    ondblClickRow: function (rowid) {
                        var returnCode = returnSelectedDialog();
                        if (returnCode != "noSelect") {
                            context.close(returnCode);
                        }
                    }
                });


                // ダイアログ内のグリッド定義
                dialog_grid_hasu.jqGrid({
                    // todo：画面の仕様に応じて以下の列名の定義を変更してください。
                    colNames: [
                        pageLangText.cd_hinmei_dlg.text
                        , pageLangText.no_kotei_dlg.text
                        , pageLangText.nm_mark_label_dlg.text
                        , pageLangText.nm_genryo_dlg.text
                        , pageLangText.wt_kihon_dlg.text
                        , pageLangText.wt_haigo_dlg.text
                        , pageLangText.nm_tani_shiyo_dlg.text
                        , pageLangText.wt_nisugata_dlg.text, pageLangText.su_nisugata_kowake_dlg.text
                        , pageLangText.wt_kowake1_dlg.text, pageLangText.su_kowake1_kowake_dlg.text
                        , pageLangText.nm_futai1_dlg.text
                        , pageLangText.wt_kowake2_dlg.text, pageLangText.su_kowake2_kowake_dlg.text
                        , pageLangText.nm_futai2_dlg.text, pageLangText.blank.text
                        , pageLangText.blank.text, pageLangText.blank.text, pageLangText.blank.text, pageLangText.blank.text
                        , pageLangText.blank.text, pageLangText.blank.text, pageLangText.blank.text, pageLangText.blank.text
                        , pageLangText.blank.text, pageLangText.blank.text, pageLangText.blank.text, pageLangText.blank.text
                        , pageLangText.blank.text, pageLangText.blank.text, pageLangText.blank.text, pageLangText.blank.text
                        , pageLangText.blank.text, pageLangText.blank.text, pageLangText.blank.text, pageLangText.blank.text
                        , pageLangText.blank.text
                    ],
                    // todo：ここまで
                    // todo：画面の仕様に応じて以下の列モデルの定義を変更してください。
                    colModel: [
                        { name: 'cd_hinmei', width: 80, align: "left", sortable: false },
                        { name: 'no_kotei', width: pageLangText.no_kotei_width.number, align: "left", sortable: false },
                        { name: 'nm_mark', width: 80, align: "left", sortable: false },
                        { name: 'nm_hinmei', width: 160, align: "left", sortable: false },
                        {
                            name: 'wt_kihon', hidden: true, hidedlg: true, align: "right", sortable: false,
                            formatter: 'number',
                            formatoptions: {
                                decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 6, defaultValue: "0"
                            }
                        },
                        {
                            name: 'wt_haigo_hasu', width: pageLangText.wt_haigo_width.number, align: "right", sortable: false,
                            formatter: formatNumber,
                            formatoptions: {
                                decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 6, defaultValue: "0"
                            }
                        },
                    	//{ name: 'nm_tani', width: 100, align: "left", sortable: false },
                        { name: 'nm_tani_hasu', width: 90, align: "left", sortable: false },
                        //{ name: 'wt_nisugata', width: pageLangText.wt_nisugata_width.number, align: "right", sortable: false,
                        {
                            name: 'wt_nisugata_hasu', width: pageLangText.wt_nisugata_width.number, align: "right", sortable: false,
                            formatter: formatNumber,
                            formatoptions: {
                                decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 6, defaultValue: " "
                            }
                        },
                        { name: 'su_nisugata_kowake_hasu', width: pageLangText.su_nisugata_kowake_hasu_width.number, align: "right" },
                        {
                            name: 'wt_kowake1_hasu', width: pageLangText.wt_kowake1_width.number, align: "right",
                            formatter: formatNumber,
                            formatoptions: {
                                decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 6, defaultValue: " "
                            }
                        },
                        { name: 'su_kowake1_kowake_hasu', width: pageLangText.su_kowake1_kowake_width.number, align: "right", sortable: false },
                        { name: 'nm_futai1_hasu', width: 100, align: "left" },
                        {
                            name: 'wt_kowake2_hasu', width: pageLangText.wt_kowake2_width.number, align: "right", sortable: false,
                            formatter: formatNumber,
                            formatoptions: {
                                decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 6, defaultValue: " "
                            }
                        },
                        { name: 'su_kowake2_kowake_hasu', width: pageLangText.su_kowake2_kowake_width.number, align: "right", sortable: false },
                        { name: 'nm_futai2_hasu', width: 100, align: "left", sortable: false },
                        { name: 'kbn_hin', hidden: true, hidedlg: true },
                        { name: 'cd_line', hidden: true, hidedlg: true },
                        { name: 'cd_shokuba', hidden: true, hidedlg: true },
                        { name: 'cd_mark', hidden: true, hidedlg: true },
                        {
                            name: 'dt_seizo', hidden: true, hidedlg: true,
                            formatter: "date",
                            formatoptions: {
                                srcformat: newDateFormat
                                , newformat: newDateFormat
                            }
                        },
                        { name: 'suNisugata', hidden: true, hidedlg: true },
                        { name: 'suKowake1', hidden: true, hidedlg: true },
                        { name: 'suKowake2', hidden: true, hidedlg: true },
                        { name: 'cd_haigo', hidden: true, hidedlg: true },
                        { name: 'soJyuryo', hidden: true, hidedlg: true },
                        { name: 'no_han', hidden: true, hidedlg: true },
                        { name: 'cd_futai1_hasu', hidden: true, hidedlg: true },
                        { name: 'cd_futai2_hasu', hidden: true, hidedlg: true },
                        { name: 'no_lot_shikakari', hidden: true, hidedlg: true },
                        { name: 'su_kowake2_kowake_hasu', hidden: true, hidedlg: true },
                        { name: 'no_tonyu', hidden: true, hidedlg: true },
                        { name: 'su_batch_keikaku_hasu', hidden: true, hidedlg: true },
                        { name: 'kbnAllergy', hidden: true, hidedlg: true },
                        { name: 'nm_Allergy', hidden: true, hidedlg: true },
                        { name: 'kbnOther', hidden: true, hidedlg: true },
                        { name: 'nm_Other', hidden: true, hidedlg: true },
                        { name: 'nm_hinmei_ryaku', hidden: true, hidedlg: true }
                    ],
                    // todo：ここまで
                    datatype: "local",
                    shrinktofit: false,
                    multiselect: multiselect,
                    rownumbers: true,
                    hoverrows: false,
                    height: 130,
                    loadComplete: function () {
                        dialog_grid_hasu.jqGrid('setGridWidth', $("#grid-hasu").width(), false);
                    },
                    ondblClickRow: function (rowid) {
                        var returnCode = returnSelectedDialog();
                        if (returnCode != "noSelect") {
                            context.close(returnCode);
                        }
                    }
                });
                /*
                /// <summary>正規グリッドの計画バッチ端数を0にします</summary>
                function setZero() {
                return pageLangText.falseFlg.text;
                }
                */
                /// <summary>選択したコードを書き出します</summary>
                var returnSelectedDialog = function () {
                    var selArray;
                    if (dialog_grid_seiki.getGridParam("multiselect")) {
                        selArray = dialog_grid_seiki.jqGrid("getGridParam", "selarrrow");
                        if (!App.isArray(selArray) || selArray.length == 0) {
                            dialogNotifyInfo.message(pageLangText.noSelect.text).show();
                            return "noSelect";
                        }
                    }
                    else {
                        selArray = [];
                        selArray[0] = dialog_grid_seiki.jqGrid("getGridParam", "selrow");
                        if (selArray[0] == null || selArray.length == 0) {
                            dialogNotifyInfo.message(pageLangText.noSelect.text).show();
                            return "noSelect";
                        }
                    }
                    var row,
                        selCode = [],
                        selName = [];
                    // TODO：画面の仕様に応じて返却文字列を指定してください。
                    for (var i = 0; i < selArray.length; i++) {
                        row = dialog_grid_seiki.jqGrid("getRowData", selArray[i]);
                        selCode.push(row.cd_line);
                        selName.push(row.nm_line);
                    }
                    // TODO：ここまで
                    return [selCode.join(", "), selName.join(", ")];
                };

                // バリデーション設定
                var labelValidation = Aw.validation({
                    items: validationSetting,
                    handlers: {
                        success: function (results) {
                            var i = 0, l = results.length;
                            for (; i < l; i++) {
                                dialogNotifyAlert.remove(results[i].element);
                            }
                        },
                        error: function (results) {
                            var i = 0, l = results.length;
                            for (; i < l; i++) {
                                dialogNotifyAlert.message(results[i].message, results[i].element).show();
                            }
                        }
                    }
                });
                $(".dialog-content-label").validation(labelValidation);

                // <summary>ダイアログの閉じるボタンクリック時のイベント処理を行います。</summary>
                elem.find(".dlg-close-button").on("click", function () {

                    // 正規端数を表示する
                    $('input[name="gridViewRadio"]').val(['default']); //.prop("checked", true);
                    resizeContentsDialog(); //リサイズ
                    dialog_grid_seiki.jqGrid('setGridState', 'visible'); //grid表示
                    dialog_grid_hasu.jqGrid('setGridState', 'visible'); //grid表示
                    $("#seiki-button").show('nomal'); //ボタン表示
                    $("#hasu-button").show('nomal'); //ボタン表示
                    $("#radio-seiki").prop("checked", true); //チェックボックスを正規にする
                    // <summary>ダイアログの閉じるボタンクリック時のイベント処理を行います。</summary>
                    $('#hasu-button').prop("disabled", false);
                    $('#seiki-button').prop("disabled", false);
                    $("#radio-seiki").click();
                    // ボタン表示を再設定
                    $("#grid-view").buttonset();
                    //$("#label-hakko input").button("enable");

                    // 古いデータが残らないよう、閉じるタイミングでもグリッドの初期化を行う
                    clearStateDialog();
                    $("#selectHaigoName").text("");
                    $("#selectJyuryoSoShikomi").text("");
                    shikakariLot = "";  // ロット番号(グローバル変数)は検索条件なので、処理の前後で古い情報で検索しないようクリア。

                    context.close("canceled");
                });

                // <summary>ダイアログの選択ボタンクリック時のイベント処理を行います。</summary>
                elem.find(".dlg-select-button").on("click", function () {
                    var returnCode = returnSelectedDialog();
                    if (returnCode != "noSelect") {
                        context.close(returnCode);
                    }
                });

                // <summary>全ラベル出力選択ボタンクリック時のイベント処理を行います。</summary>
                elem.find(".dlg-zenlabel-button").on("click", function () {
                    dialogNotifyInfo.clear();
                    dialogNotifyAlert.clear();
                    setLabelVersion();
                    setHaigoGokei();
                    $.qrCodePrintArea(true); // 全ラベル出力
                });

                // <summary>個別ラベル出力選択ボタンクリック時のイベント処理を行います。</summary>
                elem.find(".dlg-kobetsulabel-button").on("click", function () {
                    dialogNotifyInfo.clear();
                    dialogNotifyAlert.clear();
                    setLabelVersion();
                    var selectedSeikiRowId = $("#dialog-list-seiki").getGridParam('selrow'),
                        selectedHasuRowId = $("#dialog-list-hasu").getGridParam('selrow');

                    // 行選択チェック
                    var select = $("input:radio[name='seikihasuRadio']:checked").val();

                    if (select == "seiki" && App.isUndefOrNull(selectedSeikiRowId)
                        || select == "hasu" && App.isUndefOrNull(selectedHasuRowId)) {
                        dialogNotifyAlert.message(pageLangText.noRowSelect.text).show();
                        return;
                    }

                    // validation
                    var detailContent = $(".dialog-content-label"),
                        result;

                    result = detailContent.validation().validate();
                    if (result.errors.length) {
                        return;
                    }

                    if (select == "seiki") {
                        var suKowake1 = dialog_grid_seiki.jqGrid('getCell', selectedSeikiRowId, "su_kowake1_kowake_seiki");
                        var suKowake2 = dialog_grid_seiki.jqGrid('getCell', selectedSeikiRowId, "su_kowake2_kowake_seiki");
                        if (suKowake1 == "0" && suKowake2 == "0") {
                            dialogNotifyAlert.message(pageLangText.noKowakeLabel.text).show();
                            return;
                        }
                    }
                    else if (select == "hasu") {
                        var suKowake1 = dialog_grid_hasu.jqGrid('getCell', selectedHasuRowId, "su_kowake1_kowake_hasu");
                        var suKowake2 = dialog_grid_hasu.jqGrid('getCell', selectedHasuRowId, "su_kowake2_kowake_hasu");
                        if (suKowake1 == "0" && suKowake2 == "0") {
                            dialogNotifyAlert.message(pageLangText.noKowakeLabel.text).show();
                            return;
                        }
                    }

                    dialogNotifyAlert.clear();
                    setHaigoGokei();
                    $.qrCodePrintArea(false); // 個別出力
                });

                /// <summary>配合合計重量を設定する。</summary>
                var setHaigoGokei = function () {
                    App.ajax.webgetSync("../Services/FoodProcsService.svc/ma_haigo_mei?&$filter="
                                         + "cd_haigo eq '" + haigoCode + "' and "
                                         + "dt_from le DateTime'" + dt_seizo
                                         + "'&$orderby=dt_from desc"
                                         + "&$top=1"
                    ).done(function (result) {
                        wt_haigo_gokei = result.d[0].wt_haigo_gokei;
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
                    });
                };

                /// <summary>コードの不足分をスペースで埋めます。</summary>
                /// <param name="cd">コード</param>
                /// <param name="val">埋める値</param>
                var fillSpace = function (cd, val) {
                    var charCd = String(cd);
                    val = parseInt(val);
                    var space = " ";
                    for (; charCd.length < val; charCd = charCd + space);
                    return charCd;
                };

                /// <summary>値の不足分を0で埋めます。</summary>
                /// <param name="value">値</param>
                /// <param name="val">埋める値</param>
                var fillZeroJuryo = function (value, val) {
                    var charCd = String(value);
                    val = parseInt(val);
                    var zero = "0";
                    for (; charCd.length < val; charCd = charCd + zero);
                    return charCd;
                };

                /// <summary>マークがスパイスのときの配合重量を取得します。</summary>
                /// <param name="juryo">配合重量</param>
                var getJuryuMarkSpice = function (juryo) {
                    // マークが「スパイス」の場合、1000倍する
                    var wtHaigo = parseFloat(juryo),
                        resultWtHaigo = "0.000";
                    if (wtHaigo > 0) {
                        resultWtHaigo = String((wtHaigo * 1000).toFixed(3));
                        var splitWt = resultWtHaigo.split('.');
                        splitWt[1] = fillZeroJuryo(splitWt[1], 3);  // 小数点以下は0で尻埋め
                        //resultWtHaigo = splitWt[0] + "." + splitWt[1];
                        resultWtHaigo = splitWt[0].slice(-3) + "." + splitWt[1];
                    }
                    return resultWtHaigo;
                };

                // 日付文字列からyyyymmdd形式の日付コードを生成する
                /// <param name="date">日付文字列</param>
                /// <param name="kowakeLabelKeta">小分けラベル桁情報</param>
                var createDateCode = function (date, kowakeLabelKeta) {
                    var dateCode;           // 日付コード 

                    // 日付をスラッシュで分割                 
                    date = date.split('/');
                    if (App.ui.page.lang == 'ja' || App.ui.page.lang == 'zh') {
                        dateCode = fillSpace(date[0], kowakeLabelKeta[7].su_byte); //年
                        dateCode += fillSpace(date[1], kowakeLabelKeta[8].su_byte); //月
                        dateCode += fillSpace(date[2], kowakeLabelKeta[9].su_byte); //日
                    }
                    else {
                        if (App.ui.page.langCountry != 'en-US') {
                            dateCode = fillSpace(date[2], kowakeLabelKeta[7].su_byte); //年
                            dateCode += fillSpace(date[1], kowakeLabelKeta[8].su_byte); //月
                            dateCode += fillSpace(date[0], kowakeLabelKeta[9].su_byte); //日
                        }
                        else {
                            dateCode = fillSpace(date[2], kowakeLabelKeta[7].su_byte); //年
                            dateCode += fillSpace(date[0], kowakeLabelKeta[8].su_byte); //月
                            dateCode += fillSpace(date[1], kowakeLabelKeta[9].su_byte); //日
                        }
                    }
                    return dateCode;
                };

                /// <summary> 倍率を4桁の数値に変換します。　</summary>
                var createRitsuCode = function (ritsu, kowakeLabelKeta) {
                    var ritsuCode;

                    ritsuCode = "" + (parseFloat(ritsu, 10) * 100);
                    var len = 4 - ritsuCode.length;
                    for (var i = 0; i < len; i++) {
                        ritsuCode = "0" + ritsuCode;
                    }
                    ritsuCode = ritsuCode.substr(0, 4);

                    return fillSpace(ritsuCode, kowakeLabelKeta);
                };

                // 小分けラベル内のコードを生成する
                /// <param name="dt">grid一行分のデータ</param>
                var generateKowakeCode = function (dt) {
                    //var code,
                    //wt = dt.set_wt_label_now.split('.'); // 重量をコロンで分割 ;

                    // 重量を環境ごとに変更
                    var wt_label_now = kowakeLabelFormatNumber(dt.set_wt_label_now);
                    //var wt_label_now = dt.set_wt_label_now;
                    //var shosuKeta = pageLangText.ketaShosuten2.number;
                    //var zero = pageLangText.systemValueZero.text;

                    // Q&Bの場合
                    if (ketaShosuten == pageLangText.ketaShosuten2.number) {

                        // 重量の小数第3位に0を追加する
                        wt_label_now += pageLangText.systemValueZero.text;
                    }
                    wt = wt_label_now.split('.'); // 重量をコロンで分割 ;
                    code = fillSpace(dt.cd_haigo, kowakeLabelKeta[0].su_byte);                  // 配合コード
                    code += fillSpace(dt.kbn_hin, kowakeLabelKeta[1].su_byte);                  // 品区分
                    code += fillSpace('', kowakeLabelKeta[2].su_byte);                          // チームコード（空白）
                    code += fillSpace(dt.cd_line, kowakeLabelKeta[3].su_byte);                  // ラインコード
                    code += fillSpace(dt.no_kotei, kowakeLabelKeta[4].su_byte);                 // 工程順
                    code += fillSpace(dt.no_tonyu, kowakeLabelKeta[5].su_byte);                 // 投入順
                    code += fillSpace(dt.cd_mark, kowakeLabelKeta[6].su_byte);                  // マークコード
                    code += createDateCode(dt.dt_seizo, kowakeLabelKeta);                       // 製造日(yyyyMMdd)
                    code += createRitsuCode(dt.set_ritsu_bai, kowakeLabelKeta[10].su_byte);     // 倍率
                    code += fillSpace(dt.set_su_label_now, kowakeLabelKeta[11].su_byte);        // 個数
                    code += fillSpace(dt.set_su_batch_now, kowakeLabelKeta[12].su_byte);        // 回数
                    code += fillSpace(dt.cd_hinmei, kowakeLabelKeta[13].su_byte);               // 原料コード
                    code += fillSpace(wt[0].slice(-3), kowakeLabelKeta[14].su_byte);                      // 重量（ｋ）
                    //code += fillSpace(wt[1], kowakeLabelKeta[15].su_byte);                      // 重量（ｇ）
                    code += wt[1].substr(0, 3);                                                  // 重量（ｇ）
                    //code += wt[1];                                                              // 重量（ｇ）
                    code += fillSpace(dt.no_han, kowakeLabelKeta[16].su_byte);                  // 版
                    code += fillSpace(dt.set_cd_futai_now, kowakeLabelKeta[17].su_byte);        // 風袋コード
                    code += fillSpace(dt.no_lot_shikakari, kowakeLabelKeta[18].su_byte);        // ロットNo
                    code += fillSpace(dt.su_batch_keikaku_hasu, kowakeLabelKeta[19].su_byte);   // 端数フラグ
                    code += fillSpace(kbnSeikiHasu, kowakeLabelKeta[20].su_byte);   // 正規、端数区分

                    return code;
                };

                // byte数チェック
                var countLength = function (str) {
                    var r = 0;
                    for (var i = 0; i < str.length; i++) {
                        var c = str.charCodeAt(i);
                        if ((c >= 0x0 && c < 0x81) || (c == 0xf8f0) || (c >= 0xff61 && c < 0xffa0) || (c >= 0xf8f1 && c < 0xf8f4)) {
                            r += 1;
                        }
                        else {
                            r += 2;
                        }
                    }
                    return r;
                };

                //アレルゲン、食品添加物の内容生成
                var nameSplit = function (name) {
                    var strName = "";
                    var strLen = 0;
                    for (a = 0; a < name.length; a++) {
                        strLen = strLen + countLength(name[a]) + 1; //1はカンマのbyte数
                        if (strLen < 52) {
                            if (a == 0) {   //1回目はカンマを付けないようにします
                                strName = strName + name[a];
                            }
                            else {
                                strName = strName + "," + name[a];
                            }
                        }
                        else {
                            return strName;
                        }
                    }
                    return strName;
                };

                /// <summary>ラベルフォーマット区分の取得</summary>
                var setLabelVersion = function () {
                    App.deferred.parallel({
                        labelVersion: App.ajax.webgetSync("../Services/FoodProcsService.svc/cn_kino_sentaku()?$filter=kbn_kino eq " + pageLangText.kinoLabelKbn.number)
                    }).done(function (result) {
                        labelVersion = result.successes.labelVersion.d;
                        if (labelVersion.length > 0) {
                            version = labelVersion[0].kbn_kino_naiyo;
                        }
                        else {
                            version = "";
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

                // 小分けラベル作成処理
                /// <param name="i">index</param>
                /// <param name="text">ラベル内データ</param>
                /// <param name="dt">gridのデータ</param>
                /// <param name="multiLanguageName">多言語対応項目</param>
                var createKowakePrintArea = function (i, dt, name, isLast) {
                    if (version == pageLangText.kaigaiLabelFormatKbn.number) {
                        //// ■ Version2：海外対応(tableバージョン) ■
                        var wk = "";

                        if (isLast) {
                            //wk += wk + "<div style='page-break-after:auto; font-family:ＭＳ ゴシック;'>"; //改行　print.cssで定義
                        }
                        else {
                            //wk += wk + "<div style='page-break-after:always; font-family:ＭＳ ゴシック;'>"; //改行　print.cssで定義
                        }
                        var code;
                        // QRCodeの作成
                        var data = "./QRCodeGererateHandler.ashx";
                        data += "?code=";
                        code = generateKowakeCode(dt);
                        data += code;
                        data += "&lang=";
                        data += App.ui.page.lang;
                        if (dt.nm_Allergy.length != 0) {
                            var nameAllergy = dt.nm_Allergy.split(",");
                            allergyName = nameSplit(nameAllergy);
                            allergyKbn = dt.kbnAllergy;
                        }
                        else {
                            allergyKbn = "";
                            allergyName = "";
                        }
                        if (dt.nm_Other.length != 0) {
                            var nameOther = dt.nm_Other.split(",");
                            otherName = nameSplit(nameOther);
                            otherKbn = dt.kbnOther;
                        }
                        else {
                            otherKbn = "";
                            otherName = "";
                        }
                        wk += "<table style='font-size:11pt;' height='350px'; width='350';>";
                        wk += "<tr><td  colspan='4' align='center' height='10px' >" + pageLangText.txt_titleKowake_label.text + "</td></tr>"; 
                        // 原料コード
                        //wk += "<tr valign='top'><td width='75px'>" + pageLangText.txt_code_label2.text + "</td>";
                        wk += "<tr valign='top'><td width='90px' style=' padding-left: 12px;'>" + pageLangText.txt_code_label2.text + "</td>";
                        wk += "<td>:</td>";
                        wk += "<td style='padding-left: 5px;'>";
                        wk += dt.cd_hinmei;
                        wk += "</td>";
                        wk += "<td></td>";
                        wk += "</tr>";
                        // 原料名
                        //wk += "<tr valign='top'><td width='75px'>" + pageLangText.txt_genryo_label2.text + "</td>";
                        wk += "<tr valign='top'><td width='90px' style=' padding-left: 12px;'>" + pageLangText.txt_genryo_label2.text + "</td>";
                        wk += "<td>:</td>";
                        wk += "<td colspan='2' style='padding-left: 5px; word-break: break-all;'>";
                        wk += name;
                        wk += "</td>";
                        wk += "</tr>";

                        /*
                        // 小分重量   
                        //phuc maintenance start
                        if (pageLangText.kbn_tani_LB_GAL.text === App.ui.page.user.kbn_tani) {
                            if (dt.cd_mark == pageLangText.spiceMarkCode.text) {
                                dt.nm_tani = pageLangText.gramText.text;
                            }
                            else {
                                dt.nm_tani = pageLangText.tani_LB_text.text;
                            }
                        }
                        else {
                            if (dt.cd_mark == pageLangText.spiceMarkCode.text) {
                                dt.nm_tani = pageLangText.gramText.text;
                            }
                            else {
                                dt.nm_tani = pageLangText.tani_Kg_text.text;
                            }
                        }
                        //phuc maintenance end

                        if (dt.cd_mark == pageLangText.spiceMarkCode.text) {
	                        dt.nm_tani = pageLangText.gramText.text;
                        }
                        */

                        //wk += "<tr valign='top'><td width='75px'>" + pageLangText.txt_juryo_label2.text + "</td>";
                        wk += "<tr valign='top'><td width='90px' style=' padding-left: 12px;'>" + pageLangText.txt_juryo_label2.text + "</td>";
                        wk += "<td>:</td>";
                        wk += "<td style='padding-left: 5px;'>";
                        if (kbnSeikiHasu == pageLangText.seikiHasuSeikiKbn.text) {
                            wk += kowakeLabelFormatNumber(dt.set_wt_label_now) + " " + dt.nm_tani;
                            //wk += dt.set_wt_label_now + " " + dt.nm_tani;
                        }
                        else {
                            wk += kowakeLabelFormatNumber(dt.set_wt_label_now) + " " + dt.nm_tani_hasu;
                            //wk += dt.set_wt_label_now + " " + dt.nm_tani_hasu;
                        }
                        wk += "</td>";
                        wk += "<td></td>";
                        wk += "</tr>";
                        // 配合コード
                        wk += "<tr valign='top'><td width='90px' style=' padding-left: 12px;'>" + pageLangText.txt_codeHaigo_label2.text + "</td>";
                        wk += "<td>:</td>";
                        wk += "<td colspan='2' style='padding-left: 5px; word-break: break-all;'>";
                        wk += dt.cd_haigo;
                        wk += "</td>";
                        wk += "</tr>";
                        // 配合名
                        //wk += "<tr valign='top'><td width='75px'>" + pageLangText.txt_haigo_label2.text + "</td>";
                        wk += "<tr valign='top'><td width='90px' style=' padding-left: 12px;'>" + pageLangText.txt_haigo_label2.text + "</td>";
                        wk += "<td>:</td>";
                        wk += "<td colspan='2' style='padding-left: 5px; word-break: break-all;'>";
                        wk += haigoName;
                        wk += "</td>";
                        wk += "</tr>";
                        // 製造日
                        //wk += "<tr valign='top'><td width='75px'>" + pageLangText.txt_shikomi_label2.text + "</td>";
                        wk += "<tr valign='top'><td width='90px' style=' padding-left: 12px;'>" + pageLangText.txt_shikomi_label2.text + "</td>";
                        wk += "<td>:</td>";
                        wk += "<td style='padding-left: 5px;'>";
                        wk += dt.dt_seizo;
                        wk += "</td>";
                        wk += "<td></td>";
                        wk += "</tr>";
                        // 工程
                        //wk += "<tr valign='top'><td width='75px'>" + pageLangText.txt_kotei_label2.text + "</td>";
                        wk += "<tr valign='top'><td width='90px' style=' padding-left: 12px;'>" + pageLangText.txt_kotei_label2.text + "</td>";
                        wk += "<td>:</td>";
                        wk += "<td style='padding-left: 5px;'>";
                        wk += dt.no_kotei;
                        wk += "</td>";
                        // QRコードイメージ
                        wk += "<td rowspan='3'><img src='";
                        wk += data;
                        wk += "' height='65px' width='65px' /></td>";
                        wk += "</tr>";
                        // 投入順
                        wk += "<tr valign='top'><td width='90px' style=' padding-left: 12px;'>" + pageLangText.txt_kotei_sagyojyun_label2.text + "</td>";
                        wk += "<td>:</td>";
                        wk += "<td style='padding-left: 5px;'>";
                        wk += dt.no_tonyu;
                        wk += "</td></tr>";
                        // バッチ数
                        //wk += "<tr valign='top'><td width='75px'>" + pageLangText.txt_kaisu_label2.text + "</td>";
                        wk += "<tr valign='top'><td width='90px' style=' padding-left: 12px;'>" + pageLangText.txt_kaisu_label2.text + "</td>";
                        wk += "<td>:</td>";
                        wk += "<td style='padding-left: 5px;'>";
                        wk += dt.set_su_batch_now + " / " + dt.set_su_batch_end;
                        wk += "</td></tr>";
                        // 個数
                        //wk += "<tr valign='top'><td width='75px'>" + pageLangText.txt_kosu_label2.text + "</td>";
                        wk += "<tr valign='top'><td width='90px' style=' padding-left: 12px;'>" + pageLangText.txt_kosu_label2.text + "</td>";
                        wk += "<td>:</td>";
                        wk += "<td style='padding-left: 5px;'>";
                        wk += dt.set_su_label_now + " / " + dt.set_su_label_end;
                        // 枠線表示切替区分の判定(0：表示しない　1：表示する)
                        if (kbnWakusen == pageLangText.kbnWakusenAri.number) {
                            wk += "</td>";
                            // 枠線イメージ
                            wk += "<td rowspan='2'><div style='border:1px solid #000000;width:125px;height:95%'>";
                        }
                        wk += "</td></tr>";
                        // 倍率
                        //wk += "<tr valign='top'><td width='75px'>" + pageLangText.txt_ritsuBai_label2.text + "</td>";
                        wk += "<tr valign='top'><td width='90px' style=' padding-left: 12px;'>" + pageLangText.txt_ritsuBai_label2.text + "</td>";
                        wk += "<td>:</td>";
                        wk += "<td style='padding-left: 5px;'>";
                        wk += dt.set_ritsu_bai;
                        wk += "</td></tr>";
                        if (dt.nm_Allergy.length != 0) {
                            // アレルゲン
                            //wk += "<tr valign='top'><td width='75px'>" + allergyKbn + "</td>";
                            wk += "<tr valign='top'><td width='90px' style=' padding-left: 12px;'>" + allergyKbn + "</td>";
                            wk += "<td>:</td>";
                            wk += "<td colspan='2' style='padding-left: 5px; word-break: break-all;'>";
                            wk += allergyName;
                            wk += "</td>";
                            wk += "</tr>";
                        }
                        if (dt.nm_Other.length != 0) {
                            // 食品添加物
                            //wk += "<tr valign='top'><td width='75px'>" + otherKbn + "</td>";
                            wk += "<tr valign='top'><td width='90px' style=' padding-left: 12px;'>" + otherKbn + "</td>";
                            wk += "<td>:</td>";
                            wk += "<td colspan='2' style='padding-left: 5px; word-break: break-all;'>";
                            wk += otherName;
                            wk += "</td>";
                            wk += "</tr>";
                        }

                        wk += "</table></div>";

                        return wk;
                    }
                    else if (version == pageLangText.chinaLabelFormatKbn.number) {
                        if (App.ui.page.lang == 'ja' || App.ui.page.lang == 'zh') {
                            //// ■ 中文対応 ■
                            var wk = "";
                            var code;
                            var paddingL = "padding-left: 2px";

                            // QRCodeの作成
                            var data = "./QRCodeGererateHandler.ashx";
                            data += "?code=";
                            code = generateKowakeCode(dt);
                            data += code;
                            data += "&lang=";
                            data += App.ui.page.lang;
                            if (dt.nm_Allergy.length != 0) {
                                var nameAllergy = dt.nm_Allergy.split(",");
                                allergyName = nameSplit(nameAllergy);
                                allergyKbn = dt.kbnAllergy;
                            }
                            else {
                                allergyKbn = "";
                                allergyName = "";
                            }
                            if (dt.nm_Other.length != 0) {
                                var nameOther = dt.nm_Other.split(",");
                                otherName = nameSplit(nameOther);
                                otherKbn = dt.kbnOther;
                            }
                            else {
                                otherKbn = "";
                                otherName = "";
                            }

                            // 全体サイズ設定
                            wk += "<table style='font-size:9pt; letter-spacing: 0px; line-height:12px; font-family:SimHei; height:250px; width:360px; border-spacing:0px 0px; border:solid 0px; table-layout: fixed;'>";

                            // 1行目
                            wk += "<tr>";
                            // ラベル名
                            wk += "<td width='50px' style='padding-left:0px;'></td>"
                            wk += "<td colspan='3' align='center' style='border:solid 0px;padding-bottom: 0px;padding-top: 10px;line-height:normal'>";
                            wk += pageLangText.txt_titleKowake_label.text;
                            wk += "</td>";
                            wk += "<td width='80px'></td>"
                            wk += "</tr>";

                            // 2行目
                            wk += "<tr>";
                            // 製造ライン
                            wk += "<td style='vertical-align:top; border:solid 0px;'>";
                            wk += pageLangText.seizoLineName.text;
                            wk += "</td>";
                            wk += "<td colspan='3' style='vertical-align:top; " + paddingL + "; border:solid 0px;'>";
                            wk += lineName;
                            wk += "</td>";
                            // QRコードイメージ
                            wk += "<td rowspan='3' align='center' style='border:solid 0px; padding:3px 0px;'><img src='";
                            wk += data;
                            wk += "' height='50px' width='50px' />"
                            wk += "</td>";
                            wk += "</tr>";

                            // 3行目
                            wk += "<tr>";
                            // 工程
                            wk += "<td style='vertical-align:top; border:solid 0px;'>";
                            wk += pageLangText.txt_kotei_label2.text;
                            wk += "</td>";
                            wk += "<td style='vertical-align:top; " + paddingL + "; border:solid 0px;'>";
                            wk += dt.no_kotei;
                            wk += "</td>";
                            // 投入順
                            wk += "<td style='vertical-align:top; border:solid 0px;'>";
                            wk += pageLangText.txt_kotei_sagyojyun_label2.text;
                            wk += "</td>";
                            wk += "<td style='vertical-align:top; " + paddingL + "; border:solid 0px;'>";
                            wk += dt.no_tonyu;
                            wk += "</td>";
                            wk += "</tr>";


                            // 4行目
                            wk += "<tr>";
                            // 配合コード
                            /* 2022/31/03 - 22094: -START FP-Lite ChromeBrowser Modify */
                            wk += "<td style='vertical-align:top; border:solid 0px;'>";
                            /* 2022/31/03 - 22094: -END FP-Lite ChromeBrowser Modify */
                            wk += pageLangText.txt_codeHaigo_label2.text;
                            wk += "</td>";
                            wk += "<td colspan='2' style='vertical-align:top; " + paddingL + "; border:solid 0px;'>";
                            wk += dt.cd_haigo;
                            wk += "</td>";
                            wk += "</td>";
                            // 仕込量
                            wk += "<td style='vertical-align:top; width:85px; border:solid 0px;text-align:right'>";
                            wk += "(";
                            //wk += shikomiRyo;
                            //wk += " ";
                            if (kbnSeikiHasu == pageLangText.seikiHasuSeikiKbn.text) {
                                wk += parseFloat(wt_haigo_gokei).toFixed(3);
                                wk += " ";
                                // 単位を「Kg」で固定化
                                //wk += dt.nm_tani;
                                wk += pageLangText.lbl_mark_Kg.text;
                            }
                            else {
                                wk += parseFloat(shikomiRyo - wt_haigo_gokei * batchKeikaku).toFixed(3);
                                wk += " ";
                                // 単位を「Kg」で固定化
                                //wk += dt.nm_tani_hasu;
                                wk += pageLangText.lbl_mark_Kg.text;
                            }
                            wk += ")";
                            wk += "</td>";
                            wk += "</tr>";

                            // 5行目
                            wk += "<tr>";
                            // 配合名
                            /* 2022/31/03 - 22094: -START FP-Lite ChromeBrowser Modify */
                            wk += "<td style='vertical-align:top; border:solid 0px;'>";
                            /* 2022/31/03 - 22094: -END FP-Lite ChromeBrowser Modify */
                            wk += pageLangText.txt_haigo_label2.text;
                            wk += "</td>";
                            wk += "<td colspan='4' style='letter-spacing:-1px; vertical-align:top; " + paddingL + "; font-size:14pt; font-weight: bold; word-break:break-all; border:solid 0px;line-height:18px;'>";
                            wk += haigoName;
                            wk += "</tr>";


                            // 6行目
                            wk += "<tr>";
                            // 原料コード
                            wk += "<td style='vertical-align:top; border:solid 0px;'>";
                            wk += pageLangText.txt_code_label2.text;
                            wk += "</td>";
                            wk += "<td colspan='4' style='vertical-align:top; " + paddingL + "; border:solid 0px;'>";
                            wk += dt.cd_hinmei;
                            wk += "</td>";
                            wk += "</tr>";

                            // 7行目
                            wk += "<tr>";
                            // 原料名
                            wk += "<td style='vertical-align:top; border:solid 0px;'>";
                            wk += pageLangText.txt_genryo_label2.text;
                            wk += "</td>";
                            wk += "<td colspan='4' style='vertical-align:top; " + paddingL + "; font-size:14pt; font-weight: bold; word-break:break-all; border:solid 0px;letter-spacing:-1px; line-height: 18px'>";
                            wk += name;
                            wk += "</td>";
                            wk += "</tr>";

                            // 8行目
                            wk += "<tr>";
                            // 小分重量
                            wk += "<td style='vertical-align:top; border-spacing:0px 0px; border:solid 0px;'>";
                            wk += pageLangText.txt_juryo_label2.text;
                            wk += "</td>";
                            wk += "<td colspan='3' style='vertical-align:top; " + paddingL + "; font-size:14pt; font-weight: bold; border:solid 0px;; line-height: 18px'>";
                            if (kbnSeikiHasu == pageLangText.seikiHasuSeikiKbn.text) {
                                wk += kowakeLabelFormatNumber(dt.set_wt_label_now) + " " + dt.nm_tani;
                            }
                            else {
                                wk += kowakeLabelFormatNumber(dt.set_wt_label_now) + " " + dt.nm_tani_hasu;
                            }
                            // 枠線イメージ
                            wk += "<td rowspan='2' align='center'>";
                            // 枠線表示切替区分の判定(0：表示しない　1：表示する)
                            if (kbnWakusen == pageLangText.kbnWakusenAri.number) {
                                wk += "<div style='border:1px solid #000000;width:100%;height:100%;'>";
                            }
                            wk += "</td>";
                            wk += "</td>";
                            wk += "</tr>";

                            // 9行目
                            wk += "<tr>";
                            // バッチ数
                            wk += "<td style='width:54px; border:solid 0px;'>";
                            wk += pageLangText.txt_kaisu_label2.text;
                            wk += "</td>";
                            wk += "<td style='" + paddingL + "; border:solid 0px;'>";
                            wk += "<span style='font-weight: bold; font-size:14pt;'>";
                            wk += dt.set_su_batch_now;
                            wk += "</span>";
                            wk += " / ";
                            wk += dt.set_su_batch_end;
                            wk += "</td>";
                            // 個数
                            wk += "<td align='right' style='border:solid 0px;'>";
                            wk += pageLangText.txt_kosu_label2.text;
                            wk += "</td>";
                            wk += "<td style='" + paddingL + "; border:solid 0px;'>";
                            wk += "<span style='font-weight: bold; font-size:14pt;'>";
                            wk += dt.set_su_label_now;
                            wk += "</span>";
                            wk += " / ";
                            wk += dt.set_su_label_end;
                            wk += "</td>";
                            wk += "</tr>";

                            // 10行目 
                            wk += "<tr>";
                            // 倍率
                            wk += "<td style='vertical-align:top; border:solid 0px;'>";
                            wk += pageLangText.txt_ritsuBai_label2.text;
                            wk += "</td>";
                            wk += "<td style='vertical-align:top; " + paddingL + "; border:solid 0px;'>";
                            wk += dt.set_ritsu_bai;
                            wk += "</td>";
                            // 製造日
                            /* 2022/01/04 - 22094: -START FP-Lite ChromeBrowser Modify */
                            wk += "<td align='right' style='vertical-align:top; border:solid 0px;'>";
                            /* 2022/01/04 - 22094: -END FP-Lite ChromeBrowser Modify */
                            wk += pageLangText.txt_shikomi_label2.text;
                            wk += "</td>";
                            wk += "<td style='vertical-align:top; " + paddingL + "; border:solid 0px;'>";
                            wk += dt.dt_seizo;
                            wk += "</td>";
                            wk += "</tr>";

                            // 11行目
                            if (dt.nm_Allergy.length != 0) {
                                wk += "<tr>";
                                // アレルゲン
                                wk += "<td style='vertical-align:top; width:60px; border:solid 0px;'>";
                                wk += allergyKbn;
                                wk += "</td>";
                                wk += "<td colspan='4' style='vertical-align:top; " + paddingL + "; word-break:break-all; border:solid 0px;'>";
                                wk += allergyName;
                                wk += "</td>";
                                wk += "</tr>";
                            }

                            // 12行目
                            if (dt.nm_Other.length != 0) {
                                wk += "<tr>";
                                // 食品添加物
                                wk += "<td style='vertical-align:top; width:60px; border:solid 0px;'>";
                                wk += otherKbn;
                                wk += "<td colspan='4' style='vertical-align:top; " + paddingL + "; word-break:break-all; border:solid 0px;'>";
                                wk += otherName;
                                wk += "</td>";
                                wk += "</tr>";
                            }

                            wk += "</table></div>";
                        }
                        else {
                            //// ■ 中文対応 ■
                            var wk = "";
                            var code;

                            // QRCodeの作成
                            var data = "./QRCodeGererateHandler.ashx";
                            data += "?code=";
                            code = generateKowakeCode(dt);
                            data += code;
                            data += "&lang=";
                            data += App.ui.page.lang;
                            if (dt.nm_Allergy.length != 0) {
                                var nameAllergy = dt.nm_Allergy.split(",");
                                allergyName = nameSplit(nameAllergy);
                                allergyKbn = dt.kbnAllergy;
                            }
                            else {
                                allergyKbn = "";
                                allergyName = "";
                            }
                            if (dt.nm_Other.length != 0) {
                                var nameOther = dt.nm_Other.split(",");
                                otherName = nameSplit(nameOther);
                                otherKbn = dt.kbnOther;
                            }
                            else {
                                otherKbn = "";
                                otherName = "";
                            }

                            // 全体サイズ設定
                            wk += "<table style='font-size:9pt; letter-spacing: 0px; line-height:12px; font-family:SimHei; height:250px; width:360px; border-spacing:0px 0px; border:solid 0px; padding:5px'>";

                            wk += "<tr><td width='80px'></td><td width='52px'></td><td width='80px'></td><td width='76px'></td><td></td></tr>"
                            // 1行目
                            wk += "<tr>";
                            // ラベル名
                            wk += "<td colspan='5' align='center' style='border:solid 0px; padding-top: 10px;'>"; 
                            wk += pageLangText.txt_titleKowake_label.text;
                            wk += "</td>";
                            wk += "</tr>";

                            // 2行目
                            wk += "<tr>";
                            // 製造ライン
                            wk += "<td style='vertical-align:top; width:54px; border:solid 0px;padding-left:3px'>";
                            wk += pageLangText.seizoLineName.text;
                            wk += "</td>";
                            wk += "<td colspan='3' style='vertical-align:top; padding-left: 10px; border:solid 0px;'>";
                            wk += lineName;
                            wk += "</td>";
                            // QRコードイメージ
                            wk += "<td rowspan='3' align='left' style='border:solid 0px; padding-top:10px;padding-left:3px'><img src='";
                            wk += data;
                            wk += "' height='50px' width='50px' />"
                            wk += "</td>";
                            wk += "</tr>";

                            // 3行目
                            wk += "<tr>";
                            // 工程
                            wk += "<td style='vertical-align:top; width:54px; border:solid 0px;padding-left:3px'>";
                            wk += pageLangText.txt_kotei_label2.text;
                            wk += "</td>";
                            wk += "<td style='vertical-align:top; padding-left: 5px; border:solid 0px; padding-left: 10px'>";
                            wk += dt.no_kotei;
                            wk += "</td>";
                            // 投入順
                            wk += "<td style='vertical-align:top; width:70px; border:solid 0px;'>";
                            wk += pageLangText.txt_kotei_sagyojyun_label2.text;
                            wk += "</td>";
                            wk += "<td style='vertical-align:top; padding-left: 5px; border:solid 0px;'>";
                            wk += dt.no_tonyu;
                            wk += "</td>";
                            wk += "</tr>";


                            // 4行目
                            wk += "<tr>";
                            // 配合コード
                            /* 2022/31/03 - 22094: -START FP-Lite ChromeBrowser Modify */
                            wk += "<td style='vertical-align:top; width:54px; border:solid 0px; padding-right: 0px;padding-left:3px'>";
                            /* 2022/31/03 - 22094: -END FP-Lite ChromeBrowser Modify */
                            wk += pageLangText.txt_codeHaigo_label2.text;
                            wk += "</td>";
                            wk += "<td colspan='2' style='vertical-align:top; padding-left: 5px; border:solid 0px; padding-left: 10px;'>";
                            wk += dt.cd_haigo;
                            wk += "</td>";
                            // 仕込量
                            wk += "<td style='vertical-align:top; width:75px; border:solid 0px;text-align:right'>";
                            wk += "(";
                            //wk += shikomiRyo;
                            //wk += " ";
                            if (kbnSeikiHasu == pageLangText.seikiHasuSeikiKbn.text) {
                                wk += parseFloat(wt_haigo_gokei).toFixed(3);
                                wk += " ";
                                // 単位を「Kg」で固定化
                                //wk += dt.nm_tani;
                                wk += pageLangText.lbl_mark_Kg.text;
                            }
                            else {
                                wk += parseFloat(shikomiRyo - wt_haigo_gokei * batchKeikaku).toFixed(3);
                                wk += " ";
                                // 単位を「Kg」で固定化
                                //wk += dt.nm_tani_hasu;
                                wk += pageLangText.lbl_mark_Kg.text;
                            }
                            wk += ")";
                            wk += "</td>";
                            wk += "</tr>";

                            // 5行目
                            wk += "<tr>";
                            // 配合名
                            /* 2022/31/03 - 22094: -START FP-Lite ChromeBrowser Modify */
                            wk += "<td style='vertical-align:top; width:54px; border:solid 0px; padding-right: 0px;padding-left:3px;'>";
                            /* 2022/31/03 - 22094: -END FP-Lite ChromeBrowser Modify */
                            wk += pageLangText.txt_haigo_label2.text;
                            wk += "</td>";
                            wk += "<td colspan='4' style='letter-spacing:-0.6px; vertical-align:top; padding-left: 5px; font-size:15pt; font-weight: bold; word-break:break-all; border:solid 0px; padding-left: 10px;line-height: 16px;'>";
                            wk += haigoName;
                            wk += "</td>";
                            wk += "</tr>";

                            // 6行目
                            wk += "<tr>";
                            // 原料コード
                            wk += "<td style='vertical-align:top; width:54px; border:solid 0px;padding-left:3px'>";
                            wk += pageLangText.txt_code_label2.text;
                            wk += "</td>";
                            wk += "<td colspan='4' style='vertical-align:top; padding-left: 10px; border:solid 0px; padding-top: 2px;'>";
                            wk += dt.cd_hinmei;
                            wk += "</td>";
                            wk += "</tr>";

                            // 7行目
                            wk += "<tr>";
                            // 原料名
                            wk += "<td style='vertical-align:top; width:54px; border:solid 0px;padding-left:3px'>";
                            wk += pageLangText.txt_genryo_label2.text;
                            wk += "</td>";
                            wk += "<td colspan='4' style='vertical-align:top; padding-left: 10px; font-size:15pt; font-weight: bold; word-break:break-all; border:solid 0px;line-height: 16px; padding-top: 1px;'>";
                            wk += name;
                            wk += "</td>";
                            wk += "</tr>";

                            // 8行目
                            wk += "<tr style='line-height: 18px;'>";
                            // 小分重量
                            wk += "<td style='vertical-align:top; width:54px; border-spacing:0px 0px; border:solid 0px;padding-left:3px'>";
                            wk += pageLangText.txt_juryo_label2.text;
                            wk += "</td>";
                            wk += "<td colspan='4' style='vertical-align:top; padding-left: 10px; font-size:15pt; font-weight: bold; border:solid 0px; padding-top: 1px;'>";
                            if (kbnSeikiHasu == pageLangText.seikiHasuSeikiKbn.text) {
                                wk += kowakeLabelFormatNumber(dt.set_wt_label_now) + " " + dt.nm_tani;
                            }
                            else {
                                wk += kowakeLabelFormatNumber(dt.set_wt_label_now) + " " + dt.nm_tani_hasu;
                            }
                            wk += "</td>";
                            wk += "</tr>";

                            // 9行目
                            wk += "<tr style='line-height: 18px;'>";
                            // バッチ数
                            wk += "<td style='width:54px; border:solid 0px;padding-left:3px'>";
                            wk += pageLangText.txt_kaisu_label2.text;
                            wk += "</td>";
                            wk += "<td style='padding-left: 10px; border:solid 0px;' colspan='2'>";
                            wk += "<span style='font-weight: bold; font-size:15pt;'>";
                            wk += dt.set_su_batch_now;
                            wk += "</span>";
                            wk += " / ";
                            wk += dt.set_su_batch_end;
                            //wk += "</td>";
                            //// 個数
                            //wk += "<td align='right' style='border:solid 0px;'>";
                            wk += "<span style='float: right;'>"
                            wk += pageLangText.txt_kosu_label2.text;
                            wk += "</span>"
                            wk += "</td>";
                            wk += "<td style='padding-left: 10px; border:solid 0px;'>";
                            wk += "<span style='font-weight: bold; font-size:15pt;'>";
                            wk += dt.set_su_label_now;
                            wk += "</span>";
                            wk += " / ";
                            wk += dt.set_su_label_end;
                            wk += "</td>";
                            // 枠線イメージ
                            wk += "<td rowspan='2' align='left'>";
                            // 枠線表示切替区分の判定(0：表示しない　1：表示する)
                            if (kbnWakusen == pageLangText.kbnWakusenAri.number) {
                                wk += "<div style='border:1px solid #000000;width:85%;height:100%;'>";
                            }
                            wk += "</td>";
                            wk += "</tr>";

                            // 10行目
                            wk += "<tr>";
                            // 倍率
                            wk += "<td style='vertical-align:top; width:54px; border:solid 0px;padding-left:3px'>";
                            wk += pageLangText.txt_ritsuBai_label2.text;
                            wk += "</td>";
                            wk += "<td style='vertical-align:top; padding-left: 10px; border:solid 0px;' colspan='2'>";
                            wk += dt.set_ritsu_bai;
                            //wk += "</td>";
                            // 製造日
                            /* 2022/01/04 - 22094: -START FP-Lite ChromeBrowser Modify */
                            //wk += "<td align='right' style='vertical-align:top; width:54px; border:solid 0px; padding-left:2px'>";
                            /* 2022/01/04 - 22094: -END FP-Lite ChromeBrowser Modify */
                            wk += "<span style='float: right;'>"
                            wk += pageLangText.txt_shikomi_label2.text;
                            wk += "</span>";
                            wk += "</td>";
                            wk += "<td style='vertical-align:top; padding-left: 10px; border:solid 0px;'>";
                            wk += dt.dt_seizo;
                            wk += "</td>";
                            wk += "</tr>";

                            // 11行目
                            if (dt.nm_Allergy.length != 0) {
                                wk += "<tr>";
                                // アレルゲン
                                wk += "<td style='vertical-align:top; width:60px; border:solid 0px;padding-left:3px'>";
                                wk += allergyKbn;
                                wk += "</td>";
                                wk += "<td colspan='4' style='vertical-align:top; padding-left: 10px; word-break:break-all; border:solid 0px; padding-top: 2px;'>";
                                wk += allergyName;
                                wk += "</td>";
                                wk += "</tr>";
                            }

                            // 12行目
                            if (dt.nm_Other.length != 0) {
                                wk += "<tr>";
                                // 食品添加物
                                wk += "<td style='vertical-align:top; width:60px; border:solid 0px;padding-left:3px'>";
                                wk += otherKbn;
                                wk += "<td colspan='4' style='vertical-align:top; padding-left: 10px; word-break:break-all; border:solid 0px;'>";
                                wk += otherName;
                                wk += "</td>";
                                wk += "</tr>";
                            }

                            wk += "</table></div>";
                        }

                        return wk;
                    }
                    else {
                        //// ■ 初期ラベル(divバージョン) ■
                        // 処理開始
                        var wk = "";
                        if (isLast) {
                            //wk += "<div style='page-break-after:auto; font-family:ＭＳ ゴシック; word-break:break-all;'>";
                        }
                        else {
                            //wk += "<div style='page-break-after:always;font-family:ＭＳ ゴシック;word-break:break-all;'>";
                        }
                        var code;
                        if (dt.nm_Allergy.length != 0) {
                            var nameAllergy = dt.nm_Allergy.split(",");
                            allergyName = nameSplit(nameAllergy);
                            allergyKbn = dt.kbnAllergy + "：";
                        }
                        else {
                            allergyKbn = "";
                            allergyName = "";
                        }
                        if (dt.nm_Other.length != 0) {
                            var nameOther = dt.nm_Other.split(",");
                            otherName = nameSplit(nameOther);
                            otherKbn = dt.kbnOther + "：";
                        }
                        else {
                            otherKbn = "";
                            otherName = "";
                        }

                        // QRCodeの作成
                        var data = "./QRCodeGererateHandler.ashx";
                        data += "?code=";
                        code = generateKowakeCode(dt);
                        data += code;
                        data += "&lang=";
                        data += App.ui.page.lang;
                        wk += "<div style='float: left'><img style='' src='" + data + "' width='65' height='65'/></div>";
                        // codeを分割して表示
                        var codes = code.match(/.{1,40}/g);
                        wk += "<div style='position:relative;left: 30px;font-size:8px;'>" + codes[0] + codes[1] + "</div>";
                        wk += "<div style='position:relative;left: 30px;font-size:8px;'>" + codes[2] + "</div>";
                        //wk += "<div style='position:relative;left: 30px;font-size:16px;'>" + pageLangText.txt_kotei_label.text + "：" + dt.no_kotei + "</div>";
                        if (App.ui.page.lang == 'ja' || App.ui.page.lang == 'zh') {
                            wk += "<div style='position:relative;left: 30px;font-size:19px;'>" + pageLangText.txt_kotei_label.text + "：" + dt.no_kotei + "</div>";
                            wk += "<div style='position:relative;left: 30px;font-size:19px;'>" + pageLangText.txt_kotei_sagyojyun_label.text + "：" + dt.no_tonyu + "　　" + dt.set_ritsu_bai + pageLangText.ritsuBaiShort.text + "</div>";
                        }
                        else {
                            wk += "<div style='position:relative;left: 30px;font-size:16px;'>" + pageLangText.txt_kotei_label.text + "：" + dt.no_kotei + "</div>";
                            wk += "<div style='position:relative;left: 30px;font-size:16px;'>" + pageLangText.txt_kotei_sagyojyun_label.text + "：" + dt.no_tonyu + "</div>";
                            wk += "<div style='position:relative;left: 30px;font-size:16px;'>" + pageLangText.ritsuBaiShort.text + "：" + dt.set_ritsu_bai + "</div>";
                        }
                        //wk += "<div style='position:relative;left: 30px;font-size:19px;'>" + pageLangText.txt_kotei_sagyojyun_label.text + "：" + dt.no_tonyu + "　　" + dt.set_ritsu_bai + pageLangText.ritsuBaiShort.text + "</div>";
                        //wk += "<div style='position:relative;left: 30px;font-size:16px;'>" + pageLangText.txt_kotei_sagyojyun_label.text + "：" + dt.no_tonyu + "</div>";
                        //wk += "<div style='position:relative;left: 30px;font-size:16px;'>" + dt.set_ritsu_bai + " " + pageLangText.ritsuBaiShort.text + "</div>";
                        wk += "<div style='clear:both; width:350px; font-size:18px;margin-top:2px;'>" + pageLangText.txt_haigo_label.text + "：" + haigoName + "</div>";
                        wk += "<div style='width:350px; font-size:25px;margin-top:3px;'>" + pageLangText.txt_genryo_label.text + "：" + name + "</div>";
                        //wk += "<div style='height:10px;'>" + "</div>";
                        //if (dt.cd_mark == pageLangText.spiceMarkCode.text) {
                        //    dt.nm_tani = pageLangText.gramText.text;
                        //}

                        //wk += "<div style='width:350px; font-size:25px;'>" + pageLangText.txt_juryo_label.text + "：" + dt.set_wt_label_now + " " + dt.nm_tani + "</div>";

                        if (kbnSeikiHasu == pageLangText.seikiHasuSeikiKbn.text) {
                            wk += "<div style='width:350px; font-size:25px;'>" + pageLangText.txt_juryo_label.text + "：" + kowakeLabelFormatNumber(dt.set_wt_label_now) + " " + dt.nm_tani + "</div>";
                            //wk += "<div style='width:350px; font-size:25px;'>" + pageLangText.txt_juryo_label.text + "：" + dt.set_wt_label_now + " " + dt.nm_tani + "</div>";
                        }
                        else {
                            wk += "<div style='width:350px; font-size:25px;'>" + pageLangText.txt_juryo_label.text + "：" + kowakeLabelFormatNumber(dt.set_wt_label_now) + " " + dt.nm_tani_hasu + "</div>";
                            //wk += "<div style='width:350px; font-size:25px;'>" + pageLangText.txt_juryo_label.text + "：" + dt.set_wt_label_now + " " + dt.nm_tani_hasu + "</div>";
                        }

                        // レイアウト変更：2014.10.21　風袋名を削除し、回数個数を大きくする
                        //wk += "<div style='width:350px; font-size:18px;'>" + "(" + pageLangText.txt_futai_label.text + "：" + dt.set_nm_futai_now + ")" + "</div>";

                        wk += "<div style='font-size:20px;'>" + pageLangText.txt_kaisu_label.text + "：" + dt.set_su_batch_now + " / " + dt.set_su_batch_end;
                        wk += "     " + pageLangText.txt_kosu_label.text + "：" + dt.set_su_label_now + " / " + dt.set_su_label_end + "</div>";

                        //wk += "<div>" + "　" + "</div>";
                        wk += "<div style='font-size:18px;'>" + pageLangText.txt_shikomi_label.text + "：" + dt.dt_seizo + "</div>";
                        wk += "<div style='font-size:14px; width:350px;'>" + allergyKbn + allergyName + "</div>";
                        wk += "<div style='font-size:14px; width:350px;'>" + otherKbn + otherName + "</div>";
                        wk += "</div>";
                        // 処理終了
                        return wk;
                    }
                };

                // 重ねラベル作成処理
                /// <param name="i">index</param>
                /// <param name="dt">gridのデータ</param>
                var createKasanePrintArea = function (i, obj, objlength, isLast) {
                    if (version == pageLangText.kaigaiLabelFormatKbn.number) {
                        //Version2（海外対応）
                        // 処理開始
                        var j = 0, // 重ねループ時に利用
                                d, // 一行ごとのデータ
                                baseUrl = "./QRCodeGererateHandler.ashx",
                                baseLang = "&lang=" + App.ui.page.lang,
                                kasaneHeader = ""; // 重ねで同じマークが5～8個ある場合に1枚目のヘッダを保持しておく

                        var wk = "";
                        if (isLast && objlength <= 4) {
                            //wk += "<div style='page-break-after:auto; width:375px; height:350px;'>";
                        }
                        else {
                            //wk += "<div style='page-break-after:always; width:375px; height:350px;'>";
                        }

                        // ラベルの作成 start
                        // ①代表ラベル分を作成
                        // ①-1表示する文言を作成
                        d = $.extend(true, {}, obj[j]);

                        wk += "<table width='350'><tr>";
                        wk += "<td  colspan='4' align='center' height='10px' >" + pageLangText.txt_titleKasane_label.text + "</td></tr><tr>";
                        wk += "<td width='75px' style=' padding-left: 12px;'>";
                        wk += pageLangText.txt_kotei_label2.text + "</td>";
                        wk += "<td>:</td>";
                        wk += "<td>" + d.no_kotei + "</td>";
                        // ①-2ラベルの内容を作成
                        var data = baseUrl + "?code=";
                        // 代表ラベル用にデータを入替える
                        d.cd_hinmei = pageLangText.kasaneLabelCd.text;
                        d.cd_mark = "";
                        d["set_wt_label_now"] = d.set_gokei_kasane;
                        data += generateKowakeCode(d);
                        data += baseLang;
                        wk += "<td rowspan='3'>";
                        wk += "<img style='padding-top: 7px; padding-bottom: 7px;' src='" + data + "' width='60' height='60'/>";
                        wk += "</td></tr><tr>";
                        wk += "<td width='75px' style=' padding-left: 12px;'>";
                        wk += pageLangText.txt_shikomi_label2.text + "</td>";
                        wk += "<td>:</td>";
                        wk += "<td>" + d.dt_seizo + "</td>";
                        wk += "</tr><tr>";
                        wk += "<td width='75px' style=' padding-left: 12px;'>";
                        wk += pageLangText.txt_kaisu_label2.text + "</td>";
                        wk += "<td>:</td>";
                        wk += "<td>" + d.set_su_batch_now + " / " + d.set_su_batch_end + "</td>";
                        wk += "</tr></table>";

                        // 重ねラベルヘッダ個所を保持
                        kasaneHeader = wk;

                        // ②各小分けラベルを作成
                        for (var j; j < objlength; j++) {
                            if (App.isNumeric(j) && (j != 0) && (j % 4 == 0)) {
                                // 4枚出力するごとに、改ページ判断
                                wk += "</div>";
                                wk += "<div style='width: 350px;'></div>"

                                //if (isLast && objlength - j <= 4) {
                                //    // 最終頁の場合は折り返しなし
                                //    wk += "<div style='page-break-after:auto'>";
                                //}
                                //else {
                                //    // 次ページもあるので折り返し
                                //    wk += "<div style='page-break-after:always; font-family: ＭＳ ゴシック; width: 355px; height: 350px;'>";
                                //}

                                // 後からソートするため、最終頁の判断をしない。
                                wk += "<div style='page-break-after:always; font-family: ＭＳ ゴシック; width: 355px; height: 350px;'>";

                                // 同一重ねラベルは8枚までなので、上の条件に関係なくヘッダを挿入
                                // 保持していた重ねヘッダを再度表示します。
                                wk += kasaneHeader;
                            }
                            // ②-1表示文言作成
                            d = obj[j];

                            //if (d.cd_mark == pageLangText.spiceMarkCode.text) {
                            //    d.nm_tani = pageLangText.gramText.text;
                            //}

                            if (App.isNumeric(j) && ((j + 1) % 2 != 0)) {
                                wk += "<table width='350' border='0' cellspacing='0' cellpadding='0'  style='margin-left: 7px;'>";
                                //rules = 'all'
                                wk += "<tr valign='top'>";
                            }
                            if (App.isNumeric(j) && (j == 0 || (j % 4 == 0))) {
                                wk += "<td style='border-top:1px solid black;border-bottom:1px solid black;border-left:1px solid black;border-right:1px solid black; margin-left: 7px;'>";
                            }
                            else if (App.isNumeric(j) && (j == 1 || ((j - 1) % 4 == 0))) {
                                wk += "<td style='border-top:1px solid black;border-bottom:1px solid black;border-left:0px solid black;border-right:1px solid black;'>";
                            }
                            else if (App.isNumeric(j) && (j != 0 && (j % 2 == 0))) {
                                wk += "<td style='border-top:0px solid black;border-bottom:1px solid black;border-left:1px solid black;border-right:1px solid black; margin-left: 7px;'>";
                            }
                            else {
                                wk += "<td style='border-top:0px solid black;border-bottom:1px solid black;border-left:0px solid black;border-right:1px solid black;'>";
                            }
                            data = baseUrl + "?code=";
                            // ②-2ラベル作成
                            data += generateKowakeCode(d);
                            data += baseLang;
                            wk += "<table width='175'>";
                            wk += "<tr><td colspan='2' style='word-break: break-all; padding-bottom: 4px; padding-top: 2px; padding-left: 3px;'>";
                            wk += d.no_tonyu + " " + d.nm_hinmei;
                            wk += "</td></tr>";
                            wk += "<tr><td style='padding-top: 20px; padding-left: 3px;'>";
                            //wk += d.set_wt_label_now + d.nm_tani;
                            if (kbnSeikiHasu == pageLangText.seikiHasuSeikiKbn.text) {
                                //wk += d.set_wt_label_now + d.nm_tani;
                                wk += kowakeLabelFormatNumber(d.set_wt_label_now) + d.nm_tani;
                            }
                            else {
                                //wk += d.set_wt_label_now + d.nm_tani_hasu
                                wk += kowakeLabelFormatNumber(d.set_wt_label_now) + d.nm_tani_hasu;
                            }
                            wk += "</td><td>";
                            wk += "<img style='padding-bottom: 5px;' src='" + data + "' width='60' height='60'/>";
                            wk += "</td>";
                            wk += "</tr>";
                            wk += "</table>";
                            wk += "</td>";

                            if (App.isNumeric(j) && (((j + 1) % 2 == 0) || (j + 1) == objlength)) {
                                if ((j + 1) == objlength && (j == 0 || ((j + 1) % 2 != 0))) {
                                    wk += "<td><table width='175'></table></td>";
                                    wk += "</tr></table>";
                                }
                                else {
                                    wk += "</tr></table>";
                                }
                            }
                            if (App.isNumeric(j) && (j + 1) != objlength // 最終行は不要
                                             && ((j + 1) % 2 == 0) // ２枚ごと 
                                             && ((j + 1) % 4 != 0)) {// ４枚目は不要
                                // 最終行、４枚目は不要
                                // 2枚出力するごとに、ラベルのfloatを左に寄せる
                                //wk += "<div style='clear:both'></div>";
                            }
                        }
                        wk += "</div>";
                        return wk;
                    }
                    else if (version == pageLangText.chinaLabelFormatKbn.number) {
                        if (App.ui.page.lang == 'ja' || App.ui.page.lang == 'zh') {
                            //// ■ 中文対応 ■
                            // 処理開始
                            var j = 0; // 重ねループ時に利用
                            var d; // 一行ごとのデータ
                            var baseUrl = "./QRCodeGererateHandler.ashx";
                            var baseLang = "&lang=" + App.ui.page.lang;
                            var kasaneHeader = ""; // 重ねで同じマークが5～8個ある場合に1枚目のヘッダを保持しておく

                            var wk = "";

                            // ラベルの作成 start
                            // ①代表ラベル分を作成
                            // ①-1表示する文言を作成
                            d = $.extend(true, {}, obj[j]);
                            //wk += "<style>table td {padding:2px 2px 2px 0px; padding-right: 0px; letter-spacing: -0.6}</style>";
                            // サイズ設定
                            wk += "<table style='font-size:8pt; font-family:SimHei; height:115px; width:375px; border-spacing:0px 0px; border:solid 0px; line-height: 1;letter-spacing: -0.6; padding: 0px;'>";

                            // 1行目
                            wk += "<tr>";
                            // ラベル名
                            wk += "<td colspan='8' align='center' style='border:solid 0px; line-height: normal; padding-top: 10px;'>";
                            wk += pageLangText.txt_titleKasane_label.text;
                            wk += "</td>";
                            wk += "</tr>";

                            // 2行目
                            wk += "<tr>";
                            // 製造ライン
                            wk += "<td style='vertical-align:top; width:54px; border:solid 0px;'>";
                            wk += pageLangText.seizoLineName.text;
                            wk += "</td>";
                            wk += "<td style='vertical-align:top; border:solid 0px;'>";
                            wk += ":";
                            wk += "</td>";
                            wk += "<td colspan='4' style='vertical-align:top; padding-left: 5px; word-break:break-all; border:solid 0px;'>";
                            wk += lineName;
                            wk += "</td>";
                            // QRコード作成
                            // ①-2ラベルの内容を作成
                            var data = baseUrl + "?code=";
                            // 代表ラベル用にデータを入替える
                            d.cd_hinmei = pageLangText.kasaneLabelCd.text;
                            d.cd_mark = "";
                            d["set_wt_label_now"] = d.set_gokei_kasane;
                            data += generateKowakeCode(d);
                            data += baseLang;
                            wk += "<td colspan='2' rowspan='4' style='vertical-align:top; border:solid 0px;padding-right:40px;'>";
                            wk += "<img style='' src='";
                            wk += data;
                            wk += "' width='65' height='65'/>";
                            wk += "</td>";
                            wk += "</tr>";

                            // 3行目
                            wk += "<tr>";
                            // 配合コード
                            wk += "<td style='vertical-align:top; width:54px; border:solid 0px;'>";
                            wk += pageLangText.txt_codeHaigo_label2.text;
                            wk += "</td>";
                            wk += "<td style='vertical-align:top; border:solid 0px;'>";
                            wk += ":";
                            wk += "</td>";
                            wk += "<td colspan='4' style='vertical-align:top; padding-left: 5px; border:solid 0px;'>";
                            wk += d.cd_haigo;
                            wk += "</td>";
                            wk += "</tr>";

                            // 4行目
                            wk += "<tr>";
                            // 配合名
                            wk += "<td style='vertical-align:top; width:54px; border:solid 0px;'>";
                            wk += pageLangText.txt_haigo_label2.text;
                            wk += "</td>";
                            wk += "<td style='vertical-align:top; border:solid 0px;'>";
                            wk += ":";
                            wk += "</td>";
                            wk += "<td colspan='4' style='vertical-align:top; padding-left: 5px; word-break:break-all; border:solid 0px;width:300px;padding-right: 8px;'>";
                            wk += haigoName;
                            wk += "</td>";
                            wk += "</tr>";

                            // 5行目
                            wk += "<tr>";
                            // 投放日
                            wk += "<td style='vertical-align:top; width:54px; border:solid 0px;'>";
                            wk += pageLangText.txt_shikomi_label2.text;
                            wk += "</td>";
                            wk += "<td style='vertical-align:top; border:solid 0px;'>";
                            wk += ":";
                            wk += "</td>";
                            wk += "<td colspan='4' style='vertical-align:top; padding-left: 5px; word-break:break-all; border:solid 0px;'>";
                            wk += d.dt_seizo;
                            wk += "</td>";
                            wk += "</tr>";

                            // 6行目
                            wk += "<tr>";
                            // 工程
                            wk += "<td style='vertical-align:top; width:54px; border:solid 0px;'>";
                            wk += pageLangText.txt_kotei_label2.text;
                            wk += "</td>";
                            wk += "<td style='vertical-align:top; border:solid 0px;'>";
                            wk += ":";
                            wk += "</td>";
                            wk += "<td style='vertical-align:top; padding-left: 5px; word-break:break-all; border:solid 0px;'>";
                            wk += d.no_kotei;
                            wk += "</td>";
                            // 次数
                            wk += "<td style='vertical-align:top; width:25px; border:solid 0px;'>";
                            wk += pageLangText.txt_kaisu_label2.text;
                            wk += "</td>";
                            wk += "<td style='vertical-align:top; border:solid 0px;'>";
                            wk += ":";
                            wk += "</td>";
                            wk += "<td style='vertical-align:top; padding-left: 5px; word-break:break-all; border:solid 0px;'>";
                            wk += d.set_su_batch_now;
                            wk += " / ";
                            wk += d.set_su_batch_end;
                            wk += "</td>";

                            wk += "</tr>";

                            wk += "</table>";

                            // 重ねラベルヘッダ個所を保持
                            kasaneHeader = wk;

                            // ②各小分けラベルを作成
                            for (var j; j < objlength; j++) {
                                if (App.isNumeric(j) && (j != 0) && (j % 4 == 0)) {
                                    // 4枚出力するごとに、改ページ判断
                                    wk += "</div>";

                                    // 後からソートするため、最終頁の判断をしない。
                                    wk += "<div style='page-break-after:always; font-family:SimHei;'>";

                                    // 同一重ねラベルは8枚までなので、上の条件に関係なくヘッダを挿入
                                    // 保持していた重ねヘッダを再度表示します。
                                    wk += kasaneHeader;
                                }
                                // ②-1表示文言作成
                                d = obj[j];

                                if (App.isNumeric(j) && ((j + 1) % 2 != 0)) {
                                    wk += "<table cellspacing='1' cellpadding='0' width='346px'; style='margin-bottom:2px;'>"; 
                                    wk += "<tr valign='top'>";
                                }

                                // 枠線作成
                                wk += "<td>";

                                data = baseUrl + "?code=";
                                // ②-2ラベル作成
                                data += generateKowakeCode(d);
                                data += baseLang;
                                wk += "<table style='font-size:8pt; font-family:SimHei; width:172px; border-top:1px solid black;border-bottom:1px solid black;border-left:1px solid black;border-right:1px solid black'>";

                                // 1行目（重ねラベル）
                                wk += "<tr>";
                                // 原料名
                                wk += "<td colspan='2'>";
                                wk += "<div style='overflow:hidden; height:7px; width:100%; border:solid 0px; padding-bottom:12px;padding-left:1px;'>";
                                wk += d.no_tonyu + " " + d.nm_hinmei;
                                wk += "</div>";
                                wk += "</td>";
                                wk += "</tr>";

                                // 2行目（重ねラベル）
                                wk += "<tr>";
                                // 重量
                                wk += "<td style='border:solid 0px; vertical-align: middle; padding-left:3px;'>";
                                if (kbnSeikiHasu == pageLangText.seikiHasuSeikiKbn.text) {
                                    wk += kowakeLabelFormatNumber(d.set_wt_label_now) + d.nm_tani;
                                }
                                else {
                                    // wk += d.set_wt_label_now + d.nm_tani_hasu
                                    wk += kowakeLabelFormatNumber(d.set_wt_label_now) + d.nm_tani_hasu;
                                }
                                wk += "</td>";
                                // QRコード
                                wk += "<td style='text-align:center; border:solid 0px; padding-bottom:4px;'>";
                                wk += "<img style='' src='";
                                wk += data;
                                wk += "' width='38' height='38'/>";
                                wk += "</td>";
                                wk += "</tr>";
                                wk += "</table>";
                                wk += "</td>";

                                // 重ねラベル3つ表示の際のレイアウト調整
                                if (App.isNumeric(j) && (((j + 1) % 2 == 0) || (j + 1) == objlength)) {
                                    if ((j + 1) == objlength && (j == 0 || ((j + 1) % 2 != 0))) {
                                        wk += "<td><table style='font-size:8pt; font-family:SimHei; width:172px; border:solid 0px;'></table></td>";
                                        wk += "</table>";
                                    }
                                    else {
                                        wk += "</table>";
                                    }
                                }
                            }
                            wk += "</div>";
                            return wk;
                        }else{
                        //// ■ 中文対応(英語) ■
                        // 処理開始
                        var j = 0; // 重ねループ時に利用
                        var d; // 一行ごとのデータ
                        var baseUrl = "./QRCodeGererateHandler.ashx";
                        var baseLang = "&lang=" + App.ui.page.lang;
                        var kasaneHeader = ""; // 重ねで同じマークが5～8個ある場合に1枚目のヘッダを保持しておく

                        var wk = "";

                        // ラベルの作成 start
                        // ①代表ラベル分を作成
                        // ①-1表示する文言を作成
                        d = $.extend(true, {}, obj[j]);
                        //wk += "<style>table td {padding:2px 2px 2px 0px; padding-right: 0px; letter-spacing: -0.6}</style>";
                        // サイズ設定
                        wk += "<table style='font-size:8pt; font-family:SimHei; height:115px; width:375px; border-spacing:0px 0px; border:solid 0px; line-height: 1;letter-spacing: -0.6; padding: 0px;'>";

                        // 1行目
                        wk += "<tr>";
                        // ラベル名
                        wk += "<td colspan='8' align='center' style='border:solid 0px; line-height: normal; padding-top: 10px;'>";
                        wk += pageLangText.txt_titleKasane_label.text;
                        wk += "</td>";
                        wk += "</tr>";

                        // 2行目
                        wk += "<tr>";
                        // 製造ライン
                        wk += "<td style='vertical-align:top; width:54px; border:solid 0px;'>";
                        wk += pageLangText.seizoLineName.text;
                        wk += "</td>";
                        wk += "<td style='vertical-align:top; border:solid 0px;'>";
                        wk += ":";
                        wk += "</td>";
                        wk += "<td colspan='4' style='vertical-align:top; padding-left: 5px; word-break:break-all; border:solid 0px;'>";
                        wk += lineName;
                        wk += "</td>";
                        // QRコード作成
                        // ①-2ラベルの内容を作成
                        var data = baseUrl + "?code=";
                        // 代表ラベル用にデータを入替える
                        d.cd_hinmei = pageLangText.kasaneLabelCd.text;
                        d.cd_mark = "";
                        d["set_wt_label_now"] = d.set_gokei_kasane;
                        data += generateKowakeCode(d);
                        data += baseLang;
                        wk += "<td colspan='2' rowspan='4' align='right' style='vertical-align:top; border:solid 0px;padding-right:40px;'>";
                        wk += "<img style='' src='";
                        wk += data;
                        wk += "' width='65' height='65'/>";
                        wk += "</td>";
                        wk += "</tr>";

                        // 3行目
                        wk += "<tr>";
                        // 配合コード
                        wk += "<td style='vertical-align:top; width:54px; border:solid 0px;'>";
                        wk += pageLangText.txt_codeHaigo_label2.text;
                        wk += "</td>";
                        wk += "<td style='vertical-align:top; border:solid 0px;'>";
                        wk += ":";
                        wk += "</td>";
                        wk += "<td colspan='4' style='vertical-align:top; padding-left: 5px; border:solid 0px;'>";
                        wk += d.cd_haigo;
                        wk += "</td>";
                        wk += "</tr>";

                        // 4行目
                        wk += "<tr>";
                        // 配合名
                        wk += "<td style='vertical-align:top; width:54px; border:solid 0px;'>";
                        wk += pageLangText.txt_haigo_label2.text;
                        wk += "</td>";
                        wk += "<td style='vertical-align:top; border:solid 0px;'>";
                        wk += ":";
                        wk += "</td>";
                        wk += "<td colspan='4' style='vertical-align:top; padding-left: 5px; word-break:break-all; border:solid 0px; width:300px;'>";
                        wk += haigoName;
                        wk += "</td>";
                        wk += "</tr>";

                        // 5行目
                        wk += "<tr>";
                        // 投放日
                        wk += "<td style='vertical-align:top; width:54px; border:solid 0px;'>";
                        wk += pageLangText.txt_shikomi_label2.text;
                        wk += "</td>";
                        wk += "<td style='vertical-align:top; border:solid 0px;'>";
                        wk += ":";
                        wk += "</td>";
                        wk += "<td colspan='4' style='vertical-align:top; padding-left: 5px; word-break:break-all; border:solid 0px;'>";
                        wk += d.dt_seizo;
                        wk += "</td>";
                        wk += "</tr>";

                        // 6行目
                        wk += "<tr>";
                        // 工程
                        wk += "<td style='vertical-align:top; width:54px; border:solid 0px;'>";
                        wk += pageLangText.txt_kotei_label2.text;
                        wk += "</td>";
                        wk += "<td style='vertical-align:top; border:solid 0px;'>";
                        wk += ":";
                        wk += "</td>";
                        wk += "<td style='vertical-align:top; padding-left: 5px; word-break:break-all; border:solid 0px;'>";
                        wk += d.no_kotei;
                        wk += "</td>";
                        // 次数
                        wk += "<td style='vertical-align:top; width:25px; border:solid 0px;'>";
                        wk += pageLangText.txt_kaisu_label2.text;
                        wk += "</td>";
                        wk += "<td style='vertical-align:top; border:solid 0px;'>";
                        wk += ":";
                        wk += "</td>";
                        wk += "<td style='vertical-align:top; padding-left: 5px; word-break:break-all; border:solid 0px;'>";
                        wk += d.set_su_batch_now;
                        wk += " / ";
                        wk += d.set_su_batch_end;
                        wk += "</td>";

                        wk += "</tr>";

                        wk += "</table>";

                        // 重ねラベルヘッダ個所を保持
                        kasaneHeader = wk;

                        // ②各小分けラベルを作成
                        for (var j; j < objlength; j++) {
                            if (App.isNumeric(j) && (j != 0) && (j % 4 == 0)) {
                                // 4枚出力するごとに、改ページ判断
                                wk += "</div>";

                                // 後からソートするため、最終頁の判断をしない。
                                wk += "<div style='page-break-after:always; font-family:SimHei;'>";

                                // 同一重ねラベルは8枚までなので、上の条件に関係なくヘッダを挿入
                                // 保持していた重ねヘッダを再度表示します。
                                wk += kasaneHeader;
                            }
                            // ②-1表示文言作成
                            d = obj[j];

                            if (App.isNumeric(j) && ((j + 1) % 2 != 0)) {
                                wk += "<table cellspacing='1' cellpadding='0' width='346px'; style='margin-bottom:2px;'>";
                                wk += "<tr valign='top'>";
                            }

                            // 枠線作成
                            wk += "<td>";

                            data = baseUrl + "?code=";
                            // ②-2ラベル作成
                            data += generateKowakeCode(d);
                            data += baseLang;
                            wk += "<table style='font-size:9pt; font-family:SimHei; width:172px; border-top:1px solid black;border-bottom:1px solid black;border-left:1px solid black;border-right:1px solid black'>";

                            // 1行目（重ねラベル）
                            wk += "<tr>";
                            // 原料名
                            wk += "<td colspan='2'>";
                            wk += "<div style='overflow:hidden; height:7px; width:100%; border:solid 0px; padding-bottom:9px;padding-left:1px;'>";
                            wk += d.no_tonyu + " " + d.nm_hinmei;
                            wk += "</div>";
                            wk += "</td>";
                            wk += "</tr>";

                            // 2行目（重ねラベル）
                            wk += "<tr>";
                            // 重量
                            wk += "<td style='border:solid 0px; vertical-align: middle; padding-left:3px;'>";
                            if (kbnSeikiHasu == pageLangText.seikiHasuSeikiKbn.text) {
                                wk += kowakeLabelFormatNumber(d.set_wt_label_now) + d.nm_tani;
                            }
                            else {
                                // wk += d.set_wt_label_now + d.nm_tani_hasu
                                wk += kowakeLabelFormatNumber(d.set_wt_label_now) + d.nm_tani_hasu;
                            }
                            wk += "</td>";
                            // QRコード
                            wk += "<td style='text-align:center; border:solid 0px; padding-bottom:4px;'>";
                            wk += "<img style='' src='";
                            wk += data;
                            wk += "' width='38' height='38'/>";
                            wk += "</td>";
                            wk += "</tr>";
                            wk += "</table>";
                            wk += "</td>";

                            // 重ねラベル3つ表示の際のレイアウト調整
                            if (App.isNumeric(j) && (((j + 1) % 2 == 0) || (j + 1) == objlength)) {
                                if ((j + 1) == objlength && (j == 0 || ((j + 1) % 2 != 0))) {
                                    wk += "<td><table style='font-size:10pt; font-family:SimHei; width:172px; border:solid 0px;'></table></td>";
                                    wk += "</table>";
                                }
                                else {
                                    wk += "</table>";
                                }
                            }
                        }
                        wk += "</div>";
                        return wk;
                    }
                    }
                    else {
                        // 処理開始
                        var j = 0, // 重ねループ時に利用
                            d, // 一行ごとのデータ
                            baseUrl = "./QRCodeGererateHandler.ashx",
                            baseLang = "&lang=" + App.ui.page.lang,
                            kasaneHeader = ""; // 重ねで同じマークが5～8個ある場合に1枚目のヘッダを保持しておく

                        var wk = "";
                        if (isLast && objlength <= 4) {
                            //wk += "<div style='page-break-after:auto'>";
                        }
                        else {
                            //wk += "<div style='page-break-after:always'>";
                        }

                        // ラベルの作成 start
                        // ①代表ラベル分を作成
                        // ①-1表示する文言を作成
                        d = $.extend(true, {}, obj[j]);


                        wk += "<div style='float:left'>" + pageLangText.txt_kotei_label.text + d.no_kotei + "　　" + pageLangText.txt_kaisu_label.text + "：" + d.set_su_batch_now + " / " + d.set_su_batch_end + "</br>";
                        wk += d.no_lot_shikakari + " " + "</br>";
                        wk += d.dt_seizo + "</br>";
                        //wk += pageLangText.txt_kaisu_label.text + "：" + d.set_su_batch_now + " / " + d.set_su_batch_end + "</div>";
                        wk += "</div>";
                        //wk += "<div style='float:center'>";
                        wk += "<div style='float:center;margin-left:20px; display:inline;'>";
                        // ①-2ラベルの内容を作成
                        var data = baseUrl + "?code=";
                        // 代表ラベル用にデータを入替える
                        d.cd_hinmei = pageLangText.kasaneLabelCd.text;
                        d.cd_mark = "";
                        d["set_wt_label_now"] = d.set_gokei_kasane;
                        data += generateKowakeCode(d);
                        data += baseLang;
                        wk += "<img style='' src='" + data + "' width='60' height='60'/></div>";
                        wk += "<div style='clear:both'></div>";
                        wk += "<div style='position:relative;width: 360px;'>";
                        wk += "<hr>"
                        wk += "</div>";

                        // 重ねラベルヘッダ個所を保持
                        kasaneHeader = wk;

                        // ②各小分けラベルを作成
                        for (var j; j < objlength; j++) {
                            if (App.isNumeric(j) && (j != 0) && (j % 4 == 0)) {
                                // 4枚出力するごとに、改ページ判断
                                wk += "</div>";
                                wk += "<div style='width: 360px;'></div>"

                                //if (isLast && objlength - j <= 4) {
                                //    // 最終頁の場合は折り返しなし
                                //    wk += "<div style='page-break-after:auto'>";
                                //}
                                //else {
                                //    // 次ページもあるので折り返し
                                //    wk += "<div style='page-break-after:always; font-family: ＭＳ ゴシック; width: 355px; height: 350px;'>";
                                //}

                                // 後からソートするため、最終頁の判断をしない。
                                wk += "<div style='page-break-after:always; font-family: ＭＳ ゴシック; width: 355px; height: 350px;'>";

                                // 同一重ねラベルは8枚までなので、上の条件に関係なくヘッダを挿入
                                // 保持していた重ねヘッダを再度表示します。
                                wk += kasaneHeader;
                            }
                            // ②-1表示文言作成
                            d = obj[j];
                            //if (d.cd_mark == pageLangText.spiceMarkCode.text) {
                            //    d.nm_tani = pageLangText.gramText.text;
                            //}

                            wk += "<div style='width:210px; height:123px; line-height:105%'>";

                            if (kbnSeikiHasu == pageLangText.seikiHasuSeikiKbn.text) {
                                //wk += d.no_tonyu + "  " + d.nm_hinmei + "</br>" + d.set_wt_label_now + d.nm_tani;
                                wk += d.no_tonyu + "  " + d.nm_hinmei + "</br>" + kowakeLabelFormatNumber(d.set_wt_label_now) + d.nm_tani;
                            }
                            else {
                                //wk += d.no_tonyu + "  " + d.nm_hinmei + "</br>" + d.set_wt_label_now + d.nm_tani_hasu;
                                wk += d.no_tonyu + "  " + d.nm_hinmei + "</br>" + kowakeLabelFormatNumber(d.set_wt_label_now) + d.nm_tani_hasu;
                            }
                            //wk += d.no_tonyu + "  " + d.nm_hinmei + "</br>" + d.set_wt_label_now + d.nm_tani;
                            wk += "</br>";
                            data = baseUrl + "?code=";
                            // ②-2ラベル作成
                            data += generateKowakeCode(d);
                            data += baseLang;
                            wk += "<img style='' src='" + data + "' width='60' height='60'/></div>";
                            if (App.isNumeric(j) && (j + 1) != objlength // 最終行は不要
                                             && ((j + 1) % 2 == 0) // ２枚ごと 
                                             && ((j + 1) % 4 != 0)) {// ４枚目は不要
                                // 最終行、４枚目は不要
                                // 2枚出力するごとに、ラベルのfloatを左に寄せる
                                wk += "<div style='clear:both'></div>";
                            }
                        }
                        wk += "</div>";
                        // 処理終了
                        return wk;
                    }
                };

                //// ラベルの作成（個別）
                //var printKobetsuQR = function () {
                //    // ラベル内容
                //    var dt,
                //        wk,
                //        result = "";

                //    //ラベル並び替え用
                //    var labelarr = [];
                //    var labelcount = 0;

                //    //データ取り出し
                //    var printSeikiGrid = $("#dialog-list-seiki"),
                //        printHasuGrid = $("#dialog-list-hasu"),
                //        select = $("input:radio[name='seikihasuRadio']:checked").val(),
                //        setBairitsu,
                //        printGrid,
                //    // 現在どちらのグリッドを見ているか
                //        isSeiki = true;

                //    // 対象エリア選択
                //    if (select == "seiki") {
                //        printGrid = printSeikiGrid;
                //        setBairitsu = ritsuKeikaku;
                //        isSeiki = true;
                //    }
                //    else {
                //        printGrid = printHasuGrid;
                //        setBairitsu = ritsuHasu;
                //        isSeiki = false;
                //    }
                //    var cnt = printGrid.getGridParam("records"), //個別ラベルは一行
                //        name;
                //    // 重ねラベル考慮
                //    var mark,
                //        markKakunin,
                //        isKasane = false,
                //        isLast = false,
                //        selectRow,
                //        focusedRow = printGrid.getGridParam("selrow"),
                //        kasaneLoop = 0,
                //        kasaneGokei = 0,
                //        kasaneObj = {};

                //    // 選択した行が重ねマークの場合は、その始まりの重ねを取得する
                //    var clickmark = dialog_grid_seiki.getCell(focusedRow, "cd_mark"),
                //        comparemark,
                //        clickLineNo = focusedRow;
                //    // 重ねラベルかどうか、一行目ではないか
                //    if (parseFloat(pageLangText.kasane1MarkKbn.text) <= parseFloat(clickmark)
                //            && parseFloat(clickmark) <= parseFloat(pageLangText.kasane9MarkKbn.text)
                //            && focusedRow > 1) {
                //        for (var i = focusedRow; i > 0; i--) {
                //            comparemark = dialog_grid_seiki.getCell(i, "cd_mark");
                //            if (clickmark == comparemark) {
                //                clickLineNo = i;
                //                continue; // さらに一行前を確認
                //            }
                //            break;
                //        }
                //        // 重ねの始まりを取得
                //        focusedRow = clickLineNo;
                //    }

                //    // バッチループ開始
                //    var kaishiVal = parseInt($("#suKaishiBatch").val(), 10);
                //    var shuryuoVal = parseInt($("#suShuryoBatch").val(), 10);

                //    for (var i = kaishiVal; i <= shuryuoVal; i++) {

                //        // 選択行ごとのデータから、枚数を取得しループ
                //        //var selData = printGrid.getRowData(focusedRow);
                //        var selData = getRowAndBlankToZero(printGrid, focusedRow);
                //        // 正規端数値をセット
                //        if (select == "seiki") {
                //            //selData["su_nisugata_kowake"] = selData.su_nisugata_kowake_seiki;
                //            selData["su_nisugata_kowake"] = 0;
                //            selData["su_kowake1_kowake"] = selData.su_kowake1_kowake_seiki;
                //            selData["su_kowake2_kowake"] = selData.su_kowake2_kowake_seiki;
                //        }
                //        else {
                //            //selData["su_nisugata_kowake"] = selData.su_nisugata_kowake_hasu;
                //            selData["su_nisugata_kowake"] = 0;
                //            selData["su_kowake1_kowake"] = selData.su_kowake1_kowake_hasu;
                //            selData["su_kowake2_kowake"] = selData.su_kowake2_kowake_hasu;
                //        }

                //        var nisugataLabelCnt = parseInt(selData.su_nisugata_kowake, 10),
                //            kowake1LabelCnt = parseInt(selData.su_kowake1_kowake, 10),
                //            kowake2LabelCnt = parseInt(selData.su_kowake2_kowake, 10);
                //        // 枚数の計
                //        var loop = nisugataLabelCnt + kowake1LabelCnt + kowake2LabelCnt;

                //        // 枚数分のラベルを発行
                //        for (var j = 1; j <= loop; j++) {
                //            // ラベル作成
                //            for (var k = 1; k <= cnt; k++) {

                //                if (!kasaneLoop > 0) {
                //                    // 情報の設定：行データをまるごと取得
                //                    selectRow = focusedRow;
                //                    dt = selData;
                //                }
                //                else {
                //                    // 重ね対応
                //                    selectRow++;
                //                    dt = printGrid.getRowData(selectRow);
                //                }

                //                // 現在どの行を実施しているかをセット
                //                dt = setLabelSu(dt, nisugataLabelCnt, kowake1LabelCnt, kowake2LabelCnt, shuryuoVal, i, j, isSeiki);
                //                // 倍率セット
                //                dt["set_ritsu_bai"] = setBairitsu;
                //                if (version == pageLangText.kaigaiLabelFormatKbn.number) {
                //                    if (dt.nm_hinmei_ryaku == "") {
                //                        name = dt.nm_hinmei;
                //                    }
                //                    else {
                //                        name = dt.nm_hinmei_ryaku;
                //                    }
                //                }
                //                else {
                //                    name = dt.nm_hinmei;
                //                }
                //                mark = dt.cd_mark;

                //                // マークを判定し、重ね(1-9)か単体ラベルかを判断する
                //                // 重ねラベルのグループが取得できれば、重ねを発行する
                //                if (parseFloat(pageLangText.kasane1MarkKbn.text) <= parseFloat(mark)
                //                && parseFloat(mark) <= parseFloat(pageLangText.kasane9MarkKbn.text)) {
                //                    // マークセット
                //                    if (!kasaneLoop > 0) {
                //                        markKakunin = mark;
                //                    }
                //                    if (App.ifUndefOrNull(markKakunin) && mark == markKakunin) {
                //                        //kasaneObj[kasaneLoop] = dt;
                //                        //var wtHaigo = parseFloat(dt.set_wt_label_now),
                //                        //resultWtHaigo = "0.000";
                //                        //if (wtHaigo > 0) {
                //                            //resultWtHaigo = String(wtHaigo.toFixed(3));
                //                            //var splitWt = resultWtHaigo.split('.');
                //                            //splitWt[1] = fillZeroJuryo(splitWt[1], 3);  // 小数点以下は0で尻埋め
                //                            //resultWtHaigo = splitWt[0].slice(-3) + "." + splitWt[1];
                //                            //dt.set_wt_label_now = resultWtHaigo;
                //                        //}

                //                        dt.set_wt_label_now = kowakeLabelFormatNumber(dt.set_wt_label_now);

                //                        kasaneObj[kasaneLoop] = dt;
                //                        // 重ね合計を求める
                //                        kasaneGokei = parseFloat(kasaneGokei) + parseFloat(dt.set_wt_label_now)
                //                        kasaneLoop++;
                //                        markKakunin = mark;
                //                        if (k < cnt && selectRow != cnt) {
                //                            // 次の対象行がある場合は、ループを次に送る
                //                            // 個別ラベルの場合、最終行かどうかも判定
                //                            continue;
                //                        }
                //                    }
                //                }
                //                else if (kasaneLoop > 0) {
                //                    // 重ねグループの取得が終了したので、重ねラベル作成を指示
                //                    isKasane = true;
                //                    // 最終行でなければ、次のラベルを取得しているので、iを戻す
                //                    if (k < cnt) {
                //                        k--;
                //                    }
                //                }
                //                // 重ねグループの取得が終了したので、重ねラベル作成を指示
                //                if (!App.isUndefOrNull(kasaneObj[0])) {
                //                    isKasane = true;
                //                }

                //                if (parseFloat(pageLangText.spiceMarkCode.text) == parseFloat(mark)) {
                //                    // マークが「スパイス」の場合、1000倍する
                //                    //dt.set_wt_label_now = getJuryuMarkSpice(dt.set_wt_label_now);
                //                }
                //                else {
                //                    //var wtHaigo = parseFloat(dt.set_wt_label_now),
                //                        //resultWtHaigo = "0.000";
                //                    //if (wtHaigo > 0) {
                //                        //resultWtHaigo = String(wtHaigo.toFixed(3));
                //                        //var splitWt = resultWtHaigo.split('.');
                //                        //splitWt[1] = fillZeroJuryo(splitWt[1], 3);  // 小数点以下は0で尻埋め
                //                        //resultWtHaigo = splitWt[0] + "." + splitWt[1];
                //                        //resultWtHaigo = splitWt[0].slice(-3) + "." + splitWt[1];
                //                        //dt.set_wt_label_now = resultWtHaigo;
                //                    //}
                //                    dt.set_wt_label_now = kowakeLabelFormatNumber(dt.set_wt_label_now);
                //                }

                //                isLast = (i == shuryuoVal && j == loop) ? true : false;
                //                if (isKasane) {// 重ね判定
                //                    // 重ねラベル作成
                //                    kasaneObj[0]["set_gokei_kasane"] = kasaneGokei.toFixed(3);
                //                    wk = createKasanePrintArea(k, kasaneObj, kasaneLoop, isLast);
                //                    // 重ねが終わったことを指示
                //                    labelarr[labelcount] = [labelcount, wk, kasaneLoop];
                //                    labelcount = labelcount + 1;
                //                    kasaneObj = {};
                //                    kasaneLoop = 0;
                //                    kasaneGokei = 0;
                //                    isKasane = false;
                //                }
                //                else {
                //                    // 小分けラベル作成
                //                    wk = createKowakePrintArea(k, dt, name, isLast);
                //                    labelarr[labelcount] = [labelcount, wk, 0];
                //                    labelcount = labelcount + 1;
                //                    // 個別ラベルなので、１枚で処理を抜ける
                //                }
                //                result = result + wk;
                //                break;
                //            } // 行からのデータ取得終了
                //        } // 行に指定され枚数データ分
                //    } // バッチ数ループ終了


                //    // ラベル作成後にソートすることでpage-break-after:autoが最後にこない不具合に対応
                //    // allは使わず、常にalwaysで改行する。ソート後に最後のラベル情報のpage-break-afterをautoに修正する
                //    labelarr = convertPageBreakToAuto(labelarr);


                //    var labelresult = "";
                //    for (var lcnt = 0; lcnt < labelarr.length; lcnt++) {
                //        if (labelarr.length == 1 && labelarr[lcnt][2] > 4) {
                //            labelresult = labelresult + "<div style='page-break-after:always; font-family:ＭＳ ゴシック; width:355px; height:350px;'>";
                //        }
                //        else if (lcnt + 1 == labelarr.length && labelarr[lcnt][2] <= 4) {
                //            labelresult = labelresult + "<div style='page-break-after:auto; font-family:ＭＳ ゴシック; width:355px; height:350px;'>";
                //        }
                //        else {
                //            //labelresult = labelresult + "<div style='page-break-after:always; font-family:ＭＳ ゴシック; word-break:break-all;'>";
                //            labelresult = labelresult + "<div style='page-break-after:always; font-family:ＭＳ ゴシック; width:355px; height:350px;'>";
                //        }
                //        labelresult = labelresult + labelarr[lcnt][1];
                //    }
                //    //並び替えを行います ここまで

                //    return labelresult;
                //    //return result;
                //};

                // ラベルの作成(個別ラベル印刷[複数行選択対応])
                var printKobetsuQR = function () {
                    // ラベル内容
                    var dt,
                        wk,
                        seiki = 1,
                        hasu = 2,
                        printSeikiGrid = $("#dialog-list-seiki"),
                        printHasuGrid = $("#dialog-list-hasu"),
                        result = "";

                    //ラベル並び替え用
                    var labelarr = [];
                    var labelcount = 0;
                    var selRows;

                    // 正規選択行番号
                    var selRowsSeiki = printSeikiGrid.getGridParam('selarrrow');
                    var selRowsHasu = printHasuGrid.getGridParam('selarrrow');

                    //データ取り出し
                    var setBairitsu,
                        printGrid;
                    // バッチループ
                    var kaishiVal = parseInt($("#suKaishiBatch").val(), 10);
                    var shuryuoVal = parseInt($("#suShuryoBatch").val(), 10);

                    var select = $("input:radio[name='seikihasuRadio']:checked").val();

                    // 対象エリア選択
                    if (select == "seiki") {
                        printGrid = printSeikiGrid;
                        setBairitsu = ritsuKeikaku;
                        selRows = selRowsSeiki;
                    }
                    else {
                        printGrid = printHasuGrid;
                        setBairitsu = ritsuHasu;
                        selRows = selRowsHasu;
                    }

                    var cnt = printGrid.getGridParam("records"), //個別ラベルは一行
                        name;
                    var printLineSu = cnt;
                    for (var lcnt = 1; lcnt <= cnt; lcnt++) {
                        // 選択されていない行の場合は次に進む
                        if ($.inArray(lcnt.toString(), selRows) == -1) {
                            continue;
                        }
                        var lineData = getRowAndBlankToZero(printGrid, lcnt);
                        var lineLastData = getRowAndBlankToZero(printGrid, cnt);
                        var lineLastNi;
                        var lineLastKo1;
                        var lineLastKo2;
                        // 正規端数値をセット
                        if (select == "seiki") {
                            lineData["su_nisugata_kowake"] = lineData.su_nisugata_kowake_seiki;
                            lineData["su_kowake1_kowake"] = lineData.su_kowake1_kowake_seiki;
                            lineData["su_kowake2_kowake"] = lineData.su_kowake2_kowake_seiki;
                            lineLastNi = parseInt(lineLastData.su_nisugata_kowake_seiki, 10);
                            lineLastKo1 = parseInt(lineLastData.su_kowake1_kowake_seiki, 10);
                            lineLastKo2 = parseInt(lineLastData.su_kowake2_kowake_seiki, 10);
                            isSeiki = true;
                        }
                        else {
                            lineData["su_nisugata_kowake"] = lineData.su_nisugata_kowake_hasu;
                            lineData["su_kowake1_kowake"] = lineData.su_kowake1_kowake_hasu;
                            lineData["su_kowake2_kowake"] = lineData.su_kowake2_kowake_hasu;
                            lineLastNi = parseInt(lineLastData.su_nisugata_kowake_hasu, 10);
                            lineLastKo1 = parseInt(lineLastData.su_kowake1_kowake_hasu, 10);
                            lineLastKo2 = parseInt(lineLastData.su_kowake2_kowake_hasu, 10);
                            isSeiki = false;
                        }

                        // 枚数取り出し
                        var nisugataLabelCnt = parseInt(lineData.su_nisugata_kowake, 10),
                            kowake1LabelCnt = parseInt(lineData.su_kowake1_kowake, 10),
                            kowake2LabelCnt = parseInt(lineData.su_kowake2_kowake, 10);
                        if (kowake1LabelCnt == "0" && kowake2LabelCnt == "0") {
                            nisugataLabelCnt = 0;
                        }
                        if (lineLastKo1 == "0" && lineLastKo2 == "0") {
                            lineLastNi = 0;
                        }
                        var lineAll = 0 + lineLastKo1 + lineLastKo2;
                        // 枚数の計
                        var loop = 0 + kowake1LabelCnt + kowake2LabelCnt;
                        if (lineAll > 0) {
                            printLineSu = cnt;
                            break;
                        }
                    }
                    cnt = printLineSu;
                    // 重ねラベル考慮
                    var mark,
                    isKasane = false,
                    isLast = false,
                    kasaneLoop = 0,
                    kasaneGokei = 0,
                    kasaneObj = {},
                    isSeiki = true;
                    var kasaneKaiPage = 0;

                    // バッチループ開始
                    for (var i = kaishiVal; i <= shuryuoVal ; i++) {
                        kasaneLoop = 0;
                        var markKakunin = "";
                        // ラベル作成
                        for (var k = 1; k <= cnt; k++) {
                            // 選択されていない行の場合は次に進む
                            if ($.inArray(k.toString(), selRows) == -1) {
                                continue;
                            }
                            // 選択行ごとのデータから、枚数を取得しループ
                            var selData = getRowAndBlankToZero(printGrid, k);
                            // 重ねの場合、同一マークは次の行へ
                            if (parseFloat(pageLangText.kasane1MarkKbn.text) <= parseFloat(selData.cd_mark)
                                    && parseFloat(selData.cd_mark) <= parseFloat(pageLangText.kasane9MarkKbn.text)
                                    && markKakunin == selData.cd_mark) {
                                continue;
                            }
                            // 同じ重ねマークをスキップし切ってから初期化
                            markKakunin = "";
                            // 正規端数値をセット
                            if (select == "seiki") {
                                selData["su_nisugata_kowake"] = 0;
                                selData["su_kowake1_kowake"] = selData.su_kowake1_kowake_seiki;
                                selData["su_kowake2_kowake"] = selData.su_kowake2_kowake_seiki;
                                isSeiki = true;
                            }
                            else {
                                selData["su_nisugata_kowake"] = 0;
                                selData["su_kowake1_kowake"] = selData.su_kowake1_kowake_hasu;
                                selData["su_kowake2_kowake"] = selData.su_kowake2_kowake_hasu;
                                isSeiki = false;
                            }
                            // 枚数取り出し
                            nisugataLabelCnt = parseInt(selData.su_nisugata_kowake, 10);
                            kowake1LabelCnt = parseInt(selData.su_kowake1_kowake, 10);
                            kowake2LabelCnt = parseInt(selData.su_kowake2_kowake, 10);
                            // 枚数の計
                            loop = nisugataLabelCnt + kowake1LabelCnt + kowake2LabelCnt;
                            // 枚数分のラベルを発行
                            for (var j = 1; j <= loop; j++) {
                                /////////
                                for (var kasane = k; kasane <= cnt; kasane++) {
                                    if (!kasaneLoop > 0) {
                                        //行データをまるごと取得
                                        dt = selData;
                                    }
                                    else {
                                        // 重ね対応
                                        dt = printGrid.getRowData(kasane);
                                    }
                                    // 現在どの行を実施しているかをセット
                                    dt = setLabelSu(dt, nisugataLabelCnt, kowake1LabelCnt, kowake2LabelCnt, shuryuoVal, i, j, isSeiki);
                                    // 倍率セット
                                    dt["set_ritsu_bai"] = setBairitsu;
                                    if (version == pageLangText.kaigaiLabelFormatKbn.number) {
                                        if (dt.nm_hinmei_ryaku == "") {
                                            name = dt.nm_hinmei;
                                        }
                                        else {
                                            name = dt.nm_hinmei_ryaku;
                                        }
                                    }
                                    else {
                                        name = dt.nm_hinmei;
                                    }
                                    mark = dt.cd_mark;

                                    // マークを判定し、重ね(1-9)か単体ラベルかを判断する
                                    // 重ねラベルのグループが取得できれば、重ねを発行する
                                    if (parseFloat(pageLangText.kasane1MarkKbn.text) <= parseFloat(mark)
                                    && parseFloat(mark) <= parseFloat(pageLangText.kasane9MarkKbn.text)) {
                                        // マークセット
                                        if (!kasaneLoop > 0) {
                                            markKakunin = mark;
                                        }
                                        if (App.ifUndefOrNull(markKakunin) && mark == markKakunin) {
                                            dt.set_wt_label_now = kowakeLabelFormatNumber(dt.set_wt_label_now);
                                            kasaneObj[kasaneLoop] = dt;

                                            // 重ね合計を求める
                                            kasaneGokei = parseFloat(kasaneGokei) + parseFloat(dt.set_wt_label_now)
                                            kasaneLoop++;
                                            markKakunin = mark;
                                            if (kasane < cnt && kasane != cnt) {
                                                // 次の対象行がある場合は、ループを次に送る
                                                continue;
                                            }
                                        }
                                    }
                                    else if (kasaneLoop > 0) {
                                        // 重ねグループの取得が終了したので、重ねラベル作成を指示
                                        isKasane = true;
                                        // 最終行でなければ、次のラベルを取得しているので、iを戻す
                                        if (kasane < cnt) {
                                            kasane--;
                                        }
                                    }

                                    // 重ねグループの取得が終了したので、重ねラベル作成を指示
                                    if (!App.isUndefOrNull(kasaneObj[0])) {
                                        kasaneKaiPage = cnt - (kasaneLoop - 1);
                                        isKasane = true;
                                    }

                                    if (parseFloat(pageLangText.spiceMarkCode.text) == parseFloat(mark)) {
                                    }
                                    else {
                                        dt.set_wt_label_now = kowakeLabelFormatNumber(dt.set_wt_label_now);
                                    }

                                    // 改ページ判断
                                    isLast = (i == shuryuoVal && kasane == cnt && j == loop) ? true : false;

                                    // 以下のどれかに当てはまる場合、最終フラグをfalseに戻す
                                    // ・最終行の判断がされたが、現在見ているグリッドが正規で端数バッチ数が0以上の場合
                                    // ・最終行の判断がされたが、kとcntの値が違う かつ kとkasaneKaiPageの値が違う場合
                                    if ((isLast && isSeiki && batchHasu > 0) || (isLast && k != cnt && k != kasaneKaiPage)) {
                                        isLast = false;
                                    }

                                    if (isKasane) {// 重ね判定
                                        // 重ねラベル作成
                                        kasaneObj[0]["set_gokei_kasane"] = kasaneGokei.toFixed(3);
                                        wk = createKasanePrintArea(kasane, kasaneObj, kasaneLoop, isLast);
                                        // 重ねが終わったことを指示
                                        labelarr[labelcount] = [
                                            labelcount
                                            , wk
                                            , "zzzzzzzzzzzzzzz"
                                            , dt.no_kotei
                                            , kasaneObj[0]["no_tonyu"]
                                            , select
                                            , i
                                            , kasaneLoop
                                            , dt.set_su_label_now
                                            , dt.label_kowake
                                        ];
                                        labelcount = labelcount + 1;
                                        kasaneObj = {};
                                        kasaneLoop = 0;
                                        kasaneGokei = 0;
                                        isKasane = false;
                                        result = result + wk;
                                        break;
                                    }
                                    else {
                                        // 小分けラベル作成
                                        wk = createKowakePrintArea(kasane, dt, name, isLast);
                                        labelarr[labelcount] = [
                                            labelcount
                                            , wk
                                            , dt.cd_hinmei
                                            , dt.no_kotei
                                            , dt.no_tonyu
                                            , select
                                            , i
                                            , 0
                                            , dt.set_su_label_now
                                            , dt.label_kowake
                                        ];
                                        labelcount = labelcount + 1;
                                        result = result + wk;
                                        break;
                                    }
                                }
                            } // 行に指定され枚数データ分
                        } // 行からのデータ取得終了
                    } // バッチ数ループ終了

                    //並び替えを行います
                    // [2]原料コード＞[4]投入順＞[5]正規(1)/端数(2)＞[3]工程＞[6]バッチ数＞[7]重ね順＞[9]荷受or小分１or小分２＞[8]個数：すべて昇順
                    labelarr.sort(function (a, b) {
                        /// sortはアルファベット順でソートする関数。数値の大きさで比較しないため、
                        /// 拡張して直接比較する。aがbよりも小さい場合は-1を、aがbよりも大きいときは1を返却する。

                        // [2]原料コード
                        if (a[2] > b[2]) return 1;
                        if (a[2] < b[2]) return -1;
                        // [4]投入順
                        if (parseInt(a[4]) > parseInt(b[4])) return 1;
                        if (parseInt(a[4]) < parseInt(b[4])) return -1;
                        // [5]正規(1)/端数(2)
                        if (parseInt(a[5]) > parseInt(b[5])) return 1;
                        if (parseInt(a[5]) < parseInt(b[5])) return -1;
                        // [3]工程
                        if (parseInt(a[3]) > parseInt(b[3])) return 1;
                        if (parseInt(a[3]) < parseInt(b[3])) return -1;
                        // [6]バッチ数
                        if (parseInt(a[6]) > parseInt(b[6])) return 1;
                        if (parseInt(a[6]) < parseInt(b[6])) return -1;
                        // [9]荷受or小分１or小分２
                        if (parseInt(a[9]) > parseInt(b[9])) return 1;
                        if (parseInt(a[9]) < parseInt(b[9])) return -1;
                        // [8]個数
                        if (parseInt(a[8]) > parseInt(b[8])) return 1;
                        if (parseInt(a[8]) < parseInt(b[8])) return -1;
                        return 0;
                    });

                    // ラベル作成後にソートすることでpage-break-after:autoが最後にこない不具合に対応
                    // allは使わず、常にalwaysで改行する。ソート後に最後のラベル情報のpage-break-afterをautoに修正する
                    labelarr = convertPageBreakToAuto(labelarr);

                    var labelresult = "";
                    for (var lcnt = 0; lcnt < labelarr.length; lcnt++) {
                        if (labelarr.length == 1 && labelarr[lcnt][7] > 4) {
                            labelresult = labelresult + "<div style='page-break-after:always; font-family:ＭＳ ゴシック; width:360px;'>";
                        }
                        else if (lcnt + 1 == labelarr.length && labelarr[lcnt][7] <= 4) {
                            labelresult = labelresult + "<div style='page-break-after:auto; font-family:ＭＳ ゴシック; width:360px;'>";
                        }
                        else {
                            labelresult = labelresult + "<div style='page-break-after:always; font-family:ＭＳ ゴシック; width:360px;'>";
                        }
                        labelresult = labelresult + labelarr[lcnt][1];
                    }
                    //並び替えを行います ここまで

                    return labelresult;
                };

                // ラベルの作成(全ラベル印刷)
                var printQR = function () {
                    // ラベル内容
                    var dt,
                        wk,
                        seiki = 1,
                        hasu = 2,
                        printSeikiGrid = $("#dialog-list-seiki"),
                        printHasuGrid = $("#dialog-list-hasu"),
                        result = "";

                    //ラベル並び替え用
                    var labelarr = [];
                    var labelcount = 0;

                    // 全ラベルを印刷するので、正規/端数のループを回す
                    for (var all = seiki; all <= hasu; all++) {
                        //データ取り出し
                        var setBairitsu,
                            printGrid;
                        // バッチループ
                        var kaishiVal = 1, // 固定
                            shuryuoVal;
                        // 対象エリア選択
                        if (all == seiki) {
                            printGrid = printSeikiGrid;
                            setBairitsu = ritsuKeikaku;
                            shuryuoVal = batchKeikaku;
                        }
                        else {
                            printGrid = printHasuGrid;
                            setBairitsu = ritsuHasu;
                            shuryuoVal = batchHasu;
                        }
                        var cnt = printGrid.getGridParam("records"), //個別ラベルは一行
                            name;
                        //var printLineSu = cnt + 1;
                        var printLineSu = cnt;
                        for (var lcnt = 1; lcnt <= cnt; lcnt++) {
                            //var lineData = printGrid.getRowData(lcnt);
                            var lineData = getRowAndBlankToZero(printGrid, lcnt);
                            //var lineLastData = printGrid.getRowData(cnt);
                            var lineLastData = getRowAndBlankToZero(printGrid, cnt);
                            var lineLastNi;
                            var lineLastKo1;
                            var lineLastKo2;
                            // 正規端数値をセット
                            if (all == seiki) {
                                lineData["su_nisugata_kowake"] = lineData.su_nisugata_kowake_seiki;
                                lineData["su_kowake1_kowake"] = lineData.su_kowake1_kowake_seiki;
                                lineData["su_kowake2_kowake"] = lineData.su_kowake2_kowake_seiki;
                                lineLastNi = parseInt(lineLastData.su_nisugata_kowake_seiki, 10);
                                lineLastKo1 = parseInt(lineLastData.su_kowake1_kowake_seiki, 10);
                                lineLastKo2 = parseInt(lineLastData.su_kowake2_kowake_seiki, 10);
                                isSeiki = true;
                            }
                            else {
                                lineData["su_nisugata_kowake"] = lineData.su_nisugata_kowake_hasu;
                                lineData["su_kowake1_kowake"] = lineData.su_kowake1_kowake_hasu;
                                lineData["su_kowake2_kowake"] = lineData.su_kowake2_kowake_hasu;
                                lineLastNi = parseInt(lineLastData.su_nisugata_kowake_hasu, 10);
                                lineLastKo1 = parseInt(lineLastData.su_kowake1_kowake_hasu, 10);
                                lineLastKo2 = parseInt(lineLastData.su_kowake2_kowake_hasu, 10);
                                isSeiki = false;
                            }
                            // 枚数取り出し
                            var nisugataLabelCnt = parseInt(lineData.su_nisugata_kowake, 10),
                                kowake1LabelCnt = parseInt(lineData.su_kowake1_kowake, 10),
                                kowake2LabelCnt = parseInt(lineData.su_kowake2_kowake, 10);
                            if (kowake1LabelCnt == "0" && kowake2LabelCnt == "0") {
                                nisugataLabelCnt = 0;
                            }
                            if (lineLastKo1 == "0" && lineLastKo2 == "0") {
                                lineLastNi = 0;
                            }
                            //var lineAll = lineLastNi + lineLastKo1 + lineLastKo2;
                            var lineAll = 0 + lineLastKo1 + lineLastKo2;
                            // 枚数の計
                            //var loop = nisugataLabelCnt + kowake1LabelCnt + kowake2LabelCnt;
                            var loop = 0 + kowake1LabelCnt + kowake2LabelCnt;
                            if (lineAll > 0) {
                                printLineSu = cnt;
                                break;
                            }
                            /*
                            if (loop <= 0) {
                            printLineSu = printLineSu - 1;
                            }
                            */
                        }
                        cnt = printLineSu;
                        // 重ねラベル考慮
                        var mark,
                        //markKakunin = "",
                        isKasane = false,
                        isLast = false,
                        kasaneLoop = 0,
                        kasaneGokei = 0,
                        kasaneObj = {},
                        isSeiki = true;
                        var kasaneKaiPage = 0;

                        // バッチループ開始
                        for (var i = kaishiVal; i <= parseInt(shuryuoVal) ; i++) {
                            kasaneLoop = 0;
                            var markKakunin = "";
                            // ラベル作成
                            for (var k = 1; k <= cnt; k++) {
                                // 選択行ごとのデータから、枚数を取得しループ
                                //var selData = printGrid.getRowData(k);
                                var selData = getRowAndBlankToZero(printGrid, k);
                                /*
                                // 荷姿原料の判別
                                if (all == seiki) {
                                if (selData.su_kowake1_kowake_seiki == "0" && selData.su_kowake2_kowake_seiki == "0") {
                                continue;
                                }
                                }
                                else {
                                if (selData.su_kowake1_kowake_hasu == "0" && selData.su_kowake2_kowake_hasu == "0") {
                                continue;
                                }
                                }
                                */
                                // 重ねの場合、同一マークは次の行へ
                                if (parseFloat(pageLangText.kasane1MarkKbn.text) <= parseFloat(selData.cd_mark)
                                        && parseFloat(selData.cd_mark) <= parseFloat(pageLangText.kasane9MarkKbn.text)
                                        && markKakunin == selData.cd_mark) {
                                    continue;
                                }
                                // 同じ重ねマークをスキップし切ってから初期化
                                markKakunin = "";

                                // 重ねラベル用設定
                                //var kasane = k;

                                // 正規端数値をセット
                                if (all == seiki) {
                                    //selData["su_nisugata_kowake"] = selData.su_nisugata_kowake_seiki;
                                    selData["su_nisugata_kowake"] = 0;
                                    selData["su_kowake1_kowake"] = selData.su_kowake1_kowake_seiki;
                                    selData["su_kowake2_kowake"] = selData.su_kowake2_kowake_seiki;
                                    isSeiki = true;
                                }
                                else {
                                    //selData["su_nisugata_kowake"] = selData.su_nisugata_kowake_hasu;
                                    selData["su_nisugata_kowake"] = 0;
                                    selData["su_kowake1_kowake"] = selData.su_kowake1_kowake_hasu;
                                    selData["su_kowake2_kowake"] = selData.su_kowake2_kowake_hasu;
                                    isSeiki = false;
                                }
                                // 枚数取り出し
                                //var nisugataLabelCnt = parseInt(selData.su_nisugata_kowake, 10),
                                //kowake1LabelCnt = parseInt(selData.su_kowake1_kowake, 10),
                                //kowake2LabelCnt = parseInt(selData.su_kowake2_kowake, 10);
                                nisugataLabelCnt = parseInt(selData.su_nisugata_kowake, 10);
                                kowake1LabelCnt = parseInt(selData.su_kowake1_kowake, 10);
                                kowake2LabelCnt = parseInt(selData.su_kowake2_kowake, 10);
                                // 枚数の計
                                //var loop = nisugataLabelCnt + kowake1LabelCnt + kowake2LabelCnt;
                                loop = nisugataLabelCnt + kowake1LabelCnt + kowake2LabelCnt;
                                // 枚数分のラベルを発行
                                for (var j = 1; j <= loop; j++) {
                                    /////////
                                    for (var kasane = k; kasane <= cnt; kasane++) {
                                        if (!kasaneLoop > 0) {
                                            //行データをまるごと取得
                                            //kasane = k;
                                            dt = selData;
                                            //dt = printGrid.getRowData(kasane);
                                        }
                                        else {
                                            // 重ね対応
                                            dt = printGrid.getRowData(kasane);
                                        }
                                        // 現在どの行を実施しているかをセット
                                        dt = setLabelSu(dt, nisugataLabelCnt, kowake1LabelCnt, kowake2LabelCnt, shuryuoVal, i, j, isSeiki);
                                        // 倍率セット
                                        dt["set_ritsu_bai"] = setBairitsu;
                                        if (version == pageLangText.kaigaiLabelFormatKbn.number) {
                                            if (dt.nm_hinmei_ryaku == "") {
                                                name = dt.nm_hinmei;
                                            }
                                            else {
                                                name = dt.nm_hinmei_ryaku;
                                            }
                                        }
                                        else {
                                            name = dt.nm_hinmei;
                                        }
                                        mark = dt.cd_mark;

                                        // マークを判定し、重ね(1-9)か単体ラベルかを判断する
                                        // 重ねラベルのグループが取得できれば、重ねを発行する
                                        if (parseFloat(pageLangText.kasane1MarkKbn.text) <= parseFloat(mark)
                                        && parseFloat(mark) <= parseFloat(pageLangText.kasane9MarkKbn.text)) {
                                            // マークセット
                                            if (!kasaneLoop > 0) {
                                                markKakunin = mark;
                                            }
                                            if (App.ifUndefOrNull(markKakunin) && mark == markKakunin) {
                                                //kasaneObj[kasaneLoop] = dt;
                                                /*
                                                var wtHaigo = parseFloat(dt.set_wt_label_now),
                                                resultWtHaigo = "0.000";
                                                if (wtHaigo > 0) {
                                                    resultWtHaigo = String(wtHaigo.toFixed(3));
                                                    var splitWt = resultWtHaigo.split('.');
                                                    splitWt[1] = fillZeroJuryo(splitWt[1], 3);  // 小数点以下は0で尻埋め
                                                    resultWtHaigo = splitWt[0].slice(-3) + "." + splitWt[1];
                                                    dt.set_wt_label_now = resultWtHaigo;
                                                }
                                                */
                                                dt.set_wt_label_now = kowakeLabelFormatNumber(dt.set_wt_label_now);
                                                kasaneObj[kasaneLoop] = dt;

                                                // 重ね合計を求める
                                                kasaneGokei = parseFloat(kasaneGokei) + parseFloat(dt.set_wt_label_now)
                                                kasaneLoop++;
                                                markKakunin = mark;
                                                if (kasane < cnt && kasane != cnt) {
                                                    // 次の対象行がある場合は、ループを次に送る
                                                    continue;
                                                }
                                            }
                                        }
                                        else if (kasaneLoop > 0) {
                                            // 重ねグループの取得が終了したので、重ねラベル作成を指示
                                            isKasane = true;
                                            // 最終行でなければ、次のラベルを取得しているので、iを戻す
                                            if (kasane < cnt) {
                                                kasane--;
                                            }
                                        }

                                        // 重ねグループの取得が終了したので、重ねラベル作成を指示
                                        if (!App.isUndefOrNull(kasaneObj[0])) {
                                            kasaneKaiPage = cnt - (kasaneLoop - 1);
                                            isKasane = true;
                                        }

                                        if (parseFloat(pageLangText.spiceMarkCode.text) == parseFloat(mark)) {
                                            // マークが「スパイス」の場合、1000倍する
                                            //dt.set_wt_label_now = getJuryuMarkSpice(dt.set_wt_label_now);
                                        }
                                        else {
                                            /*
                                            var wtHaigo = parseFloat(dt.set_wt_label_now),
                                                resultWtHaigo = "0.000";
                                            if (wtHaigo > 0) {
                                                resultWtHaigo = String(wtHaigo.toFixed(3));
                                                var splitWt = resultWtHaigo.split('.');
                                                splitWt[1] = fillZeroJuryo(splitWt[1], 3);  // 小数点以下は0で尻埋め
                                                //resultWtHaigo = splitWt[0] + "." + splitWt[1];
                                                resultWtHaigo = splitWt[0].slice(-3) + "." + splitWt[1];
                                                dt.set_wt_label_now = resultWtHaigo;
                                            }
                                            */
                                            dt.set_wt_label_now = kowakeLabelFormatNumber(dt.set_wt_label_now);
                                        }

                                        // 改ページ判断
                                        isLast = (i == shuryuoVal && kasane == cnt && j == loop) ? true : false;
                                        //isLast = ((i == shuryuoVal && j == loop) || kasane == cnt) ? true : false;

                                        // 以下のどれかに当てはまる場合、最終フラグをfalseに戻す
                                        // ・最終行の判断がされたが、現在見ているグリッドが正規で端数バッチ数が0以上の場合
                                        // ・最終行の判断がされたが、kとcntの値が違う かつ kとkasaneKaiPageの値が違う場合
                                        if ((isLast && isSeiki && batchHasu > 0) || (isLast && k != cnt && k != kasaneKaiPage)) {
                                            isLast = false;
                                        }

                                        if (isKasane) {// 重ね判定
                                            // 重ねラベル作成
                                            kasaneObj[0]["set_gokei_kasane"] = kasaneGokei.toFixed(3);
                                            wk = createKasanePrintArea(kasane, kasaneObj, kasaneLoop, isLast);
                                            // 重ねが終わったことを指示
                                            labelarr[labelcount] = [
                                                labelcount
                                                , wk
                                                , "zzzzzzzzzzzzzzz"
                                                , dt.no_kotei
                                                , kasaneObj[0]["no_tonyu"]
                                                , all
                                                , i
                                                , kasaneLoop
                                                , dt.set_su_label_now
                                                , dt.label_kowake
                                            ];
                                            labelcount = labelcount + 1;
                                            kasaneObj = {};
                                            kasaneLoop = 0;
                                            kasaneGokei = 0;
                                            isKasane = false;
                                            result = result + wk;
                                            break;
                                        }
                                        else {
                                            // 小分けラベル作成
                                            wk = createKowakePrintArea(kasane, dt, name, isLast);
                                            labelarr[labelcount] = [
                                                labelcount
                                                , wk
                                                , dt.cd_hinmei
                                                , dt.no_kotei
                                                , dt.no_tonyu
                                                , all
                                                , i
                                                , 0
                                                , dt.set_su_label_now
                                                , dt.label_kowake
                                            ];
                                            labelcount = labelcount + 1;
                                            result = result + wk;
                                            break;
                                        }
                                        //result = result + wk;
                                        //break;
                                    }
                                } // 行に指定され枚数データ分
                            } // 行からのデータ取得終了
                        } // バッチ数ループ終了
                    } // 正規端数ループ終了


                    //並び替えを行います
                    /*
                    labelarr.sort(function (a, b) {
                    if (a[2] > b[2]) return 1;
                    if (a[2] < b[2]) return -1;
                    if (parseInt(a[5]) > parseInt(b[5])) return 1;
                    if (parseInt(a[5]) < parseInt(b[5])) return -1;
                    if (parseInt(a[3]) > parseInt(b[3])) return 1;
                    if (parseInt(a[3]) < parseInt(b[3])) return -1;
                    if (parseInt(a[4]) > parseInt(b[4])) return 1;
                    if (parseInt(a[4]) < parseInt(b[4])) return -1;
                    return 0;
                    });
                    */
                    // [2]原料コード＞[4]投入順＞[5]正規(1)/端数(2)＞[3]工程＞[6]バッチ数＞[7]重ね順＞[9]荷受or小分１or小分２＞[8]個数：すべて昇順
                    labelarr.sort(function (a, b) {
                        /// sortはアルファベット順でソートする関数。数値の大きさで比較しないため、
                        /// 拡張して直接比較する。aがbよりも小さい場合は-1を、aがbよりも大きいときは1を返却する。

                        // [2]原料コード
                        if (a[2] > b[2]) return 1;
                        if (a[2] < b[2]) return -1;
                        // [4]投入順
                        if (parseInt(a[4]) > parseInt(b[4])) return 1;
                        if (parseInt(a[4]) < parseInt(b[4])) return -1;
                        // [5]正規(1)/端数(2)
                        if (parseInt(a[5]) > parseInt(b[5])) return 1;
                        if (parseInt(a[5]) < parseInt(b[5])) return -1;
                        // [3]工程
                        if (parseInt(a[3]) > parseInt(b[3])) return 1;
                        if (parseInt(a[3]) < parseInt(b[3])) return -1;
                        // [6]バッチ数
                        if (parseInt(a[6]) > parseInt(b[6])) return 1;
                        if (parseInt(a[6]) < parseInt(b[6])) return -1;
                        // [9]荷受or小分１or小分２
                        if (parseInt(a[9]) > parseInt(b[9])) return 1;
                        if (parseInt(a[9]) < parseInt(b[9])) return -1;
                        // [8]個数
                        if (parseInt(a[8]) > parseInt(b[8])) return 1;
                        if (parseInt(a[8]) < parseInt(b[8])) return -1;
                        return 0;
                    });

                    // ラベル作成後にソートすることでpage-break-after:autoが最後にこない不具合に対応
                    // allは使わず、常にalwaysで改行する。ソート後に最後のラベル情報のpage-break-afterをautoに修正する
                    labelarr = convertPageBreakToAuto(labelarr);

                    var labelresult = "";
                    for (var lcnt = 0; lcnt < labelarr.length; lcnt++) {
                        if (labelarr.length == 1 && labelarr[lcnt][7] > 4) {
                            labelresult = labelresult + "<div style='page-break-after:always; font-family:ＭＳ ゴシック; width:360px;'>";
                        }
                        else if (lcnt + 1 == labelarr.length && labelarr[lcnt][7] <= 4) {
                            labelresult = labelresult + "<div style='page-break-after:auto; font-family:ＭＳ ゴシック; width:360px;'>";
                        }
                        else {
                            labelresult = labelresult + "<div style='page-break-after:always; font-family:ＭＳ ゴシック; width:360px;'>";
                        }
                        labelresult = labelresult + labelarr[lcnt][1];
                    }
                    //並び替えを行います ここまで

                    return labelresult;
                    //return result;
                };

                /// <summary>ソート後に実行することで、一番最後の頁切替をalwaysからautoに変更します。</summary>
                /// <param name="pLabelArr">ラベル情報配列</param>
                /// <return>ラベル情報配列</return>
                var convertPageBreakToAuto = function (pLabelArr) {
                    // ラベル作成後にソートすることでpage-break-after:autoが最後にこない不具合に対応
                    // allは使わず、常にalwaysで改行する。ソート後に最後のラベル情報のpage-break-afterをautoに修正する
                    if (pLabelArr.length > 0) {
                        var tLen = pLabelArr.length - 1,
                            targetLabel = pLabelArr[tLen][1];

                        targetLabel = targetLabel.replace("page-break-after:always", "page-break-after:auto");

                        pLabelArr[tLen][1] = targetLabel;
                    }

                    return pLabelArr;
                }

                // ラベル出力用の処理数をセット
                var setLabelSu = function (dt, nisugata, kowake1, kowake2, batchEnd, batchNow, kosuNow, isSeiki) {
                    // バッチの回数をセット
                    //dt["set_su_batch_end"] = batchEnd;
                    //dt["set_su_batch_now"] = batchNow;

                    // ラベルの回数、利用する風袋、重量をセット
                    var now,
                        end,
                        futaiCode = "",
                        futaiName = "",
                        wt_label_now = "",
                        seikihasuText;
                    var totalBatch = 0;

                    if (isSeiki) {
                        seikihasuText = "_seiki"
                        kbnSeikiHasu = pageLangText.seikiHasuSeikiKbn.text;
                        totalBatch = $("#batchSeiki").text();
                    }
                    else {
                        seikihasuText = "_hasu"
                        kbnSeikiHasu = pageLangText.seikiHasuHasuKbn.text;
                        totalBatch = $("#batchHasu").text();
                    }

                    // バッチの回数をセット
                    dt["set_su_batch_end"] = totalBatch;
                    dt["set_su_batch_now"] = batchNow;

                    // 判定
                    if (kosuNow <= nisugata) {
                        // 荷姿
                        end = nisugata;
                        now = kosuNow;
                        futaiCode = pageLangText.nisugataFutaiCode.text;
                        futaiName = pageLangText.nm_nisugata_dlg.text;
                        wt_label_now = dt.wt_nisugata;
                        dt["label_kowake"] = 0;    // ソート用
                    }
                    else if (kosuNow - nisugata <= kowake1) {
                        // 小分け１
                        end = kowake1;
                        now = kosuNow - nisugata;
                        futaiCode = dt["cd_futai1" + seikihasuText];
                        futaiName = dt["nm_futai1" + seikihasuText];
                        wt_label_now = dt["wt_kowake1" + seikihasuText];
                        dt.su_batch_keikaku_hasu = "0";
                        dt["label_kowake"] = 1;    // ソート用
                    }
                    else {
                        // 小分け２
                        end = kowake2;
                        now = kosuNow - nisugata - kowake1;
                        futaiCode = dt["cd_futai2" + seikihasuText];
                        futaiName = dt["nm_futai2" + seikihasuText];
                        wt_label_now = dt["wt_kowake2" + seikihasuText];
                        dt.su_batch_keikaku_hasu = "1";
                        dt["label_kowake"] = 2;    // ソート用
                    }

                    // 現在の行の可変値をセット
                    dt["set_su_label_now"] = now;
                    dt["set_su_label_end"] = end;
                    dt["set_cd_futai_now"] = futaiCode;
                    dt["set_nm_futai_now"] = futaiName;
                    //dt["set_wt_label_now"] = parseFloat(wt_label_now).toFixed(3);
                    dt["set_wt_label_now"] = wt_label_now + ""; // stringにするために空文字を足す
                    return dt;
                };

                var isGreaterThan = function (val) {
                    // 値比較する
                    var kaishiVal = $("#suKaishiBatch").val();
                    if (App.isUndefOrNull(kaishiVal) || (!App.isNumeric(kaishiVal))) {
                        // 開始側のバリデーションでエラーになるのでリターン
                        return true;
                    }

                    // バッチ指定回数より数が少ないか（正規端数で切分け）
                    var max;
                    if ("seiki" == $("input:radio[name='seikihasuRadio']:checked").val()) {
                        max = batchKeikaku;
                    }
                    else {
                        max = batchHasu;
                    }

                    // 指定回数より多いか
                    if (parseInt(val, 10) > parseInt(max, 10)) {
                        return false;
                    }

                    // 終了バッチ数の方が大きいか
                    if (parseInt(val, 10) < parseInt(kaishiVal, 10)) {
                        return false;
                    }

                    return true;
                };

                validationSetting.suShuryoBatch.rules.custom = function (value) {
                    return isGreaterThan(value);
                };

                /// <summary>再起動時にダイアログを開きます。</summary>
                this.reopen = function (option) {
                    //dialogNotifyInfo.clear();
                    //dialogNotifyAlert.clear();
                    clearStateDialog();
                    // ブロックUIを閉じる
                    App.ui.block.close(".part-grid-up");
                    App.ui.block.close(".part-grid-down");
                    // 印刷区分
                    isLabelPrintEnd = true;
                    // 引数受け取り
                    shikakariLot = option.param1;
                    lineName = option.param2,
                    haigoName = option.param3,
                    shikomiRyo = option.param4,
                    ritsuKeikaku = option.param5,
                    ritsuHasu = option.param6,
                    batchKeikaku = option.param7,
                    batchHasu = option.param8;
                    haigoCode = option.param9;

                    searchItemsDialog(new queryDialog());
                };

                /// <summary>画面起動時にダイアログを開きます。</summary>
                var open = function () {
                    searchItemsDialog(new queryDialog());
                };
                open();

                //正規端数ラジオボタンの作成
                $(function () {
                    $("#label-hakko").buttonset();
                });

                $('input[name="seikihasuRadio"]:radio').change(function () {
                    var id = $(this).val();
                    if (id == "seiki") {
                        App.ui.block.close(".part-grid-up");
                        App.ui.block.close(".part-grid-down");
                        App.ui.block.show(".part-grid-down");
                    }
                    else {
                        App.ui.block.close(".part-grid-down");
                        App.ui.block.close(".part-grid-up");
                        App.ui.block.show(".part-grid-up");
                    }
                });

                //グリッド表示ラジオボタンの作成
                $(function () {
                    $("#grid-view").buttonset();
                });

                $('input[name="gridViewRadio"]:radio').change(function () {
                    var status = $(this).val();
                    switch (status) {
                        case "default":
                            // 正規端数を表示する
                            resizeContentsDialog(); //リサイズ
                            dialog_grid_seiki.jqGrid('setGridState', 'visible'); //grid表示
                            dialog_grid_hasu.jqGrid('setGridState', 'visible'); //grid表示
                            $("#seiki-button").show('nomal'); //ボタン表示
                            $("#hasu-button").show('nomal'); //ボタン表示
                            $("#radio-seiki").prop("checked", true); //チェックボックスを正規にする
                            //$("#label-hakko input").button("enable");
                            App.ui.block.close(".part-grid-up");
                            App.ui.block.close(".part-grid-down");
                            App.ui.block.show(".part-grid-down");
                            $("#radio-seiki").click();
                            break;
                        case "seikiGrid":
                            // 正規を表示する
                            $("#radio-seiki").prop("checked", true); //チェックボックスを正規にする
                            $("#radio-seiki").click();
                            dialog_grid_hasu.jqGrid('setGridState', 'hidden');
                            resizeContentsDialog();
                            dialog_grid_seiki.jqGrid('setGridState', 'visible');
                            App.ui.block.close(".part-grid-up");
                            App.ui.block.close(".part-grid-down");
                            //$("#label-hakko input").button("disable");
                            break;
                        case "hasuGrid":
                            // 端数を表示する
                            $("#radio-hasu").prop("checked", true); //チェックボックスを正規にする
                            $("#radio-hasu").click();
                            resizeContentsDialog();
                            dialog_grid_seiki.jqGrid('setGridState', 'hidden');
                            dialog_grid_hasu.jqGrid('setGridState', 'visible');
                            App.ui.block.close(".part-grid-up");
                            App.ui.block.close(".part-grid-down");
                            //$("#label-hakko input").button("disable");
                            break;
                    }
                });

                /// <summary>コンテンツのリサイズを行います。</summary>
                var resizeContentsDialog = function (e) {
                    var status = $('input[name="gridViewRadio"]:checked').val();
                    var resultPart = $(".dialog-result-list"),
                        container = $(".content-container");

                    resultPartHeader = resultPart.find(".part-header"),
                    resultPartCommands = resultPart.find(".item-command"),
                    resultPartStyle = resultPart[0].currentStyle || document.defaultView.getComputedStyle(resultPart[0], "");

                    dialog_grid_seiki.jqGrid('setGridWidth', $("#grid-seiki").width(), false); //gridの横幅制御
                    dialog_grid_hasu.jqGrid('setGridWidth', $("#grid-hasu").width(), false);

                    switch (status) {
                        case "default": // 両方表示した場合のリサイズ
                            var resultHight = $(".seiki-area").height() + $(".hasu-area").height();
                            var gridHeight = resultHight / 2;
                            $(".hasu-area").height(gridHeight);
                            $(".seiki-area").height(gridHeight);
                            dialog_grid_seiki.setGridHeight(gridHeight - 30);
                            dialog_grid_hasu.setGridHeight(gridHeight - 30);
                            break;
                        case "seikiGrid": // 正規のリサイズ
                            // リザルトパートの高さから端数グリッドエリア（５０）を引いた分を表示
                            var resultHight = $(".seiki-area").height() + $(".hasu-area").height() - 50;
                            $(".hasu-area").height(50);
                            $(".seiki-area").height(resultHight);
                            dialog_grid_seiki.setGridHeight(resultHight - 35);
                            dialog_grid_hasu.setGridHeight(resultHight - 35);
                            break;
                        case "hasuGrid": //　端数のリサイズ
                            // リザルトパートの高さから正規グリッドエリア（５０）を引いた分を表示
                            var resultHight = $(".seiki-area").height() + $(".hasu-area").height() - 50;
                            $(".hasu-area").height(resultHight);
                            $(".seiki-area").height(50);
                            dialog_grid_hasu.setGridHeight(resultHight - 35);
                            dialog_grid_seiki.setGridHeight(resultHight - 35);
                            break;
                    }
                };

                /// <summary>行データを取得する。</summary>
                /// <summary>取得した行データの小分重量１と小分重量２がブランクの場合に0を設定する。</summary>
                /// <param name="printGrid">正規または端数グリット</param>
                /// <param name="rowId">行ID</param>
                /// <return>行データ</return>
                var getRowAndBlankToZero = function (printGrid, rowId) {

                    // 行データを取得する。
                    var dt = printGrid.getRowData(rowId);

                    // 小分数１(正規)がブランクの場合
                    if (dt.su_kowake1_kowake_seiki == " ") {
                        dt.su_kowake1_kowake_seiki = 0;
                    }

                    // 小分数１(端数)がブランクの場合
                    if (dt.su_kowake1_kowake_hasu == " ") {
                        dt.su_kowake1_kowake_hasu = 0;

                    }

                    // 小分数２(正規)がブランクの場合
                    if (dt.su_kowake2_kowake_seiki == " ") {
                        dt.su_kowake2_kowake_seiki = 0;

                    }

                    // 小分数２(端数)がブランクの場合
                    if (dt.su_kowake2_kowake_hasu == " ") {
                        dt.su_kowake2_kowake_hasu = 0;
                    }
                    return dt;
                };

                /// <summary>画面リサイズ時のイベント処理を行います。</summary>
                $(App.ui.page).on("resized", resizeContentsDialog);

                /// <summary>少数桁の変更を行います。</summary>
                var kowakeLabelFormatNumber = function (value) {

                    // 引数は文字列でくるのでfloatに変換
                    var iValue = parseFloat(value);

                    //var handred = pageLangText.systemValueHundred.number;
                    //var result = null;
                    var splitWt;

                    if (iValue > 0) {

                        // QBの場合
                        if (ketaShosuten == pageLangText.ketaShosuten2.number) {

                            //var tempVal = Math.round(iValue * 100000) / 1000;
                            //result = Math.round(tempVal) / handred;
                            //result = result.toFixed(2);
                            //return result;
                            var result = "0.00";
                            result = String(iValue.toFixed(2));
                            splitWt = result.split('.');
                            splitWt[1] = fillZeroJuryo(splitWt[1], 2);
                            result = splitWt[0].slice(-3) + "." + splitWt[1];
                        }
                            // QBでない場合
                        else {

                            //result = iValue.toFixed(3);
                            //return result;
                            var result = "0.000";
                            result = String(iValue.toFixed(3));
							//TOsVN 17035 nt.toan 2023/03/16(Support #525 Displaying decimals on Label print dialog) Start -->
                            if (result < String(iValue)) {
                                result = String(parseFloat(result) + 0.001);
                            }
							//TOsVN 17035 nt.toan2023/03/16(Support #525 Displaying decimals on Label print dialog) End -->
                            splitWt = result.split('.');
                            splitWt[1] = fillZeroJuryo(splitWt[1], 3);
                            result = splitWt[0].slice(-3) + "." + splitWt[1];
                        }
                    }
                    return result;
                };
            }
        });
    </script>
</head>
<body>
    <!-- ダイアログ固有のデザイン -- Start -->
    <div class="dialog-content-label">
        <!-- TODO: 画面の仕様に応じて以下のダイアログの設定を変更してください。 -->
        <div class="dialog-header">
            <h4 data-app-text="labelinsatsuDialog">
            </h4>
        </div>
        <div class="dialog-body" style="padding: 10px; width: 95%;">
            <div class="dialog-search-criteria">
				<ul class="item-list item-list-left">
                <li>
                    <label>
				    	<span class="item-label-head" data-app-text="seizoLineName"></span>
                        <span id="selectLineName"></span>
                    </label>
                <br/>
                
                    <label>
                        <span class="item-label-head" data-app-text="haigoName"></span>
				        <span id="selectHaigoName"></span>
                    </label>
                <br/>
                    <label>
					    <span class="item-label-head" data-app-text="jyuryoSoShikomi" data-tooltip-text="jyuryoSoShikomi"></span>
                        <span id="selectJyuryoSoShikomi"></span>
                    </label>
                </li>
                </ul>
                <ul class="item-list item-list-right">
                <li>
                    <label>
                        <span class="item-label-head" data-app-text="ritsuBai"></span>
                        <span class="item-label-muji" data-app-text="suSeikiKakko"></span>
                        <span id="ritsuSeiki" class="suji-label"></span>
                        <span class="item-label-muji" data-app-text="suHasuKakko"></span>
                        <span id="ritsuHasu" class="suji-label"></span>
                    </label>
                </li>
                
                <li>
                    <label>
                        <span class="item-label-head" data-app-text="suBatch"></span>
                        <span class="item-label-muji" data-app-text="suSeikiKakko"></span>
                        <span id="batchSeiki" class="suji-label"></span>
                        <span class="item-label-muji" data-app-text="suHasuKakko"></span>
                        <span id="batchHasu" class="suji-label"></span>
                    </label>
                </li>
                <!-- TODO: ここまで -->
                </ul>
                
                <div id="grid-view">
                    <input type="radio" id="radio-default" name="gridViewRadio" value="default" checked="checked" />
                    <label for="radio-default" style="width:100px;">
                        <span data-app-text="allView"></span>
                    </label>
                    <input type="radio" id="radio-seikiview" name="gridViewRadio" value="seikiGrid"/>
                    <label for="radio-seikiview" style="width:100px;">
                        <span data-app-text="seikiView"></span>
                    </label>
                    <input type="radio" id="radio-hasuview" name="gridViewRadio" value="hasuGrid"/>
                    <label for="radio-hasuview" style="width:100px;">
                        <span data-app-text="hasuView"></span>
                    </label>
                </div>
                                
            </div><!-- 検索終了 -->
                
            <div class="dialog-result-list">
                <!-- グリッドコントロール固有のデザイン -- Start -->
                <div id="label-hakko">
                    <!-- 正規グリッド -->
                    <div class="seiki-area">
                        <div id="seiki-button">
                            <input type="radio" id="radio-seiki" name="seikihasuRadio" value="seiki" checked="checked" />
                            <label for="radio-seiki">
                                <span data-app-text="suSeiki"></span>
                            </label>
                        </div>
                        <div class="part-grid-up" id="grid-seiki">
                            <table id="dialog-list-seiki"></table>
                        </div>
                    </div>
                    <!-- 端数グリッド -->
                    <div class="hasu-area">
                        <div id="hasu-button">
                            <input type="radio" id="radio-hasu" name="seikihasuRadio" value="hasu" />
                            <label for="radio-hasu">
                                <span data-app-text="suHasu"></span>
                            </label>
                        </div>
                        <div class="part-grid-down" id="grid-hasu">
                            <table id="dialog-list-hasu"></table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <!-- TODO: ここまで  -->
        <div class="dialog-footer">
            <div class="command" style="position: absolute; left: 10px; top: 5px">
                <button class="dlg-zenlabel-button" name="dlg-zenlabel-button" data-app-text="labelInsatsuZen" data-app-operation="zenlabel">
                </button>
            </div>
            <div class="command" style="position: absolute; left: 200px; top: 5px;">
                <label>
                    <span class="item-label"  data-app-text="suKaishiBatch"></span>
                    <input type="text" name="suKaishiBatch" id="suKaishiBatch" maxlength="2" />
                </label>
                <label>&nbsp;</label>
                <label>
                    <span class="item-label" data-app-text="suShuryoBatch"></span>
                    <input type="text" name="suShuryoBatch" id="suShuryoBatch" maxlength="2" />
                </label>
                <button class="dlg-kobetsulabel-button" name="dlg-kobetsulabel-button" data-app-text="labelInsatsuKo" data-app-operation="kobetsulabel">
                </button>
            </div>
            <div class="command" style="position: absolute; right: 5px; top: 5px;">
                <button class="dlg-close-button" name="dlg-close-button" data-app-text="close">
                </button>
            </div>
        </div>
        <div class="message-area dialog-slideup-area">
            <div class="alert-message" style="display: none" data-app-text="title:alertTitle">
                <ul>
                </ul>
            </div>
            <div class="info-message" style="display: none" data-app-text="title:infoTitle">
                <ul>
                </ul>
            </div>
        </div>
    </div>
</body>
</html>