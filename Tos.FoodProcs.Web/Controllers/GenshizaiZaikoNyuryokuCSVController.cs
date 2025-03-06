using System;
using System.Data;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Text;
using System.Web;
using System.Web.Http;
using Tos.FoodProcs.Web.Data;
using Tos.FoodProcs.Web.Logging;
using Tos.FoodProcs.Web.Properties;

namespace Tos.FoodProcs.Web.Controllers
{
    [Authorize]
    public class GenshizaiZaikoNyuryokuCSVController : ApiController
    {

        #region const

        /// <summary>区切り文字：タブ</summary>
        private char Delimiter = '\t'; // '\t' or ','
        /// <summary>最大ファイルサイズ：1MB</summary>
        private double MaxFileSize = 1;
        /// <summary>項目数：15</summary>
        private int CsvItemCount = 15 + 1;              // 最後の項目と改行の間にもタブが入るので1加算
        /// <summary>ヘッダ最終行番号：21(ja)・17(en)</summary>
        private int headerRowNo;
        /// <summary>csvインデックス：品名コード：1</summary>
        private int hinmeiCodeIndex = 1;
        /// <summary>csvインデックス：品名コード：2</summary>
        private int hinmeiNameIndex = 2;
        /// <summary>csvインデックス：実在庫数(納入単位)：7</summary>
        private int zaikosuNonyuIndex = 7;
        /// <summary>csvインデックス：実在庫端数(納入単位)：8</summary>
        private int zaikohasuNonyuIndex = 8;
        /// <summary>csvインデックス：実在庫数(使用単位)：9</summary>
        private int zaikosuShiyoIndex = 9;
        /// <summary>csvインデックス：実在庫数確定日：11</summary>
        private int zaikoDateIndex = 11;
        /// <summary>csvインデックス：棚卸個単価：13</summary>
        private int tanaTankaIndex = 13;


        // 画面からの値を格納する変数宣言
        /// <summary>原資材在庫入力画面．検索条件/在庫日付</summary>
        private DateTime hizuke;
        /// <summary>原資材在庫入力画面．検索条件/在庫区分</summary>
        private short zaikoKubun;
        /// <summary>原資材在庫入力画面．倉庫</summary>
        private string sokoCode;
        /// <summary>当日日付時刻</summary>
        private DateTime nowDateTime;
        /// <summary>当日日付</summary>
        private string nowDate;
        /// <summary>offset</summary>
        private int offset;

        // CSV項目名
        /// <summary>CSV項項目名：コード</summary>
        private string HIN_CODE;
        /// <summary>CSV項項目名：実在庫数(納入単位)</summary>
        private string ZAIKOSU_NONYU;
        /// <summary>CSV項目名：実在庫端数(納入単位)</summary>
        private string ZAIKOHASU_NONYU;
        /// <summary>CSV項目名：実在庫数(使用単位)</summary>
        private string ZAIKOSU_SHIYO;
        /// <summary>CSV項目名：実在庫数確定日</summary>
        private string ZAIKO_KAKUTEI_DATE;
        /// <summary>CSV項目名：単価</summary>
        private string TANA_TANKA;

        #endregion

        // GET api/GenshizaiZaikoNyuryokuCSV
        /// <summary>
        /// ファイル ダウンロードサービスを提供します。
        /// </summary>
        public HttpResponseMessage Get()
        {
            StringBuilder builder = new StringBuilder();

            // テキストファイルをアタッチしたレスポンスを生成して返します。
            return FileDownloadUtility.CreateTextFileResponse(builder.ToString(), "yourFileName");
        }

