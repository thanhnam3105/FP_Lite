<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="NonyuIraishoSakusei.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.NonyuIraishoSakusei" %>
<asp:Content ID="Content1" ContentPlaceHolderID="IncludeContent" runat="server">
    <script src="<%=ResolveUrl("~/Resources/pages/pagedata-nonyuiraishosakusei." + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
    <script src="<%=ResolveUrl("~/Resources/grid/grid.locale-" + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
    <script src="<%=ResolveUrl("~/Resources/systemconst." + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
    <% Request.ContentType = "text/html;charset=UTF-8"; %>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        /* 画面デザイン -- Start */
        
        /* TODO：画面の仕様に応じて以下のスタイルを変更してください。 */
        .part-body .item-label
        {
            display: inline-block;
        }
                
        .part-body .item-list li
        {
            margin-bottom: .2em;
        }
        
        .search-criteria select
        {
            width: 20em;
        }
        
        .search-criteria .item-label
        {
            width: 10em;
        }

        .torihiki-dialog {
            background-color: White;
            width: 570px;
        }

        .hinmei-dialog
        {
            background-color: White;
            width: 590px;
        }

        .nohinsaki-dialog
        {
            background-color: White;
            width: 480px;
        }
        
        .teikeibun-dialog
        {
            background-color: White;
            width: 750px;
        }
        
        button.nohinsaki-button .icon
        {
            background-position: -48px -80px;
        }

        button.teikeibun-button .icon
        {
            background-position: -48px -80px;
        }
        
        .allprint-confirm-dialog
        {
            background-color: White;
            width: 350px;
        }
                
        .allprint-confirm-dialog .part-body
        {
            width: 95%;
        }
        
        .pagemaxim-confirm-dialog
        {
            background-color: White;
            width: 430px;
        }
                
        .pagemaxim-confirm-dialog .part-body
        {
            width: 95%;
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

            各コードブロック名を選択し Ctrl+F キーを押下することで
            Visual Studio の検索ダイアログを使用して該当のコードにジャンプできます。
            ・「TODO」で検索すると画面の仕様に応じて変更が必要なコードにジャンプできます。
            ・「画面アーキテクチャ共通」で検索すると画面アーキテクチャで共通のコードにジャンプできます。
            ・「グリッドコントロール固有」で検索するとグリッドコントロール固有のコードにジャンプできます。
            ・「ダイアログ固有」で検索するとダイアログ固有のコードにジャンプできます。
            */

            //// 変数宣言 -- Start

            // 画面アーキテクチャ共通の変数宣言
            var pageLangText = App.ui.pagedata.lang(App.ui.page.lang),
            //validationSetting = App.ui.pagedata.validation(App.ui.page.lang),
            //querySetting = { skip: 0, top: 40, count: 0 },
            //isDataLoading = false,
            //searchCondition,
                beforeSelectVal = pageLangText.selectToriHin.text;

            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            var outputCondition = {
                    torihikisakiCode: "",
                    hinmeiCode: "",
                    yoteiNashiItem: "",
                    bunruiKaiPage: "",
                    nohinsakiCode: "",
                    comment: "",
                    createDate: ""
                },
                renrakusaki;

            // 時刻を除いたシステム日付
            var systemDate = new Date(new Date().getFullYear(), new Date().getMonth(), new Date().getDate());

            // 文字列内の空白(全半角どちらも)を除去する
            var delBlank = function (str) {
                if (!App.isUndefOrNull(str)) {
                    str = str.replace(/[\s　]/g, "");
                }
                return str;
            };

            // trueの場合は1、それ以外は0を返却
            var changeFlag = function (flg) {
                if (!App.isUndefOrNull(flg)) {
                    if (flg) {
                        return pageLangText.trueFlg.text;
                    }
                }
                return pageLangText.falseFlg.text;
            };

            // 納入依頼書リスト画面に遷移する
            var openNonyuIraishoLst = function () {
                var url = "./NonyuIraishoList.aspx";
                // TODO: 遷移時に渡すパラメータを設定
                url += "?dt=" + outputCondition.createDate.replace(/[\/]/g, "");
                url += "&to=" + delBlank(outputCondition.torihikisakiCode);
                url += "&hi=" + delBlank(outputCondition.hinmeiCode);
                url += "&yo=" + changeFlag(outputCondition.yoteiNashiItem);
                url += "&bu=" + changeFlag(outputCondition.bunruiKaiPage);
                url += "&ni=" + outputCondition.nohinsakiCode;
                url += "&co=" + encodeURIComponent(outputCondition.comment);
                // TODO: ここまで
                window.location = url;
            };

            // 取引先選択時のダイアログ
            var torihikiDialog = $(".torihiki-dialog");
            torihikiDialog.dlg({
                url: "Dialog/TorihikisakiDialog.aspx",
                name: "TorihikisakiDialog",
                closed: function (e, data) {
                    if (data == "canceled") {
                        return;
                    }
                    else {
                        outputCondition.torihikisakiCode = data;

                        // 取引／品名選択だった場合
                        if (beforeSelectVal == pageLangText.selectToriHin.text) {
                            // 品名ダイアログを開く
                            showHinmeiDialog();
                        }
                        else {
                            // 納入依頼書リスト画面へ
                            openNonyuIraishoLst();
                        }
                    }
                }
            });

            // 品名選択時のダイアログ
            var hinmeiDialog = $(".hinmei-dialog");
            hinmeiDialog.dlg({
                url: "Dialog/HinmeiDialog.aspx",
                name: "HinmeiDialog",
                closed: function (e, data, data2) {
                    if (data == "canceled") {
                        return;
                    }
                    else {
                        outputCondition.hinmeiCode = data;
                        // 納入依頼書リスト画面に遷移
                        openNonyuIraishoLst();
                    }
                }
            });

            // 納品先一覧：荷受場所マスタダイアログ
            var nohinsakiDialog = $(".nohinsaki-dialog");
            nohinsakiDialog.dlg({
                url: "Dialog/NiukebashoDialog.aspx",
                name: "NiukebashoDialog",
                closed: function (e, data, data2) {
                    if (data == "canceled") {
                        return;
                    }
                    else {
                        // セレクタから取得した納品先を設定
                        outputCondition.nohinsakiCode = data;
                        $("#id_niuke_basho").text(data2);
                        // 枠線のエラー色を解除
                        //resetBorder("#id_niuke_basho");
                    }
                }
            });

            // 定型文一覧：コメントマスタダイアログ
            var teikeibunDialog = $(".teikeibun-dialog");
            teikeibunDialog.dlg({
                url: "Dialog/CommentDialog.aspx",
                name: "CommentDialog",
                closed: function (e, data, data2) {
                    if (data == "canceled") {
                        return;
                    }
                    else {
                        // セレクタから取得した定型文を追加(dataはコード)
                        var commentVal = $("#comment_area").val() + data2;
                        //$("#comment_area").append(data2); // appendだとIE以外でうまく動作しないときがあるのでvalを使用
                        $("#comment_area").val(commentVal);
                        resetBorder("#comment_area");
                    }
                }
            });

            // TODO: ここまで

            // ダイアログ固有の変数宣言
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            var allprintConfirmDialog = $(".allprint-confirm-dialog");
            var pageMaximConfirmDialog = $(".pagemaxim-confirm-dialog");
            // TODO：ここまで

            //// 変数宣言 -- End

            //// コントロール定義 -- Start

            // ダイアログ固有のコントロール定義
            allprintConfirmDialog.dlg();
            pageMaximConfirmDialog.dlg();

            /// 品名マスタセレクタを起動する
            var showHinmeiDialog = function () {
                option = { id: 'hinmei', multiselect: true, param1: pageLangText.genshizaiHinDlgParam.text };
                hinmeiDialog.draggable(true);
                //hinmeiDialog.draggable({ containment: document.body, scroll: false });    // IE以外では挙動がおかしい？保留中
                hinmeiDialog.dlg("open", option);
            }

            /// <summary>ダイアログを開きます。</summary>
            // 全件印刷選択時のダイアログ
            var showAllprintConfirmDialog = function () {
                allprintConfirmDialogNotifyInfo.clear();
                allprintConfirmDialogNotifyAlert.clear();
                allprintConfirmDialog.draggable(true);
                //allprintConfirmDialog.draggable({ containment: document.body, scroll: false }); // IE以外では挙動がおかしい？保留中
                allprintConfirmDialog.dlg("open");
            };
            // 上限印刷数オーバー時のダイアログ
            var showPageMaximConfirmDialog = function () {
                pageMaximConfirmDialogNotifyInfo.clear();
                pageMaximConfirmDialogNotifyAlert.clear();
                pageMaximConfirmDialog.draggable(true);
                //pageMaximConfirmDialog.draggable({ containment: document.body, scroll: false });  // IE以外では挙動がおかしい？保留中
                pageMaximConfirmDialog.dlg("open");
            };

            /// <summary>ダイアログを閉じます。</summary>
            var closeAllprintConfirmDialog = function () {
                allprintConfirmDialog.dlg("close");
            };
            /// <summary>ダイアログを閉じます。</summary>
            var closePageMaximConfirmDialog = function () {
                pageMaximConfirmDialog.dlg("close");
            };

            var datePickerFormat = pageLangText.dateFormatUS.text;
            if (App.ui.page.langCountry !== 'en-US') {
                datePickerFormat = pageLangText.dateFormat.text;
            }
            // TODO：画面の仕様に応じて以下の datepicker の設定を変更してください。
            $(".search-criteria [name='dt_sakusei_kaishi']").datepicker({ dateFormat: datePickerFormat });
            // TODO：ここまで

            // グリッド：当画面では未使用

            //// コントロール定義 -- End

            //// 操作制御定義 -- Start

            // 操作制御定義を定義します。
            App.ui.pagedata.operation.applySetting(App.ui.page.user.Roles[0], App.ui.page.lang);

            //// 操作制御定義 -- End

            //// 事前データロード -- Start 

            // 画面アーキテクチャ共通の事前データロード
            var loading;

            App.deferred.parallel({
                // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                // ローディング
                loading: App.ui.loading.show(pageLangText.nowProgressing.text)
                // TODO: ここまで
            }).done(function (result) {
                // TODO: 画面の仕様に応じて以下のサービス呼び出し成功時の処理を変更してください。
                // システム日付の翌日を挿入
                var sakuseiDate = new Date(new Date().getFullYear(), new Date().getMonth(), new Date().getDate() + 1);
                $(".search-criteria [name='dt_sakusei_kaishi']").datepicker("setDate", sakuseiDate);
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
                App.ui.loading.close();
            });

            //// 事前データロード -- End

            //// 検索処理 -- Start

            // グリッドコントロール固有の検索処理

            /// <summary>検索前バリデーションの初期化</summary>
            var searchValidation = Aw.validation({
                items: App.ui.pagedata.validation(App.ui.page.lang),
                handlers: {
                    success: function (results) {
                        var i = 0, l = results.length;
                        for (; i < l; i++) {
                            App.ui.page.notifyAlert.remove(results[i].element);
                            // textareaにはエラー赤枠がつかないので、手動で処理
                            if (results[i].item == "comment_area") {
                                resetBorder("#comment_area");
                            }
                        }
                    },
                    error: function (results) {
                        var i = 0, l = results.length;
                        for (; i < l; i++) {
                            App.ui.page.notifyAlert.message(results[i].message, results[i].element).show();
                            // textareaにはエラー赤枠がつかないので、手動で処理
                            if (results[i].item == "comment_area") {
                                setErrorBorder("#comment_area");
                            }
                        }
                    }
                }
            });
            $(".part-body .item-list").validation(searchValidation);

            //// 検索処理 -- End

            //// 出力条件の各処理 -- Start

            /// <summary>ダウンロードボタンクリック時のオーバレイ処理を行います。</summary>
            var downloadOverlay = function (renrakusaki) {
                App.ui.loading.show(pageLangText.nowProgressing.text);
                printPdf(renrakusaki);
                App.ui.loading.close();
            };
            /// <summary>PDFファイル出力を行います。</summary>
            var printPdf = function (renrakusaki) {

                //var query = {
                //    // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                //    url: "../api/NonyuIraishoListPDF",
                //    // TODO: ここまで
                //    //filter: createFilter()
                //    // TODO: 画面の仕様に応じて以下のソート条件を変更してください。
                //    orderby: "cd_hinmei"
                //    // TODO: ここまで
                //}

                // PDF出力用URLを取得
                //var url = getPdfUrl(query, renrakusaki);
                var url = getPdfUrl(renrakusaki);

                // 出力処理
                window.open(url, '_parent');
            };
            // 引数のパラメーターを設定したPDF出力用URLを取得
            var getPdfUrl = function (renrakusaki) {
                // 必要な情報を取得
                var creDateTo = App.date.localDate(outputCondition.createDate),
                    str = "",
                    renrakusakikojo = "",
                    renrakusakiTel = "",
                    renrakusakiFax = "",
                    renrakusakiKaisha = "";
                creDateTo.setDate(creDateTo.getDate() + 30);

                if (!App.isUndefOrNull(renrakusaki)) {
                    renrakusakikojo = renrakusaki.nm_kojo;
                    renrakusakiTel = renrakusaki.no_tel_1;
                    renrakusakiFax = renrakusaki.no_fax_1;
                    renrakusakiKaisha = renrakusaki.nm_kaisha;
                }

                var query = {
                        url: "../api/NonyuIraishoListPDF",
                        "lang": App.ui.page.lang,
                        "uuid": App.uuid(),
                        "printType": pageLangText.systemValueOne.text,
                        "yotei": outputCondition.yoteiNashiItem,
                        "bunrui": outputCondition.bunruiKaiPage,
                        "niukeCode": outputCondition.nohinsakiCode,
                        "hachuNo": "",
                        "dateFrom": App.data.getDateTimeStringForQueryNoUtc(App.date.localDate(outputCondition.createDate)),
                        "dateTo": App.data.getDateTimeStringForQueryNoUtc(creDateTo),
                        "cdLoginKaisha": App.ui.page.user.KaishaCode,
                        "cdLoginKojo": App.ui.page.user.BranchCode,
                        "renrakusaki": encodeURIComponent(renrakusakikojo),
                        "renTel": encodeURIComponent(renrakusakiTel),
                        "renFax": encodeURIComponent(renrakusakiFax),
                        "nohinsaki": "",
                        "nohinsakiAdd": "",
                        "torihikisaki": "",
                        "kbnKeishiki": "",
                        "comment": encodeURIComponent(outputCondition.comment),
                        "kaishaName": encodeURIComponent(renrakusakiKaisha),
                        "sysdate": App.data.getDateTimeStringForQueryNoUtc(systemDate),
                        "hinCode": "",
                        "torihikiCode": "",
                        "maxPages": pageLangText.pageMaximums.text,
                        "maxColumn": pageLangText.pdfColMaximums5.text,
                        "local_today": App.data.getDateTimeStringForQuery(new Date(), true)
                    };

                // URLにパラメータを設定
                url = App.data.toWebAPIFormat(query);

                return url;
            };
            // ヘッダー情報の取得処理
            var getHeader = function () {
                App.deferred.parallel({
                    // TODO: 画面の仕様に応じて以下のサービスのエンドポイントを変更してください。
                    // ローディング
                    loading: App.ui.loading.show(pageLangText.nowProgressing.text),
                    // 連絡先：工場マスタ
                    //renrakusaki: App.ajax.webget("../Services/FoodProcsService.svc/ma_kojo?$filter=cd_kaisha eq '"
                    //    + App.ui.page.user.KaishaCode + "' and  cd_kojo eq '" + App.ui.page.user.BranchCode + "'")
                    renrakusaki: App.ajax.webget("../Services/FoodProcsService.svc/ma_kojo?$orderby=cd_kaisha,cd_kojo&$top=1")
                    // TODO: ここまで
                }).done(function (result) {
                    // TODO: 画面の仕様に応じて以下のサービス呼び出し成功時の処理を変更してください。
                    renrakusaki = result.successes.renrakusaki.d;

                    // PDF出力処理へ
                    downloadOverlay(renrakusaki[0]);

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
                    App.ui.loading.close();
                });
            };
            /// <summary>PDFの出力件数(ページ数)のチェック</summary>
            /// <param name="query">クエリオブジェクト</param>
            var checkPageCount = function () {
                closeAllprintConfirmDialog();
                // ローディング開始
                App.ui.loading.show(pageLangText.nowProgressing.text);

                var creDateTo = App.date.localDate(outputCondition.createDate),
                    str = "";
                creDateTo.setDate(creDateTo.getDate() + 30);

                var query = {
                    url: "../api/NonyuIraishoListPDFCount",
                    printType: pageLangText.systemValueOne.text,
                    yotei: outputCondition.yoteiNashiItem,
                    bunrui: outputCondition.bunruiKaiPage,
                    niukeCode: outputCondition.nohinsakiCode,
                    dateFrom: App.data.getDateTimeStringForQueryNoUtc(App.date.localDate(outputCondition.createDate)),
                    dateTo: App.data.getDateTimeStringForQueryNoUtc(creDateTo),
                    torihikisaki: "",
                    sysdate: App.data.getDateTimeStringForQueryNoUtc(systemDate),
                    hinCode: "",
                    torihikiCode: "",
                    maxPages: pageLangText.pageMaximums.text,
                    maxColumn: pageLangText.pdfColMaximums5.text
                    //top: 1
                }

                App.ajax.webget(
                    App.data.toWebAPIFormat(query)
                ).done(function (result) {
                    App.ui.loading.close(); // ローディング終了
                    // ページがチェック数を超えていた場合、確認DLGを表示する
                    var cautionPages = parseInt(pageLangText.pageCautions.text);
                    var maxPages = parseInt(pageLangText.pageMaximums.text);
                    if (result > cautionPages) {
                        if (result > maxPages) {
                            // 上限数を超えていた場合、出力しない
                            App.ui.page.notifyAlert.message(
                                App.str.format(pageLangText.pageMaximumsOver.text, maxPages)
                            ).show();
                        }
                        else {
                            showPageMaximConfirmDialog();
                        }
                    }
                    else {
                        // 出力処理へ
                        allPrint();
                    }
                }).fail(function (result) {
                    App.ui.page.notifyAlert.message(result.message).show();
                }).always(function () {
                    // ローディング終了
                    App.ui.loading.close();
                });
            };
            /// <summary>全件印刷選択時のイベント処理を行います。</summary>
            var allPrint = function () {
                getHeader();
                return;
            };

            /// <summary>選択ボタンクリック時のイベント処理を行います。</summary>
            var openSelectWindow = function () {
                // メッセージのクリア
                App.ui.page.notifyInfo.clear();
                App.ui.page.notifyAlert.clear();

                // チェック処理
                if (!checkSelect()) {
                    return;
                }

                // 値の取得
                outputCondition.createDate = $("#condition-date").val();
                outputCondition.yoteiNashiItem = $("#check-yotei").prop("checked");
                outputCondition.bunruiKaiPage = $("#check-bunruigoto").prop("checked");
                outputCondition.comment = $("#comment_area").val();

                // 選択画面へ
                var selectVal = $("input:radio[name='select_print']:checked").val(),
                    option;
                switch (selectVal) {
                    // 取引先   
                    // 取引先／品名   
                    case pageLangText.selectToriHin.text:
                    case pageLangText.selectTorihiki.text:
                        option = { id: 'torihiki', multiselect: true, param1: pageLangText.shiiresakiToriKbn.text };
                        torihikiDialog.draggable(true);
                        //torihikiDialog.draggable({ containment: document.body, scroll: false });    // IE以外では挙動がおかしい？保留中
                        torihikiDialog.dlg("open", option);
                        break;
                    // 品名   
                    case pageLangText.selectHinmei.text:
                        outputCondition.torihikisakiCode = "";  // 取引先コードクリア
                        showHinmeiDialog();
                        break;
                    // 全件印刷   
                    case pageLangText.selectAllPrint.text:
                        showAllprintConfirmDialog();
                        break;
                    default:
                        // ラジオボタンなので有り得ないが、念のため実装：MSG「出力条件を選択してください。(MS0044)」
                        App.ui.page.notifyAlert.message(
                            App.str.format(pageLangText.selectNone.text, pageLangText.selectCriteria.text)
                        ).show();
                        break;
                }
                return;
            };
            /// <summary>選択ボタンクリック時のチェック処理を行います。</summary>
            var checkSelect = function () {
                var isValid = true,
                    commentValid = true;

                // バリデーション
                var result = $(".part-body .item-list").validation().validate();
                if (result.errors.length) {
                    return false;
                }

                // 相関チェック
                // 「納品先　代替場所指定」チェックありの場合、代替場所が入力されていること
                if ($("#check-nohinsaki").prop('checked')) {
                    var niukeBasho = $("#id_niuke_basho").text();
                    if (App.isUndefOrNull(niukeBasho) || niukeBasho == "") {
                        App.ui.page.notifyAlert.message(
                            App.str.format(pageLangText.selectRequired.text, pageLangText.reqMsgNohinsaki.text)
                        ).show();
                        isValid = false;
                    }
                }

                // 「コメント」チェックありの場合、コメント欄が入力されていること
                if ($("#check-comment").prop('checked')) {
                    var comment = $("#comment_area").val();
                    if (App.isUndefOrNull(comment) || comment == "") {
                        App.ui.page.notifyAlert.message(
                            App.str.format(pageLangText.selectRequired.text, pageLangText.reqMsgComment.text)
                        ).show();
                        commentValid = false;
                        isValid = false;
                    }
                }

                return isValid;
            };
            // 枠線をエラー状態にする
            var setErrorBorder = function (targetId) {
                // border→colorの順でないと色が変わらないので注意
                $(targetId).css({ "border": "solid 2px", "border-color": "#FF6666" });
            };
            // エラー状態の枠線を元に戻す
            var resetBorder = function (targetId) {
                $(targetId).css({ "border": "solid 1px", "border-color": "" });
            };
            $(".select-button").on("click", openSelectWindow);

            //// 出力条件の各処理 -- End

            //// メッセージ表示 -- Start

            // グリッドコントロール固有のメッセージ表示

            /// <summary>エラー一覧クリック時の処理を行います。</summary>
            /// <param name="data">エラー情報</param>
            var handleNotifyAlert = function (data) {
                //data.unique でキーが取得できる
                //data.handledにtrueを指定することでデフォルトの動作(キーがHTMLElementの場合にフォーカスを当てる処理)の実行をキャンセルする

                // グリッド内のエラーの場合、data.uniqueがstringになるため以下の条件分岐を追加
                if (!App.isStr(data.unique)) {
                    data.handled = false;
                    return;
                }
                data.handled = true;
            };
            /// <summary>エラー一覧クリック時のイベント処理を行います。</summary>
            $(App.ui.page.notifyAlert).on("itemselected", function (e, data) {
                // エラー一覧クリック時の処理
                handleNotifyAlert(data);
            });

            // ダイアログ固有のメッセージ表示
            // ダイアログ情報メッセージの設定

            // 全件印刷選択時ダイアログ情報メッセージの設定
            var allprintConfirmDialogNotifyInfo = App.ui.notify.info(allprintConfirmDialog, {
                container: ".allprint-confirm-dialog .dialog-slideup-area .info-message",
                messageContainerQuery: "ul",
                show: function () {
                    allprintConfirmDialog.find(".info-message").show();
                },
                clear: function () {
                    allprintConfirmDialog.find(".info-message").hide();
                }
            });
            // 印刷時ページが上限値に達したときのダイアログ情報メッセージの設定
            var pageMaximConfirmDialogNotifyInfo = App.ui.notify.info(pageMaximConfirmDialog, {
                container: ".pagemaxim-confirm-dialog .dialog-slideup-area .info-message",
                messageContainerQuery: "ul",
                show: function () {
                    pageMaximConfirmDialog.find(".info-message").show();
                },
                clear: function () {
                    pageMaximConfirmDialog.find(".info-message").hide();
                }
            });

            // ダイアログ警告メッセージの設定
            var allprintConfirmDialogNotifyAlert = App.ui.notify.alert(allprintConfirmDialog, {
                container: ".allprint-confirm-dialog .dialog-slideup-area .alert-message",
                messageContainerQuery: "ul",
                show: function () {
                    allprintConfirmDialog.find(".alert-message").show();
                },
                clear: function () {
                    allprintConfirmDialog.find(".alert-message").hide();
                }
            });
            var pageMaximConfirmDialogNotifyAlert = App.ui.notify.alert(pageMaximConfirmDialog, {
                container: ".pagemaxim-confirm-dialog .dialog-slideup-area .alert-message",
                messageContainerQuery: "ul",
                show: function () {
                    pageMaximConfirmDialog.find(".alert-message").show();
                },
                clear: function () {
                    pageMaximConfirmDialog.find(".alert-message").hide();
                }
            });

            //// メッセージ表示 -- End

            //// データ変更処理 -- Start
            //// データ変更処理 -- End

            /// <summary>納品先一覧ボタンクリック時のイベント処理を行います。</summary>
            $(".nohinsaki-button").on("click", function (e) {
                // 納品先　代替場所指定にチェックが無い場合は処理を抜ける
                if (!$("#check-nohinsaki").prop('checked')) {
                    return;
                }

                var option = { id: 'nohinsaki', multiselect: false };
                nohinsakiDialog.draggable(true);
                // ドラッグ範囲を指定
                //nohinsakiDialog.draggable({ containment: document.body, scroll: false }); // IE以外では挙動がおかしい？保留中
                nohinsakiDialog.dlg("open", option);
            });

            /// <summary>定型文一覧ボタンクリック時のイベント処理を行います。</summary>
            $(".teikeibun-button").on("click", function (e) {
                // コメントにチェックが無い場合は処理を抜ける
                if (!$("#check-comment").prop('checked')) {
                    return;
                }
                var option = { id: 'teikeibun', multiselect: false };
                teikeibunDialog.draggable(true);
                // ドラッグ範囲を指定
                //teikeibunDialog.draggable({ containment: document.body, scroll: false }); // IE以外では挙動がおかしい？保留中
                teikeibunDialog.dlg("open", option);
            });

            //// 保存処理 -- Start
            //// 保存処理 -- End

            //// バリデーション -- Start

            // グリッドコントロール固有のバリデーション

            // TODO: 画面の仕様に応じて以下のカスタムバリデーション定義を変更してください。
            // TODO: ここまで

            // グリッドのバリデーション設定
            //var v = Aw.validation({
            //    items: validationSetting
            //});

            //// バリデーション -- End

            /// <summary>ファンクションキー対応処理</summary>
            /// <param name="e">イベントデータ</param>
            var processFunctionKey = function (e) {
                var processed = false;
                // TODO: 画面の仕様に応じて以下のファンクションキー毎の処理を定義します。
                if (e.keyCode === App.ui.keys.F2) {
                    // F2の処理
                    processed = true;
                }
                else if (e.keyCode === App.ui.keys.F3) {
                    // F3の処理
                    processed = true;
                }
                // TODO: ここまで
                if (processed) {
                    //何か処理を行なっていた場合、ブラウザ既定の動作を無効にする
                    e.preventDefault();
                }
            };
            /// <summary>キーダウン時のイベント処理を行います。</summary>
            $(window).on("keydown", processFunctionKey);

            /// <summary>コンテンツのリサイズを行います。</summary>
            var resizeContents = function (e) {
                var container = $(".content-container"),
                    searchPart = $(".search-criteria");
            };
            /// <summary>画面リサイズ時のイベント処理を行います。</summary>
            $(App.ui.page).on("resized", resizeContents);

            /// <summary>全件印刷確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".allprint-confirm-dialog .dlg-yes-button").on("click", checkPageCount);
            // <summary>全件印刷確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".allprint-confirm-dialog .dlg-no-button").on("click", closeAllprintConfirmDialog);

            /// <summary>チェックページ数を超えていたときの印刷確認ダイアログの「はい」ボタンクリック時のイベント処理を行います。</summary>
            $(".pagemaxim-confirm-dialog .dlg-yes-button").on("click", function () {
                closePageMaximConfirmDialog();
                // 時間がかかる為、その間操作しないよう注意メッセージ：infoだと数秒で消えてしまう為、alertで表示
                App.ui.page.notifyAlert.message(pageLangText.notOperate.text).show();
                // 出力処理へ
                allPrint();
            });
            // <summary>チェックページ数を超えていたときの印刷確認ダイアログの「いいえ」ボタンクリック時のイベント処理を行います。</summary>
            $(".pagemaxim-confirm-dialog .dlg-no-button").on("click", closePageMaximConfirmDialog);

            /// <summary>コメントチェックボックスのイベント処理を行います。</summary>
            $("#check-comment").click(function () {
                if ($("#check-comment").prop('checked')) {
                    $(".teikeibun-button").attr("disabled", false);
                    $("#comment_area").attr("readonly", false).css("background-color", "#FFFFFF");
                }
                else {
                    $(".teikeibun-button").attr("disabled", true);
                    $("#comment_area").attr("readonly", true).css("background-color", "#F2F2F2");
                    $("#comment_area").val("");
                }
            });

            /// <summary>納品先チェックボックスのイベント処理を行います。</summary>
            var changeNohinButton = function () {
                if ($("#check-nohinsaki").prop('checked')) {
                    $(".nohinsaki-button").attr("disabled", false);
                }
                else {
                    $(".nohinsaki-button").attr("disabled", true);
                    $("#id_niuke_basho").text("");
                }
            };
            $("#check-nohinsaki").click(function () {
                changeNohinButton();
            });

            /// <summary>選択された出力条件によるチェックボックスの制御を行います。</summary>
            // チェックボックスの制御ここから
            // 入力可：false　入力不可：true
            var controlCheckBox = function (yotei, bunrui, nohin) {
                // チェックボックスのクリア
                $("#check-yotei, #check-bunruigoto, #check-nohinsaki").removeAttr('checked');
                // 制御
                $("#check-yotei").attr("disabled", yotei);
                $("#check-bunruigoto").attr("disabled", bunrui);
                $("#check-nohinsaki").attr("disabled", nohin);
                // 何が選択されたかを保持
                beforeSelectVal = $("input:radio[name='select_print']:checked").val();
            }

            // 取引先が選択された場合
            // 予定なし：×　分類毎：○　代替場所指定：○
            $("#select-torihiki").click(function () {
                if (beforeSelectVal == pageLangText.selectTorihiki.text) {
                    // 何が選択されたかを保持
                    beforeSelectVal = $("input:radio[name='select_print']:checked").val();
                    return;
                }
                controlCheckBox(true, false, false);
            });

            // 品名が選択された場合
            // 予定なし：○　分類毎：○　代替場所指定：×
            $("#select-hinmei").click(function () {
                if (beforeSelectVal == pageLangText.selectHinmei.text) {
                    return;
                }
                controlCheckBox(false, false, true);
                $("#id_niuke_basho").text("");
                changeNohinButton();
            });

            // 全件印刷が選択された場合
            // 予定なし：×　分類毎：○　代替場所指定：×
            $("#select-allprint").click(function () {
                if (beforeSelectVal == pageLangText.selectAllPrint.text) {
                    return;
                }
                controlCheckBox(true, false, true);
                $("#id_niuke_basho").text("");
                changeNohinButton();
            });

            // 取引先／品名が選択された場合
            // 予定なし：○　分類毎：○　代替場所指定：○
            $("#select_tori_hin").click(function () {
                if (beforeSelectVal == pageLangText.selectToriHin.text) {
                    // 何が選択されたかを保持
                    beforeSelectVal = $("input:radio[name='select_print']:checked").val();
                    return;
                }
                controlCheckBox(false, false, false);
            });
            // チェックボックスの制御ここまで

            /// <summary>メニューボタンクリック時のイベント処理を行います。</summary>
            var backToMenu = function () {
                // IEバグによる例外発生をキャッチします。例外発生時は何もしません。
                try {
                    document.location = "./MainMenu.aspx";
                } catch (e) {
                }
            };
            /// <summary>メニューボタンクリック時のイベント処理を行います。</summary>
            $(".menu-button").on("click", backToMenu);
        });
    </script>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <!-- 画面デザイン -- Start -->

    <!-- 出力条件 -->
    <div class="content-part search-criteria">
        <h3 class="part-header" data-app-text="selectCriteria"></h3>
        <div class="part-body">
            <ul class="item-list item-command">
                <!-- TODO: 画面の仕様に応じて以下の項目を変更してください。-->
                <li>
                    <!-- 作成開始日 -->
                    <label>
                        <span class="item-label" style="width: 120px" data-app-text="dt_sakusei_kaishi"></span>
                        <input type="text" name="dt_sakusei_kaishi" id="condition-date" style="width: 100px" />
                        <span class="item-label" style="width: 30px">&nbsp;</span>
                    </label>
                    <label>
                        <span class="item-label">&nbsp;</span> <span class="item-label" style="width: 123px">
                            &nbsp;</span>
                    </label>
                </li>
                <li>
                    <!-- スペース -->
                    <label>
                        <span class="item-label">&nbsp;</span>
                    </label>
                    <label>
                        <span class="item-label">&nbsp;</span>
                    </label>
                </li>
                <li>
                    <!-- ラジオボタン：取引/品名選択 -->
                    <label>
                        <input type="radio" name="select_print" id="select_tori_hin" value="4" checked="checked" /><span class="item-label" style="width: 150px" data-app-text="select_torihiki_hinmei"></span>
                    </label>
                    <label>
                        <span class="item-label" style="width: 50px">&nbsp;</span>
                    </label>
                    <!-- チェックボックス：予定なしの品目も出力する -->
                    <label>
                        <input type="checkbox" name="yotei_nashi" id="check-yotei" /><span class="item-label" style="width: 400px" data-app-text="yotei_nashi"></span>
                    </label>
                </li>
                <li>
                    <!-- ラジオボタン：取引先選択 -->
                    <label>
                        <input type="radio" name="select_print" id="select-torihiki" value="1" /><span class="item-label" style="width: 150px" data-app-text="select_torihiki"></span>
                    </label>
                    <label>
                        <span class="item-label" style="width: 50px">&nbsp;</span>
                    </label>
                    <!-- チェックボックス：分類毎に改頁する -->
                    <label>
                        <input type="checkbox" name="bunruigoto" id="check-bunruigoto" /><span class="item-label" style="width: 400px" data-app-text="bunruigoto"></span>
                    </label>
                </li>
                <li>
                    <!-- ラジオボタン：品名選択 -->
                    <label>
                        <input type="radio" name="select_print" id="select-hinmei" value="2" /><span class="item-label" style="width: 150px" data-app-text="select_hinmei"></span>
                    </label>
                    <label>
                        <span class="item-label" style="width: 50px">&nbsp;</span>
                    </label>
                    <!-- チェックボックス：納品先 -->
                    <label>
                        <input type="checkbox" name="nohinsaki" id="check-nohinsaki" /><span class="item-label" style="width: 400px" data-app-text="nohinsaki"></span>
                    </label>
                </li>
                <li>
                    <!-- ラジオボタン：全件印刷 -->
                    <label>
                        <input type="radio" name="select_print" id="select-allprint" value="3" /><span class="item-label" style="width: 150px" data-app-text="select_all_print"></span>
                    </label>
                    <label>
                        <span class="item-label" style="width: 50px">&nbsp;</span>
                    </label>
                    <!-- label>
                        <span class="item-label" style="width: 225px">&nbsp;</span>
                    </label -->
                    <!-- ボタン：納品先一覧 -->
                    <label>
                        <button type="button" class="dialog-button nohinsaki-button" name="nohinsaki-button" disabled="disabled" data-app-operation="nohinsakiIchiran" style="width:120px;">
                            <span class="icon"></span><span data-app-text="nohinsakiIchiran"></span>
                        </button>
                    </label>
                    <!-- 納品場所表示欄 -->
                    <label>
                        <!--input id="id_niuke_basho" class="readonly-txt" readonly="readonly" type="text" name="niuke_basho" style="width:140px;" / -->
                        <span class="item-label" id="id_niuke_basho" name="niuke_basho" style="width: 400px"></span>
                    </label>
                </li>
                <!-- スペース -->
                <li>
                    <label>
                        <span class="item-label" style="width: 50px">&nbsp;</span>
                    </label>
                </li>
                <!-- コメント(定型文) -->
                <li>
                    <label>
                        <input type="checkbox" name="comment" id="check-comment" /><span class="item-label" style="width: 60px" data-app-text="comment"></span>
                    </label>
                    <label>
                        <button type="button" class="dialog-button teikeibun-button" name="teikeibun-button" disabled="disabled" data-app-operation="teikeibunIchiran">
                            <span class="icon"></span><span data-app-text="teikeibunIchiran"></span>
                        </button>
                    </label>
                </li>
                <li>
                    <label>
                        <input type="text" class="readonly-txt" id="comment_area" name="comment_area" style="width: 450px" maxlength="100" />
                    </label>
                </li>
                <!-- TODO: ここまで -->
            </ul>
        </div>
    </div>

    <!-- 画面デザイン -- End -->
