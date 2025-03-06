using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Security;

namespace Tos.FoodProcs.Web
{
    public partial class SiteMaster : System.Web.UI.MasterPage
    {
        public string colorMenuBar = System.Web.Configuration.WebConfigurationManager.AppSettings["colorMenuBar"];
        protected void Page_Load(object sender, EventArgs e)
        {
			this.loginButton.ServerClick += new EventHandler(loginButton_ServerClick);
        }

		private void loginButton_ServerClick(object sender, EventArgs e)
		{
			FormsAuthentication.SignOut();
			FormsAuthentication.RedirectToLoginPage();
		}
    }
}