        // POST api/GenshizaiZaikoNyuryokuCSV
        /// <summary>
        /// ファイル アップロードサービスを提供します。
        /// </summary>
        public HttpResponseMessage Post()
        {
            FoodProcsEntities context = new FoodProcsEntities();

            // リクエストの取得
            var httpRequest = HttpContext.Current.Request;
            if (httpRequest.Files.Count == 0)
            {
                // リクエストにファイルが一つも存在しない場合は、
                // 失敗のレスポンスを生成して返します。
                return FileUploadUtility.CreateFailResponse(HttpStatusCode.BadRequest, Resources.NoFileAttachmentMessage);
            }

            // 画面値の取得
            SetPageValue(httpRequest);

            // トランザクションを開始し、エンティティの変更をデータベースに反映します。
            // 更新処理に失敗した場合、例外が発生し、トランザクションは暗黙的にロールバックされます。
            // 個別でチェック処理を行いロールバックを行う場合には明示的に
            // IDbTransaction インタフェースの Rollback メソッドを呼び出します。
            using (IDbConnection connection = context.Connection)
            {
                context.Connection.Open();
                using (IDbTransaction transaction = context.Connection.BeginTransaction())
                {
                    try
                    {
                        HttpFileCollection Files = httpRequest.Files;
                        int saveCount = 0;
                        string errorMessage;
                        foreach (string file in Files)
                        {
                            HttpPostedFile postedFile = Files[file];
                            string fileName = postedFile.FileName;
                            if (string.IsNullOrEmpty(fileName))
                            {
                                continue;
                            }

                            // ファイルチェックを行います。
                            errorMessage = checkFile(postedFile);
                            if (!string.IsNullOrEmpty(errorMessage))
                            {
                                // 失敗のレスポンスを生成して返します。
                                return FileUploadUtility.CreateFailResponse(HttpStatusCode.BadRequest, errorMessage);
                            }

                            // CSVデータをDBに投入
                            errorMessage = BuildCsvData(context, postedFile);
                            if (!string.IsNullOrEmpty(errorMessage))
                            {
                                // 失敗のレスポンスを生成して返します。
                                return FileUploadUtility.CreateFailResponse(HttpStatusCode.BadRequest, errorMessage);
                            }

                            saveCount++;
                        }

                        if (saveCount == 0)
                        {
                            // 失敗のレスポンスを生成して返します。
                            return FileUploadUtility.CreateFailResponse(HttpStatusCode.BadRequest, Resources.NoFileAttachmentMessage);
                        }

                        // コミット
                        context.SaveChanges();
                        transaction.Commit();

                        // 成功のレスポンスを生成して返します。
                        return FileUploadUtility.CreateSuccessResponse(Resources.FileSaveSuccessMessage);
                    }
                    catch (OptimisticConcurrencyException oex)
                    {
                        // ロールバック
                        transaction.Rollback();

                        // 楽観排他制御 (データベース上の timestamp 列による他ユーザーの更新確認) で発生したエラーをハンドルします。
                        // ここではエラーログを出力し、クライアントに対してエラー内容を書き込んだ HttpResponse を作成します。
                        Logger.App.Error(Properties.Resources.OptimisticConcurrencyError, oex);

                        // 失敗のレスポンスを生成して返します。
                        return FileUploadUtility.CreateFailResponse(
                            HttpStatusCode.InternalServerError, Resources.FileSaveErrorMessage, oex.ToString());
                    }
                    catch (Exception ex)
                    {
                        // ロールバック
                        transaction.Rollback();

                        // 楽観排他制御 (データベース上の timestamp 列による他ユーザーの更新確認) で発生したエラーをハンドルします。
                        // ここではエラーログを出力し、クライアントに対してエラー内容を書き込んだ HttpResponse を作成します。
                        Logger.App.Error(Properties.Resources.OptimisticConcurrencyError, ex);

                        // 失敗のレスポンスを生成して返します。
                        return FileUploadUtility.CreateFailResponse(
                            HttpStatusCode.InternalServerError, Resources.FileSaveErrorMessage, ex.ToString());
                    }
                }
            }
        }

