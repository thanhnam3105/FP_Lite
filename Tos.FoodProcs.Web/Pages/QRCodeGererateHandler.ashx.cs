using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using MessagingToolkit.QRCode.Codec;
using System.Drawing;
using Tos.FoodProcs.Web.Properties;
using System.Text;


namespace Tos.FoodProcs.Web.Pages
{
    /// <summary>
    /// QRCodeを作成し、イメージを画面に返却します
    /// </summary>
    public class QRCodeGererateHandler : IHttpHandler
    {
        public void ProcessRequest(HttpContext context)
        {
            // 言語の選択
            string encode = "UTF-8";
            string lang = context.Request.QueryString.Get("lang");
            if (lang == Resources.LangJa)
            {
                encode = "shift-jis";
            }
            
            // ラベル作成
            string code = context.Request.QueryString.Get("code");
            context.Response.ContentType = "image/gif";
            if (code.Length > 0)
            {
                QRCodeEncoder qe = new QRCodeEncoder();
                qe.QRCodeBackgroundColor = Color.White;
                qe.QRCodeForegroundColor = Color.Black;
                qe.CharacterSet = encode;
                qe.QRCodeEncodeMode = QRCodeEncoder.ENCODE_MODE.BYTE;
                qe.QRCodeScale = Convert.ToInt16(4);
                qe.QRCodeVersion = Convert.ToInt16(0);

                // errorCorrect "M";
                qe.QRCodeErrorCorrect = QRCodeEncoder.ERROR_CORRECTION.M;

                // イメージをリサイズ
                Bitmap bm = qe.Encode(code); 
                // レスポンスに返却
                bm.Save(context.Response.OutputStream, System.Drawing.Imaging.ImageFormat.Gif);
            }
        }

        public bool IsReusable
        {
            get
            {
                return false;
            }
        }
    }
}