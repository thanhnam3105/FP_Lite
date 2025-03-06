using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Security;
using Tos.FoodProcs.Web.Properties;
using Tos.FoodProcs.Web.Data;

namespace Tos.FoodProcs.Web.Account
{
	public partial class Login : System.Web.UI.Page
	{
		// ログインエラー時のメッセージ
		private string loginErrorMessage = "";
        public string colorMenuBar = System.Web.Configuration.WebConfigurationManager.AppSettings["colorMenuBar"];

		protected void Page_Load(object sender, EventArgs e)
		{
			loginErrorMessage = "";
			if (Page.IsPostBack)
			{
				if (Membership.ValidateUser(userid.Value, password.Value))
				{
                    // for un-use flag
                    // 未使用フラグを確認し、非活性の場合はログインできない
                    FoodProcsEntities fpcontext = new FoodProcsEntities();
                    fpcontext.ContextOptions.LazyLoadingEnabled = false;
                    Int16 flagFalse = Int16.Parse(Resources.FlagFalse);
                    ma_tanto result = fpcontext.ma_tanto.FirstOrDefault(tanto => (tanto.cd_tanto == userid.Value && tanto.flg_mishiyo == flagFalse));
                    if(result != null){
                        FormsAuthentication.RedirectFromLoginPage(userid.Value, persistlogin.Checked);
                    }
					// 未使用フラグが立っていた場合はメッセージを設定
					loginErrorMessage = Resources.InvalidAuthoritySetting;
				}
				else
				{
					// ログインに失敗した場合はメッセージを設定
					loginErrorMessage = Resources.InvalidUserIdOrPassword;
				}
			}
		}
		/// <summary>
		/// ログインエラーのメッセージを取得します。
		/// </summary>
		/// <returns>ログインエラーメッセージ</returns>
		/// <remarks>このメソッドは aspx 側から呼び出すために定義されています。</remarks>
		public string getLoginError()
		{
			return loginErrorMessage;
		}
	}
}