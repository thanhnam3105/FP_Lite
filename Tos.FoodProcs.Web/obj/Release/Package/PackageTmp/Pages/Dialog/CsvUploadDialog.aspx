<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CsvUploadDialog.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.Dialog.CsvUploadDialog" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <!-- include -->
    <script src="../Scripts/uploadfile.js" type="text/javascript"></script>
    <title></title>
    <style type="text/css">
        /* 画面デザイン -- Start */
        .dialog-content .item-label {
            width: 12em;
            line-height: 180%;
        }
        .dialog-content .item-input {
            width: 12em;
            line-height: 180%;
        }

        /* 画面デザイン -- End */
    </style>
    <script type="text/javascript" >
        $.dlg.register("CsvUploadDialog", {
            initialize: function (context) {
                //// 変数宣言 -- Start
                var elem = context.element,
                    pageLangText = App.ui.pagedata.lang(App.ui.page.lang),
                    workId = context.data.workId,   // 処理選別用ID
                    params = context.data.params;        // 元画面からのデータ(JSON形式)

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

                /// <summary>メッセージクリア処理を定義します。</summary>
                var clearMessages = function () {
                    // 情報メッセージのクリア
                    dialogNotifyInfo.clear();
                    // エラーメッセージのクリア
                    dialogNotifyAlert.clear();
                };

                /// <summary>初期化処理を定義します。</summary>
                var clearStateDialog = function () {
                    // メッセージのクリア
                    clearMessages();
                    // 選択ファイルをクリア
                    $("#csvFile").replaceWith('<input type="file" id="csvFile" name="csvFile" style="width: 400px;" />');
                };

                /// <summary>ダイアログを閉じる処理を定義します。</summary>
                var closeCsvDialog = function () {
                    context.close("canceled");
                };

                /// <summary>CSVファイルをアップロードする処理を定義します。</summary>
                var uploadCsvFile = function () {

                    var fileName = elem.find("#csvFile").val()
                        , options = {};

                    // メッセージのクリア
                    clearMessages();

                    // ファイルが選択されていない場合は処理中止
                    if (fileName == "") {
                        var errMsg = App.str.format(MS0044, pageLangText.fileName.text);
                        dialogNotifyAlert.message(errMsg).show();
                        return;
                    }

                    // ローディングの表示
                    App.ui.loading.show(pageLangText.uploading.text, ".dialog-content");


                    // TODO ここから: それぞれの呼び出し元用の処理をここに記述して下さい

                    // 呼び出し画面機能によってコントローラを選択します。
                    switch (workId) {
                        case "1":
                            // 原資材在庫入力
                            options = {
                                url: "../api/GenshizaiZaikoNyuryokuCSV"
                            };

                            // コントローラへ引き渡すパラメタセット
                            genshizaiZaikoNyuryokuWork(1);
                            break;

                        default:
                            App.ui.loading.close(".dialog-content");
                            return;
                    };

                    // TODO ここまで: それぞれの呼び出し元用の処理をここに記述して下さい


                    // 取り込み処理
                    $("#csv-upload-form").uploadfile(options)
                    .done(function (result) {
                        // アップロード処理成功後の処理を定義します。
                        switch (workId) {
                            case "1":
                                // 原資材在庫入力
                                genshizaiZaikoNyuryokuWork(2);
                                break;
                            default:
                                break;
                        }

                    }).fail(function (result) {
                        dialogNotifyAlert.clear();
                        dialogNotifyAlert.message(result.message).show();
                    }).always(function () {
                        // ローディングの終了
                        App.ui.loading.close(".dialog-content");
                    });
                };

                /// 各画面用機能定義

                /// <summary>原資材在庫入力画面から呼び出した場合の処理を定義します。</summary>
                var genshizaiZaikoNyuryokuWork = function (kbn) {
                    switch (kbn) {
                        case 1:
                            // upload前の処理
                            var tags = "";

                            // 初期化処理
                            elem.find("#paramForm").find("INPUT").replaceWith("");

                            // タグ生成処理
                            params.offset = new Date().getTimezoneOffset() / 60;
                            for (var p in params) {
                                if (!params.hasOwnProperty(p)) {
                                    continue;
                                }
                                tags += App.str.format("<input type='hidden' name='{0}' value='{1}' />", p, params[p]);
                            }

                            // コントローラで使用する値をセット
                            elem.find("#paramForm").append(tags);
                            break;

                        case 2:
                            // upload後のdone処理
                            // 画面を閉じます。
                            context.close("done");
                            break;
                        default:
                            break;
                    };
                };

                /// イベント定義

                /// <summary>閉じるボタンクリック時のイベント処理を行います。</summary>
                elem.find(".dlg-cancel-button").on("click", closeCsvDialog);

                /// <summary>アップロードボタンクリック時のイベント処理を行います。</summary>
                elem.find(".dlg-ok-button").on("click", uploadCsvFile);

                /// バリデーション

                /// 再表示処理

                /// <summary>ダイアログを開きます。</summary>
                this.reopen = function (option) {
                    // 引数の再取得
                    workId = option.workId;
                    params = option.params;
                    // 初期化処理
                    clearStateDialog();
                };
                clearStateDialog();
            }
        });
    </script>
</head>
<body>
    <!-- ダイアログ固有のデザイン -- Start -->
    <div class="dialog-content">
        <!-- TODO: 画面の仕様に応じて以下のダイアログの設定を変更してください。 -->
        <div class="dialog-header">
            <h4 data-app-text="upload"></h4>
        </div>
        <div class="dialog-body" style="padding: 10px; width: 95%;">
            <div class="dialog-search-criteria">
                <div class="part-body" id="csv-upload-form">
                    <ul class="item-list">
                        <li>
                            <label>
                                <span class="item-label" data-app-text="fileName"></span>
                            </label>
                            <label>
                                <input type="file" id="csvFile" name="csvFile" style="width: 400px;" />
                            </label>
                            <div id="paramForm"></div>
                        </li>
                    </ul>
                </div>
            </div>
        </div>
    <!-- TODO: ここまで  -->
        <div class="dialog-footer">
            <div class="command" style="position: absolute; left: 10px; top: 5px">
                <button class="dlg-ok-button" name="dlg-ok-button" data-app-text="upload"></button>
            </div>
            <div class="command" style="position: absolute; right: 5px; top: 5px;">
                <button class="dlg-cancel-button" name="dlg-cancel-button" data-app-text="close"></button>
            </div>
        </div>
        <div class="message-area dialog-slideup-area" >
            <div class="alert-message" style="display: none" data-app-text="title:alertTitle" >
                <ul>        
                </ul>
            </div>
            <div class="info-message" style="display: none" data-app-text="title:infoTitle" >
                <ul>
                </ul>
            </div>
        </div>
    </div>
</body>
</html>