</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="FooterContent" runat="server">
    <!-- 画面デザイン -- Start -->

    <!-- 画面アーキテクチャ共通のデザイン -- Start -->
    <div class="command" style="left: 1px;">
        <!-- TODO: 画面の仕様に応じて以下のボタンを変更してください。 -->
        <button type="button" class="select-button" name="select-button" data-app-operation="select">
            <span class="icon"></span>
            <span data-app-text="select"></span>
        </button>
        <!-- TODO: ここまで -->
    </div>
    <div class="command" style="right: 9px;">
        <button type="button" class="menu-button" name="menu-button">
            <span class="icon"></span>
            <span data-app-text="menu"></span>
        </button>
    </div>
    <!-- 画面アーキテクチャ共通のデザイン -- End -->

    <!-- 画面デザイン -- End -->
</asp:Content>
<asp:Content ID="Content5" ContentPlaceHolderID="DialogsContent" runat="server">
    <!-- 画面デザイン -- Start -->
    <!-- ダイアログ固有のデザイン -- Start -->

    <!-- TODO: 画面の仕様に応じて以下のダイアログの設定を変更してください。 -->
    <div class="allprint-confirm-dialog" style="display: none;">
        <div class="dialog-header">
            <h4 data-app-text="confirmTitle"></h4>
        </div>
        <div class="dialog-body" style="padding: 10px; width: 100%;">
            <div class="part-body">
                <span data-app-text="printConfirm"></span>
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
    <div class="pagemaxim-confirm-dialog" style="display: none;">
        <div class="dialog-header">
            <h4 data-app-text="confirmTitle"></h4>
        </div>
        <div class="dialog-body" style="padding: 10px; width: 100%;">
            <div class="part-body">
                <span data-app-text="pageCautionsOverConfirm"></span>
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
    <div class="torihiki-dialog">
    </div>
    <div class="hinmei-dialog">
    </div>
    <div class="nohinsaki-dialog">
    </div>
    <div class="teikeibun-dialog">
    </div>
    <!-- TODO: ここまで  -->

    <!-- 画面デザイン -- End -->
</asp:Content>
