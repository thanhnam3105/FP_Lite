using System;
using System.Collections.Generic;
using System.Data.Objects;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Web.Http;
using System.IO;
using System.Xml.Linq;
using System.Text;
using Tos.FoodProcs.Web.Utilities;
using Tos.FoodProcs.Web.Services;
using Tos.FoodProcs.Web.Data;
using System.Data;
using Tos.FoodProcs.Web.Logging;
using System.Web.Http.OData.Query;
using Tos.FoodProcs.Web.Properties;

namespace Tos.FoodProcs.Web.Controllers
{
    /// <summary>
    /// 納入依頼書リスト：PDFの件数をカウントするコントローラを定義します。
    /// </summary>
    /// <remarks>
    /// </remarks>

    [Authorize]
    [LoggingExceptionFilter]
    public class NonyuIraishoListPDFCountController : ApiController
    {
        // 発注番号取得時の判定用ブレイクキー
        /// <summary>発注番号取得時の判定用：取引先コード</summary>
        //private String TorihikiCode = "";
        /// <summary>発注番号取得時の判定用：荷受コード</summary>
        private String NiukeCode = "";

        /// <summary>検索結果のレコード数</summary>
        private int ResultCount = 0;

        // Entity取得
        private FoodProcsEntities context = new FoodProcsEntities();
        
        /// <param name="criteria">検索条件</param>
        /// <param name="maxPages">出力できる最大ページ数</param>
        /// <param name="maxColumn">1ページに出力する列数</param>
        /// <returns></returns>
        public int Get([FromUri]NonyuIraishoPdfCountCriteria criteria, int maxPages, int maxColumn)
        {
            try
            {
                int pageCount = 1;

			    // バリデーションエラーおよび競合エラー時にクライアントに返却するオブジェクトの遅延読み込み防止
			    context.ContextOptions.LazyLoadingEnabled = false;

                // 明細情報の取得
                IEnumerable<usp_NonyuIraishoListPdf_select_Result> results;
                results = GetMeisai(criteria);

                // 並び替え
                results = OrderByResult(results);

                // ページカウント処理
                pageCount = CountPage(results, criteria, maxPages, maxColumn);
                
                // ページ数の返却
                return pageCount;
            }
            catch (HttpResponseException ex)
            {
                Logger.App.Error("http response exception", ex);
                throw ex;
            }
            catch (Exception e)
            {
                Logger.App.Error("response exception", e);
                throw e;
            }
        }


        /// <summary>明細データ取得処理</summary>
        /// <param name="criteria">検索条件</param>
        /// <returns>検索結果</returns>
        private IEnumerable<usp_NonyuIraishoListPdf_select_Result> GetMeisai(
            NonyuIraishoPdfCountCriteria criteria)
        {
            short yotei = 0;
            short mishiyoFlgShiyo = ActionConst.FlagFalse;
            string torihikisakiCode = ChangedNullToEmpty(criteria.torihikiCode);

            // 印刷種別が「指定印刷」の場合
            if (!ActionConst.NonyuIraishoPrintTypeAllPrint.Equals(criteria.printType)
                && !ActionConst.NonyuIraishoPrintTypeSelectAllPrint.Equals(criteria.printType))
            {
                // 画面．検索条件/取引先コードを設定する
                torihikisakiCode = criteria.torihikisaki;
            }

            // 「予定なしの品目も出力する」にチェックが入っていた場合
            if (criteria.yotei)
            {
                yotei = 1;
            }

            // 明細情報の取得処理
            IEnumerable<usp_NonyuIraishoListPdf_select_Result> result;
            result = context.usp_NonyuIraishoListPdf_select(
                criteria.dateFrom,
                criteria.dateTo,
                criteria.sysdate,
                yotei,
                ActionConst.YoteiYojitsuFlag,
                ActionConst.JissekiYojitsuFlag,
                mishiyoFlgShiyo,
                torihikisakiCode,
                ChangedNullToEmpty(criteria.hinCode),
                ActionConst.KgKanzanKbn,
                ActionConst.LKanzanKbn
            ).AsEnumerable();

            return result;
        }

        /// <summary>
        /// 並び替え処理。引数のデータを次の順に並び替える。
        /// 取引先コード＞荷受場所コード＞分類コード＞品名コード
        /// </summary>
        /// <param name="data">検索結果</param>
        /// <returns>並び替え結果</returns>
        private IEnumerable<usp_NonyuIraishoListPdf_select_Result> OrderByResult(
            IEnumerable<usp_NonyuIraishoListPdf_select_Result> data)
        {
            IEnumerable<usp_NonyuIraishoListPdf_select_Result> result;
            
            // レコード数を取得
            List<usp_NonyuIraishoListPdf_select_Result> list
                = data.ToList<usp_NonyuIraishoListPdf_select_Result>();
            ResultCount = list.Count;

            // 並び替え(取引先コード＞荷受場所コード＞分類コード＞品名コード)
            result = list.OrderBy(key1 => key1.cd_torihiki).ThenBy(
                key2 => key2.cd_niuke_basho).ThenBy(key3 => key3.cd_bunrui).ThenBy(key4 => key4.cd_hinmei);

            return result;
        }