        /// <summary>
        /// CSVデータをDBに投入します。
        /// </summary>
        /// <param name="context">エンティティ</param>
        /// <param name="csvFileData">CSVファイルデータ</param>
        /// <returns>正常時：空文字　エラー時：エラーメッセージ</returns>
        private string BuildCsvData(FoodProcsEntities context, HttpPostedFile csvFileData)
        {
            int rowNumber = 0;  // 行番号
            string errMessage;
            bool isSaved = false;

            using (TextReader reader = new StreamReader(csvFileData.InputStream, System.Text.Encoding.UTF8))
            {
                // 検索条件の日付とファイルのヘッダにある在庫日付が同じであること。
                // 在庫日付のある2行目を取得し、在庫日付をチェックします。
                string[] headerData = reader.ReadLine().Split(Delimiter);
                headerData = reader.ReadLine().Split(Delimiter);
                rowNumber = 2;

                // 在庫日付
                string fileZaikoHizuke = headerData[1];
                
                // ファイルの在庫日付はスラッシュ区切りされていることを前提にします。
                if (!(fileZaikoHizuke.IndexOf('/') > 0))
                {
                    // スラッシュ区切りがない場合はエラー
                    return Resources.MS0767;
                }

                if (System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName == "en")
                {
                    string[] dAry = fileZaikoHizuke.Split('/');
                    dAry[0] = getDoubleDigit("00" + dAry[0]);
                    dAry[1] = getDoubleDigit("00" + dAry[1]);
                    fileZaikoHizuke = dAry[0] + "/" + dAry[1] + "/" + dAry[2];
                }
                else if (System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName == "vi")
                {
                    string[] dAry = fileZaikoHizuke.Split('/');
                    dAry[0] = getDoubleDigit("00" + dAry[0]);
                    dAry[1] = getDoubleDigit("00" + dAry[1]);
                    fileZaikoHizuke = dAry[2] + "/" + dAry[1] + "/" + dAry[0];
                }

                if (string.IsNullOrEmpty(fileZaikoHizuke) || insertSlash(fileZaikoHizuke) != hizuke.ToString("yyyy/MM/dd"))
                {
                    // 検索条件とCSVヘッダの日付が違う場合はエラーを表示
                    return Resources.MS0767;
                }

                do
                {
                    rowNumber++;
                    string[] splitData = reader.ReadLine().Split(Delimiter);

                    // ヘッダーは飛ばす
                    if (rowNumber > headerRowNo)
                    {
                        // 項目数のチェック
                        if (splitData.Length != CsvItemCount)
                        {
                            // 表示用にヘッダ内改行回数を引きます
                            string param = String.Format(Resources.LineUnit, (rowNumber - headerRowNo).ToString());
                            return string.Format(Resources.MS0735, param);
                        }

                        // Excelの時点で行を空白にした場合、タブのみが残るため、
                        // 一行全てがタブのみの場合はスキップします。
                        int i, iLen, cnt;
                        for (i = 0, iLen = splitData.Length, cnt = 0; i < iLen; i++)
                        {
                            if (string.IsNullOrEmpty(splitData[i]))
                            {
                                cnt++;
                            }
                        }
                        // 全てが未入力ならスキップ
                        if (cnt == CsvItemCount)
                        {
                            continue;
                        }

                        // バリデーションチェック
                        // 表示用にヘッダ内改行回数を引きます
                        errMessage = ValidateFile(context, splitData, (rowNumber - headerRowNo));
                        if (String.IsNullOrEmpty(errMessage))
                        {
                            // チェック成功時：データ作成
                            //tr_zaiko data = CreateData(splitData);
                            tr_zaiko data = CreateData(context, splitData);
                            tr_zaiko current = GetTrZaiko(context, data);

                            // 類似データが取得できない場合は新規追加、できる場合は更新
                            if (current == null)
                            {
                                // 新規追加
                                context.AddTotr_zaiko(data);
                            }
                            else
                            {
                                // 更新
                                context.tr_zaiko.ApplyOriginalValues(data);
                                context.tr_zaiko.ApplyCurrentValues(data);
                            }

                            // 一時保存
                            context.SaveChanges();
                            isSaved = true;
                        }
                        else if (errMessage == "end")
                        {
                            // 最終行なのでスキップします。
                            continue;
                        }
                        else
                        {
                            return errMessage;
                        }
                    }
                } while (-1 < reader.Peek());
            }

            // ヘッダーしかない場合はエラー
            if (rowNumber <= headerRowNo || !isSaved)
            {
                return Resources.NoFileDataMessage;
            }

            return string.Empty;
        }

