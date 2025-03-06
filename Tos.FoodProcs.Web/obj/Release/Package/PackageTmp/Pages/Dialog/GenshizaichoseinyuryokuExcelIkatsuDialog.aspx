<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="GenshizaichoseinyuryokuExcelIkatsuDialog.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.Dialog.ExcelIkatsuDialog" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
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
    <script src="<%=ResolveUrl("~/Scripts/util/app-util.js") %>" type="text/javascript"></script>
	<script type="text/javascript">
	    // TODO：画面の仕様に応じて以下のダイアログ名を変更してください。
	    $.dlg.register("GenshizaichoseinyuryokuExcelIkatsuDialog", {
	        // TODO：ここまで
	        initialize: function (context) {
	            //// 変数宣言 -- Start
	            var hinKubun
                    , elem = context.element
				    , hinKbnParam = context.data.param1
				    , dateParam = context.data.param2
				    , lang = App.ui.page.lang
                    , kbn_hin_criteria = null;
	            var pageLangText = App.ui.pagedata.lang(lang);
                //validationの追加
	            var validationSetting = App.ui.pagedata.validation(App.ui.page.lang);
	            // 多言語対応
	            var hinmeiName = 'nm_hinmei_' + App.ui.page.lang;
	            isCriteriaChange = false;

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

	            //日付テスト　start
	            // 日付の多言語対応
	            var datePickerFormat = pageLangText.dateFormatUS.text;
	            var newDateFormat = pageLangText.dateNewFormatUS.text;
	            var newDateMMDDFormat = pageLangText.dateMMDDFormatUS.text;
	            if (App.ui.page.langCountry !== 'en-US') {
	                datePickerFormat = pageLangText.dateFormat.text;
	                newDateFormat = pageLangText.dateNewFormat.text;
	                newDateMMDDFormat = pageLangText.dateMMDDFormat.text;
	            }
	            // 開始日の初期値を取得する。
	            var getDateFrom = function () {
	                var returnVal;
	                    returnVal = new Date(new Date().getFullYear(), new Date().getMonth(), 1);
	                return returnVal;
	            };

	            /// <summary>終了日の初期値を取得する。</summary>
	            var getDateTo = function () {
	                var start_date = $("#condition-date_from").val();
	                start_date = new Date(start_date);
	                var dayVal = start_date.getDate();
	                var returnVal = new Date();
	                    // 開始日が1日の場合はその月の末日を設定する
	                    returnVal = new Date(new Date().getFullYear(), new Date().getMonth() + 1, 0);

	                return returnVal;
	            };

	            /// <summary>時間を省いたシステム日付を日付オブジェクトで取得する</summary>
	            var getSystemDate = function () {
	                var sysdate = new Date(new Date().getFullYear(), new Date().getMonth(), new Date().getDate());
	                return sysdate;
	            };

	            $("#condition-date_from, #condition-date_to").on("keyup", App.data.addSlashForDateString);
	            $("#condition-date_from, #condition-date_to").datepicker({
	                dateFormat: datePickerFormat,
	                minDate: new Date(1975,1 -1, 1),
	                maxDate: "+10y"
	            });
	            $("#condition-date_from").datepicker("setDate", getDateFrom());
	            $("#condition-date_to").datepicker("setDate", getDateTo());

	            // 曜日フォーマッター
	            var yobiFormatter = function (celldata, options, rowobject) {
	                var showdata = "";
	                if (celldata >= 0 && celldata <= pageLangText.yobiId.data.length) {
	                    showdata = pageLangText.yobiId.data[celldata].shortName;
	                }
	                for (var i in pageLangText.yobiId.data) {
	                    if (pageLangText.yobiId.data[i].shortName === celldata) {
	                        showdata = celldata;
	                    }
	                }
	                return showdata;
	            };
	            //日付end

                //品名区分の取得
	            var getHinKbnParam = function () {
	                // 検索条件の品区分によって抽出条件を変更する
	                var hinKbnParam = "";
	                if (App.isUndefOrNull(searchCondition)) {
	                    // 未検索時は空を設定（searchConditionがundefinedの為）
	                    searchCondition = getSearchConDef();
	                }

	                if (searchCondition.hinKubun == pageLangText.genryoHinKbn.text) {
	                    hinKbnParam = pageLangText.genryoHinDlgParam.text;
	                }
	                else if (searchCondition.hinKubun == pageLangText.shizaiHinKbn.text) {
	                    hinKbnParam = pageLangText.shizaiHinDlgParam.text;
	                }
	                else if (searchCondition.hinKubun == pageLangText.jikaGenryoHinKbn.text) {
	                    hinKbnParam = pageLangText.jikaGenryoHinDlgParam.text;
	                }
	                else {
	                    hinKbnParam = pageLangText.genshizaiJikagenHinDlgParam.text;
	                }
	                return hinKbnParam;
	            };
                //comboboxを作成
	            var createCombobox = function (param) {
	                // ローディングの表示
	                App.ui.loading.show(pageLangText.nowProgressing.text, ".dialog-content");

	                var hinKubun;
	                $("#condition-kbn_hin-dlg > option").remove();
	                // 画面アーキテクチャ共通の事前データロード
	                App.deferred.parallel({	                    
	                    hinKubun: App.ajax.webget("../Services/FoodProcsService.svc/ma_kbn_hin?$filter=kbn_hin eq "
                        + pageLangText.genryoHinKbn.text + " or kbn_hin eq " + pageLangText.shizaiHinKbn.text
                        + " or kbn_hin eq " + pageLangText.jikaGenryoHinKbn.text + "&$orderby=kbn_hin")
	                    // TODO: ここまで
	                }).done(function (result) {
	                    // TODO: 画面の仕様に応じて以下のサービス呼び出し成功時の処理を変更してください。
	                    hinKubun = result.successes.hinKubun.d;
	                    var targetHinKbn = $(".dialog-search-criteria [name='hinKubun']");
	                    App.ui.appendOptions(targetHinKbn, "kbn_hin", "nm_kbn_hin", hinKubun, true);
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
	                    App.ui.loading.close(".dialog-content");
	                });
	            };

	            /// <summary>フィルター条件の設定</summary>
	            var createFilter = function () {
	                var criteria = $(".dialog-search-criteria").toJSON(),
                        filters = [];
	                searchCondition = criteria;
	                if (!App.isUndefOrNull(criteria.hizuke)) {
	                    filters.push("dt_hizuke ge DateTime'" + App.data.getDateTimeStringForQueryNoUtc(criteria.hizuke) + "'");
	                }
	                if (!App.isUndefOrNull(criteria.hizuke_to)) {
	                    filters.push("dt_hizuke le DateTime'" + App.data.getDateTimeStringForQueryNoUtc(criteria.hizuke_to) + "'");
	                }
	                if (!App.isUndefOrNull(criteria.hinKubun) && criteria.hinKubun.length > 0) {
	                    filters.push("kbn_hin eq " + criteria.hinKubun);
	                }
	                else {
	                    // 品区分に選択がない場合、原料と資材と自家原料を取得
	                    filters.push("(kbn_hin eq " + pageLangText.genryoHinKbn.text
                                + " or kbn_hin eq " + pageLangText.shizaiHinKbn.text
                                + " or kbn_hin eq " + pageLangText.jikaGenryoHinKbn.text + ")");
	                }
	                filters.push("kbn_bunrui_riyu eq " + pageLangText.choseiRiyuKbn.text);
	                // TODO: ここまで

	                return filters.join(" and ");
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

                //validationの追加
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
	            $(".dialog-content").validation(searchValidation);

	            /// <summary>Excelファイル出力を行います。</summary>
	            var printExcel = function (e) {

	                var query = {
	                    // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
	                    url: "../api/GenshizaiChoseiNyuryokuExcelIkatsu",
	                    // TODO: ここまで
	                    filter: createFilter(),
	                    // TODO: 画面の仕様に応じて以下のソート条件を変更してください。
	                    orderby: "dt_hizuke,cd_hinmei"
	                    // TODO: ここまで
	                };
	                // 処理中を表示する
	                App.ui.loading.show(pageLangText.nowProgressing.text, ".dialog-content");

	                // 必要な情報を渡します
	                var container = $(".dialog-search-criteria").toJSON(),
                        hinKbnName = pageLangText.noSelectConditionExcel.text;
	                if (!App.isUndefOrNull(container.hinKubun)) {
	                    hinKbnName = $("#condition-kbn_hin-dlg option:selected").text();
	                }
	                var url = App.data.toODataFormat(query);
	                url = url + "&lang=" + App.ui.page.lang + "&hinKubun="
                        + encodeURIComponent(hinKbnName)
                        + "&userName=" + encodeURIComponent(App.ui.page.user.Name)
                        + "&UTC=" + new Date().getTimezoneOffset() / 60
	                    + "&today=" + App.data.getDateTimeStringForQuery(new Date(), true);
	                window.open(url, '_parent');

	                // Cookieを監視する
	                onComplete();
	            };

	            // Cookieを1秒ごとにチェックする
	            var onComplete = function () {
	                if (app_util.prototype.getCookieValue(pageLangText.genshizaichoseinyuryokuExcelIkatsuDialogCookie.text) == pageLangText.checkCookie.text) {
	                    app_util.prototype.deleteCookie(pageLangText.genshizaichoseinyuryokuExcelIkatsuDialogCookie.text);
	                    //ローディング終了
	                    App.ui.loading.close(".dialog-content");
	                }
	                else {
	                    // 再起してCookieが作成されたか監視
	                    setTimeout(onComplete, 1000);
	                }
	            };

	            /// <summary>ダウンロードボタンクリック時のオーバレイ処理を行います。</summary>
	            var downloadOverlay = function () {
	                App.ui.page.notifyAlert.clear();
	                //    //検索条件入力チェック

	                var result = $(".part-body .item-list").validation().validate();
	                if (result.errors.length) {
	                    //        // ローディングの終了
	                    //App.ui.loading.close();
	                    return;
	                }

	                printExcel();
	            };
	            $(".ikatsu-excel-button").on("click", downloadOverlay);

	            // <summary>ダイアログの閉じるボタンクリック時のイベント処理を行います。</summary>
	            elem.find(".dlg-close-button").on("click", function () {
	                context.close("canceled");
	            });

	            /// <summary>ダイアログを開きます。</summary>
	            this.reopen = function (option) {
	                hinKbnParam = option.param1;
	                dateParam = option.param2
	                lineParam = option.param3
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
			<h4 data-app-text="excelikatsuDialog"></h4>
		</div>
		<div class="dialog-body" style="padding: 10px; width: 95%;">
			<div class="dialog-search-criteria">
				<div class="part-body">
					<ul class="item-list">
                        <li>
                            <label>
                                <span class="item-label"  data-app-text="dt_niuke_dlg"></span>
                                <input type="text" name="hizuke" id="condition-date_from" maxlength="10" style="width: 110px" />
                            </label>
                            <span data-app-text="between"></span>
                            <label>
                                <input type="text" name="hizuke_to" id="condition-date_to" maxlength="10" style="width: 110px" />
                            </label>
                        </li>
						<li>
							<label>
								<span class="item-label" data-app-text="kbn_hin_dlg"></span>
							</label>
							<select name="hinKubun" style="width: 150px" id="condition-kbn_hin-dlg">
							</select>
						</li>
					</ul>
				</div>
			</div>
		</div>
		<!-- TODO: ここまで  -->
		<div class="dialog-footer">
			<button type="button" style="position: absolute; left: 5px; top: 5px;" class="ikatsu-excel-button" name="ikatsu-excel-button" data-app-operation="excel">
                <span data-app-text="excel"></span>
            </button>
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
