using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Net.Http;
using System.Net;
using System.Web.Script.Serialization;
using System.Text;

namespace Tos.FoodProcs.Web.Controllers
{
	/// <summary>
	/// クライアント側の uploadfile.js と連携するためのユーティリティクラスです。
	/// </summary>
	public static class FileUploadUtility
	{
		private const string RequestClientKeyName = "__key";
		private const string ResponseHtmlFormat = "<html><head>" +
			"<meta http-equiv='content-type' content='text/html; charset=UTF-8' />" +
			"<script type='text/javascript'>" +
				"if(window.parent && window.parent.postMessage){{" +
					"window.parent.postMessage('{0}','{1}');" +
				"}}" +
			"</script></head>" +
			"<body>" +
				"<div class='key'>{2}</div>" +
				"<div class='result'>{3}</div>" +
				"<div class='message'>{4}</div>" +
				"<div class='data'>{5}</div>" +
			"</body></html>";

		/// <summary>
		/// 成功のレスポンスを作成します。ステータスは自動的に OK に設定されます。
		/// </summary>
		/// <param name="message">クライアントに返すメッセージ</param>
		/// <param name="data">クライアントに返す付属データ</param>
		/// <returns>レスポンス</returns>
		public static HttpResponseMessage CreateSuccessResponse(string message, object data = null)
		{
			return CreateResponse(true, HttpStatusCode.OK, message, data);
		}

		/// <summary>
		/// 失敗のレスポンスを作成します。
		/// </summary>
		/// <param name="statusCode">HTTPステータス</param>
		/// <param name="message">クライアントに返すメッセージ</param>
		/// <param name="data">クライアントに返す保続データ</param>
		/// <returns>レスポンス</returns>
		public static HttpResponseMessage CreateFailResponse(HttpStatusCode statusCode, string message, object data = null)
		{
			return CreateResponse(false, statusCode, message, data);
		}

		/// <summary>
		/// レスポンスを生成します。
		/// </summary>
		/// <param name="result">成功の場合は true 、そうでない場合は false</param>
		/// <param name="status">HTTPステータス</param>
		/// <param name="message">クライアントに返すメッセージ</param>
		/// <param name="data">クライアントに返す保続データ</param>
		/// <returns>レスポンス</returns>
		public static HttpResponseMessage CreateResponse(bool result, HttpStatusCode status, string message, object data)
		{
			HttpResponseMessage res = new HttpResponseMessage(status);
			HttpRequest req = HttpContext.Current.Request;
			string key = req.Params[RequestClientKeyName];
			string targetOrigion = "*";

			if (req.UrlReferrer != null)
			{
				targetOrigion = string.Format("{0}{1}{2}",
					req.UrlReferrer.Scheme,
					Uri.SchemeDelimiter,
					req.UrlReferrer.Host);
				if (!req.UrlReferrer.IsDefaultPort)
				{
					targetOrigion += ":" + req.UrlReferrer.Port.ToString();
				}
			}

			Dictionary<string, object> resultData = new Dictionary<string, object>(){
				    {"key", key},
				    {"result", result},
				    {"message", message},
				    {"data", data}
			    };

			JavaScriptSerializer serializer = new JavaScriptSerializer();
			string postMessageJson = serializer.Serialize(resultData);
			string dataJson = serializer.Serialize(data);

			res.Content = new StringContent(string.Format(ResponseHtmlFormat, postMessageJson, targetOrigion, key, result, ToNumericCharacterReference(message), dataJson), Encoding.UTF8, "text/html");
			return res;
		}

		/// <summary>
		/// 文字列を数値実体参照文字列に変換します。
		/// </summary>
		/// <param name="value">変換する文字列</param>
		/// <returns>変換された数値実体参照文字列</returns>
		public static string ToNumericCharacterReference(string value)
		{
			StringBuilder result = new StringBuilder();
			foreach (int v in value)
			{
				result.Append("&#x" + v.ToString("x") + ";");
			}
			return result.ToString();
		}

	}
}