        /// <summary>
        /// ファイルサイズチェック
        /// </summary>
        /// <param name="fileData">ファイルデータ</param>
        /// <returns>正常時：空文字　エラー時：エラーメッセージ</returns>
        private string ValidateFileSize(HttpPostedFile fileData)
        {
            var mbLength = Math.Round(fileData.ContentLength / Math.Pow(2, 20), 10);

            if (mbLength > MaxFileSize)
            {
                return string.Format(Resources.FileSizeErrorMessage, MaxFileSize);
            }

            if (mbLength <= 0)
            {
                return Resources.NoFileDataMessage;
            }
            return string.Empty;
        }

        /// <summary>
        /// 画面の値でサーバ処理に使用する値を保持します。
        /// </summary>
        /// <param name="httpRequest">リクエスト</param>
        private void SetPageValue(HttpRequest httpRequest)
        {
            for (int i = 0; i < httpRequest.Form.Count; i++)
            {
                var key = httpRequest.Form.GetKey(i);
                var value = httpRequest.Form[i];

                switch (key)
                {
                    case "con_dt_zaiko":
                        DateTime out_dt_hizuke;
                        if (!string.IsNullOrEmpty(value) && DateTime.TryParse(value, out out_dt_hizuke))
                        {
                            hizuke = out_dt_hizuke;
                        }
                        break;

                    case "kbn_zaiko":
                        if (!string.IsNullOrEmpty(value))
                        {
                            zaikoKubun = short.Parse(value);
                        }
                        break;

                    case "cd_soko":
                        sokoCode = value;
                        break;

                    case "offset":
                        if (!string.IsNullOrEmpty(value))
                        {
                            offset = int.Parse(value);
                        }
                        break;

                    case "lit_hinCode":
                        HIN_CODE = value;
                        break;

                    case "lit_zaikoNonyu":
                        ZAIKOSU_NONYU = value;
                        break;

                    case "lit_zaikohasuNonyu":
                        ZAIKOHASU_NONYU = value;
                        break;

                    case "lit_zaikoShiyo":
                        ZAIKOSU_SHIYO = value;
                        break;

                    case "lit_zaikoDate":
                        ZAIKO_KAKUTEI_DATE = value;
                        break;

                    case "lit_tanaTank":
                        TANA_TANKA = value;
                        break;
                    default:
                        break;
                };
            }
            nowDateTime = DateTime.UtcNow;
            nowDate = DateTime.Now.ToShortDateString();

            // 画面の値ではないが、ここでセット
            headerRowNo = int.Parse(Resources.GenshizaiZaikoNyuryokuHeaderRowNo);
        }

        /// <summary>
        /// ファイルについてのチェックを行います。
        /// </summary>
        /// <param name="postedFile">ファイル</param>
        /// <returns>正常時：空白、異常時：エラーメッセージ</returns>
        private string checkFile(HttpPostedFile postedFile)
        {
            string fileName = postedFile.FileName;
            string extension = fileName.Substring(fileName.Length - 4, 4);
            string errorMessage;

            // 拡張子のチェック：csvまたはtxt形式であること。
            if ((String.Compare(extension, ".csv", true) != 0) && (String.Compare(extension, ".txt", true) != 0))
            {
                // 失敗のレスポンスを生成して返します。
                return Resources.NotCSVFileMessage;
            }

            // ファイルサイズ検証
            errorMessage = ValidateFileSize(postedFile);
            if (!string.IsNullOrEmpty(errorMessage))
            {
                // 失敗のレスポンスを生成して返します。
                return errorMessage;
            }

            return string.Empty;
        }

