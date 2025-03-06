<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="InsatsuSentakuDialog.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.Dialog.InsatsuSentakuDialog" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <style type="text/css">
        /* 画面デザイン -- Start */
        
        /* TODO：画面の仕様に応じて以下のスタイルを変更してください。 */
        .dialog-content .item-labelf
        {
            width: 8em;
            line-height: 180%;
        }
        .dialog-content .item-input
        {
            width: 12em;
            line-height: 180%;
        }
        .dialog-content .dialog-search-criteria-print
        {
            border: solid 1px #efefef;
            padding-top: 1em;
            padding-left: 2.5em;
            height: 50px;
        }
        .dialog-content .dialog-search-criteria-print .part-footer
        {
            margin-top: 1em;
            margin-left: .5em;
            margin-right: .5em;
            position: relative;
            height: 40px;
            border-top: solid 1px #dbdbdb;
        }
        .dialog-content .dialog-search-criteria-print .part-footer .command
        {
            position: absolute;
            display: inline-block;
            right: 0;
        }
        .dialog-content .dialog-result-list
        {
            margin-top: 10px;
        }
        .dialog-content .dialog-search-criteria-print .part-footer .command button
        {
            position: relative;
            margin-left: .5em;
            top: 5px;
            padding: 0px;
            min-width: 100px;
            margin-right: 0;
        }
        
        ul.check-hyo-area li
        {
            height: 30px;
        }
        
        /* チェック時の色 */
        
        .checkLabelCol.ui-state-active  
        {
            background: #008000;
        }
        
        .checkLabelCol.ui-state-active span.ui-button-text span 
        { 
            color: 	#FFFFFF; 
        }
        
        .checkedcol
        {
            background: #008000;
            color: 	#FFFFFF; 
        }
        /* TODO：ここまで */
        
        /* 画面デザイン -- End */
    </style>
    <script src="<%=ResolveUrl("~/Scripts/util/app-util.js") %>" type="text/javascript"></script>
    <script type="text/javascript">
        // TODO：画面の仕様に応じて以下のダイアログ名を変更してください。
        $.dlg.register("InsatsuSentakuDialog", {
            // TODO：ここまで
            initialize: function (context) {
                //// 変数宣言 -- Start
                var elem = context.element,
                    isFirstLoad = true, // 初回起動時
                    pageLangText = App.ui.pagedata.lang(App.ui.page.lang);

                var selectShikomiKakuteiFlg = context.data.param1,
                    criteria = context.data.param2,
                    selectShikakariLotNo = context.data.param3;

                // 画面がら渡されたフラグを確認し、ボタンの制御をします
                var setButtonsetControl = function () {
                    // 全てが確定されていなかった場合、ボタン制御
                    if (selectShikomiKakuteiFlg == false) {
                        $('#lotKirokuHyoCheck').prop("disabled", true); //.css("background-color", "#F2F2F2");
                        $('#checkHyoCheck').prop("disabled", true);
                    } else {
                        $('#lotKirokuHyoCheck').prop("disabled", false); //.prop("disabled", false);
                        $('#checkHyoCheck').prop("disabled", false);
                    }
                    //ボタンセット作成
                    $("#check-box-area").buttonset();
                };

                setButtonsetControl();
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

                /// <summary>検索条件をクリアします</summary>
                var clearCriteriaDialog = function () {
                    var criteria = elem.find(".dialog-search-criteria-print");
                    var controls = criteria.find("*").not(":button");
                    $.each(controls, function () {
                        var control = $(this);
                        if (control.is(":checkbox")) {
                            control.prop('checked', false);
                            control.prop('disabled', false);
                        }
                    });
                    // TODO：ここまで
                };

                /// <summary>ダウンロードボタンクリック時処理を行います。</summary>
                var prePrintDoc = function (output) {
                    if (output == "shikomi") {
                        // 仕込計画表
                        printShikomiExcel();
                    } else if (output == "lot") {
                        // 秤量記録表
                        printLotPDF();
                    } else if (output == "check") {
                        // 配合チェック表
                        printCheckPDF();
                    }
                };

                /// <summary>Excelファイル出力（仕込計画表）を行います。</summary>
                var printShikomiExcel = function (e) {
                    // 確定・未確定チェックの値を検証
                    var kakuteiValue = criteria.kakuteiCheck == "on" ? pageLangText.trueFlg.text : pageLangText.falseFlg.text;
                    var mikakuteiValue = criteria.mikakuteiCheck == "on" ? pageLangText.trueFlg.text : pageLangText.falseFlg.text;
                    var query = {
                        // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                        url: "../api/ShikomiKeikakuHyoExcel",
                        cd_shokuba: criteria.shokubaCode,
                        cd_line: criteria.lineCode,
                        flg_kakutei: kakuteiValue,
                        flg_mikakutei: mikakuteiValue,
                        dt_hiduke: App.data.getDateTimeStringForQueryNoUtc(criteria.dt_hiduke_search),
                        isShikomi: criteria.shokubaRadio,
                        nm_shokuba: encodeURIComponent($(".search-criteria [name='shokubaCode'] option:selected").text()),
                        nm_line: encodeURIComponent($(".search-criteria [name='lineCode'] option:selected").text())
                        // TODO: ここまで
                    };

                    // 処理中を表示する
                    App.ui.loading.show(pageLangText.nowProgressing.text, ".dialog-content");

                    // 必要な情報を渡します
                    var url = App.data.toWebAPIFormat(query);
                    url = url + "&lang=" + App.ui.page.lang
                              + "&UTC=" + new Date().getTimezoneOffset() / 60 // UTCの考慮時間を渡す
                              + "&userName=" + encodeURIComponent(App.ui.page.user.Name)
                              + "&outputDate=" + App.data.getDateTimeStringForQuery(new Date(), true);
                    window.open(url, '_parent');

                    // Cookieを監視する
                    onComplete();
                };
                // Cookieを1秒ごとにチェックする
                var onComplete = function () {
                    if (app_util.prototype.getCookieValue(pageLangText.insatsuSentakuDialogCookie.text) == pageLangText.checkCookie.text) {
                        app_util.prototype.deleteCookie(pageLangText.insatsuSentakuDialogCookie.text);
                        //ローディング終了
                        App.ui.loading.close(".dialog-content");
                    }
                    else {
                        // 再起してCookieが作成されたか監視
                        setTimeout(onComplete, 1000);
                    }
                };

                /// <summary>PDFファイル出力（ロット番号記録表）を行います。</summary>
                var printLotPDF = function (e) {
                    var query = {
                        // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                        url: "../api/GenryoLotBangoKirokuHyoPDF"
                        // TODO: ここまで
                    }

                    // 必要な情報を渡します
                    var url = App.data.toWebAPIFormat(query);
                    url = url + "&lang=" + App.ui.page.lang
                              + "&UTC=" + new Date().getTimezoneOffset() / 60 // UTCの考慮時間を渡す
                              + "&uuid=" + App.uuid()
                              + "&lotNo=" + selectShikakariLotNo
                              + "&jyotaiSonota=" + pageLangText.sonotaJotaiKbn.text
                              + "&shiyoFlg=" + pageLangText.shiyoMishiyoFlg.text
                              + "&today=" + App.data.getDateTimeStringForQuery(new Date(), true);
                    window.open(url, '_parent');
                };

                /// <summary>PDFファイル出力（チェック表）を行います。</summary>
                var printCheckPDF = function (e) {
                    var query = {
                        // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                        url: "../api/ShikomiCheckHyoPDF"
                        // TODO: ここまで
                    }

                    // 必要な情報を渡します
                    var url = App.data.toWebAPIFormat(query);
                    url = url + "&lang=" + App.ui.page.lang
                              + "&UTC=" + new Date().getTimezoneOffset() / 60 // UTCの考慮時間を渡す
                              + "&uuid=" + App.uuid()
                              + "&lotNo=" + selectShikakariLotNo
                              + "&shiyoFlg=" + pageLangText.shiyoMishiyoFlg.text
                              + "&today=" + App.data.getDateTimeStringForQuery(new Date(), true);
                    window.open(url, '_parent');
                };

                // 選択処理
                $('.print-check').on("click", function () {
                    // 同一クラスのチェックボックスをOFF
                    var group = "input:checkbox[name='" + $(this).attr("name") + "']";
                    $(group).prop('checked', false);
                    // 色を変更
                    $(".checkLabelCol").removeClass('ui-state-active');

                    // 対象のチェックボックスを選択/色をアクティブに
                    $(this).prop('checked', true);
                    var label = $('#' + $(this).context.id + ' + label');
                    label.addClass('ui-state-active');
                });

                // <summary>ダイアログの閉じるボタンクリック時のイベント処理を行います。</summary>
                elem.find(".dlg-close-button").on("click", function () {
                    context.close("canceled");
                });

                // <summary>ダイアログの印刷ボタンクリック時のイベント処理を行います。</summary>
                elem.find(".dlg-insatsu-button").on("click", function () {
                    // チェックボックスチェック                   
                    var shikomi = $('#shikomiKeikakuHyoCheck');
                    var lot = $('#lotKirokuHyoCheck');
                    var check = $('#checkHyoCheck');

                    if (shikomi.is(':checked') === false
                        && lot.is(':checked') === false
                        && check.is(':checked') === false) {
                        // 未チェック
                        dialogNotifyInfo.message(pageLangText.noPrintSelect.text).show();
                        return;
                    }
                    // 印刷確認
                    if (true === false) {
                        // 確認メッセージ
                    }

                    // 印刷処理
                    if (shikomi.is(':checked') === true) {
                        // 仕掛品仕込計画表印刷
                        prePrintDoc("shikomi");
                    }
                    else if (lot.is(':checked') === true) {
                        // 秤量記録表印刷
                        prePrintDoc("lot");
                    }
                    else if (check.is(':checked') === true) {
                        // 配合チェック表リスト印刷
                        prePrintDoc("check");
                    }

                });

                /// <summary>ダイアログを開きます。</summary>
                this.reopen = function (option) {
                    dialogNotifyInfo.clear();
                    dialogNotifyAlert.clear();
                    clearCriteriaDialog();
                    //clearStateDialog();
                    // 条件をセット
                    selectShikomiKakuteiFlg = option.param1;
                    criteria = option.param2;
                    selectShikakariLotNo = option.param3;
                    setButtonsetControl();
                };
            }
        });
    </script>
