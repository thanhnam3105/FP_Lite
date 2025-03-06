using System;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Web.Http.Filters;
using Tos.FoodProcs.Web.Logging;
using Tos.FoodProcs.Web.Properties;

namespace Tos.FoodProcs.Web.Controllers
{
	public class LoggingExceptionFilterAttribute : GenericExceptionFilterAttribute
	{
		protected override void HandleException(HttpActionExecutedContext actionExecutedContext)
		{
			Logger.App.Error(Properties.Resources.ServiceError, actionExecutedContext.Exception);

            // ユーザーに通知するメッセージを指定して、例外をクライアントに送信します。
            Exception ex = new Exception(Resources.ServiceErrorForClient);
            var formatter = GlobalConfiguration.Configuration.Formatters.JsonFormatter;

            HttpResponseMessage response = new HttpResponseMessage(HttpStatusCode.InternalServerError)
            {
                Content = new ObjectContent<Exception>(ex, formatter)
            };

            actionExecutedContext.Response = response;
		}
	}
}