        /// <summary>
        /// ファイル内容のバリデーション
        /// </summary>
        /// <param name="context">エンティティ</param>
        /// <param name="fileData">ファイルデータ</param>
        /// <param name="rowNumber">行番号</param>
        /// <returns>正常時：空文字　エラー時：エラーメッセージ</returns>
        private string ValidateFile(FoodProcsEntities context, string[] fileData, int rowNumber)
        {
            string message = string.Empty;

            string hinmeiCode = fileData[hinmeiCodeIndex];
            string hinmeiName = fileData[hinmeiNameIndex];

            // 品名コードと原資材名に値がない場合は合計行と判断し、保存処理を行う。
            if (string.IsNullOrEmpty(hinmeiCode) && string.IsNullOrEmpty(hinmeiName))
            {
                return "end";
            }

            // 必須項目に値が入っていること。
            message = checkRequired(fileData, rowNumber);
            if (!string.IsNullOrEmpty(message))
            {
                return message;
            }

            // 品名マスタからデータが取得できること
            message = checkHinMaster(context, fileData, rowNumber);
            if (!string.IsNullOrEmpty(message))
            {
                return message;
            }

            //// 実在庫数確定日のチェック
            //message = checkJissekiZaikoDate(fileData, rowNumber);
            //if (!string.IsNullOrEmpty(message))
            //{
            //    return message;
            //}

            // 実在庫数(使用単位)のチェック
            message = checkZaikoSu(fileData, rowNumber);
            if (!string.IsNullOrEmpty(message))
            {
                return message;
            }

            // 単価のチェック
            message = checkTanaTanka(fileData, rowNumber);
            if (!string.IsNullOrEmpty(message))
            {
                return message;
            }

            return string.Empty;
        }

        /// <summary>
        /// 必須項目に値があるかチェックします。
        /// </summary>
        /// <param name="data">CSV1行分のデータ</param>
        /// <param name="rowNumber">CSVの該当行数</param>
        /// <returns>正常時：空白、異常時：エラーメッセージ</returns>
        private string checkRequired(string[] data, int rowNumber)
        {
            /// 画面必須項目
            // 実在庫数(納入単位)
            if (string.IsNullOrEmpty(data[zaikosuNonyuIndex]))
            {
                return ErrorMessageRequired(ZAIKOSU_NONYU, rowNumber);
            }
            // 実在庫端数(納入単位)
            if (string.IsNullOrEmpty(data[zaikohasuNonyuIndex]))
            {
                return ErrorMessageRequired(ZAIKOHASU_NONYU, rowNumber);
            }
            // 実在庫数(使用単位)
            if (string.IsNullOrEmpty(data[zaikosuShiyoIndex]))
            {
                return ErrorMessageRequired(ZAIKOSU_SHIYO, rowNumber);
            }

            return string.Empty;
        }

        /// <summary>
        /// CSVの品名コードが品名マスタにあること。
        /// </summary>
        /// <param name="context">エンティティ</param>
        /// <param name="data">CSV1行分のデータ</param>
        /// <param name="rowNumber">CSVの該当行数</param>
        /// <returns>正常時：空白、異常時：エラーメッセージ</returns>
        private string checkHinMaster(FoodProcsEntities context, string[] data, int rowNumber)
        {
            // 品名マスタのデータを取得
            string hinmeiCode = data[hinmeiCodeIndex];
            ma_hinmei current = (from ma in context.ma_hinmei
                                 where ma.cd_hinmei == hinmeiCode
                                      && (ma.kbn_hin == ActionConst.GenryoHinKbn
                                          || ma.kbn_hin == ActionConst.ShizaiHinKbn
                                          || ma.kbn_hin == ActionConst.JikaGenryoHinKbn)
                                 select ma).FirstOrDefault();

            // 取得できない場合はエラー
            if (current == null)
            {
                return ErrorMessageNoFileData(HIN_CODE, rowNumber);
            }
            else
            {
                return string.Empty;
            }
        }

