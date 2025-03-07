<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="GenshizaiShiyoIchiranDialog.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.Dialog.GenshizaiShiyoIchiranDialog" %>

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
            position: absolute;
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
	    $.dlg.register("GenshizaiShiyoIchiranDialog", {
	        // TODO：ここまで
	        initialize: function (context) {
	            //// 変数宣言 -- Start
	            var elem = context.element
				    , pageLangText = App.ui.pagedata.lang(App.ui.page.lang)
				    , lang = App.ui.page.lang
    			    , hinCode = context.data.hinCode
    			    , hizuke = context.data.hizuke;
	            var hinName = "nm_hinmei_" + lang,  // 多言語対応の品名
                    haigoName = "nm_haigo_" + lang; // 多言語対応の配合名(仕掛品名)

	            //var dialog_grid = elem.find(".dialog-result-list [name='dialog-list']"),
	            var dialog_grid = elem.find("#dialog-list"),
				    querySettingDialog = { skip: 0, top: 500, count: 0 },
				    isDialogLoading = false;

	            //Add tool tip
	            App.customTooltip("#dialog-content-label, .shiyo-ichiran-dialog");

	            // パラメータからグリッドのIDを設定
	            dialog_grid.attr("id", context.data.id);

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

	            /// <summary>クエリオブジェクトの設定</summary>
	            var queryDialog = function () {

	                // TODO: 画面の仕様に応じて以下のエンドポイントを変更してください。
	                var query = {
	                    url: "../Services/FoodProcsService.svc/vw_tr_shiyo_yojitsu_01",
	                    filter: createFilterDialog(),
	                    orderby: "cd_hinmei", // 追加
	                    // select: "cd_hinmei, nm_hinmei_" + lang + ", nm_kbn_hin, nm_naiyo",
	                    skip: querySettingDialog.skip,
	                    top: querySettingDialog.top,
	                    // TODO：ここまで
	                    inlinecount: "allpages"
	                };
	                return query;
	            };

	            var createFilterDialog = function () {
	                var criteria = elem.find(".dialog-search-criteria").toJSON(),
                        filters = [];
	                filters.push("cd_hinmei eq '" + hinCode + "'");
	                filters.push("dt_shiyo eq DateTime'" + App.data.getDateTimeStringForQueryNoUtc(hizuke) + "'");
	                filters.push("flg_mishiyo_shikakari eq " + pageLangText.falseFlg.text);
	                filters.push("flg_mishiyo_seihin eq " + pageLangText.falseFlg.text);
	                filters.push("flg_mishiyo_hinmei eq " + pageLangText.falseFlg.text);
	                filters.push("flg_yojitsu eq " + pageLangText.yoteiYojitsuFlg.text);
	                if (!App.isUndefOrNull(criteria.nm_shikakari_hin_dlg)) {
	                    filters.push("( substringof('" + encodeURIComponent(criteria.nm_shikakari_hin_dlg) + "', cd_shikakari_hin) "
                            + "or substringof('" + encodeURIComponent(criteria.nm_shikakari_hin_dlg) + "', " + haigoName + ") )");
	                }
	                // TODO：ここまで
	                return filters.join(" and ");
	            };

	            var searchItemsDialog = function (_query) {
	                if (isDialogLoading === true) {
	                    return;
	                }
	                isDialogLoading = true;

	                App.ajax.webget(
						App.data.toODataFormat(_query)
					).done(function (result) {
					    // データバインド
					    bindDataDialog(result);
					    var dlgHinName = "";
					    if (result.d.__count > 0) {
					        var results = result.d.results[0];
					        if (!App.isUndefOrNull(results[hinName])) {
					            dlgHinName = results[hinName];
					        }
					    }
					    $("#nm_hinmei_dialog").text(dlgHinName);
					}).fail(function (result) {
					    dialogNotifyInfo.message(result.message).show();
					}).always(function () {
					    isDialogLoading = false;
					});
	            };

	            // ダイアログ内のグリッド定義
	            dialog_grid.jqGrid({
	                // TODO：画面の仕様に応じて以下の列名の定義を変更してください。
	                colNames: [
						pageLangText.cd_shikakari_hin_dlg.text
						, pageLangText.nm_shikakari_hin_dlg.text
						, pageLangText.wt_hitsuyo_dlg.text
						, pageLangText.cd_seihin_shiyodlg.text
						, pageLangText.nm_seihin_dlg.text
					],
	                // TODO：ここまで
	                // TODO：画面の仕様に応じて以下の列モデルの定義を変更してください。
	                colModel: [
						{ name: 'cd_shikakari_hin', label: pageLangText.cd_shikakari_hin_dlg.tooltip, width: 120, sorttype: "text", align: "left" },
						{ name: haigoName, label: pageLangText.nm_shikakari_hin_dlg.tooltip, width: 200, sorttype: "text", align: "left" },
						{ name: 'su_shiyo', width: 110, sorttype: "float", align: "right", formatter: 'number',
						    //formatoptions: { thousandsSeparator: ",", decimalPlaces: 6, defaultValue: "" }
                            formatoptions: { thousandsSeparator: ",", decimalPlaces: 3, defaultValue: "" }
						},
						{ name: 'cd_seihin', width: 120, sorttype: "text", align: "left" },
						{ name: 'nm_seihin_' + App.ui.page.lang, width: 200, sorttype: "text", align: "left" }
					],
	                // TODO：ここまで
	                datatype: "local",
	                shrinkToFit: false,
	                multiselect: false,
	                rownumbers: false,
	                hoverrows: false,
	                height: 160,
	                loadComplete: function () {
	                    // グリッドの先頭行選択：loadCompleteに記述しないとグリッドのソートで先頭行が選択されない
	                    dialog_grid.setSelection(1, false);
	                    App.customTooltip(".shiyo-ichiran-dialog", dialog_grid)
	                }
	            });

	            var clearStateDialog = function () {
	                // データクリア
	                dialog_grid.clearGridData();
	                querySettingDialog.skip = 0;
	                querySettingDialog.count = 0;
	                displayCountDialog();
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
	                var resultCount = parseInt(result.d.__count);
	                querySettingDialog.skip = querySettingDialog.skip + result.d.results.length;
	                querySettingDialog.count = resultCount;

	                // 検索結果が上限数を超えていた場合
	                if (resultCount > querySettingDialog.top) {
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
	                var currentData = dialog_grid.getGridParam("data").concat(result.d.results);
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

	            /// <summary>ダイアログの検索ボタンクリック時のイベント処理を行います。</summary>
	            elem.find(".dlg-find-button").on("click", function () {
	                clearStateDialog();
	                searchItemsDialog(new queryDialog());
	            });

	            // <summary>ダイアログの閉じるボタンクリック時のイベント処理を行います。</summary>
	            elem.find(".dlg-close-button").on("click", function () {
	                context.close("canceled");
	            });

	            /// <summary>ダイアログを開きます。</summary>
	            this.reopen = function (option) {
	                // ダイアログ再オープン時の処理
	                clearStateDialog();
	                hinCode = option.hinCode;
	                hizuke = option.hizuke;
	                $("#con_shikakari").val("");
	                searchItemsDialog(new queryDialog());
	            };

	            // 初回検索処理
	            // loadCompleteで実施するとグリッドのソート毎に検索後のメッセージが表示されてしまう為、初回読み込みの一番最後に検索処理を実施する
	            searchItemsDialog(new queryDialog());
	        }
	    });
	</script>
</head>
<body>
	<!-- ダイアログ固有のデザイン -- Start -->
	<div class="dialog-content">
		<!-- TODO: 画面の仕様に応じて以下のダイアログの設定を変更してください。 -->
		<div class="dialog-header">
			<h4 data-app-text="shiyoIchiranDialog">
			</h4>
		</div>
		<div class="dialog-body" style="padding: 10px; width: 95%;">
            <div>
                <span class="item-label" style="font-weight: bold; font-size: 12pt;" data-app-text="hinName"></span>
                <span class="conditionname-label" id="nm_hinmei_dialog"></span>
            </div>
            <!-- 検索条件 -->
            <div class="dialog-search-criteria">
                    <div class="part-body" >
                        <ul class="item-list">
                            <li>
                                <label>
                                    <span class="item-label" data-app-text="nm_shikakari_hin_dlg" data-tooltip-text="nm_shikakari_hin_dlg" style="width: auto;"></span>
                                    <input type="text" id="con_shikakari" name="nm_shikakari_hin_dlg" style="width: 300px;" maxlength="50" />
                                </label>
                            </li>
                        </ul>
                    </div>
                    <div class="part-footer">
                        <div class="command">
                            <button class="dlg-find-button" name="dlg-find-button" data-app-text="search"></button>
                        </div>
                    </div>
            </div>
			<div class="dialog-result-list">
				<!-- グリッドコントロール固有のデザイン -- Start -->
				<h3 id="listHeader" class="part-header">
					<span data-app-text="resultList" style="padding-right: 10px; padding-bottom: 1px;"id="list-results"></span>
					<span class="list-count list-count-dialog" id="list-count"></span>
				</h3>
				<div class="part-body" style="height: 180px;">
					<table id="dialog-list">
					</table>
				</div>
			</div>
		</div>
		<!-- TODO: ここまで  -->
		<div class="dialog-footer">
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
