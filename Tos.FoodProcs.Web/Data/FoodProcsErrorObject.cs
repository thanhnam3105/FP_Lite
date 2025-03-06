using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Tos.FoodProcs.Web.Data
{
    public class FoodProcsErrorObject
    {
        public FoodProcsErrorObject(String tableName, String[] keys, String[] contents, String message)
        {
            tableName = this.tableName;
            keys = this.keys;
            contents = this.contents;
            message = this.message;
        }

        public String tableName { set; get; }
        public String[] keys;
        public String[] contents;
        public String message { set; get; }

    }
}