        /// <summary>
        /// 実在庫数確定日のチェックを行います。
        /// </summary>
        /// <param name="data">CSV1行分のデータ</param>
        /// <param name="rowNumber">CSVの該当行数</param>
        /// <returns>正常時：空白、異常時：エラーメッセージ</returns>
        private string checkJissekiZaikoDate(string[] data, int rowNumber)
        {
            // 日付型に変換できること。
            DateTime out_dt_zaiko;
            string check_dt_zaiko = insertSlash(data[zaikoDateIndex]);
            if (!DateTime.TryParse(check_dt_zaiko, out out_dt_zaiko))
            {
                return ErrorMessageFormat(ZAIKO_KAKUTEI_DATE, rowNumber);
            }

            return string.Empty;
        }

        /// <summary>
        /// 実在庫数(使用単位)のチェックを行います。
        /// </summary>
        /// <param name="data">CSV1行分のデータ</param>
        /// <param name="rowNumber">CSVの該当行数</param>
        /// <returns>正常時：空白、異常時：エラーメッセージ</returns>
        private string checkZaikoSu(string[] data, int rowNumber)
        {
            // float型に変換できること。
            decimal out_su_zaiko;
            string check_su_zaiko = data[zaikosuShiyoIndex].Replace("\"", "");
            if (System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName == "vi")
            {
                check_su_zaiko = check_su_zaiko.Replace(",", "").Replace(".", ",");
            }
            data[zaikosuShiyoIndex] = check_su_zaiko;
            if (!decimal.TryParse(check_su_zaiko, out out_su_zaiko))
            {
                return ErrorMessageFormat(ZAIKOSU_SHIYO, rowNumber);
            }

            // 0以上、99999999.999以下であること
            decimal min = (decimal)0;
            //decimal max = (decimal)999999.999999;
            //BRC t.Sato 2021/03/08 Start -->
            //decimal max = (decimal)999999.999;
            decimal max = (decimal)99999999.999;
            //BRC t.Sato 2021/03/08 End <--
            if (out_su_zaiko < min || max < out_su_zaiko)
            {
                return ErrorMesageRange(ZAIKOSU_SHIYO, rowNumber, min, max);
            }

            return string.Empty;
        }

        /// <summary>
        /// 実在庫数(使用単位)のチェックを行います。
        /// </summary>
        /// <param name="data">CSV1行分のデータ</param>
        /// <param name="rowNumber">CSVの該当行数</param>
        /// <returns>正常時：空白、異常時：エラーメッセージ</returns>
        private string checkTanaTanka(string[] data, int rowNumber)
        {
            // float型に変換できること。
            decimal out_tan_tana;
            string check_tan_tana = data[tanaTankaIndex].Replace("\"", "");
            if (System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName == "vi")
            {
                check_tan_tana = check_tan_tana.Replace(",", "").Replace(".", ",");
            }
            data[tanaTankaIndex] = check_tan_tana;
            if (!decimal.TryParse(check_tan_tana, out out_tan_tana))
            {
                return ErrorMessageFormat(TANA_TANKA, rowNumber);
            }

            // 0以上、99999999以下であること
            decimal min = (decimal)0;
            //BRC t.Sato 2021/03/10 Start -->
            //decimal max = (decimal)999999;
            decimal max = (decimal)99999999;
            //BRC t.Sato 2021/03/10 End <--
            if (out_tan_tana < min || max < out_tan_tana)
            {
                return ErrorMesageRange(TANA_TANKA, rowNumber, min, max);
            }

            return string.Empty;
        }

        /// <summary>
        /// 必須エラーメッセージの作成
        /// </summary>
        /// <param name="itemName">項目名</param>
        /// <param name="rowNumer">行番号</param>
        /// <returns>エラーメッセージ</returns>
        private string ErrorMessageRequired(string itemName, int rowNumer)
        {
            string param = String.Format(Resources.LineUnit, rowNumer.ToString());
            string msg = String.Format(Resources.MS0042, itemName) + String.Format(Resources.CsvMsgTargetData, param);
            return msg;
        }

