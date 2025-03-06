using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Web;
using System.Web.Http;
using System.Web.Routing;
using System.Web.Security;
using System.Web.SessionState;
using System.Net.Http;
using Tos.FoodProcs.Web.Controllers;
using Newtonsoft.Json;

namespace Tos.FoodProcs.Web
{
    public class Global : System.Web.HttpApplication
    {

        void Application_Start(object sender, EventArgs e)
        {
			RouteTable.Routes.MapHttpRoute(
				name: "Custome Service Routes",
				routeTemplate: "api/{controller}/{id}",
				defaults: new { id = RouteParameter.Optional }
			);

			GlobalConfiguration.Configuration.Filters.Add(
				new LoggingExceptionFilterAttribute()
			);

            var json = GlobalConfiguration.Configuration.Formatters.JsonFormatter;
            json.SerializerSettings.DateFormatHandling = DateFormatHandling.MicrosoftDateFormat;　// 日付フォーマットを正しく表示する
            json.SerializerSettings.DateTimeZoneHandling = DateTimeZoneHandling.Utc;　//UTC考慮の時間に変更する
            GlobalConfiguration.Configuration.EnableQuerySupport();
        }

        void Application_End(object sender, EventArgs e)
        {
            //  アプリケーションのシャットダウンで実行するコードです

        }

        /// <summary>
        /// 未処理の例外がスローされると発生する <see cref="System.Web.HttpApplication.Error"/> イベントを実装します。
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        void Application_Error(object sender, EventArgs e)
        {
            Exception exception = Server.GetLastError();
            HttpException httpException = exception as HttpException;

            // TODO: 404 (Not Fount) など 500 以外の HTTP エラーの場合にはロギングなどは実施しません。
            if (httpException != null)
            {
                if (httpException.GetHttpCode() != (int)HttpStatusCode.InternalServerError)
                {
                    return;
                }
            }

            exception = exception.InnerException.GetBaseException();
            Logging.Logger.App.Error(exception.Message, exception);
        }

        void Session_Start(object sender, EventArgs e)
        {
            // 新規セッションを開始したときに実行するコードです

        }

        void Session_End(object sender, EventArgs e)
        {
            // セッションが終了したときに実行するコードです 
            // メモ: Web.config ファイル内で sessionstate モードが InProc に設定されているときのみ、
            // Session_End イベントが発生します。 session モードが StateServer か、または 
            // SQLServer に設定されている場合、イベントは発生しません。

        }

    }
}
