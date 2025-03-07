<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="HinmeiDialog.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.Dialog.HinmeiDialog" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
	<title></title>
	<style type="text/css">
		/* 画面デザイン -- Start */
		
		/* TODO：画面の仕様に応じて以下のスタイルを変更してください。 */
		.dialog-content .item-label
		{
			width: 8em;
			line-height: 180%;
		}
		.dialog-content .item-input
		{
			width: 12em;
			line-height: 180%;
		}
		.dialog-content .dialog-search-criteria
		{
			border: solid 1px #efefef;
			padding-top: 0.5em;
			padding-left: 0.5em;
		}
		.dialog-content .dialog-search-criteria .part-footer
		{
			margin-top: 1em;
			margin-left: .5em;
			margin-right: .5em;
			position: relative;
			height: 40px;
			border-top: solid 1px #dbdbdb;
		}
		.dialog-content .dialog-search-criteria .part-footer .command
		{
			/*position: absolute;*/
			display: inline-block;
			right: 0;
		}
		.dialog-content .dialog-result-list
		{
			margin-top: 10px;
		}
		.dialog-content .dialog-search-criteria .part-footer .command button
		{
			position: relative;
			margin-left: .5em;
			top: 5px;
			padding: 0px;
			min-width: 100px;
			margin-right: 0;
		}

        .nm_hinmei {
            width: 350px;
        }
		/* TODO：ここまで */
		
		/* 画面デザイン -- End */
	</style>
	<script type="text/javascript">
		// TODO：画面の仕様に応じて以下のダイアログ名を変更してください。
	    $.dlg.register("HinmeiDialog", {
	        // TODO：ここまで
	        initialize: function (context) {
	            //// 変数宣言 -- Start
	            var elem = context.element
				    , hinKbnParam = context.data.param1
				    , dateParam = context.data.param2
				    , lineParam = context.data.param3
				    , shokubaParam = context.data.param4
				    , lang = App.ui.page.lang
                    , kbn_hin_criteria = null;
	            var pageLangText = App.ui.pagedata.lang(lang);

	            // 多言語対応
	            var hinmeiName = 'nm_hinmei_' + lang;

	            // パラメータからmultiselectを設定
	            var multiselect = false;
	            if (context.data.multiselect) {
	                multiselect = context.data.multiselect;
	            }
	            // パラメータから「未使用含」条件の操作を設定する
	            if (pageLangText.falseFlg.text === context.data.ismishiyo) {
	                $("#condition-flg_mishiyo_fukumu").attr("disabled", "disabled");
	            }

	            // ダイアログ情報メッセージの設定
	            var dialogNotifyInfo = App.ui.notify.info(elem, {
	                container: elem.find(".dialog-slideup-area .dialog-info-message"),
	                messageContainerQuery: "ul",
	                show: function () {
	                    elem.find(".dialog-info-message").show();
	                },
	                clear: function () {
	                    elem.find(".dialog-info-message").hide();
	                }
	            });
	            // ダイアログ警告メッセージの設定
	            var dialogNotifyAlert = App.ui.notify.alert(elem, {
	                container: elem.find(".dialog-slideup-area .dialog-alert-message"),
	                messageContainerQuery: "ul",
	                show: function () {
	                    elem.find(".dialog-alert-message").show();
	                },
	                clear: function () {
	                    elem.find(".dialog-alert-message").hide();
	                }
	            });
	            App.customTooltip(".hinmei-dialog, .shizai-dialog, .genshizai-dialog, .seihin-dialog, .seihin-search-dialog, .hinmei-dialog2, .con-seihin-button-dialog");
	            /// パラメータ別に表示する品区分を切り替える
	            var getHinKubun = function (param) {
	                if (param === pageLangText.maHinmeiHinDlgParam.text) {
	                    return "kbn_hin eq " + pageLangText.seihinHinKbn.text + " or kbn_hin eq "
							+ pageLangText.genryoHinKbn.text + " or kbn_hin eq "
							+ pageLangText.shizaiHinKbn.text + " or kbn_hin eq "
							+ pageLangText.jikaGenryoHinKbn.text;
	                }
	                else if (param === pageLangText.genryoShikakariHinDlgParam.text) {
	                    return "kbn_hin eq " + pageLangText.genryoHinKbn.text + " or kbn_hin eq "
							+ pageLangText.shikakariHinKbn.text;
	                }
	                else if (param === pageLangText.recipeTorokuHinDlgParam.text) {
	                    return "kbn_hin eq " + pageLangText.genryoHinKbn.text + " or kbn_hin eq "
							+ pageLangText.shizaiHinKbn.text + " or kbn_hin eq "
							+ pageLangText.shikakariHinKbn.text + " or kbn_hin eq "
							+ pageLangText.jikaGenryoHinKbn.text + " or kbn_hin eq "
							+ pageLangText.sagyoShijiHinKbn.text;
	                }
	                else if (param === pageLangText.seihinHinDlgParam.text) {
	                    return "kbn_hin eq " + pageLangText.seihinHinKbn.text;
	                }
	                else if (param === pageLangText.shikakariHinDlgParam.text ||
                                param === pageLangText.keikakuShikakariDlgParam.text) {
	                    return "kbn_hin eq " + pageLangText.shikakariHinKbn.text;
	                }
	                else if (param === pageLangText.genshizaiHinDlgParam.text) {
	                    return "kbn_hin eq " + pageLangText.genryoHinKbn.text + " or kbn_hin eq "
							+ pageLangText.shizaiHinKbn.text;
	                }
	                else if (param === pageLangText.genryoHinDlgParam.text) {
	                    return "kbn_hin eq " + pageLangText.genryoHinKbn.text;
	                }
	                else if (param === pageLangText.shizaiHinDlgParam.text) {
	                    return "kbn_hin eq " + pageLangText.shizaiHinKbn.text;
	                }
	                else if (param === pageLangText.jikaGenryoHinDlgParam.text) {
	                    return "kbn_hin eq " + pageLangText.jikaGenryoHinKbn.text;
	                }
	                else if (param === pageLangText.sagyoShijiHinDlgParam.text) {
	                    return "kbn_hin eq " + pageLangText.sagyoShijiHinKbn.text;
	                }
	                else if (param === pageLangText.seihinJikagenHinDlgParam.text ||
                                param === pageLangText.keikakuSeihinHinDlgParam.text) {
	                    return "kbn_hin eq " + pageLangText.seihinHinKbn.text + " or kbn_hin eq "
							+ pageLangText.jikaGenryoHinKbn.text;
	                }
	                else if (param === pageLangText.genshizaiJikagenHinDlgParam.text) {
	                    return "kbn_hin eq " + pageLangText.genryoHinKbn.text + " or kbn_hin eq "
							+ pageLangText.shizaiHinKbn.text + " or kbn_hin eq "
							+ pageLangText.jikaGenryoHinKbn.text;
	                }
	                else if (param === pageLangText.genshizaiJikagenShikakariHinDlgParam.text) {
	                    return "kbn_hin eq " + pageLangText.genryoHinKbn.text + " or kbn_hin eq "
							+ pageLangText.shizaiHinKbn.text + " or kbn_hin eq "
							+ pageLangText.shikakariHinKbn.text + " or kbn_hin eq "
							+ pageLangText.jikaGenryoHinKbn.text;
	                }
	                else if (param === pageLangText.genryoLotTorokuDlgParam.text) {
	                    return "kbn_hin eq " + pageLangText.genryoHinKbn.text + " or kbn_hin eq "
							+ pageLangText.jikaGenryoHinKbn.text;
                    }
	                return "1 eq 1";
	            };

	            //// 事前データロード -- Start 

	            /// 品区分を基に、分類コンボボックスを作成する
	            var createBunruiCombobox = function () {
	                $("#condition-bunrui-dlg > option").remove();
	                var comboBunruiHin;
	                var criteriaKbnHin = elem.find(".dialog-search-criteria").toJSON().kbn_hin;
	                // 品区分が作業指示の場合は分類を取得しない
	                if (criteriaKbnHin == pageLangText.sagyoShijiHinKbn.text) {
	                    elem.find("#condition-bunrui-dlg").attr("disabled", true);  // 検索条件/分類を操作不可にする
	                    App.ui.loading.close(".dialog-content");
	                    return;
	                }
	                else {
	                    elem.find("#condition-bunrui-dlg").attr("disabled", false); // 検索条件/分類を操作可にする
	                }
	                App.deferred.parallel({
	                    comboBunruiHin: App.ajax.webget(
                            "../Services/FoodProcsService.svc/ma_bunrui?$filter=kbn_hin eq "
                            + criteriaKbnHin
                            + " and flg_mishiyo eq "
                            + pageLangText.shiyoMishiyoFlg.text
                            + "&$orderby=cd_bunrui")
	                }).done(function (result) {
	                    // コンボボックス：検索条件/品分類の設定
	                    comboBunruiHin = result.successes.comboBunruiHin.d;
	                    // ※targetは$(".dialog-search-criteria [name='bunrui']")としてください。id(#XXXX)で指定するとプルダウンに値が設定されません。
	                    var targetBunrui = $(".dialog-search-criteria [name='bunrui']");
	                    App.ui.appendOptions(targetBunrui, "cd_bunrui", "nm_bunrui", comboBunruiHin, true);
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
	                    // ローディングの終了
	                    App.ui.loading.close(".dialog-content");
	                });
	            };
	            var createCombobox = function (param) {
	                // ローディングの表示
	                App.ui.loading.show(pageLangText.nowProgressing.text, ".dialog-content");

	                var hinKubun;
	                $("#condition-kbn_hin-dlg > option").remove();
	                // 画面アーキテクチャ共通の事前データロード
	                App.deferred.parallel({
	                    // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
	                    hinKubun: App.ajax.webget("../Services/FoodProcsService.svc/ma_kbn_hin?$filter="
							+ getHinKubun(hinKbnParam) + "&$orderby=kbn_hin")
	                    // TODO: ここまで
	                }).done(function (result) {
	                    // TODO: 画面の仕様に応じて以下のサービス呼び出し成功時の処理を変更してください。
	                    hinKubun = result.successes.hinKubun.d;
	                    // 検索用ドロップダウンの設定
	                    App.ui.appendOptions($(".dialog-search-criteria [name='kbn_hin']"), "kbn_hin",
							"nm_kbn_hin", hinKubun, false);

	                    // 分類の取得と設定(品区分による検索条件の操作制御もこの先で行っている)
	                    createBunruiCombobox();

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
	                    if (!App.isUndefOrNull(param)) {
	                        $("#condition-kbn_hin-dlg").val(param);
	                    }
	                });
	            };

	            var dialog_grid = elem.find(".dialog-result-list [name='dialog-list']"),
				    querySettingDialog = { skip: 0, top: 500, count: 0 },
				    isDialogLoading = false,
                    nextScrollTopDialog = 0,
				    lastScrollTopDialog = 0;
	            // パラメータからグリッドのIDを設定
	            dialog_grid.attr("id", context.data.id);

	            // ダイアログ内のグリッド定義
	            dialog_grid.jqGrid({
	                // TODO：画面の仕様に応じて以下の列名の定義を変更してください。
	                colNames: [
						pageLangText.cd_hinmei_dlg.text
						, pageLangText.kbn_hin_dlg.text
						, pageLangText.kbn_hin_dlg.text
						, pageLangText.nm_hinmei_dlg.text
						, pageLangText.nm_hinmei_dlg.text
						, pageLangText.nm_naiyo_dlg.text
					],
	                // TODO：ここまで
	                // TODO：画面の仕様に応じて以下の列モデルの定義を変更してください。
	                colModel: [
						{ name: 'cd_hinmei', width: 110, align: "left" },
						{ name: 'nm_kbn_hin', width: 90, align: "center" },
						{ name: 'kbn_hin', width: 0, hidden: true, hidedlg: true },
						{ name: hinmeiName, width: 145 },
						{ name: 'nm_hinmei', width: 0, hidden: true, hidedlg: true },
						{ name: 'nm_naiyo', width: 145, align: "left" }
					],
	                // TODO：ここまで
	                datatype: "local",
	                shrinkToFit: false,
	                multiselect: multiselect,
	                rownumbers: false,
	                hoverrows: false,
	                height: 138,
	                gridComplete: function () {
	                    for (var iRow = 0; iRow < this.rows.length; iRow++) {
	                        dialog_grid.setCell(iRow, "nm_hinmei", dialog_grid.getCell(iRow, hinmeiName));
	                    }
	                    dialog_grid.closest(".ui-jqgrid-bdiv").scrollTop(nextScrollTopDialog);
	                },
	                loadComplete: function () {
	                    //createCombobox(kbn_hin_criteria);
	                    if (!multiselect) {
	                        // 複数行選択をしない場合
	                        // グリッドの先頭行選択：loadCompleteに記述しないとグリッドのソートで先頭行が選択されない
	                        dialog_grid.setSelection(1, false);
	                    }
	                },
	                ondblClickRow: function (rowid) {
	                    var returnCode = returnSelectedDialog();
	                    if (returnCode != "noSelect") {
	                        context.close(returnCode);
	                    }
	                }
	            });

	            /// <summary>クエリオブジェクトの設定</summary>
	            var queryDialogWeb = function () {
	                var criteria = elem.find(".dialog-search-criteria").toJSON(),
                        urlStr;

	                if (hinKbnParam == pageLangText.keikakuSeihinHinDlgParam.text ||
                            hinKbnParam == pageLangText.keikakuShikakariDlgParam.text) {
	                    // パラメーター品区分が計画系(製品計画または仕掛品計画)の場合

	                    var paramType = pageLangText.systemValueZero.text;
	                    if (hinKbnParam == pageLangText.keikakuSeihinHinDlgParam.text) {
	                        paramType = pageLangText.systemValueOne.text;
	                    }
	                    else if (hinKbnParam == pageLangText.keikakuShikakariDlgParam.text) {
	                        paramType = pageLangText.systemValueTwo.text;
	                    }
	                    urlStr = { url: "../api/HinmeiDialog"
                                   , flg_mishiyo_fukumu: criteria.flg_mishiyo_fukumu
                                   , nm_hinmei: criteria.nm_hinmei == null ? "" : encodeURIComponent(criteria.nm_hinmei)
                                   , kbn_hin: criteria.kbn_hin
                                   , top: querySettingDialog.top
                                   , keikakuType: paramType
                                   , seizoDate: dateParam
                                   , lineCode: lineParam
                                   , shokubaCode: shokubaParam
                                   , lang: lang
                                   , cd_bunrui: criteria.bunrui
	                    };
	                    return urlStr;
	                }
	                else if (criteria.kbn_hin == pageLangText.shikakariHinKbn.text) {
	                    // 検索条件/品区分が「仕掛品」の場合
	                    //urlStr = "../Services/FoodProcsService.svc/vw_ma_hinmei_05";
	                    urlStr = { url: "../api/HinmeiDialog"
                                   , flg_mishiyo_fukumu: criteria.flg_mishiyo_fukumu
                                   , nm_hinmei: criteria.nm_hinmei == null ? "" : encodeURIComponent(criteria.nm_hinmei)
                                   , top: querySettingDialog.top
                                   , cd_bunrui: criteria.bunrui
	                    };
	                    return urlStr;
	                }
	                else if (criteria.kbn_hin == pageLangText.sagyoShijiHinKbn.text) {
	                    urlStr = "../Services/FoodProcsService.svc/vw_ma_hinmei_06";
	                }
	                else {
	                    urlStr = "../Services/FoodProcsService.svc/vw_ma_hinmei_03";
	                }

	                var query = {
	                    url: urlStr,
	                    filter: createFilterDialog(),
	                    orderby: "cd_hinmei",
	                    select: "cd_hinmei, " + hinmeiName + ", nm_kbn_hin, nm_naiyo",
	                    skip: querySettingDialog.skip,
	                    top: querySettingDialog.top,
	                    inlinecount: "allpages"
	                };
	                return query;
	            };

	            /// <summary>検索条件の設定</summary>
	            var createFilterDialog = function () {
	                var criteria = elem.find(".dialog-search-criteria").toJSON(), filters = [];
	                filters.push("kbn_hin eq " + criteria.kbn_hin);
	                if (!App.isUndefOrNull(criteria.nm_hinmei) && criteria.nm_hinmei.length > 0) {
	                    //filters.push("substringof('" + encodeURIComponent(criteria.nm_hinmei) + "', " + hinmeiName + ") eq true");
	                    filters.push("(substringof('" + encodeURIComponent(criteria.nm_hinmei) + "', cd_hinmei) "
                            + "or substringof('" + encodeURIComponent(criteria.nm_hinmei) + "'," + hinmeiName + "))");
	                }
	                if (criteria.flg_mishiyo_fukumu != "1") {
	                    filters.push("flg_mishiyo eq " + pageLangText.falseFlg.text);
	                }
	                if (!App.isUndefOrNull(criteria.bunrui)) {
	                    filters.push("cd_bunrui eq '" + criteria.bunrui + "'");
	                }
	                return filters.join(" and ");
	            };

	            /// <summary>検索処理の実行</summary>
	            var searchItemsDialog = function (_query) {
	                // ローディングの表示
	                App.ui.loading.show(pageLangText.nowProgressing.text, ".dialog-content");

	                isDialogLoading = true;
	                nextScrollTopDialog = $("#hinmeiDialog").find(".ui-jqgrid-bdiv").scrollTop();
	                kbn_hin_criteria = elem.find(".dialog-search-criteria").toJSON().kbn_hin;

	                var exeQuery = "";
	                if (kbn_hin_criteria == pageLangText.shikakariHinKbn.text ||
                            hinKbnParam == pageLangText.keikakuSeihinHinDlgParam.text ||
                            hinKbnParam == pageLangText.keikakuShikakariDlgParam.text) {
	                    // 検索条件/品区分が「仕掛品」または、パラメーター品区分が計画系(製品計画または仕掛品計画)の場合
	                    exeQuery = App.data.toWebAPIFormat(_query);
	                }
	                else {
	                    exeQuery = App.data.toODataFormat(_query);
	                }
	                App.ajax.webget(
	                //App.data.toODataFormat(_query)
                        exeQuery
					).done(function (result) {
					    // データバインド
					    bindDataDialog(result);
					}).fail(function (result) {
					    //dialogNotifyInfo.message(result.message).show();
					    dialogNotifyAlert.message(result.message).show();
					}).always(function () {
					    // 検索ボタンダブルクリックで検索結果がおかしくならないようsetTimeoutで間を入れる
					    // ＃不要な検索処理が走ってしまう為
					    setTimeout(function () {
					        isDialogLoading = false;
					    }, 500);
					    // ローディングの終了
					    App.ui.loading.close(".dialog-content");
					});
	            };

	            var clearStateDialog = function () {
	                // データクリア
	                dialog_grid.clearGridData();
	                querySettingDialog.skip = 0;
	                querySettingDialog.count = 0;
	                lastScrollTopDialog = 0;
	                nextScrollTopDialog = 0;
	                displayCountDialog();
	                isDialogLoading = false;
	                // 情報メッセージのクリア
	                dialogNotifyInfo.clear();
	                // エラーメッセージのクリア
	                dialogNotifyAlert.clear();
	            };
	            /// <summary>データ取得件数を表示します。</summary>
	            var displayCountDialog = function () {
	                $(".list-count-dialog").text(
						App.str.format("{0}/{1}", querySettingDialog.skip, querySettingDialog.count));
	            };
	            /// <summary>データをバインドします。</summary>
	            /// <param name="result">検索結果</param>
	            var bindDataDialog = function (result) {

	                var resultCount = result.d.__count;
	                var resultData = result.d.results;
	                if (App.isUndefOrNull(resultCount)) {
	                    // result.d.__countがUndefの場合、ストアド検索なので取得先を変更する
	                    resultCount = parseInt(result.__count);
	                    resultData = result.d;
	                }
	                querySettingDialog.count = resultCount;

	                // 検索結果が上限数を超えていた場合
	                if (parseInt(resultCount) > querySettingDialog.top) {
	                    querySettingDialog.skip = querySettingDialog.top;
	                    dialogNotifyAlert.message(MS0011).show();
	                }
	                else {
	                    querySettingDialog.skip = resultCount;
	                }

	                // グリッドの表示件数を更新
	                dialog_grid.setGridParam({ rowNum: querySettingDialog.skip });
	                displayCountDialog();
	                // データバインド
	                var currentData = dialog_grid.getGridParam("data").concat(resultData);
	                dialog_grid.setGridParam({ data: currentData }).trigger('reloadGrid', [{ current: true}]);
	                // 取得完了メッセージの表示
	                if (querySettingDialog.count <= 0) {
	                    dialogNotifyAlert.message(pageLangText.notFound.text).show();
	                }
	                else {
	                    dialogNotifyInfo.message(
                            App.str.format(pageLangText.searchResultCount.text, querySettingDialog.skip, querySettingDialog.count)
                        ).show();
	                }
	            };

	            /// <summary>検索条件をクリアします</summary>
	            var clearCriteriaDialog = function () {
	                var criteria = elem.find(".dialog-search-criteria");
	                var controls = criteria.find("*").not(":button");
	                $.each(controls, function () {
	                    var control = $(this);
	                    if (control.is(":text")) {
	                        control.val("");
	                    }
	                    if (control.is(":checkbox")) {
	                        control.attr("checked", false);
	                    }
	                    if (control.is("select")) {
	                        control.find("option[selected='selected']").removeAttr("selected");
	                        control.find("option:first").attr("selected", "selected");
	                    }
	                });
	                // TODO：画面の仕様に応じて検索条件の初期値を設定してください。
	                // gridのmultiselect all select row 用checkbox のクリア
	                elem.find("#cb_" + dialog_grid[0].id).attr("checked", false);
	                // TODO：ここまで
	            };

	            /// <summary>選択したコードを書き出します</summary>
	            var returnSelectedDialog = function () {
	                var selArray;
	                if (dialog_grid.getGridParam("multiselect")) {
	                    selArray = dialog_grid.jqGrid("getGridParam", "selarrrow");
	                    if (!App.isArray(selArray) || selArray.length == 0) {
	                        dialogNotifyInfo.message(pageLangText.noSelect.text).show();
	                        return "noSelect";
	                    } else if (selArray.length > pageLangText.limitMultiSelect.text) {
	                        // error message
	                        dialogNotifyInfo.message(
                                App.str.format(pageLangText.multiSelect.text, pageLangText.limitMultiSelect.text)
                            ).show();
	                        return "noSelect";
	                    }
	                }
	                else {
	                    selArray = [];
	                    selArray[0] = dialog_grid.jqGrid("getGridParam", "selrow");
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
	                    row = dialog_grid.jqGrid("getRowData", selArray[i]);
	                    selCode.push(row.cd_hinmei);
	                    selName.push(row.nm_hinmei);
	                }
	                // TODO：ここまで
	                return [selCode.join(", "), selName.join(", ")];
	            };

	            // <summary>ダイアログの閉じるボタンクリック時のイベント処理を行います。</summary>
	            elem.find(".dlg-close-button").on("click", function () {
	                context.close("canceled");
	            });

	            // <summary>ダイアログの選択ボタンクリック時のイベント処理を行います。</summary>
	            elem.find(".dlg-select-button").on("click", function () {
	                var returnCode = returnSelectedDialog();
	                if (returnCode != "noSelect") {
	                    context.close(returnCode);
	                }
	            });

	            /// <summary>ダイアログの検索ボタンクリック時のイベント処理を行います。</summary>
	            elem.find(".dlg-find-button").on("click", function () {
	                if (isDialogLoading == true) {
	                    return;
	                }
	                clearStateDialog();
	                searchItemsDialog(new queryDialogWeb());
	            });

	            /// <summary>コンボボックス：検索条件/品区分変更時のイベント処理を行います。</summary>
	            elem.find("#condition-kbn_hin-dlg").on("change", function () {
	                // コンボボックス：検索条件/分類の作成処理
	                createBunruiCombobox();
	            });

	            /// <summary>ダイアログを開きます。</summary>
	            this.reopen = function (option) {
	                // ダイアログ再オープン時の処理
	                clearCriteriaDialog();
	                clearStateDialog();
	                hinKbnParam = option.param1;
	                dateParam = option.param2
	                lineParam = option.param3
	                shokubaParam = option.param4
	                createCombobox();
	            };
	            createCombobox();
	        }
	    });
	</script>
