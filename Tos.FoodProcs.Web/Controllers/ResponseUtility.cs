using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Net.Http;
using System.Net;
using System.Web.Script.Serialization;
using System.Text;
using Tos.FoodProcs.Web.Properties;
using System.Web.Http;

namespace Tos.FoodProcs.Web.Controllers
{
	/// <summary>
	/// クライアント側へのレスポンスを返却するためのユーティリティクラスです。
	/// </summary>
	public static class ResponseUtility
	{
		
		/// <summary>
		/// 失敗のレスポンスを作成します。
		/// </summary>
		/// <param name="statusCode">HTTPステータス</param>
		/// <param name="message">クライアントに返すメッセージ</param>
		/// <returns>レスポンス</returns>
		public static HttpResponseMessage CreateFailResponse(HttpStatusCode statusCode, string message)
		{
            Exception ex = new Exception(message);
            var formatter = GlobalConfiguration.Configuration.Formatters.JsonFormatter;

            HttpResponseMessage response = new HttpResponseMessage(statusCode)
            {
                Content = new ObjectContent<Exception>(ex, formatter)
            };

            return response;
		}
	}
}