        /// <summary>
        /// 存在チェックエラーメッセージの作成
        /// </summary>
        /// <param name="itemName">項目名</param>
        /// <param name="rowNumer">行番号</param>
        /// <returns>エラーメッセージ</returns>
        private string ErrorMessageNoFileData(string itemName, int rowNumer)
        {
            string param = String.Format(Resources.LineUnit, rowNumer.ToString()) + ActionConst.Comma + itemName;
            string msg = Resources.NoFileDataMessage + String.Format(Resources.CsvMsgTargetData, param);
            return msg;
        }

        /// <summary>
        /// 形式チェックエラーメッセージの作成
        /// </summary>
        /// <param name="itemName">項目名</param>
        /// <param name="rowNumer">行番号</param>
        /// <returns>エラーメッセージ</returns>
        private string ErrorMessageFormat(string itemName, int rowNumer)
        {
            string param = String.Format(Resources.LineUnit, rowNumer.ToString()) + ActionConst.Comma + itemName;
            string msg = Resources.InvalidDataFormatMessage + String.Format(Resources.CsvMsgTargetData, param);
            return msg;
        }

        /// <summary>
        /// 範囲チェックエラーメッセージの作成
        /// </summary>
        /// <param name="itemName">項目名</param>
        /// <param name="rowNumber">行番号</param>
        /// <param name="min">最小値</param>
        /// <param name="max">最大値</param>
        /// <returns>エラーメッセージ</returns>
        private string ErrorMesageRange(string itemName, int rowNumber, decimal min, decimal max)
        {
            string msg = string.Format(Resources.MS0666, itemName, min.ToString("#,0.######"), max.ToString("#,0.######"));
            string param = string.Format(Resources.LineUnit, rowNumber.ToString());
            msg = msg + string.Format(Resources.CsvMsgTargetData, param);
            return msg;
        }

        /// <summary>
        /// 保存用のワークデータを作成する
        /// </summary>
        /// <param name="context">エンティティ</param>
        /// <param name="fileData">ファイルデータ</param>
        /// <returns>作成した在庫トランデータ</returns>
        //private tr_zaiko CreateData(string[] fileData)
        private tr_zaiko CreateData(FoodProcsEntities context, string[] fileData)
        {
            tr_zaiko wk_data = new tr_zaiko();

            // 品名コード
            wk_data.cd_hinmei = fileData[hinmeiCodeIndex];
            // 日付
            wk_data.dt_hizuke = hizuke;
            // 在庫数
            wk_data.su_zaiko = decimal.Parse(fileData[zaikosuShiyoIndex]);
            // 実在庫数確定日
            wk_data.dt_jisseki_zaiko = GetUtcDate(nowDate, 10);// 10時固定
            // 更新日
            wk_data.dt_update = nowDateTime;
            // 更新者
            wk_data.cd_update = User.Identity.Name;
            // 棚卸個単価
            wk_data.tan_tana = decimal.Parse(fileData[tanaTankaIndex]);
            // 在庫区分
            wk_data.kbn_zaiko = zaikoKubun;
            // 倉庫コード
            //wk_data.cd_soko = sokoCode;
            wk_data.cd_soko = getSokoCode(context, fileData[hinmeiCodeIndex]);
            
            return wk_data;
        }

        /// <summary>
        /// 任意の在庫トランのデータを取得します。
        /// </summary>
        /// <param name="context">エンティティ</param>
        /// <param name="data">在庫トランデータ</param>
        /// <returns>在庫トランデータ、もしくはnull</returns>
        private tr_zaiko GetTrZaiko(FoodProcsEntities context, tr_zaiko data)
        {
            string cdSoko = getSokoCode(context, data.cd_hinmei);

            tr_zaiko current = (from tr in context.tr_zaiko
                                where tr.cd_hinmei == data.cd_hinmei
                                    && tr.dt_hizuke == data.dt_hizuke
                                    && tr.kbn_zaiko == data.kbn_zaiko
                                    //&& tr.cd_soko == data.cd_soko
                                    && tr.cd_soko == cdSoko
                                select tr).FirstOrDefault();
            return current;
        }

