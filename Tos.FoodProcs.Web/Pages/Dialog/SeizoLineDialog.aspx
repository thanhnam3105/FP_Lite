<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SeizoLineDialog.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.Dialog.SeizoLineDialog" %>

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
        /* TODO：ここまで */
        
        /* 画面デザイン -- End */
    </style>
    <script type="text/javascript">
        // TODO：画面の仕様に応じて以下のダイアログ名を変更してください。
    	$.dlg.register("SeizoLineDialog", {
    		// TODO：ここまで
    		initialize: function (context) {
    			//// 変数宣言 -- Start
    			var elem = context.element,
                    pageLangText = App.ui.pagedata.lang(App.ui.page.lang),
                    shokubaCode,
                    haigoCode,
                    masterKubun;

    			/// パラメータ取得
    			// マルチセレクトを設定
    			var multiselect = false;
    			if (context.data.multiselect) {
    				multiselect = context.data.multiselect;
    			}
    			/// パラムを設定する
    			/// param1:職場コード
    			/// param2:配合コード
    			/// param3:マスタ区分
    			var setParam = function (option) {
                    if (App.isUndefOrNull(option) || option === "") {
                        shokubaCode = context.data.param1;
                        haigoCode = context.data.param2;
                        masterKubun = context.data.param3;
                    }
                    else {
                        shokubaCode = option.param1;
                        haigoCode = option.param2;
                        masterKubun = option.param3;
                    }
    			}
    			setParam();

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

    			var dialog_grid = elem.find(".dialog-result-list [name='dialog-list']"),
				querySettingDialog = { skip: 0, top: 500, count: 0 },
				isDialogLoading = false,
				lastScrollTopDialog = 0;
    			// パラメータからグリッドのIDを設定
    			dialog_grid.attr("id", context.data.id);


    			/// &lt;summary&gt;クエリオブジェクトの設定&lt;/summary&gt;
    			var queryDialog = function () {
    				var query = {
    					// TODO: 画面の仕様に応じて以下のエンドポイントを変更してください。
    					url: "../Services/FoodProcsService.svc/vw_ma_seizo_line_01",
    					filter: createFilterDialog(),
    					orderby: "no_juni_yusen, cd_line",
    					skip: querySettingDialog.skip,
    					top: querySettingDialog.top,
    					// TODO：ここまで
    					inlinecount: "allpages"
    				}
    				return query;
    			};
    			/// 抽出条件の設定
    			var createFilterDialog = function () {
    				var criteria = elem.find(".dialog-search-criteria").toJSON(),
                        filters = [];
    				searchCondition = criteria;
    				// TODO: 画面の仕様に応じて以下のフィルター条件を変更してください。
    				if (!App.isUndefOrNull(masterKubun) && masterKubun.length > 0) {
    					filters.push("kbn_master eq " + masterKubun);
    				}
    				if (!App.isUndefOrNull(haigoCode) && haigoCode.length > 0) {
    					filters.push("cd_haigo eq '" + haigoCode + "'");
    				}
    				if (!App.isUndefOrNull(shokubaCode) && shokubaCode.length > 0) {
    					filters.push("cd_shokuba eq '" + shokubaCode + "'");
    				}
                    if (!App.isUndefOrNull(criteria.cd_line_dlg)) {
                        filters.push("(substringof('" + encodeURIComponent(criteria.cd_line_dlg) + "', cd_line) "
                            + "or substringof('" + encodeURIComponent(criteria.cd_line_dlg) + "', nm_line))");
                    }
    				filters.push("seizo_line_mishiyo eq " + pageLangText.shiyoMishiyoFlg.text);
    				filters.push("line_mishiyo eq " + pageLangText.shiyoMishiyoFlg.text);
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
                    }).fail(function (result) {
                    	dialogNotifyInfo.message(result.message).show();
                    }).always(function () {
                    	isDialogLoading = false;
                    });
    			};
    			var clearStateDialog = function () {
    				// データクリア
    				dialog_grid.clearGridData();
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
                    var resultCount = parseInt(result.d.__count);
    				//querySettingDialog.skip = querySettingDialog.skip + result.d.results.length;
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

    			// ダイアログ内のグリッド定義
    			dialog_grid.jqGrid({
    				// todo：画面の仕様に応じて以下の列名の定義を変更してください。
    				colNames: [
                        pageLangText.cd_line_dlg.text
                        , pageLangText.nm_line_dlg.text
                    ],
    				// todo：ここまで
    				// todo：画面の仕様に応じて以下の列モデルの定義を変更してください。
    				colModel: [
                        { name: 'cd_line', width: 115, align: "left" },
                        { name: 'nm_line', width: 360, align: "left" }
                    ],
    				// todo：ここまで
    				datatype: "local",
    				shrinktofit: false,
    				multiselect: multiselect,
    				rownumbers: true,
                    hoverrows: false,
    				height: 150,
    				loadComplete: function () {
                        // グリッドの先頭行選択：loadCompleteに記述しないとグリッドのソートで先頭行が選択されない
                        dialog_grid.setSelection(1, false);
    				},
    				ondblClickRow: function (rowid) {
    					var returnCode = returnSelectedDialog();
    					if (returnCode != "noSelect") {
    						context.close(returnCode);
    					}
    				}
    			});

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
    					selCode.push(row.cd_line);
    					selName.push(row.nm_line);
    				}
    				// TODO：ここまで
    				return [selCode.join(", "), selName.join(", ")];
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

    			// <summary>ダイアログの選択ボタンクリック時のイベント処理を行います。</summary>
    			elem.find(".dlg-select-button").on("click", function () {
    				var returnCode = returnSelectedDialog();
    				if (returnCode != "noSelect") {
    					context.close(returnCode);
    				}
    			});

    			/// <summary>ダイアログを開きます。</summary>
    			this.reopen = function (option) {
                    // ダイアログ再オープン時の処理
    				clearCriteriaDialog();
    				clearStateDialog();
    				setParam(option);
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
            <h4 data-app-text="seizoLineDialog">
            </h4>
        </div>
        <div class="dialog-body" style="padding: 10px; width: 95%;">
            <!-- 検索条件 -->
                <div class="dialog-search-criteria">
                    <div class="part-body" >
                        <ul class="item-list">
                            <li>
                                <label>
                                    <span class="item-label" data-app-text="cd_line_dlg" style="width: 80px;"></span>
                                    <input type="text" id="con_cd_line_dlg" name="cd_line_dlg" style="width: 300px;" maxlength="50" />
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
                    <span data-app-text="resultList" style="padding-right: 10px; padding-bottom: 4px;"
                        id="list-results"></span><span class="list-count list-count-dialog" id="list-count"></span>
                </h3>
                <div class="part-body" style="height: 200px;">
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
