	<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ShokubaSentakuDialog.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.Dialog.ShokubaSentakuDialog" %>

	<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	<html xmlns="http://www.w3.org/1999/xhtml">
	<head id="Head1" runat="server">
	    <title></title>
	    <style type="text/css">
			/* 画面デザイン -- Start */
			
			/* TODO：画面の仕様に応じて以下のスタイルを変更してください。 */
			/* TODO：ここまで */
			
			/* 画面デザイン -- End */
		</style>
        <script src="<%=ResolveUrl("~/Scripts/util/app-util.js") %>" type="text/javascript"></script>
		<script type="text/javascript">
		    // TODO：画面の仕様に応じて以下のダイアログ名を変更してください。
		    $.dlg.register("ShokubaSentakuDialog", {
		        // TODO：ここまで
		        initialize: function (context) {
		            //// 変数宣言 -- Start
		            var nmShokuba;
		            var elem = context.element
	                    , dtSearchParam = context.data.param1
					    , kbnHinParam = context.data.param2
	                    , nmHinParam = context.data.param3
					    , cdBunruiParam = context.data.param4
	                    , nmBunruiParam = context.data.param5
	                    , yojitsuFlagParam = context.data.param6
	                    , dtUTCParam = context.data.param7;
		            var pageLangText = App.ui.pagedata.lang(App.ui.page.lang)
		            var dialog_grid = $(".dialog-content [name='dialog-shokuba-list']"),
					    querySettingDialog = { skip: 0, top: 500, count: 0 },
					    isDialogLoading = false,
	                    nextScrollTopDialog = 0,
					    lastScrollTopDialog = 0;

		            // パラメータからmultiselectを設定
		            var multiselect = false;
		            if (context.data.multiselect) {
		                multiselect = context.data.multiselect;
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

		            // 職場検索処理
		            var searchShokubaDialog = function () {
		                if (isDialogLoading === true) {
		                    return;
		                }
		                isDialogLoading = true;
		                // ローディングの表示
		                App.ui.loading.show(pageLangText.nowLoading.text, ".dialog-content");

		                //// 事前データロード -- Start 
		                // 画面アーキテクチャ共通の事前データロード
		                App.deferred.parallel({
		                    // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
		                    nmShokuba: App.ajax.webgetSync("../Services/FoodProcsService.svc/ma_shokuba?$filter=flg_mishiyo eq 0 & orderby eq cd_shokuba desc & $select=cd_shokuba,nm_shokuba ")
		                    // TODO: ここまで
		                }).done(function (result) {
		                    // TODO: 画面の仕様に応じて以下のサービス呼び出し成功時の処理を変更してください。
		                    nmShokuba = result.successes.nmShokuba.d;
		                    bindDataDialog(nmShokuba);
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
		                    // ローディングの終了
		                    App.ui.loading.close(".dialog-content");
		                });
		            };

		            // パラメータからグリッドのIDを設定
		            dialog_grid.attr("id", context.data.id);

		            // ダイアログ内のグリッド定義
		            dialog_grid.jqGrid({
		                // TODO：画面の仕様に応じて以下の列名の定義を変更してください。
		                colNames: [
	                        pageLangText.cd_shokuba_dlg.text
	                        , pageLangText.nm_shokubamei_dlg.text
						],
		                // TODO：ここまで
		                // TODO：画面の仕様に応じて以下の列モデルの定義を変更してください。
		                colModel: [
	                        { name: 'cd_shokuba', hidden: true, hidedlg: true },
	                        { name: 'nm_shokuba', align: "left", width: 350 }
						],
		                // TODO：ここまで
		                datatype: "local",
		                shrinkToFit: false,
		                multiselect: true,
		                rownumbers: false,
		                hoverrows: false,
		                height: 138,
		                gridComplete: function () {
		                },
		                loadComplete: function () {
		                },
		                ondblClickRow: function (rowid) {
		                }
		            });

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

		            /// <summary>データバインドをします。</summary>
		            var bindDataDialog = function (result) {
		                querySettingDialog.skip = querySettingDialog.skip + result.length;
		                querySettingDialog.count = parseInt(result.length);

		                // グリッドの表示件数を更新
		                dialog_grid.setGridParam({ rowNum: querySettingDialog.skip });
		                displayCountDialog();

		                // データバインド
		                var currentData = dialog_grid.getGridParam("data").concat(result);
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

		            // 検索処理
		            var printExcel = function (shokubaData) {

		                if (shokubaData != "noSelect") {

		                    var query = {
		                        // TODO: 画面の仕様に応じて以下のエンドポイントを変更してください。
		                        url: "../api/ShokubaBetsuExcel",
		                        con_hizuke: dtSearchParam,
		                        con_bunrui: cdBunruiParam,
		                        bunruiName: nmBunruiParam,
		                        con_shokuba: shokubaData[0],
		                        shokubaName: shokubaData[1],
		                        hinKubun: kbnHinParam,
		                        hinKubunName: nmHinParam,
		                        flg_yojitsu: yojitsuFlagParam,
		                        userName: encodeURIComponent(App.ui.page.user.Name),
		                        utc: dtUTCParam,
		                        lang: App.ui.page.lang,
		                        outputDate: App.data.getDateTimeStringForQuery(new Date(), true)
		                        // TODO：ここまで
		                    };
		                    // 処理中を表示する
		                    App.ui.loading.show(pageLangText.nowProgressing.text, ".dialog-content");

		                    // 必要な情報を渡します
		                    var url = App.data.toWebAPIFormat(query);

		                    // 出力処理
		                    window.open(url, '_parent');
		                    // Cookieを監視する
		                    onComplete();
		                }
		            };

		            // Cookieを1秒ごとにチェックする
		            var onComplete = function () {
		                if (app_util.prototype.getCookieValue(pageLangText.shokubaDialogCookie.text) == pageLangText.checkCookie.text) {
		                    app_util.prototype.deleteCookie(pageLangText.shokubaDialogCookie.text);
		                    //ローディング終了
		                    App.ui.loading.close(".dialog-content");
		                }
		                else {
		                    // 再起してCookieが作成されたか監視
		                    setTimeout(onComplete, 1000);
		                }
		            };

		            /// <summary>選択したコードを書き出します</summary>
		            var returnSelectedDialog = function () {
		                var selArray;
		                if (dialog_grid.getGridParam("multiselect")) {
		                    selArray = dialog_grid.jqGrid("getGridParam", "selarrrow");
		                    if (!App.isArray(selArray) || selArray.length == 0) {
		                        dialogNotifyInfo.message(pageLangText.noSelect.text).show();
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
		                    selCode.push(row.cd_shokuba);
		                    selName.push(row.nm_shokuba);
		                }
		                // TODO：ここまで
		                return [selCode.join(", "), selName.join(", ")];
		            };

		            // <summary>ダイアログの閉じるボタンクリック時のイベント処理を行います。</summary>
		            elem.find(".dlg-close-button").on("click", function () {
		                context.close("canceled");
		            });

		            // <summary>ダイアログの出力ボタンクリック時のイベント処理を行います。</summary>
		            elem.find(".dlg-output-button").on("click", function () {
		                var returnCode = returnSelectedDialog();
		                printExcel(returnCode);
		            });

		            /// <summary>ダイアログを開きます。</summary>
		            this.reopen = function (option) {
		                // ダイアログ再オープン時の処理
		                clearStateDialog();
		                searchShokubaDialog();

                        // パラメータ設定
		                dtSearchParam = option.param1
		                kbnHinParam = option.param2
		                nmHinParam = option.param3
		                cdBunruiParam = option.param4
		                nmBunruiParam = option.param5
		                yojitsuFlagParam = option.param6
		                dtUTCParam = option.param7;
		            };


		            /// <summary>画面起動時にダイアログを開きます。</summary>
		            var open = function () {
		                searchShokubaDialog();
		            };
		            open();
		        }
		    });
		</script>
	</head>
	<body>
	    <!-- ダイアログ固有のデザイン -- Start -->
	    <div class="dialog-content">
	        <!-- TODO: 画面の仕様に応じて以下のダイアログの設定を変更してください。 -->
	        <div class="dialog-header">
	            <h4 data-app-text="shokubaSentakuDialog">
	            </h4>
	        </div>
	        <div class="dialog-body" style="padding: 10px; width: 95%;">
	            <div class="dialog-result-list">
					<h3 id="listHeader" class="part-header">
						<span data-app-text="resultList" style="padding-right: 10px; padding-bottom: 4px;"id="list-results"></span>
						<span class="list-count list-count-dialog" id="list-count"></span>
					</h3>
					<div class="part-body" style="height: 170px;" id="shokubaSentakuDialog">
						<table name="dialog-shokuba-list">
						</table>
					</div>
				</div>
	        </div>
	        <!-- TODO: ここまで  -->
	        <div class="dialog-footer">
	            <div class="command" style="position: absolute; left: 10px; top: 5px">
	                <button class="dlg-output-button" name="dlg-output-button" data-app-text="output" data-app-operation="zenlabel">
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
