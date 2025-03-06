using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Text;
using System.Web.Services.Protocols;
using System.Xml.Serialization;
using Microsoft.Web.Services2;

namespace Tos.FoodProcs.Web.Services
{
    /// <summary>
    /// Soapを利用して、jasperに帳票発行の要求を行います
    /// </summary>
    [WebServiceBinding(Name = "repositorySoapBinding", Namespace = "Tos.FoodProcs.Web.Services")]
    class JasperService : WebServicesClientProtocol
    {
        // jasperservice url を返す
        public JasperService(string url)
        {
            this.Url = url;
        }

        //[return: SoapElement("runReportReturn")]
        [SoapRpcMethod]
        public string runReport(string requestXmlString)
        {
            return (string)base.Invoke("runReport", new object[] { requestXmlString })[0];
        }
    }
}
