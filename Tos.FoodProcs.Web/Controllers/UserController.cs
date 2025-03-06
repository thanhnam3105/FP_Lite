using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Http;
using System.Web.Security;
using Tos.FoodProcs.Web.Data;
using Tos.FoodProcs.Web.Properties;

namespace Tos.FoodProcs.Web.Controllers
{
    /// <summary>
    /// ユーザーの情報に関するサービスを Web API として提供します。
    /// </summary>
    [Authorize]
    public class UserController : ApiController
    {
        /// <summary>
        /// 現在ログインしているユーザー名を取得します。
        /// </summary>
        public UserInfo Get()
        {
            var result = new UserInfo();
            //// TODO: Userに紐づく情報を取得します
            result.Code = User.Identity.Name;
            string decId;
            decId = User.Identity.Name;
            
            // TODO: Userに紐づく情報を取得します
            FoodProcsEntities context = new FoodProcsEntities();
            var views = from d in context.vw_user_info where d.cd_tanto == decId select d;
            var kaisha = (from ma in context.ma_kaisha
                        select ma).FirstOrDefault();
            var kojo = (from ma in context.ma_kojo
                          select ma).FirstOrDefault();
            var location = (from ma in context.cn_kino_sentaku
                            where ma.kbn_kino == ActionConst.kbn_location
                            select ma).FirstOrDefault();
            var hinmeiKirikae = (from ma in context.cn_kino_sentaku
                                 where ma.kbn_kino == ActionConst.kbn_hinmei_kirikae
                                select ma).FirstOrDefault();

            foreach (vw_user_info item in views)
            {
                result.Name = item.nm_tanto;
                //---------------------------------------------------------
                //2019/07/23 trinh.bd Update new column from [vw_user_info]
                //------------------------START----------------------------
                result.kbn_ma_hinmei = (item.kbn_ma_hinmei == null ? 0 : item.kbn_ma_hinmei);
                result.kbn_ma_haigo = (item.kbn_ma_haigo == null ? 0 : item.kbn_ma_haigo);
                result.kbn_ma_konyusaki = (item.kbn_ma_konyusaki == null ? 0 : item.kbn_ma_konyusaki);
                result.kbn_shikomi_chohyo = (item.kbn_shikomi_chohyo == null ? 0 : item.kbn_shikomi_chohyo);
                //-------------------------END-----------------------------
            }

            // 会社情報の設定
            result.Organization = kaisha.nm_kaisha;
            result.KaishaCode = kaisha.cd_kaisha;

            // 工場情報の設定
            result.Branch = kojo.nm_kojo;
            result.BranchCode = kojo.cd_kojo;

            if (location == null)
            {
                result.locationCode = 0;
            }
            else {
                result.locationCode = location.kbn_kino_naiyo;
            }

            if (hinmeiKirikae == null)
            {
                result.kbn_hinmei_kirikae = 0;
            }
            else
            {
                result.kbn_hinmei_kirikae = hinmeiKirikae.kbn_kino_naiyo;
            }

            // 現在ログインしているユーザーが付与されているロール（権限）をすべて取得します
            result.Roles.AddRange(Roles.GetRolesForUser());

            // 単位区分取得し、現在ログインしているユーザーに設定する
            var tani = (from ma in context.cn_kino_sentaku
                            where ma.kbn_kino == ActionConst.kbn_kino_kbn_tani 
                            select ma).FirstOrDefault();
            if (tani == null)
            {
                result.kbn_tani = "0";
            }
            else {
                result.kbn_tani = tani.kbn_kino_naiyo.ToString();
            }

            return result;
        }

        public void Update()
        {
            Membership.UpdateUser(Membership.GetUser(User.Identity.Name));
        }
    }
}