        /// <summary>ページカウント処理</summary>
        /// <param name="result">検索結果</param>
        /// <param name="criteria">検索条件</param>
        /// <param name="maxPages">出力できる最大ページ数</param>
        /// <param name="maxColumn">1ページに出力する列数</param>
        /// <returns>ページのカウント数</returns>
        private int CountPage(IEnumerable<usp_NonyuIraishoListPdf_select_Result> result,
            NonyuIraishoPdfCountCriteria criteria, int maxPages, int maxColumn)
        {
            int pageCount = 1;
            int rowCount = 0;
            bool newPageFlg = false;
            bool startPageFlg = true;
            string beforeTorihikiCode = ""; // 比較用変数：取引コード
            string beforeHinmeiCode = "";   // 比較用変数：品名コード
            int dataCount = 0;  // 現在の明細行数

            foreach (usp_NonyuIraishoListPdf_select_Result data in result)
            {
                // ★ページ数の上限チェック
                if (pageCount > maxPages)
                {
                    break;
                }

                // ページ始めの初期処理
                if (startPageFlg)
                {
                    string niukeCode = data.cd_niuke_basho;
                    if (!String.IsNullOrEmpty(criteria.niukeCode))
                    {   // 画面で指定された荷受場所コードがある場合、それを使用する
                        niukeCode = criteria.niukeCode;
                    }
                    rowCount = 1;
                    NiukeCode = niukeCode;
                    beforeTorihikiCode = data.cd_torihiki;
                    beforeHinmeiCode = data.cd_hinmei;
                    startPageFlg = false;
                }

                // 品コードが変わった場合、次の列へ
                if (!beforeHinmeiCode.Equals(data.cd_hinmei))
                {
                    // 列カウントが最終列だった場合、改ページ
                    if (rowCount == maxColumn)
                    {
                        newPageFlg = true;
                    }
                    else
                    {
                        // 次の列へ
                        rowCount++;
                        beforeHinmeiCode = data.cd_hinmei;
                    }
                }

                // 作成画面で「分類毎に改頁する」にチェックが入っていた場合
                // ただし、最終レコードの場合は判定しない
                if (criteria.bunrui && ResultCount > (dataCount + 1))
                {
                    usp_NonyuIraishoListPdf_select_Result nextData = result.ElementAt(dataCount + 1);
                    if (data.cd_bunrui != nextData.cd_bunrui)
                    {
                        // 次の明細で分類コードが変わる場合、改ページする
                        newPageFlg = true;
                    }
                }

                // 次の明細をチェック
                if (!newPageFlg)
                {
                    newPageFlg = CheckNextMeisai(result, data,
                        beforeTorihikiCode, criteria.niukeCode, criteria.bunrui, dataCount);
                }

                // 改ページ処理
                if (newPageFlg)
                {
                    // 改ページ処理
                    pageCount++;
                    newPageFlg = false;
                    startPageFlg = true;
                }
                dataCount++;
            }

            return pageCount;
        }

        /// <summary>次の明細をチェックし、条件が一致した場合は改ページフラグをONにする。
        /// 次の明細がない場合は判定しないのでfalseを返す。
        /// </summary>
        /// <param name="sortData">１取引コード分の明細情報</param>
        /// <param name="data">現在の明細情報</param>
        /// <param name="beforeToriCd">現在見ている取引先コード</param>
        /// <param name="niukeCode">作成画面で指定した荷受場所コード</param>
        /// <param name="bunrui">「分類毎に改頁する」フラグ</param>
        /// <param name="dataCount">現在の明細行数</param>
        /// <returns>改ページフラグ</returns>
        private Boolean CheckNextMeisai(IEnumerable<usp_NonyuIraishoListPdf_select_Result> result,
            usp_NonyuIraishoListPdf_select_Result data,
            string beforeToriCd, string niukeCode, bool bunrui, int dataCount)
        {
            // 次のレコードをチェック
            // ただし、最終レコードの場合は判定しない
            if (ResultCount > (dataCount + 1))
            {
                usp_NonyuIraishoListPdf_select_Result nextData = result.ElementAt(dataCount + 1);

                // 次の明細で取引先コードが変わる場合、改ページする
                if (!beforeToriCd.Equals(nextData.cd_torihiki))
                {
                    return true;
                }

                // 荷受場所コードが指定されていない場合
                if (String.IsNullOrEmpty(niukeCode))
                {
                    if (NiukeCode != nextData.cd_niuke_basho)
                    {
                        // 荷受場所コードが変わった場合、改ページする
                        return true;
                    }
                }

                // 作成画面で「分類毎に改頁する」にチェックが入っていた場合
                if (bunrui)
                {
                    if (data.cd_bunrui != nextData.cd_bunrui)
                    {
                        // 次の明細で分類コードが変わる場合、改ページする
                        return true;
                    }
                }
            }
            return false;
        }
        
        /// <summary>nullの場合、空文字に変更します。</summary>
        /// <param name="value">判定する値</param>
        /// <returns>判定後の値</returns>
        private string ChangedNullToEmpty(string value)
        {
            if (String.IsNullOrEmpty(value) || value == "null")
            {
                value = "";
            }
            return value;
        }
    }
}