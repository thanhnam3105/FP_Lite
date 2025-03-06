using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Data.Objects;

namespace Tos.FoodProcs.Web.Data
{
	public class StoredProcedureResult<T>
	{
		public int __count { get; set; }
		public IEnumerable<T> d { get; set; }
	}
}