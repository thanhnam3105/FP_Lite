<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="HakariSample.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.SearchList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="IncludeContent" runat="server">
    <script src="<%=ResolveUrl("~/Resources/pages/pagedata-hakarisample." + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
    <script src="<%=ResolveUrl("~/Resources/grid/grid.locale-" + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
    <OBJECT ID="SerialPort" CLASSID="CLSID:A3FFF0A8-21BD-4F68-B328-EA4BCD0749EB" CODEBASE="http://localhost/spactx.dll#version=1,0,0,1"></OBJECT>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        /* 画面デザイン -- Start */
        
        /* TODO：画面の仕様に応じて以下のスタイルを変更してください。 */
        
        #loopData 
        {
            font-size: 400%;
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
                validationSetting = App.ui.pagedata.validation(App.ui.page.lang),
                querySetting = { skip: 0, top: 40, count: 0 },
                isDataLoading = false;

            // グリッドコントロール固有の変数宣言
            // TODO：画面の仕様に応じて以下の変数宣言を変更してください。
            var lastScrollTop = 0,
                nextScrollTop = 0;
            // TODO: ここまで

            //// 変数宣言 -- End

            //// コントロール定義 -- Start
            //// コントロール定義 -- End

            //// 操作制御定義 -- Start
            $(".beep-button").on("click", function () {
                SerialPort.Beep();
            });
            $(".portname-button").on("click", function () {
                var names;
                names = SerialPort.GetPortNames();
                $("#portNameResult").val(names);
            });
            $(".portopen-button").on("click", function () {
                var result;
                result = SerialPort.Open($("#openTargetPort").val());
                SerialPort.BaudRate = 2400;
                SerialPort.ByteSize = 7;
                SerialPort.ReadTimeout = 1000;
                alert(pageLangText.methodReturn[result]);
            });
            $(".portclose-button").on("click", function () {
                var result;
                result = SerialPort.Close();
                alert(pageLangText.methodReturn[result]);
            });
            $(".checkport-button").on("click", function () {
                var result;
                result = SerialPort.IsPortAvailable($("#checkTargetPort").val());
                alert(pageLangText.methodReturn[result]);
            });
            $(".writeline-button").on("click", function () {
                var result;
                result = SerialPort.WriteLine($("#writeLineData").val());
                alert(pageLangText.methodReturn[result]);
            });
            $(".readline-button").on("click", function () {
                var result;
                result = SerialPort.ReadLine();
                alert(pageLangText.methodReturn[result]);
                $("#readLineData").val(SerialPort.GetData());
            });
            $(".readall-button").on("click", function () {
                var result;
                result = SerialPort.Read();
                alert(pageLangText.methodReturn[result]);
                $("#readLineData").val(SerialPort.GetData());
            });
            $(".getbaudrate-button").on("click", function () {
                $("#baudrate").val(SerialPort.BaudRate);
            });
            $(".setbaudrate-button").on("click", function () {
                SerialPort.BaudRate = $("#baudrate").val();
            });
            $(".getbytesize-button").on("click", function () {
                $("#byteSize").val(SerialPort.ByteSize);
            });
            $(".setbytesize-button").on("click", function () {
                SerialPort.ByteSize = $("#byteSize").val();
            });
            $(".getparity-button").on("click", function () {
                $("#parity").val(SerialPort.Parity);
            });
            $(".setparity-button").on("click", function () {
                SerialPort.Parity = $("#parity").val();
            });
            $(".getstopbit-button").on("click", function () {
                $("#stopBits").val(SerialPort.StopBits);
            });
            $(".setstopbit-button").on("click", function () {
                SerialPort.StopBits = $("#stopBits").val();
            });
            $(".gettimeout-button").on("click", function () {
                $("#timeout").val(SerialPort.ReadTimeout);
            });
            $(".settimeout-button").on("click", function () {
                SerialPort.ReadTimeout = $("#timeout").val();
            });

            var loopFlagClosure = function () {
                var flag = false;
                return function () {
                    flag = !flag;
                    return flag;
                };
            };

            var loopFlag = loopFlagClosure();
            var loopable;
            var loopTimer;

            $(".startloop-button").on("click", function () {
                if (!loopable) {
                    loopable = loopFlag();
                }
                var result;
                result = SerialPort.Open($("#openTargetPort").val());
                SerialPort.BaudRate = 2400;
                SerialPort.ByteSize = 7;
                SerialPort.ReadTimeout = 1000;
                if (result != 0) {
                    alert(pageLangText.methodReturn[result]);
                    return;
                }
                loopRead();
            });
            $(".stoploop-button").on("click", function () {
                if (loopable) {
                    loopable = loopFlag();
                    alert(loopable);
                }
            });

            var loopRead = function () {
                var result;
                if (!loopable) {
                    result = SerialPort.Close();
                    if (result != 0) {
                        alert(pageLangText.methodReturn[result]);
                    }
                    return;
                }
                SerialPort.ReadTimeout = 100;
                result = SerialPort.ReadLine();
                if (result != 0 && result != -1) {
                    alert(pageLangText.methodReturn[result]);
                    loopable = loopFlag();
                }
                var readdata = SerialPort.GetData();
                if (readdata != "") {
                    $("#loopData").val(readdata);
                }

                $.timeout = function (time) {
                    return $.Deferred(function (dfd) {
                        setTimeout(dfd.resolve, time);
                    }).promise();
                }

                $.timeout(100).then(function () {
                    loopRead();
                });
            };

            $(document).on("dblclick", function () {
                var isOpen = SerialPort.IsPortAvailable($("#openTargetPort").val());
                alert(pageLangText.methodReturn[isOpen]);
                if (isOpen != 0) {
                    alert("ポート閉じます");
                    result = SerialPort.Close();
                    //if (result != 0) {
                    alert(pageLangText.methodReturn[result]);
                    //}
                    return;
                }
                alert("ポート閉じてます");
            });

            //// 操作制御定義 -- End

            //// 事前データロード -- Start 

            //// 事前データロード -- End

            //// 検索処理 -- Start

            // 画面アーキテクチャ共通の検索処理

            // グリッドコントロール固有の検索処理

            //// 検索処理 -- End

            //// メッセージ表示 -- Start

            //// メッセージ表示 -- End

            //// データ変更処理 -- Start

            //// データ変更処理 -- End

            //// 保存処理 -- Start

            //// 保存処理 -- End

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

            //// バリデーション -- End
        });
    </script>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <!-- 画面デザイン -- Start -->
    <div class="part-body">
        <ul class="item-list">
            <li>
                <button type="button" class="beep-button">
                    <span class="icon"></span><span data-app-text="beep"></span>
                </button>
            </li>
            <li>
                <button type="button" class="portname-button">
                    <span class="icon"></span><span data-app-text="portName"></span>
                </button>
                <input type="text" id="portNameResult" value="" />
            </li>
            <li>
                <button type="button" class="portopen-button">
                    <span class="icon"></span><span data-app-text="portOpen"></span>
                </button>
                <input type="text" id="openTargetPort" value="COM3" />
            </li>
            <li>
                <button type="button" class="portclose-button">
                    <span class="icon"></span><span data-app-text="portClose"></span>
                </button>
            </li>
            <li>
                <button type="button" class="checkport-button">
                    <span class="icon"></span><span data-app-text="checkPort"></span>
                </button>
                <input type="text" id="checkTargetPort" value="COM3" />
            </li>
            <li>
                <button type="button" class="writeline-button">
                    <span class="icon"></span><span data-app-text="writeLineData"></span>
                </button>
                <input type="text" id="writeLineData" value="ABCDEFG" />
            </li>
            <li>
                <button type="button" class="readline-button">
                    <span class="icon"></span><span data-app-text="readLineData"></span>
                </button>
                <input type="text" id="readLineData" value="" />
            </li>
            <li>
                <button type="button" class="readall-button">
                    <span class="icon"></span><span data-app-text="readAllData"></span>
                </button>
            </li>
            <li>
                <button type="button" class="getbaudrate-button">
                    <span class="icon"></span><span data-app-text="getBaudrate"></span>
                </button>
                <input type="text" id="baudrate" value="" />
                <button type="button" class="setbaudrate-button">
                    <span class="icon"></span><span data-app-text="setBaudrate"></span>
                </button>
            </li>
            <li>
                <button type="button" class="getbytesize-button">
                    <span class="icon"></span><span data-app-text="getByteSize"></span>
                </button>
                <input type="text" id="byteSize" value="" />
                <button type="button" class="setbytesize-button">
                    <span class="icon"></span><span data-app-text="setByteSize"></span>
                </button>
            </li>
            <li>
                <button type="button" class="getparity-button">
                    <span class="icon"></span><span data-app-text="getParity"></span>
                </button>
                <input type="text" id="parity" value="" />
                <button type="button" class="setparity-button">
                    <span class="icon"></span><span data-app-text="setParity"></span>
                </button>
            </li>
            <li>
                <button type="button" class="getstopbit-button">
                    <span class="icon"></span><span data-app-text="getStopBit"></span>
                </button>
                <input type="text" id="stopBits" value="" />
                <button type="button" class="setstopbit-button">
                    <span class="icon"></span><span data-app-text="setStopBit"></span>
                </button>
            </li>
            <li>
                <button type="button" class="gettimeout-button">
                    <span class="icon"></span><span data-app-text="getTimeout"></span>
                </button>
                <input type="text" id="timeout" value="" />
                <button type="button" class="settimeout-button">
                    <span class="icon"></span><span data-app-text="setTimeout"></span>
                </button>
            </li>
            <li>
                <button type="button" class="startloop-button">
                    <span class="icon"></span><span data-app-text="startLoop"></span>
                </button>
                <button type="button" class="stoploop-button">
                    <span class="icon"></span><span data-app-text="stopLoop"></span>
                </button>
                <input type="text" id="loopData" value="" />
            </li>
        </ul>
    </div>
    <!-- 画面デザイン -- End -->
</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="FooterContent" runat="server">
    <!-- 画面デザイン -- Start -->

    <!-- 画面アーキテクチャ共通のデザイン -- Start -->
    <div class="command" style="left: 1px;">
        <!-- TODO: 画面の仕様に応じて以下のボタンを変更してください。 -->
        <!-- TODO: ここまで -->
    </div>
    <div class="command" style="right: 9px;">
        <!-- TODO: 画面の仕様に応じて以下のボタンを変更してください。 -->
        <!-- TODO: ここまで -->
    </div>
    <!-- 画面アーキテクチャ共通のデザイン -- End -->

    <!-- 画面デザイン -- End -->
</asp:Content>
<asp:Content ID="Content5" ContentPlaceHolderID="DialogsContent" runat="server">
    <!-- 画面デザイン -- Start -->
    <!-- 画面デザイン -- End -->
</asp:Content>