</head>
<body>
    <!-- ダイアログ固有のデザイン -- Start -->
    <div class="dialog-content">
        <!-- TODO: 画面の仕様に応じて以下のダイアログの設定を変更してください。 -->
        <div class="dialog-header">
            <h4 data-app-text="insatsuSentakuDialog">
            </h4>
        </div>
        <div class="dialog-body" style="padding: 10px; width: 95%;">
            <div class="dialog-search-criteria-print">
				<div class="part-body">
                    <div id="check-box-area">
                        <input type="checkbox" name="printCheck" id="shikomiKeikakuHyoCheck" value="shikomi", class="print-check"/>
                        <label for="shikomiKeikakuHyoCheck" class="checkLabelCol">
                            <span data-app-text="shikomiKeikauHyo"></span>
                        </label>

                        <input type="checkbox" name="printCheck" id="lotKirokuHyoCheck" value="lot", class="print-check"/>
                        <label for="lotKirokuHyoCheck" class="checkLabelCol">
                            <span data-app-text="lotKirokuHyo"></span>
                        </label>

                        <input type="checkbox" name="printCheck" id="checkHyoCheck" value="check", class="print-check"/>
                        <label for="checkHyoCheck" class="checkLabelCol">
                            <span data-app-text="checkHyo"></span>
                        </label>
                    </div>
				</div>
			</div>
            
        </div>
        <!-- TODO: ここまで  -->
        <div class="dialog-footer">
            <div class="command" style="position: absolute; left: 10px; top: 5px">
                <button class="dlg-insatsu-button" name="dlg-insatsu-button" data-app-text="insatsuButton">
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
