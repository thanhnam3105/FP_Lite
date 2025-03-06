using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Net;
using Tos.FoodProcs.Web.Properties;

namespace Tos.FoodProcs.Web
{
	public partial class Error : System.Web.UI.Page
	{
        public string colorMenuBar = System.Web.Configuration.WebConfigurationManager.AppSettings["colorMenuBar"];
		protected void Page_Load(object sender, EventArgs e)
		{

			Exception exception = Server.GetLastError();

			if (exception == null)
			{
				return;
			}

			exception = exception.GetBaseException();

			Server.ClearError();

			//タイトルの設定
			messageTitle.InnerText = Resources.ErrorMessageTitle;

			//例外詳細の設定
			message.InnerText = exception.Message;
			stacktrace.InnerText = exception.StackTrace;
		}
	}
}