        /// <summary>
        /// 日付をUTCに変換して返却する。
        /// </summary>
        /// <param name="date">日付</param>
        /// <returns>変換後の日付</returns>
        private DateTime GetUtcDate(string date, int offset)
        {
            //データ登録用にmm/dd/yyyy形式に整形する(アップロードファイルデータ上、mm/dd/yyyyが来た場合変換)

            string str = insertSlash(date);    // スラッシュを付ける
            DateTime dt = DateTime.Parse(str).AddHours(offset); // UTC日付に変換
            return dt;
        }

        /// <summary>
        /// 文字型の日付にスラッシュを付与する。
        /// yyyyMMdd、yyMMddのどちらでも対応。
        /// </summary>
        /// <param name="str">文字型の日付</param>
        /// <returns>スラッシュ付与</returns>
        private string insertSlash(string str)
        {
            // 文字数によってスラッシュを付ける位置を変更する
            string ret = str;
            if (str.Length == 6)
            {
                ret = str.Insert(2, "/").Insert(5, "/");
            }
            else if (str.Length == 8)
            {
                //8桁のみの条件だと、「2015/9/9」や「9/9/2015」が引っかかってしまう為、文字中スラッシュの有無を条件に追加。
                if (str.IndexOf("/") > 0)
                {
                    //スラッシュあり
                    // 英語対応(dd/MM/yyyy形式の文字列だとパースできない)
                    if (System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName == "en")
                    {
                        if (System.Threading.Thread.CurrentThread.CurrentUICulture.Name == "en-US")
                        {
                            //米国はMM/dd/yyyy形式
                            string[] dateArray = ret.Split('/');
                            ret = dateArray[2] + "/" + dateArray[0] + "/" + dateArray[1];
                        }
                        else
                        {
                            //他は1dd/MM/yyyy形式
                            string[] dateArray = ret.Split('/');
                            ret = dateArray[2] + "/" + dateArray[1] + "/" + dateArray[0];
                        }
                    }
                    else {
                        //そのままyyyy/mm/ddを通す
                    }
                }
                else
                {
                    //スラッシュなし
                    ret = str.Insert(4, "/").Insert(7, "/");
                }
            }
            // 6文字でも8文字でもない場合は最初からスラッシュ付きなので、そのまま返却

            // 英語対応(dd/MM/yyyy形式の文字列だとパースできない)
            if (System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName == "en")
            {
                if (System.Threading.Thread.CurrentThread.CurrentUICulture.Name == "en-US")
                {
                    //米国はMM/dd/yyyy形式
                    string[] dateArray = ret.Split('/');
                    ret = dateArray[2] + "/" + dateArray[0] + "/" + dateArray[1];
                }
                else
                {
                    //他は1dd/MM/yyyy形式
                    string[] dateArray = ret.Split('/');
                    ret = dateArray[2] + "/" + dateArray[1] + "/" + dateArray[0];
                }
            }
            else
            {
                //そのままyyyy/mm/ddを通す
            }
            return ret;
        }

        private string getDoubleDigit(string dTmp)
        {
            return dTmp.Substring(dTmp.Length - 2);
        }

        /// <summary>
        /// 倉庫コードを取得する。
        /// </summary>
        /// <param name="context">エンティティ</param>
        /// <param name="cdHinmei">品名コード</param>
        /// <returns>倉庫コード</returns>
        private string getSokoCode(FoodProcsEntities context, string cdHinmei)
        {
            string cdSoko;

            //品名コードから品名情報の取得
            ma_hinmei hinmeiCurrent = (from tr in context.ma_hinmei where tr.cd_hinmei == cdHinmei select tr).FirstOrDefault();

            //品名情報を元に対象の倉庫コードを取得する
            vw_soko_info sokoCurrent = (from tr in context.vw_soko_info where tr.cd_hinmei == cdHinmei && tr.kbn_hin == hinmeiCurrent.kbn_hin select tr).FirstOrDefault();

            //取得した倉庫コードの設定
            cdSoko = sokoCurrent.cd_soko;

            return cdSoko;

        }

    }
}