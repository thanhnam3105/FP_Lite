using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Net.Http;
using System.Net;
using System.IO;
using System.Text;
using System.Net.Http.Headers;

namespace Tos.FoodProcs.Web.Controllers
{
	public static class FileDownloadUtility
	{
		/// <summary>
		/// 指定された文字列をテキストファイルとしてダウンロードするためのレスポンスを生成します。
		/// </summary>
		/// <param name="content">コンテンツ</param>
		/// <param name="fileName">ファイル名</param>
		/// <returns>レスポンス</returns>
		public static HttpResponseMessage CreateTextFileResponse(string content, string fileName)
		{
			HttpResponseMessage result = new HttpResponseMessage(HttpStatusCode.OK);
            fileName = fileName.Replace(" ", "_");
            var lang = System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName;
            if (lang == "vi")
            {
                result.Content = new StreamContent(new MemoryStream(Encoding.GetEncoding("utf-8").GetBytes(content)));
            }
            else
            {
                result.Content = new StreamContent(new MemoryStream(Encoding.GetEncoding("shift-jis").GetBytes(content)));
            }
            result.Content.Headers.ContentType = new MediaTypeHeaderValue("application/octet-stream");
			result.Content.Headers.ContentDisposition = new System.Net.Http.Headers.ContentDispositionHeaderValue("attachment");
			result.Content.Headers.ContentDisposition.FileName = HttpUtility.UrlEncode(fileName);
            result.Headers.CacheControl = new CacheControlHeaderValue { Private = true, MaxAge = TimeSpan.Zero };
			return result;
		}

        /// <summary>
        /// 【Excel出力用】指定された文字列をExcelファイルとしてダウンロードするためのレスポンスを生成します。
        /// </summary>
        /// <param name="content">コンテンツ</param>
        /// <param name="fileName">ファイル名</param>
        /// <returns>レスポンス</returns>
        public static HttpResponseMessage CreateExcelFileResponse(byte[] mem, string fileName)
        {
            HttpResponseMessage result = new HttpResponseMessage();
            fileName = fileName.Replace(" ", "_");
            result.StatusCode = HttpStatusCode.OK;
            result.Content = new ByteArrayContent(mem); //クライアントに返すStreamへ 
            result.Content.Headers.ContentType = new MediaTypeHeaderValue("application/octet-stream");
            result.Content.Headers.ContentDisposition = new System.Net.Http.Headers.ContentDispositionHeaderValue("attachment");
            result.Content.Headers.ContentDisposition.FileName = HttpUtility.UrlEncode(fileName); //出力されるファイル名称
            result.Headers.CacheControl = new CacheControlHeaderValue { Private = true, MaxAge = TimeSpan.Zero };

            return result;
        }

        /// <summary>
        /// 【Excel出力用】Excelファイルのレスポンスにcookieを追加する。
        /// </summary>
        /// <param name="response">レスポンス</param>
        /// <param name="name">名称</param>
        /// <param name="value">値</param>
        /// <returns>レスポンス</returns>
        public static HttpResponseMessage CreateCookieAddResponse(byte[] mem, string fileName, string name, string value)
        {
            HttpResponseMessage result = new HttpResponseMessage();
            result = CreateExcelFileResponse(mem, fileName);
            var cookie = new CookieHeaderValue(name, value);
            cookie.Expires = DateTimeOffset.Now.AddDays(1);
            cookie.Path = "/";
            result.Headers.AddCookies(new CookieHeaderValue[] { cookie });

            return result;
        }
        

        /// <summary>
        /// 【PDF出力用】指定された文字列をPDFファイルとしてダウンロードするためのレスポンスを生成します。
        /// </summary>
        /// <param name="content">コンテンツ</param>
        /// <param name="fileName">ファイル名</param>
        /// <returns>レスポンス</returns>
        public static HttpResponseMessage CreatePDFFileResponse(MemoryStream responseStream, string fileName)
        {
            HttpResponseMessage result = new HttpResponseMessage();
            fileName = fileName.Replace(" ", "_");
            result.StatusCode = HttpStatusCode.OK;
            result.Content = new StreamContent(responseStream); //クライアントに返すStreamへ 
            result.Content.Headers.ContentType = new MediaTypeHeaderValue("application/octet-stream");
            result.Content.Headers.ContentDisposition = new System.Net.Http.Headers.ContentDispositionHeaderValue("attachment");
            result.Content.Headers.ContentDisposition.FileName = HttpUtility.UrlEncode(fileName); //出力されるファイル名称
            result.Headers.CacheControl = new CacheControlHeaderValue { Private = true, MaxAge = TimeSpan.Zero };

            return result;
        }

        /// <summary>
        /// 【PDF出力エラー時用】指定された文字列をExcelファイルとしてダウンロードするためのレスポンスを生成します。
        /// </summary>
        /// <param name="content">コンテンツ</param>
        /// <param name="fileName">ファイル名</param>
        /// <returns>レスポンス</returns>
        public static HttpResponseMessage CreateErrorFileResponse(byte[] mem, string fileName)
        {
            HttpResponseMessage result = new HttpResponseMessage();
            fileName = fileName.Replace(" ", "_");
            result.StatusCode = HttpStatusCode.OK;
            result.Content = new ByteArrayContent(mem); //クライアントに返すStreamへ 
            result.Content.Headers.ContentType = new MediaTypeHeaderValue("text/html");
            result.Content.Headers.ContentDisposition = new System.Net.Http.Headers.ContentDispositionHeaderValue("attachment");
            result.Content.Headers.ContentDisposition.FileName = HttpUtility.UrlEncode(fileName); //出力されるファイル名称
            result.Headers.CacheControl = new CacheControlHeaderValue { Private = true, MaxAge = TimeSpan.Zero };

            return result;
        }
    }
}