</head>
<body>
	<!-- ダイアログ固有のデザイン -- Start -->
	<div class="dialog-content">
		<!-- TODO: 画面の仕様に応じて以下のダイアログの設定を変更してください。 -->
		<div class="dialog-header">
			<h4 data-app-text="hinmeiDialog">
			</h4>
		</div>
		<div class="dialog-body" style="padding: 10px; width: 95%;">
			<div class="dialog-search-criteria">
				<div class="part-body">
					<ul class="item-list">
						<li>
							<label>
								<span class="item-label" data-app-text="kbn_hin_dlg"></span>
							</label>
							<select name="kbn_hin" style="width: 150px" id="condition-kbn_hin-dlg">
							</select>
						</li>
						<li>
							<label>
								<span class="item-label" data-app-text="categoryName"></span>
							</label>
							<select name="bunrui" style="width: 250px;" id="condition-bunrui-dlg">
							</select>
						</li>
						<li>
							<label>
								<span class="item-label" data-app-text="nm_hinmei_dlg"></span>
							</label>
							<input type="text" class="nm_hinmei" name="nm_hinmei" id="condition-nm_hinmei" />
						</li>
						<li>
							<label>
								<span class="item-label" data-app-text="mishiyoFukumuFlag" data-tooltip-text="mishiyoFukumuFlag"></span>
							</label>
							<input type="checkbox" name="flg_mishiyo_fukumu" id="condition-flg_mishiyo_fukumu"
								value="1" />
						</li>
					</ul>
				</div>
				<div class="part-footer">
					<div class="command">
						<button class="dlg-find-button" name="dlg-find-button" data-app-text="search">
						</button>
					</div>
				</div>
			</div>
			<div class="dialog-result-list">
				<!-- グリッドコントロール固有のデザイン -- Start -->
				<h3 id="listHeader" class="part-header">
					<span data-app-text="resultList" style="padding-right: 10px; padding-bottom: 4px;"id="list-results"></span>
					<span class="list-count list-count-dialog" id="list-count"></span>
				</h3>
				<div class="part-body" style="height: 170px;" id="hinmeiDialog">
					<table name="dialog-list">
					</table>
				</div>
			</div>
		</div>
		<!-- TODO: ここまで  -->
		<div class="dialog-footer">
			<div class="command" style="position: absolute; left: 10px; top: 5px">
				<button class="dlg-select-button" name="dlg-select-button" data-app-text="select">
				</button>
			</div>
			<div class="command" style="position: absolute; right: 5px; top: 5px;">
				<button class="dlg-close-button" name="dlg-close-button" data-app-text="close">
				</button>
			</div>
		</div>
		<div class="message-area dialog-slideup-area">
			<div class="dialog-alert-message" style="display: none" data-app-text="title:alertTitle">
				<ul>
				</ul>
			</div>
			<div class="dialog-info-message" style="display: none" data-app-text="title:infoTitle">
				<ul>
				</ul>
			</div>
		</div>
	</div>
</body>
</html>
