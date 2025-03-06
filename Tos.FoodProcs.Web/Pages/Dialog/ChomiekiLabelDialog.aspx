<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ChomiekiLabelDialog.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.Dialog.ChomiekiLabelDialog" %>

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
        .dialog-content .dialog-criteria-chomiprint
        {
            border-bottom: solid 1px #efefef;
            border-left: solid 1px #efefef;
            border-top: solid 1px #efefef;
            padding-top: 1em;
            padding-left: 1.5em;
            height: 65px;
        }
        .dialog-content .dialog-criteria-chomiprint .part-footer
        {
            margin-top: 1em;
            margin-right: .5em;
            position: relative;
            height: 40px;
            border-top: solid 1px #dbdbdb;
        }
        .dialog-content .dialog-criteria-chomiprint .part-footer .command
        {
            position: absolute;
            display: inline-block;
            right: 0;
        }
        .dialog-content .dialog-result-list
        {
            margin-top: 10px;
        }
        .dialog-content .dialog-criteria-chomiprint .part-footer .command button
        {
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
    <script type="text/javascript">
        // TODO：画面の仕様に応じて以下のダイアログ名を変更してください。
        $.dlg.register("ChomiekiLabelDialog", {
            // TODO：ここまで
            initialize: function (context) {
                //// 変数宣言 -- Start
                var version;
                var elem = context.element,
                    isFirstLoad = true, // 初回起動時
                    pageLangText = App.ui.pagedata.lang(App.ui.page.lang);

                // 起動元画面の行データ
                var rowdata = context.data.param1,
                    chomidata = context.data.param2,
                    nameKey = context.data.param3;

                // ラベル内容の確認項目を出力
                var setText = function () {
                    var text = rowdata.cd_shikakari_hin + "  " + rowdata[nameKey];
                    $("#chomiekiLabelInfo").text(text);
                };

                // 0を埋める
                var padZero = function (str, max) {
                    str = str.toString();
                    return str.length < max ? padZero("0" + str, max) : str;
                }

                // 時刻取得
                var getTimeToMilli = function (d) {
                    // ミリ秒を含めた時刻表示
                    var tMilli = padZero(d.getFullYear(), 4) + padZero((d.getMonth() + 1), 2) + padZero(d.getDate(), 2) +
			            padZero(d.getHours(), 2) + padZero(d.getMinutes(), 2) + padZero(d.getSeconds(), 2) +
			            padZero(d.getMilliseconds(), 3);
                    return tMilli;
                }

                // <summary>日付フォーマット変換</summary>
                var getDate = function (date) {
                    if (App.ui.page.lang == 'ja' || App.ui.page.lang == 'zh') {
                        date = [date.getFullYear(), (date.getMonth() + 1), (date.getDate())].join('/');
                    } else if (App.ui.page.langCountry == 'en-US') {
                        date = [(date.getMonth() + 1), (date.getDate()), date.getFullYear()].join('/');
                    } else {
                        date = [(date.getDate()), (date.getMonth() + 1), date.getFullYear()].join('/');
                    }
                    return date;
                }

                // byte数チェック
                var countLength = function (str) {
                    var r = 0;
                    for (var i = 0; i < str.length; i++) {
                        var c = str.charCodeAt(i);
                        if ((c >= 0x0 && c < 0x81) || (c == 0xf8f0) || (c >= 0xff61 && c < 0xffa0) || (c >= 0xf8f1 && c < 0xf8f4)) {
                            r += 1;
                        } else {
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
                            } else {
                                strName = strName + "," + name[a];
                            }
                        } else {
                            return strName;
                        }
                    }
                    return strName;
                }

                // テキスト表示
                setText();

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

                /// <summary>ラベル出力を行います。</summary>
                var printChomiekiLabel = function (e) {
                    // 確定・未確定チェックの値を検証
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

                    // 自家原印刷
                    wk = printChomiQR(); //データを元にラベルのHTMLを作成

                    doc.write(wk);  //HTMLを書き込み
                    // Chromeの場合、QRコードが表示されないことがあるため、
                    // QRコードの読み込み完了まで印刷ダイアログ表示を待機する
                    var delay = 1000; // ハンドラの実行トライ間隔(ms)
                    App.sync.loadQRHandler(function () {
                        toPrintOutChomi(doc, iframe);
                    }, delay, doc);

                    // ダイアログを閉じる
                    context.close("canceled");
                };

                // ラベル出力ウィンドウを呼び出す
                var toPrintOutChomi = function (doc, iframe) {
                    doc.close();
                    // セキュリティ更新プログラムによってiframeの印刷ができなくなったので対応（2017/06/16 kaneko.m）
                    if (iframe.contentWindow.document.queryCommandSupported('print')) {
                        iframe.contentWindow.document.execCommand('print', false, null);
                    } else {
                        iframe.contentWindow.focus();
                        iframe.contentWindow.print();
                    }
                    document.body.removeChild(iframe);

                }

                // ラベル出力用の処理数をセット
                var setLabelSu = function (dt, seikiCnt, hasuCnt, sum, batchEnd, batchNow, kosuNow, kosuEnd) {
                    // バッチの回数をセット
                    dt["set_su_batch_end"] = batchEnd;
                    dt["set_su_batch_now"] = batchNow;

                    // ラベルの回数をセット
                    var now,
                        end;
                    if (sum <= seikiCnt) {
                        // 正規
                        end = seikiCnt;
                        now = kosuNow;
                    } else {
                        // 端数
                        end = hasuCnt;
                        now = kosuNow;
                    }

                    dt["set_su_label_now"] = now;
                    dt["set_su_label_end"] = kosuEnd;
                    return dt;
                }

                // ラベルの作成
                var printChomiQR = function () {

                    // ラベル内容
                    var dt,
                        wk,
                        seiki = 1,
                        hasu = 2,
                        result = "";
                    // 変数宣言
                    var kaishiVal = 1, // 開始は１
                        shuryoVal, //終了値
                        islastprint = false; // 印刷ページ最終行判断

                    var su_batch_keikaku = parseInt(rowdata.su_batch_keikaku, 10);
                    var su_batch_keikaku_hasu = parseInt(rowdata.su_batch_keikaku_hasu, 10);
                    var ritsu_keikaku = parseFloat(rowdata.ritsu_keikaku);
                    var ritsu_keikaku_hasu = parseFloat(rowdata.ritsu_keikaku_hasu);

                    //var labelCnt = parseInt(rowdata.su_batch_keikaku, 10),
                    //    labelHasuCnt = parseInt(rowdata.su_batch_keikaku_hasu, 10),
                    //    labelSum = labelCnt + labelHasuCnt;

                    var labelCnt = 0;
                    var labelHasuCnt = 0;

                    if (su_batch_keikaku > 0 && ritsu_keikaku > 0) {
                        labelCnt = su_batch_keikaku;
                    }

                    if (su_batch_keikaku_hasu > 0 && ritsu_keikaku_hasu > 0) {
                        labelHasuCnt = su_batch_keikaku_hasu;
                    }

                    var labelSum = labelCnt + labelHasuCnt;

                    // 全ラベルを印刷するので、正規/端数のループを回す
                    for (var all = seiki; all <= hasu; all++) {
                        // バッチループ開始
                        // 対象エリア選択
                        if (all == seiki) {
                            shuryoVal = labelCnt;
                            // 端数がある場合はfalse
                            islastprint = (labelHasuCnt > 0) ? false : true;
                        } else {
                            shuryoVal = labelHasuCnt;
                            islastprint = true;
                        }
                        // 調味液データを取得
                        var chomiInfo = chomidata.d[0];

                        //正規回数、端数1回ループ
                        for (var i = kaishiVal; i <= shuryoVal; i++) {
                            // 発行枚数
                            var loop = shuryoVal;
                            var kosu = chomidata.d[0].su_kowake;
                            //個数分ループ
                            for (var j = 1; j <= kosu; j++) {
                                rowdata = setLabelSu(rowdata, labelCnt, labelHasuCnt, labelSum, shuryoVal, i, j, kosu);
                                var isLast = (i == shuryoVal && j == kosu && islastprint == true) ? true : false; // 最終頁判断
                                wk = createChomiPrintArea(i, j, chomiInfo, shuryoVal, isLast);
                                result = result + wk;
                            }
                            /*
                            rowdata = setLabelSu(rowdata, labelCnt, labelHasuCnt, labelSum, shuryoVal, i, j);
                            // ラベル作成
                            var isLast = (i == shuryoVal && j == loop && islastprint == true) ? true : false; // 最終頁判断
                            wk = createChomiPrintArea(i, j, chomiInfo, shuryoVal, isLast);
                            result = result + wk;
                            */
                            /*
                            // 枚数分のラベルを発行
                            for (var j = 1; j <= loop; j++) {
                            // 現在どの行を実施しているかをセット
                            rowdata = setLabelSu(rowdata, labelCnt, labelHasuCnt, labelSum, shuryoVal, i, j);
                            // ラベル作成
                            var isLast = (i == shuryoVal && j == loop && islastprint == true) ? true : false; // 最終頁判断
                            wk = createChomiPrintArea(i, j, chomiInfo, shuryoVal, isLast);
                            result = result + wk;
                            } // 行に指定され枚数データ分
                            */
                        } // バッチ数ループ終了
                    } // 正規端数ループ終了
                    return result;
                };

                /// <summary>ラベルフォーマット区分の取得</summary>
                var setLabelVersion = function () {
                    App.deferred.parallel({
                        labelVersion: App.ajax.webgetSync("../Services/FoodProcsService.svc/cn_kino_sentaku()?$filter=kbn_kino eq " + pageLangText.kinoLabelKbn.number)
                    }).done(function (result) {
                        labelVersion = result.successes.labelVersion.d;
                        if (labelVersion.length > 0) {
                            version = labelVersion[0].kbn_kino_naiyo;
                        } else {
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

                /// <summary>値の右に文字を指定した数分加え、左から指定した数分切り取って返します</summary>
                /// <param name="val">元になる値</param>
                /// <param name="len">戻り値を切り取る左からの文字数</param>
                /// <param name="char">加える文字</param>
                var paddingRight = function (val, len, char) {
                    var res, pads = "";
                    var i = 0;
                    char = char.toString();
                    val = val.toString();
                    for (; i < len; i++) {
                        pads += char;
                    }
                    res = (val + pads).substr(0, len);
                    return res;
                };

                /// <summary>任意の小分重量を成型します。重量のgは右を0埋めします。</summary>
                /// <param name="val">元になる値</param>
                /// <param name="len">戻り値を切り取る左からの文字数</param>
                /// <param name="char">加える文字</param>
                /// <return>成型された小分重量の文字列</param>
                var padKowakeJuryoKg = function (val, len, char) {
                    var kowakeJuryoAry,
                        kowakeJuryoView = "";

                    if (App.isUndef(val)) {
                        // 値がない場合は空文字を返します。
                        return kowakeJuryoView;
                    }
                    else {
                        // 値がある場合は、小数点第四位を四捨五入します。
                        var juryoFloat = parseFloat(val),
                            tf = App.data.trimFixed;
                        juryoFloat = tf(juryoFloat * 1000);
                        juryoFloat = tf(Math.round(juryoFloat));
                        juryoFloat = tf(juryoFloat / 1000);
                        kowakeJuryoView = juryoFloat.toString();
                    }

                    kowakeJuryoAry = kowakeJuryoView.split(".");
                    switch (kowakeJuryoAry.length) {
                        case 1:
                            // 小数部無しは0で小数点以下を0埋めで統一
                            kowakeJuryoAry[1] = paddingRight("", len, char);
                            kowakeJuryoView = kowakeJuryoAry.join(".");
                            break;
                        case 2:
                            // 小数部あり
                            kowakeJuryoAry[1] = paddingRight(kowakeJuryoAry[1], len, char);
                            kowakeJuryoView = kowakeJuryoAry.join(".");
                            break;
                        default:
                            break;
                    }

                    return kowakeJuryoView;
                };

                // ラベル作成処理
                /// <param name="i"バッチループ数</param>
                /// <param name="j">ラベル発行枚数</param>
                /// <param name="chomiInfo"></param>
                /// <param name="shuryoVal"></param>
                /// <param name="isLast">最終データ判定フラグ</param>
                var createChomiPrintArea = function (i, j, dt, shuryoVal, isLast) {
                    var padLen = 3,
                        padChar = "0";

                    if (version == pageLangText.kaigaiLabelFormatKbn.number) {
                        //Version2（海外対応）
                        // 処理開始
                        var wk = "";
                        if (isLast) {
                            //wk += "<div style='page-break-after:auto; width:346px;'>";
                            wk += "<table style='page-break-after:auto; font-size:11pt; font-family:ＭＳ ゴシック;' height='350px'; width='350';>";
                        } else {
                            //wk += "<div style='page-break-after:always; width='346px;'>";
                            wk += "<table style='page-break-after:always; font-size:11pt; font-family:ＭＳ ゴシック;' height='350px'; width='350';>";
                        }

                        var code;
                        // 製造日取得
                        var rowdate = new Date(parseInt(rowdata.dt_seizo.substr(6)));
                        var seizodate = new Date(parseInt(rowdata.dt_seizo.substr(6)));
                        var seizoDateY = rowdate.getFullYear().toString();
                        var seizoDateM = (rowdate.getMonth() + 1).toString();
                        var seizoDateD = rowdate.getDate().toString();
                        // 製造日取得（使用期限用）
                        var rowdateShiyo = new Date(parseInt(rowdata.dt_seizo.substr(6)));

                        // QRCodeの作成
                        var data = "./QRCodeGererateHandler.ashx";
                        data += "?code=";
                        code = generateChomiCode(j, dt, seizoDateY, seizoDateM, seizoDateD, rowdate, rowdateShiyo);
                        data += code;
                        data += "&lang=";
                        data += App.ui.page.lang;

                        //var wt_kowake_data = dt.wt_kowake.toString().split('.'); //.length
                        //var wt_kowake_g;
                        //if (wt_kowake_data.length > 1) {
                        //    wt_kowake_g = dt.wt_kowake.toString().split('.')[1];
                        //} else {
                        //    wt_kowake_g = 0;
                        //}
                        // 10 Kg or LB
                        var wt_kowake_g, kowakeJuryoAry,
                            kowakeJuryoView = "";
                        if (App.ui.page.user.kbn_tani === pageLangText.kbn_tani_LB_GAL.text) {
                            if (dt.cd_mark === pageLangText.cd_mark.text) {
                                wt_kowake_g = pageLangText.lbl_mark_g.text;
                            }
                            else {
                                wt_kowake_g = pageLangText.lbl_mark_LB.text;
                            }
                        }
                        else {
                            if (App.ui.page.user.kbn_tani == "" || App.ui.page.user.kbn_tani === pageLangText.kbn_tani_Kg_L.text) {
                                if (dt.cd_mark === pageLangText.cd_mark.text) {
                                    wt_kowake_g = pageLangText.lbl_mark_g.text;
                                }
                                else {
                                    wt_kowake_g = pageLangText.lbl_mark_Kg.text;
                                }
                            }
                        }
                        //wt_kowake_g = paddingRight(wt_kowake_g, padLen, padChar);
                        // 小分重量の成型
                        kowakeJuryoView = padKowakeJuryoKg(dt.wt_kowake, padLen, padChar);

                        var dateSeizo = seizodate;
                        var dateKigen = rowdateShiyo;
                        dateSeizo = getDate(dateSeizo);
                        dateKigen = getDate(dateKigen);
                        wk += "<tr><td  colspan='4' align='center' height='10px' '>" + pageLangText.txt_titleChomi_label.text + "</td></tr>";
                        // 配合コード
                        //wk += "<tr valign='top'><td width='75px'>" + pageLangText.txt_codeHaigo_label2.text + "</td>";
                        wk += "<tr valign='top'><td width='120px' style=' padding-left: 12px;'>" + pageLangText.txt_codeHaigo_label2.text + "</td>";
                        wk += "<td>:</td>";
                        wk += "<td style='padding-left: 5px;'>";
                        wk += dt.cd_haigo;
                        wk += "</td>";
                        wk += "<td></td>";
                        wk += "</tr>";
                        // 配合名
                        //wk += "<tr valign='top'><td width='75px'>" + pageLangText.txt_haigo_label2.text + "</td>";
                        wk += "<tr valign='top'><td width='120px' style=' padding-left: 12px;'>" + pageLangText.txt_haigo_label2.text + "</td>";
                        wk += "<td>:</td>";
                        wk += "<td colspan='2' style='padding-left: 5px; word-break: break-all;'>";
                        wk += rowdata[nameKey];
                        wk += "</td>";
                        wk += "</tr>";
                        // 重量
                        //wk += "<tr valign='top'><td width='75px'>" + pageLangText.txt_juryo_label2.text + "</td>";
                        wk += "<tr valign='top'><td width='120px' style=' padding-left: 12px;'>" + pageLangText.txt_juryo_label2.text + "</td>";
                        wk += "<td>:</td>";
                        wk += "<td style='padding-left: 5px;'>";
                        //wk += wt_kowake_data[0] + "k" + wt_kowake_g + "g";
                        //wk += dt.wt_kowake + " " + wt_kowake_g;
                        wk += kowakeJuryoView + " " + wt_kowake_g;
                        wk += "</td>";
                        //wk += "<td></td>";
                        wk += "<td style='border:solid 1px; text-align: center; vertical-align: middle; word-break: break-all;'>";
                        wk += dt.nm_hokan_kbn;
                        wk += "</td>";
                        wk += "</tr>";
                        //製造日
                        wk += "<tr valign='top'><td width='120px' style=' padding-left: 12px;'>" + pageLangText.txt_seizo_label2.text + "</td>";
                        wk += "<td>:</td>";
                        wk += "<td style='padding-left: 5px;'>";
                        wk += dateSeizo;
                        wk += "</td>";
                        wk += "<td></td>";
                        wk += "</tr>";
                        //使用期限
                        wk += "<tr valign='top'><td width='120px' style=' padding-left: 12px;'>" + pageLangText.txt_kigen_label.text + "</td>";
                        wk += "<td>:</td>";
                        wk += "<td style='padding-left: 5px;'>";
                        wk += dateKigen;
                        wk += "</td>";
                        // QRコードイメージ
                        wk += "<td rowspan='3'><img src='";
                        wk += data;
                        wk += "' height='70px' width='70px' /></td>";
                        wk += "</tr>";
                        // バッチ数
                        //wk += "<tr valign='top'><td width='75px'>" + pageLangText.txt_kaisu_label2.text + "</td>";
                        wk += "<tr valign='top'><td width='120px' style=' padding-left: 12px;'>" + pageLangText.txt_kaisu_label2.text + "</td>";
                        wk += "<td>:</td>";
                        wk += "<td style='padding-left: 5px;'>";
                        wk += rowdata.set_su_batch_now + " / " + rowdata.set_su_batch_end;
                        wk += "</td></tr>";
                        // 枚数
                        //wk += "<tr valign='top'><td width='75px'>" + pageLangText.txt_maisu_label2.text + "</td>";
                        wk += "<tr valign='top'><td width='120px' style=' padding-left: 12px;'>" + pageLangText.txt_maisu_label2.text + "</td>";
                        wk += "<td>:</td>";
                        wk += "<td style='padding-left: 5px;'>";
                        wk += rowdata.set_su_label_now + " / " + rowdata.set_su_label_end;
                        wk += "</td></tr>";

                        var allergyName;
                        var allergyKbn;
                        var otherKbn;
                        var otherName;
                        if (!App.isUndefOrNull(dt.nm_Allergy) && dt.nm_Allergy.length != 0) {
                            var nameAllergy = dt.nm_Allergy.split(",");
                            allergyName = nameSplit(nameAllergy);
                            allergyKbn = dt.kbnAllergy;
                        }
                        if (!App.isUndefOrNull(dt.nm_Other) && dt.nm_Other.length != 0) {
                            var nameOther = dt.nm_Other.split(",");
                            otherName = nameSplit(nameOther);
                            otherKbn = dt.kbnOther;
                        }

                        if (!App.isUndefOrNull(dt.nm_Allergy) && dt.nm_Allergy.length != 0) {
                            // アレルゲン
                            //wk += "<tr valign='top'><td width='75px'>" + allergyKbn + "</td>";
                            wk += "<tr valign='top'><td width='120px' style=' padding-left: 12px;'>" + allergyKbn + "</td>";
                            wk += "<td>:</td>";
                            wk += "<td colspan='2' style='padding-left: 5px; word-break: break-all;'>";
                            wk += allergyName;
                            wk += "</td>";
                            wk += "</tr>";
                        }
                        if (!App.isUndefOrNull(dt.nm_Other) && dt.nm_Other.length != 0) {
                            // 食品添加物
                            //wk += "<tr valign='top'><td width='75px'>" + otherKbn + "</td>";
                            wk += "<tr valign='top'><td width='120px' style=' padding-left: 12px;'>" + otherKbn + "</td>";
                            wk += "<td>:</td>";
                            wk += "<td colspan='2' style='padding-left: 5px; word-break: break-all;'>";
                            wk += otherName;
                            wk += "</td>";
                            wk += "</tr>";
                        }
                        wk += "</table>";

                        // 処理終了
                        return wk

                    } else if (version == pageLangText.chinaLabelFormatKbn.number) {
                        //Version3（中文対応）

                        if (App.ui.page.lang == 'ja' || App.ui.page.lang == 'zh') {

                            /* ラベルへの出力データの取得 */
                            var code;
                            // 製造日取得
                            var rowdate = new Date(parseInt(rowdata.dt_seizo.substr(6)));
                            var seizodate = new Date(parseInt(rowdata.dt_seizo.substr(6)));
                            var seizoDateY = rowdate.getFullYear().toString();
                            var seizoDateM = (rowdate.getMonth() + 1).toString();
                            var seizoDateD = rowdate.getDate().toString();
                            // 製造日取得（使用期限用）
                            var rowdateShiyo = new Date(parseInt(rowdata.dt_seizo.substr(6)));

                            // QRCodeの作成
                            var data = "./QRCodeGererateHandler.ashx";
                            data += "?code=";
                            code = generateChomiCode(j, dt, seizoDateY, seizoDateM, seizoDateD, rowdate, rowdateShiyo);
                            data += code;
                            data += "&lang=";
                            data += App.ui.page.lang;
                            var kowakeJuryoAry;
                            var kowakeJuryoView = "";
                            // 小分重量の生成
                            kowakeJuryoView = padKowakeJuryoKg(dt.wt_kowake, padLen, padChar);
                            var dateSeizo = seizodate;
                            var dateKigen = rowdateShiyo;
                            dateSeizo = getDate(dateSeizo);
                            dateKigen = getDate(dateKigen);
                            // QRコードの上の（）の中の重量
                            var wt_chomi = dt.wt_kowake * rowdata.set_su_label_end;

                            // アレルゲン・食品添加物の取得
                            var allergyName = "";
                            var allergyKbn = "";
                            var otherKbn = "";
                            var otherName = "";
                            if (!App.isUndefOrNull(dt.nm_Allergy) && dt.nm_Allergy.length != 0) {
                                var nameAllergy = dt.nm_Allergy.split(",");
                                allergyName = nameSplit(nameAllergy);
                                allergyKbn = dt.kbnAllergy;
                            }
                            if (!App.isUndefOrNull(dt.nm_Other) && dt.nm_Other.length != 0) {
                                var nameOther = dt.nm_Other.split(",");
                                otherName = nameSplit(nameOther);
                                otherKbn = dt.kbnOther;
                            }

                            /* ラベルの生成開始 */
                            var col1Width = "60px";
                            var largeFontSize = "15pt";
                            var wk = "";
                            if (isLast) {
                                wk += "<table style='page-break-after:auto; font-size:11pt; font-family:simHei; line-height: 0.9; ' height='245px'; width='375px';>";
                            } else {
                                wk += "<table style='page-break-after:always; font-size:11pt; font-family:simHei; line-height: 0.9;' height='245px'; width='375px';>";
                            }
                            // 0行目
                            wk += "<tr>";
                            // ラベル名
                            wk += "<td width='80px';height='0px'></td>";
                            wk += "<td width='6px';height='0px'></td>";
                            wk += "<td width='250px';height='0px'></td>";
                            wk += "<td width='75px';height='0px'></td>";
                            wk += "<td width='5px';height='0px'></td>";
                            wk += "</tr>";

                            // 1行目
                            wk += "<tr>";
                            // ラベル名
                            wk += "<td colspan='5' align='center' height='10px' style='line-height:normal; padding-top: 10px;'>";
                            wk += pageLangText.txt_titleChomi_label.text;
                            wk += "</td>";
                            wk += "</tr>";

                            // 2行目
                            wk += "<tr valign='top'>";
                            // ライン名
                            wk += "<td colspan='5' align='left' style='letter-spacing:-0.5;line-height:normal;'>";
                            wk += rowdata["nm_line"];
                            wk += "</td>";
                            wk += "</tr>";

                            // 3行目
                            wk += "<tr valign='top'>";
                            // 配合名
                            wk += "<td >";//width='" + col1Width + "'>";
                            wk += pageLangText.txt_haigo_label2.text;
                            wk += "</td>";
                            wk += "<td >:</td>"; 
                            wk += "<td colspan='3' align='left' style='font-size:" + largeFontSize + "; letter-spacing: -0.1px; word-break: break-word;line-height:normal;  padding-right:20px;font-weight: bold;'>";
                            wk += rowdata[nameKey];
                            wk += "</td>";
                            wk += "</tr>";

                            // 4行目
                            wk += "<tr valign='top'>";
                            // 配合コード
                            wk += "<td >";//width='" + col1Width + "'>";
                            wk += pageLangText.txt_codeHaigo_label2.text;
                            wk += "</td>";
                            wk += "<td>:</td>";
                            wk += "<td align='left' word-break: break-all;' width='140px'>";
                            wk += dt.cd_haigo;
                            wk += "</td>";
                            wk += "<td style=' padding-right: 15px;'>"
                            //wk += "(" + dt.wt_kowake + rowdata.nm_tani + ")";
                            wk += "(" + wt_chomi + rowdata.nm_tani + ")";
                            wk += "</td>"
                            wk += "<td></td>";
                            wk += "</tr>";

                            // 5行目
                            wk += "<tr valign='top'>";
                            //重量
                            wk += "<td width='" + col1Width + "' style='vertical-align: middle;'>";
                            wk += pageLangText.txt_juryo_label2.text;
                            wk += "</td>";
                            wk += "<td style='vertical-align: middle;'>:</td>";
                            wk += "<td style='vertical-align: middle; font-weight: bold; font-size:" + largeFontSize + "'>";
                            wk += kowakeJuryoView + " " + rowdata.nm_tani;
                            wk += "</td>";
                            //                      wk += "<td width='75px' style='border:solid 1px; text-align: center; vertical-align: middle; word-break: break-all; padding-right: 5px;'>";
                            wk += "<td  style='padding-right: 15px; padding-top: 3px'>";//width='70px'
                            wk += "<div style='word-break: break-all; border:solid 1px; text-align: center; vertical-align: middle;  width: 68px;'>"
                            wk += dt.nm_hokan_kbn;
                            wk += "</div>"
                            wk += "</td>";
                            wk += "<td></td>";
                            wk += "</tr>";

                            // 6行目
                            wk += "<tr valign='top'>";
                            // バッチ数とQRコード
                            // バッチ数
                            wk += "<td >";//width='" + col1Width + "'>";
                            wk += pageLangText.txt_kaisu_label2.text;
                            wk += "</td>";
                            wk += "<td>:</td>";
                            wk += "<td>";
                            wk += rowdata.set_su_batch_now + " / " + rowdata.set_su_batch_end
                            wk += "</td>";
                            //QRコード
                            wk += "<td  rowspan='4' style=' padding-right: 25px; padding-top: 5px;'>"; 
                            wk += "<img src='";
                            wk += data;
                            wk += "' height='70px' width='70px' />";
                            wk += "</td>";
                            wk += "<td></td>";
                            wk += "</tr>";

                            // 7行目
                            wk += "<tr valign='top'>";
                            // 枚数
                            wk += "<td>";
                            wk += pageLangText.txt_kosu_label.text;
                            wk += "</td>";
                            wk += "<td>:</td>";
                            wk += "<td>";
                            wk += rowdata.set_su_label_now + " / " + rowdata.set_su_label_end;
                            wk += "</td>";
                            wk += "<td></td>";
                            wk += "</tr>";

                            // 8行目
                            wk += "<tr valign='top'>";
                            // 仕込日
                            wk += "<td >";//width='" + col1Width + "'>";
                            wk += pageLangText.txt_shikomi_label.text;
                            wk += "</td>";
                            wk += "<td>:</td>";
                            wk += "<td>";
                            wk += dateSeizo;
                            wk += "</td>";
                            wk += "<td></td>";
                            wk += "</tr>";

                            // 9行目
                            wk += "<tr valign='top'>";
                            // 賞味期限
                            wk += "<td >";//width='" + col1Width + "'>";
                            wk += pageLangText.txt_kigen_label.text;
                            wk += "</td>";
                            wk += "<td>:</td>";
                            wk += "<td width='200px'>";
                            wk += dateKigen;
                            wk += "</td>";
                            wk += "<td></td>";
                            wk += "</tr>";

                            // アレルゲン
                            if (!App.isUndefOrNull(dt.nm_Allergy) && dt.nm_Allergy.length != 0) {
                                // 10行目
                                wk += "<tr valign='top'>";
                                // アレルゲン
                                wk += "<td  >";//width='" + col1Width + "'>";
                                wk += allergyKbn;
                                wk += "</td>";
                                wk += "<td>:</td>";
                                wk += "<td word-break: break-all;' colspan='3'style=' padding-right: 25px; word-break:break-all;'>";
                                wk += allergyName;
                                wk += "</td>";
                                wk += "<td></td>";
                                wk += "</tr>";
                            }
                            // 食品添加物
                            if (!App.isUndefOrNull(dt.nm_Other) && dt.nm_Other.length != 0) {
                                // 11行目
                                wk += "<tr valign='top'>";
                                // 食品添加物
                                wk += "<td >";//width='" + col1Width + "'>";
                                wk += otherKbn;
                                wk += "</td>";
                                wk += "<td>:</td>";
                                wk += "<td  colspan='3' style='padding-right: 25px; word-break:break-all;'>";
                                wk += otherName;
                                wk += "</td>";
                                wk += "<td></td>";
                                wk += "</tr>";
                            }
                            wk += "</table>";

                        } else {

                            //Version3（中文対応）
                            /* ラベルへの出力データの取得 */
                            var code;
                            // 製造日取得
                            var rowdate = new Date(parseInt(rowdata.dt_seizo.substr(6)));
                            var seizodate = new Date(parseInt(rowdata.dt_seizo.substr(6)));
                            var seizoDateY = rowdate.getFullYear().toString();
                            var seizoDateM = (rowdate.getMonth() + 1).toString();
                            var seizoDateD = rowdate.getDate().toString();
                            // 製造日取得（使用期限用）
                            var rowdateShiyo = new Date(parseInt(rowdata.dt_seizo.substr(6)));

                            // QRCodeの作成
                            var data = "./QRCodeGererateHandler.ashx";
                            data += "?code=";
                            code = generateChomiCode(j, dt, seizoDateY, seizoDateM, seizoDateD, rowdate, rowdateShiyo);
                            data += code;
                            data += "&lang=";
                            data += App.ui.page.lang;
                            var kowakeJuryoAry;
                            var kowakeJuryoView = "";
                            // 小分重量の生成
                            kowakeJuryoView = padKowakeJuryoKg(dt.wt_kowake, padLen, padChar);
                            var dateSeizo = seizodate;
                            var dateKigen = rowdateShiyo;
                            dateSeizo = getDate(dateSeizo);
                            dateKigen = getDate(dateKigen);
                            // QRコードの上の（）の中の重量
                            var wt_chomi = dt.wt_kowake * rowdata.set_su_label_end;

                            // アレルゲン・食品添加物の取得
                            var allergyName = "";
                            var allergyKbn = "";
                            var otherKbn = "";
                            var otherName = "";
                            if (!App.isUndefOrNull(dt.nm_Allergy) && dt.nm_Allergy.length != 0) {
                                var nameAllergy = dt.nm_Allergy.split(",");
                                allergyName = nameSplit(nameAllergy);
                                allergyKbn = dt.kbnAllergy;
                            }
                            if (!App.isUndefOrNull(dt.nm_Other) && dt.nm_Other.length != 0) {
                                var nameOther = dt.nm_Other.split(",");
                                otherName = nameSplit(nameOther);
                                otherKbn = dt.kbnOther;
                            }

                            /* ラベルの生成開始 */
                            var col1Width = "60px";
                            var largeFontSize = "15pt";
                            var wk = "";
                            if (isLast) {
                                wk += "<table style='page-break-after:auto; font-size:10pt; font-family:simHei;' height='245px'; width='350px';>";
                            } else {
                                wk += "<table style='page-break-after:always; font-size:10pt; font-family:simHei;' height='245px'; width='350px';>";
                            }
                            // 0行目
                            wk += "<tr>";
                            // ラベル名
                            wk += "<td width='60px';height='0px'></td>";
                            wk += "<td width='8px';height='0px'></td>";
                            wk += "<td width='200px';height='0px'></td>";
                            wk += "<td width='75px';height='0px'></td>";
                            wk += "<td width='2px';height='0px'></td>";
                            wk += "</tr>";

                            // 1行目
                            wk += "<tr>";
                            // ラベル名
                            wk += "<td colspan='5' align='center' height='10px' style='padding-top: 10px;'>";
                            wk += pageLangText.txt_titleChomi_label.text;
                            wk += "</td>";
                            wk += "</tr>";

                            // 2行目
                            wk += "<tr valign='top'>";
                            // ライン名
                            wk += "<td colspan='5' align='left'>";
                            wk += rowdata["nm_line"];
                            wk += "</td>";
                            wk += "</tr>";

                            // 3行目
                            wk += "<tr valign='top'>";
                            // 配合名
                            wk += "<td >";//width='" + col1Width + "'>";
                            wk += pageLangText.txt_haigo_label2.text;
                            wk += "</td>";
                            wk += "<td>:</td>"; 
                            wk += "<td colspan='3' align='left' style='word-break:break-all; padding-right: 10px; font-weight: bold; font-size:" + largeFontSize + "'>"; 
                            wk += rowdata[nameKey];
                            wk += "</td>";
                            wk += "</tr>";

                            // 4行目
                            wk += "<tr valign='top'>";
                            // 配合コード
                            wk += "<td >";//width='" + col1Width + "'>";
                            wk += pageLangText.txt_codeHaigo_label2.text;
                            wk += "</td>";
                            wk += "<td>:</td>";
                            wk += "<td align='left'>";
                            wk += dt.cd_haigo;
                            wk += "</td>";
                            wk += "<td>"
                            //wk += "(" + dt.wt_kowake + rowdata.nm_tani + ")";
                            wk += "(" + wt_chomi + rowdata.nm_tani + ")";
                            wk += "</td>"
                            wk += "<td></td>";
                            wk += "</tr>";

                            // 5行目
                            wk += "<tr valign='top'>";
                            //重量
                            wk += "<td>";//width='" + col1Width + "'>";
                            wk += pageLangText.txt_juryo_label2.text;
                            wk += "</td>";
                            wk += "<td>:</td>";
                            wk += "<td style='; font-weight: bold; font-size:" + largeFontSize + "'>";
                            wk += kowakeJuryoView + " " + rowdata.nm_tani;
                            wk += "</td>";
                            //                      wk += "<td width='75px' style='border:solid 1px; text-align: center; vertical-align: middle; word-break: break-all; padding-right: 5px;'>";
                            wk += "<td style=' padding-right: 15px; padding-top: 1px'>"; 
                            wk += "<div style=' border:solid 1px; text-align: center; vertical-align: middle;  width: 68px;'>"
                            wk += dt.nm_hokan_kbn;
                            wk += "</div>"
                            wk += "</td>";
                            wk += "<td></td>";
                            wk += "</tr>";

                            // 6行目
                            wk += "<tr valign='top'>";
                            // バッチ数とQRコード
                            // バッチ数
                            wk += "<td width='" + col1Width + "'>";
                            wk += pageLangText.txt_kaisu_label2.text;
                            wk += "</td>";
                            wk += "<td>:</td>";
                            wk += "<td>";
                            wk += rowdata.set_su_batch_now + " / " + rowdata.set_su_batch_end
                            wk += "</td>";
                            //QRコード
                            wk += "<td  rowspan='4' style=' padding-right: 25px; padding-top: 2px;'>";
                            wk += "<img src='";
                            wk += data;
                            wk += "' height='70px' width='70px' />";
                            wk += "</td>";
                            wk += "<td></td>";
                            wk += "</tr>";

                            // 7行目
                            wk += "<tr valign='top'>";
                            // 枚数
                            wk += "<td>";
                            wk += pageLangText.txt_kosu_label.text;
                            wk += "</td>";
                            wk += "<td>:</td>";
                            wk += "<td>";
                            wk += rowdata.set_su_label_now + " / " + rowdata.set_su_label_end;
                            wk += "</td>";
                            wk += "<td></td>";
                            wk += "</tr>";

                            // 8行目
                            wk += "<tr valign='top'>";
                            // 仕込日
                            wk += "<td>";//width='" + col1Width + "'>";
                            wk += pageLangText.txt_shikomi_label.text;
                            wk += "</td>";
                            wk += "<td>:</td>";
                            wk += "<td>";
                            wk += dateSeizo;
                            wk += "</td>";
                            wk += "<td></td>";
                            wk += "</tr>";

                            // 9行目
                            wk += "<tr valign='top'>";
                            // 賞味期限
                            wk += "<td >";//width='" + col1Width + "'>";
                            wk += pageLangText.txt_kigen_label.text;
                            wk += "</td>";
                            wk += "<td>:</td>";
                            wk += "<td >";
                            wk += dateKigen;
                            wk += "</td>";
                            wk += "<td></td>";
                            wk += "</tr>";

                            // アレルゲン
                            if (!App.isUndefOrNull(dt.nm_Allergy) && dt.nm_Allergy.length != 0) {
                                // 10行目
                                wk += "<tr valign='top'>";
                                // アレルゲン
                                wk += "<td >";//width='" + col1Width + "'>";
                                wk += allergyKbn;
                                wk += "</td>";
                                wk += "<td>:</td>";
                                wk += "<td  colspan='3' style='padding-right: 15px;word-break: break-all;'>";
                                wk += allergyName;
                                wk += "</td>";
                                wk += "<td></td>";
                                wk += "</tr>";
                            }
                            // 食品添加物
                            if (!App.isUndefOrNull(dt.nm_Other) && dt.nm_Other.length != 0) {
                                // 11行目
                                wk += "<tr valign='top'>";
                                // 食品添加物
                                wk += "<td >";//width='" + col1Width + "'>";
                                wk += otherKbn;
                                wk += "</td>";
                                wk += "<td>:</td>";
                                wk += "<td colspan='3' style='padding-right: 15px; word-break: break-all;'>";
                                wk += otherName;
                                wk += "</td>";
                                wk += "<td></td>";
                                wk += "</tr>";
                            }

                            wk += "</table>";



                        }
                        // 処理終了
                        return wk;

                    } else {
                        // 処理開始
                        var wk = "";
                        if (isLast) {
                            wk += "<div style='page-break-after:auto; font-family: Times New Roman, SimSun; width:346px;'>";
                        } else {
                            wk += "<div style='page-break-after:always; font-family: Times New Roman, SimSun; width='346px;'>";
                        }
                        var code;
                        // 製造日取得
                        var rowdate = new Date(parseInt(rowdata.dt_seizo.substr(6)));
                        var seizodate = new Date(parseInt(rowdata.dt_seizo.substr(6)));
                        var seizoDateY = rowdate.getFullYear().toString();
                        var seizoDateM = (rowdate.getMonth() + 1).toString();
                        var seizoDateD = rowdate.getDate().toString();
                        // 製造日取得（使用期限用）
                        var rowdateShiyo = new Date(parseInt(rowdata.dt_seizo.substr(6)));

                        // QRCodeの作成
                        var data = "./QRCodeGererateHandler.ashx";
                        data += "?code=";
                        code = generateChomiCode(j, dt, seizoDateY, seizoDateM, seizoDateD, rowdate, rowdateShiyo);
                        data += code;
                        data += "&lang=";
                        data += App.ui.page.lang;

                        //var wt_kowake_data = dt.wt_kowake.toString().split('.'); //.length 
                        //var wt_kowake_g;
                        //if (wt_kowake_data.length > 1) {
                        //    wt_kowake_g = dt.wt_kowake.toString().split('.')[1];
                        //} else {
                        //    wt_kowake_g = 0;
                        //}
                        //wt_kowake_g = paddingRight(wt_kowake_g, padLen, padChar);
                        // 小分重量の成型
                        var wt_kowake_data = padKowakeJuryoKg(dt.wt_kowake, padLen, padChar);
                        if (wt_kowake_data === "") {
                            wt_kowake_data[0] = ""; wt_kowake_data[1] = "";
                        }
                        else {
                            wt_kowake_data = wt_kowake_data.split('.');
                        }

                        wk += "<div>" + rowdata.nm_line + "</div>"; // + "     " + dt.nm_hokan_kbn + "</div>";
                        wk += "<div style='font-size:25px; word-break: break-all;'>" + pageLangText.haigoName.text + "：" + rowdata[nameKey] + "</div>";
                        //wk += "<div style='float:left; word-break: break-all;'>" + pageLangText.kbn_hin_dlg.text + "：" + dt.nm_kbn_hin + "</div>";
                        //wk += "<div style='float:right; border:solid 1px; word-break: break-all;'>" + dt.nm_hokan_kbn + "</div>";

                        wk += "<div>";
                        wk += "<label style='word-break: break-all;'>" + pageLangText.kbn_hin_dlg.text + "：" + dt.nm_kbn_hin + "</label>";
                        wk += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
                        wk += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
                        wk += "<label style='border:solid 1px; word-wrap:normal; word-break: break-all; max-width:85px; width:85px;'>" + dt.nm_hokan_kbn + "</label>";
                        wk += "</div>";

                        wk += "<div style='clear:both; '></div>";
                        wk += "<div>" + pageLangText.cd_seihin_dlg.text + "：" + dt.cd_haigo + "</div>";
                        wk += "<div style='clear:both; '></div>";
                        wk += "<div  style='float:left;'>";
                        wk += "<div style='font-size:25px;'>" + pageLangText.txt_juryo_label.text + "：" + wt_kowake_data[0] + "k";
                        //wk += wt_kowake_g + "g" + "</div>";
                        wk += wt_kowake_data[1] + "g" + "</div>";
                        wk += "<div>" + pageLangText.txt_kaisu_label.text + "：" + rowdata.set_su_batch_now + "/" + rowdata.set_su_batch_end + pageLangText.txt_kai_label.text;
                        wk += "  " + pageLangText.txt_kosu_label.text + "：" + rowdata.set_su_label_now + "/" + rowdata.set_su_label_end + pageLangText.txt_kai_label.text + "</div>";
                        var dateSeizo = seizodate;
                        var dateKigen = rowdateShiyo;
                        dateSeizo = getDate(dateSeizo);
                        dateKigen = getDate(dateKigen);
                        // 製造日は、ラベル作成時に日付を調整済み
                        wk += "<div>" + pageLangText.txt_shikomi_label.text + "：" + dateSeizo + "</div>";
                        // 使用期限は、ラベル作成時に日付を調整済み
                        wk += "<div>" + pageLangText.txt_kigen_label.text + "：" + dateKigen + "</div>";
                        wk += "</div>";
                        //wk += "<div style='position:relative; float:right;'>&nbsp;<img style='' src='" + data + "' width='75' height='75'/></div>";
                        // QRコード
                        wk += "<div>";
                        wk += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
                        wk += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
                        wk += "<img style='' src='" + data + "' width='75' height='75'/>";
                        wk += "</div>";

                        wk += "<div style='float:left;clear:both; '>";

                        var allergyName;
                        var allergyKbn;
                        var otherKbn;
                        var otherName;
                        if (!App.isUndefOrNull(dt.nm_Allergy) && dt.nm_Allergy.length != 0) {
                            var nameAllergy = dt.nm_Allergy.split(",");
                            allergyName = nameSplit(nameAllergy);
                            allergyKbn = dt.kbnAllergy;
                            // ■アレルゲン
                            wk += "<div style='width:250px; word-break: break-all;'>" + allergyKbn + "：" + allergyName + "</div>";
                        } else {
                            allergyKbn = "";
                            allergyName = "";
                        }
                        if (!App.isUndefOrNull(dt.nm_Other) && dt.nm_Other.length != 0) {
                            var nameOther = dt.nm_Other.split(",");
                            otherName = nameSplit(nameOther);
                            otherKbn = dt.kbnOther;
                            // ■食品添加物
                            wk += "<div style='width:250px; word-break: break-all;'>" + otherKbn + "：" + otherName + "</div>";
                        } else {
                            otherKbn = "";
                            otherName = "";
                        }
                        wk += "</div>";
                        wk += "</div>";

                        // 処理終了
                        return wk
                    }
                }

                // ラベル内のコードを生成する
                /// <param name="dt">起動元で取得した調味液データ</param>
                var generateChomiCode = function (cnt, dt, yyyy, mm, dd, shomidate, shiyodate) {
                    Sleep(11); // シリアル番号が一意にならないケースがあるので、敢えて待たせる(素数)
                    var padLen = 3,
                        padChar = "0";

                    var text = "";
                    // 必須項目
                    text += pageLangText.preLetters.text; // 開始コード
                    text += pageLangText.symbol_RS.text; // RS
                    text += pageLangText.ai_fixed_text.text;
                    text += pageLangText.symbol_GS.text; // GS

                    // 品名コード
                    text += pageLangText.ai_cd_hinmei.text; // AI
                    text += dt.cd_haigo;
                    text += pageLangText.symbol_GS.text;
                    // 賞味期限
                    text += pageLangText.ai_dt_kigen.text; // AI
                    var shomiDate = new Date(shomidate.setDate(shomidate.getDate() + dt.dd_shomi - 1));
                    var shomiDateY = shomiDate.getFullYear().toString();
                    //var shomiDateM = (shomiDate.getMonth() + 1).toString();
                    var shomiDateM = padZero((shomiDate.getMonth() + 1).toString(), 2);
                    //var shomiDateD = shomiDate.getDate().toString();
                    var shomiDateD = padZero(shomiDate.getDate().toString(), 2);
                    text += shomiDateY.substring(2, 4) + shomiDateM + shomiDateD;
                    text += pageLangText.symbol_GS.text;
                    // 製造日
                    text += pageLangText.ai_dt_seizo.text; // AI
                    //text += yyyy.substring(2, 4) + mm + dd;
                    text += yyyy.substring(2, 4) + padZero(mm, 2) + padZero(dd, 2);
                    text += pageLangText.symbol_GS.text;
                    // ロットNo. 仕込日(6)+枚数(4)+個数(4)+出力時分秒(6)
                    text += pageLangText.ai_no_lot.text; // AI
                    var time = new Date();
                    text += (yyyy.substring(2, 4) + padZero(mm, 2) + padZero(dd, 2)) + padZero(cnt, 4) + padZero(dt.su_kowake, 4);
                    //+ (padZero(time.getHours(), 2)
                    //+ padZero(time.getMinutes(), 2)
                    //+ padZero(time.getSeconds(), 2));
                    text += pageLangText.symbol_GS.text;
                    // シリアルNo.（ラベル発行日時）
                    text += pageLangText.ai_serial_number.text; // AI
                    text += getTimeToMilli(time);
                    text += pageLangText.symbol_GS.text;
                    // 品コード
                    text += pageLangText.ai_cd_hin.text; // AI
                    text += dt.cd_haigo;
                    text += pageLangText.symbol_GS.text;
                    text += pageLangText.symbol_RS.text;

                    // フリーテキストエリアの印
                    text += pageLangText.ai_free_text.text;

                    // A始まりのＡＩ
                    // 品名 
                    text += pageLangText.ai_nm_hinmei.text; // AI
                    //text += encodeURIComponent(dt["nm_haigo_" + App.ui.page.lang]);  // 品名
                    text += ","; // 区切りカンマ
                    // メーカー工場名
                    text += pageLangText.ai_nm_maker_kojo.text; // AI
                    //text += encodeURIComponent($("#user-info-branch").text());
                    text += ","; // 区切りカンマ
                    // 使用期限日
                    text += pageLangText.ai_dt_kigen_shiyo.text; // AI
                    var shiyoDate = new Date(shiyodate.setDate(shiyodate.getDate() + dt.dd_shomi - 1));
                    var shiyoDateY = shiyoDate.getFullYear().toString();
                    //var shiyoDateM = (shiyoDate.getMonth() + 1).toString();
                    var shiyoDateM = padZero((shiyoDate.getMonth() + 1).toString(), 2);
                    //var shiyoDateD = shiyoDate.getDate().toString();
                    var shiyoDateD = padZero(shiyoDate.getDate().toString(), 2);
                    text += shiyoDateY.substring(2, 4) + shiyoDateM + shiyoDateD;
                    text += ","; // 区切りカンマ
                    // 重量Ｋ
                    var wt = dt.wt_kowake.toString().split('.');
                    text += pageLangText.ai_wt_jyuryo_k.text; // AI
                    text += wt[0];
                    text += ","; // 区切りカンマ
                    // 重量ｇ
                    var wt_kowake_g;
                    if (wt.length > 1) {
                        wt_kowake_g = wt[1];
                    } else {
                        wt_kowake_g = 0;
                    }
                    wt_kowake_g = paddingRight(wt_kowake_g, padLen, padChar);

                    text += pageLangText.ai_wt_jyuryo_g.text; // AI
                    text += wt_kowake_g;
                    text += ","; // 区切りカンマ

                    // ラベル区分
                    text += pageLangText.ai_label_kbn.text; // AI
                    text += pageLangText.jikagenLabelKbn.text;   // ラベル区分.自家原

                    text += pageLangText.symbol_RS.text; // RS
                    text += pageLangText.symbol_EOT.text; // EOT
                    return text;
                }

                // <summary>スリープ処理</summary>
                // 引数：時間（ミリ秒）
                function Sleep(ms) {
                    var d1 = new Date().getTime();
                    var d2 = new Date().getTime();
                    while (d2 < (d1 + ms)) {
                        d2 = new Date().getTime();
                    }
                    return;
                }

                // <summary>ダイアログの閉じるボタンクリック時のイベント処理を行います。</summary>
                elem.find(".dlg-close-button").on("click", function () {
                    context.close("canceled");
                });

                // <summary>ダイアログの印刷ボタンクリック時のイベント処理を行います。</summary>
                elem.find(".dlg-insatsu-button").on("click", function () {
                    setLabelVersion();
                    printChomiekiLabel();
                });

                /// <summary>ダイアログを開きます。</summary>
                this.reopen = function (option) {
                    dialogNotifyInfo.clear();
                    dialogNotifyAlert.clear();
                    // 条件をセット
                    rowdata = option.param1;
                    chomidata = option.param2;
                    nameKey = option.param3;
                    setText();
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
            <h4 data-app-text="confirmTitle">
            </h4>
        </div>
        <div class="dialog-body" style="width: 95%;">
            <div class="dialog-criteria-chomiprint">
				<div class="part-body">
                    <label>
                        <span data-app-text="chomiekiLabelPrintConfirm"></span>
                    </label>
                    <br/><br/>
                    <span id="chomiekiLabelInfo"></span>
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
